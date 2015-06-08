CREATE OR REPLACE PACKAGE quest_cmo_emergents AS
  package_version CONSTANT VARCHAR2(20) := '1.0.0';

  PROCEDURE find_DBFile_alerts
  (
    p_database_id         NUMBER
   ,p_pct_threshold       NUMBER
   ,p_next_fail_threshold NUMBER
   ,p_max_fail_threshold  NUMBER
   ,p_tbsp_full_threshold NUMBER
   ,p_critical_fail_date  NUMBER
  );
END quest_cmo_emergents;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_emergents AS

  --deleting current entries
  PROCEDURE delete_emergent
  (
    p_capacity_object_id NUMBER
   ,p_database_id        NUMBER
  ) IS
  
  BEGIN
    DELETE FROM quest_cmo_emergent_issue a
     WHERE a.associated_object_id = p_capacity_object_id
       AND a.database_id = p_database_id
       AND a.message_id IN
           (SELECT b.message_id
              FROM quest_cmo_emergent_issue_msg b
             WHERE b.message_code IN ('TBSP FULL', 'WILL FAIL', 'EXCESS FREE'));
  END delete_emergent;

  PROCEDURE insert_emergent
  (
    p_msg_id             NUMBER
   ,p_msg_type           VARCHAR2
   ,p_severity           NUMBER
   ,p_generated_on       DATE
   ,p_est_percent        NUMBER
   ,p_days_to_fail       NUMBER
   ,p_capacity_object_id NUMBER
   ,p_object_type        VARCHAR2
   ,p_total_size         NUMBER
   ,p_database_id        NUMBER
  ) IS
    issue_item_id NUMBER;
    data_item_id  NUMBER;
    date_too_large EXCEPTION;
    PRAGMA EXCEPTION_INIT(date_too_large, -01841);
  
    failure_date DATE;
  BEGIN
  
    INSERT INTO quest_cmo_emergent_issue
      (database_id
      ,message_id
      ,severity_level
      ,message_type
      ,emergent_issue_date
      ,associated_object_id
      ,associated_object_type)
    VALUES
      (p_database_id, p_msg_id, p_severity, p_msg_type, SYSDATE, p_capacity_object_id, p_object_type)
    RETURNING emergent_issue_id INTO issue_item_id;
  
    BEGIN
      IF abs(p_days_to_fail) >= 25 * 365.25
      THEN
        failure_date := NULL;
      ELSE
        failure_date := trunc(SYSDATE + p_days_to_fail);
      END IF;
    EXCEPTION
      WHEN date_too_large THEN
        failure_date := NULL;
    END;
  
    INSERT INTO quest_cmo_emergent_issue_data
      (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_date)
    VALUES
      ('DATE FAIL', issue_item_id, 'DAY', failure_date);
  
    INSERT INTO quest_cmo_emergent_issue_data
      (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_num)
    VALUES
      ('TOTAL SIZE', issue_item_id, 'KB', p_total_size);
  
    INSERT INTO quest_cmo_emergent_issue_data
      (emergent_issue_data_type, emergent_issue_id, value_unit, emergent_issue_value_num)
    VALUES
      ('ESTIMATED FREE', issue_item_id, 'NUM', p_est_percent);
    COMMIT;
  END insert_emergent;

  PROCEDURE find_DBFile_alerts
  (
    p_database_id         NUMBER
   ,p_pct_threshold       NUMBER
   ,p_next_fail_threshold NUMBER
   ,p_max_fail_threshold  NUMBER
   ,p_tbsp_full_threshold NUMBER
   ,p_critical_fail_date  NUMBER
  ) IS
    days_to_fail NUMBER;
    est_percent  NUMBER;
    severity     NUMBER;
    msg_id       NUMBER;
    msg_type     VARCHAR2(10);
  BEGIN
  
    FOR c1 IN (SELECT tbsp_capacity_object_id
                     ,tablespace_name
                     ,tbsp_type
                     ,MAX(df.snapshot_id) snapshot_id
                     ,MAX(start_snapshot) start_snapshot
                     ,SUM(total_amt) total_size
                     ,SUM(allocated_amt) total_allocated
                     ,SUM(free_amt) total_free
                     ,property_value_num growth_rate
                 FROM quest_cmo_datafile_snapshot    df
                     ,quest_cmo_object_last_snapshot ls
                     ,quest_cmo_capacity_object_prop prop
                WHERE df.database_id = p_database_id
                  AND df.df_capacity_object_id = ls.capacity_object_id
                  AND df.snapshot_id = ls.snapshot_id
                  AND df.tbsp_capacity_object_id = prop.capacity_object_id(+)
                  AND prop.cap_obj_prop_data_type(+) = 'GROWTH RATE ALLOC'
                  AND df.TBSP_SUBTYPE = 'PERMANENT'
                GROUP BY tbsp_capacity_object_id
                        ,tablespace_name
                        ,tbsp_type
                        ,property_value_num)
    LOOP
    
      delete_emergent(c1.tbsp_capacity_object_id, p_database_id);
      -- account for the time passed from lst snapshot to today
      est_percent := 100 * (c1.total_free - c1.growth_rate * ROUND((SYSDATE - c1.start_snapshot))) /
                     c1.total_size;
      IF (c1.growth_rate > 0)
         AND (c1.growth_rate IS NOT NULL)
      THEN
        days_to_fail := (c1.total_free / c1.growth_rate) - ROUND((SYSDATE - c1.start_snapshot));
        --days from last snapshot         -- now we want only days from today
      ELSE
        days_to_fail := NULL;
      END IF;
    
      IF (est_percent < p_pct_threshold)
         OR (days_to_fail < p_next_fail_threshold)
      THEN
      
        IF (est_percent < p_tbsp_full_threshold)
           OR (days_to_fail < p_critical_fail_date)
        THEN
          SELECT a.message_id
                ,b.severity_level
            INTO msg_id
                ,severity
            FROM quest_cmo_emergent_issue_msg a
                ,quest_cmo_emergent_issue_sev b
           WHERE a.message_code = 'TBSP FULL'
             AND b.severity_level_description = 'CRITICAL';
          msg_type := 'SIZE';
        ELSE
          SELECT a.message_id
                ,b.severity_level
            INTO msg_id
                ,severity
            FROM quest_cmo_emergent_issue_msg a
                ,quest_cmo_emergent_issue_sev b
           WHERE a.message_code = 'WILL FAIL'
             AND b.severity_level_description = 'WARNING';
          msg_type := 'GROWTH';
        END IF;
      
        insert_emergent(msg_id
                       ,msg_type
                       ,severity
                       ,ROUND(SYSDATE)
                       ,greatest(est_percent, 0)
                       ,days_to_fail
                       ,c1.tbsp_capacity_object_id
                       ,'CAPACITY OBJECT'
                       ,c1.total_size
                       ,p_database_id);
      
      ELSIF days_to_fail > p_max_fail_threshold
      THEN
      
        SELECT a.message_id
              ,b.severity_level
          INTO msg_id
              ,severity
          FROM quest_cmo_emergent_issue_msg a
              ,quest_cmo_emergent_issue_sev b
         WHERE a.message_code = 'EXCESS FREE'
           AND b.severity_level_description = 'ADVICE';
        msg_type := 'GROWTH';
        insert_emergent(msg_id
                       ,msg_type
                       ,severity
                       ,ROUND(SYSDATE)
                       ,greatest(est_percent, 0)
                       ,days_to_fail
                       ,c1.tbsp_capacity_object_id
                       ,'CAPACITY OBJECT'
                       ,c1.total_size
                       ,p_database_id);
      END IF;
    END LOOP;
  END find_DBFile_alerts;

END quest_cmo_emergents;
/

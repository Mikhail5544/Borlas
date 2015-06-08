CREATE OR REPLACE PACKAGE quest_cmo_user_manager IS
  PROCEDURE grant_user
  (
    user_p       IN VARCHAR2
   ,caller_is_qc BOOLEAN DEFAULT TRUE
  );
  PROCEDURE revoke_user
  (
    user_p       IN VARCHAR2
   ,caller_is_qc BOOLEAN DEFAULT TRUE
  );
  FUNCTION validate_user_access
  (
    user_p              IN VARCHAR2
   ,authorization_level IN VARCHAR2
  ) RETURN INTEGER;
END quest_cmo_user_manager;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_user_manager IS
  PROCEDURE manage_access
  (
    object_name_in IN VARCHAR2
   ,user_name_in   IN VARCHAR2
   ,sel            IN BOOLEAN DEFAULT FALSE
   ,dml            IN BOOLEAN DEFAULT FALSE
   ,exe            IN BOOLEAN DEFAULT FALSE
   ,grt            IN BOOLEAN DEFAULT FALSE
   ,rev            IN BOOLEAN DEFAULT FALSE
  ) IS
    cmd  VARCHAR2(6);
    cmd2 VARCHAR2(4);
    priv VARCHAR2(30);
  BEGIN
    IF grt
    THEN
      cmd  := 'grant';
      cmd2 := 'to';
    ELSIF rev
    THEN
      cmd  := 'revoke';
      cmd2 := 'from';
    END IF;
    IF dml
    THEN
      priv := 'select, insert, update, delete';
    ELSIF sel
    THEN
      priv := 'select';
    ELSIF exe
    THEN
      priv := 'execute';
    END IF;
    EXECUTE IMMEDIATE cmd || ' ' || priv || ' on ' || object_name_in || ' ' || cmd2 || ' ' ||
                      user_name_in;
  END manage_access;

  PROCEDURE grant_user
  (
    user_p       IN VARCHAR2
   ,caller_is_qc BOOLEAN DEFAULT TRUE
  ) IS
    dup_key EXCEPTION;
    PRAGMA EXCEPTION_INIT(dup_key, -00001);
  BEGIN
    -- tables
    manage_access('quest_cmo_capacity_object', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_capacity_object_prop', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_cap_obj_prop_typ', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_cap_obj_relation', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_collection_job', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_coll_job_last_run', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_coll_job_sched', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_databases', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_data_value_unit', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergent_issue', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergent_issue_data', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergent_issue_disp', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergent_issue_msg', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergent_issue_sev', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_emerg_iss_dtyp', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_frequency_type_code', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_item_data_type', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_history', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_objects', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_object_descr', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_run_method', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_schedule', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_status_type_code', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_type_code', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_message_type', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_object_last_snapshot', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_object_snapshot', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_object_type', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_preferences', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_preference_data', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_preference_set', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_preference_set_xref', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_pref_data_type', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_report_job', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_report_job_sched', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_schedule_run_days', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_seg_snapshot_tbsp', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_snapshot_data_value', user_p, dml => TRUE, grt => TRUE);
    manage_access('quest_cmo_snap_data_type', user_p, dml => TRUE, grt => TRUE);
  
    -- views
    manage_access('quest_cmo_datafile_property', user_p, sel => TRUE, grt => TRUE);
    manage_access('quest_cmo_datafile_snapshot', user_p, sel => TRUE, grt => TRUE);
    manage_access('quest_cmo_emerg_issue_values', user_p, sel => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_info', user_p, sel => TRUE, grt => TRUE);
    manage_access('quest_cmo_obj_snapshot_values', user_p, sel => TRUE, grt => TRUE);
    manage_access('quest_cmo_tablespace_property', user_p, sel => TRUE, grt => TRUE);
  
    -- functions, procedures, packages
    manage_access('quest_cmo_get_calendar_string', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_aggregator', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_calc_growth', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_collector', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_current', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_emergents', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_general_purpose', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_job_synch', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_schedule', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_schedule_util', user_p, exe => TRUE, grt => TRUE);
    manage_access('quest_cmo_run_collection', user_p, exe => TRUE, grt => TRUE);
  
    IF NOT caller_is_qc
    THEN
      BEGIN
        INSERT INTO quest_com_users
          (user_id, product_id, authorization_level, install_user)
          SELECT a.user_id
                ,b.product_id
                ,NULL
                ,b.install_user
            FROM all_users          a
                ,quest_com_products b
           WHERE a.username = user_p
             AND b.product_prefix = 'CMO';
        COMMIT;
      EXCEPTION
        WHEN dup_key THEN
          NULL;
      END;
    END IF;
  END grant_user;

  PROCEDURE revoke_user
  (
    user_p       IN VARCHAR2
   ,caller_is_qc BOOLEAN DEFAULT TRUE
  ) IS
  BEGIN
    DELETE FROM quest_com_users a
     WHERE (a.product_id, a.install_user, a.user_id) IN
           (SELECT b.product_id
                  ,b.install_user
                  ,c.user_id
              FROM quest_com_products b
                  ,all_users          c
             WHERE b.product_prefix = 'CMO'
               AND c.username = user_p);
    COMMIT;
  
    -- tables
    manage_access('quest_cmo_capacity_object', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_capacity_object_prop', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_cap_obj_prop_typ', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_cap_obj_relation', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_collection_job', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_coll_job_last_run', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_coll_job_sched', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_databases', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_data_value_unit', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergent_issue', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergent_issue_data', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergent_issue_disp', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergent_issue_msg', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergent_issue_sev', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_emerg_iss_dtyp', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_frequency_type_code', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_item_data_type', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_history', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_objects', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_object_descr', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_run_method', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_schedule', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_status_type_code', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_type_code', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_message_type', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_object_last_snapshot', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_object_snapshot', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_object_type', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_preferences', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_preference_data', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_preference_set', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_preference_set_xref', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_pref_data_type', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_report_job', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_report_job_sched', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_schedule_run_days', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_seg_snapshot_tbsp', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_snapshot_data_value', user_p, dml => TRUE, rev => TRUE);
    manage_access('quest_cmo_snap_data_type', user_p, dml => TRUE, rev => TRUE);
  
    -- views
    manage_access('quest_cmo_datafile_property', user_p, sel => TRUE, rev => TRUE);
    manage_access('quest_cmo_datafile_snapshot', user_p, sel => TRUE, rev => TRUE);
    manage_access('quest_cmo_emerg_issue_values', user_p, sel => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_info', user_p, sel => TRUE, rev => TRUE);
    manage_access('quest_cmo_obj_snapshot_values', user_p, sel => TRUE, rev => TRUE);
    manage_access('quest_cmo_tablespace_property', user_p, sel => TRUE, rev => TRUE);
  
    -- functions, procedures, packages
    manage_access('quest_cmo_get_calendar_string', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_aggregator', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_calc_growth', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_collector', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_current', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_emergents', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_general_purpose', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_job_synch', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_schedule', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_schedule_util', user_p, exe => TRUE, rev => TRUE);
    manage_access('quest_cmo_run_collection', user_p, exe => TRUE, rev => TRUE);
  END revoke_user;

  FUNCTION validate_user_access
  (
    user_p              IN VARCHAR2
   ,authorization_level IN VARCHAR2
  ) RETURN INTEGER IS
    nrows PLS_INTEGER;
  BEGIN
    SELECT COUNT(*)
      INTO nrows
      FROM quest_com_products a
          ,quest_com_users    b
          ,all_users          c
     WHERE a.product_prefix = 'CMO'
       AND b.product_id = a.product_id
       AND b.install_user = a.install_user
       AND b.user_id = c.user_id
       AND c.username = user_p;
    RETURN nrows;
  END validate_user_access;
END quest_cmo_user_manager;
/

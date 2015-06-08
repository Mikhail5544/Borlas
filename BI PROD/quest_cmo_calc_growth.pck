CREATE OR REPLACE PACKAGE quest_cmo_calc_growth AS
  package_version CONSTANT VARCHAR2(20) := '1.0.0';

  PROCEDURE all_tbsp_regression(p_database_id NUMBER);
  PROCEDURE all_datafile_regression(p_database_id NUMBER);

  PROCEDURE object_regression
  (
    p_database_id  NUMBER
   ,pObject_type   VARCHAR2
   ,pOwner         VARCHAR2
   ,pObject_name   VARCHAR2
   ,pSubname       VARCHAR2
   ,pdata_type     VARCHAR2
   ,SlopeAllocated OUT DOUBLE PRECISION
   ,bAllocated     OUT DOUBLE PRECISION
   ,SlopeHWM       OUT DOUBLE PRECISION
   ,bHWM           OUT DOUBLE PRECISION
   ,slopeUsed      OUT DOUBLE PRECISION
   ,bUsed          OUT DOUBLE PRECISION
  );

  PROCEDURE ts_regression
  (
    p_database_id     NUMBER
   ,p_tablespace_name VARCHAR2
   ,SlopeAllocated    OUT DOUBLE PRECISION
   ,bAllocated        OUT DOUBLE PRECISION
   ,SlopeSize         OUT DOUBLE PRECISION
   ,bSize             OUT DOUBLE PRECISION
  );

  PROCEDURE df_regression
  (
    p_database_id   NUMBER
   ,p_datafile_name VARCHAR2
   ,SlopeAllocated  OUT DOUBLE PRECISION
   ,bAllocated      OUT DOUBLE PRECISION
   ,SlopeSize       OUT DOUBLE PRECISION
   ,bSize           OUT DOUBLE PRECISION
  );

  PROCEDURE db_regression
  (
    p_database_id  NUMBER
   ,SlopeAllocated OUT DOUBLE PRECISION
   ,bAllocated     OUT DOUBLE PRECISION
   ,SlopeSize      OUT DOUBLE PRECISION
   ,bSize          OUT DOUBLE PRECISION
  );

END quest_cmo_calc_growth;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_calc_growth AS

  TYPE number_table IS TABLE OF DOUBLE PRECISION NOT NULL INDEX BY BINARY_INTEGER;

  TYPE date_table IS TABLE OF DATE NOT NULL INDEX BY BINARY_INTEGER;

  PROCEDURE all_tbsp_regression(p_database_id NUMBER) IS
    SlopeAllocated DOUBLE PRECISION;
    bAllocated     DOUBLE PRECISION;
    SlopeSize      DOUBLE PRECISION;
    bSize          DOUBLE PRECISION;
  BEGIN
    FOR ts_cur IN (SELECT object_name        tablespace_name
                         ,capacity_object_id ts_capacity_object_id
                     FROM QUEST_CMO_CAPACITY_OBJECT ob
                         ,QUEST_CMO_OBJECT_TYPE     typ
                    WHERE ob.object_type_code = typ.object_type_code
                      AND typ.object_type = 'TABLESPACE'
                      AND database_id = p_database_id)
    LOOP
      ts_regression(p_database_id
                   ,ts_cur.tablespace_name
                   ,SlopeAllocated
                   ,bAllocated
                   ,SlopeSize
                   ,bSize);
      IF slopeAllocated IS NOT NULL
      THEN
        DELETE FROM quest_cmo_capacity_object_prop
         WHERE capacity_object_id = ts_cur.ts_capacity_object_id
           AND cap_obj_prop_data_type = 'GROWTH RATE ALLOC';
      
        INSERT INTO quest_cmo_capacity_object_prop
          (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
        VALUES
          ('KB', ts_cur.ts_capacity_object_id, 'GROWTH RATE ALLOC', ROUND(SlopeAllocated, 2));
      
      END IF;
    
      IF slopeSize IS NOT NULL
      THEN
        DELETE FROM quest_cmo_capacity_object_prop
         WHERE capacity_object_id = ts_cur.ts_capacity_object_id
           AND cap_obj_prop_data_type = 'GROWTH RATE TOTAL';
      
        INSERT INTO quest_cmo_capacity_object_prop
          (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
        VALUES
          ('KB', ts_cur.ts_capacity_object_id, 'GROWTH RATE TOTAL', ROUND(SlopeSize, 2));
      
      END IF;
    END LOOP;
    COMMIT;
  
  END all_tbsp_regression;

  PROCEDURE all_datafile_regression(p_database_id NUMBER) IS
    SlopeAllocated DOUBLE PRECISION;
    bAllocated     DOUBLE PRECISION;
    SlopeSize      DOUBLE PRECISION;
    bSize          DOUBLE PRECISION;
  BEGIN
    FOR df_cur IN (SELECT object_name        datafile_name
                         ,capacity_object_id df_capacity_object_id
                     FROM QUEST_CMO_CAPACITY_OBJECT ob
                         ,QUEST_CMO_OBJECT_TYPE     typ
                    WHERE ob.object_type_code = typ.object_type_code
                      AND typ.object_type = 'DATAFILE'
                      AND database_id = p_database_id)
    LOOP
      df_regression(p_database_id, df_cur.datafile_name, SlopeAllocated, bAllocated, SlopeSize, bSize);
      IF slopeAllocated IS NOT NULL
      THEN
        DELETE FROM quest_cmo_capacity_object_prop
         WHERE capacity_object_id = df_cur.df_capacity_object_id
           AND cap_obj_prop_data_type = 'GROWTH RATE ALLOC';
      
        INSERT INTO quest_cmo_capacity_object_prop
          (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
        VALUES
          ('KB', df_cur.df_capacity_object_id, 'GROWTH RATE ALLOC', ROUND(SlopeAllocated, 2));
      
      END IF;
    
      IF slopeSize IS NOT NULL
      THEN
        DELETE FROM quest_cmo_capacity_object_prop
         WHERE capacity_object_id = df_cur.df_capacity_object_id
           AND cap_obj_prop_data_type = 'GROWTH RATE TOTAL';
      
        INSERT INTO quest_cmo_capacity_object_prop
          (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
        VALUES
          ('KB', df_cur.df_capacity_object_id, 'GROWTH RATE TOTAL', ROUND(SlopeSize, 2));
      
      END IF;
    END LOOP;
    COMMIT;
  
  END all_datafile_regression;

  PROCEDURE calc_rate
  (
    arrayX     Number_table
   ,arrayY     Number_table
   ,irows      NUMBER
   ,SlopeVAlue IN OUT DOUBLE PRECISION
   ,bValue     IN OUT DOUBLE PRECISION
  ) IS
  
    avgX DOUBLE PRECISION;
    sumX DOUBLE PRECISION;
  
    sumSqrX DOUBLE PRECISION;
  
    avgY         DOUBLE PRECISION;
    sumY         DOUBLE PRECISION;
    sumXY        DOUBLE PRECISION;
    my_date      DATE;
    iNotNullRows NUMBER;
  BEGIN
    sumX    := 0;
    sumSQRX := 0;
    avgX    := 0;
  
    sumY         := 0;
    sumXY        := 0;
    avgY         := 0;
    iNotNullRows := 0;
    my_date      := SYSDATE;
    FOR i IN 1 .. iRows
    LOOP
    
      IF (arrayY(i) IS NOT NULL)
         AND (arrayY(i) >= 0)
      THEN
        sumX    := sumX + arrayX(i);
        sumSqrX := sumSqrX + arrayX(i) * arrayX(i);
      
        sumY  := SumY + arrayY(i);
        sumXY := sumXY + ArrayY(i) * ArrayX(i);
      
        iNotNullRows := iNotNullRows + 1;
      END IF;
    END LOOP;
    IF iNotNullRows > 0
    THEN
      AvgX := sumX / iNotNullRows;
      avgY := sumY / iNotNullRows;
      IF (SumSqrX - iNotNullRows * avgX * AvgX) <> 0
      THEN
        SlopeValue := (SumXY - iNotNullRows * avgX * avgY) / (SumSqrX - iNotNullRows * avgX * AvgX);
      END IF;
    END IF;
  
  END calc_rate;

  PROCEDURE object_regression
  (
    p_database_id  NUMBER
   ,pObject_type   VARCHAR2
   ,pOwner         VARCHAR2
   ,pObject_name   VARCHAR2
   ,pSubname       VARCHAR2
   ,pdata_type     VARCHAR2
   ,SlopeAllocated OUT DOUBLE PRECISION
   ,bAllocated     OUT DOUBLE PRECISION
   ,SlopeHWM       OUT DOUBLE PRECISION
   ,bHWM           OUT DOUBLE PRECISION
   ,slopeUsed      OUT DOUBLE PRECISION
   ,bUsed          OUT DOUBLE PRECISION
  ) IS
  
    x_allocated number_table;
    x_hwm       number_table;
    x_used      number_table;
    days        number_table;
  
    Stampdate DATE;
    my_date   DATE;
  
    i    BINARY_INTEGER;
    iRow BINARY_INTEGER;
  
  BEGIN
    FOR c1 IN (SELECT object_name
                     ,allocated
                     ,used
                     ,high_water_mark
                     ,start_snapshot
                 FROM quest_cmo_obj_snapshot_values
                WHERE object_type = pobject_type
                  AND database_id = p_database_id
                  AND object_name = pObject_name
                  AND owner = pOwner
                  AND (subname = pSubname OR pSubname IS NULL))
    LOOP
      x_allocated(iRow) := c1.allocated;
      x_hwm(iRow) := c1.high_water_mark;
      x_used(iRow) := c1.used;
      days(iRow) := MONTHS_BETWEEN(c1.start_snapshot, to_date('2000/01/01', 'yyyy/mm/dd')) * 31.0;
      irow := iRow + 1;
    END LOOP;
    calc_rate(days, x_used, irow, slopeUsed, BUsed);
    calc_rate(days, x_allocated, irow, slopeallocated, BAllocated);
    calc_rate(days, x_HWM, irow, slopeHWM, BHWM);
  END object_regression;

  PROCEDURE ts_regression
  (
    p_database_id     NUMBER
   ,p_tablespace_name VARCHAR2
   ,SlopeAllocated    OUT DOUBLE PRECISION
   ,bAllocated        OUT DOUBLE PRECISION
   ,SlopeSize         OUT DOUBLE PRECISION
   ,bSize             OUT DOUBLE PRECISION
  ) IS
  
    x_allocated number_table;
    x_size      number_table;
  
    days number_table;
  
    Stampdate DATE;
    my_date   DATE;
  
    i    BINARY_INTEGER;
    iRow BINARY_INTEGER;
  
  BEGIN
    iRow := 1;
    FOR c1 IN (SELECT p_tablespace_name
                     ,SUM(total_amt) total_size
                     ,SUM(allocated_amt) allocated
                     ,MAX(h.start_time) start_snapshot
                 FROM quest_cmo_datafile_snapshot s
                     ,quest_cmo_job_history       h
                WHERE database_id = p_database_id
                  AND tablespace_name = p_tablespace_name
                  AND s.job_history_id = h.job_history_id
                GROUP BY h.start_time
                        ,h.job_history_id)
    LOOP
      x_allocated(iRow) := nvl(c1.allocated, -1);
      x_size(iRow) := nvl(c1.total_size, -1);
      days(iRow) := MONTHS_BETWEEN(c1.start_snapshot, to_date('1990/01/01', 'yyyy/mm/dd')) * 31.0;
      irow := iRow + 1;
    END LOOP;
    IF iRow < 3
    THEN
      RETURN;
    END IF;
  
    calc_rate(days, x_allocated, irow - 1, slopeallocated, BAllocated);
    calc_rate(days, x_size, irow - 1, slopeSize, BSize);
  END ts_regression;

  PROCEDURE df_regression
  (
    p_database_id   NUMBER
   ,p_datafile_name VARCHAR2
   ,SlopeAllocated  OUT DOUBLE PRECISION
   ,bAllocated      OUT DOUBLE PRECISION
   ,SlopeSize       OUT DOUBLE PRECISION
   ,bSize           OUT DOUBLE PRECISION
  ) IS
  
    x_allocated number_table;
    x_size      number_table;
  
    days number_table;
  
    Stampdate DATE;
    my_date   DATE;
  
    i    BINARY_INTEGER;
    iRow BINARY_INTEGER;
  
  BEGIN
    iRow := 1;
    FOR c1 IN (SELECT p_datafile_name
                     ,total_amt       total_size
                     ,allocated_amt   allocated
                     ,start_snapshot
                 FROM quest_cmo_datafile_snapshot
                WHERE database_id = p_database_id
                  AND file_name = p_datafile_name)
    LOOP
      x_allocated(iRow) := nvl(c1.allocated, -1);
      x_size(iRow) := nvl(c1.total_size, -1);
      days(iRow) := MONTHS_BETWEEN(c1.start_snapshot, to_date('1990/01/01', 'yyyy/mm/dd')) * 31.0;
      irow := iRow + 1;
    END LOOP;
    IF iRow < 3
    THEN
      RETURN;
    END IF;
    calc_rate(days, x_allocated, irow - 1, slopeallocated, BAllocated);
    calc_rate(days, x_size, irow - 1, slopeSize, BSize);
  END df_regression;

  PROCEDURE db_regression
  (
    p_database_id  NUMBER
   ,SlopeAllocated OUT DOUBLE PRECISION
   ,bAllocated     OUT DOUBLE PRECISION
   ,SlopeSize      OUT DOUBLE PRECISION
   ,bSize          OUT DOUBLE PRECISION
  ) IS
  
    x_allocated number_table;
    x_size      number_table;
  
    days number_table;
  
    Stampdate DATE;
    my_date   DATE;
  
    i    BINARY_INTEGER;
    iRow BINARY_INTEGER;
  
  BEGIN
    FOR c1 IN (SELECT database_id
                     ,SUM(nvl(total_amt, 0)) total_size
                     ,SUM(nvl(allocated_amt, 0)) allocated
                     ,MAX(h.start_time) start_snapshot
                 FROM quest_cmo_datafile_snapshot s
                     ,quest_cmo_job_history       h
                WHERE database_id = p_database_id
                  AND h.job_history_id = s.job_history_id
                GROUP BY h.start_time
                        ,h.job_history_id)
    LOOP
      x_allocated(iRow) := nvl(c1.allocated, -1);
      x_size(iRow) := nvl(c1.total_size, -1);
    
      days(iRow) := MONTHS_BETWEEN(c1.start_snapshot, to_date('1990/01/01', 'yyyy/mm/dd')) * 31.0;
      irow := iRow + 1;
    END LOOP;
    IF iRow < 3
    THEN
      RETURN;
    END IF;
  
    calc_rate(days, x_allocated, irow, slopeallocated, BAllocated);
    calc_rate(days, x_size, irow, slopeSize, BSize);
  END db_regression;

END quest_cmo_calc_growth;
/

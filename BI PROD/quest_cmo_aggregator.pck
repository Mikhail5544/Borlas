CREATE OR REPLACE PACKAGE quest_cmo_aggregator AS
  package_version CONSTANT VARCHAR2(20) := '1.0.0';

  PROCEDURE datafile_aggregator
  (
    db_id_in          IN quest_cmo_databases.database_id%TYPE
   ,job_history_id_in IN quest_cmo_job_history.job_history_id%TYPE
  );

  PROCEDURE datafile_aggregator_initial(db_id_in IN quest_cmo_databases.database_id%TYPE);

  -- procedures declared externally because they are called from a
  --  dynamic anonymous PL/SQL block in this package, but not meant to be
  --  called outside of quest_cmo_aggregator
  PROCEDURE store_datafile_stat
  (
    db_id_in          IN quest_cmo_databases.database_id%TYPE
   ,job_history_id_in IN quest_cmo_job_history.job_history_id%TYPE
   ,dbi               IN quest_cmo_collector.db_info
   ,dfst              IN quest_cmo_collector.datafile_stats_tab
  );

  PROCEDURE store_datafile_history
  (
    db_id_in IN quest_cmo_databases.database_id%TYPE
   ,dfst     IN quest_cmo_collector.datafile_stats_tab
  );

END quest_cmo_aggregator;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_aggregator AS
  FUNCTION get_database_link(database_id_in IN NUMBER) RETURN VARCHAR2 IS
    this_db_link quest_cmo_databases.database_link%TYPE;
  BEGIN
    SELECT database_link
      INTO this_db_link
      FROM quest_cmo_databases
     WHERE database_id = database_id_in;
    RETURN this_db_link;
  END get_database_link;

  PROCEDURE store_tablespace_property
  (
    tbsp_db_id_in IN quest_cmo_databases.database_id%TYPE
   ,tbsp_info     IN quest_cmo_collector.datafile_stats
   ,tbsp_id_out   OUT quest_cmo_capacity_object.capacity_object_id%TYPE
  ) IS
  BEGIN
    -- +++++++ storing tablespace in object table
    MERGE INTO quest_cmo_capacity_object a
    USING (SELECT tbsp_info.ts_tablespace_name AS tablespace_name
                 ,CASE tbsp_info.ts_contents
                    WHEN 'UNDO' THEN
                     (SELECT object_type_code
                        FROM quest_cmo_object_type
                       WHERE object_type = 'TABLESPACE'
                         AND object_subtype = 'UNDO')
                    WHEN 'PERMANENT' THEN
                     (SELECT object_type_code
                        FROM quest_cmo_object_type
                       WHERE object_type = 'TABLESPACE'
                         AND object_subtype = 'PERMANENT')
                    WHEN 'TEMPORARY' THEN
                     CASE tbsp_info.ts_extent_management
                       WHEN 'LOCAL' THEN
                        (SELECT object_type_code
                           FROM quest_cmo_object_type
                          WHERE object_type = 'TABLESPACE'
                            AND object_subtype = 'TEMPORARY TEMPFILE')
                       ELSE
                        (SELECT object_type_code
                           FROM quest_cmo_object_type
                          WHERE object_type = 'TABLESPACE'
                            AND object_subtype = 'TEMPORARY DATAFILE')
                     END
                  END AS object_type_code
             FROM dual) c
    ON (a.database_id = tbsp_db_id_in AND c.tablespace_name = a.object_name AND a.object_type_code IN (SELECT d.object_type_code
                                                                                                         FROM quest_cmo_object_type d
                                                                                                        WHERE d.object_type =
                                                                                                              'TABLESPACE'))
    WHEN MATCHED THEN
      UPDATE SET a.object_type_code = c.object_type_code
    WHEN NOT MATCHED THEN
      INSERT
        (a.database_id, a.object_name, a.object_type_code)
      VALUES
        (tbsp_db_id_in, c.tablespace_name, c.object_type_code);
  
    -- +++++++ storing tablespace properties in property table
    SELECT a.capacity_object_id
      INTO tbsp_id_out
      FROM quest_cmo_capacity_object a
     WHERE a.database_id = tbsp_db_id_in
       AND a.object_name = tbsp_info.ts_tablespace_name
       AND a.object_type_code IN
           (SELECT b.object_type_code FROM quest_cmo_object_type b WHERE b.object_type = 'TABLESPACE');
    DELETE FROM quest_cmo_capacity_object_prop WHERE capacity_object_id = tbsp_id_out;
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
    VALUES
      ('B', tbsp_id_out, 'TBSP INIEXT', tbsp_info.ts_initial_extent);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
    VALUES
      ('B', tbsp_id_out, 'TBSP BLKSIZ', tbsp_info.ts_blocksize);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
    VALUES
      ('B', tbsp_id_out, 'TBSP MINEXTL', tbsp_info.ts_min_extlen);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, tbsp_id_out, 'TBSP EXTMGMT', tbsp_info.ts_extent_management);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, tbsp_id_out, 'TBSP ALLOCTYP', tbsp_info.ts_allocation_type);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, tbsp_id_out, 'TBSP SSM', tbsp_info.ts_segment_space_management);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, tbsp_id_out, 'TBSP BIGF', tbsp_info.ts_bigfile);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, tbsp_id_out, 'TBSP CONT', tbsp_info.ts_contents);
  END store_tablespace_property;

  PROCEDURE store_tablespace_snapshot
  (
    tbsp_info         IN quest_cmo_collector.datafile_stats
   ,tbsp_id_in        IN quest_cmo_capacity_object.capacity_object_id%TYPE
   ,job_history_id_in IN quest_cmo_job_history.job_history_id%TYPE
  ) IS
    tbsp_snapshot_id quest_cmo_object_snapshot.snapshot_id%TYPE;
  BEGIN
    -- +++++++ storing tablespace snapshot info
    INSERT INTO quest_cmo_object_snapshot
      (job_history_id, capacity_object_id, start_snapshot, end_snapshot)
    VALUES
      (job_history_id_in, tbsp_id_in, tbsp_info.snapshot_date, tbsp_info.snapshot_date)
    RETURNING snapshot_id INTO tbsp_snapshot_id;
  
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, snapshot_data_value_char)
    VALUES
      (tbsp_snapshot_id, 'TBSP STATUS', tbsp_info.ts_status);
  END store_tablespace_snapshot;

  PROCEDURE store_datafile_property
  (
    db_id_in   IN quest_cmo_databases.database_id%TYPE
   ,tbsp_id_in IN quest_cmo_capacity_object.capacity_object_id%TYPE
   ,dbf_id_out OUT quest_cmo_capacity_object.capacity_object_id%TYPE
   ,dbf_info   IN quest_cmo_collector.datafile_stats
  ) IS
  BEGIN
    -- +++++++ storing datafile in object table
    MERGE INTO quest_cmo_capacity_object a
    USING (SELECT dbf_info.df_datafile_name AS file_name
                 ,e.object_type_code
                 ,tbsp_id_in                AS tablespace_capacity_object_id
             FROM quest_cmo_object_type e
            WHERE e.object_type = CASE dbf_info.ts_contents
                    WHEN 'TEMPORARY' THEN
                     CASE dbf_info.ts_extent_management
                       WHEN 'LOCAL' THEN
                        'TEMPFILE'
                       ELSE
                        'DATAFILE'
                     END
                    ELSE
                     'DATAFILE'
                  END) j
    ON (a.database_id = db_id_in AND j.file_name = a.object_name AND a.object_type_code IN (SELECT k.object_type_code
                                                                                              FROM quest_cmo_object_type k
                                                                                             WHERE k.object_type IN
                                                                                                   ('DATAFILE'
                                                                                                   ,'TEMPFILE')))
    WHEN MATCHED THEN
      UPDATE
         SET a.object_type_code = j.object_type_code
            ,a.container        = j.tablespace_capacity_object_id
    WHEN NOT MATCHED THEN
      INSERT
        (a.database_id, a.object_name, a.object_type_code, a.container)
      VALUES
        (db_id_in, j.file_name, j.object_type_code, j.tablespace_capacity_object_id);
  
    -- +++++++ storing datafile properties in property table
    SELECT a.capacity_object_id
      INTO dbf_id_out
      FROM quest_cmo_capacity_object a
     WHERE a.database_id = db_id_in
       AND a.object_name = dbf_info.df_datafile_name
       AND a.object_type_code IN
           (SELECT b.object_type_code
              FROM quest_cmo_object_type b
             WHERE b.object_type IN ('DATAFILE', 'TEMPFILE'));
    DELETE FROM quest_cmo_capacity_object_prop WHERE capacity_object_id = dbf_id_out;
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_char)
    VALUES
      (NULL, dbf_id_out, 'DF AUTOEXT', dbf_info.df_autoextensible);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
    VALUES
      ('MB', dbf_id_out, 'DF NEXT', dbf_info.df_next_size);
    INSERT INTO quest_cmo_capacity_object_prop
      (value_unit, capacity_object_id, cap_obj_prop_data_type, property_value_num)
    VALUES
      ('MB', dbf_id_out, 'DF MAX', dbf_info.df_max_size);
  END store_datafile_property;

  PROCEDURE store_datafile_snapshot
  (
    snap_id_in IN quest_cmo_object_snapshot.snapshot_id%TYPE
   ,dbf_info   IN quest_cmo_collector.datafile_stats
  ) IS
  BEGIN
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'ALLOC', 'MB', dbf_info.df_total_size);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'USABLE', 'MB', dbf_info.df_usable_size);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'USED', 'MB', dbf_info.df_allocation);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF FREE', 'MB', dbf_info.df_free_space);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'HWM', 'B', dbf_info.df_highest_block * dbf_info.ts_blocksize);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF ALLOC DATA', 'B', dbf_info.df_data_alloc);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF ALLOC INDX', 'B', dbf_info.df_index_alloc);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF ALLOC UNDO', 'B', dbf_info.df_rollback_alloc);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF ALLOC TEMP', 'B', dbf_info.df_temp_alloc);
    INSERT INTO quest_cmo_snapshot_data_value
      (snapshot_id, snap_data_type, value_unit, snapshot_data_value_num)
    VALUES
      (snap_id_in, 'DF ALLOC OTHER', 'B', dbf_info.df_other_alloc);
  END store_datafile_snapshot;

  PROCEDURE store_datafile_stat
  (
    db_id_in          IN quest_cmo_databases.database_id%TYPE
   ,job_history_id_in IN quest_cmo_job_history.job_history_id%TYPE
   ,dbi               IN quest_cmo_collector.db_info
   ,dfst              IN quest_cmo_collector.datafile_stats_tab
  ) IS
    this_snapshot_id  quest_cmo_object_snapshot.snapshot_id%TYPE;
    current_tbsp_id   quest_cmo_capacity_object.capacity_object_id%TYPE;
    current_dbf_id    quest_cmo_capacity_object.capacity_object_id%TYPE;
    previous_snapshot quest_cmo_object_last_snapshot.snapshot_id%TYPE;
    new_tbsp          BOOLEAN;
  BEGIN
    UPDATE quest_cmo_databases a
       SET a.software_version = dbi.dbms_version
    -- database name and server name fields?
     WHERE database_id = db_id_in;
  
    FOR i IN 1 .. dfst.last
    LOOP
      new_tbsp := FALSE;
      IF NOT dfst.exists(i - 1)
      THEN
        new_tbsp := TRUE;
      ELSIF dfst(i).ts_tablespace_name != dfst(i - 1).ts_tablespace_name
      THEN
        new_tbsp := TRUE;
      END IF;
      IF new_tbsp
      THEN
        store_tablespace_property(db_id_in, dfst(i), current_tbsp_id);
        store_tablespace_snapshot(dfst(i), current_tbsp_id, job_history_id_in);
      END IF;
    
      store_datafile_property(db_id_in, current_tbsp_id, current_dbf_id, dfst(i));
    
      -- for offline tablespaces we will use the values from the previous
      -- snapshot.
      IF dfst(i).ts_status = 'OFFLINE'
      THEN
        BEGIN
          SELECT snapshot_id
            INTO previous_snapshot
            FROM quest_cmo_object_last_snapshot
           WHERE capacity_object_id = current_dbf_id;
        EXCEPTION
          WHEN no_data_found THEN
            previous_snapshot := NULL;
        END;
      END IF;
    
      -- +++++++ storing datafile snapshot info
      INSERT INTO quest_cmo_object_snapshot
        (job_history_id, capacity_object_id, start_snapshot, end_snapshot)
      VALUES
        (job_history_id_in, current_dbf_id, dfst(i).snapshot_date, dfst(i).snapshot_date)
      RETURNING snapshot_id INTO this_snapshot_id;
    
      IF dfst(i).ts_status = 'OFFLINE'
          AND previous_snapshot IS NOT NULL
      THEN
        INSERT INTO quest_cmo_snapshot_data_value
          (snapshot_id
          ,snap_data_type
          ,value_unit
          ,snapshot_data_value_num
          ,snapshot_data_value_date
          ,snapshot_data_value_char)
          SELECT this_snapshot_id
                ,b.snap_data_type
                ,b.value_unit
                ,b.snapshot_data_value_num
                ,b.snapshot_data_value_date
                ,b.snapshot_data_value_char
            FROM quest_cmo_snapshot_data_value b
           WHERE b.snapshot_id = previous_snapshot
             AND b.snap_data_type IN ('ALLOC'
                                     ,'USABLE'
                                     ,'USED'
                                     ,'DF FREE'
                                     ,'HWM'
                                     ,'DF ALLOC DATA'
                                     ,'DF ALLOC INDX'
                                     ,'DF ALLOC UNDO'
                                     ,'DF ALLOC TEMP'
                                     ,'DF ALLOC OTHER');
      ELSE
        store_datafile_snapshot(this_snapshot_id, dfst(i));
      END IF;
    END LOOP;
  END store_datafile_stat;

  PROCEDURE store_datafile_history
  (
    db_id_in IN quest_cmo_databases.database_id%TYPE
   ,dfst     IN quest_cmo_collector.datafile_stats_tab
  ) IS
    this_snapshot_id       quest_cmo_object_snapshot.snapshot_id%TYPE;
    current_tbsp_id        quest_cmo_capacity_object.capacity_object_id%TYPE;
    current_dbf_id         quest_cmo_capacity_object.capacity_object_id%TYPE;
    current_job_history_id quest_cmo_job_history.job_history_id%TYPE;
    temp_dbf_rec           quest_cmo_collector.datafile_stats;
    TYPE cap_obj_id_tab IS TABLE OF quest_cmo_capacity_object.capacity_object_id%TYPE INDEX BY BINARY_INTEGER;
    dbf_ids         cap_obj_id_tab;
    tbsp_ids        cap_obj_id_tab;
    new_job_history BOOLEAN;
    new_tbsp        BOOLEAN;
    TYPE bool_tab IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
    tbsp_snapshot_this_row bool_tab;
  BEGIN
    FOR i IN 1 .. dfst.last
    LOOP
      temp_dbf_rec    := dfst(i);
      new_job_history := FALSE;
      new_tbsp        := FALSE;
      -- this check put in because sometimes creation date is null
      --  in v$tempfile
      IF temp_dbf_rec.snapshot_date IS NULL
      THEN
        IF dfst.exists(i - 1)
        THEN
          temp_dbf_rec.snapshot_date := dfst(i - 1).snapshot_date;
        ELSE
          temp_dbf_rec.snapshot_date := SYSDATE;
        END IF;
      END IF;
      IF NOT dfst.exists(i - 1)
      THEN
        new_job_history := TRUE;
      ELSIF trunc(temp_dbf_rec.snapshot_date) != trunc(dfst(i - 1).snapshot_date)
      THEN
        new_job_history := TRUE;
      END IF;
      IF new_job_history
      THEN
        INSERT INTO quest_cmo_job_history
          (status_type_code, start_time, end_time)
        VALUES
          ('COMP', temp_dbf_rec.snapshot_date, temp_dbf_rec.snapshot_date)
        RETURNING job_history_id INTO current_job_history_id;
        new_tbsp := TRUE;
      ELSE
        IF dfst(i).ts_tablespace_name != dfst(i - 1).ts_tablespace_name
        THEN
          new_tbsp := TRUE;
        END IF;
      END IF;
    
      IF new_tbsp
      THEN
        store_tablespace_property(db_id_in, temp_dbf_rec, current_tbsp_id);
        store_tablespace_snapshot(temp_dbf_rec, current_tbsp_id, current_job_history_id);
      END IF;
    
      store_datafile_property(db_id_in, current_tbsp_id, current_dbf_id, temp_dbf_rec);
    
      -- +++++++ storing datafile snapshot info
      INSERT INTO quest_cmo_object_snapshot
        (job_history_id, capacity_object_id, start_snapshot, end_snapshot)
      VALUES
        (current_job_history_id
        ,current_dbf_id
        ,temp_dbf_rec.snapshot_date
        ,temp_dbf_rec.snapshot_date)
      RETURNING snapshot_id INTO this_snapshot_id;
    
      store_datafile_snapshot(this_snapshot_id, temp_dbf_rec);
    
      tbsp_snapshot_this_row(i) := new_tbsp;
      tbsp_ids(i) := current_tbsp_id;
      dbf_ids(i) := current_dbf_id;
    
      IF new_job_history
         AND i > 1
      THEN
        FOR j IN 1 .. i - 1
        LOOP
          temp_dbf_rec               := dfst(j);
          temp_dbf_rec.snapshot_date := dfst(i).snapshot_date;
          IF tbsp_snapshot_this_row(j)
          THEN
            store_tablespace_snapshot(temp_dbf_rec, tbsp_ids(j), current_job_history_id);
          END IF;
          INSERT INTO quest_cmo_object_snapshot
            (job_history_id, capacity_object_id, start_snapshot, end_snapshot)
          VALUES
            (current_job_history_id
            ,dbf_ids(j)
            ,temp_dbf_rec.snapshot_date
            ,temp_dbf_rec.snapshot_date)
          RETURNING snapshot_id INTO this_snapshot_id;
          store_datafile_snapshot(this_snapshot_id, temp_dbf_rec);
        END LOOP;
      END IF;
    END LOOP;
  END store_datafile_history;

  PROCEDURE datafile_aggregator
  (
    db_id_in          IN quest_cmo_databases.database_id%TYPE
   ,job_history_id_in IN quest_cmo_job_history.job_history_id%TYPE
  ) IS
    db_link quest_cmo_databases.database_link%TYPE;
    dfst    quest_cmo_collector.datafile_stats_tab;
    dbi     quest_cmo_collector.db_info;
  BEGIN
    db_link := get_database_link(db_id_in);
    IF db_link IS NULL
    THEN
      quest_cmo_collector.get_db_info(dbi);
      quest_cmo_collector.get_datafile_stats(dfst);
      store_datafile_stat(db_id_in, job_history_id_in, dbi, dfst);
    ELSE
      EXECUTE IMMEDIATE 'declare dbi_loc quest_cmo_collector.db_info ; ' ||
                        ' dbi_remote quest_cmo_collector.db_info@"' || db_link || '" ; ' ||
                        ' dfst_loc quest_cmo_collector.datafile_stats_tab ; ' ||
                        ' dfst_remote quest_cmo_collector.datafile_stats_tab@"' || db_link || '" ; ' ||
                        'begin quest_cmo_collector.get_db_info@"' || db_link || '" (dbi_remote) ; ' ||
                        ' dbi_loc.database_name := dbi_remote.database_name ; ' ||
                        ' dbi_loc.server_name := dbi_remote.server_name ; ' ||
                        ' dbi_loc.dbms_version := dbi_remote.dbms_version ; ' ||
                        ' quest_cmo_collector.get_datafile_stats@"' || db_link || '" (dfst_remote) ; ' ||
                        ' for i in 1..dfst_remote.count loop ' ||
                        '  dfst_loc(i).df_datafile_name := dfst_remote(i).df_datafile_name ; ' ||
                        '  dfst_loc(i).ts_tablespace_name := dfst_remote(i).ts_tablespace_name ; ' ||
                        '  dfst_loc(i).df_autoextensible := dfst_remote(i).df_autoextensible ; ' ||
                        '  dfst_loc(i).df_total_size := dfst_remote(i).df_total_size ; ' ||
                        '  dfst_loc(i).df_usable_size := dfst_remote(i).df_usable_size ; ' ||
                        '  dfst_loc(i).df_next_size := dfst_remote(i).df_next_size ; ' ||
                        '  dfst_loc(i).df_max_size := dfst_remote(i).df_max_size ; ' ||
                        '  dfst_loc(i).df_allocation := dfst_remote(i).df_allocation ; ' ||
                        '  dfst_loc(i).df_free_space := dfst_remote(i).df_free_space ; ' ||
                        '  dfst_loc(i).ts_tablespace_id := dfst_remote(i).ts_tablespace_id ; ' ||
                        '  dfst_loc(i).df_file_id := dfst_remote(i).df_file_id ; ' ||
                        '  dfst_loc(i).df_relative_fno := dfst_remote(i).df_relative_fno ; ' ||
                        '  dfst_loc(i).df_highest_block := dfst_remote(i).df_highest_block ; ' ||
                        '  dfst_loc(i).df_data_alloc := dfst_remote(i).df_data_alloc ; ' ||
                        '  dfst_loc(i).df_index_alloc := dfst_remote(i).df_index_alloc ; ' ||
                        '  dfst_loc(i).df_rollback_alloc := dfst_remote(i).df_rollback_alloc ; ' ||
                        '  dfst_loc(i).df_temp_alloc := dfst_remote(i).df_temp_alloc ; ' ||
                        '  dfst_loc(i).df_other_alloc := dfst_remote(i).df_other_alloc ; ' ||
                        '  dfst_loc(i).ts_initial_extent := dfst_remote(i).ts_initial_extent ; ' ||
                        '  dfst_loc(i).ts_blocksize := dfst_remote(i).ts_blocksize ; ' ||
                        '  dfst_loc(i).ts_min_extlen := dfst_remote(i).ts_min_extlen ; ' ||
                        '  dfst_loc(i).ts_extent_management := dfst_remote(i).ts_extent_management ; ' ||
                        '  dfst_loc(i).ts_allocation_type := dfst_remote(i).ts_allocation_type ; ' ||
                        '  dfst_loc(i).ts_segment_space_management := dfst_remote(i).ts_segment_space_management ; ' ||
                        '  dfst_loc(i).ts_bigfile := dfst_remote(i).ts_bigfile ; ' ||
                        '  dfst_loc(i).ts_contents := dfst_remote(i).ts_contents ; ' ||
                        '  dfst_loc(i).ts_status := dfst_remote(i).ts_status ; ' ||
                        '  dfst_loc(i).snapshot_date := dfst_remote(i).snapshot_date ; ' ||
                        ' end loop ; ' ||
                        ' quest_cmo_aggregator.store_datafile_stat (:db_id, :job_history_id, dbi_loc, dfst_loc) ; ' ||
                        'end ;'
        USING db_id_in, job_history_id_in;
    END IF;
    COMMIT;
  END datafile_aggregator;

  PROCEDURE datafile_aggregator_initial(db_id_in IN quest_cmo_databases.database_id%TYPE) IS
    db_link quest_cmo_databases.database_link%TYPE;
    dfst    quest_cmo_collector.datafile_stats_tab;
  BEGIN
    db_link := get_database_link(db_id_in);
    IF db_link IS NULL
    THEN
      quest_cmo_collector.get_init_repository_stats(dfst);
      store_datafile_history(db_id_in, dfst);
    ELSE
      EXECUTE IMMEDIATE 'declare dfst_loc quest_cmo_collector.datafile_stats_tab ; ' ||
                        ' dfst_remote quest_cmo_collector.datafile_stats_tab@"' || db_link || '" ; ' ||
                        'begin  ' || ' quest_cmo_collector.get_init_repository_stats@"' || db_link ||
                        '" (dfst_remote) ; ' || ' for i in 1..dfst_remote.count loop ' ||
                        '  dfst_loc(i).df_datafile_name := dfst_remote(i).df_datafile_name ; ' ||
                        '  dfst_loc(i).ts_tablespace_name := dfst_remote(i).ts_tablespace_name ; ' ||
                        '  dfst_loc(i).df_autoextensible := dfst_remote(i).df_autoextensible ; ' ||
                        '  dfst_loc(i).df_total_size := dfst_remote(i).df_total_size ; ' ||
                        '  dfst_loc(i).df_usable_size := dfst_remote(i).df_usable_size ; ' ||
                        '  dfst_loc(i).df_next_size := dfst_remote(i).df_next_size ; ' ||
                        '  dfst_loc(i).df_max_size := dfst_remote(i).df_max_size ; ' ||
                        '  dfst_loc(i).df_allocation := dfst_remote(i).df_allocation ; ' ||
                        '  dfst_loc(i).df_free_space := dfst_remote(i).df_free_space ; ' ||
                        '  dfst_loc(i).ts_tablespace_id := dfst_remote(i).ts_tablespace_id ; ' ||
                        '  dfst_loc(i).df_file_id := dfst_remote(i).df_file_id ; ' ||
                        '  dfst_loc(i).df_relative_fno := dfst_remote(i).df_relative_fno ; ' ||
                        '  dfst_loc(i).df_highest_block := dfst_remote(i).df_highest_block ; ' ||
                        '  dfst_loc(i).df_data_alloc := dfst_remote(i).df_data_alloc ; ' ||
                        '  dfst_loc(i).df_index_alloc := dfst_remote(i).df_index_alloc ; ' ||
                        '  dfst_loc(i).df_rollback_alloc := dfst_remote(i).df_rollback_alloc ; ' ||
                        '  dfst_loc(i).df_temp_alloc := dfst_remote(i).df_temp_alloc ; ' ||
                        '  dfst_loc(i).df_other_alloc := dfst_remote(i).df_other_alloc ; ' ||
                        '  dfst_loc(i).ts_initial_extent := dfst_remote(i).ts_initial_extent ; ' ||
                        '  dfst_loc(i).ts_blocksize := dfst_remote(i).ts_blocksize ; ' ||
                        '  dfst_loc(i).ts_min_extlen := dfst_remote(i).ts_min_extlen ; ' ||
                        '  dfst_loc(i).ts_extent_management := dfst_remote(i).ts_extent_management ; ' ||
                        '  dfst_loc(i).ts_allocation_type := dfst_remote(i).ts_allocation_type ; ' ||
                        '  dfst_loc(i).ts_segment_space_management := dfst_remote(i).ts_segment_space_management ; ' ||
                        '  dfst_loc(i).ts_bigfile := dfst_remote(i).ts_bigfile ; ' ||
                        '  dfst_loc(i).ts_contents := dfst_remote(i).ts_contents ; ' ||
                        '  dfst_loc(i).ts_status := dfst_remote(i).ts_status ; ' ||
                        '  dfst_loc(i).snapshot_date := dfst_remote(i).snapshot_date ; ' ||
                        ' end loop ; ' ||
                        ' quest_cmo_aggregator.store_datafile_history (:db_id, dfst_loc) ; ' ||
                        'end ;'
        USING db_id_in;
    END IF;
    COMMIT;
  END datafile_aggregator_initial;

END quest_cmo_aggregator;
/

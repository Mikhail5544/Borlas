CREATE OR REPLACE PACKAGE quest_cmo_current AS
  package_version CONSTANT VARCHAR2(20) := '1.0.0';

  TYPE currt_ref_cur IS REF CURSOR;

  FUNCTION check_connection(database_id_in IN NUMBER) RETURN NUMBER;

  FUNCTION get_tablespaces
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_datafiles
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_largest_tablespaces
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
   ,num_requested  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_largest_datafiles
  (
    currt_rc        IN OUT currt_ref_cur
   ,database_id_in  IN NUMBER
   ,tablespace_name IN VARCHAR2
   ,num_requested   IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION get_instances
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER;

  currt_obj_list  quest_cmo_currt_obj_list_tab;
  currt_obj       quest_cmo_currt_obj_tab;
  currt_inst_list quest_cmo_currt_inst_list_tab;
END quest_cmo_current;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_current AS
  PROCEDURE get_database_link
  (
    database_id_in    IN NUMBER
   ,database_link_out OUT VARCHAR2
  ) IS
  BEGIN
    SELECT database_link
      INTO database_link_out
      FROM quest_cmo_databases
     WHERE database_id = database_id_in;
  END get_database_link;

  FUNCTION check_connection(database_id_in IN NUMBER) RETURN NUMBER IS
    rc      NUMBER;
    db_link quest_cmo_databases.database_link%TYPE;
  BEGIN
    SELECT database_link INTO db_link FROM quest_cmo_databases WHERE database_id = database_id_in;
    IF db_link IS NOT NULL
    THEN
      db_link := '@"' || db_link || '"';
    END IF;
    BEGIN
      EXECUTE IMMEDIATE 'select count (*) from dual' || db_link
        INTO rc;
    EXCEPTION
      WHEN OTHERS THEN
        rc := 0;
    END;
    RETURN rc;
  END check_connection;

  FUNCTION get_tablespaces
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER IS
    db_link quest_cmo_databases.database_link%TYPE;
    alltbsp quest_cmo_collector.currt_object_list_tab;
  BEGIN
    get_database_link(database_id_in, db_link);
    IF db_link IS NULL
    THEN
      currt_obj_list := quest_cmo_currt_obj_list_tab();
      quest_cmo_collector.get_tablespaces_currt(alltbsp);
      FOR i IN 1 .. alltbsp.count
      LOOP
        currt_obj_list.extend;
        currt_obj_list(currt_obj_list.count) := quest_cmo_currt_obj_list_typ(alltbsp(i));
      END LOOP;
    ELSE
      EXECUTE IMMEDIATE 'declare alltbsp_remote quest_cmo_collector.currt_object_list_tab@"' ||
                        db_link || '" ; ' || 'begin quest_cmo_current.currt_obj_list := ' ||
                        '   quest_cmo_currt_obj_list_tab () ; ' ||
                        ' quest_cmo_collector.get_tablespaces_currt@"' || db_link ||
                        '" (alltbsp_remote) ; ' || ' for i in 1..alltbsp_remote.count loop ' ||
                        ' quest_cmo_current.currt_obj_list.extend ; ' ||
                        ' quest_cmo_current.currt_obj_list ' ||
                        '  (quest_cmo_current.currt_obj_list.count) := ' ||
                        '  quest_cmo_currt_obj_list_typ (alltbsp_remote(i)) ; ' || ' end loop ; ' ||
                        'end ;';
    END IF;
    OPEN currt_rc FOR
      SELECT d.capacity_object_id
            ,a.object_name AS tablespace_name
        FROM TABLE(CAST(currt_obj_list AS quest_cmo_currt_obj_list_tab)) a
            ,(SELECT b.capacity_object_id
                    ,b.object_name
                FROM quest_cmo_capacity_object b
                    ,quest_cmo_object_type     c
               WHERE b.database_id = database_id_in
                 AND b.object_type_code = c.object_type_code
                 AND c.object_type = 'TABLESPACE') d
       WHERE a.object_name = d.object_name(+)
       ORDER BY a.object_name;
    RETURN currt_obj_list.count;
  END get_tablespaces;

  FUNCTION get_datafiles
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER IS
    db_link quest_cmo_databases.database_link%TYPE;
    alldf   quest_cmo_collector.currt_object_tab;
  BEGIN
    get_database_link(database_id_in, db_link);
    IF db_link IS NULL
    THEN
      currt_obj := quest_cmo_currt_obj_tab();
      quest_cmo_collector.get_datafiles_currt(alldf);
      FOR i IN 1 .. alldf.count
      LOOP
        currt_obj.extend;
        currt_obj(currt_obj.count) := quest_cmo_currt_obj_typ(alldf(i).long_name
                                                             ,alldf(i).short_name
                                                             ,NULL
                                                             ,alldf(i).total_size
                                                             ,alldf(i).free_space);
      END LOOP;
    ELSE
      EXECUTE IMMEDIATE 'declare alldf_remote quest_cmo_collector.currt_object_tab@"' || db_link ||
                        '" ; ' || 'begin quest_cmo_current.currt_obj := quest_cmo_currt_obj_tab () ; ' ||
                        ' quest_cmo_collector.get_datafiles_currt@"' || db_link ||
                        '" (alldf_remote) ; ' || ' for i in 1..alldf_remote.count loop ' ||
                        ' quest_cmo_current.currt_obj.extend ; ' ||
                        ' quest_cmo_current.currt_obj (quest_cmo_current.currt_obj.count) := ' ||
                        '  quest_cmo_currt_obj_typ (alldf_remote(i).long_name, ' ||
                        '  alldf_remote(i).short_name, null, ' || '  alldf_remote(i).total_size, ' ||
                        '  alldf_remote(i).free_space) ; ' || ' end loop ; ' || 'end ;';
    END IF;
    OPEN currt_rc FOR
      SELECT d.capacity_object_id AS tbsp_object_id
            ,a.short_name AS tablespace_name
            ,g.capacity_object_id AS file_object_id
            ,a.long_name AS file_name
            ,quest_cmo_general_purpose.extract_file_name(a.long_name) AS short_file_name
            ,g.container AS file_container
            ,a.total_size
            ,a.free_space
        FROM TABLE(CAST(currt_obj AS quest_cmo_currt_obj_tab)) a
            ,(SELECT b.capacity_object_id
                    ,b.object_name
                FROM quest_cmo_capacity_object b
                    ,quest_cmo_object_type     c
               WHERE b.database_id = database_id_in
                 AND b.object_type_code = c.object_type_code
                 AND c.object_type = 'TABLESPACE') d
            ,(SELECT e.capacity_object_id
                    ,e.object_name
                    ,e.container
                FROM quest_cmo_capacity_object e
                    ,quest_cmo_object_type     f
               WHERE e.database_id = database_id_in
                 AND e.object_type_code = f.object_type_code
                 AND f.object_type IN ('DATAFILE', 'TEMPFILE')) g
       WHERE a.short_name = d.object_name(+)
         AND a.long_name = g.object_name(+)
       ORDER BY a.short_name
               ,a.long_name;
    RETURN currt_obj.count;
  END get_datafiles;

  FUNCTION get_largest_tablespaces
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
   ,num_requested  IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    db_link      quest_cmo_databases.database_link%TYPE;
    largest_tbsp quest_cmo_collector.currt_object_tab;
  BEGIN
    get_database_link(database_id_in, db_link);
    IF db_link IS NULL
    THEN
      currt_obj := quest_cmo_currt_obj_tab();
      quest_cmo_collector.get_largest_tbsp_currt(largest_tbsp, num_requested);
      FOR i IN 1 .. largest_tbsp.count
      LOOP
        currt_obj.extend;
        currt_obj(currt_obj.count) := quest_cmo_currt_obj_typ(NULL
                                                             ,largest_tbsp(i).short_name
                                                             ,NULL
                                                             ,largest_tbsp(i).total_size
                                                             ,largest_tbsp(i).free_space);
      END LOOP;
    ELSE
      EXECUTE IMMEDIATE 'declare largest_tbsp_remote quest_cmo_collector.currt_object_tab@"' ||
                        db_link || '" ; ' ||
                        'begin quest_cmo_current.currt_obj := quest_cmo_currt_obj_tab () ; ' ||
                        ' quest_cmo_collector.get_largest_tbsp_currt@"' || db_link ||
                        '" (largest_tbsp_remote, :num_requested_in) ; ' ||
                        ' for i in 1..largest_tbsp_remote.count loop ' ||
                        ' quest_cmo_current.currt_obj.extend ; ' ||
                        ' quest_cmo_current.currt_obj (quest_cmo_current.currt_obj.count) := ' ||
                        '  quest_cmo_currt_obj_typ (null, largest_tbsp_remote(i).short_name, ' ||
                        '  null, largest_tbsp_remote(i).total_size, ' ||
                        '  largest_tbsp_remote(i).free_space) ; ' || ' end loop ; ' || 'end ;'
        USING num_requested;
    END IF;
    OPEN currt_rc FOR
      SELECT d.capacity_object_id
            ,a.short_name AS tablespace_name
            ,a.total_size
            ,a.free_space
        FROM TABLE(CAST(currt_obj AS quest_cmo_currt_obj_tab)) a
            ,(SELECT b.capacity_object_id
                    ,b.object_name
                FROM quest_cmo_capacity_object b
                    ,quest_cmo_object_type     c
               WHERE b.database_id = database_id_in
                 AND b.object_type_code = c.object_type_code
                 AND c.object_type = 'TABLESPACE') d
       WHERE a.short_name = d.object_name(+)
       ORDER BY a.total_size DESC
               ,a.free_space ASC
               ,a.short_name;
    RETURN currt_obj.count;
  END get_largest_tablespaces;

  FUNCTION get_largest_datafiles
  (
    currt_rc        IN OUT currt_ref_cur
   ,database_id_in  IN NUMBER
   ,tablespace_name IN VARCHAR2
   ,num_requested   IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    db_link    quest_cmo_databases.database_link%TYPE;
    largest_df quest_cmo_collector.currt_object_tab;
  BEGIN
    get_database_link(database_id_in, db_link);
    IF db_link IS NULL
    THEN
      currt_obj := quest_cmo_currt_obj_tab();
      quest_cmo_collector.get_largest_df_currt(tablespace_name, largest_df, num_requested);
      FOR i IN 1 .. largest_df.count
      LOOP
        currt_obj.extend;
        currt_obj(currt_obj.count) := quest_cmo_currt_obj_typ(largest_df(i).long_name
                                                             ,NULL
                                                             ,NULL
                                                             ,largest_df(i).total_size
                                                             ,largest_df(i).free_space);
      END LOOP;
    ELSE
      EXECUTE IMMEDIATE 'declare largest_df_remote quest_cmo_collector.currt_object_tab@"' || db_link ||
                        '" ; ' || 'begin quest_cmo_current.currt_obj := quest_cmo_currt_obj_tab () ; ' ||
                        ' quest_cmo_collector.get_largest_df_currt@"' || db_link ||
                        '" (:tablespace_name, largest_df_remote, :num_requested_in) ; ' ||
                        ' for i in 1..largest_df_remote.count loop ' ||
                        ' quest_cmo_current.currt_obj.extend ; ' ||
                        ' quest_cmo_current.currt_obj (quest_cmo_current.currt_obj.count) := ' ||
                        '  quest_cmo_currt_obj_typ (largest_df_remote(i).long_name, ' ||
                        '  null, null, largest_df_remote(i).total_size, ' ||
                        '  largest_df_remote(i).free_space) ; ' || ' end loop ; ' || 'end ;'
        USING tablespace_name, num_requested;
    END IF;
    OPEN currt_rc FOR
      SELECT d.capacity_object_id
            ,a.long_name AS file_name
            ,quest_cmo_general_purpose.extract_file_name(a.long_name) AS short_file_name
            ,d.container
            ,a.total_size
            ,a.free_space
        FROM TABLE(CAST(currt_obj AS quest_cmo_currt_obj_tab)) a
            ,(SELECT b.capacity_object_id
                    ,b.object_name
                    ,b.container
                FROM quest_cmo_capacity_object b
                    ,quest_cmo_object_type     c
               WHERE b.database_id = database_id_in
                 AND b.object_type_code = c.object_type_code
                 AND c.object_type IN ('DATAFILE', 'TEMPFILE')) d
       WHERE a.long_name = d.object_name(+)
       ORDER BY a.total_size DESC
               ,a.free_space ASC
               ,a.long_name;
    RETURN currt_obj.count;
  END get_largest_datafiles;

  FUNCTION get_instances
  (
    currt_rc       IN OUT currt_ref_cur
   ,database_id_in IN NUMBER
  ) RETURN NUMBER IS
    db_link quest_cmo_databases.database_link%TYPE;
    allinst quest_cmo_collector.currt_inst_list_tab;
  BEGIN
    get_database_link(database_id_in, db_link);
    IF db_link IS NULL
    THEN
      currt_inst_list := quest_cmo_currt_inst_list_tab();
      quest_cmo_collector.get_instances_currt(allinst);
      FOR i IN 1 .. allinst.count
      LOOP
        currt_inst_list.extend;
        currt_inst_list(currt_inst_list.count) := quest_cmo_currt_inst_list_typ(allinst(i)
                                                                                .instance_number
                                                                               ,allinst(i)
                                                                                .instance_name
                                                                               ,allinst(i).host_name
                                                                               ,allinst(i).status);
      END LOOP;
    ELSE
      EXECUTE IMMEDIATE 'declare allinst_remote quest_cmo_collector.currt_inst_list_tab@"' || db_link ||
                        '" ; ' || 'begin quest_cmo_current.currt_inst_list := ' ||
                        '   quest_cmo_currt_inst_list_tab () ; ' ||
                        ' quest_cmo_collector.get_instances_currt@"' || db_link ||
                        '" (allinst_remote) ; ' || ' for i in 1..allinst_remote.count loop ' ||
                        ' quest_cmo_current.currt_inst_list.extend ; ' ||
                        ' quest_cmo_current.currt_inst_list ' ||
                        '  (quest_cmo_current.currt_inst_list.count) := ' ||
                        '  quest_cmo_currt_inst_list_typ (allinst_remote(i).instance_number, ' ||
                        '     allinst_remote(i).instance_name, allinst_remote(i).host_name, ' ||
                        '     allinst_remote(i).status) ; ' || ' end loop ; ' || 'end ;';
    END IF;
    OPEN currt_rc FOR
      SELECT a.instance_number
            ,a.instance_name
            ,a.host_name
            ,a.status
        FROM TABLE(CAST(currt_inst_list AS quest_cmo_currt_inst_list_tab)) a
       ORDER BY a.instance_number;
    RETURN currt_inst_list.count;
  END get_instances;
END quest_cmo_current;
/

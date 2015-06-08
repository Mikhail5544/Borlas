CREATE OR REPLACE PACKAGE quest_cmo_collector AS
  package_version CONSTANT VARCHAR2(20) := '1.0.0';
  FUNCTION get_package_version RETURN VARCHAR2;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --  types for aggregator calls
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TYPE db_info IS RECORD(
     database_name VARCHAR2(50)
    ,server_name   VARCHAR2(50)
    ,dbms_version  VARCHAR2(100));

  TYPE datafile_stats IS RECORD(
     df_datafile_name            VARCHAR2(520)
    ,ts_tablespace_name          VARCHAR2(35)
    ,df_autoextensible           VARCHAR2(3)
    ,df_total_size               NUMBER
    ,df_usable_size              NUMBER
    ,df_next_size                NUMBER
    ,df_max_size                 NUMBER
    ,df_allocation               NUMBER
    ,df_free_space               NUMBER
    ,ts_tablespace_id            NUMBER
    ,df_file_id                  NUMBER
    ,df_relative_fno             NUMBER
    ,df_highest_block            NUMBER
    ,df_data_alloc               NUMBER
    ,df_index_alloc              NUMBER
    ,df_rollback_alloc           NUMBER
    ,df_temp_alloc               NUMBER
    ,df_other_alloc              NUMBER
    ,ts_initial_extent           NUMBER
    ,ts_blocksize                NUMBER
    ,ts_min_extlen               NUMBER
    ,ts_extent_management        VARCHAR2(10)
    ,ts_allocation_type          VARCHAR2(10)
    ,ts_segment_space_management VARCHAR2(10)
    ,ts_bigfile                  VARCHAR2(3)
    ,ts_contents                 VARCHAR2(10)
    ,ts_status                   VARCHAR2(9)
    ,snapshot_date               DATE);
  TYPE datafile_stats_tab IS TABLE OF datafile_stats INDEX BY BINARY_INTEGER;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --  procedures used by aggregator
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PROCEDURE get_db_info(dbr OUT db_info);

  PROCEDURE get_init_repository_stats(datafile_stats_array OUT datafile_stats_tab);

  PROCEDURE get_datafile_stats
  (
    datafile_stats_array OUT datafile_stats_tab
   ,ts_name              VARCHAR2 DEFAULT NULL
   ,datafile_name        VARCHAR2 DEFAULT NULL
  );

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --  types for current query calls
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TYPE currt_object_list_tab IS TABLE OF VARCHAR2(520) INDEX BY BINARY_INTEGER;

  TYPE currt_object IS RECORD(
     long_name   VARCHAR2(520)
    ,short_name  VARCHAR2(30)
    ,object_type VARCHAR2(20)
    ,total_size  NUMBER
    ,free_space  NUMBER);
  TYPE currt_object_tab IS TABLE OF currt_object INDEX BY BINARY_INTEGER;

  TYPE currt_inst_list IS RECORD(
     instance_number NUMBER
    ,instance_name   VARCHAR2(16)
    ,host_name       VARCHAR2(64)
    ,status          VARCHAR2(12));
  TYPE currt_inst_list_tab IS TABLE OF currt_inst_list INDEX BY BINARY_INTEGER;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --  procedures used by current queries
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PROCEDURE get_tablespaces_currt(alltbsp OUT currt_object_list_tab);

  PROCEDURE get_datafiles_currt(alldf OUT currt_object_tab);

  PROCEDURE get_largest_tbsp_currt
  (
    bigtbsp       OUT currt_object_tab
   ,num_requested IN NUMBER DEFAULT NULL
  );

  PROCEDURE get_largest_df_currt
  (
    tablespace_name_in IN VARCHAR2
   ,bigdf              OUT currt_object_tab
   ,num_requested      IN NUMBER DEFAULT NULL
  );

  PROCEDURE get_instances_currt(allinst OUT currt_inst_list_tab);
END quest_cmo_collector;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_collector AS
  TYPE df_distribution IS RECORD(
     server_name   VARCHAR2(30)
    ,database_name VARCHAR2(30)
    ,filename      VARCHAR2(100)
    ,temporary     NUMBER
    ,data          NUMBER
    ,indx          NUMBER
    ,hwm           NUMBER
    ,ROLLBACK      NUMBER
    ,other         NUMBER);
  TYPE df_distribution_tab IS TABLE OF df_distribution INDEX BY BINARY_INTEGER;

  TYPE rc IS REF CURSOR;

  TYPE version_tabtype IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;

  FUNCTION get_package_version RETURN VARCHAR2 IS
  BEGIN
    RETURN package_version;
  END get_package_version;

  FUNCTION conv_version(version IN VARCHAR2) RETURN version_tabtype IS
    version_to_convert VARCHAR2(64) := version;
    version#           version_tabtype;
    pos1               PLS_INTEGER;
    pos2               PLS_INTEGER;
    idx                PLS_INTEGER;
  BEGIN
    pos1 := length(version);
    pos2 := 0;
    FOR i IN 1 .. pos1
    LOOP
      IF translate(substr(version, i, 1), '~0123456789.', rpad('x', 12, '~')) = '~'
      THEN
        pos2 := pos2 + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    version_to_convert := substr(version, 1, pos2);
    pos1               := 1;
    idx                := 1;
    WHILE pos1 > 0
    LOOP
      version#(idx) := NULL;
      pos2 := instr(version_to_convert, '.', pos1);
      IF pos2 > 0
      THEN
        version#(idx) := to_number(substr(version_to_convert, pos1, pos2 - pos1));
        pos1 := pos2 + 1;
      ELSE
        version#(idx) := to_number(substr(version_to_convert, pos1));
        pos1 := 0;
      END IF;
      idx := idx + 1;
    END LOOP;
    RETURN version#;
  END conv_version;

  PROCEDURE df_alloc_distribution
  (
    ts_name       IN VARCHAR2 DEFAULT NULL
   ,datafile_name IN VARCHAR2 DEFAULT NULL
   ,df_alloc_dist OUT df_distribution_tab
  ) IS
    TYPE array_of_string IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
    fn   array_of_string;
    i    INTEGER := 0;
    f_id INTEGER;
    str  VARCHAR2(1000);
    TYPE rc IS REF CURSOR;
    cref rc;
    CURSOR c_ext IS
      SELECT e.block_id AS block#
            ,e.blocks
            ,e.bytes
            ,e.file_id
            ,e.tablespace_name
            ,e.segment_type
        FROM dba_extents     e
            ,dba_tablespaces ts
       WHERE e.tablespace_name = ts.tablespace_name;
  
    c c_ext%ROWTYPE;
  BEGIN
    IF datafile_name IS NULL
    THEN
      --create lookup table for file name
      FOR c1 IN (SELECT NAME
                       ,file#
                   FROM v$dbfile)
      LOOP
        fn(c1.file#) := c1.name;
      END LOOP;
    ELSE
      --find file_is for taht file
      SELECT file# INTO f_id FROM v$dbfile WHERE NAME = datafile_name;
    END IF;
    str := 'select  e.block_id as block#, e.blocks, e.bytes, e.file_id, e.tablespace_name,e.segment_type' ||
           ' from    dba_extents e, dba_tablespaces ts' ||
           ' where  e.tablespace_name = ts.tablespace_name ';
    IF ts_name IS NOT NULL
    THEN
      str := ' and ts.tablespace_name = ' || ts_name;
    END IF;
  
    IF f_id IS NOT NULL
    THEN
      str := ' and e.file_id = ' || f_id;
    END IF;
    str := str || '   order by  e.tablespace_name, e.file_id';
    OPEN cref FOR str;
    LOOP
      FETCH cref
        INTO c;
      EXIT WHEN cref%NOTFOUND;
      i := c.file_id;
      IF NOT df_alloc_dist.exists(i)
      THEN
        df_alloc_dist(i).data := 0;
        df_alloc_dist(i).hwm := 0;
        df_alloc_dist(i).indx := 0;
        df_alloc_dist(i).temporary := 0;
        df_alloc_dist(i).rollback := 0;
        df_alloc_dist(i).other := 0;
      END IF;
    
      IF c.block# + c.blocks > nvl(df_alloc_dist(i).hwm, 0)
      THEN
        df_alloc_dist(i).hwm := c.block# + c.blocks;
      END IF;
      IF c.segment_type IN ('TABLE'
                           ,'NESTED TABLE'
                           ,'TABLE PARTITION'
                           ,'TABLE SUBPARTITION'
                           ,'LOBSEGMENT'
                           ,'LOB PARTITION'
                           ,'LOB SUBPARTITION'
                           ,'CLUSTER')
      THEN
        df_alloc_dist(i).data := df_alloc_dist(i).data + c.bytes;
      ELSIF c.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'LOBINDEX')
      THEN
        df_alloc_dist(i).indx := df_alloc_dist(i).indx + c.bytes;
      ELSIF c.segment_type IN ('ROLLBACK', 'TYPE2 UNDO')
      THEN
        df_alloc_dist(i).rollback := df_alloc_dist(i).rollback + c.bytes;
      ELSIF c.segment_type IN ('TEMPORARY', 'CACHE')
      THEN
        df_alloc_dist(i).temporary := df_alloc_dist(i).temporary + c.bytes;
      ELSE
        df_alloc_dist(i).other := df_alloc_dist(i).other + c.bytes;
      END IF;
    END LOOP;
    CLOSE cref;
  END df_alloc_distribution;

  PROCEDURE get_db_info(dbr OUT db_info) IS
    dbms_compatibility VARCHAR2(100);
  BEGIN
    dbms_utility.db_version(dbr.dbms_version, dbms_compatibility);
    SELECT a.name
          ,b.host_name
      INTO dbr.database_name
          ,dbr.server_name
      FROM v$database  a
          ,gv$instance b
     WHERE b.inst_id = userenv('instance');
  END get_db_info;

  PROCEDURE populate_datafile_tab
  (
    lcur rc
   ,dfad IN df_distribution_tab
   ,dfsa IN OUT datafile_stats_tab
  ) IS
    i    PLS_INTEGER;
    dfid NUMBER;
  BEGIN
    i := nvl(dfsa.last, 0);
    LOOP
      i := i + 1;
      FETCH lcur
        INTO dfsa(i).df_total_size
            ,dfsa(i).df_usable_size
            ,dfsa(i).snapshot_date
            ,dfsa(i).ts_status
            ,dfsa(i).df_autoextensible
            ,dfsa(i).df_datafile_name
            ,dfsa(i).ts_tablespace_name
            ,dfsa(i).df_file_id
            ,dfsa(i).df_relative_fno
            ,dfsa(i).ts_contents
            ,dfsa(i).df_free_space
            ,dfsa(i).df_allocation
            ,dfsa(i).df_next_size
            ,dfsa(i).df_max_size
            ,dfsa(i).ts_initial_extent
            ,dfsa(i).ts_min_extlen
            ,dfsa(i).ts_extent_management
            ,dfsa(i).ts_allocation_type
            ,dfsa(i).ts_blocksize
            ,dfsa(i).ts_segment_space_management
            ,dfsa(i).ts_bigfile;
      IF lcur%NOTFOUND
      THEN
        dfsa.delete(i);
        EXIT;
      END IF;
    
      IF dfsa(i).df_autoextensible = 'NO'
      THEN
        dfsa(i).df_max_size := dfsa(i).df_allocation;
      END IF;
    
      dfid := dfsa(i).df_file_id;
      IF dfsa(i).ts_contents = 'PERMANENT'
      THEN
        IF dfad.exists(dfid)
        THEN
          dfsa(i).df_highest_block := dfad(dfid).hwm;
          dfsa(i).df_data_alloc := dfad(dfid).data;
          dfsa(i).df_index_alloc := dfad(dfid).indx;
          dfsa(i).df_rollback_alloc := dfad(dfid).rollback;
          dfsa(i).df_temp_alloc := dfad(dfid).temporary;
          dfsa(i).df_other_alloc := dfad(dfid).other;
        ELSE
          dfsa(i).df_highest_block := 0;
          dfsa(i).df_data_alloc := 0;
          dfsa(i).df_index_alloc := 0;
          dfsa(i).df_rollback_alloc := 0;
          dfsa(i).df_temp_alloc := 0;
          dfsa(i).df_other_alloc := 0;
        END IF;
        dfsa(i).df_other_alloc := dfsa(i)
                                  .df_other_alloc +
                                   (dfsa(i)
                                    .df_total_size - nvl(dfsa(i).df_usable_size, dfsa(i).df_total_size)) * 1024 * 1024;
      ELSE
        IF dfsa(i).ts_contents = 'TEMPORARY'
        THEN
          dfsa(i).df_rollback_alloc := 0;
          dfsa(i).df_highest_block := NULL;
          dfsa(i).df_temp_alloc := dfsa(i).df_total_size * (1024 * 1024);
        ELSIF dfsa(i).ts_contents LIKE '%UNDO%'
        THEN
          dfsa(i).df_rollback_alloc := dfsa(i).df_total_size * (1024 * 1024);
          dfsa(i).df_highest_block := NULL;
          dfsa(i).df_temp_alloc := 0;
        END IF;
        dfsa(i).df_allocation := dfsa(i).df_total_size;
        dfsa(i).df_free_space := 0;
        dfsa(i).df_index_alloc := 0;
        dfsa(i).df_data_alloc := 0;
        dfsa(i).df_other_alloc := 0;
      END IF;
    END LOOP;
  END populate_datafile_tab;

  PROCEDURE build_df_sql
  (
    tablespace_name_in    VARCHAR2
   ,datafile_name_in      VARCHAR2
   ,variable_col_list_out OUT VARCHAR2
   ,where_clause_out      OUT VARCHAR2
  ) IS
    dbms_version       VARCHAR2(64);
    dbms_version#      version_tabtype;
    dbms_compatibility VARCHAR2(100);
  
    parameter_value     VARCHAR2(512);
    parameter_type      PLS_INTEGER;
    parameter_value_int PLS_INTEGER;
  BEGIN
    -- extra columns in dba_tablespaces for some Oracle versions
    dbms_utility.db_version(dbms_version, dbms_compatibility);
    dbms_version# := conv_version(dbms_version);
    IF dbms_version#(1) >= 9
    THEN
      variable_col_list_out := variable_col_list_out || ', ts.block_size as ts_blocksize, ' ||
                               'ts.segment_space_management as ts_segment_space_management';
    ELSE
      parameter_type        := dbms_utility.get_parameter_value('db_block_size'
                                                               ,parameter_value_int
                                                               ,parameter_value);
      variable_col_list_out := variable_col_list_out || ', ' || to_char(parameter_value_int) ||
                               ' as ts_blocksize, ' || '''MANUAL'' as ts_segment_space_management ';
    END IF;
    IF dbms_version#(1) >= 10
    THEN
      variable_col_list_out := variable_col_list_out || ', ts.bigfile as ts_bigfile ';
    ELSE
      variable_col_list_out := variable_col_list_out || ', ''NO'' as ts_bigfile ';
    END IF;
  
    -- where clause for datafile query
    IF tablespace_name_in IS NOT NULL
    THEN
      where_clause_out := where_clause_out || ' and ts.tablespace_name = ''' || tablespace_name_in || '''';
    END IF;
    IF datafile_name_in IS NOT NULL
    THEN
      where_clause_out := where_clause_out || ' and df.file_name = ''' || datafile_name_in || '''';
    END IF;
  END build_df_sql;

  PROCEDURE get_init_repository_stats(datafile_stats_array OUT datafile_stats_tab) IS
    lcur              rc;
    extra_select_cols VARCHAR2(200);
    where_clause      VARCHAR2(200);
    querystr          VARCHAR2(4000);
    df_alloc_dist     df_distribution_tab;
  BEGIN
    -- determine columns present by version, and where clause based on input
    build_df_sql(NULL, NULL, extra_select_cols, where_clause);
  
    -- historical data: datafiles and tempfiles
    -- this query needs to be a union to have all file information returned
    --  in the correct order (tempfiles and datafiles ordered by creation date
    --   and tablespace_name)
    querystr := 'select vdf.bytes / (1024 * 1024) as df_total_size, ' ||
                '  to_number (null) as df_usable_size, ' ||
                '  vdf.creation_time as snapshot_date, null as ts_status, ' ||
                '  df.autoextensible as df_autoextensible, ' || '  df.file_name as df_datafile_name, ' ||
                '  df.tablespace_name as ts_tablespace_name, df.file_id as df_file_id, ' ||
                '  df.relative_fno as df_relative_fno, ts.contents as ts_contents, ' ||
                '  to_number (null) as df_free_space, ' || '  to_number (null) as df_allocation, ' ||
                '  (df.bytes / df.blocks) * increment_by / (1024 * 1024) ' ||
                '    as df_next_size, df.maxbytes / (1024 * 1024) as df_max_size, ' ||
                '  ts.initial_extent as ts_initial_extent, ts.min_extlen as ts_min_extlen, ' ||
                '  ts.extent_management as ts_extent_management, ' ||
                '  ts.allocation_type as ts_allocation_type ' || extra_select_cols ||
                ' from v$datafile vdf, dba_data_files df, dba_tablespaces ts ' ||
                ' where vdf.file# = df.file_id ' || '   and df.tablespace_name = ts.tablespace_name ' ||
                where_clause || 'union all select vtf.bytes / (1024 * 1024) as df_total_size, ' ||
                '  to_number (null) as df_usable_size, ' ||
                '  vtf.creation_time as snapshot_date, null as ts_status, ' ||
                '  df.autoextensible as df_autoextensible, ' || '  df.file_name as df_datafile_name, ' ||
                '  df.tablespace_name as ts_tablespace_name, df.file_id as df_file_id, ' ||
                '  df.relative_fno as df_relative_fno, ts.contents as ts_contents, ' ||
                '  0 as df_free_space, ' || '  to_number (null) as df_allocation, ' ||
                '  (df.bytes / df.blocks) * increment_by / (1024 * 1024) ' ||
                '    as df_next_size, df.maxbytes / (1024 * 1024) as df_max_size, ' ||
                '  ts.initial_extent as ts_initial_extent, ts.min_extlen as ts_min_extlen, ' ||
                '  ts.extent_management as ts_extent_management, ' ||
                '  ts.allocation_type as ts_allocation_type ' || extra_select_cols ||
                ' from v$tempfile vtf, dba_temp_files df, dba_tablespaces ts ' ||
                ' where vtf.file# = df.file_id ' || '   and df.tablespace_name = ts.tablespace_name ' ||
                where_clause || 'order by snapshot_date, ts_tablespace_name, df_datafile_name';
    OPEN lcur FOR querystr;
    populate_datafile_tab(lcur, df_alloc_dist, datafile_stats_array);
    CLOSE lcur;
  END get_init_repository_stats;

  PROCEDURE get_datafile_stats
  (
    datafile_stats_array OUT datafile_stats_tab
   ,ts_name              VARCHAR2 DEFAULT NULL
   ,datafile_name        VARCHAR2 DEFAULT NULL
  ) IS
    lcur              rc;
    extra_select_cols VARCHAR2(200);
    where_clause      VARCHAR2(200);
    querystr          VARCHAR2(2000);
    df_alloc_dist     df_distribution_tab;
  BEGIN
    -- get datafile totals by object type (data vs. index vs. other)
    df_alloc_distribution(ts_name, datafile_name, df_alloc_dist);
  
    -- determine columns present by version, and where clause based on input
    build_df_sql(ts_name, datafile_name, extra_select_cols, where_clause);
  
    -- datafiles
    querystr := 'select df.bytes / (1024 * 1024) as df_total_size, ' ||
                '  df.user_bytes / (1024 * 1024) as df_usable_size, ' ||
                '  sysdate as snapshot_date, ts.status as ts_status, ' ||
                '  df.autoextensible as df_autoextensible, ' || '  df.file_name as df_datafile_name, ' ||
                '  ts.tablespace_name as ts_tablespace_name, df.file_id as df_file_id, ' ||
                '  df.relative_fno as df_relative_fno, ts.contents as ts_contents, ' ||
                '  nvl (fr.bytes, 0)/ (1024 * 1024) as df_free_space, ' ||
                '  (df.bytes -  nvl (fr.bytes, 0)) / (1024 * 1024) as df_allocation, ' ||
                '  (df.bytes / df.blocks) * increment_by / (1024 * 1024) ' ||
                '    as df_next_size, df.maxbytes / (1024 * 1024) as df_max_size, ' ||
                '  ts.initial_extent as ts_initial_extent, ts.min_extlen as ts_min_extlen, ' ||
                '  ts.extent_management as ts_extent_management, ' ||
                '  ts.allocation_type as ts_allocation_type ' || extra_select_cols ||
                ' from dba_data_files df, dba_tablespaces ts, ' ||
                '  (select tablespace_name, relative_fno, sum (bytes) as bytes ' ||
                '   from dba_free_space group by tablespace_name, relative_fno) fr ' ||
                ' where fr.tablespace_name (+) = df.tablespace_name ' ||
                '   and fr.relative_fno (+) = df.relative_fno ' ||
                '   and df.tablespace_name = ts.tablespace_name ' || where_clause ||
                ' order by ts.tablespace_name, df.file_name';
    OPEN lcur FOR querystr;
    populate_datafile_tab(lcur, df_alloc_dist, datafile_stats_array);
    CLOSE lcur;
  
    -- tempfiles
    querystr := 'select df.bytes / (1024 * 1024) as df_total_size, ' ||
                '  df.user_bytes / (1024 * 1024) as df_usable_size, ' ||
                '  sysdate as snapshot_date, ts.status as ts_status, ' ||
                '  df.autoextensible as df_autoextensible, ' || '  df.file_name as df_datafile_name, ' ||
                '  ts.tablespace_name as ts_tablespace_name, ' ||
                '  df.file_id as df_file_id, df.relative_fno as df_relative_fno, ' ||
                '  ts.contents as ts_contents,  0 as df_free_space, ' ||
                '  (df.bytes - 0) / (1024 * 1024) as df_allocation, ' ||
                '  (df.bytes / df.blocks) * increment_by / (1024 * 1024) ' ||
                '    as df_next_size, df.maxbytes / (1024 * 1024) as df_max_size, ' ||
                '  ts.initial_extent as ts_initial_extent, ts.min_extlen as ts_min_extlen, ' ||
                '  ts.extent_management as ts_extent_management, ' ||
                '  ts.allocation_type as ts_allocation_type ' || extra_select_cols ||
                ' from dba_temp_files df, dba_tablespaces ts ' ||
                ' where df.tablespace_name = ts.tablespace_name ' || where_clause ||
                ' order by ts.tablespace_name, df.file_name';
    OPEN lcur FOR querystr;
    populate_datafile_tab(lcur, df_alloc_dist, datafile_stats_array);
    CLOSE lcur;
  END get_datafile_stats;

  PROCEDURE get_tablespaces_currt(alltbsp OUT currt_object_list_tab) IS
    CURSOR c_tablespaces IS
      SELECT a.tablespace_name FROM dba_tablespaces a;
    i         PLS_INTEGER;
    more_rows BOOLEAN;
  BEGIN
    i := 0;
    OPEN c_tablespaces;
    more_rows := TRUE;
    WHILE more_rows
    LOOP
      i := i + 1;
      FETCH c_tablespaces
        INTO alltbsp(i);
      IF c_tablespaces%NOTFOUND
      THEN
        alltbsp.delete(i);
        more_rows := FALSE;
      END IF;
    END LOOP;
    CLOSE c_tablespaces;
  END get_tablespaces_currt;

  PROCEDURE get_datafiles_currt(alldf OUT currt_object_tab) IS
    CURSOR c_datafiles IS
      SELECT ts.tablespace_name
            ,d.file_name
            ,d.bytes / 1024 AS total
            ,decode(ts.contents, 'TEMPORARY', 0, 'UNDO', 0, SUM(f.bytes) / 1024) AS free
        FROM dba_free_space  f
            ,dba_data_files  d
            ,dba_tablespaces ts
       WHERE ts.tablespace_name = d.tablespace_name
         AND d.file_id = f.file_id(+)
       GROUP BY ts.tablespace_name
               ,d.file_name
               ,d.bytes
               ,ts.contents
      UNION ALL
      SELECT t.tablespace_name
            ,t.file_name
            ,t.bytes / 1024 AS total
            ,0 AS free
        FROM dba_temp_files t;
    i         PLS_INTEGER;
    more_rows BOOLEAN;
  BEGIN
    i := 0;
    OPEN c_datafiles;
    more_rows := TRUE;
    WHILE more_rows
    LOOP
      i := i + 1;
      FETCH c_datafiles
        INTO alldf(i).short_name
            ,alldf(i).long_name
            ,alldf(i).total_size
            ,alldf(i).free_space;
      IF c_datafiles%NOTFOUND
      THEN
        alldf.delete(i);
        more_rows := FALSE;
      END IF;
    END LOOP;
    CLOSE c_datafiles;
  END get_datafiles_currt;

  PROCEDURE get_largest_tbsp_currt
  (
    bigtbsp       OUT currt_object_tab
   ,num_requested IN NUMBER DEFAULT NULL
  ) IS
    CURSOR c_largest_tbsp IS
      SELECT ts.tablespace_name
            ,s.total
            ,decode(ts.contents, 'TEMPORARY', 0, 'UNDO', 0, nvl(SUM(f.bytes), 0) / 1024) AS free
        FROM dba_tablespaces ts
            ,dba_free_space f
            ,(SELECT d.tablespace_name
                    ,SUM(d.bytes) / 1024 AS total
                FROM dba_data_files d
               GROUP BY d.tablespace_name
              UNION ALL
              SELECT t.tablespace_name
                    ,SUM(t.bytes) / 1024 AS total
                FROM dba_temp_files t
               GROUP BY t.tablespace_name) s
       WHERE ts.tablespace_name = s.tablespace_name
         AND ts.tablespace_name = f.tablespace_name(+)
       GROUP BY ts.tablespace_name
               ,s.total
               ,ts.contents
       ORDER BY s.total DESC
               ,free    ASC;
    i         PLS_INTEGER;
    more_rows BOOLEAN;
  BEGIN
    IF num_requested <= 0
    THEN
      RETURN;
    END IF;
    i := 0;
    OPEN c_largest_tbsp;
    more_rows := TRUE;
    WHILE more_rows
    LOOP
      i := i + 1;
      FETCH c_largest_tbsp
        INTO bigtbsp(i).short_name
            ,bigtbsp(i).total_size
            ,bigtbsp(i).free_space;
      IF c_largest_tbsp%NOTFOUND
      THEN
        bigtbsp.delete(i);
        more_rows := FALSE;
      END IF;
      IF bigtbsp.count >= num_requested
      THEN
        more_rows := FALSE;
      END IF;
    END LOOP;
    CLOSE c_largest_tbsp;
  END get_largest_tbsp_currt;

  PROCEDURE get_largest_df_currt
  (
    tablespace_name_in IN VARCHAR2
   ,bigdf              OUT currt_object_tab
   ,num_requested      IN NUMBER DEFAULT NULL
  ) IS
    CURSOR c_largest_df(tbsp_name IN VARCHAR2) IS
      SELECT d.file_name
            ,d.bytes / 1024 AS total
            ,decode(ts.contents, 'TEMPORARY', 0, 'UNDO', 0, SUM(f.bytes) / 1024) AS free
        FROM dba_tablespaces ts
            ,dba_free_space  f
            ,dba_data_files  d
       WHERE ts.tablespace_name = tbsp_name
         AND ts.tablespace_name = d.tablespace_name
         AND d.file_id = f.file_id(+)
       GROUP BY d.file_name
               ,d.bytes
               ,ts.contents
      UNION ALL
      SELECT t.file_name
            ,t.bytes / 1024 AS total
            ,0 AS free
        FROM dba_temp_files t
       WHERE t.tablespace_name = tbsp_name
       GROUP BY t.file_name
               ,t.bytes
       ORDER BY total DESC
               ,free  ASC;
    i         PLS_INTEGER;
    more_rows BOOLEAN;
  BEGIN
    IF num_requested <= 0
    THEN
      RETURN;
    END IF;
    i := 0;
    OPEN c_largest_df(tablespace_name_in);
    more_rows := TRUE;
    WHILE more_rows
    LOOP
      i := i + 1;
      FETCH c_largest_df
        INTO bigdf(i).long_name
            ,bigdf(i).total_size
            ,bigdf(i).free_space;
      IF c_largest_df%NOTFOUND
      THEN
        bigdf.delete(i);
        more_rows := FALSE;
      END IF;
      IF bigdf.count >= num_requested
      THEN
        more_rows := FALSE;
      END IF;
    END LOOP;
    CLOSE c_largest_df;
  END get_largest_df_currt;

  PROCEDURE get_instances_currt(allinst OUT currt_inst_list_tab) IS
    CURSOR c_instances IS
      SELECT a.instance_number
            ,a.instance_name
            ,a.host_name
            ,a.status
        FROM gv$instance a;
    i         PLS_INTEGER;
    more_rows BOOLEAN;
  BEGIN
    i := 0;
    OPEN c_instances;
    more_rows := TRUE;
    WHILE more_rows
    LOOP
      i := i + 1;
      FETCH c_instances
        INTO allinst(i);
      IF c_instances%NOTFOUND
      THEN
        allinst.delete(i);
        more_rows := FALSE;
      END IF;
    END LOOP;
    CLOSE c_instances;
  END get_instances_currt;
END quest_cmo_collector;
/

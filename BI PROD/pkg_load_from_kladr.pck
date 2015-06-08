CREATE OR REPLACE PACKAGE pkg_load_from_kladr AS
  -- procedure to a load a table with records
  -- from a DBASE file.
  --
  -- Uses a BFILE to read binary data and dbms_sql
  -- to dynamically insert into any table you
  -- have insert on.
  --
  -- p_dir is the name of an ORACLE Directory Object
  --       that was created via the CREATE DIRECTORY
  --       command
  --
  -- p_file is the name of a file in that directory
  --        will be the name of the DBASE file
  --
  -- p_tname is the name of the table to load from
  --
  -- p_cnames is an optional list of comma separated
  --          column names.  If not supplied, this pkg
  --          assumes the column names in the DBASE file
  --          are the same as the column names in the
  --          table
  --
  -- p_show boolean that if TRUE will cause us to just
  --        PRINT (and not insert) what we find in the
  --        DBASE files (not the data, just the info
  --        from the dbase headers....)
  PROCEDURE load_table
  (
    p_dir    IN VARCHAR2
   ,p_file   IN VARCHAR2
   ,p_tname  IN VARCHAR2
   ,p_cnames IN VARCHAR2 DEFAULT NULL
   ,p_show   IN BOOLEAN DEFAULT FALSE
  );

  --�������� ��������� dbf-������
  PROCEDURE ww_test_load;

  --��������� �� ������������� ������ � ��������
  PROCEDURE run_load_from_temp
  (
    p_error  OUT NUMBER
   ,p_reload NUMBER DEFAULT 0
    /* 1-�������������� ������� ���������� ���� ������; 0 - �� ������� */
  );

  --�������� ������������� ������
  PROCEDURE create_temp_tables(p_error OUT NUMBER);

  --��������� �� ��������� �������
  PROCEDURE run_load_to_temp(p_error OUT NUMBER);

  --���������, ������� ��������� �������� ������ � ���� ���� �� �����:
  PROCEDURE run_load
  (
    p_reload_table        IN NUMBER DEFAULT 0
   ,p_reload_to_temp      IN NUMBER DEFAULT 0
   ,p_recreate_temp_table IN NUMBER DEFAULT 0
  );
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_load_from_kladr AS
  big_endian CONSTANT BOOLEAN DEFAULT TRUE;

  TYPE dbf_header IS RECORD(
     VERSION    VARCHAR2(25)
    , -- dBASE ������
    YEAR       INT
    , -- 1 byte int year, add to 1900
    MONTH      INT
    , -- 1 byte month
    DAY        INT
    , -- 1 byte day
    no_records INT
    , -- number of records in file,
    -- 4 byte int
    hdr_len INT
    , -- length of header, 2 byte int
    rec_len INT
    , -- number of bytes in record,
    -- 2 byte int
    no_fields INT -- number of fields
    );

  TYPE field_descriptor IS RECORD(
     NAME     VARCHAR2(11)
    ,TYPE     CHAR(1)
    ,LENGTH   INT
    , -- 1 byte length
    decimals INT -- 1 byte scale
    );

  TYPE field_descriptor_array IS TABLE OF field_descriptor INDEX BY BINARY_INTEGER;

  TYPE rowarray IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  g_cursor BINARY_INTEGER DEFAULT DBMS_SQL.open_cursor;

  /*************************************************************************************/
  -- Function to convert a binary unsigned integer
  -- into a PLSQL number
  FUNCTION to_int(p_data IN VARCHAR2) RETURN NUMBER IS
    l_number NUMBER DEFAULT 0;
    l_bytes  NUMBER DEFAULT LENGTH(p_data);
  BEGIN
    IF (big_endian)
    THEN
      FOR i IN 1 .. l_bytes
      LOOP
        l_number := l_number + ASCII(SUBSTR(p_data, i, 1)) * POWER(2, 8 * (i - 1));
      END LOOP;
    ELSE
      FOR i IN 1 .. l_bytes
      LOOP
        l_number := l_number + ASCII(SUBSTR(p_data, l_bytes - i + 1, 1)) * POWER(2, 8 * (i - 1));
      END LOOP;
    END IF;
  
    RETURN l_number;
  END;

  -- Routine to parse the DBASE header record, can get
  -- all of the details of the contents of a dbase file from
  -- this header
  PROCEDURE get_header
  (
    p_bfile        IN BFILE
   ,p_bfile_offset IN OUT NUMBER
   ,p_hdr          IN OUT dbf_header
   ,p_flds         IN OUT field_descriptor_array
  ) IS
    l_data            VARCHAR2(100);
    l_hdr_size        NUMBER DEFAULT 32;
    l_field_desc_size NUMBER DEFAULT 32;
    l_flds            field_descriptor_array;
  BEGIN
    p_flds           := l_flds;
    l_data           := UTL_RAW.cast_to_varchar2(DBMS_LOB.SUBSTR(p_bfile, l_hdr_size, p_bfile_offset));
    p_bfile_offset   := p_bfile_offset + l_hdr_size;
    p_hdr.VERSION    := ASCII(SUBSTR(l_data, 1, 1));
    p_hdr.YEAR       := 1900 + ASCII(SUBSTR(l_data, 2, 1));
    p_hdr.MONTH      := ASCII(SUBSTR(l_data, 3, 1));
    p_hdr.DAY        := ASCII(SUBSTR(l_data, 4, 1));
    p_hdr.no_records := to_int(SUBSTR(l_data, 5, 4));
    p_hdr.hdr_len    := to_int(SUBSTR(l_data, 9, 2));
    p_hdr.rec_len    := to_int(SUBSTR(l_data, 11, 2));
    p_hdr.no_fields  := TRUNC((p_hdr.hdr_len - l_hdr_size) / l_field_desc_size);
  
    FOR i IN 1 .. p_hdr.no_fields
    LOOP
      l_data := UTL_RAW.cast_to_varchar2(DBMS_LOB.SUBSTR(p_bfile, l_field_desc_size, p_bfile_offset));
      p_bfile_offset := p_bfile_offset + l_field_desc_size;
      p_flds(i).NAME := RTRIM(SUBSTR(l_data, 1, 11), CHR(0));
      p_flds(i).TYPE := SUBSTR(l_data, 12, 1);
      p_flds(i).LENGTH := ASCII(SUBSTR(l_data, 17, 1));
      p_flds(i).decimals := ASCII(SUBSTR(l_data, 18, 1));
    END LOOP;
  
    p_bfile_offset := p_bfile_offset + MOD(p_hdr.hdr_len - l_hdr_size, l_field_desc_size);
  END;

  /*************************************************************************************/

  FUNCTION build_insert
  (
    p_tname  IN VARCHAR2
   ,p_cnames IN VARCHAR2
   ,p_flds   IN field_descriptor_array
  ) RETURN VARCHAR2 IS
    l_insert_statement LONG;
  BEGIN
    l_insert_statement := 'insert into ' || p_tname || '(';
  
    IF (p_cnames IS NOT NULL)
    THEN
      l_insert_statement := l_insert_statement || p_cnames || ') values (';
    ELSE
      FOR i IN 1 .. p_flds.COUNT
      LOOP
        IF (i <> 1)
        THEN
          l_insert_statement := l_insert_statement || ',';
        END IF;
        l_insert_statement := l_insert_statement || '"' || p_flds(i).NAME || '"';
      END LOOP;
      l_insert_statement := l_insert_statement || ') values (';
    END IF;
  
    FOR i IN 1 .. p_flds.COUNT
    LOOP
      IF (i <> 1)
      THEN
        l_insert_statement := l_insert_statement || ',';
      END IF;
    
      IF (p_flds(i).TYPE = 'D')
      THEN
        l_insert_statement := l_insert_statement || 'to_date(:bv' || i || ',''yyyymmdd'' )';
      ELSE
        l_insert_statement := l_insert_statement || ':bv' || i;
      END IF;
    END LOOP;
  
    l_insert_statement := l_insert_statement || ')';
    RETURN l_insert_statement;
  END;

  FUNCTION get_row
  (
    p_bfile        IN BFILE
   ,p_bfile_offset IN OUT NUMBER
   ,p_hdr          IN dbf_header
   ,p_flds         IN field_descriptor_array
  ) RETURN rowarray IS
    l_data VARCHAR2(4000);
    l_row  rowarray;
    l_n    NUMBER DEFAULT 2;
  BEGIN
    l_data := CONVERT(UTL_RAW.cast_to_varchar2(DBMS_LOB.SUBSTR(p_bfile, p_hdr.rec_len, p_bfile_offset))
                     ,'CL8MSWIN1251'
                     ,'RU8PC866');
    p_bfile_offset := p_bfile_offset + p_hdr.rec_len;
    l_row(0) := SUBSTR(l_data, 1, 1);
  
    FOR i IN 1 .. p_hdr.no_fields
    LOOP
      l_row(i) := RTRIM(LTRIM(SUBSTR(l_data, l_n, p_flds(i).LENGTH)));
      IF (p_flds(i).TYPE = 'F' AND l_row(i) = '.')
      THEN
        l_row(i) := NULL;
      END IF;
      l_n := l_n + p_flds(i).LENGTH;
    END LOOP;
  
    RETURN l_row;
  END get_row;

  /*************************************************************************************/

  PROCEDURE show
  (
    p_hdr    IN dbf_header
   ,p_flds   IN field_descriptor_array
   ,p_tname  IN VARCHAR2
   ,p_cnames IN VARCHAR2
   ,p_bfile  IN BFILE
  ) IS
    l_sep VARCHAR2(1) DEFAULT ',';
  
    PROCEDURE p(p_str IN VARCHAR2) IS
      l_str LONG DEFAULT p_str;
    BEGIN
      WHILE (l_str IS NOT NULL)
      LOOP
        DBMS_OUTPUT.put_line(SUBSTR(l_str, 1, 250));
        l_str := SUBSTR(l_str, 251);
      END LOOP;
    END;
  BEGIN
    p('������ DBASE �����: ' || DBMS_LOB.getlength(p_bfile));
    p('DBASE ���������� � ���������: ');
    p(CHR(9) || '������  = ' || p_hdr.VERSION);
    p(CHR(9) || '���     = ' || p_hdr.YEAR);
    p(CHR(9) || '�����   = ' || p_hdr.MONTH);
    p(CHR(9) || '����    = ' || p_hdr.DAY);
    p(CHR(9) || '#�������= ' || p_hdr.no_records);
    p(CHR(9) || '��� ��� = ' || p_hdr.hdr_len);
    p(CHR(9) || '��� ��� = ' || p_hdr.rec_len);
    p(CHR(9) || '#����   = ' || p_hdr.no_fields);
    p(CHR(10) || '�a���� :');
  
    FOR i IN 1 .. p_hdr.no_fields
    LOOP
      p('���� (' || i || ') ' || '���  = "' || p_flds(i).NAME || '", ' || '���  = ' || p_flds(i).TYPE || ', ' ||
        '�����= ' || p_flds(i).LENGTH || ', ' || '����.= ' || p_flds(i).decimals);
    END LOOP;
  
    p(CHR(10) || '��� ������� ������������:');
    p(build_insert(p_tname, p_cnames, p_flds));
    p(CHR(10) || '������ ��� �������� �������:');
    p('create table ' || p_tname);
    p('(');
  
    FOR i IN 1 .. p_hdr.no_fields
    LOOP
      IF (i = p_hdr.no_fields)
      THEN
        l_sep := ')';
      END IF;
    
      DBMS_OUTPUT.put(CHR(9) || '"' || p_flds(i).NAME || '"   ');
    
      IF (p_flds(i).TYPE = 'D')
      THEN
        p('date' || l_sep);
      ELSIF (p_flds(i).TYPE = 'F')
      THEN
        p('float' || l_sep);
      ELSIF (p_flds(i).TYPE = 'N')
      THEN
        IF (p_flds(i).decimals > 0)
        THEN
          p('number(' || p_flds(i).LENGTH || ',' || p_flds(i).decimals || ')' || l_sep);
        ELSE
          p('number(' || p_flds(i).LENGTH || ')' || l_sep);
        END IF;
      ELSE
        p('varchar2(' || p_flds(i).LENGTH || ')' || l_sep);
      END IF;
    END LOOP;
  
    p('/');
  END;

  /*************************************************************************************/

  PROCEDURE load_table
  (
    p_dir    IN VARCHAR2
   ,p_file   IN VARCHAR2
   ,p_tname  IN VARCHAR2
   ,p_cnames IN VARCHAR2 DEFAULT NULL
   ,p_show   IN BOOLEAN DEFAULT FALSE
  ) IS
    l_bfile  BFILE;
    l_offset NUMBER DEFAULT 1;
    l_hdr    dbf_header;
    l_flds   field_descriptor_array;
    l_row    rowarray;
  BEGIN
    l_bfile := BFILENAME(p_dir, p_file);
    DBMS_LOB.fileopen(l_bfile);
    get_header(l_bfile, l_offset, l_hdr, l_flds);
  
    IF (p_show)
    THEN
      show(l_hdr, l_flds, p_tname, p_cnames, l_bfile);
    ELSE
      DBMS_SQL.parse(g_cursor, build_insert(p_tname, p_cnames, l_flds), DBMS_SQL.native);
      FOR i IN 1 .. l_hdr.no_records
      LOOP
        l_row := get_row(l_bfile, l_offset, l_hdr, l_flds);
      
        IF (l_row(0) <> '*') -- deleted record
        THEN
          FOR i IN 1 .. l_hdr.no_fields
          LOOP
            DBMS_SQL.bind_variable(g_cursor, ':bv' || i, l_row(i), 4000);
          END LOOP;
        
          IF (DBMS_SQL.EXECUTE(g_cursor) <> 1)
          THEN
            raise_application_error(-20001, '������� ����������' || SQLERRM);
          END IF;
        END IF;
      END LOOP;
    END IF;
  
    DBMS_LOB.fileclose(l_bfile);
  EXCEPTION
    WHEN OTHERS THEN
      IF (DBMS_LOB.ISOPEN(l_bfile) > 0)
      THEN
        DBMS_LOB.fileclose(l_bfile);
      END IF;
      RAISE;
  END;

  /*************************************************************************************/

  PROCEDURE ww_test_load IS
    l_bfile  BFILE;
    l_offset NUMBER DEFAULT 1;
    l_hdr    dbf_header;
    l_flds   field_descriptor_array;
    l_row    rowarray;
    p_tname  VARCHAR2(30);
    p_cnames VARCHAR2(30) DEFAULT NULL;
  BEGIN
    l_bfile := BFILENAME('WW_DBF_FOLDER', 'SOCRBASE.DBF');
    DBMS_LOB.fileopen(l_bfile);
    get_header(l_bfile, l_offset, l_hdr, l_flds);
    show(l_hdr, l_flds, p_tname, p_cnames, l_bfile);
    DBMS_LOB.fileclose(l_bfile);
  EXCEPTION
    WHEN OTHERS THEN
      IF (DBMS_LOB.ISOPEN(l_bfile) > 0)
      THEN
        DBMS_LOB.fileclose(l_bfile);
      END IF;
    
      RAISE;
  END;

  /*************************************************************************************/

  --��������� �� ������������� ������ � ��������
  PROCEDURE run_load_from_temp
  (
    p_error  OUT NUMBER
   ,p_reload NUMBER DEFAULT 0
    /* 1-�������������� ������� ���������� ���� ������; 0 - �� ������� */
  ) IS
    SUBTYPE typ_kladr_code IS temp_kladr.code%TYPE;
    const_province   CONSTANT typ_kladr_code := '__000000000__';
    const_province_n CONSTANT typ_kladr_code := '00000000000__';
    const_region     CONSTANT typ_kladr_code := '_____000000__';
    const_region_n   CONSTANT typ_kladr_code := '__000000000__';
    const_city       CONSTANT typ_kladr_code := '________000__';
    const_city_n     CONSTANT typ_kladr_code := '_____000000__';
    const_district   CONSTANT typ_kladr_code := '_____________';
    const_district_n CONSTANT typ_kladr_code := '________000__';
  
    --������ � �����������, ��������������� ��� ������� ������� ������� �� �������
    CURSOR cur_kladr_object
    (
      const_reg1 typ_kladr_code
     ,const_reg2 typ_kladr_code
    ) IS
      SELECT rownum
            ,kladr.socr kladr_socr
            ,kladr."NAME" kladr_name
             ,SUBSTR(kladr.code, 1, 11) kladr_code
             ,kladr.code kladr_code_hist
             ,kladr."INDEX" kladr_zip
             ,kladr.ocatd kladr_ocatd
        FROM temp_kladr kladr
       WHERE kladr.code LIKE const_reg1
         AND kladr.code NOT LIKE const_reg2;
  
    --������, ��������������� ��� ������� ������� �� ������
    CURSOR cur_street IS
      SELECT rownum
            ,st.socr kladr_socr
            ,st."NAME" kladr_name
             ,SUBSTR(st.code, 1, 15) kladr_code
             ,SUBSTR(st.code, 1, 11) kladr_code_parent
             ,st.code kladr_code_hist
             ,st."INDEX" kladr_zip
             ,st.ocatd kladr_ocatd
        FROM temp_street st;
    --------------------------------
  BEGIN
    --�������� ����� �������� (������)
    DECLARE
      --������ ��� ����� ��������, ������� �������� � �����-dbf
      CURSOR cur_kladr_obj_type(p_type_obj VARCHAR2) IS
        SELECT sb.socrname
              ,sb.scname
              ,sb.kod_t_st
          FROM temp_socrbase sb
         WHERE sb."LEVEL" = p_type_obj;
      --������ �� ������ �������
      row_obj_type1 t_province_type%ROWTYPE;
      row_obj_type2 t_region_type%ROWTYPE;
      row_obj_type3 t_city_type%ROWTYPE;
      row_obj_type4 t_district_type%ROWTYPE;
      row_obj_type5 t_street_type%ROWTYPE;
      --���������� �������
      p_row_count NUMBER(10);
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --------------------------------
    BEGIN
      dbms_output.put_line('������ �������� ����� ��������...');
    
      --�������
      BEGIN
        p_row_count    := 0;
        p_own_count    := 0;
        p_own_load     := 0;
        p_own_noload   := 0;
        p_own_inserted := 0;
        dbms_output.put_line('������ �������� ������ � ������� T_PROVINCE_TYPE...');
        IF p_reload = 1
        THEN
          DELETE FROM t_province_type;
        END IF;
      
        FOR row_obj_type IN cur_kladr_obj_type('1')
        LOOP
          p_own_count := p_own_count + 1;
        
          --��������� ������ ��� �������  
          SELECT sq_t_province_type.nextval INTO row_obj_type1.province_type_id FROM dual;
          row_obj_type1.description       := row_obj_type.socrname;
          row_obj_type1.description_short := row_obj_type.scname;
          row_obj_type1.kladr_type        := to_number(row_obj_type.kod_t_st);
          row_obj_type1.is_default        := 0;
          row_obj_type1.ent_id            := 204;
        
          --������� � ������� t_province_type ��������������� ������ 
          SELECT COUNT(*)
            INTO p_row_count
            FROM t_province_type pt
           WHERE pt.DESCRIPTION_SHORT = row_obj_type1.description_short;
          --and    pt.DESCRIPTION=row_obj_type1.description
          --and    pt.KLADR_TYPE=row_obj_type1.kladr_type;
        
          --���� �� �� ������� � ������� ��������������� ������, �� �������� �
          IF p_row_count = 0
          THEN
            INSERT INTO t_province_type VALUES row_obj_type1;
            p_own_inserted := p_own_inserted + 1;
            p_own_load     := p_own_load + 1;
          ELSE
            p_own_noload := p_own_noload + 1;
          END IF;
        END LOOP;
      
        --�������������� ������ �������� 
        dbms_output.put_line('...���������');
        dbms_output.put_line('����������: ');
        dbms_output.put_line('����������: ' || p_own_count);
        dbms_output.put_line('���������: ' || p_own_load);
        dbms_output.put_line('�� ���������: ' || p_own_noload);
        dbms_output.put_line('Inserted : ' || p_own_inserted);
        dbms_output.put_line('-------------------');
      END;
    
      --�����
      BEGIN
        p_row_count    := 0;
        p_own_count    := 0;
        p_own_load     := 0;
        p_own_noload   := 0;
        p_own_inserted := 0;
        dbms_output.put_line('������ �������� � ������� T_REGION_TYPE...');
        IF p_reload = 1
        THEN
          DELETE FROM T_REGION_TYPE;
        END IF;
      
        FOR row_obj_type IN cur_kladr_obj_type('2')
        LOOP
          p_own_count := p_own_count + 1;
        
          --��������� ������ ��� �������  
          SELECT sq_t_region_type.nextval INTO row_obj_type2.region_type_id FROM dual;
          row_obj_type2.description       := row_obj_type.socrname;
          row_obj_type2.description_short := row_obj_type.scname;
          row_obj_type2.kladr_type        := to_number(row_obj_type.kod_t_st);
          row_obj_type2.is_default        := 0;
          row_obj_type2.ent_id            := 206;
        
          --������� � ������� t_region_type ��������������� ������ 
          SELECT COUNT(*)
            INTO p_row_count
            FROM t_region_type pt
           WHERE pt.DESCRIPTION_SHORT = row_obj_type2.description_short;
          --and    pt.DESCRIPTION=row_obj_type2.description
          --and    pt.KLADR_TYPE=row_obj_type2.kladr_type;
        
          --���� �� �� ������� � ������� ��������������� ������, �� �������� �
          IF p_row_count = 0
          THEN
            INSERT INTO t_region_type VALUES row_obj_type2;
            p_own_inserted := p_own_inserted + 1;
            p_own_load     := p_own_load + 1;
          ELSE
            p_own_noload := p_own_noload + 1;
          END IF;
        END LOOP;
      
        --�������������� ������ �������� 
        dbms_output.put_line('...���������');
        dbms_output.put_line('����������: ');
        dbms_output.put_line('����������: ' || p_own_count);
        dbms_output.put_line('���������: ' || p_own_load);
        dbms_output.put_line('�� ���������: ' || p_own_noload);
        dbms_output.put_line('Inserted : ' || p_own_inserted);
        dbms_output.put_line('-------------------');
      END;
    
      --�����
      BEGIN
        p_row_count    := 0;
        p_own_count    := 0;
        p_own_load     := 0;
        p_own_noload   := 0;
        p_own_inserted := 0;
        dbms_output.put_line('������ �������� � ������� T_CITY_TYPE...');
        IF p_reload = 1
        THEN
          DELETE FROM t_city_type;
        END IF;
      
        FOR row_obj_type IN cur_kladr_obj_type('3')
        LOOP
          p_own_count := p_own_count + 1;
        
          --��������� ������ ��� �������  
          SELECT sq_t_city_type.nextval INTO row_obj_type3.city_type_id FROM dual;
          row_obj_type3.description       := row_obj_type.socrname;
          row_obj_type3.description_short := row_obj_type.scname;
          row_obj_type3.kladr_type        := to_number(row_obj_type.kod_t_st);
          row_obj_type3.is_default        := 0;
          row_obj_type3.ent_id            := 202;
        
          --������� � ������� t_city_type ��������������� ������ 
          SELECT COUNT(*)
            INTO p_row_count
            FROM t_city_type pt
           WHERE pt.DESCRIPTION_SHORT = row_obj_type3.description_short;
          --and    pt.DESCRIPTION=row_obj_type3.description
          --and    pt.KLADR_TYPE=row_obj_type3.kladr_type;
        
          --���� �� �� ������� � ������� ��������������� ������, �� �������� �
          IF p_row_count = 0
          THEN
            INSERT INTO t_city_type VALUES row_obj_type3;
            p_own_inserted := p_own_inserted + 1;
            p_own_load     := p_own_load + 1;
          ELSE
            p_own_noload := p_own_noload + 1;
          END IF;
        END LOOP;
      
        --�������������� ������ �������� 
        dbms_output.put_line('...���������');
        dbms_output.put_line('����������: ');
        dbms_output.put_line('����������: ' || p_own_count);
        dbms_output.put_line('���������: ' || p_own_load);
        dbms_output.put_line('�� ���������: ' || p_own_noload);
        dbms_output.put_line('Inserted : ' || p_own_inserted);
        dbms_output.put_line('-------------------');
      END;
    
      --��������� �����
      BEGIN
        p_row_count    := 0;
        p_own_count    := 0;
        p_own_load     := 0;
        p_own_noload   := 0;
        p_own_inserted := 0;
        dbms_output.put_line('������ �������� � ������� T_DISTRICT_TYPE...');
        IF p_reload = 1
        THEN
          DELETE FROM t_district_type;
        END IF;
      
        FOR row_obj_type IN cur_kladr_obj_type('4')
        LOOP
          p_own_count := p_own_count + 1;
        
          --��������� ������ ��� �������  
          SELECT sq_t_district_type.nextval INTO row_obj_type4.district_type_id FROM dual;
          row_obj_type4.description       := row_obj_type.socrname;
          row_obj_type4.description_short := row_obj_type.scname;
          row_obj_type4.kladr_type        := to_number(row_obj_type.kod_t_st);
          row_obj_type4.is_default        := 0;
          row_obj_type4.ent_id            := 203;
        
          --������� � ������� t_district_type ��������������� ������ 
          SELECT COUNT(*)
            INTO p_row_count
            FROM t_district_type pt
           WHERE pt.DESCRIPTION_SHORT = row_obj_type4.description_short;
          --and    pt.DESCRIPTION=row_obj_type4.description
          --and    pt.KLADR_TYPE=row_obj_type4.kladr_type;
        
          --���� �� �� ������� � ������� ��������������� ������, �� �������� �
          IF p_row_count = 0
          THEN
            INSERT INTO t_district_type VALUES row_obj_type4;
            p_own_inserted := p_own_inserted + 1;
            p_own_load     := p_own_load + 1;
          ELSE
            p_own_noload := p_own_noload + 1;
          END IF;
        END LOOP;
      
        --�������������� ������ �������� 
        dbms_output.put_line('...���������');
        dbms_output.put_line('����������: ');
        dbms_output.put_line('����������: ' || p_own_count);
        dbms_output.put_line('���������: ' || p_own_load);
        dbms_output.put_line('�� ���������: ' || p_own_noload);
        dbms_output.put_line('Inserted : ' || p_own_inserted);
        dbms_output.put_line('-------------------');
      END;
    
      --�����
      BEGIN
        p_row_count    := 0;
        p_own_count    := 0;
        p_own_load     := 0;
        p_own_noload   := 0;
        p_own_inserted := 0;
        dbms_output.put_line('������ �������� � ������� T_STREET_TYPE...');
        IF p_reload = 1
        THEN
          DELETE FROM t_street_type;
        END IF;
      
        FOR row_obj_type IN cur_kladr_obj_type('5')
        LOOP
          p_own_count := p_own_count + 1;
        
          --��������� ������ ��� �������  
          SELECT sq_t_street_type.nextval INTO row_obj_type5.street_type_id FROM dual;
          row_obj_type5.description       := row_obj_type.socrname;
          row_obj_type5.description_short := row_obj_type.scname;
          row_obj_type5.kladr_type        := to_number(row_obj_type.kod_t_st);
          row_obj_type5.is_default        := 0;
          row_obj_type5.ent_id            := 201;
        
          --������� � ������� t_street_type ��������������� ������ 
          SELECT COUNT(*)
            INTO p_row_count
            FROM t_street_type pt
           WHERE pt.DESCRIPTION_SHORT = row_obj_type5.description_short;
          --and    pt.DESCRIPTION=row_obj_type5.description
          --and    pt.KLADR_TYPE=row_obj_type5.kladr_type;
        
          --���� �� �� ������� � ������� ��������������� ������, �� �������� �
          IF p_row_count = 0
          THEN
            INSERT INTO t_street_type VALUES row_obj_type5;
            p_own_inserted := p_own_inserted + 1;
            p_own_load     := p_own_load + 1;
          ELSE
            p_own_noload := p_own_noload + 1;
          END IF;
        END LOOP;
      
        --�������������� ������ �������� 
        dbms_output.put_line('...���������');
        dbms_output.put_line('����������: ');
        dbms_output.put_line('����������: ' || p_own_count);
        dbms_output.put_line('���������: ' || p_own_load);
        dbms_output.put_line('�� ���������: ' || p_own_noload);
        dbms_output.put_line('Inserted : ' || p_own_inserted);
        dbms_output.put_line('-------------------');
      END;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� ����� �������� ����������� � ��������... �������� �����');
        RAISE;
    END;
    --�������� ����� �������� (�����)
    --    
    ---------------------------------------
    ---------------------------------------
    --
    -- �������� � ������� T_PROVINCE (������)
    DECLARE
      --������ �� ������ �������
      row_table t_province%ROWTYPE;
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --���������� ���������� �������
      p_own_updated NUMBER(20) := 0;
      --���������� ���������� ������� � ����������������
      p_upd_warn_count NUMBER(20) := 0;
      --���������� ��������������
      p_own_warning NUMBER(20) := 0;
    BEGIN
      dbms_output.put_line('������ �������� � ������� T_PROVINCE...');
    
      IF p_reload = 1
      THEN
        DELETE FROM t_province;
      END IF;
    
      FOR row_province IN cur_kladr_object(const_province, const_province_n)
      LOOP
        p_own_count := p_own_count + 1;
        --������� ��������������� ������ � ������� � ��������� � ��� ���� KLADR_CODE_HIST
        UPDATE t_province pr
           SET pr.KLADR_CODE_HIST = row_province.kladr_code_hist
         WHERE pr.KLADR_CODE = row_province.kladr_code
           AND pr.province_name = row_province.kladr_name
           AND (pr.ZIP = row_province.kladr_zip OR (pr.ZIP IS NULL AND row_province.kladr_zip IS NULL))
           AND (pr.OCATD = row_province.kladr_OCATD OR
               (pr.OCATD IS NULL AND row_province.kladr_OCATD IS NULL))
           AND pr.country_id = 169
           AND pr.PROVINCE_TYPE_ID =
               (SELECT pt.province_type_id
                  FROM t_province_type pt
                 WHERE pt.DESCRIPTION_SHORT = row_province.kladr_socr);
        CASE
        
        --������� ������ 1-�� ������
          WHEN SQL%ROWCOUNT > 1 THEN
            p_own_load       := p_own_load + 1;
            p_upd_warn_count := p_upd_warn_count + 1;
            p_own_warning    := p_own_warning + 1;
            dbms_output.put_line('��������������!!! ��� ������� ' || row_province.kladr_name || ',' ||
                                 row_province.kladr_socr ||
                                 ' ������� ����� ������ ������������ � ������������ �����������');
          
        --������� �� �������
          WHEN SQL%ROWCOUNT = 0 THEN
            SELECT sq_t_province.nextval INTO row_table.province_id FROM dual;
            row_table.province_name   := row_province.kladr_name;
            row_table.kladr_code      := row_province.kladr_code;
            row_table.kladr_code_hist := row_province.kladr_code_hist;
            row_table.ZIP             := row_province.kladr_zip;
            row_table.OCATD           := row_province.kladr_OCATD;
            row_table.COUNTRY_ID      := 169;
            row_table.is_default      := 0;
            row_table.ent_id          := 205;
          
            --��������� ������� � ����������� ���� �������  
            BEGIN
              SELECT pt.PROVINCE_TYPE_id
                INTO row_table.PROVINCE_TYPE_ID
                FROM t_province_type pt
               WHERE pt.DESCRIPTION_SHORT = row_province.kladr_socr;
              --�������� ������ � �������
              INSERT INTO t_province VALUES row_table;
              p_own_load     := p_own_load + 1;
              p_own_inserted := p_own_inserted + 1;
              -- dbms_output.put_line(to_char(row_province.rownum,'000000')||': Insert record');
            EXCEPTION
              WHEN no_data_found THEN
                p_own_noload  := p_own_noload + 1;
                p_own_warning := p_own_warning + 1;
                dbms_output.put_line('��������������!!! ��� ������� ' || row_province.kladr_name || ',' ||
                                     row_province.kladr_socr ||
                                     ' �� ������� ���������������� �������� � ����������� �����');
            END;
          
        --������ �������
          WHEN SQL%ROWCOUNT = 1 THEN
            p_own_load    := p_own_load + 1;
            p_own_updated := p_own_updated + 1;
            --dbms_output.put_line(to_char(row_province.rownum,'000000')||': Update record');
        END CASE;
      END LOOP;
    
      --�������������� ������ �������� 
      dbms_output.put_line('...���������');
      dbms_output.put_line('����������: ');
      dbms_output.put_line('����������: ' || p_own_count);
      dbms_output.put_line('���������: ' || p_own_load);
      dbms_output.put_line('�� ���������: ' || p_own_noload);
      dbms_output.put_line('Inserted: ' || p_own_inserted);
      dbms_output.put_line('Updated: ' || p_own_updated);
      dbms_output.put_line('Updated (Warning): ' || p_upd_warn_count);
      dbms_output.put_line('Warnings: ' || p_own_warning);
      dbms_output.put_line('-------------------');
    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� � ������� T_PROVINCE ����������� � ��������... �������� �����');
        RAISE;
    END;
    -- �������� � ������� T_PROVINCE (�����)
    --    
    ---------------------------------------
    ---------------------------------------
    --
    -- �������� � ������� T_REGION (������)
    DECLARE
      --������ �� ������ �������
      row_table t_region%ROWTYPE;
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --���������� ���������� �������
      p_own_updated NUMBER(20) := 0;
      --���������� ���������� ������� � ����������������
      p_upd_warn_count NUMBER(20) := 0;
      --���������� ��������������
      p_own_warning NUMBER(20) := 0;
    BEGIN
      dbms_output.put_line('������ �������� � ������� T_REGION...');
    
      IF p_reload = 1
      THEN
        DELETE FROM t_region;
      END IF;
    
      FOR row_region IN cur_kladr_object(const_region, const_region_n)
      LOOP
        p_own_count := p_own_count + 1;
        --������� ��������������� ������ � ������� � ��������� � ��� ���� KLADR_CODE_HIST
        UPDATE t_region pr
           SET pr.KLADR_CODE_HIST = row_region.kladr_code_hist
         WHERE pr.KLADR_CODE = row_region.kladr_code
           AND pr.region_name = row_region.kladr_name
           AND pr.kladr_code_parent = substr(row_region.kladr_code, 1, 2) || '000000000'
           AND (pr.ZIP = row_region.kladr_zip OR (pr.ZIP IS NULL AND row_region.kladr_zip IS NULL))
           AND (pr.OCATD = row_region.kladr_OCATD OR
               (pr.OCATD IS NULL AND row_region.kladr_OCATD IS NULL))
           AND pr.region_TYPE_ID =
               (SELECT pt.region_type_id
                  FROM t_region_type pt
                 WHERE pt.DESCRIPTION_SHORT = row_region.kladr_socr);
        CASE
        --������� ������ 1-�� ������
          WHEN SQL%ROWCOUNT > 1 THEN
            p_own_load       := p_own_load + 1;
            p_upd_warn_count := p_upd_warn_count + 1;
            p_own_warning    := p_own_warning + 1;
            dbms_output.put_line('��������������!!! ��� ������� ' || row_region.kladr_name || ',' ||
                                 row_region.kladr_socr ||
                                 ' ������� ����� ������ ������������ � ������������ �����������');
            --������� �� �������
          WHEN SQL%ROWCOUNT = 0 THEN
            SELECT sq_t_region.nextval INTO row_table.region_id FROM dual;
            row_table.region_name       := row_region.kladr_name;
            row_table.kladr_code        := row_region.kladr_code;
            row_table.kladr_code_parent := substr(row_region.kladr_code, 1, 2) || '000000000';
            row_table.kladr_code_hist   := row_region.kladr_code_hist;
            row_table.ZIP               := row_region.kladr_zip;
            row_table.OCATD             := row_region.kladr_OCATD;
            row_table.is_default        := 0;
            row_table.ent_id            := 207;
          
            --��������� ������� � ����������� ���� �������  
            BEGIN
              SELECT pt.region_TYPE_id
                INTO row_table.region_TYPE_ID
                FROM t_region_type pt
               WHERE pt.DESCRIPTION_SHORT = row_region.kladr_socr;
              --�������� ������ � �������
              INSERT INTO t_region VALUES row_table;
              p_own_load     := p_own_load + 1;
              p_own_inserted := p_own_inserted + 1;
              --dbms_output.put_line(to_char(row_region.rownum,'000000')||': Insert record');
            EXCEPTION
              WHEN no_data_found THEN
                p_own_noload  := p_own_noload + 1;
                p_own_warning := p_own_warning + 1;
                dbms_output.put_line('��������������!!! ��� ������� ' || row_region.kladr_name || ',' ||
                                     row_region.kladr_socr ||
                                     ' �� ������� ���������������� �������� � ����������� �����');
            END;
          
        --������ �������
          WHEN SQL%ROWCOUNT = 1 THEN
            p_own_load    := p_own_load + 1;
            p_own_updated := p_own_updated + 1;
            --dbms_output.put_line(to_char(row_region.rownum,'000000')||': Update record');
        END CASE;
      END LOOP;
    
      --�������������� ������ �������� 
      dbms_output.put_line('...���������');
      dbms_output.put_line('����������: ');
      dbms_output.put_line('����������: ' || p_own_count);
      dbms_output.put_line('���������: ' || p_own_load);
      dbms_output.put_line('�� ���������: ' || p_own_noload);
      dbms_output.put_line('Inserted: ' || p_own_inserted);
      dbms_output.put_line('Updated: ' || p_own_updated);
      dbms_output.put_line('Updated (Warning): ' || p_upd_warn_count);
      dbms_output.put_line('Warnings: ' || p_own_warning);
      dbms_output.put_line('-------------------');
    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� � ������� T_REGION ����������� � ��������... �������� �����');
        RAISE;
    END;
    -- �������� � ������� T_REGION (�����)  
    --    
    ---------------------------------------
    ---------------------------------------
    --
    -- �������� � ������� T_CITY (������)
    DECLARE
      --������ �� ������ �������
      row_table t_city%ROWTYPE;
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --���������� ���������� �������
      p_own_updated NUMBER(20) := 0;
      --���������� ���������� ������� � ����������������
      p_upd_warn_count NUMBER(20) := 0;
      --���������� ��������������
      p_own_warning NUMBER(20) := 0;
    BEGIN
      dbms_output.put_line('������ �������� � ������� T_CITY...');
    
      IF p_reload = 1
      THEN
        DELETE FROM t_city;
      END IF;
    
      FOR row_city IN cur_kladr_object(const_city, const_city_n)
      LOOP
        p_own_count := p_own_count + 1;
        --������� ��������������� ������ � ������� � ��������� � ��� ���� KLADR_CODE_HIST
        UPDATE t_city pr
           SET pr.KLADR_CODE_HIST = row_city.kladr_code_hist
         WHERE pr.KLADR_CODE = row_city.kladr_code
           AND pr.city_name = row_city.kladr_name
           AND pr.kladr_code_parent = substr(row_city.kladr_code, 1, 5) || '000000'
           AND (pr.ZIP = row_city.kladr_zip OR (pr.ZIP IS NULL AND row_city.kladr_zip IS NULL))
           AND (pr.OCATD = row_city.kladr_OCATD OR (pr.OCATD IS NULL AND row_city.kladr_OCATD IS NULL))
           AND pr.city_TYPE_ID = (SELECT pt.city_type_id
                                    FROM t_city_type pt
                                   WHERE pt.DESCRIPTION_SHORT = row_city.kladr_socr);
        CASE
        --������� ������ 1-�� ������
          WHEN SQL%ROWCOUNT > 1 THEN
            p_own_load       := p_own_load + 1;
            p_upd_warn_count := p_upd_warn_count + 1;
            p_own_warning    := p_own_warning + 1;
            dbms_output.put_line('��������������!!! ��� ������� ' || row_city.kladr_name || ',' ||
                                 row_city.kladr_socr ||
                                 ' ������� ����� ������ ������������ � ������������ �����������');
            --������� �� �������
          WHEN SQL%ROWCOUNT = 0 THEN
            SELECT sq_t_city.nextval INTO row_table.city_id FROM dual;
            row_table.city_name         := row_city.kladr_name;
            row_table.kladr_code        := row_city.kladr_code;
            row_table.kladr_code_parent := substr(row_city.kladr_code, 1, 5) || '000000';
            row_table.kladr_code_hist   := row_city.kladr_code_hist;
            row_table.ZIP               := row_city.kladr_zip;
            row_table.OCATD             := row_city.kladr_OCATD;
            row_table.is_default        := 0;
            row_table.ent_id            := 210;
          
            --��������� ������� � ����������� ���� �������  
            BEGIN
              SELECT pt.city_TYPE_id
                INTO row_table.city_TYPE_ID
                FROM t_city_type pt
               WHERE pt.DESCRIPTION_SHORT = row_city.kladr_socr;
              --�������� ������ � �������
              INSERT INTO t_city VALUES row_table;
              p_own_load     := p_own_load + 1;
              p_own_inserted := p_own_inserted + 1;
              --dbms_output.put_line(to_char(row_city.rownum,'000000')||': Insert record');
            EXCEPTION
              WHEN no_data_found THEN
                p_own_noload  := p_own_noload + 1;
                p_own_warning := p_own_warning + 1;
                dbms_output.put_line('��������������!!! ��� ������� ' || row_city.kladr_name || ',' ||
                                     row_city.kladr_socr ||
                                     ' �� ������� ���������������� �������� � ����������� �����');
            END;
          
        --������ �������
          WHEN SQL%ROWCOUNT = 1 THEN
            p_own_load    := p_own_load + 1;
            p_own_updated := p_own_updated + 1;
            --dbms_output.put_line(to_char(row_city.rownum,'000000')||': Update record');
        END CASE;
      END LOOP;
    
      --�������������� ������ �������� 
      dbms_output.put_line('...���������');
      dbms_output.put_line('����������: ');
      dbms_output.put_line('����������: ' || p_own_count);
      dbms_output.put_line('���������: ' || p_own_load);
      dbms_output.put_line('�� ���������: ' || p_own_noload);
      dbms_output.put_line('Inserted: ' || p_own_inserted);
      dbms_output.put_line('Updated: ' || p_own_updated);
      dbms_output.put_line('Updated (Warning): ' || p_upd_warn_count);
      dbms_output.put_line('Warnings: ' || p_own_warning);
      dbms_output.put_line('-------------------');
    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� � ������� T_CITY ����������� � ��������... �������� �����');
        RAISE;
    END;
    -- �������� � ������� T_CITY (�����) 
    --    
    ---------------------------------------
    ---------------------------------------
    --
    -- �������� � ������� T_DISTRICT (������)
    DECLARE
      --������ �� ������ �������
      row_table t_district%ROWTYPE;
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --���������� ���������� �������
      p_own_updated NUMBER(20) := 0;
      --���������� ���������� ������� � ����������������
      p_upd_warn_count NUMBER(20) := 0;
      --���������� ��������������
      p_own_warning NUMBER(20) := 0;
    BEGIN
      dbms_output.put_line('������ �������� � ������� T_DISTRICT...');
    
      IF p_reload = 1
      THEN
        DELETE FROM t_district;
      END IF;
    
      FOR row_district IN cur_kladr_object(const_district, const_district_n)
      LOOP
        p_own_count := p_own_count + 1;
        --������� ��������������� ������ � ������� � ��������� � ��� ���� KLADR_CODE_HIST
        UPDATE t_district pr
           SET pr.KLADR_CODE_HIST = row_district.kladr_code_hist
         WHERE pr.KLADR_CODE = row_district.kladr_code
           AND pr.district_name = row_district.kladr_name
           AND pr.kladr_code_parent = substr(row_district.kladr_code, 1, 8) || '000'
           AND (pr.ZIP = row_district.kladr_zip OR (pr.ZIP IS NULL AND row_district.kladr_zip IS NULL))
           AND (pr.OCATD = row_district.kladr_OCATD OR
               (pr.OCATD IS NULL AND row_district.kladr_OCATD IS NULL))
           AND pr.district_TYPE_ID =
               (SELECT pt.district_type_id
                  FROM t_district_type pt
                 WHERE pt.DESCRIPTION_SHORT = row_district.kladr_socr);
        CASE
        --������� ������ 1-�� ������
          WHEN SQL%ROWCOUNT > 1 THEN
            p_own_load       := p_own_load + 1;
            p_upd_warn_count := p_upd_warn_count + 1;
            p_own_warning    := p_own_warning + 1;
            dbms_output.put_line('��������������!!! ��� ������� ' || row_district.kladr_name || ',' ||
                                 row_district.kladr_socr ||
                                 ' ������� ����� ������ ������������ � ������������ �����������');
            --������� �� �������
          WHEN SQL%ROWCOUNT = 0 THEN
            SELECT sq_t_district.nextval INTO row_table.district_id FROM dual;
            row_table.district_name     := row_district.kladr_name;
            row_table.kladr_code        := row_district.kladr_code;
            row_table.kladr_code_parent := substr(row_district.kladr_code, 1, 8) || '000';
            row_table.kladr_code_hist   := row_district.kladr_code_hist;
            row_table.ZIP               := row_district.kladr_zip;
            row_table.OCATD             := row_district.kladr_OCATD;
            row_table.is_default        := 0;
            row_table.ent_id            := 211;
          
            --��������� ������� � ����������� ���� �������  
            BEGIN
              SELECT pt.district_TYPE_id
                INTO row_table.district_TYPE_ID
                FROM t_district_type pt
               WHERE pt.DESCRIPTION_SHORT = row_district.kladr_socr;
              --�������� ������ � �������
              INSERT INTO t_district VALUES row_table;
              p_own_load     := p_own_load + 1;
              p_own_inserted := p_own_inserted + 1;
              --dbms_output.put_line(to_char(row_district.rownum,'000000')||': Insert record');
            EXCEPTION
              WHEN no_data_found THEN
                p_own_noload  := p_own_noload + 1;
                p_own_warning := p_own_warning + 1;
                dbms_output.put_line('��������������!!! ��� ������� ' || row_district.kladr_name || ',' ||
                                     row_district.kladr_socr ||
                                     ' �� ������� ���������������� �������� � ����������� �����');
            END;
          
        --������ �������
          WHEN SQL%ROWCOUNT = 1 THEN
            p_own_load    := p_own_load + 1;
            p_own_updated := p_own_updated + 1;
            -- dbms_output.put_line(to_char(row_district.rownum,'000000')||': Update record');
        END CASE;
      END LOOP;
    
      --�������������� ������ �������� 
      dbms_output.put_line('...���������');
      dbms_output.put_line('����������: ');
      dbms_output.put_line('����������: ' || p_own_count);
      dbms_output.put_line('���������: ' || p_own_load);
      dbms_output.put_line('�� ���������: ' || p_own_noload);
      dbms_output.put_line('Inserted: ' || p_own_inserted);
      dbms_output.put_line('Updated: ' || p_own_updated);
      dbms_output.put_line('Updated (Warning): ' || p_upd_warn_count);
      dbms_output.put_line('Warnings: ' || p_own_warning);
      dbms_output.put_line('-------------------');
    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� � ������� T_DISTRICT ����������� � ��������... �������� �����');
        RAISE;
    END;
    -- �������� � ������� T_DISTRICT (�����) 
    --
    -- �������� � ������� T_STREET (������)
    DECLARE
      --������ �� ������ �������
      row_table t_street%ROWTYPE;
      --���������� ������������ �������
      p_own_count NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_load NUMBER(20) := 0;
      --���������� ������������� �������
      p_own_noload NUMBER(20) := 0;
      --���������� ����������� �������
      p_own_inserted NUMBER(20) := 0;
      --���������� ���������� �������
      p_own_updated NUMBER(20) := 0;
      --���������� ���������� ������� � ����������������
      p_upd_warn_count NUMBER(20) := 0;
      --���������� ��������������
      p_own_warning NUMBER(20) := 0;
    
    BEGIN
      dbms_output.put_line('������ �������� � ������� T_STREET...');
    
      IF p_reload = 1
      THEN
        DELETE FROM t_street;
      END IF;
    
      FOR row_street IN cur_street
      LOOP
        p_own_count := p_own_count + 1;
        --������� ��������������� ������ � ������� � ��������� � ��� ���� KLADR_CODE_HIST
        UPDATE t_street pr
           SET pr.KLADR_CODE_HIST = row_street.kladr_code_hist
         WHERE pr.KLADR_CODE = row_street.kladr_code
           AND pr.street_name = row_street.kladr_name
           AND pr.kladr_code_parent = row_street.kladr_code_parent
           AND (pr.ZIP = row_street.kladr_zip OR (pr.ZIP IS NULL AND row_street.kladr_zip IS NULL))
           AND (pr.OCATD = row_street.kladr_OCATD OR
               (pr.OCATD IS NULL AND row_street.kladr_OCATD IS NULL))
           AND pr.street_TYPE_ID =
               (SELECT pt.street_type_id
                  FROM t_street_type pt
                 WHERE pt.DESCRIPTION_SHORT = row_street.kladr_socr);
        CASE
        --������� ������ 1-�� ������
          WHEN SQL%ROWCOUNT > 1 THEN
            p_own_load       := p_own_load + 1;
            p_upd_warn_count := p_upd_warn_count + 1;
            p_own_warning    := p_own_warning + 1;
            dbms_output.put_line('��������������!!! ��� ������� ' || row_street.kladr_name || ',' ||
                                 row_street.kladr_socr ||
                                 ' ������� ����� ������ ������������ � ������������ �����������');
            --������� �� �������
          WHEN SQL%ROWCOUNT = 0 THEN
            SELECT sq_t_street.nextval INTO row_table.street_id FROM dual;
            row_table.street_name       := row_street.kladr_name;
            row_table.kladr_code        := row_street.kladr_code;
            row_table.kladr_code_parent := row_street.kladr_code_parent;
            row_table.kladr_code_hist   := row_street.kladr_code_hist;
            row_table.ZIP               := row_street.kladr_zip;
            row_table.OCATD             := row_street.kladr_OCATD;
            row_table.is_default        := 0;
            row_table.ent_id            := 212;
          
            --��������� ������� � ����������� ���� �������  
            BEGIN
              SELECT pt.street_TYPE_id
                INTO row_table.street_TYPE_ID
                FROM t_street_type pt
               WHERE pt.DESCRIPTION_SHORT = row_street.kladr_socr;
              --�������� ������ � �������
              INSERT INTO t_street VALUES row_table;
              p_own_load     := p_own_load + 1;
              p_own_inserted := p_own_inserted + 1;
              --dbms_output.put_line(to_char(row_street.rownum,'000000')||': Insert record');
            EXCEPTION
              WHEN no_data_found THEN
                p_own_noload  := p_own_noload + 1;
                p_own_warning := p_own_warning + 1;
                dbms_output.put_line('��������������!!! ��� ������� ' || row_street.kladr_name || ',' ||
                                     row_street.kladr_socr ||
                                     ' �� ������� ���������������� �������� � ����������� �����');
              WHEN OTHERS THEN
                dbms_output.put_line('Error!!!');
            END;
          
        --������ �������
          WHEN SQL%ROWCOUNT = 1 THEN
            p_own_load    := p_own_load + 1;
            p_own_updated := p_own_updated + 1;
            -- dbms_output.put_line(to_char(row_street.rownum,'000000')||': Update record');
        END CASE;
      END LOOP;
    
      --�������������� ������ �������� 
      dbms_output.put_line('...���������');
      dbms_output.put_line('����������: ');
      dbms_output.put_line('����������: ' || p_own_count);
      dbms_output.put_line('���������: ' || p_own_load);
      dbms_output.put_line('�� ���������: ' || p_own_noload);
      dbms_output.put_line('Inserted: ' || p_own_inserted);
      dbms_output.put_line('Updated: ' || p_own_updated);
      dbms_output.put_line('Updated (Warning): ' || p_upd_warn_count);
      dbms_output.put_line('Warnings: ' || p_own_warning);
      dbms_output.put_line('-------------------');
    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('�������� � ������� T_STREET ����������� � ��������... �������� �����');
        RAISE;
    END;
    -- �������� � ������� T_STREET (�����) 
  
    COMMIT;
    p_error := 0;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_error := 1;
  END;

  /*************************************************************************************/
  --�������� ������������� ������ 
  PROCEDURE create_temp_tables(p_error OUT NUMBER) IS
  BEGIN
    dbms_output.put_line('�������� ������������� ������...');
    BEGIN
      EXECUTE IMMEDIATE ('drop table TEMP_KLADR');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('������� TEMP_KLADR �� ������������ � ������� �����');
    END;
    EXECUTE IMMEDIATE ('CREATE TABLE TEMP_KLADR
    (
      NAME     VARCHAR2(40 BYTE),
      SOCR     VARCHAR2(10 BYTE),
      CODE     VARCHAR2(13 BYTE),
      "INDEX"  VARCHAR2(6 BYTE),
      GNINMB   VARCHAR2(4 BYTE),
      UNO      VARCHAR2(4 BYTE),
      OCATD    VARCHAR2(11 BYTE),
      STATUS   VARCHAR2(1 BYTE)
    )
    TABLESPACE SYSTEM
    PCTUSED    40
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        1
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               )
    LOGGING 
    NOCOMPRESS 
    NOCACHE
    NOPARALLEL
    NOMONITORING');
  
    BEGIN
      EXECUTE IMMEDIATE ('drop table TEMP_SOCRBASE');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('������� TEMP_SOCRBASE �� ������������ � ������� �����');
    END;
    EXECUTE IMMEDIATE ('CREATE TABLE TEMP_SOCRBASE
    (
      "LEVEL"   VARCHAR2(5 BYTE),
      SCNAME    VARCHAR2(10 BYTE),
      SOCRNAME  VARCHAR2(29 BYTE),
      KOD_T_ST  VARCHAR2(3 BYTE)
    )
    TABLESPACE SYSTEM
    PCTUSED    40
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        1
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               )
    LOGGING 
    NOCOMPRESS 
    NOCACHE
    NOPARALLEL
    NOMONITORING');
  
    BEGIN
      EXECUTE IMMEDIATE ('drop table TEMP_STREET');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('������� TEMP_STREET �� ������������ � ������� �����');
    END;
    EXECUTE IMMEDIATE ('CREATE TABLE TEMP_STREET
    (
      NAME     VARCHAR2(40 BYTE),
      SOCR     VARCHAR2(10 BYTE),
      CODE     VARCHAR2(17 BYTE),
      "INDEX"  VARCHAR2(6 BYTE),
      GNINMB   VARCHAR2(4 BYTE),
      UNO      VARCHAR2(4 BYTE),
      OCATD    VARCHAR2(11 BYTE)
    )
    TABLESPACE SYSTEM
    PCTUSED    40
    PCTFREE    10
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        1
                FREELIST GROUPS  1
                BUFFER_POOL      DEFAULT
               )
    LOGGING 
    NOCOMPRESS 
    NOCACHE
    NOPARALLEL
    NOMONITORING');
  
    dbms_output.put_line('������������� ������� �������!');
    dbms_output.put_line('--------------------');
    p_error := 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_error := 1;
      dbms_output.put_line('������!!! ������������� ������� �� �������');
      dbms_output.put_line('--------------------');
  END;

  /*************************************************************************************/
  --��������� �� ��������� �������
  PROCEDURE run_load_to_temp(p_error OUT NUMBER) IS
    exc_temp_socrbase EXCEPTION;
    exc_temp_kladr    EXCEPTION;
    exc_temp_street   EXCEPTION;
  BEGIN
    --��������� ������ � ������� TEMP_SOCRBASE
    BEGIN
      dbms_output.put_line('��������� ������ � ������� TEMP_SOCRBASE');
      load_table('WW_DBF_FOLDER', 'SOCRBASE.DBF', 'TEMP_SOCRBASE');
      dbms_output.put_line('...���������');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE exc_temp_socrbase;
    END;
  
    --��������� ������ � ������� TEMP_KLADR
    BEGIN
      dbms_output.put_line('��������� ������ � ������� TEMP_KLADR');
      load_table('WW_DBF_FOLDER', 'KLADR.DBF', 'TEMP_KLADR');
      dbms_output.put_line('...���������');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE exc_temp_kladr;
    END;
  
    --��������� ������ � ������� TEMP_SOCRSTREETBASE
    BEGIN
      dbms_output.put_line('��������� ������ � ������� TEMP_STREET');
      load_table('WW_DBF_FOLDER', 'STREET.DBF', 'TEMP_STREET');
      dbms_output.put_line('...���������');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE exc_temp_street;
    END;
    p_error := 0;
    COMMIT;
  EXCEPTION
    WHEN exc_temp_socrbase THEN
      p_error := 1;
      dbms_output.put_line('������!!! ������ � ������������� ������� �� ���������. ');
      dbms_output.put_line('��������� ������� � ������������ �������� ������ SOCRBASE.DBF � TEMP_SOCRBASE');
      dbms_output.put_line('--------------------');
      ROLLBACK;
    WHEN exc_temp_kladr THEN
      p_error := 1;
      dbms_output.put_line('������!!! ������ � ������������� ������� �� ���������. ');
      dbms_output.put_line('��������� ������� � ������������ �������� ������ KLADR.DBF � TEMP_KLADR');
      dbms_output.put_line('--------------------');
      ROLLBACK;
    WHEN exc_temp_street THEN
      p_error := 1;
      dbms_output.put_line('������!!! ������ � ������������� ������� �� ���������. ');
      dbms_output.put_line('��������� ������� � ������������ �������� ������ STREET.DBF � TEMP_STREET');
      dbms_output.put_line('--------------------');
      ROLLBACK;
  END;

  /*************************************************************************************/
  --���������, ������� ��������� �������� ������ � ���� ���� �� �����:
  PROCEDURE run_load
  (
    p_reload_table        IN NUMBER DEFAULT 0
   ,p_reload_to_temp      IN NUMBER DEFAULT 0
   ,p_recreate_temp_table IN NUMBER DEFAULT 0
  ) IS
    p_error      NUMBER(1) := 0;
    p_begin_date TIMESTAMP;
  BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    p_begin_date := systimestamp;
    --�������� ������������� ������
    IF p_recreate_temp_table = 1
    THEN
      create_temp_tables(p_error);
    END IF;
  
    --��������� �� ��������� �������
    IF (p_reload_to_temp = 1)
       AND (p_error = 0)
    THEN
      run_load_to_temp(p_error);
    END IF;
  
    --��������� �� ��������� �������
    IF (p_error = 0)
    THEN
      run_load_from_temp(p_error, p_reload_table);
    END IF;
  
    DBMS_OUTPUT.put_line('�������� ��������: ' || TO_CHAR(p_begin_date, 'DD.MM.YYYY HH24:MI:SS'));
    DBMS_OUTPUT.put_line('�������� �����������: ' || TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
    DBMS_OUTPUT.put_line('����� ����������: ' ||
                         to_char(extract(minute FROM(systimestamp - p_begin_date)), '00') || ':' ||
                         to_char(extract(SECOND FROM(systimestamp - p_begin_date)), '00'));
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('������!!! ������ ��� ���������� ��������� RUN_LOAD');
      DBMS_OUTPUT.put_line('�������� ��������: ' || TO_CHAR(p_begin_date, 'DD.MM.YYYY HH24:MI:SS'));
      DBMS_OUTPUT.put_line('�������� ����������: ' || TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
      DBMS_OUTPUT.put_line('����� ����������: ' ||
                           to_char(extract(minute FROM(systimestamp - p_begin_date)), '00') || ':' ||
                           to_char(extract(SECOND FROM(systimestamp - p_begin_date)), '00'));
  END;

END;
/

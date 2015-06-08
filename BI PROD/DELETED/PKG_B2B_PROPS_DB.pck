CREATE OR REPLACE PACKAGE PKG_B2B_PROPS_DB_FRM IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 01.10.2012 15:41:39
  -- Purpose : ������ �� ������������ "���� ������" ��� ��������� �������������� � B2B

  -- ���������� ������
  -- par_db_brief - �����������
  -- par_db_name  - ��������
  -- �� ������    - ID ������
  FUNCTION insert_record
  (
    par_db_brief VARCHAR2
   ,par_db_name  VARCHAR2
  ) RETURN NUMBER;

  -- ����������� ������
  -- par_b2b_props_db_id - ID ������
  -- par_db_brief        - �����������
  -- par_db_name         - ��������
  PROCEDURE update_record
  (
    par_b2b_props_db_id NUMBER
   ,par_db_brief        VARCHAR2
   ,par_db_name         VARCHAR2
  );

  -- �������� ������
  -- par_b2b_props_db_id - ID ������
  PROCEDURE delete_record(par_b2b_props_db_id NUMBER);

END PKG_B2B_PROPS_DB_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_B2B_PROPS_DB_FRM IS

  -- ���������� ������
  -- par_db_brief - �����������
  -- par_db_name  - ��������
  -- �� ������    - ID ������
  FUNCTION insert_record
  (
    par_db_brief VARCHAR2
   ,par_db_name  VARCHAR2
  ) RETURN NUMBER IS
    v_b2b_props_db_id NUMBER;
  BEGIN
    SELECT sq_t_b2b_props_db.nextval INTO v_b2b_props_db_id FROM dual;
  
    INSERT INTO ven_t_b2b_props_db
      (t_b2b_props_db_id, db_brief, db_name)
    VALUES
      (v_b2b_props_db_id, par_db_brief, par_db_name);
  
    RETURN v_b2b_props_db_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'���������� ������ ���������� ��-�� ������������ ��������/����������� ��!');
  END insert_record;

  -- ����������� ������
  -- par_b2b_props_db_id - ID ������
  -- par_db_brief        - �����������
  -- par_db_name         - ��������
  PROCEDURE update_record
  (
    par_b2b_props_db_id NUMBER
   ,par_db_brief        VARCHAR2
   ,par_db_name         VARCHAR2
  ) IS
  BEGIN
    UPDATE ven_t_b2b_props_db db
       SET db.db_brief = par_db_brief
          ,db.db_name  = par_db_name
     WHERE db.t_b2b_props_db_id = par_b2b_props_db_id;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      raise_application_error(-20001
                             ,'����������� ������ ���������� ��-�� ������������ ��������/����������� ��!');
  END update_record;

  -- �������� ������
  -- par_b2b_props_db_id - ID ������
  PROCEDURE delete_record(par_b2b_props_db_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_b2b_props_db db WHERE db.t_b2b_props_db_id = par_b2b_props_db_id;
  END delete_record;

END PKG_B2B_PROPS_DB_FRM;
/

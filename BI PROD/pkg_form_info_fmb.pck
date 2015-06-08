CREATE OR REPLACE PACKAGE pkg_form_info_fmb IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 11.07.2014 17:50:01
  -- Purpose : 

  -- Public type declarations
  TYPE t_info_record IS RECORD(
     block_name VARCHAR2(32767)
    ,item_name  VARCHAR2(32767)
    ,VALUE      VARCHAR2(32767));
  TYPE t_info IS TABLE OF t_info_record;

  gv_records t_info;

  PROCEDURE clear;

  PROCEDURE add_record
  (
    par_block_name VARCHAR2
   ,par_item_name  VARCHAR2
   ,par_value      VARCHAR2
  );

  FUNCTION get_records RETURN t_info
    PIPELINED;

  PROCEDURE add_delimiter;

END pkg_form_info_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_form_info_fmb IS

  PROCEDURE clear IS
  BEGIN
    gv_records := t_info();
  END clear;

  PROCEDURE add_record
  (
    par_block_name VARCHAR2
   ,par_item_name  VARCHAR2
   ,par_value      VARCHAR2
  ) IS
    v_record t_info_record;
  BEGIN
    v_record.block_name := par_block_name;
    v_record.item_name  := par_item_name;
    v_record.value      := par_value;
  
    gv_records.extend;
    gv_records(gv_records.last) := v_record;
  END add_record;

  PROCEDURE add_delimiter IS
  BEGIN
    add_record('///*************************'
              ,'***************************************'
              ,'*********************************************************************************///');
  END add_delimiter;

  FUNCTION get_records RETURN t_info
    PIPELINED IS
  BEGIN
    IF gv_records IS NOT NULL
    THEN
      FOR i IN 1 .. gv_records.count
      LOOP
        PIPE ROW(gv_records(i));
      END LOOP;
    END IF;
  
    RETURN;
  END get_records;

END pkg_form_info_fmb;
/

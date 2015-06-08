CREATE OR REPLACE PACKAGE pkg_distibution_risks IS

  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 14.02.2013 12:17:58
  -- Purpose : 

  PROCEDURE delete_distibution_risks(par_load_csv_list_id NUMBER);

  PROCEDURE import_distibution_risks_load(par_load_file_id NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_distibution_risks IS

  c_error            CONSTANT NUMBER(1) := -1;
  c_not_loaded       CONSTANT NUMBER(1) := 0;
  c_loaded           CONSTANT NUMBER(1) := 1;
  c_part_loaded      CONSTANT NUMBER(1) := 2;
  c_not_need_to_load CONSTANT NUMBER(1) := 3;
  c_checked          CONSTANT NUMBER(1) := 4;

  PROCEDURE delete_distibution_risks(par_load_csv_list_id NUMBER) IS
  BEGIN
    --очищаем таблицу для построения отчета
    DELETE FROM distibution_risks;
    COMMIT;
  END delete_distibution_risks;

  PROCEDURE import_distibution_risks_load(par_load_file_id NUMBER) IS
  BEGIN
    -- если проверен
    INSERT INTO distibution_risks
      (pol_header_id
      ,pol_num
      ,prem_percent
      ,prem
      ,agent_number
      ,agent_name
      ,bonus_type
      ,otch_period
      ,date_register)
      SELECT lf.val_1
            ,lf.val_2
            ,lf.val_3
            ,lf.val_4
            ,lf.val_5
            ,lf.val_6
            ,lf.val_7
            ,lf.val_8
            ,lf.val_9
        FROM load_file_rows lf
       WHERE lf.load_file_id = par_load_file_id
         AND lf.is_checked = 1
         AND lf.row_status = c_checked;
  
    --удаляем строку из универсального загрузчика
    DELETE FROM load_file_rows lf
     WHERE lf.load_file_id = par_load_file_id
       AND lf.is_checked = 1
       AND lf.row_status = c_checked;
  
  END import_distibution_risks_load;

/*PROCEDURE import_distibution_risks_load(par_load_file_rows_id NUMBER) IS
    v_row_status NUMBER;
  BEGIN
    -- если проверен
    INSERT INTO distibution_risks
      (pol_header_id
      ,pol_num
      ,prem_percent
      ,prem
      ,agent_number
      ,agent_name
      ,bonus_type
      ,otch_period
      ,date_register)
      SELECT lf.val_1
            ,lf.val_2
            ,lf.val_3
            ,lf.val_4
            ,lf.val_5
            ,lf.val_6
            ,lf.val_7
            ,lf.val_8
            ,lf.val_9
        FROM load_file_rows lf
       WHERE lf.load_file_rows_id = par_load_file_rows_id;
    --помечаем статус, загружен
    \*UPDATE load_file_rows lf
      SET lf.row_status  = pkg_load_file_to_table.get_loaded
         ,lf.row_comment = 'Запись загружена'
    WHERE lf.load_file_rows_id = par_load_file_rows_id;*\
  
    --удаляем строку из универсального загрузчика
    DELETE FROM load_file_rows lf WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
  END import_distibution_risks_load;*/

BEGIN
  -- Initialization
  NULL;
END;
/

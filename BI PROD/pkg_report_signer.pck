CREATE OR REPLACE PACKAGE pkg_report_signer IS

  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 23.04.2014 12:54:16
  -- Purpose : Пакет для работы с подписантами в отчетах

  TYPE typ_signer IS RECORD(
     id                    t_signer.t_signer_id%TYPE
    ,NAME                  t_signer.contact_name%TYPE
    ,name_genetive         t_signer.contact_name%TYPE
    ,procuratory           t_signer.procuratory_num%TYPE
    ,job_position          t_job_position.position_name%TYPE
    ,job_position_genitive t_job_position.genitive_position_name%TYPE
    ,image_sign            t_signer.image_sign_jpg%TYPE
    ,procuratory_num       t_signer.procuratory_num%TYPE
    ,short_name            t_signer.contact_name%TYPE
    ,image_sign_jpg        t_signer.image_sign_jpg%TYPE
    ,stamp_jpg             t_signer.stamp_jpg%TYPE);

  /* Получает record данных подписанта по id отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_rep_report_id - id отчета
  */
  FUNCTION get_signer_id_by_rep_id(par_rep_report_id rep_report.rep_report_id%TYPE) RETURN typ_signer;

  /* Получает record данных  подписанта по exe_name отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_report_exe_name - exe_name отчета
  */
  FUNCTION get_signer_id_by_exe_name(par_report_exe_name rep_report.exe_name%TYPE) RETURN typ_signer;

  /* Получает record данных  подписанта по наим. отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_report_rep_name - наим. отчета
  */
  FUNCTION get_signer_id_by_rep_name(par_report_rep_name rep_report.name%TYPE) RETURN typ_signer;

  /* Добвавляет подписанта в очет
  * @autor Владимир Чирков 
  * @param par_t_signer_id - id подписанта
  * @param par_report_id - id отчета
  */
  PROCEDURE add_signer_to_report
  (
    par_t_signer_id t_report_signer.t_signer_id%TYPE
   ,par_report_id   t_report_signer.report_id%TYPE
  );

  PROCEDURE add_signer_to_report
  (
    par_t_signer_id     t_report_signer.t_signer_id%TYPE
   ,par_report_exe_name rep_report.exe_name%TYPE
  );

END pkg_report_signer;
/
CREATE OR REPLACE PACKAGE BODY pkg_report_signer IS
  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 23.04.2014 12:54:16
  -- Purpose : Пакет для работы с подписантами в отчетах

  /* Получает record данных подписанта по id отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_rep_report_id - id отчета
  */
  FUNCTION get_signer_id_by_rep_id(par_rep_report_id rep_report.rep_report_id%TYPE) RETURN typ_signer IS
    v_signer typ_signer;
  BEGIN
    BEGIN
      SELECT s.t_signer_id
            ,s.contact_name
            ,pkg_contact.get_fio_case(s.contact_name, 'Р')
            ,s.procuratory_num
            ,jp.position_name
            ,jp.genitive_position_name
            ,s.image_sign
            ,s.procuratory_num
            ,pkg_contact.get_fio_fmt(s.contact_name, 4) short_name
            ,s.image_sign_jpg
            ,s.stamp_jpg
        INTO v_signer.id
            ,v_signer.name
            ,v_signer.name_genetive
            ,v_signer.procuratory
            ,v_signer.job_position
            ,v_signer.job_position_genitive
            ,v_signer.image_sign
            ,v_signer.procuratory_num
            ,v_signer.short_name
            ,v_signer.image_sign_jpg
            ,v_signer.stamp_jpg
        FROM rep_report      r
            ,t_report_signer sg
            ,t_job_position  jp
            ,t_signer        s
       WHERE 1 = 1
         AND r.rep_report_id = sg.report_id
         AND s.job_position_id = jp.t_job_position_id
         AND jp.is_enabled = 1
         AND s.t_signer_id = sg.t_signer_id
         AND r.rep_report_id = par_rep_report_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
      WHEN too_many_rows THEN
        ex.raise('При определении id подписанта по id отчета найдено несколько подписантов');
    END;
    RETURN v_signer;
  
  END get_signer_id_by_rep_id;

  /* Получает record данных подписанта по exe_name отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_report_exe_name - exe_name отчета
  */
  FUNCTION get_signer_id_by_exe_name(par_report_exe_name rep_report.exe_name%TYPE) RETURN typ_signer IS
    v_signer        typ_signer;
    v_rep_report_id NUMBER;
  BEGIN
    BEGIN
      SELECT rr.rep_report_id
        INTO v_rep_report_id
        FROM ins.rep_report rr
       WHERE rr.exe_name = par_report_exe_name;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
      WHEN too_many_rows THEN
        ex.raise('При определении id отчета по exe_name найдено несколько записей');
    END;
  
    v_signer := get_signer_id_by_rep_id(v_rep_report_id);
  
    RETURN v_signer;
  
  END get_signer_id_by_exe_name;

  /* Получает record данных  подписанта по наим. отчета и наим. структурной единицы
  * @autor Владимир Чирков 
  * @param par_report_rep_name - наим. отчета
  */
  FUNCTION get_signer_id_by_rep_name(par_report_rep_name rep_report.name%TYPE) RETURN typ_signer IS
    v_signer        typ_signer;
    v_rep_report_id NUMBER;
  BEGIN
    BEGIN
      SELECT rr.rep_report_id
        INTO v_rep_report_id
        FROM ins.rep_report rr
       WHERE rr.name = par_report_rep_name;
    
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
      WHEN too_many_rows THEN
        ex.raise('При определении id отчета по его наименованию найдено несколько записей');
    END;
  
    v_signer := get_signer_id_by_rep_id(v_rep_report_id);
  
    RETURN v_signer;
  END get_signer_id_by_rep_name;

  /* Добвавляет подписанта в очет
  * @autor Владимир Чирков 
  * @param par_t_signer_id - id подписанта
  * @param par_report_id - id отчета
  */
  PROCEDURE add_signer_to_report
  (
    par_t_signer_id t_report_signer.t_signer_id%TYPE
   ,par_report_id   t_report_signer.report_id%TYPE
  ) IS
  BEGIN
    dml_t_report_signer.insert_record(par_t_signer_id, par_report_id);
  END add_signer_to_report;

  PROCEDURE add_signer_to_report
  (
    par_t_signer_id     t_report_signer.t_signer_id%TYPE
   ,par_report_exe_name rep_report.exe_name%TYPE
  ) IS
    v_rep_report_id rep_report.rep_report_id%TYPE;
  BEGIN
    BEGIN
      SELECT rr.rep_report_id
        INTO v_rep_report_id
        FROM rep_report rr
       WHERE rr.exe_name = par_report_exe_name;
    EXCEPTION
      WHEN no_data_found THEN
        ex.raise('Не удалось найти отчет по exe_name');
      WHEN too_many_rows THEN
        ex.raise('Для заданного exe_name найдено несколько отчетов. Воспользуйтесь перегруеженой функцией с ИД отчета в виде параметра');
    END;
  
    add_signer_to_report(par_t_signer_id => par_t_signer_id, par_report_id => v_rep_report_id);
  END add_signer_to_report;

BEGIN
  NULL;
END pkg_report_signer;
/

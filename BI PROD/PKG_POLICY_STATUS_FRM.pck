CREATE OR REPLACE PACKAGE pkg_policy_status_frm IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 03.05.2012 12:40:24
  -- Purpose : Содержит бизнес-логику формы POLICY_STATUS

  /*
     Байтин А.
     Часть триггера :CTRL.SET_STATUS_BUTT.WHEN-BUTTON-PRESSED
     Добавляет код для обработки очереди статусов в очередь отложенных задач
  */
  PROCEDURE insert_queue;

  /*
     Байтин А.
     Часть триггер :DB_QUEUE.BTN_CLEAR_ERRS.WHEN-BUTTON-PRESSED
     Очищает очередь от записей с ошибками
  */
  PROCEDURE clear_errors_from_queue;

  /*
     Байтин А.
     Возвращает количество записей с ошибками/всего
  */
  PROCEDURE get_total_values
  (
    par_total_errors  OUT NUMBER
   ,par_total_records OUT NUMBER
  );

  /* sergey.ilyushkin   18/06/2012 
    Процедура проверки строк загруженного файла со списком договоров
    @param par_Load_File_Rows_ID - ИД строки
  */
  /* sergey.ilyushkin   18/06/2012 
    Процедура проверки строк загруженного файла со списком договоров
    @param par_Load_File_Rows_ID - ИД строки
    @param par_Row_Status - Номер статуса строки после проверки
    @param par_Row_Comment - Описание состояния строки после проверки
  */
  PROCEDURE check_load_files_rows
  (
    par_load_file_rows_id IN NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  );

  /* sergey.ilyushkin   18/06/2012 
    Процедура обработки строк загруженного файла со списком договоров
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE set_policy_list(par_load_file_rows_id NUMBER);

  /*
    Байтин А.
    Заявка 197124
    Выполняет поиск договоров по ИДС для группового перевода статуса
  */
  PROCEDURE check_load_files_rows_ids
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  );

END pkg_policy_status_frm;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_status_frm IS

  /*
     Байтин А.
     Часть триггера :CTRL.SET_STATUS_BUTT.WHEN-BUTTON-PRESSED
     Добавляет код для обработки очереди статусов в очередь отложенных задач
  */
  PROCEDURE insert_queue IS
  BEGIN
    pkg_scheduler.insert_queue(par_job_name => 'DOC_SET_STATUS'
                              ,par_plsql    => 'for vr_rec in (select document_id
                      ,doc_status_id
                      ,err_message
                      ,rowid          as rid
                      ,rownum         as rn
                  from policy_status_queue
                 where err_message is null
               )
 loop
   begin
     savepoint before_status;
		 dbms_application_info.set_client_info(''Обрабатывается: ''||to_char(vr_rec.document_id));
     doc.set_doc_status(p_doc_id    => vr_rec.document_id
                       ,p_status_id => vr_rec.doc_status_id
                       );
     if mod(vr_rec.rn,1000) = 0 then
       dbms_application_info.set_client_info(''Обрабатывается: ''||to_char(vr_rec.document_id)||'' Обработано ''||to_char(vr_rec.rn)||'' записей'');
     end if;
     delete from policy_status_queue 
           where err_message is null
             and rowid = vr_rec.rid;
     commit;
   exception
     when others then
       rollback to before_status;
       vr_rec.err_message := substr(sqlerrm,1,500);
       update policy_status_queue 
          set err_message = vr_rec.err_message
        where rowid = vr_rec.rid;
       commit;
   end;
 end loop;');
  END insert_queue;

  /*
     Байтин А.
     Часть триггер :DB_QUEUE.BTN_CLEAR_ERRS.WHEN-BUTTON-PRESSED
     Очищает очередь от записей с ошибками
  */
  PROCEDURE clear_errors_from_queue IS
  BEGIN
    DELETE FROM policy_status_queue WHERE err_message IS NOT NULL;
  END clear_errors_from_queue;

  /*
     Байтин А.
     Возвращает количество записей с ошибками/всего
  */
  PROCEDURE get_total_values
  (
    par_total_errors  OUT NUMBER
   ,par_total_records OUT NUMBER
  ) IS
  BEGIN
    SELECT COUNT(*)
          ,COUNT(err_message)
      INTO par_total_records
          ,par_total_errors
      FROM policy_status_queue;
  END get_total_values;

  /* sergey.ilyushkin   18/06/2012 
    Процедура проверки строк загруженного файла со списком договоров
    @param par_Load_File_Rows_ID - ИД строки
    @param par_Row_Status - Номер статуса строки после проверки
    @param par_Row_Comment - Описание состояния строки после проверки
  */
  PROCEDURE check_load_files_rows
  (
    par_load_file_rows_id IN NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  ) IS
    v_pol_num     VARCHAR2(1000) := NULL;
    v_first_name  VARCHAR2(1000) := NULL;
    v_last_name   VARCHAR2(1000) := NULL;
    v_middle_name VARCHAR2(1000) := NULL;
    v_status      VARCHAR2(1000) := NULL;
    v_policy_id   NUMBER := NULL;
  
  BEGIN
    FOR i IN (SELECT * FROM load_file_rows WHERE load_file_rows_id = par_load_file_rows_id)
    LOOP
      BEGIN
        SELECT pp.pol_num
              ,con.first_name
              ,con.middle_name
              ,con.name
              ,doc.get_doc_status_name(pp.policy_id)
              ,pp.policy_id
          INTO v_pol_num
              ,v_first_name
              ,v_middle_name
              ,v_last_name
              ,v_status
              ,v_policy_id
          FROM p_policy           pp
              ,p_policy_contact   ppc
              ,t_contact_pol_role tcpr
              ,contact            con
              ,p_pol_header       pph
         WHERE pp.pol_num = TRIM(i.val_4)
           AND ppc.policy_id = pp.policy_id
           AND pph.policy_header_id = pp.pol_header_id
           AND pp.policy_id = pph.last_ver_id
           AND tcpr.id = ppc.contact_policy_role_id
           AND doc.get_doc_status_brief(pph.last_ver_id) != 'CANCEL' --Заявка 222821
           AND upper(tcpr.brief) = 'СТРАХОВАТЕЛЬ'
           AND con.contact_id = ppc.contact_id
           AND upper(REPLACE(REPLACE(con.obj_name_orig, ' '), '"')) =
               upper(REPLACE(REPLACE(i.val_1, ' '), '"') || REPLACE(REPLACE(i.val_2, ' '), '"') ||
                     REPLACE(REPLACE(i.val_3, ' '), '"'));
      
        IF (upper(i.val_1) <> upper(v_last_name))
           OR (upper(i.val_2) <> upper(v_first_name))
           OR (upper(i.val_3) <> upper(v_middle_name))
        THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          par_row_comment := 'Не найден по ФИО';
        END IF;
      
        IF upper(i.val_5) <> upper(v_status)
        THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          par_row_comment := 'Не найден по статусу ДС';
        END IF;
      
        IF (par_row_status <> pkg_load_file_to_table.get_error)
           OR (par_row_status IS NULL)
        THEN
          par_row_status  := pkg_load_file_to_table.get_checked;
          par_row_comment := 'Договор найден по ДС';
          UPDATE load_file_rows
             SET ure_id = 283
                ,uro_id = v_policy_id
           WHERE load_file_rows_id = par_load_file_rows_id;
        END IF;
      
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          par_row_comment := 'Не найден по номеру ДС';
        WHEN too_many_rows THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          par_row_comment := 'Найдено более одного договора';
      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END check_load_files_rows;

  /* sergey.ilyushkin   18/06/2012 
    Процедура обработки строк загруженного файла со списком договоров
    @param par_Load_File_Rows_ID - ИД строки
  */
  PROCEDURE set_policy_list(par_load_file_rows_id NUMBER) IS
    v_policy_id NUMBER := NULL;
  BEGIN
    UPDATE load_file_rows SET is_checked = 1 WHERE load_file_rows_id = par_load_file_rows_id;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END set_policy_list;

  /*
    Байтин А.
    Заявка 197124
    Выполняет поиск договоров по ИДС для группового перевода статуса
  */
  PROCEDURE check_load_files_rows_ids
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  ) IS
    v_policy_id NUMBER;
  BEGIN
    FOR i IN (SELECT lf.val_1 FROM load_file_rows lf WHERE lf.load_file_rows_id = par_load_file_rows_id)
    LOOP
      BEGIN
        SELECT ph.last_ver_id INTO v_policy_id FROM p_pol_header ph WHERE ph.ids = i.val_1;
      
        par_row_status  := pkg_load_file_to_table.get_checked;
        par_row_comment := 'Договор найден по ИДС';
      
        UPDATE load_file_rows
           SET ure_id = 283
              ,uro_id = v_policy_id
         WHERE load_file_rows_id = par_load_file_rows_id;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          par_row_comment := 'Не найден по ИДС';
      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END check_load_files_rows_ids;

END pkg_policy_status_frm;
/

CREATE OR REPLACE PROCEDURE ins.sp_rep_doc_bank_to_mail IS
  v_file_clob    CLOB;
  v_files        pkg_email.t_files := pkg_email.t_files();
  v_blob_offset  NUMBER := 1;
  v_clob_offset  NUMBER := 1;
  v_warning      NUMBER;
  v_query        VARCHAR2(2000);
  v_row_count    PLS_INTEGER;
  v_lang_context INTEGER := dbms_lob.default_lang_ctx;
  c_to           pkg_email.t_recipients := pkg_email.t_recipients('Rustam.Ahtyamov@Renlife.com');
  --  c_cc           pkg_email.t_recipients := pkg_email.t_recipients('Irina.Dobrohotova@renlife.com');
BEGIN

  v_query := 'SELECT due_date
      ,num
      ,doc_templ_name
      ,collection_method_desc
      ,fund_brief
      ,in_amount
      ,out_amount
      ,comm_amount
      ,set_off_amount
      ,contact_name
      ,doc_status_name
      ,''cч.''||to_char(acc_company) as acc_company
      ,''cч.''||to_char(acc_client) as acc_client
      ,note
      ,set_off_state_descr
  FROM v_doc_bank t
 WHERE t.contact_name = ''ООО "ХКФ БАНК"''
   AND t.acc_company = ''40701810600010000030''
   AND t.doc_status_name <> ''Аннулирован''
   AND t.due_date <= trunc(SYSDATE)-7
   AND t.in_amount <> t.set_off_amount';

  dbms_lob.createtemporary(lob_loc => v_file_clob, cache => TRUE);
  pkg_csv.select_to_csv(par_select        => v_query
                       ,par_header_option => pkg_csv.gc_header_from_parameter
                       ,par_header        => tt_one_col('Дата'
                                                       ,'Номер'
                                                       ,'Шаблон документа'
                                                       ,'Способ оплаты'
                                                       ,'Валюта'
                                                       ,'Приход'
                                                       ,'Расход'
                                                       ,'Комиссия'
                                                       ,'Зачтено'
                                                       ,'Плательщик / Получатель'
                                                       ,'Статус'
                                                       ,'Счет компании'
                                                       ,'Счет контрагента'
                                                       ,'Примечание'
                                                       ,'Комментарий')
                       ,par_csv           => v_file_clob
                       ,par_row_count     => v_row_count);
  IF v_row_count > 0
  THEN
    v_files.extend(1);
    -- Название файла
    v_files(1).v_file_name := 'Неразнесенные платежи.csv';
    v_files(1).v_file_type := tt_file.get_mime_type(par_file_name_or_ext => v_files(1).v_file_name);
    dbms_lob.createtemporary(lob_loc => v_files(1).v_file, cache => TRUE);
    dbms_lob.converttoblob(src_clob     => v_file_clob
                          ,dest_lob     => v_files(1).v_file
                          ,amount       => dbms_lob.lobmaxsize
                          ,dest_offset  => v_blob_offset
                          ,src_offset   => v_clob_offset
                          ,blob_csid    => dbms_lob.default_csid
                          ,lang_context => v_lang_context
                          ,warning      => v_warning);
    pkg_email.send_mail_with_attachment(par_to => c_to
                                        --                                       ,par_cc         => c_cc
                                       ,par_subject    => 'Неразнесенные платежи от ' ||
                                                          to_char(SYSDATE, 'dd.mm.yyyy')
                                       ,par_text       => 'Неразнесенные платежи от ' ||
                                                          to_char(SYSDATE, 'dd.mm.yyyy')
                                       ,par_attachment => v_files);
    dbms_lob.freetemporary(lob_loc => v_files(1).v_file);
  END IF;

  dbms_lob.freetemporary(lob_loc => v_file_clob);

END sp_rep_doc_bank_to_mail;
/

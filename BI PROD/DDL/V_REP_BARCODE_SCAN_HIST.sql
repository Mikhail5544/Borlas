CREATE OR REPLACE VIEW V_REP_BARCODE_SCAN_HIST AS
SELECT bss.t_barcode_scan_sessn_id
      ,bss.sys_user_id
      ,bsh.barcode_num "№ штрих-кода"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          CASE substr(bsh.barcode_num, 1, 2)
            WHEN '01' THEN
             'Полис'
            WHEN '02' THEN
             'Заявление'
            WHEN '03' THEN
             'Квитанция'
            ELSE
             'Тип не определен'
          END
         ELSE
          NULL
       END "Тип документа"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 3, 10)
         ELSE
          NULL
       END "Номер документа"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 13, 3)
         ELSE
          NULL
       END "Номер версии"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          substr(bsh.barcode_num, 16, 4)
         ELSE
          NULL
       END "Контрольное число"
       ,(SELECT nvl(c.obj_name_orig, su.sys_user_name)
          FROM sys_user su
              ,contact  c
         WHERE su.contact_id = c.contact_id(+)
           AND su.sys_user_id = bss.sys_user_id) "ФИО пользователя"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          'Успешно'
         WHEN 1 THEN
          'Документ не найден'
         WHEN 2 THEN
          'Ошибка сканирования'
         ELSE
          'Статус не определен'
       END "Результат"
       ,trunc(bss.start_date) "Дата сканирования"
       ,CASE bsh.session_status_id
         WHEN 0 THEN
          (SELECT ph.ids
             FROM bso          b
                 ,p_pol_header ph
            WHERE b.pol_header_id = ph.policy_header_id
              AND b.barcode_num = bsh.barcode_num)
         ELSE
          NULL
       END "ИДС"
       ,(SELECT NAME FROM doc_status_ref WHERE doc_status_ref_id = bss.src_doc_status_ref_id) "Статус ИЗ"
       ,(SELECT NAME FROM doc_status_ref WHERE doc_status_ref_id = bss.dest_doc_status_ref_id) "Статус В"
       ,bsh.change_status_msg "Результат перевода статуса"
       ,(SELECT vi.contact_name
          FROM bso                 b
              ,p_policy            pp
              ,v_pol_issuer        vi
         WHERE b.policy_id = pp.policy_id
           AND b.barcode_num = bsh.barcode_num
           AND pp.policy_id = vi.policy_id) "ФИО страхователя"
  FROM t_barcode_scan_hist  bsh
      ,t_barcode_scan_sessn bss
 WHERE bsh.t_barcode_scan_sessn_id = bss.t_barcode_scan_sessn_id;

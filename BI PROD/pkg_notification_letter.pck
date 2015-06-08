CREATE OR REPLACE PACKAGE pkg_notification_letter IS

  -- Author  : Черных М.
  -- Created : 23.09.2014
  -- Purpose : Печать писем напоминаний

  -- Author  : Черных М.
  -- Created : 23.09.2014
  -- Purpose : Письмо-напоминание в льготный период с уведомлением
  PROCEDURE remind_in_grace_period
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Author  : Черных М.
  -- Created : 24.09.2014
  -- Purpose : Письмо-напоминание за 30 дней до оплаты
  PROCEDURE remind_30_days_before_pay
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Author  : Григорьев Ю.
  -- Created : 29.01.2015
  -- Purpose : Список страхователей, которым высылается письмо-напоминание в льготный период с уведомлением (Excel)

  PROCEDURE remind_in_grace_period_excel
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Author  : Григорьев Ю.
  -- Created : 29.01.2015
  -- Purpose : Список страхователей, которым высылается письмо-напоминание за 30 дней до оплаты (Excel)

  PROCEDURE remind_30days_before_pay_excel
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

END pkg_notification_letter;
/
CREATE OR REPLACE PACKAGE BODY pkg_notification_letter IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  -- Author  : Черных М.
  -- Created : 23.09.2014 
  -- Purpose : Письмо-напоминание в льготный период с уведомлением
  PROCEDURE remind_in_grace_period
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    vc_default_font_size CONSTANT NUMBER := 9;
    vc_one_shift_width   CONSTANT NUMBER := 10; --Сдвиг на один отступ
    vc_two_shift_width   CONSTANT NUMBER := vc_one_shift_width * 2; --Сдвиг на два отступ
  
    vc_receipt_space CONSTANT NUMBER := 28;
    vc_width_second  CONSTANT NUMBER := 130; --Ширина 2-й части квитанции
    v_is_first_letter BOOLEAN := TRUE; --Признак, что первое письмо
    /*Параметры старого отчета Report*/
    vp_sid           NUMBER; --ИД сессии пользователя, который печатает отчеты
    vp_report_id     NUMBER;
    vp_position_name VARCHAR2(500);
    vp_signer_name   VARCHAR2(500);
    vp_signer_id     NUMBER;
    vp_number        VARCHAR2(500); --Исходящий номер
    vnum             VARCHAR2(500);
    vsys_date        VARCHAR2(100);
    vp_month         VARCHAR2(100);
    vp_year          VARCHAR2(100);
  
    /*Данные для отчета*/
    CURSOR cur_rep_data
    (
      par_sessionid NUMBER
     ,par_number    VARCHAR2
    ) IS
    /*-----------с уведомлением----------*/
      SELECT rownum rec_number
            ,payment_period
            ,contact_name
            ,regexp_substr(contact_name, '\w+', 1, 2) || ' ' ||
             regexp_substr(contact_name, '\w+', 1, 3) || '!' contact_name_only
            ,contact_name || '!' contact_name_1
            ,address_name
            ,fadr
            ,CASE
               WHEN nvl(distr_name, 'X') <> 'X'
                    AND nvl(city_name, 'X') <> 'X' THEN
                city_name || ', ' || distr_name
               ELSE
                (CASE
                  WHEN nvl(distr_name, 'X') = 'X' THEN
                   city_name
                  ELSE
                   distr_name
                END)
             END city_name
            ,province_name
            ,region_name
            ,CASE
               WHEN nvl(country_name, 'X') <> 'X'
                    AND nvl(province_name, 'X') <> 'X' THEN
                province_name || ', ' || country_name
               ELSE
                (CASE
                  WHEN nvl(province_name, 'X') = 'X' THEN
                   country_name
                  ELSE
                   province_name
                END)
             END country_name
            ,distr_name
            ,zip
            ,code
            ,init_name
            ,grace_date
            ,ids
            ,amount
            ,fund
            ,grace_period
            ,grace_period_1
            ,dog_num
            ,pol_ser
            ,type_contact
            ,gender
            ,abz
            ,'При этом напоминаем Вам, что в соответствии с ' || usl1 ||
             ' на основании которых заключен' || chr(10) ||
             'договор страхования, возможность оплаты страхового взноса по Вашему договору ' ||
             'страхования сохраняется до окончания' || chr(10) || ' льготного периода, т.е. до ' ||
             grace_period || '.' usl1
            ,usl2 || ' ' || 'При этом датой ' || rast2 || ' ' || 'будет являться ' || grace_period_1 || '.' usl2
            ,rast1
            ,rast2
            ,sex
            ,'22' || lpad(par_number + rownum - 1, 6, '0') vhnum
            ,CASE mb
               WHEN 0 THEN
                TRIM(to_char(fee, '9999999990D00'))
               ELSE
                TRIM(to_char(amount, '9999999990D00'))
             END fee
            ,CASE
               WHEN payment_period = 'ежемесячный' THEN
                1
               ELSE
                (CASE
                  WHEN fcur = 'RUR' THEN
                   (CASE
                     WHEN (nvl(non_pay_amount, 0) + (CASE mb
                            WHEN 0 THEN
                             fee
                            ELSE
                             amount
                          END) - nvl(part_pay_amount, 0)) > 500 THEN
                      1
                     ELSE
                      0
                   END)
                  ELSE
                   (CASE
                     WHEN (nvl(non_pay_amount, 0) + (CASE mb
                            WHEN 0 THEN
                             fee
                            ELSE
                             amount
                          END) - nvl(part_pay_amount, 0)) >= 12 THEN
                      1
                     ELSE
                      0
                   END)
                END)
             END zadol
            ,TRIM(to_char(non_pay_amount, '9999999990D00')) non_pay_amount
            ,TRIM(to_char(part_pay_amount, '9999999990D00')) part_pay_amount
            ,CASE
               WHEN (nvl(non_pay_amount, 0)) > 0 THEN
                ', а также погасить задолженность по оплате предыдущих взносов '
               ELSE
                ' к ' || grace_date || '.'
             END usl01
            ,
             
             CASE
               WHEN (nvl(non_pay_amount, 0)) > 0 THEN
                'в размере ' || TRIM(to_char(non_pay_amount, '9999999990D00')) || ' ' || fund || ' к ' ||
                grace_date || '.'
               ELSE
                NULL
             END usl02
            ,
             
             CASE
               WHEN nvl(part_pay_amount, 0) > 0 THEN
                '          Однако по состоянию на ' || to_char(SYSDATE, 'dd.mm.yyyy') ||
                ' оплата очередного страхового взноса ' || (CASE
                  WHEN (nvl(non_pay_amount, 0)) > 0 THEN
                   'и имеющейся задолженности '
                  ELSE
                   ''
                END) || 'в ООО «СК «Ренессанс Жизнь»' || chr(10) || ' поступила в размере ' ||
                TRIM(to_char(part_pay_amount, '9999999990D00')) || ' ' || fund || '.'
               ELSE
                '          Однако по состоянию на ' || to_char(SYSDATE, 'dd.mm.yyyy') ||
                ' оплата очередного страхового взноса ' || (CASE
                  WHEN (nvl(non_pay_amount, 0)) > 0 THEN
                   'и имеющейся задолженности '
                  ELSE
                   ''
                END) || (CASE
                  WHEN (nvl(non_pay_amount, 0)) > 0 THEN
                   'в ООО «СК' || chr(10) || '«Ренессанс Жизнь» не поступила.'
                  ELSE
                   'в ООО «СК «Ренессанс Жизнь»' || chr(10) || ' не поступила.'
                END)
             END usl03
            ,TRIM(to_char(nvl(non_pay_amount, 0) + (CASE mb
                                                      WHEN 0 THEN
                                                       fee
                                                      ELSE
                                                       amount
                                                    END) - (nvl(part_pay_amount, 0))
                         ,'9999999990D00')) sum_zadol
            ,colm_flag
        FROM (SELECT
              
               (SELECT SUM(nvl(a.amount, 0)) -
                       SUM(nvl(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL), 0))
                  FROM document       d
                      ,ac_payment     a
                      ,doc_templ      dt
                      ,doc_doc        dd
                      ,p_policy       p
                      ,p_pol_header   pph
                      ,contact        c
                      ,doc_status     ds
                      ,doc_status_ref dsr
                 WHERE d.document_id = a.payment_id
                   AND d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND dd.child_id = d.document_id
                   AND dd.parent_id = p.policy_id
                   AND pph.policy_header_id = p.pol_header_id
                   AND a.contact_id = c.contact_id
                   AND ds.document_id = d.document_id
                   AND ds.start_date = (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                   AND dsr.name <> 'Аннулирован'
                   AND a.plan_date BETWEEN ph.start_date AND vlp.prev_due_date
                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                   AND p.pol_header_id = ph.policy_header_id) non_pay_amount
              ,(SELECT SUM(nvl(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL), 0))
                  FROM document       d
                      ,ac_payment     a
                      ,doc_templ      dt
                      ,doc_doc        dd
                      ,p_policy       p
                      ,p_pol_header   pph
                      ,contact        c
                      ,doc_status     ds
                      ,doc_status_ref dsr
                 WHERE d.document_id = a.payment_id
                   AND d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND dd.child_id = d.document_id
                   AND dd.parent_id = p.policy_id
                   AND pph.policy_header_id = p.pol_header_id
                   AND a.contact_id = c.contact_id
                   AND ds.document_id = d.document_id
                   AND ds.start_date = (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                   AND dsr.name NOT IN ('Аннулирован', 'Оплачен')
                   AND a.plan_date BETWEEN vlp.due_date AND vlp.due_date
                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                   AND p.pol_header_id = ph.policy_header_id) part_pay_amount
              ,
               
               vlp.payment_period
              ,ph.ids
              ,fd.brief fcur
              ,vlp.contact_name
              ,vlp.address_name
              ,vlp.fadr
              ,vlp.city_name
              ,vlp.province_name
              ,vlp.distr_name
              ,vlp.region_name
              ,vlp.country_name
              ,vlp.zip
              ,vlp.code
              ,vlp.mb
              ,vlp.init_name
              ,to_char(vlp.due_date, 'dd.mm.yyyy') grace_date
              ,vlp.sum_fee amount
              ,vlp.pay_amount_dog
              ,vlp.fund
              ,to_char(vlp.due_date + tper.period_value, 'dd.mm.yyyy') grace_period
              ,to_char(vlp.due_date + (tper.period_value + 1), 'dd.mm.yyyy') grace_period_1
              ,pp.pol_num dog_num
              ,CASE
                 WHEN length(pp.pol_num) > 6 THEN
                  substr(pp.pol_num, 1, 3)
                 ELSE
                  pp.pol_ser
               END pol_ser
              ,CASE
                 WHEN length(pp.pol_num) > 6 THEN
                  ''
                 ELSE
                  '          Так же сообщаем Вам, что в целях стандартизации процесса приема платежей, Вашему договору присвоен идентификационный номер ' ||
                  ph.ids ||
                  '. Просим Вас при оплате страховых взносов в назначении платежа вместо номера договора указывать данный идентификационный номер.'
               END abz
              ,vlp.type_contact
              ,vlp.gender
              ,CASE vlp.gender
                 WHEN 0 THEN
                  'Уважаемая'
                 WHEN 1 THEN
                  'Уважаемый'
                 ELSE
                  ''
               END sex
              ,SUM(nvl(pc.fee, 0)) fee
              ,CASE
                 WHEN ph.start_date < to_date('30.06.2007', 'dd.mm.yyyy') THEN
                  'Общими условиями страхования,'
                 WHEN ph.start_date BETWEEN to_date('30.06.2007', 'dd.mm.yyyy') AND
                      to_date('01.04.2009', 'dd.mm.yyyy') THEN
                  'Правилами страхования,'
                 WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy') THEN
                  'Полисными условиями,'
                 ELSE
                  ''
               END usl1
              ,CASE
                 WHEN ph.start_date < to_date('30.06.2007', 'dd.mm.yyyy') THEN
                  'п. 11.2.1 Общих условий страхования.'
                 WHEN ph.start_date BETWEEN to_date('30.06.2007', 'dd.mm.yyyy') AND
                      to_date('01.04.2009', 'dd.mm.yyyy') THEN
                  'п. 12.2.1 Правил страхования жизни.'
                 WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy')
                      AND substr(to_char(ph.ids), 1, 3) = '123' THEN
                  'п. 9.2.1. Полисных условий.'
                 WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy')
                      AND substr(to_char(ph.ids), 1, 3) <> '123' THEN
                  'п. 13.1. Полисных условий.'
                 ELSE
                  ''
               END usl2
              ,CASE
                 WHEN length(pp.pol_num) > 6 THEN
                  'прекращении'
                 ELSE
                  'расторжении'
               END rast1
              ,CASE
                 WHEN length(pp.pol_num) > 6 THEN
                  'прекращения'
                 ELSE
                  'расторжения'
               END rast2
              ,vlp.colm_flag
                FROM v_letters_payment   vlp
                    ,notif_letter_rep    nlr
                    ,p_pol_header        ph
                    ,fund                fd
                    ,p_policy            pp
                    ,t_period            tper
                    ,as_asset            a
                    ,p_cover             pc
                    ,t_prod_line_option  plo
               WHERE vlp.document_id = nlr.document_id
                 AND nlr.sessionid = par_sessionid
                 AND ph.policy_header_id = vlp.pol_header_id
                 AND pp.policy_id = ph.policy_id
                 AND pp.policy_id = a.p_policy_id
                 AND ph.fund_id = fd.fund_id
                 AND pp.payment_term_id != 1 --Единовременно
                    --        
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.brief != 'Penalty'
                 AND pc.status_hist_id <> 3
                 AND a.as_asset_id = pc.as_asset_id
                 AND pp.pol_privilege_period_id = tper.id(+)
               GROUP BY vlp.payment_period
                       ,ph.ids
                       ,vlp.contact_name
                       ,vlp.address_name
                       ,vlp.fadr
                       ,vlp.city_name
                       ,vlp.province_name
                       ,vlp.region_name
                       ,vlp.country_name
                       ,vlp.distr_name
                       ,vlp.zip
                       ,vlp.code
                       ,vlp.mb
                       ,vlp.init_name
                       ,to_char(vlp.due_date, 'dd.mm.yyyy')
                       ,vlp.due_date
                       ,vlp.prev_due_date
                       ,ph.policy_header_id
                       ,ph.start_date
                       ,vlp.sum_fee
                       ,vlp.pay_amount_dog
                       ,vlp.fund
                       ,to_char(vlp.due_date + tper.period_value, 'dd.mm.yyyy')
                       ,to_char(vlp.due_date + (tper.period_value + 1), 'dd.mm.yyyy')
                       ,pp.pol_num
                       ,CASE
                          WHEN length(pp.pol_num) > 6 THEN
                           substr(pp.pol_num, 1, 3)
                          ELSE
                           pp.pol_ser
                        END
                       ,vlp.type_contact
                       ,vlp.gender
                       ,fd.brief
                       ,CASE vlp.gender
                          WHEN 0 THEN
                           'Уважаемая'
                          WHEN 1 THEN
                           'Уважаемый'
                          ELSE
                           ''
                        END
                       ,CASE
                          WHEN ph.start_date < to_date('30.06.2007', 'dd.mm.yyyy') THEN
                           'Общими условиями страхования,'
                          WHEN ph.start_date BETWEEN to_date('30.06.2007', 'dd.mm.yyyy') AND
                               to_date('01.04.2009', 'dd.mm.yyyy') THEN
                           'Правилами страхования,'
                          WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy') THEN
                           'Полисными условиями,'
                          ELSE
                           ''
                        END
                       ,CASE
                          WHEN ph.start_date < to_date('30.06.2007', 'dd.mm.yyyy') THEN
                           'п. 11.2.1 Общих условий страхования,'
                          WHEN ph.start_date BETWEEN to_date('30.06.2007', 'dd.mm.yyyy') AND
                               to_date('01.04.2009', 'dd.mm.yyyy') THEN
                           'п. 12.2.1 Правил страхования жизни,'
                          WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy')
                               AND substr(to_char(ph.ids), 1, 3) = '123' THEN
                           'п. 9.2.1. Полисных условий,'
                          WHEN ph.start_date > to_date('01.04.2009', 'dd.mm.yyyy')
                               AND substr(to_char(ph.ids), 1, 3) <> '123' THEN
                           'п. 13.1. Полисных условий,'
                          ELSE
                           ''
                        END
                       ,CASE
                          WHEN length(pp.pol_num) > 6 THEN
                           'прекращении'
                          ELSE
                           'расторжении'
                        END
                       ,CASE
                          WHEN length(pp.pol_num) > 6 THEN
                           ''
                          ELSE
                           '          Так же сообщаем Вам, что в целях стандартизации процесса приема платежей, Вашему договору присвоен идентификационный номер ' ||
                           ph.ids ||
                           '. Просим Вас при оплате страховых взносов в назначении платежа вместо номера договора указывать данный идентификационный номер.'
                        END
                       ,CASE
                          WHEN length(pp.pol_num) > 6 THEN
                           'прекращения'
                          ELSE
                           'расторжения'
                        END
                       ,CASE
                          WHEN substr(par_number, 1, 3) = '000' THEN
                           to_number(substr(par_number, 4, 1))
                          WHEN substr(par_number, 1, 2) = '00' THEN
                           to_number(substr(par_number, 3, 2))
                          WHEN substr(par_number, 1, 1) = '0' THEN
                           to_number(substr(par_number, 2, 3))
                          WHEN substr(par_number, 1, 1) <> '0' THEN
                           to_number(par_number)
                        END
                       ,vlp.colm_flag
               ORDER BY vlp.contact_name);
    vr_rep_data cur_rep_data%ROWTYPE;
  
    /*Процедура для запуска перед вызовом отчета (старый BEFORE_REPORT тригггер)
    заполняет глобальные переменные процедуры
    */
    PROCEDURE beforereport IS
      /**/
      v_report_id     NUMBER;
      v_position_name VARCHAR2(2000);
      v_signer_name   VARCHAR2(600);
      v_signer_id     NUMBER;
    
    BEGIN
    
      BEGIN
        SELECT r.rep_report_id
          INTO v_report_id
          FROM ins.rep_report r
         WHERE r.exe_name = lower(gc_pkg_name || '.remind_in_grace_period');
      EXCEPTION
        WHEN no_data_found THEN
          v_report_id := 0;
      END;
      vp_report_id := v_report_id;
    
      BEGIN
        SELECT s.contact_name
              ,s.t_signer_id
              ,jp.position_name
          INTO v_signer_name
              ,v_signer_id
              ,v_position_name
          FROM ins.t_report_signer sg
              ,ins.t_job_position  jp
              ,ins.t_signer        s
         WHERE s.job_position_id = jp.t_job_position_id
           AND jp.dep_brief = 'ОПЕРУ'
           AND jp.is_enabled = 1
           AND s.t_signer_id = sg.t_signer_id
           AND sg.report_id = v_report_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_signer_name   := '';
          v_signer_id     := 0;
          v_position_name := '';
      END;
    
      vp_position_name := v_position_name;
      vp_signer_name   := v_signer_name;
      vp_signer_id     := v_signer_id;
    
      SELECT to_char(trunc(SYSDATE), 'dd.mm.yyyy')
            ,to_char(trunc(SYSDATE), 'mm')
            ,to_char(trunc(SYSDATE), 'yy')
        INTO vsys_date
            ,vp_month
            ,vp_year
        FROM dual;
    
      SELECT CASE
               WHEN substr(vp_number, 1, 3) = '000' THEN
                to_number(substr(vp_number, 4, 1))
               WHEN substr(vp_number, 1, 2) = '00' THEN
                to_number(substr(vp_number, 3, 2))
               WHEN substr(vp_number, 1, 1) = '0' THEN
                to_number(substr(vp_number, 2, 3))
               WHEN substr(vp_number, 1, 1) <> '0' THEN
                to_number(vp_number)
             END
        INTO vnum
        FROM dual;
    
    END beforereport;
  
    PROCEDURE init_input_parameters IS
    BEGIN
      vp_sid    := to_number(repcore.get_context('SID'));
      vp_number := repcore.get_context('PNUMBER');
    END init_input_parameters;
  
    /*Печать письма*/
    PROCEDURE print_letter IS
      -- Печать шапки письма
      PROCEDURE print_header IS
        vc_header_font_size CONSTANT NUMBER := 10;
        vc_zip_font_size    CONSTANT NUMBER := 14;
        vc_empty_space_size CONSTANT NUMBER := 32; --отступ от полей до шапки (поля по 10 мм)
      
        vc_col1       CONSTANT NUMBER := 15;
        vc_col2       CONSTANT NUMBER := 85; --10(поля) + 15(первая колонка)+88 (отступ)=113 мм. до Куда-Кому
        vc_addr_space CONSTANT NUMBER := vc_col1 + vc_col2; --Отступ до адреса
      
        vc_table_col1_width CONSTANT NUMBER := 15; --Ширина колонки "Кому"
        vc_table_col2_width CONSTANT NUMBER := 68; --Ширина колонки "Адреса"
      BEGIN
      
        pkg_rep_plpdf.set_font(par_size  => vc_header_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_bold);
        --Вертикальный Отступ
        plpdf.printcell(p_w => 0, p_h => vc_empty_space_size, p_ln => 1);
      
        plpdf.printcell(p_w => vc_col1, p_h => -1, p_txt => 'Дата:');
        plpdf.printcell(p_w => vc_col2, p_h => -1, p_txt => vsys_date);
      
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_txt => 'Кому:', p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.contact_name
                       ,p_border => 0
                       ,p_ln     => 1);
      
        plpdf.printcell(p_w => vc_col1, p_h => -1, p_txt => 'Исх.№');
        plpdf.printcell(p_w   => vc_col2
                       ,p_h   => -1
                       ,p_txt => vr_rep_data.vhnum || ' ' || vp_month || '/' || vp_year);
        /*Куда*/
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_txt => 'Куда:', p_border => 0);
        /*Адрес печатается обычным (нежирным) шрифтом*/
        pkg_rep_plpdf.set_font(par_size  => vc_header_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.fadr
                       ,p_border => 0
                       ,p_ln     => 1);
      
        /*Город*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.city_name
                       ,p_border => 0
                       ,p_ln     => 1);
        /*Регион*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.region_name
                       ,p_border => 0
                       ,p_ln     => 1);
        /*Страна*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.country_name
                       ,p_border => 0
                       ,p_ln     => 1);
      
        /*Индекс*/
        pkg_rep_plpdf.set_font(par_size => vc_zip_font_size);
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.zip
                       ,p_border => 0
                       ,p_ln     => 1);
      END print_header;
    
      --Печать текста письма
      PROCEDURE print_main_text IS
        vc_main_text_font_size CONSTANT NUMBER := 9;
        vc_vertical_space      CONSTANT NUMBER := 9; --Вертикальный отступ от предыдущего раздела
        vc_paragraph         VARCHAR2(10) := '    ';
        v_already_payed_text VARCHAR2(4000) := vc_paragraph ||
                                               '(В случае, если Вы уже получили смс-уведомление о зачислении требуемой суммы, убедительно просим Вас не принимать во внимание настоящее письмо. Если же оплата была Вами произведена, но в течение двух недель после оплаты Вы не получили смс-уведомление о зачислении денежных средств по договору страхования, убедительно просим Вас связаться с нами по телефону: (495) 981-2-981).';
        vc_text_height CONSTANT NUMBER := 4;
      BEGIN
        --Вертикальный Отступ
        plpdf.printcell(p_w => 0, p_h => vc_vertical_space, p_ln => 1);
        /*Уважаемый*/
        pkg_rep_plpdf.set_font(par_size  => vc_main_text_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_bold);
        plpdf.printcell(p_h     => -1
                       ,p_txt   => vr_rep_data.sex || ' ' || vr_rep_data.contact_name_only
                       ,p_ln    => 1
                       ,p_align => 'C');
        /*Абзац про оплату*/
        pkg_rep_plpdf.set_font(par_size  => vc_main_text_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printmultilinecell(p_h     => vc_text_height
                                ,p_txt   => vc_paragraph ||
                                            'ООО «СК «Ренессанс Жизнь» благодарит Вас за сотрудничество и напоминает, что согласно условиям договора страхования №' ||
                                            vr_rep_data.dog_num ||
                                            ', Вам необходимо было оплатить очередной ' ||
                                            vr_rep_data.payment_period ||
                                            ' страховой взнос в размере ' ||
                                            pkg_rep_utils.to_money_sep(vr_rep_data.fee) || ' ' ||
                                            vr_rep_data.fund || ' ' || vr_rep_data.usl01 || ' ' || vr_rep_data.usl02
                                ,p_ln    => 1
                                ,p_align => 'J'
                                ,p_clipping => 0);
      

      
        IF vr_rep_data.usl03 IS NOT NULL
        THEN
          plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                  ,p_h     => vc_text_height
                                  ,p_txt   => vr_rep_data.usl03
                                  ,p_align => 'J'
                                  ,p_ln    => 1
                                  ,p_clipping => 0);
        END IF;
        /*Уже оплачено*/
        plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                ,p_h     => vc_text_height
                                ,p_txt   => v_already_payed_text
                                ,p_align => 'J'
                                ,p_ln    => 1
                                ,p_clipping => 0);
      
        /*Погасить 1*/
        plpdf.printmultilinecell(p_w     => 0
                                ,p_h     => vc_text_height
                                ,p_txt   => vc_paragraph ||
                                            'Для продолжения действия Вашего договора страхования, обращаемся к Вам с просьбой погасить имеющуюся задолженность по оплате страховых взносов в размере ' ||
                                            pkg_rep_utils.to_money_sep(vr_rep_data.sum_zadol) || ' ' ||
                                            vr_rep_data.fund || '.'
                                ,p_ln    => 1
                                ,p_align => 'J'
                                ,p_clipping => 0);
      
        /*----*/
        plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                ,p_h     => vc_text_height
                                ,p_txt   => vc_paragraph || vr_rep_data.usl1
                                ,p_align => 'J'
                                ,p_ln    => 1
                                ,p_clipping => 0);
      
        plpdf.printmultilinecell(p_w     => 0
                                ,p_h     => vc_text_height
                                ,p_txt   => vc_paragraph ||
                                            'Если задолженность по оплате страховых взносов не будет погашена до даты окончания льготного периода (включительно), Компания уведомляет Вас о ' ||
                                            vr_rep_data.rast1 || ' договора страхования №' ||
                                            vr_rep_data.dog_num || ' в соответствии с ' ||
                                            vr_rep_data.usl2
                                ,p_ln    => 1
                                ,p_align => 'J'
                                ,p_clipping => 0);
                                
        IF vr_rep_data.abz IS NOT NULL
        THEN
          plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                  ,p_h     => vc_text_height
                                  ,p_txt   => vr_rep_data.abz
                                  ,p_align => 'J'
                                  ,p_ln    => 1
                                  ,p_clipping => 0);
        END IF;
      
      END print_main_text;
    
      /*Реквизиты банков для оплаты*/
      PROCEDURE print_bank_requisite IS
        vc_text_height CONSTANT NUMBER := 4;
        /*ВТБ-24*/
        PROCEDURE vtb24_requisite IS
        BEGIN
          plpdf.printcell(p_w => vc_one_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Реквизиты для оплаты через банк ВТБ-24:'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Получатель платежа: ООО "СК "Ренессанс Жизнь", ИНН 7725520440, КПП 775001001'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'р/с 40701810019000007118 в ВТБ24 (ЗАО), БИК 044525716, к/с 30101810100000000716.'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Назначение платежа: Страховая премия по договору №' ||
                                        vr_rep_data.ids || ' ' || vr_rep_data.contact_name
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
        END vtb24_requisite;
      
        PROCEDURE other_bank_requisite IS
        BEGIN
          plpdf.printcell(p_w => vc_one_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Реквизиты для оплаты через прочие банки:'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Получатель платежа: ООО "СК "Ренессанс Жизнь", ИНН 7725520440, КПП 775001001,'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'р/с 40701810800001410925 в АО "Райффайзенбанк" г. Москва, БИК 044525700, к/с 30101810200000000700.'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_height, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_height
                         ,p_txt      => 'Назначение платежа: Страховая премия по договору №' ||
                                        vr_rep_data.ids || ' ' || vr_rep_data.contact_name
                         ,p_ln       => 1
                         ,p_clipping => 0);
        END other_bank_requisite;
      
      BEGIN
      
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'Оплатить очередной взнос Вы можете по следующим реквизитам:'
                       ,p_ln  => 1);
        /*Оплата через ВТБ-24*/
        vtb24_requisite;
        /*Оплата через другие банк*/
        other_bank_requisite;
      END print_bank_requisite;
    
      /*Оплата без комиссий*/
      PROCEDURE print_pay_without_comission IS
        vc_vertical_space CONSTANT NUMBER := 9;
        vc_text_height CONSTANT NUMBER := 4;
      BEGIN
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'Для уплаты страхового взноса без дополнительных банковских комиссионных сборов Вы можете воспользоваться:'
                       ,p_ln  => 1);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => vc_text_height
                       ,p_txt => '1. Отделениями банка "ВТБ24". Со списком отделений банка, в Вашем регионе вы можете'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w   => plpdf.gettextwidth('ознакомиться на сайте банка ') + 2 --50
                       ,p_h   => vc_text_height
                       ,p_txt => 'ознакомиться на сайте банка '
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => vc_text_height
                       ,p_txt => 'http://www.vtb24.ru/'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.black);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.gettextwidth('2. Личным кабинетом') + 2
                       ,p_h   => vc_text_height
                       ,p_txt => '2. Личным кабинетом '
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.gettextwidth('https://lifecabinet.renlife.com/user/login') + 2
                       ,p_h   => vc_text_height
                       ,p_txt => 'https://lifecabinet.renlife.com/user/login'
                       ,p_clipping => 0
                        );
        plpdf.setcolor4text(p_color => plpdf_const.black);
        plpdf.printcell(p_w   => plpdf.gettextwidth(', где Вы также можете узнать информацию о состоянии')
                       ,p_h   => vc_text_height
                       ,p_txt => ', где Вы также можете узнать информацию '
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => vc_text_height
                       ,p_txt => 'о состоянии Договора страхования'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.gettextwidth('3. Интернет сайтом Компании') + 2
                       ,p_h   => vc_text_height
                       ,p_txt => '3. Интернет сайтом Компании'
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.gettextwidth('http://www.renlife.com/') + 2
                       ,p_h   => vc_text_height
                       ,p_txt => 'http://www.renlife.com/'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.black);
        IF vr_rep_data.colm_flag <> 1 -- Прямое списание с карты
        THEN
          plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
          plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                         ,p_h   => vc_text_height
                         ,p_txt => '4. Услугами Страхового представителя ООО «СК «Ренессанс Жизнь», уполномоченного Компанией принимать '
                         ,p_ln  => 1
                         ,p_clipping => 0);
          plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                  ,p_h     => vc_text_height
                                  ,p_txt   => 'страховые взносы. Вызвать страхового представителя Вы можете, позвонив по телефону: +7 495 981 2 981.>  Проверить информацию о состоянии Вашей квитанции об оплате страховой премии (взноса) формы № А-7 можно в разделе проверка бланков строгой отчетности на интернет-сайте компании.'
                                  ,p_align => 'J'
                                  ,p_ln    => 1
                                  ,p_clipping => 0);
        
        END IF;
        plpdf.printcell(p_h => vc_vertical_space, p_ln => 1);
      
      END print_pay_without_comission;
    
      PROCEDURE print_sign IS
        vr_signer dml_t_signer.tt_t_signer;
      BEGIN
        vr_signer := dml_t_signer.get_record(par_t_signer_id => vp_signer_id);
      
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold_italic);
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'С наилучшими пожеланиями,'
                       ,p_ln  => 1);
        plpdf.printcell(p_w => 0, p_h => -1, p_txt => vp_position_name, p_ln => 1);
        plpdf.printcell(p_w => 0, p_h => -1, p_txt => vp_signer_name, p_ln => 1);
        IF vr_signer.only_sign_jpg IS NOT NULL
        THEN
          plpdf.putimage(p_name => 'only_sign_jpg'
                        ,p_data => vr_signer.only_sign_jpg
                        ,p_x    => plpdf.getpagespace - 45
                        ,p_y    => plpdf.getcurrenty - 20
                        ,p_w    => 15
                        ,p_h    => 25);
        END IF;
      END print_sign;
    
    BEGIN
    
      /*Печать шапки*/
      print_header;
      /*Основной текст*/
      print_main_text;
      /*Реквизиты банков для оплаты*/
      print_bank_requisite;
      /*Оплата без комиссий*/
      print_pay_without_comission;
      /*Подпись*/
      print_sign;
    
    END print_letter;
  
    /*Напечатать текст в начале квитании с чертой в конце*/
    PROCEDURE print_start_text_with_border
    (
      par_text         VARCHAR2 := NULL
     ,par_ln           NUMBER := 0
     ,par_border       VARCHAR2 := 'R'
     ,par_w            NUMBER := vc_receipt_space
     ,par_align        VARCHAR2 := NULL
     ,par_h            NUMBER := -1
     ,par_space_width  NUMBER := 0 /*Ширина пробела после вертикальной черты для квитанций ВТБ*/
     ,par_space_border VARCHAR2 := '0' /*Границы пробела после вертикальной чертны*/
    ) IS
      v_ln NUMBER; --Флаг перевода строки
    BEGIN
      /*Если печатается пробел, то строку не переводим*/
      IF par_space_width > 0
      THEN
        v_ln := 0;
      ELSE
        v_ln := par_ln;
      END IF;
    
      plpdf.printcell(p_w        => par_w
                     ,p_h        => par_h
                     ,p_txt      => par_text
                     ,p_ln       => v_ln
                     ,p_border   => par_border
                     ,p_align    => par_align
                     ,p_clipping => 0);
    
      IF par_space_width > 0
      THEN
        plpdf.printcell(p_w        => par_space_width
                       ,p_h        => par_h
                       ,p_ln       => par_ln
                       ,p_border   => par_space_border
                       ,p_align    => par_align
                       ,p_clipping => 0);
      END IF;
    
    END print_start_text_with_border;
  
    /*Квитаниця ВТБ-24*/
    PROCEDURE print_receipt_vtb24 IS
      vc_left_margin    CONSTANT NUMBER := 17; --Левое поле (для сдвига положения квитанции)
      vc_default_margin CONSTANT NUMBER := 10;
      PROCEDURE print_header IS
        vc_vertical_space CONSTANT NUMBER := 7; --Вертикальный отступ
      BEGIN
        plpdf.printcell(p_h => vc_vertical_space, p_ln => 1);
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 14);
        plpdf.printcell(p_w     => 0
                       ,p_h     => -1
                       ,p_txt   => 'Квитанция для оплаты через банк ВТБ-24'
                       ,p_ln    => 1
                       ,p_align => 'C');
      
      END print_header;
    
      /*Печать слова ИЗВЕЩЕНИЕ*/
      PROCEDURE print_notification_name IS
      BEGIN
        pkg_rep_plpdf.set_font(par_size => 10);
      
        print_start_text_with_border(par_text => NULL, par_ln => 1); --Пустая строка
        print_start_text_with_border(par_text => 'ИЗВЕЩЕНИЕ', par_ln => 1);
      END print_notification_name;
    
      /*Печать слова КВИТАНЦИЯ*/
      PROCEDURE print_receipt_name IS
      BEGIN
        pkg_rep_plpdf.set_font(par_size => 10);
      
        print_start_text_with_border(par_text => NULL, par_ln => 1); --Пустая строка
        print_start_text_with_border(par_text => 'КВИТАНЦИЯ', par_ln => 1);
      END print_receipt_name;
    
      /*Печать слова реквизитов платежа*/
      PROCEDURE print_payment IS
        v_x       NUMBER;
        v_y       NUMBER;
        v_new_y   NUMBER;
        vc_height NUMBER := 4; --Высота строки банковских реквизитов
      
        /*Реквизиты банка*/
        PROCEDURE pring_bank_requisite IS
        BEGIN
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Наименование получателя:  ООО СК "Ренессанс Жизнь"'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'ИНН 7725520440'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Р/с 40701810019000007118 в ВТБ24 (ЗАО)'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Кор. сч.30101810100000000716, БИК 044525716'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        END pring_bank_requisite;
      
        /*Реквизиты плательщика*/
        PROCEDURE payer_detail IS
        BEGIN
          print_start_text_with_border(par_space_width => 5, par_space_border => 'B');
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'ФИО Плательщика'
                         ,p_ln     => 1
                         ,p_border => 'B');
          print_start_text_with_border(par_space_width => 5, par_space_border => 'B');
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'Адрес Плательщика'
                         ,p_ln     => 1
                         ,p_border => 'B');
        
          print_start_text_with_border(par_space_width => 5);
          plpdf.printcell(p_w      => 50
                         ,p_h      => -1
                         ,p_txt    => 'ФИО Страхователя'
                         ,p_border => 0);
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w      => vc_width_second - 50
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_border => 0
                         ,p_ln     => 1);
        END payer_detail;
      
        /*Назначение платежа*/
        PROCEDURE payment_dedication IS
        BEGIN
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'T');
          plpdf.printcell(p_w      => 65
                         ,p_h      => -1
                         ,p_txt    => 'Назначение платежа'
                         ,p_border => 'RTB'
                         ,p_align  => 'C');
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => 'Дата', p_border => 1, p_align => 'C');
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => 'Сумма'
                         ,p_border => 1
                         ,p_align  => 'C'
                         ,p_ln     => 1);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'T');
          plpdf.printcell(p_w      => 65
                         ,p_h      => -1
                         ,p_txt    => 'Страховая премия по договору'
                         ,p_border => 'RTB');
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => NULL, p_border => 'LR', p_align => 'C');
          /*Запоминаем позицию курсора для впечатывания суммы*/
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
        
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => NULL
                         ,p_border => 'LR'
                         ,p_align  => 'C'
                         ,p_ln     => 1);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'TB');
          plpdf.printcell(p_w      => 35
                         ,p_h      => -1
                         ,p_txt    => 'Серия             Номер'
                         ,p_border => 'TB');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w      => 30
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.ids
                         ,p_border => 'RTB'
                         ,p_align  => 'L');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => NULL, p_border => 'LRB', p_align => 'C');
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => NULL
                         ,p_border => 'LRB'
                         ,p_align  => 'C'
                         ,p_ln     => 1);
          /*Переводим курсор на нужную позицию для печати объединенной ячейки*/
          v_new_y := plpdf.getcurrenty;
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w     => 40
                         ,p_h     => v_new_y - v_y
                         ,p_txt   => pkg_rep_utils.to_money_sep(vr_rep_data.sum_zadol)
                         ,p_align => 'C'
                         ,p_ln    => 1);
        END payment_dedication;
      
        /*Подпись плательщика и кассира*/
        PROCEDURE payer_sign IS
        BEGIN
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
          print_start_text_with_border(par_text => 'Кассир', par_space_width => 5);
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'Подпись плательщика'
                         ,p_border => 'R'
                         ,p_ln     => 1);
          --Горизонтальная черта               
          plpdf.printcell(p_w => vc_receipt_space, p_h => 3, p_txt => NULL, p_border => 'BR');
          plpdf.printcell(p_w      => vc_width_second + 5
                         ,p_h      => 3
                         ,p_txt    => NULL
                         ,p_border => 'BR'
                         ,p_ln     => 1);
        END payer_sign;
      BEGIN
        --Реквизиты банка
        pring_bank_requisite;
        --Реквизиты плательщика
        payer_detail;
        --Назанчение платежа
        payment_dedication;
        --Подпись плательщика и кассира
        payer_sign;
      
      END print_payment;
    
    BEGIN
      plpdf.newpage;
      /*Выставление полей для выравнивания положения квитанции*/
      plpdf.setleftmargin(p_margin => vc_left_margin);
    
      --Шапка
      print_header;
      --Извещение
      print_notification_name; --Печать типа Извещение или Квитанция
      --Реквизиты платежа
      print_payment;
    
      --Квитанция
      print_receipt_name; --Печать типа Извещение или Квитанция
      --Реквизиты платежа
      print_payment;
    
      /*Возвращение к дефолтным размерам полей*/
      plpdf.setleftmargin(p_margin => vc_default_margin);
    
    END print_receipt_vtb24;
  
    /*Квитаниця для остальных банков*/
    PROCEDURE print_receipt_other_bank IS
      vc_left_margin    CONSTANT NUMBER := 14; --Левое поле (для сдвига положения квитанции)
      vc_default_margin CONSTANT NUMBER := 10;
      vc_part_one_width CONSTANT NUMBER := 28; --Ширина первой части квитанции
      vc_width_second   CONSTANT NUMBER := 140; --Ширина второй части квитанции
      vc_middle_space   CONSTANT NUMBER := 5; --Отступ после вертикальной черты
      /*Печать отступа после вертикальной черты*/
      PROCEDURE print_middle_space
      (
        par_border VARCHAR2 := '0'
       ,par_h      NUMBER := -1
      ) IS
      BEGIN
        plpdf.printcell(p_w => vc_middle_space, p_h => par_h, p_border => par_border);
      END print_middle_space;
    
      /*Печать стандартной строки квитанции*/
      PROCEDURE print_row
      (
        par_text1       VARCHAR2 := NULL
       ,par_text2       VARCHAR2 := NULL
       ,par_style_text1 VARCHAR2 := NULL
       ,par_style_text2 VARCHAR2 := NULL
       ,par_align1      VARCHAR2 := NULL
       ,par_align2      VARCHAR2 := NULL
       ,par_font_size1  NUMBER := NULL
       ,par_font_size2  NUMBER := NULL
       ,par_border1     VARCHAR2 := 'LR'
       ,par_border2     VARCHAR2 := 'R'
       ,par_h1          NUMBER := -1 --Высота строки
       ,par_h2          NUMBER := -1
      ) IS
        v_middle_border VARCHAR2(10);
      BEGIN
        IF par_style_text1 IS NOT NULL
           OR par_font_size1 IS NOT NULL
        THEN
          pkg_rep_plpdf.set_font(par_style => par_style_text1, par_size => par_font_size1);
        END IF;
        print_start_text_with_border(par_border => par_border1
                                    ,par_w      => vc_part_one_width
                                    ,par_text   => par_text1
                                    ,par_align  => par_align1
                                    ,par_h      => par_h1);
        IF instr(par_border1, 'T') != 0
        THEN
          v_middle_border := 'T';
        ELSIF instr(par_border1, 'B') != 0
        THEN
          v_middle_border := 'B';
        END IF;
        print_middle_space(par_border => v_middle_border, par_h => par_h2);
        IF par_style_text2 IS NOT NULL
        THEN
          pkg_rep_plpdf.set_font(par_style => par_style_text2, par_size => par_font_size2);
        END IF;
        plpdf.printcell(p_w        => vc_width_second
                       ,p_h        => par_h2
                       ,p_txt      => par_text2
                       ,p_ln       => 1
                       ,p_align    => par_align2
                       ,p_border   => par_border2
                       ,p_clipping => 0);
      END print_row;
    
      PROCEDURE print_header IS
      BEGIN
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 14);
        plpdf.printcell(p_w     => 0
                       ,p_h     => -1
                       ,p_txt   => 'Квитанция для оплаты через прочие банки'
                       ,p_ln    => 1
                       ,p_align => 'C');
        /*Пустая строка*/
        plpdf.printcell(p_w => 0, p_h => -1, p_ln => 1);
      
      END print_header;
    
      PROCEDURE print_pd4 IS
      BEGIN
        print_row(par_text2       => 'Форма ПД-4'
                 ,par_style_text1 => pkg_rep_plpdf.gc_style_bold
                 ,par_style_text2 => pkg_rep_plpdf.gc_style_bold
                 ,par_align2      => 'R'
                 ,par_font_size1  => 13
                 ,par_font_size2  => 13
                 ,par_border1     => 'LTR'
                 ,par_border2     => 'TR');
      
      END print_pd4;
      --par_type  -1 Извещение  (верхняя часть), 2 - квитанция (нижняя часть)
      PROCEDURE print_insurer_info(par_type NUMBER) IS
      BEGIN
        IF par_type = 2
        THEN
          /*Отступ для нижней части*/
          print_row;
        END IF;
        print_row(par_text2       => 'ООО "СК "Ренессанс Жизнь"'
                 ,par_style_text1 => pkg_rep_plpdf.gc_style_bold
                 ,par_style_text2 => pkg_rep_plpdf.gc_style_bold
                 ,par_font_size1  => 10
                 ,par_font_size2  => 10);
      END print_insurer_info;
    
      /*Печать слова реквизитов платежа*/
      --par_type  -1 Извещение  (верхняя часть), 2 - квитанция (нижняя часть)
      PROCEDURE print_payment(par_type NUMBER) IS
        v_x     NUMBER;
        v_y     NUMBER;
        v_new_y NUMBER;
      
        /*Реквизиты банка*/
        PROCEDURE pring_bank_requisite IS
          v_text1        VARCHAR2(200);
          vr_t_rep_image dml_t_rep_image.tt_t_rep_image;
          v_height       NUMBER := 4; --Высота строки
        
        BEGIN
        
          IF par_type = 1
          THEN
            v_text1 := 'Отправить в д/о';
          END IF;
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          print_row(par_text1 => v_text1
                   ,par_text2 => 'ИНН 7725520440, КПП 775001001'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          vr_t_rep_image := dml_t_rep_image.get_rec_by_brief(par_brief => 'RENLIFE_LETTER');
          plpdf.putimage(p_name => 'image_for_letter'
                        ,p_data => vr_t_rep_image.image
                        ,p_x    => plpdf.getpagespace - 45
                        ,p_y    => plpdf.getcurrenty - 10
                        ,p_w    => 30
                        ,p_h    => 12);
        
          IF par_type = 1
          THEN
            v_text1 := '___________';
          END IF;
          print_row(par_text1 => v_text1
                   ,par_text2 => 'Р/с 40701810800001410925'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          print_row(par_text1 => NULL
                   ,par_text2 => 'В АО "Райффайзенбанк" г. Москва'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          print_row(par_text1 => NULL
                   ,par_text2 => 'БИК 044525700, К/С 30101810200000000700'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        END pring_bank_requisite;
      
        /*Реквизиты плательщика*/
        PROCEDURE payer_detail IS
          v_x            NUMBER;
          v_y            NUMBER;
          v_height_small NUMBER := 3; --высота строки подписи
        BEGIN
          IF par_type = 1
          THEN
            print_row(par_text1 => 'ИЗВЕЩЕНИЕ', par_text2 => NULL);
          ELSE
            print_row(par_text1 => 'КВИТАНЦИЯ', par_text2 => NULL);
          END IF;
          print_row(par_text1 => 'Кассир'
                   ,par_text2 => 'Плательщик___________________________________________________________');
          print_row(par_text1      => NULL
                   ,par_text2      => '(Фамилия, Имя, Отчество плательщика)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
          print_row(par_text1      => NULL
                   ,par_text2      => '______________________________________________________________________'
                   ,par_font_size1 => 10);
          print_row(par_text1      => NULL
                   ,par_text2      => '(Адрес плательщика)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
        
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          /*Страхователь*/
          print_start_text_with_border(par_text => NULL, par_border => 'LR');
          print_middle_space;
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
          plpdf.printcell(p_w   => vc_width_second
                         ,p_h   => -1
                         ,p_txt => 'Страхователь_________________________________________________________');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_ln     => 1
                         ,p_border => 'R'
                         ,p_align  => 'C');
          print_row(par_text1      => NULL
                   ,par_text2      => '(Фамилия, Имя, Отчество страхователя)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
        END payer_detail;
      
        /*Назначение платежа*/
        PROCEDURE payment_dedication IS
          v_vertical_space NUMBER := 2; --Высота вертикального отступа
        BEGIN
          /*Отступ*/
          print_row(par_text1 => NULL
                   ,par_text2 => NULL
                   ,par_h1    => v_vertical_space
                   ,par_h2    => v_vertical_space);
          /*Строка 1*/
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w      => 90
                         ,p_h      => -1
                         ,p_txt    => 'Назначение платежа: Страховая премия'
                         ,p_border => 'LTR');
        
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => 'Сумма', p_border => 1, p_align => 'C');
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Строка 2*/
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w => 28, p_h => -1, p_txt => 'по договору № ', p_border => 'L');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w => 62, p_h => -1, p_txt => vr_rep_data.ids, p_border => '0');
          /*Запоминаем для впечатывания суммы в обобщенную ячейку*/
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => NULL, p_border => 'LR');
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Строка 3*/
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w      => 90
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_border => 'LB'
                         ,p_align  => 'C');
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => NULL, p_border => 'LRB');
        
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Впечатываем сумму в обобщенную ячейку*/
          v_new_y := plpdf.getcurrenty;
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w     => 30
                         ,p_h     => v_new_y - v_y
                         ,p_txt   => pkg_rep_utils.to_money_sep(vr_rep_data.sum_zadol)
                         ,p_align => 'C'
                         ,p_ln    => 1);
          /*Отступ*/
          print_row(par_text1 => NULL
                   ,par_text2 => NULL
                   ,par_h1    => v_vertical_space
                   ,par_h2    => v_vertical_space);
        END payment_dedication;
      
        /*Подпись плательщика и кассира*/
        PROCEDURE payer_sign IS
          v_height NUMBER := 1;
        BEGIN
          print_row(par_text1      => NULL
                   ,par_text2      => '"______"________________ 20___г.        Подпись плательщика _______________'
                   ,par_font_size1 => 10);
          --Горизонтальная черта
          print_row(par_text1   => NULL
                   ,par_text2   => NULL
                   ,par_border1 => 'LBR'
                   ,par_border2 => 'BR'
                   ,par_h1      => v_height
                   ,par_h2      => v_height);
        END payer_sign;
      BEGIN
        --Реквизиты банка
        pring_bank_requisite;
        --Реквизиты плательщика
        payer_detail;
        --Назанчение платежа
        payment_dedication;
        --Подпись плательщика и кассира
        payer_sign;
      
      END print_payment;
    
    BEGIN
      plpdf.newpage;
      /*Выставление полей для выравнивания положения квитанции*/
      plpdf.setleftmargin(p_margin => vc_left_margin);
    
      --Шапка
      print_header;
      --печать строки о ПД-4
      print_pd4;
      --Ренессанс
      print_insurer_info(par_type => 1);
      --Реквизиты платежа
      print_payment(par_type => 1);
    
      --Ренессанс
      print_insurer_info(par_type => 2);
      --Реквизиты платежа
      print_payment(par_type => 2);
    
      /*Возвращение к дефолтным размерам полей*/
      plpdf.setleftmargin(p_margin => vc_default_margin);
    END print_receipt_other_bank;
  
  BEGIN
  
    /*инициализация входных параметров*/
    init_input_parameters;
    --Инициализация параметров процедуры
    beforereport;
    -- Инициализация PL/PDF
    pkg_rep_plpdf.init(par_default_font_size => vc_default_font_size);
    --Установка черного цвета шрифта  
    pkg_rep_plpdf.set_font;
  
    /*Цикл по письмам, отмеченным галочкой на форме*/
    v_is_first_letter := TRUE;
    OPEN cur_rep_data(vp_sid, vp_number);
    LOOP
      FETCH cur_rep_data
        INTO vr_rep_data;
      EXIT WHEN cur_rep_data%NOTFOUND;
    
      IF NOT v_is_first_letter
      THEN
        plpdf.newpage; --Для первого письмо новая страница в init делается
      END IF;
    
      v_is_first_letter := FALSE;
      /*Печать первой страницы письма*/
      print_letter;
      /*Печать квитанции для ВТБ-24*/
      print_receipt_vtb24;
      /*Печать квитанции для остальных банков*/
      print_receipt_other_bank;
    END LOOP;
    CLOSE cur_rep_data;
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'remind_letter_' || vp_sid || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF cur_rep_data%ISOPEN
      THEN
        CLOSE cur_rep_data;
      END IF;
      RAISE;
  END remind_in_grace_period;

  -- Author  : Черных М.
  -- Created : 24.09.2014
  -- Purpose : Письмо-напоминание за 30 дней до оплаты
  PROCEDURE remind_30_days_before_pay
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    vc_default_font_size CONSTANT NUMBER := 9;
    vc_one_shift_width   CONSTANT NUMBER := 10; --Сдвиг на один отступ
    vc_two_shift_width   CONSTANT NUMBER := vc_one_shift_width * 2; --Сдвиг на два отступ
  
    vc_receipt_space CONSTANT NUMBER := 28;
    vc_width_second  CONSTANT NUMBER := 130; --Ширина 2-й части квитанции
    v_is_first_letter BOOLEAN := TRUE; --Признак, что первое письмо
    /*Параметры старого отчета Report*/
    vp_sid           NUMBER; --ИД сессии пользователя, который печатает отчеты
    vp_report_id     NUMBER;
    vp_position_name VARCHAR2(500);
    vp_signer_name   VARCHAR2(500);
    vp_signer_id     NUMBER;
    vp_number        VARCHAR2(500); --Исходящий номер
    vnum             VARCHAR2(500);
    vsys_date        VARCHAR2(100);
    vp_month         VARCHAR2(100);
    vp_year          VARCHAR2(100);
  
    /*Данные для отчета*/
    CURSOR cur_rep_data(par_sessionid NUMBER) IS
      SELECT rownum rec_number
            ,21 || lpad(vnum + rownum - 1, 6, '0') vhnum
            ,b.*
        FROM (SELECT mn.*
                    ,TRIM(pkg_rep_utils.to_money_sep(sum_zadol_num)) || CASE
                       WHEN fund != 'RUR' THEN
                        ' * '
                     END sum_zadol
                FROM (SELECT payment_period
                            ,sex
                            ,contact_name
                            ,contact_name || '!' contact_name_1
                            ,regexp_substr(contact_name, '\w+', 1, 2) || ' ' ||
                             regexp_substr(contact_name, '\w+', 1, 3) || '!' contact_name_only
                            ,address_name
                            ,fadr
                            ,CASE
                               WHEN nvl(distr_name, 'X') <> 'X'
                                    AND nvl(city_name, 'X') <> 'X' THEN
                                city_name || ', ' || distr_name
                               ELSE
                                (CASE
                                  WHEN nvl(distr_name, 'X') = 'X' THEN
                                   city_name
                                  ELSE
                                   distr_name
                                END)
                             END city_name
                            ,province_name
                            ,region_name
                            ,CASE
                               WHEN nvl(country_name, 'X') <> 'X'
                                    AND nvl(province_name, 'X') <> 'X' THEN
                                province_name || ', ' || country_name
                               ELSE
                                (CASE
                                  WHEN nvl(province_name, 'X') = 'X' THEN
                                   country_name
                                  ELSE
                                   province_name
                                END)
                             END country_name
                            ,zip
                            ,code
                            ,init_name
                            ,due_date
                            ,fund
                            ,CASE
                               WHEN fund = 'RUR' THEN
                                ''
                               ELSE
                                '*Сумма указана в валюте ' || fund ||
                                '. Оплата в рублях по курсу ЦБ РФ на дату оплаты.'
                             END fund_str
                            ,pol_num
                            ,abz
                            ,ids
                            ,flag
                            ,dog_num
                            ,pol_ser
                            ,type_contact
                            ,is_adm
                            ,gender
                            ,CASE mb
                               WHEN 0 THEN
                                TRIM(to_char(fee, '9999999990D00'))
                               ELSE
                                TRIM(to_char(amount, '9999999990D00'))
                             END amount
                            ,CASE
                               WHEN nvl(part_pay_amount, 0) > 0 THEN
                                TRIM(to_char((CASE mb
                                               WHEN 0 THEN
                                                fee
                                               ELSE
                                                amount
                                             END) - nvl(part_pay_amount, 0)
                                            ,'9999999990D00'))
                               ELSE
                                TRIM(to_char((CASE mb
                                               WHEN 0 THEN
                                                fee
                                               ELSE
                                                amount
                                             END)
                                            ,'9999999990D00'))
                             END amount_new
                            ,('договора страхования № ' || pol_num || ' ' ||
                             
                             CASE
                               WHEN nvl(part_pay_amount, 0) > 0 THEN
                                'Вам необходимо доплатить сумму в размере ' ||
                                pkg_rep_utils.to_money_sep((CASE mb
                                                             WHEN 0 THEN
                                                              fee
                                                             ELSE
                                                              amount
                                                           END) - nvl(part_pay_amount, 0)) || ' ' || fund
                               ELSE
                                'Вам необходимо оплатить очередной ' || payment_period ||
                                ' страховой взнос'
                             END || CASE
                               WHEN nvl(part_pay_amount, 0) > 0 THEN
                                ' в счет платежа в связи с переплатой по договору страхования в размере ' ||
                                pkg_rep_utils.to_money_sep(nvl(part_pay_amount, 0)) || ' ' || fund ||
                                ' к ' || due_date
                               ELSE
                                ' в размере ' || pkg_rep_utils.to_money_sep((CASE mb
                                                                              WHEN 0 THEN
                                                                               fee
                                                                              ELSE
                                                                               amount
                                                                            END)) || ' ' || fund || ' к ' ||
                                due_date
                             END ||
                             
                             CASE
                               WHEN nvl(non_pay_amount, 0) > 0
                                    AND nvl(part_pay_amount, 0) = 0 THEN
                                ', а также погасить задолженность по оплате предыдущих взносов в размере ' ||
                                pkg_rep_utils.to_money_sep(non_pay_amount)
                               WHEN nvl(non_pay_amount, 0) > 0
                                    AND nvl(part_pay_amount, 0) > 0 THEN
                                NULL
                               WHEN nvl(non_pay_amount, 0) = 0
                                    AND nvl(part_pay_amount, 0) > 0 THEN
                                NULL
                               ELSE
                                NULL
                             END || CASE
                               WHEN nvl(non_pay_amount, 0) > 0 THEN
                                fund || ' к ' || due_date || '.'
                               ELSE
                                ''
                             END || usl01) new_phrase1
                            ,NULL new_phrase2
                            ,NULL usl02
                            ,NULL usl03
                            ,NULL usl01
                            ,TRIM(to_char(non_pay_amount, '9999999990D00')) non_pay_amount
                            ,decode(mb, 0, fee, amount) - abs(nvl(part_pay_amount, 0)) sum_zadol_num
                            ,TRIM(to_char(nvl(part_pay_amount, 0), '9999999990D00')) part_pay_amount
                        FROM (SELECT
                              
                               (SELECT SUM(a.amount) -
                                       SUM(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL))
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                 WHERE d.document_id = a.payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name <> 'Аннулирован'
                                   AND a.plan_date BETWEEN pph.start_date AND vlp.prev_due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) non_pay_amount
                              ,
                               
                               (SELECT SUM(nvl(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL)
                                              ,0))
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                 WHERE d.document_id = a.payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name NOT IN ('Аннулирован', 'Оплачен')
                                   AND a.plan_date BETWEEN vlp.due_date AND vlp.due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) part_pay_amount
                              ,
                               
                               vlp.payment_period
                              ,vlp.contact_name
                              ,vlp.address_name
                              ,vlp.fadr
                              ,vlp.city_name
                              ,vlp.province_name
                              ,(SELECT COUNT(*)
                                  FROM ins.p_policy           pol
                                      ,ins.as_asset           at
                                      ,ins.p_cover            pct
                                      ,ins.t_prod_line_option opt
                                      ,ins.t_product_line     pl
                                 WHERE pol.policy_id = at.p_policy_id
                                   AND at.as_asset_id = pct.as_asset_id
                                   AND pct.t_prod_line_option_id = opt.id
                                   AND pl.id = opt.product_line_id
                                   AND pol.pol_header_id = ph.policy_header_id
                                   AND pl.description IN 'Административные издержки') is_adm
                              ,vlp.distr_name
                              ,vlp.region_name
                              ,vlp.country_name
                              ,vlp.zip
                              ,vlp.code
                              ,vlp.mb
                              ,vlp.init_name
                              ,to_char(vlp.due_date, 'dd.mm.yyyy') due_date
                              ,vlp.sum_fee amount
                              ,vlp.pay_amount_dog
                              ,vlp.fund
                              ,pp.pol_num
                              ,ph.ids
                              ,CASE
                                 WHEN (SUM(plt.plt_cnt) > 0 AND
                                      to_char(due_date, 'dd.mm') = to_char(ph.start_date, 'dd.mm') AND
                                      substr(ph.ids, 1, 3) = 114) THEN
                                  ' Также напоминаем, что в случае, если оплата взноса не будет произведена до установленной договором страхования даты, дополнительные программы, срок действия которых заканчивается ' ||
                                  to_char(vlp.due_date - 1, 'dd.mm.yyyy') ||
                                  ' не продлеваются на очередной страховой год.'
                               END usl01
                              ,CASE
                                 WHEN length(pp.pol_num) > 6 THEN
                                  1
                                 ELSE
                                  0
                               END flag
                              ,pp.pol_num dog_num
                              ,CASE
                                 WHEN length(pp.pol_num) > 6 THEN
                                  substr(pp.pol_num, 1, 3)
                                 ELSE
                                  pp.pol_ser
                               END pol_ser
                              ,CASE
                                 WHEN length(pp.pol_num) > 6 THEN
                                  ''
                                 ELSE
                                  '          Так же сообщаем Вам, что в целях стандартизации процесса приема платежей, Вашему договору присвоен идентификационный номер ' ||
                                  ph.ids ||
                                  '. Просим Вас при оплате страховых взносов в назначении платежа вместо номера договора указывать данный идентификационный номер.'
                               END abz
                              ,vlp.type_contact
                              ,vlp.gender
                              ,CASE vlp.gender
                                 WHEN 0 THEN
                                  'Уважаемая'
                                 WHEN 1 THEN
                                  'Уважаемый'
                                 ELSE
                                  ''
                               END sex
                              ,SUM(pc.fee) -
                               (SELECT nvl(SUM(ir.invest_reserve_amount), 0)
                                  FROM ins.ac_payment_ir ir
                                      ,doc_doc           dd_
                                      ,p_policy          pp_
                                 WHERE ir.ac_payment_id = dd_.child_id
                                   AND dd_.parent_id = pp_.policy_id
                                   AND pp_.pol_header_id = ph.policy_header_id) fee
                              
                                FROM v_letters_payment vlp
                                    ,notif_letter_rep nlr
                                    ,p_pol_header ph
                                    ,t_product prod
                                    ,p_policy pp
                                    ,as_asset a
                                    ,p_cover pc
                                    ,(SELECT pol.pol_header_id
                                            ,SUM(decode(plt.brief, 'OPTIONAL', 1, 'MANDATORY', 1, 0)) plt_cnt
                                        FROM ins.p_policy            pol
                                            ,ins.as_asset            at
                                            ,ins.p_cover             pct
                                            ,ins.t_prod_line_option  opt
                                            ,ins.t_product_line      pl
                                            ,ins.t_product_line_type plt
                                       WHERE pol.policy_id = at.p_policy_id
                                         AND at.as_asset_id = pct.as_asset_id
                                         AND pct.t_prod_line_option_id = opt.id
                                         AND pl.id = opt.product_line_id
                                         AND pl.product_line_type_id = plt.product_line_type_id
                                         AND opt.brief NOT IN
                                             ('Adm_Cost_Life', 'Adm_Cost_Acc', 'Penalty')
                                         AND at.as_asset_id = pct.as_asset_id
                                       GROUP BY pol.pol_header_id) plt
                              
                               WHERE vlp.document_id = nlr.document_id
                                    --изменено и добавлены комментарии 307107: Доработка выгрузки писем-напоминаний и в ЛП
                                 AND pp.payment_term_id != 1 --Единовременно
                                 AND nlr.sessionid = par_sessionid
                                 AND ph.policy_header_id = vlp.pol_header_id
                                 AND ph.product_id = prod.product_id
                                 AND plt.pol_header_id = ph.policy_header_id
                                 AND pp.policy_id = ph.policy_id
                                 AND pp.policy_id = a.p_policy_id
                                 AND a.as_asset_id = pc.as_asset_id
                                 AND pc.status_hist_id <> 3
                               GROUP BY vlp.payment_period
                                       ,vlp.contact_name
                                       ,vlp.address_name
                                       ,vlp.fadr
                                       ,vlp.city_name
                                       ,vlp.province_name
                                       ,vlp.region_name
                                       ,vlp.distr_name
                                       ,vlp.country_name
                                       ,vlp.zip
                                       ,vlp.code
                                       ,vlp.mb
                                       ,vlp.init_name
                                       ,to_char(vlp.due_date, 'dd.mm.yyyy')
                                       ,vlp.due_date
                                       ,vlp.prev_due_date
                                       ,ph.policy_header_id
                                       ,ph.ids
                                       ,ph.start_date
                                       ,vlp.sum_fee
                                       ,vlp.pay_amount_dog
                                       ,vlp.fund
                                       ,pp.pol_num
                                       ,CASE
                                          WHEN length(pp.pol_num) > 6 THEN
                                           ''
                                          ELSE
                                           '          Так же сообщаем Вам, что в целях стандартизации процесса приема платежей, Вашему договору присвоен идентификационный номер ' ||
                                           ph.ids ||
                                           '. Просим Вас при оплате страховых взносов в назначении платежа вместо номера договора указывать данный идентификационный номер.'
                                        END
                                       ,ph.ids
                                       ,CASE
                                          WHEN length(pp.pol_num) > 6 THEN
                                           1
                                          ELSE
                                           0
                                        END
                                       ,pp.pol_num
                                       ,CASE
                                          WHEN length(pp.pol_num) > 6 THEN
                                           substr(pp.pol_num, 1, 3)
                                          ELSE
                                           pp.pol_ser
                                        END
                                       ,vlp.type_contact
                                       ,vlp.gender)) mn
                    ,(SELECT pv.number_val
                            ,CASE lp.brief
                               WHEN 'SUM_DEBT_RUR' THEN
                                'RUR'
                               WHEN 'SUM_DEBT_USD' THEN
                                'USD'
                               WHEN 'SUM_DEBT_EUR' THEN
                                'EUR'
                             END AS fund_brief
                        FROM t_notification_type  nt
                            ,t_n_ltrs_params      lp
                            ,t_n_ltrs_params_vals pv
                       WHERE nt.brief = 'REMIND_30_PDFN'
                         AND lp.brief IN ('SUM_DEBT_RUR', 'SUM_DEBT_USD', 'SUM_DEBT_EUR')
                         AND nt.t_notification_type_id = pv.t_notification_type_id
                         AND lp.t_n_ltrs_params_id = pv.t_notif_param_id) sm
               WHERE mn.fund = sm.fund_brief
                 AND mn.sum_zadol_num >= sm.number_val
                 AND mn.sum_zadol_num - mn.amount < (CASE mn.fund
                       WHEN 'RUR' THEN
                        600
                       ELSE
                        20
                     END)
               ORDER BY mn.contact_name) b;
    vr_rep_data cur_rep_data%ROWTYPE;
  
    /*Процедура для запуска перед вызовом отчета (старый BEFORE_REPORT тригггер)
    заполняет глобальные переменные процедуры
    */
    PROCEDURE beforereport IS
      /**/
      v_report_id     NUMBER;
      v_position_name VARCHAR2(2000);
      v_signer_name   VARCHAR2(600);
      v_signer_id     NUMBER;
    
    BEGIN
    
      BEGIN
        SELECT r.rep_report_id
          INTO v_report_id
          FROM ins.rep_report r
         WHERE r.exe_name = lower(gc_pkg_name || '.remind_30_days_before_pay');
      EXCEPTION
        WHEN no_data_found THEN
          v_report_id := 0;
      END;
      vp_report_id := v_report_id;
    
      BEGIN
        SELECT s.contact_name
              ,s.t_signer_id
              ,jp.position_name
          INTO v_signer_name
              ,v_signer_id
              ,v_position_name
          FROM ins.t_report_signer sg
              ,ins.t_job_position  jp
              ,ins.t_signer        s
         WHERE s.job_position_id = jp.t_job_position_id
           AND jp.dep_brief = 'ОПЕРУ'
           AND jp.is_enabled = 1
           AND s.t_signer_id = sg.t_signer_id
           AND sg.report_id = v_report_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_signer_name   := '';
          v_signer_id     := 0;
          v_position_name := '';
      END;
    
      vp_position_name := v_position_name;
      vp_signer_name   := v_signer_name;
      vp_signer_id     := v_signer_id;
    
      SELECT to_char(trunc(SYSDATE), 'dd.mm.yyyy')
            ,to_char(trunc(SYSDATE), 'mm')
            ,to_char(trunc(SYSDATE), 'yy')
        INTO vsys_date
            ,vp_month
            ,vp_year
        FROM dual;
    
      SELECT to_number(vp_number) INTO vnum FROM dual;
    
    END beforereport;
  
    PROCEDURE init_input_parameters IS
    BEGIN
      vp_sid    := to_number(repcore.get_context('SID'));
      vp_number := repcore.get_context('PNUMBER');
    END init_input_parameters;
  
    /*Печать письма*/
    PROCEDURE print_letter IS
      -- Печать шапки письма
      PROCEDURE print_header IS
        vc_header_font_size CONSTANT NUMBER := 10;
        vc_zip_font_size    CONSTANT NUMBER := 14;
        vc_empty_space_size CONSTANT NUMBER := 32; -- отступ от полей до шапки (поля по 10 мм)
      
        vc_col1       CONSTANT NUMBER := 15;
        vc_col2       CONSTANT NUMBER := 85; --10(поля) + 15(первая колонка)+85 (отступ)=110 мм. до Куда-Кому
        vc_addr_space CONSTANT NUMBER := vc_col1 + vc_col2; --Отступ до адреса
      
        vc_table_col1_width CONSTANT NUMBER := 15; --Ширина колонки "Кому"
        vc_table_col2_width CONSTANT NUMBER := 68; --Ширина колонки "Адреса"
      BEGIN
      
        pkg_rep_plpdf.set_font(par_size  => vc_header_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_bold);
        --Вертикальный Отступ
        plpdf.printcell(p_w => 0, p_h => vc_empty_space_size, p_ln => 1);
      
        plpdf.printcell(p_w => vc_col1, p_h => -1, p_txt => 'Дата:');
        plpdf.printcell(p_w => vc_col2, p_h => -1, p_txt => vsys_date);
      
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_txt => 'Кому:', p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.contact_name
                       ,p_border => 0
                       ,p_ln     => 1);
      
        plpdf.printcell(p_w => vc_col1, p_h => -1, p_txt => 'Исх.№');
        plpdf.printcell(p_w   => vc_col2
                       ,p_h   => -1
                       ,p_txt => vr_rep_data.vhnum || ' ' || vp_month || '/' || vp_year);
        /*Куда*/
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_txt => 'Куда:', p_border => 0);
        /*Адрес печатается обычным (нежирным) шрифтом*/
        pkg_rep_plpdf.set_font(par_size  => vc_header_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.fadr
                       ,p_border => 0
                       ,p_ln     => 1);
      
        /*Город*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.city_name
                       ,p_border => 0
                       ,p_ln     => 1);
        /*Регион*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.region_name
                       ,p_border => 0
                       ,p_ln     => 1);
        /*Страна*/
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.country_name
                       ,p_border => 0
                       ,p_ln     => 1);
      
        /*Индекс*/
        pkg_rep_plpdf.set_font(par_size => vc_zip_font_size);
        plpdf.printcell(p_w => vc_addr_space, p_h => -1);
        plpdf.printcell(p_w => vc_table_col1_width, p_h => -1, p_border => 0);
        plpdf.printcell(p_w      => vc_table_col2_width
                       ,p_h      => -1
                       ,p_txt    => vr_rep_data.zip
                       ,p_border => 0
                       ,p_ln     => 1);
      END print_header;
    
      --Печать текста письма
      PROCEDURE print_main_text IS
        vc_main_text_font_size CONSTANT NUMBER := 9;
        vc_vertical_space      CONSTANT NUMBER := 9; --Вертикальный отступ от предыдущего раздела
        vc_paragraph         VARCHAR2(10) := '    ';
        v_already_payed_text VARCHAR2(4000) := vc_paragraph ||
                                               '(В случае, если Вы уже получили смс-уведомление о зачислении требуемой суммы, убедительно просим Вас не принимать во внимание настоящее письмо. Если же оплата была Вами произведена, но в течение двух недель после оплаты Вы не получили смс-уведомление о зачислении денежных средств по договору страхования, убедительно просим Вас связаться с нами по телефону: (495) 981-2-981).';
      BEGIN
        --Вертикальный Отступ
        plpdf.printcell(p_w => 0, p_h => vc_vertical_space, p_ln => 1);
        /*Уважаемый*/
        pkg_rep_plpdf.set_font(par_size  => vc_main_text_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_bold);
        plpdf.printcell(p_h     => -1
                       ,p_txt   => vr_rep_data.sex || ' ' || vr_rep_data.contact_name_only
                       ,p_ln    => 1
                       ,p_align => 'C');
        /*Абзац про оплату*/
        pkg_rep_plpdf.set_font(par_size  => vc_main_text_font_size
                              ,par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printmultilinecell(p_h     => -1
                                ,p_txt   => vc_paragraph ||
                                            'ООО «СК «Ренессанс Жизнь» благодарит Вас за сотрудничество и напоминает, что согласно условиям ' ||
                                            vr_rep_data.new_phrase1
                                ,p_ln    => 1
                                ,p_align => 'J');
      
        /*Уже оплачено*/
        plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                ,p_h     => -1
                                ,p_txt   => v_already_payed_text
                                ,p_align => 'J'
                                ,p_ln    => 1);
      
        plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                ,p_h     => -1
                                ,p_txt   => vr_rep_data.abz
                                ,p_align => 'J'
                                ,p_ln    => 1);
      END print_main_text;
    
      /*Реквизиты банков для оплаты*/
      PROCEDURE print_bank_requisite IS
        vc_text_haight CONSTANT NUMBER := 4;
        /*ВТБ-24*/
        PROCEDURE vtb24_requisite IS
        BEGIN
          plpdf.printcell(p_w => vc_one_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Реквизиты для оплаты через банк ВТБ-24:'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Получатель платежа: ООО "СК "Ренессанс Жизнь", ИНН 7725520440, КПП 775001001'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'р/с 40701810019000007118 в ВТБ24 (ЗАО), БИК 044525716, к/с 30101810100000000716.'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Назначение платежа: Страховая премия по договору №' ||
                                        vr_rep_data.ids || ' ' || vr_rep_data.contact_name
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
        END vtb24_requisite;
      
        PROCEDURE other_bank_requisite IS
        BEGIN
          plpdf.printcell(p_w => vc_one_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Реквизиты для оплаты через прочие банки:'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Получатель платежа: ООО "СК "Ренессанс Жизнь", ИНН 7725520440, КПП 775001001,'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'р/с 40701810800001410925 в АО "Райффайзенбанк" г. Москва, БИК 044525700, к/с 30101810200000000700.'
                         ,p_ln       => 1
                         ,p_clipping => 0);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => vc_text_haight, p_clipping => 0);
          plpdf.printcell(p_w        => 0
                         ,p_h        => vc_text_haight
                         ,p_txt      => 'Назначение платежа: Страховая премия по договору №' ||
                                        vr_rep_data.ids || ' ' || vr_rep_data.contact_name
                         ,p_ln       => 1
                         ,p_clipping => 0);
        END other_bank_requisite;
      
      BEGIN
      
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'Оплатить очередной взнос Вы можете по следующим реквизитам:'
                       ,p_ln  => 1);
        /*Оплата через ВТБ-24*/
        vtb24_requisite;
        /*Оплата через другие банк*/
        other_bank_requisite;
      END print_bank_requisite;
    
      /*Оплата без комиссий*/
      PROCEDURE print_pay_without_comission IS
        vc_vertical_space CONSTANT NUMBER := 18;
        vc_text_height CONSTANT NUMBER := 4;
      BEGIN
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'Для уплаты страхового взноса без дополнительных банковских комиссионных сборов Вы можете воспользоваться:'
                       ,p_ln  => 1);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => -1
                       ,p_txt => '1. Отделениями банка "ВТБ24". Со списком отделений банка, в Вашем регионе вы можете'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w   => plpdf.gettextwidth('ознакомиться на сайте банка ') + 2 --50
                       ,p_h   => -1
                       ,p_txt => 'ознакомиться на сайте банка '
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => -1
                       ,p_txt => 'http://www.vtb24.ru/'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.black);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.gettextwidth('2. Личным кабинетом') + 2
                       ,p_h   => -1
                       ,p_txt => '2. Личным кабинетом '
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.gettextwidth('https://lifecabinet.renlife.com/user/login') + 2
                       ,p_h   => -1
                       ,p_txt => 'https://lifecabinet.renlife.com/user/login'
                       ,p_clipping => 0
                        );
        plpdf.setcolor4text(p_color => plpdf_const.black);
        plpdf.printcell(p_w   => plpdf.gettextwidth(', где Вы также можете узнать информацию ')
                       ,p_h   => -1
                       ,p_txt => ', где Вы также можете узнать информацию '
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                       ,p_h   => -1
                       ,p_txt => 'о состоянии Договора страхования'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
        plpdf.printcell(p_w   => plpdf.gettextwidth('3. Интернет сайтом Компании') + 2
                       ,p_h   => -1
                       ,p_txt => '3. Интернет сайтом Компании'
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.blue);
        plpdf.printcell(p_w   => plpdf.gettextwidth('http://www.renlife.com/') + 2
                       ,p_h   => -1
                       ,p_txt => 'http://www.renlife.com/'
                       ,p_ln  => 1
                       ,p_clipping => 0);
        plpdf.setcolor4text(p_color => plpdf_const.black);
          plpdf.printcell(p_w => vc_two_shift_width, p_h => -1);
          plpdf.printcell(p_w   => plpdf.getpageavailablewidth
                         ,p_h   => -1
                         ,p_txt => '4. Услугами Страхового представителя ООО «СК «Ренессанс Жизнь», уполномоченного Компанией принимать '
                         ,p_ln  => 1
                         ,p_clipping => 0);
          plpdf.printmultilinecell(p_w     => plpdf.getpageavailablewidth
                                  ,p_h     => -1
                                  ,p_txt   => 'страховые взносы. Вызвать страхового представителя Вы можете, позвонив по телефону: +7 495 981 2 981.>  Проверить информацию о состоянии Вашей квитанции об оплате страховой премии (взноса) формы № А-7 можно в разделе проверка бланков строгой отчетности на интернет-сайте компании.'
                                  ,p_align => 'J'
                                  ,p_ln    => 1
                                  ,p_clipping => 0);
        plpdf.printcell(p_h => vc_vertical_space, p_ln => 1);
      END print_pay_without_comission;
    
      PROCEDURE print_sign IS
        vr_signer dml_t_signer.tt_t_signer;
      BEGIN
        vr_signer := dml_t_signer.get_record(par_t_signer_id => vp_signer_id);
      
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold_italic);
        plpdf.printcell(p_w   => 0
                       ,p_h   => -1
                       ,p_txt => 'С наилучшими пожеланиями,'
                       ,p_ln  => 1);
        plpdf.printcell(p_w => 0, p_h => -1, p_txt => vp_position_name, p_ln => 1);
        plpdf.printcell(p_w => 0, p_h => -1, p_txt => vp_signer_name, p_ln => 1);
        IF vr_signer.only_sign_jpg IS NOT NULL
        THEN
          plpdf.putimage(p_name => 'only_sign_jpg'
                        ,p_data => vr_signer.only_sign_jpg
                        ,p_x    => plpdf.getpagespace - 45
                        ,p_y    => plpdf.getcurrenty - 20
                        ,p_w    => 15
                        ,p_h    => 25);
        END IF;
      END print_sign;
    
    BEGIN
    
      /*Печать шапки*/
      print_header;
      /*Основной текст*/
      print_main_text;
      /*Реквизиты банков для оплаты*/
      print_bank_requisite;
      /*Оплата без комиссий*/
      print_pay_without_comission;
      /*Подпись*/
      print_sign;
    
    END print_letter;
  
    /*Напечатать текст в начале квитании с чертой в конце*/
    PROCEDURE print_start_text_with_border
    (
      par_text         VARCHAR2 := NULL
     ,par_ln           NUMBER := 0
     ,par_border       VARCHAR2 := 'R'
     ,par_w            NUMBER := vc_receipt_space
     ,par_align        VARCHAR2 := NULL
     ,par_h            NUMBER := -1
     ,par_space_width  NUMBER := 0 /*Ширина пробела после вертикальной черты для квитанций ВТБ*/
     ,par_space_border VARCHAR2 := '0' /*Границы пробела после вертикальной чертны*/
    ) IS
      v_ln NUMBER; --Флаг перевода строки
    BEGIN
      /*Если печатается пробел, то строку не переводим*/
      IF par_space_width > 0
      THEN
        v_ln := 0;
      ELSE
        v_ln := par_ln;
      END IF;
    
      plpdf.printcell(p_w        => par_w
                     ,p_h        => par_h
                     ,p_txt      => par_text
                     ,p_ln       => v_ln
                     ,p_border   => par_border
                     ,p_align    => par_align
                     ,p_clipping => 0);
    
      IF par_space_width > 0
      THEN
        plpdf.printcell(p_w        => par_space_width
                       ,p_h        => par_h
                       ,p_ln       => par_ln
                       ,p_border   => par_space_border
                       ,p_align    => par_align
                       ,p_clipping => 0);
      END IF;
    
    END print_start_text_with_border;
  
    /*Квитаниця ВТБ-24*/
    PROCEDURE print_receipt_vtb24 IS
      vc_left_margin    CONSTANT NUMBER := 17; --Левое поле (для сдвига положения квитанции)
      vc_default_margin CONSTANT NUMBER := 10;
      PROCEDURE print_header IS
        vc_vertical_space CONSTANT NUMBER := 7; --Вертикальный отступ
      BEGIN
        plpdf.printcell(p_h => vc_vertical_space, p_ln => 1);
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 14);
        plpdf.printcell(p_w     => 0
                       ,p_h     => -1
                       ,p_txt   => 'Квитанция для оплаты через банк ВТБ-24'
                       ,p_ln    => 1
                       ,p_align => 'C');
      
      END print_header;
    
      /*Печать слова ИЗВЕЩЕНИЕ*/
      PROCEDURE print_notification_name IS
      BEGIN
        pkg_rep_plpdf.set_font(par_size => 10);
      
        print_start_text_with_border(par_text => NULL, par_ln => 1); --Пустая строка
        print_start_text_with_border(par_text => 'ИЗВЕЩЕНИЕ', par_ln => 1);
      END print_notification_name;
    
      /*Печать слова КВИТАНЦИЯ*/
      PROCEDURE print_receipt_name IS
      BEGIN
        pkg_rep_plpdf.set_font(par_size => 10);
      
        print_start_text_with_border(par_text => NULL, par_ln => 1); --Пустая строка
        print_start_text_with_border(par_text => 'КВИТАНЦИЯ', par_ln => 1);
      END print_receipt_name;
    
      /*Печать слова реквизитов платежа*/
      PROCEDURE print_payment IS
        v_x       NUMBER;
        v_y       NUMBER;
        v_new_y   NUMBER;
        vc_height NUMBER := 4; --Высота строки банковских реквизитов
      
        /*Реквизиты банка*/
        PROCEDURE pring_bank_requisite IS
        BEGIN
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Наименование получателя:  ООО СК "Ренессанс Жизнь"'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'ИНН 7725520440'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Р/с 40701810019000007118 в ВТБ24 (ЗАО)'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        
          print_start_text_with_border(par_h => vc_height, par_space_width => 5);
          plpdf.printcell(p_w        => vc_width_second
                         ,p_h        => vc_height
                         ,p_txt      => 'Кор. сч.30101810100000000716, БИК 044525716'
                         ,p_ln       => 1
                         ,p_clipping => 0);
        END pring_bank_requisite;
      
        /*Реквизиты плательщика*/
        PROCEDURE payer_detail IS
        BEGIN
          print_start_text_with_border(par_space_width => 5, par_space_border => 'B');
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'ФИО Плательщика'
                         ,p_ln     => 1
                         ,p_border => 'B');
          print_start_text_with_border(par_space_width => 5, par_space_border => 'B');
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'Адрес Плательщика'
                         ,p_ln     => 1
                         ,p_border => 'B');
        
          print_start_text_with_border(par_space_width => 5);
          plpdf.printcell(p_w      => 50
                         ,p_h      => -1
                         ,p_txt    => 'ФИО Страхователя'
                         ,p_border => 0);
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w      => vc_width_second - 50
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_border => 0
                         ,p_ln     => 1);
        END payer_detail;
      
        /*Назначение платежа*/
        PROCEDURE payment_dedication IS
        BEGIN
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'T');
          plpdf.printcell(p_w      => 65
                         ,p_h      => -1
                         ,p_txt    => 'Назначение платежа'
                         ,p_border => 'RTB'
                         ,p_align  => 'C');
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => 'Дата', p_border => 1, p_align => 'C');
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => 'Сумма'
                         ,p_border => 1
                         ,p_align  => 'C'
                         ,p_ln     => 1);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'T');
          plpdf.printcell(p_w      => 65
                         ,p_h      => -1
                         ,p_txt    => 'Страховая премия по договору'
                         ,p_border => 'RTB');
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => NULL, p_border => 'LR', p_align => 'C');
          /*Запоминаем позицию курсора для впечатывания суммы*/
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
        
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => NULL
                         ,p_border => 'LR'
                         ,p_align  => 'C'
                         ,p_ln     => 1);
        
          print_start_text_with_border(par_space_width => 5, par_space_border => 'TB');
          plpdf.printcell(p_w      => 35
                         ,p_h      => -1
                         ,p_txt    => 'Серия             Номер'
                         ,p_border => 'TB');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w      => 30
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.ids
                         ,p_border => 'RTB'
                         ,p_align  => 'L');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
          plpdf.printcell(p_w => 25, p_h => -1, p_txt => NULL, p_border => 'LRB', p_align => 'C');
          plpdf.printcell(p_w      => 40
                         ,p_h      => -1
                         ,p_txt    => NULL
                         ,p_border => 'LRB'
                         ,p_align  => 'C'
                         ,p_ln     => 1);
          /*Переводим курсор на нужную позицию для печати объединенной ячейки*/
          v_new_y := plpdf.getcurrenty;
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w     => 40
                         ,p_h     => v_new_y - v_y
                         ,p_txt   => vr_rep_data.sum_zadol
                         ,p_align => 'C'
                         ,p_ln    => 1);
        END payment_dedication;
      
        /*Подпись плательщика и кассира*/
        PROCEDURE payer_sign IS
        BEGIN
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular);
          print_start_text_with_border(par_text => 'Кассир', par_space_width => 5);
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => 'Подпись плательщика'
                         ,p_border => 'R'
                         ,p_ln     => 1);
          --Горизонтальная черта               
          plpdf.printcell(p_w => vc_receipt_space, p_h => 3, p_txt => NULL, p_border => 'BR');
          plpdf.printcell(p_w      => vc_width_second + 5
                         ,p_h      => 3
                         ,p_txt    => NULL
                         ,p_border => 'BR'
                         ,p_ln     => 1);
        END payer_sign;
      BEGIN
        --Реквизиты банка
        pring_bank_requisite;
        --Реквизиты плательщика
        payer_detail;
        --Назанчение платежа
        payment_dedication;
        --Подпись плательщика и кассира
        payer_sign;
      
      END print_payment;
    
      /*Печать строки с валютой*/
      PROCEDURE print_fund_string IS
      BEGIN
        plpdf.printcell(p_h => -1, p_txt => vr_rep_data.fund_str, p_ln => 1);
      END print_fund_string;
    
    BEGIN
      plpdf.newpage;
      /*Выставление полей для выравнивания положения квитанции*/
      plpdf.setleftmargin(p_margin => vc_left_margin);
    
      --Шапка
      print_header;
      --Извещение
      print_notification_name; --Печать типа Извещение или Квитанция
      --Реквизиты платежа
      print_payment;
    
      --Квитанция
      print_receipt_name; --Печать типа Извещение или Квитанция
      --Реквизиты платежа
      print_payment;
    
      --Строка с валютой
      print_fund_string;
    
      /*Возвращение к дефолтным размерам полей*/
      plpdf.setleftmargin(p_margin => vc_default_margin);
    
    END print_receipt_vtb24;
  
    /*Квитаниця для остальных банков*/
    PROCEDURE print_receipt_other_bank IS
      vc_left_margin    CONSTANT NUMBER := 14; --Левое поле (для сдвига положения квитанции)
      vc_default_margin CONSTANT NUMBER := 10;
      vc_part_one_width CONSTANT NUMBER := 28; --Ширина первой части квитанции
      vc_width_second   CONSTANT NUMBER := 140; --Ширина второй части квитанции
      vc_middle_space   CONSTANT NUMBER := 5; --Отступ после вертикальной черты
      /*Печать отступа после вертикальной черты*/
      PROCEDURE print_middle_space
      (
        par_border VARCHAR2 := '0'
       ,par_h      NUMBER := -1
      ) IS
      BEGIN
        plpdf.printcell(p_w => vc_middle_space, p_h => par_h, p_border => par_border);
      END print_middle_space;
    
      /*Печать стандартной строки квитанции*/
      PROCEDURE print_row
      (
        par_text1       VARCHAR2 := NULL
       ,par_text2       VARCHAR2 := NULL
       ,par_style_text1 VARCHAR2 := NULL
       ,par_style_text2 VARCHAR2 := NULL
       ,par_align1      VARCHAR2 := NULL
       ,par_align2      VARCHAR2 := NULL
       ,par_font_size1  NUMBER := NULL
       ,par_font_size2  NUMBER := NULL
       ,par_border1     VARCHAR2 := 'LR'
       ,par_border2     VARCHAR2 := 'R'
       ,par_h1          NUMBER := -1 --Высота строки
       ,par_h2          NUMBER := -1
      ) IS
        v_middle_border VARCHAR2(10);
      BEGIN
        IF par_style_text1 IS NOT NULL
           OR par_font_size1 IS NOT NULL
        THEN
          pkg_rep_plpdf.set_font(par_style => par_style_text1, par_size => par_font_size1);
        END IF;
        print_start_text_with_border(par_border => par_border1
                                    ,par_w      => vc_part_one_width
                                    ,par_text   => par_text1
                                    ,par_align  => par_align1
                                    ,par_h      => par_h1);
        IF instr(par_border1, 'T') != 0
        THEN
          v_middle_border := 'T';
        ELSIF instr(par_border1, 'B') != 0
        THEN
          v_middle_border := 'B';
        END IF;
        print_middle_space(par_border => v_middle_border, par_h => par_h2);
        IF par_style_text2 IS NOT NULL
        THEN
          pkg_rep_plpdf.set_font(par_style => par_style_text2, par_size => par_font_size2);
        END IF;
        plpdf.printcell(p_w        => vc_width_second
                       ,p_h        => par_h2
                       ,p_txt      => par_text2
                       ,p_ln       => 1
                       ,p_align    => par_align2
                       ,p_border   => par_border2
                       ,p_clipping => 0);
      END print_row;
    
      PROCEDURE print_header IS
      BEGIN
        pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 14);
        plpdf.printcell(p_w     => 0
                       ,p_h     => -1
                       ,p_txt   => 'Квитанция для оплаты через прочие банки'
                       ,p_ln    => 1
                       ,p_align => 'C');
        /*Пустая строка*/
        plpdf.printcell(p_w => 0, p_h => -1, p_ln => 1);
      
      END print_header;
    
      PROCEDURE print_pd4 IS
      BEGIN
        print_row(par_text2       => 'Форма ПД-4'
                 ,par_style_text1 => pkg_rep_plpdf.gc_style_bold
                 ,par_style_text2 => pkg_rep_plpdf.gc_style_bold
                 ,par_align2      => 'R'
                 ,par_font_size1  => 13
                 ,par_font_size2  => 13
                 ,par_border1     => 'LTR'
                 ,par_border2     => 'TR');
      
      END print_pd4;
      --par_type  -1 Извещение  (верхняя часть), 2 - квитанция (нижняя часть)
      PROCEDURE print_insurer_info(par_type NUMBER) IS
      BEGIN
        IF par_type = 2
        THEN
          /*Отступ для нижней части*/
          print_row;
        END IF;
        print_row(par_text2       => 'ООО "СК "Ренессанс Жизнь"'
                 ,par_style_text1 => pkg_rep_plpdf.gc_style_bold
                 ,par_style_text2 => pkg_rep_plpdf.gc_style_bold
                 ,par_font_size1  => 10
                 ,par_font_size2  => 10);
      END print_insurer_info;
    
      /*Печать слова реквизитов платежа*/
      --par_type  -1 Извещение  (верхняя часть), 2 - квитанция (нижняя часть)
      PROCEDURE print_payment(par_type NUMBER) IS
        v_x     NUMBER;
        v_y     NUMBER;
        v_new_y NUMBER;
      
        /*Реквизиты банка*/
        PROCEDURE pring_bank_requisite IS
          v_text1        VARCHAR2(200);
          vr_t_rep_image dml_t_rep_image.tt_t_rep_image;
          v_height       NUMBER := 4; --Высота строки
        
        BEGIN
        
          IF par_type = 1
          THEN
            v_text1 := 'Отправить в д/о';
          END IF;
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          print_row(par_text1 => v_text1
                   ,par_text2 => 'ИНН 7725520440, КПП 775001001'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          vr_t_rep_image := dml_t_rep_image.get_rec_by_brief(par_brief => 'RENLIFE_LETTER');
          plpdf.putimage(p_name => 'image_for_letter'
                        ,p_data => vr_t_rep_image.image
                        ,p_x    => plpdf.getpagespace - 45
                        ,p_y    => plpdf.getcurrenty - 10
                        ,p_w    => 30
                        ,p_h    => 12);
        
          IF par_type = 1
          THEN
            v_text1 := '___________';
          END IF;
          print_row(par_text1 => v_text1
                   ,par_text2 => 'Р/с 40701810800001410925'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          print_row(par_text1 => NULL
                   ,par_text2 => 'В АО "Райффайзенбанк" г. Москва'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        
          print_row(par_text1 => NULL
                   ,par_text2 => 'БИК 044525700, К/С 30101810200000000700'
                   ,par_h1    => v_height
                   ,par_h2    => v_height);
        END pring_bank_requisite;
      
        /*Реквизиты плательщика*/
        PROCEDURE payer_detail IS
          v_x            NUMBER;
          v_y            NUMBER;
          v_height_small NUMBER := 3; --высота строки подписи
        BEGIN
          IF par_type = 1
          THEN
            print_row(par_text1 => 'ИЗВЕЩЕНИЕ', par_text2 => NULL);
          ELSE
            print_row(par_text1 => 'КВИТАНЦИЯ', par_text2 => NULL);
          END IF;
          print_row(par_text1 => 'Кассир'
                   ,par_text2 => 'Плательщик___________________________________________________________');
          print_row(par_text1      => NULL
                   ,par_text2      => '(Фамилия, Имя, Отчество плательщика)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
          print_row(par_text1      => NULL
                   ,par_text2      => '______________________________________________________________________'
                   ,par_font_size1 => 10);
          print_row(par_text1      => NULL
                   ,par_text2      => '(Адрес плательщика)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
        
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          /*Страхователь*/
          print_start_text_with_border(par_text => NULL, par_border => 'LR');
          print_middle_space;
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
          plpdf.printcell(p_w   => vc_width_second
                         ,p_h   => -1
                         ,p_txt => 'Страхователь_________________________________________________________');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w      => vc_width_second
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_ln     => 1
                         ,p_border => 'R'
                         ,p_align  => 'C');
          print_row(par_text1      => NULL
                   ,par_text2      => '(Фамилия, Имя, Отчество страхователя)'
                   ,par_font_size1 => 8
                   ,par_align2     => 'C'
                   ,par_h1         => v_height_small
                   ,par_h2         => v_height_small);
        END payer_detail;
      
        /*Назначение платежа*/
        PROCEDURE payment_dedication IS
          v_vertical_space NUMBER := 2; --Высота вертикального отступа
        BEGIN
          /*Отступ*/
          print_row(par_text1 => NULL
                   ,par_text2 => NULL
                   ,par_h1    => v_vertical_space
                   ,par_h2    => v_vertical_space);
          /*Строка 1*/
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_regular, par_size => 10);
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w      => 90
                         ,p_h      => -1
                         ,p_txt    => 'Назначение платежа: Страховая премия'
                         ,p_border => 'LTR');
        
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => 'Сумма', p_border => 1, p_align => 'C');
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Строка 2*/
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w => 28, p_h => -1, p_txt => 'по договору № ', p_border => 'L');
          pkg_rep_plpdf.set_font(par_style => pkg_rep_plpdf.gc_style_bold);
          plpdf.printcell(p_w => 62, p_h => -1, p_txt => vr_rep_data.ids, p_border => '0');
          /*Запоминаем для впечатывания суммы в обобщенную ячейку*/
          v_x := plpdf.getcurrentx;
          v_y := plpdf.getcurrenty;
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => NULL, p_border => 'LR');
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Строка 3*/
          print_start_text_with_border(par_border => 'LR', par_w => vc_part_one_width);
          print_middle_space(par_border => 'LR');
          plpdf.printcell(p_w      => 90
                         ,p_h      => -1
                         ,p_txt    => vr_rep_data.contact_name
                         ,p_border => 'LB'
                         ,p_align  => 'C');
          plpdf.printcell(p_w => 30, p_h => -1, p_txt => NULL, p_border => 'LRB');
        
          plpdf.printcell(p_w => 20, p_h => -1, p_border => 'R', p_ln => 1);
          /*Впечатываем сумму в обобщенную ячейку*/
          v_new_y := plpdf.getcurrenty;
          plpdf.setcurrentxy(p_x => v_x, p_y => v_y);
          plpdf.printcell(p_w     => 30
                         ,p_h     => v_new_y - v_y
                         ,p_txt   => vr_rep_data.sum_zadol
                         ,p_align => 'C'
                         ,p_ln    => 1);
          /*Отступ*/
          print_row(par_text1 => NULL
                   ,par_text2 => NULL
                   ,par_h1    => v_vertical_space
                   ,par_h2    => v_vertical_space);
        END payment_dedication;
      
        /*Подпись плательщика и кассира*/
        PROCEDURE payer_sign IS
          v_height NUMBER := 1;
        BEGIN
          print_row(par_text1      => NULL
                   ,par_text2      => '"______"________________ 20___г.        Подпись плательщика _______________'
                   ,par_font_size1 => 10);
          --Горизонтальная черта
          print_row(par_text1   => NULL
                   ,par_text2   => NULL
                   ,par_border1 => 'LBR'
                   ,par_border2 => 'BR'
                   ,par_h1      => v_height
                   ,par_h2      => v_height);
        END payer_sign;
      BEGIN
        --Реквизиты банка
        pring_bank_requisite;
        --Реквизиты плательщика
        payer_detail;
        --Назанчение платежа
        payment_dedication;
        --Подпись плательщика и кассира
        payer_sign;
      
      END print_payment;
    
      /*Печать строки с валютой*/
      PROCEDURE print_fund_string IS
      BEGIN
        plpdf.printcell(p_h => -1, p_txt => vr_rep_data.fund_str, p_ln => 1);
      END print_fund_string;
    
    BEGIN
      plpdf.newpage;
      /*Выставление полей для выравнивания положения квитанции*/
      plpdf.setleftmargin(p_margin => vc_left_margin);
    
      --Шапка
      print_header;
      --печать строки о ПД-4
      print_pd4;
      --Ренессанс
      print_insurer_info(par_type => 1);
      --Реквизиты платежа
      print_payment(par_type => 1);
    
      --Ренессанс
      print_insurer_info(par_type => 2);
      --Реквизиты платежа
      print_payment(par_type => 2);
    
      /*Печать строки с валютой*/
      print_fund_string;
    
      /*Возвращение к дефолтным размерам полей*/
      plpdf.setleftmargin(p_margin => vc_default_margin);
    END print_receipt_other_bank;
  
  BEGIN
  
    /*инициализация входных параметров*/
    init_input_parameters;
    --Инициализация параметров процедуры
    beforereport;
    -- Инициализация PL/PDF
    pkg_rep_plpdf.init(par_default_font_size => vc_default_font_size);
    --Установка черного цвета шрифта  
    pkg_rep_plpdf.set_font;
  
    /*Цикл по письмам, отмеченным галочкой на форме*/
    v_is_first_letter := TRUE;
    OPEN cur_rep_data(vp_sid);
    LOOP
      FETCH cur_rep_data
        INTO vr_rep_data;
      EXIT WHEN cur_rep_data%NOTFOUND;
    
      IF NOT v_is_first_letter
      THEN
        plpdf.newpage; --Для первого письмо новая страница в init делается
      END IF;
    
      v_is_first_letter := FALSE;
      /*Печать первой страницы письма*/
      print_letter;
      /*Печать квитанции для ВТБ-24*/
      print_receipt_vtb24;
      /*Печать квитанции для остальных банков*/
      print_receipt_other_bank;
    END LOOP;
    CLOSE cur_rep_data;
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'remind_letter_30_days_' || vp_sid || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF cur_rep_data%ISOPEN
      THEN
        CLOSE cur_rep_data;
      END IF;
      RAISE;
  END remind_30_days_before_pay;

  -- Author  : Григорьев Ю.
  -- Created : 29.01.2015
  -- Purpose : Список страхователей, которым высылается письмо-напоминание в льготный период с уведомлением (Excel)

  PROCEDURE remind_in_grace_period_excel
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    vp_number VARCHAR2(500); --Исходящий номер
    vp_sid    NUMBER; --ИД сессии пользователя, который печатает отчеты
    l_blob    BLOB;
  
    CURSOR cur_rep_data
    (
      par_sessionid NUMBER
     ,par_number    VARCHAR2
    ) IS
      SELECT rownum rec_number
            ,to_char(trunc(SYSDATE), 'dd.mm.yyyy') sys_date
            ,to_char(trunc(SYSDATE), 'mm') p_month
            ,to_char(trunc(SYSDATE), 'yyyy') p_year
            ,contact_name
            ,contact_id
            ,address_name
            ,fadr
            ,city_name
            ,distr_name
            ,region_name
            ,province_name
            ,country_name
            ,zip
            ,ids
            ,fee
            ,TRIM(to_char(non_pay_amount, '999999999D99')) non_pay_amount
            ,TRIM(to_char(nvl(non_pay_amount, 0) + fee - (nvl(part_pay_amount, 0)), '999999999D99')) sum_zadol
            ,TRIM(to_char(part_pay_amount, '999999999D99')) part_pay_amount
            ,product
            ,start_date
            ,payment_period
            ,fund_brief
            ,TRIM(to_char(pay_amount, '999999999D99')) pay_amount
            ,to_char(last_payd, 'dd.mm.yyyy') last_payd
            ,to_char(first_unpayd, 'dd.mm.yyyy') first_unpayd
            ,grace_period
            ,pol_ser
            ,pol_num
            ,code
            ,due_date
            ,plan_date
            ,grace_date
            ,'22' || lpad(par_number + rownum - 1, 6, '0') vhnum
            ,agent_current
            ,leader_agent
            ,leader_manag
            ,last_pol_status
        FROM (SELECT vlp.contact_name
                    ,vlp.contact_id
                    ,vlp.address_name
                    ,vlp.pol_ser
                    ,vlp.pol_num
                    ,to_char(vlp.grace_date + 1, 'dd.mm.yyyy') grace_period
                    ,vlp.fadr
                    ,TRIM(to_char(vlp.oplata, '999999999D99')) fee
                    ,vlp.city_name
                    ,to_char(vlp.plan_date, 'dd.mm.yyyy') plan_date
                    ,vlp.province_name
                    ,vlp.distr_name
                    ,vlp.region_name
                    ,vlp.country_name
                    ,vlp.zip
                    ,vlp.code
                    ,ph.ids
                    ,pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 2) last_payd
                    ,pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 1) first_unpayd
                    ,prod.description product
                    ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                    ,vlp.payment_period
                    ,f.brief fund_brief
                    ,pkg_policy.get_last_version_status(ph.policy_header_id) AS last_pol_status
                    ,(SELECT SUM(a.amount) -
                             SUM(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL))
                        FROM document       d
                            ,ac_payment     a
                            ,doc_templ      dt
                            ,doc_doc        dd
                            ,p_policy       p
                            ,p_pol_header   pph
                            ,contact        c
                            ,doc_status     ds
                            ,doc_status_ref dsr
                       WHERE d.document_id = a.payment_id
                         AND d.doc_templ_id = dt.doc_templ_id
                         AND dt.brief = 'PAYMENT'
                         AND dd.child_id = d.document_id
                         AND dd.parent_id = p.policy_id
                         AND pph.policy_header_id = p.pol_header_id
                         AND a.contact_id = c.contact_id
                         AND ds.document_id = d.document_id
                         AND ds.start_date = (SELECT MAX(dss.start_date)
                                                FROM doc_status dss
                                               WHERE dss.document_id = d.document_id)
                         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                         AND dsr.name <> 'Аннулирован'
                         AND a.plan_date BETWEEN pph.start_date AND vlp.prev_due_date
                         AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                         AND p.pol_header_id = ph.policy_header_id) non_pay_amount
                    ,(SELECT SUM(nvl(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL), 0))
                        FROM document       d
                            ,ac_payment     a
                            ,doc_templ      dt
                            ,doc_doc        dd
                            ,p_policy       p
                            ,p_pol_header   pph
                            ,contact        c
                            ,doc_status     ds
                            ,doc_status_ref dsr
                       WHERE d.document_id = a.payment_id
                         AND d.doc_templ_id = dt.doc_templ_id
                         AND dt.brief = 'PAYMENT'
                         AND dd.child_id = d.document_id
                         AND dd.parent_id = p.policy_id
                         AND pph.policy_header_id = p.pol_header_id
                         AND a.contact_id = c.contact_id
                         AND ds.document_id = d.document_id
                         AND ds.start_date = (SELECT MAX(dss.start_date)
                                                FROM doc_status dss
                                               WHERE dss.document_id = d.document_id)
                         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                         AND dsr.name NOT IN ('Аннулирован', 'Оплачен')
                         AND a.plan_date BETWEEN vlp.due_date AND vlp.due_date
                         AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                         AND p.pol_header_id = ph.policy_header_id) part_pay_amount
                    ,(SELECT SUM(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL))
                        FROM document       d
                            ,ac_payment     a
                            ,doc_templ      dt
                            ,doc_doc        dd
                            ,p_policy       p
                            ,p_pol_header   pph
                            ,contact        c
                            ,doc_status     ds
                            ,doc_status_ref dsr
                       WHERE d.document_id = a.payment_id
                         AND d.doc_templ_id = dt.doc_templ_id
                         AND dt.brief = 'PAYMENT'
                         AND dd.child_id = d.document_id
                         AND dd.parent_id = p.policy_id
                         AND pph.policy_header_id = p.pol_header_id
                         AND a.contact_id = c.contact_id
                         AND ds.document_id = d.document_id
                         AND ds.start_date = (SELECT MAX(dss.start_date)
                                                FROM doc_status dss
                                               WHERE dss.document_id = d.document_id)
                         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                         AND dsr.name <> 'Аннулирован'
                         AND a.plan_date BETWEEN pph.start_date AND vlp.prev_due_date
                         AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                         AND p.pol_header_id = ph.policy_header_id) pay_amount
                    ,
                     
                     to_char(vlp.due_date, 'dd.mm.yyyy') due_date
                    ,to_char(vlp.grace_date, 'dd.mm.yyyy') grace_date
                    ,vlp.agent_current
                    ,vlp.leader_agent
                    ,vlp.leader_manag
                FROM v_letters_payment vlp
                    ,notif_letter_rep  nlr
                    ,p_pol_header      ph
                    ,ins.p_policy      p
                    ,t_product         prod
                    ,fund              f
               WHERE vlp.document_id = nlr.document_id
                 AND nlr.sessionid = par_sessionid
                 AND vlp.pol_header_id = ph.policy_header_id
                 AND prod.product_id = ph.product_id
                 AND ph.fund_id = f.fund_id
                 AND ph.policy_id = p.policy_id
                 AND p.payment_term_id != 1 --Единовременно
               ORDER BY upper(vlp.contact_name));
    vr_rep_data cur_rep_data%ROWTYPE;
  
    PROCEDURE init_input_parameters IS
    BEGIN
      vp_sid    := to_number(repcore.get_context('SID'));
      vp_number := repcore.get_context('PNUMBER');
    END init_input_parameters;
  
    PROCEDURE print_header
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
     ,par_width      NUMBER
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_font(par_cell_index, 'Calibri', 11);
      ora_excel.set_cell_bold(par_cell_index);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_middle(par_cell_index);
      ora_excel.set_cell_border(par_cell_index);
      ora_excel.set_cell_bg_color(par_cell_index, '999999');
      ora_excel.set_column_width(par_cell_index, par_width);
    END;
  
    PROCEDURE print_align_center_bottom_cell
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_bottom(par_cell_index);
      ora_excel.set_cell_wrap_text(par_cell_index);
      ora_excel.set_cell_border(par_cell_index);
    END;
  
    PROCEDURE print_col_align_centr_mid_cell
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
     ,par_color      VARCHAR2 DEFAULT '999999'
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_bold(par_cell_index);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_middle(par_cell_index);
      ora_excel.set_cell_wrap_text(par_cell_index);
      ora_excel.set_cell_bg_color(par_cell_index, par_color);
      ora_excel.set_cell_border(par_cell_index);
    END;
  
    PROCEDURE print_footer IS
    BEGIN
      ora_excel.add_row;
      ora_excel.add_row;
    
      ora_excel.set_cell_value('A'
                              ,'Передал: ____________________/______________________________________');
      ora_excel.set_cell_font('A', 'Calibri', 11);
      ora_excel.set_cell_bold('A');
      ora_excel.merge_cells('A', 'AT');
      ora_excel.set_cell_align_left('A');
      ora_excel.set_cell_vert_align_middle('A');
    
      ora_excel.add_row;
      ora_excel.add_row;
    
      ora_excel.set_cell_value('A'
                              ,'Принял: _____________________/______________________________________');
      ora_excel.set_cell_font('A', 'Calibri', 11);
      ora_excel.set_cell_bold('A');
      ora_excel.merge_cells('A', 'AT');
      ora_excel.set_cell_align_left('A');
      ora_excel.set_cell_vert_align_middle('A');
    END;
  
  BEGIN
  
    init_input_parameters;
  
    ora_excel.new_document;
    ora_excel.add_sheet('Report');
  
    --Шапка отчета
    ora_excel.add_row;
    ora_excel.set_row_height(46.5);
    ora_excel.set_cell_value('A'
                            ,'Список' || chr(10) ||
                             'Письмо-напоминание в льготный период с уведомлением (PDF от 28.06.2010) (отправка с уведомлением)');
    ora_excel.set_cell_font('A', 'Calibri', 12);
    ora_excel.set_cell_bold('A');
    ora_excel.merge_cells('A', 'AB');
    ora_excel.set_cell_align_center('A');
    ora_excel.set_cell_vert_align_middle('A');
    ora_excel.set_cell_wrap_text('A');
  
    --Шапка таблицы отчета
    ora_excel.add_row;
    ora_excel.set_row_height(15);
  
    print_header('A', '№', 3);
    print_header('B', 'Исходящий номер', 18);
    print_header('C', 'Страхователь', 33);
    print_header('D', 'Серия', 8);
    print_header('E', 'Номер', 12);
    print_header('F', 'Строка адреса', 29);
    print_header('G', 'Город', 21);
    print_header('H', 'Населенный пункт', 18);
    print_header('I', 'Район', 15);
    print_header('J', 'Область, республика', 21);
    print_header('K', 'Страна', 22);
    print_header('L', 'Индекс', 8);
    print_header('M', 'Адрес Страхователя', 36);
    print_header('N', 'Программа', 15);
    print_header('O', 'Дата начала действия ДС', 24);
    print_header('P', 'Периодичность', 16);
    print_header('Q', 'Валюта ответственности', 23);
    print_header('R', 'Дата последнего оплаченного ЭПГ', 33);
    print_header('S', 'Дата первого неоплаченного ЭПГ', 32);
    print_header('T', 'Оплачено', 10);
    print_header('U', 'Сумма задолженности', 22);
    print_header('V', 'Сумма ЭПГ к оплате', 19);
    print_header('W', 'Из них оплачено', 16);
    print_header('X', 'Общая задолженность', 23);
    print_header('Y', 'Дата ЭПГ', 10);
    print_header('Z', 'Дата расторжения', 18);
    print_header('AA', 'ИДС договора', 14);
    print_header('AB', 'Регион', 21);
    print_header('AC', 'Действующий агент', 36);
    print_header('AD', 'Руководитель агента/Менеджер', 32);
    print_header('AE', 'Руководитель менеджера/Директор', 36);
    print_header('AF', 'Статус последней версии', 24);
    print_header('AG', 'Contact_ID', 10);
    print_header('AH', 'Вид сообщения', 15);
    print_header('AI', 'Тип сообщения', 18);
    print_header('AJ', 'Тип реквизита', 14);
    print_header('AK', 'Статус', 10);
    print_header('AL', 'Описание', 36);
    print_header('AM', 'Тема сообщения', 36);
    print_header('AN', 'Дата регистрации', 17);
    print_header('AO', 'Номер реестра', 17);
    print_header('AP', 'Инициатор доставки', 20);
    print_header('AQ', 'Порядковый номер', 20);
    print_header('AR', 'Комментарий', 17);
  
    --Вывод данных запроса в таблицу
    OPEN cur_rep_data(vp_sid, vp_number);
    LOOP
      FETCH cur_rep_data
        INTO vr_rep_data;
      EXIT WHEN cur_rep_data%NOTFOUND;
    
      ora_excel.add_row;
      ora_excel.set_row_height(90);
      print_align_center_bottom_cell('A', vr_rep_data.rec_number);
      print_align_center_bottom_cell('B'
                                    ,vr_rep_data.vhnum || '-' || vr_rep_data.p_month || '/' ||
                                     vr_rep_data.p_year);
      print_align_center_bottom_cell('C', vr_rep_data.contact_name);
      print_align_center_bottom_cell('D', vr_rep_data.pol_ser);
      print_align_center_bottom_cell('E', vr_rep_data.pol_num);
      print_align_center_bottom_cell('F', vr_rep_data.fadr);
      print_align_center_bottom_cell('G', vr_rep_data.city_name);
      print_align_center_bottom_cell('H', vr_rep_data.distr_name);
      print_align_center_bottom_cell('I', vr_rep_data.region_name);
      print_align_center_bottom_cell('J', vr_rep_data.province_name);
      print_align_center_bottom_cell('K', vr_rep_data.country_name);
      print_align_center_bottom_cell('L', vr_rep_data.zip);
      print_align_center_bottom_cell('M', vr_rep_data.address_name);
      print_align_center_bottom_cell('N', vr_rep_data.product);
      print_align_center_bottom_cell('O', vr_rep_data.start_date);
      print_align_center_bottom_cell('P', vr_rep_data.payment_period);
      print_align_center_bottom_cell('Q', vr_rep_data.fund_brief);
      print_align_center_bottom_cell('R', vr_rep_data.last_payd);
      print_align_center_bottom_cell('S', vr_rep_data.first_unpayd);
      print_align_center_bottom_cell('T', vr_rep_data.pay_amount);
      print_align_center_bottom_cell('U', vr_rep_data.non_pay_amount);
      print_align_center_bottom_cell('V', vr_rep_data.fee);
      print_align_center_bottom_cell('W', vr_rep_data.part_pay_amount);
      print_align_center_bottom_cell('X', vr_rep_data.sum_zadol);
      print_align_center_bottom_cell('Y', vr_rep_data.plan_date);
      print_align_center_bottom_cell('Z', vr_rep_data.grace_period);
      print_align_center_bottom_cell('AA', vr_rep_data.ids);
      print_align_center_bottom_cell('AB', vr_rep_data.code);
      print_align_center_bottom_cell('AC', vr_rep_data.agent_current);
      print_align_center_bottom_cell('AD', vr_rep_data.leader_agent);
      print_align_center_bottom_cell('AE', vr_rep_data.leader_manag);
      print_align_center_bottom_cell('AF', vr_rep_data.last_pol_status);
      print_col_align_centr_mid_cell('AG', vr_rep_data.contact_id);
      print_col_align_centr_mid_cell('AH', 'Исходящий');
      print_col_align_centr_mid_cell('AI'
                                    ,'письмо в льготный период (с уведомлением)');
      print_col_align_centr_mid_cell('AJ', 'Адрес');
      print_col_align_centr_mid_cell('AK', 'Отправлен');
      print_col_align_centr_mid_cell('AL'
                                    ,'Очередной страховой взнос ' || vr_rep_data.fee ||
                                     ', задолженность по оплате предыдущих взносов ' ||
                                     vr_rep_data.sum_zadol || ' ' || vr_rep_data.fund_brief ||
                                     ', предполагаемая дата расторжения ' || vr_rep_data.grace_period ||
                                     ', дата окончания ЛП ' || vr_rep_data.plan_date);
      print_col_align_centr_mid_cell('AM'
                                    ,'письмо ЛП-напоминание об оплате (с уведомлением)');
      print_col_align_centr_mid_cell('AN', '');
      print_col_align_centr_mid_cell('AO', '');
      print_col_align_centr_mid_cell('AP', '');
      print_col_align_centr_mid_cell('AQ', '');
      print_col_align_centr_mid_cell('AR', '');
    
    END LOOP;
  
    --Вывод строки "Всего..." и строк для подписей
    ora_excel.add_row;
    ora_excel.add_row;
  
    ora_excel.set_cell_value('A', 'Всего ' || to_char(ora_excel.current_row_id - 4)); -- Если запрос не возвращает ни одной строки, то строка с "Всего..." расположена на 4 строке, и значит получим "Всего 0". Если на 5, то "Всего 1", и т.д.
    ora_excel.set_cell_font('A', 'Calibri', 11);
    ora_excel.set_cell_bold('A');
    ora_excel.merge_cells('A', 'AT');
    ora_excel.set_cell_align_left('A');
    ora_excel.set_cell_vert_align_middle('A');
  
    print_footer;
  
    ora_excel.save_to_blob(l_blob);
  
    par_data         := l_blob;
    par_file_name    := 'remind_letter_report_' || vp_sid || '.xlsx';
    par_content_type := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  
    ora_excel.close_document;
  
  END;

  -- Author  : Григорьев Ю.
  -- Created : 29.01.2015
  -- Purpose : Список страхователей, которым высылается письмо-напоминание за 30 дней до оплаты (Excel)

  PROCEDURE remind_30days_before_pay_excel
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    vp_number VARCHAR2(500); --Исходящий номер
    vp_sid    NUMBER; --ИД сессии пользователя, который печатает отчеты
    l_blob    BLOB;
  
    CURSOR cur_rep_data
    (
      par_sessionid NUMBER
     ,par_number    VARCHAR2
    ) IS
      SELECT rownum rec_number
            ,21 || lpad(par_number + rownum - 1, 6, '0') vhnum
            ,to_char(trunc(SYSDATE), 'dd.mm.yyyy') sys_date
            ,to_char(trunc(SYSDATE), 'mm') p_month
            ,to_char(trunc(SYSDATE), 'yyyy') p_year
            ,b.*
        FROM (SELECT mn.*
                    ,TRIM(to_char(sum_zadol_num, '9999999990D00')) || CASE
                       WHEN fund != 'RUR' THEN
                        ' * '
                     END sum_zadol
                FROM (SELECT payment_period
                            ,contact_name
                            ,contact_name || '!' contact_name_1
                            ,address_name
                            ,fadr
                            ,distr_name
                            ,CASE
                               WHEN nvl(distr_name, 'X') <> 'X'
                                    AND nvl(city_name, 'X') <> 'X' THEN
                                city_name || ', ' || distr_name
                               ELSE
                                (CASE
                                  WHEN nvl(distr_name, 'X') = 'X' THEN
                                   city_name
                                  ELSE
                                   distr_name
                                END)
                             END city_name
                            ,province_name
                            ,region_name
                            ,CASE
                               WHEN nvl(country_name, 'X') <> 'X'
                                    AND nvl(province_name, 'X') <> 'X' THEN
                                province_name || ', ' || country_name
                               ELSE
                                (CASE
                                  WHEN nvl(province_name, 'X') = 'X' THEN
                                   country_name
                                  ELSE
                                   province_name
                                END)
                             END country_name
                            ,zip
                            ,code
                            ,init_name
                            ,due_date
                            ,fund
                            ,pol_num
                            ,ids
                            ,flag
                            ,dog_num
                            ,pol_ser
                            ,type_contact
                            ,is_adm
                            ,gender
                            ,product
                            ,start_date
                            ,to_char(last_payd, 'dd.mm.yyyy') last_payd
                            ,to_char(first_unpayd, 'dd.mm.yyyy') first_unpayd
                            ,oplata
                            ,pay_amount
                            ,agent_current
                            ,leader_agent
                            ,leader_manag
                            ,contact_id
                            ,grace_period
                            ,plan_date
                            ,CASE mb
                               WHEN 0 THEN
                                TRIM(to_char(fee, '9999999990D00'))
                               ELSE
                                TRIM(to_char(amount, '9999999990D00'))
                             END amount
                            ,CASE
                               WHEN nvl(part_pay_amount, 0) > 0 THEN
                                TRIM(to_char((CASE mb
                                               WHEN 0 THEN
                                                fee
                                               ELSE
                                                amount
                                             END) - nvl(part_pay_amount, 0)
                                            ,'9999999990D00'))
                               ELSE
                                TRIM(to_char((CASE mb
                                               WHEN 0 THEN
                                                fee
                                               ELSE
                                                amount
                                             END)
                                            ,'9999999990D00'))
                             END amount_new
                            ,last_pol_status
                            ,TRIM(to_char(non_pay_amount, '9999999990D00')) non_pay_amount
                            ,decode(mb, 0, fee, amount) - ir_amount - abs(nvl(part_pay_amount, 0)) sum_zadol_num
                            ,TRIM(to_char(nvl(part_pay_amount, 0), '9999999990D00')) part_pay_amount
                        FROM (SELECT
                              
                               (SELECT SUM(a.amount) -
                                       SUM(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL))
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                 WHERE d.document_id = a.payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name <> 'Аннулирован'
                                   AND a.plan_date BETWEEN pph.start_date AND vlp.prev_due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) non_pay_amount
                              ,
                               
                               (SELECT SUM(nvl(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL)
                                              ,0))
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                 WHERE d.document_id = a.payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name NOT IN ('Аннулирован', 'Оплачен')
                                   AND a.plan_date BETWEEN vlp.due_date AND vlp.due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) part_pay_amount
                              ,(SELECT nvl(SUM(ir.invest_reserve_amount), 0)
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                      ,ac_payment_ir  ir
                                 WHERE d.document_id = a.payment_id
                                   AND a.payment_id = ir.ac_payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name NOT IN ('Аннулирован', 'Оплачен')
                                   AND a.plan_date BETWEEN vlp.due_date AND vlp.due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) ir_amount
                              ,(SELECT SUM(pkg_payment.get_set_off_amount(d.document_id, NULL, NULL))
                                  FROM document       d
                                      ,ac_payment     a
                                      ,doc_templ      dt
                                      ,doc_doc        dd
                                      ,p_policy       p
                                      ,p_pol_header   pph
                                      ,contact        c
                                      ,doc_status     ds
                                      ,doc_status_ref dsr
                                 WHERE d.document_id = a.payment_id
                                   AND d.doc_templ_id = dt.doc_templ_id
                                   AND dt.brief = 'PAYMENT'
                                   AND dd.child_id = d.document_id
                                   AND dd.parent_id = p.policy_id
                                   AND pph.policy_header_id = p.pol_header_id
                                   AND a.contact_id = c.contact_id
                                   AND ds.document_id = d.document_id
                                   AND ds.start_date =
                                       (SELECT MAX(dss.start_date)
                                          FROM doc_status dss
                                         WHERE dss.document_id = d.document_id)
                                   AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                                   AND dsr.name <> 'Аннулирован'
                                   AND a.plan_date BETWEEN pph.start_date AND vlp.prev_due_date
                                   AND a.due_date >= to_date('01.01.2008', 'dd.mm.yyyy')
                                   AND p.pol_header_id = ph.policy_header_id) pay_amount
                              ,vlp.payment_period
                              ,vlp.contact_name
                              ,vlp.contact_id
                              ,vlp.address_name
                              ,vlp.fadr
                              ,vlp.city_name
                              ,vlp.province_name
                              ,(SELECT COUNT(*)
                                  FROM ins.p_policy           pol
                                      ,ins.as_asset           at
                                      ,ins.p_cover            pct
                                      ,ins.t_prod_line_option opt
                                      ,ins.t_product_line     pl
                                 WHERE pol.policy_id = at.p_policy_id
                                   AND at.as_asset_id = pct.as_asset_id
                                   AND pct.t_prod_line_option_id = opt.id
                                   AND pl.id = opt.product_line_id
                                   AND pol.pol_header_id = ph.policy_header_id
                                   AND pl.description IN 'Административные издержки') is_adm
                              ,vlp.distr_name
                              ,vlp.region_name
                              ,vlp.country_name
                              ,vlp.zip
                              ,vlp.code
                              ,vlp.mb
                              ,vlp.init_name
                              ,to_char(vlp.due_date, 'dd.mm.yyyy') due_date
                              ,vlp.sum_fee amount
                              ,vlp.pay_amount_dog
                              ,vlp.fund
                              ,pp.pol_num
                              ,ph.ids
                              ,CASE
                                 WHEN length(pp.pol_num) > 6 THEN
                                  1
                                 ELSE
                                  0
                               END flag
                              ,pp.pol_num dog_num
                              ,CASE
                                 WHEN length(pp.pol_num) > 6 THEN
                                  substr(pp.pol_num, 1, 3)
                                 ELSE
                                  pp.pol_ser
                               END pol_ser
                              ,vlp.type_contact
                              ,vlp.gender
                              ,TRIM(to_char(vlp.oplata, '999999999D99')) oplata
                              ,SUM(pc.fee) fee
                              ,prod.description product
                              ,to_char(ph.start_date, 'dd.mm.yyyy') start_date
                              ,pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 2) last_payd
                              ,pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 1) first_unpayd
                              ,to_char(vlp.grace_date + 1, 'dd.mm.yyyy') grace_period
                              ,to_char(vlp.plan_date, 'dd.mm.yyyy') plan_date
                              ,vlp.agent_current
                              ,vlp.leader_agent
                              ,vlp.leader_manag
                              ,pkg_policy.get_last_version_status(ph.policy_header_id) AS last_pol_status
                                FROM v_letters_payment vlp
                                    ,notif_letter_rep nlr
                                    ,p_pol_header ph
                                    ,t_product prod
                                    ,p_policy pp
                                    ,as_asset a
                                    ,p_cover pc
                                    ,(SELECT pol.pol_header_id
                                            ,SUM(decode(plt.brief, 'OPTIONAL', 1, 'MANDATORY', 1, 0)) plt_cnt
                                        FROM ins.p_policy            pol
                                            ,ins.as_asset            at
                                            ,ins.p_cover             pct
                                            ,ins.t_prod_line_option  opt
                                            ,ins.t_product_line      pl
                                            ,ins.t_product_line_type plt
                                       WHERE pol.policy_id = at.p_policy_id
                                         AND at.as_asset_id = pct.as_asset_id
                                         AND pct.t_prod_line_option_id = opt.id
                                         AND pl.id = opt.product_line_id
                                         AND pl.product_line_type_id = plt.product_line_type_id
                                         AND opt.brief NOT IN
                                             ('Adm_Cost_Life', 'Adm_Cost_Acc', 'Penalty')
                                         AND at.as_asset_id = pct.as_asset_id
                                       GROUP BY pol.pol_header_id) plt
                              
                               WHERE vlp.document_id = nlr.document_id
                                 AND pp.payment_term_id != 1 --Единовременно
                                 AND nlr.sessionid = par_sessionid
                                 AND ph.policy_header_id = vlp.pol_header_id
                                 AND ph.product_id = prod.product_id
                                 AND plt.pol_header_id = ph.policy_header_id
                                 AND pp.policy_id = ph.policy_id
                                 AND pp.policy_id = a.p_policy_id
                                 AND a.as_asset_id = pc.as_asset_id
                                 AND pc.status_hist_id <> 3
                               GROUP BY vlp.payment_period
                                       ,vlp.contact_name
                                       ,vlp.address_name
                                       ,vlp.fadr
                                       ,vlp.city_name
                                       ,vlp.province_name
                                       ,vlp.region_name
                                       ,vlp.distr_name
                                       ,vlp.country_name
                                       ,vlp.zip
                                       ,vlp.code
                                       ,vlp.mb
                                       ,vlp.init_name
                                       ,to_char(vlp.due_date, 'dd.mm.yyyy')
                                       ,vlp.due_date
                                       ,vlp.prev_due_date
                                       ,ph.policy_header_id
                                       ,ph.ids
                                       ,ph.start_date
                                       ,vlp.sum_fee
                                       ,vlp.pay_amount_dog
                                       ,vlp.fund
                                       ,pp.pol_num
                                       ,ph.ids
                                       ,CASE
                                          WHEN length(pp.pol_num) > 6 THEN
                                           1
                                          ELSE
                                           0
                                        END
                                       ,pp.pol_num
                                       ,CASE
                                          WHEN length(pp.pol_num) > 6 THEN
                                           substr(pp.pol_num, 1, 3)
                                          ELSE
                                           pp.pol_ser
                                        END
                                       ,vlp.type_contact
                                       ,vlp.gender
                                       ,prod.description
                                       ,vlp.oplata
                                       ,to_char(vlp.grace_date + 1, 'dd.mm.yyyy')
                                       ,to_char(vlp.plan_date, 'dd.mm.yyyy')
                                       ,vlp.agent_current
                                       ,vlp.leader_agent
                                       ,vlp.leader_manag
                                       ,vlp.contact_id)) mn
                    ,(SELECT pv.number_val
                            ,CASE lp.brief
                               WHEN 'SUM_DEBT_RUR' THEN
                                'RUR'
                               WHEN 'SUM_DEBT_USD' THEN
                                'USD'
                               WHEN 'SUM_DEBT_EUR' THEN
                                'EUR'
                             END AS fund_brief
                        FROM t_notification_type  nt
                            ,t_n_ltrs_params      lp
                            ,t_n_ltrs_params_vals pv
                       WHERE nt.brief = 'REMIND_30_PDFN'
                         AND lp.brief IN ('SUM_DEBT_RUR', 'SUM_DEBT_USD', 'SUM_DEBT_EUR')
                         AND nt.t_notification_type_id = pv.t_notification_type_id
                         AND lp.t_n_ltrs_params_id = pv.t_notif_param_id) sm
               WHERE mn.fund = sm.fund_brief
                 AND mn.sum_zadol_num >= sm.number_val
                 AND mn.sum_zadol_num - mn.amount < (CASE mn.fund
                       WHEN 'RUR' THEN
                        600
                       ELSE
                        20
                     END)
               ORDER BY upper(mn.contact_name)) b;
    vr_rep_data cur_rep_data%ROWTYPE;
  
    PROCEDURE init_input_parameters IS
    BEGIN
      vp_sid    := to_number(repcore.get_context('SID'));
      vp_number := repcore.get_context('PNUMBER');
    END init_input_parameters;
  
    PROCEDURE print_header
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
     ,par_width      NUMBER
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_font(par_cell_index, 'Calibri', 11);
      ora_excel.set_cell_bold(par_cell_index);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_middle(par_cell_index);
      ora_excel.set_cell_border(par_cell_index);
      ora_excel.set_cell_bg_color(par_cell_index, '999999');
      ora_excel.set_column_width(par_cell_index, par_width);
    END;
  
    PROCEDURE print_align_center_bottom_cell
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_bottom(par_cell_index);
      ora_excel.set_cell_wrap_text(par_cell_index);
      ora_excel.set_cell_border(par_cell_index);
    END;
  
    PROCEDURE print_col_align_centr_mid_cell
    (
      par_cell_index VARCHAR2
     ,par_cell_value VARCHAR2
     ,par_color      VARCHAR2 DEFAULT '999999'
    ) IS
    BEGIN
      ora_excel.set_cell_value(par_cell_index, par_cell_value);
      ora_excel.set_cell_bold(par_cell_index);
      ora_excel.set_cell_align_center(par_cell_index);
      ora_excel.set_cell_vert_align_middle(par_cell_index);
      ora_excel.set_cell_wrap_text(par_cell_index);
      ora_excel.set_cell_bg_color(par_cell_index, par_color);
      ora_excel.set_cell_border(par_cell_index);
    END;
  
    PROCEDURE print_footer IS
    BEGIN
      ora_excel.add_row;
      ora_excel.add_row;
    
      ora_excel.set_cell_value('A'
                              ,'Передал: ____________________/______________________________________');
      ora_excel.set_cell_font('A', 'Calibri', 11);
      ora_excel.set_cell_bold('A');
      ora_excel.merge_cells('A', 'AT');
      ora_excel.set_cell_align_left('A');
      ora_excel.set_cell_vert_align_middle('A');
    
      ora_excel.add_row;
      ora_excel.add_row;
    
      ora_excel.set_cell_value('A'
                              ,'Принял: _____________________/______________________________________');
      ora_excel.set_cell_font('A', 'Calibri', 11);
      ora_excel.set_cell_bold('A');
      ora_excel.merge_cells('A', 'AT');
      ora_excel.set_cell_align_left('A');
      ora_excel.set_cell_vert_align_middle('A');
    END;
  
  BEGIN
  
    init_input_parameters;
  
    ora_excel.new_document;
    ora_excel.add_sheet('Report');
  
    --Шапка отчета
    ora_excel.add_row;
    ora_excel.set_row_height(46.5);
    ora_excel.set_cell_value('A'
                            ,'Список' || chr(10) ||
                             'Письмо-напоминание за 30 дней до даты оплаты (PDF от 28.06.2010) (отправка с уведомлением)');
    ora_excel.set_cell_font('A', 'Calibri', 12);
    ora_excel.set_cell_bold('A');
    ora_excel.merge_cells('A', 'AB');
    ora_excel.set_cell_align_center('A');
    ora_excel.set_cell_vert_align_middle('A');
    ora_excel.set_cell_wrap_text('A');
  
    --Шапка таблицы отчета
    ora_excel.add_row;
    ora_excel.set_row_height(15);
  
    print_header('A', '№', 3);
    print_header('B', 'Исходящий номер', 18);
    print_header('C', 'Страхователь', 33);
    print_header('D', 'Серия', 8);
    print_header('E', 'Номер', 12);
    print_header('F', 'Строка адреса', 29);
    print_header('G', 'Город', 21);
    print_header('H', 'Населенный пункт', 18);
    print_header('I', 'Район', 15);
    print_header('J', 'Область, республика', 21);
    print_header('K', 'Страна', 22);
    print_header('L', 'Индекс', 8);
    print_header('M', 'Адрес Страхователя', 36);
    print_header('N', 'Программа', 15);
    print_header('O', 'Дата начала действия ДС', 24);
    print_header('P', 'Периодичность', 16);
    print_header('Q', 'Валюта ответственности', 23);
    print_header('R', 'Дата последнего оплаченного ЭПГ', 33);
    print_header('S', 'Дата первого неоплаченного ЭПГ', 32);
    print_header('T', 'Оплачено', 10);
    print_header('U', 'Сумма ЭПГ к оплате', 19);
    print_header('V', 'Из них оплачено', 16);
    print_header('W', 'Сумма задолженности', 22);
    print_header('X', 'Дата ЭПГ', 10);
    print_header('Y', 'Дата расторжения', 18);
    print_header('Z', 'ИДС договора', 14);
    print_header('AA', 'Регион', 21);
    print_header('AB', 'Действующий агент', 36);
    print_header('AC', 'Руководитель агента/Менеджер', 32);
    print_header('AD', 'Руководитель менеджера/Директор', 36);
    print_header('AE', 'Статус последней версии', 24);
    print_header('AF', 'Contact_ID', 10);
    print_header('AG', 'Вид сообщения', 15);
    print_header('AH', 'Тип сообщения', 18);
    print_header('AI', 'Тип реквизита', 14);
    print_header('AJ', 'Статус', 10);
    print_header('AK', 'Описание', 36);
    print_header('AL', 'Тема сообщения', 36);
    print_header('AM', 'Дата регистрации', 17);
    print_header('AN', 'Номер реестра', 17);
    print_header('AO', 'Инициатор доставки', 20);
    print_header('AP', 'Порядковый номер', 20);
    print_header('AQ', 'Комментарий', 17);
  
    --Вывод данных запроса в таблицу
    OPEN cur_rep_data(vp_sid, vp_number);
    LOOP
      FETCH cur_rep_data
        INTO vr_rep_data;
      EXIT WHEN cur_rep_data%NOTFOUND;
    
      ora_excel.add_row;
      ora_excel.set_row_height(60);
      print_align_center_bottom_cell('A', vr_rep_data.rec_number);
      print_align_center_bottom_cell('B'
                                    ,vr_rep_data.vhnum || '-' || vr_rep_data.p_month || '/' ||
                                     vr_rep_data.p_year);
      print_align_center_bottom_cell('C', vr_rep_data.contact_name);
      print_align_center_bottom_cell('D', vr_rep_data.pol_ser);
      print_align_center_bottom_cell('E', vr_rep_data.pol_num);
      print_align_center_bottom_cell('F', vr_rep_data.fadr);
      print_align_center_bottom_cell('G', vr_rep_data.city_name);
      print_align_center_bottom_cell('H', vr_rep_data.distr_name);
      print_align_center_bottom_cell('I', vr_rep_data.region_name);
      print_align_center_bottom_cell('J', vr_rep_data.province_name);
      print_align_center_bottom_cell('K', vr_rep_data.country_name);
      print_align_center_bottom_cell('L', vr_rep_data.zip);
      print_align_center_bottom_cell('M', vr_rep_data.address_name);
      print_align_center_bottom_cell('N', vr_rep_data.product);
      print_align_center_bottom_cell('O', vr_rep_data.start_date);
      print_align_center_bottom_cell('P', vr_rep_data.payment_period);
      print_align_center_bottom_cell('Q', vr_rep_data.fund);
      print_align_center_bottom_cell('R', vr_rep_data.last_payd);
      print_align_center_bottom_cell('S', vr_rep_data.first_unpayd);
      print_align_center_bottom_cell('T', vr_rep_data.pay_amount);
      print_align_center_bottom_cell('U', vr_rep_data.oplata);
      print_align_center_bottom_cell('V', vr_rep_data.part_pay_amount);
      print_align_center_bottom_cell('W', vr_rep_data.sum_zadol);
      print_align_center_bottom_cell('X', vr_rep_data.plan_date);
      print_align_center_bottom_cell('Y', vr_rep_data.grace_period);
      print_align_center_bottom_cell('Z', vr_rep_data.ids);
      print_align_center_bottom_cell('AA', vr_rep_data.code);
      print_align_center_bottom_cell('AB', vr_rep_data.agent_current);
      print_align_center_bottom_cell('AC', vr_rep_data.leader_agent);
      print_align_center_bottom_cell('AD', vr_rep_data.leader_manag);
      print_align_center_bottom_cell('AE', vr_rep_data.last_pol_status);
      print_col_align_centr_mid_cell('AF', vr_rep_data.contact_id);
      print_col_align_centr_mid_cell('AG', 'Исходящий');
      print_col_align_centr_mid_cell('AH', 'письма за 30 дней');
      print_col_align_centr_mid_cell('AI', 'Адрес');
      print_col_align_centr_mid_cell('AJ', 'Отправлен');
      print_col_align_centr_mid_cell('AK'
                                    ,'Очередной страховой взнос ' || vr_rep_data.oplata ||
                                     ', задолженность по оплате предыдущих взносов ' ||
                                     vr_rep_data.sum_zadol || ' ' || vr_rep_data.fund ||
                                     ', дата выставления платежа ' || vr_rep_data.plan_date);
      print_col_align_centr_mid_cell('AL'
                                    ,'письмо 30 дн-напоминание об оплате');
      print_col_align_centr_mid_cell('AM', '');
      print_col_align_centr_mid_cell('AN', '');
      print_col_align_centr_mid_cell('AO', '');
      print_col_align_centr_mid_cell('AP', '');
      print_col_align_centr_mid_cell('AQ', '');
    
    END LOOP;
  
    --Вывод строки "Всего..." и строк для подписей
    ora_excel.add_row;
    ora_excel.add_row;
  
    ora_excel.set_cell_value('A', 'Всего ' || to_char(ora_excel.current_row_id - 4)); -- Если запрос не возвращает ни одной строки, то строка с "Всего..." расположена на 4 строке, и значит получим "Всего 0". Если на 5, то "Всего 1", и т.д.  
    ora_excel.set_cell_font('A', 'Calibri', 11);
    ora_excel.set_cell_bold('A');
    ora_excel.merge_cells('A', 'AT');
    ora_excel.set_cell_align_left('A');
    ora_excel.set_cell_vert_align_middle('A');
  
    print_footer;
  
    ora_excel.save_to_blob(l_blob);
  
    par_data         := l_blob;
    par_file_name    := 'remind_letter_30_days_report_' || vp_sid || '.xlsx';
    par_content_type := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  
    ora_excel.close_document;
  
  END remind_30days_before_pay_excel;

END pkg_notification_letter;
/

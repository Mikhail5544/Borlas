CREATE OR REPLACE PACKAGE pkg_mass_decline_rep AS

  --Отчет Реестр актов для реквеста (о досрочном прекращении)
  PROCEDURE list_acts_for_request
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр нулевых актов (о досрочном прекращении)
  PROCEDURE list_null_acts
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с запросом реквизитов (о досрочном прекращении)
  PROCEDURE list_acts_for_requisites
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с зачетом (о досрочном прекращении)».
  PROCEDURE list_acts_checkin
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с зачетом и выплатой (о досрочном прекращении)
  PROCEDURE list_acts_checkin_and_paym
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов для реквеста (о признании договоре незаключенным)
  PROCEDURE list_acts_for_request_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр нулевых актов (о признании договоре незаключенным)
  PROCEDURE list_null_acts_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с запросом реквизитов (о признании договоре незаключенным)
  PROCEDURE list_acts_for_requisites_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с зачетом (о признании договоре незаключенным)
  PROCEDURE list_acts_checkin_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Отчет Реестр актов с зачетом и выплатой (о признании договоре незаключенным)
  PROCEDURE list_acts_checkin_and_paym_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );
  
  --Отчет о загрузке
  PROCEDURE rep_load_pol_quit
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_mass_decline_rep AS

  TYPE ref_cur IS REF CURSOR RETURN v_mass_decline_rep%ROWTYPE;
  -- значение P_DECLINE_PACK_ID из контекста
  gv_decline_pack_id NUMBER := to_number(repcore.get_context('P_DECLINE_PACK_ID'));
  gc_file_ext CONSTANT VARCHAR2(30) := '.xlsx';

  -- формирует blob отчета по ссылке на курсор
  PROCEDURE create_report
  (
    par_refcur     IN ref_cur
   ,par_sheet_name IN VARCHAR2 DEFAULT 'Отчет'
   ,par_file       IN OUT NOCOPY BLOB
  ) IS
    rec    par_refcur%ROWTYPE;
    v_rnum NUMBER := 1;
  BEGIN
    --Создание документа
    ora_excel.new_document;
    ora_excel.add_sheet(par_sheet_name);
  
    --Создание шапки
    ora_excel.add_row;
  
    ora_excel.set_column_width('B', 16);
    ora_excel.set_column_width('C', 16);
    ora_excel.set_column_width('D', 42);
    ora_excel.set_column_width('E', 42);
    ora_excel.set_column_width('F', 16);
    ora_excel.set_column_width('G', 16);
    ora_excel.set_column_width('H', 16);
    ora_excel.set_column_width('I', 50);
    ora_excel.set_column_width('K', 16);
    ora_excel.set_column_width('L', 20);
    ora_excel.set_column_width('U', 42);
    ora_excel.set_column_width('V', 70);
  
    ora_excel.set_cell_value('A', '№');
    ora_excel.set_cell_value('B', 'ИДС');
    ora_excel.set_cell_value('C', 'Номер договора');
    ora_excel.set_cell_value('D', 'Страхователь');
    ora_excel.set_cell_value('E', 'Причина расторжения');
    ora_excel.set_cell_value('F', 'Дата начала договора');
    ora_excel.set_cell_value('G', 'Дата расторжения');
    ora_excel.set_cell_value('H', 'Периодичность уплаты взноса');
    ora_excel.set_cell_value('I', 'Полисные условия');
    ora_excel.set_cell_value('J', 'Код региона');
    ora_excel.set_cell_value('K', 'Дата акта');
    ora_excel.set_cell_value('L', 'Валюта');
    ora_excel.set_cell_value('M'
                            ,'Сумма к возврату (в целом по договору)');
    ora_excel.set_cell_value('N', '-Недоплата/ +Переплата');
    ora_excel.set_cell_value('O', 'МЕДО (в целом по договору)');
    ora_excel.set_cell_value('P', 'Сумма зачета');
    ora_excel.set_cell_value('Q', 'Гос.пошлина');
    ora_excel.set_cell_value('R', 'Штраф');
    ora_excel.set_cell_value('S', 'Прочие судебные расходы');
    ora_excel.set_cell_value('T'
                            ,'К перечислению Страхователю (в целом по договору)');
    ora_excel.set_cell_value('U', 'Застрахованный');
    ora_excel.set_cell_value('V', 'Риски');
    ora_excel.set_cell_value('W', 'Срок страхования');
    ora_excel.set_cell_value('X', 'Выкупная сумма');
    ora_excel.set_cell_value('Y', 'Дополнительная Выкупная сумма');
    ora_excel.set_cell_value('Z', 'ДИД');
    ora_excel.set_cell_value('AA', 'Возврат части премии/платежа');
    ora_excel.set_cell_value('AB', 'РВД по рискам');
    ora_excel.set_cell_value('AC'
                            ,'Начисленная премия к списанию прошлых лет');
    ora_excel.set_cell_value('AD'
                            ,'Начисленная премия к списанию текущего года');
    ora_excel.set_cell_value('AE'
                            ,'Начисленная премия к списанию по неоплате за прошлый период');
    ora_excel.set_cell_value('AF'
                            ,'Начисленная премия к списанию по неоплате за текущий период');
    ora_excel.set_cell_value('AG'
                            ,'Начисленная премия к списанию по неоплате за ЛП');
  
    --Создание тела  
    LOOP
      FETCH par_refcur
        INTO rec;
      EXIT WHEN par_refcur%NOTFOUND;
    
      ora_excel.add_row;
    
      ora_excel.set_column_width('B', 16);
      ora_excel.set_column_width('C', 16);
      ora_excel.set_column_width('D', 42);
      ora_excel.set_column_width('E', 42);
      ora_excel.set_column_width('F', 16);
      ora_excel.set_column_width('G', 16);
      ora_excel.set_column_width('H', 16);
      ora_excel.set_column_width('I', 50);
      ora_excel.set_column_width('K', 16);
      ora_excel.set_column_width('L', 20);
      ora_excel.set_column_width('U', 42);
      ora_excel.set_column_width('V', 70);
    
      ora_excel.set_cell_value('A', v_rnum);
      ora_excel.set_cell_value('B', rec.ids);
      ora_excel.set_cell_value('C', rec.contract_number);
      ora_excel.set_cell_value('D', rec.insuree_name);
      ora_excel.set_cell_value('E', rec.decline_reason);
      ora_excel.set_cell_value('F', rec.contract_start_date);
      ora_excel.set_cell_value('G', rec.decline_date);
      ora_excel.set_cell_value('H', rec.payment_term);
      ora_excel.set_cell_value('I', rec.product_conds);
      ora_excel.set_cell_value('J', rec.region_code);
      ora_excel.set_cell_value('K', rec.act_date);
      ora_excel.set_cell_value('L', rec.fund_name);
      ora_excel.set_cell_value('M', rec.issuer_return_sum);
      ora_excel.set_cell_value('N', rec.debt_ovpmnt);
      ora_excel.set_cell_value('O', rec.medo_cost);
      ora_excel.set_cell_value('P', rec.state_duty);
      ora_excel.set_cell_value('Q', rec.penalty);
      ora_excel.set_cell_value('R', rec.other_court_fees);
      ora_excel.set_cell_value('S', rec.other_pol_sum);
      ora_excel.set_cell_value('T', rec.return_summ);
      ora_excel.set_cell_value('U', rec.insured_name);
      ora_excel.set_cell_value('V', rec.cover_name);
      ora_excel.set_cell_value('W', rec.cover_period);
      ora_excel.set_cell_value('X', rec.redemption_sum);
      ora_excel.set_cell_value('Y', rec.add_surr_summ);
      ora_excel.set_cell_value('Z', rec.add_invest_income);
      ora_excel.set_cell_value('AA', rec.return_bonus_part);
      ora_excel.set_cell_value('AB', rec.admin_expenses);
      ora_excel.set_cell_value('AC', rec.bonus_off_prev);
      ora_excel.set_cell_value('AD', rec.bonus_off_current);
      ora_excel.set_cell_value('AE', rec.unpayed_premium_previous);
      ora_excel.set_cell_value('AF', rec.unpayed_premium_current);
      ora_excel.set_cell_value('AG', rec.unpayed_premium_lp);
    
      v_rnum := v_rnum + 1;
    END LOOP;
  
    ora_excel.save_to_blob(par_file);
  END;

  -- Отчет Реестр актов для реквеста (о досрочном прекращении)
  PROCEDURE list_acts_for_request
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND doc.get_doc_status_brief(v.policy_id) = 'QUIT_TO_PAY' /*Прекращен.К выплате*/
         AND EXISTS (SELECT 1
                FROM doc_doc    dd
                    ,ac_payment ap
               WHERE ap.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(ap.payment_id) = 'NEW'
                 AND dd.parent_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 0;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Реестр актов для реквеста (о досрочном прекращении)' || gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов для реквеста'
                 ,par_file       => par_data);
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END list_acts_for_request;

  --Отчет Реестр нулевых актов (о досрочном прекращении)
  PROCEDURE list_null_acts
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ <= v.income_tax_sum /*Итого к выплате <= Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 0;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр нулевых актов (о досрочном прекращении)' || gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр нулевых актов'
                 ,par_file       => par_data);
  END list_null_acts;

  --Отчет Реестр актов с запросом реквизитов (о досрочном прекращении)
  PROCEDURE list_acts_for_requisites
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND doc.get_doc_status_brief(v.policy_id) = 'QUIT_REQ_QUERY' /*Прекращен. Запрос реквизитов*/
         AND EXISTS (SELECT 1
                FROM doc_doc    dd
                    ,ac_payment ap
               WHERE ap.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(ap.payment_id) = 'NEW'
                 AND dd.parent_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 0;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр актов с запросом реквизитов (о досрочном прекращении)' ||
                        gc_file_ext;
  
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с запросом реквизитов'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр актов с зачетом (о досрочном прекращении) 
  PROCEDURE list_acts_checkin
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
      
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ <= v.income_tax_sum /*Итого к выплате <= Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
         AND EXISTS (SELECT 1
                FROM doc_doc       dd
                    ,document      d
                    ,doc_templ     dt
                    ,p_pol_decline pd
               WHERE dd.child_id = d.document_id
                 AND dt.doc_templ_id = d.doc_templ_id
                 AND dt.brief = 'PAYMENT_SETOFF'
                 AND pd.p_policy_id = dd.parent_id
                 AND pd.p_policy_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 0;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр актов с зачетом (о досрочном прекращении)' || gc_file_ext;
  
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с зачетом'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр актов с зачетом и выплатой (о досрочном прекращении)
  -- дописать после уточнения требований
  PROCEDURE list_acts_checkin_and_paym
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ > v.income_tax_sum /*Итого к выплате > Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
         AND EXISTS (SELECT 1
                FROM doc_doc       dd
                    ,document      d
                    ,doc_templ     dt
                    ,p_pol_decline pd
               WHERE dd.child_id = d.document_id
                 AND dt.doc_templ_id = d.doc_templ_id
                 AND dt.brief = 'PAYMENT_SETOFF'
                 AND pd.p_policy_id = dd.parent_id
                 AND pd.p_policy_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 0;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр актов с зачетом и выплатой (о досрочном прекращении)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с зачетом и выплатой'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр актов для реквеста (о признании договоре незаключенным) 
  PROCEDURE list_acts_for_request_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND doc.get_doc_status_brief(v.policy_id) = 'QUIT_TO_PAY' /*Прекращен.К выплате*/
         AND EXISTS (SELECT 1
                FROM doc_doc    dd
                    ,ac_payment ap
               WHERE ap.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(ap.payment_id) = 'NEW'
                 AND dd.parent_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 1;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр актов для реквеста (о признании договоре незаключенным)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов для реквеста'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр нулевых актов (о признании договоре незаключенным)
  PROCEDURE list_null_acts_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ <= v.income_tax_sum /*Итого к выплате <= Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 1;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр нулевых актов (о признании договоре незаключенным)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр нулевых актов'
                 ,par_file       => par_data);
  END list_null_acts_a;

  --Отчет Реестр актов с запросом реквизитов (о признании договора незаключенным)
  PROCEDURE list_acts_for_requisites_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND doc.get_doc_status_brief(v.policy_id) = 'QUIT_REQ_QUERY' /*Прекращен. Запрос реквизитов*/
         AND EXISTS (SELECT 1
                FROM doc_doc    dd
                    ,ac_payment ap
               WHERE ap.payment_id = dd.child_id
                 AND doc.get_doc_status_brief(ap.payment_id) = 'NEW'
                 AND dd.parent_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 1;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Реестр актов с запросом реквизитов (о признании договоре незаключенным)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с запросом реквизитов'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр актов с зачетом (о признании договоре незаключенным) 
  PROCEDURE list_acts_checkin_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ <= v.income_tax_sum /*Итого к выплате <= Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
            
         AND EXISTS (SELECT 1
                FROM doc_doc       dd
                    ,document      d
                    ,doc_templ     dt
                    ,p_pol_decline pd
               WHERE dd.child_id = d.document_id
                 AND dt.doc_templ_id = d.doc_templ_id
                 AND dt.brief = 'PAYMENT_SETOFF'
                 AND pd.p_policy_id = dd.parent_id
                 AND pd.p_policy_id = v.policy_id)
            
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 1;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет Реестр актов с зачетом (о признании договоре незаключенным)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с зачетом'
                 ,par_file       => par_data);
  END;

  --Отчет Реестр актов с зачетом и выплатой (о признании договоре незаключенным)
  PROCEDURE list_acts_checkin_and_paym_a
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    refcur ref_cur;
  BEGIN
    OPEN refcur FOR
      SELECT *
        FROM v_mass_decline_rep v
       WHERE v.p_decline_pack_id = gv_decline_pack_id
         AND v.return_summ > v.income_tax_sum /*Итого к выплате > Сумма НДФЛ*/
         AND doc.get_doc_status_brief(v.policy_id) NOT IN
             ('TO_QUIT_AWAITING_USVE', 'TO_QUIT', 'TO_QUIT_CHECK_READY')
         AND EXISTS (SELECT 1
                FROM doc_doc       dd
                    ,document      d
                    ,doc_templ     dt
                    ,p_pol_decline pd
               WHERE dd.child_id = d.document_id
                 AND dt.doc_templ_id = d.doc_templ_id
                 AND dt.brief = 'PAYMENT_SETOFF'
                 AND pd.p_policy_id = dd.parent_id
                 AND pd.p_policy_id = v.policy_id)
         AND pkg_policy_decline.is_policy_annulled(v.policy_id) = 1;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Реестр актов с зачетом и выплатой (о признании договоре незаключенным)' ||
                        gc_file_ext;
    create_report(par_refcur     => refcur
                 ,par_sheet_name => 'Реестр актов с зачетом и выплатой'
                 ,par_file       => par_data);
  END;

  -- Отчет о загрузке
  PROCEDURE rep_load_pol_quit
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  
    CURSOR cur(cp_decline_pack_id NUMBER) IS
      SELECT ph.ids
            ,vi.contact_name issuer_name
            ,p.pol_num policy_number
            ,CASE
               WHEN dr.name = 'Решение суда (аннулирование)' THEN
                'Решение суда'
               WHEN dr.name = 'Решение суда (расторжение)' THEN
                'Решение суда'
               ELSE
                dr.name
             END decline_reason
            ,p.decline_date
            ,to_char(p.decline_date, 'dd.mm.yyyy') decline_date_formatted
            ,dsr.name last_ver_status
            ,dpd.commentary
        FROM ins.ven_p_policy          p
            ,ins.p_decline_pack_detail dpd
            ,ins.ven_t_decline_reason  dr
            ,ins.ven_p_pol_header      ph
            ,ins.v_pol_issuer          vi
            ,ins.ven_department        d
            ,ins.doc_status            ds
            ,ins.doc_status_ref        dsr
       WHERE p.decline_reason_id = dr.t_decline_reason_id(+)
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = vi.policy_id
         AND ph.agency_id = d.department_id(+)
         AND p.policy_id(+) = dpd.p_policy_id
         AND ds.doc_status_id = dpd.doc_status_id
         AND dsr.doc_status_ref_id = ds.doc_status_ref_id
         AND dpd.p_decline_pack_id = cp_decline_pack_id;
  
    PROCEDURE set_col_width IS
    BEGIN
      ora_excel.set_column_width('A', 16);
      ora_excel.set_column_width('B', 16);
      ora_excel.set_column_width('C', 16);
      ora_excel.set_column_width('D', 16);
      ora_excel.set_column_width('E', 16);
      ora_excel.set_column_width('F', 16);
      ora_excel.set_column_width('G', 16);
    END;
  BEGIN
    --Создание документа
    ora_excel.new_document;
    ora_excel.add_sheet('Отчет');
  
    --Создание шапки
    ora_excel.add_row;
    set_col_width;
  
    ora_excel.set_cell_value('A', 'ИДС');
    ora_excel.set_cell_value('B', 'Страхователь');
    ora_excel.set_cell_value('C', 'Номер договора');
    ora_excel.set_cell_value('D', 'Причина расторжения');
    ora_excel.set_cell_value('E', 'Дата расторжения');
    ora_excel.set_cell_value('F', 'Статус последней версии');
    ora_excel.set_cell_value('G', 'Ошибка');
    --Создание тела 
    FOR rec IN cur(gv_decline_pack_id)
    LOOP
      ora_excel.add_row;
      set_col_width;
    
      ora_excel.set_cell_value('A', rec.ids);
      ora_excel.set_cell_value('B', rec.issuer_name);
      ora_excel.set_cell_value('C', rec.policy_number);
      ora_excel.set_cell_value('D', rec.decline_reason);
      ora_excel.set_cell_value('E', rec.decline_date_formatted);
      ora_excel.set_cell_value('F', rec.last_ver_status);
      ora_excel.set_cell_value('G', rec.commentary);
    END LOOP;
  
    par_content_type := 'application/excel';
    par_file_name    := 'Отчет о загрузке' || gc_file_ext;
    ora_excel.save_to_blob(par_data);
  END;

END;
/

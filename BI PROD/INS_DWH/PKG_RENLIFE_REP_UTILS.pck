CREATE OR REPLACE PACKAGE ins_dwh.pkg_renlife_rep_utils IS

  FUNCTION f_write_param
  (
    p_report_name VARCHAR2
   ,p_param_name  VARCHAR2
   ,p_param_value VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_param
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_param_date
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
   ,par_format      VARCHAR2 := 'dd.mm.yyyy'
  ) RETURN DATE;

  FUNCTION get_param_number
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
  ) RETURN NUMBER;

  FUNCTION f_get_period
  (
    p_report_type VARCHAR2
   ,p_startdate   VARCHAR2
   ,p_enddate     VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION f_get_period_1
  (
    p_report_type VARCHAR2
   ,p_startdate   VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE sp_write_period
  (
    p_startdate DATE
   ,p_enddate   DATE
   ,p_rep_id    NUMBER
  );

  /**
  * Функция вызывает создание отчета Sales Report с детализацией до продукта
  * заполнение таблицы ins_dwh.rep_sr_wo_prog
  * @autor Mirovich M.
  * @param dleft - начало периода
  * @param dright - окончание периода
  */
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  );

  /** Для отчет NewBusines EndOfMonth
  */
  PROCEDURE create_endmonth
  (
    dleft  DATE
   ,dright DATE
  );

  /** Для отчет NewBusines NextMonth
  */
  PROCEDURE create_nextmonth
  (
    dleft  DATE
   ,dright DATE
  );

  /** Для отчет NewBusines CurrentMonth
  */
  PROCEDURE create_currentmonth
  (
    dleft  DATE
   ,dright DATE
  );

  /** Новый вариант для детализации Sales Report до полиса
  */
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fpol    VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  );

  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER;
  FUNCTION check_save_date_kp
  (
    par_pol_header_id         NUMBER
   ,par_ag_contract_header_id NUMBER
   ,par_date                  DATE
   ,par_rep_name              VARCHAR2
  ) RETURN NUMBER;

END pkg_renlife_rep_utils;
/
CREATE OR REPLACE PACKAGE BODY ins_dwh.pkg_renlife_rep_utils IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.05.2009 16:59:51
  -- Purpose : Заполнеяет параметры для выполнения отчета
  /*!!!!!!!*/
  /*  NEW  */
  /*!!!!!!!*/
  FUNCTION f_write_param
  (
    p_report_name VARCHAR2
   ,p_param_name  VARCHAR2
   ,p_param_value VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    proc_name VARCHAR2(20) := 'f_write_param';
  BEGIN
    --Гимнастика для ума. Можно было бы просто delete и insert сделать.
    MERGE INTO ins_dwh.rep_param rp
    USING (SELECT report_name
                 ,param_name
                 ,param_value
                 ,date_t
             FROM (SELECT 2             c1
                         ,p_report_name report_name
                         ,p_param_name  param_name
                         ,p_param_value param_value
                         ,SYSDATE       date_t
                     FROM dual
                   UNION ALL
                   SELECT 1 c1
                         ,'Dual'
                         ,'Dual'
                         ,'Dual'
                         ,SYSDATE
                     FROM dual)
            ORDER BY c1) np
    ON (np.param_value = 'Dual' AND np.report_name = 'Dual' AND np.param_name = 'Dual')
    WHEN MATCHED THEN
      UPDATE SET rp.param_value = rp.param_value DELETE WHERE rp.change_time < np.date_t - 0.0001
    WHEN NOT MATCHED THEN
      INSERT
        (rp.rep_name, rp.param_name, rp.param_value, rp.change_time)
      VALUES
        (np.report_name, np.param_name, np.param_value, np.date_t);
  
    /*    INSERT INTO ins_dwh.rep_param (rep_name,param_name,param_value)
    VALUES (p_Report_name, p_Param_name, p_param_value);*/
  
    COMMIT;
    -- ins.pkg_renlife_utils.tmp_log_writer(userenv('SID')||p_Report_name||''||p_Param_name||' '||p_param_value||' ОК');
    RETURN(p_report_name || '' || p_param_name || ' ' || p_param_value || ' ОК');
  EXCEPTION
    WHEN dup_val_on_index THEN
      RETURN('Параметр уже существует');
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END f_write_param;

  FUNCTION get_param
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
  ) RETURN VARCHAR2 IS
    RESULT ins_dwh.rep_param.param_value%TYPE;
  BEGIN
    SELECT r.param_value
      INTO RESULT
      FROM ins_dwh.rep_param r
     WHERE r.rep_name = par_report_name
       AND r.param_name = par_param_name;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_param;

  FUNCTION get_param_date
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
   ,par_format      VARCHAR2 := 'dd.mm.yyyy'
  ) RETURN DATE IS
    RESULT DATE;
  BEGIN
    SELECT to_date(r.param_value, par_format)
      INTO RESULT
      FROM ins_dwh.rep_param r
     WHERE r.rep_name = par_report_name
       AND r.param_name = par_param_name;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_param_date;

  FUNCTION get_param_number
  (
    par_report_name VARCHAR2
   ,par_param_name  VARCHAR2
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT to_number(r.param_value)
      INTO RESULT
      FROM ins_dwh.rep_param r
     WHERE r.rep_name = par_report_name
       AND r.param_name = par_param_name;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_param_number;

  /*Кусок старого пакет PKG_REPRESITORY_FUNCTION*/
  -- Вызывает процедуру, необходимую для построения отчета
  -- Возвращает период
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  /*   DEPRECATED USE F_WRITE_PARAM INSTEAD   */
  /*   УСТАРЕЛО ИСПОЛЬЗОВАТЬ F_WRITE_PARAM    */
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  FUNCTION f_get_period
  (
    p_report_type VARCHAR2
   ,p_startdate   VARCHAR2
   ,p_enddate     VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    RESULT        VARCHAR2(100);
    v_rep_type_id NUMBER;
  BEGIN
  
    RESULT := '';
  
    CASE
      WHEN p_report_type = 'rep_sr_product' THEN
        v_rep_type_id := 1;
      WHEN p_report_type = 'rep_sr_programm' THEN
        v_rep_type_id := 2;
      WHEN p_report_type = 'rep_endmonth' THEN
        v_rep_type_id := 3;
      WHEN p_report_type = 'tmp_life_nonlife_agency' THEN
        v_rep_type_id := 4;
      WHEN p_report_type = 'policy_REVISION' THEN
        v_rep_type_id := 5;
      WHEN p_report_type = 'for_sms_report_payment' THEN
        v_rep_type_id := 6;
      ELSE
        v_rep_type_id := 0;
    END CASE;
  
    ins.pkg_renlife_utils.tmp_log_writer(p_startdate || ' ' || p_enddate);
  
    sp_write_period(to_date(substr(p_startdate, 7, 4) || substr(p_startdate, 4, 2) ||
                            substr(p_startdate, 1, 2)
                           ,'yyyymmdd')
                   ,to_date(substr(p_enddate, 7, 4) || substr(p_enddate, 4, 2) ||
                            substr(p_enddate, 1, 2)
                           ,'yyyymmdd')
                   ,v_rep_type_id);
  
    SELECT to_char(rp.start_date, 'dd.mm.yyyy') || '-' || to_char(rp.end_date, 'dd.mm.yyyy')
      INTO RESULT
      FROM ins_dwh.rep_period rp
     WHERE rp.start_date =
           to_date(substr(p_startdate, 7, 4) || substr(p_startdate, 4, 2) || substr(p_startdate, 1, 2)
                  ,'yyyymmdd')
       AND rp.end_date =
           to_date(substr(p_enddate, 7, 4) || substr(p_enddate, 4, 2) || substr(p_enddate, 1, 2)
                  ,'yyyymmdd');
  
    CASE
      WHEN p_report_type = 'rep_sr_product' THEN
        create_period_sr_wo(to_date(p_startdate, 'dd.mm.yyyy'), to_date(p_enddate, 'dd.mm.yyyy'));
      
      WHEN p_report_type = 'rep_sr_programm' THEN
        ins_dwh.pkg_rep_utils_ins11.create_period_sr_prog(to_date(p_startdate, 'dd.mm.yyyy')
                                                         ,to_date(p_enddate, 'dd.mm.yyyy'));
      
      WHEN p_report_type = 'rep_endmonth' THEN
        create_endmonth(to_date(p_startdate, 'dd.mm.yyyy'), to_date(p_enddate, 'dd.mm.yyyy'));
      WHEN p_report_type = 'tmp_life_nonlife_agency' THEN
        ins.pkg_renlife_utils.tmp_life_nonlife_agency(to_date(p_startdate, 'dd.mm.yyyy')
                                                     ,to_date(p_enddate, 'dd.mm.yyyy'));
      WHEN p_report_type = 'tmp_input_data' THEN
        ins.pkg_renlife_utils.input_data();
      WHEN p_report_type = 'policy_REVISION' THEN
        NULL;
      WHEN p_report_type = 'for_sms_report_payment' THEN
        ins.pkg_renlife_utils.for_sms_report_payment(to_date(p_startdate, 'dd.mm.yyyy')
                                                    ,to_date(p_enddate, 'dd.mm.yyyy'));
        /*when p_Report_Type = 'rep_currentmonth' 
        then pkg_rep_utils_ins11.create_currentmonth(to_date(p_StartDate,'dd.mm.yyyy'),to_date('01-01-1900','dd.mm.yyyy'));*/
    
      ELSE
        RESULT := '';
    END CASE;
    COMMIT;
    RETURN(RESULT);
  END;

  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  /*   DEPRECATED USE F_WRITE_PARAM INSTEAD   */
  /*   УСТАРЕЛО ИСПОЛЬЗОВАТЬ F_WRITE_PARAM    */
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  FUNCTION f_get_period_1
  (
    p_report_type VARCHAR2
   ,p_startdate   VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    RESULT        VARCHAR2(100);
    v_rep_type_id NUMBER;
  BEGIN
  
    RESULT := '';
  
    CASE
      WHEN p_report_type = 'rep_currentmonth' THEN
        v_rep_type_id := 1;
      WHEN p_report_type = 'rep_nextmonth' THEN
        v_rep_type_id := 2;
      WHEN p_report_type = 'agent_ws' THEN
        v_rep_type_id := 3;
      WHEN p_report_type = 'AGENT_TREE_by_DATE' THEN
        v_rep_type_id := 4;
      ELSE
        v_rep_type_id := 0;
    END CASE;
  
    sp_write_period(to_date(substr(p_startdate, 7, 4) || substr(p_startdate, 4, 2) ||
                            substr(p_startdate, 1, 2)
                           ,'yyyymmdd')
                   ,to_date(substr('01-01-1900', 7, 4) || substr('01-01-1900', 4, 2) ||
                            substr('01-01-1900', 1, 2)
                           ,'yyyymmdd')
                   ,v_rep_type_id);
  
    SELECT to_char(rp.start_date, 'dd.mm.yyyy') || '-' || to_char(rp.end_date, 'dd.mm.yyyy')
      INTO RESULT
      FROM ins_dwh.rep_period rp
     WHERE rp.start_date =
           to_date(substr(p_startdate, 7, 4) || substr(p_startdate, 4, 2) || substr(p_startdate, 1, 2)
                  ,'yyyymmdd')
       AND rp.end_date = to_date(substr('01-01-1900', 7, 4) || substr('01-01-1900', 4, 2) ||
                                 substr('01-01-1900', 1, 2)
                                ,'yyyymmdd');
  
    CASE
      WHEN p_report_type = 'rep_currentmonth' THEN
        create_currentmonth(to_date(p_startdate, 'dd.mm.yyyy'), to_date('01-01-1900', 'dd.mm.yyyy'));
      
      WHEN p_report_type = 'rep_nextmonth' THEN
        create_nextmonth(to_date(p_startdate, 'dd.mm.yyyy'), to_date('01-01-1900', 'dd.mm.yyyy'));
      WHEN p_report_type = 'agent_ws' THEN
        ins.pkg_renlife_utils.agent_ws(to_date(p_startdate, 'dd.mm.yyyy'));
      WHEN p_report_type = 'AGENT_TREE_by_DATE' THEN
        NULL; --ins.pkg_renlife_utils.AGENT_TREE_by_DATE(to_date(p_StartDate,'dd.mm.yyyy'));           
      ELSE
        RESULT := '';
    END CASE;
    COMMIT;
    RETURN(RESULT);
  END;

  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  /*   DEPRECATED USE F_WRITE_PARAM INSTEAD   */
  /*   УСТАРЕЛО ИСПОЛЬЗОВАТЬ F_WRITE_PARAM    */
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  -- Записывает период
  PROCEDURE sp_write_period
  (
    p_startdate DATE
   ,p_enddate   DATE
   ,p_rep_id    NUMBER
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE rep_period;
    -- ins.pkg_renlife_utils.tmp_log_writer(p_StartDate||' '||p_EndDate);
    INSERT INTO ins_dwh.rep_period VALUES (p_startdate, p_enddate, p_rep_id);
    COMMIT;
  END;

  /*Кусок пакета INS_DWH.PKG_REP_UTILS_INS11*/

  -- Вызывает формирование отчета Sales Report с детализацией до продукта
  -- opatsan version
  --новая версия pkg_rep_utils_ins11.create_period_sr_wo (модифицировал Сизон С.Л.) 
  PROCEDURE create_period_sr_wo
  (
    dleft  DATE
   ,dright DATE
  ) IS
    -- вспомогательные переменные
    first_day DATE; -- дата начала года
    dl        DATE;
    dr        DATE;
    -- активные договора с накопленным итогом с начала года
    act_ape_ytd        NUMBER; -- годовая премия
    act_pay_amount_ytd NUMBER DEFAULT 0; -- оплаченная премия
    act_num_ytd        NUMBER; -- количество договоров
  
    v_fund_id      NUMBER;
    v_rate_type_id NUMBER;
  
  BEGIN
    dl := to_date('01-06-2008', 'dd-mm-yyyy');
    dr := to_date('30-06-2008', 'dd-mm-yyyy');
    -- заполняем таблицу соответсвия "договор  - агент" 
    --ins_dwh.pkg_rep_utils_ins11.fill_tbl_pol_ag(dleft, dright);
  
    -- вычисляем первую дату года
    first_day := trunc(dleft, 'yyyy');
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    SELECT f.fund_id INTO v_fund_id FROM ins.ven_fund f WHERE f.brief = 'RUR';
  
    SELECT t.rate_type_id INTO v_rate_type_id FROM ins.ven_rate_type t WHERE t.brief = 'ЦБ';
  
    FOR rec IN (SELECT SUM(CASE
                             WHEN pp_notice_date BETWEEN dleft AND dright THEN
                              pp_premium * frate
                             ELSE
                              0
                           END) pol_ape
                      , --pol_ape
                       SUM(CASE
                             WHEN pp_notice_date BETWEEN dleft AND dright THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph_policy_header_id) * frate
                             ELSE
                              0
                           END) pol_pay_amount
                      , --pol_pay_amount
                       SUM(CASE
                             WHEN pp_notice_date BETWEEN dleft AND dright THEN
                              1
                             ELSE
                              0
                           END) pol_num
                      , --pol_num
                       SUM(CASE
                             WHEN --(pp_decline_date BETWEEN dleft AND dright) AND
                              tdr_brief IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              pp_premium * frate
                             ELSE
                              0
                           END) dec_ape
                      , --dec_ape
                       SUM(CASE
                             WHEN --pp_decline_date BETWEEN dleft AND dright AND
                              tdr_brief IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_num
                      , --dec_num
                       SUM(CASE
                             WHEN --pp_decline_date BETWEEN dleft AND dright AND
                              tdr_brief IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              pp_decline_summ * frate
                             ELSE
                              0
                           END) dec_pay_amount
                      , --dec_pay_amount
                       SUM(CASE
                             WHEN (nvl(pp_end_date, dright + 1) > dright)
                                  AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              pp_premium * frate
                             ELSE
                              0
                           END) act_ape
                      , --act_ape
                       SUM(CASE
                             WHEN (nvl(pp_end_date, dright + 1) > dright)
                                  AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              ins.pkg_payment.get_pay_pol_header_amount_pfa(dleft
                                                                           ,dright
                                                                           ,ph_policy_header_id) * frate
                             ELSE
                              0
                           END) act_pay_amount
                      , --act_pay_amount
                       SUM(CASE
                             WHEN (nvl(pp_end_date, dright + 1) > dright)
                                  AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) act_num
                      , --act_num       
                       SUM(CASE
                             WHEN --pp_decline_date BETWEEN dleft AND dright AND
                              tdr_brief NOT IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dl AND dright) THEN
                              pp_premium * frate
                             ELSE
                              0
                           END) dec_oth_ape
                      , --dec_oth_ape
                       SUM(CASE
                             WHEN --pp_decline_date BETWEEN dleft AND dright AND
                              tdr_brief NOT IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              1
                             ELSE
                              0
                           END) dec_oth_num
                      , --dec_oth_num
                       SUM(CASE
                             WHEN --pp_decline_date BETWEEN dleft AND dright AND
                              tdr_brief NOT IN
                              ('ЗаявСтрахователя', 'ОтказВпредПокр')
                              AND (pp_notice_date BETWEEN dleft AND dright) THEN
                              pp_decline_summ * frate
                             ELSE
                              0
                           END) dec_oth_pay_amount
                      , --dec_oth_pay_amount    
                       SUM(pp_premium * frate) act_ape_ytd
                      ,COUNT(*) act_num_ytd
                      ,
                       
                       /*                  SUM(
                       NVL(td_trans_amount
                           , 0) + 
                       NVL(-tc_trans_amount
                           , 0)) act_pay_amount_ytd,*/
                       /* --Этот вариант не подходит т.к. есть проблеммы в базе в плане актуальных версий догоовра, 
                        кроме того надо брать все суммы по договору а не только по актуальной версии
                       (SELECT nvl(SUM(t.trans_amount),0)
                          FROM ins.ven_trans t 
                         WHERE t.dt_account_id(+) = ins.pkg_payment.v_pay_acc_id
                           AND t.A2_DT_URO_ID(+) = pp_policy_id
                           AND t.trans_date(+) BETWEEN first_day AND dright)-
                       (SELECT nvl(sum(t.trans_amount),0)
                          FROM ins.ven_trans t 
                         WHERE t.ct_account_id(+) = ins.pkg_payment.v_pay_acc_id
                           AND t.A2_CT_URO_ID(+) = pp_policy_id
                           AND t.trans_date(+) BETWEEN first_day AND dright)
                        */
                       --Правильное вложение по проводкам
                       --Каткевич А.Г. 22.04.2008
                       SUM(ins.pkg_payment.get_pay_pol_header_amount_pfa(first_day
                                                                        ,dright
                                                                        ,ph_policy_header_id) * frate) act_pay_amount_ytd
                      ,
                       
                       --tt_ag_id agent_id,
                       c_obj_name_orig     ag_fio
                      ,sch_brief           ch_br
                      ,ph_sales_channel_id sales_channel_id
                      ,sch_description     ch_name
                      ,ph_agency_id        dep_id
                      ,dep_name
                      ,pr_product_id       product_id
                      ,pr_brief            pr_br
                      ,pr_description      pr_name /*,
                                                                                                                                                                                                                                                                                                                                                                      pol_number*/
                  FROM (SELECT /*tt.ag_id tt_ag_id, */
                         pp.policy_id pp_policy_id
                        ,pp.num pol_number
                        ,pr.product_id pr_product_id
                        ,c.obj_name_orig c_obj_name_orig
                        ,ph.sales_channel_id ph_sales_channel_id
                        ,sch.brief sch_brief
                        ,sch.description sch_description
                        ,ph.agency_id ph_agency_id
                        ,ins_dwh.pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) dep_name
                        ,pr.brief pr_brief
                        ,pr.description pr_description
                        ,ph.start_date ph_start_date
                        ,pp.notice_date pp_notice_date
                        ,
                         /*                       td.trans_amount td_trans_amount,
                         tc.trans_amount tc_trans_amount,*/ins.acc_new.get_cross_rate_by_id(v_rate_type_id
                                                         ,ph.fund_id
                                                         ,v_fund_id
                                                         ,ph.start_date) frate
                        ,pp.premium pp_premium
                        ,pp.decline_summ pp_decline_summ
                        ,pp.decline_date pp_decline_date
                        ,tdr.brief tdr_brief
                        ,pp.end_date pp_end_date
                        ,ph.policy_header_id ph_policy_header_id
                          FROM ins.ven_p_pol_header    ph
                              ,ins.ven_p_policy        pp
                              ,ins.ven_t_sales_channel sch
                              ,ins.ven_t_product       pr
                              ,
                               -- ins_dwh.rep_sr_ag       tt,
                               ins.ven_contact          c
                              ,ins.ven_t_decline_reason tdr
                        -- ins.ac_payment ap,
                        -- ins.doc_doc dd,
                        --ins.doc_status ds
                        /*                    --вложение по проводкам 
                        ins.ven_trans td,
                        ins.ven_trans tc*/
                         WHERE pp.notice_date BETWEEN dleft /*first_day*/
                               AND dright
                              --and NVL(ins.Doc.get_doc_status_name(pp.policy_id),ins.Doc.get_doc_status_name(pp.policy_id, pp.start_date)) not in ('Отменен')
                           AND ph.policy_id = pp.policy_id(+)
                           AND sch.id = ph.sales_channel_id
                              -- AND pp.policy_id IN (5661978,5723259,5853436) --pp.num IN ( '027657','027785', '028116')
                           AND pr.product_id = ph.product_id
                              -- AND tt.pol_id(+) = ph.policy_header_id
                           AND c.contact_id(+) =
                               ins_dwh.pkg_rep_utils_ins11.get_agch_id_by_polid(ph.policy_header_id) --tt.ag_id
                           AND tdr.t_decline_reason_id(+) = pp.decline_reason_id
                        /*AND dd.parent_id = pp.policy_id
                        AND ap.payment_id = dd.child_id
                        AND ap.payment_id = ds.document_id
                        AND ds.doc_status_ref_id = 6
                        AND ds.start_date = (SELECT MAX(dss.start_date)
                                               FROM ins.DOC_STATUS dss
                                               WHERE  dss.document_id = ds.document_id
                                               )
                        AND ap.payment_number = 1*/
                        /*                  --вложение по проводкам 
                        AND td.dt_account_id(+) = ins.pkg_payment.v_pay_acc_id
                        AND td.A2_DT_URO_ID(+) = pp.policy_id
                        AND td.trans_date(+) BETWEEN first_day AND dright
                        AND tc.ct_account_id(+) = ins.pkg_payment.v_pay_acc_id
                        AND tc.A2_CT_URO_ID(+) = pp.policy_id
                        AND tc.trans_date(+) BETWEEN first_day AND dright*/
                        )
                 GROUP BY --tt_ag_id, 
                          c_obj_name_orig
                         ,pr_product_id
                         ,ph_sales_channel_id
                         ,sch_brief
                         ,sch_description
                         ,ph_agency_id
                         ,dep_name
                         ,pr_brief
                         ,pr_description /*,
                                                                                                                                                                                                                                                                                                                                                                         pol_number*/
                
                /*   HAVING  SUM(CASE
                  WHEN pp_notice_date BETWEEN dleft AND dright THEN 1
                  ELSE 0
                 END                                           
                ) > 0   */
                )
    LOOP
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'6 Количество заключенных договоров за текущий месяц'
                                                     ,rec.pol_num);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'7 APE MTD'
                                                     ,rec.act_ape);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'8 Количество договоров YTD'
                                                     ,rec.act_num_ytd);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'9 APE YTD'
                                                     ,rec.act_ape_ytd);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'10 Оплаченная премия MTD'
                                                     ,rec.pol_pay_amount);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name
                                                     ,rec.dep_name
                                                     ,rec.ag_fio
                                                     ,
                                                      --rec.pol_number,
                                                      rec.pr_name
                                                     ,'11 Оплаченная премия YTD'
                                                     ,rec.act_pay_amount_ytd);
      /* ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.ch_name,
      rec.dep_name,
      rec.ag_fio,
      --rec.pol_number,
      rec.pr_name,
      'Годовая премия (gross)',
      rec.pol_ape);*/
    /*insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'APE по расторгнутым договорам',
                                                                                                              rec.dec_ape);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Сумма возвращенной премии',
                                                                                                              rec.dec_pay_amount);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Количество расторгнутых договоров',
                                                                                                              rec.dec_num);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Сумма оплаченной премии (net)',
                                                                                                              rec.act_pay_amount);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Количество заключенных договоров (net)',
                                                                                                              rec.act_num);
                                                                                        insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'APE по иным случаям расторжения',
                                                                                                              rec.dec_oth_ape);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Сумма возвращенной премии по иным случаям расторжения',
                                                                                                              rec.dec_oth_pay_amount);
                                                                                          insert_row_to_sr_wo(rec.ch_name,
                                                                                                              rec.dep_name,
                                                                                                              rec.ag_fio,
                                                                                                              rec.pol_number,
                                                                                                              rec.pr_name,
                                                                                                              'Количество договоров по иным случаям расторжения',
                                                                                                              rec.dec_oth_num);*/
    
    END LOOP;
    COMMIT;
  END;

  --Вызывает выполнение отчета NewBusiness EndOfMonth
  PROCEDURE create_endmonth
  (
    dleft  DATE
   ,dright DATE
  ) IS
    first_day DATE;
  BEGIN
    first_day := trunc(dleft, 'yyyy');
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    FOR rec IN (SELECT kol_policy.dep
                      ,kol_policy.sales_chnl
                      ,
                       /*kol_proekt.kol_proekt,
                       kol_proekt.kol_proekt_sgp,*/kol_status.kol_status
                      ,kol_status.kol_status_sgp
                      ,kol_all_st.kol_all_st
                      ,kol_all_st.kol_all_st_sgp
                      ,kol_oth_st.kol_oth_st
                      ,kol_oth_st.kol_oth_st_sgp
                      ,paym.paym
                      ,kol_rast.kol_rast
                      ,kol_rast.kol_rast_sgp
                      ,kol_agent.kol_agent
                      ,agent_pol.agent_pol
                      ,kol_policy.life
                      ,kol_policy.ns
                      ,kol_policy.nakop
                      ,kol_policy.fdep
                      ,kol_policy.fdep_sum
                      ,kol_policy.gn
                      ,kol_policy.other
                      ,NULL                      AS ag_fio
                      ,NULL                      AS pr_name
                  FROM (SELECT life.life
                              ,fdep.fdep
                              ,fdep.fdep_sum
                              ,ns.ns
                              ,nakop.nakop
                              ,gn.gn
                              ,other.other
                              ,d.all_prog
                              ,d.dep
                              ,d.sales_chnl
                          FROM (SELECT COUNT(*) AS all_prog
                                      ,k.dep
                                      ,k.sales_chnl
                                  FROM (SELECT pp.policy_header_id
                                              ,pp.pol_ser || ' ' || pp.pol_num
                                              ,pp.notice_num
                                              ,pp.start_date
                                              ,dep.name AS dep
                                              ,ch.description AS sales_chnl
                                              ,st.name AS policy_agent_status
                                          FROM ins.v_policy_version_journal pp
                                          LEFT JOIN ins.p_policy_agent ag
                                            ON (pp.policy_header_id = ag.policy_header_id)
                                          LEFT JOIN ins.ag_contract_header ah
                                            ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                          LEFT JOIN ins.department dep
                                            ON ah.agency_id = dep.department_id
                                          LEFT JOIN ins.policy_agent_status st
                                            ON (ag.status_id = st.policy_agent_status_id)
                                          LEFT JOIN ins.t_sales_channel ch
                                            ON (ch.id = pp.sales_channel_id)
                                         WHERE pp.policy_id = pp.active_policy_id
                                           AND pp.status_name NOT IN ('Отменен')
                                           AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                           AND pp.notice_date BETWEEN dleft AND dright) k
                                 GROUP BY k.dep
                                         ,k.sales_chnl) d
                          LEFT JOIN (SELECT COUNT(*) AS life
                                          ,k.dep
                                          ,k.sales_chnl
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.product_id IN (2267, 7678, 7679, 7680, 12380) --life
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) life
                            ON (d.dep = life.dep AND d.sales_chnl = life.sales_chnl)
                          LEFT JOIN (SELECT COUNT(*) AS ns
                                          ,k.dep
                                          ,k.sales_chnl
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.product_id IN (7681, 7677, 7674, 7670, 12378) --ns
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) ns
                            ON d.dep = ns.dep
                           AND d.sales_chnl = ns.sales_chnl
                          LEFT JOIN (SELECT COUNT(*) AS nakop
                                          ,k.dep
                                          ,k.sales_chnl
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.product_id = 2267 --Гармония
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) nakop
                            ON nakop.dep = d.dep
                           AND d.sales_chnl = nakop.sales_chnl
                          LEFT JOIN (SELECT COUNT(*) AS fdep
                                          ,k.dep
                                          ,k.sales_chnl
                                          ,SUM(k.premium * k.koef) AS fdep_sum
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.premium
                                                  ,CASE pp.fund_id
                                                     WHEN 5 THEN
                                                      35
                                                     WHEN 122 THEN
                                                      1
                                                     WHEN 121 THEN
                                                      24
                                                     ELSE
                                                      1
                                                   END AS koef
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.product_id = 28487 --Гармония
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) fdep
                            ON fdep.dep = d.dep
                           AND d.sales_chnl = fdep.sales_chnl
                          LEFT JOIN (SELECT COUNT(*) AS gn
                                          ,k.dep
                                          ,k.sales_chnl
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.prod_desc IN ('GN', 'ABC_business')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) gn
                            ON d.dep = gn.dep
                           AND d.sales_chnl = gn.sales_chnl
                          LEFT JOIN (SELECT COUNT(*) AS other
                                          ,k.dep
                                          ,k.sales_chnl
                                      FROM (SELECT pp.policy_header_id
                                                  ,pp.pol_ser || ' ' || pp.pol_num
                                                  ,pp.notice_num
                                                  ,pp.start_date
                                                  ,dep.name AS dep
                                                  ,ch.description AS sales_chnl
                                                  ,st.name AS policy_agent_status
                                              FROM ins.v_policy_version_journal pp
                                              LEFT JOIN ins.p_policy_agent ag
                                                ON (pp.policy_header_id = ag.policy_header_id)
                                              LEFT JOIN ins.ag_contract_header ah
                                                ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                              LEFT JOIN ins.department dep
                                                ON ah.agency_id = dep.department_id
                                              LEFT JOIN ins.policy_agent_status st
                                                ON (ag.status_id = st.policy_agent_status_id)
                                              LEFT JOIN ins.t_sales_channel ch
                                                ON (ch.id = pp.sales_channel_id)
                                             WHERE pp.policy_id = pp.active_policy_id
                                               AND pp.product_id NOT IN (7681
                                                                        ,7677
                                                                        ,7674
                                                                        ,7670
                                                                        ,12378
                                                                        ,2267
                                                                        ,7678
                                                                        ,7679
                                                                        ,7680
                                                                        ,12380)
                                               AND pp.prod_desc NOT IN ('GN', 'ABC_business')
                                               AND pp.status_name NOT IN ('Отменен')
                                               AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                               AND pp.notice_date BETWEEN dleft AND dright) k
                                     GROUP BY k.dep
                                             ,k.sales_chnl) other
                            ON d.dep = other.dep
                           AND d.sales_chnl = other.sales_chnl) kol_policy
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_agent
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,ah.date_begin
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) AS status
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     WHERE nvl(ah.date_break, '01-01-1900') < dright
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_agent
                    ON (kol_agent.dep = kol_policy.dep AND kol_agent.sales_chnl = kol_policy.sales_chnl)
                
                /*left join
                (select count(*) as kol_proekt,
                       sum(k.sgp) as kol_proekt_sgp,
                       k.dep,
                       k.sales_chnl
                from
                (select pp.policy_header_id,
                       pp.policy_id,
                       pp.start_date,
                       pp.notice_num,
                       pp.pol_ser||' '||pp.pol_num,
                       pp.premium,
                       pp.fund_id,
                       pp.premium * (case pp.fund_id when 122 then 1 when 121 then 25 when 5 then 35 end) as sgp,
                       pp.status_name,
                       dep.name as dep,
                       ch.description as sales_chnl,
                       st.name as policy_agent_status
                from ins.v_policy_version_journal pp
                     left join ins.p_policy_agent ag on (pp.policy_header_id = ag.policy_header_id)
                     left join ins.ag_contract_header ah on (ag.ag_contract_header_id = ah.ag_contract_header_id)
                     left join ins.department dep on ah.agency_id = dep.department_id
                     left join ins.policy_agent_status st on (ag.status_id = st.policy_agent_status_id)
                     left join ins.t_sales_channel ch on (ch.id = pp.sales_channel_id)
                     left join (select min(state.start_date) as m_date, state.document_id, state.doc_status_ref_id
                                from ins.ven_doc_status state
                                group by state.document_id, state.doc_status_ref_id) state on (state.document_id = pp.active_policy_id)
                where pp.policy_id = pp.active_policy_id
                      and state.doc_status_ref_id = 16
                      --and pp.status_name not in ('Отменен')
                      and st.name not in ('ОТМЕНЕН','ОШИБКА')
                      and pp.notice_date between dleft and dright
                      and state.m_date between dleft and dright) k
                group by k.dep,
                         k.sales_chnl ) kol_proekt on (kol_proekt.dep = kol_policy.dep and kol_proekt.sales_chnl = kol_policy.sales_chnl)*/
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_rast
                                  ,SUM(k.sgp) AS kol_rast_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.doc_status_ref_id = 10
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date BETWEEN dleft AND dright) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_rast
                    ON (kol_rast.dep = kol_policy.dep AND kol_rast.sales_chnl = kol_policy.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_status
                                  ,SUM(k.sgp) AS kol_status_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND pp.status_name IN ('Действующий'
                                                             ,'Напечатан'
                                                             ,'Новый'
                                                             ,'Активный'
                                                             ,'Андеррайтинг')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND pp.notice_date BETWEEN dleft AND dright) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_status
                    ON (kol_status.dep = kol_policy.dep AND
                       kol_status.sales_chnl = kol_policy.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_oth_st
                                  ,SUM(k.sgp) AS kol_oth_st_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND pp.status_name NOT IN ('Действующий'
                                                                 ,'Напечатан'
                                                                 ,'Новый'
                                                                 ,'Активный'
                                                                 ,'Андеррайтинг')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND pp.notice_date BETWEEN dleft AND dright) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_oth_st
                    ON (kol_oth_st.dep = kol_policy.dep AND
                       kol_oth_st.sales_chnl = kol_policy.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_all_st
                                  ,SUM(k.sgp) AS kol_all_st_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                          --and pp.status_name not in ('Действующий','Напечатан','Новый','Активный','Андеррайтинг','Расторгнут')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND pp.notice_date BETWEEN dleft AND dright) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_all_st
                    ON (kol_all_st.dep = kol_policy.dep AND
                       kol_all_st.sales_chnl = kol_policy.sales_chnl)
                
                  LEFT JOIN (SELECT SUM(k.paym) AS paym
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT paym.pay_amount
                                          ,pp.fund_id
                                          ,paym.pay_amount * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS paym
                                          ,paym.amount
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.start_date
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_payment_schedule paym
                                      LEFT JOIN ins.v_policy_version_journal pp
                                        ON (paym.pol_header_id = pp.policy_header_id)
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND paym.doc_status_ref_name LIKE 'Оплачен'
                                       AND paym.due_date BETWEEN dleft AND dright
                                       AND pp.notice_date BETWEEN dleft AND dright) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) paym
                    ON (paym.dep = kol_policy.dep AND paym.sales_chnl = kol_policy.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS agent_pol
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,dep.name       AS dep
                                          ,ch.description AS sales_chnl
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     INNER JOIN (SELECT DISTINCT ah.agent_id
                                                               ,dep.name       AS dep
                                                               ,ch.description AS sales_chnl
                                                  FROM ins.ag_contract_header ah
                                                  LEFT JOIN ins.p_policy_agent pa
                                                    ON (pa.ag_contract_header_id =
                                                       ah.ag_contract_header_id)
                                                  LEFT JOIN ins.v_policy_version_journal pp
                                                    ON (pp.policy_header_id = pa.policy_header_id)
                                                  LEFT JOIN ins.department dep
                                                    ON ah.agency_id = dep.department_id
                                                  LEFT JOIN ins.policy_agent_status st
                                                    ON (pa.status_id = st.policy_agent_status_id)
                                                  LEFT JOIN ins.t_sales_channel ch
                                                    ON (ch.id = pp.sales_channel_id)
                                                 INNER JOIN ins.v_policy_payment_schedule paym
                                                    ON (pp.policy_header_id = paym.pol_header_id)
                                                 WHERE pp.policy_id = pp.active_policy_id
                                                   AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                                   AND paym.doc_status_ref_name = 'Оплачен'
                                                   AND pp.notice_date BETWEEN dleft AND dright) pp
                                        ON (pp.agent_id = ah.agent_id AND pp.dep = dep.name AND
                                           pp.sales_chnl = ch.description)
                                     WHERE nvl(ah.date_break, '01-01-1900') < dright
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) agent_pol
                    ON (agent_pol.dep = kol_policy.dep AND agent_pol.sales_chnl = kol_policy.sales_chnl))
    LOOP
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
      /*ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl,
                          rec.dep,
                          rec.ag_fio,
                          rec.pr_name,
                          'Policies entered in system: Number',
                          rec.kol_proekt);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl,
                          rec.dep,
                          rec.ag_fio,
                          rec.pr_name,
                          'Policies entered in system: Premium',
                          rec.kol_proekt_sgp);*/
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies all state: Number'
                                                     ,rec.kol_all_st);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies all state: Premium'
                                                     ,rec.kol_all_st_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Number'
                                                     ,rec.kol_status);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Premium'
                                                     ,rec.kol_status_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Premium in USD'
                                                     ,rec.kol_status_sgp / 23.5);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies other state: Number'
                                                     ,rec.kol_oth_st);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies other state: Premium'
                                                     ,rec.kol_oth_st_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies other state: Premium'
                                                     ,rec.kol_oth_st_sgp / 23.5);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Premium Received'
                                                     ,rec.paym);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Premium Received'
                                                     ,rec.paym / 23.5);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Outstanding Polices: Number'
                                                     ,rec.kol_rast);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Outstanding Polices: Premium'
                                                     ,rec.kol_rast_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'#of agents with contracts'
                                                     ,rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'#of selling Agents'
                                                     ,rec.agent_pol);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies per agent'
                                                     ,rec.kol_all_st / rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies per selling agent'
                                                     ,rec.kol_all_st / rec.agent_pol);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Life'
                                                     ,rec.life);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Fdep'
                                                     ,rec.fdep);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Fdep_Sum'
                                                     ,rec.fdep_sum);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Accident'
                                                     ,rec.ns);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Savings'
                                                     ,rec.nakop);
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Corporate'
                                                     ,rec.gn);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Other'
                                                     ,rec.other);
    
    END LOOP;
    COMMIT;
  END;

  --Вызывает выполнение отчета NewBusiness CurrentMonth
  PROCEDURE create_currentmonth
  (
    dleft  DATE
   ,dright DATE
  ) IS
    first_day DATE;
    end_day   DATE;
  BEGIN
    first_day := trunc(dleft, 'mm');
    end_day   := last_day(dleft);
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    FOR rec IN (SELECT d.dep
                      ,d.sales_chnl
                      ,kol_proekt.kol_proekt
                      ,kol_proekt.kol_proekt_sgp
                      ,kol_status.kol_status
                      ,kol_status.kol_status_sgp
                      ,kol_proekt_month.kol_proekt_month
                      ,kol_proekt_month.kol_proekt_month_sgp
                      ,kol_status_month.kol_status_month
                      ,kol_status_month.kol_status_month_sgp
                      ,kol_rast.kol_rast
                      ,kol_rast.kol_rast_sgp
                      ,kol_agent.kol_agent
                      ,agent_pol.agent_pol
                      ,NULL                                  AS ag_fio
                      ,NULL                                  AS pr_name
                  FROM (SELECT COUNT(*) AS all_prog
                              ,k.dep
                              ,k.sales_chnl
                          FROM (SELECT pp.policy_header_id
                                      ,pp.pol_ser || ' ' || pp.pol_num
                                      ,pp.notice_num
                                      ,pp.start_date
                                      ,dep.name AS dep
                                      ,ch.description AS sales_chnl
                                      ,st.name AS policy_agent_status
                                  FROM ins.v_policy_version_journal pp
                                  LEFT JOIN ins.p_policy_agent ag
                                    ON (pp.policy_header_id = ag.policy_header_id)
                                  LEFT JOIN ins.ag_contract_header ah
                                    ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                  LEFT JOIN ins.department dep
                                    ON ah.agency_id = dep.department_id
                                  LEFT JOIN ins.policy_agent_status st
                                    ON (ag.status_id = st.policy_agent_status_id)
                                  LEFT JOIN ins.t_sales_channel ch
                                    ON (ch.id = pp.sales_channel_id)
                                 WHERE pp.policy_id = pp.active_policy_id
                                   AND pp.status_name NOT IN ('Отменен')
                                   AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                   AND pp.notice_date BETWEEN ADD_MONTHS(first_day, -3) AND
                                       ADD_MONTHS(end_day, 3)) k
                         GROUP BY k.dep
                                 ,k.sales_chnl) d
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_proekt
                                  ,SUM(k.sgp) AS kol_proekt_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.src_doc_status_ref_id = 0
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date = dleft) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_proekt
                    ON (kol_proekt.dep = d.dep AND kol_proekt.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_status
                                  ,SUM(k.sgp) AS kol_status_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.src_doc_status_ref_id IN (1, 2, 18, 19, 20)
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND state.start_date = dleft) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_status
                    ON (kol_status.dep = d.dep AND kol_status.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_proekt_month
                                  ,SUM(k.sgp) AS kol_proekt_month_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.src_doc_status_ref_id = 0
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date BETWEEN first_day AND end_day
                                       AND pp.notice_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_proekt_month
                    ON (kol_proekt_month.dep = d.dep AND kol_proekt_month.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_status_month
                                  ,SUM(k.sgp) AS kol_status_month_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND pp.status_name IN ('Действующий'
                                                             ,'Напечатан'
                                                             ,'Новый'
                                                             ,'Активный'
                                                             ,'Андеррайтинг')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND pp.notice_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_status_month
                    ON (kol_status_month.dep = d.dep AND kol_status_month.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_rast
                                  ,SUM(k.sgp) AS kol_rast_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.doc_status_ref_id = 10
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_rast
                    ON (kol_rast.dep = d.dep AND kol_rast.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_agent
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,ah.date_begin
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) AS status
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     WHERE nvl(ah.date_break, '01-01-1900') < end_day
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_agent
                    ON (kol_agent.dep = d.dep AND kol_agent.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS agent_pol
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,dep.name       AS dep
                                          ,ch.description AS sales_chnl
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     INNER JOIN (SELECT DISTINCT ah.agent_id
                                                               ,dep.name       AS dep
                                                               ,ch.description AS sales_chnl
                                                  FROM ins.ag_contract_header ah
                                                  LEFT JOIN ins.p_policy_agent pa
                                                    ON (pa.ag_contract_header_id =
                                                       ah.ag_contract_header_id)
                                                  LEFT JOIN ins.v_policy_version_journal pp
                                                    ON (pp.policy_header_id = pa.policy_header_id)
                                                  LEFT JOIN ins.department dep
                                                    ON ah.agency_id = dep.department_id
                                                  LEFT JOIN ins.policy_agent_status st
                                                    ON (pa.status_id = st.policy_agent_status_id)
                                                  LEFT JOIN ins.t_sales_channel ch
                                                    ON (ch.id = pp.sales_channel_id)
                                                 INNER JOIN ins.v_policy_payment_schedule paym
                                                    ON (pp.policy_header_id = paym.pol_header_id)
                                                 WHERE pp.policy_id = pp.active_policy_id
                                                   AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                                   AND paym.doc_status_ref_name = 'Оплачен'
                                                   AND pp.notice_date BETWEEN first_day AND end_day) pp
                                        ON (pp.agent_id = ah.agent_id AND pp.dep = dep.name AND
                                           pp.sales_chnl = ch.description)
                                     WHERE nvl(ah.date_break, '01-01-1900') < end_day
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) agent_pol
                    ON (agent_pol.dep = d.dep AND agent_pol.sales_chnl = d.sales_chnl))
    LOOP
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies entered in system: Number'
                                                     ,rec.kol_proekt);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies entered in system: Premium'
                                                     ,rec.kol_proekt_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Number'
                                                     ,rec.kol_status);
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Premium'
                                                     ,rec.kol_status_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies entered in system: Number'
                                                     ,rec.kol_proekt_month);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies entered in system: Premium'
                                                     ,rec.kol_proekt_month_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies Processed: Number'
                                                     ,rec.kol_status_month);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies Processed: Premium'
                                                     ,rec.kol_status_month_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Outstanding Polices: Number'
                                                     ,rec.kol_rast);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Outstanding Polices: Premium'
                                                     ,rec.kol_rast_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: #of agents with contracts'
                                                     ,rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: #of selling Agents'
                                                     ,rec.agent_pol);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies per agent'
                                                     ,rec.kol_proekt / rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies per selling agent'
                                                     ,rec.kol_proekt / rec.agent_pol);
    
    END LOOP;
    COMMIT;
  END;

  --Вызывает выполнение отчета NewBusiness NextMonth
  PROCEDURE create_nextmonth
  (
    dleft  DATE
   ,dright DATE
  ) IS
    first_day DATE;
    end_day   DATE;
  BEGIN
    first_day := trunc(ADD_MONTHS(dleft, 1), 'mm');
    end_day   := last_day(ADD_MONTHS(dleft, 1));
    DELETE FROM ins_dwh.rep_sr_wo_prog;
  
    FOR rec IN (SELECT d.dep
                      ,d.sales_chnl
                      ,kol_proekt.kol_proekt
                      ,kol_proekt.kol_proekt_sgp
                      ,kol_status.kol_status
                      ,kol_status.kol_status_sgp
                      ,kol_proekt_month.kol_proekt_month
                      ,kol_proekt_month.kol_proekt_month_sgp
                      ,kol_status_month.kol_status_month
                      ,kol_status_month.kol_status_month_sgp
                      ,kol_rast.kol_rast
                      ,kol_rast.kol_rast_sgp
                      ,kol_agent.kol_agent
                      ,agent_pol.agent_pol
                      ,NULL                                  AS ag_fio
                      ,NULL                                  AS pr_name
                  FROM (SELECT COUNT(*) AS all_prog
                              ,k.dep
                              ,k.sales_chnl
                          FROM (SELECT pp.policy_header_id
                                      ,pp.pol_ser || ' ' || pp.pol_num
                                      ,pp.notice_num
                                      ,pp.start_date
                                      ,dep.name AS dep
                                      ,ch.description AS sales_chnl
                                      ,st.name AS policy_agent_status
                                  FROM ins.v_policy_version_journal pp
                                  LEFT JOIN ins.p_policy_agent ag
                                    ON (pp.policy_header_id = ag.policy_header_id)
                                  LEFT JOIN ins.ag_contract_header ah
                                    ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                  LEFT JOIN ins.department dep
                                    ON ah.agency_id = dep.department_id
                                  LEFT JOIN ins.policy_agent_status st
                                    ON (ag.status_id = st.policy_agent_status_id)
                                  LEFT JOIN ins.t_sales_channel ch
                                    ON (ch.id = pp.sales_channel_id)
                                 WHERE pp.policy_id = pp.active_policy_id
                                   AND pp.status_name NOT IN ('Отменен')
                                   AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                   AND pp.notice_date BETWEEN ADD_MONTHS(first_day, -3) AND
                                       ADD_MONTHS(end_day, 3)) k
                         GROUP BY k.dep
                                 ,k.sales_chnl) d
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_proekt
                                  ,SUM(k.sgp) AS kol_proekt_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.src_doc_status_ref_id = 0
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date = dleft) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_proekt
                    ON (kol_proekt.dep = d.dep AND kol_proekt.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_status
                                  ,SUM(k.sgp) AS kol_status_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.src_doc_status_ref_id IN (1, 2, 18, 19, 20)
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND state.start_date = dleft) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_status
                    ON (kol_status.dep = d.dep AND kol_status.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_proekt_month
                                  ,SUM(k.sgp) AS kol_proekt_month_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.src_doc_status_ref_id = 0
                                       AND pp.status_name NOT IN ('Отменен')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date BETWEEN first_day AND end_day
                                       AND pp.notice_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_proekt_month
                    ON (kol_proekt_month.dep = d.dep AND kol_proekt_month.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_status_month
                                  ,SUM(k.sgp) AS kol_status_month_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND pp.status_name IN ('Действующий'
                                                             ,'Напечатан'
                                                             ,'Новый'
                                                             ,'Активный'
                                                             ,'Андеррайтинг')
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND pp.notice_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_status_month
                    ON (kol_status_month.dep = d.dep AND kol_status_month.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_rast
                                  ,SUM(k.sgp) AS kol_rast_sgp
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT pp.policy_header_id
                                          ,pp.policy_id
                                          ,pp.start_date
                                          ,pp.notice_num
                                          ,pp.pol_ser || ' ' || pp.pol_num
                                          ,pp.premium
                                          ,pp.fund_id
                                          ,pp.premium * (CASE pp.fund_id
                                             WHEN 122 THEN
                                              1
                                             WHEN 121 THEN
                                              25
                                             WHEN 5 THEN
                                              35
                                           END) AS sgp
                                          ,pp.status_name
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,st.name AS policy_agent_status
                                      FROM ins.v_policy_version_journal pp
                                      LEFT JOIN ins.p_policy_agent ag
                                        ON (pp.policy_header_id = ag.policy_header_id)
                                      LEFT JOIN ins.ag_contract_header ah
                                        ON (ag.ag_contract_header_id = ah.ag_contract_header_id)
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.policy_agent_status st
                                        ON (ag.status_id = st.policy_agent_status_id)
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = pp.sales_channel_id)
                                      LEFT JOIN ins.ven_doc_status state
                                        ON (state.document_id = pp.active_policy_id)
                                     WHERE pp.policy_id = pp.active_policy_id
                                       AND state.doc_status_ref_id = 10
                                       AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                       AND state.start_date BETWEEN first_day AND end_day) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_rast
                    ON (kol_rast.dep = d.dep AND kol_rast.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS kol_agent
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,ah.date_begin
                                          ,dep.name AS dep
                                          ,ch.description AS sales_chnl
                                          ,decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) AS status
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     WHERE nvl(ah.date_break, '01-01-1900') < end_day
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) kol_agent
                    ON (kol_agent.dep = d.dep AND kol_agent.sales_chnl = d.sales_chnl)
                
                  LEFT JOIN (SELECT COUNT(*) AS agent_pol
                                  ,k.dep
                                  ,k.sales_chnl
                              FROM (SELECT ah.agent_id
                                          ,dep.name       AS dep
                                          ,ch.description AS sales_chnl
                                      FROM ins.ag_contract_header ah
                                      LEFT JOIN ins.department dep
                                        ON ah.agency_id = dep.department_id
                                      LEFT JOIN ins.t_sales_channel ch
                                        ON (ch.id = ah.t_sales_channel_id)
                                      JOIN ins.document d
                                        ON d.document_id = ah.ag_contract_header_id
                                      JOIN ins.doc_status ds
                                        ON (ds.document_id = d.document_id AND
                                           ds.start_date IN
                                           (SELECT MAX(dd.start_date)
                                               FROM ins.doc_status dd
                                              WHERE dd.document_id = d.document_id))
                                     INNER JOIN (SELECT DISTINCT ah.agent_id
                                                               ,dep.name       AS dep
                                                               ,ch.description AS sales_chnl
                                                  FROM ins.ag_contract_header ah
                                                  LEFT JOIN ins.p_policy_agent pa
                                                    ON (pa.ag_contract_header_id =
                                                       ah.ag_contract_header_id)
                                                  LEFT JOIN ins.v_policy_version_journal pp
                                                    ON (pp.policy_header_id = pa.policy_header_id)
                                                  LEFT JOIN ins.department dep
                                                    ON ah.agency_id = dep.department_id
                                                  LEFT JOIN ins.policy_agent_status st
                                                    ON (pa.status_id = st.policy_agent_status_id)
                                                  LEFT JOIN ins.t_sales_channel ch
                                                    ON (ch.id = pp.sales_channel_id)
                                                 INNER JOIN ins.v_policy_payment_schedule paym
                                                    ON (pp.policy_header_id = paym.pol_header_id)
                                                 WHERE pp.policy_id = pp.active_policy_id
                                                   AND st.name NOT IN ('ОТМЕНЕН', 'ОШИБКА')
                                                   AND paym.doc_status_ref_name = 'Оплачен'
                                                   AND pp.notice_date BETWEEN first_day AND end_day) pp
                                        ON (pp.agent_id = ah.agent_id AND pp.dep = dep.name AND
                                           pp.sales_chnl = ch.description)
                                     WHERE nvl(ah.date_break, '01-01-1900') < end_day
                                       AND decode(ins.doc.get_doc_status_brief(d.document_id
                                                                              ,ds.start_date)
                                                 ,'BREAK'
                                                 ,ins.doc.get_doc_status_name(d.document_id, SYSDATE)
                                                 ,ins.doc.get_doc_status_name(d.document_id
                                                                             ,ds.start_date)) NOT IN
                                           ('Расторгнут'
                                           ,'Завершен'
                                           ,'Отменен'
                                           ,'Приостановлен'
                                           ,'Закрыт')) k
                             GROUP BY k.dep
                                     ,k.sales_chnl) agent_pol
                    ON (agent_pol.dep = d.dep AND agent_pol.sales_chnl = d.sales_chnl))
    LOOP
    
      -- добавляем строки в таблицу
      -- ////////////////////////////////////////////
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies entered in system: Number'
                                                     ,rec.kol_proekt);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies entered in system: Premium'
                                                     ,rec.kol_proekt_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Number'
                                                     ,rec.kol_status);
    
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Policies Processed: Premium'
                                                     ,rec.kol_status_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies entered in system: Number'
                                                     ,rec.kol_proekt_month);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies entered in system: Premium'
                                                     ,rec.kol_proekt_month_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies Processed: Number'
                                                     ,rec.kol_status_month);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies Processed: Premium'
                                                     ,rec.kol_status_month_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Outstanding Polices: Number'
                                                     ,rec.kol_rast);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Outstanding Polices: Premium'
                                                     ,rec.kol_rast_sgp);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: #of agents with contracts'
                                                     ,rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: #of selling Agents'
                                                     ,rec.agent_pol);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies per agent'
                                                     ,rec.kol_proekt / rec.kol_agent);
      ins_dwh.pkg_rep_utils_ins11.insert_row_to_sr_wo(rec.sales_chnl
                                                     ,rec.dep
                                                     ,rec.ag_fio
                                                     ,rec.pr_name
                                                     ,'Month to date: Policies per selling agent'
                                                     ,rec.kol_proekt / rec.agent_pol);
    
    END LOOP;
    COMMIT;
  END;

  -- добавляет строку в таблицу rep_sr_wo_prog
  PROCEDURE insert_row_to_sr_wo
  (
    fchanal VARCHAR2
   ,fdep    VARCHAR2
   ,fagent  VARCHAR2
   ,fpol    VARCHAR2
   ,fprod   VARCHAR2
   ,fparam  VARCHAR2
   ,fvalue  NUMBER
  ) IS
  BEGIN
    INSERT INTO ins_dwh.rep_sr_wo_prog sr
      (chanal, agency, AGENT, product, param, policy_num, VALUE)
    VALUES
      (fchanal, fdep, fagent, fprod, fparam, fpol, fvalue);
  END;

  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(30) := 'get_p_agent_current';
  BEGIN
    SELECT a
      INTO RESULT
      FROM (SELECT CASE
                     WHEN par_return = 1 THEN
                      pa.ag_contract_header_id
                     ELSE
                      pa.p_policy_agent_doc_id
                   END a
              FROM ins.p_policy_agent_doc pa
             WHERE 1 = 1
               AND pa.policy_header_id = par_pol_header_id
               AND par_date BETWEEN pa.date_begin AND pa.date_end
            --AND ins.doc.get_doc_status_brief(pa.p_policy_agent_doc_id) = 'CURRENT'
            )
     WHERE rownum = 1;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_p_agent_current;

  FUNCTION check_save_date_kp
  (
    par_pol_header_id         NUMBER
   ,par_ag_contract_header_id NUMBER
   ,par_date                  DATE
   ,par_rep_name              VARCHAR2
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    v_result := 0;
    IF par_rep_name = 'Отчет о просроченных платежах для перевода на прямое сопровождение'
    THEN
      --если дата КП <= Даты документа, то договор не должен попасть в отчет
      --0 - договор попадает, 1 - договор не попадает в отчет.
      SELECT COUNT(1)
        INTO v_result
        FROM dual
       WHERE EXISTS (SELECT 1
                FROM ins.ven_hist_kp_policy hkp
               WHERE hkp.ag_contract_header_id = par_ag_contract_header_id
                 AND hkp.pol_header_id = par_pol_header_id
                 AND hkp.save_date > par_date);
    ELSIF par_rep_name = 'DWH_отчет о неоплатах_анализ неплат_2011'
    THEN
      --если дата КП > Даты срока платежа, то договор не должен попасть в отчет
      --0 - договор попадает, 1 - договор не попадает в отчет.
      SELECT COUNT(1)
        INTO v_result
        FROM dual
       WHERE EXISTS (SELECT 1
                FROM ins.ven_hist_kp_policy hkp
               WHERE hkp.ag_contract_header_id = par_ag_contract_header_id
                 AND hkp.pol_header_id = par_pol_header_id
                 AND hkp.save_date > par_date);
    END IF;
    RETURN v_result;
  END;

--BEGIN
-- Initialization
--<STATEMENT>;
END pkg_renlife_rep_utils;
/

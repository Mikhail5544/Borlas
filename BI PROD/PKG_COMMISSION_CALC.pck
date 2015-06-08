CREATE OR REPLACE PACKAGE pkg_commission_calc IS

  FUNCTION find_add_payment
  (
    p_date_begin   DATE
   ,p_date_end     DATE
   ,p_payment_date DATE DEFAULT SYSDATE
   ,p_pol_num      VARCHAR2
   ,p_roll_id      NUMBER
  ) RETURN NUMBER;

  FUNCTION get_correct_roll
  (
    p_arh_id  NUMBER
   ,p_roll_id NUMBER
  ) RETURN NUMBER;
  PROCEDURE set_group_banks(par_work_act_id ag_perfomed_work_act.ag_perfomed_work_act_id%TYPE);
  FUNCTION set_group_oav
  (
    p_arh_id                  NUMBER
   ,p_roll_id                 NUMBER
   ,p_ag_perfomed_work_act_id NUMBER
  ) RETURN NUMBER;
  PROCEDURE fill_banks_acts(par_ag_roll_id ag_roll.ag_roll_id%TYPE);
  FUNCTION set_group_prem
  (
    p_arh_id                  NUMBER
   ,p_roll_id                 NUMBER
   ,p_ag_perfomed_work_act_id NUMBER
  ) RETURN NUMBER;
  FUNCTION set_ungroup_prem
  (
    p_arh_id  NUMBER
   ,p_roll_id NUMBER
  ) RETURN NUMBER;
  PROCEDURE load_detail_commission
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
   ,par_roll_id      NUMBER
  );
  PROCEDURE save_to_ag_roll(p_roll_id NUMBER DEFAULT NULL);
  FUNCTION get_vol
  (
    par_ag_contract_header PLS_INTEGER
   ,par_roll_id            NUMBER
   ,par_rl_vol             NUMBER
   ,par_inv_vol            NUMBER
   ,par_ops_vol            NUMBER
   ,par_ops2_vol           NUMBER
   ,par_sofi_vol           NUMBER
  ) RETURN t_volume_val_o;

  /*  Создание шапки ведомости на выплату
      Параметры:
               Дата начала периода
               Дата окончания периода
               Версия расчетной ведомости
               Тип компании
               Выходной: ИД выплатной ведомости
      Веселуха Е.В.
      Изменения: 26.04.2013
  */
  FUNCTION create_ag_roll_pay
  (
    p_begin_date            DATE
   ,p_end_date              DATE
   ,p_ag_roll_num           NUMBER
   ,p_type_company          NUMBER
   ,p_ag_roll_pay_header_id OUT NUMBER
  ) RETURN NUMBER;

  /*  Создание деталей выплатной ведомости
      Параметры:
               ИД шапки выплатной ведомости
      Тип компании - 2 Партнерс: собираем Агентов, Менеджеров, Директоров
                     1 РЖ: собираем Тер директоров
  */
  PROCEDURE create_ag_pay_detail(p_ag_pay_header_id NUMBER);

  FUNCTION prep_detail_to RETURN NUMBER;
  /*Процедура проверки данных при заливке
   Веселуха Е.В.
   12.02.2013
  */
  PROCEDURE check_data_detail
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  );
  /*  Включить предыдущие периоды:
      к выплатной ведомости добавляем
      не выплаченные детали
      Веселуха Е.В.
      24.04.2013
      Параметр - ИД выплатной ведомости в статусе Новый
  */
  PROCEDURE add_last_period(par_roll_pay_header_id NUMBER);
  /*Процедура заливки в БД данных деталей КВ
    Веселуха Е.В.
    12.02.2013
  */
  PROCEDURE save_to_detail_commiss(par_load_file_id NUMBER);
  /*  Экспорт выплатной ведомости в 1С
      Веселуха Е.
      19.04.2013
      Параметр - ИД выплатной ведомости
  */
  PROCEDURE export_sav(par_roll_pay_header_id NUMBER);
  /*Процедура проверки данных при заливке
   Веселуха Е.В.
   23.08.2013
  */
  PROCEDURE check_data_detail_group(par_load_file_id NUMBER);
  /*Процедуры проверки реквизитов при заливки банков / брокеров
    и проставления им признака и даты РСБУ
    Веселуха Е.В.
    23.08.2013
  */
  PROCEDURE check_bank_group(par_load_file_id NUMBER);
  PROCEDURE check_bank
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  );
  /*Процедура обновления признака и дат РСБУ для Банков / Брокеров
    в ведомости объемов
    Веселуха Е.В.
    23.08.2013
  */
  PROCEDURE load_bank_group(par_load_file_id NUMBER);
  /*Веселуха Е.В.
    30.10.2013
    Проверки перед пересчетом ведомости RLP
  */
  PROCEDURE check_recalc_roll(p_ag_roll_id NUMBER);
  /*Веселуха Е.В.
    11.09.2013
    Пересчет ведомости RLP, размазка по АВНадо    
  */
  PROCEDURE calc(p_ag_roll_id NUMBER);
  /*Веселуха Е.В.
    11.09.2013
    Размазка по АВНадо
  */
  PROCEDURE recalcrlp(p_ag_roll_id NUMBER);
  /*Веселуха Е.В.
    30.10.2013
    Копируем AG_ROLL
    Параметры: p_ag_roll_id - на какую, p_copy_ag_roll_id - с какой копируем
  */
  PROCEDURE copy_ag_roll
  (
    p_ag_roll_id      NUMBER
   ,p_copy_ag_roll_id NUMBER
  );

END pkg_commission_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_commission_calc IS

  /* ОБЪЯВЛЕННЫЕ ПЕРЕМЕННЫЕ */
  --Инициализация в самом конце пакета
  --Статусы документов
  g_st_new          PLS_INTEGER;
  g_st_act          PLS_INTEGER;
  g_st_curr         PLS_INTEGER;
  g_st_cancel       PLS_INTEGER;
  g_st_stoped       PLS_INTEGER;
  g_st_print        PLS_INTEGER;
  g_st_revision     PLS_INTEGER;
  g_st_agrevision   PLS_INTEGER;
  g_st_underwr      PLS_INTEGER;
  g_st_berak        PLS_INTEGER;
  g_st_readycancel  PLS_INTEGER;
  g_st_paid         PLS_INTEGER;
  g_st_annulated    PLS_INTEGER;
  g_st_resume       PLS_INTEGER;
  g_st_stop         PLS_INTEGER;
  g_st_concluded    PLS_INTEGER;
  g_st_to_agent     PLS_INTEGER;
  g_st_from_agent   PLS_INTEGER;
  g_st_error        PLS_INTEGER;
  g_st_quit         PLS_INTEGER;
  g_st_quit_to_pay  PLS_INTEGER;
  g_st_quit_req_reg PLS_INTEGER;
  g_st_quit_query   PLS_INTEGER;
  g_st_to_quit_ch   PLS_INTEGER;
  g_st_to_quit      PLS_INTEGER;
  g_st_ch_ready     PLS_INTEGER;
  --Курс на ЦБ
  g_rev_rate_type_id PLS_INTEGER;
  g_fund_rur         PLS_INTEGER;
  --Параметры АД
  g_ct_agent           PLS_INTEGER;
  g_sc_dsf             PLS_INTEGER;
  g_sc_sas             PLS_INTEGER;
  g_sc_sas_2           PLS_INTEGER;
  g_sc_grs_moscow      PLS_INTEGER;
  g_sc_grs_region      PLS_INTEGER;
  g_ag_fake_agent      PLS_INTEGER;
  g_ag_external_agency PLS_INTEGER;
  --Платежные периоды
  g_pt_quater       PLS_INTEGER;
  g_pt_nonrecurring PLS_INTEGER;
  g_pt_monthly      PLS_INTEGER;
  g_pt_year         PLS_INTEGER;
  g_pt_halfyear     PLS_INTEGER;
  --Юридические статусы
  g_cn_legentity PLS_INTEGER;
  g_cn_natperson PLS_INTEGER;
  g_cn_legal     PLS_INTEGER;
  --Шаблоны документов
  g_dt_pp_noncash_doc PLS_INTEGER;
  g_dt_a7_doc         PLS_INTEGER;
  g_dt_pd4_doc        PLS_INTEGER;
  g_dt_epg_doc        PLS_INTEGER;
  g_dt_pp_direct_doc  PLS_INTEGER;
  g_dt_pp_payer_doc   PLS_INTEGER;
  --Шаблоны платежек
  g_apt_a7         PLS_INTEGER;
  g_apt_pd4        PLS_INTEGER;
  g_apt_pp         PLS_INTEGER;
  g_apt_pp_dir_p   PLS_INTEGER;
  g_apt_pp_payer_p PLS_INTEGER;
  g_apt_ukv        PLS_INTEGER;
  --Виды перечисления денег
  g_cm_direct_pay  PLS_INTEGER;
  g_cm_noncash_pay PLS_INTEGER;
  g_cm_payer_pay   PLS_INTEGER;
  g_cm_tech        PLS_INTEGER;
  --Продукт
  g_pr_familydep         PLS_INTEGER;
  g_pr_familydep_2011    PLS_INTEGER;
  g_pr_familydep_2014    PLS_INTEGER;
  g_pr_protect_state     PLS_INTEGER;
  g_pr_bank_1            PLS_INTEGER;
  g_pr_bank_2            PLS_INTEGER;
  g_pr_bank_3            PLS_INTEGER;
  g_pr_bank_4            PLS_INTEGER;
  g_pr_bank_5            PLS_INTEGER;
  g_pr_investor          PLS_INTEGER;
  g_pr_investor_lump     PLS_INTEGER;
  g_pr_investor_lump_old PLS_INTEGER;
  g_prod_cr92_1          PLS_INTEGER;
  g_prod_cr92_2          PLS_INTEGER;
  g_prod_cr92_3          PLS_INTEGER;
  g_prod_cr92_1_1        PLS_INTEGER;
  g_prod_cr92_2_1        PLS_INTEGER;
  g_prod_cr92_3_1        PLS_INTEGER;
  --Типы объемов
  g_vt_life    PLS_INTEGER;
  g_vt_ops     PLS_INTEGER;
  g_vt_ops_1   PLS_INTEGER;
  g_vt_ops_2   PLS_INTEGER;
  g_vt_ops_3   PLS_INTEGER;
  g_vt_ops_9   PLS_INTEGER;
  g_vt_inv     PLS_INTEGER;
  g_vt_avc     PLS_INTEGER;
  g_vt_avc_pay PLS_INTEGER;
  g_vt_nonevol PLS_INTEGER;
  g_vt_bank    PLS_INTEGER;
  g_vt_fdep    PLS_INTEGER;
  --АВНадо и АВРасчет для Пересчета RLP
  g_av_need   NUMBER;
  g_av_calc   NUMBER;
  g_av_recalc NUMBER;

  FUNCTION find_add_payment
  (
    p_date_begin   DATE
   ,p_date_end     DATE
   ,p_payment_date DATE DEFAULT SYSDATE
   ,p_pol_num      VARCHAR2
   ,p_roll_id      NUMBER
  ) RETURN NUMBER IS
  
    proc_name VARCHAR2(20) := 'FIND_ADD_PAYMENT';
  
  BEGIN
  
    DELETE FROM t_founded_payment;
    INSERT INTO t_founded_payment
      (ag_volume_type_id
      ,ag_roll_id
      ,ag_contract_header_id
      ,policy_header_id
      ,date_begin
      ,conclude_date
      ,ins_period
      ,payment_term_id
      ,last_status
      ,active_status
      ,fund
      ,epg_payment
      ,epg_date
      ,pay_period
      ,epg_status
      ,epg_ammount
      ,epg_pd_type
      ,pd_copy_status
      ,pd_payment
      ,pd_collection_method
      ,payment_date
      ,t_prod_line_option_id
      ,trans_id
      ,trans_sum
      ,index_delta_sum
      ,nbv_coef
      ,is_nbv
      ,is_added)
      SELECT CASE
               WHEN (epg_st <> 6 AND (epg_payed / rev_amount < 0.999 OR payment_date < '26.08.2010') AND
                    nvl(is_trans_annul, 0) = 0) THEN
                g_vt_nonevol
               WHEN nvl(pd_copy_stat, 6) = 41 THEN
                (CASE
                  WHEN (SELECT COUNT(*)
                          FROM ins.ag_volume agv
                         WHERE agv.epg_payment = epg
                           AND agv.ag_volume_type_id = g_vt_life) > 0 THEN
                   g_vt_life
                  WHEN nvl(is_trans_annul, 0) = 1 THEN
                   g_vt_life
                  ELSE
                   g_vt_nonevol
                END)
               WHEN (nvl(pd_copy_stat, 6) <> 6) THEN
                g_vt_nonevol
               ELSE
                (CASE
                  WHEN vol.product_id IN (28487, 42000)
                       AND pay_term = 163
                       AND greatest(conclude_date, payment_date, date_s) > '25.05.2011' THEN
                   g_vt_nonevol
                  WHEN vol.product_id IN (28487, 42000)
                       AND pay_period > 1 THEN
                   g_vt_nonevol
                  WHEN vol.product_id IN (28487, 42000)
                       AND pay_period <= 1
                       AND pay_term IN (g_pt_quater, g_pt_year, g_pt_halfyear) THEN
                   g_vt_fdep
                  WHEN vol.product_id IN (g_pr_investor, g_pr_investor_lump, g_pr_investor_lump_old)
                       AND pay_doc_cm <> g_cm_tech THEN
                   g_vt_inv
                  ELSE
                   (CASE
                     WHEN pay_doc_cm = g_cm_tech THEN
                      g_vt_nonevol
                     ELSE
                      g_vt_life
                   END)
                END)
             END vol_type
            ,p_roll_id
            ,ag_contract_header_id
            ,policy_header_id
            ,date_s
            ,conclude_date
            ,ins_period
            ,pay_term
            ,last_st
            ,active_st
            ,fund
            ,epg
            ,epg_date
            ,pay_period
            ,epg_st
            ,epg_amt
            ,epg_pd_type
            ,pd_copy_stat
            ,pay_doc
            ,pay_doc_cm
            ,payment_date
            ,tplo_id
            ,CASE
               WHEN epg_st = 6
                    AND nvl(pd_copy_stat, 6) = 6 THEN
                trans_id
               WHEN epg_payed / rev_amount >= (CASE
                      WHEN fund <> 122 THEN
                       0.99
                      ELSE
                       0.999
                    END) THEN
                trans_id
               WHEN nvl(is_trans_annul, 0) = 1 THEN
                trans_id
               ELSE
                NULL
             END trans_id
            ,trans_sum
            ,ROUND(ind_sum, 2) ind_sum
            ,CASE
               WHEN nvl(pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss'
                                                      ,t_number_type(policy_header_id))
                       ,999) = 999 THEN
                (CASE
                  WHEN vol.product_id = 39456 THEN
                   0
                  WHEN vol.product_id IN (g_pr_bank_1, g_pr_bank_2, g_pr_bank_3, g_pr_bank_4, g_pr_bank_5) THEN
                   0.5
                  ELSE
                   CASE
                     WHEN (pay_period = 1 OR nvl(ind_sum, 0) <> 0)
                          AND epg_st = 6
                          AND nvl(pd_copy_stat, 6) = 6 THEN
                      CASE
                        WHEN pay_term = 163
                             AND ins_period > 1 THEN
                         0.1
                        ELSE
                         first_pay_coef
                      END
                     WHEN pay_period = 1
                          AND epg_payed / rev_amount >= 0.999 THEN
                      1
                     ELSE
                      0
                   END
                END)
               ELSE
                pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss', t_number_type(policy_header_id))
             END nbv_coef
            ,CASE
               WHEN (pay_period = 1 OR nvl(ind_sum, 0) <> 0)
                    AND epg_st = 6
                    AND nvl(pd_copy_stat, 6) = 6 THEN
                1
               WHEN (pay_period = 1 AND epg_payed / rev_amount >= 0.999) THEN
                1
               ELSE
                0
             END is_nbv
            ,1 is_added
        FROM (SELECT pad.ag_contract_header_id
                    ,ph.policy_header_id
                    ,ph.product_id
                    ,pp.policy_id
                    ,ph.start_date date_s
                    ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) ins_period
                    ,pp.payment_term_id pay_term
                    ,ph.ref_ph_id last_st
                    ,ph.ref_pp_id active_st
                    ,ph.fund_id fund
                    ,(SELECT MIN(ds1.start_date)
                        FROM p_policy   pp1
                            ,doc_status ds1
                       WHERE pp1.pol_header_id = ph.policy_header_id
                         AND pp1.policy_id = ds1.document_id
                         AND ds1.doc_status_ref_id IN (91, 2)) conclude_date
                    ,epg.plan_date epg_date
                    ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date) / 12) + 1 pay_period
                    ,epg.payment_id epg
                    ,epg.amount epg_amt
                    ,decode(ph.fund_id, 122, epg.amount, epg.rev_amount) rev_amount
                    ,(SELECT nvl(SUM(decode(dd_e.doc_doc_id
                                           ,NULL
                                           ,dso_e.set_off_child_amount
                                           ,dso2_e.set_off_child_amount))
                                ,0)
                        FROM doc_set_off dso_e
                            ,ac_payment  acp_e
                            ,doc_doc     dd_e
                            ,doc_set_off dso2_e
                       WHERE dso_e.parent_doc_id = epg.payment_id
                         AND acp_e.payment_id = dso_e.parent_doc_id
                         AND dso_e.cancel_date IS NULL
                         AND acp_e.payment_id = dd_e.parent_id(+)
                         AND dd_e.child_id = dso2_e.parent_doc_id(+)
                         AND dso2_e.cancel_date IS NULL) epg_payed
                    ,doc.get_doc_status_id(epg.payment_id) epg_st
                    ,epg_dso.set_off_child_amount epg_set_off
                    ,epg_pd.payment_templ_id epg_pd_type
                    ,decode(ph.fund_id, 122, epg_pd_copy.amount, epg_pd_copy.rev_amount) pd_copy_rev_amount
                    ,pd_dso.set_off_amount pd_dso_set_off_amount
                    ,doc.get_doc_status_id(epg_pd_copy.payment_id) pd_copy_stat
                    ,nvl(pp_pd.payment_id, epg_pd.payment_id) pay_doc
                    ,(SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = epg.payment_id
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN (4983, 6277, 2, 16123, 16125)) payment_date
                    ,nvl(pp_pd.collection_metod_id
                        ,nvl(epg_pd_copy.collection_metod_id, epg_pd.collection_metod_id)) pay_doc_cm
                    ,CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) = 3
                            AND pp.payment_term_id = 166 THEN
                        (SELECT nvl(MIN(CASE
                                          WHEN nvl(pay_1.collection_metod_id, epg_pd1.collection_metod_id) = 3 THEN
                                           1
                                          ELSE
                                           2
                                        END)
                                   ,2)
                           FROM p_policy       pp1
                               ,doc_doc        dd_policy
                               ,ven_ac_payment epg1
                               ,doc_set_off    epg_so
                               ,ac_payment     epg_pd1
                               ,doc_doc        dd_copy
                               ,doc_set_off    copy_so
                               ,ac_payment     pay_1
                          WHERE pp1.pol_header_id = ph.policy_header_id
                            AND dd_policy.parent_id = pp1.policy_id
                            AND dd_policy.child_id = epg1.payment_id
                            AND epg1.doc_templ_id = 4
                            AND epg1.plan_date < epg.plan_date
                            AND epg_so.parent_doc_id = epg1.payment_id
                            AND epg_so.child_doc_id = epg_pd1.payment_id
                            AND epg_pd1.payment_id = dd_copy.parent_id(+)
                            AND dd_copy.child_id = copy_so.parent_doc_id(+)
                            AND copy_so.child_doc_id = pay_1.payment_id(+))
                       ELSE
                        1
                     END first_pay_coef
                    ,pc.fee
                    ,tplo.id tplo_id
                    ,t.trans_id
                    ,t.trans_amount trans_sum
                    ,t.trans_amount - t.trans_amount / CASE
                       WHEN EXISTS
                        (SELECT NULL
                               FROM p_policy            pol
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(p_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' ||
                                               to_char(ADD_MONTHS(p_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(p_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(p_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(p_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       p_date_end
                                    END)
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2') THEN
                        CASE
                          WHEN pp.start_date >=
                               (SELECT pol.start_date
                                  FROM p_policy            pol
                                      ,p_pol_addendum_type ppa
                                      ,t_addendum_type     ta
                                 WHERE pol.pol_header_id = ph.policy_header_id
                                   AND pol.start_date BETWEEN (CASE
                                         WHEN to_char(p_date_end + 1, 'DD.MM') = '29.02'
                                              AND MOD(to_char(p_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                          to_date(28 || '.' ||
                                                  to_char(ADD_MONTHS(p_date_end, -12), 'MM.YYYY')
                                                 ,'DD.MM.YYYY')
                                         ELSE
                                          ADD_MONTHS(p_date_end, -12) + 1
                                       END)
                                   AND (CASE
                                         WHEN to_char(p_date_end, 'DD.MM') = '29.02'
                                              AND MOD(to_char(p_date_end, 'YYYY'), 4) <> 0 THEN
                                          to_date(28 || '.' || to_char(p_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                         ELSE
                                          p_date_end
                                       END)
                                   AND pol.policy_id = ppa.p_policy_id
                                   AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                   AND ta.brief = 'INDEXING2'
                                   AND rownum = 1 /*Да, потому что есть такие договора*/
                                ) THEN
                           ((SELECT pcl.fee pc_i
                               FROM p_policy            pol
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                                   ,as_asset            asl
                                   ,p_cover             pcl
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(p_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(ADD_MONTHS(p_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(p_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(p_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(p_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       p_date_end
                                    END)
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND asl.p_policy_id = pol.policy_id
                                AND pcl.as_asset_id = asl.as_asset_id
                                AND pcl.t_prod_line_option_id = pc.t_prod_line_option_id
                                AND rownum = 1) /
                           (SELECT pc_l.fee pc_l
                               FROM p_policy            pol
                                   ,as_asset            aas_l
                                   ,p_cover             pc_l
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(p_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(ADD_MONTHS(p_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(p_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(p_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(p_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(p_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       p_date_end
                                    END)
                                AND aas_l.p_policy_id = pkg_policy.get_previous_version(pol.policy_id)
                                AND pc_l.as_asset_id = aas_l.as_asset_id
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND pc_l.t_prod_line_option_id = pc.t_prod_line_option_id
                                AND rownum = 1))
                          ELSE
                           1
                        END
                       ELSE
                        1
                     END ind_sum
                    ,(SELECT 1
                        FROM dual
                       WHERE EXISTS
                       (SELECT NULL
                                FROM dual
                               WHERE nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                              ,'31.12.2999')
                                        ,-999) IN (g_st_quit
                                                  ,g_st_quit_to_pay
                                                  ,g_st_quit_req_reg
                                                  ,g_st_quit_query
                                                  ,g_st_to_quit_ch
                                                  ,g_st_to_quit
                                                  ,g_st_ch_ready)
                                 AND EXISTS
                               (SELECT NULL
                                        FROM doc_set_off dso1
                                            ,ac_payment  acp1
                                       WHERE dso1.parent_doc_id = epg.payment_id
                                         AND acp1.payment_id = dso1.child_doc_id
                                         AND doc.get_doc_status_id(acp1.payment_id) = g_st_annulated
                                         AND acp1.payment_templ_id IN
                                             (g_apt_a7
                                             ,g_apt_pd4
                                             ,g_apt_pp
                                             ,g_apt_pp_dir_p
                                             ,g_apt_pp_payer_p)
                                         AND EXISTS
                                       (SELECT NULL
                                                FROM ins.ag_volume agvf
                                               WHERE agvf.epg_payment = dso1.parent_doc_id)))) is_trans_annul
                FROM (SELECT pha.policy_header_id
                            ,pha.sales_channel_id
                            ,pha.start_date
                            ,pha.last_ver_id
                            ,pha.fund_id
                            ,pha.product_id
                            ,pha.policy_id
                            ,d_ph.doc_status_ref_id ref_ph_id
                            ,d_pp.doc_status_ref_id ref_pp_id
                        FROM ins.p_pol_header pha
                            ,ins.document     d_ph
                            ,ins.document     d_pp
                       WHERE pha.policy_header_id IN
                             (SELECT p.pol_header_id FROM p_policy p WHERE p.pol_num = p_pol_num)
                         AND pha.last_ver_id = d_ph.document_id
                         AND pha.policy_id = d_pp.document_id
                         AND pha.product_id NOT IN (g_prod_cr92_1
                                                   ,g_prod_cr92_2
                                                   ,g_prod_cr92_3
                                                   ,g_prod_cr92_1_1
                                                   ,g_prod_cr92_2_1
                                                   ,g_prod_cr92_3_1)
                         AND d_ph.doc_status_ref_id NOT IN
                             (21, 10, 188, 3, 187, 186, 185, 184, 182, 183)) ph
                    ,(SELECT *
                        FROM ins.p_policy_agent_doc pada
                            ,ins.document           padd
                       WHERE padd.document_id = pada.p_policy_agent_doc_id
                         AND padd.doc_status_ref_id <> 161) pad
                    ,ins.ven_p_policy pp
                    ,ins.doc_doc pp_dd
                    ,(SELECT *
                        FROM ins.ac_payment epga
                            ,ins.document   d_epg
                       WHERE d_epg.doc_templ_id = 4
                         AND epga.payment_id = d_epg.document_id
                         AND d_epg.doc_status_ref_id != 1) epg
                    ,ins.doc_set_off epg_dso
                    ,(SELECT *
                        FROM ins.ac_payment epg_pda
                       WHERE epg_pda.payment_templ_id IN (4983, 6277, 2, 16123, 16125)) epg_pd
                    ,ins.doc_doc pd_dd
                    ,ins.ac_payment epg_pd_copy
                    ,ins.doc_set_off pd_dso
                    ,ins.oper o
                    ,(SELECT tr.trans_id
                            ,tr.trans_amount
                            ,tr.oper_id
                            ,tr.obj_uro_id
                        FROM trans tr
                       WHERE tr.dt_account_id = 122) t
                    ,ins.p_cover pc
                    ,ins.t_prod_line_option tplo
                    ,(SELECT *
                        FROM ins.ac_payment pp_pda
                       WHERE (pp_pda.payment_templ_id IN (2, 16123, 16125) OR
                             pp_pda.payment_templ_id IS NULL)) pp_pd
               WHERE 1 = 1
                 AND ph.policy_header_id = pp.pol_header_id
                 AND ph.policy_header_id = pad.policy_header_id
                 AND (ph.sales_channel_id IN (12, 121, 161, 8, 10, 81) OR
                     pad.ag_contract_header_id IN (26101892, 25873698))
                 AND CASE
                       WHEN epg_pd.due_date < ph.start_date THEN
                        ph.start_date
                       ELSE
                        (SELECT MAX(acp1.due_date)
                           FROM doc_set_off dso1
                               ,ac_payment  acp1
                          WHERE dso1.parent_doc_id = epg.payment_id
                            AND acp1.payment_id = dso1.child_doc_id
                            AND acp1.payment_templ_id IN (4983, 6277, 2, 16123, 16125))
                     END BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
                 AND pp.policy_id = pp_dd.parent_id
                 AND pp_dd.child_id = epg.payment_id
                 AND epg.payment_id = epg_dso.parent_doc_id
                 AND epg_dso.child_doc_id = epg_pd.payment_id
                 AND epg_pd.payment_id = pd_dd.parent_id(+)
                 AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                 AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                 AND pd_dso.child_doc_id = pp_pd.payment_id(+)
                 AND o.document_id = nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                 AND t.oper_id = o.oper_id
                 AND pc.p_cover_id = t.obj_uro_id
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.description <> 'Административные издержки'
                    -- Ограничения по отчетному периоду
                 AND (SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = epg.payment_id
                         AND acp1.payment_id = dso1.child_doc_id
                         AND dso1.cancel_date IS NULL
                         AND doc.get_doc_status_id(acp1.payment_id) != 41
                         AND acp1.payment_templ_id IN (4983, 6277, 2, 16123, 16125)) <= p_payment_date
                    
                    --Ограничения по учтенным объемам
                 AND NOT EXISTS (SELECT NULL
                        FROM ag_volume av
                       WHERE av.trans_id = t.trans_id
                         AND av.is_calc = 1)
              UNION ALL
              SELECT --ДС
               pad.ag_contract_header_id
              ,ph.policy_header_id
              ,ph.product_id
              ,pp.policy_id
              ,ph.start_date date_s
              ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) ins_period
              ,pp.payment_term_id pay_term
              ,ph.ref_ph_id last_st
              ,ph.ref_pp_id active_st
              ,ph.fund_id fund
              ,(SELECT MIN(ds1.start_date)
                  FROM p_policy   pp1
                      ,doc_status ds1
                 WHERE pp1.pol_header_id = ph.policy_header_id
                   AND pp1.policy_id = ds1.document_id
                   AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr)) conclude_date
              ,
               --ЭПГ
               epg.plan_date epg_date
              ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date) / 12) + 1 pay_period
              ,epg.payment_id epg
              ,epg.amount epg_amt
              ,decode(ph.fund_id, 122, epg.amount, epg.rev_amount) rev_amount
              ,(SELECT nvl(SUM(decode(dd_e.doc_doc_id
                                     ,NULL
                                     ,dso_e.set_off_child_amount
                                     ,dso2_e.set_off_child_amount))
                          ,0)
                  FROM doc_set_off dso_e
                      ,ac_payment  acp_e
                      ,doc_doc     dd_e
                      ,doc_set_off dso2_e
                 WHERE dso_e.parent_doc_id = epg.payment_id
                   AND acp_e.payment_id = dso_e.parent_doc_id
                   AND dso_e.cancel_date IS NULL
                   AND acp_e.payment_id = dd_e.parent_id(+)
                   AND dd_e.child_id = dso2_e.parent_doc_id(+)
                   AND dso2_e.cancel_date IS NULL) epg_payed
              ,doc.get_doc_status_id(epg.payment_id) epg_st
              ,epg_dso.set_off_child_amount epg_set_off
              ,epg_pd.payment_templ_id epg_pd_type
              ,
               --Платежный док
               decode(ph.fund_id, 122, epg_pd_copy.amount, epg_pd_copy.rev_amount) pd_copy_rev_amount
              ,pd_dso.set_off_amount pd_dso_set_off_amount
              ,doc.get_doc_status_id(epg_pd_copy.payment_id) pd_copy_stat
              ,nvl(pp_pd.payment_id, epg_pd.payment_id) pay_doc
              ,(SELECT MAX(acp1.due_date)
                  FROM doc_set_off dso1
                      ,ac_payment  acp1
                 WHERE dso1.parent_doc_id = epg.payment_id
                   AND acp1.payment_id = dso1.child_doc_id
                   AND acp1.payment_templ_id IN
                       (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p, g_apt_ukv)) payment_date
              ,nvl(pp_pd.collection_metod_id
                  ,nvl(epg_pd_copy.collection_metod_id, epg_pd.collection_metod_id)) pay_doc_cm
              ,CASE
                 WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) = g_cm_direct_pay
                      AND pp.payment_term_id = g_pt_monthly THEN
                  (SELECT nvl(MIN(CASE
                                    WHEN nvl(pay_1.collection_metod_id, epg_pd1.collection_metod_id) =
                                         g_cm_direct_pay THEN
                                     1
                                    ELSE
                                     2
                                  END)
                             ,2)
                     FROM p_policy       pp1
                         ,doc_doc        dd_policy
                         ,ven_ac_payment epg1
                         ,doc_set_off    epg_so
                         ,ac_payment     epg_pd1
                         ,doc_doc        dd_copy
                         ,doc_set_off    copy_so
                         ,ac_payment     pay_1
                    WHERE pp1.pol_header_id = ph.policy_header_id
                      AND dd_policy.parent_id = pp1.policy_id
                      AND dd_policy.child_id = epg1.payment_id
                      AND epg1.doc_templ_id = g_dt_epg_doc -- 4
                      AND epg1.plan_date < epg.plan_date
                      AND epg_so.parent_doc_id = epg1.payment_id
                      AND epg_so.child_doc_id = epg_pd1.payment_id
                      AND epg_pd1.payment_id = dd_copy.parent_id(+)
                      AND dd_copy.child_id = copy_so.parent_doc_id(+)
                      AND copy_so.child_doc_id = pay_1.payment_id(+))
                 ELSE
                  1
               END first_pay_coef
              ,
               --Проводки
               pc.fee
              ,tplo.id tplo_id
              ,t.trans_id
              ,t.trans_amount trans_sum
              ,0 ind_sum
              ,(SELECT 1
                  FROM dual
                 WHERE EXISTS
                 (SELECT NULL
                          FROM dual
                         WHERE ph.ref_ph_id IN (g_st_quit
                                               ,g_st_quit_to_pay
                                               ,g_st_quit_req_reg
                                               ,g_st_quit_query
                                               ,g_st_to_quit_ch
                                               ,g_st_to_quit
                                               ,g_st_ch_ready)
                           AND EXISTS
                         (SELECT NULL
                                  FROM doc_set_off dso1
                                      ,ac_payment  acp1
                                 WHERE dso1.parent_doc_id = epg.payment_id
                                   AND acp1.payment_id = dso1.child_doc_id
                                   AND doc.get_doc_status_id(acp1.payment_id) = g_st_annulated
                                   AND acp1.payment_templ_id IN (g_apt_a7
                                                                ,g_apt_pd4
                                                                ,g_apt_pp
                                                                ,g_apt_pp_dir_p
                                                                ,g_apt_pp_payer_p
                                                                ,g_apt_ukv)
                                   AND EXISTS (SELECT NULL
                                          FROM ins.ag_volume agvf
                                         WHERE agvf.epg_payment = dso1.parent_doc_id)))) is_trans_annul
                FROM (SELECT pha.policy_header_id
                            ,pha.fund_id
                            ,pha.start_date
                            ,pha.product_id
                            ,pha.policy_id
                            ,pha.sales_channel_id
                            ,d_ph.doc_status_ref_id ref_ph_id
                            ,d_pp.doc_status_ref_id ref_pp_id
                        FROM ins.p_pol_header pha
                            ,ins.document     d_ph
                            ,ins.document     d_pp
                       WHERE pha.policy_header_id IN
                             (SELECT p.pol_header_id FROM p_policy p WHERE p.pol_num = p_pol_num)
                         AND pha.last_ver_id = d_ph.document_id
                         AND pha.policy_id = d_pp.document_id
                         AND pha.sales_channel_id IN (8, 10, 81)
                         AND d_pp.doc_status_ref_id IN (g_st_concluded, g_st_curr, g_st_to_agent)) ph
                    ,(SELECT *
                        FROM ins.p_policy_agent_doc pada
                            ,ins.document           d_pad
                       WHERE pada.p_policy_agent_doc_id = d_pad.document_id
                         AND d_pad.doc_status_ref_id != g_st_error) pad
                    ,ins.ven_p_policy pp
                    ,ins.doc_doc pp_dd
                    ,(SELECT *
                        FROM ins.ac_payment epga
                            ,ins.document   d_epg
                       WHERE d_epg.doc_templ_id = g_dt_epg_doc
                         AND epga.payment_id = d_epg.document_id
                         AND d_epg.doc_status_ref_id != g_st_new
                         AND epga.plan_date <= p_payment_date) epg
                    ,ins.doc_set_off epg_dso
                    ,(SELECT *
                        FROM ins.ac_payment epg_pda
                       WHERE epg_pda.payment_templ_id IN (g_apt_ukv)) epg_pd
                    ,ins.doc_doc pd_dd
                    ,ins.ac_payment epg_pd_copy
                    ,ins.doc_set_off pd_dso
                    ,ins.oper o
                    ,(SELECT tra.oper_id
                            ,tra.obj_uro_id
                            ,tra.trans_amount
                            ,tra.trans_id
                            ,tra.reg_date
                        FROM ins.trans tra
                       WHERE tra.dt_account_id = 55) t
                    ,ins.p_cover pc
                    ,ins.t_prod_line_option tplo
                    ,(SELECT *
                        FROM ins.ven_ac_payment pp_pda
                       WHERE (pp_pda.payment_templ_id = g_apt_ukv OR pp_pda.payment_templ_id IS NULL)) pp_pd
               WHERE 1 = 1
                 AND ph.policy_header_id = pp.pol_header_id
                 AND ph.policy_header_id = pad.policy_header_id
                 AND CASE
                       WHEN epg_pd.due_date < ph.start_date THEN
                        ph.start_date
                       ELSE
                        (SELECT MAX(acp1.due_date)
                           FROM doc_set_off dso1
                               ,ac_payment  acp1
                          WHERE dso1.parent_doc_id = epg.payment_id
                            AND acp1.payment_id = dso1.child_doc_id
                            AND acp1.payment_templ_id IN (g_apt_a7
                                                         ,g_apt_pd4
                                                         ,g_apt_pp
                                                         ,g_apt_pp_dir_p
                                                         ,g_apt_pp_payer_p
                                                         ,g_apt_ukv))
                     END BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
                 AND pp.policy_id = pp_dd.parent_id
                 AND pp_dd.child_id = epg.payment_id
                 AND epg.payment_id = epg_dso.parent_doc_id
                 AND epg_dso.child_doc_id = epg_pd.payment_id
                 AND epg_pd.payment_id = pd_dd.parent_id(+)
                 AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                 AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                 AND pd_dso.child_doc_id = pp_pd.payment_id(+)
                 AND o.document_id = epg_dso.doc_set_off_id
                 AND t.oper_id = o.oper_id
                 AND pc.p_cover_id = t.obj_uro_id
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.description <> 'Административные издержки'
                    --Ограничения по учтенным объемам
                 AND NOT EXISTS
               (SELECT NULL
                        FROM ag_volume av
                       WHERE av.trans_id = t.trans_id
                         AND av.ag_roll_id NOT IN
                             (SELECT var.ag_roll_id
                                FROM ven_ag_roll_header   varh
                                    ,ins.ven_ag_roll_type vart
                                    ,ven_ag_roll          var
                               WHERE varh.ag_roll_type_id = vart.ag_roll_type_id
                                 AND vart.brief = 'VOL_NOMAJOR'
                                 AND varh.ag_roll_header_id = var.ag_roll_header_id))) vol;
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  FUNCTION get_correct_roll
  (
    p_arh_id  NUMBER
   ,p_roll_id NUMBER
  ) RETURN NUMBER IS
  
    p_ag_roll_id    NUMBER;
    p_insert_update NUMBER;
    proc_name       VARCHAR2(20) := 'GET_CORRECT_ROLL';
  
  BEGIN
  
    BEGIN
      SELECT to_number(arn.num)
            ,arn.ag_roll_id
        INTO p_insert_update
            ,p_ag_roll_id
        FROM ven_ag_roll_header arh
            ,ven_ag_roll        ar
            ,ven_ag_roll        arn
       WHERE arh.ag_roll_header_id = ar.ag_roll_header_id
         AND arh.ag_roll_header_id = p_arh_id
         AND ar.ag_roll_id = p_roll_id
         AND arh.ag_roll_header_id = arn.ag_roll_header_id
         AND (SELECT MIN(to_number(ar.num))
                FROM ven_ag_roll_header arh
                    ,ven_ag_roll        ar
                    ,ins.ag_volume      agv
               WHERE arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND arh.ag_roll_header_id = p_arh_id
                 AND ar.ag_roll_id = agv.ag_roll_id
                 AND arn.ag_roll_id = ar.ag_roll_id
                 AND NOT EXISTS (SELECT NULL
                        FROM ins.ven_ag_roll      arl
                            ,ins.ag_volume        agv
                            ,ins.ag_perf_work_vol vol
                       WHERE arl.ag_roll_id = ar.ag_roll_id
                         AND ar.ag_roll_id = agv.ag_roll_id
                         AND vol.ag_volume_id = agv.ag_volume_id)
                 AND EXISTS (SELECT NULL
                        FROM ag_volume av
                       WHERE av.ag_volume_id = agv.ag_volume_id
                         AND av.is_added IN (1, 2))) > to_number(ar.num);
    EXCEPTION
      WHEN no_data_found THEN
        p_insert_update := 0;
        p_ag_roll_id    := -2;
    END;
  
    RETURN p_ag_roll_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  PROCEDURE set_group_banks(par_work_act_id ag_perfomed_work_act.ag_perfomed_work_act_id%TYPE) IS
  BEGIN
    DELETE FROM t_group_oav_detail;
    INSERT INTO t_group_oav_detail
      (policy_num
      ,ids
      ,product
      ,detail_commis
      ,ag_contract_header_id
      ,ag_perfomed_work_act_id
      ,prem_type)
      SELECT CASE
               WHEN pp.pol_ser IS NOT NULL THEN
                pp.pol_ser || '-'
             END || pp.pol_num
            ,ph.ids
            ,pr.description
            ,vb.sav * vb.trans_amount
            ,wa.ag_contract_header_id
            ,par_work_act_id
            ,(SELECT rt.name
               FROM ag_perfom_work_det wd
                   ,ag_rate_type       rt
              WHERE wd.ag_perfomed_work_act_id = par_work_act_id
                AND wd.ag_rate_type_id = rt.ag_rate_type_id)
        FROM ag_perfomed_work_act wa
            ,ag_volume_bank       vb
            ,p_pol_header         ph
            ,p_policy             pp
            ,t_product            pr
       WHERE wa.ag_perfomed_work_act_id = par_work_act_id
         AND wa.ag_contract_header_id = vb.ag_contract_header_id
         AND wa.ag_roll_id = vb.ag_roll_id
         AND vb.policy_header_id = ph.policy_header_id
         AND ph.product_id = pr.product_id
         AND ph.policy_id = pp.policy_id;
  END set_group_banks;

  FUNCTION set_group_oav
  (
    p_arh_id                  NUMBER
   ,p_roll_id                 NUMBER
   ,p_ag_perfomed_work_act_id NUMBER
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'SET_GROUP_OAV';
  BEGIN
    DELETE FROM t_group_oav_detail;
    INSERT INTO t_group_oav_detail
      SELECT arh.ag_roll_header_id
            ,ar.ag_roll_id
            ,apw.ag_perfomed_work_act_id
            ,art.name prem_type
            ,dep.name agency
            ,ts.description sales_ch
            ,ach.ag_contract_header_id
            ,ach.num ad
            ,ach.date_begin
            ,aca.category_name
            ,cn.obj_name_orig agent_fio
            ,tct.description leg_entity
            ,avt.description volume_type
            ,apw.ag_level
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(6) inv_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(8) ops2_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,apw.sgp1 act_volume_amt
            ,apw.sum act_commission
            ,ph.ids ids
            ,pp.pol_num policy_num
            ,tp.description product
            ,cn_ins.obj_name_orig insuer
            ,per.gender
            ,per.date_of_birth
            ,agv.date_begin policy_begin
            ,agv.ins_period insurance_term
            ,ins.ent.obj_name('DOC_STATUS_REF', agv.last_status) last_status
            ,ins.ent.obj_name('DOC_STATUS_REF', agv.active_status) active_status
            ,pt.description payment_term
            ,f.name fund
            ,epg.num epg_num
            ,agv.epg_date
            ,agv.pay_period pay_year
            ,agv.epg_ammount
            ,ins.ent.obj_name('DOC_STATUS_REF', agv.epg_status) epg_status
            ,ins.ent.obj_name('DOC_STATUS_REF', agv.pd_copy_status) pd_copy_status
            ,acpt.title pd_type
            ,pd.num pd_num
            ,cm.description collect_method
            ,agv.payment_date
            ,t.reg_date reg_date
            ,tplo.description cover
            ,agv.trans_sum
            ,agv.index_delta_sum
            ,agv.nbv_coef
            ,apv.vol_amount detail_vol_amt
            ,apv.vol_rate detail_vol_rate
            ,apv.vol_amount * apv.vol_rate detail_commis
            ,apw.volumes.get_volume(121) ops9_vol
            ,apw.volumes.get_volume(101) fdep_vol
        FROM ins.ven_ag_roll_header     arh
            ,ins.ven_ag_roll            ar
            ,ins.ag_perfomed_work_act   apw
            ,ins.ag_perfom_work_det     apd
            ,ins.ag_rate_type           art
            ,ins.ag_perf_work_vol       apv
            ,ins.ag_volume              agv
            ,ins.ag_volume_type         avt
            ,ins.ven_ag_contract_header ach
            ,ins.t_sales_channel        ts
            ,ins.ag_contract            ac
            ,ins.ag_category_agent      aca
            ,ins.department             dep
            ,ins.t_contact_type         tct
            ,ins.contact                cn
            ,ins.contact                cn_ins
            ,ins.cn_person              per
            ,ins.p_pol_header           ph
            ,ins.p_policy               pp
            ,ins.t_product              tp
            ,ins.t_payment_terms        pt
            ,ins.fund                   f
            ,ins.ac_payment_templ       acpt
            ,ins.document               epg
            ,ins.document               pd
            ,ins.trans                  t
            ,ins.t_collection_method    cm
            ,ins.t_prod_line_option     tplo
       WHERE 1 = 1
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = p_roll_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND art.ag_rate_type_id = apd.ag_rate_type_id
         AND apv.ag_volume_id = agv.ag_volume_id
         AND tct.id = ac.leg_pos
         AND ac.contract_id = ach.ag_contract_header_id
         AND ts.id(+) = ach.t_sales_channel_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.category_id = aca.ag_category_agent_id
         AND agv.ag_volume_type_id = avt.ag_volume_type_id
         AND avt.brief IN ('RL', 'INV', 'FDep')
         AND apw.ag_contract_header_id = ach.ag_contract_header_id
         AND dep.department_id = ach.agency_id
         AND ach.agent_id = cn.contact_id
         AND agv.policy_header_id = ph.policy_header_id
         AND ph.policy_id = pp.policy_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_ins.contact_id
         AND cn_ins.contact_id = per.contact_id(+)
         AND agv.payment_term_id = pt.id
         AND epg.document_id = agv.epg_payment
         AND f.fund_id = agv.fund
         AND agv.pd_payment = pd.document_id
         AND acpt.payment_templ_id = agv.epg_pd_type
         AND cm.id = agv.pd_collection_method
         AND tplo.id = agv.t_prod_line_option_id
         AND agv.trans_id = t.trans_id(+)
         AND tp.product_id = ph.product_id
         AND apw.ag_perfomed_work_act_id = p_ag_perfomed_work_act_id
      UNION ALL
      SELECT arh.ag_roll_header_id
            ,ar.ag_roll_id vedom
            ,apw.ag_perfomed_work_act_id
            ,art.name prem_type
            ,dep.name agency
            ,ts.description sales_ch
            ,ach.ag_contract_header_id
            ,ach.num ad
            ,ach.date_begin
            ,aca.category_name
            ,cn.obj_name_orig agent_fio
            ,tct.description leg_entity
            ,avt.description volume_type
            ,apw.ag_level
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(6) inv_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(8) ops2_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,apw.sgp1 act_volume_amt
            ,apw.sum act_commission
            ,NULL
            ,anv.snils
            ,NULL --tp.DESCRIPTION product,
            ,anv.fio --cn_ins.obj_name_orig Insuer,
            ,anv.gender
            ,anv.assured_birf_date
            ,anv.sign_date --agv.date_begin policy_begin,
            ,NULL --agv.ins_period insurance_term,
            ,NULL --ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
            ,NULL --ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
            ,NULL --pt.DESCRIPTION payment_term,
            ,NULL --f.NAME fund,
            ,NULL --epg.num epg_num,
            ,NULL --agv.epg_date,
            ,NULL --agv.pay_period pay_year,
            ,NULL --agv.epg_ammount,
            ,NULL --ent.obj_name('DOC_STATUS_REF',agv.epg_status) epg_status,
            ,NULL --ent.obj_name('DOC_STATUS_REF',agv.pd_copy_status) pd_copy_status,
            ,NULL --acpt.title pd_type,
            ,NULL --pd.num pd_num,
            ,NULL --cm.DESCRIPTION collect_method,
            ,NULL --agv.payment_date,
            ,NULL --t.reg_date reg_date,
            ,NULL --tplo.DESCRIPTION cover,
            ,agv.trans_sum
            ,NULL --agv.index_delta_sum,
            ,agv.nbv_coef
            ,apv.vol_amount detail_vol_amt
            ,apv.vol_rate detail_vol_rate
            ,apv.vol_rate * apv.vol_amount
            ,apw.volumes.get_volume(121) ops9_vol
            ,apw.volumes.get_volume(101) fdep_vol
        FROM ins.ven_ag_roll_header     arh
            ,ins.ven_ag_roll            ar
            ,ins.ag_perfomed_work_act   apw
            ,ins.ag_perfom_work_det     apd
            ,ins.ag_rate_type           art
            ,ins.ag_perf_work_vol       apv
            ,ins.ag_volume              agv
            ,ins.ag_volume_type         avt
            ,ins.ag_npf_volume_det      anv
            ,ins.ven_ag_contract_header ach
            ,ins.t_sales_channel        ts
            ,ins.ag_contract            ac
            ,ins.ag_category_agent      aca
            ,ins.department             dep
            ,ins.contact                cn
            ,ins.t_contact_type         tct
       WHERE 1 = 1
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = p_roll_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND art.ag_rate_type_id = apd.ag_rate_type_id
         AND apv.ag_volume_id = agv.ag_volume_id
         AND agv.ag_volume_id(+) = anv.ag_volume_id
         AND agv.ag_volume_type_id = avt.ag_volume_type_id
         AND avt.brief IN ('NPF', 'NPF02', 'AVCP', 'SOFI', 'NPF(MARK9)')
         AND apw.ag_contract_header_id = ach.ag_contract_header_id
         AND ac.contract_id = ach.ag_contract_header_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.category_id = aca.ag_category_agent_id
         AND dep.department_id = ach.agency_id
         AND ach.agent_id = cn.contact_id
         AND tct.id = ac.leg_pos
         AND ach.t_sales_channel_id = ts.id(+)
         AND apw.ag_perfomed_work_act_id = p_ag_perfomed_work_act_id;
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  PROCEDURE fill_banks_acts(par_ag_roll_id ag_roll.ag_roll_id%TYPE) IS
  BEGIN
    DELETE FROM t_ungroup_prem;
    INSERT INTO t_ungroup_prem
      (ag_roll_header_id
      ,ag_roll_id
      ,ag_perfomed_work_act_id
      ,ag_contract_header_id
      ,agency
      ,agent_fio
      ,agent_num
      ,date_begin_ad
      ,rl_vol
      ,sales_chnl
      ,commission
      ,act_date
      ,accrual_1c_date)
      SELECT ar.ag_roll_header_id
            ,ar.ag_roll_id
            ,wa.ag_perfomed_work_act_id
            ,wa.ag_contract_header_id
            ,dp.name AS agency
            ,co.obj_name_orig AS agent_fio
            ,dc_ch.num AS agent_num
            ,ch.date_begin AS date_begin_ad
            ,wa.all_volume
            ,(SELECT sc.brief FROM ins.t_sales_channel sc WHERE sc.id = ch.t_sales_channel_id)
            ,wa.sum
            ,wa.act_date
            ,wa.accrual_1c_date
        FROM ag_perfomed_work_act wa
            ,ag_roll              ar
            ,ag_roll_header       arh
            ,ag_contract_header   ch
            ,ag_contract          ac
            ,contact              co
            ,department           dp
            ,document             dc_ch
       WHERE ar.ag_roll_id = par_ag_roll_id
         AND ar.ag_roll_id = wa.ag_roll_id
         AND ar.ag_roll_header_id = arh.ag_roll_header_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND wa.ag_contract_header_id = ch.ag_contract_header_id
         AND ch.ag_contract_header_id = ac.contract_id
         AND ch.agent_id = co.contact_id
         AND ac.agency_id = dp.department_id
         AND ch.ag_contract_header_id = dc_ch.document_id;
  
  END fill_banks_acts;

  FUNCTION set_ungroup_prem
  (
    p_arh_id  NUMBER
   ,p_roll_id NUMBER
  ) RETURN NUMBER IS
    proc_name VARCHAR2(25) := 'SET_UNGROUP_PREM';
  BEGIN
    DELETE FROM t_ungroup_prem;
    INSERT INTO t_ungroup_prem
      (ag_roll_header_id
      ,ag_roll_id
      ,ag_perfomed_work_act_id
      ,ag_contract_header_id
      ,agency
      ,agent_fio
      ,agent_num
      ,date_begin_ad
      ,total_volume
      ,sales_chnl)
      SELECT arh.ag_roll_header_id
            ,ar.ag_roll_id
            ,apw.ag_perfomed_work_act_id
            ,ach.ag_contract_header_id
            ,(SELECT dep.name
                FROM ins.department  dep
                    ,ins.ag_contract ac
               WHERE ach.ag_contract_header_id = ac.contract_id
                 AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = dep.department_id) agency
            ,cn_a.obj_name_orig ag_fio
            ,(SELECT d.num FROM document d WHERE d.document_id = ach.ag_contract_header_id) num
            ,ach.date_begin date_degin_ad
            ,apw.all_volume
            ,(SELECT ch.brief FROM ins.t_sales_channel ch WHERE ch.id = ach.t_sales_channel_id)
        FROM ins.ag_roll_header       arh
            ,ins.ag_roll              ar
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_contract_header   ach
            ,ins.contact              cn_a
       WHERE 1 = 1
         AND arh.ag_roll_header_id = p_arh_id
         AND ar.ag_roll_id = p_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND EXISTS (SELECT NULL
                FROM ins.ag_perfom_work_det det
                    ,ins.ag_perf_work_vol   apv
                    ,ins.ag_volume          agv
               WHERE det.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apv.ag_perfom_work_det_id = det.ag_perfom_work_det_id
                 AND agv.ag_volume_id = apv.ag_volume_id)
         AND cn_a.contact_id = ach.agent_id;
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  FUNCTION set_group_prem
  (
    p_arh_id                  NUMBER
   ,p_roll_id                 NUMBER
   ,p_ag_perfomed_work_act_id NUMBER
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'SET_GROUP_PREM';
  BEGIN
    DELETE FROM t_group_prem_detail;
    INSERT INTO t_group_prem_detail
      SELECT arh.ag_roll_header_id
            ,ar.ag_roll_id
            ,apw.ag_perfomed_work_act_id
            ,apv.ag_perfom_work_det_id
            ,av.ag_volume_id
            ,ach.ag_contract_header_id
            ,dep.name agency
            ,cn_a.obj_name_orig ag_fio
            ,ach.num
            ,ach.date_begin date_degin_ad
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(6) inv_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(8) ops2_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'WG_0510') work_group
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'RE_POL_0510') renewal_ploicy
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'SS_0510') self_sale
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'LVL_0510') level_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_0510') ksp_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'ES_0510') evol_sub
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PENROL_0510') enrol_sub
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PG_0510') personal_group
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QOPS_0510') qualitative_ops
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QMOPS_0510') q_male_ops
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PEXEC_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Active_agent_0510') active_agents
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Exec_plan_GRS') exec_plan_grs
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Policy_commiss_GRS') policy_commiss_grs
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'OAV_GRS') self_sale_grs
            ,(SELECT asp.plan_value
                FROM ins.ag_sale_plan asp
               WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
                 AND asp.plan_type = 1
                 AND arh.date_end BETWEEN asp.date_begin AND asp.date_end
                 AND rownum = 1) plan_value
            ,art.name prem_detail_name
            ,avt.description vol_type
            ,tp.description product
            ,ph.ids
            ,pp.pol_num
            ,tplo.description risk
            ,av.pay_period
            ,av.ins_period
            ,av.nbv_coef
            ,av.trans_sum
            ,av.index_delta_sum
            ,apv.vol_amount detail_amt
            ,apv.vol_rate detail_rate
            ,apv.vol_amount * apv.vol_rate detail_commis
            ,apw.volumes.get_volume(121) ops9_vol
            ,apw.volumes.get_volume(101) fdep_vol
        FROM ins.ven_ag_roll_header     arh
            ,ins.ven_ag_roll            ar
            ,ins.ag_perfomed_work_act   apw
            ,ins.ag_perfom_work_det     apd
            ,ins.ag_rate_type           art
            ,ins.ag_perf_work_vol       apv
            ,ins.ag_volume              av
            ,ins.ag_volume_type         avt
            ,ins.ven_ag_contract_header ach
            ,ins.ven_ag_contract_header ach_s
            ,ins.ven_ag_contract_header leader_ach
            ,ins.ven_ag_contract        leader_ac
            ,ins.contact                cn_leader
            ,ins.contact                cn_as
            ,ins.contact                cn_a
            ,ins.department             dep
            ,ins.t_sales_channel        ts
            ,ins.ag_contract            ac
            ,ins.ag_category_agent      aca
            ,ins.t_contact_type         tct
            ,ins.p_pol_header           ph
            ,ins.t_product              tp
            ,ins.t_prod_line_option     tplo
            ,ins.t_payment_terms        pt
            ,ins.p_policy               pp
            ,ins.contact                cn_i
       WHERE 1 = 1
         AND arh.ag_roll_header_id = p_arh_id
         AND ar.ag_roll_id = p_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND art.brief IN ('WG_0510', 'SS_0510', 'RE_POL_0510', 'PG_0510')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.policy_header_id = ph.policy_header_id
         AND av.ag_volume_type_id = avt.ag_volume_type_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND ph.policy_id = pp.policy_id
         AND ph.product_id = tp.product_id
         AND tplo.id = av.t_prod_line_option_id
         AND ins.pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь') = cn_i.contact_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ach.t_sales_channel_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND pt.id = av.payment_term_id
         AND apw.ag_perfomed_work_act_id = p_ag_perfomed_work_act_id
      
      UNION ALL
      
      SELECT arh.ag_roll_header_id
            ,ar.ag_roll_id
            ,apw.ag_perfomed_work_act_id
            ,apv.ag_perfom_work_det_id
            ,av.ag_volume_id
            ,ach.ag_contract_header_id
            ,dep.name agency
            ,cn_a.obj_name_orig ag_fio
            ,ach.num
            ,ach.date_begin date_degin_ad
            ,apw.volumes.get_volume(1) rl_vol
            ,apw.volumes.get_volume(6) inv_vol
            ,apw.volumes.get_volume(2) ops_vol
            ,apw.volumes.get_volume(8) ops2_vol
            ,apw.volumes.get_volume(3) sofi_vol
            ,apw.volumes.get_volume(5) sofi_pay_vol
            ,apw.ag_ksp ksp
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id --
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'WG_0510') work_group
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'RE_POL_0510') renewal_ploicy
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'SS_0510') self_sale
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'LVL_0510') level_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'KSP_0510') ksp_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'ES_0510') evol_sub
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PENROL_0510') enrol_sub
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PG_0510') personal_group
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QOPS_0510') qualitative_ops
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'QMOPS_0510') q_male_ops
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'PEXEC_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Active_agent_0510') plan_reach
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Exec_plan_GRS') exec_plan_grs
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'Policy_commiss_GRS') policy_commiss_grs
            ,(SELECT apd1.summ
                FROM ins.ag_perfom_work_det apd1
                    ,ins.ag_rate_type       art1
               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                 AND art1.brief = 'OAV_GRS') self_sale_grs
            ,(SELECT asp.plan_value
                FROM ins.ag_sale_plan asp
               WHERE asp.ag_contract_header_id = ach.ag_contract_header_id
                 AND asp.plan_type = 1
                 AND arh.date_end BETWEEN asp.date_begin AND asp.date_end
                 AND rownum = 1) plan_value
            ,art.name prem
            ,avt.description vol_type
            ,'ОПС' product
            ,NULL ids
            ,anv.snils
            ,'' risk
            ,NULL
            ,NULL
            ,av.nbv_coef
            ,av.trans_sum
            ,av.index_delta_sum
            ,apv.vol_amount detail_amt
            ,apv.vol_rate detail_rate
            ,apv.vol_amount * apv.vol_rate detail_commis
            ,apw.volumes.get_volume(121) ops9_vol
            ,apw.volumes.get_volume(101) fdep_vol
        FROM ins.ven_ag_roll_header     arh
            ,ins.ven_ag_roll            ar
            ,ins.ag_perfomed_work_act   apw
            ,ins.ag_perfom_work_det     apd
            ,ins.ag_rate_type           art
            ,ins.ag_perf_work_vol       apv
            ,ins.ven_ag_contract_header ach_s
            ,ins.contact                cn_as
            ,ins.ag_npf_volume_det      anv
            ,ins.ag_volume              av
            ,ins.ag_volume_type         avt
            ,ins.ven_ag_contract_header ach
            ,ins.ven_ag_contract_header leader_ach
            ,ins.ven_ag_contract        leader_ac
            ,ins.contact                cn_leader
            ,ins.contact                cn_a
            ,ins.department             dep
            ,ins.t_sales_channel        ts
            ,ins.ag_contract            ac
            ,ins.ag_category_agent      aca
            ,ins.t_contact_type         tct
       WHERE 1 = 1
         AND arh.ag_roll_header_id = p_arh_id
         AND ar.ag_roll_id = p_roll_id
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = art.ag_rate_type_id
         AND ac.contract_f_lead_id = leader_ac.ag_contract_id(+)
         AND leader_ac.contract_id = leader_ach.ag_contract_header_id(+)
         AND leader_ach.agent_id = cn_leader.contact_id(+)
         AND art.brief IN ('WG_0510'
                          ,'SS_0510'
                          ,'QMOPS_0510'
                          ,'QOPS_0510'
                          ,'PG_0510'
                          ,'Policy_commiss_GRS'
                          ,'OAV_GRS'
                          ,'FAKE_Sofi_prem_0510')
         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
         AND apv.ag_volume_id = av.ag_volume_id
         AND av.ag_contract_header_id = ach_s.ag_contract_header_id
         AND ach_s.agent_id = cn_as.contact_id
         AND av.ag_volume_id = anv.ag_volume_id
         AND avt.ag_volume_type_id = av.ag_volume_type_id
         AND ach.ag_contract_header_id = apw.ag_contract_header_id
         AND ach.ag_contract_header_id = ac.contract_id
         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
         AND ac.agency_id = dep.department_id
         AND ach.t_sales_channel_id = ts.id
         AND ac.category_id = aca.ag_category_agent_id
         AND cn_a.contact_id = ach.agent_id
         AND tct.id = ac.leg_pos
         AND apw.ag_perfomed_work_act_id = p_ag_perfomed_work_act_id;
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
    WHEN OTHERS THEN
      raise_application_error(-20003
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END;

  PROCEDURE load_detail_commission
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
   ,par_roll_id      NUMBER
  ) IS
    va_values   pkg_load_file_to_table.t_varay;
    v_blob_data BLOB;
    v_blob_len  NUMBER;
    v_position  NUMBER;
    c_chunk_len NUMBER := 1;
    v_line      VARCHAR2(32767) := NULL;
    v_line_num  NUMBER := 0;
    v_char      CHAR(1);
    v_raw_chunk RAW(10000);
    v_load      t_load_detail_commission%ROWTYPE;
  BEGIN
  
    DELETE FROM ins.t_load_detail_commission;
  
    SELECT file_blob INTO v_blob_data FROM temp_load_blob WHERE session_id = par_id;
    v_blob_len := dbms_lob.getlength(v_blob_data);
    v_position := 1;
    WHILE (v_position <= v_blob_len)
    LOOP
      v_raw_chunk := dbms_lob.substr(v_blob_data, c_chunk_len, v_position);
      v_char      := chr(pkg_load_file_to_table.hex2dec(rawtohex(v_raw_chunk)));
      v_line      := v_line || v_char;
      v_position  := v_position + c_chunk_len;
      IF v_char = chr(10)
      THEN
        v_line     := REPLACE(REPLACE(v_line, chr(10)), chr(13));
        v_line_num := v_line_num + 1;
        IF v_line_num > 1
        THEN
          -- строку заголовков столбцов не грузим
          va_values := pkg_load_file_to_table.str2array(v_line); -- разбиение 
          -- строки на поля
          IF v_line IS NOT NULL
          THEN
            v_load := NULL;
            SELECT sq_t_detail_commission.nextval INTO v_load.t_load_detail_commission_id FROM dual;
            v_load.load_id := par_load_file_id;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  v_load.sales_ch := va_values(i);
                WHEN i = 2 THEN
                  v_load.agency_id := va_values(i);
                WHEN i = 3 THEN
                  v_load.category_name := va_values(i);
                WHEN i = 4 THEN
                  v_load.ag_num_id := va_values(i);
                WHEN i = 5 THEN
                  v_load.ag_level := va_values(i);
                WHEN i = 6 THEN
                  v_load.rl_vol := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 7 THEN
                  v_load.inv_vol := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 8 THEN
                  v_load.ops_vol := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 9 THEN
                  v_load.ops2_vol := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 10 THEN
                  v_load.sofi_vol := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 11 THEN
                  v_load.ksp := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 12 THEN
                  v_load.prem_detail_name := va_values(i);
                WHEN i = 13 THEN
                  v_load.vol_type := va_values(i);
                WHEN i = 14 THEN
                  v_load.agent_ad_id := va_values(i);
                WHEN i = 15 THEN
                  v_load.product := va_values(i);
                WHEN i = 16 THEN
                  v_load.pol_header_id := va_values(i);
                WHEN i = 17 THEN
                  v_load.pol_num_ops := va_values(i);
                WHEN i = 18 THEN
                  v_load.sign_date_ops := to_date(va_values(i), 'DD.MM.YYYY');
                WHEN i = 19 THEN
                  v_load.epg_id := va_values(i);
                WHEN i = 20 THEN
                  v_load.payment_id := va_values(i);
                WHEN i = 21 THEN
                  v_load.p_cover_id := va_values(i);
                WHEN i = 22 THEN
                  v_load.pay_period := va_values(i);
                WHEN i = 23 THEN
                  v_load.ins_period := va_values(i);
                WHEN i = 24 THEN
                  v_load.nbv_coef := va_values(i);
                WHEN i = 25 THEN
                  v_load.trans_sum := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 26 THEN
                  v_load.index_delta_sum := to_number(translate(va_values(i), ',.', '..')
                                                     ,'9999999999.99');
                WHEN i = 27 THEN
                  v_load.detail_amt := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 28 THEN
                  v_load.detail_rate := to_number(translate(va_values(i), ',.', '..'), '9999999999.99');
                WHEN i = 29 THEN
                  v_load.detail_commis := to_number(translate(va_values(i), ',.', '..')
                                                   ,'9999999999.99');
                ELSE
                  NULL;
              END CASE;
            END LOOP;
            INSERT INTO ins.t_load_detail_commission
              (t_load_detail_commission_id
              ,load_id
              ,sales_ch
              ,agency_id
              ,category_name
              ,ag_num_id
              ,ag_level
              ,rl_vol
              ,inv_vol
              ,ops_vol
              ,ops2_vol
              ,sofi_vol
              ,ksp
              ,prem_detail_name
              ,vol_type
              ,agent_ad_id
              ,product
              ,pol_header_id
              ,pol_num_ops
              ,sign_date_ops
              ,epg_id
              ,payment_id
              ,p_cover_id
              ,pay_period
              ,ins_period
              ,nbv_coef
              ,trans_sum
              ,index_delta_sum
              ,detail_amt
              ,detail_rate
              ,detail_commis)
            VALUES
              (v_load.t_load_detail_commission_id
              ,v_load.load_id
              ,v_load.sales_ch
              ,v_load.agency_id
              ,v_load.category_name
              ,v_load.ag_num_id
              ,v_load.ag_level
              ,v_load.rl_vol
              ,v_load.inv_vol
              ,v_load.ops_vol
              ,v_load.ops2_vol
              ,v_load.sofi_vol
              ,v_load.ksp
              ,v_load.prem_detail_name
              ,v_load.vol_type
              ,v_load.agent_ad_id
              ,v_load.product
              ,v_load.pol_header_id
              ,v_load.pol_num_ops
              ,v_load.sign_date_ops
              ,v_load.epg_id
              ,v_load.payment_id
              ,v_load.p_cover_id
              ,v_load.pay_period
              ,v_load.ins_period
              ,v_load.nbv_coef
              ,v_load.trans_sum
              ,v_load.index_delta_sum
              ,v_load.detail_amt
              ,v_load.detail_rate
              ,v_load.detail_commis);
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
  
    pkg_commission_calc.save_to_ag_roll(par_roll_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении LOAD_DETAIL_COMMISSION ' || SQLERRM);
  END load_detail_commission;
  /*Процедура заливки в БД данных деталей КВ
    Веселуха Е.В.
    12.02.2013
  */
  PROCEDURE save_to_detail_commiss(par_load_file_id NUMBER) IS
  BEGIN
    INSERT INTO ins.t_load_detail_commission
      (t_load_detail_commission_id
      ,load_id
      ,sales_ch
      ,agency_id
      ,category_name
      ,ag_num_id
      ,ag_level
      ,rl_vol
      ,inv_vol
      ,ops_vol
      ,ops2_vol
      ,sofi_vol
      ,ksp
      ,prem_detail_name
      ,vol_type
      ,agent_ad_id
      ,product
      ,pol_header_id
      ,pol_num_ops
      ,sign_date_ops
      ,epg_id
      ,payment_id
      ,p_cover_id
      ,pay_period
      ,ins_period
      ,nbv_coef
      ,trans_sum
      ,index_delta_sum
      ,detail_amt
      ,detail_rate
      ,detail_commis)
      SELECT lf.load_file_rows_id
            ,lf.val_32
            ,lf.val_1
            ,lf.val_2
            ,lf.val_3
            ,lf.val_4
            ,lf.val_5
            ,lf.val_6
            ,lf.val_7
            ,lf.val_8
            ,lf.val_9
            ,lf.val_10
            ,lf.val_11
            ,lf.val_12
            ,lf.val_13
            ,lf.val_14
            ,lf.val_15
            ,lf.val_16
            ,lf.val_17
            ,lf.val_18
            ,lf.val_19
            ,lf.val_20
            ,lf.val_21
            ,lf.val_22
            ,lf.val_23
            ,lf.val_24
            ,lf.val_25
            ,lf.val_26
            ,lf.val_27
            ,lf.val_28
            ,lf.val_29
        FROM ins.load_file_rows lf
       WHERE lf.load_file_id = par_load_file_id
         AND lf.row_status = ins.pkg_load_file_to_table.get_checked;
    ins.pkg_commission_calc.save_to_ag_roll;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении SAVE_TO_DETAIL_COMMISS ' || SQLERRM);
  END save_to_detail_commiss;
  /**/
  PROCEDURE save_to_ag_roll(p_roll_id NUMBER DEFAULT NULL) IS
    v_all_vol      t_volume_val_o := t_volume_val_o(NULL);
    v_act_id       NUMBER;
    v_det_id       NUMBER;
    v_vol_id       NUMBER;
    v_npf_id       NUMBER;
    v_ag_volume_id NUMBER;
    v_old_ad_id    NUMBER := 0;
    v_cur_id       NUMBER;
  BEGIN
  
    FOR cur IN (SELECT ld.*
                      ,SUM(ld.detail_commis) over(PARTITION BY ld.prem_detail_name, ld.ag_num_id) summ_commiss
                  FROM ins.t_load_detail_commission ld
                 WHERE NOT EXISTS (SELECT NULL
                          FROM ins.ag_volume agv
                         WHERE agv.epg_payment = ld.epg_id
                           AND agv.trans_sum = ld.trans_sum)
                   AND NOT EXISTS (SELECT NULL
                          FROM ag_npf_volume_det anv
                         WHERE anv.snils = ld.pol_num_ops
                           AND anv.npf_det_type = 'OPS'))
    LOOP
      v_cur_id := cur.t_load_detail_commission_id;
      /***********добавляем, если грузим ОПС**********************/
      CASE
        WHEN cur.vol_type IN ('NPF', 'NPF02', 'AVCP', 'SOFI', 'NPF(MARK9)') THEN
          SELECT sq_ag_volume.nextval INTO v_ag_volume_id FROM dual;
          INSERT INTO ins.ag_volume
            (ag_volume_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,date_begin
            ,ag_roll_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,is_added
            ,is_calc)
          VALUES
            (v_ag_volume_id
            ,(SELECT tp.ag_volume_type_id
               FROM ins.ag_volume_type tp
              WHERE upper(tp.brief) = cur.vol_type)
            ,cur.ag_num_id
            ,cur.sign_date_ops
            ,cur.load_id
            ,cur.trans_sum
            ,cur.nbv_coef
            ,decode(cur.trans_sum, 500, 1, 0)
            ,0
            ,1);
          /*********ag_perfom_work_det************/
          SELECT sq_ag_npf_volume_det.nextval INTO v_npf_id FROM dual;
          INSERT INTO ven_ag_npf_volume_det
            (ag_npf_volume_det_id
            ,ag_contract_num
            ,sign_date
            ,ag_volume_id
            ,snils
            ,npf_det_type
            ,kv_flag)
          VALUES
            (v_npf_id
            ,(SELECT agh.num
               FROM ven_ag_contract_header agh
              WHERE agh.ag_contract_header_id = cur.ag_num_id)
            ,cur.sign_date_ops
            ,v_ag_volume_id
            ,cur.pol_num_ops
            ,decode(cur.vol_type, 'NPF', 'OPS', 'NPF02', 'OPS', 'NPF(MARK9)', 'OPS', cur.vol_type)
            ,1);
          /*************************************/
        ELSE
          /**************добавляем, если грузим Жизнь********************/
          /*******ag_volume************/
          SELECT sq_ag_volume.nextval INTO v_ag_volume_id FROM dual;
          INSERT INTO ins.ag_volume
            (ag_volume_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,policy_header_id
            ,date_begin
            ,ins_period
            ,payment_term_id
            ,
             --last_status,
             active_status
            ,fund
            ,epg_payment
            ,epg_date
            ,pay_period
            ,epg_status
            ,epg_ammount
            ,epg_pd_type
            ,pd_payment
            ,pd_collection_method
            ,payment_date
            ,t_prod_line_option_id
            ,ag_roll_id
            ,trans_sum
            ,index_delta_sum
            ,nbv_coef
            ,is_nbv
            ,is_added
            ,is_calc)
          VALUES
            (v_ag_volume_id
            ,(SELECT tp.ag_volume_type_id
               FROM ins.ag_volume_type tp
              WHERE upper(tp.brief) = cur.vol_type)
            ,cur.ag_num_id
            ,cur.pol_header_id
            ,(SELECT ph.start_date FROM p_pol_header ph WHERE ph.policy_header_id = cur.pol_header_id)
            ,cur.ins_period
            ,(SELECT pp.payment_term_id
               FROM p_pol_header ph
                   ,p_policy     pp
              WHERE ph.policy_id = pp.policy_id
                AND ph.policy_header_id = cur.pol_header_id)
            ,(SELECT d.doc_status_ref_id
               FROM p_pol_header ph
                   ,p_policy     pp
                   ,document     d
              WHERE ph.policy_id = pp.policy_id
                AND ph.policy_header_id = cur.pol_header_id
                AND pp.policy_id = d.document_id)
            ,(SELECT ph.fund_id FROM p_pol_header ph WHERE ph.policy_header_id = cur.pol_header_id)
            ,cur.epg_id
            ,(SELECT ac.plan_date FROM ac_payment ac WHERE ac.payment_id = cur.epg_id)
            ,cur.pay_period
            ,(SELECT de.doc_status_ref_id
               FROM ac_payment ac
                   ,document   de
              WHERE ac.payment_id = cur.epg_id
                AND ac.payment_id = de.document_id)
            ,(SELECT ac.amount FROM ac_payment ac WHERE ac.payment_id = cur.epg_id)
            ,(SELECT acs.payment_templ_id FROM ac_payment acs WHERE acs.payment_id = cur.payment_id)
            ,cur.payment_id
            ,(SELECT ac.collection_metod_id FROM ac_payment ac WHERE ac.payment_id = cur.payment_id)
            ,(SELECT ac.due_date FROM ac_payment ac WHERE ac.payment_id = cur.payment_id)
            ,(SELECT opt.id
               FROM p_cover            pc
                   ,t_prod_line_option opt
              WHERE pc.p_cover_id = cur.p_cover_id
                AND pc.t_prod_line_option_id = opt.id)
            ,cur.load_id
            ,cur.trans_sum
            ,cur.index_delta_sum
            ,cur.nbv_coef
            ,CASE WHEN cur.nbv_coef = 0 THEN 0 ELSE 1 END
            ,0
            ,1);
      END CASE;
    
      /*****************************************/
      IF v_old_ad_id <> cur.ag_num_id
      THEN
        /*********ag_perfomed_work_act************/
        SELECT sq_ag_perfomed_work_act.nextval INTO v_act_id FROM dual;
      
        v_all_vol := get_vol(cur.ag_num_id
                            ,cur.load_id
                            ,cur.rl_vol
                            ,cur.inv_vol
                            ,cur.ops_vol
                            ,cur.ops2_vol
                            ,cur.sofi_vol);
      
        INSERT INTO ven_ag_perfomed_work_act
          (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, ag_ksp, ag_level, volumes)
        VALUES
          (v_act_id, cur.load_id, cur.ag_num_id, cur.ksp, cur.ag_level, v_all_vol);
        /*********ag_perfom_work_det************/
        SELECT sq_ag_perfom_work_det.nextval INTO v_det_id FROM dual;
        INSERT INTO ven_ag_perfom_work_det
          (ag_perfom_work_det_id, ag_rate_type_id, summ, ag_perfomed_work_act_id)
        VALUES
          (v_det_id
          ,(SELECT t.ag_rate_type_id FROM ag_rate_type t WHERE upper(t.brief) = cur.prem_detail_name)
          ,cur.summ_commiss
          ,v_act_id);
      END IF;
      /*******ag_perf_work_vol*************/
      SELECT sq_ag_perf_work_vol.nextval INTO v_vol_id FROM dual;
      INSERT INTO ven_ag_perf_work_vol
        (ag_perf_work_vol_id, ag_perfom_work_det_id, vol_amount, vol_rate, ag_volume_id)
      VALUES
        (v_vol_id, v_det_id, cur.detail_amt, cur.detail_rate, v_ag_volume_id);
      /*********************/
      v_old_ad_id := cur.ag_num_id;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      UPDATE ins.load_file_rows lf
         SET lf.val_33 = 'Неизвестная ошибка при загрузке данных в ведомость'
       WHERE lf.load_file_rows_id = v_cur_id;
      raise_application_error(-20001
                             ,'Ошибка при выполнении SAVE_TO_AG_ROLL ' || SQLERRM);
  END save_to_ag_roll;

  FUNCTION get_vol
  (
    par_ag_contract_header PLS_INTEGER
   ,par_roll_id            NUMBER
   ,par_rl_vol             NUMBER
   ,par_inv_vol            NUMBER
   ,par_ops_vol            NUMBER
   ,par_ops2_vol           NUMBER
   ,par_sofi_vol           NUMBER
  ) RETURN t_volume_val_o IS
    proc_name VARCHAR2(25) := 'GET_VOL';
    v_vol     t_volume_val_o := t_volume_val_o(NULL);
  BEGIN
  
    FOR r IN (SELECT 1          ag_volume_type_id
                    ,par_rl_vol amt
                FROM dual
              UNION
              SELECT 6           ag_volume_type_id
                    ,par_inv_vol amt
                FROM dual
              UNION
              SELECT 2           ag_volume_type_id
                    ,par_ops_vol amt
                FROM dual
              UNION
              SELECT 8            ag_volume_type_id
                    ,par_ops2_vol amt
                FROM dual
              UNION
              SELECT 3            ag_volume_type_id
                    ,par_sofi_vol amt
                FROM dual)
    LOOP
    
      v_vol.set_volume(r.ag_volume_type_id, r.amt);
    
    END LOOP;
  
    RETURN v_vol;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_vol;

  /*  Создание шапки ведомости на выплату
      Параметры:
               Дата начала периода
               Дата окончания периода
               Версия расчетной ведомости
               Тип компании
               Выходной: ИД выплатной ведомости
      Веселуха Е.В.
      Изменения: 26.04.2013
  */
  FUNCTION create_ag_roll_pay
  (
    p_begin_date            DATE
   ,p_end_date              DATE
   ,p_ag_roll_num           NUMBER
   ,p_type_company          NUMBER
   ,p_ag_roll_pay_header_id OUT NUMBER
  ) RETURN NUMBER IS
    p_roll_id NUMBER := 0;
    sq_pay_id NUMBER;
    p_new_num NUMBER;
    p_new_var VARCHAR2(10) := '';
    dt_id     NUMBER;
    is_calc   NUMBER := 0;
    no_calc EXCEPTION;
    proc_name VARCHAR2(20) := 'CREATE_AG_ROLL_PAY';
  BEGIN
  
    dbms_application_info.set_client_info('PKG_COMMISSION_CALC.CREATE_AG_ROLL_PAY;p_type_company = ' ||
                                          p_type_company);
    SELECT COUNT(*)
      INTO is_calc
      FROM ins.ven_ag_roll_pay_header arph
     WHERE arph.date_begin = p_begin_date
       AND arph.date_end = p_end_date
       AND arph.ag_roll_num = p_ag_roll_num
       AND arph.company = decode(p_type_company, 1, 'РЖ', 2, 'Партнерс', 'РЖ');
    IF is_calc != 0
    THEN
      RAISE no_calc;
    END IF;
  
    SELECT sq_ag_roll_pay_header.nextval INTO sq_pay_id FROM dual;
  
    SELECT dt.doc_templ_id INTO dt_id FROM doc_templ dt WHERE dt.brief = 'AG_PAY_HEADER';
  
    SELECT nvl(MAX(to_number(substr(arph.num, 1, 5))), 0) + 1
      INTO p_new_num
      FROM ins.ven_ag_roll_pay_header arph;
  
    INSERT INTO ins.ven_ag_roll_pay_header arph
      (ag_roll_pay_header_id, date_begin, date_end, ag_roll_num, num, doc_templ_id, company)
    VALUES
      (sq_pay_id
      ,p_begin_date
      ,p_end_date
      ,p_ag_roll_num
      ,lpad(p_new_num, 5, '0')
      ,dt_id
      ,decode(p_type_company, 1, 'РЖ', 2, 'Партнерс', 'РЖ'));
    dbms_application_info.set_client_info('PKG_COMMISSION_CALC.CREATE_AG_PAY_DETAIL;p_type_company = ' ||
                                          p_type_company);
    doc.set_doc_status(sq_pay_id, 'NEW');
    pkg_commission_calc.create_ag_pay_detail(sq_pay_id);
  
    p_ag_roll_pay_header_id := sq_pay_id;
    RETURN 1;
  
  EXCEPTION
    WHEN no_calc THEN
      pkg_forms_message.put_message('Выплатная ведомость с такими параметрами уже существует. Расчет невозможен.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Выплатная ведомость с такими параметрами уже существует. Расчет невозможен.');
    WHEN OTHERS THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'По неизвестной причине не удалось создать выплатную ведомость.');
  END create_ag_roll_pay;
  /*  Создание деталей выплатной ведомости
      Параметры:
               ИД шапки выплатной ведомости
      Тип компании - 2 Партнерс: собираем Агентов, Менеджеров, Директоров
                     1 РЖ: собираем Тер директоров
  */
  PROCEDURE create_ag_pay_detail(p_ag_pay_header_id NUMBER) IS
    proc_name VARCHAR2(20) := 'CREATE_AG_PAY_DETAIL';
    is_exists NUMBER;
    p_noncalc EXCEPTION;
    p_roll_type    VARCHAR2(30);
    v_date_begin   DATE;
    v_date_end     DATE;
    v_type_company NUMBER;
    v_roll_num     NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO is_exists
      FROM ins.ag_roll_pay_header aph
          ,document               d
          ,doc_status_ref         rf
     WHERE aph.ag_roll_pay_header_id = d.document_id
       AND rf.doc_status_ref_id = d.doc_status_ref_id
       AND aph.ag_roll_pay_header_id = p_ag_pay_header_id
       AND rf.brief = 'NEW';
    IF is_exists = 0
    THEN
      RAISE p_noncalc;
    END IF;
    SELECT arph.date_begin
          ,arph.date_end
          ,decode(arph.company, 'РЖ', 1, 'Партнерс', 2, 1)
          ,arph.ag_roll_num
      INTO v_date_begin
          ,v_date_end
          ,v_type_company
          ,v_roll_num
      FROM ins.ag_roll_pay_header arph
     WHERE arph.ag_roll_pay_header_id = p_ag_pay_header_id;
  
    INSERT INTO ins.ven_ag_roll_pay_detail
      (ag_roll_id
      ,ag_roll_header_id
      ,ag_perfomed_work_act_id
      ,ag_contract_header_id
      ,prem_sum
      ,ag_rate_type_id
      ,department_id
      ,contact_type_id
      ,ag_category_agent_id
      ,contact_id
      ,to_pay_bank
      ,to_pay_amount
      ,to_pay_props
      ,ag_roll_pay_header_id
      ,state_detail
      ,ag_sales_channel_id
      ,vol_type_id
      ,vol_type_brief
      ,ig_property
      ,other_prem_sum)
      SELECT ag_roll_id
            ,ag_roll_header_id
            ,ag_perfomed_work_act_id
            ,ag_contract_header_id
            ,SUM(vol_amount * vol_rate) prem_sum
            ,ag_rate_type_id
            ,department_id
            ,t_id_type_id
            ,ag_category_agent_id
            ,contact_id
            ,to_pay_bank
            ,to_pay_amount
            ,to_pay_props
            ,ag_roll_pay_header_id
            ,CASE
               WHEN to_pay_bank + to_pay_amount + to_pay_props < 3 THEN
                0
               ELSE
                1
             END
            ,ag_sales_chn_id
            ,vol_type_id
            ,vol_type_brief
            ,life_property
            ,(nvl(kpi_orig_ops, 0) + nvl(kpi_plan_ops, 0) + nvl(ksp_kpi_reach_0510, 0) +
             nvl(level_reach, 0) + /*NVL(KSP_reach, 0) + NVL(Evol_sub, 0) + NVL(Enrol_sub, 0) +*/
             nvl(qualitative_ops, 0) + nvl(q_male_ops, 0) /*+ NVL(Plan_reach, 0)*/
             ) other_prem_sum
        FROM (SELECT apw.ag_contract_header_id
                    ,apw.ag_perfomed_work_act_id
                    ,arh.ag_roll_header_id
                    ,ar.ag_roll_id
                    ,vol.vol_amount
                    ,vol.vol_rate
                    ,art.ag_rate_type_id
                    ,dep.department_id
                    ,tct.id t_id_type_id
                    ,aca.ag_category_agent_id
                    ,cn.contact_id
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM dual
                              WHERE EXISTS (SELECT NULL
                                       FROM ins.ag_documents agd
                                           ,ins.ag_doc_type  adt
                                           ,document         d
                                      WHERE agd.ag_contract_header_id = ach.ag_contract_header_id
                                        AND adt.ag_doc_type_id = agd.ag_doc_type_id
                                        AND adt.brief = 'PAY_PROP_CHG'
                                        AND agd.ag_documents_id = d.document_id
                                        AND d.doc_status_ref_id =
                                            (SELECT rf.doc_status_ref_id
                                               FROM doc_status_ref rf
                                              WHERE rf.brief = 'PROJECT'))) = 0 THEN
                        1
                       ELSE
                        0
                     END to_pay_bank
                    ,CASE
                       WHEN (SELECT SUM(nvl(vl.vol_amount, 0) * nvl(vl.vol_rate, 0))
                               FROM ins.ag_roll              r
                                   ,ins.ag_perfomed_work_act ac
                                   ,ins.ag_perfom_work_det   dt
                                   ,ins.ag_perf_work_vol     vl
                              WHERE ac.ag_contract_header_id = ach.ag_contract_header_id
                                AND ac.ag_roll_id = r.ag_roll_id
                                AND r.ag_roll_header_id = arh.ag_roll_header_id
                                AND dt.ag_perfomed_work_act_id = ac.ag_perfomed_work_act_id
                                AND vl.ag_perfom_work_det_id = dt.ag_perfom_work_det_id) <= 350 THEN
                        0
                       ELSE
                        1
                     END to_pay_amount
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM dual
                              WHERE EXISTS (SELECT NULL
                                       FROM ins.ag_bank_props pr
                                      WHERE pr.ag_contract_header_id = ach.ag_contract_header_id
                                        AND pr.enable = 1)) = 0 THEN
                        0
                       ELSE
                        1
                     END to_pay_props
                    ,p_ag_pay_header_id ag_roll_pay_header_id
                    ,ac.ag_sales_chn_id
                    ,(CASE
                       WHEN avt.brief IN ('NPF01', 'NPF02', 'NPF03', 'NPF', 'NPF(MARK9)') THEN
                        2
                       ELSE
                        1
                     END) vol_type_id
                    ,avt.brief vol_type_brief
                    ,nvl(ig.life_property, 0) life_property
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'KPI_ORIG_OPS') kpi_orig_ops
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'KPI_PLAN_OPS') kpi_plan_ops
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'LVL_0510') level_reach
                     /*                    ,(SELECT apd1.summ
                         FROM ins.ag_perfom_work_det apd1
                             ,ins.ag_rate_type       art1
                        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                          AND art1.brief = 'KSP_0510') KSP_reach
                     ,(SELECT apd1.summ
                         FROM ins.ag_perfom_work_det apd1
                             ,ins.ag_rate_type       art1
                        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                          AND art1.brief = 'ES_0510') Evol_sub
                     ,(SELECT apd1.summ
                         FROM ins.ag_perfom_work_det apd1
                             ,ins.ag_rate_type       art1
                        WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                          AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                          AND art1.brief = 'PENROL_0510') Enrol_sub*/
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'QOPS_0510') qualitative_ops
                    ,(SELECT apd1.summ
                        FROM ins.ag_perfom_work_det apd1
                            ,ins.ag_rate_type       art1
                       WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                         AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                         AND art1.brief = 'QMOPS_0510') q_male_ops
              /*                    ,(SELECT apd1.summ
               FROM ins.ag_perfom_work_det apd1
                   ,ins.ag_rate_type       art1
              WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                AND art1.brief = 'PEXEC_0510') Plan_reach*/
                FROM ins.ag_roll_header       arh
                    ,ins.ag_roll              ar
                    ,ins.document             d_ar
                    ,ins.ag_roll_type         rl_tp
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_rate_type         art
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_contract_header   ach
                    ,ins.ag_contract          ac
                    ,ins.t_sales_channel      ts
                    ,ins.department           dep
                    ,ins.contact              cn
                    ,ins.t_contact_type       tct
                    ,ins.ag_category_agent    aca
                    ,ins.ag_perf_work_vol     vol
                    ,ins.ag_volume            agv
                    ,ins.ag_volume_type       avt
                    ,ins.t_prod_line_option   opt
                    ,ins.t_product_line       pl
                    ,ins.t_insurance_group    ig
               WHERE 1 = 1
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND d_ar.document_id = ar.ag_roll_id
                 AND arh.ag_roll_type_id = rl_tp.ag_roll_type_id
                 AND rl_tp.brief NOT IN ('CALC_OAV_BANK', 'RLP_CALC', 'RLA_OAV', 'RLA_PREM')
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apw.ag_contract_header_id = ach.ag_contract_header_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = dep.department_id
                 AND ac.leg_pos = tct.id
                 AND ac.ag_sales_chn_id = ts.id
                 AND ach.agent_id = cn.contact_id
                 AND ac.category_id = aca.ag_category_agent_id
                 AND apd.ag_rate_type_id = art.ag_rate_type_id
                    /*AND arh.ag_roll_header_id = p_ag_roll_header_id*/
                 AND nvl(ar.date_begin, arh.date_begin) = v_date_begin
                 AND nvl(ar.date_end, arh.date_end) = v_date_end
                 AND d_ar.num = v_roll_num
                 AND vol.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                 AND vol.ag_volume_id = agv.ag_volume_id
                 AND agv.ag_volume_type_id = avt.ag_volume_type_id
                 AND aca.brief IN (CASE WHEN v_type_company = 1 THEN 'TD' ELSE aca.brief END)
                 AND aca.brief != 'TD'
                 AND agv.t_prod_line_option_id = opt.id(+)
                 AND opt.product_line_id = pl.id(+)
                 AND pl.insurance_group_id = ig.t_insurance_group_id(+))
       GROUP BY ag_roll_id
               ,ag_roll_header_id
               ,ag_perfomed_work_act_id
               ,ag_contract_header_id
               ,ag_rate_type_id
               ,department_id
               ,t_id_type_id
               ,ag_category_agent_id
               ,contact_id
               ,to_pay_bank
               ,to_pay_amount
               ,to_pay_props
               ,ag_roll_pay_header_id
               ,ag_sales_chn_id
               ,vol_type_id
               ,vol_type_brief
               ,life_property
               ,kpi_orig_ops
               ,kpi_plan_ops
               ,ksp_kpi_reach_0510
               ,level_reach
                /*,KSP_reach
                ,Evol_sub
                ,Enrol_sub*/
               ,qualitative_ops
               ,q_male_ops
      /*,Plan_reach*/
      UNION /* ALL*/
      SELECT ag_roll_id
            ,roll_header_id
            ,ag_perfomed_work_act_id
            ,agh_id
            ,prem_sum
            ,ag_rate_type_id
            ,department_id
            ,t_id_type_id
            ,ag_category_agent_id
            ,contact_id
            ,to_pay_bank
            ,to_pay_amount
            ,to_pay_props
            ,ag_roll_pay_header_id
            ,CASE
               WHEN to_pay_bank + to_pay_amount + to_pay_props < 3 THEN
                0
               ELSE
                1
             END
            ,t_sales_channel_id
            ,vol_type_id
            ,vol_type_brief
            ,life_property
            ,other_prem_sum
        FROM (SELECT ag_roll_id
                    ,roll_header_id
                    ,ag_perfomed_work_act_id
                    ,agh_id
                    ,prem_sum
                    ,(nvl(kpi_orig_ops, 0) + nvl(kpi_plan_ops, 0) + nvl(ksp_kpi_reach_0510, 0) +
                     nvl(level_reach, 0) + /*NVL(KSP_reach, 0) + NVL(Evol_sub, 0) + NVL(Enrol_sub, 0) +*/
                     nvl(qualitative_ops, 0) + nvl(q_male_ops, 0) /*+ NVL(Plan_reach, 0)*/
                     ) other_prem_sum
                    ,ag_rate_type_id
                    ,department_id
                    ,t_id_type_id
                    ,ag_category_agent_id
                    ,contact_id
                    ,ag_roll_pay_header_id
                    ,ig_property life_property
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM dual
                              WHERE EXISTS (SELECT NULL
                                       FROM ins.ag_documents agd
                                           ,ins.ag_doc_type  adt
                                           ,document         d
                                      WHERE agd.ag_contract_header_id = agh_id
                                        AND adt.ag_doc_type_id = agd.ag_doc_type_id
                                        AND adt.brief = 'PAY_PROP_CHG'
                                        AND agd.ag_documents_id = d.document_id
                                        AND d.doc_status_ref_id =
                                            (SELECT rf.doc_status_ref_id
                                               FROM doc_status_ref rf
                                              WHERE rf.brief = 'PROJECT'))) = 0 THEN
                        1
                       ELSE
                        0
                     END to_pay_bank
                    ,CASE
                       WHEN (SELECT SUM(nvl(vl.vol_amount, 0) * nvl(vl.vol_rate, 0))
                               FROM ins.ag_roll              r
                                   ,ins.ag_perfomed_work_act ac
                                   ,ins.ag_perfom_work_det   dt
                                   ,ins.ag_perf_work_vol     vl
                              WHERE ac.ag_contract_header_id = agh_id
                                AND ac.ag_roll_id = r.ag_roll_id
                                AND r.ag_roll_header_id = roll_header_id
                                AND dt.ag_perfomed_work_act_id = ac.ag_perfomed_work_act_id
                                AND vl.ag_perfom_work_det_id = dt.ag_perfom_work_det_id) <= 350 THEN
                        0
                       ELSE
                        1
                     END to_pay_amount
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM dual
                              WHERE EXISTS (SELECT NULL
                                       FROM ins.ag_bank_props pr
                                      WHERE pr.ag_contract_header_id = agh_id
                                        AND pr.enable = 1)) = 0 THEN
                        0
                       ELSE
                        1
                     END to_pay_props
                    ,t_sales_channel_id
                    ,vol_type_id
                    ,vol_type_brief
                FROM (SELECT apw.ag_contract_header_id agh_id
                            ,apw.ag_perfomed_work_act_id
                            ,arh.ag_roll_header_id roll_header_id
                            ,ar.ag_roll_id
                            ,cn.contact_id
                            ,tct.id t_id_type_id
                            ,aca.ag_category_agent_id
                            ,art.ag_rate_type_id
                            ,dep.department_id
                            ,nvl(ti.life_property, 0) ig_property
                            ,SUM(apv.vol_amount * apv.vol_rate) prem_sum
                            ,p_ag_pay_header_id ag_roll_pay_header_id
                            ,ach.t_sales_channel_id
                            ,(CASE
                               WHEN avt.brief IN ('NPF01', 'NPF02', 'NPF03', 'NPF', 'NPF(MARK9)') THEN
                                2
                               ELSE
                                1
                             END) vol_type_id
                            ,avt.brief vol_type_brief
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'KPI_ORIG_OPS') kpi_orig_ops
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'KPI_PLAN_OPS') kpi_plan_ops
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'KSP_KPI_Reach_0510') ksp_kpi_reach_0510
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'LVL_0510') level_reach
                             /*                            ,(SELECT apd1.summ
                                 FROM ins.ag_perfom_work_det apd1
                                     ,ins.ag_rate_type       art1
                                WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                  AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                  AND art1.brief = 'KSP_0510') KSP_reach
                             ,(SELECT apd1.summ
                                 FROM ins.ag_perfom_work_det apd1
                                     ,ins.ag_rate_type       art1
                                WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                  AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                  AND art1.brief = 'ES_0510') Evol_sub
                             ,(SELECT apd1.summ
                                 FROM ins.ag_perfom_work_det apd1
                                     ,ins.ag_rate_type       art1
                                WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                  AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                  AND art1.brief = 'PENROL_0510') Enrol_sub*/
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'QOPS_0510') qualitative_ops
                            ,(SELECT apd1.summ
                                FROM ins.ag_perfom_work_det apd1
                                    ,ins.ag_rate_type       art1
                               WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                 AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                                 AND art1.brief = 'QMOPS_0510') q_male_ops
                      /*                            ,(SELECT apd1.summ
                       FROM ins.ag_perfom_work_det apd1
                           ,ins.ag_rate_type       art1
                      WHERE apd1.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                        AND apd1.ag_rate_type_id = art1.ag_rate_type_id
                        AND art1.brief = 'PEXEC_0510') Plan_reach*/
                        FROM ins.ag_roll_header       arh
                            ,ins.ag_roll              ar
                            ,ins.document             d_ar
                            ,ins.ag_roll_type         rl_tp
                            ,ins.ag_perfomed_work_act apw
                            ,ins.ag_perfom_work_det   apd
                            ,ins.ag_rate_type         art
                            ,ins.ag_perf_work_vol     apv
                            ,ins.ag_volume            av
                            ,ins.t_prod_line_option   tplo
                            ,ins.t_product_line       tpl
                            ,ins.t_insurance_group    ti
                            ,ins.ag_volume_type       avt
                            ,ins.ag_contract_header   ach
                            ,ins.ag_contract          ac
                            ,ins.t_sales_channel      ts
                            ,ins.department           dep
                            ,ins.contact              cn
                            ,ins.t_contact_type       tct
                            ,ins.ag_category_agent    aca
                       WHERE 1 = 1
                         AND arh.ag_roll_header_id = ar.ag_roll_header_id
                         AND ar.ag_roll_id = apw.ag_roll_id
                         AND d_ar.document_id = ar.ag_roll_id
                         AND arh.ag_roll_type_id = rl_tp.ag_roll_type_id
                         AND rl_tp.brief = 'MnD_PREM'
                         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                         AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                         AND apv.ag_volume_id = av.ag_volume_id
                         AND av.ag_volume_type_id = avt.ag_volume_type_id
                         AND av.t_prod_line_option_id = tplo.id(+)
                         AND tplo.product_line_id = tpl.id(+)
                         AND tpl.insurance_group_id = ti.t_insurance_group_id(+)
                         AND apw.ag_contract_header_id = ach.ag_contract_header_id
                         AND ach.ag_contract_header_id = ac.contract_id
                         AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
                         AND aca.ag_category_agent_id = ac.category_id
                         AND ac.agency_id = dep.department_id
                         AND apd.ag_rate_type_id = art.ag_rate_type_id
                         AND ac.leg_pos = tct.id
                         AND ach.t_sales_channel_id = ts.id
                         AND ach.agent_id = cn.contact_id
                            /*AND arh.ag_roll_header_id = p_ag_roll_header_id*/
                         AND nvl(ar.date_begin, arh.date_begin) = v_date_begin
                         AND nvl(ar.date_end, arh.date_end) = v_date_end
                         AND d_ar.num = v_roll_num
                         AND aca.brief = (CASE
                               WHEN v_type_company = 1 THEN
                                'TD'
                               ELSE
                                'AG'
                             END)
                       GROUP BY apw.ag_contract_header_id
                               ,apw.ag_perfomed_work_act_id
                               ,arh.ag_roll_header_id
                               ,ar.ag_roll_id
                               ,cn.contact_id
                               ,tct.id
                               ,aca.ag_category_agent_id
                               ,art.ag_rate_type_id
                               ,dep.department_id
                               ,ts.description
                               ,avt.brief
                               ,nvl(ti.life_property, 0)
                               ,ach.t_sales_channel_id));
  
  EXCEPTION
    WHEN p_noncalc THEN
      raise_application_error(-20002
                             ,'Невозможно провести пересчет ведомости в данном статусе.');
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
    
  END create_ag_pay_detail;
  /**/
  FUNCTION prep_detail_to RETURN NUMBER IS
    proc_name    VARCHAR2(26) := 'PREP_DETAIL_TO';
    g_date_end   DATE;
    g_date_begin DATE;
    raise_too_many_rows EXCEPTION;
    raise_no_data_found EXCEPTION;
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.T_FOUNDED_TO_INS';
  
    BEGIN
      SELECT t.start_date
            ,t.end_date
        INTO g_date_begin
            ,g_date_end
        FROM ins.t_epg_paym_date t
       WHERE t.enabled = 1;
    EXCEPTION
      WHEN too_many_rows THEN
        RAISE raise_too_many_rows;
      WHEN no_data_found THEN
        RAISE raise_no_data_found;
    END;
  
    INSERT INTO ins.t_founded_to_ins
      SELECT CASE
               WHEN (epg_st <> 6 AND (epg_payed / rev_amount < 0.999 OR payment_date < '26.08.2010') AND
                    nvl(is_trans_annul, 0) = 0) THEN
                g_vt_nonevol
               WHEN nvl(pd_copy_stat, 6) = 41 THEN
                (CASE
                  WHEN (SELECT COUNT(*)
                          FROM ins.ag_volume agv
                         WHERE agv.epg_payment = epg
                           AND agv.ag_volume_type_id = g_vt_life) > 0 THEN
                   g_vt_life
                  WHEN nvl(is_trans_annul, 0) = 1 THEN
                   g_vt_life
                  ELSE
                   g_vt_nonevol
                END)
               WHEN (nvl(pd_copy_stat, 6) <> 6) THEN
                g_vt_nonevol
               ELSE
                CASE
                  WHEN vol.product_id IN (g_pr_familydep, g_pr_familydep_2011, g_pr_familydep_2014)
                       AND pay_term = g_pt_nonrecurring
                       AND greatest(conclude_date, payment_date, date_s) > '25.05.2011' THEN
                   g_vt_nonevol
                  WHEN vol.product_id IN (g_pr_familydep, g_pr_familydep_2011, g_pr_familydep_2014)
                       AND pay_period > 1 THEN
                   g_vt_nonevol
                  WHEN vol.product_id IN (g_pr_familydep, g_pr_familydep_2011, g_pr_familydep_2014)
                       AND pay_period <= 1
                       AND pay_term IN (g_pt_quater, g_pt_year, g_pt_halfyear) THEN
                   g_vt_fdep
                  WHEN vol.product_id = g_pr_investor
                       AND pay_doc_cm <> g_cm_tech THEN
                   g_vt_inv
                  WHEN vol.product_id = g_pr_investor_lump
                       AND pay_doc_cm <> g_cm_tech THEN
                   g_vt_inv
                  WHEN vol.product_id = g_pr_investor_lump_old
                       AND pay_doc_cm <> g_cm_tech THEN
                   g_vt_inv
                  ELSE
                   CASE
                     WHEN pay_doc_cm = g_cm_tech THEN
                      g_vt_nonevol
                     ELSE
                      g_vt_life
                   END
                END
             END vol_type
            ,(SELECT agh.ag_contract_header_id
                FROM ins.p_policy_agent_doc pad
                    ,ins.ag_contract_header agh
                    ,ins.ag_contract        ag
                    ,ins.document           dpad
               WHERE pad.ag_contract_header_id = agh.ag_contract_header_id
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND payment_date BETWEEN ag.date_begin AND ag.date_end
                 AND pad.policy_header_id = policy_header_id
                 AND dpad.document_id = pad.p_policy_agent_doc_id
                 AND dpad.doc_status_ref_id != g_st_error) ag_contract_header_id
            ,agency_id
            ,category_id
            ,policy_header_id
            ,date_s
            ,conclude_date
            ,ins_period
            ,pay_term
            ,last_st
            ,active_st
            ,fund
            ,epg
            ,epg_date
            ,pay_period
            ,epg_st
            ,epg_amt
            ,epg_pd_type
            ,pd_copy_stat
            ,pay_doc
            ,pay_doc_cm
            ,payment_date
            ,p_cover_id
            ,tplo_id
            ,CASE
               WHEN epg_st = g_st_paid
                    AND nvl(pd_copy_stat, g_st_paid) = g_st_paid THEN
                trans_id
               WHEN epg_payed / rev_amount >= (CASE
                      WHEN fund <> 122 THEN
                       0.99
                      ELSE
                       0.999
                    END) THEN
                trans_id
               WHEN nvl(is_trans_annul, 0) = 1 THEN
                trans_id
               ELSE
                NULL
             END trans_id
            ,trans_sum
            ,ROUND(ind_sum, 2) ind_sum
            ,CASE
               WHEN nvl(pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss'
                                                      ,t_number_type(policy_header_id))
                       ,999) = 999 THEN
                (CASE
                  WHEN vol.product_id = g_pr_protect_state THEN
                   0
                  WHEN vol.product_id IN (g_pr_bank_1, g_pr_bank_2, g_pr_bank_3, g_pr_bank_4, g_pr_bank_5) THEN
                   0.5
                  ELSE
                   CASE
                     WHEN (pay_period = 1 OR nvl(ind_sum, 0) <> 0)
                          AND epg_st = g_st_paid
                          AND nvl(pd_copy_stat, g_st_paid) = g_st_paid THEN
                      CASE
                        WHEN pay_term = g_pt_nonrecurring
                             AND ins_period > 1 THEN
                         0.1
                        ELSE
                         first_pay_coef
                      END
                     WHEN pay_period = 1
                          AND epg_payed / rev_amount >= 0.999 THEN
                      1
                     WHEN pay_period = 1
                          AND nvl(is_trans_annul, 0) = 1 THEN
                      1
                     ELSE
                      0
                   END
                END)
               ELSE
                pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss', t_number_type(policy_header_id))
             END nbv_coef
            ,CASE
               WHEN (pay_period = 1 OR nvl(ind_sum, 0) <> 0)
                    AND epg_st = g_st_paid
                    AND nvl(pd_copy_stat, g_st_paid) = g_st_paid THEN
                1
               WHEN (pay_period = 1 AND epg_payed / rev_amount >= 0.999) THEN
                1
               WHEN pay_period = 1
                    AND nvl(is_trans_annul, 0) = 1 THEN
                1
               ELSE
                0
             END is_nbv
        FROM (SELECT ph.policy_header_id
                    ,ph.product_id
                    ,pp.policy_id
                    ,ph.start_date date_s
                    ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) ins_period
                    ,pp.payment_term_id pay_term
                    ,doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                          ,'31.12.2999') last_st
                    ,doc.get_doc_status_id(ph.policy_id, '31.12.2999') active_st
                    ,ph.fund_id fund
                    ,(SELECT MIN(ds1.start_date)
                        FROM p_policy   pp1
                            ,doc_status ds1
                       WHERE pp1.pol_header_id = ph.policy_header_id
                         AND pp1.policy_id = ds1.document_id
                         AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr)) conclude_date
                    ,epg.plan_date epg_date
                    ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date) / 12) + 1 pay_period
                    ,epg.payment_id epg
                    ,epg.amount epg_amt
                    ,decode(ph.fund_id, 122, epg.amount, epg.rev_amount) rev_amount
                    ,(SELECT nvl(SUM(decode(dd_e.doc_doc_id
                                           ,NULL
                                           ,dso_e.set_off_child_amount
                                           ,dso2_e.set_off_child_amount))
                                ,0)
                        FROM doc_set_off dso_e
                            ,ac_payment  acp_e
                            ,doc_doc     dd_e
                            ,doc_set_off dso2_e
                       WHERE dso_e.parent_doc_id = epg.payment_id
                         AND acp_e.payment_id = dso_e.parent_doc_id
                         AND dso_e.cancel_date IS NULL
                         AND acp_e.payment_id = dd_e.parent_id(+)
                         AND dd_e.child_id = dso2_e.parent_doc_id(+)
                         AND dso2_e.cancel_date IS NULL) epg_payed
                    ,doc.get_doc_status_id(epg.payment_id) epg_st
                    ,epg_dso.set_off_child_amount epg_set_off
                    ,epg_pd.payment_templ_id epg_pd_type
                    ,decode(ph.fund_id, 122, epg_pd_copy.amount, epg_pd_copy.rev_amount) pd_copy_rev_amount
                    ,pd_dso.set_off_amount pd_dso_set_off_amount
                    ,doc.get_doc_status_id(epg_pd_copy.payment_id) pd_copy_stat
                    ,nvl(pp_pd.payment_id, epg_pd.payment_id) pay_doc
                    ,(SELECT MAX(acp1.due_date)
                        FROM doc_set_off dso1
                            ,ac_payment  acp1
                       WHERE dso1.parent_doc_id = epg.payment_id
                         AND acp1.payment_id = dso1.child_doc_id
                         AND acp1.payment_templ_id IN
                             (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) payment_date
                    ,nvl(pp_pd.collection_metod_id
                        ,nvl(epg_pd_copy.collection_metod_id, epg_pd.collection_metod_id)) pay_doc_cm
                    ,CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) = g_cm_direct_pay
                            AND pp.payment_term_id = g_pt_monthly THEN
                        (SELECT nvl(MIN(CASE
                                          WHEN nvl(pay_1.collection_metod_id, epg_pd1.collection_metod_id) =
                                               g_cm_direct_pay THEN
                                           1
                                          ELSE
                                           2
                                        END)
                                   ,2)
                           FROM p_policy       pp1
                               ,doc_doc        dd_policy
                               ,ven_ac_payment epg1
                               ,doc_set_off    epg_so
                               ,ac_payment     epg_pd1
                               ,doc_doc        dd_copy
                               ,doc_set_off    copy_so
                               ,ac_payment     pay_1
                          WHERE pp1.pol_header_id = ph.policy_header_id
                            AND dd_policy.parent_id = pp1.policy_id
                            AND dd_policy.child_id = epg1.payment_id
                            AND epg1.doc_templ_id = g_dt_epg_doc -- 4
                            AND epg1.plan_date < epg.plan_date
                            AND epg_so.parent_doc_id = epg1.payment_id
                            AND epg_so.child_doc_id = epg_pd1.payment_id
                            AND epg_pd1.payment_id = dd_copy.parent_id(+)
                            AND dd_copy.child_id = copy_so.parent_doc_id(+)
                            AND copy_so.child_doc_id = pay_1.payment_id(+))
                       ELSE
                        1
                     END first_pay_coef
                    ,pc.fee
                    ,pc.p_cover_id
                    ,tplo.id tplo_id
                    ,t.trans_id
                    ,MAX(t.reg_date) over(PARTITION BY epg.payment_id) max_reg_date
                    ,t.trans_amount trans_sum
                    ,t.trans_amount - t.trans_amount / CASE
                       WHEN EXISTS
                        (SELECT NULL
                               FROM p_policy            pol
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                                   ,ins.document        dpol
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(g_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' ||
                                               to_char(ADD_MONTHS(g_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(g_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(g_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(g_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       g_date_end
                                    END)
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief IN ('INDEXING2', 'FEE_INDEXATION')
                                AND dpol.document_id = pol.policy_id
                                AND dpol.doc_status_ref_id !=
                                    (SELECT rf.doc_status_ref_id
                                       FROM ins.doc_status_ref rf
                                      WHERE rf.brief = 'INDEXATING')) THEN
                        CASE
                          WHEN pp.start_date >=
                               (SELECT pol.start_date
                                  FROM p_policy            pol
                                      ,p_pol_addendum_type ppa
                                      ,t_addendum_type     ta
                                      ,ins.document        dpol
                                 WHERE pol.pol_header_id = ph.policy_header_id
                                   AND pol.start_date BETWEEN (CASE
                                         WHEN to_char(g_date_end + 1, 'DD.MM') = '29.02'
                                              AND MOD(to_char(g_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                          to_date(28 || '.' ||
                                                  to_char(ADD_MONTHS(g_date_end, -12), 'MM.YYYY')
                                                 ,'DD.MM.YYYY')
                                         ELSE
                                          ADD_MONTHS(g_date_end, -12) + 1
                                       END)
                                   AND (CASE
                                         WHEN to_char(g_date_end, 'DD.MM') = '29.02'
                                              AND MOD(to_char(g_date_end, 'YYYY'), 4) <> 0 THEN
                                          to_date(28 || '.' || to_char(g_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                         ELSE
                                          g_date_end
                                       END)
                                   AND pol.policy_id = ppa.p_policy_id
                                   AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                   AND ta.brief IN ('INDEXING2', 'FEE_INDEXATION')
                                   AND dpol.document_id = pol.policy_id
                                   AND dpol.doc_status_ref_id !=
                                       (SELECT rf.doc_status_ref_id
                                          FROM ins.doc_status_ref rf
                                         WHERE rf.brief = 'INDEXATING')
                                   AND rownum = 1 /*Да, потому что есть такие договора*/
                                ) THEN
                           ((SELECT pcl.fee pc_i
                               FROM p_policy            pol
                                   ,ins.document        dpol
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                                   ,as_asset            asl
                                   ,p_cover             pcl
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(g_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(ADD_MONTHS(g_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(g_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(g_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(g_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       g_date_end
                                    END)
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief IN ('INDEXING2', 'FEE_INDEXATION')
                                AND asl.p_policy_id = pol.policy_id
                                AND pcl.as_asset_id = asl.as_asset_id
                                AND pcl.t_prod_line_option_id = pc.t_prod_line_option_id
                                AND dpol.document_id = pol.policy_id
                                AND dpol.doc_status_ref_id !=
                                    (SELECT rf.doc_status_ref_id
                                       FROM ins.doc_status_ref rf
                                      WHERE rf.brief = 'INDEXATING')
                                AND rownum = 1) /
                           (SELECT pc_l.fee pc_l
                               FROM p_policy            pol
                                   ,ins.document        dpol
                                   ,as_asset            aas_l
                                   ,p_cover             pc_l
                                   ,p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE pol.pol_header_id = ph.policy_header_id
                                AND pol.start_date BETWEEN (CASE
                                      WHEN to_char(g_date_end + 1, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY') - 1, 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(ADD_MONTHS(g_date_end, -12), 'MM.YYYY')
                                              ,'DD.MM.YYYY')
                                      ELSE
                                       ADD_MONTHS(g_date_end, -12) + 1
                                    END)
                                AND (CASE
                                      WHEN to_char(g_date_end, 'DD.MM') = '29.02'
                                           AND MOD(to_char(g_date_end, 'YYYY'), 4) <> 0 THEN
                                       to_date(28 || '.' || to_char(g_date_end, 'MM.YYYY'), 'DD.MM.YYYY')
                                      ELSE
                                       g_date_end
                                    END)
                                AND aas_l.p_policy_id = pkg_policy.get_previous_version(pol.policy_id)
                                AND pc_l.as_asset_id = aas_l.as_asset_id
                                AND pol.policy_id = ppa.p_policy_id
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief IN ('INDEXING2', 'FEE_INDEXATION')
                                AND dpol.document_id = pol.policy_id
                                AND dpol.doc_status_ref_id !=
                                    (SELECT rf.doc_status_ref_id
                                       FROM ins.doc_status_ref rf
                                      WHERE rf.brief = 'INDEXATING')
                                AND pc_l.t_prod_line_option_id = pc.t_prod_line_option_id
                                AND rownum = 1))
                          ELSE
                           1
                        END
                       ELSE
                        1
                     END ind_sum
                    ,(SELECT 1
                        FROM dual
                       WHERE EXISTS
                       (SELECT NULL
                                FROM dual
                               WHERE nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                              ,'31.12.2999')
                                        ,-999) IN (g_st_quit
                                                  ,g_st_quit_to_pay
                                                  ,g_st_quit_req_reg
                                                  ,g_st_quit_query
                                                  ,g_st_to_quit_ch
                                                  ,g_st_to_quit
                                                  ,g_st_ch_ready)
                                 AND EXISTS
                               (SELECT NULL
                                        FROM doc_set_off dso1
                                            ,ac_payment  acp1
                                       WHERE dso1.parent_doc_id = epg.payment_id
                                         AND acp1.payment_id = dso1.child_doc_id
                                         AND doc.get_doc_status_id(acp1.payment_id) = g_st_annulated
                                         AND acp1.payment_templ_id IN
                                             (g_apt_a7
                                             ,g_apt_pd4
                                             ,g_apt_pp
                                             ,g_apt_pp_dir_p
                                             ,g_apt_pp_payer_p)
                                         AND EXISTS
                                       (SELECT NULL
                                                FROM ins.ag_volume agvf
                                               WHERE agvf.epg_payment = dso1.parent_doc_id)))) is_trans_annul
                    ,ag_agent.agency_id
                    ,ag_agent.category_id
                FROM p_pol_header ph
                    ,ven_p_policy pp
                    ,doc_doc pp_dd
                    ,ven_ac_payment epg
                    ,doc_set_off epg_dso
                    ,ac_payment epg_pd
                    ,doc_doc pd_dd
                    ,ac_payment epg_pd_copy
                    ,doc_set_off pd_dso
                    ,oper o
                    ,trans t
                    ,p_cover pc
                    ,t_prod_line_option tplo
                    ,ven_ac_payment pp_pd
                    ,(SELECT agh.ag_contract_header_id
                            ,pad.policy_header_id
                            ,ag.agency_id
                            ,ag.category_id
                        FROM ins.p_policy_agent_doc pad
                            ,ins.ag_contract_header agh
                            ,ins.ag_contract        ag
                            ,ins.document           dpad
                       WHERE pad.ag_contract_header_id = agh.ag_contract_header_id
                         AND agh.ag_contract_header_id = ag.contract_id
                         AND g_date_end BETWEEN ag.date_begin AND ag.date_end
                         AND dpad.document_id = pad.p_policy_agent_doc_id
                         AND dpad.doc_status_ref_id != g_st_error) ag_agent
               WHERE 1 = 1
                 AND ph.policy_header_id = pp.pol_header_id
                 AND ph.sales_channel_id IN (g_sc_dsf, g_sc_sas, g_sc_sas_2)
                 AND ag_agent.policy_header_id(+) = ph.policy_header_id
                 AND pp.policy_id = pp_dd.parent_id
                 AND pp_dd.child_id = epg.payment_id
                 AND epg.payment_id = epg_dso.parent_doc_id
                 AND epg_dso.child_doc_id = epg_pd.payment_id
                 AND epg_pd.payment_id = pd_dd.parent_id(+)
                 AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                 AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                 AND pd_dso.child_doc_id = pp_pd.payment_id(+)
                 AND o.document_id = nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                 AND t.oper_id = o.oper_id
                 AND t.dt_account_id = 122
                 AND pc.p_cover_id = t.obj_uro_id
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.description <> 'Административные издержки'
                    -- Ограничения по типам документов
                 AND epg.doc_templ_id = g_dt_epg_doc
                 AND epg_pd.payment_templ_id IN
                     (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                 AND (pp_pd.payment_templ_id IN (g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p) OR
                     pp_pd.payment_templ_id IS NULL)
                    -- Ограничения по отчетному периоду
                 AND epg.plan_date <= g_date_end + 1
                    /*********заявка №162959 стало***************************/
                 AND ((nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                ,'31.12.2999')
                          ,-999) IN (g_st_quit
                                      ,g_st_quit_to_pay
                                      ,g_st_quit_req_reg
                                      ,g_st_quit_query
                                      ,g_st_to_quit_ch
                                      ,g_st_to_quit
                                      ,g_st_ch_ready) AND EXISTS
                      (SELECT NULL
                          FROM doc_set_off dso1
                              ,ac_payment  acp1
                         WHERE dso1.parent_doc_id = epg.payment_id
                           AND acp1.payment_id = dso1.child_doc_id
                           AND doc.get_doc_status_id(acp1.payment_id) = g_st_annulated
                           AND acp1.payment_templ_id IN
                               (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                           AND EXISTS (SELECT NULL
                                  FROM ins.ag_volume agvf
                                 WHERE agvf.epg_payment = dso1.parent_doc_id))) OR
                     (nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                ,'31.12.2999')
                          ,-999) NOT IN (g_st_readycancel
                                          ,g_st_berak
                                          ,g_st_quit
                                          ,g_st_stop
                                          ,g_st_quit_to_pay
                                          ,g_st_quit_req_reg
                                          ,g_st_quit_query
                                          ,g_st_to_quit_ch
                                          ,g_st_to_quit
                                          ,g_st_ch_ready) AND
                     (SELECT MAX(acp1.due_date)
                          FROM doc_set_off dso1
                              ,ac_payment  acp1
                         WHERE dso1.parent_doc_id = epg.payment_id
                           AND acp1.payment_id = dso1.child_doc_id
                           AND dso1.cancel_date IS NULL
                           AND doc.get_doc_status_id(acp1.payment_id) != g_st_annulated
                           AND acp1.payment_templ_id IN
                               (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) BETWEEN
                     g_date_begin AND g_date_end))) vol;
  
    RETURN 1;
  
  EXCEPTION
    WHEN raise_too_many_rows THEN
      RETURN 0;
    WHEN raise_no_data_found THEN
      RETURN - 1;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
    
  END prep_detail_to;
  /*Процедура проверки данных при заливке
   Веселуха Е.В.
   23.08.2013
  */
  PROCEDURE check_data_detail_group(par_load_file_id NUMBER) IS
    v_row_status  load_file_rows.row_status%TYPE;
    v_row_comment load_file_rows.row_comment%TYPE;
  BEGIN
    FOR vr_rows IN (SELECT lfr.load_file_rows_id
                      FROM load_file_rows lfr
                     WHERE lfr.load_file_id = par_load_file_id)
    LOOP
      ins.pkg_commission_calc.check_data_detail(vr_rows.load_file_rows_id
                                               ,v_row_status
                                               ,v_row_comment);
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_rows.load_file_rows_id
                                           ,par_row_status        => v_row_status
                                           ,par_row_comment       => v_row_comment);
    END LOOP;
  END check_data_detail_group;
  /*Процедура проверки данных при заливке
   Веселуха Е.В.
   12.02.2013
  */
  PROCEDURE check_data_detail
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  ) IS
    v_roll_header_id NUMBER;
    v_roll_id        NUMBER;
    v_pol_header_id  NUMBER;
    v_ops_id         NUMBER;
    v_ag_id_1        NUMBER;
    v_ag_id_2        NUMBER;
    v_sales_id       NUMBER;
    v_dep_id         NUMBER;
    v_cat_id         NUMBER;
    v_payment_id     NUMBER;
    v_plan_date      DATE;
    v_roll_date      NUMBER;
    is_wrong         NUMBER := 0;
    v_due_date       DATE;
    v_cover_id       NUMBER;
    v_rate_id        NUMBER;
    v_volume_id      NUMBER;
    v_product_id     NUMBER;
    v_buf            VARCHAR2(4000);
  BEGIN
    FOR i IN (SELECT lf.val_30
                    ,lf.val_31
                    ,lf.val_16
                    ,lf.val_17
                    ,lf.val_4
                    , --агент
                     lf.val_14
                    , --агент
                     lf.val_1
                    , --канал продаж
                     lf.val_2
                    , --агентство
                     lf.val_3
                    , --категория
                     lf.val_19
                    , --эпг
                     lf.val_21
                    , --покрытие
                     lf.val_20
                    , --оплата
                     lf.val_12
                    , --премия
                     lf.val_13
                    , --объем
                     lf.val_15 --продукт
                FROM load_file_rows lf
               WHERE lf.load_file_rows_id = par_load_file_rows_id)
    LOOP
      /*проверка существования ведомости*/
      dbms_application_info.set_client_info('проверка существования ведомости');
      BEGIN
        SELECT arh.ag_roll_header_id
          INTO v_roll_header_id
          FROM ins.ven_ag_roll_header arh
         WHERE arh.num = lpad(i.val_30, 6, '0');
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Не найдена ведомость;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования версии ведомости*/
      dbms_application_info.set_client_info('проверка существования версии ведомости');
      BEGIN
        SELECT rl.ag_roll_id
          INTO v_roll_id
          FROM ins.ven_ag_roll_header arh
              ,ins.ven_ag_roll        rl
         WHERE arh.num = lpad(i.val_30, 6, '0')
           AND arh.ag_roll_header_id = rl.ag_roll_header_id
           AND rl.num = i.val_31;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Не найдена версия ведомости;';
          par_row_comment := par_row_comment || v_buf;
      END;
      IF v_roll_id IS NOT NULL
      THEN
        UPDATE load_file_rows rf
           SET rf.val_32 = v_roll_id
         WHERE rf.load_file_rows_id = par_load_file_rows_id;
      END IF;
      /*проверка существования ДС*/
      dbms_application_info.set_client_info('проверка существования ДС');
      IF i.val_16 IS NULL
         AND i.val_17 IS NULL
      THEN
        par_row_status  := pkg_load_file_to_table.get_error;
        is_wrong        := is_wrong + 1;
        v_buf           := 'Не указан номер договора;';
        par_row_comment := par_row_comment || v_buf;
      ELSIF i.val_16 IS NOT NULL
            AND i.val_17 IS NOT NULL
      THEN
        par_row_status  := pkg_load_file_to_table.get_error;
        is_wrong        := is_wrong + 1;
        v_buf           := 'Указан и ДС и ОПС;';
        par_row_comment := par_row_comment || v_buf;
      ELSIF i.val_16 IS NOT NULL
            AND i.val_17 IS NULL
      THEN
        BEGIN
          SELECT ph.policy_header_id
            INTO v_pol_header_id
            FROM ins.p_pol_header ph
           WHERE ph.policy_header_id = i.val_16;
        EXCEPTION
          WHEN no_data_found THEN
            par_row_status  := pkg_load_file_to_table.get_error;
            is_wrong        := is_wrong + 1;
            v_buf           := 'Не найден ДС;';
            par_row_comment := par_row_comment || v_buf;
        END;
      ELSIF i.val_16 IS NULL
            AND i.val_17 IS NOT NULL
      THEN
        BEGIN
          SELECT ops.policy_id
            INTO v_ops_id
            FROM etl.npf_ops_policy ops
           WHERE ops.policy_num LIKE '%' || i.val_17 || '%';
        EXCEPTION
          WHEN no_data_found THEN
            par_row_status  := pkg_load_file_to_table.get_error;
            is_wrong        := is_wrong + 1;
            v_buf           := 'ОПС не передавался;';
            par_row_comment := par_row_comment || v_buf;
        END;
      END IF;
      /*проверка существования АД кому начислено*/
      dbms_application_info.set_client_info('проверка существования АД');
      BEGIN
        SELECT agh.ag_contract_header_id
          INTO v_ag_id_1
          FROM ins.ag_contract_header agh
         WHERE agh.ag_contract_header_id = i.val_4;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Агент "КОМУ" не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования АД за кого начислено*/
      BEGIN
        SELECT agh.ag_contract_header_id
          INTO v_ag_id_2
          FROM ins.ag_contract_header agh
         WHERE agh.ag_contract_header_id = i.val_14;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Агент "ЗА КОГО" не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования канала продаж*/
      dbms_application_info.set_client_info('проверка существования канала продаж');
      BEGIN
        SELECT ch.id INTO v_sales_id FROM ins.t_sales_channel ch WHERE ch.description = i.val_1;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Канал продаж не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования агентства*/
      dbms_application_info.set_client_info('проверка существования агентства');
      BEGIN
        SELECT dep.department_id
          INTO v_dep_id
          FROM ins.department dep
         WHERE dep.department_id = i.val_2;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Агентство не найдено;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования категории*/
      dbms_application_info.set_client_info('проверка существования категории');
      BEGIN
        SELECT cat.ag_category_agent_id
          INTO v_cat_id
          FROM ins.ag_category_agent cat
         WHERE cat.category_name = i.val_3;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Категория не найдена;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка существования ЭПГ и попадание даты ЭПГ в период ведомости*/
      dbms_application_info.set_client_info('проверка существования ЭПГ, Оплат');
      IF v_roll_header_id IS NOT NULL
         AND v_roll_id IS NOT NULL
      THEN
        BEGIN
          SELECT ac.payment_id
                ,ac.plan_date
            INTO v_payment_id
                ,v_plan_date
            FROM ins.ac_payment ac
           WHERE ac.payment_id = i.val_19;
        EXCEPTION
          WHEN no_data_found THEN
            par_row_status  := pkg_load_file_to_table.get_error;
            is_wrong        := is_wrong + 1;
            v_buf           := 'ЭПГ не найден в системе;';
            par_row_comment := par_row_comment || v_buf;
        END;
        IF v_payment_id IS NOT NULL
        THEN
          BEGIN
            SELECT rl.ag_roll_id
              INTO v_roll_date
              FROM ins.ag_roll_header arh
                  ,ins.ag_roll        rl
             WHERE arh.ag_roll_header_id = rl.ag_roll_header_id
               AND rl.ag_roll_id = v_roll_id
               AND arh.ag_roll_header_id = v_roll_header_id
               AND v_plan_date + 1 <= nvl(rl.date_end, arh.date_end);
          EXCEPTION
            WHEN no_data_found THEN
              par_row_status  := pkg_load_file_to_table.get_error;
              is_wrong        := is_wrong + 1;
              v_buf           := 'ЭПГ не в периоде ведомости;';
              par_row_comment := par_row_comment || v_buf;
          END;
          /*проверка попадания даты оплаты в период ведомости*/
          SELECT MAX(ac.due_date)
            INTO v_due_date
            FROM ins.ac_payment ac
           WHERE ac.payment_id = i.val_20;
          BEGIN
            SELECT rl.ag_roll_id
              INTO v_roll_date
              FROM ins.ag_roll_header arh
                  ,ins.ag_roll        rl
             WHERE arh.ag_roll_header_id = rl.ag_roll_header_id
               AND rl.ag_roll_id = v_roll_id
               AND arh.ag_roll_header_id = v_roll_header_id
               AND v_due_date BETWEEN nvl(rl.date_begin, arh.date_begin) AND
                   nvl(rl.date_end, arh.date_end);
          EXCEPTION
            WHEN no_data_found THEN
              par_row_status  := pkg_load_file_to_table.get_error;
              is_wrong        := is_wrong + 1;
              v_buf           := 'Дата оплаты не в периоде ведомости;';
              par_row_comment := par_row_comment || v_buf;
          END;
        END IF;
      END IF;
      /*проверка на существование p_cover_id*/
      dbms_application_info.set_client_info('проверка существования p_cover_id');
      BEGIN
        SELECT pc.p_cover_id INTO v_cover_id FROM ins.p_cover pc WHERE pc.p_cover_id = i.val_21;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Покрытие не найдено;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка на существование типа премии*/
      dbms_application_info.set_client_info('проверка существования типа премии');
      BEGIN
        SELECT art.ag_rate_type_id
          INTO v_rate_id
          FROM ins.ag_rate_type art
         WHERE art.brief = i.val_12;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Тип премии не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка на существование объема*/
      dbms_application_info.set_client_info('проверка существования объема');
      BEGIN
        SELECT avt.ag_volume_type_id
          INTO v_volume_id
          FROM ins.ag_volume_type avt
         WHERE avt.brief = i.val_13;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Тип объема не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*проверка на существование продукта*/
      dbms_application_info.set_client_info('проверка существования продукта');
      BEGIN
        SELECT prod.product_id INTO v_product_id FROM ins.t_product prod WHERE prod.brief = i.val_15;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Продукт не найден;';
          par_row_comment := par_row_comment || v_buf;
      END;
    END LOOP;
    IF is_wrong = 0
    THEN
      par_row_status  := pkg_load_file_to_table.get_checked;
      par_row_comment := 'Запись прошла проверку';
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END check_data_detail;

  /*  Включить предыдущие периоды:
      к выплатной ведомости добавляем
      не выплаченные детали
      Веселуха Е.В.
      24.04.2013
      Параметр - ИД выплатной ведомости в статусе Новый
  */
  PROCEDURE add_last_period(par_roll_pay_header_id NUMBER) IS
    is_no_state_new  NUMBER;
    is_no_state_paid NUMBER;
    no_state_new  EXCEPTION;
    no_state_paid EXCEPTION;
    proc_name VARCHAR2(20) := 'ADD_LAST_PERIOD';
  BEGIN
  
    SELECT COUNT(*)
      INTO is_no_state_new
      FROM ins.ag_roll_pay_header arph
          ,ins.document           d
          ,ins.doc_status_ref     rf
     WHERE arph.ag_roll_pay_header_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief = 'NEW'
       AND arph.ag_roll_pay_header_id = par_roll_pay_header_id;
    IF is_no_state_new = 0
    THEN
      RAISE no_state_new;
    END IF;
    SELECT COUNT(*)
      INTO is_no_state_paid
      FROM ins.ag_roll_pay_header arph
          ,ins.document           d
          ,ins.doc_status_ref     rf
     WHERE arph.ag_roll_pay_header_id = d.document_id
       AND d.doc_status_ref_id = rf.doc_status_ref_id
       AND rf.brief = 'PAYED_AG'
       AND arph.ag_roll_pay_header_id != par_roll_pay_header_id;
    IF is_no_state_paid = 0
    THEN
      RAISE no_state_paid;
    END IF;
  
    INSERT INTO ins.ven_ag_roll_pay_detail
      (ag_roll_pay_detail_id
      ,ag_category_agent_id
      ,ag_contract_header_id
      ,ag_perfomed_work_act_id
      ,ag_rate_type_id
      ,ag_roll_header_id
      ,ag_roll_id
      ,ag_roll_pay_header_id
      ,amount_payed
      ,contact_id
      ,contact_type_id
      ,department_id
      ,ig_property
      ,prem_sum
      ,state_detail
      ,to_pay_amount
      ,to_pay_bank
      ,to_pay_props
      ,vol_type_id)
      SELECT sq_ag_roll_pay_detail.nextval
            ,arpd.ag_category_agent_id
            ,arpd.ag_contract_header_id
            ,arpd.ag_perfomed_work_act_id
            ,arpd.ag_rate_type_id
            ,arpd.ag_roll_header_id
            ,arpd.ag_roll_id
            ,par_roll_pay_header_id
            ,arpd.amount_payed
            ,arpd.contact_id
            ,arpd.contact_type_id
            ,arpd.department_id
            ,arpd.ig_property
            ,arpd.prem_sum
            ,arpd.state_detail
            ,arpd.to_pay_amount
            ,arpd.to_pay_bank
            ,arpd.to_pay_props
            ,arpd.vol_type_id
        FROM ins.ag_roll_pay_detail arpd
            ,ins.ag_roll_pay_header arph
            ,ins.ag_roll_header     arh
       WHERE arpd.state_detail IN (0, 3)
         AND arpd.prem_sum != 0
         AND arpd.ag_roll_pay_header_id = arph.ag_roll_pay_header_id
         AND arph.ag_roll_header_id = arh.ag_roll_header_id
         AND EXISTS (SELECT NULL
                FROM ins.ven_ag_roll_pay_header arpha
                    ,ins.document               d
                    ,ins.doc_status_ref         rf
                    ,ins.ag_roll_header         arha
               WHERE arpha.ag_roll_pay_header_id = d.document_id
                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                 AND rf.brief = 'PAYED_AG'
                 AND arpha.ag_roll_pay_header_id != par_roll_pay_header_id
                 AND arha.ag_roll_header_id = arpha.ag_roll_header_id
                 AND arha.ag_roll_type_id = arh.ag_roll_type_id);
    DELETE FROM ins.ag_roll_pay_detail arpd
     WHERE arpd.state_detail IN (0, 3)
       AND arpd.prem_sum != 0
       AND EXISTS
     (SELECT NULL
              FROM ins.ag_roll_pay_header arph
                  ,ins.ag_roll_header     arh
             WHERE arpd.ag_roll_pay_header_id = arph.ag_roll_pay_header_id
               AND arph.ag_roll_header_id = arh.ag_roll_header_id
               AND EXISTS (SELECT NULL
                      FROM ins.ven_ag_roll_pay_header arpha
                          ,ins.document               d
                          ,ins.doc_status_ref         rf
                          ,ins.ag_roll_header         arha
                     WHERE arpha.ag_roll_pay_header_id = d.document_id
                       AND d.doc_status_ref_id = rf.doc_status_ref_id
                       AND rf.brief = 'PAYED_AG'
                       AND arpha.ag_roll_pay_header_id != par_roll_pay_header_id
                       AND arpha.ag_roll_header_id = arha.ag_roll_header_id
                       AND arha.ag_roll_type_id = arh.ag_roll_type_id));
  
  EXCEPTION
    WHEN no_state_new THEN
      pkg_forms_message.put_message('В ведомость в данном статусе нет возможности добавить предыдущие периоды.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'В ведомость в данном статусе нет возможности добавить предыдущие периоды.');
    WHEN no_state_paid THEN
      pkg_forms_message.put_message('Нет ведомости в статусе Выплачен, предыдущие периоды не могут быть добавлены.');
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'Нет ведомости в статусе Выплачен, предыдущие периоды не могут быть добавлены.');
    WHEN OTHERS THEN
      raise_application_error(-20002
                             ,'Ошибка при выполнении ' || proc_name || ': ' ||
                              'По неизвестной ошибке не удалось добавить предыдущие периоды в указанную ведомость.');
  END add_last_period;

  /*  Экспорт выплатной ведомости в 1С
      Веселуха Е.
      19.04.2013
      Параметр - ИД выплатной ведомости
  */
  PROCEDURE export_sav(par_roll_pay_header_id NUMBER) IS
  BEGIN
  
    insi.pkg_gate_new.export_roll_pay(par_roll_pay_header_id);
  
  END export_sav;
  /**/
  PROCEDURE check_bank_group(par_load_file_id NUMBER) IS
    v_row_status  load_file_rows.row_status%TYPE;
    v_row_comment load_file_rows.row_comment%TYPE;
  BEGIN
    UPDATE ins.load_file_rows lfr
       SET lfr.row_status  = pkg_load_file_to_table.get_error
          ,lfr.row_comment = 'Задвоен ИДС (такой ИДС уже есть в списке)'
          ,lfr.is_checked  = 0
     WHERE lfr.load_file_rows_id NOT IN (SELECT MIN(lf.load_file_rows_id)
                                           FROM ins.load_file_rows lf
                                          WHERE lf.load_file_id = lfr.load_file_id
                                          GROUP BY lf.val_1
                                                  ,lf.val_2
                                                  ,lf.val_3
                                                  ,lf.val_4
                                                  ,lf.val_5)
       AND lfr.load_file_id = par_load_file_id;
    FOR vr_rows IN (SELECT lfr.load_file_rows_id
                      FROM ins.load_file_rows lfr
                     WHERE lfr.load_file_id = par_load_file_id
                       AND lfr.is_checked = 1)
    LOOP
      ins.pkg_commission_calc.check_bank(vr_rows.load_file_rows_id, v_row_status, v_row_comment);
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => vr_rows.load_file_rows_id
                                           ,par_row_status        => v_row_status
                                           ,par_row_comment       => v_row_comment);
    END LOOP;
  END check_bank_group;
  /**/
  PROCEDURE check_bank
  (
    par_load_file_rows_id NUMBER
   ,par_row_status        OUT load_file_rows.row_status%TYPE
   ,par_row_comment       OUT load_file_rows.row_comment%TYPE
  ) IS
    v_roll_header_id NUMBER;
    v_roll_id        NUMBER;
    v_pol_header_id  NUMBER;
    is_wrong         NUMBER := 0;
    v_buf            VARCHAR2(4000);
    v_count_header   NUMBER := 0;
  BEGIN
    FOR i IN (SELECT lf.val_1
                    ,lf.val_4
                    ,lf.val_5
                    ,lf.load_file_id
                FROM load_file_rows lf
               WHERE lf.load_file_rows_id = par_load_file_rows_id)
    LOOP
      /*проверка существования ИДС*/
      BEGIN
        SELECT ph.policy_header_id
          INTO v_pol_header_id
          FROM ins.p_pol_header ph
         WHERE ph.ids = i.val_1;
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Не найден ИДС;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*Проверка на существование в списке еще одного такого же ИДС*/
      /*SELECT COUNT(*)
        INTO v_count_header
        FROM ins.load_file_rows lf
       WHERE lf.val_1 =
             (SELECT ph.ids FROM ins.p_pol_header ph WHERE ph.policy_header_id = v_pol_header_id)
         AND lf.load_file_rows_id != par_load_file_rows_id
         AND lf.load_file_id = i.load_file_id;
      IF v_count_header != 0
      THEN
        par_row_status  := pkg_load_file_to_table.get_error;
        is_wrong        := is_wrong + 1;
        v_buf           := 'Задвоен ИДС (такой ИДС уже есть в списке. Удалите один из);';
        par_row_comment := par_row_comment || v_buf;
      END IF;*/
      /*Проверка существования ведомости*/
      BEGIN
        SELECT arh.ag_roll_header_id
          INTO v_roll_header_id
          FROM ins.ven_ag_roll_header arh
              ,ins.ag_roll_type       tp
         WHERE arh.num = lpad(i.val_4, 6, '0')
           AND arh.ag_roll_type_id = tp.ag_roll_type_id
           AND tp.brief = 'CALC_VOL_BANK';
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Не найдена ведомость объемов;';
          par_row_comment := par_row_comment || v_buf;
      END;
      /*Проверка существования версии ведомости*/
      BEGIN
        SELECT ar.ag_roll_id
          INTO v_roll_id
          FROM ins.ven_ag_roll_header arh
              ,ins.ven_ag_roll        ar
              ,ins.ag_roll_type       tp
         WHERE arh.num = lpad(i.val_4, 6, '0')
           AND ar.ag_roll_header_id = arh.ag_roll_header_id
           AND ar.num = i.val_5
           AND arh.ag_roll_type_id = tp.ag_roll_type_id
           AND tp.brief = 'CALC_VOL_BANK';
      EXCEPTION
        WHEN no_data_found THEN
          par_row_status  := pkg_load_file_to_table.get_error;
          is_wrong        := is_wrong + 1;
          v_buf           := 'Не найдена версии ведомости объемов;';
          par_row_comment := par_row_comment || v_buf;
      END;
    
    END LOOP;
    IF is_wrong = 0
    THEN
      par_row_status  := pkg_load_file_to_table.get_checked;
      par_row_comment := 'Запись прошла проверку';
    END IF;
  END check_bank;
  /**/
  PROCEDURE load_bank_group(par_load_file_id NUMBER) IS
  BEGIN
    UPDATE ins.ag_volume agv
       SET (agv.is_rsbu, agv.date_rsbu) =
           (SELECT fr.val_2
                  ,fr.val_3
              FROM ins.load_file_rows fr
             WHERE fr.load_file_id = par_load_file_id
               AND fr.row_status = ins.pkg_load_file_to_table.get_checked
               AND agv.ag_roll_id = (SELECT arl.ag_roll_id
                                       FROM ins.ven_ag_roll_header arh
                                           ,ins.ven_ag_roll        arl
                                           ,ins.ag_roll_type       tp
                                      WHERE arh.ag_roll_header_id = arl.ag_roll_header_id
                                        AND arh.num = lpad(fr.val_4, 6, '0')
                                        AND arl.num = fr.val_5
                                        AND arh.ag_roll_type_id = tp.ag_roll_type_id
                                        AND tp.brief = 'CALC_VOL_BANK')
               AND agv.policy_header_id =
                   (SELECT ph.policy_header_id FROM ins.p_pol_header ph WHERE ph.ids = fr.val_1))
     WHERE agv.policy_header_id IN (SELECT ph.policy_header_id
                                      FROM ins.p_pol_header   ph
                                          ,ins.load_file_rows fra
                                     WHERE fra.load_file_id = par_load_file_id
                                       AND fra.row_status = ins.pkg_load_file_to_table.get_checked
                                       AND ph.ids = fra.val_1)
       AND EXISTS (SELECT NULL
              FROM ins.load_file_rows fra
             WHERE fra.load_file_id = par_load_file_id
               AND fra.row_status = ins.pkg_load_file_to_table.get_checked
               AND agv.ag_roll_id = (SELECT arl.ag_roll_id
                                       FROM ins.ven_ag_roll_header arh
                                           ,ins.ven_ag_roll        arl
                                      WHERE arh.ag_roll_header_id = arl.ag_roll_header_id
                                        AND arh.num = lpad(fra.val_4, 6, '0')
                                        AND arl.num = fra.val_5))
       AND EXISTS (SELECT NULL
              FROM ins.ag_roll        rl
                  ,ins.ag_roll_header arh
                  ,ins.ag_roll_type   tp
             WHERE rl.ag_roll_id = agv.ag_roll_id
               AND arh.ag_roll_header_id = rl.ag_roll_header_id
               AND arh.ag_roll_type_id = tp.ag_roll_type_id
               AND tp.brief = 'CALC_VOL_BANK');
  
    IF SQL%ROWCOUNT != 0
    THEN
      UPDATE load_file_rows
         SET row_status  = ins.pkg_load_file_to_table.get_loaded
            ,row_comment = 'Загружено'
       WHERE load_file_id = par_load_file_id;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении LOAD_BANK_GROUP: ' ||
                              'Ошибка при обновлении признака и дат РСБУ.');
  END load_bank_group;
  /*Веселуха Е.В.
    30.10.2013
    Проверки перед пересчетом ведомости RLP
  */
  PROCEDURE check_recalc_roll(p_ag_roll_id NUMBER) IS
    v_roll_type_exist NUMBER;
    v_exeption EXCEPTION;
    v_msg              VARCHAR2(2000) := '';
    v_proc_name        VARCHAR2(20) := 'check_recalc_roll';
    v_roll_version_num NUMBER;
    v_exists_av_need   NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO v_roll_type_exist
      FROM ins.ag_roll rl
     WHERE rl.ag_roll_id = p_ag_roll_id
       AND EXISTS (SELECT NULL
              FROM ins.ag_roll_header arh
                  ,ins.ag_roll_type   art
             WHERE rl.ag_roll_header_id = arh.ag_roll_header_id
               AND arh.ag_roll_type_id = art.ag_roll_type_id
               AND art.brief = 'RLP_CALC');
  
    IF v_roll_type_exist = 0
    THEN
      v_msg := 'Для данного типа ведомости Пересчет не предусмотрен.';
      RAISE v_exeption;
    END IF;
  
    SELECT to_number(rl.num)
      INTO v_roll_version_num
      FROM ins.ven_ag_roll rl
     WHERE rl.ag_roll_id = p_ag_roll_id;
  
    IF v_roll_version_num <= 1
    THEN
      v_msg := 'Для данного номера версии ведомости Пересчет не предусмотрен.';
      RAISE v_exeption;
    END IF;
  
    SELECT COUNT(*)
      INTO v_exists_av_need
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_roll ar
             WHERE ar.ag_roll_id = p_ag_roll_id
               AND nvl(ar.rlp_av_need, 0) > 0);
  
    IF v_exists_av_need = 0
    THEN
      v_msg := 'Для данной версии ведомости проверьте наличие сумм АВНадо и АВРазмазать.';
      RAISE v_exeption;
    END IF;
  
  EXCEPTION
    WHEN v_exeption THEN
      raise_application_error(-20002, v_msg);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END check_recalc_roll;

  /*Веселуха Е.В.
    11.09.2013
    Пересчет ведомости RLP, размазка по АВНадо    
  */
  PROCEDURE calc(p_ag_roll_id NUMBER) IS
    v_proc_name       VARCHAR2(24) := 'pkg_commission_calc.calc';
    v_exists_data     NUMBER;
    v_copy_ag_roll_id NUMBER;
  BEGIN
  
    pkg_agent_calculator.insertinfo('Определение параметров ведомости');
    pkg_agent_calculator.insertinfo('Проверка наличия данных по ведомости (их создание при необходимости);');
    /**/
    SELECT COUNT(*)
      INTO v_exists_data
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_roll    ar
                  ,ins.ag_act_rlp act
             WHERE ar.ag_roll_id = p_ag_roll_id
               AND ar.ag_roll_id = act.ag_roll_id);
    IF v_exists_data = 0
    THEN
      BEGIN
        SELECT ag_roll_id
          INTO v_copy_ag_roll_id
          FROM (SELECT ar.ag_roll_id
                  FROM ins.ag_roll ar
                 WHERE ar.ag_roll_header_id =
                       (SELECT ara.ag_roll_header_id
                          FROM ins.ag_roll ara
                         WHERE ara.ag_roll_id = p_ag_roll_id)
                   AND ar.ag_roll_id < p_ag_roll_id
                 ORDER BY ar.ag_roll_id DESC)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_copy_ag_roll_id := p_ag_roll_id;
      END;
      copy_ag_roll(p_ag_roll_id, v_copy_ag_roll_id);
    END IF;
    /**/
    pkg_agent_calculator.insertinfo('Ведомость RLP_CALC id: ' || to_char(p_ag_roll_id));
    SELECT nvl(ar.rlp_av_need, 0)
      INTO g_av_need
      FROM ins.ag_roll ar
     WHERE ar.ag_roll_id = p_ag_roll_id;
  
    SELECT SUM(vol.vol_av)
          ,g_av_need - SUM(vol.vol_sav + vol.last_vol_av)
      INTO g_av_calc
          ,g_av_recalc
      FROM ins.ag_roll         ar
          ,ins.ag_act_rlp      act
          ,ins.ag_work_det_rlp det
          ,ins.ag_vol_rlp      vol
          ,ins.ag_volume_rlp   agv
          ,ins.ag_volume_type  t
          ,ins.p_pol_header    ph
     WHERE ar.ag_roll_id = p_ag_roll_id
       AND ar.ag_roll_id = act.ag_roll_id
       AND act.ag_act_rlp_id = det.ag_act_rlp_id
       AND det.ag_work_det_rlp_id = vol.ag_work_det_rlp_id
       AND vol.ag_volume_rlp_id = agv.ag_volume_rlp_id
       AND agv.ag_volume_type_id = t.ag_volume_type_id
       AND t.brief IN ('RL', 'INV', 'FDep')
       AND agv.policy_header_id = ph.policy_header_id;
  
    ins.pkg_commission_calc.recalcrlp(p_ag_roll_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END calc;
  /*Веселуха Е.В.
    11.09.2013
    Размазка по АВНадо
  */
  PROCEDURE recalcrlp(p_ag_roll_id NUMBER) IS
    v_proc_name VARCHAR2(30) := 'pkg_commission_calc.ReCalcRLP';
  BEGIN
    pkg_agent_calculator.insertinfo('Пересчет ведомости RLP');
    UPDATE ins.ag_vol_rlp vlr
       SET (vlr.percent_av_calc, vlr.av_need, vlr.rate_need) =
           (SELECT vlr.vol_av / g_av_calc
                  ,(vlr.vol_av / g_av_calc) * g_av_recalc
                  ,((vlr.vol_av / g_av_calc) * g_av_recalc) / (vlr.vol_amount * vlr.cross_rate)
              FROM ins.ag_work_det_rlp det
                  ,ins.ag_act_rlp      act
                  ,ins.ag_roll         ar
                  ,ins.ag_volume_rlp   agv
                  ,ins.ag_volume_type  t
                  ,ins.p_pol_header    ph
             WHERE vlr.ag_work_det_rlp_id = det.ag_work_det_rlp_id
               AND det.ag_act_rlp_id = act.ag_act_rlp_id
               AND act.ag_roll_id = ar.ag_roll_id
               AND ar.ag_roll_id = p_ag_roll_id
               AND vlr.ag_volume_rlp_id = agv.ag_volume_rlp_id
               AND agv.ag_volume_type_id = t.ag_volume_type_id
               AND t.brief IN ('RL', 'INV', 'FDep')
               AND agv.policy_header_id = ph.policy_header_id)
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_work_det_rlp det
                  ,ins.ag_act_rlp      act
                  ,ins.ag_roll         ar
                  ,ins.ag_volume_rlp   agv
                  ,ins.ag_volume_type  t
                  ,ins.p_pol_header    ph
             WHERE vlr.ag_work_det_rlp_id = det.ag_work_det_rlp_id
               AND det.ag_act_rlp_id = act.ag_act_rlp_id
               AND act.ag_roll_id = ar.ag_roll_id
               AND ar.ag_roll_id = p_ag_roll_id
               AND vlr.ag_volume_rlp_id = agv.ag_volume_rlp_id
               AND agv.ag_volume_type_id = t.ag_volume_type_id
               AND t.brief IN ('RL', 'INV', 'FDep')
               AND agv.policy_header_id = ph.policy_header_id);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END;
  /*Веселуха Е.В.
    30.10.2013
    Копируем AG_ROLL
    Параметры: p_ag_roll_id - на какую, p_copy_ag_roll_id - с какой копируем
  */
  PROCEDURE copy_ag_roll
  (
    p_ag_roll_id      NUMBER
   ,p_copy_ag_roll_id NUMBER
  ) IS
    v_proc_name VARCHAR2(15) := 'copy_ag_roll';
    v_act_id    NUMBER;
    v_det_id    NUMBER;
    v_vol_id    NUMBER;
    v_av_need   NUMBER;
    v_av_recalc NUMBER;
  BEGIN
    DELETE FROM ins.ag_act_rlp act WHERE act.ag_roll_id = p_ag_roll_id;
  
    FOR cur_act IN (SELECT act.ag_act_rlp_id
                          ,act.ag_roll_id
                          ,act.ag_contract_header_id
                          ,act.sum
                          ,act.date_calc
                      FROM ins.ag_roll    ar
                          ,ins.ag_act_rlp act
                     WHERE ar.ag_roll_id = p_copy_ag_roll_id
                       AND ar.ag_roll_id = act.ag_roll_id)
    LOOP
      SELECT sq_ag_act_rlp.nextval INTO v_act_id FROM dual;
      INSERT INTO ins.ven_ag_act_rlp
        (ag_act_rlp_id, ag_roll_id, ag_contract_header_id, date_calc, SUM)
      VALUES
        (v_act_id, p_ag_roll_id, cur_act.ag_contract_header_id, cur_act.date_calc, cur_act.sum);
      FOR cur_det IN (SELECT det.ag_work_det_rlp_id
                            ,det.ag_rate_type_id
                            ,det.summ
                            ,det.ag_act_rlp_id
                        FROM ins.ag_work_det_rlp det
                       WHERE det.ag_act_rlp_id = cur_act.ag_act_rlp_id)
      LOOP
        SELECT sq_ag_work_det_rlp.nextval INTO v_det_id FROM dual;
        INSERT INTO ins.ven_ag_work_det_rlp
          (ag_work_det_rlp_id, ag_act_rlp_id, ag_rate_type_id, summ)
        VALUES
          (v_det_id, v_act_id, cur_det.ag_rate_type_id, cur_det.summ);
        FOR cur_vol IN (SELECT vol.ag_vol_rlp_id
                              ,vol.ag_volume_rlp_id
                              ,vol.ag_work_det_rlp_id
                              ,vol.vol_amount
                              ,vol.vol_rate
                              ,vol.ext_work_det_rlp_id
                              ,vol.vol_sav
                              ,vol.vol_av
                              ,vol.last_vol_av
                              ,vol.percent_av_calc
                              ,vol.av_need
                              ,vol.rate_need
                              ,vol.cross_rate
                          FROM ins.ag_vol_rlp vol
                         WHERE vol.ag_work_det_rlp_id = cur_det.ag_work_det_rlp_id)
        LOOP
          SELECT sq_ag_vol_rlp.nextval INTO v_vol_id FROM dual;
          INSERT INTO ins.ven_ag_vol_rlp
            (ag_vol_rlp_id
            ,ag_volume_rlp_id
            ,ag_work_det_rlp_id
            ,av_need
            ,cross_rate
            ,ext_work_det_rlp_id
            ,last_vol_av
            ,percent_av_calc
            ,rate_need
            ,vol_amount
            ,vol_av
            ,vol_rate
            ,vol_sav)
          VALUES
            (v_vol_id
            ,cur_vol.ag_volume_rlp_id
            ,v_det_id
            ,cur_vol.av_need
            ,cur_vol.cross_rate
            ,cur_vol.ext_work_det_rlp_id
            ,cur_vol.last_vol_av
            ,cur_vol.percent_av_calc
            ,cur_vol.rate_need
            ,cur_vol.vol_amount
            ,cur_vol.vol_av
            ,cur_vol.vol_rate
            ,cur_vol.vol_sav);
        END LOOP;
      
      END LOOP;
    
    END LOOP;
  
    BEGIN
      SELECT nvl(ar.rlp_av_need, 0)
        INTO v_av_need
        FROM ins.ag_roll ar
       WHERE ar.ag_roll_id = p_ag_roll_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_av_need := 0;
    END;
  
    BEGIN
      SELECT v_av_need - SUM(vol.vol_sav + vol.last_vol_av)
        INTO v_av_recalc
        FROM ins.ag_roll         ar
            ,ins.ag_act_rlp      act
            ,ins.ag_work_det_rlp det
            ,ins.ag_vol_rlp      vol
            ,ins.ag_volume_rlp   agv
            ,ins.ag_volume_type  t
            ,ins.p_pol_header    ph
       WHERE ar.ag_roll_id = p_ag_roll_id
         AND ar.ag_roll_id = act.ag_roll_id
         AND act.ag_act_rlp_id = det.ag_act_rlp_id
         AND det.ag_work_det_rlp_id = vol.ag_work_det_rlp_id
         AND vol.ag_volume_rlp_id = agv.ag_volume_rlp_id
         AND agv.ag_volume_type_id = t.ag_volume_type_id
         AND t.brief IN ('RL', 'INV', 'FDep')
         AND agv.policy_header_id = ph.policy_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_av_recalc := 0;
    END;
  
    UPDATE ins.ag_roll ar SET ar.rlp_av_smear = v_av_recalc WHERE ar.ag_roll_id = p_ag_roll_id;
    /*COMMIT;*/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || v_proc_name || SQLERRM);
  END;

BEGIN

  SELECT rt.rate_type_id INTO g_rev_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';

  SELECT doc_status_ref_id INTO g_st_new FROM doc_status_ref WHERE brief = 'NEW';

  SELECT doc_status_ref_id INTO g_st_error FROM doc_status_ref WHERE brief = 'ERROR';

  SELECT doc_status_ref_id INTO g_st_act FROM doc_status_ref WHERE brief = 'ACTIVE';

  SELECT doc_status_ref_id INTO g_st_curr FROM doc_status_ref WHERE brief = 'CURRENT';

  SELECT doc_status_ref_id INTO g_st_stoped FROM doc_status_ref WHERE brief = 'STOPED';

  SELECT doc_status_ref_id INTO g_st_stop FROM doc_status_ref WHERE brief = 'STOP';

  SELECT doc_status_ref_id INTO g_st_print FROM doc_status_ref WHERE brief = 'PRINTED';

  SELECT doc_status_ref_id INTO g_st_revision FROM doc_status_ref WHERE brief = 'REVISION';

  SELECT doc_status_ref_id INTO g_st_agrevision FROM doc_status_ref WHERE brief = 'AGENT_REVISION';

  SELECT doc_status_ref_id INTO g_st_underwr FROM doc_status_ref WHERE brief = 'UNDERWRITING';

  SELECT doc_status_ref_id INTO g_st_berak FROM doc_status_ref WHERE brief = 'BREAK';

  SELECT doc_status_ref_id INTO g_st_resume FROM doc_status_ref WHERE brief = 'RESUME';

  SELECT doc_status_ref_id INTO g_st_readycancel FROM doc_status_ref WHERE brief = 'READY_TO_CANCEL';

  SELECT doc_status_ref_id INTO g_st_cancel FROM doc_status_ref WHERE brief = 'CANCEL';

  SELECT doc_status_ref_id INTO g_st_paid FROM doc_status_ref WHERE brief = 'PAID';

  SELECT doc_status_ref_id INTO g_st_annulated FROM doc_status_ref WHERE brief = 'ANNULATED';

  SELECT doc_status_ref_id INTO g_st_concluded FROM doc_status_ref WHERE brief = 'CONCLUDED';

  SELECT doc_status_ref_id INTO g_st_to_agent FROM doc_status_ref WHERE brief = 'PASSED_TO_AGENT';

  SELECT doc_status_ref_id
    INTO g_st_from_agent
    FROM doc_status_ref
   WHERE brief = 'RECEIVED_FROM_AGENT';

  SELECT doc_status_ref_id INTO g_st_quit FROM doc_status_ref WHERE brief = 'QUIT';

  SELECT doc_status_ref_id INTO g_st_quit_to_pay FROM doc_status_ref WHERE brief = 'QUIT_TO_PAY';

  SELECT doc_status_ref_id INTO g_st_quit_req_reg FROM doc_status_ref WHERE brief = 'QUIT_REQ_GET';

  SELECT doc_status_ref_id INTO g_st_quit_query FROM doc_status_ref WHERE brief = 'QUIT_REQ_QUERY';

  SELECT doc_status_ref_id INTO g_st_to_quit_ch FROM doc_status_ref WHERE brief = 'TO_QUIT_CHECKED';

  SELECT doc_status_ref_id INTO g_st_to_quit FROM doc_status_ref WHERE brief = 'TO_QUIT';

  SELECT doc_status_ref_id INTO g_st_ch_ready FROM doc_status_ref WHERE brief = 'TO_QUIT_CHECK_READY';

  SELECT dt.doc_templ_id INTO g_dt_epg_doc FROM doc_templ dt WHERE dt.brief = 'PAYMENT';

  SELECT dt.doc_templ_id INTO g_dt_pp_noncash_doc FROM doc_templ dt WHERE dt.brief = 'ПП';

  SELECT dt.doc_templ_id INTO g_dt_a7_doc FROM doc_templ dt WHERE dt.brief = 'A7';

  SELECT dt.doc_templ_id INTO g_dt_pd4_doc FROM doc_templ dt WHERE dt.brief = 'PD4';

  SELECT dt.doc_templ_id INTO g_dt_pp_direct_doc FROM doc_templ dt WHERE dt.brief = 'ПП_ПС';

  SELECT dt.doc_templ_id INTO g_dt_pp_payer_doc FROM doc_templ dt WHERE dt.brief = 'ПП_ОБ';

  SELECT apt.payment_templ_id INTO g_apt_pp FROM ac_payment_templ apt WHERE apt.brief = 'ПП';

  SELECT apt.payment_templ_id INTO g_apt_a7 FROM ac_payment_templ apt WHERE apt.brief = 'A7';

  SELECT apt.payment_templ_id INTO g_apt_pd4 FROM ac_payment_templ apt WHERE apt.brief = 'PD4';

  SELECT apt.payment_templ_id
    INTO g_apt_ukv
    FROM ac_payment_templ apt
   WHERE apt.brief = 'ЗачетУ_КВ';

  SELECT apt.payment_templ_id
    INTO g_apt_pp_dir_p
    FROM ac_payment_templ apt
   WHERE apt.brief = 'ПП_ПС';

  SELECT apt.payment_templ_id
    INTO g_apt_pp_payer_p
    FROM ac_payment_templ apt
   WHERE apt.brief = 'ПП_ОБ';

  SELECT pr.product_id INTO g_pr_familydep FROM t_product pr WHERE pr.brief = 'Family_Dep';
  SELECT pr.product_id INTO g_pr_familydep_2011 FROM t_product pr WHERE pr.brief = 'Family_Dep_2011';
  SELECT pr.product_id INTO g_pr_familydep_2014 FROM t_product pr WHERE pr.brief = 'Family_Dep_2014';

  SELECT pr.product_id INTO g_pr_investor FROM t_product pr WHERE pr.brief = 'Investor';

  SELECT pr.product_id INTO g_pr_investor_lump FROM t_product pr WHERE pr.brief = 'INVESTOR_LUMP';

  SELECT pr.product_id
    INTO g_pr_investor_lump_old
    FROM t_product pr
   WHERE pr.brief = 'INVESTOR_LUMP_OLD';

  SELECT pr.product_id INTO g_pr_protect_state FROM t_product pr WHERE pr.brief = 'Fof_Prot';

  SELECT pr.product_id INTO g_pr_bank_1 FROM t_product pr WHERE pr.brief = 'CR50_1';

  SELECT pr.product_id INTO g_pr_bank_2 FROM t_product pr WHERE pr.brief = 'CR50_2';

  SELECT pr.product_id INTO g_pr_bank_3 FROM t_product pr WHERE pr.brief = 'CR50_3';

  SELECT pr.product_id INTO g_pr_bank_5 FROM t_product pr WHERE pr.brief = 'CR50_4';

  SELECT pr.product_id INTO g_pr_bank_4 FROM t_product pr WHERE pr.brief = 'CR78';

  SELECT id INTO g_pt_quater FROM t_payment_terms WHERE brief = 'EVERY_QUARTER';

  SELECT id INTO g_pt_year FROM t_payment_terms WHERE brief = 'EVERY_YEAR';

  SELECT id INTO g_pt_halfyear FROM t_payment_terms WHERE brief = 'HALF_YEAR';

  SELECT id INTO g_pt_nonrecurring FROM t_payment_terms WHERE brief = 'Единовременно';

  SELECT id INTO g_pt_monthly FROM t_payment_terms WHERE description = 'Ежемесячно';

  SELECT ag_category_agent_id INTO g_ct_agent FROM ag_category_agent WHERE brief = 'AG';

  SELECT id INTO g_sc_dsf FROM t_sales_channel WHERE brief = 'MLM';

  SELECT id INTO g_sc_sas FROM t_sales_channel WHERE brief = 'SAS';

  SELECT id INTO g_sc_sas_2 FROM t_sales_channel WHERE brief = 'SAS 2';

  SELECT ts.id INTO g_sc_grs_moscow FROM t_sales_channel ts WHERE ts.brief = 'GRSMoscow';

  SELECT ts.id INTO g_sc_grs_region FROM t_sales_channel ts WHERE ts.brief = 'GRSRegion';

  SELECT prod.product_id INTO g_prod_cr92_1 FROM ins.t_product prod WHERE prod.brief = 'CR92_1';

  SELECT prod.product_id INTO g_prod_cr92_2 FROM ins.t_product prod WHERE prod.brief = 'CR92_2';

  SELECT prod.product_id INTO g_prod_cr92_3 FROM ins.t_product prod WHERE prod.brief = 'CR92_3';

  SELECT prod.product_id INTO g_prod_cr92_1_1 FROM ins.t_product prod WHERE prod.brief = 'CR92_1.1';

  SELECT prod.product_id INTO g_prod_cr92_2_1 FROM ins.t_product prod WHERE prod.brief = 'CR92_2.1';

  SELECT prod.product_id INTO g_prod_cr92_3_1 FROM ins.t_product prod WHERE prod.brief = 'CR92_3.1';

  SELECT id
    INTO g_cn_natperson
    FROM t_contact_type
   WHERE is_legal_entity = 0
     AND is_leaf = 1
     AND brief = 'ФЛ';

  SELECT id
    INTO g_cn_legentity
    FROM t_contact_type
   WHERE is_legal_entity = 0
     AND is_leaf = 1
     AND brief = 'ПБОЮЛ';

  SELECT id
    INTO g_cn_legal
    FROM t_contact_type
   WHERE is_legal_entity = 1
     AND is_leaf = 0
     AND brief = 'ЮЛ';

  SELECT cm.id
    INTO g_cm_direct_pay
    FROM t_collection_method cm
   WHERE cm.description = 'Прямое списание с карты';

  SELECT cm.id
    INTO g_cm_noncash_pay
    FROM t_collection_method cm
   WHERE cm.description = 'Безналичный расчет';

  SELECT cm.id
    INTO g_cm_payer_pay
    FROM t_collection_method cm
   WHERE cm.description = 'Перечисление средств Плательщиком';

  SELECT cm.id
    INTO g_cm_tech
    FROM t_collection_method cm
   WHERE cm.description = 'Технический';

  SELECT avt.ag_volume_type_id INTO g_vt_life FROM ag_volume_type avt WHERE avt.brief = 'RL';

  SELECT avt.ag_volume_type_id INTO g_vt_ops FROM ag_volume_type avt WHERE avt.brief = 'NPF';

  SELECT avt.ag_volume_type_id INTO g_vt_ops_1 FROM ag_volume_type avt WHERE avt.brief = 'NPF01';

  SELECT avt.ag_volume_type_id INTO g_vt_ops_2 FROM ag_volume_type avt WHERE avt.brief = 'NPF02';

  SELECT avt.ag_volume_type_id INTO g_vt_ops_3 FROM ag_volume_type avt WHERE avt.brief = 'NPF03';
  SELECT avt.ag_volume_type_id INTO g_vt_ops_9 FROM ag_volume_type avt WHERE avt.brief = 'NPF(MARK9)';

  SELECT avt.ag_volume_type_id INTO g_vt_inv FROM ag_volume_type avt WHERE avt.brief = 'INV';

  SELECT avt.ag_volume_type_id INTO g_vt_avc FROM ag_volume_type avt WHERE avt.brief = 'SOFI';

  SELECT avt.ag_volume_type_id INTO g_vt_bank FROM ag_volume_type avt WHERE avt.brief = 'BANK';

  SELECT avt.ag_volume_type_id INTO g_vt_avc_pay FROM ag_volume_type avt WHERE avt.brief = 'AVCP';

  SELECT avt.ag_volume_type_id INTO g_vt_nonevol FROM ag_volume_type avt WHERE avt.brief = 'INFO';

  SELECT avt.ag_volume_type_id INTO g_vt_fdep FROM ag_volume_type avt WHERE avt.brief = 'FDep';

  SELECT fund_id INTO g_fund_rur FROM fund WHERE brief = 'RUR';

  g_ag_fake_agent      := 2125380;
  g_ag_external_agency := 8127;

END pkg_commission_calc;
/

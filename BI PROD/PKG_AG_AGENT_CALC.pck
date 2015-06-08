CREATE OR REPLACE PACKAGE pkg_ag_agent_calc IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.01.2009 19:30:46
  -- Purpose : Расчет агнетского вознаграждения для Агентов (Новая НМ)
  TYPE t_cash IS RECORD(
     cash_amount    NUMBER
    ,commiss_amount NUMBER);

  --Расчет
  PROCEDURE calc
  (
    p_ag_roll_id            NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  );

  PROCEDURE calc_vedom_010409(p_ag_contract_header_id NUMBER);
  PROCEDURE update_detail_rlp(par_roll_id NUMBER);

  PROCEDURE calc_dav_vedom_010609(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_oav_vedom_010609(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_at_vedom(p_ag_contract_header_id NUMBER);

  PROCEDURE calc_ksp_vedom(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_oav_vedom_250510(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_oav_rla(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_av_rlp(p_ag_contract_header_id NUMBER);
  PROCEDURE calc_volume_vedom(p_ag_contract_header_id NUMBER DEFAULT NULL);
  PROCEDURE calc_volume_rla(p_ag_contract_header_id NUMBER DEFAULT NULL);
  PROCEDURE calc_volume_rlp(p_ag_contract_header_id NUMBER DEFAULT NULL);
  PROCEDURE calc_rlp_vedom(p_ag_contract_header_id NUMBER DEFAULT NULL);
  PROCEDURE calc_b2b_volume;

  FUNCTION get_payed_sav
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER;

  PROCEDURE get_ksp_volume(p_date DATE);
  PROCEDURE get_volume
  (
    p_date        DATE
   ,p_roll_type   PLS_INTEGER
   ,p_roll_header PLS_INTEGER
  );

  PROCEDURE prepare_ksp;
  PROCEDURE prepare_sgp;
  PROCEDURE prepare_ksp_0510;
  PROCEDURE prepare_cash;
  PROCEDURE prepare_cash_oav;
  PROCEDURE prepare_attest_vol;

  FUNCTION get_nbv_for_act(p_ag_contract_header PLS_INTEGER) RETURN t_volume_val_o;
  FUNCTION get_nbv_value
  (
    p_ag_contract_header PLS_INTEGER
   ,nbv_type             PLS_INTEGER
  ) RETURN NUMBER;
  FUNCTION get_ksp_value(p_ag_contract_header PLS_INTEGER) RETURN NUMBER;
  FUNCTION get_sgp(p_ag_work_det_id PLS_INTEGER) RETURN NUMBER;
  FUNCTION get_ksp(p_ag_work_det_id NUMBER) RETURN NUMBER;
  FUNCTION get_cash(p_ag_work_det_id NUMBER) RETURN t_cash;
  FUNCTION get_ksp_250510(p_ag_work_det_id PLS_INTEGER) RETURN NUMBER;

  PROCEDURE fake_sofi_prem_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE bonus_200_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE ips_ops_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE extra_sav_ops(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE get_oav_250510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE get_first_rla(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE get_rlp(p_ag_perf_work_det_id PLS_INTEGER);
  -- Author  : VESELEK
  -- Created : 29.05.2013 12:27:29
  -- Purpose : Производит перенос АВ в будущую ведомость для RLP
  PROCEDURE replace_rlp(par_roll_id NUMBER);
  PROCEDURE q_male_ops_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE get_grs_agents_prem(p_ag_perf_work_det_id PLS_INTEGER);

  PROCEDURE av_dav_calc_0106(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE av_dav_plus_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE av_oav_calc_0106(p_ag_perf_work_det_id PLS_INTEGER);

  PROCEDURE av_dav_all_calc(p_ag_contract_header_id NUMBER DEFAULT NULL);

  PROCEDURE av_dav_agent_calc
  (
    p_ag_contract_header_id NUMBER
   ,p_ag_perfomed_act       NUMBER
  );

  FUNCTION av_dav_agent_gr_policy_calc
  (
    par_policy_header_id NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER;

  FUNCTION av_dav_agent_policy_calc
  (
    par_pol_header       NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER;

  PROCEDURE av_oav_all_calc(p_ag_contract_header_id NUMBER DEFAULT NULL);

  PROCEDURE av_oav_agent_calc
  (
    p_ag_contract_header_id NUMBER
   ,p_ag_perfomed_act       NUMBER
  );

  FUNCTION ag_oav_agent_policy_calc
  (
    par_policy_header_id NUMBER
   ,p_performed_act_dpol NUMBER
  ) RETURN NUMBER;
  PROCEDURE load_trast
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
  );
  FUNCTION load_to_db_trast
  (
    p_load_id    NUMBER
   ,p_ag_roll_id NUMBER
  ) RETURN NUMBER;

  -- Author  : Веселуха Е.В.
  -- Created : 21.08.2013
  -- Purpose : Подготовка и заполнение ведомости объемов для Банков
  PROCEDURE calc_banks(p_ag_contract_header_id NUMBER DEFAULT NULL);
  -- Author  : Веселуха Е.В.
  -- Created : 22.08.2013
  -- Purpose : Расчет ведомости ОАВ для Банков / Брокеров
  PROCEDURE calc_oav_bank;
  -- Author  : Веселуха Е.В.
  -- Created : 22.08.2013
  -- Purpose : Производит расчет ОАВ для мотивации Банков / Брокеров
  PROCEDURE get_oav_bank(p_ag_perf_work_det_id PLS_INTEGER);
  -- Author  : Веселуха Е.В.
  -- Created : 23.08.2013
  -- Purpose : Получение САВ для банков с АД
  FUNCTION get_sav_bank
  (
    par_ag_contract_header_id t_ag_contract_sav.ag_contract_header_id%TYPE
   ,par_product_line_id       t_ag_contract_sav.product_line_id%TYPE
   ,par_ins_amount            t_ag_contract_sav.amount_from%TYPE
   ,par_insurance_period      t_ag_contract_sav.term_ins_from%TYPE
   ,par_commission_period     t_ag_contract_sav.pay_ins_from%TYPE
   ,par_assured_gender        t_ag_contract_sav.assured_gender%TYPE
   ,par_assured_age           t_ag_contract_sav.assured_age_from%TYPE
   ,par_policy_start_date     p_pol_header.start_date%TYPE
   ,par_payment_term          t_ag_contract_sav.paym_term%TYPE --Вид оплаты:0-Любой,1-Единовременная,2-Периодическая
   ,par_sum_fee               t_ag_contract_sav.sum_fee_from%TYPE
  ) RETURN t_ag_contract_sav.value_sav_order%TYPE;

  /*
    Капля П.
    04.08.2014
    Премия за Листы переговоров
    Если агент за отчетный период имеет 20 и более ЛП (см. п.1) , то:
    КВ для ФЛ =  Объем агента *15%, но не более 1500 руб.
    КВ для ИП = Объем агента*16,6%, но не более 1660 руб.
  */
  PROCEDURE get_conv_sheet_rate(par_ag_perf_work_det_id PLS_INTEGER);

  /*
    Зыонг Р.
    12.05.2015
    Премия за рекрутированного агента
  */
  PROCEDURE get_recruited_agent_prem(par_ag_perf_work_det_id PLS_INTEGER);
END pkg_ag_agent_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_agent_calc IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  g_date_end         DATE DEFAULT SYSDATE;
  g_date_begin       DATE DEFAULT SYSDATE;
  g_status_date      DATE := SYSDATE; --  := TO_DATE('10.12.2009 23:59:59','dd.mm.yyyy HH24:MI:SS'); -- SYSDATE;
  g_pay_reg_date     DATE := SYSDATE; --TO_DATE('12.08.2010 23:59:59','dd.mm.yyyy HH24:MI:SS');
  g_pay_date         DATE := SYSDATE; --TO_DATE('27.07.2010 23:59:59','dd.mm.yyyy HH24:MI:SS');
  g_cat_date         DATE;
  g_ops_sign_d       DATE;
  g_sofi_begin_d     DATE;
  g_sofi_end_d       DATE;
  g_roll_type        PLS_INTEGER DEFAULT NULL;
  g_roll_type_brief  ag_roll_type.brief%TYPE;
  g_roll_id          PLS_INTEGER;
  g_roll_num         PLS_INTEGER;
  g_roll_header_id   PLS_INTEGER;
  g_category_id      PLS_INTEGER;
  g_sales_ch         PLS_INTEGER;
  g_leg_pos          PLS_INTEGER;
  g_ag_status        PLS_INTEGER;
  g_ag_start_date    DATE;
  g_sgp1             NUMBER;
  g_sgp2             NUMBER;
  g_commision        NUMBER;
  g_ag_work_dpol     ven_ag_perfom_work_dpol%ROWTYPE;
  g_ksp_vedom        PLS_INTEGER;
  g_fund_rur         NUMBER;
  g_is_calc_sofi     NUMBER;
  g_is_calc_sofi_pay NUMBER;
  g_is_ops_retention NUMBER;
  g_note             VARCHAR2(255);
  g_is_only_nb       NUMBER;

  /* ОБЪЯВЛЕННЫЕ ПЕРЕМЕННЫЕ */
  --Инициализация в самом конце пакета
  --Статусы документов
  g_st_renew               PLS_INTEGER;
  g_st_getdoc              PLS_INTEGER;
  g_st_reins               PLS_INTEGER;
  g_st_medo                PLS_INTEGER;
  g_st_nostand             PLS_INTEGER;
  g_st_newterm             PLS_INTEGER;
  g_st_declrenew           PLS_INTEGER;
  g_st_passdoc             PLS_INTEGER;
  g_st_recdoc              PLS_INTEGER;
  g_st_recnewterm          PLS_INTEGER;
  g_st_new                 PLS_INTEGER;
  g_st_act                 PLS_INTEGER;
  g_st_curr                PLS_INTEGER;
  g_st_cancel              PLS_INTEGER;
  g_st_project             PLS_INTEGER;
  g_st_b2b_pending         PLS_INTEGER;
  g_st_b2b_calculated      PLS_INTEGER;
  g_st_waiting_for_payment PLS_INTEGER;
  g_st_stoped              PLS_INTEGER;
  g_st_print               PLS_INTEGER;
  g_st_revision            PLS_INTEGER;
  g_st_agrevision          PLS_INTEGER;
  g_st_underwr             PLS_INTEGER;
  g_st_berak               PLS_INTEGER;
  g_st_readycancel         PLS_INTEGER;
  g_st_paid                PLS_INTEGER;
  g_st_annulated           PLS_INTEGER;
  g_st_resume              PLS_INTEGER;
  g_st_stop                PLS_INTEGER;
  g_st_concluded           PLS_INTEGER;
  g_st_to_agent            PLS_INTEGER;
  g_st_from_agent          PLS_INTEGER;
  g_st_error               PLS_INTEGER;
  g_st_quit                PLS_INTEGER;
  g_st_quit_to_pay         PLS_INTEGER;
  g_st_quit_req_reg        PLS_INTEGER;
  g_st_quit_query          PLS_INTEGER;
  g_st_to_quit_ch          PLS_INTEGER;
  g_st_to_quit             PLS_INTEGER;
  g_st_ch_ready            PLS_INTEGER;
  --Курс на ЦБ
  g_rev_rate_type_id PLS_INTEGER;
  --Параметры АД
  g_ct_agent           PLS_INTEGER;
  g_sc_dsf             PLS_INTEGER;
  g_sc_sas             PLS_INTEGER;
  g_sc_sas_2           PLS_INTEGER;
  g_sc_grs_moscow      PLS_INTEGER;
  g_sc_grs_region      PLS_INTEGER;
  g_sc_rla             PLS_INTEGER;
  g_ag_fake_agent      PLS_INTEGER;
  g_ag_external_agency PLS_INTEGER;
  g_sc_bank            PLS_INTEGER;
  g_sc_br              PLS_INTEGER;
  g_sc_br_wdisc        PLS_INTEGER;
  g_sc_mbg             PLS_INTEGER;
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
  g_dt_pp_noncash_doc    NUMBER;
  g_dt_a7_doc            NUMBER;
  g_dt_pd4_doc           NUMBER;
  g_dt_epg_doc           NUMBER;
  g_dt_pp_direct_doc     NUMBER;
  g_dt_pp_payer_doc      NUMBER;
  g_dt_direct_pay        NUMBER;
  g_dt_payer_pay         NUMBER;
  g_dt_comiss_retention  NUMBER; -- Зачет удержания КВ
  g_ag_perf_work_act_doc NUMBER;
  --Шаблоны платежек
  g_apt_a7         PLS_INTEGER;
  g_apt_pd4        PLS_INTEGER;
  g_apt_pp         PLS_INTEGER;
  g_apt_pp_dir_p   PLS_INTEGER;
  g_apt_pp_payer_p PLS_INTEGER;
  g_apt_ukv        PLS_INTEGER;
  --Виды перечисления денег
  g_cm_direct_pay         t_collection_method.id%TYPE;
  g_cm_noncash_pay        t_collection_method.id%TYPE;
  g_cm_payer_pay          t_collection_method.id%TYPE;
  g_cm_tech               t_collection_method.id%TYPE;
  g_cm_periodic_writeoff  t_collection_method.id%TYPE;
  g_cm_internet_acquiring t_collection_method.id%TYPE;
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
  g_pr_investorplus      PLS_INTEGER;
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
  g_vt_inv     PLS_INTEGER;
  g_vt_avc     PLS_INTEGER;
  g_vt_avc_pay PLS_INTEGER;
  g_vt_nonevol PLS_INTEGER;
  g_vt_bank    PLS_INTEGER;
  g_vt_fdep    PLS_INTEGER;
  g_vt_ops_9   PLS_INTEGER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.01.2009 19:32:32
  -- Purpose : Основной расчет
  PROCEDURE calc
  (
    p_ag_roll_id            NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  ) IS
    v_calc_func VARCHAR2(2000);
  BEGIN
    --TODO переделать в процедуру Autonomus aka flush
    DELETE FROM time_elapsed WHERE sid = p_ag_roll_id;
    COMMIT;
  
    pkg_agent_calculator.insertinfo('Определение параметров ведомости');
    SELECT ar.date_begin
          ,ar.date_end
          ,art.ag_roll_type_id
          ,art.brief
          ,ar.ag_roll_id
          ,arh.ag_roll_header_id
          ,'begin ' || calc_pkg || '.' || calc_func || '(:P_ag_contract_header); end;' v_f
          ,ar.num
          ,arh.ksp_roll_header_id
          ,ar.payment_date + 0.99999
          ,ar.trans_reg_date + 0.99999
          ,nvl(ar.conclude_date + 0.99999, last_day(ar.date_end) + 10.99999)
          ,nvl(ar.ops_sign_date, ADD_MONTHS(g_date_end, 1))
          ,nvl(ar.sofi_begin_date, g_date_begin)
          ,nvl(ar.sofi_end_date, g_date_end)
          ,nvl(ar.is_calc_sofi, 0)
          ,nvl(ar.is_calc_sofi_pay, 0)
          ,nvl(ar.is_ops_retention, 0)
          ,nvl(TRIM(arh.note), 'Не определен')
          ,nvl(ar.is_only_nb, 0)
      INTO g_date_begin
          ,g_date_end
          ,g_roll_type
          ,g_roll_type_brief
          ,g_roll_id
          ,g_roll_header_id
          ,v_calc_func
          ,g_roll_num
          ,g_ksp_vedom
          ,g_pay_date
          ,g_pay_reg_date
          ,g_status_date
          ,g_ops_sign_d
          ,g_sofi_begin_d
          ,g_sofi_end_d
          ,g_is_calc_sofi
          ,g_is_calc_sofi_pay
          ,g_is_ops_retention
          ,g_note
          ,g_is_only_nb
      FROM ven_ag_roll            ar
          ,ins.ven_ag_roll_header arh
          ,ag_roll_type           art
     WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
       AND arh.ag_roll_type_id = art.ag_roll_type_id
       AND ar.ag_roll_id = p_ag_roll_id;
  
    pkg_agent_calculator.insertinfo('Ведомость ' || g_roll_type_brief || ' id: ' ||
                                    to_char(p_ag_roll_id));
  
    -- g_status_date:=last_day(g_date_end)+12.99999;
  
    EXECUTE IMMEDIATE v_calc_func
      USING p_ag_contract_header_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка! при расчете ведомости ' || SQLERRM || chr(10));
  END calc;

  -- Author  : Веселуха Е.В.
  -- Created : 23.08.2013
  -- Purpose : Получение САВ для банков с АД
  FUNCTION get_sav_bank
  (
    par_ag_contract_header_id t_ag_contract_sav.ag_contract_header_id%TYPE
   ,par_product_line_id       t_ag_contract_sav.product_line_id%TYPE
   ,par_ins_amount            t_ag_contract_sav.amount_from%TYPE
   ,par_insurance_period      t_ag_contract_sav.term_ins_from%TYPE
   ,par_commission_period     t_ag_contract_sav.pay_ins_from%TYPE
   ,par_assured_gender        t_ag_contract_sav.assured_gender%TYPE
   ,par_assured_age           t_ag_contract_sav.assured_age_from%TYPE
   ,par_policy_start_date     p_pol_header.start_date%TYPE
   ,par_payment_term          t_ag_contract_sav.paym_term%TYPE --Вид оплаты:0-Любой,1-Единовременная,2-Периодическая
   ,par_sum_fee               t_ag_contract_sav.sum_fee_from%TYPE
  ) RETURN t_ag_contract_sav.value_sav_order%TYPE IS
    proc_name VARCHAR2(25) := 'get_sav_bank';
    v_sav     NUMBER;
  BEGIN
    BEGIN
      SELECT value_sav_order
        INTO v_sav
        FROM (SELECT acs.value_sav_order
                FROM ins.t_ag_contract_sav acs
               WHERE acs.ag_contract_header_id = par_ag_contract_header_id
                 AND acs.product_line_id = par_product_line_id
                 AND par_policy_start_date BETWEEN acs.start_date AND acs.end_date
                 AND par_ins_amount BETWEEN acs.amount_from AND acs.amount_to
                 AND par_insurance_period BETWEEN acs.term_ins_from AND acs.term_ins_to
                 AND par_commission_period BETWEEN acs.pay_ins_from AND acs.pay_ins_to
                 AND par_assured_age BETWEEN acs.assured_age_from AND acs.assured_age_to
                 AND par_sum_fee BETWEEN acs.sum_fee_from AND acs.sum_fee_to
                 AND (acs.assured_gender IS NULL OR acs.assured_gender = par_assured_gender)
                 AND (acs.paym_term = par_payment_term OR acs.paym_term = 0)
                 AND acs.is_action = 1
               ORDER BY acs.t_ag_contract_sav_id DESC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_sav := 0;
    END;
    RETURN v_sav;
  END get_sav_bank;

  PROCEDURE calc_rlp_vedom(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(25) := 'Calc_RLP_vedom';
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет ведомости RLP');
  
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      NULL;
    END IF;
  
    INSERT INTO ven_ag_volume
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
      ,is_nbv)
      SELECT DISTINCT avt.ag_volume_type_id
                     ,g_roll_id
                     ,agv.ag_contract_header_id
                     ,agv.policy_header_id
                     ,agv.date_begin
                     ,agv.conclude_date
                     ,agv.ins_period
                     ,agv.payment_term_id
                     ,agv.last_status
                     ,agv.active_status
                     ,agv.fund
                     ,agv.epg_payment
                     ,agv.epg_date
                     ,agv.pay_period
                     ,agv.epg_status
                     ,agv.epg_ammount
                     ,agv.epg_pd_type
                     ,agv.pd_copy_status
                     ,agv.pd_payment
                     ,agv.pd_collection_method
                     ,agv.payment_date
                     ,agv.t_prod_line_option_id
                     ,agv.trans_id
                     ,agv.trans_sum
                     ,agv.index_delta_sum
                     ,agv.nbv_coef
                     ,agv.is_nbv
        FROM ins.ven_ag_perf_work_vol   apv
            ,ins.ag_perfom_work_det     apd
            ,ins.ag_perfomed_work_act   apw
            ,ins.ven_ag_roll            agr
            ,ins.ven_ag_roll_header     arh
            ,ins.ag_volume              agv
            ,ins.ag_volume_type         avt
            ,ins.p_pol_header           ph
            ,ins.ven_ag_contract_header agh
            ,ins.ag_contract            ag
            ,ins.ag_category_agent      aca
       WHERE apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
         AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
         AND apw.ag_roll_id = agr.ag_roll_id
         AND agr.ag_roll_header_id = arh.ag_roll_header_id
         AND agv.ag_volume_type_id = avt.ag_volume_type_id
         AND agv.ag_volume_id = apv.ag_volume_id
         AND agv.policy_header_id = ph.policy_header_id
         AND ph.start_date BETWEEN g_date_begin AND g_date_end
         AND agv.ag_contract_header_id = agh.ag_contract_header_id
         AND agh.ag_contract_header_id = ag.contract_id
         AND agr.date_end BETWEEN ag.date_begin AND ag.date_end
         AND ag.category_id = aca.ag_category_agent_id
         AND (aca.category_name = 'Агент' OR agv.ag_contract_header_id = apw.ag_contract_header_id);
  
    pkg_ag_agent_calc.update_detail_rlp(g_roll_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_rlp_vedom;

  PROCEDURE update_detail_rlp(par_roll_id NUMBER) IS
  BEGIN
  
    FOR cur_pol IN (SELECT COUNT(opt.id) over(PARTITION BY ig.life_property, agv.policy_header_id, agv.pd_payment) str_cnt
                          ,CASE
                             WHEN nvl(ig.life_property, 0) = 0 THEN
                              'C'
                             ELSE
                              'L'
                           END tp_life
                          ,COUNT(DISTINCT ig.life_property) over(PARTITION BY agv.policy_header_id, agv.pd_payment) str_num
                          ,agv.ag_volume_id
                          ,agv.policy_header_id
                      FROM ins.ag_volume          agv
                          ,ins.t_prod_line_option opt
                          ,ins.t_product_line     pl
                          ,ins.t_lob_line         ll
                          ,ins.t_insurance_group  ig
                     WHERE agv.ag_roll_id = par_roll_id
                       AND opt.id = agv.t_prod_line_option_id
                       AND opt.product_line_id = pl.id
                       AND pl.t_lob_line_id = ll.t_lob_line_id
                       AND ll.insurance_group_id = ig.t_insurance_group_id)
    LOOP
    
      IF cur_pol.str_num = 1
      THEN
        UPDATE ins.ag_volume agv
           SET agv.trans_sum = ROUND(nvl(pkg_tariff_calc.calc_coeff_val('CASH_FOR_PRODUCTLINE'
                                                                       ,t_number_type(agv.t_prod_line_option_id
                                                                                     ,to_char(SYSDATE
                                                                                             ,'Q')
                                                                                     ,to_char(agv.date_begin
                                                                                             ,'YYYY')))
                                        ,0) / cur_pol.str_cnt
                                    ,2)
         WHERE agv.ag_volume_id = cur_pol.ag_volume_id;
      ELSE
        CASE
          WHEN cur_pol.tp_life = 'C' THEN
            UPDATE ins.ag_volume agv
               SET agv.trans_sum = ROUND(nvl(pkg_tariff_calc.calc_coeff_val('CASH_FOR_PRODUCTLINE'
                                                                           ,t_number_type(agv.t_prod_line_option_id
                                                                                         ,to_char(SYSDATE
                                                                                                 ,'Q')
                                                                                         ,to_char(agv.date_begin
                                                                                                 ,'YYYY')))
                                            ,0) * 0.3 / cur_pol.str_cnt
                                        ,2)
             WHERE agv.ag_volume_id = cur_pol.ag_volume_id;
          ELSE
            UPDATE ins.ag_volume agv
               SET agv.trans_sum = ROUND(nvl(pkg_tariff_calc.calc_coeff_val('CASH_FOR_PRODUCTLINE'
                                                                           ,t_number_type(agv.t_prod_line_option_id
                                                                                         ,to_char(SYSDATE
                                                                                                 ,'Q')
                                                                                         ,to_char(agv.date_begin
                                                                                                 ,'YYYY')))
                                            ,0) * 0.7 / cur_pol.str_cnt
                                        ,2)
             WHERE agv.ag_volume_id = cur_pol.ag_volume_id;
        END CASE;
      END IF;
    
    END LOOP;
  
  END update_detail_rlp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 15:17:57
  -- Purpose : Подготовка и заполнение ведомости объемов
  PROCEDURE calc_volume_vedom(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(25) := 'Calc_cash_vedom';
  
    -- Удержание по заявке 329526
    PROCEDURE calc_deduction IS
    BEGIN
      INSERT INTO ag_volume
        (ag_volume_id
        ,ag_volume_type_id
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
        ,payment_date_orig
        ,is_deduction)
        SELECT sq_ag_volume.nextval
              ,av.ag_volume_type_id
              ,g_roll_id
              ,av.ag_contract_header_id
              ,policy_header_id
              ,av.date_begin
              ,conclude_date
              ,ins_period
              ,payment_term_id
              ,(SELECT dcl.doc_status_ref_id
                  FROM p_pol_header ph
                      ,document     dcl
                 WHERE ph.policy_header_id = av.policy_header_id
                   AND ph.last_ver_id = dcl.document_id) AS last_status
              ,(SELECT dca.doc_status_ref_id
                  FROM p_pol_header ph
                      ,document     dca
                 WHERE ph.policy_header_id = av.policy_header_id
                   AND ph.last_ver_id = dca.document_id) AS active_status
              ,fund
              ,epg_payment
              ,epg_date
              ,pay_period
              ,(SELECT dcp.doc_status_ref_id FROM document dcp WHERE dcp.document_id = av.epg_payment) AS epg_status
              ,epg_ammount
              ,epg_pd_type
              ,(SELECT dcp.doc_status_ref_id
                  FROM doc_doc  ddp
                      ,document dcp
                 WHERE ddp.parent_id = av.pd_payment
                   AND ddp.child_id = dcp.document_id) AS pd_copy_status
              ,pd_payment
              ,pd_collection_method
              ,payment_date
              ,t_prod_line_option_id
              ,trans_id
              ,-trans_sum
              ,index_delta_sum
              ,nbv_coef
              ,is_nbv
              ,payment_date_orig
              ,1 AS is_deduction
          FROM ag_volume          av
              ,document           dc
              ,ag_contract_header ach
              ,t_sales_channel    sc
         WHERE av.ag_contract_header_id = dc.document_id
           AND av.ag_contract_header_id = ach.ag_contract_header_id
           AND ach.t_sales_channel_id = sc.id
           AND dc.doc_status_ref_id != 10 -- Не Расторгнут
           AND sc.brief = 'MLM'
              --AND av.policy_header_id in (select ph.policy_header_id from p_pol_header ph where ph.ids in (1730008318,1630038510,2620185080,1630033247,4140013198,2160267486,2160009492))
           AND EXISTS (SELECT NULL
                  FROM doc_set_off dso
                      ,trans       tr
                      ,oper        op
                 WHERE tr.trans_id = av.trans_id
                   AND tr.oper_id = op.oper_id
                   AND op.document_id = dso.doc_set_off_id
                   AND dso.cancel_date IS NULL)
           AND (av.policy_header_id, av.ag_contract_header_id) IN
               (SELECT pp.pol_header_id
                      ,pad.ag_contract_header_id
                  FROM oper               op
                      ,p_policy           pp
                      ,trans              tr
                      ,p_policy_agent_doc pad
                 WHERE pp.policy_id = op.document_id
                   AND op.oper_id = tr.oper_id
                   AND pp.pol_header_id = pad.policy_header_id
                   AND tr.trans_date BETWEEN pad.date_begin AND pad.date_end
                   AND tr.trans_templ_id = 861
                   AND tr.trans_date BETWEEN g_date_begin AND g_date_end)
           AND NOT EXISTS (SELECT NULL
                  FROM ag_volume avd
                 WHERE avd.trans_id = av.trans_id
                   AND avd.is_deduction = 1);
    END calc_deduction;
  
    PROCEDURE delete_canceled_mpos_payments IS
    BEGIN
      DELETE FROM ag_volume av
       WHERE av.ag_roll_id = g_roll_id
         AND av.trans_id IN
             (SELECT tr.trans_id
                FROM trans tr
               WHERE tr.oper_id IN (SELECT op.oper_id
                                      FROM oper op
                                     WHERE op.document_id IN
                                           (SELECT dso.doc_set_off_id
                                              FROM doc_set_off dso
                                             WHERE dso.pay_registry_item IN
                                                   (SELECT wn.payment_register_item_id
                                                      FROM mpos_writeoff_notice wn
                                                          ,document             dc
                                                          ,doc_status_ref       dsr
                                                     WHERE wn.mpos_writeoff_form_id = dc.document_id
                                                       AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                                                       AND dsr.brief = 'CANCEL'))));
    END;
  BEGIN
  
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег BI');
  
    pkg_trace.add_variable(par_trace_var_name => 'g_date_end', par_trace_var_value => g_date_end);
    pkg_trace.add_variable(par_trace_var_name => 'g_date_begin', par_trace_var_value => g_date_begin);
    pkg_trace.add_variable(par_trace_var_name => 'g_roll_id', par_trace_var_value => g_roll_id);
  
    pkg_trace.trace_procedure_start(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                                   ,par_trace_subobj_name => 'CALC_VOLUME_VEDOM');
  
    --return;
    INSERT INTO ag_volume
      (ag_volume_id
      ,ag_volume_type_id
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
      ,payment_date_orig)
      SELECT sq_ag_volume.nextval
            ,CASE
               WHEN (epg_st <> g_st_paid AND
                    (epg_payed / rev_amount < 0.999 OR payment_date < '26.08.2010') AND
                    nvl(is_trans_annul, 0) = 0)
               --OR (nvl(pd_copy_stat,6) <> 6)
                THEN
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
                  WHEN vol.product_id IN (g_pr_investor, g_pr_investorplus)
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
            ,g_roll_id
            ,ag_contract_header_id
            ,
             --ДС
             policy_header_id
            ,date_s
            ,conclude_date
            ,ins_period
            ,pay_term
            ,last_st
            ,active_st
            ,fund
            ,
             --ЭПГ
             epg
            ,epg_date
            ,pay_period
            ,epg_st
            ,epg_amt
            , --info
             --Платежный документ
             epg_pd_type
            , --info
             pd_copy_stat
            ,pay_doc
            ,pay_doc_cm
            ,payment_date
            ,
             --Проводки
             tplo_id
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
            ,
             --если определение ставки для конкретного pol_header_id возвращает 999, то считаем NBV как обычно, иначе этой функцией
             CASE
               WHEN nvl(pkg_tariff_calc.calc_coeff_val('nbv_koef_for_commiss'
                                                      ,t_number_type(policy_header_id))
                       ,999) = 999 THEN
                (CASE
                  WHEN vol.product_id = g_pr_protect_state THEN
                   0
                  WHEN vol.product_id IN (g_pr_bank_1, g_pr_bank_2, g_pr_bank_3, g_pr_bank_4, g_pr_bank_5) THEN
                   0.5
                /*Настя сказала надо для CR78 (g_pr_Bank_4) 0,5
                WHEN vol.product_id IN (g_pr_Bank_4)
                THEN 0.125*/
                /*заявка №197959*/
                  WHEN vol.product_id IN (g_pr_investor_lump, g_pr_investor_lump_old) THEN
                   (CASE ins_period
                     WHEN 3 THEN
                      0.3
                     WHEN 5 THEN
                      0.2
                     ELSE
                      0
                   END)
                /**/
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
            ,NULL
        FROM (SELECT --ДС
               pad.ag_contract_header_id
              ,ph.policy_header_id
              ,ph.product_id
              ,pp.policy_id
              ,(SELECT agd.doc_date
                  FROM ins.ag_documents agd
                      ,ins.ag_doc_type  adt
                      ,ins.document     da
                 WHERE agd.ag_contract_header_id = pad.ag_contract_header_id
                   AND agd.ag_doc_type_id = adt.ag_doc_type_id
                   AND adt.brief = 'BREAK_AD'
                   AND da.document_id = agd.ag_documents_id
                   AND da.doc_status_ref_id NOT IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('PROJECT', 'CANCEL'))) break_ad_date
              ,(SELECT agh.date_begin
                  FROM ins.ag_contract_header agh
                 WHERE agh.ag_contract_header_id = pad.ag_contract_header_id) begin_ad_date
              ,ph.start_date date_s
              ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) ins_period
              ,pp.payment_term_id pay_term
              ,ph.ref_ph_id /*doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id), '31.12.2999')*/ last_st
              ,ph.ref_pp_id /*doc.get_doc_status_id(ph.policy_id, '31.12.2999')*/ active_st
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
              ,pd_dso.set_off_amount /* * ((Acc_New.Get_Rate_By_ID(1,
                                                                                                                                                                                                                                                                                                                                                     122,
                                                                                                                                                                                                                                                                                                                                                     epg_pd_copy.due_date) * 100) / 100)*/ pd_dso_set_off_amount
              ,doc.get_doc_status_id(epg_pd_copy.payment_id) pd_copy_stat
              ,nvl(pp_pd.payment_id, epg_pd.payment_id) pay_doc
               /*,CASE
                 WHEN pp.payment_term_id = g_pt_monthly
                      AND pp.is_group_flag = 0
                      AND nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) NOT IN
                      (g_cm_direct_pay, g_cm_payer_pay)
                      AND (pri.collection_method_id != g_cm_periodic_writeoff OR
                      pri.collection_method_id IS NULL)
                      -- Капля П. Сделал идентично тому, как применяетяс в отборе ниже
                      --AND (ph.start_date > to_date('26.12.2010', 'dd.mm.yyyy')
                      AND (pp.notice_date > to_date('25.12.2010', 'dd.mm.yyyy')
               
                      \*OR (SELECT MIN(ds1.start_date)
                      FROM p_policy pp1,
                      doc_status ds1
                      WHERE pp1.pol_header_id = ph.policy_header_id
                      AND pp1.policy_id = ds1.document_id
                      AND ds1.doc_status_ref_id IN
                      (g_st_Concluded,g_st_Curr,g_st_Stoped)) 
                      >= TO_DATE('15.01.2011','dd.mm.yyyy')*\
                      OR (SELECT MAX(acp1.due_date)
                                 FROM doc_set_off    dso1
                                     ,ac_payment     acp1
                                     ,ven_ac_payment epg_in
                                     ,doc_templ      dt_in
                                     ,doc_doc        dd_in
                                     ,p_policy       pp_in
                                WHERE 1 = 1
                                  AND pp_in.pol_header_id = ph.policy_header_id
                                  AND pp_in.policy_id = dd_in.parent_id
                                  AND dd_in.child_id = epg_in.payment_id
                                  AND epg_in.doc_templ_id = dt_in.doc_templ_id
                                  AND dt_in.brief = 'PAYMENT'
                                  AND doc.get_doc_status_brief(epg_in.payment_id) = 'PAID'
                                  AND epg_in.plan_date =
                                      (SELECT MIN(epg_in_in.plan_date)
                                         FROM ven_ac_payment epg_in_in
                                             ,doc_templ      dt_in_in
                                             ,doc_doc        dd_in_in
                                             ,p_policy       pp_in_in
                                        WHERE epg_in_in.payment_id = dd_in_in.child_id
                                          AND dd_in_in.parent_id = pp_in_in.policy_id
                                          AND pp_in_in.pol_header_id = ph.policy_header_id
                                          AND epg_in_in.doc_templ_id = dt_in_in.doc_templ_id
                                          AND dt_in_in.brief = 'PAYMENT')
                                  AND dso1.parent_doc_id = epg_in.payment_id
                                  AND acp1.payment_id = dso1.child_doc_id
                                  AND dso1.cancel_date IS NULL
                                  AND doc.get_doc_status_id(acp1.payment_id) != g_st_annulated
                                  AND acp1.payment_templ_id IN
                                      (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) >
                      to_date('25.12.2010', 'dd.mm.yyyy')) THEN
                  coalesce((SELECT --min(epg_in.plan_date)
                            MIN(epg_pay_in.due_date)
                             FROM p_policy       pp_in
                                 ,doc_doc        dd_in
                                 ,ac_payment     epg_in
                                 ,doc_set_off    dso_in
                                 ,ven_ac_payment epg_pay_in
                                 ,doc_doc        dd2_in
                                 ,doc_set_off    dso2_in
                                 ,ven_ac_payment pay_doc_in
                            WHERE pp_in.pol_header_id = ph.policy_header_id
                              AND pp_in.policy_id = dd_in.parent_id
                              AND dd_in.child_id = epg_in.payment_id
                              AND epg_in.payment_id = dso_in.parent_doc_id
                              AND dso_in.child_doc_id = epg_pay_in.payment_id
                              AND dso_in.cancel_date IS NULL
                              AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                              AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                 --AND dso2_in.cancel_date IS NULL
                              AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                              AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) IN
                                  (g_dt_pp_direct_doc
                                  ,g_dt_pp_payer_doc \*g_cm_Direct_pay,g_cm_Payer_pay*\))
                          ,(SELECT MAX(acp1.due_date)
                             FROM doc_set_off dso1
                                 ,ac_payment  acp1
                            WHERE dso1.parent_doc_id = epg.payment_id
                              AND acp1.payment_id = dso1.child_doc_id
                              AND acp1.payment_templ_id IN
                                  (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)))
                 ELSE
                  (SELECT MAX(acp1.due_date)
                     FROM doc_set_off dso1
                         ,ac_payment  acp1
                    WHERE dso1.parent_doc_id = epg.payment_id
                      AND acp1.payment_id = dso1.child_doc_id
                      AND acp1.payment_templ_id IN
                          (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p))
               END payment_date*/
              ,(SELECT MAX(acp1.due_date)
                  FROM doc_set_off dso1
                      ,ac_payment  acp1
                 WHERE dso1.parent_doc_id = epg.payment_id
                   AND acp1.payment_id = dso1.child_doc_id
                   AND dso1.cancel_date IS NULL
                   AND acp1.payment_templ_id IN
                       (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) AS payment_date
              ,coalesce(pri.collection_method_id
                       ,pp_pd.collection_metod_id
                       ,epg_pd_copy.collection_metod_id
                       ,epg_pd.collection_metod_id) pay_doc_cm
              ,CASE
                 WHEN pp.payment_term_id = g_pt_monthly
                      AND (nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) = g_cm_direct_pay OR
                      pri.collection_method_id IN (g_cm_periodic_writeoff, g_cm_internet_acquiring)) THEN
                  (SELECT nvl(MIN(CASE
                                    WHEN (nvl(pay_1.collection_metod_id, epg_pd1.collection_metod_id) =
                                         g_cm_direct_pay)
                                         OR pri1.collection_method_id IN
                                         (g_cm_periodic_writeoff, g_cm_internet_acquiring) THEN
                                     1
                                    ELSE
                                     2
                                  END)
                             ,2)
                     FROM p_policy                  pp1
                         ,doc_doc                   dd_policy
                         ,ven_ac_payment            epg1
                         ,doc_set_off               epg_so
                         ,ac_payment                epg_pd1
                         ,doc_doc                   dd_copy
                         ,doc_set_off               copy_so
                         ,ac_payment                pay_1
                         ,ins.payment_register_item pri1
                    WHERE pp1.pol_header_id = ph.policy_header_id
                      AND dd_policy.parent_id = pp1.policy_id
                      AND dd_policy.child_id = epg1.payment_id
                      AND epg1.doc_templ_id = g_dt_epg_doc -- 4
                      AND epg1.plan_date < epg.plan_date
                      AND epg_so.parent_doc_id = epg1.payment_id
                      AND epg_so.child_doc_id = epg_pd1.payment_id
                      AND epg_pd1.payment_id = dd_copy.parent_id(+)
                      AND dd_copy.child_id = copy_so.parent_doc_id(+)
                      AND copy_so.child_doc_id = pay_1.payment_id(+)
                      AND copy_so.pay_registry_item = pri1.payment_register_item_id(+))
                 ELSE
                  1
               END first_pay_coef
              ,
               --Проводки
               pc.fee
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
                          AND dpol.document_id = pol.policy_id
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))) THEN
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
                             AND dpol.document_id = pol.policy_id
                             AND dpol.doc_status_ref_id NOT IN
                                 (SELECT rf.doc_status_ref_id
                                    FROM ins.doc_status_ref rf
                                   WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                                   AND acp1.payment_templ_id IN
                                       (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                                   AND EXISTS (SELECT NULL
                                          FROM ins.ag_volume agvf
                                         WHERE agvf.epg_payment = dso1.parent_doc_id)))) is_trans_annul
                FROM (SELECT pha.policy_header_id
                            ,pha.fund_id
                            ,pha.start_date
                            ,pha.product_id
                            ,pha.policy_id
                            ,pha.sales_channel_id
                            ,pha.ids
                            ,d_ph.doc_status_ref_id ref_ph_id
                            ,d_pp.doc_status_ref_id ref_pp_id
                        FROM ins.p_pol_header pha
                            ,ins.document     d_ph
                            ,ins.document     d_pp
                       WHERE 1 = 1
                            /*And pha.ids in (1560388532
                            ,1960047551
                            ,1960047544
                            )*/
                         AND pha.last_ver_id = d_ph.document_id
                         AND pha.policy_id = d_pp.document_id
                            --AND pha.policy_header_id in (select ph.policy_header_id from p_pol_header ph where ph.ids in (1730008318,1630038510,2620185080,1630033247,4140013198,2160267486,2160009492))
                         AND pha.sales_channel_id IN (g_sc_dsf, g_sc_sas, g_sc_sas_2)
                         AND (pha.start_date < '26.08.2009' OR EXISTS
                              (SELECT NULL
                                 FROM p_policy   pp1
                                     ,doc_status ds1
                                WHERE pp1.pol_header_id = pha.policy_header_id
                                  AND pp1.policy_id = ds1.document_id
                                  AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr, g_st_stoped)
                                  AND ds1.start_date <= g_status_date))) ph
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
                         AND epga.plan_date <= g_date_end + 1) epg
                    ,ins.doc_set_off epg_dso
                    ,(SELECT *
                        FROM ins.ac_payment epg_pda
                       WHERE epg_pda.payment_templ_id IN
                             (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) epg_pd
                    ,ins.doc_doc pd_dd
                    ,ins.ac_payment epg_pd_copy
                    ,ins.doc_set_off pd_dso
                    ,ins.payment_register_item pri
                    ,ins.oper o
                    ,(SELECT tra.oper_id
                            ,tra.obj_uro_id
                            ,tra.trans_amount
                            ,tra.trans_id
                            ,tra.reg_date
                        FROM ins.trans tra
                       WHERE tra.dt_account_id = 122) t
                    ,ins.p_cover pc
                    ,ins.t_prod_line_option tplo
                    ,(SELECT *
                        FROM ins.ven_ac_payment pp_pda
                       WHERE (pp_pda.payment_templ_id IN (g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p) OR
                             pp_pda.payment_templ_id IS NULL)) pp_pd
               WHERE 1 = 1
                    --AND ph.policy_header_id IN (29938274,29842700,27336509)
                    --and ph.policy_header_id = 110302669
                    --AND ph.ids IN (1920134021)
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
                            AND acp1.payment_templ_id IN
                                (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p))
                     END BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
                 AND pp.policy_id = pp_dd.parent_id
                 AND pp_dd.child_id = epg.payment_id
                 AND epg.payment_id = epg_dso.parent_doc_id
                 AND epg_dso.child_doc_id = epg_pd.payment_id
                 AND epg_pd.payment_id = pd_dd.parent_id(+)
                 AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                 AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                 AND pd_dso.pay_registry_item = pri.payment_register_item_id(+)
                 AND pd_dso.child_doc_id = pp_pd.payment_id(+)
                 AND o.document_id = nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                 AND t.oper_id = o.oper_id
                 AND pc.p_cover_id = t.obj_uro_id
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.description <> 'Административные издержки'
                    /**********заявка №162959********************************/
                    /*AND nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id),'31.12.2999'),-999) 
                    NOT IN (g_st_ReadyCancel, g_st_Berak,g_st_quit, g_st_Stop,       
                            g_st_quit_to_pay, g_st_quit_req_reg, g_st_quit_query,
                            g_st_to_quit_ch,g_st_to_quit,g_st_ch_ready)*/
                    /******************************************/
                 AND (ph.start_date < '26.08.2009' OR EXISTS
                      (SELECT NULL
                         FROM p_policy   pp1
                             ,doc_status ds1
                        WHERE pp1.pol_header_id = ph.policy_header_id
                          AND pp1.policy_id = ds1.document_id
                          AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr, g_st_stoped)
                          AND ds1.start_date <= g_status_date))
                    --Ограничения для Аннулированных и опять созданных ЭПГ
                 AND NOT EXISTS
               (SELECT NULL
                        FROM p_policy           pan
                            ,doc_doc            dan
                            ,ac_payment         acan
                            ,document           ddan
                            ,doc_status         dsan
                            ,doc_status_ref     rf
                            ,ins.ag_volume      agvan
                            ,ins.ag_volume_type avta
                       WHERE pan.pol_header_id = ph.policy_header_id
                         AND dan.parent_id = pan.policy_id
                         AND dan.child_id = acan.payment_id
                         AND acan.plan_date = epg.plan_date
                         AND acan.payment_id = ddan.document_id
                         AND ddan.doc_status_id = dsan.doc_status_id
                         AND rf.doc_status_ref_id = ddan.doc_status_ref_id
                         AND rf.brief = 'ANNULATED'
                         AND agvan.epg_payment = acan.payment_id
                         AND avta.ag_volume_type_id = agvan.ag_volume_type_id
                         AND avta.ag_volume_type_id <> 4)
                    -- Огрнаничения для отсечения старых данных
                 AND ((ph.start_date < '26.08.2009' AND
                     (epg.plan_date > '26.04.2010' AND
                     (SELECT MAX(acp1.due_date)
                           FROM doc_set_off dso1
                               ,ac_payment  acp1
                          WHERE dso1.parent_doc_id = epg.payment_id
                            AND acp1.payment_id = dso1.child_doc_id
                            AND acp1.payment_templ_id IN
                                (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) > CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) =
                            g_cm_noncash_pay THEN
                        '25.04.2010'
                       ELSE
                        '10.05.2010'
                     END)) OR
                     (ph.start_date >= '26.08.2009' AND
                     ((epg.plan_date > '26.04.2010' AND
                     (SELECT MAX(acp1.due_date)
                            FROM doc_set_off dso1
                                ,ac_payment  acp1
                           WHERE dso1.parent_doc_id = epg.payment_id
                             AND acp1.payment_id = dso1.child_doc_id
                             AND acp1.payment_templ_id IN
                                 (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) > CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) =
                            g_cm_noncash_pay THEN
                        '25.04.2010'
                       ELSE
                        '10.05.2010'
                     END) OR (SELECT MIN(ds1.start_date)
                                   FROM p_policy   pp1
                                       ,doc_status ds1
                                  WHERE pp1.pol_header_id = ph.policy_header_id
                                    AND pp1.policy_id = ds1.document_id
                                    AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr)) >=
                     '12.05.2010' OR (epg.plan_date = '26.04.2010' AND epg.payment_number <> 1))))
                    
                    /*********заявка №162959 стало***************************/
                 AND ((ph.ref_ph_id IN (g_st_quit
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
                     (ph.ref_ph_id NOT IN (g_st_readycancel
                                           ,g_st_berak
                                           ,g_st_quit
                                           ,g_st_stop
                                           ,g_st_quit_to_pay
                                           ,g_st_quit_req_reg
                                           ,g_st_quit_query
                                           ,g_st_to_quit_ch
                                           ,g_st_to_quit
                                           ,g_st_ch_ready) AND
                     (SELECT MAX(trunc(acp1.due_date))
                          FROM doc_set_off dso1
                              ,ac_payment  acp1
                         WHERE dso1.parent_doc_id = epg.payment_id
                           AND acp1.payment_id = dso1.child_doc_id
                           AND dso1.cancel_date IS NULL
                           AND doc.get_doc_status_id(acp1.payment_id) != g_st_annulated
                           AND acp1.payment_templ_id IN
                               (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) <=
                     g_pay_date))
                    
                    /********заявка №162959 стало***************************/
                    /*AND (SELECT MAX(acp1.due_date) 
                     FROM doc_set_off dso1,
                          ac_payment acp1
                    WHERE dso1.parent_doc_id = epg.payment_id
                      AND acp1.payment_id = dso1.child_doc_id
                      AND dso1.cancel_date IS NULL
                      AND doc.get_doc_status_id(acp1.payment_id) != g_st_Annulated
                      AND acp1.payment_templ_id IN (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p))  <= g_pay_date*/
                    --Ограничения по типу поступивших денег
                    /*AND pp.payment_term_id = g_pt_monthly*/
                    /**************
                    Для ежемесячных договоров (с рядом ограничений) в объемы заходят деньги поступившие через MPOS и ACQ.
                    Эти ограничения применяются только к договорам с датой заключения > 25.12.2010, деньги по более старым заходят в объемы
                    ***************/
                 AND (CASE
                       WHEN pp.payment_term_id = g_pt_monthly
                            AND pp.is_group_flag = 0
                            AND nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) NOT IN
                            (g_cm_direct_pay, g_cm_payer_pay)
                            AND (pri.collection_method_id != g_cm_periodic_writeoff OR
                            pri.collection_method_id IS NULL)
                            AND pp.notice_date > to_date('25.12.2010', 'dd.mm.yyyy')
                            AND pp.notice_date < to_date('26.10.2014', 'dd.mm.yyyy') THEN
                       /*(CASE
                         WHEN ((SELECT MIN(epg_in.plan_date)
                                  FROM ac_payment     epg_in
                                      ,doc_set_off    dso_in
                                      ,ven_ac_payment epg_pay_in
                                      ,doc_doc        dd2_in
                                      ,doc_set_off    dso2_in
                                      ,ven_ac_payment pay_doc_in
                                 WHERE epg_in.payment_id = epg.payment_id
                                   AND epg_in.payment_id = dso_in.parent_doc_id
                                   AND dso_in.child_doc_id = epg_pay_in.payment_id
                                   AND dso_in.cancel_date IS NULL
                                   AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                   AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                   AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                   AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) NOT IN
                                       (g_dt_pp_direct_doc, g_dt_pp_payer_doc)
                                   AND trunc(nvl(dso_in.set_off_date, dso2_in.set_off_date)) <= g_date_end) BETWEEN
                              (SELECT MIN(epg_in.plan_date)
                                  FROM p_policy       pp_in
                                      ,doc_doc        dd_in
                                      ,ac_payment     epg_in
                                      ,doc_set_off    dso_in
                                      ,ven_ac_payment epg_pay_in
                                      ,doc_doc        dd2_in
                                      ,doc_set_off    dso2_in
                                      ,ven_ac_payment pay_doc_in
                                 WHERE pp_in.pol_header_id = ph.policy_header_id
                                   AND pp_in.policy_id = dd_in.parent_id
                                   AND dd_in.child_id = epg_in.payment_id
                                   AND epg_in.payment_id = dso_in.parent_doc_id
                                   AND dso_in.child_doc_id = epg_pay_in.payment_id
                                   AND dso_in.cancel_date IS NULL
                                   AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                   AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                   AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                   AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) IN
                                       (g_dt_pp_direct_doc, g_dt_pp_payer_doc)) AND
                              (SELECT MIN(epg_in.plan_date)
                                  FROM p_policy       pp_in
                                      ,doc_doc        dd_in
                                      ,ac_payment     epg_in
                                      ,doc_set_off    dso_in
                                      ,ven_ac_payment epg_pay_in
                                      ,doc_doc        dd2_in
                                      ,doc_set_off    dso2_in
                                      ,ven_ac_payment pay_doc_in
                                 WHERE pp_in.pol_header_id = ph.policy_header_id
                                   AND pp_in.policy_id = dd_in.parent_id
                                   AND dd_in.child_id = epg_in.payment_id
                                   AND epg_in.payment_id = dso_in.parent_doc_id
                                   AND dso_in.child_doc_id = epg_pay_in.payment_id
                                   AND dso_in.cancel_date IS NULL
                                   AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                   AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                   AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                   AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) IN
                                       (g_dt_pp_direct_doc, g_dt_pp_payer_doc)
                                   AND trunc(nvl(dso_in.set_off_date, dso2_in.set_off_date)) <= g_date_end
                                   AND epg_in.plan_date >
                                       (SELECT MIN(epg_in.plan_date)
                                          FROM p_policy       pp_in
                                              ,doc_doc        dd_in
                                              ,ac_payment     epg_in
                                              ,doc_set_off    dso_in
                                              ,ven_ac_payment epg_pay_in
                                              ,doc_doc        dd2_in
                                              ,doc_set_off    dso2_in
                                              ,ven_ac_payment pay_doc_in
                                         WHERE pp_in.pol_header_id = ph.policy_header_id
                                           AND pp_in.policy_id = dd_in.parent_id
                                           AND dd_in.child_id = epg_in.payment_id
                                           AND epg_in.payment_id = dso_in.parent_doc_id
                                           AND dso_in.child_doc_id = epg_pay_in.payment_id
                                           AND dso_in.cancel_date IS NULL
                                           AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                           AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                           AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                           AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) NOT IN
                                               (g_dt_pp_direct_doc, g_dt_pp_payer_doc)))
                              
                              OR
                              (SELECT MIN(epg_in.plan_date)
                                  FROM ac_payment     epg_in
                                      ,doc_set_off    dso_in
                                      ,ven_ac_payment epg_pay_in
                                      ,doc_doc        dd2_in
                                      ,doc_set_off    dso2_in
                                      ,ven_ac_payment pay_doc_in
                                 WHERE epg_in.payment_id = epg.payment_id
                                   AND epg_in.payment_id = dso_in.parent_doc_id
                                   AND dso_in.child_doc_id = epg_pay_in.payment_id
                                   AND dso_in.cancel_date IS NULL
                                   AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                   AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                   AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                   AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) NOT IN
                                       (g_dt_pp_direct_doc, g_dt_pp_payer_doc)
                                   AND trunc(nvl(dso_in.set_off_date, dso2_in.set_off_date)) <= g_date_end) <
                              (SELECT MIN(epg_in.plan_date)
                                  FROM p_policy       pp_in
                                      ,doc_doc        dd_in
                                      ,ac_payment     epg_in
                                      ,doc_set_off    dso_in
                                      ,ven_ac_payment epg_pay_in
                                      ,doc_doc        dd2_in
                                      ,doc_set_off    dso2_in
                                      ,ven_ac_payment pay_doc_in
                                 WHERE pp_in.pol_header_id = ph.policy_header_id
                                   AND pp_in.policy_id = dd_in.parent_id
                                   AND dd_in.child_id = epg_in.payment_id
                                   AND epg_in.payment_id = dso_in.parent_doc_id
                                   AND dso_in.child_doc_id = epg_pay_in.payment_id
                                   AND dso_in.cancel_date IS NULL
                                   AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                                   AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                                   AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                                   AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) IN
                                       (g_dt_pp_direct_doc, g_dt_pp_payer_doc)
                                   AND trunc(nvl(dso_in.set_off_date, dso2_in.set_off_date)) <= g_date_end)) THEN
                          1
                         ELSE
                          0
                       END)*/
                        (CASE
                          WHEN EXISTS (SELECT NULL
                                  FROM mpos_writeoff_form mwf
                                 WHERE mwf.policy_header_id = ph.policy_header_id)
                               OR EXISTS
                           (SELECT NULL
                                  FROM acq_payment_template aqpt
                                      ,acq_internet_payment intp
                                 WHERE aqpt.policy_header_id = ph.policy_header_id
                                   AND intp.acq_payment_template_id = aqpt.acq_payment_template_id
                                   AND trunc(intp.transaction_date) BETWEEN g_date_begin AND g_date_end
                                   AND doc.get_doc_status_brief(intp.acq_internet_payment_id, SYSDATE) =
                                       'LOADED') THEN
                           1
                          ELSE
                           0
                        END)
                       ELSE
                        1
                     END) = 1
                    --ограничение по новому бизнесу
                 AND (nvl(g_is_only_nb, 0) != 1 OR ph.start_date BETWEEN g_date_begin AND g_date_end)
                    /* Капля П. Заменил на эквивалентное.
                    Значение g_is_only_nb устанавливается в самой главной функции - calc причем с nvl( ,0) так что оно всегда будет иметь значение
                    (CASE
                         WHEN g_is_only_nb = 1 THEN
                          (CASE
                            WHEN ph.start_date BETWEEN g_date_begin AND g_date_end THEN
                             1
                            ELSE
                             0
                          END)
                         ELSE
                          1
                       END) = 1*/
                    --если ведомость только по доплатам ОПС, объемы по Жизни нам не нужны
                 AND g_is_ops_retention = 0
                    --если скидка для сотрудников, договор в объемы попадать не должен
                 AND nvl(pp.discount_f_id, 0) NOT IN
                     (SELECT disc.discount_f_id FROM discount_f disc WHERE disc.brief = 'EMPLOYEE')
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
                                 AND varh.ag_roll_header_id = var.ag_roll_header_id))) vol
       WHERE max_reg_date <= g_pay_reg_date
         AND payment_date < nvl(break_ad_date, to_date('31.12.2999', 'DD.MM.YYYY'))
         AND payment_date >= nvl(begin_ad_date, to_date('01.01.1999', 'DD.MM.YYYY'))
         AND (nvl(ag_contract_header_id, 0) != 30707667 OR
             payment_date >= to_date('26.07.2011', 'DD.MM.YYYY'))
            /* Капля П. Заменил на эквивалентное.
            (CASE
                  WHEN ag_contract_header_id = 30707667 THEN
                   (CASE
                     WHEN payment_date >= to_date('26.07.2011', 'DD.MM.YYYY') THEN
                      1
                     ELSE
                      0
                   END)
                  ELSE
                   1
                END) = 1*/
         AND (fund = g_fund_rur OR fund != g_fund_rur AND NOT EXISTS
              (SELECT NULL
                 FROM ins.ag_volume      agv
                     ,ins.ag_volume_type avt
                WHERE agv.epg_payment = epg
                  AND agv.ag_volume_type_id = avt.ag_volume_type_id
                  AND avt.ag_volume_type_id = g_vt_life));
    /* Капля П. Заменил на эквивалентное.
    (CASE
          WHEN fund <> g_fund_rur
               AND (SELECT COUNT(*)
                      FROM ins.ag_volume      agv
                          ,ins.ag_volume_type avt
                     WHERE agv.epg_payment = epg
                       AND agv.ag_volume_type_id = avt.ag_volume_type_id
                       AND avt.ag_volume_type_id = g_vt_life) = 0 THEN
           1
          WHEN fund = g_fund_rur THEN
           1
          ELSE
           0
        END) = 1;*/
    /*Заявка №299465*/
    --IF g_date_begin < TO_DATE('26.12.2013','dd.mm.yyyy') THEN
    calc_b2b_volume;
    --END IF;
    calc_deduction;
  
    /* 
      Заявка №348386
      
      Удаляем записи в объемах, связанные с отмененными платежами MPOS.
    */
    delete_canceled_mpos_payments;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                                 ,par_trace_subobj_name => 'CALC_VOLUME_BANK');
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_volume_vedom;

  -- Author  : VESELEK
  -- Created : 02.10.2012
  -- Purpose : Подготовка и заполнение ведомости объемов RLA
  PROCEDURE calc_volume_rla(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(25) := 'calc_volume_RLA';
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет объемов RLA');
    --Т.к. механизм ведомостей общий, а здесь АД мне не нужен то здесь будет заглшка
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      NULL;
    END IF;
  
    INSERT INTO ven_ag_volume
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
      ,payment_date_orig)
      SELECT CASE
               WHEN (epg_st <> g_st_paid AND
                    (epg_payed / rev_amount < 0.999 OR payment_date < '26.08.2010') AND
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
               ELSE
                CASE
                  WHEN vol.product_id IN (g_pr_familydep, g_pr_familydep_2011, g_pr_familydep_2014)
                       AND pay_term = g_pt_nonrecurring
                       AND greatest(conclude_date, payment_date, date_s) > '25.05.2011' THEN
                   g_vt_nonevol
                  WHEN vol.product_id IN (g_pr_familydep, g_pr_familydep_2011, g_pr_familydep_2014)
                       AND pay_period > 1 THEN
                   g_vt_nonevol
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
            ,g_roll_id
            ,ag_contract_header_id
            ,
             --ДС
             policy_header_id
            ,date_s
            ,conclude_date
            ,ins_period
            ,pay_term
            ,last_st
            ,active_st
            ,fund
            ,
             --ЭПГ
             epg
            ,epg_date
            ,pay_period
            ,epg_st
            ,epg_amt
            , --info
             --Платежный документ
             epg_pd_type
            , --info
             pd_copy_stat
            ,pay_doc
            ,pay_doc_cm
            ,payment_date
            ,
             --Проводки
             tplo_id
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
            ,
             --если определение ставки для конкретного pol_header_id возвращает 999, то считаем NBV как обычно, иначе этой функцией
             CASE
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
            ,payment_date_orig
        FROM (SELECT --ДС
               pad.ag_contract_header_id
              ,ph.policy_header_id
              ,ph.product_id
              ,pp.policy_id
              ,(SELECT agd.doc_date
                  FROM ins.ag_documents agd
                      ,ins.ag_doc_type  adt
                      ,ins.document     da
                 WHERE agd.ag_contract_header_id = pad.ag_contract_header_id
                   AND agd.ag_doc_type_id = adt.ag_doc_type_id
                   AND adt.brief = 'BREAK_AD'
                   AND da.document_id = agd.ag_documents_id
                   AND da.doc_status_ref_id NOT IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('PROJECT', 'CANCEL'))) break_ad_date
              ,(SELECT agh.date_begin
                  FROM ins.ag_contract_header agh
                 WHERE agh.ag_contract_header_id = pad.ag_contract_header_id) begin_ad_date
              ,ph.start_date date_s
              ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) ins_period
              ,pp.payment_term_id pay_term
              ,ph.doc_status_ref_id last_st
              ,doc.get_doc_status_id(ph.policy_id, '31.12.2999') active_st
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
              ,CASE
                 WHEN pp.payment_term_id = g_pt_monthly
                      AND pp.is_group_flag = 0
                      AND nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) NOT IN
                      (g_cm_direct_pay, g_cm_payer_pay)
                      AND
                      (ph.start_date > to_date('26.12.2010', 'dd.mm.yyyy') OR
                      (SELECT MAX(acp1.due_date)
                          FROM doc_set_off    dso1
                              ,ac_payment     acp1
                              ,ven_ac_payment epg_in
                              ,doc_templ      dt_in
                              ,doc_doc        dd_in
                              ,p_policy       pp_in
                         WHERE 1 = 1
                           AND pp_in.pol_header_id = ph.policy_header_id
                           AND pp_in.policy_id = dd_in.parent_id
                           AND dd_in.child_id = epg_in.payment_id
                           AND epg_in.doc_templ_id = dt_in.doc_templ_id
                           AND dt_in.brief = 'PAYMENT'
                           AND doc.get_doc_status_brief(epg_in.payment_id) = 'PAID'
                           AND epg_in.plan_date = (SELECT MIN(epg_in_in.plan_date)
                                                     FROM ven_ac_payment epg_in_in
                                                         ,doc_templ      dt_in_in
                                                         ,doc_doc        dd_in_in
                                                         ,p_policy       pp_in_in
                                                    WHERE epg_in_in.payment_id = dd_in_in.child_id
                                                      AND dd_in_in.parent_id = pp_in_in.policy_id
                                                      AND pp_in_in.pol_header_id = ph.policy_header_id
                                                      AND epg_in_in.doc_templ_id = dt_in_in.doc_templ_id
                                                      AND dt_in_in.brief = 'PAYMENT')
                           AND dso1.parent_doc_id = epg_in.payment_id
                           AND acp1.payment_id = dso1.child_doc_id
                           AND dso1.cancel_date IS NULL
                           AND doc.get_doc_status_id(acp1.payment_id) != g_st_annulated
                           AND acp1.payment_templ_id IN
                               (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) >
                      to_date('25.12.2010', 'dd.mm.yyyy')) THEN
                  coalesce((SELECT MIN(epg_pay_in.due_date)
                             FROM p_policy       pp_in
                                 ,doc_doc        dd_in
                                 ,ac_payment     epg_in
                                 ,doc_set_off    dso_in
                                 ,ven_ac_payment epg_pay_in
                                 ,doc_doc        dd2_in
                                 ,doc_set_off    dso2_in
                                 ,ven_ac_payment pay_doc_in
                            WHERE pp_in.pol_header_id = ph.policy_header_id
                              AND pp_in.policy_id = dd_in.parent_id
                              AND dd_in.child_id = epg_in.payment_id
                              AND epg_in.payment_id = dso_in.parent_doc_id
                              AND dso_in.child_doc_id = epg_pay_in.payment_id
                              AND dso_in.cancel_date IS NULL
                              AND epg_pay_in.payment_id = dd2_in.parent_id(+)
                              AND dd2_in.child_id = dso2_in.parent_doc_id(+)
                              AND dso2_in.child_doc_id = pay_doc_in.payment_id(+)
                              AND nvl(pay_doc_in.doc_templ_id, epg_pay_in.doc_templ_id) IN
                                  (g_dt_pp_direct_doc
                                  ,g_dt_pp_payer_doc /*g_cm_Direct_pay,g_cm_Payer_pay*/))
                          ,(SELECT MAX(acp1.due_date)
                             FROM doc_set_off dso1
                                 ,ac_payment  acp1
                            WHERE dso1.parent_doc_id = epg.payment_id
                              AND acp1.payment_id = dso1.child_doc_id
                              AND acp1.payment_templ_id IN
                                  (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)))
                 ELSE
                  (SELECT MAX(acp1.due_date)
                     FROM doc_set_off dso1
                         ,ac_payment  acp1
                    WHERE dso1.parent_doc_id = epg.payment_id
                      AND acp1.payment_id = dso1.child_doc_id
                      AND acp1.payment_templ_id IN
                          (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p))
               END payment_date
              ,epg_pd.due_date payment_date_orig
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
                          AND dpol.document_id = pol.policy_id
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))) THEN
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
                             AND dpol.document_id = pol.policy_id
                             AND dpol.doc_status_ref_id NOT IN
                                 (SELECT rf.doc_status_ref_id
                                    FROM ins.doc_status_ref rf
                                   WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                          AND dpol.doc_status_ref_id NOT IN
                              (SELECT rf.doc_status_ref_id
                                 FROM ins.doc_status_ref rf
                                WHERE rf.brief IN ('INDEXATING', 'CANCEL'))
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
                                       (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                                   AND EXISTS (SELECT NULL
                                          FROM ins.ag_volume agvf
                                         WHERE agvf.epg_payment = dso1.parent_doc_id)))) is_trans_annul
                FROM (SELECT *
                        FROM ins.p_pol_header pha
                            ,ins.document     d_pha
                       WHERE EXISTS (SELECT NULL
                                FROM ins.p_policy   pp1
                                    ,ins.doc_status ds1
                               WHERE pp1.pol_header_id = pha.policy_header_id
                                 AND pp1.policy_id = ds1.document_id
                                 AND ds1.doc_status_ref_id IN (g_st_curr))
                            --для RLA, чтобы был хотя бы раз Действующий (заявка №207098)
                         AND pha.last_ver_id = d_pha.document_id
                         AND d_pha.doc_status_ref_id NOT IN
                             (g_st_agrevision
                             ,g_st_new
                             ,g_st_underwr
                             ,g_st_print
                             ,g_st_getdoc
                             ,g_st_medo
                             ,g_st_reins
                             ,g_st_revision
                             ,g_st_to_agent
                             ,g_st_nostand
                             ,g_st_newterm
                             ,g_st_passdoc
                             ,g_st_recdoc
                             ,g_st_recnewterm
                             ,g_st_renew
                             ,g_st_declrenew)
                      --По письму Махониной ограничения по статусам
                      ) ph
                    ,(SELECT *
                        FROM ins.p_policy_agent_doc pada
                            ,ins.document           d_pada
                       WHERE pada.p_policy_agent_doc_id = d_pada.document_id
                         AND d_pada.doc_status_ref_id != g_st_error) pad
                    ,ins.ven_p_policy pp
                    ,ins.doc_doc pp_dd
                    ,(SELECT *
                        FROM ins.ac_payment epga
                            ,ins.document   d_epga
                       WHERE epga.plan_date <= g_date_end
                         AND d_epga.doc_templ_id = g_dt_epg_doc
                         AND d_epga.document_id = epga.payment_id
                         AND d_epga.doc_status_ref_id != g_st_new) epg
                    ,ins.doc_set_off epg_dso
                    ,(SELECT *
                        FROM ins.ac_payment epg_pda
                       WHERE epg_pda.payment_templ_id IN
                             (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) epg_pd
                    ,ins.doc_doc pd_dd
                    ,ins.ac_payment epg_pd_copy
                    ,ins.doc_set_off pd_dso
                    ,ins.oper o
                    ,(SELECT * FROM ins.trans ta WHERE ta.dt_account_id = 122) t
                    ,ins.p_cover pc
                    ,ins.t_prod_line_option tplo
                    ,(SELECT *
                        FROM ins.ac_payment pp_pda
                       WHERE (pp_pda.payment_templ_id IN (g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p) OR
                             pp_pda.payment_templ_id IS NULL)) pp_pd
               WHERE 1 = 1
                    --AND ph.policy_header_id IN (29938274,29842700,27336509)
                    --AND ph.ids in (1920134021)
                 AND ph.policy_header_id = pp.pol_header_id
                 AND ph.policy_header_id = pad.policy_header_id
                 AND (ph.sales_channel_id IN (g_sc_rla) OR pad.ag_contract_header_id = 10146042)
                 AND CASE
                       WHEN epg_pd.due_date < ph.start_date THEN
                        ph.start_date
                       ELSE
                        (SELECT MAX(acp1.due_date)
                           FROM doc_set_off dso1
                               ,ac_payment  acp1
                          WHERE dso1.parent_doc_id = epg.payment_id
                            AND acp1.payment_id = dso1.child_doc_id
                            AND acp1.payment_templ_id IN
                                (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p))
                     END BETWEEN pad.date_begin AND pad.date_end - 1 / 24 / 3600
                 AND pp.policy_id = pp_dd.parent_id
                 AND pp_dd.child_id = epg.payment_id
                    /*Ограничение: если есть ЭПГ от той же даты в статусе К оплате,
                      то попадать даже Оплаченный не должен
                    */
                 AND NOT EXISTS
               (SELECT NULL
                        FROM ins.p_policy       pol
                            ,ins.doc_doc        dd
                            ,ins.ac_payment     ac
                            ,ins.document       dac
                            ,ins.doc_templ      dtt
                            ,ins.doc_status_ref rfac
                       WHERE pol.pol_header_id = pp.pol_header_id
                         AND pol.policy_id = dd.parent_id
                         AND dd.child_id = ac.payment_id
                         AND ac.plan_date = epg.plan_date
                         AND ac.payment_id = dac.document_id
                         AND dac.doc_status_ref_id = rfac.doc_status_ref_id
                         AND rfac.brief IN ('TO_PAY', 'NEW')
                         AND dac.doc_templ_id = dtt.doc_templ_id
                         AND dtt.brief = 'PAYMENT')
                    /**/
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
                 AND tplo.description NOT IN
                     ('Административные издержки'
                     ,'Административные издержки на восстановление')
                    --Ограничения для Аннулированных и опять созданных ЭПГ
                 AND NOT EXISTS
               (SELECT NULL
                        FROM p_policy           pan
                            ,doc_doc            dan
                            ,ac_payment         acan
                            ,document           ddan
                            ,doc_status         dsan
                            ,doc_status_ref     rf
                            ,ins.ag_volume      agvan
                            ,ins.ag_volume_type avta
                       WHERE pan.pol_header_id = ph.policy_header_id
                         AND dan.parent_id = pan.policy_id
                         AND dan.child_id = acan.payment_id
                         AND acan.plan_date = epg.plan_date
                         AND acan.payment_id = ddan.document_id
                         AND ddan.doc_status_id = dsan.doc_status_id
                         AND rf.doc_status_ref_id = ddan.doc_status_ref_id
                         AND rf.brief = 'ANNULATED'
                         AND agvan.epg_payment = acan.payment_id
                         AND avta.ag_volume_type_id = agvan.ag_volume_type_id
                         AND avta.ag_volume_type_id <> 4)
                    -- Огрнаничения для отсечения старых данных
                 AND ((ph.start_date < '26.08.2009' AND
                     (epg.plan_date > '26.04.2010' AND
                     (SELECT MAX(acp1.due_date)
                           FROM doc_set_off dso1
                               ,ac_payment  acp1
                          WHERE dso1.parent_doc_id = epg.payment_id
                            AND acp1.payment_id = dso1.child_doc_id
                            AND acp1.payment_templ_id IN
                                (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) > CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) =
                            g_cm_noncash_pay THEN
                        '25.04.2010'
                       ELSE
                        '10.05.2010'
                     END)) OR
                     (ph.start_date >= '26.08.2009' AND
                     ((epg.plan_date > '26.04.2010' AND
                     (SELECT MAX(acp1.due_date)
                            FROM doc_set_off dso1
                                ,ac_payment  acp1
                           WHERE dso1.parent_doc_id = epg.payment_id
                             AND acp1.payment_id = dso1.child_doc_id
                             AND acp1.payment_templ_id IN
                                 (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)) > CASE
                       WHEN nvl(pp_pd.collection_metod_id, epg_pd.collection_metod_id) =
                            g_cm_noncash_pay THEN
                        '25.04.2010'
                       ELSE
                        '10.05.2010'
                     END) OR (SELECT MIN(ds1.start_date)
                                   FROM p_policy   pp1
                                       ,doc_status ds1
                                  WHERE pp1.pol_header_id = ph.policy_header_id
                                    AND pp1.policy_id = ds1.document_id
                                    AND ds1.doc_status_ref_id IN (g_st_concluded, g_st_curr)) >=
                     '12.05.2010' OR (epg.plan_date = '26.04.2010' AND epg.payment_number <> 1))))
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
                     (SELECT MAX(acp1.due_date)
                         FROM doc_set_off dso1
                             ,ac_payment  acp1
                        WHERE dso1.parent_doc_id = epg.payment_id
                          AND acp1.payment_id = dso1.child_doc_id
                          AND dso1.cancel_date IS NULL
                          AND doc.get_doc_status_id(acp1.payment_id) != g_st_annulated
                          AND acp1.payment_templ_id IN
                              (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                             /*211382 - Сделайте, пожалуйста, так, чтобы не под каким видом 
                             два графика от одной даты в разные отчеты не попадало.  А попадали 
                             оба в отчет за тот период, в котором оба графика от одной даты 
                             стали оплачены*/
                          AND NOT EXISTS
                        (SELECT NULL
                                 FROM ins.p_policy       pola
                                     ,ins.doc_doc        dda
                                     ,ins.ac_payment     aca
                                     ,ins.document       da
                                     ,ins.doc_templ      dta
                                     ,ins.doc_status_ref rfa
                                     ,ins.doc_set_off    sof
                                     ,ins.ac_payment     ac_dso
                                     ,ins.document       d_ac
                                WHERE pola.pol_header_id = ph.policy_header_id
                                  AND pola.policy_id = dda.parent_id
                                  AND dda.child_id = aca.payment_id
                                  AND aca.payment_id = da.document_id
                                  AND da.doc_templ_id = dta.doc_templ_id
                                  AND dta.brief = 'PAYMENT'
                                  AND da.doc_status_ref_id = rfa.doc_status_ref_id
                                  AND rfa.brief = 'PAID'
                                  AND aca.plan_date = epg.plan_date
                                  AND aca.payment_id != epg.payment_id
                                  AND sof.parent_doc_id = aca.payment_id
                                  AND ac_dso.payment_id = sof.child_doc_id
                                  AND sof.cancel_date IS NULL
                                  AND ac_dso.payment_id = d_ac.document_id
                                  AND d_ac.doc_status_ref_id != g_st_annulated
                                  AND ac_dso.payment_templ_id IN
                                      (g_apt_a7, g_apt_pd4, g_apt_pp, g_apt_pp_dir_p, g_apt_pp_payer_p)
                                  AND ac_dso.due_date > g_pay_date)) <= g_pay_date)
                    
                    --если ведомость только по доплатам ОПС, объемы по Жизни нам не нужны
                 AND g_is_ops_retention = 0
                    --Ограничения по учтенным объемам
                 AND NOT EXISTS (SELECT NULL FROM ag_volume av WHERE av.trans_id = t.trans_id)) vol
       WHERE max_reg_date <= g_pay_reg_date
         AND payment_date < nvl(break_ad_date, to_date('31.12.2999', 'DD.MM.YYYY'))
         AND payment_date >= nvl(begin_ad_date, to_date('01.01.1999', 'DD.MM.YYYY'))
         AND (CASE
               WHEN ag_contract_header_id = 30707667 THEN
                (CASE
                  WHEN payment_date >= to_date('26.07.2011', 'DD.MM.YYYY') THEN
                   1
                  ELSE
                   0
                END)
               ELSE
                1
             END) = 1
         AND (CASE
               WHEN fund <> g_fund_rur
                    AND (SELECT COUNT(*)
                           FROM ins.ag_volume      agv
                               ,ins.ag_volume_type avt
                          WHERE agv.epg_payment = epg
                            AND agv.ag_volume_type_id = avt.ag_volume_type_id
                            AND avt.ag_volume_type_id = g_vt_life) = 0 THEN
                1
               WHEN fund = g_fund_rur THEN
                1
               ELSE
                0
             END) = 1;
  
    /*Calc_b2b_volume;*/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_volume_rla;
  /**/
  -- Author  : VESELEK
  -- Created : 07.11.2012 10:46:57
  -- Purpose : Подготовка и заполнение ведомости объемов для RLP
  PROCEDURE calc_volume_rlp(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(25) := 'calc_volume_RLP';
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет объемов RLP');
    --Т.к. механизм ведомостей общий, а здесь АД мне не нужен то здесь будет заглшка
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      NULL;
    END IF;
  
    INSERT INTO ven_ag_volume_rlp
      (ag_volume_type_id
      ,ag_roll_id
      ,ag_contract_header_id
      ,policy_header_id
      ,product_id
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
      ,nbv_coef
      ,is_nbv
      ,vol_sav)
      SELECT agv.ag_volume_type_id
            ,g_roll_id
            ,apw.ag_contract_header_id
            ,agv.policy_header_id
            ,ph.product_id
            ,agv.date_begin
            ,agv.conclude_date
            ,agv.ins_period
            ,agv.payment_term_id
            ,agv.last_status
            ,agv.active_status
            ,agv.fund
            ,agv.epg_payment
            ,agv.epg_date
            ,agv.pay_period
            ,agv.epg_status
            ,agv.epg_ammount
            ,agv.epg_pd_type
            ,agv.pd_copy_status
            ,agv.pd_payment
            ,agv.pd_collection_method
            ,agv.payment_date
            ,agv.nbv_coef
            ,agv.is_nbv
            ,SUM(apv.vol_amount * apv.vol_rate) vol_sav
        FROM ins.ag_roll rl
            ,(SELECT arha.ag_roll_header_id
                FROM ins.ag_roll_header arha
                    ,ins.ag_roll_type   arta
               WHERE arha.ag_roll_type_id = arta.ag_roll_type_id
                 AND arta.brief IN ('OAV_0510', 'MnD_PREM')
                 AND arha.date_end BETWEEN g_date_begin AND g_date_end) arh
            ,ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det apd
            ,ins.ag_perf_work_vol apv
            ,ins.ag_volume agv
            ,(SELECT pha.product_id
                    ,pha.last_ver_id
                    ,pha.policy_header_id
                FROM ins.p_pol_header   pha
                    ,ins.t_product      proda
                    ,ins.document       da
                    ,ins.doc_status_ref rfa
               WHERE pha.product_id = proda.product_id
                 AND proda.brief IN ('END'
                                    ,'END_2'
                                    ,'CHI'
                                    ,'CHI_2'
                                    ,'PEPR'
                                    ,'PEPR_2'
                                    ,'ACC163'
                                    ,'ACC164'
                                    ,'APG'
                                    ,'Investor'
                                    ,'InvestorPlus'
                                    ,'INVESTOR_LUMP'
                                    ,'INVESTOR_LUMP_OLD'
                                    ,'LOD'
                                    ,'OPS_Plus'
                                    ,'OPS_Plus_New'
                                    ,'OPS_Plus_New_2014'
                                    ,'Family_Dep'
                                    ,'Family_Dep_2011'
                                    ,'Family_Dep_2014'
                                    ,'TERM'
                                    ,'TERM_2'
                                    ,'SF_AVCR'
                                    ,'GN'
                                    ,'Fof_Prot'
                                    ,'ACC')
                 AND da.document_id = pha.last_ver_id
                 AND da.doc_status_ref_id = rfa.doc_status_ref_id
                 AND rfa.brief NOT IN ('BREAK', 'CANCEL')) ph
       WHERE rl.ag_roll_header_id = arh.ag_roll_header_id
         AND apw.ag_roll_id = rl.ag_roll_id
         AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
         AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
         AND agv.ag_volume_id = apv.ag_volume_id
         AND agv.policy_header_id = ph.policy_header_id
            --Ограничения по учтенным объемам
         AND NOT EXISTS
       (SELECT NULL FROM ins.ag_volume_rlp av WHERE av.epg_payment = agv.epg_payment)
       GROUP BY agv.ag_volume_type_id
               ,g_roll_id
               ,apw.ag_contract_header_id
               ,agv.policy_header_id
               ,ph.product_id
               ,agv.date_begin
               ,agv.conclude_date
               ,agv.ins_period
               ,agv.payment_term_id
               ,agv.last_status
               ,agv.active_status
               ,agv.fund
               ,agv.epg_payment
               ,agv.epg_date
               ,agv.pay_period
               ,agv.epg_status
               ,agv.epg_ammount
               ,agv.epg_pd_type
               ,agv.pd_copy_status
               ,agv.pd_payment
               ,agv.pd_collection_method
               ,agv.payment_date
               ,agv.nbv_coef
               ,agv.is_nbv;
    UPDATE ins.ag_volume_rlp av
       SET av.ag_roll_id = g_roll_id
          ,av.is_future  = 0
     WHERE av.is_future = 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_volume_rlp;

  /**/
  -- Author  : Веселуха Е.В.
  -- Created : 21.08.2013
  -- Purpose : Подготовка и заполнение ведомости объемов для Банков
  PROCEDURE calc_banks(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(25) := 'calc_volume_bank';
  
    PROCEDURE prepare_temporary_data IS
    BEGIN
      DELETE FROM tmp_ag_bank_com_epg;
      DELETE FROM tmp_ag_bank_com_ph;
    
      INSERT INTO tmp_ag_bank_com_epg
        WITH payment AS
         (SELECT /*+ LEADING (dc)*/
           dc.document_id
            FROM ac_payment pm
                ,document   dc
           WHERE pm.due_date BETWEEN g_date_begin AND g_date_end
             AND pm.payment_id = dc.document_id
             AND dc.doc_templ_id = g_dt_pp_noncash_doc)
        SELECT dso_e.parent_doc_id
          FROM doc_set_off dso_e
              ,document    dc
         WHERE dso_e.child_doc_id IN (SELECT document_id FROM payment)
           AND dso_e.parent_doc_id = dc.document_id
           AND dc.doc_templ_id = 4
        UNION ALL
        SELECT dso_e.parent_doc_id
          FROM doc_set_off dso_pd
              ,doc_doc     dd
              ,doc_set_off dso_e
         WHERE dso_pd.child_doc_id IN (SELECT document_id FROM payment)
           AND dso_pd.parent_doc_id = dd.child_id
           AND dd.parent_id = dso_e.child_doc_id;
    
      -- Неявно коммитит!
      dbms_stats.gather_table_stats(ownname => 'INS'
                                   ,tabname => 'TMP_AG_BANK_COM_EPG'
                                   ,cascade => FALSE);
    
      INSERT INTO tmp_ag_bank_com_ph
        SELECT /*+ LEADING (dso_pd) INDEX (epga PK_AC_PAYMENT)
                                                                                                                               INDEX(pp PK_P_POLICY) INDEX(pha PK_P_POL_HEADER)
                                                                                                                               INDEX(pad IX_P_POLICY_AGENT_DOC_01)*/
         pha.policy_header_id
        ,pha.fund_id
        ,pha.start_date
        ,pha.product_id
        ,pha.policy_id
        ,pha.sales_channel_id
        ,d_ph.doc_status_ref_id   ref_ph_id
        ,d_pp.doc_status_ref_id   ref_pp_id
        ,ch.ag_contract_header_id
        ,epga.payment_id
        ,epga.plan_date
        ,epga.rev_amount
        ,epga.amount
        ,pp.payment_term_id
        ,pp.end_date
          FROM (SELECT /*+ NO_MERGE*/
                 ch.ag_contract_header_id
                  FROM ins.ag_contract_header ch
                 WHERE ch.select_commission_by = 0
                   AND ch.ag_contract_header_id NOT IN
                       (SELECT ae.ag_contract_header_id
                          FROM ins.exclude_agents ae
                         WHERE ae.ag_roll_id = g_roll_id)) ch
              ,ins.p_policy_agent_doc pad
              ,ins.p_pol_header pha
              ,ins.document d_pad
              ,ins.document d_ph
              ,ins.document d_pp
              ,ins.ac_payment epga
              ,ins.document d_epg
              ,ins.p_policy pp
              ,ins.doc_doc pp_dd
         WHERE pha.last_ver_id = d_ph.document_id
           AND pha.policy_id = d_pp.document_id
           AND pha.policy_header_id = pad.policy_header_id
              --AND pha.ids IN (2240182492, 2240183030, 2240183425, 2701656394)
           AND pad.p_policy_agent_doc_id = d_pad.document_id
           AND pad.ag_contract_header_id = ch.ag_contract_header_id
           AND pha.policy_header_id = pp.pol_header_id
           AND pp.policy_id = pp_dd.parent_id
           AND pp_dd.child_id = epga.payment_id
           AND epga.payment_id = d_epg.document_id
           AND d_pad.doc_status_ref_id = g_st_curr
           AND pha.sales_channel_id IN (g_sc_bank, g_sc_br, g_sc_br_wdisc, g_sc_mbg)
           AND d_pp.doc_status_ref_id NOT IN (g_st_new
                                             ,g_st_cancel
                                             ,g_st_project
                                             ,g_st_b2b_pending
                                             ,g_st_b2b_calculated
                                             ,g_st_waiting_for_payment)
           AND epga.payment_id IN (SELECT dso_pd.parent_doc_id FROM tmp_ag_bank_com_epg dso_pd);
    
      -- Неявно коммитит!
      dbms_stats.gather_table_stats(ownname => 'INS'
                                   ,tabname => 'TMP_AG_BANK_COM_PH'
                                   ,cascade => FALSE);
    END prepare_temporary_data;
  
    PROCEDURE insert_by_pol_start_date IS
    BEGIN
      /* По дате начала ДС */
    
      INSERT INTO ag_volume_bank
        (ag_volume_bank_id
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_start_date
        ,insurance_period
        ,payment_term_id
        ,fund_id
        ,epg_id
        ,payment_period
        ,assured_age
        ,trans_id
        ,trans_amount
        ,ag_roll_id
        ,p_cover_id
        ,product_line_id
        ,sav)
        SELECT /*+ LEADING (vol)*/
         sq_ag_volume_bank.nextval
        ,vol.ag_contract_header_id
        ,vol.policy_header_id
        ,vol.policy_start_date
        ,vol.insurance_period
        ,vol.payment_term_id
        ,vol.fund_id
        ,vol.epg_id
        ,vol.payment_period
        ,pc.insured_age
        ,t.trans_id
        ,t.trans_amount
        ,g_roll_id
        ,pc.p_cover_id
        ,tplo.product_line_id
        ,coalesce((SELECT MAX(el.sav) keep(dense_rank LAST ORDER BY el.estimated_liabilities_id)
                    FROM estimated_liabilities el
                   WHERE el.p_cover_id = pc.p_cover_id
                     AND el.payment_period = vol.payment_period)
                 ,pkg_ag_agent_calc.get_sav_bank(vol.ag_contract_header_id
                                                ,tplo.product_line_id
                                                ,pc.ins_amount
                                                ,vol.insurance_period
                                                ,vol.payment_period
                                                ,su.gender
                                                ,pc.insured_age
                                                ,vol.policy_start_date
                                                ,CASE
                                                   WHEN pt.is_periodical = 1 THEN
                                                    2
                                                   ELSE
                                                    1
                                                 END
                                                ,nvl(se.fee * t.acc_rate, 0)))
          FROM (SELECT /*+ LEADING (ph)*/
                 ph.ag_contract_header_id
                ,ph.policy_header_id
                ,ph.start_date AS policy_start_date
                ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                ,pp.payment_term_id
                ,ph.fund_id
                ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date) / 12) + 1 AS payment_period
                ,epg.payment_id epg_id
                ,decode(ph.fund_id, 122, epg.amount, epg.rev_amount) rev_amount
                ,CASE d.doc_templ_id
                   WHEN g_dt_comiss_retention THEN
                    epg_dso.doc_set_off_id
                   ELSE
                    nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                 END AS doc_set_off_id
                ,(SELECT coalesce(MAX(CASE
                                        WHEN dso_pd.set_off_amount / epg.amount >= 0.99 THEN
                                         CASE dc_pp_.doc_templ_id
                                           WHEN g_dt_comiss_retention THEN
                                            ppv_.due_date
                                           ELSE
                                            nvl(ppv.due_date, ppv_.due_date)
                                         END
                                      END)
                                 ,MAX(CASE dc_pp_.doc_templ_id
                                        WHEN g_dt_comiss_retention THEN
                                         ppv_.due_date
                                        ELSE
                                         nvl(ppv.due_date, ppv_.due_date)
                                      END))
                    FROM doc_set_off dso_pd
                        ,doc_doc     dd_pd
                        ,doc_set_off dso_pp
                        ,document    dc_pp
                        ,document    dc_pp_
                        ,ac_payment  ppv
                        ,ac_payment  ppv_
                   WHERE dso_pd.parent_doc_id = epg.payment_id
                     AND dso_pd.child_doc_id = ppv_.payment_id
                     AND dso_pd.child_doc_id = dd_pd.parent_id(+)
                     AND dd_pd.child_id = dso_pp.parent_doc_id(+)
                     AND dso_pp.child_doc_id = ppv.payment_id(+)
                     AND dso_pp.child_doc_id = dc_pp.document_id(+)
                     AND dso_pd.child_doc_id = dc_pp_.document_id
                     AND (dc_pp_.doc_templ_id = g_dt_pp_noncash_doc OR
                         dc_pp.doc_templ_id = g_dt_pp_noncash_doc)) payment_date
                  FROM (SELECT /*+ NO_MERGE LEADING(pha) INDEX(pad IX_P_POLICY_AGENT_DOC_01)*/
                         pha.policy_header_id
                        ,pha.fund_id
                        ,pha.start_date
                        ,pha.product_id
                        ,pha.policy_id
                        ,pha.sales_channel_id
                        ,d_ph.doc_status_ref_id   ref_ph_id
                        ,d_pp.doc_status_ref_id   ref_pp_id
                        ,ch.ag_contract_header_id
                          FROM ins.ag_contract_header ch
                              ,ins.p_policy_agent_doc pad
                              ,ins.p_pol_header       pha
                              ,ins.document           d_pad
                              ,ins.document           d_ph
                              ,ins.document           d_pp
                         WHERE pha.last_ver_id = d_ph.document_id
                           AND pha.policy_id = d_pp.document_id
                           AND pha.policy_header_id = pad.policy_header_id
                              --AND pha.ids IN (2240182492, 2240183030, 2240183425, 2701656394)
                           AND pad.p_policy_agent_doc_id = d_pad.document_id
                           AND pad.ag_contract_header_id = ch.ag_contract_header_id
                           AND ch.select_commission_by = 1
                           AND d_pad.doc_status_ref_id = g_st_curr
                           AND pha.sales_channel_id IN (g_sc_bank, g_sc_br, g_sc_br_wdisc, g_sc_mbg)
                           AND pha.start_date BETWEEN g_date_begin AND g_date_end
                           AND d_pp.doc_status_ref_id NOT IN
                               (g_st_new
                               ,g_st_cancel
                               ,g_st_project
                               ,g_st_b2b_pending
                               ,g_st_b2b_calculated
                               ,g_st_waiting_for_payment)
                           AND NOT EXISTS
                         (SELECT NULL
                                  FROM ins.exclude_agents ae
                                 WHERE ae.ag_contract_header_id = pad.ag_contract_header_id
                                   AND ae.ag_roll_id = g_roll_id)) ph
                      ,ins.p_policy pp
                      ,ins.doc_doc pp_dd
                      ,(SELECT *
                          FROM ins.ac_payment epga
                              ,ins.document   d_epg
                         WHERE d_epg.doc_templ_id = g_dt_epg_doc
                           AND epga.payment_id = d_epg.document_id
                           AND d_epg.doc_status_ref_id != g_st_new) epg
                      ,ins.doc_set_off epg_dso
                      ,ins.doc_doc pd_dd
                      ,ins.ac_payment epg_pd_copy
                      ,ins.doc_set_off pd_dso
                      ,ins.document d
                 WHERE ph.policy_header_id = pp.pol_header_id
                   AND pp.policy_id = pp_dd.parent_id
                   AND pp_dd.child_id = epg.payment_id
                   AND epg.payment_id = epg_dso.parent_doc_id
                   AND epg_dso.child_doc_id = d.document_id
                   AND epg_dso.child_doc_id = pd_dd.parent_id(+)
                   AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                   AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                      --Ограничения для Аннулированных и опять созданных ЭПГ
                   AND NOT EXISTS (SELECT /*+ LEADING (pan dan acan ddan dsan agvan) USE_NL(agvan)*/
                         NULL
                          FROM p_policy       pan
                              ,doc_doc        dan
                              ,ac_payment     acan
                              ,document       ddan
                              ,doc_status     dsan
                              ,doc_status_ref rf
                              ,ag_volume_bank agvan
                         WHERE pan.pol_header_id = ph.policy_header_id
                           AND dan.parent_id = pan.policy_id
                           AND dan.child_id = acan.payment_id
                           AND acan.plan_date = epg.plan_date
                           AND acan.payment_id = ddan.document_id
                           AND ddan.doc_status_id = dsan.doc_status_id
                           AND rf.doc_status_ref_id = ddan.doc_status_ref_id
                           AND rf.brief = 'ANNULATED'
                           AND agvan.epg_id = acan.payment_id)) vol
              ,ins.oper o
              ,(SELECT tra.oper_id
                      ,tra.obj_uro_id
                      ,tra.trans_amount
                      ,tra.trans_id
                      ,tra.reg_date
                      ,tra.acc_rate
                  FROM ins.trans tra
                 WHERE tra.dt_account_id IN (122, 55)) t
              ,ins.p_cover pc
              ,ins.as_assured su
              ,ins.as_asset se
              ,ins.t_prod_line_option tplo
              ,t_payment_terms pt
         WHERE o.document_id = vol.doc_set_off_id
           AND t.oper_id = o.oper_id
           AND pc.p_cover_id = t.obj_uro_id
           AND pc.t_prod_line_option_id = tplo.id
           AND pc.as_asset_id = su.as_assured_id
           AND pc.as_asset_id = se.as_asset_id
           AND vol.payment_term_id = pt.id
           AND tplo.description <> 'Административные издержки'
              --Ограничения по учтенным объемам
           AND NOT EXISTS
         (SELECT NULL FROM ag_volume_bank av WHERE av.trans_id = t.trans_id)
           AND (vol.fund_id = g_fund_rur OR NOT EXISTS
                (SELECT NULL FROM ins.ag_volume_bank agv WHERE agv.epg_id = vol.epg_id));
    END insert_by_pol_start_date;
  
    PROCEDURE insert_by_pp_date IS
    BEGIN
      /* По дате ПП */
      INSERT INTO ag_volume_bank
        (ag_volume_bank_id
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_start_date
        ,insurance_period
        ,payment_term_id
        ,fund_id
        ,epg_id
        ,payment_period
        ,assured_age
        ,trans_id
        ,trans_amount
        ,ag_roll_id
        ,p_cover_id
        ,product_line_id
        ,sav)
        SELECT /*+ LEADING (vol) INDEX(o IX_OPER_DOCUMENT)
                                                                                                                                   INDEX(t IX_TRANS_OPER)*/
         sq_ag_volume_bank.nextval
        ,vol.ag_contract_header_id
        ,vol.policy_header_id
        ,vol.policy_start_date
        ,vol.insurance_period
        ,vol.payment_term_id
        ,vol.fund_id
        ,vol.epg_id
        ,vol.payment_period
        ,pc.insured_age
        ,t.trans_id
        ,t.trans_amount
        ,g_roll_id
        ,pc.p_cover_id
        ,tplo.product_line_id
        ,coalesce((SELECT MAX(el.sav) keep(dense_rank LAST ORDER BY el.estimated_liabilities_id)
                    FROM estimated_liabilities el
                   WHERE el.p_cover_id = pc.p_cover_id
                     AND el.payment_period = vol.payment_period)
                 ,pkg_ag_agent_calc.get_sav_bank(vol.ag_contract_header_id
                                                ,tplo.product_line_id
                                                ,pc.ins_amount
                                                ,vol.insurance_period
                                                ,vol.payment_period
                                                ,su.gender
                                                ,pc.insured_age
                                                ,vol.policy_start_date
                                                ,CASE
                                                   WHEN pt.is_periodical = 1 THEN
                                                    2
                                                   ELSE
                                                    1
                                                 END
                                                ,nvl(se.fee * t.acc_rate, 0)))
          FROM (SELECT /*+ NO_MERGE*/
                 *
                  FROM (SELECT ph.ag_contract_header_id
                              ,ph.policy_header_id
                              ,ph.start_date AS policy_start_date
                              ,ROUND(MONTHS_BETWEEN(ph.end_date, ph.start_date) / 12) insurance_period
                              ,ph.payment_term_id
                              ,ph.fund_id
                              ,FLOOR(MONTHS_BETWEEN(ph.plan_date, ph.start_date) / 12) + 1 AS payment_period
                              ,ph.payment_id epg_id
                              ,decode(ph.fund_id, 122, ph.amount, ph.rev_amount) rev_amount
                              ,CASE d.doc_templ_id
                                 WHEN g_dt_comiss_retention THEN
                                  epg_dso.doc_set_off_id
                                 ELSE
                                  nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                               END AS doc_set_off_id
                              ,(SELECT nvl(MAX(CASE
                                                 WHEN dso_pd.set_off_amount / ph.amount >= 0.99 THEN
                                                  CASE dc_pp_.doc_templ_id
                                                    WHEN g_dt_comiss_retention THEN
                                                     ppv_.due_date
                                                    ELSE
                                                     nvl(ppv.due_date, ppv_.due_date)
                                                  END
                                               END)
                                          ,MAX(CASE dc_pp_.doc_templ_id
                                                 WHEN g_dt_comiss_retention THEN
                                                  ppv_.due_date
                                                 ELSE
                                                  nvl(ppv.due_date, ppv_.due_date)
                                               END))
                                  FROM doc_set_off dso_pd
                                      ,ac_payment  ppv_
                                      ,document    dc_pp_
                                      ,doc_doc     dd_pd
                                      ,doc_set_off dso_pp
                                      ,ac_payment  ppv
                                      ,document    dc_pp
                                 WHERE dso_pd.parent_doc_id = ph.payment_id
                                   AND dso_pd.child_doc_id = ppv_.payment_id
                                      
                                   AND dso_pd.child_doc_id = dd_pd.parent_id(+)
                                   AND dd_pd.child_id = dso_pp.parent_doc_id(+)
                                   AND dso_pp.child_doc_id = ppv.payment_id(+)
                                   AND dso_pp.child_doc_id = dc_pp.document_id(+)
                                   AND dso_pd.child_doc_id = dc_pp_.document_id
                                   AND ((dc_pp.doc_templ_id = g_dt_pp_noncash_doc OR
                                       dc_pp_.doc_templ_id IS NULL) OR
                                       dc_pp_.doc_templ_id = g_dt_pp_noncash_doc)) payment_date
                          FROM ins.tmp_ag_bank_com_ph ph
                              ,ins.doc_set_off        epg_dso
                              ,ins.doc_doc            pd_dd
                              ,ins.doc_set_off        pd_dso
                              ,ins.document           d
                         WHERE ph.payment_id = epg_dso.parent_doc_id
                           AND epg_dso.child_doc_id = d.document_id
                           AND epg_dso.child_doc_id = pd_dd.parent_id(+)
                           AND pd_dd.child_id = pd_dso.parent_doc_id(+)
                              --Ограничения для Аннулированных и опять созданных ЭПГ
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_policy       pan
                                      ,doc_doc        dan
                                      ,ac_payment     acan
                                      ,document       ddan
                                      ,doc_status     dsan
                                      ,doc_status_ref rf
                                      ,ag_volume_bank agvan
                                 WHERE pan.pol_header_id = ph.policy_header_id
                                   AND dan.parent_id = pan.policy_id
                                   AND dan.child_id = acan.payment_id
                                   AND acan.plan_date = ph.plan_date
                                   AND acan.payment_id = ddan.document_id
                                   AND ddan.doc_status_id = dsan.doc_status_id
                                   AND rf.doc_status_ref_id = ddan.doc_status_ref_id
                                   AND rf.brief = 'ANNULATED'
                                   AND agvan.epg_id = acan.payment_id)) voli
                 WHERE voli.payment_date BETWEEN g_date_begin AND g_date_end) vol
              ,ins.oper o
              ,ins.trans t
              ,ins.p_cover pc
              ,ins.as_assured su
              ,ins.as_asset se
              ,ins.t_prod_line_option tplo
              ,t_payment_terms pt
         WHERE o.document_id = vol.doc_set_off_id
           AND t.oper_id = o.oper_id
           AND pc.p_cover_id = t.obj_uro_id
           AND pc.t_prod_line_option_id = tplo.id
           AND pc.as_asset_id = su.as_assured_id
           AND pc.as_asset_id = se.as_asset_id
           AND vol.payment_term_id = pt.id
           AND tplo.description <> 'Административные издержки'
           AND t.dt_account_id IN (122, 55)
              --Ограничения по учтенным объемам
           AND NOT EXISTS
         (SELECT NULL FROM ag_volume_bank av WHERE av.trans_id = t.trans_id)
           AND (vol.fund_id = g_fund_rur OR NOT EXISTS
                (SELECT NULL FROM ins.ag_volume_bank agv WHERE agv.epg_id = vol.epg_id));
    END insert_by_pp_date;
  
    PROCEDURE insert_by_pd4_date IS
    BEGIN
      /* По дате ПД4 */
      INSERT INTO ag_volume_bank
        (ag_volume_bank_id
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_start_date
        ,insurance_period
        ,payment_term_id
        ,fund_id
        ,epg_id
        ,payment_period
        ,assured_age
        ,trans_id
        ,trans_amount
        ,ag_roll_id
        ,p_cover_id
        ,product_line_id
        ,sav)
        SELECT /*+ LEADING (vol)*/
         sq_ag_volume_bank.nextval
        ,vol.ag_contract_header_id
        ,vol.policy_header_id
        ,vol.policy_start_date
        ,vol.insurance_period
        ,vol.payment_term_id
        ,vol.fund_id
        ,vol.epg_id
        ,vol.payment_period
        ,pc.insured_age
        ,t.trans_id
        ,t.trans_amount
        ,g_roll_id
        ,pc.p_cover_id
        ,tplo.product_line_id
        ,coalesce((SELECT MAX(el.sav) keep(dense_rank LAST ORDER BY el.estimated_liabilities_id)
                    FROM estimated_liabilities el
                   WHERE el.p_cover_id = pc.p_cover_id
                     AND el.payment_period = vol.payment_period)
                 ,pkg_ag_agent_calc.get_sav_bank(vol.ag_contract_header_id
                                                ,tplo.product_line_id
                                                ,pc.ins_amount
                                                ,vol.insurance_period
                                                ,vol.payment_period
                                                ,su.gender
                                                ,pc.insured_age
                                                ,vol.policy_start_date
                                                ,CASE
                                                   WHEN pt.is_periodical = 1 THEN
                                                    2
                                                   ELSE
                                                    1
                                                 END
                                                ,nvl(se.fee * t.acc_rate, 0)))
          FROM (SELECT /* + NO_MERGE */
                 *
                  FROM (SELECT ph.ag_contract_header_id
                              ,ph.policy_header_id
                              ,ph.start_date AS policy_start_date
                              ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                              ,pp.payment_term_id
                              ,ph.fund_id
                              ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date) / 12) + 1 AS payment_period
                              ,epg.payment_id epg_id
                              ,decode(ph.fund_id, 122, epg.amount, epg.rev_amount) rev_amount
                              ,nvl(pd_dso.doc_set_off_id, epg_dso.doc_set_off_id) AS doc_set_off_id
                              ,(SELECT nvl(MAX(CASE
                                                 WHEN (dso_pd.set_off_amount) / epg.amount >= 0.99 THEN
                                                  ppv.due_date
                                               END)
                                          ,MAX(ppv.due_date))
                                  FROM doc_set_off dso_pd
                                      ,ac_payment  ppv
                                      ,document    dc
                                 WHERE dso_pd.parent_doc_id = epg.payment_id
                                   AND dso_pd.child_doc_id = ppv.payment_id
                                   AND ppv.payment_id = dc.document_id
                                   AND dc.doc_templ_id IN (g_dt_pd4_doc, g_dt_a7_doc)) pd4_date
                          FROM (SELECT /* + NO_MERGE */
                                 pha.policy_header_id
                                ,pha.fund_id
                                ,pha.start_date
                                ,pha.product_id
                                ,pha.policy_id
                                ,pha.sales_channel_id
                                ,d_ph.doc_status_ref_id   ref_ph_id
                                ,d_pp.doc_status_ref_id   ref_pp_id
                                ,ch.ag_contract_header_id
                                  FROM ins.ag_contract_header ch
                                      ,ins.p_policy_agent_doc pad
                                      ,ins.p_pol_header       pha
                                      ,ins.document           d_pad
                                      ,ins.document           d_ph
                                      ,ins.document           d_pp
                                 WHERE pha.last_ver_id = d_ph.document_id
                                   AND pha.policy_id = d_pp.document_id
                                   AND pha.policy_header_id = pad.policy_header_id
                                      --AND pha.ids IN (2240182492, 2240183030, 2240183425, 2701656394)
                                   AND pad.p_policy_agent_doc_id = d_pad.document_id
                                   AND pad.ag_contract_header_id = ch.ag_contract_header_id
                                   AND ch.select_commission_by = 2
                                   AND d_pad.doc_status_ref_id = g_st_curr
                                      
                                   AND pha.sales_channel_id IN
                                       (g_sc_bank, g_sc_br, g_sc_br_wdisc, g_sc_mbg)
                                   AND d_pp.doc_status_ref_id NOT IN
                                       (g_st_new
                                       ,g_st_cancel
                                       ,g_st_project
                                       ,g_st_b2b_pending
                                       ,g_st_b2b_calculated
                                       ,g_st_waiting_for_payment)
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM ins.exclude_agents ae
                                         WHERE ae.ag_contract_header_id = pad.ag_contract_header_id
                                           AND ae.ag_roll_id = g_roll_id)) ph
                              ,ins.p_policy pp
                              ,ins.doc_doc pp_dd
                              ,(SELECT *
                                  FROM ins.ac_payment epga
                                      ,ins.document   d_epg
                                 WHERE d_epg.doc_templ_id = g_dt_epg_doc
                                      
                                   AND epga.payment_id = d_epg.document_id
                                   AND d_epg.doc_status_ref_id != g_st_new) epg
                              ,ins.doc_set_off epg_dso
                              ,ins.doc_doc pd_dd
                              ,ins.ac_payment epg_pd_copy
                              ,ins.doc_set_off pd_dso
                         WHERE ph.policy_header_id = pp.pol_header_id
                           AND pp.policy_id = pp_dd.parent_id
                           AND pp_dd.child_id = epg.payment_id
                           AND epg.payment_id = epg_dso.parent_doc_id
                           AND epg_dso.child_doc_id = pd_dd.parent_id(+)
                           AND pd_dd.child_id = epg_pd_copy.payment_id(+)
                           AND epg_pd_copy.payment_id = pd_dso.parent_doc_id(+)
                           AND EXISTS (SELECT NULL
                                  FROM doc_set_off dso_pd
                                      ,ac_payment  ppv
                                      ,document    dc
                                 WHERE dso_pd.parent_doc_id = epg.payment_id
                                   AND dso_pd.child_doc_id = ppv.payment_id
                                   AND ppv.payment_id = dc.document_id
                                   AND dc.doc_templ_id IN (g_dt_pd4_doc, g_dt_a7_doc)
                                   AND ppv.due_date BETWEEN g_date_begin AND g_date_end)
                              --Ограничения для Аннулированных и опять созданных ЭПГ
                           AND NOT EXISTS (SELECT NULL
                                  FROM p_policy       pan
                                      ,doc_doc        dan
                                      ,ac_payment     acan
                                      ,document       ddan
                                      ,doc_status     dsan
                                      ,doc_status_ref rf
                                      ,ag_volume_bank agvan
                                 WHERE pan.pol_header_id = ph.policy_header_id
                                   AND dan.parent_id = pan.policy_id
                                   AND dan.child_id = acan.payment_id
                                   AND acan.plan_date = epg.plan_date
                                   AND acan.payment_id = ddan.document_id
                                   AND ddan.doc_status_id = dsan.doc_status_id
                                   AND rf.doc_status_ref_id = ddan.doc_status_ref_id
                                   AND rf.brief = 'ANNULATED'
                                   AND agvan.epg_id = acan.payment_id)
                        
                        ) voli
                 WHERE voli.pd4_date BETWEEN g_date_begin AND g_date_end) vol
              ,ins.oper o
              ,(SELECT tra.oper_id
                      ,tra.obj_uro_id
                      ,tra.trans_amount
                      ,tra.trans_id
                      ,tra.reg_date
                      ,tra.acc_rate
                  FROM ins.trans tra
                 WHERE tra.dt_account_id IN (122, 55)) t
              ,ins.p_cover pc
              ,ins.as_assured su
              ,ins.as_asset se
              ,ins.t_prod_line_option tplo
              ,t_payment_terms pt
         WHERE o.document_id = vol.doc_set_off_id
           AND t.oper_id = o.oper_id
           AND pc.p_cover_id = t.obj_uro_id
           AND pc.t_prod_line_option_id = tplo.id
           AND pc.as_asset_id = su.as_assured_id
           AND pc.as_asset_id = se.as_asset_id
           AND vol.payment_term_id = pt.id
           AND tplo.description <> 'Административные издержки'
              --Ограничения по учтенным объемам
           AND NOT EXISTS
         (SELECT NULL FROM ag_volume_bank av WHERE av.trans_id = t.trans_id)
           AND (vol.fund_id = g_fund_rur OR NOT EXISTS
                (SELECT NULL FROM ins.ag_volume_bank agv WHERE agv.epg_id = vol.epg_id));
    END insert_by_pd4_date;
  
    PROCEDURE insert_deduction IS
    BEGIN
      INSERT INTO ag_volume_bank_deduction
        (ag_volume_bank_deduction_id
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_start_date
        ,insurance_period
        ,payment_term_id
        ,payment_period
        ,assured_age
        ,trans_id
        ,trans_amount
        ,ag_roll_id
        ,p_cover_id
        ,cover_fee
        ,product_line_id
        ,prod_line_option_id
        ,sav
        ,deduction_type)
        SELECT sq_ag_volume_bank_deduction.nextval
              ,vb.ag_contract_header_id
              ,vb.policy_header_id
              ,vb.policy_start_date
              ,vb.insurance_period
              ,vb.payment_term_id
              ,vb.payment_period
              ,vb.assured_age
              ,vb.trans_id
              ,vb.trans_amount
              ,g_roll_id
              ,vb.p_cover_id
              ,pc.fee
              ,vb.product_line_id
              ,pc.t_prod_line_option_id
              ,vb.sav
              ,2
          FROM ag_volume_bank     vb
              ,p_cover            pc
              ,ag_contract_header ch
         WHERE vb.ag_contract_header_id = ch.ag_contract_header_id
           AND ch.deduction_flag IN (1, 2)
           AND vb.p_cover_id = pc.p_cover_id
              --AND vb.policy_header_id IN (108254858, 107198238, 106519322, 106459633)
              --AND vb.policy_header_id in (select ph.policy_header_id from p_pol_header ph where ids in (2240182492, 2240183030, 2240183425, 2701656394))
           AND NOT EXISTS (SELECT NULL
                  FROM ins.exclude_agents ae
                 WHERE ae.ag_contract_header_id = vb.ag_contract_header_id
                   AND ae.ag_roll_id = g_roll_id)
           AND EXISTS
         (SELECT NULL
                  FROM oper          op
                      ,trans         tr
                      ,p_policy      pp
                      ,p_pol_decline pd
                 WHERE pp.pol_header_id = vb.policy_header_id
                   AND op.document_id = pp.policy_id
                   AND op.oper_id = tr.oper_id
                   AND pp.policy_id = pd.p_policy_id(+)
                   AND tr.trans_templ_id = 861
                      /* Зыонг Р.: Заявка №404084 */
                   AND CASE
                         WHEN ch.agent_id = 1730537 THEN
                          pd.issuer_return_date
                         ELSE
                          tr.trans_date
                       END BETWEEN g_date_begin AND (g_date_end + 1) - INTERVAL '1' SECOND)
              -- Не удерживаем дважды
           AND NOT EXISTS
         (SELECT NULL FROM ag_volume_bank_deduction bd WHERE bd.trans_id = vb.trans_id);
    
      INSERT INTO ag_volume_bank_deduction
        (ag_volume_bank_deduction_id
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_start_date
        ,insurance_period
        ,payment_term_id
        ,payment_period
        ,assured_age
        ,trans_id
        ,trans_amount
        ,ag_roll_id
        ,p_cover_id
        ,cover_fee
        ,product_line_id
        ,prod_line_option_id
        ,sav
        ,deduction_type
        ,bank_support
        ,days_till_decline
        ,days_till_end)
        SELECT sq_ag_volume_bank_deduction.nextval
              ,vb.ag_contract_header_id
              ,vb.policy_header_id
              ,vb.policy_start_date
              ,vb.insurance_period
              ,vb.payment_term_id
              ,vb.payment_period
              ,vb.assured_age
              ,vb.trans_id
              ,vb.trans_amount
              ,g_roll_id
              ,vb.p_cover_id
              ,pc.fee
              ,vb.product_line_id
              ,pc.t_prod_line_option_id
              ,vb.sav
              ,1
              ,CASE
                 WHEN ch.bank_support_perc IS NOT NULL THEN
                  (1 - ch.bank_support_perc / 100)
                 ELSE
                  1
               END AS bank_support
              ,ROUND(pp.end_date - pp.decline_date) AS days_till_decline
              ,ROUND(ppf.end_date - ph.start_date) AS days_till_end
          FROM ag_volume_bank     vb
              ,ag_contract_header ch
              ,p_policy           pp
              ,p_pol_header       ph
              ,p_policy           ppf
              ,p_cover            pc
         WHERE vb.ag_contract_header_id = ch.ag_contract_header_id
              --AND vb.policy_header_id in (select ph.policy_header_id from p_pol_header ph where ids in (2240182492, 2240183030, 2240183425, 2701656394))
           AND pp.pol_header_id = ph.policy_header_id
           AND ppf.pol_header_id = ph.policy_header_id
           AND ppf.version_num = 1
           AND ph.policy_header_id = vb.policy_header_id
           AND ch.deduction_flag = 1
           AND vb.p_cover_id = pc.p_cover_id
           AND EXISTS
         (SELECT NULL
                  FROM oper          op
                      ,trans         tr
                      ,p_pol_decline pd
                 WHERE op.document_id = pp.policy_id
                   AND op.oper_id = tr.oper_id
                   AND pp.policy_id = pd.p_policy_id(+)
                   AND tr.trans_templ_id = 809
                      /* Зыонг Р. Заявка №404084 */
                   AND CASE
                         WHEN ch.agent_id = 1730537 THEN
                          pd.issuer_return_date
                         ELSE
                          tr.trans_date
                       END BETWEEN g_date_begin AND (g_date_end + 1) - INTERVAL '1' SECOND)
              -- Не удерживаем дважды
           AND NOT EXISTS
         (SELECT NULL FROM ag_volume_bank_deduction bd WHERE bd.trans_id = vb.trans_id);
    END insert_deduction;
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег Банки');
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 0);
  
    pkg_trace.add_variable(par_trace_var_name => 'g_date_end', par_trace_var_value => g_date_end);
    pkg_trace.add_variable(par_trace_var_name => 'g_date_begin', par_trace_var_value => g_date_begin);
    pkg_trace.add_variable(par_trace_var_name => 'g_roll_id', par_trace_var_value => g_roll_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                                   ,par_trace_subobj_name => 'CALC_VOLUME_BANK');
    --ex.RAISE('Расчет временно закрыт');
    --return;
  
    prepare_temporary_data;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 10);
  
    insert_by_pol_start_date;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 30);
  
    insert_by_pp_date;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 60);
  
    insert_by_pd4_date;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 70);
  
    insert_deduction;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 80);
  
    calc_oav_bank;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                                 ,par_trace_subobj_name => 'CALC_VOLUME_BANK');
  
  END calc_banks;

  /**/
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.12.2010 14:58:24
  -- Purpose : Отбор объемов из b2b по новой методике
  PROCEDURE calc_b2b_volume IS
    proc_name                VARCHAR2(25) := 'Calc_b2b_volume';
    v_sq_ag_volume_id        PLS_INTEGER;
    v_amt                    NUMBER;
    v_curr_amt               NUMBER;
    pv_ag_contract_header_id NUMBER;
    pv_snils                 VARCHAR2(255);
    pv_fio                   VARCHAR2(255);
    pv_ass_birth_date        DATE;
    pv_gender                NUMBER;
    pv_ag_contract_num       VARCHAR2(50);
    pv_sign_date             DATE;
    pv_ops_is_seh            NUMBER;
    pv_kv_flag               NUMBER;
    pv_sch_flag              NUMBER;
    pv_sign_flag             NUMBER;
    pv_limit_flag            NUMBER;
    pv_amt                   NUMBER;
    pv_from_8_to_1           NUMBER;
    pv_kv_is_volume_calc     NUMBER;
    pv_kv_volume_type        NUMBER;
  
    CURSOR c_ops IS
      SELECT ach.ag_contract_header_id
            ,npp.snils
            ,npp.surname || ' ' || npp.name || ' ' || npp.midname fio
            ,npp.birth_date ass_birth_date
            ,npp.gender gender
            ,nop.ag_contract_num
            ,nop.sign_date
            ,nop.ops_is_seh
            ,nop.kv_flag
            ,decode(ach.brief, 'SAS 2', 1, 0) sch_flag
            ,CASE
               WHEN nop.sign_date <= to_date('25.05.2011', 'dd.mm.yyyy') THEN
                1
               ELSE
                0
             END sign_flag
            ,CASE
               WHEN g_date_begin BETWEEN to_date('26.10.2011', 'dd.mm.yyyy') AND
                    to_date('25.12.2011', 'dd.mm.yyyy')
                    AND ach.brief IN ('SAS', 'MLM') THEN
                1
               ELSE
                0
             END limit_flag
            , /*Заявка №262407*/CASE
               WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) BETWEEN 14 AND 23 THEN
                100
               WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 14 THEN
                0
               ELSE
                CASE
                  WHEN npp.birth_date >= to_date('01.01.1967', 'dd.mm.yyyy') THEN
                   1000
                  ELSE
                   CASE
                     WHEN npp.gender = 1 THEN
                      CASE
                        WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 55 THEN
                         100
                        ELSE
                         0
                      END
                     ELSE
                      CASE
                        WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 50 THEN
                         100
                        ELSE
                         0
                      END
                   END
                END
             END amt
            ,(SELECT COUNT(*)
                FROM ag_npf_volume_det anv
               WHERE anv.snils = npp.snils
                 AND anv.npf_det_type = 'OPS'
                 AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                       FROM ins.t_kv_flag kv
                                      WHERE kv.kv_flag_brief = 'TO_RET'
                                        AND kv.is_used = 1)) from_8_to_1
            ,(SELECT flg.volume_type_id
                FROM ins.t_kv_flag flg
               WHERE flg.kv_flag_val = nop.kv_flag
                 AND flg.kv_flag_brief = 'TO_PAY'
                 AND flg.is_used = 1) kv_volume_type
            ,(SELECT flg.is_volume_calc
                FROM ins.t_kv_flag flg
               WHERE flg.kv_flag_val = nop.kv_flag
                 AND flg.kv_flag_brief = 'TO_PAY'
                 AND flg.is_used = 1) kv_is_volume_calc
        FROM etl.npf_person npp
            ,etl.npf_ops_policy nop
            ,etl.npf_product np
            ,etl.npf_status_ref nsr
            ,(SELECT prev.a2 num
                    ,ach.ag_contract_header_id
                    ,ach.agency_id
                    ,ach.agent_id
                    ,nvl(chac.brief, ch.brief) brief
                FROM ven_ag_contract_header ach
                    ,t_sales_channel ch
                    ,ag_contract ac
                    ,t_sales_channel chac
                    ,(SELECT *
                        FROM (SELECT ach.ag_contract_header_id a1
                                    ,ach.num                   a2
                                FROM ven_ag_contract_header ach
                               WHERE ach.is_new = 1
                              UNION
                              SELECT apd.ag_contract_header_id
                                    ,'S' || apd.num
                                FROM ag_prev_dog apd)) prev
               WHERE ach.ag_contract_header_id = prev.a1
                 AND ch.id = ach.t_sales_channel_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.ag_sales_chn_id = chac.id(+)
                 AND ach.is_new = 1) ach
       WHERE 1 = 1
         AND npp.person_id = nop.person_id
         AND nop.product_id = np.product_id
         AND nop.status_ref_id = nsr.status_ref_id
         AND nop.sign_date >= to_date('15.06.2010', 'dd.mm.yyyy')
         AND nop.sign_date <= g_ops_sign_d
         AND nsr.status_name = CASE
               WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                'Отправлен в ПФР'
               ELSE
                nsr.status_name
             END
         AND (nop.kv_flag = CASE
               WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                nop.kv_flag
               ELSE
                1
             END OR nop.kv_flag IN (SELECT kv.kv_flag_val
                                       FROM ins.t_kv_flag kv
                                      WHERE kv.kv_flag_brief = 'TO_PAY'
                                        AND kv.is_used = 1))
         AND np.product_name IN ('Договор ОПС', 'Договор ОПС ( НПФ - НПФ )')
         AND nop.ag_contract_num = ach.num
         AND nop.policy_num NOT IN (SELECT a.ops_num FROM etl.tmp_ops_nums_for_delete a)
         AND (((SELECT COUNT(*)
                  FROM ag_npf_volume_det anv
                 WHERE anv.snils = npp.snils
                   AND anv.npf_det_type = 'OPS'
                   AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                         FROM ins.t_kv_flag kv
                                        WHERE kv.kv_flag_brief = 'TO_RET'
                                          AND kv.is_used = 1)) = 1 AND /*EXISTS
                                                                                                                                                                                                                                                  (SELECT NULL
                                                                                                                                                                                                                                                      FROM ag_npf_volume_det anv
                                                                                                                                                                                                                                                     WHERE anv.snils = npp.snils
                                                                                                                                                                                                                                                       AND anv.npf_det_type = 'OPS'
                                                                                                                                                                                                                                                       AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                                                                                                                                                                                                                                                             FROM ins.t_kv_flag kv
                                                                                                                                                                                                                                                                            WHERE kv.kv_flag_brief = 'TO_PAY'
                                                                                                                                                                                                                                                                              AND kv.is_used = 1))*/
             (SELECT COUNT(*)
                  FROM ag_npf_volume_det anv
                 WHERE anv.snils = npp.snils
                   AND anv.npf_det_type = 'OPS'
                   AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                         FROM ins.t_kv_flag kv
                                        WHERE kv.kv_flag_brief = 'TO_PAY'
                                          AND kv.is_used = 1)) < 2) OR
             (NOT EXISTS (SELECT NULL
                             FROM ag_npf_volume_det anv
                            WHERE anv.snils = npp.snils
                              AND anv.npf_det_type = 'OPS'
                           /*AND anv.kv_flag IN (SELECT kv.kv_flag_val
                           FROM ins.t_kv_flag kv
                           WHERE kv.kv_flag_brief = 'TO_PAY'
                             AND kv.is_used = 1
                           )*/
                           )));
  
    CURSOR c_ret IS
      SELECT ach.ag_contract_header_id
            ,npp.snils
            ,npp.surname || ' ' || npp.name || ' ' || npp.midname fio
            ,npp.birth_date ass_birth_date
            ,npp.gender gender
            ,nop.ag_contract_num
            ,nop.sign_date
            ,nop.ops_is_seh
            ,nop.kv_flag
            ,decode(ach.brief, 'SAS 2', 1, 0) sch_flag
            ,CASE
               WHEN nop.sign_date <= to_date('25.05.2011', 'dd.mm.yyyy') THEN
                1
               ELSE
                0
             END sign_flag
            ,CASE
               WHEN g_date_begin BETWEEN to_date('26.10.2011', 'dd.mm.yyyy') AND
                    to_date('25.12.2011', 'dd.mm.yyyy')
                    AND ach.brief IN ('SAS', 'MLM') THEN
                1
               ELSE
                0
             END limit_flag
            , /*Заявка №262407*/CASE
               WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) BETWEEN 14 AND 23 THEN
                100
               WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 14 THEN
                0
               ELSE
                CASE
                  WHEN npp.birth_date >= to_date('01.01.1967', 'dd.mm.yyyy') THEN
                   1000
                  ELSE
                   CASE
                     WHEN npp.gender = 1 THEN
                      CASE
                        WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 55 THEN
                         100
                        ELSE
                         0
                      END
                     ELSE
                      CASE
                        WHEN FLOOR(MONTHS_BETWEEN(nop.sign_date, npp.birth_date) / 12) < 50 THEN
                         100
                        ELSE
                         0
                      END
                   END
                END
             END amt
            ,99 from_8_to_1
            ,kv.volume_type_id kv_volume_type
            ,kv.is_volume_calc kv_is_volume_calc
        FROM etl.npf_person npp
            ,etl.npf_ops_policy nop
            ,etl.npf_product np
            ,etl.npf_status_ref nsr
            ,(SELECT prev.a2 num
                    ,ach.ag_contract_header_id
                    ,ach.agency_id
                    ,ach.agent_id
                    ,nvl(chac.brief, ch.brief) brief
                FROM ven_ag_contract_header ach
                    ,t_sales_channel ch
                    ,ag_contract ac
                    ,t_sales_channel chac
                    ,(SELECT *
                        FROM (SELECT ach.ag_contract_header_id a1
                                    ,ach.num                   a2
                                FROM ven_ag_contract_header ach
                               WHERE ach.is_new = 1
                              UNION
                              SELECT apd.ag_contract_header_id
                                    ,'S' || apd.num
                                FROM ag_prev_dog apd)) prev
               WHERE ach.ag_contract_header_id = prev.a1
                 AND ch.id = ach.t_sales_channel_id
                 AND ach.ag_contract_header_id = ac.contract_id
                 AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.ag_sales_chn_id = chac.id(+)
                 AND ach.is_new = 1) ach
            ,ins.t_kv_flag kv
       WHERE 1 = 1
         AND npp.person_id = nop.person_id
         AND nop.product_id = np.product_id
         AND nop.status_ref_id = nsr.status_ref_id
         AND nop.sign_date >= to_date('15.06.2010', 'dd.mm.yyyy')
         AND nop.sign_date <= g_ops_sign_d
         AND nsr.status_name = CASE
               WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                'Отправлен в ПФР'
               ELSE
                nsr.status_name
             END
         AND nop.kv_flag = kv.kv_flag_val
         AND kv.kv_flag_brief = 'TO_RET'
         AND kv.is_used = 1
         AND np.product_name IN ('Договор ОПС', 'Договор ОПС ( НПФ - НПФ )')
         AND nop.ag_contract_num = ach.num
         AND nop.policy_num NOT IN (SELECT a.ops_num FROM etl.tmp_ops_nums_for_delete a)
         AND NOT EXISTS (SELECT NULL
                FROM ag_npf_volume_det anv
               WHERE anv.snils = npp.snils
                 AND anv.npf_det_type = 'OPS'
                 AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                       FROM ins.t_kv_flag kv
                                      WHERE kv.kv_flag_brief = 'TO_RET'
                                        AND kv.is_used = 1))
         AND EXISTS (SELECT NULL
                FROM ag_npf_volume_det anv
               WHERE anv.snils = npp.snils
                 AND anv.npf_det_type = 'OPS'
                 AND anv.kv_flag IN (SELECT kv.kv_flag_val
                                       FROM ins.t_kv_flag kv
                                      WHERE kv.kv_flag_brief = 'TO_PAY'
                                        AND kv.is_used = 1));
  
  BEGIN
  
    pkg_agent_calculator.insertinfo('Расчет объемов по данным из b2b : OPS');
  
    /*
    TODO: owner="alexey.katkevich" created="23.07.2010"
    text="Доработать механизм отбора ОПС до более внятного
          5. Механизм сделать через блочную вставку"
    */
  
    --Объемы договоров ОПС
  
    IF g_is_ops_retention = 1
    THEN
      /*удержание ОПС*/
      OPEN c_ret;
      LOOP
        FETCH c_ret
          INTO pv_ag_contract_header_id
              ,pv_snils
              ,pv_fio
              ,pv_ass_birth_date
              ,pv_gender
              ,pv_ag_contract_num
              ,pv_sign_date
              ,pv_ops_is_seh
              ,pv_kv_flag
              ,pv_sch_flag
              ,pv_sign_flag
              ,pv_limit_flag
              ,pv_amt
              ,pv_from_8_to_1
              ,pv_kv_volume_type
              ,pv_kv_is_volume_calc;
        EXIT WHEN c_ret%NOTFOUND;
      
        IF pv_limit_flag = 1
           AND pv_amt = 250
        THEN
          /*********необходимо две вставки******************/
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,decode(pv_kv_is_volume_calc
                   ,1
                   ,pv_kv_volume_type
                   ,decode(pv_sign_flag
                          ,1
                          ,g_vt_ops
                          ,0
                          ,decode(pv_sch_flag
                                 ,0
                                 ,g_vt_ops
                                 ,1
                                 ,decode(pv_amt, 1000, g_vt_ops, g_vt_ops_2)
                                 ,g_vt_ops)
                          ,g_vt_ops))
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, -pv_amt)
            ,0
            ,0
            ,pv_sign_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id
            ,ag_contract_num
            ,assured_birf_date
            ,fio
            ,gender
            ,snils
            ,sign_date
            ,ops_is_seh
            ,kv_flag
            ,npf_det_type
            ,from_ret_to_pay)
          VALUES
            (v_sq_ag_volume_id
            ,pv_ag_contract_num
            ,pv_ass_birth_date
            ,pv_fio
            ,pv_gender
            ,pv_snils
            ,pv_sign_date
            ,pv_ops_is_seh
            ,pv_kv_flag
            ,'OPS'
            ,pv_from_8_to_1);
          /************************************/
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,g_vt_ops_3
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, -200)
            ,0
            ,0
            ,pv_sign_date);
        
          /***********************************/
        
        ELSE
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,decode(pv_kv_is_volume_calc
                   ,1
                   ,pv_kv_volume_type
                   ,decode(pv_sign_flag
                          ,1
                          ,g_vt_ops
                          ,0
                          ,decode(pv_sch_flag
                                 ,0
                                 ,g_vt_ops
                                 ,1
                                 ,decode(pv_amt, 1000, g_vt_ops, g_vt_ops_2)
                                 ,g_vt_ops)
                          ,g_vt_ops))
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, -pv_amt)
            ,0
            ,0
            ,pv_sign_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id
            ,ag_contract_num
            ,assured_birf_date
            ,fio
            ,gender
            ,snils
            ,sign_date
            ,ops_is_seh
            ,kv_flag
            ,npf_det_type
            ,from_ret_to_pay)
          VALUES
            (v_sq_ag_volume_id
            ,pv_ag_contract_num
            ,pv_ass_birth_date
            ,pv_fio
            ,pv_gender
            ,pv_snils
            ,pv_sign_date
            ,pv_ops_is_seh
            ,pv_kv_flag
            ,'OPS'
            ,pv_from_8_to_1);
        
        END IF;
      
      END LOOP;
      CLOSE c_ret;
    ELSE
      /**/
      OPEN c_ops;
      LOOP
        FETCH c_ops
          INTO pv_ag_contract_header_id
              ,pv_snils
              ,pv_fio
              ,pv_ass_birth_date
              ,pv_gender
              ,pv_ag_contract_num
              ,pv_sign_date
              ,pv_ops_is_seh
              ,pv_kv_flag
              ,pv_sch_flag
              ,pv_sign_flag
              ,pv_limit_flag
              ,pv_amt
              ,pv_from_8_to_1
              ,pv_kv_volume_type
              ,pv_kv_is_volume_calc;
        EXIT WHEN c_ops%NOTFOUND;
      
        IF pv_limit_flag = 1
           AND pv_amt = 250
        THEN
          /*********необходимо две вставки******************/
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,decode(pv_kv_is_volume_calc
                   ,1
                   ,pv_kv_volume_type
                   ,decode(pv_sign_flag
                          ,1
                          ,g_vt_ops
                          ,0
                          ,decode(pv_sch_flag
                                 ,0
                                 ,g_vt_ops
                                 ,1
                                 ,decode(pv_amt, 1000, g_vt_ops, g_vt_ops_2)
                                 ,g_vt_ops)
                          ,g_vt_ops))
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, pv_amt)
            ,decode(pv_kv_flag, 2, 0, 1)
            ,decode(pv_kv_flag
                   ,2
                   ,0
                   ,decode(pv_sign_flag
                          ,1
                          ,decode(pv_amt, 1000, 1, 0)
                          ,0
                          ,decode(pv_sch_flag
                                 ,1
                                 ,decode(pv_amt, 1000, 1, 250, 1, 0)
                                 ,decode(pv_amt, 1000, 1, 0))
                          ,decode(pv_amt, 1000, 1, 0)))
            ,pv_sign_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id
            ,ag_contract_num
            ,assured_birf_date
            ,fio
            ,gender
            ,snils
            ,sign_date
            ,ops_is_seh
            ,kv_flag
            ,npf_det_type
            ,from_ret_to_pay)
          VALUES
            (v_sq_ag_volume_id
            ,pv_ag_contract_num
            ,pv_ass_birth_date
            ,pv_fio
            ,pv_gender
            ,pv_snils
            ,pv_sign_date
            ,pv_ops_is_seh
            ,pv_kv_flag
            ,'OPS'
            ,pv_from_8_to_1);
          /************************************/
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,g_vt_ops_3
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, 200)
            ,decode(pv_kv_flag, 2, 0, 1)
            ,1
            ,pv_sign_date);
        
          /***********************************/
        
        ELSE
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,decode(pv_kv_is_volume_calc
                   ,1
                   ,pv_kv_volume_type
                   ,decode(pv_sign_flag
                          ,1
                          ,g_vt_ops
                          ,0
                          ,decode(pv_sch_flag
                                 ,0
                                 ,g_vt_ops
                                 ,1
                                 ,decode(pv_amt, 1000, g_vt_ops, g_vt_ops_2)
                                 ,g_vt_ops)
                          ,g_vt_ops))
            ,pv_ag_contract_header_id
            ,decode(pv_kv_flag, 2, 0, pv_amt)
            ,decode(pv_kv_flag, 2, 0, decode(pv_amt, 1000, 0.5, 0))
            ,decode(pv_kv_flag
                   ,2
                   ,0
                   ,decode(pv_sign_flag
                          ,1
                          ,decode(pv_amt, 1000, 1, 0)
                          ,0
                          ,decode(pv_sch_flag
                                 ,1
                                 ,decode(pv_amt, 1000, 1, 250, 1, 0)
                                 ,decode(pv_amt, 1000, 1, 0))
                          ,decode(pv_amt, 1000, 1, 0)))
            ,pv_sign_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id
            ,ag_contract_num
            ,assured_birf_date
            ,fio
            ,gender
            ,snils
            ,sign_date
            ,ops_is_seh
            ,kv_flag
            ,npf_det_type
            ,from_ret_to_pay)
          VALUES
            (v_sq_ag_volume_id
            ,pv_ag_contract_num
            ,pv_ass_birth_date
            ,pv_fio
            ,pv_gender
            ,pv_snils
            ,pv_sign_date
            ,pv_ops_is_seh
            ,pv_kv_flag
            ,'OPS'
            ,pv_from_8_to_1);
        
        END IF;
      
      END LOOP;
      CLOSE c_ops;
    END IF;
  
    IF g_is_calc_sofi = 1
    THEN
    
      pkg_agent_calculator.insertinfo('Расчет объемов по данным из b2b : SOFI');
      --Объемы денег заявленых агентами по платежкам
    
      FOR sofi IN (SELECT ach.ag_contract_header_id
                         ,ns.ag_contract_num
                         ,npp.snils
                         ,npp.surname || ' ' || npp.name || ' ' || npp.midname fio
                         ,npp.birth_date ass_birth_date
                         ,ns.sofi_pay_date
                         ,ns.amount amt
                         ,row_number() over(PARTITION BY ns.person_id ORDER BY ns.sofi_pay_date) rn
                         ,(SELECT nvl(SUM(av.trans_sum), 0)
                             FROM ag_npf_volume_det anv
                                 ,ag_volume         av
                            WHERE anv.snils = npp.snils
                              AND av.ag_volume_id = anv.ag_volume_id
                              AND anv.npf_det_type = 'SOFI') amt_exists
                     FROM etl.npf_person npp
                         ,etl.npf_sofi ns
                         ,(SELECT prev.a2 num
                                 ,ach.ag_contract_header_id
                                 ,ach.agency_id
                                 ,ach.agent_id
                             FROM ven_ag_contract_header ach
                                 ,(SELECT *
                                     FROM (SELECT ach.ag_contract_header_id a1
                                                 ,ach.num                   a2
                                             FROM ven_ag_contract_header ach
                                            WHERE ach.is_new = 1
                                           UNION
                                           SELECT apd.ag_contract_header_id
                                                 ,'S' || apd.num
                                             FROM ag_prev_dog apd)) prev
                            WHERE ach.ag_contract_header_id = prev.a1
                              AND ach.is_new = 1) ach
                    WHERE 1 = 1
                      AND npp.person_id = ns.person_id
                      AND EXISTS
                    (SELECT NULL
                             FROM etl.npf_ops_policy nop
                                 ,etl.npf_product    np
                                 ,etl.npf_status_ref nsr
                            WHERE nop.person_id = npp.person_id
                              AND nop.product_id = np.product_id
                              AND nop.status_ref_id = nsr.status_ref_id
                              AND np.product_name IN
                                  ('Договор ОПС', 'Договор ОПС ( НПФ - НПФ )')
                              AND nsr.status_name = CASE
                                    WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                                     'Отправлен в ПФР'
                                    ELSE
                                     nsr.status_name
                                  END
                              AND (nop.kv_flag IN (1, 4, 5, 6) OR
                                  nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy'))
                           /*AND nop.kv_flag = CASE WHEN nop.sign_date < TO_DATE('25.11.2010', 'dd.mm.yyyy')
                                THEN nop.kv_flag
                           ELSE 1
                           END*/
                           )
                      AND EXISTS
                    (SELECT NULL
                             FROM etl.npf_ops_policy nop
                                 ,etl.npf_product    np
                                 ,etl.npf_status_ref nsr
                            WHERE nop.person_id = npp.person_id
                              AND nop.product_id = np.product_id
                              AND nop.status_ref_id = nsr.status_ref_id
                              AND np.product_name = 'СОФИ'
                                 /*Заявка №256807*/
                                 /*AND ((nop.sign_date = '31.03.2011' AND nsr.status_name = 'Подписан') OR
                                 nsr.status_name = 'Отправлен в ПФР'))*/
                              AND nsr.status_name IN ('Подписан', 'Отправлен в ПФР'))
                      AND ns.sofi_pay_date BETWEEN g_sofi_begin_d AND g_sofi_end_d --g_date_begin AND g_date_end
                      AND ns.ag_contract_num = ach.num
                      AND NOT EXISTS (SELECT NULL
                             FROM ag_npf_volume_det anv
                            WHERE anv.snils = npp.snils
                              AND anv.npf_det_type = 'SOFI'
                              AND extract(YEAR FROM anv.sign_date) =
                                  extract(YEAR FROM ns.sofi_pay_date) - 1)
                   
                   )
      LOOP
        IF sofi.rn = 1
        THEN
          v_curr_amt := 0;
        END IF;
      
        v_curr_amt := v_curr_amt + sofi.amt;
      
        IF v_curr_amt <= 12000
        THEN
        
          v_amt := least(12000 - sofi.amt_exists - (v_curr_amt - sofi.amt), sofi.amt);
        
        ELSE
        
          v_amt := least(12000 - sofi.amt_exists - (v_curr_amt - sofi.amt)
                        ,(12000 - (v_curr_amt - sofi.amt)));
        
        END IF;
      
        IF v_amt > 0
        THEN
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,g_vt_avc
            ,sofi.ag_contract_header_id
            ,v_amt
            ,0.5
            ,1
            ,sofi.sofi_pay_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id, ag_contract_num, fio, assured_birf_date, snils, sign_date, npf_det_type)
          VALUES
            (v_sq_ag_volume_id
            ,sofi.ag_contract_num
            ,sofi.fio
            ,sofi.ass_birth_date
            ,sofi.snils
            ,sofi.sofi_pay_date
            ,'SOFI');
        END IF;
      
      END LOOP;
    
    END IF;
  
    IF g_is_calc_sofi_pay = 1
    THEN
    
      --Объемы реально поступивших их ПФР денег
      pkg_agent_calculator.insertinfo('Расчет объемов по данным из b2b : SOFI_PAYMENT');
    
      FOR sofi_pay IN (SELECT ach.ag_contract_header_id
                             ,ach.num ag_contract_num
                             ,n_p.snils
                             ,n_p.surname || ' ' || n_p.name || ' ' || n_p.midname fio
                             ,n_p.birth_date ass_birth_date
                             ,nsp.amount amt
                             ,nsp.pay_date
                             ,
                              --row_number() OVER (PARTITION BY n_p.person_id ORDER BY nsp.pay_date) rn,
                              (SELECT nvl(SUM(av.trans_sum), 0)
                                 FROM ag_npf_volume_det anv
                                     ,ag_volume         av
                                WHERE anv.snils = n_p.snils
                                  AND av.ag_volume_id = anv.ag_volume_id
                                  AND anv.npf_det_type = 'SOFI') amt_exists
                             ,(SELECT nvl(SUM(av.trans_sum), 0)
                                 FROM ag_npf_volume_det anv
                                     ,ag_volume         av
                                WHERE anv.snils = n_p.snils
                                  AND av.ag_volume_id = anv.ag_volume_id
                                  AND anv.npf_det_type = 'AVCP') sum_amt
                         FROM etl.npf_sofi_payments nsp
                             ,(SELECT nop.ag_contract_num
                                     ,npp.person_id
                                     ,npp.surname
                                     ,npp.name
                                     ,npp.midname
                                     ,npp.birth_date
                                     ,npp.snils
                                 FROM etl.npf_person     npp
                                     ,etl.npf_ops_policy nop
                                     ,etl.npf_product    np
                                     ,etl.npf_status_ref nsr
                                WHERE nop.person_id = npp.person_id
                                  AND nop.product_id = np.product_id
                                  AND nop.status_ref_id = nsr.status_ref_id
                                  AND np.product_name IN ('СОФИ')
                                     /*Заявка №256807*/
                                     /*AND nsr.status_name = 'Отправлен в ПФР'*/
                                  AND nsr.status_name IN
                                      ('Подписан', 'Отправлен в ПФР')) n_p
                             ,(SELECT prev.a2 num
                                     ,ach.ag_contract_header_id
                                     ,ach.agency_id
                                     ,ach.agent_id
                                 FROM ven_ag_contract_header ach
                                     ,(SELECT *
                                         FROM (SELECT ach.ag_contract_header_id a1
                                                     ,ach.num                   a2
                                                 FROM ven_ag_contract_header ach
                                                WHERE ach.is_new = 1
                                               UNION
                                               SELECT apd.ag_contract_header_id
                                                     ,'S' || apd.num
                                                 FROM ag_prev_dog apd)) prev
                                WHERE ach.ag_contract_header_id = prev.a1
                                  AND ach.is_new = 1) ach
                        WHERE 1 = 1
                          AND n_p.person_id = nsp.person_id
                          AND ach.num = n_p.ag_contract_num
                          AND EXISTS
                        (SELECT NULL
                                 FROM etl.npf_ops_policy nop
                                     ,etl.npf_product    np
                                     ,etl.npf_status_ref nsr
                                WHERE nop.person_id = n_p.person_id
                                  AND nop.product_id = np.product_id
                                  AND nop.status_ref_id = nsr.status_ref_id
                                  AND np.product_name IN
                                      ('Договор ОПС'
                                      ,'Договор ОПС ( НПФ - НПФ )')
                                  AND nsr.status_name = CASE
                                        WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                                         'Отправлен в ПФР'
                                        ELSE
                                         nsr.status_name
                                      END
                                  AND nop.kv_flag = CASE
                                        WHEN nop.sign_date < to_date('25.11.2010', 'dd.mm.yyyy') THEN
                                         nop.kv_flag
                                        ELSE
                                         1
                                      END)
                          AND NOT EXISTS (SELECT NULL
                                 FROM ag_npf_volume_det anv
                                WHERE anv.snils = n_p.snils
                                  AND anv.npf_det_type = 'AVCP'
                                  AND anv.sign_date = nsp.pay_date))
      LOOP
      
        SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
      
        INSERT INTO ven_ag_volume
          (ag_volume_id
          ,ag_roll_id
          ,ag_volume_type_id
          ,ag_contract_header_id
          ,trans_sum
          ,nbv_coef
          ,is_nbv
          ,date_begin)
        VALUES
          (v_sq_ag_volume_id
          ,g_roll_id
          ,g_vt_avc_pay
          ,sofi_pay.ag_contract_header_id
          ,sofi_pay.amt
          ,0.5
          ,1
          ,sofi_pay.pay_date);
      
        INSERT INTO ven_ag_npf_volume_det
          (ag_volume_id, fio, ag_contract_num, assured_birf_date, snils, sign_date, npf_det_type)
        VALUES
          (v_sq_ag_volume_id
          ,sofi_pay.fio
          ,sofi_pay.ag_contract_num
          ,sofi_pay.ass_birth_date
          ,sofi_pay.snils
          ,sofi_pay.pay_date
          ,'AVCP');
      
        v_amt := least(12000 - sofi_pay.amt_exists
                      ,(sofi_pay.amt + sofi_pay.sum_amt) - sofi_pay.amt_exists);
      
        IF v_amt > 0
        THEN
        
          SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
        
          INSERT INTO ven_ag_volume
            (ag_volume_id
            ,ag_roll_id
            ,ag_volume_type_id
            ,ag_contract_header_id
            ,trans_sum
            ,nbv_coef
            ,is_nbv
            ,date_begin)
          VALUES
            (v_sq_ag_volume_id
            ,g_roll_id
            ,g_vt_avc
            ,sofi_pay.ag_contract_header_id
            ,v_amt
            ,0.5
            ,1
            ,sofi_pay.pay_date);
        
          INSERT INTO ven_ag_npf_volume_det
            (ag_volume_id, ag_contract_num, fio, assured_birf_date, snils, sign_date, npf_det_type)
          VALUES
            (v_sq_ag_volume_id
            ,sofi_pay.ag_contract_num
            ,sofi_pay.fio
            ,sofi_pay.ass_birth_date
            ,sofi_pay.snils
            ,g_date_end
            ,'SOFI');
        END IF;
      END LOOP;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_b2b_volume;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 17:50:31
  -- Purpose : Расчет ведомости для хранения КСП
  PROCEDURE calc_ksp_vedom(p_ag_contract_header_id NUMBER) IS
    proc_name    VARCHAR2(25) := 'Calc_KSP_vedom';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
    v_ksp        NUMBER;
  BEGIN
    --Т.к. механизм ведомостей общий, а здесь АД мне не нужен то здесь будет заглшка
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      NULL;
    END IF;
  
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id);
  
    pkg_agent_calculator.insertinfo('Расчет объемов для КСП');
    prepare_ksp_0510;
  
    pkg_agent_calculator.insertinfo('Начат расчет актов');
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ac.category_id
                         ,ach.date_begin
                     FROM ven_ag_contract_header ach
                         ,ag_contract            ac
                    WHERE 1 = 1
                      AND ac.contract_id = ach.ag_contract_header_id
                         --Приходится использовать функцию из старого функционала чтобы обеспечить 
                         --его поддержку
                      AND pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE) =
                          ac.ag_contract_id)
    LOOP
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, date_calc)
      VALUES
        (v_apw_id, g_roll_id, agents.ag_contract_header_id, SYSDATE);
    
      SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
    
      /*
      TODO: owner="alexey.katkevich" created="23.07.2010"
      text="Заменить ID типа вознаграждения на вычисленное значение"
      */
    
      INSERT INTO ven_ag_perfom_work_det d
        (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id)
      VALUES
        (v_apw_det_id, v_apw_id, 262);
    
      v_ksp := get_ksp_250510(v_apw_det_id);
    
      UPDATE ag_perfom_work_det SET summ = v_ksp WHERE ag_perfom_work_det_id = v_apw_det_id;
    
      COMMIT; --после каждого акта
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END calc_ksp_vedom;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 15:42:35
  -- Purpose : Расчет ведомости ОАВ с 25.05.2010
  PROCEDURE calc_oav_vedom_250510(p_ag_contract_header_id NUMBER) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'calc_oav_vedom_250510';
    v_apw_id                  PLS_INTEGER;
    v_apw_det_id              PLS_INTEGER;
    perc_done                 NUMBER := 0;
    last_perc                 NUMBER := 0;
    v_ksp_val                 NUMBER;
    v_rl_nbv                  NUMBER;
    v_sofi_nbv                NUMBER;
    v_rl_sofi_nbv             NUMBER;
    v_all_nbv                 NUMBER;
    v_level                   PLS_INTEGER;
    v_activity_meetings_count NUMBER;
    v_comis_total             NUMBER;
    v_all_vol                 t_volume_val_o := t_volume_val_o(NULL);
    pg_agent_id               NUMBER;
  BEGIN
  
    pkg_trace.trace_procedure_start(gc_pkg_name, c_proc_name);
  
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 0);
  
    -- pkg_agent_calculator.Progress(g_roll_id,0);
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,rownum rn
                         ,ach.ag_contract_header_id
                         ,ac.category_id
                         ,ach.date_begin
                         ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
                         ,ac.leg_pos
                         ,pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                        ,g_date_end + 0.99999
                                                        ,ac.category_id
                                                        ,1
                                                        ,1) cat_date
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,t_sales_channel    chac
                         ,ag_documents       agd
                         ,ag_doc_type        adt
                    WHERE ach.ag_contract_header_id = ac.contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ach.ag_contract_header_id = agd.ag_contract_header_id
                      AND agd.ag_doc_type_id = adt.ag_doc_type_id
                      AND ac.ag_sales_chn_id = chac.id(+)
                      AND adt.brief = 'NEW_AD'
                         --AND ach.ag_contract_header_id = '92289414'
                         /*Заявка №301938*/
                         /*Заявка №281838*/
                         /*AND (EXISTS
                         (SELECT NULL
                            FROM ins.ag_documents   agd_ch
                                ,ins.ag_doc_type    t_ch
                                ,ins.document       d_agd
                                ,ins.doc_status_ref d_rf
                           WHERE agd_ch.ag_contract_header_id = ach.ag_contract_header_id
                             AND agd_ch.ag_doc_type_id = t_ch.ag_doc_type_id
                             AND t_ch.brief = 'SALES_CHG'
                             AND agd_ch.ag_documents_id = d_agd.document_id
                             AND d_agd.doc_status_ref_id = d_rf.doc_status_ref_id
                             AND d_rf.brief IN ('CO_ACCEPTED', 'CO_ACHIVE')) OR NOT EXISTS
                         (SELECT NULL
                            FROM ins.ag_documents agd_ch
                                ,ins.ag_doc_type  t_ch
                           WHERE agd_ch.ag_contract_header_id = ach.ag_contract_header_id
                             AND agd_ch.ag_doc_type_id = t_ch.ag_doc_type_id
                             AND t_ch.brief = 'SALES_CHG'))*/
                         /*Добавлен статус DEFICIENCY по заявке №235089*/
                      AND doc.get_doc_status_brief(agd.ag_documents_id) IN
                          ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY')
                         /* Зыонг Р.: Заявка №405271 */
                      AND ((CASE
                            WHEN g_date_begin >= to_date('26/02/2015', 'dd/mm/yyyy')
                                 AND NOT EXISTS
                             (SELECT NULL
                                    FROM ag_documents agd2
                                        ,ag_doc_type  adt2
                                   WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                     AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                     AND adt2.brief = 'NEW_AD_RENLIFE'
                                     AND doc.get_doc_status_brief(agd2.ag_documents_id) IN
                                         ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY')) THEN
                             0
                            ELSE
                             1
                          END) = 1 OR (CASE
                            WHEN g_date_begin >= to_date('26/02/2015', 'dd/mm/yyyy')
                                 AND ach.date_begin >= to_date('26/02/2015', 'dd/mm/yyyy')
                                 AND NOT EXISTS
                             (SELECT NULL
                                    FROM ag_documents agd2
                                        ,ag_doc_type  adt2
                                   WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                     AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                     AND adt2.brief IN ('NEW_AD', 'NEW_AD_RENLIFE')
                                     AND doc.get_doc_status_brief(agd2.ag_documents_id) IN
                                         ('CO_ACCEPTED', 'CO_ACHIVE')) THEN
                             0
                            ELSE
                             1
                          END) = 1)
                         /************добавлен статус Расторгнут, заявка №153093 Чернова Анастасия***************************/
                      AND (doc.get_doc_status_brief(ach.ag_contract_header_id) = 'CURRENT' OR EXISTS
                           (SELECT NULL
                              FROM ins.doc_status     ds
                                  ,ins.doc_status_ref rf
                             WHERE ds.doc_status_ref_id = rf.doc_status_ref_id
                               AND rf.brief = 'BREAK'
                               AND ds.document_id = ach.ag_contract_header_id
                               AND ds.start_date >= to_date('26.12.2011', 'DD.MM.YYYY')))
                      AND ach.agency_id <> g_ag_external_agency
                      AND ac.category_id = g_ct_agent
                      AND (NOT EXISTS (SELECT NULL
                                         FROM ag_documents ad
                                             ,ag_doc_type  adt1
                                        WHERE ad.ag_doc_type_id = adt1.ag_doc_type_id
                                          AND adt1.brief = 'CAT_CHG'
                                          AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                          AND ad.doc_date = ac.date_begin) OR
                           (SELECT doc.get_doc_status_brief(ad.ag_documents_id)
                                         FROM ag_documents ad
                                             ,ag_doc_type  adt1
                                        WHERE ad.ag_doc_type_id = adt1.ag_doc_type_id
                                          AND adt1.brief = 'CAT_CHG'
                                          AND ad.ag_contract_header_id = ach.ag_contract_header_id
                                          AND rownum = 1 --Плохо - А что делать, если находятся такие удолбаны?)                      
                                          AND ad.doc_date = ac.date_begin) IN
                           ('CO_ACCEPTED', 'CO_ACHIVE', 'CANCEL', 'DEFICIENCY'))
                      AND ach.t_sales_channel_id IN
                          (g_sc_dsf, g_sc_sas, g_sc_grs_moscow, g_sc_grs_region, g_sc_sas_2)
                      AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                      AND nvl(ach.is_new, 1) = 1)
    LOOP
    
      pkg_trace.add_variable('ag_contract_header_id', agents.ag_contract_header_id);
      pkg_trace.trace(gc_pkg_name, c_proc_name, 'Нечало обработки агента');
    
      perc_done := agents.rn / agents.cur_count * 100;
      IF last_perc <> perc_done
      THEN
        last_perc := perc_done;
        pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, perc_done);
      END IF;
    
      g_cat_date    := agents.cat_date;
      g_category_id := agents.category_id;
      g_sales_ch    := agents.t_sales_channel_id;
      g_leg_pos     := agents.leg_pos;
      g_sgp1        := 0;
    
      v_ksp_val := nvl(get_ksp_value(agents.ag_contract_header_id), 0);
    
      v_all_vol := get_nbv_for_act(agents.ag_contract_header_id);
    
      v_all_nbv := v_all_vol.get_volume(g_vt_life) + v_all_vol.get_volume(g_vt_inv) +
                   v_all_vol.get_volume(g_vt_ops) + v_all_vol.get_volume(g_vt_ops_2) +
                   v_all_vol.get_volume(g_vt_avc) + v_all_vol.get_volume(g_vt_bank) +
                   v_all_vol.get_volume(g_vt_fdep) + v_all_vol.get_volume(g_vt_ops_9);
    
      v_activity_meetings_count := pkg_agn_control.get_activity_meetings_count(par_ag_countract_header_id => agents.ag_contract_header_id
                                                                              ,par_vedom_end_date         => g_date_end);
    
      v_level := nvl(pkg_tariff_calc.calc_coeff_val('LEVEL'
                                                   ,t_number_type(g_sales_ch
                                                                 ,g_category_id
                                                                 ,v_activity_meetings_count
                                                                 ,v_all_nbv
                                                                 ,v_ksp_val))
                    ,1);
    
      --Вставляем запись в акты
    
      dml_ag_perfomed_work_act.insert_record(par_ag_roll_id              => g_roll_id
                                            ,par_ag_contract_header_id   => agents.ag_contract_header_id
                                            ,par_doc_templ_id            => g_ag_perf_work_act_doc
                                            ,par_ag_level                => v_level
                                            ,par_ag_ksp                  => v_ksp_val
                                            ,par_volumes                 => v_all_vol
                                            ,par_date_calc               => SYSDATE
                                            ,par_activity_meetings_count => v_activity_meetings_count
                                            ,par_all_volume              => v_all_nbv
                                            ,par_ag_perfomed_work_act_id => v_apw_id);
    
      pkg_trace.add_variable('g_roll_id', g_roll_id);
      pkg_trace.add_variable('v_ksp_val', v_ksp_val);
      pkg_trace.add_variable('v_level', v_level);
      pkg_trace.add_variable('v_activity_meetings_count', v_activity_meetings_count);
      pkg_trace.trace(gc_pkg_name, c_proc_name, 'Создан акт');
    
      pg_agent_id := agents.ag_contract_header_id;
      -- Отбор и расчет премий
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                     FROM ag_av_type_conform atc
                         ,ag_rate_type       arat
                         ,ag_roll_type       arot
                    WHERE arat.ag_rate_type_id = atc.ag_rate_type_id
                      AND atc.ag_roll_type_id = g_roll_type
                      AND g_date_begin >= arat.date_begin
                      AND g_date_end < nvl(arat.date_end, g_date_end + 1)
                      AND atc.ag_roll_type_id = arot.ag_roll_type_id
                      AND nvl(arat.enabled, 0) = 1
                      AND nvl(atc.enabled, 0) = 1
                      AND atc.t_sales_channel_id = agents.t_sales_channel_id)
      LOOP
        dml_ag_perfom_work_det.insert_record(par_ag_perfomed_work_act_id => v_apw_id
                                            ,par_ag_rate_type_id         => prem.ag_rate_type_id
                                            ,par_summ                    => 0
                                            ,par_ag_perfom_work_det_id   => v_apw_det_id);
      
        g_commision := 0;
        /****************/
        pkg_trace.trace(gc_pkg_name
                       ,c_proc_name
                       ,'Запуск расчета премии: ' || prem.calc_fun);
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
        pkg_trace.add_variable('g_commision', g_commision);
        pkg_trace.trace(gc_pkg_name
                       ,c_proc_name
                       ,'Конец расчета премии: ' || prem.calc_fun);
      
        UPDATE ag_perfom_work_det a
           SET a.summ = g_commision
         WHERE a.ag_perfom_work_det_id = v_apw_det_id;
      
        v_comis_total := v_comis_total + nvl(g_commision, 0);
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sum  = v_comis_total
            ,a.sgp1 = g_sgp1
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || c_proc_name || '-' || pg_agent_id || ' ' ||
                              SQLERRM);
  END calc_oav_vedom_250510;

  -- Author  : VESELEK
  -- Created : 02.10.2012
  -- Purpose : Расчет ведомости ОАВ RLA
  PROCEDURE calc_oav_rla(p_ag_contract_header_id NUMBER) IS
    proc_name     VARCHAR2(25) := 'calc_OAV_RLA';
    v_apw_id      PLS_INTEGER;
    v_apw_det_id  PLS_INTEGER;
    perc_done     NUMBER := 0;
    last_perc     NUMBER := 0;
    v_ksp_val     NUMBER;
    v_sofi_nbv    NUMBER;
    v_rl_sofi_nbv NUMBER;
    v_all_nbv     NUMBER;
    v_level       PLS_INTEGER;
    v_comis_total NUMBER;
    v_all_vol     t_volume_val_o := t_volume_val_o(NULL);
    pg_agent_id   NUMBER;
  BEGIN
  
    pkg_progress_util.set_progress_percent('CALC_COMMISS_RLA', g_roll_id, 0);
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,rownum rn
                         ,ach.ag_contract_header_id
                         ,ac.category_id
                         ,ach.date_begin
                         ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
                         ,ac.leg_pos
                         ,pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                        ,g_date_end + 0.99999
                                                        ,ac.category_id
                                                        ,1
                                                        ,1) cat_date
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,t_sales_channel    chac
                         ,ag_documents       agd
                         ,ag_doc_type        adt
                    WHERE ach.ag_contract_header_id = ac.contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ach.ag_contract_header_id = agd.ag_contract_header_id
                      AND agd.ag_doc_type_id = adt.ag_doc_type_id
                      AND ac.ag_sales_chn_id = chac.id(+)
                      AND adt.brief = 'NEW_AD'
                      AND doc.get_doc_status_brief(ach.ag_contract_header_id) NOT IN ('CANCEL')
                      AND ach.t_sales_channel_id IN (g_sc_rla)
                      AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                      AND nvl(ach.is_new, 1) = 1
                   UNION ALL
                   SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,rownum rn
                         ,ach.ag_contract_header_id
                         ,ac.category_id
                         ,ach.date_begin
                         ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
                         ,ac.leg_pos
                         ,pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                        ,g_date_end + 0.99999
                                                        ,ac.category_id
                                                        ,1
                                                        ,1) cat_date
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,t_sales_channel    chac
                    WHERE ach.last_ver_id = ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ac.ag_sales_chn_id = chac.id(+)
                      AND doc.get_doc_status_brief(ach.ag_contract_header_id) = 'CURRENT'
                      AND nvl(ach.is_new, 1) = 0
                      AND ach.ag_contract_header_id = 10146042)
    LOOP
    
      perc_done := agents.rn / agents.cur_count * 100;
      IF last_perc <> perc_done
      THEN
        last_perc := perc_done;
        pkg_progress_util.set_progress_percent('CALC_COMMISS_RLA', g_roll_id, perc_done);
      END IF;
    
      g_cat_date    := agents.cat_date;
      g_category_id := agents.category_id;
      g_sales_ch    := agents.t_sales_channel_id;
      g_leg_pos     := agents.leg_pos;
      g_sgp1        := 0;
    
      v_ksp_val := nvl(get_ksp_value(agents.ag_contract_header_id), 0);
    
      v_all_vol := get_nbv_for_act(agents.ag_contract_header_id);
    
      v_sofi_nbv    := 0;
      v_rl_sofi_nbv := 0;
    
      v_all_nbv := v_all_vol.get_volume(g_vt_life) + v_all_vol.get_volume(g_vt_inv) +
                   v_all_vol.get_volume(g_vt_ops) + v_all_vol.get_volume(g_vt_ops_2) +
                   v_all_vol.get_volume(g_vt_avc) + v_all_vol.get_volume(g_vt_bank) +
                   v_all_vol.get_volume(g_vt_ops_9);
    
      v_level := 1;
    
      --Вставляем запись в акты
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,volumes
        ,ag_level
        ,ag_ksp)
      VALUES
        (v_apw_id, g_roll_id, agents.ag_contract_header_id, SYSDATE, v_all_vol, v_level, v_ksp_val);
      pg_agent_id := agents.ag_contract_header_id;
      -- Отбор и расчет премий
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                     FROM ag_av_type_conform atc
                         ,ag_rate_type       arat
                         ,ag_roll_type       arot
                    WHERE arat.ag_rate_type_id = atc.ag_rate_type_id
                      AND atc.ag_roll_type_id = g_roll_type
                      AND g_date_begin >= arat.date_begin
                      AND g_date_end < nvl(arat.date_end, g_date_end + 1)
                      AND atc.ag_roll_type_id = arot.ag_roll_type_id
                      AND nvl(arat.enabled, 0) = 1
                      AND nvl(atc.enabled, 0) = 1
                      AND atc.t_sales_channel_id = agents.t_sales_channel_id)
      LOOP
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
        VALUES
          (v_apw_det_id, v_apw_id, prem.ag_rate_type_id, 0);
      
        g_commision := 0;
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
        UPDATE ag_perfom_work_det a
           SET a.summ = g_commision
         WHERE a.ag_perfom_work_det_id = v_apw_det_id;
      
        v_comis_total := v_comis_total + nvl(g_commision, 0);
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sum  = v_comis_total
            ,a.sgp1 = g_sgp1
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '-' || pg_agent_id || ' ' ||
                              SQLERRM);
  END calc_oav_rla;
  /**/
  -- Author  : VESELEK
  -- Created : 07.11.2012 12:11:35
  -- Purpose : Расчет ведомости АВ RLP
  PROCEDURE calc_av_rlp(p_ag_contract_header_id NUMBER) IS
    proc_name     VARCHAR2(25) := 'calc_AV_RLP';
    v_apw_id      PLS_INTEGER;
    v_apw_det_id  PLS_INTEGER;
    perc_done     NUMBER := 0;
    last_perc     NUMBER := 0;
    v_comis_total NUMBER;
    pg_agent_id   NUMBER;
  BEGIN
  
    pkg_progress_util.set_progress_percent('CALC_AV_RLP', g_roll_id, 0);
  
    FOR agents IN (SELECT ag_contract_header_id
                         ,t_sales_channel_id
                         ,category_id
                         ,COUNT(*) over(PARTITION BY 1) cur_count
                         ,rownum rn
                     FROM (SELECT DISTINCT rlp.ag_contract_header_id
                                          ,agh.t_sales_channel_id
                                          ,ag.category_id
                             FROM ins.ag_volume_rlp      rlp
                                 ,ins.ag_roll            rl
                                 ,ins.ag_roll_header     arh
                                 ,ins.ag_contract_header agh
                                 ,ins.ag_contract        ag
                            WHERE rlp.ag_roll_id = rl.ag_roll_id
                              AND rl.ag_roll_header_id = arh.ag_roll_header_id
                              AND arh.date_end BETWEEN g_date_begin AND g_date_end
                              AND rlp.ag_contract_header_id = agh.ag_contract_header_id
                              AND agh.ag_contract_header_id = ag.contract_id
                              AND g_date_end BETWEEN ag.date_begin AND ag.date_end))
    LOOP
    
      perc_done := agents.rn / agents.cur_count * 100;
      IF last_perc <> perc_done
      THEN
        last_perc := perc_done;
        pkg_progress_util.set_progress_percent('CALC_AV_RLP', g_roll_id, perc_done);
      END IF;
    
      --Вставляем запись в акты
      SELECT sq_ag_act_rlp.nextval INTO v_apw_id FROM dual;
      INSERT INTO ven_ag_act_rlp
        (ag_act_rlp_id, ag_roll_id, ag_contract_header_id, date_calc)
      VALUES
        (v_apw_id, g_roll_id, agents.ag_contract_header_id, SYSDATE);
      pg_agent_id := agents.ag_contract_header_id;
      -- Отбор и расчет премий
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                     FROM ag_av_type_conform atc
                         ,ag_rate_type       arat
                         ,ag_roll_type       arot
                    WHERE arat.ag_rate_type_id = atc.ag_rate_type_id
                      AND atc.ag_roll_type_id = g_roll_type
                      AND g_date_begin >= arat.date_begin
                      AND g_date_end < nvl(arat.date_end, g_date_end + 1)
                      AND atc.ag_roll_type_id = arot.ag_roll_type_id
                      AND nvl(arat.enabled, 0) = 1
                      AND nvl(atc.enabled, 0) = 1
                      AND atc.t_sales_channel_id = agents.t_sales_channel_id
                      AND atc.ag_category_agent_id = agents.category_id)
      LOOP
      
        SELECT sq_ag_work_det_rlp.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_work_det_rlp d
          (ag_work_det_rlp_id, ag_act_rlp_id, ag_rate_type_id, summ)
        VALUES
          (v_apw_det_id, v_apw_id, prem.ag_rate_type_id, 0);
      
        g_commision := 0;
        /****************/
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
        UPDATE ag_work_det_rlp a SET a.summ = g_commision WHERE a.ag_work_det_rlp_id = v_apw_det_id;
      
        v_comis_total := v_comis_total + nvl(g_commision, 0);
      END LOOP;
    
      UPDATE ag_act_rlp a SET a.sum = v_comis_total WHERE a.ag_act_rlp_id = v_apw_id;
    
      COMMIT;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '-' || pg_agent_id || ' ' ||
                              SQLERRM);
  END calc_av_rlp;

  -- Author  : Веселуха Е.В.
  -- Created : 22.08.2013
  -- Purpose : Расчет ведомости ОАВ для Банков / Брокеров
  PROCEDURE calc_oav_bank IS
    proc_name    VARCHAR2(25) := 'calc_oav_bank';
    v_apw_id     PLS_INTEGER;
    perc_done    NUMBER := 0;
    last_perc    NUMBER := 0;
    v_volume     NUMBER;
    v_commission NUMBER;
  BEGIN
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,rownum rn
                         ,ag_contract_header_id
                         ,category_id
                         ,date_begin
                         ,t_sales_channel_id
                         ,leg_pos
                         ,pkg_ag_calc_admin.get_cat_date(ag_contract_header_id
                                                        ,g_date_end + 0.99999
                                                        ,category_id
                                                        ,1
                                                        ,1) cat_date
                     FROM (SELECT ach.ag_contract_header_id
                                 ,ac.category_id
                                 ,ach.date_begin
                                 ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
                                 ,ac.leg_pos
                             FROM ins.ag_contract_header ach
                                 ,ins.ag_contract        ac
                                 ,ins.t_sales_channel    chac
                            WHERE ach.ag_contract_header_id = ac.contract_id
                              AND ac.ag_sales_chn_id = chac.id(+)
                              AND doc.get_doc_status_brief(ach.ag_contract_header_id) = 'CURRENT'
                              AND ac.category_id = g_ct_agent
                              AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                              AND ach.is_new = 1
                              AND ach.t_sales_channel_id IN
                                  (g_sc_bank, g_sc_br, g_sc_br_wdisc, g_sc_mbg)
                           /*AND ach.ag_contract_header_id IN (80462297,80462258,80462039)*/
                           ))
    LOOP
      -- т.к. осталось 20 процентов
      perc_done := 80 + (20 / 100 * (agents.rn / agents.cur_count * 100));
      IF last_perc <> perc_done
      THEN
        last_perc := perc_done;
        pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, perc_done);
      END IF;
    
      --Вставляем запись в акты
      SELECT nvl(SUM(ba.trans_amount * ba.sav), 0)
            ,nvl(SUM(ba.trans_amount), 0)
        INTO v_commission
            ,v_volume
        FROM ag_volume_bank ba
       WHERE ba.ag_contract_header_id = agents.ag_contract_header_id
         AND ba.ag_roll_id = g_roll_id;
    
      --v_all_vol.set_volume(p_vol_type => 701, p_volume => v_volume);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, date_calc, SUM, all_volume)
      VALUES
        (v_apw_id, g_roll_id, agents.ag_contract_header_id, SYSDATE, v_commission, v_volume);
    
      INSERT INTO ven_ag_perfom_work_det d
        (ag_perfomed_work_act_id, ag_rate_type_id, summ)
      VALUES
        (v_apw_id, 701, v_volume);
    
      doc.set_doc_status(p_doc_id => v_apw_id, p_status_brief => 'FINISH_CALCULATE');
    END LOOP;
  
  END calc_oav_bank;

  /**/
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.07.2009 12:21:17
  -- Purpose : Расчет ведомости ОАВ
  PROCEDURE calc_oav_vedom_010609(p_ag_contract_header_id NUMBER) IS
    proc_name    VARCHAR2(25) := 'calc_oav_vedom_010609';
    v_apw_id     NUMBER;
    v_apw_det_id PLS_INTEGER;
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег');
    prepare_cash_oav;
  
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    pkg_agent_calculator.insertinfo('Начат расчет актов');
    --2) Отбор АД
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ash.ag_stat_hist_id
                         ,ash.ag_stat_agent_id
                         ,ac.is_comm_holding
                         ,ac.category_id
                         ,ach.date_begin
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,ag_stat_hist       ash
                         ,t_sales_channel    chac
                    WHERE pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end) =
                          ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ash.ag_contract_header_id = ach.ag_contract_header_id
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ash.num = (SELECT MAX(num)
                                       FROM ag_stat_hist ash1
                                      WHERE ash1.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ash1.stat_date <= g_date_end)
                      AND doc.get_doc_status_id(ach.ag_contract_header_id) IN (g_st_curr, g_st_resume) --изменения в ТЗ Ким Т.
                      AND ach.agency_id <> g_ag_external_agency
                      AND ac.ag_sales_chn_id = chac.id(+)
                      AND nvl(chac.id, ach.t_sales_channel_id) = g_sc_dsf
                   
                   )
    LOOP
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     agents.ag_contract_header_id
                                    ,g_roll_id
                                    ,agents.cur_count);
      --Вставляем запись в акты
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id
        ,is_deduct)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,agents.ag_contract_header_id
        ,SYSDATE
        ,agents.ag_stat_hist_id
        ,agents.ag_stat_agent_id
        ,agents.is_comm_holding);
    
      g_commision := 0;
      g_sgp1      := 0;
      g_sgp2      := 0;
    
      g_category_id   := agents.category_id;
      g_ag_start_date := agents.date_begin;
    
      -- Отбор и расчет премий
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                     FROM ag_av_type_conform atc
                         ,ag_rate_type       arat
                         ,ag_roll_type       arot
                    WHERE arat.ag_rate_type_id = atc.ag_rate_type_id
                      AND atc.ag_roll_type_id = g_roll_type
                      AND g_date_begin >= arat.date_begin
                      AND g_date_end < nvl(arat.date_end, g_date_end + 1)
                      AND atc.ag_roll_type_id = arot.ag_roll_type_id
                      AND nvl(arat.enabled, 0) = 1)
      LOOP
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, mounth_num, summ)
        VALUES
          (v_apw_det_id
          ,v_apw_id
          ,prem.ag_rate_type_id
          ,pkg_ag_calc_admin.get_operation_months(agents.date_begin, g_date_end)
          ,0);
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
        UPDATE ag_perfom_work_det a
           SET a.summ = g_commision
         WHERE a.ag_perfom_work_det_id = v_apw_det_id;
      
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sgp1 = g_sgp1
            ,a.sgp2 = g_sgp2
            ,a.sum  = g_commision
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_oav_vedom_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.06.2009 16:53:56
  -- Purpose : Расчет ведомостей АВ с 01/06/2009
  PROCEDURE calc_dav_vedom_010609(p_ag_contract_header_id NUMBER) IS
    proc_name    VARCHAR2(25) := 'calc_dav_vedom_010609';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
  
    IF g_date_begin > '26.03.2010'
    THEN
      pkg_agent_calculator.insertinfo('Расчет объемов для КСП');
      prepare_ksp;
    END IF;
  
    pkg_agent_calculator.insertinfo('Расчет объемов СГП');
    prepare_sgp;
    pkg_agent_calculator.insertinfo('Расчет объемов CASH');
    prepare_cash;
  
    pkg_agent_calculator.insertinfo('Начат расчет актов');
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ash.ag_stat_hist_id
                         ,ash.ag_stat_agent_id
                         ,ac.is_comm_holding
                         ,ac.category_id
                         ,(SELECT MIN(ach1.date_begin)
                             FROM ag_contract_header ach1
                            WHERE ach1.agent_id = ach.agent_id) date_begin
                         ,doc.get_doc_status_id(ac.ag_contract_id) ad_status
                         ,CASE
                            WHEN ac.leg_pos = 0 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                            WHEN ac.leg_pos = 1 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ПБОЮЛ')
                            ELSE
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                          END ag_leg_pos
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,ag_stat_hist       ash
                         ,ag_stat_agent      asa
                    WHERE pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end) =
                          ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ash.ag_contract_header_id = ach.ag_contract_header_id
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ac.category_id = g_ct_agent
                         -- AND ach.ag_contract_header_id = 569892
                      AND ash.num = (SELECT MAX(num)
                                       FROM ag_stat_hist ash1
                                      WHERE ash1.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ash1.stat_date <= g_date_end)
                      AND asa.ag_stat_agent_id = ash.ag_stat_agent_id
                         -- AND ash.ag_stat_agent_id <> 120 -- Базовый агент
                      AND ach.t_sales_channel_id = g_sc_dsf
                      AND doc.get_doc_status_id(ac.ag_contract_id) IN (g_st_curr, g_st_resume)
                      AND ach.agency_id <> g_ag_external_agency)
    LOOP
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     agents.ag_contract_header_id
                                    ,g_roll_id
                                    ,agents.cur_count);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id
        ,is_deduct)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,agents.ag_contract_header_id
        ,SYSDATE
        ,agents.ag_stat_hist_id
        ,agents.ad_status
        ,agents.is_comm_holding);
    
      g_commision     := 0;
      g_sgp1          := 0;
      g_sgp2          := 0;
      g_leg_pos       := agents.ag_leg_pos;
      g_ag_start_date := agents.date_begin;
    
      -- Отбор и расчет премий
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                     FROM ag_av_type_conform atc
                         ,ag_rate_type       arat
                         ,ag_roll_type       arot
                    WHERE arat.ag_rate_type_id = atc.ag_rate_type_id
                      AND atc.ag_roll_type_id = g_roll_type
                      AND g_date_begin >= arat.date_begin
                      AND g_date_end < nvl(arat.date_end, g_date_end + 1)
                      AND atc.ag_roll_type_id = arot.ag_roll_type_id
                         --  AND atc.ag_status_id = agents.ag_stat_agent_id
                      AND nvl(arat.enabled, 0) = 1)
      LOOP
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, mounth_num, summ)
        VALUES
          (v_apw_det_id
          ,v_apw_id
          ,prem.ag_rate_type_id
          ,pkg_ag_calc_admin.get_operation_months(agents.date_begin, g_date_end)
          ,0);
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sgp1 = g_sgp1
            ,a.sgp2 = g_sgp2
            ,a.sum  = g_commision
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT; --после каждого акта
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_dav_vedom_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 31.08.2009 10:44:16
  -- Purpose : Расчет ведомости для аттестации агентов
  PROCEDURE calc_at_vedom(p_ag_contract_header_id NUMBER) IS
    proc_name    VARCHAR2(20) := 'calc_at_vedom';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
    v_cash       t_cash;
    v_ksp        NUMBER;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
  
    prepare_attest_vol;
  
    pkg_agent_calculator.insertinfo('Расчет объемов для КСП');
    prepare_ksp;
  
    pkg_agent_calculator.insertinfo('Начат расчет актов');
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ash.ag_stat_hist_id
                         ,ash.ag_stat_agent_id
                         ,ac.is_comm_holding
                         ,ac.category_id
                         ,(SELECT MIN(ach1.date_begin)
                             FROM ag_contract_header ach1
                            WHERE ach1.agent_id = ach.agent_id) date_begin
                         ,doc.get_doc_status_id(ac.ag_contract_id) ad_status
                         ,CASE
                            WHEN ac.leg_pos = 0 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                            WHEN ac.leg_pos = 1 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ПБОЮЛ')
                            ELSE
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                          END ag_leg_pos
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,ag_stat_hist       ash
                         ,ag_stat_agent      asa
                    WHERE pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end) =
                          ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ash.ag_contract_header_id = ach.ag_contract_header_id
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ac.category_id = g_ct_agent
                         -- AND ach.ag_contract_header_id = 569892
                      AND ash.num = (SELECT MAX(num)
                                       FROM ag_stat_hist ash1
                                      WHERE ash1.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ash1.stat_date <= g_date_end)
                      AND asa.ag_stat_agent_id = ash.ag_stat_agent_id
                      AND ach.t_sales_channel_id = g_sc_dsf
                      AND doc.get_doc_status_id(ac.ag_contract_id) IN (g_st_curr, g_st_resume)
                      AND ach.agency_id <> g_ag_external_agency)
    LOOP
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     agents.ag_contract_header_id
                                    ,g_roll_id
                                    ,agents.cur_count);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id
        ,is_deduct)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,agents.ag_contract_header_id
        ,SYSDATE
        ,agents.ag_stat_hist_id
        ,agents.ad_status
        ,agents.is_comm_holding);
    
      g_commision     := 0;
      g_sgp1          := 0;
      g_sgp2          := 0;
      g_leg_pos       := agents.ag_leg_pos;
      g_ag_start_date := agents.date_begin;
    
      SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
    
      INSERT INTO ven_ag_perfom_work_det d
        (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, mounth_num, summ)
      VALUES
        (v_apw_det_id
        ,v_apw_id
        ,221
        ,pkg_ag_calc_admin.get_operation_months(agents.date_begin, g_date_end)
        ,0);
    
      v_cash      := get_cash(v_apw_det_id);
      g_sgp1      := get_sgp(v_apw_det_id);
      g_sgp2      := v_cash.commiss_amount;
      g_commision := g_sgp1 + g_sgp2;
      v_ksp       := get_ksp(v_apw_det_id);
    
      UPDATE ag_perfomed_work_act a
         SET a.sgp1 = g_sgp1
            ,a.sgp2 = g_sgp2
            ,a.sum  = g_commision
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
    
      UPDATE ag_perfom_work_det SET summ = v_ksp WHERE ag_perfom_work_det_id = v_apw_det_id;
    
      COMMIT; --после каждого акта
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_at_vedom;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.06.2009 15:54:59
  -- Purpose : Расчет ведомостей АВ с 01/04/09 по 01/06/2009
  PROCEDURE calc_vedom_010409(p_ag_contract_header_id NUMBER) IS
    proc_name   VARCHAR2(20) := 'calc_vedom_010409';
    v_calc_func VARCHAR2(2000);
  BEGIN
    SELECT 'begin ' || arot.calc_pkg || '.' || art.calc_fun || '; end;' calc_fun
      INTO v_calc_func
      FROM ag_av_type_conform atc
          ,ag_rate_type       art
          ,ag_roll_type       arot
     WHERE art.ag_rate_type_id = atc.ag_rate_type_id
       AND atc.ag_roll_type_id = arot.ag_roll_type_id
       AND atc.ag_roll_type_id = g_roll_type;
  
    EXECUTE IMMEDIATE v_calc_func
      USING p_ag_contract_header_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_vedom_010409;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 30.08.2010 18:06:00
  -- Purpose : Получает ставку уже оплаченного вознаграждения с данного объема
  -- DEPRICATED !!!!!!!! use pkg_ag_calc_admin.Get_payed_rate instead
  FUNCTION get_payed_sav
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER IS
    v_sav     NUMBER;
    proc_name VARCHAR2(25) := 'Get_delta_sav';
  BEGIN
    SELECT nvl(SUM(apv.vol_rate), 0)
      INTO v_sav
      FROM ag_roll              ar
          ,ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_perf_work_vol     apv
     WHERE ar.ag_roll_header_id = p_roll_header_id
       AND ar.ag_roll_id = apw.ag_roll_id
       AND apw.ag_contract_header_id = p_ag_contract_header_id
       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
       AND apd.ag_rate_type_id = p_rate_type
       AND apv.ag_volume_id = p_ag_volume_id;
  
    RETURN(v_sav);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_payed_sav;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.06.2009 11:45:31
  -- Purpose : Ипользуется для получения объема КСП пр построении отчетов
  PROCEDURE get_ksp_volume(p_date DATE) IS
    proc_name VARCHAR2(20) := 'Get_KSP_volume';
  BEGIN
    g_date_end   := pkg_ag_calc_admin.get_opertation_month_date(p_date, 2);
    g_date_begin := pkg_ag_calc_admin.get_opertation_month_date(p_date, 1);
    prepare_ksp;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END get_ksp_volume;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.06.2009 17:14:01
  -- Purpose : Получает только объемы - требуется для построения отчета
  PROCEDURE get_volume
  (
    p_date        DATE
   ,p_roll_type   PLS_INTEGER
   ,p_roll_header PLS_INTEGER
  ) IS
    proc_name VARCHAR2(20) := 'Get_volume';
  BEGIN
    g_date_end   := pkg_ag_calc_admin.get_opertation_month_date(p_date, 2);
    g_date_begin := pkg_ag_calc_admin.get_opertation_month_date(p_date, 1);
    g_roll_type  := p_roll_type;
    SELECT brief INTO g_roll_type_brief FROM ag_roll_type WHERE ag_roll_type_id = p_roll_type;
    g_roll_header_id := p_roll_header;
  
    --Prepare_cash_OAV;
    --Prepare_cash;
    --     Prepare_SGP;
    --  Prepare_KSP_0510;
    --Prepare_KSP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_volume;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 17:31:38
  -- Purpose : Подготовка объемов для КСП по мотивации от  25052010
  PROCEDURE prepare_ksp_0510 IS
    proc_name VARCHAR2(25) := 'Prepare_KSP_0510';
  BEGIN
  
    INSERT INTO temp_ksp_calc
      (contract_header_id
      ,policy_header_id
      ,ksp_begin
      ,ksp_end
      ,fee_expected
      ,cash_recived
      ,fee_count
      ,agent_contract_header
      ,last_policy_status_id
      ,decline_date)
      SELECT ag_contract_header_id
            ,policy_header_id
            ,ksp_begin
            ,ksp_end
            ,fee_rur * fee_count + nvl(adm_costs_rur * CEIL(fee_count / number_of_payments), 0) fee_rur
            ,SUM(trans_amount) cash
            ,fee_count
            ,ag_contract_header_id
            ,last_stat
            ,CASE
               WHEN last_stat IN (g_st_readycancel
                                 ,g_st_berak
                                 ,g_st_to_quit
                                 ,g_st_ch_ready
                                 ,g_st_to_quit_ch
                                 ,g_st_quit
                                 ,g_st_quit_query
                                 ,g_st_quit_req_reg) THEN
                decline_date
               ELSE
                NULL
             END decline_date
        FROM (SELECT pad.ag_contract_header_id
                    ,pp_last.start_date decline_date
                    ,doc.get_doc_status_id(pp_last.policy_id, '31.12.2999') last_stat
                    ,ph.policy_header_id
                    ,(SELECT SUM(pc.fee)
                        FROM as_asset               ass
                            ,ins.p_cover            pc
                            ,ins.t_prod_line_option tplo
                       WHERE ass.p_policy_id = pp_first.policy_id
                         AND ass.as_asset_id = pc.as_asset_id
                         AND pc.status_hist_id <> 3
                         AND pc.t_prod_line_option_id = tplo.id
                         AND tplo.description != 'Административные издержки') *
                     acc.get_cross_rate_by_id(1, ph.fund_id, 122, ph.start_date) fee_rur
                    ,(SELECT SUM(pc.fee)
                        FROM as_asset               ass
                            ,ins.p_cover            pc
                            ,ins.t_prod_line_option tplo
                       WHERE ass.p_policy_id = pp_first.policy_id
                         AND ass.as_asset_id = pc.as_asset_id
                         AND pc.status_hist_id <> 3
                         AND pc.t_prod_line_option_id = tplo.id
                         AND tplo.description = 'Административные издержки') *
                     acc.get_cross_rate_by_id(1, ph.fund_id, 122, ph.start_date) adm_costs_rur
                    ,FLOOR((MONTHS_BETWEEN(least(pp_first.end_date
                                                ,g_date_end - decode(pt.id, g_pt_monthly, 30, 45))
                                          ,greatest(ph.start_date, g_date_begin)) + 0.001) / 12 *
                           pt.number_of_payments + 1) fee_count
                    ,pt.number_of_payments
                    ,greatest(ph.start_date, g_date_begin) ksp_begin
                    ,least(pp_first.end_date, g_date_end) ksp_end
                    ,(SELECT SUM(t.trans_amount)
                        FROM oper  o
                            ,trans t
                       WHERE o.document_id = nvl(pp_dso.doc_set_off_id, epg_dso.doc_set_off_id)
                         AND o.oper_id = t.oper_id
                         AND t.dt_account_id = 122) trans_amount
                FROM p_pol_header       ph
                    ,p_policy           pp
                    ,p_policy           pp_last
                    ,p_policy           pp_first
                    ,t_payment_terms    pt
                    ,p_policy_agent_doc pad
                    ,doc_doc            dd
                    ,ven_ac_payment     epg
                    ,doc_set_off        epg_dso
                    ,doc_doc            epg_pd
                    ,doc_set_off        pp_dso
               WHERE 1 = 1
                 AND ph.sales_channel_id IN (g_sc_dsf, g_sc_sas, g_sc_sas_2)
                 AND ph.policy_header_id = pp.pol_header_id
                 AND pkg_policy.get_last_version(ph.policy_header_id) = pp_last.policy_id
                 AND pp_first.pol_header_id = ph.policy_header_id
                 AND pp_first.version_num =
                     (SELECT MAX(pp_v2.version_num)
                        FROM ins.p_policy       pp_v2
                            ,ins.document       d
                            ,ins.doc_status_ref rf
                       WHERE pp_v2.pol_header_id = ph.policy_header_id
                         AND pp_v2.policy_id = d.document_id
                         AND d.doc_status_ref_id = rf.doc_status_ref_id
                         AND rf.brief != 'CANCEL'
                         AND pp_v2.start_date =
                             (SELECT MIN(pp_v3.start_date)
                                FROM p_policy pp_v3
                               WHERE pp_v3.pol_header_id = ph.policy_header_id))
                 AND pp_first.payment_term_id = pt.id
                 AND pt.is_periodical = 1
                 AND MONTHS_BETWEEN(pp_first.end_date, ph.start_date) > 12
                 AND ph.product_id IN (SELECT tc.criteria_1
                                         FROM t_prod_coef      tc
                                             ,t_prod_coef_type tpc
                                        WHERE tpc.brief = 'Products_in_calc'
                                          AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                          AND tc.criteria_2 = 3)
                 AND dd.parent_id = pp.policy_id
                 AND dd.child_id = epg.payment_id
                 AND epg.doc_templ_id = 4
                 AND ph.start_date BETWEEN g_date_begin AND g_date_end
                 AND epg.plan_date + decode(pt.id, g_pt_monthly, 30, 45) BETWEEN g_date_begin AND
                     g_date_end
                 AND ADD_MONTHS(ph.start_date, 12 / pt.number_of_payments) <=
                     g_date_end - decode(pt.id, g_pt_monthly, 30, 45)
                 AND epg.payment_id = epg_dso.parent_doc_id(+)
                 AND epg_dso.child_doc_id = epg_pd.parent_id(+)
                 AND epg_pd.child_id = pp_dso.parent_doc_id(+)
                    /*заявка №128784 от 25.07.2011*/
                 AND pp_last.policy_id NOT IN
                     (SELECT p.policy_id
                        FROM p_policy p
                            ,(SELECT CASE dr.name
                                       WHEN 'Неоплата очередного взноса' THEN
                                        'Расторжение'
                                       WHEN 'Окончание выжидательного периода' THEN
                                        'Расторжение'
                                       WHEN 'Увеличение степени страхового риска' THEN
                                        'Расторжение'
                                       WHEN 'Неоплата первого взноса' THEN
                                        'Аннулирование'
                                       WHEN 'Отказ Страховщика' THEN
                                        'Аннулирование'
                                       WHEN 'Заявление клиента' THEN
                                        'Расторжение'
                                       WHEN 'Отказ страхователя от НУ' THEN
                                        'Аннулирование'
                                       WHEN 'Решение суда (аннулирование)' THEN
                                        'Аннулирование'
                                       WHEN 'Решение суда (расторжение)' THEN
                                        'Расторжение'
                                       WHEN 'Смерть Страхователя' THEN
                                        'Расторжение'
                                       WHEN 'Смерть Застрахованного' THEN
                                        'Расторжение'
                                       WHEN 'Отказ Страхователя от договора' THEN
                                        'Аннулирование'
                                       ELSE
                                        tr.name
                                     END reason
                                    ,pol.policy_id
                                FROM p_policy         pol
                                    ,t_decline_reason dr
                                    ,t_decline_type   tr
                               WHERE pol.decline_reason_id = dr.t_decline_reason_id
                                 AND pol.decline_type_id = tr.t_decline_type_id) dr
                       WHERE p.policy_id = pp_last.policy_id
                         AND p.policy_id = dr.policy_id
                         AND dr.reason = 'Аннулирование')
                    /**/
                 AND doc.get_doc_status_id(pp_last.policy_id, '31.12.2999') NOT IN (g_st_stoped)
                 AND (doc.get_doc_status_id(pp_last.policy_id, '31.12.2999') NOT IN
                     (g_st_readycancel
                      ,g_st_berak
                      ,g_st_to_quit
                      ,g_st_ch_ready
                      ,g_st_to_quit_ch
                      ,g_st_quit
                      ,g_st_quit_query
                      ,g_st_quit_req_reg) OR
                     ((extract(YEAR FROM ph.start_date) = 2008 AND pp_last.start_date > '01.07.2009') OR
                     extract(YEAR FROM ph.start_date) <> 2008))
                 AND pad.policy_header_id = ph.policy_header_id
                 AND doc.get_doc_status_brief(pad.p_policy_agent_doc_id) <> 'ERROR'
                 AND decode(doc.get_doc_status_id(pp_last.policy_id, '31.12.2999')
                           ,g_st_readycancel
                           ,pp_last.start_date
                           ,g_st_berak
                           ,pp_last.start_date
                           ,g_st_to_quit
                           ,pp_last.start_date
                           ,g_st_ch_ready
                           ,pp_last.start_date
                           ,g_st_to_quit_ch
                           ,pp_last.start_date
                           ,g_st_quit
                           ,pp_last.start_date
                           ,g_st_quit_query
                           ,pp_last.start_date
                           ,g_st_quit_req_reg
                           ,pp_last.start_date
                           ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2)) BETWEEN
                     pad.date_begin AND pad.date_end)
       GROUP BY ag_contract_header_id
               ,policy_header_id
               ,fee_rur
               ,adm_costs_rur
               ,fee_count
               ,ksp_begin
               ,ksp_end
               ,number_of_payments
               ,last_stat
               ,decline_date;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END prepare_ksp_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.06.2009 17:04:24
  -- Purpose : Подготовка объемов для расчета КСП
  PROCEDURE prepare_ksp IS
    proc_name VARCHAR2(20) := 'Prepare_KSP';
  BEGIN
    DELETE FROM temp_ksp_calc;
  
    INSERT INTO temp_ksp_calc
      (agent_contract_header
      ,contract_header_id
      ,policy_header_id
      ,active_policy_status_id
      ,last_policy_status_id
      ,conclude_policy_sgp
      ,decline_date
      ,prolong_policy_sgp)
      SELECT a.ag_contract_header_id
            ,a.ag_contract_header_id
            ,a.policy_header_id
            ,a.active_st
            ,a.last_st
            ,a.sgp_z sgp_z
            ,a.decline_date
            ,CASE
               WHEN a.last_st NOT IN (g_st_readycancel, g_st_cancel, g_st_berak, g_st_stoped) THEN
                a.sgp
               ELSE
                0
             END sgp_real_p
        FROM (SELECT ach.ag_contract_header_id
                    ,ph.policy_header_id
                    ,pa.date_start
                    ,pp.decline_date
                    ,doc.get_doc_status_id(ph.policy_id) active_st
                    ,doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) last_st
                    ,(SELECT SUM(pc.fee) * pt1.number_of_payments
                        FROM p_policy           pp1
                            ,as_asset           aa
                            ,p_cover            pc
                            ,status_hist        sh
                            ,t_prod_line_option tplo
                            ,t_payment_terms    pt1
                       WHERE 1 = 1
                         AND pp1.pol_header_id = ph.policy_header_id
                         AND pt1.id = pp1.payment_term_id
                         AND pp1.version_num =
                             (SELECT MAX(pp2.version_num)
                                FROM ins.p_policy       pp2
                                    ,ins.document       d
                                    ,ins.doc_status_ref rf
                               WHERE pp2.pol_header_id = ph.policy_header_id
                                 AND pp2.policy_id = d.document_id
                                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                                 AND rf.brief != 'CANCEL'
                                 AND pp2.start_date =
                                     (SELECT MIN(pp3.start_date)
                                        FROM p_policy pp3
                                       WHERE pp3.pol_header_id = ph.policy_header_id))
                         AND aa.p_policy_id = pp1.policy_id
                         AND aa.as_asset_id = pc.as_asset_id
                         AND pc.status_hist_id = sh.status_hist_id
                         AND sh.brief <> 'DELETED'
                         AND pc.t_prod_line_option_id = tplo.id
                         AND tplo.description <> 'Административные издержки'
                       GROUP BY pt1.number_of_payments) *
                     acc.get_cross_rate_by_id(1, ph.fund_id, 122, SYSDATE) sgp_z
                    ,(SELECT SUM(pc.fee)
                        FROM as_asset           aa
                            ,p_cover            pc
                            ,status_hist        sh
                            ,t_prod_line_option tplo
                       WHERE aa.p_policy_id = pp.policy_id
                         AND aa.as_asset_id = pc.as_asset_id
                         AND pc.status_hist_id = sh.status_hist_id
                         AND sh.brief <> 'DELETED'
                         AND pc.t_prod_line_option_id = tplo.id
                         AND tplo.description <> 'Административные издержки') * pt.number_of_payments *
                     acc.get_cross_rate_by_id(1, ph.fund_id, 122, SYSDATE) sgp
                FROM ag_contract_header ach
                    ,t_sales_channel    ts
                    ,ag_contract        ac
                    ,t_sales_channel    chac
                    ,p_pol_header       ph
                    ,p_policy           pp
                    ,t_payment_terms    pt
                    ,p_policy_agent     pa
               WHERE ac.ag_contract_id =
                     pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end)
                 AND ac.ag_sales_chn_id = chac.id(+)
                 AND ach.t_sales_channel_id = ts.id
                 AND nvl(chac.id, ach.t_sales_channel_id) = g_sc_dsf
                 AND ph.start_date >= '01.10.2006' -- от кривых ДС
                    --  AND ph.policy_header_id = 812662
                 AND ph.product_id IN (SELECT tc.criteria_1
                                         FROM t_prod_coef      tc
                                             ,t_prod_coef_type tpc
                                        WHERE tpc.brief = 'Products_in_calc'
                                          AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                          AND tc.criteria_2 = 3)
                 AND ac.agency_id <> g_ag_external_agency
                 AND pa.policy_header_id = ph.policy_header_id
                 AND pa.ag_contract_header_id = ach.ag_contract_header_id
                 AND pa.p_policy_agent_id =
                     pkg_renlife_utils.get_p_agent_current(ph.policy_header_id
                                                          ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                      ,2)
                                                          ,2)
                 AND pp.pol_header_id = ph.policy_header_id
                 AND pp.payment_term_id = pt.id
                 AND pt.is_periodical = 1
                 AND pp.version_num = (SELECT MAX(pp1.version_num)
                                         FROM ins.p_policy       pp1
                                             ,ins.document       d
                                             ,ins.doc_status_ref rf
                                        WHERE pp1.pol_header_id = pp.pol_header_id
                                          AND pp1.policy_id = d.document_id
                                          AND d.doc_status_ref_id = rf.doc_status_ref_id
                                          AND rf.brief != 'CANCEL')
                 AND greatest(ph.start_date, pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) BETWEEN
                     pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 1, -31) AND
                     pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -8)
                 AND g_date_end >= ADD_MONTHS(ph.start_date, 12 / pt.number_of_payments) + 45
                 AND doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                     (g_st_stoped, g_st_cancel)
                 AND (doc.get_doc_status_id(pp.policy_id) NOT IN (g_st_readycancel, g_st_berak) OR
                     ((extract(YEAR FROM ph.start_date) = 2008 AND pp.decline_date > '01.07.2009') OR
                     (extract(YEAR FROM ph.start_date) <> 2008 AND pp.decline_date >= pa.date_start)))) a;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_ksp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.07.2009 16:23:06
  -- Purpose : Подготовка данных по поступившим деньгам для ОАВ
  PROCEDURE prepare_cash_oav IS
    proc_name VARCHAR2(20) := 'Prepare_cash_OAV';
  BEGIN
    DELETE FROM temp_cash_calc;
    INSERT INTO temp_cash_calc
      (policy_id
      ,policy_status_id
      ,epg_payment_id
      ,epg_status_id
      ,pay_payment_id
      ,pay_bank_doc_id
      ,trans_id
      ,trans_amount
      ,t_prod_line_option_id
      ,current_agent
      ,agent_status_id
      ,active_policy_id
      ,active_pol_status_id
      ,t_payment_term_id
      ,insurance_period
      ,is_indexing
      ,check_1
      ,check_2
      ,check_3
      ,year_of_insurance
      ,leg_pos
      ,policy_agent_part
      ,policy_agent_date
      ,ag_contract_id)
      SELECT a.policy_id
            ,a.policy_status
            ,a.epg
            ,a.epg_status
            ,a.pay_doc
            ,a.bank_doc
            ,t.trans_id
            ,t.trans_amount
            ,tplo.id prod_line_option
            ,a.ag_contract_header_id
            ,a.ag_status
            ,a.active_policy
            ,a.active_pol_status
            ,a.pay_term
            ,a.insurance_period
            ,a.indexing
            ,a.check1
            ,a.check2
            ,a.check3
            ,a.year_of_insurance
            ,a.leg_pos
            ,a.part_agent
            ,a.agent_start_date
            ,a.ag_contract_id
        FROM (SELECT COUNT(pa.p_policy_agent_id) over(PARTITION BY pa.ag_contract_header_id, pa.policy_header_id, epg.payment_id, pay_doc.payment_id, bank_doc.doc_set_off_id) rn
                    ,pa.status_id pa_stat
                    ,pp.policy_id
                    ,ph.policy_id active_policy
                    ,doc.get_doc_status_id(ph.policy_id) active_pol_status
                    ,doc.get_doc_status_id(pp.policy_id) policy_status
                    ,epg.payment_id epg
                    ,doc.get_doc_status_id(epg.payment_id) epg_status
                    ,pay_doc.payment_id pay_doc
                    ,nvl(pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, epg.plan_date)
                        ,pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, ach.date_begin)) ag_contract_id
                    ,CASE
                       WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                        dso.doc_set_off_id
                       ELSE
                        bank_doc.doc_set_off_id
                     END set_off_doc
                    ,
                     --             dd.parent_id,
                     CASE
                       WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                        dso.parent_doc_id
                       ELSE
                        bank_doc.parent_doc_id
                     END parent_set_off
                    ,CASE
                       WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                        pay_doc.payment_id
                       ELSE
                        bank_doc.child_doc_id
                     END bank_doc
                    ,CEIL(MONTHS_BETWEEN((SELECT end_date
                                           FROM p_policy pp1
                                          WHERE pp1.policy_id = ph.policy_id)
                                        ,ph.start_date) / 12) insurance_period
                    ,CEIL(MONTHS_BETWEEN(epg.plan_date + 1, ph.start_date) / 12) year_of_insurance
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM t_addendum_type     ta
                                   ,p_pol_addendum_type ppa
                              WHERE ppa.p_policy_id = pp.policy_id
                                AND MONTHS_BETWEEN(epg.due_date + 1, pp.start_date) <= 12
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2') > 0 THEN
                        1
                       ELSE
                        0
                     END indexing
                    ,pp.payment_term_id pay_term
                    ,ach.ag_contract_header_id
                    ,pa.date_start agent_start_date
                    ,nvl(pa.part_agent, 100) part_agent
                    ,pkg_renlife_utils.get_ag_stat_id(pa.ag_contract_header_id, epg.plan_date, 2) ag_status
                    ,(SELECT CASE
                               WHEN ac.leg_pos = 0 THEN
                                g_cn_natperson
                               WHEN ac.leg_pos = 1 THEN
                                g_cn_legentity
                               ELSE
                                g_cn_natperson
                             END
                        FROM ag_contract ac
                       WHERE ac.ag_contract_id =
                             nvl(pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                               ,epg.plan_date)
                                ,pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                               ,ach.date_begin))) leg_pos
                    ,(SELECT CASE
                               WHEN COUNT(*) > 0 THEN
                                1
                               ELSE
                                0
                             END
                        FROM p_policy pp1
                       WHERE pp1.pol_header_id = pp.pol_header_id
                         AND (doc.get_doc_status_id(pp1.policy_id) IN
                             (g_st_act, g_st_curr, g_st_print, g_st_stoped, g_st_concluded) OR
                             (doc.get_doc_status_id(pp1.policy_id) IN (g_st_to_agent, g_st_from_agent) AND
                             EXISTS (SELECT NULL
                                        FROM doc_status ds1
                                       WHERE ds1.document_id = pp1.policy_id
                                         AND ds1.doc_status_ref_id IN (g_st_act, g_st_print))))) check1
                    ,CASE
                       WHEN doc.get_doc_status_id(ph.policy_id) IN
                            (g_st_berak, g_st_revision, g_st_agrevision, g_st_underwr, g_st_stop) THEN
                        0
                       ELSE
                        1
                     END check2
                    ,decode(doc.get_doc_status_id(pkg_policy.get_last_version(pp.pol_header_id))
                           ,g_st_readycancel
                           ,0
                           ,1) check3
                FROM p_pol_header ph
                    ,p_policy_agent pa
                    ,ag_contract_header ach
                    ,p_policy pp
                    ,doc_doc dd
                    ,ven_ac_payment epg
                    ,doc_set_off dso
                    ,ven_ac_payment pay_doc
                    ,ac_payment_templ acpt
                    ,(SELECT dso2.child_doc_id
                            ,dd2.parent_id
                            ,dso2.doc_set_off_id
                            ,dso2.parent_doc_id
                        FROM doc_doc     dd2
                            ,doc_set_off dso2
                       WHERE dso2.parent_doc_id = dd2.child_id) bank_doc
               WHERE 1 = 1
                    -- AND pa.ag_contract_header_id = 5792948
                    --  AND ph.policy_header_id = par_policy_header_id
                 AND acpt.payment_templ_id = pay_doc.payment_templ_id
                 AND (doc.get_doc_status_id(ph.policy_id) IN (g_st_concluded, g_st_curr, g_st_stoped) OR
                     greatest(CASE
                                 WHEN ph.start_date > '26.08.2009' THEN
                                  ph.start_date - 1
                                 ELSE
                                  ph.start_date
                               END
                              ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) <
                     '26.08.2009')
                 AND ph.policy_header_id = pa.policy_header_id
                 AND pa.ag_contract_header_id = ach.ag_contract_header_id
                 AND (ph.product_id <> 7687 OR ph.start_date >= '01.03.2010')
                 AND pa.status_id <> 4
                 AND ((pa.date_start <= pay_doc.due_date AND pa.date_end > pay_doc.due_date AND
                     pkg_renlife_utils.get_p_ag_status_by_date(pa.ag_contract_header_id
                                                                ,ph.policy_header_id
                                                                ,pay_doc.due_date) = 'CURRENT') OR
                     NOT EXISTS
                      (SELECT 1
                         FROM p_policy_agent pa2
                        WHERE pa2.policy_header_id = ph.policy_header_id
                          AND pa2.status_id <> 4
                          AND pa2.ag_contract_header_id <> ach.ag_contract_header_id))
                 AND dd.parent_id = pp.policy_id
                 AND dd.child_id = epg.payment_id
                 AND epg.doc_templ_id = g_dt_epg_doc
                 AND dso.parent_doc_id = epg.payment_id
                 AND dso.child_doc_id = pay_doc.payment_id
                    --AND pay_doc.doc_templ_id IN (g_dt_pay_doc, g_dt_pd4_doc, g_dt_a7_doc)
                 AND acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ', 'A7', 'PD4')
                 AND epg.plan_date <= g_date_end
                 AND pay_doc.reg_date > '31.07.2007' -- Платежный документ создали после Внедрения
                 AND epg.due_date > ADD_MONTHS(g_date_end, -15) --Ограничим немного выборку
                    --AND dso.set_off_date <= g_date_end
                 AND pay_doc.due_date <= g_date_end + 0.99999
                 AND pay_doc.payment_id = bank_doc.parent_id(+)
                 AND pp.pol_header_id = ph.policy_header_id) a
            ,oper o
            ,trans t
            ,trans_templ tt
            ,p_cover pc
            ,t_prod_line_option tplo
       WHERE o.oper_id = t.oper_id
         AND ((a.rn > 1 AND a.pa_stat = 1) OR a.rn = 1)
         AND t.trans_templ_id = tt.trans_templ_id
         AND tt.brief IN ('СтраховаяПремияОплачена'
                         ,'СтраховаяПремияАвансОпл'
                         ,'ПремияОплаченаПоср'
                         ,'ЗачВзнСтрАг')
         AND t.obj_uro_id = pc.p_cover_id
         AND pc.t_prod_line_option_id = tplo.id
         AND o.document_id(+) = a.set_off_doc
         AND tplo.description <> 'Административные издержки'
            -- AND t.reg_date >= '01.04.2009'    --Чтобы отдельно не писат условие для старой мотиваци
         AND NOT EXISTS (SELECT 1 --Нет расчета по этой проводке по старой мотивации 
              --т.к. смотрели на другой зачет приходится извращатся
                FROM agent_report_cont arc
                    ,trans             t2
                    ,oper              o2
                    ,doc_set_off       dso2
                    ,doc_doc           dd2
               WHERE arc.trans_id = t2.trans_id
                 AND t2.oper_id = o2.oper_id
                 AND o2.document_id = dso2.doc_set_off_id
                 AND dso2.child_doc_id = dd2.parent_id
                 AND dd2.child_id = a.parent_set_off)
            -- AND sign(t2.trans_amount)= sign(t.trans_amount))
         AND NOT EXISTS (SELECT 1 --Нет расчета по этой проводке по старой мотивации
                FROM agent_report_cont arc
               WHERE arc.trans_id = t.trans_id)
         AND NOT EXISTS (SELECT 1 --Нет расчета по этой проводке по новой мотивации
                FROM ag_roll              ar
                    ,ag_roll_type         art
                    ,ven_ag_roll_header   arh
                    ,ag_perfomed_work_act apw
                    ,ag_perfom_work_det   apdet
                    ,ag_perfom_work_dpol  apdpol
                    ,ag_perf_work_pay_doc apd
                    ,ag_perf_work_trans   apwt
               WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                 AND arh.ag_roll_type_id = art.ag_roll_type_id
                 AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
                 AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                 AND arh.ag_roll_header_id <> g_roll_header_id
                 AND apw.ag_roll_id = ar.ag_roll_id
                 AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                 AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                 AND apdpol.ag_perfom_work_dpol_id = apd.ag_preformed_work_dpol_id
                 AND apd.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
                 AND apwt.trans_id = t.trans_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_cash_oav;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:09:29
  -- Purpose : Подготовка данных по поступишвим деньгам
  PROCEDURE prepare_cash IS
    proc_name VARCHAR2(20) := 'Prepare_cash';
    i         PLS_INTEGER;
  
    TYPE t_temp_cash_calc IS TABLE OF temp_cash_calc%ROWTYPE INDEX BY PLS_INTEGER;
    v_temp_cash_calc t_temp_cash_calc;
  BEGIN
    DELETE FROM temp_cash_calc;
    FOR pay_doc IN (SELECT pp.policy_id policy
                          ,pa.ag_contract_header_id
                          ,pp.pol_header_id
                          ,pp.payment_term_id
                          ,CASE
                             WHEN ((acpt.brief IN ('ПП_ПС', 'ПП_ОБ') OR
                                  bank_doc.brief IN ('ПП_ПС', 'ПП_ОБ')) AND
                                  ph.start_date BETWEEN '26.07.2009' AND '25.12.2009')
                                  OR ((acpt.brief = 'ПП_ПС' OR bank_doc.brief = 'ПП_ПС') AND
                                  ph.start_date BETWEEN '26.12.2009' AND '25.03.2010') THEN
                              CASE
                                WHEN EXISTS
                                 (SELECT NULL -- COUNT(apdpol.ag_perfom_work_dpol_id)
                                        FROM ag_roll              ar
                                            ,ag_roll_type         art
                                            ,ven_ag_roll_header   arh
                                            ,ag_perfomed_work_act apw
                                            ,ag_perfom_work_det   apdet
                                            ,ag_perfom_work_dpol  apdpol
                                            ,p_policy             pp1
                                       WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                                         AND arh.ag_roll_type_id = art.ag_roll_type_id
                                         AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
                                         AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                                         AND arh.ag_roll_header_id <> g_roll_header_id
                                         AND apw.ag_roll_id = ar.ag_roll_id
                                         AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                                         AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                                         AND pp1.policy_id = apdpol.policy_id
                                         AND pp1.pol_header_id = ph.policy_header_id
                                         AND apdpol.policy_agent_part = 3) THEN
                                 1
                                ELSE
                                 CASE
                                   WHEN row_number()
                                    over(PARTITION BY ph.policy_header_id
                                            ,decode(acpt.brief
                                                   ,'ПП_ПС'
                                                   ,1
                                                   ,'ПП_ОБ'
                                                   ,1
                                                   ,decode(bank_doc.brief, 'ПП_ПС', 1, 'ПП_ОБ', 1, 0)) ORDER BY
                                             pay_doc.due_date) = 1 THEN
                                    3
                                   ELSE
                                    1
                                 END
                              END
                             ELSE
                              1
                           END direct_debt_coef
                          ,nvl2((SELECT ppa.p_policy_id
                                  FROM p_pol_addendum_type ppa
                                      ,t_addendum_type     ta
                                 WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                   AND ta.brief = 'INDEXING2'
                                   AND ppa.p_policy_id = pp.policy_id)
                               ,1
                               ,0) idx
                          ,tp.is_group
                          ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date)) + 1 epg_num
                          ,CEIL(MONTHS_BETWEEN((SELECT pp_a.end_date
                                                 FROM p_policy pp_a
                                                WHERE pp_a.policy_id = ph.policy_id)
                                              ,ph.start_date) / 12) insurance_period
                          ,ph.policy_id active_pol
                          ,ph.product_id
                          ,doc.get_doc_status_id(ph.policy_id, g_status_date) active_pol_st
                          ,doc.get_doc_status_id(pp.policy_id, g_status_date) policy_st
                          ,epg.payment_id epg
                          ,doc.get_doc_status_id(epg.payment_id) epg_st
                          ,pay_doc.payment_id pd
                          ,CASE
                             WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                              dso.doc_set_off_id
                             ELSE
                              bank_doc.doc_set_off_id
                           END set_off_doc
                          ,CASE
                             WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                              pay_doc.payment_id
                             ELSE
                              bank_doc.child_doc_id
                           END bank_doc
                          ,(SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ag_contract_header ach
                                  ,ag_contract        ac
                             WHERE ac.ag_contract_id =
                                   pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                 ,ph.start_date)
                               AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) <>
                                   g_st_berak
                               AND ach.agent_id =
                                   pkg_policy.get_policy_contact(ph.policy_id
                                                                ,'Страхователь')) insuer_not_agent
                          , --check1
                           (SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ven_as_assured va
                             WHERE va.p_policy_id = ph.policy_id
                               AND EXISTS
                             (SELECT 1
                                      FROM ag_contract_header ach1
                                          ,ag_contract        ac1
                                     WHERE ac1.ag_contract_id =
                                           pkg_agent_1.get_status_by_date(ach1.ag_contract_header_id
                                                                         ,ph.start_date)
                                       AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) <>
                                           g_st_berak
                                       AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                      FROM p_policy_agent      pa
                          ,policy_agent_status pas
                          ,p_policy            pp
                          ,p_pol_header        ph
                          ,t_payment_terms     pt
                          ,
                           --  t_collection_method cm,
                           t_product tp
                          ,doc_doc dd
                          ,ven_ac_payment epg
                          ,doc_templ dt
                          ,doc_set_off dso
                          ,ven_ac_payment pay_doc
                          ,ac_payment_templ acpt
                          ,(SELECT dso2.child_doc_id
                                  ,dd2.parent_id
                                  ,dso2.doc_set_off_id
                                  ,dso2.parent_doc_id
                                  ,acpt2.brief
                              FROM doc_doc          dd2
                                  ,doc_set_off      dso2
                                  ,ac_payment       acp2
                                  ,ac_payment_templ acpt2
                             WHERE dso2.parent_doc_id = dd2.child_id
                               AND dso2.child_doc_id = acp2.payment_id
                               AND acp2.payment_templ_id = acpt2.payment_templ_id
                               AND doc.get_doc_status_id(dd2.child_id) = g_st_paid) bank_doc
                     WHERE 1 = 1
                       AND pa.policy_header_id = ph.policy_header_id
                       AND pa.status_id = pas.policy_agent_status_id
                       AND pas.brief = 'CURRENT'
                       AND (NOT EXISTS (SELECT NULL
                                          FROM p_policy_agent      pa2
                                              ,policy_agent_status pas2
                                         WHERE pa2.policy_header_id = pa.policy_header_id
                                           AND pa2.status_id = pas2.policy_agent_status_id
                                           AND pa2.p_policy_agent_id <> pa.p_policy_agent_id
                                           AND pas2.brief IN ('CANCEL', 'NEW')) OR EXISTS
                            (SELECT NULL
                               FROM p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND ppa.p_policy_id = pp.policy_id))
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                          -- AND cm.id = pp.collection_method_id
                       AND pp.payment_term_id = pt.id
                       AND (pt.id IN (g_pt_quater, g_pt_monthly) OR tp.is_group = 1 OR EXISTS
                            (SELECT NULL
                               FROM p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND ppa.p_policy_id = pp.policy_id))
                       AND tp.product_id IN (SELECT tc.criteria_1
                                               FROM t_prod_coef      tc
                                                   ,t_prod_coef_type tpc
                                              WHERE tpc.brief = 'Products_in_calc'
                                                AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                                AND tc.criteria_2 = 1)
                       AND (ph.product_id <> 7687 OR ph.start_date >= '01.03.2010')
                       AND dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt.doc_templ_id = epg.doc_templ_id
                       AND ((nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,0) NOT IN (g_st_readycancel, g_st_stoped, g_st_berak, g_st_stop) AND
                           doc.get_doc_status_id(pkg_renlife_utils.get_first_a_policy(ph.policy_header_id)
                                                  ,g_status_date) IN
                           (g_st_concluded, g_st_curr, g_st_stoped)) OR
                           (greatest(CASE
                                        WHEN ph.start_date > '26.08.2009' THEN
                                         ph.start_date - 1
                                        ELSE
                                         ph.start_date
                                      END
                                     ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) <
                           '26.08.2009' AND
                           nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,0) NOT IN (g_st_readycancel, g_st_stoped, g_st_berak, g_st_stop)))
                       AND doc.get_doc_status_id(epg.payment_id) = g_st_paid
                       AND dt.brief = 'PAYMENT'
                       AND ((MONTHS_BETWEEN(epg.plan_date, ph.start_date) < 12 AND
                           ph.start_date >= '29.05.2009') OR
                           (EXISTS (SELECT NULL
                                       FROM p_pol_addendum_type ppa
                                           ,t_addendum_type     ta
                                      WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                        AND ta.brief = 'INDEXING2'
                                        AND ppa.p_policy_id = pp.policy_id) AND
                            MONTHS_BETWEEN(epg.plan_date, pp.start_date) < 12))
                       AND epg.plan_date <= g_date_end + 1
                       AND pay_doc.due_date <= CASE
                             WHEN pp.payment_term_id = g_pt_monthly
                                  AND nvl(bank_doc.brief, acpt.brief) IN ('ПП_ПС', 'ПП_ОБ') THEN
                              last_day(g_date_end) + 10
                             ELSE
                              g_date_end
                           END
                          -- AND pp.pol_header_id = 15839568
                          /*             AND doc.get_doc_status_id(ph.policy_id) <> g_st_Revision*/
                       AND (SELECT doc.get_doc_status_id(pp1.policy_id, g_status_date)
                              FROM p_policy pp1
                             WHERE pp1.pol_header_id = ph.policy_header_id
                               AND pp1.version_num = 1) <> g_st_revision
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_doc.payment_id
                       AND pay_doc.due_date >= '29.05.2009'
                       AND doc.get_doc_status_id(pay_doc.payment_id) <> g_st_annulated
                       AND acpt.payment_templ_id = pay_doc.payment_templ_id
                       AND acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ', 'A7', 'PD4')
                       AND pay_doc.payment_id = bank_doc.parent_id(+))
    LOOP
      FOR trans IN (SELECT t.trans_id
                          ,tplo.id prod_line_option
                          ,CASE
                             WHEN pay_doc.idx = 1 THEN --Размер индексированного взноса
                              t.trans_amount *
                              pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tplo.id, 3)
                             ELSE
                              t.trans_amount * pay_doc.direct_debt_coef
                           END trans_amount
                      FROM oper               o
                          ,trans              t
                          ,trans_templ        tt
                          ,p_cover            pc
                          ,t_prod_line_option tplo
                     WHERE o.oper_id = t.oper_id
                       AND t.trans_templ_id = tt.trans_templ_id
                       AND tt.brief IN ('СтраховаяПремияОплачена'
                                       ,'СтраховаяПремияАвансОпл'
                                       ,'ПремияОплаченаПоср'
                                       ,'ЗачВзнСтрАг')
                       AND t.obj_uro_id = pc.p_cover_id
                       AND pc.t_prod_line_option_id = tplo.id
                       AND o.document_id = pay_doc.set_off_doc
                       AND tplo.description <> 'Административные издержки'
                       AND NOT EXISTS
                     (SELECT 1 --Нет расчета по этой проводке по новой мотивации
                              FROM ag_roll              ar
                                  ,ag_roll_type         art
                                  ,ven_ag_roll_header   arh
                                  ,ag_perfomed_work_act apw
                                  ,ag_perfom_work_det   apdet
                                  ,ag_perfom_work_dpol  apdpol
                                  ,ag_perf_work_pay_doc apd
                                  ,ag_perf_work_trans   apwt
                             WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                               AND arh.ag_roll_type_id = art.ag_roll_type_id
                               AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
                               AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                               AND arh.ag_roll_header_id <> g_roll_header_id
                               AND apw.ag_roll_id = ar.ag_roll_id
                               AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                               AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                               AND apdpol.ag_perfom_work_dpol_id = apd.ag_preformed_work_dpol_id
                               AND apd.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
                               AND apwt.trans_id = t.trans_id))
      LOOP
        i := v_temp_cash_calc.count + 1;
      
        v_temp_cash_calc(i).policy_id := pay_doc.policy;
        v_temp_cash_calc(i).policy_status_id := pay_doc.policy_st;
        v_temp_cash_calc(i).epg_payment_id := pay_doc.epg;
        v_temp_cash_calc(i).epg_status_id := pay_doc.epg_st;
        v_temp_cash_calc(i).pay_payment_id := pay_doc.pd;
        v_temp_cash_calc(i).pay_bank_doc_id := pay_doc.bank_doc;
        v_temp_cash_calc(i).trans_id := trans.trans_id;
        v_temp_cash_calc(i).trans_amount := trans.trans_amount;
        v_temp_cash_calc(i).t_prod_line_option_id := trans.prod_line_option;
        v_temp_cash_calc(i).current_agent := pay_doc.ag_contract_header_id;
        v_temp_cash_calc(i).is_group := pay_doc.is_group;
        v_temp_cash_calc(i).active_policy_id := pay_doc.active_pol;
        v_temp_cash_calc(i).active_pol_status_id := pay_doc.active_pol_st;
        v_temp_cash_calc(i).t_payment_term_id := pay_doc.payment_term_id;
        v_temp_cash_calc(i).is_indexing := pay_doc.idx;
        v_temp_cash_calc(i).insurance_period := pay_doc.insurance_period;
        v_temp_cash_calc(i).check_1 := pay_doc.insuer_not_agent;
        v_temp_cash_calc(i).check_2 := pay_doc.assured_not_agent;
        v_temp_cash_calc(i).policy_agent_part := 1; --pay_doc.direct_debt_coef;
      /*                      IF pay_doc.payment_term_id =g_pt_monthly AND pay_doc.epg_num<2 THEN
                                                                                                                                                 v_temp_cash_calc(i).POLICY_AGENT_PART:=3;
                                                                                                                                              ELSE v_temp_cash_calc(i).POLICY_AGENT_PART:=1;
                                                                                                                                              END IF;*/
      END LOOP;
    END LOOP;
  
    DECLARE
      errors NUMBER;
      dml_errors EXCEPTION;
      PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    BEGIN
      FORALL i IN 1 .. v_temp_cash_calc.count SAVE EXCEPTIONS
        INSERT INTO temp_cash_calc VALUES v_temp_cash_calc (i);
    EXCEPTION
      WHEN dml_errors THEN
        errors := SQL%bulk_exceptions.count;
        FOR i IN 1 .. errors
        LOOP
        
          IF SQL%BULK_EXCEPTIONS(i).error_code <> 1
          THEN
            raise_application_error(-20099, SQLERRM(-sql%BULK_EXCEPTIONS(i).error_code));
          END IF;
        END LOOP;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_cash;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:10:54
  -- Purpose : Подтовка данных по СГП за период
  PROCEDURE prepare_sgp IS
    proc_name VARCHAR2(20) := 'Prepare_SGP';
    v_attrs   pkg_tariff_calc.attr_type;
    v_koef    NUMBER;
  BEGIN
    DELETE FROM temp_sgp_calc;
    FOR pay_doc IN (SELECT pa.ag_contract_header_id
                          ,ph.policy_id active_policy
                          ,doc.get_doc_status_id(ph.policy_id, g_status_date) active_pol_st
                          ,pp.policy_id
                          ,pp.pol_header_id
                          ,ph.product_id
                          ,pt.id pay_term
                          ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                          ,doc.get_doc_status_id(pp.policy_id, g_status_date) policy_st
                          ,epg.payment_id epg
                          ,pt.number_of_payments
                          ,
                           -- doc.get_doc_status_id(epg.payment_id) epg_st,
                           ph.fund_id
                          ,(SELECT DISTINCT last_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pd
                          ,(SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ag_contract_header ach
                                  ,ag_contract        ac
                             WHERE ac.ag_contract_id =
                                   pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                 ,ph.start_date)
                               AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) <>
                                   g_st_berak
                               AND ach.agent_id =
                                   pkg_policy.get_policy_contact(ph.policy_id
                                                                ,'Страхователь')) insuer_not_agent
                          , --check1
                           (SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ven_as_assured va
                             WHERE va.p_policy_id = ph.policy_id
                               AND EXISTS
                             (SELECT 1
                                      FROM ag_contract_header ach1
                                          ,ag_contract        ac1
                                     WHERE ac1.ag_contract_id =
                                           pkg_agent_1.get_status_by_date(ach1.ag_contract_header_id
                                                                         ,ph.start_date)
                                       AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) <>
                                           g_st_berak
                                       AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                      FROM p_policy_agent      pa
                          ,policy_agent_status pas
                          ,p_policy            pp
                          ,p_pol_header        ph
                          ,t_product           tp
                          ,doc_doc             dd
                          ,ven_ac_payment      epg
                          ,doc_templ           epg_dt
                          ,t_payment_terms     pt
                     WHERE 1 = 1
                       AND pa.policy_header_id = ph.policy_header_id
                       AND pa.status_id = pas.policy_agent_status_id
                       AND pas.brief = 'CURRENT'
                       AND NOT EXISTS
                     (SELECT NULL
                              FROM p_policy_agent      pa2
                                  ,policy_agent_status pas2
                             WHERE pa2.policy_header_id = pa.policy_header_id
                               AND pa2.status_id = pas2.policy_agent_status_id
                               AND pa2.p_policy_agent_id <> pa.p_policy_agent_id
                               AND pas2.brief IN ('CANCEL', 'NEW'))
                       AND pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND tp.product_id IN (SELECT tc.criteria_1
                                               FROM t_prod_coef      tc
                                                   ,t_prod_coef_type tpc
                                              WHERE tpc.brief = 'Products_in_calc'
                                                AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                                AND tc.criteria_2 = 1)
                       AND nvl(tp.is_group, 0) = 0
                       AND pt.id NOT IN (g_pt_monthly, g_pt_quater)
                       AND ((doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                  ,g_status_date) NOT IN
                           (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
                           greatest((SELECT MAX(pay_d1.due_date)
                                        FROM doc_set_off    dso
                                            ,ven_ac_payment pay_d1
                                            ,doc_templ      pay_temp
                                       WHERE dso.parent_doc_id = epg.payment_id
                                         AND dso.child_doc_id = pay_d1.payment_id
                                         AND doc.get_doc_status_id(pay_d1.payment_id) <> g_st_annulated
                                         AND pay_d1.reg_date >= '01.04.2009'
                                         AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                         AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))
                                     ,CASE
                                        WHEN ph.start_date > '26.08.2009' THEN
                                         ph.start_date - 1
                                        ELSE
                                         ph.start_date
                                      END) < '26.08.2009') OR
                           (doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                  ,g_status_date) NOT IN
                           (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
                           doc.get_doc_status_id(pkg_renlife_utils.get_first_a_policy(ph.policy_header_id)
                                                  ,g_status_date) IN
                           (g_st_concluded, g_st_curr, g_st_stoped)))
                          --AND pp.policy_id = 10251142
                          --   AND ph.policy_header_id = 17464646
                       AND (SELECT doc.get_doc_status_id(pp1.policy_id, g_status_date)
                              FROM p_policy pp1
                             WHERE pp1.pol_header_id = ph.policy_header_id
                               AND pp1.version_num = 1) <> g_st_revision
                       AND ph.start_date >= '01.04.2009'
                          --                AND doc.get_doc_status_id(ph.policy_id) <> g_st_Revision
                       AND pp.policy_id = dd.parent_id
                       AND epg.payment_id = dd.child_id
                       AND epg.doc_templ_id = epg_dt.doc_templ_id
                       AND epg_dt.brief = 'PAYMENT'
                       AND epg.payment_number =
                           (SELECT MIN(acp2.payment_number)
                              FROM ac_payment acp2
                                  ,doc_doc    dd2
                                  ,p_policy   pp2
                             WHERE doc.get_doc_status_id(acp2.payment_id) = g_st_paid
                               AND acp2.payment_id = dd2.child_id
                               AND dd2.parent_id = pp2.policy_id
                               AND pp2.pol_header_id = ph.policy_header_id
                               AND acp2.plan_date =
                                   (SELECT MIN(acp3.plan_date) --BUG: заявка 24279 
                                      FROM ac_payment acp3
                                          ,doc_doc    dd3
                                          ,p_policy   pp3
                                     WHERE acp3.payment_number = 1
                                       AND acp3.payment_id = dd3.child_id
                                       AND dd3.parent_id = pp3.policy_id
                                       AND pp3.pol_header_id = ph.policy_header_id))
                       AND greatest((SELECT MAX(pay_d1.due_date)
                                      FROM doc_set_off    dso
                                          ,ven_ac_payment pay_d1
                                          ,doc_templ      pay_temp
                                     WHERE dso.parent_doc_id = epg.payment_id
                                       AND dso.child_doc_id = pay_d1.payment_id
                                       AND doc.get_doc_status_id(dso.doc_set_off_id) <> g_st_annulated
                                       AND pay_d1.due_date >= '29.05.2009'
                                       AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                       AND pay_temp.brief IN
                                           ('A7', 'PD4', 'ПП', 'ПП_ПС', 'ПП_ОБ'))
                                   ,CASE
                                      WHEN ph.start_date > g_date_end THEN
                                       ph.start_date - 1
                                      ELSE
                                       ph.start_date
                                    END) <= g_date_end
                          --BETWEEN g_date_begin AND g_date_end
                       AND ph.policy_header_id NOT IN
                           (SELECT pp1.pol_header_id --Нет в пердидущих расчетах сгп1
                              FROM ag_roll_type         art
                                  ,ven_ag_roll_header   arh
                                  ,ag_roll              ar
                                  ,ag_perfomed_work_act apw
                                  ,ag_perfom_work_det   apwd
                                  ,ag_rate_type         agrt
                                  ,ag_perfom_work_dpol  apd
                                  ,p_policy             pp1
                             WHERE substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
                               AND ar.ag_roll_header_id <> g_roll_header_id
                               AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                               AND arh.ag_roll_type_id = art.ag_roll_type_id
                               AND ar.ag_roll_header_id = arh.ag_roll_header_id
                               AND apw.ag_roll_id = ar.ag_roll_id
                               AND apwd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                               AND apwd.ag_rate_type_id = agrt.ag_rate_type_id
                               AND apd.ag_perfom_work_det_id = apwd.ag_perfom_work_det_id
                               AND pp1.policy_id = apd.policy_id))
    LOOP
    
      v_attrs.delete;
    
      v_attrs(1) := pay_doc.product_id;
      v_attrs(2) := pay_doc.pay_term;
      v_attrs(3) := pay_doc.insurance_period; --год страхования
      v_attrs(4) := 1; --ДАВ
      v_attrs(5) := to_char(g_date_end, 'YYYYMMDD');
      v_koef := nvl(pkg_tariff_calc.calc_coeff_val('SGP_koeff', v_attrs, 5), 0);
    
      FOR cover IN (SELECT ROUND(pc.fee *
                                 acc.get_cross_rate_by_id(1
                                                         ,pay_doc.fund_id
                                                         ,122
                                                         ,(SELECT MAX(pay_d1.reg_date)
                                                            FROM doc_set_off    dso
                                                                ,ven_ac_payment pay_d1
                                                                ,doc_templ      pay_temp
                                                           WHERE dso.parent_doc_id = pay_doc.epg
                                                             AND dso.child_doc_id = pay_d1.payment_id
                                                             AND pay_d1.doc_templ_id =
                                                                 pay_temp.doc_templ_id
                                                             AND pay_temp.brief IN
                                                                 ('A7'
                                                                 ,'PD4'
                                                                 ,'ПП'
                                                                 ,'ПП_ПС'
                                                                 ,'ПП_ОБ')))
                                ,2) * pay_doc.number_of_payments brutto_prem
                          ,pc.p_cover_id
                          ,tplo.id t_prod_line_option
                      FROM as_asset           ass
                          ,p_cover            pc
                          ,t_prod_line_option tplo
                          ,status_hist        sh
                     WHERE ass.p_policy_id = pay_doc.active_policy
                       AND ass.as_asset_id = pc.as_asset_id
                       AND pc.status_hist_id = sh.status_hist_id
                       AND sh.brief <> 'DELETED'
                       AND pc.t_prod_line_option_id = tplo.id
                       AND tplo.description <> 'Административные издержки')
      LOOP
        BEGIN
          INSERT INTO temp_sgp_calc
            (policy_id
            ,policy_status_id
            ,epg_payment_id
            ,pay_payment_id
            ,brutto_prem
            ,p_cover_id
            ,t_prod_line_option
            ,current_agent
            ,active_policy_id
            ,active_pol_status_id
            ,sgp_koef
            ,payment_term_id
            ,insurance_period
            ,check_1
            ,check_2)
          VALUES
            (pay_doc.policy_id
            ,pay_doc.policy_st
            ,pay_doc.epg
            ,pay_doc.pd
            ,cover.brutto_prem
            ,cover.p_cover_id
            ,cover.t_prod_line_option
            ,pay_doc.ag_contract_header_id
            ,pay_doc.active_policy
            ,pay_doc.active_pol_st
            ,v_koef
            ,pay_doc.pay_term
            ,pay_doc.insurance_period
            ,pay_doc.insuer_not_agent
            ,pay_doc.assured_not_agent);
        EXCEPTION
          WHEN dup_val_on_index THEN
            NULL;
        END;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_sgp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 31.08.2009 15:49:23
  -- Purpose : Расчет объемов для аттестации
  PROCEDURE prepare_attest_vol IS
    proc_name VARCHAR2(25) := 'Prepare_attest_vol';
    v_koef    NUMBER;
    i         PLS_INTEGER := 0;
  
    TYPE t_temp_cash_calc IS TABLE OF temp_cash_calc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_temp_sgp_calc IS TABLE OF temp_sgp_calc%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_temp_cash_calc t_temp_cash_calc;
    v_temp_sgp_calc  t_temp_sgp_calc;
  
  BEGIN
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег');
    DELETE FROM temp_cash_calc;
    FOR pay_doc IN (SELECT pp.policy_id policy
                          ,pa.ag_contract_header_id
                          ,pp.pol_header_id
                          ,pp.payment_term_id
                          ,ph.product_id
                          ,CASE
                             WHEN ((acpt.brief IN ('ПП_ПС', 'ПП_ОБ') OR
                                  bank_doc.brief IN ('ПП_ПС', 'ПП_ОБ')) AND
                                  ph.start_date BETWEEN '26.07.2009' AND '25.12.2009') THEN
                              CASE
                                WHEN EXISTS
                                 (SELECT NULL -- COUNT(apdpol.ag_perfom_work_dpol_id)
                                        FROM ag_roll              ar
                                            ,ag_roll_type         art
                                            ,ven_ag_roll_header   arh
                                            ,ag_perfomed_work_act apw
                                            ,ag_perfom_work_det   apdet
                                            ,ag_perfom_work_dpol  apdpol
                                            ,p_policy             pp1
                                       WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                                         AND arh.ag_roll_type_id = art.ag_roll_type_id
                                         AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
                                         AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                                         AND arh.ag_roll_header_id <> g_roll_header_id
                                         AND apw.ag_roll_id = ar.ag_roll_id
                                         AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                                         AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                                         AND pp1.policy_id = apdpol.policy_id
                                         AND pp1.pol_header_id = ph.policy_header_id
                                         AND apdpol.policy_agent_part = 3) THEN
                                 1
                                ELSE
                                 CASE
                                   WHEN row_number()
                                    over(PARTITION BY ph.policy_header_id
                                            ,decode(acpt.brief
                                                   ,'ПП_ПС'
                                                   ,1
                                                   ,'ПП_ОБ'
                                                   ,1
                                                   ,decode(bank_doc.brief, 'ПП_ПС', 1, 'ПП_ОБ', 1, 0)) ORDER BY
                                             pay_doc.due_date) = 1 THEN
                                    3
                                   ELSE
                                    1
                                 END
                              END
                             ELSE
                              1
                           END direct_debt_coef
                          ,nvl2((SELECT ppa.p_policy_id
                                  FROM p_pol_addendum_type ppa
                                      ,t_addendum_type     ta
                                 WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                   AND ta.brief = 'INDEXING2'
                                   AND ppa.p_policy_id = pp.policy_id)
                               ,1
                               ,0) idx
                          ,tp.is_group
                          ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph.start_date)) + 1 epg_num
                          ,CEIL(MONTHS_BETWEEN((SELECT pp_a.end_date
                                                 FROM p_policy pp_a
                                                WHERE pp_a.policy_id = ph.policy_id)
                                              ,ph.start_date) / 12) insurance_period
                          ,ph.policy_id active_pol
                          ,doc.get_doc_status_id(ph.policy_id, g_status_date) active_pol_st
                          ,doc.get_doc_status_id(pp.policy_id, g_status_date) policy_st
                          ,epg.payment_id epg
                          ,doc.get_doc_status_id(epg.payment_id) epg_st
                          ,pay_doc.payment_id pd
                          ,CASE
                             WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                              dso.doc_set_off_id
                             ELSE
                              bank_doc.doc_set_off_id
                           END set_off_doc
                          ,CASE
                             WHEN acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ') THEN
                              pay_doc.payment_id
                             ELSE
                              bank_doc.child_doc_id
                           END bank_doc
                          ,(SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ag_contract_header ach
                                  ,ag_contract        ac
                             WHERE ac.ag_contract_id =
                                   pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                 ,ph.start_date)
                               AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) <>
                                   g_st_berak
                               AND ach.agent_id =
                                   pkg_policy.get_policy_contact(ph.policy_id
                                                                ,'Страхователь')) insuer_not_agent
                          , --check1
                           (SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ven_as_assured va
                             WHERE va.p_policy_id = ph.policy_id
                               AND EXISTS
                             (SELECT 1
                                      FROM ag_contract_header ach1
                                          ,ag_contract        ac1
                                     WHERE ac1.ag_contract_id =
                                           pkg_agent_1.get_status_by_date(ach1.ag_contract_header_id
                                                                         ,ph.start_date)
                                       AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) <>
                                           g_st_berak
                                       AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                      FROM p_policy_agent pa
                          ,policy_agent_status pas
                          ,p_policy pp
                          ,p_pol_header ph
                          ,t_payment_terms pt
                          ,t_product tp
                          ,doc_doc dd
                          ,ven_ac_payment epg
                          ,doc_templ dt
                          ,doc_set_off dso
                          ,ven_ac_payment pay_doc
                          ,ac_payment_templ acpt
                          ,(SELECT dso2.child_doc_id
                                  ,dd2.parent_id
                                  ,dso2.doc_set_off_id
                                  ,dso2.parent_doc_id
                                  ,acpt2.brief
                              FROM doc_doc          dd2
                                  ,doc_set_off      dso2
                                  ,ac_payment       acp2
                                  ,ac_payment_templ acpt2
                             WHERE dso2.parent_doc_id = dd2.child_id
                               AND dso2.child_doc_id = acp2.payment_id
                               AND acp2.payment_templ_id = acpt2.payment_templ_id
                               AND doc.get_doc_status_id(dd2.child_id) = g_st_paid) bank_doc
                     WHERE 1 = 1
                       AND pa.policy_header_id = ph.policy_header_id
                       AND pa.status_id = pas.policy_agent_status_id
                       AND pas.brief = 'CURRENT'
                       AND (NOT EXISTS (SELECT NULL
                                          FROM p_policy_agent      pa2
                                              ,policy_agent_status pas2
                                         WHERE pa2.policy_header_id = pa.policy_header_id
                                           AND pa2.status_id = pas2.policy_agent_status_id
                                           AND pa2.p_policy_agent_id <> pa.p_policy_agent_id
                                           AND pas2.brief IN ('CANCEL', 'NEW')) OR EXISTS
                            (SELECT NULL
                               FROM p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND ppa.p_policy_id = pp.policy_id))
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND pp.payment_term_id = pt.id
                       AND (pt.id IN (g_pt_quater, g_pt_monthly) OR tp.is_group = 1 OR EXISTS
                            (SELECT 1
                               FROM p_pol_addendum_type ppa
                                   ,t_addendum_type     ta
                              WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2'
                                AND ppa.p_policy_id = pp.policy_id))
                       AND tp.product_id IN (SELECT tc.criteria_1
                                               FROM t_prod_coef      tc
                                                   ,t_prod_coef_type tpc
                                              WHERE tpc.brief = 'Products_in_calc'
                                                AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                                AND tc.criteria_2 = 4)
                       AND dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt.doc_templ_id = epg.doc_templ_id
                       AND ((doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                  ,g_status_date) NOT IN
                           (g_st_readycancel, g_st_stoped, g_st_berak, g_st_stop) AND
                           doc.get_doc_status_id(pkg_renlife_utils.get_first_a_policy(ph.policy_header_id)
                                                  ,g_status_date) IN
                           (g_st_concluded, g_st_curr, g_st_stoped)) OR
                           (greatest(CASE
                                        WHEN ph.start_date >= '26.08.2009' THEN
                                         ph.start_date - 1
                                        ELSE
                                         ph.start_date
                                      END
                                     ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) <
                           '26.08.2009' AND
                           nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,-10) NOT IN (g_st_readycancel, g_st_stoped, g_st_stop, g_st_berak)))
                       AND doc.get_doc_status_id(epg.payment_id) = g_st_paid
                       AND dt.brief = 'PAYMENT'
                       AND (((MONTHS_BETWEEN(epg.plan_date, ph.start_date) < 12) AND
                           ph.start_date > '31.12.2008') OR
                           (EXISTS (SELECT 1
                                       FROM p_pol_addendum_type ppa
                                           ,t_addendum_type     ta
                                      WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                        AND ta.brief = 'INDEXING2'
                                        AND ppa.p_policy_id = pp.policy_id) AND
                            MONTHS_BETWEEN(epg.plan_date, pp.start_date) < 12))
                       AND epg.plan_date <= g_date_end + 1
                       AND pay_doc.due_date BETWEEN g_date_begin AND CASE
                             WHEN pp.payment_term_id = g_pt_monthly
                                  AND nvl(bank_doc.brief, acpt.brief) IN ('ПП_ПС', 'ПП_ОБ') THEN
                              last_day(g_date_end) + 10
                             ELSE
                              g_date_end
                           END
                       AND (SELECT doc.get_doc_status_id(pp1.policy_id, g_status_date)
                              FROM p_policy pp1
                             WHERE pp1.pol_header_id = ph.policy_header_id
                               AND pp1.version_num = 1) <> g_st_revision
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_doc.payment_id
                          --AND greatest(pay_doc.due_date, epg.plan_date) > g_date_begin
                          --     AND g_date_end+0.1                 
                       AND doc.get_doc_status_id(pay_doc.payment_id) <> g_st_annulated
                       AND acpt.payment_templ_id = pay_doc.payment_templ_id
                       AND acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ', 'A7', 'PD4')
                       AND pay_doc.payment_id = bank_doc.parent_id(+))
    LOOP
      FOR trans IN (SELECT t.trans_id
                          ,tplo.id prod_line_option
                          ,CASE
                             WHEN pay_doc.idx = 1 THEN
                              t.trans_amount *
                              pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tplo.id, 3)
                             ELSE
                              t.trans_amount * pay_doc.direct_debt_coef
                           END trans_amount
                      FROM oper               o
                          ,trans              t
                          ,trans_templ        tt
                          ,p_cover            pc
                          ,t_prod_line_option tplo
                     WHERE o.oper_id = t.oper_id
                       AND t.trans_templ_id = tt.trans_templ_id
                       AND tt.brief IN ('СтраховаяПремияОплачена'
                                       ,'СтраховаяПремияАвансОпл'
                                       ,'ПремияОплаченаПоср'
                                       ,'ЗачВзнСтрАг')
                       AND t.obj_uro_id = pc.p_cover_id
                       AND pc.t_prod_line_option_id = tplo.id
                       AND o.document_id = pay_doc.set_off_doc
                       AND tplo.description <> 'Административные издержки'
                    
                    )
      LOOP
      
        i := v_temp_cash_calc.count + 1;
      
        v_temp_cash_calc(i).policy_id := pay_doc.policy;
        v_temp_cash_calc(i).policy_status_id := pay_doc.policy_st;
        v_temp_cash_calc(i).epg_payment_id := pay_doc.epg;
        v_temp_cash_calc(i).epg_status_id := pay_doc.epg_st;
        v_temp_cash_calc(i).pay_payment_id := pay_doc.pd;
        v_temp_cash_calc(i).pay_bank_doc_id := pay_doc.bank_doc;
        v_temp_cash_calc(i).trans_id := trans.trans_id;
        v_temp_cash_calc(i).trans_amount := trans.trans_amount;
        v_temp_cash_calc(i).t_prod_line_option_id := trans.prod_line_option;
        v_temp_cash_calc(i).current_agent := pay_doc.ag_contract_header_id;
        v_temp_cash_calc(i).is_group := pay_doc.is_group;
        v_temp_cash_calc(i).active_policy_id := pay_doc.active_pol;
        v_temp_cash_calc(i).active_pol_status_id := pay_doc.active_pol_st;
        v_temp_cash_calc(i).t_payment_term_id := pay_doc.payment_term_id;
        v_temp_cash_calc(i).insurance_period := pay_doc.insurance_period;
        v_temp_cash_calc(i).is_indexing := pay_doc.idx;
        v_temp_cash_calc(i).check_1 := pay_doc.insuer_not_agent;
        v_temp_cash_calc(i).check_2 := pay_doc.assured_not_agent;
        /*                      IF pay_doc.payment_term_id =g_pt_monthly AND pay_doc.epg_num<2 THEN
           v_temp_cash_calc(i).POLICY_AGENT_PART:=3;
        ELSE */
        v_temp_cash_calc(i).policy_agent_part := 1;
        -- END IF;                     
      END LOOP;
    END LOOP;
  
    pkg_agent_calculator.insertinfo('Расчет объемов СГП');
    i := 0;
    DELETE FROM temp_sgp_calc;
    FOR pay_doc IN (SELECT pa.ag_contract_header_id
                          ,ph.policy_id active_policy
                          ,doc.get_doc_status_id(ph.policy_id, g_status_date) active_pol_st
                          ,pp.policy_id
                          ,pp.pol_header_id
                          ,ph.product_id
                          ,pt.id pay_term
                          ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                          ,doc.get_doc_status_id(pp.policy_id, g_status_date) policy_st
                          ,epg.payment_id epg
                          ,pt.number_of_payments
                          ,ph.fund_id
                          ,(SELECT DISTINCT first_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pd
                          ,(SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ag_contract_header ach
                                  ,ag_contract        ac
                             WHERE ac.ag_contract_id =
                                   pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                 ,ph.start_date)
                               AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) <>
                                   g_st_berak
                               AND ach.agent_id =
                                   pkg_policy.get_policy_contact(ph.policy_id
                                                                ,'Страхователь')) insuer_not_agent
                          , --check1
                           (SELECT CASE
                                     WHEN COUNT(*) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ven_as_assured va
                             WHERE va.p_policy_id = ph.policy_id
                               AND EXISTS
                             (SELECT 1
                                      FROM ag_contract_header ach1
                                          ,ag_contract        ac1
                                     WHERE ac1.ag_contract_id =
                                           pkg_agent_1.get_status_by_date(ach1.ag_contract_header_id
                                                                         ,ph.start_date)
                                       AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) <>
                                           g_st_berak
                                       AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                      FROM p_policy_agent      pa
                          ,policy_agent_status pas
                          ,p_policy            pp
                          ,p_pol_header        ph
                          ,t_product           tp
                          ,doc_doc             dd
                          ,ven_ac_payment      epg
                          ,doc_templ           epg_dt
                          ,t_payment_terms     pt
                     WHERE 1 = 1
                       AND pa.policy_header_id = ph.policy_header_id
                       AND pa.status_id = pas.policy_agent_status_id
                       AND pas.brief = 'CURRENT'
                       AND NOT EXISTS
                     (SELECT NULL
                              FROM p_policy_agent      pa2
                                  ,policy_agent_status pas2
                             WHERE pa2.policy_header_id = pa.policy_header_id
                               AND pa2.status_id = pas2.policy_agent_status_id
                               AND pa2.p_policy_agent_id <> pa.p_policy_agent_id
                               AND pas2.brief IN ('CANCEL', 'NEW'))
                       AND pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND tp.product_id IN (SELECT tc.criteria_1
                                               FROM t_prod_coef      tc
                                                   ,t_prod_coef_type tpc
                                              WHERE tpc.brief = 'Products_in_calc'
                                                AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                                AND tc.criteria_2 = 4)
                       AND nvl(tp.is_group, 0) = 0
                       AND pt.id NOT IN (g_pt_monthly, g_pt_quater)
                       AND ((nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,-10) NOT IN (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
                           greatest((SELECT MAX(pay_d1.due_date)
                                        FROM doc_set_off    dso
                                            ,ven_ac_payment pay_d1
                                            ,doc_templ      pay_temp
                                       WHERE dso.parent_doc_id = epg.payment_id
                                         AND dso.child_doc_id = pay_d1.payment_id
                                         AND doc.get_doc_status_id(pay_d1.payment_id) <> g_st_annulated
                                         AND pay_d1.reg_date >= '01.04.2009'
                                         AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                         AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))
                                     ,CASE
                                        WHEN ph.start_date >= '26.08.2009' THEN
                                         ph.start_date - 1
                                        ELSE
                                         ph.start_date
                                      END) < '26.08.2009') OR
                           (doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                  ,g_status_date) NOT IN
                           (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
                           doc.get_doc_status_id(pkg_renlife_utils.get_first_a_policy(ph.policy_header_id)
                                                  ,g_status_date) IN
                           (g_st_concluded, g_st_curr, g_st_stoped, 81)))
                       AND (SELECT doc.get_doc_status_id(pp1.policy_id, g_status_date)
                              FROM p_policy pp1
                             WHERE pp1.pol_header_id = ph.policy_header_id
                               AND pp1.version_num = 1) <> g_st_revision
                       AND pp.policy_id = dd.parent_id
                       AND epg.payment_id = dd.child_id
                       AND epg.doc_templ_id = epg_dt.doc_templ_id
                       AND epg_dt.brief = 'PAYMENT'
                       AND epg.payment_number =
                           (SELECT MIN(acp2.payment_number)
                              FROM ac_payment acp2
                                  ,doc_doc    dd2
                                  ,p_policy   pp2
                             WHERE doc.get_doc_status_id(acp2.payment_id) = g_st_paid
                               AND acp2.payment_id = dd2.child_id
                               AND dd2.parent_id = pp2.policy_id
                               AND pp2.pol_header_id = ph.policy_header_id
                               AND acp2.plan_date =
                                   (SELECT MIN(acp3.plan_date) --BUG: заявка 24279 
                                      FROM ac_payment acp3
                                          ,doc_doc    dd3
                                          ,p_policy   pp3
                                     WHERE acp3.payment_number = 1
                                       AND acp3.payment_id = dd3.child_id
                                       AND dd3.parent_id = pp3.policy_id
                                       AND pp3.pol_header_id = ph.policy_header_id))
                       AND greatest((SELECT MAX(pay_d1.due_date)
                                      FROM doc_set_off    dso
                                          ,ven_ac_payment pay_d1
                                          ,doc_templ      pay_temp
                                     WHERE dso.parent_doc_id = epg.payment_id
                                       AND dso.child_doc_id = pay_d1.payment_id
                                       AND doc.get_doc_status_id(dso.doc_set_off_id) <> g_st_annulated
                                       AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                       AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))
                                   ,CASE
                                      WHEN ph.start_date > g_date_end THEN
                                       ph.start_date - 1
                                      WHEN ph.start_date <= g_date_begin THEN
                                       g_date_begin - 1
                                      ELSE
                                       ph.start_date
                                    END) BETWEEN g_date_begin AND g_date_end + 0.9999
                    /*AND GREATEST((SELECT MIN(pay_d1.due_date)
                     FROM doc_set_off dso,
                          ven_ac_payment pay_d1,
                          doc_templ pay_temp
                    WHERE dso.parent_doc_id = epg.payment_id
                      AND dso.child_doc_id = pay_d1.payment_id
                      AND doc.get_doc_status_id(pay_d1.payment_id)<>g_st_Annulated
                      AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                      AND pay_temp.brief IN ('A7','PD4','ПП')), 
                      decode(trunc(ph.start_date,'DD'),g_date_end+1,g_date_end,ph.start_date)) 
                          BETWEEN g_date_begin AND g_date_end+0.9999*/
                    
                    )
    LOOP
    
      v_koef := nvl(pkg_tariff_calc.calc_coeff_val('SGP_koeff'
                                                  ,t_number_type(pay_doc.product_id
                                                                ,pay_doc.pay_term
                                                                ,pay_doc.insurance_period
                                                                ,4
                                                                ,to_char(g_date_end, 'YYYYMMDD')))
                   ,0);
    
      FOR cover IN (SELECT ROUND(pc.fee *
                                 acc.get_cross_rate_by_id(1
                                                         ,pay_doc.fund_id
                                                         ,122
                                                         ,(SELECT MAX(pay_d1.reg_date)
                                                            FROM doc_set_off    dso
                                                                ,ven_ac_payment pay_d1
                                                                ,doc_templ      pay_temp
                                                           WHERE dso.parent_doc_id = pay_doc.epg
                                                             AND dso.child_doc_id = pay_d1.payment_id
                                                             AND pay_d1.doc_templ_id =
                                                                 pay_temp.doc_templ_id
                                                             AND pay_temp.brief IN ('A7', 'PD4', 'ПП')))
                                ,2) * pay_doc.number_of_payments brutto_prem
                          ,pc.p_cover_id
                          ,tplo.id t_prod_line_option
                      FROM as_asset           ass
                          ,p_cover            pc
                          ,t_prod_line_option tplo
                          ,status_hist        sh
                     WHERE ass.p_policy_id = pay_doc.active_policy
                       AND ass.as_asset_id = pc.as_asset_id
                       AND pc.status_hist_id = sh.status_hist_id
                       AND sh.brief <> 'DELETED'
                       AND pc.t_prod_line_option_id = tplo.id
                       AND tplo.description <> 'Административные издержки')
      LOOP
        i := v_temp_sgp_calc.count + 1;
      
        v_temp_sgp_calc(i).policy_id := pay_doc.policy_id;
        v_temp_sgp_calc(i).policy_status_id := pay_doc.policy_st;
        v_temp_sgp_calc(i).epg_payment_id := pay_doc.epg;
        v_temp_sgp_calc(i).pay_payment_id := pay_doc.pd;
        v_temp_sgp_calc(i).brutto_prem := cover.brutto_prem;
        v_temp_sgp_calc(i).p_cover_id := cover.p_cover_id;
        v_temp_sgp_calc(i).t_prod_line_option := cover.t_prod_line_option;
        v_temp_sgp_calc(i).current_agent := pay_doc.ag_contract_header_id;
        v_temp_sgp_calc(i).active_policy_id := pay_doc.active_policy;
        v_temp_sgp_calc(i).active_pol_status_id := pay_doc.active_pol_st;
        v_temp_sgp_calc(i).sgp_koef := v_koef;
        v_temp_sgp_calc(i).payment_term_id := pay_doc.pay_term;
        v_temp_sgp_calc(i).insurance_period := pay_doc.insurance_period;
        v_temp_sgp_calc(i).check_1 := pay_doc.insuer_not_agent;
        v_temp_sgp_calc(i).check_2 := pay_doc.assured_not_agent;
      
      END LOOP;
    END LOOP;
  
    DECLARE
      errors NUMBER;
      dml_errors EXCEPTION;
      PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    BEGIN
    
      FORALL i IN 1 .. v_temp_cash_calc.count SAVE EXCEPTIONS
        INSERT INTO temp_cash_calc VALUES v_temp_cash_calc (i);
    
      FORALL i IN 1 .. v_temp_sgp_calc.count SAVE EXCEPTIONS
        INSERT INTO temp_sgp_calc VALUES v_temp_sgp_calc (i);
    
    EXCEPTION
      WHEN dml_errors THEN
        errors := SQL%bulk_exceptions.count;
        FOR i IN 1 .. errors
        LOOP
        
          IF SQL%BULK_EXCEPTIONS(i).error_code <> 1
          THEN
            raise_application_error(-20099, SQLERRM(-sql%BULK_EXCEPTIONS(i).error_code));
          END IF;
        END LOOP;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END prepare_attest_vol;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.12.2010 22:55:20
  -- Purpose : Получает все типы объемов для акта (новая платформа учета ОП)
  FUNCTION get_nbv_for_act(p_ag_contract_header PLS_INTEGER) RETURN t_volume_val_o IS
    proc_name VARCHAR2(25) := 'Get_NBV_for_act';
    v_vol     t_volume_val_o := t_volume_val_o(NULL);
  BEGIN
  
    FOR r IN (SELECT av.ag_volume_type_id
                     /*изменения №174670, RL_VOL должно быть равно 0, если Страхователь = Агент*/
                    ,SUM(CASE
                           WHEN av.ag_volume_type_id IN (g_vt_life, g_vt_inv)
                                AND insurer.contact_id =
                                (SELECT agh.agent_id
                                       FROM ins.ag_contract_header agh
                                      WHERE agh.ag_contract_header_id = p_ag_contract_header) THEN
                            0
                           WHEN av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                                AND (SELECT upper(anv.fio)
                                       FROM ins.ag_npf_volume_det anv
                                      WHERE anv.ag_volume_id = av.ag_volume_id) =
                                (SELECT upper(c.obj_name_orig)
                                       FROM ins.ag_contract_header agh
                                           ,ins.contact            c
                                      WHERE agh.ag_contract_header_id = p_ag_contract_header
                                        AND agh.agent_id = c.contact_id) THEN
                            0
                           ELSE
                            (CASE
                              WHEN av.ag_volume_type_id IN (g_vt_ops_3, g_vt_ops_2, g_vt_ops, g_vt_ops_9) THEN
                               (CASE
                                 WHEN (SELECT nvl(anv.from_ret_to_pay, 0)
                                         FROM ins.ag_npf_volume_det anv
                                        WHERE anv.ag_volume_id = av.ag_volume_id) = 1 THEN
                                  0
                                 ELSE
                                  (av.trans_sum * av.nbv_coef)
                               END)
                              ELSE
                               (CASE
                                 WHEN nvl(av.index_delta_sum, 0) <> 0 THEN
                                 /*заявка №197959*/
                                  (av.index_delta_sum * (CASE
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id IN (g_pr_investor_lump, g_pr_investor_lump_old)) > 0
                                         AND av.ins_period = 3 THEN
                                     0.3
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id IN (g_pr_investor_lump, g_pr_investor_lump_old)) > 0
                                         AND av.ins_period = 5 THEN
                                     0.2
                                    ELSE
                                     av.nbv_coef
                                  END)
                                  
                                  )
                               /*THEN (av.index_delta_sum * av.nbv_coef)*/
                                 ELSE
                                  (av.trans_sum * (CASE
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id IN (g_pr_investor_lump, g_pr_investor_lump_old)) > 0
                                         AND av.ins_period = 3 THEN
                                     0.3
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id IN (g_pr_investor_lump, g_pr_investor_lump_old)) > 0
                                         AND av.ins_period = 5 THEN
                                     0.2
                                    ELSE
                                     av.nbv_coef
                                  END)
                                  
                                  )
                               /*ELSE (av.trans_sum * av.nbv_coef)*/
                               /**/
                               END)
                            END)
                         END) amt
                FROM ag_volume av
                     /*изменения №174670, найдем Страхователя*/
                    ,(SELECT ph.policy_header_id
                            ,ppc.contact_id
                        FROM ins.p_pol_header       ph
                            ,ins.p_policy           pol
                            ,ins.p_policy_contact   ppc
                            ,ins.t_contact_pol_role polr
                       WHERE ph.last_ver_id = pol.policy_id
                         AND pol.policy_id = ppc.policy_id
                         AND ppc.contact_policy_role_id = polr.id
                         AND polr.brief = 'Страхователь') insurer
                    ,
                     /**/ag_roll        ar
                    ,ag_roll_header arh
               WHERE 1 = 1
                 AND av.ag_volume_type_id NOT IN (g_vt_ops)
                 AND av.is_nbv = 1
                 AND ar.ag_roll_id = av.ag_roll_id
                 AND ar.ag_roll_header_id = arh.ag_roll_header_id
                 AND arh.date_end <= g_date_end
                 AND decode(av.ag_volume_type_id
                           ,g_vt_life
                           ,greatest(nvl(av.conclude_date, av.payment_date)
                                    ,av.payment_date
                                    ,av.date_begin)
                           ,g_vt_fdep
                           ,greatest(nvl(av.conclude_date, av.payment_date)
                                    ,av.payment_date
                                    ,av.date_begin)
                           ,g_vt_inv
                           ,greatest(nvl(av.conclude_date, av.payment_date)
                                    ,av.payment_date
                                    ,av.date_begin)
                           ,g_vt_ops
                           ,av.date_begin
                           ,g_vt_ops_2
                           ,av.date_begin
                           ,g_vt_ops_9
                           ,av.date_begin
                           ,g_vt_bank
                           ,av.date_begin
                           ,g_vt_nonevol
                           ,greatest(nvl(av.conclude_date, av.payment_date)
                                    ,av.payment_date
                                    ,av.date_begin)
                           ,g_date_end) >= g_cat_date
                 AND NOT EXISTS (SELECT NULL
                        FROM ag_perfomed_work_act apw
                            ,ag_perfom_work_det   apde
                            ,ag_perf_work_vol     apv
                            ,ag_roll              ar
                       WHERE apw.ag_contract_header_id IN
                             (SELECT p_ag_contract_header
                                FROM dual
                              UNION
                              SELECT apd.ag_prev_header_id
                                FROM ag_prev_dog apd
                               WHERE apd.ag_contract_header_id = p_ag_contract_header)
                         AND apw.ag_roll_id = ar.ag_roll_id
                         AND ar.ag_roll_header_id != g_roll_header_id
                         AND apw.ag_perfomed_work_act_id = apde.ag_perfomed_work_act_id
                         AND apde.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                         AND apv.ag_volume_id = av.ag_volume_id)
                 AND av.ag_contract_header_id IN
                     (SELECT p_ag_contract_header
                        FROM dual
                      UNION
                      SELECT apd.ag_prev_header_id
                        FROM ag_prev_dog apd
                       WHERE apd.ag_contract_header_id = p_ag_contract_header)
                    /*изменения №174670*/
                 AND av.policy_header_id = insurer.policy_header_id(+)
              /**/
               GROUP BY av.ag_volume_type_id)
    LOOP
    
      v_vol.set_volume(r.ag_volume_type_id, r.amt);
    
    END LOOP;
  
    RETURN v_vol;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_nbv_for_act;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 15:55:38
  -- Purpose : Получает значение NBV для агента
  -- nbv_type - тип объема из nbv_type (-1 - все)
  -- DEPRICATED - учет объемов переведен на акт
  FUNCTION get_nbv_value
  (
    p_ag_contract_header PLS_INTEGER
   ,nbv_type             PLS_INTEGER
  ) RETURN NUMBER IS
    v_nbv     NUMBER;
    proc_name VARCHAR2(25) := 'Get_NBV_value';
  BEGIN
  
    SELECT SUM(CASE
                 WHEN nvl(av.index_delta_sum, 0) <> 0 THEN
                  (av.index_delta_sum * av.nbv_coef)
                 ELSE
                  (av.trans_sum * av.nbv_coef)
               END)
      INTO v_nbv
      FROM ag_volume      av
          ,ag_roll        ar
          ,ag_roll_header arh
     WHERE (av.ag_volume_type_id = nbv_type OR
           (nbv_type = -1 AND av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc_pay)))
       AND av.is_nbv = 1
       AND ar.ag_roll_id = av.ag_roll_id
       AND ar.ag_roll_header_id = arh.ag_roll_header_id
       AND arh.date_end <= g_date_end
       AND decode(av.ag_volume_type_id
                 ,g_vt_life
                 ,greatest(nvl(av.conclude_date, av.payment_date), av.payment_date, av.date_begin)
                 ,g_vt_inv
                 ,greatest(nvl(av.conclude_date, av.payment_date), av.payment_date, av.date_begin)
                 ,g_vt_ops
                 ,av.date_begin
                 ,g_vt_ops_2
                 ,av.date_begin
                 ,g_vt_ops_9
                 ,av.date_begin
                 ,g_date_end) >= g_cat_date
       AND NOT EXISTS (SELECT NULL
              FROM ag_perfomed_work_act apw
                  ,ag_perfom_work_det   apde
                  ,ag_perf_work_vol     apv
                  ,ag_roll              ar
             WHERE apw.ag_contract_header_id IN
                   (SELECT p_ag_contract_header
                      FROM dual
                    UNION
                    SELECT apd.ag_prev_header_id
                      FROM ag_prev_dog apd
                     WHERE apd.ag_contract_header_id = p_ag_contract_header)
               AND apw.ag_roll_id = ar.ag_roll_id
               AND ar.ag_roll_header_id != g_roll_header_id
               AND apw.ag_perfomed_work_act_id = apde.ag_perfomed_work_act_id
               AND apde.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
               AND apv.ag_volume_id = av.ag_volume_id)
       AND av.ag_contract_header_id IN
           (SELECT p_ag_contract_header
              FROM dual
            UNION
            SELECT apd.ag_prev_header_id
              FROM ag_prev_dog apd
             WHERE apd.ag_contract_header_id = p_ag_contract_header);
  
    RETURN(v_nbv);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_nbv_value;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 16:08:42
  -- Purpose : Получает значение КСП для мотивации действующей с 25052010
  FUNCTION get_ksp_value(p_ag_contract_header PLS_INTEGER) RETURN NUMBER IS
    proc_name   VARCHAR2(25) := 'Get_KSP_value';
    v_ksp_value NUMBER;
  BEGIN
  
    SELECT ak.ksp_value
      INTO v_ksp_value
      FROM ven_ag_roll_header   arh
          ,ag_roll              ar
          ,ag_perfomed_work_act apw
          ,ag_ksp               ak
     WHERE arh.ag_roll_header_id = ar.ag_roll_header_id
       AND ar.ag_roll_id = apw.ag_roll_id
       AND apw.ag_perfomed_work_act_id = ak.document
       AND arh.ag_roll_header_id = g_ksp_vedom
       AND apw.ag_contract_header_id = p_ag_contract_header;
  
    RETURN(v_ksp_value);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_ksp_value;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 02.12.2010 12:12:22
  -- Purpose : Фиктивная премия для учета будущих платежей по СОФИ
  PROCEDURE fake_sofi_prem_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'FAKE_Sofi_prem_0510';
    v_ag_ch_id PLS_INTEGER;
  BEGIN
    SELECT apw.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    FOR vol IN (SELECT av.ag_volume_id
                  FROM ins.ag_volume      av
                      ,ins.ag_roll        ar
                      ,ins.ag_roll_header arh
                      ,ins.ag_roll_type   art
                 WHERE 1 = 1
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'CASH_VOL'
                   AND nvl(ar.date_begin, arh.date_begin) <= g_date_begin
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id)
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND apw.ag_contract_header_id = v_ag_ch_id)
                   AND av.ag_volume_type_id = g_vt_avc)
    LOOP
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END fake_sofi_prem_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 19.10.2010 15:58:17
  -- Purpose : Расчет премии "Бонус 200"
  PROCEDURE bonus_200_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Bonus_200_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_commiss     NUMBER;
    vp_ret_pay    PLS_INTEGER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
          ,ag_contract_header   ach
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND ach.ag_contract_header_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT av.ag_volume_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND c.contact_id = agh.agent_id) agent_fio
                      ,upper(anv.fio) ins_fio
                  FROM ins.ag_volume         av
                      ,ins.ag_npf_volume_det anv
                      ,ins.ag_roll           ar
                      ,ins.ag_roll_header    arh
                      ,ins.ag_roll_type      art
                 WHERE 1 = 1
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_begin, arh.date_begin) <= g_date_begin
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'CASH_VOL'
                   AND anv.ag_volume_id = av.ag_volume_id
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id)
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apd.ag_rate_type_id = v_rate_type)
                      --   AND av.Is_Nbv = 1
                   AND av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                   AND anv.ops_is_seh = 1
                   AND anv.assured_birf_date >= to_date('01.01.1967', 'dd.mm.yyyy')
                   AND FLOOR(MONTHS_BETWEEN(anv.sign_date, anv.assured_birf_date) / 12) >= 18
                      /***********заявка №162959************************/
                   AND EXISTS
                 (SELECT NULL
                          FROM ins.ag_contract       ag
                              ,ins.ag_category_agent cat
                         WHERE ag.contract_id = v_ag_ch_id
                           AND cat.ag_category_agent_id = ag.category_id
                           AND (anv.sign_date - to_number(to_char(last_day(anv.sign_date), 'DD'))) BETWEEN
                               ag.date_begin AND ag.date_end
                           AND cat.brief = 'AG')
                /******************************/
                )
    LOOP
    
      CASE g_leg_pos
        WHEN g_cn_legentity THEN
          v_commiss := 200;
        WHEN g_cn_legal THEN
          v_commiss := 200;
        WHEN g_cn_natperson THEN
          v_commiss := 180;
        ELSE
          v_commiss := 0;
      END CASE;
      /*изменения №174670*/
      IF vol.agent_fio = vol.ins_fio
      THEN
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
        g_commision := g_commision + 0;
        /**/
      ELSE
        /*Удержание ОПС*/
        BEGIN
          SELECT nvl(det.from_ret_to_pay, 0) from_ret_to_pay
                ,det.snils
            INTO vp_ret_pay
                ,vp_ret_snils
            FROM ins.ag_npf_volume_det det
           WHERE det.ag_volume_id = vol.ag_volume_id;
        EXCEPTION
          WHEN no_data_found THEN
            vp_ret_pay := -1;
        END;
        IF vp_ret_pay = 99
        THEN
          --99 перешли на 8
          BEGIN
            SELECT -apv.vol_amount
                  ,
                   -- -(agv.trans_sum * agv.nbv_coef),
                   SUM(apv.vol_rate) vol_rate
              INTO vp_ret_amount
                  ,vp_ret_rate
              FROM ins.ag_roll_header       arh
                  ,ins.ven_ag_roll          ar
                  ,ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det   apd
                  ,ins.ag_rate_type         art
                  ,ins.ag_perf_work_vol     apv
                  ,ins.ag_volume            agv
                  ,ins.ag_volume_type       avt
                  ,ins.ag_npf_volume_det    anv
             WHERE 1 = 1
               AND arh.ag_roll_header_id = g_roll_header_id
               AND ar.ag_roll_id != g_roll_id
               AND ar.ag_roll_id = apw.ag_roll_id
               AND arh.ag_roll_header_id = ar.ag_roll_header_id
               AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
               AND art.ag_rate_type_id = apd.ag_rate_type_id
               AND apv.ag_volume_id = agv.ag_volume_id
               AND agv.ag_volume_id(+) = anv.ag_volume_id
               AND agv.ag_volume_type_id = avt.ag_volume_type_id
               AND avt.brief IN ('NPF', 'NPF02')
               AND art.brief = 'bonus_200'
               AND anv.snils = vp_ret_snils
               AND nvl(anv.from_ret_to_pay, 0) = 0
             GROUP BY apv.vol_amount;
          EXCEPTION
            WHEN no_data_found THEN
              vp_ret_pay := -1;
          END;
          IF vp_ret_pay != -1
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
            g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
            g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
          END IF;
        ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
        THEN
          --не равно 0 - перешли с 8 на 1
          BEGIN
            SELECT -apv.vol_amount
                  ,
                   -- -(agv.trans_sum * agv.nbv_coef),
                   SUM(apv.vol_rate) vol_rate
              INTO vp_ret_amount
                  ,vp_ret_rate
              FROM ins.ag_roll_header       arh
                  ,ins.ven_ag_roll          ar
                  ,ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det   apd
                  ,ins.ag_rate_type         art
                  ,ins.ag_perf_work_vol     apv
                  ,ins.ag_volume            agv
                  ,ins.ag_volume_type       avt
                  ,ins.ag_npf_volume_det    anv
             WHERE 1 = 1
               AND ar.ag_roll_id != g_roll_id
               AND ar.ag_roll_id = apw.ag_roll_id
               AND arh.ag_roll_header_id = ar.ag_roll_header_id
               AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
               AND art.ag_rate_type_id = apd.ag_rate_type_id
               AND apv.ag_volume_id = agv.ag_volume_id
               AND agv.ag_volume_id(+) = anv.ag_volume_id
               AND agv.ag_volume_type_id = avt.ag_volume_type_id
               AND avt.brief IN ('NPF', 'NPF02')
               AND art.brief = 'bonus_200'
               AND anv.snils = vp_ret_snils
               AND nvl(anv.from_ret_to_pay, 0) = 99
               AND NOT EXISTS (SELECT NULL
                      FROM ins.ag_npf_volume_det    d
                          ,ins.ag_perf_work_vol     vl
                          ,ins.ag_perfom_work_det   det
                          ,ins.ag_perfomed_work_act act
                     WHERE d.snils = anv.snils
                       AND nvl(d.from_ret_to_pay, 0) = 1
                       AND d.ag_volume_id = vl.ag_volume_id
                       AND vl.ag_volume_id = vol.ag_volume_id
                       AND vl.ag_perfom_work_det_id = det.ag_perfom_work_det_id
                       AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
                       AND det.ag_rate_type_id = art.ag_rate_type_id)
             GROUP BY apv.vol_amount;
          EXCEPTION
            WHEN no_data_found THEN
              vp_ret_pay := -1;
          END;
          IF vp_ret_pay != -1
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
            g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
            g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
          END IF;
          /**/
        ELSE
          INSERT INTO ven_ag_perf_work_vol
            (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
          VALUES
            (p_ag_perf_work_det_id, vol.ag_volume_id, v_commiss, 1);
        
          g_commision := g_commision + v_commiss;
        END IF;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '-' || p_ag_perf_work_det_id || ' ' ||
                              SQLERRM);
  END bonus_200_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.09.2010
  -- Purpose : Расчет премии за размер инидвидуального пенсионного счета клиента
  PROCEDURE ips_ops_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Qualitative_OPS_0510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_commiss     NUMBER;
  BEGIN
    /*
    TODO: owner="alexey.katkevich" category="Optimize" priority="2 - Medium" created="19.10.2010"
    text="Переделать определение ИПС на справочник"
    */
    SELECT apw.ag_level
          ,apw.ag_contract_header_id
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apd.ag_rate_type_id
      INTO v_level
          ,v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
          ,t_sales_channel      chac
          ,ag_contract_header   ach
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND ac.ag_sales_chn_id = chac.id(+)
       AND ach.ag_contract_header_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT avi.ips_year
                      ,avi.ips_summ
                      ,av.ag_volume_id
                  FROM ins.ag_volume         av
                      ,etl.npf_ips           avi
                      ,ins.ag_npf_volume_det anv
                      ,ins.ag_roll           ar
                      ,ins.ag_roll_header    arh
                 WHERE 1 = 1
                   AND avi.snils = substr(anv.policy_num, instr(anv.policy_num, '-') + 1, 11)
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_begin, arh.date_begin) <= g_date_begin
                   AND anv.ag_volume_id = av.ag_volume_id
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id)
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apd.ag_rate_type_id = v_rate_type)
                   AND av.is_nbv = 1
                   AND av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9))
    LOOP
    
      v_commiss := nvl(pkg_tariff_calc.calc_coeff_val('IPS_AWARD'
                                                     ,t_number_type(extract(YEAR FROM vol.ips_year)
                                                                   ,vol.ips_summ
                                                                   ,g_leg_pos))
                      ,0);
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol.ag_volume_id, v_commiss, 1);
    
      g_commision := g_commision + v_commiss;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ips_ops_0510;

  -- Author  : VESELEK
  -- Created : 31.10.2012
  -- Purpose : Расчет дополнительной премии САВ №2 по ОПС
  PROCEDURE extra_sav_ops(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'EXTRA_SAV_OPS';
    v_ag_ch_id    PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_commiss     NUMBER;
    v_rate        NUMBER;
    vp_ret_pay    PLS_INTEGER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    IF g_leg_pos = 3
    THEN
      v_rate := 150;
    ELSE
      v_rate := 167;
    END IF;
  
    FOR vol IN (SELECT av.ag_volume_id
                      ,anv.assured_birf_date
                      ,CASE
                         WHEN anv.assured_birf_date BETWEEN to_date('01.01.1967', 'DD.MM.YYYY') AND
                              to_date('31.12.1982', 'DD.MM.YYYY') THEN
                          1
                         ELSE
                          0
                       END is_nbv
                      ,COUNT(av.ag_volume_id) over(PARTITION BY 1) count_ops
                  FROM ins.ag_volume         av
                      ,ins.ag_npf_volume_det anv
                      ,ins.ag_roll           ar
                      ,ins.ag_roll_header    arh
                 WHERE 1 = 1
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_begin, arh.date_begin) <= g_date_begin
                   AND anv.ag_volume_id = av.ag_volume_id
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id)
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apd.ag_rate_type_id = v_rate_type)
                   AND av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                   AND anv.sign_date >= to_date('25.10.2012', 'DD.MM.YYYY'))
    LOOP
      IF vol.count_ops >= 20
      THEN
        IF vol.is_nbv = 1
        THEN
          /**/
          /*Удержание ОПС*/
          BEGIN
            SELECT nvl(det.from_ret_to_pay, 0) from_ret_to_pay
                  ,det.snils
              INTO vp_ret_pay
                  ,vp_ret_snils
              FROM ins.ag_npf_volume_det det
             WHERE det.ag_volume_id = vol.ag_volume_id;
          EXCEPTION
            WHEN no_data_found THEN
              vp_ret_pay := -1;
          END;
          IF vp_ret_pay = 99
          THEN
            --99 перешли на 8
            BEGIN
              SELECT -apv.vol_amount
                    ,SUM(apv.vol_rate) vol_rate
                INTO vp_ret_amount
                    ,vp_ret_rate
                FROM ins.ag_roll_header       arh
                    ,ins.ven_ag_roll          ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            agv
                    ,ins.ag_volume_type       avt
                    ,ins.ag_npf_volume_det    anv
               WHERE 1 = 1
                 AND arh.ag_roll_header_id = g_roll_header_id
                 AND ar.ag_roll_id != g_roll_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND art.ag_rate_type_id = apd.ag_rate_type_id
                 AND apv.ag_volume_id = agv.ag_volume_id
                 AND agv.ag_volume_id(+) = anv.ag_volume_id
                 AND agv.ag_volume_type_id = avt.ag_volume_type_id
                 AND avt.brief IN ('NPF', 'NPF02')
                 AND art.brief = 'EXTRA_SAV_OPS'
                 AND anv.snils = vp_ret_snils
                 AND nvl(anv.from_ret_to_pay, 0) = 0
               GROUP BY apv.vol_amount;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay != -1
            THEN
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
              g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
            END IF;
          ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
          THEN
            --не равно 0 - перешли с 8 на 1
            BEGIN
              SELECT -apv.vol_amount
                    ,SUM(apv.vol_rate) vol_rate
                INTO vp_ret_amount
                    ,vp_ret_rate
                FROM ins.ag_roll_header       arh
                    ,ins.ven_ag_roll          ar
                    ,ins.ag_perfomed_work_act apw
                    ,ins.ag_perfom_work_det   apd
                    ,ins.ag_rate_type         art
                    ,ins.ag_perf_work_vol     apv
                    ,ins.ag_volume            agv
                    ,ins.ag_volume_type       avt
                    ,ins.ag_npf_volume_det    anv
               WHERE 1 = 1
                 AND ar.ag_roll_id != g_roll_id
                 AND ar.ag_roll_id = apw.ag_roll_id
                 AND arh.ag_roll_header_id = ar.ag_roll_header_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                 AND art.ag_rate_type_id = apd.ag_rate_type_id
                 AND apv.ag_volume_id = agv.ag_volume_id
                 AND agv.ag_volume_id(+) = anv.ag_volume_id
                 AND agv.ag_volume_type_id = avt.ag_volume_type_id
                 AND avt.brief IN ('NPF', 'NPF02')
                 AND art.brief = 'EXTRA_SAV_OPS'
                 AND anv.snils = vp_ret_snils
                 AND nvl(anv.from_ret_to_pay, 0) = 99
                 AND NOT EXISTS (SELECT NULL
                        FROM ins.ag_npf_volume_det    d
                            ,ins.ag_perf_work_vol     vl
                            ,ins.ag_perfom_work_det   det
                            ,ins.ag_perfomed_work_act act
                       WHERE d.snils = anv.snils
                         AND nvl(d.from_ret_to_pay, 0) = 1
                         AND d.ag_volume_id = vl.ag_volume_id
                         AND vl.ag_volume_id = vol.ag_volume_id
                         AND vl.ag_perfom_work_det_id = det.ag_perfom_work_det_id
                         AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
                         AND det.ag_rate_type_id = art.ag_rate_type_id)
               GROUP BY apv.vol_amount;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay != -1
            THEN
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
              g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
            END IF;
            /**/
          ELSE
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 1, v_rate);
          
            g_commision := g_commision + v_commiss;
          END IF;
          /**/
          /*INSERT INTO ven_ag_perf_work_vol 
                    (ag_perfom_work_det_id,
                    ag_volume_id,
                    vol_amount,
                    vol_rate)
             VALUES (p_ag_perf_work_det_id,
                    vol.ag_volume_id,
                    1,
                    v_rate);
          
          g_commision:=g_commision+v_commiss;*/
        
        END IF;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END extra_sav_ops;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.06.2010 12:08:18
  -- Purpose : Премия за качественные договоры ОПС
  PROCEDURE q_male_ops_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'Q_Male_OPS_0510';
    v_ag_ch_id  PLS_INTEGER;
    v_rate      NUMBER;
    v_rate_type PLS_INTEGER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    /*
    TODO: owner="alexey.katkevich" created="23.07.2010"
    text="Сделать определение ставки за дс со страхователями мужчинами через справочник"
    */
  
    IF g_leg_pos = 3
    THEN
      v_rate := 0.17;
    ELSE
      v_rate := 0.2;
    END IF;
  
    FOR vol IN (SELECT av.*
                      ,anv.gender
                  FROM ins.ag_volume         av
                      ,ins.ag_npf_volume_det anv
                      ,ins.ag_roll           ar
                      ,ins.ag_roll_header    arh
                 WHERE av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                   AND av.is_nbv = 1
                   AND anv.gender = 1
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND anv.sign_date >= g_cat_date
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id IN
                               (SELECT apd.ag_prev_header_id
                                  FROM ag_prev_dog apd
                                 WHERE apd.ag_contract_header_id = v_ag_ch_id
                                UNION ALL
                                SELECT v_ag_ch_id
                                  FROM dual)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_id != g_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id)
                   AND av.ag_volume_id = anv.ag_volume_id
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id))
    LOOP
      g_commision := g_commision + v_rate * vol.trans_sum /** vol.nbv_coef*/
       ;
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum /** vol.nbv_coef*/, v_rate);
    END LOOP;
  
    UPDATE ag_perfom_work_det a
       SET a.summ = g_commision
     WHERE a.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_male_ops_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 16:19:29
  -- Purpose : Производит расчет ОАВ для мотивации с 25052010
  PROCEDURE get_oav_250510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Get_OAV_250510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_sav_gp      PLS_INTEGER;
    v_sav         NUMBER;
    v_ind_sav     NUMBER;
    v_comon_sav   NUMBER;
    v_payed_sav   NUMBER;
    v_nonrec      PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_individ_sav PLS_INTEGER;
    vp_ret_pay    PLS_INTEGER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apw.ag_level
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_level
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    FOR vol IN (SELECT av.*
                      ,(SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,insurer.contact_id insrl
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id) agent_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_fio
                  FROM ins.ag_volume av
                       /*изменения №174670, найдем Страхователя*/
                      ,(SELECT ph.policy_header_id
                              ,ppc.contact_id
                          FROM ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.p_policy_contact   ppc
                              ,ins.t_contact_pol_role polr
                         WHERE ph.last_ver_id = pol.policy_id
                           AND pol.policy_id = ppc.policy_id
                           AND ppc.contact_policy_role_id = polr.id
                           AND polr.brief = 'Страхователь') insurer
                      ,ins.ag_roll ar
                      ,ins.ag_roll_header arh
                      ,ins.ag_roll_type art
                 WHERE av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc, g_vt_ops) /*((av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc) AND
                                                                                                                                                                                                                                                                                                                                                                                                                                   g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                                                                                                                                                                                                                                                                                                                                                                                                                                   (av.ag_volume_type_id NOT IN
                                                                                                                                                                                                                                                                                                                                                                                                                                   (g_vt_ops, g_vt_ops_2, g_vt_ops_9, g_vt_nonevol, g_vt_avc) AND
                                                                                                                                                                                                                                                                                                                                                                                                                                   g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))*/
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'CASH_VOL'
                      /*изменения №174670*/
                   AND av.policy_header_id = insurer.policy_header_id(+)
                      /**/
                   AND decode(av.ag_volume_type_id
                             ,g_vt_life
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_fdep
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_inv
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_ops
                             ,av.date_begin
                             ,g_vt_ops_2
                             ,av.date_begin
                             ,g_vt_ops_9
                             ,av.date_begin
                             ,g_date_end) >= g_cat_date
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id IN
                               (SELECT apd.ag_prev_header_id
                                  FROM ag_prev_dog apd
                                 WHERE apd.ag_contract_header_id = v_ag_ch_id
                                UNION ALL
                                SELECT v_ag_ch_id
                                  FROM dual)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id != g_roll_header_id)
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id))
    LOOP
    
      v_payed_sav := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                     ,v_rate_type
                                                     ,v_ag_ch_id
                                                     ,vol.ag_volume_id);
    
      CASE
        WHEN vol.ag_volume_type_id IN (g_vt_life, g_vt_fdep) THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_id
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            --функция Индивидуальных ставок (по конкретному pol_header_id), если возвращает 999, то не нашел такой
            --договор и рассчитываем САВ как обычно, по группам ставок
            --(по сути "заплатка", но надо было впихнуть
            IF vol.pay_period = 1
            THEN
              v_individ_sav := nvl(pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                                 ,t_number_type(vol.policy_header_id))
                                  ,999);
            ELSE
              v_individ_sav := 999;
            END IF;
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id
                                                                    ,g_sales_ch));
          
            --2) Определяем ставку
            CASE
              WHEN vol.payment_term_id = g_pt_nonrecurring THEN
                v_nonrec := 1;
              ELSE
                v_nonrec := 0;
            END CASE;
          
            v_ind_sav := 0;
            IF nvl(vol.index_delta_sum, 0) <> 0
            THEN
              CASE
                WHEN v_individ_sav <> 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                             ,t_number_type(vol.policy_header_id));
                WHEN v_sav_gp <= 3
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_level));
                WHEN v_sav_gp = 4
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_nonrec
                                                                           ,v_level));
                WHEN v_sav_gp = 5
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,1
                                                                           ,v_level));
                WHEN v_sav_gp IN (6, 7)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_level));
                WHEN v_sav_gp IN (8)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_level
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 9
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
                WHEN v_sav_gp = 10
                     AND v_individ_sav = 999 THEN
                
                  DECLARE
                    v_ins_age PLS_INTEGER;
                  BEGIN
                    SELECT FLOOR(pc.insured_age)
                      INTO v_ins_age
                      FROM p_cover pc
                          ,trans   t
                     WHERE t.obj_uro_id = pc.p_cover_id
                       AND t.trans_id = vol.trans_id;
                  
                    v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                               ,t_number_type(g_leg_pos
                                                                             ,v_level
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,g_sales_ch
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 12
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 29
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,vol.pay_period
                                                                           ,v_level
                                                                           ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,g_category_id));
                WHEN v_sav_gp = 30
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,vol.pay_period
                                                                           ,v_level));
                  /*------------------------------------------------------------------------*/
              
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            
            END IF;
          
            CASE
              WHEN v_individ_sav <> 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('ind_sav', t_number_type(vol.policy_header_id));
              WHEN v_sav_gp <= 3
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_level));
              WHEN v_sav_gp = 4
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_nonrec
                                                                     ,v_level));
              WHEN v_sav_gp = 5
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level));
              WHEN v_sav_gp IN (6, 7)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch, g_leg_pos, v_level));
              WHEN v_sav_gp IN (8)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 9
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
              WHEN v_sav_gp = 10
                   AND v_individ_sav = 999 THEN
              
                DECLARE
                  v_ins_age PLS_INTEGER;
                BEGIN
                  SELECT FLOOR(pc.insured_age)
                    INTO v_ins_age
                    FROM p_cover pc
                        ,trans   t
                   WHERE t.obj_uro_id = pc.p_cover_id
                     AND t.trans_id = vol.trans_id;
                
                  v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                         ,t_number_type(g_leg_pos
                                                                       ,v_level
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,g_sales_ch
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 12
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 29
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,g_category_id));
              WHEN v_sav_gp = 30
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level));
                /*------------------------------------------------------------------------*/
              ELSE
                v_sav := 0;
            END CASE;
          
            v_sav       := nvl(v_sav, 0) / 100;
            v_comon_sav := v_sav + v_ind_sav;
          
            IF v_payed_sav IS NOT NULL
            THEN
              IF v_comon_sav != 0
              THEN
                v_sav     := (v_comon_sav - v_payed_sav) * v_sav / v_comon_sav;
                v_ind_sav := (v_comon_sav - v_payed_sav) * v_ind_sav / v_comon_sav;
              END IF;
            END IF;
          
            IF v_payed_sav IS NULL
               OR v_payed_sav != v_comon_sav
            THEN
            
              -- Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id
                ,vol.ag_volume_id
                ,nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                g_sgp1      := g_sgp1 + nvl(vol.index_delta_sum, 0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id = g_vt_inv THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_id
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            --функция Индивидуальных ставок (по конкретному pol_header_id), если возвращает 999, то не нашел такой
            --договор и рассчитываем САВ как обычно, по группам ставок
            --(по сути "заплатка", но надо было впихнуть
            IF vol.pay_period = 1
            THEN
              v_individ_sav := nvl(pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                                 ,t_number_type(vol.policy_header_id))
                                  ,999);
            ELSE
              v_individ_sav := 999;
            END IF;
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id
                                                                    ,g_sales_ch));
          
            --2) Определяем ставку
            CASE
              WHEN vol.payment_term_id = g_pt_nonrecurring THEN
                v_nonrec := 1;
              ELSE
                v_nonrec := 0;
            END CASE;
          
            v_ind_sav := 0;
            IF nvl(vol.index_delta_sum, 0) <> 0
            THEN
              CASE
                WHEN v_individ_sav <> 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                             ,t_number_type(vol.policy_header_id));
                WHEN v_sav_gp <= 3
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_level));
                WHEN v_sav_gp = 4
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_nonrec
                                                                           ,v_level));
                WHEN v_sav_gp = 5
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,1
                                                                           ,v_level));
                WHEN v_sav_gp IN (6, 7)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_level));
                WHEN v_sav_gp IN (8)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,v_level
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 9
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
                WHEN v_sav_gp = 10
                     AND v_individ_sav = 999 THEN
                
                  DECLARE
                    v_ins_age PLS_INTEGER;
                  BEGIN
                    SELECT FLOOR(pc.insured_age)
                      INTO v_ins_age
                      FROM p_cover pc
                          ,trans   t
                     WHERE t.obj_uro_id = pc.p_cover_id
                       AND t.trans_id = vol.trans_id;
                  
                    v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                               ,t_number_type(g_leg_pos
                                                                             ,v_level
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,g_sales_ch
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 12
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 29
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,g_leg_pos
                                                                           ,vol.pay_period
                                                                           ,v_level
                                                                           ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,g_category_id));
                WHEN v_sav_gp = 30
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_leg_pos
                                                                           ,vol.pay_period
                                                                           ,v_level));
                  /*------------------------------------------------------------------------*/
              
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            
            END IF;
          
            CASE
              WHEN v_individ_sav <> 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('ind_sav', t_number_type(vol.policy_header_id));
              WHEN v_sav_gp <= 3
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_level));
              WHEN v_sav_gp = 4
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_nonrec
                                                                     ,v_level));
              WHEN v_sav_gp = 5
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level));
              WHEN v_sav_gp IN (6, 7)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch, g_leg_pos, v_level));
              WHEN v_sav_gp IN (8)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 9
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
              WHEN v_sav_gp = 10
                   AND v_individ_sav = 999 THEN
              
                DECLARE
                  v_ins_age PLS_INTEGER;
                BEGIN
                  SELECT FLOOR(pc.insured_age)
                    INTO v_ins_age
                    FROM p_cover pc
                        ,trans   t
                   WHERE t.obj_uro_id = pc.p_cover_id
                     AND t.trans_id = vol.trans_id;
                
                  v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                         ,t_number_type(g_leg_pos
                                                                       ,v_level
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,g_sales_ch
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 12
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 29
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,g_category_id));
              WHEN v_sav_gp = 30
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_leg_pos
                                                                     ,vol.pay_period
                                                                     ,v_level));
                /*------------------------------------------------------------------------*/
              ELSE
                v_sav := 0;
            END CASE;
          
            v_sav       := nvl(v_sav, 0) / 100;
            v_comon_sav := v_sav + v_ind_sav;
          
            IF v_payed_sav IS NOT NULL
            THEN
              IF v_comon_sav != 0
              THEN
                v_sav     := (v_comon_sav - v_payed_sav) * v_sav / v_comon_sav;
                v_ind_sav := (v_comon_sav - v_payed_sav) * v_ind_sav / v_comon_sav;
              END IF;
            END IF;
          
            IF v_payed_sav IS NULL
               OR v_payed_sav != v_comon_sav
            THEN
            
              -- Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id
                ,vol.ag_volume_id
                ,nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                g_sgp1      := g_sgp1 + nvl(vol.index_delta_sum, 0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
      
        WHEN vol.ag_volume_type_id = g_vt_ops THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum /** vol.nbv_coef*/, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            /*Удержание ОПС*/
            BEGIN
              SELECT nvl(det.from_ret_to_pay, 0) from_ret_to_pay
                    ,det.snils
                INTO vp_ret_pay
                    ,vp_ret_snils
                FROM ins.ag_npf_volume_det det
               WHERE det.ag_volume_id = vol.ag_volume_id;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay = 99
            THEN
              --99 перешли на 8
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                      /*AND arh.ag_roll_header_id = g_roll_header_id*/
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'OAV_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
            THEN
              --не равно 0 - перешли с 8 на 1
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'OAV_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ins.ag_npf_volume_det    d
                              ,ins.ag_perf_work_vol     vl
                              ,ins.ag_perfom_work_det   det
                              ,ins.ag_perfomed_work_act act
                         WHERE d.snils = anv.snils
                           AND nvl(d.from_ret_to_pay, 0) = 1
                           AND d.ag_volume_id = vl.ag_volume_id
                           AND vl.ag_volume_id = vol.ag_volume_id
                           AND vl.ag_perfom_work_det_id = det.ag_perfom_work_det_id
                           AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
                           AND det.ag_rate_type_id = art.ag_rate_type_id)
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSE
            
              /**/
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(v_level
                                                                   ,g_leg_pos
                                                                   ,vol.is_nbv
                                                                   ,g_sales_ch));
            
              /**********Заглушка от Анастасии Черновой: для Москва 4 и качественных ОПС ставка 1.4************************/
              /*BEGIN
                SELECT COUNT(*)
                INTO pv_exists_dep
                FROM ins.ag_contract_header agh,
                     ins.ag_contract ag,
                     ins.department dep
                WHERE agh.ag_contract_header_id = ag.contract_id
                      AND agh.ag_contract_header_id = v_ag_ch_id
                      AND g_date_end BETWEEN ag.date_begin AND ag.date_end
                      AND dep.department_id = ag.agency_id
                      AND dep.name = 'Москва 4';
              EXCEPTION WHEN NO_DATA_FOUND THEN
                pv_exists_dep := 0;
              END;
              
              IF pv_exists_dep > 0 AND vol.trans_sum = 500 THEN
                v_sav := 140;
              END IF;*/
              /**********************************/
            
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum /** vol.nbv_coef*/, v_sav);
              
                g_sgp1      := g_sgp1 + nvl(vol.trans_sum /** vol.nbv_coef*/, 0);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav /** vol.nbv_coef*/, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id IN (g_vt_ops_2, g_vt_ops_9) THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum /** vol.nbv_coef*/, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            /*Удержание ОПС*/
            BEGIN
              SELECT nvl(det.from_ret_to_pay, 0) from_ret_to_pay
                    ,det.snils
                INTO vp_ret_pay
                    ,vp_ret_snils
                FROM ins.ag_npf_volume_det det
               WHERE det.ag_volume_id = vol.ag_volume_id;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay = 99
            THEN
              --99 перешли на 8
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND arh.ag_roll_header_id = g_roll_header_id
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02', 'NPF(MARK9)')
                   AND art.brief = 'OAV_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
            THEN
              --не равно 0 - перешли с 8 на 1
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02', 'NPF(MARK9)')
                   AND art.brief = 'OAV_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ins.ag_npf_volume_det    d
                              ,ins.ag_perf_work_vol     vl
                              ,ins.ag_perfom_work_det   det
                              ,ins.ag_perfomed_work_act act
                         WHERE d.snils = anv.snils
                           AND nvl(d.from_ret_to_pay, 0) = 1
                           AND d.ag_volume_id = vl.ag_volume_id
                           AND vl.ag_volume_id = vol.ag_volume_id
                           AND vl.ag_perfom_work_det_id = det.ag_perfom_work_det_id
                           AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
                           AND det.ag_rate_type_id = art.ag_rate_type_id)
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
              /**/
            ELSE
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(v_level
                                                                   ,g_leg_pos
                                                                   ,vol.is_nbv
                                                                   ,g_sales_ch));
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum /** vol.nbv_coef*/, v_sav);
              
                g_sgp1      := g_sgp1 + nvl(vol.trans_sum /** vol.nbv_coef*/, 0);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav /** vol.nbv_coef*/, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id = g_vt_bank THEN
        
          v_sav := pkg_tariff_calc.calc_coeff_val('RATE_BANKS', t_number_type(g_sales_ch, g_leg_pos));
          v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
        
          IF v_payed_sav IS NULL
             OR v_sav != 0
          THEN
          
            --3) Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum, v_sav);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum, 0);
            g_commision := g_commision + nvl(vol.trans_sum * v_sav, 0);
          END IF;
        
        WHEN vol.ag_volume_type_id = g_vt_avc_pay THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            v_sav := pkg_tariff_calc.calc_coeff_val('RATE_SOFI'
                                                   ,t_number_type(v_level, g_leg_pos, g_sales_ch));
            v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
          
            IF v_payed_sav IS NULL
               OR v_sav != 0
            THEN
            
              --3) Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
              g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
      
        ELSE
          NULL;
      END CASE;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_oav_250510;

  -- Author  : VESELEK
  -- Created : 02.10.2012
  -- Purpose : Производит расчет первичной КВ для RLA
  PROCEDURE get_first_rla(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name       VARCHAR2(25) := 'GET_FIRST_RLA';
    v_level         PLS_INTEGER;
    v_ag_ch_id      PLS_INTEGER;
    v_category_id   PLS_INTEGER;
    v_sav_gp        PLS_INTEGER;
    v_sav           NUMBER;
    v_ind_sav       NUMBER;
    v_comon_sav     NUMBER;
    v_payed_sav     NUMBER;
    v_nonrec        PLS_INTEGER;
    v_rate_type     PLS_INTEGER;
    v_individ_sav   PLS_INTEGER;
    vp_ret_pay      PLS_INTEGER;
    vp_ret_snils    VARCHAR2(255);
    vp_ret_amount   NUMBER;
    vp_ret_rate     NUMBER;
    v_agh_header_id NUMBER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,CASE
             WHEN g_sales_ch = g_sc_rla THEN
              1
             ELSE
              apw.ag_level
           END
          ,apd.ag_rate_type_id
          ,(CASE
             WHEN ach.num NOT IN ('2100', '2071') THEN
              -1
             ELSE
              ach.ag_contract_header_id
           END)
      INTO v_ag_ch_id
          ,v_category_id
          ,v_level
          ,v_rate_type
          ,v_agh_header_id
      FROM ag_perfomed_work_act       apw
          ,ag_perfom_work_det         apd
          ,ag_contract                ac
          ,ins.ven_ag_contract_header ach
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND ach.ag_contract_header_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT av.*
                      ,(SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,insurer.contact_id insrl
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id) agent_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_fio
                  FROM ins.ag_volume av
                      ,(SELECT ph.policy_header_id
                              ,ppc.contact_id
                          FROM ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.p_policy_contact   ppc
                              ,ins.t_contact_pol_role polr
                         WHERE ph.last_ver_id = pol.policy_id
                           AND pol.policy_id = ppc.policy_id
                           AND ppc.contact_policy_role_id = polr.id
                           AND polr.brief = 'Страхователь') insurer
                      ,ins.ag_roll ar
                      ,ins.ven_ag_roll_header arh
                      ,ins.ag_roll_type tp
                 WHERE ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND arh.ag_roll_type_id = tp.ag_roll_type_id
                   AND tp.brief = 'RLA_CASH_VOL'
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND nvl(TRIM(arh.note), 'Не определен') = g_note
                      /*изменения №174670*/
                   AND av.policy_header_id = insurer.policy_header_id(+)
                      /**/
                   AND decode(av.ag_volume_type_id
                             ,g_vt_life
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_inv
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_ops
                             ,av.date_begin
                             ,g_vt_ops_2
                             ,av.date_begin
                             ,g_vt_ops_9
                             ,av.date_begin
                             ,g_date_end) >= g_cat_date
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id IN
                               (SELECT apd.ag_prev_header_id
                                  FROM ag_prev_dog apd
                                 WHERE apd.ag_contract_header_id = v_ag_ch_id
                                UNION ALL
                                SELECT v_ag_ch_id
                                  FROM dual)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id != g_roll_header_id)
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id)
                /*AND av.ag_volume_type_id NOT IN (g_vt_NoneVol)*/
                )
    LOOP
      v_payed_sav := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                     ,v_rate_type
                                                     ,v_ag_ch_id
                                                     ,vol.ag_volume_id);
    
      CASE vol.ag_volume_type_id
        WHEN g_vt_life THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_id
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            --функция Индивидуальных ставок (по конкретному pol_header_id), если возвращает 999, то не нашел такой
            --договор и рассчитываем САВ как обычно, по группам ставок
            --(по сути "заплатка", но надо было впихнуть
            IF vol.pay_period = 1
            THEN
              v_individ_sav := nvl(pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                                 ,t_number_type(vol.policy_header_id))
                                  ,999);
            ELSE
              v_individ_sav := 999;
            END IF;
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id
                                                                    ,(CASE
                                                                       WHEN g_sales_ch != g_sc_rla THEN
                                                                        g_sc_dsf
                                                                       ELSE
                                                                        g_sales_ch
                                                                     END)));
          
            --2) Определяем ставку
            CASE
              WHEN vol.payment_term_id = g_pt_nonrecurring THEN
                v_nonrec := 1;
              ELSE
                v_nonrec := 0;
            END CASE;
          
            v_ind_sav := 0;
            IF nvl(vol.index_delta_sum, 0) <> 0
            THEN
              CASE
                WHEN v_individ_sav <> 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                             ,t_number_type(vol.policy_header_id));
                WHEN v_sav_gp <= 3
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_level));
                WHEN v_sav_gp = 4
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,v_level));
                WHEN v_sav_gp = 5
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,1
                                                                           ,v_level));
                WHEN v_sav_gp IN (6, 7)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level));
                WHEN v_sav_gp IN (8)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,1));
                WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
                WHEN v_sav_gp IN (20, 23, 24)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_agh_header_id, 1));
                WHEN v_sav_gp = 10
                     AND v_individ_sav = 999 THEN
                
                  DECLARE
                    v_ins_age PLS_INTEGER;
                  BEGIN
                    SELECT FLOOR(pc.insured_age)
                      INTO v_ins_age
                      FROM p_cover pc
                          ,trans   t
                     WHERE t.obj_uro_id = pc.p_cover_id
                       AND t.trans_id = vol.trans_id;
                  
                    v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                               ,t_number_type((CASE g_leg_pos
                                                                                WHEN 101 THEN
                                                                                 3
                                                                                ELSE
                                                                                 g_leg_pos
                                                                              END)
                                                                             ,v_level
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,(CASE
                                                                              WHEN g_sales_ch != g_sc_rla THEN
                                                                               g_sc_dsf
                                                                              ELSE
                                                                               g_sales_ch
                                                                            END)
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 12
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                  /*------------------------------------------------------------------------*/
                WHEN v_sav_gp = 13
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 14
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 21
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 22
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 25
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp IN (26, 27)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_agh_header_id, 1));
                WHEN v_sav_gp = 29
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,vol.pay_period
                                                                           ,v_level
                                                                           ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_category_id));
                WHEN v_sav_gp = 30
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,vol.pay_period
                                                                           ,v_level));
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            
            END IF;
          
            CASE
              WHEN v_individ_sav <> 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('ind_sav', t_number_type(vol.policy_header_id));
              WHEN v_sav_gp <= 3
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_level));
              WHEN v_sav_gp = 4
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,v_level));
              WHEN v_sav_gp = 5
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level));
              WHEN v_sav_gp IN (6, 7)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level));
              WHEN v_sav_gp IN (8)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
              WHEN v_sav_gp IN (20, 23, 24)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_agh_header_id, 1));
              WHEN v_sav_gp = 10
                   AND v_individ_sav = 999 THEN
              
                DECLARE
                  v_ins_age PLS_INTEGER;
                BEGIN
                  SELECT FLOOR(pc.insured_age)
                    INTO v_ins_age
                    FROM p_cover pc
                        ,trans   t
                   WHERE t.obj_uro_id = pc.p_cover_id
                     AND t.trans_id = vol.trans_id;
                
                  v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                         ,t_number_type((CASE g_leg_pos
                                                                          WHEN 101 THEN
                                                                           3
                                                                          ELSE
                                                                           g_leg_pos
                                                                        END)
                                                                       ,v_level
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,(CASE
                                                                        WHEN g_sales_ch != g_sc_rla THEN
                                                                         g_sc_dsf
                                                                        ELSE
                                                                         g_sales_ch
                                                                      END)
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 12
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
                /*------------------------------------------------------------------------*/
              WHEN v_sav_gp = 13
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 14
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 21
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 22
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 25
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp IN (26, 27)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_agh_header_id, 1));
              WHEN v_sav_gp = 29
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
              WHEN v_sav_gp = 30
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level));
              ELSE
                v_sav := 0;
            END CASE;
          
            v_sav       := nvl(v_sav, 0) / 100;
            v_comon_sav := v_sav + v_ind_sav;
          
            IF v_payed_sav IS NOT NULL
            THEN
              IF v_comon_sav != 0
              THEN
                v_sav     := (v_comon_sav - v_payed_sav) * v_sav / v_comon_sav;
                v_ind_sav := (v_comon_sav - v_payed_sav) * v_ind_sav / v_comon_sav;
              END IF;
            END IF;
          
            IF v_payed_sav IS NULL
               OR v_payed_sav != v_comon_sav
            THEN
            
              -- Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id
                ,vol.ag_volume_id
                ,nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                g_sgp1      := g_sgp1 + nvl(vol.index_delta_sum, 0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN g_vt_inv THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_id
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            --функция Индивидуальных ставок (по конкретному pol_header_id), если возвращает 999, то не нашел такой
            --договор и рассчитываем САВ как обычно, по группам ставок
            --(по сути "заплатка", но надо было впихнуть
            IF vol.pay_period = 1
            THEN
              v_individ_sav := nvl(pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                                 ,t_number_type(vol.policy_header_id))
                                  ,999);
            ELSE
              v_individ_sav := 999;
            END IF;
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id
                                                                    ,(CASE
                                                                       WHEN g_sales_ch != g_sc_rla THEN
                                                                        g_sc_dsf
                                                                       ELSE
                                                                        g_sales_ch
                                                                     END)));
          
            --2) Определяем ставку
            CASE
              WHEN vol.payment_term_id = g_pt_nonrecurring THEN
                v_nonrec := 1;
              ELSE
                v_nonrec := 0;
            END CASE;
          
            v_ind_sav := 0;
            IF nvl(vol.index_delta_sum, 0) <> 0
            THEN
              CASE
                WHEN v_individ_sav <> 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('ind_sav'
                                                             ,t_number_type(vol.policy_header_id));
                WHEN v_sav_gp <= 3
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_level));
                WHEN v_sav_gp = 4
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,v_level));
                WHEN v_sav_gp = 5
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,1
                                                                           ,v_level));
                WHEN v_sav_gp IN (6, 7)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level));
                WHEN v_sav_gp IN (8)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1));
                WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19, 20, 23, 24)
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
                WHEN v_sav_gp = 10
                     AND v_individ_sav = 999 THEN
                
                  DECLARE
                    v_ins_age PLS_INTEGER;
                  BEGIN
                    SELECT FLOOR(pc.insured_age)
                      INTO v_ins_age
                      FROM p_cover pc
                          ,trans   t
                     WHERE t.obj_uro_id = pc.p_cover_id
                       AND t.trans_id = vol.trans_id;
                  
                    v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                               ,t_number_type((CASE g_leg_pos
                                                                                WHEN 101 THEN
                                                                                 3
                                                                                ELSE
                                                                                 g_leg_pos
                                                                              END)
                                                                             ,v_level
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,(CASE
                                                                              WHEN g_sales_ch != g_sc_rla THEN
                                                                               g_sc_dsf
                                                                              ELSE
                                                                               g_sales_ch
                                                                            END)));
                WHEN v_sav_gp = 12
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_level
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                  /*------------------------------------------------------------------------*/
                WHEN v_sav_gp = 13
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id));
                WHEN v_sav_gp = 14
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id
                                                                           ,1));
                WHEN v_sav_gp = 21
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 22
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 25
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,v_nonrec
                                                                           ,vol.pay_period
                                                                           ,vol.ins_period
                                                                           ,v_agh_header_id));
                WHEN v_sav_gp = 29
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(g_sales_ch
                                                                           ,(CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,vol.pay_period
                                                                           ,v_level
                                                                           ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_category_id));
                WHEN v_sav_gp = 30
                     AND v_individ_sav = 999 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type((CASE g_leg_pos
                                                                              WHEN 101 THEN
                                                                               3
                                                                              ELSE
                                                                               g_leg_pos
                                                                            END)
                                                                           ,vol.pay_period
                                                                           ,v_level));
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            
            END IF;
          
            CASE
              WHEN v_individ_sav <> 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('ind_sav', t_number_type(vol.policy_header_id));
              WHEN v_sav_gp <= 3
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_level));
              WHEN v_sav_gp = 4
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,v_level));
              WHEN v_sav_gp = 5
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level));
              WHEN v_sav_gp IN (6, 7)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level));
              WHEN v_sav_gp IN (8)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period));
              WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19, 20, 23, 24)
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
              WHEN v_sav_gp = 10
                   AND v_individ_sav = 999 THEN
              
                DECLARE
                  v_ins_age PLS_INTEGER;
                BEGIN
                  SELECT FLOOR(pc.insured_age)
                    INTO v_ins_age
                    FROM p_cover pc
                        ,trans   t
                   WHERE t.obj_uro_id = pc.p_cover_id
                     AND t.trans_id = vol.trans_id;
                
                  v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_10'
                                                         ,t_number_type((CASE g_leg_pos
                                                                          WHEN 101 THEN
                                                                           3
                                                                          ELSE
                                                                           g_leg_pos
                                                                        END)
                                                                       ,v_level
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,(CASE
                                                                        WHEN g_sales_ch != g_sc_rla THEN
                                                                         g_sc_dsf
                                                                        ELSE
                                                                         g_sales_ch
                                                                      END)));
              WHEN v_sav_gp = 12
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_level
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
                /*------------------------------------------------------------------------*/
              WHEN v_sav_gp = 13
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id));
              WHEN v_sav_gp = 14
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id
                                                                     ,1));
              WHEN v_sav_gp = 21
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 22
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 25
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_agh_header_id));
              WHEN v_sav_gp = 29
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(g_sales_ch
                                                                     ,(CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
              WHEN v_sav_gp = 30
                   AND v_individ_sav = 999 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type((CASE g_leg_pos
                                                                        WHEN 101 THEN
                                                                         3
                                                                        ELSE
                                                                         g_leg_pos
                                                                      END)
                                                                     ,vol.pay_period
                                                                     ,v_level));
              ELSE
                v_sav := 0;
            END CASE;
          
            v_sav       := nvl(v_sav, 0) / 100;
            v_comon_sav := v_sav + v_ind_sav;
          
            IF v_payed_sav IS NOT NULL
            THEN
              IF v_comon_sav != 0
              THEN
                v_sav     := (v_comon_sav - v_payed_sav) * v_sav / v_comon_sav;
                v_ind_sav := (v_comon_sav - v_payed_sav) * v_ind_sav / v_comon_sav;
              END IF;
            END IF;
          
            IF v_payed_sav IS NULL
               OR v_payed_sav != v_comon_sav
            THEN
            
              -- Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id
                ,vol.ag_volume_id
                ,nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum - nvl(vol.index_delta_sum, 0), 0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                g_sgp1      := g_sgp1 + nvl(vol.index_delta_sum, 0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
      
        WHEN g_vt_ops THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            /*Удержание ОПС*/
            BEGIN
              SELECT nvl(det.from_ret_to_pay, 0)
                    ,det.snils
                INTO vp_ret_pay
                    ,vp_ret_snils
                FROM ins.ag_npf_volume_det det
               WHERE det.ag_volume_id = vol.ag_volume_id;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay = 99
            THEN
              --99 перешли на 8
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                      /*AND arh.ag_roll_header_id = g_roll_header_id*/
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'GET_FIRST_RLA'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
            THEN
              --не равно 0 - перешли с 8 на 1
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'GET_FIRST_RLA'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSE
            
              /**/
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(v_level
                                                                   ,g_leg_pos
                                                                   ,vol.is_nbv
                                                                   ,g_sales_ch));
            
              /**********Заглушка от Анастасии Черновой: для Москва 4 и качественных ОПС ставка 1.4************************/
              /*BEGIN
                SELECT COUNT(*)
                INTO pv_exists_dep
                FROM ins.ag_contract_header agh,
                     ins.ag_contract ag,
                     ins.department dep
                WHERE agh.ag_contract_header_id = ag.contract_id
                      AND agh.ag_contract_header_id = v_ag_ch_id
                      AND g_date_end BETWEEN ag.date_begin AND ag.date_end
                      AND dep.department_id = ag.agency_id
                      AND dep.name = 'Москва 4';
              EXCEPTION WHEN NO_DATA_FOUND THEN
                pv_exists_dep := 0;
              END;
              
              IF pv_exists_dep > 0 AND vol.trans_sum = 500 THEN
                v_sav := 140;
              END IF;*/
              /**********************************/
            
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
              
                g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN g_vt_ops_2 THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            /*Удержание ОПС*/
            BEGIN
              SELECT nvl(det.from_ret_to_pay, 0)
                    ,det.snils
                INTO vp_ret_pay
                    ,vp_ret_snils
                FROM ins.ag_npf_volume_det det
               WHERE det.ag_volume_id = vol.ag_volume_id;
            EXCEPTION
              WHEN no_data_found THEN
                vp_ret_pay := -1;
            END;
            IF vp_ret_pay = 99
            THEN
              --99 перешли на 8
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND arh.ag_roll_header_id = g_roll_header_id
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'GET_FIRST_RLA'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
            ELSIF (vp_ret_pay > 0 AND vp_ret_pay != 99)
            THEN
              --не равно 0 - перешли с 8 на 1
              BEGIN
                SELECT -apv.vol_amount
                      ,
                       -- -(agv.trans_sum * agv.nbv_coef),
                       SUM(apv.vol_rate) vol_rate
                  INTO vp_ret_amount
                      ,vp_ret_rate
                  FROM ins.ag_roll_header       arh
                      ,ins.ven_ag_roll          ar
                      ,ins.ag_perfomed_work_act apw
                      ,ins.ag_perfom_work_det   apd
                      ,ins.ag_rate_type         art
                      ,ins.ag_perf_work_vol     apv
                      ,ins.ag_volume            agv
                      ,ins.ag_volume_type       avt
                      ,ins.ag_npf_volume_det    anv
                 WHERE 1 = 1
                   AND ar.ag_roll_id != g_roll_id
                   AND ar.ag_roll_id = apw.ag_roll_id
                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                   AND art.ag_rate_type_id = apd.ag_rate_type_id
                   AND apv.ag_volume_id = agv.ag_volume_id
                   AND agv.ag_volume_id(+) = anv.ag_volume_id
                   AND agv.ag_volume_type_id = avt.ag_volume_type_id
                   AND avt.brief IN ('NPF', 'NPF02')
                   AND art.brief = 'GET_FIRST_RLA'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                 GROUP BY apv.vol_amount;
              EXCEPTION
                WHEN no_data_found THEN
                  vp_ret_pay := -1;
              END;
              IF vp_ret_pay != -1
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vp_ret_amount, vp_ret_rate);
                g_sgp1      := g_sgp1 + nvl(vp_ret_amount, 0);
                g_commision := g_commision + nvl(vp_ret_amount * vp_ret_rate, 0);
              END IF;
              /**/
            ELSE
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(v_level
                                                                   ,g_leg_pos
                                                                   ,vol.is_nbv
                                                                   ,g_sales_ch));
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
              
                g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN g_vt_bank THEN
        
          v_sav := pkg_tariff_calc.calc_coeff_val('RATE_BANKS', t_number_type(g_sales_ch, g_leg_pos));
          v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
        
          IF v_payed_sav IS NULL
             OR v_sav != 0
          THEN
          
            --3) Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum, v_sav);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum, 0);
            g_commision := g_commision + nvl(vol.trans_sum * v_sav, 0);
          END IF;
        
        WHEN g_vt_avc_pay THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_fio
          THEN
            -- Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            v_sav := pkg_tariff_calc.calc_coeff_val('RATE_SOFI'
                                                   ,t_number_type(v_level, g_leg_pos, g_sales_ch));
            v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
          
            IF v_payed_sav IS NULL
               OR v_sav != 0
            THEN
            
              --3) Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
            
              g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
              g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
      
        ELSE
          NULL;
      END CASE;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_first_rla;
  /**/
  -- Author  : VESELEK
  -- Created : 07.11.2012 12:27:29
  -- Purpose : Производит расчет АВ1 для RLP
  PROCEDURE get_rlp(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'GET_RLP';
    v_ag_ch_id  PLS_INTEGER;
    v_sav       NUMBER;
    v_rate_type PLS_INTEGER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_rate_type
      FROM ag_act_rlp      apw
          ,ag_work_det_rlp apd
     WHERE apw.ag_act_rlp_id = apd.ag_act_rlp_id
       AND apd.ag_work_det_rlp_id = p_ag_perf_work_det_id;
  
    FOR vol IN (SELECT av.*
                      ,ins.acc.get_cross_rate_by_id(1, ph.fund_id, 122, av.payment_date) cross_rate
                      ,ins.pkg_ag_calc_admin.get_rlp_amount(ph.policy_header_id, g_roll_id, v_ag_ch_id) last_av
                  FROM ins.ag_volume_rlp  av
                      ,ins.ag_roll        ar
                      ,ins.ag_roll_header arh
                      ,ins.p_pol_header   ph
                 WHERE ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) BETWEEN g_date_begin AND g_date_end
                   AND av.ag_contract_header_id = v_ag_ch_id
                   AND ph.policy_header_id = av.policy_header_id)
    LOOP
    
      v_sav := pkg_tariff_calc.calc_coeff_val('SAV_RLP'
                                             ,t_number_type(vol.product_id
                                                           ,vol.pay_period
                                                           ,vol.ins_period));
      INSERT INTO ven_ag_vol_rlp
        (ag_work_det_rlp_id
        ,ag_volume_rlp_id
        ,vol_amount
        ,vol_rate
        ,vol_sav
        ,vol_av
        ,last_vol_av
        ,cross_rate)
      VALUES
        (p_ag_perf_work_det_id
        ,vol.ag_volume_rlp_id
        ,vol.epg_ammount
        ,v_sav
        ,vol.vol_sav
        ,vol.epg_ammount * v_sav * vol.cross_rate
        ,vol.last_av
        ,vol.cross_rate);
    
      g_commision := g_commision + nvl(vol.epg_ammount * v_sav * vol.cross_rate, 0);
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_rlp;
  /**/
  -- Author  : VESELEK
  -- Created : 29.05.2013 12:27:29
  -- Purpose : Производит перенос АВ в будущую ведомость для RLP
  PROCEDURE replace_rlp(par_roll_id NUMBER) IS
    proc_name VARCHAR2(25) := 'REPLACE_RLP';
  BEGIN
    UPDATE ins.ag_volume_rlp av
       SET av.is_future = 1
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_vol_rlp      vol
                  ,ins.ag_act_rlp      act
                  ,ins.ag_work_det_rlp det
             WHERE av.ag_volume_rlp_id = vol.ag_volume_rlp_id
               AND vol.ag_work_det_rlp_id = det.ag_work_det_rlp_id
               AND det.ag_act_rlp_id = act.ag_act_rlp_id
               AND (vol.vol_amount * vol.vol_rate) - vol.vol_sav <= 0
               AND act.ag_roll_id = par_roll_id);
    DELETE FROM ins.ag_act_rlp act
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_vol_rlp      vol
                  ,ins.ag_work_det_rlp det
             WHERE vol.ag_work_det_rlp_id = det.ag_work_det_rlp_id
               AND det.ag_act_rlp_id = act.ag_act_rlp_id
               AND (vol.vol_amount * vol.vol_rate) - vol.vol_sav <= 0
               AND act.ag_roll_id = par_roll_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END replace_rlp;

  -- Author  : Веселуха Е.В.
  -- Created : 22.08.2013
  -- Purpose : Производит расчет ОАВ для мотивации Банков / Брокеров
  -- Байтин А.
  -- Не используется более, весь расчет в calc_banks
  PROCEDURE get_oav_bank(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'get_oav_bank';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_sav_gp      PLS_INTEGER;
    v_sav         NUMBER;
    v_ind_sav     NUMBER;
    v_comon_sav   NUMBER;
    v_payed_sav   NUMBER;
    v_nonrec      PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_individ_sav PLS_INTEGER;
    vp_ret_pay    PLS_INTEGER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apw.ag_level
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_level
          ,v_rate_type
      FROM ins.ag_perfomed_work_act apw
          ,ins.ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    FOR vol IN (SELECT av.*
                      ,(SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,(SELECT pi.contact_id FROM v_pol_issuer pi WHERE pi.policy_id = ph.last_ver_id) insrl
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id) agent_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_fio
                      ,ph.product_id
                      ,trm.is_periodical
                      ,pp.ins_amount
                  FROM ins.ag_volume       av
                      ,ins.ag_roll         ar
                      ,ins.ag_roll_header  arh
                      ,ins.ag_roll_type    art
                      ,ins.p_pol_header    ph
                      ,ins.p_policy        pp
                      ,ins.t_payment_terms trm
                 WHERE ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'CALC_VOL_BANK'
                   AND av.policy_header_id = ph.policy_header_id(+)
                   AND ph.last_ver_id = pp.policy_id(+)
                   AND av.payment_term_id = trm.id
                   AND decode(av.ag_volume_type_id
                             ,g_vt_life
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_fdep
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_inv
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_nonevol
                             ,greatest(nvl(av.conclude_date, av.payment_date)
                                      ,av.payment_date
                                      ,av.date_begin)
                             ,g_vt_ops
                             ,av.date_begin
                             ,g_vt_ops_2
                             ,av.date_begin
                             ,g_vt_ops_9
                             ,av.date_begin
                             ,g_date_end) >= g_cat_date
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id != g_roll_header_id)
                   AND av.ag_contract_header_id = v_ag_ch_id)
    LOOP
    
      v_payed_sav := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                     ,v_rate_type
                                                     ,v_ag_ch_id
                                                     ,vol.ag_volume_id);
    
      IF vol.insrl = vol.agent_id
      THEN
        -- Записываем полученные значения
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
      
        g_sgp1      := g_sgp1 + nvl(vol.trans_sum, 0);
        g_commision := g_commision + 0;
      ELSE
        v_sav := NULL;
        /* v_sav := get_sav_bank(par_ag_contract_header_id => v_ag_ch_id
        ,par_product_line_id       => vol.t_prod_line_option_id
        ,par_ins_amount            => vol.ins_amount
        ,par_insurance_period      => vol.ins_period
        ,par_commission_period     => vol.pay_period
        ,par_payment_term          => CASE
                                 WHEN vol.is_periodical = 1 THEN
                                  2
                                 ELSE
                                  1
                                      END);*/
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
      
        g_sgp1      := g_sgp1 + nvl(vol.trans_sum * vol.nbv_coef, 0);
        g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
      
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END get_oav_bank;

  /**/
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.11.2010 13:34:15
  -- Purpose : Расчет премии для агентов ГРС
  PROCEDURE get_grs_agents_prem(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'Get_GRS_agents_prem';
    v_ag_ch_id PLS_INTEGER;
    v_rate     PLS_INTEGER;
    pv_cnt_vol PLS_INTEGER := 0;
  BEGIN
  
    SELECT apw.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    /************План по пред версиям*******************************************/
    BEGIN
      SELECT COUNT(*)
        INTO pv_cnt_vol
        FROM ins.ag_volume      av
            ,ins.ven_ag_roll    ar
            ,ins.ag_roll_header arh
            ,ins.ag_roll_type   art
       WHERE av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
         AND av.trans_sum = 500
         AND ar.ag_roll_id = av.ag_roll_id
         AND ar.ag_roll_header_id = arh.ag_roll_header_id
         AND arh.date_end <= g_date_end
         AND arh.ag_roll_type_id = art.ag_roll_type_id
         AND art.brief = 'CASH_VOL'
         AND EXISTS
       (SELECT NULL
                FROM ag_perf_work_vol     apv
                    ,ag_perfom_work_det   apd
                    ,ag_perfomed_work_act apw
                    ,ins.ven_ag_roll      ar
                    ,ag_roll_header       arh
               WHERE apv.ag_volume_id = av.ag_volume_id
                 AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                 AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apw.ag_contract_header_id IN (SELECT apd.ag_prev_header_id
                                                     FROM ag_prev_dog apd
                                                    WHERE apd.ag_contract_header_id = v_ag_ch_id
                                                   UNION ALL
                                                   SELECT v_ag_ch_id
                                                     FROM dual)
                 AND apw.ag_roll_id = ar.ag_roll_id
                 AND ar.num <
                     (SELECT arl.num FROM ins.ven_ag_roll arl WHERE arl.ag_roll_id = g_roll_id)
                 AND arh.ag_roll_header_id = g_roll_header_id
                 AND ar.ag_roll_header_id = arh.ag_roll_header_id)
         AND av.ag_contract_header_id IN
             (SELECT v_ag_ch_id
                FROM dual
              UNION
              SELECT apd.ag_prev_header_id
                FROM ag_prev_dog apd
               WHERE apd.ag_contract_header_id = v_ag_ch_id);
    EXCEPTION
      WHEN no_data_found THEN
        pv_cnt_vol := 0;
    END;
    /******************************************************/
  
    FOR vol IN (SELECT av.ag_volume_id
                      ,av.nbv_coef
                      ,av.trans_sum
                      ,COUNT(av.ag_volume_id) over(PARTITION BY av.trans_sum) cnt
                      ,
                       
                       (SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_fio
                
                  FROM ins.ag_volume      av
                      ,ins.ag_roll        ar
                      ,ins.ag_roll_header arh
                      ,ins.ag_roll_type   art
                 WHERE av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                   AND av.trans_sum IN (500, 250)
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND arh.date_end <= g_date_end
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'CASH_VOL'
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id IN
                               (SELECT apd.ag_prev_header_id
                                  FROM ag_prev_dog apd
                                 WHERE apd.ag_contract_header_id = v_ag_ch_id
                                UNION ALL
                                SELECT v_ag_ch_id
                                  FROM dual)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_id != g_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id)
                   AND av.ag_contract_header_id IN
                       (SELECT v_ag_ch_id
                          FROM dual
                        UNION
                        SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id))
    LOOP
    
      IF vol.trans_sum = 500
      THEN
        vol.cnt := vol.cnt + pv_cnt_vol;
      END IF;
    
      /*добавлено 04-08-2011 Заявка №128655*/
      /*добавлено Настькой*/
      IF g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
         to_date('25.12.2011', 'DD.MM.YYYY')
      THEN
        CASE g_leg_pos
          WHEN 3 THEN
            /***************************/
            CASE g_sales_ch
              WHEN g_sc_grs_region THEN
                IF vol.trans_sum = 500
                THEN
                  CASE
                    WHEN vol.cnt <= 4 THEN
                      v_rate := 350;
                    WHEN vol.cnt <= 9 THEN
                      v_rate := 400;
                    WHEN vol.cnt <= 69 THEN
                      v_rate := 500;
                    ELSE
                      v_rate := 600;
                  END CASE;
                ELSE
                  v_rate := 250;
                END IF;
              WHEN g_sc_grs_moscow THEN
                IF vol.trans_sum = 500
                THEN
                  IF vol.cnt <= 10
                  THEN
                    v_rate := 500;
                  ELSE
                    v_rate := 700;
                  END IF;
                ELSE
                  v_rate := 250;
                END IF;
              ELSE
                NULL;
            END CASE;
            /*****************************/
          ELSE
            CASE g_sales_ch
              WHEN g_sc_grs_region THEN
                IF vol.trans_sum = 500
                THEN
                  CASE
                    WHEN vol.cnt <= 4 THEN
                      v_rate := 450;
                    WHEN vol.cnt <= 9 THEN
                      v_rate := 500;
                    WHEN vol.cnt <= 69 THEN
                      v_rate := 600;
                    ELSE
                      v_rate := 700;
                  END CASE;
                ELSE
                  v_rate := 250;
                END IF;
              WHEN g_sc_grs_moscow THEN
                IF vol.trans_sum = 500
                THEN
                  IF vol.cnt <= 10
                  THEN
                    v_rate := 500;
                  ELSE
                    v_rate := 700;
                  END IF;
                ELSE
                  v_rate := 250;
                END IF;
              ELSE
                NULL;
            END CASE;
          
        END CASE;
        /*************************************/
      ELSE
        /****************************************/
        CASE g_leg_pos
          WHEN 1030 THEN
            IF vol.trans_sum = 500
            THEN
              CASE
                WHEN vol.cnt <= 4 THEN
                  v_rate := 350;
                WHEN vol.cnt <= 9 THEN
                  v_rate := 450;
                ELSE
                  v_rate := 600;
              END CASE;
            ELSE
              v_rate := 250;
            END IF;
          ELSE
            CASE g_sales_ch
              WHEN g_sc_grs_moscow THEN
                IF vol.trans_sum = 500
                THEN
                  IF vol.cnt <= 10
                  THEN
                    v_rate := 500;
                  ELSE
                    v_rate := 700;
                  END IF;
                ELSE
                  v_rate := 250;
                END IF;
              WHEN g_sc_grs_region THEN
                IF vol.trans_sum = 500
                THEN
                  CASE
                    WHEN vol.cnt <= 4 THEN
                      v_rate := 350;
                    WHEN vol.cnt <= 9 THEN
                      v_rate := 400;
                    ELSE
                      v_rate := 500;
                  END CASE;
                ELSE
                  v_rate := 250;
                END IF;
              ELSE
                NULL;
            END CASE;
          
        END CASE;
        /*********************************************/
      END IF;
      /*********************************************/
    
      /*изменения №174670*/
      /*закрыто по Акту от 21.08.2012*/
      /*IF vol.insops = vol.agent_fio THEN
        -- Записываем полученные значения
        INSERT INTO ven_ag_perf_work_vol 
                    (ag_perfom_work_det_id,
                    ag_volume_id,
                    vol_amount,
                    vol_rate)
             VALUES (p_ag_perf_work_det_id,
                    vol.ag_volume_id,
                    0,
                    0);
                  
        g_commision:=g_commision+0;
      ELSE*/
      /**/
      g_commision := g_commision + v_rate;
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol.ag_volume_id, 1, v_rate);
    
    /*END IF;*/
    
    END LOOP;
  
    UPDATE ag_perfom_work_det a
       SET a.summ = g_commision
     WHERE a.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    /******Чтобы Настя видела 0 и 100 ОПС в деталях*********************************/
    FOR vol_zero IN (SELECT av.ag_volume_id
                           ,av.nbv_coef
                           ,av.trans_sum
                           ,COUNT(av.ag_volume_id) over(PARTITION BY av.trans_sum) cnt
                       FROM ag_volume      av
                           ,ag_roll        ar
                           ,ag_roll_header arh
                      WHERE av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_9)
                        AND av.trans_sum IN (100, 0)
                        AND ar.ag_roll_id = av.ag_roll_id
                        AND ar.ag_roll_header_id = arh.ag_roll_header_id
                        AND arh.date_end <= g_date_end
                        AND NOT EXISTS
                      (SELECT NULL
                               FROM ag_perf_work_vol     apv
                                   ,ag_perfom_work_det   apd
                                   ,ag_perfomed_work_act apw
                                   ,ag_roll              ar
                                   ,ag_roll_header       arh
                              WHERE apv.ag_volume_id = av.ag_volume_id
                                AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                                AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                AND apw.ag_contract_header_id IN
                                    (SELECT apd.ag_prev_header_id
                                       FROM ag_prev_dog apd
                                      WHERE apd.ag_contract_header_id = v_ag_ch_id
                                     UNION ALL
                                     SELECT v_ag_ch_id
                                       FROM dual)
                                AND apw.ag_roll_id = ar.ag_roll_id
                                AND ar.ag_roll_id != g_roll_id
                                AND ar.ag_roll_header_id = arh.ag_roll_header_id)
                        AND av.ag_contract_header_id IN
                            (SELECT v_ag_ch_id
                               FROM dual
                             UNION
                             SELECT apd.ag_prev_header_id
                               FROM ag_prev_dog apd
                              WHERE apd.ag_contract_header_id = v_ag_ch_id))
    LOOP
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol_zero.ag_volume_id, 0, 0);
    
    END LOOP;
    /********************************/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_grs_agents_prem;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.06.2010 17:39:55
  -- Purpose : Получение и сохранение КСП для агента
  FUNCTION get_ksp_250510(p_ag_work_det_id PLS_INTEGER) RETURN NUMBER IS
    --Result number;
    proc_name      VARCHAR2(25) := 'Get_KSP_250510';
    v_ksp          NUMBER;
    v_ag_ch_id     PLS_INTEGER := 1;
    v_ag_ksp       PLS_INTEGER;
    v_expected_fee NUMBER := 0;
    v_recived_cash NUMBER := 0;
    v_ag_rate_type PLS_INTEGER;
    v_ag_perf_act  PLS_INTEGER;
    i              PLS_INTEGER;
    TYPE t_ag_ksp_det IS TABLE OF ven_ag_ksp_det%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_ksp_det t_ag_ksp_det;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,apw.ag_perfomed_work_act_id
      INTO v_ag_ch_id
          ,v_ag_rate_type
          ,v_ag_perf_act
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_work_det_id;
  
    SELECT sq_ag_ksp.nextval INTO v_ag_ksp FROM dual;
  
    <<ml>>
    FOR ksp IN (SELECT *
                  FROM temp_ksp_calc tc
                 WHERE tc.contract_header_id = v_ag_ch_id
                    OR tc.contract_header_id IN
                       (SELECT apd.ag_prev_header_id
                          FROM ag_prev_dog apd
                         WHERE apd.ag_contract_header_id = v_ag_ch_id))
    LOOP
      i := v_ag_ksp_det.count + 1;
      v_ag_ksp_det(i).ag_ksp_id := v_ag_ksp;
      v_ag_ksp_det(i).ag_contract_header_id := v_ag_ch_id;
      v_ag_ksp_det(i).policy_header_id := ksp.policy_header_id;
      v_ag_ksp_det(i).policy_agent := ksp.agent_contract_header;
      v_ag_ksp_det(i).fee_count := ksp.fee_count;
      v_ag_ksp_det(i).fee_expected := ksp.fee_expected;
      v_ag_ksp_det(i).ksp_per_begin := ksp.ksp_begin;
      v_ag_ksp_det(i).ksp_per_end := ksp.ksp_end;
      v_ag_ksp_det(i).cash_recived := ksp.cash_recived;
      v_ag_ksp_det(i).decline_date := ksp.decline_date;
      v_ag_ksp_det(i).last_policy_status_id := ksp.last_policy_status_id;
    
      v_expected_fee := v_expected_fee + nvl(ksp.fee_expected, 0);
      v_recived_cash := v_recived_cash + nvl(ksp.cash_recived, 0);
    END LOOP ml;
  
    IF v_expected_fee = 0
    THEN
      v_ksp := 100;
    ELSE
      v_ksp := ROUND(v_recived_cash / v_expected_fee * 100, 2);
      IF v_ksp > 100
      THEN
        v_ksp := 100;
      END IF;
    END IF;
  
    INSERT INTO ven_ag_ksp
      (ag_ksp_id, ag_rate_type_id, document, ksp_value)
    VALUES
      (v_ag_ksp, v_ag_rate_type, v_ag_perf_act, v_ksp);
  
    FORALL i IN 1 .. v_ag_ksp_det.count
      INSERT INTO ven_ag_ksp_det VALUES v_ag_ksp_det (i);
  
    RETURN(v_ksp);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_ksp_250510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 02.07.2009 11:22:36
  -- Purpose : Получает КСП и записывает детализацию
  FUNCTION get_ksp(p_ag_work_det_id NUMBER) RETURN NUMBER IS
    proc_name      VARCHAR2(20) := 'GetKSP';
    v_ksp          NUMBER;
    v_ag_ch_id     PLS_INTEGER := 1;
    v_ag_ksp       PLS_INTEGER;
    v_conclude_sgp NUMBER := 0;
    v_prolong_sgp  NUMBER := 0;
    v_ag_rate_type PLS_INTEGER;
    v_ag_perf_act  PLS_INTEGER;
    i              PLS_INTEGER;
    TYPE t_ag_ksp_det IS TABLE OF ven_ag_ksp_det%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_ksp_det t_ag_ksp_det;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,apw.ag_perfomed_work_act_id
      INTO v_ag_ch_id
          ,v_ag_rate_type
          ,v_ag_perf_act
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_work_det_id;
  
    SELECT sq_ag_ksp.nextval INTO v_ag_ksp FROM dual;
  
    FOR ksp IN (SELECT * FROM temp_ksp_calc tc WHERE tc.contract_header_id = v_ag_ch_id)
    LOOP
      i := v_ag_ksp_det.count + 1;
      v_ag_ksp_det(i).ag_ksp_id := v_ag_ksp;
      v_ag_ksp_det(i).ag_contract_header_id := ksp.contract_header_id;
      v_ag_ksp_det(i).active_policy_status_id := ksp.active_policy_status_id;
      v_ag_ksp_det(i).last_policy_status_id := ksp.last_policy_status_id;
      v_ag_ksp_det(i).conclude_policy_sgp := ksp.conclude_policy_sgp;
      v_ag_ksp_det(i).policy_header_id := ksp.policy_header_id;
      v_ag_ksp_det(i).policy_agent := ksp.agent_contract_header;
      v_ag_ksp_det(i).decline_date := ksp.decline_date;
      v_ag_ksp_det(i).prolong_policy_sgp := ksp.prolong_policy_sgp;
    
      v_conclude_sgp := v_conclude_sgp + ksp.conclude_policy_sgp;
      v_prolong_sgp  := v_prolong_sgp + ksp.prolong_policy_sgp;
    END LOOP;
  
    IF v_conclude_sgp = 0
    THEN
      v_ksp := 100;
    ELSE
      v_ksp := ROUND(v_prolong_sgp / v_conclude_sgp * 100, 2);
      IF v_ksp > 100
      THEN
        v_ksp := 100;
      END IF;
    END IF;
  
    INSERT INTO ven_ag_ksp
      (ag_ksp_id, ag_rate_type_id, document, ksp_value)
    VALUES
      (v_ag_ksp, v_ag_rate_type, v_ag_perf_act, v_ksp);
  
    FORALL i IN 1 .. v_ag_ksp_det.count
      INSERT INTO ven_ag_ksp_det VALUES v_ag_ksp_det (i);
  
    RETURN(v_ksp);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM || chr(10));
  END get_ksp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:14:02
  -- Purpose : Получает сумму поступивших денег, сумму премии и заполняет детализацию
  FUNCTION get_cash(p_ag_work_det_id NUMBER) RETURN t_cash IS
    proc_name         VARCHAR2(20) := 'Get_cash';
    v_cash            t_cash;
    v_ag_ch_id        PLS_INTEGER := 1;
    v_ag_stat_agent   PLS_INTEGER;
    v_ag_header_id    PLS_INTEGER;
    v_commission      NUMBER;
    v_payed_commision NUMBER := 0;
    v_policy_id       PLS_INTEGER := 0;
    v_pay_doc_id      PLS_INTEGER := 0;
    v_epg_doc_id      PLS_INTEGER := 0;
    i                 PLS_INTEGER;
    j                 PLS_INTEGER;
    y                 PLS_INTEGER;
    v_roll_type_k     PLS_INTEGER;
    TYPE t_ag_perf_work_dpol IS TABLE OF ven_ag_perfom_work_dpol%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_payd IS TABLE OF ven_ag_perf_work_pay_doc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_tran IS TABLE OF ven_ag_perf_work_trans%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_perf_work_dpol t_ag_perf_work_dpol;
    v_ag_perf_work_payd t_ag_perf_work_payd;
    v_ag_perf_work_tran t_ag_perf_work_tran;
  
  BEGIN
    v_cash.cash_amount    := 0;
    v_cash.commiss_amount := 0;
  
    CASE substr(g_roll_type_brief, 1, 4)
      WHEN 'DAV_' THEN
        v_roll_type_k := 1;
      WHEN 'AGAT' THEN
        v_roll_type_k := 4;
      ELSE
        v_roll_type_k := 0;
    END CASE;
  
    SELECT apw.ag_contract_header_id
          ,ash.ag_stat_agent_id
      INTO v_ag_ch_id
          ,v_ag_stat_agent
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_stat_hist         ash
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_work_det_id
       AND ash.ag_stat_hist_id = apw.ag_stat_hist_id;
  
    FOR cash IN (SELECT tc.*
                       ,ph.product_id
                   FROM temp_cash_calc tc
                       ,p_policy       pp
                       ,p_pol_header   ph
                  WHERE tc.current_agent = v_ag_ch_id
                    AND tc.policy_id = pp.policy_id
                    AND pp.pol_header_id = ph.policy_header_id
                  ORDER BY tc.active_policy_id
                          ,tc.epg_payment_id
                          ,tc.pay_payment_id
                          ,tc.trans_id)
    LOOP
    
      IF cash.active_policy_id <> v_policy_id
      THEN
        v_policy_id := cash.active_policy_id;
        i           := v_ag_perf_work_dpol.count + 1;
      
        SELECT sq_ag_perfom_work_dpol.nextval
          INTO v_ag_perf_work_dpol(i).ag_perfom_work_dpol_id
          FROM dual;
      
        IF cash.is_indexing = 1
        THEN
          v_ag_perf_work_dpol(i).policy_agent_part := pkg_tariff_calc.calc_coeff_val('SGP_koeff'
                                                                                    ,t_number_type(cash.product_id
                                                                                                  ,cash.t_payment_term_id
                                                                                                  ,cash.insurance_period
                                                                                                  ,v_roll_type_k
                                                                                                  ,to_char(g_date_end
                                                                                                          ,'YYYYMMDD')));
        ELSE
          v_ag_perf_work_dpol(i).policy_agent_part := cash.policy_agent_part;
        END IF;
      
        v_ag_perf_work_dpol(i).ag_perfom_work_det_id := p_ag_work_det_id;
        v_ag_perf_work_dpol(i).policy_id := cash.active_policy_id;
        v_ag_perf_work_dpol(i).policy_status_id := cash.active_pol_status_id;
        v_ag_perf_work_dpol(i).ag_contract_header_ch_id := cash.current_agent;
        --v_ag_perf_work_dpol(i).ag_status_id := cash.agent_status_id;
        v_ag_perf_work_dpol(i).summ := 0;
        v_ag_perf_work_dpol(i).pay_term := cash.t_payment_term_id;
        v_ag_perf_work_dpol(i).ag_leg_pos := g_leg_pos;
        v_ag_perf_work_dpol(i).check_1 := cash.check_1;
        v_ag_perf_work_dpol(i).check_2 := cash.check_2;
        v_ag_perf_work_dpol(i).ag_status_id := v_ag_stat_agent;
        v_ag_perf_work_dpol(i).insurance_period := cash.insurance_period;
      END IF;
    
      IF cash.pay_payment_id <> v_pay_doc_id
         OR cash.epg_payment_id <> v_epg_doc_id
      THEN
        v_pay_doc_id := cash.pay_payment_id;
        v_epg_doc_id := cash.epg_payment_id;
        j            := v_ag_perf_work_payd.count + 1;
      
        SELECT sq_ag_perf_work_pay_doc.nextval
          INTO v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id
          FROM dual;
      
        v_ag_perf_work_payd(j).ag_preformed_work_dpol_id := v_ag_perf_work_dpol(i)
                                                            .ag_perfom_work_dpol_id;
        v_ag_perf_work_payd(j).policy_id := cash.policy_id;
        v_ag_perf_work_payd(j).policy_status_id := cash.policy_status_id;
        v_ag_perf_work_payd(j).epg_payment_id := cash.epg_payment_id;
        v_ag_perf_work_payd(j).epg_status_id := cash.epg_status_id;
        v_ag_perf_work_payd(j).pay_payment_id := cash.pay_payment_id;
        v_ag_perf_work_payd(j).pay_bank_doc_id := cash.pay_bank_doc_id;
      END IF;
    
      y := v_ag_perf_work_tran.count + 1;
    
      SELECT sq_ag_perf_work_trans.nextval
        INTO v_ag_perf_work_tran(y).ag_perf_work_trans_id
        FROM dual;
    
      v_ag_perf_work_tran(y).ag_perf_work_pay_doc_id := v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id;
      v_ag_perf_work_tran(y).trans_id := cash.trans_id;
      v_ag_perf_work_tran(y).t_prod_line_option_id := cash.t_prod_line_option_id;
      v_ag_perf_work_tran(y).sum_premium := cash.trans_amount;
      v_ag_perf_work_tran(y).is_indexing := cash.is_indexing;
    
      IF g_roll_num <> 1
      THEN
        SELECT nvl(SUM(apt.sum_commission), 0)
          INTO v_payed_commision
          FROM ag_roll_header       arh
              ,ag_roll              ar
              ,ag_roll_type         art
              ,ag_perfomed_work_act apw
              ,ag_perfom_work_det   apd
              ,ag_perfom_work_dpol  apdp
              ,ag_perf_work_pay_doc appd
              ,ag_perf_work_trans   apt
         WHERE arh.ag_roll_header_id = g_roll_header_id
           AND arh.ag_roll_type_id = art.ag_roll_type_id
           AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
           AND apw.ag_contract_header_id = v_ag_header_id
           AND ar.ag_roll_header_id = arh.ag_roll_header_id
           AND apw.ag_roll_id = ar.ag_roll_id
           AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
           AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
           AND appd.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
           AND appd.ag_perf_work_pay_doc_id = apt.ag_perf_work_pay_doc_id
           AND apt.trans_id = cash.trans_id;
        IF cash.check_1 = 1
           AND cash.check_2 = 1
        THEN
          v_commission := nvl(cash.trans_amount, 0) - v_payed_commision;
        ELSE
          v_commission := -v_payed_commision;
        END IF;
      ELSE
        IF cash.check_1 = 1
           AND cash.check_2 = 1
        THEN
          v_commission := nvl(cash.trans_amount, 0);
        ELSE
          v_commission := 0;
        END IF;
      END IF;
    
      v_ag_perf_work_tran(y).sum_commission := v_commission;
    
      v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + v_commission;
    
      v_cash.cash_amount    := v_cash.cash_amount + nvl(cash.trans_amount, 0);
      v_cash.commiss_amount := v_cash.commiss_amount +
                               v_commission * v_ag_perf_work_dpol(i).policy_agent_part;
    
    END LOOP;
  
    FORALL i IN 1 .. v_ag_perf_work_dpol.count
      INSERT INTO ven_ag_perfom_work_dpol VALUES v_ag_perf_work_dpol (i);
  
    FORALL i IN 1 .. v_ag_perf_work_payd.count
      INSERT INTO ven_ag_perf_work_pay_doc VALUES v_ag_perf_work_payd (i);
  
    FORALL i IN 1 .. v_ag_perf_work_tran.count
      INSERT INTO ven_ag_perf_work_trans VALUES v_ag_perf_work_tran (i);
  
    RETURN(v_cash);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END get_cash;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:15:15
  -- Purpose : Получает сумму СГП и заполняет детализацию
  FUNCTION get_sgp(p_ag_work_det_id PLS_INTEGER) RETURN NUMBER IS
    proc_name       VARCHAR2(20) := 'Get_SGP';
    v_sgp           NUMBER := 0;
    v_ag_ch_id      PLS_INTEGER := 1;
    v_ag_stat_agent PLS_INTEGER;
    v_policy_id     PLS_INTEGER := 0;
    v_pay_doc_id    PLS_INTEGER := 0;
    v_epg_doc_id    PLS_INTEGER := 0;
    i               PLS_INTEGER;
    j               PLS_INTEGER;
    y               PLS_INTEGER;
  
    TYPE t_ag_perf_work_dpol IS TABLE OF ven_ag_perfom_work_dpol%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_payd IS TABLE OF ven_ag_perf_work_pay_doc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_dcov IS TABLE OF ven_ag_perf_work_dcover%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_perf_work_dpol t_ag_perf_work_dpol;
    v_ag_perf_work_payd t_ag_perf_work_payd;
    v_ag_perf_work_dcov t_ag_perf_work_dcov;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,ash.ag_stat_agent_id
      INTO v_ag_ch_id
          ,v_ag_stat_agent
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_stat_hist         ash
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_work_det_id
       AND ash.ag_stat_hist_id = apw.ag_stat_hist_id;
  
    FOR sgp IN (SELECT *
                  FROM temp_sgp_calc tc
                 WHERE tc.current_agent = v_ag_ch_id
                 ORDER BY tc.active_policy_id
                         ,tc.epg_payment_id
                         ,tc.pay_payment_id
                         ,tc.p_cover_id)
    LOOP
    
      IF sgp.active_policy_id <> v_policy_id
      THEN
        v_policy_id := sgp.active_policy_id;
        i           := v_ag_perf_work_dpol.count + 1;
      
        SELECT sq_ag_perfom_work_dpol.nextval
          INTO v_ag_perf_work_dpol(i).ag_perfom_work_dpol_id
          FROM dual;
      
        v_ag_perf_work_dpol(i).ag_perfom_work_det_id := p_ag_work_det_id;
        v_ag_perf_work_dpol(i).policy_id := sgp.active_policy_id;
        v_ag_perf_work_dpol(i).policy_status_id := sgp.active_pol_status_id;
        v_ag_perf_work_dpol(i).ag_contract_header_ch_id := sgp.current_agent;
        v_ag_perf_work_dpol(i).ag_status_id := sgp.agent_status_id;
        v_ag_perf_work_dpol(i).policy_agent_part := sgp.sgp_koef;
        v_ag_perf_work_dpol(i).summ := 0;
        v_ag_perf_work_dpol(i).pay_term := sgp.payment_term_id;
        v_ag_perf_work_dpol(i).ag_leg_pos := g_leg_pos;
        v_ag_perf_work_dpol(i).ag_status_id := v_ag_stat_agent;
        v_ag_perf_work_dpol(i).insurance_period := sgp.insurance_period;
        v_ag_perf_work_dpol(i).check_1 := sgp.check_1;
        v_ag_perf_work_dpol(i).check_2 := sgp.check_2;
      END IF;
    
      IF sgp.pay_payment_id <> v_pay_doc_id
         OR sgp.epg_payment_id <> v_epg_doc_id
      THEN
        v_pay_doc_id := sgp.pay_payment_id;
        v_epg_doc_id := sgp.epg_payment_id;
        j            := v_ag_perf_work_payd.count + 1;
      
        SELECT sq_ag_perf_work_pay_doc.nextval
          INTO v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id
          FROM dual;
      
        v_ag_perf_work_payd(j).ag_preformed_work_dpol_id := v_ag_perf_work_dpol(i)
                                                            .ag_perfom_work_dpol_id;
        v_ag_perf_work_payd(j).policy_id := sgp.policy_id;
        v_ag_perf_work_payd(j).policy_status_id := sgp.policy_status_id;
        v_ag_perf_work_payd(j).epg_payment_id := sgp.epg_payment_id;
        v_ag_perf_work_payd(j).epg_status_id := g_st_paid;
        v_ag_perf_work_payd(j).pay_payment_id := sgp.pay_payment_id;
      END IF;
    
      y := v_ag_perf_work_dcov.count + 1;
    
      SELECT sq_ag_perf_work_dcover.nextval
        INTO v_ag_perf_work_dcov(y).ag_perf_work_dcover_id
        FROM dual;
    
      v_ag_perf_work_dcov(y).ag_perf_work_dpol_id := v_ag_perf_work_dpol(i).ag_perfom_work_dpol_id;
      v_ag_perf_work_dcov(y).p_cover_id := sgp.p_cover_id;
      v_ag_perf_work_dcov(y).prod_line_option_id := sgp.t_prod_line_option;
      v_ag_perf_work_dcov(y).summ := sgp.brutto_prem;
    
      IF (sgp.check_1 = 1 AND sgp.check_2 = 1)
         OR sgp.payment_term_id = g_pt_nonrecurring
      THEN
        v_sgp := v_sgp + nvl(sgp.brutto_prem, 0) * nvl(sgp.sgp_koef, 0);
        v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + nvl(sgp.brutto_prem, 0);
      END IF;
    
    END LOOP;
  
    FORALL i IN 1 .. v_ag_perf_work_dpol.count
      INSERT INTO ven_ag_perfom_work_dpol VALUES v_ag_perf_work_dpol (i);
  
    FORALL i IN 1 .. v_ag_perf_work_payd.count
      INSERT INTO ven_ag_perf_work_pay_doc VALUES v_ag_perf_work_payd (i);
  
    FORALL i IN 1 .. v_ag_perf_work_dcov.count
      INSERT INTO ven_ag_perf_work_dcover VALUES v_ag_perf_work_dcov (i);
  
    RETURN(v_sgp);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END get_sgp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.02.2009 10:49:30
  -- Purpose : Расчет ДАВ по агенту
  PROCEDURE av_dav_calc_0106(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'av_dav_calc_0106';
    v_cash         t_cash;
    v_ag_ch_id     PLS_INTEGER;
    v_sgp_sum      NUMBER := 0;
    v_dav          NUMBER;
    v_ops_cnt      PLS_INTEGER;
    v_agent_work_m NUMBER;
    v_sgp_plan     NUMBER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.mounth_num
      INTO v_ag_ch_id
          ,v_agent_work_m
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    IF v_agent_work_m <= 36
    THEN
      v_cash    := get_cash(p_ag_perf_work_det_id);
      g_sgp1    := get_sgp(p_ag_perf_work_det_id);
      g_sgp2    := v_cash.commiss_amount;
      v_sgp_sum := g_sgp2 + g_sgp1;
    ELSE
      v_sgp_sum := 0;
    END IF;
  
    --TODO - Подсчет договоров ОПС    
    v_ops_cnt := 3;
  
    v_sgp_plan := nvl(pkg_tariff_calc.calc_coeff_val('SGP_plan_for_DAV'
                                                    ,t_number_type(to_char(g_date_end, 'YYYYMMDD')
                                                                  ,v_agent_work_m
                                                                  ,v_sgp_sum))
                     ,0);
  
    IF v_sgp_plan = 0
    THEN
      v_dav := 0;
    ELSE
      IF v_sgp_sum < v_sgp_plan
      THEN
        --Выполнение плана
        IF v_agent_work_m = 1
        THEN
          --Месяц работы
          IF v_sgp_sum >= v_sgp_plan * (g_date_end + 1 - g_ag_start_date) / --Выполнение скорректированого плана
             (g_date_end + 1 - g_date_begin)
          THEN
            v_dav := nvl(pkg_tariff_calc.calc_coeff_val('DAV_NEW'
                                                       ,t_number_type(to_char(g_date_end, 'YYYYMMDD')
                                                                     ,v_ops_cnt
                                                                     ,g_leg_pos
                                                                     ,v_agent_work_m
                                                                     ,v_sgp_plan))
                        ,0) * v_sgp_sum / v_sgp_plan;
          ELSE
            v_dav := 0;
          END IF;
        ELSE
          v_dav := 0;
        END IF;
      ELSE
        v_dav := nvl(pkg_tariff_calc.calc_coeff_val('DAV_NEW'
                                                   ,t_number_type(to_char(g_date_end, 'YYYYMMDD')
                                                                 ,v_ops_cnt
                                                                 ,g_leg_pos
                                                                 ,v_agent_work_m
                                                                 ,v_sgp_plan))
                    ,0);
      END IF;
    END IF;
  
    v_dav := v_dav - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    g_commision := g_commision + v_dav;
    UPDATE ag_perfom_work_det apd
       SET summ                = v_dav
          ,count_recruit_agent = v_ops_cnt
     WHERE apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_dav_calc_0106;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 03.07.2009 11:37:40
  -- Purpose : Производит расчет ДАВ+
  PROCEDURE av_dav_plus_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(20) := 'ag_dav_plus_calc';
    v_ag_ch_id     PLS_INTEGER;
    v_ag_rate_type PLS_INTEGER;
    v_ag_status    PLS_INTEGER;
    v_dav          NUMBER;
    v_ksp          NUMBER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,(SELECT ash.ag_stat_agent_id
             FROM ag_stat_hist ash
            WHERE ash.ag_stat_hist_id = apw.ag_stat_hist_id)
      INTO v_ag_ch_id
          ,v_ag_rate_type
          ,v_ag_status
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    --TODO учет суммы ДАВ которая уже участвовал в ДАВ+
    SELECT nvl(SUM(apd.summ), 0)
      INTO v_dav
      FROM ag_roll_header       arh
          ,ag_roll              ar
          ,ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE arh.ag_roll_type_id = g_roll_type
       AND arh.ag_roll_header_id = ar.ag_roll_header_id
       AND ar.ag_roll_id = apw.ag_roll_id
       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apw.ag_contract_header_id = v_ag_ch_id
       AND apd.ag_rate_type_id = v_ag_rate_type
       AND arh.date_begin >= '29.05.2009'
       AND arh.date_begin BETWEEN pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 1, -33) AND
           pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -9);
  
    v_ksp := get_ksp(p_ag_perf_work_det_id);
  
    g_commision := g_commision + v_dav * nvl(pkg_tariff_calc.calc_coeff_val('KSP_depend_percent'
                                                                           ,t_number_type(v_ag_rate_type
                                                                                         ,v_ag_status
                                                                                         ,to_char(g_date_end
                                                                                                 ,'YYYYMMDD')
                                                                                         ,1
                                                                                         ,v_ksp))
                                            ,0);
  
    UPDATE ag_perfom_work_det
       SET summ = v_dav *
                  nvl(pkg_tariff_calc.calc_coeff_val('KSP_depend_percent'
                                                    ,t_number_type(v_ag_rate_type
                                                                  ,v_ag_status
                                                                  ,to_char(g_date_end, 'YYYYMMDD')
                                                                  ,1
                                                                  ,v_ksp))
                     ,0)
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END av_dav_plus_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.07.2009 12:43:02
  -- Purpose : Расчет ОАВ с 01/06/2009
  PROCEDURE av_oav_calc_0106(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name         VARCHAR2(20) := 'av_oav_calc_0106';
    v_ag_ch_id        PLS_INTEGER;
    v_agent_status    PLS_INTEGER;
    v_commission      NUMBER;
    v_indexing_sum    NUMBER;
    v_payed_commision NUMBER := 0;
    v_policy_id       PLS_INTEGER := 0;
    v_pay_doc_id      PLS_INTEGER := 0;
    v_epg_doc_id      PLS_INTEGER := 0;
    v_trans_id        PLS_INTEGER := 0;
    v_func_num        PLS_INTEGER := 0;
    i                 PLS_INTEGER;
    j                 PLS_INTEGER;
    y                 PLS_INTEGER;
    v_sav             NUMBER;
    v_attrs           pkg_tariff_calc.attr_type;
    TYPE t_ag_perf_work_dpol IS TABLE OF ven_ag_perfom_work_dpol%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_payd IS TABLE OF ven_ag_perf_work_pay_doc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_tran IS TABLE OF ven_ag_perf_work_trans%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_perf_work_dpol t_ag_perf_work_dpol;
    v_ag_perf_work_payd t_ag_perf_work_payd;
    v_ag_perf_work_tran t_ag_perf_work_tran;
  BEGIN
    SELECT apw.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    FOR cash IN (SELECT tc.*
                       ,tpv.product_id
                       ,tplo.product_line_id
                       ,decode(pt.is_periodical, 0, 1, 0) non_periodeical
                       ,ac.category_id
                       ,pp.fee_payment_term
                   FROM temp_cash_calc     tc
                       ,t_prod_line_option tplo
                       ,t_product_line     tpl
                       ,t_product_ver_lob  tpvl
                       ,t_product_version  tpv
                       ,t_payment_terms    pt
                       ,ag_contract        ac
                       ,p_policy           pp
                  WHERE tplo.id = tc.t_prod_line_option_id
                    AND tplo.product_line_id = tpl.id
                    AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
                    AND tpvl.product_version_id = tpv.t_product_version_id
                    AND pt.id = tc.t_payment_term_id
                    AND ac.ag_contract_id = tc.ag_contract_id
                    AND tc.current_agent = v_ag_ch_id
                    AND pp.policy_id = tc.policy_id
                  ORDER BY tc.active_policy_id
                          ,tc.epg_payment_id
                          ,tc.pay_payment_id
                          ,tc.trans_id)
    LOOP
    
      IF cash.active_policy_id <> v_policy_id
      THEN
        v_policy_id := cash.active_policy_id;
        i           := v_ag_perf_work_dpol.count + 1;
      
        SELECT sq_ag_perfom_work_dpol.nextval
          INTO v_ag_perf_work_dpol(i).ag_perfom_work_dpol_id
          FROM dual;
      
        v_ag_perf_work_dpol(i).ag_perfom_work_det_id := p_ag_perf_work_det_id;
        v_ag_perf_work_dpol(i).policy_id := cash.active_policy_id;
        v_ag_perf_work_dpol(i).policy_status_id := cash.active_pol_status_id;
        v_ag_perf_work_dpol(i).ag_contract_header_ch_id := cash.current_agent;
        v_ag_perf_work_dpol(i).ag_status_id := cash.agent_status_id;
        v_ag_perf_work_dpol(i).policy_agent_part := cash.policy_agent_part;
        v_ag_perf_work_dpol(i).policy_agent_date := cash.policy_agent_date;
        v_ag_perf_work_dpol(i).summ := 0;
        v_ag_perf_work_dpol(i).pay_term := cash.t_payment_term_id;
        v_ag_perf_work_dpol(i).ag_leg_pos := cash.leg_pos;
        v_ag_perf_work_dpol(i).check_1 := cash.check_1;
        v_ag_perf_work_dpol(i).check_2 := cash.check_2;
        v_ag_perf_work_dpol(i).check_3 := cash.check_3;
        v_ag_perf_work_dpol(i).insurance_period := cash.insurance_period;
      END IF;
    
      IF cash.pay_payment_id <> v_pay_doc_id
         OR cash.epg_payment_id <> v_epg_doc_id
      THEN
        v_pay_doc_id := cash.pay_payment_id;
        v_epg_doc_id := cash.epg_payment_id;
        j            := v_ag_perf_work_payd.count + 1;
      
        SELECT sq_ag_perf_work_pay_doc.nextval
          INTO v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id
          FROM dual;
      
        v_ag_perf_work_payd(j).ag_preformed_work_dpol_id := v_ag_perf_work_dpol(i)
                                                            .ag_perfom_work_dpol_id;
        v_ag_perf_work_payd(j).policy_id := cash.policy_id;
        v_ag_perf_work_payd(j).policy_status_id := cash.policy_status_id;
        v_ag_perf_work_payd(j).epg_payment_id := cash.epg_payment_id;
        v_ag_perf_work_payd(j).epg_status_id := cash.epg_status_id;
        v_ag_perf_work_payd(j).pay_payment_id := cash.pay_payment_id;
        v_ag_perf_work_payd(j).pay_bank_doc_id := cash.pay_bank_doc_id;
        v_ag_perf_work_payd(j).year_of_insurance := cash.year_of_insurance;
      END IF;
    
      v_func_num := pkg_tariff_calc.calc_coeff_val('GP_PROG'
                                                  ,t_number_type(cash.product_id, cash.product_line_id));
    
      IF cash.agent_status_id > 125
      THEN
        v_agent_status := 123;
      ELSE
        v_agent_status := cash.agent_status_id;
      END IF;
    
      v_indexing_sum := 0;
    
      IF cash.is_indexing = 1
      THEN
        v_attrs.delete; --Почистим на всякий случай;
        CASE
          WHEN v_func_num < 6 THEN
            v_attrs(1) := v_agent_status; --Статус Агента
            v_attrs(2) := cash.leg_pos; --Юр статус
            v_attrs(3) := cash.insurance_period - cash.year_of_insurance + 1; --Период страхования
            v_attrs(4) := 1; --Год действия
            v_attrs(5) := cash.non_periodeical; --единовременная
            v_attrs(6) := 0; --переданный ДС
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 6), 0);
          WHEN v_func_num < 12 THEN
            v_attrs(1) := v_agent_status; --Статус Агента
            v_attrs(2) := cash.leg_pos; --Юр статус
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          WHEN v_func_num = 12 THEN
            v_attrs(1) := cash.leg_pos; --Юр статус
            v_attrs(2) := cash.t_payment_term_id; --Условие рассрочки платежа
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          WHEN v_func_num = 13 THEN
            v_attrs(1) := cash.leg_pos; --Юр статус
            v_attrs(2) := cash.category_id; --Категория агента
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          WHEN v_func_num = 14 THEN
            v_sav := nvl(pkg_tariff_calc.calc_fun('GP14', 1, 1), 0);
          WHEN v_func_num IN (15, 16) THEN
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num
                                                       ,t_number_type(cash.leg_pos))
                        ,0);
          WHEN v_func_num IN (17) THEN
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP17', t_number_type(1)), 0);
          WHEN v_func_num IN (18) THEN
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP18'
                                                       ,t_number_type(cash.fee_payment_term
                                                                     ,cash.leg_pos
                                                                     ,cash.year_of_insurance))
                        ,0);
          ELSE
            v_sav := 0;
        END CASE;
      
        v_indexing_sum := cash.trans_amount *
                          pkg_renlife_utils.get_indexing_summ(cash.epg_payment_id
                                                             ,cash.t_prod_line_option_id
                                                             ,3);
      
        --Доп проверки в соответствии с ТЗ.
        IF cash.check_1 = 0
           OR --Check_1
           cash.check_2 = 0
           OR --Check_2
           cash.check_3 = 0
           OR --Check_3
           cash.epg_status_id <> g_st_paid --Check_4         
        -- v_sav IS NULL OR v_sav = 0 --Check_5
        THEN
          v_commission := 0;
          v_trans_id   := NULL;
        ELSE
          v_commission := (v_sav / 100) * nvl(cash.policy_agent_part / 100, 1) * v_indexing_sum;
          v_trans_id   := cash.trans_id;
        END IF;
      
        y := v_ag_perf_work_tran.count + 1;
      
        SELECT sq_ag_perf_work_trans.nextval
          INTO v_ag_perf_work_tran(y).ag_perf_work_trans_id
          FROM dual;
      
        v_ag_perf_work_tran(y).ag_perf_work_pay_doc_id := v_ag_perf_work_payd(j)
                                                          .ag_perf_work_pay_doc_id;
        v_ag_perf_work_tran(y).trans_id := v_trans_id;
        v_ag_perf_work_tran(y).t_prod_line_option_id := cash.t_prod_line_option_id;
        v_ag_perf_work_tran(y).sum_premium := v_indexing_sum;
        v_ag_perf_work_tran(y).sav := v_sav;
        v_ag_perf_work_tran(y).is_indexing := 1;
      
        IF g_roll_num <> 1
        THEN
          SELECT nvl(SUM(apt.sum_commission), 0)
            INTO v_payed_commision
            FROM ag_roll_header       arh
                ,ag_roll              ar
                ,ag_roll_type         art
                ,ag_perfomed_work_act apw
                ,ag_perfom_work_det   apd
                ,ag_perfom_work_dpol  apdp
                ,ag_perf_work_pay_doc appd
                ,ag_perf_work_trans   apt
           WHERE arh.ag_roll_header_id = g_roll_header_id
             AND arh.ag_roll_type_id = art.ag_roll_type_id
             AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
             AND apw.ag_contract_header_id = v_ag_ch_id
             AND ar.ag_roll_header_id = arh.ag_roll_header_id
             AND apw.ag_roll_id = ar.ag_roll_id
             AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
             AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
             AND appd.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
             AND appd.ag_perf_work_pay_doc_id = apt.ag_perf_work_pay_doc_id
             AND apt.trans_id = cash.trans_id
             AND apt.is_indexing = 1;
          v_commission := v_commission - v_payed_commision;
        END IF;
      
        v_ag_perf_work_tran(y).sum_commission := v_commission;
        v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + v_indexing_sum;
      
        g_sgp1      := g_sgp1 + v_indexing_sum;
        g_commision := g_commision + v_commission;
      
      END IF;
    
      v_attrs.delete; --Почистим на всякий случай;
      CASE
        WHEN v_func_num < 6 THEN
          v_attrs(1) := v_agent_status; --Статус Агента
          v_attrs(2) := cash.leg_pos; --Юр статус
          v_attrs(3) := cash.insurance_period; --Период страхования
          v_attrs(4) := cash.year_of_insurance; --Год действия
          v_attrs(5) := cash.non_periodeical; --единовременная
          v_attrs(6) := 0; --переданный ДС
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 6), 0);
        WHEN v_func_num < 12 THEN
          v_attrs(1) := v_agent_status; --Статус Агента
          v_attrs(2) := cash.leg_pos; --Юр статус
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
        WHEN v_func_num = 12 THEN
          v_attrs(1) := cash.leg_pos; --Юр статус
          v_attrs(2) := cash.t_payment_term_id; --Условие рассрочки платежа
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
        WHEN v_func_num = 13 THEN
          v_attrs(1) := cash.leg_pos; --Юр статус
          v_attrs(2) := cash.category_id; --Категория агента
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
        WHEN v_func_num = 14 THEN
          v_sav := nvl(pkg_tariff_calc.calc_fun('GP14', 1, 1), 0);
        WHEN v_func_num IN (15, 16) THEN
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, t_number_type(cash.leg_pos))
                      ,0);
        WHEN v_func_num IN (17) THEN
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, t_number_type(1)), 0);
        WHEN v_func_num IN (18) THEN
          v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP18'
                                                     ,t_number_type(cash.fee_payment_term
                                                                   ,cash.leg_pos
                                                                   ,cash.year_of_insurance))
                      ,0);
        ELSE
          v_sav := 0;
      END CASE;
    
      --Доп проверки в соответствии с ТЗ.
      IF cash.check_1 = 0
         OR --Check_1
         cash.check_2 = 0
         OR --Check_2
         cash.check_3 = 0
         OR --Check_3
         cash.epg_status_id <> g_st_paid --Check_4         
      --  v_sav IS NULL OR v_sav = 0 --Check_5
      THEN
        v_commission := 0;
        v_trans_id   := NULL;
      ELSE
        v_commission := (v_sav / 100) * nvl(cash.policy_agent_part / 100, 1) *
                        (cash.trans_amount - v_indexing_sum);
        v_trans_id   := cash.trans_id;
      END IF;
    
      y := v_ag_perf_work_tran.count + 1;
    
      SELECT sq_ag_perf_work_trans.nextval
        INTO v_ag_perf_work_tran(y).ag_perf_work_trans_id
        FROM dual;
    
      v_ag_perf_work_tran(y).ag_perf_work_pay_doc_id := v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id;
      v_ag_perf_work_tran(y).trans_id := v_trans_id;
      v_ag_perf_work_tran(y).t_prod_line_option_id := cash.t_prod_line_option_id;
      v_ag_perf_work_tran(y).sum_premium := cash.trans_amount - v_indexing_sum;
      v_ag_perf_work_tran(y).sav := v_sav;
      v_ag_perf_work_tran(y).is_indexing := 0;
    
      IF g_roll_num <> 1
      THEN
        SELECT nvl(SUM(apt.sum_commission), 0)
          INTO v_payed_commision
          FROM ag_roll_header       arh
              ,ag_roll              ar
              ,ag_roll_type         art
              ,ag_perfomed_work_act apw
              ,ag_perfom_work_det   apd
              ,ag_perfom_work_dpol  apdp
              ,ag_perf_work_pay_doc appd
              ,ag_perf_work_trans   apt
         WHERE arh.ag_roll_header_id = g_roll_header_id
           AND arh.ag_roll_type_id = art.ag_roll_type_id
           AND substr(art.brief, 1, 3) = substr(g_roll_type_brief, 1, 3)
           AND apw.ag_contract_header_id = v_ag_ch_id
           AND ar.ag_roll_header_id = arh.ag_roll_header_id
           AND apw.ag_roll_id = ar.ag_roll_id
           AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
           AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
           AND appd.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
           AND appd.ag_perf_work_pay_doc_id = apt.ag_perf_work_pay_doc_id
           AND apt.trans_id = cash.trans_id
           AND apt.is_indexing = 0;
        v_commission := v_commission - v_payed_commision;
      END IF;
    
      v_ag_perf_work_tran(y).sum_commission := v_commission;
    
      v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + cash.trans_amount - v_indexing_sum;
    
      g_sgp1      := g_sgp1 + cash.trans_amount - v_indexing_sum;
      g_commision := g_commision + v_commission;
    
    END LOOP;
  
    FORALL i IN 1 .. v_ag_perf_work_dpol.count
      INSERT INTO ven_ag_perfom_work_dpol VALUES v_ag_perf_work_dpol (i);
  
    FORALL i IN 1 .. v_ag_perf_work_payd.count
      INSERT INTO ven_ag_perf_work_pay_doc VALUES v_ag_perf_work_payd (i);
  
    FORALL i IN 1 .. v_ag_perf_work_tran.count
      INSERT INTO ven_ag_perf_work_trans VALUES v_ag_perf_work_tran (i);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END av_oav_calc_0106;

  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  --
  --ПРОЦЕДУРЫ МОТИВАЦИИ ДЕЙСТВОВАШИЕ С 01/04/2009 по 01/06/2009
  --Могут быть вызваны при создании старых типов ведомостей
  --
  --
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.04.2009 19:08:50
  -- Purpose : Расчет ДАВ пол полису для групповых договоров
  -- Действовал с 01/04/09 по 01/06/09
  FUNCTION av_dav_get_cash
  (
    par_policy_header_id NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER IS
    proc_name        VARCHAR2(30) := 'av_dav_agent_gr_policy_calc';
    v_sgp_summ       NUMBER;
    v_return_sum     NUMBER := 0;
    v_trans_id       PLS_INTEGER;
    v_cur_count      PLS_INTEGER := 0;
    v_pay_doc_count  PLS_INTEGER := 0;
    v_apw_pay_doc_id PLS_INTEGER;
  BEGIN
    FOR pay_doc IN (SELECT /*+ ORDERED*/
                     pp.policy_id
                    ,doc.get_doc_status_id(pp.policy_id) policy_status
                    ,epg.payment_id epg
                    ,doc.get_doc_status_id(epg.payment_id) epg_status
                    ,pay_d.payment_id pay_doc
                    ,pay_d.reg_date pay_d_date
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        dso.doc_set_off_id
                       ELSE
                        bank_doc.doc_set_off_id
                     END set_off_doc
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        pay_d.payment_id
                       ELSE
                        bank_doc.child_doc_id
                     END bank_doc
                      FROM p_pol_header ph
                          ,p_policy pp
                          ,doc_doc dd
                          ,ven_ac_payment epg
                          ,doc_templ dt1
                          ,doc_set_off dso
                          ,ven_ac_payment pay_d
                          ,doc_templ dt
                          ,(SELECT dso2.child_doc_id
                                  ,dd2.parent_id
                                  ,dso2.doc_set_off_id
                              FROM doc_doc     dd2
                                  ,doc_set_off dso2
                             WHERE dso2.parent_doc_id = dd2.child_id) bank_doc
                     WHERE dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt1.doc_templ_id = epg.doc_templ_id
                       AND dt1.brief = 'PAYMENT' -- ЭПГ имеет тип "Счет на оплату взносов"
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_d.payment_id
                       AND pay_d.doc_templ_id = dt.doc_templ_id
                       AND dt.brief IN ('ПП', 'A7', 'PD4')
                       AND epg.plan_date < g_date_end
                       AND pay_d.due_date BETWEEN g_date_begin AND g_date_end --изменения в ТЗ (согласовано с Иконописцевым)
                       AND pay_d.reg_date > '31.07.2007' -- Платежный документ создали после Внедрения
                       AND epg.reg_date > ADD_MONTHS(g_date_end, -15) --Ограничим немного выборку 
                       AND epg.plan_date BETWEEN ph.start_date AND ADD_MONTHS(ph.start_date, 12) - 1
                       AND dso.set_off_date <= g_date_end
                       AND pay_d.payment_id = bank_doc.parent_id(+)
                       AND ph.policy_header_id = par_policy_header_id
                       AND pp.pol_header_id = ph.policy_header_id)
    LOOP
      v_pay_doc_count := 0;
      FOR tran IN (SELECT t.trans_id
                         ,tplo.id prod_line_option
                         ,t.trans_amount
                     FROM oper               o
                         ,trans              t
                         ,trans_templ        tt
                         ,p_cover            pc
                         ,t_prod_line_option tplo
                    WHERE o.oper_id = t.oper_id
                      AND t.trans_templ_id = tt.trans_templ_id
                      AND tt.brief IN ('СтраховаяПремияОплачена'
                                      ,'СтраховаяПремияАвансОпл'
                                      ,'ПремияОплаченаПоср'
                                      ,'ЗачВзнСтрАг')
                      AND t.obj_uro_id = pc.p_cover_id
                      AND pc.t_prod_line_option_id = tplo.id
                      AND o.document_id = pay_doc.set_off_doc
                      AND tplo.description <> 'Административные издержки'
                      AND NOT EXISTS
                    (SELECT 1
                             FROM ag_roll              ar
                                 ,ag_roll_header       arh
                                 ,ag_perfomed_work_act apw
                                 ,ag_perfom_work_det   apdet
                                 ,ag_perfom_work_dpol  apdpol
                                 ,ag_perf_work_pay_doc apd
                                 ,ag_perf_work_trans   apwt
                            WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                              AND arh.ag_roll_type_id = g_roll_type
                              AND arh.ag_roll_header_id <> g_roll_header_id
                              AND apw.ag_roll_id = ar.ag_roll_id
                              AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                              AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                              AND apdpol.ag_perfom_work_dpol_id = apd.ag_preformed_work_dpol_id
                              AND apd.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
                              AND apwt.trans_id = t.trans_id))
      LOOP
        IF v_cur_count = 0
        THEN
          INSERT INTO ven_ag_perfom_work_dpol
            (ag_perfom_work_dpol_id
            ,ag_contract_header_ch_id
            ,ag_perfom_work_det_id
            ,policy_id
            ,policy_status_id
            ,ag_leg_pos
            ,ag_status_id
            ,insurance_period
            ,pay_term
            ,is_transfered
            ,policy_agent_part
            ,summ
            ,check_1
            ,check_2
            ,check_3)
          VALUES
            (g_ag_work_dpol.ag_perfom_work_dpol_id
            ,g_ag_work_dpol.ag_contract_header_ch_id
            ,g_ag_work_dpol.ag_perfom_work_det_id
            ,g_ag_work_dpol.policy_id
            ,g_ag_work_dpol.policy_status_id
            ,g_ag_work_dpol.ag_leg_pos
            ,g_ag_work_dpol.ag_status_id
            ,g_ag_work_dpol.insurance_period
            ,g_ag_work_dpol.pay_term
            ,g_ag_work_dpol.is_transfered
            ,g_ag_work_dpol.policy_agent_part
            ,g_ag_work_dpol.summ
            ,g_ag_work_dpol.check_1
            ,g_ag_work_dpol.check_2
            ,g_ag_work_dpol.check_3);
          v_cur_count := v_cur_count + 1;
        END IF;
      
        IF v_pay_doc_count = 0
        THEN
          SELECT sq_ag_perf_work_pay_doc.nextval INTO v_apw_pay_doc_id FROM dual;
        
          INSERT INTO ven_ag_perf_work_pay_doc
            (ag_perf_work_pay_doc_id
            ,ag_preformed_work_dpol_id
            ,epg_payment_id
            ,epg_status_id
            ,pay_bank_doc_id
            ,pay_payment_id
            ,policy_id
            ,policy_status_id)
          VALUES
            (v_apw_pay_doc_id
            ,p_performed_act_dpol
            ,pay_doc.epg
            ,pay_doc.epg_status
            ,pay_doc.bank_doc
            ,pay_doc.pay_doc
            ,pay_doc.policy_id
            ,pay_doc.policy_status);
          v_pay_doc_count := 1;
        END IF;
      
        --Доп проверки в соответствии с ТЗ.
        IF g_ag_work_dpol.check_1 = 0
           OR --Check_1
           g_ag_work_dpol.check_2 = 0
           OR --Check_2
           g_ag_work_dpol.check_3 = 0
           OR --Check_3
           pay_doc.epg_status <> g_st_paid --Check_4         
        THEN
          v_sgp_summ := 0;
          v_trans_id := NULL;
        ELSE
          v_sgp_summ := tran.trans_amount;
          v_trans_id := tran.trans_id;
        END IF;
      
        INSERT INTO ven_ag_perf_work_trans
          (ag_perf_work_pay_doc_id
          ,is_indexing
          ,sav
          ,sum_commission
          ,sum_premium
          ,t_prod_line_option_id
          ,trans_id)
        VALUES
          (v_apw_pay_doc_id
          ,0
          , --tran.indexing, 
           0
          ,v_sgp_summ
          ,tran.trans_amount
          ,tran.prod_line_option
          ,v_trans_id);
      
        v_return_sum := v_return_sum + v_sgp_summ;
      END LOOP;
    END LOOP;
  
    UPDATE ag_perfom_work_dpol d
       SET d.summ = v_return_sum
     WHERE d.ag_perfom_work_dpol_id = g_ag_work_dpol.ag_perfom_work_dpol_id;
    RETURN(v_return_sum);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || par_policy_header_id ||
                              SQLERRM || chr(10));
  END av_dav_get_cash;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.02.2009 16:02:59
  -- Purpose : Расчет ДАВ по полису для агента
  FUNCTION av_dav_get_sgp
  (
    par_pol_header       NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER IS
    proc_name    VARCHAR2(25) := 'av_dav_agent_policy_calc';
    ret_sgp_summ NUMBER;
  BEGIN
    ret_sgp_summ := 0;
    FOR pay_doc IN (SELECT (SELECT SUM(pc.fee)
                              FROM as_asset           ass
                                  ,p_cover            pc
                                  ,t_prod_line_option tplo
                             WHERE ass.p_policy_id = pp.policy_id
                               AND ass.as_asset_id = pc.as_asset_id
                               AND pc.t_prod_line_option_id = tplo.id
                               AND tplo.description <> 'Административные издержки') * --Брутто взнос
                           pt.number_of_payments * --Кол-во платежей
                           acc.get_cross_rate_by_id(1
                                                   ,ph.fund_id
                                                   ,122
                                                   ,(SELECT MAX(pay_d1.reg_date)
                                                      FROM doc_set_off    dso
                                                          ,ven_ac_payment pay_d1
                                                          ,doc_templ      pay_temp
                                                     WHERE dso.parent_doc_id = epg.payment_id
                                                       AND dso.child_doc_id = pay_d1.payment_id
                                                       AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                                       AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))) sgp
                          , --Валюта на дату Плат. док.
                           epg.payment_id epg_id
                          ,doc.get_doc_status_id(epg.payment_id) epg_status
                          ,(SELECT DISTINCT last_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pay_doc_id
                      FROM p_policy        pp
                          ,p_pol_header    ph
                          ,doc_doc         dd
                          ,ven_ac_payment  epg
                          ,doc_templ       epg_dt
                          ,t_payment_terms pt
                     WHERE pp.pol_header_id = par_pol_header
                       AND pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND pp.policy_id = dd.parent_id
                       AND epg.payment_id = dd.child_id
                       AND epg.doc_templ_id = epg_dt.doc_templ_id
                       AND epg_dt.brief = 'PAYMENT'
                       AND epg.payment_number = 1
                       AND greatest((SELECT MAX(pay_d1.due_date)
                                      FROM doc_set_off    dso
                                          ,ven_ac_payment pay_d1
                                          ,doc_templ      pay_temp
                                     WHERE dso.parent_doc_id = epg.payment_id
                                       AND dso.child_doc_id = pay_d1.payment_id
                                       AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                       AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))
                                   ,ph.start_date) BETWEEN g_date_begin AND g_date_end)
    LOOP
    
      g_ag_work_dpol.summ := pay_doc.sgp; /*g_ag_work_dpol.POLICY_AGENT_PART*/
    
      IF g_ag_work_dpol.check_1 = 0
         OR --Check_1
         g_ag_work_dpol.check_2 = 0
         OR --Check_2
         g_ag_work_dpol.check_3 = 0
         OR --Chrck_3
         pay_doc.epg_status <> g_st_paid --Check_4
      THEN
        ret_sgp_summ := 0;
      ELSE
        ret_sgp_summ := nvl(g_ag_work_dpol.summ, 0);
      END IF;
    
      INSERT INTO ven_ag_perfom_work_dpol
        (ag_perfom_work_dpol_id
        ,ag_contract_header_ch_id
        ,ag_perfom_work_det_id
        ,policy_id
        ,policy_status_id
        ,ag_leg_pos
        ,ag_status_id
        ,insurance_period
        ,pay_term
        ,is_transfered
        ,policy_agent_part
        ,summ
        ,check_1
        ,check_2
        ,check_3)
      VALUES
        (g_ag_work_dpol.ag_perfom_work_dpol_id
        ,g_ag_work_dpol.ag_contract_header_ch_id
        ,g_ag_work_dpol.ag_perfom_work_det_id
        ,g_ag_work_dpol.policy_id
        ,g_ag_work_dpol.policy_status_id
        ,g_ag_work_dpol.ag_leg_pos
        ,g_ag_work_dpol.ag_status_id
        ,g_ag_work_dpol.insurance_period
        ,g_ag_work_dpol.pay_term
        ,g_ag_work_dpol.is_transfered
        ,g_ag_work_dpol.policy_agent_part
        ,ret_sgp_summ
        ,g_ag_work_dpol.check_1
        ,g_ag_work_dpol.check_2
        ,g_ag_work_dpol.check_3);
    
      INSERT INTO ven_ag_perf_work_pay_doc
        (ag_preformed_work_dpol_id, epg_payment_id, epg_status_id, pay_payment_id)
      VALUES
        (p_performed_act_dpol, pay_doc.epg_id, pay_doc.epg_status, pay_doc.pay_doc_id);
    
    END LOOP;
    RETURN(ret_sgp_summ);
  EXCEPTION
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Ошибка ' || proc_name || 'существует более 1ого ЭПГ с номером 1' ||
                              chr(10));
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_dav_get_sgp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.02.2009 10:02:45
  -- Purpose : Расчет ведомости ДАВ
  PROCEDURE av_dav_all_calc(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(20) := 'av_dav_all_calc';
    v_apw_id  PLS_INTEGER;
  BEGIN
  
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
  
    pkg_agent_calculator.insertinfo('Начат расчет актов');
  
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ash.ag_stat_hist_id
                         ,ash.ag_stat_agent_id
                         ,ac.is_comm_holding
                         ,ac.category_id
                         ,
                          --            ach.date_begin,
                          (SELECT MIN(ach1.date_begin)
                             FROM ag_contract_header ach1
                            WHERE ach1.agent_id = ach.agent_id) date_begin
                         ,doc.get_doc_status_id(ac.ag_contract_id) ad_status
                         ,CASE
                            WHEN ac.leg_pos = 0 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                            WHEN ac.leg_pos = 1 THEN
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ПБОЮЛ')
                            ELSE
                             (SELECT id
                                FROM t_contact_type
                               WHERE is_legal_entity = 0
                                 AND is_leaf = 1
                                 AND brief = 'ФЛ')
                          END ag_leg_pos
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,ag_stat_hist       ash
                         ,t_sales_channel    ts
                         ,ag_stat_agent      asa
                    WHERE pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end) =
                          ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ash.ag_contract_header_id = ach.ag_contract_header_id
                      AND ach.ag_contract_header_id <> 2125380 -- Неопознаный агент
                      AND ac.category_id = 2
                      AND ash.num = (SELECT MAX(num)
                                       FROM ag_stat_hist ash1
                                      WHERE ash1.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ash1.stat_date <= g_date_end)
                      AND asa.ag_stat_agent_id = ash.ag_stat_agent_id
                      AND ach.t_sales_channel_id = ts.id
                      AND doc.get_doc_status_id(ac.ag_contract_id) IN (g_st_curr, g_st_resume)
                      AND ((g_roll_type = 41 AND
                           ent.obj_name('DEPARTMENT', ach.agency_id) <> 'Внешние агенты и агентства' AND
                           ts.brief = 'MLM') OR
                           ts.brief =
                           decode(g_roll_type, 44, 'BANK', 45, 'BR', 46, 'CORPORATE', '!NONE!')))
    LOOP
      g_sgp1          := 0;
      g_ag_start_date := agents.date_begin;
      g_leg_pos       := agents.ag_leg_pos;
      g_ag_status     := agents.ag_stat_agent_id;
    
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     agents.ag_contract_header_id
                                    ,g_roll_id
                                    ,agents.cur_count);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,delta
        ,sgp1
        ,sgp2
        ,SUM
        ,date_calc
        ,ag_stat_hist_id
        ,status_id
        ,is_deduct)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,agents.ag_contract_header_id
        ,0
        ,0
        ,0
        ,0
        ,SYSDATE
        ,agents.ag_stat_hist_id
        ,agents.ad_status
        ,agents.is_comm_holding);
    
      av_dav_agent_calc(agents.ag_contract_header_id, v_apw_id);
    
      UPDATE ag_perfomed_work_act apw
         SET apw.sum =
             (SELECT SUM(summ)
                FROM ag_perfom_work_det apd
               WHERE apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id)
            ,apw.sgp1 = g_sgp1
            ,apw.sgp2 = g_sgp2
       WHERE apw.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT; --после каждого акта
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_dav_all_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.02.2009 10:49:30
  -- Purpose : Расчет ДАВ по агенту
  PROCEDURE av_dav_agent_calc
  (
    p_ag_contract_header_id NUMBER
   ,p_ag_perfomed_act       NUMBER
  ) IS
    proc_name      VARCHAR2(20) := 'av_dav_agent_calc';
    v_sgp          NUMBER;
    v_sgp_sum      NUMBER;
    v_dav          NUMBER;
    v_payed_dav    NUMBER := 0;
    v_apw_pol_id   PLS_INTEGER;
    v_apw_det_id   PLS_INTEGER;
    v_prem_type    PLS_INTEGER;
    v_attrs        pkg_tariff_calc.attr_type;
    v_koef         NUMBER;
    v_ops_cnt      PLS_INTEGER;
    v_agent_work_m NUMBER;
    v_sgp_plan     NUMBER;
  BEGIN
    --Вставляем запись в детали по акту
    SELECT art.ag_rate_type_id INTO v_prem_type FROM ven_ag_rate_type art WHERE art.brief = 'DAV';
  
    SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
  
    INSERT INTO ven_ag_perfom_work_det d
      (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
    VALUES
      (v_apw_det_id, p_ag_perfomed_act, v_prem_type, 0);
  
    v_sgp_sum := 0;
  
    FOR agent_pol IN (SELECT pa.p_policy_agent_id
                            ,pa.policy_header_id
                            ,tp.is_group
                            ,tp.product_id
                            ,ph.policy_id
                            ,doc.get_doc_status_id(ph.policy_id) active_policy_st
                            , --check?
                             ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                            ,pp.payment_term_id pay_term
                            ,(SELECT CASE
                                       WHEN COUNT(*) > 0 THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM ag_contract_header ach
                                    ,ag_contract        ac
                               WHERE ac.ag_contract_id =
                                     pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                   ,ph.start_date)
                                 AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) <>
                                     g_st_berak
                                 AND ach.agent_id =
                                     pkg_policy.get_policy_contact(ph.policy_id
                                                                  ,'Страхователь')) insuer_not_agent
                            , --check1
                             (SELECT CASE
                                       WHEN COUNT(*) > 0 THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM ven_as_assured va
                               WHERE va.p_policy_id = ph.policy_id
                                 AND EXISTS
                               (SELECT 1
                                        FROM ag_contract_header ach1
                                            ,ag_contract        ac1
                                       WHERE ac1.ag_contract_id =
                                             pkg_agent_1.get_status_by_date(ach1.ag_contract_header_id
                                                                           ,ph.start_date)
                                         AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) <>
                                             g_st_berak
                                         AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                            ,pa.date_start pa_date_start
                            ,pa.date_end
                        FROM p_policy_agent      pa
                            ,policy_agent_status pas
                            ,p_pol_header        ph
                            ,p_policy            pp
                            ,t_product           tp
                       WHERE pa.ag_contract_header_id = p_ag_contract_header_id
                         AND pa.status_id = pas.policy_agent_status_id
                         AND pa.policy_header_id = ph.policy_header_id
                         AND ph.product_id = tp.product_id
                         AND pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 1) >= '01.04.2009' --Не входил в старую мотивацию 
                         AND ph.policy_id = pp.policy_id
                         AND NOT EXISTS
                       (SELECT 1 --Нет агнетов в статусе отменен
                                FROM p_policy_agent      pa1
                                    ,policy_agent_status pas1
                               WHERE pa1.policy_header_id = ph.policy_header_id
                                 AND pa1.status_id = pas1.policy_agent_status_id
                                 AND pas1.brief = 'CANCEL')
                         AND pas.brief = 'CURRENT' --Агент в статусе Действующий
                         AND doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                             (g_st_berak, g_st_readycancel, g_st_stoped)
                         AND (ph.policy_header_id NOT IN
                             (SELECT pp.pol_header_id --Нет в пердидущих расчетах ДАВ
                                 FROM ag_roll_type         art
                                     ,ven_ag_roll_header   arh
                                     ,ag_roll              ar
                                     ,ag_perfomed_work_act apw
                                     ,ag_perfom_work_det   apwd
                                     ,ag_perfom_work_dpol  apd
                                     ,p_policy             pp
                                WHERE art.brief = 'DAV'
                                  AND arh.ag_roll_header_id = art.ag_roll_type_id
                                  AND ar.ag_roll_header_id = arh.ag_roll_header_id
                                  AND ar.ag_roll_header_id <> g_roll_header_id
                                  AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                                  AND arh.ag_roll_type_id = g_roll_type
                                  AND apw.ag_roll_id = ar.ag_roll_id
                                  AND apw.ag_contract_header_id = p_ag_contract_header_id
                                  AND apwd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                                  AND apd.ag_perfom_work_det_id = apwd.ag_perfom_work_det_id
                                  AND pp.policy_id = apd.policy_id) OR tp.is_group = 1))
    LOOP
    
      v_attrs.delete;
    
      IF agent_pol.is_group = 0
      THEN
        v_attrs(1) := agent_pol.product_id;
        v_attrs(2) := agent_pol.pay_term;
        v_attrs(3) := agent_pol.insurance_period;
        v_attrs(4) := 1; --ДАВ
        v_attrs(5) := to_char(g_date_end, 'YYYYMMDD');
        v_koef := nvl(pkg_tariff_calc.calc_coeff_val('SGP_koeff', v_attrs, 5), 0);
      ELSE
        v_koef := 1;
      END IF;
    
      --Вставляем запись в детали полиса
      SELECT sq_ag_perfom_work_dpol.nextval INTO v_apw_pol_id FROM dual;
    
      g_ag_work_dpol.ag_perfom_work_dpol_id   := v_apw_pol_id;
      g_ag_work_dpol.ag_contract_header_ch_id := p_ag_contract_header_id;
      g_ag_work_dpol.ag_perfom_work_det_id    := v_apw_det_id;
      g_ag_work_dpol.policy_id                := agent_pol.policy_id;
      g_ag_work_dpol.policy_status_id         := agent_pol.active_policy_st;
      g_ag_work_dpol.ag_leg_pos               := g_leg_pos;
      g_ag_work_dpol.ag_status_id             := g_ag_status;
      g_ag_work_dpol.insurance_period := CASE
                                           WHEN abs(agent_pol.insurance_period) > 99 THEN
                                            -1
                                           ELSE
                                            agent_pol.insurance_period
                                         END;
      g_ag_work_dpol.pay_term                 := agent_pol.pay_term;
      g_ag_work_dpol.is_transfered            := NULL; --AGENT_POL.TRANSFERED;
      g_ag_work_dpol.policy_agent_date        := agent_pol.pa_date_start;
      g_ag_work_dpol.policy_agent_part        := v_koef;
      g_ag_work_dpol.summ                     := 0;
      g_ag_work_dpol.check_1                  := agent_pol.insuer_not_agent;
      g_ag_work_dpol.check_2                  := agent_pol.assured_not_agent;
      g_ag_work_dpol.check_3                  := 1; --AGENT_POL.CHECK3;
    
      IF agent_pol.is_group = 0
      THEN
        v_sgp     := av_dav_agent_policy_calc(agent_pol.policy_header_id, v_apw_pol_id);
        v_sgp_sum := v_sgp_sum + v_sgp * v_koef;
      ELSE
        v_sgp     := av_dav_agent_gr_policy_calc(agent_pol.policy_header_id, v_apw_pol_id);
        v_sgp_sum := v_sgp_sum + v_sgp;
      END IF;
    END LOOP;
  
    v_ops_cnt := 3;
  
    v_agent_work_m := CEIL(MONTHS_BETWEEN(g_date_end + 1, g_ag_start_date));
  
    v_attrs.delete;
    v_attrs(1) := to_char(g_date_end, 'YYYYMMDD');
    v_attrs(2) := v_agent_work_m;
    v_attrs(3) := v_sgp_sum;
    v_sgp_plan := nvl(pkg_tariff_calc.calc_coeff_val('SGP_plan_for_DAV', v_attrs, 3), 0);
  
    IF v_sgp_plan = 0
    THEN
      v_dav := 0;
    ELSE
      IF v_sgp_sum < v_sgp_plan
      THEN
        --Выполнение плана
        IF v_agent_work_m = 1
        THEN
          --Месяц работы
          IF v_sgp_sum >= v_sgp_plan * (g_date_end + 1 - g_ag_start_date) / --Выполнение скорректированого плана
             (g_date_end + 1 - trunc(g_ag_start_date, 'MONTH'))
          THEN
            v_attrs.delete;
            v_attrs(1) := to_char(g_date_end, 'YYYYMMDD');
            v_attrs(2) := v_ops_cnt;
            v_attrs(3) := g_leg_pos;
            v_attrs(4) := v_agent_work_m;
            v_attrs(5) := v_sgp_plan;
            v_dav := nvl(pkg_tariff_calc.calc_coeff_val('DAV_NEW', v_attrs, 5), 0) * v_sgp_sum /
                     v_sgp_plan;
            v_sgp_plan := v_sgp_plan * (g_date_end + 1 - g_ag_start_date) /
                          (g_date_end + 1 - trunc(g_ag_start_date, 'MONTH')); --Чтобы была возможность хранить приведенный план
          ELSE
            v_dav := 0;
          END IF;
        ELSE
          v_dav := 0;
        END IF;
      ELSE
        v_attrs.delete;
        v_attrs(1) := to_char(g_date_end, 'YYYYMMDD');
        v_attrs(2) := v_ops_cnt;
        v_attrs(3) := g_leg_pos;
        v_attrs(4) := v_agent_work_m;
        v_attrs(5) := v_sgp_plan;
        v_dav := nvl(pkg_tariff_calc.calc_coeff_val('DAV_NEW', v_attrs, 5), 0);
      END IF;
    END IF;
  
    BEGIN
      SELECT SUM(apd.summ)
        INTO v_payed_dav
        FROM ag_roll              ar
            ,ag_perfomed_work_act apw
            ,ag_perfom_work_det   apd
       WHERE ar.ag_roll_header_id = g_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_contract_header_id = p_ag_contract_header_id
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_rate_type_id = v_prem_type;
    EXCEPTION
      WHEN no_data_found THEN
        v_payed_dav := 0;
    END;
  
    --IF v_dav - v_payed_dav < 0 THEN v_dav:=0; ELSE
    v_dav := v_dav - v_payed_dav;
    --END IF;
  
    g_sgp2 := v_sgp_plan;
    g_sgp1 := v_sgp_sum;
  
    UPDATE ag_perfom_work_det apd
       SET summ                = v_dav
          ,mounth_num          = v_agent_work_m
          ,count_recruit_agent = v_ops_cnt
     WHERE apd.ag_perfom_work_det_id = v_apw_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_dav_agent_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.04.2009 19:08:50
  -- Purpose : Расчет ДАВ пол полису для групповых договоров
  FUNCTION av_dav_agent_gr_policy_calc
  (
    par_policy_header_id NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER IS
    proc_name        VARCHAR2(30) := 'av_dav_agent_gr_policy_calc';
    v_sgp_summ       NUMBER;
    v_return_sum     NUMBER := 0;
    v_trans_id       PLS_INTEGER;
    v_cur_count      PLS_INTEGER := 0;
    v_pay_doc_count  PLS_INTEGER := 0;
    v_apw_pay_doc_id PLS_INTEGER;
  BEGIN
    FOR pay_doc IN (SELECT /*+ ORDERED*/
                     pp.policy_id
                    ,doc.get_doc_status_id(pp.policy_id) policy_status
                    ,epg.payment_id epg
                    ,doc.get_doc_status_id(epg.payment_id) epg_status
                    ,pay_d.payment_id pay_doc
                    ,pay_d.reg_date pay_d_date
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        dso.doc_set_off_id
                       ELSE
                        bank_doc.doc_set_off_id
                     END set_off_doc
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        pay_d.payment_id
                       ELSE
                        bank_doc.child_doc_id
                     END bank_doc
                      FROM p_pol_header ph
                          ,p_policy pp
                          ,doc_doc dd
                          ,ven_ac_payment epg
                          ,doc_templ dt1
                          ,doc_set_off dso
                          ,ven_ac_payment pay_d
                          ,doc_templ dt
                          ,(SELECT dso2.child_doc_id
                                  ,dd2.parent_id
                                  ,dso2.doc_set_off_id
                              FROM doc_doc     dd2
                                  ,doc_set_off dso2
                             WHERE dso2.parent_doc_id = dd2.child_id) bank_doc
                     WHERE dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt1.doc_templ_id = epg.doc_templ_id
                       AND dt1.brief = 'PAYMENT' -- ЭПГ имеет тип "Счет на оплату взносов"
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_d.payment_id
                       AND pay_d.doc_templ_id = dt.doc_templ_id
                       AND dt.brief IN ('ПП', 'A7', 'PD4')
                       AND epg.plan_date < g_date_end
                       AND pay_d.due_date BETWEEN g_date_begin AND g_date_end --изменения в ТЗ (согласовано с Иконописцевым)
                       AND pay_d.reg_date > '31.07.2007' -- Платежный документ создали после Внедрения
                       AND epg.reg_date > ADD_MONTHS(g_date_end, -15) --Ограничим немного выборку 
                       AND epg.plan_date BETWEEN ph.start_date AND ADD_MONTHS(ph.start_date, 12) - 1
                       AND dso.set_off_date <= g_date_end
                       AND pay_d.payment_id = bank_doc.parent_id(+)
                       AND ph.policy_header_id = par_policy_header_id
                       AND pp.pol_header_id = ph.policy_header_id)
    LOOP
      v_pay_doc_count := 0;
      FOR tran IN (SELECT t.trans_id
                         ,tplo.id prod_line_option
                         ,t.trans_amount
                     FROM oper               o
                         ,trans              t
                         ,trans_templ        tt
                         ,p_cover            pc
                         ,t_prod_line_option tplo
                    WHERE o.oper_id = t.oper_id
                      AND t.trans_templ_id = tt.trans_templ_id
                      AND tt.brief IN ('СтраховаяПремияОплачена'
                                      ,'СтраховаяПремияАвансОпл'
                                      ,'ПремияОплаченаПоср'
                                      ,'ЗачВзнСтрАг')
                      AND t.obj_uro_id = pc.p_cover_id
                      AND pc.t_prod_line_option_id = tplo.id
                      AND o.document_id = pay_doc.set_off_doc
                      AND tplo.description <> 'Административные издержки'
                      AND NOT EXISTS
                    (SELECT 1
                             FROM ag_roll              ar
                                 ,ag_roll_header       arh
                                 ,ag_perfomed_work_act apw
                                 ,ag_perfom_work_det   apdet
                                 ,ag_perfom_work_dpol  apdpol
                                 ,ag_perf_work_pay_doc apd
                                 ,ag_perf_work_trans   apwt
                            WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                              AND arh.ag_roll_type_id = g_roll_type
                              AND arh.ag_roll_header_id <> g_roll_header_id
                              AND apw.ag_roll_id = ar.ag_roll_id
                              AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                              AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                              AND apdpol.ag_perfom_work_dpol_id = apd.ag_preformed_work_dpol_id
                              AND apd.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
                              AND apwt.trans_id = t.trans_id))
      LOOP
        IF v_cur_count = 0
        THEN
          INSERT INTO ven_ag_perfom_work_dpol
            (ag_perfom_work_dpol_id
            ,ag_contract_header_ch_id
            ,ag_perfom_work_det_id
            ,policy_id
            ,policy_status_id
            ,ag_leg_pos
            ,ag_status_id
            ,insurance_period
            ,pay_term
            ,is_transfered
            ,policy_agent_part
            ,summ
            ,check_1
            ,check_2
            ,check_3)
          VALUES
            (g_ag_work_dpol.ag_perfom_work_dpol_id
            ,g_ag_work_dpol.ag_contract_header_ch_id
            ,g_ag_work_dpol.ag_perfom_work_det_id
            ,g_ag_work_dpol.policy_id
            ,g_ag_work_dpol.policy_status_id
            ,g_ag_work_dpol.ag_leg_pos
            ,g_ag_work_dpol.ag_status_id
            ,g_ag_work_dpol.insurance_period
            ,g_ag_work_dpol.pay_term
            ,g_ag_work_dpol.is_transfered
            ,g_ag_work_dpol.policy_agent_part
            ,g_ag_work_dpol.summ
            ,g_ag_work_dpol.check_1
            ,g_ag_work_dpol.check_2
            ,g_ag_work_dpol.check_3);
          v_cur_count := v_cur_count + 1;
        END IF;
      
        IF v_pay_doc_count = 0
        THEN
          SELECT sq_ag_perf_work_pay_doc.nextval INTO v_apw_pay_doc_id FROM dual;
        
          INSERT INTO ven_ag_perf_work_pay_doc
            (ag_perf_work_pay_doc_id
            ,ag_preformed_work_dpol_id
            ,epg_payment_id
            ,epg_status_id
            ,pay_bank_doc_id
            ,pay_payment_id
            ,policy_id
            ,policy_status_id)
          VALUES
            (v_apw_pay_doc_id
            ,p_performed_act_dpol
            ,pay_doc.epg
            ,pay_doc.epg_status
            ,pay_doc.bank_doc
            ,pay_doc.pay_doc
            ,pay_doc.policy_id
            ,pay_doc.policy_status);
          v_pay_doc_count := 1;
        END IF;
      
        --Доп проверки в соответствии с ТЗ.
        IF g_ag_work_dpol.check_1 = 0
           OR --Check_1
           g_ag_work_dpol.check_2 = 0
           OR --Check_2
           g_ag_work_dpol.check_3 = 0
           OR --Check_3
           pay_doc.epg_status <> g_st_paid --Check_4         
        THEN
          v_sgp_summ := 0;
          v_trans_id := NULL;
        ELSE
          v_sgp_summ := tran.trans_amount;
          v_trans_id := tran.trans_id;
        END IF;
      
        INSERT INTO ven_ag_perf_work_trans
          (ag_perf_work_pay_doc_id
          ,is_indexing
          ,sav
          ,sum_commission
          ,sum_premium
          ,t_prod_line_option_id
          ,trans_id)
        VALUES
          (v_apw_pay_doc_id
          ,0
          , --tran.indexing, 
           0
          ,v_sgp_summ
          ,tran.trans_amount
          ,tran.prod_line_option
          ,v_trans_id);
      
        v_return_sum := v_return_sum + v_sgp_summ;
      END LOOP;
    END LOOP;
  
    UPDATE ag_perfom_work_dpol d
       SET d.summ = v_return_sum
     WHERE d.ag_perfom_work_dpol_id = g_ag_work_dpol.ag_perfom_work_dpol_id;
    RETURN(v_return_sum);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || par_policy_header_id ||
                              SQLERRM || chr(10));
  END av_dav_agent_gr_policy_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.02.2009 16:02:59
  -- Purpose : Расчет ДАВ по полису для агента
  FUNCTION av_dav_agent_policy_calc
  (
    par_pol_header       NUMBER
   ,p_performed_act_dpol PLS_INTEGER
  ) RETURN NUMBER IS
    proc_name    VARCHAR2(25) := 'av_dav_agent_policy_calc';
    ret_sgp_summ NUMBER;
  BEGIN
    ret_sgp_summ := 0;
    FOR pay_doc IN (SELECT (SELECT SUM(pc.fee)
                              FROM as_asset           ass
                                  ,p_cover            pc
                                  ,t_prod_line_option tplo
                             WHERE ass.p_policy_id = pp.policy_id
                               AND ass.as_asset_id = pc.as_asset_id
                               AND pc.t_prod_line_option_id = tplo.id
                               AND tplo.description <> 'Административные издержки') * --Брутто взнос
                           pt.number_of_payments * --Кол-во платежей
                           acc.get_cross_rate_by_id(1
                                                   ,ph.fund_id
                                                   ,122
                                                   ,(SELECT MAX(pay_d1.reg_date)
                                                      FROM doc_set_off    dso
                                                          ,ven_ac_payment pay_d1
                                                          ,doc_templ      pay_temp
                                                     WHERE dso.parent_doc_id = epg.payment_id
                                                       AND dso.child_doc_id = pay_d1.payment_id
                                                       AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                                                       AND pay_temp.brief IN ('A7', 'PD4', 'ПП'))) sgp
                          , --Валюта на дату Плат. док.
                           epg.payment_id epg_id
                          ,doc.get_doc_status_id(epg.payment_id) epg_status
                          ,(SELECT DISTINCT last_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pay_doc_id
                      FROM p_policy        pp
                          ,p_pol_header    ph
                          ,doc_doc         dd
                          ,ven_ac_payment  epg
                          ,doc_templ       epg_dt
                          ,t_payment_terms pt
                     WHERE pp.pol_header_id = par_pol_header
                       AND pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND pp.policy_id = dd.parent_id
                       AND epg.payment_id = dd.child_id
                       AND epg.doc_templ_id = epg_dt.doc_templ_id
                       AND epg_dt.brief = 'PAYMENT'
                       AND epg.payment_number = 1
                          --Аналог pkg_agent_1.get_agent_start_contr
                       AND --GREATEST( --По распоряжению Гусева от 29.05.09
                           (SELECT MAX(pay_d1.due_date)
                              FROM doc_set_off    dso
                                  ,ven_ac_payment pay_d1
                                  ,doc_templ      pay_temp
                             WHERE dso.parent_doc_id = epg.payment_id
                               AND dso.child_doc_id = pay_d1.payment_id
                               AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                               AND pay_temp.brief IN ('A7', 'PD4', 'ПП')) --, ph.start_date) 
                           BETWEEN g_date_begin AND g_date_end)
    LOOP
    
      g_ag_work_dpol.summ := pay_doc.sgp; /*g_ag_work_dpol.POLICY_AGENT_PART*/
    
      IF g_ag_work_dpol.check_1 = 0
         OR --Check_1
         g_ag_work_dpol.check_2 = 0
         OR --Check_2
         g_ag_work_dpol.check_3 = 0
         OR --Chrck_3
         pay_doc.epg_status <> g_st_paid --Check_4
      THEN
        ret_sgp_summ := 0;
      ELSE
        ret_sgp_summ := nvl(g_ag_work_dpol.summ, 0);
      END IF;
    
      INSERT INTO ven_ag_perfom_work_dpol
        (ag_perfom_work_dpol_id
        ,ag_contract_header_ch_id
        ,ag_perfom_work_det_id
        ,policy_id
        ,policy_status_id
        ,ag_leg_pos
        ,ag_status_id
        ,insurance_period
        ,pay_term
        ,is_transfered
        ,policy_agent_part
        ,summ
        ,check_1
        ,check_2
        ,check_3)
      VALUES
        (g_ag_work_dpol.ag_perfom_work_dpol_id
        ,g_ag_work_dpol.ag_contract_header_ch_id
        ,g_ag_work_dpol.ag_perfom_work_det_id
        ,g_ag_work_dpol.policy_id
        ,g_ag_work_dpol.policy_status_id
        ,g_ag_work_dpol.ag_leg_pos
        ,g_ag_work_dpol.ag_status_id
        ,g_ag_work_dpol.insurance_period
        ,g_ag_work_dpol.pay_term
        ,g_ag_work_dpol.is_transfered
        ,g_ag_work_dpol.policy_agent_part
        ,ret_sgp_summ
        ,g_ag_work_dpol.check_1
        ,g_ag_work_dpol.check_2
        ,g_ag_work_dpol.check_3);
    
      INSERT INTO ven_ag_perf_work_pay_doc
        (ag_preformed_work_dpol_id, epg_payment_id, epg_status_id, pay_payment_id)
      VALUES
        (p_performed_act_dpol, pay_doc.epg_id, pay_doc.epg_status, pay_doc.pay_doc_id);
    
    END LOOP;
    RETURN(ret_sgp_summ);
  EXCEPTION
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Ошибка ' || proc_name || 'существует более 1ого ЭПГ с номером 1' ||
                              chr(10));
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_dav_agent_policy_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.01.2009 19:55:09
  -- Purpose : Расчет ОАВ всего
  -- Действовал с 01/04/09 по 01/06/09
  PROCEDURE av_oav_all_calc(p_ag_contract_header_id NUMBER DEFAULT NULL) IS
    proc_name VARCHAR2(20) := 'av_oav_all_calc';
    v_apw_id  NUMBER;
  BEGIN
  
    --   v_calc_count:= 0;
    --1) Почистим ведомость на пердмет актов
    --Перенс это в отдельных переход (Расчитан -> Доработка) так что здесь должно чиститься быстро
    --но на всякий случай лучше отсюда не убирать
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
  
    pkg_agent_calculator.insertinfo('Начат расчет актов');
    --2) Отбор АД
    FOR agents IN (SELECT COUNT(*) over(PARTITION BY 1) cur_count
                         ,ach.ag_contract_header_id
                         ,ash.ag_stat_hist_id
                         ,ash.ag_stat_agent_id
                         ,ac.is_comm_holding
                         ,ac.category_id
                         ,ach.date_begin
                     FROM ag_contract_header ach
                         ,ag_contract        ac
                         ,ag_stat_hist       ash
                         ,t_sales_channel    ts
                    WHERE pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end) =
                          ac.ag_contract_id
                      AND ach.ag_contract_header_id =
                          nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                      AND ash.ag_contract_header_id = ach.ag_contract_header_id
                      AND ach.ag_contract_header_id <> g_ag_fake_agent
                      AND ash.num = (SELECT MAX(num)
                                       FROM ag_stat_hist ash1
                                      WHERE ash1.ag_contract_header_id = ach.ag_contract_header_id
                                        AND ash1.stat_date <= g_date_end)
                      AND ach.t_sales_channel_id = ts.id
                      AND doc.get_doc_status_id(ach.ag_contract_header_id) IN (g_st_curr, g_st_resume) --изменения в ТЗ Ким Т.
                      AND ((g_roll_type = 40 AND
                           ent.obj_name('DEPARTMENT', ach.agency_id) <> 'Внешние агенты и агентства' AND
                           ts.brief = 'MLM') OR
                           ts.brief =
                           decode(g_roll_type, 44, 'BANK', 45, 'BR', 46, 'CORPORATE', '!NONE!')))
    LOOP
    
      g_category_id   := agents.category_id;
      g_ag_start_date := agents.date_begin;
    
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     agents.ag_contract_header_id
                                    ,g_roll_id
                                    ,agents.cur_count);
      --Вставляем запись в акты
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id
        ,is_deduct)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,agents.ag_contract_header_id
        ,SYSDATE
        ,agents.ag_stat_hist_id
        ,agents.ag_stat_agent_id
        ,agents.is_comm_holding);
    
      g_sgp1 := 0;
      av_oav_agent_calc(agents.ag_contract_header_id, v_apw_id);
    
      UPDATE ag_perfomed_work_act apw
         SET apw.sum =
             (SELECT SUM(summ)
                FROM ag_perfom_work_det apd
               WHERE apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id)
            ,apw.sgp1 = g_sgp1
       WHERE apw.ag_perfomed_work_act_id = v_apw_id;
    
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_oav_all_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.01.2009 20:36:22
  -- Purpose : Расчет ОАВ по АД
  PROCEDURE av_oav_agent_calc
  (
    p_ag_contract_header_id NUMBER
   ,p_ag_perfomed_act       NUMBER
  ) IS
    proc_name    VARCHAR2(30) := 'av_oav_agent_calc';
    v_prem_type  NUMBER;
    v_apw_det_id NUMBER;
    v_apw_pol_id NUMBER;
  BEGIN
  
    --Вставляем запись в детали по акту
    SELECT art.ag_rate_type_id INTO v_prem_type FROM ven_ag_rate_type art WHERE art.brief = 'OAV';
  
    SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
  
    INSERT INTO ven_ag_perfom_work_det d
      (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
    VALUES
      (v_apw_det_id, p_ag_perfomed_act, v_prem_type, 0);
  
    --Отбор ДС по которым действует АД
    FOR agent_pol IN (SELECT pa.p_policy_agent_id
                            ,pa.ag_contract_header_id
                            ,pa.policy_header_id
                            ,ph.policy_id
                            ,doc.get_doc_status_id(ph.policy_id) policy_status_id
                            , --check2
                             pa.part_agent
                            ,CASE
                               WHEN ac.leg_pos = 0 THEN
                                (SELECT id
                                   FROM t_contact_type
                                  WHERE is_legal_entity = 0
                                    AND is_leaf = 1
                                    AND brief = 'ФЛ')
                               WHEN ac.leg_pos = 1 THEN
                                (SELECT id
                                   FROM t_contact_type
                                  WHERE is_legal_entity = 0
                                    AND is_leaf = 1
                                    AND brief = 'ПБОЮЛ')
                               ELSE
                                (SELECT id
                                   FROM t_contact_type
                                  WHERE is_legal_entity = 0
                                    AND is_leaf = 1
                                    AND brief = 'ФЛ')
                             END ag_leg_pos
                            ,pkg_renlife_utils.is_p_agent_transfered(pa.ag_contract_header_id
                                                                    ,pa.policy_header_id) transfered
                            ,pa.date_start pa_date_start
                            ,decode(pt.is_periodical, 0, 1, 0) nonperiodical
                            ,CASE
                               WHEN pkg_renlife_utils.is_p_agent_transfered(pa.ag_contract_header_id
                                                                           ,pa.policy_header_id) = 1 THEN
                                CASE
                                  WHEN pkg_renlife_utils.get_ag_stat_id(p_ag_contract_header_id
                                                                       ,pa.date_start
                                                                       ,3) > 125 THEN
                                   123
                                  ELSE
                                   pkg_renlife_utils.get_ag_stat_id(p_ag_contract_header_id
                                                                   ,pa.date_start
                                                                   ,3)
                                END
                               ELSE
                                CASE
                                  WHEN pkg_renlife_utils.get_ag_stat_id(p_ag_contract_header_id
                                                                       ,trunc(pkg_agent_1.get_agent_start_contr(ph.policy_header_id
                                                                                                               ,3)
                                                                             ,'DD')
                                                                       ,3) > 125 THEN
                                   123
                                  ELSE
                                   pkg_renlife_utils.get_ag_stat_id(p_ag_contract_header_id
                                                                   ,trunc(pkg_agent_1.get_agent_start_contr(ph.policy_header_id
                                                                                                           ,3)
                                                                         ,'DD')
                                                                   ,3)
                                END
                             END ag_status_id
                            ,CEIL(MONTHS_BETWEEN(pp.end_date
                                                ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id
                                                                                  ,3)) / 12) insurance_period
                            ,
                             --Проверки
                             (SELECT CASE
                                       WHEN COUNT(*) > 0 THEN
                                        1
                                       ELSE
                                        0
                                     END
                                FROM p_policy pp1
                               WHERE pp1.pol_header_id = pp.pol_header_id
                                 AND doc.get_doc_status_id(pp1.policy_id) --На дату расчета - требование Иконописцева см. ТЗ
                                     IN (g_st_act, g_st_curr, g_st_print, g_st_stoped)) check1
                            ,CASE
                               WHEN doc.get_doc_status_id(ph.policy_id) IN
                                    (g_st_berak, g_st_revision, g_st_agrevision, g_st_underwr) THEN
                                0
                               ELSE
                                1
                             END check2
                            ,decode(doc.get_doc_status_id(pkg_policy.get_last_version(pp.pol_header_id))
                                   ,g_st_readycancel
                                   ,0
                                   ,1) check3
                        FROM p_policy_agent pa
                            ,
                             --Есть подозрение с p_policy_agent работает быстрее чем только через get_p_ag_status_by_date
                             p_pol_header    ph
                            ,ag_contract     ac
                            ,p_policy        pp
                            ,t_payment_terms pt
                       WHERE pa.ag_contract_header_id = p_ag_contract_header_id
                         AND ph.policy_header_id = pa.policy_header_id
                            --версию АД по ДС определяем на "Дату  А7" или на дату передачи, для переданных договоров.
                         AND nvl(pkg_agent_1.get_status_by_date(pa.ag_contract_header_id
                                                               ,decode(pkg_renlife_utils.is_p_agent_transfered(pa.policy_header_id
                                                                                                              ,pa.ag_contract_header_id)
                                                                      ,1
                                                                      ,pa.date_start
                                                                      ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id
                                                                                                        ,3)))
                                ,pkg_agent_1.get_status_by_date(pa.ag_contract_header_id
                                                               ,decode(pkg_renlife_utils.is_p_agent_transfered(pa.policy_header_id
                                                                                                              ,pa.ag_contract_header_id)
                                                                      ,1
                                                                      ,pa.date_start
                                                                      ,g_ag_start_date))) =
                             ac.ag_contract_id
                         AND ph.policy_id = pp.policy_id
                         AND pp.payment_term_id = pt.id
                         AND pkg_renlife_utils.get_p_ag_status_by_date(p_ag_contract_header_id
                                                                      ,ph.policy_header_id
                                                                      ,g_date_end) = 'CURRENT'
                         AND pa.date_start <= g_date_end
                         AND pa.date_end > g_date_end
                         AND pa.status_id <> 4
                      --       AND pas.brief = 'CURRENT'
                      )
    LOOP
    
      --Вставляем запись в детали полиса
      SELECT sq_ag_perfom_work_dpol.nextval INTO v_apw_pol_id FROM dual;
    
      g_ag_work_dpol.ag_perfom_work_dpol_id   := v_apw_pol_id;
      g_ag_work_dpol.ag_contract_header_ch_id := agent_pol.ag_contract_header_id;
      g_ag_work_dpol.ag_perfom_work_det_id    := v_apw_det_id;
      g_ag_work_dpol.policy_id                := agent_pol.policy_id;
      g_ag_work_dpol.policy_status_id         := agent_pol.policy_status_id;
      g_ag_work_dpol.ag_leg_pos               := agent_pol.ag_leg_pos;
      g_ag_work_dpol.ag_status_id             := agent_pol.ag_status_id;
      g_ag_work_dpol.insurance_period := CASE
                                           WHEN abs(agent_pol.insurance_period) > 99 THEN
                                            -1
                                           ELSE
                                            agent_pol.insurance_period
                                         END;
      g_ag_work_dpol.pay_term                 := agent_pol.nonperiodical;
      g_ag_work_dpol.is_transfered            := agent_pol.transfered;
      g_ag_work_dpol.policy_agent_date        := agent_pol.pa_date_start;
      g_ag_work_dpol.policy_agent_part        := agent_pol.part_agent;
      g_ag_work_dpol.summ                     := 0;
      g_ag_work_dpol.check_1                  := agent_pol.check1;
      g_ag_work_dpol.check_2                  := agent_pol.check2;
      g_ag_work_dpol.check_3                  := agent_pol.check3;
    
      IF ag_oav_agent_policy_calc(agent_pol.policy_header_id, v_apw_pol_id) = 1
      THEN
      
        UPDATE ag_perfom_work_dpol d
           SET d.summ = g_ag_work_dpol.summ
         WHERE d.ag_perfom_work_dpol_id = g_ag_work_dpol.ag_perfom_work_dpol_id;
      END IF;
    
    END LOOP;
  
    --Проапдейтим суммы
    UPDATE ag_perfom_work_det apd
       SET summ =
           (SELECT SUM(apd.summ)
              FROM ag_perfom_work_dpol apd
             WHERE apd.ag_perfom_work_det_id = v_apw_det_id)
     WHERE apd.ag_perfom_work_det_id = v_apw_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END av_oav_agent_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.01.2009 20:53:59
  -- Purpose : Расчет ОАВ по одному ДС
  FUNCTION ag_oav_agent_policy_calc
  (
    par_policy_header_id NUMBER
   ,p_performed_act_dpol NUMBER
  ) RETURN NUMBER IS
    proc_name         VARCHAR2(30) := 'ag_oav_agent_policy_calc';
    v_apw_pay_doc_id  PLS_INTEGER;
    RESULT            NUMBER := 0;
    v_product_id      PLS_INTEGER;
    v_func_num        PLS_INTEGER;
    v_sav             NUMBER;
    v_oav             NUMBER;
    v_trans_amt       NUMBER;
    v_ins_period      PLS_INTEGER;
    v_ins_year        PLS_INTEGER;
    v_ag_status_id    PLS_INTEGER;
    v_ag_categ_id     PLS_INTEGER;
    v_leg_pos_id      PLS_INTEGER;
    v_indexing        PLS_INTEGER;
    v_product_line_id PLS_INTEGER;
    v_cur_count       PLS_INTEGER := 0;
    v_pay_doc_count   PLS_INTEGER := 0;
    v_trans_id        PLS_INTEGER;
    v_attrs           pkg_tariff_calc.attr_type;
  BEGIN
    FOR pay_doc IN (SELECT /*+ ORDERED*/
                     pp.policy_id
                    ,pp.start_date policy_start
                    ,doc.get_doc_status_id(pp.policy_id) policy_status
                    ,epg.payment_id epg
                    ,doc.get_doc_status_id(epg.payment_id) epg_status
                    ,pay_doc.document_id pay_doc
                    ,pay_doc.reg_date pay_doc_date
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        dso.doc_set_off_id
                       ELSE
                        bank_doc.doc_set_off_id
                     END set_off_doc
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        dso.parent_doc_id
                       ELSE
                        bank_doc.parent_doc_id
                     END parent_set_off
                    ,CASE
                       WHEN dt.brief = 'ПП' THEN
                        pay_doc.document_id
                       ELSE
                        bank_doc.child_doc_id
                     END bank_doc
                    ,CEIL(MONTHS_BETWEEN(epg.plan_date + 1, ph.start_date) / 12) year_of_insurance
                    ,CASE
                       WHEN (SELECT COUNT(*)
                               FROM t_addendum_type     ta
                                   ,p_pol_addendum_type ppa
                              WHERE ppa.p_policy_id = pp.policy_id
                                AND MONTHS_BETWEEN(epg.due_date + 1, pp.start_date) <= 12
                                AND ta.t_addendum_type_id = ppa.t_addendum_type_id
                                AND ta.brief = 'INDEXING2') > 0 THEN
                        1
                       ELSE
                        0
                     END indexing
                    ,pp.payment_term_id pay_term
                      FROM p_pol_header ph
                          ,p_policy pp
                          ,doc_doc dd
                          ,ven_ac_payment epg
                          ,doc_templ dt1
                          ,doc_set_off dso
                          ,document pay_doc
                          ,doc_templ dt
                          ,(SELECT dso2.child_doc_id
                                  ,dd2.parent_id
                                  ,dso2.doc_set_off_id
                                  ,dso2.parent_doc_id
                              FROM doc_doc     dd2
                                  ,doc_set_off dso2
                             WHERE dso2.parent_doc_id = dd2.child_id) bank_doc
                     WHERE dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt1.doc_templ_id = epg.doc_templ_id
                       AND dt1.brief = 'PAYMENT' -- ЭПГ имеет тип "Счет на оплату взносов"
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_doc.document_id
                       AND pay_doc.doc_templ_id = dt.doc_templ_id
                       AND dt.brief IN ('ПП', 'A7', 'PD4')
                       AND epg.plan_date <= g_date_end --В расчет не попадают будущие план графики изменения ТЗ Ким Т.
                       AND pay_doc.reg_date > '31.07.2007' -- Платежный документ создали после Внедрения
                          --AND Doc.get_doc_status_brief(epg.payment_id) = 'PAID' Чтобы было видно какие ЭПГ с оплатами не попали
                       AND epg.reg_date > ADD_MONTHS(g_date_end, -15) --Ограничим немного выборку 
                       AND dso.set_off_date <= g_date_end
                       AND pay_doc.document_id = bank_doc.parent_id(+)
                       AND ph.policy_header_id = par_policy_header_id
                       AND pp.pol_header_id = ph.policy_header_id)
    LOOP
    
      v_pay_doc_count := 0;
    
      FOR tran IN (SELECT t.trans_id
                         ,tplo.id prod_line_option
                         ,t.trans_amount
                     FROM oper               o
                         ,trans              t
                         ,trans_templ        tt
                         ,p_cover            pc
                         ,t_prod_line_option tplo
                    WHERE o.oper_id = t.oper_id
                      AND t.trans_templ_id = tt.trans_templ_id
                      AND tt.brief IN ('СтраховаяПремияОплачена'
                                      ,'СтраховаяПремияАвансОпл'
                                      ,'ПремияОплаченаПоср'
                                      ,'ЗачВзнСтрАг')
                      AND t.obj_uro_id = pc.p_cover_id
                      AND pc.t_prod_line_option_id = tplo.id
                      AND o.document_id = pay_doc.set_off_doc
                      AND tplo.description <> 'Административные издержки'
                      AND NOT EXISTS (SELECT 1 --Нет расчета по этой проводке по старой мотивации 
                           --т.к. смотрели на другой зачет приходится извращатся
                             FROM agent_report_cont arc
                                 ,trans             t2
                                 ,oper              o2
                                 ,doc_set_off       dso2
                                 ,doc_doc           dd2
                            WHERE arc.trans_id = t2.trans_id
                              AND t2.oper_id = o2.oper_id
                              AND o2.document_id = dso2.doc_set_off_id
                              AND dso2.child_doc_id = dd2.parent_id
                              AND dd2.child_id = pay_doc.parent_set_off
                              AND sign(t2.trans_amount) = sign(t.trans_amount))
                      AND NOT EXISTS (SELECT 1 --Нет расчета по этой проводке по старой мотивации
                             FROM agent_report_cont arc
                            WHERE arc.trans_id = t.trans_id)
                      AND NOT EXISTS
                    (SELECT 1 --Нет расчета по этой проводке по новой мотивации
                             FROM ag_roll              ar
                                 ,ven_ag_roll_header   arh
                                 ,ag_perfomed_work_act apw
                                 ,ag_perfom_work_det   apdet
                                 ,ag_perfom_work_dpol  apdpol
                                 ,ag_perf_work_pay_doc apd
                                 ,ag_perf_work_trans   apwt
                            WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
                              AND arh.ag_roll_type_id = g_roll_type
                              AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                              AND arh.ag_roll_header_id <> g_roll_header_id
                              AND apw.ag_roll_id = ar.ag_roll_id
                              AND apw.ag_perfomed_work_act_id = apdet.ag_perfomed_work_act_id
                              AND apdet.ag_perfom_work_det_id = apdpol.ag_perfom_work_det_id
                              AND apdpol.ag_perfom_work_dpol_id = apd.ag_preformed_work_dpol_id
                              AND apd.ag_perf_work_pay_doc_id = apwt.ag_perf_work_pay_doc_id
                              AND apwt.trans_id = t.trans_id))
      LOOP
      
        SELECT tpv.product_id
              ,tplo.product_line_id
          INTO v_product_id
              ,v_product_line_id
          FROM t_prod_line_option tplo
              ,t_product_line     tpl
              ,t_product_ver_lob  tpvl
              ,t_product_version  tpv
         WHERE tplo.id = tran.prod_line_option
           AND tplo.product_line_id = tpl.id
           AND tpl.product_ver_lob_id = tpvl.t_product_ver_lob_id
           AND tpvl.product_version_id = tpv.t_product_version_id;
      
        IF v_cur_count = 0
        THEN
          INSERT INTO ven_ag_perfom_work_dpol
            (ag_perfom_work_dpol_id
            ,ag_contract_header_ch_id
            ,ag_perfom_work_det_id
            ,policy_id
            ,policy_status_id
            ,ag_leg_pos
            ,ag_status_id
            ,insurance_period
            ,pay_term
            ,is_transfered
            ,policy_agent_part
            ,summ
            ,check_1
            ,check_2
            ,check_3)
          VALUES
            (g_ag_work_dpol.ag_perfom_work_dpol_id
            ,g_ag_work_dpol.ag_contract_header_ch_id
            ,g_ag_work_dpol.ag_perfom_work_det_id
            ,g_ag_work_dpol.policy_id
            ,g_ag_work_dpol.policy_status_id
            ,g_ag_work_dpol.ag_leg_pos
            ,g_ag_work_dpol.ag_status_id
            ,g_ag_work_dpol.insurance_period
            ,g_ag_work_dpol.pay_term
            ,g_ag_work_dpol.is_transfered
            ,g_ag_work_dpol.policy_agent_part
            ,g_ag_work_dpol.summ
            ,g_ag_work_dpol.check_1
            ,g_ag_work_dpol.check_2
            ,g_ag_work_dpol.check_3);
          v_cur_count := v_cur_count + 1;
        END IF;
      
        IF v_pay_doc_count = 0
        THEN
          SELECT sq_ag_perf_work_pay_doc.nextval INTO v_apw_pay_doc_id FROM dual;
        
          INSERT INTO ven_ag_perf_work_pay_doc
            (ag_perf_work_pay_doc_id
            ,ag_preformed_work_dpol_id
            ,epg_payment_id
            ,epg_status_id
            ,pay_bank_doc_id
            ,pay_payment_id
            ,policy_id
            ,policy_status_id
            ,year_of_insurance)
          VALUES
            (v_apw_pay_doc_id
            ,p_performed_act_dpol
            ,pay_doc.epg
            ,pay_doc.epg_status
            ,pay_doc.bank_doc
            ,pay_doc.pay_doc
            ,pay_doc.policy_id
            ,pay_doc.policy_status
            ,pay_doc.year_of_insurance);
        
          v_pay_doc_count := 1;
        END IF;
      
        v_indexing := pay_doc.indexing;
      
        <<calc>>
        IF v_indexing = 1
        THEN
          v_trans_amt    := tran.trans_amount *
                            pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tran.prod_line_option, 3);
          v_ins_period   := g_ag_work_dpol.insurance_period - pay_doc.year_of_insurance;
          v_ins_year     := 1;
          v_ag_status_id := pkg_renlife_utils.get_ag_stat_id(g_ag_work_dpol.ag_contract_header_ch_id
                                                            ,pay_doc.policy_start
                                                            ,3);
          SELECT ac.category_id
            INTO v_ag_categ_id
            FROM ag_contract ac
           WHERE ac.ag_contract_id =
                 pkg_agent_1.get_status_by_date(g_ag_work_dpol.ag_contract_header_ch_id
                                               ,pay_doc.policy_start);
        
          SELECT CASE
                   WHEN ac.leg_pos = 0 THEN
                    (SELECT id
                       FROM t_contact_type
                      WHERE is_legal_entity = 0
                        AND is_leaf = 1
                        AND brief = 'ФЛ')
                   WHEN ac.leg_pos = 1 THEN
                    (SELECT id
                       FROM t_contact_type
                      WHERE is_legal_entity = 0
                        AND is_leaf = 1
                        AND brief = 'ПБОЮЛ')
                   ELSE
                    (SELECT id
                       FROM t_contact_type
                      WHERE is_legal_entity = 0
                        AND is_leaf = 1
                        AND brief = 'ФЛ')
                 END ag_leg_pos
            INTO v_leg_pos_id
            FROM ag_contract ac
           WHERE ac.ag_contract_id =
                 pkg_agent_1.get_status_by_date(g_ag_work_dpol.ag_contract_header_ch_id
                                               ,pay_doc.policy_start);
        
          v_indexing := -1; --Признак того что расчитывается сумма индексации
        ELSE
          IF v_indexing = -1
          THEN
            --Чтобы лишний раз подсичтывать суммы
            v_trans_amt := tran.trans_amount *
                           (1 -
                           pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tran.prod_line_option, 3));
          ELSE
            v_trans_amt := tran.trans_amount;
          END IF;
          v_ins_period   := g_ag_work_dpol.insurance_period;
          v_ins_year     := pay_doc.year_of_insurance;
          v_ag_status_id := g_ag_work_dpol.ag_status_id;
          v_ag_categ_id  := g_category_id;
          v_leg_pos_id   := g_ag_work_dpol.ag_leg_pos;
          v_indexing     := 0;
        END IF;
      
        v_attrs(1) := v_product_id;
        v_attrs(2) := v_product_line_id;
      
        v_func_num := pkg_tariff_calc.calc_coeff_val('GP_PROG', v_attrs, 2);
      
        v_attrs.delete; --Почистим на всякий случай;
      
        CASE
          WHEN v_func_num < 6 THEN
            v_attrs(1) := v_ag_status_id; --Статус Агента
            v_attrs(2) := v_leg_pos_id; --Юр статус
            v_attrs(3) := v_ins_period; --Период страхования
            v_attrs(4) := v_ins_year; --Год действия
            v_attrs(5) := g_ag_work_dpol.pay_term; --единовременная
            v_attrs(6) := g_ag_work_dpol.is_transfered; --переданный ДС
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 6), 0);
          WHEN v_func_num < 12 THEN
            v_attrs(1) := v_ag_status_id; --Статус Агента
            v_attrs(2) := v_leg_pos_id; --Юр статус
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          WHEN v_func_num = 12 THEN
            v_attrs(1) := v_leg_pos_id; --Юр статус
            v_attrs(2) := pay_doc.pay_term; --Условие рассрочки платежа
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          WHEN v_func_num = 13 THEN
            v_attrs(1) := v_leg_pos_id; --Юр статус
            v_attrs(2) := v_ag_categ_id; --Категория агента
            v_sav := nvl(pkg_tariff_calc.calc_coeff_val('GP' || v_func_num, v_attrs, 2), 0);
          ELSE
            v_sav := 0;
        END CASE;
      
        --Доп проверки в соответствии с ТЗ.
        IF g_ag_work_dpol.check_1 = 0
           OR --Check_1
           g_ag_work_dpol.check_2 = 0
           OR --Check_2
           g_ag_work_dpol.check_3 = 0
           OR --Check_3
           pay_doc.epg_status <> g_st_paid
           OR --Check_4         
           v_sav IS NULL
           OR v_sav = 0 --Check_5
        THEN
          v_oav      := 0;
          v_trans_id := NULL;
        ELSE
          IF g_ag_work_dpol.is_transfered = 1
             AND g_ag_work_dpol.policy_agent_date > pay_doc.pay_doc_date --деньги по переданным ДС
          THEN
            v_oav := 0;
          ELSE
            v_oav := (v_sav / 100) * nvl(g_ag_work_dpol.policy_agent_part / 100, 1) * v_trans_amt;
          END IF;
          v_trans_id := tran.trans_id;
        END IF;
      
        INSERT INTO ven_ag_perf_work_trans
          (ag_perf_work_pay_doc_id
          ,is_indexing
          ,sav
          ,sum_commission
          ,sum_premium
          ,t_prod_line_option_id
          ,trans_id)
        VALUES
          (v_apw_pay_doc_id
          ,abs(v_indexing)
          ,v_sav
          ,v_oav
          ,v_trans_amt
          ,tran.prod_line_option
          ,v_trans_id);
      
        g_ag_work_dpol.summ := g_ag_work_dpol.summ + v_oav;
      
        g_sgp1 := g_sgp1 + v_trans_amt;
      
        IF v_indexing = -1
        THEN
          GOTO calc;
        END IF;
      
        RESULT := 1;
      
      END LOOP;
    END LOOP;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка ' || proc_name || SQLERRM || chr(10));
  END ag_oav_agent_policy_calc;

  PROCEDURE load_trast
  (
    par_id           NUMBER
   ,par_load_file_id NUMBER
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
    v_load      t_load_trast%ROWTYPE;
  BEGIN
    SAVEPOINT before_load;
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
            SELECT sq_t_load_trast.nextval INTO v_load.t_load_trast_id FROM dual;
            v_load.load_id := par_load_file_id;
            -- проход по полям
            FOR i IN va_values.first .. va_values.last
            LOOP
              CASE
                WHEN i = 1 THEN
                  NULL; --первый столбец - порядковый номер - не грузим
                WHEN i = 2 THEN
                  v_load.agency_name := va_values(i);
                WHEN i = 3 THEN
                  v_load.ad_name := va_values(i);
                WHEN i = 4 THEN
                  v_load.ad_num := va_values(i);
                WHEN i = 5 THEN
                  v_load.date_sale := to_date(va_values(i), 'DD.MM.YYYY');
                WHEN i = 6 THEN
                  v_load.client_name := va_values(i);
                WHEN i = 7 THEN
                  v_load.num_pol := va_values(i);
                WHEN i = 8 THEN
                  v_load.credit_amount := to_number(translate(va_values(i), ',.', '..')
                                                   ,'9999999999.99');
                ELSE
                  NULL;
              END CASE;
            END LOOP;
            INSERT INTO ins.ven_t_load_trast
              (t_load_trast_id
              ,load_id
              ,agency_name
              ,ad_name
              ,ad_num
              ,date_sale
              ,client_name
              ,num_pol
              ,credit_amount
              ,date_load
              ,note_load)
            VALUES
              (v_load.t_load_trast_id
              ,v_load.load_id
              ,v_load.agency_name
              ,v_load.ad_name
              ,v_load.ad_num
              ,v_load.date_sale
              ,v_load.client_name
              ,v_load.num_pol
              ,v_load.credit_amount
              ,SYSDATE
              ,'Новая запись');
          END IF;
        END IF;
        v_line := NULL;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      raise_application_error(-20001
                             ,'Ошибка при выполнении LOAD_TRAST ' || SQLERRM);
  END load_trast;

  FUNCTION load_to_db_trast
  (
    p_load_id    NUMBER
   ,p_ag_roll_id NUMBER
  ) RETURN NUMBER IS
    p_exists_dep          NUMBER;
    p_exists_ad           NUMBER;
    p_load                NUMBER := 0;
    v_ag_contract_id      NUMBER;
    v_sq_ag_volume_det_id NUMBER;
    v_sq_ag_volume_id     NUMBER;
    v_num_arh             VARCHAR2(10);
    v_num_roll            VARCHAR2(5);
    p_exists_date         NUMBER;
    p_exists_pol          NUMBER;
  BEGIN
  
    FOR cur IN (SELECT tr.t_load_trast_id
                      ,tr.ad_name
                      ,tr.ad_num
                      ,tr.agency_name
                      ,tr.client_name
                      ,tr.credit_amount
                      ,tr.date_load
                      ,tr.date_sale
                      ,tr.note_load
                      ,tr.num_pol
                  FROM ins.ven_t_load_trast tr
                 WHERE tr.load_id = p_load_id
                   AND substr(tr.note_load, 1, 8) <> 'Загружен'
                /*AND NOT EXISTS (SELECT NULL
                FROM ins.ven_ag_trast_volume_det det
                WHERE det.policy_num = tr.num_pol
                )*/
                )
    LOOP
    
      SELECT COUNT(*)
        INTO p_exists_pol
        FROM dual
       WHERE NOT EXISTS
       (SELECT NULL FROM ins.ven_ag_trast_volume_det det WHERE det.policy_num = cur.num_pol);
    
      IF p_exists_pol = 0
      THEN
        UPDATE ins.ven_t_load_trast tr
           SET tr.note_load = 'Не загружен. Такой договор уже есть в системе'
         WHERE tr.t_load_trast_id = cur.t_load_trast_id;
        p_load := p_load + 1;
      END IF;
    
      SELECT COUNT(*)
        INTO p_exists_dep
        FROM dual
       WHERE EXISTS (SELECT NULL FROM department dep WHERE upper(dep.name) = upper(cur.agency_name));
      IF p_exists_dep = 0
      THEN
        UPDATE ins.ven_t_load_trast tr
           SET tr.note_load = 'Не загружен. Не найдено агентство'
         WHERE tr.t_load_trast_id = cur.t_load_trast_id;
        p_load := p_load + 1;
      END IF;
    
      SELECT COUNT(*)
        INTO p_exists_ad
        FROM dual
       WHERE EXISTS (SELECT NULL FROM ven_ag_contract_header agh WHERE agh.num = cur.ad_num);
      IF p_exists_ad = 0
      THEN
        UPDATE ins.ven_t_load_trast tr
           SET tr.note_load = 'Не загружен. Не найден агент'
         WHERE tr.t_load_trast_id = cur.t_load_trast_id;
        p_load := p_load + 1;
      END IF;
    
      SELECT COUNT(*)
        INTO p_exists_date
        FROM dual
       WHERE NOT EXISTS (SELECT NULL
                FROM ins.ven_ag_roll_header arh
                    ,ins.ven_ag_roll        agr
               WHERE arh.ag_roll_header_id = agr.ag_roll_header_id
                 AND agr.ag_roll_id = p_ag_roll_id
                 AND arh.date_end < cur.date_sale);
      IF p_exists_date = 0
      THEN
        UPDATE ins.ven_t_load_trast tr
           SET tr.note_load = 'Будущий период. Дата договора выходит за рамки ведомости'
         WHERE tr.t_load_trast_id = cur.t_load_trast_id;
        p_load := p_load + 1;
      END IF;
    
      IF p_load = 0
      THEN
      
        SELECT sq_ag_volume.nextval INTO v_sq_ag_volume_id FROM dual;
      
        SELECT agh.ag_contract_header_id
          INTO v_ag_contract_id
          FROM ven_ag_contract_header agh
         WHERE agh.num = cur.ad_num;
      
        INSERT INTO ven_ag_volume
          (ag_volume_id
          ,ag_roll_id
          ,ag_volume_type_id
          ,ag_contract_header_id
          ,trans_sum
          ,nbv_coef
          ,is_nbv
          ,date_begin)
        VALUES
          (v_sq_ag_volume_id
          ,p_ag_roll_id
          ,g_vt_bank
          ,v_ag_contract_id
          ,cur.credit_amount
          ,0.05
          ,1
          ,cur.date_sale);
        SELECT sq_ag_trast_volume_det.nextval INTO v_sq_ag_volume_det_id FROM dual;
      
        INSERT INTO ins.ven_ag_trast_volume_det
          (ag_trast_volume_det_id
          ,ag_contract_num
          ,ag_volume_id
          ,fio
          ,notice_date
          ,policy_num
          ,sign_date
          ,trast_type)
        VALUES
          (v_sq_ag_volume_det_id
          ,cur.ad_num
          ,v_sq_ag_volume_id
          ,cur.client_name
          ,cur.date_sale
          ,cur.num_pol
          ,cur.date_sale
          ,'TRAST');
      
        SELECT arh.num
              ,agr.num
          INTO v_num_arh
              ,v_num_roll
          FROM ins.ven_ag_roll_header arh
              ,ins.ven_ag_roll        agr
         WHERE arh.ag_roll_header_id = agr.ag_roll_header_id
           AND agr.ag_roll_id = p_ag_roll_id;
      
        UPDATE ins.ven_t_load_trast tr
           SET tr.note_load = 'Загружен. Ведомость №' || v_num_arh || ' версия №' || v_num_roll
         WHERE tr.t_load_trast_id = cur.t_load_trast_id;
      
      END IF;
    
    END LOOP;
  
    RETURN 0;
  
  END load_to_db_trast;

  /*
    Капля П.
    04.08.2014
    Премия за Листы переговоров
    Если агент за отчетный период имеет 20 и более ЛП (см. п.1) , то:
    КВ для ФЛ =  Объем агента *15%, но не более 1500 руб.
    КВ для ИП = Объем агента*16,6%, но не более 1660 руб.
  */
  PROCEDURE get_conv_sheet_rate(par_ag_perf_work_det_id PLS_INTEGER) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'GET_CONV_SHEET_RATE';
    v_ag_ch_id                ag_perfomed_work_act.ag_contract_header_id%TYPE;
    v_rate_type               ag_perfom_work_det.ag_rate_type_id%TYPE;
    v_activity_meetings_count ag_perfomed_work_act.activity_meetings_count%TYPE;
    v_contact_type_id         t_contact_type.id%TYPE;
    c_fl_limit CONSTANT NUMBER := 1500;
    c_ul_limit CONSTANT NUMBER := 1660;
    v_category_id          NUMBER;
    v_sales_ch_id          NUMBER;
    v_volume               ag_perfomed_work_act.volumes%TYPE;
    v_limit                NUMBER;
    v_full_comission_value NUMBER;
    v_all_volume           NUMBER;
    v_ag_roll_h_id         NUMBER;
    v_prev_com             NUMBER;
    v_level                NUMBER;
  
    v_ag_perf_work_vol dml_ag_perf_work_vol.typ_nested_table;
  
  BEGIN
    pkg_trace.add_variable('par_ag_perf_work_det_id', par_ag_perf_work_det_id);
    pkg_trace.trace_procedure_start(gc_pkg_name, c_proc_name);
  
    SELECT ac.category_id
          ,apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.activity_meetings_count
          ,ac.leg_pos
          ,apw.all_volume
          ,vag.ag_roll_header_id
          ,apw.ag_level
      INTO v_category_id
          ,v_ag_ch_id
          ,v_rate_type
          ,v_sales_ch_id
          ,v_activity_meetings_count
          ,v_contact_type_id
          ,v_all_volume
          ,v_ag_roll_h_id
          ,v_level
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
          ,t_sales_channel      chac
          ,ag_contract_header   ach
          ,v_ag_roll            vag
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = par_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND ac.ag_sales_chn_id = chac.id(+)
       AND ach.ag_contract_header_id = apw.ag_contract_header_id
       AND ach.ag_contract_header_id = ac.contract_id
       AND apw.ag_roll_id = vag.ag_roll_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    pkg_trace.add_variable('v_activity meetings_count', v_activity_meetings_count);
    pkg_trace.add_variable('v_contact_type_id', v_contact_type_id);
    pkg_trace.trace(gc_pkg_name, c_proc_name, 'Определено количество ЛП');
  
    -- Премия начисляется только при наличии более 20 листов переговоров
    IF v_activity_meetings_count >= 20
       AND v_level IN (2, 3, 4)
    THEN
      v_limit                := CASE v_contact_type_id
                                  WHEN g_cn_legentity THEN
                                   c_ul_limit
                                  ELSE
                                   c_fl_limit
                                END;
      v_full_comission_value := v_all_volume * v_limit / 10000;
      g_commision            := g_commision + least(v_full_comission_value, v_limit);
    
      /* 374618 Григорьев Ю.А. Премия за листы переговоров по рассчитываемой версии ведомости
         рассчитывается с учетом вычета премии, выплаченной в предыдущих версиях 
      */
    
      SELECT nvl(SUM(summ), 0)
        INTO v_prev_com
        FROM ag_perfomed_work_act apw
            ,ag_perfom_work_det   apd
            ,v_ag_roll            vag
            ,ag_rate_type         agr
       WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apw.ag_contract_header_id = v_ag_ch_id
         AND vag.ag_roll_header_id = v_ag_roll_h_id
         AND vag.ag_roll_id = apw.ag_roll_id
         AND apd.ag_rate_type_id = agr.ag_rate_type_id
         AND agr.brief = 'CONV_SHEET';
    
      g_commision := greatest(0, g_commision - v_prev_com);
    
      /**/
    
      IF g_commision != 0
      THEN
      
        INSERT INTO ag_perf_work_vol
          (ag_perf_work_vol_id, ag_volume_id, ag_perfom_work_det_id, vol_amount, vol_rate)
          SELECT sq_ag_perf_work_vol.nextval
                ,av.ag_volume_id
                ,par_ag_perf_work_det_id
                ,g_commision
                ,1 / COUNT(*) over() vol_rate
            FROM ins.ag_volume      av
                ,ins.ag_roll        ar
                ,ins.ag_roll_header arh
                ,ins.ag_roll_type   art
           WHERE av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc)
             AND ar.ag_roll_id = av.ag_roll_id
             AND ar.ag_roll_header_id = arh.ag_roll_header_id
             AND nvl(ar.date_end, arh.date_end) <= g_date_end
             AND arh.ag_roll_type_id = art.ag_roll_type_id
             AND art.brief = 'CASH_VOL'
             AND NOT EXISTS
           (SELECT NULL
                    FROM ag_perf_work_vol     apv
                        ,ag_perfom_work_det   apd
                        ,ag_perfomed_work_act apw
                        ,ag_roll              ar
                   WHERE apv.ag_volume_id = av.ag_volume_id
                     AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                     AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                     AND apw.ag_contract_header_id IN (SELECT apd.ag_prev_header_id
                                                         FROM ag_prev_dog apd
                                                        WHERE apd.ag_contract_header_id = v_ag_ch_id
                                                       UNION ALL
                                                       SELECT v_ag_ch_id
                                                         FROM dual)
                     AND apw.ag_roll_id = ar.ag_roll_id
                     AND ar.ag_roll_header_id != g_roll_header_id)
             AND av.ag_contract_header_id IN
                 (SELECT v_ag_ch_id
                    FROM dual
                  UNION
                  SELECT apd.ag_prev_header_id
                    FROM ag_prev_dog apd
                   WHERE apd.ag_contract_header_id = v_ag_ch_id);
      
      END IF;
    
    END IF;
  
    pkg_trace.trace_procedure_end(gc_pkg_name, c_proc_name);
  
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise_custom('Ошибка при выполнении ' || c_proc_name || SQLERRM);
  END get_conv_sheet_rate;

  /*
    Зыонг Р.
    12.05.2015
    Премия за рекрутированного агента
  */
  PROCEDURE get_recruited_agent_prem(par_ag_perf_work_det_id PLS_INTEGER) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'GET_RECRUITED_AGENT_PREM';
    v_ag_ch_id      ag_perfomed_work_act.ag_contract_header_id%TYPE;
    v_rt_date_begin ag_rate_type.date_begin%TYPE;
    v_sale_ch       t_sales_channel.id%TYPE;
    v_sum           NUMBER := 0;
    v_paid_prem     NUMBER := 0;
  BEGIN
    pkg_trace.add_variable('par_ag_perf_work_det_id', par_ag_perf_work_det_id);
    pkg_trace.trace_procedure_start(gc_pkg_name, c_proc_name);
  
    SELECT apw.ag_contract_header_id
          ,art.date_begin
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
      INTO v_ag_ch_id
          ,v_rt_date_begin
          ,v_sale_ch
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
          ,ag_contract_header   ach
          ,ag_rate_type         art
          ,t_sales_channel      chac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apw.ag_contract_header_id = ac.contract_id
       AND apw.ag_contract_header_id = ach.ag_contract_header_id
       AND apd.ag_perfom_work_det_id = par_ag_perf_work_det_id
       AND apd.ag_rate_type_id = art.ag_rate_type_id
       AND ac.ag_sales_chn_id = chac.id(+)
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR detail_vol IN (SELECT *
                         FROM (WITH recruited_agents AS (SELECT ach1.ag_contract_header_id
                                                           FROM ag_contract_header ach1
                                                               ,ag_contract        ac1
                                                          WHERE ach1.ag_contract_header_id =
                                                                ac1.contract_id
                                                            AND ach1.date_begin BETWEEN g_date_begin AND
                                                                g_date_end
                                                            AND g_date_end BETWEEN ac1.date_begin AND
                                                                ac1.date_end
                                                            AND ac1.category_id = g_ct_agent
                                                            AND ac1.date_begin >= v_rt_date_begin
                                                            AND ac1.contract_recrut_id =
                                                                (SELECT ac2.ag_contract_id
                                                                   FROM ag_contract_header ach2
                                                                       ,ag_contract        ac2
                                                                  WHERE ach2.ag_contract_header_id =
                                                                        ac2.contract_id
                                                                    AND ach2.ag_contract_header_id =
                                                                        v_ag_ch_id
                                                                    AND g_date_end BETWEEN ac2.date_begin AND
                                                                        ac2.date_end)
                                                            AND (CASE
                                                                  WHEN doc.get_last_doc_status_brief(ach1.ag_contract_header_id) =
                                                                       'BREAK'
                                                                       AND EXISTS
                                                                   (SELECT NULL
                                                                          FROM ag_documents ad
                                                                              ,ag_doc_type  adt
                                                                         WHERE ad.ag_doc_type_id =
                                                                               adt.ag_doc_type_id
                                                                           AND adt.brief = 'BREAK_AD'
                                                                           AND ad.ag_contract_header_id =
                                                                               ach1.ag_contract_header_id
                                                                           AND ad.doc_date BETWEEN
                                                                               g_date_begin AND g_date_end) THEN
                                                                   0
                                                                  ELSE
                                                                   1
                                                                END) = 1)
                              
                                SELECT av.ag_volume_id
                                      ,av.trans_sum vol_amount
                                      ,CASE
                                         WHEN v_sale_ch = g_sc_dsf THEN
                                          0.03
                                         ELSE
                                          0
                                       END vol_rate
                                  FROM ins.ag_volume      av
                                      ,ins.ag_roll        ar
                                      ,ins.ag_roll_header arh
                                      ,ins.ag_roll_type   art
                                 WHERE av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc, g_vt_ops)
                                   AND ar.ag_roll_id = av.ag_roll_id
                                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                                   AND art.brief = 'CASH_VOL'
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM ag_perf_work_vol     apv
                                              ,ag_perfom_work_det   apd
                                              ,ag_perfomed_work_act apw
                                              ,ag_roll              ar
                                         WHERE apv.ag_volume_id = av.ag_volume_id
                                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                           AND apw.ag_contract_header_id IN
                                               (SELECT apd.ag_prev_header_id
                                                  FROM ag_prev_dog apd
                                                 WHERE apd.ag_contract_header_id IN
                                                       (SELECT * FROM recruited_agents)
                                                UNION ALL
                                                SELECT *
                                                  FROM recruited_agents)
                                           AND apw.ag_roll_id = ar.ag_roll_id
                                           AND ar.ag_roll_header_id != g_roll_header_id)
                                   AND av.ag_contract_header_id IN
                                       (SELECT *
                                          FROM recruited_agents
                                        UNION
                                        SELECT apd.ag_prev_header_id
                                          FROM ag_prev_dog apd
                                         WHERE apd.ag_contract_header_id IN
                                               (SELECT * FROM recruited_agents)))
                       )
    LOOP
      INSERT INTO ag_perf_work_vol
        (ag_perf_work_vol_id, ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (sq_ag_perf_work_vol.nextval
        ,par_ag_perf_work_det_id
        ,detail_vol.ag_volume_id
        ,detail_vol.vol_amount
        ,detail_vol.vol_rate);
    
      v_sum := v_sum + nvl(detail_vol.vol_amount, 0);
    END LOOP;
  
    v_paid_prem := pkg_ag_calc_admin.get_payed_amount(par_ag_perf_work_det_id);
  
    IF v_sale_ch = g_sc_dsf
    THEN
      g_commision := v_sum * 0.03 - v_paid_prem;
    ELSE
      g_commision := 0;
    END IF;
  
    pkg_trace.trace_procedure_end(gc_pkg_name, c_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise_custom('Ошибка при выполнении ' || c_proc_name || SQLERRM);
  END get_recruited_agent_prem;

BEGIN

  pkg_trace.trace_procedure_start(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                                 ,par_trace_subobj_name => 'INIT');

  SELECT rt.rate_type_id INTO g_rev_rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ';

  g_st_renew               := dml_doc_status_ref.get_id_by_brief('RECOVER');
  g_st_getdoc              := dml_doc_status_ref.get_id_by_brief('DOC_REQUEST');
  g_st_reins               := dml_doc_status_ref.get_id_by_brief('RE_REQUEST');
  g_st_medo                := dml_doc_status_ref.get_id_by_brief('MED_OBSERV');
  g_st_nostand             := dml_doc_status_ref.get_id_by_brief('NONSTANDARD');
  g_st_newterm             := dml_doc_status_ref.get_id_by_brief('NEW_CONDITION');
  g_st_declrenew           := dml_doc_status_ref.get_id_by_brief('RECOVER_DENY');
  g_st_passdoc             := dml_doc_status_ref.get_id_by_brief('TO_AGENT_DS');
  g_st_recdoc              := dml_doc_status_ref.get_id_by_brief('FROM_AGENT_DS');
  g_st_recnewterm          := dml_doc_status_ref.get_id_by_brief('FROM_AGENT_NEW_CONDITION');
  g_st_new                 := dml_doc_status_ref.get_id_by_brief('NEW');
  g_st_error               := dml_doc_status_ref.get_id_by_brief('ERROR');
  g_st_act                 := dml_doc_status_ref.get_id_by_brief('ACTIVE');
  g_st_curr                := dml_doc_status_ref.get_id_by_brief('CURRENT');
  g_st_stoped              := dml_doc_status_ref.get_id_by_brief('STOPED');
  g_st_project             := dml_doc_status_ref.get_id_by_brief('PROJECT');
  g_st_b2b_pending         := dml_doc_status_ref.get_id_by_brief('B2B_PENDING');
  g_st_b2b_calculated      := dml_doc_status_ref.get_id_by_brief('B2B_CALCULATED');
  g_st_waiting_for_payment := dml_doc_status_ref.get_id_by_brief('WAITING_FOR_PAYMENT');
  g_st_stop                := dml_doc_status_ref.get_id_by_brief('STOP');
  g_st_print               := dml_doc_status_ref.get_id_by_brief('PRINTED');
  g_st_revision            := dml_doc_status_ref.get_id_by_brief('REVISION');
  g_st_agrevision          := dml_doc_status_ref.get_id_by_brief('AGENT_REVISION');
  g_st_underwr             := dml_doc_status_ref.get_id_by_brief('UNDERWRITING');
  g_st_berak               := dml_doc_status_ref.get_id_by_brief('BREAK');
  g_st_resume              := dml_doc_status_ref.get_id_by_brief('RESUME');
  g_st_readycancel         := dml_doc_status_ref.get_id_by_brief('READY_TO_CANCEL');
  g_st_cancel              := dml_doc_status_ref.get_id_by_brief('CANCEL');
  g_st_paid                := dml_doc_status_ref.get_id_by_brief('PAID');
  g_st_annulated           := dml_doc_status_ref.get_id_by_brief('ANNULATED');
  g_st_concluded           := dml_doc_status_ref.get_id_by_brief('CONCLUDED');
  g_st_to_agent            := dml_doc_status_ref.get_id_by_brief('PASSED_TO_AGENT');
  g_st_from_agent          := dml_doc_status_ref.get_id_by_brief('RECEIVED_FROM_AGENT');
  g_st_quit                := dml_doc_status_ref.get_id_by_brief('QUIT');
  g_st_quit_to_pay         := dml_doc_status_ref.get_id_by_brief('QUIT_TO_PAY');
  g_st_quit_req_reg        := dml_doc_status_ref.get_id_by_brief('QUIT_REQ_GET');
  g_st_quit_query          := dml_doc_status_ref.get_id_by_brief('QUIT_REQ_QUERY');
  g_st_to_quit_ch          := dml_doc_status_ref.get_id_by_brief('TO_QUIT_CHECKED');
  g_st_to_quit             := dml_doc_status_ref.get_id_by_brief('TO_QUIT');
  g_st_ch_ready            := dml_doc_status_ref.get_id_by_brief('TO_QUIT_CHECK_READY');

  g_dt_epg_doc           := dml_doc_templ.get_id_by_brief('PAYMENT');
  g_dt_pp_noncash_doc    := dml_doc_templ.get_id_by_brief('ПП');
  g_dt_a7_doc            := dml_doc_templ.get_id_by_brief('A7');
  g_dt_pd4_doc           := dml_doc_templ.get_id_by_brief('PD4');
  g_dt_pp_direct_doc     := dml_doc_templ.get_id_by_brief('ПП_ПС');
  g_dt_pp_payer_doc      := dml_doc_templ.get_id_by_brief('ПП_ОБ');
  g_dt_comiss_retention  := dml_doc_templ.get_id_by_brief('ЗачетУ_КВ');
  g_ag_perf_work_act_doc := dml_doc_templ.get_id_by_brief('AG_PERFOMED_WORK_ACT');

  g_apt_pp         := dml_ac_payment_templ.get_id_by_brief('ПП');
  g_apt_a7         := dml_ac_payment_templ.get_id_by_brief('A7');
  g_apt_pd4        := dml_ac_payment_templ.get_id_by_brief('PD4');
  g_apt_ukv        := dml_ac_payment_templ.get_id_by_brief('ЗачетУ_КВ');
  g_apt_pp_dir_p   := dml_ac_payment_templ.get_id_by_brief('ПП_ПС');
  g_apt_pp_payer_p := dml_ac_payment_templ.get_id_by_brief('ПП_ОБ');

  g_pr_familydep         := dml_t_product.get_id_by_brief('Family_Dep');
  g_pr_familydep_2011    := dml_t_product.get_id_by_brief('Family_Dep_2011');
  g_pr_familydep_2014    := dml_t_product.get_id_by_brief('Family_Dep_2014');
  g_pr_investor          := dml_t_product.get_id_by_brief('Investor');
  g_pr_investorplus      := dml_t_product.get_id_by_brief('InvestorPlus');
  g_pr_investor_lump     := dml_t_product.get_id_by_brief('INVESTOR_LUMP');
  g_pr_investor_lump_old := dml_t_product.get_id_by_brief('INVESTOR_LUMP_OLD');
  g_pr_protect_state     := dml_t_product.get_id_by_brief('Fof_Prot');
  g_pr_bank_1            := dml_t_product.get_id_by_brief('CR50_1');
  g_pr_bank_2            := dml_t_product.get_id_by_brief('CR50_2');
  g_pr_bank_3            := dml_t_product.get_id_by_brief('CR50_3');
  g_pr_bank_5            := dml_t_product.get_id_by_brief('CR50_4');
  g_pr_bank_4            := dml_t_product.get_id_by_brief('CR78');
  g_prod_cr92_1          := dml_t_product.get_id_by_brief('CR92_1');
  g_prod_cr92_2          := dml_t_product.get_id_by_brief('CR92_2');
  g_prod_cr92_3          := dml_t_product.get_id_by_brief('CR92_3');
  g_prod_cr92_1_1        := dml_t_product.get_id_by_brief('CR92_1.1');
  g_prod_cr92_2_1        := dml_t_product.get_id_by_brief('CR92_2.1');
  g_prod_cr92_3_1        := dml_t_product.get_id_by_brief('CR92_3.1');

  g_pt_quater       := dml_t_payment_terms.get_id_by_brief('EVERY_QUARTER');
  g_pt_year         := dml_t_payment_terms.get_id_by_brief('EVERY_YEAR');
  g_pt_halfyear     := dml_t_payment_terms.get_id_by_brief('HALF_YEAR');
  g_pt_nonrecurring := dml_t_payment_terms.get_id_by_brief('Единовременно');
  g_pt_monthly      := dml_t_payment_terms.get_id_by_brief('MONTHLY');

  g_ct_agent := dml_ag_category_agent.get_id_by_brief('AG');

  g_sc_dsf        := dml_t_sales_channel.get_id_by_brief('MLM');
  g_sc_sas        := dml_t_sales_channel.get_id_by_brief('SAS');
  g_sc_sas_2      := dml_t_sales_channel.get_id_by_brief('SAS 2');
  g_sc_grs_moscow := dml_t_sales_channel.get_id_by_brief('GRSMoscow');
  g_sc_grs_region := dml_t_sales_channel.get_id_by_brief('GRSRegion');
  g_sc_rla        := dml_t_sales_channel.get_id_by_brief('RLA');
  g_sc_bank       := dml_t_sales_channel.get_id_by_brief('BANK');
  g_sc_br         := dml_t_sales_channel.get_id_by_brief('BR');
  g_sc_br_wdisc   := dml_t_sales_channel.get_id_by_brief('BR_WDISC');
  g_sc_mbg        := dml_t_sales_channel.get_id_by_brief('MBG');

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

  g_cm_direct_pay         := dml_t_collection_method.get_id_by_brief('Прямое списание с карты');
  g_cm_noncash_pay        := dml_t_collection_method.get_id_by_brief('Безналичный расчет');
  g_cm_payer_pay          := dml_t_collection_method.get_id_by_brief('Перечисление средств Плательщиком');
  g_cm_tech               := dml_t_collection_method.get_id_by_brief('Технический');
  g_cm_periodic_writeoff  := dml_t_collection_method.get_id_by_brief('Периодическое списание');
  g_cm_internet_acquiring := dml_t_collection_method.get_id_by_brief('Интернет Эквайринг');

  g_vt_life    := dml_ag_volume_type.get_id_by_brief('RL');
  g_vt_ops     := dml_ag_volume_type.get_id_by_brief('NPF');
  g_vt_ops_1   := dml_ag_volume_type.get_id_by_brief('NPF01');
  g_vt_ops_2   := dml_ag_volume_type.get_id_by_brief('NPF02');
  g_vt_ops_3   := dml_ag_volume_type.get_id_by_brief('NPF03');
  g_vt_inv     := dml_ag_volume_type.get_id_by_brief('INV');
  g_vt_fdep    := dml_ag_volume_type.get_id_by_brief('FDep');
  g_vt_avc     := dml_ag_volume_type.get_id_by_brief('SOFI');
  g_vt_bank    := dml_ag_volume_type.get_id_by_brief('BANK');
  g_vt_avc_pay := dml_ag_volume_type.get_id_by_brief('AVCP');
  g_vt_nonevol := dml_ag_volume_type.get_id_by_brief('INFO');
  g_vt_ops_9   := dml_ag_volume_type.get_id_by_brief('NPF(MARK9)');

  g_fund_rur := dml_fund.get_id_by_brief('RUR');

  g_ag_fake_agent      := 2125380;
  g_ag_external_agency := 8127;

  pkg_trace.add_variable(par_trace_var_name => 'g_status_date', par_trace_var_value => g_status_date);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pay_reg_date'
                        ,par_trace_var_value => g_pay_reg_date);
  pkg_trace.add_variable(par_trace_var_name => 'g_pay_date', par_trace_var_value => g_pay_date);
  pkg_trace.add_variable(par_trace_var_name => 'g_cat_date', par_trace_var_value => g_cat_date);
  pkg_trace.add_variable(par_trace_var_name => 'g_ops_sign_d', par_trace_var_value => g_ops_sign_d);
  pkg_trace.add_variable(par_trace_var_name  => 'g_sofi_begin_d'
                        ,par_trace_var_value => g_sofi_begin_d);
  pkg_trace.add_variable(par_trace_var_name => 'g_sofi_end_d', par_trace_var_value => g_sofi_end_d);
  pkg_trace.add_variable(par_trace_var_name => 'g_roll_type', par_trace_var_value => g_roll_type);
  pkg_trace.add_variable(par_trace_var_name  => 'g_roll_type_brief'
                        ,par_trace_var_value => g_roll_type_brief);
  pkg_trace.add_variable(par_trace_var_name => 'g_roll_num', par_trace_var_value => g_roll_num);
  pkg_trace.add_variable(par_trace_var_name  => 'g_roll_header_id'
                        ,par_trace_var_value => g_roll_header_id);
  pkg_trace.add_variable(par_trace_var_name => 'g_category_id', par_trace_var_value => g_category_id);
  pkg_trace.add_variable(par_trace_var_name => 'g_sales_ch', par_trace_var_value => g_sales_ch);
  pkg_trace.add_variable(par_trace_var_name => 'g_leg_pos', par_trace_var_value => g_leg_pos);
  pkg_trace.add_variable(par_trace_var_name => 'g_ag_status', par_trace_var_value => g_ag_status);
  pkg_trace.add_variable(par_trace_var_name  => 'g_ag_start_date'
                        ,par_trace_var_value => g_ag_start_date);
  pkg_trace.add_variable(par_trace_var_name => 'g_sgp1', par_trace_var_value => g_sgp1);
  pkg_trace.add_variable(par_trace_var_name => 'g_sgp2', par_trace_var_value => g_sgp2);
  pkg_trace.add_variable(par_trace_var_name => 'g_commision', par_trace_var_value => g_commision);
  pkg_trace.add_variable(par_trace_var_name => 'g_ksp_vedom', par_trace_var_value => g_ksp_vedom);
  pkg_trace.add_variable(par_trace_var_name => 'g_fund_rur', par_trace_var_value => g_fund_rur);
  pkg_trace.add_variable(par_trace_var_name  => 'g_is_calc_sofi'
                        ,par_trace_var_value => g_is_calc_sofi);
  pkg_trace.add_variable(par_trace_var_name  => 'g_is_calc_sofi_pay'
                        ,par_trace_var_value => g_is_calc_sofi_pay);
  pkg_trace.add_variable(par_trace_var_name  => 'g_is_ops_retention'
                        ,par_trace_var_value => g_is_ops_retention);
  pkg_trace.add_variable(par_trace_var_name => 'g_note', par_trace_var_value => g_note);
  pkg_trace.add_variable(par_trace_var_name => 'g_is_only_nb', par_trace_var_value => g_is_only_nb);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_renew', par_trace_var_value => g_st_renew);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_getdoc', par_trace_var_value => g_st_getdoc);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_reins', par_trace_var_value => g_st_reins);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_medo', par_trace_var_value => g_st_medo);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_nostand', par_trace_var_value => g_st_nostand);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_newterm', par_trace_var_value => g_st_newterm);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_declrenew'
                        ,par_trace_var_value => g_st_declrenew);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_passdoc', par_trace_var_value => g_st_passdoc);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_recdoc', par_trace_var_value => g_st_recdoc);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_recnewterm'
                        ,par_trace_var_value => g_st_recnewterm);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_new', par_trace_var_value => g_st_new);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_act', par_trace_var_value => g_st_act);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_curr', par_trace_var_value => g_st_curr);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_cancel', par_trace_var_value => g_st_cancel);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_project', par_trace_var_value => g_st_project);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_b2b_pending'
                        ,par_trace_var_value => g_st_b2b_pending);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_b2b_calculated'
                        ,par_trace_var_value => g_st_b2b_calculated);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_waiting_for_payment'
                        ,par_trace_var_value => g_st_waiting_for_payment);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_stoped', par_trace_var_value => g_st_stoped);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_print', par_trace_var_value => g_st_print);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_revision', par_trace_var_value => g_st_revision);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_agrevision'
                        ,par_trace_var_value => g_st_agrevision);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_underwr', par_trace_var_value => g_st_underwr);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_berak', par_trace_var_value => g_st_berak);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_readycancel'
                        ,par_trace_var_value => g_st_readycancel);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_paid', par_trace_var_value => g_st_paid);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_annulated'
                        ,par_trace_var_value => g_st_annulated);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_resume', par_trace_var_value => g_st_resume);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_stop', par_trace_var_value => g_st_stop);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_concluded'
                        ,par_trace_var_value => g_st_concluded);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_to_agent', par_trace_var_value => g_st_to_agent);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_from_agent'
                        ,par_trace_var_value => g_st_from_agent);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_error', par_trace_var_value => g_st_error);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_quit', par_trace_var_value => g_st_quit);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_quit_to_pay'
                        ,par_trace_var_value => g_st_quit_to_pay);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_quit_req_reg'
                        ,par_trace_var_value => g_st_quit_req_reg);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_quit_query'
                        ,par_trace_var_value => g_st_quit_query);
  pkg_trace.add_variable(par_trace_var_name  => 'g_st_to_quit_ch'
                        ,par_trace_var_value => g_st_to_quit_ch);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_to_quit', par_trace_var_value => g_st_to_quit);
  pkg_trace.add_variable(par_trace_var_name => 'g_st_ch_ready', par_trace_var_value => g_st_ch_ready);
  pkg_trace.add_variable(par_trace_var_name  => 'g_rev_rate_type_id'
                        ,par_trace_var_value => g_rev_rate_type_id);
  pkg_trace.add_variable(par_trace_var_name => 'g_ct_agent', par_trace_var_value => g_ct_agent);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_dsf', par_trace_var_value => g_sc_dsf);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_sas', par_trace_var_value => g_sc_sas);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_sas_2', par_trace_var_value => g_sc_sas_2);
  pkg_trace.add_variable(par_trace_var_name  => 'g_sc_grs_moscow'
                        ,par_trace_var_value => g_sc_grs_moscow);
  pkg_trace.add_variable(par_trace_var_name  => 'g_sc_grs_region'
                        ,par_trace_var_value => g_sc_grs_region);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_rla', par_trace_var_value => g_sc_rla);
  pkg_trace.add_variable(par_trace_var_name  => 'g_ag_fake_agent'
                        ,par_trace_var_value => g_ag_fake_agent);
  pkg_trace.add_variable(par_trace_var_name  => 'g_ag_external_agency'
                        ,par_trace_var_value => g_ag_external_agency);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_bank', par_trace_var_value => g_sc_bank);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_br', par_trace_var_value => g_sc_br);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_br_wdisc', par_trace_var_value => g_sc_br_wdisc);
  pkg_trace.add_variable(par_trace_var_name => 'g_sc_mbg', par_trace_var_value => g_sc_mbg);
  pkg_trace.add_variable(par_trace_var_name => 'g_pt_quater', par_trace_var_value => g_pt_quater);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pt_nonrecurring'
                        ,par_trace_var_value => g_pt_nonrecurring);
  pkg_trace.add_variable(par_trace_var_name => 'g_pt_monthly', par_trace_var_value => g_pt_monthly);
  pkg_trace.add_variable(par_trace_var_name => 'g_pt_year', par_trace_var_value => g_pt_year);
  pkg_trace.add_variable(par_trace_var_name => 'g_pt_halfyear', par_trace_var_value => g_pt_halfyear);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cn_legentity'
                        ,par_trace_var_value => g_cn_legentity);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cn_natperson'
                        ,par_trace_var_value => g_cn_natperson);
  pkg_trace.add_variable(par_trace_var_name => 'g_cn_legal', par_trace_var_value => g_cn_legal);
  pkg_trace.add_variable(par_trace_var_name  => 'g_dt_pp_noncash_doc'
                        ,par_trace_var_value => g_dt_pp_noncash_doc);
  pkg_trace.add_variable(par_trace_var_name => 'g_dt_a7_doc', par_trace_var_value => g_dt_a7_doc);
  pkg_trace.add_variable(par_trace_var_name => 'g_dt_pd4_doc', par_trace_var_value => g_dt_pd4_doc);
  pkg_trace.add_variable(par_trace_var_name => 'g_dt_epg_doc', par_trace_var_value => g_dt_epg_doc);
  pkg_trace.add_variable(par_trace_var_name  => 'g_dt_pp_direct_doc'
                        ,par_trace_var_value => g_dt_pp_direct_doc);
  pkg_trace.add_variable(par_trace_var_name  => 'g_dt_pp_payer_doc'
                        ,par_trace_var_value => g_dt_pp_payer_doc);
  pkg_trace.add_variable(par_trace_var_name  => 'g_dt_direct_pay'
                        ,par_trace_var_value => g_dt_direct_pay);
  pkg_trace.add_variable(par_trace_var_name  => 'g_dt_payer_pay'
                        ,par_trace_var_value => g_dt_payer_pay);
  pkg_trace.add_variable(par_trace_var_name => 'g_apt_a7', par_trace_var_value => g_apt_a7);
  pkg_trace.add_variable(par_trace_var_name => 'g_apt_pd4', par_trace_var_value => g_apt_pd4);
  pkg_trace.add_variable(par_trace_var_name => 'g_apt_pp', par_trace_var_value => g_apt_pp);
  pkg_trace.add_variable(par_trace_var_name  => 'g_apt_pp_dir_p'
                        ,par_trace_var_value => g_apt_pp_dir_p);
  pkg_trace.add_variable(par_trace_var_name  => 'g_apt_pp_payer_p'
                        ,par_trace_var_value => g_apt_pp_payer_p);
  pkg_trace.add_variable(par_trace_var_name => 'g_apt_ukv', par_trace_var_value => g_apt_ukv);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cm_direct_pay'
                        ,par_trace_var_value => g_cm_direct_pay);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cm_noncash_pay'
                        ,par_trace_var_value => g_cm_noncash_pay);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cm_payer_pay'
                        ,par_trace_var_value => g_cm_payer_pay);
  pkg_trace.add_variable(par_trace_var_name => 'g_cm_tech', par_trace_var_value => g_cm_tech);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cm_periodic_writeoff'
                        ,par_trace_var_value => g_cm_periodic_writeoff);
  pkg_trace.add_variable(par_trace_var_name  => 'g_cm_internet_acquiring'
                        ,par_trace_var_value => g_cm_internet_acquiring);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_familydep'
                        ,par_trace_var_value => g_pr_familydep);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_familydep_2011'
                        ,par_trace_var_value => g_pr_familydep_2011);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_familydep_2014'
                        ,par_trace_var_value => g_pr_familydep_2014);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_protect_state'
                        ,par_trace_var_value => g_pr_protect_state);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_bank_1', par_trace_var_value => g_pr_bank_1);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_bank_2', par_trace_var_value => g_pr_bank_2);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_bank_3', par_trace_var_value => g_pr_bank_3);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_bank_4', par_trace_var_value => g_pr_bank_4);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_bank_5', par_trace_var_value => g_pr_bank_5);
  pkg_trace.add_variable(par_trace_var_name => 'g_pr_investor', par_trace_var_value => g_pr_investor);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_investorplus'
                        ,par_trace_var_value => g_pr_investorplus);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_investor_lump'
                        ,par_trace_var_value => g_pr_investor_lump);
  pkg_trace.add_variable(par_trace_var_name  => 'g_pr_investor_lump_old'
                        ,par_trace_var_value => g_pr_investor_lump_old);
  pkg_trace.add_variable(par_trace_var_name => 'g_prod_cr92_1', par_trace_var_value => g_prod_cr92_1);
  pkg_trace.add_variable(par_trace_var_name => 'g_prod_cr92_2', par_trace_var_value => g_prod_cr92_2);
  pkg_trace.add_variable(par_trace_var_name => 'g_prod_cr92_3', par_trace_var_value => g_prod_cr92_3);
  pkg_trace.add_variable(par_trace_var_name  => 'g_prod_cr92_1_1'
                        ,par_trace_var_value => g_prod_cr92_1_1);
  pkg_trace.add_variable(par_trace_var_name  => 'g_prod_cr92_2_1'
                        ,par_trace_var_value => g_prod_cr92_2_1);
  pkg_trace.add_variable(par_trace_var_name  => 'g_prod_cr92_3_1'
                        ,par_trace_var_value => g_prod_cr92_3_1);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_life', par_trace_var_value => g_vt_life);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_ops', par_trace_var_value => g_vt_ops);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_ops_1', par_trace_var_value => g_vt_ops_1);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_ops_2', par_trace_var_value => g_vt_ops_2);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_ops_3', par_trace_var_value => g_vt_ops_3);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_inv', par_trace_var_value => g_vt_inv);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_avc', par_trace_var_value => g_vt_avc);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_avc_pay', par_trace_var_value => g_vt_avc_pay);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_nonevol', par_trace_var_value => g_vt_nonevol);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_bank', par_trace_var_value => g_vt_bank);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_fdep', par_trace_var_value => g_vt_fdep);
  pkg_trace.add_variable(par_trace_var_name => 'g_vt_ops_9', par_trace_var_value => g_vt_ops_9);

  pkg_trace.trace_procedure_end(par_trace_obj_name    => 'PKG_AG_AGENT_CALC'
                               ,par_trace_subobj_name => 'INIT');
END pkg_ag_agent_calc;
/

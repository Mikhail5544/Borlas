CREATE OR REPLACE PACKAGE pkg_ag_mng_dir_calc IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 02.06.2009 11:32:18
  -- Purpose : Расчет премий менеджерам и директорам по приказу 26/ОД/09 от 01/04/2009
  TYPE t_cash IS RECORD(
     cash_amount    NUMBER
    ,commiss_amount NUMBER);

  PROCEDURE get_volume
  (
    p_date        DATE
   ,p_roll_type   PLS_INTEGER
   ,p_roll_header PLS_INTEGER
  );
  PROCEDURE calc
  (
    p_ag_roll_id            NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  );

  PROCEDURE calc_vedom_250510(p_ag_contract_header_id PLS_INTEGER);
  PROCEDURE calc_vedom_rla(p_ag_contract_header_id PLS_INTEGER);
  PROCEDURE calc_vedom_010409(p_ag_contract_header_id PLS_INTEGER);
  PROCEDURE calc_vedom_010609(p_ag_contract_header_id PLS_INTEGER);

  PROCEDURE prepare_cash;
  PROCEDURE prepare_cash_010609;
  PROCEDURE prepare_sgp;
  PROCEDURE prepare_sgp_010609;
  PROCEDURE prepare_volume;
  PROCEDURE prepare_ksp_0510;

  PROCEDURE prepare_ksp;

  FUNCTION get_volume_val_act
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_vol_type              PLS_INTEGER DEFAULT 1
   ,p_department_id         PLS_INTEGER DEFAULT NULL
   ,p_date                  DATE DEFAULT NULL
  ) RETURN t_volume_val_o;
  FUNCTION get_volume_val
  (
    p_ag_contract_header_id PLS_INTEGER
   ,vol_type                PLS_INTEGER
   ,p_department_id         PLS_INTEGER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION get_ksp_0510(p_ag_perf_work_act_id PLS_INTEGER) RETURN NUMBER;
  FUNCTION get_sgp
  (
    p_ag_work_det_id        PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION get_cash(p_ag_work_det_id NUMBER) RETURN t_cash;
  FUNCTION get_ksp(p_ag_work_det_id NUMBER) RETURN NUMBER;

  PROCEDURE fake_sofi_prem_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE self_sale_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rla_volume_group(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rla_personal_pol(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rla_management_structure(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rla_contrib_years(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rla_charging_units;
  PROCEDURE work_group_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE renew_policy_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE reach_level_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE reach_ksp_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE exec_plan_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE evol_sub_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE personal_group_5010(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE qualitative_ops_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE q_male_ops_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE enroled_leader_calc_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE ksp_kpi_reach_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE kpi_orig_ops(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE kpi_plan_ops(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE active_agent_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE grs_exec_plan_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE grs_policy_comis_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE get_grs_agents_prem(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rm_plan_exec_0510(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rm_active_agent_0510(p_ag_perf_work_det_id PLS_INTEGER);

  PROCEDURE work_group_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE rd_exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE add_exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE over_plan_calc(p_ag_perf_work_det_id NUMBER);
  PROCEDURE evol_step_calc(p_ag_perf_work_det_id NUMBER);
  PROCEDURE add_evol_step_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE evol_sub_calc(p_ag_perf_work_det_id NUMBER);
  PROCEDURE evol_sub_calc_010609(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE over_plan_year_calc(p_ag_perf_work_det_id PLS_INTEGER);
  PROCEDURE add_work_group_calc(p_ag_perf_work_det_id PLS_INTEGER);

END pkg_ag_mng_dir_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_mng_dir_calc IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  g_roll_type          PLS_INTEGER DEFAULT NULL;
  g_roll_type_brief    ag_roll_type.brief%TYPE;
  g_roll_id            PLS_INTEGER;
  g_roll_header_id     PLS_INTEGER;
  g_vol_roll_header_id NUMBER;
  g_roll_num           PLS_INTEGER;
  g_commision          NUMBER;
  g_date_end           DATE DEFAULT SYSDATE;
  g_date_begin         DATE DEFAULT SYSDATE;
  g_status_date        DATE := SYSDATE; -- TO_DATE('10.12.2009 23:59:59', 'dd.mm.yyyy HH24:Mi:SS'); -- SYSDATE;
  g_sgp1               NUMBER;
  g_sgp2               NUMBER;
  g_rate_type_id       PLS_INTEGER;
  g_ksp_vedom          PLS_INTEGER;
  --Статусы--
  g_st_new         PLS_INTEGER;
  g_st_resume      PLS_INTEGER;
  g_st_act         PLS_INTEGER;
  g_st_curr        PLS_INTEGER;
  g_st_cancel      PLS_INTEGER;
  g_st_stoped      PLS_INTEGER;
  g_st_print       PLS_INTEGER;
  g_st_revision    PLS_INTEGER;
  g_st_agrevision  PLS_INTEGER;
  g_st_underwr     PLS_INTEGER;
  g_st_berak       PLS_INTEGER;
  g_st_readycancel PLS_INTEGER;
  g_st_paid        PLS_INTEGER;
  g_st_annulated   PLS_INTEGER;
  g_st_stop        PLS_INTEGER;
  g_st_concluded   PLS_INTEGER;
  --Статусы агентов--
  g_agst_mng_base PLS_INTEGER;
  g_agst_ag_base  PLS_INTEGER;
  g_agst_rop      PLS_INTEGER;
  g_agst_tdir     PLS_INTEGER;
  g_agst_reg_dir  PLS_INTEGER;
  g_agst_mng1     PLS_INTEGER;
  g_catag_mn      PLS_INTEGER;
  --Рассрочки--
  g_pt_quater       PLS_INTEGER;
  g_pt_nonrecurring PLS_INTEGER;
  g_pt_monthly      PLS_INTEGER;
  --Тип контакта--
  g_cn_legentity PLS_INTEGER;
  g_cn_natperson PLS_INTEGER;
  g_cn_legal     PLS_INTEGER;
  --Шаблоны документов--
  g_dt_pay_doc          PLS_INTEGER;
  g_dt_a7_doc           PLS_INTEGER;
  g_dt_pd4_doc          PLS_INTEGER;
  g_dt_epg_doc          PLS_INTEGER;
  g_dt_ag_perf_work_act NUMBER;

  g_ct_agent           PLS_INTEGER;
  g_sc_sas             PLS_INTEGER;
  g_sc_sas_2           PLS_INTEGER;
  g_sc_dsf             PLS_INTEGER;
  g_sc_grs_moscow      PLS_INTEGER;
  g_sc_grs_region      PLS_INTEGER;
  g_sc_rla             PLS_INTEGER;
  g_ag_fake_agent      PLS_INTEGER;
  g_ag_external_agency PLS_INTEGER;

  g_tt_insprempaid    PLS_INTEGER;
  g_tt_inspremapaid   PLS_INTEGER;
  g_tt_prempaidagent  PLS_INTEGER;
  g_tt_agentpaysetoff PLS_INTEGER;

  --Типы объемов
  g_vt_life       PLS_INTEGER;
  g_vt_ops        PLS_INTEGER;
  g_vt_ops_1      PLS_INTEGER;
  g_vt_ops_2      PLS_INTEGER;
  g_vt_ops_3      PLS_INTEGER;
  g_vt_inv        PLS_INTEGER;
  g_vt_avc        PLS_INTEGER;
  g_vt_avc_pay    PLS_INTEGER;
  g_vt_nonevol    PLS_INTEGER;
  g_vt_bank       PLS_INTEGER;
  g_vt_fdep       PLS_INTEGER;
  g_vt_ops_9      PLS_INTEGER;
  g_vt_conv_sheet PLS_INTEGER;
  --Продукт
  g_prod_id         PLS_INTEGER;
  g_prod_invplus_id PLS_INTEGER;
  --Категории агентов
  g_cat_td_id PLS_INTEGER;

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
    g_date_end       := pkg_ag_calc_admin.get_opertation_month_date(p_date, 2);
    g_date_begin     := pkg_ag_calc_admin.get_opertation_month_date(p_date, 1);
    g_roll_type      := p_roll_type;
    g_roll_header_id := p_roll_header;
    --     Prepare_cash;
    --     Prepare_SGP;
    --    Prepare_cash_010609;
    -- Prepare_SGP_010609;
    --    Prepare_KSP;
    --      Prepare_KSP_0510;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_volume;

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
          ,arh.vol_roll_header_id
      INTO g_date_begin
          ,g_date_end
          ,g_roll_type
          ,g_roll_type_brief
          ,g_roll_id
          ,g_roll_header_id
          ,v_calc_func
          ,g_roll_num
          ,g_ksp_vedom
          ,g_vol_roll_header_id
      FROM ven_ag_roll    ar
          ,ag_roll_header arh
          ,ag_roll_type   art
     WHERE ar.ag_roll_header_id = arh.ag_roll_header_id
       AND arh.ag_roll_type_id = art.ag_roll_type_id
       AND ar.ag_roll_id = p_ag_roll_id;
  
    pkg_agent_calculator.insertinfo('Ведомость ' || g_roll_type_brief || ' id: ' ||
                                    to_char(p_ag_roll_id));
  
    g_status_date := last_day(g_date_end) + 10.99999;
  
    EXECUTE IMMEDIATE v_calc_func
      USING p_ag_contract_header_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка! при расчете ведомости ' || SQLERRM || chr(10));
  END calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 20.06.2010 17:57:14
  -- Purpose : Расчет ведомости МнД по мотивации от 25/05/2010
  -- НЕ ИСПОЛЬЗУЕТСЯ с 21.08.2014, впоследствие можно удалить
  PROCEDURE calc_vedom_250510_old(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'calc_vedom_250510';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
    v_volumes    t_volume_val_o := t_volume_val_o(NULL);
    v_rl_nbv     NUMBER;
    v_all_nbv    NUMBER;
    v_ksp        NUMBER;
    v_level      PLS_INTEGER;
    perc_done    NUMBER := 0;
    perc_total   NUMBER := 0;
    last_perc    NUMBER := 0;
    i            PLS_INTEGER := 0;
    v_dt_manag   DATE;
    v_ops3_nbv   NUMBER := 0;
    -- j            PLS_INTEGER:=0;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 0);
    --1)Подготовим данные для расчета премий.
    pkg_agent_calculator.insertinfo('Построение дерева для объемов');
    prepare_volume;
    pkg_agent_calculator.insertinfo('Построение дерева для КСП');
    prepare_ksp_0510;
    pkg_agent_calculator.insertinfo('Начат расчет Актов');
  
    FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                       ,arat.ag_rate_type_id ag_rate_type_id
                       ,atc.ag_category_agent_id
                       ,atc.t_sales_channel_id
                       ,COUNT(*) over(PARTITION BY 1) prem_count
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
                  ORDER BY atc.sort_order)
    LOOP
      i := 0;
      -- j:=j+1;
      perc_total := perc_done;
      --2)Отбор менеджеров/директоров
      FOR managers IN (SELECT ach.ag_contract_header_id
                             ,COUNT(*) over(PARTITION BY 1) cur_count
                             ,ach.t_sales_channel_id
                             ,ac.category_id
                             ,(SELECT MAX(LEVEL)
                                 FROM ag_contract acr
                                START WITH acr.ag_contract_id = ac.ag_contract_id
                               CONNECT BY PRIOR
                                           acr.contract_id =
                                           (SELECT acr2.contract_id
                                              FROM ag_contract acr2
                                             WHERE acr2.ag_contract_id = acr.contract_f_lead_id)
                                      AND SYSDATE BETWEEN acr.date_begin AND acr.date_end) recr_lvl
                         FROM ins.ag_contract        ac
                             ,ins.ag_contract_header ach
                             ,ins.t_sales_channel    ts
                             ,ins.ag_documents       agd
                             ,ins.ag_doc_type        adt
                             ,ins.document           d
                             ,ins.doc_status_ref     rf
                        WHERE ac.contract_id = ach.ag_contract_header_id
                          AND ach.ag_contract_header_id =
                              nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                          AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                             /**********заявка №162959******************************/
                          AND (ac.category_id IN
                              (SELECT cat.ag_category_agent_id
                                  FROM ins.ag_category_agent cat
                                 WHERE cat.brief IN ('MN', 'DR', 'DR2')) OR
                              (ac.category_id IN (SELECT cat.ag_category_agent_id
                                                     FROM ins.ag_category_agent cat
                                                    WHERE cat.brief IN ('TD')) AND NOT EXISTS
                               (SELECT NULL
                                   FROM ag_contract ac1
                                  WHERE ac1.contract_id = ach.ag_contract_header_id
                                    AND SYSDATE BETWEEN ac1.date_begin AND ac1.date_end
                                    AND ac1.category_id = g_ct_agent)))
                             /*************************************/
                          AND ts.id = ach.t_sales_channel_id
                          AND ach.ag_contract_header_id = agd.ag_contract_header_id
                          AND agd.ag_doc_type_id = adt.ag_doc_type_id
                          AND adt.brief = 'NEW_AD'
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
                          AND EXISTS
                        (SELECT NULL
                                 FROM ag_documents agd1
                                     ,ag_doc_type  adt1
                                WHERE agd1.ag_doc_type_id = adt1.ag_doc_type_id
                                  AND adt1.brief = 'CAT_CHG'
                                  AND agd1.ag_contract_header_id = ach.ag_contract_header_id
                                  AND agd1.doc_date = pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                                                    ,g_date_end
                                                                                    ,ac.category_id
                                                                                    ,1)
                                  AND doc.get_doc_status_brief(agd1.ag_documents_id) IN
                                      ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))
                             /************Анастасия Чернова: у директоров/менеджеров должен быть документ Заключение с RLP, но не у тердиров и не у Норманских и Макаровой****************/
                          AND (CASE
                                WHEN ac.category_id IN
                                     (SELECT cat.ag_category_agent_id
                                        FROM ins.ag_category_agent cat
                                       WHERE cat.brief IN ('MN', 'DR', 'DR2'))
                                     AND EXISTS
                                 (SELECT NULL
                                        FROM ag_documents agd2
                                            ,ag_doc_type  adt2
                                       WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                         AND adt2.brief = 'RLP_AD'
                                         AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                         AND doc.get_doc_status_brief(agd2.ag_documents_id) IN
                                             ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))
                                     AND ach.ag_contract_header_id NOT IN
                                     (SELECT agha.ag_contract_header_id
                                            FROM ins.ven_ag_contract_header agha
                                           WHERE agha.num IN ( /*'13855',*/ '10201')) THEN
                                 1
                                WHEN ac.category_id = (SELECT cat.ag_category_agent_id
                                                         FROM ins.ag_category_agent cat
                                                        WHERE cat.brief IN ('TD')) THEN
                                 1
                                WHEN ac.category_id IN
                                     (SELECT cat.ag_category_agent_id
                                        FROM ins.ag_category_agent cat
                                       WHERE cat.brief IN ('DR', 'DR2'))
                                     AND ach.ag_contract_header_id IN
                                     (SELECT agha.ag_contract_header_id
                                            FROM ins.ven_ag_contract_header agha
                                           WHERE agha.num IN ( /*'13855',*/ '10201')) THEN
                                 1
                                ELSE
                                 0
                              END) = 1
                             /************добавлен статус Расторгнут, заявка №153093 Чернова Анастасия***************************/
                             /*********убран статус Расторгнут, заявка 220784 Синицина Ирина*****************/
                          AND ach.ag_contract_header_id = d.document_id
                          AND d.doc_status_ref_id = rf.doc_status_ref_id
                          AND rf.brief = 'CURRENT'
                          AND nvl(ach.is_new, 1) = 1
                          AND ac.category_id = prem.ag_category_agent_id
                          AND ts.id = prem.t_sales_channel_id
                        ORDER BY recr_lvl)
      LOOP
      
        i         := i + 1;
        perc_done := (i / managers.cur_count) * 100 * 1 / prem.prem_count + perc_total;
        IF last_perc <> perc_done
        THEN
          last_perc := perc_done;
          pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, perc_done);
        END IF;
      
        BEGIN
        
          SELECT apw.ag_perfomed_work_act_id
            INTO v_apw_id
            FROM ag_perfomed_work_act apw
           WHERE apw.ag_roll_id = g_roll_id
             AND apw.ag_contract_header_id = managers.ag_contract_header_id;
        
        EXCEPTION
          WHEN no_data_found THEN
          
            SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
            v_ops3_nbv := 0;
            IF managers.t_sales_channel_id IN (g_sc_grs_moscow, g_sc_grs_region)
            THEN
              v_volumes := get_volume_val_act(managers.ag_contract_header_id, 9);
            
              v_rl_nbv  := 0;
              v_all_nbv := v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                           v_volumes.get_volume(g_vt_ops_9);
            
            ELSIF managers.t_sales_channel_id IN (g_sc_dsf)
            THEN
              v_volumes := get_volume_val_act(managers.ag_contract_header_id);
              /**Изменения №159549************/
              /*v_ops3_nbv := v_volumes.get_volume(g_vt_OPS_3);*/
              /*************/
              v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                           v_volumes.get_volume(g_vt_fdep);
              v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_ops) +
                           v_volumes.get_volume(g_vt_ops_2) + v_volumes.get_volume(g_vt_avc) +
                           v_volumes.get_volume(g_vt_inv) + v_volumes.get_volume(g_vt_bank) +
                           v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
            
            ELSIF managers.t_sales_channel_id IN (g_sc_sas)
            THEN
              v_volumes := get_volume_val_act(managers.ag_contract_header_id);
            
              /*****Изменения №159549**********/
              IF managers.category_id = g_cat_td_id
              THEN
                v_ops3_nbv := v_volumes.get_volume(g_vt_ops_3);
              ELSE
                v_ops3_nbv := 0;
              END IF;
              /*****************/
              v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                           v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_fdep);
              v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                           v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                           v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_bank) +
                           v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
            
            ELSIF managers.t_sales_channel_id IN (g_sc_sas_2)
            THEN
              v_volumes := get_volume_val_act(managers.ag_contract_header_id);
            
              v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                           v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_fdep);
              v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                           v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                           v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_bank) +
                           v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
            
            END IF;
          
            INSERT INTO ven_ag_perfomed_work_act
              (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, date_calc, volumes)
            VALUES
              (v_apw_id, g_roll_id, managers.ag_contract_header_id, SYSDATE, v_volumes);
          
            IF managers.t_sales_channel_id != g_sc_dsf
            THEN
              v_ksp := 100;
            ELSE
              v_ksp := nvl(get_ksp_0510(v_apw_id), 0);
            END IF;
          
            BEGIN
              SELECT agd.doc_date
                INTO v_dt_manag
                FROM ven_ag_contract_header agh
                    ,ins.ag_documents       agd
                    ,ins.ag_doc_type        adt
                    ,ins.ag_props_change    apc
                    ,ins.ag_props_type      apt
                    ,ins.ag_contract        ag
                    ,ins.document           d
                    ,ins.doc_status_ref     rf
               WHERE agh.ag_contract_header_id = agd.ag_contract_header_id
                 AND agd.ag_doc_type_id = adt.ag_doc_type_id
                 AND adt.brief = 'CAT_CHG'
                 AND agd.ag_documents_id = apc.ag_documents_id
                 AND apc.ag_props_type_id = apt.ag_props_type_id
                 AND apt.brief = 'CAT_PROP'
                 AND agd.ag_documents_id = d.document_id
                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                 AND rf.brief NOT IN ('PROJECT', 'CANCEL')
                 AND agh.ag_contract_header_id = ag.contract_id
                 AND ag.date_begin BETWEEN to_date('15.09.2011', 'dd.mm.yyyy') AND
                     to_date('15.12.2011', 'dd.mm.yyyy')
                 AND ag.ag_documents_id = agd.ag_documents_id
                 AND apc.new_value = '3'
                 AND agh.ag_contract_header_id = managers.ag_contract_header_id
                 AND nvl(agh.is_new, 0) = 1
                 AND rownum = 1;
            EXCEPTION
              WHEN no_data_found THEN
                v_dt_manag := to_date('31.12.2999', 'DD.MM.YYYY');
            END;
          
            SELECT CASE
                     WHEN managers.t_sales_channel_id = g_sc_dsf THEN
                      (CASE
                        WHEN managers.category_id = 3
                             AND v_dt_manag <> to_date('31.12.2999', 'DD.MM.YYYY') THEN
                         (CASE
                           WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                                to_date('25.12.2011', 'DD.MM.YYYY') THEN
                            v_all_nbv
                           ELSE
                            v_rl_nbv
                         END)
                        WHEN managers.category_id = 2 THEN
                         (CASE
                           WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                                to_date('25.12.2011', 'DD.MM.YYYY') THEN
                            v_all_nbv
                           ELSE
                            v_rl_nbv
                         END)
                        ELSE
                         v_rl_nbv
                      END)
                     ELSE
                      (CASE
                        WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                             to_date('25.12.2011', 'DD.MM.YYYY') THEN
                         v_all_nbv
                        ELSE
                         v_rl_nbv
                      END)
                   END
              INTO v_rl_nbv
              FROM dual;
          
            v_level := nvl(pkg_tariff_calc.calc_coeff_val('LEVEL'
                                                         ,t_number_type(managers.t_sales_channel_id
                                                                       ,managers.category_id
                                                                       ,0
                                                                       ,v_rl_nbv
                                                                       ,v_all_nbv + v_ops3_nbv
                                                                       ,v_ksp
                                                                       ,999))
                          ,1);
          
            UPDATE ag_perfomed_work_act apw
               SET apw.ag_ksp   = v_ksp
                  ,apw.ag_level = v_level
             WHERE apw.ag_perfomed_work_act_id = v_apw_id;
          
        END;
      
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
      
        UPDATE ag_perfomed_work_act a
           SET a.sum = a.sum + nvl(g_commision, 0)
         WHERE a.ag_perfomed_work_act_id = v_apw_id;
      
        --После каждого акта
        COMMIT;
      END LOOP;
    END LOOP;
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 100);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_vedom_250510_old;

  PROCEDURE calc_vedom_250510(p_ag_contract_header_id PLS_INTEGER) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'calc_vedom_250510';
    v_apw_id                  PLS_INTEGER;
    v_apw_det_id              PLS_INTEGER;
    v_volumes                 t_volume_val_o := t_volume_val_o(NULL);
    v_rl_nbv                  NUMBER;
    v_all_nbv                 NUMBER;
    v_ksp                     NUMBER;
    v_level                   PLS_INTEGER;
    perc_done                 NUMBER := 0;
    perc_total                NUMBER := 0;
    last_perc                 NUMBER := 0;
    i                         PLS_INTEGER := 0;
    v_activity_meetings_count NUMBER;
    v_dt_manag                DATE;
    v_ops3_nbv                NUMBER := 0;
    v_timestamp               TIMESTAMP;
    -- j            PLS_INTEGER:=0;
  BEGIN
    pkg_trace.trace_procedure_start(gc_pkg_name, c_proc_name);
    -- Получаем актуальные данные по листам переговоров из Навигатора
    IF FALSE --par_download_activity_meetings
    THEN
      pkg_agn_control.download_activity_meetings(trunc(g_date_end, 'month'));
    END IF;
  
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 0);
    --1)Подготовим данные для расчета премий.
    pkg_agent_calculator.insertinfo('Построение дерева для объемов');
    prepare_volume;
    pkg_agent_calculator.insertinfo('Построение дерева для КСП');
    prepare_ksp_0510;
    pkg_agent_calculator.insertinfo('Начат расчет Актов');
  
    --2)Отбор менеджеров/директоров
    FOR managers IN (SELECT ach.ag_contract_header_id
                           ,COUNT(*) over(PARTITION BY 1) cur_count
                           ,ach.t_sales_channel_id
                           ,ac.category_id
                           ,(SELECT MAX(LEVEL)
                               FROM ag_contract acr
                              START WITH acr.ag_contract_id = ac.ag_contract_id
                             CONNECT BY PRIOR acr.contract_id =
                                         (SELECT acr2.contract_id
                                                 FROM ag_contract acr2
                                                WHERE acr2.ag_contract_id = acr.contract_f_lead_id)
                                    AND SYSDATE BETWEEN acr.date_begin AND acr.date_end) recr_lvl
                       FROM ins.ag_contract        ac
                           ,ins.ag_contract_header ach
                           ,ins.t_sales_channel    ts
                           ,ins.ag_documents       agd
                           ,ins.ag_doc_type        adt
                           ,ins.document           d
                           ,ins.doc_status_ref     rf
                      WHERE ac.contract_id = ach.ag_contract_header_id
                        AND ach.ag_contract_header_id =
                            nvl(p_ag_contract_header_id, ach.ag_contract_header_id)
                        AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                           /**********заявка №162959******************************/
                        AND (ac.category_id IN
                            (SELECT cat.ag_category_agent_id
                                FROM ins.ag_category_agent cat
                               WHERE cat.brief IN ('MN', 'DR', 'DR2')) OR
                            (ac.category_id IN (SELECT cat.ag_category_agent_id
                                                   FROM ins.ag_category_agent cat
                                                  WHERE cat.brief IN ('TD')) AND NOT EXISTS
                             (SELECT NULL
                                 FROM ag_contract ac1
                                WHERE ac1.contract_id = ach.ag_contract_header_id
                                  AND SYSDATE BETWEEN ac1.date_begin AND ac1.date_end
                                  AND ac1.category_id = g_ct_agent)))
                           /*************************************/
                        AND ts.id = ach.t_sales_channel_id
                        AND ach.ag_contract_header_id = agd.ag_contract_header_id
                        AND agd.ag_doc_type_id = adt.ag_doc_type_id
                        AND adt.brief = 'NEW_AD'
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
                        AND EXISTS
                      (SELECT NULL
                               FROM ag_documents agd1
                                   ,ag_doc_type  adt1
                              WHERE agd1.ag_doc_type_id = adt1.ag_doc_type_id
                                AND adt1.brief = 'CAT_CHG'
                                AND agd1.ag_contract_header_id = ach.ag_contract_header_id
                                AND agd1.doc_date = pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                                                  ,g_date_end
                                                                                  ,ac.category_id
                                                                                  ,1)
                                AND doc.get_doc_status_brief(agd1.ag_documents_id) IN
                                    ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))
                           /************Анастасия Чернова: у директоров/менеджеров должен быть документ Заключение с RLP, но не у тердиров и не у Норманских и Макаровой****************/
                        AND (CASE
                              WHEN ac.category_id IN
                                   (SELECT cat.ag_category_agent_id
                                      FROM ins.ag_category_agent cat
                                     WHERE cat.brief IN ('MN', 'DR', 'DR2'))
                                   AND EXISTS
                               (SELECT NULL
                                      FROM ag_documents agd2
                                          ,ag_doc_type  adt2
                                     WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                       AND adt2.brief = 'RLP_AD'
                                       AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                       AND doc.get_doc_status_brief(agd2.ag_documents_id) IN
                                           ('CO_ACCEPTED', 'CO_ACHIVE', 'DEFICIENCY'))
                                   AND ach.ag_contract_header_id NOT IN
                                   (SELECT agha.ag_contract_header_id
                                          FROM ins.ven_ag_contract_header agha
                                         WHERE agha.num IN ( /*'13855',*/ '10201')) THEN
                               1
                              WHEN ac.category_id = (SELECT cat.ag_category_agent_id
                                                       FROM ins.ag_category_agent cat
                                                      WHERE cat.brief IN ('TD')) THEN
                               1
                              WHEN ac.category_id IN
                                   (SELECT cat.ag_category_agent_id
                                      FROM ins.ag_category_agent cat
                                     WHERE cat.brief IN ('DR', 'DR2'))
                                   AND ach.ag_contract_header_id IN
                                   (SELECT agha.ag_contract_header_id
                                          FROM ins.ven_ag_contract_header agha
                                         WHERE agha.num IN ( /*'13855',*/ '10201')) THEN
                               1
                              ELSE
                               0
                            END) = 1
                           /* Зыонг Р.: Заявка №405271 */
                        AND (CASE
                              WHEN ac.category_id IN
                                   (SELECT cat.ag_category_agent_id
                                      FROM ins.ag_category_agent cat
                                     WHERE cat.brief IN ('MN', 'DR', 'DR2'))
                                   AND g_date_begin >= to_date('26/02/2015', 'dd/mm/yyyy')
                                   AND
                                   (NOT EXISTS
                                    (SELECT NULL
                                       FROM ag_documents agd2
                                           ,ag_doc_type  adt2
                                      WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                        AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                        AND adt2.brief = 'BONUSES_PROVISION'
                                        AND doc.get_doc_status_brief(agd2.ag_documents_id) IN
                                            ('CO_ACCEPTED', 'CO_ACHIVE')) OR
                                    ach.date_break BETWEEN g_date_begin AND g_date_end OR EXISTS
                                    (SELECT NULL
                                       FROM ag_documents agd2
                                           ,ag_doc_type  adt2
                                      WHERE agd2.ag_doc_type_id = adt2.ag_doc_type_id
                                        AND agd2.ag_contract_header_id = ach.ag_contract_header_id
                                        AND adt2.brief = 'BREAK_AD'
                                        AND doc.get_doc_status_brief(agd2.ag_documents_id) = 'CONFIRMED'
                                        AND agd2.doc_date >= g_date_begin)) THEN
                               0
                              ELSE
                               1
                            END) = 1
                           /************добавлен статус Расторгнут, заявка №153093 Чернова Анастасия***************************/
                           /*********убран статус Расторгнут, заявка 220784 Синицина Ирина*****************/
                        AND ach.ag_contract_header_id = d.document_id
                        AND d.doc_status_ref_id = rf.doc_status_ref_id
                        AND rf.brief = 'CURRENT'
                        AND nvl(ach.is_new, 1) = 1
                     --AND ach.ag_contract_header_id = 104527004
                     /*AND ach.ag_contract_header_id IN
                                               (21819536, 21865453, 21865673, 21880627, 67779181,23133280
                     ,23140676
                     ,29978645
                     ,43950458
                     ,21865470
                     )*/
                      ORDER BY recr_lvl)
    LOOP
      pkg_trace.add_variable('ag_contract_header_id', managers.ag_contract_header_id);
      pkg_trace.trace(gc_pkg_name, c_proc_name, 'Нечало обработки агента');
    
      i         := i + 1;
      perc_done := (i / managers.cur_count) * 100;
      pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, perc_done);
    
      v_ops3_nbv := 0;
      IF managers.t_sales_channel_id IN (g_sc_grs_moscow, g_sc_grs_region)
      THEN
        v_volumes := get_volume_val_act(managers.ag_contract_header_id, 9);
      
        v_rl_nbv  := 0;
        v_all_nbv := v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                     v_volumes.get_volume(g_vt_ops_9);
      
      ELSIF managers.t_sales_channel_id IN (g_sc_dsf)
      THEN
        v_volumes := get_volume_val_act(managers.ag_contract_header_id);
        /**Изменения №159549************/
        /*v_ops3_nbv := v_volumes.get_volume(g_vt_OPS_3);*/
        /*************/
        v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                     v_volumes.get_volume(g_vt_fdep);
        v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_ops) +
                     v_volumes.get_volume(g_vt_ops_2) + v_volumes.get_volume(g_vt_avc) +
                     v_volumes.get_volume(g_vt_inv) + v_volumes.get_volume(g_vt_bank) +
                     v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
      
      ELSIF managers.t_sales_channel_id IN (g_sc_sas)
      THEN
        v_volumes := get_volume_val_act(managers.ag_contract_header_id);
      
        /*****Изменения №159549**********/
        IF managers.category_id = g_cat_td_id
        THEN
          v_ops3_nbv := v_volumes.get_volume(g_vt_ops_3);
        ELSE
          v_ops3_nbv := 0;
        END IF;
        /*****************/
        v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                     v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_fdep);
        v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                     v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                     v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_bank) +
                     v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
      
      ELSIF managers.t_sales_channel_id IN (g_sc_sas_2)
      THEN
        v_volumes := get_volume_val_act(managers.ag_contract_header_id);
      
        v_rl_nbv  := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                     v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_fdep);
        v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_inv) +
                     v_volumes.get_volume(g_vt_ops) + v_volumes.get_volume(g_vt_ops_2) +
                     v_volumes.get_volume(g_vt_avc) + v_volumes.get_volume(g_vt_bank) +
                     v_volumes.get_volume(g_vt_fdep) + v_volumes.get_volume(g_vt_ops_9);
      
      END IF;
    
      dml_ag_perfomed_work_act.insert_record(par_ag_roll_id              => g_roll_id
                                            ,par_ag_contract_header_id   => managers.ag_contract_header_id
                                            ,par_doc_templ_id            => g_dt_ag_perf_work_act
                                            ,par_volumes                 => v_volumes
																						,par_all_volume              => v_all_nbv
                                            ,par_date_calc               => SYSDATE
                                            ,par_ag_perfomed_work_act_id => v_apw_id);
    
      IF managers.t_sales_channel_id != g_sc_dsf
      THEN
        v_ksp := 100;
      ELSE
        v_ksp := nvl(get_ksp_0510(v_apw_id), 0);
      END IF;
    
      BEGIN
        SELECT agd.doc_date
          INTO v_dt_manag
          FROM ven_ag_contract_header agh
              ,ins.ag_documents       agd
              ,ins.ag_doc_type        adt
              ,ins.ag_props_change    apc
              ,ins.ag_props_type      apt
              ,ins.ag_contract        ag
              ,ins.document           d
              ,ins.doc_status_ref     rf
         WHERE agh.ag_contract_header_id = agd.ag_contract_header_id
           AND agd.ag_doc_type_id = adt.ag_doc_type_id
           AND adt.brief = 'CAT_CHG'
           AND agd.ag_documents_id = apc.ag_documents_id
           AND apc.ag_props_type_id = apt.ag_props_type_id
           AND apt.brief = 'CAT_PROP'
           AND agd.ag_documents_id = d.document_id
           AND d.doc_status_ref_id = rf.doc_status_ref_id
           AND rf.brief NOT IN ('PROJECT', 'CANCEL')
           AND agh.ag_contract_header_id = ag.contract_id
           AND ag.date_begin BETWEEN to_date('15.09.2011', 'dd.mm.yyyy') AND
               to_date('15.12.2011', 'dd.mm.yyyy')
           AND ag.ag_documents_id = agd.ag_documents_id
           AND apc.new_value = '3'
           AND agh.ag_contract_header_id = managers.ag_contract_header_id
           AND nvl(agh.is_new, 0) = 1
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_dt_manag := to_date('31.12.2999', 'DD.MM.YYYY');
      END;
    
      SELECT CASE
               WHEN managers.t_sales_channel_id = g_sc_dsf THEN
                (CASE
                  WHEN managers.category_id = 3
                       AND v_dt_manag <> to_date('31.12.2999', 'DD.MM.YYYY') THEN
                   (CASE
                     WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                          to_date('25.12.2011', 'DD.MM.YYYY') THEN
                      v_all_nbv
                     ELSE
                      v_rl_nbv
                   END)
                  WHEN managers.category_id = 2 THEN
                   (CASE
                     WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                          to_date('25.12.2011', 'DD.MM.YYYY') THEN
                      v_all_nbv
                     ELSE
                      v_rl_nbv
                   END)
                  ELSE
                   v_rl_nbv
                END)
               ELSE
                (CASE
                  WHEN g_date_begin BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
                       to_date('25.12.2011', 'DD.MM.YYYY') THEN
                   v_all_nbv
                  ELSE
                   v_rl_nbv
                END)
             END
        INTO v_rl_nbv
        FROM dual;
    
      v_activity_meetings_count := pkg_agn_control.get_activity_meetings_count(par_ag_countract_header_id => managers.ag_contract_header_id
                                                                              ,par_vedom_end_date         => g_date_end);
    
      v_level := nvl(pkg_tariff_calc.calc_coeff_val('LEVEL'
                                                   ,t_number_type(managers.t_sales_channel_id
                                                                 ,managers.category_id
                                                                 ,v_activity_meetings_count
                                                                 ,v_all_nbv + v_ops3_nbv
                                                                 ,v_ksp))
                    ,1);
    
      UPDATE ag_perfomed_work_act apw
         SET apw.ag_ksp                  = v_ksp
            ,apw.ag_level                = v_level
            ,apw.activity_meetings_count = v_activity_meetings_count
       WHERE apw.ag_perfomed_work_act_id = v_apw_id;
    
      pkg_trace.add_variable('g_roll_id', g_roll_id);
      pkg_trace.add_variable('v_ksp', v_ksp);
      pkg_trace.add_variable('v_level', v_level);
      pkg_trace.add_variable('v_activity_meetings_count', v_activity_meetings_count);
      pkg_trace.trace(gc_pkg_name, c_proc_name, 'Создан акт');
    
      FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                         ,arat.ag_rate_type_id ag_rate_type_id
                         ,atc.ag_category_agent_id
                         ,atc.t_sales_channel_id
                         ,COUNT(*) over(PARTITION BY 1) prem_count
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
                      AND atc.ag_category_agent_id = managers.category_id
                      AND atc.t_sales_channel_id = managers.t_sales_channel_id
                    ORDER BY atc.sort_order)
      LOOP
        dml_ag_perfom_work_det.insert_record(par_ag_perfomed_work_act_id => v_apw_id
                                            ,par_ag_rate_type_id         => prem.ag_rate_type_id
                                            ,par_summ                    => 0
                                            ,par_ag_perfom_work_det_id   => v_apw_det_id);
      
        g_commision := 0;
      
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
      
        UPDATE ag_perfomed_work_act a
           SET a.sum = a.sum + nvl(g_commision, 0)
         WHERE a.ag_perfomed_work_act_id = v_apw_id;
      END LOOP;
    
      --После каждого акта
      COMMIT;
    END LOOP;
  
    pkg_progress_util.set_progress_percent('CALC_COMMISS', g_roll_id, 100);
    pkg_trace.trace_procedure_end(gc_pkg_name, c_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || c_proc_name || SQLERRM || chr(10));
  END calc_vedom_250510;

  -- Author  : VESELEK
  -- Created : 01.10.2012
  -- Purpose : Расчет ведомости RLA
  PROCEDURE calc_vedom_rla(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name    VARCHAR2(25) := 'calc_vedom_RLA';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
    v_volumes    t_volume_val_o := t_volume_val_o(NULL);
    v_rl_nbv     NUMBER;
    v_all_nbv    NUMBER;
    v_ksp        NUMBER;
    v_level      PLS_INTEGER;
    perc_done    NUMBER := 0;
    perc_total   NUMBER := 0;
    last_perc    NUMBER := 0;
    i            PLS_INTEGER := 0;
    v_dt_manag   DATE;
    v_ops3_nbv   NUMBER := 0;
    gv_agent_id  NUMBER;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    pkg_progress_util.set_progress_percent('CALC_COMMISS_RLA', g_roll_id, 0);
    --1)Подготовим данные для расчета премий.
    pkg_agent_calculator.insertinfo('Начат расчет Актов');
  
    FOR prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                       ,arat.ag_rate_type_id ag_rate_type_id
                       ,atc.ag_category_agent_id
                       ,atc.t_sales_channel_id
                       ,COUNT(*) over(PARTITION BY 1) prem_count
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
                  ORDER BY atc.sort_order)
    LOOP
      pkg_agent_calculator.insertinfo('Начат расчет премии: ' || prem.calc_fun);
      i          := 0;
      perc_total := perc_done;
      --2)Отбор менеджеров/директоров
      FOR managers IN (SELECT ag_contract_header_id
                             ,COUNT(*) over(PARTITION BY 1) cur_count
                             ,t_sales_channel_id
                             ,category_id
                             ,recr_lvl
                         FROM (SELECT ach.ag_contract_header_id
                                     ,ach.t_sales_channel_id
                                     ,ac.category_id
                                     ,(SELECT MAX(LEVEL)
                                         FROM ag_contract acr
                                        START WITH acr.ag_contract_id = ac.ag_contract_id
                                       CONNECT BY PRIOR
                                                   acr.contract_id =
                                                   (SELECT acr2.contract_id
                                                      FROM ag_contract acr2
                                                     WHERE acr2.ag_contract_id = acr.contract_f_lead_id)
                                              AND SYSDATE BETWEEN acr.date_begin AND acr.date_end) recr_lvl
                                 FROM ag_contract        ac
                                     ,ag_contract_header ach
                                     ,ag_documents       agd
                                     ,ag_doc_type        adt
                                WHERE ac.contract_id = ach.ag_contract_header_id
                                  AND ach.ag_contract_header_id = nvl(NULL, ach.ag_contract_header_id)
                                  AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                                  AND ach.ag_contract_header_id = agd.ag_contract_header_id
                                  AND agd.ag_doc_type_id = adt.ag_doc_type_id
                                  AND adt.brief = 'NEW_AD'
                                     /*AND ach.date_block IS NULL*/
                                  AND doc.get_doc_status_brief(ach.ag_contract_header_id) NOT IN
                                      ('PROJECT', 'CANCEL')
                                  AND nvl(ach.is_new, 1) = 1
                                  AND ac.category_id = prem.ag_category_agent_id
                                  AND ach.t_sales_channel_id = prem.t_sales_channel_id
                               UNION
                               SELECT ach.ag_contract_header_id
                                     ,ach.t_sales_channel_id
                                     ,ac.category_id
                                     ,(SELECT MAX(LEVEL)
                                         FROM ag_contract acr
                                        START WITH acr.ag_contract_id = ac.ag_contract_id
                                       CONNECT BY PRIOR
                                                   acr.contract_id =
                                                   (SELECT acr2.contract_id
                                                      FROM ag_contract acr2
                                                     WHERE acr2.ag_contract_id = acr.contract_f_lead_id)
                                              AND SYSDATE BETWEEN acr.date_begin AND acr.date_end) recr_lvl
                                 FROM ag_contract_header ach
                                     ,ag_contract        ac
                                WHERE ach.last_ver_id = ac.ag_contract_id
                                  AND doc.get_doc_status_brief(ach.ag_contract_header_id) = 'CURRENT'
                                  AND nvl(ach.is_new, 1) = 0
                                  AND ach.ag_contract_header_id = 10146042)
                        ORDER BY recr_lvl)
      LOOP
        gv_agent_id := managers.ag_contract_header_id;
        i           := i + 1;
        perc_done   := (i / managers.cur_count) * 100 * 1 / prem.prem_count + perc_total;
        IF last_perc <> perc_done
        THEN
          last_perc := perc_done;
          pkg_progress_util.set_progress_percent('CALC_COMMISS_RLA', g_roll_id, perc_done);
        END IF;
      
        BEGIN
        
          SELECT apw.ag_perfomed_work_act_id
            INTO v_apw_id
            FROM ag_perfomed_work_act apw
           WHERE apw.ag_roll_id = g_roll_id
             AND apw.ag_contract_header_id = managers.ag_contract_header_id;
        
        EXCEPTION
          WHEN no_data_found THEN
          
            SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
          
            INSERT INTO ven_ag_perfomed_work_act
              (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, date_calc)
            VALUES
              (v_apw_id, g_roll_id, managers.ag_contract_header_id, SYSDATE);
          
            v_ksp := 100;
          
        END;
      
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
      
        UPDATE ag_perfomed_work_act a
           SET a.sum = a.sum + nvl(g_commision, 0)
         WHERE a.ag_perfomed_work_act_id = v_apw_id;
      
        --После каждого акта
        COMMIT;
      END LOOP;
    END LOOP;
    ins.pkg_ag_mng_dir_calc.rla_charging_units;
    pkg_progress_util.set_progress_percent('CALC_COMMISS_RLA', g_roll_id, 100);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; Агент-' || gv_agent_id || '/' ||
                              SQLERRM || chr(10));
  END calc_vedom_rla;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 13:40:57
  -- Purpose : Расчитывает ведомость ПмД по мотивации от 01/04/09
  PROCEDURE calc_vedom_010409(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name    VARCHAR2(20) := 'calc_vedom_010409';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    --1)Подготовим данные для расчета премий.
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег');
    prepare_cash;
    pkg_agent_calculator.insertinfo('Расчет объемов СГП');
    prepare_sgp;
  
    pkg_agent_calculator.insertinfo('Начат расчет Актов');
    --2)Отбор менеджеров/директоров
    FOR managers IN (SELECT ach.ag_contract_header_id
                           ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 4) ag_stat_hist_id
                           ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                           ,COUNT(*) over(PARTITION BY 1) cur_count
                       FROM ag_contract        ac
                           ,ag_contract_header ach
                           ,t_sales_channel    ts
                      WHERE ac.ag_contract_id =
                            pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end)
                        AND ach.ag_contract_header_id =
                            nvl2(p_ag_contract_header_id
                                ,p_ag_contract_header_id
                                ,ach.ag_contract_header_id)
                        AND ts.id = ach.t_sales_channel_id
                        AND ts.brief = 'MLM'
                        AND ac.category_id =
                            (SELECT art.agent_category_id
                               FROM ag_roll_type art
                              WHERE art.ag_roll_type_id = g_roll_type)
                        AND doc.get_doc_status_id(ach.last_ver_id) IN (g_st_curr, g_st_resume))
    LOOP
    
      pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header ' ||
                                     managers.ag_contract_header_id
                                    ,g_roll_id
                                    ,managers.cur_count);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,managers.ag_contract_header_id
        ,SYSDATE
        ,managers.ag_stat_hist_id
        ,managers.ag_status_id);
    
      g_commision := 0;
      g_sgp1      := 0;
      g_sgp2      := 0;
      --3) Отбор и расчет премий для менеджера
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
                      AND atc.ag_status_id = managers.ag_status_id
                      AND nvl(arat.enabled, 0) = 1)
      LOOP
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
        VALUES
          (v_apw_det_id, v_apw_id, prem.ag_rate_type_id, 0);
      
        g_rate_type_id := prem.ag_rate_type_id;
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sgp1 = g_sgp1
            ,a.sgp2 = g_sgp2
            ,a.sum  = g_commision
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
      --После каждого акта
      COMMIT;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_vedom_010409;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 13:52:00
  -- Purpose : Расччет ведомости ПмД по мотивации от 01/06/09
  PROCEDURE calc_vedom_010609(p_ag_contract_header_id PLS_INTEGER) IS
    proc_name    VARCHAR2(20) := 'calc_vedom_010609';
    v_apw_id     PLS_INTEGER;
    v_apw_det_id PLS_INTEGER;
  BEGIN
    pkg_ag_calc_admin.delete_perf_work_act(g_roll_id, p_ag_contract_header_id);
    --1)Подготовим данные для расчета премий.
    pkg_agent_calculator.insertinfo('Расчет объемов поступивших денег');
    prepare_cash_010609;
    pkg_agent_calculator.insertinfo('Расчет объемов СГП');
    prepare_sgp_010609;
    -- pkg_agent_calculator.InsertInfo('Расчет объемов КСП отключен');
    -- Prepare_KSP;
  
    pkg_agent_calculator.insertinfo('Начат расчет Актов');
    --2)Отбор менеджеров/директоров
    FOR managers IN (SELECT ach.ag_contract_header_id
                           ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 4) ag_stat_hist_id
                           ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                           ,COUNT(*) over(PARTITION BY 1) cur_count
                       FROM ag_contract        ac
                           ,ag_contract_header ach
                           ,t_sales_channel    ts
                      WHERE ac.ag_contract_id =
                            pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end)
                        AND ach.ag_contract_header_id =
                            nvl2(p_ag_contract_header_id
                                ,p_ag_contract_header_id
                                ,ach.ag_contract_header_id)
                        AND ts.id = ach.t_sales_channel_id
                        AND ts.brief = 'MLM'
                        AND ac.category_id =
                            (SELECT art.agent_category_id
                               FROM ag_roll_type art
                              WHERE art.ag_roll_type_id = g_roll_type)
                        AND doc.get_doc_status_id(ach.last_ver_id) IN (g_st_curr, g_st_resume))
    LOOP
    
      --  pkg_renlife_utils.time_elapsed('Начат расчет акта для ag_header '||managers.ag_contract_header_id , g_roll_id, managers.cur_count);
    
      SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
    
      INSERT INTO ven_ag_perfomed_work_act
        (ag_perfomed_work_act_id
        ,ag_roll_id
        ,ag_contract_header_id
        ,date_calc
        ,ag_stat_hist_id
        ,status_id)
      VALUES
        (v_apw_id
        ,g_roll_id
        ,managers.ag_contract_header_id
        ,SYSDATE
        ,managers.ag_stat_hist_id
        ,managers.ag_status_id);
    
      g_commision := 0;
      g_sgp1      := 0;
      g_sgp2      := 0;
      --3) Отбор и расчет премий для менеджера
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
                      AND atc.ag_status_id = managers.ag_status_id
                      AND nvl(arat.enabled, 0) = 1)
      LOOP
      
        --pkg_renlife_utils.time_elapsed('Начат расчет премии '||prem.calc_fun, g_roll_id, managers.cur_count);
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
        VALUES
          (v_apw_det_id, v_apw_id, prem.ag_rate_type_id, 0);
      
        g_rate_type_id := prem.ag_rate_type_id;
      
        EXECUTE IMMEDIATE prem.calc_fun
          USING v_apw_det_id;
      
      END LOOP;
    
      UPDATE ag_perfomed_work_act a
         SET a.sgp1 = g_sgp1
            ,a.sgp2 = g_sgp2
            ,a.sum  = g_commision
       WHERE a.ag_perfomed_work_act_id = v_apw_id;
      --После каждого акта
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END calc_vedom_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.12.2010 16:34:51
  -- Purpose : Получает объемы для менеджера
  -- p_vol_type - тип объемов 9 - количество продаж
  -- иначе сумма продаж
  -- p_department - ограничить объемы по агенству
  -- p_date  - ограничить объемы по дате
  FUNCTION get_volume_val_act
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_vol_type              PLS_INTEGER DEFAULT 1
   ,p_department_id         PLS_INTEGER DEFAULT NULL
   ,p_date                  DATE DEFAULT NULL
  ) RETURN t_volume_val_o IS
    v_volume  t_volume_val_o := t_volume_val_o(NULL);
    proc_name VARCHAR2(25) := 'Get_volume_val_act';
  BEGIN
  
    FOR r IN (SELECT CASE
                       WHEN p_vol_type = 9 THEN
                        COUNT(*)
                       ELSE
                       /*изменения №174670*/
                        SUM(CASE
                              WHEN av.ag_volume_type_id IN (g_vt_life, g_vt_inv, g_vt_fdep)
                                   AND insurer.contact_id =
                                   (SELECT agh.agent_id
                                          FROM ins.ag_contract_header agh
                                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id)
                                   AND insurer.contact_id =
                                   (SELECT agh.agent_id
                                          FROM ins.ag_contract_header agh
                                         WHERE agh.ag_contract_header_id = tv.ag_contract_header_id) THEN
                               0
                              WHEN av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2, g_vt_ops_3, g_vt_ops_9)
                                   AND (SELECT upper(anv.fio)
                                          FROM ins.ag_npf_volume_det anv
                                         WHERE anv.ag_volume_id = av.ag_volume_id) =
                                   (SELECT upper(c.obj_name_orig)
                                          FROM ins.ag_contract_header agh
                                              ,ins.contact            c
                                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                                           AND c.contact_id = agh.agent_id)
                                   AND (SELECT upper(anv.fio)
                                          FROM ins.ag_npf_volume_det anv
                                         WHERE anv.ag_volume_id = av.ag_volume_id) =
                                   (SELECT upper(c.obj_name_orig)
                                          FROM ins.ag_contract_header agh
                                              ,ins.contact            c
                                         WHERE agh.ag_contract_header_id = tv.ag_contract_header_id
                                           AND c.contact_id = agh.agent_id) THEN
                               0
                              ELSE
                               (CASE
                                 WHEN nvl(av.index_delta_sum, 0) <> 0 THEN
                                  (av.index_delta_sum * (CASE
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                                ,ins.t_product    prod
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id = prod.product_id
                                             AND prod.brief IN ('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD')) > 0
                                         AND av.ins_period = 3
                                         AND (SELECT COUNT(*)
                                                FROM ins.ag_contract ag
                                               WHERE ag.contract_id = tv.ag_contract_header_id
                                                 AND ag.category_id = g_cat_td_id
                                                 AND g_date_end BETWEEN ag.date_begin AND ag.date_end) = 0 THEN
                                     0.3
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                                ,ins.t_product    prod
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id = prod.product_id
                                             AND prod.brief IN ('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD')) > 0
                                         AND av.ins_period = 5
                                         AND (SELECT COUNT(*)
                                                FROM ins.ag_contract ag
                                               WHERE ag.contract_id = tv.ag_contract_header_id
                                                 AND ag.category_id = g_cat_td_id
                                                 AND g_date_end BETWEEN ag.date_begin AND ag.date_end) = 0 THEN
                                     0.2
                                    ELSE
                                     av.nbv_coef
                                  END)
                                  
                                  )
                                 ELSE
                                  (av.trans_sum * (CASE
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                                ,ins.t_product    prod
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id = prod.product_id
                                             AND prod.brief IN ('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD')) > 0
                                         AND av.ins_period = 3
                                         AND (SELECT COUNT(*)
                                                FROM ins.ag_contract ag
                                               WHERE ag.contract_id = tv.ag_contract_header_id
                                                 AND ag.category_id = g_cat_td_id
                                                 AND g_date_end BETWEEN ag.date_begin AND ag.date_end) = 0 THEN
                                     0.3
                                    WHEN (SELECT COUNT(*)
                                            FROM ins.p_pol_header ph
                                                ,ins.t_product    prod
                                           WHERE ph.policy_header_id = av.policy_header_id
                                             AND ph.product_id = prod.product_id
                                             AND prod.brief IN ('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD')) > 0
                                         AND av.ins_period = 5
                                         AND (SELECT COUNT(*)
                                                FROM ins.ag_contract ag
                                               WHERE ag.contract_id = tv.ag_contract_header_id
                                                 AND ag.category_id = g_cat_td_id
                                                 AND g_date_end BETWEEN ag.date_begin AND ag.date_end) = 0 THEN
                                     0.2
                                    ELSE
                                     av.nbv_coef
                                  END))
                               END)
                            END)
                     END amt
                    ,
                     /**/av.ag_volume_type_id
                FROM temp_vol_calc      tv
                    ,ag_volume          av
                    ,ag_contract_header ach
                    ,
                     /*изменения №174670, найдем Страхователя*/(SELECT ph.policy_header_id
                            ,ppc.contact_id
                        FROM ins.p_pol_header       ph
                            ,ins.p_policy           pol
                            ,ins.p_policy_contact   ppc
                            ,ins.t_contact_pol_role polr
                       WHERE ph.last_ver_id = pol.policy_id
                         AND pol.policy_id = ppc.policy_id
                         AND ppc.contact_policy_role_id =
                             polr.id
                         AND polr.brief = 'Страхователь') insurer
              /**/
               WHERE tv.ag_volume_id = av.ag_volume_id
                 AND av.is_nbv = 1
                 AND ach.ag_contract_header_id = av.ag_contract_header_id
                 AND (decode(av.ag_volume_type_id
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
                            ,g_vt_ops_3
                            ,av.date_begin
                            ,g_vt_ops_9
                            ,av.date_begin
                            ,g_vt_bank
                            ,av.date_begin
                            ,g_date_end) >= p_date OR p_date IS NULL)
                 AND (ach.agency_id = p_department_id OR p_department_id IS NULL)
                 AND tv.ag_contract_header_id = p_ag_contract_header_id
                 AND NOT EXISTS (SELECT NULL
                        FROM ag_roll              ar
                            ,ag_perfomed_work_act apw
                            ,ag_perfom_work_det   apde
                            ,ag_perf_work_vol     apv
                       WHERE 1 = 1
                         AND ar.ag_roll_header_id != g_roll_header_id
                         AND ar.ag_roll_id = apw.ag_roll_id
                         AND apw.ag_contract_header_id = p_ag_contract_header_id
                         AND apw.ag_perfomed_work_act_id = apde.ag_perfomed_work_act_id
                         AND apde.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                         AND apv.ag_volume_id = av.ag_volume_id)
                    /**чтобы объем сибук, еврокомерц и еще какая то хрень не попадала тер дирам в RL_VOL****/
                 AND (CASE
                       WHEN av.ag_contract_header_id IN (26101892, 25873698, 30707667)
                            AND tv.ag_contract_header_id IN (21813000, 21822653, 24763393) THEN
                        0
                       ELSE
                        1
                     END) = 1
                    /*изменения №174670*/
                 AND av.policy_header_id = insurer.policy_header_id(+)
              /**/
               GROUP BY av.ag_volume_type_id)
    LOOP
    
      v_volume.set_volume(r.ag_volume_type_id, r.amt);
    
    END LOOP;
  
    RETURN(v_volume);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_volume_val_act;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 16:48:09
  -- Purpose : Получает сумму объема для МиД
  -- DEPRICATED - учет объемов перенесен на акт

  FUNCTION get_volume_val
  (
    p_ag_contract_header_id PLS_INTEGER
   ,vol_type                PLS_INTEGER
   ,p_department_id         PLS_INTEGER DEFAULT NULL
  ) RETURN NUMBER IS
    v_vol_amt  NUMBER;
    proc_name  VARCHAR2(25) := 'Get_volume_val';
    v_vol_type PLS_INTEGER;
  BEGIN
  
    IF vol_type = 9
    THEN
      v_vol_type := 2;
    ELSE
      v_vol_type := vol_type;
    END IF;
  
    SELECT CASE
             WHEN vol_type = 9 THEN
              COUNT(*)
             ELSE
              SUM(CASE
                    WHEN nvl(av.index_delta_sum, 0) <> 0 THEN
                     (av.index_delta_sum * av.nbv_coef)
                    ELSE
                     (av.trans_sum * av.nbv_coef)
                  END)
           END
      INTO v_vol_amt
      FROM temp_vol_calc      tv
          ,ag_volume          av
          ,ag_contract_header ach
     WHERE tv.ag_volume_id = av.ag_volume_id
       AND av.is_nbv = 1
       AND ach.ag_contract_header_id = av.ag_contract_header_id
       AND (ach.agency_id = p_department_id OR p_department_id IS NULL)
       AND tv.ag_contract_header_id = p_ag_contract_header_id
       AND NOT EXISTS (SELECT NULL
              FROM ag_roll              ar
                  ,ag_perfomed_work_act apw
                  ,ag_perfom_work_det   apde
                  ,ag_perf_work_vol     apv
             WHERE 1 = 1
               AND ar.ag_roll_header_id != g_roll_header_id
               AND ar.ag_roll_id = apw.ag_roll_id
               AND apw.ag_contract_header_id = p_ag_contract_header_id
               AND apw.ag_perfomed_work_act_id = apde.ag_perfomed_work_act_id
               AND apde.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
               AND apv.ag_volume_id = av.ag_volume_id)
       AND (av.ag_volume_type_id = v_vol_type OR
           (v_vol_type = -1 AND av.ag_volume_type_id != g_vt_nonevol));
  
    RETURN(v_vol_amt);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_volume_val;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:14:02
  -- Purpose : Получает сумму поступивших денег, сумму премии и заполняет детализацию
  FUNCTION get_cash(p_ag_work_det_id NUMBER) RETURN t_cash IS
    v_cash    t_cash;
    proc_name VARCHAR2(20) := 'Get_cash';
    v_attrs   pkg_tariff_calc.attr_type;
    --v_ag_ch_id         PLS_INTEGER:=1;
    v_ag_header_id    PLS_INTEGER;
    v_commission      NUMBER;
    v_payed_commision NUMBER := 0;
    i                 PLS_INTEGER;
    j                 PLS_INTEGER;
    y                 PLS_INTEGER;
    TYPE t_ag_perf_work_dpol IS TABLE OF ven_ag_perfom_work_dpol%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_payd IS TABLE OF ven_ag_perf_work_pay_doc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_tran IS TABLE OF ven_ag_perf_work_trans%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_perf_work_dpol t_ag_perf_work_dpol;
    v_ag_perf_work_payd t_ag_perf_work_payd;
    v_ag_perf_work_tran t_ag_perf_work_tran;
  
    v_ag_rate_type_id PLS_INTEGER;
    v_policy_id       PLS_INTEGER := 0;
    v_pay_doc_id      PLS_INTEGER := 0;
    v_epg_doc_id      PLS_INTEGER := 0;
  BEGIN
    v_cash.cash_amount    := 0;
    v_cash.commiss_amount := 0;
    SELECT --pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end),
     apw.ag_contract_header_id
    ,apd.ag_rate_type_id
      INTO --v_ag_ch_id ,
           v_ag_header_id
          ,v_ag_rate_type_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_work_det_id;
  
    FOR cash IN (SELECT tc.*
                   FROM temp_cash_calc tc
                       ,p_policy       pp
                       ,p_pol_header   ph
                  WHERE tc.ag_contract_id = v_ag_header_id
                    AND pp.policy_id = tc.policy_id
                    AND pp.pol_header_id = ph.policy_header_id
                    AND (v_ag_rate_type_id <> 241 ---'ADD_WG'
                        OR
                        ( --tc.policy_agent_part=3
                         tc.year_of_insurance = 1 AND ((tc.lvl <= 2 AND tc.agent_status_id = g_agst_rop) OR
                         tc.agent_status_id <> g_agst_rop) AND
                         tc.t_payment_term_id IN (g_pt_monthly, g_pt_quater) AND
                         greatest(ph.start_date
                                  ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) BETWEEN
                         '26.08.2009' AND '25.12.2009'))
                    AND ph.product_id IN (SELECT tc.criteria_1
                                            FROM t_prod_coef      tc
                                                ,t_prod_coef_type tpc
                                           WHERE tpc.brief = 'Products_in_calc'
                                             AND tpc.t_prod_coef_type_id = tc.t_prod_coef_type_id
                                             AND tc.criteria_2 = 2)
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
      
        v_ag_perf_work_dpol(i).ag_perfom_work_det_id := p_ag_work_det_id;
        v_ag_perf_work_dpol(i).policy_id := cash.active_policy_id;
        v_ag_perf_work_dpol(i).policy_status_id := cash.active_pol_status_id;
        v_ag_perf_work_dpol(i).ag_contract_header_ch_id := cash.current_agent;
        v_ag_perf_work_dpol(i).ag_status_id := cash.agent_status_id;
        v_ag_perf_work_dpol(i).policy_agent_part := 1;
        v_ag_perf_work_dpol(i).summ := 0;
        v_ag_perf_work_dpol(i).check_1 := cash.check_1;
        v_ag_perf_work_dpol(i).check_1 := cash.check_2;
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
      v_attrs.delete;
      v_attrs(1) := cash.agent_status_id;
      v_attrs(2) := v_ag_rate_type_id;
    
      SELECT sq_ag_perf_work_trans.nextval
        INTO v_ag_perf_work_tran(y).ag_perf_work_trans_id
        FROM dual;
    
      v_ag_perf_work_tran(y).ag_perf_work_pay_doc_id := v_ag_perf_work_payd(j).ag_perf_work_pay_doc_id;
      v_ag_perf_work_tran(y).trans_id := cash.trans_id;
      v_ag_perf_work_tran(y).t_prod_line_option_id := cash.t_prod_line_option_id;
      v_ag_perf_work_tran(y).sum_premium := cash.trans_amount;
      v_ag_perf_work_tran(y).is_indexing := cash.is_indexing;
      v_ag_perf_work_tran(y).sav := pkg_tariff_calc.calc_coeff_val('Work_group_percent', v_attrs, 2) / 100;
    
      IF g_roll_num <> 1
      THEN
        SELECT nvl(SUM(apt.sum_commission), 0)
          INTO v_payed_commision
          FROM ag_roll_header       arh
              ,ag_roll              ar
              ,ag_perfomed_work_act apw
              ,ag_perfom_work_det   apd
              ,ag_perfom_work_dpol  apdp
              ,ag_perf_work_pay_doc appd
              ,ag_perf_work_trans   apt
         WHERE arh.ag_roll_header_id = g_roll_header_id
              -- AND arh.ag_roll_type_id = g_roll_type
           AND apd.ag_rate_type_id = g_rate_type_id
           AND apw.ag_contract_header_id = v_ag_header_id
           AND ar.ag_roll_header_id = arh.ag_roll_header_id
           AND apw.ag_roll_id = ar.ag_roll_id
           AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
           AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
           AND appd.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
           AND appd.ag_perf_work_pay_doc_id = apt.ag_perf_work_pay_doc_id
           AND apt.trans_id = cash.trans_id;
        v_commission := nvl(cash.trans_amount, 0) * v_ag_perf_work_tran(y).sav - v_payed_commision;
      ELSE
        v_commission := nvl(cash.trans_amount, 0) * v_ag_perf_work_tran(y).sav;
      END IF;
    
      -- IF cash.check_1=0 OR cash.check_2=0 THEN v_commission:=0; END IF;
    
      v_ag_perf_work_tran(y).sum_commission := v_commission;
    
      v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + nvl(cash.trans_amount, 0);
    
      v_cash.cash_amount    := v_cash.cash_amount + nvl(cash.trans_amount, 0);
      v_cash.commiss_amount := v_cash.commiss_amount + v_commission;
    
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
  FUNCTION get_sgp
  (
    p_ag_work_det_id        PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER DEFAULT NULL
  ) RETURN NUMBER IS
    v_sgp      NUMBER := 0;
    proc_name  VARCHAR2(20) := 'Get_SGP';
    v_ag_ch_id PLS_INTEGER := 1;
    i          PLS_INTEGER;
    j          PLS_INTEGER;
    y          PLS_INTEGER;
  
    TYPE t_ag_perf_work_dpol IS TABLE OF ven_ag_perfom_work_dpol%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_payd IS TABLE OF ven_ag_perf_work_pay_doc%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_dcov IS TABLE OF ven_ag_perf_work_dcover%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE t_ag_perf_work_tran IS TABLE OF ven_ag_perf_work_trans%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_perf_work_dpol t_ag_perf_work_dpol;
    v_ag_perf_work_payd t_ag_perf_work_payd;
    v_ag_perf_work_dcov t_ag_perf_work_dcov;
    v_ag_perf_work_tran t_ag_perf_work_tran;
  
    v_policy_id  PLS_INTEGER := 0;
    v_pay_doc_id PLS_INTEGER := 0;
    v_epg_doc_id PLS_INTEGER := 0;
  BEGIN
    IF p_ag_contract_header_id IS NULL
    THEN
      SELECT apw.ag_contract_header_id
      --pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end)
        INTO v_ag_ch_id
        FROM ag_perfomed_work_act apw
            ,ag_perfom_work_det   apd
       WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apd.ag_perfom_work_det_id = p_ag_work_det_id;
    ELSE
      v_ag_ch_id := p_ag_contract_header_id;
      --;pkg_agent_1.get_status_by_date(p_ag_contract_header_id, g_date_end);
    END IF;
  
    FOR sgp IN (SELECT *
                  FROM temp_sgp_calc tc
                 WHERE tc.ag_contract_id = v_ag_ch_id
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
        v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + nvl(sgp.brutto_prem, 0);
      
        v_sgp := v_sgp + nvl(sgp.brutto_prem, 0) * nvl(sgp.sgp_koef, 0);
      END IF;
    END LOOP;
  
    FORALL i IN 1 .. v_ag_perf_work_dpol.count
      INSERT INTO ven_ag_perfom_work_dpol VALUES v_ag_perf_work_dpol (i);
  
    FORALL i IN 1 .. v_ag_perf_work_payd.count
      INSERT INTO ven_ag_perf_work_pay_doc VALUES v_ag_perf_work_payd (i);
  
    FORALL i IN 1 .. v_ag_perf_work_dcov.count
      INSERT INTO ven_ag_perf_work_dcover VALUES v_ag_perf_work_dcov (i);
  
    v_ag_perf_work_dpol.delete;
    v_ag_perf_work_payd.delete;
    v_ag_perf_work_dcov.delete;
  
    --Получение SGP для групповых договоров
    FOR cash IN (SELECT tc.policy_id
                       ,tc.policy_status_id
                       ,tc.epg_payment_id
                       ,tc.epg_status_id
                       ,tc.pay_payment_id
                       ,tc.pay_bank_doc_id
                       ,tc.trans_id
                       ,CASE
                          WHEN tc.t_payment_term_id = g_pt_monthly
                               AND tc.policy_agent_part = 3 THEN
                           tc.trans_amount * 3
                          ELSE
                           tc.trans_amount
                        END trans_amount
                       ,tc.t_prod_line_option_id
                       ,tc.current_agent
                       ,tc.agent_status_id
                       ,tc.active_policy_id
                       ,tc.active_pol_status_id
                       ,tc.t_payment_term_id
                       ,tc.insurance_period
                       ,tc.is_indexing
                       ,tc.check_1
                       ,tc.check_2
                       ,tc.policy_agent_part
                       ,ph.product_id
                   FROM temp_cash_calc   tc
                       ,p_pol_header     ph
                       ,p_policy         pp
                       ,ac_payment       bd
                       ,ac_payment_templ acpt
                  WHERE tc.ag_contract_id = v_ag_ch_id
                    AND pp.policy_id = tc.policy_id
                    AND ph.policy_header_id = pp.pol_header_id
                    AND bd.payment_id = tc.pay_bank_doc_id
                    AND bd.payment_templ_id = acpt.payment_templ_id
                    AND (tc.is_group = 1 OR (g_roll_type_brief NOT IN ('NDIR', 'NMGR') AND
                        ((tc.t_payment_term_id IN (g_pt_quater, g_pt_monthly) AND
                        ph.start_date > '29.05.2009') OR tc.is_indexing = 1)))
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
                                                                                                  ,2
                                                                                                  ,to_char(g_date_end
                                                                                                          ,'YYYYMMDD')));
        ELSE
          v_ag_perf_work_dpol(i).policy_agent_part := 1;
        END IF;
      
        v_ag_perf_work_dpol(i).ag_perfom_work_det_id := p_ag_work_det_id;
        v_ag_perf_work_dpol(i).policy_id := cash.active_policy_id;
        v_ag_perf_work_dpol(i).policy_status_id := cash.active_pol_status_id;
        v_ag_perf_work_dpol(i).ag_contract_header_ch_id := cash.current_agent;
        v_ag_perf_work_dpol(i).ag_status_id := cash.agent_status_id;
        v_ag_perf_work_dpol(i).summ := 0;
        v_ag_perf_work_dpol(i).pay_term := cash.t_payment_term_id;
        v_ag_perf_work_dpol(i).insurance_period := cash.insurance_period;
        v_ag_perf_work_dpol(i).check_1 := cash.check_1;
        v_ag_perf_work_dpol(i).check_2 := cash.check_2;
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
      v_ag_perf_work_tran(y).sav := 1;
      v_ag_perf_work_tran(y).sum_commission := cash.trans_amount * v_ag_perf_work_dpol(i)
                                              .policy_agent_part;
      v_ag_perf_work_tran(y).is_indexing := cash.is_indexing;
    
      IF (cash.check_1 = 1 AND cash.check_2 = 1)
         OR cash.t_payment_term_id = g_pt_nonrecurring
      THEN
        v_ag_perf_work_dpol(i).summ := v_ag_perf_work_dpol(i).summ + nvl(cash.trans_amount, 0);
      
        v_sgp := v_sgp + nvl(cash.trans_amount * v_ag_perf_work_dpol(i).policy_agent_part, 0);
      END IF;
    END LOOP;
  
    FORALL i IN 1 .. v_ag_perf_work_dpol.count
      INSERT INTO ven_ag_perfom_work_dpol VALUES v_ag_perf_work_dpol (i);
  
    FORALL i IN 1 .. v_ag_perf_work_payd.count
      INSERT INTO ven_ag_perf_work_pay_doc VALUES v_ag_perf_work_payd (i);
  
    FORALL i IN 1 .. v_ag_perf_work_tran.count
      INSERT INTO ven_ag_perf_work_trans VALUES v_ag_perf_work_tran (i);
    RETURN(v_sgp);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END get_sgp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.06.2010 16:11:24
  -- Purpose : Получение КСП для менеджера
  FUNCTION get_ksp_0510(p_ag_perf_work_act_id PLS_INTEGER) RETURN NUMBER IS
    proc_name      VARCHAR2(25) := 'Get_KSP_0510';
    v_ksp          NUMBER;
    v_ag_ch_id     PLS_INTEGER := 1;
    v_ag_ksp       PLS_INTEGER;
    v_expected_fee NUMBER := 0;
    v_recived_cash NUMBER := 0;
    --v_ag_rate_type      PLS_INTEGER;
    v_ag_perf_act PLS_INTEGER;
    i             PLS_INTEGER;
    TYPE t_ag_ksp_det IS TABLE OF ven_ag_ksp_det%ROWTYPE INDEX BY PLS_INTEGER;
  
    v_ag_ksp_det t_ag_ksp_det;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,apw.ag_perfomed_work_act_id
      INTO v_ag_ch_id
          ,v_ag_perf_act
      FROM ag_perfomed_work_act apw
     WHERE apw.ag_perfomed_work_act_id = p_ag_perf_work_act_id;
  
    SELECT sq_ag_ksp.nextval INTO v_ag_ksp FROM dual;
  
    FOR ksp IN (SELECT * FROM temp_ksp_calc tc WHERE tc.contract_header_id = v_ag_ch_id)
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
    
    END LOOP;
  
    IF v_expected_fee = 0
    THEN
      --v_ksp := 100;
      /*******заявка №153126 Чернова Анастасия*********/
      v_ksp := 0;
    ELSE
      v_ksp := ROUND(v_recived_cash / v_expected_fee * 100, 2);
      IF v_ksp > 100
      THEN
        v_ksp := 100;
      END IF;
    END IF;
  
    INSERT INTO ven_ag_ksp (ag_ksp_id, document, ksp_value) VALUES (v_ag_ksp, v_ag_perf_act, v_ksp);
  
    FORALL i IN 1 .. v_ag_ksp_det.count
      INSERT INTO ven_ag_ksp_det VALUES v_ag_ksp_det (i);
  
    RETURN(v_ksp);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_ksp_0510;

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
  
    FOR ksp IN (SELECT * FROM temp_ksp_calc tc WHERE tc.agent_contract_header = v_ag_ch_id)
    LOOP
      i := v_ag_ksp_det.count + 1;
      v_ag_ksp_det(i).ag_ksp_id := v_ag_ksp;
      v_ag_ksp_det(i).ag_contract_header_id := ksp.contract_header_id;
      v_ag_ksp_det(i).active_policy_status_id := ksp.active_policy_status_id;
      v_ag_ksp_det(i).last_policy_status_id := ksp.last_policy_status_id;
      v_ag_ksp_det(i).policy_header_id := ksp.policy_header_id;
      v_ag_ksp_det(i).policy_agent := ksp.agent_contract_header;
      v_ag_ksp_det(i).decline_date := ksp.decline_date;
      v_ag_ksp_det(i).conclude_policy_sgp := ksp.conclude_policy_sgp;
      v_ag_ksp_det(i).prolong_policy_sgp := ksp.prolong_policy_sgp;
    
      v_conclude_sgp := v_conclude_sgp + ksp.conclude_policy_sgp;
      v_prolong_sgp  := v_prolong_sgp + ksp.prolong_policy_sgp;
    END LOOP;
  
    IF v_conclude_sgp = 0
       OR v_prolong_sgp = 0
    THEN
      v_ksp := 0;
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
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END get_ksp;

  -- По какой то причине в отличие от КСП здесь работает долго
  -- Возможно плохо справляется с вложеным курсором
  -- может быть план запроса за счет кучи ветвлений "кривой"
  /*
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 10:46:58
  -- Purpose : Подготовка объема для МиД по  мотивации 25.05.2010
  PROCEDURE Prepare_volume
  IS
     proc_name VARCHAR2(25):='Prepare_volume';
  
     CURSOR vol_cur IS
     SELECT agv.ag_volume_id,
            CURSOR (
            SELECT aat.ag_contract_header_id, LEVEL
              FROM ag_agent_tree aat
             START WITH aat.ag_contract_header_id = nvl(apd.ag_contract_header_id, agv.ag_contract_header_id)
               AND CASE WHEN avt.brief IN ('NPF','SOFI')
                        THEN arh.date_end
                   ELSE CASE WHEN greatest(agv.payment_date,
                                           NVL(agv.conclude_date,agv.payment_date))<'26.04.2010'
                             THEN arh.date_end
                        ELSE agv.payment_date
                        END
                   END
                   BETWEEN aat.date_begin AND aat.date_end
           CONNECT BY PRIOR aat.ag_parent_header_id = aat.ag_contract_header_id
                        AND CASE WHEN avt.brief IN ('NPF','SOFI')
                                 THEN arh.date_end
                            ELSE CASE WHEN greatest(agv.payment_date,
                                                    NVL(agv.conclude_date,agv.payment_date))<'26.04.2010'
                                      THEN arh.date_end
                                 ELSE agv.payment_date
                                 END
                            END
                            BETWEEN aat.date_begin AND aat.date_end
            ) tree_cur
       FROM ag_volume agv,
            ag_roll ar,
            ag_roll_header arh,
            ins.ag_volume_type avt,
            ag_prev_dog apd
      WHERE agv.ag_volume_type_id = avt.ag_volume_type_id
        --AND agv.is_nbv = 1
        AND arh.date_end <= g_date_end
        AND avt.brief IN ('RL','NPF','SOFI')
        AND agv.ag_roll_id = ar.ag_roll_id
        AND ar.ag_roll_header_id = arh.ag_roll_header_id
        AND apd.ag_prev_header_id (+) = agv.ag_contract_header_id;
  
     TYPE t_tmp_vol_calc IS TABLE OF TEMP_VOL_CALC%ROWTYPE INDEX BY PLS_INTEGER;
     agent_tree_cur        SYS_REFCURSOR;
     i                     PLS_INTEGER;
     v_temp_vol_calc       t_tmp_vol_calc;
     v_volume_id           PLS_INTEGER;
     v_contract_header_id  PLS_INTEGER;
     v_level               PLS_INTEGER;
  BEGIN
  \*
  TODO: owner="alexey.katkevich" created="26.07.2010"
  text="Уменьшить первоначальный объем ДО отбора дерева"
  *\
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_VOL_CALC';
  
  \*
  TODO: owner="alexey.katkevich" priority="2 - Medium" created="26.07.2010"
  text="Сделать проверку правильности подчинености при отборе объемов"
  *\
  
    OPEN vol_cur;
    LOOP
       FETCH vol_cur
        INTO v_volume_id,
             agent_tree_cur;
       EXIT WHEN vol_cur%NOTFOUND;
       LOOP
          FETCH agent_tree_cur INTO v_contract_header_id, v_level;
          EXIT WHEN agent_tree_cur%NOTFOUND;
          i:=v_temp_vol_calc.COUNT+1;
          v_temp_vol_calc(i).ag_contract_header_id := v_contract_header_id;
          v_temp_vol_calc(i).ag_volume_id := v_volume_id;
          v_temp_vol_calc(i).lvl := v_level;
       END LOOP;
       CLOSE agent_tree_cur;
    END LOOP;
  
     DECLARE
       errors NUMBER;
       dml_errors EXCEPTION;
       PRAGMA EXCEPTION_INIT(dml_errors, -24381);
     BEGIN
         FORALL i IN 1..v_temp_vol_calc.COUNT SAVE EXCEPTIONS
                INSERT INTO temp_vol_calc VALUES v_temp_vol_calc(i);
     EXCEPTION WHEN dml_errors THEN
       errors := SQL%BULK_EXCEPTIONS.COUNT;
       FOR i IN 1..errors LOOP
  
         IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE<> 1 THEN
           RAISE_APPLICATION_ERROR(-20099,
                            SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
         END IF;
       END LOOP;
     END;
  
  EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении '||proc_name||SQLERRM);
  END Prepare_volume;
  */

  -- Выше вариант с вложенным курсором
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 10:46:58
  -- Purpose : Подготовка объема для МиД по  мотивации 25.05.2010
  PROCEDURE prepare_volume IS
    proc_name VARCHAR2(25) := 'Prepare_volume';
  
    TYPE t_tmp_vol_calc IS TABLE OF temp_vol_calc%ROWTYPE INDEX BY PLS_INTEGER;
    i               PLS_INTEGER;
    v_temp_vol_calc t_tmp_vol_calc;
  BEGIN
    /*
    TODO: owner="alexey.katkevich" created="26.07.2010"
    text="Уменьшить первоначальный объем ДО отбора дерева"
    */
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_VOL_CALC';
  
    /*
    TODO: owner="alexey.katkevich" priority="2 - Medium" created="26.07.2010"
    text="Сделать проверку правильности подчинености при отборе объемов"
    */
  
    FOR vol_cur IN (SELECT agv.ag_volume_id
                          ,nvl(apd.ag_contract_header_id, agv.ag_contract_header_id) ach
                          ,nvl(agv.conclude_date, agv.payment_date) p_date
                          ,agv.payment_date
                          ,nvl(ar.date_end, arh.date_end) arh_de
                          ,avt.brief
                      FROM ag_volume          agv
                          ,ag_roll            ar
                          ,ag_roll_header     arh
                          ,ins.ag_volume_type avt
                          ,ag_prev_dog        apd
                          ,ins.ag_roll_type   art
                     WHERE agv.ag_volume_type_id = avt.ag_volume_type_id
                          --AND agv.is_nbv = 1
                          --AND arh.date_end <= g_date_end
                       AND nvl(ar.date_end, arh.date_end) BETWEEN g_date_begin AND g_date_end
                       AND arh.ag_roll_type_id = art.ag_roll_type_id
                       AND art.brief = 'CASH_VOL'
                       AND avt.brief IN ('RL'
                                        ,'NPF'
                                        ,'NPF01'
                                        ,'NPF02'
                                        ,'SOFI'
                                        ,'AVCP'
                                        ,'INV'
                                        ,'NPF03'
                                        ,'BANK'
                                        ,'FDep'
                                        ,'NPF(MARK9)')
                       AND agv.ag_roll_id = ar.ag_roll_id
                       AND ar.ag_roll_header_id = arh.ag_roll_header_id
                       AND apd.ag_prev_header_id(+) = agv.ag_contract_header_id
                    
                    )
    LOOP
    
      FOR atree IN (SELECT aat.ag_contract_header_id
                          ,LEVEL
                      FROM ag_agent_tree aat
                     START WITH aat.ag_contract_header_id = vol_cur.ach
                            AND CASE
                                  WHEN vol_cur.brief IN ('NPF'
                                                        ,'NPF01'
                                                        ,'NPF02'
                                                        ,'NPF03'
                                                        ,'SOFI'
                                                        ,'AVCP'
                                                        ,'BANK'
                                                        ,'NPF(MARK9)') THEN
                                   vol_cur.arh_de
                                  ELSE
                                   CASE
                                     WHEN greatest(vol_cur.payment_date, vol_cur.p_date) < '26.04.2010' THEN
                                      vol_cur.arh_de
                                     ELSE
                                      vol_cur.payment_date
                                   END
                                END BETWEEN aat.date_begin AND aat.date_end
                    CONNECT BY PRIOR aat.ag_parent_header_id = aat.ag_contract_header_id
                           AND CASE
                                 WHEN vol_cur.brief IN ('NPF'
                                                       ,'NPF01'
                                                       ,'NPF02'
                                                       ,'NPF03'
                                                       ,'SOFI'
                                                       ,'AVCP'
                                                       ,'BANK'
                                                       ,'NPF(MARK9)') THEN
                                  vol_cur.arh_de
                                 ELSE
                                  CASE
                                    WHEN greatest(vol_cur.payment_date, vol_cur.p_date) < '26.04.2010' THEN
                                     vol_cur.arh_de
                                    ELSE
                                     vol_cur.payment_date
                                  END
                               END BETWEEN aat.date_begin AND aat.date_end)
      LOOP
      
        i := v_temp_vol_calc.count + 1;
        v_temp_vol_calc(i).ag_contract_header_id := atree.ag_contract_header_id;
        v_temp_vol_calc(i).ag_volume_id := vol_cur.ag_volume_id;
        v_temp_vol_calc(i).lvl := atree.level;
        /*****************************/
      /*
                                                                  create table tmp#_volume_mnd
                                                                  (p_ag_volume_id NUMBER,
                                                                   p_ag_contract_header_id NUMBER,
                                                                   pp_date DATE,
                                                                   p_payment_date DATE,
                                                                   p_arh_de DATE,
                                                                   p_brief VARCHAR2(255),
                                                                   p_atree_ag_header_id NUMBER,
                                                                   p_vol_cur_volume_id NUMBER,
                                                                   p_atree_level NUMBER
                                                                  );
                                                                  */
      /*INSERT INTO tmp#_volume_mnd
                                                                  (p_ag_volume_id,p_ag_contract_header_id,pp_date,p_payment_date,p_arh_de,p_brief,
                                                                  p_atree_ag_header_id,p_vol_cur_volume_id,p_atree_level)
                                                                  VALUES (vol_cur.ag_volume_id,
                                                                          vol_cur.ach,
                                                                          vol_cur.p_date,
                                                                          vol_cur.payment_date,
                                                                          vol_cur.arh_de,
                                                                          vol_cur.brief,
                                                                          atree.ag_contract_header_id,
                                                                          vol_cur.ag_volume_id,
                                                                          atree.level);*/
      /****************************/
      END LOOP;
    
      DECLARE
        errors NUMBER;
        dml_errors EXCEPTION;
        PRAGMA EXCEPTION_INIT(dml_errors, -24381);
      BEGIN
        FORALL i IN 1 .. v_temp_vol_calc.count SAVE EXCEPTIONS
          INSERT INTO temp_vol_calc VALUES v_temp_vol_calc (i);
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
    
      v_temp_vol_calc.delete;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END prepare_volume;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.06.2010 15:57:56
  -- Purpose : Подготовка объемов КСП
  PROCEDURE prepare_ksp_0510 IS
    proc_name VARCHAR2(25) := 'Prepare_KSP_0510';
  
    CURSOR main_policy IS
      SELECT akd.policy_header_id
            ,akd.ksp_per_begin
            ,akd.ksp_per_end
            ,akd.fee_expected
            ,akd.cash_recived
            ,akd.fee_count
            ,akd.ag_contract_header_id
            ,akd.last_policy_status_id
            ,akd.decline_date
            ,CURSOR (SELECT CASE
                             WHEN NOT EXISTS (SELECT apd.ag_contract_header_id
                                     FROM ag_prev_dog apd
                                    WHERE apd.ag_prev_header_id = ac.contract_id
                                      AND apd.ag_contract_header_id IS NOT NULL) THEN
                              (SELECT ach.ag_contract_header_id
                                 FROM ag_contract_header ach
                                WHERE 1 = 1
                                  AND ach.ag_contract_header_id = ac.contract_id
                                  AND nvl(ach.is_new, 1) = 1)
                             ELSE
                              (SELECT apd.ag_contract_header_id
                                 FROM ag_prev_dog apd
                                WHERE apd.ag_prev_header_id = ac.contract_id)
                           END rh
                      FROM ag_contract ac
                    --                     WHERE LEVEL <> 1
                     START WITH ac.contract_id = akd.ag_contract_header_id
                            AND ac.ag_contract_id =
                                pkg_agent_1.get_status_by_date(ac.contract_id
                                                              ,nvl(akd.decline_date, g_date_end))
                    CONNECT BY nocycle
                     ac.contract_id = PRIOR
                               (SELECT ac1.contract_id
                                  FROM ag_contract ac1
                                 WHERE ac1.ag_contract_id = ac.contract_leader_id)
                           AND ac.ag_contract_id =
                               pkg_agent_1.get_status_by_date(ac.contract_id
                                                             ,nvl(akd.decline_date, g_date_end))
                           AND ac.category_id <= 50) col
        FROM ag_roll_header       arh
            ,ag_roll              ar
            ,ag_perfomed_work_act apw
            ,ag_ksp               ak
            ,ag_ksp_det           akd
       WHERE arh.ag_roll_header_id = g_ksp_vedom
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND apw.ag_perfomed_work_act_id = ak.document
         AND ak.ag_ksp_id = akd.ag_ksp_id;
  
    agent_tree_cur SYS_REFCURSOR;
    i              PLS_INTEGER;
    TYPE t_tmp_ksp_calc IS TABLE OF temp_ksp_calc%ROWTYPE INDEX BY PLS_INTEGER;
    v_temp_ksp_calc t_tmp_ksp_calc;
  
    v_contract_header_id    PLS_INTEGER;
    v_policy_header_id      PLS_INTEGER;
    v_ksp_begin             DATE;
    v_ksp_end               DATE;
    v_fee_expected          NUMBER;
    v_cash_recived          NUMBER;
    v_fee_count             PLS_INTEGER;
    v_agent_contract_header PLS_INTEGER;
    v_last_policy_status_id PLS_INTEGER;
    v_decline_date          DATE;
  
  BEGIN
  
    /*
    TODO: owner="alexey.katkevich" priority="3 - Low" created="26.07.2010"
    text="Посмотреть отобр объемов КСП в плане оптимизаци
      --Возможно следует сначала вставить записи по не расторгнутым ДС
    -- а потом довставлять отсатки
    "
    */
  
    -- Получение дерева для каждого договора
    OPEN main_policy;
    LOOP
      FETCH main_policy
        INTO v_policy_header_id
            ,v_ksp_begin
            ,v_ksp_end
            ,v_fee_expected
            ,v_cash_recived
            ,v_fee_count
            ,v_agent_contract_header
            ,v_last_policy_status_id
            ,v_decline_date
            ,agent_tree_cur;
      EXIT WHEN main_policy%NOTFOUND;
      LOOP
        FETCH agent_tree_cur
          INTO v_contract_header_id;
        EXIT WHEN agent_tree_cur%NOTFOUND;
        i := v_temp_ksp_calc.count + 1;
        v_temp_ksp_calc(i).contract_header_id := v_contract_header_id;
        v_temp_ksp_calc(i).policy_header_id := v_policy_header_id;
        v_temp_ksp_calc(i).ksp_begin := v_ksp_begin;
        v_temp_ksp_calc(i).ksp_end := v_ksp_end;
        v_temp_ksp_calc(i).fee_expected := v_fee_expected;
        v_temp_ksp_calc(i).cash_recived := v_cash_recived;
        v_temp_ksp_calc(i).fee_count := v_fee_count;
        v_temp_ksp_calc(i).agent_contract_header := v_agent_contract_header;
        v_temp_ksp_calc(i).last_policy_status_id := v_last_policy_status_id;
        v_temp_ksp_calc(i).decline_date := v_decline_date;
      
      END LOOP;
      CLOSE agent_tree_cur;
    END LOOP;
  
    DECLARE
      errors NUMBER;
      dml_errors EXCEPTION;
      PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    BEGIN
      FORALL i IN 1 .. v_temp_ksp_calc.count SAVE EXCEPTIONS
        INSERT INTO temp_ksp_calc VALUES v_temp_ksp_calc (i);
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
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END prepare_ksp_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:09:29
  -- Purpose : Подготовка данных по поступишвим деньгам
  PROCEDURE prepare_cash IS
    proc_name  VARCHAR2(20) := 'Prepare_cash';
    v_ag_ch_id PLS_INTEGER;
    CURSOR policy_agent
    (
      pol_header_id NUMBER
     ,par_date      DATE
    ) IS(
      SELECT DISTINCT ag_contract_header_id
        FROM p_policy_agent      pa
            ,policy_agent_status pas
       WHERE pa.date_start <= par_date
         AND pa.date_end > par_date
         AND pa.status_id = pas.policy_agent_status_id
         AND pas.brief <> 'ERROR'
         AND pa.policy_header_id = pol_header_id);
  BEGIN
    DELETE FROM temp_cash_calc;
    FOR pay_doc IN (SELECT pp.policy_id policy
                          ,pp.pol_header_id
                          ,tp.is_group
                          ,ph.policy_id active_pol
                          ,doc.get_doc_status_id(ph.policy_id) active_pol_st
                          ,doc.get_doc_status_id(pp.policy_id) policy_st
                          ,epg.payment_id epg
                          ,doc.get_doc_status_id(epg.payment_id) epg_st
                          ,pay_doc.payment_id pd
                          ,
                           --  acpt.brief,
                           last_day(pay_doc.due_date) pay_month
                          ,CASE
                             WHEN acpt.brief = 'ПП' THEN
                              dso.doc_set_off_id
                             ELSE
                              bank_doc.doc_set_off_id
                           END set_off_doc
                          ,CASE
                             WHEN acpt.brief = 'ПП' THEN
                              pay_doc.payment_id
                             ELSE
                              bank_doc.child_doc_id
                           END bank_doc
                      FROM p_policy pp
                          ,p_pol_header ph
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
                              FROM doc_doc     dd2
                                  ,doc_set_off dso2
                             WHERE dso2.parent_doc_id = dd2.child_id
                               AND doc.get_doc_status_id(dd2.child_id) = g_st_paid) bank_doc
                     WHERE pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                          --  AND tp.product_id IN (SELECT criteria_1 FROM t_prod_coef WHERE t_prod_coef_type_id = 7005)
                       AND dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND dt.doc_templ_id = epg.doc_templ_id
                       AND doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                           (g_st_readycancel, g_st_stoped, g_st_berak)
                       AND doc.get_doc_status_brief(epg.payment_id) = 'PAID'
                       AND dt.brief = 'PAYMENT'
                       AND (MONTHS_BETWEEN(epg.plan_date, ph.start_date) < 12 OR
                           (EXISTS (SELECT 1
                                       FROM p_pol_addendum_type ppa
                                           ,t_addendum_type     ta
                                      WHERE ta.t_addendum_type_id = ppa.p_pol_addendum_type_id
                                        AND ta.brief = 'INDEXATING'
                                        AND ppa.p_policy_id = pp.policy_id) AND
                            MONTHS_BETWEEN(epg.plan_date, pp.start_date) < 12))
                       AND epg.plan_date <= g_date_end -- Ким
                       AND pay_doc.reg_date <= g_date_end --Гусев, Ким
                          --  AND tp.is_group = 1
                          -- AND pp.pol_header_id = 10230627
                       AND ph.start_date >= '01.04.2009' --Гусев, Ким
                       AND doc.get_doc_status_id(ph.policy_id) <> g_st_revision --Гусев, Ким
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_doc.payment_id
                       AND pay_doc.due_date >= '01.04.2009'
                       AND doc.get_doc_status_id(pay_doc.payment_id) <> g_st_annulated
                       AND acpt.payment_templ_id = pay_doc.payment_templ_id
                       AND acpt.brief IN ('ПП', 'A7', 'PD4')
                       AND pay_doc.payment_id = bank_doc.parent_id(+)
                       AND NOT EXISTS (SELECT 1
                              FROM ag_sgp_det asd
                                  ,ag_sgp     asg
                                  ,p_policy   pp1
                             WHERE pp1.policy_id = asd.policy_id
                               AND asg.ag_sgp_id = asd.ag_sgp_id
                               AND asg.sgp_type_id = 2
                               AND pp1.pol_header_id = ph.policy_header_id))
    LOOP
    
      OPEN policy_agent(pay_doc.pol_header_id, pay_doc.pay_month);
      FETCH policy_agent
        INTO v_ag_ch_id;
      IF policy_agent%NOTFOUND
      THEN
        v_ag_ch_id := pkg_renlife_utils.get_p_agent_sale(pay_doc.pol_header_id);
      
        FOR mng_vol IN (SELECT ac.ag_contract_id
                              ,ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, pay_doc.pay_month, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> 2
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, pay_doc.pay_month)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_rop --Рук. - РОП
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_reg_dir --Рук Регион.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_tdir --Рук Тер.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, pay_doc.pay_month) =
                                   ac.ag_contract_id)
        LOOP
          FOR trans IN (SELECT t.trans_id
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
            BEGIN
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
                ,lvl
                ,current_agent
                ,ag_contract_id
                ,agent_status_id
                ,is_group
                ,active_policy_id
                ,active_pol_status_id)
              VALUES
                (pay_doc.policy
                ,pay_doc.policy_st
                ,pay_doc.epg
                ,pay_doc.epg_st
                ,pay_doc.pd
                ,pay_doc.bank_doc
                ,trans.trans_id
                ,trans.trans_amount
                ,trans.prod_line_option
                ,mng_vol.lvl
                ,v_ag_ch_id
                ,mng_vol.ag_contract_id
                ,mng_vol.ag_status_id
                ,pay_doc.is_group
                ,pay_doc.active_pol
                ,pay_doc.active_pol_st);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
      END IF;
      LOOP
        EXIT WHEN policy_agent%NOTFOUND;
      
        FOR mng_vol IN (SELECT ac.ag_contract_id
                              ,ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, pay_doc.pay_month, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> 2
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, pay_doc.pay_month)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_rop --Рук. - РОП
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_reg_dir --Рук Регион.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_tdir --Рук Тер.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, pay_doc.pay_month) =
                                   ac.ag_contract_id)
        LOOP
          FOR trans IN (SELECT t.trans_id
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
            BEGIN
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
                ,lvl
                ,current_agent
                ,ag_contract_id
                ,agent_status_id
                ,is_group
                ,active_policy_id
                ,active_pol_status_id)
              VALUES
                (pay_doc.policy
                ,pay_doc.policy_st
                ,pay_doc.epg
                ,pay_doc.epg_st
                ,pay_doc.pd
                ,pay_doc.bank_doc
                ,trans.trans_id
                ,trans.trans_amount
                ,trans.prod_line_option
                ,mng_vol.lvl
                ,v_ag_ch_id
                ,mng_vol.ag_contract_id
                ,mng_vol.ag_status_id
                ,pay_doc.is_group
                ,pay_doc.active_pol
                ,pay_doc.active_pol_st);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
        FETCH policy_agent
          INTO v_ag_ch_id;
      END LOOP;
      CLOSE policy_agent;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_cash;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 09.06.2009 16:10:54
  -- Purpose : Подтовка данных по СГП за период
  PROCEDURE prepare_sgp IS
    proc_name  VARCHAR2(20) := 'Prepare_SGP';
    v_ag_ch_id PLS_INTEGER;
    v_attrs    pkg_tariff_calc.attr_type;
    v_koef     NUMBER;
    CURSOR policy_agent
    (
      pol_header_id NUMBER
     ,par_date      DATE
    ) IS(
      SELECT DISTINCT ag_contract_header_id
        FROM p_policy_agent      pa
            ,policy_agent_status pas
       WHERE pa.date_start <= par_date
         AND pa.date_end > par_date
         AND pa.status_id = pas.policy_agent_status_id
         AND pas.brief <> 'ERROR'
         AND pa.policy_header_id = pol_header_id);
  BEGIN
    DELETE FROM temp_sgp_calc;
    FOR pay_doc IN (SELECT ph.policy_id active_policy
                          ,doc.get_doc_status_id(ph.policy_id) active_pol_st
                          ,pp.policy_id
                          ,pp.pol_header_id
                          ,ph.product_id
                          ,pt.id pay_term
                          ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) insurance_period
                          ,doc.get_doc_status_id(pp.policy_id) policy_st
                          ,epg.payment_id epg
                          ,pt.number_of_payments
                          ,ph.fund_id
                          ,(SELECT DISTINCT last_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pd
                      FROM p_policy        pp
                          ,p_pol_header    ph
                          ,t_product       tp
                          ,doc_doc         dd
                          ,ven_ac_payment  epg
                          ,doc_templ       epg_dt
                          ,t_payment_terms pt
                     WHERE pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND nvl(tp.is_group, 0) = 0
                       AND doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                           (g_st_readycancel, g_st_stoped, g_st_berak)
                          -- AND pp.pol_header_id =10770919
                          --AND pp.policy_id = 10251142
                       AND ph.start_date >= '01.04.2009' --Гусев, Ким
                       AND doc.get_doc_status_id(ph.policy_id) <> g_st_revision --Ким
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
                       AND /*GREATEST(*/
                           (SELECT MAX(pay_d1.due_date) --Изменения в приказе Ким!!!!! 29/06/2009
                              FROM doc_set_off    dso
                                  ,ven_ac_payment pay_d1
                                  ,doc_templ      pay_temp
                             WHERE dso.parent_doc_id = epg.payment_id
                               AND dso.child_doc_id = pay_d1.payment_id
                               AND doc.get_doc_status_id(dso.doc_set_off_id) <> g_st_annulated
                               AND pay_d1.reg_date >= '01.04.2009'
                               AND pay_d1.doc_templ_id = pay_temp.doc_templ_id
                               AND pay_temp.brief IN ('A7', 'PD4', 'ПП')) /*, ph.start_date)*/
                           BETWEEN g_date_begin AND g_date_end
                       AND ph.policy_header_id NOT IN
                           (SELECT pp1.pol_header_id --Нет в пердидущих расчетах сгп1
                              FROM ag_roll_type         art
                                  ,ven_ag_roll_header   arh
                                  ,ag_roll              ar
                                  ,ag_perfomed_work_act apw
                                  ,ag_perfom_work_det   apwd
                                  ,ag_rate_type         agrt
                                  ,t_sgp_type           tsgp
                                  ,ag_perfom_work_dpol  apd
                                  ,p_policy             pp1
                             WHERE art.ag_roll_type_id = g_roll_type
                               AND ar.ag_roll_header_id <> g_roll_header_id
                               AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                               AND arh.ag_roll_header_id = art.ag_roll_type_id
                               AND ar.ag_roll_header_id = arh.ag_roll_header_id
                               AND apw.ag_roll_id = ar.ag_roll_id
                               AND apwd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                               AND apwd.ag_rate_type_id = agrt.ag_rate_type_id
                               AND agrt.t_sgp_type_id = tsgp.t_sgp_type_id
                               AND tsgp.name = 'СГП 1'
                               AND apd.ag_perfom_work_det_id = apwd.ag_perfom_work_det_id
                               AND pp1.policy_id = apd.policy_id))
    LOOP
      v_attrs.delete;
    
      v_attrs(1) := pay_doc.product_id;
      v_attrs(2) := pay_doc.pay_term;
      v_attrs(3) := pay_doc.insurance_period; --год страхования
      v_attrs(4) := 2; --Премии
      v_attrs(5) := to_char(g_date_end, 'YYYYMMDD');
      v_koef := nvl(pkg_tariff_calc.calc_coeff_val('SGP_koeff', v_attrs, 5), 0);
    
      OPEN policy_agent(pay_doc.pol_header_id, g_date_end);
      FETCH policy_agent
        INTO v_ag_ch_id;
      IF policy_agent%NOTFOUND
      THEN
        v_ag_ch_id := pkg_renlife_utils.get_p_agent_sale(pay_doc.pol_header_id);
      
        FOR mng_vol IN (SELECT ac.ag_contract_id
                              ,ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> 2
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, g_date_end)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_rop --Рук. - РОП
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_reg_dir --Рук Регион.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_tdir --Рук Тер.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, g_date_end) =
                                   ac.ag_contract_id)
        LOOP
          FOR cover IN (SELECT ROUND(pc.fee *
                                     acc.get_cross_rate_by_id(1
                                                             ,pay_doc.fund_id
                                                             ,122
                                                             ,(SELECT MAX(pay_d1.reg_date)
                                                                FROM doc_set_off    dso
                                                                    ,ven_ac_payment pay_d1
                                                                    ,doc_templ      pay_temp
                                                               WHERE dso.parent_doc_id = pay_doc.epg
                                                                 AND dso.child_doc_id =
                                                                     pay_d1.payment_id
                                                                 AND pay_d1.doc_templ_id =
                                                                     pay_temp.doc_templ_id
                                                                 AND pay_temp.brief IN
                                                                     ('A7', 'PD4', 'ПП')))
                                    ,2) * pay_doc.number_of_payments /**v_koef*/ brutto_prem
                              , --теперь умножаем в get_SGP
                               pc.p_cover_id
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
                ,lvl
                ,ag_contract_id
                ,current_agent
                ,agent_status_id
                ,active_policy_id
                ,active_pol_status_id
                ,sgp_koef)
              VALUES
                (pay_doc.policy_id
                ,pay_doc.policy_st
                ,pay_doc.epg
                ,pay_doc.pd
                ,cover.brutto_prem
                ,cover.p_cover_id
                ,cover.t_prod_line_option
                ,mng_vol.lvl
                ,mng_vol.ag_contract_id
                ,v_ag_ch_id
                ,mng_vol.ag_status_id
                ,pay_doc.active_policy
                ,pay_doc.active_pol_st
                ,v_koef);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
      END IF;
      LOOP
        EXIT WHEN policy_agent%NOTFOUND;
        FOR mng_vol IN (SELECT ac.ag_contract_id
                              ,ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> 2
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, g_date_end)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_rop --Рук. - РОП
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_reg_dir --Рук Регион.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_tdir --Рук Тер.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, g_date_end) =
                                   ac.ag_contract_id)
        LOOP
          FOR cover IN (SELECT ROUND(pc.fee *
                                     acc.get_cross_rate_by_id(1
                                                             ,pay_doc.fund_id
                                                             ,122
                                                             ,(SELECT MAX(pay_d1.reg_date)
                                                                FROM doc_set_off    dso
                                                                    ,ven_ac_payment pay_d1
                                                                    ,doc_templ      pay_temp
                                                               WHERE dso.parent_doc_id = pay_doc.epg
                                                                 AND dso.child_doc_id =
                                                                     pay_d1.payment_id
                                                                 AND pay_d1.doc_templ_id =
                                                                     pay_temp.doc_templ_id
                                                                 AND pay_temp.brief IN
                                                                     ('A7', 'PD4', 'ПП')))
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
                ,lvl
                ,ag_contract_id
                ,current_agent
                ,agent_status_id
                ,active_policy_id
                ,active_pol_status_id
                ,sgp_koef)
              VALUES
                (pay_doc.policy_id
                ,pay_doc.policy_st
                ,pay_doc.epg
                ,pay_doc.pd
                ,cover.brutto_prem
                ,cover.p_cover_id
                ,cover.t_prod_line_option
                ,mng_vol.lvl
                ,mng_vol.ag_contract_id
                ,v_ag_ch_id
                ,mng_vol.ag_status_id
                ,pay_doc.active_policy
                ,pay_doc.active_pol_st
                ,v_koef);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
        FETCH policy_agent
          INTO v_ag_ch_id;
      END LOOP;
      CLOSE policy_agent;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_sgp;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 20.07.2009 15:32:15
  -- Purpose : Расчет объемов поступивших денег по мотивации от 010609
  PROCEDURE prepare_cash_010609 IS
    proc_name  VARCHAR2(25) := 'Prepare_cash_010609';
    v_ag_ch_id PLS_INTEGER;
    v_trans_id PLS_INTEGER;
    i          PLS_INTEGER;
  
    TYPE t_temp_cash_calc IS TABLE OF temp_cash_calc%ROWTYPE INDEX BY PLS_INTEGER;
    v_temp_cash_calc t_temp_cash_calc;
  
    CURSOR policy_agent
    (
      pol_header_id NUMBER
     ,par_date      DATE
    ) IS(
      SELECT DISTINCT ag_contract_header_id
        FROM p_policy_agent      pa
            ,policy_agent_status pas
       WHERE pa.date_start <= par_date
         AND pa.date_end > par_date
         AND pa.status_id = pas.policy_agent_status_id
         AND pas.brief <> 'ERROR'
         AND pa.policy_header_id = pol_header_id);
  BEGIN
    DELETE FROM temp_cash_calc;
    FOR pay_doc IN (SELECT pp.policy_id policy
                          ,pp.pol_header_id
                          ,pp.payment_term_id
                          ,tp.is_group
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
                                             epg.plan_date) = 1 THEN
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
                          ,ph.policy_id active_pol
                          ,doc.get_doc_status_id(ph.policy_id, g_status_date) active_pol_st
                          ,doc.get_doc_status_id(pp.policy_id, g_status_date) policy_st
                          ,epg.payment_id epg
                          ,ph.product_id
                          ,CEIL(MONTHS_BETWEEN(epg.plan_date + 1, ph.start_date) / 12) year_of_insurance
                          ,CEIL(MONTHS_BETWEEN((SELECT pp_a.end_date
                                                 FROM p_policy pp_a
                                                WHERE pp_a.policy_id = ph.policy_id)
                                              ,ph.start_date) / 12) insurance_period
                          ,doc.get_doc_status_id(epg.payment_id) epg_st
                          ,pay_doc.payment_id pd
                          ,pkg_ag_calc_admin.get_opertation_month_date(pay_doc.due_date, 2) pay_month
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
                                     WHEN COUNT(ac.ag_contract_id) > 0 THEN
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
                          ,(SELECT CASE
                                     WHEN COUNT(va.as_assured_id) > 0 THEN
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
                      FROM p_policy pp
                          ,p_pol_header ph
                          ,t_product tp
                          ,doc_doc dd
                          ,ven_ac_payment epg
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
                     WHERE pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND dd.parent_id = pp.policy_id
                       AND dd.child_id = epg.payment_id
                       AND (ph.product_id <> 7687 OR ph.start_date >= '01.03.2010')
                       AND acpt.payment_templ_id = pay_doc.payment_templ_id
                       AND epg.doc_templ_id = g_dt_epg_doc
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
                       AND ((ph.start_date >= '01.04.2009' AND
                           MONTHS_BETWEEN(epg.plan_date, ph.start_date) < 12 AND NOT EXISTS
                            (SELECT NULL
                                FROM ag_sgp_det asd
                                    ,ag_sgp     asg
                                    ,p_policy   pp1
                               WHERE pp1.policy_id = asd.policy_id
                                 AND asg.ag_sgp_id = asd.ag_sgp_id
                                 AND asg.sgp_type_id = 2
                                 AND pp1.pol_header_id = ph.policy_header_id)) OR
                           (MONTHS_BETWEEN(epg.plan_date, pp.start_date) < 12 AND EXISTS
                            (SELECT NULL
                                FROM p_pol_addendum_type ppa
                                    ,t_addendum_type     ta
                               WHERE ta.t_addendum_type_id = ppa.t_addendum_type_id
                                 AND ta.brief = 'INDEXING2'
                                 AND ppa.p_policy_id = pp.policy_id)))
                       AND epg.plan_date <= g_date_end + 1
                       AND pay_doc.due_date <= CASE
                             WHEN pp.payment_term_id = g_pt_monthly
                                  AND nvl(bank_doc.brief, acpt.brief) IN ('ПП_ПС', 'ПП_ОБ') THEN
                              last_day(g_date_end) + 10
                             ELSE
                              g_date_end
                           END
                          --decode(pp.PAYMENT_TERM_ID, g_pt_monthly, last_day(g_date_end)+5, g_date_end)
                       AND ph.start_date <= g_date_end + 1
                       AND pay_doc.due_date >= '01.04.2009'
                          --AND pp.pol_header_id = 15384335
                       AND (SELECT doc.get_doc_status_id(pp1.policy_id, g_status_date)
                              FROM p_policy pp1
                             WHERE pp1.pol_header_id = ph.policy_header_id
                               AND pp1.version_num = 1) <> g_st_revision
                       AND dso.parent_doc_id = epg.payment_id
                       AND dso.child_doc_id = pay_doc.payment_id
                       AND doc.get_doc_status_id(pay_doc.payment_id) <> g_st_annulated
                       AND acpt.brief IN ('ПП', 'ПП_ПС', 'ПП_ОБ', 'A7', 'PD4')
                          --AND pay_doc.doc_templ_id IN (g_dt_pay_doc, g_dt_pd4_doc, g_dt_a7_doc)
                       AND pay_doc.payment_id = bank_doc.parent_id(+))
    LOOP
    
      OPEN policy_agent(pay_doc.pol_header_id, pay_doc.pay_month);
      FETCH policy_agent
        INTO v_ag_ch_id;
      IF policy_agent%NOTFOUND
      THEN
        v_ag_ch_id := pkg_renlife_utils.get_p_agent_sale(pay_doc.pol_header_id);
      
        FOR mng_vol IN (SELECT ac.contract_id ag_contract_id
                              , --раньше была версия, но это порочная практика!!!!
                               ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, pay_doc.pay_month, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> g_ct_agent
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, pay_doc.pay_month)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_rop --Рук. - РОП
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_reg_dir --Рук Регион.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_tdir --Рук Тер.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, pay_doc.pay_month) =
                                   ac.ag_contract_id)
        LOOP
        
          FOR trans IN (SELECT t.trans_id
                              ,tplo.id prod_line_option
                              ,CASE
                                 WHEN pay_doc.idx = 1 THEN
                                  t.trans_amount *
                                  pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tplo.id, 3)
                                 ELSE
                                  t.trans_amount
                               END trans_amount
                          FROM oper               o
                              ,trans              t
                              ,p_cover            pc
                              ,t_prod_line_option tplo
                         WHERE o.oper_id = t.oper_id
                           AND t.trans_templ_id IN (g_tt_agentpaysetoff
                                                   ,g_tt_inspremapaid
                                                   ,g_tt_insprempaid
                                                   ,g_tt_prempaidagent)
                           AND t.obj_uro_id = pc.p_cover_id
                           AND pc.t_prod_line_option_id = tplo.id
                           AND o.document_id = pay_doc.set_off_doc
                           AND tplo.description <> 'Административные издержки')
          LOOP
            --Нет расчета по этой проводке по новой мотивации
            --Раньше это было одинм запросом через NOT exists
            --Но потому почему то начало сбоить в плане производительности
            SELECT COUNT(apwt.trans_id)
              INTO v_trans_id
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
               AND apwt.trans_id = trans.trans_id;
            IF v_trans_id = 0
            THEN
            
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
              v_temp_cash_calc(i).lvl := mng_vol.lvl;
              v_temp_cash_calc(i).current_agent := v_ag_ch_id;
              v_temp_cash_calc(i).ag_contract_id := mng_vol.ag_contract_id;
              v_temp_cash_calc(i).agent_status_id := mng_vol.ag_status_id;
              v_temp_cash_calc(i).is_group := pay_doc.is_group;
              v_temp_cash_calc(i).active_policy_id := pay_doc.active_pol;
              v_temp_cash_calc(i).active_pol_status_id := pay_doc.active_pol_st;
              v_temp_cash_calc(i).t_payment_term_id := pay_doc.payment_term_id;
              v_temp_cash_calc(i).is_indexing := pay_doc.idx;
              v_temp_cash_calc(i).insurance_period := pay_doc.insurance_period;
              v_temp_cash_calc(i).year_of_insurance := pay_doc.year_of_insurance;
              v_temp_cash_calc(i).check_1 := pay_doc.insuer_not_agent;
              v_temp_cash_calc(i).check_2 := pay_doc.assured_not_agent;
              --                            IF pay_doc.payment_term_id =g_pt_monthly AND pay_doc.epg_num<2 THEN
              v_temp_cash_calc(i).policy_agent_part := pay_doc.direct_debt_coef;
              --                          ELSE v_temp_cash_calc(i).POLICY_AGENT_PART:=1;
              --                        END IF;
            
            END IF;
          END LOOP;
        END LOOP;
      END IF;
      LOOP
        EXIT WHEN policy_agent%NOTFOUND;
      
        FOR mng_vol IN (SELECT ac.contract_id ag_contract_id
                              , --раньше была версия, но это порочная практика!!!!
                               ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, pay_doc.pay_month, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> g_ct_agent
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, pay_doc.pay_month)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_rop --Рук. - РОП
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_reg_dir --Рук Регион.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                         ,pay_doc.pay_month
                                                                         ,2) = g_agst_tdir --Рук Тер.Дир
                                   AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                   ,pay_doc.pay_month
                                                                                   ,2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, pay_doc.pay_month) =
                                   ac.ag_contract_id)
        LOOP
          FOR trans IN (SELECT t.trans_id
                              ,tplo.id prod_line_option
                              ,CASE
                                 WHEN pay_doc.idx = 1 THEN
                                  t.trans_amount *
                                  pkg_renlife_utils.get_indexing_summ(pay_doc.epg, tplo.id, 3)
                                 ELSE
                                  t.trans_amount
                               END trans_amount
                          FROM oper               o
                              ,trans              t
                              ,p_cover            pc
                              ,t_prod_line_option tplo
                         WHERE o.oper_id = t.oper_id
                           AND t.trans_templ_id IN (g_tt_agentpaysetoff
                                                   ,g_tt_inspremapaid
                                                   ,g_tt_insprempaid
                                                   ,g_tt_prempaidagent)
                           AND t.obj_uro_id = pc.p_cover_id
                           AND pc.t_prod_line_option_id = tplo.id
                           AND o.document_id = pay_doc.set_off_doc
                           AND tplo.description <> 'Административные издержки')
          LOOP
            --Нет расчета по этой проводке по новой мотивации
            --Раньше это было одинм запросом через NOT exists
            --Но потому почему то начало сбоить в плане производительности
            SELECT COUNT(apwt.trans_id)
              INTO v_trans_id
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
               AND apwt.trans_id = trans.trans_id;
          
            IF v_trans_id = 0
            THEN
            
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
              v_temp_cash_calc(i).lvl := mng_vol.lvl;
              v_temp_cash_calc(i).current_agent := v_ag_ch_id;
              v_temp_cash_calc(i).ag_contract_id := mng_vol.ag_contract_id;
              v_temp_cash_calc(i).agent_status_id := mng_vol.ag_status_id;
              v_temp_cash_calc(i).is_group := pay_doc.is_group;
              v_temp_cash_calc(i).active_policy_id := pay_doc.active_pol;
              v_temp_cash_calc(i).active_pol_status_id := pay_doc.active_pol_st;
              v_temp_cash_calc(i).t_payment_term_id := pay_doc.payment_term_id;
              v_temp_cash_calc(i).is_indexing := pay_doc.idx;
              v_temp_cash_calc(i).insurance_period := pay_doc.insurance_period;
              v_temp_cash_calc(i).year_of_insurance := pay_doc.year_of_insurance;
              v_temp_cash_calc(i).check_1 := pay_doc.insuer_not_agent;
              v_temp_cash_calc(i).check_2 := pay_doc.assured_not_agent;
              v_temp_cash_calc(i).policy_agent_part := pay_doc.direct_debt_coef;
            
            END IF;
          END LOOP;
        END LOOP;
        FETCH policy_agent
          INTO v_ag_ch_id;
      END LOOP;
      CLOSE policy_agent;
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
  END prepare_cash_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 20.07.2009 18:03:39
  -- Purpose : Получение объемов СГП для расчета премий от 01/06/2009
  PROCEDURE prepare_sgp_010609 IS
    proc_name  VARCHAR2(20) := 'Prepare_SGP_010609';
    v_ag_ch_id PLS_INTEGER;
    v_attrs    pkg_tariff_calc.attr_type;
    v_koef     NUMBER;
    CURSOR policy_agent
    (
      pol_header_id NUMBER
     ,par_date      DATE
    ) IS(
      SELECT DISTINCT ag_contract_header_id
        FROM p_policy_agent      pa
            ,policy_agent_status pas
       WHERE pa.date_start <= par_date
         AND pa.date_end > par_date
         AND pa.status_id = pas.policy_agent_status_id
         AND pas.brief <> 'ERROR'
         AND pa.policy_header_id = pol_header_id);
  BEGIN
    DELETE FROM temp_sgp_calc;
    FOR pay_doc IN (SELECT ph.policy_id active_policy
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
                          ,(SELECT DISTINCT last_value(pay3.document_id) over(ORDER BY pay3.reg_date rows BETWEEN unbounded preceding AND unbounded following)
                              FROM doc_set_off dso4
                                  ,document    pay3
                                  ,doc_templ   dt6
                             WHERE dso4.parent_doc_id = epg.payment_id
                               AND pay3.document_id = dso4.child_doc_id
                               AND pay3.doc_templ_id = dt6.doc_templ_id
                               AND dt6.brief IN ('A7', 'PD4', 'ПП')) pd
                          ,(SELECT CASE
                                     WHEN COUNT(ac.ag_contract_id) > 0 THEN
                                      0
                                     ELSE
                                      1
                                   END
                              FROM ag_contract_header ach
                                  ,ag_contract        ac
                             WHERE ac.ag_contract_id =
                                   pkg_agent_1.get_status_by_date(ach.ag_contract_header_id
                                                                 ,ph.start_date)
                               AND doc.get_doc_status_id(ac.ag_contract_id, ph.start_date) NOT IN
                                   (g_st_berak, g_st_cancel)
                               AND ach.agent_id =
                                   pkg_policy.get_policy_contact(ph.policy_id
                                                                ,'Страхователь')) insuer_not_agent
                          ,(SELECT CASE
                                     WHEN COUNT(va.as_assured_id) > 0 THEN
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
                                       AND doc.get_doc_status_id(ac1.ag_contract_id, ph.start_date) NOT IN
                                           (g_st_berak, g_st_cancel)
                                       AND ach1.agent_id = va.assured_contact_id)) assured_not_agent
                      FROM p_policy        pp
                          ,p_pol_header    ph
                          ,t_product       tp
                          ,doc_doc         dd
                          ,ven_ac_payment  epg
                          ,doc_templ       epg_dt
                          ,t_payment_terms pt
                     WHERE pp.payment_term_id = pt.id
                       AND pp.pol_header_id = ph.policy_header_id
                       AND ph.product_id = tp.product_id
                       AND nvl(tp.is_group, 0) = 0
                       AND pt.id NOT IN (g_pt_quater, g_pt_monthly)
                       AND ((nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,0) NOT IN (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
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
                           (nvl(doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)
                                                      ,g_status_date)
                                ,0) NOT IN (g_st_readycancel, g_st_stop, g_st_stoped, g_st_berak) AND
                           doc.get_doc_status_id(pkg_renlife_utils.get_first_a_policy(ph.policy_header_id)
                                                  ,g_status_date) IN
                           (g_st_concluded, g_st_curr, g_st_stoped)))
                          -- AND pp.pol_header_id =10770919
                          --AND pp.policy_id = 10251142
                          -- AND ph.start_date >= '30.05.2009'
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
                          --Доработки в ТЗ - Ким (максимальная из дат: "Дата С", "Дата платежа"
                          -- Если "Дата С">Даты окончания ОП то -1
                          -- Если оплата ежемесячная то сравнивается с 5 календарным днем следющего месяца
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
                       AND ph.policy_header_id NOT IN
                           (SELECT pp1.pol_header_id --Нет в пердидущих расчетах сгп1
                              FROM ag_roll_type         art
                                  ,ven_ag_roll_header   arh
                                  ,ag_roll              ar
                                  ,ag_perfomed_work_act apw
                                  ,ag_perfom_work_det   apwd
                                  ,ag_rate_type         agrt
                                  ,t_sgp_type           tsgp
                                  ,ag_perfom_work_dpol  apd
                                  ,p_policy             pp1
                             WHERE 1 = 1
                               AND ar.ag_roll_header_id <> art.ag_roll_type_id
                               AND art.agent_category_id IN (3, 4)
                               AND arh.date_begin <> g_date_begin
                               AND arh.date_end <> g_date_end
                                  --AND substr(art.brief,1,3) = substr(g_roll_type_brief,1,3)
                               AND nvl(arh.note, ' ') <> '!ТЕСТ!'
                               AND arh.ag_roll_type_id = art.ag_roll_type_id
                               AND ar.ag_roll_header_id = arh.ag_roll_header_id
                               AND apw.ag_roll_id = ar.ag_roll_id
                               AND apwd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
                               AND apwd.ag_rate_type_id = agrt.ag_rate_type_id
                               AND agrt.t_sgp_type_id = tsgp.t_sgp_type_id
                               AND tsgp.name = 'СГП 1'
                               AND apd.ag_perfom_work_det_id = apwd.ag_perfom_work_det_id
                               AND pp1.policy_id = apd.policy_id))
    LOOP
      v_attrs.delete;
    
      v_attrs(1) := pay_doc.product_id;
      v_attrs(2) := pay_doc.pay_term;
      v_attrs(3) := pay_doc.insurance_period; --год страхования
      v_attrs(4) := 2; --Премии
      v_attrs(5) := to_char(g_date_end, 'YYYYMMDD');
      v_koef := nvl(pkg_tariff_calc.calc_coeff_val('SGP_koeff', v_attrs, 5), 0);
    
      OPEN policy_agent(pay_doc.pol_header_id, g_date_end);
      FETCH policy_agent
        INTO v_ag_ch_id;
      IF policy_agent%NOTFOUND
      THEN
        v_ag_ch_id := pkg_renlife_utils.get_p_agent_sale(pay_doc.pol_header_id);
      
        FOR mng_vol IN (SELECT ac.contract_id ag_contract_id
                              , --раньше была версия, но это порочная практика!!!!
                               ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> g_ct_agent
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, g_date_end)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_rop --Рук. - РОП
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_reg_dir --Рук Регион.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_tdir --Рук Тер.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, g_date_end) =
                                   ac.ag_contract_id)
        LOOP
          FOR cover IN (SELECT ROUND(pc.fee *
                                     acc.get_cross_rate_by_id(1
                                                             ,pay_doc.fund_id
                                                             ,122
                                                             ,(SELECT MAX(pay_d1.reg_date)
                                                                FROM doc_set_off    dso
                                                                    ,ven_ac_payment pay_d1
                                                                    ,doc_templ      pay_temp
                                                               WHERE dso.parent_doc_id = pay_doc.epg
                                                                 AND dso.child_doc_id =
                                                                     pay_d1.payment_id
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
                ,lvl
                ,ag_contract_id
                ,current_agent
                ,agent_status_id
                ,active_policy_id
                ,active_pol_status_id
                ,sgp_koef
                ,payment_term_id
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
                ,mng_vol.lvl
                ,mng_vol.ag_contract_id
                ,v_ag_ch_id
                ,mng_vol.ag_status_id
                ,pay_doc.active_policy
                ,pay_doc.active_pol_st
                ,v_koef
                ,pay_doc.pay_term
                ,pay_doc.insuer_not_agent
                ,pay_doc.assured_not_agent);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
      END IF;
      LOOP
        EXIT WHEN policy_agent%NOTFOUND;
        FOR mng_vol IN (SELECT ac.contract_id ag_contract_id
                              , --раньше была версия, но это порочная практика!!!!
                               ac.category_id
                              ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) ag_status_id
                              ,LEVEL lvl
                          FROM ag_contract ac
                         WHERE ac.category_id <> g_ct_agent
                         START WITH ac.ag_contract_id =
                                    pkg_agent_1.get_status_by_date(v_ag_ch_id, g_date_end)
                        CONNECT BY nocycle
                         PRIOR
                                    (SELECT c1.contract_id
                                       FROM ag_contract c1
                                      WHERE c1.ag_contract_id = ac.contract_leader_id) = ac.contract_id
                               AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                   OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_rop --Рук. - РОП
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_rop) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_reg_dir --Рук Регион.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) NOT IN
                                    (g_agst_reg_dir, g_agst_tdir)) OR
                                   (pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) =
                                   g_agst_tdir --Рук Тер.Дир
                                   AND
                                   PRIOR
                                    pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 2) <>
                                    g_agst_tdir)))
                               AND pkg_agent_1.get_status_by_date(ac.contract_id, g_date_end) =
                                   ac.ag_contract_id)
        LOOP
          FOR cover IN (SELECT ROUND(pc.fee *
                                     acc.get_cross_rate_by_id(1
                                                             ,pay_doc.fund_id
                                                             ,122
                                                             ,(SELECT MAX(pay_d1.reg_date)
                                                                FROM doc_set_off    dso
                                                                    ,ven_ac_payment pay_d1
                                                                    ,doc_templ      pay_temp
                                                               WHERE dso.parent_doc_id = pay_doc.epg
                                                                 AND dso.child_doc_id =
                                                                     pay_d1.payment_id
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
                ,lvl
                ,ag_contract_id
                ,current_agent
                ,agent_status_id
                ,active_policy_id
                ,active_pol_status_id
                ,sgp_koef
                ,payment_term_id
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
                ,mng_vol.lvl
                ,mng_vol.ag_contract_id
                ,v_ag_ch_id
                ,mng_vol.ag_status_id
                ,pay_doc.active_policy
                ,pay_doc.active_pol_st
                ,v_koef
                ,pay_doc.pay_term
                ,pay_doc.insuer_not_agent
                ,pay_doc.assured_not_agent);
            EXCEPTION
              WHEN dup_val_on_index THEN
                NULL;
            END;
          END LOOP;
        END LOOP;
        FETCH policy_agent
          INTO v_ag_ch_id;
      END LOOP;
      CLOSE policy_agent;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END prepare_sgp_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.06.2009 17:04:24
  -- Purpose : Подготовка объемов для расчета КСП
  PROCEDURE prepare_ksp IS
    proc_name VARCHAR2(20) := 'Prepare_KSP';
  
    TYPE t_temp_ksp_calc IS TABLE OF temp_ksp_calc%ROWTYPE INDEX BY PLS_INTEGER;
    v_temp_ksp_calc t_temp_ksp_calc;
  
    i PLS_INTEGER;
  
  BEGIN
    DELETE FROM temp_ksp_calc;
  
    FOR pol IN (SELECT a.ag_contract_header_id
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
                                   AND tplo.description <> 'Административные издержки') *
                               pt.number_of_payments *
                               acc.get_cross_rate_by_id(1, ph.fund_id, 122, SYSDATE) sgp
                          FROM ag_contract_header ach
                              ,t_sales_channel    ts
                              ,ag_contract        ac
                              ,p_pol_header       ph
                              ,p_policy           pp
                              ,t_payment_terms    pt
                              ,p_policy_agent     pa
                         WHERE ac.ag_contract_id =
                               pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, g_date_end)
                           AND ach.t_sales_channel_id = ts.id
                           AND ach.t_sales_channel_id = g_sc_dsf
                           AND ph.start_date >= '01.10.2006'
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
                                                                                                                ,2
                                                                                                                ,0)
                                                                    , --а раньше было -1
                                                                     2)
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
                           AND greatest(ph.start_date
                                       ,pkg_agent_1.get_agent_start_contr(ph.policy_header_id, 5)) BETWEEN
                               pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 1, -31) AND
                               pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -8)
                           AND g_date_end >= ADD_MONTHS(ph.start_date, 12 / pt.number_of_payments) + 45
                           AND doc.get_doc_status_id(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                               (g_st_stoped, g_st_cancel)
                           AND (doc.get_doc_status_id(pp.policy_id) NOT IN
                               (g_st_readycancel, g_st_berak) OR
                               ((extract(YEAR FROM ph.start_date) = 2008 AND
                               pp.decline_date > '01.07.2009') OR (extract(YEAR FROM ph.start_date) <> 2008 AND
                               pp.decline_date >= pa.date_start)))) a)
    LOOP
      FOR mng_vol IN (SELECT ac.contract_id
                        FROM ag_contract ac
                       WHERE ac.category_id <> g_ct_agent
                       START WITH ac.ag_contract_id =
                                  pkg_agent_1.get_status_by_date(pol.ag_contract_header_id
                                                                ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                            ,2
                                                                                                            ,-1))
                      CONNECT BY nocycle PRIOR (SELECT c1.contract_id
                                          FROM ag_contract c1
                                         WHERE c1.ag_contract_id = ac.contract_leader_id) =
                                  ac.contract_id
                             AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                 OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                       ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                   ,2
                                                                                                                   ,-1)
                                                                       ,2) = g_agst_rop --Рук. - РОП
                                 AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                 ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                             ,2
                                                                                                                             ,-1)
                                                                                 ,2) <>
                                  g_agst_rop) OR (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                       ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                                   ,2
                                                                                                                                   ,-1)
                                                                                       ,2) =
                                 g_agst_reg_dir --Рук Регион.Дир
                                 AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                                 ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                                             ,2
                                                                                                                                             ,-1)
                                                                                                 ,2) NOT IN
                                  (g_agst_reg_dir, g_agst_tdir)) OR
                                 (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                       ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                   ,2
                                                                                                                   ,-1)
                                                                       ,2) = g_agst_tdir --Рук Тер.Дир
                                 AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                 ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                                             ,2
                                                                                                                             ,-1)
                                                                                 ,2) <>
                                  g_agst_tdir)))
                             AND pkg_agent_1.get_status_by_date(ac.contract_id
                                                               ,pkg_ag_calc_admin.get_opertation_month_date(g_date_end
                                                                                                           ,2
                                                                                                           ,-1)) =
                                 ac.ag_contract_id)
      LOOP
        IF pol.last_st IN (g_st_readycancel, g_st_berak)
        THEN
          FOR mng_vol_dec IN (SELECT ac.contract_id
                                FROM ag_contract ac
                               WHERE ac.category_id <> g_ct_agent
                               START WITH ac.ag_contract_id =
                                          pkg_agent_1.get_status_by_date(pol.ag_contract_header_id
                                                                        ,pol.decline_date - 1)
                              CONNECT BY nocycle
                               PRIOR (SELECT c1.contract_id
                                                  FROM ag_contract c1
                                                 WHERE c1.ag_contract_id = ac.contract_leader_id) =
                                          ac.contract_id
                                     AND (PRIOR ac.category_id < ac.category_id --Категории подчиненного всегда меньше категории руководителя кроме:
                                         OR ((pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                               ,pol.decline_date - 1
                                                                               ,2) = g_agst_rop --Рук. - РОП
                                         AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                         ,pol.decline_date - 1
                                                                                         ,2) <>
                                          g_agst_rop) OR (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                               ,pol.decline_date - 1
                                                                                               ,2) =
                                         g_agst_reg_dir --Рук Регион.Дир
                                         AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                                         ,pol.decline_date - 1
                                                                                                         ,2) NOT IN
                                          (g_agst_reg_dir, g_agst_tdir)) OR
                                         (pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                               ,pol.decline_date - 1
                                                                               ,2) = g_agst_tdir --Рук Тер.Дир
                                         AND PRIOR pkg_renlife_utils.get_ag_stat_id(ac.contract_id
                                                                                         ,pol.decline_date - 1
                                                                                         ,2) <>
                                          g_agst_tdir)))
                                     AND pkg_agent_1.get_status_by_date(ac.contract_id
                                                                       ,pol.decline_date - 1) =
                                         ac.ag_contract_id)
          LOOP
            IF mng_vol_dec.contract_id = mng_vol.contract_id
            THEN
              i := v_temp_ksp_calc.count + 1;
              v_temp_ksp_calc(i).contract_header_id := mng_vol.contract_id;
              v_temp_ksp_calc(i).agent_contract_header := pol.ag_contract_header_id;
              v_temp_ksp_calc(i).decline_date := pol.decline_date;
              v_temp_ksp_calc(i).policy_header_id := pol.policy_header_id;
              v_temp_ksp_calc(i).active_policy_status_id := pol.active_st;
              v_temp_ksp_calc(i).last_policy_status_id := pol.last_st;
              v_temp_ksp_calc(i).conclude_policy_sgp := pol.sgp_z;
              v_temp_ksp_calc(i).prolong_policy_sgp := pol.sgp_real_p;
            END IF;
          END LOOP;
        ELSE
          i := v_temp_ksp_calc.count + 1;
          v_temp_ksp_calc(i).contract_header_id := mng_vol.contract_id;
          v_temp_ksp_calc(i).agent_contract_header := pol.ag_contract_header_id;
          v_temp_ksp_calc(i).decline_date := pol.decline_date;
          v_temp_ksp_calc(i).policy_header_id := pol.policy_header_id;
          v_temp_ksp_calc(i).active_policy_status_id := pol.active_st;
          v_temp_ksp_calc(i).last_policy_status_id := pol.last_st;
          v_temp_ksp_calc(i).conclude_policy_sgp := pol.sgp_z;
          v_temp_ksp_calc(i).prolong_policy_sgp := pol.sgp_real_p;
        END IF;
      END LOOP;
    END LOOP;
  
    DECLARE
      errors NUMBER;
      dml_errors EXCEPTION;
      PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    BEGIN
      FORALL i IN 1 .. v_temp_ksp_calc.count SAVE EXCEPTIONS
        INSERT INTO temp_ksp_calc VALUES v_temp_ksp_calc (i);
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
  END prepare_ksp;

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
                  FROM temp_vol_calc  tv
                      ,ag_volume      av
                      ,ag_roll        ar
                      ,ag_roll_header arh
                 WHERE 1 = 1
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND arh.date_begin <= g_date_begin
                   AND tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id IN
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

  -- Author  : VESELEK
  -- Created : 15.03.2013
  -- Purpose : Комиссионное вознаграждение за групповой Объем (КВГ)
  PROCEDURE rla_volume_group(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'RLA_VOLUME_GROUP';
    v_ag_ch_id  PLS_INTEGER;
    v_rate_type PLS_INTEGER;
  BEGIN
  
    BEGIN
      SELECT ag_contract_header_id
            ,ag_rate_type_id
        INTO v_ag_ch_id
            ,v_rate_type
        FROM (SELECT apw.ag_contract_header_id
                    ,apd.ag_rate_type_id
                FROM ins.ag_perfomed_work_act   apw
                    ,ins.ag_perfom_work_det     apd
                    ,ins.ag_contract            ac
                    ,ins.ven_ag_contract_header ach
                    ,ins.document               d
                    ,ins.doc_status_ref         rf
               WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
                 AND ac.contract_id = apw.ag_contract_header_id
                 AND ach.ag_contract_header_id = d.document_id
                 AND d.doc_status_ref_id = rf.doc_status_ref_id
                 AND ach.t_sales_channel_id IN
                     (SELECT ch.id FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA')
                 AND rf.brief = 'CURRENT'
                 AND ach.agent_id IN
                     (SELECT agh.agent_id FROM ins.ven_ag_contract_header agh WHERE agh.num = '2089')
                 AND ach.ag_contract_header_id =
                     (SELECT MAX(ag.ag_contract_header_id)
                        FROM ins.ag_contract_header ag
                       WHERE ag.agent_id = (SELECT acha.agent_id
                                              FROM ins.ven_ag_contract_header acha
                                             WHERE acha.num = '2089'))
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                 AND nvl(ach.is_new, 0) = 1
                 AND trunc(g_date_end) >= to_date('31.07.2013', 'DD.MM.YYYY')
              UNION
              SELECT apw.ag_contract_header_id
                    ,apd.ag_rate_type_id
                FROM ins.ag_perfomed_work_act   apw
                    ,ins.ag_perfom_work_det     apd
                    ,ins.ag_contract            ac
                    ,ins.ven_ag_contract_header ach
               WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                 AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
                 AND ac.contract_id = apw.ag_contract_header_id
                 AND ach.t_sales_channel_id IN
                     (SELECT ch.id FROM ins.t_sales_channel ch WHERE ch.brief = 'RLA')
                 AND ach.num = '2089'
                 AND ach.ag_contract_header_id = apw.ag_contract_header_id
                 AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                 AND nvl(ach.is_new, 0) = 1
                 AND trunc(g_date_end) < to_date('31.07.2013', 'DD.MM.YYYY'));
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
    END;
  
    FOR vl IN (SELECT av.ag_volume_id
                     ,ROUND(nvl(apv.vol_amount, 0), 2) detail_amt
                     ,CASE
                        WHEN tp.brief IN
                             ('END', 'END_2', 'CHI', 'CHI_2', 'PEPR', 'PEPR_2', 'TERM', 'TERM_2')
                             AND (SELECT COUNT(*)
                                    FROM ins.t_product_line      pl
                                        ,ins.t_product_line_type plt
                                   WHERE pl.id = tplo.product_line_id
                                     AND pl.product_line_type_id = plt.product_line_type_id
                                     AND plt.brief != 'RECOMMENDED') != 0 THEN
                         0
                        ELSE
                         ROUND(10 / 100, 2)
                      END detail_rate
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
                  AND ar.ag_roll_id = g_roll_id
                  AND arh.ag_roll_header_id = ar.ag_roll_header_id
                  AND ar.ag_roll_id = apw.ag_roll_id
                  AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                  AND apd.ag_rate_type_id = art.ag_rate_type_id
                  AND art.brief IN ('RLA_PERSONAL_POL')
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
                  AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                  AND ac.agency_id = dep.department_id
                  AND ac.ag_sales_chn_id = ts.id
                  AND ac.category_id = aca.ag_category_agent_id
                  AND cn_a.contact_id = ach.agent_id
                  AND tct.id = ac.leg_pos
                  AND pt.id = av.payment_term_id
                  AND ach.num IN ('2100', '47975'))
    LOOP
    
      INSERT INTO ins.ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vl.ag_volume_id, vl.detail_amt, vl.detail_rate);
    
      g_commision := g_commision + nvl(vl.detail_amt * vl.detail_rate, 0);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; v_ag_ch_id = ' ||
                              v_ag_ch_id || SQLERRM);
  END;

  -- Author  : VESELEK
  -- Created : 01.10.2012
  -- Purpose : Комиссионное вознаграждение за личное заключение ДС
  PROCEDURE rla_personal_pol(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'RLA_PERSONAL_POL';
    v_ag_ch_id     PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_sales_ch     PLS_INTEGER;
    v_sav          NUMBER;
    v_leg_pos      PLS_INTEGER;
    v_rate_type    PLS_INTEGER;
    v_decrease_sav NUMBER := 0.8;
    v_leg_pos_recr NUMBER;
    v_sav_recr     NUMBER;
    v_is_exception NUMBER;
    v_sav_gp       NUMBER;
    v_ind_sav      NUMBER;
  BEGIN
  
    SELECT ag_contract_header_id
          ,category_id
          ,t_sales_channel_id
          ,leg_pos
          ,ag_rate_type_id
          ,tariff_agent
          ,leg_pos_recr
          ,nvl(tariff_recr, 0)
          ,is_exception
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_leg_pos
          ,v_rate_type
          ,v_sav
          ,v_leg_pos_recr
          ,v_sav_recr
          ,v_is_exception
      FROM (SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,apd.ag_rate_type_id
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_agent
                  ,nvl(ac_r.leg_pos, 0) leg_pos_recr
                  ,CASE
                     WHEN ach.num = '47975' THEN
                      1
                     ELSE
                      0
                   END is_exception
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_recr
              FROM ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det apd
                  ,ins.ag_contract ac
                  ,ins.ven_ag_contract_header ach
                  ,ins.ag_contract ac_recr
                  ,(SELECT aca.contract_id
                          ,aca.ag_contract_id
                          ,aca.leg_pos
                      FROM ins.ag_contract aca
                     WHERE g_date_end BETWEEN aca.date_begin AND aca.date_end) ac_r
                  ,ins.ag_contract_header ach_recr
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND g_date_end BETWEEN ac.date_begin AND ac.date_end
               AND nvl(ach.is_new, 0) = 1
               AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
               AND ac_recr.contract_id = ac_r.contract_id(+)
               AND ac_r.contract_id = ach_recr.ag_contract_header_id(+)
            UNION
            SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,apd.ag_rate_type_id
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_agent
                  ,nvl(ac_recr.leg_pos, 0) leg_pos_recr
                  ,CASE
                     WHEN ach.num = '47975' THEN
                      1
                     ELSE
                      0
                   END is_exception
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_recr
              FROM ins.ag_perfomed_work_act   apw
                  ,ins.ag_perfom_work_det     apd
                  ,ins.ag_contract            ac
                  ,ins.ven_ag_contract_header ach
                  ,ins.ag_contract            ac_recr
                  ,ins.ag_contract_header     ach_recr
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND ach.last_ver_id = ac.ag_contract_id
               AND nvl(ach.is_new, 0) = 0
               AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
               AND ac_recr.contract_id = ach_recr.ag_contract_header_id(+));
  
    FOR vol IN (SELECT av.*
                      ,CASE
                         WHEN trm.brief = 'Единовременно' THEN
                          1
                         ELSE
                          0
                       END v_nonrec
                      ,CASE
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief != 'Единовременно' THEN
                          av.trans_sum * (CASE
                            WHEN av.ins_period > 20 THEN
                             20
                            ELSE
                             av.ins_period
                          END) / 20000
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief = 'Единовременно' THEN
                          av.trans_sum / 20000 * 1.5
                         WHEN prod.brief IN ('OPS_Plus', 'OPS_Plus_2') THEN
                          av.trans_sum * 20 / 20000
                         WHEN av.ag_volume_type_id IN
                              (g_vt_ops, g_vt_ops_1, g_vt_ops_2, g_vt_ops_3, g_vt_ops_9) THEN
                          0.5
                         WHEN prod.brief IN ('RP-9', 'AUTO_EXP', 'ACC_MLN') THEN
                          av.trans_sum * 12.5 / 20000
                         WHEN prod.brief IN ('Investor', 'InvestorALFA') THEN
                          av.trans_sum / 10000
                         ELSE
                          0
                       END le
                      ,pkg_tariff_calc.calc_coeff_val('SAV_GP_' || (CASE
                                                        WHEN prod.brief IN ('PRIN_DP', 'PRIN_DP_NEW', 'PRIN_DP_NEW_CITY') THEN
                                                         25
                                                        WHEN prod.brief IN ('Baby_LA', 'Baby_LA2') THEN
                                                         14
                                                        ELSE
                                                         13
                                                      END)
                                                     ,t_number_type(v_sales_ch
                                                                   ,v_leg_pos
                                                                   ,CASE
                                                                      WHEN trm.brief = 'Единовременно' THEN
                                                                       1
                                                                      ELSE
                                                                       0
                                                                    END
                                                                   ,av.pay_period
                                                                   ,av.ins_period
                                                                   ,v_ag_ch_id
                                                                   ,decode(prod.brief
                                                                          ,'Baby_LA'
                                                                          ,2
                                                                          ,'Baby_LA2'
                                                                          ,2
                                                                          ,1))) v_sav_ul
                  FROM ins.ag_volume          av
                      ,ins.ag_roll            ar
                      ,ins.ven_ag_roll_header arh
                      ,ins.p_pol_header       ph
                      ,ins.t_product          prod
                      ,ins.t_payment_terms    trm
                      ,ins.ag_contract_header agh
                      ,ins.ag_roll_type       art
                 WHERE av.ag_roll_id = ar.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND av.policy_header_id = ph.policy_header_id(+)
                   AND av.payment_term_id = trm.id(+)
                   AND ph.product_id = prod.product_id(+)
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND nvl(arh.note, 'Не определен') != 'Фиктивная'
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'RLA_CASH_VOL'
                   AND av.ag_contract_header_id = agh.ag_contract_header_id
                   AND nvl(av.pay_period, 1) = 1
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ins.ag_perf_work_vol     apv
                              ,ins.ag_perfom_work_det   apd
                              ,ins.ag_perfomed_work_act apw
                              ,ins.ag_roll              ar
                              ,ins.ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND ar.ag_roll_header_id != g_roll_header_id
                           AND apd.ag_rate_type_id = v_rate_type)
                   AND av.ag_contract_header_id = v_ag_ch_id)
    LOOP
    
      IF v_is_exception = 0
      THEN
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate, vol_decrease)
        VALUES
          (p_ag_perf_work_det_id
          ,vol.ag_volume_id
          ,CASE WHEN v_leg_pos = 101 THEN ROUND(vol.trans_sum, 2) ELSE ROUND(vol.le, 2) END
          ,CASE WHEN v_leg_pos = 101 THEN(vol.v_sav_ul / 100) ELSE ROUND(v_sav, 2) END
          ,CASE WHEN(v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN v_decrease_sav ELSE 1 END);
      
        g_commision := g_commision + nvl((CASE
                                           WHEN v_leg_pos = 101 THEN
                                            (vol.v_sav_ul / 100)
                                           ELSE
                                            ROUND(v_sav, 2)
                                         END) * (CASE
                                           WHEN v_leg_pos = 101 THEN
                                            ROUND(vol.trans_sum, 2)
                                           ELSE
                                            ROUND(vol.le, 2)
                                         END) * (CASE
                                           WHEN (v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN
                                            v_decrease_sav
                                           ELSE
                                            1
                                         END)
                                        ,0);
      
        /*костыль для Ромуальда*/
      ELSE
        v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                  ,t_number_type(vol.t_prod_line_option_id, v_sales_ch));
        CASE
          WHEN v_sav_gp <= 3 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,1
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,1));
          WHEN v_sav_gp = 4 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,1));
          WHEN v_sav_gp = 5 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 1, 1));
          WHEN v_sav_gp IN (6, 7) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 1));
          WHEN v_sav_gp IN (8) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,1
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,2));
          WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19) THEN
            v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
          WHEN v_sav_gp IN (20, 23, 24) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_ag_ch_id, 2));
          WHEN v_sav_gp = 10 THEN
          
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
                                                         ,t_number_type(v_leg_pos, 1, 1, v_ins_age));
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20099
                                       ,'Не удается определить возраст застрахованного');
            END;
          WHEN v_sav_gp = 11 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,1
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period
                                                                     ,v_sales_ch
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 12 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,1
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period));
          WHEN v_sav_gp = 13 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 14 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 21 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 22 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 25 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp IN (26, 27) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_ag_ch_id, 2));
          WHEN v_sav_gp = 29 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
          WHEN v_sav_gp = 30 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos, vol.pay_period, 2));
          ELSE
            v_ind_sav := 0;
        END CASE;
        v_ind_sav := nvl(v_ind_sav, 0) / 100;
      
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate, vol_decrease)
        VALUES
          (p_ag_perf_work_det_id
          ,vol.ag_volume_id
          ,ROUND(vol.trans_sum, 2)
          ,v_ind_sav
          ,CASE WHEN(v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN v_decrease_sav ELSE 1 END);
      
        g_commision := g_commision + nvl(v_ind_sav * ROUND(vol.trans_sum, 2) * (CASE
                                           WHEN (v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN
                                            v_decrease_sav
                                           ELSE
                                            1
                                         END)
                                        ,0);
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; v_ag_ch_id = ' ||
                              v_ag_ch_id || SQLERRM);
  END;

  -- Author  : VESELEK
  -- Created : 01.10.2012
  -- Purpose : Комиссионное вознаграждение за руководство структурами
  PROCEDURE rla_management_structure(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'RLA_MANAG_STRUCTURE';
    v_ag_ch_id     PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_sales_ch     PLS_INTEGER;
    v_sav          NUMBER;
    v_sav_ch       NUMBER;
    v_leg_pos      PLS_INTEGER;
    v_rate_type    PLS_INTEGER;
    v_kv           NUMBER := 0;
    v_le           NUMBER := 0;
    v_apw_id       NUMBER;
    v_apw_det_id   NUMBER;
    p_commission   NUMBER;
    par_from_id_1  NUMBER;
    par_from_id_2  NUMBER;
    k              NUMBER;
    v_decrease_sav NUMBER := 0.8;
    v_leg_pos_lead NUMBER;
    v_leg_pos_recr NUMBER;
    v_sav_recr     NUMBER;
  BEGIN
  
    SELECT ag_contract_header_id
          ,category_id
          ,t_sales_channel_id
          ,leg_pos
          ,ag_rate_type_id
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_leg_pos
          ,v_rate_type
      FROM (SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,apd.ag_rate_type_id
              FROM ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det   apd
                  ,ins.ag_contract          ac
                  ,ins.ag_contract_header   ach
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND g_date_end BETWEEN ac.date_begin AND ac.date_end
               AND nvl(ach.is_new, 0) = 1
            UNION
            SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,apd.ag_rate_type_id
              FROM ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det   apd
                  ,ins.ag_contract          ac
                  ,ins.ag_contract_header   ach
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND ach.last_ver_id = ac.ag_contract_id
               AND nvl(ach.is_new, 0) = 0);
  
    FOR vol IN (SELECT CASE
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief != 'Единовременно' THEN
                          av.trans_sum * (CASE
                            WHEN av.ins_period > 20 THEN
                             20
                            ELSE
                             av.ins_period
                          END) / 20000
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief = 'Единовременно' THEN
                          av.trans_sum / 20000 * 1.5
                         WHEN prod.brief IN ('OPS_Plus', 'OPS_Plus_2') THEN
                          av.trans_sum * 20 / 20000
                         WHEN av.ag_volume_type_id IN
                              (g_vt_ops, g_vt_ops_1, g_vt_ops_2, g_vt_ops_3, g_vt_ops_9) THEN
                          0.5
                         WHEN prod.brief IN ('RP-9', 'AUTO_EXP', 'ACC_MLN') THEN
                          av.trans_sum * 12.5 / 20000
                         WHEN prod.brief IN ('Investor', 'InvestorALFA') THEN
                          av.trans_sum / 10000
                         ELSE
                          0
                       END le
                      ,av.*
                  FROM ins.ag_volume          av
                      ,ins.ag_roll            ar
                      ,ins.ven_ag_roll_header arh
                      ,ins.p_pol_header       ph
                      ,ins.t_product          prod
                      ,ins.t_payment_terms    trm
                      ,ins.ag_roll_type       art
                 WHERE av.ag_roll_id = ar.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND av.policy_header_id = ph.policy_header_id(+)
                   AND ph.product_id = prod.product_id(+)
                   AND av.payment_term_id = trm.id(+)
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND nvl(arh.note, 'Не определен') != 'Фиктивная'
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'RLA_CASH_VOL'
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ins.ag_perf_work_vol     apv
                              ,ins.ag_perfom_work_det   apd
                              ,ins.ag_perfomed_work_act apw
                              ,ins.ag_roll              ar
                              ,ins.ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id IN
                               (SELECT tr.ag_parent_header_id
                                  FROM ins.ag_agent_tree tr
                                 WHERE tr.ag_contract_header_id = v_ag_ch_id
                                   AND g_date_end BETWEEN tr.date_begin AND tr.date_end)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND ar.ag_roll_header_id != g_roll_header_id
                           AND apd.ag_rate_type_id = v_rate_type)
                   AND av.ag_contract_header_id = v_ag_ch_id)
    LOOP
    
      FOR tre IN (SELECT from_rate_id
                        ,to_rate_id
                    FROM (SELECT tr.ag_contract_header_id from_rate_id
                                ,tr.ag_parent_header_id   to_rate_id
                            FROM ins.ag_agent_tree tr
                           WHERE g_date_end BETWEEN tr.date_begin AND tr.date_end
                          CONNECT BY PRIOR tr.ag_parent_header_id = tr.ag_contract_header_id
                           START WITH tr.ag_contract_header_id = v_ag_ch_id)
                   WHERE to_rate_id IS NOT NULL
                  
                  )
      LOOP
      
        p_commission := 0;
        BEGIN
          SELECT apw.ag_perfomed_work_act_id
            INTO v_apw_id
            FROM ag_perfomed_work_act apw
           WHERE apw.ag_roll_id = g_roll_id
             AND apw.ag_contract_header_id = tre.to_rate_id;
        EXCEPTION
          WHEN no_data_found THEN
            SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
            INSERT INTO ven_ag_perfomed_work_act
              (ag_perfomed_work_act_id, ag_roll_id, ag_contract_header_id, date_calc)
            VALUES
              (v_apw_id, g_roll_id, tre.to_rate_id, SYSDATE);
        END;
      
        SELECT sq_ag_perfom_work_det.nextval INTO v_apw_det_id FROM dual;
      
        INSERT INTO ven_ag_perfom_work_det d
          (ag_perfom_work_det_id, ag_perfomed_work_act_id, ag_rate_type_id, summ)
        VALUES
          (v_apw_det_id, v_apw_id, v_rate_type, 0);
      
        v_le := v_le + vol.le;
        /*лидер*/
        SELECT marketing_rla_sav
              ,leg_pos
              ,leg_pos_recr
              ,nvl(sav_recr, 0) sav_recr
          INTO v_sav
              ,v_leg_pos_lead
              ,v_leg_pos_recr
              ,v_sav_recr
          FROM (SELECT (SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) marketing_rla_sav
                      ,ac.leg_pos
                      ,nvl(ac_r.leg_pos, 0) leg_pos_recr
                      ,(SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) sav_recr
                  FROM ins.ag_contract ac
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract ac_recr
                      ,(SELECT aca.contract_id
                              ,aca.ag_contract_id
                              ,aca.leg_pos
                          FROM ins.ag_contract aca
                         WHERE g_date_end BETWEEN aca.date_begin AND aca.date_end) ac_r
                      ,ins.ag_contract_header ach_recr
                 WHERE ac.contract_id = tre.to_rate_id
                   AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                   AND ach.ag_contract_header_id = ac.contract_id
                   AND nvl(ach.is_new, 0) = 1
                   AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
                   AND ac_recr.contract_id = ac_r.contract_id(+)
                   AND ac_r.contract_id = ach_recr.ag_contract_header_id(+)
                UNION
                SELECT (SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) marketing_rla_sav
                      ,ac.leg_pos
                      ,ac_recr.leg_pos leg_pos_recr
                      ,(SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) sav_recr
                  FROM ins.ag_contract        ac
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac_recr
                      ,ins.ag_contract_header ach_recr
                 WHERE ach.ag_contract_header_id = tre.to_rate_id
                   AND ach.last_ver_id = ac.ag_contract_id
                   AND nvl(ach.is_new, 0) = 0
                   AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
                   AND ac_recr.contract_id = ach_recr.ag_contract_header_id(+));
        /*агент*/
        SELECT marketing_rla_sav
          INTO v_sav_ch
          FROM (SELECT (SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) marketing_rla_sav
                  FROM ins.ag_contract        ac
                      ,ins.ag_contract_header ach
                 WHERE ac.contract_id = tre.from_rate_id
                   AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                   AND ach.ag_contract_header_id = ac.contract_id
                   AND nvl(ach.is_new, 0) = 1
                UNION
                SELECT (SELECT MAX(pl.t_tariff)
                          FROM ins.t_career_plan pl
                         WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                           AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) marketing_rla_sav
                  FROM ins.ag_contract        ac
                      ,ins.ag_contract_header ach
                 WHERE ach.ag_contract_header_id = tre.from_rate_id
                   AND ach.last_ver_id = ac.ag_contract_id
                   AND nvl(ach.is_new, 0) = 0);
        /**/
      
        v_kv := (v_sav - v_sav_ch);
        IF v_kv < 0
        THEN
          v_kv := 0;
        END IF;
      
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate, vol_units, vol_decrease)
        VALUES
          (v_apw_det_id
          ,vol.ag_volume_id
          ,ROUND(v_kv, 2)
          ,(CASE WHEN vol.pay_period = 1 THEN 1 WHEN vol.pay_period = 2 THEN 25 / 100 WHEN
            vol.pay_period > 2 AND vol.pay_period <= 5 THEN 10 / 100 ELSE 0 END)
          ,ROUND(vol.le, 2)
          ,(CASE WHEN(v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN v_decrease_sav ELSE 1 END));
        p_commission := p_commission + nvl(ROUND(v_kv, 2) * (CASE
                                                               WHEN vol.pay_period = 1 THEN
                                                                1
                                                               WHEN vol.pay_period = 2 THEN
                                                                25 / 100
                                                               WHEN vol.pay_period > 2
                                                                    AND vol.pay_period <= 5 THEN
                                                                10 / 100
                                                               ELSE
                                                                0
                                                             END) * ROUND(vol.le, 2) *
                                           (CASE
                                              WHEN (v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN
                                               v_decrease_sav
                                              ELSE
                                               1
                                            END)
                                          ,0);
      
        UPDATE ag_perfom_work_det a
           SET a.summ = p_commission
         WHERE a.ag_perfom_work_det_id = v_apw_det_id;
      
        UPDATE ag_perfomed_work_act a
           SET a.sum = a.sum + nvl(p_commission, 0)
         WHERE a.ag_perfomed_work_act_id = v_apw_id;
      
      END LOOP;
    
    END LOOP;
  
    DELETE FROM ins.ag_perfom_work_det det WHERE det.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; v_ag_ch_id = ' ||
                              v_ag_ch_id || SQLERRM);
  END rla_management_structure;

  -- Author  : VESELEK
  -- Created : 01.10.2012
  -- Purpose : Комиссионное вознаграждение за взносы последующих лет
  PROCEDURE rla_contrib_years(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'RLA_CONTRIB_YEARS';
    v_ag_ch_id     PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_sales_ch     PLS_INTEGER;
    v_sav          NUMBER;
    v_leg_pos      PLS_INTEGER;
    v_rate_type    PLS_INTEGER;
    v_decrease_sav NUMBER := 0.8;
    v_leg_pos_recr NUMBER;
    v_sav_recr     NUMBER;
    v_is_exception NUMBER;
    v_sav_gp       NUMBER;
    v_ind_sav      NUMBER;
  BEGIN
  
    SELECT ag_contract_header_id
          ,category_id
          ,t_sales_channel_id
          ,leg_pos
          ,ag_rate_type_id
          ,tariff_agent
          ,leg_pos_recr
          ,tariff_recr
          ,is_exception
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_leg_pos
          ,v_rate_type
          ,v_sav
          ,v_leg_pos_recr
          ,v_sav_recr
          ,v_is_exception
      FROM (SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,CASE
                     WHEN ach.num = '47975' THEN
                      1
                     ELSE
                      0
                   END is_exception
                  ,apd.ag_rate_type_id
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_agent
                  ,nvl(ac_r.leg_pos, 0) leg_pos_recr
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_recr
              FROM ins.ag_perfomed_work_act apw
                  ,ins.ag_perfom_work_det apd
                  ,ins.ag_contract ac
                  ,ins.ven_ag_contract_header ach
                  ,ins.ag_contract ac_recr
                  ,(SELECT aca.contract_id
                          ,aca.ag_contract_id
                          ,aca.leg_pos
                      FROM ins.ag_contract aca
                     WHERE g_date_end BETWEEN aca.date_begin AND aca.date_end) ac_r
                  ,ins.ag_contract_header ach_recr
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND g_date_end BETWEEN ac.date_begin AND ac.date_end
               AND nvl(ach.is_new, 0) = 1
               AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
               AND ac_recr.contract_id = ac_r.contract_id(+)
               AND ac_r.contract_id = ach_recr.ag_contract_header_id(+)
            UNION
            SELECT apw.ag_contract_header_id
                  ,ac.category_id
                  ,ach.t_sales_channel_id
                  ,ac.leg_pos
                  ,CASE
                     WHEN ach.num = '47975' THEN
                      1
                     ELSE
                      0
                   END is_exception
                  ,apd.ag_rate_type_id
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_agent
                  ,nvl(ac_recr.leg_pos, 0) leg_pos_recr
                  ,(SELECT MAX(pl.t_tariff)
                      FROM ins.t_career_plan pl
                     WHERE ach_recr.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
                       AND ach_recr.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to) tariff_recr
              FROM ins.ag_perfomed_work_act   apw
                  ,ins.ag_perfom_work_det     apd
                  ,ins.ag_contract            ac
                  ,ins.ven_ag_contract_header ach
                  ,ins.ag_contract            ac_recr
                  ,ins.ag_contract_header     ach_recr
             WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
               AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
               AND ac.contract_id = apw.ag_contract_header_id
               AND ach.ag_contract_header_id = apw.ag_contract_header_id
               AND ach.last_ver_id = ac.ag_contract_id
               AND nvl(ach.is_new, 0) = 0
               AND ac.contract_recrut_id = ac_recr.ag_contract_id(+)
               AND ac_recr.contract_id = ach_recr.ag_contract_header_id(+));
  
    FOR vol IN (SELECT av.policy_header_id
                      ,av.ag_contract_header_id
                      ,av.trans_sum
                      ,(CASE
                         WHEN nvl(av.pay_period, 1) = 2 THEN
                          25 / 100
                         WHEN nvl(av.pay_period, 1) > 2
                              AND nvl(av.pay_period, 1) <= 5 THEN
                          10 / 100
                         ELSE
                          0
                       END) vol_rate
                      ,av.ag_volume_id
                      ,av.t_prod_line_option_id
                      ,av.ins_period
                      ,av.pay_period
                      ,av.trans_id
                      ,CASE
                         WHEN trm.brief = 'Единовременно' THEN
                          1
                         ELSE
                          0
                       END v_nonrec
                      ,CASE
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief != 'Единовременно' THEN
                          av.trans_sum * (CASE
                            WHEN av.ins_period > 20 THEN
                             20
                            ELSE
                             av.ins_period
                          END) / 20000
                         WHEN prod.brief IN ('END'
                                            ,'END_2'
                                            ,'END_Old'
                                            ,'Baby_LA'
                                            ,'Baby_LA2'
                                            ,'Family La'
                                            ,'Family_La2'
                                            ,'Platinum_LA'
                                            ,'Platinum_LA2'
                                            ,'Platinum_LA2_CityService'
                                            ,'CHI'
                                            ,'CHI_2'
                                            ,'CHI_Old'
                                            ,'PEPR'
                                            ,'PEPR_2'
                                            ,'PEPR_Old')
                              AND trm.brief = 'Единовременно' THEN
                          av.trans_sum / 20000 * 1.5
                         WHEN prod.brief IN ('OPS_Plus', 'OPS_Plus_2') THEN
                          av.trans_sum * 20 / 20000
                         WHEN av.ag_volume_type_id IN
                              (g_vt_ops, g_vt_ops_1, g_vt_ops_2, g_vt_ops_3, g_vt_ops_9) THEN
                          0.5
                         WHEN prod.brief IN ('RP-9', 'AUTO_EXP', 'ACC_MLN') THEN
                          av.trans_sum * 12.5 / 20000
                         WHEN prod.brief IN ('Investor', 'InvestorALFA') THEN
                          av.trans_sum / 10000
                         ELSE
                          0
                       END le
                      ,pkg_tariff_calc.calc_coeff_val('SAV_GP_' || (CASE
                                                        WHEN prod.brief IN ('PRIN_DP', 'PRIN_DP_NEW', 'PRIN_DP_NEW_CITY') THEN
                                                         25
                                                        WHEN prod.brief IN ('Baby_LA', 'Baby_LA2') THEN
                                                         14
                                                        ELSE
                                                         13
                                                      END)
                                                     ,t_number_type(v_sales_ch
                                                                   ,v_leg_pos
                                                                   ,CASE
                                                                      WHEN trm.brief = 'Единовременно' THEN
                                                                       1
                                                                      ELSE
                                                                       0
                                                                    END
                                                                   ,av.pay_period
                                                                   ,av.ins_period
                                                                   ,v_ag_ch_id
                                                                   ,decode(prod.brief
                                                                          ,'Baby_LA'
                                                                          ,2
                                                                          ,'Baby_LA2'
                                                                          ,2
                                                                          ,1))) v_sav_ul
                  FROM ins.ag_volume          av
                      ,ins.ag_roll            ar
                      ,ins.ven_ag_roll_header arh
                      ,ins.p_pol_header       ph
                      ,ins.t_product          prod
                      ,ins.t_payment_terms    trm
                      ,ins.ag_contract_header ach
                      ,ins.ag_roll_type       art
                 WHERE av.ag_roll_id = ar.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND av.policy_header_id = ph.policy_header_id(+)
                   AND av.payment_term_id = trm.id(+)
                   AND ph.product_id = prod.product_id(+)
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND nvl(arh.note, 'Не определен') != 'Фиктивная'
                   AND arh.ag_roll_type_id = art.ag_roll_type_id
                   AND art.brief = 'RLA_CASH_VOL'
                   AND nvl(av.pay_period, 1) != 1
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ins.ag_perf_work_vol     apv
                              ,ins.ag_perfom_work_det   apd
                              ,ins.ag_perfomed_work_act apw
                              ,ins.ag_roll              ar
                              ,ins.ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = v_ag_ch_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND ar.ag_roll_header_id != g_roll_header_id
                           AND apd.ag_rate_type_id = v_rate_type)
                   AND av.ag_contract_header_id = v_ag_ch_id
                   AND ach.ag_contract_header_id = av.ag_contract_header_id)
    LOOP
      IF v_is_exception = 0
      THEN
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate, vol_units, vol_decrease)
        VALUES
          (p_ag_perf_work_det_id
          ,vol.ag_volume_id
          ,(CASE WHEN v_leg_pos = 101 THEN(vol.v_sav_ul / 100) ELSE ROUND(v_sav, 2) END)
          ,(CASE WHEN v_leg_pos = 101 THEN - 1 ELSE ROUND(vol.vol_rate, 2) END)
          ,(CASE WHEN v_leg_pos = 101 THEN ROUND(vol.trans_sum, 2) ELSE ROUND(vol.le, 2) END)
          ,CASE WHEN(v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN v_decrease_sav ELSE 1 END);
      
        g_commision := g_commision +
                       nvl(ROUND(vol.vol_rate, 2) * (CASE
                                                       WHEN v_leg_pos = 101 THEN
                                                        ROUND(vol.trans_sum, 2) * (vol.v_sav_ul / 100)
                                                       ELSE
                                                        ROUND(vol.le, 2) * ROUND(v_sav, 2)
                                                     END) * (CASE
                                                               WHEN (v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN
                                                                v_decrease_sav
                                                               ELSE
                                                                1
                                                             END)
                          ,0);
        /*костыль для Ромуальда*/
      ELSE
        v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                  ,t_number_type(vol.t_prod_line_option_id, v_sales_ch));
        CASE
          WHEN v_sav_gp <= 3 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,1
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,1));
          WHEN v_sav_gp = 4 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,1));
          WHEN v_sav_gp = 5 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 1, 1));
          WHEN v_sav_gp IN (6, 7) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 1));
          WHEN v_sav_gp IN (8) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,1
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,2));
          WHEN v_sav_gp IN (9, 15, 16, 17, 18, 19) THEN
            v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_' || v_sav_gp, 1, 1);
          WHEN v_sav_gp IN (20, 23, 24) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_ag_ch_id, 2));
          WHEN v_sav_gp = 10 THEN
          
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
                                                         ,t_number_type(v_leg_pos, 1, 1, v_ins_age));
            EXCEPTION
              WHEN no_data_found THEN
                raise_application_error(-20099
                                       ,'Не удается определить возраст застрахованного');
            END;
          WHEN v_sav_gp = 11 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,1
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period
                                                                     ,v_sales_ch
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 12 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,1
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period));
          WHEN v_sav_gp = 13 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 14 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 21 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 22 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp = 25 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,v_ag_ch_id
                                                                     ,2));
          WHEN v_sav_gp IN (26, 27) THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_ag_ch_id, 2));
          WHEN v_sav_gp = 29 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,1
                                                                     ,vol.v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
          WHEN v_sav_gp = 30 THEN
            v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos, vol.pay_period, 2));
          ELSE
            v_ind_sav := 0;
        END CASE;
        v_ind_sav := nvl(v_ind_sav, 0) / 100;
      
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate, vol_units, vol_decrease)
        VALUES
          (p_ag_perf_work_det_id
          ,vol.ag_volume_id
          ,v_ind_sav
          ,1
          ,ROUND(vol.trans_sum, 2)
          ,CASE WHEN(v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN v_decrease_sav ELSE 1 END);
      
        g_commision := g_commision + nvl(v_ind_sav * ROUND(vol.trans_sum, 2) * (CASE
                                           WHEN (v_leg_pos_recr IN (1, 3) AND v_sav_recr < 660) THEN
                                            v_decrease_sav
                                           ELSE
                                            1
                                         END)
                                        ,0);
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; v_ag_ch_id = ' ||
                              v_ag_ch_id || SQLERRM);
  END;
  /**/
  PROCEDURE rla_charging_units IS
    proc_name      VARCHAR2(25) := 'RLA_CHARGING_UNITS';
    v_ag_ch_id     NUMBER;
    p_roll_unit_id NUMBER := 0;
  BEGIN
    /*личные*/
    FOR cur IN (SELECT SUM(vol_amount) detail_vol_amt
                      ,SUM(vol_units) detail_vol_rate
                      ,SUM(detail_commis) detail_commis
                      ,ag_contract_header_id
                      ,personal_units
                      ,structural_units
                  FROM (SELECT ag_contract_header_id
                              ,prem_detail_name
                              ,product
                              ,ids
                              ,pol_num
                              ,insuer
                              ,trans_sum
                              ,epg
                              ,payment_date
                              ,pay_period
                              ,ins_period
                              ,ROUND(vol_amount, 2) vol_amount
                              ,ROUND(vol_rate, 2) vol_rate
                              ,ROUND(vol_units, 2) vol_units
                              ,ROUND(vol_amount * vol_rate * vol_units, 2) detail_commis
                              ,personal_units
                              ,structural_units
                          FROM (SELECT ag_contract_header_id
                                      ,prem_detail_name
                                      ,product
                                      ,ids
                                      ,pol_num
                                      ,insuer
                                      ,SUM(trans_sum) trans_sum
                                      ,epg
                                      ,payment_date
                                      ,pay_period
                                      ,ins_period
                                      ,vol_amount
                                      ,(CASE
                                         WHEN vol_rate = -1 THEN
                                          1
                                         ELSE
                                          vol_rate
                                       END) vol_rate
                                      ,SUM(vol_units) vol_units
                                      ,personal_units
                                      ,structural_units
                                  FROM (SELECT arh.num vedom
                                              ,ar.num vedom_ver
                                              ,ts.description sales_ch
                                              ,dep.name agency
                                              ,aca.category_name
                                              ,cn_a.obj_name_orig ag_fio
                                              ,ach.num agent_num
                                              ,ach.ag_contract_header_id
                                              ,tct.description leg_pos
                                              ,leader_ach.num leader_num
                                              ,art.name prem_detail_name
                                              ,avt.description vol_type
                                              ,ach_s.num agent_ad
                                              ,cn_as.obj_name_orig agent_fio
                                              ,tp.description product
                                              ,ph.ids
                                              ,pp.pol_num
                                              ,ph.start_date
                                              ,cn_i.obj_name_orig insuer
                                              ,NULL assured_birf_date
                                              ,NULL gender
                                              ,(SELECT num
                                                  FROM ins.document d
                                                 WHERE d.document_id = av.epg_payment) epg
                                              ,av.payment_date
                                              ,tplo.description risk
                                              ,av.pay_period
                                              ,av.ins_period
                                              ,pt.description payment_term
                                              ,av.nbv_coef
                                              ,av.trans_sum
                                              ,av.index_delta_sum
                                              ,nvl(apv.vol_rate, 0) vol_rate
                                              ,nvl(apv.vol_units, 0) vol_units
                                              ,nvl(apv.vol_amount, 0) vol_amount
                                              ,apv.ag_perf_work_vol_id
                                              ,apd.ag_perfom_work_det_id
                                              ,ach.personal_units
                                              ,ach.structural_units
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
                                           AND arh.ag_roll_header_id = g_roll_header_id
                                           AND ar.ag_roll_id = g_roll_id
                                           AND arh.ag_roll_header_id = ar.ag_roll_header_id
                                           AND ar.ag_roll_id = apw.ag_roll_id
                                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                           AND apd.ag_rate_type_id = art.ag_rate_type_id
                                           AND art.brief IN ('RLA_CONTRIB_YEARS')
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
                                           AND ins.pkg_policy.get_policy_contact(ph.policy_id
                                                                                ,'Страхователь') =
                                               cn_i.contact_id
                                           AND ach.ag_contract_header_id = apw.ag_contract_header_id
                                           AND ach.ag_contract_header_id = ac.contract_id
                                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND
                                               ac.date_end
                                           AND ac.agency_id = dep.department_id
                                           AND ac.ag_sales_chn_id = ts.id
                                           AND ac.category_id = aca.ag_category_agent_id
                                           AND cn_a.contact_id = ach.agent_id
                                           AND tct.id = ac.leg_pos
                                           AND pt.id = av.payment_term_id
                                           AND NOT EXISTS
                                         (SELECT NULL
                                                  FROM ins.ag_contract            ag_rec
                                                      ,ins.ven_ag_contract_header agh_rec
                                                 WHERE ag_rec.ag_contract_id = ac.contract_recrut_id
                                                   AND ag_rec.contract_id = agh_rec.ag_contract_header_id
                                                   AND agh_rec.agent_id IN
                                                       (SELECT acha.agent_id
                                                          FROM ins.ven_ag_contract_header acha
                                                         WHERE acha.num = '2089')))
                                 GROUP BY ag_contract_header_id
                                         ,prem_detail_name
                                         ,product
                                         ,ids
                                         ,pol_num
                                         ,insuer
                                         ,epg
                                         ,payment_date
                                         ,pay_period
                                         ,ins_period
                                         ,vol_amount
                                         ,vol_rate
                                         ,personal_units
                                         ,structural_units)
                        UNION ALL
                        SELECT ag_contract_header_id
                              ,prem_detail_name
                              ,product
                              ,ids
                              ,pol_num
                              ,insuer
                              ,SUM(trans_sum) trans_sum
                              ,epg
                              ,payment_date
                              ,pay_period
                              ,ins_period
                              ,ROUND(SUM(detail_amt), 2) detail_amt
                              ,ROUND(detail_rate, 2) detail_rate
                              ,ROUND(SUM(detail_vol_units), 2) vol_units
                              ,ROUND(SUM(detail_commis), 2) detail_commis
                              ,personal_units
                              ,structural_units
                          FROM (SELECT arh.num vedom
                                      ,ar.num vedom_ver
                                      ,ts.description sales_ch
                                      ,dep.name agency
                                      ,aca.category_name
                                      ,cn_a.obj_name_orig ag_fio
                                      ,ach.num agent_num
                                      ,ach.ag_contract_header_id
                                      ,tct.description leg_pos
                                      ,leader_ach.num leader_num
                                      ,art.name prem_detail_name
                                      ,avt.description vol_type
                                      ,ach_s.num agent_ad
                                      ,cn_as.obj_name_orig agent_fio
                                      ,tp.description product
                                      ,ph.ids
                                      ,pp.pol_num
                                      ,ph.start_date
                                      ,cn_i.obj_name_orig insuer
                                      ,NULL assured_birf_date
                                      ,NULL gender
                                      ,(SELECT num
                                          FROM ins.document d
                                         WHERE d.document_id = av.epg_payment) epg
                                      ,av.payment_date
                                      ,tplo.description risk
                                      ,av.pay_period
                                      ,av.ins_period
                                      ,pt.description payment_term
                                      ,av.nbv_coef
                                      ,av.trans_sum
                                      ,av.index_delta_sum
                                      ,nvl(apv.vol_amount, 0) detail_amt
                                      ,nvl(apv.vol_rate, 0) detail_rate
                                      ,nvl(apv.vol_units, 0) detail_vol_units
                                      ,apv.vol_amount * apv.vol_rate detail_commis
                                      ,apv.ag_perf_work_vol_id
                                      ,apd.ag_perfom_work_det_id
                                      ,ach.personal_units
                                      ,ach.structural_units
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
                                   AND arh.ag_roll_header_id = g_roll_header_id
                                   AND ar.ag_roll_id = g_roll_id
                                   AND arh.ag_roll_header_id = ar.ag_roll_header_id
                                   AND ar.ag_roll_id = apw.ag_roll_id
                                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                   AND apd.ag_rate_type_id = art.ag_rate_type_id
                                   AND art.brief IN ('RLA_PERSONAL_POL')
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
                                   AND ins.pkg_policy.get_policy_contact(ph.policy_id
                                                                        ,'Страхователь') =
                                       cn_i.contact_id
                                   AND ach.ag_contract_header_id = apw.ag_contract_header_id
                                   AND ach.ag_contract_header_id = ac.contract_id
                                   AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND
                                       ac.date_end
                                   AND ac.agency_id = dep.department_id
                                   AND ac.ag_sales_chn_id = ts.id
                                   AND ac.category_id = aca.ag_category_agent_id
                                   AND cn_a.contact_id = ach.agent_id
                                   AND tct.id = ac.leg_pos
                                   AND pt.id = av.payment_term_id
                                   AND NOT EXISTS
                                 (SELECT NULL
                                          FROM ins.ag_contract            ag_rec
                                              ,ins.ven_ag_contract_header agh_rec
                                         WHERE ag_rec.ag_contract_id = ac.contract_recrut_id
                                           AND ag_rec.contract_id = agh_rec.ag_contract_header_id
                                           AND agh_rec.agent_id IN
                                               (SELECT acha.agent_id
                                                  FROM ins.ven_ag_contract_header acha
                                                 WHERE acha.num = '2089')))
                         GROUP BY ag_contract_header_id
                                 ,prem_detail_name
                                 ,product
                                 ,ids
                                 ,pol_num
                                 ,insuer
                                 ,payment_date
                                 ,pay_period
                                 ,epg
                                 ,detail_rate
                                 ,ins_period
                                 ,personal_units
                                 ,structural_units)
                 GROUP BY ag_contract_header_id
                         ,personal_units
                         ,structural_units)
    LOOP
      p_roll_unit_id := 0;
      /*либо можно p_roll_unit_id переопределить при INSERT INTO ins.ven_ag_roll_units*/
      BEGIN
        SELECT gu.ag_roll_units_id
          INTO p_roll_unit_id
          FROM ins.ven_ag_roll_units gu
         WHERE gu.ag_roll_id = g_roll_id
           AND gu.ag_contract_header_id = cur.ag_contract_header_id;
      EXCEPTION
        WHEN no_data_found THEN
          INSERT INTO ins.ven_ag_roll_units
            (ag_roll_id, ag_contract_header_id, personal_units, structural_units)
          VALUES
            (g_roll_id, cur.ag_contract_header_id, cur.personal_units, cur.structural_units);
      END;
      UPDATE ins.ag_contract_header agh
         SET agh.personal_units = nvl(agh.personal_units, 0) + nvl(cur.detail_vol_rate, 0)
       WHERE agh.ag_contract_header_id = cur.ag_contract_header_id;
    
      UPDATE ins.ven_ag_roll_units gu
         SET gu.personal_units = nvl(cur.personal_units, 0)
       WHERE gu.ag_roll_units_id = p_roll_unit_id;
    
    END LOOP;
    /*структурные*/
    FOR cut IN (SELECT SUM(vol_units) detail_rate
                      ,ag_contract_header_id
                      ,structural_units
                      ,personal_units
                  FROM (SELECT ag_contract_header_id
                              ,prem_detail_name
                              ,product
                              ,ids
                              ,pol_num
                              ,insuer
                              ,trans_sum
                              ,epg
                              ,payment_date
                              ,pay_period
                              ,ins_period
                              ,ROUND(vol_amount, 2) vol_amount
                              ,ROUND(vol_rate, 2) vol_rate
                              ,ROUND(vol_units, 2) vol_units
                              ,ROUND(vol_amount * vol_rate * vol_units, 2) detail_commis
                              ,structural_units
                              ,personal_units
                          FROM (SELECT ag_contract_header_id
                                      ,prem_detail_name
                                      ,product
                                      ,ids
                                      ,pol_num
                                      ,insuer
                                      ,SUM(trans_sum) trans_sum
                                      ,epg
                                      ,payment_date
                                      ,pay_period
                                      ,ins_period
                                      ,vol_amount
                                      ,vol_rate
                                      ,SUM(vol_units) vol_units
                                      ,structural_units
                                      ,personal_units
                                  FROM (SELECT arh.num vedom
                                              ,ar.num vedom_ver
                                              ,ts.description sales_ch
                                              ,dep.name agency
                                              ,aca.category_name
                                              ,cn_a.obj_name_orig ag_fio
                                              ,ach.num agent_num
                                              ,ach.ag_contract_header_id
                                              ,tct.description leg_pos
                                              ,leader_ach.num leader_num
                                              ,art.name prem_detail_name
                                              ,avt.description vol_type
                                              ,ach_s.num agent_ad
                                              ,cn_as.obj_name_orig agent_fio
                                              ,tp.description product
                                              ,ph.ids
                                              ,pp.pol_num
                                              ,ph.start_date
                                              ,cn_i.obj_name_orig insuer
                                              ,NULL assured_birf_date
                                              ,NULL gender
                                              ,(SELECT num
                                                  FROM ins.document d
                                                 WHERE d.document_id = av.epg_payment) epg
                                              ,av.payment_date
                                              ,tplo.description risk
                                              ,av.pay_period
                                              ,av.ins_period
                                              ,pt.description payment_term
                                              ,av.nbv_coef
                                              ,av.trans_sum
                                              ,av.index_delta_sum
                                              ,nvl(apv.vol_rate, 0) vol_rate
                                              ,nvl(apv.vol_units, 0) vol_units
                                              ,nvl(apv.vol_amount, 0) vol_amount
                                              ,apv.ag_perf_work_vol_id
                                              ,apd.ag_perfom_work_det_id
                                              ,ach.structural_units
                                              ,ach.personal_units
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
                                           AND arh.ag_roll_header_id = g_roll_header_id
                                           AND ar.ag_roll_id = g_roll_id
                                           AND arh.ag_roll_header_id = ar.ag_roll_header_id
                                           AND ar.ag_roll_id = apw.ag_roll_id
                                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                           AND apd.ag_rate_type_id = art.ag_rate_type_id
                                           AND art.brief IN ('RLA_MANAG_STRUCTURE')
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
                                           AND ins.pkg_policy.get_policy_contact(ph.policy_id
                                                                                ,'Страхователь') =
                                               cn_i.contact_id
                                           AND ach.ag_contract_header_id = apw.ag_contract_header_id
                                           AND ach.ag_contract_header_id = ac.contract_id
                                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND
                                               ac.date_end
                                           AND ac.agency_id = dep.department_id
                                           AND ac.ag_sales_chn_id = ts.id
                                           AND ac.category_id = aca.ag_category_agent_id
                                           AND cn_a.contact_id = ach.agent_id
                                           AND tct.id = ac.leg_pos
                                           AND pt.id = av.payment_term_id
                                           AND NOT EXISTS
                                         (SELECT NULL
                                                  FROM ins.ag_contract            ag_rec
                                                      ,ins.ven_ag_contract_header agh_rec
                                                 WHERE ag_rec.ag_contract_id = ac.contract_recrut_id
                                                   AND ag_rec.contract_id = agh_rec.ag_contract_header_id
                                                   AND agh_rec.agent_id IN
                                                       (SELECT acha.agent_id
                                                          FROM ins.ven_ag_contract_header acha
                                                         WHERE acha.num = '2089')))
                                 GROUP BY ag_contract_header_id
                                         ,prem_detail_name
                                         ,product
                                         ,ids
                                         ,pol_num
                                         ,insuer
                                         ,epg
                                         ,payment_date
                                         ,pay_period
                                         ,ins_period
                                         ,vol_amount
                                         ,vol_rate
                                         ,structural_units
                                         ,personal_units))
                 GROUP BY ag_contract_header_id
                         ,structural_units
                         ,personal_units)
    LOOP
      p_roll_unit_id := 0;
      /*либо можно p_roll_unit_id переопределить при INSERT INTO ins.ven_ag_roll_units*/
      BEGIN
        SELECT gu.ag_roll_units_id
          INTO p_roll_unit_id
          FROM ins.ven_ag_roll_units gu
         WHERE gu.ag_roll_id = g_roll_id
           AND gu.ag_contract_header_id = cut.ag_contract_header_id;
      EXCEPTION
        WHEN no_data_found THEN
          INSERT INTO ins.ven_ag_roll_units
            (ag_roll_id, ag_contract_header_id, structural_units, personal_units)
          VALUES
            (g_roll_id, cut.ag_contract_header_id, cut.structural_units, cut.personal_units);
      END;
      UPDATE ins.ag_contract_header agh
         SET agh.structural_units = nvl(agh.structural_units, 0) + nvl(cut.detail_rate, 0)
       WHERE agh.ag_contract_header_id = cut.ag_contract_header_id;
    
      UPDATE ins.ven_ag_roll_units gu
         SET gu.structural_units = nvl(cut.structural_units, 0)
       WHERE gu.ag_roll_units_id = p_roll_unit_id;
    
    END LOOP;
    /*общие*/
    UPDATE ins.ag_contract_header agh
       SET agh.common_units = nvl(agh.structural_units, 0) + nvl(agh.personal_units, 0)
     WHERE agh.t_sales_channel_id = g_sc_rla;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || '; v_ag_ch_id = ' ||
                              v_ag_ch_id || SQLERRM);
  END rla_charging_units;
  /**/
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 18:45:24
  -- Purpose : Расчет премии за собственные продажи
  PROCEDURE self_sale_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Self_sale_calc_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_sav_gp      PLS_INTEGER;
    v_sav         NUMBER;
    v_ind_sav     NUMBER;
    v_payed_sav   NUMBER;
    v_comon_sav   NUMBER;
    v_nonrec      PLS_INTEGER;
    v_leg_pos     PLS_INTEGER;
    -- v_qual_ops     PLS_INTEGER;
    v_rate_type        PLS_INTEGER;
    vp_ret_pay         NUMBER;
    vp_ret_snils       VARCHAR2(255);
    vp_ret_amount      NUMBER;
    vp_ret_rate        NUMBER;
    v_agent_contact_id ag_contract_header.agent_id%TYPE;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,ach.t_sales_channel_id
          ,ac.leg_pos
          ,apd.ag_rate_type_id
          ,ach.agent_id
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_leg_pos
          ,v_rate_type
          ,v_agent_contact_id
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
                      ,av.ag_volume_type_id
                      ,av.ag_contract_header_id
                      ,av.policy_header_id
                      ,av.date_begin
                      ,av.ins_period
                      ,av.payment_term_id
                      ,av.last_status
                      ,av.active_status
                      ,av.fund
                      ,av.epg_payment
                      ,av.epg_date
                      ,av.pay_period
                      ,av.epg_status
                      ,av.epg_ammount
                      ,av.epg_pd_type
                      ,av.pd_copy_status
                      ,av.pd_payment
                      ,av.pd_collection_method
                      ,av.payment_date
                      ,av.t_prod_line_option_id
                      ,av.trans_id
                      ,av.nbv_coef
                      ,av.ag_roll_id
                      ,av.is_nbv
                      ,av.conclude_date
                      ,av.payment_date_orig
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.trans_sum * 50 / 100
                         ELSE
                          av.trans_sum
                       END trans_sum
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.index_delta_sum * 50 / 100
                         ELSE
                          av.index_delta_sum
                       END index_delta_sum
                      ,(CASE
                         WHEN av.ag_volume_type_id = g_vt_ops_2
                              AND av.trans_sum = 250 THEN
                          2
                         ELSE
                          av.is_nbv
                       END) ops2_cat2
                      ,(SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,insurer.contact_id insrl
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id) agent_num_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_num_fio
                  FROM ag_volume av
                      ,ag_roll ar
                      ,ag_roll_header arh
                      ,ins.ag_roll_type art
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
                /*изменения №174670, найдем Страхователя*/
                /**/
                 WHERE ((av.ag_volume_type_id NOT IN (g_vt_nonevol, g_vt_avc, g_vt_ops_3) AND
                       g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                       (av.ag_volume_type_id NOT IN
                       (g_vt_ops, g_vt_ops_2, g_vt_ops_9, g_vt_nonevol, g_vt_avc, g_vt_ops_3) AND
                       g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                   AND av.ag_roll_id = ar.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
                   AND art.ag_roll_type_id = arh.ag_roll_type_id
                   AND art.brief = 'CASH_VOL'
                      /*изменения №174670*/
                   AND av.policy_header_id = insurer.policy_header_id(+)
                      /**/
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                              ,ag_contract_header   ch
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ch.ag_contract_header_id
                           AND ch.agent_id = v_agent_contact_id
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND ar.ag_roll_header_id != g_roll_header_id)
                   AND av.ag_contract_header_id IN (SELECT apd.ag_prev_header_id
                                                      FROM ag_prev_dog apd
                                                     WHERE apd.ag_contract_header_id = v_ag_ch_id
                                                    UNION ALL
                                                    SELECT v_ag_ch_id
                                                      FROM dual))
    LOOP
    
      v_payed_sav := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                     ,v_rate_type
                                                     ,v_ag_ch_id
                                                     ,vol.ag_volume_id);
    
      CASE
        WHEN vol.ag_volume_type_id IN (g_vt_life, g_vt_fdep) THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_num_id
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id));
          
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
                WHEN v_sav_gp <= 3 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period
                                                                           ,2));
                WHEN v_sav_gp = 4 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,v_nonrec
                                                                           ,2));
                WHEN v_sav_gp = 5 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,1
                                                                           ,2));
                WHEN v_sav_gp IN (6, 7) THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch, v_leg_pos, 2));
                WHEN v_sav_gp IN (8) THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,2
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 9 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
                WHEN v_sav_gp = 10 THEN
                
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
                                                               ,t_number_type(v_leg_pos
                                                                             ,2
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,2
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,v_sales_ch
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 12 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,2
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 29 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,vol.pay_period
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_category_id));
                WHEN v_sav_gp = 30 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,vol.pay_period
                                                                           ,2));
                  /*------------------------------------------------------------------------*/
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            END IF;
          
            CASE
              WHEN v_sav_gp <= 3 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,2));
              WHEN v_sav_gp = 4 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,v_nonrec
                                                                     ,2));
              WHEN v_sav_gp = 5 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,2));
              WHEN v_sav_gp IN (6, 7) THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 2));
              WHEN v_sav_gp IN (8) THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 9 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
              WHEN v_sav_gp = 10 THEN
              
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
                                                         ,t_number_type(v_leg_pos
                                                                       ,2
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,v_sales_ch
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 12 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 29 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,1
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
              WHEN v_sav_gp = 30 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos, vol.pay_period, 2));
                /*------------------------------------------------------------------------*/
              ELSE
                v_sav := 0;
            END CASE;
            v_sav := nvl(v_sav, 0) / 100;
          
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
                ,vol.trans_sum - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              --  g_sgp1:=g_sgp1+nvl(vol.trans_sum-NVL(vol.index_delta_sum,0),0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                --  g_sgp1:=g_sgp1+nvl(vol.index_delta_sum,0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
      
        WHEN vol.ag_volume_type_id = g_vt_inv THEN
          /*изменения №174670*/
          IF vol.insrl = vol.agent_num_id
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
          ELSE
            /**/
            --1) Определеям Группу ставок
            v_sav_gp := pkg_tariff_calc.calc_coeff_val('SAV_GROUP'
                                                      ,t_number_type(vol.t_prod_line_option_id));
          
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
                WHEN v_sav_gp <= 3 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,v_nonrec
                                                                           ,1
                                                                           ,vol.ins_period -
                                                                            vol.pay_period
                                                                           ,2));
                WHEN v_sav_gp = 4 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,v_nonrec
                                                                           ,2));
                WHEN v_sav_gp = 5 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,1
                                                                           ,2));
                WHEN v_sav_gp IN (6, 7) THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch, v_leg_pos, 2));
                WHEN v_sav_gp IN (8) THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_sales_ch
                                                                           ,v_leg_pos
                                                                           ,2
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 9 THEN
                  v_ind_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
                WHEN v_sav_gp = 10 THEN
                
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
                                                               ,t_number_type(v_leg_pos
                                                                             ,2
                                                                             ,1
                                                                             ,v_ins_age));
                  EXCEPTION
                    WHEN no_data_found THEN
                      raise_application_error(-20099
                                             ,'Не удается определить возраст застрахованного');
                  END;
                  /*-------------------------------------------*/
                WHEN v_sav_gp = 11 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,2
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period
                                                                           ,v_sales_ch
                                                                           ,-1
                                                                           ,1));
                WHEN v_sav_gp = 12 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,2
                                                                           ,1
                                                                           ,v_nonrec
                                                                           ,vol.ins_period));
                WHEN v_sav_gp = 29 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                              ,t_number_type(v_sales_ch
                                                                            ,v_leg_pos
                                                                            ,vol.pay_period
                                                                            ,1
                                                                            ,v_nonrec
                                                                           ,vol.ins_period -
                                                                            vol.pay_period + 1
                                                                           ,v_category_id));
                WHEN v_sav_gp = 30 THEN
                  v_ind_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                             ,t_number_type(v_leg_pos
                                                                           ,vol.pay_period
                                                                           ,2));
                  /*------------------------------------------------------------------------*/
                ELSE
                  v_ind_sav := 0;
              END CASE;
              v_ind_sav := nvl(v_ind_sav, 0) / 100;
            END IF;
          
            CASE
              WHEN v_sav_gp <= 3 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,v_nonrec
                                                                     ,vol.pay_period
                                                                     ,vol.ins_period
                                                                     ,2));
              WHEN v_sav_gp = 4 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,v_nonrec
                                                                     ,2));
              WHEN v_sav_gp = 5 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,2));
              WHEN v_sav_gp IN (6, 7) THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch, v_leg_pos, 2));
              WHEN v_sav_gp IN (8) THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 9 THEN
                v_sav := pkg_tariff_calc.calc_fun('SAV_GP_9', 1, 1);
              WHEN v_sav_gp = 10 THEN
              
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
                                                         ,t_number_type(v_leg_pos
                                                                       ,2
                                                                       ,vol.pay_period
                                                                       ,v_ins_age));
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20099
                                           ,'Не удается определить возраст застрахованного');
                END;
                /*-------------------------------------------*/
              WHEN v_sav_gp = 11 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period
                                                                     ,v_sales_ch
                                                                     ,-1
                                                                     ,1));
              WHEN v_sav_gp = 12 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos
                                                                     ,2
                                                                     ,vol.pay_period
                                                                     ,v_nonrec
                                                                     ,vol.ins_period));
              WHEN v_sav_gp = 29 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_leg_pos
                                                                     ,vol.pay_period
                                                                     ,1
                                                                     ,v_nonrec
                                                                     ,vol.ins_period - vol.pay_period + 1
                                                                     ,v_category_id));
              WHEN v_sav_gp = 30 THEN
                v_sav := pkg_tariff_calc.calc_coeff_val('SAV_GP_' || v_sav_gp
                                                       ,t_number_type(v_leg_pos, vol.pay_period, 2));
                /*------------------------------------------------------------------------*/
              ELSE
                v_sav := 0;
            END CASE;
            v_sav := nvl(v_sav, 0) / 100;
          
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
                ,vol.trans_sum - nvl(vol.index_delta_sum, 0)
                ,v_sav);
            
              --  g_sgp1:=g_sgp1+nvl(vol.trans_sum-NVL(vol.index_delta_sum,0),0);
              g_commision := g_commision + (vol.trans_sum - nvl(vol.index_delta_sum, 0)) * v_sav;
            
              IF nvl(vol.index_delta_sum, 0) <> 0
              THEN
              
                -- Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.index_delta_sum, v_ind_sav);
                --  g_sgp1:=g_sgp1+nvl(vol.index_delta_sum,0);
                g_commision := g_commision + nvl(vol.index_delta_sum, 0) * v_ind_sav;
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id IN (g_vt_ops, g_vt_ops_9) THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_num_fio
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
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
                   AND avt.brief IN ('NPF', 'NPF02', 'NPF(MARK9)')
                   AND art.brief = 'SS_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
                   AND art.brief = 'SS_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
              /**/
              --  IF vol.Is_Nbv = 1 THEN v_qual_ops:=1; ELSE v_qual_ops:=0; END IF;
            
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(2
                                                                   ,v_leg_pos
                                                                   ,vol.is_nbv
                                                                   ,v_sales_ch));
            
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum /** vol.nbv_coef*/, v_sav);
              
                --   g_sgp1:=g_sgp1+nvl(vol.trans_sum*vol.nbv_coef,0);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav /** vol.nbv_coef*/, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id = g_vt_ops_2 THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_num_fio
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
            g_commision := g_commision + 0;
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
                   AND art.brief = 'SS_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
                   AND art.brief = 'SS_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
              /**/
              v_sav := pkg_tariff_calc.calc_coeff_val('RATE_OPS'
                                                     ,t_number_type(2
                                                                   ,v_leg_pos
                                                                   ,vol.ops2_cat2
                                                                   ,v_sales_ch));
            
              v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
            
              IF v_payed_sav IS NULL
                 OR v_sav != 0
              THEN
              
                --3) Записываем полученные значения
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
                g_commision := g_commision + nvl(vol.trans_sum * v_sav * vol.nbv_coef, 0);
              END IF;
            END IF;
            /*изменения №174670*/
          END IF;
          /**/
        WHEN vol.ag_volume_type_id = g_vt_bank THEN
          v_sav := pkg_tariff_calc.calc_coeff_val('RATE_BANKS', t_number_type(v_sales_ch, v_leg_pos));
        
          v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
        
          IF v_payed_sav IS NULL
             OR v_sav != 0
          THEN
          
            --3) Записываем полученные значения
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum, v_sav);
            g_commision := g_commision + nvl(vol.trans_sum * v_sav, 0);
          END IF;
        WHEN vol.ag_volume_type_id = g_vt_avc_pay THEN
          /*изменения №174670*/
          IF vol.insops = vol.agent_num_fio
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
            g_commision := g_commision + 0;
          ELSE
            /**/
            v_sav := pkg_tariff_calc.calc_coeff_val('RATE_SOFI'
                                                   ,t_number_type(2, v_leg_pos, v_sales_ch));
          
            v_sav := nvl(v_sav, 0) / 100 - nvl(v_payed_sav, 0);
          
            IF v_payed_sav IS NULL
               OR v_sav != 0
            THEN
            
              --3) Записываем полученные значения
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_sav);
            
              --   g_sgp1:=g_sgp1+nvl(vol.trans_sum*vol.nbv_coef,0);
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
  END self_sale_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 17:40:44
  -- Purpose : Премия за работу группы от 25052010
  PROCEDURE work_group_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Work_group_calc_0510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_prod_gp     PLS_INTEGER;
    v_pay_period  PLS_INTEGER;
    v_rate        NUMBER;
    v_payed_rate  NUMBER;
    --v_qual_ops    PLS_INTEGER;
    v_sales_ch  PLS_INTEGER;
    v_rate_type PLS_INTEGER;
    v_leg_pos   PLS_INTEGER;
    pv_cnt_inv  PLS_INTEGER;
    /**/
    vp_ret_pay    NUMBER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
    SELECT apw.ag_level
          ,apw.ag_contract_header_id
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apd.ag_rate_type_id
          ,ac.leg_pos
      INTO v_level
          ,v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_rate_type
          ,v_leg_pos
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
          ,t_sales_channel      chac
          ,ag_contract_header   ach
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.ag_sales_chn_id = chac.id(+)
       AND ac.contract_id = apw.ag_contract_header_id
       AND ach.ag_contract_header_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT av.ag_volume_id
                      ,av.ag_volume_type_id
                      ,av.ag_contract_header_id
                      ,av.policy_header_id
                      ,av.date_begin
                      ,av.ins_period
                      ,av.payment_term_id
                      ,av.last_status
                      ,av.active_status
                      ,av.fund
                      ,av.epg_payment
                      ,av.epg_date
                      ,av.pay_period
                      ,av.epg_status
                      ,av.epg_ammount
                      ,av.epg_pd_type
                      ,av.pd_copy_status
                      ,av.pd_payment
                      ,av.pd_collection_method
                      ,av.payment_date
                      ,av.t_prod_line_option_id
                      ,av.trans_id
                      ,av.nbv_coef
                      ,av.ag_roll_id
                      ,av.is_nbv
                      ,av.conclude_date
                      ,av.payment_date_orig
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.trans_sum * 50 / 100
                         ELSE
                          av.trans_sum
                       END trans_sum
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.index_delta_sum * 50 / 100
                         ELSE
                          av.index_delta_sum
                       END index_delta_sum
                      ,insurer.product_id
                      ,(SELECT upper(anv.fio)
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) insops
                      ,insurer.contact_id insrl
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id) agent_av_num_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = av.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_av_num_fio
                      ,(SELECT agh.agent_id
                          FROM ins.ag_contract_header agh
                         WHERE agh.ag_contract_header_id = tv.ag_contract_header_id) agent_tv_num_id
                      ,(SELECT upper(c.obj_name_orig)
                          FROM ins.ag_contract_header agh
                              ,ins.contact            c
                         WHERE agh.ag_contract_header_id = tv.ag_contract_header_id
                           AND agh.agent_id = c.contact_id) agent_tv_num_fio
                  FROM temp_vol_calc tv
                      ,ag_volume av
                      ,(SELECT ph.policy_header_id
                              ,ppc.contact_id
                              ,ph.product_id
                          FROM ins.p_pol_header       ph
                              ,ins.p_policy           pol
                              ,ins.p_policy_contact   ppc
                              ,ins.t_contact_pol_role polr
                         WHERE ph.last_ver_id = pol.policy_id
                           AND pol.policy_id = ppc.policy_id
                           AND ppc.contact_policy_role_id = polr.id
                           AND polr.brief = 'Страхователь') insurer
                /*изменения №261399, найдем Страхователя*/
                 WHERE tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id = v_ag_ch_id
                      /*---чтоб некоторым тердирам не входили банки---*/
                   AND (CASE
                         WHEN av.ag_contract_header_id IN (26101892, 25873698, 30707667)
                              AND tv.ag_contract_header_id IN (21813000, 21822653, 24763393) THEN
                          0
                         ELSE
                          1
                       END) = 1
                      /*-----*/
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_contract          ac
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ac.contract_id
                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                           AND (decode(ac.category_id, 20, 4, ac.category_id) =
                               decode(v_category_id, 20, 4, v_category_id) OR
                               ac.contract_id = v_ag_ch_id)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND arh.ag_roll_header_id != g_roll_header_id)
                      /* AND (arh.ag_roll_type_id != g_roll_type
                      OR (apd.ag_rate_type_id = v_rate_type
                          AND arh.ag_roll_header_id != g_roll_header_id)))*/
                   AND av.policy_header_id = insurer.policy_header_id(+)
                   AND ((av.ag_volume_type_id NOT IN (g_vt_avc, g_vt_nonevol, g_vt_ops_3, g_vt_ops_9) AND
                       g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                       (av.ag_volume_type_id NOT IN
                       (g_vt_ops, g_vt_ops_2, g_vt_ops_9, g_vt_avc, g_vt_nonevol, g_vt_ops_3) AND
                       g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                   AND av.is_nbv = 1
                   AND (av.ag_volume_type_id IN
                       (g_vt_life, g_vt_avc_pay, g_vt_inv, g_vt_bank, g_vt_fdep) OR
                       v_sales_ch = g_sc_dsf OR
                       (v_category_id = g_cat_td_id AND v_sales_ch = g_sc_sas)))
    LOOP
    
      v_payed_rate := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                      ,v_rate_type
                                                      ,v_ag_ch_id
                                                      ,vol.ag_volume_id);
    
      CASE
        WHEN vol.ag_volume_type_id IN (g_vt_life, g_vt_avc_pay, g_vt_fdep) THEN
        
          /*изменения №261399*/
          IF vol.insrl = vol.agent_av_num_id
             AND vol.insrl = vol.agent_tv_num_id
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
          ELSE
          
            IF vol.ag_volume_type_id = g_vt_avc_pay
            THEN
              v_prod_gp    := 2;
              v_pay_period := 1;
            ELSE
              v_prod_gp    := nvl(pkg_tariff_calc.calc_coeff_val('PROD_MNG_GP'
                                                                ,t_number_type(vol.product_id))
                                 ,0);
              v_pay_period := vol.pay_period;
            END IF;
          
            IF nvl(vol.index_delta_sum, 0) <> 0
            THEN
            
              v_rate := pkg_tariff_calc.calc_coeff_val('GP_WORK_RATE'
                                                      ,t_number_type(v_category_id
                                                                    ,v_level
                                                                    ,v_prod_gp
                                                                    ,1
                                                                    ,v_sales_ch));
              v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
            
              IF v_payed_rate IS NULL
                 OR v_rate != 0
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id
                  ,vol.ag_volume_id
                  ,vol.index_delta_sum * vol.nbv_coef
                  ,v_rate);
              
                g_commision := g_commision + nvl(vol.index_delta_sum * v_rate * vol.nbv_coef, 0);
              END IF;
            ELSE
              v_rate := pkg_tariff_calc.calc_coeff_val('GP_WORK_RATE'
                                                      ,t_number_type(v_category_id
                                                                    ,v_level
                                                                    ,v_prod_gp
                                                                    ,v_pay_period
                                                                    ,v_sales_ch));
            
              v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
            
              IF v_payed_rate IS NULL
                 OR v_rate != 0
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id
                  ,vol.ag_volume_id
                  ,(nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)) * vol.nbv_coef
                  ,v_rate);
              
                g_commision := g_commision + (nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)) *
                               v_rate * vol.nbv_coef;
              END IF;
            END IF;
          END IF;
        WHEN vol.ag_volume_type_id IN (g_vt_inv, g_vt_fdep) THEN
          /*изменения №261399*/
          IF vol.insrl = vol.agent_av_num_id
             AND vol.insrl = vol.agent_tv_num_id
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
          ELSE
          
            SELECT COUNT(*)
              INTO pv_cnt_inv
              FROM ins.ag_perf_work_vol     wol
                  ,ins.ag_perfom_work_det   det
                  ,ins.ag_perfomed_work_act act
                  ,ins.ag_volume            agv
             WHERE wol.ag_volume_id = agv.ag_volume_id
               AND wol.ag_perfom_work_det_id = det.ag_perfom_work_det_id
               AND det.ag_rate_type_id =
                   (SELECT art.ag_rate_type_id FROM ins.ag_rate_type art WHERE art.brief = 'WG_0510')
               AND agv.ag_volume_id = vol.ag_volume_id
               AND act.ag_perfomed_work_act_id = det.ag_perfomed_work_act_id
               AND act.ag_contract_header_id = v_ag_ch_id
               AND agv.policy_header_id = vol.policy_header_id
               AND agv.trans_sum = vol.trans_sum
               AND agv.t_prod_line_option_id = vol.t_prod_line_option_id;
          
            IF pv_cnt_inv = 0
            THEN
            
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
            
            END IF;
          
          END IF;
        WHEN vol.ag_volume_type_id IN (g_vt_ops) THEN
          /*изменения №261399*/
          IF vol.insops = vol.agent_av_num_fio
             AND vol.insops = vol.agent_tv_num_fio
          THEN
            INSERT INTO ven_ag_perf_work_vol
              (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
            VALUES
              (p_ag_perf_work_det_id, vol.ag_volume_id, 0, 0);
          
            g_commision := g_commision + 0;
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
                   AND art.brief = 'WG_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 0
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
                   AND art.brief = 'WG_0510'
                   AND anv.snils = vp_ret_snils
                   AND nvl(anv.from_ret_to_pay, 0) = 99
                   AND apw.ag_contract_header_id = v_ag_ch_id
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
              v_rate := pkg_tariff_calc.calc_coeff_val('MND_RATE_OPS'
                                                      ,t_number_type(v_category_id
                                                                    ,v_level
                                                                    ,vol.is_nbv
                                                                    ,v_sales_ch));
              v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
            
              IF v_payed_rate IS NULL
                 OR v_rate != 0
              THEN
                INSERT INTO ven_ag_perf_work_vol
                  (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
                VALUES
                  (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_rate);
              
                g_commision := g_commision + vol.trans_sum * v_rate * vol.nbv_coef;
              END IF;
            END IF;
          END IF;
        WHEN vol.ag_volume_type_id = g_vt_bank THEN
          IF v_category_id = g_catag_mn
          THEN
            v_rate := pkg_tariff_calc.calc_coeff_val('RATE_BANKS'
                                                    ,t_number_type(v_sales_ch, v_leg_pos));
            v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
            IF v_payed_rate IS NULL
               OR v_rate != 0
            THEN
              INSERT INTO ven_ag_perf_work_vol
                (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
              VALUES
                (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_rate);
            
              g_commision := g_commision + vol.trans_sum * v_rate * vol.nbv_coef;
            END IF;
          END IF;
        ELSE
          NULL;
      END CASE;
    
    /*для лога
                                                   insert into tmp$_work_group (t_ag_perf_work_det_id,
                                                            t_payed_rate,
                                                            t_volume_type_id,
                                                            t_prod_gp,
                                                            t_pay_period,
                                                            t_rate,
                                                            t_commision,
                                                            t_ag_ch_id,
                                                            t_trans_sum,
                                                            t_nbv_coef)
                                                   values (p_ag_perf_work_det_id,
                                                            v_payed_rate,
                                                            vol.ag_volume_type_id,
                                                            v_prod_gp,
                                                            v_pay_period,
                                                            v_rate,
                                                            g_commision,
                                                            v_ag_ch_id,
                                                            vol.trans_sum,
                                                            vol.nbv_coef);*/
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END work_group_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.06.2010 11:40:14
  -- Purpose : Премия за ДС 2-5 годов действия
  PROCEDURE renew_policy_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Renew_policy_calc_0510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_prod_gp     PLS_INTEGER;
    v_rate        NUMBER;
    v_payed_rate  NUMBER;
    v_sales_ch    PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
  BEGIN
  
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
  
    FOR vol IN (SELECT av.*
                      ,ph.product_id
                  FROM temp_vol_calc tv
                      ,ag_volume     av
                      ,p_pol_header  ph
                 WHERE tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id = v_ag_ch_id
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_contract          ac
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ac.contract_id
                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                           AND (decode(ac.category_id, 20, 4, ac.category_id) =
                               decode(v_category_id, 20, 4, v_category_id) OR
                               ac.contract_id = v_ag_ch_id)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND arh.ag_roll_header_id != g_roll_header_id)
                      /* AND (arh.ag_roll_type_id != g_roll_type
                      OR (apd.ag_rate_type_id = v_rate_type
                         AND arh.ag_roll_header_id != g_roll_header_id)))*/
                   AND tv.ag_contract_header_id = v_ag_ch_id
                   AND av.policy_header_id = ph.policy_header_id(+)
                   AND av.pay_period > 1
                      --         AND (av.nbv_coef = 0 OR av.index_delta_sum <> 0)
                   AND av.ag_volume_type_id IN (g_vt_life) -- NOT IN (g_vt_AVC, g_vt_NoneVol)
                )
    LOOP
    
      v_payed_rate := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                      ,v_rate_type
                                                      ,v_ag_ch_id
                                                      ,vol.ag_volume_id);
    
      v_prod_gp := nvl(pkg_tariff_calc.calc_coeff_val('PROD_MNG_GP', t_number_type(vol.product_id)), 0);
    
      v_rate := pkg_tariff_calc.calc_coeff_val('GP_WORK_RATE'
                                              ,t_number_type(v_category_id
                                                            ,v_level
                                                            ,v_prod_gp
                                                            ,vol.pay_period
                                                            ,v_sales_ch));
    
      v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
    
      IF v_payed_rate IS NULL
         OR v_rate != 0
      THEN
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id
          ,vol.ag_volume_id
          ,nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)
          ,v_rate);
      
        g_commision := g_commision + (nvl(vol.trans_sum, 0) - nvl(vol.index_delta_sum, 0)) * v_rate;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END renew_policy_calc_0510;

  FUNCTION get_new_child_agent_count
  (
    par_ag_contract_header_id NUMBER
   ,par_vol_roll_header_id    NUMBER
   ,par_date_begin            DATE
   ,par_date_end              DATE
   ,par_min_volume            NUMBER
  ) RETURN NUMBER IS
    v_new_ag_count NUMBER;
  BEGIN
    WITH ag_tree AS
     (SELECT agt.ag_contract_header_id
        FROM ag_agent_tree agt
       WHERE doc.get_doc_status_brief(agt.ag_contract_header_id, par_date_end) = 'CURRENT'
         AND (SELECT ah.date_begin
                FROM ag_contract_header ah
               WHERE ah.ag_contract_header_id = agt.ag_contract_header_id) BETWEEN par_date_begin AND
             par_date_end
       START WITH agt.ag_parent_header_id = par_ag_contract_header_id
      CONNECT BY PRIOR agt.ag_contract_header_id = agt.ag_parent_header_id
             AND par_date_end BETWEEN agt.date_begin AND agt.date_end)
    SELECT COUNT(*)
      INTO v_new_ag_count
      FROM (SELECT at.ag_contract_header_id
              FROM ag_volume      av
                  ,ag_roll_header rh
                  ,ag_roll        rr
                  ,ag_tree        at
             WHERE rh.ag_roll_header_id = par_vol_roll_header_id
               AND rh.ag_roll_header_id = rr.ag_roll_header_id
               AND rr.ag_roll_id = av.ag_roll_id
               AND av.ag_contract_header_id = at.ag_contract_header_id
             GROUP BY at.ag_contract_header_id
            HAVING SUM(av.trans_sum) >= par_min_volume);
  
    RETURN v_new_ag_count;
  
  END get_new_child_agent_count;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 19:09:30
  -- Purpose : Премия за достижение уровня
  PROCEDURE reach_level_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name                 VARCHAR2(25) := 'Reach_level_calc_0510';
    v_level                   PLS_INTEGER;
    v_ag_ch_id                PLS_INTEGER;
    v_category_id             PLS_INTEGER;
    v_rate_type               PLS_INTEGER;
    v_sales_ch_id             PLS_INTEGER;
    v_activity_meetings_count ag_perfomed_work_act.activity_meetings_count%TYPE;
    v_new_ag_count            NUMBER;
  BEGIN
    SELECT apw.ag_level
          ,ac.category_id
          ,apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.activity_meetings_count
      INTO v_level
          ,v_category_id
          ,v_ag_ch_id
          ,v_rate_type
          ,v_sales_ch_id
          ,v_activity_meetings_count
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
       AND ach.ag_contract_header_id = ac.contract_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    v_new_ag_count := get_new_child_agent_count(par_ag_contract_header_id => v_ag_ch_id
                                               ,par_vol_roll_header_id    => g_vol_roll_header_id
                                               ,par_date_begin            => g_date_begin
                                               ,par_date_end              => g_date_end
                                               ,par_min_volume            => 6000);
  
    g_commision := coalesce(pkg_tariff_calc.calc_coeff_val(p_brief => 'REACH_LEVEL_PREMIUM'
                                                          ,p_attrs => t_number_type(v_category_id
                                                                                   ,v_level
                                                                                   ,v_activity_meetings_count
                                                                                   ,v_new_ag_count))
                           ,0);
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    IF g_commision != 0
    THEN
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ext_perform_work_det_id)
        SELECT p_ag_perf_work_det_id
              ,apd.ag_perfom_work_det_id
          FROM ag_perfomed_work_act apw
              ,ag_perfom_work_det   apd
         WHERE apw.ag_roll_id = g_roll_id
           AND apw.ag_contract_header_id = v_ag_ch_id
           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
           AND apd.ag_rate_type_id IN
               (SELECT arte.ag_rate_type_id
                  FROM ag_av_type_conform avt
                      ,ag_rate_type_ext   arte
                 WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                   AND avt.ag_roll_type_id = g_roll_type
                   AND avt.ag_rate_type_id = v_rate_type
                   AND avt.ag_category_agent_id = v_category_id
                   AND avt.t_sales_channel_id = v_sales_ch_id);
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END reach_level_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 19:17:06
  -- Purpose : Премия за достижение КСП
  PROCEDURE reach_ksp_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(25) := 'Reach_KSP_calc_0510';
    v_ag_ch_id     PLS_INTEGER;
    v_level        PLS_INTEGER;
    v_ksp          NUMBER;
    v_all_nbv      NUMBER;
    v_category_id  PLS_INTEGER;
    v_rate         NUMBER;
    v_rate_type    PLS_INTEGER;
    v_sales_ch_id  PLS_INTEGER;
    v_work_act_id  PLS_INTEGER;
    v_vol_investor PLS_INTEGER;
    ext_det_rate   NUMBER := 0;
  BEGIN
    SELECT apw.ag_level
          ,ac.category_id
          ,apw.ag_contract_header_id
          ,apw.ag_ksp
          ,CASE
             WHEN ac.category_id = g_catag_mn THEN
              apw.volumes.get_volume(g_vt_life) + apw.volumes.get_volume(g_vt_ops) +
              apw.volumes.get_volume(g_vt_avc_pay) + apw.volumes.get_volume(g_vt_bank) +
              apw.volumes.get_volume(g_vt_fdep) * 0.5
             ELSE
              apw.volumes.get_volume(g_vt_life) + apw.volumes.get_volume(g_vt_ops) +
              apw.volumes.get_volume(g_vt_avc_pay) + apw.volumes.get_volume(g_vt_fdep) * 0.5
           END
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_perfomed_work_act_id
      INTO v_level
          ,v_category_id
          ,v_ag_ch_id
          ,v_ksp
          ,v_all_nbv
          ,v_rate_type
          ,v_sales_ch_id
          ,v_work_act_id
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
       AND ach.ag_contract_header_id = ac.contract_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    IF v_level >= 3
    THEN
    
      IF v_category_id = 3
      THEN
        v_rate := 0.02;
      ELSE
        v_rate := 0.01;
      END IF;
    
      CASE
        WHEN v_ksp >= 60
             AND v_ksp < 75 THEN
          g_commision  := v_all_nbv * v_rate;
          ext_det_rate := v_rate;
        WHEN v_ksp >= 75 THEN
          g_commision  := v_all_nbv * v_rate * 2;
          ext_det_rate := v_rate * 2;
        ELSE
          g_commision  := 0;
          ext_det_rate := 0;
      END CASE;
    
    END IF;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    IF g_commision != 0
    THEN
      FOR ext_det IN (SELECT apd.ag_perfom_work_det_id
                            ,wol.ag_volume_id
                            ,wol.vol_amount
                        FROM ins.ag_perfomed_work_act apw
                            ,ins.ag_perfom_work_det   apd
                            ,ins.ag_perf_work_vol     wol
                       WHERE apw.ag_roll_id = g_roll_id
                         AND apw.ag_contract_header_id = v_ag_ch_id
                         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                         AND apd.ag_perfom_work_det_id = wol.ag_perfom_work_det_id
                         AND apd.ag_rate_type_id IN
                             (SELECT arte.ag_rate_type_id
                                FROM ag_av_type_conform avt
                                    ,ag_rate_type_ext   arte
                               WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                                 AND avt.ag_roll_type_id = g_roll_type
                                 AND avt.ag_rate_type_id = v_rate_type
                                 AND avt.ag_category_agent_id = v_category_id
                                 AND avt.t_sales_channel_id = v_sales_ch_id)
                      /*SELECT apd.ag_perfom_work_det_id
                       FROM ag_perfomed_work_act apw
                           ,ag_perfom_work_det   apd
                      WHERE apw.ag_roll_id = g_roll_id
                        AND apw.ag_contract_header_id = v_ag_ch_id
                        AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                        AND apd.ag_rate_type_id IN
                            (SELECT arte.ag_rate_type_id
                               FROM ag_av_type_conform avt
                                   ,ag_rate_type_ext   arte
                              WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                                AND avt.ag_roll_type_id = g_roll_type
                                AND avt.ag_rate_type_id = v_rate_type
                                AND avt.ag_category_agent_id = v_category_id
                                AND avt.t_sales_channel_id = v_sales_ch_id)*/
                      )
      LOOP
      
        INSERT INTO ins.ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ext_perform_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id
          ,ext_det.ag_perfom_work_det_id
          ,ext_det.ag_volume_id
          ,ext_det.vol_amount
          ,ext_det_rate);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END reach_ksp_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.06.2010 19:39:37
  -- Purpose : Премия за достижение индивидуального плана
  PROCEDURE exec_plan_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name                 VARCHAR2(25) := 'Exec_plan_calc_0510';
    v_ag_ch_id                PLS_INTEGER;
    v_level                   PLS_INTEGER;
    v_sales_ch                PLS_INTEGER;
    v_all_nbv                 NUMBER;
    v_category_id             PLS_INTEGER;
    v_plan                    NUMBER;
    v_rate_type               PLS_INTEGER;
    v_all_nbv_prev            NUMBER := -1;
    v_all_policy              NUMBER := 0;
    v_no_policy               NUMBER := 0;
    v_cur_policy              NUMBER := 0;
    v_activity_meetings_count NUMBER;
    v_all_volume              NUMBER;
  
    v_new_ag_count NUMBER;
  BEGIN
    SELECT apw.ag_level
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_contract_header_id
          ,apw.volumes.get_volume(g_vt_life) + apw.volumes.get_volume(g_vt_inv) +
           apw.volumes.get_volume(g_vt_fdep) + apw.volumes.get_volume(g_vt_ops) +
           apw.volumes.get_volume(g_vt_ops_2) + apw.volumes.get_volume(g_vt_ops_3) +
           apw.volumes.get_volume(g_vt_avc) + apw.volumes.get_volume(g_vt_bank)
          ,apd.ag_rate_type_id
          ,apw.activity_meetings_count
      INTO v_level
          ,v_category_id
          ,v_sales_ch
          ,v_ag_ch_id
          ,v_all_nbv
          ,v_rate_type
          ,v_activity_meetings_count
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
       AND ach.ag_contract_header_id = ac.contract_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
    /*для заявки №266297*/
    BEGIN
      SELECT apw.volumes.get_volume(g_vt_life) + apw.volumes.get_volume(g_vt_inv) +
             apw.volumes.get_volume(g_vt_fdep) + apw.volumes.get_volume(g_vt_ops) +
             apw.volumes.get_volume(g_vt_ops_2) + apw.volumes.get_volume(g_vt_ops_3) +
             apw.volumes.get_volume(g_vt_avc) + apw.volumes.get_volume(g_vt_bank)
        INTO v_all_nbv_prev
        FROM ins.ag_perfomed_work_act apw
            ,ins.ag_perfom_work_det   apd
            ,ins.ven_ag_roll          ar
            ,ins.ag_roll_header       arh
            ,ins.ag_rate_type         t
       WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND apw.ag_contract_header_id = v_ag_ch_id
         AND apw.ag_roll_id = ar.ag_roll_id
         AND ar.ag_roll_header_id = arh.ag_roll_header_id
         AND apd.ag_rate_type_id = t.ag_rate_type_id
         AND t.brief = 'PEXEC_0510'
         AND arh.ag_roll_header_id = g_roll_header_id
         AND ar.ag_roll_id = (SELECT ar2.ag_roll_id
                                FROM ins.ven_ag_roll    ar1
                                    ,ins.ag_roll_header arh
                                    ,ins.ven_ag_roll    ar2
                               WHERE ar1.ag_roll_header_id = g_roll_header_id
                                 AND ar1.ag_roll_id = g_roll_id
                                 AND ar2.ag_roll_header_id = arh.ag_roll_header_id
                                 AND ar1.ag_roll_header_id = arh.ag_roll_header_id
                                 AND ar2.num = ar1.num - 1);
    EXCEPTION
      WHEN no_data_found THEN
        v_all_nbv_prev := -1;
    END;
  
    /*
      349280
      Получение новых агентов с объемом болье 6000
    */
    v_new_ag_count := get_new_child_agent_count(par_ag_contract_header_id => v_ag_ch_id
                                               ,par_vol_roll_header_id    => g_vol_roll_header_id
                                               ,par_date_begin            => g_date_begin
                                               ,par_date_end              => g_date_end
                                               ,par_min_volume            => 6000);
  
    /*При этом, если сумма "премии за выполнение индивидуального плана" не изменилась
      по сравнению с предыдущими версиями, повторно в размазку премия входить не должна.
      Если же сумма изменилась, то необходимо осуществить размазку по договорам всех версий,
      если сумма премии была =0 всей премии, и по договорам только последней версии разницы,
      если сумма премии ранее была >0, но меньше, чем после расчета последней версии
    */
    IF v_all_nbv_prev != -1
    THEN
      IF (v_all_nbv - v_all_nbv_prev) = v_all_nbv_prev
      THEN
        -- Не надо размазыват
        v_no_policy := 1;
      ELSIF (v_all_nbv - v_all_nbv_prev) != 0
            AND v_all_nbv_prev = 0
      THEN
        v_all_policy := 1;
      ELSIF v_all_nbv_prev > 0
            AND v_all_nbv_prev < (v_all_nbv - v_all_nbv_prev)
      THEN
        v_cur_policy := 1;
      END IF;
    END IF;
    /**/
    v_plan := pkg_ag_calc_admin.get_plan_0510(v_ag_ch_id, 1, g_date_end);
  
    IF v_plan != 0
       AND v_all_nbv >= v_plan
    THEN
      g_commision := coalesce(pkg_tariff_calc.calc_coeff_val(p_brief => 'REACH_PLAN_PREMIUM'
                                                            ,p_attrs => t_number_type(v_category_id
                                                                                     ,v_level
                                                                                     ,v_activity_meetings_count
                                                                                     ,v_new_ag_count))
                             ,0);
    END IF;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    IF g_commision != 0
       AND v_all_nbv_prev = -1
       AND v_no_policy = 0
    THEN
      FOR ext_det IN (SELECT apd.ag_perfom_work_det_id
                            ,wol.ag_volume_id
                            ,CASE
                               WHEN avt.brief IN ('INV', 'SOFI') THEN
                                agv.trans_sum * agv.nbv_coef
                               WHEN avt.brief = 'FDep' THEN
                                wol.vol_amount * 2
                               ELSE
                                wol.vol_amount
                             END vol_amount
                            ,CASE
                               WHEN v_all_nbv = 0 THEN
                                0
                               ELSE
                                g_commision / v_all_nbv
                             END vol_rate
                        FROM ins.ag_perfomed_work_act apw
                            ,ins.ag_perfom_work_det   apd
                            ,ins.ag_perf_work_vol     wol
                            ,ins.ag_volume            agv
                            ,ins.ag_volume_type       avt
                       WHERE ((apw.ag_roll_id = g_roll_id AND
                             (v_cur_policy = 1 OR
                             (SELECT ar.num FROM ins.ven_ag_roll ar WHERE ar.ag_roll_id = g_roll_id) = 1)) OR
                             (apw.ag_roll_id IN
                             (SELECT ar.ag_roll_id
                                  FROM ins.ag_roll ar
                                 WHERE ar.ag_roll_header_id = g_roll_header_id) AND v_all_policy = 1))
                         AND apw.ag_contract_header_id = v_ag_ch_id
                         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                         AND apd.ag_perfom_work_det_id = wol.ag_perfom_work_det_id
                         AND wol.ag_volume_id = agv.ag_volume_id
                         AND agv.ag_volume_type_id = avt.ag_volume_type_id
                         AND apd.ag_rate_type_id IN
                             (SELECT arte.ag_rate_type_id
                                FROM ag_av_type_conform avt
                                    ,ag_rate_type_ext   arte
                               WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                                 AND avt.ag_roll_type_id = g_roll_type
                                 AND avt.ag_rate_type_id = v_rate_type
                                 AND avt.ag_category_agent_id = v_category_id
                                 AND avt.t_sales_channel_id = v_sales_ch))
      LOOP
        dml_ag_perf_work_vol.insert_record(par_ag_volume_id            => ext_det.ag_volume_id
                                          ,par_ag_perfom_work_det_id   => p_ag_perf_work_det_id
                                          ,par_vol_amount              => ext_det.vol_amount
                                          ,par_vol_rate                => ext_det.vol_rate
                                          ,par_ext_perform_work_det_id => ext_det.ag_perfom_work_det_id);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      g_commision := 0;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END exec_plan_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.06.2010 10:47:22
  -- Purpose : Премия за выращенных руководителей
  PROCEDURE evol_sub_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Evol_sub_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_wg_sum      NUMBER := 0;
    v_rate_type   PLS_INTEGER;
    v_paid_prem   NUMBER;
    v_sale_ch     PLS_INTEGER;
    v_category_id PLS_INTEGER;
  BEGIN
  
    SELECT decode(ac.category_id, 20, 4, ac.category_id)
          ,apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
      INTO v_category_id
          ,v_ag_ch_id
          ,v_rate_type
          ,v_sale_ch
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
  
    FOR evolved IN (SELECT apd.summ
                          ,apd.ag_perfom_work_det_id
                      FROM ag_roll              ar
                          ,ag_perfomed_work_act apw
                          ,ag_perfom_work_det   apd
                     WHERE ar.ag_roll_header_id = g_roll_header_id
                       AND ar.ag_roll_id = apw.ag_roll_id
                       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                       AND apd.summ != 0
                       AND apd.ag_rate_type_id IN
                           (SELECT arte.ag_rate_type_id
                              FROM ag_av_type_conform avt
                                  ,ag_rate_type_ext   arte
                             WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                               AND avt.ag_roll_type_id = g_roll_type
                               AND avt.ag_rate_type_id = v_rate_type
                               AND avt.ag_category_agent_id = v_category_id
                               AND avt.t_sales_channel_id = v_sale_ch)
                       AND apw.ag_contract_header_id IN
                           (SELECT ag_contract_header_id
                              FROM (SELECT ach.ag_contract_header_id
                                          ,ins.pkg_ag_calc_admin.get_operation_months(nvl(pkg_ag_calc_admin.get_cat_date(apd.ag_prev_header_id
                                                                                                                        ,'26.04.2010'
                                                                                                                        ,ac.category_id)
                                                                                         ,MIN(ac.date_begin)
                                                                                          over(PARTITION BY
                                                                                               ach.ag_contract_header_id))
                                                                                     ,least(MAX(ac.date_end)
                                                                                            over(PARTITION BY
                                                                                                 ach.ag_contract_header_id)
                                                                                           ,g_date_end)) after_cat
                                          ,
                                           
                                           CASE
                                             WHEN nvl(chac.id, ach.t_sales_channel_id) = g_sc_sas
                                                  AND EXISTS (SELECT NULL
                                                     FROM ag_prev_dog a
                                                    WHERE a.company = 'NPF'
                                                      AND a.ag_contract_header_id =
                                                          ach.ag_contract_header_id) THEN
                                              1
                                             WHEN nvl(chac.id, ach.t_sales_channel_id) = g_sc_sas_2
                                                  AND EXISTS (SELECT NULL
                                                     FROM ag_prev_dog a
                                                    WHERE a.company = 'NPF'
                                                      AND a.ag_contract_header_id =
                                                          ach.ag_contract_header_id) THEN
                                              1
                                             ELSE
                                             
                                              ins.pkg_ag_calc_admin.get_operation_months(MIN(nvl(ach_p.date_begin
                                                                                                ,ach.date_begin))
                                                                                         over(PARTITION BY
                                                                                              ach.ag_contract_header_id)
                                                                                        ,nvl(pkg_ag_calc_admin.get_cat_date(apd.ag_prev_header_id
                                                                                                                           ,'26.04.2010'
                                                                                                                           ,ac.category_id)
                                                                                            ,MIN(ac.date_begin)
                                                                                             over(PARTITION BY
                                                                                                  ach.ag_contract_header_id)))
                                           
                                           END before_cat
                                    
                                      FROM ven_ag_contract_header ach
                                          , --Выращенный новый АД
                                           ag_contract ac
                                          , --Выращенный новый АД
                                           t_sales_channel chac
                                          ,(SELECT *
                                              FROM ag_prev_dog a
                                             WHERE a.company = 'Реннесанс Жизнь') apd
                                          , --Выращенный ссылка на старый АД
                                           ag_contract_header ach_p --Выращенный старый АД
                                     WHERE 1 = 1
                                       AND nvl(ach.is_new, 1) = 1
                                       AND ach.ag_contract_header_id = apd.ag_contract_header_id(+)
                                       AND apd.ag_prev_header_id = ach_p.ag_contract_header_id(+)
                                       AND ac.contract_id = ach.ag_contract_header_id
                                       AND ac.ag_sales_chn_id = chac.id(+)
                                       AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                                       AND (SELECT ac1.contract_id
                                              FROM ag_contract ac1
                                             WHERE ac1.ag_contract_id = ac.contract_f_lead_id) =
                                           v_ag_ch_id
                                       AND decode(ac.category_id, 20, 4, ac.category_id) = v_category_id)
                             WHERE after_cat <=
                                   decode(v_sale_ch, g_sc_dsf, 12, g_sc_sas, 6, g_sc_sas_2, 6, 12)
                               AND (before_cat >= 1 OR v_category_id IN (50, 20, 4)))
                          /*Рассчитывается АВ за развитие и рекрутинг менеджерам и директорам 
                          которые уже уволены. Необходимо сделать условие, чтобы данное АВ не 
                          рассчитывалось. (пример Куриленко М.Ф., уволена в феврале, а АВ за 
                          развитие ей начисляется)*/
                       AND NOT EXISTS (SELECT NULL
                              FROM ins.ag_documents   agd
                                  ,ins.ag_doc_type    ad
                                  ,ins.document       d
                                  ,ins.doc_status_ref rf
                             WHERE agd.ag_contract_header_id = v_ag_ch_id
                               AND agd.ag_doc_type_id = ad.ag_doc_type_id
                               AND ad.brief = 'BREAK_AD'
                               AND agd.ag_documents_id = d.document_id
                               AND d.doc_status_ref_id = rf.doc_status_ref_id
                               AND rf.brief = 'CONFIRMED'
                               AND agd.doc_date <= g_date_end))
    LOOP
      FOR evolved_vol IN (SELECT wv.ag_volume_id
                                ,wv.vol_amount
                                ,wv.vol_rate * (CASE
                                   WHEN v_sale_ch = g_sc_dsf THEN
                                    0.5
                                   ELSE
                                    0.25
                                 END) vol_rate
                            FROM ins.ag_perf_work_vol     wv
                                ,ins.ag_perfom_work_det   de
                                ,ins.ag_perfomed_work_act at
                           WHERE wv.ag_perfom_work_det_id = evolved.ag_perfom_work_det_id
                             AND wv.ag_perfom_work_det_id = de.ag_perfom_work_det_id
                             AND de.ag_perfomed_work_act_id = at.ag_perfomed_work_act_id
                             AND at.ag_roll_id = g_roll_id)
      LOOP
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ext_perform_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id
          ,evolved.ag_perfom_work_det_id
          ,evolved_vol.ag_volume_id
          ,evolved_vol.vol_amount
          ,evolved_vol.vol_rate);
      END LOOP;
    
      /*INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ext_perform_work_det_id)
      VALUES
        (p_ag_perf_work_det_id, evolved.ag_perfom_work_det_id);*/
    
      v_wg_sum := v_wg_sum + nvl(evolved.summ, 0);
    
    END LOOP;
  
    v_paid_prem := pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    IF v_sale_ch = g_sc_dsf
    THEN
      g_commision := v_wg_sum * 0.5 - v_paid_prem;
    ELSE
      g_commision := v_wg_sum * 0.25 - v_paid_prem;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      g_commision := 0;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END evol_sub_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 26.08.2010 12:40:49
  -- Purpose : Расчет премии за рекрутированных руководителей
  PROCEDURE enroled_leader_calc_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Enroled_leader_calc_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_wg_sum      NUMBER := 0;
    v_rate_type   PLS_INTEGER;
    v_paid_prem   NUMBER;
    v_sale_ch     PLS_INTEGER;
  BEGIN
  
    SELECT ac.category_id
          ,apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
      INTO v_category_id
          ,v_ag_ch_id
          ,v_rate_type
          ,v_sale_ch
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
  
    FOR enrol IN (SELECT apd.summ
                        ,apd.ag_perfom_work_det_id
                    FROM ag_roll              ar
                        ,ag_perfomed_work_act apw
                        ,ag_perfom_work_det   apd
                   WHERE ar.ag_roll_header_id = g_roll_header_id
                     AND ar.ag_roll_id = apw.ag_roll_id
                     AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                     AND apd.summ != 0
                     AND apd.ag_rate_type_id IN
                         (SELECT arte.ag_rate_type_id
                            FROM ag_av_type_conform avt
                                ,ag_rate_type_ext   arte
                           WHERE avt.ag_av_type_conform_id = arte.ag_av_type_conform_id
                             AND avt.ag_roll_type_id = g_roll_type
                             AND avt.ag_rate_type_id = v_rate_type
                             AND avt.ag_category_agent_id = v_category_id
                             AND avt.t_sales_channel_id = v_sale_ch)
                     AND apw.ag_contract_header_id IN
                         (SELECT ag_contract_header_id
                            FROM (SELECT ach.ag_contract_header_id
                                        ,ins.pkg_ag_calc_admin.get_operation_months(nvl(pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                                                                                      ,g_date_end
                                                                                                                      ,ac.category_id
                                                                                                                      ,1)
                                                                                       ,g_date_end)
                                                                                   ,least(nvl(pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                                                                                            ,g_date_end
                                                                                                                            ,ac.category_id
                                                                                                                            ,2)
                                                                                             ,g_date_end)
                                                                                         ,g_date_end)) after_cat
                                        ,
                                         
                                         ins.pkg_ag_calc_admin.get_operation_months(ach.date_begin
                                                                                   ,nvl(pkg_ag_calc_admin.get_cat_date(ach.ag_contract_header_id
                                                                                                                      ,g_date_end
                                                                                                                      ,ac.category_id
                                                                                                                      ,1)
                                                                                       ,g_date_end)) before_cat
                                    FROM ven_ag_contract_header ach
                                        , --Выращенный новый АД
                                         ag_contract            ac --Выращенный новый АД
                                   WHERE 1 = 1
                                     AND nvl(ach.is_new, 1) = 1
                                     AND ac.ag_contract_id = ach.last_ver_id
                                     AND ac.contract_recrut_id IN
                                         (SELECT acl.ag_contract_id
                                            FROM ag_contract acl
                                           WHERE acl.contract_id = v_ag_ch_id
                                             AND acl.category_id = v_category_id)
                                     AND ac.category_id = v_category_id
                                     AND ach.date_begin >= '26.06.2010')
                           WHERE after_cat <
                                 decode(v_sale_ch, g_sc_dsf, 12, g_sc_sas, 6, g_sc_sas_2, 6, 12)
                             AND before_cat = 0)
                        /*Рассчитывается АВ за развитие и рекрутинг менеджерам и директорам 
                        которые уже уволены. Необходимо сделать условие, чтобы данное АВ не 
                        рассчитывалось. (пример Куриленко М.Ф., уволена в феврале, а АВ за 
                        развитие ей начисляется)*/
                     AND NOT EXISTS (SELECT NULL
                            FROM ins.ag_documents   agd
                                ,ins.ag_doc_type    ad
                                ,ins.document       d
                                ,ins.doc_status_ref rf
                           WHERE agd.ag_contract_header_id = v_ag_ch_id
                             AND agd.ag_doc_type_id = ad.ag_doc_type_id
                             AND ad.brief = 'BREAK_AD'
                             AND agd.ag_documents_id = d.document_id
                             AND d.doc_status_ref_id = rf.doc_status_ref_id
                             AND rf.brief = 'CONFIRMED'
                             AND agd.doc_date <= g_date_end))
    LOOP
      FOR enrol_vol IN (SELECT wv.ag_volume_id
                              ,wv.vol_amount
                              ,wv.vol_rate * (CASE
                                 WHEN v_sale_ch = g_sc_dsf THEN
                                  0.5
                                 ELSE
                                  0.25
                               END) vol_rate
                          FROM ins.ag_perf_work_vol     wv
                              ,ins.ag_perfom_work_det   de
                              ,ins.ag_perfomed_work_act at
                         WHERE wv.ag_perfom_work_det_id = enrol.ag_perfom_work_det_id
                           AND wv.ag_perfom_work_det_id = de.ag_perfom_work_det_id
                           AND de.ag_perfomed_work_act_id = at.ag_perfomed_work_act_id
                           AND at.ag_roll_id = g_roll_id)
      LOOP
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ext_perform_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id
          ,enrol.ag_perfom_work_det_id
          ,enrol_vol.ag_volume_id
          ,enrol_vol.vol_amount
          ,enrol_vol.vol_rate);
      END LOOP;
    
      /*INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ext_perform_work_det_id)
      VALUES
        (p_ag_perf_work_det_id, enrol.ag_perfom_work_det_id);*/
    
      v_wg_sum := v_wg_sum + nvl(enrol.summ, 0);
    
    END LOOP;
  
    v_paid_prem := pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    IF v_sale_ch = g_sc_dsf
    THEN
      g_commision := v_wg_sum * 0.5 - v_paid_prem;
    ELSE
      g_commision := v_wg_sum * 0.25 - v_paid_prem;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      g_commision := 0;
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END enroled_leader_calc_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 29.06.2010 11:13:58
  -- Purpose : Расчет премии за работу личной группы
  PROCEDURE personal_group_5010(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Personal_group_5010';
    v_ag_ch_id    PLS_INTEGER;
    v_amount      NUMBER;
    v_rate_type   PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_rate        NUMBER := 0.1; --10% от продаж личной группы;
    /**/
    vp_ret_pay    NUMBER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_category_id
          ,v_rate_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT av.ag_volume_id
                      ,av.ag_volume_type_id
                      ,av.ag_contract_header_id
                      ,av.policy_header_id
                      ,av.date_begin
                      ,av.ins_period
                      ,av.payment_term_id
                      ,av.last_status
                      ,av.active_status
                      ,av.fund
                      ,av.epg_payment
                      ,av.epg_date
                      ,av.pay_period
                      ,av.epg_status
                      ,av.epg_ammount
                      ,av.epg_pd_type
                      ,av.pd_copy_status
                      ,av.pd_payment
                      ,av.pd_collection_method
                      ,av.payment_date
                      ,av.t_prod_line_option_id
                      ,av.trans_id
                      ,av.nbv_coef
                      ,av.ag_roll_id
                      ,av.is_nbv
                      ,av.conclude_date
                      ,av.payment_date_orig
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.trans_sum * 50 / 100
                         ELSE
                          av.trans_sum
                       END trans_sum
                      ,CASE
                         WHEN av.ag_volume_type_id = g_vt_fdep THEN
                          av.index_delta_sum * 50 / 100
                         ELSE
                          av.index_delta_sum
                       END index_delta_sum
                  FROM temp_vol_calc tv
                      ,ag_volume     av
                      ,ag_prev_dog   apd
                      ,ag_contract   ac
                 WHERE tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id = v_ag_ch_id
                      /*---чтоб дирам не входили банки---*/
                   AND (CASE
                         WHEN av.ag_contract_header_id IN (26101892, 25873698, 30707667)
                              AND tv.ag_contract_header_id IN (21815846, 24674672, 21875188) THEN
                          0
                         ELSE
                          1
                       END) = 1
                      /*-----*/
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_contract          ac
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ac.contract_id
                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                           AND (decode(ac.category_id, 20, 4, ac.category_id) =
                               decode(v_category_id, 20, 4, v_category_id) OR
                               ac.contract_id = v_ag_ch_id)
                           AND apw.ag_roll_id != g_roll_id --Ставка не меняеется поэтому не пересчитываем
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND apw.ag_roll_id = ar.ag_roll_id)
                   AND av.is_nbv = 1
                   AND ((av.ag_volume_type_id IN (g_vt_life, g_vt_ops, g_vt_avc_pay, g_vt_fdep) AND
                       g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                       (av.ag_volume_type_id IN (g_vt_life, g_vt_avc_pay, g_vt_fdep) AND
                       g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                   AND tv.lvl = 2
                   AND av.ag_contract_header_id = apd.ag_prev_header_id(+)
                   AND ac.contract_id = nvl(apd.ag_contract_header_id, av.ag_contract_header_id)
                   AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                   AND ac.category_id = g_ct_agent)
    LOOP
    
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
             AND art.brief = 'PG_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 0
             AND apw.ag_contract_header_id = v_ag_ch_id
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
             AND art.brief = 'PG_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 99
             AND apw.ag_contract_header_id = v_ag_ch_id
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
        v_rate := 0.1;
        --10% от продаж личной группы
        IF nvl(vol.index_delta_sum, 0) <> 0
        THEN
          v_amount := nvl(vol.index_delta_sum, 0) * vol.nbv_coef;
        ELSE
          v_amount := nvl(vol.trans_sum, 0) * vol.nbv_coef;
        END IF;
      
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id, vol.ag_volume_id, v_amount, v_rate);
      
        g_commision := g_commision + v_amount * v_rate;
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END personal_group_5010;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 29.06.2010 11:16:29
  -- Purpose : Расчет премии за качественные ОПС
  PROCEDURE qualitative_ops_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Qualitative_OPS_0510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_rate        NUMBER;
    v_payed_rate  NUMBER;
    v_sales_ch    PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    /**/
    vp_ret_pay    NUMBER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
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
  
    FOR vol IN (SELECT av.*
                  FROM temp_vol_calc tv
                      ,ag_volume     av
                 WHERE tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id = v_ag_ch_id
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_contract          ac
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ac.contract_id
                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                           AND (decode(ac.category_id, 20, 4, ac.category_id) =
                               decode(v_category_id, 20, 4, v_category_id) OR
                               ac.contract_id = v_ag_ch_id)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND arh.ag_roll_header_id != g_roll_header_id)
                   AND av.is_nbv = 1
                   AND av.ag_volume_type_id IN (g_vt_ops))
    LOOP
    
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
             AND art.brief = 'QOPS_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 0
             AND apw.ag_contract_header_id = v_ag_ch_id
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
             AND art.brief = 'QOPS_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 99
             AND apw.ag_contract_header_id = v_ag_ch_id
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
        v_payed_rate := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                        ,v_rate_type
                                                        ,v_ag_ch_id
                                                        ,vol.ag_volume_id);
      
        v_rate := pkg_tariff_calc.calc_coeff_val('MND_RATE_OPS'
                                                ,t_number_type(v_category_id, v_level, 1, v_sales_ch));
        v_rate := nvl(v_rate, 0) / 100 - nvl(v_payed_rate, 0);
      
        IF v_payed_rate IS NULL
           OR v_rate != 0
        THEN
          INSERT INTO ven_ag_perf_work_vol
            (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
          VALUES
            (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_rate);
        
          g_commision := g_commision + vol.trans_sum * v_rate * vol.nbv_coef;
        END IF;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END qualitative_ops_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 29.06.2010 11:19:54
  -- Purpose : Расчет премии за продажи качественных ОПС застрахованным мужского пола
  PROCEDURE q_male_ops_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Q_Male_OPS_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_rate        NUMBER;
    v_payed_rate  NUMBER;
    v_rate_type   PLS_INTEGER;
    /**/
    vp_ret_pay    NUMBER;
    vp_ret_snils  VARCHAR2(255);
    vp_ret_amount NUMBER;
    vp_ret_rate   NUMBER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,apd.ag_rate_type_id
      INTO v_ag_ch_id
          ,v_category_id
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
  
    FOR vol IN (SELECT a.*
                  FROM (SELECT av.ag_volume_id
                              ,av.trans_sum
                              ,av.nbv_coef
                              ,apn.gender
                              ,SUM(apn.gender) over(PARTITION BY 1) / COUNT(*) over(PARTITION BY 1) male_percent
                          FROM temp_vol_calc     tv
                              ,ag_volume         av
                              ,ag_npf_volume_det apn
                         WHERE tv.ag_volume_id = av.ag_volume_id
                           AND tv.ag_contract_header_id = v_ag_ch_id
                           AND av.is_nbv = 1
                           AND NOT EXISTS
                         (SELECT NULL
                                  FROM ag_perf_work_vol     apv
                                      ,ag_perfom_work_det   apd
                                      ,ag_perfomed_work_act apw
                                      ,ag_contract          ac
                                      ,ag_roll              ar
                                      ,ag_roll_header       arh
                                 WHERE apv.ag_volume_id = av.ag_volume_id
                                   AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                                   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                                   AND apw.ag_contract_header_id = ac.contract_id
                                   AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND
                                       ac.date_end
                                   AND (decode(ac.category_id, 20, 4, ac.category_id) =
                                       decode(v_category_id, 20, 4, v_category_id) OR
                                       ac.contract_id = v_ag_ch_id)
                                   AND apw.ag_roll_id = ar.ag_roll_id
                                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                                   AND arh.ag_roll_header_id != g_roll_header_id)
                           AND av.ag_volume_type_id IN (g_vt_ops)
                           AND apn.ag_volume_id = av.ag_volume_id) a
                 WHERE a.gender = 1)
    LOOP
    
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
             AND art.brief = 'QMOPS_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 0
             AND apw.ag_contract_header_id = v_ag_ch_id
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
             AND art.brief = 'QMOPS_0510'
             AND anv.snils = vp_ret_snils
             AND nvl(anv.from_ret_to_pay, 0) = 99
             AND apw.ag_contract_header_id = v_ag_ch_id
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
        IF v_category_id = 3
        THEN
          v_rate := 0.05;
        ELSE
          v_rate := 0.03;
        END IF;
      
        IF vol.male_percent <= 0.6
        THEN
          v_rate := 0;
        END IF;
      
        v_payed_rate := pkg_ag_calc_admin.get_payed_rate(g_roll_header_id
                                                        ,v_rate_type
                                                        ,v_ag_ch_id
                                                        ,vol.ag_volume_id);
        v_rate       := v_rate - nvl(v_payed_rate, 0);
      
        IF v_payed_rate IS NULL
           OR v_rate != 0
        THEN
          INSERT INTO ven_ag_perf_work_vol
            (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
          VALUES
            (p_ag_perf_work_det_id, vol.ag_volume_id, vol.trans_sum * vol.nbv_coef, v_rate);
        
          g_commision := g_commision + vol.trans_sum * v_rate * vol.nbv_coef;
        END IF;
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_male_ops_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 12.10.2010 15:44:16
  -- Purpose : Расчет премии за активных агентов мотивация 0510
  PROCEDURE active_agent_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'Active_agent_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_um_cnt      PLS_INTEGER;
    v_aa_cnt      PLS_INTEGER;
    v_plan        PLS_INTEGER;
    v_rate_type   PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_level       PLS_INTEGER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,apd.ag_rate_type_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_level
      INTO v_ag_ch_id
          ,v_category_id
          ,v_rate_type
          ,v_sales_ch
          ,v_level
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
  
    IF v_level = 1
    THEN
    
      SELECT SUM(CASE
                   WHEN (SELECT ac.category_id
                           FROM ag_contract ac
                          WHERE ac.contract_id = aat.ag_contract_header_id
                            AND g_date_end BETWEEN ac.date_begin AND ac.date_end) = 3 THEN
                    1
                   ELSE
                    0
                 END) manager_unit
            ,
             
             SUM(CASE
                   WHEN (SELECT ac.category_id
                           FROM ag_contract ac
                          WHERE ac.contract_id = aat.ag_contract_header_id
                            AND g_date_end BETWEEN ac.date_begin AND ac.date_end) = 2 THEN
                   
                    (SELECT CASE
                              WHEN SUM(decode(av.ag_volume_type_id, 1, 1, 0)) >= 1
                                   OR SUM(decode(av.ag_volume_type_id, 2, 1, 0)) >= 1 THEN
                               1
                              ELSE
                               0
                            END a_o_rl
                       FROM ag_volume      av
                           ,ag_roll        ar
                           ,ag_roll_header arh
                      WHERE av.ag_roll_id = ar.ag_roll_id
                        AND ar.ag_roll_header_id = arh.ag_roll_header_id
                        AND ((av.ag_volume_type_id IN (1, 2) AND
                            g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                            (av.ag_volume_type_id IN (1) AND
                            g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                        AND av.is_nbv = 1
                           /*-----------Совет Анастасии Черновой-----------------*/
                        AND nvl(av.pay_period, 1) = 1
                        AND substr((SELECT num FROM document d WHERE d.document_id = av.epg_payment)
                                  ,instr((SELECT num FROM document d WHERE d.document_id = av.epg_payment)
                                        ,'/') + 1) = 1
                           /*---------------------------------------*/
                        AND nvl(av.index_delta_sum, 0) = 0
                        AND nvl(ar.date_end, arh.date_end) =
                            pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -1)
                        AND av.ag_contract_header_id = aat.ag_contract_header_id)
                   ELSE
                    0
                 END) active_agent
        INTO v_um_cnt
            ,v_aa_cnt
        FROM ag_agent_tree aat
       WHERE EXISTS (SELECT NULL
                FROM ins.ag_contract_header ach
               WHERE ach.ag_contract_header_id = aat.ag_contract_header_id
                 AND ach.is_new = 1)
       START WITH aat.ag_contract_header_id = v_ag_ch_id
              AND pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -1) BETWEEN
                  aat.date_begin AND aat.date_end
      CONNECT BY aat.ag_parent_header_id = PRIOR aat.ag_contract_header_id
             AND pkg_ag_calc_admin.get_opertation_month_date(g_date_end, 2, -1) BETWEEN aat.date_begin AND
                 aat.date_end;
    
      v_plan := CEIL(v_um_cnt * 1.5 + v_aa_cnt * 0.8);
    
    ELSE
    
      v_plan := pkg_ag_calc_admin.get_plan_0510(v_ag_ch_id, 3, g_date_end);
    
    END IF;
  
    SELECT SUM(CASE
                 WHEN (SELECT ac.category_id
                         FROM ag_contract ac
                        WHERE ac.contract_id = aat.ag_contract_header_id
                          AND g_date_end BETWEEN ac.date_begin AND ac.date_end) = 2 THEN
                  (SELECT CASE
                            WHEN SUM(decode(av.ag_volume_type_id, 1, 1, 0)) >= 1
                                 OR SUM(decode(av.ag_volume_type_id, 2, 1, 0)) >= 1 THEN
                             1
                            ELSE
                             0
                          END a_o_rl
                     FROM ag_volume      av
                         ,ag_roll        ar
                         ,ag_roll_header arh
                    WHERE av.ag_roll_id = ar.ag_roll_id
                      AND ar.ag_roll_header_id = arh.ag_roll_header_id
                      AND ((av.ag_volume_type_id IN (1, 2) AND
                          g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                          (av.ag_volume_type_id IN (1) AND
                          g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                      AND av.is_nbv = 1
                      AND nvl(av.index_delta_sum, 0) = 0
                      AND nvl(ar.date_end, arh.date_end) = g_date_end
                      AND av.ag_contract_header_id = aat.ag_contract_header_id)
                 ELSE
                  0
               END) active_agent
      INTO v_aa_cnt
      FROM ag_agent_tree aat
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_contract_header ach
             WHERE ach.ag_contract_header_id = aat.ag_contract_header_id
               AND ach.is_new = 1)
     START WITH aat.ag_contract_header_id = v_ag_ch_id
            AND g_date_end BETWEEN aat.date_begin AND aat.date_end
    CONNECT BY aat.ag_parent_header_id = PRIOR aat.ag_contract_header_id
           AND g_date_end BETWEEN aat.date_begin AND aat.date_end;
  
    IF v_plan != 0
       AND v_plan <= v_aa_cnt
    THEN
      g_commision := nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_level
                                                                     ,v_category_id))
                        ,0);
    END IF;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END active_agent_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 20.10.2010 17:43:15
  -- Purpose : Расчет премии за достижение KPI по КСП
  PROCEDURE ksp_kpi_reach_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'KSP_KPI_Reach_0510';
    v_plan        NUMBER;
    v_ksp         NUMBER;
    v_level       PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_level
          ,apw.ag_ksp
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_level
          ,v_ksp
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
  
    v_plan := pkg_ag_calc_admin.get_plan_0510(v_ag_ch_id, 2, g_date_end);
  
    IF v_plan != 0
       AND v_plan <= v_ksp
    THEN
    
      IF v_level = 1
      THEN
        g_commision := 0;
      ELSE
        g_commision := nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                         ,t_number_type(v_sales_ch
                                                                       ,v_level
                                                                       ,v_category_id))
                          ,0);
      END IF;
    
    END IF;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END ksp_kpi_reach_0510;

  -- Author  : Веселуха Е.В.
  -- Created : 14.03.2012 17:43:15
  -- Purpose : Премия за достижения KPI (предоставление оригиналов ОПС)
  PROCEDURE kpi_orig_ops(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'KPI_ORIG_OPS';
    v_plan        NUMBER;
    v_ksp         NUMBER;
    v_level       PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
  BEGIN
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_level
          ,apw.ag_ksp
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
          ,v_level
          ,v_ksp
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
  
    v_plan := pkg_ag_calc_admin.get_plan_0510(v_ag_ch_id, 4, g_date_end);
  
    IF v_plan != 0
    THEN
      g_commision := nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                       ,t_number_type(v_sales_ch
                                                                     ,v_level
                                                                     ,v_category_id))
                        ,0);
    END IF;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END kpi_orig_ops;

  -- Author  : Веселуха Е.В.
  -- Created : 02.04.2012 17:43:15
  -- Purpose : Премия за достижения KPI 3 (план по ОПС)
  PROCEDURE kpi_plan_ops(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'KPI_PLAN_OPS';
    v_plan        NUMBER;
    v_level       PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_ops_nbv     NUMBER;
    v_rate        NUMBER;
  BEGIN
  
    SELECT apw.ag_level
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_contract_header_id
          ,apw.volumes.get_volume(g_vt_ops)
      INTO v_level
          ,v_category_id
          ,v_sales_ch
          ,v_ag_ch_id
          ,v_ops_nbv
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
       AND ach.ag_contract_header_id = ac.contract_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    v_plan := pkg_ag_calc_admin.get_plan_0510(v_ag_ch_id, 5, g_date_end);
  
    IF v_category_id = g_cat_td_id
    THEN
    
      IF v_level > 1
      THEN
        IF v_plan != 0
           AND v_plan <= (v_ops_nbv / 500)
        THEN
          g_commision := nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                           ,t_number_type(v_sales_ch
                                                                         ,v_level
                                                                         ,v_category_id))
                            ,0);
        END IF;
      ELSE
        g_commision := 0;
      END IF;
    
    ELSE
    
      IF v_plan != 0
         AND v_plan <= (v_ops_nbv / 500)
      THEN
        CASE
          WHEN (v_ops_nbv / 500) <= 99 THEN
            g_commision := 5000;
          WHEN (v_ops_nbv / 500) <= 199 THEN
            g_commision := 10000;
          WHEN (v_ops_nbv / 500) <= 399 THEN
            g_commision := 20000;
          ELSE
            g_commision := 30000;
        END CASE;
      ELSE
        g_commision := 0;
      END IF;
    
    END IF;
  
    /*FOR cur_vol IN (SELECT wv.ag_volume_id
                          ,wv.vol_amount
                          ,wv.vol_amount * (v_ops_nbv / 500) vol_rate
                          ,t.name
                      FROM ins.ag_perfom_work_det det
                          ,ins.ag_perfom_work_det dt
                          ,ins.ag_perf_work_vol   wv
                          ,ins.ag_rate_type       t
                          ,ins.ag_volume          agv
                          ,ins.ag_volume_type     avt
                     WHERE det.ag_perfom_work_det_id = p_ag_perf_work_det_id
                       AND det.ag_perfomed_work_act_id = dt.ag_perfomed_work_act_id
                       AND dt.ag_perfom_work_det_id = wv.ag_perfom_work_det_id
                       AND wv.vol_amount != 0
                       AND dt.ag_rate_type_id = t.ag_rate_type_id
                       AND t.brief IN ('QOPS_0510', 'WG_0510')
                       AND agv.ag_volume_id = wv.ag_volume_id
                       AND agv.ag_volume_type_id = avt.ag_volume_type_id
                       AND avt.brief = 'NPF')
    LOOP
      IF cur_vol.vol_rate = 0
      THEN
        v_rate := 0;
      ELSE
        v_rate := g_commision / cur_vol.vol_rate;
      END IF;
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, cur_vol.ag_volume_id, cur_vol.vol_amount, v_rate);
    
    END LOOP;*/
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END kpi_plan_ops;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.11.2010 14:36:04
  -- Purpose : Расчет премии за выполнение плана
  PROCEDURE grs_exec_plan_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'GRS_exec_plan_0510';
    v_level     PLS_INTEGER;
    v_paid_prem NUMBER;
  BEGIN
    SELECT apw.ag_level
      INTO v_level
      FROM ag_perfom_work_det   apd
          ,ag_perfomed_work_act apw
     WHERE apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id;
  
    v_paid_prem := pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    CASE v_level
      WHEN 0 THEN
        g_commision := 0 - v_paid_prem;
      WHEN 1 THEN
        g_commision := 5000 - v_paid_prem;
      WHEN 2 THEN
        g_commision := 10000 - v_paid_prem;
      WHEN 3 THEN
        g_commision := 15000 - v_paid_prem;
      WHEN 4 THEN
        g_commision := 25000 - v_paid_prem;
        /*WHEN 0 THEN g_commision:= 0-v_paid_prem;
        WHEN 1 THEN g_commision:= 2500-v_paid_prem;
        WHEN 2 THEN g_commision:= 5000-v_paid_prem;
        WHEN 3 THEN g_commision:= 10000-v_paid_prem;
        WHEN 4 THEN g_commision:= 15000-v_paid_prem;
        WHEN 5 THEN g_commision:= 25000-v_paid_prem;*/
      ELSE
        NULL;
    END CASE;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END grs_exec_plan_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.11.2010 15:52:14
  -- Purpose : Расчет комиссионной премии менеджера ГРС
  PROCEDURE grs_policy_comis_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'GRS_policy_comis_0510';
    v_level       PLS_INTEGER;
    v_ag_ch_id    PLS_INTEGER;
    v_rate        NUMBER;
    v_payed_rate  NUMBER;
    v_rate_type   PLS_INTEGER;
    v_category_id PLS_INTEGER;
  BEGIN
  
    SELECT apw.ag_level
          ,apw.ag_contract_header_id
          ,apd.ag_rate_type_id
          ,ac.category_id
      INTO v_level
          ,v_ag_ch_id
          ,v_rate_type
          ,v_category_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND g_date_end BETWEEN ac.date_begin AND ac.date_end;
  
    FOR vol IN (SELECT av.*
                  FROM temp_vol_calc tv
                      ,ag_volume     av
                 WHERE tv.ag_volume_id = av.ag_volume_id
                   AND tv.ag_contract_header_id = v_ag_ch_id
                   AND NOT EXISTS
                 (SELECT NULL
                          FROM ag_perf_work_vol     apv
                              ,ag_perfom_work_det   apd
                              ,ag_perfomed_work_act apw
                              ,ag_contract          ac
                              ,ag_roll              ar
                              ,ag_roll_header       arh
                         WHERE apv.ag_volume_id = av.ag_volume_id
                           AND apv.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
                           AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                           AND apw.ag_contract_header_id = ac.contract_id
                           AND nvl(ar.date_end, arh.date_end) BETWEEN ac.date_begin AND ac.date_end
                           AND (decode(ac.category_id, 20, 4, ac.category_id) =
                               decode(v_category_id, 20, 4, v_category_id) OR
                               ac.contract_id = v_ag_ch_id)
                           AND apw.ag_roll_id = ar.ag_roll_id
                           AND ar.ag_roll_header_id = arh.ag_roll_header_id
                           AND arh.ag_roll_header_id != g_roll_header_id)
                   AND av.is_nbv = 1
                   AND av.ag_volume_type_id IN (g_vt_ops)
                /*******заявка №145152**********/
                /* AND NOT EXISTS (SELECT NULL
                FROM  ins.ag_perfomed_work_act apw,
                      ins.ag_perfom_work_det apd,
                      ins.ag_rate_type art,
                      ins.ag_perf_work_vol apv,
                      ins.ag_npf_volume_det anv
                WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
                      AND apd.ag_rate_type_id = art.ag_rate_type_id
                      AND art.brief IN ('WG_0510','SS_0510','QMOPS_0510','QOPS_0510','PG_0510','Policy_commiss_GRS','OAV_GRS','FAKE_Sofi_prem_0510') --,'LVL_0510')
                      AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
                      AND apv.ag_volume_id = av.ag_volume_id
                      AND av.ag_volume_id = anv.ag_volume_id)*/
                )
    LOOP
    
      CASE v_level
        WHEN 0 THEN
          v_rate := 30;
        WHEN 1 THEN
          v_rate := 60;
        WHEN 2 THEN
          v_rate := 75;
        WHEN 3 THEN
          v_rate := 80;
        WHEN 4 THEN
          v_rate := 90;
        ELSE
          NULL;
      END CASE;
    
      /*v_payed_rate:=pkg_ag_calc_admin.Get_payed_rate(g_roll_header_id,
      v_rate_type,
      v_ag_ch_id,
      vol.ag_volume_id);*/
      v_payed_rate := pkg_ag_calc_admin.get_payed_rate_amount(g_roll_header_id
                                                             ,v_rate_type
                                                             ,v_ag_ch_id
                                                             ,vol.ag_volume_id);
      v_rate       := v_rate - nvl(v_payed_rate, 0);
    
      /***************************************/
      /*
      create table tmp#_commis_grs
        (p_ag_level NUMBER,
         p_ag_contract_header_id NUMBER,
         p_ag_rate_type_id NUMBER,
         p_category_id NUMBER,
         p_rate NUMBER,
         p_payed_rate NUMBER,
         p_ag_volume_id NUMBER
        );
       */
      /*INSERT INTO tmp#_commis_grs
      (p_ag_level,p_ag_contract_header_id,p_ag_rate_type_id,p_category_id,p_rate,p_payed_rate,p_ag_volume_id)
      VALUES (v_level,
              v_ag_ch_id,
              v_rate_type,
              v_category_id,
              v_rate,
              v_payed_rate,
              vol.ag_volume_id);*/
      /*************************************/
      IF v_payed_rate IS NULL
         OR v_rate != 0
      THEN
        INSERT INTO ven_ag_perf_work_vol
          (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
        VALUES
          (p_ag_perf_work_det_id, vol.ag_volume_id, v_rate, 1);
      
        g_commision := g_commision + v_rate;
      END IF;
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END grs_policy_comis_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.11.2010 13:34:15
  -- Purpose : Расчет премии за личные продажи для менеджеров ГРС
  PROCEDURE get_grs_agents_prem(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name  VARCHAR2(25) := 'Get_GRS_agents_prem';
    v_ag_ch_id PLS_INTEGER;
    v_rate     PLS_INTEGER;
    v_sales_ch PLS_INTEGER;
    pv_cnt_vol PLS_INTEGER := 0;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
      INTO v_ag_ch_id
          ,v_sales_ch
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
    /*************План по пред версиям******************************************/
    BEGIN
      SELECT COUNT(*)
        INTO pv_cnt_vol
        FROM ag_volume       av
            ,ins.ven_ag_roll ar
            ,ag_roll_header  arh
       WHERE av.ag_volume_type_id IN (g_vt_ops, g_vt_ops_2)
         AND av.trans_sum = 500
         AND ar.ag_roll_id = av.ag_roll_id
         AND ar.ag_roll_header_id = arh.ag_roll_header_id
         AND nvl(ar.date_end, arh.date_end) <= g_date_end
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
                      ,av.trans_sum
                      ,COUNT(av.ag_volume_id) over(PARTITION BY av.is_nbv /*av.nbv_coef*/) cnt
                      ,(SELECT anv.sign_date
                          FROM ins.ag_npf_volume_det anv
                         WHERE anv.ag_volume_id = av.ag_volume_id) sign_date
                  FROM ag_volume      av
                      ,ag_roll        ar
                      ,ag_roll_header arh
                 WHERE av.ag_volume_type_id IN (g_vt_ops)
                   AND av.trans_sum IN (500, 250)
                   AND ar.ag_roll_id = av.ag_roll_id
                   AND ar.ag_roll_header_id = arh.ag_roll_header_id
                   AND nvl(ar.date_end, arh.date_end) <= g_date_end
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
    
      CASE v_sales_ch
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
            IF vol.sign_date BETWEEN to_date('26.09.2011', 'DD.MM.YYYY') AND
               to_date('25.12.2011', 'DD.MM.YYYY')
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
              CASE
                WHEN vol.cnt <= 4 THEN
                  v_rate := 350;
                WHEN vol.cnt <= 9 THEN
                  v_rate := 400;
                ELSE
                  v_rate := 500;
              END CASE;
            END IF;
          ELSE
            v_rate := 250;
          END IF;
        ELSE
          NULL;
      END CASE;
    
      g_commision := g_commision + v_rate;
    
      INSERT INTO ven_ag_perf_work_vol
        (ag_perfom_work_det_id, ag_volume_id, vol_amount, vol_rate)
      VALUES
        (p_ag_perf_work_det_id, vol.ag_volume_id, v_rate, 1);
    END LOOP;
  
    UPDATE ag_perfom_work_det a
       SET a.summ = g_commision
     WHERE a.ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_grs_agents_prem;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.11.2010 18:00:12
  -- Purpose : Рачсет премии за выполнение плана для региональных управляющих
  PROCEDURE rm_plan_exec_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'RM_plan_exec_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
    v_all_nbv     NUMBER;
    v_volumes     t_volume_val_o := t_volume_val_o(NULL);
    v_category_id PLS_INTEGER;
    v_paid_prem   NUMBER;
  BEGIN
    SELECT ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
          ,apw.ag_contract_header_id
      INTO v_category_id
          ,v_sales_ch
          ,v_ag_ch_id
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
  
    FOR agency_plan IN (SELECT asp.plan_value
                              ,asp.agency_id
                          FROM ag_sale_plan asp
                         WHERE asp.ag_contract_header_id = v_ag_ch_id
                           AND asp.plan_type = 1
                           AND g_date_end BETWEEN asp.date_begin AND asp.date_end)
    LOOP
    
      v_volumes := get_volume_val_act(v_ag_ch_id
                                     ,1
                                     ,agency_plan.agency_id
                                     ,pkg_ag_calc_admin.get_cat_date(v_ag_ch_id
                                                                    ,SYSDATE
                                                                    ,v_category_id));
    
      v_all_nbv := v_volumes.get_volume(g_vt_life) + v_volumes.get_volume(g_vt_ops) +
                   v_volumes.get_volume(g_vt_avc_pay);
    
      IF nvl(agency_plan.plan_value, 0) != 0
         AND agency_plan.plan_value < v_all_nbv
      THEN
      
        g_commision := g_commision +
                       nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                         ,t_number_type(v_sales_ch, 1, v_category_id))
                          ,0);
      END IF;
    
    END LOOP;
  
    v_paid_prem := pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
    g_commision := g_commision - v_paid_prem;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END rm_plan_exec_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.11.2010 18:02:19
  -- Purpose : Расчет премии за активных агентов для рекгиональных управлюящих
  PROCEDURE rm_active_agent_0510(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name     VARCHAR2(25) := 'RM_Active_agent_0510';
    v_ag_ch_id    PLS_INTEGER;
    v_category_id PLS_INTEGER;
    v_aa_cnt      PLS_INTEGER;
    v_sales_ch    PLS_INTEGER;
  BEGIN
  
    SELECT apw.ag_contract_header_id
          ,ac.category_id
          ,nvl(chac.id, ach.t_sales_channel_id) t_sales_channel_id
      INTO v_ag_ch_id
          ,v_category_id
          ,v_sales_ch
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
  
    FOR agency_plan IN (SELECT asp.plan_value
                              ,asp.agency_id
                          FROM ag_sale_plan asp
                         WHERE asp.ag_contract_header_id = v_ag_ch_id
                           AND asp.plan_type = 3
                           AND g_date_end BETWEEN asp.date_begin AND asp.date_end)
    LOOP
    
      SELECT SUM(CASE
                   WHEN (SELECT ac.category_id
                           FROM ag_contract ac
                          WHERE ac.contract_id = aat.ag_contract_header_id
                            AND g_date_end BETWEEN ac.date_begin AND ac.date_end) = 2 THEN
                    (SELECT CASE
                              WHEN SUM(decode(av.ag_volume_type_id, 1, 1, 0)) >= 1
                                   OR SUM(decode(av.ag_volume_type_id, 2, 1, 0)) >= 1 THEN
                               1
                              ELSE
                               0
                            END a_o_rl
                       FROM ag_volume      av
                           ,ag_roll        ar
                           ,ag_roll_header arh
                      WHERE av.ag_roll_id = ar.ag_roll_id
                        AND ar.ag_roll_header_id = arh.ag_roll_header_id
                        AND ((av.ag_volume_type_id IN (1, 2) AND
                            g_date_begin < to_date('26.12.2013', 'dd.mm.yyyy')) OR
                            (av.ag_volume_type_id IN (1) AND
                            g_date_begin >= to_date('26.12.2013', 'dd.mm.yyyy')))
                        AND av.is_nbv = 1
                        AND nvl(av.index_delta_sum, 0) = 0
                        AND nvl(ar.date_end, arh.date_end) = g_date_end
                        AND av.ag_contract_header_id = aat.ag_contract_header_id)
                   ELSE
                    0
                 END) active_agent
        INTO v_aa_cnt
        FROM ag_agent_tree aat
       WHERE aat.ag_contract_header_id IN
             (SELECT ach.ag_contract_header_id
                FROM ag_contract_header ach
                    ,ag_contract        ac
               WHERE ach.ag_contract_header_id = ac.contract_id
                 AND ach.is_new = 1
                 AND g_date_end BETWEEN ac.date_begin AND ac.date_end
                 AND ac.agency_id = agency_plan.agency_id)
       START WITH aat.ag_contract_header_id = v_ag_ch_id
              AND g_date_end BETWEEN aat.date_begin AND aat.date_end
      CONNECT BY aat.ag_parent_header_id = PRIOR aat.ag_contract_header_id
             AND g_date_end BETWEEN aat.date_begin AND aat.date_end;
    
      IF agency_plan.plan_value != 0
         AND agency_plan.plan_value <= v_aa_cnt
      THEN
        g_commision := nvl(pkg_tariff_calc.calc_coeff_val('KPI_REACH_AWARD'
                                                         ,t_number_type(v_sales_ch, 1, v_category_id))
                          ,0);
      END IF;
    
    END LOOP;
  
    g_commision := g_commision - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END rm_active_agent_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.06.2009 16:34:02
  -- Purpose : Расчет премии за работу группы
  PROCEDURE work_group_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'Work_group_calc';
    v_cash    t_cash;
  BEGIN
    v_cash := get_cash(p_ag_perf_work_det_id);
  
    UPDATE ag_perfom_work_det
       SET summ = v_cash.commiss_amount
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_cash.commiss_amount;
    g_sgp2      := g_sgp2 + v_cash.cash_amount;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END work_group_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.06.2009 16:56:24
  -- Purpose : Расчет премии за выполнение плана
  PROCEDURE exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name      VARCHAR2(20) := 'Exec_plan_calc';
    v_month_num    NUMBER;
    v_sgp          NUMBER;
    v_plan         t_agent_plan := t_agent_plan(NULL, NULL);
    v_ag_status_id PLS_INTEGER;
    v_ag_ch_id     PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_date_beg     DATE;
    v_month_koef   NUMBER;
    v_commission   NUMBER;
    v_prem_type    PLS_INTEGER;
    v_payed_sum    NUMBER;
  BEGIN
    SELECT apw.status_id
          ,apw.ag_contract_header_id
          ,ac.category_id
          ,apd.ag_rate_type_id
      INTO v_ag_status_id
          ,v_ag_ch_id
          ,v_category_id
          ,v_prem_type
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.ag_contract_id = pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end);
  
    v_sgp       := get_sgp(p_ag_perf_work_det_id);
    v_month_num := pkg_ag_calc_admin.get_cat_o_months(v_ag_ch_id, g_date_end, v_category_id);
  
    CASE
      WHEN g_roll_type_brief IN ('NMGR_0106', 'NDIR_0106')
           AND v_ag_status_id >= 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      WHEN g_roll_type_brief IN ('NMGR', 'NDIR')
           AND v_ag_status_id > 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      ELSE
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end);
    END CASE;
  
    --1) Выполнен ли план
    IF v_plan.sgp_amount > v_sgp
    THEN
      --2) План не выполен проверяем месяц работы
      IF v_month_num = 1
      THEN
        v_date_beg   := pkg_ag_calc_admin.get_date_cat(v_ag_ch_id, g_date_end, v_category_id);
        v_month_koef := (pkg_ag_calc_admin.get_opertation_month_date(v_date_beg, 2) - v_date_beg + 1) /
                        extract(DAY FROM pkg_ag_calc_admin.get_opertation_month_date(v_date_beg, 2));
        --3) Получим "пропорциональный" план и сравним его с СГП
        IF v_month_koef * v_plan.sgp_amount > v_sgp
        THEN
          v_commission := 0;
        ELSE
          v_commission := pkg_ag_calc_admin.get_premium_amount(g_rate_type_id
                                                              ,v_ag_status_id
                                                              ,g_date_end) * v_sgp / v_plan.sgp_amount;
        END IF;
      ELSE
        --Месяц работы не впервый - ничего не получает
        v_commission := 0;
      END IF;
    ELSE
      -- План выполнен начисляем премию
      v_commission := pkg_ag_calc_admin.get_premium_amount(g_rate_type_id, v_ag_status_id, g_date_end);
    END IF;
  
    IF g_roll_num <> 1
    THEN
      v_payed_sum  := pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
      v_commission := v_commission - v_payed_sum;
    END IF;
  
    UPDATE ag_perfom_work_det
       SET summ       = v_commission
          ,mounth_num = v_month_num
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_commission;
    g_sgp1      := v_sgp;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END exec_plan_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 16:04:17
  -- Purpose : Расчет премии за выполнение плана для Тер. директора
  PROCEDURE rd_exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'RD_Exec_plan_calc';
  BEGIN
  
    IF p_ag_perf_work_det_id IS NULL
    THEN
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END rd_exec_plan_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 16:05:24
  -- Purpose : Рачсчет дополнительной премии за выполнение плана
  PROCEDURE add_exec_plan_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'ADD_Exec_plan_calc';
  BEGIN
  
    IF p_ag_perf_work_det_id IS NULL
    THEN
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END add_exec_plan_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.06.2009 17:51:11
  -- Purpose : Расчет премии за превышение плана
  PROCEDURE over_plan_calc(p_ag_perf_work_det_id NUMBER) IS
    proc_name      VARCHAR2(20) := 'Over_plan_calc';
    v_month_num    NUMBER;
    v_plan         t_agent_plan := t_agent_plan(NULL, NULL);
    v_sgp          NUMBER;
    v_percent      NUMBER;
    v_ag_status_id PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_ag_ch_id     PLS_INTEGER;
    v_commission   NUMBER;
    v_over_plan    PLS_INTEGER;
  BEGIN
    SELECT apw.status_id
          ,apw.ag_contract_header_id
          ,ac.category_id
      INTO v_ag_status_id
          ,v_ag_ch_id
          ,v_category_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.ag_contract_id = pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end);
  
    --Это конечно косяк таким образом зашиватся в коде, но сроки жмут а воротить огород
    --ради одной премии не хочу, если будут путные идеи потом переделаю
    SELECT ag_rate_type_id INTO v_over_plan FROM ag_rate_type WHERE brief = 'N_OVER_PLAN2X';
  
    v_sgp       := get_sgp(p_ag_perf_work_det_id);
    v_month_num := pkg_ag_calc_admin.get_cat_o_months(v_ag_ch_id, g_date_end, v_category_id);
    CASE
      WHEN g_roll_type_brief IN ('NMGR_0106', 'NDIR_0106')
           AND v_ag_status_id >= 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      WHEN g_roll_type_brief IN ('NMGR', 'NDIR')
           AND v_ag_status_id > 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      ELSE
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end);
    END CASE;
    v_percent := FLOOR(((v_sgp - v_plan.sgp_amount) / v_plan.sgp_amount) * 100);
  
    CASE
      WHEN v_percent < 50 THEN
        v_commission := 0;
      WHEN v_percent >= 50
           AND v_percent < 100 THEN
        v_commission := pkg_ag_calc_admin.get_premium_amount(g_rate_type_id
                                                            ,v_ag_status_id
                                                            ,g_date_end);
      WHEN v_percent >= 100 THEN
        v_commission := pkg_ag_calc_admin.get_premium_amount(v_over_plan, v_ag_status_id, g_date_end);
    END CASE;
  
    IF g_roll_num <> 1
    THEN
      v_commission := v_commission - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
    END IF;
  
    UPDATE ag_perfom_work_det
       SET summ       = v_commission
          ,mounth_num = v_month_num
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_commission;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END over_plan_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.06.2009 20:57:04
  -- Purpose : Расчитывает премию "Шаг развития"
  PROCEDURE evol_step_calc(p_ag_perf_work_det_id NUMBER) IS
    proc_name      VARCHAR2(20) := 'Evol_step_calc';
    v_month_num    NUMBER;
    v_plan         t_agent_plan := t_agent_plan(NULL, NULL);
    v_sgp          NUMBER;
    v_ag_status_id PLS_INTEGER;
    v_category_id  PLS_INTEGER;
    v_ag_ch_id     PLS_INTEGER;
    v_commission   NUMBER;
    v_kpp          NUMBER;
    v_evol_step    NUMBER := 50000;
    v_koef         NUMBER := 1;
  BEGIN
    SELECT apw.status_id
          ,apw.ag_contract_header_id
          ,ac.category_id
      INTO v_ag_status_id
          ,v_ag_ch_id
          ,v_category_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.ag_contract_id = pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end);
  
    v_evol_step := pkg_tariff_calc.calc_coeff_val('Evol_step_size'
                                                 ,t_number_type(to_char(g_date_end, 'yyyymmdd')
                                                               ,v_ag_status_id));
  
    IF v_ag_status_id = g_agst_mng1
       AND g_roll_type_brief = 'NMGR'
    THEN
      v_koef := 2;
    END IF;
  
    v_sgp       := get_sgp(p_ag_perf_work_det_id);
    v_month_num := pkg_ag_calc_admin.get_cat_o_months(v_ag_ch_id, g_date_end, v_category_id);
    CASE
      WHEN g_roll_type_brief IN ('NMGR_0106', 'NDIR_0106')
           AND v_ag_status_id >= 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      WHEN g_roll_type_brief IN ('NMGR', 'NDIR')
           AND v_ag_status_id > 202 THEN
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end, v_ag_ch_id);
      ELSE
        v_plan := pkg_ag_calc_admin.get_plan(v_month_num, v_ag_status_id, g_date_end);
    END CASE;
  
    v_kpp := FLOOR((v_sgp - v_koef * v_plan.sgp_amount) / v_evol_step);
  
    IF v_kpp < 1
    THEN
      v_commission := 0;
    ELSE
      v_commission := v_kpp *
                      pkg_ag_calc_admin.get_premium_amount(g_rate_type_id, v_ag_status_id, g_date_end);
    END IF;
  
    IF g_roll_num <> 1
    THEN
      v_commission := v_commission - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
    END IF;
  
    UPDATE ag_perfom_work_det
       SET summ       = v_commission
          ,mounth_num = v_month_num
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_commission;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END evol_step_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 16:06:18
  -- Purpose : Расчет дополнительной премии "Шаг развития"
  PROCEDURE add_evol_step_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'ADD_Evol_step_calc';
  BEGIN
  
    IF p_ag_perf_work_det_id IS NULL
    THEN
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END add_evol_step_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.06.2009 21:36:37
  -- Purpose : Расчитывает премию за развитие подчиненных
  PROCEDURE evol_sub_calc(p_ag_perf_work_det_id NUMBER) IS
    proc_name      VARCHAR2(20) := 'Evol_sub_calc';
    v_ag_status_id PLS_INTEGER;
    v_ag_ch_id     PLS_INTEGER;
    v_plan         t_agent_plan := t_agent_plan(NULL, NULL);
    v_sgp          NUMBER;
    v_category_id  PLS_INTEGER;
    v_month_num    NUMBER;
    v_commission   NUMBER := 0;
    v_evol_count   PLS_INTEGER := 0;
  BEGIN
    SELECT apw.status_id
          ,apw.ag_contract_header_id
          ,ac.category_id
      INTO v_ag_status_id
          ,v_ag_ch_id
          ,v_category_id
      FROM ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_contract          ac
     WHERE apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND ac.ag_contract_id = pkg_agent_1.get_status_by_date(apw.ag_contract_header_id, g_date_end);
  
    FOR evol_sub IN (SELECT ac.contract_id
                           ,pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 1) ag_stat_id
                       FROM ven_ag_contract ac
                      WHERE ac.date_begin < g_date_end
                        AND ac.category_id = v_category_id
                        AND pkg_renlife_utils.get_ag_stat_id(ac.contract_id, g_date_end, 3) <>
                            g_agst_mng_base
                        AND ac.num = (SELECT MIN(ac1.num)
                                        FROM ven_ag_contract ac1
                                       WHERE ac1.contract_id = ac.contract_id
                                         AND ac1.contract_f_lead_id IN
                                             (SELECT ag_contract_id
                                                FROM ag_contract
                                               WHERE contract_id = v_ag_ch_id)
                                         AND ac1.category_id = v_category_id)
                        AND pkg_ag_calc_admin.get_cat_o_months(ac.contract_id
                                                              ,g_date_end
                                                              ,v_category_id) <= 12
                        AND ac.contract_f_lead_id IN
                            (SELECT ag_contract_id FROM ag_contract WHERE contract_id = v_ag_ch_id))
    LOOP
    
      v_sgp       := get_sgp(p_ag_perf_work_det_id, evol_sub.contract_id);
      v_month_num := pkg_ag_calc_admin.get_cat_o_months(evol_sub.contract_id
                                                       ,g_date_end
                                                       ,v_category_id);
    
      CASE
        WHEN g_roll_type_brief IN ('NMGR_0106', 'NDIR_0106')
             AND evol_sub.ag_stat_id >= 202 THEN
          v_plan := pkg_ag_calc_admin.get_plan(v_month_num
                                              ,evol_sub.ag_stat_id
                                              ,g_date_end
                                              ,evol_sub.contract_id);
        WHEN g_roll_type_brief IN ('NMGR', 'NDIR')
             AND evol_sub.ag_stat_id > 202 THEN
          v_plan := pkg_ag_calc_admin.get_plan(v_month_num
                                              ,evol_sub.ag_stat_id
                                              ,g_date_end
                                              ,evol_sub.contract_id);
        ELSE
          v_plan := pkg_ag_calc_admin.get_plan(v_month_num, evol_sub.ag_stat_id, g_date_end);
      END CASE;
    
      IF v_sgp >= v_plan.sgp_amount
      THEN
        v_commission := v_commission + pkg_ag_calc_admin.get_premium_amount(g_rate_type_id
                                                                           ,v_ag_status_id
                                                                           ,g_date_end);
      END IF;
      v_evol_count := v_evol_count + 1;
    
    END LOOP;
  
    v_month_num := pkg_ag_calc_admin.get_cat_o_months(v_ag_ch_id, g_date_end, v_category_id);
  
    IF g_roll_num <> 1
    THEN
      v_commission := v_commission - pkg_ag_calc_admin.get_payed_amount(p_ag_perf_work_det_id);
    END IF;
  
    UPDATE ag_perfom_work_det
       SET summ                = v_commission
          ,mounth_num          = v_month_num
          ,count_recruit_agent = v_evol_count
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_commission;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END evol_sub_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.11.2009 10:38:25
  -- Purpose : Расчет дополнительной премии за работу группы
  PROCEDURE add_work_group_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'ADD_Work_group_calc';
    v_cash    t_cash;
  BEGIN
    v_cash := get_cash(p_ag_perf_work_det_id);
  
    UPDATE ag_perfom_work_det
       SET summ = v_cash.commiss_amount
     WHERE ag_perfom_work_det_id = p_ag_perf_work_det_id;
  
    g_commision := g_commision + v_cash.commiss_amount;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END add_work_group_calc;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 21.07.2009 16:02:54
  -- Purpose : Расчт премии за выращенных подчиненных
  PROCEDURE evol_sub_calc_010609(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'evol_sub_calc_010609';
  BEGIN
  
    IF p_ag_perf_work_det_id IS NULL
    THEN
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END evol_sub_calc_010609;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 16.06.2009 11:42:30
  -- Purpose : Расчитывает годовую премию Региональным/Терреториальным директорам
  PROCEDURE over_plan_year_calc(p_ag_perf_work_det_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'Over_plan_year_calc';
  BEGIN
  
    IF p_ag_perf_work_det_id IS NULL
    THEN
      NULL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END over_plan_year_calc;

BEGIN
  g_st_new         := dml_doc_status_ref.get_id_by_brief('NEW');
  g_st_act         := dml_doc_status_ref.get_id_by_brief('ACTIVE');
  g_st_resume      := dml_doc_status_ref.get_id_by_brief('RESUME');
  g_st_curr        := dml_doc_status_ref.get_id_by_brief('CURRENT');
  g_st_stoped      := dml_doc_status_ref.get_id_by_brief('STOPED');
  g_st_stop        := dml_doc_status_ref.get_id_by_brief('STOP');
  g_st_print       := dml_doc_status_ref.get_id_by_brief('PRINTED');
  g_st_revision    := dml_doc_status_ref.get_id_by_brief('REVISION');
  g_st_agrevision  := dml_doc_status_ref.get_id_by_brief('AGENT_REVISION');
  g_st_underwr     := dml_doc_status_ref.get_id_by_brief('UNDERWRITING');
  g_st_berak       := dml_doc_status_ref.get_id_by_brief('BREAK');
  g_st_readycancel := dml_doc_status_ref.get_id_by_brief('READY_TO_CANCEL');
  g_st_cancel      := dml_doc_status_ref.get_id_by_brief('CANCEL');
  g_st_paid        := dml_doc_status_ref.get_id_by_brief('PAID');
  g_st_annulated   := dml_doc_status_ref.get_id_by_brief('ANNULATED');
  g_st_concluded   := dml_doc_status_ref.get_id_by_brief('CONCLUDED');

  g_agst_mng_base := dml_ag_stat_agent.get_id_by_brief('БазМен');
  g_agst_ag_base  := dml_ag_stat_agent.get_id_by_brief('БазАг');
  g_agst_rop      := dml_ag_stat_agent.get_id_by_brief('МенРукОтдПр');
  g_agst_tdir     := dml_ag_stat_agent.get_id_by_brief('ТерДир');
  g_agst_reg_dir  := dml_ag_stat_agent.get_id_by_brief('РегДир');
  g_agst_mng1     := dml_ag_stat_agent.get_id_by_brief('Мен1Кат');

  g_catag_mn  := dml_ag_category_agent.get_id_by_brief('MN');
  g_ct_agent  := dml_ag_category_agent.get_id_by_brief('AG');
  g_cat_td_id := dml_ag_category_agent.get_id_by_brief('TD');

  g_dt_epg_doc          := dml_doc_templ.get_id_by_brief('PAYMENT');
  g_dt_pay_doc          := dml_doc_templ.get_id_by_brief('ПП');
  g_dt_a7_doc           := dml_doc_templ.get_id_by_brief('A7');
  g_dt_pd4_doc          := dml_doc_templ.get_id_by_brief('PD4');
  g_dt_ag_perf_work_act := dml_doc_templ.get_id_by_brief('AG_PERFOMED_WORK_ACT');

  g_pt_quater       := dml_t_payment_terms.get_id_by_brief('EVERY_QUARTER');
  g_pt_nonrecurring := dml_t_payment_terms.get_id_by_brief('Единовременно');
  g_pt_monthly      := dml_t_payment_terms.get_id_by_brief('MONTHLY');

  g_sc_dsf        := dml_t_sales_channel.get_id_by_brief('MLM');
  g_sc_sas        := dml_t_sales_channel.get_id_by_brief('SAS');
  g_sc_sas_2      := dml_t_sales_channel.get_id_by_brief('SAS 2');
  g_sc_grs_moscow := dml_t_sales_channel.get_id_by_brief('GRSMoscow');
  g_sc_grs_region := dml_t_sales_channel.get_id_by_brief('GRSRegion');
  g_sc_rla        := dml_t_sales_channel.get_id_by_brief('RLA');

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

  g_vt_life    := dml_ag_volume_type.get_id_by_brief('RL');
  g_vt_inv     := dml_ag_volume_type.get_id_by_brief('INV');
  g_vt_ops     := dml_ag_volume_type.get_id_by_brief('NPF');
  g_vt_ops_1   := dml_ag_volume_type.get_id_by_brief('NPF01');
  g_vt_ops_3   := dml_ag_volume_type.get_id_by_brief('NPF03');
  g_vt_ops_2   := dml_ag_volume_type.get_id_by_brief('NPF02');
  g_vt_ops_9   := dml_ag_volume_type.get_id_by_brief('NPF(MARK9)');
  g_vt_avc     := dml_ag_volume_type.get_id_by_brief('SOFI');
  g_vt_avc_pay := dml_ag_volume_type.get_id_by_brief('AVCP');
  g_vt_bank    := dml_ag_volume_type.get_id_by_brief('BANK');
  g_vt_fdep    := dml_ag_volume_type.get_id_by_brief('FDep');
  g_vt_nonevol := dml_ag_volume_type.get_id_by_brief('INFO');
  --g_vt_conv_sheet := dml_ag_volume_type.get_id_by_brief('CONV_SHEET');

  g_tt_insprempaid    := dml_trans_templ.get_id_by_brief('СтраховаяПремияОплачена');
  g_tt_inspremapaid   := dml_trans_templ.get_id_by_brief('СтраховаяПремияАвансОпл');
  g_tt_prempaidagent  := dml_trans_templ.get_id_by_brief('ПремияОплаченаПоср');
  g_tt_agentpaysetoff := dml_trans_templ.get_id_by_brief('ЗачВзнСтрАг');

  g_prod_id         := dml_t_product.get_id_by_description('Инвестор');
  g_prod_invplus_id := dml_t_product.get_id_by_description('Инвестор Плюс');

  g_ag_fake_agent      := 2125380;
  g_ag_external_agency := 8127;

END pkg_ag_mng_dir_calc;
/

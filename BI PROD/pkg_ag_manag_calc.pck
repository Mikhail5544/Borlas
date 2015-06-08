CREATE OR REPLACE PACKAGE pkg_ag_manag_calc IS

  -- Author  : DKOLGANOV
  -- Created : 31.05.2008 13:07:42
  -- Purpose : расчет премий менеджеров

  /*Интерфейсные фукнции */
  var_ven_ag_roll        ven_ag_roll%ROWTYPE;
  var_ven_ag_roll_header ven_ag_roll_header%ROWTYPE;

  PROCEDURE InitDataLocal;

  /*Расчет*/
  PROCEDURE calc
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  );

  /*Аттестация*/
  PROCEDURE attest
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER DEFAULT NULL
   ,p_ag_perfomed_work_act_id IN NUMBER DEFAULT NULL
  );

  /*-- Премии*/

  PROCEDURE m1_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m2_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE rop_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m1_evol_manag_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m2_evol_manag_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m1_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m1_over_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m1_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m2_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m2_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE rop_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE rop_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE m_break_policy_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  /*Аттестация*/

  FUNCTION m12_3plan
  (
    p_ag_contract_header_id IN NUMBER
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_sgp_id             IN NUMBER
  ) RETURN NUMBER;

END pkg_ag_manag_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_manag_calc IS

  PROCEDURE attest
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER DEFAULT NULL
   ,p_ag_perfomed_work_act_id IN NUMBER DEFAULT NULL
  )
  
   IS
  
    var_AG_ATTEST_DOCUMENT ven_AG_ATTEST_DOCUMENT%ROWTYPE;
    var_ven_AG_ROLL_TYPE   ven_AG_ROLL_TYPE%ROWTYPE;
    ret                    NUMBER;
  
  BEGIN
  
    RETURN;
  
    var_ven_ag_roll.ag_roll_id := p_ag_roll_id;
    InitDataLocal();
  
    var_ven_AG_ROLL_TYPE := PKG_AG_ROLL.GEtAgRollType(var_ven_ag_roll_header.AG_ROLL_TYPE_ID);
  
    var_AG_ATTEST_DOCUMENT.NUM       := PKG_AUTOSQ.NEXTVAL('ATTEST_DOCUMENT', '');
    var_AG_ATTEST_DOCUMENT.STAT_DATE := ADD_MONTHS(var_ven_ag_roll_header.DATE_BEGIN, 1);
  
    ret := PKG_AGENT_ATTEST.InsertAgAttestDocument(var_AG_ATTEST_DOCUMENT);
    DOC.SET_DOC_STATUS(p_ag_roll_id
                      ,'NEW'
                      ,SYSDATE
                      ,'AUTO'
                      ,'Автоматическое создание документа по ' || var_ven_AG_ROLL_TYPE.NAME);
  
    --Заглушка чтобы компилятор не ругался
    IF ret IS NULL
    THEN
      NULL;
    END IF;
    IF p_ag_contract_header_id IS NULL
    THEN
      NULL;
    END IF;
    IF p_ag_perfomed_work_act_id IS NULL
    THEN
      NULL;
    END IF;
  
  END attest;

  PROCEDURE InitDataLocal IS
  BEGIN
  
    var_ven_ag_roll        := PKG_AG_ROLL.GetAgRoll(var_ven_ag_roll.ag_roll_id);
    var_ven_ag_roll_header := PKG_AG_ROLL.GetAgRollHeader(var_ven_ag_roll.ag_roll_header_id);
  
  END InitDataLocal;

  --процедура для отбора менеджеров для расчета и организации ветвления процесса расчета
  PROCEDURE calc
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  ) IS
    v_apw_id    NUMBER;
    v_calc      NUMBER;
    v_apw_brief NUMBER;
    v_cat       NUMBER;
    CURSOR exist_act(ach_id NUMBER) IS(
      SELECT ap.ag_perfomed_work_act_id
        FROM ven_ag_perfomed_work_act ap
       WHERE ap.ag_roll_id = p_ag_roll_id
         AND ap.ag_contract_header_id = ach_id);
  
  BEGIN
  
    var_ven_ag_roll.ag_roll_id := p_ag_roll_id;
    InitDataLocal();
  
    --отбор СГП для расчета  
    pkg_agent_calculator.InsertInfo('Начало. Отбор СГП для расчета.');
    FOR cur_sgp_man IN (SELECT DISTINCT st.name_pkg
                          FROM ag_av_type_conform ac
                          JOIN ag_rate_type ar
                            ON ar.ag_rate_type_id = ac.ag_rate_type_id
                          JOIN t_sgp_type st
                            ON (st.t_sgp_type_id = ar.t_sgp_type_id)
                          JOIN ag_roll_header ah
                            ON (ah.ag_roll_type_id = ac.ag_roll_type_id)
                          JOIN ag_roll agr
                            ON (agr.ag_roll_header_id = ah.ag_roll_header_id)
                         WHERE agr.ag_roll_id = p_ag_roll_id)
    LOOP
      EXECUTE IMMEDIATE 'begin ' || cur_sgp_man.name_pkg ||
                        '.sgp_all_calc(:p_date, :p_ag_roll_id , :p_ag_contract_header_id ); end;'
        USING IN var_ven_ag_roll_header.date_begin, IN p_ag_roll_id, IN p_ag_contract_header_id;
    END LOOP;
  
    SELECT arh.ag_category_agent_id
      INTO v_cat
      FROM ven_ag_roll ar
      JOIN ven_ag_roll_header arh
        ON (ar.ag_roll_header_id = arh.ag_roll_header_id AND ar.ag_roll_id = p_ag_roll_id);
  
    IF v_cat <> 3
    THEN
    
      DELETE FROM ag_sgp ap
       WHERE ap.ag_roll_id = p_ag_roll_id
         AND ap.ag_contract_header_id = nvl(p_ag_contract_header_id, ap.ag_contract_header_id);
    
    END IF;
  
    --Почистим ведомость от мусора (если есть акты под которые нет СГП)
    DELETE FROM ven_ag_perfomed_work_act apw
     WHERE apw.ag_roll_id = p_ag_roll_id
       AND NOT EXISTS (SELECT 1
              FROM ag_sgp ap
             WHERE ap.ag_roll_id = p_ag_roll_id
               AND ap.ag_contract_header_id = apw.ag_contract_header_id);
  
    pkg_agent_calculator.InsertInfo('Завершение. Отбор СГП для расчета.');
  
    pkg_agent_calculator.InsertInfo('Начало. Отбор менеджеров для расчета.');
    v_calc := 0;
    --отбор менеджеров для расчета
    FOR all_m IN (SELECT SUM(1) over(PARTITION BY 1) AS COUNT_R
                        ,agp.ag_contract_header_id
                        ,pkg_ag_sgp.get_sgp(p_ag_roll_id, agp.ag_contract_header_id, 1) sgp1
                        ,pkg_ag_sgp.get_sgp(p_ag_roll_id, agp.ag_contract_header_id, 2) sgp2
                        ,pkg_ag_sgp.get_status(arh.date_end, agp.ag_contract_header_id) status_id
                        ,agp.category_id
                        ,arh.ag_roll_type_id
                        ,arh.date_end
                        ,agp.ag_stat_hist_id
                    FROM ag_sgp agp
                    JOIN ag_roll ar
                      ON (ar.ag_roll_id = agp.ag_roll_id)
                    JOIN ag_roll_header arh
                      ON (arh.ag_roll_header_id = ar.ag_roll_header_id)
                  
                   WHERE agp.ag_contract_header_id IN
                         (SELECT ap.ag_contract_header_id
                            FROM ag_sgp ap
                           WHERE ap.ag_roll_id = p_ag_roll_id
                             AND ap.category_id = 3
                           GROUP BY ap.ag_contract_header_id
                                   ,ap.status_id)
                     AND agp.ag_roll_id = p_ag_roll_id
                     AND agp.ag_contract_header_id =
                         nvl(p_ag_contract_header_id, agp.ag_contract_header_id))
    LOOP
    
      v_calc := v_calc + 1;
      IF (v_calc = 1)
      THEN
        pkg_agent_calculator.InsertInfo('Всего менеджеров для расчета ' || all_m.COUNT_R);
      END IF;
    
      SELECT d.doc_templ_id INTO v_apw_brief FROM doc_templ d WHERE d.brief = 'AG_PERFOMED_WORK_ACT';
    
      OPEN exist_act(all_m.ag_contract_header_id);
      FETCH exist_act
        INTO v_apw_id;
      IF (exist_act%NOTFOUND)
      THEN
        SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
      
        INSERT INTO ven_ag_perfomed_work_act
          (ag_perfomed_work_act_id
          ,ag_roll_id
          ,ag_contract_header_id
          ,delta
          ,sgp1
          ,sgp2
          ,SUM
          ,doc_templ_id
          ,date_calc
          ,ag_stat_hist_id
          ,status_id)
        VALUES
          (v_apw_id
          ,p_ag_roll_id
          ,all_m.ag_contract_header_id
          ,0
          ,all_m.sgp1
          ,all_m.sgp2
          ,0
          ,v_apw_brief
          ,SYSDATE
          ,all_m.ag_stat_hist_id
          ,all_m.status_id);
        CLOSE exist_act;
      ELSE
        UPDATE ven_ag_perfomed_work_act aw
           SET aw.delta           = 0
              ,aw.sgp1            = all_m.sgp1
              ,aw.sgp2            = all_m.sgp2
              ,aw.sum             = 0
              ,aw.date_calc       = SYSDATE
              ,aw.ag_stat_hist_id = all_m.ag_stat_hist_id
              ,aw.status_id       = all_m.status_id
         WHERE aw.ag_perfomed_work_act_id = v_apw_id;
      
        DELETE FROM ven_ag_perfom_work_det apd WHERE apd.ag_perfomed_work_act_id = v_apw_id;
        CLOSE exist_act;
      END IF;
    
      FOR all_prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                             ,arat.NAME
                         FROM ag_av_type_conform atc
                             ,ag_rate_type       arat
                             ,ag_roll_type       arot
                        WHERE atc.ag_rate_type_id = arat.ag_rate_type_id
                          AND atc.ag_roll_type_id = arot.ag_roll_type_id
                          AND atc.ag_roll_type_id = all_m.ag_roll_type_id
                          AND atc.ag_status_id =
                              pkg_ag_sgp.get_status(all_m.date_end, all_m.ag_contract_header_id))
      LOOP
      
        /*      select art.calc_fun, ART.NAME
         from ag_av_type_conform atc
         join ag_rate_type art on (art.ag_rate_type_id =
                                  atc.ag_rate_type_id)
         join ag_stat_agent asa on (asa.ag_stat_agent_id =
                                   atc.ag_status_id and
                                   asa.priority_in_calc is not null)
        where atc.ag_roll_type_id = all_m.ag_roll_type_id
          and atc.ag_status_id =
              pkg_ag_sgp.get_status(all_m.date_end,
                                    all_m.ag_contract_header_id)) loop*/
        EXECUTE IMMEDIATE all_prem.calc_fun
          USING IN p_ag_roll_id, IN all_m.ag_contract_header_id, IN v_apw_id;
      END LOOP;
    
    END LOOP;
    pkg_agent_calculator.InsertInfo('Завершение. Отбор менеджеров для расчета.');
  END;

  --процедура для расчета премии за работу менеджеров 1 категории
  PROCEDURE m1_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_sgp2     NUMBER;
    v_sgp_id   NUMBER;
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
    CURSOR def_sgp IS(
      SELECT ap.ag_sgp_id
            ,ap.sgp_sum
        FROM ag_sgp ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
         AND ap.ag_roll_id = p_ag_roll_id);
  
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  BEGIN
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
  
    CLOSE def_sgp;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_GR_M1');
    v_rec_det.summ                    := 0;
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    FOR men1_gr IN (SELECT aspd.ag_contract_header_ch_id
                          ,aspd.policy_id
                          ,aspd.sum
                      FROM ag_sgp asp
                      JOIN ag_sgp_det aspd
                        ON (asp.ag_sgp_id = aspd.ag_sgp_id)
                     WHERE asp.ag_contract_header_id = p_ag_contract_header_id
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := men1_gr.sum * 0.03;
      v_rec_dpol.ag_contract_header_ch_id := men1_gr.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
  
    OPEN get_psum(v_rec_det.ag_perfom_work_det_id);
    FETCH get_psum
      INTO v_rec_det.summ;
    IF (get_psum%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_psum;
    END IF;
    CLOSE get_psum;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
  
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  
  END;

  --процедура для расчета премии за работу менеджеров 2 категории
  PROCEDURE m2_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_sgp2     NUMBER;
    v_sgp_id   NUMBER;
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
    CURSOR def_sgp IS(
      SELECT ap.ag_sgp_id
            ,ap.sgp_sum
        FROM ag_sgp ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
         AND ap.ag_roll_id = p_ag_roll_id);
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  BEGIN
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
    CLOSE def_sgp;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_GR_M2');
    v_rec_det.summ                    := 0;
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    FOR men1_gr IN (SELECT aspd.ag_contract_header_ch_id
                          ,aspd.policy_id
                          ,aspd.sum
                      FROM ag_sgp asp
                      JOIN ag_sgp_det aspd
                        ON (asp.ag_sgp_id = aspd.ag_sgp_id)
                     WHERE asp.ag_contract_header_id = p_ag_contract_header_id
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := men1_gr.sum * 0.03;
      v_rec_dpol.ag_contract_header_ch_id := men1_gr.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
  
    OPEN get_psum(v_rec_det.ag_perfom_work_det_id);
    FETCH get_psum
      INTO v_rec_det.summ;
    IF (get_psum%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_psum;
    END IF;
    CLOSE get_psum;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  END;

  --процедура для расчета премии за работу руководителей отделов продаж
  PROCEDURE rop_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_sgp2     NUMBER;
    v_sgp_id   NUMBER;
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
    CURSOR def_sgp IS(
      SELECT ap.ag_sgp_id
            ,ap.sgp_sum
        FROM ag_sgp ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
         AND ap.ag_roll_id = p_ag_roll_id);
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  BEGIN
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
    CLOSE def_sgp;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_GR_ROP');
    v_rec_det.summ                    := 0;
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    FOR men1_gr IN (SELECT aspd.ag_contract_header_ch_id
                          ,aspd.policy_id
                          ,aspd.sum
                      FROM ag_sgp asp
                      JOIN ag_sgp_det aspd
                        ON (asp.ag_sgp_id = aspd.ag_sgp_id)
                     WHERE asp.ag_contract_header_id = p_ag_contract_header_id
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := men1_gr.sum * 0.02;
      v_rec_dpol.ag_contract_header_ch_id := men1_gr.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
  
    OPEN get_psum(v_rec_det.ag_perfom_work_det_id);
    FETCH get_psum
      INTO v_rec_det.summ;
    IF (get_psum%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_psum;
    END IF;
    CLOSE get_psum;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
  
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  
  END;

  --процедура для расчета премии за развитеие менеджеров менеджеров 1 категории
  PROCEDURE m1_evol_manag_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR get_c(cc_id NUMBER) IS(
      SELECT COUNT(1) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = cc_id);
  
    CURSOR cur_m(c_date DATE) IS(
      SELECT t.ag_contract_id
            ,t.contract_id
            ,t.category_id
            ,t.status_id
            ,t.months
            ,t.summ
            ,pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date) plan_m
        FROM (SELECT ac.ag_contract_id
                    ,ac.contract_id
                    ,ac.category_id
                    ,ap.status_id
                    ,pkg_ag_calc_admin.get_months(ac.contract_id, c_date, ac.category_id) months
                    ,ap.sgp_sum summ
                FROM ag_contract ac
                JOIN ag_sgp ap
                  ON (ac.contract_id = ap.ag_contract_header_id AND ap.ag_roll_id = p_ag_roll_id AND
                     ap.status_id = 200)
               WHERE ac.category_id = 3
                 AND ac.date_begin < c_date
                 AND ac.contract_f_lead_id IN
                     (SELECT ac1.ag_contract_id
                        FROM ven_ag_contract ac1
                       WHERE ac1.contract_id = p_ag_contract_header_id
                         AND ac1.category_id = ac.category_id)
                 AND (SELECT MAX(a.ag_contract_id)
                        FROM ag_contract a
                       WHERE a.date_begin < c_date
                         AND a.contract_id = ac.contract_id
                         AND a.category_id = ac.category_id) = ac.ag_contract_id) t
       WHERE t.summ >= pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date)
         AND pkg_ag_calc_admin.get_months(t.contract_id, c_date, t.category_id) <= 12);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
    v_date  DATE;
    p_cur_m cur_m%ROWTYPE;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('MEN_EVOL_M1');
    v_rec_det.summ                    := 0;
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    OPEN cur_m(v_date);
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_id
            ,p_cur_m.contract_id
            ,p_cur_m.category_id
            ,p_cur_m.status_id
            ,p_cur_m.months
            ,p_cur_m.summ
            ,p_cur_m.plan_m;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.num_months               := p_cur_m.months;
      v_rec_dpol.summ                     := p_cur_m.summ;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.contract_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    
    END LOOP;
  
    OPEN get_c(v_rec_det.ag_perfom_work_det_id);
    FETCH get_c
      INTO v_rec_det.count_recruit_agent;
    IF (get_c%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_c;
    END IF;
    CLOSE get_c;
    v_rec_det.summ := v_rec_det.count_recruit_agent * 10000;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  
    CLOSE cur_m;
  END;

  --процедура для расчета премии за развитеие менеджеров менеджеров 2 категории
  PROCEDURE m2_evol_manag_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR get_c(cc_id NUMBER) IS(
      SELECT COUNT(1) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = cc_id);
  
    CURSOR cur_m(c_date DATE) IS(
      SELECT t.ag_contract_id
            ,t.contract_id
            ,t.category_id
            ,t.status_id
            ,t.months
            ,t.summ
            ,pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date) plan_m
        FROM (SELECT ac.ag_contract_id
                    ,ac.contract_id
                    ,ac.category_id
                    ,ap.status_id
                    ,pkg_ag_calc_admin.get_months(ac.contract_id, c_date, ac.category_id) months
                    ,ap.sgp_sum summ
                FROM ag_contract ac
                JOIN ag_sgp ap
                  ON (ac.contract_id = ap.ag_contract_header_id AND ap.ag_roll_id = p_ag_roll_id AND
                     ap.status_id = 200)
               WHERE ac.category_id = 3
                 AND ac.date_begin < c_date
                 AND ac.contract_f_lead_id IN
                     (SELECT ac1.ag_contract_id
                        FROM ven_ag_contract ac1
                       WHERE ac1.contract_id = p_ag_contract_header_id
                         AND ac1.category_id = ac.category_id)
                 AND (SELECT MAX(a.ag_contract_id)
                        FROM ag_contract a
                       WHERE a.date_begin < c_date
                         AND a.contract_id = ac.contract_id
                         AND a.category_id = ac.category_id) = ac.ag_contract_id) t
       WHERE t.summ >= pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date)
         AND pkg_ag_calc_admin.get_months(t.contract_id, c_date, t.category_id) <= 12);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
    v_date  DATE;
    p_cur_m cur_m%ROWTYPE;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('MEN_EVOL_M2');
    v_rec_det.summ                    := 0;
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    OPEN cur_m(v_date);
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_id
            ,p_cur_m.contract_id
            ,p_cur_m.category_id
            ,p_cur_m.status_id
            ,p_cur_m.months
            ,p_cur_m.summ
            ,p_cur_m.plan_m;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.num_months               := p_cur_m.months;
      v_rec_dpol.summ                     := p_cur_m.summ;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.contract_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    
    END LOOP;
  
    OPEN get_c(v_rec_det.ag_perfom_work_det_id);
    FETCH get_c
      INTO v_rec_det.count_recruit_agent;
    IF (get_c%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_c;
    END IF;
    CLOSE get_c;
    v_rec_det.summ := v_rec_det.count_recruit_agent * 10000;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  
    CLOSE cur_m;
  END;

  --процедура для расчета премии за выполнение плана менеджеров 1 категории
  PROCEDURE m1_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND a.ag_contract_header_id = p_ag_contract_header_id AND
             a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date       DATE;
    v_date_beg   DATE;
    v_month_num  NUMBER;
    v_sgp_plan   NUMBER;
    v_month_koef NUMBER;
    p_cur_m      cur_m%ROWTYPE;
    p_cur_sgp    cur_sgp%ROWTYPE;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_M1');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
  
    --1) Выполнил ли менеджер план
    IF v_sgp_plan > p_cur_sgp.sgp_sum
    THEN
      --2) План не выполен проверяем месяц работы 
      IF v_month_num = 1
      THEN
      
        v_date_beg   := pkg_ag_calc_admin.get_date_cat(p_ag_contract_header_id, v_date, 3);
        v_month_koef := (LAST_DAY(v_date_beg) - v_date_beg + 1) /
                        EXTRACT(DAY FROM LAST_DAY(v_date_beg));
        --3) Получим "пропорциональный" план и сравним его с СГП
        IF v_month_koef * v_sgp_plan > p_cur_sgp.sgp_sum
        THEN
          v_rec_det.summ := 0;
          pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
        ELSE
          --В соответсвии с приказом от 26/11/2008
          v_rec_det.summ := 10000 * p_cur_sgp.sgp_sum / v_sgp_plan;
          pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
        END IF;
      
      ELSE
        --Месяц работы не впервый менеджер ничего не получает
        v_rec_det.summ := 0;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      END IF;
    ELSE
      -- План выполнен начисляем премию
      v_rec_det.summ := 10000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета премии за перевыполнение плана менеджеров 1 категории
  PROCEDURE m1_over_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND a.ag_contract_header_id = p_ag_contract_header_id AND
             a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_sgp_plan  NUMBER;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_percent   NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('OVER_PLAN_M1');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
  
    --В соответсвии с приказом от 26/11/2008
    IF v_sgp_plan > p_cur_sgp.sgp_sum
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      -- План выполнен начисляем премию
      v_percent      := FLOOR(((p_cur_sgp.sgp_sum - v_sgp_plan) / v_sgp_plan) * 100) + 100;
      v_rec_det.summ := pkg_ag_calc_admin.get_bonus(v_month_num, p_cur_sgp.status_id, v_percent);
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета премии "Шаг развития" менеджеров 1 категории
  --01.08.2008 Каткевич - Внес исправления в код
  PROCEDURE m1_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND a.ag_contract_header_id = p_ag_contract_header_id AND
             a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_kpdp      NUMBER;
    v_sgp_plan  NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_M1');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    --чтобы проще было читать и отлаживать код:
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
    v_kpdp      := FLOOR((p_cur_sgp.sgp_sum - 2 * v_sgp_plan) / 50000);
  
    --В соответствии с приказом от 26/11/2008
    IF v_kpdp < 1
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := v_kpdp * 5000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета премии за выполнение плана менеджеров 2 категории
  PROCEDURE m2_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND a.ag_contract_header_id = p_ag_contract_header_id AND
             a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_date      DATE;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_sgp_plan  NUMBER;
    v_rec_det   ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol  ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act   ven_ag_perfomed_work_act%ROWTYPE;
    v_month_num NUMBER;
  
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_M2');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
  
    IF v_sgp_plan > p_cur_sgp.sgp_sum
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := 15000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета премии "Шаг развития" менеджеров 2 категории
  PROCEDURE m2_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND a.ag_contract_header_id = p_ag_contract_header_id AND
             a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_month_num NUMBER;
    v_sgp_plan  NUMBER;
    v_kpp       NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_M2');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
    v_kpp       := FLOOR((p_cur_sgp.sgp_sum - v_sgp_plan) / 50000);
  
    IF v_kpp < 1
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := v_kpp * 5000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  
  END;

  --процедура для расчета премии за выполнение плана руководителей отделов продаж
  PROCEDURE rop_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND --a.sgp_type_id = 1 and
             a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE /*a.sgp_type_id = 1
                                                         and */
       a.ag_contract_header_id = p_ag_contract_header_id
       AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_date      DATE;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_rec_det   ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol  ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act   ven_ag_perfomed_work_act%ROWTYPE;
    v_month_num NUMBER;
    v_sgp_plan  NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_ROP');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
  
    IF v_sgp_plan > p_cur_sgp.sgp_sum
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := 25000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета премии "Шаг развития" руководителей отделов продаж
  PROCEDURE rop_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_m IS(
      SELECT d.ag_contract_header_ch_id
            ,d.policy_id
            ,d.sum
        FROM ag_sgp_det d
        JOIN ag_sgp a
          ON (a.ag_sgp_id = d.ag_sgp_id AND --a.sgp_type_id = 1 and
             a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE /*a.sgp_type_id = 1
                                                         and */
       a.ag_contract_header_id = p_ag_contract_header_id
       AND a.ag_roll_id = p_ag_roll_id);
  
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
  
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_sgp_plan  NUMBER;
    v_kpp       NUMBER;
    v_month_num NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_ROP');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 3);
    v_sgp_plan  := pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
    v_kpp       := FLOOR((p_cur_sgp.sgp_sum - v_sgp_plan) / 50000);
  
    IF v_kpp < 1
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := v_kpp * 5000;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    END IF;
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
    OPEN cur_m;
    LOOP
      FETCH cur_m
        INTO p_cur_m.ag_contract_header_ch_id
            ,p_cur_m.policy_id
            ,p_cur_m.sum;
      EXIT WHEN cur_m%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := p_cur_m.policy_id;
      v_rec_dpol.summ                     := p_cur_m.sum;
      v_rec_dpol.ag_contract_header_ch_id := p_cur_m.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    END LOOP;
    CLOSE cur_m;
  END;

  --процедура для расчета расторжений менеджерам
  PROCEDURE m_break_policy_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_mbr(c_date DATE) IS(
      SELECT app.policy_id
            ,apw.ag_contract_header_id
            ,((app.summ *
             (pt.number_of_payments -
             (SELECT COUNT(1)
                   FROM p_policy pp
                   JOIN doc_doc dd
                     ON (dd.parent_id = pp.policy_id)
                   JOIN ac_payment ap
                     ON (ap.payment_id = dd.child_id AND ap.payment_templ_id = 1)
                  WHERE Doc.get_doc_status_brief(ap.payment_id, TO_DATE('31.12.9999', 'DD.MM.YYYY')) =
                        'PAID'
                    AND pp.pol_header_id = ph.policy_header_id))) / pt.number_of_payments) sum_v
            ,app.ag_contract_header_ch_id
        FROM ag_perfom_work_det   apd
            ,ag_perfomed_work_act apw
            ,ag_roll              ar
            ,ag_roll_header       arh
            ,ag_perfom_work_dpol  app
            ,p_policy             p
            ,p_pol_header         ph
            ,t_product            tp
            ,t_payment_terms      pt
       WHERE ph.policy_header_id = p.pol_header_id
         AND pt.id = p.payment_term_id
         AND tp.product_id = ph.product_id
         AND p.policy_id = app.policy_id
         AND arh.date_begin <= c_date
         AND arh.ag_roll_header_id = ar.ag_roll_header_id
         AND ar.ag_roll_id = apw.ag_roll_id
         AND arh.ag_roll_type_id = 51
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND app.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
         AND app.policy_id IN (SELECT p.policy_id
                                 FROM p_policy p
                                 JOIN doc_status d
                                   ON d.document_id = p.policy_id
                                WHERE d.doc_status_ref_id = 10
                                  AND d.start_date > c_date
                                  AND d.start_date < last_day(c_date)
                                  AND (d.start_date - p.start_date) < 366));
  
    CURSOR cur_date IS(
      SELECT arh.date_begin
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT nvl(SUM(d.summ), 0)
        FROM ven_ag_perfom_work_det d
       WHERE d.ag_perfomed_work_act_id = ca_id);
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
    v_date     DATE;
    v_cur_mbr  cur_mbr%ROWTYPE;
    --v_apd_id   number;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('DEC_MEN');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
    v_rec_det.summ                    := 0;
    pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN cur_mbr(v_date);
    LOOP
      FETCH cur_mbr
        INTO v_cur_mbr.policy_id
            ,v_cur_mbr.ag_contract_header_id
            ,v_cur_mbr.sum_v
            ,v_cur_mbr.ag_contract_header_ch_id;
      EXIT WHEN cur_mbr%NOTFOUND;
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := v_cur_mbr.policy_id;
      v_rec_dpol.summ                     := v_cur_mbr.sum_v;
      v_rec_dpol.ag_contract_header_ch_id := v_cur_mbr.ag_contract_header_ch_id;
      v_rec_dpol.ag_perfom_work_det_id    := v_rec_det.ag_perfom_work_det_id;
    
      pkg_ag_act_calc.insert_ag_perf_dpol(v_rec_dpol);
    
    END LOOP;
    CLOSE cur_mbr;
  
    OPEN get_psum(v_rec_det.ag_perfom_work_det_id);
    FETCH get_psum
      INTO v_rec_det.summ;
    IF (get_psum%NOTFOUND)
    THEN
      v_rec_det.summ := 0;
      CLOSE get_psum;
    END IF;
    CLOSE get_psum;
    pkg_ag_act_calc.update_ag_perf_det(v_rec_det);
  
    v_rec_act := pkg_ag_act_calc.get_ag_perfomed_work_act(p_ag_perfomed_work_act_id);
  
    OPEN get_asum(p_ag_perfomed_work_act_id);
    FETCH get_asum
      INTO v_rec_act.sum;
    IF (get_asum%NOTFOUND)
    THEN
      v_rec_act.sum := 0;
      CLOSE get_asum;
    END IF;
    CLOSE get_asum;
    v_rec_act.delta := pkg_ag_calc_admin.get_delta(p_ag_roll_id
                                                  ,p_ag_contract_header_id
                                                  ,v_rec_act.sum);
    pkg_ag_act_calc.update_ag_perfomed_work_act(v_rec_act);
  END;

  FUNCTION m12_3plan
  (
    p_ag_contract_header_id IN NUMBER
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_sgp_id             IN NUMBER
  ) RETURN NUMBER IS
    res NUMBER := UTILS.C_FALSE;
  BEGIN
  
    IF p_ag_sgp_id IS NULL
    THEN
      NULL;
    END IF;
  
    FOR rec IN (SELECT MONTHS_BETWEEN(ARH.DATE_BEGIN, W.DATE_BEGIN) AS COUNT_MOUNTH
                  FROM ag_contract_header w
                      ,AG_ROLL            ar
                      ,AG_ROLL_HEADER     arh
                 WHERE w.ag_contract_header_id = p_ag_contract_header_id
                   AND AR.AG_ROLL_ID = p_ag_roll_id
                   AND ARH.AG_ROLL_HEADER_ID = AR.AG_ROLL_HEADER_ID)
    LOOP
      IF (rec.COUNT_MOUNTH >= 12)
      THEN
        res := UTILS.C_TRUE;
      END IF;
    END LOOP;
  
    RETURN res;
  
  END;

END pkg_ag_manag_calc;
/

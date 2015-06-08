CREATE OR REPLACE PACKAGE pkg_ag_dir_calc IS

  -- Author  : DKOLGANOV
  -- Created : 16.06.2008 12:11:20
  -- Purpose : пакет для расчета вознаграждения для директоров

  /*Интерфейсные фукнции */
  var_ven_ag_roll        ven_ag_roll%ROWTYPE;
  var_ven_ag_roll_header ven_ag_roll_header%ROWTYPE;

  PROCEDURE InitDataLocal;

  -- Public type declarations
  PROCEDURE calc
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  );

  PROCEDURE d1_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d2_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE td_work_group_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d1_evol_dir_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d2_evol_dir_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d1_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d1_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d2_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d2_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE td_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE td_evol_step_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE rd_exec_plan_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

  PROCEDURE d_break_policy_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );
  PROCEDURE td_over_year_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );
  PROCEDURE rd_over_year_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  );

END pkg_ag_dir_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_dir_calc IS

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
    FOR cur_sgp_dir IN (SELECT DISTINCT st.name_pkg
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
      EXECUTE IMMEDIATE 'begin ' || cur_sgp_dir.name_pkg ||
                        '.sgp_all_calc(:p_date, :p_ag_roll_id , :p_ag_contract_header_id ); end;'
        USING IN var_ven_ag_roll_header.date_begin, IN p_ag_roll_id, IN p_ag_contract_header_id;
    END LOOP;
  
    SELECT arh.ag_category_agent_id
      INTO v_cat
      FROM ven_ag_roll ar
      JOIN ven_ag_roll_header arh
        ON (ar.ag_roll_header_id = arh.ag_roll_header_id AND ar.ag_roll_id = p_ag_roll_id);
  
    IF v_cat <> 4
    THEN
    
      DELETE FROM ag_sgp ap
       WHERE ap.ag_roll_id = p_ag_roll_id
         AND ap.ag_contract_header_id = nvl(p_ag_contract_header_id, ap.ag_contract_header_id);
    END IF;
  
    DELETE FROM ven_ag_perfomed_work_act apw
     WHERE apw.ag_roll_id = p_ag_roll_id
       AND NOT EXISTS (SELECT 1
              FROM ag_sgp ap
             WHERE ap.ag_roll_id = p_ag_roll_id
               AND ap.ag_contract_header_id = apw.ag_contract_header_id);
  
    pkg_agent_calculator.InsertInfo('Завершение. Отбор СГП для расчета.');
  
    pkg_agent_calculator.InsertInfo('Начало. Отбор директоров для расчета.');
  
    --отбор менеджеров для расчета
    v_calc := 0;
    FOR all_d IN (SELECT agp.ag_contract_header_id
                        ,SUM(1) over(PARTITION BY 1) AS COUNT_R
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
                             AND ap.category_id = 4
                           GROUP BY ap.ag_contract_header_id
                                   ,ap.status_id)
                     AND agp.ag_roll_id = p_ag_roll_id
                     AND agp.ag_contract_header_id =
                         nvl(p_ag_contract_header_id, agp.ag_contract_header_id))
    LOOP
    
      v_calc := v_calc + 1;
      IF (v_calc = 1)
      THEN
        pkg_agent_calculator.InsertInfo('Всего директоров для расчета ' || all_d.COUNT_R);
      END IF;
      SELECT d.doc_templ_id INTO v_apw_brief FROM doc_templ d WHERE d.brief = 'AG_PERFOMED_WORK_ACT';
    
      OPEN exist_act(all_d.ag_contract_header_id);
      FETCH exist_act
        INTO v_apw_id;
      IF (exist_act%NOTFOUND)
      THEN
        SELECT sq_ag_perfomed_work_act.nextval INTO v_apw_id FROM dual;
        pkg_renlife_utils.tmp_log_writer('2');
      
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
          ,all_d.ag_contract_header_id
          ,0
          ,all_d.sgp1
          ,all_d.sgp2
          ,0
          ,v_apw_brief
          ,SYSDATE
          ,all_d.ag_stat_hist_id
          ,all_d.status_id);
        CLOSE exist_act;
      
      ELSE
        UPDATE ven_ag_perfomed_work_act aw
           SET aw.delta           = 0
              ,aw.sgp1            = all_d.sgp1
              ,aw.sgp2            = all_d.sgp2
              ,aw.sum             = 0
              ,aw.date_calc       = SYSDATE
              ,aw.ag_stat_hist_id = all_d.ag_stat_hist_id
              ,aw.status_id       = all_d.status_id
         WHERE aw.ag_perfomed_work_act_id = v_apw_id;
      
        DELETE FROM ag_perfom_work_det apw WHERE apw.ag_perfomed_work_act_id = v_apw_id;
        CLOSE exist_act;
      END IF;
    
      --   pkg_renlife_utils.tmp_log_writer('1');
    
      FOR all_prem IN (SELECT 'begin ' || arot.calc_pkg || '.' || arat.calc_fun || '; end;' calc_fun
                             ,arat.NAME
                         FROM ag_av_type_conform atc
                             ,ag_rate_type       arat
                             ,ag_roll_type       arot
                        WHERE atc.ag_rate_type_id = arat.ag_rate_type_id
                          AND atc.ag_roll_type_id = arot.ag_roll_type_id
                          AND atc.ag_roll_type_id = all_d.ag_roll_type_id
                          AND atc.ag_status_id =
                              pkg_ag_sgp.get_status(all_d.date_end, all_d.ag_contract_header_id))
      LOOP
        /*(select art.calc_fun
         from ag_av_type_conform atc
         join ag_rate_type art on (art.ag_rate_type_id =
                                  atc.ag_rate_type_id)
         join ag_stat_agent asa on (asa.ag_stat_agent_id =
                                   atc.ag_status_id and
                                   asa.priority_in_calc is not null)
        where atc.ag_roll_type_id = all_d.ag_roll_type_id
          and atc.ag_status_id =
              pkg_ag_sgp.get_status(all_d.date_end,
                                    all_d.ag_contract_header_id)) loop*/
        EXECUTE IMMEDIATE all_prem.calc_fun
          USING IN p_ag_roll_id, IN all_d.ag_contract_header_id, IN v_apw_id;
        --  pkg_renlife_utils.tmp_log_writer(all_prem.calc_fun||' '||all_d.ag_contract_header_id||' '||v_apw_id);
      END LOOP;
    END LOOP;
    pkg_agent_calculator.InsertInfo('Завершение. Отбор директоров для расчета.');
  END;

  --процедура для расчета премии за работу менеджеров 1 категории
  PROCEDURE d1_work_group_calc
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
            --and ap.sgp_type_id = 2
         AND ap.ag_roll_id = p_ag_roll_id);
  
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  BEGIN
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
  
    CLOSE def_sgp;
    /* select ap.ag_sgp_id, ap.sgp_sum
    into v_sgp_id, v_sgp2
        from ag_sgp ap
       where ap.ag_contract_header_id = p_ag_contract_header_id
         and ap.sgp_type_id = 2
         and ap.ag_roll_id = p_ag_roll_id;*/
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_AG_D1');
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
                          --and asp.sgp_type_id = 2
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := (men1_gr.sum) * 0.01;
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

  --процедура для расчета премии за работу менеджеров 2 категории
  PROCEDURE d2_work_group_calc
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
  
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR def_sgp IS(
      SELECT ap.ag_sgp_id
            ,ap.sgp_sum
        FROM ag_sgp ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
            --     and ap.sgp_type_id = 2
         AND ap.ag_roll_id = p_ag_roll_id);
  
  BEGIN
  
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
  
    CLOSE def_sgp;
  
    /* select ap.ag_sgp_id, ap.sgp_sum
    into v_sgp_id, v_sgp2
        from ag_sgp ap
       where ap.ag_contract_header_id = p_ag_contract_header_id
         and ap.sgp_type_id = 2
         and ap.ag_roll_id = p_ag_roll_id;*/
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_AG_D2');
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
                          -- and asp.sgp_type_id = 2
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := (men1_gr.sum) * 0.01;
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
  PROCEDURE td_work_group_calc
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
  
    CURSOR get_psum(c_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR def_sgp IS(
      SELECT ap.ag_sgp_id
            ,ap.sgp_sum
        FROM ag_sgp ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
            --    and ap.sgp_type_id = 2
         AND ap.ag_roll_id = p_ag_roll_id);
  BEGIN
  
    OPEN def_sgp;
    FETCH def_sgp
      INTO v_sgp_id
          ,v_sgp2;
  
    CLOSE def_sgp;
  
    /* select ap.ag_sgp_id, ap.sgp_sum
    into v_sgp_id, v_sgp2
        from ag_sgp ap
       where ap.ag_contract_header_id = p_ag_contract_header_id
         and ap.sgp_type_id = 2
         and ap.ag_roll_id = p_ag_roll_id;*/
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('WORK_AG_TD');
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
                          -- and asp.sgp_type_id = 2
                       AND asp.ag_roll_id = p_ag_roll_id)
    LOOP
    
      v_rec_dpol.ag_perfom_work_dpol_id   := NULL;
      v_rec_dpol.policy_id                := men1_gr.policy_id;
      v_rec_dpol.summ                     := (men1_gr.sum) * 0.005;
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

  --процедура для расчета премии за развитеие дироекторов для директоров 1 категории
  PROCEDURE d1_evol_dir_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR get_c(cc_id NUMBER) IS(
      SELECT COUNT(1) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = cc_id);
  
    CURSOR cur_m(c_date DATE) IS(
      SELECT t.ag_contract_id
            ,t.contract_id
            ,t.category_id
            ,t.status_id
            ,t.months
            ,t.summ
            ,
             --pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date) plan_m
             pkg_renlife_utils.get_ag_plan(t.contract_id, c_date, 1) plan_m
        FROM (SELECT ac.ag_contract_id
                    ,ac.contract_id
                    ,ac.category_id
                    ,ap.status_id
                    ,pkg_ag_calc_admin.get_months(ac.contract_id, c_date, ac.category_id) months
                    ,ap.sgp_sum summ
                FROM ag_contract ac
                JOIN ag_sgp ap
                  ON (ac.contract_id = ap.ag_contract_header_id AND
                     -- ap.sgp_type_id = 1 and
                     ap.ag_roll_id = p_ag_roll_id AND ap.status_id = 203)
               WHERE ac.category_id = 4
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
       WHERE t.summ >= --pkg_renlife_utils.get_ag_plan(t.contract_id, c_date, 1)
             pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date)
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
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('DIR_EVOL_D1');
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
    v_rec_det.summ := v_rec_det.count_recruit_agent * 30000;
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

  --процедура для расчета премии за развитеие дироекторов для директоров 2 категории
  PROCEDURE d2_evol_dir_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    CURSOR get_c(cc_id NUMBER) IS(
      SELECT COUNT(1) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = cc_id);
  
    CURSOR cur_m(c_date DATE) IS(
      SELECT t.ag_contract_id
            ,t.contract_id
            ,t.category_id
            ,t.status_id
            ,t.months
            ,t.summ
            ,
             --pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date) plan_m
             pkg_renlife_utils.get_ag_plan(t.contract_id, c_date, 1) plan_m
        FROM (SELECT ac.ag_contract_id
                    ,ac.contract_id
                    ,ac.category_id
                    ,ap.status_id
                    ,pkg_ag_calc_admin.get_months(ac.contract_id, c_date, ac.category_id) months
                    ,ap.sgp_sum summ
                FROM ag_contract ac
                JOIN ag_sgp ap
                  ON (ac.contract_id = ap.ag_contract_header_id AND
                     --ap.sgp_type_id = 1 and
                     ap.ag_roll_id = p_ag_roll_id AND ap.status_id = 203)
               WHERE ac.category_id = 4
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
       WHERE t.summ >= --pkg_renlife_utils.get_ag_plan(t.contract_id, c_date, 1)
             pkg_ag_calc_admin.get_plan_old(t.months, t.status_id, c_date)
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
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('DIR_EVOL_D2');
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
    v_rec_det.summ := v_rec_det.count_recruit_agent * 30000;
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
  PROCEDURE d1_exec_plan_calc
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
          ON (a.ag_sgp_id = d.ag_sgp_id /*and a.sgp_type_id = 1*/
             AND a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_date_beg  DATE;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4);
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EXEC_PLAN_D1');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF v_month_num = 1
    THEN
    
      /* select ach.date_begin
       into v_date_beg
       from ag_contract_header ach
      where ach.ag_contract_header_id = p_ag_contract_header_id;*/
    
      v_date_beg := pkg_ag_calc_admin.get_date_cat(p_ag_contract_header_id, v_date, 4);
    
      IF ((LAST_DAY(v_date_beg) - v_date_beg + 1) *
         --pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) /
         pkg_ag_calc_admin.get_plan_old(1, p_cur_sgp.status_id, v_date) /
         EXTRACT(DAY FROM LAST_DAY(v_date_beg)) > p_cur_sgp.sgp_sum)
      THEN
        v_rec_det.summ := 0;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      ELSE
        v_rec_det.summ := (((LAST_DAY(v_date_beg) - v_date_beg + 1) * 25000) /
                          EXTRACT(DAY FROM LAST_DAY(v_date_beg)));
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      END IF;
    ELSE
      IF pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date) > p_cur_sgp.sgp_sum
      --pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
      THEN
        v_rec_det.summ := 0;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      ELSE
        v_rec_det.summ := 25000;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      END IF;
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

  --процедура для расчета премии "Шаг развития" директоров 1 категории
  PROCEDURE d1_evol_step_calc
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
          ON (a.ag_sgp_id = d.ag_sgp_id /*and a.sgp_type_id = 1*/
             AND a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date        DATE;
    v_date_beg    DATE;
    v_month_num   NUMBER;
    p_cur_m       cur_m%ROWTYPE;
    p_cur_sgp     cur_sgp%ROWTYPE;
    v_kpdp        NUMBER;
    v_sgp_plan    NUMBER;
    v_worked_days NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4);
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_D1');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    --чтобы проще было читать и отлаживать код:
    v_sgp_plan :=  --pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1);
     pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date);
    v_kpdp     := ((p_cur_sgp.sgp_sum - v_sgp_plan) / 50000);
  
    IF v_month_num = 1
    THEN
    
      /*SELECT MAX(stat_date) KEEP (dense_rank LAST ORDER BY ash.num DESC)
       INTO v_date_beg
       FROM ag_stat_hist ash
      WHERE ash.ag_contract_header_id = p_ag_contract_header_id
        AND ash.stat_date <= v_date
        AND ash.ag_category_agent_id = 4; */ --> Нифига не правильно по логике, но работает на практике
      v_date_beg    := pkg_ag_calc_admin.get_date_cat(p_ag_contract_header_id, v_date, 4);
      v_worked_days := (LAST_DAY(v_date_beg) - v_date_beg + 1) /
                       EXTRACT(DAY FROM LAST_DAY(v_date_beg));
      v_kpdp        := (p_cur_sgp.sgp_sum - v_worked_days * v_sgp_plan) / 50000;
    
      IF (v_kpdp / v_worked_days) < 1
      THEN
        v_rec_det.summ := 0;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      ELSE
        v_rec_det.summ := FLOOR(v_kpdp) * v_worked_days * 5000;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      END IF;
    
    ELSE
      IF v_kpdp < 1
      THEN
        v_rec_det.summ := 0;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      ELSE
        v_rec_det.summ := FLOOR(v_kpdp) * 5000;
        pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
      END IF;
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

  PROCEDURE d2_exec_plan_calc
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
          ON (a.ag_sgp_id = d.ag_sgp_id /*and a.sgp_type_id = 1*/
             AND a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    SELECT pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4)
      INTO v_month_num
      FROM dual;
  
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_D2');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
    THEN
      --pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date) >
    
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := pkg_ag_calc_admin.get_bonus(1000, p_cur_sgp.status_id, 100);
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

  PROCEDURE d2_evol_step_calc
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
          ON (a.ag_sgp_id = d.ag_sgp_id /*and a.sgp_type_id = 1*/
             AND a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_kpdp      NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4);
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_D2');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
    --(pkg_ag_calc_admin.get_plan_old(v_month_num, p_cur_sgp.status_id, v_date)) >
    THEN
    
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      SELECT FLOOR((p_cur_sgp.sgp_sum -
                   pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1)) / 50000)
        INTO v_kpdp
        FROM dual;
    
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

  PROCEDURE td_exec_plan_calc
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
          ON (a.ag_sgp_id = d.ag_sgp_id /*and a.sgp_type_id = 1*/
             AND a.ag_contract_header_id = p_ag_contract_header_id AND a.ag_roll_id = p_ag_roll_id));
  
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,a.status_id
        FROM ag_sgp a
       WHERE /*a.sgp_type_id = 1
                                 and*/
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date    DATE;
    p_cur_m   cur_m%ROWTYPE;
    p_cur_sgp cur_sgp%ROWTYPE;
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
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_TD');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := 80000;
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

  PROCEDURE td_evol_step_calc
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    v_month_num NUMBER;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
    v_kpdp      NUMBER;
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4);
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO p_cur_sgp.sgp_sum
          ,p_cur_sgp.status_id;
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('EVOL_STEP_TD');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
    THEN
    
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      SELECT FLOOR((p_cur_sgp.sgp_sum -
                   pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1)) / 50000)
        INTO v_kpdp
        FROM dual;
    
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

  PROCEDURE rd_exec_plan_calc
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date      DATE;
    p_cur_m     cur_m%ROWTYPE;
    p_cur_sgp   cur_sgp%ROWTYPE;
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
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('PLAN_EXEC_RD');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    v_month_num := pkg_ag_calc_admin.get_months(p_ag_contract_header_id, v_date, 4);
  
    IF pkg_renlife_utils.get_ag_plan(p_ag_contract_header_id, v_date, 1) > p_cur_sgp.sgp_sum
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := pkg_ag_calc_admin.get_bonus(1, p_cur_sgp.status_id, p_cur_sgp.sgp_sum);
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

  PROCEDURE d_break_policy_calc
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
         AND arh.ag_roll_type_id = 54
         AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
         AND app.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
         AND apw.ag_contract_header_id = nvl(p_ag_contract_header_id, apw.ag_contract_header_id)
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
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_dpol d WHERE d.ag_perfom_work_det_id = c_id);
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
    v_rec_det  ven_ag_perfom_work_det%ROWTYPE;
    v_rec_dpol ven_ag_perfom_work_dpol%ROWTYPE;
    v_rec_act  ven_ag_perfomed_work_act%ROWTYPE;
    v_date     DATE;
    v_cur_mbr  cur_mbr%ROWTYPE;
  BEGIN
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('DEC_DIR');
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

  PROCEDURE td_over_year_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
    CURSOR cur_m(c_date DATE) IS(
      SELECT apw.ag_contract_header_id
            ,(SUM(apw.sgp1) over(PARTITION BY apw.ag_contract_header_id)) sgp
            ,((SUM(1) over(PARTITION BY apw.ag_contract_header_id)) * 3000000) plan_s
        FROM ven_ag_perfomed_work_act apw
        JOIN ven_ag_roll ar
          ON (ar.ag_roll_id = apw.ag_roll_id)
        JOIN ven_ag_roll_header arh
          ON (arh.ag_roll_header_id = ar.ag_roll_header_id AND arh.ag_category_agent_id = 3 AND
             arh.ag_roll_type_id = 53)
       WHERE ar.num = (SELECT MAX(ar1.num) over(PARTITION BY ar1.ag_roll_header_id)
                         FROM ven_ag_roll ar1
                        WHERE ar1.ag_roll_header_id = ar.ag_roll_header_id)
         AND apw.ag_contract_header_id = nvl(p_ag_contract_header_id, apw.ag_contract_header_id)
         AND apw.status_id = 205
         AND arh.date_begin <= last_day(c_date)
         AND NOT EXISTS
       (SELECT '1'
                FROM ven_ag_perfomed_work_act apw1
                JOIN ven_ag_roll ar1
                  ON (ar1.ag_roll_id = apw1.ag_roll_id)
                JOIN ven_ag_roll_header arh1
                  ON (arh1.ag_roll_header_id = ar1.ag_roll_header_id AND arh1.ag_category_agent_id = 3 AND
                     arh1.ag_roll_type_id = 53)
               WHERE ar1.num = (SELECT MAX(ar2.num) over(PARTITION BY ar2.ag_roll_header_id)
                                  FROM ven_ag_roll ar2
                                 WHERE ar2.ag_roll_header_id = ar1.ag_roll_header_id)
                 AND apw1.ag_contract_header_id = apw.ag_contract_header_id
                 AND apw1.status_id <> 205
                 AND arh1.date_begin > arh.date_begin
                 AND arh1.date_begin <= last_day(c_date)));
  
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date    DATE;
    p_cur_m   cur_m%ROWTYPE;
    v_rec_det ven_ag_perfom_work_det%ROWTYPE;
    v_rec_act ven_ag_perfomed_work_act%ROWTYPE;
  
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_m(v_date);
    FETCH cur_m
      INTO p_cur_m.ag_contract_header_id
          ,p_cur_m.sgp
          ,p_cur_m.plan_s;
    IF (cur_m%NOTFOUND)
    THEN
      CLOSE cur_m;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('OVER_YEAR_PLAN_TD');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF (p_cur_m.plan_s > p_cur_m.sgp)
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := pkg_ag_calc_admin.get_bonus(1
                                                   ,205
                                                   ,100 *
                                                    ((p_cur_m.sgp - p_cur_m.plan_s) / p_cur_m.sgp));
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
  
  END;

  PROCEDURE rd_over_year_calc
  (
    p_ag_roll_id              IN NUMBER
   ,p_ag_contract_header_id   IN NUMBER
   ,p_ag_perfomed_work_act_id IN NUMBER
  ) IS
    CURSOR cur_date IS(
      SELECT arh.date_end
        FROM ag_roll r
        JOIN ag_roll_header arh
          ON (arh.ag_roll_header_id = r.ag_roll_header_id AND r.ag_roll_id = p_ag_roll_id));
    CURSOR cur_m(c_date DATE) IS(
      SELECT apw.ag_contract_header_id
            ,(SUM(apw.sgp1) over(PARTITION BY apw.ag_contract_header_id)) sgp
            ,((SUM(1) over(PARTITION BY apw.ag_contract_header_id)) * 3000000 *
             (SELECT COUNT(1)
                 FROM ag_contract_header aa
                WHERE pkg_agent_sub.Get_Leader_Id_By_Date(last_day(c_date)
                                                         ,aa.ag_contract_header_id
                                                         ,last_day(c_date)) = p_ag_contract_header_id
                  AND pkg_ag_sgp.get_status(last_day(c_date), aa.ag_contract_header_id) = 205)) plan_s
        FROM ven_ag_perfomed_work_act apw
        JOIN ven_ag_roll ar
          ON (ar.ag_roll_id = apw.ag_roll_id)
        JOIN ven_ag_roll_header arh
          ON (arh.ag_roll_header_id = ar.ag_roll_header_id AND arh.ag_category_agent_id = 3 AND
             arh.ag_roll_type_id = 53)
       WHERE ar.num = (SELECT MAX(ar1.num) over(PARTITION BY ar1.ag_roll_header_id)
                         FROM ven_ag_roll ar1
                        WHERE ar1.ag_roll_header_id = ar.ag_roll_header_id)
         AND apw.ag_contract_header_id = nvl(p_ag_contract_header_id, apw.ag_contract_header_id)
         AND apw.status_id = 206
         AND arh.date_begin <= last_day(c_date)
         AND NOT EXISTS
       (SELECT '1'
                FROM ven_ag_perfomed_work_act apw1
                JOIN ven_ag_roll ar1
                  ON (ar1.ag_roll_id = apw1.ag_roll_id)
                JOIN ven_ag_roll_header arh1
                  ON (arh1.ag_roll_header_id = ar1.ag_roll_header_id AND arh1.ag_category_agent_id = 3 AND
                     arh1.ag_roll_type_id = 53)
               WHERE ar1.num = (SELECT MAX(ar2.num) over(PARTITION BY ar2.ag_roll_header_id)
                                  FROM ven_ag_roll ar2
                                 WHERE ar2.ag_roll_header_id = ar1.ag_roll_header_id)
                 AND apw1.ag_contract_header_id = apw.ag_contract_header_id
                 AND apw1.status_id <> 206
                 AND arh1.date_begin > arh.date_begin
                 AND arh1.date_begin <= last_day(c_date)));
    CURSOR get_asum(ca_id NUMBER) IS(
      SELECT SUM(d.summ) FROM ven_ag_perfom_work_det d WHERE d.ag_perfomed_work_act_id = ca_id);
  
    v_date    DATE;
    p_cur_m   cur_m%ROWTYPE;
    v_rec_det ven_ag_perfom_work_det%ROWTYPE;
    v_rec_act ven_ag_perfomed_work_act%ROWTYPE;
  
  BEGIN
  
    OPEN cur_date;
    FETCH cur_date
      INTO v_date;
    IF (cur_date%NOTFOUND)
    THEN
      CLOSE cur_date;
    END IF;
    CLOSE cur_date;
  
    OPEN cur_m(v_date);
    FETCH cur_m
      INTO p_cur_m.ag_contract_header_id
          ,p_cur_m.sgp
          ,p_cur_m.plan_s;
    IF (cur_m%NOTFOUND)
    THEN
      CLOSE cur_m;
    END IF;
  
    v_rec_det.ag_rate_type_id         := pkg_ag_act_calc.get_ag_rate_type_id('OVER_YEAR_PLAN_RD');
    v_rec_det.ag_perfomed_work_act_id := p_ag_perfomed_work_act_id;
  
    IF (p_cur_m.plan_s > p_cur_m.sgp)
    THEN
      v_rec_det.summ := 0;
      pkg_ag_act_calc.insert_ag_perf_det(v_rec_det);
    ELSE
      v_rec_det.summ := pkg_ag_calc_admin.get_bonus(1
                                                   ,206
                                                   ,100 *
                                                    ((p_cur_m.sgp - p_cur_m.plan_s) / p_cur_m.sgp));
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
  END;

END pkg_ag_dir_calc;
/

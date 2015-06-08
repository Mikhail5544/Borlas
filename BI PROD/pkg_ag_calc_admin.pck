CREATE OR REPLACE PACKAGE pkg_ag_calc_admin IS

  /*TYPE t_plan IS RECORD (SGP_amount NUMBER,
  cnt        pls_integer);*/
  -- Author  : DKOLGANOV
  -- Created : 30.05.2008 12:52:05
  -- Purpose : пакет администрирования расчетов

  PROCEDURE startcalculationroll(p_id NUMBER);
  PROCEDURE startcalculationact(p_id NUMBER);
  PROCEDURE delete_act_job(p_ag_roll_id NUMBER);
  PROCEDURE delete_perf_work_act
  (
    par_roll_id             NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  );
  PROCEDURE delete_act_banks(par_roll_id ag_roll.ag_roll_id%TYPE);
  PROCEDURE delete_act_rlp
  (
    par_roll_id             NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  );
  PROCEDURE delete_ag_roll(p_ag_roll_id PLS_INTEGER);

  /**
  *  определение разницы между суммами к выплате
  *  в акте выполненных работ у одного агента
  *  в текущей версии ведомости по сравнению
  *  с предыдущей 
  *  
  * @author Колганов Дмитрий
  * @param p_ag_roll_id ид версии ведомости
  * @param p_ag_contract_header_id ид агентсокго договора
  */
  FUNCTION get_delta
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_sum                   IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_payed_amount(p_ag_perf_work_det_id PLS_INTEGER) RETURN NUMBER;

  FUNCTION get_payed_rate
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER;

  FUNCTION get_premium_amount
  (
    p_premium_id   NUMBER
   ,p_ag_status_id NUMBER
   ,p_date         DATE
  ) RETURN NUMBER;

  FUNCTION get_plan_0510
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_plan_type             PLS_INTEGER
   ,p_date                  DATE
  ) RETURN NUMBER;

  FUNCTION get_plan
  (
    p_month_num             IN NUMBER
   ,p_status_id             IN NUMBER
   ,p_date                  IN DATE
   ,p_ag_contract_header_id PLS_INTEGER DEFAULT NULL
   ,p_return                PLS_INTEGER DEFAULT 1
  ) RETURN t_agent_plan;

  FUNCTION get_individual_plan
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_return                PLS_INTEGER DEFAULT 1
  ) RETURN t_agent_plan;

  FUNCTION get_plan_old
  (
    p_month_num IN NUMBER
   ,p_status_id IN NUMBER
   ,p_date      IN DATE
  ) RETURN NUMBER;
  FUNCTION get_operation_months
  (
    p_date_begin DATE
   ,p_date_end   DATE
  ) RETURN NUMBER;
  FUNCTION get_opertation_month_date
  (
    p_date         DATE
   ,p_return       PLS_INTEGER
   ,p_months_shift PLS_INTEGER DEFAULT 0
  ) RETURN DATE;

  FUNCTION get_cat_o_months
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_category              PLS_INTEGER
  ) RETURN NUMBER;

  FUNCTION get_cat_date
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_category              PLS_INTEGER
   ,p_search_dir            PLS_INTEGER DEFAULT 1
   ,p_look_old              PLS_INTEGER DEFAULT 0
  ) RETURN DATE;

  FUNCTION get_months
  (
    p_ag_contract_header_id IN NUMBER
   ,p_date                  IN DATE
   ,p_category_id           IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_date_cat
  (
    p_ag_contract_header_id IN NUMBER
   ,p_date                  IN DATE
   ,p_category_id           IN NUMBER
  ) RETURN DATE;

  FUNCTION get_bonus
  (
    p_month_num IN NUMBER
   ,p_status_id IN NUMBER
   ,p_percent   IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_ag_status_id_by_brief(par_brief VARCHAR2) RETURN NUMBER;

  FUNCTION get_ag_category_id(par_ag_status_id NUMBER) RETURN NUMBER;

  FUNCTION ag_status_check
  (
    p_pol_header IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER;
  FUNCTION get_payed_rate_amount
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER;
  FUNCTION get_holiday_day(p_input_date DATE) RETURN DATE;

  /*Веселуха Е.В.
    11.09.2013
    Размазка для RLP по АВНадо
  */
  PROCEDURE startrecalcroll(p_id NUMBER);
  /*Веселуха Е.В.
    18.09.2013
    Получает сумму начисленного АВ из предыдущих расчетных ведомостей по договору страхования
  */
  FUNCTION get_rlp_amount
  (
    par_pol_header_id         NUMBER
   ,par_roll_id               NUMBER
   ,par_ag_contract_header_id NUMBER
  ) RETURN NUMBER;

END pkg_ag_calc_admin;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_calc_admin IS

  PROCEDURE startcalculationroll(p_id NUMBER) IS
    agent_package_name ven_ag_category_agent.package_name%TYPE;
    sql_exec           VARCHAR2(255);
  
    --job_runs PLS_INTEGER;
  
    CURSOR cur(cv_roll_id NUMBER) IS
      SELECT art.calc_pkg
            ,art.brief
        FROM ag_roll        agr
            ,ag_roll_header agrh
            ,ag_roll_type   art
       WHERE agr.ag_roll_id = cv_roll_id
         AND agrh.ag_roll_header_id = agr.ag_roll_header_id
         AND agrh.ag_roll_type_id = art.ag_roll_type_id
         AND nvl(art.enabled, 1) = 1;
  
    rec cur%ROWTYPE;
  BEGIN
  
    OPEN cur(p_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN;
    END IF;
  
    CLOSE cur;
  
    agent_package_name := rec.calc_pkg;
  
    sql_exec := 'PKG_AGENT_CALCULATOR.AG_ROLL_ID := ' || p_id || '; ' ||
                'PKG_AGENT_CALCULATOR.AgentPackageName := ''' || agent_package_name || '''; ' ||
                'PKG_AGENT_CALCULATOR.Calculate;';
  
    UPDATE ven_ag_roll ar
       SET ar.note = 'Ведомость поставлена в очередь на расчет ' ||
                     to_char(SYSDATE, 'DD.MM.YYYY HH24:Mi:SS')
     WHERE ar.ag_roll_id = p_id;
  
    pkg_scheduler.run_scheduled('COMISS_CALC', sql_exec, 0);
  
    /*    SELECT COUNT(*)
      INTO job_runs
      FROM dba_scheduler_running_jobs dj
     WHERE dj.job_name LIKE rec.brief||'%';
    
    SYS.Dbms_Scheduler.create_job(job_name => 'CALC_'||rec.brief||'_'||job_runs,
                                  job_type => 'PLSQL_BLOCK',
                                  job_action => sql_exec,
                                  comments => 'Рассчет ведомости АВ',
                                  enabled => TRUE);*/
  
  END startcalculationroll;

  /*Веселуха Е.В.
    11.09.2013
    Размазка для RLP по АВНадо
  */
  PROCEDURE startrecalcroll(p_id NUMBER) IS
    agent_package_name ven_ag_category_agent.package_name%TYPE;
    sql_exec           VARCHAR2(255);
  BEGIN
  
    agent_package_name := 'pkg_commission_calc';
  
    sql_exec := 'PKG_AGENT_CALCULATOR.AG_ROLL_ID := ' || p_id || '; ' ||
                'PKG_AGENT_CALCULATOR.AgentPackageName := ''' || agent_package_name || '''; ' ||
                'PKG_AGENT_CALCULATOR.Calculate;';
  
    UPDATE ven_ag_roll ar
       SET ar.note = 'Ведомость поставлена в очередь на пересчет ' ||
                     to_char(SYSDATE, 'DD.MM.YYYY HH24:Mi:SS')
     WHERE ar.ag_roll_id = p_id;
  
    pkg_scheduler.run_scheduled('COMISS_CALC', sql_exec, 0);
  
  END startrecalcroll;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 24.11.2009 13:38:53
  -- Purpose : Удаление ведомости
  PROCEDURE delete_ag_roll(p_ag_roll_id PLS_INTEGER) IS
    proc_name VARCHAR2(20) := 'delete_ag_roll';
  BEGIN
  
    DELETE FROM ven_ag_roll WHERE ag_roll_id = p_ag_roll_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END delete_ag_roll;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.04.2009 18:35:18
  -- Purpose : Джоб для удаления актов 
  PROCEDURE delete_act_job(p_ag_roll_id NUMBER) IS
    proc_name VARCHAR2(20) := 'delete_act_job';
    job_runs  PLS_INTEGER;
    sql_exec  VARCHAR2(500);
  BEGIN
    sql_exec := 'pkg_agent_calculator.AG_ROLL_ID:=' || p_ag_roll_id || ';' ||
                'pkg_agent_calculator.ClearMessage;' ||
                'pkg_agent_calculator.InsertInfo('' Подождите идет удаление "старых" актов'');' ||
                'PKG_AG_CALC_ADMIN.delete_perf_work_act(' || p_ag_roll_id || ');' ||
                'PKG_AG_CALC_ADMIN.delete_act_rlp(' || p_ag_roll_id || ');' ||
                'PKG_AG_CALC_ADMIN.delete_act_banks(' || p_ag_roll_id || ');' ||
                'pkg_agent_calculator.InsertInfo(''Ведомость успешно очищена'');' ||
                'DOC.SET_DOC_STATUS(' || p_ag_roll_id ||
                ',''NEW'',SYSDATE,''AUTO'',''Ведомость переведена в статус Новый'');';
  
    SELECT COUNT(*) INTO job_runs FROM dba_scheduler_running_jobs dj WHERE dj.job_name LIKE 'DELETE%';
  
    sys.dbms_scheduler.create_job(job_name   => 'DELETE_' || job_runs
                                 ,job_type   => 'PLSQL_BLOCK'
                                 ,job_action => sql_exec
                                 ,comments   => 'Удаление актов в ведомости'
                                 ,enabled    => TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM || chr(10));
  END delete_act_job;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.04.2009 18:01:00
  -- Purpose : Удаляет акты по id ведомости
  PROCEDURE delete_perf_work_act
  (
    par_roll_id             NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  ) IS
    proc_name VARCHAR2(25) := 'delete_perf_work_act';
  BEGIN
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      DELETE FROM document d
       WHERE d.document_id IN
             (SELECT ag_perfomed_work_act_id
                FROM ag_perfomed_work_act
               WHERE ag_roll_id = par_roll_id
                 AND ag_contract_header_id = p_ag_contract_header_id);
    ELSE
      DELETE FROM document d
       WHERE d.document_id IN
             (SELECT ag_perfomed_work_act_id FROM ag_perfomed_work_act WHERE ag_roll_id = par_roll_id);
    END IF;
  
    DELETE FROM ag_volume agv WHERE agv.ag_roll_id = par_roll_id;
  
    UPDATE ins.ag_contract_header agh
       SET (agh.personal_units, agh.structural_units, agh.common_units) =
           (SELECT nvl(agu.personal_units, nvl(agh.personal_units, 0))
                  ,nvl(agu.structural_units, nvl(agh.structural_units, 0))
                  ,nvl(agu.personal_units, nvl(agh.personal_units, 0)) +
                   nvl(agu.structural_units, nvl(agh.structural_units, 0))
              FROM ins.ag_roll_units agu
             WHERE agu.ag_roll_id = par_roll_id
               AND agu.ag_contract_header_id = agh.ag_contract_header_id)
     WHERE EXISTS (SELECT NULL
              FROM ins.ag_roll_units au
             WHERE au.ag_roll_id = par_roll_id
               AND au.ag_contract_header_id = agh.ag_contract_header_id);
    DELETE FROM ins.ag_roll_units agu WHERE agu.ag_roll_id = par_roll_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_err_m VARCHAR2(2000) := SQLERRM;
      BEGIN
        IF p_ag_contract_header_id IS NULL
        THEN
          doc.set_doc_status(par_roll_id, 'ERROR_CALCULATE');
          UPDATE ven_ag_roll ar
             SET ar.note = 'Ошибка при очистке ведомости ' || v_err_m
           WHERE ar.ag_roll_id = par_roll_id;
          COMMIT;
        ELSE
          raise_application_error(-20001
                                 ,'Ошибка при выполнении ' || proc_name || v_err_m || chr(10));
        END IF;
      END;
  END delete_perf_work_act;

  PROCEDURE delete_act_banks(par_roll_id ag_roll.ag_roll_id%TYPE) IS
  BEGIN
    DELETE FROM ag_perfomed_work_act wa WHERE wa.ag_roll_id = par_roll_id;
  
    DELETE FROM ag_volume_bank vb WHERE vb.ag_roll_id = par_roll_id;
  
    DELETE FROM ag_volume_bank_deduction vb WHERE vb.ag_roll_id = par_roll_id;
  END delete_act_banks;

  PROCEDURE delete_act_rlp
  (
    par_roll_id             NUMBER
   ,p_ag_contract_header_id NUMBER DEFAULT NULL
  ) IS
    proc_name VARCHAR2(25) := 'delete_act_rlp';
  BEGIN
    DELETE FROM ven_ag_act_rlp
     WHERE ag_roll_id = par_roll_id
       AND (ag_contract_header_id = p_ag_contract_header_id OR p_ag_contract_header_id IS NULL);
  
    DELETE FROM ven_ag_volume_rlp agv WHERE agv.ag_roll_id = par_roll_id;
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        v_err_m VARCHAR2(2000) := SQLERRM;
      BEGIN
        IF p_ag_contract_header_id IS NULL
        THEN
          doc.set_doc_status(par_roll_id, 'ERROR_CALCULATE');
          UPDATE ven_ag_roll ar
             SET ar.note = 'Ошибка при очистке ведомости ' || v_err_m
           WHERE ar.ag_roll_id = par_roll_id;
          COMMIT;
        ELSE
          raise_application_error(-20001
                                 ,'Ошибка при выполнении ' || proc_name || v_err_m || chr(10));
        END IF;
      END;
  END delete_act_rlp;

  FUNCTION get_delta
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_sum                   IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_vers NUMBER;
    v_sum  NUMBER;
    CURSOR def_vers IS(
      SELECT ar.num FROM ven_ag_roll ar WHERE ar.ag_roll_id = p_ag_roll_id);
  
    CURSOR get_sum(c_vers NUMBER) IS(
      SELECT apw.sum
        FROM ag_perfomed_work_act apw
       WHERE apw.ag_contract_header_id = p_ag_contract_header_id
         AND apw.ag_roll_id =
             (SELECT ar.ag_roll_id
                FROM ven_ag_roll ar
               WHERE ar.ag_roll_header_id =
                     (SELECT a.ag_roll_header_id FROM ven_ag_roll a WHERE a.ag_roll_id = p_ag_roll_id)
                 AND ar.num = c_vers - 1));
  BEGIN
    OPEN def_vers;
    FETCH def_vers
      INTO v_vers;
    IF (def_vers%NOTFOUND)
       OR (v_vers = 0)
    THEN
      CLOSE def_vers;
      RETURN 0;
    END IF;
  
    CLOSE def_vers;
  
    OPEN get_sum(v_vers);
  
    FETCH get_sum
      INTO v_sum;
  
    IF (get_sum%NOTFOUND)
    THEN
      CLOSE get_sum;
      RETURN 0;
    END IF;
  
    CLOSE get_sum;
    RESULT := p_sum - v_sum;
    RETURN RESULT;
  
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 19.06.2009 16:24:41
  -- Purpose : Получает сумму заплаченную по даному типу премии в этом отчетном периоде
  -- аналог функции get_delta
  FUNCTION get_payed_amount(p_ag_perf_work_det_id PLS_INTEGER) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'Get_payed_amount';
  BEGIN
  
    /*SELECT nvl(sum(apd.summ),0)
     INTO Result
     FROM ag_roll ar,
          ag_perfomed_work_act apw,
          ag_perfom_work_det apd,
          ag_perfomed_work_act apw2,
          ag_perfom_work_det apd2
    WHERE ar.ag_roll_id = apw.ag_roll_id
      AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
      AND apw.ag_contract_header_id = apw2.ag_contract_header_id
      AND apd.ag_rate_type_id = apd2.ag_rate_type_id
      AND apd2.ag_perfomed_work_act_id = apw2.ag_perfomed_work_act_id
      AND apd2.ag_perfom_work_det_id = p_ag_perf_work_det_id;*/
  
    SELECT nvl(SUM(apd.summ), 0)
      INTO RESULT
      FROM ag_roll              ar
          ,ag_perfomed_work_act apw
          ,ag_perfom_work_det   apd
          ,ag_roll              ar2
          ,ag_perfomed_work_act apw2
          ,ag_perfom_work_det   apd2
     WHERE ar.ag_roll_id = apw.ag_roll_id
       AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
       AND ar.ag_roll_header_id = ar2.ag_roll_header_id
       AND ar2.ag_roll_id = apw2.ag_roll_id
       AND apd2.ag_perfomed_work_act_id = apw2.ag_perfomed_work_act_id
       AND apd2.ag_perfom_work_det_id = p_ag_perf_work_det_id
       AND apw.ag_contract_header_id = apw2.ag_contract_header_id
       AND apd.ag_rate_type_id = apd2.ag_rate_type_id;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_payed_amount;
  /*Веселуха Е.В.
    18.09.2013
    Получает сумму начисленного АВ из предыдущих расчетных ведомостей по договору страхования
  */
  FUNCTION get_rlp_amount
  (
    par_pol_header_id         NUMBER
   ,par_roll_id               NUMBER
   ,par_ag_contract_header_id NUMBER
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'Get_rlp_amount';
  BEGIN
  
    SELECT nvl(SUM(nvl(vol.av_need
                      ,nvl(vol.vol_av
                          ,ins.acc.get_cross_rate_by_id(1, ph.fund_id, 122, agv.payment_date) *
                           vol.vol_amount * vol.vol_rate)))
              ,0)
      INTO RESULT
      FROM ins.ag_volume_rlp   agv
          ,ins.ag_vol_rlp      vol
          ,ins.ag_work_det_rlp det
          ,ins.p_pol_header    ph
          ,ins.ag_roll         ar
          ,ins.ag_act_rlp      act
     WHERE agv.policy_header_id = par_pol_header_id
       AND agv.ag_volume_rlp_id = vol.ag_vol_rlp_id
       AND vol.ag_work_det_rlp_id = det.ag_work_det_rlp_id
       AND agv.policy_header_id = ph.policy_header_id
       AND det.ag_act_rlp_id = act.ag_act_rlp_id
       AND act.ag_roll_id = ar.ag_roll_id
       AND act.ag_contract_header_id = par_ag_contract_header_id
       AND ar.ag_roll_id != par_roll_id;
  
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 30.08.2010 18:06:00
  -- Purpose : Получает ставку уже оплаченного вознаграждения с данного объема
  FUNCTION get_payed_rate
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER IS
    v_sav     NUMBER;
    proc_name VARCHAR2(25) := 'Get_delta_sav';
  BEGIN
    SELECT SUM(apv.vol_rate)
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
  END get_payed_rate;

  -- Author  : Веселуха Е.В.
  -- Created : 06.03.2012 18:06:00
  -- Purpose : Получает ставку уже оплаченного вознаграждения с данного объема
  FUNCTION get_payed_rate_amount
  (
    p_roll_header_id        PLS_INTEGER
   ,p_rate_type             PLS_INTEGER
   ,p_ag_contract_header_id PLS_INTEGER
   ,p_ag_volume_id          PLS_INTEGER
  ) RETURN NUMBER IS
    v_sav     NUMBER;
    proc_name VARCHAR2(25) := 'Get_payed_rate_amount';
  BEGIN
    SELECT SUM(apv.vol_rate * apv.vol_amount)
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
  END get_payed_rate_amount;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 22.10.2010 13:14:13
  -- Purpose : Получает индивидуальный план агента, выбранного типа (мотивация  от 05,2010)
  FUNCTION get_plan_0510
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_plan_type             PLS_INTEGER
   ,p_date                  DATE
  ) RETURN NUMBER IS
    proc_name VARCHAR2(25) := 'get_plan_0510';
    v_plan    NUMBER;
  BEGIN
  
    SELECT SUM(asp.plan_value)
      INTO v_plan
      FROM ag_sale_plan asp
     WHERE asp.ag_contract_header_id = p_ag_contract_header_id
       AND asp.plan_type = p_plan_type
       AND p_date BETWEEN asp.date_begin AND asp.date_end;
  
    RETURN v_plan;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_plan_0510;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.06.2009 13:59:09
  -- Purpose : Получает план СГП для Менеджеров/Директоров
  -- Возможность настройки плана с интерфейса через справочник функицй
  -- P_ag_contract_header_id - для получения индивидуальных планов
  -- Если план не найден, будет взят обычный
  FUNCTION get_plan
  (
    p_month_num             NUMBER
   ,p_status_id             NUMBER
   ,p_date                  DATE
   ,p_ag_contract_header_id PLS_INTEGER DEFAULT NULL
   ,p_return                PLS_INTEGER DEFAULT 1
  ) RETURN t_agent_plan IS
    v_plan    t_agent_plan := t_agent_plan(NULL, NULL);
    proc_name VARCHAR2(20) := 'get_plan';
    v_attrs   pkg_tariff_calc.attr_type;
  BEGIN
    IF p_ag_contract_header_id IS NOT NULL
    THEN
      v_plan := get_individual_plan(p_ag_contract_header_id, p_date, p_return);
    END IF;
  
    IF v_plan.sgp_amount IS NOT NULL
    THEN
      RETURN(v_plan);
    END IF;
  
    v_attrs(1) := p_status_id;
    v_attrs(2) := p_month_num;
    v_attrs(3) := to_char(p_date, 'YYYYMMDD');
    v_plan.sgp_amount := nvl(pkg_tariff_calc.calc_coeff_val('SGP_premium_plan', v_attrs, 3), 999999999);
  
    RETURN(v_plan);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END get_plan;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 17.06.2009 21:02:28
  -- Purpose : Получает индивидуальный план
  -- p_return - 1 индивидуальный план на указанную дату
  -- p_return - 2 годовой индивидуальный план на операционный год в который попадает указанная дата
  FUNCTION get_individual_plan
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_return                PLS_INTEGER DEFAULT 1
  ) RETURN t_agent_plan IS
    v_plan    t_agent_plan := t_agent_plan(NULL, NULL);
    proc_name VARCHAR2(20) := 'get_individual_plan';
  BEGIN
    IF p_return = 1
    THEN
      SELECT k_sgp
            ,ag_count
        INTO v_plan.sgp_amount
            ,v_plan.policy_count
        FROM ag_plan_sale ap
       WHERE ap.ag_contract_header_id = p_ag_contract_header_id
         AND p_date BETWEEN ap.date_start AND ap.date_end;
    ELSE
      SELECT SUM(sgp)
            ,SUM(cnt)
        INTO v_plan.sgp_amount
            ,v_plan.policy_count
        FROM (SELECT last_value(k_sgp ignore NULLS) over(ORDER BY date_begin) sgp
                    ,last_value(ag_count ignore NULLS) over(ORDER BY date_begin) cnt
                FROM (SELECT m.date_begin
                            ,ap.k_sgp
                            ,ap.ag_count
                        FROM ag_plan_sale ap PARTITION BY(ap.ag_contract_header_id)
                       RIGHT OUTER JOIN (SELECT ADD_MONTHS(trunc(pkg_ag_calc_admin.get_opertation_month_date(p_date
                                                                                                           ,2)
                                                               ,'YEAR')
                                                         ,rownum - 1) date_begin
                                          FROM dual
                                        CONNECT BY LEVEL < 13) m
                          ON m.date_begin = trunc(ap.date_start, 'MONTH')
                       WHERE ap.ag_contract_header_id = p_ag_contract_header_id));
    END IF;
    RETURN(v_plan);
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN(t_agent_plan(NULL, NULL));
      -- WHEN TOO_MANY_ROWS THEN v_plan.SGP_amount:=-1; RETURN(v_plan);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || ' ' || SQLERRM);
  END get_individual_plan;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 15.06.2009 19:40:59
  -- Purpose : Получает сумму премии
  FUNCTION get_premium_amount
  (
    p_premium_id   NUMBER
   ,p_ag_status_id NUMBER
   ,p_date         DATE
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(25) := 'get_premium_amount';
    v_attrs   pkg_tariff_calc.attr_type;
  BEGIN
    v_attrs(1) := p_premium_id;
    v_attrs(2) := p_ag_status_id;
    v_attrs(3) := to_char(p_date, 'YYYYMMDD');
    RESULT := nvl(pkg_tariff_calc.calc_coeff_val('Premium_amount', v_attrs, 3), 0);
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_premium_amount;

  /*DEPRECATED*/

  FUNCTION get_plan_old
  (
    p_month_num IN NUMBER
   ,p_status_id IN NUMBER
   ,p_date      IN DATE
  ) RETURN NUMBER IS
    CURSOR cur_plan(c_year NUMBER) IS(
      SELECT MIN(apm.sgp) keep(dense_rank FIRST ORDER BY apm.nmonths ASC) AS res
        FROM ag_plan_year   apy
            ,ag_plan_status aps
            ,ag_plan_months apm
       WHERE apy.ag_plan_year_id = aps.ag_plan_year
         AND apm.ag_plan_status_id = aps.ag_plan_status_id
         AND apm.nmonths IN (p_month_num, 1000)
         AND apy.ag_plan_year_id = c_year
         AND aps.ag_stat_agent_id = p_status_id);
    v_year NUMBER;
    RESULT NUMBER;
  
  BEGIN
    SELECT extract(YEAR FROM p_date) INTO v_year FROM dual;
    OPEN cur_plan(v_year);
    FETCH cur_plan
      INTO RESULT;
    IF (cur_plan%NOTFOUND)
    THEN
      CLOSE cur_plan;
    END IF;
  
    CLOSE cur_plan;
    RETURN RESULT;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 02.07.2009 17:48:47
  -- Purpose : Возвращает количество операционных месяцев между 2мя датами
  FUNCTION get_operation_months
  (
    p_date_begin DATE
   ,p_date_end   DATE
  ) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'get_operation_months';
  BEGIN
    SELECT top2.operation_period_num - top.operation_period_num
      INTO RESULT
      FROM t_operation_period top
          ,t_operation_period top2
     WHERE p_date_begin BETWEEN top.date_begin AND top.date_end
       AND p_date_end BETWEEN top2.date_begin AND top2.date_end;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(NULL);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_operation_months;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 03.07.2009 10:29:17
  -- Purpose : Возвращает даты начала и оконочания ОМ в который попадает дата
  -- p_return - тип возвращаемой даты
  --  1 - дата начала, 2 дата окончания
  -- p_months_shift - смещение в операционных месяцах
  FUNCTION get_opertation_month_date
  (
    p_date         DATE
   ,p_return       PLS_INTEGER
   ,p_months_shift PLS_INTEGER DEFAULT 0
  ) RETURN DATE IS
    RESULT    DATE;
    proc_name VARCHAR2(30) := 'get_opertation_month_date';
  BEGIN
    SELECT CASE p_return
             WHEN 1 THEN
              top.date_begin
             WHEN 2 THEN
              top.date_end
             ELSE
              NULL
           END
      INTO RESULT
      FROM t_operation_period top
     WHERE (trunc(p_date, 'DD') BETWEEN top.date_begin AND top.date_end AND p_months_shift = 0)
        OR top.operation_period_num =
           (SELECT top2.operation_period_num
              FROM t_operation_period top2
             WHERE trunc(p_date, 'DD') BETWEEN top2.date_begin AND top2.date_end) + p_months_shift;
    RETURN(RESULT);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_opertation_month_date;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 27.07.2009 14:02:54
  -- Purpose : Возвращает количество операционных месяцев отработанных в указанной категории
  FUNCTION get_cat_o_months
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_category              PLS_INTEGER
  ) RETURN NUMBER IS
    month_num NUMBER;
    proc_name VARCHAR2(20) := 'get_cat_o_months';
  BEGIN
    SELECT SUM(decode(sign(om), -1, 0, om))
      INTO month_num
      FROM (SELECT pkg_ag_calc_admin.get_operation_months(CASE
                                                            WHEN lag(oper_next_d, 1, '01.01.1900') over(ORDER BY num) > oper_begin THEN
                                                             pkg_ag_calc_admin.get_opertation_month_date(oper_begin, 2) + 1
                                                            ELSE
                                                             oper_begin
                                                          END
                                                         ,oper_next_d) om
              FROM (SELECT pkg_ag_calc_admin.get_opertation_month_date(trunc(t.date_begin, 'DD'), 1) oper_begin
                          ,least(lead(pkg_ag_calc_admin.get_opertation_month_date(trunc(t.date_begin
                                                                                       ,'DD')
                                                                                 ,2)
                                     ,1
                                     ,pkg_ag_calc_admin.get_opertation_month_date(p_date, 2))
                                 over(ORDER BY to_number(t.num))
                                ,p_date) oper_next_d
                          ,t.category_id
                          ,to_number(num) num
                      FROM ven_ag_contract t
                     WHERE t.contract_id = p_ag_contract_header_id) a
             WHERE a.category_id = p_category) a;
    RETURN(month_num);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_cat_o_months;

  FUNCTION get_holiday_day(p_input_date DATE) RETURN DATE IS
    v_data_day DATE;
  BEGIN
  
    SELECT nvl(MIN(c.t_data_day), p_input_date)
      INTO v_data_day
      FROM ins.t_calendar_holiday c
     WHERE c.t_data_day >= p_input_date
       AND decode(c.t_type_day
                 ,'Суббота'
                 ,0
                 ,'Воскресенье'
                 ,0
                 ,'Праздник'
                 ,0
                 ,1) = 1;
  
    /*v_input_date := p_input_date;
    
    WHILE v_type_day <> 1
    LOOP
     SELECT DECODE(ct.t_type_day,'Суббота',0,
                                 'Воскресенье',0,
                                 'Праздник',0,
                                 1) t_type_day, ct.t_data_day
     INTO v_type_day, v_data_day
     FROM insi.T_CALENDAR_HOLIDAY ct
     WHERE ct.t_data_day = v_input_date;
    
     v_input_date := v_input_date + 1;
    END LOOP;*/
  
    RETURN v_data_day;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 25.08.2010 19:46:29
  -- Purpose : Возвращает дату начала категории в которой непрерывно проработал агент
  -- до указанной даты
  -- p_search_dir - направление поиска 1 - назд от указанной даты; n - вперед;
  -- p_look_old - поиск даты в старом модуле 1 - да; n - нет;
  FUNCTION get_cat_date
  (
    p_ag_contract_header_id PLS_INTEGER
   ,p_date                  DATE
   ,p_category              PLS_INTEGER
   ,p_search_dir            PLS_INTEGER DEFAULT 1
   ,p_look_old              PLS_INTEGER DEFAULT 0
  ) RETURN DATE IS
    v_cat_date DATE DEFAULT NULL;
    proc_name  VARCHAR2(25) := 'get_cat_begin';
    v_cat      PLS_INTEGER;
    v_old_cat  DATE DEFAULT NULL;
  BEGIN
  
    IF p_category = 20
    THEN
      v_cat := 4;
    ELSE
      v_cat := p_category;
    END IF;
  
    IF p_search_dir = 1
    THEN
      FOR r IN (SELECT ac.ag_contract_id
                      ,ac.date_begin
                      ,decode(ac.category_id, 20, 4, ac.category_id) category_id
                      ,1
                  FROM ven_ag_contract ac
                 WHERE ac.contract_id = p_ag_contract_header_id
                   AND ac.date_begin < p_date
                UNION ALL
                SELECT ash.ag_stat_hist_id
                      ,ash.stat_date
                      ,decode(ash.ag_stat_agent_id, 213, 50, ash.ag_category_agent_id)
                      ,2
                  FROM ins.ag_stat_hist ash
                 WHERE ash.ag_contract_header_id = p_ag_contract_header_id
                 ORDER BY 4 DESC
                         ,2 DESC
                         ,1 DESC
                
                /*    SELECT ac.date_begin, 
                      decode(ac.category_id, 20, 4, ac.category_id) category_id
                 FROM ven_ag_contract ac
                WHERE ac.contract_id = p_ag_contract_header_id
                  AND ac.date_begin < p_date
                ORDER BY ac.date_begin DESC, ac.num DESC*/
                )
      LOOP
      
        IF r.category_id <> v_cat
        THEN
          RETURN(v_cat_date);
        END IF;
      
        v_cat_date := r.date_begin;
      
      END LOOP;
    
      IF p_look_old = 1
      THEN
        FOR old_ac IN (SELECT apd.ag_prev_header_id
                         FROM ag_prev_dog apd
                        WHERE apd.ag_contract_header_id = p_ag_contract_header_id
                          AND apd.company = 'Реннесанс Жизнь')
        LOOP
          v_old_cat := nvl(get_cat_date(old_ac.ag_prev_header_id
                                       ,v_cat_date
                                       ,p_category
                                       ,p_search_dir
                                       ,1)
                          ,v_cat_date);
        
          IF v_cat_date > v_old_cat
          THEN
            v_cat_date := v_old_cat;
          END IF;
        END LOOP;
        RETURN(v_cat_date);
      ELSE
        RETURN(v_cat_date);
      END IF;
    
    ELSE
      FOR r IN (SELECT ac.date_begin
                      ,decode(ac.category_id, 20, 4, ac.category_id) category_id
                      ,ach.is_new
                      ,ac.date_end
                      ,lead(ac.date_begin, 1, SYSDATE) over(ORDER BY ac.date_begin, ac.num) next_begin
                  FROM ven_ag_contract    ac
                      ,ag_contract_header ach
                 WHERE ac.contract_id = p_ag_contract_header_id
                   AND ac.contract_id = ach.ag_contract_header_id
                   AND ac.date_begin >=
                       (SELECT ac1.date_begin
                          FROM ag_contract ac1
                         WHERE ac1.ag_contract_id =
                               pkg_agent_1.get_status_by_date(p_ag_contract_header_id, p_date))
                   AND ac.num >=
                       (SELECT ac1.num
                          FROM ven_ag_contract ac1
                         WHERE ac1.ag_contract_id =
                               pkg_agent_1.get_status_by_date(p_ag_contract_header_id, p_date))
                 ORDER BY ac.date_begin
                         ,ac.num)
      LOOP
      
        IF r.category_id <> v_cat
        THEN
          RETURN(v_cat_date);
        ELSE
          IF r.is_new = 1
          THEN
            v_cat_date := r.date_end;
          ELSE
            v_cat_date := r.next_begin - 1 / 24 / 3600;
          END IF;
        END IF;
      
      END LOOP;
    
      RETURN(v_cat_date);
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_cat_date;

  FUNCTION get_months
  (
    p_ag_contract_header_id IN NUMBER
   ,p_date                  IN DATE
   ,p_category_id           IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_date DATE;
    CURSOR cur_mon IS(
      SELECT MIN(an.date_begin)
        FROM ven_ag_contract an
       WHERE an.date_begin < p_date
         AND an.contract_id = p_ag_contract_header_id
         AND an.category_id = p_category_id
         AND EXISTS (SELECT '1'
                FROM ag_contract ag
               WHERE ag.category_id <> p_category_id
                 AND ag.date_begin <= p_date
                 AND ag.date_begin >= an.date_begin));
  BEGIN
    OPEN cur_mon;
    FETCH cur_mon
      INTO v_date;
    IF (cur_mon%NOTFOUND)
    THEN
      CLOSE cur_mon;
      RETURN NULL;
    END IF;
    CLOSE cur_mon;
    RESULT := CEIL(MONTHS_BETWEEN(p_date + 1, v_date));
    RETURN RESULT;
  END;

  /*DEPRICATED!!! Use get_cat_date instead*/
  FUNCTION get_date_cat
  (
    p_ag_contract_header_id IN NUMBER
   ,p_date                  IN DATE
   ,p_category_id           IN NUMBER
  ) RETURN DATE IS
    RESULT DATE;
    v_date DATE;
    CURSOR cur_mon IS(
      SELECT MIN(an.date_begin)
        FROM ven_ag_contract an
       WHERE an.date_begin < p_date
         AND an.contract_id = p_ag_contract_header_id
         AND an.category_id = p_category_id
         AND EXISTS (SELECT '1'
                FROM ag_contract ag
               WHERE ag.category_id <> p_category_id
                 AND ag.date_begin <= p_date
                 AND ag.date_begin >= an.date_begin));
  BEGIN
  
    RETURN(get_cat_date(p_ag_contract_header_id, p_date, p_category_id));
  
    OPEN cur_mon;
    FETCH cur_mon
      INTO v_date;
    IF (cur_mon%NOTFOUND)
    THEN
      CLOSE cur_mon;
      RETURN NULL;
    END IF;
    CLOSE cur_mon;
    RESULT := v_date;
    RETURN RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, SQLERRM);
  END;

  --Каткевич А.Г. 18/11/2008 Переписал функцию
  FUNCTION get_bonus
  (
    p_month_num IN NUMBER
   ,p_status_id IN NUMBER
   ,p_percent   IN NUMBER
  ) RETURN NUMBER IS
    /*    cursor cur_bonus is(
    select t.bonus
      from ag_plan_calc t
      join ag_plan_months m on (m.ag_plan_months_id = t.ag_plan_months_id and
                               m.nmonths in
                               (select min(m1.nmonths) KEEP(DENSE_RANK first ORDER BY m1.nmonths ASC)
                                   from ag_plan_months m1
                                  where m1.nmonths in (p_month_num, 1000)) and
                               t.pmin <= p_percent and pmax >= p_percent)
      join ag_plan_status aps on (m.ag_plan_status_id =
                                 aps.ag_plan_status_id and
                                 aps.ag_stat_agent_id = p_status_id));*/
    res NUMBER;
  BEGIN
  
    SELECT t.bonus
      INTO res
      FROM ag_plan_calc t
     WHERE t.ag_plan_months_id IN (SELECT ag_plan_months_id
                                     FROM (SELECT *
                                             FROM ag_plan_months m
                                                 ,ag_plan_status aps
                                            WHERE m.ag_plan_status_id = aps.ag_plan_status_id
                                              AND aps.ag_stat_agent_id = p_status_id
                                              AND m.nmonths >= p_month_num
                                            ORDER BY m.nmonths)
                                    WHERE rownum = 1)
       AND t.pmin <= p_percent
       AND t.pmax >= p_percent;
  
    /* open cur_bonus;
    fetch cur_bonus
      into res;
    
    if (cur_bonus%notfound) then
      close cur_bonus;
      return 0;
    end if;
    
    close cur_bonus;*/
    RETURN(res);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
  END get_bonus;

  PROCEDURE startcalculationact(p_id NUMBER) AS
  
    agent_package_name VARCHAR2(32);
  
    CURSOR cur(cv_roll_id NUMBER) IS
      SELECT agca.*
        FROM ag_roll           agr
            ,ag_roll_header    agrh
            ,ag_category_agent agca
       WHERE agr.ag_roll_id = cv_roll_id
         AND agrh.ag_roll_header_id = agr.ag_roll_header_id
         AND agca.ag_category_agent_id = agrh.ag_category_agent_id;
  
    var_ven_ag_perfomed_work_act ven_ag_perfomed_work_act%ROWTYPE := pkg_ag_perfomed_work_act.getagperfomedworkact(p_id);
  
    rec cur%ROWTYPE;
  
  BEGIN
  
    OPEN cur(var_ven_ag_perfomed_work_act.ag_roll_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN;
    END IF;
  
    CLOSE cur;
  
    agent_package_name := rec.package_name;
  
    EXECUTE IMMEDIATE 'BEGIN ' || agent_package_name ||
                      '.calc(:p_ag_roll_id,:p_ag_contract_header_id); END;'
      USING IN var_ven_ag_perfomed_work_act.ag_roll_id, IN var_ven_ag_perfomed_work_act.ag_contract_header_id;
  END;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.08.2008 15:49:00
  -- Purpose : Возвращает Id статуса агента по его описанию brief
  -- Если статус не найден возвращает -1
  FUNCTION get_ag_status_id_by_brief(par_brief VARCHAR2) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'get_ag_status_id_by_brief';
  BEGIN
    SELECT ags.ag_stat_agent_id
      INTO RESULT
      FROM ag_stat_agent ags
     WHERE upper(ags.brief) = upper(par_brief);
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(-1);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_ag_status_id_by_brief;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 06.08.2008 16:24:26
  -- Purpose : Возвращает ID категории агента по Id статуса
  -- Если категория не найдена возвращает -1
  FUNCTION get_ag_category_id(par_ag_status_id NUMBER) RETURN NUMBER IS
    RESULT    NUMBER;
    proc_name VARCHAR2(20) := 'Get_ag_category_id';
  BEGIN
    SELECT ags.ag_category_agent_id
      INTO RESULT
      FROM ag_stat_agent ags
     WHERE ags.ag_stat_agent_id = par_ag_status_id;
    RETURN(RESULT);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(-1);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Ошибка при выполнении ' || proc_name);
  END get_ag_category_id;

  FUNCTION ag_status_check
  (
    p_pol_header IN NUMBER
   ,p_date       IN DATE
  ) RETURN NUMBER IS
    CURSOR ch IS(
      SELECT t1.ag_contract_header_id
        FROM (SELECT pa1.date_start
                    ,pa1.ag_contract_header_id
                FROM p_policy_agent pa1
               WHERE pa1.policy_header_id = p_pol_header
                 AND pa1.date_start < p_date
               ORDER BY pa1.date_start DESC) t1
       WHERE rownum = 1);
    v_ach_id NUMBER;
  
  BEGIN
    OPEN ch;
    FETCH ch
      INTO v_ach_id;
    IF (ch%NOTFOUND)
    THEN
      CLOSE ch;
      SELECT pa3.ag_contract_header_id
        INTO v_ach_id
        FROM p_policy_agent pa3
       WHERE pa3.policy_header_id = p_pol_header
         AND pa3.p_policy_agent_id =
             (SELECT MIN(pa2.p_policy_agent_id)
                FROM p_policy_agent pa2
               WHERE pa2.policy_header_id = p_pol_header);
      RETURN v_ach_id;
    END IF;
    CLOSE ch;
    RETURN v_ach_id;
  END;

END pkg_ag_calc_admin;
/

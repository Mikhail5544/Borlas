CREATE OR REPLACE PACKAGE pkg_policy_program_index_11 IS
  /*
   * Индексация договоров страхования 
   * @version 1
  */

  /**
  * @Author 
  * Процедура формирования списка договоров, подлежащих индексации 
  */
  PROCEDURE index_batch;

  FUNCTION create_policy_index
  (
    p_policy_header_id IN NUMBER
   ,p_year             IN NUMBER
  ) RETURN NUMBER;

  PROCEDURE index_batch(p_p_policy_id IN NUMBER);
  PROCEDURE update_cover_sum(p_as_asset_id NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_program_index_11 IS
  /*
   * Индексация договоров страхования
   * @version 1
  */
  g_fee_coef NUMBER DEFAULT 1.12;

  TYPE add_info IS RECORD(
     p_cover_id_prev            NUMBER
    ,p_cover_id_curr            NUMBER
    ,is_add_found               NUMBER(1)
    ,policy_id_prev             NUMBER
    ,policy_id_curr             NUMBER
    ,contact_id_prev            NUMBER
    ,contact_id_curr            NUMBER
    ,is_assured_change          NUMBER(1)
    ,ins_amount_prev            NUMBER
    ,ins_amount_curr            NUMBER
    ,is_ins_amount_change       NUMBER(1)
    ,fee_prev                   NUMBER
    ,fee_curr                   NUMBER
    ,is_fee_change              NUMBER(1)
    ,payment_terms_id_prev      NUMBER
    ,payment_terms_id_curr      NUMBER
    ,is_payment_terms_id_change NUMBER(1)
    ,period_id_prev             NUMBER
    ,period_id_curr             NUMBER
    ,is_period_change           NUMBER(1)
    ,is_one_payment_prev        NUMBER(1)
    ,is_one_payment_curr        NUMBER(1)
    ,is_periodical_change       NUMBER(1)
    ,ins_fund_id_curr           NUMBER
    ,ins_fund_id_prev           NUMBER
    ,is_fund_id_change          NUMBER(1)
    ,is_underwriting            NUMBER(1));

  g_debug BOOLEAN := TRUE;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO p_cover_debug
        (p_cover_id, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'PKG_POLICY_PROGRAM_INDEX_11', substr(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE init_fee_coef(p_p_policy_id IN NUMBER) IS
    RESULT NUMBER;
  BEGIN
    SELECT (100 + procent) / 100
      INTO g_fee_coef
    --, start_date, end_date
      FROM t_index_proc ip
          ,p_policy     pp
     WHERE pp.policy_id = p_p_policy_id
       AND pp.start_date BETWEEN ip.start_date AND
           nvl(ip.end_date, to_date('01.01.2099', 'dd.mm.yyyy'));
    --and pp.start_date between ip.start_date and ip.end_date;
  
  END;

  FUNCTION get_add_info(p_cover_id IN NUMBER) RETURN add_info IS
    -- Курсор для определения доп. соглашения
    CURSOR c_prev_version(p_p_cover_id IN NUMBER) IS
      SELECT p_cover_id_prev
            ,p_cover_id_curr
            ,is_add_found
            ,policy_id_prev
            ,policy_id_curr
            ,contact_id_prev
            ,contact_id_curr
            ,is_assured_change
            ,ins_amount_prev
            ,ins_amount_curr
            ,is_ins_amount_change
            ,fee_prev
            ,fee_curr
            ,is_fee_change
            ,payment_terms_id_prev
            ,payment_terms_id_curr
            ,is_payment_terms_id_change
            ,period_id_prev
            ,period_id_curr
            ,is_period_change
            ,is_one_payment_prev
            ,is_one_payment_curr
            ,is_periodical_change
            ,decode(doc.get_doc_status_brief(policy_id_prev), 'UNDERWRITING', 1, 0) is_underwriting
        FROM v_p_cover_life_add
       WHERE 1 = 1
         AND p_cover_id_curr = p_p_cover_id;
  
    --
    r_prev_version c_prev_version%ROWTYPE;
    --
    RESULT add_info;
  BEGIN
    OPEN c_prev_version(p_cover_id);
  
    FETCH c_prev_version
      INTO r_prev_version;
  
    -- При отсутствии предыдущей версии покрытия искуственно указываем, что это первая версия
    result.p_cover_id_prev := nvl(r_prev_version.p_cover_id_prev, p_cover_id);
    result.p_cover_id_curr := nvl(r_prev_version.p_cover_id_curr, p_cover_id);
    --
    result.is_add_found               := r_prev_version.is_add_found;
    result.policy_id_prev             := r_prev_version.policy_id_prev;
    result.policy_id_curr             := r_prev_version.policy_id_curr;
    result.contact_id_prev            := r_prev_version.contact_id_prev;
    result.contact_id_curr            := r_prev_version.contact_id_curr;
    result.is_assured_change          := r_prev_version.is_assured_change;
    result.ins_amount_prev            := r_prev_version.ins_amount_prev;
    result.ins_amount_curr            := r_prev_version.ins_amount_curr;
    result.is_ins_amount_change       := r_prev_version.is_ins_amount_change;
    result.fee_prev                   := r_prev_version.fee_prev;
    result.fee_curr                   := r_prev_version.fee_curr;
    result.is_fee_change              := r_prev_version.is_fee_change;
    result.payment_terms_id_prev      := r_prev_version.payment_terms_id_prev;
    result.payment_terms_id_curr      := r_prev_version.payment_terms_id_curr;
    result.is_payment_terms_id_change := r_prev_version.is_payment_terms_id_change;
    result.period_id_prev             := r_prev_version.period_id_prev;
    result.period_id_curr             := r_prev_version.period_id_curr;
    result.is_period_change           := r_prev_version.is_period_change;
    result.is_one_payment_prev        := r_prev_version.is_one_payment_prev;
    result.is_one_payment_curr        := r_prev_version.is_one_payment_curr;
    result.is_periodical_change       := r_prev_version.is_periodical_change;
    result.is_underwriting            := r_prev_version.is_underwriting;
    --
    RETURN RESULT;
    --
  END;

  PROCEDURE control
  (
    p_p_cover_id  IN NUMBER
   ,p_description IN VARCHAR2
   ,p_ll_brief    IN VARCHAR2
  ) IS
    r_add_info add_info;
  BEGIN
    r_add_info := get_add_info(p_p_cover_id);
  
    IF r_add_info.fee_prev > r_add_info.fee_curr
    THEN
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM Ошибка индексации ');
      raise_application_error(-20000
                             ,'Ошибка индексации. Брутто взнос после индексации расчитан неверно. Взнос по "' ||
                              p_description || '"' || '(' || p_ll_brief ||
                              ') меньше, чем до индексации');
    ELSIF r_add_info.fee_curr = 0
    THEN
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM Ошибка индексации ');
      raise_application_error(-20000
                             ,'Ошибка индексации. Брутто взнос после индексации расчитан неверно. Взнос по "' ||
                              p_description || '"' || '(' || p_ll_brief || ') равен 0 ');
    ELSIF r_add_info.fee_curr IS NULL
    THEN
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM Ошибка индексации ');
      raise_application_error(-20000
                             ,'Ошибка индексации. Брутто взнос после индексации на покрытии "' ||
                              p_description || '"' || '(' || p_ll_brief || ') неопределен');
    ELSIF r_add_info.is_period_change = 1
    THEN
      log(p_p_cover_id, 'CALC_PRIMARY_PROGRAM Ошибка индексации ');
      raise_application_error(-20000
                             ,'Ошибка индексации. Изменение срока действия на покрытии "' ||
                              p_description || '"' || '(' || p_ll_brief ||
                              ') в результате индексации запрещено');
    ELSIF NOT (r_add_info.period_id_prev = r_add_info.period_id_curr)
    THEN
      log(p_p_cover_id, 'CALC_PRIMARY_PROGRAM Ошибка индексации ');
      raise_application_error(-20000
                             ,'Ошибка индексации. Изменение срока действия на покрытии "' ||
                              p_description || '"' || '(' || p_ll_brief ||
                              ') в результате индексации запрещено');
    END IF;
  END;

  PROCEDURE calc_primary_program
  (
    p_p_policy_id IN NUMBER
   ,p_as_asset_id IN NUMBER
   ,p_coef        OUT NUMBER
  ) IS
    l_f             NUMBER;
    l_tariff_netto  NUMBER;
    l_tariff_brutto NUMBER;
    l_value         NUMBER;
    l_fee           NUMBER;
    l_ins_amount    NUMBER;
    l_coef          NUMBER;
    l_coef_index    NUMBER DEFAULT 0;
    l_index         NUMBER DEFAULT 0;
    r_add_info      add_info;
  
    CURSOR c_primary IS
      SELECT pc.*
            ,pl.description
            ,ll.brief ll_brief
        FROM p_cover             pc
            ,t_product_line_type plt
            ,t_lob_line          ll
            ,t_product_line      pl
            ,t_prod_line_option  plo
       WHERE 1 = 1
         AND pc.as_asset_id = p_as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plt.brief = 'RECOMMENDED';
  
    --
    v_pc   NUMBER;
    v_pp   NUMBER;
    v_gf_c NUMBER;
    v_gf_p NUMBER;
  BEGIN
    log(p_p_policy_id, 'CALC_PRIMARY_PROGRAM');
  
    FOR cur IN c_primary
    LOOP
      log(cur.p_cover_id, 'CALC_PRIMARY_PROGRAM p_cover_id ' || cur.p_cover_id);
    
      r_add_info := get_add_info(cur.p_cover_id);
    
      v_pc := pkg_tariff.calc_tarif_mul(r_add_info.p_cover_id_curr);
      v_pp := pkg_tariff.calc_tarif_mul(r_add_info.p_cover_id_prev);
    
      log(cur.p_cover_id, ' v_Pc ' || v_pc || ' v_Pp ' || v_pp);
    
      IF nvl(v_pp, 1) != 0
      THEN
        v_gf_p := ROUND(r_add_info.fee_prev / v_pp, 2);
      END IF;
    
      IF nvl(v_pc, 1) != 0
      THEN
        v_gf_c := ROUND(v_gf_p * g_fee_coef, 2);
      END IF;
    
      l_fee := v_gf_c * v_pc;
    
      --      l_fee := PKG_COVER.ROUND_FEE (cur.p_cover_id, l_fee);
    
      UPDATE p_cover SET fee = l_fee WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id, 'FEE ' || l_fee);
    
      log(cur.p_cover_id, 'PKG_COVER.CALC_LOADING INDEX_BATCH CALC ');
      log(cur.p_cover_id, 'PKG_COVER.CALC_LOADING INDEX_BATCH CALC ');
    
      l_f := pkg_cover.calc_loading(cur.p_cover_id);
    
      log(cur.p_cover_id, 'INDEX_BATCH L_F=' || l_f);
    
      UPDATE p_cover
         SET rvb_value        = l_f
            ,premia_base_type = 1
       WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id
         ,'INDEX_BATCH P_COVER_ID' || cur.p_cover_id || 'L_F ' || l_f || ' L_FEE ' || l_fee);
    
      log(cur.p_cover_id, 'INDEX_BATCH CALC pkg_cover.calc_tariff_netto');
      l_tariff_netto := pkg_cover.calc_tariff_netto(cur.p_cover_id);
    
      UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id, 'INDEX_BATCH L_TARIFF_NETTO ' || l_tariff_netto);
    
      log(cur.p_cover_id, 'INDEX_BATCH CALC pkg_cover.calc_tariff');
      l_tariff_brutto := pkg_cover.calc_tariff(cur.p_cover_id);
    
      UPDATE p_cover SET tariff = l_tariff_brutto WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id, 'INDEX_BATCH L_TARIFF_BRUTTO ' || l_tariff_brutto);
    
      IF v_pc != 0
      THEN
        l_value      := l_fee / (l_tariff_brutto * v_pc);
        l_value      := pkg_cover.round_ins_amount(cur.p_cover_id, l_value);
        l_ins_amount := l_value;
      END IF;
    
      log(cur.p_cover_id, 'INDEX_BATCH L_INS_AMOUNT ' || l_ins_amount);
    
      UPDATE p_cover
         SET --PREMIA_BASE_TYPE = cur.PREMIA_BASE_TYPE,
             ins_amount = l_ins_amount
       WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id
         ,'INDEX_BATCH Предыдущая страховая сумма ' || r_add_info.ins_amount_prev);
      l_coef_index := l_coef_index + l_ins_amount / r_add_info.ins_amount_prev;
      l_index      := l_index + 1;
    
      l_value := pkg_cover.calc_fee(cur.p_cover_id);
    
      UPDATE p_cover SET fee = l_value WHERE p_cover_id = cur.p_cover_id;
    
      l_value := pkg_cover.calc_premium(cur.p_cover_id);
    
      UPDATE p_cover SET premium = l_value WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id, 'INDEX_BATCH PREMIUM ' || l_value);
    
      control(cur.p_cover_id, cur.description, cur.ll_brief);
    
    END LOOP;
  
    l_coef_index := l_coef_index / l_index;
    p_coef       := l_coef_index;
  END;

  PROCEDURE calc_secondary_program
  (
    p_p_policy_id IN NUMBER
   ,p_as_asset_id IN NUMBER
   ,p_coef        IN NUMBER
  ) IS
    CURSOR c_secondary IS
      SELECT pc.*
            ,pl.description
            ,ll.brief ll_brief
        FROM p_cover             pc
            ,t_product_line_type plt
            ,t_lob_line          ll
            ,t_product_line      pl
            ,t_prod_line_option  plo
       WHERE 1 = 1
         AND pc.as_asset_id = p_as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plt.brief != 'RECOMMENDED'
         AND ll.brief NOT IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'PEPR_INVEST_RESERVE');
  
    CURSOR c_secondary_2 IS
      SELECT pc.*
            ,pl.description
            ,ll.brief ll_brief
        FROM p_cover             pc
            ,t_product_line_type plt
            ,t_lob_line          ll
            ,t_product_line      pl
            ,t_prod_line_option  plo
       WHERE 1 = 1
         AND pc.as_asset_id = p_as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND pl.id = plo.product_line_id
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND plt.product_line_type_id = pl.product_line_type_id
         AND plt.brief != 'RECOMMENDED'
         AND ll.brief IN ('Adm_Cost_Acc', 'Adm_Cost_Life', 'PEPR_INVEST_RESERVE');
  
    r_add_info add_info;
  
    PROCEDURE calc(p_p_cover_id IN NUMBER) IS
      l_f             NUMBER;
      l_tariff_netto  NUMBER;
      l_tariff_brutto NUMBER;
      l_value         NUMBER;
      l_ins_amount    NUMBER;
      l_coef_index    NUMBER DEFAULT 0;
      l_index         NUMBER DEFAULT 0;
      r_add_info      add_info;
      l_coef          NUMBER := 1;
    BEGIN
      r_add_info := get_add_info(p_p_cover_id);
    
      l_ins_amount := r_add_info.ins_amount_prev * p_coef;
      l_ins_amount := pkg_cover.round_ins_amount(p_p_cover_id, l_ins_amount);
    
      log(p_p_cover_id
         ,'CALC_SECONDARY_PROGRAM INS_AMOUNT BEFORE' || r_add_info.ins_amount_prev || ' p_coef ' ||
          p_coef || ' INS_AMOUNT ' || l_ins_amount);
    
      UPDATE p_cover
         SET ins_amount       = l_ins_amount
            ,premia_base_type = 0
       WHERE p_cover_id = p_p_cover_id;
    
      /* Расчет нагрузки  по дополнительной программе */
      l_f := pkg_cover.calc_loading(p_p_cover_id);
    
      /* Расчет нетто тарифа по дополнительной программе */
    
      l_tariff_netto := pkg_cover.calc_tariff_netto(p_p_cover_id);
    
      UPDATE p_cover SET tariff_netto = l_tariff_netto WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM l_tariff_netto ' || l_tariff_netto);
    
      /* Расчет брутто тарифа по дополнительной программе */
    
      l_tariff_brutto := pkg_cover.calc_tariff(p_p_cover_id);
    
      UPDATE p_cover SET tariff = l_tariff_brutto WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM l_tariff_brutto ' || l_tariff_brutto);
      /* Расчет аккумулированного коэффициента по дополнительной программе*/
      l_coef := pkg_tariff.calc_cover_coef(p_p_cover_id);
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM l_coef ' || l_coef);
      /* Расчет брутто взноса по дополнительной программе */
    
      l_value := pkg_cover.calc_fee(p_p_cover_id);
    
      UPDATE p_cover SET fee = l_value WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM FEE ' || l_value);
    
      /* Расчет брутто взноса по дополнительной программе */
    
      l_value := pkg_cover.calc_premium(p_p_cover_id);
    
      UPDATE p_cover SET premium = l_value WHERE p_cover_id = p_p_cover_id;
    
      log(p_p_cover_id, 'CALC_SECONDARY_PROGRAM PREMIUM ' || l_value);
    END;
  
  BEGIN
    FOR cur IN c_secondary
    LOOP
      /* Расчет страховой суммы по дополнительной программе */
    
      log(cur.p_cover_id, 'CALC_SECONDARY_PROGRAM ' || cur.ll_brief);
    
      IF cur.ll_brief NOT IN ('WOP', 'PWOP')
      THEN
        UPDATE p_cover
           SET is_handchange_amount     = 0
              ,is_handchange_ins_amount = 0
              ,is_handchange_fee        = 0
              ,is_handchange_tariff     = 0
              ,is_handchange_premium    = 0
         WHERE p_cover_id = cur.p_cover_id;
      
        calc(cur.p_cover_id);
      END IF;
    
      control(cur.p_cover_id, cur.description, cur.ll_brief);
    
    END LOOP;
  
    FOR cur IN c_secondary
    LOOP
      /* Расчет страховой суммы по дополнительной программе */
    
      log(cur.p_cover_id, 'CALC_SECONDARY_PROGRAM ' || cur.ll_brief);
    
      IF cur.ll_brief IN ('WOP', 'PWOP')
      THEN
        UPDATE p_cover
           SET ins_amount               = NULL
              ,is_handchange_amount     = 0
              ,is_handchange_ins_amount = 0
              ,is_handchange_fee        = 0
              ,is_handchange_tariff     = 0
              ,is_handchange_premium    = 0
         WHERE p_cover_id = cur.p_cover_id;
      
        log(cur.p_cover_id, 'CALC_SECONDARY_PROGRAM PKG_COVER.UPDATE_COVER_SUM ' || cur.ll_brief);
      
        pkg_cover.update_cover_sum(cur.p_cover_id);
        control(cur.p_cover_id, cur.description, cur.ll_brief);
      END IF;
    END LOOP;
  
    FOR cur IN c_secondary_2
    LOOP
      /* Расчет страховой суммы по дополнительной программе */
    
      log(cur.p_cover_id, 'CALC_SECONDARY_PROGRAM ' || cur.ll_brief);
    
      UPDATE p_cover
         SET ins_amount               = NULL
            ,is_handchange_amount     = 0
            ,is_handchange_ins_amount = 0
            ,is_handchange_fee        = 0
            ,is_handchange_tariff     = 0
            ,is_handchange_premium    = 0
       WHERE p_cover_id = cur.p_cover_id;
    
      log(cur.p_cover_id, 'CALC_SECONDARY_PROGRAM PKG_COVER.UPDATE_COVER_SUM ' || cur.ll_brief);
    
      pkg_cover.update_cover_sum(cur.p_cover_id);
      control(cur.p_cover_id, cur.description, cur.ll_brief);
    END LOOP;
    /**/
    /*pkg_policy_program_index_11.update_cover_sum(p_as_asset_id);*/
    /**/
  END;
  /**/
  PROCEDURE update_cover_sum(p_as_asset_id NUMBER) IS
  BEGIN
  
    FOR cur IN (SELECT pc.p_cover_id
                      ,pl.description
                      ,ll.brief ll_brief
                  FROM p_cover             pc
                      ,t_product_line_type plt
                      ,t_lob_line          ll
                      ,t_product_line      pl
                      ,t_prod_line_option  plo
                 WHERE 1 = 1
                   AND pc.as_asset_id = p_as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND pl.id = plo.product_line_id
                   AND ll.t_lob_line_id = pl.t_lob_line_id
                   AND plt.product_line_type_id = pl.product_line_type_id
                   AND plt.brief != 'RECOMMENDED'
                   AND ll.brief IN ('WOP', 'PWOP'))
    LOOP
      pkg_cover.update_cover_sum(cur.p_cover_id);
    END LOOP;
  
  END;

  /**
           * @Author
  * Процедура формирования списка договоров, подлежащих индексации
  */
  PROCEDURE index_batch IS
  BEGIN
    NULL;
  END;

  FUNCTION copy_policy_for_index(p_pol_id NUMBER) RETURN NUMBER AS
    l_policy_id NUMBER;
    v_p_policy  ven_p_policy%ROWTYPE;
    v_temp_id   NUMBER;
  BEGIN
    FOR rec IN (SELECT v.*
                  FROM ven_p_policy       v
                      ,ins.document       d
                      ,ins.doc_status_ref rf
                 WHERE v.policy_id = p_pol_id
                   AND d.document_id = v.policy_id
                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                   AND rf.brief != 'CANCEL')
    LOOP
      v_p_policy := rec;
    END LOOP;
  
    SELECT t_policy_change_type_id
      INTO v_temp_id
      FROM t_policy_change_type
     WHERE brief = 'Основные';
  
    l_policy_id := pkg_policy.new_policy_version(par_policy_id             => p_pol_id
                                                ,par_change_id             => v_temp_id
                                                ,par_policy_change_type_id => v_temp_id);
  
    FOR rec IN (SELECT t_addendum_type_id FROM t_addendum_type WHERE brief = 'INDEXING2')
    LOOP
      INSERT INTO ven_p_pol_addendum_type
        (p_policy_id, t_addendum_type_id)
      VALUES
        (l_policy_id, rec.t_addendum_type_id);
    END LOOP;
  
    UPDATE p_policy pp
       SET pp.start_date            = v_p_policy.start_date
          ,pp.confirm_date          = v_p_policy.start_date
          ,pp.end_date              = v_p_policy.end_date
          ,pp.notice_date_addendum  = v_p_policy.start_date
          ,pp.confirm_date_addendum = v_p_policy.start_date
          ,pp.cash_surr_method_id   = 2
     WHERE policy_id = l_policy_id;
  
    pkg_policy.update_policy_dates(l_policy_id);
  
    RETURN l_policy_id;
    -- Байтин А.
    -- Убрал, т.к. во-первых, вываливалась с неправильной ошибкой, т.к. функция не возвращала значения,
    -- во-вторых, не было понятно, какая именно ошибка
    /*EXCEPTION
    WHEN OTHERS
    THEN
       DBMS_OUTPUT.put_line ('ERR ' || SQLERRM);*/
  END;

  FUNCTION checkpolicyforprolongation(p_pol_header_id NUMBER) RETURN NUMBER IS
    res NUMBER := utils.c_false;
  BEGIN
    log(p_pol_header_id, 'CHECKPOLICYFORPROLONGATION');
  
    FOR cur IN (SELECT ll.brief
                      ,pc.p_cover_id
                      ,pp.policy_id
                      ,pph.policy_header_id
                      ,pp.start_date
                      ,pp.end_date
                      ,pp.payment_term_id
                      ,pp.paymentoff_term_id
                  FROM p_pol_header       pph
                      ,p_policy           pp
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob_line         ll
                 WHERE pp.pol_header_id = pph.policy_header_id
                   AND pph.policy_header_id = nvl(p_pol_header_id, pph.policy_header_id)
                   AND pp.version_num = (SELECT MAX(a.version_num)
                                           FROM ins.p_policy       a
                                               ,ins.document       d
                                               ,ins.doc_status_ref rf
                                          WHERE a.pol_header_id = pph.policy_header_id
                                            AND a.policy_id = d.document_id
                                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                                            AND rf.brief != 'CANCEL')
                   AND pp.end_date > ADD_MONTHS(pp.start_date, 12)
                   AND aa.p_policy_id = pp.policy_id
                   AND pc.as_asset_id = aa.as_asset_id
                   AND plo.id = pc.t_prod_line_option_id
                   AND pl.id = plo.product_line_id
                   AND ll.t_lob_line_id = pl.t_lob_line_id
                   AND pl.is_avtoprolongation = 1
                   AND doc.get_last_doc_status_brief(pp.policy_id) IN
                       ('CURRENT', 'ACTIVE', 'STOP', 'PRINTED')
                 ORDER BY pp.policy_id)
    LOOP
      res := utils.c_true;
      log(p_pol_header_id, 'CHECKPOLICYFORPROLONGATION TRUE');
      EXIT;
    END LOOP;
  
    RETURN res;
  END checkpolicyforprolongation;

  FUNCTION create_policy_index
  (
    p_policy_header_id IN NUMBER
   ,p_year             IN NUMBER
  ) RETURN NUMBER IS
    l_id                 NUMBER;
    l_header_id          NUMBER;
    l_policy_id          NUMBER;
    l_policy_prev_id     NUMBER;
    l_policy_prolong_id  NUMBER;
    l_start_date         DATE;
    l_doc_status         VARCHAR2(50);
    l_doc_prev_status    VARCHAR2(50);
    v_date               DATE := SYSDATE;
    l_version_indexation NUMBER := utils.c_false;
    l_error              NUMBER DEFAULT 0;
    l_ph_start_date      DATE;
    vl_doc_status        VARCHAR2(50);
    v_cnt                INT;
    l_order_num          NUMBER;
  BEGIN
    --Чирков/192022 Доработка АС BI в части обеспечения регистрации
    SELECT COUNT(1)
      INTO v_cnt
      FROM ins.ven_journal_tech_work jtw
          ,ins.doc_status_ref        dsr
     WHERE jtw.policy_header_id = p_policy_header_id
       AND jtw.doc_status_ref_id = dsr.doc_status_ref_id
       AND dsr.brief = 'CURRENT'
       AND jtw.work_type IN (1
                            ,2 --Рассмотрение в СБ, Рассмотрение в ЮУ
                            ,0 -- «Технические работы» /добавлено по заявке 303077/
                             );
    IF v_cnt > 0
    THEN
      log(p_policy_header_id, 'CREATE_POLICY_INDEX Ошибка индексации');
      raise_application_error(-20000
                             ,'ДС находится на рассмотрении в СБ или ЮУ"');
    END IF;
    --end--Чирков/192022//
  
    FOR rec IN (SELECT *
                  FROM ((SELECT pp.pol_header_id
                               ,pp.policy_id
                               ,pp.start_date
                               ,ph.start_date ph_start_date
                           FROM ins.p_pol_header   ph
                               ,ins.p_policy       pp
                               ,ins.document       d
                               ,ins.doc_status_ref rf
                          WHERE ph.policy_header_id = p_policy_header_id
                            AND pp.pol_header_id = ph.policy_header_id
                            AND pp.policy_id = d.document_id
                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                            AND rf.brief != 'CANCEL'
                          ORDER BY pp.policy_id DESC))
                 WHERE rownum = 1)
    LOOP
      l_header_id     := rec.pol_header_id;
      l_policy_id     := rec.policy_id;
      l_start_date    := rec.start_date;
      l_ph_start_date := rec.ph_start_date;
    END LOOP;
  
    FOR rec IN (SELECT *
                  FROM ((SELECT pp.policy_id
                           FROM ins.p_pol_header   ph
                               ,ins.p_policy       pp
                               ,ins.document       d
                               ,ins.doc_status_ref rf
                          WHERE ph.policy_header_id = p_policy_header_id
                            AND pp.pol_header_id = ph.policy_header_id
                            AND pp.policy_id = d.document_id
                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                            AND rf.brief != 'CANCEL'
                          ORDER BY pp.policy_id DESC))
                 WHERE rownum <= 2)
    LOOP
      l_policy_prev_id := rec.policy_id;
    END LOOP;
  
    l_doc_status      := doc.get_doc_status_brief(l_policy_id);
    l_doc_prev_status := doc.get_doc_status_brief(l_policy_prev_id);
  
    v_date := SYSDATE;
  
    /*проверка, если пролонгация на этот год*/
    IF (to_char(l_start_date, 'YYYY') = p_year)
       AND (to_char(l_ph_start_date, 'DD.MM') = to_char(l_start_date, 'DD.MM'))
    THEN
      /*Да, есть пролонгация на год*/
    
      IF (l_doc_status = 'PROJECT' OR l_doc_status = 'NEW')
      THEN
        IF (l_doc_status = 'PROJECT')
        THEN
          doc.set_doc_status(l_policy_id, 'NEW', v_date + ((10 * 1) / 24 / 3600));
        END IF;
      
        IF (l_doc_prev_status = 'ACTIVE')
        THEN
          doc.set_doc_status(l_policy_id, l_doc_prev_status, v_date + ((10 * 2) / 24 / 3600));
        END IF;
      
        IF (l_doc_prev_status = 'CURRENT')
        THEN
          doc.set_doc_status(l_policy_id, l_doc_prev_status, v_date + ((10 * 3) / 24 / 3600));
        END IF;
      
        IF (l_doc_prev_status = 'PRINTED')
        THEN
          doc.set_doc_status(l_policy_id, 'ACTIVE', v_date + ((10 * 4) / 24 / 3600));
          doc.set_doc_status(l_policy_id, l_doc_prev_status, v_date + ((10 * 5) / 24 / 3600));
        END IF;
      END IF;
    
      pkg_policy.flag_dont_check_status := 1;
      l_id                              := copy_policy_for_index(l_policy_id);
    ELSE
      /*нет пролонгации на этот год*/
    
      IF (checkpolicyforprolongation(p_policy_header_id) = utils.c_true)
      THEN
        dbms_output.put_line('before pkg_policy.job_prolongation_p2 ' || l_policy_id);
        log(l_policy_id, 'CREATE_POLICY_INDEX PKG_POLICY_11.JOB_PROLONGATION_INDEXATION 1');
        l_policy_prolong_id := pkg_policy_11.job_prolongation_indexation(p_policy_header_id
                                                                        ,0
                                                                        ,1
                                                                        ,p_year);
        log(l_policy_id, 'CREATE_POLICY_INDEX JOB_PROLONGATION_INDEXATION SUCCESFULL');
      
        l_version_indexation := utils.c_false;
      ELSE
        dbms_output.put_line('before pkg_policy.job_prolongation_p2 is auto = 0' || l_policy_id);
        log(l_policy_id, 'CREATE_POLICY_INDEX PKG_POLICY_11.JOB_PROLONGATION_INDEXATION 0');
        l_policy_prolong_id := pkg_policy_11.job_prolongation_indexation(p_policy_header_id
                                                                        ,0
                                                                        ,0
                                                                        ,p_year);
        log(l_policy_id, 'CREATE_POLICY_INDEX JOB_PROLONGATION_INDEXATION SUCCESFULL');
      
        /*т.к. в функции выше делается не тот тип изменений, меняем на индексацию*/
        UPDATE ven_p_pol_addendum_type v
           SET v.t_addendum_type_id =
               (SELECT t_addendum_type_id FROM t_addendum_type WHERE brief = 'INDEXING2')
         WHERE v.p_policy_id = l_policy_prolong_id;
        UPDATE ins.p_policy p SET p.t_pol_change_type_id = 1 WHERE p.policy_id = l_policy_prolong_id;
      
        l_version_indexation := utils.c_true;
      END IF;
    
      IF (l_policy_prolong_id <> -1)
      THEN
        IF (l_version_indexation = utils.c_false)
        THEN
          BEGIN
            log(l_policy_prolong_id
               ,'CREATE_POLICY_INDEX STATUS NEW ' ||
                to_char(v_date + ((10 * 1) / 24 / 3600), 'dd.mm.yyyy hh24:mi:ss'));
            doc.set_doc_status(l_policy_prolong_id, 'NEW', v_date + ((10 * 1) / 24 / 3600));
          EXCEPTION
            WHEN OTHERS THEN
              log(l_policy_prolong_id, 'CREATE_POLICY_INDEX ' || SQLERRM);
              RAISE;
          END;
        
          IF (l_doc_status = 'ACTIVE')
          THEN
            log(l_policy_prolong_id, 'CREATE_POLICY_INDEX STATUS ACTIVE');
            doc.set_doc_status(l_policy_prolong_id, l_doc_status, v_date + ((10 * 2) / 24 / 3600));
          END IF;
        
          IF (l_doc_status = 'CURRENT')
          THEN
            log(l_policy_prolong_id, 'CREATE_POLICY_INDEX STATUS CURRENT');
            doc.set_doc_status(l_policy_prolong_id, l_doc_status, v_date + ((10 * 3) / 24 / 3600));
          END IF;
        
          IF (l_doc_status = 'PRINTED')
          THEN
            log(l_policy_prolong_id, 'CREATE_POLICY_INDEX STATUS PRINTED');
            doc.set_doc_status(l_policy_prolong_id, 'ACTIVE', v_date + ((10 * 4) / 24 / 3600));
            doc.set_doc_status(l_policy_prolong_id, l_doc_status, v_date + ((10 * 5) / 24 / 3600));
          END IF;
        END IF;
      
        l_policy_id := l_policy_prolong_id;
      END IF;
    
      IF (l_version_indexation = utils.c_false)
      THEN
        log(l_policy_id, 'CREATE_POLICY_INDEX COPY_POLICY_FOR_INDEX');
        pkg_policy.flag_dont_check_status := 1;
        l_id                              := copy_policy_for_index(l_policy_id);
      ELSE
        log(l_policy_prolong_id, 'CREATE_POLICY_INDEX L_VERSION_INDEXATION = UTILS.C_FALSE');
        l_id := l_policy_id;
      END IF;
    END IF;
  
    IF l_id IS NULL
    THEN
      raise_application_error(-20000
                             ,'Пролонгация или копирование догвоора не выполнена');
    END IF;
  
    -- Получение ИЛ новой версии договора
  
    /*
            SELECT policy_id into l_id FROM p_policy where pol_header_id = l_header_id
      and start_date > l_start_date;
    */
    l_order_num := ins.pkg_policy.set_pol_version_order_num(l_id);
    UPDATE p_policy pp
       SET pp.cash_surr_method_id = 2
          ,
           --PP.MAILING = 1,
           pp.version_order_num = l_order_num
    /*    (SELECT   MAX (NVL (PP2.VERSION_ORDER_NUM, 0)) + 1
     FROM   P_POLICY pp2,
            ins.document d
    WHERE   PP2.POL_HEADER_ID = PP.POL_HEADER_ID
            AND PP2.POLICY_ID <> PP.POLICY_ID)*/
     WHERE pp.policy_id = l_id;
  
    doc.set_doc_status(l_id, 'INDEXATING', v_date + ((10 * 6) / 24 / 3600));
    RETURN l_id;
  EXCEPTION
    WHEN OTHERS THEN
      log(l_policy_prolong_id, 'CREATE_POLICY_INDEX EXCEPTION ' || SQLERRM);
    
      raise_application_error(-20000, SQLERRM);
  END;

  PROCEDURE index_batch(p_p_policy_id IN NUMBER) IS
    l_f             NUMBER;
    l_tariff_netto  NUMBER;
    l_tariff_brutto NUMBER;
    l_value         NUMBER;
    l_ins_amount    NUMBER;
    l_coef          NUMBER;
  BEGIN
    init_fee_coef(p_p_policy_id);
  
    FOR cur IN (SELECT as_asset_id FROM as_asset WHERE p_policy_id = p_p_policy_id)
    LOOP
      calc_primary_program(p_p_policy_id, cur.as_asset_id, l_coef);
      log(cur.as_asset_id, 'Index_Batch l_coef' || l_coef);
    
      calc_secondary_program(p_p_policy_id, cur.as_asset_id, l_coef);
    
      pkg_policy.update_policy_sum(p_p_policy_id);
    END LOOP;
  END;
END;
/

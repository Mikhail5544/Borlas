CREATE OR REPLACE PACKAGE pkg_product_conds IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 18.07.2012 17:30:53
  -- Purpose : Пакет для реализации логики справочника Полисные условия

  /*
    Байтин А.
    
    Процедура, срабатывающая на переходе из Проект в Новый версии ДС
    Устанавливает полисные условия в первую версию ДС
  */
  PROCEDURE add_conds_to_policy(par_policy_id NUMBER);

END pkg_product_conds;
/
CREATE OR REPLACE PACKAGE BODY pkg_product_conds IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  /*
    Байтин А.
    
    Процедура, срабатывающая на переходе из Проект в Новый версии ДС
    Устанавливает полисные условия в первую версию ДС
  */
  PROCEDURE add_conds_to_policy(par_policy_id NUMBER) IS
    c_proc_name CONSTANT pkg_trace.t_object_name := 'ADD_CONDS_TO_POLICY';
    v_version_num             p_policy.version_num%TYPE;
    v_bso_series              bso_series.bso_series_id%TYPE;
    v_product_conds_id        t_policyform_product.t_policyform_product_id%TYPE;
    v_policy_form_id          t_policyform_product.t_policy_form_id%TYPE;
    v_product_id              t_policyform_product.t_product_id%TYPE;
    v_bso_series_id           bso_series.bso_series_id%TYPE;
    v_start_date              p_pol_header.start_date%TYPE;
    v_t_policyform_product_id NUMBER;
  
    PROCEDURE check_prod_policy_form_exists(par_product_id t_product.product_id%TYPE) IS
      v_exists INTEGER;
    BEGIN
      SELECT COUNT(pc.t_policyform_product_id)
        INTO v_exists
        FROM ins.t_policyform_product pc
       WHERE pc.t_product_id = par_product_id;
    
      IF v_exists = 0
      THEN
        raise_application_error(-20001
                               ,'Внимание! Для данного продукта не определены полисные условия в справочнике "Настройка связи между полисными условиями и продуктом"');
      END IF;
    END check_prod_policy_form_exists;
  BEGIN
    pkg_trace.add_variable('par_policy_id', par_policy_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => c_proc_name);
  
    -- Только на первой версии
    SELECT pc.t_policy_form_id
          ,ph.product_id
          ,ph.start_date
          ,pp.version_num
      INTO v_policy_form_id
          ,v_product_id
          ,v_start_date
          ,v_version_num
      FROM p_policy                 pp
          ,ins.t_policyform_product pc
          ,ins.p_pol_header         ph
     WHERE pp.policy_id = par_policy_id
       AND pp.t_product_conds_id = pc.t_policyform_product_id(+)
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF v_version_num = 1
       AND v_policy_form_id IS NULL
    THEN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => c_proc_name
                     ,par_message           => 'Определение Полисных условий по первой неотмененной версии');
    
      BEGIN
        SELECT bs.t_product_conds_id
          INTO v_policy_form_id
          FROM bso        b
              ,bso_series bs
         WHERE b.policy_id = par_policy_id
           AND b.is_pol_num = 1
           AND bs.bso_series_id = b.bso_series_id;
      
      EXCEPTION
        WHEN no_data_found THEN
          ex.raise('Внимание! В договоре не существует БСО с активным признаком использования, и статусом «Использован», определение полисных условий невозможно');
      END;
    
      --Чирков 238562: Процедура ДС. Определение полисных условий
      check_prod_policy_form_exists(par_product_id => v_product_id);
    
      --Проверяем, что полисные условия из настроек серии (Главное меню\Документы\БСО\Настройка серииБСО) 
      --совпадает с "Справочники\Настройка связи между полисными условиями и продуктом"
      IF v_policy_form_id IS NOT NULL
      THEN
        BEGIN
          SELECT pc.t_policyform_product_id
            INTO v_t_policyform_product_id
            FROM ins.t_policyform_product pc
           WHERE pc.t_policy_form_id = v_policy_form_id
             AND pc.t_product_id = v_product_id;
        EXCEPTION
          WHEN no_data_found THEN
            ex.raise('Внимание! Для выбранного БСО не задано соответствие с полисными условиями по продукту');
        END;
      ELSE
        BEGIN
          SELECT pc.t_policyform_product_id
            INTO v_t_policyform_product_id
            FROM ins.t_policyform_product pc
           WHERE pc.t_product_id = v_product_id
             AND v_start_date BETWEEN pc.start_date AND pc.end_date;
        EXCEPTION
          WHEN no_data_found THEN
            ex.raise('Не удалось определить действующие Полисные условия по продукту на дату начала действия договора');
          WHEN too_many_rows THEN
            ex.raise('Не удалось однозначно определить действующие Полисные условия по продукту на дату начала действия договора');
        END;
      END IF;
    
      --Чирков 238562
      -- Ставим ПУ
      UPDATE p_policy pp
         SET pp.t_product_conds_id = v_t_policyform_product_id
       WHERE pp.policy_id = par_policy_id;
    END IF;
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => c_proc_name);
  END;
END pkg_product_conds;
/

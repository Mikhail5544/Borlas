CREATE OR REPLACE PACKAGE pkg_mpos_operations IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 25.02.2014 13:48:11
  -- Purpose : Работа с формой "Операции с mPos-терминалов" - MPOS_OPERATIONS.FMB

  PROCEDURE append_operation
  (
    par_obj_id            v_mpos_operations.obj_id%TYPE
   ,par_amount            v_mpos_operations.amount%TYPE
   ,par_payment_system_id v_mpos_operations.t_payment_system_id%TYPE
  );

  PROCEDURE clear_operations;

  PROCEDURE delete_operation(par_obj_id v_mpos_operations.obj_id%TYPE);

  FUNCTION get_amount_sum RETURN v_mpos_operations.amount%TYPE;

  FUNCTION is_multiple_pay_systems_exists RETURN BOOLEAN;
END pkg_mpos_operations; 
/
CREATE OR REPLACE PACKAGE BODY pkg_mpos_operations IS

  TYPE t_operation IS RECORD(
     amount            v_mpos_operations.amount%TYPE
    ,payment_system_id v_mpos_operations.t_payment_system_id%TYPE);

  TYPE tt_operations IS TABLE OF t_operation INDEX BY PLS_INTEGER;

  gc_package_name VARCHAR2(30) := 'PKG_MPOS_OPERATIONS';
  gv_operations   tt_operations;

  PROCEDURE append_operation
  (
    par_obj_id            v_mpos_operations.obj_id%TYPE
   ,par_amount            v_mpos_operations.amount%TYPE
   ,par_payment_system_id v_mpos_operations.t_payment_system_id%TYPE
  ) IS
    c_procedure_name VARCHAR2(30) := 'APPEND_OPERATION';
  BEGIN
    pkg_trace.add_variable('par_obj_id', par_obj_id);
    pkg_trace.add_variable('par_amount', par_amount);
    pkg_trace.add_variable('par_payment_system_id', par_payment_system_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_package_name
                                   ,par_trace_subobj_name => c_procedure_name);
    assert_deprecated(par_obj_id IS NULL, 'Параметр par_obj_id не может быть NULL');
    assert_deprecated(par_amount IS NULL, 'Параметр par_amount не может быть NULL');
    assert_deprecated(par_payment_system_id IS NULL
          ,'Параметр par_payment_system_id не может быть NULL');
    gv_operations(par_obj_id).amount := par_amount;
    gv_operations(par_obj_id).payment_system_id := par_payment_system_id;
  END append_operation;

  PROCEDURE clear_operations IS
  BEGIN
    gv_operations.delete;
  END clear_operations;

  PROCEDURE delete_operation(par_obj_id v_mpos_operations.obj_id%TYPE) IS
  BEGIN
    gv_operations.delete(par_obj_id);
  END delete_operation;

  FUNCTION get_amount_sum RETURN v_mpos_operations.amount%TYPE IS
    c_function_name VARCHAR2(30) := 'APPEND_OPERATION';
    v_summary       v_mpos_operations.amount%TYPE := 0;
    v_key           PLS_INTEGER;
  BEGIN
    pkg_trace.trace_function_start(par_trace_obj_name    => gc_package_name
                                  ,par_trace_subobj_name => c_function_name);
  
    v_key := gv_operations.first;
    LOOP
      EXIT WHEN v_key IS NULL;
      v_summary := v_summary + gv_operations(v_key).amount;
      v_key     := gv_operations.next(v_key);
    END LOOP;
  
    pkg_trace.trace_function_end(par_result_value      => v_summary
                                ,par_trace_obj_name    => gc_package_name
                                ,par_trace_subobj_name => c_function_name);
  
    RETURN v_summary;
  END get_amount_sum;


  /** Не позволяет к одному ППвх загружать уведомления/платежи с mPos с разными типами карт
  *   Исключением является MAESTRO и MASTERCARD, их можно загрузить к одному ППвх
  *   Возвращаем true если загрузить нельзя, т.е. найдены разные типы карт.
  */
  FUNCTION is_multiple_pay_systems_exists RETURN BOOLEAN IS
    v_is_exists              BOOLEAN := FALSE;
    v_key                    v_mpos_operations.obj_id%TYPE;
    v_prev_payment_system_id v_mpos_operations.t_payment_system_id%TYPE;
    v_maestro_id             t_payment_system.t_payment_system_id%TYPE;
    v_mastercard_id          t_payment_system.t_payment_system_id%TYPE;
  BEGIN
    v_key           := gv_operations.first;
    v_maestro_id    := pkg_t_payment_system_dml.get_id_by_brief('MAESTRO');
    v_mastercard_id := pkg_t_payment_system_dml.get_id_by_brief('MASTERCARD');
    LOOP
      EXIT WHEN v_key IS NULL OR v_is_exists;
      IF v_prev_payment_system_id IS NOT NULL
      THEN
        --/Чирков/условие изменено по заявке 320332: загрузка платежей mPos к ППвх 
        IF (v_prev_payment_system_id NOT IN (v_maestro_id, v_mastercard_id)
            OR gv_operations(v_key).payment_system_id NOT IN (v_maestro_id, v_mastercard_id))
           AND v_prev_payment_system_id != gv_operations(v_key).payment_system_id
        
        THEN
          v_is_exists := TRUE;
        END IF;
      END IF;
      --
      v_prev_payment_system_id := gv_operations(v_key).payment_system_id;
      v_key                    := gv_operations.next(v_key);
    END LOOP;
    RETURN v_is_exists;
  END is_multiple_pay_systems_exists;

END pkg_mpos_operations; 
/

CREATE OR REPLACE PACKAGE pkg_cover IS

  TYPE t_cover_rec IS RECORD(
     t_prod_line_opt_id      NUMBER
    ,t_prod_line_opt_brief   t_prod_line_option.brief%TYPE
    ,exclude                 NUMBER(1)
    ,start_date              DATE
    ,end_date                DATE
    ,fee                     NUMBER
    ,ins_amount              NUMBER
    ,period_id               NUMBER
    ,proc                    NUMBER
    ,premia_base_type        p_cover.premia_base_type%TYPE DEFAULT 0
    ,is_autoprolongation     NUMBER(1)
    ,is_handchange_amount    p_cover.is_handchange_amount%TYPE DEFAULT 0
    ,is_handchange_premium   p_cover.is_handchange_premium%TYPE DEFAULT 0
    ,is_handchange_fee       p_cover.is_handchange_fee%TYPE DEFAULT 0
    ,is_handchange_ins_price p_cover.is_handchange_ins_price%TYPE DEFAULT 0
    ,is_handchange_tariff    p_cover.is_handchange_tariff%TYPE DEFAULT 0
    ,status_hist_id          status_hist.status_hist_id%TYPE DEFAULT 1 -- NEW
    );

  TYPE t_cover_array IS TABLE OF t_cover_rec;

  --TYPE t_test IS TABLE OF NUMBER;

  FUNCTION cover_array RETURN t_cover_array
    PIPELINED;

  /**
  * ���������� ����������
  * @author Denis Ivanov
  */
  /**
  * �� ������� ����������� �������� '�����'
  */
  status_hist_id_new NUMBER;
  /**
  * �� ������� ����������� �������� '�����������'
  */
  status_hist_id_curr NUMBER;
  /**
  * �� ������� ����������� �������� '������'
  */
  status_hist_id_del NUMBER;

  FUNCTION get_status_hist_id_new RETURN NUMBER;
  FUNCTION get_status_hist_id_curr RETURN NUMBER;
  FUNCTION get_status_hist_id_del RETURN NUMBER;

  /**
  * ���������� �������� �� ��������
  * @author Denis Ivanov
  * @param p_cover_id �� ��������
  * @param p_deduct_type_id �� ���� �������� ������������
  * @param p_deduct_val_type_id �� ���� �������� �����������
  * @param p_deduct_value �������� ��������
  */
  PROCEDURE calc_deduct
  (
    p_p_cover_id         IN NUMBER
   ,p_deduct_type_id     OUT NUMBER
   ,p_deduct_val_type_id OUT NUMBER
   ,p_deduct_value       OUT NUMBER
  );

  /**
  * ���������� �������� �� ��������
  * @author Denis Ivanov
  * @param p_cover_id �� ��������
  * @param p_deduct_type_id �� ���� �������� ������������
  * @param p_deduct_val_type_id �� ���� �������� �����������
  * @param p_deduct_value �������� ��������
  */
  FUNCTION calc_deduct(p_p_cover_id IN NUMBER) RETURN NUMBER;
  /**
  * ���������� ��������� ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� �����
  */

  FUNCTION calc_ins_amount(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_ins_price(p_p_cover_id NUMBER) RETURN NUMBER;
  /**
  * ���������� ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_tariff(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ����� ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */

  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ������ �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ������ ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER;
  /**
  * ���������� �������� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_loading(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ������������� ����������� S
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_s_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ���������� ������������� ����������� K
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_k_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * �������� ������ ������� ��������
  * @author ����� �.
  * 
  */
  PROCEDURE recalc_cover_tariffs(par_cover_id p_cover.p_cover_id%TYPE);

  /*
    ����� �.
    ��������� ���� ������.
    ������������ ��� �������������� ��������
    � ���������� ����� ��������� �������� ������ ��������� �� �������� ��� �� ����� ���������������� �������� �.�. ����� �������� �� ��������
  */
  FUNCTION calc_fee_investment_part(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER;

  /**
  * ����������� ����� �� ��������
  * @author Denis Ivanov
  * @param p_p_cover_id number
  */
  PROCEDURE update_cover_sum(p_p_cover_id NUMBER);

  /**
  * ������� ������ � ���������
  * ������� ������ � p_cover_agent, ��������� ����� ����������� ������
  * � ������� @see pkg_agent.get_agent_rate_by_cover(). ���� ����� ���
  * ����, ������ ���������� �� ������.
  * @author Denis Ivanov
  * @param p_cover_id �� ��������
  * @param p_agent_id �� ������
  * @return �� p_cover_agent
  */
  FUNCTION link_cover_agent
  (
    p_cover_id NUMBER
   ,p_agent_id NUMBER
  ) RETURN NUMBER;

  /**
  * �������� ������ �������� �� ������� ����������� � ����� � ��������
  * @author Denis Ivanov
  * @param p_t_product_line_id �� ����� � ��������
  * @param p_as_asset_id �� ������� �����������
  * @return �� ������ ��������
  */
  FUNCTION cre_new_cover
  (
    p_as_asset_id       IN NUMBER
   ,p_t_product_line_id IN NUMBER
   ,
    -- ������ �.
    -- ��������: ��������� as_asset ����� ���������� ��� ���
    p_update_asset IN BOOLEAN DEFAULT TRUE
   ,p_start_date   DATE DEFAULT NULL
   ,p_end_date     DATE DEFAULT NULL
   , -- ����� �.
    -- ������� ���������, ����� ��������� ����������� ��������� �������� ����� ��� ��������
    p_period_id                NUMBER DEFAULT NULL
   ,p_fee                      NUMBER DEFAULT NULL
   ,p_ins_amount               NUMBER DEFAULT NULL
   ,p_is_autoprolongation      NUMBER DEFAULT NULL
   ,p_premia_base_type         NUMBER DEFAULT 0
   ,p_status_hist_id           NUMBER DEFAULT NULL
   ,p_is_handchange_amount     NUMBER DEFAULT 0
   ,p_is_handchange_premium    NUMBER DEFAULT 0
   ,p_is_handchange_fee        NUMBER DEFAULT 0
   ,p_is_handchange_ins_price  NUMBER DEFAULT 0
   ,p_is_handchange_tariff     NUMBER DEFAULT 0
   ,p_is_handchange_ins_amount NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * �������� ������������ �������� �� ������� �����������
  * @author Denis Ivanov
  * @param p_as_asset_id �� ������� �����������
  */
  PROCEDURE inc_mandatory_covers_by_asset(p_as_asset_id NUMBER);

  /**
  * ��������� �������� ������� �����������
  * @author Patsan O.
  * @param p_asset_id �� ������� �����������
  * @param p_prod_line_id �� ���� ��������
  * @return �� ���������� ��������
  */
  FUNCTION include_cover
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * ������� �������� � ������� �����������
  * @author Patsan O.
  * @param p_cover_id �� ��������, ������� ���������� �������
  */
  PROCEDURE exclude_cover(par_cover_id IN NUMBER);

  /**
  * ����������� ��������� �������� ������� �����������
  * @author Alexander Kalabukhov
  * @param p_old_id �� ������� ����������� ���������
  * @param p_new_id �� ������� ����������� ���������
  */
  PROCEDURE copy_p_cover
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  );

  /**
  * ������� ������ �� ����� ���������� �� ������
  * @author Patsan O.
  * @param p_pol_id �� ������
  * @param p_agent_id �� ������
  */
  PROCEDURE link_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  );

  /**
  * ������� ����� ����� ������� � ����� ���������� �� ������
  * @author Patsan O.
  * @param p_pol_id �� ������
  * @param p_agent_id �� ������
  */
  PROCEDURE unlink_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  );

  /**
  * �������� ���� ���������� � ���� ������, �� ������� ��������� �������� ���� ���������
  * @author Alexander Kalabukhov
  * @param p_p_cover_id �� ��������
  * @return ���� ���������� � ���� ������
  */
  FUNCTION get_policy_confirm_date(p_p_cover_id IN NUMBER) RETURN DATE;

  /**
  * ��������� ����������� �������������� ����������� ����� �������� ��� ���������� ������� �����������
  * @author Denis Ivanov
  * @param p_asset_id �� ������� �����������
  * @param p_prod_line_id �� ����� ��������
  * @param err_msg ��������� � ������� ���������������
  * @return 1 - ����� ��������� ��������, 0 - ������ ��������� ��������
  */
  FUNCTION check_dependences
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER;
  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� ���������.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_common(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ����������� ��������
  * @author Denis Ivanov
  * @param p_p_cover_id �� ��������
  * @param p_decline_date ���� �����������
  * @returm ����� ��������
  */

  FUNCTION decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decline_date DATE
  ) RETURN NUMBER;

  /*
  ���������� ���������� ��������
  */
  PROCEDURE calc_decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  );

  FUNCTION calc_cover_accident_return_sum(p_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION calc_cover_life_per_return_sum(p_p_cover_id NUMBER) RETURN NUMBER;

  FUNCTION calc_cover_adm_exp_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION calc_cover_cash_surr_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_age        NUMBER
  );

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_period_id  IN NUMBER
   ,p_age        NUMBER
  );

  --@Author Marchuk A

  /**
  * ��������� ����������� ���������� �������� ���������� � �������� ����������
  * @author �.�������
  * @param p_asset_id �� ������� �����������
  * @param p_prod_line_id �� ����� ��������
  * @param err_msg ��������� � ������� ���������������
  * @return 1 - ����� ��������� ��������, 0 - ������ ��������� ��������
  */
  FUNCTION check_dependencies_by_clause
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER;

  /**
  * ��������� �������� ������ ������ �� �������� ��� ��������
  * @author Marchuk A
  * @param p_p_cover_id �� ��������
  * @param p_value ������������� ��������
  * @returm ����������� ��������
  */

  FUNCTION round_fee
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER;

  /**
  * ��������� �������� ��������� ����� �� �������� ��� ��������
  * @author Marchuk A
  * @param p_p_cover_id �� ��������
  * @param p_value ������������� ��������
  * @returm ����������� ��������
  */

  FUNCTION round_ins_amount
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER;

  /**
  * @author F.GANICHEV
  */
  FUNCTION cover_copy
  (
    p_old_cover    IN OUT ven_p_cover%ROWTYPE
   ,p_new_asset_id NUMBER
   ,p_is_new       NUMBER
  ) RETURN NUMBER;

  /**
  * �������� ������ �� ��������� ���������
  * @author E.Protsvetov
  * @param p_asset_id �� ������� ����������� � ��������
  * @param p_prod_line_opt_dsc ��������� ���������
  * @returm �������� ������ �� ��������� ���������
  */
  FUNCTION get_cover_tariff
  (
    p_asset_id        NUMBER
   ,p_prod_line_brief VARCHAR2
  ) RETURN NUMBER;

  /**
  * �������� ����� ��������� ���� �� ������ �� � ���� (�������)
  * @author E.Protsvetov
  * @param p_par_policy_id �� �������f
  * @returm ����� ��������� ���� �� ������ �� � ���� (�������)
  */
  FUNCTION calc_amount_imusch_ipoteka(p_par_policy_id NUMBER) RETURN NUMBER;

  FUNCTION calc_new_cover_premium(p_p_cover_id NUMBER) RETURN NUMBER;
  FUNCTION get_cover
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN NUMBER;
  FUNCTION get_new_cover_start
  (
    par_as_asset_id PLS_INTEGER
   ,par_period_id   PLS_INTEGER
  ) RETURN DATE;
  FUNCTION get_new_cover_end
  (
    p_as_asset_id PLS_INTEGER
   ,p_period      PLS_INTEGER
  ) RETURN DATE;
  FUNCTION calc_cover_nonlife_return_sum(p_p_cover_id IN NUMBER) RETURN NUMBER;
  cover_property_cache utils.hashmap_t;

  /*
    ������ �.
    �������� �������� �� ����������, ���������� � ����������, ��� ��������� ���� ���������.
    ���� �������������� ������������� � ��������� �������
  */
  FUNCTION create_cover
  (
    par_as_asset_id              NUMBER
   ,par_prod_line_option_id      NUMBER
   ,par_period_id                NUMBER
   ,par_insured_age              NUMBER
   ,par_start_date               DATE
   ,par_end_date                 DATE
   ,par_ins_price                NUMBER
   ,par_ins_amount               NUMBER
   ,par_fee                      NUMBER
   ,par_premium                  NUMBER
   ,par_is_autoprolongation      NUMBER
   ,par_accum_period_end_age     NUMBER
   ,par_is_handchange_amount     NUMBER DEFAULT 0
   ,par_is_handchange_premium    NUMBER DEFAULT 0
   ,par_is_handchange_fee        NUMBER DEFAULT 0
   ,par_is_handchange_tariff     NUMBER DEFAULT 0
   ,par_is_handchange_ins_amount NUMBER DEFAULT 0
   ,par_is_handchange_k_coef_nm  NUMBER DEFAULT 0
   ,par_is_handchange_s_coef_nm  NUMBER DEFAULT 0
   ,par_is_handchange_deduct     NUMBER DEFAULT 0
   ,par_is_decline_payoff        NUMBER DEFAULT 0
   ,par_is_handchange_ins_price  NUMBER DEFAULT 0
   ,par_is_handchange_start_date NUMBER DEFAULT 0
   ,par_is_decline_charge        NUMBER DEFAULT 0
   ,par_is_decline_comission     NUMBER DEFAULT 0
   ,par_is_handchange_decline    NUMBER DEFAULT 0
   ,par_is_aggregate             NUMBER DEFAULT 0
   ,par_is_proportional          NUMBER DEFAULT 0
   ,par_status_hist_id           NUMBER DEFAULT 1 -- NEW
  ) RETURN NUMBER;

  /* ������ �.
  
     ����������� � ����������� ��������� ���������� �������� ��� �������� �������������� � ��������� ��
  */
  PROCEDURE exclude_cover_group
  (
    par_cover_id  IN NUMBER
   ,par_asset_id  IN NUMBER
   ,par_policy_id IN NUMBER
  );

  /*
    ����� �.
    ��������� �������� ������ �� ������. ������������ � ���������� �������� ��������� �� ����� ����� (�������, ����������)
  */
  PROCEDURE create_cover_from_array
  (
    par_as_asset_id        NUMBER
   ,par_cover_array        t_cover_array DEFAULT t_cover_array()
   ,par_default_fee        NUMBER DEFAULT NULL
   ,par_default_ins_amount NUMBER DEFAULT NULL
   ,par_update_cover_sum   BOOLEAN DEFAULT TRUE
  );

  /*
    ������ �.
    ���������� ���������� �� ������������ ���������
  */
  PROCEDURE update_cover_children(par_policy_id NUMBER);

  /* ����� �.
  �������  ����� "��������" ��� ������� �� ���������*/
  FUNCTION check_period_is_disabled
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
   ,par_period_id       NUMBER
  ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_cover IS

  g_debug BOOLEAN := FALSE;
  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_COVER';

  gv_cover_array t_cover_array;

  gv_current_product_line t_product_line%ROWTYPE;
  gv_current_cover_id     p_cover.p_cover_id%TYPE;
  gc_cover_ent_id CONSTANT entity.ent_id%TYPE := ent.id_by_brief('P_COVER');

  TYPE t_cover_cache IS RECORD(
     cover        p_cover%ROWTYPE
    ,cover_rowid  ROWID
    ,product_line t_product_line%ROWTYPE);

  gv_cover_cache t_cover_cache;

  PROCEDURE refresh_current_prod_line_cash(par_cover_id p_cover.p_cover_id%TYPE) IS
  BEGIN
    IF gv_cover_cache.cover.p_cover_id IS NULL
       OR par_cover_id IS NULL
       OR par_cover_id != gv_cover_cache.cover.p_cover_id
    THEN
      SELECT ROWID INTO gv_cover_cache.cover_rowid FROM p_cover pc WHERE pc.p_cover_id = par_cover_id;
    
      SELECT * INTO gv_cover_cache.cover FROM p_cover pc WHERE pc.rowid = gv_cover_cache.cover_rowid;
    
      SELECT pl.*
        INTO gv_cover_cache.product_line
        FROM t_prod_line_option plo
            ,t_product_line     pl
       WHERE gv_cover_cache.cover.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id;
    END IF;
  END refresh_current_prod_line_cash;

  /*
    ������ �.
    ��������� LOG ������ ������� ����� ��������... ������� �������� ��...
  */
  PROCEDURE log_autonomous
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO p_cover_debug
      (p_cover_id, execution_date, operation_type, debug_message)
    VALUES
      (p_p_cover_id, SYSDATE, 'INS.PKG_COVER', substr(p_message, 1, 4000));
    COMMIT;
  END log_autonomous;

  PROCEDURE log
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    /*PRAGMA AUTONOMOUS_TRANSACTION;*/
  BEGIN
    IF g_debug
    THEN
      /*INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_COVER', SUBSTR(p_message, 1, 4000));*/
      log_autonomous(p_p_cover_id, p_message);
    END IF;
  
    /*COMMIT;*/
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE logcover(p_msg VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    NULL;
    /*insert into tmp_message(text) values (p_msg);
    commit;*/
  END;

  FUNCTION get_status_hist_id_new RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_new;
  END;

  FUNCTION get_status_hist_id_curr RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_curr;
  END;

  FUNCTION get_status_hist_id_del RETURN NUMBER IS
  BEGIN
    RETURN status_hist_id_del;
  END;

  PROCEDURE set_cover_status
  (
    p_p_cover_id   NUMBER
   ,p_status_brief status_hist.brief%TYPE
  ) IS
    v_message VARCHAR2(4000);
  BEGIN
  
    UPDATE p_cover p
       SET p.status_hist_id =
           (SELECT sh.status_hist_id FROM status_hist sh WHERE sh.brief = p_status_brief)
     WHERE p.p_cover_id = p_p_cover_id;
  
  END;

  /**
  * ���������� �������� (���, ��� ��������, ��������) �� ��������� �� ��������
  * @author Denis Ivanov
  * @param p_cover_id �� ��������
  * @param p_deduct_type_id �� ���� �������� ������������
  * @param p_deduct_val_type_id �� ���� �������� �����������
  * @param p_deduct_value �������� ��������
  */
  PROCEDURE calc_deduct
  (
    p_p_cover_id         IN NUMBER
   ,p_deduct_type_id     OUT NUMBER
   ,p_deduct_val_type_id OUT NUMBER
   ,p_deduct_value       OUT NUMBER
  ) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'CALC_DEDUCT';
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                     ,par_trace_subobj_name => vc_proc_name
                     ,par_message           => par_message);
    END trace;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name => 'P_P_COVER_ID', par_trace_var_value => p_p_cover_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    p_deduct_type_id     := NULL;
    p_deduct_val_type_id := NULL;
    p_deduct_value       := NULL;
  
    p_deduct_type_id := utils.get_null(cover_property_cache
                                      ,'DEDUCT_TYPE_' || gv_cover_cache.product_line.id);
    IF p_deduct_type_id IS NULL
    THEN
      trace('����������� ���������� ������ �� ��������');
      SELECT deductible_type_id
            ,deductible_value_type_id
            ,def_val
        INTO p_deduct_type_id
            ,p_deduct_val_type_id
            ,p_deduct_value
        FROM (SELECT dr.deductible_type_id
                    ,dr.deductible_value_type_id
                    ,nvl(pld.default_value, 0) def_val
                FROM t_deductible_rel dr
                JOIN t_prod_line_deduct pld
                  ON pld.deductible_rel_id = dr.t_deductible_rel_id
                 AND pld.product_line_id = gv_cover_cache.product_line.id
               ORDER BY def_val DESC)
       WHERE rownum < 2;
    
      cover_property_cache('DEDUCT_TYPE_' || gv_cover_cache.product_line.id) := p_deduct_type_id;
      cover_property_cache('DEDUCT_VAL_TYPE_' || gv_cover_cache.product_line.id) := p_deduct_val_type_id;
      cover_property_cache('DEDUCT_DEF_' || gv_cover_cache.product_line.id) := p_deduct_value;
    ELSE
      p_deduct_val_type_id := utils.get_null(cover_property_cache
                                            ,'DEDUCT_VAL_TYPE_' || gv_cover_cache.product_line.id);
      p_deduct_value       := utils.get_null(cover_property_cache
                                            ,'DEDUCT_DEF_' || gv_cover_cache.product_line.id);
    END IF;
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  END calc_deduct;

  /**
  * ���������� �������� �� ��������
  * @author �.�������.
  * @param  p_cover_id �� ��������
  * @return �������� �����
  */
  FUNCTION calc_deduct(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_sql             VARCHAR2(4000);
    v_deduct          NUMBER;
    i                 INTEGER;
    c                 INTEGER;
    v_func_id         NUMBER;
    v_deduct_val_type NUMBER;
    v_deduct_val      NUMBER;
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    IF gv_cover_cache.product_line.deduct_func_id IS NOT NULL
    THEN
      v_deduct := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.deduct_func_id
                                          ,gc_cover_ent_id
                                          ,p_p_cover_id);
    ELSE
      calc_deduct(p_p_cover_id, v_deduct_val_type, v_deduct_val, v_deduct);
    END IF;
    RETURN v_deduct;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'�� ������� ������� ������� �������� �� ���������');
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END calc_deduct;

  /**
  * ���������� ������ �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_ins_amount(p_p_cover_id NUMBER) RETURN NUMBER IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'CALC_INS_AMOUNT';
    v_sql              t_product_line.ins_amount_func%TYPE;
    v_ins_amount       NUMBER;
    v_old_ins_amount   p_cover.ins_amount%TYPE;
    i                  INTEGER;
    c                  INTEGER;
    v_func_id          t_product_line.ins_amount_func_id%TYPE;
    v_premia_base_type p_cover.premia_base_type%TYPE;
    v_coef             NUMBER;
    v_tariff           p_cover.tariff%TYPE;
    v_fee              p_cover.fee%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name => 'P_P_COVER_ID', par_trace_var_value => p_p_cover_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    SELECT pc.premia_base_type
          ,pc.tariff
          ,pc.fee
          ,pc.ins_amount
      INTO v_premia_base_type
          ,v_tariff
          ,v_fee
          ,v_old_ins_amount
      FROM p_cover pc
     WHERE pc.p_cover_id = p_p_cover_id;
  
    IF gv_cover_cache.product_line.ins_amount_func IS NOT NULL
    THEN
    
      BEGIN
        c := dbms_sql.open_cursor;
        dbms_sql.parse(c, gv_cover_cache.product_line.ins_amount_func, dbms_sql.native);
        dbms_sql.bind_variable(c, 'p_p_cover_id', p_p_cover_id);
        dbms_sql.bind_variable(c, 'p_ins_amount', v_ins_amount);
        i := dbms_sql.execute(c);
        dbms_sql.variable_value(c, 'p_ins_amount', v_ins_amount);
        dbms_sql.close_cursor(c);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_sql.close_cursor(c);
          RAISE;
      END;
    
    ELSIF gv_cover_cache.product_line.ins_amount_func_id IS NOT NULL
    THEN
    
      v_ins_amount := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.ins_amount_func_id
                                              ,gc_cover_ent_id
                                              ,p_p_cover_id);
    
    ELSIF v_premia_base_type = 1
    THEN
      v_coef := pkg_tariff.calc_tarif_mul(p_p_cover_id);
      assert_deprecated(v_coef IS NULL
                       ,'�������� ������ �� ������������� �� ����������');
    
      BEGIN
        v_ins_amount := v_fee / (v_coef * v_tariff);
      EXCEPTION
        WHEN zero_divide THEN
          ex.raise('������������ ������������� �������� ����� ����');
      END;
    ELSE
      v_ins_amount := v_old_ins_amount;
    END IF;
  
    IF v_ins_amount != 0
    THEN
      v_ins_amount := pkg_cover.round_ins_amount(p_p_cover_id, v_ins_amount);
    END IF;
  
    RETURN v_ins_amount;
  
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise('������ ������� ��������� �����: ' || ex.get_ora_trimmed_errmsg(SQLERRM));
  END;

  FUNCTION calc_ins_price(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_sql       t_product_line.ins_price_func%TYPE;
    v_ins_price NUMBER;
    i           INTEGER;
    c           INTEGER;
    v_func_id   NUMBER;
  BEGIN
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    IF gv_cover_cache.product_line.ins_price_func IS NOT NULL
    THEN
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, gv_cover_cache.product_line.ins_price_func, dbms_sql.native);
      dbms_sql.bind_variable(c, 'p_p_cover_id', p_p_cover_id);
      dbms_sql.bind_variable(c, 'p_ins_price', v_ins_price);
      i := dbms_sql.execute(c);
      dbms_sql.variable_value(c, 'p_ins_price', v_ins_price);
      dbms_sql.close_cursor(c);
    ELSIF gv_cover_cache.product_line.ins_price_func_id IS NOT NULL
    THEN
      v_ins_price := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.ins_price_func_id
                                             ,gc_cover_ent_id
                                             ,p_p_cover_id);
    END IF;
    RETURN v_ins_price;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000
                             ,'������ ������� ��������� ���������');
  END;

  /**
  * ���������� ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_tariff(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_tariff NUMBER;
    i        INTEGER;
    c        INTEGER;
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    IF gv_cover_cache.product_line.tariff_const_value IS NOT NULL
    THEN
      v_tariff := gv_cover_cache.product_line.tariff_const_value;
    ELSIF gv_cover_cache.product_line.tariff_func_id IS NOT NULL
    THEN
      v_tariff := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.tariff_func_id
                                          ,gc_cover_ent_id
                                          ,p_p_cover_id);
      v_tariff := ROUND(v_tariff, nvl(gv_cover_cache.product_line.tariff_func_precision, 6));
      --    ��� ������������� ���������� �� ����� �������� �������������� ���������� ���������� �� �������� ��������
      --    ����� �������� ������������� �������������
    ELSIF gv_cover_cache.product_line.tariff_func IS NOT NULL
    THEN
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, gv_cover_cache.product_line.tariff_func, dbms_sql.native);
      dbms_sql.bind_variable(c, 'p_p_cover_id', p_p_cover_id);
      dbms_sql.bind_variable(c, 'p_tariff', v_tariff);
      i := dbms_sql.execute(c);
      dbms_sql.variable_value(c, 'p_tariff', v_tariff);
      dbms_sql.close_cursor(c);
      v_tariff := ROUND(v_tariff, nvl(gv_cover_cache.product_line.tariff_func_precision, 6));
    END IF;
    RETURN v_tariff;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'�� ������� ������� ������� ������ �� ���������');
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /**
  * ���������� ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_tariff_netto(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_tariff NUMBER;
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    IF gv_cover_cache.product_line.tariff_netto_const_value IS NOT NULL
    THEN
      v_tariff := gv_cover_cache.product_line.tariff_netto_const_value;
    ELSIF gv_cover_cache.product_line.tariff_netto_func_id IS NOT NULL
    THEN
      v_tariff := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.tariff_netto_func_id
                                          ,gc_cover_ent_id
                                          ,p_p_cover_id);
      v_tariff := ROUND(v_tariff, nvl(gv_cover_cache.product_line.tariff_netto_func_precision, 6));
    
    END IF;
    --    ��� ������������� ���������� �� ����� �������� �������������� ���������� ���������� �� �������� ��������
    --����� �������� ������������� �������������
    RETURN v_tariff;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000
                             ,'�� ������� ������� ������� ������ �� ���������');
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /**
  * ���������� ������ �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_premium(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_premium NUMBER;
    i         INTEGER;
    c         INTEGER;
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    --
    BEGIN
      IF gv_cover_cache.product_line.premium_func IS NOT NULL
      THEN
        c := dbms_sql.open_cursor;
        dbms_sql.parse(c, gv_cover_cache.product_line.premium_func, dbms_sql.native);
        dbms_sql.bind_variable(c, 'p_p_cover_id', p_p_cover_id);
        dbms_sql.bind_variable(c, 'p_premium', v_premium);
        i := dbms_sql.execute(c);
        dbms_sql.variable_value(c, 'p_premium', v_premium);
        dbms_sql.close_cursor(c);
      ELSIF gv_cover_cache.product_line.premium_func_id IS NOT NULL
      THEN
        v_premium := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.premium_func_id
                                             ,gc_cover_ent_id
                                             ,p_p_cover_id);
      END IF;
      RETURN v_premium;
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20002
                               ,'�� ������� ������� ������� ������ : p_cover_id ' || p_p_cover_id);
      WHEN OTHERS THEN
        raise_application_error(-20000, SQLERRM);
    END;
  END;

  /**
  * ���������� ������ ����� �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_fee(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
    --
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    RESULT := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.fee_func_id
                                      ,gc_cover_ent_id
                                      ,p_p_cover_id);
  
    RESULT := pkg_cover.round_fee(p_p_cover_id, RESULT);
  
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /**
  * ���������� ������ �� ��������� �� ��������
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_loading(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_loading NUMBER;
    --
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
    --
    IF gv_cover_cache.product_line.loading_const_value IS NOT NULL
    THEN
      v_loading := gv_cover_cache.product_line.loading_const_value;
    ELSIF gv_cover_cache.product_line.loading_func_id IS NOT NULL
    THEN
      -- �� ������� ������ �� ������������ ���� loading_func_precision �� t_product_line
      v_loading := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.loading_func_id
                                           ,gc_cover_ent_id
                                           ,p_p_cover_id);
      --v_loading := pkg_PrdLifeLoading.RECALC_VALUE (v_loading, r_loading.discount_f_id);
    END IF;
    RETURN v_loading;
    --
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /**
  * ���������� ������������� ����������� S
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_s_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    --
    IF gv_cover_cache.product_line.s_coef_nm_func_id IS NOT NULL
    THEN
      RESULT := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.s_coef_nm_func_id
                                        ,gc_cover_ent_id
                                        ,p_p_cover_id);
    END IF;
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /**
  * ���������� ������������� ����������� K
  * @author Denis Ivanov
  * @param  p_cover_id �� ��������
  * @return �������� ������
  */
  FUNCTION calc_k_coef_nm(p_p_cover_id NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    --
    IF gv_cover_cache.product_line.k_coef_nm_func_id IS NOT NULL
    THEN
      RESULT := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.k_coef_nm_func_id
                                        ,gc_cover_ent_id
                                        ,p_p_cover_id);
    END IF;
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, SQLERRM);
  END;

  /*
    ����� �.
    ��������� ���� ������.
    ������������ ��� �������������� ��������
    � ���������� ����� ��������� �������� ������ ��������� �� �������� ��� �� ����� ���������������� �������� �.�. ����� �������� �� ��������
  */
  FUNCTION calc_fee_investment_part(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
    v_fee_investment_part NUMBER;
  BEGIN
    refresh_current_prod_line_cash(par_cover_id => par_cover_id);
  
    IF gv_cover_cache.product_line.fee_investment_part_func_id IS NOT NULL
    THEN
      v_fee_investment_part := pkg_tariff_calc.calc_fun(gv_cover_cache.product_line.fee_investment_part_func_id
                                                       ,gc_cover_ent_id
                                                       ,par_cover_id);
    END IF;
  
    RETURN v_fee_investment_part;
  END calc_fee_investment_part;

  PROCEDURE recalc_cover_tariffs(par_cover_id p_cover.p_cover_id%TYPE) IS
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => par_cover_id);
  
    IF gv_cover_cache.cover.status_hist_id = status_hist_id_del
    THEN
      RETURN;
    END IF;
  
    -- ��������
    --LOG(gv_cover_cache.cover.p_cover_id, 'UPDATE_COVER_SUM DEDUCT_FUNC');
  
    IF nvl(gv_cover_cache.cover.is_handchange_deduct, 0) = 0
    THEN
    
      IF gv_cover_cache.product_line.deduct_func_id IS NOT NULL
      THEN
        gv_cover_cache.cover.deductible_value := pkg_cover.calc_deduct(gv_cover_cache.cover.p_cover_id);
      
        FOR cur IN (SELECT dt.id dt_id
                          ,dv.id dv_id
                      FROM p_cover               pc
                          ,t_deductible_type     dt
                          ,ven_t_deduct_val_type dv
                     WHERE pc.p_cover_id = gv_cover_cache.cover.p_cover_id
                       AND dt.id = pc.t_deductible_type_id
                       AND dv.id = pc.t_deduct_val_type_id)
        LOOP
          gv_cover_cache.cover.t_deductible_type_id := cur.dt_id;
          gv_cover_cache.cover.t_deduct_val_type_id := cur.dv_id;
        END LOOP;
      
        IF gv_cover_cache.cover.t_deductible_type_id IS NULL
           OR gv_cover_cache.cover.t_deduct_val_type_id IS NULL
        THEN
          FOR cur IN (SELECT dt.id dt_id
                            ,dv.id dv_id
                        FROM t_deductible_rel   dr
                            ,t_prod_line_deduct d
                            ,t_product_line     pl
                            ,t_deductible_type  dt
                            ,t_deduct_val_type  dv
                       WHERE pl.id = gv_cover_cache.product_line.id
                         AND dr.t_deductible_rel_id = d.deductible_rel_id
                         AND d.product_line_id = pl.id
                         AND dt.id = dr.deductible_type_id
                         AND dv.id = dr.deductible_value_type_id
                       ORDER BY d.is_default DESC)
          LOOP
            gv_cover_cache.cover.t_deductible_type_id := cur.dt_id;
            gv_cover_cache.cover.t_deduct_val_type_id := cur.dv_id;
            EXIT;
          END LOOP;
        END IF;
      
      ELSE
        calc_deduct(gv_cover_cache.cover.p_cover_id
                   ,gv_cover_cache.cover.t_deductible_type_id
                   ,gv_cover_cache.cover.t_deduct_val_type_id
                   ,gv_cover_cache.cover.deductible_value);
      END IF;
    
      UPDATE p_cover c
         SET c.t_deductible_type_id = gv_cover_cache.cover.t_deductible_type_id
            ,c.t_deduct_val_type_id = gv_cover_cache.cover.t_deduct_val_type_id
            ,c.deductible_value     = gv_cover_cache.cover.deductible_value
       WHERE c.rowid = gv_cover_cache.cover_rowid;
    END IF;
  
    -- ����� �����
    --������� �� �������� �������� �.
    --gv_cover_cache.cover.tariff := pkg_tariff.calc_cover_coef(gv_cover_cache.cover.p_cover_id);
  
    IF (gv_cover_cache.product_line.tariff_netto_func_id IS NOT NULL OR
       gv_cover_cache.product_line.tariff_netto_const_value IS NOT NULL)
       AND gv_cover_cache.cover.is_handchange_tariff = 0
    THEN
      gv_cover_cache.cover.tariff_netto := calc_tariff_netto(gv_cover_cache.cover.p_cover_id);
    
      UPDATE p_cover c
         SET c.tariff_netto = gv_cover_cache.cover.tariff_netto
       WHERE c.rowid = gv_cover_cache.cover_rowid;
    END IF;
  
    --
  
    --LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_K_COEF_NM');
  
    IF gv_cover_cache.product_line.k_coef_nm_func_id IS NOT NULL
       AND gv_cover_cache.cover.is_handchange_k_coef_nm = 0
    THEN
    
      --LOG(gv_cover_cache.cover.p_cover_id, 'CALC_K_COEF_NM');
    
      gv_cover_cache.cover.k_coef_nm := calc_k_coef_nm(gv_cover_cache.cover.p_cover_id);
    
      --LOG(gv_cover_cache.cover.p_cover_id, 'CALC_K_COEF_NM RESULT ' || gv_cover_cache.cover.k_coef_nm);
    
      UPDATE p_cover c
         SET c.k_coef_nm = gv_cover_cache.cover.k_coef_nm
       WHERE c.rowid = gv_cover_cache.cover_rowid;
    
    END IF;
  
    --LOG(p_p_cover_id, 'UPDATE_COVER_SUM CALC_S_COEF_NM');
  
    IF gv_cover_cache.product_line.s_coef_nm_func_id IS NOT NULL
       AND gv_cover_cache.cover.is_handchange_s_coef_nm = 0
    THEN
    
      --LOG(gv_cover_cache.cover.p_cover_id, 'CALC_S_COEF_NM');
    
      gv_cover_cache.cover.s_coef_nm := calc_s_coef_nm(gv_cover_cache.cover.p_cover_id);
    
      --LOG(gv_cover_cache.cover.p_cover_id, 'CALC_S_COEF_NM RESULT ' || gv_cover_cache.cover.s_coef_nm);
    
      UPDATE p_cover c
         SET c.s_coef_nm = gv_cover_cache.cover.s_coef_nm
       WHERE c.rowid = gv_cover_cache.cover_rowid;
    
    END IF;
  
    gv_cover_cache.cover.rvb_value      := calc_loading(p_p_cover_id => gv_cover_cache.cover.p_cover_id);
    gv_cover_cache.cover.normrate_value := pkg_productlifeproperty.calc_normrate_value(p_cover_id => gv_cover_cache.cover.p_cover_id);
  
    UPDATE p_cover c
       SET c.rvb_value      = gv_cover_cache.cover.rvb_value
          ,c.normrate_value = nvl(gv_cover_cache.cover.normrate_value, c.normrate_value)
     WHERE c.rowid = gv_cover_cache.cover_rowid;
  
    -- �����
    --������� �� �������� �������� �.
    --gv_cover_cache.cover.tariff := pkg_tariff.calc_cover_coef(gv_cover_cache.cover.p_cover_id);
  
    IF (gv_cover_cache.product_line.tariff_func IS NOT NULL OR
       gv_cover_cache.product_line.tariff_func_id IS NOT NULL OR
       gv_cover_cache.product_line.tariff_const_value IS NOT NULL)
       AND nvl(gv_cover_cache.cover.is_handchange_tariff, 0) = 0
    THEN
      gv_cover_cache.cover.tariff := calc_tariff(gv_cover_cache.cover.p_cover_id);
      UPDATE p_cover c
         SET c.tariff = gv_cover_cache.cover.tariff
       WHERE c.rowid = gv_cover_cache.cover_rowid;
    END IF;
  
  END recalc_cover_tariffs;

  PROCEDURE update_cover_sum(p_p_cover_id NUMBER) IS
    v_pl_id       NUMBER;
    v_pl_name     VARCHAR2(200);
    v_ins_var_id  NUMBER;
    v_prod_brief  VARCHAR2(1000);
    v_recalc_flag VARCHAR2(100);
    v_coef        NUMBER;
    v_result      NUMBER;
    v_base_sum    NUMBER;
  BEGIN
  
    refresh_current_prod_line_cash(par_cover_id => p_p_cover_id);
  
    IF gv_cover_cache.cover.status_hist_id = status_hist_id_del
    THEN
      RETURN;
    END IF;
  
    recalc_cover_tariffs(par_cover_id => p_p_cover_id);
  
    SELECT pr.brief
          ,p.base_sum
      INTO v_prod_brief
          ,v_base_sum
      FROM t_product    pr
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
          ,p_cover      pc
     WHERE a.as_asset_id = pc.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND ph.policy_header_id = p.pol_header_id
       AND pc.p_cover_id = p_p_cover_id
       AND pr.product_id = ph.product_id;
  
    IF gv_cover_cache.cover.status_hist_id = status_hist_id_del
    THEN
      RETURN;
    END IF;
  
    -- ��������������� ������ ��������� ��� ������� 
    IF nvl(gv_cover_cache.cover.premia_base_type, 0) = 0
    THEN
      IF nvl(gv_cover_cache.cover.is_handchange_amount, 0) = 0
         AND nvl(gv_cover_cache.cover.is_handchange_ins_amount, 0) = 0
      THEN
        IF (gv_cover_cache.product_line.ins_amount_func_id IS NOT NULL OR
           gv_cover_cache.product_line.ins_amount_func IS NOT NULL)
           AND (gv_cover_cache.product_line.pre_calc_ins_amount = 1 OR v_base_sum IS NOT NULL)
        THEN
        
          gv_cover_cache.cover.ins_amount := calc_ins_amount(gv_cover_cache.cover.p_cover_id);
          UPDATE p_cover c
             SET c.ins_amount = gv_cover_cache.cover.ins_amount
           WHERE c.rowid = gv_cover_cache.cover_rowid;
        
        END IF;
      
        v_coef := pkg_tariff.calc_cover_coef(gv_cover_cache.cover.p_cover_id);
      
      END IF;
    
      IF (gv_cover_cache.product_line.fee_func_id IS NOT NULL)
         AND (gv_cover_cache.cover.is_handchange_fee = 0)
      THEN
      
        gv_cover_cache.cover.fee := calc_fee(gv_cover_cache.cover.p_cover_id);
        UPDATE p_cover c
           SET c.fee = gv_cover_cache.cover.fee
         WHERE c.rowid = gv_cover_cache.cover_rowid;
      
      END IF;
    
    ELSE
      IF nvl(gv_cover_cache.cover.is_handchange_fee, 0) = 0
         AND gv_cover_cache.product_line.fee_func_id IS NOT NULL
         AND (gv_cover_cache.product_line.pre_calc_fee = 1 OR v_base_sum IS NOT NULL)
      THEN
      
        gv_cover_cache.cover.fee := calc_fee(gv_cover_cache.cover.p_cover_id);
        UPDATE p_cover c
           SET c.fee = gv_cover_cache.cover.fee
         WHERE c.rowid = gv_cover_cache.cover_rowid;
      
      END IF;
    
      IF nvl(gv_cover_cache.cover.is_handchange_amount, 0) = 0
         AND nvl(gv_cover_cache.cover.is_handchange_ins_amount, 0) = 0
      THEN
        --���� ��������� �������� � ���, ��� ����������� ������ �������������� � ���� ������.
        v_coef := pkg_tariff.calc_cover_coef(gv_cover_cache.cover.p_cover_id);
      
        gv_cover_cache.cover.ins_amount := calc_ins_amount(gv_cover_cache.cover.p_cover_id);
        UPDATE p_cover c
           SET c.ins_amount = gv_cover_cache.cover.ins_amount
         WHERE c.rowid = gv_cover_cache.cover_rowid;
      
      END IF;
    
    END IF;
  
    -- ������
    --���������� �.���������� (����� "change")
    -- if v_ins_var_id is null then --"change"
    IF ((gv_cover_cache.product_line.premium_func IS NOT NULL OR
       gv_cover_cache.product_line.premium_func_id IS NOT NULL) AND
       gv_cover_cache.cover.is_handchange_premium = 0)
    THEN
      --if (v_product_line.premium_func is not null)  then
      gv_cover_cache.cover.premium := calc_premium(gv_cover_cache.cover.p_cover_id);
    END IF;
  
    IF nvl(gv_cover_cache.cover.ins_amount, 0) <> 0
       AND gv_cover_cache.cover.is_handchange_premium = 0
    THEN
      IF gv_cover_cache.cover.tariff IS NULL
         AND gv_cover_cache.cover.premium IS NOT NULL
      THEN
        gv_cover_cache.cover.tariff := ROUND(gv_cover_cache.cover.premium /
                                             gv_cover_cache.cover.ins_amount * 100
                                            ,10);
      ELSIF gv_cover_cache.cover.premium IS NULL
            AND gv_cover_cache.cover.tariff IS NOT NULL
      THEN
        gv_cover_cache.cover.premium := ROUND(gv_cover_cache.cover.ins_amount *
                                              gv_cover_cache.cover.tariff / 100
                                             ,2);
      END IF;
    
      --�������� �.�. ����� �� ���� ���������� ������ � ������ ���� �������� �� �����        
      IF (gv_cover_cache.product_line.premium_func IS NULL AND
         gv_cover_cache.product_line.premium_func_id IS NULL)
      THEN
        gv_cover_cache.cover.premium := pkg_premium_calc.standart_premium(gv_cover_cache.cover.p_cover_id);
      END IF;
    END IF;
  
    UPDATE p_cover c
       SET c.tariff  = gv_cover_cache.cover.tariff
          ,c.premium = gv_cover_cache.cover.premium
     WHERE c.rowid = gv_cover_cache.cover_rowid;
  
  END update_cover_sum;

  FUNCTION link_cover_agent
  (
    p_cover_id NUMBER
   ,p_agent_id NUMBER
  ) RETURN NUMBER IS
    v_ret_val               NUMBER;
    v_ag_prod_line_contr_id NUMBER;
    v_rate                  ag_rate%ROWTYPE;
  BEGIN
    v_ret_val := NULL;
    -- opatsan
    -- �������������� p_cover_agent
    -- ��� 1208
    -- ����� ��� ������������ ����������� ����� ����� ��������� � �������
  
    /*
    -- begin
    -- �������� ������������� �����
    BEGIN
      SELECT ca.cover_agent_id
        INTO v_ret_val
        FROM P_COVER_AGENT ca
       WHERE ca.cover_id = p_cover_id
         AND ca.agent_id = p_agent_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    
    IF p_agent_id IS NOT NULL AND p_cover_id IS NOT NULL AND
       v_ret_val IS NULL THEN
      -- ������� ����� ������ ������ ��� ������
      v_ag_prod_line_contr_id := Pkg_Agent.get_agent_rate_by_cover(p_cover_id,
                                                                   p_agent_id,
                                                                   SYSDATE);
      IF v_ag_prod_line_contr_id IS NOT NULL THEN
        SELECT r.*
          INTO v_rate
          FROM AG_PROD_LINE_CONTR a, AG_RATE r
         WHERE a.ag_prod_line_contr_id = v_ag_prod_line_contr_id
           AND a.ag_rate_id = r.ag_rate_id;
    
        -- �������� ������
        SELECT sq_ag_rate.NEXTVAL INTO v_rate.ag_rate_id FROM dual;
        INSERT INTO AG_RATE VALUES v_rate;
    
        -- ��������� �������� � ���������� ���������� ��������
        SELECT sq_p_cover_agent.NEXTVAL INTO v_ret_val FROM dual;
        INSERT INTO P_COVER_AGENT
          (cover_agent_id,
           cover_id,
           agent_id,
           rate_id,
           rate_value,
           ag_prod_line_contr_id)
          SELECT v_ret_val,
                 p_cover_id,
                 p_agent_id,
                 v_rate.ag_rate_id,
                 v_rate.value,
                 v_ag_prod_line_contr_id
            FROM dual;
      ELSE
        -- todo: ������-�� ������ �������� ����� �������� � ��������, �������
        -- �������� �����. ����� �� ���� ����� ��������� ��������, ��� �������� ��
        -- ���������� ������ � ��� ��������� ��������. (���� ������� ����� � �.�.)
        NULL;
      END IF;
    END IF;
    
    */
  
    RETURN v_ret_val;
    /*  exception
        when others then
          null;
      end;
    */
  END;

  FUNCTION get_new_cover_start
  (
    par_as_asset_id PLS_INTEGER
   ,par_period_id   PLS_INTEGER
  ) RETURN DATE IS
    proc_name CONSTANT VARCHAR2(25) := 'get_new_cover_start';
    v_val         NUMBER;
    v_val_from    NUMBER;
    v_name        VARCHAR2(100);
    v_insured_dob DATE;
    RESULT        DATE;
  BEGIN
    IF par_as_asset_id IS NULL
       OR par_period_id IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    SELECT tp.period_value_from
      INTO v_val_from
      FROM t_period      tp
          ,t_period_type tpt
     WHERE tp.id = par_period_id
       AND tpt.id = tp.period_type_id;
  
    SELECT trunc(cp.date_of_birth)
          ,trunc(pp.start_date)
      INTO v_insured_dob
          ,RESULT
      FROM ven_as_assured aa
          ,cn_person      cp
          ,p_policy       pp
     WHERE aa.as_assured_id = par_as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND cp.contact_id = aa.assured_contact_id;
  
    IF v_val_from IS NOT NULL
    THEN
      RESULT := ADD_MONTHS(v_insured_dob, v_val_from * 12);
    END IF;
  
    RETURN RESULT;
  
  END get_new_cover_start;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.01.2011 17:10:53
  -- Purpose : �������� ���� ��������� �������� �� ������� � ���������������
  FUNCTION get_new_cover_end
  (
    p_as_asset_id PLS_INTEGER
   ,p_period      PLS_INTEGER
  ) RETURN DATE IS
    proc_name     VARCHAR2(25) := 'get_new_cover_end';
    v_val         NUMBER;
    v_val_to      NUMBER;
    v_val_from    NUMBER;
    v_insured_dob DATE;
    v_start_date  DATE;
    v_name        VARCHAR2(100);
    v_end_date    DATE;
    v_one_sec     NUMBER := 1 / 24 / 3600;
  BEGIN
    IF p_period IS NULL
       OR p_as_asset_id IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    SELECT tp.period_value_to
          ,tp.period_value_from
          ,tp.period_value
          ,tpt.description
      INTO v_val_to
          ,v_val_from
          ,v_val
          ,v_name
      FROM t_period      tp
          ,t_period_type tpt
     WHERE tp.id = p_period
       AND tpt.id = tp.period_type_id;
  
    SELECT trunc(aa.end_date)
          ,trunc(pp.start_date)
          ,trunc(cp.date_of_birth)
      INTO v_end_date
          ,v_start_date
          ,v_insured_dob
      FROM ven_as_assured aa
          ,cn_person      cp
          ,p_policy       pp
     WHERE aa.as_assured_id = p_as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND cp.contact_id = aa.assured_contact_id;
  
    IF v_name = '������'
    THEN
      RETURN v_end_date + 1 - v_one_sec;
    END IF;
  
    IF v_val_to IS NOT NULL
    THEN
    
      v_end_date := ADD_MONTHS(v_insured_dob, (v_val_to + 1) * 12) - v_one_sec;
    
      RETURN v_end_date;
    END IF;
  
    IF v_val IS NOT NULL
    THEN
      IF v_val_from IS NOT NULL
      THEN
        v_start_date := get_new_cover_start(p_as_asset_id, p_period);
      END IF;
    
      CASE v_name
        WHEN '���' THEN
          v_end_date := v_start_date + v_val - v_one_sec;
        WHEN '������' THEN
          v_end_date := ADD_MONTHS(v_start_date, v_val) - v_one_sec;
        WHEN '����' THEN
          IF to_char(trunc(v_start_date), 'ddmm') = '2902'
          THEN
            v_end_date := ADD_MONTHS(v_start_date + 1, v_val * 12) - v_one_sec;
          ELSE
            v_end_date := ADD_MONTHS(v_start_date, v_val * 12) - v_one_sec;
          END IF;
        ELSE
          NULL;
      END CASE;
    ELSE
      IF v_val_from IS NULL
      THEN
        v_end_date := NULL;
      ELSE
        v_end_date := v_end_date + 1 - v_one_sec;
      END IF;
    END IF;
  
    RETURN(v_end_date);
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'������ ��� ���������� ' || proc_name || SQLERRM);
  END get_new_cover_end;

  FUNCTION check_period_is_disabled
  (
    par_asset_id        NUMBER
   ,par_product_line_id NUMBER
   ,par_period_id       NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(plp.is_disabled, 0)
        INTO RESULT
        FROM t_prod_line_period plp
            ,t_period_use_type  put
       WHERE plp.period_id = par_period_id
         AND plp.product_line_id = par_product_line_id
         AND plp.t_period_use_type_id = put.t_period_use_type_id
         AND put.brief IN ('���� �����������'
                          ,'���� ����������� �� ������� �����������')
         AND plp.is_disabled = 1
         AND pkg_cover_control.check_cover_period_control(par_asset_id, plp.control_func_id) = 1; -- ���������
    EXCEPTION
      WHEN no_data_found THEN
        RESULT := 0;
    END;
  
    RETURN RESULT;
  
  END check_period_is_disabled;

  /**
  * �������� ������ �������� �� ������� ����������� � ����� � ��������
  * @author Denis Ivanov
  * @param p_t_product_line_id �� ����� � ��������
  * @param p_as_asset_id �� ������� �����������
  * @return �� ������ ��������
  *
  * 16,01,2007 ���������� �.�.
  * �������� ������ ������� ����������� � ����� �������������������
  *
  * 18/01/2011 �������� �.�.
  * ������ ����������� 
  * + ������� �������� ������� �� ����� 
  * + ������� ������� ������ �������� � ��������/�����
  * 
  */
  FUNCTION cre_new_cover
  (
    p_as_asset_id              IN NUMBER
   ,p_t_product_line_id        IN NUMBER
   ,p_update_asset             IN BOOLEAN DEFAULT TRUE
   ,p_start_date               DATE DEFAULT NULL
   ,p_end_date                 DATE DEFAULT NULL
   ,p_period_id                NUMBER DEFAULT NULL
   ,p_fee                      NUMBER DEFAULT NULL
   ,p_ins_amount               NUMBER DEFAULT NULL
   ,p_is_autoprolongation      NUMBER DEFAULT NULL
   ,p_premia_base_type         NUMBER DEFAULT 0
   ,p_status_hist_id           NUMBER DEFAULT NULL
   ,p_is_handchange_amount     NUMBER DEFAULT 0
   ,p_is_handchange_premium    NUMBER DEFAULT 0
   ,p_is_handchange_fee        NUMBER DEFAULT 0
   ,p_is_handchange_ins_price  NUMBER DEFAULT 0
   ,p_is_handchange_tariff     NUMBER DEFAULT 0
   ,p_is_handchange_ins_amount NUMBER DEFAULT 0
    
  ) RETURN NUMBER IS
  
    v_product_line          t_product_line%ROWTYPE;
    v_product_line_desc     t_product_line.description%TYPE;
    v_cover                 p_cover%ROWTYPE;
    v_agent_id              NUMBER;
    v_ag_prod_line_contr_id NUMBER;
    v_policy_period         PLS_INTEGER;
    v_disabled_period       PLS_INTEGER;
    v_prod_line_period      PLS_INTEGER;
    v_period_to     PLS_INTEGER;
    v_contact_name  contact.obj_name_orig%TYPE;
    v_is_invres     NUMBER;
    v_end_invres    NUMBER;
    v_start_invres  DATE;
    v_one_sec       NUMBER := 1 / 24 / 3600;
    v_ins_premium   NUMBER;
    v_is_group_flag ins.p_policy.is_group_flag%TYPE;
  
  BEGIN
  
    pkg_cover_control.precreation_cover_control(par_asset_id        => p_as_asset_id
                                               ,par_product_line_id => p_t_product_line_id);
  
    /**/
    SELECT (CASE
             WHEN lb.brief = 'PEPR_INVEST_RESERVE' THEN
              1
             ELSE
              0
           END)
      INTO v_is_invres
      FROM ins.t_product_line pl
          ,ins.t_lob_line     lb
     WHERE pl.id = p_t_product_line_id
       AND pl.t_lob_line_id = lb.t_lob_line_id;
    -- ������������� �������� ��������� �������� �� ���������
    -- ��
    SELECT sq_p_cover.nextval INTO v_cover.p_cover_id FROM dual;
  
    v_cover.ent_id := ent.id_by_brief('P_COVER');
  
    v_cover.status_hist_id := nvl(p_status_hist_id, status_hist_id_new);
  
    -- ������� ���������������, �� ������ �����
    SELECT nvl(p_is_autoprolongation, a.is_avtoprolongation)
          ,a.id
      INTO v_cover.is_avtoprolongation
          ,v_cover.t_prod_line_option_id
      FROM (SELECT pl.is_avtoprolongation
                  ,plo.id
              FROM t_product_line     pl
                  ,t_prod_line_option plo
             WHERE pl.id = p_t_product_line_id
               AND pl.id = plo.product_line_id
             ORDER BY plo.default_flag
                     ,plo.option_id) a
     WHERE rownum = 1; --������ ������ ����� ���� �� 1
  
    --������ ����������� ��� � �������, ������ ����������� ��������
    SELECT trunc(MONTHS_BETWEEN(ass.start_date, cp.date_of_birth) / 12)
          ,p_as_asset_id
          ,pp.period_id
          ,pp.start_date
          ,pp.is_group_flag
      INTO v_cover.insured_age
          ,v_cover.as_asset_id
          ,v_policy_period
          ,v_cover.start_date
          ,v_is_group_flag
      FROM ven_as_assured      ass
          ,cn_person           cp
          ,p_policy            pp
          ,v_pol_issuer        pi
          ,t_as_type_prod_line atpl
          ,p_asset_header      ah
     WHERE ass.as_assured_id = p_as_asset_id
       AND decode(atpl.is_insured, 1, pi.contact_id, ass.assured_contact_id) = cp.contact_id
       AND pp.policy_id = ass.p_policy_id
       AND pp.policy_id = pi.policy_id
       AND ass.p_asset_header_id = ah.p_asset_header_id
       AND ah.t_asset_type_id = atpl.asset_common_type_id
       AND atpl.product_line_id = p_t_product_line_id;
  
    -- ����� �.
    -- ����� ������� � ��������������� ��������� ������������ ������� �� ���� control_func_id
    -- ������ ���� ����� NULL
    -- ���� ������ ���������� ����� ���������, �� ���������� ��� ����������� ��������� �������:
    -- ���� ������ ������� �������� �������, �� ������� ������� �������� � ����� ��������,
    -- � ����� �������� �� ���� ������ ������� ������������ ����������
    -- ���� �������� �������� - ������ rollback
  
    IF p_period_id IS NOT NULL
    THEN
    
      IF check_period_is_disabled(p_as_asset_id, p_t_product_line_id, p_period_id) = 1
      THEN
        raise_application_error(-20001
                               ,'�� �������� ������� ��������� � ������ ��������');
      ELSE
        v_cover.end_date  := get_new_cover_end(p_as_asset_id, p_period_id);
        v_cover.period_id := p_period_id;
      END IF;
    
    ELSE
      -- �������� ������������ ������ ����������� ����������� �������� �����������
      -- ��������� �������� �� ������ ������
      -- ��������� ������ �� �������� � ������ 
      -- ����������� ��� ������ ��������� ��������
    
      -- �������� ��� ������������� ������� �� ��������
      -- ����� �������� ��� ������������� ������� �� ���������
      -- �������� ��, ������� ���������� ������ ������ ��������
      --����������
      --������� ������ ������� �� ��������� �� ���������, 
      --����� ���, ������� ����� ����� � ���������
      --����� �� �������
      BEGIN
        SELECT id
          INTO v_prod_line_period
          FROM (SELECT id
                  FROM (SELECT tp.id
                               --,pt.is_default --����������� �� 280922 /������/
                              ,0 is_default --������� �� 280922 /������/
                              ,pt.sort_order
                          FROM t_period          tp
                              ,t_period_use_type put
                              ,t_product_period  pt
                              ,p_pol_header      ph
                              ,p_policy          pp
                              ,as_asset          aa
                         WHERE aa.as_asset_id = p_as_asset_id
                           AND aa.p_policy_id = pp.policy_id
                           AND pp.pol_header_id = ph.policy_header_id
                           AND ph.product_id = pt.product_id
                           AND tp.id = pt.period_id
                           AND put.t_period_use_type_id = pt.t_period_use_type_id
                           AND put.name IN ('���� �����������'
                                           ,'���� ����������� �� ������� �����������')
                           AND check_period_is_disabled(p_as_asset_id, p_t_product_line_id, tp.id) = 0
                        UNION
                        SELECT p.id
                              ,plp.is_default
                              ,p.sort_order
                          FROM t_period_use_type  put
                              ,t_period           p
                              ,t_prod_line_period plp
                              ,t_product_line     pl
                         WHERE pl.id = p_t_product_line_id
                           AND plp.product_line_id = pl.id
                           AND p.id = plp.period_id
                           AND put.t_period_use_type_id = plp.t_period_use_type_id
                           AND put.brief IN ('���� �����������'
                                            ,'���� ����������� �� ������� �����������')
                           AND plp.is_disabled = 0
                           AND pkg_cover_control.check_cover_period_control(p_as_asset_id
                                                                           ,plp.control_func_id) = 1) t
                      ,as_asset aa
                      ,p_policy pp
                 WHERE get_new_cover_end(aa.as_asset_id, t.id) <=
                       get_new_cover_end(aa.as_asset_id, v_policy_period)
                   AND get_new_cover_start(aa.as_asset_id, t.id) >= trunc(pp.start_date)
                   AND aa.as_asset_id = p_as_asset_id
                   AND aa.p_policy_id = pp.policy_id
                 ORDER BY t.is_default DESC
                         ,greatest((get_new_cover_end(aa.as_asset_id, v_policy_period) -
                                   get_new_cover_end(aa.as_asset_id, t.id))
                                  ,0) +
                          greatest(get_new_cover_start(aa.as_asset_id, t.id) - trunc(pp.start_date), 0) ASC /*DESC*/ --/������ ������� DESC �� ASC/278207 FW: �� ������: ������ ��� ���������� ������� "�������������� � ���������" /
                          
                         ,t.sort_order)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
    
      --��� ������� ������
      IF v_prod_line_period IS NULL
      THEN
        raise_application_error(-20001
                               ,'�� ������� ���������� ������ ��� ���������');
      ELSIF v_prod_line_period = v_policy_period
      THEN
        --������� �����
        --� ���� ������ �������� ������ � ��������
        v_cover.end_date   := get_new_cover_end(p_as_asset_id, v_policy_period);
        v_cover.start_date := get_new_cover_start(p_as_asset_id, v_policy_period);
        v_cover.period_id  := v_policy_period;
      ELSE
        v_cover.end_date   := get_new_cover_end(p_as_asset_id, v_prod_line_period);
        v_cover.start_date := get_new_cover_start(p_as_asset_id, v_prod_line_period);
        v_cover.period_id  := v_prod_line_period;
      END IF;
    
    END IF; --if p_period_id is not null
  
    IF v_is_invres > 0
    THEN
      SELECT SUM(pc.premium)
        INTO v_ins_premium
        FROM ins.p_cover     pc
            ,ins.status_hist st
       WHERE pc.as_asset_id = p_as_asset_id
         AND st.status_hist_id = pc.status_hist_id
         AND st.brief != 'DELETED'
         AND pc.p_cover_id != v_cover.p_cover_id;
      v_cover.premium := v_ins_premium;
      v_cover.fee     := v_ins_premium;
    
    END IF;
  
    SELECT tp.period_value_to
      INTO v_cover.accum_period_end_age
      FROM t_period tp
     WHERE tp.id = v_cover.period_id;
  
    -- ���� ��������������� �� ������� �� ��� ���������
    IF v_cover.is_avtoprolongation = 1
    THEN
      v_cover.end_date := least(v_cover.end_date, ADD_MONTHS(v_cover.start_date, 12) - 1 / 24 / 3600);
    END IF;
  
    /**/
    IF p_start_date IS NOT NULL
    THEN
      v_cover.start_date := p_start_date;
    END IF;
    IF p_end_date IS NOT NULL
    THEN
      v_cover.end_date := p_end_date;
    END IF;
    /**/
  
    --������ �������������� ������� ����������/��� ���������� �������� �� ����������� ������� ��������� ������ end_date < start_date /
    IF v_cover.start_date > v_cover.end_date
    THEN
      v_cover.end_date := v_cover.start_date;
    END IF; --end_������
  
    -- ����������� ��������� ����� � ������������ ���������
    IF p_ins_amount IS NULL
    THEN
      FOR cur IN (SELECT pc.p_cover_id
                        ,pc.ins_amount
                    FROM parent_prod_line   ppl
                        ,t_prod_line_option plo
                        ,p_cover            pc
                   WHERE pc.as_asset_id = p_as_asset_id
                     AND plo.id = pc.t_prod_line_option_id
                     AND ppl.t_prod_line_id = p_t_product_line_id
                     AND plo.product_line_id = ppl.t_parent_prod_line_id
                     AND ppl.is_parent_ins_amount = 1)
      LOOP
        v_cover.ins_amount := cur.ins_amount;
      END LOOP;
    ELSE
      v_cover.ins_amount := p_ins_amount;
    END IF;
  
    v_cover.fee              := nvl(p_fee, v_cover.fee);
    v_cover.premia_base_type := coalesce(p_premia_base_type, v_cover.premia_base_type, 0);
  
    v_cover.is_handchange_amount     := coalesce(p_is_handchange_amount
                                                ,v_cover.is_handchange_amount
                                                ,0);
    v_cover.is_handchange_premium    := coalesce(p_is_handchange_premium
                                                ,v_cover.is_handchange_premium
                                                ,0);
    v_cover.is_handchange_fee        := coalesce(p_is_handchange_fee, v_cover.is_handchange_fee, 0);
    v_cover.is_handchange_ins_price  := coalesce(p_is_handchange_ins_price
                                                ,v_cover.is_handchange_ins_price
                                                ,0);
    v_cover.is_handchange_tariff     := coalesce(p_is_handchange_tariff
                                                ,v_cover.is_handchange_tariff
                                                ,0);
    v_cover.is_handchange_ins_amount := coalesce(p_is_handchange_ins_amount
                                                ,v_cover.is_handchange_ins_amount
                                                ,0);
  
    INSERT INTO p_cover
      (p_cover_id
      ,as_asset_id
      ,t_prod_line_option_id
      ,period_id
      ,start_date
      ,end_date
      ,ins_price
      ,ins_amount
      ,fee
      ,status_hist_id
      ,is_avtoprolongation
      ,accum_period_end_age
      ,insured_age
      ,premia_base_type
      ,is_handchange_amount
      ,is_handchange_premium
      ,is_handchange_fee
      ,is_handchange_ins_price
      ,is_handchange_tariff
      ,is_handchange_ins_amount)
    VALUES
      (v_cover.p_cover_id
      ,v_cover.as_asset_id
      ,v_cover.t_prod_line_option_id
      ,v_cover.period_id
      ,v_cover.start_date
      ,v_cover.end_date
      ,v_cover.ins_price
      ,v_cover.ins_amount
      ,v_cover.fee
      ,v_cover.status_hist_id
      ,v_cover.is_avtoprolongation
      ,v_cover.accum_period_end_age
      ,v_cover.insured_age
      ,v_cover.premia_base_type
      ,v_cover.is_handchange_amount
      ,v_cover.is_handchange_premium
      ,v_cover.is_handchange_fee
      ,v_cover.is_handchange_ins_price
      ,v_cover.is_handchange_tariff
      ,v_cover.is_handchange_ins_amount);
  
    --���������� ������������ ���� ��������� ��������
  
    /*      SELECT MAX (c.end_date)  
            INTO v_cover.end_date
            FROM P_COVER c
           WHERE c.as_asset_id = p_as_asset_id;
      
          UPDATE AS_ASSET a
             SET a.end_date=v_cover.end_date
           WHERE a.as_asset_id = p_as_asset_id;
    */
    -- ������ �.
    -- ��������� ������ ��������, ��� ����� ��� ��� ����
    IF p_update_asset
    THEN
    
      UPDATE ven_as_asset a
         SET /*(a.start_date, a.end_date) =
                                                                                                                                                                                                                                                                                                                                                                      (SELECT MIN(c.start_date)
                                                                                                                                                                                                                                                                                                                                                                             ,MAX(c.end_date)
                                                                                                                                                                                                                                                                                                                                                                         FROM p_cover c
                                                                                                                                                                                                                                                                                                                                                                                       WHERE c.as_asset_id = a.as_asset_id)*/
             --������� ���� ������ ��������� �� ������ 282426 /������/
               a.start_date = pkg_asset.get_asset_start_date(a.as_asset_id
                                                            ,a.p_asset_header_id
                                                            ,v_is_group_flag)
            ,a.end_date   = pkg_asset.get_asset_end_date(p_as_asset_id)
       WHERE a.as_asset_id = p_as_asset_id;
    END IF;
  
    RETURN(v_cover.p_cover_id);
  EXCEPTION
    WHEN pkg_cover_control.ex_precreation_cover_control THEN
      log(-1, SQLERRM);
      RAISE;
    WHEN dup_val_on_index THEN
      SELECT co.obj_name_orig
        INTO v_contact_name
        FROM as_asset   se
            ,as_assured su
            ,contact    co
       WHERE se.as_asset_id = p_as_asset_id
         AND se.as_asset_id = su.as_assured_id
         AND su.assured_contact_id = co.contact_id;
    
      SELECT pl.description
        INTO v_product_line_desc
        FROM t_product_line pl
       WHERE pl.id = p_t_product_line_id;
    
      raise_application_error(-20001
                             ,'������������ �������� "' || v_product_line_desc || '" � �������� "' ||
                              v_contact_name || '"');
    WHEN OTHERS THEN
      log(-1, '�� ������� ������� �������� ' || SQLERRM);
      raise_application_error(-20001
                             ,'�� ������� ������� �������� ' || SQLERRM);
    
  END;

  PROCEDURE inc_mandatory_covers_by_asset(p_as_asset_id NUMBER) IS
    v_p_cover_id NUMBER;
    v_ins_var_id NUMBER;
  
    v_prod_brief VARCHAR2(50);
  
    CURSOR cur_prod IS
      SELECT prod.brief
        FROM ven_as_asset          aa
            ,ven_p_policy          p
            ,ven_p_pol_header      ph
            ,ven_t_insurance_group ig
            ,ven_t_product         prod
       WHERE prod.product_id = ph.product_id
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = aa.p_policy_id
         AND aa.as_asset_id = p_as_asset_id;
  BEGIN
    BEGIN
      SELECT aa.ins_var_id INTO v_ins_var_id FROM as_asset aa WHERE aa.as_asset_id = p_as_asset_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_ins_var_id := NULL;
    END;
  
    OPEN cur_prod;
    FETCH cur_prod
      INTO v_prod_brief;
    IF cur_prod%NOTFOUND
    THEN
      v_prod_brief := NULL;
    END IF;
    CLOSE cur_prod;
  
    IF v_ins_var_id IS NULL
    THEN
      FOR rec IN (SELECT pl.id
                    FROM t_product           pr
                        ,t_product_version   pv
                        ,t_product_ver_lob   pvl
                        ,t_product_line      pl
                        ,t_product_line_type plt
                   WHERE pr.product_id = (SELECT ph.product_id
                                            FROM as_asset     a
                                                ,p_policy     p
                                                ,p_pol_header ph
                                           WHERE a.as_asset_id = p_as_asset_id
                                             AND a.p_policy_id = p.policy_id
                                             AND p.pol_header_id = ph.policy_header_id)
                     AND pv.product_id = pr.product_id
                     AND pvl.product_version_id = pv.t_product_version_id
                     AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
                     AND plt.product_line_type_id = pl.product_line_type_id
                     AND (plt.brief = 'MANDATORY' /* or plt.brief = 'RECOMMENDED'*/
                         ))
      LOOP
        BEGIN
          v_p_cover_id := include_cover(p_as_asset_id, rec.id);
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20000
                                   ,'������ ����������� ������������ ���������: ' || SQLERRM);
        END;
      END LOOP;
    END IF;
  
    IF v_prod_brief = '���'
       AND v_ins_var_id IS NOT NULL
    THEN
      FOR rec IN (SELECT pl.id
                    FROM t_product_line      pl
                        ,t_product_line_type plt
                   WHERE pl.id = v_ins_var_id
                     AND pl.product_line_type_id = plt.product_line_type_id
                     AND pl.id = v_ins_var_id
                     AND (plt.brief IN
                         ('COMBO', 'RISC', 'DEPOS', 'ATTACH' /*or plt.brief = 'RECOMMENDED'*/)))
      LOOP
        BEGIN
          v_p_cover_id := include_cover(p_as_asset_id, rec.id);
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20000, '������ ����������� ���������');
        END;
      END LOOP;
    END IF;
  END;

  FUNCTION include_cover
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
  ) RETURN NUMBER IS
    v_ret             NUMBER;
    v_p_cover_id      NUMBER;
    v_brief           status_hist.brief%TYPE;
    v_decline_sum     NUMBER;
    v_policy_id       NUMBER;
    v_err_msg         VARCHAR2(4000);
    v_is_proportional NUMBER;
    v_recalc_covers   NUMBER := 1;
  BEGIN
    log(p_asset_id, 'INCLUDE_COVER 1' || p_asset_id);
  
    SELECT a.p_policy_id INTO v_policy_id FROM as_asset a WHERE a.as_asset_id = p_asset_id;
    -- �������� ����������� ��������
    IF check_dependences(p_asset_id, p_prod_line_id, v_err_msg) = 0
    THEN
      raise_application_error(-20000, v_err_msg);
    END IF;
  
    log(p_asset_id, 'INCLUDE_COVER 2');
    -- ��������, ���� �� ��� � �������� ����� �������� �� �������� ������
    v_p_cover_id := NULL;
    BEGIN
      --logcover ('1');
      SELECT pc.p_cover_id
            ,sh.brief
            ,pc.decline_summ
        INTO v_p_cover_id
            ,v_brief
            ,v_decline_sum
        FROM p_cover            pc
            ,as_asset           a
            ,t_prod_line_option plo
            ,status_hist        sh
       WHERE a.as_asset_id = p_asset_id
         AND a.as_asset_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = plo.id
         AND plo.product_line_id = p_prod_line_id
         AND pc.status_hist_id = sh.status_hist_id;
    EXCEPTION
      WHEN no_data_found THEN
        v_p_cover_id := NULL;
    END;
  
    IF v_brief = 'DELETED'
    THEN
    
      set_cover_status(v_p_cover_id, 'CURRENT');
      -- �������� �����������
    
      --UPDATE P_COVER pc
      --   SET pc.decline_date = NULL,
      --           pc.decline_summ = NULL,
      --          pc.RETURN_SUMM = NULL,
      --          pc.premium = pc.old_PREMIUM + pc.ADDED_SUMM -pc.PAYED_SUMM,
      --          pc.ADDED_SUMM = NULL,
      --          pc.PAYED_SUMM = NULL,
      --          pc.DECLINE_PARTY_ID = NULL,
      --          pc.DECLINE_REASON_ID = NULL
      -- WHERE pc.p_cover_id = v_p_cover_id;
    
      --UPDATE P_POLICY p
      --  SET p.decline_summ = p.decline_summ - v_decline_sum
      --WHERE p.policy_id = v_policy_id;
    
      pkg_decline2.rollback_cover_decline(v_p_cover_id, 1);
      v_recalc_covers := 0;
    
      /* 2008/03/04 Add Marchuk A bug #1596 */
      v_ret := v_p_cover_id;
      /* 2008/03/04 End bug #1596 */
    
    ELSIF (v_brief = 'NEW' OR v_brief = 'CURRENT')
    THEN
      v_ret := v_p_cover_id;
    ELSIF v_p_cover_id IS NULL
    THEN
      v_ret := cre_new_cover(p_asset_id, p_prod_line_id);
    END IF;
  
    BEGIN
      --logcover ('4');
      SELECT decode(po.brief, 'PROPORTIONAL', 1, 0)
        INTO v_is_proportional
        FROM p_pol_header    ph
            ,t_payment_order po
            ,p_policy        p
       WHERE ph.t_prod_payment_order_id = po.t_payment_order_id(+)
         AND ph.policy_header_id = p.pol_header_id
         AND p.policy_id = v_policy_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        v_is_proportional := 0;
    END;
    IF v_is_proportional = 1
    THEN
      --logcover ('5');
      UPDATE p_cover pc SET pc.is_proportional = 1 WHERE pc.p_cover_id = v_ret;
    END IF;
  
    --opatsan
    --������� � cre_new_cover
    /*    insert into p_cover_agent
          (cover_agent_id, cover_id, p_policy_agent_com_id)
          select sq_p_cover_agent.nextval, v_ret, pac.p_policy_agent_com_id
            from p_policy_agent_com pac, p_policy_agent pa, p_policy pp
           where pp.policy_id = v_policy_id
             and pp.pol_header_id = pa.policy_header_id
             and pac.p_policy_agent_id = pa.p_policy_agent_id
             and pac.t_product_line_id = p_prod_line_id
             and not exists
           (select 1
                    from p_policy_agent_com pac1,
                         p_policy_agent     pa1,
                         p_policy           pp1,
                         p_cover_agent      ca
                   where ca.cover_id = v_ret
                     and ca.p_policy_agent_com_id = pac1.p_policy_agent_com_id
                     and pp1.policy_id = v_policy_id
                     and pp1.pol_header_id = pa1.policy_header_id
                     and pac1.p_policy_agent_id = pa1.p_policy_agent_id
                     and pac1.t_product_line_id = p_prod_line_id);
    */
    IF v_recalc_covers = 0
    THEN
      utils.put('RECALC_COVERS', 'FALSE');
    END IF;
  
    pkg_policy.update_policy_sum(v_policy_id);
  
    utils.put('RECALC_COVERS', 'TRUE');
  
    RETURN v_ret;
    log(p_asset_id, 'INCLUDE_COVER END');
  END;
  /*
    ����������
  */
  PROCEDURE calc_decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decl_date    IN DATE
   ,p_is_charge    IN NUMBER
   ,p_is_comission IN NUMBER
   ,po_ins_sum     OUT NUMBER
   ,po_prem_sum    OUT NUMBER
   ,po_pay_sum     OUT NUMBER
   ,po_payoff_sum  OUT NUMBER
   ,po_charge_sum  OUT NUMBER
   ,po_com_sum     OUT NUMBER
   ,po_zsp_sum     OUT NUMBER
   ,po_decline_sum OUT NUMBER
  ) IS
    v_cover         p_cover%ROWTYPE;
    plo             t_prod_line_option%ROWTYPE;
    v_amount        pkg_payment.t_amount;
    dni_ost         NUMBER;
    dni_all         NUMBER;
    v_policy        p_policy%ROWTYPE; -- ����������� ������ ������
    v_prev_cover    p_cover%ROWTYPE; -- ����������� ������ ��������
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
  BEGIN
    SELECT c.* INTO v_cover FROM p_cover c WHERE c.p_cover_id = p_p_cover_id;
  
    -- �. �������. ����� ���������������� �������� � ����������� ������, ����� ����� � ���� ������
    BEGIN
      -- ������ ������������ ������ ������
      SELECT p.*
        INTO v_policy
        FROM p_policy p
            ,p_cover  c
            ,as_asset a
       WHERE a.p_policy_id = p.policy_id
         AND c.as_asset_id = a.as_asset_id
         AND c.p_cover_id = p_p_cover_id;
      -- ������ ����������� ������
      SELECT *
        INTO v_policy
        FROM p_policy
       WHERE version_num = v_policy.version_num - 1
         AND pol_header_id = v_policy.pol_header_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'���������� ����� ����������� ������ ������');
    END;
  
    BEGIN
      SELECT c.*
        INTO v_prev_cover
        FROM p_cover  c
            ,as_asset a
       WHERE c.as_asset_id = a.as_asset_id
         AND a.p_policy_id = v_policy.policy_id
         AND c.t_prod_line_option_id = v_cover.t_prod_line_option_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'���������� ����� �������� �� ����������� ������ ������');
    END;
    -- �����. ����� ���������������� �������� � ����������� ������, ����� ����� � ���� ������
  
    SELECT p.* INTO plo FROM t_prod_line_option p WHERE p.id = v_cover.t_prod_line_option_id;
  
    po_ins_sum := v_cover.ins_amount;
    -- �.�������
    po_prem_sum := v_prev_cover.premium;
    --po_prem_sum := v_cover.premium;
  
    -- ������ ���������� �����
    v_amount        := pkg_payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount    := v_amount.fund_amount;
    v_charge_amount := pkg_payment.get_charge_cover_amount(p_p_cover_id).fund_amount;
  
    po_pay_sum := v_amount.fund_amount;
  
    -- ������ ����������� �����
    IF pkg_app_param.get_app_param_n('CLIENTID') = 10
    THEN
      BEGIN
        SELECT nvl(SUM(cc.payment_sum), 0)
          INTO po_payoff_sum
          FROM c_claim_header ch
              ,c_claim        cc
              ,c_claim_status cs
         WHERE ch.p_cover_id = v_prev_cover.p_cover_id
           AND cc.c_claim_header_id = ch.c_claim_header_id
           AND cc.seqno =
               (SELECT MAX(cl.seqno) FROM c_claim cl WHERE cl.c_claim_header_id = ch.c_claim_header_id)
           AND cs.c_claim_status_id = cc.claim_status_id
           AND cs.brief LIKE '�������'
           AND cc.claim_status_date <= p_decl_date;
      EXCEPTION
        WHEN no_data_found THEN
          po_payoff_sum := 0;
      END;
    ELSE
      po_payoff_sum := 0;
    END IF;
  
    -- ������ �������� �� ������� ����
    SELECT ROUND(nvl(ig.operation_cost, 0) * /*v_cover.premium*/
                 po_prem_sum
                ,2)
      INTO po_charge_sum
      FROM t_insurance_group  ig
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE plo.id = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ������ ����� ��������� ������
    -- todo �������������, ��� ������ ����� ���� ������ ���������� ���������
    SELECT nvl(ROUND(SUM(pac.val_com) * /*v_cover.premium*/
                     po_prem_sum / 100
                    ,2)
              ,0)
      INTO po_com_sum
      FROM p_cover_agent      ca
          ,p_policy_agent_com pac
     WHERE ca.cover_id = p_p_cover_id
       AND pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    -- ������ ��� (�������)
    -- todo ������� ����������� ������ ��������� ������� ��� � ����� ��������
    IF (v_cover.start_date < p_decl_date AND v_cover.end_date > p_decl_date)
    THEN
      -- ��� �����
      IF (plo.description = '�����')
      THEN
        -- �����
        SELECT SUM(d.dni_ost)
              ,SUM(d.dni_all)
          INTO dni_ost
              ,dni_all
          FROM (SELECT --p.as_asset_id,
                 CASE
                   WHEN p.end_date < p_decl_date THEN
                    0
                   WHEN p.end_date >= p_decl_date
                        AND p.start_date <= p_decl_date THEN
                    (trunc(p.end_date) - trunc(p_decl_date))
                   WHEN p.start_date > p_decl_date THEN
                    (trunc(p.end_date) - trunc(p.start_date))
                 END dni_ost
                ,(trunc(p.end_date) - trunc(p.start_date) + 1) dni_all
                  FROM as_asset_per p
                 WHERE p.as_asset_id = v_cover.as_asset_id) d;
        po_zsp_sum := ROUND( /*v_cover.premium*/(po_prem_sum - po_charge_sum) * (dni_all - dni_ost) /
                            dni_all
                           ,2);
        -- ��� ���������
      ELSIF (plo.description = '���������' OR plo.description = '�����' OR
            plo.description = '���������� ������' OR plo.description = '����������� ���������������' OR
            plo.description = '�������������� ������������' OR plo.description = '����������� ������')
      THEN
        po_zsp_sum := ROUND( /*v_cover.premium*/po_prem_sum *
                            CEIL(MONTHS_BETWEEN(p_decl_date + 1
                                               ,v_cover.start_date)) /
                            MONTHS_BETWEEN((v_cover.end_date + 1)
                                          ,v_cover.start_date)
                           ,2);
      ELSE
        po_zsp_sum := ROUND( /*v_cover.premium*/po_prem_sum * (p_decl_date - v_cover.start_date) /
                            (v_cover.end_date - v_cover.start_date)
                           ,2);
      END IF;
    ELSIF v_cover.start_date > p_decl_date
    THEN
      po_zsp_sum := 0;
    ELSIF v_cover.end_date < p_decl_date
    THEN
      po_zsp_sum :=  /*v_cover.premium*/
       po_prem_sum;
    END IF;
  
    -- ������ ����� ��������
    po_decline_sum := po_pay_sum - po_zsp_sum - po_payoff_sum;
    IF nvl(p_is_charge, 0) = 1
    THEN
      po_decline_sum := po_decline_sum - po_charge_sum;
      po_zsp_sum     := po_zsp_sum + po_charge_sum;
    END IF;
    IF nvl(p_is_comission, 0) = 1
    THEN
      po_decline_sum := po_decline_sum - po_com_sum;
      po_zsp_sum     := po_zsp_sum + po_com_sum;
    END IF;
    IF po_decline_sum < 0
    THEN
      po_decline_sum := 0;
    END IF;
    IF po_zsp_sum > /*v_cover.premium*/
       po_prem_sum
    THEN
      po_zsp_sum :=  /*v_cover.premium*/
       po_prem_sum;
    END IF;
  
    po_prem_sum := po_prem_sum + v_pay_amount - v_charge_amount;
  
    UPDATE ven_p_cover pc
       SET pc.decline_date = p_decl_date
          ,pc.decline_summ = po_decline_sum
          ,pc.return_summ  = po_decline_sum
          ,
           --     pc.old_premium = po_prem_sum+v_pay_amount-v_charge_amount,
           --   pc.premium = po_zsp_sum,
           pc.premium               = po_prem_sum
          ,pc.is_handchange_decline = 1
          ,pc.is_handchange_amount  = 1
          ,pc.is_handchange_deduct  = 1
          ,pc.is_handchange_premium = 1
          ,pc.is_handchange_tariff  = 1
     WHERE pc.p_cover_id = v_cover.p_cover_id;
  
    COMMIT;
    -- po_prem_sum:= po_zsp_sum;
  END;

  FUNCTION decline_cover
  (
    p_p_cover_id   IN NUMBER
   ,p_decline_date DATE
  ) RETURN NUMBER IS
    v_cover         p_cover%ROWTYPE;
    v_amount        pkg_payment.t_amount;
    v_func_brief    t_prod_coef_type.brief%TYPE;
    v_decline_sum   NUMBER;
    v_return_sum    NUMBER;
    v_zsp           NUMBER;
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
    v_premium       NUMBER;
    v_policy_id     NUMBER;
  
  BEGIN
    log(p_p_cover_id, 'DECLINE_COVER');
    -- ��������� ���� �����������
    UPDATE p_cover pc
       SET pc.decline_date = p_decline_date
     WHERE pc.p_cover_id = p_p_cover_id RETURN premium INTO v_premium;
  
    SELECT c.* INTO v_cover FROM p_cover c WHERE c.p_cover_id = p_p_cover_id;
  
    -- ������ ���������� �����
    v_amount        := pkg_payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount    := v_amount.fund_amount;
    v_charge_amount := pkg_payment.get_charge_cover_amount(p_p_cover_id,'PROLONG').fund_amount;
  
    log(p_p_cover_id
       ,'DECLINE_COVER pay_amount ' || v_amount.fund_amount || ' charge_amount ' || v_charge_amount);
  
    --pkg_renlife_utils.tmp_log_writer('v_pay_amount '||v_pay_amount||' v_cahrge_amount '||v_charge_amount);
    -- ������ ��� �� ���������,
    -- ������������� �� ��������� ��� ������ ��������� �� ��������.
    BEGIN
      SELECT pct.brief
        INTO v_func_brief
        FROM t_metod_decline  md
            ,t_prod_coef_type pct
       WHERE md.t_metod_decline_id = (SELECT *
                                        FROM (SELECT plmd.t_prodline_metdec_met_decl_id
                                                FROM t_product_line       pl
                                                    ,t_prod_line_option   plo
                                                    ,t_prod_line_met_decl plmd
                                               WHERE plo.id = v_cover.t_prod_line_option_id
                                                 AND plo.product_line_id = pl.id
                                                 AND plmd.t_prodline_metdec_prod_line_id = pl.id
                                               ORDER BY nvl(plmd.is_default, 0) DESC)
                                       WHERE rownum = 1)
         AND pct.t_prod_coef_type_id = md.metod_func_id;
      log(p_p_cover_id, 'DECLINE_COVER func_brief ' || v_func_brief);
    
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'�� ��������� �������� ������� ��� �� ���������');
    END;
    BEGIN
      v_zsp        := pkg_tariff_calc.calc_fun(v_func_brief
                                              ,ent.id_by_brief('P_COVER')
                                              ,v_cover.p_cover_id);
      v_return_sum := v_zsp;
    
      log(p_p_cover_id, 'DECLINE_COVER v_zsp ' || v_zsp);
    
      --  pkg_renlife_utils.tmp_log_writer('v_zsp '||v_zsp);
      v_decline_sum := v_amount.fund_amount - v_zsp;
      log(p_p_cover_id, 'DECLINE_COVER v_decline_sum ' || v_decline_sum);
      --  pkg_renlife_utils.tmp_log_writer('v_decline_sum '||v_decline_sum);
      /*
      EXCEPTION
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20000, SQLERRM);*/
    END;
  
    IF v_decline_sum < 0
    THEN
      v_decline_sum := 0;
    END IF;
  
    log(p_p_cover_id, 'DECLINE_COVER v_premium ' || v_premium);
  
    SELECT p_policy_id
      INTO v_policy_id
      FROM as_asset
     WHERE as_asset_id = (SELECT pc.as_asset_id FROM p_cover pc WHERE pc.p_cover_id = p_p_cover_id);
  
    /* 2009/07/14 �������� �
      � ������ ����������� ������ "���������� ��������" ����� � �������� ������������� �������.
      ��� ������� �������� ��������� ����� �������. �������� ! ���������� ��� �������� ����������� �������!
    */
    IF pkg_financy_weekend_fo.isfoweekpolicy(v_policy_id) = 0
    THEN
      UPDATE p_cover pc
         SET pc.premium      = pc.premium + v_pay_amount - v_charge_amount
            ,pc.decline_summ = v_decline_sum
            ,pc.return_summ  = v_decline_sum
       WHERE pc.p_cover_id = p_p_cover_id
      RETURNING premium INTO v_premium;
    ELSE
      UPDATE p_cover pc
         SET pc.premium      = pc.premium + v_pay_amount - v_charge_amount
            ,pc.decline_summ = v_decline_sum
            ,pc.return_summ  = v_return_sum
       WHERE pc.p_cover_id = p_p_cover_id;
    END IF;
  
    log(p_p_cover_id, 'DECLINE_COVER NEW premium ' || v_premium);
  
    RETURN v_decline_sum;
  END decline_cover;

  FUNCTION calc_cover_adm_exp_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount pkg_payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM p_policy p
                     ,p_cover  pc
                     ,as_asset a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      -- amount:= Pkg_Decline.get_cover_admin_exp_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := pkg_decline2.get_cover_admin_exp_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_cash_surr_ret_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount pkg_payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM p_policy p
                     ,p_cover  pc
                     ,as_asset a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_cash_surr_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := pkg_decline2.get_cover_cash_surr_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_accident_return_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount pkg_payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM p_policy p
                     ,p_cover  pc
                     ,as_asset a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_accident_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := pkg_decline2.get_cover_accident_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  FUNCTION calc_cover_life_per_return_sum(p_p_cover_id NUMBER) RETURN NUMBER IS
    amount pkg_payment.t_amount;
  BEGIN
    FOR ph IN (SELECT p.pol_header_id
                 FROM p_policy p
                     ,p_cover  pc
                     ,as_asset a
                WHERE a.p_policy_id = p.policy_id
                  AND pc.as_asset_id = a.as_asset_id
                  AND pc.p_cover_id = p_p_cover_id)
    LOOP
      --amount:= Pkg_Decline.get_cover_life_per_return_sum(ph.pol_header_id, p_p_cover_id);
      amount := pkg_decline2.get_cover_life_per_return_sum(ph.pol_header_id, p_p_cover_id);
    END LOOP;
    RETURN amount.fund_amount;
  END;

  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� ���������.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_common(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_cover      p_cover%ROWTYPE;
    v_payoff_sum NUMBER;
    v_rvd_sum    NUMBER;
    v_com_sum    NUMBER;
    v_zsp_sum    NUMBER;
    v_decl_date  DATE;
  BEGIN
    SELECT pc.* INTO v_cover FROM p_cover pc WHERE pc.p_cover_id = p_p_cover_id;
    v_decl_date := v_cover.decline_date;
  
    -- ������ ����� ������
    v_payoff_sum := 0; -- ������� �� �����������
  
    -- ������ ����� ��������� ������
    v_com_sum := 0; -- ������������ �� ����������, ��������� ����������� ���
  
    -- ������ "������" ���  (�������)
    v_zsp_sum := 0;
    IF (v_cover.start_date < v_decl_date AND v_cover.end_date > v_decl_date)
    THEN
      v_zsp_sum := ROUND(v_cover.premium * (v_decl_date - v_cover.start_date) /
                         (v_cover.end_date - v_cover.start_date)
                        ,2);
    ELSIF v_cover.start_date > v_decl_date
    THEN
      v_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decl_date
    THEN
      v_zsp_sum := v_cover.premium;
    END IF;
  
    v_rvd_sum := 0;
  
    -- ������ �������� �� ������� ����
    SELECT ROUND(nvl(ig.operation_cost, 0) * (v_cover.premium - v_zsp_sum), 2)
      INTO v_rvd_sum
      FROM t_insurance_group  ig
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE plo.id = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ������ ��� � ������ ��� � ����� �������������� ������
    v_zsp_sum := v_zsp_sum + v_rvd_sum;
    RETURN v_zsp_sum;
  END;

  PROCEDURE exclude_child_covers(par_cover_id IN NUMBER) IS
  BEGIN
    FOR pcov IN (SELECT pc.*
                   FROM p_cover            pc
                       ,t_prod_line_option plo
                  WHERE pc.as_asset_id =
                        (SELECT as_asset_id FROM p_cover WHERE p_cover_id = par_cover_id)
                    AND pc.status_hist_id <> status_hist_id_del
                    AND pc.t_prod_line_option_id = plo.id
                    AND plo.product_line_id IN
                        (SELECT ppl.t_prod_line_id
                           FROM parent_prod_line ppl
                          WHERE ppl.t_parent_prod_line_id IN
                                (SELECT plop.product_line_id
                                   FROM t_prod_line_option plop
                                       ,p_cover            pcv
                                  WHERE plop.id = pcv.t_prod_line_option_id
                                    AND pcv.p_cover_id = par_cover_id)))
    LOOP
      exclude_cover(pcov.p_cover_id);
    END LOOP;
  END;

  FUNCTION calc_new_cover_premium(p_p_cover_id NUMBER) RETURN NUMBER IS
  
    v_prem             NUMBER := 0;
    v_is_cover_changed NUMBER := 0;
    v_start            DATE;
    v_end              DATE;
    v_start_per        DATE;
    v_end_per          DATE;
    d1                 DATE;
    d2                 DATE;
  BEGIN
  
    -- �������� ��������, ���� �������� ��������� �� ����� ����
    -- ��� ����������� ��������� �������� ������ ����������������
    -- ���� �������� �� ������� �������� ����� ��� ����������������!
    -- ������������� ������ �� ������ �������� �� ������ � ������
    -- ������� ���� ������ ��������, � ������� ���� ��������� ������
    -- �� start_date ������ ��������� ��� ����� �����
    -- END_DATE �������� - ��������� ���� ��� ��������
    FOR covers IN (SELECT c.*
                         ,lead(c.pol_start_date) over(PARTITION BY c.pol_header_id ORDER BY c.policy_id ASC) next_pol_start_date
                     FROM (SELECT pc.*
                                 ,lag(pc.fee) over(PARTITION BY pc.t_prod_line_option_id, a.p_asset_header_id ORDER BY pc.as_asset_id ASC) prev_pc_fee
                                 ,p.start_date pol_start_date
                                 ,nvl(pt.number_of_payments, 1) num_of_paym
                                 ,p.version_num
                                 ,p.num
                                 ,ph.start_date ph_start_date
                                 ,p.pol_header_id
                                 ,p.policy_id
                             FROM p_cover         pc
                                 ,p_cover         pc1
                                 ,as_asset        a
                                 ,as_asset        a1
                                 ,ven_p_policy    p
                                 ,p_pol_header    ph
                                 ,t_payment_terms pt
                            WHERE pc1.p_cover_id = p_p_cover_id
                              AND pc1.t_prod_line_option_id = pc.t_prod_line_option_id
                              AND pc1.as_asset_id = a1.as_asset_id
                              AND a1.p_asset_header_id = a.p_asset_header_id
                              AND a.as_asset_id = pc.as_asset_id
                              AND pc.start_date = pc1.start_date
                              AND pc.end_date = pc1.end_date
                              AND a.p_policy_id = p.policy_id
                              AND p.payment_term_id = pt.id
                              AND ph.policy_header_id = p.pol_header_id) c
                    WHERE nvl(prev_pc_fee, 0) <> nvl(fee, 0)
                    ORDER BY p_cover_id ASC)
    LOOP
      IF covers.fee IS NULL
      THEN
        raise_application_error(-20100
                               ,'�� ������ ����� �� �������� � ������ � ' || covers.version_num ||
                                '.������� ' || covers.num);
      END IF;
    
      v_start     := greatest(trunc(covers.start_date, 'DD'), trunc(covers.pol_start_date, 'DD'));
      v_end       := least(trunc(covers.end_date + 1, 'DD')
                          ,trunc(nvl(covers.next_pol_start_date, covers.end_date + 1), 'DD'));
      v_start_per := pkg_payment.get_period_date(trunc(covers.ph_start_date, 'DD')
                                                ,covers.num_of_paym
                                                ,v_start);
      -- ���� �� ���� �������� ������, ���� �������� ��������
      LOOP
        v_end_per := ADD_MONTHS(v_start_per, 12 / covers.num_of_paym);
        IF (v_start <= v_start_per)
           AND (v_end >= v_end_per)
        THEN
          -- ���� �������� �������� ��������� ���������� ������
          v_prem := v_prem + covers.fee;
        ELSE
          d1     := greatest(v_start, v_start_per);
          d2     := least(v_end, v_end_per);
          v_prem := v_prem + covers.fee * (d2 - d1) / (v_end_per - v_start_per);
          --dbms_output.put_line((covers.fee*(d2-d1)/(v_end_per - v_start_per))||' '||d2||' '||d1||' '||v_end_per||' '||v_start_per);
        END IF;
      
        IF v_end <= v_end_per
        THEN
          EXIT;
        ELSE
          v_start_per := v_end_per;
        END IF;
      END LOOP;
    
    END LOOP;
    RETURN v_prem;
  END;

  PROCEDURE exclude_cover(par_cover_id IN NUMBER) IS
    v_brief                VARCHAR2(30);
    v_prod_line_type_brief t_product_line_type.brief%TYPE;
    v_decline_sum          NUMBER;
    v_s                    NUMBER;
    v_policy_id            NUMBER;
    v_policy_start_date    DATE;
    v_err                  VARCHAR2(1000);
  BEGIN
  
    exclude_child_covers(par_cover_id);
  
    SELECT sh.brief
          ,a.p_policy_id
      INTO v_brief
          ,v_policy_id
      FROM p_cover     p
          ,status_hist sh
          ,as_asset    a
     WHERE p.p_cover_id = par_cover_id
       AND p.as_asset_id = a.as_asset_id
       AND p.status_hist_id = sh.status_hist_id(+);
  
    -- ���� ������������ ��������, �� ������� ������
    /*    SELECT plt.brief
        into v_prod_line_type_brief
        FROM t_product_line_type plt,
             t_product_line      pl,
             t_prod_line_option  plo,
             p_cover             pc
       where pc.p_cover_id = par_cover_id
         and pc.t_prod_line_option_id = plo.id
         and plo.product_line_id = pl.id
         and pl.product_line_type_id = plt.product_line_type_id;
      if v_prod_line_type_brief = 'MANDATORY' then
        raise_application_error(-20000,
                                '�������� �������� ������������. ��������� ������.');
      end if;
    */
    CASE v_brief
      WHEN 'NEW' THEN
        -- delete from p_cover p where p.p_cover_id = par_cover_id;
        -- ���������� �.��������� ��� �������� �������� P_COVER-��, ����, P_COVER_ACCIDENT
        DELETE FROM ven_p_cover p WHERE p.p_cover_id = par_cover_id;
      WHEN 'CURRENT' THEN
        -- ������� �� � ���� ������ ������, ������ ����������� ��������
        SELECT p.policy_id
              ,p.start_date
          INTO v_policy_id
              ,v_policy_start_date
          FROM p_policy p
              ,as_asset a
              ,p_cover  pc
         WHERE pc.p_cover_id = par_cover_id
           AND pc.as_asset_id = a.as_asset_id
           AND a.p_policy_id = p.policy_id;
      
        -- ���������� ����� ��������
        /*        calc_decline_cover(par_cover_id,
        v_policy_start_date,
        0,
        0,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_s,
        v_decline_sum);*/
      
        -- �.�������
        SELECT decline_summ INTO v_decline_sum FROM p_cover WHERE p_cover_id = par_cover_id;
      
        IF v_decline_sum IS NULL
        THEN
          v_decline_sum := decline_cover(par_cover_id, v_policy_start_date);
          UPDATE p_cover pc
             SET pc.decline_date = v_policy_start_date
                ,pc.decline_summ = v_decline_sum
           WHERE pc.p_cover_id = par_cover_id;
        END IF;
        -- ������������ �� �����
        --UPDATE P_POLICY p
        --   SET p.decline_date = p.start_date,
        --       p.decline_summ = NVL(p.decline_summ, 0) + v_decline_sum
        -- WHERE p.policy_id = v_policy_id;
      
        set_cover_status(par_cover_id, 'DELETED');
      ELSE
        NULL;
    END CASE;
    -- ����������� ����� �� ���������� ������
    --pkg_policy.update_policy_sum(v_policy_id);
  EXCEPTION
    WHEN OTHERS THEN
      v_err := SQLERRM;
      IF v_err LIKE '%ORA-02292%FK_TRANS_OBJ%'
      THEN
        raise_application_error(-20100
                               ,'���� ���������� �� ��������. ��������� ������� ������ � ������� � ������');
      ELSE
        RAISE;
      END IF;
  END;

  PROCEDURE copy_p_cover
  (
    p_old_id IN NUMBER
   ,p_new_id IN NUMBER
  ) AS
    v_cover_old_id   NUMBER;
    v_cover_new_id   NUMBER;
    v_cover_accident p_cover_accident%ROWTYPE;
    p_p              p_policy%ROWTYPE;
    p_h              p_pol_header%ROWTYPE;
    v_is_new         NUMBER;
  
  BEGIN
  
    SELECT ph.*
      INTO p_h
      FROM as_asset ass
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
      JOIN p_pol_header ph
        ON ph.policy_header_id = pp.pol_header_id
     WHERE ass.as_asset_id = p_new_id;
  
    SELECT pp.*
      INTO p_p
      FROM as_asset ass
      JOIN p_policy pp
        ON pp.policy_id = ass.p_policy_id
     WHERE ass.as_asset_id = p_new_id;
  
    FOR v_r IN (SELECT *
                  FROM ven_p_cover t
                 WHERE t.as_asset_id = p_old_id
                   AND t.status_hist_id <> status_hist_id_del)
    LOOP
      IF (p_h.is_new = 0 AND p_p.version_num = 1)
      THEN
        v_is_new := 1;
      ELSE
        v_is_new := 0;
      END IF;
      v_cover_new_id := cover_copy(v_r, p_new_id, v_is_new);
      /*
       v_cover_old_id := v_r.p_cover_id;
       SELECT sq_p_cover.NEXTVAL INTO v_r.p_cover_id FROM dual;
       v_r.as_asset_id := p_new_id;
      
       -- ������ ������� ����� �� �������
       IF (p_h.is_new = 0 AND p_p.version_num = 1) THEN
        v_r.status_hist_id := status_hist_id_new;
       ELSE
         IF v_r.status_hist_id = status_hist_id_new THEN
           v_r.status_hist_id := status_hist_id_curr;
         END IF;
       END IF;
      
       v_r.old_premium := v_r.premium;
       INSERT INTO ven_p_cover VALUES v_r;
      
      -- copy
       Pkg_Tariff.copy_tariff(v_cover_old_id ,v_r.p_cover_id);
      
       -- ���� ��
       IF (Ent.brief_by_id(v_r.ent_id) = 'P_COVER_ACCIDENT') THEN
         SELECT *
           INTO v_cover_accident
           FROM p_cover_accident pca
          WHERE pca.id = v_cover_old_id;
         v_cover_accident.id := v_r.p_cover_id;
         INSERT INTO p_cover_accident VALUES v_cover_accident;
       END IF;*/
    END LOOP;
  END;

  FUNCTION cover_copy
  (
    p_old_cover    IN OUT ven_p_cover%ROWTYPE
   ,p_new_asset_id NUMBER
   ,p_is_new       NUMBER
  ) RETURN NUMBER IS
    v_cover_old_id    NUMBER;
    v_cover_accident  p_cover_accident%ROWTYPE;
    v_form_type_brief VARCHAR2(30);
    v_is_optional     NUMBER;
  
    /**
    * @author Piyadin A.
    * @param  par_cover_id �� ����������� ��������
    * @return ����, ������� ���������� ������������� ����������� ��������
              ���� 1, ���� ��� ������������ �� �������� > 0
              ���� 0, ���� ����� �� ������������� �������� = 0
    */
    FUNCTION is_cover_copy(par_cover_id p_cover.p_cover_id%TYPE) RETURN NUMBER IS
      v_result NUMBER := 1;
    BEGIN
      -- ���� �� �������������
      FOR rec IN (SELECT tpct.t_prod_coef_type_id
                    FROM t_prod_coef_type   tpct
                        ,p_cover            pc
                        ,t_prod_line_option plo
                        ,t_prod_line_coef   plc
                   WHERE pc.p_cover_id = par_cover_id
                     AND pc.t_prod_line_option_id = plo.id
                     AND plc.t_product_line_id = plo.product_line_id
                     AND plc.t_prod_coef_type_id = tpct.t_prod_coef_type_id
                     AND plc.is_disabled = 0)
      LOOP
        IF pkg_tariff_calc.calc_fun(rec.t_prod_coef_type_id, ent.id_by_brief('P_COVER'), par_cover_id) = 0
        THEN
          v_result := 0;
        END IF;
      END LOOP;
    
      RETURN v_result;
    END is_cover_copy;
  
  BEGIN
    /* ������ �.
       �� ��������� ������ ���������� ������
    */
    IF p_old_cover.t_prod_line_option_id != 147908 /*'NonInsuranceClaims'*/
    THEN
      v_cover_old_id := p_old_cover.p_cover_id;
      --������ 238167: ���������� Parent ID ��� cover
      -- ������ �. 246402
      --p_old_cover.parent_cover_id := v_cover_old_id;
      --
      SELECT sq_p_cover.nextval INTO p_old_cover.p_cover_id FROM dual;
      p_old_cover.as_asset_id := p_new_asset_id;
    
      -- ������ ������� ����� �� �������
      IF (p_is_new = 1)
      THEN
        p_old_cover.status_hist_id := status_hist_id_new;
      ELSE
        IF p_old_cover.status_hist_id = status_hist_id_new
        THEN
          p_old_cover.status_hist_id := status_hist_id_curr;
        END IF;
      END IF;
    
      -- opatsan
      -- ���� ������������������� + ������ 10 + ������� ��� ���������
      -- ������� ����� ������� ���������
      SELECT pft.brief
        INTO v_form_type_brief
        FROM p_pol_header       ph
            ,t_product          p
            ,t_policy_form_type pft
            ,p_policy           pp
            ,as_asset           aa
       WHERE aa.as_asset_id = p_new_asset_id
         AND pp.policy_id = aa.p_policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND ph.product_id = p.product_id
         AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
    
      p_old_cover.old_premium      := p_old_cover.premium;
      p_old_cover.ext_id           := NULL;
      p_old_cover.premia_base_type := 0;
    
      log(p_old_cover.p_cover_id, 'P_OLD_COVER.PREMIA_BASE_TYPE ' || p_old_cover.premia_base_type);
    
      INSERT INTO ven_p_cover VALUES p_old_cover;
      -- copy
      pkg_tariff.copy_tariff(v_cover_old_id, p_old_cover.p_cover_id);
    
      RETURN p_old_cover.p_cover_id;
    
      /*      -- ����� ������ 
            SAVEPOINT Before_Cover_Copy;
      
            log(p_old_cover.p_cover_id, 'P_OLD_COVER.PREMIA_BASE_TYPE ' || p_old_cover.premia_base_type);
          
            INSERT INTO ven_p_cover VALUES p_old_cover;
            -- copy
            pkg_tariff.copy_tariff(v_cover_old_id, p_old_cover.p_cover_id);
          
            --  ������ �., 288494 ���������� ������ �� ��������
            SELECT COUNT(*)
              INTO v_is_optional
              FROM dual
            WHERE EXISTS (SELECT 1
                          FROM t_prod_line_option  pro
                              ,t_product_line      pl
                              ,t_product_line_type plt
                          WHERE p_old_cover.t_prod_line_option_id = pro.id(+)
                            AND pro.product_line_id               = pl.ID(+)
                            AND pl.product_line_type_id           = plt.product_line_type_id
                            AND plt.presentation_desc             = '���');
                            
            IF v_is_optional = 1 AND is_cover_copy(p_old_cover.p_cover_id) = 0 THEN
              ROLLBACK TO Before_Cover_Copy;
              RETURN NULL;
            ELSE
            RETURN p_old_cover.p_cover_id;
            END IF;
      */
    ELSE
      RETURN NULL;
    END IF;
  END;

  PROCEDURE link_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  ) IS
    c NUMBER;
  BEGIN
    FOR rc IN (SELECT p.p_cover_id
                 FROM as_asset a
                     ,p_cover  p
                WHERE a.p_policy_id = p_pol_id
                  AND p.as_asset_id = a.as_asset_id)
    LOOP
      c := link_cover_agent(rc.p_cover_id, p_agent_id);
    END LOOP;
  END;

  PROCEDURE unlink_policy_agent
  (
    p_pol_id   NUMBER
   ,p_agent_id NUMBER
  ) IS
  BEGIN
    /* DELETE FROM P_COVER_AGENT ca
    WHERE ca.agent_id = p_agent_id
      AND ca.cover_id IN
          (SELECT p.p_cover_id
             FROM AS_ASSET a, P_COVER p
            WHERE a.p_policy_id = p_pol_id
              AND a.as_asset_id = p.as_asset_id); */
    NULL;
  END;

  FUNCTION get_policy_confirm_date(p_p_cover_id IN NUMBER) RETURN DATE AS
    v_result DATE;
  BEGIN
    SELECT pp.confirm_date
      INTO v_result
      FROM p_cover pc
     INNER JOIN as_asset aa
        ON aa.as_asset_id = pc.as_asset_id
     INNER JOIN p_policy pp
        ON pp.policy_id = aa.p_policy_id
     WHERE EXISTS (SELECT 1
              FROM p_cover pc_curr
             INNER JOIN as_asset aa_curr
                ON aa_curr.as_asset_id = pc_curr.as_asset_id
             WHERE pc_curr.p_cover_id = p_p_cover_id
               AND aa.p_asset_header_id = aa_curr.p_asset_header_id
               AND pc.t_prod_line_option_id = pc_curr.t_prod_line_option_id)
       AND pc.status_hist_id = pkg_cover.status_hist_id_new;
    RETURN v_result;
  END;

  /**
  * ��������� ����������� ���������� �������� ���������� � �������� ����������
  * @author �.�������
  * @param p_asset_id �� ������� �����������
  * @param p_prod_line_id �� ����� ��������
  * @param err_msg ��������� � ������� ���������������
  * @return 1 - ����� ��������� ��������, 0 - ������ ��������� ��������
  */
  FUNCTION check_dependencies_by_clause
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER IS
    v_issuer_id        NUMBER;
    v_pl_brief         VARCHAR2(100);
    v_product_brief    VARCHAR2(100);
    v_asset_contact_id NUMBER;
  BEGIN
    SELECT nvl(brief, '?') INTO v_pl_brief FROM t_product_line WHERE id = p_prod_line_id;
    SELECT nvl(p.brief, '?')
      INTO v_product_brief
      FROM t_product_line    pl
          ,t_product         p
          ,t_product_version pv
          ,t_product_ver_lob pvl
     WHERE pl.id = p_prod_line_id
       AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
       AND p.product_id = pv.product_id
       AND pv.t_product_version_id = pvl.product_version_id;
    IF v_product_brief = 'END'
       AND v_pl_brief IN ('�������������', '�������������')
    THEN
      BEGIN
        SELECT pi.contact_id
          INTO v_issuer_id
          FROM v_pol_issuer   pi
              ,ven_as_assured a
         WHERE a.p_policy_id = pi.policy_id
           AND a.as_assured_id = p_asset_id
           AND a.assured_contact_id = pi.contact_id;
        IF v_pl_brief = '�������������'
        THEN
          err_msg := '���������� �������� ��������� "������ ��������� �������", �.�. ������������ ��������� � ��������������';
          RETURN 0;
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          -- ������������ �� ��������� � ��������������-> ������������ �� ������ ������� ����������
          IF v_pl_brief = '�������������'
          THEN
            err_msg := '���������� �������� ��������� "������������ �� ������ �������", �.�. ������������ �� ��������� � ��������������';
            RETURN 0;
          END IF;
      END;
    END IF;
    RETURN 1;
  END;
  /**
  * ��������� ����������� �������������� ����������� ����� �������� ��� ���������� ������� �����������
  * @author Denis Ivanov
  * @param p_asset_id �� ������� �����������
  * @param p_prod_line_id �� ����� ��������
  * @param err_msg ��������� � ������� ���������������
  * @return 1 - ����� ��������� ��������, 0 - ������ ��������� ��������
  */
  FUNCTION check_dependences
  (
    p_asset_id     IN NUMBER
   ,p_prod_line_id IN NUMBER
   ,err_msg        OUT VARCHAR2
  ) RETURN NUMBER IS
    v_desc_concurrent_pl VARCHAR2(4000);
    v_ret_val            NUMBER(1);
  BEGIN
    v_ret_val := check_dependencies_by_clause(p_asset_id, p_prod_line_id, err_msg);
    IF v_ret_val = 0
    THEN
      RETURN v_ret_val;
    END IF;
    -- ��������� ������� ������������� ����� ��������
    BEGIN
      SELECT t.description
        INTO v_desc_concurrent_pl
        FROM (SELECT pl.id
                    ,pl.description
                FROM p_cover pc
                    ,t_prod_line_option plo
                    ,t_product_line pl
                    ,(SELECT cpl.t_concur_product_line_id concurrent_prod_line_id
                        FROM concurrent_prod_line cpl
                       WHERE cpl.t_product_line_id = p_prod_line_id
                      UNION
                      SELECT cpl.t_product_line_id concurrent_prod_line_id
                        FROM concurrent_prod_line cpl
                       WHERE cpl.t_concur_product_line_id = p_prod_line_id) t
               WHERE pc.as_asset_id = p_asset_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = pl.id
                 AND t.concurrent_prod_line_id = pl.id
                 AND pc.status_hist_id <> status_hist_id_del) t
       WHERE rownum = 1;
      v_ret_val := 0;
      err_msg   := '������ ��� �������� �� ����� ���� �������� ������������ � ' ||
                   v_desc_concurrent_pl;
      RETURN v_ret_val;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    -- ��������� �������� �� ��� ������������ ��������
    BEGIN
      SELECT tt.description
        INTO v_desc_concurrent_pl
        FROM t_product_line tt
            ,(SELECT ppl.t_parent_prod_line_id parent_prod_line_id
                FROM parent_prod_line ppl
               WHERE ppl.t_prod_line_id = p_prod_line_id
              MINUS
              SELECT pl.id
                FROM p_cover            pc
                    ,t_prod_line_option plo
                    ,t_product_line     pl
               WHERE pc.as_asset_id = p_asset_id
                 AND pc.t_prod_line_option_id = plo.id
                 AND plo.product_line_id = pl.id
                 AND pc.status_hist_id <> status_hist_id_del
              MINUS
              SELECT *
                FROM (SELECT cpl.t_concur_product_line_id concurrent_prod_line_id
                        FROM concurrent_prod_line cpl
                       WHERE cpl.t_product_line_id IN
                             (SELECT pl_.id
                                FROM p_cover            pc
                                    ,t_prod_line_option plo
                                    ,t_product_line     pl_
                               WHERE pc.as_asset_id = p_asset_id
                                 AND pc.t_prod_line_option_id = plo.id
                                 AND plo.product_line_id = pl_.id
                                 AND pc.status_hist_id <> status_hist_id_del)
                      UNION
                      SELECT cpl.t_product_line_id concurrent_prod_line_id
                        FROM concurrent_prod_line cpl
                       WHERE cpl.t_concur_product_line_id IN
                             (SELECT pl_.id
                                FROM p_cover            pc
                                    ,t_prod_line_option plo
                                    ,t_product_line     pl_
                               WHERE pc.as_asset_id = p_asset_id
                                 AND pc.t_prod_line_option_id = plo.id
                                 AND plo.product_line_id = pl_.id
                                 AND pc.status_hist_id <> status_hist_id_del))) ttt
       WHERE rownum = 1
         AND ttt.parent_prod_line_id = tt.id;
      v_ret_val := 0;
      err_msg   := '������ ��� �������� ����� ���� �������� ������ ������������ � ' ||
                   v_desc_concurrent_pl;
      RETURN v_ret_val;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_ret_val;
    END;
  END;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_age        NUMBER
  ) IS
    v_end_date        DATE;
    v_asset_id        NUMBER;
    p_pol_id          NUMBER;
    izm_srok          NUMBER;
    v_pol_id          NUMBER;
    v_pol_end_date    DATE;
    v_policy_end_date DATE;
    v_one_sec         NUMBER := 1 / 24 / 3600;
  BEGIN
    UPDATE p_cover SET accum_period_end_age = p_age WHERE p_cover_id = p_p_cover_id;
    -- ����� �� ������������� ���� ������ ������ ������ ����
  
    FOR v_pol_period IN (SELECT pc.p_cover_id
                           FROM p_cover pc
                          WHERE 1 = 1
                            AND pc.p_cover_id = p_p_cover_id
                            AND (accum_period_end_age IS NULL OR pc.is_avtoprolongation = 1))
    LOOP
    
      log(p_p_cover_id
         ,'SET_COVER_ACCUM_PERIOD_END_AGE ACCUM_PERIOD_END_AGE IS NULL OR IS_AVTOPROLONGATION = 1 ');
      RETURN;
    END LOOP;
  
    -- �������������� ���� ��������� ��������
    UPDATE p_cover
       SET end_date = ADD_MONTHS(start_date, 12 * (p_age - insured_age)) - v_one_sec
     WHERE p_cover_id = p_p_cover_id
       AND insured_age < p_age
    RETURNING end_date INTO v_end_date;
  
    IF SQL%ROWCOUNT = 0
    THEN
      --raise_application_error(-20100, '��������� ������� ������ ���� ������ �������� ��������� �������������� �������');
      log(p_p_cover_id
         ,'��������� ������� ������ ���� ������ �������� ��������� �������������� �������');
      RETURN;
    END IF;
  
    log(p_p_cover_id
       ,'SET_COVER_ACCUM_PERIOD_END_AGE END_DATE ' || to_char(v_end_date, 'dd.mm.yyyy hh24:mi:ss'));
  
    SELECT as_asset_id INTO v_asset_id FROM p_cover WHERE p_cover_id = p_p_cover_id;
    --������� 282426 /������/
    --SELECT MAX(pc.end_date) INTO v_end_date FROM p_cover pc WHERE pc.as_asset_id = v_asset_id;
  
    v_end_date := pkg_asset.get_asset_end_date(v_asset_id);
    -- �������������� ���� ��������� �������
    /*-------------------------- ��������� 07-12-2009 �������� -----------*/
    SELECT ar.p_policy_id INTO p_pol_id FROM as_asset ar WHERE ar.as_asset_id = v_asset_id;
  
    SELECT pp.end_date INTO v_policy_end_date FROM p_policy pp WHERE pp.policy_id = p_pol_id;
    --���� ������ �� �� ���� �� � ����� ���������
    SELECT COUNT(*)
      INTO izm_srok
      FROM p_pol_addendum_type at
     WHERE at.p_policy_id = p_pol_id
       AND at.t_addendum_type_id = 8;
  
    IF v_end_date > v_policy_end_date
       AND izm_srok <> 1
    THEN
      NULL;
    ELSE
      /*--------------------*/
      UPDATE as_asset SET end_date = v_end_date WHERE as_asset_id = v_asset_id;
      SELECT p_policy_id INTO v_pol_id FROM as_asset WHERE as_asset_id = v_asset_id;
    
      SELECT MAX(pc.end_date)
        INTO v_pol_end_date
        FROM p_cover  pc
            ,as_asset a
       WHERE a.p_policy_id = v_pol_id
         AND pc.as_asset_id = a.as_asset_id;
    
      log(p_p_cover_id
         ,'SET_COVER_ACCUM_PERIOD_END_AGE UPDATE POLICY END_DATE ' ||
          to_char(v_pol_end_date, 'dd.mm.yyyy hh24:mi:ss'));
    
      UPDATE p_policy
         SET end_date         = v_pol_end_date
            ,fee_payment_term = least(fee_payment_term
                                     ,trunc(MONTHS_BETWEEN(v_end_date, start_date) / 12) + 1)
       WHERE policy_id = v_pol_id;
      /*---------------*/
    END IF;
    /*----------------*/
  
  END;

  PROCEDURE set_cover_accum_period_end_age
  (
    p_p_cover_id NUMBER
   ,p_period_id  IN NUMBER
   ,p_age        NUMBER
  ) IS
    v_end_date     DATE;
    v_asset_id     NUMBER;
    v_pol_id       NUMBER;
    v_pol_end_date DATE;
  BEGIN
  
    IF p_period_id IS NULL
    THEN
      set_cover_accum_period_end_age(p_p_cover_id, p_period_id, p_age);
    ELSE
      UPDATE p_cover SET period_id = p_period_id WHERE p_cover_id = p_p_cover_id;
      set_cover_accum_period_end_age(p_p_cover_id, p_age);
    END IF;
  
  END;

  /**
  * ��������� �������� ������ ������ �� �������� ��� ��������
  * @author Marchuk A
  * @param p_p_cover_id �� ��������
  * @param p_value ������������� ��������
  * @returm ����������� ��������
  */

  FUNCTION round_fee
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER IS
    RESULT           NUMBER;
    v_round_rules_id NUMBER;
  BEGIN
  
    SELECT pl.fee_round_rules_id
      INTO v_round_rules_id
      FROM t_product_line     pl
          ,t_prod_line_option plo
          ,p_cover            pc
     WHERE pl.id = plo.product_line_id
       AND plo.id = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_round_rules_id IS NOT NULL
    THEN
      RESULT := ins.pkg_round_rules.calculate(v_round_rules_id
                                             ,p_value
                                             ,ent.id_by_brief('P_COVER')
                                             ,p_p_cover_id);
    ELSE
      RESULT := p_value;
    END IF;
    RETURN RESULT;
  END;
  /**
  * ��������� �������� ������ ������ �� �������� ��� ��������
  * @author Marchuk A
  * @param p_p_cover_id �� ��������
  * @param p_value ������������� ��������
  * @returm ����������� ��������
  */

  FUNCTION round_ins_amount
  (
    p_p_cover_id IN NUMBER
   ,p_value      IN NUMBER
  ) RETURN NUMBER IS
    RESULT           NUMBER;
    v_round_rules_id NUMBER;
  BEGIN
  
    SELECT pl.ins_amount_round_rules_id
      INTO v_round_rules_id
      FROM t_product_line     pl
          ,t_prod_line_option plo
          ,p_cover            pc
     WHERE pl.id = plo.product_line_id
       AND plo.id = pc.t_prod_line_option_id
       AND pc.p_cover_id = p_p_cover_id;
  
    IF v_round_rules_id IS NOT NULL
    THEN
      RESULT := ins.pkg_round_rules.calculate(v_round_rules_id
                                             ,p_value
                                             ,ent.id_by_brief('P_COVER')
                                             ,p_p_cover_id);
    ELSE
      RESULT := p_value;
    END IF;
    RETURN RESULT;
  END;

  FUNCTION get_cover_tariff
  (
    p_asset_id        NUMBER
   ,p_prod_line_brief VARCHAR2
  ) RETURN NUMBER IS
    v_val NUMBER;
  BEGIN
    SELECT SUM(pc.tariff)
      INTO v_val
      FROM ven_p_cover pc
      JOIN ven_t_prod_line_option plo
        ON plo.id = pc.t_prod_line_option_id
       AND plo.brief = p_prod_line_brief
      JOIN status_hist sh
        ON sh.status_hist_id = pc.status_hist_id
       AND sh.brief NOT IN ('DELETED')
     WHERE pc.as_asset_id = p_asset_id;
  
    RETURN v_val;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION calc_amount_imusch_ipoteka(p_par_policy_id NUMBER) RETURN NUMBER IS
    ret_sum NUMBER;
  BEGIN
    SELECT SUM(pc.ins_amount)
      INTO ret_sum
      FROM ven_as_property ap
      JOIN ven_p_cover pc
        ON pc.as_asset_id = as_property_id
      JOIN ven_t_prod_line_option plo
        ON plo.id = pc.t_prod_line_option_id
       AND plo.description IN ('�� ����������� ��������� �����������'
                              ,'���� ����������� ��������� �����������')
      JOIN status_hist sh
        ON sh.status_hist_id = pc.status_hist_id
       AND sh.brief NOT IN ('DELETED')
     WHERE ap.p_policy_id = p_par_policy_id;
    RETURN ret_sum;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
  END;

  FUNCTION get_cover
  (
    p_p_cover_id NUMBER
   ,p_date       DATE
  ) RETURN NUMBER IS
    v_cover_id NUMBER;
  BEGIN
    -- ������� �������� �� ���� � ����� �� ���������� � �������� �����������
    SELECT p_cover_id
      INTO v_cover_id
      FROM (SELECT pc.p_cover_id
              FROM p_cover  pc
                  ,as_asset a
                  ,p_policy p
                  ,p_cover  pc1
                  ,as_asset a1
             WHERE pc.end_date >= p_date
               AND pc.as_asset_id = a.as_asset_id
               AND pc.start_date <= p_date
               AND pc.status_hist_id <> status_hist_id_del
               AND p.start_date <= p_date
               AND p.policy_id = a.p_policy_id
               AND pc.t_prod_line_option_id = pc1.t_prod_line_option_id
               AND a.p_asset_header_id = a1.p_asset_header_id
               AND a1.as_asset_id = pc1.as_asset_id
               AND pc1.p_cover_id = p_p_cover_id
             ORDER BY p.start_date  DESC
                     ,p.version_num DESC)
     WHERE rownum < 2;
    RETURN v_cover_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  -- �������� - �������� ����������� ������
  FUNCTION calc_cover_nonlife_return_sum(p_p_cover_id IN NUMBER) RETURN NUMBER IS
    v_cover         p_cover%ROWTYPE; -- �������� ������������ ������
    plo             t_prod_line_option%ROWTYPE;
    v_amount        pkg_payment.t_amount;
    dni_ost         NUMBER;
    dni_all         NUMBER;
    v_policy_decl   p_policy%ROWTYPE;
    v_policy        p_policy%ROWTYPE; -- ����������� ������ ������
    v_prev_cover    p_cover%ROWTYPE; -- ����������� ������ ��������
    v_charge_amount NUMBER;
    v_pay_amount    NUMBER;
    po_pay_sum      NUMBER;
    po_payoff_sum   NUMBER;
    po_charge_sum   NUMBER;
    po_com_sum      NUMBER;
    po_zsp_sum      NUMBER;
    po_decline_sum  NUMBER;
    v_decline_date  DATE;
    v_prorate       NUMBER;
  BEGIN
  
    SELECT c.* INTO v_prev_cover FROM p_cover c WHERE c.p_cover_id = p_p_cover_id;
  
    SELECT *
      INTO v_policy
      FROM p_policy
     WHERE policy_id IN (SELECT p.policy_id
                           FROM p_policy p
                               ,as_asset a
                          WHERE p.policy_id = a.p_policy_id
                            AND a.as_asset_id = v_prev_cover.as_asset_id
                          GROUP BY p.policy_id);
  
    SELECT *
      INTO v_cover
      FROM p_cover
     WHERE p_cover_id IN
           (SELECT MAX(pc.p_cover_id)
              FROM p_cover  pc
                  ,as_asset a
                  ,as_asset a1
             WHERE (pc.t_prod_line_option_id = v_prev_cover.t_prod_line_option_id AND
                   a.p_asset_header_id = a1.p_asset_header_id AND
                   a1.as_asset_id = v_prev_cover.as_asset_id AND pc.as_asset_id = a.as_asset_id));
    SELECT *
      INTO v_policy_decl
      FROM p_policy
     WHERE policy_id IN (SELECT p.policy_id
                           FROM p_policy p
                               ,as_asset a
                          WHERE p.policy_id = a.p_policy_id
                            AND a.as_asset_id = v_cover.as_asset_id
                          GROUP BY p.policy_id);
  
    SELECT nvl(v_policy_decl.decline_date, v_cover.decline_date) INTO v_decline_date FROM dual;
  
    SELECT p.* INTO plo FROM t_prod_line_option p WHERE p.id = v_cover.t_prod_line_option_id;
  
    v_prorate := trunc(MONTHS_BETWEEN(v_decline_date + 1, v_prev_cover.start_date)) /
                 trunc(MONTHS_BETWEEN(v_prev_cover.end_date + 1, v_prev_cover.start_date));
    -- ������ ���������� �����
    v_amount     := pkg_payment.get_pay_cover_amount(p_p_cover_id);
    v_pay_amount := v_amount.fund_amount;
    --v_charge_amount:= Pkg_Payment.get_charge_cover_amount(p_p_cover_id).fund_amount;
    v_charge_amount := pkg_payment.get_charge_cover_amount(p_p_cover_id,'PROLONG').fund_amount;
    po_pay_sum      := v_amount.fund_amount;
  
    -- ������ ����������� �����
    IF pkg_app_param.get_app_param_n('CLIENTID') = 10
    THEN
      BEGIN
        SELECT nvl(SUM(cc.payment_sum), 0)
          INTO po_payoff_sum
          FROM c_claim_header ch
              ,c_claim        cc
              ,c_claim_status cs
         WHERE ch.p_cover_id = v_prev_cover.p_cover_id
           AND cc.c_claim_header_id = ch.c_claim_header_id
           AND cc.seqno =
               (SELECT MAX(cl.seqno) FROM c_claim cl WHERE cl.c_claim_header_id = ch.c_claim_header_id)
           AND cs.c_claim_status_id = cc.claim_status_id
           AND cs.brief LIKE '�������'
           AND cc.claim_status_date <= v_cover.decline_date;
      EXCEPTION
        WHEN no_data_found THEN
          po_payoff_sum := 0;
      END;
    ELSE
      po_payoff_sum := 0;
    END IF;
  
    -- ������ �������� �� ������� ����
    --SELECT ROUND(NVL(ig.operation_cost, 0) * v_prev_cover.premium, 2)
    --  INTO po_charge_sum
    --  FROM T_INSURANCE_GROUP ig, T_PROD_LINE_OPTION plo, T_PRODUCT_LINE pl
    -- WHERE plo.id = v_cover.t_prod_line_option_id
    --   AND plo.product_line_id = pl.id
    --   AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ���=���%*(��������-������_��_����_������*prorate)
  
    SELECT ROUND(nvl(v_prev_cover.add_exp_proc / 100, nvl(ig.operation_cost, 0)) *
                 (v_pay_amount - v_charge_amount * v_prorate)
                ,2)
      INTO po_charge_sum
      FROM t_insurance_group  ig
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE plo.id = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ������ ����� ��������� ������
    -- todo �������������, ��� ������ ����� ���� ������ ���������� ���������
  
    --SELECT NVL(ROUND(SUM(pac.val_com) * v_prev_cover.premium / 100, 2), 0)
    --  INTO po_com_sum
    --  FROM P_COVER_AGENT ca, p_policy_agent_com pac
    -- WHERE ca.cover_id = p_p_cover_id and pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    SELECT nvl(ROUND(SUM(pac.val_com) * v_charge_amount / 100, 2), 0)
      INTO po_com_sum
      FROM p_cover_agent      ca
          ,p_policy_agent_com pac
     WHERE ca.cover_id = p_p_cover_id
       AND pac.p_policy_agent_com_id = ca.p_policy_agent_com_id;
  
    -- ������ ��� (�������)
    -- todo ������� ����������� ������ ��������� ������� ��� � ����� ��������
    IF (v_cover.start_date < v_decline_date AND v_cover.end_date > v_decline_date)
    THEN
      -- ��� �����
    
      IF (plo.description = '�����')
      THEN
        -- �����
        SELECT SUM(d.dni_ost)
              ,SUM(d.dni_all)
          INTO dni_ost
              ,dni_all
          FROM (SELECT --p.as_asset_id,
                 CASE
                   WHEN p.end_date < v_decline_date THEN
                    0
                   WHEN p.end_date >= v_decline_date
                        AND p.start_date <= v_decline_date THEN
                    (trunc(p.end_date) - trunc(v_decline_date))
                   WHEN p.start_date > v_decline_date THEN
                    (trunc(p.end_date) - trunc(p.start_date))
                 END dni_ost
                ,(trunc(p.end_date) - trunc(p.start_date) + 1) dni_all
                  FROM as_asset_per p
                 WHERE p.as_asset_id = v_cover.as_asset_id) d;
        --  po_zsp_sum := ROUND((v_prev_cover.premium - po_charge_sum) * (dni_all - dni_ost)/dni_all,2);
      
        po_zsp_sum := ROUND((v_charge_amount - po_charge_sum) * (dni_all - dni_ost) / dni_all, 2);
        -- ��� ���������
      ELSIF (plo.description = '���������' OR plo.description = '�����' OR
            plo.description = '���������� ������' OR plo.description = '����������� ���������������' OR
            plo.description = '�������������� ������������' OR plo.description = '����������� ������')
      THEN
        -- po_zsp_sum := ROUND(v_prev_cover.premium *
        --                     CEIL(MONTHS_BETWEEN( v_decline_date+1,v_cover.start_date))
        --                      /MONTHS_BETWEEN((v_cover.end_date+1),v_cover.start_date),
        --                     2);
      
        po_zsp_sum := ROUND(v_charge_amount * v_prorate, 2);
      
      ELSE
        -- po_zsp_sum := ROUND(v_prev_cover.premium*
        --                     ( v_decline_date - v_cover.start_date) /
        --                     (v_cover.end_date - v_cover.start_date),
        --                     2);
        po_zsp_sum := ROUND(v_charge_amount * (v_decline_date - v_cover.start_date) /
                            (v_cover.end_date - v_cover.start_date)
                           ,2);
      
      END IF;
    ELSIF v_cover.start_date > v_decline_date
    THEN
      po_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decline_date
    THEN
      --po_zsp_sum := v_prev_cover.premium;
      po_zsp_sum := v_charge_amount;
    END IF;
  
    -- ������ ����� ��������
    po_decline_sum := po_pay_sum - po_zsp_sum - po_payoff_sum;
  
    IF nvl(v_policy_decl.is_charge, nvl(v_cover.is_decline_charge, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum - po_charge_sum;
      --po_zsp_sum := po_zsp_sum + po_charge_sum;
    END IF;
  
    IF nvl(v_policy_decl.is_comission, nvl(v_cover.is_decline_comission, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum - po_com_sum;
      --po_zsp_sum := po_zsp_sum + po_com_sum;
    END IF;
  
    IF nvl(v_policy_decl.is_decline_payoff, nvl(v_cover.is_decline_payoff, 0)) = 1
    THEN
      po_decline_sum := po_decline_sum * (1 - po_payoff_sum / v_cover.ins_amount);
      --po_zsp_sum := po_zsp_sum + po_com_sum;
    END IF;
    IF po_decline_sum < 0
    THEN
      po_decline_sum := 0;
    END IF;
  
    IF po_zsp_sum > v_prev_cover.premium
    THEN
      po_zsp_sum := v_prev_cover.premium;
    END IF;
  
    UPDATE ven_p_cover pc
       SET pc.decline_summ = po_decline_sum
          ,pc.return_summ  = po_decline_sum
          ,pc.old_premium  = pc.premium + v_pay_amount - v_charge_amount
          ,pc.premium      = po_zsp_sum
          ,
           --  pc.IS_HANDCHANGE_DECLINE=1,
           --  pc.IS_HANDCHANGE_AMOUNT=1,
           --  pc.IS_HANDCHANGE_DEDUCT=1,
           --  pc.IS_HANDCHANGE_PREMIUM=1,
           --  pc.IS_HANDCHANGE_TARIFF=1,
           pc.add_exp_sum = po_charge_sum
          ,pc.ag_comm_sum = po_com_sum
          ,pc.payoff_sum  = po_payoff_sum
     WHERE pc.p_cover_id = v_cover.p_cover_id;
    RETURN po_decline_sum;
  END;

  /*
    ������ �.
    �������� �������� �� ����������, ���������� � ����������, ��� ��������� ���� ���������.
    ���� �������������� ������������� � ��������� �������
  */
  FUNCTION create_cover
  (
    par_as_asset_id              NUMBER
   ,par_prod_line_option_id      NUMBER
   ,par_period_id                NUMBER
   ,par_insured_age              NUMBER
   ,par_start_date               DATE
   ,par_end_date                 DATE
   ,par_ins_price                NUMBER
   ,par_ins_amount               NUMBER
   ,par_fee                      NUMBER
   ,par_premium                  NUMBER
   ,par_is_autoprolongation      NUMBER
   ,par_accum_period_end_age     NUMBER
   ,par_is_handchange_amount     NUMBER DEFAULT 0
   ,par_is_handchange_premium    NUMBER DEFAULT 0
   ,par_is_handchange_fee        NUMBER DEFAULT 0
   ,par_is_handchange_tariff     NUMBER DEFAULT 0
   ,par_is_handchange_ins_amount NUMBER DEFAULT 0
   ,par_is_handchange_k_coef_nm  NUMBER DEFAULT 0
   ,par_is_handchange_s_coef_nm  NUMBER DEFAULT 0
   ,par_is_handchange_deduct     NUMBER DEFAULT 0
   ,par_is_decline_payoff        NUMBER DEFAULT 0
   ,par_is_handchange_ins_price  NUMBER DEFAULT 0
   ,par_is_handchange_start_date NUMBER DEFAULT 0
   ,par_is_decline_charge        NUMBER DEFAULT 0
   ,par_is_decline_comission     NUMBER DEFAULT 0
   ,par_is_handchange_decline    NUMBER DEFAULT 0
   ,par_is_aggregate             NUMBER DEFAULT 0
   ,par_is_proportional          NUMBER DEFAULT 0
   ,par_status_hist_id           NUMBER DEFAULT 1 -- NEW
  ) RETURN NUMBER IS
    v_cover_id NUMBER;
  BEGIN
    SELECT sq_p_cover.nextval INTO v_cover_id FROM dual;
  
    IF par_start_date > par_end_date
    THEN
      raise_application_error(-20001
                             ,'���� ������ �������� ������ ���� ��������� ��������!');
    END IF;
  
    INSERT INTO ven_p_cover
      (p_cover_id
      ,as_asset_id
      ,t_prod_line_option_id
      ,period_id
      ,start_date
      ,end_date
      ,ins_price
      ,ins_amount
      ,status_hist_id
      ,is_avtoprolongation
      ,accum_period_end_age
      ,insured_age
      ,fee
      ,premium
      ,is_handchange_amount
      ,is_handchange_premium
      ,is_handchange_fee
      ,is_handchange_tariff
      ,is_handchange_ins_amount
      ,is_handchange_k_coef_nm
      ,is_handchange_s_coef_nm
      ,is_decline_payoff
      ,is_handchange_ins_price
      ,is_handchange_start_date
      ,is_decline_charge
      ,is_decline_comission
      ,is_handchange_decline
      ,is_handchange_deduct
      ,is_aggregate
      ,is_proportional)
    VALUES
      (v_cover_id
      ,par_as_asset_id
      ,par_prod_line_option_id
      ,par_period_id
      ,par_start_date
      ,par_end_date
      ,par_ins_price
      ,par_ins_amount
      ,par_status_hist_id
      ,par_is_autoprolongation
      ,par_accum_period_end_age
      ,par_insured_age
      ,par_fee
      ,par_premium
      ,par_is_handchange_amount
      ,par_is_handchange_premium
      ,par_is_handchange_fee
      ,par_is_handchange_tariff
      ,par_is_handchange_ins_amount
      ,par_is_handchange_k_coef_nm
      ,par_is_handchange_s_coef_nm
      ,par_is_decline_payoff
      ,par_is_handchange_ins_price
      ,par_is_handchange_start_date
      ,par_is_decline_charge
      ,par_is_decline_comission
      ,par_is_handchange_decline
      ,par_is_handchange_deduct
      ,par_is_aggregate
      ,par_is_proportional);
  
    RETURN v_cover_id;
  END create_cover;

  /* ������ �.
  
     ����������� � ����������� ��������� ���������� �������� ��� �������� �������������� � ��������� ��
  */
  PROCEDURE exclude_cover_group
  (
    par_cover_id  IN NUMBER
   ,par_asset_id  IN NUMBER
   ,par_policy_id IN NUMBER
  ) IS
    v_status_brief         VARCHAR2(30);
    v_prod_line_type_brief t_product_line_type.brief%TYPE;
    v_s                    NUMBER;
    v_policy_start_date    DATE;
    v_err                  VARCHAR2(1000);
    ----------
    v_amount              pkg_payment.t_amount;
    v_func_brief          t_prod_coef_type.brief%TYPE;
    v_decline_sum         NUMBER;
    v_return_sum          NUMBER;
    v_zsp                 NUMBER;
    v_charge_amount       NUMBER;
    v_pay_amount          NUMBER;
    v_premium             NUMBER;
    v_prod_line_option_id NUMBER;
  BEGIN
  
    /*exclude_child_covers(par_cover_id);*/
  
    /*----------exclude_child_covers-------------*/
    FOR pcov IN (SELECT pc.p_cover_id
                   FROM p_cover            pc
                       ,t_prod_line_option plo
                  WHERE pc.as_asset_id = par_asset_id
                    AND pc.status_hist_id != status_hist_id_del
                    AND pc.t_prod_line_option_id = plo.id
                    AND plo.product_line_id IN
                        (SELECT ppl.t_prod_line_id
                           FROM parent_prod_line ppl
                          WHERE ppl.t_parent_prod_line_id IN
                                (SELECT plop.product_line_id
                                   FROM t_prod_line_option plop
                                       ,p_cover            pcv
                                  WHERE plop.id = pcv.t_prod_line_option_id
                                    AND pcv.p_cover_id = par_cover_id)))
    LOOP
      exclude_cover_group(pcov.p_cover_id, par_asset_id, par_policy_id);
    END LOOP;
    /*----------/exclude_child_covers-------------*/
  
    SELECT sh.brief
          ,p.t_prod_line_option_id
          ,p.decline_summ
          ,p.premium
      INTO v_status_brief
          ,v_prod_line_option_id
          ,v_decline_sum
          ,v_premium
      FROM p_cover     p
          ,status_hist sh
     WHERE p.p_cover_id = par_cover_id
       AND p.status_hist_id = sh.status_hist_id(+);
  
    CASE v_status_brief
      WHEN 'NEW' THEN
        DELETE FROM ven_p_cover p WHERE p.p_cover_id = par_cover_id;
      WHEN 'CURRENT' THEN
        IF v_decline_sum IS NULL
        THEN
          --v_decline_sum := decline_cover(par_cover_id, v_policy_start_date);
        
          /*-----decline_cover------*/
          SELECT pp.start_date
            INTO v_policy_start_date
            FROM p_policy pp
           WHERE pp.policy_id = par_policy_id;
          -- ������ ���������� �����
          v_amount        := pkg_payment.get_pay_cover_amount(par_cover_id);
          v_pay_amount    := v_amount.fund_amount;
          v_charge_amount := pkg_payment.get_charge_cover_amount(par_cover_id,'PROLONG').fund_amount;
        
          -- ������ ��� �� ���������,
          -- ������������� �� ��������� ��� ������ ��������� �� ��������.
          BEGIN
            SELECT pct.brief
              INTO v_func_brief
              FROM t_metod_decline  md
                  ,t_prod_coef_type pct
             WHERE md.t_metod_decline_id = (SELECT t_prodline_metdec_met_decl_id
                                              FROM (SELECT plmd.t_prodline_metdec_met_decl_id
                                                      FROM t_product_line       pl
                                                          ,t_prod_line_option   plo
                                                          ,t_prod_line_met_decl plmd
                                                     WHERE plo.id = v_prod_line_option_id
                                                       AND plo.product_line_id = pl.id
                                                       AND plmd.t_prodline_metdec_prod_line_id = pl.id
                                                     ORDER BY nvl(plmd.is_default, 0) DESC)
                                             WHERE rownum = 1)
               AND pct.t_prod_coef_type_id = md.metod_func_id;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20000
                                     ,'�� ��������� �������� ������� ��� �� ���������');
          END;
          v_zsp         := pkg_tariff_calc.calc_fun(v_func_brief
                                                   ,ent.id_by_brief('P_COVER')
                                                   ,par_cover_id);
          v_return_sum  := v_zsp;
          v_decline_sum := v_amount.fund_amount - v_zsp;
        
          IF v_decline_sum < 0
          THEN
            v_decline_sum := 0;
          END IF;
          IF pkg_financy_weekend_fo.isfoweekpolicy(par_policy_id) = 0
          THEN
            UPDATE p_cover pc
               SET pc.premium      = pc.premium + v_pay_amount - v_charge_amount
                  ,pc.decline_summ = v_decline_sum
                  ,pc.return_summ  = v_decline_sum
                  ,pc.decline_date = v_policy_start_date
             WHERE pc.p_cover_id = par_cover_id
            RETURNING premium INTO v_premium;
          ELSE
            UPDATE p_cover pc
               SET pc.premium      = pc.premium + v_pay_amount - v_charge_amount
                  ,pc.decline_summ = v_decline_sum
                  ,pc.return_summ  = v_return_sum
                  ,pc.decline_date = v_policy_start_date
             WHERE pc.p_cover_id = par_cover_id;
          END IF;
          /*-----/decline_cover------*/
        END IF;
      
        set_cover_status(par_cover_id, 'DELETED');
      ELSE
        NULL;
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      v_err := SQLERRM;
      IF v_err LIKE '%ORA-02292%FK_TRANS_OBJ%'
      THEN
        raise_application_error(-20100
                               ,'���� ���������� �� ��������. ��������� ������� ������ � ������� � ������');
      ELSE
        RAISE;
      END IF;
  END exclude_cover_group;

  FUNCTION cover_array RETURN t_cover_array
    PIPELINED IS
    rw t_cover_rec;
  BEGIN
    FOR i IN 1 .. gv_cover_array.count --par_cover_array.count
    LOOP
      /*      rw.t_prod_line_opt_id      := par_cover_array(i).t_prod_line_opt_id;
      rw.exclude                 := par_cover_array(i).exclude;
      rw.start_date              := par_cover_array(i).start_date;
      rw.end_date                := par_cover_array(i).end_date;
      rw.fee                     := par_cover_array(i).fee;
      rw.ins_amount              := par_cover_array(i).period_id;
      rw.period_id               := par_cover_array(i).t_prod_line_opt_id;
      rw.premia_base_type        := par_cover_array(i).premia_base_type;
      rw.is_autoprolongation     := par_cover_array(i).is_autoprolongation;
      rw.is_handchange_amount    := par_cover_array(i).is_handchange_amount;
      rw.is_handchange_premium   := par_cover_array(i).is_handchange_premium;
      rw.is_handchange_fee       := par_cover_array(i).is_handchange_fee;
      rw.is_handchange_ins_price := par_cover_array(i).is_handchange_ins_price;
      rw.is_handchange_tariff    := par_cover_array(i).is_handchange_tariff;
      rw.status_hist_id          := par_cover_array(i).status_hist_id;*/
      PIPE ROW(gv_cover_array(i));
    END LOOP;
    RETURN;
  END;

  PROCEDURE create_cover_from_array
  (
    par_as_asset_id        NUMBER
   ,par_cover_array        t_cover_array DEFAULT t_cover_array()
   ,par_default_fee        NUMBER DEFAULT NULL
   ,par_default_ins_amount NUMBER DEFAULT NULL
   ,par_update_cover_sum   BOOLEAN DEFAULT TRUE
  ) IS
    v_product_id     NUMBER;
    v_cover_id       NUMBER;
    v_pol_start_date DATE;
    v_pol_end_date   DATE;
  
    v_base_sum p_policy.base_sum%TYPE;
  
    v_product_line_id          NUMBER;
    v_prod_line_option_brief   t_prod_line_option.brief%TYPE;
    v_prod_line_option_id      NUMBER;
    v_start_date               DATE;
    v_end_date                 DATE;
    v_fee                      NUMBER;
    v_ins_amount               NUMBER;
    v_proc                     g_program.proc%TYPE;
    v_period_id                NUMBER;
    v_premia_base_type         p_cover.premia_base_type%TYPE;
    v_is_autoprolongation      NUMBER(1);
    v_is_handchange_amount     p_cover.is_handchange_amount%TYPE;
    v_is_handchange_premium    p_cover.is_handchange_premium%TYPE;
    v_is_handchange_fee        p_cover.is_handchange_fee%TYPE;
    v_is_handchange_ins_price  p_cover.is_handchange_ins_price%TYPE;
    v_is_handchange_ins_amount p_cover.is_handchange_ins_amount%TYPE;
    v_is_handchange_tariff     p_cover.is_handchange_tariff%TYPE;
    v_status_hist_id           NUMBER;
    v_is_last                  NUMBER;
    CURSOR c_default IS
      SELECT t.product_line_id
            ,t.brief
            ,t.prod_line_option_id
            ,NULL start_date
            ,NULL end_date
            ,par_default_fee fee
            ,par_default_ins_amount ins_amount
            ,NULL period_id
            ,CASE
               WHEN par_default_fee IS NOT NULL
                    AND par_default_ins_amount IS NOT NULL THEN
                1
               ELSE
                0
             END premia_base_type
            ,NULL is_autoprolongation
            ,0 is_handchange_amount
            ,0 is_handchange_premium
            ,0 is_handchange_fee
            ,0 is_handchange_ins_price
            ,0 is_handchange_tariff
            ,NULL status_hist_id
            ,nvl2(lead(1) over(ORDER BY t.prod_line_level
                      ,CASE t.brief
                         WHEN 'RECOMMENDED' THEN
                          1
                         WHEN 'MANDATORY' THEN
                          2
                         WHEN 'OPTIONAL' THEN
                          3
                         ELSE
                          10
                       END)
                 ,0
                 ,1) is_last
        FROM (SELECT pl.id product_line_id
                    ,plt.brief
                    ,plo.id prod_line_option_id
                    ,MAX(LEVEL) prod_line_level
                FROM t_product_version   pv
                    ,t_product_ver_lob   pvl
                    ,t_product_line      pl
                    ,t_product_line_type plt
                    ,t_prod_line_option  plo
                    ,parent_prod_line    ppl
                    ,t_product           p
               WHERE p.product_id = v_product_id
                 AND pv.product_id = p.product_id
                 AND pv.t_product_version_id = pvl.product_version_id
                 AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                 AND pl.product_line_type_id = plt.product_line_type_id
                 AND pl.id = plo.product_line_id
                 AND pl.skip_on_policy_creation = 0
                 AND EXISTS (SELECT NULL
                        FROM t_as_type_prod_line tap
                            ,as_asset            aa
                            ,p_asset_header      ah
                       WHERE aa.as_asset_id = par_as_asset_id
                         AND aa.p_asset_header_id = ah.p_asset_header_id
                         AND ah.t_asset_type_id = tap.asset_common_type_id
                         AND tap.product_line_id = pl.id)
                 AND pkg_cover_control.precreation_cover_control(par_as_asset_id, pl.id) = 1
                 AND ppl.t_prod_line_id(+) = pl.id
              CONNECT BY PRIOR ppl.t_prod_line_id = ppl.t_parent_prod_line_id
               GROUP BY pl.id
                       ,plt.brief
                       ,plo.id) t
       ORDER BY t.prod_line_level
               ,CASE t.brief
                  WHEN 'RECOMMENDED' THEN
                   1
                  WHEN 'MANDATORY' THEN
                   2
                  WHEN 'OPTIONAL' THEN
                   3
                  ELSE
                   10
                END;
  
    CURSOR c_config IS
      SELECT t.product_line_id
            ,t.brief
            ,t.prod_line_option_id
            ,a.start_date
            ,a.end_date
            ,nvl(a.fee, par_default_fee) fee
            ,nvl(a.ins_amount, par_default_ins_amount) ins_amount
            ,a.proc
            ,a.period_id
            ,a.premia_base_type
            ,a.is_autoprolongation
            ,a.is_handchange_amount
            ,a.is_handchange_premium
            ,a.is_handchange_fee
            ,a.is_handchange_ins_price
            ,a.is_handchange_tariff
            ,a.status_hist_id
            ,nvl2(lead(1) over(ORDER BY t.prod_line_level
                      ,CASE t.brief
                         WHEN 'RECOMMENDED' THEN
                          1
                         WHEN 'MANDATORY' THEN
                          2
                         WHEN 'OPTIONAL' THEN
                          3
                         ELSE
                          10
                       END)
                 ,0
                 ,1) is_last
        FROM (SELECT pl.id product_line_id
                    ,plt.brief
                    ,plo.id prod_line_option_id
                    ,MAX(LEVEL) prod_line_level
                FROM t_product_version pv
                    ,t_product_ver_lob pvl
                    ,t_product_line pl
                    ,t_product_line_type plt
                    ,t_prod_line_option plo
                    ,parent_prod_line ppl
                    ,(TABLE(cover_array)) a
                    ,t_product p
               WHERE p.product_id = v_product_id
                 AND pv.product_id = p.product_id
                 AND pv.t_product_version_id = pvl.product_version_id
                 AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                 AND pl.product_line_type_id = plt.product_line_type_id
                 AND pl.id = plo.product_line_id
                 AND a.t_prod_line_opt_id = plo.id
                 AND EXISTS (SELECT NULL
                        FROM t_as_type_prod_line tap
                            ,as_asset            aa
                            ,p_asset_header      ah
                       WHERE aa.as_asset_id = par_as_asset_id
                         AND aa.p_asset_header_id = ah.p_asset_header_id
                         AND ah.t_asset_type_id = tap.asset_common_type_id
                         AND tap.product_line_id = pl.id)
                 AND nvl(a.exclude, 0) = 0
                 AND ppl.t_prod_line_id(+) = pl.id
                 AND NOT EXISTS (SELECT NULL
                        FROM parent_prod_line ppl1
                            ,t_prod_line_option plo1
                            ,(TABLE(cover_array)) a1
                       WHERE a1.t_prod_line_opt_id = plo1.id
                         AND plo1.product_line_id = ppl1.t_parent_prod_line_id
                         AND ppl1.t_prod_line_id = pl.id
                         AND nvl(a.exclude, 0) = 1)
              CONNECT BY PRIOR ppl.t_prod_line_id = ppl.t_parent_prod_line_id
               GROUP BY pl.id
                       ,plt.brief
                       ,plo.id) t
            ,TABLE(cover_array) a
       WHERE a.t_prod_line_opt_id = t.prod_line_option_id
       ORDER BY t.prod_line_level
               ,CASE t.brief
                  WHEN 'RECOMMENDED' THEN
                   1
                  WHEN 'MANDATORY' THEN
                   2
                  WHEN 'OPTIONAL' THEN
                   3
                  ELSE
                   10
                END;
  BEGIN
    SELECT ph.product_id
          ,pp.confirm_date -- ���������� �������� ����� confirm_date ��� start_date. � asset ������������ confirm_date
          ,pp.end_date
          ,pp.base_sum
      INTO v_product_id
          ,v_pol_start_date
          ,v_pol_end_date
          ,v_base_sum
      FROM as_asset     aa
          ,p_policy     pp
          ,p_pol_header ph
     WHERE aa.as_asset_id = par_as_asset_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    gv_cover_array := par_cover_array;
  
    IF par_cover_array IS NULL
       OR par_cover_array.count = 0
    THEN
      OPEN c_default;
    ELSE
      FOR i IN gv_cover_array.first .. gv_cover_array.last
      LOOP
        IF gv_cover_array(i).t_prod_line_opt_brief IS NOT NULL
            AND gv_cover_array(i).t_prod_line_opt_id IS NULL
        THEN
          BEGIN
            SELECT plo.id
              INTO gv_cover_array(i).t_prod_line_opt_id
              FROM t_prod_line_option plo
                  ,t_product_line     pl
                  ,t_product_ver_lob  pvl
                  ,t_product_version  pv
             WHERE pv.product_id = v_product_id
               AND pv.t_product_version_id = pvl.product_version_id
               AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id
               AND pl.id = plo.product_line_id
               AND plo.brief = gv_cover_array(i).t_prod_line_opt_brief;
          EXCEPTION
            WHEN no_data_found THEN
              raise_application_error(-20001
                                     ,'� ������� �������� �� ������ �� id, �� ���� ��������� � ��������.');
          END;
        END IF;
      END LOOP;
      OPEN c_config;
    END IF;
  
    BEGIN
      LOOP
        IF par_cover_array IS NULL
           OR par_cover_array.count = 0
        THEN
          FETCH c_default
            INTO v_product_line_id
                ,v_prod_line_option_brief
                ,v_prod_line_option_id
                ,v_start_date
                ,v_end_date
                ,v_fee
                ,v_ins_amount
                ,v_period_id
                ,v_premia_base_type
                ,v_is_autoprolongation
                ,v_is_handchange_amount
                ,v_is_handchange_premium
                ,v_is_handchange_fee
                ,v_is_handchange_ins_price
                ,v_is_handchange_tariff
                ,v_status_hist_id
                ,v_is_last;
          EXIT WHEN c_default%NOTFOUND;
        ELSE
          FETCH c_config
            INTO v_product_line_id
                ,v_prod_line_option_brief
                ,v_prod_line_option_id
                ,v_start_date
                ,v_end_date
                ,v_fee
                ,v_ins_amount
                ,v_proc
                ,v_period_id
                ,v_premia_base_type
                ,v_is_autoprolongation
                ,v_is_handchange_amount
                ,v_is_handchange_premium
                ,v_is_handchange_fee
                ,v_is_handchange_ins_price
                ,v_is_handchange_tariff
                ,v_status_hist_id
                ,v_is_last;
          EXIT WHEN c_config%NOTFOUND;
        END IF;
      
        IF v_proc IS NOT NULL
           AND v_base_sum IS NOT NULL
        THEN
        
          IF v_fee IS NULL
             AND nvl(v_premia_base_type, 0) = 1
          THEN
            v_fee               := v_base_sum * v_proc / 100;
            v_is_handchange_fee := 1;
          ELSIF v_ins_amount IS NULL
                AND nvl(v_premia_base_type, 0) = 0
          THEN
            v_ins_amount               := v_base_sum * v_proc / 100;
            v_is_handchange_ins_amount := 1;
          END IF;
        
        END IF;
      
        /* ������� �������� */
        v_cover_id := cre_new_cover(p_as_asset_id              => par_as_asset_id
                                   ,p_t_product_line_id        => v_product_line_id
                                   ,p_update_asset             => (v_is_last = 1)
                                   ,p_start_date               => v_start_date
                                   ,p_end_date                 => v_end_date
                                   ,p_period_id                => v_period_id
                                   ,p_fee                      => v_fee
                                   ,p_ins_amount               => v_ins_amount
                                   ,p_is_autoprolongation      => v_is_autoprolongation
                                   ,p_premia_base_type         => v_premia_base_type
                                   ,p_status_hist_id           => v_status_hist_id
                                   ,p_is_handchange_amount     => v_is_handchange_amount
                                   ,p_is_handchange_premium    => v_is_handchange_premium
                                   ,p_is_handchange_fee        => v_is_handchange_fee
                                   ,p_is_handchange_ins_price  => v_is_handchange_ins_price
                                   ,p_is_handchange_tariff     => v_is_handchange_tariff
                                   ,p_is_handchange_ins_amount => v_is_handchange_ins_amount);
      
        /* ������ �������� */
        IF par_update_cover_sum
        THEN
          update_cover_sum(p_p_cover_id => v_cover_id);
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF par_cover_array IS NULL
           OR par_cover_array.count = 0
        THEN
          CLOSE c_default;
        ELSE
          CLOSE c_config;
        END IF;
        RAISE;
    END;
  
  END;

  /*
    ������ �.
    ���������� ���������� �� ������������ ���������
  */
  PROCEDURE update_cover_children(par_policy_id NUMBER) IS
    v_version_num   p_policy.version_num%TYPE;
    v_pol_header_id p_policy.pol_header_id%TYPE;
  BEGIN
    SELECT pp.version_num
          ,pp.pol_header_id
      INTO v_version_num
          ,v_pol_header_id
      FROM p_policy pp
     WHERE pp.policy_id = par_policy_id;
  
    MERGE INTO p_cover trg
    USING (SELECT ttt.parent_cover_rsbu_id
                 ,ttt.parent_cover_ifrs_id
                 ,pc.rowid AS p_cover_rid
             FROM (SELECT t.p_cover_id AS parent_cover_rsbu_id
                         ,t.contact_id
                         ,t.plo_id
                         ,t.start_date
                         ,MIN(t.p_cover_id) over(PARTITION BY t.contact_id, t.plo_id, to_char(t.start_date, 'ddmm')) AS parent_cover_ifrs_id
                     FROM (SELECT MIN(pc.p_cover_id) p_cover_id
                                 ,su.assured_contact_id AS contact_id
                                 ,pc.t_prod_line_option_id AS plo_id
                                 ,pc.start_date
                             FROM p_policy   pp
                                 ,as_asset   se
                                 ,as_assured su
                                 ,p_cover    pc
                            WHERE pp.pol_header_id = v_pol_header_id
                              AND pp.version_num <= v_version_num
                              AND pp.policy_id = se.p_policy_id
                              AND se.as_asset_id = su.as_assured_id
                              AND se.as_asset_id = pc.as_asset_id
                           
                            GROUP BY su.assured_contact_id
                                    ,pc.t_prod_line_option_id
                                    ,pc.start_date) t) ttt
                 ,as_assured su
                 ,as_asset se
                 ,p_cover pc
            WHERE ttt.contact_id = su.assured_contact_id
              AND su.as_assured_id = se.as_asset_id
              AND se.as_asset_id = pc.as_asset_id
              AND pc.start_date = ttt.start_date
              AND pc.t_prod_line_option_id = ttt.plo_id
              AND se.p_policy_id = par_policy_id) src
    ON (src.p_cover_rid = trg.rowid)
    WHEN MATCHED THEN
      UPDATE
         SET trg.parent_cover_rsbu_id = src.parent_cover_rsbu_id
            ,trg.parent_cover_ifrs_id = src.parent_cover_ifrs_id;
  
  END update_cover_children;

BEGIN
  SELECT sh.status_hist_id INTO status_hist_id_new FROM ven_status_hist sh WHERE sh.brief = 'NEW';
  SELECT sh.status_hist_id
    INTO status_hist_id_curr
    FROM ven_status_hist sh
   WHERE sh.brief = 'CURRENT';
  SELECT sh.status_hist_id INTO status_hist_id_del FROM ven_status_hist sh WHERE sh.brief = 'DELETED';
END;
/

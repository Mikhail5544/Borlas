CREATE OR REPLACE PACKAGE pkg_gen_policy IS

  -- Author  : OPATSAN
  -- Created : 26.03.2007 13:42:49
  -- Purpose : Генеральный договор страхование

  PROCEDURE new_policy
  (
    p_gen_policy_id IN NUMBER
   ,p_header_id     OUT NUMBER
  );

  /**
  * Меняет аналогичные статусы у дочерних договоров страхования
  * @author Сыровецкий Д.
  * @param p_gen_policy_id - ИД ген.договора страхования
  */
  PROCEDURE change_status_proj_to_new(p_gen_policy_id IN NUMBER);

  /**
  * Меняет аналогичные статусы у дочерних договоров страхования
  * @author Сыровецкий Д.
  * @param p_gen_policy_id - ИД ген.договора страхования
  */
  PROCEDURE change_status_new_to_cur(p_gen_policy_id IN NUMBER);

END pkg_gen_policy;
/
CREATE OR REPLACE PACKAGE BODY PKG_GEN_POLICY IS

  PROCEDURE new_policy
  (
    p_gen_policy_id IN NUMBER
   ,p_header_id     OUT NUMBER
  ) IS
    v_id       NUMBER;
    v_st_id    NUMBER;
    v_st_date  DATE;
    v_st_brief VARCHAR2(255);
    v_row      ven_gen_policy%ROWTYPE;
  BEGIN
    SELECT sq_p_pol_header.nextval INTO p_header_id FROM dual;
  
    SELECT * INTO v_row FROM ven_gen_policy WHERE gen_policy_id = p_gen_policy_id;
  
    INSERT INTO ven_p_pol_header
      (policy_header_id
      ,doc_templ_id
      ,note
      ,reg_date
      ,company_tree_id
      ,confirm_condition_id
      ,fund_id
      ,fund_pay_id
      ,product_id
      ,sales_channel_id
      ,num
      ,start_date)
      SELECT p_header_id
            ,dt.doc_templ_id
            ,v_row.note
            ,SYSDATE
            ,v_row.company_tree_id
            ,v_row.confirm_condition_id
            ,v_row.fund_id
            ,v_row.fund_pay_id
            ,v_row.product_id
            ,v_row.sales_channel_id
            ,'na'
            ,v_row.start_date
        FROM doc_templ dt
       WHERE dt.brief = 'POL_HEADER';
  
    FOR rc IN (SELECT pa.p_policy_agent_id
                 FROM p_policy_agent pa
                WHERE pa.policy_header_id = p_gen_policy_id)
    LOOP
      SELECT sq_p_policy_agent.nextval INTO v_id FROM dual;
    
      INSERT INTO p_policy_agent
        (p_policy_agent_id
        ,policy_header_id
        ,ag_contract_header_id
        ,date_start
        ,date_end
        ,status_id
        ,part_agent
        ,ag_type_rate_value_id
        ,status_date)
        SELECT v_id
              ,p_header_id
              ,ag_contract_header_id
              ,date_start
              ,date_end
              ,status_id
              ,part_agent
              ,ag_type_rate_value_id
              ,status_date
          FROM p_policy_agent pa
         WHERE pa.p_policy_agent_id = rc.p_policy_agent_id;
    
      INSERT INTO p_policy_agent_com
        (p_policy_agent_com_id
        ,p_policy_agent_id
        ,val_com
        ,ag_type_rate_value_id
        ,t_product_line_id
        ,t_prod_coef_type_id
        ,ag_type_defin_rate_id)
        SELECT sq_p_policy_agent_com.nextval
              ,v_id
              ,val_com
              ,ag_type_rate_value_id
              ,t_product_line_id
              ,t_prod_coef_type_id
              ,ag_type_defin_rate_id
          FROM p_policy_agent_com pac
         WHERE pac.p_policy_agent_id = rc.p_policy_agent_id;
    
    END LOOP;
  
    SELECT sq_p_policy.nextval INTO v_id FROM dual;
  
    INSERT INTO ven_p_policy
      (policy_id
      ,pol_header_id
      ,pol_ser
      ,pol_num
      ,notice_date
      ,sign_date
      ,confirm_date
      ,confirm_date_addendum
      ,start_date
      ,end_date
      ,first_pay_date
      ,payment_term_id
      ,period_id
      ,doc_templ_id
      ,num
      ,reg_date
      ,version_num)
      SELECT v_id
            ,p_header_id
            ,'na'
            ,'na'
            ,v_row.notice_date
            ,v_row.sign_date
            ,v_row.confirm_date
            ,v_row.confirm_date
            ,v_row.start_date
            ,v_row.end_date
            ,v_row.first_pay_date
            ,v_row.payment_term_id
            ,v_row.period_id
            ,dt.doc_templ_id
            ,'na-na'
            ,SYSDATE
            ,1
        FROM doc_templ dt
       WHERE dt.brief = 'POLICY';
  
    INSERT INTO ven_p_policy_contact
      (policy_id, contact_id, CONTACT_POLICY_ROLE_ID)
      SELECT v_id
            ,v_row.insurer_id
            ,t.id
        FROM ven_t_contact_pol_role t
       WHERE t.brief = 'Страхователь';
  
    INSERT INTO ven_p_policy_contact
      (policy_id, contact_id, CONTACT_POLICY_ROLE_ID)
      SELECT v_id
            ,v_row.CURATOR_ID
            ,t.id
        FROM ven_t_contact_pol_role t
       WHERE t.brief = 'Куратор';
  
    UPDATE p_pol_header SET policy_id = v_id WHERE policy_header_id = p_header_id;
  
    v_st_id := nvl(doc.get_doc_status_id(p_gen_policy_id)
                  ,doc.get_doc_status_id(p_gen_policy_id, v_row.start_date));
    SELECT brief INTO v_st_brief FROM doc_status_ref WHERE doc_status_ref_id = v_st_id;
    v_st_date := doc.get_status_date(p_gen_policy_id, v_st_brief);
    --doc.set_doc_status(p_header_id, v_st_id);
    doc.set_doc_status(v_id, v_st_id, v_st_date);
  
    INSERT INTO ven_doc_doc (parent_id, child_id) VALUES (p_gen_policy_id, p_header_id);
  
  END;

  -----------------------------------------------------------------
  -----------------------------------------------------------------

  PROCEDURE change_status_proj_to_new(p_gen_policy_id IN NUMBER) IS
  
    v_date DATE;
  
    CURSOR cur(cur_gen_policy_id NUMBER) IS
      SELECT p.POLICY_ID
        FROM doc_doc          dd
            ,p_pol_header     ph
            ,p_policy         p
            ,p_policy_contact pc
       WHERE dd.parent_id = cur_gen_policy_id
         AND dd.child_id = ph.POLICY_HEADER_ID
         AND ph.policy_id = p.policy_id
         AND pc.policy_id = p.policy_id
         AND pc.contact_policy_role_id =
             ent.get_obj_id('t_contact_pol_role', 'Страхователь');
  BEGIN
  
    BEGIN
      v_date := doc.get_status_date(p_gen_policy_id, 'NEW');
    EXCEPTION
      WHEN OTHERS THEN
        v_date := SYSDATE;
    END;
    --raise_application_error (-20000, 'set status');
    FOR pol IN cur(p_gen_policy_id)
    LOOP
      IF doc.get_doc_status_brief(pol.policy_id, v_date) = 'PROJECT'
      THEN
        doc.set_doc_status(pol.policy_id, 'NEW', v_date);
      END IF;
    END LOOP;
  END;

  -----------------------------------------------------------------
  -----------------------------------------------------------------

  PROCEDURE change_status_new_to_cur(p_gen_policy_id IN NUMBER) IS
  
    v_date DATE;
  
    CURSOR cur(cur_gen_policy_id NUMBER) IS
      SELECT p.POLICY_ID
            ,p.pol_header_id
        FROM doc_doc          dd
            ,p_pol_header     ph
            ,p_policy         p
            ,p_policy_contact pc
       WHERE dd.parent_id = cur_gen_policy_id
         AND dd.child_id = ph.POLICY_HEADER_ID
         AND ph.policy_id = p.policy_id
         AND pc.policy_id = p.policy_id
         AND pc.contact_policy_role_id =
             ent.get_obj_id('t_contact_pol_role', 'Страхователь');
  BEGIN
    BEGIN
      v_date := doc.get_status_date(p_gen_policy_id, 'CURRENT');
    EXCEPTION
      WHEN OTHERS THEN
        v_date := SYSDATE;
    END;
    FOR pol IN cur(p_gen_policy_id)
    LOOP
      IF doc.get_doc_status_brief(pol.policy_id, v_date) = 'NEW'
      THEN
        doc.set_doc_status(pol.policy_id, 'CURRENT', v_date);
        pkg_payment.delete_unpayed(pol.pol_header_id);
      END IF;
    END LOOP;
  END;

-----------------------------------------------------------------
-----------------------------------------------------------------

END pkg_gen_policy;
/

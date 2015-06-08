CREATE OR REPLACE PACKAGE Pkg_Claim_Payment IS

  /**
  * ������� �� ����������
  * @author Patsan O.
  */

  /**
  * ����� � ������� �� ���������
  * @author Patsan O.
  * @param par_claim_id �� ������ ���������
  * @return ����� � �������
  */
  FUNCTION get_claim_payment_sum(par_claim_id NUMBER) RETURN NUMBER;

  /**
  * ��������� �� ���������
  * @author Patsan O.
  * @param par_claim_id �� ������ ���������
  * @return ����������� �����
  */
  FUNCTION get_claim_charge_sum(par_claim_id NUMBER) RETURN NUMBER;

  /**
  * ������������� � ������� �� ���������
  * @author Patsan O.
  * @param par_claim_id �� ������ ���������
  * @return ��������������� �����
  */
  FUNCTION get_claim_plan_sum(par_claim_id NUMBER) RETURN NUMBER;

  /**
  * ������������ �� ������� �� ���������
  * @author Patsan O.
  * @param par_claim_id �� ������ ���������
  * @return ����� ������������
  */
  FUNCTION get_claim_topay_sum(par_claim_id NUMBER) RETURN NUMBER;

  /**
  * ��������� �� ���������
  * @author Patsan O.
  * @param par_claim_id �� ������ ���������
  * @return ����� ������
  */
  FUNCTION get_claim_pay_sum(par_claim_id NUMBER) RETURN NUMBER;

  /**
  * ��������� �� ��������� �� ������
  * @author Balashov
  * @param par_claim_id �� ������ ���������
  * @return ����� ������
  */
  FUNCTION get_claim_pay_sum_per
  (
    par_claim_id NUMBER
   ,par_ds       DATE
   ,par_de       DATE
  ) RETURN NUMBER;

  /**
  * ��������� �� ������������
  * @author Patsan O.
  * @param par_paym_id �� ������������ �� �������
  * @return ����� ������
  */
  FUNCTION get_claim_paiment_setoff(par_paym_id IN NUMBER) RETURN NUMBER;

  /**
  * ���� �� ���� ������
  * ���� ��� ������ ���������, �� 22.01 ����� 26.02
  * @author Patsan O.
  * @param p_Entity_ID �� ��������
  * @param p_Object_ID �� �������
  * @param p_Fund_ID �� ������ �����
  * @param p_Date �� ����
  * @param p_Doc_ID �� ���������
  * @return �� �����
  */
  FUNCTION acc_by_damage_type
  (
    p_Entity_ID IN NUMBER
   ,p_Object_ID IN NUMBER
   ,p_Fund_ID   IN NUMBER
   ,p_Date      IN DATE
   ,p_Doc_ID    IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���� ������ �������� �� ����
  * @author Mirovich M.
  * @param c_claim_id -  �� ������ ����
  * @return  - ���� ��������
  */
  FUNCTION get_first_entry_date(c_claim_id NUMBER) RETURN DATE;

  /**
  * ���� ������� ������������
  * @author Mirovich M.
  * @param c_claim_id -  �� ������ ����
  * @return  - ���� ������������
  */
  FUNCTION get_first_account_date(c_claim_id NUMBER) RETURN DATE;
  /**
  * ����� �� ��������������� �������
  * @author Mirovich M.
  * @param p_pol_id -  �� ������ ��������
  * @return  - ����� �������
  */
  FUNCTION get_close_claim_summ(p_pol_id NUMBER) RETURN NUMBER;
  /**
  * ����� �� ����������������� �������
  * @author Mirovich M.
  * @param p_pol_id -  �� ������ ��������
  * @return  - ����� �������
  */
  FUNCTION get_un_close_claim_sum(p_pol_id NUMBER) RETURN NUMBER;

  /**
  * ����� �������������� �������� �������
  * @author ���������� �.
  * @param p_claim_header_id -  �� ��������� ���������
  * @param p_claim_id - �� ������ ��������� (����� ���� ������)
  * @return  - ����� �������
  */
  FUNCTION get_claim_adds_sum
  (
    p_claim_header_id NUMBER
   ,p_claim_id        NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * ����� ���� ��������� ����������, ��������� � ������ ����������
  * @author ������� �.
  * @param p_claim_header_id -  �� ��������� ���������
  * @return  - �����
  */
  FUNCTION get_claim_paymdoc_sum(p_claim_header_id NUMBER) RETURN NUMBER;

  /**
  * �������� ���� ��������� ������ ����(���������)
  * @author ������� �.
  * @param p_claim_header_id -  �� ��������� ���������
  * @return  - ���� ��������� ������ ���������
  */
  FUNCTION get_last_claim_ver_date(p_claim_header_id NUMBER) RETURN DATE;

END Pkg_Claim_Payment;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Claim_Payment IS

  FUNCTION get_claim_paymdoc_sum(p_claim_header_id NUMBER) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    SELECT NVL(SUM(ap.amount), 0)
      INTO v_sum
      FROM DOC_DOC        dd
          ,ven_ac_payment ap
          ,ven_c_claim    c
     WHERE dd.CHILD_ID = ap.PAYMENT_ID
       AND dd.PARENT_ID = c.c_claim_id
       AND c.C_CLAIM_HEADER_ID = p_CLAIM_HEADER_ID;
    RETURN v_sum;
  END;

  FUNCTION get_last_claim_ver_date(p_claim_header_id NUMBER) RETURN DATE IS
    v_date DATE;
  BEGIN
    SELECT c.claim_status_date
      INTO v_date
      FROM C_CLAIM c
     WHERE c.C_CLAIM_HEADER_ID = p_claim_header_id
       AND ROWNUM = 1
     ORDER BY c.C_CLAIM_ID DESC;
    RETURN v_date;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION get_claim_payment_sum(par_claim_id NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT SUM(ROUND(d.payment_sum *
                                Acc.Get_Cross_Rate_By_Id(1
                                                        ,d.damage_fund_id
                                                        ,ch.fund_id
                                                        ,c.claim_status_date)
                               ,2)) summ
                 FROM C_CLAIM            c
                     ,C_DAMAGE           d
                     ,C_DAMAGE_STATUS    ds
                     ,C_CLAIM_HEADER     ch
                     ,STATUS_HIST        sh
                     ,C_DAMAGE_TYPE      dt
                     ,C_DAMAGE_COST_TYPE dct
                WHERE c.c_claim_id = par_claim_id
                  AND d.c_claim_id = c.c_claim_id
                  AND ds.c_damage_status_id = d.c_damage_status_id
                  AND d.status_hist_id = sh.status_hist_id
                  AND c.c_claim_header_id = ch.c_claim_header_id
                  AND ds.brief IN ('������', '������')
                  AND sh.brief IN ('NEW', 'CURRENT')
                  AND d.c_damage_type_id = dt.c_damage_type_id
                  AND d.c_damage_cost_type_id = dct.c_damage_cost_type_id(+)
                  AND (dt.brief = '���������' OR dct.brief = '�����������')
               /*
               and doc.get_doc_status_brief(c.c_claim_id) = 'CLOSE'*/
               )
    LOOP
      RETURN NVL(rc.summ, 0);
    END LOOP;
  
    RETURN 0;
  END;

  FUNCTION get_claim_charge_sum(par_claim_id NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT SUM(ROUND(t.acc_amount --SLEZIN �� ������ 77870
                                /*               t.trans_amount * Acc.Get_Cross_Rate_By_Id(1,
                                t.trans_fund_id,
                                ch.fund_id,
                                t.trans_date)*/
                               ,2)) summ
                 FROM ins.v_trans    t
                     ,C_CLAIM        c
                     ,C_CLAIM_HEADER ch
                WHERE t.document_id = par_claim_id
                  AND c.c_claim_id = par_claim_id
                  AND ch.c_claim_header_id = c.c_claim_header_id
                  AND t.trans_templ_brief = '�������������')
    LOOP
      RETURN NVL(rc.summ, 0);
    END LOOP;
    RETURN 0;
  END;

  FUNCTION get_claim_plan_sum(par_claim_id NUMBER) RETURN NUMBER IS
    v_sum_all NUMBER;
    v_sum_new NUMBER;
  BEGIN
    FOR rc IN (SELECT SUM(ROUND(p.amount *
                                Acc.Get_Cross_Rate_By_Id(1, p.fund_id, ch.fund_id, p.due_date)
                               ,2)) summ
                 FROM ins.AC_PAYMENT p
                     ,DOC_DOC        dd
                     ,C_CLAIM        c
                     ,C_CLAIM_HEADER ch
                WHERE dd.parent_id = par_claim_id
                  AND c.c_claim_id = par_claim_id
                  AND ch.c_claim_header_id = c.c_claim_header_id
                  AND dd.child_id = p.payment_id
                  AND Doc.get_last_doc_status_brief(p.payment_id) = 'NEW')
    LOOP
      v_sum_new := NVL(rc.summ, 0);
    END LOOP;
    FOR rc IN (SELECT SUM(ROUND(p.amount *
                                Acc.Get_Cross_Rate_By_Id(1, p.fund_id, ch.fund_id, p.due_date)
                               ,2)) summ
                 FROM AC_PAYMENT     p
                     ,DOC_DOC        dd
                     ,C_CLAIM        c
                     ,C_CLAIM_HEADER ch
                WHERE dd.parent_id = par_claim_id
                  AND c.c_claim_id = par_claim_id
                  AND ch.c_claim_header_id = c.c_claim_header_id
                  AND dd.child_id = p.payment_id)
    LOOP
      v_sum_all := NVL(rc.summ, 0);
    END LOOP;
    RETURN(v_sum_new);
  END;

  FUNCTION get_claim_topay_sum(par_claim_id NUMBER) RETURN NUMBER IS
    v_sum NUMBER;
  BEGIN
    v_sum := 0;
    FOR rc IN (SELECT SUM(summ) summ1
                 FROM (SELECT SUM(ROUND(t.acc_amount --SLEZIN �� ������ 77870
                                        /*t.trans_amount * Acc.Get_Cross_Rate_By_Id(1,
                                        t.trans_fund_id,
                                        ch.fund_id,
                                        t.trans_date)*/
                                       ,2)) summ
                         FROM DOC_DOC        dd
                             ,v_trans        t
                             ,C_CLAIM        c
                             ,C_CLAIM_HEADER ch
                        WHERE dd.parent_id = par_claim_id
                          AND c.c_claim_id = par_claim_id
                          AND ch.c_claim_header_id = c.c_claim_header_id
                          AND dd.child_id = t.document_id
                          AND t.trans_templ_brief = '�������������'))
    LOOP
      v_sum := NVL(rc.summ1, 0);
    END LOOP;
    v_sum := v_sum - get_claim_pay_sum(par_claim_id);
    RETURN v_sum;
  END;

  FUNCTION get_claim_pay_sum(par_claim_id NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT SUM(summ) summ1
                 FROM (SELECT SUM(ROUND(t.acc_amount --SLEZIN �� ������ 77870
                                        /*               t.trans_amount * Acc.Get_Cross_Rate_By_Id(1,
                                        t.trans_fund_id,
                                        ch.fund_id,
                                        t.trans_date)*/
                                       ,2)) * (-1) summ
                         FROM DOC_DOC        dd
                             ,v_trans        t
                             ,DOC_SET_OFF    dso
                             ,C_CLAIM        c
                             ,C_CLAIM_HEADER ch
                        WHERE dd.parent_id = par_claim_id
                          AND dd.child_id = dso.child_doc_id
                          AND c.c_claim_id = par_claim_id
                          AND ch.c_claim_header_id = c.c_claim_header_id
                          AND t.document_id = dso.doc_set_off_id
                          AND t.trans_templ_brief IN ('�����������������')
                       UNION
                       SELECT SUM(ROUND(t.acc_amount --SLEZIN �� ������ 77870
                                        /*               t.trans_amount * Acc.Get_Cross_Rate_By_Id(1,
                                        t.trans_fund_id,
                                        ch.fund_id,
                                        t.trans_date)*/
                                       ,2)) summ
                         FROM DOC_DOC        dd
                             ,v_trans        t
                             ,DOC_SET_OFF    dso
                             ,C_CLAIM        c
                             ,C_CLAIM_HEADER ch
                        WHERE dd.parent_id = par_claim_id
                          AND dd.child_id = dso.parent_doc_id
                          AND c.c_claim_id = par_claim_id
                          AND ch.c_claim_header_id = c.c_claim_header_id
                          AND t.document_id = dso.doc_set_off_id
                          AND t.trans_templ_brief IN ('����������')))
    LOOP
      RETURN NVL(rc.summ1, 0);
    END LOOP;
    RETURN 0;
  END;

  -- ��������� �� ��������� �� ������
  FUNCTION get_claim_pay_sum_per
  (
    par_claim_id NUMBER
   ,par_ds       DATE
   ,par_de       DATE
  ) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT SUM(t.trans_amount) summ
                 FROM DOC_DOC     dd
                     ,v_trans     t
                     ,DOC_SET_OFF dso
                WHERE dd.parent_id = par_claim_id
                  AND dd.child_id = dso.parent_doc_id
                  AND t.document_id = dso.doc_set_off_id
                  AND t.trans_templ_brief IN
                      ('����������', '�����������������')
                  AND t.trans_date BETWEEN par_ds AND par_de)
    LOOP
      RETURN NVL(rc.summ, 0);
    END LOOP;
    RETURN 0;
  END;

  FUNCTION get_claim_paiment_setoff(par_paym_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT SUM(t.acc_amount) summ
                 FROM v_trans     t
                     ,DOC_SET_OFF dso
                WHERE par_paym_id = dso.parent_doc_id
                  AND t.document_id = dso.doc_set_off_id
                  AND t.trans_templ_brief IN
                      ('����������', '�����������������'))
    LOOP
      RETURN NVL(rc.summ, 0);
    END LOOP;
    RETURN 0;
  END;

  FUNCTION acc_by_damage_type
  (
    p_Entity_ID IN NUMBER
   ,p_Object_ID IN NUMBER
   ,p_Fund_ID   IN NUMBER
   ,p_Date      IN DATE
   ,p_Doc_ID    IN NUMBER
  ) RETURN NUMBER IS
    v_account_id NUMBER;
  
  BEGIN
    BEGIN
      SELECT a.account_id
        INTO v_account_id
        FROM ACC_CHART_TYPE act
            ,ACCOUNT        a
            ,C_DAMAGE       d
            ,C_DAMAGE_TYPE  dt
       WHERE act.brief = '���'
         AND a.acc_chart_type_id = act.acc_chart_type_id
         AND d.c_damage_id = p_Object_ID
         AND d.c_damage_type_id = dt.c_damage_type_id
         AND ((dt.brief = '���������' AND a.num = '22.01') OR
             (dt.brief <> '���������' AND a.num = '26.02'));
    
    EXCEPTION
      WHEN OTHERS THEN
        v_account_id := 0;
        DBMS_OUTPUT.PUT_LINE('�.�.�. "���� �� ���� ������"');
        DBMS_OUTPUT.PUT_LINE('�� ������ ���� �� ��������� ����������:');
        DBMS_OUTPUT.PUT_LINE('p_Entity_ID = ' || TO_CHAR(p_Entity_ID));
        DBMS_OUTPUT.PUT_LINE('p_Object_ID = ' || TO_CHAR(p_Object_ID));
        DBMS_OUTPUT.PUT_LINE('p_Fund_ID   = ' || TO_CHAR(p_Fund_ID));
        DBMS_OUTPUT.PUT_LINE('p_Date      = ' || TO_CHAR(p_Date, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('p_Doc_ID = ' || p_doc_id);
    END;
    RETURN v_account_id;
  END;

  -- ���������� ���� ������ �������� �� ����
  FUNCTION get_first_entry_date(c_claim_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT MIN(ap2.due_date)
      INTO d
      FROM ven_doc_doc dd
      JOIN ven_ac_payment ap
        ON ap.payment_id = dd.child_id
      JOIN ven_doc_set_off dso
        ON dso.parent_doc_id = ap.payment_id
      JOIN ven_ac_payment ap2
        ON dso.child_doc_id = ap2.payment_id
     WHERE dd.parent_id = c_claim_id;
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ���� ������� ������������ �� ����
  FUNCTION get_first_account_date(c_claim_id NUMBER) RETURN DATE IS
    d DATE;
  BEGIN
    SELECT MIN(ap.reg_date)
      INTO d
      FROM ven_doc_doc dd
      JOIN ven_ac_payment ap
        ON ap.payment_id = dd.child_id
     WHERE dd.parent_id = c_claim_id;
    RETURN(d);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- ���������� ����� �� ��������������� �������
  FUNCTION get_close_claim_summ(p_pol_id NUMBER) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT get_claim_pay_sum(cc.c_claim_id)
      INTO summ
      FROM ven_c_claim_header ch
      JOIN ven_c_claim cc
        ON cc.c_claim_id = ch.active_claim_id
     WHERE Doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE'
       AND ch.p_policy_id = p_pol_id;
    RETURN(summ);
  END;

  -- ���������� ����� ����������������� �������
  FUNCTION get_un_close_claim_sum(p_pol_id NUMBER) RETURN NUMBER IS
    summ NUMBER(11, 2);
  BEGIN
    SELECT SUM(cc.payment_sum)
      INTO summ
      FROM ven_c_claim_header ch
      JOIN ven_c_claim cc
        ON cc.c_claim_id = ch.active_claim_id
     WHERE Doc.get_doc_status_brief(cc.c_claim_id) != 'CLOSE'
       AND ch.p_policy_id = p_pol_id;
    RETURN(summ);
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_claim_adds_sum
  (
    p_claim_header_id NUMBER
   ,p_claim_id        NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_sum    NUMBER;
    v_sum_in NUMBER;
    v_ure_id NUMBER;
  BEGIN
    v_result := 0;
  
    SELECT ent_id INTO v_ure_id FROM ENTITY WHERE brief = 'C_CLAIM';
  
    FOR cur IN --���� �� ������� 1
     (SELECT *
        FROM (SELECT cc.c_claim_id
                    ,cc.c_claim_header_id
                    ,cd.t_damage_code_id
                    ,cd.c_damage_id
                    ,cc.seqno
                    ,MAX(cc.seqno) OVER(PARTITION BY cc.c_claim_header_id) max_seqno
                FROM C_CLAIM            CC
                    ,C_DAMAGE           CD
                    ,C_DAMAGE_TYPE      CDT
                    ,C_DAMAGE_COST_TYPE CDCT
               WHERE cc.c_claim_header_id = p_claim_header_id
                 AND cc.c_claim_id = NVL(p_claim_id, cc.c_claim_id)
                 AND cd.c_claim_id = cc.c_claim_id
                 AND CDT.c_damage_type_id = CD.c_damage_type_id
                 AND CDCT.c_damage_cost_type_id = CD.c_damage_cost_type_id
                 AND CDT.brief = '���������'
                 AND CDCT.brief = '�������������'
                 AND Doc.get_doc_status_brief(cc.c_claim_id) = 'CLOSE')
       WHERE seqno = max_seqno)
    LOOP
      --���� �� ������� 2
    
      SELECT NVL(SUM(t.trans_amount), 0)
        INTO v_sum
        FROM DOC_DOC dd
            ,v_trans t
            ,TRANS   ts
       WHERE dd.parent_id = cur.c_claim_id
         AND dd.child_id = t.document_id
         AND t.trans_templ_brief = '�������������'
         AND ts.trans_id = t.trans_id
         AND ts.obj_uro_id = cur.c_damage_id
         AND ts.obj_ure_id = v_ure_id;
      --c���� ���������� �� ������� �������
      v_result := v_result + v_sum;
      v_sum    := 0;
    
      FOR cur_pr IN (SELECT cc.c_claim_id
                           ,cd.c_damage_id
                       FROM C_CLAIM            CC
                           ,C_DAMAGE           CD
                           ,C_DAMAGE_TYPE      CDT
                           ,C_DAMAGE_COST_TYPE CDCT
                      WHERE cc.c_claim_header_id = cur.c_claim_header_id
                        AND cc.seqno = cur.max_seqno - 1
                        AND cd.c_claim_id = cc.c_claim_id
                        AND cd.t_damage_code_id = cur.t_damage_code_id
                        AND cdt.c_damage_type_id = cd.c_damage_type_id
                        AND cdct.c_damage_cost_type_id = cd.c_damage_cost_type_id
                        AND CDT.brief = '���������'
                        AND CDCT.brief = '�������������')
      LOOP
        SELECT NVL(SUM(t.trans_amount), 0)
          INTO v_sum_in
          FROM DOC_DOC dd
              ,v_trans t
              ,TRANS   ts
         WHERE dd.parent_id = cur_pr.c_claim_id
           AND dd.child_id = t.document_id
           AND t.trans_templ_brief = '�������������'
           AND ts.trans_id = t.trans_id
           AND ts.obj_uro_id = cur_pr.c_damage_id
           AND ts.obj_ure_id = v_ure_id;
      
        --����� ���������� �� ���������� ������
        v_sum := v_sum + v_sum_in;
      END LOOP;
      v_result := v_result - v_sum;
    END LOOP; --���� �� ������� 3
    RETURN v_result;
  END;
  --------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END Pkg_Claim_Payment;
/

CREATE OR REPLACE PACKAGE pkg_test IS

-- Author  : ABUDKOVA
-- Created : 14.09.2007 16:03:59
-- Purpose : 

END pkg_test;
/
CREATE OR REPLACE PACKAGE BODY pkg_test IS
  ---///��������� ���������� ������ ��������� ���������� �������������� (���) �� ����������� ������
  PROCEDURE av_oav_one
  (
    p_vedom_id       IN NUMBER --��� ��������� ������� �������������� ����������
   ,p_data_begin     IN DATE --���� ������ ��������� �������
   ,policy_agent_id  IN NUMBER -- �� ������ �� �������� ������������
   ,p_method_payment IN NUMBER --����� ������� ��(�� ���������� ������ , �� ������� ������)
   ,p_category_id    IN NUMBER --��������� ������
   ,p_err_code       IN OUT NUMBER --������ ���������� �������
  ) IS
  
    v_err_num      NUMBER := 0;
    v_ag_ch_id     NUMBER;
    v_ag_av_id     NUMBER;
    v_type_r_brief VARCHAR2(100);
    CURSOR k_tran IS
      SELECT t.trans_id -- ��� ����������
            ,pac.p_policy_agent_com_id
            ,pac.ag_type_defin_rate_id
            ,pac.ag_type_rate_value_id
            ,pac.t_prod_coef_type_id
            ,pac.val_com
            ,pa.part_agent -- ���� ������ � ��������
            ,pp.policy_id -- ��� ������ �������� �����������
            ,t.trans_date -- ���� ����������
            ,t.acc_amount -- ����� � ������ ����� �� ������ ������
            ,t.acc_rate -- ���� 
            ,NVL(pt.number_of_payments, 1) NOP -- ���������� ������ � ����
            ,NVL(pp.premium, 0) GP -- ����� ������
            ,ph.start_date -- ���� ������ �������� �����������
            ,'PERCENT' brief -- ������� ������������ ���� ������
        FROM ven_ac_payment      acp1 -- ����
            ,ac_payment_templ    apt
            ,doc_set_off         dso
            ,oper                o
            ,trans               t
            ,trans_templ         tt
            ,p_policy            pp
            ,p_policy_agent      pa -- a����� �� �������� �����������
            ,p_pol_header        ph -- ��������� �������� �����������
            ,p_policy_agent_com  pac
            ,t_payment_terms     pt
            ,t_prod_line_option  plo -- ������ ������ �� ������ (��������� �����������)
            ,policy_agent_status pas -- ������� ������� �� �������� �����������
       WHERE apt.payment_templ_id = acp1.payment_templ_id
         AND apt.brief = 'PAYMENT'
         AND dso.parent_doc_id = acp1.payment_id -- ����
         AND doc.get_doc_status_brief(acp1.payment_id, SYSDATE) = 'PAID'
         AND dso.doc_set_off_id = o.document_id
         AND o.oper_id = t.oper_id
         AND tt.trans_templ_id = t.trans_templ_id
         AND tt.brief = '�����������������������'
         AND NOT EXISTS
       (SELECT 1
                FROM trans tr
               WHERE tr.oper_id = o.oper_id
               GROUP BY tr.oper_id
              HAVING MAX(tr.trans_date) > last_day(p_data_begin)) -- ���� ��������� �������
         AND t.a2_ct_uro_id = pp.policy_id
         AND t.a4_ct_uro_id = plo.id
         AND ph.policy_header_id = pa.policy_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pac.p_policy_agent_id = pa.p_policy_agent_id
         AND pt.id = pp.payment_term_id
         AND plo.product_line_id = pac.t_product_line_id
         AND pa.status_id = pas.policy_agent_status_id
            --����� ���������� ��� ��������� �� ���� ��������� �������
         AND (pas.brief IN ('CURRENT', 'CANCEL') AND pa.date_end >= LAST_DAY(p_data_begin) AND
             pa.date_start < LAST_DAY(p_data_begin))
         AND pa.p_policy_agent_id = policy_agent_id -- ������� �� ����������� ������ ������� �� ���������
            -- ��� � ���������� �������� ���� �������� 
         AND NOT EXISTS (SELECT arc.agent_report_cont_id
                FROM agent_report_cont arc
               WHERE arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
                 AND arc.trans_id = t.trans_id);
  
    v_tran k_tran%ROWTYPE;
    v_OAV  NUMBER := 0;
    v_SAV  NUMBER := 0;
    --v_category_brief          number;
    --v_count                   number :=0;
    v_report_id  NUMBER;
    v_part_agent NUMBER;
    v_r_brief    VARCHAR2(50);
  BEGIN
    SELECT pa3.ag_contract_header_id
      INTO v_ag_ch_id
      FROM ven_p_policy_agent pa3
     WHERE pa3.p_policy_agent_id = policy_agent_id;
  
    SELECT t.t_ag_av_id INTO v_ag_av_id FROM ven_t_ag_av t WHERE t.brief = '���';
  
    Pkg_Agent_Rate.DATE_END := LAST_DAY(p_data_begin);
  
    BEGIN
      SELECT ar.agent_report_id
        INTO v_report_id
        FROM ven_agent_report ar
       WHERE v_ag_ch_id = ar.ag_contract_h_id
         AND ar.ag_vedom_av_id = p_vedom_id
      --and   ar.pr_part_agent    = v_part_agent
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_report_id := 0;
    END;
  
    -- ��� ���������� ������ � agent_report ����������� ����� ������
    IF v_report_id = 0
    THEN
      v_report_id := pkg_agent_rate.av_insert_report(p_vedom_id
                                                    ,v_ag_ch_id
                                                    ,v_ag_av_id
                                                    ,v_part_agent
                                                    ,p_err_code);
    END IF;
  
    OPEN k_tran;
    LOOP
      FETCH k_tran
        INTO v_tran.trans_id
            ,v_tran.p_policy_agent_com_id
            ,v_tran.ag_type_defin_rate_id
            ,v_tran.ag_type_rate_value_id
            ,v_tran.t_prod_coef_type_id
            ,v_tran.val_com
            ,v_tran.part_agent
            ,v_tran.policy_id
            ,v_tran.trans_date
            ,v_tran.acc_amount
            ,v_tran.acc_rate
            ,v_tran.nop
            ,v_tran.gp
            ,v_tran.start_date
            ,v_tran.brief;
      EXIT WHEN k_tran%NOTFOUND;
      -- ��������� �������� ����������
      v_OAV := 0;
      v_SAV := 0;
    
      Pkg_Agent_Rate.date_pay := v_tran.trans_date;
      v_sav                   := Pkg_Agent_Rate.get_rate_oab(v_tran.p_policy_agent_com_id);
    
      BEGIN
        SELECT rv.brief
          INTO v_r_brief
          FROM ven_ag_type_rate_value rv
         WHERE rv.ag_type_rate_value_id = v_tran.ag_type_rate_value_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_r_brief := '0';
      END;
      IF v_r_brief = 'ABSOL'
      THEN
        v_oav := v_sav * v_tran.part_agent / 100;
      ELSIF v_r_brief = 'PERCENT'
      THEN
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.acc_amount;
      ELSE
        v_oav := (v_sav / 100) * (v_tran.part_agent / 100) * v_tran.acc_amount;
        ---������
      END IF;
    
      -- ����������� BRIEF ��������� ������
      /*   begin
          select ca.brief into v_category_brief
          from ven_ag_category_agent ca
          where ca.ag_category_agent_id = p_category_id;
         exception when others then raise_application_error(sqlcode,'����������� BRIEF ��������� ������ '||sqlerrm);
          --p_err_num:=sqlcode;
         end;
         -- ������ ��������� ������
         if v_category_brief ='BZ' then
              --- ????? ����� ������� �� ������� ���
              -- ������ ���
              null;
         else
              -- ������ ������ �������: '0' = �� ���������� ������ ,'1' = �� ������� ������
              if p_method_payment = 0 then
                 --- ????? ����� ������� �� ������� ���
                 -- ������ ���
                 null;
              else
                    --������ v_tran.nop (number_of_payments) -- ���������� ������ � ����
                    if v_tran.nop = 1
                       then
                       --- ????? ����� ������� �� ������� ���
                       -- ������ ���
                       null;
                    elsif v_tran.nop <> 1 and  v_tran.start_date >= add_months(p_data_begin,12) -- ����� ����
                       then
                       --- ????? ����� ������� �� ������� ���
                       -- ������1 ��� (��� ����� ���������)
                       null;
                    elsif v_tran.nop <> 1 and  v_tran.start_date < add_months(p_data_begin,12) -- ����� ����                               -- ���� <> 1 � ���� ���������� ������ > ����
                       then
                       --- ????? ����� ������� �� ������� ���
                       -- ������1 ��� (��� ����� ���������)
                       null;
                    end if; -- ������ ���������� ������ � ����
              end if ;  -- ������ ������ �������
      
         -- �������� ������� ������������� ������ � ������� agent_report_cont
         -- ������� :����� ������� = "�� ������� ������",���������� ������ >1, policy_id, ���� ���������� < ����)
        if p_method_payment = 1 then -- ����� ������� = "�� ������� ������"
            begin
                select count(*)  into  v_count
                from  ven_agent_report ar
                join  ven_agent_report_cont arc on (arc.agent_report_id=ar.agent_report_id)
                where ar.ag_contract_h_id = p_ag_contract_header_id  -- �� ������
                and   arc.policy_id = v_tran.policy_id -- �� �������� �����������
                and   v_tran.nop > 1       -- ���������� ������ > 1
                ;
            exception when no_data_found then  v_count:=0 ;
            end;
      
             if    v_count= 0    then  -- ������ �� ����������
                  --OAV*80%
                  null;
             elsif v_count=1     then  -- ������ ����
                if     v_tran.start_date >   add_months(p_data_begin,11) -- ������� ����� 11 �������
                then
                  null; -- ���� ��� ��� ����������� ������ ��� ����!!!
                elsif v_tran.start_date < add_months(p_data_begin,11) -- ������� ����� ����
                then
                  --OAV*20%
                  null;
                end if;
             else -- ������� ���� -- ������� ��� ��� ������� ��������
                 null;
             end if;
         end if;  -- ����� ������� = "�� ������� ������"
      
        end if; -- ������� ��������� ������
      */
      -- ������ � �������
    
      -- �������� ������� ������������� ������ � ������� agent_report (p_vedom_id + ���� ������)
      -- �������� ���� ������ � ���� ����
      /* if    ( v_TRAN.brief = 'PERCENT' and   v_TRAN.part_agent= 100 ) -- �������
       then    v_part_agent:=0;
       else    v_part_agent:=1;
       end if;
      */
      --????
    
      -- ����� ��������� ������� � ������� agent_report_cont
      /*av_insert_report_cont( ROUND(v_oav,2)        --����� ��������
                          , v_report_id -- �� ����
                          , 0           -- c ����������/���
                          , v_tran.p_policy_agent_com_id
                          , v_tran.trans_id -- �����
                          , NULL --��� ���� ag_type_rate_value_id
                          , v_tran.part_agent
                          , v_sav --������ %
                          , v_tran.policy_id
                          , v_tran.trans_date
                          , v_tran.acc_amount
                          ,0
                          ,p_err_code);
      */
    END LOOP;
    CLOSE k_tran;
  
    --exception when others then p_err_code:=sqlcode;
  END;
END pkg_test;
/

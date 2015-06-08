CREATE OR REPLACE VIEW V_UREG_UBITKI AS
SELECT CASE
         WHEN p45 IN ('�������� �� ������'
                     ,'������'
                     ,'�������� � �������') THEN
          (CASE
            WHEN (amount > 0)
                 AND (nvl(paym, 0) - nvl(decl, 0)) * rate / amount > 0 THEN
             1
            ELSE
             0
          END)
         ELSE
          2
       END p51
      , --����
       p1
      , --� ���������, �������� ������ (�����  / �� �����)
       p2
      , --� ����
       p3
      , --� ������
       (SELECT ids FROM p_pol_header ph WHERE ph.policy_header_id = pol_header_id) ids
      , --ids
       pol_header_id
      ,p4
      , --��� ������ (������������� ��� ��������������)
       p5
      , --�������� ���������
       p6
      , --���������� ��������� �����������
       p7
      , --��������������
       p8
      , --���
       p9
      , --���� ��������
       p10
      , --���������
       p11
      , --�����
       p12
      , --��������
       p13
      , --�����
       p14
      , --��� �������
       p15
      , --���� ���������� �������� � ����
       p16
      , --���� ��������� �����������--date_in_company
       nvl(p17, '01.01.1900') p17
      , --���� ��������� ���� ����������--date_all_doc
       nvl(p20, '01.01.1900') p20
      , --���� ����������� ���������� �������--date_event
       nvl(p21, 0) p21
      , --���������� ���� �������� ������ �� ����������� ��
       p22
      , --�������
       CASE
         WHEN p22_2 = p22_1 THEN
          p22_1
         ELSE
          '-'
       END p22_1
      , --�������� ���������
       p23
      , --�������� ������, ����������� ���������� ������������� �������
       p24
      , --����� ��������������� ��  ������
       p25
      , --������
       CASE
         WHEN rate_ins_amount = 100 THEN
          rate_ins_amount
         WHEN p31 IS NULL THEN
          SUM((CASE
                WHEN amount > 0 THEN
                 ROUND(nvl(paym, 0) * rate / amount * 100, 1)
                ELSE
                 0
              END))
         ELSE
          0
       END p26
      , --% �� �� �����--ubitok_z
       CASE
         WHEN p31 IS NULL THEN
          SUM(ROUND((nvl(amount, 0)) * (CASE
                      WHEN amount > 0 THEN
                       ((nvl(paym, 0) - nvl(decl, 0)) * rate / amount)
                      ELSE
                       0
                    END)
                   ,2))
         ELSE
          0
       END p27
      , --����� ��������������� ���������� ����������� �� ������� �����  (��� ��������)
       nvl(p28_1, 0) p28_1
      , --����������������� ����� ��������������� ���������� ����������� �� ������� �����
       --09.12.2011_������ ���������� �������� ����.  ������� ������ ������
       CASE
         WHEN plan_date IS NULL THEN
          to_date('01.01.1900')
         WHEN pl_description IN ('������ ��������� �������'
                                ,'������ ��������� ������� ������������ �� �������� ���������'
                                ,'������������ �� ������ ������� ������������ �� �������� ���������'
                                ,'������������ �� ������ ���������� �������'
                                ,'������������ �� ������ ���������� ������� ������������ �� �������� ���������'
                                ,'������������ �� ������ ��������� �������')
         
          THEN
          ADD_MONTHS(plan_date
                    ,term_number_of_payments * CASE
                       WHEN interval_num >= 0 THEN
                        interval_num
                       ELSE
                        NULL
                     END)
         WHEN prod_brief IN ('OPS_Plus', 'OPS_Plus_2', 'OPS_Plus_New') THEN
          trunc(ADD_MONTHS(plan_date
                          ,1 * CASE
                             WHEN interval_num >= 0 THEN
                              interval_num
                             ELSE
                              NULL
                           END)
               ,'mm')
       END plan_date
      ,
       --������ ������ ��������� ������� (��� ������ ������ � ������������)
       --end_09.12.2011_������ ���������� �������� ����
       --nvl(plan_date,'01.01.1900') plan_date,--������ ������ ��������� ������� (��� ������ ������ � ������������)
       nvl(p30, '01.01.1900') p30
      , --���� ����������� � ������� (���� ����������� ���������� ����)--date_get_decision1
       nvl(p31, '01.01.1900') p31
      , --���� ������ � �������--date_get_decision2
       nvl(d_v, '01.01.1900') p32
      , --���� ������� (������� �� ����������� ����� ������)--date_ppi
       add_invest
      , --�������������� �������������� �����
       add_ins_sum
      , --�������������� ��������� �����      
       p37
      , --����� ������������ ���������� ����������� �� ������� ����� (��� ��������)--sum_ppi
       paym_amount
      , --09.12.2011_������ ���������� �������� ����  /���� �������������/
       paym_ids
      , --09.12.2011_������ ���������� �������� ����  /��� �� ������/
       non_insurer
      , --����������� �������, 91 ����
       paym_ndfl
      , --09.12.2011_������ ���������� �������� ����  /���������� ����/
       CASE
         WHEN nvl(paym_rate, 0) = 0 THEN
          paym_rate_ds
         ELSE
          paym_rate
       END paym_rate
      , --09.12.2011_������ ���������� �������� ����  /���� ������ �� ���� �������/
       risk_sum
      , --����� ��� ������ ���������������
       reinsurer_perc
      , --% ���������������
       --������� �� ������ �84295
       --nvl((case when p31 is null then sum( (nvl(amount,0)) * (case when amount > 0 then round((nvl(paym,0) - nvl(decl,0)) * rate / amount, 3) else 0 end) ) else 0 end) * (nvl(reinsurer_perc,0)/100),0) dl_reins,--���� ���������������
       --������ �� ������ �84295
       /*--������� �� ������ 172101: ��������� ������ - �������� ����� � ����� ��
       case when (case when p31 is null
                        then sum( round((nvl(amount,0)) * (case when amount > 0 then ((nvl(paym,0) - nvl(decl,0)) * rate / amount) else 0 end),2) )
                        else 0
                        end) > 0
             then (case when p37 > 0
                        then round((acc_new.get_rate_by_brief('��',fund_brief,msdate) * p28_1_1) * (reinsurer_perc / 100),2)
                        else round(p28_1_1 * (reinsurer_perc / 100),2)
                        end)
             else 0
       end dl_reins,*/ --���� ���������������
       --��������� �� ������ 172101: ��������� ������ - �������� ����� � ����� ��
       CASE
         WHEN offset_date IS NULL THEN
          CASE
            WHEN p31 IS NULL THEN
             SUM(ROUND((nvl(amount, 0)) * (CASE
                         WHEN amount > 0 THEN
                          ((nvl(paym, 0) - nvl(decl, 0)) * rate / amount)
                         ELSE
                          0
                       END) * (reinsurer_perc / 100)
                      ,2))
            ELSE
             0
          END --p27
         ELSE
          p37 * (reinsurer_perc / 100)
       END dl_reins
      , --���� ���������������
       nvl(reinsurer, '-') reinsurer
      , --��������������
       --������� �� ������ �84295
       --nvl(p24 - (p24*(reinsurer_perc/100)),0) p42,--����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       --������ �� ������ �84295
       /*--������� �� ������ 172101
       case when p37 <= 0 then 0
            else (p37  - round((acc_new.get_rate_by_brief('��',fund_brief,msdate) * p28_1_1) * (reinsurer_perc / 100),2))
       end p42*/
       --������ �� ������ 172101
       CASE
         WHEN offset_date IS NULL THEN
          0
         ELSE
          p37 * (1 - reinsurer_perc / 100)
       END p42
      , --����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       nvl(date_last_st, '01.01.1900') date_last_st
      , --���� ���������� �������
       p45
      , --������
       p46
      , --�����������--note
       st_note
      , --����������� � ������� ����
       nvl(p19_1, '01.01.1900') p19_1
      , --���� ������������ � ���� ��������� ���� ����������
       p45 p47
      , --�������� � �������������
       nvl(p49, '01.01.1900') p49
      , --���� �������� �� ������--date_oplata
       p50
      , --������� ������--otkaz
       claim_date
      , --���������
       claim_count
      , --���������� ���������
       '���' import
      ,policy_holder
      ,insurance_period
      ,date_to
      ,risk_name_progr
      ,risk_name
      ,
       
       TRIM(substr(p2, 1, instr(p2, '/') - 1)) ord1
      , --delo1
       to_number(TRIM(substr(p2, instr(p2, '/') + 1))) ord2
      , --delo2
       p110
      , --ch.c_claim_header_id
       p111
      , --clm.c_claim_id
       p112
       /*      , --e.c_event_id
       sales_channel AS "����� ������ (BI)"
       ,CASE
         WHEN sales_channel IN ('DSF', 'SAS', 'SAS 2', 'Call-Center', '������') THEN
          'DSF'
         WHEN sales_channel IN ('RLA'
                               ,'����������'
                               ,'���������� ��� ������'
                               ,'������� �������') THEN
          '����������'
         WHEN sales_channel IN ('����������') THEN
          '����������'
         WHEN sales_channel IN ('�������������') THEN
          '�������������'
         ELSE
          '�� ���������'
       END AS "����� ������ (��� ������)"
       ,product_group_name -- 221342*/
      ,pkg_policy.get_pol_sales_chn(policy_header_id, 'descr') AS "����� ������ (BI)"
       ,pkg_policy.get_pol_sales_chn(policy_header_id, 'group') AS "����� ������ (��� ������)"
       ,pkg_policy.get_pol_product_group(policy_header_id) AS product_group_name
       ,pay_terms

  FROM (SELECT /*+ LEADING (ch, paym_DS) USE_NL(ch, paym_DS)*/
         ch.c_claim_header_id p110
        ,clm.c_claim_id p111
        ,e.c_event_id p112
        ,CASE
           WHEN tp.id = 30500025 THEN
            '�'
           ELSE
            (nvl(CASE tp.insurance_group_id
                   WHEN 2404 THEN
                    '�'
                   WHEN 2800 THEN
                    '�' --������ 172102 �������� ���� � ���������, �������� �����
                   WHEN 2 THEN
                    '�'
                   ELSE
                    '�'
                 END
                ,'-'))
         END p1
        ,nvl(ch.num, '-') p2
        ,nvl(decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num), '-') p3
        ,
         --������ ���������� �� ������ 313472 �� ��������� ������������ � ������� ������� ��� ������
         --nvl(case nvl(p.is_group_flag,0) when 1 then '�������������' else (case when chl.id = 8 then '���������' else '��������������' end) end,'-') p4,
         --������ ��������� �� ������ 313472 �� ��������� ������������ � ������� ������� ��� ������
         nvl(CASE
               WHEN chl.id = 8 THEN
                '���������'
               ELSE
                (CASE nvl(p.is_group_flag, 0)
                  WHEN 1 THEN
                   '�������������'
                  ELSE
                   '��������������'
                END)
             END
            ,'-') p4
        ,nvl(prod.description, '-') p5
        ,nvl(prod.brief, '-') p6
        ,nvl(ent.obj_name('CONTACT', asu.assured_contact_id), '-') p7
        ,nvl(CASE nvl(casu.gender, 0)
               WHEN 0 THEN
                '�'
               ELSE
                '�'
             END
            ,'-') p8
        ,nvl(casu.date_of_birth, '01.01.1900') p9
        ,nvl(prof.description, '-') p10
        ,nvl(pkg_agent_1.get_agent_pol(p.pol_header_id, SYSDATE), '-') p11
        ,nvl(pkg_agent_1.get_agentlider_pol(p.pol_header_id, SYSDATE), '-') p12
        ,nvl(dep.name, '-') p13
        ,nvl(substr(pr.kladr_code, 1, 2), '') p14
        ,nvl(ph.start_date, '01.01.1900') p15
        ,trunc(e.date_company) p16
        ,
         --09.12.2011_������ ���������� �������� ����
         --max_date.msdate,
         (SELECT MAX(ds1.start_date) msdate
            FROM c_claim    c1
                ,document   d1
                ,doc_status ds1
           WHERE c1.c_claim_header_id = ch.c_claim_header_id
             AND c1.c_claim_id = d1.document_id
             AND ds1.doc_status_id = d1.doc_status_id) msdate
        ,
         --end_09.12.2011_������ ���������� �������� ����
         
         CASE pl.description
           WHEN '��������� ���������������� ���������� �������� �����������' THEN
            trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date), 0) / 12
           ELSE
            trunc(MONTHS_BETWEEN(p.end_date + 1, ph.start_date), 0) / 12
         END insurance_period
        ,
         
         (SELECT MAX(ds.start_date)
            FROM ven_c_claim clm2
                ,doc_status  ds
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = 122) p17
        ,(SELECT decode(rf.name, '��� ���������', clm2.claim_status_date)
            FROM ven_c_claim        clm2
                ,ins.document       da
                ,ins.doc_status_ref rf
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND clm2.c_claim_id = da.document_id
             AND rf.doc_status_ref_id = da.doc_status_ref_id
             AND rownum = 1
             AND rf.name = '��� ���������') p19
        ,
         
         (SELECT MAX(ds.start_date)
            FROM ven_c_claim clm2
                ,doc_status  ds
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = 129) p19_1
        ,
         
         nvl(e.event_date, '01.01.1900') p20
        ,nvl(e.event_date, '01.01.1900') - nvl(ph.start_date, '01.01.1900') p21
        ,nvl(e.diagnose, '-') p22
        ,
         
         (SELECT plo.description progr
            FROM p_policy            pp
                ,as_asset            ass
                ,p_cover             pc
                ,t_prod_line_option  plo
                ,t_product_line      pl
                ,t_product_line_type plt
           WHERE ass.p_policy_id = pp.policy_id
             AND pc.as_asset_id = ass.as_asset_id
             AND plo.id = pc.t_prod_line_option_id
             AND plo.product_line_id = pl.id
             AND pl.product_line_type_id = plt.product_line_type_id
             AND plt.brief = 'RECOMMENDED'
             AND upper(TRIM(plo.description)) <> '���������������� ��������'
             AND pp.policy_id = p.policy_id
             AND rownum = 1) p22_1
        ,pl.description p22_2
        ,
         
         /*case when pl.description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                        '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                        '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                        '������������ �� ������ ��������� �������') then pl.description
         when pl.description like '%�������%�� �����������%' then pl.description
         else tp.description end p23,*/CASE
           WHEN pl.description LIKE '������ ���������%' THEN
            pl.description
           WHEN pl.description LIKE '������������%' THEN
            pl.description
           WHEN pl.description LIKE '%�������%�� �����������%' THEN
            pl.description
           WHEN pl.description LIKE '%"����������� ��������������"%' THEN
            pl.description
           WHEN pl.description LIKE '��������� ���������������� ���������� �������� �����������' THEN
            pl.description
           ELSE
            tp.description
         END p23
        ,
         
         /*case when nvl(pc.ins_amount,0) = 0 then
                   nvl((select sum(plop.limit_amount)
                       from t_prod_line_opt_peril plop
                       where plop.product_line_option_id = pl.id
                             and plop.peril_id = tp.id),0)
         else nvl(pc.ins_amount,0)
         end*/CASE
           WHEN nvl(ch.is_handset_ins_sum, 0) = 1 THEN
            ch.ins_sum
           WHEN nvl(pc.ins_amount, 0) = 0 THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           WHEN dmg.t_damage_code_id IN
                (SELECT dt.id
                   FROM ins.t_damage_code dt
                  WHERE dt.code IN ('DOP_INVEST_DOHOD', 'ADD_INS_SUM'))
               --������ /218692] ��������� ���� 8462 � ��. �������������� ������� (�����)/
                AND (SELECT COUNT(1)
                       FROM c_damage dmg_s
                      WHERE (dmg_s.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg_s.c_claim_id AND
                            dmg_s.status_hist_id <> 3)) = 1
           --
            THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           ELSE
            nvl(pc.ins_amount, 0)
         END p24
        ,
         --nvl(pc.ins_amount,0) p24,
         nvl(f.brief, '-') p25
        ,
         
         --nvl(pc.ins_amount,0)
         /*case when nvl(pc.ins_amount,0) = 0 then
                   nvl((select sum(plop.limit_amount)
                       from t_prod_line_opt_peril plop
                       where plop.product_line_option_id = pl.id
                             and plop.peril_id = tp.id),0)
         else nvl(pc.ins_amount,0)
         end*/CASE
           WHEN nvl(ch.is_handset_ins_sum, 0) = 1 THEN
            ch.ins_sum
           WHEN nvl(pc.ins_amount, 0) = 0 THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           ELSE
            nvl(pc.ins_amount, 0)
         END amount
        ,
         
         nvl(dmg.decline_sum, 0) decl
        ,nvl(dmg.declare_sum, 0) paym
        ,nvl(acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, ch.declare_date), 1) rate
        ,
         
         e.c_event_id p28
        ,
         
         (SELECT SUM(ROUND(nvl(dmg.payment_sum, 0) *
                           acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, chx.declare_date)
                          ,2))
            FROM ven_c_claim_header chx
            JOIN ven_c_claim clm
              ON (chx.c_claim_header_id = clm.c_claim_header_id)
            JOIN c_damage dmg
              ON (clm.c_claim_id = dmg.c_claim_id)
            LEFT JOIN fund dmgf
              ON (dmgf.fund_id = dmg.damage_fund_id)
            LEFT JOIN fund f
              ON (chx.fund_id = f.fund_id)
           WHERE chx.c_claim_header_id = ch.c_claim_header_id
             AND clm.seqno = 1
          /*and doc.get_last_doc_status_name(clm.c_claim_id) = '���� ���������'*/
          ) p28_1
        ,
         
         (SELECT SUM(ROUND(nvl(dmg.payment_sum, 0) *
                           acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, chx.declare_date)
                          ,2))
            FROM ven_c_claim_header chx
            JOIN ven_c_claim clm
              ON (chx.c_claim_header_id = clm.c_claim_header_id)
            JOIN c_damage dmg
              ON (clm.c_claim_id = dmg.c_claim_id)
            LEFT JOIN fund dmgf
              ON (dmgf.fund_id = dmg.damage_fund_id)
            LEFT JOIN fund f
              ON (chx.fund_id = f.fund_id)
           WHERE chx.c_claim_header_id = ch.c_claim_header_id
             AND dmg.status_hist_id <> 3
             AND clm.seqno = (SELECT MAX(clml.seqno)
                                FROM ven_c_claim clml
                               WHERE clml.c_claim_header_id = ch.c_claim_header_id)) p28_1_1
        ,
         
         CASE
           WHEN (nvl(dmg.payment_sum, 0)) > 0 THEN
           
            (SELECT MAX(ds.start_date)
               FROM ven_c_claim clm2
                   ,doc_status  ds
              WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                AND ds.document_id = clm2.c_claim_id
                AND ds.doc_status_ref_id IN (128))
         END p30
        , --  -10 �������������,11 ������
         
         CASE
           WHEN (nvl(dmg.payment_sum, 0)) = 0 THEN
           
            (SELECT MAX(ds.start_date)
               FROM ven_c_claim clm2
                   ,doc_status  ds
              WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                AND ds.document_id = clm2.c_claim_id
                AND ds.doc_status_ref_id IN (128))
         END p31
        ,
         
         nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'), 0) +
         nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'), 0) p32
        ,0 p33
        ,'-' p34
        ,0 p35
        ,'-' p36
        ,
         
         nvl(pkg_renlife_utils.ret_sod_claim(ch.c_claim_header_id), '01.01.1900') d_v
        ,
         
         nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'), 0) new_pole1
        ,pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') new_pole2
        ,CASE
           WHEN ig.brief != 'NonInsuranceClaims' THEN
           
            nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') +
                pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�')
               ,0)
           ELSE
            0
         END p37
        ,
         /*nvl((select sum(
                     case when dso.set_off_date is not null then ac.rev_amount
                          else 0
                     end
                    )
         from doc_doc dd
              ,doc_set_off dso
              ,document d_p
              ,document d_ch
              ,doc_templ dt_p
              ,doc_templ dt_ch
              ,ven_ac_payment ac --PAYORDER ��� PAYORDER_SETOFF � ����������� �� �������
              ,doc_status_ref dsr
         where dd.parent_id = clm.c_claim_id
               and ig.brief != 'NonInsuranceClaims'
               and dso.parent_doc_id = d_p.document_id
               and dso.child_doc_id = d_ch.document_id
               and d_p.doc_templ_id = dt_p.doc_templ_id
               and d_ch.doc_templ_id = dt_ch.doc_templ_id
               and ((dd.child_id = dso.child_doc_id
                     and dt_ch.brief = 'PAYORDER_SETOFF'
                     and dt_p.brief = 'PAYMENT'
                     and ac.payment_id = d_ch.document_id) --��� ����� �� child
                   or(dd.child_id = dso.parent_doc_id
                     and dt_p.brief = 'PAYORDER'
                     and dt_ch.brief = '���'
                     and ac.payment_id = d_p.document_id)) --��� ����� �� parent
               and ac.doc_status_ref_id = dsr.doc_status_ref_id
               and dsr.brief = 'PAID'
               and dso.cancel_date is null),0) p37,*/ CASE
            WHEN ig.brief = 'NonInsuranceClaims' THEN
            
             pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') +
             pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�')
            ELSE
             0
          END
         /*nvl((select sum(
                      ac.rev_amount)
         from doc_doc dd
              ,doc_set_off dso
              ,document d_p
              ,document d_ch
              ,doc_templ dt_p
              ,doc_templ dt_ch
              ,ven_ac_payment ac --PAYORDER ��� PAYORDER_SETOFF � ����������� �� �������
              ,doc_status_ref dsr
         where dd.parent_id = clm.c_claim_id
               and ig.brief = 'NonInsuranceClaims'
               and dso.parent_doc_id = d_p.document_id
               and dso.child_doc_id = d_ch.document_id
               and d_p.doc_templ_id = dt_p.doc_templ_id
               and d_ch.doc_templ_id = dt_ch.doc_templ_id
               and ((dd.child_id = dso.child_doc_id
                     and dt_ch.brief = 'PAYORDER_SETOFF'
                     and dt_p.brief = 'PAYMENT'
                     and ac.payment_id = d_ch.document_id) --��� ����� �� child
                   or(dd.child_id = dso.parent_doc_id
                     and dt_p.brief = 'PAYORDER'
                     and dt_ch.brief = '���'
                     and ac.payment_id = d_p.document_id)) --��� ����� �� parent
               and ac.doc_status_ref_id = dsr.doc_status_ref_id
               and dsr.brief = 'PAID'
               and dso.cancel_date is null),0)*/ non_insurer
        ,
         
         '-' p38
        ,'-' p39
        ,'-' p40
        ,'-' p41
        ,'-' p43
        ,'-' p44
        ,nvl(doc.get_last_doc_status_name(ch.active_claim_id), '-') p45
        ,nvl(ds.note, '-') st_note
        ,nvl(d_clm.note, '-') p46
        ,
         
         '-' p47
        ,'-' p48
        ,(SELECT MAX(ds.start_date)
            FROM ven_c_claim clm2
                ,doc_status  ds
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = 129) p49
        ,nvl(pkg_renlife_utils.damage_decline_reason(pc.p_cover_id, ch.active_claim_id), '-') p50
        ,
         --nvl(dmg.decline_reason,'-') p50,
         p.pol_header_id
        ,nvl(cad.add_invest, 0) add_invest
        ,nvl(cad.add_ins_sum, 0) add_ins_sum
        ,nvl(cad.risk_sum, 0) risk_sum
        ,nvl(cad.reinsurer_perc, 0) reinsurer_perc
        ,
         
         CASE cad.reinsurer_id
           WHEN 1 THEN
            '��������� ���������������� ��������'
           WHEN 2 THEN
            '���������� ���������������� ��������'
           WHEN 3 THEN
            'SCOR'
           WHEN 4 THEN
            '���'
           ELSE
            '�� ���������'
         END reinsurer
        ,f.brief fund_brief
        ,
         /*--09.12.2011_������ ���������� �������� ����
         case when pl.description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                            '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                            '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                            '������������ �� ������ ��������� �������')
              then pkg_claim.GET_EPG_TO_EVENT(ch.c_event_id,ch.num,e.event_date,p.first_pay_date,12 / term.number_of_payments) else to_date('01.01.1900','dd.mm.yyyy') end plan_date*/
         
         --09.12.2011_������ ���������� �������� ����
         
         CASE
           WHEN ch.plan_date IS NOT NULL THEN
            ch.plan_date
           ELSE
            nearest_claim.plan_date
         END plan_date
        ,
         
         prod.brief prod_brief
        ,
         
         CASE
           WHEN term.is_periodical = 0 THEN
            0
           ELSE
            12 / term.number_of_payments
         END term_number_of_payments
        ,
         
         pl.description pl_description
        ,CASE
           WHEN ch.plan_date IS NOT NULL THEN
            0
           ELSE
            nvl(to_number(TRIM(substr(ch.num, instr(ch.num, '/') + 1))), 0) /*������� �����*/
            -nvl(nearest_claim.ver_num, 0) --��������� �����
         END interval_num
        ,
         
         nvl(ROUND(paym_amount, 2), 0) paym_amount
        ,nvl(paym_ids, 0) paym_ids
        ,
         --������ �������������� ������� ���������� /���. ���� ������ � ���. ������ ��� (����. ����. �� ���� ���� ������)/
         nvl((SELECT MAX(dso_1.ndfl_tax)
               FROM ins.c_claim cc_1 --/������/187960: �� ����������� ���� � ���� 6314/2/
                   ,doc_doc     dd_1
                   ,doc_set_off dso_1
                   ,document    d_1
                   ,doc_templ   dt_1
              WHERE /*dd_1.parent_id = clm.c_claim_id*/ --���������������/������/187960/
              cc_1.c_claim_header_id = clm.c_claim_header_id --�������/������/187960/
          AND dd_1.parent_id = cc_1.c_claim_id
          AND dd_1.child_id = dso_1.parent_doc_id
          AND d_1.document_id = dso_1.child_doc_id
          AND dt_1.doc_templ_id = d_1.doc_templ_id
          AND dt_1.brief = '���'
          AND dso_1.set_off_date = (SELECT MAX(dso_2.set_off_date)
                                      FROM ins.c_claim cc_2 --/������/187960: �� ����������� ���� � ���� 6314/2/
                                          ,doc_doc     dd_2
                                          ,doc_set_off dso_2
                                     WHERE /*dd_2.parent_id = dd_1.parent_id*/ --���������������/������/187960/
                                     cc_2.c_claim_header_id = cc_1.c_claim_header_id --�������/������/187960/
                                 AND dd_2.parent_id = cc_2.c_claim_id
                                 AND dd_2.child_id = dso_2.parent_doc_id
                                 AND nvl(dso_2.ndfl_tax, 0) > 0))
            ,0) paym_ndfl
        ,
         
         --������ �������������� ������� ���������� /���� /
         (SELECT MAX(dso_1.set_off_rate)
            FROM c_claim     cc_1
                ,doc_doc     dd_1
                ,doc_set_off dso_1
                ,document    d_1
                ,doc_templ   dt_1
           WHERE cc_1.c_claim_header_id = ch.c_claim_header_id
             AND dd_1.parent_id = cc_1.c_claim_id
             AND d_1.document_id = dso_1.child_doc_id
             AND dt_1.doc_templ_id = d_1.doc_templ_id
             AND dt_1.brief = '���'
             AND dso_1.parent_doc_id = dd_1.child_id
             AND dso_1.set_off_date = (SELECT MAX(dso_2.set_off_date)
                                         FROM c_claim     cc_2
                                             ,doc_doc     dd_2
                                             ,doc_set_off dso_2
                                             ,document    d_2
                                             ,doc_templ   dt_2
                                        WHERE cc_2.c_claim_header_id = cc_1.c_claim_header_id
                                          AND dd_2.parent_id = cc_2.c_claim_id
                                          AND dd_2.child_id = dso_2.parent_doc_id
                                          AND d_2.document_id = dso_2.child_doc_id
                                          AND dt_2.doc_templ_id = d_2.doc_templ_id
                                          AND dt_2.brief = '���')) paym_rate
        , --���� ������ �� ���� �������
         nvl(ROUND(paym_ds.paym_rate, 4), 0) paym_rate_ds
        , --���� ������ � PAYMENT (������������ ���� ��� ���)
         
         --nvl(paym_rate,0)paym_rate,
         
         nvl((SELECT MAX(ccd.c_claim_date)
               FROM c_claim_dates ccd
              WHERE ccd.c_claim_header_id = ch.c_claim_header_id)
            ,'01.01.1900') claim_date
        ,(SELECT COUNT(ccd.c_claim_date)
            FROM c_claim_dates ccd
           WHERE ccd.c_claim_header_id = ch.c_claim_header_id) claim_count
        ,
         
         --end_09.12.2011_������ ���������� �������� ����
         --172101: ��������� ������ - �������� ����� � ����� ��
         (SELECT MAX(dso_.set_off_date)
            FROM c_claim        cc_
                ,doc_doc        dd_
                ,document       d_ac_
                ,doc_templ      dt_ac_
                ,doc_set_off    dso_
                ,document       d_dso_
                ,doc_status_ref dsr_dso_
           WHERE cc_.c_claim_header_id = clm.c_claim_header_id
             AND dd_.parent_id = cc_.c_claim_id
             AND dd_.child_id = d_ac_.document_id
             AND d_ac_.doc_templ_id = dt_ac_.doc_templ_id
             AND ((dso_.parent_doc_id = d_ac_.document_id AND dt_ac_.brief = 'PAYORDER') OR
                 (dso_.child_doc_id = d_ac_.document_id AND dt_ac_.brief = 'PAYORDER_SETOFF'))
             AND d_dso_.document_id = dso_.doc_set_off_id
             AND dsr_dso_.doc_status_ref_id = d_dso_.doc_status_ref_id
             AND dso_.cancel_date IS NULL
             AND dsr_dso_.brief != 'ANNULATED') offset_date
        ,
         --end--172101: ��������� ������ - �������� ����� � ����� ��
         
         (SELECT MAX(ds.start_date)
            FROM ven_c_claim    clm2
                ,doc_status     ds
                ,doc_status_ref rf
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = rf.doc_status_ref_id) date_last_st
        ,cpol.obj_name_orig policy_holder
        ,CASE
           WHEN decode(pc.is_avtoprolongation, 1, '��', 0, '���', '���') = '��' THEN
            (CASE
              WHEN decode(ig.life_property, 0, 'C', 1, 'L', NULL) = 'C' THEN
               (CASE
                 WHEN MOD(trunc(MONTHS_BETWEEN(p.end_date + 1, ph.start_date), 0) / 12, 1) = 0 THEN
                  (CASE
                    WHEN extract(YEAR FROM pc.end_date) - extract(YEAR FROM pc.start_date) > 1 THEN
                     (CASE extract(YEAR FROM ph.start_date)
                       WHEN 2005 THEN
                        ph.start_date + 364 + 364 + 364 + 365
                       WHEN 2006 THEN
                        ph.start_date + 364 + 364 + 365
                       WHEN 2007 THEN
                        ph.start_date + 364 + 365
                       WHEN 2008 THEN
                        ph.start_date + 365
                       ELSE
                        pc.end_date
                     END)
                    ELSE
                     pc.end_date
                  END)
                 ELSE
                  pc.end_date
               END)
              ELSE
               pc.end_date
            END)
           ELSE
            pc.end_date
         END date_to
        ,ll.description risk_name_progr
        ,opt.description risk_name
        ,CASE
           WHEN dmg.t_damage_code_id IN
                (SELECT dt.id FROM ins.t_damage_code dt WHERE dt.code IN 'DOP_INVEST_DOHOD')
               --������ /218692] ��������� ���� 8462 � ��. �������������� ������� (�����)/
                AND (SELECT COUNT(1)
                       FROM c_damage dmg_s
                      WHERE (dmg_s.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg_s.c_claim_id AND
                            dmg_s.status_hist_id <> 3)) = 1
           --
            THEN
            100
           ELSE
            1
         END rate_ins_amount
         /*,
         --������/217363 ���������� ����� � ����� "��. �������������� ������� (�����)"
          nvl((SELECT sch_.description
                FROM ins.ven_ag_contract_header ach_
                    ,p_policy_agent_doc         pad_
                    ,t_sales_channel            sch_
                    ,document                   d_pad
                    ,ins.doc_status_ref         dsr_pad
               WHERE sch_.id = ach_.t_sales_channel_id
                 AND pad_.ag_contract_header_id = ach_.ag_contract_header_id
                 AND ach_.ag_contract_header_id = ach_.ag_contract_header_id
                 AND d_pad.document_id = pad_.p_policy_agent_doc_id
                 AND dsr_pad.doc_status_ref_id = d_pad.doc_status_ref_id
                 AND dsr_pad.brief IN ('CURRENT')
                    --
                 AND pad_.policy_header_id = p.pol_header_id
                 AND rownum = 1)
             ,(SELECT sch_.description
                FROM ins.ven_ag_contract_header ach_
                    ,p_policy_agent_doc         pad_
                    ,t_sales_channel            sch_
                    ,document                   d_pad
                    ,ins.doc_status_ref         dsr_pad
               WHERE sch_.id = ach_.t_sales_channel_id
                 AND pad_.ag_contract_header_id = ach_.ag_contract_header_id
                 AND ach_.ag_contract_header_id = ach_.ag_contract_header_id
                 AND d_pad.document_id = pad_.p_policy_agent_doc_id
                 AND dsr_pad.doc_status_ref_id = d_pad.doc_status_ref_id
                 AND dsr_pad.brief IN ('NEW')
                    --
                 AND pad_.policy_header_id = p.pol_header_id
                 AND rownum = 1)) AS sales_channel*/ --����� �� ��������� -- 315513: ���� ������ ��������/������ ������ � ���������� 2014
         --217363
         --,prodgroup.name product_group_name -- 221342
        ,ph.policy_header_id
        ,term.description    pay_terms
          FROM ven_c_claim_header ch
        --join ven_c_claim clm on (ch.c_claim_header_id = clm.c_claim_header_id)
          JOIN c_claim clm
            ON (ch.active_claim_id = clm.c_claim_id)
          JOIN p_policy p
            ON ch.p_policy_id = p.policy_id
        
          JOIN p_policy_contact pcnt
            ON (pcnt.policy_id = p.policy_id)
          JOIN t_contact_pol_role polr
            ON (polr.brief = '������������' AND pcnt.contact_policy_role_id = polr.id)
          JOIN contact cpol
            ON (cpol.contact_id = pcnt.contact_id)
          JOIN c_event e
            ON (ch.c_event_id = e.c_event_id)
        ----������ �������������� ������� ����������
        /*join c_declarants cds on cds.c_claim_header_id = ch.c_claim_header_id
        join c_event_contact ec on ec.c_event_contact_id = cds.declarant_id
        join c_declarant_role dr on dr.c_declarant_role_id = cds.declarant_role_id*/
        --join c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
        --join c_declarant_role dr on ch.declarant_role_id = dr.c_declarant_role_id --������ �������������� ������� ����������
        --end_������ �������������� ������� ����������
        --join contact c on ec.cn_person_id = c.contact_id
          LEFT JOIN ven_cn_person per
            ON (ch.curator_id = per.contact_id) --������ 261659 ����� ���������/�������� ����� ����������
          LEFT JOIN department ct
            ON ch.depart_id = ct.department_id
          LEFT JOIN as_asset a
            ON ch.as_asset_id = a.as_asset_id
          LEFT JOIN as_assured asu
            ON asu.as_assured_id = a.as_asset_id
          LEFT JOIN cn_person casu
            ON casu.contact_id = asu.assured_contact_id
          LEFT JOIN t_profession prof
            ON (casu.profession = prof.id)
          LEFT JOIN fund f
            ON (ch.fund_id = f.fund_id)
          JOIN c_claim_metod_type cmt
            ON ch.notice_type_id = cmt.c_claim_metod_type_id
          LEFT JOIN p_cover pc
            ON (ch.p_cover_id = pc.p_cover_id)
          LEFT JOIN t_prod_line_option pl
            ON pc.t_prod_line_option_id = pl.id
        
          LEFT JOIN ins.t_product_line pll
            ON (pll.id = pl.product_line_id)
          LEFT JOIN ins.t_lob_line ll
            ON (pll.t_lob_line_id = ll.t_lob_line_id)
          LEFT JOIN ins.t_insurance_group ig
            ON (ig.t_insurance_group_id = ll.insurance_group_id)
        
          JOIN p_pol_header ph
            ON ph.policy_header_id = p.pol_header_id
          JOIN t_payment_terms term
            ON (term.id = p.payment_term_id)
          LEFT JOIN t_sales_channel chl
            ON (chl.id = ph.sales_channel_id)
          LEFT JOIN department dep
            ON dep.department_id = ph.agency_id
          LEFT JOIN organisation_tree ot
            ON (ot.organisation_tree_id = dep.org_tree_id)
          LEFT JOIN t_province pr
            ON (pr.province_id = ot.province_id)
          LEFT JOIN t_product prod
            ON prod.product_id = ph.product_id
          LEFT JOIN t_product_group prodgroup
            ON (prod.t_product_group_id = prodgroup.t_product_group_id)
          LEFT JOIN t_peril tp
            ON tp.id = ch.peril_id
          LEFT JOIN t_prod_line_option opt
            ON (opt.id = pc.t_prod_line_option_id)
          LEFT JOIN c_damage dmg
            ON (dmg.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg.c_claim_id AND
               dmg.status_hist_id <> 3 AND
               --381316 ��������� �. ������� �� ����������� ���� ����� (dmg.c_claim_id) ������� ������ ���� ��� ������ ����,  
               --���, ���� ��� ����� 0, �� ����� �� ���� ����� ����� ������� ������ ���� ������������. 
               --��� �����, ����� ������ ������, ����� ��������� ������ (������� �������) �� ��������� ����� ����� �������, �� �� ������� � �����.
               (nvl(dmg.payment_sum,0) > 0 OR
               (nvl(dmg.payment_sum,0) = 0 AND
               (SELECT nvl(SUM(dmg_.payment_sum),0)
                     FROM c_damage           dmg_
                         ,ven_c_claim_header ch_
                    WHERE 1 = 1
                      AND ch.c_claim_header_id = ch_.c_claim_header_id
                      AND ch_.active_claim_id = dmg_.c_claim_id
                      --AND ch_.c_claim_header_id = 114077629
                      ) = 0)))
          LEFT JOIN c_claim_add cad
            ON (cad.c_claim_id = clm.c_claim_id)
        
        /*--09.12.2011_������ ���������� �������� ����
           left join (select max(ds.start_date) msdate, chk.c_claim_header_id
                   from ven_c_claim c,
                   ven_c_claim_header chk,
                   doc_status ds
                   where chk.c_claim_header_id = c.c_claim_header_id
                         and ds.document_id = c.c_claim_id
                         and ds.start_date = (SELECT MAX(dss.start_date)
                                              FROM DOC_STATUS dss
                                              WHERE dss.document_id = c.c_claim_id)
                   group by chk.c_claim_header_id) max_date on (max_date.c_claim_header_id = ch.c_claim_header_id)
        
        left join (select max(ds.doc_status_id) ds_id, ds.document_id
                   from doc_status ds
                   group by ds.document_id) mds on (mds.document_id = clm.c_claim_id)
        left join doc_status ds on (ds.doc_status_id = mds.ds_id and ds.document_id = clm.c_claim_id)
        */
        --09.12.2011_������ ���������� �������� ����
         INNER JOIN document d_clm
            ON d_clm.document_id = clm.c_claim_id
          LEFT JOIN doc_status ds
            ON ds.doc_status_id = d_clm.doc_status_id
          LEFT JOIN (WITH claims AS (SELECT /*+use_nl(ch,d)*/
                                    to_number(regexp_substr(TRIM(num), '\d*$')) num
                                   ,plan_date
                                   ,c_event_id
                                   ,c_claim_header_id
                                     FROM c_claim_header ch
                                         ,document       d
                                    WHERE ch.c_claim_header_id = d.document_id)
        SELECT nvl(MAX(c2.num), 0) ver_num
              ,MAX(c2.plan_date) keep(dense_rank FIRST ORDER BY c2.num DESC) plan_date
              ,c1.c_event_id
              ,c1.c_claim_header_id
          FROM claims c1
              ,claims c2
         WHERE c1.c_event_id = c2.c_event_id
           AND c1.num > c2.num
           AND c2.plan_date IS NOT NULL
         GROUP BY c1.c_claim_header_id
                 ,c1.c_event_id) nearest_claim
            ON nearest_claim.c_claim_header_id = ch.c_claim_header_id
           AND nearest_claim.c_event_id = ch.c_event_id
        
          LEFT JOIN (SELECT DISTINCT SUM(dso.set_off_amount) over(PARTITION BY cc.c_claim_header_id) paym_amount
                                   , --���� �������������
                                    pkg_utils.get_aggregated_string(CAST(MULTISET
                                                                         (SELECT to_char(ph.ids)
                                                                            FROM p_pol_header ph
                                                                           WHERE ph.policy_header_id =
                                                                                 pp.pol_header_id) AS
                                                                         tt_one_col)
                                                                   ,', ') paym_ids
                                   , --��� �� ������
                                    (SELECT MAX(dso_1.set_off_rate)
                                       FROM c_claim     cc_1
                                           ,doc_doc     dd_1
                                           ,doc_set_off dso_1
                                           ,document    d_1
                                           ,doc_templ   dt_1
                                      WHERE cc_1.c_claim_header_id = cc.c_claim_header_id
                                        AND dd_1.parent_id = cc_1.c_claim_id
                                        AND d_1.document_id = dso_1.parent_doc_id
                                        AND dt_1.doc_templ_id = d_1.doc_templ_id
                                        AND dt_1.brief = 'PAYMENT'
                                        AND dso_1.child_doc_id = dd_1.child_id
                                        AND dso_1.set_off_date =
                                            (SELECT MAX(dso_2.set_off_date)
                                               FROM c_claim     cc_2
                                                   ,doc_doc     dd_2
                                                   ,doc_set_off dso_2
                                                   ,document    d_2
                                                   ,doc_templ   dt_2
                                              WHERE cc_2.c_claim_header_id = cc_1.c_claim_header_id
                                                AND dd_2.parent_id = cc_2.c_claim_id
                                                AND dd_2.child_id = dso_2.child_doc_id
                                                AND d_2.document_id = dso_2.parent_doc_id
                                                AND dt_2.doc_templ_id = d_2.doc_templ_id
                                                AND dt_2.brief = 'PAYMENT')) paym_rate
                                   ,
                                    
                                    cc.c_claim_header_id
                    
                      FROM c_claim        cc
                          ,doc_doc        dd
                          ,ven_ac_payment ac_ps
                          ,doc_templ      dt_1
                          ,doc_set_off    dso
                          ,document       d_dso
                          ,doc_status_ref dsr_dso
                          ,ac_payment     ac_p
                          ,document       d_p
                          ,doc_templ      dt_2
                          ,doc_status_ref dsr_p
                          ,doc_doc        dd_pol
                          ,p_policy       pp
                     WHERE dd.parent_id = cc.c_claim_id
                       AND dd.child_id = ac_ps.payment_id
                       AND dt_1.doc_templ_id = ac_ps.doc_templ_id
                       AND dt_1.brief = 'PAYORDER_SETOFF'
                       AND dso.child_doc_id = ac_ps.payment_id
                       AND d_dso.document_id = dso.doc_set_off_id
                       AND dso.parent_doc_id = ac_p.payment_id
                       AND d_p.document_id = ac_p.payment_id
                       AND d_p.doc_templ_id = dt_2.doc_templ_id
                       AND dt_2.brief = 'PAYMENT'
                       AND d_p.doc_status_ref_id = dsr_p.doc_status_ref_id
                       AND dsr_p.brief != 'ANNULATED'
                       AND dso.cancel_date IS NULL
                       AND d_dso.doc_status_ref_id = dsr_dso.doc_status_ref_id
                       AND dsr_dso.brief != 'ANNULATED'
                       AND dd_pol.child_id = ac_p.payment_id
                       AND dd_pol.parent_id = pp.policy_id) paym_ds --������������ �� ������� ������������� � ����������� � ���� PAYMENT
            ON paym_ds.c_claim_header_id = ch.c_claim_header_id
        
        /*--end_09.12.2011_������ ���������� �������� ����*/
          LEFT JOIN fund dmgf
            ON (dmgf.fund_id = dmg.damage_fund_id)
         WHERE ch.c_claim_header_id NOT IN
               (SELECT d.document_id
                  FROM etl.import_export_claim et
                      ,document                d
                      ,doc_templ               t
                 WHERE t.doc_templ_id = d.doc_templ_id
                   AND t.brief = '���������'
                   AND nvl(et.show_del_pret, 0) = 0
                   AND TRIM((CASE
                              WHEN instr(et.num_event, '-', 1) > 0 THEN
                               lpad(substr(et.num_event
                                          ,1
                                          ,length(et.num_event) -
                                           ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                   ,9
                                   ,'0') || '/' ||
                               substr(et.num_event
                                     ,instr(et.num_event, '-', 1) + 1
                                     ,length(et.num_event) -
                                      ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                              ELSE
                               lpad(et.num_event, 9, '0') || '/' || '1'
                            END)) = d.num)   
        --and ch.c_claim_header_id in (41242617,41614559,40701591)
        --and dmg.t_damage_code_id in (select dt.id from ins.t_damage_code dt where dt.code in 'DOP_INVEST_DOHOD' )
        
        )
 GROUP BY p1
         ,p2
         ,p3
         ,p4
         ,p5
         ,p6
         ,p7
         ,p8
         ,p9
         ,p10
         ,p11
         ,p12
         ,p13
         ,p14
         ,p15
         ,p16
         ,p17
         ,p110
         ,p111
         ,p112
         ,p19_1
         ,p20
         ,p21
         ,p22
         ,CASE
            WHEN p22_2 = p22_1 THEN
             p22_1
            ELSE
             '-'
          END
         ,p23
         ,p24
         ,p25
         ,p28
         ,p28_1
         ,p28_1_1
         ,p30
         ,CASE
            WHEN plan_date IS NULL THEN
             to_date('01.01.1900')
            WHEN pl_description IN ('������ ��������� �������'
                                   ,'������ ��������� ������� ������������ �� �������� ���������'
                                   ,'������������ �� ������ ������� ������������ �� �������� ���������'
                                   ,'������������ �� ������ ���������� �������'
                                   ,'������������ �� ������ ���������� ������� ������������ �� �������� ���������'
                                   ,'������������ �� ������ ��������� �������')
            
             THEN
             ADD_MONTHS(plan_date
                       ,term_number_of_payments * CASE
                          WHEN interval_num >= 0 THEN
                           interval_num
                          ELSE
                           NULL
                        END)
            WHEN prod_brief IN ('OPS_Plus', 'OPS_Plus_2', 'OPS_Plus_New') THEN
             trunc(ADD_MONTHS(plan_date
                             ,1 * CASE
                                WHEN interval_num >= 0 THEN
                                 interval_num
                                ELSE
                                 NULL
                              END)
                  ,'mm')
          END
         ,
          --nvl(plan_date,'01.01.1900'),
          claim_date
         , --���������
          claim_count
         , --���������� ���������
          offset_date
         ,nvl(d_v, '01.01.1900')
         ,add_invest
         ,add_ins_sum
         ,fund_brief
         ,msdate
         ,risk_sum
         ,reinsurer_perc
         ,nvl(reinsurer, '-')
         ,st_note
         ,nvl(p49, '01.01.1900')
         ,p31
         ,p37
         ,paym_amount
         ,paym_ids
         ,non_insurer
         ,paym_ndfl
         ,CASE
            WHEN nvl(paym_rate, 0) = 0 THEN
             paym_rate_ds
            ELSE
             paym_rate
          END
         ,p38
         ,nvl(p24 - (p24 * (reinsurer_perc / 100)), 0)
         ,p43
         ,p45
         ,p46
         ,p48
         ,p32 - 1
         ,p50
         ,CASE
            WHEN p45 IN ('�������� �� ������'
                        ,'������'
                        ,'�������� � �������') THEN
             (CASE
               WHEN (amount > 0)
                    AND (nvl(paym, 0) - nvl(decl, 0)) * rate / amount > 0 THEN
                1
               ELSE
                0
             END)
            ELSE
             2
          END
         ,pol_header_id
         ,nvl(date_last_st, '01.01.1900')
         ,policy_holder
         ,insurance_period
         ,date_to
         ,risk_name_progr
         ,risk_name
         ,rate_ins_amount
         ,pkg_policy.get_pol_sales_chn(policy_header_id, 'descr')
         ,pkg_policy.get_pol_sales_chn(policy_header_id, 'group')
         ,pkg_policy.get_pol_product_group(policy_header_id)
         ,pay_terms

UNION

SELECT CASE
         WHEN (CASE
                WHEN nvl(et.to_agency, '������') <> '������ ����������' THEN
                 '������'
                ELSE
                 et.to_agency
              END) IN ('�������� �� ������'
                      ,'������'
                      ,'�������� � �������') THEN
          (CASE
            WHEN nvl(et.sum_real_risk, 0) <> 0 THEN
             1
            WHEN nvl(et.non_insurer, 0) <> 0 THEN
             1
            ELSE
             0
          END)
         ELSE
          2
       END p51
      ,
       
       upper(nvl(et.num_pret, '�')) num_pret
      , --� ���������, �������� ������ (�����  / �� �����)
       
       (CASE
         WHEN instr(et.num_event, '-', 1) > 0 THEN
          lpad(substr(et.num_event
                     ,1
                     ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
              ,9
              ,'0') || '/' ||
          substr(et.num_event
                ,instr(et.num_event, '-', 1) + 1
                ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
         ELSE
          lpad(et.num_event, 9, '0') || '/' || '1'
       END) num_event
      , --� ����
       
       et.pol_num
      , --� ������
       et.ids
      ,(SELECT ph.policy_header_id
          FROM p_pol_header ph
         WHERE ph.ids = et.ids
           AND rownum = 1) policy_header_id
      ,nvl(et.type_pol, '-') type_pol
      ,et.name_product
      ,et.brief_product
      ,et.insurer
      ,upper(et.gender) gender
      , --���
       nvl(et.date_of_birth, '01.01.1900') date_of_birth
      , --���� ��������
       nvl(et.professional, '-') professional
      , --���������
       et.name_agent
      , --�����
       et.name_manager
      , --��������
       substr(et.name_dep, instr(et.name_dep, '.', 1) + 1) name_dep
      , --�����
       et.code_dep
      , --��� �������
       nvl(et.date_header, '01.01.1900') date_header
      , --���� ���������� �������� � ����
       trunc(et.date_in_company) date_in_company
      , --���� ��������� �����������--date_in_company
       nvl(et.date_all_doc, '01.01.1900') date_all_doc
      , --���� ��������� ���� ����������--date_all_doc
       nvl(et.date_event, '01.01.1900') date_event
      , --���� ����������� ���������� �������--date_event
       et.days_to_ss
      , --���������� ���� �������� ������ �� ����������� ��
       et.diagnos
      , --�������
       nvl(et.recom_prog, '-') recom_prog
      , --�������� ���������
       et.risks
      , --�������� ������, ����������� ���������� ������������� �������
       nvl(et.limit_risks, 0) limit_risks
      , --����� ��������������� ��  ������
       et.currency
      , --������
       nvl(et.rate_amount, 0) * 100 rate_amount
      , --% �� �� �����--ubitok_z
       nvl(et.summ_future_risk, 0) summ_future_risk
      , --����� ��������������� ���������� ����������� �� ������� �����  (��� ��������)
       nvl(et.reserve_sum_future_risk, 0) reserve_sum_future_risk
      , --����������������� ����� ��������������� ���������� ����������� �� ������� �����
       nvl(et.plan_date, '01.01.1900') plan_date
      , --������ ������ ��������� ������� (��� ������ ������ � ������������)
       nvl(et.date_to_vipl, '01.01.1900') date_to_vipl
      , --���� ����������� � ������� (���� ����������� ���������� ����)--date_get_decision1
       nvl(et.date_abort_vipl, '01.01.1900') date_abort_vipl
      , --���� ������ � �������--date_get_decision2
       nvl(et.date_from_account, '01.01.1900') date_from_account
      , --���� ������� (������� �� ����������� ����� ������)--date_ppi
       nvl(et.add_invest, 0) add_invest
      , --�������������� �������������� �����
       nvl(NULL, 0) add_ins_sum
      , --�������������� ��������� �����      
       nvl(et.sum_real_risk, 0) sum_real_risk
      , --����� ������������ ���������� ����������� �� ������� ����� (��� ��������)--sum_ppi
       nvl(et.paym_amount, 0) paym_amount
      , --���� �������������
       nvl(et.paym_ids, 0) paym_ids
      , --��� �� ������
       nvl(et.non_insurer, 0) non_insurer
      , --����������� �������, 91 ����
       nvl(et.paym_ndfl, 0) paym_ndfl
      , --���������� ����
       nvl(et.paym_rate, 0) paym_rate
      , --���� ������ �� ���� �������
       nvl(et.sum_risk_reins, 0) sum_risk_reins
      , --����� ��� ������ ���������������
       nvl(et.rate_reins, 0) * 100 rate_reins
      , --% ���������������
       nvl(et.quota_reins, 0) quota_reins
      , --���� ���������������
       decode(nvl(et.reinsurer, '�� ���������')
             ,'Gen Re'
             ,'��������� ���������������� ��������'
             ,'GenRe'
             ,'��������� ���������������� ��������'
             ,'Munich Re'
             ,'���������� ���������������� ��������'
             ,'MunichRe'
             ,'���������� ���������������� ��������'
             ,'Eastern Re'
             ,'��������� ���������������� ��������'
             ,'EasternRe'
             ,'��������� ���������������� ��������'
             ,'�� ���������') reinsurer
      , --��������������
       nvl(et.sum_vipl, 0) sum_vipl
      , --����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       CASE (CASE
          WHEN (CASE
                 WHEN nvl(et.to_agency, '������') <> '������ ����������' THEN
                  '������'
                 ELSE
                  et.to_agency
               END) IN ('�������� �� ������'
                       ,'������'
                       ,'�������� � �������') THEN
           (CASE
             WHEN nvl(et.sum_real_risk, 0) <> 0 THEN
              1
             ELSE
              0
           END)
          ELSE
           2
        END)
         WHEN 1 THEN
          nvl(et.date_from_account, '01.01.1900')
         WHEN 0 THEN
          nvl(et.date_abort_vipl, '01.01.1900')
         ELSE
          to_date('01.01.1900', 'dd.mm.yyyy')
       END date_last_st
      , --��������� ������
       CASE
         WHEN nvl(et.state, '������') <> '������ ����������' THEN
          '������'
         ELSE
          et.state
       END state
      , --������
       nvl(et.note, '-') note
      , --�����������--note
       nvl(et.st_note, '-') st_note
      , --����������� � ������� ����
       nvl(et.per_from_all_doc, '01.01.1900') per_from_all_doc
      , --���� ������������ � ���� ��������� ���� ����������
       CASE
         WHEN nvl(et.to_agency, '������') <> '������ ����������' THEN
          '������'
         ELSE
          et.to_agency
       END to_agency
      , --�������� � �������������
       nvl(et.date_to_oplata, '01.01.1900') date_to_oplata
      , --���� �������� �� ������--date_oplata
       nvl(et.otkaz, '-') otkaz
      , --������� ������--otkaz
       nvl(et.claim_date, '01.01.1900') claim_date
      , --���������
       nvl(et.claim_count, 0) claim_count
      , --���������� ���������
       '������' import
      ,(SELECT MAX(c.obj_name_orig)
          FROM p_policy           p
              ,p_pol_header       ph
              ,p_policy_contact   ppc
              ,t_contact_pol_role cpr
              ,contact            c
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ppc.policy_id = p.policy_id
           AND ppc.contact_policy_role_id = cpr.id
           AND cpr.description = '������������'
           AND ppc.contact_id = c.contact_id
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)) policy_holder
      ,(SELECT MAX(CASE opt.description
                     WHEN '��������� ���������������� ���������� �������� �����������' THEN
                      trunc(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date), 0) / 12
                     ELSE
                      trunc(MONTHS_BETWEEN(p.end_date + 1, ph.start_date), 0) / 12
                   END)
          FROM p_policy           p
              ,p_pol_header       ph
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)
           AND p.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id) insurance_period
      ,(SELECT MAX(CASE
                     WHEN decode(pc.is_avtoprolongation, 1, '��', 0, '���', '���') = '��' THEN
                      (CASE
                        WHEN decode(ig.life_property, 0, 'C', 1, 'L', NULL) = 'C' THEN
                         (CASE
                           WHEN MOD(trunc(MONTHS_BETWEEN(p.end_date + 1, ph.start_date), 0) / 12, 1) = 0 THEN
                            (CASE
                              WHEN extract(YEAR FROM pc.end_date) - extract(YEAR FROM pc.start_date) > 1 THEN
                               (CASE extract(YEAR FROM ph.start_date)
                                 WHEN 2005 THEN
                                  ph.start_date + 364 + 364 + 364 + 365
                                 WHEN 2006 THEN
                                  ph.start_date + 364 + 364 + 365
                                 WHEN 2007 THEN
                                  ph.start_date + 364 + 365
                                 WHEN 2008 THEN
                                  ph.start_date + 365
                                 ELSE
                                  pc.end_date
                               END)
                              ELSE
                               pc.end_date
                            END)
                           ELSE
                            pc.end_date
                         END)
                        ELSE
                         pc.end_date
                      END)
                     ELSE
                      pc.end_date
                   END)
          FROM p_policy           p
              ,p_pol_header       ph
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
              ,t_product_line     pll
              ,t_lob_line         ll
              ,t_insurance_group  ig
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)
           AND p.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pll.id
           AND pll.t_lob_line_id = ll.t_lob_line_id
           AND ll.insurance_group_id = ig.t_insurance_group_id) date_to
      ,(SELECT MAX(ll.description)
          FROM p_policy           p
              ,p_pol_header       ph
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
              ,t_product_line     pll
              ,t_lob_line         ll
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)
           AND p.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id
           AND opt.product_line_id = pll.id
           AND pll.t_lob_line_id = ll.t_lob_line_id) risk_name_progr
      ,(SELECT MAX(opt.description)
          FROM p_policy           p
              ,p_pol_header       ph
              ,as_asset           a
              ,p_cover            pc
              ,t_prod_line_option opt
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)
           AND p.policy_id = a.p_policy_id
           AND a.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = opt.id) risk_name
      ,TRIM(substr((CASE
                     WHEN instr(et.num_event, '-', 1) > 0 THEN
                      lpad(substr(et.num_event
                                 ,1
                                 ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                          ,9
                          ,'0') || '/' ||
                      substr(et.num_event
                            ,instr(et.num_event, '-', 1) + 1
                            ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                     ELSE
                      lpad(et.num_event, 9, '0') || '/' || '1'
                   END)
                  ,1
                  ,instr((CASE
                           WHEN instr(et.num_event, '-', 1) > 0 THEN
                            lpad(substr(et.num_event
                                       ,1
                                       ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                ,9
                                ,'0') || '/' ||
                            substr(et.num_event
                                  ,instr(et.num_event, '-', 1) + 1
                                  ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                           ELSE
                            lpad(et.num_event, 9, '0') || '/' || '1'
                         END)
                        ,'/') - 1)) ord1
      ,
       
       to_number(TRIM(substr((CASE
                               WHEN instr(et.num_event, '-', 1) > 0 THEN
                                lpad(substr(et.num_event
                                           ,1
                                           ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                    ,9
                                    ,'0') || '/' ||
                                substr(et.num_event
                                      ,instr(et.num_event, '-', 1) + 1
                                      ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                               ELSE
                                lpad(et.num_event, 9, '0') || '/' || '1'
                             END)
                            ,instr((CASE
                                     WHEN instr(et.num_event, '-', 1) > 0 THEN
                                      lpad(substr(et.num_event
                                                 ,1
                                                 ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                          ,9
                                          ,'0') || '/' ||
                                      substr(et.num_event
                                            ,instr(et.num_event, '-', 1) + 1
                                            ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                     ELSE
                                      lpad(et.num_event, 9, '0') || '/' || '1'
                                   END)
                                  ,'/') + 1))) ord2
      ,NULL
      , --ch.c_claim_header_id
       NULL
      , --clm.c_claim_id
       NULL
      , --e.c_event_id
       pkg_policy.get_pol_sales_chn((SELECT ph.policy_header_id
                                      FROM p_pol_header ph
                                     WHERE ph.ids = et.ids
                                       AND rownum = 1)
                                   ,'descr')
      ,pkg_policy.get_pol_sales_chn((SELECT ph.policy_header_id
                                      FROM p_pol_header ph
                                     WHERE ph.ids = et.ids
                                       AND rownum = 1)
                                   ,'group')
      ,pkg_policy.get_pol_product_group((SELECT ph.policy_header_id
                                          FROM p_pol_header ph
                                         WHERE ph.ids = et.ids
                                           AND rownum = 1))
      ,NULL
  FROM etl.import_export_claim et
      ,t_product_group         pg
      ,t_product               pr1
 WHERE nvl(et.show_del_pret, 0) != 2
   AND et.brief_product = pr1.brief(+)
   AND pr1.t_product_group_id = pg.t_product_group_id(+)
--and rownum = 1
 ORDER BY 1
         ,2;

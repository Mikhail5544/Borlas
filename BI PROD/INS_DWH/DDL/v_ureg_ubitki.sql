CREATE OR REPLACE FORCE VIEW INS_DWH.V_UREG_UBITKI AS
SELECT
       case when p45 in ('�������� �� ������','������','�������� � �������') then
            (case when (amount > 0) and (nvl(paym,0) - nvl(decl,0)) * rate / amount > 0 then 1 else 0 end)
            else 2 end p51,--����
       p1,--� ���������, �������� ������ (�����  / �� �����)
       p2,--� ����
       p3,--� ������
       (select ids from ins.p_pol_header ph where ph.policy_header_id = pol_header_id) ids, --ids
       pol_header_id,
       p4,--��� ������ (������������� ��� ��������������)
       p5,--�������� ���������
       p6,--���������� ��������� �����������
       p7,--��������������
       p8,--���
       p9,--���� ��������
       p10,--���������
       p11,--�����
       p12,--��������
       p13,--�����
       p14,--��� �������
       p15,--���� ���������� �������� � ����
       p16,--���� ��������� �����������--date_in_company
       nvl(p17,'01.01.1900') p17,--���� ��������� ���� ����������--date_all_doc
       nvl(p20,'01.01.1900') p20,--���� ����������� ���������� �������--date_event
       nvl(p21,0) p21,--���������� ���� �������� ������ �� ����������� ��
       p22,--�������
       case when p22_2 = p22_1 then p22_1 else '-' end p22_1,--�������� ���������
       p23,--�������� ������, ����������� ���������� ������������� �������
       p24,--����� ��������������� ��  ������
       p25,--������
       case when rate_ins_amount = 100 then rate_ins_amount
            when p31 is null then sum( (case when amount > 0 then round(nvl(paym,0) * rate / amount * 100,1) else 0 end))
            else 0
       end p26,--% �� �� �����--ubitok_z
       case when p31 is null then sum( round((nvl(amount,0)) * (case when amount > 0 then ((nvl(paym,0) - nvl(decl,0)) * rate / amount) else 0 end),2) )
            else 0
       end p27,--����� ��������������� ���������� ����������� �� ������� �����  (��� ��������)
       nvl(p28_1,0) p28_1,--����������������� ����� ��������������� ���������� ����������� �� ������� �����
       --09.12.2011_������ ���������� �������� ����.  ������� ������ ������
           case when plan_date is null  then  to_date('01.01.1900')
                when pl_description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                             '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                             '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                             '������������ �� ������ ��������� �������')

                then  add_months(plan_date, term_number_of_payments *
                                            case when interval_num >= 0 then
                                                      interval_num else
                                                      null
                                            end
                                )
                when  prod_brief in ('OPS_Plus', 'OPS_Plus_2' ,'OPS_Plus_New')
                then  trunc(add_months(plan_date, 1 *
                                                      case when interval_num >= 0 then
                                                           interval_num else
                                                           null
                                                      end
                                       ) , 'mm')
           end plan_date,
       --������ ������ ��������� ������� (��� ������ ������ � ������������)
       --end_09.12.2011_������ ���������� �������� ����
            --nvl(plan_date,'01.01.1900') plan_date,--������ ������ ��������� ������� (��� ������ ������ � ������������)
       nvl(p30,'01.01.1900') p30,--���� ����������� � ������� (���� ����������� ���������� ����)--date_get_decision1
       nvl(p31,'01.01.1900') p31,--���� ������ � �������--date_get_decision2
       nvl(d_v,'01.01.1900') p32,--���� ������� (������� �� ����������� ����� ������)--date_ppi
       add_invest,--�������������� �������������� �����
       p37,--����� ������������ ���������� ����������� �� ������� ����� (��� ��������)--sum_ppi
       paym_amount, --09.12.2011_������ ���������� �������� ����  /���� �������������/
       paym_ids,    --09.12.2011_������ ���������� �������� ����  /��� �� ������/
       non_insurer,--����������� �������, 91 ����
       paym_ndfl,   --09.12.2011_������ ���������� �������� ����  /���������� ����/
       case when nvl(paym_rate,0) = 0 then paym_rate_DS else paym_rate end paym_rate,   --09.12.2011_������ ���������� �������� ����  /���� ������ �� ���� �������/
       risk_sum,--����� ��� ������ ���������������
       reinsurer_perc,--% ���������������
       --������� �� ������ �84295
       --nvl((case when p31 is null then sum( (nvl(amount,0)) * (case when amount > 0 then round((nvl(paym,0) - nvl(decl,0)) * rate / amount, 3) else 0 end) ) else 0 end) * (nvl(reinsurer_perc,0)/100),0) dl_reins,--���� ���������������
       case when (case when p31 is null
                        then sum( round((nvl(amount,0)) * (case when amount > 0 then ((nvl(paym,0) - nvl(decl,0)) * rate / amount) else 0 end),2) )
                        else 0
                        end) > 0
             then (case when p37 > 0
                        then round((ins.acc_new.get_rate_by_brief('��',fund_brief,msdate) * p28_1_1) * (reinsurer_perc / 100),2)
                        else round(p28_1_1 * (reinsurer_perc / 100),2)
                        end)
             else 0
       end dl_reins,--���� ���������������
       nvl(reinsurer,'-') reinsurer,--��������������
       --������� �� ������ �84295
       --nvl(p24 - (p24*(reinsurer_perc/100)),0) p42,--����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       --������ �� ������ �84295
       case when p37 <= 0 then 0
            else (p37  - round((ins.acc_new.get_rate_by_brief('��',fund_brief,msdate) * p28_1_1) * (reinsurer_perc / 100),2))
       end p42,--����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       nvl(date_last_st,'01.01.1900') date_last_st,--���� ���������� �������
       p45,--������
       p46,--�����������--note
       st_note,--����������� � ������� ����
       nvl(p19_1,'01.01.1900') p19_1,--���� ������������ � ���� ��������� ���� ����������
       p45 p47,--�������� � �������������
       nvl(p49,'01.01.1900') p49,--���� �������� �� ������--date_oplata
       p50,--������� ������--otkaz
       claim_date,   --���������
       claim_count,  --���������� ���������

       '���' import,
       policy_holder,
       insurance_period,
       date_to,
       risk_name_progr,
       risk_name,

       trim(substr(p2,1,instr(p2,'/') - 1 )) ord1, --delo1
       to_number(trim(substr(p2,instr(p2,'/') + 1))) ord2, --delo2
       p110,--ch.c_claim_header_id
       p111,--clm.c_claim_id
       p112,--e.c_event_id
       p_cover_id,
       policy_header_id
FROM (
select /*+ LEADING (ch, paym_DS) USE_NL(ch, paym_DS)*/
       ch.c_claim_header_id p110,
       clm.c_claim_id p111,
       e.c_event_id p112,
       case when tp.id = 30500025 then '�' else
            (nvl(case tp.insurance_group_id when 2404 then '�' when 2 then '�' else '�' end,'-') )
            end p1,
       nvl(ch.num,'-') p2,
       nvl(decode(p.pol_ser, null, p.pol_num, p.pol_ser || '-' || p.pol_num),'-') p3,
       nvl(case nvl(p.is_group_flag,0) when 1 then '�������������' else (case when chl.id = 8 then '���������' else '��������������' end) end,'-') p4,
       nvl(prod.description,'-')  p5,
       nvl(prod.brief,'-') p6,
       nvl(ins.ent.obj_name('CONTACT',asu.assured_contact_id),'-') p7,
       nvl(case nvl(casu.gender,0) when 0 then '�' else '�' end,'-') p8,
       nvl(casu.date_of_birth,'01.01.1900') p9,
       nvl(prof.description,'-') p10,
       nvl(ins.pkg_agent_1.get_agent_pol(p.pol_header_id, sysdate),'-') p11,
       nvl(ins.pkg_agent_1.get_agentlider_pol(p.pol_header_id, sysdate),'-') p12,
       nvl(dep.name,'-') p13,
       nvl(substr(pr.kladr_code,1,2),'')  p14,
       nvl(ph.start_date,'01.01.1900') p15,
       nvl(e.date_company,'01.01.1900') p16,
       --09.12.2011_������ ���������� �������� ����
       --max_date.msdate,
       (select max(ds1.start_date) msdate
                from ins.c_claim c1
                     ,ins.document d1
                     ,ins.doc_status ds1
                where  c1.c_claim_header_id = ch.c_claim_header_id
                      and c1.c_claim_id = d1.document_id
                      and ds1.doc_status_id = d1.doc_status_id
       )msdate,
       --end_09.12.2011_������ ���������� �������� ����

       case pl.description when '��������� ���������������� ���������� �������� �����������'
                            then trunc(months_between(pc.end_date + 1, ph.start_date), 0) / 12
                            else trunc(months_between(p.end_date + 1, ph.start_date), 0) / 12 end
       insurance_period,

       (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 122) p17,
       (select decode(rf.name,'��� ���������', clm2.claim_status_date)
         from ins.ven_c_claim clm2,
              ins.document da,
              ins.doc_status_ref rf
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and clm2.c_claim_id = da.document_id
               and rf.doc_status_ref_id = da.doc_status_ref_id
               and rownum = 1
               and rf.name = '��� ���������') p19,

      (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 129) p19_1,

       nvl(e.event_date,'01.01.1900') p20,
       nvl(e.event_date,'01.01.1900') - nvl(ph.start_date,'01.01.1900') p21,
       nvl(e.diagnose,'-') p22,


       (select plo.description progr
        from ins.p_policy pp,
             ins.as_asset ass,
             ins.p_cover pc,
             ins.t_prod_line_option plo,
             ins.t_product_line pl,
             ins.t_product_line_type plt
        where ass.p_policy_id = pp.policy_id
              and pc.as_asset_id = ass.as_asset_id
              and plo.id = pc.t_prod_line_option_id
              and plo.product_line_id = pl.id
              and pl.product_line_type_id = plt.product_line_type_id
              and plt.brief = 'RECOMMENDED'
              and upper(trim(plo.description)) <> '���������������� ��������'
              and pp.policy_id = p.policy_id
              and rownum = 1) p22_1,
         pl.description p22_2,

         /*case when pl.description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                           '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ��������� �������') then pl.description
            when pl.description like '%�������%�� �����������%' then pl.description
            else tp.description end p23,*/
         case when pl.description like '������ ���������%'
                then pl.description
              when pl.description like '������������%'
                then pl.description
              when pl.description like '%�������%�� �����������%'
                then pl.description
              when pl.description like '%"����������� ��������������"%'
                then pl.description
              when pl.description like '��������� ���������������� ���������� �������� �����������'
                then pl.description
              else tp.description
         end p23,

        /*case when nvl(pc.ins_amount,0) = 0 then
                  nvl((select sum(plop.limit_amount)
                      from t_prod_line_opt_peril plop
                      where plop.product_line_option_id = pl.id
                            and plop.peril_id = tp.id),0)
        else nvl(pc.ins_amount,0)
        end*/
        case when nvl(pc.ins_amount,0) = 0 then
               ins.pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
             when dmg.t_damage_code_id in (select dt.id from ins.t_damage_code dt where dt.code in 'DOP_INVEST_DOHOD' ) then
               ins.pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
        else
             nvl(pc.ins_amount,0)
        end
          p24,
        --nvl(pc.ins_amount,0) p24,
        nvl(f.brief,'-') p25,

        --nvl(pc.ins_amount,0)
        /*case when nvl(pc.ins_amount,0) = 0 then
                  nvl((select sum(plop.limit_amount)
                      from t_prod_line_opt_peril plop
                      where plop.product_line_option_id = pl.id
                            and plop.peril_id = tp.id),0)
        else nvl(pc.ins_amount,0)
        end*/
        case when nvl(pc.ins_amount,0) = 0 then
               ins.pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
        else
             nvl(pc.ins_amount,0)
        end
        amount,

        nvl(dmg.decline_sum,0) decl,
        nvl(dmg.declare_sum,0) paym,
        nvl(ins.acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,ch.declare_date),1) rate,

        e.c_event_id p28,

         (select sum(round(nvl(dmg.payment_sum,0) * ins.acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,chx.declare_date),2))
         from ins.ven_c_claim_header chx
              join ins.ven_c_claim clm on (chx.c_claim_header_id = clm.c_claim_header_id)
              join ins.c_damage dmg on (clm.c_claim_id = dmg.c_claim_id)
              left join ins.fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
              left join ins.fund f on (chx.fund_id = f.fund_id)
         where chx.c_claim_header_id = ch.c_claim_header_id
               and clm.seqno = 1
               /*and doc.get_last_doc_status_name(clm.c_claim_id) = '���� ���������'*/) p28_1,

         (select sum(round(nvl(dmg.payment_sum,0) * ins.acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,chx.declare_date),2))
         from ins.ven_c_claim_header chx
              join ins.ven_c_claim clm on (chx.c_claim_header_id = clm.c_claim_header_id)
              join ins.c_damage dmg on (clm.c_claim_id = dmg.c_claim_id)
              left join ins.fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
              left join ins.fund f on (chx.fund_id = f.fund_id)
         where chx.c_claim_header_id = ch.c_claim_header_id
               and dmg.status_hist_id <> 3
               and clm.seqno = (select max(clml.seqno) from ins.ven_c_claim clml where clml.c_claim_header_id = ch.c_claim_header_id)) p28_1_1,

        case when (nvl(dmg.payment_sum,0)) > 0 then

         (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id in (128)) end p30,--  -10 �������������,11 ������


         case when (nvl(dmg.payment_sum,0)) = 0 then

        (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id in (128)) end p31,

        nvl(ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id,'�'),0) +
             nvl(ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'),0) p32,
         0 p33,
        '-' p34,
         0 p35,
        '-' p36,

        nvl(ins.pkg_renlife_utils.ret_sod_claim(ch.c_claim_header_id),'01.01.1900') d_v,

        nvl(ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'),0) new_pole1,
        ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') new_pole2,
        case when ig.brief != 'NonInsuranceClaims' then

                  nvl(ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') +
                       ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�'),0)
             else 0 end p37,
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
               and dso.cancel_date is null),0) p37,*/
        case when ig.brief = 'NonInsuranceClaims' then

                  ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�') +
                       ins.pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, '�')
             else 0 end
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
               and dso.cancel_date is null),0)*/  non_insurer,

        '-' p38,
        '-' p39, '-' p40, '-' p41,
        '-' p43, '-' p44,
        nvl(ins.doc.get_last_doc_status_name(ch.active_claim_id),'-') p45,
        nvl(ds.note,'-') st_note,
        nvl(d_clm.note,'-') p46,

        '-' p47, '-' p48,
        (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = 129) p49,
        nvl(ins.pkg_renlife_utils.damage_decline_reason(pc.p_cover_id,ch.active_claim_id),'-') p50,
        --nvl(dmg.decline_reason,'-') p50,
        p.pol_header_id,
        nvl(cad.add_invest,0) add_invest,
        nvl(cad.risk_sum,0) risk_sum,
        nvl(cad.reinsurer_perc,0) reinsurer_perc,

        case cad.reinsurer_id when 1 then '��������� ���������������� ��������' when 2 then '���������� ���������������� ��������' else '�� ���������' end reinsurer,
        f.brief fund_brief,
        /*--09.12.2011_������ ���������� �������� ����
        case when pl.description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                           '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ��������� �������')
             then pkg_claim.GET_EPG_TO_EVENT(ch.c_event_id,ch.num,e.event_date,p.first_pay_date,12 / term.number_of_payments) else to_date('01.01.1900','dd.mm.yyyy') end plan_date*/

        --09.12.2011_������ ���������� �������� ����

        case when ch.plan_date is not null
              then ch.plan_date
              else
                   nearest_claim.plan_date
         end plan_date,

         prod.brief prod_brief,

         case when term.is_periodical = 0 then 0
              else 12 / term.number_of_payments
         end term_number_of_payments,

         pl.description pl_description,
         case when ch.plan_date is not null
              then 0
              else
                 nvl(
                     to_number(trim(substr(ch.num,instr(ch.num,'/') + 1))),0
                    )/*������� �����*/
                 - nvl(nearest_claim.ver_num,0) --��������� �����
         end interval_num,

       nvl(round(paym_amount,2),0)paym_amount,
       nvl(paym_ids,0)paym_ids,
       --������ �������������� ������� ���������� /���. ���� ������ � ���. ������ ��� (����. ����. �� ���� ���� ������)/
       nvl((select max(dso_1.ndfl_tax)
                   from  ins.doc_doc dd_1
                        ,ins.doc_set_off dso_1
                        ,ins.document d_1
                        ,ins.doc_templ dt_1
                   where dd_1.parent_id = clm.c_claim_id
                        and dd_1.child_id = dso_1.parent_doc_id
                        and d_1.document_id = dso_1.child_doc_id
                        and dt_1.doc_templ_id = d_1.doc_templ_id
                        and dt_1.brief = '���'
                        and dso_1.set_off_date =
                                               (select max(dso_2.set_off_date)
                                                from  ins.doc_doc dd_2
                                                     ,ins.doc_set_off dso_2
                                                where dd_2.parent_id = dd_1.parent_id
                                                      and dd_2.child_id = dso_2.parent_doc_id
                                                      and nvl(dso_2.ndfl_tax,0) > 0))
       ,0) paym_ndfl,

       --������ �������������� ������� ���������� /���� /
      (select max(dso_1.set_off_rate)
      from ins.c_claim cc_1
           ,ins.doc_doc dd_1
           ,ins.doc_set_off dso_1
           ,ins.document d_1
           ,ins.doc_templ dt_1
      where cc_1.c_claim_header_id = ch.c_claim_header_id
            and dd_1.parent_id = cc_1.c_claim_id
            and d_1.document_id = dso_1.child_doc_id
            and dt_1.doc_templ_id = d_1.doc_templ_id
            and dt_1.brief = '���'
            and dso_1.parent_doc_id = dd_1.child_id
            and dso_1.set_off_date =
                           (select max(dso_2.set_off_date)
                            from  ins.c_claim cc_2
                                 ,ins.doc_doc dd_2
                                 ,ins.doc_set_off dso_2
                                 ,ins.document d_2
                                 ,ins.doc_templ dt_2
                            where cc_2.c_claim_header_id = cc_1.c_claim_header_id
                                  and dd_2.parent_id = cc_2.c_claim_id
                                  and dd_2.child_id = dso_2.parent_doc_id
                                  and d_2.document_id = dso_2.child_doc_id
                                  and dt_2.doc_templ_id = d_2.doc_templ_id
                                  and dt_2.brief = '���'
                                  ))
       paym_rate, --���� ������ �� ���� �������
       nvl(round(paym_DS.paym_rate,4), 0) paym_rate_DS, --���� ������ � PAYMENT (������������ ���� ��� ���)

       --nvl(paym_rate,0)paym_rate,

       nvl((select max(ccd.c_claim_date)
       from ins.c_claim_dates ccd
       where ccd.c_claim_header_id = ch.c_claim_header_id),'01.01.1900') claim_date,
       (select count(ccd.c_claim_date)
       from ins.c_claim_dates ccd
       where ccd.c_claim_header_id = ch.c_claim_header_id) claim_count,

         --end_09.12.2011_������ ���������� �������� ����

         (select max(ds.start_date)
         from ins.ven_c_claim clm2,
              ins.doc_status ds,
              ins.doc_status_ref rf
         where clm2.c_claim_header_id = ch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id = rf.doc_status_ref_id) date_last_st,
       cpol.obj_name_orig policy_holder,
       case when decode(pc.is_avtoprolongation,1,'��',0,'���','���') = '��'
            then (case when decode(ig.life_property, 0, 'C', 1, 'L', NULL) = 'C'
                       then (case when mod(trunc(months_between(p.end_date + 1, ph.start_date), 0) / 12,1) = 0
                                  then (case when extract(year from pc.end_date) - extract(year from pc.start_date) > 1
                                             then (case extract(year from ph.start_date) when 2005
                                                                                         then ph.start_date + 364 + 364 + 364 + 365
                                                                                         when 2006
                                                                                         then ph.start_date + 364 + 364 + 365
                                                                                         when 2007
                                                                                         then ph.start_date + 364 + 365
                                                                                         when 2008
                                                                                         then ph.start_date + 365
                                                                                         else pc.end_date end)
                                              else pc.end_date end)
                                  else pc.end_date end)
                       else pc.end_date end)
           else pc.end_date
           end date_to,
           ll.description risk_name_progr,
           opt.description risk_name,
           CASE WHEN dmg.t_damage_code_id in (select dt.id from ins.t_damage_code dt where dt.code in 'DOP_INVEST_DOHOD' )
                THEN 100
                 ELSE 1
           END rate_ins_amount,
           pc.p_cover_id,
           ph.policy_header_id
from ins.ven_c_claim_header ch
     --join ven_c_claim clm on (ch.c_claim_header_id = clm.c_claim_header_id)
     join ins.c_claim clm on (ch.active_claim_id = clm.c_claim_id)
     join ins.p_policy p on ch.p_policy_id = p.policy_id

     join ins.p_policy_contact pcnt on (pcnt.policy_id = p.policy_id)
     join ins.t_contact_pol_role polr on (polr.brief = '������������' and pcnt.contact_policy_role_id = polr.id)
     join ins.contact cpol on (cpol.contact_id = pcnt.contact_id)

     join ins.ven_c_event e on ch.c_event_id = e.c_event_id
     ----������ �������������� ������� ����������
     /*join c_declarants cds on cds.c_claim_header_id = ch.c_claim_header_id
     join c_event_contact ec on ec.c_event_contact_id = cds.declarant_id
     join c_declarant_role dr on dr.c_declarant_role_id = cds.declarant_role_id*/
     --join c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
     --join c_declarant_role dr on ch.declarant_role_id = dr.c_declarant_role_id --������ �������������� ������� ����������
     --end_������ �������������� ������� ����������
     --join contact c on ec.cn_person_id = c.contact_id
     join ins.ven_cn_person per on (ch.curator_id = per.contact_id)
     left join ins.department ct on ch.depart_id = ct.department_id
     left join ins.as_asset a on ch.as_asset_id = a.as_asset_id
     left join ins.as_assured asu on asu.as_assured_id = a.as_asset_id
     left join ins.cn_person casu on casu.contact_id = asu.assured_contact_id
     left join ins.t_profession prof on (casu.profession = prof.id)
     left join ins.fund f on (ch.fund_id = f.fund_id)
     join ins.c_claim_metod_type cmt on ch.notice_type_id = cmt.c_claim_metod_type_id
     left join ins.p_cover pc on (ch.p_cover_id = pc.p_cover_id)
     left join ins.t_prod_line_option pl on pc.t_prod_line_option_id = pl.id

     left join ins.t_product_line pll on (pll.id = pl.product_line_id)
     left join ins.t_lob_line ll on (pll.t_lob_line_id = ll.t_lob_line_id)
     left join ins.t_insurance_group ig on (ig.t_insurance_group_id = ll.insurance_group_id)

     join ins.p_pol_header ph on ph.policy_header_id = p.pol_header_id
     join ins.t_payment_terms term on (term.id = p.payment_term_id)
     left join ins.t_sales_channel chl on (chl.id = ph.sales_channel_id)
     left join ins.department dep on dep.department_id = ph.agency_id
     left join ins.organisation_tree ot on (ot.organisation_tree_id = dep.org_tree_id)
     left join ins.t_province pr on (pr.province_id = ot.province_id)
     left join ins.t_product prod on prod.product_id = ph.product_id
     left join ins.t_peril tp on tp.id = ch.peril_id
     left join ins.t_prod_line_option opt on (opt.id = pc.t_prod_line_option_id)
     left join ins.c_damage dmg on (dmg.p_cover_id = pc.p_cover_id and ch.active_claim_id = dmg.c_claim_id and dmg.status_hist_id <> 3)
     left join ins.c_claim_add cad on (cad.c_claim_id = clm.c_claim_id)


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
     inner join ins.document d_clm on d_clm.document_id = clm.c_claim_id
     left join ins.doc_status ds on ds.doc_status_id = d_clm.doc_status_id
     left join
              (select distinct
                   nvl(to_number(trim(substr(cch_1.num,instr(cch_1.num,'/') + 1))),0) ver_num --����� ���������� ���� �� ������ � �������� ���� ������� not null � ����� ������ ��������
                   , cch_1.plan_date  --���� ���������� ���� �� ������ � �������� ���� ������� not null � ����� ������ ��������
                   , ch_1.c_event_id
                   , ch_1.c_claim_header_id
                         from
                         ins.ven_c_claim_header cch_1 --����������� ��������� ���� � ����� ������� not null
                         ,ins.ven_c_claim_header ch_1 --������� ����
                         where cch_1.c_event_id  = ch_1.c_event_id
                               and to_number(trim(substr(cch_1.num,instr(cch_1.num,'/') + 1)))
                                   = (
                                       select max(to_number(trim(substr(cch_2.num,instr(cch_2.num,'/') + 1)))) num
                                       from ins.ven_c_claim_header cch_2
                                       where cch_2.c_event_id = cch_1.c_event_id
                                             and cch_2.plan_date is not null
                                             and to_number(trim(substr(cch_2.num,instr(cch_2.num,'/') + 1)))
                                                 < to_number(trim(substr(ch_1.num,instr(ch_1.num,'/') + 1)))
                                      )
                )nearest_claim on nearest_claim.c_claim_header_id = ch.c_claim_header_id
                               and nearest_claim.c_event_id       = ch.c_event_id

     left join
     (select distinct sum(dso.set_off_amount)over(partition by cc.c_claim_header_id) paym_amount, --���� �������������
              ins.pkg_utils.get_aggregated_string(cast(multiset(
                                                 select to_char(ph.ids)
                                                 from ins.p_pol_header ph
                                                 where ph.policy_header_id = pp.pol_header_id
                                                             ) as ins.tt_one_col), ', ') paym_ids, --��� �� ������
            (select max(dso_1.set_off_rate)
            from ins.c_claim cc_1
                 ,ins.doc_doc dd_1
                 ,ins.doc_set_off dso_1
                 ,ins.document d_1
                 ,ins.doc_templ dt_1
            where cc_1.c_claim_header_id = cc.c_claim_header_id
                  and dd_1.parent_id = cc_1.c_claim_id
                  and d_1.document_id = dso_1.parent_doc_id
                  and dt_1.doc_templ_id = d_1.doc_templ_id
                  and dt_1.brief = 'PAYMENT'
                  and dso_1.child_doc_id = dd_1.child_id
                  and dso_1.set_off_date =
                                 (select max(dso_2.set_off_date)
                                  from  ins.c_claim cc_2
                                       ,ins.doc_doc dd_2
                                       ,ins.doc_set_off dso_2
                                       ,ins.document d_2
                                       ,ins.doc_templ dt_2
                                  where cc_2.c_claim_header_id = cc_1.c_claim_header_id
                                        and dd_2.parent_id = cc_2.c_claim_id
                                        and dd_2.child_id = dso_2.child_doc_id
                                        and d_2.document_id = dso_2.parent_doc_id
                                        and dt_2.doc_templ_id = d_2.doc_templ_id
                                        and dt_2.brief = 'PAYMENT'
                                        )) paym_rate,

              cc.c_claim_header_id

       from ins.c_claim cc
            ,ins.doc_doc dd
            ,ins.ven_ac_payment ac_ps
            ,ins.doc_templ dt_1
            ,ins.doc_set_off dso
            ,ins.document d_dso
            ,ins.doc_status_ref dsr_dso
            ,ins.ac_payment ac_p
            ,ins.document d_p
            ,ins.doc_templ dt_2
            ,ins.doc_status_ref dsr_p
            ,ins.doc_doc dd_pol
            ,ins.p_policy pp
       where dd.parent_id           = cc.c_claim_id
             and dd.child_id        = ac_ps.payment_id
             and dt_1.doc_templ_id  = ac_ps.doc_templ_id
             and dt_1.brief         = 'PAYORDER_SETOFF'
             and dso.child_doc_id   = ac_ps.payment_id
             and d_dso.document_id  = dso.doc_set_off_id
             and dso.parent_doc_id  = ac_p.payment_id
             and d_p.document_id    = ac_p.payment_id
             and d_p.doc_templ_id   = dt_2.doc_templ_id
             and dt_2.brief         = 'PAYMENT'
             and d_p.doc_status_ref_id = dsr_p.doc_status_ref_id
             and dsr_p.brief        != 'ANNULATED'
             and dso.cancel_date is null
             and d_dso.doc_status_ref_id = dsr_dso.doc_status_ref_id
             and dsr_dso.brief      != 'ANNULATED'
             and dd_pol.child_id    = ac_p.payment_id
             and dd_pol.parent_id   = pp.policy_id
             ) paym_DS --������������ �� ������� ������������� � ����������� � ���� PAYMENT
     on paym_DS.c_claim_header_id = ch.c_claim_header_id


     /*--end_09.12.2011_������ ���������� �������� ����*/
     left join ins.fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)
where
 ch.c_claim_header_id NOT IN (select d.document_id
                                  from etl.import_export_claim et, ins.document d, ins.doc_templ t
                                  where t.doc_templ_id = d.doc_templ_id
                                        and t.brief = '���������'
                                        and nvl(et.show_del_pret,0) = 0
                                        and trim(
                                            (case when instr(et.num_event,'-',1) > 0 then
                                              lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
                                              else lpad(et.num_event,9,'0')||'/'||'1'
                                             end)
                                             ) = d.num)
--and ch.c_claim_header_id in (41242617,41614559,40701591)
--and dmg.t_damage_code_id in (select dt.id from ins.t_damage_code dt where dt.code in 'DOP_INVEST_DOHOD' )


)
GROUP BY p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,
      p11,p12,p13,p14,p15,p16,p17,
      p110,p111,p112,
      p19_1,p20,
      p21,p22,
      case when p22_2 = p22_1 then p22_1 else '-' end,
      p23,
      p24,p25,p28,p28_1,
      p28_1_1,p30,
       case when plan_date is null  then  to_date('01.01.1900')
            when pl_description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                         '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                         '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                         '������������ �� ������ ��������� �������')

            then  add_months(plan_date, term_number_of_payments *
                                        case when interval_num >= 0 then
                                                  interval_num else
                                                  null
                                        end
                            )
            when  prod_brief in ('OPS_Plus', 'OPS_Plus_2' ,'OPS_Plus_New')
            then  trunc(add_months(plan_date, 1 *
                                                  case when interval_num >= 0 then
                                                       interval_num else
                                                       null
                                                  end
                                   ) , 'mm')
       end ,
      --nvl(plan_date,'01.01.1900'),
      claim_date,   --���������
      claim_count,  --���������� ���������
      nvl(d_v,'01.01.1900'),
      add_invest,
      fund_brief,msdate,
      risk_sum,
      reinsurer_perc,
      nvl(reinsurer,'-'),
      st_note,
      nvl(p49,'01.01.1900'),p31,
      p37,
      paym_amount,
      paym_ids,
      non_insurer,
      paym_ndfl,
      case when nvl(paym_rate,0) = 0 then paym_rate_DS else paym_rate end,
      p38,nvl(p24 - (p24*(reinsurer_perc/100)),0),
      p43,p45,p46,p48,p32-1,p50, case when p45 in ('�������� �� ������','������','�������� � �������') then
                                                          (case when (amount > 0) and  (nvl(paym,0) - nvl(decl,0)) * rate / amount > 0 then 1 else 0 end)
                                                          else 2 end,
      pol_header_id,
      nvl(date_last_st,'01.01.1900'),
      policy_holder,
      insurance_period,
      date_to,
      risk_name_progr,
      risk_name,
      rate_ins_amount,
      p_cover_id,
      policy_header_id

union

select
       case when (case when nvl(et.to_agency,'������') <> '������ ����������' then '������' else et.to_agency end) in ('�������� �� ������','������','�������� � �������') then
            (case when nvl(et.sum_real_risk,0) <> 0 then 1 when nvl(et.non_insurer,0) <> 0 then 1 else 0 end)
            else 2
       end p51,

       UPPER(nvl(et.num_pret,'�')) num_pret,--� ���������, �������� ������ (�����  / �� �����)

       (case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end) num_event, --� ����

       et.pol_num,--� ������
       et.ids,
       (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1) policy_header_id,
       nvl(et.type_pol,'-') type_pol,
       et.name_product,
       et.brief_product,
       et.insurer,
       UPPER(et.gender) gender,--���
       nvl(et.date_of_birth,'01.01.1900') date_of_birth,--���� ��������
       nvl(et.professional,'-') professional,--���������
       et.name_agent,--�����
       et.name_manager,--��������
       substr(et.name_dep,instr(et.name_dep,'.',1) + 1) name_dep,--�����
       et.code_dep,--��� �������
       nvl(et.date_header,'01.01.1900') date_header,--���� ���������� �������� � ����
       nvl(et.date_in_company,'01.01.1900') date_in_company,--���� ��������� �����������--date_in_company
       nvl(et.date_all_doc,'01.01.1900') date_all_doc,--���� ��������� ���� ����������--date_all_doc
       nvl(et.date_event,'01.01.1900') date_event,--���� ����������� ���������� �������--date_event
       et.days_to_ss,--���������� ���� �������� ������ �� ����������� ��
       et.diagnos,--�������
       nvl(et.recom_prog,'-') recom_prog,--�������� ���������
       et.risks,--�������� ������, ����������� ���������� ������������� �������
       nvl(et.limit_risks,0) limit_risks,--����� ��������������� ��  ������
       et.currency,--������
       nvl(et.rate_amount,0) * 100 rate_amount,--% �� �� �����--ubitok_z
       nvl(et.summ_future_risk,0) summ_future_risk,--����� ��������������� ���������� ����������� �� ������� �����  (��� ��������)
       nvl(et.reserve_sum_future_risk,0) reserve_sum_future_risk,--����������������� ����� ��������������� ���������� ����������� �� ������� �����
       nvl(et.plan_date,'01.01.1900') plan_date,--������ ������ ��������� ������� (��� ������ ������ � ������������)
       nvl(et.date_to_vipl,'01.01.1900') date_to_vipl,--���� ����������� � ������� (���� ����������� ���������� ����)--date_get_decision1
       nvl(et.date_abort_vipl,'01.01.1900') date_abort_vipl,--���� ������ � �������--date_get_decision2
       nvl(et.date_from_account,'01.01.1900') date_from_account,--���� ������� (������� �� ����������� ����� ������)--date_ppi
       nvl(et.add_invest,0) add_invest,--�������������� �������������� �����
       nvl(et.sum_real_risk,0) sum_real_risk,--����� ������������ ���������� ����������� �� ������� ����� (��� ��������)--sum_ppi
       nvl(et.paym_amount, 0) paym_amount,--���� �������������
       nvl(et.paym_ids, 0) paym_ids,--��� �� ������
       nvl(et.non_insurer,0) non_insurer,--����������� �������, 91 ����
       nvl(et.paym_ndfl,0) paym_ndfl,--���������� ����
       nvl(et.paym_rate,0) paym_rate,--���� ������ �� ���� �������
       nvl(et.sum_risk_reins,0) sum_risk_reins,--����� ��� ������ ���������������
       nvl(et.rate_reins,0) * 100 rate_reins,--% ���������������
       nvl(et.quota_reins,0) quota_reins,--���� ���������������
       decode(nvl(et.reinsurer,'�� ���������'),'Gen Re','��������� ���������������� ��������',
                                               'GenRe','��������� ���������������� ��������',
                                               'Munich Re','���������� ���������������� ��������',
                                               'MunichRe','���������� ���������������� ��������',
                                               'Eastern Re','��������� ���������������� ��������',
                                               'EasternRe','��������� ���������������� ��������',
                                               '�� ���������') reinsurer,--��������������
       nvl(et.sum_vipl,0) sum_vipl,--����� ������������ ���������� ����������� �� ������� ����� (��� ���� ���������������)
       case (case when (case when nvl(et.to_agency,'������') <> '������ ����������' then '������' else et.to_agency end)
                       in ('�������� �� ������','������','�������� � �������')
                   then
                       (case when nvl(et.sum_real_risk,0) <> 0 then 1 else 0 end)
                  else 2 end)
             when 1 then nvl(et.date_from_account,'01.01.1900')
             when 0 then nvl(et.date_abort_vipl,'01.01.1900')
             else to_date('01.01.1900','dd.mm.yyyy')
       end date_last_st,--��������� ������
       case when nvl(et.state,'������') <> '������ ����������' then '������' else et.state end state,--������
       nvl(et.note,'-') note,--�����������--note
       nvl(et.st_note,'-') st_note,--����������� � ������� ����
       nvl(et.per_from_all_doc,'01.01.1900') per_from_all_doc,--���� ������������ � ���� ��������� ���� ����������
       case when nvl(et.to_agency,'������') <> '������ ����������' then '������' else et.to_agency end to_agency,--�������� � �������������
       nvl(et.date_to_oplata,'01.01.1900') date_to_oplata,--���� �������� �� ������--date_oplata
       nvl(et.otkaz,'-') otkaz,--������� ������--otkaz
       nvl(et.claim_date,'01.01.1900') claim_date, --���������
       nvl(et.claim_count,0)claim_count, --���������� ���������
       '������' import,
       (select max(c.obj_name_orig)
       from ins.p_policy p,
            ins.p_pol_header ph,
            ins.p_policy_contact ppc,
            ins.t_contact_pol_role cpr,
            ins.contact c
       where p.pol_header_id = ph.policy_header_id
             and nvl(et.date_event,'01.01.1900') between p.start_date and p.end_date
             and ppc.policy_id = p.policy_id
             and ppc.contact_policy_role_id = cpr.id
             and cpr.description = '������������'
             and ppc.contact_id = c.contact_id
             and ph.policy_header_id = (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1)
      ) policy_holder,
      (select max(case opt.description when '��������� ���������������� ���������� �������� �����������'
                            then trunc(months_between(pc.end_date + 1, ph.start_date), 0) / 12
                            else trunc(months_between(p.end_date + 1, ph.start_date), 0) / 12 end)
       from ins.p_policy p,
            ins.p_pol_header ph,
            ins.as_asset a,
            ins.p_cover pc,
            ins.t_prod_line_option opt
       where p.pol_header_id = ph.policy_header_id
             and nvl(et.date_event,'01.01.1900') between p.start_date and p.end_date
             and ph.policy_header_id = (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1)
             and p.policy_id = a.p_policy_id
             and a.as_asset_id = pc.as_asset_id
             and pc.t_prod_line_option_id = opt.id
      ) insurance_period,
      (select max(
              case when decode(pc.is_avtoprolongation,1,'��',0,'���','���') = '��'
              then (case when decode(ig.life_property, 0, 'C', 1, 'L', NULL) = 'C'
                         then (case when mod(trunc(months_between(p.end_date + 1, ph.start_date), 0) / 12,1) = 0
                                    then (case when extract(year from pc.end_date) - extract(year from pc.start_date) > 1
                                               then (case extract(year from ph.start_date) when 2005
                                                                                           then ph.start_date + 364 + 364 + 364 + 365
                                                                                           when 2006
                                                                                           then ph.start_date + 364 + 364 + 365
                                                                                           when 2007
                                                                                           then ph.start_date + 364 + 365
                                                                                           when 2008
                                                                                           then ph.start_date + 365
                                                                                           else pc.end_date end)
                                                else pc.end_date end)
                                    else pc.end_date end)
                         else pc.end_date end)
             else pc.end_date
             end
             )
       from ins.p_policy p,
            ins.p_pol_header ph,
            ins.as_asset a,
            ins.p_cover pc,
            ins.t_prod_line_option opt,
            ins.t_product_line pll,
            ins.t_lob_line ll,
            ins.t_insurance_group ig
       where p.pol_header_id = ph.policy_header_id
             and nvl(et.date_event,'01.01.1900') between p.start_date and p.end_date
             and ph.policy_header_id = (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1)
             and p.policy_id = a.p_policy_id
             and a.as_asset_id = pc.as_asset_id
             and pc.t_prod_line_option_id = opt.id
             and opt.product_line_id = pll.id
             and pll.t_lob_line_id = ll.t_lob_line_id
             and ll.insurance_group_id = ig.t_insurance_group_id
      ) date_to,
      (select max(ll.description)
       from ins.p_policy p,
            ins.p_pol_header ph,
            ins.as_asset a,
            ins.p_cover pc,
            ins.t_prod_line_option opt,
            ins.t_product_line pll,
            ins.t_lob_line ll
       where p.pol_header_id = ph.policy_header_id
             and nvl(et.date_event,'01.01.1900') between p.start_date and p.end_date
             and ph.policy_header_id = (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1)
             and p.policy_id = a.p_policy_id
             and a.as_asset_id = pc.as_asset_id
             and pc.t_prod_line_option_id = opt.id
             and opt.product_line_id = pll.id
             and pll.t_lob_line_id = ll.t_lob_line_id
      ) risk_name_progr,
      (select max(opt.description)
       from ins.p_policy p,
            ins.p_pol_header ph,
            ins.as_asset a,
            ins.p_cover pc,
            ins.t_prod_line_option opt
       where p.pol_header_id = ph.policy_header_id
             and nvl(et.date_event,'01.01.1900') between p.start_date and p.end_date
             and ph.policy_header_id = (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1)
             and p.policy_id = a.p_policy_id
             and a.as_asset_id = pc.as_asset_id
             and pc.t_prod_line_option_id = opt.id
      ) risk_name,
      trim(substr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),1,instr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),'/') - 1 )) ord1,

       to_number(trim(substr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),instr((case when instr(et.num_event,'-',1) > 0 then
            lpad(substr(et.num_event,1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1)),9,'0')||'/'||substr(et.num_event,instr(et.num_event,'-',1) + 1, length(et.num_event) - ((length(et.num_event) - instr(et.num_event,'-',1)) + 1))
            else lpad(et.num_event,9,'0')||'/'||'1'
       end),'/') + 1))) ord2,
       null,--ch.c_claim_header_id
       null,--clm.c_claim_id
       null,--e.c_event_id
       0 p_cover_id,
       (select ph.policy_header_id from ins.p_pol_header ph where ph.ids = et.ids and rownum = 1) policy_header_id
from etl.import_export_claim et
--where rownum = 1
order by 1,2
;


create materialized view INS_DWH.MV_CR_CLIENT
build deferred
refresh force on demand
as
select pr.description product_name, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       c.CONTACT_ID issuer_id, -- �� �������
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- ������������ - ������
       f1.brief fund, -- ������ ���
       f2.brief fynd_pay, -- ������ ��������
       pp.premium premium_amount, -- ������
       ins.pkg_rep_utils.pay_prem_policy(pp.POLICY_ID) premium_pay_amount, --�������� ������
       pay.pay_summ damage_pay_amount, --����������� ������
       decode (nvl(decl.dec_summ,0) - nvl(decline.decline_summ,0),0,0,
          decode ((nvl(decl.dec_summ,0) - nvl(decline.decline_summ,0))/
                    abs((nvl(decl.dec_summ,0) - nvl(decline.decline_summ,0))),
                    1,nvl(decl.dec_summ,0) - nvl(decline.decline_summ,0),
                    0)) damage_declare_amount --���������� ������� ������
 from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ins.ven_contact c on c.contact_id = ppc.contact_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
  left join (
            select pp.pol_header_id,sum(t.acc_amount) pay_summ
            from ins.ven_trans t
             join ins.ven_trans_templ tt on tt.trans_templ_id = t.trans_templ_id
             join ins.ven_c_damage cd on t.a5_dt_uro_id = cd.c_damage_id
             join ins.ven_c_claim cc on cc.c_claim_id = cd.c_claim_id
             join ins.ven_c_claim_header ch on ch.c_claim_header_id = cc.c_claim_header_id
             join ins.ven_p_policy pp on ch.p_policy_id = pp.policy_id
            where tt.brief in ('������������','������������')
             and t.trans_date <= sysdate
            group by pp.pol_header_id
          )pay on pay.pol_header_id = ph.policy_header_id
 left join (
             select pp1.pol_header_id,sum(cc.payment_sum - nvl(v.vipl,0)) dec_summ
             from ins.p_policy pp1
              join ins.c_claim_header ch on ch.p_policy_id = pp1.policy_id
              join ins.ven_c_claim cc on cc.c_claim_header_id =ch.c_claim_header_id
              join ins.p_cover pc on pc.p_cover_id = ch.p_cover_id
              join ins.t_prod_line_option plo on plo.id = pc.t_prod_line_option_id
              left join (select cd.c_claim_id,
                                sum(t.acc_amount) vipl
                         from ins.trans t
                          join ins.trans_templ tt on tt.trans_templ_id = t.trans_templ_id
                          join ins.c_damage cd on t.a5_dt_uro_id = cd.c_damage_id
                         where tt.brief in ('������������','������������')
                           and t.trans_date <= sysdate
                         group by cd.c_claim_id
                        ) v on v.c_claim_id = cc.c_claim_id
             where cc.seqno = (select max(cc2.seqno)
                               from ins.c_claim cc2
                               where cc2.c_claim_header_id = ch.c_claim_header_id
                                 and cc2.claim_status_date <= sysdate
                             )
             group by  pp1.pol_header_id
           )decl on decl.pol_header_id = ph.policy_header_id
        left join (
             select pp1.pol_header_id,sum(cd.decline_sum) decline_summ
             from ins.p_policy pp1
              join ins.c_claim_header ch on ch.p_policy_id = pp1.policy_id
              join ins.ven_c_claim cc on cc.c_claim_header_id =ch.c_claim_header_id
              join ins.c_damage cd on cd.c_claim_id = cc.c_claim_id
              group by  pp1.pol_header_id
           )decline on decline.pol_header_id = ph.policy_header_id;


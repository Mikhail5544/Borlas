create materialized view INS_DWH.MV_CR_POL_JOURNAL_POLICY
build deferred
refresh force on demand
as
select pr.description product_name, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- ������������
       case
        when cct.telephone_prefix is not null then '('||cct.telephone_prefix ||') '||cct.telephone_number
        when cct.telephone_prefix is null then cct.telephone_number
        else null
       end phone, --���������� �������
       ph.start_date, -- ���� ������
       pp.end_date, -- ���� ���������
       f1.brief fund, -- ������ ���
       f2.brief fund_pay, -- ������ ��������
       pp.ins_amount, -- ����� �����
       pp.premium,-- ���� ������
       p_in.next_bill next_bill_date, -- ��������� ����
       nvl(opl.oplacheno,0) - nvl(vozv.vozvrat,0) paid_up_amount, -- �������� �� ��������,
       col_loss.col loss_number, -- ���������� ������� �� ��������
       col_loss_pay.summ loss_amount, -- ����� �������
       sc.description sales_channel, -- ����� ������,
       ins.ent.obj_name(c1.ent_id,c1.contact_id) curator, -- �������
       pp.confirm_date    -- ���� ���������� � ����
from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '������������'
 join ins.ven_contact c on c.contact_id = ppc.contact_id
 join ins.ven_p_policy_contact ppc1 on ppc1.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr1 on cpr1.id = ppc1.contact_policy_role_id and cpr1.brief = '�������'
 join ins.ven_contact c1 on c1.contact_id = ppc1.contact_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ins.t_sales_channel sc on sc.id = ph.sales_channel_id
 left join ins.cn_contact_telephone cct on cct.contact_id = c.contact_id and cct.id in (
                                                                                    select min(cct1.id)
                                                                                    from ins.cn_contact_telephone cct1
                                                                                    group by cct1.contact_id
                                                                                   )
 left join (
            select pp1.pol_header_id,sum(t1.acc_amount) oplacheno
            from ins.trans t1
             join ins.trans_templ tt1 on t1.trans_templ_id = tt1.trans_templ_id
             join ins.p_policy pp1 on pp1.policy_id = t1.a2_ct_uro_id
            where tt1.brief = '�����������'
            group by pp1.pol_header_id
           )opl on opl.pol_header_id = ph.policy_header_id
 left join (
            select pp2.pol_header_id,sum(t2.acc_amount) vozvrat
            from ins.trans t2
             join ins.trans_templ tt2 on t2.trans_templ_id = tt2.trans_templ_id
             join ins.p_policy pp2 on pp2.policy_id = t2.a2_dt_uro_id
            where tt2.brief = '�������������'
            group by pp2.pol_header_id
           )vozv on vozv.pol_header_id = ph.policy_header_id
 left join (
            select pp3.pol_header_id,count(e.c_event_id) col
            from ins.c_event e
             join ins.as_asset ass on ass.as_asset_id = e.as_asset_id
             join ins.p_policy pp3 on pp3.policy_id = ass.p_policy_id
            group by pp3.pol_header_id
           ) col_loss on col_loss.pol_header_id  = ph.policy_header_id
 left join (
            select pay.pol_header_id,min(pay.due_date) next_bill
            from ins.V_POLICY_PAYMENT_SCHEDULE pay
             where pay.document_id not in (
                                           select pay_off.parent_doc_id
                                           from ins.V_POLICY_PAYMENT_SET_OFF pay_off
                                           )
            group by pay.pol_header_id
           ) p_in on p_in.pol_header_id = ph.policy_header_id
 left join (
            select pp3.pol_header_id,sum(cc.payment_sum) summ
            from ins.c_event e1
             join ins.as_asset ass on ass.as_asset_id = e1.as_asset_id
             join ins.p_policy pp3 on pp3.policy_id = ass.p_policy_id
             join ins.c_claim_header ch on ch.c_event_id = e1.c_event_id
             join ins.c_claim cc on cc.c_claim_header_id  = ch.c_claim_header_id
            where cc.seqno = (
                              select max(cc1.seqno)
                              from ins.c_claim cc1
                              where cc1.c_claim_header_id = ch.c_claim_header_id
                             )
            group by pp3.pol_header_id
           ) col_loss_pay on col_loss_pay.pol_header_id  = ph.policy_header_id;


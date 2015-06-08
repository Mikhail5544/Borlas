create materialized view INS_DWH.MV_CR_AGENT_PREMIUM
build deferred
refresh force on demand
as
select
 pr.description product_name, -- продукт
 pp.pol_ser,   --сери€ полиса
 pp.pol_num,   --номер полиса
 ph.policy_header_id as policy_header_id,
 c.contact_id as agent_id, -- »ƒ агента
 c1.contact_id as issuer_id,
 c1.obj_name_orig as issuer,
 c.obj_name_orig as agent , --им€ агента
 tr.acc_amount as amount, -- поступивша€ преми€
 f1.brief fund, -- валюта отв
 tr.trans_date --дата зачета денег
from ins.trans tr
 join ins.ven_p_policy pp on pp.policy_id = tr.a2_ct_uro_id
 join ins.p_pol_header ph on ph.policy_header_id = pp.pol_header_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.oper o on o.oper_id = tr.oper_id
 join ins.doc_set_off d on d.doc_set_off_id = o.document_id
 join ins.oper o1 on o1.document_id = d.doc_set_off_id
 join ins.trans tr1 on tr1.oper_id  = o1.oper_id
 join ins.trans_templ tt on tt.trans_templ_id  = tr.trans_templ_id
 join ins.trans_templ tt1 on tt1.trans_templ_id  = tr1.trans_templ_id
 join ins.contact c on c.contact_id = tr1.a1_dt_uro_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = '—трахователь'
 join ins.ven_contact c1 on c1.contact_id = ppc.contact_id
 join ins.ven_fund f1 on f1.fund_id = ph.fund_id
 where tt.brief = '«ач¬зн—трјг'
   and tt1.brief = 'ѕеренес«адолжјг';


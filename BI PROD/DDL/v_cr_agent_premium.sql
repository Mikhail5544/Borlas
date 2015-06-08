CREATE OR REPLACE FORCE VIEW V_CR_AGENT_PREMIUM
(product_name, pol_ser, pol_num, policy_header_id, agent_id, issuer_id, issuer, agent, amount, fund, trans_date, rate_agent)
AS
SELECT
 pr.description, -- продукт
 pp.pol_ser,   --сери€ полиса
 pp.pol_num,   --номер полиса
 ph.policy_header_id AS policy_header_id,
 c.contact_id AS agent_id, -- »ƒ агента
 c1.contact_id AS issuer_id,
 c1.obj_name_orig AS issuer,
 c.obj_name_orig AS agent , --им€ агента
 tr.acc_amount AS amount, -- поступивша€ преми€
 f1.brief, -- валюта отв
 tr.trans_date, --дата зачета денег
 ac.rate_agent -- процент агента 
FROM trans tr
 JOIN ven_p_policy pp ON pp.policy_id = tr.a2_ct_uro_id
 JOIN p_pol_header ph ON ph.policy_header_id = pp.pol_header_id
 JOIN p_policy_agent pa ON pa.POLICY_HEADER_ID = ph.POLICY_HEADER_ID
 JOIN ag_contract_header ch ON ch.AG_CONTRACT_HEADER_ID = pa.AG_CONTRACT_HEADER_ID 
 JOIN ag_contract ac ON ac.AG_CONTRACT_ID  = ch.LAST_VER_ID 
 JOIN ven_t_product pr ON pr.product_id = ph.product_id
 JOIN oper o ON o.oper_id = tr.oper_id
 JOIN doc_set_off d ON d.doc_set_off_id = o.document_id
 JOIN oper o1 ON o1.document_id = d.doc_set_off_id
 JOIN trans tr1 ON tr1.oper_id  = o1.oper_id
 JOIN trans_templ tt ON tt.trans_templ_id  = tr.trans_templ_id
 JOIN trans_templ tt1 ON tt1.trans_templ_id  = tr1.trans_templ_id
 JOIN contact c ON c.contact_id = tr1.a1_dt_uro_id
 JOIN ven_contact c1 ON c1.contact_id = pkg_policy.GET_POLICY_CONTACT(pp.POLICY_ID,'—трахователь') 
 JOIN ven_fund f1 ON f1.fund_id = ph.fund_id
 WHERE tt.brief = '«ач¬зн—трјг'
   AND tt1.brief = 'ѕеренес«адолжјг'
;


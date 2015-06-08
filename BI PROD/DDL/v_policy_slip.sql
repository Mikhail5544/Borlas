CREATE OR REPLACE FORCE VIEW V_POLICY_SLIP
(policy_id, pol_header_id, re_slip_id, num, start_date, end_date, product_id, description, cont_name, sb, sc, sn, ss, sr)
AS
SELECT 
 policy_id, pol_header_id, re_slip_id, num, start_date, end_date, product_id, description, cont_name,
SUM(brutto_premium) bp, SUM(commission) sc, SUM(netto_premium) sn, SUM(part_sum) ss, SUM(reten_val) sr 
FROM (
SELECT pp.policy_id, pp.pol_header_id, rc.re_slip_id, pp.num, pp.start_date,
       pp.end_date, p.product_id, p.description,
       ent.obj_name ('CONTACT', ppc.contact_id) cont_name, 
       rc.brutto_premium, rc.commission, rc.netto_premium, rc.part_sum
       , (NVL(rc.INS_AMOUNT,0) - NVL(rc.PART_SUM,0) + ABS(NVL(rc.INS_AMOUNT,0) - NVL(rc.PART_SUM,0)) )/2 reten_val
  FROM ven_re_cover rc,
       ven_p_policy pp,
       ven_p_pol_header pph,
       ven_t_product p,
       ven_p_policy_contact ppc,
       ven_t_contact_pol_role cpr
 WHERE pp.policy_id = rc.ins_policy
   AND pph.policy_header_id = pp.pol_header_id
   --AND pph.policy_id = pp.policy_id
   AND p.product_id = pph.product_id
   AND ppc.policy_id = pp.policy_id
   AND cpr.brief = 'Страхователь'
   AND ppc.contact_policy_role_id = cpr.ID)
GROUP BY policy_id, pol_header_id, re_slip_id, num, start_date, end_date, product_id, description, cont_name
;


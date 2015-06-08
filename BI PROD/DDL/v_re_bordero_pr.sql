CREATE OR REPLACE FORCE VIEW V_RE_BORDERO_PR AS
SELECT RRB.RE_BORDERO_ID
      ,RRB.RE_COVER_ID
      ,REL_RECOVER_BORDERO_ID
      ,rca.re_calculation_id
      ,RRB.is_accept
      ,pl.description
      ,rrb.ac_payment_id
      ,trim(pp.POL_SER||' '||pp.POL_NUM) pol_num
      ,ent.obj_name('AS_PROPERTY', aas.as_asset_id) obj_prop
      ,ent.obj_name('AS_VEHICLE', aas.as_asset_id) obj_vehicle
      ,ent.obj_name('AS_PERSON_MED', aas.as_asset_id) obj_med
      ,DECODE (tp.is_insured, 0, ent.obj_name('CONTACT', NVL(aa.assured_contact_id,aa.contact_id)),ent.obj_name('CONTACT', ppc.contact_id)) obj_assured
      ,ent.obj_name('CONTACT', ppc.contact_id) insurer_name
      ,NVL(rrb.plan_date, ap.plan_date) acc_start_date
      ,ADD_MONTHS(ap.plan_date,12/pt.NUMBER_OF_PAYMENTS) acc_end_date
      ,pc.START_DATE
      ,pc.end_date
      ,pc.fee
      ,pc.PREMIUM
      ,RRB.INS_PREMIUM INS_PREMIUM_in
      ,RC.INS_AMOUNT
      ,rca.reserve_begin_null
      ,rca.first_ins_guarantee
      ,rca.part_sum*100 part_perc
      ,rca.reserve_begin
      ,rca.ins_guarantee
      ,rca.reins_guarantee
      ,rca.re_tariff
      ,rca.base_rate_reins
      ,rca.k_down_payment
      ,RRB.BRUTTO_PREMIUM
      ,RRB.COMMISSION
      ,RRB.NETTO_PREMIUM
      ,rrb.RETURNED_PREMIUM
  FROM rel_recover_bordero rrb
     , re_cover rc
     , p_cover pc
     , ven_as_assured aa
     , as_asset aas
     , t_product_line pl
     , p_policy pp
     , p_policy_contact ppc
     , t_contact_pol_role cpr
     , ac_payment ap
     , t_payment_terms pt
     , entity e
     , re_calculation rca
     , t_as_type_prod_line tp
 WHERE rrb.re_cover_id = rc.re_cover_id
   AND rc.p_cover_id = pc.p_cover_id(+)
   AND aas.P_POLICY_ID = rc.INS_POLICY
   AND aas.P_ASSET_HEADER_ID = rc.P_ASSET_HEADER_ID
   AND aa.as_assured_id(+) = aas.as_asset_id
   AND pl.ID = rc.T_PRODUCT_LINE_ID
   AND pp.policy_id = aas.p_policy_id
   AND ppc.policy_id = pp.policy_id
   AND cpr.brief = 'Страхователь'
   AND ppc.contact_policy_role_id = cpr.ID
   AND ap.payment_id(+) = rrb.ac_payment_id
   AND pt.ID = pp.payment_term_id
   AND e.brief = 'REL_RECOVER_BORDERO'
   AND rca.ure_id = e.ent_id
   and pkg_policy.get_last_version_status(pp.POL_HEADER_ID) <> 'Готовится к расторжению'
   AND rca.uro_id = rrb.rel_recover_bordero_id
   AND tp.product_line_id(+) = pl.ID;


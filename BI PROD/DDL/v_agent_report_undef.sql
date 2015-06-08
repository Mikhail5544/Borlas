create or replace force view v_agent_report_undef as
select
  ca.cover_agent_id,
  con.contact_id,
  ent.obj_name(con.ent_id, con.contact_id) contact_name, -- имя страхователя
  ig.t_insurance_group_id,
  ig.description t_insurance_group_desc,
  c.t_prod_line_option_id,
  plo.description t_prod_line_option_desc,
  t.trans_id,
  t.a1_dt_ure_id,
  t.a1_dt_uro_id,
  t.a1_ct_ure_id,
  t.a1_ct_uro_id,
  t.a2_dt_ure_id,
  t.a2_dt_uro_id,
  t.a2_ct_ure_id,
  t.a2_ct_uro_id,
  t.a3_dt_ure_id,
  t.a3_dt_uro_id,
  t.a3_ct_ure_id,
  t.a3_ct_uro_id,
  t.a4_dt_ure_id,
  t.a4_dt_uro_id,
  t.a4_ct_ure_id,
  t.a4_ct_uro_id,
  t.a5_dt_ure_id,
  t.a5_dt_uro_id,
  t.a5_ct_ure_id,
  t.a5_ct_uro_id,
  t.trans_amount ins_amount,
  c.premium cover_premium,
  NULL ag_type_defin_rate_id,-- tdf.ag_type_defin_rate_id,
  NULL ag_type_defin_rate_name,-- tdf.name ag_type_defin_rate_name,
  NULL ag_type_rate_value_id,-- trv.ag_type_rate_value_id,
  NULL ag_type_rate_value_name,--trv.name ag_type_rate_value_name,
  NULL value,--r.value,
  ap.payment_id,
  ap.num,
  ap.due_date,
 NULL trans_amount -- round(t.trans_amount * r.value)/100 trans_amount
from
  p_cover_agent ca,
  p_cover c,
  as_asset ass,
  p_policy p,
  p_pol_header ph,
  p_policy_contact pc,
  t_contact_pol_role cpr,
  contact con,
  t_prod_line_option plo,
  t_product_line pl,
  t_insurance_group ig,
/*  ag_rate r,
  ag_type_defin_rate tdf,
  ag_type_rate_value trv,*/
  trans t,
  trans_templ tt,
  oper o,
  doc_set_off dso,
  ven_ac_payment ap
where
  ca.cover_id = c.p_cover_id and
  c.as_asset_id = ass.as_asset_id and
  ass.p_policy_id = p.policy_id and
  ph.policy_header_id = p.pol_header_id and
  pc.policy_id = p.policy_id and
  pc.contact_policy_role_id = cpr.id and
  pc.contact_id = con.contact_id and
  cpr.description = 'Страхователь' and
  c.t_prod_line_option_id = plo.id and
  plo.product_line_id = pl.id and
  ig.t_insurance_group_id = pl.insurance_group_id and
 -- ca.rate_id = r.ag_rate_id(+) and
 -- r.type_defin_rate_id = tdf.ag_type_defin_rate_id(+) and
 -- r.type_rate_value_id = trv.ag_type_rate_value_id(+) and
  t.trans_templ_id = tt.trans_templ_id and
  tt.brief = 'ПеренесЗадолж' and
  t.a5_dt_uro_id = c.p_cover_id and
  o.oper_id = t.oper_id and
  o.document_id = dso.doc_set_off_id and
  ap.payment_id = dso.child_doc_id
/*  not exists
  (
    select
      arc.agent_report_cont_id
    from
      agent_report_cont arc
    where
      arc.cover_agent_id = ca.cover_agent_id and
      arc.payment_id = ap.payment_id
  )*/
;


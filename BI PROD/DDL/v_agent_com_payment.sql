create or replace force view v_agent_com_payment as
select
  ppac.p_policy_agent_com_id,
  ach.ag_contract_header_id,
  t.trans_id,
  t.acc_amount,
  t.trans_amount,
  ppa.part_agent,
  f.fund_id,
  f.brief fund_brief,
  atrv.ag_type_rate_value_id,
  atrv.brief ag_type_rate_value_brief,
  tpct.t_prod_coef_type_id,
  tpct.brief t_prod_coef_type_brief,
  atdr.ag_type_defin_rate_id,
  atdr.brief ag_type_defin_rate_brief,
  ppac.val_com,
  ach.agent_id,
  t.trans_date,
  pc.ent_id p_cover_ent_id,
  pc.p_cover_id
from
  p_policy_agent ppa ,
  ag_contract_header ach,
  trans t,
  trans_templ tt,
  as_asset a,
  p_policy p,
  p_policy_agent_com ppac,
  p_cover pc,
  t_prod_line_option plo,
  fund f,
  ag_type_rate_value atrv,
  t_prod_coef_type tpct,
  ag_type_defin_rate atdr,
  policy_agent_status pas
where
  ppa.ag_contract_header_id = ach.ag_contract_header_id and
  t.trans_templ_id = tt.trans_templ_id and
  tt.brief = 'СтраховаяПремияОплачена' and
  t.a2_ct_uro_id = p.policy_id and
  p.pol_header_id = ppa.policy_header_id and
  ppac.p_policy_agent_id = ppa.p_policy_agent_id and
  a.as_asset_id = pc.as_asset_id and
  a.p_policy_id = p.policy_id and
  t.a5_ct_uro_id = pc.p_cover_id and
  pc.t_prod_line_option_id = plo.id and
  plo.product_line_id = ppac.t_product_line_id and
  f.fund_id = t.acc_fund_id and
  ppac.ag_type_rate_value_id = atrv.ag_type_rate_value_id and
  ppac.t_prod_coef_type_id = tpct.t_prod_coef_type_id(+) and
  ppac.ag_type_defin_rate_id = atdr.ag_type_defin_rate_id and
  ppa.status_id = pas.policy_agent_status_id and
  pas.brief <> 'CANCEL' and
  not exists(
    select arc.agent_report_cont_id
    from   agent_report_cont arc
    where  arc.p_policy_agent_com_id = ppac.p_policy_agent_com_id and
           arc.trans_id = t.trans_id
  );


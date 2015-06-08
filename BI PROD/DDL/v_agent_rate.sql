create or replace force view v_agent_rate as
select
    ppac.p_policy_agent_com_id,
    --ph.num,
    ph.policy_header_id,
    ach.agent_id,
    --ent.obj_name(c.ent_id, c.contact_id) agent_name,
    pl.id product_line_id,
    --pl.description product_line_desc,
    ppa.part_agent,
    ppac.val_com,
    atrv.brief ag_type_rate_value_name,
    atdr.brief ag_type_defin_rate_name,
    pct.name prod_coef_type_name,
    (
     select nvl(sum(t.trans_amount), 0)
     from   trans t, trans_templ tt
     where  t.trans_templ_id = tt.trans_templ_id and
            tt.brief = 'ѕеренес«адолжјг' and
            t.a4_dt_uro_id = ppac.p_policy_agent_id
    ) base_calc_amount,
    (
      0
    ) comm_amount,
    (
       select nvl(sum(t.trans_amount), 0)
       from   trans t, trans_templ tt
       where  t.trans_templ_id = tt.trans_templ_id and
              tt.brief = 'Ќач ¬' and
              t.a5_dt_uro_id = ppac.p_policy_agent_com_id
    ) charge_amount,
    (
      0
    ) paid_amount
  from
    p_policy_agent_com ppac, -- комиссии агентов по договору
    p_policy_agent ppa, -- агент по договору
    ven_p_pol_header ph,
    ag_contract_header ach,
    contact c,
    t_product_line pl,
    ag_type_rate_value atrv,
    ag_type_defin_rate atdr,
    t_prod_coef_type pct
  where
    ppac.p_policy_agent_id = ppa.p_policy_agent_id and
    ppa.policy_header_id = ph.policy_header_id and
    ppa.ag_contract_header_id = ach.ag_contract_header_id and
    ach.agent_id = c.contact_id and
    ppac.t_product_line_id = pl.id and
    ppac.ag_type_rate_value_id = atrv.ag_type_rate_value_id and
    ppac.ag_type_defin_rate_id = atdr.ag_type_defin_rate_id and
    ppac.t_prod_coef_type_id = pct.t_prod_coef_type_id(+)
  order by agent_id
;


create or replace force view v_prod_line_dms_depos as
select t.prod_line_dms_depos_id,
       t.ent_id,
       t.filial_id,
       t.ext_id,
       t.depos_pr,
       t.depos_sum,
       t.description,
       rpd.t_prod_line_dms_id,
       tpld.p_policy_id,
       pp.num,
       c.obj_name_orig ins_name
  from prod_line_dms_depos t,
       ven_rel_prodline_depos rpd,
       ven_t_prod_line_dms tpld,
       ven_p_policy pp,
       ven_p_pol_header pph,
       ven_contact c,
       ven_p_policy_contact ppc,
       ven_t_contact_pol_role tcpr
 where c.contact_id = ppc.contact_id
   and upper(tcpr.brief) = '—“–¿’Œ¬¿“≈À‹'
   and tcpr.id = ppc.contact_policy_role_id
   and ppc.policy_id = pp.policy_id
   and pph.policy_id = pp.policy_id
   and pp.policy_id = tpld.p_policy_id
   and tpld.t_prod_line_dms_id = rpd.t_prod_line_dms_id
   and rpd.t_prod_line_dms_depos_id = t.prod_line_dms_depos_id;


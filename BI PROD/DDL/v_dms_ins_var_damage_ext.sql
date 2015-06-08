create or replace force view v_dms_ins_var_damage_ext as
select
  null dms_ins_var_damage_id,
  null ent_id,
  null filial_id,
  null ext_id,
  divp.dms_ins_var_prg_id,
  tdc.id t_damage_code_id,
  0 is_excluded,
  tdc.peril peril_id
from
  dms_ins_var_prg divp,
  t_damage_code tdc,
  t_product_line tpl,
  t_prod_line_option tplo,
  t_prod_line_opt_peril tplop
where
  tdc.peril = tplop.peril_id and
  divp.t_product_line_id = tpl.id and
  tplo.product_line_id = tpl.id and
  tplop.product_line_option_id = tplo.id and
  not exists(
    select *
    from t_prod_line_damage tpld
    where tpld.t_damage_code_id = tdc.id and
          tpld.t_prod_line_opt_peril_id = tplop.id
  ) and
  not exists(
    select *
    from   dms_ins_var_damage tt
    where  tt.t_damage_code_id = tdc.id and
           tt.dms_ins_var_prg_id = divp.dms_ins_var_prg_id
  )
union all
select
  divd.dms_ins_var_damage_id,
  divd.ent_id,
  divd.filial_id,
  divd.ext_id,
  divd.dms_ins_var_prg_id,
  divd.t_damage_code_id,
  divd.is_excluded,
  tdc.peril peril_id
from
  dms_ins_var_damage divd,
  t_damage_code tdc
where
  divd.t_damage_code_id = tdc.id;


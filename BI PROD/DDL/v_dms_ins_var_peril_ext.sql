create or replace force view v_dms_ins_var_peril_ext as
select
  null dms_ins_var_peril_id,
  null ent_id,
  null filial_id,
  null ext_id,
  divp.dms_ins_var_prg_id,
  tplop.peril_id,
  0 limit_amount,
  0 is_excluded
from
  dms_ins_var_prg divp,
  t_product_line tpl,
  t_prod_line_option tplo,
  t_prod_line_opt_peril tplop
where
  divp.t_product_line_id = tpl.id and
  tplo.product_line_id = tpl.id and
  tplop.product_line_option_id = tplo.id and
  not exists(
    select *
    from   dms_ins_var_peril tt
    where  tt.dms_ins_var_prg_id = divp.dms_ins_var_prg_id and
           tt.peril_id = tplop.peril_id
  )
union all
select
  "DMS_INS_VAR_PERIL_ID","ENT_ID","FILIAL_ID","EXT_ID","DMS_INS_VAR_PRG_ID","PERIL_ID","LIMIT_AMOUNT","IS_EXCLUDED"
from
  dms_ins_var_peril;


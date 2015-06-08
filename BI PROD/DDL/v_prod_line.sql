create or replace force view v_prod_line as
select pl.id,
       pl.product_ver_lob_id,
       pv.product_id,
       pl.insurance_group_id,
       pl.product_line_type_id,
       pl.premium_type,
       pl.description,
       pl.visible_flag,
       pl.is_default,
       pl.sort_order,
       ig.description ig_desc,
       ig.is_default ig_is_def,
       plt.description plt_desc,
       pl.for_premium,
       pt.description pt_desc,
       pl.ent_id,
       pl.filial_id,
       pl.default_forms,
       pl.deduct_func
from ven_t_product_line pl
  left join ven_t_product_ver_lob pvl
    on pvl.t_product_ver_lob_id = pl.product_ver_lob_id
  left join ven_t_product_version pv
    on pv.t_product_version_id = pvl.product_version_id
  left join ven_t_premium_type pt
    on pt.t_premium_type_id = pl.premium_type
  left join ven_t_product_line_type plt
    on plt.product_line_type_id = pl.product_line_type_id
  left join ven_t_insurance_group ig
    on ig.t_insurance_group_id = pl.insurance_group_id;


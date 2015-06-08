create materialized view INS_DWH.DM_RISK_TYPE
refresh force on demand
as
select plo.id risk_type_id,
       p.description  prod_desc,
       p.brief        prod_brief,
       ll.description lob_line_desc,
       ll.brief       lob_line_brief,
       p.brief || ':' || pl.description prod_line_desc,
       p.brief || ':' || pl.brief prod_line_brief,
       l.description lob_desc,
       ig.description ig_desc,
       decode(ig.life_property, 1, 'Д', 0, 'Н') is_life_rsbu
  from ins.t_prod_line_option plo,
       ins.t_product_line     pl,
       ins.t_lob_line         ll,
       ins.t_lob              l,
       ins.t_product_ver_lob  pvl,
       ins.t_product_version  pv,
       ins.t_product          p,
       ins.t_insurance_group  ig
 where plo.product_line_id = pl.id
   and pl.product_ver_lob_id = pvl.t_product_ver_lob_id
   and pl.t_lob_line_id = ll.t_lob_line_id
   and pvl.product_version_id = pv.t_product_version_id
   and pv.product_id = p.product_id
   and ll.insurance_group_id = ig.t_insurance_group_id
   and ll.t_lob_id = l.t_lob_id
union all
select -1 ris_type_id,
       'неопределен'  prod_desc,
       'неопределен'       prod_brief,
       'неопределен' lob_line_desc,
       'неопределен'       lob_line_brief,
       'неопределен' prod_line_desc,
       'неопределен' prod_line_brief,
       'неопределен' lob_desc,
       'неопределен' ig_desc,
       null is_life_rsbu
       from dual;


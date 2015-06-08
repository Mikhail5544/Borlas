create or replace force view v_prod_line_opt_peril as
select prod.product_id, prod.description "Продукт",
       pl.id pl_id, pl.description "Линия страхового продукта",
       opt.id opt_id, opt.description "Наименование риска",
       pr.id pr_id, pr.description "Группа риска",
       bl.description "Страховая программа"
from t_product prod,
     t_product_version ver,
     t_product_ver_lob vl,
     t_lob_line bl,
     t_product_line pl,
     t_product_line_type tl,
     t_prod_line_option opt,
     t_prod_line_opt_peril per,
     t_peril pr
where prod.product_id = ver.product_id
      and vl.product_version_id = ver.t_product_version_id
      and pl.product_ver_lob_id = vl.t_product_ver_lob_id
      and pl.product_line_type_id = tl.product_line_type_id
      and opt.product_line_id = pl.id
      and per.product_line_option_id(+) = opt.id
      and per.peril_id = pr.id(+)

      and vl.lob_id = bl.t_lob_id
      and pl.t_lob_line_id = bl.t_lob_line_id;


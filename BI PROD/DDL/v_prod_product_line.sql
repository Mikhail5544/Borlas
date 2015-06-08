CREATE OR REPLACE VIEW V_PROD_PRODUCT_LINE AS
SELECT p.description  product_name
      ,p.product_id
      ,p.brief        product_brief
      ,pl.id          t_product_line_id
      ,pl.description t_product_line_desc
      ,pl.public_description t_product_line_public_desc
  FROM t_product         p
      ,t_product_version pv
      ,t_product_ver_lob pvl
      ,t_product_line    pl
 WHERE p.product_id = pv.product_id
   AND pv.t_product_version_id = pvl.product_version_id
   AND pvl.t_product_ver_lob_id = pl.product_ver_lob_id;

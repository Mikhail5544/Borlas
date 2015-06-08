CREATE OR REPLACE VIEW V_CRM_POLICY_COVER AS
SELECT ass.p_policy_id
      ,pl.description -- наименование
      ,pc.start_date  -- начало
      ,pc.end_date    -- окончание
      ,pc.fee         -- брутто-взнос
      ,pc.ins_amount -- страховая сумма
      ,trunc(months_between(trunc(pc.end_date) + 1, trunc(pc.start_date))/12, 2) period -- срок
      ,asu.assured_contact_id contact_id
FROM as_asset           ass
    ,as_assured         asu
    ,p_cover            pc
    ,t_prod_line_option plo
    ,t_product_line     pl
WHERE 1 = 1
  AND ass.as_asset_id          = asu.as_assured_id
  AND ass.as_asset_id          = pc.as_asset_id
  AND pc.t_prod_line_option_id = plo.id
  AND plo.product_line_id      = pl.id
  AND NVL(pc.fee, 0)          > 0
  AND pl.visible_flag         = 1
ORDER BY period DESC
;

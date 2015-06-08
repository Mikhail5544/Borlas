CREATE OR REPLACE VIEW V_AS_ASSET_ORDER AS
SELECT t.as_asset_id
      ,t.ent_id
      ,t.filial_id
      ,t.ext_id
      ,t.contact_id
      ,t.deductible_value
      ,t.end_date
      ,t.fee
      ,t.ins_amount
      ,t.ins_limit
      ,t.ins_premium
      ,t.ins_price
      ,t.ins_var_id
      ,t.is_first_event
      ,t.NAME
      ,t.note
      ,t.p_asset_header_id
      ,t.p_policy_id
      ,t.start_date
      ,t.status_hist_id
      ,t.t_deductible_type_id
      ,t.t_deduct_val_type_id
  FROM ven_as_asset t
 ORDER BY t.as_asset_id DESC;

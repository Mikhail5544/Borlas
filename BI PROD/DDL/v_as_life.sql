CREATE OR REPLACE VIEW V_AS_LIFE AS
SELECT decode(pol.pol_ser, NULL, pol.pol_num, pol.pol_ser || '-' || pol.pol_num) pol_num
      ,p.description product
      ,con1.obj_name_orig vladelets
      ,cas.obj_name_orig asset_vehicle
      ,con2.obj_name_orig strahovatel
      ,pol.policy_id
      ,veh.as_asset_id asset_id
      ,pol.pol_header_id
      ,pol.version_num
      ,con2.t_contact_status_id strahovatel_status_id
      ,ent.obj_name('T_CONTACT_STATUS', con2.t_contact_status_id) strahovatel_status
      ,pol.ins_amount amount
      ,pol.premium
      ,f.brief fund
      ,f.fund_id
      ,p.brief product_brief
      ,p.product_id
      ,vaa.card_num
      ,pol.notice_num
      ,pol.start_date
      ,pol.end_date
      ,veh.ins_premium
      ,dsr.brief AS status_brief
      ,dsr.name AS status_name
      ,vaa.credit_account_number
  FROM ven_p_policy       pol
      ,p_pol_header       ph
      ,p_policy_contact   pol_c
      ,as_asset           veh
      ,contact            con1
      ,contact            con2
      ,fund               f
      ,t_product          p
      ,as_assured         vaa
      ,contact            cas
      ,t_contact_pol_role cpr
      ,doc_status_ref     dsr
 WHERE ph.policy_header_id = pol.pol_header_id
   AND veh.p_policy_id = pol.policy_id
   AND pol.policy_id = pol_c.policy_id
   AND pol_c.contact_policy_role_id = cpr.id
   AND cpr.description = 'Страхователь'
   AND veh.contact_id = con1.contact_id
   AND pol_c.contact_id = con2.contact_id
   AND ph.fund_id = f.fund_id
   AND p.product_id = ph.product_id
   AND veh.as_asset_id = vaa.as_assured_id
   AND cas.contact_id = vaa.assured_contact_id
   AND dsr.doc_status_ref_id = pol.doc_status_ref_id;

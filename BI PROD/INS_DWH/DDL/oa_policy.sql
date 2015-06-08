create or replace force view ins_dwh.oa_policy
(policy_header_id, policy_id, as_asset_id, pol_ser, pol_num, start_date, end_date, change_date, decline_date, prev_pol_ser, prev_pol_num, vin, license_plate, is_driver_no_lim, t_vehicle_type_id, power_hp, model_year, t_vehicle_mark_id, t_vehicle_usage_id, max_weight, passangers, is_foreing_reg, ins_premium, is_national_mark, p1_start_date, p1_end_date, p2_start_date, p2_end_date, str_contact_id, sob_contact_id, coef_kbm, coef_area, sob_kladr, sob_index, nach_prem)
as
select ph.policy_header_id,     
       pp.POLICY_ID,
       ass.as_asset_id,
       pp.POL_SER,
       pp.POL_NUM,
       ph.START_DATE,
       pp.end_date,
       decode(pp.version_num,1,null,pp.start_date),
       pp.decline_date, --9
       pp_prev.POL_SER PREV_POL_SER,
       pp_prev.POL_NUM PREV_POL_NUM,
       av.VIN,
       av.LICENSE_PLATE,
       av.IS_DRIVER_NO_LIM,
       av.T_VEHICLE_TYPE_ID,
       av.POWER_HP,
       av.MODEL_YEAR,
       av.T_VEHICLE_MARK_ID,
       av.T_VEHICLE_USAGE_ID, --19
       av.MAX_WEIGHT,
       av.PASSANGERS,
       av.IS_FOREING_REG,
       ass.INS_PREMIUM,
       vm.IS_NATIONAL_MARK,
       (select min(ap.start_date) from ins.ven_as_asset_per ap where ap.as_asset_id = ass.as_asset_id) p1_start_date,
       (select min(ap.end_date) from ins.ven_as_asset_per ap where ap.as_asset_id = ass.as_asset_id) p1_end_date,
       (select decode(count(*),2,max(ap.start_date),null) from ins.ven_as_asset_per ap where ap.as_asset_id = ass.as_asset_id) p2_start_date,
       (select decode(count(*),2,max(ap.end_date),null) from ins.ven_as_asset_per ap where ap.as_asset_id = ass.as_asset_id) p2_end_date,  
       --страхователь
       pc.contact_id str_contact_id, --29
       --собственник
       ass.contact_id sob_contact_id, --30
       kbm.val, --31
       area.val,--32
       ins.pkg_contact.get_kladr(ca.id), --33
       ins.pkg_contact.get_index(ca.id), --34
       ins.pkg_payment.get_calc_amount_policy(pp.policy_id) --35
     from ins.ven_p_pol_header ph
     join t_product tp on (tp.product_id = ph.product_id and tp.brief='ОСАГО')
     join ins.ven_p_policy pp on (pp.pol_header_id = ph.policy_header_id)
left join ins.ven_p_policy pp_prev on pp_prev.pol_header_id = pp.pol_header_id and pp_prev.version_num = pp.version_num-1  
     join ins.ven_as_vehicle av on av.p_policy_id = pp.policy_id
     join t_vehicle_mark vm on vm.t_vehicle_mark_id=av.t_vehicle_mark_id
     join ins.ven_cn_contact_address cca on cca.id = av.cn_contact_address_id
     join ins.ven_cn_address ca on ca.id = cca.adress_id
     join ins.ven_as_asset ass on  ( ass.p_policy_id = pp.policy_id and ass.as_asset_id = av.as_vehicle_id )
     --страхователь
     join ins.ven_p_policy_contact pc on (pc.policy_id=pp.policy_id )
     join t_contact_pol_role tpr on (pc.contact_policy_role_id=tpr.id and tpr.brief='Страхователь')
     join ins.ven_p_cover cov on cov.as_asset_id = av.as_vehicle_id
     join (select pcc.p_cover_id,pcc.val
           from ins.ven_p_cover_coef pcc
            join ins.ven_t_prod_coef_type pct on pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
           where pct.brief = 'OSAGO_KBM') kbm on kbm.p_cover_id = cov.p_cover_id
     join (select pcc.p_cover_id,pcc.val
           from ins.ven_p_cover_coef pcc
            join ins.ven_t_prod_coef_type pct on pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
           where pct.brief = 'OSAGO_AREA')area on area.p_cover_id = cov.p_cover_id
;


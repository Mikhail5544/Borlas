CREATE OR REPLACE FUNCTION fn_obj_name
(
  p_ent_id   IN NUMBER
 ,p_obj_id   IN NUMBER
 ,p_obj_date IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2 IS
  v_result VARCHAR2(4000);
  v_ent_id NUMBER;
BEGIN
  SELECT e.ent_id INTO v_ent_id FROM ins.entity e WHERE e.source = 'T_SIGNER';
  IF p_ent_id = 1
  THEN
    SELECT NAME INTO v_result FROM analytic_type WHERE analytic_type_id = p_obj_id;
  ELSIF p_ent_id = 2
  THEN
    SELECT NAME INTO v_result FROM app_param WHERE app_param_id = p_obj_id;
  ELSIF p_ent_id = 21
  THEN
    SELECT NAME INTO v_result FROM fund WHERE fund_id = p_obj_id;
  ELSIF p_ent_id = 22
  THEN
    SELECT NAME || decode(first_name, NULL, '', ' ' || first_name) ||
           decode(middle_name, NULL, '', ' ' || middle_name)
      INTO v_result
      FROM contact
     WHERE contact_id = p_obj_id;
  ELSIF p_ent_id = 23
  THEN
    SELECT NAME INTO v_result FROM rate_type WHERE rate_type_id = p_obj_id;
  ELSIF p_ent_id = 25
  THEN
    SELECT NAME INTO v_result FROM doc_status_ref WHERE doc_status_ref_id = p_obj_id;
  ELSIF p_ent_id = 26
  THEN
    SELECT NAME INTO v_result FROM acc_chart_type WHERE acc_chart_type_id = p_obj_id;
  ELSIF p_ent_id = 27
  THEN
    SELECT NAME INTO v_result FROM acc_def_rule WHERE acc_def_rule_id = p_obj_id;
  ELSIF p_ent_id = 28
  THEN
    SELECT NAME INTO v_result FROM acc_role WHERE acc_role_id = p_obj_id;
  ELSIF p_ent_id = 29
  THEN
    SELECT NAME INTO v_result FROM acc_status WHERE acc_status_id = p_obj_id;
  ELSIF p_ent_id = 30
  THEN
    SELECT NAME INTO v_result FROM account WHERE account_id = p_obj_id;
  ELSIF p_ent_id = 31
  THEN
    SELECT NAME INTO v_result FROM acc_type_templ WHERE acc_type_templ_id = p_obj_id;
  ELSIF p_ent_id = 32
  THEN
    SELECT NAME INTO v_result FROM date_type WHERE date_type_id = p_obj_id;
  ELSIF p_ent_id = 33
  THEN
    SELECT NAME INTO v_result FROM export_type WHERE export_type_id = p_obj_id;
  ELSIF p_ent_id = 34
  THEN
    SELECT NAME INTO v_result FROM fund_type WHERE fund_type_id = p_obj_id;
  ELSIF p_ent_id = 35
  THEN
    SELECT NAME INTO v_result FROM summ_type WHERE summ_type_id = p_obj_id;
  ELSIF p_ent_id = 36
  THEN
    SELECT NAME INTO v_result FROM trans_templ WHERE trans_templ_id = p_obj_id;
  ELSIF p_ent_id = 37
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 38
  THEN
    SELECT NAME INTO v_result FROM doc_folder WHERE doc_folder_id = p_obj_id;
  ELSIF p_ent_id = 39
  THEN
    SELECT NAME INTO v_result FROM doc_templ WHERE doc_templ_id = p_obj_id;
  ELSIF p_ent_id = 40
  THEN
    SELECT NAME INTO v_result FROM oper_templ WHERE oper_templ_id = p_obj_id;
  ELSIF p_ent_id = 41
  THEN
    SELECT NAME INTO v_result FROM oper WHERE oper_id = p_obj_id;
  ELSIF p_ent_id = 43
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_id = 44
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_id = 45
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_id = 51
  THEN
    SELECT NAME INTO v_result FROM rep_type WHERE rep_type_id = p_obj_id;
    -- Ошибка в сущности №52
  ELSIF p_ent_id = 60
  THEN
    SELECT NAME INTO v_result FROM settlement_scheme WHERE settlement_scheme_id = p_obj_id;
  ELSIF p_ent_id = 63
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 66
  THEN
    SELECT NAME INTO v_result FROM rel_acc_type WHERE rel_acc_type_id = p_obj_id;
  ELSIF p_ent_id = 81
  THEN
    SELECT doc_doc_id INTO v_result FROM doc_doc WHERE doc_doc_id = p_obj_id;
  ELSIF p_ent_id = 182
  THEN
    SELECT description INTO v_result FROM ins.t_country WHERE id = p_obj_id;
  ELSIF p_ent_id = 183
  THEN
    SELECT description INTO v_result FROM ins.t_contact_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 201
  THEN
    SELECT description INTO v_result FROM ins.t_street_type WHERE street_type_id = p_obj_id;
  ELSIF p_ent_id = 202
  THEN
    SELECT description INTO v_result FROM ins.t_city_type WHERE city_type_id = p_obj_id;
  ELSIF p_ent_id = 203
  THEN
    SELECT description INTO v_result FROM ins.t_district_type WHERE district_type_id = p_obj_id;
  ELSIF p_ent_id = 204
  THEN
    SELECT description INTO v_result FROM ins.t_province_type WHERE province_type_id = p_obj_id;
  ELSIF p_ent_id = 205
  THEN
    SELECT province_name INTO v_result FROM t_province WHERE province_id = p_obj_id;
  ELSIF p_ent_id = 206
  THEN
    SELECT description INTO v_result FROM ins.t_region_type WHERE region_type_id = p_obj_id;
  ELSIF p_ent_id = 208
  THEN
    SELECT description INTO v_result FROM ins.t_phone_prefix_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 213
  THEN
    SELECT pkg_contact.get_address_name(zip
                                       ,country_name
                                       ,region_name
                                       ,NULL
                                       ,province_name
                                       ,province_type
                                       ,district_type
                                       ,district_name
                                       ,city_type
                                       ,city_name
                                       ,street_name
                                       ,street_type
                                       ,building_name
                                       ,house_nr
                                       ,block_number
                                       ,box_number
                                       ,appartment_nr
                                       ,house_type)
      INTO v_result
      FROM v_cn_address vca
     WHERE vca.id = p_obj_id;
  ELSIF p_ent_id = 214
  THEN
    SELECT description INTO v_result FROM ins.t_address_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 215
  THEN
    SELECT pkg_contact.get_address_name(cca.adress_id)
      INTO v_result
      FROM cn_contact_address cca
     WHERE cca.id = p_obj_id;
  ELSIF p_ent_id = 222
  THEN
    SELECT description INTO v_result FROM ins.t_telephone_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 223
  THEN
    SELECT description INTO v_result FROM ins.t_country_dial_code WHERE id = p_obj_id;
  ELSIF p_ent_id = 224
  THEN
    SELECT description INTO v_result FROM ins.t_email_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 226
  THEN
    SELECT description INTO v_result FROM ins.t_id_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 228
  THEN
    SELECT description INTO v_result FROM ins.t_contact_role WHERE id = p_obj_id;
  ELSIF p_ent_id = 232
  THEN
    SELECT cba.account_nr || ' в ' || cba.bank_name || ', ' || ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM cn_contact_bank_acc cba
          ,contact             c
     WHERE cba.contact_id = c.contact_id
       AND cba.id = p_obj_id;
  ELSIF p_ent_id = 241
  THEN
    SELECT description INTO v_result FROM ins.t_gender WHERE id = p_obj_id;
  ELSIF p_ent_id = 242
  THEN
    SELECT description INTO v_result FROM ins.t_family_status WHERE id = p_obj_id;
  ELSIF p_ent_id = 243
  THEN
    SELECT description INTO v_result FROM ins.t_profession WHERE id = p_obj_id;
  ELSIF p_ent_id = 244
  THEN
    SELECT description INTO v_result FROM ins.t_education WHERE id = p_obj_id;
  ELSIF p_ent_id = 245
  THEN
    SELECT description INTO v_result FROM ins.t_title WHERE id = p_obj_id;
  ELSIF p_ent_id = 246
  THEN
    SELECT c.name || ' ' || c.first_name || ' ' || c.middle_name
      INTO v_result
      FROM contact c
     WHERE c.contact_id = p_obj_id;
  ELSIF p_ent_id = 247
  THEN
    SELECT NAME || decode(first_name, NULL, '', ' ' || first_name) ||
           decode(middle_name, NULL, '', ' ' || middle_name)
      INTO v_result
      FROM contact
     WHERE contact_id = p_obj_id;
  ELSIF p_ent_id = 261
  THEN
    SELECT NAME INTO v_result FROM ins.status_hist WHERE status_hist_id = p_obj_id;
  ELSIF p_ent_id = 282
  THEN
    SELECT 'ДС №' || ph.num || ' от ' || to_char(ph.start_date, 'dd.mm.yyyy')
      INTO v_result
      FROM ven_p_pol_header ph
     WHERE ph.policy_header_id = p_obj_id;
  ELSIF p_ent_id = 283
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 284
  THEN
    SELECT description INTO v_result FROM ins.t_product WHERE product_id = p_obj_id;
  ELSIF p_ent_id = 285
  THEN
    SELECT description INTO v_result FROM ins.t_company_tree WHERE id = p_obj_id;
  ELSIF p_ent_id = 286
  THEN
    SELECT description INTO v_result FROM ins.t_sales_channel WHERE id = p_obj_id;
  ELSIF p_ent_id = 287
  THEN
    SELECT description INTO v_result FROM ins.t_contact_pol_role WHERE id = p_obj_id;
  ELSIF p_ent_id = 289
  THEN
    SELECT description INTO v_result FROM ins.t_collection_method WHERE id = p_obj_id;
  ELSIF p_ent_id = 290
  THEN
    SELECT description INTO v_result FROM t_payment_terms WHERE id = p_obj_id;
  ELSIF p_ent_id = 301
  THEN
    SELECT NAME INTO v_result FROM as_asset WHERE as_asset_id = p_obj_id;
  ELSIF p_ent_id = 302
  THEN
    SELECT MAX(ent.obj_name(a.ent_id, a.as_asset_id))
      INTO v_result
      FROM as_asset a
     WHERE a.p_asset_header_id = p_obj_id;
  ELSIF p_ent_id = 303
  THEN
    SELECT NAME INTO v_result FROM ins.t_asset_type WHERE t_asset_type_id = p_obj_id;
  ELSIF p_ent_id = 305
  THEN
    SELECT ent.obj_name(a.ent_id, a.as_asset_id) || '-' || plo.description || ', №' || d.num
      INTO v_result
      FROM p_cover            pc
          ,as_asset           a
          ,t_prod_line_option plo
          ,document           d
     WHERE pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND d.document_id = a.p_policy_id
       AND pc.p_cover_id = p_obj_id;
  ELSIF p_ent_id = 306
  THEN
    SELECT description INTO v_result FROM t_deductible_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 309
  THEN
    SELECT description INTO v_result FROM t_deduct_val_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 310
  THEN
    SELECT description INTO v_result FROM ins.t_prod_line_option WHERE id = p_obj_id;
  ELSIF p_ent_id = 321
  THEN
    SELECT description INTO v_result FROM ins.t_product_line WHERE id = p_obj_id;
  ELSIF p_ent_id = 341
  THEN
    SELECT description INTO v_result FROM ins.t_confirm_condition WHERE id = p_obj_id;
  ELSIF p_ent_id = 343
  THEN
    SELECT description INTO v_result FROM ins.t_period_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 344
  THEN
    SELECT description INTO v_result FROM ins.t_period WHERE id = p_obj_id;
  ELSIF p_ent_id = 401
  THEN
    SELECT description INTO v_result FROM t_insurance_group WHERE t_insurance_group_id = p_obj_id;
  ELSIF p_ent_id = 403
  THEN
    SELECT NAME INTO v_result FROM ins.type_oper WHERE type_oper_id = p_obj_id;
  ELSIF p_ent_id = 421
  THEN
    SELECT description INTO v_result FROM ins.t_department WHERE id = p_obj_id;
  ELSIF p_ent_id = 424
  THEN
    SELECT tvm.name || ' ' || tmm.name || ' ' || av.license_plate || ' ' || av.vin || ' ' || av.pts_s || '-' ||
           av.pts_n
      INTO v_result
      FROM as_vehicle av
      LEFT JOIN t_vehicle_mark tvm
        ON tvm.t_vehicle_mark_id = av.t_vehicle_mark_id
      LEFT JOIN t_main_model tmm
        ON tmm.t_main_model_id = av.t_main_model_id
     WHERE av.as_vehicle_id = p_obj_id;
  ELSIF p_ent_id = 426
  THEN
    SELECT ach.num || ' от ' || to_char(ach.date_begin, 'dd.mm.yyyy') || ', ' || c.name
      INTO v_result
      FROM ven_ag_contract_header ach
          ,contact                c
     WHERE ach.ag_contract_header_id = p_obj_id
       AND ach.agent_id = c.contact_id;
    -- Ошибка в сущности №427
  ELSIF p_ent_id = 429
  THEN
    SELECT NAME INTO v_result FROM ins.ag_type_rate_value WHERE ag_type_rate_value_id = p_obj_id;
  ELSIF p_ent_id = 430
  THEN
    SELECT NAME INTO v_result FROM ins.ag_type_defin_rate WHERE ag_type_defin_rate_id = p_obj_id;
  ELSIF p_ent_id = 432
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_person_med apm
          ,contact       c
     WHERE apm.as_person_med_id = p_obj_id
       AND c.contact_id = apm.cn_person_id;
  ELSIF p_ent_id = 433
  THEN
    SELECT NAME INTO v_result FROM ins.as_prog_med WHERE as_prog_med_id = p_obj_id;
  ELSIF p_ent_id = 434
  THEN
    SELECT NAME INTO v_result FROM ins.t_prog_med_group WHERE t_prog_med_group_id = p_obj_id;
    -- Ошибка в сущности №444
  ELSIF p_ent_id = 445
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 447
  THEN
    SELECT NAME INTO v_result FROM t_vehicle_type t WHERE t_vehicle_type_id = p_obj_id;
  ELSIF p_ent_id = 448
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_mark WHERE t_vehicle_mark_id = p_obj_id;
  ELSIF p_ent_id = 449
  THEN
    SELECT NAME INTO v_result FROM ins.t_fuel_type WHERE t_fuel_type_id = p_obj_id;
  ELSIF p_ent_id = 450
  THEN
    SELECT NAME INTO v_result FROM ins.t_model WHERE t_model_id = p_obj_id;
  ELSIF p_ent_id = 461
  THEN
    SELECT ext_id || ' ' || description INTO v_result FROM ins.t_peril WHERE id = p_obj_id;
  ELSIF p_ent_id = 462
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_usage WHERE t_vehicle_usage_id = p_obj_id;
  ELSIF p_ent_id = 502
  THEN
    SELECT NAME INTO v_result FROM ins.t_main_model WHERE t_main_model_id = p_obj_id;
  ELSIF p_ent_id = 522
  THEN
    SELECT num || nvl2(to_char(reg_date), ' ' || to_char(reg_date), '')
      INTO v_result
      FROM document d
     WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 561
  THEN
    SELECT description INTO v_result FROM ins.t_damage_code WHERE id = p_obj_id;
  ELSIF p_ent_id = 563
  THEN
    SELECT service_name INTO v_result FROM c_service_med WHERE c_service_med_id = p_obj_id;
  ELSIF p_ent_id = 566
  THEN
    SELECT description INTO v_result FROM ins.t_premium_type WHERE t_premium_type_id = p_obj_id;
  ELSIF p_ent_id = 581
  THEN
    SELECT NAME INTO v_result FROM ins.as_prog_med_limit WHERE as_prog_med_limit_id = p_obj_id;
  ELSIF p_ent_id = 582
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_product_line_type
     WHERE product_line_type_id = p_obj_id;
  ELSIF p_ent_id = 641
  THEN
    SELECT NAME INTO v_result FROM ins.t_prod_coef_type WHERE t_prod_coef_type_id = p_obj_id;
  ELSIF p_ent_id = 661
  THEN
    SELECT CASE
             WHEN pct.brief = 'CASCO_DAMAGE_BASE_TARRIFS'
                  AND pcc.is_damage = 1 THEN
              pct.name || ' - Хищение'
             WHEN pct.brief = 'CASCO_DAMAGE_BASE_TARRIFS'
                  AND pcc.is_damage = 0 THEN
              pct.name || ' - Ущерб'
             ELSE
              pct.name
           END o_n
      INTO v_result
      FROM p_cover_coef pcc
      JOIN t_prod_coef_type pct
        ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
     WHERE pcc.p_cover_coef_id = p_obj_id;
  ELSIF p_ent_id = 721
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 723
  THEN
    SELECT description INTO v_result FROM ins.t_rec_info_type WHERE rec_info_type_id = p_obj_id;
  ELSIF p_ent_id = 724
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_event_contact_role
     WHERE c_event_contact_role_id = p_obj_id;
  ELSIF p_ent_id = 729
  THEN
    SELECT cover_agent_id INTO v_result FROM p_cover_agent WHERE cover_agent_id = p_obj_id;
  ELSIF p_ent_id = 733
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_event_place_type
     WHERE c_event_place_type_id = p_obj_id;
  ELSIF p_ent_id = 736
  THEN
    SELECT description INTO v_result FROM ins.c_declarant_role WHERE c_declarant_role_id = p_obj_id;
  ELSIF p_ent_id = 737
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 738
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 739
  THEN
    SELECT description INTO v_result FROM ins.c_claim_status WHERE c_claim_status_id = p_obj_id;
  ELSIF p_ent_id = 741
  THEN
    SELECT description INTO v_result FROM ins.c_damage_type WHERE c_damage_type_id = p_obj_id;
  ELSIF p_ent_id = 742
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_damage_cost_type
     WHERE c_damage_cost_type_id = p_obj_id;
  ELSIF p_ent_id = 743
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_damage_exgr_type
     WHERE c_damage_exgr_type_id = p_obj_id;
  ELSIF p_ent_id = 744
  THEN
    SELECT description INTO v_result FROM ins.c_damage_status WHERE c_damage_status_id = p_obj_id;
  ELSIF p_ent_id = 745
  THEN
    SELECT description INTO v_result FROM ins.c_decline_reason WHERE c_decline_reason_id = p_obj_id;
  ELSIF p_ent_id = 746
  THEN
    SELECT description INTO v_result FROM ins.c_doc_basis_type WHERE c_doc_basis_type_id = p_obj_id;
  ELSIF p_ent_id = 747
  THEN
    SELECT NAME INTO v_result FROM ins.c_claim_doc_basis WHERE c_claim_doc_basis_id = p_obj_id;
  ELSIF p_ent_id = 748
  THEN
    SELECT c.description || ', ' || t.description
      INTO v_result
      FROM c_damage      d
          ,t_damage_code c
          ,c_damage_type t
     WHERE d.c_damage_id = p_obj_id
       AND d.t_damage_code_id = c.id
       AND d.c_damage_type_id = t.c_damage_type_id;
  ELSIF p_ent_id = 751
  THEN
    SELECT description INTO v_result FROM ins.t_catastrophe_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 761
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 781
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 801
  THEN
    SELECT agent_report_cont_id
      INTO v_result
      FROM agent_report_cont
     WHERE agent_report_cont_id = p_obj_id;
  ELSIF p_ent_id = 830
  THEN
    SELECT description INTO v_result FROM ins.t_ins_time WHERE t_ins_time_id = p_obj_id;
  ELSIF p_ent_id = 831
  THEN
    SELECT description INTO v_result FROM ins.t_work_group WHERE t_work_group_id = p_obj_id;
  ELSIF p_ent_id = 832
  THEN
    SELECT description INTO v_result FROM ins.t_rent_period WHERE t_rent_period_id = p_obj_id;
  ELSIF p_ent_id = 833
  THEN
    SELECT description INTO v_result FROM ins.t_color WHERE id = p_obj_id;
  ELSIF p_ent_id = 834
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_asset_assured aa
          ,contact          c
     WHERE aa.as_asset_assured_id = p_obj_id
       AND c.contact_id = aa.cn_assured_id;
  ELSIF p_ent_id = 835
  THEN
    SELECT description INTO v_result FROM ins.t_wall_material WHERE t_wall_material_id = p_obj_id;
  ELSIF p_ent_id = 836
  THEN
    SELECT description INTO v_result FROM ins.t_roof_material WHERE t_roof_material_id = p_obj_id;
  ELSIF p_ent_id = 837
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_basement_type_ross
     WHERE t_basement_type_ross_id = p_obj_id;
  ELSIF p_ent_id = 839
  THEN
    SELECT description INTO v_result FROM ins.t_locked_parking WHERE id = p_obj_id;
  ELSIF p_ent_id = 840
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_front_decorating
     WHERE t_front_decorating_id = p_obj_id;
  ELSIF p_ent_id = 841
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_front_decor_type
     WHERE t_front_decor_type_id = p_obj_id;
  ELSIF p_ent_id = 842
  THEN
    SELECT description INTO v_result FROM ins.t_lodger_type WHERE t_lodger_type_id = p_obj_id;
  ELSIF p_ent_id = 844
  THEN
    SELECT description INTO v_result FROM ins.t_heating_type WHERE t_heating_type_id = p_obj_id;
  ELSIF p_ent_id = 845
  THEN
    SELECT description INTO v_result FROM ven_t_casco_comp_type WHERE id = p_obj_id;
  ELSIF p_ent_id = 846
  THEN
    SELECT description INTO v_result FROM ins.t_path_type WHERE t_path_type_id = p_obj_id;
  ELSIF p_ent_id = 848
  THEN
    SELECT description INTO v_result FROM t_age_limits WHERE id = p_obj_id;
  ELSIF p_ent_id = 849
  THEN
    SELECT description INTO v_result FROM t_driver_experience WHERE id = p_obj_id;
  ELSIF p_ent_id = 861
  THEN
    SELECT description INTO v_result FROM ins.t_vehicle_mort_types WHERE id = p_obj_id;
  ELSIF p_ent_id = 862
  THEN
    SELECT NAME INTO v_result FROM ins.t_casco_doc_type WHERE t_casco_doc_type_id = p_obj_id;
  ELSIF p_ent_id = 863
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_neibour_building
     WHERE t_neibour_building_id = p_obj_id;
  ELSIF p_ent_id = 864
  THEN
    SELECT ent.obj_name(a.ent_id, a.as_asset_id) || '-' || plo.description || ', №' || d.num
      INTO v_result
      FROM p_cover            pc
          ,as_asset           a
          ,t_prod_line_option plo
          ,document           d
     WHERE pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND d.document_id = a.p_policy_id
       AND pc.p_cover_id = p_obj_id;
  ELSIF p_ent_id = 865
  THEN
    SELECT description INTO v_result FROM ins.t_territory WHERE t_territory_id = p_obj_id;
  ELSIF p_ent_id = 867
  THEN
    SELECT description INTO v_result FROM ins.t_territory_type WHERE t_territory_type_id = p_obj_id;
  ELSIF p_ent_id = 881
  THEN
    SELECT ent.obj_name(a.ent_id, a.as_asset_id) || '-' || plo.description || ', №' || d.num
      INTO v_result
      FROM p_cover            pc
          ,as_asset           a
          ,t_prod_line_option plo
          ,document           d
     WHERE pc.as_asset_id = a.as_asset_id
       AND pc.t_prod_line_option_id = plo.id
       AND d.document_id = a.p_policy_id
       AND pc.p_cover_id = p_obj_id;
  ELSIF p_ent_id = 908
  THEN
    SELECT decode(tat.edit_form_name
                 ,'AS_PROPERTY_SIMPLE'
                 ,a.name
                 ,'AS_PROPERTY'
                 ,a.name
                 ,tat.name || ' ' || ent.obj_name(ent.id_by_brief('CN_ADDRESS'), p.cn_address_id))
      INTO v_result
      FROM as_asset       a
          ,as_property    p
          ,p_asset_header ah
          ,t_asset_type   tat
     WHERE p.as_property_id = p_obj_id
       AND a.as_asset_id = p.as_property_id
       AND ah.p_asset_header_id = a.p_asset_header_id
       AND tat.t_asset_type_id = ah.t_asset_type_id;
  ELSIF p_ent_id = 921
  THEN
    SELECT NAME INTO v_result FROM ins.re_metod_reins WHERE re_metod_reins_id = p_obj_id;
  ELSIF p_ent_id = 925
  THEN
    SELECT decode(rc.p_cover_id
                 ,NULL
                 ,rc.ins_policy || '-' || rc.ins_asset
                 ,ent.obj_name(pc.ent_id, pc.p_cover_id))
      INTO v_result
      FROM re_cover rc
      LEFT JOIN ven_p_cover pc
        ON pc.p_cover_id = rc.p_cover_id
     WHERE rc.re_cover_id = p_obj_id;
  ELSIF p_ent_id = 927
  THEN
    SELECT num INTO v_result FROM re_slip_header WHERE re_slip_header_id = p_obj_id;
  ELSIF p_ent_id = 932
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 942
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 961
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 962
  THEN
    SELECT NAME INTO v_result FROM ins.re_bordero_type WHERE re_bordero_type_id = p_obj_id;
  ELSIF p_ent_id = 963
  THEN
    SELECT rbt.name || ' по пакету ' || rbp.num
      INTO v_result
      FROM re_bordero rb
      JOIN ven_re_bordero_package rbp
        ON rbp.re_bordero_package_id = rb.re_bordero_package_id
      JOIN ven_re_bordero_type rbt
        ON rbt.re_bordero_type_id = rb.re_bordero_type_id
     WHERE rb.re_bordero_id = p_obj_id;
  ELSIF p_ent_id = 965
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1021
  THEN
    SELECT NAME INTO v_result FROM ins.rep_report WHERE rep_report_id = p_obj_id;
  ELSIF p_ent_id = 1022
  THEN
    SELECT NAME INTO v_result FROM ins.rep_kind WHERE rep_kind_id = p_obj_id;
  ELSIF p_ent_id = 1041
  THEN
    SELECT NAME INTO v_result FROM ins.t_decline_reason WHERE t_decline_reason_id = p_obj_id;
  ELSIF p_ent_id = 1044
  THEN
    SELECT tdc.description
      INTO v_result
      FROM re_damage     rd
          ,t_damage_code tdc
     WHERE rd.t_damage_code_id = tdc.id
       AND rd.re_damage_id = p_obj_id;
  ELSIF p_ent_id = 1082
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1083
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1121
  THEN
    SELECT NAME INTO v_result FROM ins.lpu_account_metod WHERE lpu_account_metod_id = p_obj_id;
  ELSIF p_ent_id = 1182
  THEN
    SELECT NAME INTO v_result FROM ins.dms_decline_reason WHERE dms_decline_reason_id = p_obj_id;
  ELSIF p_ent_id = 1183
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1201
  THEN
    SELECT NAME INTO v_result FROM ins.bso_type WHERE bso_type_id = p_obj_id;
  ELSIF p_ent_id = 1204
  THEN
    SELECT NAME INTO v_result FROM ins.organisation_tree WHERE organisation_tree_id = p_obj_id;
  ELSIF p_ent_id = 1205
  THEN
    SELECT NAME INTO v_result FROM department WHERE department_id = p_obj_id;
  ELSIF p_ent_id = 1222
  THEN
    SELECT NAME INTO v_result FROM ins.bso_hist_type WHERE bso_hist_type_id = p_obj_id;
  ELSIF p_ent_id = 1224
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1281
  THEN
    SELECT NAME INTO v_result FROM ins.as_property_stuff WHERE as_property_stuff_id = p_obj_id;
  ELSIF p_ent_id = 1282
  THEN
    SELECT NAME INTO v_result FROM ins.t_measure_unit WHERE t_measure_unit_id = p_obj_id;
  ELSIF p_ent_id = 1283
  THEN
    SELECT NAME INTO v_result FROM ins.t_property_stuff_typ WHERE t_property_stuff_typ_id = p_obj_id;
  ELSIF p_ent_id = 1301
  THEN
    SELECT NAME INTO v_result FROM ins.as_vehicle_stuff WHERE as_vehicle_stuff_id = p_obj_id;
  ELSIF p_ent_id = 1322
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_type WHERE dms_lpu_type_id = p_obj_id;
  ELSIF p_ent_id = 1323
  THEN
    SELECT NAME INTO v_result FROM ins.dms_adv_type WHERE dms_adv_type_id = p_obj_id;
  ELSIF p_ent_id = 1324
  THEN
    SELECT NAME INTO v_result FROM ins.t_issuer_doc_type WHERE t_issuer_doc_type_id = p_obj_id;
  ELSIF p_ent_id = 1327
  THEN
    SELECT NAME INTO v_result FROM ins.dms_service_type WHERE dms_service_type_id = p_obj_id;
  ELSIF p_ent_id = 1341
  THEN
    SELECT NAME INTO v_result FROM ins.dms_consult_type WHERE dms_consult_type_id = p_obj_id;
  ELSIF p_ent_id = 1342
  THEN
    SELECT NAME INTO v_result FROM ins.dms_cons_stat_type WHERE dms_cons_stat_type_id = p_obj_id;
  ELSIF p_ent_id = 1343
  THEN
    SELECT NAME INTO v_result FROM ins.dms_hosp_type WHERE dms_hosp_type_id = p_obj_id;
  ELSIF p_ent_id = 1344
  THEN
    SELECT NAME INTO v_result FROM ins.dms_call_end_type WHERE dms_call_end_type_id = p_obj_id;
  ELSIF p_ent_id = 1345
  THEN
    SELECT NAME INTO v_result FROM ins.dms_req_type WHERE dms_req_type_id = p_obj_id;
  ELSIF p_ent_id = 1346
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_cat WHERE dms_lpu_cat_id = p_obj_id;
  ELSIF p_ent_id = 1347
  THEN
    SELECT NAME INTO v_result FROM ins.dms_serv_cat_type WHERE dms_serv_cat_type_id = p_obj_id;
  ELSIF p_ent_id = 1348
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_dep_type WHERE dms_lpu_dep_type_id = p_obj_id;
  ELSIF p_ent_id = 1349
  THEN
    SELECT NAME INTO v_result FROM ins.t_mark_at_device WHERE t_mark_at_device_id = p_obj_id;
  ELSIF p_ent_id = 1350
  THEN
    SELECT NAME INTO v_result FROM t_model_at_device WHERE t_model_at_device_id = p_obj_id;
  ELSIF p_ent_id = 1351
  THEN
    SELECT NAME INTO v_result FROM t_group_at_device WHERE t_group_at_device_id = p_obj_id;
  ELSIF p_ent_id = 1352
  THEN
    SELECT NAME INTO v_result FROM ins.dms_ins_rel_type WHERE dms_ins_rel_type_id = p_obj_id;
  ELSIF p_ent_id = 1353
  THEN
    SELECT ma.name || ' ' || mad.name
      INTO v_result
      FROM as_vehicle_at_device vad
      JOIN t_model_at_device mad
        ON vad.t_model_at_device_id = mad.t_model_at_device_id
      JOIN t_mark_at_device ma
        ON ma.t_mark_at_device_id = mad.t_mark_at_device_id
     WHERE vad.as_vehicle_at_device_id = p_obj_id;
  ELSIF p_ent_id = 1354
  THEN
    SELECT NAME INTO v_result FROM ins.dms_doctor_spec WHERE dms_doctor_spec_id = p_obj_id;
  ELSIF p_ent_id = 1355
  THEN
    SELECT NAME INTO v_result FROM ins.dms_gar_let_type WHERE dms_gar_let_type_id = p_obj_id;
  ELSIF p_ent_id = 1356
  THEN
    SELECT NAME INTO v_result FROM t_at_device_type WHERE t_at_device_type_id = p_obj_id;
  ELSIF p_ent_id = 1357
  THEN
    SELECT NAME INTO v_result FROM ins.dms_kvp WHERE dms_kvp_id = p_obj_id;
  ELSIF p_ent_id = 1358
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_stuff_type WHERE t_vehicle_stuff_type_id = p_obj_id;
  ELSIF p_ent_id = 1359
  THEN
    SELECT NAME INTO v_result FROM ins.dms_mkb WHERE dms_mkb_id = p_obj_id;
  ELSIF p_ent_id = 1361
  THEN
    SELECT NAME INTO v_result FROM ins.t_casco_programm WHERE t_casco_programm_id = p_obj_id;
  ELSIF p_ent_id = 1362
  THEN
    SELECT NAME INTO v_result FROM ins.t_contact_status WHERE t_contact_status_id = p_obj_id;
  ELSIF p_ent_id = 1381
  THEN
    SELECT NAME INTO v_result FROM ins.t_dept_role WHERE t_dept_role_id = p_obj_id;
  ELSIF p_ent_id = 1401
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1402
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_acc_type WHERE dms_lpu_acc_type_id = p_obj_id;
  ELSIF p_ent_id = 1403
  THEN
    SELECT NAME INTO v_result FROM ins.dms_inv_pay_cond WHERE dms_inv_pay_cond_id = p_obj_id;
  ELSIF p_ent_id = 1404
  THEN
    SELECT NAME INTO v_result FROM ins.dms_inv_pay_ord WHERE dms_inv_pay_ord_id = p_obj_id;
  ELSIF p_ent_id = 1427
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1444
  THEN
    SELECT NAME INTO v_result FROM ins.dms_price WHERE dms_price_id = p_obj_id;
  ELSIF p_ent_id = 1445
  THEN
    SELECT NAME INTO v_result FROM ins.dms_aid_type WHERE dms_aid_type_id = p_obj_id;
  ELSIF p_ent_id = 1461
  THEN
    SELECT NAME INTO v_result FROM ins.dms_age_range WHERE dms_age_range_id = p_obj_id;
  ELSIF p_ent_id = 1462
  THEN
    SELECT NAME INTO v_result FROM ins.dms_health_group WHERE dms_health_group_id = p_obj_id;
  ELSIF p_ent_id = 1463
  THEN
    SELECT NAME INTO v_result FROM ins.dms_ins_var WHERE dms_ins_var_id = p_obj_id;
  ELSIF p_ent_id = 1481
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_victim_osago_type
     WHERE t_victim_osago_type_id = p_obj_id;
  ELSIF p_ent_id = 1502
  THEN
    SELECT NAME INTO v_result FROM ins.dms_set_off_rule WHERE dms_set_off_rule_id = p_obj_id;
  ELSIF p_ent_id = 1541
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1542
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1561
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 1583
  THEN
    SELECT rel_recover_bordero_id
      INTO v_result
      FROM rel_recover_bordero
     WHERE rel_recover_bordero_id = p_obj_id;
  ELSIF p_ent_id = 1602
  THEN
    SELECT rel_redamage_bordero_id
      INTO v_result
      FROM rel_redamage_bordero
     WHERE rel_redamage_bordero_id = p_obj_id;
  ELSIF p_ent_id = 1621
  THEN
    SELECT NAME INTO v_result FROM ins.dms_err_type WHERE dms_err_type_id = p_obj_id;
  ELSIF p_ent_id = 1663
  THEN
    SELECT NAME INTO v_result FROM ins.reminder WHERE reminder_id = p_obj_id;
  ELSIF p_ent_id = 1721
  THEN
    SELECT NAME INTO v_result FROM ins.as_dispatcher WHERE as_dispatcher_id = p_obj_id;
  ELSIF p_ent_id = 1722
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_id = 1723
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_id = 1724
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_id = 1725
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_id = 1726
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_id = 1741
  THEN
    SELECT NAME INTO v_result FROM ins.as_asset_ass_status WHERE as_asset_ass_status_id = p_obj_id;
  ELSIF p_ent_id = 1761
  THEN
    SELECT description INTO v_result FROM ins.t_lob WHERE t_lob_id = p_obj_id;
  ELSIF p_ent_id = 1781
  THEN
    SELECT NAME INTO v_result FROM ins.questionnaire_type WHERE questionnaire_type_id = p_obj_id;
  ELSIF p_ent_id = 1802
  THEN
    SELECT NAME INTO v_result FROM ins.sys_event_type WHERE sys_event_type_id = p_obj_id;
  ELSIF p_ent_id = 1861
  THEN
    SELECT description INTO v_result FROM ins.t_lob_line WHERE t_lob_line_id = p_obj_id;
  ELSIF p_ent_id = 1863
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_product_ver_status
     WHERE t_product_ver_status_id = p_obj_id;
  ELSIF p_ent_id = 1882
  THEN
    SELECT doc_doc_id INTO v_result FROM doc_doc WHERE doc_doc_id = p_obj_id;
  ELSIF p_ent_id = 1901
  THEN
    SELECT 'ДС №' || ph.num || ', ' || c.name
      INTO v_result
      FROM p_policy_agent     ppa
          ,ven_p_pol_header   ph
          ,ag_contract_header ach
          ,contact            c
     WHERE ppa.p_policy_agent_id = p_obj_id
       AND ppa.policy_header_id = ph.policy_header_id
       AND ppa.ag_contract_header_id = ach.ag_contract_header_id
       AND ach.agent_id = c.contact_id;
  ELSIF p_ent_id = 1902
  THEN
    SELECT NAME INTO v_result FROM ins.policy_agent_status WHERE policy_agent_status_id = p_obj_id;
  ELSIF p_ent_id = 1921
  THEN
    SELECT NAME INTO v_result FROM ins.t_prod_coef_tariff WHERE t_prod_coef_tariff_id = p_obj_id;
  ELSIF p_ent_id = 1941
  THEN
    SELECT NAME INTO v_result FROM t_sq_year WHERE t_sq_year_id = p_obj_id;
  ELSIF p_ent_id = 2101
  THEN
    SELECT 'ДС №' || ph.num || ', ' || c.name || ', ' || t_product_line.description
      INTO v_result
      FROM p_policy_agent_com ppac
          ,p_policy_agent     ppa
          ,ven_p_pol_header   ph
          ,ag_contract_header ach
          ,contact            c
          ,t_product_line
     WHERE ppac.p_policy_agent_com_id = p_obj_id
       AND ppac.p_policy_agent_id = ppa.p_policy_agent_id
       AND ppa.policy_header_id = ph.policy_header_id
       AND ppa.ag_contract_header_id = ach.ag_contract_header_id
       AND ach.agent_id = c.contact_id
       AND ppac.t_product_line_id = t_product_line.id;
  ELSIF p_ent_id = 2341
  THEN
    SELECT description INTO v_result FROM t_addendum_type WHERE t_addendum_type_id = p_obj_id;
  ELSIF p_ent_id = 2481
  THEN
    SELECT NAME INTO v_result FROM t_payment_order WHERE t_payment_order_id = p_obj_id;
  ELSIF p_ent_id = 2482
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_assured aa
          ,contact    c
     WHERE aa.as_assured_id = p_obj_id
       AND c.contact_id = aa.assured_contact_id;
  ELSIF p_ent_id = 2762
  THEN
    SELECT NAME INTO v_result FROM doc_procedure WHERE doc_procedure_id = p_obj_id;
  ELSIF p_ent_id = 2942
  THEN
    SELECT NAME INTO v_result FROM sales_action WHERE sales_action_id = p_obj_id;
  ELSIF p_ent_id = 2962
  THEN
    SELECT NAME INTO v_result FROM discount_f WHERE discount_f_id = p_obj_id;
  ELSIF p_ent_id = 3002
  THEN
    SELECT NAME INTO v_result FROM ins.t_policy_form_type WHERE t_policy_form_type_id = p_obj_id;
  ELSIF p_ent_id = 3122
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 3162
  THEN
    SELECT assured_medical_exam_id
      INTO v_result
      FROM assured_medical_exam
     WHERE assured_medical_exam_id = p_obj_id;
  ELSIF p_ent_id = 3184
  THEN
    SELECT description INTO v_result FROM ins.t_product_line WHERE id = p_obj_id;
  ELSIF p_ent_id = 3262
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 3282
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 3283
  THEN
    SELECT NAME INTO v_result FROM t_policy_change_type WHERE t_policy_change_type_id = p_obj_id;
  ELSIF p_ent_id = 3343
  THEN
    SELECT NAME INTO v_result FROM t_decline_party WHERE t_decline_party_id = p_obj_id;
  ELSIF p_ent_id = 3383
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 3483
  THEN
    SELECT agent_report_dav_ct_id
      INTO v_result
      FROM agent_report_dav_ct
     WHERE agent_report_dav_ct_id = p_obj_id;
  ELSIF p_ent_id = 3662
  THEN
    SELECT 'ДС №' || ph.num || ' от ' || to_char(ph.start_date, 'dd.mm.yyyy')
      INTO v_result
      FROM ven_p_pol_header ph
     WHERE ph.policy_header_id = p_obj_id;
  ELSIF p_ent_id = 3782
  THEN
    SELECT NAME INTO v_result FROM t_profitableness WHERE t_profitableness_id = p_obj_id;
  ELSIF p_ent_id = 3962
  THEN
    SELECT as_assured_docum_id
      INTO v_result
      FROM as_assured_docum
     WHERE as_assured_docum_id = p_obj_id;
  ELSIF p_ent_id = 4042
  THEN
    SELECT as_assured_form_id INTO v_result FROM as_assured_form WHERE as_assured_form_id = p_obj_id;
  ELSIF p_ent_id = 4082
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4145
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4242
  THEN
    SELECT tat.name || ' ' || ent.obj_name(ent.id_by_brief('T_BUS_ACT_TYPE'), p.t_bus_act_type_id)
      INTO v_result
      FROM as_asset       a
          ,as_activity    p
          ,p_asset_header ah
          ,t_asset_type   tat
     WHERE p.as_activity_id = p_obj_id
       AND a.as_asset_id = p.as_activity_id
       AND ah.p_asset_header_id = a.p_asset_header_id
       AND tat.t_asset_type_id = ah.t_asset_type_id;
  ELSIF p_ent_id = 4263
  THEN
    SELECT as_asset_form_id INTO v_result FROM as_asset_form WHERE as_asset_form_id = p_obj_id;
  ELSIF p_ent_id = 4423
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4432
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4433
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4434
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4462
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4463
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
    -- Ошибка в сущности №4564
  ELSIF p_ent_id = 4582
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 4762
  THEN
    SELECT d.document_id INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_id = 3422
  THEN
    SELECT d.name INTO v_result FROM t_ag_decline_reason d WHERE d.t_ag_decline_reason_id = p_obj_id;
  ELSIF p_ent_id = v_ent_id
  THEN
    SELECT nvl(r.contact_name
              ,(SELECT c.obj_name_orig FROM ins.contact c WHERE c.contact_id = r.contact_id))
      INTO v_result
      FROM ins.t_signer r
     WHERE r.t_signer_id = p_obj_id;
  END IF;
  RETURN(v_result);
END; 
/

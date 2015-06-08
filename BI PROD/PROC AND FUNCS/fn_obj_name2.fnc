CREATE OR REPLACE FUNCTION fn_obj_name2
(
  p_ent_brief IN VARCHAR2
 ,p_obj_id    IN NUMBER
 ,p_obj_date  IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2 IS
  v_result VARCHAR2(300);
BEGIN
  IF p_ent_brief = 'ANALYTIC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM analytic_type WHERE analytic_type_id = p_obj_id;
  ELSIF p_ent_brief = 'ANALYTIC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM analytic_type WHERE analytic_type_id = p_obj_id;
  ELSIF p_ent_brief = 'APP_PARAM'
  THEN
    SELECT NAME INTO v_result FROM app_param WHERE app_param_id = p_obj_id;
  ELSIF p_ent_brief = 'FUND'
  THEN
    SELECT NAME INTO v_result FROM fund WHERE fund_id = p_obj_id;
  ELSIF p_ent_brief = 'CONTACT'
  THEN
    SELECT NAME || decode(first_name, NULL, '', ' ' || first_name) ||
           decode(middle_name, NULL, '', ' ' || middle_name)
      INTO v_result
      FROM contact
     WHERE contact_id = p_obj_id;
  ELSIF p_ent_brief = 'CONTACT_IO'
  THEN
    SELECT decode(first_name, NULL, '', ' ' || first_name) ||
           decode(middle_name, NULL, '', ' ' || middle_name)
      INTO v_result
      FROM contact
     WHERE contact_id = p_obj_id;
  ELSIF p_ent_brief = 'RATE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM rate_type WHERE rate_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_STATUS_REF'
  THEN
    SELECT NAME INTO v_result FROM doc_status_ref WHERE doc_status_ref_id = p_obj_id;
  ELSIF p_ent_brief = 'ACC_CHART_TYPE'
  THEN
    SELECT NAME INTO v_result FROM acc_chart_type WHERE acc_chart_type_id = p_obj_id;
  ELSIF p_ent_brief = 'ACC_DEF_RULE'
  THEN
    SELECT NAME INTO v_result FROM acc_def_rule WHERE acc_def_rule_id = p_obj_id;
  ELSIF p_ent_brief = 'ACC_ROLE'
  THEN
    SELECT NAME INTO v_result FROM acc_role WHERE acc_role_id = p_obj_id;
  ELSIF p_ent_brief = 'ACC_STATUS'
  THEN
    SELECT NAME INTO v_result FROM acc_status WHERE acc_status_id = p_obj_id;
  ELSIF p_ent_brief = 'ACCOUNT'
  THEN
    SELECT NAME INTO v_result FROM account WHERE account_id = p_obj_id;
  ELSIF p_ent_brief = 'ACC_TYPE_TEMPL'
  THEN
    SELECT NAME INTO v_result FROM acc_type_templ WHERE acc_type_templ_id = p_obj_id;
  ELSIF p_ent_brief = 'DATE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM date_type WHERE date_type_id = p_obj_id;
  ELSIF p_ent_brief = 'EXPORT_TYPE'
  THEN
    SELECT NAME INTO v_result FROM export_type WHERE export_type_id = p_obj_id;
  ELSIF p_ent_brief = 'FUND_TYPE'
  THEN
    SELECT NAME INTO v_result FROM fund_type WHERE fund_type_id = p_obj_id;
  ELSIF p_ent_brief = 'SUMM_TYPE'
  THEN
    SELECT NAME INTO v_result FROM summ_type WHERE summ_type_id = p_obj_id;
  ELSIF p_ent_brief = 'TRANS_TEMPL'
  THEN
    SELECT NAME INTO v_result FROM trans_templ WHERE trans_templ_id = p_obj_id;
  ELSIF p_ent_brief = 'DOCUMENT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_FOLDER'
  THEN
    SELECT NAME INTO v_result FROM doc_folder WHERE doc_folder_id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_TEMPL'
  THEN
    SELECT NAME INTO v_result FROM doc_templ WHERE doc_templ_id = p_obj_id;
  ELSIF p_ent_brief = 'OPER_TEMPL'
  THEN
    SELECT NAME INTO v_result FROM oper_templ WHERE oper_templ_id = p_obj_id;
  ELSIF p_ent_brief = 'OPER'
  THEN
    SELECT NAME INTO v_result FROM oper WHERE oper_id = p_obj_id;
  ELSIF p_ent_brief = 'SYS_SAFETY'
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_brief = 'SYS_ROLE'
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_brief = 'SYS_USER'
  THEN
    SELECT NAME INTO v_result FROM sys_safety WHERE sys_safety_id = p_obj_id;
  ELSIF p_ent_brief = 'REP_TYPE'
  THEN
    SELECT NAME INTO v_result FROM rep_type WHERE rep_type_id = p_obj_id;
    -- Ошибка в сущности №52
  ELSIF p_ent_brief = 'SETTLEMENT_SCHEME'
  THEN
    SELECT NAME INTO v_result FROM settlement_scheme WHERE settlement_scheme_id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_MEM_ORDER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'REL_ACC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM rel_acc_type WHERE rel_acc_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_DOC'
  THEN
    SELECT doc_doc_id INTO v_result FROM doc_doc WHERE doc_doc_id = p_obj_id;
  ELSIF p_ent_brief = 'T_COUNTRY'
  THEN
    SELECT description INTO v_result FROM ins.t_country WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_CONTACT_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_contact_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_STREET_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_street_type WHERE street_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_CITY_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_city_type WHERE city_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DISTRICT_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_district_type WHERE district_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROVINCE_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_province_type WHERE province_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROVINCE'
  THEN
    SELECT province_name INTO v_result FROM t_province WHERE province_id = p_obj_id;
  ELSIF p_ent_brief = 'T_REGION_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_region_type WHERE region_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PHONE_PREFIX_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_phone_prefix_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'CN_ADDRESS'
  THEN
    SELECT pkg_contact.get_address_name(zip
                                       ,country_name
                                       ,region_name
                                       ,region_type
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
  ELSIF p_ent_brief = 'T_ADDRESS_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_address_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'CN_CONTACT_ADDRESS'
  THEN
    SELECT pkg_contact.get_address_name(cca.adress_id)
      INTO v_result
      FROM cn_contact_address cca
     WHERE cca.id = p_obj_id;
  ELSIF p_ent_brief = 'T_TELEPHONE_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_telephone_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_COUNTRY_DIAL_CODE'
  THEN
    SELECT description INTO v_result FROM ins.t_country_dial_code WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_EMAIL_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_email_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_ID_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_id_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_CONTACT_ROLE'
  THEN
    SELECT description INTO v_result FROM ins.t_contact_role WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'CN_CONTACT_BANK_ACC'
  THEN
    SELECT cba.account_nr || ' в ' || cba.bank_name || ', ' || ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM cn_contact_bank_acc cba
          ,contact             c
     WHERE cba.contact_id = c.contact_id
       AND cba.id = p_obj_id;
  ELSIF p_ent_brief = 'T_GENDER'
  THEN
    SELECT description INTO v_result FROM ins.t_gender WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_FAMILY_STATUS'
  THEN
    SELECT description INTO v_result FROM ins.t_family_status WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROFESSION'
  THEN
    SELECT description INTO v_result FROM ins.t_profession WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_EDUCATION'
  THEN
    SELECT description INTO v_result FROM ins.t_education WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_TITLE'
  THEN
    SELECT description INTO v_result FROM ins.t_title WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'CN_PERSON'
  THEN
    SELECT c.name || ' ' || c.first_name || ' ' || c.middle_name
      INTO v_result
      FROM contact c
     WHERE c.contact_id = p_obj_id;
  ELSIF p_ent_brief = 'CN_COMPANY'
  THEN
    SELECT NAME || decode(first_name, NULL, '', ' ' || first_name) ||
           decode(middle_name, NULL, '', ' ' || middle_name)
      INTO v_result
      FROM contact
     WHERE contact_id = p_obj_id;
  ELSIF p_ent_brief = 'STATUS_HIST'
  THEN
    SELECT NAME INTO v_result FROM ins.status_hist WHERE status_hist_id = p_obj_id;
  ELSIF p_ent_brief = 'P_POL_HEADER'
  THEN
    SELECT 'ДС №' || ph.num || ' от ' || to_char(ph.start_date, 'dd.mm.yyyy')
      INTO v_result
      FROM ven_p_pol_header ph
     WHERE ph.policy_header_id = p_obj_id;
  ELSIF p_ent_brief = 'P_POLICY'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PRODUCT'
  THEN
    SELECT description INTO v_result FROM ins.t_product WHERE product_id = p_obj_id;
  ELSIF p_ent_brief = 'T_COMPANY_TREE'
  THEN
    SELECT description INTO v_result FROM ins.t_company_tree WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_SALES_CHANNEL'
  THEN
    SELECT description INTO v_result FROM ins.t_sales_channel WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_CONTACT_POL_ROLE'
  THEN
    SELECT description INTO v_result FROM ins.t_contact_pol_role WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_COLLECTION_METHOD'
  THEN
    SELECT description INTO v_result FROM ins.t_collection_method WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PAYMENT_TERMS'
  THEN
    SELECT description INTO v_result FROM t_payment_terms WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSET'
  THEN
    SELECT NAME INTO v_result FROM as_asset WHERE as_asset_id = p_obj_id;
  ELSIF p_ent_brief = 'P_ASSET_HEADER'
  THEN
    SELECT MAX(ent.obj_name(a.ent_id, a.as_asset_id))
      INTO v_result
      FROM as_asset a
     WHERE a.p_asset_header_id = p_obj_id;
  ELSIF p_ent_brief = 'T_ASSET_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_asset_type WHERE t_asset_type_id = p_obj_id;
  ELSIF p_ent_brief = 'P_COVER'
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
  ELSIF p_ent_brief = 'T_DEDUCTIBLE_TYPE'
  THEN
    SELECT description INTO v_result FROM t_deductible_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_DEDUCT_VAL_TYPE'
  THEN
    SELECT description INTO v_result FROM t_deduct_val_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROD_LINE_OPTION'
  THEN
    SELECT description INTO v_result FROM ins.t_prod_line_option WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PRODUCT_LINE'
  THEN
    SELECT description INTO v_result FROM ins.t_product_line WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_CONFIRM_CONDITION'
  THEN
    SELECT description INTO v_result FROM ins.t_confirm_condition WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PERIOD_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_period_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PERIOD'
  THEN
    SELECT description INTO v_result FROM ins.t_period WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_INSURANCE_GROUP'
  THEN
    SELECT description INTO v_result FROM t_insurance_group WHERE t_insurance_group_id = p_obj_id;
  ELSIF p_ent_brief = 'TYPE_OPER'
  THEN
    SELECT NAME INTO v_result FROM ins.type_oper WHERE type_oper_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DEPARTMENT'
  THEN
    SELECT description INTO v_result FROM ins.t_department WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'AS_VEHICLE'
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
  ELSIF p_ent_brief = 'AG_CONTRACT_HEADER'
  THEN
    SELECT ach.num || ' от ' || to_char(ach.date_begin, 'dd.mm.yyyy') || ', ' || c.name
      INTO v_result
      FROM ven_ag_contract_header ach
          ,contact                c
     WHERE ach.ag_contract_header_id = p_obj_id
       AND ach.agent_id = c.contact_id;
    -- Ошибка в сущности №427
  ELSIF p_ent_brief = 'AG_TYPE_RATE_VALUE'
  THEN
    SELECT NAME INTO v_result FROM ins.ag_type_rate_value WHERE ag_type_rate_value_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_TYPE_DEFIN_RATE'
  THEN
    SELECT NAME INTO v_result FROM ins.ag_type_defin_rate WHERE ag_type_defin_rate_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_PERSON_MED'
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_person_med apm
          ,contact       c
     WHERE apm.as_person_med_id = p_obj_id
       AND c.contact_id = apm.cn_person_id;
  ELSIF p_ent_brief = 'AS_PROG_MED'
  THEN
    SELECT NAME INTO v_result FROM ins.as_prog_med WHERE as_prog_med_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROG_MED_GROUP'
  THEN
    SELECT NAME INTO v_result FROM ins.t_prog_med_group WHERE t_prog_med_group_id = p_obj_id;
    -- Ошибка в сущности №444
  ELSIF p_ent_brief = 'CONTRACT_LPU'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'T_VEHICLE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM t_vehicle_type t WHERE t_vehicle_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_VEHICLE_MARK'
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_mark WHERE t_vehicle_mark_id = p_obj_id;
  ELSIF p_ent_brief = 'T_FUEL_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_fuel_type WHERE t_fuel_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_MODEL'
  THEN
    SELECT NAME INTO v_result FROM ins.t_model WHERE t_model_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PERIL'
  THEN
    SELECT ext_id || ' ' || description INTO v_result FROM ins.t_peril WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_VEHICLE_USAGE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_usage WHERE t_vehicle_usage_id = p_obj_id;
  ELSIF p_ent_brief = 'T_MAIN_MODEL'
  THEN
    SELECT NAME INTO v_result FROM ins.t_main_model WHERE t_main_model_id = p_obj_id;
  ELSIF p_ent_brief = 'AC_PAYMENT'
  THEN
    SELECT num || nvl2(to_char(reg_date), ' ' || to_char(reg_date), '')
      INTO v_result
      FROM document d
     WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DAMAGE_CODE'
  THEN
    SELECT description INTO v_result FROM ins.t_damage_code WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'C_SERVICE_MED'
  THEN
    SELECT service_name INTO v_result FROM c_service_med WHERE c_service_med_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PREMIUM_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_premium_type WHERE t_premium_type_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_PROG_MED_LIMIT'
  THEN
    SELECT NAME INTO v_result FROM ins.as_prog_med_limit WHERE as_prog_med_limit_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PRODUCT_LINE_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_product_line_type
     WHERE product_line_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROD_COEF_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_prod_coef_type WHERE t_prod_coef_type_id = p_obj_id;
  ELSIF p_ent_brief = 'P_COVER_COEF'
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
  ELSIF p_ent_brief = 'C_EVENT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'T_REC_INFO_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_rec_info_type WHERE rec_info_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_EVENT_CONTACT_ROLE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_event_contact_role
     WHERE c_event_contact_role_id = p_obj_id;
  ELSIF p_ent_brief = 'P_COVER_AGENT'
  THEN
    SELECT cover_agent_id INTO v_result FROM p_cover_agent WHERE cover_agent_id = p_obj_id;
  ELSIF p_ent_brief = 'C_EVENT_PLACE_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_event_place_type
     WHERE c_event_place_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DECLARANT_ROLE'
  THEN
    SELECT description INTO v_result FROM ins.c_declarant_role WHERE c_declarant_role_id = p_obj_id;
  ELSIF p_ent_brief = 'C_CLAIM_HEADER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'C_CLAIM'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'C_CLAIM_STATUS'
  THEN
    SELECT description INTO v_result FROM ins.c_claim_status WHERE c_claim_status_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DAMAGE_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.c_damage_type WHERE c_damage_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DAMAGE_COST_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_damage_cost_type
     WHERE c_damage_cost_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DAMAGE_EXGR_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.c_damage_exgr_type
     WHERE c_damage_exgr_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DAMAGE_STATUS'
  THEN
    SELECT description INTO v_result FROM ins.c_damage_status WHERE c_damage_status_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DECLINE_REASON'
  THEN
    SELECT description INTO v_result FROM ins.c_decline_reason WHERE c_decline_reason_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DOC_BASIS_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.c_doc_basis_type WHERE c_doc_basis_type_id = p_obj_id;
  ELSIF p_ent_brief = 'C_CLAIM_DOC_BASIS'
  THEN
    SELECT NAME INTO v_result FROM ins.c_claim_doc_basis WHERE c_claim_doc_basis_id = p_obj_id;
  ELSIF p_ent_brief = 'C_DAMAGE'
  THEN
    SELECT c.description || ', ' || t.description
      INTO v_result
      FROM c_damage      d
          ,t_damage_code c
          ,c_damage_type t
     WHERE d.c_damage_id = p_obj_id
       AND d.t_damage_code_id = c.id
       AND d.c_damage_type_id = t.c_damage_type_id;
  ELSIF p_ent_brief = 'T_CATASTROPHE_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_catastrophe_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'DOC_SET_OFF'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AGENT_REPORT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AGENT_REPORT_CONT'
  THEN
    SELECT agent_report_cont_id
      INTO v_result
      FROM agent_report_cont
     WHERE agent_report_cont_id = p_obj_id;
  ELSIF p_ent_brief = 'T_INS_TIME'
  THEN
    SELECT description INTO v_result FROM ins.t_ins_time WHERE t_ins_time_id = p_obj_id;
  ELSIF p_ent_brief = 'T_WORK_GROUP'
  THEN
    SELECT description INTO v_result FROM ins.t_work_group WHERE t_work_group_id = p_obj_id;
  ELSIF p_ent_brief = 'T_RENT_PERIOD'
  THEN
    SELECT description INTO v_result FROM ins.t_rent_period WHERE t_rent_period_id = p_obj_id;
  ELSIF p_ent_brief = 'T_COLOR'
  THEN
    SELECT description INTO v_result FROM ins.t_color WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSET_ASSURED'
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_asset_assured aa
          ,contact          c
     WHERE aa.as_asset_assured_id = p_obj_id
       AND c.contact_id = aa.cn_assured_id;
  ELSIF p_ent_brief = 'T_WALL_MATERIAL'
  THEN
    SELECT description INTO v_result FROM ins.t_wall_material WHERE t_wall_material_id = p_obj_id;
  ELSIF p_ent_brief = 'T_ROOF_MATERIAL'
  THEN
    SELECT description INTO v_result FROM ins.t_roof_material WHERE t_roof_material_id = p_obj_id;
  ELSIF p_ent_brief = 'T_BASEMENT_TYPE_ROSS'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_basement_type_ross
     WHERE t_basement_type_ross_id = p_obj_id;
  ELSIF p_ent_brief = 'T_LOCKED_PARKING'
  THEN
    SELECT description INTO v_result FROM ins.t_locked_parking WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_FRONT_DECORATING'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_front_decorating
     WHERE t_front_decorating_id = p_obj_id;
  ELSIF p_ent_brief = 'T_FRONT_DECOR_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_front_decor_type
     WHERE t_front_decor_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_LODGER_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_lodger_type WHERE t_lodger_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_HEATING_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_heating_type WHERE t_heating_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_CASCO_COMP_TYPE'
  THEN
    SELECT description INTO v_result FROM ven_t_casco_comp_type WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_PATH_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_path_type WHERE t_path_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_AGE_LIMITS'
  THEN
    SELECT description INTO v_result FROM t_age_limits WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_DRIVER_EXPERIENCE'
  THEN
    SELECT description INTO v_result FROM t_driver_experience WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_VEHICLE_MORT_TYPES'
  THEN
    SELECT description INTO v_result FROM ins.t_vehicle_mort_types WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'T_CASCO_DOC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_casco_doc_type WHERE t_casco_doc_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_NEIBOUR_BUILDING'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_neibour_building
     WHERE t_neibour_building_id = p_obj_id;
  ELSIF p_ent_brief = 'P_COVER_ACCIDENT'
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
  ELSIF p_ent_brief = 'T_TERRITORY'
  THEN
    SELECT description INTO v_result FROM ins.t_territory WHERE t_territory_id = p_obj_id;
  ELSIF p_ent_brief = 'T_TERRITORY_TYPE'
  THEN
    SELECT description INTO v_result FROM ins.t_territory_type WHERE t_territory_type_id = p_obj_id;
  ELSIF p_ent_brief = 'P_COVER_LIFE'
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
  ELSIF p_ent_brief = 'AS_PROPERTY'
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
  ELSIF p_ent_brief = 'RE_METOD_REINS'
  THEN
    SELECT NAME INTO v_result FROM ins.re_metod_reins WHERE re_metod_reins_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_COVER'
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
  ELSIF p_ent_brief = 'RE_SLIP_HEADER'
  THEN
    SELECT num INTO v_result FROM re_slip_header WHERE re_slip_header_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_SLIP'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_MAIN_CONTRACT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_BORDERO_PACKAGE'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_BORDERO_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.re_bordero_type WHERE re_bordero_type_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_BORDERO'
  THEN
    SELECT rbt.name || ' по пакету ' || rbp.num
      INTO v_result
      FROM re_bordero rb
      JOIN ven_re_bordero_package rbp
        ON rbp.re_bordero_package_id = rb.re_bordero_package_id
      JOIN ven_re_bordero_type rbt
        ON rbt.re_bordero_type_id = rb.re_bordero_type_id
     WHERE rb.re_bordero_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_CONTRACT_VERSION'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'REP_REPORT'
  THEN
    SELECT NAME INTO v_result FROM ins.rep_report WHERE rep_report_id = p_obj_id;
  ELSIF p_ent_brief = 'REP_KIND'
  THEN
    SELECT NAME INTO v_result FROM ins.rep_kind WHERE rep_kind_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DECLINE_REASON'
  THEN
    SELECT NAME INTO v_result FROM ins.t_decline_reason WHERE t_decline_reason_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_DAMAGE'
  THEN
    SELECT tdc.description
      INTO v_result
      FROM re_damage     rd
          ,t_damage_code tdc
     WHERE rd.t_damage_code_id = tdc.id
       AND rd.re_damage_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_CLAIM_HEADER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_CLAIM'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'LPU_ACCOUNT_METOD'
  THEN
    SELECT NAME INTO v_result FROM ins.lpu_account_metod WHERE lpu_account_metod_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_DECLINE_REASON'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_decline_reason WHERE dms_decline_reason_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_ACT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'BSO_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.bso_type WHERE bso_type_id = p_obj_id;
  ELSIF p_ent_brief = 'ORGANISATION_TREE'
  THEN
    SELECT NAME INTO v_result FROM ins.organisation_tree WHERE organisation_tree_id = p_obj_id;
  ELSIF p_ent_brief = 'DEPARTMENT'
  THEN
    SELECT NAME INTO v_result FROM department WHERE department_id = p_obj_id;
  ELSIF p_ent_brief = 'BSO_HIST_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.bso_hist_type WHERE bso_hist_type_id = p_obj_id;
  ELSIF p_ent_brief = 'BSO_DOCUMENT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_PROPERTY_STUFF'
  THEN
    SELECT NAME INTO v_result FROM ins.as_property_stuff WHERE as_property_stuff_id = p_obj_id;
  ELSIF p_ent_brief = 'T_MEASURE_UNIT'
  THEN
    SELECT NAME INTO v_result FROM ins.t_measure_unit WHERE t_measure_unit_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROPERTY_STUFF_TYP'
  THEN
    SELECT NAME INTO v_result FROM ins.t_property_stuff_typ WHERE t_property_stuff_typ_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_VEHICLE_STUFF'
  THEN
    SELECT NAME INTO v_result FROM ins.as_vehicle_stuff WHERE as_vehicle_stuff_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_LPU_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_type WHERE dms_lpu_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_ADV_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_adv_type WHERE dms_adv_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_ISSUER_DOC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_issuer_doc_type WHERE t_issuer_doc_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_SERVICE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_service_type WHERE dms_service_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_CONSULT_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_consult_type WHERE dms_consult_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_CONS_STAT_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_cons_stat_type WHERE dms_cons_stat_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_HOSP_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_hosp_type WHERE dms_hosp_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_CALL_END_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_call_end_type WHERE dms_call_end_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_REQ_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_req_type WHERE dms_req_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_LPU_CAT'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_cat WHERE dms_lpu_cat_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_SERV_CAT_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_serv_cat_type WHERE dms_serv_cat_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_LPU_DEP_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_dep_type WHERE dms_lpu_dep_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_MARK_AT_DEVICE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_mark_at_device WHERE t_mark_at_device_id = p_obj_id;
  ELSIF p_ent_brief = 'T_MODEL_AT_DEVICE'
  THEN
    SELECT NAME INTO v_result FROM t_model_at_device WHERE t_model_at_device_id = p_obj_id;
  ELSIF p_ent_brief = 'T_GROUP_AT_DEVICE'
  THEN
    SELECT NAME INTO v_result FROM t_group_at_device WHERE t_group_at_device_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_INS_REL_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_ins_rel_type WHERE dms_ins_rel_type_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_VEHICLE_AT_DEVICE'
  THEN
    SELECT ma.name || ' ' || mad.name
      INTO v_result
      FROM as_vehicle_at_device vad
      JOIN t_model_at_device mad
        ON vad.t_model_at_device_id = mad.t_model_at_device_id
      JOIN t_mark_at_device ma
        ON ma.t_mark_at_device_id = mad.t_mark_at_device_id
     WHERE vad.as_vehicle_at_device_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_DOCTOR_SPEC'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_doctor_spec WHERE dms_doctor_spec_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_GAR_LET_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_gar_let_type WHERE dms_gar_let_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_AT_DEVICE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM t_at_device_type WHERE t_at_device_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_KVP'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_kvp WHERE dms_kvp_id = p_obj_id;
  ELSIF p_ent_brief = 'T_VEHICLE_STUFF_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_vehicle_stuff_type WHERE t_vehicle_stuff_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_MKB'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_mkb WHERE dms_mkb_id = p_obj_id;
  ELSIF p_ent_brief = 'T_CASCO_PROGRAMM'
  THEN
    SELECT NAME INTO v_result FROM ins.t_casco_programm WHERE t_casco_programm_id = p_obj_id;
  ELSIF p_ent_brief = 'T_CONTACT_STATUS'
  THEN
    SELECT NAME INTO v_result FROM ins.t_contact_status WHERE t_contact_status_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DEPT_ROLE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_dept_role WHERE t_dept_role_id = p_obj_id;
  ELSIF p_ent_brief = 'CONTRACT_LPU_VER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_LPU_ACC_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_lpu_acc_type WHERE dms_lpu_acc_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_INV_PAY_COND'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_inv_pay_cond WHERE dms_inv_pay_cond_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_INV_PAY_ORD'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_inv_pay_ord WHERE dms_inv_pay_ord_id = p_obj_id;
  ELSIF p_ent_brief = 'C_SUBR_DOC'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_PRICE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_price WHERE dms_price_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_AID_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_aid_type WHERE dms_aid_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_AGE_RANGE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_age_range WHERE dms_age_range_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_HEALTH_GROUP'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_health_group WHERE dms_health_group_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_INS_VAR'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_ins_var WHERE dms_ins_var_id = p_obj_id;
  ELSIF p_ent_brief = 'T_VICTIM_OSAGO_TYPE'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_victim_osago_type
     WHERE t_victim_osago_type_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_SET_OFF_RULE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_set_off_rule WHERE dms_set_off_rule_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_SERV_ACT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_INV_LPU'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_SERV_REG'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'REL_RECOVER_BORDERO'
  THEN
    SELECT rel_recover_bordero_id
      INTO v_result
      FROM rel_recover_bordero
     WHERE rel_recover_bordero_id = p_obj_id;
  ELSIF p_ent_brief = 'REL_REDAMAGE_BORDERO'
  THEN
    SELECT rel_redamage_bordero_id
      INTO v_result
      FROM rel_redamage_bordero
     WHERE rel_redamage_bordero_id = p_obj_id;
  ELSIF p_ent_brief = 'DMS_ERR_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.dms_err_type WHERE dms_err_type_id = p_obj_id;
  ELSIF p_ent_brief = 'REMINDER'
  THEN
    SELECT NAME INTO v_result FROM ins.reminder WHERE reminder_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_DISPATCHER'
  THEN
    SELECT NAME INTO v_result FROM ins.as_dispatcher WHERE as_dispatcher_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_DEMAND'
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_COMPLAINT'
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_DEMAND_HOSP'
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_DEMAND_SMP'
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_DEMAND_SERVICE'
  THEN
    SELECT NAME INTO v_result FROM ins.as_demand WHERE as_demand_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSET_ASS_STATUS'
  THEN
    SELECT NAME INTO v_result FROM ins.as_asset_ass_status WHERE as_asset_ass_status_id = p_obj_id;
  ELSIF p_ent_brief = 'T_LOB'
  THEN
    SELECT description INTO v_result FROM ins.t_lob WHERE t_lob_id = p_obj_id;
  ELSIF p_ent_brief = 'QUESTIONNAIRE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.questionnaire_type WHERE questionnaire_type_id = p_obj_id;
  ELSIF p_ent_brief = 'SYS_EVENT_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.sys_event_type WHERE sys_event_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_LOB_LINE'
  THEN
    SELECT description INTO v_result FROM ins.t_lob_line WHERE t_lob_line_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PRODUCT_VER_STATUS'
  THEN
    SELECT description
      INTO v_result
      FROM ins.t_product_ver_status
     WHERE t_product_ver_status_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_COMMISS'
  THEN
    SELECT doc_doc_id INTO v_result FROM doc_doc WHERE doc_doc_id = p_obj_id;
  ELSIF p_ent_brief = 'P_POLICY_AGENT'
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
  ELSIF p_ent_brief = 'POLICY_AGENT_STATUS'
  THEN
    SELECT NAME INTO v_result FROM ins.policy_agent_status WHERE policy_agent_status_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROD_COEF_TARIFF'
  THEN
    SELECT NAME INTO v_result FROM ins.t_prod_coef_tariff WHERE t_prod_coef_tariff_id = p_obj_id;
  ELSIF p_ent_brief = 'T_SQ_YEAR'
  THEN
    SELECT NAME INTO v_result FROM t_sq_year WHERE t_sq_year_id = p_obj_id;
  ELSIF p_ent_brief = 'P_POLICY_AGENT_COM'
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
  ELSIF p_ent_brief = 'T_ADDENDUM_TYPE'
  THEN
    SELECT description INTO v_result FROM t_addendum_type WHERE t_addendum_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PAYMENT_ORDER'
  THEN
    SELECT NAME INTO v_result FROM t_payment_order WHERE t_payment_order_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSURED'
  THEN
    SELECT ent.obj_name(c.ent_id, c.contact_id)
      INTO v_result
      FROM as_assured aa
          ,contact    c
     WHERE aa.as_assured_id = p_obj_id
       AND c.contact_id = aa.assured_contact_id;
  ELSIF p_ent_brief = 'DOC_PROCEDURE'
  THEN
    SELECT NAME INTO v_result FROM doc_procedure WHERE doc_procedure_id = p_obj_id;
  ELSIF p_ent_brief = 'SALES_ACTION'
  THEN
    SELECT NAME INTO v_result FROM sales_action WHERE sales_action_id = p_obj_id;
  ELSIF p_ent_brief = 'DISCOUNT_F'
  THEN
    SELECT NAME INTO v_result FROM discount_f WHERE discount_f_id = p_obj_id;
  ELSIF p_ent_brief = 'T_POLICY_FORM_TYPE'
  THEN
    SELECT NAME INTO v_result FROM ins.t_policy_form_type WHERE t_policy_form_type_id = p_obj_id;
  ELSIF p_ent_brief = 'GARANT_LETTER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'ASSURED_MEDICAL_EXAM'
  THEN
    SELECT assured_medical_exam_id
      INTO v_result
      FROM assured_medical_exam
     WHERE assured_medical_exam_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROD_LINE_DMS'
  THEN
    SELECT description INTO v_result FROM ins.t_product_line WHERE id = p_obj_id;
  ELSIF p_ent_brief = 'AG_CONTRACT_DOVER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'GEN_POLICY'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'T_POLICY_CHANGE_TYPE'
  THEN
    SELECT NAME INTO v_result FROM t_policy_change_type WHERE t_policy_change_type_id = p_obj_id;
  ELSIF p_ent_brief = 'T_DECLINE_PARTY'
  THEN
    SELECT NAME INTO v_result FROM t_decline_party WHERE t_decline_party_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_VEDOM_AV'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AGENT_REPORT_DAV_CT'
  THEN
    SELECT agent_report_dav_ct_id
      INTO v_result
      FROM agent_report_dav_ct
     WHERE agent_report_dav_ct_id = p_obj_id;
  ELSIF p_ent_brief = 'P_POL_HEADER_REINS'
  THEN
    SELECT 'ДС №' || ph.num || ' от ' || to_char(ph.start_date, 'dd.mm.yyyy')
      INTO v_result
      FROM ven_p_pol_header ph
     WHERE ph.policy_header_id = p_obj_id;
  ELSIF p_ent_brief = 'T_PROFITABLENESS'
  THEN
    SELECT NAME INTO v_result FROM t_profitableness WHERE t_profitableness_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSURED_DOCUM'
  THEN
    SELECT as_assured_docum_id
      INTO v_result
      FROM as_assured_docum
     WHERE as_assured_docum_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ASSURED_FORM'
  THEN
    SELECT as_assured_form_id INTO v_result FROM as_assured_form WHERE as_assured_form_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_CONTRACT_VER_EL'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'RE_TANT_SCORE'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AS_ACTIVITY'
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
  ELSIF p_ent_brief = 'AS_ASSET_FORM'
  THEN
    SELECT as_asset_form_id INTO v_result FROM as_asset_form WHERE as_asset_form_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_ATTEST_DOCUMENT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_ROLL_HEADER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_ROLL'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'AG_PERFOMED_WORK_ACT'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'POLICY_INDEX_HEADER'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'POLICY_INDEX_ITEM'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
    -- Ошибка в сущности №4564
  ELSIF p_ent_brief = 'P_POLICY_AGENT_DOC'
  THEN
    SELECT d.num INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  ELSIF p_ent_brief = 'P_TRANS_DECLINE'
  THEN
    SELECT d.document_id INTO v_result FROM document d WHERE d.document_id = p_obj_id;
  END IF;
  RETURN(v_result);
END;
/

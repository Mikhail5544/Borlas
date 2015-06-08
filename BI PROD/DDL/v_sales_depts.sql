create or replace view v_sales_depts as
select sd.sales_dept_header_id,
          sd.sales_dept_id,
          sd.dept_name,
          sd.legal_name,
          sd.short_name,
          sd.marketing_name,
          sd.initiator_id,
          ico.obj_name_orig as initiator_name,
          iah.t_sales_channel_id as initiator_sales_channel_id,
          sd.manager_id,
          mco.obj_name_orig as manager_name,
          lah.ag_contract_header_id as local_director_id,
          lco.obj_name_orig as local_director_name,
          ad.id as address_id,
          NVL (ad.name, pkg_contact.get_address_name (ad.id)) as address,
          sd.open_date,
          sc.description as sales_channel,
          cc.t_navision_cc_id,
          cc.cc_code,
          co.contact_id as company_id,
          co.obj_name_orig as company_name,
          ot.organisation_tree_id as branch_id,
          ot.name as branch_name,
          sd.kpp,
          rh.t_roo_header_id,
          rh.roo_number,
          ro.roo_name,
          th.t_tap_header_id,
          tp.tap_number,
          TO_CHAR (sh.universal_code, 'FM0009') as universal_code,
          ot.code as branch_code,
          NULLIF (sd.close_date, pkg_sales_depts.get_default_end_date)
             as close_date,
          case sd.send_status
             when 0 then 'Не экспортировалось'
             when 1 then 'Экспортировано'
             when -1 then 'Не экспортировано'
          end
             as send_status_text,
          sd.send_error_text,
          case sh.last_sales_dept_id when sd.sales_dept_id then 1 else 0 end
             as is_last_version,
          sd.start_date,
          su.sys_user_name,
          sd.ver_num,
          RO.CORP_MAIL
     from ven_sales_dept_header sh,
          ven_sales_dept sd,
          ven_cn_entity_address ea,
          cn_address ad,
          ag_contract_header iah,
          contact ico,
          ag_contract_header mah,
          contact mco,
          ag_contract mac,
          ag_contract_header lah,
          ag_contract lac,
          contact lco,
          t_sales_channel sc,
          ven_t_navision_cc cc,
          contact co,
          organisation_tree ot,
          ven_t_roo_header rh,
          ven_t_roo ro,
          ven_t_tap_header th,
          ven_t_tap tp,
          sys_user su
    where     sh.sales_dept_header_id = sd.sales_dept_header_id
          and sd.ent_id = ea.ure_id
          and sd.sales_dept_id = ea.uro_id
          and ea.address_id = ad.id
          and sd.initiator_id = iah.ag_contract_header_id
          and iah.agent_id = ico.contact_id
          and sd.manager_id = mah.ag_contract_header_id
          and mah.agent_id = mco.contact_id
          and mah.last_ver_id = mac.ag_contract_id
          and mac.contract_leader_id = lac.ag_contract_id(+)
          and lac.contract_id = lah.ag_contract_header_id(+)
          and lah.agent_id = lco.contact_id(+)
          and mac.ag_sales_chn_id = sc.id
          and sd.t_navision_cc_id = cc.t_navision_cc_id
          and sd.company_id = co.contact_id
          and sd.branch_id = ot.organisation_tree_id(+)
          and sd.t_roo_header_id = rh.t_roo_header_id
          and rh.last_roo_id = ro.t_roo_id
          and sd.t_tap_header_id = th.t_tap_header_id
          and th.last_tap_id = tp.t_tap_id
          and sd.sys_user_id = su.sys_user_id;

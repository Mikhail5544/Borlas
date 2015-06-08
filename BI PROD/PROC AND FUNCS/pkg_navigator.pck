CREATE OR REPLACE PACKAGE pkg_navigator IS

  -- Author  : Доброхотова И.
  -- Created : 03.10.2014 8:46:57
  -- Purpose : Пакет для обмена данными с Навигатором

  -- 365198 Передача информации о РОО в Навигатор  
  PROCEDURE get_departments(par_response OUT JSON);

  -- 365198 Передача информации о карьере агентов
  PROCEDURE get_careers
  (
    par_agent_num IN VARCHAR2
   ,par_agent     OUT NOCOPY JSON
  );
  PROCEDURE get_careers
  (
    par_request  IN JSON
   ,par_response OUT NOCOPY JSON
  );

END pkg_navigator;
/
CREATE OR REPLACE PACKAGE BODY pkg_navigator IS

  -- 365198 Передача информации о РОО в Навигатор  
  PROCEDURE get_departments(par_response OUT JSON) IS
    /*    TYPE t_regions IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;
    v_region_tab t_regions;*/
  
    v_depts_array JSON_LIST := JSON_LIST();
    v_depts       JSON;
    v_depts_num   JSON;
  
    v_regions_array JSON_LIST := JSON_LIST();
    v_region        JSON;
    v_region_num    JSON;
  
    v_data JSON;
  
  BEGIN
    v_region_num := JSON();
    v_depts_num  := JSON();
    FOR rec IN (SELECT to_char(sh.universal_code, 'FM0009') AS dept_number
                      ,sd.dept_name
                      ,rh.roo_number
                      ,nvl(ad.name, pkg_contact.get_address_name(ad.id)) AS address
                      ,coalesce((SELECT kk.name
                                  FROM cn_address        ca
                                      ,cn_entity_address cea
                                      ,t_kladr           kk
                                 WHERE cea.ure_id = sd.ent_id
                                   AND cea.uro_id = sd.sales_dept_id
                                   AND cea.address_id = ca.id
                                   AND rpad(substr(ca.code, 1, 2), 13, '0') = kk.code)
                               ,(SELECT k.name
                                  FROM organisation_tree ot
                                      ,t_kladr           k
                                 WHERE ot.organisation_tree_id = sh.organisation_tree_id
                                   AND rpad(lpad(ot.reg_code, 2, '0'), 13, '0') = k.code)) AS region_name
                      ,coalesce((SELECT substr(kk.code, 1, 2)
                                  FROM cn_address        ca
                                      ,cn_entity_address cea
                                      ,t_kladr           kk
                                 WHERE cea.ure_id = sd.ent_id
                                   AND cea.uro_id = sd.sales_dept_id
                                   AND cea.address_id = ca.id
                                   AND rpad(substr(ca.code, 1, 2), 13, '0') = kk.code)
                               ,(SELECT substr(k.code, 1, 2)
                                  FROM organisation_tree ot
                                      ,t_kladr           k
                                 WHERE ot.organisation_tree_id = sh.organisation_tree_id
                                   AND rpad(lpad(ot.reg_code, 2, '0'), 13, '0') = k.code)) AS region_code
                  FROM ven_sales_dept_header sh
                      ,ven_sales_dept        sd
                      ,ven_t_roo_header      rh
                      ,ven_cn_entity_address ea
                      ,cn_address            ad
                 WHERE sh.last_sales_dept_id = sd.sales_dept_id
                   AND sd.t_roo_header_id = rh.t_roo_header_id
                   AND sd.ent_id = ea.ure_id
                   AND sd.sales_dept_id = ea.uro_id
                   AND ea.address_id = ad.id
                /*AND safety.check_right_custom('CSR_SDEPTS_SEARCH') = 1*/
                UNION ALL
                -- РОО
                SELECT to_char(rh.roo_number) AS dept_number
                      ,ro.roo_name
                      ,rh.roo_number
                      ,NULL AS address
                      ,coalesce((SELECT kk.name
                                  FROM cn_address        ca
                                      ,cn_entity_address cea
                                      ,t_kladr           kk
                                 WHERE cea.ure_id = sd.ent_id
                                   AND cea.uro_id = sd.sales_dept_id
                                   AND cea.address_id = ca.id
                                   AND rpad(substr(ca.code, 1, 2), 13, '0') = kk.code)
                               ,(SELECT k.name
                                  FROM organisation_tree ot
                                      ,t_kladr           k
                                 WHERE ot.organisation_tree_id = sh.organisation_tree_id
                                   AND rpad(lpad(ot.reg_code, 2, '0'), 13, '0') = k.code)) AS region_name
                      ,coalesce((SELECT substr(kk.code, 1, 2)
                                  FROM cn_address        ca
                                      ,cn_entity_address cea
                                      ,t_kladr           kk
                                 WHERE cea.ure_id = sd.ent_id
                                   AND cea.uro_id = sd.sales_dept_id
                                   AND cea.address_id = ca.id
                                   AND rpad(substr(ca.code, 1, 2), 13, '0') = kk.code)
                               ,(SELECT substr(k.code, 1, 2)
                                  FROM organisation_tree ot
                                      ,t_kladr           k
                                 WHERE ot.organisation_tree_id = sh.organisation_tree_id
                                   AND rpad(lpad(ot.reg_code, 2, '0'), 13, '0') = k.code)) AS region_code
                  FROM ven_t_roo_header      rh
                      ,ven_t_roo             ro
                      ,ven_sales_dept_header sh
                      ,ven_sales_dept        sd
                 WHERE rh.last_roo_id = ro.t_roo_id
                   AND ro.organisation_tree_id = sh.organisation_tree_id(+)
                   AND sh.last_sales_dept_id = sd.sales_dept_id(+)
                /*AND safety.check_right_custom('CSR_ROO_SEARCH') = 1*/
                )
    LOOP
      /*      IF NOT v_region_tab.exists(rec.region_code)
      THEN
        v_region_tab(rec.region_code) := rec.region_name;
      END IF;*/
      IF NOT v_region_num.exist(rec.region_code)
         AND (rec.region_code IS NOT NULL OR rec.region_name IS NOT NULL)
      THEN
        v_region := JSON();
        v_region.put('name', rec.region_name);
        v_region_num.put(rec.region_code, v_region.to_json_value);
      END IF;
      v_depts := JSON();
      v_depts.put('name', rec.dept_name);
      v_depts.put('address', rec.address);
      v_depts.put('parent_num', rec.roo_number);
      v_depts.put('region_num', rec.region_code);
    
      --      v_depts_num := JSON();
      v_depts_num.put(rec.dept_number, v_depts.to_json_value);
      --      v_depts_array.append(v_depts_num.to_json_value);
    END LOOP;
    --    v_regions_array.append(v_region_num.to_json_value);
    --    v_depts_array.append(v_depts_num.to_json_value);
  
    v_data := JSON();
    v_data.put('regions', v_region_num.to_json_value);
    v_data.put('departments', v_depts_num.to_json_value);
  
    /*    v_data.put('regions', v_region_num.to_json_value);
    v_data.put('departments', v_depts_array.to_json_value);*/
    par_response := JSON();
    par_response.put('status', pkg_communication.gc_ok);
    par_response.put('data', v_data.to_json_value);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise('Ошибка формирования данных о РОО и подразделениях');
  END get_departments;

  -- 365198 Передача информации о карьере агентов
  PROCEDURE get_careers
  (
    par_agent_num IN VARCHAR2
   ,par_agent     OUT NOCOPY JSON
  ) IS
    TYPE t_agent_info IS RECORD(
       ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE
      ,num                   document.num%TYPE
      ,surname               contact.name%TYPE
      ,NAME                  contact.first_name%TYPE
      ,midname               contact.middle_name%TYPE
      ,birthdate             cn_person.date_of_birth%TYPE
      ,doc_series            cn_contact_ident.serial_nr%TYPE
      ,doc_num               cn_contact_ident.id_value%TYPE
      ,doc_date              cn_contact_ident.issue_date%TYPE
      ,doc_source            cn_contact_ident.place_of_issue%TYPE
      ,doc_type              t_id_type.brief%TYPE
      ,phone                 VARCHAR2(255)
      ,email                 cn_contact_email.email%TYPE);
  
    v_agent_info t_agent_info;
  
    --    v_agent         JSON;
    v_career        JSON;
    v_careers_array JSON_LIST;
  
  BEGIN
  
    SELECT ach.ag_contract_header_id
          ,ach.num
          ,c.name
          ,c.first_name
          ,c.middle_name
          ,cp.date_of_birth
          ,cci.serial_nr
          ,cci.id_value
          ,cci.issue_date
          ,cci.place_of_issue
          ,it.brief
          ,pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_active_primary_phone_id(c.contact_id)) phone
          ,pkg_contact_rep_utils.get_email(pkg_contact_rep_utils.get_last_active_email_id(c.contact_id)) email
      INTO v_agent_info
      FROM ven_ag_contract_header ach
          ,contact                c
          ,cn_person              cp
          ,cn_contact_ident       cci
          ,t_id_type              it
     WHERE ach.num = par_agent_num
       AND c.contact_id = ach.agent_id
       AND cp.contact_id(+) = c.contact_id
       AND cci.table_id = pkg_contact_rep_utils.get_primary_doc_id(c.contact_id)
       AND cci.id_type = it.id;
  
    v_careers_array := JSON_LIST();
    FOR rec IN (SELECT date_begin
                      ,nvl(lead(date_begin) over(ORDER BY date_begin) - INTERVAL '1' SECOND
                          ,to_date('31.12.2999 23:59:59', 'dd.mm.yyyy hh24:mi:ss')) end_date
                      ,last_value(category ignore NULLS) over(ORDER BY date_begin rows BETWEEN unbounded preceding AND CURRENT ROW) AS category
                      ,last_value(department_name ignore NULLS) over(ORDER BY date_begin rows BETWEEN unbounded preceding AND CURRENT ROW) AS department_name
                      ,last_value(department_code ignore NULLS) over(ORDER BY date_begin rows BETWEEN unbounded preceding AND CURRENT ROW) AS department_code
                      ,last_value(num ignore NULLS) over(ORDER BY date_begin rows BETWEEN unbounded preceding AND CURRENT ROW) AS leader_ag_number
                  FROM (SELECT nvl(c.date_begin, l.date_begin) AS date_begin
                              ,c.category
                              ,c.department_name
                              ,c.department_code
                              ,l.num
                          FROM (SELECT /*+no_merge*/
                                 ac.date_begin
                                ,acat.brief    AS category
                                ,d.name        AS department_name
                                 --                                ,to_char(d.department_id) AS department_code
                                ,to_char(sh.universal_code, 'FM0009') AS department_code
                                  FROM ven_ag_contract       ac
                                      ,ag_category_agent     acat
                                      ,department            d
                                      ,ven_sales_dept_header sh
                                 WHERE ac.contract_id = v_agent_info.ag_contract_header_id
                                   AND acat.ag_category_agent_id = ac.category_id
                                   AND ac.agency_id = d.department_id(+)
                                   AND sh.organisation_tree_id = d.org_tree_id) c
                          FULL OUTER JOIN (SELECT /*+no_merge*/
                                           at.date_begin
                                          ,d.num
                                            FROM ag_agent_tree at
                                                ,document      d
                                           WHERE at.ag_contract_header_id =
                                                 v_agent_info.ag_contract_header_id
                                             AND at.ag_parent_header_id = d.document_id(+)) l
                            ON c.date_begin = l.date_begin)
                 ORDER BY date_begin)
    LOOP
      v_career := JSON();
      v_career.put('date_start', rec.date_begin);
      v_career.put('date_end', rec.end_date);
      v_career.put('role', rec.category);
      v_career.put('manager_num', rec.leader_ag_number);
      v_career.put('department_num', rec.department_code);
      v_careers_array.append(v_career.to_json_value);
    END LOOP;
  
    /*    par_agent := JSON();
        --    par_agent.put('num', v_agent_info.num);
        par_agent.put('surname', v_agent_info.surname);
        par_agent.put('name', v_agent_info.name);
        par_agent.put('midname', v_agent_info.midname);
        par_agent.put('birthdate', v_agent_info.birthdate);
        par_agent.put('doc_series', v_agent_info.doc_series);
        par_agent.put('doc_num', v_agent_info.doc_num);
        par_agent.put('doc_date', v_agent_info.doc_date);
        par_agent.put('doc_source', v_agent_info.doc_source);
        par_agent.put('phone', v_agent_info.phone);
        par_agent.put('email', v_agent_info.email);
        par_agent.put('career', v_careers_array.to_json_value);
    */
  
    /*    v_agent := JSON();
    --    par_agent.put('num', v_agent_info.num);
    v_agent.put('surname', v_agent_info.surname);
    v_agent.put('name', v_agent_info.name);
    v_agent.put('midname', v_agent_info.midname);
    v_agent.put('birthdate', v_agent_info.birthdate);
    v_agent.put('doc_type', v_agent_info.doc_type);
    v_agent.put('doc_series', v_agent_info.doc_series);
    v_agent.put('doc_num', v_agent_info.doc_num);
    v_agent.put('doc_date', v_agent_info.doc_date);
    v_agent.put('doc_source', v_agent_info.doc_source);
    v_agent.put('phone', v_agent_info.phone);
    v_agent.put('email', v_agent_info.email);
    v_agent.put('career', v_careers_array.to_json_value);*/
    par_agent := JSON();
    --    par_agent.put('num', par_agent_info.num);
    par_agent.put('surname', v_agent_info.surname);
    par_agent.put('name', v_agent_info.name);
    par_agent.put('midname', v_agent_info.midname);
    par_agent.put('birthdate', v_agent_info.birthdate);
    par_agent.put('doc_type', v_agent_info.doc_type);
    par_agent.put('doc_series', v_agent_info.doc_series);
    par_agent.put('doc_num', v_agent_info.doc_num);
    par_agent.put('doc_date', v_agent_info.doc_date);
    par_agent.put('doc_source', v_agent_info.doc_source);
    par_agent.put('phone', v_agent_info.phone);
    par_agent.put('email', v_agent_info.email);
    par_agent.put('career', v_careers_array.to_json_value);
    --    par_agent := JSON();
    --    par_agent. := v_agent;
    --    par_agent.put(v_agent_info.num, v_agent.to_json_value);
  EXCEPTION
    WHEN no_data_found THEN
      ex.raise('Не найдены данные по агенту ' || par_agent_num);
    WHEN OTHERS THEN
      ex.raise('Ошибка формирования данных о карьере агента ' || par_agent_num);
  END get_careers;

  PROCEDURE get_careers
  (
    par_request  IN JSON
   ,par_response OUT NOCOPY JSON
  ) IS
    v_agent          JSON;
    v_agent_array    JSON := JSON();
    v_agent_list     JSON_LIST := JSON_LIST();
    v_agent_num_list JSON_LIST := JSON_LIST();
    v_agent_num      document.num%TYPE;
  BEGIN
    IF par_request.exist('nums')
    THEN
      --      v_agent_num := par_request.get('agent_num').get_string;
      v_agent_num_list := JSON_LIST(par_request.get('nums'));
      FOR i IN 1 .. v_agent_num_list.count
      LOOP
        v_agent_num := v_agent_num_list.get(i).get_string;
        get_careers(v_agent_num, v_agent);
        --        v_agent_list.append(v_agent.to_json_value);
        v_agent_array.put(v_agent_num, v_agent.to_json_value);
      END LOOP;
    
      /*            par_response := JSON();
      par_response.put('status', pkg_communication.gc_ok);
      par_response.put('data', v_agent.to_json_value);*/
    ELSE
      BEGIN
        FOR rec IN (SELECT ah.num
                      FROM ven_ag_contract_header ah
                          ,t_sales_channel        sc
                          ,doc_status_ref         dsr
                     WHERE ah.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief NOT IN ('BREAK', 'CANCEL')
                       AND ah.t_sales_channel_id = sc.id
                       AND sc.brief IN ('MLM', 'CC')
                       AND ah.is_new = 1)
        LOOP
          get_careers(rec.num, v_agent);
          --          v_agent_list.append(v_agent.to_json_value);
          v_agent_array.put(to_char(rec.num), v_agent.to_json_value);
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          ex.raise(v_agent.to_char);
      END;
      /*      par_response := JSON();
      par_response.put('status', pkg_communication.gc_ok);
      par_response.put('data', v_agent_list.to_json_value);*/
    END IF;
    par_response := JSON();
    par_response.put('status', pkg_communication.gc_ok);
    --    par_response.put('data', v_agent_list.to_json_value);
    par_response.put('data', v_agent_array.to_json_value);
  END;

END pkg_navigator;
/

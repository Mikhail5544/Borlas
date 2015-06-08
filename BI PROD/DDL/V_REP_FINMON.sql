CREATE OR REPLACE VIEW V_REP_FINMON AS
SELECT pp.policy_id
      ,c.contact_id
      ,CASE
         WHEN ct.ext_id = 'ФизЛицо'
              AND ct.brief = 'ФЛ' THEN
          'ФЛ'
         WHEN ct.ext_id = 'ФизЛицо'
              AND ct.brief = 'ПБОЮЛ' THEN
          'ИП'
         ELSE
          'ЮЛ'
       END cont_type
      ,ph.ids
      ,dsr.brief pol_active_status
      ,pp.premium * acc_new.get_rate_by_id(1, ph.fund_id, pp.start_date) premium_rur
      ,pkg_contact_rep_utils.get_contact_fio_initials(ach.agent_id) agent_fio
      ,dep.name agency_name
      ,(SELECT ro.roo_name
          FROM sales_dept_header sh
              ,sales_dept        sd
              ,t_roo_header      rh
              ,t_roo             ro
         WHERE sh.last_sales_dept_id = sd.sales_dept_id
           AND sd.t_roo_header_id = rh.t_roo_header_id
           AND rh.last_roo_id = ro.t_roo_id
           AND sh.organisation_tree_id = dep.org_tree_id) roo_name
      ,pp.pol_ser
      ,pp.pol_num
      ,pp.start_date
      ,pp.sign_date
      ,c.obj_name_orig
      ,to_char(cp.date_of_birth, 'dd.mm.yyyy') date_of_birth
      ,FLOOR(MONTHS_BETWEEN(pp.sign_date, cp.date_of_birth) / 12) cont_age
      ,pol.cont_role
      ,(SELECT it.description
          FROM cn_contact_ident ci
              ,t_id_type        it
         WHERE 1 = 1
           AND ci.id_type = it.id
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_name
      ,(SELECT it.brief
          FROM cn_contact_ident ci
              ,t_id_type        it
         WHERE 1 = 1
           AND ci.id_type = it.id
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_brief
      ,(SELECT ci.serial_nr
          FROM cn_contact_ident ci
         WHERE 1 = 1
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_ser
      ,(SELECT ci.id_value
          FROM cn_contact_ident ci
         WHERE 1 = 1
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_num
      ,(SELECT ci.place_of_issue
          FROM cn_contact_ident ci
         WHERE 1 = 1
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_place_of_issue
      ,(SELECT to_char(ci.issue_date, 'dd.mm.yyyy')
          FROM cn_contact_ident ci
         WHERE 1 = 1
           AND ci.contact_id = c.contact_id
           AND ci.table_id = pkg_rep_utils.get_finmon_ident_id(c.contact_id, pp.sign_date)) cont_ident_issue_date
      ,CASE ct.ext_id
         WHEN 'ФизЛицо' THEN
          pkg_contact_rep_utils.get_address(coalesce(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_CONST')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'CONST') -- Адрес постоянной регистрации
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_TEMPORARY')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'TEMPORARY') -- Адрес временной регистрации
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_DOMADD')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'DOMADD') -- Домашний адрес
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_POSTAL')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'POSTAL') -- Почтовый адрес
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_FACT')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FACT') -- Адрес фактического нахождения
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_LEGAL')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'LEGAL'))) -- Юридический адрес
         ELSE
          pkg_contact_rep_utils.get_address(coalesce(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_LEGAL')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'LEGAL') -- Юридический адрес
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_FACT')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FACT') -- Адрес фактического нахождения
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_POSTAL')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'POSTAL') -- Почтовый адрес
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_CONST')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'CONST') -- Адрес постоянной регистрации
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_TEMPORARY')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'TEMPORARY') -- Адрес временной регистрации
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'FK_DOMADD')
                                                    ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                                     ,'DOMADD'))) -- Домашний адрес
       END cont_address
      ,c.resident_flag
      ,cou.description cont_country_birth
      ,CASE
         WHEN cou.description IS NOT NULL THEN
          cou.description
         WHEN cou.description IS NULL
              AND c.resident_flag = 1 THEN
          'Россия'
       END citizenry
      ,(SELECT id_value
          FROM cn_contact_ident
         WHERE table_id = pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'INN')) cont_inn
      ,(SELECT id_value
          FROM cn_contact_ident
         WHERE table_id =
               pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'FOREIGN_COMPANY_CODE')) cont_kio
      ,CASE c.is_public_contact
         WHEN 1 THEN
          'Да'
         ELSE
          'Нет'
       END cont_ipdl
      ,CASE cp.is_in_list
         WHEN 1 THEN
          'Да'
         ELSE
          'Нет'
       END cont_rpdl
      ,(SELECT id_value
          FROM cn_contact_ident
         WHERE table_id = pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'REG_SVID')) cont_reg_svid
      ,(SELECT to_char(issue_date, 'dd.mm.yyyy')
          FROM cn_contact_ident
         WHERE table_id = pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'REG_SVID')) cont_reg_svid_issue_date
      ,(SELECT id_value
          FROM cn_contact_ident
         WHERE table_id = pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'OGRN')) cont_ogrn
      ,(SELECT to_char(issue_date, 'dd.mm.yyyy')
          FROM cn_contact_ident
         WHERE table_id = pkg_contact_rep_utils.get_last_doc_by_type(c.contact_id, 'OGRN')) cont_ogrn_issue_date
      ,cp.last_update_date
  FROM p_policy pp
      ,p_pol_header ph
      ,document d
      ,doc_status_ref dsr
      ,p_policy_agent_doc pad
      ,document d_pad
      ,doc_status_ref dsr_pad
      ,ag_contract_header ach
      ,department dep
      ,(SELECT ai.policy_id
              ,ai.insured_contact_id contact_id
              ,'Страхователь' cont_role
          FROM as_insured ai
        UNION
        SELECT ass.p_policy_id
              ,nvl(asu.assured_contact_id, ass.contact_id) contact_id
              ,'Застрахованный' cont_role
          FROM as_asset   ass
              ,as_assured asu
         WHERE ass.as_asset_id = asu.as_assured_id(+)
        UNION
        SELECT ass.p_policy_id
              ,ab.contact_id
              ,'Выгодоприобретатель' cont_role
          FROM as_asset       ass
              ,as_beneficiary ab
         WHERE ass.as_asset_id = ab.as_asset_id) pol
      ,contact c
      ,cn_person cp
      ,t_country cou
      ,t_contact_type ct
 WHERE 1 = 1
   AND pp.pol_header_id = ph.policy_header_id
   AND ph.policy_id = d.document_id
   AND d.doc_status_ref_id = dsr.doc_status_ref_id
   AND ph.policy_header_id = pad.policy_header_id
   AND pad.ag_contract_header_id = ach.ag_contract_header_id
   AND pad.p_policy_agent_doc_id = d_pad.document_id
   AND d_pad.doc_status_ref_id = dsr_pad.doc_status_ref_id
   AND dsr_pad.brief = 'CURRENT'
      --394270 Григорьев Ю. Убрал ограничение, чтобы можно было выгружать информацию по недействующим договорам
      --AND SYSDATE BETWEEN pad.date_begin AND pad.date_end
   AND ach.agency_id = dep.department_id
   AND pp.policy_id = pol.policy_id
   AND pol.contact_id = c.contact_id
   AND c.contact_id = cp.contact_id(+)
   AND cp.country_birth = cou.id(+)
   AND c.contact_type_id = ct.id(+)
 ORDER BY policy_id;

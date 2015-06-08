CREATE OR REPLACE VIEW V_REP_FINMON_COMPANY AS
SELECT DISTINCT
       f.ids                                           "ИДС"
      ,f.start_date                                    "Дата заключения"
      ,f.agent_fio                                     "Агент"
      ,f.agency_name                                   "Агентство"
      ,f.roo_name                                      "РОО"
      ,f.cont_role                                     "Роли и связи"
      ,f.obj_name_orig                                 "Наименование"
      ,f.cont_address                                  "Адрес"
      ,NVL(f.cont_inn, f.cont_kio)                     "ИНН / КИО"
      ,f.cont_ogrn                                     "ОГРН"
      ,f.cont_ogrn_issue_date                          "Дата регистрации"
      ,(SELECT c_cr.obj_name_orig
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND ROWNUM = 1)
      	                                               "Бенефициарный владелец"
      ,(SELECT to_char(c_cr_cp.date_of_birth, 'dd.mm.yyyy')
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
            ,cn_person          c_cr_cp
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND c_cr.contact_id      = c_cr_cp.contact_id
          AND ROWNUM = 1)
      	                                               "Дата рожд. бенефиц. владельца"
      ,(SELECT it_cr.description                               
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
            ,cn_contact_ident   ci_cr
            ,t_id_type          it_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND c_cr.contact_id      = ci_cr.contact_id
          AND ci_cr.id_type        = it_cr.id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND ci_cr.table_id       = pkg_rep_utils.get_finmon_ident_id(c_cr.contact_id, f.sign_date)
          AND ROWNUM = 1)
                                                       "Документ бенефиц. владельца"
      ,(SELECT DECODE(ci_cr.serial_nr, NULL, ci_cr.id_value, ci_cr.serial_nr || ' ' || ci_cr.id_value)
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
            ,cn_contact_ident   ci_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND c_cr.contact_id      = ci_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND ci_cr.table_id       = pkg_rep_utils.get_finmon_ident_id(c_cr.contact_id, f.sign_date)
          AND ROWNUM = 1)
                                                       "Серия, номер"
      ,(SELECT ci_cr.place_of_issue
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
            ,cn_contact_ident   ci_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND c_cr.contact_id      = ci_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND ci_cr.table_id       = pkg_rep_utils.get_finmon_ident_id(c_cr.contact_id, f.sign_date)
          AND ROWNUM = 1)
                                                       "Кем выдан"
      ,(SELECT to_char(ci_cr.issue_date, 'dd.mm.yyyy')      
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
            ,cn_contact_ident   ci_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND c_cr.contact_id      = ci_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
          AND ci_cr.table_id       = pkg_rep_utils.get_finmon_ident_id(c_cr.contact_id, f.sign_date)
          AND ROWNUM = 1)
                                                       "Дата выдачи"
      ,(SELECT
           pkg_contact_rep_utils.get_address(COALESCE(pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_LEGAL')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'LEGAL')     -- Юридический адрес
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_FACT')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FACT')      -- Адрес фактического нахождения
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_POSTAL')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'POSTAL')    -- Почтовый адрес
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_CONST')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'CONST')     -- Адрес постоянной регистрации
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_TEMPORARY')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'TEMPORARY') -- Адрес временной регистрации
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'FK_DOMADD')
                                                     ,pkg_contact_rep_utils.get_last_active_address_id(c_cr.contact_id, 'DOMADD')))   -- Юридический адрес
        FROM cn_contact_rel     cr
            ,t_contact_rel_type crt
            ,contact            c_cr
        WHERE 1 = 1
          AND cr.contact_id_a      = f.contact_id
          AND cr.relationship_type = crt.id
          AND cr.contact_id_b      = c_cr.contact_id
          AND crt.brief            = 'Бенефициарный владелецЮридическое лицо'
                    AND rownum = 1) "Бенефиц. владелец Адрес"
                ,pi.contact_name "Страхователь по договору"
  FROM v_rep_finmon f
      ,v_pol_issuer pi
 WHERE 1 = 1
  AND f.cont_type                     = 'ЮЛ'
  AND f.pol_active_status             NOT IN ('PROJECT', 'CANCEL')
   AND lower(f.obj_name_orig) NOT LIKE lower('%По закону Рф%')
   AND (f.cont_ogrn IS NULL OR f.cont_ogrn_issue_date IS NULL OR nvl(f.cont_inn, f.cont_kio) IS NULL)
   AND pi.policy_id = f.policy_id;

CREATE OR REPLACE VIEW V_REP_FINMON_PERSON AS
SELECT DISTINCT
       f.ids                                           "ИДС"
      ,f.start_date                                    "Дата заключения"
      ,f.agent_fio                                     "Агент"
      ,f.agency_name                                   "Агентство"
      ,f.roo_name                                      "РОО"
      ,f.cont_role                                     "Роли и связи"
      ,f.obj_name_orig                                 "ФИО"
      ,f.cont_ipdl                                     "Иностр. публичное долж. лицо"
      ,f.cont_rpdl                                     "Принадлежит перечню РПДЛ"
      ,f.cont_type                                     "Юридический статус"
      ,f.date_of_birth                                 "Дата Рождения"
      ,f.citizenry                                     "Гражданство"
      ,f.cont_ident_name                               "Документ"
      ,f.cont_ident_ser || ' ' || f.cont_ident_num     "Серия, номер"
      ,f.cont_ident_place_of_issue                     "Кем выдан"
      ,f.cont_ident_issue_date                         "Дата выдачи"
      ,f.cont_address                                  "Адрес регистр. или проживания"
      ,f.cont_inn                                      "ИНН"
      ,f.cont_reg_svid                                 "Свидетельство ИП"
      ,f.cont_reg_svid_issue_date                      "Дата выдачи свидетельства ИП"
FROM v_rep_finmon f
WHERE 1 = 1
  AND f.cont_type                     IN ('ФЛ', 'ИП')
  AND (((f.cont_ipdl                   = 'Да'
         OR f.cont_rpdl                = 'Да') 
        AND f.cont_type = 'ФЛ')
       OR ((f.pol_active_status       NOT IN ('PROJECT', 'CANCEL'))
           AND ((f.cont_type       = 'ФЛ'
                AND f.premium_rur >= 5000)
               OR f.cont_type      = 'ЮЛ')
           AND (f.date_of_birth       IS NULL
                OR f.cont_address     IS NULL
                OR (f.cont_type       = 'ИП'
                    AND (f.cont_inn IS NULL OR f.cont_reg_svid IS NULL OR f.cont_reg_svid_issue_date IS NULL))
                OR (f.resident_flag = 0 AND f.cont_country_birth IS NULL)
                OR (f.cont_ident_ser IS NULL OR f.cont_ident_num IS NULL)
                OR (f.cont_ident_brief IN ('PASS_RF', 'PASS_SSSR') AND (f.cont_ident_place_of_issue IS NULL OR 
                                                                        f.cont_ident_issue_date IS NULL))
               )
          )
      );

CREATE OR REPLACE VIEW V_REP_FINMON_PERSON AS
SELECT DISTINCT
       f.ids                                           "���"
      ,f.start_date                                    "���� ����������"
      ,f.agent_fio                                     "�����"
      ,f.agency_name                                   "���������"
      ,f.roo_name                                      "���"
      ,f.cont_role                                     "���� � �����"
      ,f.obj_name_orig                                 "���"
      ,f.cont_ipdl                                     "������. ��������� ����. ����"
      ,f.cont_rpdl                                     "����������� ������� ����"
      ,f.cont_type                                     "����������� ������"
      ,f.date_of_birth                                 "���� ��������"
      ,f.citizenry                                     "�����������"
      ,f.cont_ident_name                               "��������"
      ,f.cont_ident_ser || ' ' || f.cont_ident_num     "�����, �����"
      ,f.cont_ident_place_of_issue                     "��� �����"
      ,f.cont_ident_issue_date                         "���� ������"
      ,f.cont_address                                  "����� �������. ��� ����������"
      ,f.cont_inn                                      "���"
      ,f.cont_reg_svid                                 "������������� ��"
      ,f.cont_reg_svid_issue_date                      "���� ������ ������������� ��"
FROM v_rep_finmon f
WHERE 1 = 1
  AND f.cont_type                     IN ('��', '��')
  AND (((f.cont_ipdl                   = '��'
         OR f.cont_rpdl                = '��') 
        AND f.cont_type = '��')
       OR ((f.pol_active_status       NOT IN ('PROJECT', 'CANCEL'))
           AND ((f.cont_type       = '��'
                AND f.premium_rur >= 5000)
               OR f.cont_type      = '��')
           AND (f.date_of_birth       IS NULL
                OR f.cont_address     IS NULL
                OR (f.cont_type       = '��'
                    AND (f.cont_inn IS NULL OR f.cont_reg_svid IS NULL OR f.cont_reg_svid_issue_date IS NULL))
                OR (f.resident_flag = 0 AND f.cont_country_birth IS NULL)
                OR (f.cont_ident_ser IS NULL OR f.cont_ident_num IS NULL)
                OR (f.cont_ident_brief IN ('PASS_RF', 'PASS_SSSR') AND (f.cont_ident_place_of_issue IS NULL OR 
                                                                        f.cont_ident_issue_date IS NULL))
               )
          )
      );

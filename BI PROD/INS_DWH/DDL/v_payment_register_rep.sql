CREATE OR REPLACE VIEW INS_DWH.V_PAYMENT_REGISTER_REP AS
SELECT DISTINCT pr.PAYMENT_REGISTER_ITEM_ID "��"
                ,pr.DUE_DATE "���� ��"
                ,pr.NUM "����� ��"
                ,pr.TITLE "��� ��"
                ,pr.collection_metod_desc "������ ������"
                ,pr.paym_term "��� ��������"
                ,pr.PAYMENT_CURRENCY "������ �������"
                ,pr.AMOUNT "����� �������"
                ,pr.SET_OFF_AMOUNT "����� �������"
                ,CASE
                  WHEN nvl(pr.PAYMENT_SUM, 0) = 0 THEN
                   1
                  ELSE
                   pr.PAYMENT_SUM
                END "����� �������"
                ,pr.sum2setoff "����� �������� �������"
                ,pr.CONTACT_NAME "����������"
                ,pr.POL_SER "����� ��"
                ,pr.POL_NUM "����� ��"
                ,pr.PAYER_FIO "����������"
                ,pr.TERRITORY "������"
                ,pr.PAYMENT_PURPOSE "����������"
                ,pr.ADD_INFO "�������������� ����"
                ,pr.set_off_state_descr "������ ������ ���������"
                ,decode(pr.STATUS
                      ,0
                      ,'�����'
                      ,10
                      ,'������� ���������'
                      ,20
                      ,'������������� �� ���������'
                      ,30
                      ,'�������������� �� �����'
                      ,40
                      ,'�������'
                      ,50
                      ,'��������� �������������'
                      ,60
                      ,'��������� ������������'
                      ,70
                      ,'����������'
                      ,-1
                      ,'<none>') "������ �������� �������"
                ,pr.RECOGNIZE_DATA "���� �������������"
                ,pr.NOTE "�����������"
                ,pr.num_ids "���"
                ,pr.b_pol_num "����� ������"
                ,pr.num_ser "����� �����"
                ,pr.start_date_dog "���� ������ �����������"
                ,decode(nvl(pr.is_group_flag, 0)
                      ,1
                      ,'���������'
                      ,'��������������') "������� ���������� ��������"
                ,(SELECT pp_l.start_date
                   FROM ins.p_policy pp_l
                  WHERE pp_l.policy_id =
                        ins.pkg_policy.get_last_version(nvl(pr.ph_id, ph.policy_header_id))) lv_start_date
                ,(SELECT pp_l.decline_date
                   FROM ins.p_policy pp_l
                  WHERE pp_l.policy_id =
                        ins.pkg_policy.get_last_version(nvl(pr.ph_id, ph.policy_header_id))) lv_decline_date
                ,(SELECT ins.doc.get_doc_status_name(pp_l.policy_id)
                   FROM ins.p_policy pp_l
                  WHERE pp_l.policy_id =
                        ins.pkg_policy.get_last_version(nvl(pr.ph_id, ph.policy_header_id))) lv_status
                ,ph.Ids
                ,pr.ph_id
                ,pr.PAYMENT_REGISTER_ITEM_ID
                ,pr.AC_PAYMENT_ID
                ,CASE
                  WHEN NVL((SELECT bac.account_nr || ' � ' || bac.bank_name company_bank_acc_name
                             FROM ins.ven_ac_payment      ac
                                 ,ins.cn_contact_bank_acc bac
                            WHERE ac.payment_id = pr.AC_PAYMENT_ID
                              AND ac.company_bank_acc_id = bac.id)
                          ,'X') = 'X' THEN
                   (CASE
                     WHEN NVL(pr.xx_receiver_account, 'X') = 'X' THEN
                      ''
                     ELSE
                      pr.xx_receiver_account || ' � ' || pr.xx_receiver_bank_name
                   END)
                  ELSE
                   (SELECT bac.account_nr || ' � ' || bac.bank_name company_bank_acc_name
                      FROM ins.ven_ac_payment      ac
                          ,ins.cn_contact_bank_acc bac
                     WHERE ac.payment_id = pr.AC_PAYMENT_ID
                       AND ac.company_bank_acc_id = bac.id)
                END "���� ��������"
                ,CASE
                  WHEN NVL(pr.xx_receiver_account, 'X') = 'X' THEN

                   (CASE
                     WHEN NVL((SELECT bac.account_nr || ' � ' || bac.bank_name company_bank_acc_name
                                FROM ins.ven_ac_payment      ac
                                    ,ins.cn_contact_bank_acc bac
                               WHERE ac.payment_id = pr.AC_PAYMENT_ID
                                 AND ac.company_bank_acc_id = bac.id)
                             ,'X') = 'X' THEN
                      ''
                     ELSE
                      (SELECT bac.account_nr || ' � ' || bac.bank_name company_bank_acc_name
                         FROM ins.ven_ac_payment      ac
                             ,ins.cn_contact_bank_acc bac
                        WHERE ac.payment_id = pr.AC_PAYMENT_ID
                          AND ac.company_bank_acc_id = bac.id)
                   END)

                  ELSE
                   pr.xx_receiver_account || ' � ' || pr.xx_receiver_bank_name
                END "���� �������� XX"
                ,pr.PAYMENT_ID
                ,pr.IDS "���, ����������� ������"
                ,pr.dep_name "���������"
                ,pr.ag_name "�����"
                ,pr.leader_name "������������"
                ,pr.a7_due_date "���� �7/��4"
                ,pr.a7_num "����� �7/��4"
                ,nvl(nvl(to_char(pr.IDS)
                       ,nvl(to_char(pr.num_ids)
                           ,nvl(to_char(ph.Ids), nvl(substr(pr.NOTE, 48, 10), '0'))))
                   ,'0') "���������� ���"
                ,

                ins.pkg_policy.get_last_version_status((SELECT pph.policy_header_id
                                                         FROM ins.p_pol_header pph
                                                        WHERE pph.ids = to_number(decode(TRANSLATE(UPPER(nvl(nvl(to_char(pr.IDS)
                                                                                                                ,nvl(to_char(pr.num_ids)
                                                                                                                    ,nvl(to_char(ph.Ids)
                                                                                                                        ,nvl(substr(pr.NOTE
                                                                                                                                   ,48
                                                                                                                                   ,10)
                                                                                                                            ,'0'))))
                                                                                                            ,'0'))
                                                                                                  ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ�����Ũ�������������������������| '
                                                                                                  ,' ')
                                                                                        ,nvl(nvl(to_char(pr.IDS)
                                                                                                ,nvl(to_char(pr.num_ids)
                                                                                                    ,nvl(to_char(ph.Ids)
                                                                                                        ,nvl(substr(pr.NOTE
                                                                                                                   ,48
                                                                                                                   ,10)
                                                                                                            ,'0'))))
                                                                                            ,'0')
                                                                                        ,to_number(nvl(nvl(to_char(pr.IDS)
                                                                                                          ,nvl(to_char(pr.num_ids)
                                                                                                              ,nvl(to_char(ph.Ids)
                                                                                                                  ,nvl(substr(pr.NOTE
                                                                                                                             ,48
                                                                                                                             ,10)
                                                                                                                      ,'0'))))
                                                                                                      ,'0'))
                                                                                        ,0)))) "������ ��������� ������"
                ,ins.doc.get_doc_status_name((SELECT pph.policy_id
                                              FROM ins.p_pol_header pph
                                             WHERE pph.ids = to_number(decode(TRANSLATE(UPPER(nvl(nvl(to_char(pr.IDS)
                                                                                                     ,nvl(to_char(pr.num_ids)
                                                                                                         ,nvl(to_char(ph.Ids)
                                                                                                             ,nvl(substr(pr.NOTE
                                                                                                                        ,48
                                                                                                                        ,10)
                                                                                                                 ,'0'))))
                                                                                                 ,'0'))
                                                                                       ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ�����Ũ�������������������������| '
                                                                                       ,' ')
                                                                             ,nvl(nvl(to_char(pr.IDS)
                                                                                     ,nvl(to_char(pr.num_ids)
                                                                                         ,nvl(to_char(ph.Ids)
                                                                                             ,nvl(substr(pr.NOTE
                                                                                                        ,48
                                                                                                        ,10)
                                                                                                 ,'0'))))
                                                                                 ,'0')
                                                                             ,to_number(nvl(nvl(to_char(pr.IDS)
                                                                                               ,nvl(to_char(pr.num_ids)
                                                                                                   ,nvl(to_char(ph.Ids)
                                                                                                       ,nvl(substr(pr.NOTE
                                                                                                                  ,48
                                                                                                                  ,10)
                                                                                                           ,'0'))))
                                                                                           ,'0'))
                                                                             ,0)))
                                           ,to_date('31-12-2999', 'dd-mm-yyyy')) "������ �������� ������"
                ,pr.epg_amount "����� � ������"
                ,pr.epg_due_date "���� ���"
                ,pr.pay_amount "����� �� ���."
                ,pr.part_pay_amount "����. �� ���."
                ,pr.COMMISSION "����� ��������"
                ,pr.reg_date
                ,pr.DOC_NUM "����-��"
                ,pr.PAYMENT_DATA "���� �������"
                ,pr.reg_item_coll_method_name "��� ��������"
  FROM ins_dwh.V_PAYMENT_REGISTER pr
  LEFT OUTER JOIN ins.p_pol_header ph
    ON to_char(ph.Ids) = substr(pr.NOTE, 48, 10)
 WHERE pr.DUE_DATE BETWEEN (SELECT param_value
                              FROM ins_dwh.rep_param
                             WHERE rep_name = 'pay_reg'
                               AND param_name = 'start_date')
   AND (SELECT param_value
          FROM ins_dwh.rep_param
         WHERE rep_name = 'pay_reg'
           AND param_name = 'end_date')
   AND (pr.contact_name != '��� "��� ����"' AND EXISTS
        (SELECT NULL
           FROM ins_dwh.rep_param
          WHERE rep_name = 'pay_reg'
            AND param_name = 'without_hcb'
            AND upper(param_value) = '��') OR EXISTS
        (SELECT NULL
           FROM ins_dwh.rep_param
          WHERE rep_name = 'pay_reg'
            AND param_name = 'without_hcb'
            AND upper(param_value) != '��'))
   AND (pr.contact_name != '������������ ���� ���������� ������' AND EXISTS
        (SELECT NULL
           FROM ins_dwh.rep_param
          WHERE rep_name = 'pay_reg'
            AND param_name = 'without_rcb'
            AND upper(param_value) = '��') OR EXISTS
        (SELECT NULL
           FROM ins_dwh.rep_param
          WHERE rep_name = 'pay_reg'
            AND param_name = 'without_rcb'
            AND upper(param_value) != '��'));

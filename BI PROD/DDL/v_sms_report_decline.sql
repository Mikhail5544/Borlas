CREATE OR REPLACE FORCE VIEW V_SMS_REPORT_DECLINE AS
SELECT holder,
       pol_ser,
       pol_num,
       ids,
       confirm_date,
       decline_date,
       issuer_return_sum,
       act_date,
       tel_number,
       bank_name,
       account_contact,
       CASE WHEN account_contact IS NOT NULL THEN
         'Уважаемый клиент! Для получения причитающейся к выплате суммы просим Вас направить в адрес Общества: 115114, г. Москва, Дербеневская наб., д.7, стр. 22, копии страниц документа, удостоверяющего личность, с личными данными и адресом регистрации. Ренессанс Жизнь, 88002005433'
       ELSE
         'Уважаемый клиент! Для получения причитающейся к выплате суммы просим Вас направить в адрес Общества: 115114, г. Москва, Дербеневская наб., д.7, стр. 22, Ваши полные банковские реквизиты и копии страниц документа, удостоверяющего личность с личными данными и адресом регистрации. Ренессанс Жизнь, 88002005433'
       ENd text_sms
FROM
(
select cpol.obj_name_orig holder,
       pol.pol_ser,
       pol.pol_num,
       ph.ids,
       pol.confirm_date,
       pol.decline_date,
       decl.issuer_return_sum,
       decl.act_date,
       (SELECT tel.telephone_number
        FROM ins.cn_contact_telephone tel,
             ins.t_telephone_type t
        WHERE tel.status = 1
          AND tel.control = 0
          AND tel.telephone_type = t.id
          AND t.brief = 'MOBIL'
          AND NVL(TRIM(tel.telephone_number),'X') != 'X'
          AND tel.contact_id = cpol.contact_id
          AND ROWNUM = 1
        ) tel_number,
        (SELECT ac.bank_name
         FROM ins.cn_contact_bank_acc ac,
              ins.cn_document_bank_acc dc,
              ins.document d,
              ins.doc_status_ref r
         WHERE ac.contact_id = cpol.contact_id
           AND ac.id = dc.cn_contact_bank_acc_id
           AND dc.cn_document_bank_acc_id = d.document_id
           AND d.doc_status_ref_id = r.doc_status_ref_id
           AND r.brief = 'ACTIVE'
           AND ac.used_flag = 1) bank_name,
        (SELECT CASE WHEN ac.account_nr IS NULL
                      THEN (CASE WHEN ac.account_corr IS NULL THEN '' ELSE 'Банковская карта'||ac.account_corr END)
                     ELSE 'Расчетный счет '||ac.account_nr
                END
         FROM ins.cn_contact_bank_acc ac,
              ins.cn_document_bank_acc dc,
              ins.document d,
              ins.doc_status_ref r
         WHERE ac.contact_id = cpol.contact_id
           AND ac.id = dc.cn_contact_bank_acc_id
           AND dc.cn_document_bank_acc_id = d.document_id
           AND d.doc_status_ref_id = r.doc_status_ref_id
           AND r.brief = 'ACTIVE'
           AND ac.used_flag = 1) account_contact
from ins.p_pol_header ph,
     ins.t_product prod,
     ins.p_policy pol,
     ins.document da,
     ins.doc_status_ref rf,
     ins.t_contact_pol_role polr,
     ins.p_policy_contact pcnt,
     ins.contact cpol,
     ins.p_pol_decline decl
where pol.policy_id = ph.last_ver_id
      and ph.product_id = prod.product_id
      and polr.brief = 'Страхователь'
      and da.document_id = pol.policy_id
      AND da.doc_status_ref_id = rf.doc_status_ref_id
      AND rf.brief = 'QUIT_REQ_QUERY'
      and pcnt.policy_id = pol.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      /*AND ph.ids = 6680055647*/
      AND EXISTS (SELECT NULL
                  FROM ins.cn_contact_telephone tel,
                       ins.t_telephone_type t
                  WHERE tel.status = 1
                    AND tel.control = 0
                    AND tel.telephone_type = t.id
                    AND t.brief = 'MOBIL'
                    AND NVL(TRIM(tel.telephone_number),'X') != 'X'
                    AND tel.contact_id = cpol.contact_id
                        )
      AND pol.policy_id = decl.p_policy_id
      AND decl.issuer_return_date IS NULL
      AND NOT EXISTS (SELECT NULL
                      FROM ins.c_claim_header cl
                      WHERE cl.p_policy_id = pol.policy_id)
);


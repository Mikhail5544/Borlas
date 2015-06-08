CREATE OR REPLACE VIEW V_COMPANY_INFO AS
SELECT c.contact_id
      ,CASE e.brief
         WHEN 'тк' THEN
          ' '
         WHEN 'чк' THEN
          ' '
         ELSE
          e.brief
       END AS company_type
      ,ent.obj_name(ent.id_by_brief('CONTACT'), c.contact_id) AS company_name
      ,nvl((SELECT df.okpo FROM t_contact_doc_fon df WHERE df.contact_id = c.contact_id), '') AS okpo
      ,nvl((SELECT df.ogrn FROM t_contact_doc_fon df WHERE df.contact_id = c.contact_id), '') AS ogrn
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('KPP')
              AND cci.contact_id = c.contact_id
              AND rownum = 1)
          ,' ') AS kpp
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('INN')
              AND cci.contact_id = c.contact_id
              AND rownum = 1)
          ,' ') AS inn
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('BIK')
              AND cci.contact_id = c.contact_id
              AND rownum = 1)
          ,' ') AS bik
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ins.ven_cn_contact_ident cci
                 ,ins.ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('KORR')
              AND cci.contact_id = c.contact_id
              AND rownum = 1)
          ,' ') AS cor_account
      ,nvl(ent.obj_name(ent.id_by_brief('CONTACT'), ccba.bank_id), ' ') AS bank_name
       
      ,ccba.account_nr AS account_number --
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ins.ven_cn_contact_ident cci
                 ,ins.ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('KORR')
              AND cci.contact_id = c.contact_id
              AND rownum = 1)
          ,' ') AS account_corr --
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('KORR')
              AND cci.contact_id = ccba.bank_id
              AND rownum = 1)
          ,' ') AS b_kor_account
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('BIK')
              AND cci.contact_id = ccba.bank_id
              AND rownum = 1)
          ,' ') AS b_bic
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('OKPO')
              AND cci.contact_id = ccba.bank_id
              AND rownum = 1)
          ,'') AS b_okpo
      ,nvl((SELECT CASE cci.serial_nr
                    WHEN NULL THEN
                     cci.id_value
                    ELSE
                     cci.serial_nr || ' ' || cci.id_value
                  END AS company_bank_req
             FROM ven_cn_contact_ident cci
                 ,ven_t_id_type        it
            WHERE cci.id_type = it.id
              AND it.brief IN ('OGRN')
              AND cci.contact_id = ccba.bank_id
              AND rownum = 1)
          ,'') AS b_ogrn
      ,pkg_contact_rep_utils.get_address(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                         ,'LEGAL')) AS legal_address
      ,nvl((SELECT ent.obj_name(cca.ent_id, cca.id)
             FROM ven_cn_contact_address cca
                 ,ven_t_address_type     tat
            WHERE cca.contact_id = c.contact_id
              AND tat.brief = 'FACT'
              AND tat.id = cca.address_type
              AND rownum = 1)
          ,' ') AS fact_address
      ,nvl((SELECT ent.obj_name(cca.ent_id, cca.id) AS address
             FROM ven_cn_contact_address cca
                 ,ven_t_address_type     tat
            WHERE cca.contact_id = c.contact_id
              AND tat.brief = 'POSTAL'
              AND tat.id = cca.address_type
              AND rownum = 1)
          ,' ') AS postal_address
      ,nvl(pkg_contact.get_phone_number(c.contact_id, 'WORK')
          ,pkg_contact.get_phone_number(c.contact_id, 'CONT')) AS phone
      ,pkg_contact.get_phone_number(c.contact_id, 'FAX') AS fax
      ,pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(c.contact_id
                                                                                                  ,'LICENSE_FSSN')
                                                     ,'<#DOC_SER> ╧ <DOC_NUM>') AS licence_number
      ,pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(c.contact_id
                                                                                                  ,'LICENSE_FSSN')
                                                     ,'<#DOC_DATE>') AS licence_date
      ,nvl((SELECT ent.obj_name(ent.id_by_brief('CONTACT'), v.contact_id_a)
             FROM ven_cn_contact_rel v
                 ,t_contact_rel_type t
            WHERE v.contact_id_b = c.contact_id
              AND v.relationship_type = t.reverse_relationship_type
              AND upper(t.brief) = upper('GM'))
          ,' ') AS chief_name
      ,decode(bct.brief
             ,'чк'
             ,' '
             ,CASE
                WHEN nvl(ent.obj_name(ent.id_by_brief('CONTACT'), ccba.bank_id), ' ') NOT LIKE
                     bct.brief || ' %' THEN
                 bct.brief
              END) AS bank_company_type
      ,pkg_contact.get_emales(c.contact_id) emails
      ,ccba.bank_id AS bank_id

  FROM contact             c
      ,t_contact_type      e
      ,t_contact_type      ep
      ,cn_contact_bank_acc ccba
      ,t_contact_type      bct
      ,contact             bc
 WHERE c.contact_type_id = e.id
   AND e.upper_level_id = ep.id
   AND ep.brief = 'чк'
   AND bc.contact_id(+) = ccba.bank_id
   AND bct.id(+) = bc.contact_type_id
   AND ccba.contact_id(+) = c.contact_id
   AND c.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
   AND ccba.used_flag = 1;

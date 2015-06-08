CREATE OR REPLACE VIEW INS.V_POLICY_SUMMARY AS
SELECT ph.ids
      ,pp.policy_id
      ,ph.policy_header_id
      ,ph.product_id
      ,pt.description payment_terms_desc
      ,p.description period_desc
      ,c.contact_id assured_contact_id
      ,(SELECT g.description FROM t_gender g WHERE g.id = cp.gender) AS assured_gender
      ,c.obj_name_orig assured_contact_name
      ,c.name assured_last_name
      ,c.first_name assured_first_name
      ,c.middle_name assured_middle_name
      ,cp.date_of_birth assuerd_date_of_birth
      ,pkg_contact.get_primary_zip(c.contact_id) assured_zip
      ,nvl(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id, 'FK_CONST')
          ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id, 'CONST')) assured_reg_address_id
      ,pkg_contact_rep_utils.get_address(nvl(pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                             ,'FK_CONST')
                                            ,pkg_contact_rep_utils.get_last_active_address_id(c.contact_id
                                                                                             ,'CONST'))) AS assured_reg_address
      ,REPLACE(pkg_contact.get_primary_doc(c.contact_id)
              ,'Паспорт гражданина РФ'
              ,'Паспорт') assured_passport
      ,nvl(pkg_contact.get_citizenry(c2.contact_id)
          ,pkg_contact.get_contact_ident_doc_by_type(c2.contact_id, 'INN')) AS assured_citizenry_inn
      ,(SELECT NAME FROM cn_address ca WHERE ca.id = pkg_contact.get_ltrs_address(c.contact_id)) assured_letters_address
      ,pkg_contact.get_phone_number(c.contact_id, 'HOME') assured_home_tel
      ,pkg_contact.get_phone_number(c.contact_id, 'MOBIL') assured_mob_tel
      ,pkg_contact.get_emales(c.contact_id) assured_emails
      ,c.is_public_contact assured_is_public_contact
      ,c2.contact_id insuree_contact_id
      ,(SELECT g.description FROM t_gender g WHERE g.id = cp2.gender) AS insuree_gender
      ,c2.obj_name_orig insuree_contact_name
      ,cp2.date_of_birth insuree_date_of_birth
      ,ct.description insuree_contact_type
      ,ct.brief insuree_contact_type_brief
      ,pkg_contact.get_primary_zip(c2.contact_id) insuree_zip
      ,nvl(pkg_contact_rep_utils.get_last_active_address_id(c2.contact_id, 'FK_CONST')
          ,pkg_contact_rep_utils.get_last_active_address_id(c2.contact_id, 'CONST')) insuree_reg_address_id
      ,pkg_contact_rep_utils.get_address(nvl(pkg_contact_rep_utils.get_last_active_address_id(c2.contact_id
                                                                                             ,'FK_CONST')
                                            ,pkg_contact_rep_utils.get_last_active_address_id(c2.contact_id
                                                                                             ,'CONST'))) insuree_reg_address
      ,REPLACE(
               case when ct.brief in ('ФЛ', 'ПБОЮЛ') then
                 pkg_contact.get_primary_doc(c2.contact_id)
               else
                 (
                  select vtc.dd
                  from v_temp_company vtc
                  where vtc.contact_id = c2.contact_id
                 )
               end
              ,'Паспорт гражданина РФ'
              ,'Паспорт') insuree_passport
      ,nvl(pkg_contact.get_citizenry(c2.contact_id)
          ,pkg_contact.get_contact_ident_doc_by_type(c2.contact_id, 'INN')) AS insuree_citizenry_inn
      ,(SELECT NAME FROM cn_address ca WHERE ca.id = pkg_contact.get_ltrs_address(c2.contact_id)) insuree_letters_address
      ,pkg_contact.get_phone_number(c2.contact_id, 'HOME') insuree_home_tel
      ,pkg_contact.get_phone_number(c2.contact_id, 'MOBIL') insuree_mob_tel
      ,c2.is_public_contact insuree_is_public_contact
      ,pp.ins_amount
      ,pp.premium
      ,ph.start_date
      ,pp.end_date
      ,pp.sign_date
      ,pp.pol_num
      ,pp.pol_ser
      ,doc.get_last_doc_status_name(pp.policy_id) status
      ,(SELECT f.brief FROM fund f WHERE f.fund_id = ph.fund_id) currency_code
      ,(SELECT f.name FROM fund f WHERE f.fund_id = ph.fund_id) currency_desc
      ,(SELECT pf.t_policy_form_name
          FROM t_policy_form        pf
              ,t_policyform_product pfp
         WHERE pp.t_product_conds_id = pfp.t_policyform_product_id
           AND pfp.t_policy_form_id = pf.t_policy_form_id) policy_form
      ,aas.credit_account_number
  FROM p_policy        pp
      ,p_pol_header    ph
      ,v_pol_issuer    pi
      ,as_asset        aa
      ,as_assured      aas
      ,contact         c
      ,cn_person       cp
      ,t_payment_terms pt
      ,t_period        p
      ,contact         c2
      ,cn_person       cp2
      ,cn_company      com2
      ,t_contact_type  ct
 WHERE pp.pol_header_id = ph.policy_header_id
   AND pp.policy_id = pi.policy_id
   AND pp.policy_id = aa.p_policy_id
   AND aa.as_asset_id = aas.as_assured_id
   AND aas.assured_contact_id = c.contact_id
   AND c.contact_id = cp.contact_id
   AND pp.payment_term_id = pt.id
   AND pp.period_id = p.id
   AND pi.contact_id = c2.contact_id
   AND c2.contact_id = cp2.contact_id(+)
   AND c2.contact_id = com2.contact_id(+)
   AND c2.contact_type_id = ct.id(+);

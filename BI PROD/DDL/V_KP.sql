CREATE OR REPLACE VIEW V_KP AS
SELECT agh.num,
       c.obj_name_orig agent_name,
       (SELECT rf.name
        FROM ins.doc_status_ref rf
        WHERE rf.doc_status_ref_id = dpad.doc_status_ref_id
        ) st_agent_pol,
        depa.name department_header,
        dep.name department_agent,
        ph.ids,
        pol.pol_num,
        pol.notice_num,
        cpol.obj_name_orig insurer,
        (SELECT tel.telephone_number FROM ins.cn_contact_telephone tel WHERE tel.contact_id = cpol.contact_id AND tel.telephone_type = 1) tel1,--"Личный"
        (SELECT tel.telephone_number FROM ins.cn_contact_telephone tel WHERE tel.contact_id = cpol.contact_id AND tel.telephone_type = 2) tel2,--"Рабочий"
        (SELECT tel.telephone_number FROM ins.cn_contact_telephone tel WHERE tel.contact_id = cpol.contact_id AND tel.telephone_type = 3) tel3,--"Домашний"
        (SELECT tel.telephone_number FROM ins.cn_contact_telephone tel WHERE tel.contact_id = cpol.contact_id AND tel.telephone_type = 4) tel4,--"Мобильный"
        (SELECT tel.telephone_number FROM ins.cn_contact_telephone tel WHERE tel.contact_id = cpol.contact_id AND tel.telephone_type = 181) tel5,--"Контактный"
        prod.description product,
        ph.start_date,
        (SELECT trm.description FROM ins.t_payment_terms trm WHERE trm.id = pol.payment_term_id) per,
        pol.premium,
        (SELECT rf.name
         FROM ins.doc_status_ref rf
         WHERE rf.doc_status_ref_id = dpol.doc_status_ref_id) st_pol_act,
        pkg_policy.get_last_version_status(ph.policy_header_id) st_pol,
        (SELECT MIN(a.plan_date)
        FROM DOCUMENT d,
             AC_PAYMENT a,
             DOC_TEMPL dt,
             DOC_DOC dd,
             P_POLICY p,
             CONTACT c
        WHERE d.document_id = a.payment_id AND
              d.doc_templ_id = dt.doc_templ_id AND
              dt.brief = 'PAYMENT' AND
              dd.child_id = d.document_id AND
              dd.parent_id = p.policy_id AND
              a.contact_id = c.contact_id AND
              d.doc_status_ref_id IN (SELECT rf.doc_status_ref_id
                                     FROM ins.doc_status_ref rf
                                     WHERE rf.brief IN ('NEW','TO_PAY')
                                     )
              AND p.pol_header_id = ph.policy_header_id) plan_date,
        (SELECT count(a.payment_id)
        FROM DOCUMENT d,
             AC_PAYMENT a,
             DOC_TEMPL dt,
             DOC_DOC dd,
             P_POLICY p,
             CONTACT c
        WHERE d.document_id = a.payment_id AND
              d.doc_templ_id = dt.doc_templ_id AND
              dt.brief = 'PAYMENT' AND
              dd.child_id = d.document_id AND
              dd.parent_id = p.policy_id AND
              a.contact_id = c.contact_id AND
              d.doc_status_ref_id = (SELECT rf.doc_status_ref_id
                                     FROM ins.doc_status_ref rf
                                     WHERE rf.brief = 'PAID'
                                     )
              AND p.pol_header_id = ph.policy_header_id) kol
FROM ins.p_policy_agent_doc pad,
     ins.document dpad,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_contract ag,
     ins.department dep,
     ins.p_pol_header ph,
     ins.department depa,
     ins.p_policy pol,
     ins.document dpol,
     ins.t_contact_pol_role polr,
     ins.p_policy_contact pcnt,
     ins.contact cpol,
     ins.t_product prod
WHERE agh.agent_id = c.contact_id
      AND agh.last_ver_id = ag.ag_contract_id
      AND ag.agency_id = dep.department_id
      AND pad.ag_contract_header_id = agh.ag_contract_header_id
      AND dpad.document_id = pad.p_policy_agent_doc_id
      AND dpad.doc_status_ref_id IN (SELECT rf.doc_status_ref_id
                                     FROM ins.doc_status_ref rf
                                     WHERE rf.brief IN ('CANCEL','CURRENT')
                                     )
      /*AND c.obj_name_orig = 'Авдеев Михаил Азариевич'*/
      AND pad.policy_header_id = ph.policy_header_id
      AND ph.agency_id = depa.department_id(+)
      AND pol.policy_id = ph.policy_id
      AND polr.brief = 'Страхователь'
      AND pcnt.policy_id = pol.policy_id
      AND pcnt.contact_policy_role_id = polr.id
      AND cpol.contact_id = pcnt.contact_id
      AND ph.product_id = prod.product_id
      AND dpol.document_id = pol.policy_id;

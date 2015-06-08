CREATE OR REPLACE VIEW V_NEW_POLICY AS
SELECT sc.description     "Канал продаж",
       pp.notice_ser      "Серия заявления",
       pp.notice_num      "Номер заявления",
       ph.ids,
       ent.obj_name('CONTACT',con.contact_id)   "Страхователь",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агентство агента",
       ach.num                                  "Номер АД",
       ent.obj_name('CONTACT',ach.agent_id)     "ФИО Агента",
       ag_lead.num                                 "Номер АД Руководителя",
       ent.obj_name('CONTACT',ag_lead.agent_id)    "ФИО Руководителя",
       tpt.description                          "Периодичность оплат",
       (select min(ap.grace_date)
          from p_policy   p2,
               ac_payment ap,
               document   d,
               doc_templ  dt,
               doc_doc    dd
         where dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = dd.child_id
           and ap.payment_number = 1
           and p2.pol_header_id = ph.policy_header_id
       ) "Дата 1 ЭПГ",
       tp.DESCRIPTION "Продукт",
       ph.start_date  "Дата начала ДС",
       pp.end_date    "Дата окончания ДС",
       ds.change_date "Дата статуса Проект",
       (select doc.get_doc_status_name(p2.policy_id)
         from p_policy p2
        where p2.policy_id = ph.last_ver_id
            /*p2.version_num = (select max(p3.version_num)
                                  from p_policy p3
                                 where p3.pol_header_id = p2.pol_header_id
                               )*/
          and p2.pol_header_id = ph.policy_header_id
       ) "Статус последней версии",
       (select wmsys.wm_concat(ttt.DESCRIPTION||'/'||tc.description||'/'||tcc.description||'/'||ct.telephone_prefix||'/'||
               ct.telephone_number||'/'||ct.telephone_extension)
          from cn_contact_telephone ct,
               t_telephone_type     ttt,
               t_country_dial_code  tcc,
               t_country            tc
         where ct.telephone_type = ttt.ID
           and tcc.id = ct.country_id
           and tc.id = tcc.country_id
           and ct.contact_id = con.contact_id --Страхователь
       )"Тип/Страна/код/преф/тел/доб",
       (select wmsys.wm_concat(et.description||' - '||ce.email)
          from cn_contact_email ce,
               t_email_type     et
         where ce.contact_id = con.contact_id
           and et.id = ce.email_type
       )"e-mail страхователя",
       (select  wmsys.wm_concat(ca.address_name|| ' ')
          from v_cn_contact_address ca
         where ca.contact_id = con.contact_id
           and ca.is_default = 1
       ) "Адрес страхователя"
  FROM
       p_policy               pp,
       p_pol_header           ph,
       p_policy_agent         pa,
       Policy_Agent_Status    psa,
       ven_ag_contract_header ach,
       ag_contract            ac,
       (select ac2.ag_contract_id,
               ach2.num,
               ach2.agent_id
          from ven_ag_contract_header ach2,
               ag_contract            ac2
         where ach2.ag_contract_header_id = ac2.contract_id
       ) ag_lead,
       t_sales_channel        sc,
       t_payment_terms        tpt,
       t_product              tp,
       contact                con,
       doc_status             ds,
       doc_status_ref         dsr,
       doc_status_ref         dsr_src
 WHERE pp.pol_header_id = ph.policy_header_id
   and pp.version_num = 1
   and pa.policy_header_id = ph.policy_header_id
   and ach.ag_contract_header_id = pa.ag_contract_header_id
   and psa.policy_agent_status_id = pa.status_id
   and psa.brief = 'CURRENT'
   AND ac.ag_contract_id = Pkg_Agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
   and ag_lead.ag_contract_id (+) = ac.contract_leader_id
   and sc.id = ph.sales_channel_id
   and tpt.id = pp.payment_term_id
   AND ph.product_id = tp.product_id
   and con.contact_id = pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')
   and ds.document_id = pp.policy_id
   and dsr.doc_status_ref_id = ds.doc_status_ref_id
   and dsr.brief = 'PROJECT'
   and dsr_src.doc_status_ref_id = ds.src_doc_status_ref_id
   and dsr_src.brief = 'NULL' --<Документ добавлен>
   --and ph.policy_header_id = 6311666
   and ds.change_date between (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'new_policy' and param_name = 'start_date')
                          and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'new_policy' and param_name = 'end_date');

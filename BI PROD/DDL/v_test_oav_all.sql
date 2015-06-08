CREATE OR REPLACE FORCE VIEW V_TEST_OAV_ALL AS
select agj.AG_CONTRACT_HEADER_ID as AG_CONTRACT_HEADER_ID,
       agj.AGENT_NAME,
       agj.NUM as ag,
       agj.STATUS_NAME as STATUS_NAME_agentskiy,
       agj.DATE_BEGIN,
       agj.DATE_END,
       agj.CATEGORY_NAME,
       agj.dep_name,
       hp.policy_id as policy_id,
       p.pol_ser,
       p.pol_num,
       Doc.get_doc_status_name(hp.policy_id) as status_name_policy,
       --pl.status_name as status_name_policy,
       rf.name as status_active,
       dss.start_date as date_status_active,
       p.start_date,
       p.end_date,
       p.ins_amount,
       p.premium,
       prod.brief as prod_desc,
      --pl.prod_desc,
       cont.name||' '||cont.first_name||' '||cont.middle_name as insurer_name,
       --pl.insurer_name,
       ff.brief as f_resp, --hp.fund_id
       fff.brief as f_pay, --hp.fund_pay_id
       ag.part_agent,
       st.name as status_name_agent_po_policy,
       ag.date_start as date_vstupl,
       ag.date_end as date_okonch,
       a.payment_id,
       a.payment_number,
       a.plan_date,
       ds.name_pl,
       dzp.name_pr,
       dz.num,
       az.due_date as date_pl,
       az.real_pay_date as real_date,
       k.s,
       k.date_pay as date_oplati_v_vedom,
       av.date_begin as date_begin_vedom,
       av.date_end as date_end_vedom

  from v_ag_contract_journal agj
       left join p_policy_agent ag on (ag.ag_contract_header_id = agj.ag_contract_header_id)
       left join p_pol_header hp on (hp.policy_header_id = ag.policy_header_id)
       left join p_policy p on (p.policy_id = hp.policy_id)

       left join t_product prod on (prod.product_id = hp.product_id)
       left join fund ff on (ff.fund_id = hp.fund_id)
       left join fund fff on (fff.fund_id = hp.fund_pay_id)
       left join p_policy_contact pins on (pins.policy_id = p.policy_id and pins.contact_policy_role_id = 6)
       left join contact cont ON cont.contact_id = pins.contact_id

       --left join v_policy_journal pl on (pl.policy_header_id = hp.policy_header_id)
       left join policy_agent_status st on (st.policy_agent_status_id = ag.status_id)


       left join (SELECT
                    p.pol_header_id,
                    p.policy_id,
                    d.document_id,
                    a.payment_number,
                    d.num,
                    a.due_date,
                    a.grace_date,
                    a.amount,
                    dd.parent_amount part_amount,
                    Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL) pay_amount,
                    Pkg_Payment.get_set_off_amount(d.document_id, p.pol_header_id,NULL) part_pay_amount,
                    a.contact_id,
                    c.obj_name_orig contact_name,
                    dsr.doc_status_ref_id,
                    dsr.name doc_status_ref_name,
                    a.plan_date,
                    a.payment_id
                  FROM
                    DOCUMENT d,
                    AC_PAYMENT a,
                    DOC_TEMPL dt,
                    DOC_DOC dd,
                    P_POLICY p,
                    CONTACT c,
                    DOC_STATUS ds,
                    DOC_STATUS_REF dsr
                  WHERE
                    d.document_id = a.payment_id
                    AND d.doc_templ_id = dt.doc_templ_id
                    AND dt.brief = 'PAYMENT'
                    AND dd.child_id = d.document_id
                    AND dd.parent_id = p.policy_id
                    AND a.contact_id = c.contact_id
                    AND ds.document_id = d.document_id
                    AND ds.start_date = (SELECT MAX(dss.start_date)
                                         FROM DOC_STATUS dss
                                         WHERE  dss.document_id = d.document_id
                                         )
                    AND dsr.doc_status_ref_id = ds.doc_status_ref_id) a on (a.pol_header_id = hp.policy_header_id)


       /*inner join doc_doc dd on (dd.parent_id = p.policy_id)
       inner join document d on (dd.child_id = d.document_id)
       inner join doc_templ dt on (dt.doc_templ_id = d.doc_templ_id and dt.brief = 'PAYMENT')
       inner join ac_payment a on (a.payment_id = d.document_id and a.payment_id = dd.child_id)*/
       left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)--
       left join document dz on (dz.document_id = dso.child_doc_id)
       left join ac_payment az on (dz.document_id = az.payment_id)

       left join contact ct on (a.contact_id = ct.contact_id)
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.document_id = ds.document_id )
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pr, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) dzp on (dz.document_id = dzp.document_id )

       left join agent_report rep on (ag.ag_contract_header_id = rep.ag_contract_h_id and t_ag_av_id= 41)
       left join ag_vedom_av av on (av.ag_vedom_av_id = rep.ag_vedom_av_id)
       left join (select sum(comission_sum) as s, c.agent_report_id, c.policy_id, c.date_pay --
                  from agent_report_cont c
                  group by c.agent_report_id,c.policy_id,c.date_pay) k on k.agent_report_id = rep.agent_report_id and a.policy_id = k.policy_id

       left join doc_status dss on (dss.document_id = p.policy_id and dss.doc_status_ref_id = 19)
       left join doc_status_ref rf on (dss.doc_status_ref_id = rf.doc_status_ref_id)
where --agj.ag_contract_header_id in (569369)
      --and p.policy_id = 2180452
      st.name not like 'ÎÒÌÅÍÅÍ'
      and av.date_begin >= to_date('01-06-2007','dd-mm-yyyy')
      --and a.payment_number < 10
      and nvl(a.plan_date,a.due_date) between to_date('01-05-2007','dd-mm-yyyy') and to_date('31-12-2008','dd-mm-yyyy')
;


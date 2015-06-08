CREATE OR REPLACE VIEW INS_DWH.V_CBNT_POLICY AS
select nvl(to_char(policy.policy_id), 'null') policy_id,
       nvl(to_char(policy.insured_id), 'null') insured_id,
       nvl(policy.product_name, 'null') product_name,
       nvl(policy.product_brief, 'null') product_brief,
       coalesce(to_char(policy.ids),policy.pol_num, 'null') pol_num,
       nvl(to_char(policy.fee), 'null') fee,
       nvl(to_char(policy.date_begin,'dd.mm.yyyy'), 'null') date_begin,
       nvl(to_char(policy.date_end,'dd.mm.yyyy'), 'null') date_end,
       nvl(to_char(policy.policy_header_id), 'null') policy_header_id,
       nvl(policy.payment_term, 'null') payment_term,
       nvl(policy.fund, 'null') fund,
       nvl(policy.status, 'null') status,
       nvl(to_char(policy.agent_id),'null') agent_id,
       nvl(to_char(policy.agency_id),'null') agency_id,
       nvl(to_char(policy.fee_index),'null') fee_index
      ,nvl(case
             when decline_date is null and policy.debt_sum != 0 then
                   to_char(policy.debt_sum)
           end,'null') as debt_sum
       --nvl(to_char(policy.debt_sum),'null') debt_sum
      ,nvl(cn.obj_name, 'null') agent_name,
       nvl(d.name, 'null') agency_name,
       nvl(null,'null') agency_address,
       nvl(null,'null') agency_phone,
       nvl(null,'null') indexing_persent,
       nvl(null,'null') invest_income
      ,nvl(case
             when decline_date is null then
               to_char(due_date,'dd.mm.yyyy')
           end
          ,'null') as due_date
      --nvl(to_char(due_date,'dd.mm.yyyy'),'null') as due_date
      ,nvl(to_char(decline_date,'dd.mm.yyyy'),'null') as decline_date
      ,nvl(decline_reason,'null') as decline_reason
      ,last_ver_policy_id
      ,last_ver_status
  from (select
         pol.policy_id
        ,pol.insured_id
        ,pol.product_name
        ,pol.product_brief
        ,pol.ids
        ,pol.pol_num
        ,pol.date_begin
        ,pol.date_end
        ,pol.policy_header_id
        ,pol.payment_term
        ,pol.fund
        ,case
           when pol.active_ver_status='UNDERWRITING' and last_ver.last_ver_status='NEW_CONDITION'
             or pol.active_ver_status='UNDERWRITING' and last_ver.last_ver_status='TO_AGENT_NEW_CONDITION'
             or pol.active_ver_status='UNDERWRITING' and last_ver.last_ver_status='UNDERWRITING'
             or pol.active_ver_status='UNDERWRITING' and last_ver.last_ver_status='PROJECT'
             or pol.active_ver_status='REVISION' and last_ver.last_ver_status='REVISION'
             or pol.active_ver_status='AGENT_REVISION' and last_ver.last_ver_status='AGENT_REVISION'
             or pol.active_ver_status='DOC_REQUEST' and last_ver.last_ver_status='DOC_REQUEST'
             or pol.active_ver_status='RE_REQUEST' and last_ver.last_ver_status='RE_REQUEST'
             or pol.active_ver_status='MED_OBSERV' and last_ver.last_ver_status='MED_OBSERV'
             or pol.active_ver_status='NONSTANDARD' and last_ver.last_ver_status='NONSTANDARD'
             or pol.active_ver_status='NEW_CONDITION' and last_ver.last_ver_status='NEW_CONDITION'
             or pol.active_ver_status='NEW' and last_ver.last_ver_status='NEW'
             or pol.active_ver_status='TO_AGENT_DS' and last_ver.last_ver_status='TO_AGENT_DS'
             or pol.active_ver_status='TO_AGENT_NEW_CONDITION' and last_ver.last_ver_status='TO_AGENT_NEW_CONDITION'
             or pol.active_ver_status='FROM_AGENT_DS' and last_ver.last_ver_status='FROM_AGENT_DS'
             or pol.active_ver_status='FROM_AGENT_NEW_CONDITION' and last_ver.last_ver_status='FROM_AGENT_NEW_CONDITION'
             or pol.active_ver_status='PROJECT' and last_ver.last_ver_status='PROJECT'
           then 'Выпуск полиса'
           when pol.active_ver_status='STOPED' and last_ver.last_ver_status='CURRENT'
             or pol.active_ver_status='PROJECT' and last_ver.last_ver_status='CURRENT'
             or pol.active_ver_status='ACTIVE' and last_ver.last_ver_status='ACTIVE'
             or pol.active_ver_status='ACTIVE' and last_ver.last_ver_status='INDEXATING'
             or pol.active_ver_status='ACTIVE' and last_ver.last_ver_status='PROJECT'
             or pol.active_ver_status='CURRENT' and last_ver.last_ver_status='CURRENT'
             or pol.active_ver_status='CURRENT' and last_ver.last_ver_status='INDEXATING'
             or pol.active_ver_status='CURRENT' and last_ver.last_ver_status='PROJECT'
             or pol.active_ver_status='CONCLUDED' and last_ver.last_ver_status='CONCLUDED'
             or pol.active_ver_status='INDEXATING' and last_ver.last_ver_status='INDEXATING'
             or pol.active_ver_status='PRINTED' and last_ver.last_ver_status='INDEXATING'
             or pol.active_ver_status='PRINTED' and last_ver.last_ver_status='PRINTED'
             or pol.active_ver_status='PASSED_TO_AGENT' and last_ver.last_ver_status='PASSED_TO_AGENT'
             or pol.active_ver_status='CONCLUDED' and last_ver.last_ver_status='INDEXATING'
             or pol.active_ver_status='PASSED_TO_AGENT' and last_ver.last_ver_status='INDEXATING'
           then 'Действует'
           when pol.active_ver_status='CURRENT' and last_ver.last_ver_status='STOPED'
             or pol.active_ver_status='STOPED' and last_ver.last_ver_status='STOPED'
           then 'Завершен'
           when pol.active_ver_status='CURRENT' and last_ver.last_ver_status='CANCEL'
             or pol.active_ver_status='STOPED' and last_ver.last_ver_status='CANCEL'
             or pol.active_ver_status='CANCEL' and last_ver.last_ver_status='CANCEL'
             or pol.active_ver_status='STOP' and last_ver.last_ver_status='STOP'
           then 'Отменен'
           when pol.active_ver_status='QUIT' and last_ver.last_ver_status='RECOVER'
             or pol.active_ver_status='QUIT' and last_ver.last_ver_status='PROJECT'
             or pol.active_ver_status='QUIT_REQ_QUERY' and last_ver.last_ver_status='QUIT_REQ_QUERY'
             or pol.active_ver_status='QUIT_REQ_GET' and last_ver.last_ver_status='QUIT_REQ_GET'
             or pol.active_ver_status='ACTIVE' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='ACTIVE' and last_ver.last_ver_status='BREAK'
             or pol.active_ver_status='UNDERWRITING' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='READY_TO_CANCEL' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='READY_TO_CANCEL' and last_ver.last_ver_status='PROJECT'
             or pol.active_ver_status='CURRENT' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='CONCLUDED' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='STOPED' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='DOC_REQUEST' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='TO_QUIT' and last_ver.last_ver_status='TO_QUIT'
             or pol.active_ver_status='TO_QUIT_CHECK_READY' and last_ver.last_ver_status='TO_QUIT_CHECK_READY'
             or pol.active_ver_status='TO_QUIT_CHECKED' and last_ver.last_ver_status='TO_QUIT_CHECKED'
             or pol.active_ver_status='MED_OBSERV' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='PRINTED' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='PRINTED' and last_ver.last_ver_status='BREAK'
             or pol.active_ver_status='NEW' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='NEW' and last_ver.last_ver_status='BREAK'
             or pol.active_ver_status='QUIT' and last_ver.last_ver_status='QUIT'
             or pol.active_ver_status='QUIT_TO_PAY' and last_ver.last_ver_status='QUIT_TO_PAY'
             or pol.active_ver_status='STOP' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='BREAK' and last_ver.last_ver_status='READY_TO_CANCEL'
             or pol.active_ver_status='BREAK' and last_ver.last_ver_status='BREAK'
             or pol.active_ver_status='RECOVER' and last_ver.last_ver_status='RECOVER'
             or pol.active_ver_status='QUIT' and last_ver.last_ver_status='RECOVER_DENY'
             or pol.active_ver_status='QUIT_DECL' and last_ver.last_ver_status='QUIT_DECL'
             or pol.active_ver_status='QUIT_REQ_QUERY' and last_ver.last_ver_status='RECOVER'
           then 'Расторгнут'
         end as status,
         (SELECT (SELECT agent_id
                    FROM ins.ag_contract_header ach
                   WHERE ach.ag_contract_header_id = ac.contract_id) agent_id

            FROM ins.ag_contract ac
           WHERE ac.category_id = 2
             AND ROWNUM = 1
           START WITH ac.ag_contract_id =
                      ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id,
                                                                                                   least(pol.date_end,
                                                                                                         sysdate),
                                                                                                   1),
                                                         least(pol.date_end,
                                                               sysdate))
          CONNECT BY NOCYCLE
           PRIOR (SELECT ac1.contract_id
                              FROM ins.ag_contract ac1
                             WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                      ac.contract_id
                 AND ac.ag_contract_id =
                     ins.pkg_agent_1.get_status_by_date(ac.contract_id,
                                                        least(pol.date_end,
                                                              sysdate))
                 AND ac.category_id <= 2) agent_id,

         (SELECT ac.agency_id
            FROM ins.ag_contract ac
           WHERE ac.category_id = 2
             AND ROWNUM = 1
           START WITH ac.ag_contract_id =
                      ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id,
                                                                                                   least(pol.date_end,
                                                                                                         sysdate),
                                                                                                   1),
                                                         least(pol.date_end,
                                                               sysdate))
          CONNECT BY NOCYCLE
           PRIOR (SELECT ac1.contract_id
                              FROM ins.ag_contract ac1
                             WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                      ac.contract_id
                 AND ac.ag_contract_id =
                     ins.pkg_agent_1.get_status_by_date(ac.contract_id,
                                                        least(pol.date_end,
                                                              sysdate))
                 AND ac.category_id <= 2) agency_id,

         case ins.doc.get_doc_status_name(last_ver.policy_id, sysdate)
           when 'Индексация' then
            (select round(sum(pc.fee), 2)
               from ins.p_cover pc, ins.as_asset a, ins.p_policy pp
              where pp.policy_id = a.p_policy_id
                and a.as_asset_id = pc.as_asset_id
                and pp.policy_id = last_ver.policy_id)
         end fee_index
        ,(select round(sum(pc.fee), 2)
            from ins.p_cover pc, ins.as_asset a, ins.p_policy pp
           where pp.policy_id  = a.p_policy_id
             and a.as_asset_id = pc.as_asset_id
             and pp.policy_id  = pol.policy_id) as fee
        ,(select nvl(sum(ac.amount - nvl(ins.pkg_payment.get_set_off_amount(ac.payment_id, pol.policy_header_id, null),0)),0)
                  from ins.ac_payment     ac
                      ,ins.doc_doc        dd
                      ,ins.p_policy       pp
                      ,ins.document       dc
                      ,ins.doc_status_ref dsr
                      ,ins.doc_templ      dt
                 where pp.pol_header_id     = pol.policy_header_id
                   and pp.policy_id         = dd.parent_id
                   and dd.child_id          = ac.payment_id
                   and ac.payment_id        = dc.document_id
                   and dc.doc_templ_id      = dt.doc_templ_id
                   and dc.doc_status_ref_id = dsr.doc_status_ref_id
                   and dt.brief             = 'PAYMENT'
                   and ac.plan_date        >= to_date('01.01.2010', 'dd.mm.yyyy')
                   and ac.plan_date        <= nvl((select max(ppd.decline_date)
                                                     from ins.p_policy      ppd
                                                         ,ins.p_pol_decline pdd-- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                                                    where ppd.pol_header_id = pol.policy_header_id
                                                      and ppd.policy_id     = pdd.p_policy_id
                                                  )
                                                 ,ac.plan_date)
                   and dsr.brief in ('TO_PAY', 'PAID')
         ) as debt_sum
        ,(select nvl(min(case when dsr.brief = 'TO_PAY' then ap.plan_date end)
                    ,min(case when dsr.brief = 'NEW' then ap.plan_date end)
                    )
            from ins.p_policy       po
                ,ins.doc_doc        dd
                ,ins.ac_payment     ap
                ,ins.document       dc
                ,ins.doc_status_ref dsr
                ,ins.doc_templ      dt
           where po.pol_header_id     = pol.policy_header_id
             and po.policy_id         = dd.parent_id
             and dd.child_id          = ap.payment_id
             and ap.payment_id        = dc.document_id
             and dc.doc_templ_id      = dt.doc_templ_id
             and dc.doc_status_ref_id = dsr.doc_status_ref_id
             and dt.brief             = 'PAYMENT'
             and dsr.brief in ('TO_PAY','NEW')
         ) as due_date
        ,nvl(last_ver.decline_date, pol.decline_date) as decline_date
        ,nvl(last_ver.decline_reason, pol.decline_reason) as decline_reason
        ,last_ver.policy_id as last_ver_policy_id
        ,last_ver.last_ver_status
        ,pol.active_ver_status
          from (select pp.policy_id
                      ,pol_insurer.insured_id
                      ,p.description                      product_name
                      ,p.brief                            product_brief
                      ,ph.ids
                      ,pp.pol_num
                      ,ph.start_date                      date_begin
                      ,pp.end_date                        date_end
                      ,ph.policy_header_id
                      ,pt.description                     payment_term
                      ,f.brief                            fund
                      ,case
                         when pp.decline_reason_id is not null and pd.p_policy_id is not null then
                           /*to_char(*/pp.decline_date/*,'dd.mm.yyyy')*/
                       end as decline_date
                      ,case
                         when pd.p_policy_id is not null then
                           dr.name
                       end as decline_reason
                      ,dsr.brief           as active_ver_status
                  from ins.p_policy             pp
                      ,ins.p_pol_decline        pd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                      ,ins_dwh.cbnt_contact_tmp pol_insurer
                      ,ins.p_policy_contact     pc
                      ,ins.t_product            p
                      ,ins.p_pol_header         ph
                      ,ins.fund                 f
                      ,ins.t_payment_terms      pt
                      ,ins.t_decline_reason     dr
                      ,ins.document             dc
                      ,ins.doc_status_ref       dsr
                 where pol_insurer.insured_id    = pc.contact_id
                   and pc.contact_policy_role_id = 6
                   and pp.policy_id              = pc.policy_id
                   and ph.policy_id              = pp.policy_id
                   and p.product_id              = ph.product_id
                   and f.fund_id                 = ph.fund_id
                   and pt.id                     = pp.payment_term_id
                   -- номер не должен быть пустым
                   and pp.pol_num is not null
                   and pp.decline_reason_id      = dr.t_decline_reason_id (+)
                   and pp.policy_id              = pd.p_policy_id         (+)
                   and pp.policy_id              = dc.document_id
                   and dc.doc_status_ref_id      = dsr.doc_status_ref_id
                   and dsr.brief                != 'CANCEL'
               ) pol
              ,(select pp.pol_header_id,
                       pp.policy_id,
                       pp.start_date,
                       pp.version_num
                      ,case
                         when pp.decline_reason_id is not null and pd.p_policy_id is not null then
                           /*to_char(*/pp.decline_date/*,'dd.mm.yyyy')*/
                       end as decline_date
                      ,case
                         when pd.p_policy_id is not null then
                           dr.name
                       end as decline_reason
                      ,dsr.brief as last_ver_status
                  from ins.p_pol_header     ph
                      ,ins.p_policy         pp
                      ,ins.p_pol_decline    pd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                      ,ins.document         dc
                      ,ins.doc_status_ref   dsr
                      ,ins.t_decline_reason dr
                 where pp.policy_id         = dc.document_id
                   and dc.doc_status_ref_id = dsr.doc_status_ref_id
                   and ph.last_ver_id       = pp.policy_id
                   and pp.policy_id         = pd.p_policy_id         (+)
                   and pp.decline_reason_id = dr.t_decline_reason_id (+)
               ) last_ver
         where pol.policy_header_id = last_ver.pol_header_id) policy,
       ins.contact cn,
       ins.department d
 where policy.agent_id = cn.contact_id(+)
   and policy.agency_id = d.department_id(+);

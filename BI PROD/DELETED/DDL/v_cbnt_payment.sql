CREATE OR REPLACE VIEW INS_DWH.V_CBNT_PAYMENT AS
select nvl(to_char(min(payment_id)),'null')         as payment_id
      ,nvl(to_char(min(policy_id)),'null')          as policy_id
      ,nvl(to_char(due_date,'dd.mm.yyyy'),'null')   as due_date
      ,nvl(to_char(grace_date,'dd.mm.yyyy'),'null') as grace_date
      ,case
         when nvl(min(pay_date),to_date('01.01.1900','dd.mm.yyyy')) < nvl(decline_date,to_date('31.12.2999','dd.mm.yyyy')) then
           nvl(to_char(round(sum(epg_amount),2)),'0')
         else
           '0'
       end as epg_amount
      ,nvl(to_char(min(pay_date),'dd.mm.yyyy'),'null')   as pay_date
      ,case
         when nvl(min(pay_date),to_date('01.01.1900','dd.mm.yyyy')) < nvl(decline_date,to_date('31.12.2999','dd.mm.yyyy')) then
           nvl(to_char(round(sum(epg_amount_rur),2)),'0')
         else
           '0'
       end as epg_amount_rur
      ,nvl(epg_status_brief,'null')                      as epg_status_brief
      ,nvl(case epg_status_brief
             when 'NEW' then 'Новый'
             when 'TO_PAY' then 'К оплате'
             when 'PAID' then 'Оплачен'
           end
          ,'null')
      /*,nvl(epg_status,'null')*/                       as epg_status
      ,nvl(to_char(round(sum(index_fee),2)),'0')        as index_fee
      ,case
         when nvl(min(pay_date),to_date('01.01.1900','dd.mm.yyyy')) < nvl(decline_date,to_date('31.12.2999','dd.mm.yyyy')) then
           nvl(to_char(round(sum(debt_sum),2)),'0')
         else
           nvl(to_char(round(sum(epg_amount_rur),2)),'0')
       end as debt_sum
      ,pol_header_id
  from (select payment_id
              ,policy_id
              ,pol_header_id
              ,due_date
              ,grace_date
              ,epg_amount
              ,(SELECT min(pay_doc.due_date)
                  FROM ins.doc_set_off dso,
                       ins.ac_payment pay_doc
                      ,ins.document dc
                 WHERE dso.parent_doc_id = mn.true_payment_id
                   AND dso.child_doc_id = pay_doc.payment_id
                   --AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
                   and dso.doc_set_off_id    = dc.document_id
                   and dc.doc_status_ref_id != 41
               ) pay_date
              ,epg_amount*rev_rate as epg_amount_rur
              ,epg_status_brief
              ,case
                 when epg_status_brief in ('NEW','TO_PAY')
                   and row_number() over (partition by pol_header_id order by plan_date desc) = 1 then
                   index_fee
                 else 0
               end as index_fee
              ,case epg_status_brief
                 when 'NEW' then
                   0
                 else
                   epg_amount - nvl(ins.pkg_payment.get_set_off_amount(payment_id, pol_header_id, null),0)
               end as debt_sum
              ,decline_date
          from (select /*+ NO_MERGE INDEX(pp IX_POL_HEADER) INDEX (ac PK_AC_PAYMENT)*/
                       ac.payment_id
                      ,pt.policy_id
                      ,pp.pol_header_id
                      ,ac.grace_date
                      ,case
                         when dsr.brief = 'NEW' or ac.due_date > trunc(sysdate,'dd') then
                           (select nvl(sum(se.fee),0)
                              from ins.p_pol_header ph
                                  ,ins.as_asset     se
                             where ph.policy_header_id = pp.pol_header_id
                               and ph.policy_id        = se.p_policy_id
                           )-
                           case
                             when mod(months_between(ac.plan_date,pt.date_begin),12) != 0 then
                               (select nvl(sum(pc.fee),0)
                                  from ins.p_pol_header       ph
                                      ,ins.as_asset           se
                                      ,ins.p_cover            pc
                                      ,ins.t_prod_line_option plo
                                 where ph.policy_header_id      = pp.pol_header_id
                                   and ph.policy_id             = se.p_policy_id
                                   and se.as_asset_id           = pc.as_asset_id
                                   and pc.t_prod_line_option_id = plo.id
                                   and plo.brief in ('Adm_Cost_Acc','Adm_Cost_Life')
                               )
                             else 0
                           end
                         when dsr.brief = 'PAID' then
                           ins.pkg_payment.get_set_off_amount(ac.payment_id, pp.pol_header_id,null)
                         when dsr.brief = 'TO_PAY' then
                           ac.amount
                       end epg_amount
                      ,ac.rev_rate
                      ,case
                         when count(case dsr.brief
                                      when 'TO_PAY' then
                                       1
                                    end)
                              over(partition by pp.pol_header_id, ac.plan_date) > 0
                         then
                           'TO_PAY'
                         else
                           dsr.brief
                       end as epg_status_brief
/*                      ,case
                         when count(case dsr.brief
                                      when 'TO_PAY' then
                                       1
                                    end)
                              over(partition by pt.policy_header_id, ac.plan_date) > 0
                         then
                           'К оплате'
                         else
                           dsr.name
                       end as epg_status*/
                      ,case
                         when pt.last_ver_status = 'INDEXATING' then
                           to_number(decode(pt.fee_index,'null',null,pt.fee_index))
                         else 0
                       end as index_fee
                      ,count(case when dsr.brief = 'TO_PAY' then 1 end) over (partition by pp.pol_header_id) as exists_topay
                      ,row_number() over (partition by pp.pol_header_id, dsr.brief order by ac.plan_date) as rn_status
                      ,ac.payment_id as true_payment_id
                      ,ac.due_date
                      ,ac.plan_date
                      ,ded.decline_date
                  from ins.ac_payment     ac
                      ,ins.doc_doc        dd
                      ,ins.p_policy       pp
                      ,ins.document       dc
                      ,ins.doc_status_ref dsr
                      --,ins.doc_templ      dt
                      ,ins_dwh.cbnt_policy_tmp pt
                      ,(select max(case
                                     when pd.p_policy_id is not null then
                                       ppd.decline_date
                                   end) as decline_date
                              ,ppd.pol_header_id
                          from ins.p_policy            ppd
                              ,ins.p_pol_decline       pd -- Только для обхода ошибки, связанной с копированием decline_reason_id в последующие версии
                              ,ins_dwh.cbnt_policy_tmp pt
                         where ppd.policy_id in (to_number(pt.policy_id),to_number(pt.last_ver_policy_id))
                           and ppd.policy_id = pd.p_policy_id (+)
                         group by ppd.pol_header_id
                       ) ded
                 where pp.pol_header_id     = to_number(pt.policy_header_id)
                   and pp.policy_id         = dd.parent_id
                   and dd.child_id          = ac.payment_id
                   and ac.payment_id        = dc.document_id
                   and dc.doc_templ_id      = 4--dt.doc_templ_id
                   and dc.doc_status_ref_id = dsr.doc_status_ref_id
                   --and dt.brief             = 'PAYMENT'
                   and ac.plan_date        >= to_date('01.01.2010', 'dd.mm.yyyy')
                   and pp.pol_header_id     = ded.pol_header_id
                   and ac.plan_date        <= nvl(ded.decline_date
                                                 ,ac.plan_date)
                   and dsr.brief in ('TO_PAY', 'PAID', 'NEW')
                ) mn
         where /*epg_status in ('Оплачен', 'К оплате')
            or epg_status = 'Новый'*/
               epg_status_brief in ('PAID','TO_PAY')
            or epg_status_brief = 'NEW'
           and exists_topay = 0
           and rn_status    = 1
        )
 group by pol_header_id, due_date, grace_date, epg_status_brief, decline_date;

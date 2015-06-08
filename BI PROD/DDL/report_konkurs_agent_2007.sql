create or replace force view report_konkurs_agent_2007 as
select k.AGENT_NAME,
       k.dep_name,
       --k.AG_CONTRACT_HEADER_ID,
       count(k.policy_id) as count_policy,
       count(k.prg_erz) as count_erz,
       sum(k.kf * k.premium) as s
from
(select agj.AG_CONTRACT_HEADER_ID as AG_CONTRACT_HEADER_ID,
       agj.AGENT_NAME,
       agj.NUM as ag,
       agj.STATUS_NAME as STATUS_NAME_agentskiy,
       agj.DATE_BEGIN,
       agj.DATE_END,
       agj.CATEGORY_NAME,
       agj.dep_name,
       p.pol_ser,
       p.pol_num,
       pl.policy_id,
       pl.status_name as status_name_policy,
       p.start_date,
       p.end_date,
       p.ins_amount,
       p.premium,
       pl.prod_desc,
       case when pll.prod_desc is null then '' else
            (case when p.premium >= 1500 then pll.prod_desc else '' end)
       end as prg_erz,
       pl.insurer_name,
       pl.f_resp, --hp.fund_id
       case pl.f_resp when 'RUR' then 1 when 'USD' then 25 when 'EUR' then 34 else 1 end as kf,
       pl.f_pay, --hp.fund_pay_id
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
       az.real_pay_date as real_date
  from v_ag_contract_journal agj
       left join p_policy_agent ag on (ag.ag_contract_header_id = agj.ag_contract_header_id)
       left join p_pol_header hp on (hp.policy_header_id = ag.policy_header_id)
       left join p_policy p on (p.policy_id = hp.policy_id)

       --left join v_policy_journal pl on (pl.policy_header_id = hp.policy_header_id)
       left join (select max(ll.policy_header_id) as policy_header_id, ll.insurer_name
                  from v_policy_journal ll
                  group by ll.insurer_name) ll on (ll.policy_header_id = hp.policy_header_id)
       left join v_policy_journal pl on (pl.policy_header_id = ll.policy_header_id)
       left join v_policy_journal pll on (pll.policy_header_id = hp.policy_header_id and pll.prod_desc in ('ERZ','ERZ (копия)'))
       left join policy_agent_status st on (st.policy_agent_status_id = ag.status_id)

       inner join doc_doc dd on (dd.parent_id = p.policy_id)
       inner join document d on (dd.child_id = d.document_id)
       inner join doc_templ dt on (dt.doc_templ_id = d.doc_templ_id and dt.brief = 'PAYMENT')
       inner join ac_payment a on (a.payment_id = d.document_id and a.payment_id = dd.child_id)
       left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)
       left join document dz on (dz.document_id = dso.child_doc_id)
       left join ac_payment az on (dz.document_id = az.payment_id)

       left join contact ct on (a.contact_id = ct.contact_id)
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (d.document_id = ds.document_id )
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pr, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) dzp on (dz.document_id = dzp.document_id )

  where /*agj.ag_contract_header_id in (1408707)
        and*/ st.name not like 'ОТМЕНЕН'
        and ds.name_pl like 'Оплачен'
        and az.real_pay_date between to_date('21-10-2007','dd-mm-yyyy') and to_date('21-12-2007','dd-mm-yyyy')
        and agj.CATEGORY_NAME like 'Агент'
        and pl.prod_desc in ('ACC','ACC_EXP','RP1','ERZ','ACC_OLD','ERZ (копия)')
        and hp.sales_channel_id not in (8,10,16)
        --and agj.AGENT_NAME like 'Врулина%'
               ) k
group by k.dep_name,
         k.agent_name
--       k.AG_CONTRACT_HEADER_ID;


-- Проверка количества договоров
/*
select pa.ag_contract_header_id,
       pa.policy_header_id,
       pp.policy_id,
       pp.pol_num,
       pp.notice_num,
       az.plan_date,
       az.real_pay_date
from p_policy_agent pa
     left join p_pol_header ph on (ph.policy_header_id = pa.policy_header_id)
     left join p_policy pp on (pp.pol_header_id = ph.policy_header_id)
     inner join doc_doc dd on (dd.parent_id = pp.policy_id)
     inner join document d on (dd.child_id = d.document_id)
     inner join doc_templ dt on (dt.doc_templ_id = d.doc_templ_id and dt.brief = 'PAYMENT')
     inner join ac_payment a on (a.payment_id = d.document_id and a.payment_id = dd.child_id)
     left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)--
     left join document dz on (dz.document_id = dso.child_doc_id)
     left join ac_payment az on (dz.document_id = az.payment_id)
where ph.product_id in (7670,7674,7677,7681,11477,12378)
      and pa.ag_contract_header_id = 570265
      and az.real_pay_date between to_date('21-10-2007','dd-mm-yyyy') and to_date('21-12-2007','dd-mm-yyyy');*/
;


create or replace force view v_delivery_payment as
select pp.START_DATE as "Дата начала полиса"
       , pp.pol_ser as "полис серия"
       , pp.pol_num As "полис №"
       , pp.notice_num "№ заявления"
       , cont.obj_name_orig "ФИО страхователя"
       , db.num as "№ счета"
       ,  d.num as "№ квитанции"
       , case when dt.brief like 'PD4COPY' then 'ПД4' when dt.brief like 'A7COPY' then 'А7' else '' end as "Тип"
       , dc.due_date "Дата платежа"
       , dc.real_pay_date "Дата документа"
       , ddB.Set_Off_Child_Amount "Сумма квитанции"
       ,j.agent_name "Агент"
       ,j.num "№ АД"
       ,j.date_begin "Дата начала АД"
       ,j.status_name "Статус"
       --, a.status_id
       ,j.category_name "Категория"
       ,j.dep_name "Филиал"
from ins.ac_payment dc
    ,ins.document d
    , ins.doc_templ dt
    , ins.doc_doc dd
    , ins.document dA
    , ins.doc_set_off ddB
    , ins.document dB
    , ins.doc_doc ddP
    , ins.p_policy pp
    , P_POLICY_AGENT a
    , V_AG_CONTRACT_JOURNAL j
    , T_CONTACT_POL_ROLE cpr
    , P_POLICY_CONTACT pc
    , CONTACT cont
where d.document_id = dc.payment_id
      and dt.doc_templ_id = d.doc_templ_id
      and dt.brief in ('PD4COPY', 'A7COPY')
      and ins.doc.get_last_doc_status_brief(dc.payment_id) = 'PAID'
      and dd.child_id = dc.payment_id
      and dA.Document_Id = dd.parent_id
      and ddB.Child_Doc_Id = dA.Document_Id
      and dB.Document_Id = ddB.Parent_Doc_Id
      and ddP.Child_Id = dB.Document_Id
      and pp.policy_id = ddP.Parent_Id
      and pp.POL_HEADER_ID = a.POLICY_HEADER_ID
      and a.AG_CONTRACT_HEADER_ID= j.AG_CONTRACT_HEADER_ID
      and a.status_id not in (2,4)
      and cpr.brief = 'Страхователь'
      and pc.policy_id = pp.policy_id
      AND pc.contact_policy_role_id = cpr.id
      and cont.contact_id = pc.contact_id
;


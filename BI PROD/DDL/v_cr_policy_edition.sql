CREATE OR REPLACE FORCE VIEW V_CR_POLICY_EDITION AS
select pr.description as product, -- продукт
       p.pol_ser, -- серия
       p.pol_num, -- номер
       p.num, -- номер договора
       p.policy_id, -- id полиса
       p.notice_num,-- номер заявления
       pr.brief as programm_code, -- код программы
       cont.obj_name_orig insurer_name,
       doc.get_status_date (p.policy_id,'ACTIVE') as st_active_date, -- дата статуса активный
       doc.get_status_date (p.policy_id,'UNDERWRITING') as st_under_date, -- дата статуса андеррайтинг
       doc.get_status_date (p.policy_id,'MED_OBSERV') as st_med_date, -- дата статуса мед обследование
       doc.get_status_date (p.policy_id,'REVISION') as st_rev_date, -- дата статуса доработка
       doc.get_status_date (p.policy_id,'ACTIVE') + 2 as st_date_print_to, --напечатать полис до
       sysdate - doc.get_status_date (p.policy_id,'ACTIVE') as count_days_delay, --количество дней просрочки
       doc.get_status_date (p.policy_id,'ACTIVE') + 2 - sysdate as count_days_to_issue, --количество дней на выпуск полиса
       ccc.name||' '||ccc.first_name||' '||ccc.middle_name as agent_name,
       dd.name as filial,
       p.version_num,
       paym.due_date,
       paym.real_pay_date
from ven_p_pol_header ph
   join ven_p_policy p on p.policy_id = ph.policy_id
   join P_POLICY_CONTACT pc ON pc.policy_id = p.policy_id AND pc.contact_policy_role_id = 6
   join CONTACT cont ON cont.contact_id = pc.contact_id
   join ven_t_product pr on pr.product_id = ph.product_id

   left join p_policy_agent pa on (pa.policy_header_id = ph.policy_header_id)
   left join ag_contract_header ah on (ah.ag_contract_header_id = pa.ag_contract_header_id)
   left join policy_agent_status sta on (sta.policy_agent_status_id = pa.status_id)
   left join contact ccc on ccc.contact_id = ah.agent_id
   left join department dd on (dd.department_id = ah.agency_id)

   left join

   (select dc.due_date,
           dc.real_pay_date,
           pp.policy_id
from ins.ac_payment dc
    ,ins.document d
    , ins.doc_templ dt
    , ins.doc_doc dd
    , ins.document dA
    , ins.doc_set_off ddB
    , ins.document dB
    , ins.doc_doc ddP
    , ins.p_policy pp

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
      ) paym on (paym.policy_id = p.policy_id)

   /*left join (SELECT
                    p.pol_header_id,
                    min(a.payment_id) mm
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
                    AND ds.start_date = (
                      SELECT MAX(dss.start_date)
                      FROM   DOC_STATUS dss
                      WHERE  dss.document_id = d.document_id
                    )
                    AND dsr.doc_status_ref_id = ds.doc_status_ref_id
                    group by p.pol_header_id
                    ) acc on (acc.pol_header_id = ph.policy_header_id)
       left join ac_payment a on (acc.mm = a.payment_id)
       left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)--
       left join document dz on (dz.document_id = dso.child_doc_id and dz.doc_templ_id in (5234))
       left join ac_payment az on (dz.document_id = az.payment_id)

       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.payment_id = ds.document_id )
*/


   where doc.get_doc_status_brief (p.policy_id) = 'ACTIVE'
         and sta.brief not like 'CANCEL'
         and sta.brief not like 'ERROR'
         and pr.product_id not in (7503,7676,7677,11609,12402,12410,7687,19964,29340,7670)
         and pkg_policy.get_last_version_status(ph.policy_header_id) <> 'Готовится к расторжению'
--call ents_bi.grant_to_eul('ALL')
;


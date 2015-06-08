CREATE OR REPLACE FORCE VIEW V_POLICY_REVISION AS
select rownum "№ п/п",
a."Дата заявления",
a."Серия заявления",
a."Номер заявления",
a."Дата акцепта в рег",
a."Дата ввода заявления в Борлас",
a."Страхователь",
a."Агент по ДС",
a."Руководитель агента",
a."Статус версии",
a."Дата статуса",
a."Агентство",
a."Количество дней на доработке"
  from (
SELECT distinct
--ph.policy_header_id,
p.notice_date as "Дата заявления",
p.notice_ser "Серия заявления",
p.notice_num "Номер заявления",
p.sign_date "Дата акцепта в рег",
(select min(ds2.start_date)
  from doc_status ds2,
       doc_status_ref dsr2
 where ds2.document_id = p.policy_id
   and dsr2.doc_status_ref_id = ds2.doc_status_ref_id
   and dsr2.brief in ('PROJECT')
) "Дата ввода заявления в Борлас",
con.obj_name_orig AS "Страхователь",
c.obj_name_orig AS "Агент по ДС",
c2.obj_name_orig AS "Руководитель агента",
doc.get_doc_status_name(p.policy_id) AS "Статус версии",
max(ds.start_date) over (partition by ph.policy_header_id) "Дата статуса",
dep.name as "Агентство",
round (sysdate - max(ds.start_date) over (partition by ph.policy_header_id)) "Количество дней на доработке"

 FROM p_pol_header  ph,
      p_policy      p,
      contact       con,
      p_policy_agent pa,
      ven_ag_contract_header ach,
      ven_ag_contract        ac,
      contact                c,
      ven_ag_contract_header ach2,
      ven_ag_contract        ac2,
      contact                c2,
      department             dep,
      doc_status             ds,
      doc_status_ref         dsr

WHERE p.pol_header_id = ph.policy_header_id
  AND con.contact_id = pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь')
  AND doc.get_doc_status_brief(p.policy_id) IN ('REVISION','AGENT_REVISION')
  and ds.document_id = p.policy_id
  and dsr.doc_status_ref_id = ds.doc_status_ref_id
  and dsr.brief in ('REVISION','AGENT_REVISION')
  and ds.start_date between
                    (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'p_REVISION' and param_name = 'start_date')
                    and
                    (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'p_REVISION' and param_name = 'end_date')
  and dep.name in (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'p_REVISION' and param_name = 'Agency')
  and p.policy_id = (SELECT a.policy_id
                       FROM (SELECT p2.policy_id,
                                    p2.version_num,
                                    p2.pol_header_id,
                                    row_number() over (PARTITION BY p2.pol_header_id ORDER BY p2.version_num DESC) rn
                               FROM p_policy p2
                            )a
                      WHERE a.rn = 1
                        AND a.pol_header_id = p.pol_header_id
                     )
   and pa.policy_header_id = ph.policy_header_id
   and pa.status_id = 1
   and ach.ag_contract_header_id = pa.ag_contract_header_id
   and ac.ag_contract_id = PKG_AGENT_1.GET_STATUS_BY_DATE(ach.ag_contract_header_id,sysdate)
   and c.contact_id = ach.agent_id
   and ac2.ag_contract_id = ac.contract_leader_id
   and ach2.ag_contract_header_id = ac2.contract_id
   and c2.contact_id = ach2.agent_id
  and dep.department_id = ph.agency_id (+)
  --and ph.policy_header_id = 7490563
  order by dep.name
)a
;


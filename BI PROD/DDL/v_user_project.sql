CREATE OR REPLACE FORCE VIEW V_USER_PROJECT AS
SELECT
ts.description          "Канал продаж",
dep.name                "Агентство по ДС",
ds.user_name,
--обновление от 2009.07.09 по заявке 28722
p.Notice_Num            "Номер заявления",
cn_ins.obj_name_orig    "ФИО Страхователя",
--
tp.description "Продукт",
dsr.name "Статус",
ds.change_date,
pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии"
 FROM p_pol_header  ph,
      p_policy      p,
      t_product     tp,
      t_sales_channel ts,
      department      dep,
      doc_status      ds,
      doc_status_ref  dsr,
      doc_status_ref  dsr_src,
      contact           cn_ins
WHERE p.pol_header_id = ph.policy_header_id
  and dep.department_id = ph.agency_id (+)
  and ts.id = ph.sales_channel_id
  and tp.product_id = ph.product_id
  and ds.document_id = p.policy_id
  and dsr.doc_status_ref_id = ds.doc_status_ref_id
  and p.version_num = 1
  and dsr_src.doc_status_ref_id = ds.src_doc_status_ref_id
  and dsr_src.name = '<Документ добавлен>'
  and ds.change_date between (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'u_project' and param_name = 'begin_date')
                         and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'u_project' and param_name = 'end_date')
--обновление от 2009.07.09 по заявке 28722
  AND cn_ins.contact_id =   pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')
order by ds.user_name
;


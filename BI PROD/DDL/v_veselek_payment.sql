CREATE OR REPLACE FORCE VIEW V_VESELEK_PAYMENT AS
select hp.policy_id as policy_id,
       p.pol_ser,
       p.pol_num,
       ct.name||' '||ct.first_name||' '||ct.middle_name as insurer_name,
       fd.brief,
       p.premium,
       a.payment_number,
       a.plan_date,
       a.due_date,
       a.grace_date,
       a.amount,
       pkg_payment.get_part_set_off_amount(d.document_id, p.pol_header_id, 0) part_pay_amount,

       ds.name_pl,

       so.doc_templ_name,
       so.list_doc_num,
       so.list_doc_date,
       so.set_off_amount,
       so.list_doc_amount,
       so.set_off_child_amount,
       so.doc_status_ref_name,
       so.contact_name

from p_pol_header hp
       left join p_policy p on (p.policy_id = hp.policy_id)
       left join p_policy_contact pc on (pc.policy_id = p.policy_id
                          AND pc.contact_policy_role_id = Ent.get_obj_id('t_contact_pol_role','Страхователь'))

       inner join doc_doc dd on (dd.parent_id = p.policy_id)
       inner join document d on (dd.child_id = d.document_id)
       inner join doc_templ dt on (dt.doc_templ_id = d.doc_templ_id and dt.brief = 'PAYMENT')
       inner join ac_payment a on (a.payment_id = d.document_id and a.payment_id = dd.child_id)

       left join (SELECT
  dso.parent_doc_id main_doc_id,
  dso.parent_doc_id,
  dso.doc_set_off_id,
  dso.child_doc_id,
  cd.num list_doc_num,
  cp.due_date list_doc_date,
  cd.reg_date,
  dso.set_off_date,
  dso.set_off_child_amount set_off_amount,
  dso.set_off_amount set_off_child_amount,
  (cp.amount+cp.comm_amount) list_doc_amount,
  cp.contact_id,
  cc.obj_name_orig contact_name,
  ds.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  cd.doc_templ_id,
  dt.brief doc_templ_brief,
  dt.name doc_templ_name
FROM
  doc_set_off dso,
  document cd,
  ac_payment cp,
  contact cc,
  doc_status ds,
  doc_status_ref dsr,
  doc_templ dt
WHERE
  dso.child_doc_id = cd.document_id AND
  cd.document_id = cp.payment_id AND
  cp.contact_id = cc.contact_id AND
  ds.document_id = cd.document_id AND
  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   doc_status dss
    WHERE  dss.document_id = cd.document_id
  )
  AND
  dsr.doc_status_ref_id = ds.doc_status_ref_id
  AND
  dt.doc_templ_id = cd.doc_templ_id
UNION ALL
SELECT
  dso.child_doc_id main_doc_id,
  dso.parent_doc_id,
  dso.doc_set_off_id,
  dso.child_doc_id,
  cd.num list_doc_num,
  cp.due_date list_doc_date,
  cd.reg_date,
  dso.set_off_date,
  dso.set_off_amount set_off_amount,
  dso.set_off_child_amount set_off_child_amount,
  (cp.amount+cp.comm_amount) list_doc_amount,
  cp.contact_id,
  cc.obj_name_orig contact_name,
  ds.doc_status_ref_id,
  dsr.name doc_status_ref_name,
  cd.doc_templ_id,
  dt.brief doc_templ_brief,
  dt.name doc_templ_name
FROM
  doc_set_off dso,
  document cd,
  ac_payment cp,
  contact cc,
  doc_status ds,
  doc_status_ref dsr,
  doc_templ dt
WHERE
  dso.parent_doc_id = cd.document_id AND
  cd.document_id = cp.payment_id AND
  cp.contact_id = cc.contact_id AND
  ds.document_id = cd.document_id AND
  ds.start_date = (
    SELECT MAX(dss.start_date)
    FROM   doc_status dss
    WHERE  dss.document_id = cd.document_id
  )
  AND
  dsr.doc_status_ref_id = ds.doc_status_ref_id
  AND
  dt.doc_templ_id = cd.doc_templ_id) so on (so.main_doc_id = d.document_id)


--  left join  v_policy_payment_set_off so on (so.main_doc_id = d.document_id)
       left join contact ct on (ct.contact_id = pc.contact_id)
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (d.document_id = ds.document_id )

       left join fund fd on (fd.fund_id = hp.fund_id)
where /*p.policy_id between 500000 and 800000
      and*/ nvl(a.plan_date,so.list_doc_date) between to_date('01-01-2005','dd-mm-yyyy') and to_date('31-12-2007','dd-mm-yyyy')
      --and p.policy_id = 799887
      /*and fd.brief <> 'RUR'*/
;


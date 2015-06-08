CREATE OR REPLACE VIEW V_VIP_CONTACT_REP AS
SELECT cn.obj_name_orig, cp.date_of_birth, ci.id_value, ci.issue_date, ph.Ids, d.name, cm.description,
       te.description type_email, em.email
 FROM contact cn,
      cn_person cp,
      cn_contact_email em,
      t_email_type te,
      t_contact_status cs,
      cn_contact_ident ci,
      t_id_type ti,
      p_pol_header ph,
      p_policy pp,
      t_collection_method cm,
      department d,
      p_policy_contact pc,
      t_contact_pol_role tcp
WHERE cn.t_contact_status_id = cs.t_contact_status_id
  AND ci.contact_id = cn.contact_id
  AND cp.contact_id = cn.contact_id
  AND ci.id_type = ti.ID
  AND ti.brief = 'VIPCard'
  AND cs.NAME = 'VIP'
  AND pp.policy_id = ph.policy_id
  AND ph.agency_id = d.department_id
  AND pp.collection_method_id = cm.ID
  AND pc.contact_id = cn.contact_id
  AND pc.policy_id = ph.policy_id
  AND pc.contact_policy_role_id = tcp.ID
  AND tcp.DESCRIPTION = 'Страхователь'
  and em.contact_id(+) = cp.contact_id
  and em.email_type = te.id(+)
  ORDER BY 1


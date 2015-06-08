CREATE OR REPLACE FORCE VIEW V_POL_ISSUER_AGENT AS
SELECT pc.policy_id, pc.contact_id, c.obj_name_orig contact_name, r.remarks
  FROM P_POLICY_CONTACT pc, T_CONTACT_POL_ROLE cpr, ven_contact c,
       CN_CONTACT_REL r, T_CONTACT_REL_TYPE rt
 WHERE cpr.brief = 'Представитель страхователя'
   AND cpr.ID = pc.contact_policy_role_id
   AND c.contact_id = pc.contact_id
   AND c.contact_id = r.contact_id_a(+)
   AND r.relationship_type = rt.ID(+);


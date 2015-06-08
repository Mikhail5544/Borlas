CREATE OR REPLACE FORCE VIEW V_POL_LISINGODATEL AS
SELECT pc.policy_id, pc.contact_id, c.obj_name_orig contact_name
  FROM P_POLICY_CONTACT pc, T_CONTACT_POL_ROLE cpr, ven_contact c
 WHERE cpr.brief = 'Лизингодатель'
   AND cpr.id = pc.contact_policy_role_id
   AND c.contact_id = pc.contact_id;


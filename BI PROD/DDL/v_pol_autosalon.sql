CREATE OR REPLACE FORCE VIEW V_POL_AUTOSALON AS
SELECT pc.policy_id,
    pc.contact_id,
    cm.obj_name_orig contact_name,
    pc.ID AS policy_contact_id
  FROM p_policy_contact pc, t_contact_pol_role cpr, ven_cn_company cm
 WHERE UPPER(cpr.brief) = UPPER('Автосалон')
   AND cpr.ID = pc.contact_policy_role_id
   AND cm.contact_id = pc.contact_id;


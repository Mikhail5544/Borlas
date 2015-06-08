CREATE OR REPLACE VIEW v_pol_issuer AS
SELECT pc.policy_id
      ,pc.contact_id
      ,c.obj_name_orig contact_name
  FROM p_policy_contact   pc
      ,t_contact_pol_role cpr
      ,ven_contact        c
 WHERE cpr.brief = 'Страхователь'
   AND cpr.id = pc.contact_policy_role_id
   AND c.contact_id = pc.contact_id;

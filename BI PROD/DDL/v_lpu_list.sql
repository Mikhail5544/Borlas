CREATE OR REPLACE FORCE VIEW V_LPU_LIST AS
SELECT DISTINCT
  c.contact_id,
  c.dms_lpu_code,
  ent.obj_name(c.ent_id, c.contact_id) contact_name,
  c.first_name,
  c.middle_name,
  c.latin_name,
  ct.description contact_type,
  pkg_contact.get_address_name(ca.adress_id) address_name
FROM ven_cn_company c
 JOIN cn_contact_role cr ON cr.contact_id = c.contact_id
                       AND cr.role_id = (
                                          SELECT tcr.ID FROM t_contact_role tcr
                                           WHERE tcr.brief = 'LPU'
                                        )
JOIN t_contact_type ct ON c.contact_type_id = ct.ID
JOIN cn_contact_address ca ON ca.contact_id = c.contact_id AND
                              ca.ID = (
                                        SELECT MAX(ca2.ID) FROM cn_contact_address ca2
                                        WHERE ca2.contact_id = c.contact_id
                                      )
WHERE ct.is_individual = 0;


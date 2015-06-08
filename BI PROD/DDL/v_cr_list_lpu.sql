CREATE OR REPLACE FORCE VIEW V_CR_LIST_LPU AS
SELECT NVL(dlc.NAME ,'-') AS NAME,
       NVL(PROVINCE_NAME,'-') AS PROVINCE_NAME ,
       cl.CONTACT_NAME ,
       cl.ADDRESS_NAME ,
       tc.COUNTRY_CODE||'('||cct.TELEPHONE_PREFIX||')'||cct.TELEPHONE_NUMBER Tel_Number,
       p.NUM
       FROM ven_dms_lpu_cat          dlc,
       ven_cn_company           cc,
       v_cn_contact_address     ca,
       V_CONTACT_LIST           cl,
       ven_cn_contact_telephone cct,
       ven_t_country            tc,
       ven_t_country_dial_code  tsdc,
       ven_t_telephone_prefix   ttp,
       ven_p_policy             p,
       v_pol_issuer             vi
 WHERE cc.dms_lpu_cat_id = dlc.dms_lpu_cat_id(+)
   AND cl.contact_id IN (SELECT ccr.contact_id
                           FROM CN_CONTACT_ROLE ccr, T_CONTACT_ROLE tcr
                          WHERE tcr.description = 'Медицинское учреждение'
                            AND ccr.role_id = tcr.ID)
   AND ca.contact_id = cc.contact_id
   AND ca.country_id = tc.id
   AND cc.contact_id(+) = cl.contact_id
   AND cct.contact_id = cl.contact_id
   AND p.policy_id = vi.policy_id
   AND vi.contact_id = cl.contact_id
   AND tsdc.id = cct.country_id
   AND ttp.id(+) = cct.telephone_prefix_id;


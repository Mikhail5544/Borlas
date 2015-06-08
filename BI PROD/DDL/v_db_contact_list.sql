CREATE OR REPLACE VIEW V_DB_CONTACT_LIST AS
SELECT v.CONTACT_ID                                                              as contact_id
      ,v.obj_name_orig                                                           as obj_name_orig
      ,vcp.date_of_birth                                                         as date_of_birth
      ,cci.serial_nr || ' ' || cci.id_value                                      as passp_num
      ,case when  ct.brief != 'ФЛ' then
          (SELECT nvl(adr.NAME, pkg_contact.get_address_name(adr.id))
                  FROM ins.cn_address         adr
                 WHERE  adr.id = pkg_contact.get_address_by_brief(v.contact_id, 'LEGAL'))
      else      
       nvl(
           (SELECT nvl(adr.NAME, pkg_contact.get_address_name(adr.id))
              FROM ins.cn_address         adr
             WHERE  adr.id = pkg_contact.get_address_by_brief(v.contact_id, 'CONST'))
          ,(SELECT nvl(adr.NAME, pkg_contact.get_address_name(adr.id))
              FROM ins.cn_address         adr
             WHERE adr.id = pkg_contact.get_address_by_brief(v.contact_id, 'FACT'))
          )    
      end                                                                        as address_name
      ,pkg_contact.get_contact_telephones(v.contact_id, 'Мобильный')             as phone_num

      , v.name                                                                   as name
      , v.first_name                                                             as first_name
      , v.middle_name                                                            as middle_name
      , ct.upper_level_id                                                        as upper_level_id
      , ct.id                                                                    as ct_id
      , v.latin_name                                                             as latin_name
      , cc.dms_lpu_code                                                          as dms_lpu_code
      , ct.description                                                           as contact_type
      , lc.description                                                           as risk_level
      , ct.IS_INDIVIDUAL                                                         as is_individual
  FROM contact          v
      ,cn_person        vcp
      ,(select cci.*
        from cn_contact_ident cci
        where cci.is_default = 1) cci
      ,ven_t_contact_type   ct
      ,ven_t_contact_status cs
      ,ven_t_gender         vtg
      ,ven_cn_company       cc
      ,t_risk_level         lc

 WHERE v.contact_id = vcp.contact_id(+)
   AND v.contact_id = cci.contact_id(+)

   AND v.contact_type_id = ct.id
   AND vcp.gender        = vtg.id(+)
   AND v.t_contact_status_id = cs.t_contact_status_id(+)
   AND v.contact_id          = cc.contact_id(+)
   and v.risk_level          = lc.t_risk_level_id;
   
   
  
   
   

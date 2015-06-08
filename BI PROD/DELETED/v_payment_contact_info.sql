create or replace view v_payment_contact_info as
select /*+ FULL (c)
           INDEX (city PK_T_CITY) INDEX (reg PK_T_REGION)
           INDEX (distr PK_T_DISTRICT) INDEX (prov PK_T_PROVINCE)
           INDEX (street PK_T_STREET)
       */
       rownum                                                         as num
      ,nvl(c.name,' ')                                                as name
      ,nvl(c.first_name,' ')                                          as first_name
      ,nvl(c.middle_name,' ')                                         as middle_name
      ,nvl(to_char(pkg_contact.get_birth_date(c.contact_id)),' ')     as birth_date
      ,nvl(pasp_rf.serial_nr,' ')                                     as ser_pasp
      ,nvl(pasp_rf.id_value,' ')                                      as num_pasp
      ,nvl(to_char(pasp_rf.issue_date),' ')                           as issue_date_pasp
      ,nvl(pasp_rf.place_of_issue,' ')                                as place_issue_pasp
      ,nvl(pens.id_value,' ')                                         as num_pens
      ,nvl(inn.id_value,' ')                                          as iin_contact
      ,nvl(reg.region_name,' ')                                       as region_name
      ,nvl((select rg.description_short
              from ins.t_region_type rg
             where rg.region_type_id = reg.region_type_id
           ),' ')                                                     as reg_type
      ,nvl(prov.province_name,' ')                                    as province_name
      ,nvl((select prv.description_short
              from ins.t_province_type prv
             where prv.province_type_id = prov.province_type_id
           ),' ')                                                     as prv_type
      ,nvl(city.city_name,' ')                                        as city_name
      ,nvl((select ct.description_short
              from ins.t_city_type ct
             where ct.city_type_id = city.city_type_id
           ),' ')                                                     as ct_type
      ,nvl((select dst.description_short
              from ins.t_district_type dst
             where dst.district_type_id = distr.district_type_id
           ),' ')                                                     as dst_type
      ,nvl(distr.district_name,' ')                                   as district_name
      ,nvl(street.street_name,' ')                                    as street_name
      ,nvl((select str.description_short
              from ins.t_street_type str
             where str.street_type_id = street.street_type_id
           ),' ')                                                     as str_type
      ,nvl(adr.house_nr,' ')                                          as house_nr
      ,nvl(adr.building_name,' ')                                     as building_name
      ,nvl(adr.appartment_nr,' ')                                     as appartment_nr
      ,nvl(adr.zip,' ')                                               as zip
      ,nvl(adr.name,' ')                                              as address_name
--      ,nvl(b_bik.val,' ')                                             as bik_bank
      ,(select ci.id_value
          from ins.cn_contact_ident ci
         where ci.id_type    = 10 -- 'BIK'
           and ci.contact_id = bank.contact_id
       ) bik_bank
      ,bank.obj_name_orig                                             as name_bank
--      ,nvl(b_cor.val,' ')                                             as corraccount_bank
      ,(select ci.id_value
          from ins.cn_contact_ident ci
         where ci.id_type = 11 -- 'KORR'
           and ci.contact_id = bank.contact_id
       )                                                              as corraccount_bank
      ,nvl(bacc.account_nr,' ')                                       as raccount_bank
      ,nvl(bacc.account_corr,' ')                                     as licaccount_bank
      ,nvl(b_inn.val,' ')                                             as inn_bank
      ,c.contact_id                                                   as contact_id
      ,' '                                                            as ag_contract_header_id
      ,' '                                                            as num_ad
      ,' '                                                            as category_name
      ,' '                                                            as date_begin
  from ins.contact             c,
--       ins.cn_contact_address  ca,
       ins.cn_address          adr,
       ins.t_city              city,
       ins.t_region            reg,
       ins.t_district          distr,
       ins.t_province          prov,
       ins.t_street            street,
       (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
          from ins.cn_contact_ident ii
         where ii.id_type    = 20001
           and ii.issue_date = (select max(ps.issue_date)
                                  from ins.cn_contact_ident ps
                                 where ps.id_type    = ii.id_type
                                   and ps.contact_id = ii.contact_id
                                )
       ) pasp_rf,
       (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
          from ins.cn_contact_ident ii
         where ii.id_type = 104
       ) pens,
       (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
          from ins.cn_contact_ident ii
         where ii.id_type = 1
       ) inn
      ,ins.cn_contact_bank_acc bacc
      ,ins.contact             bank
/*      ,(select ci.contact_id, ci.id_value as val
          from ins.cn_contact_ident ci
         where ci.id_type = 10 -- 'BIK'
       ) b_bik*/
/*      ,(select ci.contact_id, ci.id_value as val
          from ins.cn_contact_ident ci
         where ci.id_type = 11 -- 'KORR'
       ) b_cor*/
      ,(select ci.contact_id, ci.id_value as val
          from ins.cn_contact_ident ci
         where ci.id_type = 1 -- 'INN'
       ) b_inn
  where pasp_rf.contact_id(+)                             = c.contact_id
    and pens.contact_id(+)                                = c.contact_id
    and inn.contact_id(+)                                 = c.contact_id
/*
    and ins.pkg_contact.get_primary_address(c.contact_id) = ca.adress_id
    and c.contact_id                                      = ca.contact_id -- на PROD скорее всего можно убрать
    and adr.id(+)                                         = ca.adress_id
*/
    and ins.pkg_contact.get_primary_address(c.contact_id) = adr.id(+)
    and city.city_id(+)                                   = adr.city_id
    and reg.region_id(+)                                  = adr.region_id
    and prov.province_id(+)                               = adr.province_id
    and distr.district_id(+)                              = adr.district_id
    and street.street_id(+)                               = adr.street_id
    and c.contact_id                                      = bacc.contact_id (+)
    and bacc.bank_id                                      = bank.contact_id (+)
--    and bank.contact_id                                   = b_bik.contact_id (+)
--    and bank.contact_id                                   = b_cor.contact_id (+)
    and bank.contact_id                                   = b_inn.contact_id (+);

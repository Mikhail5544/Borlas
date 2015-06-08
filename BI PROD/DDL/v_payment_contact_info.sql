create or replace view v_payment_contact_info as
select rownum                                                         as num
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
      ,nvl(adr.region_name,' ')                                       as region_name
      ,nvl(adr.region_type,' ')                                       as reg_type
      ,nvl(adr.province_name,' ')                                     as province_name
      ,nvl(adr.province_type,' ')                                     as prv_type
      ,nvl(adr.city_name,' ')                                         as city_name
      ,nvl(adr.city_type,' ')                                         as ct_type
      ,nvl(adr.district_type,' ')                                     as dst_type
      ,nvl(adr.district_name,' ')                                     as district_name
      ,nvl(adr.street_name,' ')                                       as street_name
      ,nvl(adr.street_type,' ')                                       as str_type
      ,nvl(adr.house_nr,' ')                                          as house_nr
      ,nvl(adr.building_name,' ')                                     as building_name
      ,nvl(adr.appartment_nr,' ')                                     as appartment_nr
      ,nvl(adr.zip,' ')                                               as zip
      ,nvl(adr.name,' ')                                              as address_name
      ,(select ci.id_value
          from ins.cn_contact_ident ci
         where ci.id_type    = 10 -- 'BIK'
           and ci.contact_id = bank.contact_id
           and ci.table_id = pkg_contact.get_contact_document_id(bank.contact_id, 'BIK') --273400	Сломалась вью insi.v_payment_contact_info_facade 
       ) 
                                                                      as bik_bank 
      ,bank.obj_name_orig                                             as name_bank
      ,(select ci.id_value
          from ins.cn_contact_ident ci
         where ci.id_type = 11 -- 'KORR'
           and ci.contact_id = bank.contact_id
           and ci.table_id = pkg_contact.get_contact_document_id(bank.contact_id, 'KORR')  --273400	Сломалась вью insi.v_payment_contact_info_facade  
       ) 
                                                                      as corraccount_bank 
      ,nvl(bacc.account_nr,' ')                                       as raccount_bank
      ,coalesce(bacc.lic_code,bacc.account_corr,' ')                  as licaccount_bank
      ,nvl(b_inn.val,' ')                                             as inn_bank
      ,c.contact_id                                                   as contact_id
      ,' '                                                            as ag_contract_header_id
      ,' '                                                            as num_ad
      ,' '                                                            as category_name
      ,' '                                                            as date_begin
  from ins.contact             c,
       ins.cn_address          adr,
       --273400	Сломалась вью insi.v_payment_contact_info_facade 
       (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
          FROM ins.cn_contact_ident ii
               ,ins.t_id_type tit
          WHERE ii.id_type = 20001
            AND pkg_contact.get_ident_date(ii.contact_id,tit.brief) = ii.issue_date
            and tit.id = ii.id_type
       )
        pasp_rf,
        --end_273400
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
      ,(select ci.contact_id, ci.id_value as val
          from ins.cn_contact_ident ci
         where ci.id_type = 1 -- 'INN'
       ) b_inn
  where pasp_rf.contact_id(+)                             = c.contact_id
    and pens.contact_id(+)                                = c.contact_id
    and inn.contact_id(+)                                 = c.contact_id
    and ins.pkg_contact.get_primary_address(c.contact_id) = adr.id(+)
    and c.contact_id                                      = bacc.contact_id (+)
    and 1                                                 = bacc.used_flag (+)
    and pkg_contact.get_primary_banc_acc(c.contact_id)    = bacc.id(+) -- 275732 --задвоение банк реквизитов
    and bacc.bank_id                                      = bank.contact_id (+)
    and bank.contact_id                                   = b_inn.contact_id (+);




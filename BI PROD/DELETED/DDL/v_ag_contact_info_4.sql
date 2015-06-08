--CREATE OR REPLACE VIEW INS.V_AG_CONTACT_INFO AS
select NUM,
       name,
       first_name,
       middle_name,
       birth_date,
       ser_pasp,
       num_pasp,
       issue_date_pasp,
       place_issue_pasp,
       num_pens,
       iin_contact,
       region_name,
       reg_type,
       province_name,
       prv_type,
       city_name,
       ct_type,
       dst_type,
       district_name,
       street_name,
       str_type,
       house_nr,
       building_name,
       appartment_nr,
       zip,
       address_name,
        bik_bank,
        name_bank,
        raccount_bank,
        licaccount_bank,
        contact_id,
        ag_contract_header_id,
        num_ad,
        category_name,
        date_begin

from
(
select row_number() over (partition by c.contact_id order by pasp_rf.is_default desc) num,
       NVL(c.NAME,' ') name,
       NVL(c.first_name,' ') first_name,
       NVL(c.middle_name,' ') middle_name,
       NVL(TO_CHAR(pkg_contact.get_birth_date(c.contact_id)),' ') birth_date,
       NVL(pasp_rf.serial_nr,' ') ser_pasp,
       NVL(pasp_rf.id_value,' ') num_pasp,
       NVL(to_char(pasp_rf.issue_date),' ') issue_date_pasp,
       NVL(pasp_rf.place_of_issue,' ') place_issue_pasp,
       NVL(pens.id_value,' ') num_pens,
       NVL(inn.id_value,' ') iin_contact,
       NVL(reg.region_name,' ') region_name,
       NVL((select rg.description_short from ins.t_region_type rg where rg.region_type_id = reg.region_type_id),' ') reg_type,
       NVL(prov.province_name,' ') province_name,
       NVL((select prv.description_short from ins.t_province_type prv where prv.province_type_id = prov.province_type_id),' ') prv_type,
       --nvl(city.city_name,adr.city_name) city_name,
       NVL(city.city_name,' ') city_name,
       NVL((select ct.description_short from ins.t_city_type ct where ct.city_type_id = city.city_type_id),' ') ct_type,
       NVL((select dst.description_short from ins.t_district_type dst where dst.district_type_id = distr.district_type_id),' ') dst_type,
       NVL(distr.district_name,' ') district_name,
       --nvl(street.street_name,adr.street_name) street_name,
       NVL(street.street_name,' ') street_name,
       NVL((select str.description_short from ins.t_street_type str where str.street_type_id = street.street_type_id),' ') str_type,
       NVL(adr.house_nr,' ') house_nr,
       NVL(adr.building_name,' ') building_name,
       NVL(adr.appartment_nr,' ') appartment_nr,
       NVL(adr.zip,' ') zip,

       NVL(adr.name,' ') address_name,
       nvl(bbk.bik_bank,bbkn.bik_bank) bik_bank, 
       nvl(bbk.name_bank,bbkn.name_bank) name_bank,
       nvl(bbk.raccount_bank,bbkn.raccount_bank) raccount_bank,
       nvl(bbk.licaccount_bank,bbkn.licaccount_bank) licaccount_bank,
       /*nvl(nvl((select ii.id_value
            from ins.ven_ag_bank_props bank,
                 ins.contact c,
                 ins.cn_contact_ident ii,
                 ins.t_id_type t
            where bank.ag_contract_header_id = ag.ag_contract_header_id
                  and c.contact_id = bank.bank_id
                  and c.contact_id = ii.contact_id
                  and ii.id_type = t.id
                  and t.brief = 'BIK'
                  and nvl(bank.enable,0) = 1),
              (select ii.id_value
                from ins.ven_ag_bank_props bank,
                     ins.contact c,
                     ins.cn_contact_ident ii,
                     ins.t_id_type t
                where bank.ag_contract_header_id = ag.ag_contract_header_id
                      and c.contact_id = bank.bank_id
                      and c.contact_id = ii.contact_id
                      and ii.id_type = t.id
                      and t.brief = 'BIK'
                      and rownum = 1)),' ') bik_bank,
         NVL((nvl((select c.obj_name_orig
                    from ins.ven_ag_bank_props bank,
                         ins.contact c
                    where bank.ag_contract_header_id = ag.ag_contract_header_id
                          and c.contact_id = bank.bank_id
                          and nvl(bank.enable,0) = 1),
              (select c.obj_name_orig
              from ins.ven_ag_bank_props bank,
                   ins.contact c
              where bank.ag_contract_header_id = ag.ag_contract_header_id
              and c.contact_id = bank.bank_id
              and rownum = 1))),' ') name_bank,
        NVL(nvl((select bank.account
        from ins.ven_ag_bank_props bank
        where bank.ag_contract_header_id = ag.ag_contract_header_id
              and nvl(bank.enable,0) = 1),
              (select bank.account
              from ins.ven_ag_bank_props bank
              where bank.ag_contract_header_id = ag.ag_contract_header_id
                    and rownum = 1)),' ') raccount_bank,
       NVL(nvl((select bank.payment_props
        from ins.ven_ag_bank_props bank
        where bank.ag_contract_header_id = ag.ag_contract_header_id
              and nvl(bank.enable,0) = 1),
              (select bank.payment_props
              from ins.ven_ag_bank_props bank
              where bank.ag_contract_header_id = ag.ag_contract_header_id
                    and rownum = 1)),' ') licaccount_bank,*/
        c.contact_id contact_id,
        ag.ag_contract_header_id ag_contract_header_id,
        NVL(d.num,' ') num_ad,
        NVL(cat.category_name,' ') category_name,
        ag.date_begin
from ins.ag_contract_header ag,
     ins.ag_contract cr,
     ins.document d,
     ins.contact c,
     ins.cn_contact_address ca,
     ins.cn_address adr,
     ins.t_city city,
     ins.t_region reg,
     ins.t_district distr,
     ins.t_province prov,
     ins.t_street street,
     ins.ag_category_agent cat,
     (select nvl(ii.is_default,0) is_default, ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
      from ins.cn_contact_ident ii
      where ii.id_type = 20001
      order by nvl(ii.is_default,0) desc) pasp_rf,
      (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
      from ins.cn_contact_ident ii
      where ii.id_type = 104) pens,
      (select ii.contact_id, ii.serial_nr, ii.id_value, ii.issue_date, ii.place_of_issue
      from ins.cn_contact_ident ii
      where ii.id_type = 1) inn,
      
      
      (select bank.ag_contract_header_id, bik.id_value bik_bank, bik.obj_name_orig name_bank, bank.account raccount_bank, bank.payment_props licaccount_bank
      from ins.ven_ag_bank_props bank,
           (select ii.id_value, c.contact_id, c.obj_name_orig
            from ins.contact c,
                 ins.cn_contact_ident ii,
                 ins.t_id_type t
            where c.contact_id = ii.contact_id
                  and ii.id_type = t.id
                  and t.brief = 'BIK') bik
       where bank.bank_id = bik.contact_id
             and nvl(bank.enable,0) = 1
             ) bbk,
       (select bank.ag_contract_header_id, bik.id_value bik_bank, bik.obj_name_orig name_bank, bank.account raccount_bank, bank.payment_props licaccount_bank
      from ins.ven_ag_bank_props bank,
           (select ii.id_value, c.contact_id, c.obj_name_orig
            from ins.contact c,
                 ins.cn_contact_ident ii,
                 ins.t_id_type t
            where c.contact_id = ii.contact_id
                  and ii.id_type = t.id
                  and t.brief = 'BIK') bik
       where bank.bank_id = bik.contact_id
             and rownum = 1
             ) bbkn
      

where ag.is_new = 1
      and ag.agent_id = c.contact_id
      and ag.ag_contract_header_id = d.document_id
      and ag.ag_contract_header_id = cr.contract_id
      and sysdate between cr.date_begin and cr.date_end
      --and ag.last_ver_id = cr.ag_contract_id
      and cat.ag_category_agent_id = cr.category_id
      and pasp_rf.contact_id(+) = c.contact_id
      and pens.contact_id(+) = c.contact_id
      and inn.contact_id(+) = c.contact_id
      
      --and ag.ag_contract_header_id = 22731731

      and bbk.ag_contract_header_id(+) = ag.ag_contract_header_id
      and bbkn.ag_contract_header_id(+) = ag.ag_contract_header_id
      
      and pkg_contact.get_primary_address(c.contact_id) = ca.adress_id
      
      --and c.contact_id = ca.contact_id(+)
      and adr.id(+) = ca.adress_id
      and city.city_id(+) = adr.city_id
      and reg.region_id(+) = adr.region_id
      and prov.province_id(+) = adr.province_id
      and distr.district_id(+) = adr.district_id
      and street.street_id(+) = adr.street_id
      and (doc.get_doc_status_brief(ag.ag_contract_header_id) in ('CURRENT','NEW')
           OR (doc.get_doc_status_brief(ag.ag_contract_header_id) in ('BREAK') AND
           NOT EXISTS (SELECT NULL 
                         FROM ag_contract_header ach_n
                        WHERE ach_n.Is_New = 1
                          AND ach_n.agent_id = ag.agent_id
                          AND doc.get_doc_status_brief(ach_n.ag_contract_header_id) in ('CURRENT','NEW'))))
      )
where num = 1 

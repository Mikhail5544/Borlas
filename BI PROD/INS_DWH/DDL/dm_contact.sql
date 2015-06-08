create materialized view INS_DWH.DM_CONTACT
refresh force on demand
as
select c.contact_id,
       c.obj_name,
       decode(ct.is_individual, 1, 'ƒ', 0, 'Ќ') is_invididual,
       cntel.tel,
       inn.id_value inn,
       pens.id_value pens,
       pass.id_value pass,
       pass_data.id_value pass_data,
       DECODE(nvl(mat_leave.contact_id,0),0,'','ƒекрет') mat_leave,
       p.date_of_birth,
       decode(p.gender, 1, 'ћ', 0, '∆', 'Ќ') gender,
       cna.country_name,
       cna.region_name,
       cna.region_type,
       cna.province_name,
       cna.province_type,
       cna.city_name,
       cna.city_type,
       cna.district_name,
       cna.district_type,
       cna.street_name,
       cna.street_type,
       cna.house_nr,
       cna.block_number,
       cna.appartment_nr,
       cna.zip,
       cna.address_name address,
       cna.address_type address_type,
        t_home.tel tel_home,
        t_PERS.tel tel_PERS,
        t_FAX.tel tel_FAX,
        t_WORK.tel tel_WORK,
        t_MOBIL.tel tel_MOBIL,
        t_TELEX.tel tel_TELEX,
        t_CONT.tel tel_CONT,
        e_mail.email,
        decode(nvl(c.resident_flag,0),1,'–езидент',0,'Ќе резидент','Ќе определно') flag_resident,
        TO_CHAR(p.date_of_death,'DD.MM.YYYY') date_of_death,
        c.is_public_contact ipdl,
        tr.description risk_level


  from ins.contact c,
       ins.cn_person p,
       ins.cn_company cm,
       ins.t_contact_type ct,
       ins.t_risk_level tr,
       -- адресс по умолчанию
         ( select cad.contact_id,
                 adress.country_name,
                 adress.region_name,
                 adress.region_type,
                 adress.province_name,
                 adress.province_type,
                 adress.city_name,
                 adress.city_type,
                 adress.district_name,
                 adress.district_type,
                 adress.street_name,
                 adress.street_type,
                 adress.house_nr,
                 adress.block_number,
                 adress.appartment_nr,
                 adress.zip,
                 adress.address_name,
                 cad.address_type
            from (select contact_id, adress_id, address_type
                    from (select ca.contact_id,
                                 ca.adress_id,
                                 adt.description address_type,
                                 row_number() over(partition by ca.contact_id order by decode(adt.id, 2, 1,3,1,0) desc, nvl(ca.is_default, 0)  desc) rn
                            from ins.cn_contact_address ca, ins.t_address_type adt
                            where adt.id = ca.address_type) t
                   where rn = 1) cad,
               (select adr.id adr_id,
                       country.description country_name,
                       adr.region_name,
                       adr.region_type,
                       adr.province_name,
                       adr.province_type,
                       adr.city_name,
                       adr.city_type,
                       adr.district_name,
                       adr.district_type,
                       adr.street_name,
                       adr.street_type,
                       adr.house_nr,
                       adr.block_number,
                       adr.appartment_nr,
                       adr.zip,
                       nvl(adr.name,ins.pkg_contact.get_address_name(adr.id)) address_name

                  from ins.cn_address adr,
                       ins.t_country  country
                 where 1 = 1
                   and country.id = adr.country_id
                 ) adress

         where cad.adress_id = adress.adr_id ) cna,

       (select * from
        (select ci.contact_id, ci.id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'INN') inn1
           where inn1.rn = 1) inn,
       (select * from
        (select ci.contact_id, ci.serial_nr || '#' || ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'PASS_RF') pass1
           where pass1.rn = 1) pass,
       (select * from
        (select ci.contact_id, ci.serial_nr || ' є ' || ci.id_value ||', ¬ыдан: '||
                               ci.place_of_issue ||', ƒата выдачи: '|| ci.issue_date id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'PASS_RF') pass1
           where pass1.rn = 1) pass_data,
       (select * from
        (select ci.contact_id, ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'PENS') pens1
           where pens1.rn = 1) pens,
       (select * from
        (select ci.contact_id, ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'MATERNITY_LEAVE'
           and sysdate between ci.issue_date and nvl(ci.termination_date,to_date('31.12.3000','dd.mm.yyyy'))
           ) lv
           where lv.rn = 1) mat_leave,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt) cnt1
         where cnt1.rn = 1) cntel,

       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'HOME'
               ) cnt1
         where cnt1.rn = 1
       ) t_home,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'PERS'
               ) cnt1
         where cnt1.rn = 1
       ) t_PERS,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'FAX'
               ) cnt1
         where cnt1.rn = 1
       ) t_FAX,

       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'WORK'
               ) cnt1
         where cnt1.rn = 1
       ) t_WORK,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'MOBIL'
               ) cnt1
         where cnt1.rn = 1
       ) t_MOBIL,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'TELEX'
               ) cnt1
         where cnt1.rn = 1
       ) t_TELEX,
       (select cnt1.*
          from (select cnt.contact_id,
                       row_number() over(partition by cnt.contact_id order by cnt.id) rn,
                       cnt.telephone_prefix || cnt.telephone_number ||
                       cnt.telephone_extension || cnt.remarks tel
                  from ins.cn_contact_telephone cnt,
                       ins.t_telephone_type tt
                 WHERE tt.ID = cnt.telephone_type
                   AND tt.brief = 'CONT'
               ) cnt1
         where cnt1.rn = 1
       ) t_CONT,
       (select cce.*
          from (select ce.contact_id,
                       row_number() over(partition by ce.contact_id order by ce.email_type) rn,
                       ce.email
                  from ins.cn_contact_email ce
               ) cce
         where cce.rn = 1
       ) e_mail


 where c.contact_id = p.contact_id(+)
   and c.contact_id = cm.contact_id(+)
   and c.risk_level = tr.t_risk_level_id(+)
   and c.contact_id = cna.contact_id(+)
   and c.contact_id = inn.contact_id(+)
   and c.contact_id = pass.contact_id(+)
   and c.contact_id = pass_data.contact_id(+)
   and c.contact_id = pens.contact_id(+)
   and c.contact_id = mat_leave.contact_id(+)
   and c.contact_type_id = ct.id
   and c.contact_id = cntel.contact_id(+)
    and c.contact_id = t_home.contact_id(+)
     and c.contact_id = t_PERS.contact_id(+)
      and c.contact_id = t_FAX.contact_id(+)
       and c.contact_id = t_WORK.contact_id(+)
        and c.contact_id = t_MOBIL.contact_id(+)
         and c.contact_id = t_TELEX.contact_id(+)
          and c.contact_id = t_CONT.contact_id(+)
          AND c.contact_id = e_mail.contact_id(+)
union all
select -1 contact_id,
       'неопределен' obj_name,
       null,
       'неопределен' tel,
       'неопределен' inn,
       'неопределен' pens,
       'неопределен' pass,
       'неопределен' pass_data,
       'неопределен' mat_leave,
        null date_of_birth,
       'Ќ' gender,
       'неопределен' country_name,
       'неопределен' region_name,
       'неопределен' region_type,
       'неопределен' province_name,
       'неопределен' province_type,
       'неопределен' city_name,
       'неопределен' city_type,
       'неопределен' district_name,
       'неопределен' district_type,
       'неопределен' street_name,
       'неопределен' street_type,
       'неопределен' house_nr,
       'неопределен' block_number,
       'неопределен' appartment_nr,
       'неопределен' zip,
       'неопределен' address,
       'неопределен' address_type,
       'неопределен' tel_home,
       'неопределен' tel_PERS,
       'неопределен' tel_FAX,
       'неопределен' tel_WORK,
       'неопределен' tel_MOBIL,
       'неопределен' tel_TELEX,
       'неопределен' tel_CONT,
       'неопределен' email,
       'неопределен' flag_resident,
       'неопределен' date_of_death,
       0 ipdl,
       'неопределен' risk_level
       from dual;



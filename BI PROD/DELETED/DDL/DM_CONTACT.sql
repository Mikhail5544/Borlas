create materialized view INS_DWH.DM_CONTACT
refresh force on demand
as
select c.contact_id,
       c.obj_name,
       decode(ct.is_individual, 1, '�', 0, '�') is_invididual,
       cntel.tel,
       inn.id_value inn,
       pens.id_value pens,
       pass.id_value pass,
       pass_data.id_value pass_data,
       DECODE(nvl(mat_leave.contact_id,0),0,'','������') mat_leave,
       p.date_of_birth,
       decode(p.gender, 1, '�', 0, '�', '�') gender,
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
        decode(nvl(c.resident_flag,0),1,'��������',0,'�� ��������','�� ���������') flag_resident


  from ins.contact c,
       ins.cn_person p,
       ins.cn_company cm,
       ins.t_contact_type ct,
       -- ������ �� ���������
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
                       reg.region_name,
                       reg.region_type,
                       prov.province_name,
                       prov.province_type,
                       city.city_name,
                       city.city_type,
                       distr.district_type,
                       distr.district_name,
                       street.street_name,
                       street.street_type,
                       adr.house_nr,
                       adr.block_number,
                       --adr.building_name,
                       adr.appartment_nr,
                       adr.zip,
--                       nvl(adr.name,ins.ent.obj_name(213, adr.id))*/
                       nvl(adr.name,ins.pkg_contact.get_address_name(adr.id)) address_name

                  from ins.cn_address adr,
                       (select ct.description_short city_type, city1.city_id, city1.city_name
                          from ins.t_city_type ct, ins.t_city city1
                         where ct.city_type_id = city1.city_type_id)city,
                       (select rg.description_short region_type, reg1.region_name, reg1.region_id
                          from ins.t_region_type rg, ins.t_region reg1
                         where rg.region_type_id = reg1.region_type_id) reg,
                       (select dst.description_short district_type, distr1.district_name, distr1.district_id
                          from ins.t_district_type dst, ins.t_district distr1
                         where dst.district_type_id = distr1.district_type_id) distr,
                       (select prv.description_short province_type, prov1.province_id, prov1.province_name
                          from ins.t_province_type prv, ins.t_province prov1
                         where prv.province_type_id = prov1.province_type_id) prov,
                       (select str.description_short street_type, street1.street_id, street1.street_name
                          from ins.t_street_type str, ins.t_street street1
                         where str.street_type_id = street1.street_type_id)   street,
                       ins.t_country  country

                 where 1 = 1
                   and city.city_id(+) = adr.city_id
                   and reg.region_id(+) = adr.region_id
                   and prov.province_id(+) = adr.province_id
                   and distr.district_id(+) = adr.district_id
                   and street.street_id(+) = adr.street_id
                   and country.id = adr.country_id) adress

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
        (select ci.contact_id, ci.serial_nr || ' � ' || ci.id_value ||', �����: '||
                               ci.place_of_issue ||', ���� ������: '|| ci.issue_date id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
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
       '�����������' obj_name,
       null,
       '�����������' tel,
       '�����������' inn,
       '�����������' pens,
       '�����������' pass,
       '�����������' pass_data,
       '�����������' mat_leave,
        null date_of_birth,
       '�' gender,
       '�����������' country_name,
       '�����������' region_name,
       '�����������' region_type,
       '�����������' province_name,
       '�����������' province_type,
       '�����������' city_name,
       '�����������' city_type,
       '�����������' district_name,
       '�����������' district_type,
       '�����������' street_name,
       '�����������' street_type,
       '�����������' house_nr,
       '�����������' block_number,
       '�����������' appartment_nr,
       '�����������' zip,
       '�����������' address,
       '�����������' address_type,
       '�����������' tel_home,
       '�����������' tel_PERS,
       '�����������' tel_FAX,
       '�����������' tel_WORK,
       '�����������' tel_MOBIL,
       '�����������' tel_TELEX,
       '�����������' tel_CONT,
       '�����������' email,
       '�����������' flag_resident

       from dual;
       
GRANT SELECT ON INS_DWH.DM_CONTACT TO INS_EUL;
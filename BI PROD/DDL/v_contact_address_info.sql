create or replace view v_contact_address_info as
select co.contact_id
      ,tr.region_name
      ,rt.description_short as reg_type
      ,tp.province_name
      ,pt.description_short as prv_type
      ,tc.city_name
      ,ct.description_short as ct_type
      ,td.district_name
      ,dt.description_short as dst_type
      ,ts.street_name
      ,st.description_short as str_type
      ,ad.house_nr
      ,ad.building_name
      ,ad.appartment_nr
      ,ad.zip
      ,ad.name as address_name
  from contact            co
      ,cn_address         ad
      ,t_region           tr
      ,t_region_type      rt
      ,t_province         tp
      ,t_province_type    pt
      ,t_city             tc
      ,t_city_type        ct
      ,t_district         td
      ,t_district_type    dt
      ,t_street           ts
      ,t_street_type      st
 where pkg_contact.get_primary_address(co.contact_id) = ad.id
   and ad.region_id        = tr.region_id   (+)
   and tr.region_type_id   = rt.region_type_id (+)
   and ad.province_id      = tp.province_id (+)
   and tp.province_type_id = pt.province_type_id (+)
   and ad.city_id          = tc.city_id     (+)
   and tc.city_type_id     = ct.city_type_id (+)
   and ad.district_id      = td.district_id (+)
   and td.district_type_id = dt.district_type_id (+)
   and ad.street_id        = ts.street_id   (+)
   and ts.street_type_id   = st.street_type_id (+);

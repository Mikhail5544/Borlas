create or replace force view v_contact_address_info_facade as
select "CONTACT_ID","REGION_NAME","REG_TYPE","PROVINCE_NAME","PRV_TYPE","CITY_NAME","CT_TYPE","DISTRICT_NAME","DST_TYPE","STREET_NAME","STR_TYPE","HOUSE_NR","BUILDING_NAME","APPARTMENT_NR","ZIP","ADDRESS_NAME"
    from ins.v_contact_address_info;


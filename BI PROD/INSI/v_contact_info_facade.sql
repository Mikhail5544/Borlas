create or replace force view v_contact_info_facade as
select "CONTACT_ID","NAME","FULL_NAME","INN","KPP","DESCRIPTION"
    from ins.v_contact_info;


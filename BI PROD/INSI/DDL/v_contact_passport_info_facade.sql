create or replace force view v_contact_passport_info_facade as
select "CONTACT_ID","DESCRIPTION","SER_PASP","NUM_PASP","ISSUE_DATE","PLACE_ISSUE_PASP"
    from ins.v_contact_passport_info;


create or replace force view v_contact_face_info_facade as
select "CONTACT_ID","NAME","FIRST_NAME","MIDDLE_NAME","BIRTH_DATE","NUM_PENS","INN_CONTACT"
    from ins.v_contact_face_info;


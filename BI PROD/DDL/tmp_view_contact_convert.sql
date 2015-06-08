create or replace force view tmp_view_contact_convert as
select "CONTACT_ID","ENT_ID","FILIAL_ID","NAME","FIRST_NAME","MIDDLE_NAME","CONTACT_TYPE_ID","SHORT_NAME","LATIN_NAME","RESIDENT_FLAG","T_CONTACT_STATUS_ID","EXT_ID","DESCRIPTION","NOTE","GENITIVE","ACCUSATIVE","DATIVE","INSTRUMENTAL" from contact c where c.ext_id is not null;


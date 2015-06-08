create or replace force view v_cr_brokeage_lov as
select "CONTACT_ID","CONTACT_NAME","DEPARTMENT_ID","DEPARTMENT_NAME","ORGANISATION_TREE_ID","ORGANISATION_NAME" from v_brokeage;


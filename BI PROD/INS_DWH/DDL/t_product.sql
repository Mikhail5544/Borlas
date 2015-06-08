create or replace force view ins_dwh.t_product as
select "PRODUCT_ID","ENT_ID","FILIAL_ID","EXT_ID","ASSET_FORM","BRIEF","BSO_TYPE_ID","CLAIM_DEPARTMENT_ID","CLAIM_DEPT_ROLE_ID","DEPARTMENT_ID","DEPT_ROLE_ID","DESCRIPTION","ENABLED","T_POLICY_FORM_TYPE_ID" from ins.ven_t_product;


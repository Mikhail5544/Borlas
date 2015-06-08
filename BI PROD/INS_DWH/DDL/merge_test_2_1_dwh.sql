create or replace force view ins_dwh.merge_test_2_1_dwh as
select p.POLICY_HEADER_ID from DM_P_POL_HEADER p 
where p.START_DATE < to_date('01.09.2007','dd.mm.yyyy') 
and p.END_DATE > to_date('01.12.2007','dd.mm.yyyy');


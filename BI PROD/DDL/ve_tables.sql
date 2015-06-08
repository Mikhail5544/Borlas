create or replace force view ve_tables as
select "CHECK_EXCL_ID","EXCL_TYPE","NAME" from check_excl ce where ce.excl_type = 'ENT';


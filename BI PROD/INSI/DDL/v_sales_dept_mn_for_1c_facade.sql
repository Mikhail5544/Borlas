create or replace view insi.v_sales_dept_mn_for_1c_facade as
select "UNIVERSAL_CODE","CONTACT_ID","NAME","FIRST_NAME","MIDDLE_NAME","DATE_OF_BIRTH","FIRST_DAY_AT_AGENCY"
  from ins.v_sales_dept_mn_for_1c;

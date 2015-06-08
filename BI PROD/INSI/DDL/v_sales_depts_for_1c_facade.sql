create or replace view insi.v_sales_depts_for_1c_facade as
select "UNIVERSAL_CODE","PARENT_UNIVERSAL_CODE","DEPT_NAME","LEGAL_NAME"
  from ins.v_sales_depts_for_1c;

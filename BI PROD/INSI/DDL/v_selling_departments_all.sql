create or replace force view v_selling_departments_all as
select to_char(sh.universal_code,'FM0009') as universal_code
      ,to_char(psh.universal_code,'FM0009') as parent_universal_code
      ,sd.dept_name
      ,sd.legal_name
      ,sd.kpp
  from ins.ven_sales_dept        sd
      ,ins.ven_sales_dept_header sh
      ,ins.ven_sales_dept_header psh
 where sh.last_sales_dept_id = sd.sales_dept_id
   and sd.branch_id          = psh.organisation_tree_id (+);


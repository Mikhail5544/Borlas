create or replace view v_sales_depts_for_1c as
select to_char(sh.universal_code,'FM0009') as universal_code -- Универсальный код подразделения
      ,to_char(shp.universal_code,'FM0009') as parent_universal_code -- Универсальный код родителя
      ,sd.dept_name                                                  -- Название подразделения BI
      ,sd.legal_name                                                 -- Название подразделения Юридическое (1С)
  from sales_dept_header sh
      ,sales_dept        sd
      ,sales_dept_header shp
 where sh.last_sales_dept_id = sd.sales_dept_id
   and sd.branch_id          = shp.organisation_tree_id (+);

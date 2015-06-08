create or replace force view ins_dwh.fc_direct_costs as
select entry_no,
       account_date,
       department_id_nav,
       direct_costs_item_id_nav,
       company_inn,
       company_kpp,
       costs_amount,
       department_name_nav,
       cfr_id,
       direct_costs_name_nav,
       direct_costs_item_id_nav as direct_costs_item_id,
       company_id,
       sys_source_id from etl.jr_direct_costs;


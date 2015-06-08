create or replace force view v_prod_line_damage as
select
    dc.id,
    dc.description,
    dc.peril,
    dc.is_default,
    dc.code,
    plop.id prod_line_opt_peril_id,
    (select max(pld.t_prod_line_damage_id) from t_prod_line_damage pld where pld.t_damage_code_id = dc.id and pld.t_prod_line_opt_peril_id = plop.id) prod_line_damage_id
  from
    t_prod_line_opt_peril plop,
    t_damage_code dc
  where
    plop.peril_id = dc.peril;


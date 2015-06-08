create or replace force view v_warehouse_types_code as
select "NUM","DESCRIPTION","CODE","T_WAREHOUSE_CODE_ID","ACT_TYPE_DESCR"
  from (select 0 num,
               'Хранение в ямах, бункерах' description,
               bunker_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = bunker_code) act_type_descr
          from t_warehouse_code
        union
        select 1 num,
               'У1 - Без упаковки' description,
               u1_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = u1_code) act_type_descr
          from t_warehouse_code
        union
        select 2 num,
               'У2 - Негорючая упаковка' description,
               u2_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = u2_code) act_type_descr
          from t_warehouse_code
        union
        select 3 num,
               'У3 - Частично горючая упаковка' description,
               u3_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = u3_code) act_type_descr
          from t_warehouse_code
        union
        select 4 num,
               'У4 - Полностью горючая упаковка' description,
               u4_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = u4_code) act_type_descr
          from t_warehouse_code
        union
        select 5 num,
               'У5 - Полностью горючая упаковка из материалов интенсивно развивающих горение и способных образовывать горящие расплавы' description,
               u5_code code,
               t_warehouse_code_id,
               (select description || ' (класс риска "' || risk_class || '")' description from t_act_type_code where code = u5_code) act_type_descr
          from t_warehouse_code)
 where code is not null
 order by num;


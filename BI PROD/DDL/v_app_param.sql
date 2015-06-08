create or replace force view v_app_param as
select
    ap.app_param_id,
    ap.ent_id,
    ap.filial_id,
    ap.name,
    ap.brief,
    ap.def_value_c,
    ap.def_value_n,
    ap.def_value_d,
    ap.def_value_ure_id,
    e.name def_value_ure_name,
    ap.def_value_uro_id,
    ent.obj_name(ap.def_value_ure_id, ap.def_value_uro_id) def_value_uro_name,
    ap.param_type,
    case ap.param_type
      when 0 then 'Строка'
      when 1 then 'Число'
      when 2 then 'Дата'
      when 3 then 'Ссылка'
      else 'Неизв.тип'
    end param_type_name,
    case ap.param_type
      when 0 then ap.def_value_c
      when 1 then trim(to_char(ap.def_value_n, '999,999,999,999,999.99'))
      when 2 then trim(to_char(ap.def_value_d, 'dd/mm/yyyy'))
      when 3 then ent.obj_name(ap.def_value_ure_id, ap.def_value_uro_id)
      else 'неизвестное значение'
    end disp_value,
    ap.app_param_group_id
  from
    App_Param ap,
    Entity e
  where
    ap.def_value_ure_id = e.ent_id(+);


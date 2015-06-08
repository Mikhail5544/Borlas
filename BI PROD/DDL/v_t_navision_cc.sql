create or replace view v_t_navision_cc as
select cc.t_navision_cc_id
      ,cc.ent_id
      ,cc.filial_id
      ,cc.ext_id
      ,cc.cc_code
      ,cc.cc_name
      ,cc.open_date
      ,nullif(cc.close_date,to_date('31.12.3000','dd.mm.yyyy')) as close_date
      ,cc.deleted
      ,cc.id_1c
  from ven_t_navision_cc cc;

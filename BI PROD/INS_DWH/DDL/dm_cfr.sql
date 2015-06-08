create or replace force view ins_dwh.dm_cfr as
select t.cfr_id, t.name, nvl(city.city_name, 'неопределено') city_name
  from etl.t_cfr t, (select to_char(agency_id) agency_id, t_city_id from mm_agency_city) mm, dm_t_city city
 where rtrim(ltrim(t.cfr_id)) = mm.agency_id (+)
   and mm.t_city_id = city.t_city_id(+);


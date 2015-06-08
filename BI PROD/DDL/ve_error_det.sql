create or replace force view ve_error_det as
select t.n n,
       e.ent_id id,
       e.name   name,
       e.brief  brief,
       e.source source,
       t.error  err
from ve_error t left outer join entity e on e.ent_id = t.ent_id;


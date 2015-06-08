create or replace force view v_t_attribut_entity as
select ae.t_attribut_entity_id t_attribut_entity_id,
       ae.t_attribut_id        t_attribut_id,
       ae.entity_id            entity_id,
       ae.obj_list_sql         obj_list_sql,
       e.parent_id             ent_parent_id,
       e.name                  ent_name,
       e.brief                 ent_brief,
       e.source                ent_source,
       e.obj_name              ent_obj_name   
from T_ATTRIBUT_ENTITY ae, 
     entity e
where ae.entity_id=e.ent_id;


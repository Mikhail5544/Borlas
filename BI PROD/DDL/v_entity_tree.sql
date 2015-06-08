create or replace force view v_entity_tree as
select lpad(e.name, length(e.name) + 10 * (LEVEL - 1), ' ') name, 
       e.ent_id, 
       e.source
from entity e
start with e.parent_id is null
connect by e.parent_id = prior e.ent_id
order siblings by e.name;


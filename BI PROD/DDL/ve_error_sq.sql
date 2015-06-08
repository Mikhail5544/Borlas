create or replace force view ve_error_sq as
select e.name entity, us.sequence_name sequence, us.last_number sq_id, fn_max_id(e.source, e.id_name) obj_id
  from user_sequences us 
       inner join entity e on e.parent_id is null
                              and 'SQ_' || e.source = us.sequence_name
  where us.last_number < fn_max_id(e.source, e.id_name);


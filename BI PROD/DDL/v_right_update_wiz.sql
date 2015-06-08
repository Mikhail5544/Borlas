create or replace force view v_right_update_wiz as
select q2.ent_id,
       q2.name,
       q2.brief
  from (select e.ent_id,
               name,brief
          from entity e
         ) q2,
       (select right_obj_id
          from safety_right sr, safety_right_type srt
         where srt.brief = 'UPDATE'
           and srt.safety_right_type_id = sr.safety_right_type_id) q1
 where q2.ent_id = q1.right_obj_id(+)
   and (q1.right_obj_id is null);


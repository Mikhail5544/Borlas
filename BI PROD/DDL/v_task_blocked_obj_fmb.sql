 create or replace view v_task_blocked_obj_fmb
  as
  SELECT t.t_task_id, t.num task_num, u.sys_user_name user_name, it.item_type_brief,  it.item_name, it.owner
    FROM t_task_item ti
        ,ven_t_task      t
        ,v_task_items_pkg it
        ,ven_sys_user   u
        ,ins.doc_status_ref dsr 
   WHERE ti.t_task_id = t.t_task_id
     AND it.item_type = ti.item_type
     AND it.item_name = ti.item_name
     AND t.doc_status_ref_id = dsr.doc_status_ref_id
     and t.user_id =  u.sys_user_id
     and dsr.brief = 'IT_APPROVE'
   union
  SELECT t.t_task_id, t.num task_num, u.sys_user_name user_name, it.item_type_brief,  it.item_name, null owner
    FROM t_task_item ti
        ,ven_t_task      t
        ,v_task_items_form it
        ,ven_sys_user   u
        ,ins.doc_status_ref dsr 
   WHERE ti.t_task_id = t.t_task_id
     AND it.item_type = ti.item_type
     AND it.item_name = ti.item_name
     AND t.doc_status_ref_id = dsr.doc_status_ref_id
     and t.user_id =  u.sys_user_id
     and dsr.brief = 'IT_APPROVE'
  order by item_type_brief desc, item_name;
  grant select on v_task_blocked_obj_fmb to ins_read;

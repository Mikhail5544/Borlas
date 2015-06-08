CREATE OR REPLACE VIEW v_task_items_queue AS
SELECT t1.t_task_id task1_id
      ,t2.t_task_id task2_id
  FROM t_task t1
      ,t_task t2
 WHERE t1.t_task_id != t2.t_task_id
   AND EXISTS (SELECT NULL
          FROM t_task_item ti1
              ,t_task_item ti2
         WHERE ti1.item_name = ti2.item_name
           AND ti1.item_type = ti2.item_type
           AND ti1.t_task_id = t1.t_task_id
           AND ti2.t_task_id = t2.t_task_id);
grant select on v_task_items_queue to ins_read;

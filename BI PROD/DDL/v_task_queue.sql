CREATE OR REPLACE VIEW v_task_queue AS
SELECT t1.t_task_id task1_id
      ,dsr1.brief task1_status_brief
      ,t2.t_task_id task2_id
      ,dsr2.brief task2_status_brief
  FROM ven_t_task t1
      ,ven_t_task t2
      ,doc_status_ref dsr1
      ,doc_status_ref dsr2
 WHERE t1.t_task_id != t2.t_task_id
   AND t1.doc_status_ref_id = dsr1.doc_status_ref_id (+)
   AND t2.doc_status_ref_id = dsr2.doc_status_ref_id (+)
   AND EXISTS (SELECT NULL
          FROM t_task_item ti1
              ,t_task_item ti2
         WHERE ti1.item_name = ti2.item_name
           AND ti1.item_type = ti2.item_type
           AND ti1.t_task_id = t1.t_task_id
           AND ti2.t_task_id = t2.t_task_id);
grant select on v_task_queue to ins_read;

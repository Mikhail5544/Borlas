CREATE OR REPLACE VIEW v_task_queue_fmb AS
SELECT t.t_task_id
      ,t.num
      ,TRUNC(t.reg_date) reg_date
      ,u.sys_user_name user_name
      ,dsr.brief status_brief
      ,dsr.name status_name
      ,t.user_id
      ,CASE dsr.brief
         WHEN 'COMPLETED' THEN
          1
         ELSE
          0
       END is_completed
      ,(SELECT wm_concat(t1.num) --over (order by t1.reg_date)
          FROM ven_t_task   t1
              ,v_task_queue q
         WHERE t1.t_task_id = q.task2_id
           AND q.task2_status_brief = 'IT_APPROVE'
           AND q.task1_id = t.t_task_id
           AND q.task1_status_brief = 'QUEUED') task_nums
  FROM ven_t_task     t
      ,ven_sys_user   u
      ,doc_status_ref dsr
 WHERE t.user_id = u.sys_user_id(+)
   AND t.doc_status_ref_id = dsr.doc_status_ref_id(+)
 ORDER BY CASE dsr.brief
            WHEN 'COMPLETED' THEN
             1
            WHEN 'CANCEL' THEN
             2
            ELSE
             0
          END ASC
         ,t.reg_date DESC;
grant select on v_task_queue_fmb to ins_read;

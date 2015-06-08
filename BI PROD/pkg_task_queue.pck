CREATE OR REPLACE PACKAGE pkg_task_queue IS

  -- Author  : Kaplya P.
  -- Created : 14.03.2013 
  -- Purpose : Управление очередью заявок

  FUNCTION addTask(par_num VARCHAR2) RETURN NUMBER;

  FUNCTION addTaskItem
  (
    par_task_id   NUMBER
   ,par_item_name VARCHAR2
   ,par_item_type NUMBER
  ) RETURN NUMBER;

  FUNCTION addTaskToQueue(par_task_id NUMBER) RETURN NUMBER;

  FUNCTION isDependent(par_task_id NUMBER) RETURN NUMBER;

  PROCEDURE completeTask(par_task_id NUMBER);
  PROCEDURE cancelTask(par_task_id NUMBER);

  PROCEDURE refreshOtherTasksStatus(par_task_id NUMBER);

  PROCEDURE removeTaskItem(par_task_item_id NUMBER);

  FUNCTION putTaskBackToQueue(par_task_id NUMBER) RETURN NUMBER;

  FUNCTION checkIsMergeNeeded(par_task_id NUMBER) RETURN NUMBER;

--  FUNCTION checkTaskBeforeAdd(p_task_id NUMBER) RETURN NUMBER;

END pkg_task_queue;
/
CREATE OR REPLACE PACKAGE BODY pkg_task_queue IS

  FUNCTION check_is_empty(par_task_id NUMBER) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(1) INTO v_count FROM t_task_item ti WHERE ti.t_task_id = par_task_id;
    IF v_count = 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  FUNCTION isDependent(par_task_id NUMBER) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM v_task_queue q
     WHERE q.task1_id = par_task_id
       AND q.task2_status_brief = 'IT_APPROVE';
  
    IF v_count = 0
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  END isDependent;

  FUNCTION addTask(par_num VARCHAR2) RETURN NUMBER IS
    v_task_id NUMBER;
  BEGIN
    SELECT sq_document.nextval INTO v_task_id FROM dual;
  
    INSERT INTO ven_t_task
      (t_task_id, num, reg_date, user_id)
    VALUES
      (v_task_id, par_num, SYSDATE, safety.curr_sys_user);
  
    RETURN v_task_id;
  END;

  FUNCTION addTaskItem
  (
    par_task_id   NUMBER
   ,par_item_name VARCHAR2
   ,par_item_type NUMBER
  ) RETURN NUMBER IS
    v_task_item_id NUMBER;
  BEGIN
    SELECT sq_t_task_item.nextval INTO v_task_item_id FROM dual;
  
    INSERT INTO ven_t_task_item
      (t_task_item_id, t_task_id, item_name, item_type)
    VALUES
      (v_task_item_id, par_task_id, par_item_name, par_item_type);
  
    RETURN v_task_item_id;
  END;

  FUNCTION addTaskToQueue(par_task_id NUMBER) RETURN NUMBER IS
    v_is_dependent     NUMBER;
    v_email            VARCHAR2(150);
    v_user_name        contact.obj_name_orig%TYPE;
    v_task_num         ven_t_task.num%TYPE;
    v_subj             VARCHAR2(32767);
    v_text             VARCHAR2(32767);
    v_recipient        VARCHAR2(150);
    v_doc_status_brief doc_status_ref.brief%TYPE;
  BEGIN
    IF check_is_empty(par_task_id) = 1
    THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Невозможно добавить в очередь пустую заявку');
    END IF;
  
    v_is_dependent := isDependent(par_task_id);
    IF v_is_dependent = 1
    THEN
      SELECT num INTO v_task_num FROM ven_t_task WHERE t_task_id = par_task_id;
      FOR rec IN (SELECT c.obj_name_orig user_name
                        ,ce.email
                        ,COUNT(t2.num) task_count
                        ,wm_concat(t2.num) task_nums
                    FROM ven_t_task       t2
                        ,ven_sys_user     u
                        ,contact          c
                        ,cn_contact_email ce
                        ,v_task_queue     q
                   WHERE t2.user_id = u.sys_user_id
                     AND u.contact_id = c.contact_id(+)
                     AND c.contact_id = ce.contact_id(+)
                     AND (ce.id IS NULL OR
                         ce.id = (SELECT MAX(id)
                                     FROM cn_contact_email ce2
                                    WHERE ce2.contact_id = ce.contact_id
                                      AND (ce2.status = 1 OR NOT EXISTS
                                           (SELECT NULL
                                              FROM cn_contact_email ce3
                                             WHERE ce3.contact_id = ce.contact_id
                                               AND ce3.status = 1))))
                     AND t2.t_task_id = q.task1_id
                     AND q.task2_status_brief = 'IT_APPROVE'
                   GROUP BY t2.user_id
                           ,c.obj_name_orig
                           ,ce.email)
      LOOP
        IF rec.email IS NULL
        THEN
          IF rec.task_count > 1
          THEN
            v_subj := '[BORLAS TASK QUEUE] Для вашей заявки ' || rec.task_nums ||
                      ' создана зависимая заявка - ' || v_task_num || '.';
            v_text := 'Для вашей заявки ' || rec.task_nums || ' создана зависимая заявка - ' ||
                      v_task_num || '.';
          ELSE
            v_subj := '[BORLAS TASK QUEUE] Для ваших заявок ' || rec.task_nums ||
                      ' создана зависимая заявка - ' || v_task_num || '.';
            v_text := 'Для ваших заявок ' || rec.task_nums || ' создана зависимая заявка - ' ||
                      v_task_num || '.';
          END IF;
          v_recipient := rec.email;
        END IF;
        IF v_recipient IS NOT NULL
        THEN
          pkg_email.send_mail_with_attachment(par_to      => PKG_EMAIL.T_RECIPIENTS(v_recipient)
                                             ,par_subject => v_subj
                                             ,par_text    => v_text);
        END IF;
      
      END LOOP;
      doc.set_doc_status(par_task_id, 'QUEUED');
    ELSE
      doc.set_doc_status(par_task_id, 'IT_APPROVE');
    END IF;
    RETURN v_is_dependent;
  END addTaskToQueue;

  PROCEDURE refreshOtherTasksStatus(par_task_id NUMBER) IS
    v_baytin_email    VARCHAR2(150) := 'artur.baytin@renlife.com';
    v_kaplya_email    VARCHAR2(150) := 'pavel.kaplya@renlife.com';
    v_task_num        ven_t_task.num%TYPE;
    v_freed_task_num  ven_t_task.num%TYPE;
    v_user_name       contact.obj_name_orig%TYPE;
    v_subj            VARCHAR2(32767);
    v_text            VARCHAR2(32767);
    v_recipient       VARCHAR2(150);
    v_count           NUMBER;
    v_freed_task_nums VARCHAR2(500);
  BEGIN
    SELECT num INTO v_task_num FROM ven_t_task WHERE t_task_id = par_task_id;
  
    FOR rec IN (SELECT c.obj_name_orig user_name
                      ,ce.email
                      ,t.num
                      ,t.user_id
                      ,t.t_task_id
                      ,NVL2(lead(t.num) over(PARTITION BY t.user_id ORDER BY t.num), 0, 1) is_last
                      ,NVL2(lag(t.num) over(PARTITION BY t.user_id ORDER BY t.num), 0, 1) is_first
                  FROM ven_t_task       t
                      ,ven_sys_user     u
                      ,contact          c
                      ,cn_contact_email ce
                      ,v_task_queue     q
                 WHERE t.user_id = u.sys_user_id
                   AND u.contact_id = c.contact_id(+)
                   AND c.contact_id = ce.contact_id(+)
                   AND (ce.id IS NULL OR
                       ce.id = (SELECT MAX(id)
                                   FROM cn_contact_email ce2
                                  WHERE ce2.contact_id = ce.contact_id
                                    AND (ce2.status = 1 OR NOT EXISTS
                                         (SELECT NULL
                                            FROM cn_contact_email ce3
                                           WHERE ce3.contact_id = ce.contact_id
                                             AND ce3.status = 1))))
                   AND t.t_task_id = q.task1_id
                   AND q.task1_status_brief = 'QUEUED'
                   AND q.task2_id = par_task_id
                   AND NOT EXISTS (SELECT NULL
                          FROM v_task_queue q2
                         WHERE q2.task1_id = t.t_task_id
                           AND q2.task2_id != par_task_id
                           AND q2.task2_status_brief = 'IT_APPROVE')
                 ORDER BY t.user_id)
    LOOP
      IF rec.is_first = 1
      THEN
        v_count           := 1;
        v_freed_task_nums := rec.num;
      ELSE
        v_count           := v_count + 1;
        v_freed_task_nums := v_freed_task_nums || ', ' || rec.num;
      END IF;
    
      IF rec.is_last = 1
      THEN
        IF rec.email IS NOT NULL
        THEN
          IF v_count > 1
          THEN
            v_subj := '[BORLAS TASK QUEUE] Можно передавать заявку ' || v_freed_task_nums ||
                      ' на it_approve.';
            v_text := 'Заявка ' || v_task_num || ' выполнена, Вы можете передавать заявку ' ||
                      v_freed_task_nums ||
                      ' на очередь it_approve, предварительно сделав merge пакетов';
          ELSE
            v_subj := '[BORLAS TASK QUEUE] Можно передавать заявки ' || v_freed_task_nums ||
                      ' на it_approve.';
            v_text := 'Заявка ' || v_task_num || ' выполнена, Вы можете передавать заявки ' ||
                      v_freed_task_nums ||
                      ' на очередь it_approve, предварительно сделав merge пакетов';
          END IF;
          v_recipient := rec.email;
        
        ELSE
          v_recipient := v_baytin_email; /*v_kaplya_email;*/
          v_subj      := '[BORLAS TASK QUEUE] Ошибка при отсылке оповещения по заявке ' ||
                         v_freed_task_nums || ', зависящей от ' || v_task_num || '.';
          IF v_count > 1
          THEN
            v_text := 'Привет, Артур!' || CHR(10) || 'Заявка ' || v_task_num ||
                      ' была выполнена, в следствие чего стала доступна для установки заявка ' ||
                      v_freed_task_nums || ', которую разместил ' || NVL(rec.user_name, 'хз кто') ||
                      '. Передай ему/ей эту информацию!';
          
          ELSE
            v_text := 'Привет, Артур!' || CHR(10) || 'Заявка ' || v_task_num ||
                      ' была выполнена, в следствие чего стали доступны для установки заявки ' ||
                      v_freed_task_nums || ', которые разместил ' || NVL(rec.user_name, 'хз кто') ||
                      '. Передай ему/ей эту информацию!';
          END IF;
        END IF;
        pkg_email.send_mail_with_attachment(par_to      => PKG_EMAIL.T_RECIPIENTS(v_recipient)
                                           ,par_subject => v_subj
                                           ,par_text    => v_text);
      END IF;
    
      doc.set_doc_status(p_doc_id => rec.t_task_id, p_status_brief => 'READY_TO_IT_APPROVE');
    
    END LOOP;
  
  END;

  PROCEDURE completeTask(par_task_id NUMBER) IS
    v_task_id NUMBER;
  BEGIN
    /*Вызывается на переходе статуса*/
    --    refreshOtherTasksStatus(p_task_id);
    BEGIN
      SELECT t_task_id INTO v_task_id FROM t_task t WHERE t.t_task_id = par_task_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Заявка с таким id не существует. Вероятно Вы забыли сохраниться, когда создавали ее.');
    END;
    doc.set_doc_status(p_doc_id => par_task_id, p_status_brief => 'COMPLETE');
  END completeTask;

  PROCEDURE cancelTask(par_task_id NUMBER) IS
  BEGIN
    /*Вызывается на переходе статуса*/
    --    refreshOtherTasksStatus(p_task_id); 
    doc.set_doc_status(p_doc_id => par_task_id, p_status_brief => 'CANCEL');
  END cancelTask;

  PROCEDURE removeTaskItem(par_task_item_id NUMBER) IS
    v_task_id NUMBER;
  BEGIN
    /*    SAVEPOINT before_delete;*/
  
    SELECT t_task_id INTO v_task_id FROM t_task_item t WHERE t.t_task_item_id = par_task_item_id;
  
    DELETE FROM t_task_item WHERE t_task_item_id = par_task_item_id;
  
    /*    IF check_is_empty(v_task_id) = 1
    THEN
      ROLLBACK TO before_delete;
      RAISE_APPLICATION_ERROR(-20001, 'Заявка не может быть пустой.');
    END IF;*/
  END removeTaskItem;

  FUNCTION putTaskBackToQueue(par_task_id NUMBER) RETURN NUMBER IS
    v_status_breif doc_status_ref.brief%TYPE;
    v_is_dependent NUMBER;
  BEGIN
    v_status_breif := doc.get_doc_status_brief(par_task_id);
  
    IF v_status_breif = 'READY_TO_IT_APPROVE'
    THEN
      v_is_dependent := addTaskToQueue(par_task_id);
    ELSE
      raise_application_error(-20001
                             ,'Заявка не может быть помещена обратно в очередь из своего статуса');
    END IF;
    RETURN v_is_dependent;
  END putTaskBackToQueue;

  FUNCTION checkIsMergeNeeded(par_task_id NUMBER) RETURN NUMBER IS
    v_status_brief doc_status_ref.brief%TYPE;
    v_res          NUMBER;
  BEGIN
    v_status_brief := doc.get_doc_status_brief(par_task_id);
  
    SELECT COUNT(1)
      INTO v_res
      FROM ven_t_task         t1
          ,t_task             t2
          ,doc_status         ds1
          ,doc_status         ds2
          ,doc_status_ref     dsr1
          ,doc_status_ref     dsr2
          ,v_task_items_queue q
     WHERE t1.t_task_id = par_task_id
       AND t1.doc_status_id = ds1.doc_status_id
       AND t1.doc_status_ref_id = dsr1.doc_status_ref_id
       AND dsr1.brief = 'READY_TO_IT_APPROVE'
       AND q.task1_id = t1.t_task_id
       AND q.task2_id = t2.t_task_id
       AND t2.t_task_id = ds2.document_id
       AND ds2.doc_status_ref_id = dsr2.doc_status_ref_id
       AND dsr2.brief = 'IT_APPROVE'
       AND ds2.start_date BETWEEN ds1.start_date AND SYSDATE;
  
    IF v_res = 0
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  
  END checkIsMergeNeeded;

END pkg_task_queue;
/

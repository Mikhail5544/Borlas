CREATE OR REPLACE PACKAGE pkg_acquiring_queue IS

  -- Author  : Черных М.
  -- Created : 13.10.2014 
  -- Purpose : Работа с очередью сообщений по Эквайрингу

  /*Наименование очереди (одна очередь, у которой несколько (3) потребителя)*/

  PROCEDURE enqueue_payment_to_writeoff(par_interent_payment_id NUMBER);
  PROCEDURE enqueue_payment_to_process(par_interent_payment_id NUMBER);

  /**
  * Создание/пересоздание таблиц очереди и самих очередей
  */
  PROCEDURE aq_prepare;

  /**
  * Процедура обработки Интернет Платежей из очереди на списание
  * Вызывается механимзмом нотификации технологии Oracle Advanced Queue
  * @author Капля П.
  */
  PROCEDURE write_off_internet_payment
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  );
  /**
  * Процедура обработки Интернет Платежей из очереди на списание
  * @author Капля П.
  * @param par_internet_payment_id Ид интернет платежа
  */
  PROCEDURE write_off_internet_payment(par_internet_payment_id NUMBER);

  /**
  * Процедура обработки платежей после того, как платеж был списан.
  * Вызывается механимзмом нотификации технологии Oracle Advanced Queue
  * @author Капля П.
  */
  PROCEDURE process_internet_payment
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  );
  /**
  * Процедура обработки платежей после того, как платеж был списан.
  * @author Капля П.
  * @param par_internet_payment_id Ид интернет платежа
  */
  PROCEDURE process_internet_payment(par_internet_payment_id NUMBER);

END pkg_acquiring_queue;
/
CREATE OR REPLACE PACKAGE BODY pkg_acquiring_queue IS
  gc_set_foc_status_note CONSTANT VARCHAR2(255) := 'Обработка очереди интернет платежей';

  gc_queue_name           CONSTANT VARCHAR2(255) := 'INS.INTERNET_PAYMENT_QUEUE';
  gc_exception_queue_name CONSTANT VARCHAR2(255) := 'INS.INTERNET_PAYMENT_EQ';

  gc_to_writeoff CONSTANT VARCHAR2(30) := 'TO_WRITE_OFF';
  gc_to_process  CONSTANT VARCHAR2(30) := 'TO_PROCESS';

  gc_queue_max_retries CONSTANT INTEGER := 0;
  gc_retry_delay       CONSTANT INTEGER := 5;

  gc_dsr_to_writoff_id     CONSTANT INTEGER := dml_doc_status_ref.get_id_by_brief('TO_WRITEOFF');
  gc_dsr_writtenoff_id     CONSTANT INTEGER := dml_doc_status_ref.get_id_by_brief('WRITEDOFF');
  gc_dsr_not_writtenoff_id CONSTANT INTEGER := dml_doc_status_ref.get_id_by_brief('NOT_WRITEDOFF');
  gc_dsr_cancel_id         CONSTANT INTEGER := dml_doc_status_ref.get_id_by_brief('CANCEL');
  gc_dsr_new_id            CONSTANT INTEGER := dml_doc_status_ref.get_id_by_brief('NEW');

  c_priority_high   CONSTANT BINARY_INTEGER := 1;
  c_priority_medium CONSTANT BINARY_INTEGER := 2;

  gc_debug CONSTANT BOOLEAN := FALSE;

  ex_queue_no_messages EXCEPTION; --Нет сообщений в очереди
  PRAGMA EXCEPTION_INIT(ex_queue_no_messages, -25228);

  PROCEDURE change_cuurent_schema_to_ins IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA=INS';
  END change_cuurent_schema_to_ins;

  PROCEDURE aq_prepare IS
    c_payload_type           CONSTANT VARCHAR2(255) := 'ins.tt_acq_internet_payment';
    c_queue_table            CONSTANT VARCHAR2(255) := 'ins.aq_internet_payment';
    c_to_write_off_subsriber CONSTANT VARCHAR2(255) := 'SUBSCR_INT_PAYMENT_TOWRITEOFF';
    c_to_process_subsriber   CONSTANT VARCHAR2(255) := 'SUBSCR_INT_PAYMENT_TOPROCESS';
    c_queue_table_comment    CONSTANT VARCHAR2(500) := 'Экваринг. Таблица для очередей по интернет платежам';
    ex_queue_already_exists       EXCEPTION;
    ex_queue_table_already_exists EXCEPTION;
    ex_substriber_doesnt_exists   EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_queue_already_exists, -24006);
    PRAGMA EXCEPTION_INIT(ex_queue_table_already_exists, -24001);
    PRAGMA EXCEPTION_INIT(ex_substriber_doesnt_exists, -24035);
  
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Попытка создать очередь */
  
    BEGIN
      dbms_aqadm.create_queue_table(queue_table        => c_queue_table
                                   ,queue_payload_type => c_payload_type
                                   ,multiple_consumers => TRUE
                                   ,COMMENT            => c_queue_table_comment);
    EXCEPTION
      WHEN ex_queue_table_already_exists THEN
        NULL;
    END;
  
    BEGIN
      dbms_aqadm.create_queue(queue_name  => gc_queue_name
                             ,queue_table => c_queue_table
                             ,max_retries => gc_queue_max_retries
                             ,retry_delay => gc_retry_delay);
    EXCEPTION
      WHEN ex_queue_already_exists THEN
        NULL;
    END;
  
    BEGIN
      dbms_aqadm.create_queue(queue_name  => gc_exception_queue_name
                             ,queue_table => c_queue_table
                             ,queue_type  => dbms_aqadm.exception_queue);
    EXCEPTION
      WHEN ex_queue_already_exists THEN
        NULL;
    END;
  
    /* Запуск очереди */
  
    dbms_aqadm.start_queue(gc_queue_name);
    dbms_aqadm.start_queue(gc_exception_queue_name, FALSE, TRUE);
  
    BEGIN
      dbms_aqadm.remove_subscriber(queue_name => gc_queue_name
                                  ,subscriber => sys.aq$_agent(c_to_write_off_subsriber, NULL, NULL));
    EXCEPTION
      WHEN ex_substriber_doesnt_exists THEN
        NULL;
    END;
  
    dbms_aqadm.add_subscriber(queue_name => gc_queue_name
                             ,subscriber => sys.aq$_agent(c_to_write_off_subsriber, NULL, NULL)
                             ,rule       => 'TAB.USER_DATA.status = ''' || gc_to_writeoff || '''');
  
    dbms_aq.register(reg_list  => sys.aq$_reg_info_list(sys.aq$_reg_info(gc_queue_name || ':' ||
                                                                         c_to_write_off_subsriber
                                                                        ,dbms_aq.namespace_aq
                                                                        ,'plsql://INS.PKG_ACQUIRING_QUEUE.WRITE_OFF_INTERNET_PAYMENT'
                                                                        ,hextoraw('FF')))
                    ,reg_count => 1);
  
    BEGIN
      dbms_aqadm.remove_subscriber(queue_name => gc_queue_name
                                  ,subscriber => sys.aq$_agent(c_to_process_subsriber, NULL, NULL));
    EXCEPTION
      WHEN ex_substriber_doesnt_exists THEN
        NULL;
    END;
  
    dbms_aqadm.add_subscriber(queue_name => gc_queue_name
                             ,subscriber => sys.aq$_agent(c_to_process_subsriber, NULL, NULL)
                             ,rule       => 'TAB.USER_DATA.status = ''' || gc_to_process || '''');
  
    dbms_aq.register(reg_list  => sys.aq$_reg_info_list(sys.aq$_reg_info(gc_queue_name || ':' ||
                                                                         c_to_process_subsriber
                                                                        ,dbms_aq.namespace_aq
                                                                        ,'plsql://INS.PKG_ACQUIRING_QUEUE.PROCESS_INTERNET_PAYMENT'
                                                                        ,hextoraw('FF')))
                    ,reg_count => 1);
  
    COMMIT;
  END aq_prepare;

  PROCEDURE enqueue
  (
    par_payload  tt_acq_internet_payment
   ,par_priority BINARY_INTEGER
  ) IS
    msg_properties  dbms_aq.message_properties_t;
    enqueue_options dbms_aq.enqueue_options_t;
    --    recipients                 dbms_aq.aq$_recipient_list_t;
    msg_handle RAW(16);
  BEGIN
    enqueue_options.visibility     := dbms_aq.on_commit;
    msg_properties.priority        := par_priority;
    msg_properties.exception_queue := gc_exception_queue_name;
  
    dbms_aq.enqueue(queue_name         => gc_queue_name
                   ,enqueue_options    => enqueue_options
                   ,message_properties => msg_properties
                   ,payload            => par_payload
                   ,msgid              => msg_handle);
  END enqueue;

  -- Постановка ИП в очередь на списание
  PROCEDURE enqueue_payment_to_writeoff(par_interent_payment_id NUMBER) IS
    vr_tt_acq_intermet_payment tt_acq_internet_payment;
  BEGIN
  
    vr_tt_acq_intermet_payment := tt_acq_internet_payment(par_interent_payment_id, gc_to_writeoff);
  
    enqueue(par_payload => vr_tt_acq_intermet_payment, par_priority => c_priority_high);
  
  END enqueue_payment_to_writeoff;

  -- Постановка ИП в очередь на обработку результатов списания
  PROCEDURE enqueue_payment_to_process(par_interent_payment_id NUMBER) IS
    vr_tt_acq_intermet_payment tt_acq_internet_payment;
  BEGIN
  
    vr_tt_acq_intermet_payment := tt_acq_internet_payment(par_interent_payment_id, gc_to_process);
  
    enqueue(par_payload => vr_tt_acq_intermet_payment, par_priority => c_priority_medium);
  END enqueue_payment_to_process;

  /**
  * Процедура обработки Интернет Платежей из очереди на списание
  * @author Капля П.
  * @param par_internet_payment_id Ид интернет платежа
  */
  PROCEDURE write_off_internet_payment(par_internet_payment_id NUMBER) IS
  BEGIN
    -- С Аллой принято решение, что если ИП на момент обработки уже не в статусе На списании, 
    -- то просто ничего не делаем
    IF doc.get_last_doc_status_ref_id(par_internet_payment_id) = gc_dsr_to_writoff_id
    THEN
    
      -- Выполняем списание
      pkg_acquiring.make_payment(par_internet_payment_id);
    ELSE
      ex.raise_custom('Неверный статус интернет платежа: ' ||
                      doc.get_last_doc_status_brief(par_internet_payment_id));
    
    END IF;
  END write_off_internet_payment;

  PROCEDURE write_off_internet_payment
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  ) IS
    r_dequeue_options    dbms_aq.dequeue_options_t;
    r_message_properties dbms_aq.message_properties_t;
    v_message_handle     RAW(16);
    vr_payment           tt_acq_internet_payment;
  BEGIN
    r_dequeue_options.msgid         := descr.msg_id;
    r_dequeue_options.consumer_name := descr.consumer_name;
  
    /*Извлечение из очереди*/
    dbms_aq.dequeue(queue_name         => descr.queue_name
                   ,dequeue_options    => r_dequeue_options
                   ,message_properties => r_message_properties
                   ,payload            => vr_payment
                   ,msgid              => v_message_handle);
  
    change_cuurent_schema_to_ins;
  
    IF gc_debug
    THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'write_off_internet_payment: ' ||
                                                         vr_payment.acq_internet_payment_id
                                         ,par_text    => 'dequeued' ||
                                                         doc.get_last_doc_status_brief(vr_payment.acq_internet_payment_id));
    END IF;
  
    write_off_internet_payment(vr_payment.acq_internet_payment_id);
  
    IF gc_debug
    THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'write_off_internet_payment: ' ||
                                                         vr_payment.acq_internet_payment_id
                                         ,par_text    => 'processed' ||
                                                         doc.get_last_doc_status_brief(vr_payment.acq_internet_payment_id));
    
    END IF;
  END write_off_internet_payment;

  PROCEDURE process_internet_payment(par_internet_payment_id NUMBER) IS
    vr_payment dml_acq_internet_payment.tt_acq_internet_payment;
  BEGIN
    vr_payment := dml_acq_internet_payment.get_record(par_internet_payment_id);
  
    -- Если интернет платеж списан успешно
    IF vr_payment.doc_status_ref_id = gc_dsr_writtenoff_id
    THEN
    
      -- Переводим ИП в статус Новый
      doc.set_doc_status(p_doc_id    => par_internet_payment_id
                        ,p_status_id => gc_dsr_new_id
                        ,p_note      => gc_set_foc_status_note);
    
      -- Если ИП НЕ списан                        
    ELSIF vr_payment.doc_status_ref_id = gc_dsr_not_writtenoff_id
    THEN
      -- Переводим ИП в статус Отменен
      doc.set_doc_status(p_doc_id    => par_internet_payment_id
                        ,p_status_id => gc_dsr_cancel_id
                        ,p_note      => gc_set_foc_status_note);
    ELSE
      ex.raise_custom('Неверный статус интернет платежа: ' ||
                      doc.get_last_doc_status_brief(par_internet_payment_id));
    END IF;
  END process_internet_payment;

  PROCEDURE process_internet_payment
  (
    CONTEXT  RAW
   ,reginfo  sys.aq$_reg_info
   ,descr    sys.aq$_descriptor
   ,payload  RAW
   ,payloadl NUMBER
  ) IS
    r_dequeue_options       dbms_aq.dequeue_options_t;
    r_message_properties    dbms_aq.message_properties_t;
    v_message_handle        RAW(16);
    vr_acq_internet_payment tt_acq_internet_payment;
  BEGIN
    r_dequeue_options.msgid         := descr.msg_id;
    r_dequeue_options.consumer_name := descr.consumer_name;
  
    /*Извлечение из очереди*/
    dbms_aq.dequeue(queue_name         => descr.queue_name
                   ,dequeue_options    => r_dequeue_options
                   ,message_properties => r_message_properties
                   ,payload            => vr_acq_internet_payment
                   ,msgid              => v_message_handle);
  
    change_cuurent_schema_to_ins;
  
    IF gc_debug
    THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'process_internet_payment: ' ||
                                                         vr_acq_internet_payment.acq_internet_payment_id
                                         ,par_text    => 'qedueued' ||
                                                         doc.get_last_doc_status_brief(vr_acq_internet_payment.acq_internet_payment_id));
    END IF;
  
    process_internet_payment(vr_acq_internet_payment.acq_internet_payment_id);
  
    IF gc_debug
    THEN
      pkg_email.send_mail_with_attachment(par_to      => pkg_email.t_recipients('pavel.kaplya@renlife.com')
                                         ,par_subject => 'process_internet_payment: ' ||
                                                         vr_acq_internet_payment.acq_internet_payment_id
                                         ,par_text    => 'processed:' ||
                                                         doc.get_last_doc_status_brief(vr_acq_internet_payment.acq_internet_payment_id));
    END IF;
  END process_internet_payment;

END pkg_acquiring_queue;
/

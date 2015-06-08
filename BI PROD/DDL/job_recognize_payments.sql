begin
  DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_RECOGNIZE_PAYMENTS');

  DBMS_SCHEDULER.CREATE_JOB
    (job_name   => 'JOB_RECOGNIZE_PAYMENTS'
    ,job_type   => 'PLSQL_BLOCK'
    ,job_action => 'begin
                      for vr_pri in (select pri.payment_register_item_id, pri.set_off_state
                                       from payment_register_item pri
                                           ,ac_payment            ac
                                       where pri.ac_payment_id = ac.payment_id
                                         and ac.due_date >= to_date(''01.01.2011'',''dd.mm.yyyy'')
                                         
                                         -- NULL    �����    ������������� �� ���������  �������-���������
                                         and ((pri.set_off_state = 21 and pri.status in (0,20,10))
                                         
                                         -- �����  �����  ������������� �� ���������  �������-��������� 
                                           or (pri.set_off_state = 1 and pri.status in (0,10,20))
                                         
                                         -- �������  �����  ������������� �� ���������  �������-��������� 
                                           or (pri.set_off_state = 2 and pri.status in (0,20,10))
                                         
                                         -- ������ 
                                           or (pri.set_off_state = 10)
                                         
                                         -- ��������� �������
                                           or (pri.set_off_state = 6)
                                         
                                         -- ������ ����������  ������������� �� ���������  �������-���������
                                           or (pri.set_off_state = 17 and pri.status in (20,10))
                                         
                                         -- ���������  �����  ������������� �� ���������  �������-���������
                                           or (pri.set_off_state = 3 and pri.status in (0,20,10))
                                         
                                         -- �/�   
                                           or (pri.set_off_state = 8)
                                         
                                         -- �� ������������� ����������
                                           or (pri.set_off_state = 9)
                                         
                                         -- ��������������
                                           or (pri.set_off_state = 22)
                                         
                                         -- ����������� 
                                           or (pri.set_off_state = 11)
                                         
                                         -- ����� ������ (������ �179032)
                                           or (pri.set_off_state = 19)
                                             )
                                    )
                    loop
                      pkg_payment_register.recognize_payment(p_payment_register_item_id => vr_pri.payment_register_item_id);
                    end loop;
                    commit;
                    for vr_cur IN ( SELECT p.payment_register_item_id
                                      FROM payment_register_item  p
                                     WHERE p.status = 50 -- ��������� �������������
                                   )
                    loop
                      ins.pkg_payment_register.connect_payment(p_payment_register_item_id =>vr_cur.payment_register_item_id);                        
                    END loop;
                    commit;
                    END;'
    ,enabled   => TRUE
    ,start_date => to_timestamp('20.10.2012 04:00:00','dd.mm.yyyy HH24:MI:SS')
    ,repeat_interval => 'FREQ=DAILY;'
    );
    
end;
/

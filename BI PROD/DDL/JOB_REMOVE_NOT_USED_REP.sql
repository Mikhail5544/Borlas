
begin
      SYS.DBMS_SCHEDULER.CREATE_JOB
      (
      job_name => 'INS.JOB_REMOVE_NOT_USED_REP'
      ,start_date => TO_TIMESTAMP_TZ('2012/11/27 11:20:00.000000 +03:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm')
      ,repeat_interval => 'FREQ=MONTHLY; INTERVAL=1; BYDAY=SUN;BYHOUR=05;BYMINUTE=00;BYSECOND=00;'
      ,end_date => NULL
      ,job_class => 'DEFAULT_JOB_CLASS'
      ,job_type => 'PLSQL_BLOCK'
      ,job_action => '
      begin
      ----------------------------------
      ---помечаем к удалениею отчеты
      update ins_eul.eul5_documents_tab t
      set t.doc_name = ''К удалению ''|| to_char(sysdate + interval ''1'' month,''dd.mm.yyyy'')|| '' '' 
                       || substr(t.doc_name,0,75)                   
      where  months_between(sysdate, t.doc_created_date) > 2
             and (not (doc_description like ''%Владелец:%'')
                         or doc_description is null)
             and not(t.doc_name like ''К удалению %'');
      
      commit;
      
      ----------------------------------
      --удаляем отчеты
      for rec in
      (    
           select  t.doc_id       
           from ins_eul.eul5_documents_tab t
           where t.doc_name like ''К удалению %''
             and trunc(to_date(substr(t.doc_name,12,10), ''dd.mm.yyyy'')) < trunc(sysdate)
       )loop
         ----------------------------------
         --разрываем связь роли с правом на отчет
         delete from safety_right_role srr 
         where srr.safety_right_id =  
               (
                 select sr.safety_right_id
                   from safety_right sr 
                  where sr.right_obj_id         = rec.doc_id
                    and sr.safety_right_type_id = (select srt.safety_right_type_id 
                                                     from safety_right_type srt 
                                                    where srt.brief = ''DISCOVERER'')
               );
        ----------------------------------    
        --удаляем право на отчет
        delete from safety_right sr 
        where sr.right_obj_id         = rec.doc_id
          and sr.safety_right_type_id = (select srt.safety_right_type_id 
                                           from safety_right_type srt 
                                          where srt.brief = ''DISCOVERER'');
        ----------------------------------    
        --удаляем отчет                                          
        delete from ins_eul.EUL5_ACCESS_PRIVS a
        where a.gd_doc_id = rec.doc_id;

        delete from ins_eul.eul5_documents_tab t 
        where t.doc_id = rec.doc_id;  
       end loop;   
end;   
      '
      );
end;

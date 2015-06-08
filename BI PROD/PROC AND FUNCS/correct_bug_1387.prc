create or replace procedure correct_bug_1387 is
  v_doc_id number;
  v_date   date;
begin
  for rc in (select *
               from (select (select count(*)
                               from status_action_log sal
                              where sal.doc_status_id = ds.doc_status_id) c,
                            ds.document_id,
                            ds.start_date,
                            d.num,
                            doc.get_last_doc_status_id(ds.document_id) last_id,
                            ds.doc_status_id
                       from doc_status ds, document d
                      where ds.src_doc_status_ref_id = 16
                        and ds.status_change_type_id = 2
                        and ds.user_name = 'INS'
                        and ds.doc_status_ref_id = 1 --doc_status_id = 2555758
                        and d.document_id = ds.document_id)
              where last_id = doc_status_id
                and c < 16) loop
  
    v_doc_id := rc.document_id;
    v_date   := rc.start_date;
    begin
    
      savepoint sp_start_loop;
    
      doc.set_doc_status(v_doc_id, 'PROJECT', v_date + 1 / 24 / 3600);
      doc.set_doc_status(v_doc_id, 'NEW', v_date + 2 / 24 / 3600);
    exception
      when others then
        rollback to savepoint sp_start_loop;
    end;
  end loop;
  commit;
end correct_bug_1387;
/


CREATE OR REPLACE PROCEDURE correct_DS_status_date(v_ag_num       in varchar,
                                                   v_num          in number,
                                                   v_correct_date in date) as
  v_ag_id     number;
  v_d_id      number;
  v_dd_id     number;
  v_temp_date date;
  v_header_id number;
  sec         number := 15;
begin
  --определяем версию агентского договора
  select ac.ag_contract_id, d.document_id
    into v_ag_id, v_d_id
    from ag_contract ac, ag_contract_header ach, document d
   where ac.contract_id = ach.ag_contract_header_id
     and ac.ag_contract_id = d.document_id
     and ach.ag_contract_header_id =
         (select ag.ag_contract_header_id
            from ag_contract t, ag_contract_header ag
           where exists (select '1'
                    from ag_contract_header y, document q
                   where t.ag_contract_id = y.last_ver_id
                     and q.document_id = y.ag_contract_header_id
                     and q.num = v_ag_num) --номер агентского договора
             and t.ag_contract_id = ag.last_ver_id)
     and d.num = v_num;
  select d.document_id
    into v_dd_id
    from ag_contract t, ag_contract_header ag, document d
   where exists (select '1'
            from ag_contract_header y, document q
           where t.ag_contract_id = y.last_ver_id
             and q.document_id = y.ag_contract_header_id
             and q.num = v_ag_num)
     and t.ag_contract_id = ag.last_ver_id
     and d.document_id = ag.ag_contract_header_id;
  --внесение изменений
  for rr in (select dst.doc_status_id
               from doc_status dst
              where dst.document_id = v_ag_id) loop
    update doc_status ds
       set ds.start_date = to_date(to_char(v_correct_date) || ' 10:00:' ||
                                   to_char(sec) || '',
                                   'dd.mm.yyyy hh24:mi:ss')
     where ds.doc_status_id = rr.doc_status_id;
    sec := sec + 5;
  end loop;
  update document doc
     set doc.reg_date = to_date(to_char(v_correct_date) || ' 10:00:' ||
                                to_char(sec) || '',
                                'dd.mm.yyyy hh24:mi:ss')
   where doc.document_id = v_d_id;
  sec := sec + 5;
  update document doc
     set doc.reg_date = to_date(to_char(v_correct_date) || ' 10:00:' ||
                                to_char(sec) || '',
                                'dd.mm.yyyy hh24:mi:ss')
   where doc.document_id = v_dd_id;
  commit;
exception
  when others then
    rollback;
end correct_DS_status_date;
/


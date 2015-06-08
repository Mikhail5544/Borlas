CREATE OR REPLACE PROCEDURE correct_Jstatus_mark(v_ag_num  in varchar,
                                                 v_num     in number,
                                                 v_js_mark in number) as
  v_ag_id number := 0;
begin
  --���������� ������ ���������� ��������
  begin
    select ac.ag_contract_id
      into v_ag_id
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
                       and q.num = v_ag_num) --����� ���������� ��������
               and t.ag_contract_id = ag.last_ver_id)
       and d.num = v_num;
  exception
    when no_data_found then
      raise_application_error(-20001,
                              '������ ��������������� ��������� ���!!!: ' ||
                              sqlerrm(sqlcode));
  end;
  --�������� ���������
  begin
    update ag_contract ac
       set ac.leg_pos = v_js_mark
     where ac.ag_contract_id = v_ag_id;
    exception when
  others then rollback;
end; 
commit;
end correct_Jstatus_mark;
/


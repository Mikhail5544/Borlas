CREATE OR REPLACE PROCEDURE correct_category_agent(v_ag_num   in varchar,
                                                   v_num      in number,
                                                   v_category in number) as
  v_ag_id number := 0;
  v_ag_h_id number:=0;
begin
  --���������� ������ ���������� ��������
  begin
    select ac.ag_contract_id, ach.ag_contract_header_id
      into v_ag_id, v_ag_h_id
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
       set ac.category_id = v_category
     where ac.ag_contract_id = v_ag_id;
    exception when
  others then rollback;
end;
commit;
  begin
    update ag_stat_hist ash
       set ash.ag_category_agent_id = v_category
     where ash.ag_contract_header_id = v_ag_h_id;
    exception when
  others then rollback;
end;
commit;
end correct_category_agent;
/


CREATE OR REPLACE FUNCTION double_trans_analyze_vadim -- 2008.06.04 для расчета ОАВ май без задвоенности, пока нет патча
 				(p_ag_contract_header_id in number,
                                p_part_agent            IN NUMBER,
                                p_trans_id              in number)
    RETURN number is
    Result number;
    v_tmp  number;
  begin
    if p_part_agent = 50 then
      select count(1)
        into v_tmp
        from agent_report_cont arc
        join agent_report ar on (ar.agent_report_id = arc.agent_report_id)
       where arc.part_agent = 50
         and arc.trans_id = p_trans_id
         and ar.ag_contract_h_id <> p_ag_contract_header_id;
      if v_tmp > 1 then
        Result := 0;
      else
        Result := 1;
      end if;
    else
    select count(1)
        into v_tmp
        from agent_report_cont arc
        join agent_report ar on (ar.agent_report_id = arc.agent_report_id)
       where arc.trans_id = p_trans_id;
      if v_tmp > 0 then
        Result := 0;
      else
        Result := 1;
      end if;
    end if;
     return(Result);
    exception when others then return(0);
  end double_trans_analyze_vadim;
/


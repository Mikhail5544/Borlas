create or replace procedure DelAg2 (p_number varchar2)
as

 -- агенский договор
  cursor cur_ag_contract(cv_number varchar2) is
   select count(h.ag_contract_header_id) over (partition by h.ag_contract_header_id) as row_count,
       h.ag_contract_header_id as ag_contract_header_id,
       h.agent_id as agent_id
    from ven_ag_contract_header h
    where h.AG_CONTRACT_HEADER_ID = cv_number;

  rec_ag_contract cur_ag_contract%rowtype;

  v_rez        number :=0;
  v_hid        number :=0;
  v_aid        number :=0;
  text_ex_error varchar2(255);
  ex_error exception;

  begin
  dbms_OUTPUT.enable(100000);
--- ввод номера договора (Номер договора вводится в одинарных кавычках например: '01TEST')

   open   cur_ag_contract (p_number);
   fetch cur_ag_contract into rec_ag_contract;

 --- Не найдено
   if (cur_ag_contract%notfound)then
     close cur_ag_contract;
  text_ex_error := 'Не найден агенский договор №'||p_number;
  raise  ex_error;
   end if;

   --- НАйдено, но много
   if (rec_ag_contract.row_count > 1)then
      close cur_ag_contract;
   text_ex_error := 'Было найдено '|| rec_ag_contract.row_count ||' агенских договоров №'||p_number;
   raise  ex_error;
   end if;

    close cur_ag_contract;

    v_hid := rec_ag_contract.ag_contract_header_id;
 v_aid := rec_ag_contract.agent_id;

--- удалять нельзя, если:
   begin
     -- анализ существования расчетов премий по договору
     select 1 into v_rez  from dual
     where exists (select 1
                   from ven_agent_report r
                   where r.ag_contract_h_id = v_hid);

     if (v_rez = 1)then
     text_ex_error := 'Были найдены расчеты премий для агенского договора №'||p_number;
     raise  ex_error;
  end if;

   exception
    when no_data_found
  then v_rez:=0;
   end;

   begin
     -- анализ существования привязки к полиси
     select 1 into v_rez  from dual
     where exists (select 1
                   from ven_p_policy_agent pa, POLICY_AGENT_STATUS PAS
				   where
				       PAS.BRIEF != 'ERROR'
				   and pa.STATUS_ID = PAS.POLICY_AGENT_STATUS_ID
                   and pa.ag_contract_header_id = v_hid);

     if (v_rez = 1)then
     text_ex_error := 'Были найдены агенты для агенского договора №'||p_number;
     raise  ex_error;
  end if;

    exception
    when no_data_found then
      v_rez:=0;
   end;
/*

   -- анализ существования БСО
   v_rez := pkg_bso.count_bso_to_contact(v_aid);

   if (v_rez > 0)then
     text_ex_error := 'Были найдены БСО агента';
  raise  ex_error;
   end if;
  */
   -- удаление ставок агетта по догоовру и привязки агента к договорам
   delete from ven_p_policy_agent_com v
   where v.P_POLICY_AGENT_ID in
   (   select pa.P_POLICY_AGENT_ID from
		  ven_p_policy_agent pa
       where pa.AG_CONTRACT_HEADER_ID = v_hid );

   delete from ven_p_policy_agent pa where pa.AG_CONTRACT_HEADER_ID = v_hid;

-- удаление статусов доверенностей
  begin
    delete from ven_doc_status d
    where exists (select 1
                 from ven_ag_contract_dover ad
                 where d.document_id = ad.ag_contract_dover_id
                 and ad.ag_contract_header_id = v_hid);

   exception
     when others then
    text_ex_error := 'Ошибка при удалении статусов доверенностей: - '||sqlerrm;
    raise  ex_error;
   end;

-- удаление доверенностей
  begin
    delete from ven_ag_contract_dover ad
    where ad.ag_contract_header_id = v_hid;

   exception
     when others then
    text_ex_error := 'Ошибка при удалении доверенностей: - '||sqlerrm;
    raise  ex_error;
   end;

-- удаление плана продаж
   begin
    delete from ven_ag_plan_sale ps
    where ps.ag_contract_header_id = v_hid;

   exception
    when others then
    text_ex_error := 'Ошибка при удалении плана продаж: - '||sqlerrm;
    raise  ex_error;
   end;

-- удаление содержимого версии (риски и ставки)
   begin
    delete from ven_ag_prod_line_contr plc
    where exists ( select 1 from ven_ag_contract c
                  where c.contract_id = v_hid
                  and c.ag_contract_id = plc.ag_contract_id);

   exception
    when others then
    text_ex_error := 'Ошибка при удалении содержимого версии (риски и ставки): - '||sqlerrm;
    raise  ex_error;
   end;

-- удаление плана по ДАВ
   begin
    delete from ven_ag_dav d
    where exists ( select 1 from ven_ag_contract c
                   where d.contract_id = c.ag_contract_id
                   and  c.contract_id = v_hid);
   exception
    when others then
    text_ex_error := 'Ошибка при удалении содержимого версии (риски и ставки): - '||sqlerrm;
    raise  ex_error;
   end;

-- удаление плана Доп. КВ для интервала премий
   begin
    delete from ven_ag_plan_dop_rate dd
    where exists ( select '1' from ven_ag_contract c
                   where dd.ag_contract_id = c.ag_contract_id
                   and  c.contract_id = v_hid);

   exception
    when others then
    text_ex_error := 'Ошибка при удалении плана Доп. КВ для интервала премий: - '||sqlerrm;
    raise  ex_error;
   end;
-- удаление статуса агента
   begin
    delete from ven_ag_stat_hist st
    where st.ag_contract_header_id = v_hid;
   exception
    when others then
    text_ex_error := 'Ошибка при удалении статуса агента: - '||sqlerrm;
    raise  ex_error;
   end;
-- удаление статуса версий
   begin
    delete from ven_doc_status d
    where exists (select 1
                 from ven_ag_contract c
                 where d.document_id = c.ag_contract_id
                 and c.contract_id = v_hid);
   exception
    when others then
    text_ex_error := 'Ошибка при удалении  статуса версий: - '||sqlerrm;
    raise  ex_error;
   end;

   update ven_ag_contract_header h
   set h.last_ver_id = null
   where h.ag_contract_header_id =v_hid;

-- удаление версий
   begin
    delete from ag_contract c
    where c.contract_id = v_hid;
   exception
    when others then
    text_ex_error := 'Ошибка при удалении  статуса версий: - '||sqlerrm;
    raise  ex_error;
   end;
-- удаление статуса заголовка
   begin
    delete from ven_doc_status d
    where d.document_id = v_hid;
 exception
    when others then
    text_ex_error := 'Ошибка при удалении статуса заголовка: - '||sqlerrm;
    raise  ex_error;
   end;
-- удаление заголовка
   begin
    delete from ven_ag_contract_header h
    where h.ag_contract_header_id =v_hid;
    exception
    when others then
    text_ex_error := 'Ошибка при удалении удаление заголовка: - '||sqlerrm;
    raise  ex_error;
   end;
   commit;
exception
     when ex_error then
  rollback;
  dbms_OUTPUT.PUT_LINE(text_ex_error);
end;
/


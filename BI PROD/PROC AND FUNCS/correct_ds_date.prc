CREATE OR REPLACE PROCEDURE correct_DS_date(v_ag_num       in varchar,	--номер агенского договора 6 знаков
                                              v_num          in number, --порядковый номер ДС
                                              v_now_date     in date,	--дата которая сейчас задана
                                              v_correct_date in date) as--дата которую необходимо установить
  -- процедура по исправлению дат в Дополнительных договорах агенских договоров
  
--  sec         number := 15;
  
  ex_exception exception;
  text_ex_exception varchar2(300);
  res_date date;
  res_date_start date;
  res_date_change date; 
  
  cursor cur_ag_contract(cv_ag_num   varchar,	
  		                 cv_num      number, 
						 cv_now_date date) is
  select count(1) over() row_cnt,
         ac.ag_contract_id, 
  		 ac.date_begin, 
		 ach.ag_contract_header_id
    from ven_ag_contract ac, 
		 ven_ag_contract_header ach 
	where ac.NUM = cv_num
	and ac.CONTRACT_ID = ach.AG_CONTRACT_HEADER_ID
	and ac.DATE_BEGIN = cv_now_date
	and ach.num  = cv_ag_num;
	
  cursor cur_doc_status(p_doc number) is
	select dst.doc_status_id,dst.CHANGE_DATE,dst.START_DATE
                 from doc_status dst
                where dst.document_id = p_doc;  					 

  rec_ag_contract cur_ag_contract%rowtype;
  
  sec int := 0;		 
  
begin

 open cur_ag_contract(v_ag_num,v_num,v_now_date);
 fetch cur_ag_contract into rec_ag_contract;
 
 if (cur_ag_contract%notfound)then
  close cur_ag_contract;
  text_ex_exception := 'Не найден агенский договор.';
  raise ex_exception;
 end if;
 
 if (rec_ag_contract.row_cnt > 1) then
  close cur_ag_contract;
  text_ex_exception := 'Найдено более одного агентского договора.';
  raise ex_exception;
 end if;
 
 close cur_ag_contract;

	 
  --внесение изменений
  if rec_ag_contract.date_begin = v_correct_date then
    text_ex_exception := 'Дата доп версии и устанавливаемая даты равны.';
  	raise ex_exception;
  end if;
  
  update ven_ag_contract ac
   set ac.date_begin = v_correct_date,
   	   ac.reg_date = v_correct_date
   where ac.ag_contract_id = rec_ag_contract.ag_contract_id;
     
     sp_insert_object_history('ag_contract',
	                          'date_begin',
							  rec_ag_contract.ag_contract_id,
							  v_now_date,
							  v_correct_date,
							  'veselek',
							  'Апдейт дат доп соглашений по агентским');
     
    if v_num = 0 then
	
      update ven_ag_contract_header ach
         set ach.date_begin = v_correct_date,
		     ach.reg_date = v_correct_date
       where ach.ag_contract_header_id = rec_ag_contract.ag_contract_header_id;
	   
	   sp_insert_object_history('ag_contract_header',
	                            'date_begin',
	                            rec_ag_contract.ag_contract_header_id,
								v_now_date,
								v_correct_date,
								'veselek',
								'Апдейт дат доп соглашений по агентским');
       
    end if;
	
	for rec  in cur_doc_status(rec_ag_contract.ag_contract_header_id)
	loop
	
	   update doc_status ds
          set ds.start_date = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss'),
		      ds.CHANGE_DATE = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss')
        where ds.doc_status_id = rec.doc_status_id
	   return ds.start_date into res_date;
	   
	   sp_insert_object_history('doc_status',
	                            'start_date',
								rec.doc_status_id,
								rec.START_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским - голова');
								 
       sp_insert_object_history('doc_status',
	                            'CHANGE_DATE',
								rec.doc_status_id,
								rec.CHANGE_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским - голова');
	
	  sec := sec +5;
	end loop;
	
	
	for rec  in cur_doc_status(rec_ag_contract.ag_contract_id)
	loop
	
	   update doc_status ds
          set ds.start_date = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss'),
		      ds.CHANGE_DATE = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss')
        where ds.doc_status_id = rec.doc_status_id
	   return ds.start_date into res_date;
	   
	   sp_insert_object_history('doc_status',
	                            'start_date',
								rec.doc_status_id,
								rec.START_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским');
								 
       sp_insert_object_history('doc_status',
	                            'CHANGE_DATE',
								rec.doc_status_id,
								rec.CHANGE_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским');
	
	  sec := sec +5;
	end loop;
	

exception
  when ex_exception then
    DBMS_OUTPUT.put_line(text_ex_exception);
  when others then
    DBMS_OUTPUT.put_line(sqlerrm);
end correct_DS_date;
/


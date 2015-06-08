CREATE OR REPLACE PROCEDURE correct_dov_date(v_ag_num       in varchar, --номер агенского договора 6 знаков
                                              v_num          in number, --порядковый номер ДС
                                              v_now_date     in date, --дата которая сейчас задана
                                              v_correct_date in date) as--дата которую необходимо установить
             
  ex_exception exception;
  text_ex_exception varchar2(300);
  
  res_date date;
  
  sec int;
  
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
 
 
 cursor cur_ag_dover(P_AG_HEADER number, p_now_date date) is
 select * from VEN_AG_CONTRACT_DOVER A
 where A.AG_CONTRACT_HEADER_ID = P_AG_HEADER and A.DATE_START = p_now_date ;
 
   cursor cur_doc_status(p_doc number) is
	select dst.doc_status_id,dst.CHANGE_DATE,dst.START_DATE
                 from doc_status dst
                where dst.document_id = p_doc;  					 
  
 
  rec_ag_contract cur_ag_contract%rowtype;
   rec_doc_status cur_doc_status%rowtype;        
  
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
 
 for rec in cur_ag_dover(rec_ag_contract.ag_contract_header_id,v_now_date)
 loop
   update VEN_AG_CONTRACT_DOVER  A
   set  a.date_start =  to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:00','dd.mm.yyyy hh24:mi:ss'),
        a.reg_date  =  to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:00','dd.mm.yyyy hh24:mi:ss')
   where a.AG_CONTRACT_DOVER_ID = rec.AG_CONTRACT_DOVER_ID
   return a.date_start into res_date;
   
   
   
   for rec_status  in cur_doc_status(rec.AG_CONTRACT_DOVER_ID)
	loop
	
	   update doc_status ds
          set ds.start_date = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss'),
		      ds.CHANGE_DATE = to_date(to_char(v_correct_date,'dd.mm.yyyy') || ' 10:00:'||to_char(sec,'00') ,'dd.mm.yyyy hh24:mi:ss')
        where ds.doc_status_id = rec_status.doc_status_id
	   return ds.start_date into res_date;
	   
	   sp_insert_object_history('doc_status',
	                            'start_date',
								rec_status.doc_status_id,
								rec_status.START_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским');
								 
       sp_insert_object_history('doc_status',
	                            'CHANGE_DATE',
								rec_status.doc_status_id,
								rec_status.CHANGE_DATE,
								 res_date,
								 'veselek',
								 'Апдейт статусов доп соглашений по агентским');
	
	  sec := sec +5;
	end loop;
   
 end loop;
 
exception
  when ex_exception then
    DBMS_OUTPUT.put_line(text_ex_exception);
  when others then
    DBMS_OUTPUT.put_line(sqlerrm);
end correct_dov_date;
/


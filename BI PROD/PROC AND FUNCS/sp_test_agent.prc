create or replace procedure sp_test_agent is
 
begin  
for v_c in (	select ach.reg_date reg_date, 
                     doc.get_doc_status_brief(ach.last_ver_id) ver_status, 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) head_status,
                     ach.ag_contract_header_id h_id,
                     ach.last_ver_id v_id
              from   ven_ag_contract_header ach
              where  doc.get_doc_status_name(ach.last_ver_id)<> doc.get_doc_status_name(ach.ag_contract_header_id)
              order by ach.reg_date   
-- статусы расходятся
/*              select  ach.reg_date reg_date, 
                     doc.get_doc_status_brief(ach.last_ver_id) ver_status, 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) head_status,
                     ach.ag_contract_header_id h_id,
                     ach.last_ver_id l_v_id,
                     max(ac.ag_contract_id) v_id
              from ven_ag_contract_header ach
              join ven_ag_contract ac on (ac.contract_id=ach.ag_contract_header_id)
              where  doc.get_doc_status_name(ach.last_ver_id)<> doc.get_doc_status_name(ach.ag_contract_header_id)
              and    doc.get_doc_status_name(ac.ag_contract_id)=doc.get_doc_status_name(ach.ag_contract_header_id)
              group by ach.reg_date , 
                     doc.get_doc_status_brief(ach.last_ver_id) , 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) ,
                     ach.ag_contract_header_id,
                     ach.last_ver_id */
-- ласт версия меньше действующей версии доп соглашения                      
/*              select  ach.reg_date reg_date, 
                     doc.get_doc_status_brief(ach.last_ver_id) ver_status, 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) head_status,
                     ach.ag_contract_header_id h_id,
                     ach.last_ver_id l_v_id,
                     max(ac.ag_contract_id) v_id
              from ven_ag_contract_header ach
              join ven_ag_contract ac on (ac.contract_id=ach.ag_contract_header_id)
              where  doc.get_doc_status_brief(ac.ag_contract_id)in ('BREAK','CLOSE','CURRENT')
              and ac.ag_contract_id>ach.last_ver_id
              group by ach.reg_date , 
                     doc.get_doc_status_brief(ach.last_ver_id) , 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) ,
                     ach.ag_contract_header_id,
                     ach.last_ver_id 
*//*
               select  ach.reg_date reg_date, 
                     doc.get_doc_status_brief(ach.last_ver_id) ver_status, 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) head_status,
                     ach.ag_contract_header_id h_id,
                     ach.last_ver_id l_v_id,
                     max(ac.ag_contract_id) v_id
              from ven_ag_contract_header ach
              join ven_ag_contract ac on (ac.contract_id=ach.ag_contract_header_id)
              where  doc.get_doc_status_brief(ac.ag_contract_id) in ('BREAK','CLOSE','CURRENT')
              and ac.ag_contract_id>ach.last_ver_id 
              group by ach.reg_date , 
                     doc.get_doc_status_brief(ach.last_ver_id) , 
                     doc.get_doc_status_brief(ach.ag_contract_header_id) ,
                     ach.ag_contract_header_id,
                     ach.last_ver_id  */   )                 
             
/*                     select ac.ag_contract_id, ach.agency_id 
                     from ven_ag_contract_header ach
                     join ven_ag_contract ac on (ach.last_ver_id=ac.ag_contract_id) )
*/loop            
pkg_agent_1.set_last_ver (v_c.h_id, v_c.v_id);   

 /*if v_c.head_status<>'CLOSE' then
       doc.set_doc_status(v_c.v_id,v_c.ver_status);
    end if;*/
/*    update ven_ag_contract_header ach
    set ach.last_ver_id=v_c.v_id
    where ach.ag_contract_header_id=v_c.h_id;*/
 /*   update ven_ag_contract ac
    set ac.agency_id=v_c.agency_id 
    where ac.ag_contract_id=v_c.ag_contract_id;
*/end loop;
--commit;
end;
/


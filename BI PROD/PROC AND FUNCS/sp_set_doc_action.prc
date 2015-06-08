create or replace procedure sp_set_doc_action(v_doc_templ_brief varchar2,
                                              v_action_name varchar2,
                                              v_proc_name varchar2,
                                              v_action_type_brief varchar2,
                                              v_src_status_brief varchar2,
                                              v_dest_status_brief varchar2,
                                              v_sort_order number,
                                              v_is_execute number default 1,
                                              v_is_required number default 1
                                              ) as
                                              
  v_name varchar2(200):= v_action_name;
  v_ds_allowed_id number;   
  v_dsa_id number;
  v_doc_proc_id number;
  v_ds_action_type_id number;
  v_order_num number:= v_sort_order;
begin
 -- Добавляем процедуру, если ее нет
 begin
    select doc_procedure_id 
    into v_doc_proc_id
    from doc_procedure 
    where proc_name = v_proc_name
      and rownum=1;
 exception when no_data_found then
    select sq_doc_procedure.nextval
    into v_doc_proc_id
    from dual;
    insert into ven_doc_procedure(doc_procedure_id, name, proc_name)
       values(v_doc_proc_id, v_name, v_proc_name);          
 end; 
 
 -- Находим запись о переходе статусов
 select dsa.DOC_STATUS_ALLOWED_ID
 into v_ds_allowed_id
 from doc_status_allowed dsa,
      doc_templ_status src,
      doc_templ_status dest,
      doc_status_ref src_s,
      doc_status_ref dest_s,
      doc_templ dt
  where dsa.DEST_DOC_TEMPL_STATUS_ID = dest.DOC_TEMPL_STATUS_ID
    and dsa.SRC_DOC_TEMPL_STATUS_ID = src.DOC_TEMPL_STATUS_ID
    and src_s.DOC_STATUS_REF_ID = src.DOC_STATUS_REF_ID
    and dest_s.DOC_STATUS_REF_ID = dest.DOC_STATUS_REF_ID
    and src_s.BRIEF = v_src_status_brief
    and dest_s.BRIEF = v_dest_status_brief
    and src.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
    and dest.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
    and dt.BRIEF = v_doc_templ_brief;
  -- Добавляем процедуру на переход
  begin      
    select doc_action_type_id
    into v_ds_action_type_id
    from doc_action_type
    where brief = v_action_type_brief;
    
    select dsa.DOC_STATUS_ACTION_ID
    into v_dsa_id
    from doc_status_action dsa     
    where dsa.DOC_STATUS_ALLOWED_ID =   v_ds_allowed_id
        and dsa.DOC_ACTION_TYPE_ID = v_ds_action_type_id        
        and dsa.obj_URE_ID = ent.ID_BY_BRIEF('DOC_PROCEDURE')
        and dsa.obj_URO_ID = v_doc_proc_id
        and rownum=1;
   exception when no_data_found then
     insert into ven_doc_status_action(DOC_ACTION_TYPE_ID,DOC_STATUS_ALLOWED_ID, obj_URE_ID, obj_URO_ID, is_execute, is_required, sort_order)
     values  (v_ds_action_type_id,v_ds_allowed_id,ent.ID_BY_BRIEF('DOC_PROCEDURE'),v_doc_proc_id,v_is_execute,v_is_required,v_order_num);  
   end;   
end;
/


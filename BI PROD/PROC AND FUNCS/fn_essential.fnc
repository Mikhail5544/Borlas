create or replace function fn_essential(p_contact_id in number) return varchar2 is
  -- Устарело
  --Функция возвращает реквизиты организации.
  v_organ varchar2(150);
  v_contact_name varchar2(150);
  v_contact_addr varchar2(500);
  v_cont_inn number;
  v_cont_kpp number;
  v_cont_pc number;
  v_bank_name varchar2(100);
  v_bank_filial varchar2(100);
  v_bank_kc number;
  v_bank_bik number;
  v_bank_tel varchar2(15);
  v_bank_faks varchar2(10); 
  v_bank_id number; 
  v_res varchar2(1000);
begin
    select ct.description,
         ent.obj_name(c.ent_id, c.contact_id) contact_name,
         ad.address_name,
         ccba.account_nr pc,
         ccba.bank_id, 
         ent.obj_name(c.ent_id,ccba.bank_id) bank_name,
         ccba.branch_name,
         (select '('||tel.telephone_prefix||')'||' '||tel.telephone_number 
           from ven_cn_contact_telephone tel, ven_t_telephone_type tt
           where tel.telephone_type=tt.id 
             and tel.contact_id=v_bank_id and lower(tt.description) like '%рабоч%'||'%телефон%'),
         (select tel2.telephone_number 
           from ven_cn_contact_telephone tel2, ven_t_telephone_type tt2
           where tel2.telephone_type=tt2.id 
             and tel2.contact_id=v_bank_id and lower(tt2.description) like '%факс%')    
    into v_organ, v_contact_name, v_contact_addr,
         v_cont_pc, v_bank_id, v_bank_name,v_bank_filial,
         v_bank_tel,v_bank_faks
    from t_brand_company t,
         VEN_T_CONTACT_TYPE ct,
         v_cn_contact_address ad,
         ven_cn_contact_bank_acc ccba, 
         ven_contact c 
   where ccba.contact_id=c.contact_id
     and c.contact_id=t.contact_id 
     and c.contact_type_id=ct.id
     and ad.contact_id=c.contact_id
     and t.contact_id=p_contact_id;
  
  for v_r in (select tel.telephone_prefix, tel.telephone_number,lower(tt.description) des
              from ven_cn_contact_telephone tel, ven_t_telephone_type tt
              where tel.telephone_type=tt.id 
              and tel.contact_id=v_bank_id) LOOP
    if v_r.des like '%рабоч%'||'%телефон%'
       then v_bank_tel:= '('||v_r.telephone_prefix||')'||' '||v_r.telephone_number;
    end if;
    if v_r.des like '%факс%'
       then v_bank_faks:=v_r.telephone_number;
    end if;   
  END LOOP;    
     
  select sum(case when (ty.description='КПП' and ide.contact_id=p_contact_id) then ide.id_value end),
         sum(case when (ty.description='ИНН' and ide.contact_id=p_contact_id) then ide.id_value end),
         sum(case when (ty.description='Кор.счет' and ide.contact_id=v_bank_id) then ide.id_value end),
         sum(case when (ty.description='БИК' and ide.contact_id=v_bank_id) then ide.id_value end)           
    into v_cont_inn,v_cont_kpp,
         v_bank_kc,v_bank_bik 
  from ven_cn_contact_ident ide, 
       ven_t_id_type ty
  where ide.id_type=ty.id; 
  
  v_res:=v_organ||' <<'||v_contact_name||'>>'||chr(13)||v_contact_addr||chr(13)
         ||'ИНН '||v_cont_inn||',КПП '||v_cont_kpp||chr(13)||'Р/с '||v_cont_pc||chr(13)||
         'в '||v_bank_name||' '||v_bank_filial||chr(13)||'к/с '||v_bank_kc||', БИК '
         ||v_bank_bik||chr(13)||'Тел.:'||v_bank_tel||'  Факс: '||v_bank_faks;
  return v_res;
end;
/


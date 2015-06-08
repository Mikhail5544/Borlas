create or replace view v_c_declarants as
select de.c_declarants_id
      ,de.c_claim_header_id
      ,de.declarant_id
      ,de.declarant_role_id
      ,co.contact_id
      ,co.obj_name_orig       as declarant_name
      ,dr.description         as decl_role_name
      ,de.share_payment
      ,de.cn_contact_bank_acc_id
      ,ba.account_nr
      ,ba.bank_name
  from ven_c_declarants     de
      ,ven_c_event_contact  ec
      ,ven_contact          co
      ,ven_c_declarant_role dr
      ,cn_contact_bank_acc  ba
 where de.declarant_id      = ec.c_event_contact_id
   and ec.cn_person_id      = co.contact_id
   and de.declarant_role_id = dr.c_declarant_role_id
   and de.cn_contact_bank_acc_id = ba.id (+)
/*
union all
select null
      ,ch.c_claim_header_id
      ,ch.declarant_id
      ,ch.declarant_role_id
      ,co.contact_id
      ,co.obj_name_orig       as declarant_name
      ,dr.description         as decl_role_name
      ,0
  from ven_c_claim_header   ch
      ,ven_c_event_contact  ec
      ,ven_contact          co
      ,ven_c_declarant_role dr
 where ch.declarant_id      = ec.c_event_contact_id
   and ec.cn_person_id      = co.contact_id
   and ch.declarant_role_id = dr.c_declarant_role_id
*/;

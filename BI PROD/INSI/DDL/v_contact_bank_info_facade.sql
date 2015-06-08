create or replace force view v_contact_bank_info_facade as
select contact_id
      ,bik
      ,name_bank
      ,raccount_bank
      ,licaccount_bank
      ,bank_card_no
      ,inn_bank
      ,name_recipient
      ,recipient_id
      ,main
  from ins.v_contact_bank_props_info;


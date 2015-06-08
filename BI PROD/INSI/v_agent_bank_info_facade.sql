CREATE OR REPLACE FORCE VIEW V_AGENT_BANK_INFO_FACADE AS
SELECT contact_id
      ,bik
      ,name_bank
      ,raccount_bank
      ,licaccount_bank
      ,bank_card_no
      ,inn_bank
      ,name_recipient
      ,recipient_id
      ,main
  FROM ins.v_agent_bank_info;


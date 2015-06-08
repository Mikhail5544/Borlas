create or replace force view v_contact_agent_info_facade as
select "CONTACT_ID","AG_CONTRACT_HEADER_ID","NUM_AD","CATEGORY_NAME","DATE_BEGIN","DOC_DATE_PAY_PROP"
    from ins.v_contact_agent_contr_info;


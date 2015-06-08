create or replace force view vgo_agent_for_1c as
select
nvl(to_char(vga.CONTACT_ID),'_NULL_')         as CONTACT_ID,
nvl(to_char(vga.CODE),'_NULL_')               as CODE,
nvl(to_char(vga.FIRST_NAME),'_NULL_')         as FIRST_NAME,
nvl(to_char(vga.NAME),'_NULL_')               as NAME,
nvl(to_char(vga.MIDDLE_NAME),'_NULL_')        as MIDDLE_NAME,
'_NULL_'                                      as AGENCY_ID,
nvl(to_char(vga.GENDER),'_NULL_')             as GENDER,
nvl(to_char(vga.INN_VAL),'_NULL_')            as INN_VAL,
nvl(to_char(vga.KPP_VAL),'_NULL_')            as KPP_VAL,

nvl(to_char(vga.PENS_VAL),'_NULL_')           as PENS_VAL,
nvl(to_char(vga.PASS_VAL),'_NULL_')           as PASS_VAL,
nvl(to_char(vga.PASS_SERIAL),'_NULL_')        as PASS_SERIAL,
nvl(to_char(vga.PASS_PLACE),'_NULL_')         as PASS_PLACE,
nvl(to_char(vga.PASS_ISSUE_DATE,'DD.MM.YYYY'),'_NULL_')    as PASS_ISSUE_DATE,
nvl(to_char(vga.DATE_OF_BIRTH,'DD.MM.YYYY'),'_NULL_')      as DATE_OF_BIRTH,
nvl(to_char(vga.COUNTRY_BIRTH),'_NULL_')      as COUNTRY_BIRTH,
nvl(to_char(vga.KORR_VAL),'_NULL_')            as KORR_VAL,
nvl(to_char(vga.RASS_ACCOUNT),'_NULL_')        as RASS_ACCOUNT,
nvl(to_char(vga.RASS_BIK),'_NULL_')            as RASS_BIK,
nvl(to_char(vga.LIC_ACCOUNT),'_NULL_')         as LIC_ACCOUNT,
nvl(to_char(vga.ADDRESS_NAME_CONST),'_NULL_')  as ADDRESS_NAME_CONST,
nvl(to_char(vga.ADDRESS_NAME_DOM),'_NULL_')    as ADDRESS_NAME_DOM,
nvl(to_char(vga.AGENCY_ID),'_NULL_')          as AGENCY_BI_ID,
nvl(to_char(vga.AGENCY_NAME),'_NULL_')         as AGENCY_BI_NAME,
'_NULL_' 								                       as ROW_STATUS,
nvl(to_char(vga.BRANCH_NAME),'_NULL_')         as BRANCH_NAME,

nvl(to_char(vga.BANK_INN),'_NULL_')            as BANK_INN,
nvl(to_char(vga.BANK_KPP),'_NULL_')            as BANK_KPP,
'_NULL_'                                       as NALOG_1C_CODE,
nvl(to_char(vga.CODE),'_NULL_')                as CODE_2



from vgo_gate_agent vga;


CREATE OR REPLACE FORCE VIEW VGO_GATE_CONTACT_BANK_ACC AS
SELECT
  ccba.CONTACT_ID,
  ccba.BANK_NAME,
  ccba.BRANCH_NAME,
  ccba.ACCOUNT_NR,
  NVL(ins.pkg_contact.get_ident_number(ccba.BANK_ID, 'BIK'),'000000000') as BIC_CODE,
  ins.pkg_contact.get_ident_number(CCBA.BANK_ID, 'KORR') as ACCOUNT_CORR,
  ccba.ID AS  CODE,
  f.brief AS BANK_ACCOUNT_CURRENCY,
  ins.pkg_contact.get_ident_number(ccba.BANK_ID, 'INN') as BANK_INN,
  ins.pkg_contact.get_ident_number(ccba.BANK_ID, 'KPP') as BANK_KPP,
  null LIC_ACCOUNT
 FROM INS.CN_CONTACT_BANK_ACC ccba
 JOIN INS.FUND f on f.fund_id = ccba.BANK_ACCOUNT_CURRENCY_ID;


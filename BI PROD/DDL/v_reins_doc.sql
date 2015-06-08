create or replace force view v_reins_doc as
(
select s.re_slip_id id, sh.ASSIGNOR_ID, sh.REINSURER_ID, s.START_DATE, s.END_DATE, s.SIGN_DATE, sh.FUND_PAY_ID fund_id, sh.IS_IN
  from re_slip_header sh
     , ven_re_slip s
  where s.re_slip_header_id = sh.re_slip_header_id
union
select cv.re_contract_version_id id, mc.ASSIGNOR_ID, mc.REINSURER_ID, cv.START_DATE, cv.END_DATE, cv.SIGN_DATE, mc.FUND_ID, mc.IS_IN
  from re_main_contract mc
     , re_contract_version cv
  where mc.re_main_contract_id = cv.re_main_contract_id);


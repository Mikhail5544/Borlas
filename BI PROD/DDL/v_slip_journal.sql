CREATE OR REPLACE FORCE VIEW V_SLIP_JOURNAL AS
SELECT h.re_slip_header_id,
       h.re_main_contract_id,
       h.last_slip_id,
       h.sign_date,
       f.brief FUND,
       f1.brief fund_pay,
       h.is_in,
       h.num,
       s_last.re_slip_id,
       s_first.start_date,
       s_last.end_date,
       SUM(s_all.re_amount) re_amount,
       SUM(s_all.brutto_premium) brutto_premium,
       SUM(s_all.commission) commission,
       SUM(s_all.netto_premium) netto_premium
FROM ven_re_slip_header h,
     ven_re_slip s_last,
     ven_re_slip s_first,
     ven_re_slip s_all,
     ven_fund f,
     ven_fund f1
WHERE h.last_slip_id = s_last.re_slip_id
  AND h.re_slip_header_id=s_first.re_slip_header_id AND s_first.ver_num = 0
  AND h.re_slip_header_id=s_all.re_slip_header_id 
  AND f.fund_id=h.fund_id
  AND f1.fund_id=h.fund_pay_id
GROUP BY  h.re_slip_header_id,h.re_main_contract_id,h.last_slip_id,
       h.sign_date,f.brief,f1.brief,h.is_in,
       h.num,s_last.re_slip_id,s_first.start_date,s_last.end_date;


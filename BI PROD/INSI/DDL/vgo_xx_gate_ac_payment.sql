create or replace force view vgo_xx_gate_ac_payment
(gate_package_id, row_status, code, payment_id, payment_status, payment_templ_id, payment_terms_id, num, doc_date, bnr_date, doc_sum, rev_amount, inn, contact_name, fund_id, account_payer, pay_company_bank_acc_id, account_receiver, rec_company_bank_acc_id, note, change_flag, ext_id, rev_rate_type_id, rur_fund_id, rev_rate, contact_id, pay_bank_id, rec_bank_id, payment_note)
as
select xg.GATE_PACKAGE_ID, xg.ROW_STATUS, xg.CODE, xg.PAYMENT_ID, xg.PAYMENT_STATUS,
       case xg.PAYMENT_STATUS
         when '¬’'
         then (select apt1.payment_templ_id from ins.ac_payment_templ apt1 where apt1.brief = 'œœ')
         when '»—’'
         then (select apt1.payment_templ_id from ins.ac_payment_templ apt1 where apt1.brief = 'œœ»')
         else null
       end AS PAYMENT_TEMPL_ID,
       (select tpt1.id from ins.t_payment_terms tpt1 where tpt1.brief = '¡ÂÁÌ‡ÎË˜Ì‡ˇŒÔÎ‡Ú‡') AS PAYMENT_TERMS_ID,
       xg.NUM, DOC_DATE, xg.BNR_DATE,
       to_number(xg.DOC_SUM,'99999999999999D99000000000000000000','NLS_NUMERIC_CHARACTERS='',.''') AS DOC_SUM,
       to_number(xg.REV_AMOUNT,'99999999999999D99000000000000000000','NLS_NUMERIC_CHARACTERS='',.''') AS REV_AMOUNT,
        xg.INN, xg.CONTACT_NAME,
       f.FUND_ID,
       xg.ACCOUNT_PAYER,
       ccb_p.id AS PAY_COMPANY_BANK_ACC_ID,
       xg.ACCOUNT_RECEIVER,
       ccb_r.id AS REC_COMPANY_BANK_ACC_ID,
       xg.NOTE,
       xg.CHANGE_FLAG,
       'NAV#'||xg.CODE,
       (select rt1.rate_type_id from ins.rate_type rt1 where rt1.brief = '÷¡') AS REV_RATE_TYPE_ID,
       (select f1.fund_id from ins.fund f1 where f1.brief = 'RUR') AS RUR_FUND_ID,
       to_number(xg.REV_AMOUNT,'99999999999999D99000000000000000000','NLS_NUMERIC_CHARACTERS='',.''')/to_number(xg.DOC_SUM,'99999999999999D99000000000000000000','NLS_NUMERIC_CHARACTERS='',.''') AS REV_RATE,
       case xg.PAYMENT_STATUS
         when '¬’'
         then ins.pkg_app_param.get_app_param_u('GATE: ‘œ')
         when '»—’'
         then ap.CONTACT_ID
         else null
       end AS CONTACT_ID,
       ccb_p.BANK_ID AS PAY_BANK_ID,
       ccb_r.BANK_ID AS REC_BANK_ID,
       case xg.PAYMENT_STATUS
         when '¬’'
         then trim(xg.INN||' '||xg.ACCOUNT_RECEIVER||' '||xg.CONTACT_NAME||' '||xg.NOTE)
         when '»—’'
         then (select trim(ins.pkg_contact.get_ident_number(ap.CONTACT_ID, 'INN')||' '||
                      xg.ACCOUNT_PAYER||' '||
                      c1.obj_name_orig||' '||
                      xg.NOTE)
                 from ins.contact c1
                where c1.CONTACT_ID = ap.CONTACT_ID)
         else null
       end AS PAYMENT_NOTE
  from insi.XX_GATE_AC_PAYMENT xg
  left join ins.ac_payment ap on ap.payment_id = xg.PAYMENT_ID
  join ins.fund f on f.BRIEF = xg.CRN_CODE
  left join ins.cn_contact_bank_acc ccb_p on ccb_p.ACCOUNT_NR = xg.ACCOUNT_PAYER and ccb_p.contact_id = ins.pkg_app_param.get_app_param_u('WHOAMI')
  left join ins.cn_contact_bank_acc ccb_r on ccb_r.ACCOUNT_NR = xg.ACCOUNT_RECEIVER and ccb_r.contact_id = ins.pkg_app_param.get_app_param_u('WHOAMI');


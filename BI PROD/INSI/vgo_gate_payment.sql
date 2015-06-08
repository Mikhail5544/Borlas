CREATE OR REPLACE FORCE VIEW VGO_GATE_PAYMENT
(code, document_status, payment_number, bi_document_no, document_type, amount_rur, currency, amount_cur, contact_bank_acc_id, contact_id, date_ext, due_date, grace_date, description)
AS
SELECT ap.PAYMENT_ID as CODE,
       dsr.BRIEF as DOC_STATUS,
       ap.PAYMENT_NUMBER,
       d.NUM BI_DOCUMENT_NO,
       dt.BRIEF AS DOCUMENT_TYPE,
       to_char(ap.AMOUNT,'9999999999999999.99') AS AMOUNT_CUR,
       f.brief AS CURRENCY,
       to_char(ap.REV_AMOUNT,'9999999999999999.99') AS AMOUNT_RUR,
       ap.CONTACT_BANK_ACC_ID,
       ap.CONTACT_ID,
       ap.DATE_EXT,
       ap.DUE_DATE,
       ap.GRACE_DATE,
       d.NOTE AS DESCRIPTION
  FROM ins.AC_PAYMENT ap
  JOIN ins.FUND f on f.fund_id=ap.fund_id
  JOIN ins.document d on d.document_id = ap.payment_id
  JOIN (select row_number() over (partition by t.document_id order by t.START_DATE DESC) AS rnum,
               t.DOCUMENT_ID,
               t.DOC_STATUS_REF_ID
          from ins.doc_status t
         where t.start_date <= SYSDATE) ds on ds.DOCUMENT_ID = d.DOCUMENT_ID and ds.rnum = 1
  JOIN ins.DOC_STATUS_REF dsr on dsr.DOC_STATUS_REF_ID = ds.DOC_STATUS_REF_ID
  JOIN ins.DOC_TEMPL dt on dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID and dt.BRIEF in ('PAYORDER','PAYORDBACK');


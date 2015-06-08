CREATE OR REPLACE FORCE VIEW V_REFUSAL_NOT_PROCESSED
(
   REGISTRY_NAME,
   RECIEVE_DATE,
   INSURED_NAME,
   POLICY_NUMBER,
   NOTICE_DATE,
   POLICY_START_DATE,
   DAYS_OF_CREDIT,
   CREDIT_END_DATE,
   HOME_PHONE,
   CELL_PHONE,
   DECLINE_NOTICE_DATE,
   PAYMENT_GENERATED,
   APPLICATION_PLACE,
   IS_HKFB_ACCOUNT,
   BANK_BIK,
   ACCOUNT_NUMBER,
   IS_CREDIT,
   APPLICATION_REASON,
   BANK_RETURN_AMOUNT,
   BANK_RETURN_AG_AMOUNT,
   BANK_RETURN_RKO_AMOUNT,
   DECISION,
   DECLINE_NOTE,
   COMPANY_RETURN_AMOUNT,
   COMPANY_RETURN_AG_AMOUNT,
   COMPANY_RETURN_RKO_AMOUNT,
   REGISTRATION_DATE,
   RESPONSIBLE,
   PRODUCT_NAME,
   BANK_NOTICE
)
AS
   SELECT /*
             Отложенное задание “Контроль отказов по необработанным заявлениям на прекращение”
             В статусе "Расторгнуть в СК"  или "Передано в банк" и больше 10 дней
             Черных М.
             22.10.2014
             */
    v.registry_name
   ,v.recieve_date
   ,v.insured_name
   ,v.policy_number
   ,v.notice_date
   ,v.policy_start_date
   ,v.days_of_credit
   ,v.credit_end_date
   ,v.home_phone
   ,v.cell_phone
   ,v.decline_notice_date
   ,v.payment_generated
   ,v.application_place
   ,v.is_hkfb_account
   ,v.bank_bik
   ,v.account_number
   ,v.is_credit
   ,v.application_reason
   ,v.bank_return_amount
   ,v.bank_return_ag_amount
   ,v.bank_return_rko_amount
   ,v.decision
   ,v.decline_note
   ,v.company_return_amount
   ,v.company_return_ag_amount
   ,v.company_return_rko_amount
   ,v.registration_date
   ,v.responsible
   ,v.product_name
   ,v.bank_notice
     FROM ven_decline_journal_hkfb v
         ,doc_status               ds
    WHERE v.doc_status_id = ds.doc_status_id
      AND (v.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('BRAKE_IN_COMPANY') OR
          v.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('TRANSFER_TO_BANK') AND
          ds.start_date <= SYSDATE - 10);


GRANT SELECT ON V_REFUSAL_NOT_PROCESSED TO INS_EUL;

GRANT SELECT ON V_REFUSAL_NOT_PROCESSED TO INS_READ;

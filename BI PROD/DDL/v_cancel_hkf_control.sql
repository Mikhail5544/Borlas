CREATE OR REPLACE FORCE VIEW V_CANCEL_HKF_CONTROL
(
   REGISTRY_NAME,
   INSURED_NAME,
   POLICY_NUMBER,
   DECLINE_NOTICE_DATE,
   APPLICATION_PLACE,
   APPLICATION_REASON,
   DECISION,
   DECLINE_NOTE,
   COMPANY_RETURN_AMOUNT,
   BANK_RETURN_AMOUNT,
   CREDIT_END_DATE,
   BANK_BIK,
   ACCOUNT_NUMBER,
   STATUS_NAME
)
AS
   SELECT /*
             ќтложенное задание У онтроль отказов по за€влени€м на прекращениеФ
             ѕервый этап Ц выбираютс€ все записи в журнале. »з выборки исключаютс€ записи, у которых значение в поле УЌомер договораФ не уникально Ц в выборке остаетс€ запись с максимальной датой статуса.
             ¬торой этап Ц из выборки, сформированной на первом этапе, отбираютс€ записи в статусе:
             Х  ќтказ Ц записи в таком статусе выбираютс€, если значение в поле У омментарииФ отлично от Уƒоговор не найденФ или Уƒоговор не оплаченФ
             Х  –асторгнуть в — 
             Х  ѕередано в Ѕанк Ц записи в таком статусе выбираютс€, если статус установлен больше 10 дней на момент выполнени€ задани€
             „ерных ћ.
             22.10.2014
             */
    v.registry_name
   ,v.insured_name
   ,v.policy_number
   ,v.decline_notice_date
   ,v.application_place
   ,v.application_reason
   ,v.decision
   ,v.decline_note
   ,v.company_return_amount
   ,v.bank_return_amount
   ,v.credit_end_date
   ,v.bank_bik
   ,v.account_number
   ,(SELECT r.name FROM doc_status_ref r WHERE r.doc_status_ref_id = v.doc_status_ref_id) status_name
     FROM ven_decline_journal_hkfb v
         ,doc_status               ds
    WHERE v.decline_journal_hkfb_id IN (SELECT MAX(d.decline_journal_hkfb_id) keep(dense_rank FIRST ORDER BY ds.start_date DESC)
                                          FROM ven_decline_journal_hkfb d
                                              ,doc_status               ds
                                         WHERE d.doc_status_id = ds.doc_status_id
                                         GROUP BY d.policy_number)
      AND (v.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('REFUSE') AND
          v.decline_note NOT IN
          ('ƒоговор не найден', 'ƒоговор не оплачен') OR
          v.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('BRAKE_IN_COMPANY') OR
          v.doc_status_ref_id = dml_doc_status_ref.get_id_by_brief('TRANSFER_TO_BANK') AND
          ds.start_date <= SYSDATE - 10)
      AND v.doc_status_id = ds.doc_status_id;


GRANT SELECT ON V_CANCEL_HKF_CONTROL TO INS_EUL;

GRANT SELECT ON V_CANCEL_HKF_CONTROL TO INS_READ;

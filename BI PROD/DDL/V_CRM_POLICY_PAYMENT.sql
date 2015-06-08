CREATE OR REPLACE VIEW V_CRM_POLICY_PAYMENT AS
SELECT ps.policy_id
      ,ps.document_id payment_id
      ,ps.plan_date grace_date              -- срок платежа
      ,ps.grace_date plan_date              -- дата окончания льготного периода
      ,ps.amount                            -- сумма по договру
      ,ps.part_pay_amount                   -- зачтено по договору
      ,(SELECT MIN(list_doc_date)           -- дата поступления
        FROM v_policy_payment_set_off
        WHERE main_doc_id = ps.document_id) payment_data
      ,ps.doc_status_ref_name name          -- статус
      ,ps.pol_header_id
FROM v_policy_payment_schedule ps
ORDER BY ps.plan_date;
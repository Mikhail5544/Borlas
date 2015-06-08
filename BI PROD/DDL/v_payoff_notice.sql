CREATE OR REPLACE VIEW V_PAYOFF_NOTICE AS
SELECT
/*
Договоры страхования, с признаком «Групповой договор» равным «0 – нет»,
для которых существует документ вида «Реквизиты на выплату»
с типом «Заявление на расторжение» в статусе «Готов к обработке»
26.12.2015 Черных М.
*/
 pph.policy_id
,cn.p_pol_change_notice_id
  FROM p_pol_change_notice      cn
      ,document                 d
      ,doc_status_ref           dsr
      ,t_pol_change_notice_type typ
      ,p_pol_header             pph
 WHERE cn.p_pol_change_notice_id = d.document_id
   AND d.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief = 'READY_TO_WORK' /*Готов к работе*/
   AND cn.t_pol_change_notice_type_id = typ.t_pol_change_notice_type_id
   AND typ.brief = 'PAYOFF' /*Реквизиты на выплату*/
   AND cn.policy_header_id = pph.policy_header_id
   AND NOT EXISTS (SELECT NULL
          FROM p_policy pp
         WHERE pp.pol_header_id = cn.policy_header_id
           AND pp.is_group_flag = 1) /*Нет версий с признаком "Групповой ДС"*/
;

create view INS.V_HKF_DECLINE_OR_ANNULATE
as
SELECT rownum as rn
      ,ph.ids
      ,pp.pol_num
      ,pr.description AS product_name
      ,pi.contact_name
      ,ppf.premium
      ,pd.issuer_return_sum
      ,CASE
         WHEN dr.brief IN ('РешениеБанкаАннулирование'
                          ,'Решение суда (аннулирование)') THEN
          'Банк'
         ELSE
          'Клиент'
       END AS initiator
      ,ppf.confirm_date policy_begin_date
      ,pd.decline_notice_date
      ,pd.issuer_return_date
      ,dr.name AS decline_reason
  FROM p_pol_header     ph
      ,p_policy         pp
      ,document         dc
      ,doc_status_ref   dsr
      ,t_product        pr
      ,v_pol_issuer     pi
      ,p_pol_decline    pd
      ,t_decline_reason dr
      ,p_policy         ppf
 WHERE ph.max_uncancelled_policy_id = pp.policy_id
   AND pp.policy_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
   AND dsr.brief IN ('TO_QUIT_CHECKED', 'QUIT')
   AND ph.product_id = pr.product_id
   AND pp.policy_id = pi.policy_id
   AND pp.policy_id = pd.p_policy_id
   AND pp.decline_reason_id = dr.t_decline_reason_id
   AND ppf.pol_header_id = ph.policy_header_id
   AND ppf.version_num = 1
   AND ph.policy_header_id IN (SELECT pad.policy_header_id
                                 FROM p_policy_agent_doc pad
                                     ,ag_contract_header ch
                                     ,document           dcch
                                     ,ins_dwh.rep_param  rp
                                WHERE pad.ag_contract_header_id = ch.ag_contract_header_id
                                  AND ch.ag_contract_header_id = dcch.document_id
                                  AND dcch.num = rp.param_value
                                  AND rp.rep_name = 'HKF_DECL_OR_ANN'
                                  AND rp.param_name = 'agent_num')
   AND pd.act_date BETWEEN (SELECT to_date(rp.param_value, 'dd.mm.yyyy')
                              FROM ins_dwh.rep_param rp
                             WHERE rp.rep_name = 'HKF_DECL_OR_ANN'
                               AND rp.param_name = 'start_date')
                       AND (SELECT to_date(rp.param_value, 'dd.mm.yyyy')
                              FROM ins_dwh.rep_param rp
                             WHERE rp.rep_name = 'HKF_DECL_OR_ANN'
                               AND rp.param_name = 'end_date');

grant select on INS.V_HKF_DECLINE_OR_ANNULATE to INS_EUL;
grant select on INS.V_HKF_DECLINE_OR_ANNULATE to INS_READ;

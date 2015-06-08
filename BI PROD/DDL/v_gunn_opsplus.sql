CREATE OR REPLACE FORCE VIEW V_GUNN_OPSPLUS AS
SELECT   3  AS    "PRIZN"
         ,'Количество проданных полисов всего' AS "Месяц/Показатели"
         ,SUM(CASE WHEN (ph.start_date BETWEEN (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'start_date') AND (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'end_date')) THEN 1 ELSE 0 END) AS "Количество ДС"
FROM     t_product              tp
         ,p_pol_header          ph
WHERE    tp.DESCRIPTION         =   'ОПС +'
AND      tp.product_id          =   ph.product_id

AND      EXISTS (SELECT 1
                 FROM   p_policy          pp
                        ,doc_doc          dd
                        ,ac_payment       ap
                        ,doc_status       ds
                        ,doc_status_ref   dsr
                 WHERE
                        ph.policy_header_id    =   pp.pol_header_id
                   AND  pp.version_num         =   1
                   AND  pp.policy_id           =   dd.parent_id
                   AND  dd.child_id            =   ap.payment_id
                   --cуществование привязки к ПД4
                   AND EXISTS (SELECT 1
                                 FROM doc_set_off                      dso,
                                      ac_payment                   ap2
                                WHERE dso.parent_doc_id                = ap.payment_id
                                  AND dso.child_doc_id                 = ap2.payment_id)
                   AND  pp.policy_id         = ds.document_id
                   AND  ds.doc_status_ref_id = dsr.doc_status_ref_id
                   AND  dsr.brief  IN  ('NEW','PROJECT','ACTIVE','DOC_REQUEST','MED_OBSERV','REVISION','AGENT_REVISION','PRINTED','CURRENT')
                )
UNION

SELECT   2
         ,'Сумма годовой премии'
         ,SUM(CASE WHEN (pp1.start_date BETWEEN (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'start_date') AND (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'end_date')) THEN pp1.premium ELSE 0 END)
FROM     t_product              tp
         ,p_pol_header          ph
         ,p_policy              pp1
WHERE    tp.DESCRIPTION         =   'ОПС +'
AND      tp.product_id          =   ph.product_id
AND      ph.policy_header_id    =   pp1.pol_header_id
AND      pp1.version_num         =   1
AND      EXISTS (SELECT 1
                 FROM   p_policy          pp
                        ,doc_doc          dd
                        ,ac_payment       ap
                        ,doc_status       ds
                        ,doc_status_ref   dsr
                 WHERE
                        ph.policy_header_id    =   pp.pol_header_id
                   AND  pp.policy_id           =   pp1.policy_id
                   AND  pp.version_num         =   1
                   AND  pp.policy_id           =   dd.parent_id
                   AND  dd.child_id            =   ap.payment_id
                   --cуществование привязки к ПД4
                   AND EXISTS (SELECT 1
                                 FROM doc_set_off                      dso,
                                      ac_payment                   ap2
                                WHERE dso.parent_doc_id                = ap.payment_id
                                  AND dso.child_doc_id                 = ap2.payment_id)
                   AND  pp.policy_id         = ds.document_id
                   AND  ds.doc_status_ref_id = dsr.doc_status_ref_id
                   AND  dsr.brief  IN  ('NEW','PROJECT','ACTIVE','DOC_REQUEST','MED_OBSERV','REVISION','AGENT_REVISION','PRINTED','CURRENT')
                )

UNION

SELECT   DISTINCT 1
         ,d.NAME
         ,SUM(CASE WHEN (ph.start_date BETWEEN (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'start_date') AND (SELECT rp.param_value FROM ins_dwh.rep_param rp WHERE rp.rep_name = 'ops_plus' AND rp.param_name = 'end_date')) THEN 1 ELSE 0 END)
FROM     t_product              tp
         ,p_pol_header          ph
         ,department            d
WHERE    tp.DESCRIPTION         =   'ОПС +'
AND      tp.product_id          =   ph.product_id
AND      EXISTS (SELECT 1
                 FROM   p_policy          pp
                        ,doc_doc          dd
                        ,ac_payment       ap
                        ,doc_status       ds
                        ,doc_status_ref   dsr
                 WHERE
                        ph.policy_header_id    =   pp.pol_header_id
                   AND  pp.version_num         =   1
                   AND  pp.policy_id           =   dd.parent_id
                   AND  dd.child_id            =   ap.payment_id
                   --cуществование привязки к ПД4
                   AND EXISTS (SELECT 1
                                 FROM doc_set_off                      dso,
                                      ac_payment                   ap2
                                WHERE dso.parent_doc_id                = ap.payment_id
                                  AND dso.child_doc_id                 = ap2.payment_id)
                   AND  pp.policy_id         = ds.document_id
                   AND  ds.doc_status_ref_id = dsr.doc_status_ref_id
                   AND  dsr.brief  IN  ('NEW','PROJECT','ACTIVE','DOC_REQUEST','MED_OBSERV','REVISION','AGENT_REVISION','PRINTED','CURRENT')
                )

AND      d.department_id        =   (SELECT ach.agency_id
                                     FROM ag_contract_header    ach
                                     WHERE ach.ag_contract_header_id = pkg_renlife_utils.get_p_agent_sale(ph.policy_header_id))
GROUP BY d.NAME
ORDER BY 1
;


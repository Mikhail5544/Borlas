CREATE OR REPLACE VIEW V_REP_PPI_600 AS
SELECT ph.ids "ИДС"
       ,cont.obj_name_orig "Наименование Страхователя"
       ,CASE
         WHEN cont_t.id IN (SELECT ct.id
                              FROM t_contact_type ct
                            CONNECT BY PRIOR ct.id = ct.upper_level_id
                             START WITH ct.id = 1 /*Физическое лицо*/ ) 
              AND rl.brief = 'Terror' THEN
          rl.description /*террорист, экстремист*/
         ELSE
          NULL
       END "Уровень риска контрагента"
       ,(SELECT MAX(cntry.description)
          FROM cn_contact_address ca
          JOIN cn_address adr
            ON adr.id = ca.adress_id
          JOIN t_fatf_list fatf
            ON fatf.country_id = adr.country_id
          JOIN t_country cntry
            ON cntry.id = fatf.country_id
         WHERE ca.contact_id = src.contact_id) "Признак вхождения в ч.с. ФАТФ"
       ,pkg_contact_rep_utils.get_address(coalesce(pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'CONST')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'FK_CONST')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'DOMADD')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'FK_DOMADD')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'POSTAL')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'FK_POSTAL')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'TEMPORARY')
                                                 ,pkg_contact_rep_utils.get_last_active_address_id(cont.contact_id
                                                                                                  ,'FK_TEMPORARY'))) "Адрес"
       
       ,cc.description "Гражданство"
       ,src.last_payment_date "Дата последнего исх. платежа"
       ,src.last_payment_num "Номер последнего исх. платежа"
       ,(SELECT nvl(ap.payer_bank_name, c.obj_name_orig)
          FROM ac_payment ap
              ,contact    c
         WHERE c.contact_id = ap.contact_id
           AND ap.payment_id = src.payment_id -- param
           AND rownum = 1) "Контрагент послед.исх. платежа"
       ,src.amount "Сумма последнего исх. платежа"
       ,src.sum_amount "Сумма исходящих платежей"

  FROM (SELECT acp.*
              ,SUM(acp.amount) over(PARTITION BY acp.pol_header_id, acp.contact_id) sum_amount
          FROM (SELECT pp.pol_header_id
                      ,MAX(ap.due_date) keep(dense_rank LAST ORDER BY ap.due_date, dd.child_id) last_payment_date
                      ,MAX(ap.payment_number) keep(dense_rank LAST ORDER BY ap.due_date, dd.child_id) last_payment_num
                      ,MAX(ap.payment_id) keep(dense_rank LAST ORDER BY ap.due_date, dd.child_id) payment_id
                      ,ap.amount
                      ,ap.contact_id
                
                  FROM p_policy   pp
                      ,doc_doc    dd
                      ,ac_payment ap
                      ,document   dc
                 WHERE dd.parent_id = pp.policy_id
                   AND ap.payment_id = dd.child_id
                   AND dc.document_id = dd.child_id
                   AND ap.payment_direct_id = 1 /*исходящий*/
                   AND ap.payment_type_id = 1 /*фактический*/ 
                   AND dc.doc_templ_id = 124 /*ППИ*/ 
                 GROUP BY pp.pol_header_id
                         ,ap.amount
                         ,ap.contact_id
                
                UNION ALL
                SELECT p.pol_header_id
                      ,MAX(ap.due_date) keep(dense_rank LAST ORDER BY ap.due_date) last_payment_date
                      ,MAX(ap.payment_number) keep(dense_rank LAST ORDER BY ap.due_date) last_payment_num
                      ,MAX(ap.payment_id) keep(dense_rank LAST ORDER BY ap.due_date) payment_id
                      ,ap.amount
                      ,ap.contact_id
                
                  FROM p_policy p
                      ,ven_c_claim_header cch
                      ,ven_c_claim cc
                      ,(SELECT d.document_id
                              ,cc.c_claim_header_id
                          FROM document  d
                              ,doc_templ dt
                              ,doc_doc   dd
                              ,c_claim   cc
                         WHERE d.doc_templ_id = dt.doc_templ_id
                           AND dt.brief IN ('PAYORDER', 'PAYORDER_SETOFF')
                           AND dd.child_id = d.document_id
                           AND dd.parent_id = cc.c_claim_id) cpsh
                      ,doc_set_off dso
                      ,ac_payment ap
                 WHERE cch.p_policy_id = p.policy_id
                   AND cch.c_claim_header_id = cc.c_claim_header_id
                   AND seqno =
                       (SELECT MAX(seqno) FROM ven_c_claim WHERE c_claim_header_id = cc.c_claim_header_id)
                   AND cpsh.c_claim_header_id = cch.c_claim_header_id
                   AND dso.parent_doc_id = cpsh.document_id
                   AND ap.payment_id = dso.child_doc_id
                   AND ap.payment_direct_id = 1 /*исходящий*/
                   AND ap.payment_type_id = 1 /*фактический*/ 
                   AND doc.get_doc_templ_id(ap.payment_id) = 124 -- ППИ 
                    and nvl(doc.get_doc_status_brief(dso.doc_set_off_id),'x') not in ('ANNULATED')
                 GROUP BY p.pol_header_id
                         ,ap.amount
                         ,ap.contact_id) acp) src
      ,p_pol_header ph
      ,p_policy_contact pc
      ,contact cont
      ,t_contact_type cont_t
      ,t_risk_level rl
      ,cn_person cp
      ,t_country cc

 WHERE ph.policy_header_id = src.pol_header_id
   AND pc.policy_id = ph.policy_id
   AND pc.contact_policy_role_id = 6 --Страхователь
   AND cont.contact_id = pc.contact_id
   AND cont_t.id = cont.contact_type_id
   AND rl.t_risk_level_id = cont.risk_level
   AND cp.contact_id(+) = src.contact_id
   AND cc.country_code(+) = cp.country_birth;

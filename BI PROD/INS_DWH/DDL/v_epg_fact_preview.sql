CREATE OR REPLACE VIEW INS_DWH.V_EPG_FACT_PREVIEW AS
SELECT /*+ LEADING (pr ph) INDEX(ph IX_P_POL_HEADER_03) INDEX (dm UK_DM_P_POL_HEADER_ID)*/
 epg.payment_id
,
 --ph.ext_id ph_ext_id,
 pp.pol_header_id
,pt.description pay_term
,cm.description coll_method
,epg.plan_date
,epg.due_date
,epg.grace_date
,epg.num
,ins.doc.get_doc_status_name(epg.payment_id) epg_status
,CASE
   WHEN abs(epg.plan_date - ph.start_date) < 5 THEN
    1
   ELSE
    0
 END first_epg
,
 
 (epg.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                     FROM ins.doc_set_off dso
                         ,ins.doc_doc     dd
                    WHERE 1 = 1
                      AND dso.parent_doc_id = epg.payment_id
                      AND dd.child_id = dso.child_doc_id
                      AND dd.parent_id = pp.policy_id)
                  ,0)) * ins.acc.get_cross_rate_by_id(1, ph.fund_id, 122, epg.plan_date) epg_amount_rur
,
 
 epg.amount - nvl((SELECT SUM(dso.set_off_child_amount)
                    FROM ins.doc_set_off dso
                        ,ins.doc_doc     dd
                   WHERE 1 = 1
                     AND dso.parent_doc_id = epg.payment_id
                     AND dd.child_id = dso.child_doc_id
                     AND dd.parent_id = pp.policy_id)
                 ,0) epg_amount
,
 
 (SELECT MAX(CASE
               WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                pay_doc.due_date
               ELSE
                (SELECT MAX(acp.due_date)
                   FROM ins.doc_doc     dd
                       ,ins.doc_set_off dso2
                       ,ins.ac_payment  acp
                  WHERE dd.parent_id = dso.child_doc_id
                    AND dd.child_id = dso2.parent_doc_id
                    AND dso2.child_doc_id = acp.payment_id
                    AND acp.payment_templ_id IN (2, 16123, 16125)
                    AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
             END)
    FROM ins.doc_set_off    dso
        ,ins.ven_ac_payment pay_doc
   WHERE dso.parent_doc_id = epg.payment_id
     AND dso.child_doc_id = pay_doc.payment_id
     AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') pay_date
,
 
 (SELECT SUM(CASE
               WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                dso.set_off_child_amount
               ELSE
                (SELECT SUM(dso2.set_off_child_amount)
                   FROM ins.doc_doc     dd
                       ,ins.doc_set_off dso2
                       ,ins.ac_payment  acp
                  WHERE dd.parent_id = dso.child_doc_id
                    AND dd.child_id = dso2.parent_doc_id
                    AND dso2.child_doc_id = acp.payment_id
                    AND acp.payment_templ_id IN (2, 16123, 16125)
                    AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
             END)
    FROM ins.doc_set_off    dso
        ,ins.ven_ac_payment pay_doc
   WHERE dso.parent_doc_id = epg.payment_id
     AND dso.child_doc_id = pay_doc.payment_id
     AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') set_of_amt_rur
,
 
 (SELECT SUM(CASE
               WHEN pay_doc.doc_templ_id IN (86, 16174, 16176) THEN
                dso.set_off_amount
               ELSE
                CASE
                  WHEN ph.fund_id = 122 THEN
                   (SELECT SUM(ROUND(dso2.set_off_child_amount *
                                     ins.acc.get_cross_rate_by_id(1, acp.fund_id, 122, dso2.set_off_date)
                                    ,2))
                      FROM ins.doc_doc     dd
                          ,ins.doc_set_off dso2
                          ,ins.ac_payment  acp
                     WHERE dd.parent_id = dso.child_doc_id
                       AND dd.child_id = dso2.parent_doc_id
                       AND dso2.child_doc_id = acp.payment_id
                       AND acp.payment_templ_id IN (2, 16123, 16125)
                       AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
                  ELSE
                   (SELECT SUM(ROUND(dso2.set_off_amount *
                                     ins.acc.get_cross_rate_by_id(1, acp.fund_id, ph.fund_id, pd4.due_date)
                                    ,2))
                      FROM ins.ac_payment  pd4
                          ,ins.doc_doc     dd
                          ,ins.doc_set_off dso2
                          ,ins.ac_payment  acp
                     WHERE dd.parent_id = dso.child_doc_id
                       AND dd.child_id = dso2.parent_doc_id
                       AND dso2.child_doc_id = acp.payment_id
                       AND acp.payment_templ_id IN (2, 16123, 16125)
                       AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED'
                       AND pd4.payment_id = dso.child_doc_id)
                END
             END)
    FROM ins.doc_doc        dd
        ,ins.p_policy       pp
        ,ins.p_pol_header   ph
        ,ins.doc_set_off    dso
        ,ins.ven_ac_payment pay_doc
   WHERE dso.parent_doc_id = epg.payment_id
     AND dso.child_doc_id = pay_doc.payment_id
     AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
     AND dd.parent_id = pp.policy_id
     AND dd.child_id = dso.parent_doc_id
     AND ph.policy_header_id = pp.pol_header_id
  
  ) set_of_amt
,(SELECT SUM(dso.set_off_child_amount)
    FROM ins.doc_set_off    dso
        ,ins.ven_ac_payment pay_doc
   WHERE dso.parent_doc_id = epg.payment_id
     AND dso.child_doc_id = pay_doc.payment_id
     AND pay_doc.doc_templ_id = 13304
     AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') hold_amt_rur
,
 
 (SELECT SUM(dso.set_off_amount)
    FROM ins.doc_set_off    dso
        ,ins.ven_ac_payment pay_doc
   WHERE dso.parent_doc_id = epg.payment_id
     AND dso.child_doc_id = pay_doc.payment_id
     AND pay_doc.doc_templ_id = 13304
     AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED') hold_amt
,
 /*-------------------------- AGNET INFO-------------------------*/NULL agent_ad_id
,NULL agent_id
,NULL agent_stat
,NULL agent_agency
,
 /*-------------------------- MANAGER INFO-------------------------*/NULL manager_ad_id
,NULL manager_id
,NULL manager_stat
,NULL manager_agency
,
 /*-------------------------- DIR INFO-------------------------*/NULL dir_ad_id
,NULL dir_id
,NULL dir_stat
,NULL dir_agency
,decode(FLOOR(MONTHS_BETWEEN(epg.plan_date, ph1.start_date) /
              decode(ph1.max_pay_term
                    ,'Ежеквартально'
                    ,3
                    ,'Раз в полгода'
                    ,6
                    ,'Ежегодно'
                    ,12
                    ,'Единовременно'
                    ,100000
                    ,'Ежемесячно'
                    ,1
                    ,12)) + 1
       ,0
       ,1
       ,FLOOR(MONTHS_BETWEEN(epg.plan_date, ph1.start_date) /
              decode(ph1.max_pay_term
                    ,'Ежеквартально'
                    ,3
                    ,'Раз в полгода'
                    ,6
                    ,'Ежегодно'
                    ,12
                    ,'Единовременно'
                    ,100000
                    ,'Ежемесячно'
                    ,1
                    ,12)) + 1) epg_num
, /* Байтин А.
               Заявка 164825
               Поле "Индексированный взнос"
            */(SELECT SUM(se.fee)
    FROM ins.as_asset       se
        ,ins.ven_p_policy   ipp
        ,ins.doc_status_ref dsr_ipp --261409: FW: Сопровождение
   WHERE ipp.pol_header_id = pp.pol_header_id
     AND se.p_policy_id = ipp.policy_id
     AND se.status_hist_id != 3
     AND epg.plan_date = ipp.start_date
        --Чирков 261409: FW: Сопровождение
     AND ipp.doc_status_ref_id = dsr_ipp.doc_status_ref_id
     AND dsr_ipp.brief != 'CANCEL'
        --261409: FW: Сопровождение
     AND EXISTS (SELECT NULL
            FROM ins.doc_status pdc
           WHERE pdc.document_id = ipp.policy_id
             AND pdc.doc_status_ref_id = 81)) AS index_fee
,(SELECT wm_concat(at.description)
    FROM ins.p_pol_addendum_type ad
        ,ins.t_addendum_type     at
   WHERE ad.t_addendum_type_id = at.t_addendum_type_id
     AND ad.p_policy_id = (SELECT MAX(pp1.policy_id)
                             FROM ins.p_policy pp1
                            WHERE trunc(pp1.start_date) = epg.plan_date
                                 /*TO_DATE('18.02.2013')*/
                              AND pp1.pol_header_id = ph.policy_header_id
                                 /*39686788*/
                              AND EXISTS (SELECT NULL
                                     FROM ins.doc_status     ds2
                                         ,ins.doc_status_ref dsr2
                                    WHERE ds2.doc_status_ref_id = dsr2.doc_status_ref_id
                                      AND dsr2.brief = 'CURRENT'
                                      AND ds2.document_id = pp1.policy_id))) addendum_type
 
,
 
 nvl((SELECT SUM(dso.set_off_child_amount)
       FROM ins.doc_set_off dso
           ,ins.doc_doc     dd
      WHERE 1 = 1
        AND dso.parent_doc_id = epg.payment_id
        AND dd.child_id = dso.child_doc_id
        AND dd.parent_id = pp.policy_id)
    ,0) * ins.acc.get_cross_rate_by_id(1, ph.fund_id, 122, epg.plan_date) epg_amount_rur_acc
,
 
 nvl((SELECT SUM(dso.set_off_child_amount)
       FROM ins.doc_set_off dso
           ,ins.doc_doc     dd
      WHERE 1 = 1
        AND dso.parent_doc_id = epg.payment_id
        AND dd.child_id = dso.child_doc_id
        AND dd.parent_id = pp.policy_id)
    ,0) epg_amount_acc

  FROM ins.ven_ac_payment      epg
      ,ins.doc_doc             dd
      ,ins.doc_templ           dt
      ,ins.p_policy            pp
      ,ins.p_pol_header        ph
      ,ins_dwh.dm_p_pol_header ph1
      ,ins.t_collection_method cm
      ,ins.t_payment_terms     pt
      ,ins.t_product           pr
 WHERE pp.policy_id = dd.parent_id
   AND dd.child_id = epg.payment_id
   AND epg.doc_templ_id = dt.doc_templ_id
   AND dt.brief = 'PAYMENT'
   AND ph1.policy_header_id = ph.policy_header_id
      --AND doc.get_doc_status_brief(epg.payment_id) not in ('NEW','ANNULATED')
   AND epg.plan_date <= ADD_MONTHS(SYSDATE, 4)
   AND ph.policy_header_id = pp.pol_header_id
   AND cm.id = pp.collection_method_id
   AND pt.id = pp.payment_term_id
   AND ph.product_id = pr.product_id
   AND pr.brief NOT LIKE 'CR92%'
   --AND ph.ids = 4140040970

--SELECT ins.pkg_renlife_utils.get_p_agent_current(14655674,'30.09.2009',1) FROM dual
--  AND epg.plan_date > '01.06.2009';;
;

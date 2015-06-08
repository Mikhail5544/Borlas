<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
   <userParameter name="P_SID"/>
    <userParameter name="PNUMBER"/>
	<userParameter name="NTID"/>
	<userParameter name="NUM"/>
    <userParameter name="P_MONTH" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="name_letter" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SYS_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_YEAR" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="NOTIF" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[  select count(*) rec_count
    from notif_letter_rep rep
   where rep.sessionid = :P_SID
           ]]>
      </select>
      <group name="group_count">
        <dataItem name="rec_count"/>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[
SELECT rownum rec_num
      ,t.type_operation
  ,t.ig_type
  ,t.policy_header_id
  ,t.ids
  ,t.pol_num
  ,t.notice_ser
  ,t.notice_num
  ,t.prod_name
  ,t.plo_description
  ,t.p_cover_id
  ,t.plo_od
  ,t.region_name
  ,t.region_code
  ,t.holder_name
  ,t.holder_id
  ,t.type_holder
  ,t.rezident
  ,t.country_holder
  ,t.holder_name
  ,t.holder_id
  ,t.type_holder
  ,t.rezident
  ,t.country_holder
  ,t.agent_name
  ,t.brief_cur
  ,t.ins_amount
  ,t.ph_start_date
  ,t.ph_end_date
  ,t.fee
  ,t.premium
  ,t.payment_period
  ,CASE WHEN t.return_sum < 0 THEN 0 ELSE t.return_sum END return_sum
  ,t.return_part_of_sum
  ,t.account_91
  ,t.account_92
  ,t.act_date
  ,t.pay_date
  ,t.ds_start_date
  ,t.reason_termination
  ,t.view_termination
  ,t.this_ids
  ,t.return_sum
  ,t.insured_name
  ,t.insured_id
  ,t.cr_prod_name
  ,t.group_risk_name
  ,t.type_change
 ,t.account_92 + t.account_91 sum_91_92
FROM
(
SELECT ROWNUM rec_num,
       CASE
         WHEN ins.pkg_policy_checks.check_addendum_type(a.policy_id, 'FIN_WEEK') = 1 THEN
          'Финансовые каникулы'
         ELSE
          'Зачет'
       END type_operation
      ,decode(ig.life_property, 1, 'Ж', 0, 'НС') ig_type
       ,a.ids
       ,a.pol_num
       ,a.notice_ser
       ,a.notice_num
       ,a.prod_name
       ,plo.description plo_description
       ,pc.p_cover_id
       ,plo.id plo_od
       ,a.region_name
       ,a.region_code
       ,a.holder_name
       ,a.holder_id
       ,(SELECT decode(tpc.description
                     ,'Физическое лицо'
                     ,tpc.description
                     ,'Юридическое лицо')
          FROM ins.ven_contact    c
              ,ins.t_contact_type tpc
         WHERE c.contact_id = a.holder_id
           AND c.contact_type_id = tpc.id) type_holder
       ,(SELECT decode(nvl(c.resident_flag, 0), 0, 'Нерезидент', 1, 'Резидент', '')
          FROM ins.ven_contact c
         WHERE c.contact_id = a.holder_id) rezident
       ,(SELECT cca.country_name
          FROM ins.v_cn_contact_address cca
         WHERE cca.contact_id = a.holder_id
           AND ins.pkg_contact.get_primary_address(a.holder_id) = cca.id(+)) country_holder
       ,a.agent_name
       ,a.brief_cur
       ,pc.ins_amount
       ,TO_CHAR(a.ph_start_date,'dd.mm.yyyy') ph_start_date
       ,TO_CHAR(a.ph_end_date,'dd.mm.yyyy') ph_end_date
       ,TO_CHAR(pc.start_date,'dd.mm.yyyy') pc_start_date
       ,TO_CHAR(pc.end_date,'dd.mm.yyyy') pc_end_date
       ,pc.fee
       ,pc.premium
       ,a.payment_period
       ,a.db
       ,ADD_MONTHS(a.db, 12 / a.number_of_payments) dg
       ,a.ppo
       ,a.po
       ,(SELECT MAX(ap.amount)
          FROM ins.p_policy   p2
              ,ins.doc_doc    dd
              ,ins.document   d
              ,ins.doc_templ  dt
              ,ins.ac_payment ap
         WHERE p2.pol_header_id = a.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
           AND ap.plan_date = a.db) epg_amount_db
       ,(SELECT SUM(t.acc_amount)
          FROM ins.oper    o
              ,ins.trans   t
              ,ins.account a
         WHERE 1 = 1
           AND o.oper_id = t.oper_id
           AND t.ct_account_id = a.account_id
           AND a.num = '92.01'
           AND t.trans_amount > 0
           AND t.a4_ct_uro_id = plo.id
           AND t.a3_ct_uro_id = aa.p_asset_header_id) charge_amount_rur
       ,(SELECT SUM(t.acc_amount)
          FROM ins.oper    o
              ,ins.trans   t
              ,ins.account a
         WHERE 1 = 1
           AND o.oper_id = t.oper_id
           AND t.ct_account_id = a.account_id
           AND a.num = '92.01'
           AND t.trans_amount < 0
           AND t.a4_ct_uro_id = plo.id
           AND t.a3_ct_uro_id = aa.p_asset_header_id) storno_charge_amount_rur
       ,(SELECT SUM(t.acc_amount)
           FROM ins.trans       t
               ,ins.oper        o
               ,ins.doc_set_off dso
               ,ins.document    d
               ,ins.doc_templ   dt
               ,ins.trans_templ tt
               ,ins.p_cover     pc1
               ,ins.as_asset    a1
          WHERE
         
          tt.trans_templ_id = t.trans_templ_id
       AND o.oper_id = t.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND t.obj_ure_id = 305
       AND t.obj_uro_id = pc1.p_cover_id
       AND pc1.as_asset_id = a1.as_asset_id
       AND pc1.t_prod_line_option_id = plo.id
       AND a1.p_asset_header_id = aa.p_asset_header_id
       AND dso.child_doc_id = d.document_id
       AND dt.doc_templ_id = d.doc_templ_id
       AND t.acc_amount > 0
       AND ((tt.brief IN ('СтраховаяПремияОплачена'
                        ,'ЗачВзнСтрАг'
                        ,'ПремияОплаченаПоср'
                        ,'СтраховаяПремияАвансОпл') AND dt.brief IN ('ПП', 'ПП_ОБ', 'ПП_ПС')) OR
          (tt.brief IN ('СтраховаяПремияАвансОпл', 'УдержКВ') --Убыток и выплата КВ
          AND dt.brief IN ('PAYORDER_SETOFF', 'ЗачетУ_КВ')))) payd_amount_rur
       ,
       (SELECT SUM(t.acc_amount)
           FROM ins.trans       t
               ,ins.oper        o
               ,ins.doc_set_off dso
               ,ins.document    d
               ,ins.doc_templ   dt
               ,ins.trans_templ tt
               ,ins.p_cover     pc1
               ,ins.as_asset    a1
          WHERE
         
          tt.trans_templ_id = t.trans_templ_id
       AND o.oper_id = t.oper_id
       AND o.document_id = dso.doc_set_off_id
       AND t.obj_ure_id = 305
       AND t.obj_uro_id = pc1.p_cover_id
       AND pc1.as_asset_id = a1.as_asset_id
       AND pc1.t_prod_line_option_id = plo.id
       AND a1.p_asset_header_id = aa.p_asset_header_id
       AND dso.child_doc_id = d.document_id
       AND dt.doc_templ_id = d.doc_templ_id
       AND t.acc_amount < 0
       AND ((tt.brief IN ('СтраховаяПремияОплачена'
                        ,'ЗачВзнСтрАг'
                        ,'ПремияОплаченаПоср'
                        ,'СтраховаяПремияАвансОпл') AND dt.brief IN ('ПП', 'ПП_ОБ', 'ПП_ПС')) OR
          (tt.brief IN ('СтраховаяПремияАвансОпл', 'УдержКВ') --Убыток и выплата КВ
          AND dt.brief IN ('PAYORDER_SETOFF', 'ЗачетУ_КВ')))) storno_payd_amount_rur
       ,a.state_policy
       ,(CASE
            WHEN shp.brief = 'DELETED' THEN
             (SELECT pca.fee
             FROM ins.p_policy pp
                 ,ins.as_asset ap
                 ,ins.p_cover  pca
                 ,ins.document d_prev
                 ,ins.doc_status_ref rf_prev
            WHERE pp.policy_id = ap.p_policy_id
              AND ap.as_asset_id = pca.as_asset_id
              AND pp.policy_id = a.prev_ver_id
              AND pc.t_prod_line_option_id = pca.t_prod_line_option_id
              AND pp.policy_id = d_prev.document_id
              AND d_prev.doc_status_ref_id = rf_prev.doc_status_ref_id
              AND rf_prev.brief != 'CANCEL'
           )
            ELSE
             (SELECT pca.fee - pc.fee
             FROM ins.p_policy pp
                 ,ins.as_asset ap
                 ,ins.p_cover  pca
                 ,ins.document d_prev
                 ,ins.doc_status_ref rf_prev
            WHERE pp.policy_id = ap.p_policy_id
              AND ap.as_asset_id = pca.as_asset_id
              AND pp.policy_id = a.prev_ver_id
              AND pc.t_prod_line_option_id = pca.t_prod_line_option_id
              AND pp.policy_id = d_prev.document_id
              AND d_prev.doc_status_ref_id = rf_prev.doc_status_ref_id
              AND rf_prev.brief != 'CANCEL'
            )
        END) return_part_of_sum
	   ,(CASE
          WHEN shp.brief = 'DELETED' THEN
           ins.pkg_payment.get_part_of_return_sum(pc.p_cover_id)
		  ELSE
           ins.pkg_payment.get_part_of_return_sum(pc.p_cover_id) - pc.fee
        END) return_sum
       ,CASE
          WHEN ins.pkg_policy_checks.check_addendum_type(a.policy_id, 'FIN_WEEK') = 0 THEN
          (CASE WHEN ig.life_property = 1 THEN (NVL(pc.fee,0) - ins.pkg_payment.get_as_eps(pc.p_cover_id)) ELSE ((NVL(pc.fee,0) * a.number_of_payments) - ins.pkg_payment.get_as_iy(pc.p_cover_id)) END)
        ELSE
          (CASE WHEN ig.life_property = 1 THEN NVL(ins.pkg_payment.get_as_eps(pc.p_cover_id),0) ELSE (CASE WHEN a.is_one_finance_year = 1 THEN ins.pkg_payment.get_ps_iy(pc.p_cover_id) - ins.pkg_payment.get_as_iy(pc.p_cover_id) ELSE 0 END) END)
        END AS account_92
       ,CASE
          WHEN ins.pkg_policy_checks.check_addendum_type(a.policy_id, 'FIN_WEEK') = 0 THEN
          0
        ELSE
         (CASE WHEN ig.life_property = 1 THEN 0 ELSE (CASE WHEN a.is_one_finance_year != 1 THEN (ins.pkg_payment.get_ps_iy(pc.p_cover_id) - ins.pkg_payment.get_as_iy(pc.p_cover_id)) ELSE 0 END) END)
        END AS account_91
       ,TO_CHAR(SYSDATE,'dd.mm.yyyy') act_date
       ,TO_CHAR(SYSDATE,'dd.mm.yyyy') pay_date
       ,'Дополнительное соглашение к договору страхования' reason_termination
       ,a.view_termination
       ,CASE
         WHEN ins.pkg_policy_checks.check_addendum_type(a.policy_id, 'FIN_WEEK') = 0 THEN
          a.ids
         ELSE
          ''
       END this_ids
       ,(SELECT c.obj_name_orig FROM ins.contact c WHERE c.contact_id = ass.assured_contact_id) insured_name
       ,(SELECT c.contact_id FROM ins.contact c WHERE c.contact_id = ass.assured_contact_id) insured_id
       ,a.cr_prod_name
       ,ll.description group_risk_name
       ,policy_header_id
       ,policy_id
       ,CASE
         WHEN shp.brief = 'DELETED' THEN
          'Исключение покрытия'
         ELSE
          'Уменьшение взноса'
       END type_change
       ,TO_CHAR(a.ds_start_date,'dd.mm.yyyy') ds_start_date
  FROM (SELECT to_char(ph.ids) ids
               ,ph.policy_header_id
               ,p.policy_id
               ,(SELECT MIN(ins.doc.get_doc_status_brief(ab.payment_id))
                  FROM ins.document   db
                      ,ins.ac_payment ab
                      ,ins.doc_templ  dtb
                      ,ins.doc_doc    ddb
                 WHERE db.document_id = ab.payment_id
                   AND db.doc_templ_id = dtb.doc_templ_id
                   AND dtb.brief IN
                       ('PAYORDBACK', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
                   AND ddb.child_id = db.document_id
                   AND ddb.parent_id = p.policy_id
                   AND ins.doc.get_doc_status_brief(ab.payment_id) <> 'ANNULATED') min_back_stat
               ,p.pol_num
               ,p.notice_ser
               ,p.notice_num
               ,tp.description prod_name
               ,nvl(depph.name
                  ,(SELECT depa.name
                     FROM ins.p_pol_header       pha
                         ,ins.p_policy_agent_doc pad
                         ,ins.ag_contract_header ach
                         ,ins.ag_contract        ag
                         ,ins.department         depa
                    WHERE pha.policy_header_id = ph.policy_header_id
                      AND pha.policy_header_id = pad.policy_header_id
                      AND pad.ag_contract_header_id = ach.ag_contract_header_id
                      AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                      AND ag.contract_id = ach.ag_contract_header_id
                      AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
                      AND nvl(ach.is_new, 0) = 1
                      AND ag.agency_id = depa.department_id)) region_name
               ,CASE
                 WHEN nvl(depph.name, 'X') = 'X' THEN
                  (SELECT to_char(depa.department_code)
                     FROM ins.p_pol_header       pha
                         ,ins.p_policy_agent_doc pad
                         ,ins.ag_contract_header ach
                         ,ins.ag_contract        ag
                         ,ins.department         depa
                    WHERE pha.policy_header_id = ph.policy_header_id
                      AND pha.policy_header_id = pad.policy_header_id
                      AND pad.ag_contract_header_id = ach.ag_contract_header_id
                      AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                      AND ag.contract_id = ach.ag_contract_header_id
                      AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
                      AND nvl(ach.is_new, 0) = 1
                      AND ag.agency_id = depa.department_id)
                 ELSE
                  substr(tpr.ocatd, 1, 2)
               END region_code
               ,ins.pkg_policy.get_policy_contact(p.policy_id, 'Страхователь') holder_id
               ,ins.ent.obj_name('CONTACT'
                               ,ins.pkg_policy.get_policy_contact(p.policy_id
                                                                 ,'Страхователь')) holder_name
               ,(SELECT cag.obj_name_orig
                  FROM ins.p_pol_header       pha
                      ,ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.contact            cag
                 WHERE pha.policy_header_id = ph.policy_header_id
                   AND pha.policy_header_id = pad.policy_header_id
                   AND pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND nvl(ach.is_new, 0) = 1
                   AND ach.agent_id = cag.contact_id) agent_name
               ,f.brief brief_cur
               ,ph.start_date ph_start_date
			   ,p.start_date pol_start_date
               ,p.end_date ph_end_date
               ,tpt.description payment_period
               ,tpt.number_of_payments
               ,(SELECT MAX(ap.plan_date)
                  FROM ins.p_policy   p2
                      ,ins.doc_doc    dd
                      ,ins.document   d
                      ,ins.doc_templ  dt
                      ,ins.ac_payment ap
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = d.document_id
                   AND ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID') db
               ,(SELECT SUM(ap.amount)
                  FROM ins.p_policy   p2
                      ,ins.doc_doc    dd
                      ,ins.document   d
                      ,ins.doc_templ  dt
                      ,ins.ac_payment ap
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = d.document_id
                   AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                   AND ap.plan_date <= pgkr.decline_date) ppo
               ,(SELECT SUM(ins.pkg_payment.get_set_off_amount(ap.payment_id, ph.policy_header_id, NULL))
                  FROM ins.p_policy   p2
                      ,ins.doc_doc    dd
                      ,ins.document   d
                      ,ins.doc_templ  dt
                      ,ins.ac_payment ap
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = d.document_id
                   AND ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
                   AND ap.plan_date <= pgkr.decline_date) po
               ,(SELECT SUM(dd.parent_amount -
                           ins.pkg_payment.get_set_off_amount(ap.payment_id, ph.policy_header_id, NULL))
                  FROM ins.p_policy   p2
                      ,ins.doc_doc    dd
                      ,ins.document   d
                      ,ins.doc_templ  dt
                      ,ins.ac_payment ap
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = d.document_id
                   AND ap.plan_date <= pgkr.decline_date) size_overpayment
               ,to_char(pgkr.decline_date, 'dd.mm.yyyy') date_termination
               ,tdr.name reason_termination
               ,'Изменение условий' view_termination
               ,ins.doc.get_doc_status_name(pgkr.policy_id) state_policy
               ,decode(ins.doc.get_doc_status_name(pgkr.policy_id)
                     ,'К прекращению'
                     ,1
                     ,'К прекращению. Готов для проверки'
                     ,1
                     ,'К прекращению. Проверен'
                     ,1
                     ,'Прекращен'
                     ,1
                     ,0) is_to_quit
               ,decode(ins.doc.get_doc_status_name(pgkr.policy_id)
                     ,'К прекращению'
                     ,1
                     ,'К прекращению. Готов для проверки'
                     ,1
                     ,'К прекращению. Проверен'
                     ,1
                     ,'Прекращен'
                     ,1
                     ,'Прекращен.К выплате'
                     ,1
                     ,'Прекращен. Запрос реквизитов'
                     ,1
                     ,'Прекращен. Реквизиты получены'
                     ,1
                     ,0) show_date
               ,p.version_num
               ,(SELECT pas.policy_id
                  FROM ins.p_policy pas
                 WHERE pas.pol_header_id = ph.policy_header_id
                   AND pas.version_num = pgkr.version_num - 1) past_policy_id
               ,p.is_group_flag
               ,pgkr.return_summ
               ,cr_prod.description cr_prod_name
               ,p.prev_ver_id
               ,(SELECT trunc(MIN(ds.start_date))
                  FROM ins.doc_status     ds
                      ,ins.doc_status_ref rf
                 WHERE ds.document_id = p.policy_id
                   AND ds.doc_status_ref_id = rf.doc_status_ref_id
                   AND rf.brief IN ('CONCLUDED', 'CURRENT')) ds_start_date
               ,(CASE WHEN TO_CHAR(p.start_date,'YYYY') = TO_CHAR((select MAX(po.start_date)
        															from ins.p_policy po
        															where po.pol_header_id = ph.policy_header_id
         																and po.start_date <= p.start_date
         																and po.policy_id != p.policy_id
        														  ),'YYYY') THEN 1 ELSE 0 END) is_one_finance_year
          FROM ins.p_policy p
              ,ins.p_pol_header ph
              ,ins.t_product tp
              ,(SELECT prod1.description
                      ,prod1.product_id
                  FROM ins.t_product prod1
                 WHERE prod1.brief LIKE '%CR%') cr_prod
              ,ins.department depph
              ,ins.t_province tpr
              ,ins.fund f
              ,ins.t_payment_terms tpt
              ,ins.p_policy pgkr
              ,ins.t_decline_reason tdr
              ,ins.t_decline_type tdt
        ,ins.notif_letter_rep nlr
         WHERE 1 = 1
           AND p.pol_header_id = ph.policy_header_id
           AND tp.product_id = ph.product_id
           AND tp.product_id = cr_prod.product_id(+)
           AND tpr.province_id(+) = p.region_id
           AND ph.agency_id = depph.department_id(+)
           AND f.fund_id = ph.fund_id
           AND tpt.id = p.payment_term_id
           AND pgkr.pol_header_id = ph.policy_header_id
           AND pgkr.policy_id = (SELECT MAX(ppl.policy_id)
                                   FROM ins.p_policy       ppl
                                       ,ins.document       d
                                       ,ins.doc_status_ref rf
                                  WHERE ppl.pol_header_id = ph.policy_header_id
                                    AND ppl.policy_id = d.document_id
                                    AND d.doc_status_ref_id = rf.doc_status_ref_id
                                    AND rf.brief != 'CANCEL')
           AND tdr.t_decline_reason_id(+) = pgkr.decline_reason_id
           AND tdt.t_decline_type_id(+) = pgkr.decline_type_id
           --AND p.policy_id IN (15093542)
       AND nlr.document_id = p.policy_id
          AND nlr.sessionid = :P_SID
       ) a
       ,ins.as_asset aa
       ,ins.as_assured ass
       ,ins.contact cas
       ,ins.status_hist sha
       ,ins.p_cover pc
       ,ins.status_hist shp
       ,ins.t_prod_line_option plo
       ,ins.t_product_line pl
       ,ins.t_product_line_type plt
       ,ins.t_lob_line ll
       ,ins.t_insurance_group ig
 WHERE aa.p_policy_id = a.policy_id
   AND sha.status_hist_id = aa.status_hist_id
   AND sha.brief != 'DELETED'
   AND pc.as_asset_id = aa.as_asset_id
   AND aa.as_asset_id = ass.as_assured_id(+)
   AND ass.assured_contact_id = cas.contact_id(+)
   AND shp.status_hist_id = pc.status_hist_id
   AND plo.id = pc.t_prod_line_option_id
   AND plo.product_line_id = pl.id
   AND pl.t_lob_line_id = ll.t_lob_line_id
   AND pl.product_line_type_id = plt.product_line_type_id
   AND ll.insurance_group_id = ig.t_insurance_group_id
   AND (exists (SELECT NULL
               FROM ins.p_policy pol,
                    ins.as_asset a,
                    ins.p_cover co,
                    ins.t_prod_line_option opt,
                    ins.t_product_line pla
                WHERE pol.pol_header_id = a.policy_header_id
                  AND a.p_policy_id = pol.policy_id
                  AND co.as_asset_id = a.as_asset_id
                  AND co.t_prod_line_option_id = opt.id
                  AND opt.product_line_id = pla.id
                  AND pla.id = pl.id
                  AND a.prev_ver_id = pol.policy_id
                  AND co.fee > pc.fee
              )
        OR
        (shp.brief = 'DELETED')
      )
) t
	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_num"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

select to_char(trunc(sysdate),'dd.mm.yyyy'),
	to_char(trunc(sysdate),'mm'),
       to_char(trunc(sysdate),'yyyy')
into :SYS_DATE, :P_MONTH, :P_YEAR
from dual;

select t.description
into :name_letter
from t_notification_type t
where t.t_notification_type_id = :NTID;

return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:???????;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	mso-rotate:0;}
.xl65
	{mso-style-parent:style0;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	border:.5pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-weight:700;}
.xl68
	{mso-style-parent:style0;
	vertical-align:middle;}
.xl69
	{mso-style-parent:style0;
	text-align:center;
	border:.5pt solid windowtext;}
.xl70
	{mso-style-parent:style0;
	font-weight:700;
	font-style:italic;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>????1</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>17</x:ActiveRow>
       <x:ActiveCol>6</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????2</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????3</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11955</x:WindowHeight>
  <x:WindowWidth>18975</x:WindowWidth>
  <x:WindowTopX>-615</x:WindowTopX>
  <x:WindowTopY>270</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
</xml><![endif]-->
</head>

<% 
  int rec_count_all = 0;
  int rec_count_current = 0;
  int p_number = 0;
  String pnum = request.getParameter("PNUMBER");
  DecimalFormat decimalPlaces = new DecimalFormat("0000");
%>
<rw:foreach id="fi0" src="group_count">
  <rw:getValue id="j_rec_count" src="rec_count"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>


<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;table-layout:fixed;width:557pt'>
 <col width=48 style='mso-width-source:userset;mso-width-alt:1755;width:36pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:3181;width:65pt'>
 <col width=61 style='mso-width-source:userset;mso-width-alt:2230;width:46pt'>
 <col width=84 style='mso-width-source:userset;mso-width-alt:3072;width:63pt'>
 <col width=164 style='mso-width-source:userset;mso-width-alt:5997;width:123pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=105 style='mso-width-source:userset;mso-width-alt:3840;width:79pt'>
  <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=73 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Список<br>
    <rw:field id="" src="name_letter"/> </td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=48 style='height:30.0pt;border-top:none;
  width:36pt'>Пп</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Тип операции</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Вид Страхования</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>POL_ID_Head</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ИДС</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№ полиса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Серия заявления</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№ заявления</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Название программы</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Риски по договору</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ID Покрытия</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Id Наименования Риска</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Регион</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Код региона</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страхователь</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ID контакта (Страхователь)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип Страхователя (Физ лицо / Юр лицо)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип Страхователя (Резидент/Нерезидент)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страна Проживания Страхователя</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Contractor № из Navision</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Получатель страхового возмещения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ID Контакта (Получатель страхового возмещения)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип получателя страхового возмещения (Физ лицо/Юр лицо)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип получателя страхового возмещения (Резидент/Нерезидент)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страна проживания получателя страхового возмещения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агент</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Валюта договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страховая сумма</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата начала ответственности</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата окончания ответственности</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Курс на отчетную дату (или дату оплаты)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма премии/взноса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Годовая премия</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Периодичность уплаты взносов</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма страхового взноса в пересчете на один день</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Кол-во дней страхования с даты расторжения до конца оплаченного периода</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Выкупная сумма в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Возврат части премии в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Доп. Инвест. Доход в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма к возврату в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Недоплата (ППУ) в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>админ.изд.  в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>переплата в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Стоимость МО в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>91 счет в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сторно 92 счета в валюте договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма НДФЛ (для нулевых актов)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата акта</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата выплаты</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Судебные расходы</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата расторжения/изменения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Причина расторжения/изменения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Причина расторжения для 2-С (Досрочное расторжение/Изменение условий)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Инициатор</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Год расторжения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Перенос оплаты в счет оплаты по другому договору (№ договора)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>POL_ID_Head (перенос оплаты, другой договор)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Перенос оплаты в счет оплаты по тому же договору (№ договора)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма 92 и 91 счета</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Признак договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Комментарии</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Общая Сумма Уплаченных Взносов</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Филиал</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Регион по ОКАТО</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Застрахованный</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Ид Контакта (Застрахованный)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Наим Банковского Продукта</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Наименование группы риска</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Признак наличия инвестиционной составляющей</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Признак наличия ренты/аннуитета</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата восстановления договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Тип изменения</td>
 </tr>
 
 <rw:foreach id="fi2" src="group_data">
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><%=++rec_count_current%></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="type_operation"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ig_type"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="policy_header_id"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ids"></rw:field></td>
  <td class=xl69 style='mso-number-format:"@";border-top:none;border-left:none'><rw:field id="" src="pol_num"></rw:field></td>
  <td class=xl69 style='mso-number-format:"@";border-top:none;border-left:none'><rw:field id="" src="notice_ser"></rw:field></td>
  <td class=xl69 style='mso-number-format:"@";border-top:none;border-left:none'><rw:field id="" src="notice_num"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="prod_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="plo_description"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="p_cover_id"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="plo_od"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="region_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="region_code"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="holder_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="holder_id"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="type_holder"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="rezident"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="country_holder"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="holder_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="holder_id"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="type_holder"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="rezident"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="country_holder"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="agent_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="brief_cur"></rw:field></td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="ins_amount"></rw:field></td>
  <td class=xl69 style='mso-number-format:"dd\/mm\/yyyy";border-top:none;border-left:none'><rw:field id="" src="ph_start_date"></rw:field></td>
  <td class=xl69 style='mso-number-format:"dd\/mm\/yyyy";border-top:none;border-left:none'><rw:field id="" src="ph_end_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="fee"></rw:field></td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="premium"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="payment_period"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="return_part_of_sum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="account_91"></rw:field></td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="account_92"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='mso-number-format:"dd\/mm\/yyyy";border-top:none;border-left:none'><rw:field id="" src="act_date"></rw:field></td>
  <td class=xl69 style='mso-number-format:"dd\/mm\/yyyy";border-top:none;border-left:none'><rw:field id="" src="pay_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='mso-number-format:"dd\/mm\/yyyy";border-top:none;border-left:none'><rw:field id="" src="ds_start_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="reason_termination"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="view_termination"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'>0</td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="this_ids"></rw:field> <rw:field id="" src="return_sum"></rw:field></td>
  <td class=xl69 style='mso-number-format:"0\.00";border-top:none;border-left:none'><rw:field id="" src="sum_91_92"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="insured_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="insured_id"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="cr_prod_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="group_risk_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="type_change"></rw:field></td>
 </tr>
 
 </rw:foreach>
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=73 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=73 class=xl71 style='height:15.0pt'>Всего: <%=rec_count_all%></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=73 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=73 class=xl71 style='height:15.0pt'>Передал:
  ____________________/______________________________________</td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=73 class=xl71 style='height:15.0pt'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=73 class=xl71 style='height:15.0pt'>Принял:
  _____________________/______________________________________</td>
 </tr>
 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=73 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=48 style='width:36pt'></td>
  <td width=82 style='width:62pt'></td>
  <td width=87 style='width:65pt'></td>
  <td width=61 style='width:46pt'></td>
  <td width=84 style='width:63pt'></td>
  <td width=164 style='width:123pt'></td>
  <td width=110 style='width:83pt'></td>
  <td width=105 style='width:79pt'></td>
 </tr>
 <![endif]>
</table>

</body>

</html>


</rw:report>

CREATE OR REPLACE VIEW INS_DWH.V_TRANS_REP AS
SELECT ph.policy_header_id AS pol_header_id
       ,/* 'о' */NULL AS "Тип"
       ,t.risk_type_id
       ,t.trans_id
       ,t.trans_templ_id
       ,tt.name "Шаблон проводки"
       ,trunc(t.trans_date, 'dd') AS trans_date
       ,trunc(t.trans_doc_date, 'dd') AS trans_doc_date
       ,trunc(coalesce((SELECT max(ap1.due_date)
          FROM ins.doc_doc     dd
              ,ins.doc_set_off dso
              ,ins.ac_payment  ap1
         WHERE dd.parent_id = d.payment_id
           AND dd.child_id = dso.parent_doc_id
           AND dso.child_doc_id = ap1.payment_id), d.due_date, t.trans_doc_date), 'dd') AS trans_doc_date_2
       ,trunc(t.trans_reg_date, 'dd') trans_reg_date
       ,t.rur_amount
       ,CASE
         WHEN ph.fund_id <> 122
              AND t.doc_fund = 'RUR' THEN
          ROUND(t.doc_amount /
                decode(ins.pkg_readonly.get_rate_by_id(1, ph.fund_id, t.trans_date)
                      ,0
                      ,1
                      ,ins.pkg_readonly.get_rate_by_id(1, ph.fund_id, t.trans_date)),2)
         ELSE
          t.doc_amount
       END doc_amount
       ,t.doc_fund
       ,'Borlas' borlas
       ,t.p_cover_id
       ,t.dt_num
       ,t.ct_num
       ,dt.brief
       ,ae.assured_contact_id insurer_id
  FROM ins_dwh.fc_trans   t
      ,ins.p_pol_header   ph
      ,ins.doc_set_off    dso
      ,ins.ven_ac_payment d
      ,ins.doc_templ      dt
      ,ins.trans_templ    tt
      ,ins.p_cover        c
      ,ins.as_assured     ae
      ,ins.p_policy       pp
 WHERE tt.trans_templ_id = t.trans_templ_id
   AND ph.policy_header_id = t.pol_header_id
   AND pp.policy_id = ph.policy_id
   AND pp.is_group_flag = 0
	 -- Информация о зачитывающем документе
   AND t.document_id = dso.doc_set_off_id(+)
   AND dso.child_doc_id = d.payment_id(+)
   AND d.doc_templ_id = dt.doc_templ_id(+)
      /* AND tt.brief IN ('СтраховаяПремияОплачена'
      ,'ЗачВзнСтрАг'
      ,'ПремияОплаченаПоср'
      ,'СтраховаяПремияАвансОпл'
      ,'УдержКВ')*/
   AND t.trans_date BETWEEN ins_dwh.pkg_reserves_vs_profit.get_trans_begin_date AND
       ins_dwh.pkg_reserves_vs_profit.get_trans_end_date -- date '2013-01-01' and date '2013-01-31'
   -- получение ИД контакта застрахованного
   AND t.p_cover_id = c.p_cover_id(+)
   AND c.as_asset_id = ae.as_assured_id (+)
;

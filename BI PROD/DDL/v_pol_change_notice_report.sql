create or replace  view V_POL_CHANGE_NOTICE_REPORT as
SELECT
/*
Отчет по поступившим Заявлениям
2.2.2015 Черных М.
*/
 rownum row_num
,dt.name decline_type_name
,pph.ids
,pp.pol_num
,c.obj_name_orig issurer_name
,tp.description
,pph.start_date
,trunc(ii.reg_date) reg_date
,dr.name decline_reason_name
,trunc(greatest(ii.reg_date, cn.policy_decline_date)) + 20 due_date
,CASE
   WHEN cn.is_to_set_off = 1 THEN
    'Зачет'
   WHEN (SELECT COUNT(1)
           FROM cn_contact_bank_acc  t
               ,cn_document_bank_acc dacc
               ,document             d
               ,doc_status_ref       dsr
          WHERE t.contact_id = c.contact_id
            AND dacc.cn_contact_bank_acc_id = t.id
            AND dacc.cn_document_bank_acc_id = d.document_id
            AND d.doc_status_ref_id = dsr.doc_status_ref_id
            AND dsr.brief = 'ACTIVE') > 0 THEN
    'Есть'
   ELSE
    'Нет'
 END requisites
,CASE
   WHEN doc.get_last_doc_status_brief(pph.max_uncancelled_policy_id) IN
        ('TO_QUIT', 'TO_QUIT_CHECK_READY', 'TO_QUIT_CHECKED', 'QUIT_TO_PAY', 'QUIT_REQ_QUERY', 'QUIT') THEN
    pp.return_summ
   ELSE
    to_number(NULL)
 END return_summ /*Итого к выплате*/
,f.name fund_name
,doc.get_last_doc_status_name(pph.max_uncancelled_policy_id) max_uncancelled_status
,(SELECT SUM(cd.add_invest_income)
  FROM p_pol_decline   pd
      ,p_cover_decline cd
 WHERE pd.p_policy_id = pp.policy_id
   AND pd.p_pol_decline_id = cd.p_cover_decline_id) did_summ /*Сумма ДИД на дату расторжения */
,doc.get_last_doc_status_name(cn.p_pol_change_notice_id) notice_status
,ii.note
,doc.get_last_doc_status_date(cn.p_pol_change_notice_id) notice_status_date /*Дата статуса заявления*/
,CASE
   WHEN doc.get_last_doc_status_brief(pph.max_uncancelled_policy_id) IN
        ('TO_QUIT', 'TO_QUIT_CHECK_READY', 'TO_QUIT_CHECKED', 'QUIT_TO_PAY', 'QUIT_REQ_QUERY', 'QUIT') THEN
    (SELECT pd.issuer_return_date FROM p_pol_decline pd WHERE pd.p_policy_id = pp.policy_id)
   ELSE
    to_date(NULL)
 END return_date /*Дата выплаты*/
,to_number(NULL) request_number /*Номер реквеста*/
,(SELECT ds.user_name
    FROM document   d
        ,doc_status ds
   WHERE d.document_id = cn.p_pol_change_notice_id
     AND d.doc_status_id = ds.doc_status_id) user_name /*Исполнитель*/
,sc.description sales_chanel_descr /*Канал продаж*/
,trunc(greatest(cn.notice_date, cn.policy_decline_date)) + 15 search_date /*Дата для поиска по "сроку исполнения"*/
  FROM p_pol_change_notice cn
      ,inoutput_info       ii
      ,p_policy            pp
      ,p_pol_header        pph
      ,t_decline_reason    dr
      ,t_decline_type      dt
      ,t_sales_channel     sc
      ,t_product           tp
      ,p_policy_contact    pc
      ,t_contact_pol_role  cpr
      ,contact             c
      ,fund                f
 WHERE cn.inoutput_info_id = ii.inoutput_info_id
   AND cn.policy_header_id = pph.policy_header_id
   AND cn.t_decline_reason_id = dr.t_decline_reason_id
   AND pph.policy_id = pp.policy_id
   AND dr.t_decline_type_id = dt.t_decline_type_id
   AND pph.sales_channel_id = sc.id
   AND pph.product_id = tp.product_id
   AND pp.policy_id = pc.policy_id
   AND pc.contact_policy_role_id = cpr.id
   AND cpr.brief = 'Страхователь'
   AND pc.contact_id = c.contact_id
   AND pph.fund_id = f.fund_id;
   
grant select on V_POL_CHANGE_NOTICE_REPORT to INS_EUL;   

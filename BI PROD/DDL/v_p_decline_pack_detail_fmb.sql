create or replace view v_p_decline_pack_detail_fmb as
SELECT
/*
Детализация по пакетам обработки (используется в форму "Журнал обработки прекращений")
Черных М. 23.1.2015
*/
 pd.p_decline_pack_detail_id
,pd.p_decline_pack_id
,pd.p_policy_id
,(SELECT pph.ids
    FROM p_pol_header pph
        ,p_policy     pp
   WHERE pph.policy_header_id = pp.pol_header_id
     AND pp.policy_id = pd.p_policy_id) ids
,(SELECT vi.contact_name FROM v_pol_issuer vi WHERE vi.policy_id = pd.p_policy_id) issurer_name
,pd.process_date
,pd.result
,decode(pd.result
       ,0
       ,'новый'
       ,1
       ,'успешно обработан'
       ,2
       ,'обработан с ошибкой') result_name
,pd.doc_status_id
,(SELECT dsr.name
    FROM doc_status     ds
        ,doc_status_ref dsr
   WHERE ds.doc_status_id = pd.doc_status_id
     AND dsr.doc_status_ref_id = ds.doc_status_ref_id) doc_status_name
,(SELECT tp.is_handchange
    FROM t_policyform_product tp
        ,p_policy             pp
   WHERE pp.policy_id = pd.p_policy_id
     AND pp.t_product_conds_id = tp.t_policyform_product_id) is_handchange
,pd.commentary
,pd.p_pol_change_notice_id
  FROM p_decline_pack_detail pd;

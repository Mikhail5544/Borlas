CREATE OR REPLACE VIEW V_KTU_INDEX AS
SELECT sch.description   "Канал продаж"
      ,sch.descr_for_rep "Канал продаж отч"
      ,pr.description    "Продукт"
      ,decode(pr.brief
               ,'GN'
               ,CASE
                  WHEN pkg_policy.get_pol_sales_chn(ph.policy_header_id, 'brief') = 'BANK' THEN
                   'Group Credit life'
                  WHEN 1 = (SELECT COUNT(1)
                              FROM dual
                             WHERE EXISTS
                             (SELECT NULL
                                      FROM ins.p_pol_header       phh
                                          ,ins.as_asset           aa
                                          ,ins.p_cover            pc
                                          ,ins.t_prod_line_option plo
                                          ,ins.t_product_line     pl
                                          ,ins.t_lob_line         ll
                                     WHERE phh.policy_id = aa.p_policy_id
                                       AND aa.as_asset_id = pc.as_asset_id
                                       AND pc.t_prod_line_option_id = plo.id
                                       AND plo.product_line_id = pl.id
                                       AND ll.t_lob_line_id = pl.t_lob_line_id
                                       AND phh.policy_header_id = ph.policy_header_id
                                       AND ll.description IN
                                           ('Программа №1 Смешанное страхование жизни'
                                           ,'Программа №4 Дожитие с возвратом взносов в случае смерти'))) THEN
                   'Group END'
                  ELSE
                   'Group Term/PA'
                END
               ,prg.name) "Линия бизнеса"
      ,dt.name           "Тип документа"
      ,ids
      ,ph.policy_header_id
      ,ds.start_date     "Создал когда"
      ,MAX(ds.start_date) OVER (PARTITION BY ph.policy_header_id) max_start_date
      ,pih.policy_index_header_id
      ,pih.num           "Номер журнала"
      ,pr.product_id
FROM ins.p_pol_header            ph
    ,ins.t_sales_channel         sch
    ,ins.t_product               pr
    ,ins.T_PRODUCT_GROUP         prg
    ,ins.ven_p_policy            pp
    ,ins.doc_templ               dt
    ,ins.policy_index_item       pit
    ,ins.ven_policy_index_header pih
    ,ins.doc_status              ds
    ,ins.doc_status_ref          dsr
WHERE ph.product_id              = pr.product_id
  AND pr.t_product_group_id      = prg.t_product_group_id
  AND sch.id                     = ph.sales_channel_id
  AND pp.pol_header_id           = ph.policy_header_id
  AND pit.policy_header_id       = ph.policy_header_id
  AND ph.policy_id               = pp.policy_id
  AND pit.policy_index_header_id = pih.policy_index_header_id
  AND pih.doc_templ_id           = dt.doc_templ_id
  AND dsr.doc_status_ref_id      = ds.doc_status_ref_id
  AND dsr.brief                  = 'PROJECT'
  AND trunc(ds.start_date)       BETWEEN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'start_date') 
                                     AND (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'end_date')
  AND ds.document_id             = pih.policy_index_header_id;

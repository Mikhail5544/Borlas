CREATE OR REPLACE VIEW V_KTU_GROUP AS
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
      ,CASE WHEN pp.version_num = 1 THEN 'Договор страхования'
         ELSE dt.name
       END "Тип документа"
      ,src_dsr.name "Статус"
      ,dsr.name "Тип измен"
      ,IDS
      ,ph.policy_header_id
      ,ds.start_date
      ,max(ds.start_date) over (partition by pp.policy_id) max_start_date
      ,pr.product_id
FROM ins.p_pol_header    ph
    ,ins.t_sales_channel sch
    ,ins.t_product       pr
    ,ins.t_product_group prg
    ,ins.ven_p_policy    pp
    ,ins.doc_templ       dt
    ,ins.doc_status      ds
    ,ins.doc_status_ref  dsr
    ,ins.doc_status_ref  src_dsr
WHERE ph.product_id            = pr.product_id
  AND pr.t_product_group_id    = prg.t_product_group_id(+)
  AND sch.id                   = ph.sales_channel_id
  AND pp.pol_header_id         = ph.policy_header_id
  AND pp.doc_templ_id          = dt.doc_templ_id
  AND pp.policy_id             = ds.document_id
  AND ds.doc_status_ref_id     = dsr.doc_status_ref_id
  AND ds.src_doc_status_ref_id = src_dsr.doc_status_ref_id
  AND trunc(ds.start_date)     BETWEEN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'start_date')
                                   AND (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'end_date')
  AND pr.description           = 'Универсальный продукт'
  AND dsr.name                 = 'Передано Агенту'
  AND dt.name                  = 'Дополнительное соглашение к договору страхования';

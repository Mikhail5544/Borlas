CREATE OR REPLACE VIEW V_KTU_POST_LETTERS AS
SELECT  DISTINCT
        ch.description       "Канал продаж"
       ,ch.descr_for_rep     "Канал продаж для отчетности"
       ,pr.description       "Продукт"
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
               ,pg.name) "Линия бизнеса для отчетности"
       ,'Почтовое сообщение' "Тип документа"
       ,ph.ids               "ИДС"
       ,trunc(ii.REG_DATE)   "Дата регистрации"
       ,ph.policy_header_id
  FROM inoutput_info     ii
      ,p_pol_header      ph
      ,t_sales_channel   ch
      ,t_product         pr
      ,T_PRODUCT_GROUP   pg
  WHERE trunc(ii.REG_DATE)  BETWEEN (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'start_date') 
                               AND (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ktu_reports' AND param_name = 'end_date')
   AND ph.policy_header_id = ii.pol_header_id
   AND ph.sales_channel_id = ch.id
   AND ph.product_id = pr.product_id
   AND pr.t_product_group_id = pg.t_product_group_id
   AND ii.t_message_type_id = 2 -- Почтовые сообщения
;

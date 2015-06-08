CREATE OR REPLACE VIEW V_KTU_AG_ROLL AS
SELECT ch.description "Канал продаж"
       ,ch.descr_for_rep "Канал продаж отч"
       ,prod.description "Продукт"
       ,decode(prod.brief
             ,'GN'
             ,CASE
                WHEN pkg_policy.get_pol_sales_chn(agv.policy_header_id,'brief') = 'BANK' THEN
                 'Group Credit life'
                WHEN 1 =
                     (SELECT COUNT(1)
                        FROM dual
                       WHERE EXISTS (SELECT NULL
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
             ,gr.name) "Линия бизнеса"
       ,rl.name "Тип документа"
       ,rl.date_begin "Дата начала"
       ,ph.ids "IDS"
       ,payd.num "Номер ЭПГ"
       ,tp.description "Тип Volume"
       ,plo.description "Риск"
       ,agv.epg_payment
       ,agv.policy_header_id
       ,prod.product_id
  FROM ins.ag_volume agv
      ,(SELECT rla.ag_roll_id
              ,ta.name
              ,arha.date_begin
          FROM ins.ag_roll        rla
              ,ins.ag_roll_header arha
              ,ins.ag_roll_type   ta
              ,ins.document       d
         WHERE rla.ag_roll_header_id = arha.ag_roll_header_id
           AND arha.ag_roll_type_id = ta.ag_roll_type_id
           AND trunc(arha.date_end) BETWEEN --to_date('01.01.2014','dd.mm.yyyy') and to_date('15.02.2015','dd.mm.yyyy')
               (SELECT param_value
                  FROM ins_dwh.rep_param
                 WHERE rep_name = 'ktu_reports'
                   AND param_name = 'start_date')
           AND (SELECT param_value
                  FROM ins_dwh.rep_param
                 WHERE rep_name = 'ktu_reports'
                   AND param_name = 'end_date')
           AND ta.brief = 'CASH_VOL'
           AND rla.ag_roll_id = d.document_id
           AND d.doc_status_ref_id = 62) rl
      ,ins.p_pol_header ph
      ,ins.t_product prod
      ,ins.t_sales_channel ch
      ,ins.t_product_group gr
      ,ins.ag_volume_type tp
      ,ins.document payd
      ,ins.t_prod_line_option plo
 WHERE agv.ag_roll_id = rl.ag_roll_id
   AND agv.policy_header_id = ph.policy_header_id
   AND ph.product_id = prod.product_id
   AND ph.sales_channel_id = ch.id
   AND prod.t_product_group_id = gr.t_product_group_id(+)
   AND agv.ag_volume_type_id = tp.ag_volume_type_id
   AND agv.epg_payment = payd.document_id
   AND agv.t_prod_line_option_id = plo.id
   AND tp.brief != 'INFO';

CREATE OR REPLACE VIEW V_KTU_PAYMENT_REG AS
SELECT /*+ FIRST_ROWS LEADING ac pri dso*/
DISTINCT sch.description "Канал продаж"
         ,sch.descr_for_rep "Канал продаж отч"
         ,pr.description "Продукт"
         ,decode(pr.brief
               ,'GN'
               ,CASE
                  WHEN pkg_policy.get_pol_sales_chn(epg.policy_header_id, 'brief') = 'BANK' THEN
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
                                       AND phh.policy_header_id = epg.policy_header_id
                                       AND ll.description IN
                                           ('Программа №1 Смешанное страхование жизни'
                                           ,'Программа №4 Дожитие с возвратом взносов в случае смерти'))) THEN
                   'Group END'
                  ELSE
                   'Group Term/PA'
                END
               ,prg.name) "Линия бизнеса"
         ,dt.name                      "Тип документа"
         ,pri.payment_register_item_id
         ,epg.policy_header_id
         ,epg.ids
         ,pr.product_id
  FROM ins.ven_ac_payment        ac
      ,ins.payment_register_item pri
      ,ins.doc_set_off           dso
      ,ins.doc_templ             dt
      ,ins.t_sales_channel       sch
      ,ins.t_product             pr
      ,ins.t_product_group       prg
       --Ветка когда реестр разнесен с ПП на ЭПГ
      ,(SELECT acp_epg.payment_id
              ,ph1.policy_header_id
              ,pp1.pol_ser
              ,pp1.pol_num
              ,ph1.ids
              ,pp1.is_group_flag
              ,ph1.start_date
              ,pp1.policy_id
              ,acp_epg.amount
              ,acp_epg.due_date
              ,acp_epg.payment_id AS payment_id2
              ,ph1.sales_channel_id
              ,ph1.product_id
          FROM ins.ac_payment   acp_epg
              ,ins.doc_doc      dd1
              ,ins.p_policy     pp1
              ,ins.p_pol_header ph1
         WHERE acp_epg.payment_id = dd1.child_id
           AND dd1.parent_id = pp1.policy_id
           AND pp1.pol_header_id = ph1.policy_header_id
        UNION ALL
        --Ветка когда реестр разнесен с ПП на копию А7/ПД4
        SELECT acp_a7.document_id
              ,ph2.policy_header_id
              ,pp2.pol_ser
              ,pp2.pol_num
              ,ph2.ids
              ,pp2.is_group_flag
              ,ph2.start_date
              ,pp2.policy_id
              ,epg2.amount
              ,epg2.due_date
              ,epg2.payment_id AS payment_id2
              ,ph2.sales_channel_id
              ,ph2.product_id
          FROM ins.document     acp_a7
              ,ins.doc_doc      dd2_1
              ,ins.doc_set_off  dso2
              ,ins.ac_payment   epg2
              ,ins.doc_doc      dd2
              ,ins.p_policy     pp2
              ,ins.p_pol_header ph2
         WHERE acp_a7.doc_templ_id IN (6432, 6533, 23095)
           AND acp_a7.document_id = dd2_1.child_id
           AND dd2_1.parent_id = dso2.child_doc_id
           AND dso2.parent_doc_id = epg2.payment_id
           AND epg2.payment_id = dd2.child_id
           AND dd2.parent_id = pp2.policy_id
           AND pp2.pol_header_id = ph2.policy_header_id) epg
 WHERE ac.doc_templ_id IN (86, 16174, 16176) --Платежное поручение входящее,Платежное поручение входящее (Прямое списание), Платежное поручение входящее (Перечислено плательщиком)
   AND ac.doc_templ_id = dt.doc_templ_id
   AND ac.payment_id = pri.ac_payment_id
   AND trunc(pri.recognize_data) BETWEEN
       (SELECT param_value
          FROM ins_dwh.rep_param
         WHERE rep_name = 'ktu_reports'
           AND param_name = 'start_date')
   AND (SELECT param_value
          FROM ins_dwh.rep_param
         WHERE rep_name = 'ktu_reports'
           AND param_name = 'end_date')
   AND pri.status = 40 --Разнесено
   AND pri.payment_register_item_id = dso.pay_registry_item(+)
   AND dso.parent_doc_id = epg.payment_id(+)
   AND epg.sales_channel_id = sch.id(+)
   AND epg.product_id = pr.product_id(+)
   AND pr.t_product_group_id = prg.t_product_group_id(+);

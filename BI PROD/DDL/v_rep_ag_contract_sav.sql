CREATE OR REPLACE VIEW V_REP_AG_CONTRACT_SAV AS
SELECT s.ag_contract_header_id
      ,sch.brief
      ,agh.num "Номер агента"
       ,c.obj_name_orig "ФИО агента"
       ,agh.date_begin "Дата начала АД"
       ,rf.name "Статус агента"
       ,prod.product_id "ИД продукта"
       ,prod.description "Продукт"
       ,s.t_ag_contract_sav_id "ИД Ставки"
       ,pl.id "ИД Риска"
       ,pl.description "Риск"
       ,s.product_line_order "Программа по приказу"
       ,s.name_product_line_order "Название программы по приказу"
       ,s.value_sav_order "САВ"
       ,s.note "Комментарии"
       ,s.start_date "Дата начала действия"
       ,s.end_date "Дата окончания действия"
       ,s.amount_from "Сумма с"
       ,s.amount_to "Сумма по"
       ,s.term_ins_from "Срок страхования от"
       ,s.term_ins_to "Срок страхования до"
       ,decode(s.paym_term, 0, 'Люб', 1, 'Един', 2, 'Период', 'Неизвестно') "Вид оплаты"
       ,decode(agh.with_retention
             ,0
             ,'Без удержания'
             ,1
             ,'С удержанием'
             ,'Неизвестно') "Удержание"
       ,decode(s.with_nds, 1, 'НДС вкл', 2, 'НДС не вкл', 'Неизвестно') "НДС в КВ"
       ,decode(s.is_action, 1, 'Действует', '') is_action
       ,s.pay_ins_from "Год оплаты от"
       ,s.pay_ins_to "Год оплаты до"
       ,agh.rko "РКО"
       ,agh.storage_ds "Хранение руб."
       ,(SELECT admin_num FROM ag_contract a WHERE a.ag_contract_id = agh.last_ver_id) "Административный номер"
       ,s.assured_age_from
       ,s.assured_age_to
       ,decode(agh.select_commission_by,0,'По дате оплаты Д/С',1,'По дате начала Д/С',agh.select_commission_by) commission_by
  FROM ins.ven_ag_contract_header agh
      ,ins.t_ag_contract_sav      s
      ,ins.t_product              prod
      ,ins.t_product_line         pl
      ,ins.contact                c
      ,ins.document               d
      ,ins.doc_status_ref         rf
      ,ins.t_sales_channel        sch
 WHERE agh.ag_contract_header_id = s.ag_contract_header_id(+)
   AND s.product_id = prod.product_id(+)
   AND s.product_line_id = pl.id(+)
   AND agh.agent_id = c.contact_id
   AND agh.ag_contract_header_id = d.document_id
   AND d.doc_status_ref_id = rf.doc_status_ref_id
   AND agh.t_sales_channel_id = sch.id
   AND ((sch.brief IN ('BANK', 'BR') AND s.ag_contract_header_id IS NULL) OR
       s.ag_contract_header_id IS NOT NULL);

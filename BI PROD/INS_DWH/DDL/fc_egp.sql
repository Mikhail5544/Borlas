CREATE OR REPLACE VIEW INS_DWH.FC_EGP AS
SELECT payment_id "ID ЭПГ"
       ,pol_header_id "ID Договора Страхования"
       ,e.coll_method "Тип расчетов"
       ,plan_date "Дата ЭПГ"
       ,e.due_date "Дата выставения"
       ,e.grace_date "Срок платежа"
       ,num "Номер ЭПГ"
       ,epg_status "Статус ЭПГ"
       ,first_epg "Признак 1ого ЭПГ"
       ,e.epg_amount_rur "Сумма ЭПГ р"
       ,e.epg_amount "Сумма ЭПГ"
       ,e.pay_date "Дата оплаты"
       ,e.set_of_amt_rur "Зачтенная по ЭПГ сумма р"
       ,e.set_of_amt "Зачтенная по ЭПГ сумма"
       ,e.hold_amt_rur "Удержанно в счет КВ р"
       ,e.hold_amt "Удержанная в счет КВ"
       ,e.agent_id "Id агента"
       ,e.agent_ad_id "Id аг договора"
       ,e.agent_stat "Статус агента"
       ,nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency) "Агентство аг."
       ,e.manager_id "Id менеджера"
       ,e.manager_ad_id "Id мнг договора"
       ,e.manager_stat "Статус менеджера"
       ,e.manager_agency "Агентство мен."
       ,e.dir_id "Id директора"
       ,e.dir_ad_id "Id дир договора"
       ,e.dir_stat "Статус директора"
       ,e.dir_agency "Агентство дир."
       ,e.addendum_type "Тип изменений"
       ,e.ape_amount_rur
       ,e.epg_num
       ,e.agent_agency_id
       ,e.index_fee
       ,e.index_fee_prop
       ,e.epg_amount_rur_acc
       ,e.epg_amount_acc
  FROM ins_dwh.t_fc_epg e;

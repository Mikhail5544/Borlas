CREATE OR REPLACE VIEW INS_DWH.FC_EGP AS
SELECT payment_id "ID ЭПГ",
       pol_header_id "ID Договора Страхования",
       e.coll_method "Тип расчетов",
       plan_date "Дата ЭПГ",
       e.due_date "Дата выставения",
       e.grace_date "Срок платежа",
       num "Номер ЭПГ",
       epg_status "Статус ЭПГ",
       first_epg "Признак 1ого ЭПГ",
       e.epg_amount_rur "Сумма ЭПГ р",
       e.epg_amount "Сумма ЭПГ",
       e.pay_date "Дата оплаты",
       e.set_of_amt_rur "Зачтенная по ЭПГ сумма р",
       e.set_of_amt "Зачтенная по ЭПГ сумма",
       e.hold_amt_rur "Удержанно в счет КВ р",
       e.hold_amt "Удержанная в счет КВ",
       e.agent_id "Id агента",
       e.agent_ad_id "Id аг договора",
       e.agent_stat "Статус агента",
       nvl(nvl(e.agent_agency, e.MANAGER_agency),e.DIR_agency) "Агентство аг.",
       e.MANAGER_id "Id менеджера",
       e.MANAGER_ad_id "Id мнг договора",
       e.MANAGER_stat "Статус менеджера",
       e.MANAGER_agency "Агентство мен.",
       e.DIR_id "Id директора",
       e.DIR_ad_id "Id дир договора",
       e.DIR_stat "Статус директора",
       e.DIR_agency "Агентство дир.",
       e.ape_amount_rur,
       e.epg_num,
       e.agent_agency_id,
       e.index_fee
  FROM ins_dwh.t_fc_epg e
/*DROP MATERIALIZED VIEW FC_EGP;

CREATE MATERIALIZED VIEW FC_EGP
REFRESH FORCE ON DEMAND
AS
SELECT payment_id "ID ЭПГ",
       pol_header_id "ID Договора Страхования",
       e.coll_method "Тип расчетов",
       plan_date "Дата ЭПГ",
       e.due_date "Дата выставения",
       e.grace_date "Срок платежа",
       num "Номер ЭПГ",
       epg_status "Статус ЭПГ",
       first_epg "Признак 1ого ЭПГ",
       e.epg_amount_rur "Сумма ЭПГ р",
       e.epg_amount "Сумма ЭПГ",
       e.pay_date "Дата оплаты",
       e.set_of_amt_rur "Зачтенная по ЭПГ сумма р",
       e.set_of_amt "Зачтенная по ЭПГ сумма",
       e.hold_amt_rur "Удержанно в счет КВ р",
       e.hold_amt "Удержанная в счет КВ",
       e.agent_id "Id агента",
       e.agent_ad_id "Id аг договора",
       e.agent_stat "Статус агента",
       e.agent_agency "Агентство аг.",
       e.MANAGER_id "Id менеджера",
       e.MANAGER_ad_id "Id мнг договора",
       e.MANAGER_stat "Статус менеджера",
       e.MANAGER_agency "Агентство мен.",
       e.DIR_id "Id директора",
       e.DIR_ad_id "Id дир договора",
       e.DIR_stat "Статус директора",
       e.DIR_agency "Агентство дир.",
       e.epg_num
  FROM ins.v_epg_fact_preview e

begin
dbms_stats.gather_table_stats(
    'INS_DWH', 'fc_egp',
    degree => 1,
    CASCADE => TRUE
  );
end;*/;

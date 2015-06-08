CREATE MATERIALIZED VIEW INS_DWH.FC_AGENT_COMMISS
REFRESH FORCE ON DEMAND
AS
SELECT pol_header "ID Договора страхования",
       com_epg "ЭПГ с начисленой комиссией",
       date_from "Дата С",
       fee "Брутто взнос по 1ой",
       adm_cost "Издержки по 1ой",
       pay_term "Переодичность по 1ой",
       f_date "Дата оплаты 1ого ЭПГ",
       f_pay "Сумма оплаты 1ого ЭПГ",
       sale_ad "ID продавшего АД",
       cat_ad "Категрия продавшего",
       stat_ad "Статус продавшего",
       mng_ad "ID руководителя",
       FIO_MNG "ФИО руководителя",
       AD_NUM_MNG "АД руководителя",
       CAT_MNG "Категория руководителя",
       STAT_MNG "Статус руководителя",
       GET_AD "ID получившего АД",
       FIO_GET "ФИО получившего",
       AD_NUM_GET "АД получившего",
       GET_AGENCY "Агентство получившего",
       CAT_GET "Категрия получившего",
       STAT_GET "Статус получившего",
       MONTH_NUM "Месяц менеджер",
       TYPE_AV "Тип АВ",
       CALC_DATE "Дата расчета АВ",
       CALC_PER "Отчетный период",
       SUB_TYPE_AV "Вид АВ",
       COM_SUMm "Сумма комиссии"
  FROM ins.v_commis_fact_preview_oav a
 WHERE 1!=1
UNION ALL
SELECT * FROM ins.v_commis_fact_preview_dav
WHERE 1!=1
UNION ALL
SELECT * FROM ins.v_commis_fact_preview_prem
WHERE 1!=1;


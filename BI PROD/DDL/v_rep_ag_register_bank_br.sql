CREATE OR REPLACE VIEW  v_rep_ag_register_bank_br AS
SELECT DISTINCT ag.agent_name "Наименование Агента"
                ,ag.NUM "Номер САД"
                ,ag.admin_num "Номер Агентского договора"
                ,last_value(ag.leg_pos) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "Юридический статус"
                ,last_value(ag.NAME) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "Агентство"
                ,ag.DATE_BEGIN "Дата начала действия АД"
                ,last_value(ag.DESCRIPTION) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "Канал продаж"
                ,ins.doc.get_last_doc_status_name(ag.ag_contract_header_id) "Статус Агентского договора"
                ,agd.doc_status "Статус д-а <Заключение АД>"
  FROM ins.v_agn_contract  ag
      ,ins.V_AGN_DOCUMENTS agd
 WHERE agd.ag_contract_header_id = ag.ag_contract_header_id
   AND agd.doc_desc = 'Заключение АД'
   AND ag.DESCRIPTION IN ('Банковский'
                         ,'Брокерский'
                         ,'Корпоративный'
                         ,'Прямой'
                         ,'Брокерский без скидки'
                         ,'Департамент Прямых Продаж'
                         ,'НПФ партнеры'
                         ,'Канал Прямых Продаж')
--and num='45048'

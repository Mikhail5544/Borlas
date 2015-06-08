CREATE OR REPLACE VIEW V_REP_CRM_INPUT_CALLS AS
SELECT ii.inoutput_info_id
      ,mt.message_type_name                                "Тип обращения"
      ,mk.message_kind_name                                "Вид обращения"
      ,ct.name                                             "Тип клиента"
      ,d.name                                              "Подразделение"
      ,ii.user_name_loaded                                 "Оператор создал"
      ,to_date(to_char(ii.reg_date, 'dd.mm.yyyy hh24:mi:ss'), 'dd.mm.yyyy hh24:mi:ss')       "Дата создания"
      ,to_date(to_char(ii.date_call_end, 'dd.mm.yyyy hh24:mi:ss'), 'dd.mm.yyyy hh24:mi:ss')  "Дата закрытия"
      ,ceil((EXTRACT( DAY    FROM (ii.date_call_end - ii.date_call_start) ) *24*60*60
     + EXTRACT( HOUR   FROM (ii.date_call_end - ii.date_call_start) ) *60*60
     + EXTRACT( MINUTE FROM (ii.date_call_end - ii.date_call_start) ) *60
     + EXTRACT( SECOND FROM (ii.date_call_end - ii.date_call_start) )) / 60)  "Время звонка"
      ,ceil((EXTRACT( DAY    FROM (ii.date_reg_end - ii.reg_date) ) *24*60*60
     + EXTRACT( HOUR   FROM (ii.date_reg_end - ii.reg_date) ) *60*60
     + EXTRACT( MINUTE FROM (ii.date_reg_end - ii.reg_date) ) *60
     + EXTRACT( SECOND FROM (ii.date_reg_end - ii.reg_date) )) / 60)  "Время на регистрацию"
     ,to_date(to_char(ii.date_call_start, 'dd.mm.yyyy hh24:mi:ss'), 'dd.mm.yyyy hh24:mi:ss') "Начало звонка"
FROM inoutput_info     ii
    ,t_message_type    mt
    ,t_message_kind    mk
    ,t_crm_client_type ct
    ,department        d
WHERE 1 = 1
  AND ii.t_message_type_id = mt.t_message_type_id(+)
  AND ii.t_message_kind_id = mk.t_message_kind_id(+)
  AND ii.client_type_id    = ct.t_crm_client_type_id(+)
  AND ii.department_id     = d.department_id(+)
  AND mt.message_type_brief = 'CALL'
;
GRANT SELECT ON V_REP_CRM_INPUT_CALLS TO INS_EUL, INS_READ;
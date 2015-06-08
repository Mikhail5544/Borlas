CREATE OR REPLACE VIEW FV_REP_TEMPL AS
SELECT
/*
Шаблоны печатных документов
5.5.2015 Черных М.
*/
 rt.rep_templ_id
,rt.name
,rt.brief
,rt.rep_templ_type_id
,rt.templ
,rt.ent_id
,rt.filial_id
,rt.ext_id
,rtt.name templ_type_name
,rtt.brief templ_type_brief
,CASE
   WHEN rt.templ IS NULL THEN
    'Нет'
   ELSE
    'Да'
 END is_templ_loaded /*Признак загрузки шаблона*/
  FROM rep_templ        rt
      ,t_rep_templ_type rtt
 WHERE rt.rep_templ_type_id = rtt.t_rep_templ_type_id;
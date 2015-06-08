create or replace view fv_t_rep_templ_type as
select
/*
 Типы шаблонов отчетов
 5.5.2015 Черных М.
*/
 T_REP_TEMPL_TYPE_ID,NAME,BRIEF,ENT_ID,FILIAL_ID,EXT_ID from T_REP_TEMPL_TYPE;

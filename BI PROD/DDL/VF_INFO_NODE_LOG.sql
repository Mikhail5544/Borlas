/* sergey.ilyushkin 04/09/2012  RT 183938 */
create or replace view VF_INFO_NODE_LOG
(
   HISTORY_TABLES_ID,
   HISTORY_COLUMNS_ID,
   NODE_NAME,
   CHANGE_ENT,
   CHANGE_TYPE,
   OLD_VALUE,
   NEW_VALUE,
   CHANGE_DATE,
   SYS_USER_NAME
)
as
   select /*+ FIRST_ROWS(50)*/
       ht.history_tables_id,
       hc.history_columns_id,
       INF.NODE_NAME,
       rtrim(decode(en.brief, 'INFO_NODE', 'Узел', 'INFO_NODE_ACCESS', 'Связь', null)||'/'||
       decode(upper(hc.column_name), 'NODE_NAME', 'Наименование', 'BRIEF', 'Крат.наимен.', 'ACCESS_NODE_ID', 'Видящий узел', 'DATA_NODE_ID', 'Видимый узел', 'IS_WRITE', 'Признак редактирования', hc.column_name), '/') as COLUMN_NAME,
       decode(ht.change_type, 'INSERT', 'доб.', 'UPDATE', 'измен.', 'DELETE', 'удал.', null) as CHANGE_TYPE,
       hc.OLD_VALUE,
       hc.NEW_VALUE,
       ht.CHANGE_DATE,
       SU.SYS_USER_NAME
  from ven_history_tables ht,
       ven_history_columns hc,
       ven_info_node inf,
       entity en,
       sys_user su
 where hc.history_tables_id = ht.history_tables_id
   and inf.info_node_id = ht.uro_id
   and ht.ure_id = en.ent_id
   and en.brief in ('INFO_NODE', 'INFO_NODE_ACCESS')
   and SU.SYS_USER_ID = ht.sys_user_id
/

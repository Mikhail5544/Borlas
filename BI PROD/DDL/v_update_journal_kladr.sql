CREATE OR REPLACE FORCE VIEW V_UPDATE_JOURNAL_KLADR AS
SELECT ujk.update_journal_kladr_id,
       ujk.change_date,
       ujk.user_id,
       (SELECT sys_user_name
        FROM ins.sys_user
        WHERE sys_user_id = ujk.user_id) user_name,
       ujk.table_name,
       ujk.code,
       ujk.old_value,
       ujk.new_value,
       ujk.change_type,
       (SELECT DECODE(ujk.change_type,1,'Запись добавлена',2,'Запись отредактирована',3,'Запись удалена','Не определено')
        FROM DUAL) change_type_name
FROM INS.UPDATE_JOURNAL_KLADR ujk;


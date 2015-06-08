CREATE OR REPLACE FORCE VIEW V_ACTUAL_JOURNAL_ADR AS
SELECT aja.actual_journal_adr_id,
       aja.change_date,
       aja.user_id,
       (SELECT sys_user_name
        FROM ins.sys_user
        WHERE sys_user_id = aja.user_id) user_name,
       aja.id_adress,
       aja.note,
       aja.old_value,
       aja.new_value,
       aja.change_type,
       (SELECT DECODE(aja.change_type,1,'Запись добавлена',2,'Запись отредактирована',3,'Запись удалена','Не определено')
        FROM DUAL) change_type_name,
       c.contact_id,
       c.obj_name_orig contact_name
FROM INS.ACTUAL_JOURNAL_ADR aja,
     ins.cn_contact_address cca,
     ins.contact c
WHERE aja.id_adress = cca.adress_id (+)
      AND cca.contact_id = c.contact_id (+);


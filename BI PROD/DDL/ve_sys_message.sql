create or replace force view ve_sys_message as
select sys_message_id, name, brief, lang_id from sys_message sm where sm.lang_id=ents.get_lang_id;


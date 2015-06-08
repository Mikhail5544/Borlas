CREATE OR REPLACE VIEW V_AGN_DOC_PROP AS
SELECT agd.ag_documents_id,
       apt.description,
       apt.brief,
       (SELECT apc.new_value
          FROM ag_props_change apc
         WHERE apc.ag_documents_id = agd.ag_documents_id
           AND apc.ag_props_type_id = apt.ag_props_type_id) new_value,
       (SELECT decode(apc.new_value, 'NULL', 'Пустое значение',
               decode(apt.source_ent, NULL, apc.new_value,
               ent.obj_name(apt.source_ent, to_number(apc.new_value))))
          FROM ag_props_change apc
         WHERE apc.ag_documents_id = agd.ag_documents_id
           AND apc.ag_props_type_id = apt.ag_props_type_id) val,
       adtp.ag_doc_type_prop_id,
       apt.ag_props_type_id,
       apt.source_ent,
       adtp.can_change,
       adtp.default_val,
       agd.doc_date,
			 nvl2(adtp.lov_sql,1,0) as gen_lov
  FROM ag_documents     agd,
       ag_doc_type_prop adtp,
       ag_props_type    apt
 WHERE 1 = 1
   AND adtp.ag_doc_type_id = agd.ag_doc_type_id
   AND adtp.ag_props_type_id = apt.ag_props_type_id
with read only;
comment on column V_AGN_DOC_PROP.AG_DOCUMENTS_ID is 'Ид записи документы агентского договора';
comment on column V_AGN_DOC_PROP.DESCRIPTION is 'Описание';
comment on column V_AGN_DOC_PROP.BRIEF is 'Сокращение';
comment on column V_AGN_DOC_PROP.AG_DOC_TYPE_PROP_ID is 'Ид записи типы изменений АД для документа';
comment on column V_AGN_DOC_PROP.AG_PROPS_TYPE_ID is 'Ид записи типы реквизитов АД';
comment on column V_AGN_DOC_PROP.SOURCE_ENT is 'Исходная сущьность';
comment on column V_AGN_DOC_PROP.CAN_CHANGE is 'Может изменятся';
comment on column V_AGN_DOC_PROP.DEFAULT_VAL is 'Значение по умолчанию';
comment on column V_AGN_DOC_PROP.DOC_DATE is 'Дата документа';
comment on column V_AGN_DOC_PROP.gen_lov is 'Использовать LOV для заполнения возможного выбора';

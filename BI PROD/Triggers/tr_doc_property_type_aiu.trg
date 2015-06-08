CREATE OR REPLACE TRIGGER tr_doc_property_type_aiu
  AFTER INSERT ON doc_property_type
  FOR EACH ROW
DECLARE
  v_doc_prop_value_type_brief doc_prop_value_type.brief%TYPE;
BEGIN
  SELECT dpvt.brief
    INTO v_doc_prop_value_type_brief
    FROM doc_prop_value_type dpvt
   WHERE dpvt.doc_prop_value_type_id = :new.doc_prop_value_type_id;

  assert_deprecated(v_doc_prop_value_type_brief = 'ENTITY_OBJECT' AND :new.ent_id IS NULL
        ,'Для свойств с типом "Экземпляр сущности" должен быть указан ИД сущности'
        ,20010);

END tr_doc_property_type_aiu; 
/

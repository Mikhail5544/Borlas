CREATE OR REPLACE PACKAGE dml_doc_property IS

  FUNCTION get_record(par_doc_property_id IN doc_property.doc_property_id%TYPE)
    RETURN doc_property%ROWTYPE;

  PROCEDURE insert_record
  (
    par_document_id          IN doc_property.document_id%TYPE
   ,par_doc_property_type_id IN doc_property.doc_property_type_id%TYPE
   ,par_value_char           IN doc_property.value_char%TYPE DEFAULT NULL
   ,par_value_num            IN doc_property.value_num%TYPE DEFAULT NULL
   ,par_value_date           IN doc_property.value_date%TYPE DEFAULT NULL
   ,par_value_ent_id         IN doc_property.value_ent_id%TYPE DEFAULT NULL
   ,par_value_obj_id         IN doc_property.value_obj_id%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT doc_property%ROWTYPE);

  PROCEDURE insert_record
  (
    par_document_id          IN doc_property.document_id%TYPE
   ,par_doc_property_type_id IN doc_property.doc_property_type_id%TYPE
   ,par_value_char           IN doc_property.value_char%TYPE DEFAULT NULL
   ,par_value_num            IN doc_property.value_num%TYPE DEFAULT NULL
   ,par_value_date           IN doc_property.value_date%TYPE DEFAULT NULL
   ,par_value_ent_id         IN doc_property.value_ent_id%TYPE DEFAULT NULL
   ,par_value_obj_id         IN doc_property.value_obj_id%TYPE DEFAULT NULL
   ,par_doc_property_id      OUT doc_property.doc_property_id%TYPE
  );

  PROCEDURE update_record(par_record IN doc_property%ROWTYPE);

  PROCEDURE delete_record(par_doc_property_id IN doc_property.doc_property_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_doc_property IS

  FUNCTION get_record(par_doc_property_id IN doc_property.doc_property_id%TYPE)
    RETURN doc_property%ROWTYPE IS
    vr_record doc_property%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM doc_property WHERE doc_property_id = par_doc_property_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_document_id          IN doc_property.document_id%TYPE
   ,par_doc_property_type_id IN doc_property.doc_property_type_id%TYPE
   ,par_value_char           IN doc_property.value_char%TYPE DEFAULT NULL
   ,par_value_num            IN doc_property.value_num%TYPE DEFAULT NULL
   ,par_value_date           IN doc_property.value_date%TYPE DEFAULT NULL
   ,par_value_ent_id         IN doc_property.value_ent_id%TYPE DEFAULT NULL
   ,par_value_obj_id         IN doc_property.value_obj_id%TYPE DEFAULT NULL
  ) IS
    v_id doc_property.doc_property_id%TYPE;
  BEGIN
    insert_record(par_document_id          => par_document_id
                 ,par_doc_property_type_id => par_doc_property_type_id
                 ,par_value_char           => par_value_char
                 ,par_value_num            => par_value_num
                 ,par_value_date           => par_value_date
                 ,par_value_ent_id         => par_value_ent_id
                 ,par_value_obj_id         => par_value_obj_id
                 ,par_doc_property_id      => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT doc_property%ROWTYPE) IS
    v_id doc_property.doc_property_id%TYPE;
  BEGIN
    insert_record(par_document_id          => par_record.document_id
                 ,par_doc_property_type_id => par_record.doc_property_type_id
                 ,par_value_char           => par_record.value_char
                 ,par_value_num            => par_record.value_num
                 ,par_value_date           => par_record.value_date
                 ,par_value_ent_id         => par_record.value_ent_id
                 ,par_value_obj_id         => par_record.value_obj_id
                 ,par_doc_property_id      => par_record.doc_property_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_document_id          IN doc_property.document_id%TYPE
   ,par_doc_property_type_id IN doc_property.doc_property_type_id%TYPE
   ,par_value_char           IN doc_property.value_char%TYPE DEFAULT NULL
   ,par_value_num            IN doc_property.value_num%TYPE DEFAULT NULL
   ,par_value_date           IN doc_property.value_date%TYPE DEFAULT NULL
   ,par_value_ent_id         IN doc_property.value_ent_id%TYPE DEFAULT NULL
   ,par_value_obj_id         IN doc_property.value_obj_id%TYPE DEFAULT NULL
   ,par_doc_property_id      OUT doc_property.doc_property_id%TYPE
  ) IS
  BEGIN
    SELECT sq_doc_property.nextval INTO par_doc_property_id FROM dual;
    INSERT INTO doc_property
      (doc_property_id
      ,doc_property_type_id
      ,value_obj_id
      ,value_num
      ,value_date
      ,value_ent_id
      ,document_id
      ,value_char)
    VALUES
      (par_doc_property_id
      ,par_doc_property_type_id
      ,par_value_obj_id
      ,par_value_num
      ,par_value_date
      ,par_value_ent_id
      ,par_document_id
      ,par_value_char);
  END insert_record;

  PROCEDURE update_record(par_record IN doc_property%ROWTYPE) IS
  BEGIN
    UPDATE doc_property
       SET document_id          = par_record.document_id
          ,doc_property_type_id = par_record.doc_property_type_id
          ,value_char           = par_record.value_char
          ,value_num            = par_record.value_num
          ,value_date           = par_record.value_date
          ,value_ent_id         = par_record.value_ent_id
          ,value_obj_id         = par_record.value_obj_id
     WHERE doc_property_id = par_record.doc_property_id;
  END update_record;

  PROCEDURE delete_record(par_doc_property_id IN doc_property.doc_property_id%TYPE) IS
  BEGIN
    DELETE FROM doc_property WHERE doc_property_id = par_doc_property_id;
  END delete_record;
END;
/

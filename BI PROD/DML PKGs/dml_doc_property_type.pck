CREATE OR REPLACE PACKAGE dml_doc_property_type IS

  FUNCTION get_record(par_doc_property_type_id IN doc_property_type.doc_property_type_id%TYPE)
    RETURN doc_property_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_doc_templ_id           IN doc_property_type.doc_templ_id%TYPE
   ,par_doc_prop_value_type_id IN doc_property_type.doc_prop_value_type_id%TYPE
   ,par_brief                  IN doc_property_type.brief%TYPE
   ,par_name                   IN doc_property_type.name%TYPE
  );

  PROCEDURE insert_record(par_record IN OUT doc_property_type%ROWTYPE);

  PROCEDURE insert_record
  (
    par_doc_templ_id           IN doc_property_type.doc_templ_id%TYPE
   ,par_doc_prop_value_type_id IN doc_property_type.doc_prop_value_type_id%TYPE
   ,par_brief                  IN doc_property_type.brief%TYPE
   ,par_name                   IN doc_property_type.name%TYPE
   ,par_doc_property_type_id   OUT doc_property_type.doc_property_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN doc_property_type%ROWTYPE);

  PROCEDURE delete_record(par_doc_property_type_id IN doc_property_type.doc_property_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_doc_property_type IS

  FUNCTION get_record(par_doc_property_type_id IN doc_property_type.doc_property_type_id%TYPE)
    RETURN doc_property_type%ROWTYPE IS
    vr_record doc_property_type%ROWTYPE;
  BEGIN
    SELECT *
      INTO vr_record
      FROM doc_property_type
     WHERE doc_property_type_id = par_doc_property_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_doc_templ_id           IN doc_property_type.doc_templ_id%TYPE
   ,par_doc_prop_value_type_id IN doc_property_type.doc_prop_value_type_id%TYPE
   ,par_brief                  IN doc_property_type.brief%TYPE
   ,par_name                   IN doc_property_type.name%TYPE
  ) IS
    v_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    insert_record(par_doc_templ_id           => par_doc_templ_id
                 ,par_doc_prop_value_type_id => par_doc_prop_value_type_id
                 ,par_brief                  => par_brief
                 ,par_name                   => par_name
                 ,par_doc_property_type_id   => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT doc_property_type%ROWTYPE) IS
    v_id doc_property_type.doc_property_type_id%TYPE;
  BEGIN
    insert_record(par_doc_templ_id           => par_record.doc_templ_id
                 ,par_doc_prop_value_type_id => par_record.doc_prop_value_type_id
                 ,par_brief                  => par_record.brief
                 ,par_name                   => par_record.name
                 ,par_doc_property_type_id   => par_record.doc_property_type_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_doc_templ_id           IN doc_property_type.doc_templ_id%TYPE
   ,par_doc_prop_value_type_id IN doc_property_type.doc_prop_value_type_id%TYPE
   ,par_brief                  IN doc_property_type.brief%TYPE
   ,par_name                   IN doc_property_type.name%TYPE
   ,par_doc_property_type_id   OUT doc_property_type.doc_property_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_doc_property_type.nextval INTO par_doc_property_type_id FROM dual;
    INSERT INTO doc_property_type
      (doc_property_type_id, NAME, brief, doc_templ_id, doc_prop_value_type_id)
    VALUES
      (par_doc_property_type_id, par_name, par_brief, par_doc_templ_id, par_doc_prop_value_type_id);
  END insert_record;

  PROCEDURE update_record(par_record IN doc_property_type%ROWTYPE) IS
  BEGIN
    UPDATE doc_property_type
       SET doc_templ_id           = par_record.doc_templ_id
          ,doc_prop_value_type_id = par_record.doc_prop_value_type_id
          ,brief                  = par_record.brief
          ,NAME                   = par_record.name
     WHERE doc_property_type_id = par_record.doc_property_type_id;
  END update_record;

  PROCEDURE delete_record(par_doc_property_type_id IN doc_property_type.doc_property_type_id%TYPE) IS
  BEGIN
    DELETE FROM doc_property_type WHERE doc_property_type_id = par_doc_property_type_id;
  END delete_record;
END;
/

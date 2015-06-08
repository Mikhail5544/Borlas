CREATE OR REPLACE PACKAGE dml_doc_templ IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN doc_templ.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN doc_templ.doc_templ_id%TYPE;

  FUNCTION get_record(par_doc_templ_id IN doc_templ.doc_templ_id%TYPE) RETURN doc_templ%ROWTYPE;

  PROCEDURE insert_record
  (
    par_doc_ent_id            IN doc_templ.doc_ent_id%TYPE
   ,par_name                  IN doc_templ.name%TYPE
   ,par_brief                 IN doc_templ.brief%TYPE
   ,par_prefix                IN doc_templ.prefix%TYPE DEFAULT NULL
   ,par_ending                IN doc_templ.ending%TYPE DEFAULT NULL
   ,par_num_len_min           IN doc_templ.num_len_min%TYPE DEFAULT NULL
   ,par_num_len_max           IN doc_templ.num_len_max%TYPE DEFAULT NULL
   ,par_def_doc_folder_id     IN doc_templ.def_doc_folder_id%TYPE DEFAULT NULL
   ,par_def_doc_status_ref_id IN doc_templ.def_doc_status_ref_id%TYPE DEFAULT NULL
   ,par_num_code              IN doc_templ.num_code%TYPE DEFAULT NULL
   ,par_edit_form_name        IN doc_templ.edit_form_name%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT doc_templ%ROWTYPE);

  PROCEDURE insert_record
  (
    par_doc_ent_id            IN doc_templ.doc_ent_id%TYPE
   ,par_name                  IN doc_templ.name%TYPE
   ,par_brief                 IN doc_templ.brief%TYPE
   ,par_prefix                IN doc_templ.prefix%TYPE DEFAULT NULL
   ,par_ending                IN doc_templ.ending%TYPE DEFAULT NULL
   ,par_num_len_min           IN doc_templ.num_len_min%TYPE DEFAULT NULL
   ,par_num_len_max           IN doc_templ.num_len_max%TYPE DEFAULT NULL
   ,par_def_doc_folder_id     IN doc_templ.def_doc_folder_id%TYPE DEFAULT NULL
   ,par_def_doc_status_ref_id IN doc_templ.def_doc_status_ref_id%TYPE DEFAULT NULL
   ,par_num_code              IN doc_templ.num_code%TYPE DEFAULT NULL
   ,par_edit_form_name        IN doc_templ.edit_form_name%TYPE DEFAULT NULL
   ,par_doc_templ_id          OUT doc_templ.doc_templ_id%TYPE
  );

  PROCEDURE update_record(par_record IN doc_templ%ROWTYPE);

  PROCEDURE delete_record(par_doc_templ_id IN doc_templ.doc_templ_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_doc_templ IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN doc_templ.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN doc_templ.doc_templ_id%TYPE IS
    v_id doc_templ.doc_templ_id%TYPE;
  BEGIN
    BEGIN
      SELECT doc_templ_id INTO v_id FROM doc_templ WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Шаблон документа" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_doc_templ_id IN doc_templ.doc_templ_id%TYPE) RETURN doc_templ%ROWTYPE IS
    vr_record doc_templ%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM doc_templ WHERE doc_templ_id = par_doc_templ_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_doc_ent_id            IN doc_templ.doc_ent_id%TYPE
   ,par_name                  IN doc_templ.name%TYPE
   ,par_brief                 IN doc_templ.brief%TYPE
   ,par_prefix                IN doc_templ.prefix%TYPE DEFAULT NULL
   ,par_ending                IN doc_templ.ending%TYPE DEFAULT NULL
   ,par_num_len_min           IN doc_templ.num_len_min%TYPE DEFAULT NULL
   ,par_num_len_max           IN doc_templ.num_len_max%TYPE DEFAULT NULL
   ,par_def_doc_folder_id     IN doc_templ.def_doc_folder_id%TYPE DEFAULT NULL
   ,par_def_doc_status_ref_id IN doc_templ.def_doc_status_ref_id%TYPE DEFAULT NULL
   ,par_num_code              IN doc_templ.num_code%TYPE DEFAULT NULL
   ,par_edit_form_name        IN doc_templ.edit_form_name%TYPE DEFAULT NULL
  ) IS
    v_id doc_templ.doc_templ_id%TYPE;
  BEGIN
    insert_record(par_doc_ent_id            => par_doc_ent_id
                 ,par_name                  => par_name
                 ,par_brief                 => par_brief
                 ,par_prefix                => par_prefix
                 ,par_ending                => par_ending
                 ,par_num_len_min           => par_num_len_min
                 ,par_num_len_max           => par_num_len_max
                 ,par_def_doc_folder_id     => par_def_doc_folder_id
                 ,par_def_doc_status_ref_id => par_def_doc_status_ref_id
                 ,par_num_code              => par_num_code
                 ,par_edit_form_name        => par_edit_form_name
                 ,par_doc_templ_id          => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT doc_templ%ROWTYPE) IS
    v_id doc_templ.doc_templ_id%TYPE;
  BEGIN
    insert_record(par_doc_ent_id            => par_record.doc_ent_id
                 ,par_name                  => par_record.name
                 ,par_brief                 => par_record.brief
                 ,par_prefix                => par_record.prefix
                 ,par_ending                => par_record.ending
                 ,par_num_len_min           => par_record.num_len_min
                 ,par_num_len_max           => par_record.num_len_max
                 ,par_def_doc_folder_id     => par_record.def_doc_folder_id
                 ,par_def_doc_status_ref_id => par_record.def_doc_status_ref_id
                 ,par_num_code              => par_record.num_code
                 ,par_edit_form_name        => par_record.edit_form_name
                 ,par_doc_templ_id          => par_record.doc_templ_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_doc_ent_id            IN doc_templ.doc_ent_id%TYPE
   ,par_name                  IN doc_templ.name%TYPE
   ,par_brief                 IN doc_templ.brief%TYPE
   ,par_prefix                IN doc_templ.prefix%TYPE DEFAULT NULL
   ,par_ending                IN doc_templ.ending%TYPE DEFAULT NULL
   ,par_num_len_min           IN doc_templ.num_len_min%TYPE DEFAULT NULL
   ,par_num_len_max           IN doc_templ.num_len_max%TYPE DEFAULT NULL
   ,par_def_doc_folder_id     IN doc_templ.def_doc_folder_id%TYPE DEFAULT NULL
   ,par_def_doc_status_ref_id IN doc_templ.def_doc_status_ref_id%TYPE DEFAULT NULL
   ,par_num_code              IN doc_templ.num_code%TYPE DEFAULT NULL
   ,par_edit_form_name        IN doc_templ.edit_form_name%TYPE DEFAULT NULL
   ,par_doc_templ_id          OUT doc_templ.doc_templ_id%TYPE
  ) IS
  BEGIN
    SELECT sq_doc_templ.nextval INTO par_doc_templ_id FROM dual;
    INSERT INTO doc_templ
      (doc_templ_id
      ,NAME
      ,brief
      ,prefix
      ,edit_form_name
      ,num_len_min
      ,num_len_max
      ,def_doc_folder_id
      ,def_doc_status_ref_id
      ,num_code
      ,doc_ent_id
      ,ending)
    VALUES
      (par_doc_templ_id
      ,par_name
      ,par_brief
      ,par_prefix
      ,par_edit_form_name
      ,par_num_len_min
      ,par_num_len_max
      ,par_def_doc_folder_id
      ,par_def_doc_status_ref_id
      ,par_num_code
      ,par_doc_ent_id
      ,par_ending);
  END insert_record;

  PROCEDURE update_record(par_record IN doc_templ%ROWTYPE) IS
  BEGIN
    UPDATE doc_templ
       SET doc_ent_id            = par_record.doc_ent_id
          ,NAME                  = par_record.name
          ,brief                 = par_record.brief
          ,prefix                = par_record.prefix
          ,ending                = par_record.ending
          ,num_len_min           = par_record.num_len_min
          ,num_len_max           = par_record.num_len_max
          ,def_doc_folder_id     = par_record.def_doc_folder_id
          ,def_doc_status_ref_id = par_record.def_doc_status_ref_id
          ,num_code              = par_record.num_code
          ,edit_form_name        = par_record.edit_form_name
     WHERE doc_templ_id = par_record.doc_templ_id;
  END update_record;

  PROCEDURE delete_record(par_doc_templ_id IN doc_templ.doc_templ_id%TYPE) IS
  BEGIN
    DELETE FROM doc_templ WHERE doc_templ_id = par_doc_templ_id;
  END delete_record;
END;
/

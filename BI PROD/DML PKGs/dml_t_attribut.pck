CREATE OR REPLACE PACKAGE dml_t_attribut IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_attribut.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut.t_attribut_id%TYPE;

  FUNCTION get_record(par_t_attribut_id IN t_attribut.t_attribut_id%TYPE) RETURN t_attribut%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut.name%TYPE
   ,par_brief                IN t_attribut.brief%TYPE
   ,par_t_attribut_source_id IN t_attribut.t_attribut_source_id%TYPE
   ,par_attribut_ent_id      IN t_attribut.attribut_ent_id%TYPE DEFAULT NULL
   ,par_obj_list_sql         IN t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_attr_tarif_id        IN t_attribut.attr_tarif_id%TYPE DEFAULT NULL
   ,par_note                 IN t_attribut.note%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut.name%TYPE
   ,par_brief                IN t_attribut.brief%TYPE
   ,par_t_attribut_source_id IN t_attribut.t_attribut_source_id%TYPE
   ,par_attribut_ent_id      IN t_attribut.attribut_ent_id%TYPE DEFAULT NULL
   ,par_obj_list_sql         IN t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_attr_tarif_id        IN t_attribut.attr_tarif_id%TYPE DEFAULT NULL
   ,par_note                 IN t_attribut.note%TYPE DEFAULT NULL
   ,par_t_attribut_id        OUT t_attribut.t_attribut_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_attribut%ROWTYPE);

  PROCEDURE delete_record(par_t_attribut_id IN t_attribut.t_attribut_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_attribut IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_attribut.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_attribut.t_attribut_id%TYPE IS
    v_id t_attribut.t_attribut_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_attribut_id INTO v_id FROM t_attribut WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Атрибут для тарификатора" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_attribut_id IN t_attribut.t_attribut_id%TYPE) RETURN t_attribut%ROWTYPE IS
    vr_record t_attribut%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_attribut WHERE t_attribut_id = par_t_attribut_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut.name%TYPE
   ,par_brief                IN t_attribut.brief%TYPE
   ,par_t_attribut_source_id IN t_attribut.t_attribut_source_id%TYPE
   ,par_attribut_ent_id      IN t_attribut.attribut_ent_id%TYPE DEFAULT NULL
   ,par_obj_list_sql         IN t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_attr_tarif_id        IN t_attribut.attr_tarif_id%TYPE DEFAULT NULL
   ,par_note                 IN t_attribut.note%TYPE DEFAULT NULL
  ) IS
    v_id t_attribut.t_attribut_id%TYPE;
  BEGIN
    insert_record(par_name                 => par_name
                 ,par_brief                => par_brief
                 ,par_t_attribut_source_id => par_t_attribut_source_id
                 ,par_attribut_ent_id      => par_attribut_ent_id
                 ,par_obj_list_sql         => par_obj_list_sql
                 ,par_attr_tarif_id        => par_attr_tarif_id
                 ,par_note                 => par_note
                 ,par_t_attribut_id        => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                 IN t_attribut.name%TYPE
   ,par_brief                IN t_attribut.brief%TYPE
   ,par_t_attribut_source_id IN t_attribut.t_attribut_source_id%TYPE
   ,par_attribut_ent_id      IN t_attribut.attribut_ent_id%TYPE DEFAULT NULL
   ,par_obj_list_sql         IN t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_attr_tarif_id        IN t_attribut.attr_tarif_id%TYPE DEFAULT NULL
   ,par_note                 IN t_attribut.note%TYPE DEFAULT NULL
   ,par_t_attribut_id        OUT t_attribut.t_attribut_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_attribut.nextval INTO par_t_attribut_id FROM dual;
    INSERT INTO t_attribut
      (t_attribut_id
      ,brief
      ,note
      ,obj_list_sql
      ,t_attribut_source_id
      ,attr_tarif_id
      ,NAME
      ,attribut_ent_id)
    VALUES
      (par_t_attribut_id
      ,par_brief
      ,par_note
      ,par_obj_list_sql
      ,par_t_attribut_source_id
      ,par_attr_tarif_id
      ,par_name
      ,par_attribut_ent_id);
  END insert_record;

  PROCEDURE update_record(par_record IN t_attribut%ROWTYPE) IS
  BEGIN
    UPDATE t_attribut
       SET NAME                 = par_record.name
          ,brief                = par_record.brief
          ,attribut_ent_id      = par_record.attribut_ent_id
          ,obj_list_sql         = par_record.obj_list_sql
          ,t_attribut_source_id = par_record.t_attribut_source_id
          ,attr_tarif_id        = par_record.attr_tarif_id
          ,note                 = par_record.note
     WHERE t_attribut_id = par_record.t_attribut_id;
  END update_record;

  PROCEDURE delete_record(par_t_attribut_id IN t_attribut.t_attribut_id%TYPE) IS
  BEGIN
    DELETE FROM t_attribut WHERE t_attribut_id = par_t_attribut_id;
  END delete_record;
END;
/

CREATE OR REPLACE PACKAGE dml_ac_payment_templ IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN ac_payment_templ.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN ac_payment_templ.payment_templ_id%TYPE;

  FUNCTION get_record(par_payment_templ_id IN ac_payment_templ.payment_templ_id%TYPE)
    RETURN ac_payment_templ%ROWTYPE;

  PROCEDURE insert_record
  (
    par_doc_templ_id         IN ac_payment_templ.doc_templ_id%TYPE
   ,par_payment_type_id      IN ac_payment_templ.payment_type_id%TYPE
   ,par_payment_direct_id    IN ac_payment_templ.payment_direct_id%TYPE
   ,par_title                IN ac_payment_templ.title%TYPE
   ,par_brief                IN ac_payment_templ.brief%TYPE
   ,par_parent_doc_ent_id    IN ac_payment_templ.parent_doc_ent_id%TYPE DEFAULT NULL
   ,par_self_oper_templ_id   IN ac_payment_templ.self_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_oper_templ_id    IN ac_payment_templ.dso_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_ag_oper_templ_id IN ac_payment_templ.dso_ag_oper_templ_id%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT ac_payment_templ%ROWTYPE);

  PROCEDURE insert_record
  (
    par_doc_templ_id         IN ac_payment_templ.doc_templ_id%TYPE
   ,par_payment_type_id      IN ac_payment_templ.payment_type_id%TYPE
   ,par_payment_direct_id    IN ac_payment_templ.payment_direct_id%TYPE
   ,par_title                IN ac_payment_templ.title%TYPE
   ,par_brief                IN ac_payment_templ.brief%TYPE
   ,par_parent_doc_ent_id    IN ac_payment_templ.parent_doc_ent_id%TYPE DEFAULT NULL
   ,par_self_oper_templ_id   IN ac_payment_templ.self_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_oper_templ_id    IN ac_payment_templ.dso_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_ag_oper_templ_id IN ac_payment_templ.dso_ag_oper_templ_id%TYPE DEFAULT NULL
   ,par_payment_templ_id     OUT ac_payment_templ.payment_templ_id%TYPE
  );

  PROCEDURE update_record(par_record IN ac_payment_templ%ROWTYPE);

  PROCEDURE delete_record(par_payment_templ_id IN ac_payment_templ.payment_templ_id%TYPE);
END dml_ac_payment_templ;
/
CREATE OR REPLACE PACKAGE BODY dml_ac_payment_templ IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN ac_payment_templ.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN ac_payment_templ.payment_templ_id%TYPE IS
    v_id ac_payment_templ.payment_templ_id%TYPE;
  BEGIN
    BEGIN
      SELECT payment_templ_id INTO v_id FROM ac_payment_templ WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Шаблон платежа" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_payment_templ_id IN ac_payment_templ.payment_templ_id%TYPE)
    RETURN ac_payment_templ%ROWTYPE IS
    vr_record ac_payment_templ%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM ac_payment_templ WHERE payment_templ_id = par_payment_templ_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_doc_templ_id         IN ac_payment_templ.doc_templ_id%TYPE
   ,par_payment_type_id      IN ac_payment_templ.payment_type_id%TYPE
   ,par_payment_direct_id    IN ac_payment_templ.payment_direct_id%TYPE
   ,par_title                IN ac_payment_templ.title%TYPE
   ,par_brief                IN ac_payment_templ.brief%TYPE
   ,par_parent_doc_ent_id    IN ac_payment_templ.parent_doc_ent_id%TYPE DEFAULT NULL
   ,par_self_oper_templ_id   IN ac_payment_templ.self_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_oper_templ_id    IN ac_payment_templ.dso_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_ag_oper_templ_id IN ac_payment_templ.dso_ag_oper_templ_id%TYPE DEFAULT NULL
  ) IS
    v_id ac_payment_templ.payment_templ_id%TYPE;
  BEGIN
    insert_record(par_doc_templ_id         => par_doc_templ_id
                 ,par_payment_type_id      => par_payment_type_id
                 ,par_payment_direct_id    => par_payment_direct_id
                 ,par_title                => par_title
                 ,par_brief                => par_brief
                 ,par_parent_doc_ent_id    => par_parent_doc_ent_id
                 ,par_self_oper_templ_id   => par_self_oper_templ_id
                 ,par_dso_oper_templ_id    => par_dso_oper_templ_id
                 ,par_dso_ag_oper_templ_id => par_dso_ag_oper_templ_id
                 ,par_payment_templ_id     => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT ac_payment_templ%ROWTYPE) IS
  BEGIN
    insert_record(par_doc_templ_id         => par_record.doc_templ_id
                 ,par_payment_type_id      => par_record.payment_type_id
                 ,par_payment_direct_id    => par_record.payment_direct_id
                 ,par_title                => par_record.title
                 ,par_brief                => par_record.brief
                 ,par_parent_doc_ent_id    => par_record.parent_doc_ent_id
                 ,par_self_oper_templ_id   => par_record.self_oper_templ_id
                 ,par_dso_oper_templ_id    => par_record.dso_oper_templ_id
                 ,par_dso_ag_oper_templ_id => par_record.dso_ag_oper_templ_id
                 ,par_payment_templ_id     => par_record.payment_templ_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_doc_templ_id         IN ac_payment_templ.doc_templ_id%TYPE
   ,par_payment_type_id      IN ac_payment_templ.payment_type_id%TYPE
   ,par_payment_direct_id    IN ac_payment_templ.payment_direct_id%TYPE
   ,par_title                IN ac_payment_templ.title%TYPE
   ,par_brief                IN ac_payment_templ.brief%TYPE
   ,par_parent_doc_ent_id    IN ac_payment_templ.parent_doc_ent_id%TYPE DEFAULT NULL
   ,par_self_oper_templ_id   IN ac_payment_templ.self_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_oper_templ_id    IN ac_payment_templ.dso_oper_templ_id%TYPE DEFAULT NULL
   ,par_dso_ag_oper_templ_id IN ac_payment_templ.dso_ag_oper_templ_id%TYPE DEFAULT NULL
   ,par_payment_templ_id     OUT ac_payment_templ.payment_templ_id%TYPE
  ) IS
  BEGIN
    SELECT sq_ac_payment_templ.nextval INTO par_payment_templ_id FROM dual;
    INSERT INTO ac_payment_templ
      (payment_templ_id
      ,payment_type_id
      ,payment_direct_id
      ,dso_ag_oper_templ_id
      ,brief
      ,parent_doc_ent_id
      ,self_oper_templ_id
      ,dso_oper_templ_id
      ,doc_templ_id
      ,title)
    VALUES
      (par_payment_templ_id
      ,par_payment_type_id
      ,par_payment_direct_id
      ,par_dso_ag_oper_templ_id
      ,par_brief
      ,par_parent_doc_ent_id
      ,par_self_oper_templ_id
      ,par_dso_oper_templ_id
      ,par_doc_templ_id
      ,par_title);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN ac_payment_templ%ROWTYPE) IS
  BEGIN
    UPDATE ac_payment_templ
       SET doc_templ_id         = par_record.doc_templ_id
          ,payment_type_id      = par_record.payment_type_id
          ,payment_direct_id    = par_record.payment_direct_id
          ,title                = par_record.title
          ,brief                = par_record.brief
          ,parent_doc_ent_id    = par_record.parent_doc_ent_id
          ,self_oper_templ_id   = par_record.self_oper_templ_id
          ,dso_oper_templ_id    = par_record.dso_oper_templ_id
          ,dso_ag_oper_templ_id = par_record.dso_ag_oper_templ_id
     WHERE payment_templ_id = par_record.payment_templ_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_payment_templ_id IN ac_payment_templ.payment_templ_id%TYPE) IS
  BEGIN
    DELETE FROM ac_payment_templ WHERE payment_templ_id = par_payment_templ_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;
END dml_ac_payment_templ;
/

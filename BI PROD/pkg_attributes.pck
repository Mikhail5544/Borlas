CREATE OR REPLACE PACKAGE pkg_attributes IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 03.09.2013 13:47:24
  -- Purpose : Пакет для работы с таблицами t_attribut

  gc_attr_source_default_brief CONSTANT t_attribut_source.brief%TYPE := 'S_DEFAULT';
  gc_attr_source_func_brief    CONSTANT t_attribut_source.brief%TYPE := 'S_FUNC';
  gc_attr_source_ent_brief     CONSTANT t_attribut_source.brief%TYPE := 'S_ENT';

  PROCEDURE create_attribut
  (
    par_attribut_name        t_attribut.name%TYPE
   ,par_attribut_brief       t_attribut.brief%TYPE
   ,par_attribut_ent_brief   entity.brief%TYPE DEFAULT NULL
   ,par_obj_list_sql         t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_source_brief         t_attribut_source.brief%TYPE DEFAULT gc_attr_source_default_brief
   ,par_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_note                 t_attribut.note%TYPE DEFAULT NULL
  );

  PROCEDURE assign_entity_for_attribute
  (
    par_attribute_brief t_attribut.brief%TYPE
   ,par_entity_brief    entity.brief%TYPE
   ,par_sql             t_attribut_entity.obj_list_sql%TYPE
  );

  FUNCTION get_attribut_id_by_brief(par_brief VARCHAR2) RETURN NUMBER;

END pkg_attributes;
/
CREATE OR REPLACE PACKAGE BODY pkg_attributes IS

  PROCEDURE create_attribut
  (
    par_attribut_name        t_attribut.name%TYPE
   ,par_attribut_brief       t_attribut.brief%TYPE
   ,par_attribut_ent_brief   entity.brief%TYPE DEFAULT NULL
   ,par_obj_list_sql         t_attribut.obj_list_sql%TYPE DEFAULT NULL
   ,par_source_brief         t_attribut_source.brief%TYPE DEFAULT gc_attr_source_default_brief
   ,par_prod_coef_type_brief t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_note                 t_attribut.note%TYPE DEFAULT NULL
  ) IS
    v_attribute_source_id t_attribut_source.t_attribut_source_id%TYPE;
    v_ent_id              entity.ent_id%TYPE;
    v_prod_coef_type_id   t_prod_coef_type.t_prod_coef_type_id%TYPE;
  BEGIN
    IF par_attribut_ent_brief IS NOT NULL
    THEN
      v_ent_id := ent.id_by_brief(par_attribut_ent_brief);
      IF v_ent_id IS NULL
      THEN
        raise_application_error(-20000
                               ,'Не удалось найти сущность по брифу - ' || par_attribut_ent_brief);
      END IF;
    END IF;
  
    v_attribute_source_id := dml_t_attribut_source.get_id_by_brief(par_brief          => par_source_brief
                                                                  ,par_raise_on_error => TRUE);
  
    IF par_prod_coef_type_brief IS NOT NULL
    THEN
      v_prod_coef_type_id := dml_t_prod_coef_type.get_id_by_brief(par_brief          => par_prod_coef_type_brief
                                                                 ,par_raise_on_error => TRUE);
    END IF;
  
    dml_t_attribut.insert_record(par_name                 => par_attribut_name
                                ,par_brief                => par_attribut_brief
                                ,par_t_attribut_source_id => v_attribute_source_id
                                ,par_attribut_ent_id      => v_ent_id
                                ,par_obj_list_sql         => par_obj_list_sql
                                ,par_attr_tarif_id        => v_prod_coef_type_id
                                ,par_note                 => par_note);
  
  END create_attribut;

  PROCEDURE assign_entity_for_attribute
  (
    par_attribute_brief t_attribut.brief%TYPE
   ,par_entity_brief    entity.brief%TYPE
   ,par_sql             t_attribut_entity.obj_list_sql%TYPE
  ) IS
    v_attribute_id t_attribut.t_attribut_id%TYPE;
    v_ent_id       entity.ent_id%TYPE;
  BEGIN
    assert_deprecated(par_sql IS NULL, 'Параметр par_sql не может быть пустым');
  
    v_attribute_id := get_attribut_id_by_brief(par_brief => par_attribute_brief);
  
    v_ent_id := ents.id_by_brief(p_brief => par_entity_brief);
    assert_deprecated(v_ent_id IS NULL
          ,'Не удалось определить entity по брифу: ' || par_entity_brief);
  
    INSERT INTO ven_t_attribut_entity
      (entity_id, obj_list_sql, t_attribut_id)
    VALUES
      (v_ent_id, par_sql, v_attribute_id);
  
  END assign_entity_for_attribute;

  FUNCTION get_attribut_id_by_brief(par_brief VARCHAR2) RETURN NUMBER IS
    v_attribute_id t_attribut.t_attribut_id%TYPE;
  BEGIN
    RETURN dml_t_attribut.get_id_by_brief(par_brief => par_brief, par_raise_on_error => TRUE);
  END get_attribut_id_by_brief;

BEGIN
  NULL;
END pkg_attributes; 
/

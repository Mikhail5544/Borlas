CREATE OR REPLACE PACKAGE pkg_product_category IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 22.07.2014 18:52:47
  -- Purpose : 

  /*
    Капля П.
    Получение идентификатора категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_id
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE;
  FUNCTION get_product_category_id
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE;
  FUNCTION get_product_category_id
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE;

  /*
    Капля П.
    Получение брифа категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_brief
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE;
  FUNCTION get_product_category_brief
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE;
  FUNCTION get_product_category_brief
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE;

  /*
    Капля П.
    Получение наименования категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_name
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE;
  FUNCTION get_product_category_name
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE;
  FUNCTION get_product_category_name
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE;

  /*
    Капля П.
    Проверка, принадлежит ли продукт к кадегории
  */
  FUNCTION is_product_in_category
  (
    par_product_id  NUMBER
   ,par_category_id NUMBER
  ) RETURN BOOLEAN;
  FUNCTION is_product_in_category
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN BOOLEAN;
  FUNCTION is_product_in_category
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN BOOLEAN;

  /*
    Капля П.
    Получение списка ИД продуктов для категории
  */
  FUNCTION get_product_list(par_category_id NUMBER) RETURN dml_t_product.typ_prymary_key_nested_table
    PIPELINED;
  FUNCTION get_product_list
  (
    par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN dml_t_product.typ_prymary_key_nested_table
    PIPELINED;

  /*
    Капля П.
    Добавление продукта в категоризатор
  */
  PROCEDURE add_product_to_category
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_prod_category_id NUMBER
  );
  PROCEDURE add_product_to_category
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_prod_category_brief VARCHAR2
  );
  PROCEDURE add_product_to_category
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_prod_category_brief VARCHAR2
  );

END pkg_product_category;
/
CREATE OR REPLACE PACKAGE BODY pkg_product_category IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  FUNCTION get_product_category
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category%ROWTYPE IS
    v_product_category t_prod_category%ROWTYPE;
  BEGIN
    SELECT pc.*
      INTO v_product_category
      FROM t_product_prod_cat ppc
          ,t_prod_category    pc
     WHERE ppc.t_product_id = par_product_id
       AND ppc.t_prod_category_type_id = par_category_type_id
       AND ppc.t_prod_category_id = pc.t_prod_category_id;
    RETURN v_product_category;
  EXCEPTION
    WHEN no_data_found THEN
      IF par_raise_on_error
      THEN
        DECLARE
          v_product       dml_t_product.tt_t_product := dml_t_product.get_record(par_product_id);
          v_category_type dml_t_prod_category_type.tt_t_prod_category_type := dml_t_prod_category_type.get_record(par_category_type_id);
        BEGIN
          ex.raise('Не удалось определить категорию для продукта ' || v_product.description ||
                   ' для типа категории ' || v_category_type.name);
        END;
      END IF;
    WHEN OTHERS THEN
      ex.raise;
  END get_product_category;

  /*
    Капля П.
    Получение идентификатора категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_id
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE IS
  BEGIN
    RETURN get_product_category(par_product_id, par_category_type_id, par_raise_on_error).t_prod_category_id;
  END get_product_category_id;

  FUNCTION get_product_category_id
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE IS
    v_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
  BEGIN
    v_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    RETURN get_product_category_id(par_product_id       => par_product_id
                                  ,par_category_type_id => v_category_type_id
                                  ,par_raise_on_error   => par_raise_on_error);
  END get_product_category_id;

  FUNCTION get_product_category_id
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.t_prod_category_id%TYPE IS
    v_product_id t_product.product_id%TYPE;
  BEGIN
    v_product_id := dml_t_product.get_id_by_brief(par_product_brief);
    RETURN get_product_category_id(par_product_id          => v_product_id
                                  ,par_category_type_brief => par_category_type_brief
                                  ,par_raise_on_error      => par_raise_on_error);
  END get_product_category_id;

  /*
    Капля П.
    Получение брифа категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_brief
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE IS
  BEGIN
    RETURN get_product_category(par_product_id, par_category_type_id, par_raise_on_error).brief;
  END get_product_category_brief;

  FUNCTION get_product_category_brief
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE IS
    v_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
  BEGIN
    v_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    RETURN get_product_category_brief(par_product_id       => par_product_id
                                     ,par_category_type_id => v_category_type_id
                                     ,par_raise_on_error   => par_raise_on_error);
  END get_product_category_brief;

  FUNCTION get_product_category_brief
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.brief%TYPE IS
    v_product_id t_product.product_id%TYPE;
  BEGIN
    v_product_id := dml_t_product.get_id_by_brief(par_product_brief);
    RETURN get_product_category_brief(par_product_id          => v_product_id
                                     ,par_category_type_brief => par_category_type_brief
                                     ,par_raise_on_error      => par_raise_on_error);
  END get_product_category_brief;

  /*
    Капля П.
    Получение наименования категории в рамках типа категаризации для продукта
  */
  FUNCTION get_product_category_name
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_raise_on_error   BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE IS
  BEGIN
    RETURN get_product_category(par_product_id, par_category_type_id).name;
  END get_product_category_name;

  FUNCTION get_product_category_name
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE IS
    v_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
  BEGIN
    v_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    RETURN get_product_category_name(par_product_id       => par_product_id
                                    ,par_category_type_id => v_category_type_id
                                    ,par_raise_on_error   => par_raise_on_error);
  END get_product_category_name;

  FUNCTION get_product_category_name
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_raise_on_error      BOOLEAN DEFAULT FALSE
  ) RETURN t_prod_category.name%TYPE IS
    v_product_id t_product.product_id%TYPE;
  BEGIN
    v_product_id := dml_t_product.get_id_by_brief(par_product_brief);
    RETURN get_product_category_name(par_product_id          => v_product_id
                                    ,par_category_type_brief => par_category_type_brief
                                    ,par_raise_on_error      => par_raise_on_error);
  END get_product_category_name;

  /*
    Капля П.
    Проверка, принадлежит ли продукт к кадегории
  */
  FUNCTION is_product_in_category
  (
    par_product_id  NUMBER
   ,par_category_id NUMBER
  ) RETURN BOOLEAN IS
    v_exists NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM t_product_prod_cat ppc
             WHERE ppc.t_product_id = par_product_id
               AND ppc.t_prod_category_id = par_category_id);
    RETURN v_exists = 1;
  END is_product_in_category;

  FUNCTION is_product_in_category
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN BOOLEAN IS
    v_category_id      t_prod_category.t_prod_category_id%TYPE;
    v_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
  BEGIN
    v_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    v_category_id      := dml_t_prod_category.id_by_t_prod_cate_type_id_brie(v_category_type_id
                                                                            ,par_category_brief);
  
    RETURN is_product_in_category(par_product_id => par_product_id, par_category_id => v_category_id);
  
  END is_product_in_category;

  FUNCTION is_product_in_category
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN BOOLEAN IS
    v_product_id t_product.product_id%TYPE;
  BEGIN
    v_product_id := dml_t_product.get_id_by_brief(par_product_brief);
  
    RETURN is_product_in_category(par_product_id          => v_product_id
                                 ,par_category_type_brief => par_category_type_brief
                                 ,par_category_brief      => par_category_brief);
  
  END is_product_in_category;

  /*
    Капля П.
    Получение списка ИД продуктов для категории
  */
  FUNCTION get_product_list(par_category_id NUMBER) RETURN dml_t_product.typ_prymary_key_nested_table
    PIPELINED IS
  BEGIN
    FOR rec IN (SELECT ppc.t_product_id
                  FROM t_product_prod_cat ppc
                 WHERE ppc.t_prod_category_id = par_category_id)
    LOOP
      PIPE ROW(rec.t_product_id);
    END LOOP;
    RETURN;
  END get_product_list;

  FUNCTION get_product_list
  (
    par_category_type_brief VARCHAR2
   ,par_category_brief      VARCHAR2
  ) RETURN dml_t_product.typ_prymary_key_nested_table
    PIPELINED IS
    v_prod_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
    v_category_id           t_prod_category.t_prod_category_id%TYPE;
  BEGIN
    v_prod_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    v_category_id           := dml_t_prod_category.id_by_t_prod_cate_type_id_brie(par_t_prod_category_type_id => v_prod_category_type_id
                                                                                 ,par_brief                   => par_category_brief);
  
    FOR rec IN (SELECT column_value FROM TABLE(get_product_list(v_category_id)))
    LOOP
      PIPE ROW(rec.column_value);
    END LOOP;
  
    RETURN;
  END get_product_list;

  /*
    Капля П.
    Добавление продукта в категоризатор
  */
  PROCEDURE add_product_to_category
  (
    par_product_id       NUMBER
   ,par_category_type_id NUMBER
   ,par_prod_category_id NUMBER
  ) IS
  BEGIN
  
    dml_t_product_prod_cat.insert_record(par_t_prod_category_id      => par_prod_category_id
                                        ,par_t_prod_category_type_id => par_category_type_id
                                        ,par_t_product_id            => par_product_id);
  END add_product_to_category;

  PROCEDURE add_product_to_category
  (
    par_product_id          NUMBER
   ,par_category_type_brief VARCHAR2
   ,par_prod_category_brief VARCHAR2
  ) IS
    v_category_type_id t_prod_category_type.t_prod_category_type_id%TYPE;
    v_category_id      t_prod_category.t_prod_category_id%TYPE;
  BEGIN
    v_category_type_id := dml_t_prod_category_type.get_id_by_brief(par_category_type_brief);
    v_category_id      := dml_t_prod_category.id_by_t_prod_cate_type_id_brie(v_category_type_id
                                                                            ,par_prod_category_brief);
    add_product_to_category(par_product_id       => par_product_id
                           ,par_category_type_id => v_category_type_id
                           ,par_prod_category_id => v_category_id);
  
  END add_product_to_category;

  PROCEDURE add_product_to_category
  (
    par_product_brief       VARCHAR2
   ,par_category_type_brief VARCHAR2
   ,par_prod_category_brief VARCHAR2
  ) IS
    v_product_id t_product.product_id%TYPE;
  BEGIN
    v_product_id := dml_t_product.get_id_by_brief(par_product_brief);
    add_product_to_category(par_product_id          => v_product_id
                           ,par_category_type_brief => par_category_type_brief
                           ,par_prod_category_brief => par_prod_category_brief);
  END add_product_to_category;

END pkg_product_category;
/

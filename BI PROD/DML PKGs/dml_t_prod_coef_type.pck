CREATE OR REPLACE PACKAGE dml_t_prod_coef_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_prod_coef_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_prod_coef_type.t_prod_coef_type_id%TYPE;

  FUNCTION get_record(par_t_prod_coef_type_id IN t_prod_coef_type.t_prod_coef_type_id%TYPE)
    RETURN t_prod_coef_type%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name                    IN t_prod_coef_type.name%TYPE
   ,par_func_define_type_id     IN t_prod_coef_type.func_define_type_id%TYPE
   ,par_factor_1                IN t_prod_coef_type.factor_1%TYPE DEFAULT NULL
   ,par_factor_2                IN t_prod_coef_type.factor_2%TYPE DEFAULT NULL
   ,par_factor_3                IN t_prod_coef_type.factor_3%TYPE DEFAULT NULL
   ,par_factor_4                IN t_prod_coef_type.factor_4%TYPE DEFAULT NULL
   ,par_factor_5                IN t_prod_coef_type.factor_5%TYPE DEFAULT NULL
   ,par_sub_t_prod_coef_type_id IN t_prod_coef_type.sub_t_prod_coef_type_id%TYPE DEFAULT NULL
   ,par_brief                   IN t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_comparator_1            IN t_prod_coef_type.comparator_1%TYPE DEFAULT NULL
   ,par_comparator_2            IN t_prod_coef_type.comparator_2%TYPE DEFAULT NULL
   ,par_comparator_3            IN t_prod_coef_type.comparator_3%TYPE DEFAULT NULL
   ,par_comparator_4            IN t_prod_coef_type.comparator_4%TYPE DEFAULT NULL
   ,par_comparator_5            IN t_prod_coef_type.comparator_5%TYPE DEFAULT NULL
   ,par_t_prod_coef_tariff_id   IN t_prod_coef_type.t_prod_coef_tariff_id%TYPE DEFAULT NULL
   ,par_r_sql                   IN t_prod_coef_type.r_sql%TYPE DEFAULT NULL
   ,par_factor_6                IN t_prod_coef_type.factor_6%TYPE DEFAULT NULL
   ,par_factor_7                IN t_prod_coef_type.factor_7%TYPE DEFAULT NULL
   ,par_factor_8                IN t_prod_coef_type.factor_8%TYPE DEFAULT NULL
   ,par_factor_9                IN t_prod_coef_type.factor_9%TYPE DEFAULT NULL
   ,par_factor_10               IN t_prod_coef_type.factor_10%TYPE DEFAULT NULL
   ,par_comparator_6            IN t_prod_coef_type.comparator_6%TYPE DEFAULT NULL
   ,par_comparator_7            IN t_prod_coef_type.comparator_7%TYPE DEFAULT NULL
   ,par_comparator_8            IN t_prod_coef_type.comparator_8%TYPE DEFAULT NULL
   ,par_comparator_9            IN t_prod_coef_type.comparator_9%TYPE DEFAULT NULL
   ,par_comparator_10           IN t_prod_coef_type.comparator_10%TYPE DEFAULT NULL
   ,par_note                    IN t_prod_coef_type.note%TYPE DEFAULT NULL
   ,par_is_default              IN t_prod_coef_type.is_default%TYPE DEFAULT 0
   ,par_is_ver_prod_coef        IN t_prod_coef_type.is_ver_prod_coef%TYPE DEFAULT 0
  );

  PROCEDURE insert_record
  (
    par_name                    IN t_prod_coef_type.name%TYPE
   ,par_func_define_type_id     IN t_prod_coef_type.func_define_type_id%TYPE
   ,par_factor_1                IN t_prod_coef_type.factor_1%TYPE DEFAULT NULL
   ,par_factor_2                IN t_prod_coef_type.factor_2%TYPE DEFAULT NULL
   ,par_factor_3                IN t_prod_coef_type.factor_3%TYPE DEFAULT NULL
   ,par_factor_4                IN t_prod_coef_type.factor_4%TYPE DEFAULT NULL
   ,par_factor_5                IN t_prod_coef_type.factor_5%TYPE DEFAULT NULL
   ,par_sub_t_prod_coef_type_id IN t_prod_coef_type.sub_t_prod_coef_type_id%TYPE DEFAULT NULL
   ,par_brief                   IN t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_comparator_1            IN t_prod_coef_type.comparator_1%TYPE DEFAULT NULL
   ,par_comparator_2            IN t_prod_coef_type.comparator_2%TYPE DEFAULT NULL
   ,par_comparator_3            IN t_prod_coef_type.comparator_3%TYPE DEFAULT NULL
   ,par_comparator_4            IN t_prod_coef_type.comparator_4%TYPE DEFAULT NULL
   ,par_comparator_5            IN t_prod_coef_type.comparator_5%TYPE DEFAULT NULL
   ,par_t_prod_coef_tariff_id   IN t_prod_coef_type.t_prod_coef_tariff_id%TYPE DEFAULT NULL
   ,par_r_sql                   IN t_prod_coef_type.r_sql%TYPE DEFAULT NULL
   ,par_factor_6                IN t_prod_coef_type.factor_6%TYPE DEFAULT NULL
   ,par_factor_7                IN t_prod_coef_type.factor_7%TYPE DEFAULT NULL
   ,par_factor_8                IN t_prod_coef_type.factor_8%TYPE DEFAULT NULL
   ,par_factor_9                IN t_prod_coef_type.factor_9%TYPE DEFAULT NULL
   ,par_factor_10               IN t_prod_coef_type.factor_10%TYPE DEFAULT NULL
   ,par_comparator_6            IN t_prod_coef_type.comparator_6%TYPE DEFAULT NULL
   ,par_comparator_7            IN t_prod_coef_type.comparator_7%TYPE DEFAULT NULL
   ,par_comparator_8            IN t_prod_coef_type.comparator_8%TYPE DEFAULT NULL
   ,par_comparator_9            IN t_prod_coef_type.comparator_9%TYPE DEFAULT NULL
   ,par_comparator_10           IN t_prod_coef_type.comparator_10%TYPE DEFAULT NULL
   ,par_note                    IN t_prod_coef_type.note%TYPE DEFAULT NULL
   ,par_is_default              IN t_prod_coef_type.is_default%TYPE DEFAULT 0
   ,par_is_ver_prod_coef        IN t_prod_coef_type.is_ver_prod_coef%TYPE DEFAULT 0
   ,par_t_prod_coef_type_id     OUT t_prod_coef_type.t_prod_coef_type_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_prod_coef_type%ROWTYPE);

  PROCEDURE delete_record(par_t_prod_coef_type_id IN t_prod_coef_type.t_prod_coef_type_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_prod_coef_type IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_prod_coef_type.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_prod_coef_type.t_prod_coef_type_id%TYPE IS
    v_id t_prod_coef_type.t_prod_coef_type_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_prod_coef_type_id INTO v_id FROM t_prod_coef_type WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Коэффициент страхового тарифа" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_prod_coef_type_id IN t_prod_coef_type.t_prod_coef_type_id%TYPE)
    RETURN t_prod_coef_type%ROWTYPE IS
    vr_record t_prod_coef_type%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_prod_coef_type WHERE t_prod_coef_type_id = par_t_prod_coef_type_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name                    IN t_prod_coef_type.name%TYPE
   ,par_func_define_type_id     IN t_prod_coef_type.func_define_type_id%TYPE
   ,par_factor_1                IN t_prod_coef_type.factor_1%TYPE DEFAULT NULL
   ,par_factor_2                IN t_prod_coef_type.factor_2%TYPE DEFAULT NULL
   ,par_factor_3                IN t_prod_coef_type.factor_3%TYPE DEFAULT NULL
   ,par_factor_4                IN t_prod_coef_type.factor_4%TYPE DEFAULT NULL
   ,par_factor_5                IN t_prod_coef_type.factor_5%TYPE DEFAULT NULL
   ,par_sub_t_prod_coef_type_id IN t_prod_coef_type.sub_t_prod_coef_type_id%TYPE DEFAULT NULL
   ,par_brief                   IN t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_comparator_1            IN t_prod_coef_type.comparator_1%TYPE DEFAULT NULL
   ,par_comparator_2            IN t_prod_coef_type.comparator_2%TYPE DEFAULT NULL
   ,par_comparator_3            IN t_prod_coef_type.comparator_3%TYPE DEFAULT NULL
   ,par_comparator_4            IN t_prod_coef_type.comparator_4%TYPE DEFAULT NULL
   ,par_comparator_5            IN t_prod_coef_type.comparator_5%TYPE DEFAULT NULL
   ,par_t_prod_coef_tariff_id   IN t_prod_coef_type.t_prod_coef_tariff_id%TYPE DEFAULT NULL
   ,par_r_sql                   IN t_prod_coef_type.r_sql%TYPE DEFAULT NULL
   ,par_factor_6                IN t_prod_coef_type.factor_6%TYPE DEFAULT NULL
   ,par_factor_7                IN t_prod_coef_type.factor_7%TYPE DEFAULT NULL
   ,par_factor_8                IN t_prod_coef_type.factor_8%TYPE DEFAULT NULL
   ,par_factor_9                IN t_prod_coef_type.factor_9%TYPE DEFAULT NULL
   ,par_factor_10               IN t_prod_coef_type.factor_10%TYPE DEFAULT NULL
   ,par_comparator_6            IN t_prod_coef_type.comparator_6%TYPE DEFAULT NULL
   ,par_comparator_7            IN t_prod_coef_type.comparator_7%TYPE DEFAULT NULL
   ,par_comparator_8            IN t_prod_coef_type.comparator_8%TYPE DEFAULT NULL
   ,par_comparator_9            IN t_prod_coef_type.comparator_9%TYPE DEFAULT NULL
   ,par_comparator_10           IN t_prod_coef_type.comparator_10%TYPE DEFAULT NULL
   ,par_note                    IN t_prod_coef_type.note%TYPE DEFAULT NULL
   ,par_is_default              IN t_prod_coef_type.is_default%TYPE DEFAULT 0
   ,par_is_ver_prod_coef        IN t_prod_coef_type.is_ver_prod_coef%TYPE DEFAULT 0
  ) IS
    v_id t_prod_coef_type.t_prod_coef_type_id%TYPE;
  BEGIN
    insert_record(par_name                    => par_name
                 ,par_func_define_type_id     => par_func_define_type_id
                 ,par_factor_1                => par_factor_1
                 ,par_factor_2                => par_factor_2
                 ,par_factor_3                => par_factor_3
                 ,par_factor_4                => par_factor_4
                 ,par_factor_5                => par_factor_5
                 ,par_sub_t_prod_coef_type_id => par_sub_t_prod_coef_type_id
                 ,par_brief                   => par_brief
                 ,par_comparator_1            => par_comparator_1
                 ,par_comparator_2            => par_comparator_2
                 ,par_comparator_3            => par_comparator_3
                 ,par_comparator_4            => par_comparator_4
                 ,par_comparator_5            => par_comparator_5
                 ,par_t_prod_coef_tariff_id   => par_t_prod_coef_tariff_id
                 ,par_r_sql                   => par_r_sql
                 ,par_factor_6                => par_factor_6
                 ,par_factor_7                => par_factor_7
                 ,par_factor_8                => par_factor_8
                 ,par_factor_9                => par_factor_9
                 ,par_factor_10               => par_factor_10
                 ,par_comparator_6            => par_comparator_6
                 ,par_comparator_7            => par_comparator_7
                 ,par_comparator_8            => par_comparator_8
                 ,par_comparator_9            => par_comparator_9
                 ,par_comparator_10           => par_comparator_10
                 ,par_note                    => par_note
                 ,par_is_default              => par_is_default
                 ,par_is_ver_prod_coef        => par_is_ver_prod_coef
                 ,par_t_prod_coef_type_id     => v_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_name                    IN t_prod_coef_type.name%TYPE
   ,par_func_define_type_id     IN t_prod_coef_type.func_define_type_id%TYPE
   ,par_factor_1                IN t_prod_coef_type.factor_1%TYPE DEFAULT NULL
   ,par_factor_2                IN t_prod_coef_type.factor_2%TYPE DEFAULT NULL
   ,par_factor_3                IN t_prod_coef_type.factor_3%TYPE DEFAULT NULL
   ,par_factor_4                IN t_prod_coef_type.factor_4%TYPE DEFAULT NULL
   ,par_factor_5                IN t_prod_coef_type.factor_5%TYPE DEFAULT NULL
   ,par_sub_t_prod_coef_type_id IN t_prod_coef_type.sub_t_prod_coef_type_id%TYPE DEFAULT NULL
   ,par_brief                   IN t_prod_coef_type.brief%TYPE DEFAULT NULL
   ,par_comparator_1            IN t_prod_coef_type.comparator_1%TYPE DEFAULT NULL
   ,par_comparator_2            IN t_prod_coef_type.comparator_2%TYPE DEFAULT NULL
   ,par_comparator_3            IN t_prod_coef_type.comparator_3%TYPE DEFAULT NULL
   ,par_comparator_4            IN t_prod_coef_type.comparator_4%TYPE DEFAULT NULL
   ,par_comparator_5            IN t_prod_coef_type.comparator_5%TYPE DEFAULT NULL
   ,par_t_prod_coef_tariff_id   IN t_prod_coef_type.t_prod_coef_tariff_id%TYPE DEFAULT NULL
   ,par_r_sql                   IN t_prod_coef_type.r_sql%TYPE DEFAULT NULL
   ,par_factor_6                IN t_prod_coef_type.factor_6%TYPE DEFAULT NULL
   ,par_factor_7                IN t_prod_coef_type.factor_7%TYPE DEFAULT NULL
   ,par_factor_8                IN t_prod_coef_type.factor_8%TYPE DEFAULT NULL
   ,par_factor_9                IN t_prod_coef_type.factor_9%TYPE DEFAULT NULL
   ,par_factor_10               IN t_prod_coef_type.factor_10%TYPE DEFAULT NULL
   ,par_comparator_6            IN t_prod_coef_type.comparator_6%TYPE DEFAULT NULL
   ,par_comparator_7            IN t_prod_coef_type.comparator_7%TYPE DEFAULT NULL
   ,par_comparator_8            IN t_prod_coef_type.comparator_8%TYPE DEFAULT NULL
   ,par_comparator_9            IN t_prod_coef_type.comparator_9%TYPE DEFAULT NULL
   ,par_comparator_10           IN t_prod_coef_type.comparator_10%TYPE DEFAULT NULL
   ,par_note                    IN t_prod_coef_type.note%TYPE DEFAULT NULL
   ,par_is_default              IN t_prod_coef_type.is_default%TYPE DEFAULT 0
   ,par_is_ver_prod_coef        IN t_prod_coef_type.is_ver_prod_coef%TYPE DEFAULT 0
   ,par_t_prod_coef_type_id     OUT t_prod_coef_type.t_prod_coef_type_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_prod_coef_type.nextval INTO par_t_prod_coef_type_id FROM dual;
    INSERT INTO t_prod_coef_type
      (t_prod_coef_type_id
      ,factor_1
      ,factor_2
      ,factor_3
      ,factor_4
      ,factor_5
      ,sub_t_prod_coef_type_id
      ,is_default
      ,is_ver_prod_coef
      ,brief
      ,comparator_1
      ,comparator_2
      ,comparator_3
      ,comparator_4
      ,comparator_5
      ,t_prod_coef_tariff_id
      ,r_sql
      ,factor_6
      ,factor_7
      ,factor_8
      ,factor_9
      ,factor_10
      ,comparator_6
      ,comparator_7
      ,comparator_8
      ,comparator_9
      ,comparator_10
      ,note
      ,func_define_type_id
      ,NAME)
    VALUES
      (par_t_prod_coef_type_id
      ,par_factor_1
      ,par_factor_2
      ,par_factor_3
      ,par_factor_4
      ,par_factor_5
      ,par_sub_t_prod_coef_type_id
      ,par_is_default
      ,par_is_ver_prod_coef
      ,par_brief
      ,par_comparator_1
      ,par_comparator_2
      ,par_comparator_3
      ,par_comparator_4
      ,par_comparator_5
      ,par_t_prod_coef_tariff_id
      ,par_r_sql
      ,par_factor_6
      ,par_factor_7
      ,par_factor_8
      ,par_factor_9
      ,par_factor_10
      ,par_comparator_6
      ,par_comparator_7
      ,par_comparator_8
      ,par_comparator_9
      ,par_comparator_10
      ,par_note
      ,par_func_define_type_id
      ,par_name);
  END insert_record;

  PROCEDURE update_record(par_record IN t_prod_coef_type%ROWTYPE) IS
  BEGIN
    UPDATE t_prod_coef_type
       SET NAME                    = par_record.name
          ,factor_1                = par_record.factor_1
          ,factor_2                = par_record.factor_2
          ,factor_3                = par_record.factor_3
          ,factor_4                = par_record.factor_4
          ,factor_5                = par_record.factor_5
          ,sub_t_prod_coef_type_id = par_record.sub_t_prod_coef_type_id
          ,is_default              = par_record.is_default
          ,is_ver_prod_coef        = par_record.is_ver_prod_coef
          ,brief                   = par_record.brief
          ,comparator_1            = par_record.comparator_1
          ,comparator_2            = par_record.comparator_2
          ,comparator_3            = par_record.comparator_3
          ,comparator_4            = par_record.comparator_4
          ,comparator_5            = par_record.comparator_5
          ,t_prod_coef_tariff_id   = par_record.t_prod_coef_tariff_id
          ,r_sql                   = par_record.r_sql
          ,factor_6                = par_record.factor_6
          ,factor_7                = par_record.factor_7
          ,factor_8                = par_record.factor_8
          ,factor_9                = par_record.factor_9
          ,factor_10               = par_record.factor_10
          ,comparator_6            = par_record.comparator_6
          ,comparator_7            = par_record.comparator_7
          ,comparator_8            = par_record.comparator_8
          ,comparator_9            = par_record.comparator_9
          ,comparator_10           = par_record.comparator_10
          ,note                    = par_record.note
          ,func_define_type_id     = par_record.func_define_type_id
     WHERE t_prod_coef_type_id = par_record.t_prod_coef_type_id;
  END update_record;

  PROCEDURE delete_record(par_t_prod_coef_type_id IN t_prod_coef_type.t_prod_coef_type_id%TYPE) IS
  BEGIN
    DELETE FROM t_prod_coef_type WHERE t_prod_coef_type_id = par_t_prod_coef_type_id;
  END delete_record;
END;
/

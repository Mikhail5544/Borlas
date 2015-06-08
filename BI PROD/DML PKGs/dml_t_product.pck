CREATE OR REPLACE PACKAGE dml_t_product IS

  FUNCTION get_entity_id RETURN entity.ent_id%TYPE;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_product.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_product.product_id%TYPE;

  FUNCTION get_rec_by_brief
  (
    par_brief          IN t_product.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_product%ROWTYPE;

  FUNCTION get_record(par_product_id IN t_product.product_id%TYPE) RETURN t_product%ROWTYPE;

  PROCEDURE insert_record
  (
    par_description                IN t_product.description%TYPE
   ,par_brief                      IN t_product.brief%TYPE
   ,par_enabled                    IN t_product.enabled%TYPE DEFAULT 1
   ,par_is_group                   IN t_product.is_group%TYPE DEFAULT 0
   ,par_asset_form                 IN t_product.asset_form%TYPE DEFAULT NULL
   ,par_department_id              IN t_product.department_id%TYPE DEFAULT NULL
   ,par_dept_role_id               IN t_product.dept_role_id%TYPE DEFAULT NULL
   ,par_claim_department_id        IN t_product.claim_department_id%TYPE DEFAULT NULL
   ,par_claim_dept_role_id         IN t_product.claim_dept_role_id%TYPE DEFAULT NULL
   ,par_t_policy_form_type_id      IN t_product.t_policy_form_type_id%TYPE DEFAULT NULL
   ,par_serial_policy              IN t_product.serial_policy%TYPE DEFAULT NULL
   ,par_t_product_group_id         IN t_product.t_product_group_id%TYPE DEFAULT NULL
   ,par_ins_amount_func_id         IN t_product.ins_amount_func_id%TYPE DEFAULT NULL
   ,par_custom_policy_calc_func_id IN t_product.custom_policy_calc_func_id%TYPE DEFAULT NULL
   ,par_bso_type_id                IN t_product.bso_type_id%TYPE DEFAULT NULL
   ,par_is_bso_polnum              IN t_product.is_bso_polnum%TYPE DEFAULT 0
   ,par_is_express                 IN t_product.is_express%TYPE DEFAULT 0
   ,par_use_ids_as_number          IN t_product.use_ids_as_number%TYPE DEFAULT 1
   ,par_is_quart                   IN t_product.is_quart%TYPE DEFAULT 0
  );

  PROCEDURE insert_record(par_record IN OUT t_product%ROWTYPE);

  PROCEDURE insert_record
  (
    par_description                IN t_product.description%TYPE
   ,par_brief                      IN t_product.brief%TYPE
   ,par_enabled                    IN t_product.enabled%TYPE DEFAULT 1
   ,par_is_group                   IN t_product.is_group%TYPE DEFAULT 0
   ,par_asset_form                 IN t_product.asset_form%TYPE DEFAULT NULL
   ,par_department_id              IN t_product.department_id%TYPE DEFAULT NULL
   ,par_dept_role_id               IN t_product.dept_role_id%TYPE DEFAULT NULL
   ,par_claim_department_id        IN t_product.claim_department_id%TYPE DEFAULT NULL
   ,par_claim_dept_role_id         IN t_product.claim_dept_role_id%TYPE DEFAULT NULL
   ,par_t_policy_form_type_id      IN t_product.t_policy_form_type_id%TYPE DEFAULT NULL
   ,par_serial_policy              IN t_product.serial_policy%TYPE DEFAULT NULL
   ,par_t_product_group_id         IN t_product.t_product_group_id%TYPE DEFAULT NULL
   ,par_ins_amount_func_id         IN t_product.ins_amount_func_id%TYPE DEFAULT NULL
   ,par_custom_policy_calc_func_id IN t_product.custom_policy_calc_func_id%TYPE DEFAULT NULL
   ,par_bso_type_id                IN t_product.bso_type_id%TYPE DEFAULT NULL
   ,par_is_bso_polnum              IN t_product.is_bso_polnum%TYPE DEFAULT 0
   ,par_is_express                 IN t_product.is_express%TYPE DEFAULT 0
   ,par_use_ids_as_number          IN t_product.use_ids_as_number%TYPE DEFAULT 1
   ,par_is_quart                   IN t_product.is_quart%TYPE DEFAULT 0
   ,par_product_id                 OUT t_product.product_id%TYPE
  );

  PROCEDURE update_record(par_record IN t_product%ROWTYPE);

  PROCEDURE delete_record(par_product_id IN t_product.product_id%TYPE);

  PROCEDURE lock_record(par_product_id IN t_product.product_id%TYPE);
END dml_t_product;
/
CREATE OR REPLACE PACKAGE BODY dml_t_product IS

  gc_entity_id CONSTANT entity.ent_id%TYPE := ent.id_by_brief('T_PRODUCT');

  FUNCTION get_entity_id RETURN entity.ent_id%TYPE IS
  BEGIN
    RETURN gc_entity_id;
  END get_entity_id;

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_product.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_product.product_id%TYPE IS
    v_id t_product.product_id%TYPE;
  BEGIN
    BEGIN
      SELECT product_id INTO v_id FROM t_product WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Страховой продукт" по значению поля "Сокращение": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_rec_by_brief
  (
    par_brief          IN t_product.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_product%ROWTYPE IS
    v_record t_product%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO v_record FROM t_product WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Страховой продукт" по значению поля "Сокращение": ' ||
                   par_brief);
        END IF;
    END;
    RETURN v_record;
  END get_rec_by_brief;

  FUNCTION get_record(par_product_id IN t_product.product_id%TYPE) RETURN t_product%ROWTYPE IS
    vr_record t_product%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_product WHERE product_id = par_product_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description                IN t_product.description%TYPE
   ,par_brief                      IN t_product.brief%TYPE
   ,par_enabled                    IN t_product.enabled%TYPE DEFAULT 1
   ,par_is_group                   IN t_product.is_group%TYPE DEFAULT 0
   ,par_asset_form                 IN t_product.asset_form%TYPE DEFAULT NULL
   ,par_department_id              IN t_product.department_id%TYPE DEFAULT NULL
   ,par_dept_role_id               IN t_product.dept_role_id%TYPE DEFAULT NULL
   ,par_claim_department_id        IN t_product.claim_department_id%TYPE DEFAULT NULL
   ,par_claim_dept_role_id         IN t_product.claim_dept_role_id%TYPE DEFAULT NULL
   ,par_t_policy_form_type_id      IN t_product.t_policy_form_type_id%TYPE DEFAULT NULL
   ,par_serial_policy              IN t_product.serial_policy%TYPE DEFAULT NULL
   ,par_t_product_group_id         IN t_product.t_product_group_id%TYPE DEFAULT NULL
   ,par_ins_amount_func_id         IN t_product.ins_amount_func_id%TYPE DEFAULT NULL
   ,par_custom_policy_calc_func_id IN t_product.custom_policy_calc_func_id%TYPE DEFAULT NULL
   ,par_bso_type_id                IN t_product.bso_type_id%TYPE DEFAULT NULL
   ,par_is_bso_polnum              IN t_product.is_bso_polnum%TYPE DEFAULT 0
   ,par_is_express                 IN t_product.is_express%TYPE DEFAULT 0
   ,par_use_ids_as_number          IN t_product.use_ids_as_number%TYPE DEFAULT 1
   ,par_is_quart                   IN t_product.is_quart%TYPE DEFAULT 0
  ) IS
    v_id t_product.product_id%TYPE;
  BEGIN
    insert_record(par_description                => par_description
                 ,par_brief                      => par_brief
                 ,par_enabled                    => par_enabled
                 ,par_is_group                   => par_is_group
                 ,par_asset_form                 => par_asset_form
                 ,par_department_id              => par_department_id
                 ,par_dept_role_id               => par_dept_role_id
                 ,par_claim_department_id        => par_claim_department_id
                 ,par_claim_dept_role_id         => par_claim_dept_role_id
                 ,par_t_policy_form_type_id      => par_t_policy_form_type_id
                 ,par_serial_policy              => par_serial_policy
                 ,par_t_product_group_id         => par_t_product_group_id
                 ,par_ins_amount_func_id         => par_ins_amount_func_id
                 ,par_custom_policy_calc_func_id => par_custom_policy_calc_func_id
                 ,par_bso_type_id                => par_bso_type_id
                 ,par_is_bso_polnum              => par_is_bso_polnum
                 ,par_is_express                 => par_is_express
                 ,par_use_ids_as_number          => par_use_ids_as_number
                 ,par_is_quart                   => par_is_quart
                 ,par_product_id                 => v_id);
  
  END insert_record;

  PROCEDURE insert_record(par_record IN OUT t_product%ROWTYPE) IS
  BEGIN
    insert_record(par_description                => par_record.description
                 ,par_brief                      => par_record.brief
                 ,par_enabled                    => par_record.enabled
                 ,par_is_group                   => par_record.is_group
                 ,par_asset_form                 => par_record.asset_form
                 ,par_department_id              => par_record.department_id
                 ,par_dept_role_id               => par_record.dept_role_id
                 ,par_claim_department_id        => par_record.claim_department_id
                 ,par_claim_dept_role_id         => par_record.claim_dept_role_id
                 ,par_t_policy_form_type_id      => par_record.t_policy_form_type_id
                 ,par_serial_policy              => par_record.serial_policy
                 ,par_t_product_group_id         => par_record.t_product_group_id
                 ,par_ins_amount_func_id         => par_record.ins_amount_func_id
                 ,par_custom_policy_calc_func_id => par_record.custom_policy_calc_func_id
                 ,par_bso_type_id                => par_record.bso_type_id
                 ,par_is_bso_polnum              => par_record.is_bso_polnum
                 ,par_is_express                 => par_record.is_express
                 ,par_use_ids_as_number          => par_record.use_ids_as_number
                 ,par_is_quart                   => par_record.is_quart
                 ,par_product_id                 => par_record.product_id);
  
  END insert_record;

  PROCEDURE insert_record
  (
    par_description                IN t_product.description%TYPE
   ,par_brief                      IN t_product.brief%TYPE
   ,par_enabled                    IN t_product.enabled%TYPE DEFAULT 1
   ,par_is_group                   IN t_product.is_group%TYPE DEFAULT 0
   ,par_asset_form                 IN t_product.asset_form%TYPE DEFAULT NULL
   ,par_department_id              IN t_product.department_id%TYPE DEFAULT NULL
   ,par_dept_role_id               IN t_product.dept_role_id%TYPE DEFAULT NULL
   ,par_claim_department_id        IN t_product.claim_department_id%TYPE DEFAULT NULL
   ,par_claim_dept_role_id         IN t_product.claim_dept_role_id%TYPE DEFAULT NULL
   ,par_t_policy_form_type_id      IN t_product.t_policy_form_type_id%TYPE DEFAULT NULL
   ,par_serial_policy              IN t_product.serial_policy%TYPE DEFAULT NULL
   ,par_t_product_group_id         IN t_product.t_product_group_id%TYPE DEFAULT NULL
   ,par_ins_amount_func_id         IN t_product.ins_amount_func_id%TYPE DEFAULT NULL
   ,par_custom_policy_calc_func_id IN t_product.custom_policy_calc_func_id%TYPE DEFAULT NULL
   ,par_bso_type_id                IN t_product.bso_type_id%TYPE DEFAULT NULL
   ,par_is_bso_polnum              IN t_product.is_bso_polnum%TYPE DEFAULT 0
   ,par_is_express                 IN t_product.is_express%TYPE DEFAULT 0
   ,par_use_ids_as_number          IN t_product.use_ids_as_number%TYPE DEFAULT 1
   ,par_is_quart                   IN t_product.is_quart%TYPE DEFAULT 0
   ,par_product_id                 OUT t_product.product_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_product.nextval INTO par_product_id FROM dual;
    INSERT INTO t_product
      (product_id
      ,is_express
      ,is_quart
      ,description
      ,enabled
      ,brief
      ,asset_form
      ,bso_type_id
      ,department_id
      ,dept_role_id
      ,claim_department_id
      ,claim_dept_role_id
      ,t_policy_form_type_id
      ,serial_policy
      ,is_group
      ,is_bso_polnum
      ,t_product_group_id
      ,ins_amount_func_id
      ,custom_policy_calc_func_id
      ,use_ids_as_number)
    VALUES
      (par_product_id
      ,par_is_express
      ,par_is_quart
      ,par_description
      ,par_enabled
      ,par_brief
      ,par_asset_form
      ,par_bso_type_id
      ,par_department_id
      ,par_dept_role_id
      ,par_claim_department_id
      ,par_claim_dept_role_id
      ,par_t_policy_form_type_id
      ,par_serial_policy
      ,par_is_group
      ,par_is_bso_polnum
      ,par_t_product_group_id
      ,par_ins_amount_func_id
      ,par_custom_policy_calc_func_id
      ,par_use_ids_as_number);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record(par_record IN t_product%ROWTYPE) IS
  BEGIN
    UPDATE t_product
       SET custom_policy_calc_func_id = par_record.custom_policy_calc_func_id
          ,use_ids_as_number          = par_record.use_ids_as_number
          ,is_quart                   = par_record.is_quart
          ,description                = par_record.description
          ,enabled                    = par_record.enabled
          ,brief                      = par_record.brief
          ,asset_form                 = par_record.asset_form
          ,bso_type_id                = par_record.bso_type_id
          ,department_id              = par_record.department_id
          ,dept_role_id               = par_record.dept_role_id
          ,claim_department_id        = par_record.claim_department_id
          ,claim_dept_role_id         = par_record.claim_dept_role_id
          ,t_policy_form_type_id      = par_record.t_policy_form_type_id
          ,serial_policy              = par_record.serial_policy
          ,is_group                   = par_record.is_group
          ,is_bso_polnum              = par_record.is_bso_polnum
          ,t_product_group_id         = par_record.t_product_group_id
          ,ins_amount_func_id         = par_record.ins_amount_func_id
          ,is_express                 = par_record.is_express
     WHERE product_id = par_record.product_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record(par_product_id IN t_product.product_id%TYPE) IS
  BEGIN
    DELETE FROM t_product WHERE product_id = par_product_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;

  PROCEDURE lock_record(par_product_id IN t_product.product_id%TYPE) IS
    v_dummy t_product.product_id%TYPE;
  BEGIN
  
    assert(par_product_id IS NULL
          ,'Запись для блокировки должна быть указана');
  
    SELECT product_id INTO v_dummy FROM t_product WHERE product_id = par_product_id FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN pkg_oracle_exceptions.resource_busy_nowait THEN
      ex.raise('Не удалось заблонировать запись в таблице "Страховой продукт"');
    WHEN no_data_found THEN
      ex.raise('Не удалось найти запись для блокировки в таблице "Страховой продукт"');
    WHEN OTHERS THEN
      ex.raise;
  END lock_record;
END dml_t_product;
/

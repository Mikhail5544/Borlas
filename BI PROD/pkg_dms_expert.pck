CREATE OR REPLACE PACKAGE pkg_dms_expert IS

  -- найти застрахованного
  --function Find_As_Person_Med(par_service_med_id number) return number;
  -- найти услугу из прейскуранта
  -- function Find_Dms_Price(par_service_med_id number) return number;
  --проверить, может ли быть застрахованный обслуживаться по данному договору
  FUNCTION Is_Invalid_Date_Range
  (
    par_service_med_id   NUMBER
   ,par_as_person_med_id NUMBER
  ) RETURN NUMBER;
  --проверить, соответствует ли заявленна цена услуги прейскуранту
  FUNCTION Is_Invalid_Serv_Price
  (
    par_service_med_id NUMBER
   ,par_dms_price_id   NUMBER
  ) RETURN NUMBER;
  --найти страховую программу, по которой обслуживается застрахованный
  FUNCTION Find_Dms_Ins_Prg
  (
    par_service_med_id   NUMBER
   ,par_as_person_med_id NUMBER
   ,par_dms_price_id     NUMBER
  ) RETURN NUMBER;

  --получить количество по услуге, вошедшее в акты экспертиз
  --если direction > 0 то возвращается значение без учета данного акта
  FUNCTION Get_Expert_Count
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
   ,direction          NUMBER DEFAULT 0
  ) RETURN NUMBER;
  --получить сумму по услуге, вошедшее в акты экспертиз
  --если direction > 0 то возвращается значение без учета данного акта
  FUNCTION Get_Expert_Amount
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
   ,direction          NUMBER DEFAULT 0
  ) RETURN NUMBER;

  --получить сумму по содержимому реестра
  FUNCTION Get_Dms_Serv_Reg_Amount
  (
    p_dms_serv_reg_id NUMBER
   ,p_amount_type     VARCHAR2
  ) RETURN NUMBER;
  --получить количество по услуге, подлежащее оплате
  FUNCTION Get_Fact_Count
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  --получить сумму по услуге, подлежащую оплате
  FUNCTION Get_Fact_Amount
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  --показать, входит ли оказанная услуга в какой-либо акт экспертизы
  FUNCTION is_in_dms_act
  (
    p_c_service_med_id IN NUMBER
   ,p_type             IN VARCHAR2
  ) RETURN NUMBER;
  -- показать, входит ли оказанная услуга в  акт(ы) медицинской экспертизы
  FUNCTION is_in_dms_med_act
  (
    p_c_service_med_id IN NUMBER
   ,p_act              IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  -- показать, входит ли оказанная услуга в конкретный акт или в любой акт экспертизы
  --(необязательно действующий)
  FUNCTION is_in_dms_act_all
  (
    p_c_service_med_id IN NUMBER
   ,p_act              IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;
  /**
   * провести экспертизу по оказанной услуге
   * @param p_c_service_med_id ИД оказанной услуги
  **/
  FUNCTION check_c_service_med
  (
    p_c_service_med_id NUMBER
   ,p_create_act       IN NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  FUNCTION med_expert
  (
    p_c_service_med_id   IN NUMBER
   ,p_med_expert_type_id IN NUMBER
   ,p_dms_mkb_id         IN NUMBER
   ,p_is_not_med         IN NUMBER
   ,p_count_med_exp      IN NUMBER
   ,p_amount_med_exp     IN NUMBER
   ,p_act_note           IN VARCHAR2
  ) RETURN VARCHAR2;

  -- провести экспертизу по всему реестру
  FUNCTION check_dms_serv_reg
  (
    p_dms_serv_reg_id NUMBER
   ,p_create_act      IN NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  FUNCTION get_amount_by_kind
  (
    p_dms_serv_reg_id IN NUMBER
   ,p_kind            IN VARCHAR2
  ) RETURN NUMBER;
  PROCEDURE get_sum_amount
  (
    p_dms_serv_reg_id IN NUMBER
   ,p_plan_amount     OUT NUMBER
   ,p_fact_amount     OUT NUMBER
   ,p_exp_amount      OUT NUMBER
   ,p_undef_amount    OUT NUMBER
  );

  /**
   * Признак прохождения ТЭ всех услуг реестра
   * @param p_dms_serv_reg_id ИД реестра
   * @return признак 0 - есть услуги, не прошедшие ТЭ; 1 - все услуги реестра прошли ТЭ
  **/
  FUNCTION check_is_all_tech(p_dms_serv_reg_id IN NUMBER) RETURN NUMBER;

  /**
   * Признак удачного прохождения услугой технической экспертизы
   * @param c_service_med_id ИД реестра
   * @return признак 0 - услуга не прошла ТЭ; 1 - услуга прошла ТЭ
  **/
  FUNCTION check_is_tech_auto(p_c_service_med_id IN NUMBER) RETURN NUMBER;

END Pkg_Dms_Expert;
/
CREATE OR REPLACE PACKAGE BODY PKG_DMS_EXPERT IS

  FUNCTION get_param(p_field IN VARCHAR2) RETURN BOOLEAN IS
    v_ret_val  BOOLEAN;
    v_is_param NUMBER;
  
    CURSOR cur_find IS
      SELECT COUNT(apv.app_param_val_id)
        FROM ven_app_param     ap
            ,ven_app_param_val apv
       WHERE UPPER(apv.user_name) = UPPER(USER)
         AND apv.app_param_id = ap.app_param_id
         AND ap.brief = 'DMS_TE_FIELD';
  
    CURSOR cur_param(pc_field VARCHAR2) IS
      SELECT DECODE(COUNT(app_param_val_id), 0, 0, 1)
        FROM ven_app_param_val
       WHERE UPPER(user_name) = UPPER(USER)
         AND UPPER(val_c) = UPPER(pc_field);
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_is_param;
    IF cur_find%NOTFOUND
    THEN
      v_is_param := NULL;
    END IF;
    CLOSE cur_find;
  
    IF v_is_param IS NULL
    THEN
      RETURN(TRUE);
    END IF;
  
    OPEN cur_param(p_field);
    FETCH cur_param
      INTO v_is_param;
    IF cur_param%NOTFOUND
    THEN
      v_ret_val := FALSE;
    ELSE
      IF v_is_param = 0
      THEN
        v_ret_val := FALSE;
      ELSE
        v_ret_val := TRUE;
      END IF;
    END IF;
    CLOSE cur_param;
  
    RETURN(v_ret_val);
  END;
  -- найти застрахованного
  /*  function Find_As_Person_Med(par_service_med_id number) return number is
    v_result number;
    v_csm c_service_med%rowtype;
  begin
    select * into v_csm from c_service_med t where t.c_service_med_id = par_service_med_id;
    begin
      select vapm.as_person_med_id
      into   v_result
      from   ven_as_person_med vapm, contact c
      where  vapm.cn_person_id = c.contact_id and
             trim(c.name || ' ' || c.first_name || ' ' || c.middle_name) = v_csm.as_assured_name and
             vapm.card_num = v_csm.bso_num;
    exception when others then
      v_result := null;
      insert into dms_err de
        (
         de.dms_err_id,
         de.c_service_med_id,
         de.dms_err_type_id,
         de.note
        )
      values
        (
         sq_dms_err.nextval,
         v_csm.c_service_med_id,
         (select det.dms_err_type_id from dms_err_type det where det.name = 'Критическая'),
         'Не найден застрахованный'
        );
    end;
    return v_result;
  end;*/

  -- найти услугу из прейскуранта
  /*  function Find_Dms_Price(par_service_med_id number) return number is
    v_result number;
    v_csm c_service_med%rowtype;
    v_contract_lpu_ver_id number;
  begin
    select * into v_csm from c_service_med t where t.c_service_med_id = par_service_med_id;
    select dsa.contract_lpu_ver_id
    into   v_contract_lpu_ver_id
    from   dms_serv_reg dsr, dms_serv_act dsa
    where  dsr.dms_serv_reg_id = v_csm.dms_serv_reg_id and
           dsr.dms_serv_act_id = dsa.dms_serv_act_id;
    begin
      select dp.dms_price_id
      into   v_result
      from   dms_price dp
      where  dp.code = v_csm.service_code and
             dp.name = v_csm.service_name and
             dp.contract_lpu_ver_id = v_contract_lpu_ver_id;
    exception when others then
      v_result := null;
      insert into dms_err de
        (
         de.dms_err_id,
         de.c_service_med_id,
         de.dms_err_type_id,
         de.note
        )
      values
        (
         sq_dms_err.nextval,
         v_csm.c_service_med_id,
         (select det.dms_err_type_id from dms_err_type det where det.name = 'Критическая'),
         'Не найдена услуга из прейскуранта'
        );
    end;
    return v_result;
  end;*/

  --проверить, может ли быть застрахованный обслуживаться по данному договору
  FUNCTION Is_Invalid_Date_Range
  (
    par_service_med_id   NUMBER
   ,par_as_person_med_id NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_csm    C_SERVICE_MED%ROWTYPE;
    v_id     NUMBER;
  BEGIN
    SELECT * INTO v_csm FROM C_SERVICE_MED t WHERE t.c_service_med_id = par_service_med_id;
    BEGIN
      SELECT vapm.as_person_med_id
        INTO v_id
        FROM ven_as_person_med vapm
       WHERE vapm.start_date <= v_csm.service_date
         AND vapm.end_date >= v_csm.service_date
         AND vapm.as_person_med_id = par_as_person_med_id;
      v_result := 0;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 1;
        INSERT INTO DMS_ERR de
          (de.dms_err_id, de.c_service_med_id, de.dms_err_type_id, de.note)
        VALUES
          (sq_dms_err.NEXTVAL
          ,v_csm.c_service_med_id
          ,(SELECT det.dms_err_type_id FROM DMS_ERR_TYPE det WHERE det.NAME = 'Критическая')
          ,'Дата оказания услуги не попадает в срок действия варианта страхования');
    END;
    RETURN v_result;
  END;

  --проверить, соответствует ли заявленна цена услуги прейскуранту
  FUNCTION Is_Invalid_Serv_Price
  (
    par_service_med_id NUMBER
   ,par_dms_price_id   NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
    v_csm    C_SERVICE_MED%ROWTYPE;
    v_id     NUMBER;
  BEGIN
    SELECT * INTO v_csm FROM C_SERVICE_MED t WHERE t.c_service_med_id = par_service_med_id;
    BEGIN
      SELECT dp.dms_price_id
        INTO v_id
        FROM DMS_PRICE dp
       WHERE dp.dms_price_id = par_dms_price_id
         AND ROUND(dp.amount * v_csm.count_plan * 100) / 100 = ROUND(v_csm.amount_plan * 100) / 100;
      v_result := 0;
    EXCEPTION
      WHEN OTHERS THEN
        v_result := 1;
        INSERT INTO DMS_ERR de
          (de.dms_err_id, de.c_service_med_id, de.dms_err_type_id, de.note)
        VALUES
          (sq_dms_err.NEXTVAL
          ,par_service_med_id
          ,(SELECT det.dms_err_type_id FROM DMS_ERR_TYPE det WHERE det.NAME = 'Критическая')
          ,'Стоимость услуги не соответствует действующему прейскуранту');
    END;
    RETURN v_result;
  END;

  --найти страховую программу, по которой обслуживается застрахованный
  FUNCTION Find_Dms_Ins_Prg
  (
    par_service_med_id   NUMBER
   ,par_as_person_med_id NUMBER
   ,par_dms_price_id     NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    /*
    begin
      select divp.dms_ins_prg_id
      into   v_result
      from   ven_as_person_med vapm,
             dms_price dp,
             dms_ins_var_prg divp,
             dms_rel_ins_prg_aid dripa
      where  vapm.as_person_med_id = par_as_person_med_id and
             dp.dms_price_id = par_dms_price_id and
             vapm.dms_ins_var_id = divp.dms_ins_var_id and
             divp.dms_ins_prg_id = dripa.dms_ins_prg_id and
             dripa.dms_aid_type_id = dp.dms_aid_type_id;
    exception when others then
      v_result := null;
      insert into dms_err de
        (
         de.dms_err_id,
         de.c_service_med_id,
         de.dms_err_type_id,
         de.note
        )
      values
        (
         sq_dms_err.nextval,
         par_service_med_id,
         (select det.dms_err_type_id from dms_err_type det where det.name = 'Критическая'),
         'Застрахованный не может получить данную услугу по своему варианту'
        );
    end;
    */
    v_result := NULL;
    RETURN v_result;
  END;

  -- поиск застрахованного по ФИО и номеру полиса
  FUNCTION find_as_assured
  (
    p_last_name   IN VARCHAR2
   ,p_first_name  IN VARCHAR2
   ,p_middle_name IN VARCHAR2
   ,p_card_num    IN VARCHAR2
   ,p_count       IN OUT NUMBER
  ) RETURN NUMBER IS
    v_ret_val     NUMBER;
    v_count       NUMBER;
    v_card_num    NUMBER;
    v_last_name   NUMBER;
    v_first_name  NUMBER;
    v_middle_name NUMBER;
  
    --исправил Д.Сыровецкий
    /*cursor cur_find is select asr.as_assured_id,
                               count(asr.as_assured_id) over()
                          from ven_as_assured asr,
                               ven_as_asset ast,
                               ven_contact c
                         where (upper(asr.card_num) = upper(p_card_num) or v_card_num is null)
                           and asr.as_assured_id = ast.as_asset_id
                           and ast.contact_id = c.contact_id
                           and (upper(c.middle_name) = upper(p_middle_name) or v_middle_name is null)
                           and (upper(c.first_name) = upper(p_first_name) or v_first_name is null)
                           and (upper(c.name) = upper(p_last_name) or v_last_name is null);
       --Добавил Д.Сыровецкий
    CURSOR cur_find IS SELECT asr.as_assured_id,
                               COUNT(asr.as_assured_id) over()
                          FROM ven_as_assured asr,
                               ven_as_asset ast,
                               ven_contact c
                         WHERE (NVL(UPPER(asr.card_num),'-1') = NVL(UPPER(p_card_num),'-1') OR v_card_num IS NULL)
                           AND asr.as_assured_id = ast.as_asset_id
                           AND ast.contact_id = c.contact_id
                           AND (NVL(UPPER(c.middle_name),'-1') = NVL(UPPER(p_middle_name),'-1') OR v_middle_name IS NULL)
                           AND (NVL(UPPER(c.first_name),'-1') = NVL(UPPER(p_first_name),'-1') OR v_first_name IS NULL)
                           AND (NVL(UPPER(c.name),'-1') = NVL(UPPER(p_last_name),'-1') OR v_last_name IS NULL);*/
  BEGIN
    IF get_param('CARD_NUM')
    THEN
      v_card_num := 1;
    ELSE
      v_card_num := NULL;
    END IF;
    IF get_param('AS_ASSURED_LAST_NAME')
    THEN
      v_last_name := 1;
    ELSE
      v_last_name := NULL;
    END IF;
    IF get_param('AS_ASSURED_FIRST_NAME')
    THEN
      v_first_name := 1;
    ELSE
      v_first_name := NULL;
    END IF;
    IF get_param('AS_ASSURED_MIDDLE_NAME')
    THEN
      v_middle_name := 1;
    ELSE
      v_middle_name := NULL;
    END IF;
  
    v_ret_val := NULL;
  
    --добавил Д.Сыровецкий
    IF v_card_num IS NULL
       AND v_last_name IS NULL
    THEN
      p_count := 2;
      --Имя и отчество проверять нет смысла, если не нужно проверять полис и фамилию
      RETURN v_ret_val;
    END IF;
  
    IF NVL(p_last_name, p_card_num) IS NULL
    THEN
      -- пользователь не указал ни полис, ни фамилию
      p_count := 2;
      RETURN v_ret_val;
    END IF;
  
    --Исправил Д.Сыровецкий
    /*OPEN cur_find;
    FETCH cur_find INTO v_ret_val, v_count;
    IF cur_find%NOTFOUND THEN
      v_ret_val := NULL;
      v_count := 0;
    END IF;
    CLOSE cur_find;*/
  
    --raise_application_error(-20000, v_middle_name);
  
    BEGIN
      SELECT asr.as_assured_id
        INTO v_ret_val
        FROM ven_as_assured   asr
            ,ven_contact      c
            ,ven_p_pol_header pph
       WHERE pph.policy_id = asr.p_policy_id
         AND asr.assured_contact_id = c.contact_id
         AND (NVL(UPPER(asr.card_num), '-1') = UPPER(p_card_num) OR v_card_num IS NULL)
         AND (NVL(UPPER(c.middle_name), '-1') = UPPER(p_middle_name) OR v_middle_name IS NULL)
         AND (NVL(UPPER(c.first_name), '-1') = UPPER(p_first_name) OR v_first_name IS NULL)
         AND (NVL(UPPER(c.NAME), '-1') = UPPER(p_last_name) OR v_last_name IS NULL);
      v_count := 1;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        v_count   := 3;
        v_ret_val := NULL;
      WHEN NO_DATA_FOUND THEN
        v_count   := 0;
        v_ret_val := NULL;
    END;
    --конец исправления
  
    p_count := v_count;
    RETURN(v_ret_val);
  END;

  --убирает пробелы и нули слева у строки
  FUNCTION trunc_str(p_code IN VARCHAR2) RETURN VARCHAR2 IS
    v_code VARCHAR2(255) := p_code;
  BEGIN
    v_code := TRIM(v_code);
    LOOP
      IF SUBSTR(v_code, 1, 1) <> '0'
      THEN
        EXIT;
      ELSE
        IF LENGTH(v_code) = 1
        THEN
          v_code := '';
          EXIT;
        END IF;
        v_code := SUBSTR(v_code, 2);
      END IF;
    END LOOP;
    RETURN v_code;
  END;

  -- поиск услуги в прайсе ЛПУ
  FUNCTION find_dms_price
  (
    p_c_service_med_id IN NUMBER
   ,p_price_code       IN VARCHAR2
   ,p_price_name       IN VARCHAR2
   ,p_dms_price_cost   OUT NUMBER
   ,p_dms_aid_type     OUT NUMBER
   ,p_is_not_ins       OUT NUMBER
   ,p_is_not_med       OUT NUMBER
  ) RETURN NUMBER IS
    v_ret_val         NUMBER;
    v_is_service_code NUMBER;
    v_is_service_name NUMBER;
    v_cod             VARCHAR2(255);
  
    CURSOR cur_find IS
      SELECT dp.dms_price_id
            ,dp.amount
            ,dp.dms_aid_type_id
            ,dp.code
            ,dp.is_not_ins
            ,dp.is_not_med
        FROM ven_c_service_med    sm
            ,ven_dms_serv_reg     dsr
            ,ven_doc_doc          dd1
            ,ven_doc_doc          dd2
            ,ven_ac_payment       ap
            ,ven_contract_lpu_ver clv
            ,ven_dms_price        dp
       WHERE dp.contract_lpu_ver_id = clv.contract_lpu_ver_id
         AND (NVL(UPPER(dp.NAME), '-1') = NVL(UPPER(p_price_name), '-1') OR v_is_service_name IS NULL)
         AND (NVL(UPPER(dp.code), '-1') = NVL(UPPER(p_price_code), '-1') OR v_is_service_code IS NULL)
         AND clv.contract_lpu_ver_id = dd2.parent_id
         AND dd2.child_id = ap.payment_id
         AND ap.payment_id = dd1.parent_id
         AND dd1.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = sm.dms_serv_reg_id
         AND sm.c_service_med_id = p_c_service_med_id;
  
  BEGIN
    IF get_param('SERVICE_CODE')
    THEN
      v_is_service_code := 1;
    ELSE
      v_is_service_code := NULL;
    END IF;
    IF get_param('SERVICE_NAME')
    THEN
      v_is_service_name := 1;
    ELSE
      v_is_service_name := NULL;
    END IF;
  
    --Добавил Д.Сыровецкий
    IF v_is_service_code IS NULL
       AND v_is_service_name IS NULL
    THEN
      RETURN NULL;
    END IF;
  
    OPEN cur_find;
    FETCH cur_find
      INTO v_ret_val
          ,p_dms_price_cost
          ,p_dms_aid_type
          ,v_cod
          ,p_is_not_ins
          ,p_is_not_med;
    IF cur_find%NOTFOUND
    THEN
      v_ret_val        := NULL;
      p_dms_price_cost := NULL;
      p_dms_aid_type   := NULL;
      p_is_not_ins     := 0;
      p_is_not_med     := 0;
      /*ELSE
      if (upper(trunc_str(v_cod)) <> upper(trunc_str(p_price_code))) and v_is_service_code = 1 then
        v_ret_val := NULL;
        p_dms_price_cost := NULL;
        p_dms_aid_type := NULL;
      end if;*/
    END IF;
    CLOSE cur_find;
    RETURN(v_ret_val);
  END;

  -- запись ошибки
  PROCEDURE save_dms_err
  (
    p_c_service_med_id IN NUMBER
   ,p_dms_err_type_id  IN NUMBER
   ,p_note             IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO ven_dms_err
      (dms_err_id, c_service_med_id, dms_err_type_id, note)
    VALUES
      (sq_dms_err.NEXTVAL, p_c_service_med_id, p_dms_err_type_id, NVL(p_note, 'неизвестно'));
  END;

  -- мог ли застрахованный получить данную помощь в рамках варианта страхования
  FUNCTION find_damage_code
  (
    p_as_asset_id  IN NUMBER
   ,p_dms_price_id IN NUMBER
   ,p_lpu_id       IN NUMBER
   ,p_serv_date    IN DATE
   ,err_mess       OUT VARCHAR2 /*, p_peril_id OUT VARCHAR2*/
  ) RETURN NUMBER IS
    v_ret_val          NUMBER := 1;
    v_start_date       DATE;
    v_end_date         DATE;
    v_t_damage_code_id NUMBER;
    v_t_peril_id       NUMBER;
    v_is_peril         NUMBER := 0;
    v_is_damage        NUMBER := 0;
    v_is_lpu           NUMBER := 0;
  
    CURSOR cur_price IS
      SELECT dp.t_damage_code_id
            ,dp.DMS_AID_TYPE_ID
        FROM ven_dms_price dp
       WHERE dp.dms_price_id = p_dms_price_id;
  
    /*cursor cur_find(p_damage_id number) is select tdc.id,
          pc.start_date,
          pc.end_date
     from ven_p_cover pc,
          ven_t_prod_line_option tplo,
          ven_t_prod_line_opt_peril tplop,
          ven_t_peril tp,
          ven_t_damage_code tdc
    where tdc.id = p_damage_id
      and tdc.peril = tp.id
      and tp.id = tplop.peril_id
      and tplop.product_line_option_id = tplo.id
      and tplo.id = pc.t_prod_line_option_id
      and pc.as_asset_id = p_as_asset_id;*/
    CURSOR cur_find IS
      SELECT pc.START_DATE
            ,pc.END_DATE
        FROM ven_p_cover               pc
            ,ven_t_prod_line_option    tplo
            ,ven_t_prod_line_dms       tpld
            ,ven_parent_prod_line_dms  ppld
            ,ven_par_prod_line_cont    pplc
            ,ven_t_prod_line_opt_peril tplop
            ,ven_t_prod_line_option    tplo1
       WHERE (tplop.peril_id = v_t_peril_id OR v_is_peril IS NULL)
         AND (pplc.contact_id = p_lpu_id OR v_is_lpu IS NULL)
         AND tplop.product_line_option_id = tplo1.ID
         AND tplo1.product_line_id = ppld.t_prod_line_id
         AND pplc.parent_prod_line_id = ppld.parent_prod_line_dms_id
         AND ppld.t_parent_prod_line_id = tpld.t_prod_line_dms_id
         AND tpld.t_prod_line_dms_id = tplo.product_line_id
         AND tplo.ID = pc.t_prod_line_option_id
         AND pc.as_asset_id = p_as_asset_id;
  BEGIN
    IF get_param('PERIL_IN_PROG')
    THEN
      v_is_peril := 1;
    ELSE
      v_is_peril := NULL;
    END IF;
  
    IF get_param('LPU_IN_PROG')
    THEN
      v_is_lpu := 1;
    ELSE
      v_is_lpu := NULL;
    END IF;
  
    OPEN cur_price;
    FETCH cur_price
      INTO v_t_damage_code_id
          ,v_t_peril_id;
    IF cur_price%NOTFOUND
    THEN
      v_t_peril_id       := NULL;
      v_t_damage_code_id := NULL;
    END IF;
    CLOSE cur_price;
    --p_peril_id := v_t_peril_id;
  
    IF NOT get_param('PERIL_LINK')
    THEN
      RETURN NULL;
    ELSE
      IF v_t_peril_id IS NULL
      THEN
        v_ret_val := NULL;
        err_mess  := 'В прайс-листе ЛПУ нет привязки услуги к типу медицинской помощи.';
        RETURN(v_ret_val);
      ELSE
        IF get_param('DAMAGE_CODE_LINK')
           AND v_t_damage_code_id IS NULL
        THEN
          v_ret_val := NULL;
          err_mess  := 'В прайс-листе ЛПУ нет привязки услуги к виду услуг.';
          RETURN(v_ret_val);
        END IF;
      
        OPEN cur_find;
        FETCH cur_find
          INTO v_start_date
              ,v_end_date;
        IF cur_find%NOTFOUND
        THEN
          IF get_param('LPU_IN_PROG')
          THEN
            v_ret_val    := NULL;
            err_mess     := 'Данная услуга не может быть получена застрахованным в указанном ЛПУ на основании текущего варианта страхования!';
            v_start_date := NULL;
            v_end_date   := NULL;
            CLOSE cur_find;
            RETURN(v_ret_val);
          ELSE
            IF get_param('PERIL_IN_PROG')
            THEN
              v_ret_val    := NULL;
              err_mess     := 'Данная услуга не может быть получена застрахованным на основании текущего варианта страхования!';
              v_start_date := NULL;
              v_end_date   := NULL;
              CLOSE cur_find;
              RETURN(v_ret_val);
            END IF;
          END IF;
        ELSE
          IF NOT (p_serv_date BETWEEN v_start_date AND v_end_date)
          THEN
            v_ret_val := NULL;
            err_mess  := 'Данная услуга не могла быть получена застрахованным в указанную дату!';
            CLOSE cur_find;
            RETURN(v_ret_val);
          END IF;
        END IF;
        CLOSE cur_find;
      END IF;
    END IF;
  
    RETURN(v_ret_val);
  END;

  -- поиск возможного ЛПУ для получения услуги застрахованным
  /*FUNCTION find_lpu(p_as_asset IN NUMBER, p_c_service_med_id IN NUMBER, p_dms_price_id IN NUMBER) RETURN NUMBER IS
    v_ret_val NUMBER;
    v_lpu_id NUMBER;
    CURSOR cur_lpu IS SELECT dsa.executor_id
                        FROM ven_c_service_med csm,
                             ven_dms_serv_reg dsr,
                             ven_dms_serv_act dsa,
                             ven_doc_doc dd
                       WHERE dsa.dms_serv_act_id = dd.parent_id
                         AND dd.child_id = dsr.dms_serv_reg_id
                         AND dsr.dms_serv_reg_id = csm.dms_serv_reg_id
                         AND csm.c_service_med_id = p_c_service_med_id;
  
    CURSOR cur_find(p_lpu_id NUMBER) IS SELECT c.contact_id
                         FROM ven_p_cover pc,
                              ven_t_prod_line_option tplo,
                              ven_t_product_line tpl,
                              ven_parent_prod_line ppl,
                              ven_par_prod_line_cont pplc,
                              ven_contact c
                        WHERE c.contact_id = p_lpu_id
                          AND c.contact_id = pplc.contact_id
                          AND pplc.parent_prod_line_id = ppl.parent_prod_line_id
                          AND ppl.t_parent_prod_line_id = tpl.id
                          AND tpl.id = tplo.product_line_id
                          AND tplo.id = pc.t_prod_line_option_id
                          AND pc.as_asset_id = p_as_asset;
  
  BEGIN
    OPEN cur_lpu;
    FETCH cur_lpu INTO v_lpu_id;
    IF cur_lpu%NOTFOUND THEN
      v_lpu_id := NULL;
    END IF;
    CLOSE cur_lpu;
  
    IF v_lpu_id IS NOT NULL THEN
      OPEN cur_find(v_lpu_id);
      FETCH cur_find INTO v_ret_val;
      IF cur_find%NOTFOUND THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_find;
    END IF;
    RETURN(v_ret_val);
  END;*/

  -- провести экспертизу по оказанной услуге
  FUNCTION check_c_service_med
  (
    p_c_service_med_id NUMBER
   ,p_create_act       IN NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
    v_is_error NUMBER; -- 0 - ошибок нет, 1 - есть критические ошибки, 2 - есть некритические ошибки, 3 - есть предупреждения
    v_err_mess VARCHAR2(1000);
    v_csm      ven_c_service_med%ROWTYPE;
  
    v_as_assured_id_fact NUMBER;
    v_dms_ins_prg_id     NUMBER;
    v_dms_price_id       NUMBER;
    v_dms_price_cost     NUMBER;
    v_dms_aid_type_id    NUMBER;
    v_is_not_ins         NUMBER;
    v_is_not_med         NUMBER;
    v_fact_cost          NUMBER;
    v_act_summ           NUMBER := NULL;
    v_act_count          NUMBER := NULL;
    v_damage_code_id     NUMBER;
    v_lpu_id             NUMBER;
  
    v_dms_act_id      NUMBER;
    v_act_num         VARCHAR2(50);
    v_dms_serv_act_id NUMBER;
    v_doc_templ_id    NUMBER;
    v_doc_id          NUMBER;
  
    v_ret_val VARCHAR2(50);
    v_count   NUMBER := 0;
  
    CURSOR cur_templ IS
      SELECT dt.doc_templ_id FROM ven_doc_templ dt WHERE brief = 'DMS_ACT_TECH';
  
    CURSOR cur_act IS
      SELECT da.dms_act_id
            ,da.num || ' от ' || da.act_date act_full_num
        FROM ven_ac_payment   dsa
            ,ven_doc_doc      dd
            ,ven_dms_serv_reg dsr
            ,ven_doc_doc      dd1
            ,ven_dms_act      da
            ,ven_doc_templ    dt
       WHERE Doc.get_doc_status_brief(da.dms_act_id) = 'NEW'
         AND dt.brief = 'DMS_ACT_TECH'
         AND dt.doc_templ_id = da.doc_templ_id
         AND da.dms_act_id = dd1.child_id
         AND dd1.parent_id = dsa.payment_id
         AND dsa.payment_id = dd.parent_id
         AND dd.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = v_csm.dms_serv_reg_id;
  
    CURSOR cur_parent IS
      SELECT dsa.num || 'T' act_num
            ,dsa.payment_id
        FROM ven_ac_payment   dsa
            ,ven_doc_doc      dd
            ,ven_dms_serv_reg dsr
       WHERE dsa.payment_id = dd.parent_id
         AND dd.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = v_csm.dms_serv_reg_id;
  
    CURSOR cur_lpu IS
      SELECT dsr.lpu_id
        FROM ven_c_service_med csm
            ,ven_dms_serv_reg  dsr
       WHERE dsr.dms_serv_reg_id = csm.dms_serv_reg_id
         AND csm.c_service_med_id = p_c_service_med_id;
  BEGIN
    -- очищаем список ошибок
    DELETE DMS_ERR de
     WHERE de.c_service_med_id = p_c_service_med_id
       AND de.dms_err_type_id <> 2;
    -- удаляем услугу из актов экспертиз
    DELETE DMS_REL_SERV_ACT drsa
     WHERE drsa.c_service_med_id = p_c_service_med_id
       AND drsa.dms_act_id IN (SELECT da.dms_act_id
                                 FROM ven_dms_act   da
                                     ,ven_doc_templ dt
                                WHERE Doc.get_doc_status_brief(da.dms_act_id) = 'NEW'
                                  AND da.doc_templ_id = dt.doc_templ_id
                                  AND dt.brief = 'DMS_ACT_TECH');
    -- экспертиза
    SELECT * INTO v_csm FROM ven_c_service_med t WHERE t.c_service_med_id = p_c_service_med_id;
    v_is_error := 0;
    -- 1 поиск застрахованного
    v_count              := 0;
    v_as_assured_id_fact := find_as_assured(v_csm.as_assured_last_name
                                           ,v_csm.as_assured_first_name
                                           ,v_csm.as_assured_middle_name
                                           ,v_csm.bso_num
                                           ,v_count);
  
    --исправил Д.Сыровецкий
    --if v_as_assured_id_fact is null then -- было
    IF v_as_assured_id_fact IS NULL
       AND (get_param('CARD_NUM') OR get_param('AS_ASSURED_LAST_NAME'))
    THEN
    
      IF v_count < 2
      THEN
        v_is_error := 1;
        v_err_mess := 'Указанный застрахованный не найден!';
      ELSE
        v_is_error := 3;
        v_err_mess := 'Найдено несколько человек, удовлетворяющих условию поиска! Необходимо задать дополнительное условие или определить вручную';
      END IF;
      save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
    END IF;
  
    IF v_as_assured_id_fact IS NOT NULL
    THEN
      BEGIN
        SELECT pld.t_prod_line_dms_id
          INTO v_dms_ins_prg_id
          FROM P_COVER            pc
              ,T_PROD_LINE_OPTION plo
              ,T_PROD_LINE_DMS    pld
         WHERE pc.AS_ASSET_ID = v_as_assured_id_fact
           AND plo.ID = pc.T_PROD_LINE_OPTION_ID
           AND pld.T_PROD_LINE_DMS_ID = plo.PRODUCT_LINE_ID;
      EXCEPTION
        WHEN OTHERS THEN
          v_dms_ins_prg_id := NULL;
      END;
    END IF;
  
    -- 2 найти услугу в прайсе ЛПУ
    v_dms_price_id := find_dms_price(v_csm.c_service_med_id
                                    ,v_csm.service_code
                                    ,v_csm.service_name
                                    ,v_dms_price_cost
                                    ,v_dms_aid_type_id
                                    ,v_is_not_ins
                                    ,v_is_not_med);
  
    --Исправил Д.Сыровецкий
    --if v_dms_price_id is null then -- было
    IF v_dms_price_id IS NULL
       AND (get_param('SERVICE_CODE') OR get_param('SERVICE_NAME'))
    THEN
      v_is_error := 1;
      v_err_mess := 'Указанная услуга не найдена в прайс-листе ЛПУ!';
      save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
    END IF;
  
    -- 3 проверить соответствие цены услуги прейскуранту
    IF (v_dms_price_id IS NOT NULL)
       AND (v_is_error = 0)
       AND (get_param('AMOUNT_PLAN'))
    THEN
      IF NVL(v_csm.count_plan, 0) = 0
      THEN
        v_err_mess := 'Не указано количество оказанных услуг';
        save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
      ELSE
        v_fact_cost := ROUND(v_csm.amount_plan / v_csm.count_plan);
        IF v_fact_cost > v_dms_price_cost
        THEN
          v_is_error := 2;
          v_err_mess := 'Указанная цена услуги выше, чем цена в прайс-листе данного ЛПУ!';
          save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
          v_act_summ := ROUND((v_fact_cost - v_dms_price_cost) * v_csm.count_plan, 2);
        ELSIF v_fact_cost < v_dms_price_cost
        THEN
          v_is_error := 3;
          v_err_mess := 'Указанная цена услуги ниже, чем цена в прайс-листе данного ЛПУ!';
          save_dms_err(v_csm.c_service_med_id, 4, v_err_mess);
        END IF;
      END IF;
    END IF;
  
    -- 4 мог ли застрахованный получить эту услугу в рамках варианта страхования
    IF (v_dms_price_id IS NOT NULL)
       AND (v_as_assured_id_fact IS NOT NULL)
    THEN
      OPEN cur_lpu;
      FETCH cur_lpu
        INTO v_lpu_id;
      IF cur_lpu%NOTFOUND
      THEN
        v_lpu_id := NULL;
      END IF;
      CLOSE cur_lpu;
    
      v_damage_code_id := find_damage_code(v_as_assured_id_fact
                                          ,v_dms_price_id
                                          ,v_lpu_id
                                          ,v_csm.service_date
                                          ,v_err_mess /*
                                                                                  , v_dms_aid_type_id*/);
    
      IF v_damage_code_id IS NULL
         AND (get_param('PERIL_LINK') OR get_param('DAMAGE_CODE_LINK') OR get_param('PERIL_IN_PROG') OR
         get_param('LPU_IN_PROG'))
      THEN
        v_is_error := 1;
        v_err_mess := 'Застрахованный не мог получать данную услугу в рамках варианта страхования!';
        save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
      END IF;
      /*IF v_dms_aid_type_id IS NULL AND get_param('PERIL_LINK') THEN
           v_is_error := 1;
           save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
      ELSE
        IF v_damage_code_id IS NULL AND get_param('DAMAGE_CODE_LINK') THEN
             v_is_error := 1;
             save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
           END IF;
         END IF;*/
    
    END IF;
  
    -- 5 мог ли застрахованный получить эту услугу в данном ЛПУ
    /*  IF (v_as_assured_id_fact IS NOT NULL) AND (v_dms_price_id IS NOT NULL) AND get_param('LPU_IN_PROG')THEN
      v_lpu_id := find_lpu(v_as_assured_id_fact, v_csm.c_service_med_id, v_dms_price_id);
      IF v_lpu_id IS NULL THEN
        v_is_error := NULL;
        v_err_mess := 'Застрахованный не должен был получать данную услугу в указанном ЛПУ';
        save_dms_err(v_csm.c_service_med_id, 1, v_err_mess);
      END IF;
    END IF;*/
  
    -- проапдейтить оказанную услугу определенными значениями
    UPDATE C_SERVICE_MED csm
       SET csm.as_asset_id  = v_as_assured_id_fact
          ,csm.dms_price_id = v_dms_price_id
          ,csm.is_not_ins   = NVL(v_is_not_ins, 0)
          ,csm.is_not_med   = NVL(v_is_not_med, 0)
          ,
           --csm.t_damage_code_id = v_damage_code_id,
           csm.dms_ins_prg_id  = v_dms_ins_prg_id
          ,csm.dms_aid_type_id = v_dms_aid_type_id
          ,csm.is_tech_check   = 1
          ,csm.is_tech_manual  = 0
     WHERE csm.c_service_med_id = p_c_service_med_id;
  
    IF p_create_act = 0
    THEN
      IF v_is_error IN (1, 2)
      THEN
        RETURN 'error';
      END IF;
    END IF;
    -- если есть услуги, в которых обнаружены критические ошибки,
    -- то создать акт технической экспертизы или добавить услугу,
    -- не прошедшую техническую экспертизу в уже существующий акт
  
    v_act_summ := NVL(v_act_summ, v_csm.amount_plan);
    IF v_act_summ = v_csm.amount_plan
    THEN
      v_act_count := v_csm.count_plan;
    ELSE
      v_act_count := 0;
    END IF;
  
    IF v_is_error IN (1, 2)
    THEN
      OPEN cur_act;
      FETCH cur_act
        INTO v_dms_act_id
            ,v_ret_val;
      IF cur_act%NOTFOUND
      THEN
        v_dms_act_id := NULL;
        v_ret_val    := NULL;
      END IF;
      CLOSE cur_act;
    
      IF v_dms_act_id IS NOT NULL
      THEN
        INSERT INTO ven_dms_rel_serv_act
          (dms_rel_serv_act_id, dms_act_id, c_service_med_id, serv_count, serv_amount)
        VALUES
          (sq_dms_rel_serv_act.NEXTVAL, v_dms_act_id, v_csm.c_service_med_id, v_act_count, v_act_summ);
      ELSE
        OPEN cur_parent;
        FETCH cur_parent
          INTO v_act_num
              ,v_dms_serv_act_id;
        IF cur_parent%NOTFOUND
        THEN
          v_act_num         := NULL;
          v_dms_serv_act_id := NULL;
        END IF;
        CLOSE cur_parent;
      
        OPEN cur_templ;
        FETCH cur_templ
          INTO v_doc_templ_id;
        IF cur_templ%NOTFOUND
        THEN
          v_doc_templ_id := NULL;
        END IF;
        CLOSE cur_templ;
      
        SELECT sq_dms_act.NEXTVAL INTO v_dms_act_id FROM dual;
        v_ret_val := '№ ' || v_act_num || ' от ' || TRUNC(SYSDATE, 'dd');
        INSERT INTO ven_dms_act
          (dms_act_id, num, reg_date, doc_templ_id, act_date)
        VALUES
          (v_dms_act_id, v_act_num, SYSDATE, v_doc_templ_id, TRUNC(SYSDATE, 'dd'));
        Doc.set_doc_status(v_dms_act_id, 'NEW');
      
        SELECT sq_doc_doc.NEXTVAL INTO v_doc_id FROM dual;
        INSERT INTO ven_doc_doc
          (doc_doc_id, parent_id, child_id)
        VALUES
          (v_doc_id, v_dms_serv_act_id, v_dms_act_id);
      
        INSERT INTO ven_dms_rel_serv_act
          (dms_rel_serv_act_id, dms_act_id, c_service_med_id, serv_count, serv_amount)
        VALUES
          (sq_dms_rel_serv_act.NEXTVAL, v_dms_act_id, v_csm.c_service_med_id, v_act_count, v_act_summ);
      END IF;
    END IF;
    RETURN(v_ret_val);
  END;

  -- проведение медицинской экспертизы
  FUNCTION med_expert
  (
    p_c_service_med_id   IN NUMBER
   ,p_med_expert_type_id IN NUMBER
   ,p_dms_mkb_id         IN NUMBER
   ,p_is_not_med         IN NUMBER
   ,p_count_med_exp      IN NUMBER
   ,p_amount_med_exp     IN NUMBER
   ,p_act_note           IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_ret_val         VARCHAR2(50);
    v_csm             ven_c_service_med%ROWTYPE;
    v_dms_act_id      NUMBER;
    v_dms_act_num     VARCHAR2(50);
    v_dms_serv_act_id NUMBER;
  
    CURSOR cur_act IS
      SELECT da.dms_act_id
            ,da.num || ' от ' || da.act_date dms_act_num
        FROM ven_dms_serv_act dsa
            ,ven_doc_doc      dd
            ,ven_dms_serv_reg dsr
            ,ven_doc_doc      dd1
            ,ven_dms_act      da
            ,ven_doc_templ    dt
       WHERE Doc.get_doc_status_brief(da.dms_act_id) = 'NEW'
         AND dt.doc_templ_id = p_med_expert_type_id
         AND dt.doc_templ_id = da.doc_templ_id
         AND da.dms_act_id = dd1.child_id
         AND dd1.parent_id = dsa.dms_serv_act_id
         AND dsa.dms_serv_act_id = dd.parent_id
         AND dd.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = v_csm.dms_serv_reg_id;
  
    CURSOR cur_parent IS
      SELECT 'M' act_num
            ,dsa.dms_serv_act_id
        FROM ven_dms_serv_act dsa
            ,ven_doc_doc      dd
            ,ven_dms_serv_reg dsr
       WHERE dsa.dms_serv_act_id = dd.parent_id
         AND dd.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = v_csm.dms_serv_reg_id;
  BEGIN
    -- очищаем список ошибок
    DELETE DMS_ERR de
     WHERE de.c_service_med_id = p_c_service_med_id
       AND de.dms_err_type_id = 2;
    -- удаляем услугу из актов экспертиз
    DELETE DMS_REL_SERV_ACT drsa
     WHERE drsa.c_service_med_id = p_c_service_med_id
       AND drsa.dms_act_id IN (SELECT da.dms_act_id
                                 FROM ven_dms_act   da
                                     ,ven_doc_templ dt
                                WHERE Doc.get_doc_status_brief(da.dms_act_id) = 'NEW'
                                  AND da.doc_templ_id = dt.doc_templ_id
                                  AND dt.doc_templ_id = p_med_expert_type_id);
    -- экспертиза
    SELECT * INTO v_csm FROM ven_c_service_med t WHERE t.c_service_med_id = p_c_service_med_id;
    save_dms_err(p_c_service_med_id, 2, p_act_note);
  
    OPEN cur_act;
    FETCH cur_act
      INTO v_dms_act_id
          ,v_dms_act_num;
    IF cur_act%NOTFOUND
    THEN
      v_dms_act_id  := NULL;
      v_dms_act_num := NULL;
    END IF;
    CLOSE cur_act;
    v_ret_val := '№ ' || v_dms_act_num;
  
    IF v_dms_act_id IS NULL
    THEN
      OPEN cur_parent;
      FETCH cur_parent
        INTO v_dms_act_num
            ,v_dms_serv_act_id;
      IF cur_parent%NOTFOUND
      THEN
        v_dms_act_num     := NULL;
        v_dms_serv_act_id := NULL;
      END IF;
      CLOSE cur_parent;
    
      IF v_dms_act_num IS NOT NULL
         AND v_dms_serv_act_id IS NOT NULL
      THEN
        SELECT sq_dms_act.NEXTVAL INTO v_dms_act_id FROM dual;
        INSERT INTO ven_dms_act
          (dms_act_id, doc_templ_id, num, reg_date, act_date)
        VALUES
          (v_dms_act_id
          ,p_med_expert_type_id
          ,TO_CHAR(v_dms_act_id) || v_dms_act_num
          ,SYSDATE
          ,TRUNC(SYSDATE, 'DD'));
        Doc.set_doc_status(v_dms_act_id, 'NEW');
        v_ret_val := '№ ' || v_dms_act_num || ' от ' || TRUNC(SYSDATE, 'dd');
      
        INSERT INTO ven_doc_doc
          (doc_doc_id, parent_id, child_id)
        VALUES
          (sq_doc_doc.NEXTVAL, v_dms_serv_act_id, v_dms_act_id);
      END IF;
    END IF;
  
    INSERT INTO ven_dms_rel_serv_act
      (dms_rel_serv_act_id, c_service_med_id, dms_act_id, serv_amount, serv_count)
    VALUES
      (sq_dms_rel_serv_act.NEXTVAL
      ,p_c_service_med_id
      ,v_dms_act_id
      ,p_amount_med_exp
      ,p_count_med_exp);
  
    UPDATE ven_c_service_med SET is_med_check = 1 WHERE c_service_med_id = p_c_service_med_id;
  
    RETURN(v_ret_val);
  END;

  -- провести экспертизу по всему реестру
  FUNCTION check_dms_serv_reg
  (
    p_dms_serv_reg_id NUMBER
   ,p_create_act      IN NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(50);
    CURSOR cur_reg IS
      SELECT csm.c_service_med_id
        FROM ven_c_service_med csm
       WHERE csm.dms_serv_reg_id = p_dms_serv_reg_id;
  BEGIN
    FOR c_reg IN cur_reg
    LOOP
      v_ret_val := check_c_service_med(c_reg.c_service_med_id, p_create_act);
    END LOOP;
    RETURN(v_ret_val);
  END;

  --получить количество по услуге, вошедшее в акты экспертиз
  FUNCTION Get_Expert_Count
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
   ,direction          NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_result NUMBER;
    CURSOR cur_find IS
      SELECT NVL(SUM(drsa.serv_count), 0) exp_count
        FROM ven_dms_rel_serv_act drsa
       WHERE drsa.c_service_med_id = p_c_service_med_id
         AND ((p_dms_act_id IS NULL) OR (drsa.dms_act_id = p_dms_act_id));
  
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_result;
    IF cur_find%NOTFOUND
    THEN
      v_result := 0;
    END IF;
    CLOSE cur_find;
    IF direction > 0
    THEN
      SELECT NVL(SUM(drsa.serv_count), 0) exp_count
        INTO v_result
        FROM ven_dms_rel_serv_act drsa
       WHERE drsa.c_service_med_id = p_c_service_med_id
         AND drsa.dms_act_id <> p_dms_act_id;
    END IF;
    RETURN v_result;
  END;

  --получить сумму по услуге, вошедшее в акты экспертиз
  FUNCTION Get_Expert_Amount
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
   ,direction          NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_result NUMBER;
    CURSOR cur_find IS
      SELECT NVL(SUM(drsa.serv_amount), 0) exp_amount
        FROM ven_dms_rel_serv_act drsa
       WHERE drsa.c_service_med_id = p_c_service_med_id
         AND ((p_dms_act_id IS NULL) OR (drsa.dms_act_id = p_dms_act_id));
  
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_result;
    IF cur_find%NOTFOUND
    THEN
      v_result := 0;
    END IF;
    CLOSE cur_find;
    IF direction > 0
    THEN
      SELECT NVL(SUM(drsa.serv_amount), 0) exp_amount
        INTO v_result
        FROM ven_dms_rel_serv_act drsa
       WHERE drsa.c_service_med_id = p_c_service_med_id
         AND (drsa.dms_act_id <> p_dms_act_id);
    END IF;
    RETURN v_result;
  END;

  -- показать, входит ли оказанная услуга в какой-либо действующий акт экспертизы
  FUNCTION is_in_dms_act
  (
    p_c_service_med_id IN NUMBER
   ,p_type             IN VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
    v_type    VARCHAR2(100);
  
    CURSOR cur_find IS
      SELECT da.dms_act_id
        FROM ven_dms_act          da
            ,ven_dms_rel_serv_act drsa
            ,ven_doc_templ        dt
       WHERE Doc.get_doc_status_brief(da.dms_act_id) NOT IN ('NEW')
         AND dt.brief IN (v_type)
         AND dt.doc_templ_id = da.doc_templ_id
         AND da.dms_act_id = drsa.dms_act_id
         AND drsa.c_service_med_id = p_c_service_med_id;
  
  BEGIN
    IF p_type = 'ALL'
    THEN
      v_type := 'DMS_ACT_TECH, DMS_ACT_FIRST_MED, DMS_ACT_SELECT_MED, DMS_ACT_DIRECT_MED';
    ELSE
      v_type := p_type;
    END IF;
  
    OPEN cur_find;
    FETCH cur_find
      INTO v_ret_val;
    IF cur_find%NOTFOUND
    THEN
      v_ret_val := NULL;
    END IF;
    RETURN(v_ret_val);
  END;

  -- показать, входит ли оказанная услуга в какой-либо любой (необязательно действующий) акт экспертизы
  FUNCTION is_in_dms_act_all
  (
    p_c_service_med_id IN NUMBER
   ,p_act              IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_ret_val
      FROM ven_dms_rel_serv_act
     WHERE c_service_med_id = p_c_service_med_id
       AND dms_act_id = NVL(p_act, dms_act_id);
    IF v_ret_val > 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  -- показать, входит ли оказанная услуга в  акт(ы) медицинской экспертизы
  FUNCTION is_in_dms_med_act
  (
    p_c_service_med_id IN NUMBER
   ,p_act              IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_ret_val
      FROM ven_dms_rel_serv_act drsa
          ,ven_dms_act          da
          ,ven_doc_templ        dt
     WHERE drsa.c_service_med_id = p_c_service_med_id
       AND drsa.dms_act_id = da.DMS_ACT_ID
       AND da.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
       AND dt.BRIEF <> 'DMS_ACT_TECH'
       AND drsa.dms_act_id = NVL(p_act, drsa.dms_act_id);
    IF v_ret_val > 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  --получить сумму по содержимому реестра
  FUNCTION Get_Dms_Serv_Reg_Amount
  (
    p_dms_serv_reg_id NUMBER
   ,p_amount_type     VARCHAR2
  ) RETURN NUMBER IS
    v_result      NUMBER;
    v_temp_result NUMBER;
  BEGIN
    CASE
      WHEN p_amount_type = 'PLAN' THEN
        SELECT NVL(SUM(csm.amount_plan), 0)
          INTO v_result
          FROM C_SERVICE_MED csm
         WHERE csm.dms_serv_reg_id = p_dms_serv_reg_id;
      WHEN p_amount_type = 'EXP' THEN
        SELECT NVL(SUM(drsa.serv_amount), 0)
          INTO v_result
          FROM C_SERVICE_MED    csm
              ,DMS_REL_SERV_ACT drsa
         WHERE csm.dms_serv_reg_id = p_dms_serv_reg_id
           AND drsa.c_service_med_id = csm.c_service_med_id;
      WHEN p_amount_type = 'FACT' THEN
        SELECT NVL(SUM(csm.amount_plan), 0)
          INTO v_result
          FROM C_SERVICE_MED csm
         WHERE csm.dms_serv_reg_id = p_dms_serv_reg_id
           AND csm.is_tech_check = 1
            OR csm.is_med_check = 1;
        SELECT NVL(SUM(drsa.serv_amount), 0)
          INTO v_temp_result
          FROM C_SERVICE_MED    csm
              ,DMS_REL_SERV_ACT drsa
         WHERE csm.dms_serv_reg_id = p_dms_serv_reg_id
           AND drsa.c_service_med_id = csm.c_service_med_id
           AND csm.is_tech_check = 1
            OR csm.is_med_check = 1;
        v_result := v_result - v_temp_result;
      ELSE
        v_result := 0;
    END CASE;
    RETURN v_result;
  END;

  --получить количество по услуге, подлежащее оплате
  FUNCTION Get_Fact_Count
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_result NUMBER;
    CURSOR cur_find IS
      SELECT NVL(csm.count_plan, 0) - Get_Expert_count(p_c_service_med_id, p_dms_act_id) fact_count
        FROM ven_c_service_med csm
       WHERE csm.c_service_med_id = p_c_service_med_id;
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_result;
    IF cur_find%NOTFOUND
    THEN
      v_result := 0;
    END IF;
    CLOSE cur_find;
    RETURN v_result;
  END;

  --получить сумму по услуге, подлежащую оплате
  FUNCTION Get_Fact_Amount
  (
    p_c_service_med_id NUMBER
   ,p_dms_act_id       NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_result NUMBER;
    CURSOR cur_find IS
      SELECT NVL(csm.amount_plan, 0) - Get_Expert_Amount(p_c_service_med_id, p_dms_act_id) fact_amount
        FROM ven_c_service_med csm
       WHERE csm.c_service_med_id = p_c_service_med_id;
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_result;
    IF cur_find%NOTFOUND
    THEN
      v_result := 0;
    END IF;
    CLOSE cur_find;
    RETURN v_result;
  END;

  FUNCTION get_amount_by_kind
  (
    p_dms_serv_reg_id IN NUMBER
   ,p_kind            IN VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER;
    v_tmp     NUMBER;
    v_tmp1    NUMBER;
    v_tmp2    NUMBER;
  BEGIN
    IF p_kind = 'FACT'
    THEN
      get_sum_amount(p_dms_serv_reg_id, v_tmp, v_ret_val, v_tmp1, v_tmp2);
    ELSIF p_kind = 'EXP'
    THEN
      get_sum_amount(p_dms_serv_reg_id, v_tmp, v_tmp1, v_ret_val, v_tmp2);
    END IF;
    RETURN(NVL(v_ret_val, .00));
  END;

  PROCEDURE get_sum_amount
  (
    p_dms_serv_reg_id IN NUMBER
   ,p_plan_amount     OUT NUMBER
   ,p_fact_amount     OUT NUMBER
   ,p_exp_amount      OUT NUMBER
   ,p_undef_amount    OUT NUMBER
  ) IS
    CURSOR cur_sum IS
      SELECT SUM(csm.amount_plan)
            ,SUM(Pkg_Dms_Expert.Get_Fact_Amount(csm.c_service_med_id, NULL)) amount_fact
            ,SUM(Pkg_Dms_Expert.get_expert_amount(csm.c_service_med_id, NULL)) amount_expert
            ,MAX(csm.is_tech_check) is_check
        FROM ven_c_service_med csm
            ,(SELECT da.dms_act_id
                    ,drsa.c_service_med_id
                FROM ven_dms_act          da
                    ,ven_dms_rel_serv_act drsa
               WHERE da.dms_act_id = drsa.dms_act_id) sa
       WHERE sa.c_service_med_id(+) = csm.c_service_med_id
         AND csm.dms_serv_reg_id = p_dms_serv_reg_id;
    v_is_check      NUMBER;
    v_plan_amount   NUMBER;
    v_fact_amount   NUMBER;
    v_expert_amount NUMBER;
    v_undef_amount  NUMBER;
  BEGIN
    OPEN cur_sum;
    FETCH cur_sum
      INTO v_plan_amount
          ,v_fact_amount
          ,v_expert_amount
          ,v_is_check;
    IF cur_sum%NOTFOUND
    THEN
      v_is_check      := NULL;
      v_plan_amount   := NULL;
      v_fact_amount   := NULL;
      v_expert_amount := NULL;
      v_undef_amount  := NULL;
    ELSE
      IF v_is_check = 1
      THEN
        v_undef_amount := v_plan_amount - v_fact_amount - v_expert_amount;
      ELSE
        v_undef_amount := 0;
      END IF;
    END IF;
    CLOSE cur_sum;
    p_plan_amount  := v_plan_amount;
    p_fact_amount  := v_fact_amount;
    p_exp_amount   := v_expert_amount;
    p_undef_amount := v_undef_amount;
  END;

  /**
   * Признак прохождения ТЭ всех услуг реестра
   * @param p_dms_serv_reg_id ИД реестра
   * @return признак 0 - есть услуги, не прошедшие ТЭ; 1 - все услуги реестра прошли ТЭ
  **/
  FUNCTION check_is_all_tech(p_dms_serv_reg_id IN NUMBER) RETURN NUMBER IS
    v_ret_val NUMBER := 0;
    v_temp    NUMBER;
  
    CURSOR cur_check IS
      SELECT COUNT(csm.c_service_med_id) all_check
        FROM ven_c_service_med csm
       WHERE (csm.is_tech_check = 0 AND csm.is_tech_manual = 0)
         AND csm.dms_serv_reg_id = p_dms_serv_reg_id;
  BEGIN
    OPEN cur_check;
    FETCH cur_check
      INTO v_temp;
    IF cur_check%NOTFOUND
    THEN
      v_temp := 0;
    END IF;
    CLOSE cur_check;
  
    IF v_temp = 0
    THEN
      v_ret_val := 1;
    ELSE
      v_ret_val := 0;
    END IF;
  
    RETURN(v_ret_val);
  END check_is_all_tech;

  /**
   * Признак удачного прохождения услугой технической экспертизы
   * @param c_service_med_id ИД реестра
   * @return признак 0 - услуга не прошла ТЭ; 1 - услуга прошла ТЭ
  **/
  FUNCTION check_is_tech_auto(p_c_service_med_id IN NUMBER) RETURN NUMBER IS
    v_ret_val NUMBER := 0;
    v_temp1   NUMBER;
    v_temp2   NUMBER;
    CURSOR cur_err IS
      SELECT COUNT(de.dms_err_id) FROM ven_dms_err de WHERE de.c_service_med_id = p_c_service_med_id;
    CURSOR cur_tech IS
      SELECT csm.is_tech_check
        FROM ven_c_service_med csm
       WHERE csm.c_service_med_id = p_c_service_med_id;
  BEGIN
    OPEN cur_err;
    FETCH cur_err
      INTO v_temp1;
    IF cur_err%NOTFOUND
    THEN
      v_temp1 := NULL;
    END IF;
    CLOSE cur_err;
  
    OPEN cur_tech;
    FETCH cur_tech
      INTO v_temp2;
    IF cur_tech%NOTFOUND
    THEN
      v_temp2 := NULL;
    END IF;
    CLOSE cur_tech;
  
    IF v_temp1 IS NULL
       OR v_temp2 IS NULL
    THEN
      v_ret_val := 0;
    ELSE
      IF v_temp2 = 0
      THEN
        v_ret_val := 0;
      ELSE
        IF v_temp1 = 0
        THEN
          v_ret_val := 1;
        ELSE
          v_ret_val := 0;
        END IF;
      END IF;
    END IF;
    RETURN(v_ret_val);
  END check_is_tech_auto;

END Pkg_Dms_Expert;
/

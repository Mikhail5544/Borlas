CREATE OR REPLACE PACKAGE pkg_dms IS
  --
  -- Процедуры и функции для работы с ДМС
  --
  --
  -- MODIFICATION HISTORY
  -- Person           Date            Comments
  -- --------------   -----------     ------------------------------------------
  -- Ilyushkin S.     20.03.2007      Create package
  -- Ilyushkin S.     17.01.2008      Добавил в функ. copy_progs возможность копирования метода ЗСП в вариантах в ДС

  /**
  * Функция формирования кода варианта страхования
  * @author Сыровецкий Д.
  * @param p_t_product_line_id - ИД программы в продукте
  * @return Код варианта страхования
  */
  FUNCTION create_variant_code(p_t_product_line_id NUMBER) RETURN VARCHAR2;

  /**
  * Вставляет новый код для варианта медицинской помощи с исключением
  * @author Сыровецкий Д.
  * @param p_prod_line_id - ИД программы страхования
  * @param p_peril_id - ИД медицинской помощи
  * @return код вставленного исключения
  */
  FUNCTION insert_new_excud
  (
    p_prod_line_id NUMBER
   ,p_peril_id     NUMBER
  ) RETURN VARCHAR2;

  /**
  * Вставляет новый код для варианта медицинской помощи с исключением
  * в том случае, если его нет, то он создается
  * @author Сыровецкий Д.
  * @param p_prod_line_id - ИД программы страхования
  * @param p_peril_id - ИД медицинской помощи
  * @return код исключения
  */
  FUNCTION get_brief_exclusion
  (
    p_prod_line_id IN NUMBER
   ,p_perid_in_id  IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * Копирует содержимое выбранной программы в страховой продукт
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  * @param cont_lpu_ver_id - ИД версии договора ЛПУ
  * @return True в случае успеха и False в противном случае
  */
  FUNCTION copy_progs
  (
    to_id            IN NUMBER
   ,from_id          IN NUMBER
   ,contr_lpu_ver_id IN NUMBER DEFAULT NULL
  ) RETURN BOOLEAN;

  /**
  * Обеспечивает создание новой версии полиса (договора)
  * @author Сыровецкий Д.
  * @param new_pol_id - ИД нового полиса
  * @param old_pol_id - ИД старой версии полиса
  */
  PROCEDURE copy_policy
  (
    new_pol_id NUMBER
   ,old_pol_id NUMBER
  );

  /**
  * Обеспечивает создание новой версии полиса (договора)
  * @author Сыровецкий Д.
  * @param new_contr_id - ИД новой версии контракта
  * @param old_contr_id - ИД старой версии контракта
  * @param p_start_date Начальная дата версии контракта (необязательный параметер)
  * @param p_end_date Конечная дата версии контракта (необязательный параметер)
  */
  PROCEDURE copy_contract_lpu
  (
    new_contr_id NUMBER
   ,old_contr_id NUMBER
   ,p_start_date DATE DEFAULT NULL
   ,p_end_date   DATE DEFAULT NULL
  );

  /**
  * Вставляет значение deduct
  * @author Сыровецкий Д.
  * @param new_prod_line - ИД новой версии контракта
  */
  PROCEDURE ins_deduct(new_prod_line NUMBER);

  /**
  * Копирует список территориий из одной программы в другую
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  */
  PROCEDURE copy_pr_ter
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Копирует список Коэффициентов из одной программы в другую
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  */
  PROCEDURE copy_pr_coef
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Копирует список типов медицинской помощи из одной программы в другую
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  */
  PROCEDURE copy_pr_med
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Копирует список исключений из одной программы в другую
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  */
  PROCEDURE copy_pr_except
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Копирует депозиты из одной программы в другую
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, которая копируется
  */
  PROCEDURE copy_pr_depos
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Копирует исполнителей
  * @author Сыровецкий Д.
  * @param to_id - ИД страхового продукта
  * @param from_id - ИД программы, из которой копируется
  */
  PROCEDURE copy_pr_executer
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  );

  /**
  * Создает платежный документ для акта экспертизы
  * @author Syrovetskiy D.
  * @param p_act_id - ИД акта экспертизы
  * @return ИД платежного документа
  */
  FUNCTION create_pay_for_act(p_act_id IN NUMBER) RETURN NUMBER;

  /**
  * Процедура смены статуса реестра оказанных услуг
  * и всех сопутствующих документов (счет, акт, счет-фактура)
  * @author Syrovetskiy D.
  * @param p_document_id - ИД реестра
  */
  PROCEDURE set_dms_serv_reg_status(p_document_id IN NUMBER);

  /**
  * Генерирует для застрахованного номер полиса
  * @author Syrovetskiy D.
  * @param p_pol_id - номер полиса
  * @return номер полиса
  */
  FUNCTION get_pol_num
  (
    p_pol_id     IN NUMBER
   ,p_session_id NUMBER
  ) RETURN VARCHAR2;

  /**
  * Функция расчета коэффициента для премии пропорционально дням прикрепления
  * @author Syrovetskiy D.
  * @param p_asset_id - ИД застрахованного
  * @return значение коэффициента
  */
  FUNCTION get_koef_for_premium(p_asset_id NUMBER) RETURN NUMBER;

  -- получить код исключений из программы ДМС
  /**
  * Функция возвращает код исключений из программы ДМС
  * @author Syrovetskiy D.
  * @param p_prod_line_id - ИД программы ДМС
  * @return код исключения
  */
  FUNCTION get_except_code
  (
    p_prod_line_id IN NUMBER
   ,p_t_peril_id   IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * Функция возвращает строкой кода всех программ для застрахованного
  * @author Chikashova O.
  * @param as_assured_id ИД застрахованного
  * @return строка
  */
  FUNCTION get_programm_code(as_assured_id NUMBER) RETURN VARCHAR2;

  /**
  * Изменить у покрытий продукт-лайн опции на новые
  * @author Patsan O.
  * @param p_new_pol_id ИД новой версии полиса
  * @param p_new_pol_id ИД старой версии полиса
  */
  PROCEDURE update_covers(p_new_pol_id IN NUMBER);

  /**
  * Форматированная строка номера документа-основания
  * @author Ilyushkin S.
  * @param p_document_id ИД документа
  * @return форматированная строка номера: <тип> <номер> от <дата>
  */
  FUNCTION get_parent_doc_name(p_document_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Возвращает порядковый номер распоряжения
  * @author Syrovetskiy D.
  * @param p_doc_templ_brief Сокращиение платежного документа
  * @return номер распоряжения
  */
  FUNCTION get_payment_num(p_doc_templ_brief VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /**
  * Копирует t_prod_line_option
  * @author Syrovetskiy D.
  * @param p_prod_line_id ID программы
  */
  PROCEDURE copy_plo(p_prod_line_id IN NUMBER);

  /**
  * временно
  */
  FUNCTION get_lpu_code_net(p_prod_line_id NUMBER) RETURN NUMBER;

  /**
  *проверяет соответствие дат полиса методам прикрепления/открепления
  */
  PROCEDURE check_policy_date(p_policy_id NUMBER);

  FUNCTION GET_ACC_TYPE(p_contract_lpu_ver_id NUMBER) RETURN VARCHAR2;

END; -- Package spec
/
CREATE OR REPLACE PACKAGE BODY pkg_dms IS
  v_un_lpu NUMBER := 0;
  --
  -- Процедуры и функции для работы с ДМС
  --
  --
  -- MODIFICATION HISTORY
  -- Person           Date            Comments
  -- --------------   -----------     ------------------------------------------
  -- Ilyushkin S.     20.03.2007      Create package

  -- Вспомогательная функция для формирования кода региона в коде варианта ДМС
  FUNCTION get_region_code(p_t_product_line_id NUMBER) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(4000) := NULL;
    CURSOR cur_ter IS
      SELECT t.brief
        FROM ven_t_prod_line_ter plt
            ,ven_t_territory     t
       WHERE t.t_territory_id = plt.t_territory_id
         AND plt.product_line_id = p_t_product_line_id;
    v_counter NUMBER;
    v_count_R VARCHAR2(2);
  BEGIN
    v_counter := 0;
    FOR c_ter IN cur_ter
    LOOP
      v_ret_val := v_ret_val || c_ter.brief || '+';
      v_counter := v_counter + 1;
    END LOOP;
    v_ret_val := RTRIM(v_ret_val, '+');
  
    IF v_counter > 1
    THEN
      v_count_R := 'RR';
    ELSE
      v_count_R := 'R';
    END IF;
  
    IF v_ret_val IS NOT NULL
    THEN
      v_ret_val := v_count_R || v_ret_val;
    ELSE
      v_ret_val := v_count_R;
    END IF;
  
    RETURN(v_ret_val);
  END get_region_code;

  -- Вспомогательная функция для извлечени кода региона из кода варианта
  FUNCTION get_region_from_code(p_prog_code IN VARCHAR2) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(4000);
  BEGIN
    -- уточнить по строковым функциям
    RETURN(v_ret_val);
  END get_region_from_code;

  -- Вспомогательная функция для формирования кода типа помощи и видов услуг
  FUNCTION get_aid_code(p_t_peril_id NUMBER) RETURN VARCHAR2 IS
    v_ret_val     VARCHAR2(4000) := NULL;
    v_is_dms_code NUMBER;
    v_descr_eng   VARCHAR2(50) := NULL;
  
    CURSOR cur_per IS
      SELECT p.is_dms_code
            ,p.descr_eng
        FROM ven_t_peril p
       WHERE p.ID = p_t_peril_id;
  
    CURSOR cur_dam IS
      SELECT dc.is_dms_code
            ,dc.code
        FROM ven_t_damage_code dc
       WHERE dc.peril = p_t_peril_id;
  BEGIN
    OPEN cur_per;
    FETCH cur_per
      INTO v_is_dms_code
          ,v_descr_eng;
    IF cur_per%NOTFOUND
    THEN
      v_is_dms_code := NULL;
      v_descr_eng   := NULL;
      v_ret_val     := NULL;
    ELSE
      IF v_is_dms_code = 0
      THEN
        v_ret_val := NULL;
      ELSE
        v_ret_val := v_ret_val || v_descr_eng;
        FOR c_dam IN cur_dam
        LOOP
          IF c_dam.is_dms_code = 1
          THEN
            v_ret_val := v_ret_val || c_dam.code;
          END IF;
        END LOOP;
      END IF;
    END IF;
  
    --v_ret_val:='SS';
  
    RETURN(v_ret_val);
  END get_aid_code;

  -- Функция формирования кода для программы ЛПУ
  FUNCTION get_prog_code_lpu
  (
    p_t_product_line_id NUMBER
   ,is_full             BOOLEAN DEFAULT TRUE
  ) RETURN VARCHAR2 IS
    v_ret_val           VARCHAR2(4000) := NULL;
    v_temp_str          VARCHAR2(4000) := NULL;
    v_product_line_type VARCHAR2(50) := NULL;
    v_old_code          VARCHAR2(4000) := NULL;
  
    /*cursor cur_code is
    select tpld.code
      from ven_t_prod_line_dms tpld
     where tpld.t_prod_line_dms_id = p_t_product_line_id;*/
  
    CURSOR cur_lpu IS
      SELECT cc.dms_lpu_code
        FROM ven_t_prod_line_contact plc
            ,ven_cn_company          cc
       WHERE cc.contact_id = plc.contact_id
         AND plc.product_line_id = p_t_product_line_id;
  
    CURSOR cur_aid IS
      SELECT plop.peril_id
        FROM ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_option    plo
            ,ven_t_peril               p
       WHERE p.ID = plop.peril_id
         AND plop.product_line_option_id = plo.ID
         AND plo.product_line_id = p_t_product_line_id
       ORDER BY p.sort_order
               ,plop.ID;
  
    CURSOR cur_type IS
      SELECT plt.brief
        FROM ven_t_product_line      pl
            ,ven_t_product_line_type plt
       WHERE plt.product_line_type_id = pl.product_line_type_id
         AND pl.ID = p_t_product_line_id;
  BEGIN
    /*open cur_code;
    fetch cur_code
      into v_old_code;
    if cur_code%notfound then
      v_old_code := null;
    end if;
    close cur_code;
    
    if not is_full and v_old_code is not null then
      v_ret_val := v_old_code;
      return(v_ret_val);
    end if;*/
  
    IF is_full
    THEN
      -- код региона
      v_ret_val := get_region_code(p_t_product_line_id) || '.';
      IF v_ret_val = '.'
      THEN
        v_ret_val := NULL;
      END IF;
    END IF;
  
    -- код по прикреплению
    OPEN cur_type;
    FETCH cur_type
      INTO v_product_line_type;
    IF cur_type%NOTFOUND
    THEN
      v_product_line_type := NULL;
    END IF;
    CLOSE cur_type;
  
    -- код типов помощи
    FOR c_lpu IN cur_lpu
    LOOP
    
      IF is_full
      THEN
        v_ret_val := v_ret_val || c_lpu.dms_lpu_code;
      END IF;
    
      FOR c_aid IN cur_aid
      LOOP
        v_ret_val := v_ret_val || get_aid_code(c_aid.peril_id) ||
                     get_except_code(p_t_product_line_id, c_aid.peril_id);
      END LOOP;
    
      v_ret_val := RTRIM(v_ret_val, '.');
      IF v_product_line_type = 'ATTACH'
      THEN
        v_ret_val := v_ret_val || 'i' || get_except_code(p_t_product_line_id, NULL) || '.';
      ELSE
        v_ret_val := v_ret_val || get_except_code(p_t_product_line_id, NULL) || '.';
      END IF;
    END LOOP;
    v_ret_val := RTRIM(v_ret_val, '.');
    RETURN(v_ret_val);
  END get_prog_code_lpu;

  -- Функция формирования кода для базовой программы
  FUNCTION get_prog_code_base
  (
    p_t_product_line_id NUMBER
   ,is_full             BOOLEAN DEFAULT TRUE
   ,is_not_in_pr        BOOLEAN DEFAULT TRUE
   ,p_ret_val           VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
    v_ret_val           VARCHAR2(4000) := NULL;
    v_ret_val1          VARCHAR2(4000) := NULL;
    v_temp_str          VARCHAR2(4000) := NULL;
    v_product_line_type VARCHAR2(50) := NULL;
    v_lpu_code          VARCHAR2(50) := NULL;
    v_depos             VARCHAR2(50) := NULL;
    v_old_code          VARCHAR2(4000) := NULL;
  
    /* cursor cur_code is
    select tpld.code
      from ven_t_prod_line_dms tpld
     where tpld.t_prod_line_dms_id = p_t_product_line_id;*/
  
    CURSOR cur_lpu IS
      SELECT cc.dms_lpu_code
        FROM ven_t_prod_line_contact plc
            ,ven_cn_company          cc
       WHERE cc.contact_id = plc.contact_id
         AND plc.product_line_id = p_t_product_line_id;
  
    CURSOR cur_aid IS
      SELECT plop.peril_id
        FROM ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_option    plo
            ,ven_t_peril               p
       WHERE p.ID = plop.peril_id
         AND plop.product_line_option_id = plo.ID
         AND plo.product_line_id = p_t_product_line_id
       ORDER BY p.sort_order
               ,plop.peril_id;
  
    CURSOR cur_type IS
      SELECT plt.brief
            ,TRIM(TO_CHAR(pld.pr_depos, '990d0')) pr_depos
        FROM ven_t_prod_line_dms     pld
            ,ven_t_product_line_type plt
       WHERE plt.product_line_type_id = pld.product_line_type_id
         AND pld.t_prod_line_dms_id = p_t_product_line_id;
  BEGIN
    /* open cur_code;
    fetch cur_code
      into v_old_code;
    if cur_code%notfound then
      v_old_code := null;
    end if;
    close cur_code;
    
    if not is_full and v_old_code is not null then
      v_ret_val := v_old_code;
      return(v_ret_val);
    end if;*/
  
    IF is_full
    THEN
      -- код региона
      v_ret_val := get_region_code(p_t_product_line_id) || '.';
      IF v_ret_val = '.'
      THEN
        v_ret_val := NULL;
      END IF;
    END IF;
  
    v_ret_val := p_ret_val || v_ret_val;
  
    -- код по прикреплению
    OPEN cur_type;
    FETCH cur_type
      INTO v_product_line_type
          ,v_depos;
    IF cur_type%NOTFOUND
    THEN
      v_product_line_type := NULL;
      v_depos             := NULL;
    END IF;
    CLOSE cur_type;
  
    -- код типов помощи
    OPEN cur_lpu;
    FETCH cur_lpu
      INTO v_lpu_code;
    IF cur_lpu%NOTFOUND
    THEN
      v_lpu_code := NULL;
    END IF;
  
    LOOP
      IF (v_lpu_code IS NOT NULL)
         AND is_full
      THEN
        v_ret_val := v_ret_val || v_lpu_code;
      END IF;
    
      FOR c_aid IN cur_aid
      LOOP
        v_ret_val := v_ret_val || get_aid_code(c_aid.peril_id) ||
                     get_except_code(p_t_product_line_id, c_aid.peril_id);
      END LOOP;
    
      v_ret_val := RTRIM(v_ret_val, '.');
      IF v_product_line_type = 'ATTACH'
      THEN
        v_ret_val := v_ret_val || 'i' || get_except_code(p_t_product_line_id, NULL) || '.';
      ELSE
        v_ret_val := v_ret_val || get_except_code(p_t_product_line_id, NULL) || '.';
      END IF;
    
      FETCH cur_lpu
        INTO v_lpu_code;
      EXIT WHEN cur_lpu%NOTFOUND;
    
    END LOOP;
    CLOSE cur_lpu;
  
    IF v_product_line_type = 'DEPOS'
    THEN
      v_ret_val1 := 'w' || /* v_depos ||*/
                    '.';
    ELSE
      v_ret_val1 := '';
    END IF;
  
    IF is_full
    THEN
      v_ret_val := v_ret_val || v_ret_val1;
    END IF;
  
    v_ret_val := REPLACE(v_ret_val, '..', '.');
    v_ret_val := RTRIM(v_ret_val, '.');
  
    RETURN(v_ret_val);
  END get_prog_code_base;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  FUNCTION get_lpu_code_net(p_prod_line_id NUMBER) RETURN NUMBER IS
    v_lpu_str VARCHAR2(4000) := '';
    v_count   NUMBER;
    v_ret_val NUMBER;
  BEGIN
    FOR cur IN (SELECT DISTINCT TO_CHAR(pplc.contact_id) c_id
                  FROM parent_prod_line   ppl
                      ,par_prod_line_cont pplc
                 WHERE pplc.parent_prod_line_id = ppl.parent_prod_line_id
                   AND ppl.t_parent_prod_line_id = p_prod_line_id
                 ORDER BY pplc.contact_id)
    LOOP
      IF LENGTH(v_lpu_str) + LENGTH(cur.c_id) > 4000
      THEN
        EXIT;
      END IF;
      v_lpu_str := v_lpu_str || cur.c_id || ';';
    END LOOP;
  
    v_ret_val := 0;
    --dbms_output.put_line('v_lpu_str = '||v_lpu_str);
    SELECT COUNT(1) INTO v_count FROM ven_dms_lpu_code_net WHERE full_code = v_lpu_str;
    --dbms_output.put_line('v_count = '||v_count);
    IF v_count > 0
    THEN
      SELECT un_code INTO v_ret_val FROM ven_dms_lpu_code_net WHERE full_code = v_lpu_str;
      --    dbms_output.put_line('un_code_1 = '||v_ret_val);
    ELSE
      --if v_lpu_str is null then
      --return null;
      SELECT NVL(MAX(un_code), 0) + 1 INTO v_ret_val FROM dms_lpu_code_net;
      --end if;
      --dbms_output.put_line('un_code_2 = '||v_ret_val);
      --dbms_output.put_line('un_code_3 = '||v_un_lpu);
      IF v_ret_val <= v_un_lpu
      THEN
        v_ret_val := v_un_lpu + 1;
        v_un_lpu  := v_ret_val;
      END IF;
    
      INSERT INTO ven_dms_lpu_code_net (un_code, full_code) VALUES (v_ret_val, v_lpu_str);
      --commit;
    END IF;
  
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Невозможно создать сетевой код для программы id=' || p_prod_line_id);
    
  END;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  FUNCTION get_prog_code_product_net
  (
    p_t_product_line_id NUMBER
   ,is_full             BOOLEAN DEFAULT TRUE
   ,is_not_in_pr        BOOLEAN DEFAULT TRUE
  ) RETURN VARCHAR2 IS
    v_ret_val           VARCHAR2(4000) := NULL;
    v_ret_val1          VARCHAR2(4000) := NULL;
    v_product_line_id   NUMBER;
    v_product_line_type VARCHAR2(50);
    v_depos             VARCHAR2(50) := NULL;
  
    CURSOR cur_aid IS
      SELECT plop.peril_id
        FROM ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_option    plo
            ,ven_t_peril               p
       WHERE p.ID = plop.peril_id
         AND plop.product_line_option_id = plo.ID
         AND plo.product_line_id = p_t_product_line_id
       ORDER BY p.sort_order
               ,plop.peril_id;
  BEGIN
  
    IF is_full
    THEN
      -- код региона
      v_ret_val := get_region_code(p_t_product_line_id) || '.';
      IF v_ret_val = '.'
      THEN
        v_ret_val := NULL;
      END IF;
    END IF;
  
    -- код по прикреплению
    FOR cur IN (SELECT plt.brief
                      ,TRIM(TO_CHAR(pld.pr_depos, '990d0')) pr_depos
                  FROM ven_t_prod_line_dms     pld
                      ,ven_t_product_line_type plt
                 WHERE plt.product_line_type_id = pld.product_line_type_id
                   AND pld.t_prod_line_dms_id = p_t_product_line_id)
    LOOP
      v_product_line_type := cur.brief;
      v_depos             := cur.pr_depos;
    END LOOP;
  
    -- коды ЛПУ
    v_ret_val := v_ret_val || 'U' || get_lpu_code_net(p_t_product_line_id);
  
    --код типов помощи
    FOR c_aid IN cur_aid
    LOOP
      v_ret_val := v_ret_val || get_aid_code(c_aid.peril_id) ||
                   get_except_code(p_t_product_line_id, c_aid.peril_id);
    END LOOP;
  
    v_ret_val := RTRIM(v_ret_val, '.');
    IF v_product_line_type = 'ATTACH'
    THEN
      v_ret_val := v_ret_val || 'i';
      IF is_full
      THEN
        v_ret_val := v_ret_val || get_except_code(p_t_product_line_id, NULL);
        v_ret_val := v_ret_val || '.';
      END IF;
    ELSE
      v_ret_val := v_ret_val || get_except_code(p_t_product_line_id, NULL) || '.';
    END IF;
  
    IF v_product_line_type = 'DEPOS'
    THEN
      v_ret_val1 := 'w' || /*v_depos ||*/
                    '.';
    ELSE
      v_ret_val1 := '';
    END IF;
  
    IF is_full
    THEN
      v_ret_val := v_ret_val || v_ret_val1;
    END IF;
  
    v_ret_val := REPLACE(v_ret_val, '..', '.');
    v_ret_val := RTRIM(v_ret_val, '.');
  
    RETURN(v_ret_val);
  END;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  FUNCTION get_prog_code_product
  (
    p_t_product_line_id NUMBER
   ,p_is_full           BOOLEAN DEFAULT TRUE
  ) RETURN VARCHAR2 IS
    v_ret_val           VARCHAR2(4000) := NULL;
    v_ret_val1          VARCHAR2(4000);
    v_product_line_id   NUMBER;
    v_product_line_type VARCHAR2(50);
    v_is_depos          NUMBER := 0;
  
    CURSOR cur_prog IS
      SELECT *
        FROM (SELECT pld.t_prod_line_dms_id
                    ,dpt.brief
                    ,pld.is_net
                    ,DECODE(plt.brief, 'DEPOS', 2, 1) ord_depos
                    ,min_peril.m_val
                FROM ven_parent_prod_line ppl
                    ,ven_t_prod_line_dms pld
                    ,ven_dms_prog_type dpt
                    ,ven_t_product_line_type plt
                    ,(SELECT MIN(p.sort_order) m_val
                            ,pld.t_prod_line_dms_id p_id
                        FROM t_prod_line_dms       pld
                            ,t_prod_line_option    plo
                            ,t_prod_line_opt_peril plop
                            ,t_peril               p
                       WHERE plo.product_line_id = pld.t_prod_line_dms_id
                         AND plop.product_line_option_id = plo.ID
                         AND p.ID = plop.peril_id
                       GROUP BY pld.t_prod_line_dms_id) min_peril
               WHERE dpt.dms_prog_type_id = pld.dms_prog_type_id
                 AND pld.t_prod_line_dms_id = ppl.t_prod_line_id
                 AND ppl.t_parent_prod_line_id = p_t_product_line_id
                 AND plt.product_line_type_id = pld.product_line_type_id
                 AND min_peril.p_id(+) = pld.t_prod_line_dms_id)
       ORDER BY ord_depos
               ,m_val;
  
    CURSOR cur_lpu(p_tpl_id NUMBER) IS
      SELECT cc.dms_lpu_code
        FROM ven_par_prod_line_cont pplc
            ,ven_parent_prod_line   ppl
            ,ven_cn_company         cc
       WHERE cc.contact_id = pplc.contact_id
         AND pplc.parent_prod_line_id = ppl.parent_prod_line_id
         AND ppl.t_prod_line_id = p_tpl_id
         AND ppl.t_parent_prod_line_id = p_t_product_line_id;
  BEGIN
    -- код региона
    IF p_is_full
    THEN
      v_ret_val := get_region_code(p_t_product_line_id) || '.';
      IF v_ret_val = '.'
      THEN
        v_ret_val := NULL;
      END IF;
    END IF;
    -- открываем все дочерние программы
    FOR c_prog IN cur_prog
    LOOP
      IF c_prog.ord_depos = 2
         AND v_is_depos = 0
         AND p_is_full
      THEN
        v_is_depos := 1;
        v_ret_val  := v_ret_val || 'w.';
      END IF;
      IF c_prog.brief = 'LPU'
      THEN
        v_ret_val1 := '';
        FOR c_lpu IN cur_lpu(c_prog.t_prod_line_dms_id)
        LOOP
          v_ret_val1 := v_ret_val1 || c_lpu.dms_lpu_code || '+';
          -- чтобы не было лишних "+"
          IF v_ret_val1 = '+'
          THEN
            v_ret_val1 := '';
          END IF;
        END LOOP;
        v_ret_val := v_ret_val || v_ret_val1;
        v_ret_val := RTRIM(v_ret_val, '+');
        --получаем код ЛПУ
        v_ret_val := v_ret_val || get_prog_code_lpu(c_prog.t_prod_line_dms_id, FALSE) || '.';
      ELSIF c_prog.brief = 'BASE'
      THEN
        v_ret_val1 := '';
        FOR c_lpu IN cur_lpu(c_prog.t_prod_line_dms_id)
        LOOP
          v_ret_val1 := v_ret_val1 || c_lpu.dms_lpu_code || '+';
          IF v_ret_val1 = '+'
          THEN
            v_ret_val1 := '';
          END IF;
        END LOOP;
        -- в зависимости от того внутренняя программ или нет,
        -- нужно на разные места ставить признак депозита
        v_ret_val := v_ret_val || v_ret_val1;
        v_ret_val := RTRIM(v_ret_val, '+');
        -- поэтому v_ret_va1 передается в формирование кода
        v_ret_val := v_ret_val || get_prog_code_base(c_prog.t_prod_line_dms_id, FALSE, FALSE) || '.';
      ELSIF c_prog.brief = 'INSPR'
            AND c_prog.is_net = 1
      THEN
        v_ret_val := v_ret_val || get_prog_code_product_net(c_prog.t_prod_line_dms_id, FALSE, FALSE) ||
                     get_except_code(c_prog.t_prod_line_dms_id, NULL) || '.';
      ELSIF c_prog.brief = 'INSPR'
            AND c_prog.is_net = 0
      THEN
        v_ret_val := v_ret_val || get_prog_code_product(c_prog.t_prod_line_dms_id, FALSE) || '.';
      END IF;
    END LOOP;
    v_ret_val := RTRIM(v_ret_val, '.');
    RETURN(v_ret_val);
  END get_prog_code_product;

  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------

  -- Функция формирования кода варианта страхования
  -- @param p_t_product_line_id - ИД программы в продукте
  -- @return Код варианта страхования
  FUNCTION create_variant_code(p_t_product_line_id NUMBER) RETURN VARCHAR2 IS
    v_ret_val   VARCHAR2(2000) := NULL;
    v_temp_str  VARCHAR2(2000) := NULL;
    v_depos_str VARCHAR2(2000) := 'w.';
  
    v_dms_prog_type VARCHAR2(50) := NULL;
    v_is_net        NUMBER;
  
    CURSOR cur_prog_type IS
      SELECT dpt.brief
        FROM ven_t_prod_line_dms pld
            ,ven_dms_prog_type   dpt
       WHERE dpt.dms_prog_type_id = pld.dms_prog_type_id
         AND pld.t_prod_line_dms_id = p_t_product_line_id;
  
    CURSOR cur_net IS
      SELECT NVL(is_net, 0) is_net
        FROM t_prod_line_dms
       WHERE t_prod_line_dms_id = p_t_product_line_id;
  BEGIN
    OPEN cur_prog_type;
    FETCH cur_prog_type
      INTO v_dms_prog_type;
    IF cur_prog_type%NOTFOUND
    THEN
      v_dms_prog_type := NULL;
    END IF;
    CLOSE cur_prog_type;
    IF v_dms_prog_type IS NULL
    THEN
      v_ret_val := NULL;
    ELSIF v_dms_prog_type = 'LPU'
    THEN
      v_ret_val := get_prog_code_lpu(p_t_product_line_id);
    ELSIF v_dms_prog_type = 'BASE'
    THEN
      v_ret_val := get_prog_code_base(p_t_product_line_id);
    ELSIF v_dms_prog_type = 'INSPR'
    THEN
      /*select nvl(is_net,0) into v_is_net
      from t_prod_line_dms where t_prod_line_dms_id = p_t_product_line_id;*/
      OPEN cur_net;
      FETCH cur_net
        INTO v_is_net;
      IF cur_net%NOTFOUND
      THEN
        v_is_net := 0;
      END IF;
      CLOSE cur_net;
      IF v_is_net = 0
      THEN
        v_ret_val := get_prog_code_product(p_t_product_line_id);
      ELSE
        v_ret_val := get_prog_code_product_net(p_t_product_line_id);
      END IF;
    ELSE
      v_ret_val := NULL;
    END IF;
    DBMS_OUTPUT.PUT_LINE(v_ret_val);
    RETURN(v_ret_val);
  END Create_variant_code;

  -- Формирование уникального кода исключения
  FUNCTION get_unicue_brief(p_t_peril_id NUMBER) RETURN VARCHAR2 IS
    CURSOR cur_type IS
      SELECT p.descr_eng FROM ven_t_peril p WHERE p.ID = p_t_peril_id;
  
    CURSOR cur_brief IS
      SELECT ed.brief FROM T_EXCLUSION_DMS ed;
  
    v_peril_type VARCHAR2(50);
    v_max_brief  NUMBER;
    v_cur_brief  NUMBER;
    v_ret_val    VARCHAR2(50);
  BEGIN
    OPEN cur_type;
    FETCH cur_type
      INTO v_peril_type;
    IF cur_type%NOTFOUND
    THEN
      v_peril_type := NULL;
    END IF;
    CLOSE cur_type;
  
    v_max_brief := 1;
    FOR c_brief IN cur_brief
    LOOP
      BEGIN
        v_cur_brief := SUBSTR(c_brief.brief, 2);
        v_cur_brief := TO_NUMBER(c_brief.brief);
      EXCEPTION
        WHEN OTHERS THEN
          v_cur_brief := 0;
      END;
      IF v_cur_brief > v_max_brief
      THEN
        v_max_brief := v_cur_brief;
      END IF;
    END LOOP;
    IF v_peril_type IN ('V', 'E')
    THEN
      v_ret_val := 'J' || TO_CHAR(v_max_brief + 1);
    ELSE
      v_ret_val := 'N' || TO_CHAR(v_max_brief + 1);
    END IF;
    RETURN(v_ret_val);
  END get_unicue_brief;

  FUNCTION insert_new_excud
  (
    p_prod_line_id NUMBER
   ,p_peril_id     NUMBER
  ) RETURN VARCHAR2 IS
  
    CURSOR get_exclud
    (
      p_cur2_prod_line_id NUMBER
     ,p_peril_id          NUMBER
    ) IS
      SELECT plda.T_DAMAGE_CODE_ID ID
        FROM ven_t_prod_line_dms       pld
            ,ven_t_prod_line_option    plo
            ,ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_damage    plda
       WHERE pld.T_PROD_LINE_DMS_ID = p_cur2_prod_line_id
         AND plop.PERIL_ID = p_peril_id
         AND plo.PRODUCT_LINE_ID = pld.T_PROD_LINE_DMS_ID
         AND plop.PRODUCT_LINE_OPTION_ID = plo.ID
         AND plda.T_PROD_LINE_OPT_PERIL_ID = plop.ID
         AND plda.IS_EXCLUDED = 1
       ORDER BY plda.T_DAMAGE_CODE_ID;
  
    v_temp_exc_id     NUMBER;
    v_temp_name_prog  T_PRODUCT_LINE.description%TYPE;
    v_temp_descrt_eng T_PERIL.descr_eng%TYPE;
    ret_val           VARCHAR2(200);
  
  BEGIN
    SELECT sq_t_exclusion_dms.NEXTVAL INTO v_temp_exc_id FROM dual;
  
    SELECT description INTO v_temp_name_prog FROM T_PRODUCT_LINE WHERE ID = p_prod_line_id;
    SELECT descr_eng INTO v_temp_descrt_eng FROM T_PERIL WHERE ID = p_peril_id;
  
    ret_val := get_unicue_brief(p_peril_id);
  
    INSERT INTO T_EXCLUSION_DMS
      (t_exclusion_dms_id, description, brief, t_peril_id)
    VALUES
      (v_temp_exc_id, v_temp_name_prog || '(' || v_temp_descrt_eng || ')', ret_val, p_peril_id);
  
    FOR cur IN get_exclud(p_prod_line_id, p_peril_id)
    LOOP
      --просто нужно добавить сюда все выбранные исключения
      INSERT INTO T_EXCLUD_DMS_CONT
        (t_exclud_dms_cont_id, t_exclusion_dms_id, t_damage_code_id)
      VALUES
        (sq_t_exclud_dms_cont.NEXTVAL, v_temp_exc_id, cur.ID);
    END LOOP;
  
    RETURN ret_val;
  END;

  -- получить код исключений из программы ДМС
  FUNCTION get_except_code
  (
    p_prod_line_id IN NUMBER
   ,p_t_peril_id   IN NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR cur_except IS
      SELECT ec.brief
        FROM ven_dms_prog_except_code dpec
            ,ven_dms_except_code      ec
       WHERE ec.dms_except_code_id = dpec.dms_except_code_id
         AND ((dpec.t_peril_id = p_t_peril_id) OR (p_t_peril_id IS NULL AND dpec.t_peril_id IS NULL))
         AND dpec.t_prod_line_dms_id = p_prod_line_id;
    v_ret_val VARCHAR2(2000);
  BEGIN
    FOR c_except IN cur_except
    LOOP
      --v_ret_val := v_ret_val || c_except.brief||'.';
      v_ret_val := v_ret_val || c_except.brief;
    END LOOP;
    RETURN(v_ret_val);
  END get_except_code;

  -- пока считать устаревшей и работать с функцией get_except_code
  FUNCTION get_brief_exclusion
  (
    p_prod_line_id IN NUMBER
   ,p_perid_in_id  IN NUMBER
  ) RETURN VARCHAR2 IS
    v_temp_count  NUMBER;
    v_temp_count2 NUMBER;
  
    v_find_flg NUMBER;
    v_final_id NUMBER;
  
    v_brief VARCHAR2(255);
  
    CURSOR get_peril
    (
      p_cur1_prod_line_id NUMBER
     ,p_cur1_peril_id     NUMBER
    ) IS
      SELECT DISTINCT plop.PERIL_ID ID
        FROM ven_t_prod_line_dms       pld
            ,ven_t_prod_line_option    plo
            ,ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_damage    plda
       WHERE pld.T_PROD_LINE_DMS_ID = p_cur1_prod_line_id
         AND plop.PERIL_ID = p_cur1_peril_id
         AND plo.PRODUCT_LINE_ID = pld.T_PROD_LINE_DMS_ID
         AND plop.PRODUCT_LINE_OPTION_ID = plo.ID
         AND plda.T_PROD_LINE_OPT_PERIL_ID = plop.ID
         AND plda.IS_EXCLUDED = 1;
  
    CURSOR get_exclud
    (
      p_cur2_prod_line_id NUMBER
     ,p_peril_id          NUMBER
    ) IS
      SELECT plda.T_DAMAGE_CODE_ID ID
        FROM ven_t_prod_line_dms       pld
            ,ven_t_prod_line_option    plo
            ,ven_t_prod_line_opt_peril plop
            ,ven_t_prod_line_damage    plda
       WHERE pld.T_PROD_LINE_DMS_ID = p_cur2_prod_line_id
         AND plop.PERIL_ID = p_peril_id
         AND plo.PRODUCT_LINE_ID = pld.T_PROD_LINE_DMS_ID
         AND plop.PRODUCT_LINE_OPTION_ID = plo.ID
         AND plda.T_PROD_LINE_OPT_PERIL_ID = plop.ID
         AND plda.IS_EXCLUDED = 1
       ORDER BY plda.T_DAMAGE_CODE_ID;
  
  BEGIN
    FOR cur1 IN get_peril(p_prod_line_id, p_perid_in_id)
    LOOP
      -- нужно проверить есть ли такае МП в справочнике исключений
    
      SELECT COUNT(1) INTO v_temp_count FROM T_EXCLUSION_DMS WHERE t_peril_id = p_perid_in_id;
    
      IF v_temp_count = 0
      THEN
        --такого исключения нет, поэтому можно смело его вставлять
        RETURN(insert_new_excud(p_prod_line_id, p_perid_in_id));
      ELSE
        --эта мед. помощь есть, поэтому нужно проверить на исключения
        --нужно для каждого perila в этой таблице проверить набор исключений
      
        v_find_flg := 0;
      
        FOR cur2 IN (SELECT t_exclusion_dms_id ID FROM T_EXCLUSION_DMS WHERE t_peril_id = p_perid_in_id)
        LOOP
          -- 1. нужно проверить общее количество записей
          -- если они равны, то разговариваем дальше, елси нет то вставка новой записи
          SELECT COUNT(1) INTO v_temp_count FROM T_EXCLUD_DMS_CONT WHERE t_exclusion_dms_id = cur2.ID;
          SELECT COUNT(1)
            INTO v_temp_count2
            FROM ven_t_prod_line_dms       pld
                ,ven_t_prod_line_option    plo
                ,ven_t_prod_line_opt_peril plop
                ,ven_t_prod_line_damage    plda
           WHERE pld.T_PROD_LINE_DMS_ID = p_prod_line_id
             AND plop.PERIL_ID = p_perid_in_id
             AND plo.PRODUCT_LINE_ID = pld.T_PROD_LINE_DMS_ID
             AND plop.PRODUCT_LINE_OPTION_ID = plo.ID
             AND plda.T_PROD_LINE_OPT_PERIL_ID = plop.ID
             AND plda.IS_EXCLUDED = 1;
        
          IF v_temp_count <> v_temp_count2
          THEN
            -- количество не равно
            NULL;
          ELSE
            --2. нужно проверить состав
            SELECT COUNT(1)
              INTO v_temp_count
              FROM T_EXCLUD_DMS_CONT a
             WHERE a.t_exclusion_dms_id = cur2.ID
               AND NOT EXISTS (SELECT 1
                      FROM ven_t_prod_line_dms       pld
                          ,ven_t_prod_line_option    plo
                          ,ven_t_prod_line_opt_peril plop
                          ,ven_t_prod_line_damage    plda
                     WHERE pld.T_PROD_LINE_DMS_ID = p_prod_line_id
                       AND plop.PERIL_ID = p_perid_in_id
                       AND plo.PRODUCT_LINE_ID = pld.T_PROD_LINE_DMS_ID
                       AND plop.PRODUCT_LINE_OPTION_ID = plo.ID
                       AND plda.T_PROD_LINE_OPT_PERIL_ID = plop.ID
                       AND plda.T_DAMAGE_CODE_ID = a.t_damage_code_id
                       AND plda.IS_EXCLUDED = 1);
            IF v_temp_count = 0
            THEN
              v_find_flg := 1;
              v_final_id := cur2.ID;
              EXIT;
            END IF;
          END IF;
        END LOOP;
      
        IF v_find_flg = 0
        THEN
          RETURN(insert_new_excud(p_prod_line_id, p_perid_in_id));
        ELSE
          SELECT brief INTO v_brief FROM T_EXCLUSION_DMS WHERE t_exclusion_dms_id = v_final_id;
          RETURN v_brief;
        END IF;
      
      END IF;
    END LOOP;
  
    RETURN NULL;
  END;

  FUNCTION copy_progs
  (
    to_id            IN NUMBER
   ,from_id          IN NUMBER
   ,contr_lpu_ver_id IN NUMBER DEFAULT NULL
  ) RETURN BOOLEAN IS
    temp_id                       NUMBER;
    temp_id1                      NUMBER;
    temp_id2                      NUMBER;
    temp_descr                    VARCHAR2(4000);
    temp_med1                     NUMBER;
    temp_med2                     NUMBER;
    v_prodline_metdec_met_decl_id NUMBER;
  
    cur_brief  VARCHAR2(200);
    cur_brief1 VARCHAR2(200);
    v_type     VARCHAR2(200);
    v_type1    VARCHAR2(200);
  
    temp_note VARCHAR2(4000);
  
    v_name VARCHAR2(4000);
    v_sum  NUMBER;
    v_sum1 NUMBER;
  BEGIN
  
    BEGIN
      SELECT t1.BRIEF
            ,t2.brief
            ,plt1.BRIEF
            ,plt2.BRIEF
        INTO cur_brief
            ,cur_brief1
            ,v_type
            ,v_type1
        FROM ven_t_prod_line_dms pld1
            ,ven_t_prod_line_dms pld2
            ,ven_dms_prog_type   t1
            ,ven_dms_prog_type   t2
            ,t_product_line_type plt1
            ,t_product_line_type plt2
       WHERE pld1.T_PROD_LINE_DMS_ID = to_id
         AND pld2.T_PROD_LINE_DMS_ID = from_id
            --AND pld1.DMS_PROG_TYPE_ID = pld2.DMS_PROG_TYPE_ID
         AND pld1.DMS_PROG_TYPE_ID = t1.DMS_PROG_TYPE_ID
         AND pld2.DMS_PROG_TYPE_ID = t2.DMS_PROG_TYPE_ID
         AND pld1.PRODUCT_LINE_TYPE_ID = plt1.PRODUCT_LINE_TYPE_ID
         AND pld2.PRODUCT_LINE_TYPE_ID = plt2.PRODUCT_LINE_TYPE_ID;
    EXCEPTION
      WHEN OTHERS THEN
        -- Копируются программы разных типов
        RETURN FALSE;
    END;
  
    IF cur_brief <> cur_brief1
    THEN
      IF v_type1 = 'RISC'
         AND v_type = 'DEPOS'
      THEN
        NULL;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  
    copy_pr_ter(to_id, from_id);
    copy_pr_coef(to_id, from_id);
    copy_pr_med(to_id, from_id);
    copy_pr_except(to_id, from_id);
    copy_pr_depos(to_id, from_id);
  
    -- Копирование ЗСП
    BEGIN
      SELECT *
        INTO v_prodline_metdec_met_decl_id
        FROM (SELECT t_prodline_metdec_met_decl_id
                FROM ven_t_prod_line_met_decl
               WHERE t_prodline_metdec_prod_line_id = from_id
               ORDER BY is_default DESC)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_prodline_metdec_met_decl_id := NULL;
    END;
  
    INSERT INTO ven_t_prod_line_met_decl
      (t_prod_line_met_decl_id, t_prodline_metdec_prod_line_id, t_prodline_metdec_met_decl_id)
    VALUES
      (sq_t_prod_line_met_decl.NEXTVAL, to_id, v_prodline_metdec_met_decl_id);
  
    -- Копирование примечаний
    SELECT note INTO temp_note FROM ven_t_prod_line_dms WHERE t_prod_line_dms_id = from_id;
    UPDATE ven_t_prod_line_dms SET note = temp_note WHERE t_prod_line_dms_id = to_id;
  
    IF cur_brief = 'INSPR'
    THEN
    
      SELECT pld.description
            ,pld.INS_AMOUNT
            ,pld.INS_PREMIUM
        INTO v_name
            ,v_sum
            ,v_sum1
        FROM ven_t_prod_line_dms pld
       WHERE pld.t_prod_line_dms_id = from_id;
    
      UPDATE ven_t_prod_line_dms
         SET description = v_name
            ,ins_amount  = DECODE(NVL(pkg_app_param.GET_APP_PARAM_N('DMS_UPDATE_SUM_BY_COPY'), 0)
                                 ,1
                                 ,v_sum
                                 ,ins_amount)
            ,ins_premium = DECODE(NVL(pkg_app_param.GET_APP_PARAM_N('DMS_UPDATE_SUM_BY_COPY'), 0)
                                 ,1
                                 ,v_sum1
                                 ,ins_premium)
       WHERE t_prod_line_dms_id = to_id;
    
      FOR par IN (SELECT * FROM ven_parent_prod_line_dms a WHERE a.t_parent_prod_line_id = from_id)
      LOOP
      
        SELECT COUNT(1)
          INTO temp_id
          FROM ven_parent_prod_line_dms
         WHERE t_prod_line_id = par.t_prod_line_id
           AND t_parent_prod_line_id = to_id;
      
        IF temp_id = 0
        THEN
          SELECT sq_parent_prod_line_dms.NEXTVAL INTO temp_id FROM dual;
          INSERT INTO ven_parent_prod_line_dms
            (parent_prod_line_dms_id
            ,ent_id
            ,filial_id
            ,ext_id
            ,t_prod_line_id
            ,t_parent_prod_line_id
            ,amount
            ,dms_repay_method_id
            ,dms_recalc_method_id
            ,PRODUCT_VER_LOB_ID)
          VALUES
            (temp_id
            ,par.ent_id
            ,par.filial_id
            ,par.ext_id
            ,par.t_prod_line_id
            ,to_id
            ,par.amount
            ,par.dms_repay_method_id
            ,par.dms_recalc_method_id
            ,par.PRODUCT_VER_LOB_ID);
        ELSE
          SELECT parent_prod_line_dms_id
            INTO temp_id
            FROM ven_parent_prod_line_dms
           WHERE t_prod_line_id = par.t_prod_line_id
             AND t_parent_prod_line_id = to_id;
        END IF;
        -- в temp_id = ссылка на новую запись
        -- в par.parent_prod_line_id = на старую запись
      
        FOR par_lpu IN (SELECT *
                          FROM ven_par_prod_line_cont a
                         WHERE a.parent_prod_line_id = par.parent_prod_line_dms_id
                           AND NOT EXISTS (SELECT 1
                                  FROM ven_par_prod_line_cont b
                                 WHERE b.parent_prod_line_id = temp_id
                                   AND b.contract_lpu_ver_id = a.CONTRACT_LPU_VER_ID
                                   AND b.contact_id = a.CONTACT_ID))
        LOOP
          INSERT INTO ven_par_prod_line_cont
            (par_prod_line_cont_id
            ,ent_id
            ,filial_id
            ,ext_id
            ,contact_id
            ,contract_lpu_ver_id
            ,parent_prod_line_id)
          VALUES
            (sq_par_prod_line_cont.NEXTVAL
            ,par_lpu.ent_id
            ,par_lpu.filial_id
            ,par_lpu.ext_id
            ,par_lpu.contact_id
            ,par_lpu.contract_lpu_ver_id
            ,temp_id);
        
        END LOOP;
      
      END LOOP;
    
      RETURN TRUE;
    ELSE
      -- копирование базовых программ и программ ЛПУ
    
      --копирование болезней
      FOR cur IN (SELECT a.dms_mkb_id
                    FROM ven_t_prod_line_mkb a
                   WHERE a.product_line_id = from_id
                     AND NOT EXISTS (SELECT 1
                            FROM ven_t_prod_line_mkb b
                           WHERE b.product_line_id = to_id
                             AND b.dms_mkb_id = a.dms_mkb_id))
      LOOP
      
        INSERT INTO ven_t_prod_line_mkb
          (t_prod_line_mkb_id, product_line_id, dms_mkb_id)
        VALUES
          (sq_t_prod_line_mkb.NEXTVAL, to_id, cur.dms_mkb_id);
      
      END LOOP;
    
      BEGIN
        --копирование ЛПУ
        IF cur_brief = 'LPU'
           AND contr_lpu_ver_id IS NULL
        THEN
          NULL;
        ELSE
          FOR cur IN (SELECT a.contact_id
                            ,a.t_prod_line_contact_id
                            ,contract_lpu_ver_id
                        FROM ven_t_prod_line_contact a
                       WHERE a.product_line_id = from_id)
          LOOP
            -- cur.t_prod_line_contact_id = старая ссылка на контакт
            -- temp_id - будет новая ссылка
          
            --nvl(contr_lpu_ver_id,cur.contract_lpu_ver_id)
            -- если contr_lpu_ver_id - то идет копирование программы для
            -- новой версии контракта ЛПУ
          
            -- проверяем наличие уже новой записи
            SELECT COUNT(1)
              INTO temp_id2
              FROM ven_t_prod_line_contact
             WHERE contact_id = cur.contact_id
               AND contract_lpu_ver_id = NVL(contr_lpu_ver_id, cur.contract_lpu_ver_id)
               AND product_line_id = to_id;
          
            IF temp_id2 > 0
            THEN
              SELECT t_prod_line_contact_id
                INTO temp_id
                FROM ven_t_prod_line_contact
               WHERE contact_id = cur.contact_id
                 AND contract_lpu_ver_id = NVL(contr_lpu_ver_id, cur.contract_lpu_ver_id)
                 AND product_line_id = to_id;
            ELSE
              SELECT sq_t_prod_line_contact.NEXTVAL INTO temp_id FROM dual;
              INSERT INTO ven_t_prod_line_contact
                (t_prod_line_contact_id, product_line_id, contact_id, contract_lpu_ver_id)
              VALUES
                (temp_id, to_id, cur.contact_id, NVL(contr_lpu_ver_id, cur.contract_lpu_ver_id));
            END IF;
          
            --копирование помощи ЛПУ
            FOR cur1 IN (SELECT a.dms_aid_type_id
                           FROM ven_t_prod_line_aid a
                          WHERE a.t_prod_line_contact_id = cur.t_prod_line_contact_id
                            AND NOT EXISTS (SELECT 1
                                   FROM ven_t_prod_line_aid b
                                  WHERE b.t_prod_line_contact_id = temp_id
                                    AND b.dms_aid_type_id = a.dms_aid_type_id))
            LOOP
            
              INSERT INTO ven_t_prod_line_aid
                (t_prod_line_aid_id, t_prod_line_contact_id, dms_aid_type_id)
              VALUES
                (sq_t_prod_line_aid.NEXTVAL, temp_id, cur1.dms_aid_type_id);
            
            END LOOP;
          END LOOP;
          RETURN TRUE;
        END IF;
        RETURN TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
      END;
    END IF;
    RETURN TRUE;
  END;

  --------------------------------------------------------------------
  --------------------------------------------------------------------
  PROCEDURE copy_plo(p_prod_line_id IN NUMBER) IS
  BEGIN
    INSERT INTO ven_t_prod_line_option
      (product_line_id, description)
      SELECT pl.T_PROD_LINE_DMS_ID
            ,pl.DESCRIPTION
        FROM ven_t_prod_line_dms pl
       WHERE pl.T_PROD_LINE_DMS_ID = p_prod_line_id;
  END;

  --------------------------------------------------------------------
  --------------------------------------------------------------------

  PROCEDURE copy_policy
  (
    new_pol_id NUMBER
   ,old_pol_id NUMBER
  ) IS
  
    v_new_prod_line_id NUMBER;
    res                BOOLEAN;
  
    v_temp_id NUMBER;
  
    CURSOR pol(p_old_pol_id NUMBER) IS
      SELECT * FROM ven_t_prod_line_dms WHERE p_policy_id = p_old_pol_id;
  BEGIN
    FOR cur1 IN pol(old_pol_id)
    LOOP
      --1.нужно создать дубликат записи в prod_line_dms
      --2.скопировать содержимое одного полиса в другой
    
      SELECT sq_t_prod_line_dms.NEXTVAL INTO v_new_prod_line_id FROM dual;
      INSERT INTO INS.VEN_T_PROD_LINE_DMS
        (T_PROD_LINE_DMS_ID
        ,ENT_ID
        ,FILIAL_ID
        ,EXT_ID
        ,DEDUCT_FUNC
        ,DEDUCT_FUNC_ID
        ,DEFAULT_FORMS
        ,DESCRIPTION
        ,FOR_PREMIUM
        ,INSURANCE_GROUP_ID
        ,INS_AMOUNT
        ,INS_AMOUNT_FUNC
        ,INS_AMOUNT_FUNC_ID
        ,INS_PREMIUM
        ,INS_PRICE_FUNC
        ,INS_PRICE_FUNC_ID
        ,IS_AGGREGATE
        ,IS_AVTOPROLONGATION
        ,IS_DEFAULT
        ,NOTE
        ,PREMIUM_FUNC
        ,PREMIUM_FUNC_ID
        ,PREMIUM_TYPE
        ,PRODUCT_LINE_TYPE_ID
        ,PRODUCT_VER_LOB_ID
        ,SORT_ORDER
        ,TARIFF_FUNC
        ,TARIFF_FUNC_ID
        ,T_LOB_LINE_ID
        ,VISIBLE_FLAG
        ,CODE
        ,DMS_PROG_TYPE_ID
        ,END_DATE
        ,P_POLICY_ID
        ,SHORT_NAME
        ,START_DATE
        ,pr_depos
        ,pr_rvd
        ,dms_repay_method_id
        ,dms_recalc_method_id
        ,old_id)
        SELECT v_new_prod_line_id --новое значение
              ,a.ent_id
              ,a.filial_id
              ,a.ext_id
              ,a.deduct_func
              ,a.deduct_func_id
              ,a.default_forms
              ,a.description
              ,a.for_premium
              ,a.insurance_group_id
              ,a.ins_amount
              ,a.ins_amount_func
              ,a.ins_amount_func_id
              ,a.ins_premium
              ,a.ins_price_func
              ,a.ins_price_func_id
              ,a.is_aggregate
              ,a.is_avtoprolongation
              ,a.is_default
              ,a.note
              ,a.premium_func
              ,a.premium_func_id
              ,a.premium_type
              ,a.product_line_type_id
              ,a.product_ver_lob_id
              ,a.sort_order
              ,a.tariff_func
              ,a.tariff_func_id
              ,a.t_lob_line_id
              ,a.visible_flag
              ,a.code
              ,a.dms_prog_type_id
              ,a.end_date
              ,new_pol_id --новое значение
              ,a.short_name
              ,a.start_date
              ,a.pr_depos
              ,a.pr_rvd
              ,a.dms_repay_method_id
              ,a.dms_recalc_method_id
              ,a.t_prod_line_dms_id --старая ссылка на программу
          FROM ven_t_prod_line_dms a
         WHERE a.p_policy_id = old_pol_id
           AND a.t_prod_line_dms_id = cur1.t_prod_line_dms_id;
    
      copy_plo(v_new_prod_line_id);
      ins_deduct(v_new_prod_line_id);
      res := copy_progs(v_new_prod_line_id, cur1.t_prod_line_dms_id);
    
      BEGIN
        SELECT t_metod_decline_id INTO v_temp_id FROM ven_t_metod_decline WHERE brief = 'ZSP_DMS';
      
        --select sq_t_prod_line_met_decl.nextval into v_id from dual;
        INSERT INTO ven_t_prod_line_met_decl
          (t_prodline_metdec_prod_line_id, t_prodline_metdec_met_decl_id)
        VALUES
          (v_new_prod_line_id, v_temp_id);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      FOR cur IN (SELECT * FROM prod_line_dms_depos WHERE p_policy_id = old_pol_id)
      LOOP
        INSERT INTO ven_prod_line_dms_depos t
          (t.DEPOS_PR, t.DEPOS_SUM, t.DESCRIPTION, t.P_POLICY_ID)
        VALUES
          (cur.depos_pr, cur.depos_sum, cur.description, new_pol_id);
      END LOOP;
    
    END LOOP;
  END;
  --------------------------------------------------------------------
  --------------------------------------------------------------------
  PROCEDURE copy_contract_lpu
  (
    new_contr_id NUMBER
   ,old_contr_id NUMBER
   ,p_start_date DATE DEFAULT NULL
   ,p_end_date   DATE DEFAULT NULL
  ) IS
  
    v_new_prod_line_id NUMBER;
    res                BOOLEAN;
    v_cur_end_date     DATE;
  
    CURSOR lpu(cur_old_contr_id NUMBER) IS
      SELECT * FROM ven_t_prod_line_contact WHERE contract_lpu_ver_id = cur_old_contr_id;
  
  BEGIN
  
    SELECT TRUNC(end_date)
      INTO v_cur_end_date
      FROM contract_lpu_ver
     WHERE contract_lpu_ver_id = old_contr_id;
  
    FOR cur1 IN lpu(old_contr_id)
    LOOP
      --1.нужно создать дубликат записи в prod_line_dms
    
      SELECT sq_t_prod_line_dms.NEXTVAL INTO v_new_prod_line_id FROM dual;
      INSERT INTO INS.VEN_T_PROD_LINE_DMS
        (T_PROD_LINE_DMS_ID
        ,ENT_ID
        ,FILIAL_ID
        ,EXT_ID
        ,DEDUCT_FUNC
        ,DEDUCT_FUNC_ID
        ,DEFAULT_FORMS
        ,DESCRIPTION
        ,FOR_PREMIUM
        ,INSURANCE_GROUP_ID
        ,INS_AMOUNT
        ,INS_AMOUNT_FUNC
        ,INS_AMOUNT_FUNC_ID
        ,INS_PREMIUM
        ,INS_PRICE_FUNC
        ,INS_PRICE_FUNC_ID
        ,IS_AGGREGATE
        ,IS_AVTOPROLONGATION
        ,IS_DEFAULT
        ,NOTE
        ,PREMIUM_FUNC
        ,PREMIUM_FUNC_ID
        ,PREMIUM_TYPE
        ,PRODUCT_LINE_TYPE_ID
        ,PRODUCT_VER_LOB_ID
        ,SORT_ORDER
        ,TARIFF_FUNC
        ,TARIFF_FUNC_ID
        ,T_LOB_LINE_ID
        ,VISIBLE_FLAG
        ,CODE
        ,DMS_PROG_TYPE_ID
        ,END_DATE
        ,P_POLICY_ID
        ,SHORT_NAME
        ,START_DATE
        ,pr_depos
        ,pr_rvd
        ,dms_repay_method_id
        ,dms_recalc_method_id)
        SELECT v_new_prod_line_id --новое значение
              ,a.ent_id
              ,a.filial_id
              ,a.ext_id
              ,a.deduct_func
              ,a.deduct_func_id
              ,a.default_forms
              ,a.description
              ,a.for_premium
              ,a.insurance_group_id
              ,a.ins_amount
              ,a.ins_amount_func
              ,a.ins_amount_func_id
              ,a.ins_premium
              ,a.ins_price_func
              ,a.ins_price_func_id
              ,a.is_aggregate
              ,a.is_avtoprolongation
              ,a.is_default
              ,a.note
              ,a.premium_func
              ,a.premium_func_id
              ,a.premium_type
              ,a.product_line_type_id
              ,a.product_ver_lob_id
              ,a.sort_order
              ,a.tariff_func
              ,a.tariff_func_id
              ,a.t_lob_line_id
              ,a.visible_flag
              ,a.code
              ,a.dms_prog_type_id
              ,DECODE(TRUNC(a.end_date), v_cur_end_date, NVL(p_end_date, a.end_date), a.end_date)
              ,
               --a.end_date,
               a.P_POLICY_ID
              ,a.short_name
              ,a.start_date
              ,a.pr_depos
              ,a.pr_rvd
              ,a.dms_repay_method_id
              ,a.dms_recalc_method_id
          FROM ven_t_prod_line_dms a
         WHERE a.t_prod_line_dms_id = cur1.product_line_id;
    
      ins_deduct(v_new_prod_line_id);
      res := copy_progs(v_new_prod_line_id, cur1.product_line_id, new_contr_id);
    
    END LOOP;
  END;

  PROCEDURE ins_deduct(new_prod_line NUMBER) IS
  BEGIN
    INSERT INTO T_PROD_LINE_DEDUCT
      (ID, PRODUCT_LINE_ID, DEDUCTIBLE_REL_ID, IS_DEFAULT)
    VALUES
      (sq_t_prod_line_deduct.NEXTVAL, new_prod_line, 1, 1);
  END;
  --------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------
  PROCEDURE copy_pr_ter
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
  BEGIN
    FOR cur IN (SELECT a.t_territory_id
                  FROM ven_t_prod_line_ter a
                 WHERE a.product_line_id = from_id
                   AND NOT EXISTS (SELECT 1
                          FROM ven_t_prod_line_ter b
                         WHERE b.product_line_id = to_id
                           AND b.t_territory_id = a.t_territory_id))
    LOOP
    
      INSERT INTO ven_t_prod_line_ter
        (t_prod_line_ter_id, product_line_id, t_territory_id)
      VALUES
        (sq_t_prod_line_ter.NEXTVAL, to_id, cur.t_territory_id);
    
    END LOOP;
  END;
  --------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------
  PROCEDURE copy_pr_coef
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
  BEGIN
    FOR cur IN (SELECT a.t_prod_coef_type_id
                      ,a.is_restriction
                  FROM ven_t_prod_line_coef a
                 WHERE a.t_product_line_id = from_id
                   AND NOT EXISTS (SELECT 1
                          FROM ven_t_prod_line_coef b
                         WHERE b.t_product_line_id = to_id
                           AND b.t_prod_coef_type_id = a.t_prod_coef_type_id))
    LOOP
    
      INSERT INTO ven_t_prod_line_coef
        (t_prod_line_coef_id, t_product_line_id, t_prod_coef_type_id, is_restriction)
      VALUES
        (sq_t_prod_line_coef.NEXTVAL, to_id, cur.t_prod_coef_type_id, cur.is_restriction);
    
    END LOOP;
  END;
  --------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------
  PROCEDURE copy_pr_except
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
  BEGIN
    FOR cur IN (SELECT a.dms_except_code_id
                      ,a.t_peril_id
                  FROM ven_dms_prog_except_code a
                 WHERE a.t_prod_line_dms_id = from_id
                   AND NOT EXISTS (SELECT 1
                          FROM ven_dms_prog_except_code b
                         WHERE b.t_prod_line_dms_id = to_id
                           AND b.dms_except_code_id = a.dms_except_code_id
                           AND NVL(b.t_peril_id, -1) = NVL(a.t_peril_id, -1)))
    LOOP
    
      INSERT INTO ven_dms_prog_except_code
        (dms_prog_except_code_id, t_prod_line_dms_id, dms_except_code_id, t_peril_id)
      VALUES
        (sq_dms_prog_except_code.NEXTVAL, to_id, cur.dms_except_code_id, cur.t_peril_id);
    
    END LOOP;
  END;
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------

  PROCEDURE copy_pr_depos
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
  BEGIN
    FOR cur IN (SELECT a.t_prod_line_dms_depos_id
                  FROM ven_rel_prodline_depos a
                 WHERE a.t_prod_line_dms_id = from_id
                   AND NOT EXISTS
                 (SELECT 1
                          FROM ven_rel_prodline_depos b
                         WHERE b.t_prod_line_dms_id = to_id
                           AND b.t_prod_line_dms_depos_id = a.t_prod_line_dms_depos_id))
    LOOP
    
      INSERT INTO ven_rel_prodline_depos
        (rel_prodline_depos_id, t_prod_line_dms_id, t_prod_line_dms_depos_id)
      VALUES
        (sq_rel_prodline_depos.NEXTVAL, to_id, cur.t_prod_line_dms_depos_id);
    
    END LOOP;
  END;

  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------

  PROCEDURE copy_pr_executer
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
    cur_brief          VARCHAR2(50);
    v_par_prod_line_id NUMBER;
  BEGIN
    --подразумевается, что происходит копирование программ в страховой продукт
    BEGIN
      SELECT t.BRIEF
        INTO cur_brief
        FROM ven_t_prod_line_dms pld
            ,ven_dms_prog_type   t
       WHERE pld.T_PROD_LINE_DMS_ID = from_id
         AND pld.DMS_PROG_TYPE_ID = t.DMS_PROG_TYPE_ID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Невозможно получить тип программы. ' || SQLERRM);
    END;
  
    SELECT parent_prod_line_id
      INTO v_par_prod_line_id
      FROM ven_parent_prod_line
     WHERE t_parent_prod_line_id = to_id
       AND t_prod_line_id = from_id;
  
    CASE cur_brief
      WHEN 'LPU' THEN
        FOR cur IN (SELECT plc.contact_id
                          ,plc.CONTRACT_LPU_VER_ID
                      FROM ven_t_prod_line_dms     pld
                          ,ven_t_prod_line_contact plc
                     WHERE pld.t_prod_line_dms_id = from_id
                       AND plc.product_line_id = pld.t_prod_line_dms_id
                       AND NOT EXISTS (SELECT (1)
                              FROM ven_par_prod_line_cont a
                                  ,ven_parent_prod_line   b
                             WHERE a.contact_id = plc.contact_id
                               AND a.CONTRACT_LPU_VER_ID = plc.CONTRACT_LPU_VER_ID
                               AND a.parent_prod_line_id = v_par_prod_line_id))
        LOOP
          INSERT INTO ven_par_prod_line_cont
            (contact_id, contract_lpu_ver_id, parent_prod_line_id)
          VALUES
            (cur.contact_id, cur.contract_lpu_ver_id, v_par_prod_line_id);
        END LOOP;
      WHEN 'INSPR' THEN
        FOR cur IN (SELECT DISTINCT pplc.contact_id
                                   ,pplc.contract_lpu_ver_id
                      FROM parent_prod_line   ppl
                          ,par_prod_line_cont pplc
                     WHERE pplc.parent_prod_line_id = ppl.parent_prod_line_id
                       AND ppl.t_parent_prod_line_id = from_id
                       AND NOT EXISTS (SELECT (1)
                              FROM ven_par_prod_line_cont a
                                  ,ven_parent_prod_line   b
                             WHERE a.contact_id = pplc.contact_id
                               AND a.CONTRACT_LPU_VER_ID = pplc.CONTRACT_LPU_VER_ID
                               AND a.parent_prod_line_id = v_par_prod_line_id))
        LOOP
          INSERT INTO ven_par_prod_line_cont
            (contact_id, contract_lpu_ver_id, parent_prod_line_id)
          VALUES
            (cur.contact_id, cur.contract_lpu_ver_id, v_par_prod_line_id);
        END LOOP;
      ELSE
        NULL;
    END CASE;
  END;

  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------

  PROCEDURE copy_pr_med
  (
    to_id   IN NUMBER
   ,from_id IN NUMBER
  ) IS
    temp_id       NUMBER;
    temp_id1      NUMBER;
    temp_descr    VARCHAR2(4000);
    temp_med1     NUMBER;
    count_exc_new NUMBER;
    count_exc_old NUMBER;
    copy_exc_flg  NUMBER;
    temp_limit    VARCHAR2(200);
  BEGIN
    --получаем данные о копируемой записи
    SELECT ID
          ,description
      INTO temp_id1
          ,temp_descr
      FROM ven_t_prod_line_option
     WHERE product_line_id = from_id
       AND ROWNUM = 1;
  
    --проверяем на наличие уже новой записи (которая была создана при первом копированиии)
    SELECT COUNT(1) INTO temp_id FROM ven_t_prod_line_option WHERE product_line_id = to_id;
    IF temp_id = 0
    THEN
      --записи нет, нужно ее создать
      SELECT sq_t_prod_line_option.NEXTVAL INTO temp_id FROM dual;
      INSERT INTO ven_t_prod_line_option
        (ID, product_line_id, description)
      VALUES
        (temp_id, to_id, temp_descr);
    ELSE
      --запись есть
      SELECT ID
        INTO temp_id
        FROM ven_t_prod_line_option
       WHERE product_line_id = to_id
         AND ROWNUM = 1;
    END IF;
  
    --в temp_id - храниться ссылка на новую Option
    --в temp_id1 - на старую
  
    --копирование мед помощи
  
    --получаем данные о копируемой записе
    FOR med IN (SELECT ID
                      ,peril_id
                  FROM ven_t_prod_line_opt_peril
                 WHERE product_line_option_id = temp_id1)
    LOOP
    
      --проверяем на наличие уже новой записи (которая была создана при первом копированиии)
      SELECT COUNT(1)
        INTO temp_med1
        FROM ven_t_prod_line_opt_peril
       WHERE product_line_option_id = temp_id --новая строка
         AND peril_id = med.peril_id;
    
      IF temp_med1 > 0
      THEN
        SELECT ID
          INTO temp_med1
          FROM T_PROD_LINE_OPT_PERIL
         WHERE product_line_option_id = temp_id --новая строка
           AND peril_id = med.peril_id;
        copy_exc_flg := 0; --можно только удалять существующие исключения
      
      ELSE
        SELECT sq_t_prod_line_opt_peril.NEXTVAL INTO temp_med1 FROM dual;
        INSERT INTO T_PROD_LINE_OPT_PERIL
          (ID, product_line_option_id, peril_id)
        VALUES
          (temp_med1, temp_id, med.peril_id);
        copy_exc_flg := 1; -- можно добавлять любые исключения
      END IF;
    
      --temp_med1 - ссылка на новую строку
      --med.id - ссылка на старую строку
    
      --копирование исключений
      IF copy_exc_flg = 1
      THEN
        FOR med2 IN (SELECT a.t_damage_code_id
                           ,a.is_excluded
                           ,a.LIMIT
                       FROM ven_t_prod_line_damage a
                      WHERE a.t_prod_line_opt_peril_id = med.ID
                     -- and not exists (
                     --  select 1 from ven_t_prod_line_damage b
                     -- where b.t_prod_line_opt_peril_id = temp_med1
                     --  and b.t_damage_code_id = a.t_damage_code_id)
                     )
        LOOP
          INSERT INTO ven_t_prod_line_damage
            (t_prod_line_damage_id, t_prod_line_opt_peril_id, t_damage_code_id, is_excluded, LIMIT)
          VALUES
            (sq_t_prod_line_damage.NEXTVAL
            ,temp_med1
            ,med2.t_damage_code_id
            ,med2.is_excluded
            ,med2.LIMIT);
        END LOOP;
      ELSE
        -- прежде всего нужно удалить те исключения, на которых нет ограничений
        FOR exc1 IN (SELECT pld.t_prod_line_damage_id ID
                       FROM T_PROD_LINE_DAMAGE pld
                      WHERE pld.t_prod_line_opt_peril_id = temp_med1
                        AND NOT EXISTS (SELECT 1
                               FROM T_PROD_LINE_DAMAGE a
                              WHERE a.t_prod_line_opt_peril_id = med.ID
                                AND a.t_damage_code_id = pld.t_damage_code_id))
        LOOP
        
          DELETE T_PROD_LINE_DAMAGE WHERE t_prod_line_damage_id = exc1.ID;
        
        END LOOP;
        -- теперь нужно разобраться с ограничениями
        FOR exc2 IN (SELECT pld.t_prod_line_damage_id ID
                           ,t_damage_code_id          dam_id
                       FROM T_PROD_LINE_DAMAGE pld
                      WHERE pld.t_prod_line_opt_peril_id = temp_med1
                        AND is_excluded = 1)
        LOOP
          BEGIN
            SELECT a.LIMIT
              INTO temp_limit
              FROM T_PROD_LINE_DAMAGE a
             WHERE a.t_damage_code_id = exc2.dam_id
               AND a.t_prod_line_opt_peril_id = med.ID
               AND a.is_excluded = 0;
            UPDATE T_PROD_LINE_DAMAGE b
               SET b.is_excluded = 0
                  ,b.LIMIT       = temp_limit
             WHERE b.t_prod_line_damage_id = exc2.ID
               AND t_prod_line_opt_peril_id = temp_med1;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        
        END LOOP;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  FUNCTION create_pay_for_act(p_act_id IN NUMBER) RETURN NUMBER IS
    v_paym   ven_ac_payment%ROWTYPE;
    temp_num NUMBER;
  BEGIN
    --проверка существования данного платежа
    SELECT COUNT(1) INTO temp_num FROM DOC_DOC WHERE parent_id = p_act_id;
    IF temp_num = 1
    THEN
      SELECT child_id INTO temp_num FROM DOC_DOC WHERE parent_id = p_act_id;
      RETURN temp_num;
    ELSIF temp_num > 1
    THEN
      RETURN 0;
    END IF;
  
    BEGIN
    
      --берем данные из родительского счета
      SELECT ap.payment_type_id
            ,ap.payment_direct_id
            ,ap.due_date
            ,ap.grace_date
            ,ap.real_pay_date
            ,ap.fund_id
            ,ap.contact_id
            ,ap.payment_terms_id
            ,ap.collection_metod_id
            ,ap.contact_bank_acc_id
            ,ap.company_bank_acc_id
            ,ap.rev_amount
            ,ap.rev_fund_id
            ,ap.rev_rate
            ,ap.rev_rate_type_id
            ,ap.is_agent
            ,ap.comm_amount
        INTO v_paym.payment_type_id
            ,v_paym.payment_direct_id
            ,v_paym.due_date
            ,v_paym.grace_date
            ,v_paym.real_pay_date
            ,v_paym.fund_id
            ,v_paym.contact_id
            ,v_paym.payment_terms_id
            ,v_paym.collection_metod_id
            ,v_paym.contact_bank_acc_id
            ,v_paym.company_bank_acc_id
            ,v_paym.rev_amount
            ,v_paym.rev_fund_id
            ,v_paym.rev_rate
            ,v_paym.rev_rate_type_id
            ,v_paym.is_agent
            ,v_paym.comm_amount
        FROM DMS_ACT      da
            ,DOC_DOC      da_dd_sa
            ,DMS_SERV_ACT sa
            ,DOC_DOC      sa_dd_ap
            ,AC_PAYMENT   ap
       WHERE da.DMS_ACT_ID = p_act_id
         AND da_dd_sa.CHILD_ID = da.DMS_ACT_ID
         AND sa.DMS_SERV_ACT_ID = da_dd_sa.PARENT_ID
         AND sa_dd_ap.CHILD_ID = da_dd_sa.PARENT_ID
         AND ap.PAYMENT_ID = sa_dd_ap.PARENT_ID;
    
      -- специфические данные
      SELECT doc_templ_id INTO v_paym.doc_templ_id FROM DOC_TEMPL WHERE brief = 'OrdOnRecAct';
      SELECT payment_templ_id
        INTO v_paym.payment_templ_id
        FROM AC_PAYMENT_TEMPL
       WHERE brief = 'OrdOnRecAct';
      SELECT num || '\1' INTO v_paym.num FROM DOCUMENT WHERE document_id = p_act_id;
      SELECT SYSDATE INTO v_paym.reg_date FROM dual;
    
    EXCEPTION
      WHEN OTHERS THEN
        --error на одном из селектов
        RETURN 0;
    END;
  
    SELECT sq_ac_payment.NEXTVAL INTO v_paym.payment_id FROM dual;
  
    v_paym.payment_number := 1;
  
    SELECT NVL(SUM(serv_amount), 0)
      INTO v_paym.amount
      FROM DMS_ACT          da
          ,DMS_REL_SERV_ACT rsa
     WHERE da.dms_act_id = p_act_id
       AND rsa.dms_act_id = da.dms_act_id;
  
    INSERT INTO ven_ac_payment VALUES v_paym;
    INSERT INTO DOC_DOC
      (doc_doc_id, parent_id, child_id)
    VALUES
      (sq_doc_doc.NEXTVAL, p_act_id, v_paym.payment_id);
  
    RETURN v_paym.payment_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      --скорее всего insert не прошел
      RETURN 0;
  END;

  -- Процедура смены статуса реестра оказанных услуг и всех сопутствующих документов (счет, акт, счет-фактура)
  PROCEDURE set_dms_serv_reg_status(p_document_id IN NUMBER) IS
    CURSOR cur_act IS
      SELECT ap.payment_id
            ,dsa.dms_serv_act_id
        FROM ven_dms_serv_reg dsr
            ,ven_doc_doc      dd
            ,ven_dms_serv_act dsa
            ,ven_doc_templ    dt
            ,ven_ac_payment   ap
            ,ven_doc_doc      dd1
            ,ven_doc_templ    dt1
       WHERE dt1.brief IN ('DMS_INV_LPU_SERV')
         AND dt1.doc_templ_id = ap.doc_templ_id
         AND ap.payment_id = dd1.parent_id
         AND dd1.child_id = dsa.dms_serv_act_id
         AND dt.brief IN ('DMS_SERV_ACT', 'DMS_SERV_INV')
         AND dt.doc_templ_id = dsa.doc_templ_id
         AND dsa.dms_serv_act_id = dd.parent_id
         AND dd.child_id = dsr.dms_serv_reg_id
         AND dsr.dms_serv_reg_id = p_document_id;
  
    v_reg_status_brief VARCHAR2(50);
  BEGIN
    v_reg_status_brief := Doc.get_doc_status_brief(p_document_id);
    FOR c_act IN cur_act
    LOOP
      IF Doc.get_doc_status_brief(c_act.payment_id) <> v_reg_status_brief
      THEN
        Doc.set_doc_status(c_act.payment_id
                          ,v_reg_status_brief
                          ,SYSDATE
                          ,'AUTO'
                          ,'Смена статуса пакета документов');
      END IF;
      IF Doc.get_doc_status_brief(c_act.dms_serv_act_id) <> v_reg_status_brief
      THEN
        Doc.set_doc_status(c_act.dms_serv_act_id
                          ,v_reg_status_brief
                          ,SYSDATE
                          ,'AUTO'
                          ,'Смена статуса пакета документов');
      END IF;
    END LOOP;
  END set_dms_serv_reg_status;

  -----------------------------------------------------------
  FUNCTION get_pol_num
  (
    p_pol_id     IN NUMBER
   ,p_session_id NUMBER
  ) RETURN VARCHAR2 IS
    v_temp     NUMBER;
    v_temp1    NUMBER;
    v_temp2    NUMBER;
    v_temp3    NUMBER;
    v_t_num    NUMBER;
    v_pol_num  VARCHAR2(200);
    v_temp_num VARCHAR2(200);
  BEGIN
    SELECT pp.pol_ser || '/' || pp.pol_num
          ,LTRIM(pp.POL_NUM, '0')
      INTO v_temp_num
          ,v_pol_num
      FROM ven_p_policy pp
     WHERE pp.POLICY_ID = p_pol_id;
  
    SELECT COUNT(1) INTO v_temp3 FROM as_asset aa WHERE aa.P_POLICY_ID = p_pol_id;
  
    BEGIN
      SELECT MAX(card_num)
        INTO v_temp1
        FROM (SELECT NVL(MAX(TO_NUMBER((SUBSTR(card_num, LENGTH(v_temp_num) + 2)))), 0) card_num
                FROM ven_as_assured
               WHERE p_policy_id = p_pol_id
                 AND card_num IS NOT NULL
                 AND card_num LIKE v_temp_num || '%'
              UNION
              SELECT NVL(MAX(TO_NUMBER((SUBSTR(bso_num, LENGTH(v_temp_num) + 2)))), 0) card_num
                FROM as_person_med_tmp
               WHERE bso_num IS NOT NULL
                 AND bso_num LIKE v_temp_num || '%'
                 AND session_id = p_session_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_temp1 := NULL;
    END;
  
    BEGIN
      SELECT MAX(card_num)
        INTO v_temp2
        FROM (SELECT NVL(MAX(TO_NUMBER((SUBSTR(card_num, LENGTH(v_pol_num) + 2)))), 0) card_num
                FROM ven_as_assured
               WHERE p_policy_id = p_pol_id
                 AND card_num IS NOT NULL
                 AND card_num LIKE v_pol_num || '%'
              UNION
              SELECT NVL(MAX(TO_NUMBER((SUBSTR(bso_num, LENGTH(v_pol_num) + 2)))), 0) card_num
                FROM as_person_med_tmp
               WHERE bso_num IS NOT NULL
                 AND bso_num LIKE v_pol_num || '%'
                 AND session_id = p_session_id);
    EXCEPTION
      WHEN INVALID_NUMBER THEN
        BEGIN
          SELECT NVL(MAX(TO_NUMBER((SUBSTR(bso_num, LENGTH(v_pol_num) + 2)))), 0)
            INTO v_temp2
            FROM as_person_med_tmp
           WHERE bso_num IS NOT NULL
             AND bso_num LIKE v_pol_num || '%'
             AND session_id = p_session_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp2 := NULL;
        END;
      
      WHEN OTHERS THEN
        v_temp2 := NULL;
    END;
  
    IF v_temp1 IS NULL
       AND v_temp2 IS NULL
    THEN
      BEGIN
        SELECT MAX(card_num)
          INTO v_temp
          FROM (SELECT NVL(TO_NUMBER(TRANSLATE(UPPER(card_num)
                                              ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ!?@#№$%^~&*(){}[]<>_-=+|,.;/\''"`'
                                              ,'0123456789'))
                          ,0) card_num
                  FROM ven_as_assured
                 WHERE p_policy_id = p_pol_id
                   AND card_num IS NOT NULL
                UNION
                SELECT NVL(TO_NUMBER(TRANSLATE(UPPER(bso_num)
                                              ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ!?@#№$%^~&*(){}[]<>_-=+|,.;/\''"`'
                                              ,'0123456789'))
                          ,0) card_num
                  FROM as_person_med_tmp
                 WHERE bso_num IS NOT NULL
                   AND session_id = p_session_id);
      EXCEPTION
        WHEN OTHERS THEN
          v_temp := 0;
      END;
    ELSE
      v_temp := GREATEST(NVL(v_temp1, 0), NVL(v_temp2, 0), NVL(v_temp3, 0));
    
    END IF;
  
    /* WHILE INSTR(v_temp, '-') > 0 LOOP
      v_temp := SUBSTR(v_temp, INSTR(v_temp, '-') + 1);
    END LOOP;*/
    /*    SELECT NVL(MAX(card_num), '-0')
      INTO v_temp
      FROM ven_as_assured
     WHERE p_policy_id = p_pol_id
       AND card_num IS NOT NULL
       AND card_num LIKE v_temp_num || '%';
    WHILE INSTR(v_temp, '-') > 0 LOOP
      v_temp := SUBSTR(v_temp, INSTR(v_temp, '-') + 1);
    END LOOP;*/
  
    v_t_num := v_temp + 1;
    --v_temp_num := v_temp_num || '-' || TO_CHAR(v_t_num);
    v_temp_num := v_pol_num || '-' || TO_CHAR(v_t_num);
  
    RETURN v_temp_num;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Функция расчета коэффициента для премии пропорционально дням прикрепления
  FUNCTION get_koef_for_premium(p_asset_id NUMBER) RETURN NUMBER IS
    CURSOR cur_days IS
      SELECT TRUNC(aa.end_date) - TRUNC(aa.start_date) asset_days
        FROM ven_as_asset aa
       WHERE aa.as_asset_id = p_asset_id;
  
    CURSOR cur_year IS
      SELECT TRUNC(TO_DATE('31/12/' || TO_CHAR(aa.end_date, 'YYYY'), 'DD/MM/YYYY')) -
             TRUNC(TO_DATE('01/01/' || TO_CHAR(aa.end_date, 'YYYY'), 'DD/MM/YYYY')) year_days
        FROM ven_as_asset aa
       WHERE aa.as_asset_id = p_asset_id;
    v_year_days  NUMBER;
    v_asset_days NUMBER;
    v_ret_val    NUMBER;
  BEGIN
    OPEN cur_year;
    FETCH cur_year
      INTO v_year_days;
    IF cur_year%NOTFOUND
    THEN
      v_year_days := NULL;
    END IF;
    CLOSE cur_year;
  
    OPEN cur_days;
    FETCH cur_days
      INTO v_asset_days;
    IF cur_days%NOTFOUND
    THEN
      v_asset_days := NULL;
    END IF;
    CLOSE cur_days;
  
    IF v_asset_days IS NOT NULL
       AND v_year_days IS NOT NULL
    THEN
      v_ret_val := ROUND(v_asset_days / v_year_days, 7);
    ELSE
      v_ret_val := 0;
    END IF;
  
    RETURN(v_ret_val);
  END get_koef_for_premium;

  PROCEDURE update_covers(p_new_pol_id IN NUMBER) IS
  BEGIN
  
    UPDATE P_COVER c
       SET c.t_prod_line_option_id =
           (SELECT plo2.ID
              FROM T_PROD_LINE_OPTION plo1
                  ,T_PROD_LINE_OPTION plo2
                  ,T_PROD_LINE_DMS    d
             WHERE plo1.ID = c.t_prod_line_option_id
               AND d.old_id = plo1.product_line_id
               AND plo2.product_line_id = d.t_prod_line_dms_id)
     WHERE c.p_cover_id IN (SELECT pc.p_cover_id
                              FROM AS_ASSET a
                                  ,P_COVER  pc
                             WHERE a.p_policy_id = p_new_pol_id
                               AND pc.as_asset_id = a.as_asset_id)
       AND c.t_prod_line_option_id IN
           (SELECT plo.ID
              FROM T_PROD_LINE_OPTION plo
                  ,T_PROD_LINE_DMS    d
             WHERE plo.ID = c.t_prod_line_option_id
               AND plo.product_line_id = d.old_id);
  
  END;

  FUNCTION get_programm_code(as_assured_id NUMBER) RETURN VARCHAR2 IS
    str VARCHAR2(1000);
  BEGIN
    FOR i IN (SELECT DISTINCT tpld.code
                FROM ven_as_asset           a
                    ,ven_p_cover            pc
                    ,ven_t_prod_line_option tplo
                    ,ven_t_prod_line_dms    tpld
               WHERE pc.as_asset_id = as_assured_id
                 AND tplo.ID = pc.t_prod_line_option_id
                 AND tpld.t_prod_line_dms_id = tplo.product_line_id)
    LOOP
      IF str IS NOT NULL
      THEN
        str := str || '; ' || i.code;
      ELSE
        str := i.code;
      END IF;
    END LOOP;
    RETURN(str);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /**
  * Форматированная строка номера документа-основания
  * @author Ilyushkin S.
  * @param p_document_id ИД документа
  * @return форматированная строка номера: <тип> <номер> от <дата>
  */
  FUNCTION get_parent_doc_name(p_document_id IN NUMBER) RETURN VARCHAR2 IS
    v_ret_val  VARCHAR2(500) := NULL;
    v_type_str VARCHAR2(100);
    v_num_str  VARCHAR2(300);
    v_date_str VARCHAR2(100);
  
    CURSOR cur_find IS
      SELECT dt.brief
            ,ap.num
            ,TO_CHAR(ap.date_ext, 'DD.MM.YYYY') date_ext
        FROM ven_ac_payment ap
            ,ven_doc_templ  dt
       WHERE dt.doc_templ_id = ap.doc_templ_id
         AND ap.payment_id = p_document_id;
  BEGIN
    OPEN cur_find;
    FETCH cur_find
      INTO v_type_str
          ,v_num_str
          ,v_date_str;
    IF cur_find%NOTFOUND
    THEN
      v_type_str := '<неизвестно>';
      v_num_str  := '<неизвестно>';
      v_date_str := '<неизвестно>';
    END IF;
    CLOSE cur_find;
  
    IF v_type_str IN ('DMS_INV_LPU_SERV', 'DMS_INV_LPU_ADV_ATTACH')
    THEN
      v_ret_val := v_ret_val || 'Счет';
    ELSIF v_type_str = 'DMS_SERV_INV'
    THEN
      v_ret_val := v_ret_val || 'Счет-фактура';
    ELSIF v_type_str = 'DMS_SERV_ACT'
    THEN
      v_ret_val := v_ret_val || 'Акт';
    ELSE
      v_ret_val := v_type_str;
    END IF;
  
    v_ret_val := v_ret_val || ' № ' || v_num_str || ' от ' || v_date_str || 'г.';
    v_ret_val := TRIM(v_ret_val);
  
    RETURN(v_ret_val);
  END get_parent_doc_name;

  FUNCTION get_payment_num(p_doc_templ_brief VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    v_ret_val NUMBER;
  BEGIN
    SELECT NVL(MAX(TO_NUMBER(num)), 0) + 1
      INTO v_ret_val
      FROM ven_ac_payment ap
          ,ven_doc_templ  dt
     WHERE ap.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
       AND UPPER(dt.BRIEF) = UPPER(p_doc_templ_brief);
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE check_policy_date(p_policy_id NUMBER) IS
    v_start_date DATE;
    v_end_date   DATE;
  
    v_temp_count NUMBER;
    v_policy_id  NUMBER;
  
    last_day_month VARCHAR2(2);
  
  BEGIN
  
    v_policy_id := p_policy_id;
  
    FOR cur IN (SELECT pc.start_date
                      ,pc.end_date
                      ,pc.P_COVER_ID
                  FROM as_asset aa
                      ,p_cover  pc
                 WHERE aa.p_POLICY_ID = v_policy_id
                   AND pc.AS_ASSET_ID = aa.AS_ASSET_ID)
    LOOP
    
      v_start_date := cur.start_date;
      v_end_date   := cur.end_date;
    
      SELECT COUNT(1)
        INTO v_temp_count
        FROM (SELECT NVL(drm.brief, drm_c.brief) brief
                FROM as_asset                 aa
                    ,p_cover                  pc
                    ,t_prod_line_option       plo
                    ,ven_t_prod_line_dms      pld
                    ,dms_prog_type            pt
                    ,ven_parent_prod_line_dms ppld
                    ,dms_repay_method         drm
                    ,ven_t_prod_line_dms      pld_c
                    ,dms_repay_method         drm_c
               WHERE pc.P_COVER_ID = cur.p_cover_id
                 AND plo.ID = pc.t_prod_line_option_id
                 AND pld.t_prod_line_dms_id = plo.product_line_id
                 AND pt.dms_prog_type_id = pld.dms_prog_type_id
                 AND pt.brief = 'INSPR'
                 AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
                 AND drm.dms_repay_method_id(+) = ppld.dms_repay_method_id
                 AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
                 AND drm_c.dms_repay_method_id(+) = pld_c.dms_repay_method_id)
       WHERE brief LIKE ('FOR_MONTH%');
    
      IF v_temp_count > 0
      THEN
        IF TO_CHAR(v_start_date, 'dd') <> '01'
        THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Дата начала прикрепления должна быть первым днем месяца.');
        END IF;
      END IF;
    
      SELECT COUNT(1)
        INTO v_temp_count
        FROM (SELECT NVL(drm.brief, drm_c.brief) brief
                FROM as_asset                 aa
                    ,p_cover                  pc
                    ,t_prod_line_option       plo
                    ,ven_t_prod_line_dms      pld
                    ,dms_prog_type            pt
                    ,ven_parent_prod_line_dms ppld
                    ,dms_repay_method         drm
                    ,ven_t_prod_line_dms      pld_c
                    ,dms_repay_method         drm_c
               WHERE pc.P_COVER_ID = cur.p_cover_id
                 AND plo.ID = pc.t_prod_line_option_id
                 AND pld.t_prod_line_dms_id = plo.product_line_id
                 AND pt.dms_prog_type_id = pld.dms_prog_type_id
                 AND pt.brief = 'INSPR'
                 AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
                 AND drm.dms_repay_method_id(+) = ppld.dms_repay_method_id
                 AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
                 AND drm_c.dms_repay_method_id(+) = pld_c.dms_repay_method_id)
       WHERE brief LIKE ('FOR_HALFMON%');
    
      IF v_temp_count > 0
      THEN
        IF TO_CHAR(v_start_date, 'dd') NOT IN ('01', '15')
        THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Дата начала прикрепления должна быть первым или пятнадцатым днем месяца.');
        END IF;
      END IF;
    
      SELECT TO_CHAR(TO_DATE('01' || TO_CHAR(ADD_MONTHS(v_end_date, 1), 'mmyyyy'), 'ddmmyyyy') - 1
                    ,'dd')
        INTO last_day_month
        FROM dual;
    
      SELECT COUNT(1)
        INTO v_temp_count
        FROM (SELECT NVL(drm.brief, drm_c.brief) brief
                FROM as_asset                 aa
                    ,p_cover                  pc
                    ,t_prod_line_option       plo
                    ,ven_t_prod_line_dms      pld
                    ,dms_prog_type            pt
                    ,ven_parent_prod_line_dms ppld
                    ,dms_repay_method         drm
                    ,ven_t_prod_line_dms      pld_c
                    ,dms_repay_method         drm_c
               WHERE pc.P_COVER_ID = cur.p_cover_id
                 AND plo.ID = pc.t_prod_line_option_id
                 AND pld.t_prod_line_dms_id = plo.product_line_id
                 AND pt.dms_prog_type_id = pld.dms_prog_type_id
                 AND pt.brief = 'INSPR'
                 AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
                 AND drm.dms_repay_method_id(+) = ppld.DMS_RECALC_METHOD_ID
                 AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
                 AND drm_c.dms_repay_method_id(+) = pld_c.DMS_RECALC_METHOD_ID)
       WHERE brief LIKE ('REP_MONTH%');
    
      IF v_temp_count > 0
      THEN
        IF TO_CHAR(v_end_date, 'dd') <> last_day_month
        THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Дата окончания прикрепления должна быть последним днем месяца.');
        END IF;
      END IF;
    
      SELECT COUNT(1)
        INTO v_temp_count
        FROM (SELECT NVL(drm.brief, drm_c.brief) brief
                FROM as_asset                 aa
                    ,p_cover                  pc
                    ,t_prod_line_option       plo
                    ,ven_t_prod_line_dms      pld
                    ,dms_prog_type            pt
                    ,ven_parent_prod_line_dms ppld
                    ,dms_repay_method         drm
                    ,ven_t_prod_line_dms      pld_c
                    ,dms_repay_method         drm_c
               WHERE pc.P_COVER_ID = cur.p_cover_id
                 AND plo.ID = pc.t_prod_line_option_id
                 AND pld.t_prod_line_dms_id = plo.product_line_id
                 AND pt.dms_prog_type_id = pld.dms_prog_type_id
                 AND pt.brief = 'INSPR'
                 AND ppld.t_parent_prod_line_id = pld.t_prod_line_dms_id
                 AND drm.dms_repay_method_id(+) = ppld.DMS_RECALC_METHOD_ID
                 AND pld_c.t_prod_line_dms_id = ppld.t_prod_line_id
                 AND drm_c.dms_repay_method_id(+) = pld_c.DMS_RECALC_METHOD_ID)
       WHERE brief LIKE ('REP_HALFMON%');
    
      IF v_temp_count > 0
      THEN
        IF TO_CHAR(v_end_date, 'dd') <> last_day_month
           AND TO_CHAR(v_end_date, 'dd') <> '14'
        THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Дата окончания прикрепления должна быть последним или четырнадцатым днем месяца.');
        END IF;
      END IF;
    
    END LOOP;
  
  END;

  FUNCTION GET_ACC_TYPE(p_contract_lpu_ver_id NUMBER) RETURN VARCHAR2 IS
    v_ret_val VARCHAR2(500);
    v_count   NUMBER;
    v_temp    VARCHAR2(500) := NULL;
  
    CURSOR cur_count IS
      SELECT COUNT(dat.NAME) count_type
        FROM ven_contract_lpu_ver_acc clva
            ,ven_dms_lpu_acc_type     dat
       WHERE dat.dms_lpu_acc_type_id = clva.dms_lpu_acc_type_id
         AND clva.contract_lpu_ver_id = p_contract_lpu_ver_id;
  
    CURSOR cur_name IS
      SELECT dat.NAME
        FROM ven_contract_lpu_ver_acc clva
            ,ven_dms_lpu_acc_type     dat
       WHERE dat.dms_lpu_acc_type_id = clva.dms_lpu_acc_type_id
         AND clva.contract_lpu_ver_id = p_contract_lpu_ver_id;
  BEGIN
    OPEN cur_count;
    FETCH cur_count
      INTO v_count;
    IF cur_count%NOTFOUND
    THEN
      v_count := 0;
    END IF;
    CLOSE cur_count;
  
    IF v_count = 0
    THEN
      v_ret_val := NULL;
    ELSIF v_count = 1
    THEN
      OPEN cur_name;
      FETCH cur_name
        INTO v_ret_val;
      IF cur_name%NOTFOUND
      THEN
        v_ret_val := NULL;
      END IF;
      CLOSE cur_name;
    ELSIF v_count > 1
    THEN
      FOR c_name IN cur_name
      LOOP
        IF LOWER(c_name.NAME) <> 'по факту'
        THEN
          v_temp := v_temp || c_name.NAME || ',';
        END IF;
      END LOOP;
      v_temp    := RTRIM(v_temp, ',');
      v_ret_val := 'По факту (' || v_temp || ')';
    END IF;
  
    RETURN(v_ret_val);
  END;

END;
/

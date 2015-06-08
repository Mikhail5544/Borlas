CREATE OR REPLACE PACKAGE pkg_ProductLifeProperty IS

  /**
   * Пакет расчета значений норм доходности по страхованию жизни, нагрузок. 
   * @author Marchuk A.
   * @version 1
   * @headcom
  */

  /**
    * Функция возвращает значение нагрузки по программе страхования 
    * @Author Author Marchuk A
    * @param p_program_id - ИД программы страхования
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION Get_LoadingValue
  (
    p_program_id          IN NUMBER
   ,p_term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
  ) RETURN NUMBER;

  /**
    * Функция возвращает значение нагрузки по программе страхования 
    * @Author Author Marchuk A
    * @param p_program_id - ИД программы страхования
    * @param p_discount_f_id значение нагрузки по договору страхования
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION Get_LoadingValue
  (
    p_program_id          IN NUMBER
   ,p_term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
   ,p_discount_f_id       IN NUMBER
  ) RETURN NUMBER;

  /**
    * Функция рассчитывает значение нормы доходности для покрытия по условиям 
    * @Author Author Marchuk A
    * @param p_cover_id - ИД покрытия
  */

  FUNCTION Calc_Normrate_Value(p_cover_id IN NUMBER) RETURN NUMBER;

  /**
    * Функция рассчитывает значение нормы ДОПОЛНИТЕЛЬНОЙ ИНВЕСТИЦИОННОЙ НОРМЫ доходности для покрытия по условиям 
    * @Author Author Marchuk A
    * @param p_cover_id - ИД покрытия
  */

  FUNCTION Calc_NormrateAdd_Value(p_cover_id IN NUMBER) RETURN NUMBER;
END pkg_ProductLifeProperty;
/
CREATE OR REPLACE PACKAGE BODY pkg_ProductLifeProperty IS
  --@Author Marchuk A
  --Класс для определения размера нагрузки для риска
  --Cюда нужно дописывать код при изменении документа
  --"СТРУКТУРА ТАРИФНЫХ СТАВОК" для СК "Ренессанс Жизнь"
  --
  --Риски:
  --  END - смешанное страхование
  --  PEPR - страхование на дожитие с возвратом взносов
  --  TERM - страхование жизни на срок
  --  CRI  - кредитное страхование жизни (то же, что и TERM, другая ТС)
  --  DD - первичное диагностирование смертельно опасного заболевания
  --  WOP - освобождение от уплаты страховых взносов
  --  PWOP - защита страховых взносов
  --  I - инвест
  --
  --  [Accident]:
  --  AD      - смерть НС
  --  Dism    - телесные повреждения в результате НС
  --  Adis    - инвалидность в результате НС
  --  TPD     - инвалидность по любой причине (НС + болезнь)
  --  ATD     - временная нетрудоспособность в результате НС
  --  H       - госпитализация в результате НС

  -- @Author Marchuk A
  /**
    * смешанного страхования "END" и "PEPR"
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  G_DEBUG BOOLEAN := FALSE;

  PROCEDURE LOG
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'PKG_PRODUCTLIFEPROPERTY', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION LoadingEND_PEPR
  (
    p_Term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('enter LoadingEND_PEPR p_Term_id' || p_Term_id || ' p_OnePayment_property ' ||
                         p_OnePayment_property);
    IF p_OnePayment_property = 1
    THEN
      -- единовременные взносы
      IF (p_Term_id >= 5)
         AND (p_Term_id <= 30)
      THEN
        RESULT := (12 + (p_Term_id - 5) * 0.2) / 100;
      ELSE
        IF (p_Term_id > 30)
        THEN
          RESULT := 17 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSE
      IF (p_Term_id >= 5)
         AND (p_Term_id <= 20)
      THEN
        RESULT := (12.5 + (p_Term_id - 5) * 0.5) / 100;
      ELSE
        IF (p_Term_id > 20)
        THEN
          RESULT := 20 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    END IF;
    RETURN RESULT;
  END;

  /**
    * Нагрузка для пожизненного страхования "WL"
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingWL
  (
    p_Term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF p_OnePayment_property = 1
    THEN
      -- единовременные взносы
      IF (p_Term_id >= 5)
         AND (p_Term_id <= 30)
      THEN
        RESULT := (12 + (p_Term_id - 5) * 0.2) / 100;
      ELSE
        IF (p_Term_id > 30)
        THEN
          RESULT := 17 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSE
      -- периодические
      IF (p_Term_id >= 5)
         AND (p_Term_id <= 20)
      THEN
        RESULT := (12.5 + (p_Term_id - 5) * 0.5) / 100;
      ELSE
        IF (p_Term_id > 20)
        THEN
          RESULT := 20 / 100;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    END IF;
    RETURN RESULT;
  END LoadingWL;

  /**
    * Нагрузка для страхования жизни на срок "TERM" (индивидуального и группового)
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingTERM(p_Special IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 30 / 100;
    RETURN RESULT;
  END LoadingTERM;

  /**
    * Нагрузка для кредитного страхования жизни "CRI" (индивидуального и группового)
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */
  FUNCTION LoadingCRI(p_Special IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 30 / 100;
    RETURN RESULT;
  END LoadingCRI;

  /**
    * Нагрузка для страхования первичного диагностирования с.о. заболевания "DD"
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingDD(p_Special IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 30 / 100;
    RETURN RESULT;
  END;

  /**
    * Нагрузка для WOP, PWOP
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingWOP(p_Special IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 30 / 100;
    RETURN RESULT;
  END LoadingWOP;

  /**
    * Нагрузка для INVEST
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingINVEST(p_Special IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 10 / 100;
    RETURN RESULT;
  END LoadingINVEST;

  /**
    * Нагрузка для НС ("AD", "Dism", "Adis", "TPD", "ATD", "H")
    * @Author Author Marchuk A
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_OnePayment - единовременный платеж (True) или периодический (False)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION LoadingAccident(p_Special IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 35 / 100;
    RETURN RESULT;
  END LoadingAccident;

  /**
    * Функция возвращает значение нагрузки по программе страхования 
    * @Author Author Marchuk A
    * @param p_program_id - ИД программы страхования
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION Get_LoadingValue
  (
    p_program_id          IN NUMBER
   ,p_term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
  ) RETURN NUMBER IS
    --
    RESULT        NUMBER;
    v_lob_line_id NUMBER;
  BEGIN
    --
    v_lob_line_id := p_program_id;
    DBMS_OUTPUT.PUT_LINE('Get_LoadingValue (basic) p_program_id = ' || p_program_id);
    --      
  
    IF v_lob_line_id = 30500033
    THEN
      RESULT := LoadingEND_PEPR(p_Term_id, p_OnePayment_property, p_Special);
    ELSIF v_lob_line_id = 30500034
    THEN
      RESULT := LoadingEND_PEPR(p_Term_id, p_OnePayment_property, p_Special);
    ELSIF v_lob_line_id = 30500036
    THEN
      RESULT := LoadingEND_PEPR(p_Term_id, p_OnePayment_property, p_Special);
      --       Case "WL"
      --            GetLoading = LoadingWL(Term, OnePayment, Special)
    ELSIF v_lob_line_id = 30500037
    THEN
      --          Case "TERM"
      RESULT := LoadingTERM(p_Special);
    ELSIF v_lob_line_id = 2922
    THEN
      --          Case "CRI"
      RESULT := LoadingCRI(p_Special);
    ELSIF v_lob_line_id = 30500035
    THEN
      --         Case "DD"
      RESULT := LoadingDD(p_Special);
    ELSIF v_lob_line_id = 3836
    THEN
      --         Case "DD"
      RESULT := LoadingDD(p_Special);
    ELSIF v_lob_line_id = 30500044
    THEN
      --  Case "WOP", "PWOP"            
      RESULT := LoadingWOP(p_Special);
    ELSIF v_lob_line_id = 92
    THEN
      --  Case "WOP", "PWOP"
      RESULT := LoadingWOP(p_Special);
    ELSIF v_lob_line_id = 30500038
    THEN
      --  Case "I"
      RESULT := LoadingINVEST(p_Special);
    ELSE
      RESULT := NULL;
      --        Case "AD", "Dism", "Adis", "TPD", "ATD", "H"
      --            GetLoading = LoadingAccident(Special)
      --        Case Else ' Unknown risk
    END IF;
    RETURN RESULT;
  END;

  /**
    * Функция возвращает значение нагрузки по программе страхования 
    * @Author Author Marchuk A
    * @param p_program_id - ИД программы страхования
    * @param p_discount_f_id значение нагрузки по договору страхования
    * @param @p_Term - срок от начала страхования до предельного возраста ТС? (уточнить)
    * @param p_Special - строка с кодом специальных (нестандартных) условий
  */

  FUNCTION Get_LoadingValue
  (
    p_program_id          IN NUMBER
   ,p_term_id             IN NUMBER
   ,p_OnePayment_property IN NUMBER
   ,p_Special             IN VARCHAR2
   ,p_discount_f_id       IN NUMBER
  ) RETURN NUMBER IS
    --
    RESULT  NUMBER;
    v_brief VARCHAR2(50);
    v_value NUMBER;
  BEGIN
    RESULT := Get_LoadingValue(p_program_id, p_term_id, p_OnePayment_property, p_Special);
    SELECT VALUE INTO v_brief FROM DISCOUNT_F WHERE DISCOUNT_F.discount_f_id = p_discount_f_id;
    IF INSTR(v_brief, '%') > 1
    THEN
      v_brief := REPLACE(v_brief, '%', '');
      v_value := TO_NUMBER(v_brief);
      IF v_value > 0
      THEN
        IF v_value < 100
        THEN
          RESULT := RESULT * (1 + v_value / 100);
        ELSIF v_value >= 100
        THEN
          RESULT := NULL;
        ELSE
          RESULT := NULL;
        END IF;
      ELSE
        IF ABS(v_value) < 100
        THEN
          RESULT := RESULT * (1 + v_value / 100);
        ELSIF v_value >= 100
        THEN
          RESULT := NULL;
        ELSE
          RESULT := NULL;
        END IF;
      END IF;
    ELSIF v_brief IS NULL
    THEN
      RESULT := RESULT;
    ELSE
      RESULT := TO_NUMBER(v_brief);
    END IF;
    --
    RETURN RESULT;
    --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /**
    * Функция рассчитывает значение нормы доходности для покрытия по условиям 
    * @Author Author Marchuk A
    * @param p_cover_id - ИД покрытия
  */

  FUNCTION Calc_Normrate_Value(p_cover_id IN NUMBER) RETURN NUMBER IS
    --
    v_lob_line_id NUMBER;
    --
    v_cover_id NUMBER;
    v_normrate NUMBER;
    --
  BEGIN
    LOG(p_cover_id, 'CALC_NORMRATE_VALUE');
    v_cover_id := p_cover_id;
    --      
  
    SELECT NVL(value_slave, value_master)
      INTO v_normrate
      FROM (
            
            SELECT ph.fund_id
                   ,ll.t_lob_line_id
                   ,TRUNC(pc.start_date) start_date
                   ,CASE
                      WHEN pln.norm_func_id IS NOT NULL THEN
                       pkg_tariff_calc.calc_fun(pln.norm_func_id, 305, p_cover_id)
                      ELSE
                       DECODE(pln.product_line_id, pl.ID, pln.VALUE, NULL, NULL, NULL)
                    END value_slave
                   ,vnr.VALUE value_master
                   ,pl.ID product_line_id
                   ,vnr.normrate_id normrate_id_master
                   ,DECODE(pln.product_line_id, pl.ID, pl.ID, NULL, NULL, NULL) product_line_id_slave
                   ,TRUNC(d_begin) d_begin
                   ,(NVL(lead(TRUNC(vnr.d_begin))
                         OVER(PARTITION BY vnr.t_lob_line_id, vnr.base_fund_id ORDER BY vnr.d_begin)
                        ,TRUNC(pc.end_date)) - 1) d_end
                   ,vnr.base_fund_id
              FROM NORMRATE           vnr
                   ,T_PROD_LINE_NORM   pln
                   ,T_LOB_LINE         ll
                   ,T_PRODUCT_LINE     pl
                   ,T_PROD_LINE_OPTION plo
                   ,P_POL_HEADER       ph
                   ,P_POLICY           pp
                   ,AS_ASSET           aa
                   ,P_COVER            pc
             WHERE 1 = 1
               AND pc.p_cover_id = v_cover_id
               AND aa.as_asset_id = pc.as_asset_id
               AND pp.policy_id = aa.p_policy_id
               AND ph.policy_header_id = pp.pol_header_id
               AND plo.ID = pc.t_prod_line_option_id
               AND pl.ID = plo.product_line_id
               AND ll.t_lob_line_id = pl.t_lob_line_id
               AND vnr.t_lob_line_id = ll.t_lob_line_id
               AND vnr.base_fund_id = ph.fund_id
               AND TRUNC(pc.start_date) >= TRUNC(vnr.d_begin)
                  -- AND pln.normrate_id (+) = vnr.normrate_id
               AND pln.product_line_id(+) = plo.product_line_id
            -- AND (pln.product_line_id = plo.product_line_id OR pln.product_line_id IS NULL)
            
            ) nr
     WHERE 1 = 1
       AND nr.product_line_id = NVL(product_line_id_slave, product_line_id)
       AND TRUNC(start_date) BETWEEN TRUNC(nr.d_begin) AND TRUNC(nr.d_end);
    --
    LOG(v_cover_id
       ,'Установленная норма доходности для "страховой программы" ' || v_normrate);
    --
    RETURN v_normrate;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /**
    * Функция рассчитывает значение нормы ДОПОЛНИТЕЛЬНОЙ ИНВЕСТИЦИОННОЙ НОРМЫ доходности для покрытия по условиям 
    * @Author Author Marchuk A
    * @param p_cover_id - ИД покрытия
  */

  FUNCTION Calc_NormrateAdd_Value(p_cover_id IN NUMBER) RETURN NUMBER IS
    --
    v_cover_id     NUMBER;
    v_normrate_add NUMBER;
    --
  BEGIN
    v_cover_id := p_cover_id;
    --      
    RETURN NULL;
    /*
    
      select value into v_normrate_add
      from 
        (
        select 
          vnr.value
        , ven_p_cover.start_date
        , max (d_begin) d_begin 
        , nvl (min (d_end), to_date ('01.01.3000', 'dd.mm.yyyy')) d_end
        from 
          ven_normrate_add vnr
        , ven_t_lob_line ven_t_lob_line
        , ven_t_product_line ven_t_product_line
        , ven_t_prod_line_option ven_t_prod_line_option
        , ven_p_pol_header ven_p_pol_header
        , ven_p_policy  ven_p_policy
        , ven_as_assured ven_as_assured
        , ven_p_cover ven_p_cover
          where 1=1
            and ven_p_cover.p_cover_id = v_cover_id
            and ven_as_assured.as_assured_id = ven_p_cover.as_asset_id
            and ven_p_policy.policy_id = ven_as_assured.p_policy_id
            and ven_p_pol_header.policy_header_id = ven_p_policy.pol_header_id
            and ven_t_prod_line_option.id = ven_p_cover.t_prod_line_option_id
            and ven_t_product_line.id = ven_t_prod_line_option.product_line_id
            and ven_t_lob_line.t_lob_line_id = ven_t_product_line.t_lob_line_id
            and vnr.t_lob_line_id = ven_t_lob_line.t_lob_line_id
            and vnr.base_fund_id = ven_p_pol_header.fund_id
            and ven_p_cover.start_date >= vnr.d_begin
        group by
          vnr.value
        , vnr.d_begin
        , ven_p_cover.start_date
        having
          ven_p_cover.start_date between max (d_begin) and nvl(min (d_end), to_date ('01.01.3000', 'dd.mm.yyyy'))
        order by d_begin desc, d_end asc
        ) nr
        where 1=1
          and rownum = 1;
    --
        dbms_output.put_line ('Установленная норма инвестиционной доходности для страховой программы '||v_normrate_add);
    --
        return v_normrate_add;
    */
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
END;
/

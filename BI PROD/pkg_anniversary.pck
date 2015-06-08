CREATE OR REPLACE PACKAGE pkg_anniversary IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 19.12.2014 11:03:00
  -- Purpose : 

  /**
  * Процедура получения N-ой годовщины
  * @author Капля П.
  * @param par_header_start_date - дата начала действия договора (p_pol_header.start_date)
  * @param par_anniversary_index - номер годовщины (начинается с 0)
  * @return date                 - дата годовщины
  */
  FUNCTION get_anniversary
  (
    par_header_start_date DATE
   ,par_anniversary_index INTEGER
  ) RETURN DATE;
	
  /**
	* Процедура определения следующей годовщины
	* @author Капля П.
  * @param par_header_start_date - дата начала действия договора (p_pol_header.start_date)
  * @param par_date              - дата для проверки принадлежности к году страхования
  * @return date                 - Дата следующей годовщины	
	*/
  FUNCTION get_next_anniversary
  (
    par_header_start_date DATE
   ,par_date              DATE
  ) RETURN DATE;

  /**
  * Процедура номер года, к которому относится дата (начинается с 0)
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_date              - дата для проверки принадлежности к году страхования
  * @return integer              - номер года, к которому относится дата
  */
  FUNCTION get_year_number
  (
    par_header_start_date DATE
   ,par_date              DATE
  ) RETURN INTEGER;

  /**
  * Проверка, является ли дата годовщиной договора страхования
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_checking_date     - дата для проверки
  * @return boolean              - является ли дата годовщиной
  */
  FUNCTION is_anniversary
  (
    par_header_start_date DATE
   ,par_checking_date     DATE
  ) RETURN BOOLEAN;
  /**
  * Проверка, является ли дата годовщиной договора страхования
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_checking_date     - дата для проверки
  * @return number               - является ли дата годовщиной (0 - нет, 1 - да)
  */
  FUNCTION is_anniversary_sql
  (
    par_header_start_date DATE
   ,par_checking_date     DATE
  ) RETURN NUMBER;

  /**
  * Проверка наличия годовщины между двумя датами (включая обе границы)
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_date_begin        - дата начала проверяемого периоду
  * @param par_date_end          - дата окончания проверяемого периоду
  * @return boolean              - есть ли между датами годовщины
  */
  FUNCTION is_anniversary_between_dates
  (
    par_header_start_date DATE
   ,par_date_begin        DATE
   ,par_date_end          DATE
  ) RETURN BOOLEAN;

END pkg_anniversary;
/
CREATE OR REPLACE PACKAGE BODY pkg_anniversary IS

  /**
  * Процедура получения N-ой годовщины
  * @author Капля П.
  * @param par_header_start_date - дата начала действия договора (p_pol_header.start_date)
  * @param par_anniversary_index - номер годовщины (начинается с 0)
  * @return date                 - дата годовщины
  */
  FUNCTION get_anniversary
  (
    par_header_start_date DATE
   ,par_anniversary_index INTEGER
  ) RETURN DATE IS
    v_anniversary_date DATE;
  BEGIN
    v_anniversary_date := ADD_MONTHS(par_header_start_date, par_anniversary_index * 12);
    RETURN v_anniversary_date;
  END get_anniversary;

  /**
	* Процедура определения следующей годовщины
	* @author Капля П.
  * @param par_header_start_date - дата начала действия договора (p_pol_header.start_date)
  * @param par_date              - дата для проверки принадлежности к году страхования
  * @return date                 - Дата следующей годовщины	
	*/
  FUNCTION get_next_anniversary
  (
    par_header_start_date DATE
   ,par_date              DATE
  ) RETURN DATE IS
    v_anniversary_date DATE;
  BEGIN
    v_anniversary_date := get_anniversary(par_header_start_date
                                         ,get_year_number(par_header_start_date, par_date) + 1);
    RETURN v_anniversary_date;
  END get_next_anniversary;

  /**
  * Процедура номер года, к которому относится дата (начинается с 0)
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_date              - дата для проверки принадлежности к году страхования
  * @return integer              - номер года, к которому относится дата
  */
  FUNCTION get_year_number
  (
    par_header_start_date DATE
   ,par_date              DATE
  ) RETURN INTEGER IS
    v_closest_anniversary_num INTEGER;
    v_anniversary_date        DATE;
  BEGIN
    v_closest_anniversary_num := trunc(MONTHS_BETWEEN(par_date, par_header_start_date) / 12);
    v_anniversary_date        := get_anniversary(par_header_start_date, v_closest_anniversary_num);
  
    IF v_anniversary_date > par_date
    THEN
      v_closest_anniversary_num := v_closest_anniversary_num - 1;
    END IF;
  
    RETURN v_closest_anniversary_num;
  
  END get_year_number;

  /**
  * Проверка, является ли дата годовщиной договора страхования
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_checking_date     - дата для проверки
  * @return boolean              - является ли дата годовщиной
  */
  FUNCTION is_anniversary
  (
    par_header_start_date DATE
   ,par_checking_date     DATE
  ) RETURN BOOLEAN IS
    v_anniversary_date DATE;
  BEGIN
    v_anniversary_date := get_anniversary(par_header_start_date
                                         ,get_year_number(par_header_start_date => par_header_start_date
                                                         ,par_date              => par_checking_date));
  
    RETURN v_anniversary_date = par_checking_date;
  END is_anniversary;

  /**
  * Проверка, является ли дата годовщиной договора страхования
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_checking_date     - дата для проверки
  * @return number               - является ли дата годовщиной (0 - нет, 1 - да)
  */
  FUNCTION is_anniversary_sql
  (
    par_header_start_date DATE
   ,par_checking_date     DATE
  ) RETURN NUMBER IS
  BEGIN
    RETURN sys.diutil.bool_to_int(is_anniversary(par_header_start_date, par_checking_date));
  END is_anniversary_sql;

  /**
  * Проверка наличия годовщины между двумя датами (включая обе границы)
  * @author Капля П.
  * @param par_header_start_date - Дата начала действия договора (p_pol_header.start_date)
  * @param par_date_begin        - дата начала проверяемого периоду
  * @param par_date_end          - дата окончания проверяемого периоду
  * @return boolean              - есть ли между датами годовщины
  */
  FUNCTION is_anniversary_between_dates
  (
    par_header_start_date DATE
   ,par_date_begin        DATE
   ,par_date_end          DATE
  ) RETURN BOOLEAN IS
    --v_exists NUMBER;
    v_db_yn  INTEGER;
    v_de_yn  INTEGER;
    v_result BOOLEAN;
  BEGIN
    /*    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE get_anniversary(par_header_start_date, LEVEL - 1) BETWEEN par_date_begin AND par_date_end
    CONNECT BY get_anniversary(par_header_start_date, LEVEL - 1) < par_date_end;
    
    RETURN v_exists > 0;*/
  
    v_db_yn := get_year_number(par_header_start_date, par_date_begin);
    v_de_yn := get_year_number(par_header_start_date, par_date_end);
  
    -- Если даты относятся к разным годам, значит между ними есть годовщина
    v_result := v_db_yn < v_de_yn OR get_anniversary(par_header_start_date, v_db_yn) = par_date_begin OR
                get_anniversary(par_header_start_date, v_de_yn) = par_date_end;
  
    RETURN v_result;
  END is_anniversary_between_dates;
END pkg_anniversary;
/

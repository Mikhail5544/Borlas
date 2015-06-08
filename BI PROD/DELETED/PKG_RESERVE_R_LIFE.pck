CREATE OR REPLACE PACKAGE RESERVE.PKG_RESERVE_R_LIFE IS
  /**
  * ������ �������� �� ����������� �����
  * @author Ivanov D.
  * @version Reserve For Life 1.1
  * @since 1.1
  */

  -- � ������������ ������� ������� �������� �������. ��������� �������
  -- ����� ���������� ��������� ������� ����������� ����� (����� �����)-
  -- ������� ����������� - ��������������. ����������� �������� �������
  -- �������� ������ � ������� r_reserve_ross.

  PKG_NAME CONSTANT VARCHAR2(20) := 'pkg_reserve';

  TYPE my_cursor_type IS REF CURSOR RETURN r_reserve%ROWTYPE;

  /**
  * ��������������
  */
  TYPE who_is IS RECORD(
     sex        NUMBER
    , -- ���, ������� 1, ������� 0
    age        NUMBER
    , -- ��������� �������
    death_date DATE -- ���� ������
    );

  /**
  * �������� ������� ����������
  */
  TYPE mortality_value_type IS RECORD(
     number_lives      NUMBER
    , -- ����� ��������
    number_died       NUMBER
    , -- ����� ���������
    death_portability NUMBER); -- ����������� �������

  /**
  * �������� �� ���������� �����, ����������� ��� ������� ��������.
  * <br> �������� �� �������� �������, ���������� ��������� �� ������
  * <br> �������� ���������� ����.
  * <br> �.� ���������� ��������
  */
  TYPE hist_values_type IS RECORD(
     policy_number     VARCHAR2(100)
    ,fact_yield_rate   NUMBER
    , -- ����������� ����� ���������� (������� ������)
    is_periodical     NUMBER
    , -- ����� ����������� ��� ��������������
    periodicity       NUMBER
    , -- ������������� (1,2,4,12) (������� ������)
    payment_duration  NUMBER
    , -- ���� ������ �������  (������� ������)
    start_date        DATE
    , -- ���� ������ ��������������� (������� ������)
    end_date          DATE
    , -- ���� ��������� �������������� (������� �������� �����������)
    payment           NUMBER
    , -- ������ ������ (������� �������� �����������)
    insurance_amount  NUMBER
    , -- ��������� ����� (������� �������� �����������)
    b                 NUMBER
    , -- ����������� �� ��������
    rent_periodicity  NUMBER
    , -- ������������� ������� �����
    rent_payment      NUMBER
    , -- ������ ����� ������� �����
    rent_duration     NUMBER
    , -- ���� ������� �����
    rent_start_date   DATE
    , -- ���� ������ ������� �����
    has_additional    NUMBER
    , -- ������� �� �������������� ������� �����������
    payment_base      NUMBER
    , -- ����� ������� �� ��������� ����������� � �������� �� ����������� �������
    k_coef            NUMBER
    ,s_coef            NUMBER
    ,rvb_value         NUMBER
    ,g                 NUMBER
    ,p                 NUMBER
    ,g_re              NUMBER
    ,p_re              NUMBER
    ,k_coef_re         NUMBER
    ,s_coef_re         NUMBER
    ,deathrate_id      NUMBER
    ,age               NUMBER
    ,sex               NUMBER
    ,death_date        DATE
    ,t_product_line_id NUMBER
    ,policy_id         NUMBER
    ,ins_premium       NUMBER);

  /**
  * �������� �������
  */

  TYPE reserve_value_type IS RECORD(
     reserve_id            NUMBER
    ,insurance_year_date   DATE
    ,insurance_year_number NUMBER
    ,par_plan              NUMBER
    ,par_fact              NUMBER);

  /**
  * ����������� ������ � ������� ������.
  * @param par_pkg_name �����
  * @param par_func_name ��� ������� ��� ��������� ��� ������� error
  * @param par_description �������� ������
  */
  PROCEDURE error
  (
    par_pkg_name    VARCHAR2
   ,par_func_name   VARCHAR2
   ,par_description VARCHAR2
  );

  /**
  * �������� �������� ������� ���������� ��� ���������������
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @return ������ ���� mortality_value_type
  */
  FUNCTION get_mortality_value
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN mortality_value_type;

  /**
  * �������� �������� ������� ���������� ��� ���������������
  * @param par_insured ���� ������� ����������
  * @return ������ ���� mortality_value_type
  */
  FUNCTION get_mortality_value(par_values PKG_RESERVE_R_LIFE.hist_values_type)
    RETURN mortality_value_type;

  /**
  * �������� ����������� ������ ��������������� � ������� ����
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @return �������� ����������� ������ ��������������� � ������� ����
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN NUMBER;

  /**
  * �������� ����������� ������ ��������������� � ������� ���������
  * <br> k ���
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_k ���������� ���, � ������� ������� �������� ������.
  * <br> ���������� ��� ����� ���� ������� ���������
  * @return �������� ����������� ����, ��� �������������� ����� � ������� � ���
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER;

  /**
  * ����������� ����, ��� �������������� ���������� �������� par_age �����
  * <br> � ������� par_k ��� ��� ������ ��������� 1-�� ��� 2-�� ������
  * <br> � ������� ���� �� ���������� �������. ����������� ��.
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_k ���������� ��� .
  * <br> ���������� ��� ����� ���� ������� ���������
  * @return �������� ����������� �� � ������� ��������� par_k ���
  */
  FUNCTION get_accident_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER;

  /**
  * �������� �������� �������� ����� ����������
  * @param par_calc_date
  * @return �������� �������� ����� ����������, ����������� ��
  * <br> ���� par_calc_date
  */
  FUNCTION get_plan_yield_rate(par_calc_date DATE) RETURN NUMBER;

  /**
  * �������� �������� ����������� ����� ����������.
  * <br> ����������� �������� ������� �������������� �� ��������
  * <br> �������� ����������� ����� ����������, ������������ � �������� �������.
  * <br> ������������ ��� ��������� ������� ����������� �����
  * <br> ���������� ��� ���������� ����.
  * @param par_begin_date ���� ������ �������
  * @param par_end_date ���� ��������� �������
  * @return �������� �������������������� ����������� ����� ����������
  */
  FUNCTION get_fact_yield_rate
  (
    par_begin_date DATE
   ,par_end_date   DATE
  ) RETURN NUMBER;

  /**
  * �������� �������� ������������ B
  * @param par_insurance_duration ������ ������ �������
  * @return �������� ������������ �
  */
  FUNCTION get_b(par_insurance_duration T_B.insurance_duration%TYPE) RETURN T_B.VALUE%TYPE;

  /**
  * �������� �������� ����������� ������������ �� �������� ���������������
  * <br >�� ������� ��� ������������.
  * @param par_age ������� ���������������
  * @return ����������� ����� ��������� � �������� age
  */
  FUNCTION get_u(par_age T_U.age%TYPE) RETURN T_U.portability%TYPE;

  /**
  * ���� ���� ��������, ���������� �������
  * par_t ����� ���������� ����
  */
  FUNCTION get_kom(par_t T_B.insurance_duration%TYPE) RETURN T_B.commission_part%TYPE;

  /**
  * ������� ��������� �������� ������� �� ���� ������� ������� �������� ������������
  * <br> �� ��������� ��������� �� ������ �������, � ������� ����� ���� �������.
  * @param par_date_begin ���� ������ �������
  * @param par_date_end ���� ����� �������
  * @param par_value_for_begin �������� �� ���� ������ �������
  * @param par_value_for_end �������� �� ���� ����� �������
  * @param par_cal_date ���� �������
  * @return �������� �� ���� �������, ���������� ������� �������� ������������
  */
  FUNCTION line_interpolation
  (
    par_date_begin      IN r_reserve_value.insurance_year_date%TYPE
   ,par_date_end        IN r_reserve_value.insurance_year_date%TYPE
   ,par_value_for_begin IN r_reserve_value.fact%TYPE
   ,par_value_for_end   IN r_reserve_value.PLAN%TYPE
   ,par_calc_date       IN DATE
  ) RETURN r_reserve_value.PLAN%TYPE;

  /**
  * ������� ��������� ������ ���������� ���� �� ���� ������ ���������������
  * <br> � ���� �������
  * @param par_start_date
  * @param par_cal_date
  * @return ����� ���������� ���� �� ���� �������
  */
  FUNCTION get_insurance_year_number
  (
    par_start_date DATE
   ,par_calc_date  DATE
  ) RETURN NUMBER;

  /**
  * �������� ���������� �������� �� �������� ������� �� ����
  * ������� ������� �� ��
  * @param par_reserve ����� - ������� ����������� - ��������������
  * @param par_date ����, �� ������� ���������� �������� ���������� ��������
  * @return ���������� �������� ���� hist_values_type
  */
  FUNCTION get_history_values
  (
    p_reserve   r_reserve%ROWTYPE
   ,p_calc_date DATE
  ) RETURN PKG_RESERVE_R_LIFE.hist_values_type;

  /**
  * �������� ���� ������ ��������������� �� �������� �������
  * @param par_reserve ����� - ������� ����������� - ��������������
  * @return ���� ������ ���������������
  */
  FUNCTION get_start_date(par_reserve r_reserve%ROWTYPE) RETURN DATE;

  /**
  * ��������� ��������� ������ � r_reserve_ross ��� ���������� ���������
  * �������.
  * ��������� ������� �� ��
  */
  PROCEDURE check_new_regisry;

  /**
  * ��������� ������ �� ����� ��������� �� ������.
  * <br> ��� ���� �������� ������� ������� r_reserve_ross.
  * <br> ���� ��� ������ ������� �� ��������� ������� � ������� r_reserve_ross
  * <br> ��, ������ ��������� ��� ���� ����������� ��������������
  * <br> � ��������� �����������.
  * @param par_policy_id �� ������
  * @param par_reserve_cursor ������ �� ��������� ������� �� ������
  */
  PROCEDURE open_reserve_cursor
  (
    par_policy_id      IN NUMBER
   ,par_reserve_cursor IN OUT my_cursor_type
  );

  /**
  * ��������� ������� �������� (�������� ����) �� ������.
  * ����� ���� �������, ����� ����� ������ ��������.
  * @param par_policy_id �� ������, �� �������� ������� �������
  * @param par_calc_date ���� �������
  */
  PROCEDURE calc_reserve_for_policy
  (
    par_policy_id IN NUMBER
   ,par_calc_date IN DATE DEFAULT NULL
  );
  /**
  * ��������� �������� �������� �� ������.
  * ����� ���� �������, ����� ����� ������ ��������.
  * @param par_policy_id �� ������, �� �������� ������� �������
  * @param par_calc_date ���� �������
  */
  PROCEDURE drop_reserve_for_policy(par_policy_id IN NUMBER);

  /**
  * ����� �������� ������� �� �����
  * @param par_reserve_id �� �������� �������, �� �������� ����� ������� ��������
  * @param par_insurance_year_date ���� ������ ���������� ����
  * @param par_insurance_year_number ����� ���������� ����
  * @return ������ ������� r_reserve_value_ross
  */
  FUNCTION get_reserve_value
  (
    par_reserve_id          IN NUMBER
   ,par_insurance_year_date DATE
  ) RETURN r_reserve_value%ROWTYPE;

  /**
  * �������� �������� ������� �� ��������.
  * <p> �������� ����� �������� �������. ���� �� �������, �� ���������
  * <br> ����� ������. ���� �������, �� ������ ������.
  * @param par_reserve_value ������ ������� r_reserve_value_ross
  */
  PROCEDURE add_reserve_value(par_reserve_value IN r_reserve_value%ROWTYPE);

  /**
  * ������� ������� �������� ������� �� ��������� ���������
  * <br> �� ���� ������ � ���� �������� ���������� ���� � ������� par_t.
  * <p> ���� �������� �� ���� ������ ���������� ����������
  * <br> �������� ������ ��� ������ ���������� ���� par_t-1.
  * <br> �������� �������������, ����� ������� ��������
  * <br> ������� �� ���� ������ ���������� ����, ���� ����
  * <br> ���������� ������ �� ���� ������ ������� ����������
  * <br> ����. ������ �������� �� ���� ������ ������� ����������
  * <br> ���� ������������ ��� ������ �������� calc_reserve_for_iv.
  * <p> ���� ���������� �������� ������� �� ���� ���������
  * <br> ���������� ���� � ������� par_t, �� ��� ��������������
  * <br> ��� ������ ������� calc_reserve_for_iv.
  * @param par_registry ������� �������
  * @param par_t ����� ���������� ����, ��� �������� ������������ ������
  * @return �������� ������� �� ����� ���������� ����
  */
  PROCEDURE calc_reserve_anniversary
  (
    par_registry IN r_reserve%ROWTYPE
   ,p_i          IN NUMBER
   ,p_t          IN OUT NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  );

  /**
  * ������� ������� �������� ������� �� ��������
  * <br> ������� �� ������������ ����.
  * @param par_registry ������� �������, �� �������� ���������� ������
  */
  PROCEDURE calc_reserve_for_registry(par_registry IN r_reserve%ROWTYPE);

  /**
  * ��������� ������� �������� �� ��������. ������ ������������ �� ���� ��
  * ��������� ��������� �����������.
  * @param par_calc_reserve ������ ������� r_calc_reserve_ross. ��� ������
  * ���� ��, ����� �������, ���� �������. ������ ������������ �� ���� ���������
  * ������� �������� ����������� ������� �������. �.� �� �� ��������� ������� �������
  * r_calc_results_ross, ������� ��������� �� ������ ������ (par_calc_reserve).
  * ����� ���������� �������� ������ � ������� r_calc_results_ross ����������
  * �� ���������� ������� �� ���� ��������� �����������. ��� �������� �����
  * �������� ����������� ������������ ������� r_calc_results_temp.
  * �������� ��������, ������� ��������� � ������� ���������� �� ��������� ���������
  * ��������� � �������� ���������� ������� ��������� ����������� �
  * ����������� ��������� ����������� ����� �� ������������� v_active_policy_ross
  */
  PROCEDURE calc_reserve_for_company(par_calc_reserve R_CALC_RESERVE%ROWTYPE);

  /**
  * ��������� �������. �������� ����� ��������� ������-������ � ��������� �����
  * @param par_inv ������� ����������� (�� t_product_line_option)
  * @param par_sex ��� ��������������� (1- �������, 0 - �������)
  * @param par_age ��������� ������� ���������������
  * @param par_start_date ���� ������ ��������������� �� �������� �����������
  * @param par_end_date ���� ��������� ��������������� �� �������� �����������
  * @param par_periodisity ������������� ������ ������� (���������� �������� � ��� �� ������)
  * @param par_r ���� ������ ������� (�� ������)
  * @param par_j ����� ����������, ��������� �� �������� (�� ������)
  * @param par_b ����������� b (�� ������)
  * @param par_rent_periodicity ������������� ������� �����
  * @param par_rent_payment ������ ������� �����
  * @param par_rent_duration ���� ������� �����
  * @param par_has_additional ������� �������������� ������� �����������
  * @param par_payment_base ����� ������_������� �� ��������� ��������� �����������
  * @return ������-�����/��������� �����, ���� 0, ����
  * ��� ������� ���� ������
  */
  FUNCTION act_function
  (
    par_inv              IN NUMBER
   ,par_sex              IN NUMBER
   ,par_age              IN NUMBER
   ,par_start_date       IN DATE
   ,par_end_date         IN DATE
   ,par_periodicity      IN NUMBER
   ,par_r                IN NUMBER
   ,par_j                IN NUMBER
   ,par_b                IN NUMBER
   ,par_rent_periodicity IN NUMBER DEFAULT NULL
   ,par_rent_payment     IN NUMBER DEFAULT NULL
   ,par_rent_duration    IN NUMBER DEFAULT NULL
   ,par_has_additional   IN NUMBER DEFAULT 0
   ,par_payment_base     IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * ������� �������� ����������� ������� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������
  */
  FUNCTION get_VB
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;

  /**
  * ������� �������� ����� ������� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������
  */
  FUNCTION get_V
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;

  /**
  * ������� �������� ����� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������
  */
  FUNCTION get_P
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
  FUNCTION get_PP
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;

  /**
  * ������� �������� ����� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������
  */
  FUNCTION get_VS
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER;
  /**
  * ������� �������� ��������� ����� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������
  */
  FUNCTION get_S
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
  FUNCTION get_SS
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY RESERVE.PKG_RESERVE_R_LIFE IS

  g_start_date_header DATE;
  /**
  * ����������� ������ � ������� ������.
  * @param par_pkg_name �����
  * @param par_func_name ��� ������� ��� ��������� ��� ������� error
  * @param par_description �������� ������
  */
  PROCEDURE error
  (
    par_pkg_name    VARCHAR2
   ,par_func_name   VARCHAR2
   ,par_description VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO R_ERROR_JOURNAL
      (error_description, error_date, function_call, ID)
    VALUES
      (par_description, SYSDATE, par_pkg_name || '.' || par_func_name, 1);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /**
  * �������� �������� ������� ���������� ��� ���������������
  *@param par_sex ��� ���������������
  *@param age ������� ��������������� 
  *@return ������ ���� mortality_value_type
  */
  FUNCTION get_mortality_value
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN mortality_value_type IS
    mortality_value mortality_value_type;
  
    CURSOR c1
    (
      cur_sex NUMBER
     ,cur_age NUMBER
    ) IS
      SELECT mtv.number_lives      AS f1
            ,mtv.number_died       AS f2
            ,mtv.death_portability AS f3
        FROM T_MORTALITY_FAST_TABLE mtv
       WHERE mtv.sex = cur_sex
         AND mtv.age = cur_age;
    v_age NUMBER;
  BEGIN
    v_age := par_age;
    IF v_age > 100
    THEN
      v_age := 100;
    END IF;
    FOR rec IN c1(par_sex, v_age)
    LOOP
      mortality_value.number_lives      := rec.f1; -- Lx
      mortality_value.number_died       := rec.f2; -- Dx
      mortality_value.death_portability := rec.f3; -- Qx
    END LOOP;
    RETURN mortality_value;
  END;

  /**
  * �������� �������� ������� ���������� ��� ���������������
  *@param par_insured ���� ������� ����������
  *@return ������ ���� mortality_value_type
  */
  FUNCTION get_mortality_value(par_values PKG_RESERVE_R_LIFE.hist_values_type)
    RETURN mortality_value_type IS
  BEGIN
    RETURN get_mortality_value(par_values.sex, par_values.age);
  END;

  /** 
  * �������� ����������� ������ ��������������� � ������� ����
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @return �������� ����������� ������ ��������������� � ������� ����
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN get_mortality_value(par_sex, par_age).death_portability;
  END;

  /**
  * �������� ����������� ������ ��������������� � ������� ���������
  * <br> k ���
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_k ���������� ���, � ������� ������� �������� ������
  * <br> ���������� ��� ����� ���� ������� ���������  
  * @return �������� ����������� ����, ��� �������������� ����� � ������� � ���
  */
  FUNCTION get_death_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER IS
    --    CURSOR c1(cur_sex NUMBER, cur_age NUMBER, cur_last_age NUMBER) IS
    --      SELECT SUM(mtv.death_portability)
    --        FROM t_mortality_fast_table mtv
    --       WHERE mtv.sex = cur_sex
    --         AND mtv.age BETWEEN cur_age AND cur_last_age; 
    res_portability NUMBER;
    v_k_integer     NUMBER; -- ����� ����� ����� �� par_k
    Q_t_x           mortality_value_type;
    Q_t_x_k         mortality_value_type;
  BEGIN
    IF par_k <= 0
    THEN
      res_portability := 0;
    ELSIF par_k + par_age > 100
    THEN
      res_portability := 1;
    ELSE
      v_k_integer := TRUNC(par_k, 0);
      IF par_k = v_k_integer
      THEN
        -- ������� ��������� ������ �������
        Q_t_x           := get_mortality_value(par_sex, par_age);
        Q_t_x_k         := get_mortality_value(par_sex, par_age + v_k_integer);
        res_portability := (Q_t_x.number_lives - Q_t_x_k.number_lives) / Q_t_x.number_lives;
        --        OPEN c1(par_sex, par_age, par_age + par_k - 1);
        --        FETCH c1
        --          INTO res_portability;
        --        CLOSE c1;
      ELSE
        -- ������� ����������
        res_portability := 1 - (1 - get_death_portability(par_sex, par_age, v_k_integer)) *
                           (1 - (par_k - v_k_integer) *
                           get_death_portability(par_sex, par_age + v_k_integer));
      END IF;
    END IF;
    RETURN res_portability;
  END;

  /**
  * ����������� ����, ��� �������������� ���������� �������� par_age ����� 
  * <br> � ������� par_k ��� ��� ������ ��������� 1-�� ��� 2-�� ������
  * <br> � ������� ���� �� ���������� �������. �.�. ����������� ��.
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_k ���������� ���. 
  * <br> ���������� ��� ����� ���� ������� ���������
  * @return �������� ����������� �� � ������� ��������� par_k ���
  */
  FUNCTION get_accident_portability
  (
    par_sex IN NUMBER
   ,par_age IN NUMBER
   ,par_k   NUMBER
  ) RETURN NUMBER IS
    v_k_integer     NUMBER;
    res_portability NUMBER;
    v_i_multi       NUMBER;
    v_u             NUMBER;
    v_q             NUMBER;
  BEGIN
    IF par_k <= 0
    THEN
      res_portability := 0;
    ELSE
      v_k_integer := TRUNC(par_k, 0);
      IF par_k = v_k_integer
      THEN
        -- ��� ����� �������� par_k
        v_i_multi := 1;
        FOR i IN 0 .. par_k - 1
        LOOP
          v_u       := get_u(par_age + i);
          v_q       := get_death_portability(par_sex, par_age + i);
          v_i_multi := v_i_multi * (1 - v_u - v_q + v_u * v_q);
        END LOOP;
        res_portability := 1 - v_i_multi;
      ELSE
        -- ��� �������
        v_u             := get_u(par_age + v_k_integer);
        v_q             := get_death_portability(par_sex, par_age + v_k_integer);
        res_portability := 1 - (1 - get_accident_portability(par_sex, par_age, v_k_integer)) *
                           (1 - (par_k - v_k_integer) * (v_q + v_u - v_q * v_u));
      END IF;
    END IF;
    RETURN res_portability;
  END;

  /**
  * �������� �������� �������� ����� ����������
  * @param par_calc_date
  * @return �������� �������� ����� ����������, ����������� ��
  * <br> ���� par_calc_date
  */
  FUNCTION get_plan_yield_rate(par_calc_date DATE) RETURN NUMBER IS
    CURSOR c1(cur_calc_date DATE) IS
      SELECT yr1.VALUE
        FROM T_YIELD_RATE yr1
       WHERE yr1.date_change = (SELECT MAX(yr2.date_change)
                                  FROM T_YIELD_RATE yr2
                                 WHERE yr2.date_change <= par_calc_date
                                   AND yr2.flag = yr1.flag)
         AND yr1.flag = 0;
    res_yield_rate NUMBER;
  BEGIN
    OPEN c1(par_calc_date);
    FETCH c1
      INTO res_yield_rate;
    CLOSE c1;
    RETURN res_yield_rate;
  END;

  /**
  * �������� �������� ����������� ����� ����������.
  * <br> ����������� �������� ������� �������������� �� ��������
  * <br> �������� ����������� ����� ����������, ������������ � �������� �������.
  * <br> ������������ ��� ��������� ������� ����������� �����
  * <br> ���������� ��� ���������� ����.
  * @param par_begin_date ���� ������ �������
  * @param par_end_date ���� ��������� �������
  * @return �������� �������������������� ����������� ����� ����������
  */
  FUNCTION get_fact_yield_rate
  (
    par_begin_date DATE
   ,par_end_date   DATE
  ) RETURN NUMBER IS
    CURSOR c1
    (
      cur_begin_date DATE
     ,cur_end_date   DATE
    ) IS
      SELECT NVL((SELECT SUM(res) / MONTHS_BETWEEN(cur_end_date, cur_begin_date)
                   FROM ((SELECT MONTHS_BETWEEN(yr.date_change
                                               ,lag(yr.date_change, 1, cur_begin_date)
                                                OVER(ORDER BY yr.date_change)) * yr.VALUE AS res
                            FROM T_YIELD_RATE yr
                           WHERE yr.date_change >= cur_begin_date
                             AND yr.date_change <= cur_end_date
                             AND yr.flag = 1)
                        
                         UNION ALL
                        
                         (SELECT MONTHS_BETWEEN(cur_end_date, prev_date) * val AS res
                            FROM (SELECT NVL((SELECT yr.VALUE
                                               FROM T_YIELD_RATE yr
                                              WHERE yr.date_change =
                                                    (SELECT MIN(yr1.date_change)
                                                       FROM T_YIELD_RATE yr1
                                                      WHERE yr1.flag = yr.flag
                                                        AND yr1.date_change >= cur_end_date)
                                                AND yr.flag = 1)
                                            ,
                                             -- �������� ����� ����������
                                             (SELECT yr1.VALUE
                                                FROM T_YIELD_RATE yr1
                                               WHERE yr1.date_change =
                                                     (SELECT MAX(yr2.date_change)
                                                        FROM T_YIELD_RATE yr2
                                                       WHERE yr2.date_change <= cur_end_date
                                                         AND yr2.flag = yr1.flag)
                                                 AND yr1.flag = 0)) AS val
                                        ,(SELECT yr.date_change
                                            FROM T_YIELD_RATE yr
                                           WHERE yr.date_change =
                                                 (SELECT MAX(yr1.date_change)
                                                    FROM T_YIELD_RATE yr1
                                                   WHERE yr1.flag = yr.flag
                                                     AND yr1.date_change <= cur_end_date
                                                     AND yr1.date_change >= cur_begin_date)
                                             AND yr.flag = 1) AS prev_date
                                    FROM DUAL))))
                ,(SELECT yr1.VALUE
                   FROM T_YIELD_RATE yr1
                  WHERE yr1.date_change = (SELECT MAX(yr2.date_change)
                                             FROM T_YIELD_RATE yr2
                                            WHERE yr2.date_change <= cur_end_date
                                              AND yr2.flag = yr1.flag)
                    AND yr1.flag = 0)) AS res
        FROM dual;
  
    res_fact_yield_rate NUMBER;
  BEGIN
    OPEN c1(par_begin_date, par_end_date);
    FETCH c1
      INTO res_fact_yield_rate;
    CLOSE c1;
    RETURN res_fact_yield_rate;
  END;

  /**
  * �������� �������� ������������ B
  * @param 
  * @return 
  */
  FUNCTION get_b(par_insurance_duration T_B.insurance_duration%TYPE) RETURN T_B.VALUE%TYPE IS
  
    res_value T_B.VALUE%TYPE;
    CURSOR c1(cur_ins_dur T_B.insurance_duration%TYPE) IS
      SELECT b.VALUE AS v FROM T_B b WHERE b.insurance_duration = cur_ins_dur;
  BEGIN
    OPEN c1(par_insurance_duration);
    LOOP
      FETCH c1
        INTO res_value;
      EXIT WHEN c1%NOTFOUND;
    END LOOP;
    CLOSE c1;
    RETURN NVL(res_value, 0);
  END;

  /**
  * �������� �������� ����������� ������������ �� �������� ���������������
  * <br >�� ������� ��� ������������.
  * @param par_age ������� ���������������
  * @return ����������� ����� ��������� � �������� age
  */
  FUNCTION get_u(par_age T_U.age%TYPE) RETURN T_U.portability%TYPE IS
    CURSOR c1(cur_age_of_insured T_U.age%TYPE) IS
      SELECT portability FROM T_U WHERE age = cur_age_of_insured;
    res_value T_U.portability%TYPE;
  BEGIN
    OPEN c1(par_age);
    LOOP
      FETCH c1
        INTO res_value;
      EXIT WHEN c1%NOTFOUND;
    END LOOP;
    CLOSE c1;
    RETURN NVL(res_value, 0);
  END;

  /**
  * ���� ���� ��������, ���������� �������
  * par_t ����� ���������� ����
  */
  FUNCTION get_kom(par_t T_B.insurance_duration%TYPE) RETURN T_B.commission_part%TYPE IS
    res_value T_B.commission_part%TYPE;
    CURSOR c1(cur_ins_dur T_B.insurance_duration%TYPE) IS
      SELECT b.commission_part AS v FROM T_B b WHERE b.insurance_duration = cur_ins_dur;
  BEGIN
    IF par_t >= 5
    THEN
      res_value := 0;
      RETURN res_value;
    ELSE
      OPEN c1(par_t);
      LOOP
        FETCH c1
          INTO res_value;
        EXIT WHEN c1%NOTFOUND;
      END LOOP;
      CLOSE c1;
      RETURN NVL(res_value, 0);
    END IF;
  END;

  /**  
  * ������� ��������� �������� �� ���� ������� ������� �������� ������������
  * <br> �� ��������� ��������� �� ������ �������, � ������� ����� ���� �������.
  * @param par_date_begin ���� ������ �������
  * @param par_date_end ���� ����� �������
  * @param par_value_for_begin �������� �� ���� ������ �������
  * @param par_value_for_end �������� �� ���� ����� �������
  * @param par_cal_date ���� �������
  * @return �������� �� ���� �������, ���������� ������� �������� ������������
  */
  FUNCTION line_interpolation
  (
    par_date_begin      IN r_reserve_value.insurance_year_date%TYPE
   ,par_date_end        IN r_reserve_value.insurance_year_date%TYPE
   ,par_value_for_begin IN r_reserve_value.fact%TYPE
   ,par_value_for_end   IN r_reserve_value.PLAN%TYPE
   ,par_calc_date       IN DATE
  ) RETURN r_reserve_value.PLAN%TYPE IS
  
  BEGIN
    --DBMS_OUTPUT.PUT_LINE ('line_interpolation '||' par_date_begin '||par_date_begin||' par_date_end '||par_date_end||' par_value_for_begin '||par_value_for_begin||' par_value_for_end '||par_value_for_end||' par_calc_date '||par_calc_date);
    -- ���� ���� �����, �� ������ �������� �� ���� ������ ��� ��������� �������
    -- �������� �.
    IF (par_calc_date < par_date_begin)
    THEN
      RETURN par_value_for_begin;
    ELSE
      IF (par_calc_date > par_date_end)
      THEN
        RETURN par_value_for_end;
      END IF;
    END IF;
    -- 
    IF (par_date_begin = par_date_end)
    THEN
      RETURN NVL(par_value_for_begin, par_value_for_end);
    ELSE
      RETURN(par_value_for_end - par_value_for_begin) * MONTHS_BETWEEN(par_calc_date, par_date_begin) / MONTHS_BETWEEN(par_date_end
                                                                                                                      ,par_date_begin) + par_value_for_begin;
    END IF;
  END;

  /**
  * ������� ��������� ������ ���������� ���� �� ���� ������ ���������������
  * <br> � ���� �������
  * @param par_start_date
  * @param par_cal_date
  * @return ����� ���������� ���� �� ���� �������
  */
  FUNCTION get_insurance_year_number
  (
    par_start_date DATE
   ,par_calc_date  DATE
  ) RETURN NUMBER IS
    var_year_number NUMBER;
  BEGIN
    -- ������� ����� ���������� ����, � ������� �������� ���� �������
    DBMS_OUTPUT.PUT_LINE('par_calc_date ' || par_calc_date || ' par_start_date ' || par_start_date);
    var_year_number := MONTHS_BETWEEN(par_calc_date, par_start_date) / 12;
    var_year_number := TRUNC(var_year_number, 0);
    IF var_year_number < 0
    THEN
      var_year_number := 0;
    END IF;
    RETURN var_year_number + 1;
  END;

  /**
  * �������� ���������� �������� �� �������� ������� �� ����
  * ������� ������� �� ��
  * @param par_reserve ����� - ������� ����������� - ��������������
  * @param par_date ����, �� ������� ���������� �������� ���������� ��������
  * @return ���������� �������� ���� PKG_RESERVE_LIFE.hist_values_type
  */
  FUNCTION get_history_values
  (
    p_reserve   r_reserve%ROWTYPE
   ,p_calc_date IN DATE
  ) RETURN PKG_RESERVE_R_LIFE.hist_values_type IS
  
    CURSOR c_history IS
    
      SELECT a.p_policy_id policy_id
            ,aa.assured_contact_id
        FROM ins.AS_ASSET a
            ,ins.AS_ASSURED aa
            ,(SELECT pp.policy_id
                    ,pp.pol_header_id
                    ,pp.version_num
                    ,pp.start_date
                    ,pp_cur.start_date start_date_cur
                    ,NVL((lead(pp.start_date)
                          OVER(PARTITION BY pp.pol_header_id ORDER BY pp.version_num) - 1)
                        ,TRUNC(pp.end_date)) end_date
                FROM ins.P_POLICY     pp_cur
                    ,ins.P_POLICY     pp
                    ,ins.P_POL_HEADER ph
               WHERE 1 = 1
                 AND ph.policy_header_id = p_reserve.pol_header_id
                 AND pp.pol_header_id = ph.policy_header_id
                 AND pp_cur.policy_id = p_reserve.policy_id) pp
       WHERE 1 = 1
         AND pp.pol_header_id = p_reserve.pol_header_id
            -- ��� ������ ���������� ������ �� ������� ���� �������� ������ �� ������� ��������. ���� ���� ����� ������ �������� ������� ������ ������
            -- �� �������� ������ �� ���� ������
         AND ((TRUNC(pp.start_date_cur) > TRUNC(p_calc_date /*- 1*/) AND
             TRUNC(p_calc_date /*- 1*/) BETWEEN pp.start_date AND pp.end_date) OR
             (TRUNC(pp.start_date_cur) <= TRUNC(p_calc_date /*- 1*/) AND
             pp.policy_id = p_reserve.policy_id))
         AND a.p_asset_header_id = p_reserve.p_asset_header_id
         AND a.p_policy_id = pp.policy_id
         AND aa.as_assured_id = a.as_asset_id;
    --
    r_history c_history%ROWTYPE;
    --
    CURSOR c_current IS
      SELECT a.p_policy_id policy_id
            ,aa.assured_contact_id
        FROM ins.AS_ASSET     a
            ,ins.AS_ASSURED   aa
            ,ins.P_POLICY     pp
            ,ins.P_POL_HEADER ph
       WHERE 1 = 1
         AND ph.policy_header_id = p_reserve.pol_header_id
         AND pp.pol_header_id = ph.policy_header_id
         AND pp.policy_id = p_reserve.policy_id
         AND pp.pol_header_id = p_reserve.pol_header_id
         AND a.p_asset_header_id = p_reserve.p_asset_header_id
         AND a.p_policy_id = pp.policy_id
         AND aa.as_assured_id = a.as_asset_id;
    r_current c_current%ROWTYPE;
  
    CURSOR c1
    (
      cur_policy_id       IN NUMBER
     ,cur_contact_id      IN NUMBER
     ,cur_variant_id      IN NUMBER
     ,cur_product_line_id IN NUMBER
     ,cur_calc_date       IN DATE
    ) IS
      SELECT h.policy_number
            ,h.policy_fact_yield_rate
            ,h.is_periodical
            ,h.periodicity
            ,h.payment_duration
            ,h.start_date
            ,h.end_date
            ,h.payment
            ,h.insurance_amount
            ,h.b
            ,h.rent_periodicity
            ,h.rent_payment
            ,h.rent_duration
            ,h.rent_start_date
            ,h.has_additional
            ,h.payment_base
            ,h.k_coef
            ,h.s_coef
            ,h.rvb_value
            ,h.g
            ,h.p
            ,h.g_re
            ,h.p_re
            ,h.k_coef_re
            ,h.s_coef_re
            ,h.deathrate_id
            ,h.age
            ,h.sex
            ,h.death_date
            ,
             --             
             h.t_product_line_id
            ,h.policy_id
            ,h.ins_premium
      --
        FROM v_registry_hist_values h
       WHERE h.policy_id = cur_policy_id
         AND h.insurance_variant_id = cur_variant_id
         AND h.t_product_line_id = cur_product_line_id;
    res_values   PKG_RESERVE_R_LIFE.hist_values_type;
    p_contact_id NUMBER;
    v_cnt        NUMBER DEFAULT 0;
    l_new_cover  NUMBER;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('��������� �����. ���. ������. ������� ����� ' || 'policy_id ' ||
                         p_reserve.policy_id || ' �� ���� ' || ' par_calc_date ' || p_calc_date ||
                         ' cur_p_asset_header_id ' || p_reserve.p_asset_header_id ||
                         ' par_reserve.insurance_variant_id ' || p_reserve.insurance_variant_id);
  
    /* �������� ������� �� ����� �� ������� "���������� �������"   */
    SELECT COUNT(at.brief)
      INTO l_new_cover
      FROM ins.p_policy            pp
          ,ins.p_pol_addendum_type pa
          ,ins.t_addendum_type     at
     WHERE pp.policy_id = p_reserve.policy_id
       AND pa.p_policy_id = pp.policy_id
       AND at.t_addendum_type_id = pa.t_addendum_type_id
       AND at.brief = 'CLOSE_FIN_WEEKEND';
  
    OPEN c_history;
    FETCH c_history
      INTO r_history;
  
    IF l_new_cover = 0
       AND c_history%FOUND
    THEN
      DBMS_OUTPUT.PUT_LINE('����� ������ �� ������ ������ ������ ' || r_history.policy_id ||
                           ' assured_contact_id ' || r_history.assured_contact_id ||
                           ' t_product_line_id ' || p_reserve.t_product_line_id ||
                           ' insurance_variant_id ' || p_reserve.insurance_variant_id ||
                           ' p_calc_date ' || TO_CHAR(p_calc_date, 'dd.mm.yyyy hh24:mi:ss'));
      OPEN c1(r_history.policy_id
             ,r_history.assured_contact_id
             ,p_reserve.insurance_variant_id
             ,p_reserve.t_product_line_id
             ,p_calc_date);
      FETCH c1
        INTO res_values;
      IF c1%FOUND
      THEN
        DBMS_OUTPUT.PUT_LINE('���������� ������ �������');
      END IF;
      CLOSE c1;
      CLOSE c_history;
    ELSE
      OPEN c_current;
      FETCH c_current
        INTO r_current;
      IF c_current%FOUND
      THEN
      
        DBMS_OUTPUT.PUT_LINE('����� ������ �� ������� ������ ������ ' || r_current.policy_id ||
                             ' assured_contact_id ' || r_current.assured_contact_id ||
                             ' t_product_line_id ' || p_reserve.t_product_line_id ||
                             ' insurance_variant_id ' || p_reserve.insurance_variant_id ||
                             ' p_calc_date ' || TO_CHAR(p_calc_date, 'dd.mm.yyyy hh24:mi:ss'));
        OPEN c1(r_current.policy_id
               ,r_current.assured_contact_id
               ,p_reserve.insurance_variant_id
               ,p_reserve.t_product_line_id
               ,p_calc_date);
        FETCH c1
          INTO res_values;
        IF c1%FOUND
        THEN
          DBMS_OUTPUT.PUT_LINE('����������� ������ �������');
        END IF;
        CLOSE c1;
      ELSE
        DBMS_OUTPUT.PUT_LINE('����������� ������ �� �������');
      END IF;
      CLOSE c_current;
    
    END IF;
  
    DBMS_OUTPUT.PUT_LINE(' policy_number ' || res_values.policy_number || ' insurance_amount ' ||
                         res_values.insurance_amount);
  
    RETURN res_values;
  
  END;

  /**                            
  * �������� ���� ������ ��������������� �� �������� �������
  * ������� ������� �� ��    
  * @param par_reserve ����� - ������� ����������� - ��������������                              
  * @return ���� ������ ���������������
  */
  FUNCTION get_start_date(par_reserve r_reserve%ROWTYPE) RETURN DATE IS
    v_ret_val DATE;
  BEGIN
    SELECT ph.start_date
      INTO v_ret_val
      FROM ins.P_POL_HEADER ph
     WHERE ph.policy_header_id = par_reserve.pol_header_id;
    RETURN v_ret_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SYSDATE;
  END;

  /**
  * ��������� ������ �� ����� ��������� �� ������.
  * <br> ��� ���� �������� ������� ������� r_reserve.
  * <br> ���� ��� ������ ������� �� ��������� ������� � ������� r_reserve
  * <br> ��, ������ ��������� ��� ���� ����������� �������������� 
  * <br> � ��������� �����������.
  * @param par_policy_id �� ������
  * @param par_reserve_cursor ������ �� ��������� ������� �� ������
  */
  PROCEDURE open_reserve_cursor
  (
    par_policy_id      IN NUMBER
   ,par_reserve_cursor IN OUT my_cursor_type
  ) IS
    -- �������� ����� ������ �� ������, ������� ����� �������� � �������
    CURSOR new_reserves(cur_policy_id NUMBER) IS
      SELECT vner.policy_header_id
            ,cur_policy_id policy_id
            ,p_asset_header_id
            ,vner.insurance_variant_id
            ,vner.t_product_line_id
            ,vner.p_cover_id
        FROM v_not_exists_registry vner
       WHERE 1 = 1
         AND vner.policy_id = cur_policy_id;
    -- 
  
  BEGIN
    DBMS_OUTPUT.PUT_LINE('ENTER open_reserve_cursor par_policy_id' || par_policy_id);
    -- ����� �������� ������� �� ������
    FOR rec IN new_reserves(par_policy_id)
    LOOP
      DBMS_OUTPUT.PUT('�������� ����� ������ � ��������...par_policy_id = ' || rec.policy_id);
      DBMS_OUTPUT.PUT(' pol_header_id ' || rec.policy_header_id || ' insurance_variant_id ' ||
                      rec.insurance_variant_id);
      DBMS_OUTPUT.PUT_LINE(' p_asset_header_id' || rec.p_asset_header_id || ' t_product_line_id ' ||
                           rec.t_product_line_id);
      INSERT INTO r_reserve
        (ID
        ,policy_id
        ,pol_header_id
        ,insurance_variant_id
        ,t_product_line_id
        ,p_asset_header_id
        ,p_cover_id)
      VALUES
        (sq_r_reserve.NEXTVAL
        ,rec.policy_id
        ,rec.policy_header_id
        ,rec.insurance_variant_id
        ,rec.t_product_line_id
        ,rec.p_asset_header_id
        ,rec.p_cover_id);
    END LOOP;
  
    -- ������� �������� ������� �� ������
  
    OPEN par_reserve_cursor FOR
      SELECT rr.ID
            ,rr.policy_id
            ,rr.insurance_variant_id
            ,rr.contact_id
            ,rr.pol_header_id
            ,rr.p_asset_header_id
            ,rr.t_product_line_id
            ,rr.p_cover_id
        FROM r_reserve    rr
            ,ins.P_POLICY pp
       WHERE 1 = 1
         AND pp.policy_id = par_policy_id
         AND rr.policy_id = pp.policy_id
       ORDER BY rr.policy_id
               ,rr.insurance_variant_id;
  
  END;

  /**
  * �������� �������� ������� �� �����
  * @param par_reserve_id �� �������� �������, �� �������� ����� ������� ��������
  * @param par_insurance_year_date ���� ������ ���������� ����
  * @param par_insurance_year_number ����� ���������� ����  
  * @return ������ ������� r_reserve_value
  */
  FUNCTION get_reserve_value
  (
    par_reserve_id          IN NUMBER
   ,par_insurance_year_date DATE
  )
  --
   RETURN r_reserve_value%ROWTYPE IS
    -- �������� �������� ������� �� �����
    CURSOR val
    (
      cur_reserve_id          NUMBER
     ,cur_insurance_year_date DATE
    ) IS
      SELECT *
        FROM r_reserve_value rvr
       WHERE 1 = 1
         AND rvr.insurance_year_date = cur_insurance_year_date
         AND rvr.reserve_id = cur_reserve_id;
  
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    IF par_reserve_id IS NULL
       OR par_insurance_year_date IS NULL
    THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'reserve.find_reserve_value: ���� �� ����� ��������� �������� null');
    END IF;
  
    OPEN val(par_reserve_id, par_insurance_year_date);
    FETCH val
      INTO res_reserve_value;
    DBMS_OUTPUT.PUT_LINE('�������� �� ������ ���� ������� ' || res_reserve_value.S || 'tVZ ' ||
                         res_reserve_value.TVZ_P);
    IF val%NOTFOUND
    THEN
      DBMS_OUTPUT.PUT_LINE('�������� �� ������ ���� �� ������� ...par_reserve_id ' || par_reserve_id || ' ' ||
                           to_char(par_insurance_year_date, 'dd.mm.yyyy'));
    END IF;
    CLOSE val;
  
    RETURN res_reserve_value;
  END;

  PROCEDURE add_reserve_value(par_reserve_value IN r_reserve_value%ROWTYPE) IS
  
    find_flag NUMBER(1); -- ����, ����������, ���� ������� �������� � �����
    -- 0 - �� ������� ������� ��� ����� ���� �����������
    -- 1 - ������� ������, ��������� update
    -- 2 - ������� ������ � �������� ������� ��������� - ������ �� ���� ������
    value_id NUMBER;
  
    reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('������� ���������� ������������ �������� ��� ���� ' ||
                         to_date(par_reserve_value.insurance_year_date, 'dd.mm.yyyy'));
    find_flag := 0; -- �� ������� ������ �� �����
  
    reserve_value := get_reserve_value(par_reserve_value.reserve_id
                                      ,par_reserve_value.insurance_year_date);
  
    IF reserve_value.ID IS NOT NULL
    THEN
      find_flag := 1; --  ������� ������ � ����� �� ������
      value_id  := reserve_value.ID;
    END IF;
  
    IF find_flag = 0
    THEN
      -- �� ���� �������, ���������
      DBMS_OUTPUT.PUT_LINE('������� ������ � ������� ������� .... ');
      INSERT INTO reserve.r_reserve_value
        (ID
        ,reserve_id
        ,insurance_year_date
        ,insurance_year_number
        ,reserve_date
        ,a_z
        ,PLAN
        ,fact
        ,c
        ,j
        ,p
        ,g
        ,p_re
        ,g_re
        ,s
        ,tV_p
        ,tV_f
        ,tV_p_re
        ,tV_f_re
        ,tVZ_p
        ,tVZ_f
        ,tVexp_p
        ,tVexp_f
        ,tVS_p
        ,tVS_f
        ,fee)
      VALUES
        (sq_r_reserve_value.NEXTVAL
        ,par_reserve_value.reserve_id
        ,par_reserve_value.insurance_year_date
        ,par_reserve_value.insurance_year_number
        ,par_reserve_value.insurance_year_date - 1
        ,par_reserve_value.a_z
        ,par_reserve_value.PLAN
        ,par_reserve_value.fact
        ,par_reserve_value.c
        ,par_reserve_value.j
        ,par_reserve_value.p
        ,par_reserve_value.g
        ,par_reserve_value.p_re
        ,par_reserve_value.g_re
        ,par_reserve_value.s
        ,par_reserve_value.tV_p
        ,par_reserve_value.tV_f
        ,par_reserve_value.tV_p_re
        ,par_reserve_value.tV_f_re
        ,par_reserve_value.tVZ_p
        ,par_reserve_value.tVZ_f
        ,par_reserve_value.tVexp_p
        ,par_reserve_value.tVexp_f
        ,par_reserve_value.tVS_p
        ,par_reserve_value.tVS_f
        ,par_reserve_value.fee);
    ELSIF find_flag = 1
    THEN
      -- ���� ������� � ������� ����������, ������
      UPDATE r_reserve_value r
         SET r.PLAN    = par_reserve_value.PLAN
            ,r.fact    = par_reserve_value.fact
            ,r.c       = par_reserve_value.c
            ,r.j       = par_reserve_value.j
            ,r.p       = par_reserve_value.p
            ,r.g       = par_reserve_value.g
            ,r.p_re    = par_reserve_value.p_re
            ,r.g_re    = par_reserve_value.g_re
            ,r.s       = par_reserve_value.s
            ,r.tV_p    = par_reserve_value.tV_p
            ,r.tV_f    = par_reserve_value.tV_f
            ,r.tV_p_re = par_reserve_value.tV_p_re
            ,r.tV_f_re = par_reserve_value.tV_f_re
            ,r.tVZ_p   = par_reserve_value.tVZ_p
            ,r.tVZ_f   = par_reserve_value.tVZ_f
            ,r.tVexp_p = par_reserve_value.tVexp_p
            ,r.tVexp_f = par_reserve_value.tVexp_f
            ,r.tVS_p   = par_reserve_value.tVS_p
            ,r.tVS_f   = par_reserve_value.tVS_f
            ,r.A_Z     = par_reserve_value.A_Z
            ,r.fee     = par_reserve_value.fee
       WHERE r.ID = value_id;
    END IF;
    /* exception
    when others then
      rollback to sp1; 
      error(pkg_name, 'add_reserve_value', '������ ������ ������� �� = ' || par_reserve_value.reserve_id);
      raise; */
  END;

  /**
  * ��������� ������� �������� (�������� ����) �� ������.
  * ����� ���� �������, ����� ����� ������ ��������.
  * @param par_policy_id �� ������, �� �������� ������� �������
  * @param par_calc_date ���� �������
  */
  PROCEDURE calc_reserve_for_policy
  (
    par_policy_id IN NUMBER
   ,par_calc_date IN DATE DEFAULT NULL
  ) IS
    -- ����� ��������� ������� �� ������  
    reserve_cursor my_cursor_type;
  
    -- ������ �������
    rec_reserve       r_reserve%ROWTYPE;
    res_reserve_value NUMBER;
    --
    v_policy_end_date       DATE;
    v_reserve_value_for_end r_reserve_value%ROWTYPE;
  
  BEGIN
    -- �������� �������� �������� �� ������, �� ������� ����� �������� ������.
    open_reserve_cursor(par_policy_id, reserve_cursor);
    IF reserve_cursor%ISOPEN
    THEN
      LOOP
        FETCH reserve_cursor
          INTO rec_reserve;
        EXIT WHEN reserve_cursor%NOTFOUND OR reserve_cursor%NOTFOUND IS NULL;
        -- �� �������� ���������� �� ������ � ���������������
        DBMS_OUTPUT.PUT_LINE('������ �� �������� ���������� �� ������ � ��������������� ' ||
                             rec_reserve.policy_id);
        calc_reserve_for_registry(rec_reserve);
      END LOOP;
    ELSE
      DBMS_OUTPUT.PUT_LINE('������ ������... ');
    END IF;
    --EXCEPTION
    --  WHEN OTHERS THEN
    --    raise_application_error(-20000, 'calc_reserve_for_policy() ' || sqlerrm || 'policy_id = ' || par_policy_id);
  END;

  /**
  * ��������� �������� �������� �� ������.
  * ����� ���� �������, ����� ����� ������ ��������.
  * @param par_policy_id �� ������, �� �������� ������� �������
  * @param par_calc_date ���� �������
  */
  PROCEDURE drop_reserve_for_policy(par_policy_id IN NUMBER) IS
  BEGIN
    DELETE FROM reserve.r_reserve WHERE policy_id = par_policy_id;
  END;

  /**
    * ������� ������� �������� ������� �� �������� �������
    * <br> �� ���� ������ � ���� �������Begin
  FND_GLOBAL.APPS_INITIALIZE(1163,20678,20005); 
  FND_GLOBAL.set_nls_context(p_nls_language => 'RUSSIAN',
                   p_nls_date_format => null,
                     p_nls_date_language => null,
                     p_nls_numeric_characters => null,
                     p_nls_sort => null,
                     p_nls_territory => null);
  end;
  � ���������� ���� � ������� par_t. 
    * <p> ���� �������� �� ���� ������ ���������� ����������
    * <br> �������� ������ ��� ������ ���������� ���� par_t-1.
    * <br> �������� �������������, ����� ������� ��������     
    * <br> ������� �� ���� ������ ���������� ����, ���� ����
    * <br> ���������� ������ �� ���� ������ ������� ����������       
    * <br> ����. ������ �������� �� ���� ������ ������� ����������
    * <br> ���� ������������ ��� ������ �������� calc_reserve_for_iv.
    * <p> ���� ���������� �������� ������� �� ���� ��������� 
    * <br> ���������� ���� � ������� par_t, �� ��� ��������������
    * <br> ��� ������ ������� calc_reserve_for_iv.
    * @param par_registry ������� �������
    * @param par_start_date ���� ������ ��������������� �� ��������
    * @param par_t ����� ���������� ����, ��� �������� ������������ ������
    * @param par_reserve_value_for_begin �������� ������� �� ������
    * @param par_depth ������� ��������  
    * @return �������� ������� �� ����� ���������� ����  
    */
  PROCEDURE calc_reserve_anniversary
  (
    par_registry IN r_reserve%ROWTYPE
   ,p_i          IN NUMBER
   ,p_t          IN OUT NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) IS
    v_values                PKG_RESERVE_R_LIFE.hist_values_type;
    v_hist_date             DATE; -- ���� ������ ���������� ���� � ������� par_t
    v_ins_end_date          DATE; -- ���� ��������� ��������� ���� � ������� par_t
    v_cur_date              DATE; -- ���� ��������� �������� ���. ����
    v_c                     NUMBER; -- �������� ����� ����������
    v_j                     NUMBER; -- ����������� ����� ����������    
    v_n                     NUMBER; -- ���� �����������
    v_t                     NUMBER; -- ���� �����������
    v_b                     NUMBER; -- todo ���������� ��������
    v_kom                   NUMBER; -- 
    v_periodical            NUMBER(1);
    v_reserve_value_start   r_reserve_value%ROWTYPE;
    v_reserve_value_end     r_reserve_value%ROWTYPE;
    v_insurance_year_number NUMBER(3);
  
    l_cur_policy_start_date DATE;
    l_version_num           NUMBER;
  
    PROCEDURE GET_HISTORY_RESERVE IS
    
    BEGIN
    
      DBMS_OUTPUT.PUT_LINE('GET_HISTORY_RESERVE' || to_char(v_hist_date, 'dd.mm.yyyy'));
    
      v_reserve_value_end.reserve_id := par_registry.id;
    
      DBMS_OUTPUT.PUT_LINE('GET_HISTORY_RESERVE A_Z ' || v_reserve_value_end.a_z ||
                           ' INSURANCE_YEAR_DATE ' ||
                           to_char(v_reserve_value_end.INSURANCE_YEAR_DATE, 'dd.mm.yyyy'));
    
    END;
  
    FUNCTION CHECK_HISTORY_RESERVE RETURN NUMBER IS
      l_new_cover NUMBER := 0;
    BEGIN
    
      /* �������� ������� �� ����� �� ������� "���������� �������"   */
      SELECT COUNT(at.brief)
        INTO l_new_cover
        FROM ins.p_policy            pp
            ,ins.p_pol_addendum_type pa
            ,ins.t_addendum_type     at
       WHERE pp.policy_id = par_registry.policy_id
         AND pa.p_policy_id = pp.policy_id
         AND at.t_addendum_type_id = pa.t_addendum_type_id
         AND at.brief = 'CLOSE_FIN_WEEKEND';
    
      IF l_new_cover = 1
      THEN
        RETURN 0;
      END IF;
    
      DBMS_OUTPUT.PUT_LINE('CHECK_HISTORY_RESERVE POL_HEADER_ID ' || par_registry.POL_HEADER_ID ||
                           ' POLICY_ID ' || par_registry.policy_id || ' HIST_DATE ' ||
                           to_char(v_hist_date, 'dd.mm.yyyy') || ' INSURANCE_VARIANT_ID ' ||
                           par_registry.INSURANCE_VARIANT_ID || ' VERSION_NUM ' || l_version_num);
    
      BEGIN
        SELECT rv.*
          INTO v_reserve_value_end
          FROM reserve.r_reserve_value rv
              ,reserve.r_reserve       rr
              ,ins.p_policy            pp
         WHERE 1 = 1
           AND pp.POL_HEADER_ID = par_registry.POL_HEADER_ID
           AND pp.VERSION_NUM =
               (SELECT MAX(a.VERSION_NUM)
                  FROM ins.p_policy a
                 WHERE pol_header_id = par_registry.POL_HEADER_ID
                   AND a.VERSION_NUM < l_version_num
                   AND EXISTS
                 (SELECT 1 FROM reserve.r_reserve rr_1 WHERE rr_1.policy_id = a.policy_id))
           AND rr.policy_id = pp.policy_id
           AND rr.INSURANCE_VARIANT_ID = par_registry.INSURANCE_VARIANT_ID
           AND trunc(rv.INSURANCE_YEAR_DATE) = trunc(v_hist_date)
           AND rv.reserve_id = rr.id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN 0;
      END;
    
      DBMS_OUTPUT.PUT_LINE('CHECK_HISTORY_RESERVE EXISTS ');
      RETURN 1;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CHECK_HISTORY_RESERVE NOT EXISTS ');
        RETURN 0;
      
    END;
  
    PROCEDURE CALCULATE_RESERVE IS
    BEGIN
      -- �������� ���������� �������� �� ������ � �������� �����������
      -- �� ����� ���������� ����
      IF p_t < v_n
      THEN
        DBMS_OUTPUT.PUT_LINE(' p_t < v_n ' || 'p_t ' || p_t || ' ������������ ������ �� ���� ' ||
                             v_hist_date);
        v_values := get_history_values(par_registry, v_hist_date);
      ELSIF p_t = v_n
            AND p_t = 1
      THEN
        DBMS_OUTPUT.PUT_LINE(' false p_t = v_n ������������ ������ �� ���� ' || p_start_date);
        v_values := get_history_values(par_registry, p_start_date);
      ELSE
        DBMS_OUTPUT.PUT_LINE(' false p_t < v_n �������� ������������ ������ �� ���� ' ||
                             ADD_MONTHS(p_end_date, -12));
        /*v_values := get_history_values(par_registry, p_start_date);*/
        /*�������� � ��������� ��� �195854: ���� ��� - �� ����������� �������, ���� ��� ������,
        �� ������ ������ �� ������ �� � ������� �������, ��� �� �����, �.�. ��������� ����� �
        ��������� ������*/
        v_values := get_history_values(par_registry, ADD_MONTHS(p_end_date, -12) + 1);
      END IF;
    
      IF v_values.start_date IS NOT NULL
      THEN
        v_n := MONTHS_BETWEEN(v_values.end_date + 1, p_start_date) / 12;
        v_t := p_t;
        --v_t := v_values.t;
      
        --    ���� �������� �� ��������� �� ����, �� ��������� ������
        v_cur_date := ADD_MONTHS(p_start_date, p_i * 12);
        IF NOT (TO_CHAR(v_cur_date, 'dd') = TO_CHAR(p_start_date, 'dd'))
        THEN
          v_cur_date := v_cur_date - 1;
        END IF;
        IF v_cur_date > v_values.end_date + 1
        THEN
          DBMS_OUTPUT.PUT_LINE('����� �� ���������... ����� �� ������� ' || p_start_date || ' p_i ' || p_i || ' ' ||
                               ADD_MONTHS(p_start_date, p_t * 12) || ' ' || (v_values.end_date + 1));
          p_t := -1;
          RETURN;
        END IF;
        -- ���� �����������      
        -- �������� ����� ���������� �� ����� ���������� ����
        v_c := get_plan_yield_rate(v_ins_end_date);
        -- ����������� ����� ����������
        IF v_values.fact_yield_rate IS NULL
           OR v_values.fact_yield_rate = 0
        THEN
          v_j := get_fact_yield_rate(v_hist_date, v_ins_end_date);
        ELSE
          v_j := v_values.fact_yield_rate;
        END IF;
      
        -- ����������� �
        IF v_values.b IS NULL
           OR v_values.b = 0
        THEN
          v_b := get_b(p_i);
        ELSE
          v_b := v_values.b;
        END IF;
      
        -- ���� ���������
        v_kom := get_kom(p_t);
      
        DBMS_OUTPUT.PUT_LINE('����� �������� �� ������ ���� id ' || par_registry.ID || ' start_date ' ||
                             ADD_MONTHS(v_hist_date, -12) || ' (t - 1) ' || (p_i - 1));
        IF MOD(EXTRACT(YEAR FROM g_start_date_header), 4) = 0
           AND TO_CHAR(g_start_date_header, 'DD') = 28
        THEN
          v_reserve_value_start := get_reserve_value(par_registry.ID
                                                    ,to_date('28.' ||
                                                             TO_CHAR(ADD_MONTHS(v_hist_date, -12)
                                                                    ,'MM.YYYY')
                                                            ,'dd.mm.yyyy'));
        ELSE
          v_reserve_value_start := get_reserve_value(par_registry.ID, ADD_MONTHS(v_hist_date, -12));
        END IF;
        /*v_reserve_value_start := get_reserve_value (par_registry.ID,
        ADD_MONTHS (v_hist_date, -12));*/
      
        DBMS_OUTPUT.PUT_LINE('reserve_value_start.tv_p ' || v_reserve_value_start.tv_p);
        -- �������� ������� �� ������ ���������� ���� ����� ������� 
        -- �� ����� �����������                                               
        --par_reserve_value_for_begin.plan := v_reserve_value_for_end.plan;
        --par_reserve_value_for_begin.fact := v_reserve_value_for_end.fact;
        -- ������ �������� ������� �� ����� ���������� ����
        v_reserve_value_end := reserve.pkg_reserve_life_alg.calc_reserve_for_iv(par_registry
                                                                               ,p_start_date
                                                                               ,v_hist_date
                                                                               ,v_values
                                                                               ,v_t
                                                                               ,v_reserve_value_start
                                                                               ,v_values.is_periodical
                                                                               ,v_n
                                                                               ,v_c
                                                                               ,v_j
                                                                               ,v_b
                                                                               ,v_kom);
      ELSE
        p_t := -1;
        DBMS_OUTPUT.PUT_LINE('������ �� ������� .... p_t ������������� ��� ' || p_t);
      END IF;
    END;
  
    PROCEDURE CALCULATE_FIRST_YEAR IS
    BEGIN
    
      -- todo ��������� ������������ ��������� �������� j, b, c,
      -- todo �������� ����� �����, ���� �� ������� �������� �� ����� �����. ���� 
      -- �������� ���������� �������� �� ������ � �������� �����������
      -- �� ������ ���������� ���� 
    
      DBMS_OUTPUT.PUT_LINE('CALCULATE_FIRST_YEAR');
      DBMS_OUTPUT.PUT_LINE('GET_HISTORY_VALUES POLICY_ID ' || par_registry.policy_id ||
                           ' POL_HEADER_ID ' || par_registry.pol_header_id || ' P_T ' ||
                           ' HIST_DATE ' || v_hist_date);
      v_values := get_history_values(par_registry, v_hist_date);
    
      IF v_values.start_date IS NOT NULL
      THEN
        DBMS_OUTPUT.PUT_LINE(' END_DATE ' || v_values.end_date);
        -- ���� �����������
        v_n := MONTHS_BETWEEN(v_values.end_date + 1, p_start_date) / 12;
        DBMS_OUTPUT.PUT_LINE(' V_N ' || v_n);
        -- �������� ����� ���������� �� ������ ���������� ����
        v_c := get_plan_yield_rate(v_hist_date);
      
        -- ����������� ����� ����������
        v_j := NVL(v_values.fact_yield_rate, get_fact_yield_rate(v_hist_date, v_ins_end_date));
      
        -- ����������� �
        v_b := NVL(v_values.b, get_b(p_i + 1));
      
        -- ���� ���������
        v_kom := get_kom(p_t + 1);
      
        -- ���������� �� ������
      
        -- �������� ����� ���������� �� ������ ���������� ����
        v_c := get_plan_yield_rate(v_hist_date);
      
        v_reserve_value_start.insurance_year_date   := p_start_date;
        v_reserve_value_start.insurance_year_number := 0;
        DBMS_OUTPUT.PUT_LINE('������� �������... calc_reserve_for_iv ��� par_t<=0 ....deathrate_id ' ||
                             v_values.deathrate_id);
      
        v_reserve_value_start := pkg_reserve_life_alg.calc_reserve_for_iv(par_registry
                                                                         ,p_start_date
                                                                         ,v_hist_date
                                                                         ,v_values
                                                                         ,p_t
                                                                         ,v_reserve_value_start
                                                                         ,v_values.is_periodical
                                                                         ,v_n
                                                                         ,v_c
                                                                         ,v_j
                                                                         ,v_b
                                                                         ,v_kom);
        DBMS_OUTPUT.PUT_LINE('����� ������... calc_reserve_for_iv ��� par_t<=0');
      
        v_reserve_value_end := v_reserve_value_start;
        -- ������� �������� ������� �� ������ ������� ���������� ����      
        -- add_reserve_value(v_reserve_value_start);
        -- ������� �������� ������� �� ������ ������� ���������� ����
      ELSE
        p_t := -1;
        DBMS_OUTPUT.PUT_LINE('������ �� ������� .... p_t ������������� ��� ' || p_t);
      END IF;
      --
    END;
  
  BEGIN
    SELECT start_date
          ,version_num
      INTO l_cur_policy_start_date
          ,l_version_num
      FROM ins.p_policy
     WHERE policy_id = par_registry.policy_id;
  
    -- ��������� ���� ������ ���������� ���� � ������� par_t
    DBMS_OUTPUT.PUT_LINE('CALC_RESERVE_ANNIVERSARY START_DATE ' ||
                         to_char(p_start_date, 'dd.mm.yyyy') || ' END_DATE ' ||
                         to_char(p_end_date, 'dd.mm.yyyy'));
    v_hist_date := ADD_MONTHS(p_start_date
                             ,(p_i /*- 1*/
                              ) * 12);
  
    -- ���� ��������� ���������� ���� � ������� par_t
    v_ins_end_date := ADD_MONTHS(p_start_date, 12) - 1;
    v_n            := MONTHS_BETWEEN(p_end_date + 1, p_start_date) / 12;
  
    DBMS_OUTPUT.PUT_LINE('CALC_RESERVE_ANNIVERSARY t ' || p_t || ' CUR_POLICY_START_DATE ' ||
                         to_char(l_cur_policy_start_date, 'dd.mm.yyyy') || ' HIST_DATE ' ||
                         to_char(v_hist_date, 'dd.mm.yyyy'));
  
    IF p_t <= 0
       AND trunc(l_cur_policy_start_date) >= trunc(v_hist_date)
       AND CHECK_HISTORY_RESERVE = 1
    THEN
      GET_HISTORY_RESERVE;
      -- add_reserve_value (v_reserve_value_end);        
    ELSIF p_t <= 0
    THEN
      -- ���� �� ������ ������� ���������� ����    
      CALCULATE_FIRST_YEAR;
    END IF;
  
    IF p_t > 0
    THEN
      DBMS_OUTPUT.PUT_LINE('CALC_RESERVE_ANNIVERSARY ������ �������� ������� ������ ������ ' ||
                           to_char(l_cur_policy_start_date, 'dd.mm.yyyy'));
    
      IF trunc(l_cur_policy_start_date) >= trunc(v_hist_date)
         AND CHECK_HISTORY_RESERVE = 1
      THEN
        GET_HISTORY_RESERVE;
      ELSE
        CALCULATE_RESERVE;
      END IF;
    
    END IF;
  
    IF p_t > -1
    THEN
      -- ������� �������� ������������� �������
      add_reserve_value(v_reserve_value_end);
    END IF;
  
    /*exception 
    WHEN others THEN 
      raise;*/
  END;

  /**
  * ������� ������� �������� ������� �� �������� 
  * <br> ������� �� ������������ ����.
  * @param par_registry ������� �������, �� �������� ���������� ������
  * @param par_calc_date ���� �������
  */
  PROCEDURE calc_reserve_for_registry(par_registry IN r_reserve%ROWTYPE) IS
    v_reserve_value_for_begin r_reserve_value%ROWTYPE; -- ������ �� ������
    v_reserve_value_for_end   r_reserve_value%ROWTYPE; -- ������ �� �����
    v_n                       NUMBER; -- ����� �������� ���������� ����
    v_start_date              DATE; -- ���� ������ ���������� ����,  ������� ������ par_calc_date
    v_end_date                DATE; -- ���� ��������� ���������� ����, � ������� ������ par_calc_date
    res_reserve_value         NUMBER; -- �������� ������������ ������� �� ���� �������
    v_t                       NUMBER DEFAULT - 1;
    v_start_date_header       DATE;
  BEGIN
    -- ������� ���� ������ ���������������
    DBMS_OUTPUT.PUT_LINE('CALC_RESERVE_FOR_REGISTRY ������� ���� ������ ��������������� ' ||
                         par_registry.pol_header_id || ' ' || par_registry.policy_id);
  
    SELECT
    /*     (CASE WHEN (SELECT COUNT(*)
                FROM ins.t_addendum_type t,
                     ins.p_pol_addendum_type pt
                WHERE t.t_addendum_type_id = pt.t_addendum_type_id
                      AND pt.p_policy_id = pp.policy_id
                      AND t.brief = 'CLOSE_FIN_WEEKEND'
                ) > 0
          THEN TRUNC(MONTHS_BETWEEN(pc.end_date + 1, ph.start_date)/12)
     ELSE TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date)/12)
     END
    )*/
     TRUNC(MONTHS_BETWEEN(pc.end_date + 1, pc.start_date) / 12)
    ,pc.start_date
    ,pc.end_date
    ,ph.start_date
      INTO v_n
          ,v_start_date
          ,v_end_date
          ,g_start_date_header
      FROM ins.P_POL_HEADER ph
          ,ins.P_POLICY     pp
          ,ins.p_cover      pc
     WHERE 1 = 1
       AND ph.policy_header_id = par_registry.pol_header_id
       AND pp.policy_id = par_registry.policy_id
       AND pc.p_cover_id = par_registry.p_cover_id;
  
    DBMS_OUTPUT.PUT_LINE('START_DATE ' || v_start_date || ' v_n ' || v_n);
  
    -- ��������� ������ �� ������ � �� ����� ���������� ���� v_t
    FOR i IN 0 .. v_n
    LOOP
      v_t := v_t + 1;
      DBMS_OUTPUT.PUT_LINE('i ' || i || 'v_t ' || v_t);
    
      calc_reserve_anniversary(par_registry, i, v_t, v_start_date, v_end_date);
    END LOOP;
    -- ������������
  
    /*    exception 
          WHEN others then 
            -- todo �������� � ����������� �� ��, � �������� �������� �����������, ����� ��������
            -- � ���������� �� ��������������� - ������ �����?
            pkg_reserve_life.error(pkg_name, 'calc_reserve_for_iv', '��� ������� ������� �� �������� ����������� ��������� ������ (��. ����)' ||
                      par_registry.insurance_variant_id ||' ��� �������� ' || par_registry.policy_id 
                      || ' � ��������������� ' || par_registry.contact_id);
            raise;    
    */
  END;

  /**
  * ��������� ��������� ������ � r_reserve_ross ��� ���������� ���������
  * �������.
  * ��������� ������� �� ��
  */
  PROCEDURE check_new_regisry IS
    -- ���������� �������� �� ��������� ����������� �����
    CURSOR new_reserves IS
      SELECT vner.policy_id
            ,vner.p_asset_header_id
            ,vner.insurance_variant_id
            ,vner.t_product_line_id
        FROM v_not_exists_registry vner;
  BEGIN
    -- ������� ����� �������� 
    FOR rec IN new_reserves
    LOOP
      INSERT INTO r_reserve
        (ID, policy_id, insurance_variant_id, p_asset_header_id)
      VALUES
        (sq_r_reserve.NEXTVAL, rec.policy_id, rec.insurance_variant_id, rec.p_asset_header_id);
    END LOOP;
    NULL;
  END;

  /**
  * ��������� ������� �������� �� ��������. 
  * @param par_calc_reserve ������ ������� r_calc_reserve. ��� ������
  * ���� ��, ����� �������, ���� �������. ������ ������������ �� ���� ���������
  * ������� �������� ����������� ������� �������. �.� �� �� ��������� ������� ������� 
  * r_calc_results, ������� ��������� �� ������ ������ (par_calc_reserve). 
  * ����� ���������� �������� ������ � ������� r_calc_results ����������
  * �� ���������� ������� �� ���� ��������� �����������. ��� �������� �����
  * �������� ����������� ������������ ������� r_calc_results_temp.
  * �������� ��������, ������� ��������� � ������� ���������� �� ��������� ���������
  * ��������� � �������� ���������� ������� ��������� ����������� � 
  * ����������� ��������� ����������� ����� �� ������������� v_active_policy_ross
  */
  PROCEDURE calc_reserve_for_company(par_calc_reserve R_CALC_RESERVE%ROWTYPE) IS
    -- ������ �������� �������� �� ����������� �� ���� ������� ��������� 
    -- ����������� ����� 
    CURSOR registry_map(cur_calc_reserve R_CALC_RESERVE%ROWTYPE) IS
      SELECT r.ID
            ,r.policy_id
            ,r.insurance_variant_id
            ,r.t_product_line_id
            ,r.contact_id
            ,r.p_asset_header_id
            ,f.brief AS cur
        FROM r_reserve r
            ,(SELECT ap.policy_id
                    ,ap.fund_id
                FROM v_active_policy_life ap
              -- todo ��������� ������������ ������� ���������
               WHERE ap.START_DATE <= cur_calc_reserve.calc_date) apr
            ,FUND f
       WHERE 1 = 1
         AND r.policy_id = apr.policy_id
         AND apr.fund_id = f.fund_id
         AND r.insurance_variant_id IN (SELECT DISTINCT r.insurance_variant_id FROM r_reserve r);
    /*  (SELECT crr.insurance_variant_id 
     FROM r_calc_results crr
    WHERE crr.calc_reserve_id = cur_calc_reserve.id);*/
  
    registry      r_reserve%ROWTYPE;
    reserve_value NUMBER;
  BEGIN
    -- ����� ����� �������� �������� � r_reserve
    check_new_regisry;
  
    -- ������� ������� ��� ������������� �����������   
    DELETE FROM R_CALC_RESULTS_TEMP;
    -- ������� ������ ������;
    DELETE FROM R_ERROR_JOURNAL;
  
    -- �� ���� ��������� �������
    FOR rec IN registry_map(par_calc_reserve)
    LOOP
      registry.ID                   := rec.ID;
      registry.policy_id            := rec.policy_id;
      registry.insurance_variant_id := rec.insurance_variant_id;
      registry.contact_id           := rec.contact_id;
    
      BEGIN
        -- ������� �������� ������� �� �������� �� ���� �������
        calc_reserve_for_registry(registry);
      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
    END LOOP;
    /*    
        -- ������� ��������� �������
        delete from r_calc_results where calc_reserve_id = par_calc_reserve.id;
        
        -- ��������� ���������� ������� 
        insert into r_calc_results (ID,
                                         calc_reserve_id, 
                                         insurance_variant_id, 
                                         reserve_value,
                                         currency, 
                                         reserve_value_rur)
          -- ��������� ��������������� �� �������� �����������
          -- � ������ �������� �������� �� ��������� �� ����
          SELECT sq_r_calc_results.nextval, 
                 par_calc_reserve.id,
                 t.iv,
                 t.res,
                 t.cur,
                 t.res_rur
            from (select crt.insurance_variant_id as iv, 
                         sum(crt.reserve_value) as res, 
                         crt.currency as cur, 
                         sum(crt.reserve_value) * pkg_reserve.get_cross_rate_by_brief_cb(crt.currency,'RUR', par_calc_reserve.calc_date) as res_rur
                    from r_calc_results_temp crt
                group by crt.insurance_variant_id, crt.currency) t;
    */
  END;

  /** 
  * ��������� �������. �������� ����� ��������� ������-������ � ��������� �����
  * @param par_inv ������� �����������
  * @param par_sex ��� ���������������
  * @param par_age ��������� ������� ���������������
  * @param par_start_date ���� ������ ��������������� �� �������� ����������� 
  * @param par_end_date ���� ��������� ��������������� �� �������� �����������
  * @param par_periodisity ������������� ������ ������� (���������� �������� � ���)
  * @param par_r ���� ������ �������
  * @param par_j ����� ����������, ��������� �� ��������
  * @param par_b ����������� b
  * @param par_rent_periodicity ������������� ������� �����
  * @param par_rent_payment ������ ������� �����
  * @param par_rent_duration ���� ������� �����
  * @param par_has_additional ������� �������������� ������� �����������
  * @param par_payment_base ����� ������_������� �� ��������� ��������� �����������
  * @return ������-�����/��������� �����, ���� 0, ���� 
  * ��� ������� ���� ������
  */
  FUNCTION act_function
  (
    par_inv              IN NUMBER
   ,par_sex              IN NUMBER
   ,par_age              IN NUMBER
   ,par_start_date       IN DATE
   ,par_end_date         IN DATE
   ,par_periodicity      IN NUMBER
   ,par_r                IN NUMBER
   ,par_j                IN NUMBER
   ,par_b                IN NUMBER
   ,par_rent_periodicity IN NUMBER DEFAULT NULL
   ,par_rent_payment     IN NUMBER DEFAULT NULL
   ,par_rent_duration    IN NUMBER DEFAULT NULL
   ,par_has_additional   IN NUMBER DEFAULT 0
   ,par_payment_base     IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_values  PKG_RESERVE_R_LIFE.hist_values_type;
    res_value NUMBER;
  BEGIN
    BEGIN
      -- �������������� ������ �� �������� �������
      v_values.fact_yield_rate := par_j;
      IF v_values.fact_yield_rate IS NULL
         OR v_values.fact_yield_rate = 0
      THEN
        v_values.fact_yield_rate := get_plan_yield_rate(par_start_date);
      END IF;
      v_values.periodicity      := par_periodicity;
      v_values.payment_duration := par_r;
      v_values.start_date       := par_start_date;
      v_values.end_date         := par_end_date;
      v_values.b                := par_b;
      v_values.rent_periodicity := par_rent_periodicity;
      v_values.rent_payment     := par_rent_payment;
      v_values.rent_payment     := par_rent_duration;
      v_values.has_additional   := par_has_additional;
      v_values.payment_base     := par_payment_base;
    
      -- �������������� ������ �� ���������������;
      v_values.sex := par_sex;
      v_values.age := par_age;
    
      res_value := pkg_reserve_life_alg.act_iv(par_inv, v_values);
    
      /*   exception 
      when others then 
        res_value := 0;
         */
    END;
  
    RETURN res_value;
  END;

  /** 
  * ������� �������� ����������� ������� �� ����
  * @param p_policy_header_id �� �������� �����������
  * @param p_insurance_variant_id �� ��������� ���������
  * @param p_contact_id �� ���������������
  * @param p_calc_date ����, �� ������� ������������� ���������� ������ 
  */
  FUNCTION get_VB
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT par_date_begin
                    ,par_date_end
                    ,par_value_for_begin
                    ,par_value_for_end
                    ,par_calc_date
                FROM (SELECT rv.reserve_date par_date_begin
                            ,lead(rv.reserve_date) OVER(PARTITION BY reserve_id ORDER BY reserve_date) par_date_end
                            ,rv.PLAN par_value_for_begin
                            ,lead(rv.PLAN) OVER(PARTITION BY reserve_id ORDER BY reserve_date) par_value_for_end
                            ,p_calc_date par_calc_date
                        FROM reserve.r_reserve_value rv
                       WHERE rv.reserve_id IN
                             (SELECT rr.ID
                                FROM reserve.r_reserve rr
                               WHERE 1 = 1
                                 AND rr.pol_header_id = p_policy_header_id
                                 AND rr.policy_id = p_policy_id
                                 AND rr.insurance_variant_id = p_insurance_variant_id
                                 AND rr.p_asset_header_id = p_p_asset_header_id)
                       ORDER BY rv.reserve_date)
               WHERE 1 = 1
                 AND p_calc_date BETWEEN par_date_begin AND par_date_end)
    LOOP
      --DBMS_OUTPUT.PUT_LINE ('����� ����� �������� '||p_policy_header_id||' '||p_policy_id||' '||p_insurance_variant_id||' '||p_p_asset_header_id||' '||p_calc_date);             
      --DBMS_OUTPUT.PUT_LINE ('����� �������. �������� '||i.par_date_begin||' '||i.par_date_end||' '||i.par_value_for_begin||' '||i.par_value_for_begin||' '||i.par_calc_date);             
      RESULT := line_interpolation(i.par_date_begin
                                  ,i.par_date_end
                                  ,i.par_value_for_begin
                                  ,i.par_value_for_end
                                  ,i.par_calc_date);
    
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_V
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.tV_p
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.reserve_date = p_calc_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.tV_p;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_P
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.P
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.insurance_year_date = p_calc_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.P;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_VS
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_reserve_date         IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.TVS_P
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.reserve_date = p_reserve_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.TVS_P;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_S
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.S
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.insurance_year_date = p_calc_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.S;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_PP
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
  
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.P
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.reserve_date = p_calc_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.P;
    END LOOP;
    RETURN RESULT;
  END;

  FUNCTION get_SS
  (
    p_policy_header_id     IN NUMBER
   ,p_policy_id            IN NUMBER
   ,p_insurance_variant_id IN NUMBER
   ,p_p_asset_header_id    IN NUMBER
   ,p_calc_date            IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  
  BEGIN
    FOR i IN (SELECT rv.S
                FROM reserve.r_reserve_value rv
                    ,reserve.r_reserve       rr
               WHERE 1 = 1
                 AND rr.pol_header_id = p_policy_header_id
                 AND rr.policy_id = p_policy_id
                 AND rr.insurance_variant_id = p_insurance_variant_id
                 AND rr.p_asset_header_id = p_p_asset_header_id
                 AND rv.reserve_id = rr.ID
                 AND rv.reserve_date = p_calc_date
                 AND ROWNUM < 2)
    LOOP
      RESULT := i.S;
    END LOOP;
    RETURN RESULT;
  END;

/*

  BEGIN
    -- Initialization
    < STATEMENT >;*/

END;
/

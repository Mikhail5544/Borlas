CREATE OR REPLACE PACKAGE reserve.pkg_reserve_life_alg IS
  /**
  * ��������� ��� ��������� ����������� �����
  * @author Ivanov D.
  * @version Reserve For Life 1.1
  * @since 1.1
  */
  pkg_name CONSTANT VARCHAR2(20) := 'pkg_reserve_alg_life';

  -- �������������� ��������� ����������� (t_product_line_option):
  -- ��������� ����������� �����
  iv_01 CONSTANT VARCHAR2(30) := 'END';
  -- ��������� �4 ������� � ��������� ������� � ������ ������
  iv_02 CONSTANT VARCHAR2(30) := 'PEPR';
  -- ����������� �� ������ ������ �� ���� � �������� �����
  iv_03 CONSTANT VARCHAR2(30) := 'TERM';
  -- ����������� �� �������
  iv_04 CONSTANT VARCHAR2(30) := '30500036';
  -- ����������� ����� � ������������� ������ ������� ���������� �����������
  iv_05 CONSTANT VARCHAR2(30) := '30500037';
  -- ����������� ��������� �����
  iv_06 CONSTANT VARCHAR2(30) := '30500038';
  -- ��������� ����������� �����
  iv_07 CONSTANT VARCHAR2(30) := '30500039';
  -- ����������� �� ������ ������ �� ����������� ������
  iv_08 CONSTANT VARCHAR2(30) := '30500040';
  -- ����������� �� ������ ������������ ������������ � ���������� ����������� ������
  iv_09 CONSTANT VARCHAR2(30) := '30500041';
  -- ����������� �� ������ ��������� ������ ����������������
  iv_10 CONSTANT VARCHAR2(30) := '30500042';
  -- ����������� �� ������ ��������� ������ � ���������� ����������� ������
  iv_11 CONSTANT VARCHAR2(30) := '30500043';
  -- ����������� �� ������ ������������ ������������ - ������������ �� ������ ���������� �������
  iv_12 CONSTANT VARCHAR2(30) := '30500044';
  -- ������� ������� � ������ ������
  iv_13 CONSTANT VARCHAR2(30) := '30500045';
  -- ������� ������� � ������ ������
  iv_14 CONSTANT VARCHAR2(30) := 'INVEST2';
  -- ����������� �� ��������� "��������� ���������������� ���������� �������� �����������"
  iv_15 CONSTANT VARCHAR2(30) := 'DD';
  --������� �������� ��������� ��������������
  iv_16 CONSTANT VARCHAR2(30) := 'PEPR_C';
  --������� �������� ��������� ����������������
  iv_17 CONSTANT VARCHAR2(30) := 'PEPR_B';
  --������� �������� ��������� �����������
  iv_18 CONSTANT VARCHAR2(30) := 'PEPR_A';
  --������� �������� ��������� ����������� ����
  iv_19 CONSTANT VARCHAR2(30) := 'PEPR_A_PLUS';
  --������� �������� ���� ��������� ������
  iv_20 CONSTANT VARCHAR2(30) := 'GOLD';
  --������� �������� ���� ��������� �����
  iv_21 CONSTANT VARCHAR2(30) := 'OIL';
  --��������� ��������� ������-������
  iv_22 CONSTANT VARCHAR2(30) := 'PEPR_INVEST_RESERVE';
  --'��������� ����������� ������������ ����� � �����'
  iv_23 CONSTANT VARCHAR2(30) := 'Ins_life_to_date';
  -- ���� �������� � �������� ������
  const_f CONSTANT NUMBER(9) := 0.1;

  /**
  * ������� ���������� �������� ��������� � � ����� ������� ������.
  * ������ ������� (2.3.6)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * <br> �������������� �������� <code>iv_12</code>
  * @return �������� ������������ a � �������
  */
  FUNCTION get_a_dot
  (
    par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER;

  /**
  * ������� ������� ������������ A �������. ��. ������� (2.3.10)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @return �������� ������������ � �������
  */
  FUNCTION get_a_big_1
  (
    par_yield_rate NUMBER
   ,par_n          NUMBER
   ,par_age        NUMBER
   ,par_sex        NUMBER
  ) RETURN NUMBER;

  /**
  * ������� ������� ������������ �. ��. ������� (2.3.8)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ a
  */
  FUNCTION get_a
  (
    par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER;

  /**
  * �������� ������������� ������
  * @param par_payment ������-�����
  * @param par_yield_rate ����� ���������� (�������� ��� �����������)
  * @param par_n ���� ������ �������
  * @param par_periodicity ������������� ������ �������
  * @param par_B ����������� �
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ����������������� ������-������
  */
  FUNCTION get_tspm
  (
    par_payment        NUMBER
   ,par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_periodicity    NUMBER
   ,par_b              NUMBER
   ,par_sex            NUMBER
   ,par_age            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER;

  FUNCTION act_iv_01
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ �� ����".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_02
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER;

  /**
  * ��������� �������. ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv(...)
  * @param par_inv ������� �����������
  * @param par_values �������� �������� �������.
  * @param par_insured �������� ���������������
  */
  FUNCTION act_iv
  (
    par_inv    IN NUMBER
   ,par_values IN pkg_reserve_r_life.hist_values_type
  ) RETURN NUMBER;

  /**
  * ������� ������� �������� ������� �� �������� �������.
  * <p> �������������� ���������� ���������� ������ ��
  * <br> �������� �����������. ����� �������, ��� �������
  * <br> �� ������� �������� �� ��������� �����������
  * <br> ������ ����� ����� �� ���������. ������� ��������
  * <br> ����������� ��������� �� ������� �������� �������.
  * @param par_registry ������� �������
  * @param par_start_date ���� ������ ��������������� ������
  * @param par_ins_start_date ���� ������ ���������� ���� par_t
  * @param par_values �������� �� ������ � �������� �����������, ���������� �������� par_t
  * @param par_t ����� ���������� ����, � ������� ���������� ������
  * @param par_reserve_value_for_begin �������� �������
  * <br> �� ������ �����. ���� � ������� par_t. ������������ ��������
  * @param par_insured ������ ���������������
  * @param par_periodical ���������� �� ������ �� �������� �������
  * @param par_n ���� �����������
  * @param par_c �������� ����� ����������
  * @param par_j ����������� ����� ����������
  * @param par_b ����������� �
  * @param par_kom ���� �������� (������� �� pat_t)
  */
  FUNCTION calc_reserve_for_iv
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE;

END;
/
CREATE OR REPLACE PACKAGE BODY reserve.pkg_reserve_life_alg IS

  /**
  * ������� ���������� �������� ��������� E .
  * ������ ������� (2.3.1) � (2.3.2) �������� �� �����
  * @param par_nu ������� �������������� ��������� 1/(1 + c)
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ E
  */
  g_lob_line_brief VARCHAR2(200);

  gc_pkg_name CONSTANT ins.pkg_trace.t_object_name := 'PKG_RESERVE_LIFE_ALG';

  FUNCTION get_e
  (
    par_nu             NUMBER
   ,par_n              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
  BEGIN
    IF par_has_additional = 0
    THEN
      RETURN(1 - pkg_reserve_life.get_death_portability(par_sex, par_age, par_n)) * power(par_nu
                                                                                         ,par_n);
    ELSE
      RETURN(1 - pkg_reserve_life.get_accident_portability(par_sex, par_age, par_n)) * power(par_nu
                                                                                            ,par_n);
    END IF;
  END;

  /**
  * ������� ���������� �������� ��������� � � ����� ������� ������.
  * ������ ������� (2.3.6) � (2.3.7)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ a � �������
  */
  FUNCTION get_a_dot
  (
    par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
    v_nu    NUMBER;
    v_a_dot NUMBER;
    v_multi NUMBER;
  BEGIN
    v_nu    := 1 / (1 + par_yield_rate);
    v_a_dot := 0;
    -- ������� ����������� a c �������
    -- todo �������������� ������
    FOR k IN 0 .. par_n - 1
    LOOP
      IF par_has_additional = 0
      THEN
        v_multi := power(v_nu, k) * (1 - pkg_reserve_life.get_death_portability(par_sex, par_age, k));
      ELSE
        v_multi := power(v_nu, k) *
                   (1 - pkg_reserve_life.get_accident_portability(par_sex, par_age, k));
      END IF;
      v_a_dot := v_a_dot + v_multi;
      --      DBMS_OUTPUT.PUT_LINE('k = ' || k || '; nu_k = '|| power(v_nu, k) ||'; p = ' || (1 - get_death_portability(par_sex, par_age, k)) );
    END LOOP;
    RETURN v_a_dot;
  END;

  /**
  * ������� ������� ������������ �. ��. ������� (2.3.8) � (2.3.9)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ a
  */
  FUNCTION get_a
  (
    par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
    v_nu   NUMBER;
    v_dlt  NUMBER;
    v_dlt2 NUMBER;
    v_a    NUMBER;
  BEGIN
    v_nu   := 1 / (1 + par_yield_rate);
    v_dlt  := ln(1 + par_yield_rate);
    v_dlt2 := v_dlt * v_dlt;
  
    -- ������� ����������� �
    -- todo �������������� ������
    v_a := (par_yield_rate * (1 - v_nu) *
           get_a_dot(par_yield_rate, par_n, par_age, par_sex, par_has_additional) -
           (par_yield_rate - v_dlt) * (1 - get_e(v_nu, par_n, par_age, par_sex, par_has_additional))) /
           v_dlt2;
    RETURN v_a;
  END;

  /**
  * ������� ������� ������������ A �������. ��. ������� (2.3.10)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @return �������� ������������ � �������
  */
  FUNCTION get_a_big_1
  (
    par_yield_rate NUMBER
   ,par_n          NUMBER
   ,par_age        NUMBER
   ,par_sex        NUMBER
  ) RETURN NUMBER IS
    v_nu     NUMBER;
    v_i_summ NUMBER;
    res      NUMBER;
  BEGIN
    v_nu     := 1 / (1 + par_yield_rate);
    v_i_summ := 0;
  
    FOR i IN 0 .. par_n - 1
    LOOP
      v_i_summ := v_i_summ + power(v_nu, i + 1) *
                  (1 - pkg_reserve_life.get_death_portability(par_sex, par_age, i)) *
                  pkg_reserve_life.get_death_portability(par_sex, par_age + i);
    END LOOP;
  
    res := v_i_summ * par_yield_rate / ln(1 + par_yield_rate);
    RETURN res;
  END;

  /**
  * ������� ������� ������������ (IA) �������. ��. ������� (2.3.11)
  * @param par_yield_rate ����� ����������
  * @param par_n ���� �����������
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @return �������� ������������ � �������
  */
  FUNCTION get_i_a_big_1
  (
    par_yield_rate NUMBER
   ,par_n          NUMBER
   ,par_age        NUMBER
   ,par_sex        NUMBER
  ) RETURN NUMBER IS
    v_nu     NUMBER;
    v_dlt    NUMBER;
    v_fract  NUMBER;
    v_item   NUMBER;
    v_i_summ NUMBER;
    v_k_summ NUMBER;
    res      NUMBER;
  BEGIN
    v_nu     := 1 / (1 + par_yield_rate);
    v_dlt    := ln(1 + par_yield_rate);
    v_fract  := par_yield_rate / v_dlt;
    v_i_summ := 0;
    v_k_summ := 0;
    FOR i IN 0 .. par_n - 1
    LOOP
      v_item   := power(v_nu, i + 1) *
                  (1 - pkg_reserve_life.get_death_portability(par_sex, par_age, i)) *
                  pkg_reserve_life.get_death_portability(par_sex, par_age + i);
      v_i_summ := v_i_summ + v_item;
      v_k_summ := v_k_summ + (i + 1) * v_item;
    END LOOP;
    res := v_fract * v_k_summ - v_fract * v_i_summ +
           (par_yield_rate - v_dlt) * v_i_summ / (v_dlt * v_dlt);
    RETURN res;
  END;

  /**
  * ������� ������� �������� g. ��. ������� (2.3.1)
  * @param par_yield_rate ����� ����������
  * @param par_t ����� ���������� ����
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ � �������
  */
  FUNCTION get_g
  (
    par_yield_rate     NUMBER
   ,par_t              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
    v_dlt NUMBER;
    v_u   NUMBER;
    v_q   NUMBER;
    res   NUMBER;
  BEGIN
    v_q   := pkg_reserve_life.get_death_portability(par_sex, par_age + par_t - 1);
    v_dlt := ln(1 + par_yield_rate);
    res   := (v_dlt - par_yield_rate) / (v_dlt * v_dlt);
    -- ���� ���� �������������� �������
    IF par_has_additional = 1
    THEN
      v_u := pkg_reserve_life.get_u(par_age + par_t - 1);
      res := res * (v_q + v_u - v_q * v_u);
    ELSE
      res := res * v_q;
    END IF;
    res := res + par_yield_rate / v_dlt;
  
    RETURN res;
  END;

  /**
  * ������� ������� �������� G �������. ��. ������� (2.3.2)
  * @param par_yield_rate ����� ����������
  * @param par_r ���� ������ �������
  * @param par_t ����� ���������� ����
  * @param par_age ������� ���������������
  * @param par_sex ��� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ������������ � �������
  */
  FUNCTION get_g_big
  (
    par_yield_rate     NUMBER
   ,par_r              NUMBER
   ,par_t              NUMBER
   ,par_age            NUMBER
   ,par_sex            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    res := 0;
    IF par_t <= par_r
    THEN
      res := get_g(par_yield_rate, par_t, par_age, par_sex, par_has_additional);
    END IF;
    RETURN res;
  END;

  /**
  * �������� ������������� ������
  * @param par_payment ������-�����
  * @param par_yield_rate ����� ���������� (�������� ��� �����������)
  * @param par_n ���� ������ �������
  * @param par_periodicity ������������� ������ �������
  * @param par_B ����������� �
  * @param par_sex ��� ���������������
  * @param par_age ������� ���������������
  * @param par_has_additional ������� �� �������������� �������
  * @return �������� ����������������� ������-������
  */
  FUNCTION get_tspm
  (
    par_payment        NUMBER
   ,par_yield_rate     NUMBER
   ,par_n              NUMBER
   ,par_periodicity    NUMBER
   ,par_b              NUMBER
   ,par_sex            NUMBER
   ,par_age            NUMBER
   ,par_has_additional NUMBER
  ) RETURN NUMBER IS
    res_tspm NUMBER;
    v_temp   NUMBER;
    v_nu     NUMBER;
    v_b4     NUMBER;
    v_a      NUMBER;
  BEGIN
    -- ��������������� ����������
    v_nu := 1 / (1 + par_yield_rate);
    v_b4 := 0;
  
    -- ������� ����������� b
    FOR i IN 1 .. 4 * par_periodicity
    LOOP
      v_temp := (i - 1) / par_periodicity;
      v_b4   := v_b4 + (1 - pkg_reserve_life.get_death_portability(par_sex, par_age, v_temp)) *
                power(v_nu, v_temp) * pkg_reserve_life.get_kom(v_temp);
    
    END LOOP;
  
    -- ������� ����������� �
    v_a := get_a(par_yield_rate, par_n, par_age, par_sex, par_has_additional);
  
    -- ������� ���������������� �����
    res_tspm := par_payment * (1 + par_b * v_b4 / ((1 - const_f) * v_a));
  
    RETURN res_tspm;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� ����������� �� ������ ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_01(...)
  */
  FUNCTION act_iv_01
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    res_act := get_a_big_1(par_c, 100 - par_values.age, par_values.age, par_values.sex);
    res_act := res_act / (1 - const_f);
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ �� ����".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_02
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    -- todo � ������ ������ � �������� ��������� ������� �1
    res_act := get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
    res_act := res_act / (1 - const_f);
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ �� ���� � �������� �����".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_03
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
  
    v_nu      NUMBER;
    v_i_summ  NUMBER;
    v_j_summ  NUMBER;
    res_act   NUMBER;
    v_old_age NUMBER;
    v_q       NUMBER;
    v_q_k     NUMBER;
    v_q_k_int NUMBER;
    v_temp    NUMBER;
    i12       NUMBER;
    i12_int   NUMBER;
  BEGIN
    -- ������������� �������
    v_nu      := 1 / (1 + par_c);
    v_i_summ  := 0;
    v_old_age := par_values.age;
    v_q       := pkg_reserve_life.get_death_portability(par_values.sex, v_old_age);
    v_q_k_int := 0;
    FOR i IN 0 .. (12 * par_n - 1)
    LOOP
      v_j_summ := 0;
      i12      := i / 12;
      i12_int  := trunc(i12, 0);
      FOR j IN 0 .. 12 * par_n - i - 1
      LOOP
        v_j_summ := v_j_summ + power(v_nu, j / 12);
      END LOOP; --for j
      -- todo �������������� ������ v_p
    
      IF v_old_age <> par_values.age + i12_int
      THEN
      
        v_q_k_int := v_q_k_int + v_q;
      
        v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + i12_int);
      
        v_old_age := par_values.age + i12_int;
      END IF;
    
      v_q_k := 1 - (1 - v_q_k_int) * (1 - (i12 - i12_int) * v_q);
    
      v_temp := v_j_summ * power(v_nu, i12) * (1 - v_q_k);
    
      v_temp := v_temp * v_q;
    
      v_i_summ := v_i_summ + v_temp;
    END LOOP; -- for i
    res_act := v_i_summ / (144 * (1 - const_f));
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� �������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_04
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    v_nu    NUMBER;
    res_act NUMBER;
  BEGIN
    -- todo � ������ ������ � �������� ��������� ������� �1
    v_nu    := 1 / (1 + par_c);
    res_act := get_e(v_nu, par_n, par_values.age, par_values.sex, par_values.has_additional);
    res_act := res_act / (1 - const_f);
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� � ������������� ������ ������� ���������� �����������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_05
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    v_nu    NUMBER;
    res_act NUMBER;
  BEGIN
    v_nu    := 1 / (1 + par_c);
    res_act := power(v_nu, par_n) / ((1 - const_f) * par_values.periodicity);
  
    res_act := res_act /
               (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
               par_values.periodicity);
  
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� ��������� �����".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_06
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    v_nu    NUMBER;
    res_act NUMBER;
  BEGIN
    v_nu := 1 / (1 + par_c);
    -- todo ���� (1 - power(v_nu, v_k)) - v_k -  ��� ����� ��� � ������� ������� �� ������� ����� � ������� �������
    res_act := power(v_nu, par_n) * (1 - power(v_nu, par_n)) /
               ((1 - const_f) * par_values.periodicity * par_values.rent_periodicity *
                (1 - power(v_nu, 1 / par_values.rent_periodicity)));
    IF par_values.has_additional = 0
    THEN
      res_act := res_act /
                 get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "��������� ����������� �����".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_07
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    v_nu     NUMBER;
    res_act  NUMBER;
    v_i_summ NUMBER;
    v_pn     NUMBER;
    v_dlt    NUMBER;
  
  BEGIN
    v_dlt    := ln(1 + par_c);
    v_pn     := par_values.rent_periodicity * par_n;
    v_nu     := 1 / (1 + par_c);
    v_i_summ := 0;
  
    FOR i IN 0 .. v_pn - 1
    LOOP
      v_i_summ := v_i_summ +
                  (1 - i / v_pn) * power(v_nu, (i + 1) / par_values.rent_periodicity) *
                  pkg_reserve_life.get_death_portability(par_values.sex
                                                        ,par_values.age +
                                                         i / par_values.rent_periodicity) *
                  (1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                             ,par_values.age
                                                             ,i / par_values.rent_periodicity));
    END LOOP;
  
    res_act := v_i_summ * par_c / ((1 - const_f) * par_values.rent_periodicity * v_dlt);
  
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
  
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ ����������  ����������� ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_08
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    res_act := 0.4 * get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
    res_act := res_act / (1 - const_f);
    IF par_periodical = 1
    THEN
      res_act := res_act /
                 (get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) *
                 par_values.periodicity);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������������ ������������ ����������  ����������� ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_09
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    res_act := 0.0548 * (1 - const_f); -- ����������� - ��� TNS2
  
    IF par_periodical = 1
    THEN
      res_act := res_act / par_values.periodicity;
    ELSE
      res_act := res_act *
                 get_a_dot(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ��������� ������ ����������  ����������� ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_10
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    res_act := 0.0866 * (1 - const_f); -- ����������� - ��� TNS3
  
    IF par_periodical = 1
    THEN
      res_act := res_act / par_values.periodicity;
    ELSE
      res_act := res_act *
                 get_a_dot(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ��������� ������ ���������������� ����������  ����������� ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_11
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
  BEGIN
    res_act := 0.1263 * (1 - const_f); -- ����������� - ��� TNS4
  
    IF par_periodical = 1
    THEN
      res_act := res_act / par_values.periodicity;
    ELSE
      res_act := res_act *
                 get_a_dot(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional);
    END IF;
    RETURN res_act;
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������������ ������������ - ������������ �� ������ ���������� �������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_12
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0; -- ��� �������������� �������
  END;

  /**
  * ��������� ������� ��� �������� �����������
  * <br> "������� ������� � ������ ������".
  * <p> ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv_03(...)
  */
  FUNCTION act_iv_13
  (
    par_values     IN pkg_reserve_r_life.hist_values_type
   ,par_periodical IN NUMBER
   ,par_n          IN NUMBER
   ,par_c          IN NUMBER
  ) RETURN NUMBER IS
    res_act NUMBER;
    v_a_big NUMBER;
  BEGIN
    -- todo ��������� �������� ������-������ �� ��������� ��������� �����������
    -- ����� par_values.payment ��� ����� �� ��������� ��������� ��� ��������������� � ��������
    res_act := par_values.payment;
    IF par_periodical = 0
    THEN
      v_a_big := get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
      res_act := res_act * v_a_big / (1 - const_f - v_a_big);
    ELSE
      v_a_big := get_i_a_big_1(par_c, par_n, par_values.age, par_values.sex);
      res_act := res_act * v_a_big /
                 ((1 - const_f) *
                 get_a(par_c, par_n, par_values.age, par_values.sex, par_values.has_additional) -
                 v_a_big);
    END IF;
  END;

  /**
  * ��������� �������. ��������� ��������� ����� � ������-�����, ��� ���
  * <br> ������-���� = ���������_����� * act_iv(...)
  * @param par_inv ������� �����������
  * @param par_values �������� �������� �������.
  */
  FUNCTION act_iv
  (
    par_inv    IN NUMBER
   ,par_values IN pkg_reserve_r_life.hist_values_type
  ) RETURN NUMBER IS
    res_value    NUMBER;
    v_periodical NUMBER;
    v_n          NUMBER;
    v_c          NUMBER;
    --
  BEGIN
    SELECT brief INTO g_lob_line_brief FROM ins.t_lob_line WHERE t_lob_line_id = par_inv;
  
    -- ���������� �� ������
    IF par_values.payment_duration = 1
       AND par_values.periodicity = 1
    THEN
      v_periodical := 0;
    ELSE
      v_periodical := 1;
    END IF;
  
    -- ���� �����������
    v_n := MONTHS_BETWEEN(par_values.end_date, par_values.start_date) / 12;
    v_c := par_values.fact_yield_rate;
  
    -- � ����������� �� �������� �����������
    -- ������������ ��������� �������
    CASE par_inv
    -- ����������� ����������� �� ������ ������
      WHEN iv_01 THEN
        res_value := act_iv_01(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_02 THEN
        res_value := act_iv_02(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_03 THEN
        res_value := act_iv_03(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_04 THEN
        res_value := act_iv_04(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_05 THEN
        res_value := act_iv_05(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_06 THEN
        res_value := act_iv_06(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_07 THEN
        res_value := act_iv_07(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_08 THEN
        res_value := act_iv_08(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_09 THEN
        res_value := act_iv_09(par_values, v_periodical, v_n, v_c);
        -- ����������� ����������� �� ������ ������
      WHEN iv_10 THEN
        res_value := act_iv_10(par_values, v_periodical, v_n, v_c);
      
    -- ����������� ����������� �� ������ ������
      WHEN iv_11 THEN
        res_value := act_iv_11(par_values, v_periodical, v_n, v_c);
      
    -- ����������� ����������� �� ������ ������
      WHEN iv_12 THEN
        res_value := act_iv_12(par_values, v_periodical, v_n, v_c);
      WHEN iv_13 THEN
        res_value := act_iv_13(par_values, v_periodical, v_n, v_c);
      ELSE
        --raise case_not_found;
        RETURN NULL;
    END CASE;
    RETURN res_value;
  END;

  -- ������ ��������
  FUNCTION a_z
  (
    p_p_policy_id IN NUMBER
   ,rvd_value     NUMBER
  ) RETURN NUMBER IS
    v_res NUMBER;
  
  BEGIN
    /*
        POL_CASH_SURR_METHOD
        [30.01.2009 19:24:20]  0 - 3% ������. 1 - 4% ������. 2 - % ����� �����
    */
    v_res := ins.pkg_pol_cash_surr_method.load_a_z(p_p_policy_id);
  
    IF g_lob_line_brief = 'INVEST2'
    THEN
      v_res := 0.01;
      RETURN v_res;
    END IF;
  
    IF g_lob_line_brief = 'PEPR_C'
       OR g_lob_line_brief = 'PEPR_B'
       OR g_lob_line_brief = 'PEPR_A'
       OR g_lob_line_brief = 'PEPR_A_PLUS'
       OR g_lob_line_brief = 'OIL'
       OR g_lob_line_brief = 'GOLD'
    THEN
      v_res := 0.04;
      RETURN v_res;
    END IF;
  
    IF rvd_value < 0.1
    THEN
      v_res := 0.01;
      RETURN v_res;
    END IF;
  
    RETURN v_res;
  
    /*
            �� 30.03.2007 ������ �������� 3 %;
            �����  30.03.2007 �������� 4 %;
    */
  
    /* ������ ��� ��������������
    ���������� 2009.01.20
    
        IF (rvd_value = 0.02 OR rvd_value = 0.03 OR rvd_value = 0.05 OR rvd_value = 0.07) THEN
           v_res := 0.01;
        ELSE
           v_res := 0.04;
        END IF;
    */
    RETURN v_res;
  END;

  FUNCTION is_onepay(par_periodical NUMBER) RETURN NUMBER IS
    v_one_payment NUMBER;
  BEGIN
    IF par_periodical = 0
    THEN
      v_one_payment := 1;
    ELSE
      v_one_payment := 0;
    END IF;
    RETURN v_one_payment;
  END is_onepay;

  FUNCTION get_gender(par_gender NUMBER) RETURN VARCHAR2 IS
    v_gender VARCHAR2(1);
  BEGIN
    IF par_gender = 0
    THEN
      v_gender := 'w';
    ELSIF par_gender = 1
    THEN
      v_gender := 'm';
    END IF;
    RETURN v_gender;
  END get_gender;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "����������� ����������� �� ������ ������".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_01
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ_plan NUMBER;
    v_i_summ_fact NUMBER;
    v_c1          NUMBER; -- �������� ����� ���������� + 1
    v_j1          NUMBER; -- ����������� ����� ���������� + 1
    v_q           NUMBER;
    v_p           NUMBER;
    v_g           NUMBER;
  
    v_p_re NUMBER;
    v_g_re NUMBER;
  
    v_axn  NUMBER;
    v_a_xn NUMBER;
  
    v_axn_re  NUMBER;
    v_a_xn_re NUMBER;
  
    v_lives                NUMBER(1); -- ��� �� ��������������
    v_i_temp               NUMBER;
    v_diff                 NUMBER;
    tspm_g_plan            NUMBER; -- ������������ tspm �� G
    tspm_g_fact            NUMBER; -- ������������ tspm �� G
    res_reserve_value      r_reserve_value%ROWTYPE;
    res_reserve_value_prev r_reserve_value%ROWTYPE;
    a                      NUMBER;
    one_payment            NUMBER(1);
    sex_vh                 VARCHAR2(2);
    ft                     NUMBER;
    v_az                   NUMBER;
  
    v_p_sum    NUMBER;
    v_p_sum_re NUMBER;
  BEGIN
  
    v_az := a_z(par_registry.policy_id, par_values.rvb_value);
  
    res_reserve_value.a_z := v_az;
  
    dbms_output.put_line('(calc_reserve_for_iv_01) az (f=' || par_values.rvb_value || ')' || v_az);
    --
    dbms_output.put_line(' ��������� ��� ' || par_t || '');
    dbms_output.put_line('�������� ����������� ������� :');
    dbms_output.put(' reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put(' insurance_year_number ' || par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put(' insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put(' tVZ_p ' || par_reserve_value_for_begin.tvz_p);
    dbms_output.put_line('');
    --
    a := 0.0025;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
  
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    dbms_output.put(lpad(' age ' || par_values.age, 10, ' '));
    dbms_output.put(lpad(' sex_vh ' || sex_vh, 10, ' '));
    dbms_output.put(lpad(' ���� ���-���(n) ' || par_n, 10, ' '));
    dbms_output.put(lpad(' ����� ���-��� ' || par_values.fact_yield_rate, 10, ' '));
    dbms_output.put(lpad(' �������� ' || par_values.rvb_value, 10, ' '));
    dbms_output.put(lpad(' ���. �����. ' || par_values.deathrate_id, 10, ' '));
    dbms_output.put_line(lpad(' ������� ������. ' || abs(sign(par_periodical - 1))
                             ,10
                             ,' '));
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
  
    --
    dbms_output.put_line(' v_P ' || v_p || ' v_G ' || v_g || 'par_periodical ' || par_periodical);
    -- � ���� ������ �� ����������
    IF par_periodical = 0
    THEN
      v_axn                  := ins.pkg_amath.axn(par_values.age + par_t
                                                 ,par_n - par_t
                                                 ,sex_vh
                                                 ,par_values.k_coef
                                                 ,par_values.s_coef
                                                 ,par_values.deathrate_id
                                                 ,par_values.fact_yield_rate);
      res_reserve_value.tv_p := ROUND(v_axn, 10);
      res_reserve_value.tv_f := ROUND(v_axn, 10);
    
      v_axn_re := ins.pkg_amath.axn(par_values.age + par_t
                                   ,par_n - par_t
                                   ,sex_vh
                                   ,par_values.k_coef_re
                                   ,par_values.s_coef_re
                                   ,par_values.deathrate_id
                                   ,par_values.fact_yield_rate);
    
      res_reserve_value.tv_p_re := ROUND(v_axn_re, 10);
      res_reserve_value.tv_f_re := ROUND(v_axn_re, 10);
      --
      v_a_xn := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,1
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,10);
      --
      res_reserve_value.tvexp_p := a * v_g * v_a_xn;
      res_reserve_value.tvexp_f := res_reserve_value.tvexp_p;
      --
      res_reserve_value.tvs_p := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
      res_reserve_value.tvs_f := res_reserve_value.tvs_p;
    ELSE
      res_reserve_value.plan := 0;
    
      v_axn := ins.pkg_amath.axn(par_values.age + par_t
                                ,par_n - par_t
                                ,sex_vh
                                ,par_values.k_coef
                                ,par_values.s_coef
                                ,par_values.deathrate_id
                                ,par_values.fact_yield_rate);
    
      dbms_output.put_line('������� ������ ��� a_xn ');
      dbms_output.put_line('������� ������ ��� a_xn x ' || (par_values.age + par_t));
      dbms_output.put_line('������� ������ ��� a_xn n ' || (par_n - par_t));
      dbms_output.put_line('������� ������ ��� a_xn sex ' || sex_vh);
      dbms_output.put_line('������� ������ ��� a_xn i ' || par_values.fact_yield_rate);
      dbms_output.put_line('������� ������ ��� a_xn k_coef ' || par_values.k_coef);
      dbms_output.put_line('������� ������ ��� a_xn s_coef ' || par_values.s_coef);
      dbms_output.put_line('������� ������ ��� a_xn table ' || par_values.deathrate_id);
    
      v_a_xn := ins.pkg_amath.a_xn(par_values.age + par_t
                                  ,par_n - par_t
                                  ,sex_vh
                                  ,par_values.k_coef
                                  ,par_values.s_coef
                                  ,1
                                  ,par_values.deathrate_id
                                  ,par_values.fact_yield_rate);
      --
    
      SELECT SUM(p * s)
        INTO v_p_sum
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      v_p_sum := (v_p_sum + v_p * par_values.insurance_amount) / par_values.insurance_amount;
    
      SELECT SUM(p * s)
        INTO v_p_sum_re
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      v_p_sum_re := (v_p_sum_re + v_p_re * par_values.insurance_amount) / par_values.insurance_amount;
    
      res_reserve_value.tv_p := ROUND(v_axn - v_p * v_a_xn, 6);
      res_reserve_value.tv_f := res_reserve_value.tv_p;
    
      --
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * (1 - res_reserve_value.tv_p)
                                      ,10);
      res_reserve_value.tvz_f := res_reserve_value.tvz_p;
    
      v_axn_re  := ins.pkg_amath.axn(par_values.age + par_t
                                    ,par_n - par_t
                                    ,sex_vh
                                    ,par_values.k_coef_re
                                    ,par_values.s_coef_re
                                    ,par_values.deathrate_id
                                    ,par_values.fact_yield_rate);
      v_a_xn_re := ins.pkg_amath.a_xn(par_values.age + par_t
                                     ,par_n - par_t
                                     ,sex_vh
                                     ,par_values.k_coef_re
                                     ,par_values.s_coef_re
                                     ,1
                                     ,par_values.deathrate_id
                                     ,par_values.fact_yield_rate);
    
      res_reserve_value.tv_p_re := ROUND(v_axn_re - v_p_re * v_a_xn_re, 10);
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
      --
    
    END IF;
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.p := v_p;
    res_reserve_value.g := v_g;
  
    res_reserve_value.p_re := v_p_re;
    res_reserve_value.g_re := v_g_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
    --
    dbms_output.put_line(' v_Axn ' || v_axn);
    dbms_output.put(' v_a_xn ' || v_a_xn);
    --
    dbms_output.put_line(' tVexp_p =  ' || res_reserve_value.tvexp_p);
    dbms_output.put(' tVS_p =  ' || res_reserve_value.tvs_p);
    dbms_output.put(' tVZ_p =  ' || res_reserve_value.tvz_p);
    --
    dbms_output.put_line(' registry_id ' || res_reserve_value.reserve_id);
    dbms_output.put_line(' insurance_year_number ' || res_reserve_value.insurance_year_number);
    dbms_output.put_line(' insurance_year_date ' || res_reserve_value.insurance_year_date);
    dbms_output.put_line(' tV ' || res_reserve_value.tv_p);
    --
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(par_reserve_value_for_begin.tvz_p, 0) +
                                               res_reserve_value.tvz_p + v_p) / 2
                                              ,10));
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    dbms_output.put_line(' t(VB) ' || res_reserve_value.plan);
    --
    RETURN res_reserve_value;
  END;

  /*
    ����� �-��� calc_reserve_for_iv_01 �� � ����������� ��� FLA_2
  */
  FUNCTION calc_reserve_for_iv_01_fla
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ_plan NUMBER;
    v_i_summ_fact NUMBER;
    v_c1          NUMBER; -- �������� ����� ���������� + 1
    v_j1          NUMBER; -- ����������� ����� ���������� + 1
    v_q           NUMBER;
    v_p           NUMBER;
    v_g           NUMBER;
  
    v_p_re NUMBER;
    v_g_re NUMBER;
  
    v_axn  NUMBER;
    v_a_xn NUMBER;
  
    v_axn_re  NUMBER;
    v_a_xn_re NUMBER;
  
    v_lives                NUMBER(1); -- ��� �� ��������������
    v_i_temp               NUMBER;
    v_diff                 NUMBER;
    tspm_g_plan            NUMBER; -- ������������ tspm �� G
    tspm_g_fact            NUMBER; -- ������������ tspm �� G
    res_reserve_value      r_reserve_value%ROWTYPE;
    res_reserve_value_prev r_reserve_value%ROWTYPE;
    a                      NUMBER;
    one_payment            NUMBER(1);
    sex_vh                 VARCHAR2(2);
    ft                     NUMBER;
    v_az                   NUMBER;
  
    v_p_sum    NUMBER;
    v_p_sum_re NUMBER;
    v          NUMBER;
  BEGIN
  
    v_az := a_z(par_registry.policy_id, par_values.rvb_value);
  
    res_reserve_value.a_z := v_az;
  
    dbms_output.put_line('(calc_reserve_for_iv_01) az (f=' || par_values.rvb_value || ')' || v_az);
    --
    dbms_output.put_line(' ��������� ��� ' || par_t || '');
    dbms_output.put_line('�������� ����������� ������� :');
    dbms_output.put(' reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put(' insurance_year_number ' || par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put(' insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put(' tVZ_p ' || par_reserve_value_for_begin.tvz_p);
    dbms_output.put_line('');
    --
    a := 0.0025;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
  
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    dbms_output.put(lpad(' age ' || par_values.age, 10, ' '));
    dbms_output.put(lpad(' sex_vh ' || sex_vh, 10, ' '));
    dbms_output.put(lpad(' ���� ���-���(n) ' || par_n, 10, ' '));
    dbms_output.put(lpad(' ����� ���-��� ' || par_values.fact_yield_rate, 10, ' '));
    dbms_output.put(lpad(' �������� ' || par_values.rvb_value, 10, ' '));
    dbms_output.put(lpad(' ���. �����. ' || par_values.deathrate_id, 10, ' '));
    dbms_output.put_line(lpad(' ������� ������. ' || abs(sign(par_periodical - 1))
                             ,10
                             ,' '));
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
  
    --
    dbms_output.put_line(' v_P ' || v_p || ' v_G ' || v_g || 'par_periodical ' || par_periodical);
    -- � ���� ������ �� ����������
    /*    IF par_periodical = 0 THEN
          v_Axn := ins.pkg_amath.Axn(par_values.age + par_t
                                                , par_n - par_t
                                                , sex_vh
                                                , par_values.k_coef
                                                , par_values.s_coef
                                                , par_values.deathrate_id
                                                , par_values.fact_yield_rate);
          res_reserve_value.tV_p := ROUND (v_Axn, 10);
          res_reserve_value.tV_f := ROUND (v_Axn, 10);
    
          v_Axn_re := ins.pkg_amath.Axn(par_values.age + par_t
                                                , par_n - par_t
                                                , sex_vh
                                                , par_values.k_coef_re
                                                , par_values.s_coef_re
                                                , par_values.deathrate_id
                                                , par_values.fact_yield_rate);
    
          res_reserve_value.tV_p_re := ROUND (v_Axn_re, 10);
          res_reserve_value.tV_f_re := ROUND (v_Axn_re, 10);
    --
          v_a_xn := ROUND (ins.pkg_amath.a_xn (par_values.age + par_t
                                    , par_n - par_t
                                    , sex_vh
                                    , par_values.k_coef
                                    , par_values.s_coef
                                    , 1
                                    , par_values.deathrate_id
                                    , par_values.fact_yield_rate), 10);
    --
          res_reserve_value.tVexp_p := a * v_g * v_a_xn;
          res_reserve_value.tVexp_f := res_reserve_value.tVexp_p;
    --
          res_reserve_value.tVS_p := res_reserve_value.tV_p + res_reserve_value.tVexp_p;
          res_reserve_value.tVS_f := res_reserve_value.tVS_p;
        ELSE*/
    res_reserve_value.plan := 0;
  
    /*      v_Axn := ins.pkg_amath.Axn(par_values.age + par_t
    , par_n - par_t
    , sex_vh
    , par_values.k_coef
    , par_values.s_coef
    , par_values.deathrate_id
    , par_values.fact_yield_rate);*/
  
    dbms_output.put_line('������� ������ ��� a_xn ');
    dbms_output.put_line('������� ������ ��� a_xn x ' || (par_values.age + par_t));
    dbms_output.put_line('������� ������ ��� a_xn n ' || (par_n - par_t));
    dbms_output.put_line('������� ������ ��� a_xn sex ' || sex_vh);
    dbms_output.put_line('������� ������ ��� a_xn i ' || par_values.fact_yield_rate);
    dbms_output.put_line('������� ������ ��� a_xn k_coef ' || par_values.k_coef);
    dbms_output.put_line('������� ������ ��� a_xn s_coef ' || par_values.s_coef);
    dbms_output.put_line('������� ������ ��� a_xn table ' || par_values.deathrate_id);
  
    v_a_xn := ins.pkg_amath.a_xn(par_values.age + par_t
                                ,par_n - par_t
                                ,sex_vh
                                ,par_values.k_coef
                                ,par_values.s_coef
                                ,1
                                ,par_values.deathrate_id
                                ,par_values.fact_yield_rate);
    --
  
    SELECT SUM(p * s)
      INTO v_p_sum
      FROM reserve.r_reserve_value
     WHERE reserve_id = par_registry.id
       AND insurance_year_number < par_t
       AND insurance_year_number != 0;
    v_p_sum := (v_p_sum + v_p * par_values.insurance_amount) / par_values.insurance_amount;
  
    SELECT SUM(p * s)
      INTO v_p_sum_re
      FROM reserve.r_reserve_value
     WHERE reserve_id = par_registry.id
       AND insurance_year_number < par_t
       AND insurance_year_number != 0;
    v_p_sum_re := (v_p_sum_re + v_p_re * par_values.insurance_amount) / par_values.insurance_amount;
  
    v                      := 1 / (1 + par_values.fact_yield_rate);
    res_reserve_value.tv_p := ROUND(power(v, par_n - par_t) - v_p * v_a_xn, 6);
    res_reserve_value.tv_f := res_reserve_value.tv_p;
  
    --
    res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * (1 - res_reserve_value.tv_p), 10);
    res_reserve_value.tvz_f := res_reserve_value.tvz_p;
  
    v_axn_re  := ins.pkg_amath.axn(par_values.age + par_t
                                  ,par_n - par_t
                                  ,sex_vh
                                  ,par_values.k_coef_re
                                  ,par_values.s_coef_re
                                  ,par_values.deathrate_id
                                  ,par_values.fact_yield_rate);
    v_a_xn_re := ins.pkg_amath.a_xn(par_values.age + par_t
                                   ,par_n - par_t
                                   ,sex_vh
                                   ,par_values.k_coef_re
                                   ,par_values.s_coef_re
                                   ,1
                                   ,par_values.deathrate_id
                                   ,par_values.fact_yield_rate);
  
    res_reserve_value.tv_p_re := ROUND(v_axn_re - v_p_re * v_a_xn_re, 10);
    res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    --
  
    --END IF;
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.p := v_p;
    res_reserve_value.g := v_g;
  
    res_reserve_value.p_re := v_p_re;
    res_reserve_value.g_re := v_g_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
    --
    --DBMS_OUTPUT.PUT_LINE (' v_Axn '||v_Axn);
    dbms_output.put(' v_a_xn ' || v_a_xn);
    --
    dbms_output.put_line(' tVexp_p =  ' || res_reserve_value.tvexp_p);
    dbms_output.put(' tVS_p =  ' || res_reserve_value.tvs_p);
    dbms_output.put(' tVZ_p =  ' || res_reserve_value.tvz_p);
    --
    dbms_output.put_line(' registry_id ' || res_reserve_value.reserve_id);
    dbms_output.put_line(' insurance_year_number ' || res_reserve_value.insurance_year_number);
    dbms_output.put_line(' insurance_year_date ' || res_reserve_value.insurance_year_date);
    dbms_output.put_line(' tV ' || res_reserve_value.tv_p);
    --
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(par_reserve_value_for_begin.tvz_p, 0) +
                                               res_reserve_value.tvz_p + v_p) / 2
                                              ,10));
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    dbms_output.put_line(' t(VB) ' || res_reserve_value.plan);
    --
    RETURN res_reserve_value;
  END calc_reserve_for_iv_01_fla;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "������� � ������������ ������� � ������ ������.
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_02
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ NUMBER;
    v_c1     NUMBER; -- �������� ����� ���������� + 1
    v_q      NUMBER;
    v_a      NUMBER;
    v_p      NUMBER;
    v_g      NUMBER;
    v_g_sum  NUMBER;
    v_s      NUMBER;
    v_s_p    NUMBER;
  
    v_p_re     NUMBER;
    v_g_re     NUMBER;
    v_g_sum_re NUMBER;
  
    v_a1xn  NUMBER;
    v_ia1xn NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
    v_nex   NUMBER;
  
    v_a1xn_re  NUMBER;
    v_ia1xn_re NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
    v_nex_re   NUMBER;
  
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
    --
    one_payment NUMBER(1);
    sex_vh      VARCHAR2(2);
    --
    v_az NUMBER;
  
    v_tvz_p NUMBER;
  
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_FOR_IV_02';
  
    --    p_p_cover_id      NUMBER;
  BEGIN
  
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_c', par_trace_var_value => par_c);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_j', par_trace_var_value => par_j);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_b', par_trace_var_value => par_b);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_kom', par_trace_var_value => par_kom);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_s := par_values.insurance_amount;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
    --
    v_az                  := a_z(par_registry.policy_id, par_values.rvb_value);
    res_reserve_value.a_z := v_az;
  
    --
    v_tvz_p := par_reserve_value_for_begin.tvz_p;
    v_s_p   := par_reserve_value_for_begin.s;
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
    --
    v_a_xn  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    -- � ���� ������ �� ����������
  
    dbms_output.put_line('par_periodical ' || par_periodical || ' par_values.age + par_t ' ||
                         (par_values.age + par_t) || ' par_n - par_t ' || (par_n - par_t) ||
                         ' sex_vh ' || sex_vh || ' par_values.deathrate_id ' ||
                         par_values.deathrate_id || ' par_values.fact_yield_rate ' ||
                         par_values.fact_yield_rate || ' par_values.k_coef_re=' ||
                         par_values.k_coef_re || ' par_values.s_coef_re=' || par_values.s_coef_re);
    IF par_periodical = 0
    THEN
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ ��� ���������������� ��������');
      -- �������� ������� ����� ������
      -- todo ���������, �� �� ������� ������������?
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,10);
      v_nex  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                     ,10);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
      v_nex_re  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                        ,10);
    
      res_reserve_value.tv_p := ROUND(v_nex + v_g * v_a1xn, 10);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx', par_trace_var_value => v_nex);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn', par_trace_var_value => v_a1xn);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g', par_trace_var_value => v_g);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tV_p');
    
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_re * v_a1xn_re, 10);
    
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx_re', par_trace_var_value => v_nex_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn_re', par_trace_var_value => v_a1xn_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g_re', par_trace_var_value => v_g_re);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p_re'
                                ,par_trace_var_value => res_reserve_value.tv_p_re);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tV_p_re');
    
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvexp_p := ROUND(v_a * v_g * v_a_xn, 10);
    
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a', par_trace_var_value => v_a);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g', par_trace_var_value => v_g);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_xn', par_trace_var_value => v_a_xn);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tVexp_p'
                                ,par_trace_var_value => res_reserve_value.tvexp_p);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tVexp_p');
    
      res_reserve_value.tvs_p := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
    ELSE
      v_a1xn  := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef
                                         ,par_values.s_coef
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                      ,10);
      v_ia1xn := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef
                                          ,par_values.s_coef
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                      ,10);
      --
      v_nex := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,par_values.fact_yield_rate)
                    ,10);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
    
      v_ia1xn_re := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                             ,par_n - par_t
                                             ,sex_vh
                                             ,par_values.k_coef_re
                                             ,par_values.s_coef_re
                                             ,par_values.deathrate_id
                                             ,par_values.fact_yield_rate)
                         ,10);
      --
      v_nex_re := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef_re
                                         ,par_values.s_coef_re
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                       ,10);
    
      --      select 0.532866729 * 456557 from dual
    
      SELECT SUM(g * s)
        INTO v_g_sum
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      dbms_output.put_line(' v_g_sum (1)' || v_g_sum);
      IF par_t > 0
      THEN
        v_g_sum := (nvl(v_g_sum, 0) + v_g * v_s) / v_s;
        v_g_sum := nvl(v_g_sum, 0);
      ELSE
        v_g_sum := 0;
      END IF;
      dbms_output.put_line(' v_g_sum (2)' || v_g_sum);
    
      SELECT SUM(g * s)
        INTO v_g_sum_re
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      v_g_sum_re := (nvl(v_g_sum_re, 0) + v_g_re * par_values.insurance_amount) /
                    par_values.insurance_amount;
      v_g_sum_re := nvl(v_g_sum_re, 0);
    
      res_reserve_value.tv_p := ROUND(v_nex + v_g_sum * v_a1xn + v_g * v_ia1xn - v_p * v_a_xn, 10);
    
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx', par_trace_var_value => v_nex);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g_sum', par_trace_var_value => v_g_sum);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn', par_trace_var_value => v_a1xn);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g', par_trace_var_value => v_g);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_IA1xn', par_trace_var_value => v_ia1xn);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_p', par_trace_var_value => v_p);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_xn', par_trace_var_value => v_a_xn);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p'
                                ,par_trace_var_value => res_reserve_value.tv_p);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tV_p');
    
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_sum_re * v_a1xn_re + v_g_re * v_ia1xn_re -
                                         v_p_re * v_a_xn_re
                                        ,10);
    
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_S', par_trace_var_value => v_s);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx_re', par_trace_var_value => v_nex_re);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'v_g_sum_re'
                                ,par_trace_var_value => v_g_sum_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn_re', par_trace_var_value => v_a1xn_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_g_re', par_trace_var_value => v_g_re);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'v_IA1xn_re'
                                ,par_trace_var_value => v_ia1xn_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_p_re', par_trace_var_value => v_p_re);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_xn_re', par_trace_var_value => v_a_xn_re);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p_re'
                                ,par_trace_var_value => res_reserve_value.tv_p_re);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tV_p_re');
    
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * v_a_xn / v_a_x_n, 10);
    
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p'
                                ,par_trace_var_value => res_reserve_value.tv_p);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_az', par_trace_var_value => v_az);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_xn', par_trace_var_value => v_a_xn);
      ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_x_n', par_trace_var_value => v_a_x_n);
      ins.pkg_trace.add_variable(par_trace_var_name  => 'tVZ_p'
                                ,par_trace_var_value => res_reserve_value.tvz_p);
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => '������ tVZ_p');
    
    END IF;
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(v_tvz_p * v_s_p, 0) +
                                               res_reserve_value.tvz_p * v_s + v_p * v_s) / 2
                                              ,10));
      res_reserve_value.plan := ROUND(res_reserve_value.plan / v_s, 10);
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
  
    --
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "������� � ������������ ������� � ������ ������. ������� SF_AVCR
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_02sf
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ NUMBER;
    v_c1     NUMBER; -- �������� ����� ���������� + 1
    v_q      NUMBER;
    v_a      NUMBER;
    v_p      NUMBER;
    v_g      NUMBER;
    v_g_sum  NUMBER;
    v_s      NUMBER;
    v_s_p    NUMBER;
  
    v_p_re     NUMBER;
    v_g_re     NUMBER;
    v_g_sum_re NUMBER;
  
    v_a1xn  NUMBER;
    v_ia1xn NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
    v_a_x_m NUMBER;
    v_nex   NUMBER;
  
    v_a1xm   NUMBER;
    v_a1xmnm NUMBER;
    v_ia1xm  NUMBER;
    v_a_xm   NUMBER;
    v_mex    NUMBER;
  
    v_a1xn_re  NUMBER;
    v_ia1xn_re NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
    v_nex_re   NUMBER;
  
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
    --
    one_payment NUMBER(1);
    sex_vh      VARCHAR2(2);
    --
    v_az NUMBER;
  
    v_tvz_p           NUMBER;
    v_m               NUMBER; -- ���� ������ ������� in (5,10,15)
    v_fact_yield_rate NUMBER;
  BEGIN
    v_fact_yield_rate := 0.05; --Ƹ���� ������� ����� ����������
  
    SELECT p.fee_payment_term INTO v_m FROM ins.p_policy p WHERE p.policy_id = par_registry.policy_id;
  
    dbms_output.put_line('CALC_RESERVE_FOR_IV_02 ');
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_s := par_values.insurance_amount;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
    --
    v_az                  := a_z(par_registry.policy_id, par_values.rvb_value);
    res_reserve_value.a_z := v_az;
  
    --
    v_tvz_p := par_reserve_value_for_begin.tvz_p;
    v_s_p   := par_reserve_value_for_begin.s;
  
    dbms_output.put_line('��������� ��� ' || par_t || '');
    dbms_output.put_line('�������� ����������� ������� :');
    dbms_output.put_line('reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put_line('insurance_year_number ' ||
                         par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put_line('insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put_line('tVZ_p ' || v_tvz_p || ' S ' || v_s_p);
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
    --
    v_a_xn := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,1
                                      ,par_values.deathrate_id
                                      ,v_fact_yield_rate)
                   ,10);
  
    v_a_xm  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,v_m - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,v_fact_yield_rate)
                    ,10);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,v_fact_yield_rate)
                    ,10);
  
    v_a_x_m := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,v_m
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,v_fact_yield_rate)
                    ,10);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,v_fact_yield_rate)
                       ,10);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,v_fact_yield_rate)
                       ,10);
  
    dbms_output.put_line('par_periodical ' || par_periodical || ' par_values.age + par_t ' ||
                         (par_values.age + par_t) || ' par_n - par_t ' || (par_n - par_t) ||
                         ' sex_vh ' || sex_vh || ' par_values.deathrate_id ' ||
                         par_values.deathrate_id || ' par_values.fact_yield_rate ' ||
                         par_values.fact_yield_rate || ' par_values.k_coef_re=' ||
                         par_values.k_coef_re || ' par_values.s_coef_re=' || par_values.s_coef_re);
  
    v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,v_fact_yield_rate)
                   ,10);
  
    v_a1xm := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                      ,v_m - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,v_fact_yield_rate)
                   ,10);
  
    v_a1xmnm := ROUND(ins.pkg_amath.ax1n(par_values.age + v_m
                                        ,par_n - v_m
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,v_fact_yield_rate)
                     ,10);
  
    v_ia1xn := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,v_fact_yield_rate)
                    ,10);
  
    v_ia1xm := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                        ,v_m - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,v_fact_yield_rate)
                    ,10);
    --
    v_nex := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                    ,par_n - par_t
                                    ,sex_vh
                                    ,par_values.k_coef
                                    ,par_values.s_coef
                                    ,par_values.deathrate_id
                                    ,v_fact_yield_rate)
                  ,10);
  
    v_mex := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                    ,v_m - par_t
                                    ,sex_vh
                                    ,par_values.k_coef
                                    ,par_values.s_coef
                                    ,par_values.deathrate_id
                                    ,v_fact_yield_rate)
                  ,10);
    dbms_output.put_line('nEx ' || v_nex);
  
    v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef_re
                                         ,par_values.s_coef_re
                                         ,par_values.deathrate_id
                                         ,v_fact_yield_rate)
                      ,10);
  
    v_ia1xn_re := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,v_fact_yield_rate)
                       ,10);
  
    v_nex_re := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef_re
                                       ,par_values.s_coef_re
                                       ,par_values.deathrate_id
                                       ,v_fact_yield_rate)
                     ,10);
  
    SELECT SUM(g * s)
      INTO v_g_sum
      FROM reserve.r_reserve_value
     WHERE reserve_id = par_registry.id
       AND insurance_year_number < par_t
       AND insurance_year_number != 0;
  
    dbms_output.put_line(' v_g_sum (1)' || v_g_sum);
    IF par_t > 0
    THEN
      v_g_sum := (nvl(v_g_sum, 0) + v_g * v_s) / v_s;
      v_g_sum := nvl(v_g_sum, 0);
    ELSE
      v_g_sum := 0;
    END IF;
    dbms_output.put_line(' v_g_sum (2)' || v_g_sum);
  
    SELECT SUM(g * s)
      INTO v_g_sum_re
      FROM reserve.r_reserve_value
     WHERE reserve_id = par_registry.id
       AND insurance_year_number < par_t
       AND insurance_year_number != 0;
    v_g_sum_re := (nvl(v_g_sum_re, 0) + v_g_re * par_values.insurance_amount) /
                  par_values.insurance_amount;
    v_g_sum_re := nvl(v_g_sum_re, 0);
  
    IF par_t <= v_m
    THEN
      --������ ������ ������� t = 0:m
      --�����-������
      res_reserve_value.tv_p  := ROUND(v_nex + v_g_sum * v_a1xm + v_g * v_ia1xm +
                                       v_g * 2 * v_m * v_a1xmnm * v_mex - v_p * v_a_xm
                                      ,10);
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * v_a_xm / v_a_x_m, 10);
    ELSIF par_t > v_m
    THEN
      --����������� ������ t = m+1:par_n
      res_reserve_value.tv_p  := ROUND(v_nex + v_g * 2 * v_m * v_a1xn, 10);
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p + v_a * v_a_xn, 10);
    END IF;
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(v_tvz_p * v_s_p, 0) +
                                               res_reserve_value.tvz_p * v_s + v_p * v_s) / 2
                                              ,10));
      res_reserve_value.plan := ROUND(res_reserve_value.plan / v_s, 10);
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    dbms_output.put_line('tV= ' || v_nex * v_s || ' + ' || v_g_sum * v_a1xn * v_s || ' + ' ||
                         v_g * v_ia1xn * v_s || ' - ' || v_p * v_a_xn * v_s);
  
    res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_sum_re * v_a1xn_re + v_g_re * v_ia1xn_re -
                                       v_p_re * v_a_xn_re
                                      ,10);
    res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
  
    dbms_output.put_line(' par_n=' || par_n || ' par_t=' || par_t || ' v_nEx=' || v_nex || ' v_g=' || v_g ||
                         ' v_A1xn=' || v_a1xn || ' v_IA1xn=' || v_ia1xn || ' v_p=' || v_p ||
                         ' v_a_xn=' || v_a_xn || ' v_g_sum ' || v_g_sum);
    dbms_output.put_line(' tV_p ' || res_reserve_value.tv_p || ' a_z ' || v_az || ' v_a_xn ' ||
                         v_a_xn || ' v_a_x_n ' || v_a_x_n || ' tVZ_p' || res_reserve_value.tvz_p ||
                         ' t(VB) ' || res_reserve_value.plan);
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := v_fact_yield_rate; --par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := v_fact_yield_rate; --par_values.fact_yield_rate;
    --
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ �� ���� � �������� �����".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_03
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ          NUMBER;
    v_j_summ          NUMBER;
    v_nu              NUMBER;
    v_formula_item1   NUMBER; -- ������ ���������
    v_formula_item2   NUMBER; -- ������ ���������
    v_formula_item3   NUMBER; -- ������ ���������
    v_n               NUMBER; -- ���� �����������
    v_q               NUMBER; -- ����������� ������
    v_1c              NUMBER; -- (1+v_c)
    v_lives           NUMBER(1); -- ��� �� ��������������
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_formula_item1 := 0;
    v_formula_item2 := 0;
    v_formula_item3 := 0;
  
    v_n := par_n;
  
    v_1c := par_c + 1;
  
    v_lives := 1;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        res_reserve_value.plan := par_values.payment * (1 - const_f);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_nu     := 1 / (1 + par_c);
      v_i_summ := 0;
      v_q      := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        -- ������ ������� ����������
        -- todo ���� ��� ��������� �� ��������� �����
        FOR i IN 12 * par_t .. (12 * par_t + 11)
        LOOP
          v_j_summ := 0;
          FOR j IN 0 .. 12 * v_n - i - 1
          LOOP
            v_j_summ := v_j_summ + power(v_nu, j / 12);
          END LOOP; --for j
          v_i_summ := v_i_summ +
                      v_j_summ * power(v_nu, (i + 1) / 12 - par_t) *
                      (1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                 ,par_values.age + par_t - 1
                                                                 ,i / 12 - par_t)) * v_q;
        END LOOP; -- for i
        -- �������� �� ������� ��������� �����
        v_i_summ := v_i_summ * par_values.insurance_amount;
        dbms_output.put_line('v_i_summ = ' || v_i_summ);
        v_formula_item1 := (par_reserve_value_for_begin.plan - v_i_summ / 144) * (1 + par_c);
      
        dbms_output.put_line('v_formula_item1 = ' || v_formula_item1 / (1 - v_q));
        IF par_periodical = 1
        THEN
          -- ������ ������� ����������
          v_i_summ := 0;
          IF par_b <> 0
          THEN
            v_formula_item2 := par_b * par_values.payment * par_kom * -- todo ������� � �������� get_kom
                               par_values.periodicity;
            FOR i IN 1 .. par_values.periodicity
            LOOP
              v_i_summ := v_i_summ +
                          (1 -
                          pkg_reserve_life.get_death_portability(par_values.sex
                                                                 ,par_values.age + par_t - 1
                                                                 ,(i - 1) / par_values.periodicity)) *
                          power(v_1c, (i - 1) / par_values.periodicity);
            
            END LOOP;
            v_formula_item2 := v_formula_item2 * v_i_summ;
            dbms_output.put_line('v_formula_item2 = ' || v_formula_item2 / (1 - v_q));
          ELSE
            v_formula_item2 := 0;
          END IF;
        
          v_formula_item3 := get_tspm(par_values.payment * par_values.periodicity
                                     , -- todo ��� �����??
                                      par_c
                                     ,par_n
                                     ,par_values.periodicity
                                     ,par_b
                                     ,par_values.sex
                                     ,par_values.age
                                     ,par_values.has_additional) *
                             get_g_big(par_c
                                      ,par_values.payment_duration
                                      ,par_t
                                      ,par_values.age
                                      ,par_values.sex
                                      ,par_values.has_additional);
          dbms_output.put_line('v_formula_item3 = ' || v_formula_item3 / (1 - v_q));
        END IF; -- periodical
        res_reserve_value.plan := (v_formula_item1 - v_formula_item2 + v_formula_item3) / (1 - v_q);
      ELSE
        -- �������������� �� ����� �� ���� par_t
        -- todo ��������� �� ���???
        FOR j IN 0 .. 12 * (v_n - par_t)
        LOOP
          v_j_summ := v_j_summ + power(v_nu, j / 12);
        END LOOP;
        v_j_summ               := v_j_summ / 12;
        res_reserve_value.plan := v_j_summ * par_values.insurance_amount;
      END IF; -- lives
    END IF; -- pat_t <= 0
    -- ��������� ����� ��� ������������� � �������������� ��������
    -- ����� ����������
    res_reserve_value.c    := par_c;
    res_reserve_value.j    := res_reserve_value.c;
    res_reserve_value.fact := res_reserve_value.plan;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� �� �� �������� ������� ���  �������� �����������
  * <br> "����������� �� �������".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_04
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ_plan     NUMBER;
    v_i_summ_fact     NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_j1              NUMBER; -- ����������� ����� ���������� + 1
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g_plan       NUMBER; -- ������������ tspm �� G
    tspm_g_fact       NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        res_reserve_value.plan := par_values.payment * (1 - const_f);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_i_summ_plan := 0;
      v_i_summ_fact := 0;
      v_c1          := par_c + 1;
      v_j1          := par_j + 1;
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        res_reserve_value.plan := par_reserve_value_for_begin.plan * v_c1;
        res_reserve_value.fact := par_reserve_value_for_begin.fact * v_j1;
      
        IF par_periodical = 1
        THEN
        
          FOR i IN 1 .. par_values.periodicity
          LOOP
            v_i_temp      := (i - 1) / par_values.periodicity;
            v_p           := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                       ,par_values.age + par_t - 1
                                                                       ,v_i_temp);
            v_i_summ_plan := v_i_summ_plan + power(v_c1, v_i_temp) * v_p;
            v_i_summ_fact := v_i_summ_fact + power(v_j1, v_i_temp) * v_p;
          END LOOP; -- for i
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ_plan;
          res_reserve_value.fact := res_reserve_value.fact -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ_fact;
        
          tspm_g_plan := get_tspm(par_values.payment * par_values.periodicity
                                 ,par_c
                                 ,par_n
                                 ,par_values.periodicity
                                 ,par_b
                                 ,par_values.sex
                                 ,par_values.age
                                 ,par_values.has_additional) *
                         get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          tspm_g_fact := get_tspm(par_values.payment * par_values.periodicity
                                 ,par_j
                                 ,par_n
                                 ,par_values.periodicity
                                 ,par_b
                                 ,par_values.sex
                                 ,par_values.age
                                 ,par_values.has_additional) *
                         get_g(par_j, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          res_reserve_value.plan := res_reserve_value.plan + tspm_g_plan;
          res_reserve_value.fact := res_reserve_value.fact + tspm_g_fact;
        
        END IF; -- periodical
        v_q                    := pkg_reserve_life.get_death_portability(par_values.sex
                                                                        ,par_values.age + par_t - 1);
        res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
        res_reserve_value.fact := res_reserve_value.fact / (1 - v_q);
      ELSE
        -- �������������� �� ����� �� ���� par_t
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_01'
                              ,'�������������� �� ����� �� ���������� ���� � ' || par_t);
      END IF; -- lives
    END IF; -- pat_t <= 0
  
    res_reserve_value.c := par_c;
    res_reserve_value.j := par_j;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "����������� ����� � ������������� ������ ������� ���������� �����������".
  * <br> ����������� �������� ������������ � �������������� �������� ���
  * <br> ����� � ������� ��������������. ������� ����������� ����� ����
  * <br> ����������� ������ � ��������� � ������������� ��������.
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_05
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ_plan     NUMBER;
    v_i_summ_fact     NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_j1              NUMBER; -- ����������� ����� ���������� + 1
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    v_diff            NUMBER;
    v_ui              NUMBER;
    v_nu_plan         NUMBER;
    v_nu_fact         NUMBER;
    tspm_g_plan       NUMBER; -- ������������ tspm �� G
    tspm_g_fact       NUMBER; -- ������������ tspm �� G
    v_z               NUMBER;
    res_reserve_value r_reserve_value%ROWTYPE;
    invalid_periodical EXCEPTION;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
  
    IF par_periodical = 0
    THEN
      pkg_reserve_life.error(pkg_name
                            ,'calc_reserve_for_iv_05'
                            ,'������� "����������� ' ||
                             '����� � ������������� ������ ������� ���������� �����������" ' ||
                             '�� ����� ���� ����������� ��� �������� � �������������� �������.');
    END IF;
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := 0;
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_z     := pkg_reserve_life.get_insurance_year_number(par_start_date, par_values.death_date);
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_i_summ_plan := 0;
      v_i_summ_fact := 0;
      v_c1          := par_c + 1;
      v_j1          := par_j + 1;
      v_nu_plan     := 1 / (v_c1);
      v_nu_fact     := 1 / (v_j1);
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        res_reserve_value.plan := par_reserve_value_for_begin.plan * (1 + v_c1);
        res_reserve_value.fact := par_reserve_value_for_begin.fact * (1 + v_j1);
      
        FOR i IN 1 .. par_values.periodicity
        LOOP
          v_i_temp      := (i - 1) / par_values.periodicity;
          v_p           := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                     ,par_values.age + par_t - 1
                                                                     ,v_i_temp);
          v_i_summ_plan := v_i_summ_plan + power(v_c1, v_i_temp);
          v_i_summ_fact := v_i_summ_fact + power(v_j1, v_i_temp);
        END LOOP; -- for i
      
        res_reserve_value.plan := res_reserve_value.plan -
                                  par_b * par_values.payment * par_values.periodicity * par_kom *
                                  v_i_summ_plan;
        res_reserve_value.fact := res_reserve_value.fact -
                                  par_b * par_values.payment * par_values.periodicity * par_kom *
                                  v_i_summ_fact;
      
        tspm_g_plan := get_tspm(par_values.payment * par_values.periodicity
                               , -- todo ��� �����??
                                par_c
                               ,par_n
                               ,par_values.periodicity
                               ,par_b
                               ,par_values.sex
                               ,par_values.age
                               ,par_values.has_additional) *
                       get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
      
        tspm_g_fact := get_tspm(par_values.payment * par_values.periodicity
                               , -- todo ��� �����??
                                par_j
                               ,par_n
                               ,par_values.periodicity
                               ,par_b
                               ,par_values.sex
                               ,par_values.age
                               ,par_values.has_additional) *
                       get_g(par_j, par_t, par_values.age, par_values.sex, par_values.has_additional);
      
        res_reserve_value.plan := res_reserve_value.plan + tspm_g_plan;
        res_reserve_value.fact := res_reserve_value.fact + tspm_g_fact;
      
        v_diff := par_reserve_value_for_begin.fact - par_reserve_value_for_begin.plan;
      
        v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age, par_t - 1);
      
        v_ui := v_q * power(v_nu_fact, par_n - par_t + 1) * (par_j - par_c) / (1 - v_q);
      
        v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
      
        res_reserve_value.plan := res_reserve_value.plan -
                                  par_values.insurance_amount * v_q * power(v_nu_plan, par_n - par_t);
      
        res_reserve_value.fact := res_reserve_value.fact + par_values.insurance_amount * v_ui -
                                  v_q * (par_values.insurance_amount * power(v_nu_fact, par_n - par_t) +
                                  v_diff * v_j1);
      
        res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
        res_reserve_value.fact := res_reserve_value.fact / (1 - v_q);
      
      ELSE
        -- �������������� �� ����� �� ���� par_t
        v_i_summ_plan := 0;
        v_i_summ_fact := 0;
        FOR i IN v_z .. par_t
        LOOP
          v_i_summ_plan := v_i_summ_plan * v_c1;
          v_i_summ_fact := v_i_summ_fact * v_j1;
        END LOOP;
        res_reserve_value.plan := par_values.insurance_amount * power(v_nu_plan, par_n - par_t);
        res_reserve_value.fact := par_values.insurance_amount *
                                  (power(v_nu_plan, par_n - par_t) + v_diff * v_i_summ_fact);
      END IF; -- lives
    END IF; -- pat_t <= 0
  
    res_reserve_value.c := par_c;
    res_reserve_value.j := par_j;
    RETURN res_reserve_value;
  END;

  -- todo ���������!!! v_a � ������ ��� ������� ������� �����.
  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "����������� ��������� �����".
  * <br> ����������� �������� ������������ � �������������� �������� ���
  * <br> ����� � ������� �������������� �� ����� ������ ������� �
  * <br> �� ����� ������� ������� �����.
  * <p> ������� ����������� ����� ����
  * <br> ����������� ������ � ��������� � ������������� ��������.
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_06
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ_plan     NUMBER;
    v_i_summ_fact     NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_j1              NUMBER; -- ����������� ����� ���������� + 1
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    v_diff            NUMBER;
    v_ui              NUMBER;
    v_nu_plan         NUMBER;
    v_nu_fact         NUMBER;
    tspm_g_plan       NUMBER; -- ������������ tspm �� G
    tspm_g_fact       NUMBER; -- ������������ tspm �� G
    v_z               NUMBER;
    v_a               NUMBER;
    res_reserve_value r_reserve_value%ROWTYPE;
    invalid_periodical EXCEPTION;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
    v_a     := 1; -- todo ����� ���������� ��� ���������
    -- �� ����� ������� �����
    IF (par_t >= par_n + 1)
       AND (par_t < par_n + par_values.rent_duration)
    THEN
      v_j1                   := par_j + 1;
      res_reserve_value.fact := (par_reserve_value_for_begin.fact - v_a * par_values.rent_payment) * v_j1;
      res_reserve_value.plan := res_reserve_value.fact;
    ELSE
    
      IF par_periodical = 0
      THEN
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_05'
                              ,'������� "����������� ' || '��������� �����" ' ||
                               '�� ����� ���� ����������� ��� �������� � �������������� �������.');
      END IF;
      -- ���� �� ������ ������� ���������� ����
      IF par_t <= 0
      THEN
        res_reserve_value.plan := 0;
        res_reserve_value.fact := 0;
      ELSE
        -- ���� ��������� ��� �� ������
      
        -- ��� �� �������������� �� ���� ������ ���� par_t
        IF par_values.death_date IS NOT NULL
        THEN
          IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
          THEN
            v_z     := pkg_reserve_life.get_insurance_year_number(par_start_date
                                                                 ,par_values.death_date);
            v_lives := 0;
          END IF;
        END IF;
      
        -- ������������� �������
        v_i_summ_plan := 0;
        v_i_summ_fact := 0;
        v_c1          := par_c + 1;
        v_j1          := par_j + 1;
        v_nu_plan     := 1 / (v_c1);
        v_nu_fact     := 1 / (v_j1);
      
        IF v_lives = 1
        THEN
          -- �������������� ���
          res_reserve_value.plan := par_reserve_value_for_begin.plan * (1 + v_c1);
          res_reserve_value.fact := par_reserve_value_for_begin.fact * (1 + v_j1);
        
          FOR i IN 1 .. par_values.periodicity
          LOOP
            v_i_temp      := (i - 1) / par_values.periodicity;
            v_p           := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                       ,par_values.age + par_t - 1
                                                                       ,v_i_temp);
            v_i_summ_plan := v_i_summ_plan + power(v_c1, v_i_temp);
            v_i_summ_fact := v_i_summ_fact + power(v_j1, v_i_temp);
          END LOOP; -- for i
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ_plan;
          res_reserve_value.fact := res_reserve_value.fact -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ_fact;
        
          tspm_g_plan := get_tspm(par_values.payment * par_values.periodicity
                                 ,par_c
                                 ,par_n
                                 ,par_values.periodicity
                                 ,par_b
                                 ,par_values.sex
                                 ,par_values.age
                                 ,par_values.has_additional) *
                         get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          tspm_g_fact := get_tspm(par_values.payment * par_values.periodicity
                                 ,par_j
                                 ,par_n
                                 ,par_values.periodicity
                                 ,par_b
                                 ,par_values.sex
                                 ,par_values.age
                                 ,par_values.has_additional) *
                         get_g(par_j, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          res_reserve_value.plan := res_reserve_value.plan + tspm_g_plan;
          res_reserve_value.fact := res_reserve_value.fact + tspm_g_fact;
        
          v_diff := par_reserve_value_for_begin.fact - par_reserve_value_for_begin.plan;
        
          v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age, par_t - 1);
        
          v_ui := v_q * v_a * power(v_nu_fact, par_n - par_t + 1) * (par_j - par_c) / (1 - v_q);
        
          v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
        
          res_reserve_value.plan := res_reserve_value.plan - par_values.insurance_amount * v_q *
                                    power(v_nu_plan, par_n - par_t);
        
          res_reserve_value.fact := res_reserve_value.fact + par_values.insurance_amount * v_ui -
                                    v_q * (par_values.insurance_amount * v_a *
                                    power(v_nu_fact, par_n - par_t) + v_diff * v_j1);
        
          res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
          res_reserve_value.fact := res_reserve_value.fact / (1 - v_q);
        
        ELSE
          -- �������������� �� ����� �� ���� par_t
          v_i_summ_plan := 0;
          v_i_summ_fact := 0;
          FOR i IN v_z .. par_t
          LOOP
            v_i_summ_plan := v_i_summ_plan * v_c1;
            v_i_summ_fact := v_i_summ_fact * v_j1;
          END LOOP;
          res_reserve_value.plan := par_values.insurance_amount * power(v_nu_plan, par_n - par_t);
          res_reserve_value.fact := par_values.insurance_amount *
                                    (power(v_nu_plan, par_n - par_t) + v_diff * v_i_summ_fact);
        END IF; -- lives
      END IF; -- pat_t <= 0
    END IF; -- �� ����� ������� �����
  
    res_reserve_value.c := par_c;
    res_reserve_value.j := par_j;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "��������� ����������� �����".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_07
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ          NUMBER;
    v_j_summ          NUMBER;
    v_nu              NUMBER;
    v_formula_item1   NUMBER; -- ������ ���������
    v_formula_item2   NUMBER; -- ������ ���������
    v_formula_item3   NUMBER; -- ������ ���������
    v_n               NUMBER; -- ���� �����������
    v_q               NUMBER; -- ����������� ������
    v_1c              NUMBER; -- (1+v_c)
    v_lives           NUMBER(1); -- ��� �� ��������������
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_formula_item1 := 0;
    v_formula_item2 := 0;
    v_formula_item3 := 0;
  
    v_n := par_n;
  
    v_1c := par_c + 1;
  
    v_lives := 1;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        res_reserve_value.plan := par_values.payment * (1 - const_f);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_nu     := 1 / (1 + par_c);
      v_i_summ := 0;
      v_q      := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        -- ������ ������� ����������
        -- todo ���� ��� ��������� �� ��������� �����
        FOR i IN par_t * par_values.rent_periodicity .. (par_t + 1) * par_values.rent_periodicity - 1
        LOOP
          v_i_summ := v_i_summ +
                      (1 - i / (par_values.rent_periodicity * par_n)) *
                      power(v_nu, (i + 1) / par_values.rent_periodicity - par_t) *
                      (1 -
                      pkg_reserve_life.get_death_portability(par_values.sex
                                                             ,par_values.age + par_t - 1
                                                             ,i / par_values.rent_periodicity - par_t)) * v_q;
        END LOOP; -- for i
        -- �������� �� ������� ��������� �����
        v_i_summ := v_i_summ * par_values.insurance_amount;
      
        v_formula_item1 := (par_reserve_value_for_begin.plan -
                           v_i_summ * par_c / (ln(v_1c) * par_values.rent_periodicity)) * (v_1c);
      
        IF par_periodical = 1
        THEN
          -- ������ ������� ����������
          v_i_summ := 0;
          IF par_b <> 0
          THEN
            v_formula_item2 := par_b * par_values.payment * par_kom * -- todo ������� � �������� get_kom
                               par_values.periodicity;
            FOR i IN 1 .. par_values.periodicity
            LOOP
              v_i_summ := v_i_summ +
                          (1 -
                          pkg_reserve_life.get_death_portability(par_values.sex
                                                                 ,par_values.age + par_t - 1
                                                                 ,(i - 1) / par_values.periodicity)) *
                          power(v_1c, (i - 1) / par_values.periodicity);
            
            END LOOP;
            v_formula_item2 := v_formula_item2 * v_i_summ;
          
          ELSE
            v_formula_item2 := 0;
          END IF;
        
          v_formula_item3 := get_tspm(par_values.payment * par_values.periodicity
                                     , -- todo ��� �����??
                                      par_c
                                     ,par_n
                                     ,par_values.periodicity
                                     ,par_b
                                     ,par_values.sex
                                     ,par_values.age
                                     ,par_values.has_additional) *
                             get_g_big(par_c
                                      ,par_values.payment_duration
                                      ,par_t
                                      ,par_values.age
                                      ,par_values.sex
                                      ,par_values.has_additional);
        
        END IF; -- periodical
        res_reserve_value.plan := (v_formula_item1 - v_formula_item2 + v_formula_item3) / (1 - v_q);
      ELSE
        -- �������������� �� ����� �� ���� par_t
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_07'
                              ,'�������������� �� ����� �� ���������� ���� �' || par_t);
      END IF; -- lives
    END IF; -- pat_t <= 0
    -- ��������� ����� ��� ������������� � �������������� ��������
    -- ����� ����������
    res_reserve_value.c    := par_c;
    res_reserve_value.j    := res_reserve_value.c;
    res_reserve_value.fact := res_reserve_value.plan;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "����������� �� ������ ������ �� ����������� ������".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_08
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ          NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        -- todo ���������, �� �� ������� ������������?
        res_reserve_value.plan :=  /*0.4 * */
         par_values.insurance_amount *
                                  get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_i_summ := 0;
      v_c1     := par_c + 1;
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        IF par_periodical = 0
        THEN
          -- ��� �������������� ������
          res_reserve_value.plan := get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
        ELSE
          -- ��� ������������ ������
          res_reserve_value.plan := par_reserve_value_for_begin.plan * (1 + v_c1);
        
          FOR i IN 1 .. par_values.periodicity
          LOOP
            v_i_temp := (i - 1) / par_values.periodicity;
            v_p      := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                  ,par_values.age + par_t - 1
                                                                  ,v_i_temp);
            v_i_summ := v_i_summ + power(v_c1, v_i_temp);
          END LOOP; -- for i
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ;
        
          tspm_g := get_tspm(par_values.payment * par_values.periodicity
                            , -- todo ��� �����??
                             par_c
                            ,par_n
                            ,par_values.periodicity
                            ,par_b
                            ,par_values.sex
                            ,par_values.age
                            ,par_values.has_additional) *
                    get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          res_reserve_value.plan := res_reserve_value.plan + tspm_g;
        
          v_q                    := pkg_reserve_life.get_death_portability(par_values.sex
                                                                          ,par_values.age + par_t - 1);
          res_reserve_value.plan := res_reserve_value.plan -
                                    (par_values.insurance_amount * v_q * par_c) / ln(v_c1);
          res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
        END IF; -- periodical
      
      ELSE
        -- �������������� �� ����� �� ���� par_t
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_08'
                              ,'�������������� �� ����� �� ���������� ���� � ' || par_t);
      END IF; -- lives
    END IF; -- pat_t <= 0
    -- � ��� �������� ������������ ������ �������� ����� ����������
    res_reserve_value.c := par_c;
    res_reserve_value.j := res_reserve_value.c;
    -- todo ��������� ��������, ���������, ������ ���������� �����. �����
    IF res_reserve_value.plan < 0
    THEN
      res_reserve_value.plan := -res_reserve_value.plan;
    END IF;
    res_reserve_value.fact := res_reserve_value.plan;
  
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� ��������� �����������
  * <br> "����������� �� ������ ������������ ������������ � ����������
  * <br> ����������� ������", "����������� �� ������ ��������� ������
  * <br> ����������������" � "����������� �� ������ ��������� ������
  * <br> � ���������� ����������� ������". ���������� ������������
  * <br> �������������� ����������� par_tns.
  * <br> �������� ��������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_09_10_11
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
   ,par_tns                     IN NUMBER DEFAULT 0.02
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ          NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        -- todo ���������, �� �� ������� ������������?
        res_reserve_value.plan := par_tns * par_values.insurance_amount *
                                  get_a(par_c
                                       ,par_n - par_t
                                       ,par_values.age + par_t
                                       ,par_values.sex
                                       ,par_values.has_additional);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_i_summ := 0;
      v_c1     := par_c + 1;
    
      IF v_lives = 1
      THEN
        -- �������������� ���
        IF par_periodical = 0
        THEN
          -- ��� �������������� ������
          res_reserve_value.plan := get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
        ELSE
          -- ��� ������������ ������
          res_reserve_value.plan := par_reserve_value_for_begin.plan * (1 + v_c1);
        
          FOR i IN 1 .. par_values.periodicity
          LOOP
            v_i_temp := (i - 1) / par_values.periodicity;
            v_p      := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                  ,par_values.age + par_t - 1
                                                                  ,v_i_temp);
            v_i_summ := v_i_summ + power(v_c1, v_i_temp);
          END LOOP; -- for i
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    par_b * par_values.payment * par_values.periodicity * par_kom *
                                    v_i_summ;
        
          tspm_g := (get_tspm(par_values.payment * par_values.periodicity
                             , -- todo ��� �����??
                              par_c
                             ,par_n
                             ,par_values.periodicity
                             ,par_b
                             ,par_values.sex
                             ,par_values.age
                             ,par_values.has_additional) - par_tns * par_values.insurance_amount) *
                    get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          res_reserve_value.plan := res_reserve_value.plan + tspm_g;
        
          v_q := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
        
          res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
        END IF; -- periodical
      
      ELSE
        -- �������������� �� ����� �� ���� par_t
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_01'
                              ,'�������������� �� ����� �� ���������� ���� � ' || par_t);
      END IF; -- lives
    END IF; -- pat_t <= 0
    -- � ��� �������� ������������ ������ �������� ����� ����������
    res_reserve_value.c    := par_c;
    res_reserve_value.j    := res_reserve_value.c;
    res_reserve_value.fact := res_reserve_value.plan;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� ��������� �����������
  * <br> "C���������� �� ������ ������������ ������������ -
  * <br> ������������ �� ������ ���������� �������". ���� ������� �������� ��
  * <br> ��������������, � ������ �� ���� �� ��������������. ��� ������� - ��������.
  * <br> ������ �� ��������������� �������� ������ ����� ����.
  * <br> �������� ��������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_12
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    res_reserve_value r_reserve_value%ROWTYPE;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
    res_reserve_value.c    := par_c;
    res_reserve_value.j    := par_j;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "������� ������� � ������ ������".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_13
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ          NUMBER;
    v_c1              NUMBER; -- �������� ����� ���������� + 1
    v_dlt             NUMBER; -- ln(1 + par_c)
    v_q               NUMBER;
    v_p               NUMBER;
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    v_gpm             NUMBER; -- ������������ ����� �� ������� ��������
    v_gpm_base        NUMBER; -- ����� ������� �� ��������� ��������� � ��������
    v_gam             NUMBER; -- �����, ��������� ������ �� ��������, � ����� ������� �� ��������� ���������
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
    e_except EXCEPTION;
  BEGIN
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_lives := 1;
  
    v_gpm      := nvl(par_values.payment, 0);
    v_gpm_base := nvl(par_values.payment_base, 0);
    IF v_gpm_base IS NULL
    THEN
      pkg_reserve_life.error(pkg_name
                            ,'calc_reserve_for_iv_13'
                            ,'����� ������� �� ��������� ��������� ����� ����');
      RAISE e_except;
    END IF;
  
    v_gam := v_gpm / v_gpm_base;
  
    -- ���� �� ������ ������� ���������� ����
    IF par_t <= 0
    THEN
      -- � ���� ������ �� ����������
      IF par_periodical = 0
      THEN
        -- �������� ������� ����� ������
        -- todo ���������, �� �� ������� ������������?
        res_reserve_value.plan := v_gpm * (1 - const_f);
      ELSE
        res_reserve_value.plan := 0;
      END IF;
      res_reserve_value.fact := res_reserve_value.plan;
    
    ELSE
      -- ���� ��������� ��� �� ������
    
      -- ��� �� �������������� �� ���� ������ ���� par_t
      IF par_values.death_date IS NOT NULL
      THEN
        IF MONTHS_BETWEEN(par_values.death_date, ADD_MONTHS(par_start_date, (par_t - 1) * 12)) < 0
        THEN
          v_lives := 0;
        END IF;
      END IF;
    
      -- ������������� �������
      v_i_summ := 0;
      v_c1     := par_c + 1;
      v_dlt    := ln(v_c1);
      v_q      := pkg_reserve_life.get_death_portability(par_values.sex, par_values.age + par_t - 1);
    
      IF v_lives = 1
      THEN
        res_reserve_value.plan := par_reserve_value_for_begin.plan * (1 + v_c1);
        res_reserve_value.plan := res_reserve_value.plan - (v_gpm + v_gpm_base) * v_q * par_c / v_dlt;
        -- �������������� ���
        IF par_periodical = 0
        THEN
          -- ��� �������������� ������
          res_reserve_value.plan := get_a_big_1(par_c, par_n, par_values.age, par_values.sex);
        ELSE
          -- ��� ������������ ������
          FOR i IN 1 .. par_values.periodicity
          LOOP
            v_i_temp := (i - 1) / par_values.periodicity;
            v_p      := 1 - pkg_reserve_life.get_death_portability(par_values.sex
                                                                  ,par_values.age + par_t - 1
                                                                  ,v_i_temp);
            v_i_summ := v_i_summ + power(v_c1, v_i_temp);
          END LOOP; -- for i
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    par_b * v_gpm * par_values.periodicity * par_kom * v_i_summ;
        
          tspm_g := get_tspm(v_gpm * par_values.periodicity
                            , -- todo ��� �����??
                             par_c
                            ,par_n
                            ,par_values.periodicity
                            ,par_b
                            ,par_values.sex
                            ,par_values.age
                            ,par_values.has_additional) *
                    get_g(par_c, par_t, par_values.age, par_values.sex, par_values.has_additional);
        
          res_reserve_value.plan := res_reserve_value.plan + tspm_g;
        
          res_reserve_value.plan := res_reserve_value.plan -
                                    (v_gpm + v_gpm_base) * v_q *
                                    ((par_t - 1) * par_c / v_dlt + (par_c - v_dlt / (v_dlt * v_dlt)));
        
          res_reserve_value.plan := res_reserve_value.plan / (1 - v_q);
        END IF; -- periodical
      
      ELSE
        -- �������������� �� ����� �� ���� par_t
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv_13'
                              ,'�������������� �� ����� �� ���������� ���� � ' || par_t);
      END IF; -- lives
    END IF; -- pat_t <= 0
    -- � ��� �������� ������������ ������ �������� ����� ����������
    res_reserve_value.c    := par_c;
    res_reserve_value.j    := res_reserve_value.c;
    res_reserve_value.fact := res_reserve_value.plan;
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "��������� ���������������� ���������� �������� �����������".
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_15
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_q NUMBER;
    v_a NUMBER;
  
    v_p NUMBER;
    v_g NUMBER;
  
    v_p_re NUMBER;
    v_g_re NUMBER;
  
    v_a1xn  NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
  
    v_a1xn_re  NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
  
    res_reserve_value r_reserve_value%ROWTYPE;
    --
    one_payment NUMBER(1);
    sex_vh      VARCHAR2(2);
    --
    v_az NUMBER;
    FUNCTION b RETURN NUMBER IS
      RESULT NUMBER;
    BEGIN
      IF par_values.rvb_value = 0.3
      THEN
        RESULT := least(par_n * 6, 120);
      ELSIF par_values.rvb_value IN (0.02, 0.03, 0.05, 0.07)
      THEN
        RESULT := least(par_n * 1, 28);
      ELSE
        RESULT := least(par_n * 1, 28);
      END IF;
      RETURN RESULT / 100;
    END;
  
  BEGIN
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
    --
    v_az                  := a_z(par_registry.policy_id, par_values.rvb_value);
    res_reserve_value.a_z := v_az;
  
    dbms_output.put_line('(calc_reserve_for_iv_15) az (f=' || par_values.rvb_value || ')' || v_az);
    --
    dbms_output.put_line(' ��������� ��� ' || par_t || '');
    dbms_output.put_line(' �������� ����������� ������� :');
    dbms_output.put(' reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put(' insurance_year_number ' || par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put(' insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put_line(' tVZ_p ' || par_reserve_value_for_begin.tvz_p);
    dbms_output.put_line('');
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
    --
    v_a_xn  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,6);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,6);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef
                                          ,par_values.s_coef
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,6);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,6);
  
    -- � ���� ������ �� ����������
    IF par_periodical = 0
    THEN
      -- �������� ������� ����� ������
      -- todo ���������, �� �� ������� ������������?
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,6);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,6);
    
      res_reserve_value.tv_p := ROUND(v_a1xn, 6);
    
      res_reserve_value.tv_p_re := ROUND(v_a1xn_re, 6);
    
      res_reserve_value.tvexp_p := ROUND(v_a * v_g * v_a_xn, 6);
      res_reserve_value.tvs_p   := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
    ELSE
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,6);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,6);
    
      res_reserve_value.tv_p := ROUND(v_a1xn - v_p * v_a_xn, 6);
    
      res_reserve_value.tv_p_re := ROUND(v_a1xn_re - v_p_re * v_a_xn_re, 6);
    
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - b * v_g * (v_a_xn / v_a_x_n), 6);
    
    END IF;
  
    dbms_output.put_line(' par_n=' || par_n || ' par_t=' || par_t || ' v_g=' || v_g || ' v_A1xn=' ||
                         v_a1xn || ' v_p=' || v_p || ' v_a_xn=' || v_a_xn);
    dbms_output.put_line(' tV_p ' || res_reserve_value.tv_p);
    dbms_output.put_line(' a_z ' || v_az || ' v_a_xn ' || v_a_xn || ' v_a_x_n ' || v_a_x_n ||
                         ' tVZ_p' || res_reserve_value.tvz_p);
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(par_reserve_value_for_begin.tvz_p, 0) +
                                               res_reserve_value.tvz_p + v_p) / 2
                                              ,6));
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
    --
    dbms_output.put_line(' t(VB) ' || res_reserve_value.plan);
    --
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
    --
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "������� � ������������ ������� � ������ ������.
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_16
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
   ,const_tarrif                IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ NUMBER;
    v_c1     NUMBER; -- �������� ����� ���������� + 1
    v_q      NUMBER;
    v_a      NUMBER;
    v_p      NUMBER;
    v_g      NUMBER;
    v_g_sum  NUMBER;
    v_s      NUMBER;
    v_s_p    NUMBER;
  
    v_p_re     NUMBER;
    v_g_re     NUMBER;
    v_g_sum_re NUMBER;
  
    v_a1xn  NUMBER;
    v_ia1xn NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
    v_nex   NUMBER;
  
    v_a1xn_re  NUMBER;
    v_ia1xn_re NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
    v_nex_re   NUMBER;
  
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
    --
    one_payment NUMBER(1);
    sex_vh      VARCHAR2(2);
    --
    v_az NUMBER;
  
    v_tvz_p      NUMBER;
    p_p_cover_id NUMBER;
    v_fee        NUMBER;
  
    v_product_brief ins.t_product.brief%TYPE;
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_FOR_IV_16';
  BEGIN
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_c', par_trace_var_value => par_c);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_j', par_trace_var_value => par_j);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_b', par_trace_var_value => par_b);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_kom', par_trace_var_value => par_kom);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    dbms_output.put_line('CALC_RESERVE_FOR_IV_16 ');
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
    res_reserve_value.fee  := par_values.ins_premium;
  
    v_s := par_values.insurance_amount;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
    --
    v_az                  := a_z(par_registry.policy_id, par_values.rvb_value);
    res_reserve_value.a_z := v_az;
  
    --
    v_tvz_p := par_reserve_value_for_begin.tvz_p;
    v_s_p   := par_reserve_value_for_begin.s;
  
    dbms_output.put_line('��������� ��� ' || par_t || '');
    dbms_output.put_line('�������� ����������� ������� :');
    dbms_output.put_line('reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put_line('insurance_year_number ' ||
                         par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put_line('insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put_line('tVZ_p ' || v_tvz_p || ' S ' || v_s_p);
  
    BEGIN
      SELECT pc.p_cover_id
        INTO p_p_cover_id
        FROM ins.t_product_line     pr
            ,ins.t_prod_line_option opt
            ,ins.p_cover            pc
            ,ins.as_asset           a
            ,ins.p_policy           pp
       WHERE pr.id = par_values.t_product_line_id
         AND pr.id = opt.product_line_id
         AND opt.id = pc.t_prod_line_option_id
         AND pc.as_asset_id = a.as_asset_id
         AND a.p_policy_id = pp.policy_id
         AND pp.policy_id = par_values.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_cover_id := 0;
    END;
  
    BEGIN
      SELECT upper(pr.brief)
        INTO v_product_brief
        FROM ins.p_policy     pp
            ,ins.p_pol_header ph
            ,ins.t_product    pr
       WHERE pp.policy_id = par_values.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = pr.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    --
    IF /*(g_lob_line_brief = iv_19 AND v_product_brief != 'Priority_Invest(lump)')
                                                                                                                                                                                                       OR*/
     (v_product_brief = 'INVEST_IN_FUTURE' AND g_lob_line_brief IN (iv_17, iv_18))
    /*OR (upper(v_product_brief) = 'INVESTOR_LUMP')*/
    THEN
      v_p := ins.pkg_prdlifecalc.pepr_get_netto(p_cover_id => p_p_cover_id, p_no_change => 1);
      v_g := ins.pkg_prdlifecalc.pepr_get_brutto(p_cover_id => p_p_cover_id, p_no_change => 1);
    ELSE
      v_g := 1 / const_tarrif;
      v_p := (1 / const_tarrif) * (1 - par_values.rvb_value);
    END IF;
    --
    --v_P := par_values.p;
    --v_G := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
    --
    v_a_xn  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    -- � ���� ������ �� ����������
  
    dbms_output.put_line('par_periodical ' || par_periodical || ' par_values.age + par_t ' ||
                         (par_values.age + par_t) || ' par_n - par_t ' || (par_n - par_t) ||
                         ' sex_vh ' || sex_vh || ' par_values.deathrate_id ' ||
                         par_values.deathrate_id || ' par_values.fact_yield_rate ' ||
                         par_values.fact_yield_rate || ' par_values.k_coef_re=' ||
                         par_values.k_coef_re || ' par_values.s_coef_re=' || par_values.s_coef_re);
    IF (upper(v_product_brief) IN
       ('INVESTOR_LUMP', 'INVESTOR_LUMP_OLD', 'INVESTOR_LUMP_CALL_CENTRE', 'INVESTOR_LUMP_ALPHA'))
       OR (upper(v_product_brief) = 'PRIORITY_INVEST(LUMP)')
       OR (upper(v_product_brief) = 'INVEST_IN_FUTURE' AND g_lob_line_brief IN (iv_19))
    THEN
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age
                                        ,par_n
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,10);
      v_nex  := ROUND(ins.pkg_amath.nex(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                     ,10);
      v_g    := v_nex / (1 - par_values.rvb_value - v_a1xn);
      v_p    := v_g * (1 - par_values.rvb_value);
    END IF;
    IF par_periodical = 0
    THEN
      -- �������� ������� ����� ������
      -- todo ���������, �� �� ������� ������������?
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,10);
      v_nex  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                     ,10);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
      v_nex_re  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                        ,10);
    
      IF par_t = 0
      THEN
        res_reserve_value.tv_p := 0;
      ELSE
        res_reserve_value.tv_p := ROUND(v_nex + v_g * v_a1xn, 10);
      END IF;
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_re * v_a1xn_re, 10);
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvexp_p := ROUND(v_a * v_g * v_a_xn, 10);
      res_reserve_value.tvs_p   := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
      /*res_reserve_value.tVZ_p   := res_reserve_value.tV_p - 0.04*v_a_xn / v_a_x_n;*/
    ELSE
      v_a1xn  := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef
                                         ,par_values.s_coef
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                      ,10);
      v_ia1xn := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef
                                          ,par_values.s_coef
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                      ,10);
      --
      v_nex := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,par_values.fact_yield_rate)
                    ,10);
    
      dbms_output.put_line('nEx ' || v_nex);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
    
      v_ia1xn_re := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                             ,par_n - par_t
                                             ,sex_vh
                                             ,par_values.k_coef_re
                                             ,par_values.s_coef_re
                                             ,par_values.deathrate_id
                                             ,par_values.fact_yield_rate)
                         ,10);
      --
      v_nex_re := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef_re
                                         ,par_values.s_coef_re
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                       ,10);
    
      --      select 0.532866729 * 456557 from dual
    
      /*BEGIN
      SELECT SUM(g * S)
        INTO v_g_sum
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        v_g_sum := 0;
      END;*/
      BEGIN
        SELECT SUM(g)
          INTO v_g_sum
          FROM reserve.r_reserve_value
         WHERE reserve_id = par_registry.id
           AND insurance_year_number < par_t
           AND insurance_year_number != 0;
      EXCEPTION
        WHEN no_data_found THEN
          v_g_sum := 0;
      END;
      /*select sum (fee / S) into v_g_sum from reserve.r_reserve_value where reserve_id = par_registry.id and insurance_year_number < par_t and insurance_year_number != 0;*/
      dbms_output.put_line(' v_g_sum (1)' || v_g_sum);
      v_fee := par_values.ins_premium;
      IF par_t > 0
      THEN
        IF v_s = 0
        THEN
          v_g_sum := nvl(v_g_sum, 0);
        ELSE
          /*v_g_sum := (nvl(v_g_sum, 0) + v_g * v_S) / v_S;*/
          v_g_sum := (nvl(v_g_sum, 0) + v_g);
          v_g_sum := nvl(v_g_sum, 0);
        END IF;
      ELSE
        v_g_sum := 0;
      END IF;
      dbms_output.put_line(' v_g_sum (2)' || v_g_sum);
    
      /*BEGIN
      SELECT SUM(g * S)
        INTO v_g_sum_re
        FROM reserve.r_reserve_value
       WHERE reserve_id = par_registry.id
         AND insurance_year_number < par_t
         AND insurance_year_number != 0;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        v_g_sum_re := 0;
      END;*/
      BEGIN
        SELECT SUM(g)
          INTO v_g_sum_re
          FROM reserve.r_reserve_value
         WHERE reserve_id = par_registry.id
           AND insurance_year_number < par_t
           AND insurance_year_number != 0;
      EXCEPTION
        WHEN no_data_found THEN
          v_g_sum_re := 0;
      END;
      IF par_values.insurance_amount = 0
      THEN
        v_g_sum_re := nvl(v_g_sum_re, 0);
      ELSE
        /*v_g_sum_re := (nvl(v_g_sum_re, 0) + v_g_re * par_values.insurance_amount) /
        par_values.insurance_amount;*/
        v_g_sum_re := (nvl(v_g_sum_re, 0) + v_g_re);
        v_g_sum_re := nvl(v_g_sum_re, 0);
      END IF;
    
      IF par_t = 0
      THEN
        res_reserve_value.tv_p := 0;
      ELSE
        res_reserve_value.tv_p := ROUND(v_nex + v_g_sum * v_a1xn + v_g * v_ia1xn - v_p * v_a_xn, 10);
      END IF;
    
      dbms_output.put_line('tV= ' || v_nex * v_s || ' + ' || v_g_sum * v_a1xn * v_s || ' + ' ||
                           v_g * v_ia1xn * v_s || ' - ' || v_p * v_a_xn * v_s);
    
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_sum_re * v_a1xn_re + v_g_re * v_ia1xn_re -
                                         v_p_re * v_a_xn_re
                                        ,10);
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * v_a_xn / v_a_x_n, 10);
    
    END IF;
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      /*IF upper(v_product_brief) = 'INVESTOR_LUMP' THEN
        res_reserve_value.PLAN := GREATEST(0
                                          ,ROUND((NVL(res_reserve_value.tVZ_p,0) + NVL(res_reserve_value.tVEXP_p,0)) \** v_S*\,10)
                                          );
      ELSE*/
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(v_tvz_p * v_s_p, 0) +
                                               res_reserve_value.tvz_p * v_s + v_p * v_s) / 2
                                              ,10));
      /*END IF;*/
      res_reserve_value.plan := ROUND(res_reserve_value.plan /*/v_S*/, 10);
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    dbms_output.put_line(' par_n=' || par_n || ' par_t=' || par_t || ' v_nEx=' || v_nex || ' v_g=' || v_g ||
                         ' v_A1xn=' || v_a1xn || ' v_IA1xn=' || v_ia1xn || ' v_p=' || v_p ||
                         ' v_a_xn=' || v_a_xn || ' v_g_sum ' || v_g_sum);
    dbms_output.put_line(' tV_p ' || res_reserve_value.tv_p || ' a_z ' || v_az || ' v_a_xn ' ||
                         v_a_xn || ' v_a_x_n ' || v_a_x_n || ' tVZ_p' || res_reserve_value.tvz_p ||
                         ' t(VB) ' || res_reserve_value.plan);
  
    ------------------
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_n'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_t'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_nEx'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_nex);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_g'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_g);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_A1xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a1xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_IA1xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_ia1xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_g_sum'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_g_sum);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.tv_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'a_z'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_az);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_x_n'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_x_n);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tVZ_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.tvz_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 't(VB)'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.plan);
  
    ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                       ,par_trace_subobj_name => c_proc_name
                       ,par_message           => '������ tV_p');
  
    ------------------      
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
    --
    RETURN res_reserve_value;
  END;

  /**
  * ������ �������� ������� �� �������� ������� ��� �������� �����������
  * <br> "������� � ������������ ������� � ������ ������, ������� �������� ����.
  * <br> �������� ���������� ������ @link calc_reserve_for_iv
  */
  FUNCTION calc_reserve_for_iv_17
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    v_i_summ NUMBER;
    v_c1     NUMBER; -- �������� ����� ���������� + 1
    v_q      NUMBER;
    v_a      NUMBER;
    v_p      NUMBER;
    v_g      NUMBER;
    v_g_sum  NUMBER;
    v_s      NUMBER;
    v_s_p    NUMBER;
  
    v_p_re     NUMBER;
    v_g_re     NUMBER;
    v_g_sum_re NUMBER;
  
    v_a1xn  NUMBER;
    v_ia1xn NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
    v_nex   NUMBER;
  
    v_a1xn_re  NUMBER;
    v_ia1xn_re NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
    v_nex_re   NUMBER;
  
    v_lives           NUMBER(1); -- ��� �� ��������������
    v_i_temp          NUMBER;
    tspm_g            NUMBER; -- ������������ tspm �� G
    res_reserve_value r_reserve_value%ROWTYPE;
    --
    one_payment NUMBER(1);
    sex_vh      VARCHAR2(2);
    --
    v_az NUMBER;
  
    v_tvz_p      NUMBER;
    p_p_cover_id NUMBER;
    v_fee        NUMBER;
  
    v_product_brief ins.t_product.brief%TYPE;
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_FOR_IV_17';
  BEGIN
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_c', par_trace_var_value => par_c);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_j', par_trace_var_value => par_j);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_b', par_trace_var_value => par_b);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_kom', par_trace_var_value => par_kom);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    dbms_output.put_line('CALC_RESERVE_FOR_IV_17 ');
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
    res_reserve_value.fee  := par_values.ins_premium;
  
    v_s := par_values.insurance_amount;
  
    SELECT decode(par_periodical, 0, 1, 0) INTO one_payment FROM dual;
    SELECT decode(par_values.sex, 0, 'w', 1, 'm') INTO sex_vh FROM dual;
    --
    v_az                  := a_z(par_registry.policy_id, par_values.rvb_value);
    res_reserve_value.a_z := v_az;
  
    --
    v_tvz_p := par_reserve_value_for_begin.tvz_p;
    v_s_p   := par_reserve_value_for_begin.s;
  
    dbms_output.put_line('��������� ��� ' || par_t || '');
    dbms_output.put_line('�������� ����������� ������� :');
    dbms_output.put_line('reserve_id ' || par_reserve_value_for_begin.reserve_id);
    dbms_output.put_line('insurance_year_number ' ||
                         par_reserve_value_for_begin.insurance_year_number);
    dbms_output.put_line('insurance_year_date ' || par_reserve_value_for_begin.insurance_year_date);
    dbms_output.put_line('tVZ_p ' || v_tvz_p || ' S ' || v_s_p);
  
    BEGIN
      SELECT pc.p_cover_id
        INTO p_p_cover_id
        FROM ins.t_product_line     pr
            ,ins.t_prod_line_option opt
            ,ins.p_cover            pc
            ,ins.as_asset           a
            ,ins.p_policy           pp
       WHERE pr.id = par_values.t_product_line_id
         AND pr.id = opt.product_line_id
         AND opt.id = pc.t_prod_line_option_id
         AND pc.as_asset_id = a.as_asset_id
         AND a.p_policy_id = pp.policy_id
         AND pp.policy_id = par_values.policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        p_p_cover_id := 0;
    END;
  
    BEGIN
      SELECT pr.brief
        INTO v_product_brief
        FROM ins.p_policy     pp
            ,ins.p_pol_header ph
            ,ins.t_product    pr
       WHERE pp.policy_id = par_values.policy_id
         AND pp.pol_header_id = ph.policy_header_id
         AND ph.product_id = pr.product_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    --
    /*v_P := INS.pkg_PrdLifeCalc.PEPR_get_netto(p_p_cover_id);
    v_G := INS.pkg_PrdLifeCalc.PEPR_get_brutto(p_p_cover_id);*/
    IF par_n = 3
    THEN
      v_g := 1 / 2.77726;
      v_p := (1 / 2.77726) * (1 - par_values.rvb_value);
    ELSE
      v_g := 1 / 4.61300;
      v_p := (1 / 4.61300) * (1 - par_values.rvb_value);
    END IF;
    --
    --v_P := par_values.p;
    --v_G := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
    --
    v_a_xn  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    -- � ���� ������ �� ����������
  
    dbms_output.put_line('par_periodical ' || par_periodical || ' par_values.age + par_t ' ||
                         (par_values.age + par_t) || ' par_n - par_t ' || (par_n - par_t) ||
                         ' sex_vh ' || sex_vh || ' par_values.deathrate_id ' ||
                         par_values.deathrate_id || ' par_values.fact_yield_rate ' ||
                         par_values.fact_yield_rate || ' par_values.k_coef_re=' ||
                         par_values.k_coef_re || ' par_values.s_coef_re=' || par_values.s_coef_re);
    IF par_periodical = 0
    THEN
      -- �������� ������� ����� ������
      -- todo ���������, �� �� ������� ������������?
      v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef
                                        ,par_values.s_coef
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                     ,10);
      v_nex  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                     ,10);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
      v_nex_re  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                        ,10);
    
      IF par_t = 0
      THEN
        res_reserve_value.tv_p := 0;
      ELSE
        res_reserve_value.tv_p := ROUND(v_nex + v_g * v_a1xn, 10);
      END IF;
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_re * v_a1xn_re, 10);
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvexp_p := ROUND(v_a * v_g * v_a_xn, 10);
      res_reserve_value.tvs_p   := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
    ELSE
      v_a1xn  := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef
                                         ,par_values.s_coef
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                      ,10);
      v_ia1xn := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef
                                          ,par_values.s_coef
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                      ,10);
      --
      v_nex := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,par_values.fact_yield_rate)
                    ,10);
    
      dbms_output.put_line('nEx ' || v_nex);
    
      v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                           ,par_n - par_t
                                           ,sex_vh
                                           ,par_values.k_coef_re
                                           ,par_values.s_coef_re
                                           ,par_values.deathrate_id
                                           ,par_values.fact_yield_rate)
                        ,10);
    
      v_ia1xn_re := ROUND(ins.pkg_amath.iax1n(par_values.age + par_t
                                             ,par_n - par_t
                                             ,sex_vh
                                             ,par_values.k_coef_re
                                             ,par_values.s_coef_re
                                             ,par_values.deathrate_id
                                             ,par_values.fact_yield_rate)
                         ,10);
      --
      v_nex_re := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef_re
                                         ,par_values.s_coef_re
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                       ,10);
    
      --      select 0.532866729 * 456557 from dual
      BEGIN
        SELECT SUM(g)
          INTO v_g_sum
          FROM reserve.r_reserve_value
         WHERE reserve_id = par_registry.id
           AND insurance_year_number < par_t
           AND insurance_year_number != 0;
      EXCEPTION
        WHEN no_data_found THEN
          v_g_sum := 0;
      END;
      dbms_output.put_line(' v_g_sum (1)' || v_g_sum);
      v_fee := par_values.ins_premium;
      IF par_t > 0
      THEN
        IF v_s = 0
        THEN
          v_g_sum := nvl(v_g_sum, 0);
        ELSE
          v_g_sum := (nvl(v_g_sum, 0) + v_g);
          v_g_sum := nvl(v_g_sum, 0);
        END IF;
      ELSE
        v_g_sum := 0;
      END IF;
      dbms_output.put_line(' v_g_sum (2)' || v_g_sum);
    
      BEGIN
        SELECT SUM(g)
          INTO v_g_sum_re
          FROM reserve.r_reserve_value
         WHERE reserve_id = par_registry.id
           AND insurance_year_number < par_t
           AND insurance_year_number != 0;
      EXCEPTION
        WHEN no_data_found THEN
          v_g_sum_re := 0;
      END;
      IF par_values.insurance_amount = 0
      THEN
        v_g_sum_re := nvl(v_g_sum_re, 0);
      ELSE
        v_g_sum_re := (nvl(v_g_sum_re, 0) + v_g_re);
        v_g_sum_re := nvl(v_g_sum_re, 0);
      END IF;
    
      IF par_t = 0
      THEN
        res_reserve_value.tv_p := 0;
      ELSE
        res_reserve_value.tv_p := ROUND(v_nex + v_g_sum * v_a1xn + v_g * v_ia1xn - v_p * v_a_xn, 10);
      END IF;
    
      dbms_output.put_line('tV= ' || v_nex * v_s || ' + ' || v_g_sum * v_a1xn * v_s || ' + ' ||
                           v_g * v_ia1xn * v_s || ' - ' || v_p * v_a_xn * v_s);
    
      res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_sum_re * v_a1xn_re + v_g_re * v_ia1xn_re -
                                         v_p_re * v_a_xn_re
                                        ,10);
      res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
    
      res_reserve_value.tvz_p := ROUND(res_reserve_value.tv_p - v_az * v_a_xn / v_a_x_n, 10);
    
    END IF;
  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl((v_tvz_p * v_s / (CASE
                                                      WHEN v_s = 0 THEN
                                                       1
                                                      ELSE
                                                       v_s
                                                    END)) * v_s_p
                                                   ,0) + res_reserve_value.tvz_p * v_s + v_p * v_s) / 2
                                              ,10));
      res_reserve_value.plan := ROUND(res_reserve_value.plan /*/v_S*/, 10);
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    dbms_output.put_line(' par_n=' || par_n || ' par_t=' || par_t || ' v_nEx=' || v_nex || ' v_g=' || v_g ||
                         ' v_A1xn=' || v_a1xn || ' v_IA1xn=' || v_ia1xn || ' v_p=' || v_p ||
                         ' v_a_xn=' || v_a_xn || ' v_g_sum ' || v_g_sum);
    dbms_output.put_line(' tV_p ' || res_reserve_value.tv_p || ' a_z ' || v_az || ' v_a_xn ' ||
                         v_a_xn || ' v_a_x_n ' || v_a_x_n || ' tVZ_p' || res_reserve_value.tvz_p ||
                         ' t(VB) ' || res_reserve_value.plan);
  
    ------------------
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_n'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_t'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_nEx'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_nex);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_g'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_g);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_A1xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a1xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_IA1xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_ia1xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_g_sum'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_g_sum);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.tv_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'a_z'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_az);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_xn'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'v_a_x_n'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => v_a_x_n);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tVZ_p'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.tvz_p);
    ins.pkg_trace.add_variable(par_trace_var_name  => 't(VB)'
                              ,par_trace_var_type  => 'NUMBER'
                              ,par_trace_var_value => res_reserve_value.plan);
  
    ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                       ,par_trace_subobj_name => c_proc_name
                       ,par_message           => '������ tV_p');
  
    ------------------      
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
    --
    RETURN res_reserve_value;
  END;

  FUNCTION calc_reserve_for_iv_23
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
  
    v_p NUMBER;
    v_g NUMBER;
  
    v_p_re NUMBER;
    v_g_re NUMBER;
  
    v_a_xn NUMBER;
    v_dx   NUMBER;
    v_nx   NUMBER;
    v_nx_n NUMBER;
  
    res_reserve_value r_reserve_value%ROWTYPE;
  
    sex_vh VARCHAR2(2);
  
    v_az NUMBER;
  
    v NUMBER;
  
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_FOR_IV_23';
  
    PROCEDURE trace(par_message VARCHAR2) IS
    BEGIN
      ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                         ,par_trace_subobj_name => c_proc_name
                         ,par_message           => par_message);
    END trace;
  
  BEGIN
  
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'reserve_id'
                              ,par_trace_var_value => par_reserve_value_for_begin.reserve_id);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'insurance_year_date'
                              ,par_trace_var_value => par_reserve_value_for_begin.insurance_year_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'insurance_year_number'
                              ,par_trace_var_value => par_reserve_value_for_begin.insurance_year_number);
    ins.pkg_trace.add_variable('par_periodical', par_periodical);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    v_az := a_z(par_registry.policy_id, par_values.rvb_value);
  
    res_reserve_value.a_z := v_az;
  
    ins.pkg_trace.add_variable('v_az', v_az);
    ins.pkg_trace.add_variable('rvb_value', par_values.rvb_value);
    trace('������ a_z');
  
    sex_vh := get_gender(par_values.sex);
  
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
  
    v_p := par_values.p;
    v_g := par_values.g;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.p := v_p;
    res_reserve_value.g := v_g;
  
    res_reserve_value.p_re := v_p_re;
    res_reserve_value.g_re := v_g_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
  
    ins.pkg_trace.add_variable('age', par_values.age);
    ins.pkg_trace.add_variable('sex_vh', sex_vh);
    ins.pkg_trace.add_variable('fact_yield_rate', par_values.fact_yield_rate); -- ����� ����������
    ins.pkg_trace.add_variable('deathrate_id', par_values.deathrate_id); -- �� ������� ����������
    ins.pkg_trace.add_variable('res_reserve_value.s', res_reserve_value.s); -- ��������� �����
    ins.pkg_trace.add_variable('v_p', v_p); -- �����-�����
    ins.pkg_trace.add_variable('v_g', v_g);
    ins.pkg_trace.add_variable('v_p_re', v_p_re);
    ins.pkg_trace.add_variable('v_g_re', v_g_re);
  
    trace('������� �������� ��������');
  
    -- �������� �������
    v_a_xn := ins.pkg_amath.a_xn(par_values.age + par_t
    ,par_n - par_t
    ,sex_vh
    ,par_values.k_coef
    ,par_values.s_coef
    ,1
    ,par_values.deathrate_id
                                ,par_values.fact_yield_rate);
    --
  
    v                      := 1 / (1 + par_values.fact_yield_rate);
    res_reserve_value.tv_p := ROUND(power(v, par_n - par_t) - v_p * v_a_xn, 9);
    res_reserve_value.tv_f := res_reserve_value.tv_p;
    --
  
    res_reserve_value.tvz_p := res_reserve_value.tv_p - v_az * (1 - res_reserve_value.tv_p);
    res_reserve_value.tvz_f := res_reserve_value.tvz_p;
  
    ins.pkg_trace.add_variable('v_dx', v_dx);
    ins.pkg_trace.add_variable('v_nx', v_nx);
    ins.pkg_trace.add_variable('v_nx_n', v_nx_n);
    ins.pkg_trace.add_variable('v_a_xn', v_a_xn);
    ins.pkg_trace.add_variable('v', v);
    ins.pkg_trace.add_variable('tv_p', res_reserve_value.tv_p);
    ins.pkg_trace.add_variable('tv_f', res_reserve_value.tv_f);
    ins.pkg_trace.add_variable('tvz_p', res_reserve_value.tvz_p);
    ins.pkg_trace.add_variable('tvz_f', res_reserve_value.tvz_f);
    trace('��������� �������');
  
    -- ������������� ������ �������
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
      res_reserve_value.plan := greatest(0
                                        ,(nvl(par_reserve_value_for_begin.tvz_p, 0) +
                                         res_reserve_value.tvz_p + v_p) / 2);
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
  
    ins.pkg_trace.add_variable('res_reserve_value.plan', res_reserve_value.plan);
    ins.pkg_trace.add_variable('res_reserve_value.fact', res_reserve_value.fact);
    trace('��������� �������');
  
    ins.pkg_trace.trace_function_end(gc_pkg_name, c_proc_name);
    --
  
    RETURN res_reserve_value;
  END calc_reserve_for_iv_23;

  FUNCTION calc_for_investor_lump_new
  (
    par_registry                IN reserve.r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN reserve.r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
  ) RETURN reserve.r_reserve_value%ROWTYPE IS
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_FOR_INVESTOR_LUMP_NEW';
    v_a   NUMBER;
    v_p   NUMBER;
    v_g   NUMBER;
    v_s   NUMBER;
    v_s_p NUMBER;
  
    v_p_re     NUMBER;
    v_g_re     NUMBER;
    v_g_sum_re NUMBER;
  
    v_a1xn  NUMBER;
    v_ia1xn NUMBER;
    v_a_xn  NUMBER;
    v_a_x_n NUMBER;
    v_nex   NUMBER;
  
    v_a1xn_re  NUMBER;
    v_ia1xn_re NUMBER;
    v_a_xn_re  NUMBER;
    v_a_x_n_re NUMBER;
    v_nex_re   NUMBER;
  
    res_reserve_value reserve.r_reserve_value%ROWTYPE;
    --
    sex_vh VARCHAR2(2);
    --
    v_tvz_p NUMBER;
  
    v_cover ins.dml_p_cover.tt_p_cover;
  BEGIN
  
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    v_a                    := 0.0025;
    res_reserve_value.plan := 0;
    res_reserve_value.fact := 0;
    res_reserve_value.fee  := par_values.ins_premium;
  
    v_s := par_values.insurance_amount;
  
    sex_vh := get_gender(par_values.sex);
  
    --
    res_reserve_value.a_z := a_z(par_registry.policy_id, par_values.rvb_value);
  
    --
    v_tvz_p := par_reserve_value_for_begin.tvz_p;
    v_s_p   := par_reserve_value_for_begin.s;
  
    v_cover := ins.dml_p_cover.get_record(par_registry.p_cover_id);
    v_g     := v_cover.tariff;
    v_p     := v_cover.tariff_netto;
  
    v_p_re := par_values.p_re;
    v_g_re := par_values.g_re;
  
    v_a_xn  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                       ,par_n - par_t
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
    v_a_x_n := ROUND(ins.pkg_amath.a_xn(par_values.age
                                       ,par_n
                                       ,sex_vh
                                       ,par_values.k_coef
                                       ,par_values.s_coef
                                       ,1
                                       ,par_values.deathrate_id
                                       ,par_values.fact_yield_rate)
                    ,10);
  
    v_a_xn_re  := ROUND(ins.pkg_amath.a_xn(par_values.age + par_t
                                          ,par_n - par_t
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
    v_a_x_n_re := ROUND(ins.pkg_amath.a_xn(par_values.age
                                          ,par_n
                                          ,sex_vh
                                          ,par_values.k_coef_re
                                          ,par_values.s_coef_re
                                          ,1
                                          ,par_values.deathrate_id
                                          ,par_values.fact_yield_rate)
                       ,10);
  
    v_a1xn := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                      ,par_n - par_t
                                      ,sex_vh
                                      ,par_values.k_coef
                                      ,par_values.s_coef
                                      ,par_values.deathrate_id
                                      ,par_values.fact_yield_rate)
                   ,10);
    v_nex  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                     ,par_n - par_t
                                     ,sex_vh
                                     ,par_values.k_coef
                                     ,par_values.s_coef
                                     ,par_values.deathrate_id
                                     ,par_values.fact_yield_rate)
                   ,10);
  
    v_a1xn_re := ROUND(ins.pkg_amath.ax1n(par_values.age + par_t
                                         ,par_n - par_t
                                         ,sex_vh
                                         ,par_values.k_coef_re
                                         ,par_values.s_coef_re
                                         ,par_values.deathrate_id
                                         ,par_values.fact_yield_rate)
                      ,10);
    v_nex_re  := ROUND(ins.pkg_amath.nex(par_values.age + par_t
                                        ,par_n - par_t
                                        ,sex_vh
                                        ,par_values.k_coef_re
                                        ,par_values.s_coef_re
                                        ,par_values.deathrate_id
                                        ,par_values.fact_yield_rate)
                      ,10);
  
    --������ tV_p
    res_reserve_value.tv_p := ROUND(v_nex + v_g * v_a1xn, 10);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx', par_trace_var_value => v_nex);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn', par_trace_var_value => v_a1xn);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_g', par_trace_var_value => v_g);
    ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                       ,par_trace_subobj_name => c_proc_name
                       ,par_message           => '������ tV_p');
  
    -- ������ tV_p_re
    res_reserve_value.tv_p_re := ROUND(v_nex_re + v_g_re * v_a1xn_re, 10);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_nEx_re', par_trace_var_value => v_nex_re);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_A1xn_re', par_trace_var_value => v_a1xn_re);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_g_re', par_trace_var_value => v_g_re);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tV_p_re'
                              ,par_trace_var_value => res_reserve_value.tv_p_re);
  
    res_reserve_value.tv_f_re := res_reserve_value.tv_p_re;
  
    -- ������ tVexp_p
    res_reserve_value.tvexp_p := ROUND(v_a * v_g * v_a_xn, 10);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_a', par_trace_var_value => v_a);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_g', par_trace_var_value => v_g);
    ins.pkg_trace.add_variable(par_trace_var_name => 'v_a_xn', par_trace_var_value => v_a_xn);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'tVexp_p'
                              ,par_trace_var_value => res_reserve_value.tvexp_p);
    ins.pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                       ,par_trace_subobj_name => c_proc_name
                       ,par_message           => '������ tVexp_p');
  
    res_reserve_value.tvs_p := res_reserve_value.tv_p + res_reserve_value.tvexp_p;
  
    /*  
    IF par_t = 0
    THEN
      res_reserve_value.plan := 0;
      res_reserve_value.fact := res_reserve_value.plan;
    ELSE
    
      res_reserve_value.plan := greatest(0
                                        ,ROUND((nvl(v_tvz_p * v_s_p, 0) +
                                               res_reserve_value.tvz_p * v_s + v_p * v_s) / 2
                                              ,10));
    
      res_reserve_value.fact := res_reserve_value.plan;
    END IF;
    */
  
    res_reserve_value.plan := ROUND((nvl(v_tvz_p * v_s_p, 0) + res_reserve_value.tvz_p * v_s +
                                    v_p * v_s) / 2
                                   ,10);
    res_reserve_value.fact := res_reserve_value.plan;
  
    res_reserve_value.s := par_values.insurance_amount;
    res_reserve_value.c := par_values.fact_yield_rate;
    res_reserve_value.g := v_g;
    res_reserve_value.p := v_p;
  
    res_reserve_value.g_re := v_g_re;
    res_reserve_value.p_re := v_p_re;
  
    res_reserve_value.j := par_values.fact_yield_rate;
  
    RETURN res_reserve_value;
  
  END calc_for_investor_lump_new;

  /**
  * ������� ������� �������� ������� �� �������� �������.
  * <p> �������������� ���������� ���������� ������ ��
  * <br> �������� �����������. ����� �������, ��� �������
  * <br> �� ������� �������� �� ��������� �����������
  * <br> ������ ����� ����� �� ���������. ������� ��������
  * <br> ����������� ��������� �� ������� �������� �������.
  * @param par_registry ������� �������
  * @param par_start_date ���� ������ ��������������� ������
  * @param par_ins_start_date ���� ������ ���������� ���� par_t
  * @param par_values �������� �� ������ � �������� �����������, ���������� �������� par_t
  * @param par_t ����� ���������� ����, � ������� ���������� ������
  * @param par_reserve_value_for_begin �������� �������
  * <br> �� ������ �����. ���� � ������� par_t. ������������ ��������
  * @param par_periodical ���������� �� ������ �� �������� �������
  * @param par_n ���� �����������
  * @param par_c �������� ����� ����������
  * @param par_j ����������� ����� ����������
  * @param par_b ����������� �
  * @param par_kom ���� �������� (������� �� pat_t)
  */
  FUNCTION calc_reserve_for_iv
  (
    par_registry                IN r_reserve%ROWTYPE
   ,par_start_date              IN DATE
   ,par_ins_start_date          IN DATE
   ,par_values                  IN pkg_reserve_r_life.hist_values_type
   ,par_t                       IN NUMBER
   ,par_reserve_value_for_begin IN r_reserve_value%ROWTYPE
   ,par_periodical              IN NUMBER
   ,par_n                       IN NUMBER
   ,par_c                       IN NUMBER
   ,par_j                       IN NUMBER
   ,par_b                       IN NUMBER
   ,par_kom                     IN NUMBER
  ) RETURN r_reserve_value%ROWTYPE IS
    c_proc_name CONSTANT ins.pkg_trace.t_object_name := 'CALC_RESERVE_FOR_IV';
    res_reserve_value r_reserve_value%ROWTYPE;
    --������ ������� 
    --v_product         varchar2(20);
    v_product   ins.t_product.brief%TYPE;
    v_const_tar NUMBER;
    --
    v_disable_reserve NUMBER(1);
  
  BEGIN
  
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_start_date'
                              ,par_trace_var_value => par_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_ins_start_date'
                              ,par_trace_var_value => par_ins_start_date);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_t', par_trace_var_value => par_t);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_periodical'
                              ,par_trace_var_value => par_periodical);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_n', par_trace_var_value => par_n);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_c', par_trace_var_value => par_c);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_j', par_trace_var_value => par_j);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_b', par_trace_var_value => par_b);
    ins.pkg_trace.add_variable(par_trace_var_name => 'par_kom', par_trace_var_value => par_kom);
    ins.pkg_trace.add_variable(par_trace_var_name  => 'par_registry.insurance_variant_id'
                              ,par_trace_var_value => par_registry.insurance_variant_id);
  
    ins.pkg_trace.trace_function_start(par_trace_obj_name    => gc_pkg_name
                                      ,par_trace_subobj_name => c_proc_name);
  
    SELECT brief
      INTO g_lob_line_brief
      FROM ins.t_lob_line
     WHERE t_lob_line_id = par_registry.insurance_variant_id;
  
    SELECT disable_reserve_calc
      INTO v_disable_reserve
      FROM ins.t_product_line
     WHERE id = par_registry.t_product_line_id;
  
    IF nvl(v_disable_reserve, 0) = 0
    THEN
      --�� ������� ������ ��� ���������� ��������
    
      SELECT tp.brief
        INTO v_product
        FROM ins.t_product    tp
            ,ins.p_policy     pp
            ,ins.p_pol_header ph
       WHERE pp.policy_id = par_registry.policy_id
         AND ph.policy_header_id = pp.pol_header_id
         AND tp.product_id = ph.product_id;
    
      IF g_lob_line_brief = iv_01
         AND v_product <> 'Family_La2'
      THEN
        --  ��������� �����������
        res_reserve_value := calc_reserve_for_iv_01(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ��������� ����������� ��� FLA_2
      ELSIF g_lob_line_brief = iv_01
            AND v_product = 'Family_La2'
      THEN
        res_reserve_value := calc_reserve_for_iv_01_fla(par_registry
                                                       ,par_start_date
                                                       ,par_ins_start_date
                                                       ,par_values
                                                       ,par_t
                                                       ,par_reserve_value_for_begin
                                                       ,par_periodical
                                                       ,par_n
                                                       ,par_c
                                                       ,par_j
                                                       ,par_b
                                                       ,par_kom);
      ELSIF g_lob_line_brief = iv_23
      THEN
        res_reserve_value := calc_reserve_for_iv_23(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      
        -- ����������� �� ������ ������ �� ����
      ELSIF g_lob_line_brief = iv_02
            AND v_product <> 'SF_AVCR'
      THEN
        res_reserve_value := calc_reserve_for_iv_02(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        --������-������
      ELSIF g_lob_line_brief = iv_22
      THEN
        res_reserve_value := calc_reserve_for_iv_02(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ����������� �� ������ ������ �� ���� ��� ���������������� + � ���
      ELSIF g_lob_line_brief = iv_02
            AND v_product = 'SF_AVCR'
      THEN
        res_reserve_value := calc_reserve_for_iv_02sf(par_registry
                                                     ,par_start_date
                                                     ,par_ins_start_date
                                                     ,par_values
                                                     ,par_t
                                                     ,par_reserve_value_for_begin
                                                     ,par_periodical
                                                     ,par_n
                                                     ,par_c
                                                     ,par_j
                                                     ,par_b
                                                     ,par_kom);
        -- ����������� �� ������ ������ �� ���� � �������� ����� (����������� ����� �� ����)
      ELSIF g_lob_line_brief = iv_03
      THEN
        res_reserve_value := calc_reserve_for_iv_15(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ����������� �� �������
      ELSIF g_lob_line_brief = iv_04
      THEN
        res_reserve_value := calc_reserve_for_iv_04(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ����������� ����� � ������������� ������ ������� ���������� �����������
      ELSIF g_lob_line_brief = iv_05
      THEN
        res_reserve_value := calc_reserve_for_iv_15(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ����������� ��������� �����
      ELSIF g_lob_line_brief = iv_06
      THEN
        res_reserve_value := calc_reserve_for_iv_06(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- ��������� ����������� �����
      ELSIF g_lob_line_brief = iv_07
      THEN
        res_reserve_value := calc_reserve_for_iv_07(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      
      ELSIF g_lob_line_brief = iv_08
      THEN
        res_reserve_value := calc_reserve_for_iv_08(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      ELSIF g_lob_line_brief = iv_09
      THEN
        res_reserve_value := calc_reserve_for_iv_09_10_11(par_registry
                                                         ,par_start_date
                                                         ,par_ins_start_date
                                                         ,par_values
                                                         ,par_t
                                                         ,par_reserve_value_for_begin
                                                         ,par_periodical
                                                         ,par_n
                                                         ,par_c
                                                         ,par_j
                                                         ,par_b
                                                         ,par_kom);
      ELSIF g_lob_line_brief = iv_10
      THEN
        res_reserve_value := calc_reserve_for_iv_09_10_11(par_registry
                                                         ,par_start_date
                                                         ,par_ins_start_date
                                                         ,par_values
                                                         ,par_t
                                                         ,par_reserve_value_for_begin
                                                         ,par_periodical
                                                         ,par_n
                                                         ,par_c
                                                         ,par_j
                                                         ,par_b
                                                         ,par_kom);
      ELSIF g_lob_line_brief = iv_11
      THEN
        res_reserve_value := calc_reserve_for_iv_09_10_11(par_registry
                                                         ,par_start_date
                                                         ,par_ins_start_date
                                                         ,par_values
                                                         ,par_t
                                                         ,par_reserve_value_for_begin
                                                         ,par_periodical
                                                         ,par_n
                                                         ,par_c
                                                         ,par_j
                                                         ,par_b
                                                         ,par_kom);
      ELSIF g_lob_line_brief = iv_12
      THEN
        res_reserve_value := calc_reserve_for_iv_12(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      ELSIF g_lob_line_brief = iv_13
      THEN
        res_reserve_value := calc_reserve_for_iv_13(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      ELSIF g_lob_line_brief = iv_14
      THEN
        -- ��������� ��������� "������ 2"
        res_reserve_value := calc_reserve_for_iv_02(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      
      ELSIF g_lob_line_brief = iv_15
      THEN
        -- ����������� �� ��������� "��������� ���������������� ���������� �������� �����������"
        res_reserve_value := calc_reserve_for_iv_15(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
        -- �������� ��� ������ ��������
        --      when 8130 then
        --         null;
        --      when 8131 then
        --        null;
        --      when 8132 then
        --       null;
      ELSIF g_lob_line_brief = iv_16
      THEN
        SELECT decode(v_product, 'Priority_Invest(regular)', 3.1614, 3.21) INTO v_const_tar FROM dual;
        res_reserve_value := calc_reserve_for_iv_16(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom
                                                   ,v_const_tar);
      ELSIF ins.pkg_product_category.is_product_in_category(par_product_brief       => v_product
                                                           ,par_category_type_brief => 'RESERVE_CALCULATION_ALGORITHM'
                                                           ,par_category_brief      => 'INVESTOR_LUMP')
           
            AND g_lob_line_brief IN (iv_17, iv_18, iv_19)
      THEN
        res_reserve_value := calc_for_investor_lump_new(par_registry
                                                       ,par_start_date
                                                       ,par_ins_start_date
                                                       ,par_values
                                                       ,par_t
                                                       ,par_reserve_value_for_begin
                                                       ,par_periodical
                                                       ,par_n);
      ELSIF g_lob_line_brief = iv_17
            AND v_product NOT IN ('INVESTOR_LUMP_AKBARS', 'INVESTOR_LUMP_GLOBEKS')
      THEN
        SELECT CASE
                 WHEN v_product = 'Priority_Invest(regular)' THEN
                  3.0451
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 5 THEN
                  1.0492
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 3 THEN
                  1.007
                 WHEN v_product = 'Priority_Invest(lump)' THEN
                  1.0070
                 ELSE
                  3.028
               END
          INTO v_const_tar
          FROM dual;
        /*SELECT DECODE(v_product
                   ,'Priority_Invest(regular)'
                   ,3.0451
                   ,'Priority_Invest(lump)'
                   ,1.0070
                   ,3.028)
        INTO v_const_tar
        FROM DUAL;*/
        res_reserve_value := calc_reserve_for_iv_16(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom
                                                   ,v_const_tar);
      ELSIF g_lob_line_brief = iv_18
            AND v_product NOT IN ('INVESTOR_LUMP_AKBARS', 'INVESTOR_LUMP_GLOBEKS')
      THEN
        SELECT CASE
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 5 THEN
                  0.9452
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 3 THEN
                  0.9482
                 WHEN v_product = 'Priority_Invest(lump)' THEN
                  0.9482
                 ELSE
                  2.9743
               END
          INTO v_const_tar
          FROM dual;
        /*SELECT DECODE(v_product, 'Priority_Invest(lump)', 0.9482, 2.9743) INTO v_const_tar FROM DUAL;*/
        res_reserve_value := calc_reserve_for_iv_16(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom
                                                   ,v_const_tar);
      ELSIF g_lob_line_brief = iv_19
            AND v_product NOT IN ('INVESTOR_LUMP_AKBARS', 'INVESTOR_LUMP_GLOBEKS')
      THEN
        SELECT CASE
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 5 THEN
                  0.8043
                 WHEN v_product IN ('INVESTOR_LUMP'
                                   ,'INVESTOR_LUMP_OLD'
                                   ,'INVESTOR_LUMP_CALL_CENTRE'
                                   ,'INVESTOR_LUMP_ALPHA')
                      AND par_n = 3 THEN
                  0.8052
                 WHEN v_product = 'Priority_Invest(lump)' THEN
                  0.8052
                 ELSE
                  1
               END
          INTO v_const_tar
          FROM dual;
        /*SELECT DECODE(v_product, 'Priority_Invest(lump)', 0.8052, 1) INTO v_const_tar FROM DUAL;*/
        res_reserve_value := calc_reserve_for_iv_16(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom
                                                   ,v_const_tar);
      ELSIF g_lob_line_brief IN (iv_20, iv_21)
      THEN
        res_reserve_value := calc_reserve_for_iv_17(par_registry
                                                   ,par_start_date
                                                   ,par_ins_start_date
                                                   ,par_values
                                                   ,par_t
                                                   ,par_reserve_value_for_begin
                                                   ,par_periodical
                                                   ,par_n
                                                   ,par_c
                                                   ,par_j
                                                   ,par_b
                                                   ,par_kom);
      ELSE
        pkg_reserve_life.error(pkg_name
                              ,'calc_reserve_for_iv'
                              ,'�� ��������� �������� ������� ������� ' ||
                               '��� �������� ����������� � �� ' || par_registry.insurance_variant_id);
        RAISE case_not_found;
      END IF;
    END IF;
    res_reserve_value.reserve_id            := par_registry.id;
    res_reserve_value.insurance_year_date   := par_ins_start_date;
    res_reserve_value.insurance_year_number := par_t;
  
    RETURN res_reserve_value;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE; -- �������� ����, ����� ����� �� ������������ ���� ������� � �����������
  
  END;
END;
/

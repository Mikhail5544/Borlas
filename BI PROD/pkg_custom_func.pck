CREATE OR REPLACE PACKAGE pkg_custom_func IS

  /**
  *
  * @author Denis Ivanov
  * ����� ���������������� �������. ��������, �� ������� ������� �� ��������� �������.
  */

  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� �����.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_osago(p_p_cover_id NUMBER) RETURN NUMBER;

  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� �����.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_casco(p_p_cover_id NUMBER) RETURN NUMBER;

END pkg_custom_func;
/
CREATE OR REPLACE PACKAGE BODY pkg_custom_func IS
  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� �����.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_osago(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_cover      p_cover%ROWTYPE;
    v_payoff_sum NUMBER;
    v_rvd_sum    NUMBER;
    v_com_sum    NUMBER;
    v_zsp_sum    NUMBER;
    v_decl_date  DATE;
    dni_ost      NUMBER;
    dni_all      NUMBER;
  BEGIN
    SELECT pc.* INTO v_cover FROM p_cover pc WHERE pc.p_cover_id = p_p_cover_id;
  
    -- �������, ��� ���� ���������� �������� ������ ����� ���� ������ ������ - 1 ����
    SELECT p.start_date - 1
      INTO v_decl_date
      FROM p_policy p
          ,as_asset a
          ,p_cover  pc
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id;
  
    -- ������ ����� ������
    v_payoff_sum := 0; -- ������� �� �����������
  
    -- ������ ����� ��������� ������
    v_com_sum := 0; -- ������������ �� ����������, ��������� ����������� ���
  
    -- ������ "������" ���  (�������)
    v_zsp_sum := 0;
    IF (v_cover.start_date < v_decl_date AND v_cover.end_date > v_decl_date)
    THEN
      SELECT SUM(d.dni_ost)
            ,SUM(d.dni_all)
        INTO dni_ost
            ,dni_all
        FROM (SELECT --p.as_asset_id,
               CASE
                 WHEN p.end_date < v_decl_date THEN
                  0
                 WHEN p.end_date >= v_decl_date
                      AND p.start_date <= v_decl_date THEN
                  (trunc(p.end_date) - trunc(v_decl_date) + 1)
                 WHEN p.start_date > v_decl_date THEN
                  (trunc(p.end_date) - trunc(p.start_date) + 1)
               END dni_ost
              ,(trunc(p.end_date) - trunc(p.start_date) + 1) dni_all
                FROM as_asset_per p
               WHERE p.as_asset_id = v_cover.as_asset_id) d;
      v_zsp_sum := ROUND(v_cover.premium * (dni_all - dni_ost) / dni_all, 2);
    ELSIF v_cover.start_date > v_decl_date
    THEN
      v_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decl_date
    THEN
      v_zsp_sum := v_cover.premium;
    END IF;
  
    v_rvd_sum := 0;
  
    -- ������ �������� �� ������� ����
    SELECT ROUND(nvl(ig.operation_cost, 0) * (v_cover.premium - v_zsp_sum), 2)
      INTO v_rvd_sum
      FROM t_insurance_group  ig
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE plo.id = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ������ ��� � ������ ��� � ����� �������������� ������
    v_zsp_sum := v_zsp_sum + v_rvd_sum;
    RETURN v_zsp_sum;
  END;

  /**
  * ������ ������������ ������ ��� ���������� ������ �� �������� �� �����.
  * @author Denis Ivanov
  * @param p_p_cover_id �� ������� �������� P_COVER
  * @return �������� ��� ������� � ������ ������ ������������ � �������.
  */
  FUNCTION calc_zsp_casco(p_p_cover_id NUMBER) RETURN NUMBER IS
    v_cover      p_cover%ROWTYPE;
    v_payoff_sum NUMBER;
    v_rvd_sum    NUMBER;
    v_com_sum    NUMBER;
    v_zsp_sum    NUMBER;
    v_decl_date  DATE;
    dni_ost      NUMBER;
    dni_all      NUMBER;
  BEGIN
    SELECT pc.* INTO v_cover FROM p_cover pc WHERE pc.p_cover_id = p_p_cover_id;
  
    -- �������, ��� ���� ���������� �������� ������ ����� ���� ������ ������ - 1 ����
    SELECT p.start_date - 1
      INTO v_decl_date
      FROM p_policy p
          ,as_asset a
          ,p_cover  pc
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id;
  
    -- ������ ����� ������
    v_payoff_sum := 0; -- ������� �� �����������
  
    -- ������ ����� ��������� ������
    v_com_sum := 0; -- ������������ �� ����������, ��������� ����������� ���
  
    -- ������ "������" ���  (�������)
    v_zsp_sum := 0;
    IF (v_cover.start_date < v_decl_date AND v_cover.end_date > v_decl_date)
    THEN
      v_zsp_sum := ROUND(v_cover.premium * CEIL(MONTHS_BETWEEN(v_decl_date + 1, v_cover.start_date)) /
                         MONTHS_BETWEEN((v_cover.end_date + 1), v_cover.start_date)
                        ,2);
    ELSIF v_cover.start_date > v_decl_date
    THEN
      v_zsp_sum := 0;
    ELSIF v_cover.end_date < v_decl_date
    THEN
      v_zsp_sum := v_cover.premium;
    END IF;
  
    v_rvd_sum := 0;
  
    -- ������ �������� �� ������� ����
    SELECT ROUND(nvl(ig.operation_cost, 0) * (v_cover.premium - v_zsp_sum), 2)
      INTO v_rvd_sum
      FROM t_insurance_group  ig
          ,t_prod_line_option plo
          ,t_product_line     pl
     WHERE plo.id = v_cover.t_prod_line_option_id
       AND plo.product_line_id = pl.id
       AND pl.insurance_group_id = ig.t_insurance_group_id;
  
    -- ������ ��� � ������ ��� � ����� �������������� ������
    v_zsp_sum := v_zsp_sum + v_rvd_sum;
    RETURN v_zsp_sum;
  END;

END pkg_custom_func;
/

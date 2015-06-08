CREATE OR REPLACE PACKAGE PKG_INS_AMOUNT IS

  -- Author  : MMIROVICH
  -- Created : 06.03.2008 15:54:41
  -- Purpose : ����� ��� ������� ��������� ���� ��� ������� � ��������

  -------------------------------------------------------------
  --***************** ��� - �����������
  -------------------------------------------------------------
  /**
  * CC �� �������� ��� �������
  * @author Mirovich M.
  * @param p_pol_id �� ������ ��������
  * @return - ��������� ����� �� �������
  */
  -- CC �� �������� ��� �������
  FUNCTION calc_amount_pol_mortgage(p_pol_id NUMBER) RETURN NUMBER;
END PKG_INS_AMOUNT;
/
CREATE OR REPLACE PACKAGE BODY PKG_INS_AMOUNT IS

  -------------------------------------------------------------
  --***************** ��� - ����������� **********************
  -------------------------------------------------------------
  -- CC �� �������� ��� �������
  FUNCTION calc_amount_pol_mortgage(p_pol_id NUMBER) RETURN NUMBER IS
    res NUMBER;
  BEGIN
    SELECT NVL(SUM(ass.ins_amount), 0)
      INTO res
      FROM ven_p_policy pp
      JOIN ven_as_assured ass
        ON pp.policy_id = ass.p_policy_id
      JOIN ven_p_asset_header pas
        ON pas.p_asset_header_id = ass.p_asset_header_id
      JOIN t_asset_type ast
        ON pas.t_asset_type_id = ast.t_asset_type_id
     WHERE pp.policy_id = p_pol_id
       AND ast.brief = '��������������'
       AND ass.is_debtor = 1;
    RETURN(res);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

END PKG_INS_AMOUNT;
/

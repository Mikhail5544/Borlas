CREATE OR REPLACE PACKAGE pkg_amath AS
  -- @Author Marchuk A.
  -- @����� "��������� ����������"
  -- @��������� �������� ��������� ����������
  --
  /**
  * ���������� a_n - ����������� ��������� (PV) ����������� / ������������������ ���������
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */

  FUNCTION a_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� a_x - ����������� ��������� (PV) ����������� ����� �����������
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */

  FUNCTION a_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� a_x - ����������� ��������� (PV) ����������� ����� �����������
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */

  FUNCTION a_xy
  (
    x              IN NUMBER
   ,p_sex_x        IN VARCHAR2
   ,y              IN NUMBER
   ,p_sex_y        IN VARCHAR2
   ,m              IN NUMBER
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� n_a_x - ����������� �� n ��� ����������� �������� ����������� - ����������� �� ������ �������� �������� �����������
  * ��������� �������� ����������� ����� (������), ����������� �� n ��� ��� �������, ��� ������ ������� ������������ ����� n ���
  * ����� ������ �������� �������� ����������� � ������ ������� ���������� ����, ���� �������������� � ����� ������� ���
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION n_a_x
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� s_n - ����������� ��������� ����������� / ������������������ ���������� � ��������� � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */

  FUNCTION s_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� qx (���� qx "�����������" ��������������)
  * @author Marchuk A.
  * @param x - �������
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */
  --
  FUNCTION qx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� px - ����������� ��� ���� �������� � ������ �� �������� x+1
  * @author Marchuk A.
  * @param x - �������
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */
  FUNCTION px
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� pxk ����������� ��� ���� �������� � ������ �� �������� x+k
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION pxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� qxk (����������� ���� ��� ���� x ����� � ������� k ���)
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  --
  /**
  * ���������� �������� nEx = p(x,n) * v^n ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION nex
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * ���������� ���������� ������� ����������, ��������������� ����� ���, �������� �� �������� x
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION lx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  --

  /**
  * ���������� Dx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION dx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  /**
  * ���������� Nx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION nx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Cx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION cx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Mx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION mx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Rx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION rx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Sx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION sx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Ax1n (APV, ����������� ��������� �������� ����������� ����� �� n ���) ��� ���������� ("�����������") ������� ���������� �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION ax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  FUNCTION axt1nt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  /**
  * ���������� Axn1 (APV, ����������� ��������� ����������� �� ������� ������ n ���) ��� ���������� ("�����������") ������� ���������� �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION axn1
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� IAx1n  - APV, ����������� ��������� �������� ����������� ����� �� n ��� � ������������ ��������� ������ (��� ������ � ������� m-�� ����, m<=n ������������� ��������� �����, ������ m)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION iax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� Axn (APV, ����������� ��������� ���������� ����������� ����� �� n ���) �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION axn
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;

  FUNCTION axtnt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * ���������� Ax (APV, ����������� ��������� ������������ �����������) �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */
  FUNCTION ax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --

  /**
  * ���������� IAx (APV, ����������� ��������� ������������ ����������� ���������) ��������� ����� ����� n � ����� n-�� ����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION iax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * ���������� a_xn ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� ������� ��������� � ������� "1"
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION a_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  FUNCTION a_xtnt_famdep
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,t              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
  ) RETURN NUMBER;
  --
  /**
  * ���������� am_xn_KS - ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * ��� ���������� ��� ������ m ��� � ��� ������������ ������������� �������� (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION am_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /**
  * ���������� am_x ����������� ��������� (APV) ������������ ��������� � ��������� n ���
  * � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * ��� ���������� ��� ������ m ��� � ��� ������������ �������������
  * �������� (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION am_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER;

  /*
  * ���������� Axn (APV, ����������� ��������� ���������� ����������� ����� �� n ���) �� "1" ��������� �����
  * ��� �������� �������� ������� 2014
  * �������� ��������� ������� ��-�� ����� ����������, ��������� �� ���� �����������
  * @author ����� �., ����������� �.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */
  FUNCTION axn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

  /*
  * ���������� a_xn ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� ������� ��������� � ������� "1"
  * ��� �������� �������� ������� 2014
  * �������� ��������� ������� ��-�� ����� ����������, ��������� �� ���� �����������
  * @author ����� �., ����������� �.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */
  FUNCTION a_xn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER;

END pkg_amath;
/
CREATE OR REPLACE PACKAGE BODY pkg_amath IS
  --
  --����� "��������� ����������"
  --��������� �������� ��������� ����������

  gc_normrate_famdep_3    CONSTANT NUMBER := 0.05;
  gc_normrate_famdep_else CONSTANT NUMBER := 0.04;

  -- ����� �.
  -- ����� ���������� �� ������ � ����������� ������ ������� ��� ����� ���������� ����������
  -- �������� ��� �������, ������ ������ ������ � ������...
  gc_normrate_famdep2015_3    CONSTANT NUMBER := 0.1;
  gc_normrate_famdep2015_else CONSTANT NUMBER := 0.04;

  /**
  * ���������� a_n - ����������� ��������� (PV) ����������� / ������������������ ���������
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */
  FUNCTION a_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    IF p_i = 0
    THEN
      RESULT := n;
    ELSE
      RESULT := 1 / m * (1 - power(v, (n * m - 1) / m)) / (1 - power(v, 1 / m)); --������������
      IF isprenumerando = 0
      THEN
        RESULT := power(v, 1 / m) * RESULT; --postnumerando
      END IF;
    END IF;
    RETURN RESULT;
  END;

  /**
  * ���������� a_x - ����������� ��������� (PV) ����������� ����� �����������
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������  */

  FUNCTION a_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER DEFAULT 0;
    w      NUMBER;
    v      NUMBER;
    v_lx   NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex, k_koeff, s_koeff, p_table_id);
  
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. w
      LOOP
        RESULT := RESULT + power(v, j) * lx(x + j, p_sex, k_koeff, s_koeff, p_table_id) / v_lx;
      END LOOP;
    ELSE
      RESULT := NULL;
    END IF;
    RETURN RESULT;
  END;

  /**
  * ���������� a_xy - ����������� ��������� ���������� ������������ (������������)
  * ���������, �������������� �� "������ ������" ��� ���� ������� � �������� x � y ��������������
  * @author Marchuk A.
  * @param x - ������� ��������� ���������������
  * @param p_Sex_x - ��� ("m" / "w") ��������� ���������������
  * @param y - ������� ��������������� ���������������
  * @param m - ��������� ������ � ����
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������  */

  FUNCTION a_xy
  (
    x              IN NUMBER
   ,p_sex_x        IN VARCHAR2
   ,y              IN NUMBER
   ,p_sex_y        IN VARCHAR2
   ,m              IN NUMBER
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_lx   NUMBER;
    v_ly   NUMBER;
    v_dxy  NUMBER;
    v_nxy  NUMBER;
    v      NUMBER;
    w      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex_x, k_koeff, s_koeff, p_table_id);
    v_ly := lx(y, p_sex_y, k_koeff, s_koeff, p_table_id);
    --
    v_dxy := power(v, (x + y) / 2) * v_lx * v_ly;
    --
    FOR j IN 0 .. w
    LOOP
      v_lx  := lx(x + j, p_sex_x, k_koeff, s_koeff, p_table_id);
      v_ly  := lx(y + j, p_sex_y, k_koeff, s_koeff, p_table_id);
      v_nxy := v_nxy + power(v, (x + j + y + j) / 2) * v_lx * v_ly;
    END LOOP;
    RESULT := v_nxy / v_dxy - (m - 1) / (2 * m);
    RETURN RESULT;
  END;

  /**
  * ���������� n_a_x - ����������� �� n ��� ����������� �������� ����������� - ����������� �� ������ �������� �������� �����������
  * ��������� �������� ����������� ����� (������), ����������� �� n ��� ��� �������, ��� ������ ������� ������������ ����� n ���
  * ����� ������ �������� �������� ����������� � ������ ������� ���������� ����, ���� �������������� � ����� ������� ���
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION n_a_x
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER DEFAULT 0;
    w      NUMBER;
    v      NUMBER;
    v_lx   NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - (x)) INTO w FROM deathrate_d WHERE deathrate_id = p_table_id;
    --
    v_lx := lx(x, p_sex, k_koeff, s_koeff, p_table_id);
  
    IF isprenumerando = 1
    THEN
      FOR j IN (n) .. w
      LOOP
        RESULT := RESULT + power(v, j) * lx(x + j, p_sex, k_koeff, s_koeff, p_table_id) / v_lx;
      END LOOP;
    ELSE
      RESULT := NULL;
    END IF;
    RETURN RESULT;
  END;

  /**
  * ���������� s_n - ����������� ��������� ����������� / ������������������ ���������� � ��������� � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * @author Marchuk A.
  * @param n ���� ������
  * @param m - ����� ������ � ��� (1, 2, 4, 12) �� ��������� m = 1
  * @param IsPrenumerando - 1 �������� ������������ (������� � ������ ������� �������. 2- ������������� (� ����� �������) �� ��������� IsPrenumerando =1
  */

  FUNCTION s_n
  (
    n              IN NUMBER
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := a_n(n, m, isprenumerando, p_i) * power(1 + p_i, n);
    RETURN RESULT;
  END;

  /**
  * ���������� qx (���� qx "�����������" ��������������)
  * @author Marchuk A.
  * @param x - �������
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */
  --
  FUNCTION qx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 1 - px(x, p_sex, k_koeff, s_koeff, p_table_id);
    --dbms_output.put_line ('qx = '||result);
    RETURN RESULT;
  END;

  /**
  * ���������� px - ����������� ��� ���� �������� � ������ �� �������� x+1
  * @author Marchuk A.
  * @param x - �������
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */
  FUNCTION px
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER(16, 8);
  BEGIN
    SELECT (decode(p_sex, 'm', lx_m_next, 'w', lx_f_next)) / decode(p_sex, 'm', lx_m, 'w', lx_f)
      INTO RESULT
      FROM (SELECT age
                  ,decode(p_sex, 'm', lx_m, 'w', lx_f)
                  ,lx_m
                  ,lx_f
                  ,lead(lx_m) over(ORDER BY age) lx_m_next
                  ,lead(lx_f) over(ORDER BY age) lx_f_next
              FROM deathrate_d
             WHERE 1 = 1
               AND deathrate_d.age BETWEEN x AND (x + 1)
               AND deathrate_d.deathrate_id = p_table_id)
     WHERE 1 = 1
       AND age = x;
    --dbms_output.put_line ('px(��� ����. ����.) = '||result);
    RESULT := 1 - ((1 + k_koeff) * (1 - RESULT) + s_koeff);
    --dbms_output.put_line ('px = '||result);
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'No data found AMath.px () for age = ' || x);
    
  END px;

  /**
  * ���������� qxk (����������� ���� ��� ���� x ����� � ������� k ���)
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */
  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    IF k = 0
       OR k IS NULL
    THEN
      RESULT := 0;
    ELSE
      SELECT (decode(p_sex, 'm', lx_m, 'w', lx_f) -
             decode(p_sex, 'm', nvl(lx_m_next, 0), 'w', nvl(lx_f_next, 0))) /
             decode(p_sex, 'm', lx_m, 'w', lx_f)
        INTO RESULT
        FROM (SELECT age
                    ,decode(p_sex, 'm', lx_m, 'w', lx_f)
                    ,lx_m
                    ,lx_f
                    ,lead(lx_m) over(ORDER BY age) lx_m_next
                    ,lead(lx_f) over(ORDER BY age) lx_f_next
                FROM deathrate_d
               WHERE age IN (x, x + k)
                 AND deathrate_id = p_table_id)
       WHERE 1 = 1
         AND age = x;
    END IF;
    --dbms_output.put_line ('qxk = '||result);
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'AMath.qxk(): x is out of life table range');
    WHEN OTHERS THEN
      RAISE;
    
  END;

  /**
  * ���������� �������� nEx = p(x,n) * v^n ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */
  FUNCTION nex
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n);
    RETURN RESULT;
  END;

  /**
  * ���������� pxk ����������� ��� ���� �������� � ������ �� �������� x+k
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION pxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
  BEGIN
    p_xk := 1; --�������� p(x, 0)
    FOR j IN 0 .. (k - 1)
    LOOP
      --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RESULT := p_xk;
    --dbms_output.put_line ('pxk = '||result);
    RETURN RESULT;
  END;

  /**
  * ���������� qxk (����������� ���� ��� ���� x ����� � ������� k ���)
  * @author Marchuk A.
  * @param x - �������
  * @param k - ���������� ���
  * @param Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION qxk
  (
    x          IN NUMBER
   ,k          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    RESULT := 1 - pxk(x, k, p_sex, k_koeff, s_koeff, p_table_id);
    --dbms_output.put_line ('qxk = '||result);
    RETURN RESULT;
  END;

  /**
  * ���������� ���������� ������� ����������, ��������������� ����� ���, �������� �� �������� x
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  */

  FUNCTION lx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    minage NUMBER;
    RESULT NUMBER;
    l_pxk  NUMBER;
  BEGIN
    --
    SELECT decode(p_sex, 'm', lx_m, 'w', lx_f) lx
      INTO RESULT
      FROM deathrate_d
     WHERE 1 = 1
       AND age = x
       AND deathrate_d.deathrate_id = p_table_id;
    --
    IF NOT (k_koeff = 0 AND s_koeff = 0)
    THEN
      SELECT MIN(age) INTO minage FROM deathrate_d WHERE deathrate_id = p_table_id;
    
      SELECT decode(p_sex, 'm', lx_m, 'w', lx_f) lx
        INTO RESULT
        FROM deathrate_d
       WHERE 1 = 1
         AND age = minage
         AND deathrate_d.deathrate_id = p_table_id;
    
      FOR i IN (minage + 1) .. x
      LOOP
        l_pxk  := pxk(i - 1, 1, p_sex, k_koeff, s_koeff, p_table_id);
        RESULT := RESULT * l_pxk;
      END LOOP;
    END IF;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'AMath.Lx(): x is out of life table range ' || x);
    WHEN OTHERS THEN
      RAISE;
  END;

  /**
  * ���������� Dx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION dx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := power(v, x) * lx(x, p_sex, k_koeff, s_koeff, p_table_id);
    RETURN RESULT;
  END;

  /**
  * ���������� Nx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION nx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --���� �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    FOR j IN 0 .. n
    LOOP
      RESULT := RESULT + dx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * ���������� Cx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION cx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v_dx   NUMBER;
    v      NUMBER;
  BEGIN
    --dx = lx * qx
    v      := 1 / (1 + p_i);
    v_dx   := lx(x, p_sex, k_koeff, s_koeff, p_table_id) * qx(x, p_sex, k_koeff, s_koeff, p_table_id);
    RESULT := power(v, (x + 1)) * v_dx;
    RETURN RESULT;
  END;

  /**
  * ���������� Mx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION mx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER
   ,s_koeff    IN NUMBER
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    -- n = aTable.MaximumAge - x --���� �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    FOR j IN 0 .. n - 1
    LOOP
      --Cx ���������� �� �������� (MaximumAge - 1)
      RESULT := RESULT + cx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  --���������� Rx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  --��. ����������� � qxk_KS(...)
  --��������:  � �������� ����� ������������ ������������ �����������
  --�.�. ��� ������� ������������� ��� ������������� qx
  --
  --x - �������
  --Sex - ��� ("m" / "w")
  --K_koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  --S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  FUNCTION rx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --���� �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    -- Cx ���������� �� �������� (MaximumAge - 1)
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + (j + 1) * cx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * ���������� Sx (�������������� �������) ��� ���������� ("�����������") ������� ����������
  * @author Marchuk A.
  * @param x - �������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION sx
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge - x --���� �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    --  --Dx ���������� �� �������� (MaximumAge)
    FOR j IN 0 .. n
    LOOP
      RESULT := RESULT + (j + 1) * dx(x + j, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * ���������� Ax1n (APV, ����������� ��������� �������� ����������� ����� �� n ���) ��� ���������� ("�����������") ������� ���������� �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION ax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --�������� p(x, 0)
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      --  �������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
  
    RETURN RESULT;
  END;

  FUNCTION axt1nt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- ����������� ����� ���������� �� ��������� ���
  BEGIN
    --v := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --�������� p(x, 0)
    v_j    := 1;
    FOR j IN 0 .. (n - t - 1)
    LOOP
      IF (t + j) < 3
      THEN
        v   := 1 / (1 + gc_normrate_famdep_3);
        v_j := v_j * v; --* ����� ���������� �� j ���
      ELSE
        v   := 1 / (1 + gc_normrate_famdep_else);
        v_j := v_j * v; --* ����� ���������� �� j ���
      END IF;
      --*    Result := Result + p_xk * qx (x + j, p_Sex, K_koeff, S_koeff, p_table_id) * power (v , (j + 1));
      RESULT := RESULT + p_xk * qx(x + t + j, p_sex, k_koeff, s_koeff, p_table_id) * v_j;
    
      --  �������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
  
    RETURN RESULT;
  END axt1nt_famdep;

  /**
  * ���������� Axn1 (APV, ����������� ��������� ����������� �� ������� ������ n ���) ��� ���������� ("�����������") ������� ���������� �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION axn1
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n);
    RETURN RESULT;
  END;

  /**
  * ���������� IAx1n  - APV, ����������� ��������� �������� ����������� ����� �� n ��� � ������������ ��������� ������ (��� ������ � ������� m-�� ����, m<=n ������������� ��������� �����, ������ m)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION iax1n
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    --�������� p(x, 0)
    v      := 1 / (1 + p_i);
    p_xk   := 1;
    RESULT := 0;
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT +
                (j + 1) * p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * ���������� Axn (APV, ����������� ��������� ���������� ����������� ����� �� n ���) �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION axn
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    v      := 1 / (1 + p_i);
    RESULT := 0;
    --�������� p(x, 0)
    p_xk := 1;
    FOR j IN 0 .. (n - 1)
    LOOP
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      -- �������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    RESULT := RESULT + power(v, n) * p_xk;
    RETURN RESULT;
  END;

  FUNCTION axtnt_famdep
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,t          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- ����������� ����� ���������� �� ��������� ���
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    --v := 1 / (1 + p_i);
    RESULT := 0;
    --�������� p(x, 0)
    p_xk := 1;
    v_j  := 1;
    FOR j IN 0 .. (n - t - 1)
    LOOP
      IF (t + j) < 3
      THEN
        v   := 1 / (1 + gc_normrate_famdep_3);
        v_j := v_j * v; --* ����� ���������� �� j ���
      ELSE
        v   := 1 / (1 + gc_normrate_famdep_else);
        v_j := v_j * v; --* ����� ���������� �� j ���
      END IF;
      --*    Result := Result + p_xk * qx (x + j, p_sex, K_koeff, S_koeff, p_table_id) * power (v , (j + 1));
      RESULT := RESULT + p_xk * qx(x + t + j, p_sex, k_koeff, s_koeff, p_table_id) * v_j;
      -- �������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    --*  result := Result + power (v , n) * p_xk;
    RESULT := RESULT + v_j * p_xk;
    RETURN RESULT;
  END;

  /**
  * ���������� Ax (APV, ����������� ��������� ������������ �����������) �� "1" ��������� �����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION ax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --n = aTable.MaximumAge -  --���� ����������� - �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    RESULT := 0;
    --------------------------
    --For j = 0 To n - 1
    --   Result = Result + pxk(x, j, Sex) * qx(x + j, Sex) * v ^ (j + 1)
    --Next j
    --------------------------
    RESULT := axn(x, n, p_sex, k_koeff, s_koeff, p_table_id, p_i);
    ---------------------------
    RETURN RESULT;
  END;

  /**
  * ���������� IAx (APV, ����������� ��������� ������������ ����������� ���������) ��������� ����� ����� n � ����� n-�� ����
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION iax
  (
    x          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
   ,p_i        IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
    p_xk   NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    --
    SELECT (MAX(age) - x) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    -- n = aTable.MaximumAge - x --���� ����������� - �� ���������� �������� � ������� ����������
    -- --�������� p(x, 0)
    p_xk   := 1;
    RESULT := 0;
    FOR j IN 0 .. n - 1
    LOOP
      RESULT := RESULT +
                (j + 1) * p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * power(v, (j + 1));
      -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    RETURN RESULT;
  END;

  /**
  * ���������� a_xn ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� ������� ��������� � ������� "1"
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION a_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
  BEGIN
    v      := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --�������� p(x, 0)
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. (n - 1)
      LOOP
        RESULT := RESULT + p_xk * power(v, j);
        -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
        --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
      END LOOP;
    ELSIF isprenumerando = 0
    THEN
      FOR j IN 1 .. n
      LOOP
        -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk   := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
        RESULT := RESULT + p_xk * power(v, j);
      END LOOP;
    END IF;
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END;

  FUNCTION a_xtnt_famdep
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,t              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    p_xk   NUMBER;
    j      NUMBER;
    v      NUMBER;
    v_j    NUMBER; -- ����������� ����� ���������� �� ��������� ���
    temp1  NUMBER;
    temp2  NUMBER;
  BEGIN
    --  v := 1 / (1 + p_i);
    RESULT := 0;
    p_xk   := 1; --�������� p(x, 0)
    v_j    := 1;
    IF isprenumerando = 1
    THEN
      FOR j IN 0 .. (n - t - 1)
      LOOP
        temp1 := power(v, j);
        temp2 := p_xk * v_j;
        --*      Result := Result + p_xk * power (v , j);
        RESULT := RESULT + p_xk * v_j;
        -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
        --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
        IF (t + j) < 3
        THEN
          v   := 1 / (1 + gc_normrate_famdep_3);
          v_j := v_j * v; --* ����� ���������� �� j ���
        ELSE
          v   := 1 / (1 + gc_normrate_famdep_else);
          v_j := v_j * v; --* ����� ���������� �� j ���
        END IF;
      END LOOP;
    ELSIF isprenumerando = 0
    THEN
      FOR j IN 1 .. (n - t)
      LOOP
        IF (t + j) <= 3
        THEN
          v   := 1 / (1 + gc_normrate_famdep_3);
          v_j := v_j * v; --* ����� ���������� �� j ���
        ELSE
          v   := 1 / (1 + gc_normrate_famdep_else);
          v_j := v_j * v; --* ����� ���������� �� j ���
        END IF;
        -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
        p_xk := p_xk * px(x + t + j, p_sex, k_koeff, s_koeff, p_table_id);
        --*      Result := Result + p_xk * power (v , j);
        RESULT := RESULT + p_xk * v_j;
      END LOOP;
    END IF;
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END;

  /**
  * ���������� am_xn - ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * ��� ���������� ��� ������ m ��� � ��� ������������ ������������� �������� (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION am_xn
  (
    x              IN NUMBER
   ,n              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    v      NUMBER;
  BEGIN
    v := 1 / (1 + p_i);
    IF isprenumerando = 1
    THEN
      RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, 1, p_table_id, p_i) -
                (m - 1) / (2 * m) * (1 - pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n));
    ELSE
      RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, 0, p_table_id, p_i) +
                (m - 1) / (2 * m) * (1 - pxk(x, n, p_sex, k_koeff, s_koeff, p_table_id) * power(v, n));
    END IF;
    RETURN RESULT;
  END;

  /**
  * ���������� am_x ����������� ��������� (APV) ������������ ��������� � ��������� n ���
  * � ������� "1" � ��� (��� �������� m ��� � ��� ������ ������ ������� 1/m)
  * ��� ���������� ��� ������ m ��� � ��� ������������ �������������
  * �������� (Woolhouse formula, TFA, Vol 37, p.63)
  * @author Marchuk A.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION am_x
  (
    x              IN NUMBER
   ,p_sex          IN VARCHAR2
   ,k_koeff        IN NUMBER DEFAULT 0
   ,s_koeff        IN NUMBER DEFAULT 0
   ,m              IN NUMBER DEFAULT 1
   ,isprenumerando IN NUMBER DEFAULT 1
   ,p_table_id     IN NUMBER
   ,p_i            IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    n      NUMBER;
    j      NUMBER;
  BEGIN
    --  n = aTable.MaximumAge - x --����  - �� ���������� �������� � ������� ����������
    SELECT (MAX(age) - (x + 1)) INTO n FROM deathrate_d WHERE deathrate_id = p_table_id;
    --����������� �������� �������������, ������� ��������
    RESULT := a_xn(x, n, p_sex, k_koeff, s_koeff, isprenumerando, p_table_id, p_i);
    IF isprenumerando = 1
    THEN
      RESULT := RESULT + (m + 1) / (2 * m);
    ELSE
      RESULT := RESULT + (m - 1) / (2 * m);
    END IF;
    RETURN RESULT;
  END;

  /*
  * ���������� Axn (APV, ����������� ��������� ���������� ����������� ����� �� n ���) �� "1" ��������� �����
  * ��� �������� �������� ������� 2014
  * �������� ��������� ������� ��-�� ����� ����������, ��������� �� ���� �����������
  * @author ����� �., ����������� �.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */
  FUNCTION axn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT     NUMBER;
    p_xk       NUMBER;
    j          NUMBER;
    v_normrate NUMBER;
    v          NUMBER; -- ����������� �� ����� ���������� �� ������� ��� 1/(1+ normrate)
    d_1        NUMBER; --� �����  �������� 1/D
    vj         NUMBER := 1; -- ������������ ������������ v
  BEGIN
    --dbms_output.put_line (' x='||x||' n='||n||' p_sex= '||p_Sex||' p_table_id='||p_table_id);
    --  v := 1 / (1 + p_i);
    RESULT := 0;
    --�������� p(x, 0)
    p_xk := 1;
    FOR j IN 0 .. (n - 1)
    LOOP
      IF j < 3
      THEN
        v_normrate := gc_normrate_famdep2015_3;
      
      ELSE
        v_normrate := gc_normrate_famdep2015_else;
      END IF;
      v      := 1 / (1 + v_normrate);
      d_1    := v_normrate / ln(1 + v_normrate);
      vj     := vj * v;
      RESULT := RESULT + p_xk * qx(x + j, p_sex, k_koeff, s_koeff, p_table_id) * vj * d_1;
      -- �������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
    END LOOP;
    -- now Result = Ax1n
    -- Set Axn = Ax1n + v^n* p(x, n)
    RESULT := RESULT + vj * p_xk;
    RETURN RESULT;
  END axn_famdep2014;

  /*
  * ���������� a_xn ����������� ��������� (APV) �������� ���������� ��������� � ��������� n ��� ������� ��������� � ������� "1"
  * ��� �������� �������� ������� 2014
  * �������� ��������� ������� ��-�� ����� ����������, ��������� �� ���� �����������
  * @author ����� �., ����������� �.
  * @param x - �������
  * @param n - ���� �����������
  * @param p_Sex - ��� ("m" / "w")
  * @param _koeff - ����� � ����� �������, �.�., ��������, ��� 50% K_koeff = 0.50
  * @param S_koeff - ����� � ����� �������, �.�., ��������, ��� 1 �������� S_koeff = 0.001
  * @param p_table_id - �� ������������ ������� ���������� �� ����������� ����. ������
  * @param p_i- ����������� ����� ����������
  */

  FUNCTION a_xn_famdep2014
  (
    x          IN NUMBER
   ,n          IN NUMBER
   ,p_sex      IN VARCHAR2
   ,k_koeff    IN NUMBER DEFAULT 0
   ,s_koeff    IN NUMBER DEFAULT 0
   ,p_table_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT     NUMBER;
    p_xk       NUMBER;
    j          NUMBER;
    vj         NUMBER := 1;
    v_normrate NUMBER;
  BEGIN
    RESULT := 0;
    p_xk   := 1; --�������� p(x, 0)
  
    FOR j IN 0 .. (n - 1)
    LOOP
      IF j < 3
      THEN
        v_normrate := gc_normrate_famdep2015_3;
      ELSE
        v_normrate := gc_normrate_famdep2015_else;
      END IF;
    
      RESULT := RESULT + p_xk * vj;
      vj     := vj / (1 + v_normrate);
      -- --�������� p(x, k + 1) = p(x, k) * p(x + k, 1)
      p_xk := p_xk * px(x + j, p_sex, k_koeff, s_koeff, p_table_id);
      --     dbms_output.put_line ('Result='||Result||'j= '||j||' p_xk '||p_xk);
    END LOOP;
  
    --dbms_output.put_line ('a_xn = '||Result);
    RETURN RESULT;
  END a_xn_famdep2014;

END;
/

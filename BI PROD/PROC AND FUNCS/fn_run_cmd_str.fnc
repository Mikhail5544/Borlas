create or replace function fn_run_cmd_str(p_cmd in varchar2) return varchar2 as
  -- ���������� ������� �� � ��������� ������
  language java name 'Util2.RunThisStr(java.lang.String) return varchar2';
/


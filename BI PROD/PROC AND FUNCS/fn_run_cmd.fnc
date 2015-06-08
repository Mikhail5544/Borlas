create or replace function fn_run_cmd(p_cmd in varchar2) return number as
  language java name 'Util.RunThis(java.lang.String) return integer';
/


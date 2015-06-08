create or replace package pkg_csrep is

  -- Author  : KALABUKHOV
  -- Created : 08.01.2007 20:46:35
  -- Purpose : Пакет поддержки общесистемных отчетов
  
   function policy_pay(p_pol_header_id in number) return number;

end pkg_csrep;
/

CREATE OR REPLACE PACKAGE PKG_AG_PLAN_MONTHS IS
  FUNCTION RegDirector
  (
    p_ag_contract_header NUMBER
   ,p_number_month       NUMBER
  ) RETURN NUMBER;
END PKG_AG_PLAN_MONTHS;
/
CREATE OR REPLACE PACKAGE BODY PKG_AG_PLAN_MONTHS IS

  FUNCTION RegDirector
  (
    p_ag_contract_header NUMBER
   ,p_number_month       NUMBER
  ) RETURN NUMBER IS
  
  BEGIN
    RETURN 0;
  END RegDirector;

END PKG_AG_PLAN_MONTHS;
/

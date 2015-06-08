CREATE OR REPLACE PACKAGE pkg_period IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 10.07.2014 16:53:55
  -- Purpose : Работа с периодами

  TYPE t_period_info IS RECORD(
     period      t_period%ROWTYPE
    ,period_type t_period_type%ROWTYPE);

  FUNCTION get_period_info(par_period_id t_period.id%TYPE) RETURN t_period_info;

  FUNCTION add_period
  (
    par_value             t_period.period_value%TYPE
   ,par_period_type_brief t_period_type.brief%TYPE
   ,par_date              DATE
   ,par_times             INTEGER DEFAULT 1
  ) RETURN DATE;

  FUNCTION add_period
  (
    par_period_info t_period_info
   ,par_date        DATE
   ,par_times       INTEGER DEFAULT 1
  ) RETURN DATE;

  FUNCTION add_period
  (
    par_period_id t_period.id%TYPE
   ,par_date      DATE
   ,par_times     INTEGER DEFAULT 1
  ) RETURN DATE;

END pkg_period;
/
CREATE OR REPLACE PACKAGE BODY pkg_period IS

  FUNCTION get_period_info(par_period_id t_period.id%TYPE) RETURN t_period_info IS
    vr_result t_period_info;
  BEGIN
    vr_result.period      := dml_t_period.get_record(par_period_id);
    vr_result.period_type := dml_t_period_type.get_record(vr_result.period.period_type_id);
    RETURN vr_result;
  END get_period_info;

  FUNCTION add_period
  (
    par_value             t_period.period_value%TYPE
   ,par_period_type_brief t_period_type.brief%TYPE
   ,par_date              DATE
   ,par_times             INTEGER DEFAULT 1
  ) RETURN DATE IS
    v_times  INTEGER := nvl(par_times, 1);
    v_result DATE;
  BEGIN
    CASE par_period_type_brief
      WHEN 'D' THEN
        v_result := par_date + par_value;
      WHEN 'M' THEN
        v_result := ADD_MONTHS(par_date, par_value * v_times);
      WHEN 'Q' THEN
        v_result := ADD_MONTHS(par_date, par_value * 3 * v_times);
      WHEN 'Y' THEN
        v_result := ADD_MONTHS(par_date, par_value * 12 * v_times);
      WHEN 'NO' THEN
        v_result := par_date;
      ELSE
        ex.raise('Тип периода с кратким названием "' || nvl(par_period_type_brief, 'null') ||
                 '" не предусмотрен');
    END CASE;
    RETURN v_result;
  END add_period;

  FUNCTION add_period
  (
    par_period_info t_period_info
   ,par_date        DATE
   ,par_times       INTEGER DEFAULT 1
  ) RETURN DATE IS
    v_result DATE;
  BEGIN
    v_result := add_period(par_value             => par_period_info.period.period_value
                          ,par_period_type_brief => par_period_info.period_type.brief
                          ,par_date              => par_date);
    RETURN v_result;
  END add_period;

  FUNCTION add_period
  (
    par_period_id t_period.id%TYPE
   ,par_date      DATE
   ,par_times     INTEGER DEFAULT 1
  ) RETURN DATE IS
    v_result       DATE;
    vr_period_info t_period_info;
  BEGIN
    vr_period_info := get_period_info(par_period_id => par_period_id);
    v_result       := add_period(par_period_info => vr_period_info, par_date => par_date);
    RETURN v_result;
  END add_period;
END pkg_period;
/

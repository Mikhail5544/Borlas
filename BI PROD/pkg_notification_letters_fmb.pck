CREATE OR REPLACE PACKAGE pkg_notification_letters_fmb IS

  -- Author  : VESELEK
  -- Created : 14.11.2013 10:58:56
  -- Purpose : ¬спомогательный пакет дл€ работы с формой NOTIFICATION_LETTERS

  PROCEDURE set_parameter_value
  (
    par_date_from DATE
   ,par_date_to   DATE
  );

  FUNCTION get_date_from RETURN DATE;
  FUNCTION get_date_to RETURN DATE;

END pkg_notification_letters_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_notification_letters_fmb IS

  gv_par_date_from DATE := to_date('01.01.2010', 'dd.mm.yyyy');
  gv_par_date_to   DATE := to_date('01.01.2013', 'dd.mm.yyyy');

  PROCEDURE set_parameter_value
  (
    par_date_from DATE
   ,par_date_to   DATE
  ) IS
  BEGIN
    gv_par_date_from := par_date_from;
    gv_par_date_to   := par_date_to;
  END set_parameter_value;

  FUNCTION get_date_from RETURN DATE IS
  BEGIN
    RETURN gv_par_date_from;
  END get_date_from;

  FUNCTION get_date_to RETURN DATE IS
  BEGIN
    RETURN gv_par_date_to;
  END get_date_to;

END pkg_notification_letters_fmb;
/

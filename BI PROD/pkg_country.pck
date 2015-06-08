CREATE OR REPLACE PACKAGE pkg_country IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 19.11.2013 13:06:51
  -- Purpose : Пакет для работы с справочником стран

  FUNCTION get_country_id_by_desc(par_country_desctiption VARCHAR2) RETURN t_country.id%TYPE;
  FUNCTION get_country_id_by_alpha2(par_country_alpha2 VARCHAR2) RETURN t_country.id%TYPE;
  FUNCTION get_country_id_by_alpha3(par_country_alpha3 VARCHAR2) RETURN t_country.id%TYPE;
  FUNCTION get_country_id_by_code(par_country_code NUMBER) RETURN t_country.id%TYPE;

  FUNCTION get_country_description(par_country_id t_country.id%TYPE) RETURN t_country.description%TYPE;

END pkg_country;
/
CREATE OR REPLACE PACKAGE BODY pkg_country IS

  FUNCTION get_country_id_by_desc(par_country_desctiption VARCHAR2) RETURN t_country.id%TYPE IS
    v_country_id t_country.id%TYPE;
  BEGIN
    SELECT id
      INTO v_country_id
      FROM t_country c
     WHERE upper(c.description) = upper(TRIM(par_country_desctiption));
    RETURN v_country_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить страну по названию: ' ||
                              nvl(par_country_desctiption, 'NULL'));
  END get_country_id_by_desc;

  FUNCTION get_country_id_by_alpha2(par_country_alpha2 VARCHAR2) RETURN t_country.id%TYPE IS
    v_country_id t_country.id%TYPE;
  BEGIN
    SELECT id INTO v_country_id FROM t_country c WHERE c.alfa2 = upper(TRIM(par_country_alpha2));
    RETURN v_country_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить страну по коду Альфа-2: ' ||
                              nvl(par_country_alpha2, 'NULL'));
  END get_country_id_by_alpha2;

  FUNCTION get_country_id_by_alpha3(par_country_alpha3 VARCHAR2) RETURN t_country.id%TYPE IS
    v_country_id t_country.id%TYPE;
  BEGIN
    SELECT id INTO v_country_id FROM t_country c WHERE c.alfa3 = upper(TRIM(par_country_alpha3));
    RETURN v_country_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить страну по коду Альфа-3: ' ||
                              nvl(par_country_alpha3, 'NULL'));
  END get_country_id_by_alpha3;

  FUNCTION get_country_id_by_code(par_country_code NUMBER) RETURN t_country.id%TYPE IS
    v_country_id t_country.id%TYPE;
  BEGIN
    SELECT id INTO v_country_id FROM t_country c WHERE c.country_code = par_country_code;
    RETURN v_country_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось определить страну по коду: ' || par_country_code);
  END get_country_id_by_code;

  FUNCTION get_country_description(par_country_id t_country.id%TYPE) RETURN t_country.description%TYPE IS
    v_country_description t_country.description%TYPE;
  BEGIN
    SELECT description INTO v_country_description FROM t_country c WHERE c.id = par_country_id;
    RETURN v_country_description;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, 'Не удалось определить страну по ID');
  END get_country_description;

BEGIN
  -- Initialization
  NULL;
END pkg_country;
/

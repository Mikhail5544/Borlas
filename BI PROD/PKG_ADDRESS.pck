CREATE OR REPLACE PACKAGE pkg_address IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 01.04.2013 18:06:52
  -- Purpose : Пакет для работы с адресами

  /*
  Капля П.с.
  Добавление адреса в справочник адресов
  */
  FUNCTION insert_adress
  (
    p_address    VARCHAR2
   ,p_country_id NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE update_address
  (
    p_address_id NUMBER
   ,p_address    VARCHAR2
   ,p_country_id NUMBER DEFAULT NULL
  );

END pkg_address;
/
CREATE OR REPLACE PACKAGE BODY pkg_address IS

  FUNCTION insert_adress
  (
    p_address    VARCHAR2
   ,p_country_id NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_country_id NUMBER;
    v_address_id NUMBER;
  BEGIN
    IF p_country_id IS NULL
    THEN
      BEGIN
        SELECT id INTO v_country_id FROM t_country WHERE is_default = 1;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20100, 'Не задана страна по-умолчанию');
        WHEN too_many_rows THEN
          raise_application_error(-20100
                                 ,'Задано более одной страны по-умолчанию');
      END;
    ELSE
      BEGIN
        SELECT id INTO v_country_id FROM t_country c WHERE c.id = p_country_id;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001, 'Указана неверная страна');
      END;
    END IF;
  
    INSERT INTO cn_address ca
      (ca.id, ca.country_id, ca.name, ca.decompos_permis)
    VALUES
      (sq_cn_address.nextval, v_country_id, p_address, 0)
    RETURNING id INTO v_address_id;
  
    RETURN v_address_id;
  END;

  PROCEDURE update_address
  (
    p_address_id NUMBER
   ,p_address    VARCHAR2
   ,p_country_id NUMBER DEFAULT NULL
  ) IS
  BEGIN
    UPDATE ins.cn_address c
       SET c.country_id          = nvl(p_country_id, c.country_id)
          ,c.name                = p_address
          ,c.decompos_permis     = 0
          ,c.decompos_date       = NULL
          ,c.street_name         = NULL
          ,c.street_type         = NULL
          ,c.code                = NULL
          ,c.zip                 = NULL
          ,c.district_type       = NULL
          ,c.district_name       = NULL
          ,c.region_type         = NULL
          ,c.region_name         = NULL
          ,c.province_type       = NULL
          ,c.province_name       = NULL
          ,c.city_type           = NULL
          ,c.city_name           = NULL
          ,c.appartment_nr       = NULL
          ,c.house_nr            = NULL
          ,c.house_type          = NULL
          ,c.actual              = 0
          ,c.code_kladr_province = NULL
          ,c.code_kladr_region   = NULL
          ,c.code_kladr_city     = NULL
          ,c.code_kladr_distr    = NULL
          ,c.code_kladr_street   = NULL
          ,c.code_kladr_doma     = NULL
          ,c.index_province      = NULL
          ,c.index_region        = NULL
          ,c.index_city          = NULL
          ,c.index_distr         = NULL
          ,c.index_street        = NULL
          ,c.index_doma          = NULL
     WHERE c.id = p_address_id
       AND (TRIM(c.name) != TRIM(p_address) OR (TRIM(c.name) IS NULL AND TRIM(p_address) IS NOT NULL));
    IF SQL%ROWCOUNT != 0
    THEN
      UPDATE ins.cn_address c
         SET c.country_id          = nvl(p_country_id, c.country_id)
            ,c.name                = p_address
            ,c.decompos_permis     = 0
            ,c.decompos_date       = NULL
            ,c.street_name         = NULL
            ,c.street_type         = NULL
            ,c.code                = NULL
            ,c.zip                 = NULL
            ,c.district_type       = NULL
            ,c.district_name       = NULL
            ,c.region_type         = NULL
            ,c.region_name         = NULL
            ,c.province_type       = NULL
            ,c.province_name       = NULL
            ,c.city_type           = NULL
            ,c.city_name           = NULL
            ,c.appartment_nr       = NULL
            ,c.house_nr            = NULL
            ,c.house_type          = NULL
            ,c.actual              = 0
            ,c.code_kladr_province = NULL
            ,c.code_kladr_region   = NULL
            ,c.code_kladr_city     = NULL
            ,c.code_kladr_distr    = NULL
            ,c.code_kladr_street   = NULL
            ,c.code_kladr_doma     = NULL
            ,c.index_province      = NULL
            ,c.index_region        = NULL
            ,c.index_city          = NULL
            ,c.index_distr         = NULL
            ,c.index_street        = NULL
            ,c.index_doma          = NULL
       WHERE c.parent_addr_id = p_address_id;
    END IF;
  END;

END pkg_address;
/

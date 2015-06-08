CREATE OR REPLACE PACKAGE pkg_entity_address IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 02.08.2011 13:37:44
  -- Purpose : Управление адресами сущностей

  /*
    Байтин А.
    Копирование адреса
  */
  PROCEDURE copy_address
  (
    par_address_id     NUMBER
   ,par_new_address_id OUT NUMBER
  );

  /*
    Байтин А.
    Удаление адреса
  */
  PROCEDURE delete_address(par_address_id NUMBER);

  /*
    Байтин А.
    Добавляет/исправляет адрес
  */
  PROCEDURE modify_address
  (
    par_country_id    NUMBER
   ,par_province_type VARCHAR2
   ,par_province_name VARCHAR2
   ,par_region_type   VARCHAR2
   ,par_region_name   VARCHAR2
   ,par_city_type     VARCHAR2
   ,par_city_name     VARCHAR2
   ,par_district_type VARCHAR2
   ,par_district_name VARCHAR2
   ,par_street_type   VARCHAR2
   ,par_street_name   VARCHAR2
   ,par_zip           VARCHAR2
   ,par_house_number  VARCHAR2
   ,par_block_number  VARCHAR2
   ,par_appartment_nr VARCHAR2
   ,par_address_id    IN OUT NUMBER
  );

  /*
    Байтин А.
    Связывает сущность с существующим адресом
  */
  PROCEDURE link_entity_to_address
  (
    par_ure_id            NUMBER
   ,par_uro_id            NUMBER
   ,par_address_id        NUMBER
   ,par_entity_address_id OUT NUMBER
  );

  FUNCTION get_address_name
  (
    zip                VARCHAR2
   ,country_name       VARCHAR2
   ,region_name        VARCHAR2
   ,region_type_name   VARCHAR2
   ,province_name      VARCHAR2
   ,province_type_name VARCHAR2
   ,district_type_name VARCHAR2
   ,district_name      VARCHAR2
   ,city_type_name     VARCHAR2
   ,city_name          VARCHAR2
   ,street_name        VARCHAR2
   ,street_type_name   VARCHAR2
   ,building_name      VARCHAR2
   ,house_nr           VARCHAR2
   ,house_type         VARCHAR2
   ,block_number       VARCHAR2
   ,box_number         VARCHAR2
   ,appartment_nr      VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_address_name(p_id NUMBER) RETURN VARCHAR2;
END pkg_entity_address;
/
CREATE OR REPLACE PACKAGE BODY pkg_entity_address IS
  /*
    Байтин А.
    Копирование адреса
  */
  PROCEDURE copy_address
  (
    par_address_id     NUMBER
   ,par_new_address_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_cn_address.nextval INTO par_new_address_id FROM dual;
  
    INSERT INTO ven_cn_address ad
      (id
      ,ent_id
      ,filial_id
      ,ext_id
      ,appartment_nr
      ,block_number
      ,box_number
      ,building_name
      ,city_name
      ,city_type
      ,country_id
      ,district_name
      ,district_type
      ,guid
      ,house_nr
      ,NAME
      ,pob
      ,province_name
      ,province_type
      ,region_name
      ,region_type
      ,remarks
      ,street_name
      ,street_type
      ,zip
      ,code
      ,code_kladr_city
      ,code_kladr_distr
      ,code_kladr_doma
      ,code_kladr_province
      ,code_kladr_region
      ,code_kladr_street
      ,decompos_date
      ,decompos_permis
      ,house_type
      ,index_city
      ,index_distr
      ,index_doma
      ,index_province
      ,index_region
      ,index_street)
      SELECT par_new_address_id
            ,ent_id
            ,filial_id
            ,ext_id
            ,appartment_nr
            ,block_number
            ,box_number
            ,building_name
            ,city_name
            ,city_type
            ,country_id
            ,district_name
            ,district_type
            ,guid
            ,house_nr
            ,NAME
            ,pob
            ,province_name
            ,province_type
            ,region_name
            ,region_type
            ,remarks
            ,street_name
            ,street_type
            ,zip
            ,code
            ,code_kladr_city
            ,code_kladr_distr
            ,code_kladr_doma
            ,code_kladr_province
            ,code_kladr_region
            ,code_kladr_street
            ,decompos_date
            ,decompos_permis
            ,house_type
            ,index_city
            ,index_distr
            ,index_doma
            ,index_province
            ,index_region
            ,index_street
        FROM ven_cn_address ad
       WHERE ad.id = par_address_id;
  END copy_address;

  /*
    Байтин А.
    Удаление адреса
  */
  PROCEDURE delete_address(par_address_id NUMBER) IS
  BEGIN
    IF par_address_id IS NOT NULL
    THEN
      DELETE FROM ven_cn_entity_address ea WHERE ea.address_id = par_address_id;
      DELETE FROM cn_address WHERE id = par_address_id;
    END IF;
  END delete_address;
  /*
    Байтин А.
    Добавляет/исправляет адрес сущности
  
  */
  PROCEDURE modify_address
  (
    par_country_id    NUMBER
   ,par_province_type VARCHAR2
   ,par_province_name VARCHAR2
   ,par_region_type   VARCHAR2
   ,par_region_name   VARCHAR2
   ,par_city_type     VARCHAR2
   ,par_city_name     VARCHAR2
   ,par_district_type VARCHAR2
   ,par_district_name VARCHAR2
   ,par_street_type   VARCHAR2
   ,par_street_name   VARCHAR2
   ,par_zip           VARCHAR2
   ,par_house_number  VARCHAR2
   ,par_block_number  VARCHAR2
   ,par_appartment_nr VARCHAR2
   ,par_address_id    IN OUT NUMBER
  ) IS
  BEGIN
    IF par_address_id IS NULL
    THEN
      SELECT sq_cn_address.nextval INTO par_address_id FROM dual;
    
      INSERT INTO cn_address
        (id
        ,country_id
        ,province_type
        ,province_name
        ,region_type
        ,region_name
        ,city_type
        ,city_name
        ,district_type
        ,district_name
        ,street_type
        ,street_name
        ,zip
        ,house_nr
        ,block_number
        ,appartment_nr)
      VALUES
        (par_address_id
        ,par_country_id
        ,par_province_type
        ,par_province_name
        ,par_region_type
        ,par_region_name
        ,par_city_type
        ,par_city_name
        ,par_district_type
        ,par_district_name
        ,par_street_type
        ,par_street_name
        ,par_zip
        ,par_house_number
        ,par_block_number
        ,par_appartment_nr);
    ELSIF par_address_id IS NOT NULL
    THEN
      UPDATE cn_address
         SET zip           = par_zip
            ,country_id    = par_country_id
            ,city_type     = par_city_type
            ,street_name   = par_street_name
            ,house_nr      = par_house_number
            ,appartment_nr = par_appartment_nr
            ,street_type   = par_street_type
            ,province_type = par_province_type
            ,province_name = par_province_name
            ,city_name     = par_city_name
            ,district_type = par_district_type
            ,district_name = par_district_name
            ,region_type   = par_region_type
            ,region_name   = par_region_name
            ,block_number  = par_block_number
       WHERE id = par_address_id;
    END IF;
  END modify_address;

  /*
    Байтин А.
    Связывает сущность с существующим адресом
  */
  PROCEDURE link_entity_to_address
  (
    par_ure_id            NUMBER
   ,par_uro_id            NUMBER
   ,par_address_id        NUMBER
   ,par_entity_address_id OUT NUMBER
  ) IS
    v_address_type_id NUMBER;
    v_cnt             NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_cn_entity_address ea
             WHERE ea.ure_id = par_ure_id
               AND ea.uro_id = par_uro_id
               AND ea.address_id = par_address_id);
    IF v_cnt = 0
    THEN
      ents.uref_ins(p_ent_id => par_ure_id, p_obj_id => par_uro_id);
    
      SELECT ta.id INTO v_address_type_id FROM t_address_type ta WHERE ta.is_default = 1;
    
      SELECT sq_cn_entity_address.nextval INTO par_entity_address_id FROM dual;
    
      INSERT INTO ven_cn_entity_address
        (cn_entity_address_id, address_id, ure_id, uro_id, is_default, address_type_id)
      VALUES
        (par_entity_address_id, par_address_id, par_ure_id, par_uro_id, 0, v_address_type_id);
    END IF;
  END link_entity_to_address;
  /*
  procedure set_default
  (
  
  )
  is
  begin
    
  end set_default;
  
  function get_default
  (
  
  )
  return number
  is
  begin
    
  end get_default;*/

  FUNCTION get_address_name
  (
    zip                VARCHAR2
   ,country_name       VARCHAR2
   ,region_name        VARCHAR2
   ,region_type_name   VARCHAR2
   ,province_name      VARCHAR2
   ,province_type_name VARCHAR2
   ,district_type_name VARCHAR2
   ,district_name      VARCHAR2
   ,city_type_name     VARCHAR2
   ,city_name          VARCHAR2
   ,street_name        VARCHAR2
   ,street_type_name   VARCHAR2
   ,building_name      VARCHAR2
   ,house_nr           VARCHAR2
   ,house_type         VARCHAR2
   ,block_number       VARCHAR2
   ,box_number         VARCHAR2
   ,appartment_nr      VARCHAR2
  ) RETURN VARCHAR2 IS
    ret_val VARCHAR2(4000);
  BEGIN
    ret_val := ret_val || country_name || ',';
  
    IF zip IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || zip || ',';
    END IF;
  
    IF province_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      IF province_type_name IS NOT NULL
      THEN
        ret_val := ret_val || province_name || ' ' || province_type_name;
      ELSE
        ret_val := ret_val || province_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF region_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || region_name;
      IF region_type_name IS NOT NULL
      THEN
        ret_val := ret_val || ' ' || region_type_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF district_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || district_name;
      IF district_type_name IS NOT NULL
      THEN
        ret_val := ret_val || ' ' || district_type_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF city_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || city_name;
      IF city_type_name IS NOT NULL
      THEN
        ret_val := ret_val || ' ' || city_type_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF street_name IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || street_name;
      IF street_type_name IS NOT NULL
      THEN
        ret_val := ret_val || ' ' || street_type_name;
      END IF;
      ret_val := ret_val || ',';
    END IF;
  
    IF house_nr IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || nvl(house_type || ' ', 'д ') || house_nr || ',';
    END IF;
  
    IF block_number IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || block_number || ',';
    END IF;
  
    IF appartment_nr IS NOT NULL
    THEN
      ret_val := ret_val || ' ';
      ret_val := ret_val || 'кв./оф.' || appartment_nr || ',';
    END IF;
  
    ret_val := rtrim(ret_val, ',');
    RETURN ret_val;
  END;

  FUNCTION get_address_name(v_adr v_cn_address%ROWTYPE) RETURN VARCHAR2 IS
  BEGIN
  
    RETURN coalesce(v_adr.name
                   ,get_address_name(zip                => v_adr.zip
                                    ,country_name       => v_adr.country_name
                                    ,region_name        => v_adr.region_name
                                    ,region_type_name   => v_adr.region_type
                                    ,province_name      => v_adr.province_name
                                    ,province_type_name => v_adr.province_type
                                    ,district_type_name => v_adr.district_type
                                    ,district_name      => v_adr.district_name
                                    ,city_type_name     => v_adr.city_type
                                    ,city_name          => v_adr.city_name
                                    ,street_name        => v_adr.street_name
                                    ,street_type_name   => v_adr.street_type
                                    ,building_name      => v_adr.building_name
                                    ,house_nr           => v_adr.house_nr
                                    ,house_type         => v_adr.house_type
                                    ,block_number       => v_adr.block_number
                                    ,box_number         => v_adr.box_number
                                    ,appartment_nr      => v_adr.appartment_nr));
  END;

  FUNCTION get_address_name(p_id NUMBER) RETURN VARCHAR2 IS
    v_adr v_cn_address%ROWTYPE;
  BEGIN
    SELECT * INTO v_adr FROM v_cn_address v WHERE v.id = p_id;
    RETURN get_address_name(v_adr);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
END pkg_entity_address;
/

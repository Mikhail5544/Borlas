CREATE OR REPLACE PACKAGE pkg_dms_vacation AS

  /**
  * Функция создания новой вакансии
  * @author Сыровецкий Д.
  * @param p_prod_line_dms_id - ИД варианта
  * @return ИД созданного объекта страхования
  */
  FUNCTION create_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER;

  /**
  * Функция возвращает допустимое кол-во объектов страхования
  * @author Сыровецкий Д.
  * @param p_prod_line_dms_id - ИД варианта
  * @param flg_check_policy - флаг проверки по отношению к полису
  * @return Количество допустимых вакансий
  */
  FUNCTION check_vacation
  (
    p_prod_line_dms_id NUMBER
   ,flg_check_policy   NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Процедура удаления вакансий
  * @author Сыровецкий Д.
  * @param p_prod_line_dms_id - ИД варианта
  */
  PROCEDURE del_vacation(p_prod_line_dms_id NUMBER);

  /**
  * Функиция возвращает кол-во существующих вакансий по варианту
  * @param p_prod_line_dms_id - ИД варианта
  * @return Кол-во вакансий
  */
  FUNCTION get_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER;

  /**
  * Функиция возвращает кол-во реальных застрахованных по варианту
  * @param p_prod_line_dms_id - ИД варианта
  * @return Кол-во застрахованных
  */
  FUNCTION get_real_assured(p_prod_line_dms_id NUMBER) RETURN NUMBER;

  /**
  * Функиция возвращает заданное максимальное кол-во застрахванных
  * @param p_prod_line_dms_id - ИД варианта
  * @return Кол-во застрахованных
  */
  FUNCTION get_max_assured(p_prod_line_dms_id NUMBER) RETURN NUMBER;

  /**
  * Функиция возвращает кол-во загружаемых застрахованных
  * @param p_prod_line_dms_id - ИД варианта
  * @parma p_session_id - ИД сессии 
  * @return Кол-во вакансий
  */
  FUNCTION get_load_assured
  (
    p_prod_line_dms_id NUMBER
   ,p_session_id       NUMBER
  ) RETURN NUMBER;

  /**
  * Функция возвращает первую свободную вакансию по варианту
  * @param p_prod_line_dms_id - ИД варианта
  * @return ИД объекта страхования
  */
  FUNCTION get_free_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER;

  /**
  * Функция проверяет - является ли данных объект вакансией
  * @param p_asset_id ИД объекта страхования
  * @return 1- является, 0 - нет
  */
  FUNCTION is_vacation(p_asset_id NUMBER) RETURN NUMBER;

  /**
  * Процедура добаляет руководителя для ЛПУ
  * @param p_lpu_id - ИД ЛПУ
  * @param p_subj_id - ИД контакта
  * @param p_name - Название должности
  */

  PROCEDURE create_official
  (
    p_lpu_id    NUMBER
   ,p_subj_id   NUMBER
   ,p_role_name VARCHAR2 DEFAULT 'Руководитель'
   ,p_name_R    VARCHAR2 DEFAULT NULL
   ,p_name_V    VARCHAR2 DEFAULT NULL
   ,p_name_D    VARCHAR2 DEFAULT NULL
   ,p_name_T    VARCHAR2 DEFAULT NULL
  );
END pkg_dms_vacation;
/
CREATE OR REPLACE PACKAGE BODY pkg_dms_vacation AS

  FUNCTION get_vacation_contact_id RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT c.CONTACT_ID
      INTO v_result
      FROM contact        c
          ,t_contact_type ct
     WHERE NAME = '<Вакансия>'
       AND c.contact_type_id = ct.ID
       AND ct.BRIEF = 'ФЛ'
       AND ct.UPPER_LEVEL_ID IS NOT NULL;
    RETURN v_result;
  END;

  FUNCTION create_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER IS
  
    v_pol_id          NUMBER;
    v_asset_header_id NUMBER;
    v_asset_id        NUMBER;
    v_status_hist_id  NUMBER;
    v_contact_id      NUMBER;
    v_contact_id1     NUMBER;
    v_ent_id          NUMBER;
  
    v_start_date DATE;
    v_end_date   DATE;
  
    v_temp_id NUMBER;
  BEGIN
    --1. нужно узнать сколько нужно вакансий по программе
    IF check_vacation(p_prod_line_dms_id, 1) < 1
    THEN
      --вакансий больше нет
      RETURN - 1;
    END IF;
  
    SELECT t_asset_type_id INTO v_Temp_id FROM t_asset_type WHERE brief = 'ASSET_PERSON_DMS';
  
    SELECT p_policy_id
      INTO v_pol_id
      FROM t_prod_line_dms
     WHERE t_prod_line_dms_id = p_prod_line_dms_id;
  
    SELECT sq_p_asset_header.NEXTVAL INTO v_asset_header_id FROM dual;
    INSERT INTO p_asset_header pah
      (pah.p_asset_header_id, pah.t_asset_type_id)
    VALUES
      (v_asset_header_id, v_temp_id);
  
    SELECT status_hist_id INTO v_status_hist_id FROM status_hist WHERE brief = 'NEW';
  
    v_contact_id := get_vacation_contact_id;
  
    SELECT ppc.CONTACT_ID
          ,pp.start_date
          ,pp.end_date
      INTO v_contact_id1
          ,v_start_date
          ,v_end_date
      FROM p_policy           pp
          ,p_policy_contact   ppc
          ,t_contact_pol_role cpr
     WHERE ppc.POLICY_ID = pp.POLICY_ID
       AND cpr.ID = ppc.CONTACT_POLICY_ROLE_ID
       AND cpr.brief = 'Страхователь'
       AND pp.POLICY_ID = v_pol_id;
  
    SELECT ent_id INTO v_ent_id FROM entity WHERE brief = 'AS_ASSURED';
  
    SELECT sq_as_asset.NEXTVAL INTO v_asset_id FROM dual;
    INSERT INTO ven_as_asset aa
      (aa.as_asset_id
      ,aa.ENT_ID
      ,aa.p_asset_header_id
      ,aa.status_hist_id
      ,aa.p_policy_id
      ,aa.ins_amount
      ,aa.ins_premium
      ,aa.contact_id
      ,aa.start_date
      ,aa.end_date
      ,aa.ins_var_id)
    VALUES
      (v_asset_id
      ,v_ent_id
      ,v_asset_header_id
      ,v_status_hist_id
      ,v_pol_id
      ,0
      ,0
      ,v_contact_id1
      ,v_start_date
      ,v_end_date
      ,p_prod_line_dms_id);
  
    INSERT INTO as_assured aaa
      (aaa.as_assured_id, aaa.assured_contact_id)
    VALUES
      (v_asset_id, v_contact_id);
    RETURN v_asset_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
  END;

  FUNCTION check_vacation
  (
    p_prod_line_dms_id NUMBER
   ,flg_check_policy   NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_max_count_vac  NUMBER;
    v_exist_vac      NUMBER := 0; --существующие вакансии
    v_flg_allow_over NUMBER;
  
    v_pol_id NUMBER;
  BEGIN
    --1. нужно узнать сколько нужно вакансий по программе
    SELECT pld.max_count_user
          ,pld.P_POLICY_ID
          ,pld.FLG_ALLOW_OVER
      INTO v_max_count_vac
          ,v_pol_id
          ,v_flg_allow_over
      FROM t_prod_line_dms pld
     WHERE pld.T_PROD_LINE_DMS_ID = p_prod_line_dms_id;
  
    IF v_pol_id IS NULL
       AND flg_check_policy = 1
    THEN
      --если полис пустой, то и вакансии не нужны
      RETURN 0;
    END IF;
  
    IF flg_check_policy = 0
    THEN
      RETURN v_max_count_vac;
    END IF;
  
    SELECT COUNT(1)
      INTO v_exist_vac
      FROM as_asset           aa
          ,p_cover            pc
          ,t_prod_line_option plo
     WHERE aa.P_POLICY_ID = v_pol_id
       AND pc.AS_ASSET_ID = aa.as_asset_id
       AND plo.ID = pc.T_PROD_LINE_OPTION_ID
       AND plo.PRODUCT_LINE_ID = p_prod_line_dms_id;
  
    IF v_exist_vac >= v_max_count_vac
       AND v_flg_allow_over = 1
    THEN
      RETURN 1;
    ELSIF v_exist_vac >= v_max_count_vac
          AND v_flg_allow_over = 0
    THEN
      RETURN 0;
    ELSE
      RETURN v_max_count_vac - v_exist_vac;
    END IF;
  
  END;

  /*
  функция для определения вакансии
  1 - вакансия
  0 - нет
  */
  FUNCTION is_vacation(p_asset_id NUMBER) RETURN NUMBER IS
    v_contact_id NUMBER;
    v_result     NUMBER;
  BEGIN
  
    v_contact_id := get_vacation_contact_id;
  
    SELECT COUNT(1)
      INTO v_result
      FROM as_assured aa
     WHERE aa.as_assured_id = p_asset_id
       AND aa.ASSURED_CONTACT_ID = v_contact_id;
  
    IF v_result > 0
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
  
    RETURN v_result;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  PROCEDURE del_vacation(p_prod_line_dms_id NUMBER) IS
  
  BEGIN
    FOR cur IN (SELECT aa.as_asset_id
                      ,aa.P_POLICY_ID
                  FROM as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                 WHERE aa.as_asset_id = pc.AS_ASSET_ID
                   AND plo.ID = pc.T_PROD_LINE_OPTION_ID
                   AND plo.PRODUCT_LINE_ID = p_prod_line_dms_id)
    LOOP
      IF is_vacation(cur.as_asset_id) = 1
      THEN
        pkg_asset.exclude_as_asset(cur.p_policy_id, cur.as_asset_id);
      END IF;
    END LOOP;
  END;

  FUNCTION get_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER IS
  
    v_contact_id NUMBER;
    v_result     NUMBER;
  BEGIN
  
    v_contact_id := get_vacation_contact_id;
  
    SELECT COUNT(1)
      INTO v_result
      FROM as_assured         aa
          ,p_cover            pc
          ,t_prod_line_option plo
     WHERE plo.PRODUCT_LINE_ID = p_prod_line_dms_id
       AND pc.T_PROD_LINE_OPTION_ID = plo.ID
       AND aa.AS_ASSURED_ID = pc.AS_ASSET_ID
       AND aa.ASSURED_CONTACT_ID = v_contact_id;
  
    RETURN v_result;
  
  END;

  FUNCTION get_real_assured(p_prod_line_dms_id NUMBER) RETURN NUMBER IS
    v_contact_id NUMBER;
    v_result     NUMBER;
  BEGIN
  
    v_contact_id := get_vacation_contact_id;
  
    SELECT COUNT(1)
      INTO v_result
      FROM as_assured         aa
          ,p_cover            pc
          ,t_prod_line_option plo
     WHERE plo.PRODUCT_LINE_ID = p_prod_line_dms_id
       AND pc.T_PROD_LINE_OPTION_ID = plo.ID
       AND aa.AS_ASSURED_ID = pc.AS_ASSET_ID
       AND aa.ASSURED_CONTACT_ID <> v_contact_id;
  
    RETURN v_result;
  
  END;

  FUNCTION get_max_assured(p_prod_line_dms_id NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
  
    SELECT pld.MAX_COUNT_USER
      INTO v_result
      FROM t_prod_line_dms pld
     WHERE pld.T_PROD_LINE_DMS_ID = p_prod_line_dms_id;
  
    RETURN v_result;
  
  END;

  FUNCTION get_load_assured
  (
    p_prod_line_dms_id NUMBER
   ,p_session_id       NUMBER
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_result
      FROM as_person_med_tmp pmt
     WHERE pmt.SESSION_ID = p_session_id
       AND pmt.DMS_INS_VAR_ID = p_prod_line_dms_id;
  
    RETURN v_result;
  END;

  FUNCTION get_free_vacation(p_prod_line_dms_id NUMBER) RETURN NUMBER IS
  
    v_contact_id NUMBER;
    v_id         NUMBER;
  
  BEGIN
  
    v_contact_id := get_vacation_contact_id;
    v_id         := NULL;
  
    FOR cur IN (SELECT aa.AS_ASSURED_ID
                  FROM as_assured         aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                 WHERE plo.PRODUCT_LINE_ID = p_prod_line_dms_id
                   AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                   AND aa.AS_ASSURED_ID = pc.AS_ASSET_ID
                   AND aa.ASSURED_CONTACT_ID = v_contact_id
                 ORDER BY aa.as_assured_id)
    LOOP
      v_id := cur.as_assured_id;
      EXIT;
    END LOOP;
  
    RETURN v_id;
  
  END;

  PROCEDURE create_official
  (
    p_lpu_id    NUMBER
   ,p_subj_id   NUMBER
   ,p_role_name VARCHAR2 DEFAULT 'Руководитель'
   ,p_name_R    VARCHAR2 DEFAULT NULL
   ,p_name_V    VARCHAR2 DEFAULT NULL
   ,p_name_D    VARCHAR2 DEFAULT NULL
   ,p_name_T    VARCHAR2 DEFAULT NULL
  ) IS
    v_count NUMBER;
  
    v_chel_id NUMBER;
    v_org_id  NUMBER;
  
    v_crt_id   NUMBER;
    v_crt_id_r NUMBER;
  
    v_temp_id NUMBER;
  
    v_name VARCHAR2(200);
  BEGIN
  
    v_name := 'Руководитель';
  
    SELECT COUNT(1) INTO v_count FROM t_contact_role WHERE brief = UPPER('OFFICIAL');
  
    IF v_count = 0
    THEN
      INSERT INTO ven_t_contact_role
        (description, brief)
      VALUES
        ('Руководитель', 'OFFICIAL');
    END IF;
  
    SELECT ID INTO v_chel_id FROM t_contact_role WHERE brief = 'OFFICIAL';
  
    SELECT ID INTO v_org_id FROM t_contact_role WHERE brief = 'LPU';
  
    SELECT COUNT(1)
      INTO v_count
      FROM t_contact_rel_type crt
     WHERE crt.SOURCE_CONTACT_ROLE_ID = v_chel_id
       AND crt.TARGET_CONTACT_ROLE_ID = v_org_id
       AND crt.RELATIONSHIP_DSC = v_name;
  
    IF v_count = 0
    THEN
      SELECT sq_t_contact_rel_type.NEXTVAL INTO v_crt_id FROM dual;
      SELECT sq_t_contact_rel_type.NEXTVAL INTO v_crt_id_r FROM dual;
      INSERT INTO ven_t_contact_rel_type crt
        (crt.ID
        ,crt.RELATIONSHIP_DSC
        ,crt.SOURCE_CONTACT_ROLE_ID
        ,crt.TARGET_CONTACT_ROLE_ID
        ,crt.FOR_DSC
        ,crt.REVERSE_RELATIONSHIP_TYPE)
      VALUES
        (v_crt_id, v_name, v_chel_id, v_org_id, 'ЛПУ', v_crt_id);
    
      INSERT INTO ven_t_contact_rel_type crt
        (crt.ID
        ,crt.FOR_DSC
        ,crt.TARGET_CONTACT_ROLE_ID
        ,crt.SOURCE_CONTACT_ROLE_ID
        ,crt.RELATIONSHIP_DSC
        ,crt.REVERSE_RELATIONSHIP_TYPE)
      VALUES
        (v_crt_id_r, v_name, v_chel_id, v_org_id, 'ЛПУ', v_crt_id);
    
      UPDATE ven_t_contact_rel_type crt
         SET crt.REVERSE_RELATIONSHIP_TYPE = v_crt_id_r
       WHERE crt.ID = v_crt_id;
    END IF;
  
    SELECT crt.ID
      INTO v_crt_id
      FROM t_contact_rel_type crt
     WHERE crt.SOURCE_CONTACT_ROLE_ID = v_chel_id
       AND crt.TARGET_CONTACT_ROLE_ID = v_org_id
       AND crt.RELATIONSHIP_DSC = v_name
       AND ROWNUM = 1;
  
    --пытаемся найти подобную роль со связью    
    SELECT COUNT(1)
      INTO v_count
      FROM ven_cn_contact_rel     ccr
          ,ven_t_contact_rel_type crt
          ,ven_t_contact_role     cr_lpu
          ,ven_t_contact_role     cr_subj
     WHERE ccr.RELATIONSHIP_TYPE = crt.ID
       AND cr_lpu.BRIEF = 'LPU'
       AND cr_subj.brief = 'OFFICIAL'
       AND crt.TARGET_CONTACT_ROLE_ID = cr_lpu.ID
       AND crt.SOURCE_CONTACT_ROLE_ID = cr_subj.ID
       AND ccr.CONTACT_ID_A = p_lpu_id;
  
    IF v_count = 0
    THEN
      INSERT INTO ven_cn_contact_rel ccr
        (ccr.CONTACT_ID_A, ccr.CONTACT_ID_B, ccr.RELATIONSHIP_TYPE)
      VALUES
        (p_lpu_id, p_subj_id, v_crt_id);
    ELSE
      --нужно попытаться найти нужную роль со связью
      FOR cur IN (SELECT ccr.ID
                        ,ccr.RELATIONSHIP_TYPE
                    FROM ven_cn_contact_rel     ccr
                        ,ven_t_contact_rel_type crt
                        ,ven_t_contact_role     cr_lpu
                        ,ven_t_contact_role     cr_subj
                   WHERE ccr.RELATIONSHIP_TYPE = crt.ID
                     AND cr_lpu.BRIEF = 'LPU'
                     AND cr_subj.brief = 'OFFICIAL'
                     AND crt.TARGET_CONTACT_ROLE_ID = cr_lpu.ID
                     AND crt.SOURCE_CONTACT_ROLE_ID = cr_subj.ID
                     AND ccr.CONTACT_ID_A = p_lpu_id)
      LOOP
        v_temp_id := cur.ID;
        IF cur.RELATIONSHIP_TYPE = v_crt_id
        THEN
          EXIT;
        END IF;
      END LOOP;
    
      UPDATE ven_cn_contact_rel ccr
         SET ccr.CONTACT_ID_B      = p_subj_id
            ,ccr.RELATIONSHIP_TYPE = v_crt_id
       WHERE ccr.ID = v_temp_id;
    END IF;
  
    IF TRIM(p_role_name) || ' ' <> ' '
    THEN
      UPDATE cn_person SET post = p_role_name WHERE contact_id = p_subj_id;
    END IF;
  
    IF TRIM(p_name_r) || TRIM(p_name_v) || TRIM(p_name_d) || TRIM(p_name_t) || ' ' <> ' '
    THEN
      UPDATE contact c
         SET c.GENITIVE     = p_name_r
            ,c.ACCUSATIVE   = p_name_v
            ,c.DATIVE       = p_name_d
            ,c.INSTRUMENTAL = p_name_t
       WHERE c.contact_id = p_subj_id;
    END IF;
  
  END;

END pkg_dms_vacation;
/

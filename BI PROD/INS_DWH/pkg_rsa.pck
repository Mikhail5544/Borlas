CREATE OR REPLACE PACKAGE PKG_RSA AS

  /*
  * Работа с посылками для Большого и Малого Автообменов
  * @author Процветов Е.
  * @version 1
  * @headcom
  */

  /**
  * Процедура создания заголовка посылки
  * @author Процветов Е.
  * @param P_DATE_FROM Начало периода
  * @param P_DATE_TO Окончание периода
  * @param P_RSA_PACK_TYPE ИД типа посылки (МА/БА)
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_PACK_HDR
  (
    P_DATE_FROM          IN DATE
   ,P_DATE_TO            IN DATE
   ,P_RSA_PACK_TYPE_ID   NUMBER
   ,P_DESCRIPTION        VARCHAR2
   ,P_RSA_PACK_HEADER_ID OUT NUMBER
  );

  /**
  * Процедура подготовки данных для основной посылки МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_LAO_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных для дополнительной посылки МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_LAD_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных для основной посылки БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAO_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных для дополнительной посылки БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAD_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных по водителям для посылок БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BA_PACK_DRIVER(P_RSA_BA_PACK_DATA_ID IN NUMBER);

  /**
  * Процедура подготовки данных по периодам страхования для посылок БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BA_PACK_PERIOD(P_RSA_BA_PACK_DATA_ID IN NUMBER);

  /**
  * Процедура подготовки данных для основной посылки БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAO_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных для дополнительной посылки БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAD_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки данных по претензиям для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BA_PACK_CLAIM(P_RSA_BA_PACK_EVENT_ID IN NUMBER);

  /**
  * Процедура подготовки данных по выплатам для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BA_PACK_PAYMENT(P_RSA_BA_PACK_CLAIM_ID IN NUMBER);

  /**
  * Процедура подготовки данных по регр. требованиям для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BA_PACK_SUBR_DOC(P_RSA_BA_PACK_CLAIM_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для основной посылки МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_LAI_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для дополнительной посылки МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_LAJ_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для основной посылки БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAI_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для дополнительной посылки БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAJ_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура обновления данных по водителям для посылок БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE UPD_BA_PACK_DRIVER(P_RSA_BA_PACK_DATA_ID IN NUMBER);

  /**
  * Процедура обновления данных по периодам для посылок БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE UPD_BA_PACK_PERIOD(P_RSA_BA_PACK_DATA_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для основной посылки БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAI_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура подготовки скорректированных данных для дополнительной посылки БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE CRE_BAJ_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER);

  /**
  * Процедура обновления данных по претензиям для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE UPD_BA_PACK_CLAIM(P_RSA_BA_PACK_EVENT_ID IN NUMBER);

  /**
  * Процедура обновления данных по выплатам для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE UPD_BA_PACK_PAYMENT(P_RSA_BA_PACK_CLAIM_ID IN NUMBER);

  /**
  * Процедура обновления данных по регр.требованиям для посылок БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  */
  PROCEDURE UPD_BA_PACK_SUBR_DOC(P_RSA_BA_PACK_CLAIM_ID IN NUMBER);

  /**
  * Процедура переводит данные в статус "Выгружен в XML" для МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  * @param P_EXP_FILE_NAME Название xml-файла
  */
  PROCEDURE CRE_LA_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  );

  /**
  * Процедура переводит данные в статус "Выгружен в XML" для БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  * @param P_EXP_FILE_NAME Название xml-файла
  */
  PROCEDURE CRE_BA_DATA_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  );

  /**
  * Процедура переводит данные в статус "Выгружен в XML" для БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  * @param P_EXP_FILE_NAME Название xml-файла
  */
  PROCEDURE CRE_BA_EVENT_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  );

  /**
  * Процедура переводит данные в статус "Ошибки при загрузке в РСА" для МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE UPD_LA_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

  /**
  * Процедура переводит данные в статус "Ошибки при загрузке в РСА" для БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE UPD_BA_DATA_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

  /**
  * Процедура переводит данные в статус "Ошибки при загрузке в РСА" для БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE UPD_BA_EVENT_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

  /**
  * Процедура удаления всех записей по посылке МА
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE DEL_LA_PACK_DATA
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

  /**
  * Процедура удаления всех записей по посылке БА (Реестр договоров страхования)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE DEL_BA_PACK_DATA
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

  /**
  * Процедура удаления всех записей по посылке БА (Реестр страховых случаев)
  * @author Процветов Е.
  * @param P_RSA_PACK_HEADER_ID ID заголовка
  * @param P_PACK_CODE_ID ID вида посылки
  */
  PROCEDURE DEL_BA_PACK_EVENT
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  );

END PKG_RSA;
/
CREATE OR REPLACE PACKAGE BODY PKG_RSA AS

  -- Author  : PROTSVETOV E.
  -- Created : 06.04.2007 18:12:23
  -- Purpose :

  /*******************************************************************************/

  PROCEDURE CRE_PACK_HDR
  (
    P_DATE_FROM          IN DATE
   ,P_DATE_TO            IN DATE
   ,P_RSA_PACK_TYPE_ID   NUMBER
   ,P_DESCRIPTION        VARCHAR2
   ,P_RSA_PACK_HEADER_ID OUT NUMBER
  ) IS
  BEGIN
    SELECT SQ_RSA_PACK_HEADER.nextval INTO P_RSA_PACK_HEADER_ID FROM dual;
  
    INSERT INTO RSA_PACK_HEADER
      (RSA_PACK_HEADER_ID, T_RSA_PACK_TYPE_ID, DATE_FROM, DATE_TO, DESCRIPTION)
    VALUES
      (P_RSA_PACK_HEADER_ID, P_RSA_PACK_TYPE_ID, P_DATE_FROM, P_DATE_TO, P_DESCRIPTION);
  END;

  /*******************************************************************************/

  PROCEDURE CRE_LAO_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_LA_PACK_DATA_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       po.policy_id Recid
                      ,po.pol_ser S_POL
                      ,po.pol_num N_POL
                      ,po.start_date Du_S
                      ,po.end_date Du_F
                      ,po.vin VIN
                      ,po.license_plate GRN
                      ,po.coef_kbm KBM_N
                      ,ev.col_ev S_S_OPL
                      ,to_char(SYSDATE, 'DD/MM/YYYY') D_AKT
                      ,decode(c.IS_INDIVIDUAL, 1, 1, 2) FIZ_UR
                      ,decode(c.IS_INDIVIDUAL, 1, c.IDENT_SERIA || ' ' || c.IDENT_NUMBER, NULL) SN_PASP
                      ,decode(c.IS_INDIVIDUAL, 1, c.NAME, NULL) FAM
                      ,decode(c.IS_INDIVIDUAL, 1, c.FIRST_NAME, NULL) NAME
                      ,decode(c.IS_INDIVIDUAL, 1, c.MIDDLE_NAME, NULL) SNAME
                      ,decode(c.IS_INDIVIDUAL, 0, c.INN_NUMBER, NULL) INN
                      ,decode(c.IS_INDIVIDUAL, 0, c.NAME, NULL) NAME_UR
                  FROM oa_policy po
                  JOIN oa_contact c
                    ON c.CONTACT_ID = po.str_contact_id
                  JOIN (SELECT e.AS_ASSET_ID
                             ,COUNT(DISTINCT e.C_EVENT_ID) col_ev
                         FROM oa_events e
                        WHERE e.DATE_DECLARE BETWEEN p_pack_header.date_from AND p_pack_header.date_to
                        GROUP BY e.AS_ASSET_ID) ev
                    ON po.as_asset_id = ev.AS_ASSET_ID
                 WHERE NOT EXISTS
                 (SELECT 1
                          FROM oa_events e1
                          JOIN rsa_la_event_usage us
                            ON us.rsa_la_event_usage_id = e1.C_EVENT_ID
                         WHERE e1.AS_ASSET_ID = po.as_asset_id
                           AND e1.DATE_DECLARE BETWEEN p_pack_header.date_from AND p_pack_header.date_to))
    LOOP
      INSERT INTO RSA_LA_PACK_DATA VALUES rec;
      INSERT INTO rsa_la_event_usage
        SELECT ev.C_EVENT_ID
              ,rec.rsa_la_pack_data_id
          FROM oa_policy po
          JOIN oa_events ev
            ON po.as_asset_id = ev.AS_ASSET_ID
           AND ev.DATE_DECLARE BETWEEN p_pack_header.date_from AND p_pack_header.date_to
         WHERE po.policy_id = rec.recid
           AND NOT EXISTS
         (SELECT 1 FROM rsa_la_event_usage us WHERE us.rsa_la_event_usage_id = ev.C_EVENT_ID);
    
    END LOOP;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_LAD_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_LA_PACK_DATA_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       po.policy_id Recid
                      ,po.pol_ser S_POL
                      ,po.pol_num N_POL
                      ,po.start_date Du_S
                      ,po.end_date Du_F
                      ,po.vin VIN
                      ,po.license_plate GRN
                      ,po.coef_kbm KBM_N
                      ,ev.col_ev S_S_OPL
                      ,to_char(SYSDATE, 'DD/MM/YYYY') D_AKT
                      ,decode(c.IS_INDIVIDUAL, 1, 1, 2) FIZ_UR
                      ,decode(c.IS_INDIVIDUAL, 1, c.IDENT_SERIA || '-' || c.IDENT_NUMBER, NULL) SN_PASP
                      ,decode(c.IS_INDIVIDUAL, 1, c.NAME, NULL) FAM
                      ,decode(c.IS_INDIVIDUAL, 1, c.FIRST_NAME, NULL) NAME
                      ,decode(c.IS_INDIVIDUAL, 1, c.MIDDLE_NAME, NULL) SNAME
                      ,decode(c.IS_INDIVIDUAL, 0, c.INN_NUMBER, NULL) INN
                      ,decode(c.IS_INDIVIDUAL, 0, c.NAME, NULL) NAME_UR
                  FROM oa_policy po
                  JOIN oa_contact c
                    ON c.CONTACT_ID = po.str_contact_id
                  JOIN (SELECT e.AS_ASSET_ID
                             ,COUNT(DISTINCT e.C_EVENT_ID) col_ev
                         FROM oa_events e
                        WHERE e.DATE_DECLARE <= p_pack_header.date_from
                        GROUP BY e.AS_ASSET_ID) ev
                    ON po.as_asset_id = ev.AS_ASSET_ID
                /*    where not exists (select 1 
                 from oa_events e1
                  join rsa_la_event_usage us on us.rsa_la_event_usage_id = e1.C_EVENT_ID
                 where e1.AS_ASSET_ID = po.as_asset_id
                   and e1.DATE_DECLARE <= p_pack_header.date_from
                )*/
                 WHERE EXISTS (SELECT 1
                          FROM oa_events e1
                          LEFT JOIN rsa_la_event_usage us
                            ON us.rsa_la_event_usage_id = e1.C_EVENT_ID
                         WHERE e1.AS_ASSET_ID = po.as_asset_id
                           AND e1.DATE_DECLARE <= p_pack_header.date_from
                           AND us.rsa_la_event_usage_id IS NULL))
    LOOP
      INSERT INTO RSA_LA_PACK_DATA VALUES rec;
      INSERT INTO rsa_la_event_usage
        SELECT ev.C_EVENT_ID
              ,rec.rsa_la_pack_data_id
          FROM oa_policy po
          JOIN oa_events ev
            ON po.as_asset_id = ev.AS_ASSET_ID
           AND ev.DATE_DECLARE <= p_pack_header.date_from
         WHERE po.policy_id = rec.recid
           AND NOT EXISTS
         (SELECT 1 FROM rsa_la_event_usage us WHERE us.rsa_la_event_usage_id = ev.C_EVENT_ID);
    
    END LOOP;
  
  END;

  /*******************************************************************************/
  --проверить
  PROCEDURE CRE_BAO_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_BA_PACK_DATA_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       po.policy_id Recid
                      ,po.pol_ser S_POL
                      ,po.pol_num N_POL
                      ,po.start_date Du_S
                      ,po.end_date Du_F
                      ,decode(po.decline_date, NULL, po.prev_pol_ser, NULL) S_Old
                      ,decode(po.decline_date, NULL, po.prev_pol_num, NULL) N_Old
                      ,decode(po.decline_date, NULL, po.change_date, NULL) Du_I
                      ,po.decline_date Du_End
                      ,decode(c.IS_INDIVIDUAL, 1, 1, 2) P_FU_S
                      ,decode(c.RESIDENT_FLAG, 1, 1, 2) P_RZ_S
                      ,decode(c.RESIDENT_FLAG, 1, c.ZIP, NULL) Index_S
                      ,decode(c.RESIDENT_FLAG, 1, c.KLADR, NULL) Kladr_S
                      ,decode(c1.IS_INDIVIDUAL, 1, 1, 2) P_FU_H
                      ,decode(c1.RESIDENT_FLAG, 1, 1, 2) P_RZ_H
                      ,decode(c1.RESIDENT_FLAG, 1, po.sob_index, NULL) Index_H
                      ,decode(c1.RESIDENT_FLAG, 1, po.sob_kladr, NULL) Kladr_H
                      ,decode(po.is_driver_no_lim, 1, 1, 2) P_Dop
                      ,rvt.code Tip_TS
                      ,ROUND(po.power_hp) Power
                      ,po.model_year Year_M
                      ,decode(vm.is_national_mark, 1, 1, 2) P_USSR
                      ,decode(po.is_driver_no_lim, 1, NULL, rbm.code) RS_BM
                      ,rvu.code Tag_TS
                      ,po.max_weight Max_M
                      ,po.passangers N_PI
                      ,po.is_foreing_reg P_Reg
                      ,po.nach_prem Sum_P
                      ,0 Sum_KV
                  FROM oa_policy po
                  JOIN oa_contact c
                    ON c.CONTACT_ID = po.str_contact_id
                  JOIN oa_contact c1
                    ON c1.CONTACT_ID = po.sob_contact_id
                  JOIN t_vehicle_type vt
                    ON vt.T_VEHICLE_TYPE_ID = po.t_vehicle_type_id
                  JOIN t_vehicle_mark vm
                    ON vm.T_VEHICLE_MARK_ID = po.t_vehicle_mark_id
                  JOIN t_rsa_vehicle_type rvt
                    ON rvt.brief = vt.BRIEF
                  JOIN t_bonus_malus tbm
                    ON tbm.COEF = po.coef_kbm
                  JOIN t_rsa_bonus_malus rbm
                    ON rbm.class = tbm.CLASS
                  JOIN t_vehicle_usage tvu
                    ON tvu.T_VEHICLE_USAGE_ID = po.t_vehicle_usage_id
                  JOIN t_rsa_vehicle_usage rvu
                    ON rvu.brief = tvu.BRIEF
                 WHERE po.start_date BETWEEN p_pack_header.date_from AND p_pack_header.date_to
                    OR po.change_date BETWEEN p_pack_header.date_from AND p_pack_header.date_to
                    OR po.decline_date BETWEEN p_pack_header.date_from AND p_pack_header.date_to)
    LOOP
      INSERT INTO RSA_BA_PACK_DATA VALUES rec;
      CRE_BA_PACK_DRIVER(rec.RSA_BA_PACK_DATA_ID);
      CRE_BA_PACK_PERIOD(rec.RSA_BA_PACK_DATA_ID);
    END LOOP;
  END;

  /*******************************************************************************/
  --дописать
  PROCEDURE CRE_BAD_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_BA_PACK_DATA_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       po.policy_id Recid
                      ,po.pol_ser S_POL
                      ,po.pol_num N_POL
                      ,po.start_date Du_S
                      ,po.end_date Du_F
                      ,decode(po.decline_date, NULL, po.prev_pol_ser, NULL) S_Old
                      ,decode(po.decline_date, NULL, po.prev_pol_num, NULL) N_Old
                      ,decode(po.decline_date, NULL, po.change_date, NULL) Du_I
                      ,po.decline_date Du_End
                      ,decode(c.IS_INDIVIDUAL, 1, 1, 2) P_FU_S
                      ,decode(c.RESIDENT_FLAG, 1, 1, 2) P_RZ_S
                      ,decode(c.RESIDENT_FLAG, 1, c.ZIP, NULL) Index_S
                      ,decode(c.RESIDENT_FLAG, 1, c.KLADR, NULL) Kladr_S
                      ,decode(c1.IS_INDIVIDUAL, 1, 1, 2) P_FU_H
                      ,decode(c1.RESIDENT_FLAG, 1, 1, 2) P_RZ_H
                      ,decode(c1.RESIDENT_FLAG, 1, po.sob_index, NULL) Index_H
                      ,decode(c1.RESIDENT_FLAG, 1, po.sob_kladr, NULL) Kladr_H
                      ,decode(po.is_driver_no_lim, 1, 1, 2) P_Dop
                      ,rvt.code Tip_TS
                      ,ROUND(po.power_hp) Power
                      ,po.model_year Year_M
                      ,decode(vm.is_national_mark, 1, 1, 2) P_USSR
                      ,decode(po.is_driver_no_lim, 1, NULL, rbm.code) RS_BM
                      ,rvu.code Tag_TS
                      ,po.max_weight Max_M
                      ,po.passangers N_PI
                      ,po.is_foreing_reg P_Reg
                      ,po.nach_prem Sum_P
                      ,0 Sum_KV
                  FROM oa_policy po
                  JOIN oa_contact c
                    ON c.CONTACT_ID = po.str_contact_id
                  JOIN oa_contact c1
                    ON c1.CONTACT_ID = po.sob_contact_id
                  JOIN t_vehicle_type vt
                    ON vt.T_VEHICLE_TYPE_ID = po.t_vehicle_type_id
                  JOIN t_vehicle_mark vm
                    ON vm.T_VEHICLE_MARK_ID = po.t_vehicle_mark_id
                  JOIN t_rsa_vehicle_type rvt
                    ON rvt.brief = vt.BRIEF
                  JOIN t_bonus_malus tbm
                    ON tbm.COEF = po.coef_kbm
                  JOIN t_rsa_bonus_malus rbm
                    ON rbm.class = tbm.CLASS
                  JOIN t_vehicle_usage tvu
                    ON tvu.T_VEHICLE_USAGE_ID = po.t_vehicle_usage_id
                  JOIN t_rsa_vehicle_usage rvu
                    ON rvu.brief = tvu.BRIEF
                 WHERE NOT EXISTS (SELECT 1
                          FROM RSA_BA_PACK_DATA rpd
                         WHERE rpd.RECID = po.POLICY_ID
                           AND rownum = 1)
                   AND (po.start_date <= p_pack_header.date_from OR
                       po.change_date <= p_pack_header.date_from OR
                       po.decline_date <= p_pack_header.date_from))
    LOOP
      INSERT INTO RSA_BA_PACK_DATA VALUES rec;
      CRE_BA_PACK_DRIVER(rec.RSA_BA_PACK_DATA_ID);
      CRE_BA_PACK_PERIOD(rec.RSA_BA_PACK_DATA_ID);
    END LOOP;
  END;

  /*******************************************************************************/
  /*проверить*/
  PROCEDURE CRE_BA_PACK_DRIVER(P_RSA_BA_PACK_DATA_ID IN NUMBER) IS
    p_recid rsa_ba_pack_data.recid%TYPE;
  BEGIN
    SELECT rpd.recid
      INTO p_recid
      FROM RSA_BA_PACK_DATA rpd
      JOIN rsa_pack_header rph
        ON rph.RSA_PACK_HEADER_ID = rpd.RSA_PACK_HEADER_ID
     WHERE rpd.RSA_BA_PACK_DATA_ID = P_RSA_BA_PACK_DATA_ID;
  
    FOR rec IN (SELECT SQ_RSA_BA_PACK_DRIVER.nextval RSA_BA_PACK_DRIVER_ID
                      ,P_RSA_BA_PACK_DATA_ID         RSA_BA_PACK_DATA_ID
                      ,p_recid                       recid
                      ,vd.CONTACT_ID
                      ,
                       --остальные поля для МА
                       vd.date_of_birth Dr
                      ,decode(vd.gender, 0, 2, 1) W
                      ,vd.standing Year_BS
                      ,bm.CLASS R_BM
                  FROM oa_policy po
                  JOIN oa_vehicle_driver vd
                    ON vd.as_vehicle_id = po.as_asset_id
                  JOIN t_bonus_malus bm
                    ON bm.T_BONUS_MALUS_ID = vd.DR_KLASS
                 WHERE po.POLICY_ID = p_recid)
    LOOP
      INSERT INTO RSA_BA_PACK_DRIVER VALUES rec;
    END LOOP;
  END;

  /*******************************************************************************/
  /*проверить*/
  PROCEDURE CRE_BA_PACK_PERIOD(P_RSA_BA_PACK_DATA_ID IN NUMBER) IS
    p_recid rsa_ba_pack_data.recid%TYPE;
  BEGIN
    SELECT rpd.recid
      INTO p_recid
      FROM RSA_BA_PACK_DATA rpd
      JOIN rsa_pack_header rph
        ON rph.RSA_PACK_HEADER_ID = rpd.RSA_PACK_HEADER_ID
     WHERE rpd.RSA_BA_PACK_DATA_ID = P_RSA_BA_PACK_DATA_ID;
  
    FOR rec IN (SELECT SQ_RSA_BA_PACK_PERIOD.nextval RSA_BA_PACK_PERIOD_ID
                      ,P_RSA_BA_PACK_DATA_ID         RSA_BA_PACK_DATA_ID
                      ,p_recid                       recid
                      ,
                       --остальные поля для МА
                       s.period_id
                      ,s.Data_S
                      ,s.Data_f
                  FROM (SELECT po.p1_start_date Data_S
                              ,po.p1_end_date   Data_f
                              ,1                period_id
                          FROM oa_policy po
                         WHERE po.POLICY_ID = p_recid
                        UNION ALL
                        SELECT po1.p2_start_date
                              ,po1.p2_end_date
                              ,2 period_id
                          FROM oa_policy po1
                         WHERE po1.POLICY_ID = p_recid) s)
    LOOP
      IF rec.Data_S IS NOT NULL
         AND rec.Data_F IS NOT NULL
      THEN
        INSERT INTO RSA_BA_PACK_PERIOD VALUES rec;
      END IF;
    END LOOP;
  END;

  /*******************************************************************************/
  /*проверить*/
  PROCEDURE CRE_BAO_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_BA_PACK_EVENT_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       ev.C_EVENT_ID Recid
                      ,p.pol_ser S_Pol
                      ,p.pol_num N_Pol
                      ,ev.EVENT_DATE Du_S
                      ,ev.DATE_DECLARE Du_Z
                      ,vd.date_of_birth Dr
                      ,decode(vd.gender, 0, 2, 1) W
                      ,vd.standing Year_BS
                      ,vd.DR_KLASS
                  FROM oa_events ev
                  JOIN oa_policy p
                    ON ev.AS_ASSET_ID = p.as_asset_id
                  JOIN oa_events_contact ec
                    ON ec.C_EVENT_ID = ev.C_EVENT_ID
                  JOIN oa_contact c
                    ON c.CONTACT_ID = ec.cn_person_id
                  JOIN oa_vehicle_driver vd
                    ON vd.as_vehicle_id = p.as_asset_id
                 WHERE ec.brief = 'Водитель'
                   AND vd.contact_id = c.CONTACT_ID
                   AND ev.DATE_DECLARE BETWEEN p_pack_header.date_from AND p_pack_header.date_to)
    LOOP
      INSERT INTO RSA_BA_PACK_EVENT VALUES rec;
      CRE_BA_PACK_CLAIM(rec.RSA_BA_PACK_EVENT_ID);
    END LOOP;
  END;

  /*******************************************************************************/
  --проверить
  PROCEDURE CRE_BAD_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_code_id NUMBER;
    p_pack_header  rsa_pack_header%ROWTYPE;
  BEGIN
    SELECT *
      INTO p_pack_header
      FROM rsa_pack_header rph
     WHERE rph.rsa_pack_header_id = P_RSA_PACK_HEADER_ID;
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_code_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    FOR rec IN (SELECT SQ_RSA_PACK_DATA.nextval RSA_BA_PACK_EVENT_ID
                      ,P_RSA_PACK_HEADER_ID     RSA_PACK_HEADER_ID
                      ,p_pack_code_id           t_rsa_pack_code_id
                      ,1                        RSA_EXPORT_STATUS_ID
                      ,NULL                     EXP_DATE
                      ,NULL                     exp_file_name
                      ,SYSDATE                  cre_date
                      ,0                        load_err
                      ,
                       --остальные поля для МА
                       ev.C_EVENT_ID Recid
                      ,p.pol_ser S_Pol
                      ,p.pol_num N_Pol
                      ,ev.EVENT_DATE Du_S
                      ,ev.DATE_DECLARE Du_Z
                      ,vd.date_of_birth Dr
                      ,decode(vd.gender, 0, 2, 1) W
                      ,vd.standing Year_BS
                      ,vd.DR_KLASS
                  FROM oa_events ev
                  JOIN oa_policy p
                    ON ev.AS_ASSET_ID = p.as_asset_id
                  JOIN oa_events_contact ec
                    ON ec.C_EVENT_ID = ev.C_EVENT_ID
                  JOIN oa_contact c
                    ON c.CONTACT_ID = ec.cn_person_id
                  JOIN oa_vehicle_driver vd
                    ON vd.as_vehicle_id = p.as_asset_id
                 WHERE ec.brief = 'Водитель'
                   AND vd.contact_id = c.CONTACT_ID
                   AND ev.DATE_DECLARE <= p_pack_header.date_from)
    LOOP
      INSERT INTO RSA_BA_PACK_EVENT VALUES rec;
      CRE_BA_PACK_CLAIM(rec.RSA_BA_PACK_EVENT_ID);
    END LOOP;
  END;

  /*******************************************************************************/
  /*дописать*/
  PROCEDURE CRE_BA_PACK_CLAIM(P_RSA_BA_PACK_EVENT_ID IN NUMBER) IS
    p_recid rsa_ba_pack_EVENT.recid%TYPE;
    d_b     DATE;
    d_e     DATE;
  BEGIN
    SELECT rpe.recid
          ,rph.DATE_FROM
          ,rph.DATE_TO
      INTO p_recid
          ,d_b
          ,d_e
      FROM RSA_BA_PACK_EVENT rpe
      JOIN RSA_PACK_HEADER rph
        ON rph.RSA_PACK_HEADER_ID = rpe.RSA_PACK_HEADER_ID
     WHERE rpe.RSA_BA_PACK_EVENT_ID = P_RSA_BA_PACK_EVENT_ID;
  
    FOR rec IN (SELECT SQ_RSA_BA_PACK_CLAIM.nextval RSA_BA_PACK_CLAIM_ID
                      ,P_RSA_BA_PACK_EVENT_ID       RSA_BA_PACK_EVENT_ID
                      ,p_recid                      recid
                      ,pret.c_claim_id
                      ,
                       --остальные поля для МА
                       pret.payment_sum - nvl(pay.paym, 0) Sum_B
                      ,CASE
                         WHEN pret.BRIEF = 'ОСАГО_ИМУЩЕСТВО' THEN
                          '001'
                         WHEN pret.DESCRIPTION IN ('Расходы на погребение'
                                                  ,'Возмещение утрачен. заработка в связи со смертью кормильца'
                                                  ,'') THEN
                          '002'
                         ELSE
                          '003'
                       END Tag_PP
                      ,CASE pret.payment_sum
                         WHEN nvl(pay.paym, 0) THEN
                          1
                         ELSE
                          2
                       END P_Ur
                  FROM oa_events ev
                  JOIN (SELECT t.C_EVENT_ID
                             ,t.C_CLAIM_HEADER_ID
                             ,t.C_CLAIM_ID
                             ,t.payment_sum
                             ,p.BRIEF
                             ,tdc.DESCRIPTION
                         FROM oa_claim t
                         JOIN oa_damage d
                           ON t.C_CLAIM_ID = d.C_CLAIM_ID
                         JOIN t_damage_code tdc
                           ON tdc.ID = d.T_DAMAGE_CODE_ID
                         JOIN t_peril p
                           ON p.ID = tdc.PERIL
                        WHERE t.seqno = (SELECT MAX(tt.seqno)
                                           FROM oa_claim tt
                                          WHERE tt.C_CLAIM_HEADER_ID = t.C_CLAIM_HEADER_ID
                                            AND tt.claim_status_date <= d_e)) pret
                    ON pret.C_EVENT_ID = ev.C_EVENT_ID
                  LEFT JOIN (SELECT cc.C_CLAIM_HEADER_ID
                                  ,SUM(tr.TRANS_AMOUNT) paym
                              FROM oa_trans tr
                              JOIN trans_templ trans
                                ON trans.TRANS_TEMPL_ID = tr.TRANS_TEMPL_ID
                              JOIN oa_damage dd
                                ON dd.C_DAMAGE_ID = tr.a5_dt_uro_id
                              JOIN oa_claim cc
                                ON cc.C_CLAIM_ID = dd.C_CLAIM_ID
                             WHERE trans.BRIEF = 'ВыплВозмещ'
                               AND tr.TRANS_DATE <= d_e
                             GROUP BY cc.C_CLAIM_HEADER_ID) pay
                    ON pay.C_CLAIM_HEADER_ID = pret.C_CLAIM_HEADER_ID
                 WHERE ev.C_EVENT_ID = p_recid)
    LOOP
      INSERT INTO RSA_BA_PACK_CLAIM VALUES rec;
      CRE_BA_PACK_PAYMENT(rec.RSA_BA_PACK_CLAIM_ID);
      CRE_BA_PACK_SUBR_DOC(rec.RSA_BA_PACK_CLAIM_ID);
    END LOOP;
  END;

  /*******************************************************************************/

  /*проверить*/
  PROCEDURE CRE_BA_PACK_PAYMENT(P_RSA_BA_PACK_CLAIM_ID IN NUMBER) IS
    p_recid rsa_ba_pack_CLAIM.recid%TYPE;
    d_b     DATE;
    d_e     DATE;
  BEGIN
    SELECT rpc.C_CLAIM_ID
          ,rph.DATE_FROM
          ,rph.DATE_TO
      INTO p_recid
          ,d_b
          ,d_e
      FROM RSA_BA_PACK_CLAIM rpc
      JOIN RSA_BA_PACK_EVENT rpe
        ON rpe.RSA_BA_PACK_EVENT_ID = rpc.RSA_BA_PACK_EVENT_ID
      JOIN RSA_PACK_HEADER rph
        ON rph.RSA_PACK_HEADER_ID = rpe.RSA_PACK_HEADER_ID
     WHERE rpc.RSA_BA_PACK_CLAIM_ID = P_RSA_BA_PACK_CLAIM_ID;
  
    FOR rec IN (SELECT SQ_RSA_BA_PACK_PAYMENT.nextval RSA_BA_PACK_PAYMENT_ID
                      ,P_RSA_BA_PACK_CLAIM_ID         RSA_BA_PACK_CLAIM_ID
                      ,p_recid                        recid
                      ,
                       --остальные поля для МА
                       t1.PAYMENT_ID
                      ,t1.Sum_V
                      ,t1.Data_V
                      ,t1.Tag_PP
                  FROM (SELECT cc.C_CLAIM_HEADER_ID PAYMENT_ID
                              ,SUM(tr.TRANS_AMOUNT) Sum_V
                              ,tr.TRANS_DATE Data_V
                              ,CASE
                                 WHEN p.BRIEF = 'ОСАГО_ИМУЩЕСТВО' THEN
                                  '001'
                                 WHEN tdc.DESCRIPTION IN ('Расходы на погребение'
                                                         ,'Возмещение утрачен. заработка в связи со смертью кормильца'
                                                         ,'') THEN
                                  '002'
                                 ELSE
                                  '003'
                               END Tag_PP
                          FROM oa_trans tr
                          JOIN trans_templ trans
                            ON trans.TRANS_TEMPL_ID = tr.TRANS_TEMPL_ID
                          JOIN oa_damage dd
                            ON dd.C_DAMAGE_ID = tr.a5_dt_uro_id
                          JOIN t_damage_code tdc
                            ON tdc.ID = dd.T_DAMAGE_CODE_ID
                          JOIN t_peril p
                            ON p.ID = tdc.PERIL
                          JOIN oa_claim cc
                            ON cc.C_CLAIM_ID = dd.C_CLAIM_ID
                         WHERE cc.C_CLAIM_ID = p_recid
                           AND trans.BRIEF = 'ВыплВозмещ'
                           AND tr.TRANS_DATE <= d_e
                         GROUP BY cc.C_CLAIM_HEADER_ID
                                 ,tr.TRANS_DATE
                                 ,p.BRIEF
                                 ,tdc.DESCRIPTION) t1)
    LOOP
      INSERT INTO RSA_BA_PACK_PAYMENT VALUES rec;
    END LOOP;
  END;

  /*******************************************************************************/

  /*проверить*/
  PROCEDURE CRE_BA_PACK_SUBR_DOC(P_RSA_BA_PACK_CLAIM_ID IN NUMBER) IS
    p_recid rsa_ba_pack_CLAIM.recid%TYPE;
    d_b     DATE;
    d_e     DATE;
  BEGIN
    SELECT rpc.C_CLAIM_ID
          ,rph.DATE_FROM
          ,rph.DATE_TO
      INTO p_recid
          ,d_b
          ,d_e
      FROM RSA_BA_PACK_CLAIM rpc
      JOIN RSA_BA_PACK_EVENT rpe
        ON rpe.RSA_BA_PACK_EVENT_ID = rpc.RSA_BA_PACK_EVENT_ID
      JOIN RSA_PACK_HEADER rph
        ON rph.RSA_PACK_HEADER_ID = rpe.RSA_PACK_HEADER_ID
     WHERE rpc.RSA_BA_PACK_CLAIM_ID = P_RSA_BA_PACK_CLAIM_ID;
  
    FOR rec IN (SELECT SQ_RSA_BA_PACK_SUBR_DOC.nextval RSA_BA_PACK_SUBR_DOC_ID
                      ,P_RSA_BA_PACK_CLAIM_ID          RSA_BA_PACK_CLAIM_ID
                      ,p_recid                         recid
                      ,
                       --остальные поля для МА
                       SD.C_SUBR_DOC_ID SUBR_DOC_ID
                      ,CASE rs.BRIEF
                         WHEN 'УМЫСЛИЦ' THEN
                          '001'
                         WHEN 'УПРАВОПЬЯН' THEN
                          '002'
                         WHEN 'НЕТПРАВУПР' THEN
                          '003'
                         WHEN 'СКРЫЛДТП' THEN
                          '004'
                         WHEN 'ЛИЦНЕДОП' THEN
                          '005'
                         WHEN 'ПЕРНЕВДОГ' THEN
                          '006'
                         ELSE
                          NULL
                       END Tag_R
                      ,t.TRANS_DATE Data_R
                      ,sd.SUBR_AMOUNT Sum_R
                  FROM oa_claim c
                  JOIN oa_subr_doc sd
                    ON sd.c_claim_header_id = c.C_CLAIM_HEADER_ID
                  JOIN t_reason_subr rs
                    ON rs.T_REASON_SUBR_ID = sd.t_reason_subr_id
                  LEFT JOIN (SELECT cl.C_CLAIM_HEADER_ID
                                  ,MAX(tr.TRANS_DATE) TRANS_DATE
                              FROM oa_trans tr
                              JOIN trans_templ tt
                                ON tr.TRANS_TEMPL_ID = tt.TRANS_TEMPL_ID
                              JOIN oa_damage d
                                ON d.C_DAMAGE_ID = tr.a1_dt_uro_id
                              JOIN oa_claim cl
                                ON cl.C_CLAIM_ID = d.C_CLAIM_ID
                             WHERE tt.BRIEF = 'РегрессныйИскНачислен'
                               AND tr.TRANS_DATE <= d_e
                             GROUP BY cl.C_CLAIM_HEADER_ID) t
                    ON t.C_CLAIM_HEADER_ID = c.C_CLAIM_HEADER_ID
                 WHERE c.C_CLAIM_ID = p_recid)
    LOOP
      INSERT INTO RSA_BA_PACK_SUBR_DOC VALUES rec;
    END LOOP;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_LAI_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_codeo_id NUMBER;
    p_pack_codei_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codeo_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codei_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('I');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT lpd.RSA_LA_PACK_DATA_ID
                                      FROM RSA_LA_PACK_DATA lpd
                                     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND lpd.T_RSA_PACK_CODE_ID IN (p_pack_codeo_id, p_pack_codei_id)
                                       AND lpd.RSA_EXPORT_STATUS_ID = 3);
  
    UPDATE RSA_LA_PACK_DATA lpd
       SET (T_RSA_PACK_CODE_ID
          ,RSA_EXPORT_STATUS_ID
          ,EXP_DATE
          ,EXP_FILE_NAME
          ,CRE_DATE
          ,LOAD_ERR
          ,S_POL
          ,N_POL
          ,Du_S
          ,Du_F
          ,VIN
          ,GRN
          ,KBM_N
          ,D_AKT
          ,FIZ_UR
          ,SN_PASP
          ,FAM
          ,NAME
          ,SNAME
          ,INN
          ,NAME_UR) =
           (SELECT p_pack_codei_id T_RSA_PACK_CODE_ID
                  ,1               RSA_EXPORT_STATUS_ID
                  ,NULL            EXP_DATE
                  ,NULL            EXP_FILE_NAME
                  ,SYSDATE         CRE_DATE
                  ,0               LOAD_ERR
                  ,
                   --новые значения
                   po.pol_ser S_POL
                  ,po.pol_num N_POL
                  ,po.start_date Du_S
                  ,po.end_date Du_F
                  ,po.vin VIN
                  ,po.license_plate GRN
                  ,po.coef_kbm KBM_N
                  ,to_char(SYSDATE, 'DD/MM/YYYY') D_AKT
                  ,decode(c.IS_INDIVIDUAL, 1, 1, 2) FIZ_UR
                  ,decode(c.IS_INDIVIDUAL, 1, c.IDENT_SERIA || ' ' || c.IDENT_NUMBER, NULL) SN_PASP
                  ,decode(c.IS_INDIVIDUAL, 1, c.NAME, NULL) FAM
                  ,decode(c.IS_INDIVIDUAL, 1, c.FIRST_NAME, NULL) NAME
                  ,decode(c.IS_INDIVIDUAL, 1, c.MIDDLE_NAME, NULL) SNAME
                  ,decode(c.IS_INDIVIDUAL, 0, c.INN_NUMBER, NULL) INN
                  ,decode(c.IS_INDIVIDUAL, 0, c.NAME, NULL) NAME_UR
              FROM oa_policy po
              JOIN oa_contact c
                ON c.CONTACT_ID = po.str_contact_id
             WHERE po.policy_id = lpd.recid)
     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND lpd.T_RSA_PACK_CODE_ID IN (p_pack_codeo_id, p_pack_codei_id)
       AND lpd.RSA_EXPORT_STATUS_ID = 3;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_LAJ_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_coded_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codej_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('J');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT lpd.RSA_LA_PACK_DATA_ID
                                      FROM RSA_LA_PACK_DATA lpd
                                     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND lpd.T_RSA_PACK_CODE_ID IN (p_pack_coded_id, p_pack_codej_id)
                                       AND lpd.RSA_EXPORT_STATUS_ID = 3);
    UPDATE RSA_LA_PACK_DATA lpd
       SET (T_RSA_PACK_CODE_ID
          ,RSA_EXPORT_STATUS_ID
          ,EXP_DATE
          ,EXP_FILE_NAME
          ,CRE_DATE
          ,LOAD_ERR
          ,S_POL
          ,N_POL
          ,Du_S
          ,Du_F
          ,VIN
          ,GRN
          ,KBM_N
          ,D_AKT
          ,FIZ_UR
          ,SN_PASP
          ,FAM
          ,NAME
          ,SNAME
          ,INN
          ,NAME_UR) =
           (SELECT p_pack_codej_id T_RSA_PACK_CODE_ID
                  ,1               RSA_EXPORT_STATUS_ID
                  ,NULL            EXP_DATE
                  ,NULL            EXP_FILE_NAME
                  ,SYSDATE         CRE_DATE
                  ,0               LOAD_ERR
                  ,
                   --новые значения
                   po.pol_ser S_POL
                  ,po.pol_num N_POL
                  ,po.start_date Du_S
                  ,po.end_date Du_F
                  ,po.vin VIN
                  ,po.license_plate GRN
                  ,po.coef_kbm KBM_N
                  ,to_char(SYSDATE, 'DD/MM/YYYY') D_AKT
                  ,decode(c.IS_INDIVIDUAL, 1, 1, 2) FIZ_UR
                  ,decode(c.IS_INDIVIDUAL, 1, c.IDENT_SERIA || ' ' || c.IDENT_NUMBER, NULL) SN_PASP
                  ,decode(c.IS_INDIVIDUAL, 1, c.NAME, NULL) FAM
                  ,decode(c.IS_INDIVIDUAL, 1, c.FIRST_NAME, NULL) NAME
                  ,decode(c.IS_INDIVIDUAL, 1, c.MIDDLE_NAME, NULL) SNAME
                  ,decode(c.IS_INDIVIDUAL, 0, c.INN_NUMBER, NULL) INN
                  ,decode(c.IS_INDIVIDUAL, 0, c.NAME, NULL) NAME_UR
              FROM oa_policy po
              JOIN oa_contact c
                ON c.CONTACT_ID = po.str_contact_id
             WHERE po.policy_id = lpd.recid)
     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND lpd.T_RSA_PACK_CODE_ID IN (p_pack_coded_id, p_pack_codej_id)
       AND lpd.RSA_EXPORT_STATUS_ID = 3;
  END;

  /*******************************************************************************/
  /*проверить*/
  PROCEDURE CRE_BAI_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_codeo_id NUMBER;
    p_pack_codei_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codeo_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codei_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('I');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT bpd.RSA_BA_PACK_DATA_ID
                                      FROM RSA_BA_PACK_DATA bpd
                                     WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND bpd.T_RSA_PACK_CODE_ID IN (p_pack_codeo_id, p_pack_codei_id)
                                       AND bpd.RSA_EXPORT_STATUS_ID = 3);
    FOR rec IN (SELECT *
                  FROM RSA_BA_PACK_DATA rpd
                 WHERE rpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                   AND rpd.T_RSA_PACK_CODE_ID = p_pack_codeo_id
                   AND rpd.RSA_EXPORT_STATUS_ID = 3)
    LOOP
    
      UPDATE RSA_BA_PACK_DATA rpd
         SET (T_RSA_PACK_CODE_ID
            ,RSA_EXPORT_STATUS_ID
            ,EXP_DATE
            ,EXP_FILE_NAME
            ,CRE_DATE
            ,LOAD_ERR
            ,
              /*проверить*/S_POL
            ,N_POL
            ,Du_S
            ,Du_F
            ,S_Old
            ,N_Old
            ,Du_I
            ,Du_End
            ,P_FU_S
            ,P_RZ_S
            ,Index_S
            ,Kladr_S
            ,P_FU_H
            ,P_RZ_H
            ,Index_H
            ,Kladr_H
            ,P_Dop
            ,Tip_TS
            ,Power
            ,Year_M
            ,P_USSR
            ,RS_BM
            ,Tag_TS
            ,Max_M
            ,N_PI
            ,P_Reg
            ,Sum_P
            ,Sum_KV) =
             (SELECT p_pack_codei_id T_RSA_PACK_CODE_ID
                    ,1               RSA_EXPORT_STATUS_ID
                    ,NULL            EXP_DATE
                    ,NULL            EXP_FILE_NAME
                    ,SYSDATE         CRE_DATE
                    ,0               LOAD_ERR
                    ,
                     --новые значения
                     po.pol_ser S_POL
                    ,po.pol_num N_POL
                    ,po.start_date Du_S
                    ,po.end_date Du_F
                    ,decode(po.decline_date, NULL, po.prev_pol_ser, NULL) S_Old
                    ,decode(po.decline_date, NULL, po.prev_pol_num, NULL) N_Old
                    ,decode(po.decline_date, NULL, po.change_date, NULL) Du_I
                    ,po.decline_date Du_End
                    ,decode(c.IS_INDIVIDUAL, 1, 1, 2) P_FU_S
                    ,decode(c.RESIDENT_FLAG, 1, 1, 2) P_RZ_S
                    ,decode(c.RESIDENT_FLAG, 1, c.ZIP, NULL) Index_S
                    ,decode(c.RESIDENT_FLAG, 1, c.KLADR, NULL) Kladr_S
                    ,decode(c1.IS_INDIVIDUAL, 1, 1, 2) P_FU_H
                    ,decode(c1.RESIDENT_FLAG, 1, 1, 2) P_RZ_H
                    ,decode(c1.RESIDENT_FLAG, 1, po.sob_index, NULL) Index_H
                    ,decode(c1.RESIDENT_FLAG, 1, po.sob_kladr, NULL) Kladr_H
                    ,decode(po.is_driver_no_lim, 1, 1, 2) P_Dop
                    ,rvt.code Tip_TS
                    ,ROUND(po.power_hp) Power
                    ,po.model_year Year_M
                    ,decode(vm.is_national_mark, 1, 1, 2) P_USSR
                    ,decode(po.is_driver_no_lim, 1, NULL, rbm.code) RS_BM
                    ,rvu.code Tag_TS
                    ,po.max_weight Max_M
                    ,po.passangers N_PI
                    ,po.is_foreing_reg P_Reg
                    ,po.nach_prem Sum_P
                    ,0 Sum_KV
                FROM oa_policy po
                JOIN oa_contact c
                  ON c.CONTACT_ID = po.str_contact_id
                JOIN oa_contact c1
                  ON c1.CONTACT_ID = po.sob_contact_id
                JOIN t_vehicle_type vt
                  ON vt.T_VEHICLE_TYPE_ID = po.t_vehicle_type_id
                JOIN t_vehicle_mark vm
                  ON vm.T_VEHICLE_MARK_ID = po.t_vehicle_mark_id
                JOIN t_rsa_vehicle_type rvt
                  ON rvt.brief = vt.BRIEF
                JOIN t_bonus_malus tbm
                  ON tbm.COEF = po.coef_kbm
                JOIN t_rsa_bonus_malus rbm
                  ON rbm.class = tbm.CLASS
                JOIN t_vehicle_usage tvu
                  ON tvu.T_VEHICLE_USAGE_ID = po.t_vehicle_usage_id
                JOIN t_rsa_vehicle_usage rvu
                  ON rvu.brief = tvu.BRIEF
               WHERE po.policy_id = rpd.recid)
       WHERE rpd.RSA_BA_PACK_DATA_ID = rec.RSA_BA_PACK_DATA_ID;
      UPD_BA_PACK_DRIVER(rec.RSA_BA_PACK_DATA_ID);
      UPD_BA_PACK_PERIOD(rec.RSA_BA_PACK_DATA_ID);
    END LOOP;
  END;

  /*******************************************************************************/

  /*проверить*/
  PROCEDURE CRE_BAJ_PACK_DATA(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_coded_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codej_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('J');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT bpd.RSA_BA_PACK_DATA_ID
                                      FROM RSA_BA_PACK_DATA bpd
                                     WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND bpd.T_RSA_PACK_CODE_ID IN (p_pack_coded_id, p_pack_codej_id)
                                       AND bpd.RSA_EXPORT_STATUS_ID = 3);
  
    FOR rec IN (SELECT *
                  FROM RSA_BA_PACK_DATA rpd
                 WHERE rpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                   AND rpd.T_RSA_PACK_CODE_ID = p_pack_coded_id
                   AND rpd.RSA_EXPORT_STATUS_ID = 3)
    LOOP
    
      UPDATE RSA_BA_PACK_DATA rpd
         SET (T_RSA_PACK_CODE_ID
            ,RSA_EXPORT_STATUS_ID
            ,EXP_DATE
            ,EXP_FILE_NAME
            ,CRE_DATE
            ,LOAD_ERR
            ,
              /*проверить*/S_POL
            ,N_POL
            ,Du_S
            ,Du_F
            ,S_Old
            ,N_Old
            ,Du_I
            ,Du_End
            ,P_FU_S
            ,P_RZ_S
            ,Index_S
            ,Kladr_S
            ,P_FU_H
            ,P_RZ_H
            ,Index_H
            ,Kladr_H
            ,P_Dop
            ,Tip_TS
            ,Power
            ,Year_M
            ,P_USSR
            ,RS_BM
            ,Tag_TS
            ,Max_M
            ,N_PI
            ,P_Reg
            ,Sum_P
            ,Sum_KV) =
             (SELECT p_pack_codej_id T_RSA_PACK_CODE_ID
                    ,1               RSA_EXPORT_STATUS_ID
                    ,NULL            EXP_DATE
                    ,NULL            EXP_FILE_NAME
                    ,SYSDATE         CRE_DATE
                    ,0               LOAD_ERR
                    ,
                     --новые значения
                     po.pol_ser S_POL
                    ,po.pol_num N_POL
                    ,po.start_date Du_S
                    ,po.end_date Du_F
                    ,decode(po.decline_date, NULL, po.prev_pol_ser, NULL) S_Old
                    ,decode(po.decline_date, NULL, po.prev_pol_num, NULL) N_Old
                    ,decode(po.decline_date, NULL, po.change_date, NULL) Du_I
                    ,po.decline_date Du_End
                    ,decode(c.IS_INDIVIDUAL, 1, 1, 2) P_FU_S
                    ,decode(c.RESIDENT_FLAG, 1, 1, 2) P_RZ_S
                    ,decode(c.RESIDENT_FLAG, 1, c.ZIP, NULL) Index_S
                    ,decode(c.RESIDENT_FLAG, 1, c.KLADR, NULL) Kladr_S
                    ,decode(c1.IS_INDIVIDUAL, 1, 1, 2) P_FU_H
                    ,decode(c1.RESIDENT_FLAG, 1, 1, 2) P_RZ_H
                    ,decode(c1.RESIDENT_FLAG, 1, po.sob_index, NULL) Index_H
                    ,decode(c1.RESIDENT_FLAG, 1, po.sob_kladr, NULL) Kladr_H
                    ,decode(po.is_driver_no_lim, 1, 1, 2) P_Dop
                    ,rvt.code Tip_TS
                    ,ROUND(po.power_hp) Power
                    ,po.model_year Year_M
                    ,decode(vm.is_national_mark, 1, 1, 2) P_USSR
                    ,decode(po.is_driver_no_lim, 1, NULL, rbm.code) RS_BM
                    ,rvu.code Tag_TS
                    ,po.max_weight Max_M
                    ,po.passangers N_PI
                    ,po.is_foreing_reg P_Reg
                    ,po.nach_prem Sum_P
                    ,0 Sum_KV
                FROM oa_policy po
                JOIN oa_contact c
                  ON c.CONTACT_ID = po.str_contact_id
                JOIN oa_contact c1
                  ON c1.CONTACT_ID = po.sob_contact_id
                JOIN t_vehicle_type vt
                  ON vt.T_VEHICLE_TYPE_ID = po.t_vehicle_type_id
                JOIN t_vehicle_mark vm
                  ON vm.T_VEHICLE_MARK_ID = po.t_vehicle_mark_id
                JOIN t_rsa_vehicle_type rvt
                  ON rvt.brief = vt.BRIEF
                JOIN t_bonus_malus tbm
                  ON tbm.COEF = po.coef_kbm
                JOIN t_rsa_bonus_malus rbm
                  ON rbm.class = tbm.CLASS
                JOIN t_vehicle_usage tvu
                  ON tvu.T_VEHICLE_USAGE_ID = po.t_vehicle_usage_id
                JOIN t_rsa_vehicle_usage rvu
                  ON rvu.brief = tvu.BRIEF
               WHERE po.policy_id = rpd.recid)
       WHERE rpd.RSA_BA_PACK_DATA_ID = rec.RSA_BA_PACK_DATA_ID;
      UPD_BA_PACK_DRIVER(rec.RSA_BA_PACK_DATA_ID);
      UPD_BA_PACK_PERIOD(rec.RSA_BA_PACK_DATA_ID);
    END LOOP;
  END;

  /*******************************************************************************/

  /*проверить*/
  PROCEDURE UPD_BA_PACK_DRIVER(P_RSA_BA_PACK_DATA_ID IN NUMBER) IS
  BEGIN
    UPDATE RSA_BA_PACK_DRIVER rpd
       SET (Dr, W, Year_BS, R_BM) =
           (SELECT --новые значения
             vd.date_of_birth Dr
            ,decode(vd.gender, 0, 2, 1) W
            ,vd.standing Year_BS
            ,bm.CLASS R_BM
              FROM oa_policy po
              JOIN oa_vehicle_driver vd
                ON vd.as_vehicle_id = po.as_asset_id
              JOIN t_bonus_malus bm
                ON bm.T_BONUS_MALUS_ID = vd.DR_KLASS /*проверить*/
             WHERE po.POLICY_ID = rpd.RECID
               AND vd.CONTACT_ID = rpd.CONTACT_ID)
     WHERE rpd.RSA_BA_PACK_DATA_ID = P_RSA_BA_PACK_DATA_ID;
  END;

  /*******************************************************************************/

  /*проверить*/
  PROCEDURE UPD_BA_PACK_PERIOD(P_RSA_BA_PACK_DATA_ID IN NUMBER) IS
  BEGIN
    UPDATE RSA_BA_PACK_PERIOD rpp
       SET (Data_S, Data_f) =
           (SELECT --новые значения
             po.p1_start_date Data_S
            ,po.p1_end_date   Data_f
              FROM oa_policy po
             CROSS JOIN (SELECT 1 period_id FROM dual UNION ALL SELECT 2 period_id FROM dual) vp
             WHERE po.POLICY_ID = rpp.RECID
               AND vp.period_id = rpp.period_id)
     WHERE rpp.RSA_BA_PACK_DATA_ID = P_RSA_BA_PACK_DATA_ID;
  END;

  /*******************************************************************************/

  /*дописать*/
  PROCEDURE CRE_BAI_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_codeo_id NUMBER;
    p_pack_codei_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codeo_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('O');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codei_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('I');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT bpe.RSA_BA_PACK_EVENT_ID
                                      FROM RSA_BA_PACK_EVENT bpe
                                     WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND bpe.T_RSA_PACK_CODE_ID IN (p_pack_codeo_id, p_pack_codei_id)
                                       AND bpe.RSA_EXPORT_STATUS_ID = 3);
  
    UPDATE RSA_BA_PACK_EVENT rpd
       SET (T_RSA_PACK_CODE_ID
          ,RSA_EXPORT_STATUS_ID
          ,EXP_DATE
          ,EXP_FILE_NAME
          ,CRE_DATE
          ,LOAD_ERR /*дописать*/) =
           (SELECT p_pack_codei_id T_RSA_PACK_CODE_ID
                  ,1               RSA_EXPORT_STATUS_ID
                  ,NULL            EXP_DATE
                  ,NULL            EXP_FILE_NAME
                  ,SYSDATE         CRE_DATE
                  ,0               LOAD_ERR
            --новые значения
            /*дописать*/
              FROM dual /*дописать*/
            )
     WHERE rpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND rpd.T_RSA_PACK_CODE_ID = p_pack_codeo_id
       AND rpd.RSA_EXPORT_STATUS_ID = 3;
  END;

  /*******************************************************************************/

  /*дописать*/
  PROCEDURE CRE_BAJ_PACK_EVENT(P_RSA_PACK_HEADER_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_coded_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('D');
  
    SELECT pt.T_RSA_PACK_CODE_ID INTO p_pack_codej_id FROM t_rsa_pack_code pt WHERE pt.CODE IN ('J');
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN (SELECT bpe.RSA_BA_PACK_EVENT_ID
                                      FROM RSA_BA_PACK_EVENT bpe
                                     WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
                                       AND bpe.T_RSA_PACK_CODE_ID IN (p_pack_coded_id, p_pack_codej_id)
                                       AND bpe.RSA_EXPORT_STATUS_ID = 3);
  
    UPDATE RSA_BA_PACK_EVENT rpd
       SET (T_RSA_PACK_CODE_ID
          ,RSA_EXPORT_STATUS_ID
          ,EXP_DATE
          ,EXP_FILE_NAME
          ,CRE_DATE
          ,LOAD_ERR /*дописать*/) =
           (SELECT p_pack_codej_id T_RSA_PACK_CODE_ID
                  ,1               RSA_EXPORT_STATUS_ID
                  ,NULL            EXP_DATE
                  ,NULL            EXP_FILE_NAME
                  ,SYSDATE         CRE_DATE
                  ,0               LOAD_ERR
            --новые значения
            /*дописать*/
              FROM dual /*дописать*/
            )
     WHERE rpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND rpd.T_RSA_PACK_CODE_ID = p_pack_coded_id
       AND rpd.RSA_EXPORT_STATUS_ID = 3;
  END;

  /*******************************************************************************/

  /*дописать*/
  PROCEDURE UPD_BA_PACK_CLAIM(P_RSA_BA_PACK_EVENT_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    /*update RSA_BA_PACK_CLAIM1 rpd
      set (*дописать*)=
             (select --новые значения
                     *дописать*
                from dual *дописать*)
    where rpd.RSA_PACK_HEADER_ID=P_RSA_PACK_HEADER_ID
      and rpd.T_RSA_PACK_CODE_ID=p_pack_coded_id
      and rpd.RSA_EXPORT_STATUS_ID=3;*/
    NULL;
  END;

  /*******************************************************************************/

  /*дописать*/
  PROCEDURE UPD_BA_PACK_PAYMENT(P_RSA_BA_PACK_CLAIM_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    /*update RSA_BA_PACK_PREPAY rpp
      set (*дописать*)=
             (select --новые значения
                     *дописать*
                from dual *дописать*)
    where rpd.RSA_PACK_HEADER_ID=P_RSA_PACK_HEADER_ID
      and rpd.T_RSA_PACK_CODE_ID=p_pack_coded_id
      and rpd.RSA_EXPORT_STATUS_ID=3;*/
    NULL;
  END;

  /*******************************************************************************/

  /*дописать*/
  PROCEDURE UPD_BA_PACK_SUBR_DOC(P_RSA_BA_PACK_CLAIM_ID IN NUMBER) IS
    p_pack_coded_id NUMBER;
    p_pack_codej_id NUMBER;
  BEGIN
  
    /*update RSA_BA_PACK_SUBR_DOC rpd
      set (*дописать*)=
             (select --новые значения
                     *дописать*
                from dual *дописать*)
    where rpd.RSA_PACK_HEADER_ID=P_RSA_PACK_HEADER_ID
      and rpd.T_RSA_PACK_CODE_ID=p_pack_coded_id
      and rpd.RSA_EXPORT_STATUS_ID=3;*/
    NULL;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_LA_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  ) IS
  BEGIN
    UPDATE RSA_LA_PACK_DATA lpd
       SET lpd.RSA_EXPORT_STATUS_ID = 2
          ,lpd.EXP_FILE_NAME        = P_EXP_FILE_NAME
     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND lpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND lpd.RSA_EXPORT_STATUS_ID = 1;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_BA_DATA_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  ) IS
  BEGIN
    UPDATE RSA_BA_PACK_DATA bpd
       SET bpd.RSA_EXPORT_STATUS_ID = 2
          ,bpd.EXP_FILE_NAME        = P_EXP_FILE_NAME
     WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND bpd.RSA_EXPORT_STATUS_ID = 1;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE CRE_BA_EVENT_XML
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
   ,P_EXP_FILE_NAME      IN VARCHAR2
  ) IS
  BEGIN
    UPDATE RSA_BA_PACK_EVENT bpe
       SET bpe.RSA_EXPORT_STATUS_ID = 2
          ,bpe.EXP_FILE_NAME        = P_EXP_FILE_NAME
     WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpe.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND bpe.RSA_EXPORT_STATUS_ID = 1;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE UPD_LA_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
    UPDATE RSA_LA_PACK_DATA lpd
       SET lpd.RSA_EXPORT_STATUS_ID = decode(sign((SELECT COUNT(*)
                                                    FROM RSA_ERR_PACK_DATA epd
                                                   WHERE epd.RSA_PACK_DATA_ID = lpd.RSA_LA_PACK_DATA_ID))
                                            ,0
                                            ,9
                                            ,1
                                            ,3)
     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND lpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND lpd.RSA_EXPORT_STATUS_ID = 2;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE UPD_BA_DATA_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
    UPDATE RSA_BA_PACK_DATA bpd
       SET bpd.RSA_EXPORT_STATUS_ID = decode(sign((SELECT COUNT(*)
                                                    FROM RSA_ERR_PACK_DATA epd
                                                   WHERE epd.RSA_PACK_DATA_ID = bpd.RSA_BA_PACK_DATA_ID))
                                            ,0
                                            ,9
                                            ,1
                                            ,3)
     WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND bpd.RSA_EXPORT_STATUS_ID = 2;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE UPD_BA_EVENT_ERR_STATUS
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
    UPDATE RSA_BA_PACK_EVENT bpe
       SET bpe.RSA_EXPORT_STATUS_ID = decode(sign((SELECT COUNT(*)
                                                    FROM RSA_ERR_PACK_DATA epd
                                                   WHERE epd.RSA_PACK_DATA_ID =
                                                         bpe.RSA_BA_PACK_EVENT_ID))
                                            ,0
                                            ,9
                                            ,1
                                            ,3)
     WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpe.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID
       AND bpe.RSA_EXPORT_STATUS_ID = 2;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE DEL_LA_PACK_DATA
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN
           (SELECT lpd.RSA_LA_PACK_DATA_ID
              FROM RSA_LA_PACK_DATA lpd
             WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND lpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
  
    DELETE FROM RSA_LA_EVENT_USAGE REU
     WHERE REU.RSA_LA_PACK_DATA_ID IN
           (SELECT lpd.RSA_LA_PACK_DATA_ID
              FROM RSA_LA_PACK_DATA lpd
             WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND lpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_LA_PACK_DATA lpd
     WHERE lpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND lpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE DEL_BA_PACK_DATA
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN
           (SELECT bpd.RSA_BA_PACK_DATA_ID
              FROM RSA_BA_PACK_DATA bpd
             WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_DRIVER BPD
     WHERE BPD.RSA_BA_PACK_DATA_ID IN
           (SELECT bpd.RSA_BA_PACK_DATA_ID
              FROM RSA_BA_PACK_DATA bpd
             WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_PERIOD BPP
     WHERE BPP.RSA_BA_PACK_DATA_ID IN
           (SELECT bpd.RSA_BA_PACK_DATA_ID
              FROM RSA_BA_PACK_DATA bpd
             WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_DATA bpd
     WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  /*******************************************************************************/

  PROCEDURE DEL_BA_PACK_EVENT
  (
    P_RSA_PACK_HEADER_ID IN NUMBER
   ,P_PACK_CODE_ID       IN NUMBER
  ) IS
  BEGIN
  
    DELETE FROM RSA_ERR_PACK_DATA EPD
     WHERE EPD.RSA_PACK_DATA_ID IN
           (SELECT bpe.RSA_BA_PACK_EVENT_ID
              FROM RSA_BA_PACK_EVENT bpe
             WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpe.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_PAYMENT BPP
     WHERE BPP.RSA_BA_PACK_CLAIM_ID IN
           (SELECT bpc.RSA_BA_PACK_CLAIM_ID
              FROM RSA_BA_PACK_EVENT bpd
              JOIN RSA_BA_PACK_CLAIM bpc
                ON bpc.RSA_BA_PACK_EVENT_ID = bpd.RSA_BA_PACK_EVENT_ID
             WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_SUBR_DOC BPS
     WHERE BPS.RSA_BA_PACK_CLAIM_ID IN
           (SELECT bpc.RSA_BA_PACK_CLAIM_ID
              FROM RSA_BA_PACK_EVENT bpd
              JOIN RSA_BA_PACK_CLAIM bpc
                ON bpc.RSA_BA_PACK_EVENT_ID = bpd.RSA_BA_PACK_EVENT_ID
             WHERE bpd.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpd.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_CLAIM BPC
     WHERE BPC.RSA_BA_PACK_EVENT_ID IN
           (SELECT bpe.RSA_BA_PACK_EVENT_ID
              FROM RSA_BA_PACK_EVENT bpe
             WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
               AND bpe.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID);
    DELETE FROM RSA_BA_PACK_EVENT bpe
     WHERE bpe.RSA_PACK_HEADER_ID = P_RSA_PACK_HEADER_ID
       AND bpe.T_RSA_PACK_CODE_ID = P_PACK_CODE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

END PKG_RSA;
/

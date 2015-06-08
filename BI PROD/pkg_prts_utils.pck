CREATE OR REPLACE PACKAGE PKG_PRTS_UTILS AS
  /******************************************************************************
     NAME:       PKG_PRTS_UTILS
     PURPOSE:    Утилиты для отчётов и форм
  
     REVISIONS:
     Ver        Date        Author               Description
     ---------  ----------  ---------------      ------------------------------------
     1.0        11.01.2007  Процветов Евгений          1. Created this package.
  ******************************************************************************/

  --Функция склоняет валюту, которую берёт из настройки ОГП
  FUNCTION get_currency_name
  (
    p_last_num IN NUMBER
   ,P_fund_id  IN NUMBER
  ) RETURN VARCHAR2;

  /** Report rQuestProp.jsp (!INS_08)
  * Застрахованные объекты (Имущество ЮЛ): 
  *     p_res=1 признак наличия (взависимости от типа) - да/нет,
  *   p_res=2 описание,
  *   p_res=3 страховая сумма/стоимость
  * @param p_policy_header_id ИД заголовка договора страхования
  *      p_type Тип объекта, кот. необходимо застраховать   
  *        p_res Тип результата, который необходимо вернуть 
  * @return признак наличия,описание,страховая сумма/стоимость
  */

  FUNCTION get_property_UL
  (
    p_policy_header_id NUMBER
   ,p_type             NUMBER
   ,p_res              NUMBER DEFAULT 1
  ) RETURN VARCHAR2;
  FUNCTION get_obj_prop_list
  (
    p_policy_header_id NUMBER
   ,n_from             NUMBER
   ,n_to               NUMBER
  ) RETURN TT_PROPERTY_UL
    PIPELINED;
  FUNCTION get_sign_cnt(p_policy_header_id NUMBER) RETURN NUMBER;
  FUNCTION get_sign_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED;
  FUNCTION get_pult_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED;
  FUNCTION get_risk_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED;
  FUNCTION get_risk_names(p_policy_header_id NUMBER) RETURN VARCHAR2;
  FUNCTION get_as_asset_id(p_policy_header_id NUMBER) RETURN NUMBER;
  FUNCTION get_inflam_mat
  (
    p_as_asset_id   NUMBER
   ,p_cn_address_id NUMBER
  ) RETURN VARCHAR2;

END PKG_PRTS_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_PRTS_UTILS AS
  /******************************************************************************
     NAME:       PKG_PRTS_UTILS
     PURPOSE:    Утилиты для отчётов и форм
  
     REVISIONS:
     Ver        Date        Author              Description
     ---------  ----------  ---------------     ------------------------------------
     1.0        11.01.2007  Процветов Евгений            1. Created this package body.
  ******************************************************************************/
  --Функция склоняет валюту, которую берёт из настройки ОГП
  FUNCTION get_currency_name
  (
    p_last_num IN NUMBER
   ,P_fund_id  IN NUMBER
  ) RETURN VARCHAR2 IS
    cur1 VARCHAR2(30);
    cur2 VARCHAR2(30);
    cur3 VARCHAR2(30);
    tmp  VARCHAR2(80);
    tmp1 NUMBER(15);
  BEGIN
    tmp1 := ABS(p_last_num);
    SELECT spell_1_whole
          ,spell_2_whole
          ,spell_5_whole
      INTO cur1
          ,cur2
          ,cur3
      FROM fund
     WHERE fund_id = p_fund_id;
  
    IF (tmp1 > 99)
    THEN
      tmp1 := TO_NUMBER(SUBSTR(TO_CHAR(tmp1), -2));
    END IF;
  
    IF (tmp1 < 9)
       OR (tmp1 > 19)
    THEN
      IF (tmp1 > 19)
      THEN
        tmp1 := TO_NUMBER(SUBSTR(TO_CHAR(tmp1), -1));
      END IF;
    
      IF (tmp1 = 1)
      THEN
        tmp := cur1;
      ELSIF ((tmp1 = 2) OR (tmp1 = 3) OR (tmp1 = 4))
      THEN
        tmp := cur2;
      ELSE
        tmp := cur3;
      END IF;
    ELSE
      tmp := cur3;
    END IF;
  
    RETURN tmp;
  
  END get_currency_name;

  ---------------------------------------------------------------------------------------

  FUNCTION get_property_UL
  (
    p_policy_header_id NUMBER
   ,p_type             NUMBER
   ,p_res              NUMBER DEFAULT 1
  ) RETURN VARCHAR2 IS
    p_cnt  NUMBER;
    p_note VARCHAR2(2000);
    p_sum  VARCHAR2(2000);
  BEGIN
    SELECT OBJ_NOTE
          ,OBJ_SUM
      INTO p_note
          ,p_sum
      FROM (SELECT CASE OBJ_NAME
                      WHEN
                       'Здание ("коробка"), включая стены, перекрытия, кровлю, внутреннюю и внешнюю отделки' THEN
                       1
                      WHEN 'Здание (только "коробка")' THEN
                       2
                      WHEN 'Внутренняя отделка' THEN
                       3
                      WHEN 'Окна, витрины, витражи' THEN
                       4
                      WHEN 'Производственное (технологическое) оборудование' THEN
                       7
                      WHEN 'Офисное оборудование' THEN
                       8
                      WHEN 'Торговое оборудование' THEN
                       9
                      WHEN 'Инструмент/инвентарь' THEN
                       10
                      WHEN 'Мебель' THEN
                       11
                      WHEN 'Запасы готовой продукции/продукции для реализации' THEN
                       13
                      WHEN 'Запасы сырья и материалов' THEN
                       14
                      WHEN 'Запасы в незавершенном производстве' THEN
                       15
                      ELSE
                       12
                    END OBJ_TYPE
                   ,OBJ_NAME
                   ,OBJ_NOTE
                   ,OBJ_SUM
               FROM (SELECT pst.name OBJ_NAME
                            ,pkg_asset.get_note(aps.t_property_stuff_typ_id, pp.policy_id, 1) OBJ_NOTE
                            ,SUM(aps.ins_sum) || '/' || SUM(aps.ins_price) OBJ_SUM
                        FROM p_pol_header ph
                        JOIN p_policy pp
                          ON pp.pol_header_id = ph.policy_header_id
                         AND pp.version_num = 1
                        JOIN as_asset ass
                          ON ass.p_policy_id = pp.policy_id
                        JOIN as_property ap
                          ON ap.as_property_id = ass.as_asset_id
                        JOIN as_property_stuff aps /*'Перечень имущества, подлежащего страхованиюэ*/
                        ON aps.as_property_id = ap.as_property_id
                      JOIN t_property_stuff_typ pst /*'Вид страхуемого имущества'*/
                        ON pst.t_property_stuff_typ_id = aps.t_property_stuff_typ_id
                     WHERE ph.policy_header_id = P_policy_header_id --52021
                     GROUP BY pst.name
                             ,pkg_asset.get_note(aps.t_property_stuff_typ_id, pp.policy_id, 1))
            UNION
            SELECT 4
                  ,'Окна, витрины, витражи'
                  ,pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2)
                  ,SUM(ass.ins_amount) || '/' || SUM(ass.ins_price)
              FROM p_pol_header ph
              JOIN p_policy pp
                ON pp.pol_header_id = ph.policy_header_id
               AND pp.version_num = 1
              JOIN as_asset ass
                ON ass.p_policy_id = pp.policy_id
              JOIN as_property ap
                ON ap.as_property_id = ass.as_asset_id
              JOIN p_asset_header pah
                ON ass.p_asset_header_id = pah.p_asset_header_id
              JOIN t_asset_type tat
                ON tat.t_asset_type_id = pah.t_asset_type_id
               AND tat.name = 'Стекла, витрины'
             WHERE ph.policy_header_id = P_policy_header_id
             GROUP BY pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2))
     WHERE OBJ_TYPE = p_type;
  
    CASE
      WHEN p_res = 1 THEN
        RETURN 'Y';
      WHEN p_res = 2 THEN
        RETURN p_note;
      WHEN p_res = 3 THEN
        RETURN p_sum;
    END CASE;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF p_res = 1
      THEN
        RETURN 'N';
      ELSE
        RETURN NULL;
      END IF;
    
  END get_property_UL;

  ---------------------------------------------------------------------------------------

  FUNCTION get_obj_prop_list
  (
    p_policy_header_id NUMBER
   ,n_from             NUMBER
   ,n_to               NUMBER
  ) RETURN TT_PROPERTY_UL
    PIPELINED IS
  BEGIN
    FOR temp_cur IN (SELECT t2.OBJ_TYPE
                           ,decode(t1.OBJ_ENABLE, 1, chr(254), chr(168)) OBJ_ENABLE
                           ,t2.OBJ_NAME
                           ,t1.OBJ_NOTE
                           ,t1.OBJ_SUM
                       FROM (SELECT CASE OBJ_NAME
                                       WHEN
                                        'Здание ("коробка"), включая стены, перекрытия, кровлю, внутреннюю и внешнюю отделки' THEN
                                        1
                                       WHEN 'Здание (только "коробка")' THEN
                                        2
                                       WHEN 'Внутренняя отделка' THEN
                                        3
                                       WHEN 'Окна, витрины, витражи' THEN
                                        4
                                       WHEN 'Производственное (технологическое) оборудование' THEN
                                        7
                                       WHEN 'Офисное оборудование' THEN
                                        8
                                       WHEN 'Торговое оборудование' THEN
                                        9
                                       WHEN 'Инструмент/инвентарь' THEN
                                        10
                                       WHEN 'Мебель' THEN
                                        11
                                       WHEN 'Запасы готовой продукции/продукции для реализации' THEN
                                        13
                                       WHEN 'Запасы сырья и материалов' THEN
                                        14
                                       WHEN 'Запасы в незавершенном производстве' THEN
                                        15
                                       ELSE
                                        12
                                     END OBJ_TYPE
                                    ,1 OBJ_ENABLE
                                    ,OBJ_NAME
                                    ,OBJ_NOTE
                                    ,OBJ_SUM
                                FROM (SELECT pst.name OBJ_NAME
                                             ,pkg_asset.get_note(aps.t_property_stuff_typ_id
                                                                ,pp.policy_id
                                                                ,1) OBJ_NOTE
                                             ,SUM(aps.ins_sum) || '/' || SUM(aps.ins_price) OBJ_SUM
                                         FROM p_pol_header ph
                                         JOIN p_policy pp
                                           ON pp.pol_header_id = ph.policy_header_id
                                          AND pp.version_num = 1
                                         JOIN as_asset ass
                                           ON ass.p_policy_id = pp.policy_id
                                         JOIN as_property ap
                                           ON ap.as_property_id = ass.as_asset_id
                                         JOIN as_property_stuff aps /*'Перечень имущества, подлежащего страхованиюэ*/
                                         ON aps.as_property_id = ap.as_property_id
                                       JOIN t_property_stuff_typ pst /*'Вид страхуемого имущества'*/
                                         ON pst.t_property_stuff_typ_id = aps.t_property_stuff_typ_id
                                      WHERE ph.policy_header_id = P_policy_header_id --52021
                                      GROUP BY pst.name
                                              ,pkg_asset.get_note(aps.t_property_stuff_typ_id
                                                                 ,pp.policy_id
                                                                 ,1))
                             UNION
                             SELECT 4
                                   ,1
                                   ,'Окна, витрины, витражи'
                                   ,pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2)
                                   ,SUM(ass.ins_amount) || '/' || SUM(ass.ins_price)
                               FROM p_pol_header ph
                               JOIN p_policy pp
                                 ON pp.pol_header_id = ph.policy_header_id
                                AND pp.version_num = 1
                               JOIN as_asset ass
                                 ON ass.p_policy_id = pp.policy_id
                               JOIN as_property ap
                                 ON ap.as_property_id = ass.as_asset_id
                               JOIN p_asset_header pah
                                 ON ass.p_asset_header_id = pah.p_asset_header_id
                               JOIN t_asset_type tat
                                 ON tat.t_asset_type_id = pah.t_asset_type_id
                                AND tat.name = 'Стекла, витрины'
                              WHERE ph.policy_header_id = P_policy_header_id
                              GROUP BY pkg_asset.get_note(pah.t_asset_type_id, pp.policy_id, 2)) t1
                           ,TABLE(TT_PROPERTY_UL(TO_PROPERTY_UL(1
                                                               ,NULL
                                                               ,'Здание ("коробка"), включая стены, перекрытия, кровлю, внутреннюю и внешнюю отделки'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(2
                                                               ,NULL
                                                               ,'Здание (только "коробка")'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(3
                                                               ,NULL
                                                               ,'Помещение по стоимости ремонта (отделки)'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(4
                                                               ,NULL
                                                               ,'Окна, витрины, витражи'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(5
                                                               ,NULL
                                                               ,'Внешние объекты (антенны, мачты, рекламные установки и т.п.)'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(6
                                                               ,NULL
                                                               ,'иное (укажите)'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(7
                                                               ,NULL
                                                               ,'Производственное (технологическое)'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(8
                                                               ,NULL
                                                               ,'Офисное (приложите список):'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(9
                                                               ,NULL
                                                               ,'Торговое (технологическое):'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(10
                                                               ,NULL
                                                               ,'Инструмент / инвентарь:'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(11, NULL, 'Мебель', NULL, NULL)
                                                ,TO_PROPERTY_UL(12
                                                               ,NULL
                                                               ,'Иное (Укажите):'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(13
                                                               ,NULL
                                                               ,'Запасы готовой продукции / продукции для реализации'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(14
                                                               ,NULL
                                                               ,'Запасы сырья и материалов'
                                                               ,NULL
                                                               ,NULL)
                                                ,TO_PROPERTY_UL(15
                                                               ,NULL
                                                               ,'Запасы в незавершенном производстве'
                                                               ,NULL
                                                               ,NULL))) t2
                      WHERE t2.OBJ_TYPE = t1.OBJ_TYPE(+)
                        AND t2.OBJ_TYPE BETWEEN n_from AND n_to
                      ORDER BY t2.OBJ_TYPE)
    LOOP
      PIPE ROW(TO_PROPERTY_UL(temp_cur.OBJ_TYPE
                             ,temp_cur.OBJ_ENABLE
                             ,temp_cur.OBJ_NAME
                             ,temp_cur.OBJ_NOTE
                             ,temp_cur.OBJ_SUM));
    END LOOP;
    RETURN;
  END get_obj_prop_list;

  FUNCTION get_sign_cnt(p_policy_header_id NUMBER) RETURN NUMBER IS
    p_ret NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO p_ret
      FROM p_pol_header ph
      JOIN p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN as_property ap
        ON ap.as_property_id = ass.as_asset_id
      JOIN t_system_signalling tss
        ON tss.t_system_signalling_id = ap.t_system_signalling_id
     WHERE ph.policy_header_id = p_policy_header_id;
    RETURN p_ret;
  END get_sign_cnt;

  FUNCTION get_sign_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED IS
  BEGIN
    FOR temp_cur IN (SELECT t2.SIGN_TYPE
                           ,nvl(t1.sign_en_1, chr(168)) sign_en_1
                           ,t2.sign_name_1
                           ,decode(t1.sign_en_2
                                  ,NULL
                                  ,decode(t2.sign_type
                                         ,2
                                         ,decode(PKG_PRTS_UTILS.get_sign_cnt(p_policy_header_id)
                                                ,0
                                                ,chr(254)
                                                ,chr(168))
                                         ,decode(t2.sign_name_2, NULL, NULL, chr(168)))) sign_en_2
                           ,t2.sign_name_2
                       FROM (SELECT decode(tss.name
                                          ,'Системы видеонаблюдения / телекамеры'
                                          ,1
                                          ,'Иные'
                                          ,1
                                          ,'Кодовые замки / системы электронного допуска'
                                          ,2
                                          ,'Датчики изменения объема'
                                          ,3) SIGN_TYPE
                                   , -- технические средства, используемые в системе сигнализации:
                                    decode(tss.name
                                          ,'Системы видеонаблюдения / телекамеры'
                                          ,chr(254)
                                          ,'Кодовые замки / системы электронного допуска'
                                          ,chr(254)
                                          ,'Датчики изменения объема'
                                          ,chr(254)
                                          ,chr(168)) SIGN_EN_1
                                   ,decode(tss.name, 'Иные', chr(254), chr(168)) SIGN_EN_2
                               FROM p_pol_header ph
                               JOIN p_policy pp
                                 ON pp.pol_header_id = ph.policy_header_id
                                AND pp.version_num = 1
                               JOIN as_asset ass
                                 ON ass.p_policy_id = pp.policy_id
                               JOIN as_property ap
                                 ON ap.as_property_id = ass.as_asset_id
                               JOIN t_system_signalling tss
                                 ON tss.t_system_signalling_id = ap.t_system_signalling_id
                              WHERE ph.policy_header_id = P_policy_header_id --52021,69491
                             ) t1
                           ,(SELECT OBJ_TYPE   SIGN_TYPE
                                   ,OBJ_ENABLE SIGN_EN_1
                                   ,OBJ_NAME   SIGN_NAME_1
                                   ,OBJ_NOTE   SIGN_EN_2
                                   ,OBJ_SUM    SIGN_NAME_2
                               FROM TABLE(TT_PROPERTY_UL(TO_PROPERTY_UL(1
                                                                       ,NULL
                                                                       ,'Системы видеонаблюдения / телекамеры'
                                                                       ,NULL
                                                                       ,'Иные:')
                                                        ,TO_PROPERTY_UL(2
                                                                       ,NULL
                                                                       ,'Кодовые замки / системы электронного допуска'
                                                                       ,NULL
                                                                       ,'Системы не установлены')
                                                        ,TO_PROPERTY_UL(3
                                                                       ,NULL
                                                                       ,'Датчики изменения объема'
                                                                       ,NULL
                                                                       ,NULL)))) t2
                      WHERE t2.sign_type = t1.sign_type(+)
                      ORDER BY t2.SIGN_TYPE)
    LOOP
      PIPE ROW(TO_PROPERTY_UL(temp_cur.SIGN_TYPE
                             ,temp_cur.SIGN_EN_1
                             ,temp_cur.SIGN_NAME_1
                             ,temp_cur.SIGN_EN_2
                             ,temp_cur.SIGN_NAME_2));
    END LOOP;
    RETURN;
  END get_sign_list;

  FUNCTION get_pult_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED IS
  BEGIN
    FOR temp_cur IN (SELECT t2.PULT_TYPE
                           ,nvl(t1.PULT_en_1, chr(168)) PULT_en_1
                           ,t2.PULT_name_1
                           ,nvl(t1.PULT_en_2, chr(168)) PULT_en_2
                           ,t2.PULT_name_2
                       FROM (SELECT decode(ps.name
                                          ,'В комнате охраны'
                                          ,1
                                          ,'На пульт отделения милиции '
                                          ,1
                                          ,'Вневедомственной охраны'
                                          ,2
                                          ,'Иное'
                                          ,2) PULT_TYPE
                                   , -- если система сигнализации выведена на пульт
                                    decode(ps.name
                                          ,'В комнате охраны'
                                          ,chr(254)
                                          ,'Вневедомственной охраны'
                                          ,chr(254)
                                          ,chr(168)) PULT_EN_1
                                   ,decode(ps.name
                                          ,'На пульт отделения милиции '
                                          ,chr(254)
                                          ,'Иное'
                                          ,chr(254)
                                          ,chr(168)) PULT_EN_2
                               FROM p_pol_header ph
                               JOIN p_policy pp
                                 ON pp.pol_header_id = ph.policy_header_id
                                AND pp.version_num = 1
                               JOIN as_asset ass
                                 ON ass.p_policy_id = pp.policy_id
                               JOIN as_property ap
                                 ON ap.as_property_id = ass.as_asset_id
                               JOIN T_PULT_SIGNALLING ps
                                 ON ps.t_pult_signalling_id = ap.t_pult_signalling_id
                              WHERE ph.policy_header_id = P_policy_header_id) t1
                           ,(SELECT OBJ_TYPE   PULT_TYPE
                                   ,OBJ_ENABLE PULT_EN_1
                                   ,OBJ_NAME   PULT_NAME_1
                                   ,OBJ_NOTE   PULT_EN_2
                                   ,OBJ_SUM    PULT_NAME_2
                               FROM TABLE(TT_PROPERTY_UL(TO_PROPERTY_UL(1
                                                                       ,NULL
                                                                       ,'В комнате охраны'
                                                                       ,NULL
                                                                       ,'На пульт отделения милиции ')
                                                        ,TO_PROPERTY_UL(2
                                                                       ,NULL
                                                                       ,'Вневедомственной охраны'
                                                                       ,NULL
                                                                       ,'Иное:')))) t2
                      WHERE t2.PULT_type = t1.PULT_type(+)
                      ORDER BY t2.PULT_TYPE)
    LOOP
      PIPE ROW(TO_PROPERTY_UL(temp_cur.PULT_TYPE
                             ,temp_cur.PULT_EN_1
                             ,temp_cur.PULT_NAME_1
                             ,temp_cur.PULT_EN_2
                             ,temp_cur.PULT_NAME_2));
    END LOOP;
    RETURN;
  END get_pult_list;

  ---------------------------------------------------------------------------------------------------------------

  FUNCTION get_risk_list(p_policy_header_id NUMBER) RETURN TT_PROPERTY_UL
    PIPELINED IS
  BEGIN
    FOR temp_cur IN (SELECT t2.risk_type
                           ,decode(t1.risk_enable, NULL, chr(168), chr(254)) risk_enable
                           ,t2.risk_name
                       FROM (SELECT RISK_TYPE
                                   ,1 RISK_ENABLE
                               FROM (SELECT CASE plo.description
                                              WHEN 'Пожар' THEN
                                               1
                                              WHEN 'Удар молнии' THEN
                                               1
                                              WHEN 'Взрыв бытового газа' THEN
                                               1
                                              WHEN 'Стихийные бедствия' THEN
                                               2
                                              WHEN
                                               'Повреждение застрахованного имущества водой из водопроводных, канализационных, отопительных систем' THEN
                                               3
                                              WHEN
                                               'Повреждение имущества водой из систем водоснабжения, отопления, канализации и аналогичных систем' THEN
                                               3
                                              WHEN 'Повреждение водой' THEN
                                               3
                                              WHEN 'Противоправные действия третьих лиц' THEN
                                               4
                                              WHEN 'Кража со взломом и грабеж' THEN
                                               4
                                              WHEN 'Кража со взломом/грабеж/разбой' THEN
                                               4
                                              WHEN
                                               'Падение на застрахованное имущество пилотируемых летающих объектов или их обломков' THEN
                                               5
                                              ELSE
                                               6
                                            END RISK_TYPE
                                       FROM p_pol_header ph
                                       JOIN p_policy pp
                                         ON pp.pol_header_id = ph.policy_header_id
                                        AND pp.version_num = 1
                                       JOIN as_asset ass
                                         ON ass.p_policy_id = pp.policy_id
                                       JOIN p_cover pc
                                         ON pc.as_asset_id = ass.as_asset_id
                                       JOIN t_prod_line_option plo
                                         ON pc.t_prod_line_option_id = plo.ID
                                      WHERE ph.policy_header_id = P_policy_header_id)
                              GROUP BY RISK_TYPE
                                      ,1) t1
                           ,(SELECT OBJ_TYPE   RISK_TYPE
                                   ,OBJ_ENABLE RISK_ENABLE
                                   ,OBJ_NAME   RISK_NAME
                               FROM TABLE(TT_PROPERTY_UL(TO_PROPERTY_UL(1
                                                                       ,NULL
                                                                       ,'Пожар, удар молнии, взрыв бытового газа '
                                                                       ,NULL
                                                                       ,NULL)
                                                        ,TO_PROPERTY_UL(2
                                                                       ,NULL
                                                                       ,'Стихийные бедствия'
                                                                       ,NULL
                                                                       ,NULL)
                                                        ,TO_PROPERTY_UL(3
                                                                       ,NULL
                                                                       ,'Повреждение имущества водой (из водопроводных, канализационных, отопительных и противопожарных систем), проникновение воды из соседних (чужих) помещений'
                                                                       ,NULL
                                                                       ,NULL)
                                                        ,TO_PROPERTY_UL(4
                                                                       ,NULL
                                                                       ,'Противоправные действия   третьих лиц (кража со взломом, грабеж, разбойное нападение, умышленное уничтожение и повреждение имущества или его частей)'
                                                                       ,NULL
                                                                       ,NULL)
                                                        ,TO_PROPERTY_UL(5
                                                                       ,NULL
                                                                       ,'Падение пилотируемых летающих средств и их обломков'
                                                                       ,NULL
                                                                       ,NULL)
                                                        ,TO_PROPERTY_UL(6
                                                                       ,NULL
                                                                       ,'Иные риски:' || chr(10) ||
                                                                        chr(13) ||
                                                                        PKG_PRTS_UTILS.get_risk_names(P_policy_header_id)
                                                                       ,NULL
                                                                       ,NULL)))) t2
                      WHERE t2.RISK_type = t1.RISK_type(+)
                      ORDER BY t2.RISK_TYPE)
    LOOP
      PIPE ROW(TO_PROPERTY_UL(temp_cur.RISK_TYPE, temp_cur.RISK_ENABLE, temp_cur.RISK_NAME, '', ''));
    END LOOP;
    RETURN;
  END get_risk_list;

  --------------------------------------------------------------------------------------------------------------- 

  FUNCTION get_risk_names(p_policy_header_id NUMBER) RETURN VARCHAR2 IS
    p_str VARCHAR2(2000);
  BEGIN
    FOR temp_rec IN (SELECT *
                       FROM (SELECT CASE plo.description
                                      WHEN 'Пожар' THEN
                                       1
                                      WHEN 'Удар молнии' THEN
                                       1
                                      WHEN 'Взрыв бытового газа' THEN
                                       1
                                      WHEN 'Стихийные бедствия' THEN
                                       2
                                      WHEN
                                       'Повреждение застрахованного имущества водой из водопроводных, канализационных, отопительных систем' THEN
                                       3
                                      WHEN
                                       'Повреждение имущества водой из систем водоснабжения, отопления, канализации и аналогичных систем' THEN
                                       3
                                      WHEN 'Повреждение водой' THEN
                                       3
                                      WHEN 'Противоправные действия третьих лиц' THEN
                                       4
                                      WHEN 'Кража со взломом и грабеж' THEN
                                       4
                                      WHEN 'Кража со взломом/грабеж/разбой' THEN
                                       4
                                      WHEN
                                       'Падение на застрахованное имущество пилотируемых летающих объектов или их обломков' THEN
                                       5
                                      ELSE
                                       6
                                    END RISK_TYPE
                                   ,plo.description
                               FROM p_pol_header ph
                               JOIN p_policy pp
                                 ON pp.pol_header_id = ph.policy_header_id
                                AND pp.version_num = 1
                               JOIN as_asset ass
                                 ON ass.p_policy_id = pp.policy_id
                               JOIN p_cover pc
                                 ON pc.as_asset_id = ass.as_asset_id
                               JOIN t_prod_line_option plo
                                 ON pc.t_prod_line_option_id = plo.ID
                              WHERE ph.policy_header_id = P_policy_header_id)
                      WHERE RISK_TYPE = 6
                      GROUP BY RISK_TYPE
                              ,DESCRIPTION)
    LOOP
      IF p_str IS NOT NULL
         AND length(p_str) > 0
      THEN
        p_str := p_str || ';' || temp_rec.description;
      ELSE
        p_str := temp_rec.description;
      END IF;
    END LOOP;
  
    RETURN p_str;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_risk_names;

  --------------------------------------------------------------------------------------------------------------- 

  FUNCTION get_as_asset_id(p_policy_header_id NUMBER) RETURN NUMBER IS
    p_as_asset_id NUMBER;
  BEGIN
  
    SELECT ass.as_asset_id
      INTO p_as_asset_id
      FROM p_pol_header ph
      JOIN p_policy pp
        ON pp.pol_header_id = ph.policy_header_id
       AND pp.version_num = 1
      JOIN p_policy_contact ppc
        ON ppc.policy_id = pp.policy_id
      JOIN t_contact_pol_role cpr
        ON cpr.id = ppc.contact_policy_role_id
       AND cpr.brief = 'Страхователь'
      JOIN as_asset ass
        ON ass.p_policy_id = pp.policy_id
      JOIN p_asset_header ah
        ON ah.p_asset_header_id = ass.p_asset_header_id
      JOIN t_asset_type tat
        ON tat.t_asset_type_id = ah.t_asset_type_id
       AND tat.brief = 'AT1'
     WHERE ph.policy_header_id = P_policy_header_id
       AND rownum = 1; --52021,51579
  
    RETURN p_as_asset_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END get_as_asset_id;

  --------------------------------------------------------------------------------------------------------------- 
  --для текущего адреса и pph список "Использ. огнеопасных материалов" 
  FUNCTION get_inflam_mat
  (
    p_as_asset_id   NUMBER
   ,p_cn_address_id NUMBER
  ) RETURN VARCHAR2 IS
    ret_tmp VARCHAR(2000);
  BEGIN
    FOR temp_rec IN (SELECT ap.use_inflam_mat
                       FROM as_property ap
                       JOIN cn_address ca
                         ON ca.id = ap.cn_address_id
                      WHERE ap.as_property_id = p_as_asset_id
                        AND ap.use_inflam_mat IS NOT NULL
                        AND ca.id = p_cn_address_id)
    LOOP
      IF ret_tmp IS NOT NULL
         AND length(ret_tmp) > 0
      THEN
        ret_tmp := ret_tmp || ';' || temp_rec.use_inflam_mat;
      ELSE
        ret_tmp := temp_rec.use_inflam_mat;
      END IF;
    END LOOP;
  
    RETURN ret_tmp;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
    
  END get_inflam_mat;

--------------------------------------------------------------------------------------------------------------- 

END PKG_PRTS_UTILS;
/

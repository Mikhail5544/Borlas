CREATE OR REPLACE PACKAGE PKG_XX10_CLAIM_CONTROL IS

  --проверка что нет права "Андерайтер автострах." и продукт - Автокаско

  FUNCTION check_victim(p_c_claim_id NUMBER) RETURN NUMBER;

END PKG_XX10_CLAIM_CONTROL;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX10_CLAIM_CONTROL IS
  /*
  При переводе убытка в статус "Закрыто" при
  условии что убыток, зарегистрирован по
  полису ОСАГО и среди ущербов есть или 
  "Расходы на погребение" или "Возмещение
  утрачен. заработка в связи со смертью
  кормильца" обязательное указание среди
  участников контакта с ролью "потерпевший"
  */

  FUNCTION check_victim(p_c_claim_id NUMBER) RETURN NUMBER IS
    l_c_claim_header_id NUMBER(12);
    l_product_brief     VARCHAR2(200);
  
  BEGIN
    SELECT ch.c_claim_header_id
          ,tp.brief
      INTO l_c_claim_header_id
          ,l_product_brief
      FROM t_product      tp
          ,p_pol_header   ph
          ,p_policy       pp
          ,c_claim        cc
          ,c_claim_header ch
     WHERE 1 = 1
       AND cc.c_claim_id = p_c_claim_id
       AND ch.c_claim_header_id = cc.c_claim_header_id
       AND pp.policy_id = ch.p_policy_id
       AND ph.policy_header_id = pp.pol_header_id
       AND tp.product_id = ph.product_id;
  
    IF l_product_brief != 'ОСАГО'
    THEN
      RETURN 1;
    END IF;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                 WHERE 1 = 1
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.id = d.t_damage_code_id
                   AND dc.brief IN ('ПОГРЕБЕНИЕ', 'УТРЗАРАБСМЕРТЬ')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = 'Потерпевший'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN ('Потерпевшие - несовершеннолетние, кроме детей-инвалидов'
                                                 ,'Потерпевшие - учащиеся старше 18 лет'
                                                 ,'Потерпевшие - мужчины старше 60 лет'
                                                 ,'Потерпевшие - другие лица')))
    LOOP
      RETURN 0;
    END LOOP;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,t_peril       tp
                 WHERE tp.brief = 'ОСАГО_ЗДОРОВЬЕ'
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.peril = tp.id
                   AND dc.id = d.t_damage_code_id
                   AND dc.brief NOT IN ('ПОГРЕБЕНИЕ', 'УТРЗАРАБСМЕРТЬ')
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = 'Потерпевший'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN
                               ('Потерпевшие - собственники ТС,получившие увечья'
                               ,'Потерпевшие - иные владельцы ТС,получившие увечья'
                               ,'Потерпевшие - пассажиры,получившие увечья'
                               ,'Потерпевшие - пешеходы,получившие увечья'
                               ,'Потерпевшие - прочие лица,получившие увечья'
                               ,'Потерпевшие - собственники ТС,получившие иное повреждение здоровью'
                               ,'Потерпевшие - иные владельцы ТС,получившие иное повреждение здоровью'
                               ,'Потерпевшие - пассажиры,получившие иное повреждение здоровью'
                               ,'Потерпевшие - пешеходы,получившие иное повреждение здоровью'
                               ,'Потерпевшие - прочие лица,получившие иное повреждение здоровью')))
    LOOP
      RETURN 0;
    END LOOP;
  
    FOR cur IN (SELECT 1
                  FROM c_damage      d
                      ,t_damage_code dc
                      ,t_peril       tp
                 WHERE tp.brief = 'ОСАГО_ИМУЩЕСТВО'
                   AND d.c_claim_id = p_c_claim_id
                   AND dc.peril = tp.id
                   AND dc.id = d.t_damage_code_id
                   AND NOT EXISTS
                 (SELECT 1
                          FROM C_EVENT_CONTACT      ec
                              ,C_EVENT_CONTACT_ROLE ecr
                              ,t_victim_osago_type  vt
                         WHERE 1 = 1
                           AND ec.C_CLAIM_HEADER_ID = l_c_claim_header_id
                           AND ecr.C_EVENT_CONTACT_ROLE_ID = ec.C_EVENT_CONTACT_ROLE_ID
                           AND ecr.brief = 'Потерпевший'
                           AND vt.t_victim_osago_type_id = ec.t_victim_osago_type_id
                           AND vt.description IN
                               ('Потерпевшие - собственники ТС, получившие ущерб имуществу'
                               ,'Потерпевшие - иные владельцы ТС, получившие ущерб имуществу'
                               ,'Потерпевшие - пассажиры, получившие ущерб имуществу'
                               ,'Потерпевшие - пешеходы, получившие ущерб имуществу'
                               ,'Потерпевшие - прочие лица, получившие ущерб имуществу')))
    LOOP
      RETURN 0;
    END LOOP;
  
    RETURN 1;
  
  END;

END;
/

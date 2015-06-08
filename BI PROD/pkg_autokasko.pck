CREATE OR REPLACE PACKAGE PKG_AUTOKASKO IS

  --проверка что нет права "Андерайтер автострах." и продукт - Автокаско

  FUNCTION is_not_auto_undewriter(p_p_policy_id NUMBER) RETURN NUMBER;

  --проверка что кол-во ключей равно 1

  FUNCTION is_one_key(p_p_policy_id NUMBER) RETURN NUMBER;

  --страх. стоимость больше 150 000 USD

  FUNCTION is_big_ins_price(p_p_policy_id NUMBER) RETURN NUMBER;

  --срок эксплуатации ТС отечест. больше 7 лет, иностр. больше 10 лет

  FUNCTION is_big_expl_term(p_p_policy_id NUMBER) RETURN NUMBER;

  --страховая сумма по рискам "Гражд. отв." и "Несч. случай" больше 100 000 USD

  FUNCTION is_big_ins_amount(p_p_policy_id NUMBER) RETURN NUMBER;

  --страх. стоимость риска "Доп. оборудовани" - 20% или более от страх. стоимости ТС

  FUNCTION is_more_eq_amount(p_p_policy_id NUMBER) RETURN NUMBER;

  --оператором установлен андеррайтерский коэффициент

  FUNCTION is_not_fixed_coef(p_p_policy_id NUMBER) RETURN NUMBER;

  --страховая премия расчитывается в "ручном" режиме

  FUNCTION is_handchange_amount(p_p_policy_id NUMBER) RETURN NUMBER;

  --Комиссия по договору с учетом поправочного коэффициента превышает 25%

  FUNCTION is_big_comiss(p_p_policy_id NUMBER) RETURN NUMBER;

END PKG_AUTOKASKO;
/
CREATE OR REPLACE PACKAGE BODY PKG_AUTOKASKO IS

  FUNCTION is_not_auto_undewriter(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    FOR rec IN (SELECT p.*
                  FROM ven_as_asset     ass
                      ,ven_p_policy     p
                      ,ven_p_pol_header ph
                      ,ven_t_product    pr
                 WHERE safety.check_right_custom('AUTO_UNDEWRITER') = 0
                   AND p.policy_id = p_p_policy_id
                   AND ass.p_policy_id = p.policy_id
                   AND p.pol_header_id = ph.policy_header_id
                   AND ph.product_id = pr.product_id
                   AND (pr.description LIKE '%Автокаско%' OR pr.description LIKE '%АвтоКаско%')
                   AND ROWNUM = 1)
    LOOP
      RETURN 1;
    END LOOP;
  
    RETURN 0;
  
  END is_not_auto_undewriter;

  FUNCTION is_one_key(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT v.*
                    FROM ven_p_policy   p
                        ,ven_as_asset   ass
                        ,ven_as_vehicle v
                   WHERE p.policy_id = p_p_policy_id
                     AND ass.p_policy_id = p.policy_id
                     AND v.as_vehicle_id = ass.as_asset_id
                     AND v.key_num = 1)
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_big_ins_price(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT p.*
                    FROM ven_p_policy     p
                        ,ven_p_cover      pc
                        ,ven_p_pol_header ph
                        ,ven_as_asset     ass
                        ,ven_fund         f
                   WHERE p.policy_id = p_p_policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND ass.p_policy_id = p.policy_id
                     AND ph.policy_id = p.policy_id
                     AND f.fund_id = ph.fund_id
                     AND DECODE(f.brief, 'USD', ass.ins_price, ass.ins_price / p.fix_rate) > 150000)
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_big_expl_term(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT vm.is_national_mark is_national_mark
                        ,MONTHS_BETWEEN(p.start_date, TO_DATE(v.model_year, 'yyyy')) / 12 term
                    FROM ven_p_policy       p
                        ,ven_as_asset       ass
                        ,AS_VEHICLE         v
                        ,ven_t_vehicle_mark vm
                   WHERE p.policy_id = p_p_policy_id
                     AND ass.p_policy_id = p.policy_id
                     AND v.as_vehicle_id = ass.as_asset_id
                     AND v.t_vehicle_mark_id = vm.t_vehicle_mark_id)
      LOOP
        IF rec.is_national_mark = 1
           AND rec.term > 7
        THEN
          RETURN 0;
        ELSIF rec.is_national_mark = 0
              AND rec.term > 10
        THEN
          RETURN 0;
        END IF;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_big_ins_amount(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT DISTINCT plo.description
                    FROM ven_p_policy           p
                        ,ven_t_prod_line_option plo
                        ,ven_p_cover            pc
                        ,ven_as_asset           ass
                        ,ven_p_pol_header       ph
                        ,ven_fund               f
                   WHERE p.policy_id = p_p_policy_id
                     AND p.policy_id = ass.p_policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND pc.t_prod_line_option_id = plo.ID
                     AND (plo.description LIKE '%Гражданская ответственность%' OR
                         plo.description LIKE '%НС%' OR UPPER(plo.description) LIKE '%НЕСЧАСТНЫ%')
                     AND ph.policy_id = p.policy_id
                     AND f.fund_id = ph.fund_id
                     AND DECODE(f.brief
                               ,'USD'
                               ,NVL(pc.ins_amount, 0)
                               ,NVL(pc.ins_amount, 0) / p.fix_rate) > 100000
                  
                  )
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_more_eq_amount(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT SUM(vs.price) OVER(PARTITION BY vs.as_vehicle_id, pc.p_cover_id) price
                        ,ass.ins_price ins_price
                    FROM ven_p_policy     p
                        ,ven_p_cover      pc
                        ,ven_as_asset     ass
                        ,AS_VEHICLE       v
                        ,AS_VEHICLE_STUFF vs
                   WHERE p.policy_id = p_p_policy_id
                     AND p.policy_id = ass.p_policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND v.as_vehicle_id = ass.as_asset_id
                     AND v.as_vehicle_id = vs.as_vehicle_id)
      LOOP
        IF NVL(rec.price, 0) >= 0.2 * NVL(rec.ins_price, 0)
        THEN
          RETURN 0;
        END IF;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_not_fixed_coef(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT p.*
                    FROM ven_p_policy         p
                        ,ven_as_asset         ass
                        ,ven_p_cover          pc
                        ,P_COVER_COEF         c
                        ,ven_t_prod_coef_type ct
                   WHERE p.policy_id = p_p_policy_id
                     AND p.policy_id = ass.p_policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND c.p_cover_id = pc.p_cover_id
                     AND c.t_prod_coef_type_id = ct.t_prod_coef_type_id
                     AND ct.brief LIKE '%CASCO_DAMAGE_K15%'
                     AND c.val <> 1)
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_handchange_amount(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT p.*
                    FROM ven_p_policy         p
                        ,ven_as_asset         ass
                        ,ven_p_cover          pc
                        ,ven_p_cover_coef     pcc
                        ,ven_t_prod_coef_type pct
                   WHERE p.policy_id = p_p_policy_id
                     AND ass.p_policy_id = p.policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND pcc.p_cover_id = pc.p_cover_id
                     AND pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                     AND pcc.default_val <> pcc.val
                     AND pct.brief IN ('CASCO_DAMAGE_K4'
                                      ,'CASCO_DAMAGE_K15'
                                      ,'CASCO_COEF_35'
                                      ,'CASCO_COEF_91'
                                      ,'CASCO_DAMAGE_K10_1'))
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

  FUNCTION is_big_comiss(p_p_policy_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    IF is_not_auto_undewriter(p_p_policy_id) = 1
    THEN
    
      FOR rec IN (SELECT c.*
                    FROM ven_p_policy_agent     pa
                        ,ven_p_pol_header       ph
                        ,ven_p_policy           p
                        ,ven_p_cover            pc
                        ,ven_as_asset           ass
                        ,ven_p_policy_agent_com c
                        ,ven_ag_type_rate_value tv
                         --, ven_doc_status      ds
                        ,ven_doc_status_ref dr
                   WHERE p.policy_id = p_p_policy_id
                     AND ass.p_policy_id = p.policy_id
                     AND pc.as_asset_id = ass.as_asset_id
                     AND p.policy_id = ph.policy_id
                     AND ph.policy_header_id = pa.policy_header_id
                     AND pa.p_policy_agent_id = c.p_policy_agent_id
                     AND tv.ag_type_rate_value_id = c.ag_type_rate_value_id
                     AND tv.brief = 'PERCENT'
                     AND pa.status_id = dr.doc_status_ref_id
                        --and ds.doc_status_id = pa.status_id
                        --and ds.doc_status_ref_id = dr.doc_status_ref_id
                     AND dr.brief <> 'CANCEL'
                     AND c.val_com > 25)
      LOOP
        RETURN 0;
      END LOOP;
    
    END IF;
  
    RETURN 1;
  
  END;

END;
/

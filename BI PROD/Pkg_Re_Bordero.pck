CREATE OR REPLACE PACKAGE Pkg_Re_Bordero IS

  /**
  * Процедуры по формированию различных типов бордеро
  * @author BALASHOV A.
  *
  */

  /**
  * Функция проверяет подлежит ди перестрахованию product_line_option
  * @author BALASHOV A.
  * @param par_pl_id - ИД программы в продукте
  * @param par_asset_id - ИД объекта стархования
  * @return 1 - подлежит, 0 - нет
  */
  FUNCTION cover_reins
  (
    par_pl_id    IN NUMBER
   ,par_asset_id IN NUMBER
  ) RETURN NUMBER;

  /**
  * Процедура подсчета сальдо пакета бордеро
  * @author BALASHOV A.
  * @param par_package - ИД пакета бордеро
  */
  PROCEDURE calc_package_saldo(par_package IN NUMBER);

  /**
  * Процедура создания бордеро первых платежей
  * @author BALASHOV A.
  * @param par_bordero_id - ИД бордеро
  * @param retr - признак ретроцессии
  */
  PROCEDURE create_bordero_first
  (
    par_bordero_id IN NUMBER
   ,retr           IN NUMBER DEFAULT 0
  );

  /**
  * Процедура удаления пакета бордеро премий
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE delete_bordero_first(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления бордеро премий
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE nach_bordero_prem(par_bordero_id IN NUMBER);

  /**
  * Процедура создания бордеро первых платежей неподтвержденных
  * @author BALASHOV A.
  * @param par_bordero_id - ИД  бордеро
  */
  PROCEDURE create_bordero_second(par_bordero_id IN NUMBER);

  /**
  * Процедура удаления пакета бордеро первых платежей (неподтвержденное)
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE delete_bordero_second(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления пакето бордеро премий
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE za4et_bordero_prem(par_bordero_id IN NUMBER);

  /**
  * Процедура создания бордеро заявленных убытков
  * @author BALASHOV A.
  * @param par_bordero_id - ИД бордеро
  */
  PROCEDURE create_bordero_declared_loss(par_bordero_id IN NUMBER);

  /**
  * Процедура создания бордеро оплаченных убытков
  * @author BALASHOV A.
  * @param par_bordero_id - ИД  бордеро
  */
  PROCEDURE create_bordero_payment_loss(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления бордеро убытков
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE nach_bordero_loss(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления пакето бордеро убытков
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE za4et_bordero_loss(par_bordero_id IN NUMBER);

  /**
  * Процедура удаления пакета бордеро заявленных убытков
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE delete_bordero_loss(par_bordero_id IN NUMBER);

  /**
  * Процедура создания бордеро расторжений
  * @author BALASHOV A.
  * @param par_bordero_id - ИД  бордеро
  */
  PROCEDURE create_bordero_rast(par_bordero_id IN NUMBER);

  /**
  * Процедура удаления пакета бордеро расторжений
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE delete_bordero_rast(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления бордеро расторжений
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE nach_bordero_rast(par_bordero_id IN NUMBER);

  /**
  * Процедура начисления пакето бордеро расторжений
  * @author BALASHOV A.
  * @param par_bordero_id - ИД пакета бордеро
  */
  PROCEDURE za4et_bordero_rast(par_bordero_id IN NUMBER);

  /**
  * Процедура создания платежа
  * @author BALASHOV A.
  * @param par_package_bordero - ИД пакета бордеро
  */
  PROCEDURE create_doc(par_package_bordero IN NUMBER);

  /**
  * Функция копирования версий договора перестархования
  * @author BALASHOV A.
  * @param par_recont_ver_id_in - ИД версии договора
  * @return ИД версии договора
  */
  FUNCTION copy_ver_contract(par_recont_ver_id_in IN NUMBER) RETURN NUMBER;

END Pkg_Re_Bordero;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Re_Bordero IS

  -- подлежит ди перестрахованию product_line_option
  FUNCTION cover_reins
  (
    par_pl_id    IN NUMBER
   ,par_asset_id IN NUMBER
  ) RETURN NUMBER IS
    ex NUMBER;
  
    v_ins  NUMBER;
    v_pr   NUMBER;
    v_as   NUMBER;
    v_pl   NUMBER;
    v_ag   NUMBER;
    v_insr NUMBER;
  BEGIN
  
    SELECT pl.insurance_group_id c_ins
          , --вид страхования
           pl.id                 c_pl
      INTO v_ins
          ,v_pl
      FROM t_product_line pl
     WHERE pl.id = par_pl_id;
  
    FOR cur IN (SELECT ph.product_id      v_pr
                      , -- продукт
                       ah.t_asset_type_id v_as
                      , -- вид объекта
                       ag.contact_id      v_ag
                      , -- агент
                       iss.contact_id     v_insr -- страхователь
                  FROM as_asset ass
                      ,p_policy pp
                      ,p_asset_header ah
                      ,p_pol_header ph
                      ,(SELECT ppc.policy_id
                              ,ppc.contact_id
                          FROM p_policy_contact   ppc
                              ,T_CONTACT_POL_ROLE cpr
                         WHERE cpr.brief = 'Страхователь'
                           AND cpr.id = ppc.contact_policy_role_id) iss
                      ,(SELECT ppc.policy_id
                              ,ppc.contact_id
                          FROM p_policy_contact   ppc
                              ,T_CONTACT_POL_ROLE cpr
                         WHERE cpr.brief = 'Агент'
                           AND cpr.id = ppc.contact_policy_role_id) ag
                 WHERE ass.as_asset_id = par_asset_id
                   AND pp.policy_id = ass.p_policy_id
                   AND ah.p_asset_header_id = ass.p_asset_header_id
                   AND ph.policy_header_id = pp.pol_header_id
                   AND iss.policy_id = pp.policy_id
                   AND ag.policy_id(+) = pp.policy_id
                
                )
    LOOP
    
      FOR filter IN (SELECT v.insurance_group_id f_ins
                           ,v.product_id         f_pr
                           ,v.asset_type_id      f_as
                           ,v.product_line_id    f_pl
                           ,v.agent_id           f_ag
                           ,v.issuer_id          f_is
                       FROM re_main_contract rmc
                       JOIN re_contract_version rcv
                         ON rcv.re_contract_version_id = rmc.last_version_id
                       JOIN re_cond_filter_obl v
                         ON v.re_contract_ver_id = rcv.re_contract_version_id)
      LOOP
        ex := 1;
        IF (filter.f_ins IS NOT NULL AND filter.f_ins != v_ins)
        THEN
          ex := 0;
        END IF;
        IF (filter.f_pr IS NOT NULL AND filter.f_pr != cur.v_pr)
        THEN
          ex := 0;
        END IF;
        IF (filter.f_as IS NOT NULL AND filter.f_as != cur.v_as)
        THEN
          ex := 0;
        END IF;
        IF (filter.f_pl IS NOT NULL AND filter.f_pl != v_pl)
        THEN
          ex := 0;
        END IF;
        IF (filter.f_ag IS NOT NULL AND filter.f_ag != cur.v_ag)
        THEN
          ex := 0;
        END IF;
        IF (filter.f_is IS NOT NULL AND filter.f_is != cur.v_insr)
        THEN
          ex := 0;
        END IF;
      
        IF ex = 1
        THEN
          RETURN ex;
        END IF;
      END LOOP;
    END LOOP;
  
    RETURN ex;
  END;

  PROCEDURE calc_package_saldo(par_package IN NUMBER) IS
    pack_fund NUMBER;
    pack_date DATE;
    res       NUMBER;
  BEGIN
  
    SELECT bp.fund_pay_id
          ,bp.accept_date
      INTO pack_fund
          ,pack_date
      FROM re_bordero_package bp
     WHERE bp.re_bordero_package_id = par_package;
  
    res := 0;
    FOR b IN (SELECT bt.brief
                    ,b.fund_id
                    ,b.netto_premium
                    ,b.payment_sum
                    ,b.return_sum
                FROM re_bordero b
                JOIN re_bordero_type bt
                  ON bt.re_bordero_type_id = b.re_bordero_type_id
              --  join fund f on f.fund_id = b.fund_id
                JOIN re_bordero_package bp
                  ON bp.re_bordero_package_id = b.re_bordero_package_id
               WHERE bp.re_bordero_package_id = par_package)
    LOOP
      CASE b.brief
        WHEN 'БОРДЕРО_ПРЕМИЙ' THEN
          res := res +
                 NVL(b.netto_premium * Acc.Get_Cross_Rate_By_Id(1, b.fund_id, pack_fund, pack_date), 0);
        WHEN 'БОРДЕРО_ДОПЛАТ' THEN
          res := res +
                 NVL(b.netto_premium * Acc.Get_Cross_Rate_By_Id(1, b.fund_id, pack_fund, pack_date), 0);
        WHEN 'БОРДЕРО_ЗАЯВ_УБЫТКОВ' THEN
          NULL;
        WHEN 'БОРДЕРО_ОПЛ_УБЫТКОВ' THEN
          res := res -
                 NVL(b.payment_sum * Acc.Get_Cross_Rate_By_Id(1, b.fund_id, pack_fund, pack_date), 0);
        WHEN 'БОРДЕРО_РАСТОРЖЕНИЙ' THEN
          res := res -
                 NVL(b.return_sum * Acc.Get_Cross_Rate_By_Id(1, b.fund_id, pack_fund, pack_date), 0);
        WHEN 'БОРДЕРО_РЕГРЕССОВ' THEN
          NULL;
      END CASE;
      NULL;
    END LOOP;
  
    UPDATE re_bordero_package bp
       SET bp.summ = NVL(res, 0)
     WHERE bp.re_bordero_package_id = par_package;
  
  END calc_package_saldo;

  PROCEDURE create_bordero_first
  (
    par_bordero_id IN NUMBER
   ,retr           IN NUMBER DEFAULT 0
  ) IS
    v_p_cover       ven_p_cover%ROWTYPE;
    v_re_cover      ven_re_cover%ROWTYPE;
    v_re_line_cover ven_re_line_cover%ROWTYPE;
    v_re_bordero    ven_re_bordero%ROWTYPE;
    db              DATE;
    de              DATE;
    recont          NUMBER;
    cont_ver        NUMBER;
    ex              NUMBER;
    all_amount      NUMBER;
    fact_pr         NUMBER;
    other_partsum   NUMBER;
  
  BEGIN
  
    -- определяем период,за который ищутся начисления и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,CV.re_main_contract_id
          ,CV.re_contract_version_id
      INTO db
          ,de
          ,recont
          , -- заголовок обл договора перестрахования
           cont_ver -- версия обл договора перестрахования, по которому сформирован пакет бордеро
      FROM re_bordero b
      JOIN re_bordero_package bp
        ON bp.re_bordero_package_id = b.re_bordero_package_id
      JOIN re_contract_version CV
        ON CV.re_contract_version_id = bp.re_contract_id
     WHERE b.re_bordero_id = par_bordero_id;
  
    -- ичищаем содержимое бордеро ( если оно конечно уже есть)
    DELETE FROM re_cover r WHERE r.re_bordero_id = par_bordero_id;
  
    IF (retr = 0)
    THEN
      -- если не ретроцессия
    
      -- бежим по всевозможным фильтрам
      FOR filter IN (SELECT v.insurance_group_id f_ins
                           ,v.product_id         f_pr
                           ,v.asset_type_id      f_as
                           ,v.product_line_id    f_plo
                           ,v.agent_id           f_ag
                           ,v.issuer_id          f_is
                       FROM re_cond_filter_obl v
                      WHERE v.re_contract_ver_id = cont_ver)
      LOOP
      
        FOR cover IN (SELECT /*+ ORDERED */
                       pl.insurance_group_id c_ins
                      , -- вид страхования
                       ph.product_id c_pr
                      , -- продукт
                       plo.product_line_id c_plo
                      , -- линия продукта
                       iss.contact_id c_is
                      , -- страхователь
                       ph.fund_id f_id
                      , -- валюта ответственности
                       pc.p_cover_id pc_id
                      , -- ид п_кавера
                       pp.policy_id pp_id
                      , -- ид п_полиси
                       pc.start_date sd
                      ,pc.end_date ed
                      ,pc.premium prem
                      , -- премия по п-каверу
                       pc.ins_amount ins_am
                      , -- стр сумам по п-каверу
                       SUM(tr.acc_amount) nach_pr -- начислено премии в отчетном периоде по п-каверу
                        FROM trans tr
                        JOIN trans_templ tt
                          ON tt.trans_templ_id = tr.trans_templ_id
                        JOIN p_cover pc
                          ON pc.p_cover_id = tr.A5_DT_URO_ID
                        JOIN t_prod_line_option plo
                          ON plo.id = pc.t_prod_line_option_id
                        JOIN t_product_line pl
                          ON pl.id = plo.product_line_id
                        JOIN as_asset ass
                          ON ass.as_asset_id = pc.as_asset_id
                        JOIN p_policy pp
                          ON pp.policy_id = ass.p_policy_id
                        JOIN ven_p_pol_header ph
                          ON ph.policy_header_id = pp.pol_header_id
                        JOIN (SELECT ppc.policy_id
                                   ,ppc.contact_id
                               FROM p_policy_contact ppc
                               JOIN T_CONTACT_POL_ROLE cpr
                                 ON cpr.id = ppc.contact_policy_role_id
                              WHERE cpr.brief = 'Страхователь') iss
                          ON iss.policy_id = pp.policy_id
                       WHERE tt.brief = 'НачПремия'
                         AND tr.trans_date <= de
                         AND NOT EXISTS (SELECT 1
                                FROM re_cover rc
                               WHERE rc.p_cover_id = pc.p_cover_id
                                 AND rc.re_m_contract_id = recont)
                       GROUP BY pl.insurance_group_id
                               ,ph.product_id
                               ,plo.product_line_id
                               ,iss.contact_id
                               ,ph.fund_id
                               ,pc.p_cover_id
                               ,pp.policy_id
                               ,pc.start_date
                               ,pc.end_date
                               ,pc.premium
                               ,pc.ins_amount)
        LOOP
        
          SELECT * INTO v_p_cover FROM ven_p_cover pc WHERE pc.p_cover_id = cover.pc_id;
        
          ex := 1;
          -- вид страхования
          IF (filter.f_ins IS NOT NULL AND filter.f_ins != cover.c_ins)
          THEN
            ex := 0;
            -- продукт
          ELSIF (filter.f_pr IS NOT NULL AND filter.f_pr != cover.c_pr)
          THEN
            ex := 0;
            -- программа
          ELSIF (filter.f_plo IS NOT NULL AND filter.f_plo != cover.c_plo)
          THEN
            ex := 0;
            -- страхователь
          ELSIF (filter.f_is IS NOT NULL AND filter.f_is != cover.c_is)
          THEN
            ex := 0;
          END IF;
        
          IF (ex <> 0)
          THEN
            -- проверка на агента
            BEGIN
              SELECT COUNT(*)
                INTO ex
                FROM p_policy_contact ppc
                JOIN T_CONTACT_POL_ROLE cpr
                  ON cpr.id = ppc.contact_policy_role_id
               WHERE cpr.brief = 'Агент'
                 AND ppc.policy_id = cover.pp_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ex := 0;
            END;
          END IF;
        
          IF (ex <> 0)
          THEN
            -- проверка на лимит ответственности по покрытию
            BEGIN
              SELECT 0
                INTO ex
                FROM t_prod_line_option plo
                LEFT JOIN ven_re_limit_contract rlc
                  ON rlc.t_product_line_id = plo.product_line_id
                 AND rlc.fund_id = cover.f_id
                 AND rlc.re_contract_version_id = cont_ver
                 AND rlc.LIMIT > v_p_cover.ins_amount
               WHERE plo.id = v_p_cover.t_prod_line_option_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ex := 1;
            END;
          
          END IF;
        
          -- проверка на наличие валюты ответственности на линиях эсцедента
          IF (ex <> 0)
          THEN
            BEGIN
              SELECT COUNT(*)
                INTO ex
                FROM re_line_contract rlc
               WHERE rlc.fund_id = cover.f_id
                 AND rlc.re_line_contract_id = cont_ver;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ex := 0;
            END;
          END IF;
        
          -- определяем сколько страховой суммы мы передали
          -- по другим договорам перестрахования по нашему п_каверу
          SELECT NVL(SUM(rc.part_sum), 0)
            INTO other_partsum
            FROM re_cover rc
           WHERE rc.p_cover_id = cover.pc_id;
        
          -- если выполнились все условия передачи покрытия и не все отдали в перестрахования,
          -- то передаем покрытие по нашему облигаторному договору перестрахования
          IF (ex <> 0 AND cover.ins_am > other_partsum)
          THEN
            -- добавляем re_cover
            BEGIN
              INSERT INTO re_cover
                (re_cover_id
                ,p_cover_id
                ,start_date
                ,end_date
                ,re_m_contract_id
                ,re_bordero_id
                ,re_contract_ver_id
                ,fund_id
                ,t_insurance_group_id)
                SELECT sq_re_cover.NEXTVAL
                      ,cover.pc_id
                      , -- ссылка на п_кавер
                       cover.sd
                      , -- дата начала
                       cover.ed
                      , -- дата окончания
                       recont
                      , -- заголовок обл догвора пер-я
                       par_bordero_id
                      , --ссылка на бордеро,в котором создан ре-кавер
                       cont_ver
                      , --версия обл договора пер-я
                       cover.f_id
                      , -- валюта отв-ти
                       cover.c_ins -- вид страхования
                  FROM dual;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL;
            END;
          
            -- выбираем запись re_cover
            SELECT *
              INTO v_re_cover
              FROM ven_re_cover r
             WHERE r.p_cover_id = cover.pc_id
               AND r.re_m_contract_id = recont
               AND r.re_bordero_id = par_bordero_id;
          
            -- добавляем re_line_cover
            DELETE FROM ven_re_line_cover r WHERE r.re_cover_id = v_re_cover.re_cover_id;
          
            all_amount := 0; -- общая страховая сумма уже посчитанная по лимитам
            -- цикл по линиям
            FOR cur IN (SELECT rlc.line_number
                              , -- номер линии
                               rlc.LIMIT
                              , -- лимит на линию
                               rlc.retention_perc
                              , -- соб удер в %
                               rlc.retention_val
                              , -- соб удер
                               rlc.part_perc
                              , -- доля пер-ка в %
                               rlc.part_sum
                              , -- доля пер-ка
                               rlc.tariff_ins
                              , -- страховой тариф
                               rlc.re_tariff
                              , -- перестрах тариф
                               rlc.commission_perc -- комисиия
                          FROM re_line_contract rlc
                         WHERE rlc.fund_id = cover.f_id
                           AND rlc.re_line_contract_id = cont_ver
                         ORDER BY rlc.line_number)
            LOOP
              -- показатели, которые подставляются с линии
              v_re_line_cover.re_cover_id     := v_re_cover.re_cover_id;
              v_re_line_cover.line_number     := cur.line_number;
              v_re_line_cover.retention_perc  := cur.retention_perc;
              v_re_line_cover.part_perc       := cur.part_perc;
              v_re_line_cover.commission_perc := cur.commission_perc;
            
              -- определение перестраховочного тарифа
              IF (cur.tariff_ins = 1)
              THEN
                -- если тариф в перестраховании совпадает со страховым тарифам
                v_re_line_cover.re_tariff := NVL(ROUND((cover.prem * 100 / cover.ins_am), 4), 0);
              ELSE
                -- если тариф в перестраховании не совпадает со страховым тарифам
                v_re_line_cover.re_tariff := NVL(cur.re_tariff, 0);
              END IF;
            
              -- определение лимита по каждой линии по ре-кавере
              v_re_line_cover.LIMIT := LEAST(cover.ins_am - other_partsum, cur.LIMIT);
            
              IF (cur.retention_val = 0)
              THEN
                -- если заполнен процент на линии
                v_re_line_cover.retention_val := ROUND(v_re_line_cover.LIMIT *
                                                       v_re_line_cover.retention_perc / 100
                                                      ,2); -- посчитали собственное удержиние по линии на ре-кавере
                v_re_line_cover.part_sum      := ROUND(v_re_line_cover.LIMIT *
                                                       v_re_line_cover.part_perc / 100
                                                      ,2); -- посчитали долю ответ перестраховщика по линии на ре-кавере
              ELSE
                -- заполнена абсолютная величина
                v_re_line_cover.retention_val  := LEAST(v_re_line_cover.LIMIT, cur.retention_val); -- минимум из указанной величины на линии на договоре и лимитом
                v_re_line_cover.retention_perc := ROUND(v_re_line_cover.retention_val * 100 /
                                                        v_re_line_cover.LIMIT
                                                       ,4);
                v_re_line_cover.part_sum       := v_re_line_cover.LIMIT -
                                                  v_re_line_cover.retention_val;
                v_re_line_cover.part_perc      := ROUND(v_re_line_cover.part_sum * 100 /
                                                        v_re_line_cover.LIMIT
                                                       ,4);
              END IF;
            
              v_re_line_cover.brutto_premium := NVL(ROUND(v_re_line_cover.part_sum *
                                                          v_re_line_cover.re_tariff / 100
                                                         ,2)
                                                   ,0);
              v_re_line_cover.commission     := NVL(ROUND(v_re_line_cover.brutto_premium *
                                                          v_re_line_cover.commission_perc / 100
                                                         ,2)
                                                   ,0);
              v_re_line_cover.netto_premium  := v_re_line_cover.brutto_premium -
                                                v_re_line_cover.commission;
            
              INSERT INTO ven_re_line_cover VALUES v_re_line_cover;
            
              all_amount := cur.LIMIT;
              IF (cover.ins_am - other_partsum <= all_amount)
              THEN
                EXIT;
              END IF;
            END LOOP;
          
            -- просуммируем все показатели на линиях по ре-каверу
            SELECT SUM(rlc.part_sum)
                  ,SUM(rlc.brutto_premium)
                  ,SUM(rlc.commission)
                  ,SUM(rlc.netto_premium)
              INTO v_re_cover.part_sum
                  ,v_re_cover.brutto_premium
                  ,v_re_cover.commission
                  ,v_re_cover.netto_premium
              FROM ven_re_line_cover rlc
             WHERE rlc.re_cover_id = v_re_cover.re_cover_id;
          
            UPDATE re_cover r
               SET (r.brutto_premium, r.commission, r.netto_premium, r.part_sum, r.ins_premium) =
                   (SELECT v_re_cover.brutto_premium
                          ,v_re_cover.commission
                          ,v_re_cover.netto_premium
                          ,v_re_cover.part_sum
                          ,cover.nach_pr
                      FROM dual)
             WHERE r.re_cover_id = v_re_cover.re_cover_id;
          
            -- связываем re_cover и re_bordero: rel_recover_rebordero
          
            -- вычисляем сколько поступило по нашему пи-каверу
            SELECT NVL(SUM(tr.acc_amount), 0)
              INTO fact_pr
              FROM trans tr
              JOIN trans_templ tt
                ON tt.trans_templ_id = tr.trans_templ_id
             WHERE tt.brief IN ('ЗачВзносСтрах', 'ЗачВзносАг')
               AND tr.trans_date BETWEEN db AND de
               AND tr.A5_CT_URO_ID = cover.pc_id;
          
            -- добавляем содержимое бордеро: связь бордеро с созданными ре-каверами
            BEGIN
              INSERT INTO rel_recover_bordero
                (rel_recover_bordero_id
                ,re_cover_id
                ,re_bordero_id
                ,brutto_premium
                ,commission
                ,netto_premium
                ,ins_premium)
                SELECT sq_rel_recover_bordero.NEXTVAL
                      ,v_re_cover.re_cover_id
                      ,par_bordero_id
                      ,ROUND(fact_pr * v_re_cover.brutto_premium / cover.nach_pr, 2)
                      ,ROUND(fact_pr * v_re_cover.commission / cover.nach_pr, 2)
                      ,ROUND(fact_pr * v_re_cover.netto_premium / cover.nach_pr, 2)
                      ,fact_pr
                  FROM dual;
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL;
            END;
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  
    -- суммируем все показатели по содержимому бордеро
    SELECT SUM(r.netto_premium)
          ,SUM(r.commission)
          ,SUM(r.brutto_premium)
      INTO v_re_bordero.netto_premium
          ,v_re_bordero.commission
          ,v_re_bordero.brutto_premium
      FROM rel_recover_bordero r
     WHERE r.re_bordero_id = par_bordero_id;
  
    UPDATE re_bordero r
       SET (netto_premium, commission, brutto_premium) =
           (SELECT v_re_bordero.netto_premium
                  ,v_re_bordero.commission
                  ,v_re_bordero.brutto_premium
              FROM dual)
     WHERE r.re_bordero_id = par_bordero_id;
    -- commit;
  END;

  PROCEDURE delete_bordero_first(par_bordero_id IN NUMBER) IS
  BEGIN
    DELETE FROM re_bordero rb WHERE rb.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE nach_bordero_prem(par_bordero_id IN NUMBER) IS
    v_templ_prem NUMBER;
    v_templ_com  NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_prem
      FROM oper_templ o
     WHERE o.brief = 'НачПремИсхПрстрх';
  
    SELECT o.oper_templ_id
      INTO v_templ_com
      FROM oper_templ o
     WHERE o.brief = 'НачКомИсхПрстрх';
  
    FOR rel IN (SELECT rc.re_cover_id
                      ,rc.ent_id
                      ,rc.brutto_premium
                      ,rc.commission
                  FROM ven_rel_recover_bordero rrb
                      ,ven_re_cover            rc
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rc.re_cover_id = rrb.re_cover_id)
    LOOP
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_prem
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_cover_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.brutto_premium
                                              ,'INS');
    
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_com
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_cover_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.commission
                                              ,'INS');
    
    END LOOP;
  END;

  PROCEDURE create_bordero_second(par_bordero_id IN NUMBER) IS
    v_re_cover   ven_re_cover%ROWTYPE;
    v_re_bordero ven_re_bordero%ROWTYPE;
    db           DATE;
    de           DATE;
    recont       NUMBER;
  BEGIN
  
    SELECT vrb.* INTO v_re_bordero FROM ven_re_bordero vrb WHERE vrb.re_bordero_id = par_bordero_id;
  
    DELETE FROM rel_recover_bordero r WHERE r.re_bordero_id = par_bordero_id;
  
    -- определяем период,за который ищутся поступление и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,CV.re_main_contract_id
      INTO db
          ,de
          ,recont
      FROM re_bordero b
      JOIN re_bordero_package bp
        ON bp.re_bordero_package_id = b.re_bordero_package_id
      JOIN re_contract_version CV
        ON CV.re_contract_version_id = bp.re_contract_id
     WHERE b.re_bordero_id = par_bordero_id;
  
    FOR cover IN (SELECT /*+ ORDERED */
                   rc.re_cover_id
                  ,tr.acc_amount post_pr
                    FROM trans tr
                    JOIN trans_templ tt
                      ON tt.trans_templ_id = tr.trans_templ_id
                    JOIN p_cover pc
                      ON pc.p_cover_id = tr.A5_CT_URO_ID
                    JOIN re_cover rc
                      ON rc.p_cover_id = pc.p_cover_id
                     AND rc.re_m_contract_id = recont
                    JOIN re_bordero rb
                      ON rb.re_bordero_id = rc.re_bordero_id
                     AND rb.re_bordero_package_id != v_re_bordero.re_bordero_package_id
                   WHERE tt.brief IN ('ЗачВзносСтрах', 'ЗачВзносАг')
                     AND tr.trans_date BETWEEN db AND de)
    LOOP
      -- связываем re_cover и re_bordero: rel_recover_rebordero
      SELECT * INTO v_re_cover FROM ven_re_cover r WHERE r.re_cover_id = cover.re_cover_id;
    
      BEGIN
        INSERT INTO rel_recover_bordero
          (rel_recover_bordero_id
          ,re_cover_id
          ,re_bordero_id
          ,brutto_premium
          ,commission
          ,netto_premium
          ,ins_premium)
          SELECT sq_rel_recover_bordero.NEXTVAL
                ,v_re_cover.re_cover_id
                ,par_bordero_id
                ,ROUND(cover.post_pr * v_re_cover.brutto_premium / v_re_cover.ins_premium, 2)
                ,ROUND(cover.post_pr * v_re_cover.commission / v_re_cover.ins_premium, 2)
                ,ROUND(cover.post_pr * v_re_cover.netto_premium / v_re_cover.ins_premium, 2)
                ,cover.post_pr
            FROM dual;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
      END;
    END LOOP;
  
    SELECT SUM(r.netto_premium)
          ,SUM(r.commission)
          ,SUM(r.brutto_premium)
      INTO v_re_bordero.netto_premium
          ,v_re_bordero.commission
          ,v_re_bordero.brutto_premium
      FROM rel_recover_bordero r
     WHERE r.re_bordero_id = par_bordero_id;
  
    UPDATE re_bordero r
       SET (netto_premium, commission, brutto_premium) =
           (SELECT v_re_bordero.netto_premium
                  ,v_re_bordero.commission
                  ,v_re_bordero.brutto_premium
              FROM dual)
     WHERE r.re_bordero_id = par_bordero_id;
    -- commit;
  END;

  PROCEDURE delete_bordero_second(par_bordero_id IN NUMBER) IS
  BEGIN
    DELETE FROM re_bordero rb WHERE rb.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE za4et_bordero_prem(par_bordero_id IN NUMBER) IS
    v_templ_prem NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_prem
      FROM oper_templ o
     WHERE o.brief = 'ВзаимозачПремИсхПрстрх';
  
    FOR rel IN (SELECT rc.re_cover_id
                      ,rc.ent_id
                      ,rrb.brutto_premium
                  FROM ven_rel_recover_bordero rrb
                      ,ven_re_cover            rc
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rc.re_cover_id = rrb.re_cover_id)
    LOOP
      IF (rel.brutto_premium > 0.00)
      THEN
        v_res_id := Acc_New.Run_Oper_By_Template(v_templ_prem
                                                ,par_bordero_id
                                                ,rel.ent_id
                                                ,rel.re_cover_id
                                                ,Doc.get_doc_status_id(par_bordero_id)
                                                ,1
                                                ,rel.brutto_premium
                                                ,'INS');
      END IF;
    END LOOP;
  END;

  PROCEDURE create_bordero_declared_loss(par_bordero_id IN NUMBER) IS
    v_re_claim_header ven_re_claim_header%ROWTYPE;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_re_damage       ven_re_damage%ROWTYPE;
    v_re_line_damage  ven_re_line_damage%ROWTYPE;
    db                DATE;
    de                DATE;
    recont            NUMBER;
    all_amount_dec    NUMBER;
    d_decsum          NUMBER;
  
  BEGIN
  
    DELETE FROM rel_recover_bordero r WHERE r.re_bordero_id = par_bordero_id;
  
    -- определяем период,за который ищутся заявленные убытки и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,CV.re_main_contract_id
      INTO db
          ,de
          ,recont
      FROM re_bordero b
      JOIN re_bordero_package bp
        ON bp.re_bordero_package_id = b.re_bordero_package_id
      JOIN re_contract_version CV
        ON CV.re_contract_version_id = bp.re_contract_id
     WHERE b.re_bordero_id = par_bordero_id;
  
    FOR loss IN (
                 
                 SELECT ch.c_claim_header_id
                        ,p.t_prod_line_option_id
                        ,(cc.declare_sum - NVL(v.vipl, 0)) dec_s
                        ,cc.seqno
                        ,cc.claim_status_date
                        ,ch.num h_num
                        ,cc.num c_num
                        ,ce.event_date
                        ,cc.claim_status_id
                   FROM ven_c_claim_header ch
                   JOIN ven_c_event ce
                     ON ce.c_event_id = ch.c_event_id
                   JOIN ven_c_claim cc
                     ON cc.c_claim_header_id = ch.c_claim_header_id
                   JOIN (SELECT DISTINCT cd.c_claim_id
                                        ,pc.t_prod_line_option_id
                           FROM ven_c_damage cd
                           JOIN p_cover pc
                             ON pc.p_cover_id = cd.p_cover_id
                           JOIN re_cover rc
                             ON rc.p_cover_id = pc.p_cover_id
                          WHERE rc.re_m_contract_id = recont) p
                     ON p.c_claim_id = cc.c_claim_id
                   LEFT JOIN (SELECT cd.c_claim_id
                                    ,NVL(SUM(t.acc_amount), 0) vipl
                                FROM trans t
                                JOIN trans_templ tt
                                  ON tt.trans_templ_id = t.trans_templ_id
                                JOIN c_damage cd
                                  ON t.a5_dt_uro_id = cd.c_damage_id
                                JOIN re_cover rc
                                  ON rc.p_cover_id = cd.p_cover_id
                               WHERE tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод')
                                 AND t.trans_date <= de
                                 AND rc.re_m_contract_id = recont
                               GROUP BY cd.c_claim_id) v
                     ON v.c_claim_id = cc.c_claim_id
                  WHERE cc.seqno = (SELECT MAX(c.seqno)
                                      FROM c_claim c
                                     WHERE c.c_claim_header_id = ch.c_claim_header_id
                                       AND c.claim_status_date BETWEEN db AND de))
    LOOP
      IF (loss.dec_s > 0)
      THEN
        -- добавляем re_claim_header,усли такой нет
        BEGIN
          INSERT INTO ven_re_claim_header
            (re_claim_header_id
            ,c_claim_header_id
            ,num
            ,doc_templ_id
            ,t_prod_line_option_id
            ,re_m_contract_id
            ,event_date)
            SELECT sq_re_claim_header.NEXTVAL
                  , -- ид
                   loss.c_claim_header_id
                  ,loss.h_num
                  ,(SELECT dc.doc_templ_id
                     FROM doc_templ dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM_HEADER'))
                  ,loss.t_prod_line_option_id
                  ,recont
                  ,loss.event_date
              FROM dual;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        -- выбираем запись re_claim_header
        SELECT *
          INTO v_re_claim_header
          FROM ven_re_claim_header r
         WHERE r.c_claim_header_id = loss.c_claim_header_id
           AND r.re_m_contract_id = recont;
        -- добавлем re_claim,усли такой нет
        BEGIN
          INSERT INTO ven_re_claim
            (re_claim_id
            ,re_claim_header_id
            ,seqno
            ,re_claim_status_date
            ,num
            ,doc_templ_id
            ,status_id)
            SELECT sq_re_claim.NEXTVAL
                  ,v_re_claim_header.re_claim_header_id
                  ,loss.seqno
                  ,loss.claim_status_date
                  ,loss.c_num
                  ,(SELECT dc.doc_templ_id
                     FROM doc_templ dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM'))
                  ,loss.claim_status_id
              FROM dual;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        -- выбираем запись re_claim
        SELECT *
          INTO v_re_claim
          FROM ven_re_claim r
         WHERE r.re_claim_header_id = v_re_claim_header.re_claim_header_id
           AND r.seqno = loss.seqno;
        -- добавляем запись в  re_damage,усли такой нет
      
        FOR ins_rd IN (SELECT rc.re_cover_id
                             ,cd.c_damage_id
                             ,cd.t_damage_code_id
                         FROM c_claim cc
                         JOIN c_damage cd
                           ON cd.c_claim_id = cc.c_claim_id
                         LEFT JOIN c_damage_cost_type dct
                           ON dct.c_damage_cost_type_id = cd.c_damage_cost_type_id
                         JOIN p_cover pc
                           ON pc.p_cover_id = cd.p_cover_id
                         JOIN re_cover rc
                           ON rc.p_cover_id = pc.p_cover_id
                        WHERE cc.c_claim_header_id = loss.c_claim_header_id
                          AND cc.seqno = loss.seqno
                          AND rc.re_m_contract_id = recont
                          AND dct.brief IS NULL
                           OR dct.brief = 'ВОЗМЕЩАЕМЫЕ')
        LOOP
          BEGIN
            INSERT INTO re_damage
              (re_damage_id, re_cover_id, damage_id, re_claim_id, t_damage_code_id)
              SELECT sq_re_damage.NEXTVAL
                    ,ins_rd.re_cover_id
                    ,ins_rd.c_damage_id
                    ,v_re_claim.re_claim_id
                    ,ins_rd.t_damage_code_id
                FROM dual;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        END LOOP;
      
        FOR re_d IN (SELECT rd.re_damage_id
                           ,rc.fund_id
                           ,rc.re_contract_ver_id
                       FROM re_damage rd
                       JOIN re_cover rc
                         ON rc.re_cover_id = rd.re_cover_id
                      WHERE rd.re_claim_id = v_re_claim.re_claim_id)
        LOOP
          SELECT * INTO v_re_damage FROM ven_re_damage r WHERE r.re_damage_id = re_d.re_damage_id;
          --удаляем линии по ущербу
          DELETE FROM re_line_damage r WHERE r.re_damage_id = v_re_damage.re_damage_id;
        
          -- заявленная сумма по оригинальному ущербу
          SELECT (cd.declare_sum - NVL(v.s, 0))
            INTO d_decsum
            FROM c_damage cd
            LEFT JOIN (SELECT t.a5_dt_uro_id
                             ,NVL(SUM(t.acc_amount), 0) s
                         FROM trans t
                         JOIN trans_templ tt
                           ON tt.trans_templ_id = t.trans_templ_id
                        WHERE t.trans_date <= de
                          AND tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод')
                        GROUP BY t.a5_dt_uro_id) v
              ON v.a5_dt_uro_id = cd.c_damage_id
           WHERE cd.c_damage_id = v_re_damage.damage_id;
        
          -- добавлем re_line_damage
          all_amount_dec := 0;
        
          FOR cur IN (SELECT rlc.line_number
                            ,rlc.LIMIT
                            ,rlc.part_perc
                        FROM re_line_contract rlc
                       WHERE rlc.fund_id = re_d.fund_id
                            /* @ Марчук А.С. 20.02.2007 В таблице нет поля re_contract_id, можно предположить, что
                                 имелось ввиду поле rlc.re_line_contract_id
                                       and rlc.re_contract_id = cont_ver;;
                            */
                         AND rlc.re_line_contract_id = re_d.re_contract_ver_id
                       ORDER BY rlc.line_number)
          LOOP
          
            v_re_line_damage.re_damage_id := v_re_damage.re_damage_id;
            v_re_line_damage.line_number  := cur.line_number;
            v_re_line_damage.part_perc    := cur.part_perc;
          
            IF (cur.line_number = 1)
            THEN
              v_re_line_damage.LIMIT := LEAST(cur.LIMIT, d_decsum);
            ELSE
              IF (d_decsum >= all_amount_dec + cur.LIMIT)
              THEN
                v_re_line_damage.LIMIT := cur.LIMIT;
              ELSE
                v_re_line_damage.LIMIT := d_decsum - all_amount_dec;
              END IF;
            END IF;
          
            v_re_line_damage.part_sum := ROUND(v_re_line_damage.LIMIT * v_re_line_damage.part_perc / 100
                                              ,2);
          
            all_amount_dec := all_amount_dec + cur.LIMIT;
            INSERT INTO ven_re_line_damage VALUES v_re_line_damage;
          
            IF (d_decsum <= all_amount_dec)
            THEN
              EXIT;
            END IF;
          END LOOP;
        
          SELECT SUM(rld.part_sum)
            INTO v_re_damage.re_declared_sum
            FROM ven_re_line_damage rld
           WHERE rld.re_damage_id = v_re_damage.re_damage_id;
        
          UPDATE ven_re_damage rd
             SET re_declared_sum =
                 (SELECT v_re_damage.re_declared_sum FROM dual)
           WHERE rd.re_damage_id = v_re_damage.re_damage_id;
        
          SELECT * INTO v_re_damage FROM ven_re_damage r WHERE r.re_damage_id = re_d.re_damage_id;
          -- связываем re_damage и re_bordero: rel_redamage_bordero
          BEGIN
            INSERT INTO rel_redamage_bordero
              (rel_redamage_bordero_id, re_damage_id, re_bordero_id, re_payment_sum)
              SELECT sq_rel_redamage_bordero.NEXTVAL
                    ,v_re_damage.re_damage_id
                    ,par_bordero_id
                    ,ROUND(NVL(v_re_damage.re_declared_sum, 0), 2)
                FROM dual;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        
        END LOOP;
      END IF;
    END LOOP;
  
    UPDATE re_bordero r
       SET r.declared_sum =
           (SELECT SUM(rr.re_payment_sum)
              FROM rel_redamage_bordero rr
             WHERE rr.re_bordero_id = par_bordero_id)
     WHERE r.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE create_bordero_payment_loss(par_bordero_id IN NUMBER) IS
    v_re_claim_header ven_re_claim_header%ROWTYPE;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_re_damage       ven_re_damage%ROWTYPE;
    v_re_line_damage  ven_re_line_damage%ROWTYPE;
    db                DATE;
    de                DATE;
    recont            NUMBER;
    all_amount_pay    NUMBER;
    d_paysum          NUMBER;
  
  BEGIN
  
    DELETE FROM rel_recover_bordero r WHERE r.re_bordero_id = par_bordero_id;
  
    -- определяем период,за который ищутся оплаченные убытки и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,CV.re_main_contract_id
      INTO db
          ,de
          ,recont
      FROM re_bordero b
      JOIN re_bordero_package bp
        ON bp.re_bordero_package_id = b.re_bordero_package_id
      JOIN re_contract_version CV
        ON CV.re_contract_version_id = bp.re_contract_id
     WHERE b.re_bordero_id = par_bordero_id;
  
    FOR loss IN (SELECT ch.c_claim_header_id
                       ,p.t_prod_line_option_id
                       ,v.vipl                  pay_s
                       ,cc.seqno
                       ,cc.claim_status_date
                       ,ch.num                  h_num
                       ,cc.num                  c_num
                       ,ce.event_date
                       ,cc.claim_status_id
                   FROM ven_c_claim_header ch
                   JOIN ven_c_event ce
                     ON ce.c_event_id = ch.c_event_id
                   JOIN ven_c_claim cc
                     ON cc.c_claim_header_id = ch.c_claim_header_id
                   JOIN (SELECT DISTINCT cd.c_claim_id
                                       ,pc.t_prod_line_option_id
                          FROM ven_c_damage cd
                          JOIN p_cover pc
                            ON pc.p_cover_id = cd.p_cover_id
                          JOIN re_cover rc
                            ON rc.p_cover_id = pc.p_cover_id
                         WHERE rc.re_m_contract_id = recont) p
                     ON p.c_claim_id = cc.c_claim_id
                   JOIN (SELECT cd.c_claim_id
                              ,NVL(SUM(t.acc_amount), 0) vipl
                          FROM trans t
                          JOIN trans_templ tt
                            ON tt.trans_templ_id = t.trans_templ_id
                          JOIN c_damage cd
                            ON t.a5_dt_uro_id = cd.c_damage_id
                          JOIN re_cover rc
                            ON rc.p_cover_id = cd.p_cover_id
                         WHERE tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод')
                           AND t.trans_date <= de
                           AND rc.re_m_contract_id = recont
                         GROUP BY cd.c_claim_id) v
                     ON v.c_claim_id = cc.c_claim_id
                  WHERE cc.seqno = (SELECT MAX(c.seqno)
                                      FROM c_claim c
                                     WHERE c.c_claim_header_id = ch.c_claim_header_id
                                       AND c.claim_status_date <= de))
    LOOP
      IF (loss.pay_s > 0)
      THEN
        -- добавляем re_claim_header,усли такой нет
        BEGIN
          INSERT INTO ven_re_claim_header
            (re_claim_header_id
            ,c_claim_header_id
            ,num
            ,doc_templ_id
            ,t_prod_line_option_id
            ,re_m_contract_id
            ,event_date)
            SELECT sq_re_claim_header.NEXTVAL
                  , -- ид
                   loss.c_claim_header_id
                  ,loss.h_num
                  ,(SELECT dc.doc_templ_id
                     FROM doc_templ dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM_HEADER'))
                  ,loss.t_prod_line_option_id
                  ,recont
                  ,loss.event_date
              FROM dual;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        -- выбираем запись re_claim_header
        SELECT *
          INTO v_re_claim_header
          FROM ven_re_claim_header r
         WHERE r.c_claim_header_id = loss.c_claim_header_id
           AND r.re_m_contract_id = recont;
        -- добавлем re_claim,усли такой нет
        BEGIN
          INSERT INTO ven_re_claim
            (re_claim_id
            ,re_claim_header_id
            ,seqno
            ,re_claim_status_date
            ,num
            ,doc_templ_id
            ,status_id)
            SELECT sq_re_claim.NEXTVAL
                  ,v_re_claim_header.re_claim_header_id
                  ,loss.seqno
                  ,loss.claim_status_date
                  ,loss.c_num
                  ,(SELECT dc.doc_templ_id
                     FROM doc_templ dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM'))
                  ,loss.claim_status_id
              FROM dual;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        -- выбираем запись re_claim
        SELECT *
          INTO v_re_claim
          FROM ven_re_claim r
         WHERE r.re_claim_header_id = v_re_claim_header.re_claim_header_id
           AND r.seqno = loss.seqno;
        -- добавляем запись в  re_damage,усли такой нет
      
        FOR ins_rd IN (SELECT rc.re_cover_id
                             ,cd.c_damage_id
                             ,cd.t_damage_code_id
                         FROM c_claim cc
                         JOIN c_damage cd
                           ON cd.c_claim_id = cc.c_claim_id
                         LEFT JOIN c_damage_cost_type dct
                           ON dct.c_damage_cost_type_id = cd.c_damage_cost_type_id
                         JOIN p_cover pc
                           ON pc.p_cover_id = cd.p_cover_id
                         JOIN re_cover rc
                           ON rc.p_cover_id = pc.p_cover_id
                        WHERE cc.c_claim_header_id = loss.c_claim_header_id
                          AND cc.seqno = loss.seqno
                          AND rc.re_m_contract_id = recont
                          AND dct.brief IS NULL
                           OR dct.brief = 'ВОЗМЕЩАЕМЫЕ')
        LOOP
          BEGIN
            INSERT INTO re_damage
              (re_damage_id, re_cover_id, damage_id, re_claim_id, t_damage_code_id)
              SELECT sq_re_damage.NEXTVAL
                    ,ins_rd.re_cover_id
                    ,ins_rd.c_damage_id
                    ,v_re_claim.re_claim_id
                    ,ins_rd.t_damage_code_id
                FROM dual;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        END LOOP;
      
        FOR re_d IN (SELECT rd.re_damage_id
                           ,rc.fund_id
                           ,rc.re_contract_ver_id
                       FROM re_damage rd
                       JOIN re_cover rc
                         ON rc.re_cover_id = rd.re_cover_id
                      WHERE rd.re_claim_id = v_re_claim.re_claim_id)
        LOOP
          SELECT * INTO v_re_damage FROM ven_re_damage r WHERE r.re_damage_id = re_d.re_damage_id;
          --удаляем линии по ущербу
          DELETE FROM re_line_damage r WHERE r.re_damage_id = v_re_damage.re_damage_id;
        
          -- сумма к выплате по оригинальному ущербу
          SELECT v.s
            INTO d_paysum
            FROM c_damage cd
            JOIN (SELECT t.a5_dt_uro_id
                        ,NVL(SUM(t.acc_amount), 0) s
                    FROM trans t
                    JOIN trans_templ tt
                      ON tt.trans_templ_id = t.trans_templ_id
                   WHERE t.trans_date <= de
                     AND tt.brief IN ('ЗачВыплКонтр', 'ЗачВыплВыгод')
                   GROUP BY t.a5_dt_uro_id) v
              ON v.a5_dt_uro_id = cd.c_damage_id
           WHERE cd.c_damage_id = v_re_damage.damage_id;
        
          -- добавлем re_line_damage
          all_amount_pay := 0;
        
          FOR cur IN (SELECT rlc.line_number
                            ,rlc.LIMIT
                            ,rlc.part_perc
                        FROM re_line_contract rlc
                       WHERE rlc.fund_id = re_d.fund_id
                            /* @ Марчук А.С. 20.02.2007 В таблице нет поля re_contract_id, можно предположить, что
                                 имелось ввиду поле rlc.re_line_contract_id
                                       and rlc.re_contract_id = cont_ver;;
                            */
                         AND rlc.re_line_contract_id = re_d.re_contract_ver_id
                       ORDER BY rlc.line_number)
          LOOP
          
            v_re_line_damage.re_damage_id := v_re_damage.re_damage_id;
            v_re_line_damage.line_number  := cur.line_number;
            v_re_line_damage.part_perc    := cur.part_perc;
          
            IF (cur.line_number = 1)
            THEN
              v_re_line_damage.LIMIT := LEAST(cur.LIMIT, d_paysum);
            ELSE
              IF (d_paysum >= all_amount_pay + cur.LIMIT)
              THEN
                v_re_line_damage.LIMIT := cur.LIMIT;
              ELSE
                v_re_line_damage.LIMIT := d_paysum - all_amount_pay;
              END IF;
            END IF;
          
            v_re_line_damage.part_sum := ROUND(v_re_line_damage.LIMIT * v_re_line_damage.part_perc / 100
                                              ,2);
          
            all_amount_pay := all_amount_pay + cur.LIMIT;
            INSERT INTO ven_re_line_damage VALUES v_re_line_damage;
          
            IF (d_paysum <= all_amount_pay)
            THEN
              EXIT;
            END IF;
          END LOOP;
        
          SELECT SUM(rld.part_sum)
            INTO v_re_damage.re_payment_sum
            FROM ven_re_line_damage rld
           WHERE rld.re_damage_id = v_re_damage.re_damage_id;
        
          UPDATE ven_re_damage rd
             SET re_payment_sum =
                 (SELECT v_re_damage.re_payment_sum FROM dual)
           WHERE rd.re_damage_id = v_re_damage.re_damage_id;
        
          SELECT * INTO v_re_damage FROM ven_re_damage r WHERE r.re_damage_id = re_d.re_damage_id;
          -- связываем re_damage и re_bordero: rel_redamage_bordero
          BEGIN
            INSERT INTO rel_redamage_bordero
              (rel_redamage_bordero_id, re_damage_id, re_bordero_id, re_payment_sum)
              SELECT sq_rel_redamage_bordero.NEXTVAL
                    ,v_re_damage.re_damage_id
                    ,par_bordero_id
                    ,ROUND(NVL(v_re_damage.re_payment_sum, 0), 2)
                FROM dual;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        
        END LOOP;
      END IF;
    END LOOP;
  
    UPDATE re_bordero r
       SET r.payment_sum =
           (SELECT SUM(rr.re_payment_sum)
              FROM rel_redamage_bordero rr
             WHERE rr.re_bordero_id = par_bordero_id)
     WHERE r.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE delete_bordero_loss(par_bordero_id IN NUMBER) IS
    ex     NUMBER;
    rch_id NUMBER;
    rc_id  NUMBER;
  BEGIN
    DELETE FROM rel_reclaim_bordero rb
     WHERE rb.re_claim_id IN
           (SELECT rc.re_claim_id FROM ven_re_claim rc WHERE rc.re_bordero_id = par_bordero_id);
    FOR vr_reclaim IN (SELECT rc.re_claim_id
                             ,rc.re_claim_header_id
                         FROM ven_re_claim rc
                        WHERE rc.re_bordero_id = par_bordero_id)
    LOOP
      DELETE FROM re_cover rc
       WHERE rc.re_cover_id IN
             (SELECT rh.re_cover_id
                FROM ven_re_claim_header rh
               WHERE rh.re_claim_header_id = vr_reclaim.re_claim_header_id);
    
      DELETE FROM document dc WHERE dc.document_id = vr_reclaim.re_claim_id;
      DELETE FROM re_claim rc WHERE rc.re_claim_id = vr_reclaim.re_claim_id;
    
      DELETE FROM document dc WHERE dc.document_id = vr_reclaim.re_claim_header_id;
      DELETE FROM re_claim_header rh WHERE rh.re_claim_header_id = vr_reclaim.re_claim_header_id;
    END LOOP;
    /*      FOR cur IN(
                SELECT rrd.re_damage_id
                FROM rel_redamage_bordero rrd
                WHERE rrd.re_bordero_id = par_bordero_id
               )
     LOOP -- бегем по содержимому бордеро
      -- определяем claim_header и claim
      SELECT rc.re_claim_header_id,rc.re_claim_id
       INTO rch_id,rc_id
      FROM re_damage rd,re_claim rc
      WHERE rd.re_damage_id = cur.re_damage_id
        AND rc.re_claim_id = rd.re_claim_id;
    
      -- определяем кол-во ущербов по claim_header и claim, исключая наш
      SELECT COUNT(rd.re_damage_id) INTO ex
      FROM re_claim rc,re_damage rd
      WHERE rc.re_claim_header_id = rch_id
        AND rc.re_claim_id = rd.re_claim_id
        AND rd.re_damage_id != cur.re_damage_id;
    
      IF (ex = 0) THEN
       -- больше нет ущербов: удаляем claim_header
       DELETE FROM re_claim_header rch
       WHERE rch.re_claim_header_id = rch_id;
      ELSE -- есть другие
       -- определяем кол-во ущербов по claim, исключая наш
       SELECT COUNT(rd.re_damage_id) INTO ex
       FROM re_damage rd
       WHERE rd.re_claim_id = rc_id
         AND rd.re_damage_id!= cur.re_damage_id;
    
       IF (ex = 0) THEN
        -- больше нет ущербов: удаляем claim
           DELETE FROM re_claim rc
           WHERE rc.re_claim_id = rc_id;
       ELSE -- есть другие
        -- определяем есть ли наш ущерб в содержимом другого бордеро
          SELECT COUNT(rrd2.re_damage_id) INTO ex
           FROM rel_redamage_bordero rrd2
           WHERE rrd2.re_damage_id   = cur.re_damage_id
             AND rrd2.re_bordero_id != par_bordero_id;
           IF (ex=0) THEN
              DELETE FROM re_damage rd
              WHERE rd.re_damage_id = cur.re_damage_id;
           END IF;
      END IF;
     END IF;
    END LOOP;*/
    --   DELETE FROM re_bordero r
    --   WHERE r.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE nach_bordero_loss(par_bordero_id IN NUMBER) IS
    v_templ_loss NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_loss
      FROM oper_templ o
     WHERE o.brief = 'НачДоляВыплИсхПрстрх';
  
    FOR rel IN (SELECT rd.re_damage_id
                      ,rd.ent_id
                      ,rd.re_payment_sum
                  FROM ven_rel_redamage_bordero rrb
                      ,ven_re_damage            rd
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rd.re_damage_id = rrb.re_damage_id)
    
    LOOP
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_loss
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_damage_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.re_payment_sum
                                              ,'INS');
    END LOOP;
  END;

  PROCEDURE za4et_bordero_loss(par_bordero_id IN NUMBER) IS
    v_templ_loss NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_loss
      FROM oper_templ o
     WHERE o.brief = 'ВзаимозачУбИсхПрстрх';
  
    FOR rel IN (SELECT rd.re_damage_id
                      ,rd.ent_id
                      ,rd.re_payment_sum
                  FROM ven_rel_redamage_bordero rrb
                      ,ven_re_damage            rd
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rd.re_damage_id = rrb.re_damage_id)
    
    LOOP
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_loss
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_damage_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.re_payment_sum
                                              ,'INS');
    END LOOP;
  END;

  PROCEDURE create_bordero_rast(par_bordero_id IN NUMBER) IS
    v_re_cover   ven_re_cover%ROWTYPE;
    v_re_bordero ven_re_bordero%ROWTYPE;
    db           DATE;
    de           DATE;
    recont       NUMBER;
  
  BEGIN
  
    DELETE FROM rel_recover_bordero r WHERE r.re_bordero_id = par_bordero_id;
  
    -- определяем период,за который ищутся расторжения и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,CV.re_main_contract_id
      INTO db
          ,de
          ,recont
      FROM re_bordero b
      JOIN re_bordero_package bp
        ON bp.re_bordero_package_id = b.re_bordero_package_id
      JOIN re_contract_version CV
        ON CV.re_contract_version_id = bp.re_contract_id
     WHERE b.re_bordero_id = par_bordero_id;
  
    FOR cover IN (SELECT /*+ ORDERED */
                   rc.re_cover_id
                  ,tr.acc_amount vozvr
                  ,fact.f_vozvr
                  ,tr.trans_date
                    FROM trans tr
                    JOIN trans_templ tt
                      ON tt.trans_templ_id = tr.trans_templ_id
                    JOIN p_cover pc
                      ON pc.p_cover_id = tr.A5_CT_URO_ID
                    LEFT JOIN (SELECT tr1.A5_CT_URO_ID p_cover
                                    ,NVL(SUM(tr1.acc_amount), 0) f_vozvr
                                FROM trans tr1
                                JOIN trans_templ tt1
                                  ON tt1.trans_templ_id = tr1.trans_templ_id
                               WHERE tt1.brief = 'ВыплВозврат'
                                 AND tr1.trans_date BETWEEN db AND de
                               GROUP BY tr1.A5_CT_URO_ID) fact
                      ON fact.p_cover = pc.p_cover_id
                    JOIN as_asset ass
                      ON ass.as_asset_id = pc.as_asset_id
                    JOIN p_policy pp
                      ON pp.policy_id = ass.p_policy_id
                    JOIN p_policy pp_prev
                      ON (pp_prev.pol_header_id = pp.pol_header_id AND
                         pp_prev.version_num = pp.version_num - 1)
                    JOIN as_asset ass_prev
                      ON pp_prev.policy_id = ass_prev.p_policy_id
                    JOIN p_cover pc_prev
                      ON ass_prev.as_asset_id = pc_prev.as_asset_id
                     AND pc_prev.t_prod_line_option_id = pc.t_prod_line_option_id
                    JOIN re_cover rc
                      ON (rc.p_cover_id = pc_prev.p_cover_id AND rc.re_m_contract_id = recont)
                   WHERE tt.brief IN ('НачВозврат') --
                     AND tr.trans_date BETWEEN db AND de)
    LOOP
      -- связываем re_cover и re_bordero: rel_recover_rebordero
      SELECT * INTO v_re_cover FROM ven_re_cover r WHERE r.re_cover_id = cover.re_cover_id;
    
      BEGIN
        INSERT INTO rel_recover_bordero
          (rel_recover_bordero_id, re_cover_id, re_bordero_id, returned_premium)
          SELECT sq_rel_recover_bordero.NEXTVAL
                ,v_re_cover.re_cover_id
                ,par_bordero_id
                ,NVL(ROUND(cover.f_vozvr * v_re_cover.brutto_premium / v_re_cover.ins_premium, 2), 0)
            FROM dual;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
      END;
    
      UPDATE ven_re_cover r
         SET r.return_premium = ROUND(cover.vozvr * v_re_cover.brutto_premium / v_re_cover.ins_premium
                                     ,2)
            ,r.cancel_date    = cover.trans_date
       WHERE r.re_cover_id = cover.re_cover_id;
    END LOOP;
  
    SELECT SUM(r.returned_premium)
      INTO v_re_bordero.return_sum
      FROM rel_recover_bordero r
     WHERE r.re_bordero_id = par_bordero_id;
  
    UPDATE re_bordero r
       SET (RETURN_SUM) =
           (SELECT v_re_bordero.return_sum FROM dual)
     WHERE r.re_bordero_id = par_bordero_id;
    -- commit;
  END;

  PROCEDURE delete_bordero_rast(par_bordero_id IN NUMBER) IS
  BEGIN
    UPDATE re_cover r
       SET r.return_premium = NULL
          ,r.cancel_date    = NULL
     WHERE r.re_cover_id IN (SELECT rrb.re_cover_id
                               FROM rel_recover_bordero rrb
                              WHERE rrb.re_bordero_id = par_bordero_id);
  
    DELETE FROM re_bordero rb WHERE rb.re_bordero_id = par_bordero_id;
  END;

  PROCEDURE nach_bordero_rast(par_bordero_id IN NUMBER) IS
    v_templ_loss NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_loss
      FROM oper_templ o
     WHERE o.brief = 'НачВозвратИсхПрстрх';
  
    FOR rel IN (SELECT rc.re_cover_id
                      ,rc.ent_id
                      ,rc.return_premium
                  FROM ven_rel_recover_bordero rrb
                      ,ven_re_cover            rc
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rc.re_cover_id = rrb.re_cover_id)
    LOOP
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_loss
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_cover_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.return_premium
                                              ,'INS');
    END LOOP;
  END;

  PROCEDURE za4et_bordero_rast(par_bordero_id IN NUMBER) IS
    v_templ_prem NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT o.oper_templ_id
      INTO v_templ_prem
      FROM oper_templ o
     WHERE o.brief = 'ВзаимозачВозвратПремИсхПрстрх';
  
    FOR rel IN (SELECT rc.re_cover_id
                      ,rc.ent_id
                      ,rrb.returned_premium
                  FROM ven_rel_recover_bordero rrb
                      ,ven_re_cover            rc
                 WHERE rrb.re_bordero_id = par_bordero_id
                   AND rc.re_cover_id = rrb.re_cover_id)
    LOOP
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_prem
                                              ,par_bordero_id
                                              ,rel.ent_id
                                              ,rel.re_cover_id
                                              ,Doc.get_doc_status_id(par_bordero_id)
                                              ,1
                                              ,rel.returned_premium
                                              ,'INS');
    END LOOP;
  END;

  PROCEDURE create_doc(par_package_bordero IN NUMBER) IS
    v_re_bordero_package ven_re_bordero_package%ROWTYPE;
    v_doc_status_ref_id  NUMBER;
    v_doc_ent_id         NUMBER;
    v_payment_type_id    NUMBER;
    v_payment_direct_id  NUMBER;
    v_doc_templ_id       NUMBER;
    v_document_id        NUMBER;
    v_payment_templ_id   NUMBER;
    v_templ_plan         NUMBER;
    v_res_id             NUMBER;
    v_rm_contract        ven_re_main_contract%ROWTYPE;
  BEGIN
  
    SELECT r.*
      INTO v_re_bordero_package
      FROM ven_re_bordero_package r
     WHERE r.re_bordero_package_id = par_package_bordero;
  
    SELECT r.*
      INTO v_rm_contract
      FROM ven_re_main_contract r
     WHERE r.re_main_contract_id = v_re_bordero_package.re_m_contract_id;
  
    -- выберем шаблон платежа
    BEGIN
      SELECT e.ent_id INTO v_doc_ent_id FROM entity e WHERE e.source = 'AC_PAYMENT';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Не найден заданный шаблон платежа');
    END;
  
    IF (v_re_bordero_package.summ > 0)
    THEN
      -- выберем шаблон платежа
      BEGIN
        SELECT pt.payment_templ_id
              ,pt.payment_type_id
              ,pt.payment_direct_id
              ,pt.doc_templ_id
          INTO v_payment_templ_id
              ,v_payment_type_id
              ,v_payment_direct_id
              ,v_doc_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'OrderPayPlusSaldoOutReins';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Не найден заданный шаблон платежа');
      END;
    ELSE
      -- выберем шаблон платежа
      BEGIN
        SELECT pt.payment_templ_id
              ,pt.payment_type_id
              ,pt.payment_direct_id
              ,pt.doc_templ_id
          INTO v_payment_templ_id
              ,v_payment_type_id
              ,v_payment_direct_id
              ,v_doc_templ_id
          FROM ac_payment_templ pt
         WHERE pt.brief = 'AccMinusSaldoOutReins';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Не найден заданный шаблон платежа');
      END;
    END IF;
  
    --выбираем статус документа
    SELECT dsr.doc_status_ref_id
      INTO v_doc_status_ref_id
      FROM doc_status_ref dsr
     WHERE dsr.brief = 'NEW';
  
    -- создаем платеж
    IF (v_re_bordero_package.summ != 0)
    THEN
      BEGIN
      
        SELECT sq_document.NEXTVAL INTO v_document_id FROM dual;
      
        INSERT INTO document
          (document_id, ent_id, num, reg_date, doc_templ_id)
        VALUES
          (v_document_id
          ,v_doc_ent_id
          ,v_re_bordero_package.num
          ,v_re_bordero_package.accept_date
          ,v_doc_templ_id);
        Doc.set_doc_status(v_document_id, v_doc_status_ref_id);
        INSERT INTO ac_payment
          (payment_id
          ,payment_number
          ,payment_type_id
          ,payment_direct_id
          ,due_date
          ,grace_date
          ,amount
          ,fund_id
          ,rev_amount
          ,rev_fund_id
          ,rev_rate_type_id
          ,rev_rate
          ,contact_id
          ,payment_templ_id
          ,payment_terms_id
          ,collection_metod_id)
        VALUES
          (v_document_id
          ,1
          ,v_payment_type_id
          ,v_payment_direct_id
          ,v_re_bordero_package.accept_date
          ,v_re_bordero_package.accept_date
          ,ABS(v_re_bordero_package.summ)
          ,v_re_bordero_package.fund_pay_id
          ,ABS(v_re_bordero_package.summ)
          ,v_re_bordero_package.fund_pay_id
          ,(SELECT rt.rate_type_id FROM rate_type rt WHERE rt.brief = 'ЦБ')
          ,1
          ,v_re_bordero_package.reinsurer_id
          ,v_payment_templ_id
          ,(SELECT pt.id
             FROM T_PAYMENT_TERMS pt
            WHERE pt.description = 'Единовременно'
              AND ROWNUM = 1)
          ,(SELECT cm.id
             FROM T_COLLECTION_METHOD cm
            WHERE cm.description = 'Безналичный расчет'));
        -- связываем с родительским документом
        INSERT INTO doc_doc
          (doc_doc_id, parent_id, child_id)
        VALUES
          (sq_doc_doc.NEXTVAL, par_package_bordero, v_document_id);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, 'Ошибка создания платежа');
        
      END;
    
      IF (v_re_bordero_package.summ > 0)
      THEN
        SELECT o.oper_templ_id
          INTO v_templ_plan
          FROM oper_templ o
         WHERE o.brief = 'УтвРаспВыплПоложСальдоИсхП';
      ELSE
        SELECT o.oper_templ_id
          INTO v_templ_plan
          FROM oper_templ o
         WHERE o.brief = 'ВыстСчётОплОтрСальдоИсхП';
      END IF;
    
      v_res_id := Acc_New.Run_Oper_By_Template(v_templ_plan
                                              ,v_document_id
                                              ,v_rm_contract.ent_id
                                              ,v_rm_contract.re_main_contract_id
                                              ,Doc.get_doc_status_id(v_document_id)
                                              ,1
                                              ,ABS(v_re_bordero_package.summ)
                                              ,'INS');
    
    END IF;
  END;

  FUNCTION copy_ver_contract(par_recont_ver_id_in IN NUMBER) RETURN NUMBER IS
    v_re_contract_version ven_re_contract_version%ROWTYPE;
  BEGIN
  
    SELECT t.*
      INTO v_re_contract_version
      FROM ven_re_contract_version t
     WHERE t.re_contract_version_id = par_recont_ver_id_in;
  
    -- новый ид версии
    SELECT sq_re_contract_version.NEXTVAL INTO v_re_contract_version.re_contract_version_id FROM dual;
  
    v_re_contract_version.start_date := TRUNC(SYSDATE, 'dd');
  
    INSERT INTO ven_re_contract_version VALUES v_re_contract_version;
  
    -- статус
    Doc.set_doc_status(v_re_contract_version.re_contract_version_id, 'NEW');
  
    INSERT INTO ven_RE_COND_FILTER_OBL
      (RE_COND_FILTER_OBL_ID
      ,PRODUCT_ID
      ,INSURANCE_GROUP_ID
      ,ASSET_TYPE_ID
      ,PRODUCT_LINE_ID
      ,RE_CONTRACT_VER_ID
      ,AGENT_ID
      ,ISSUER_ID)
      SELECT sq_re_cond_filter_obl.NEXTVAL
            ,t.product_id
            ,t.insurance_group_id
            ,t.asset_type_id
            ,t.product_line_id
            ,v_re_contract_version.re_contract_version_id
            ,t.agent_id
            ,t.issuer_id
        FROM ven_RE_COND_FILTER_OBL t
       WHERE t.re_contract_ver_id = par_recont_ver_id_in;
  
    /* Марчук А. 20.02.2007
      В view ven_re_line_contract в настоящий момент отсутствует поле RE_CONTRACT_ID
    */
    INSERT INTO ven_re_line_contract
      (RE_LINE_CONTRACT_ID
      , /*RE_LINE_CONTRACT_ID,*/LINE_NUMBER
      ,LIMIT
      ,RETENTION_PERC
      ,RETENTION_VAL
      ,PART_PERC
      ,PART_SUM
      ,COMMISSION_PERC
      ,FUND_ID /*,TARIFF_INS,RE_TARIFF*/)
      SELECT sq_re_line_contract.NEXTVAL
            ,
             /*       v_re_contract_version.re_contract_version_id, */t1.line_number
            ,t1.LIMIT
            ,t1.retention_perc
            ,t1.retention_val
            ,t1.part_perc
            ,t1.part_sum
            ,t1.commission_perc
            ,t1.fund_id --,
      --t1.tariff_ins,
      --t1.re_tariff
        FROM ven_re_line_contract t1
      /* Марчук А. 20.02.2007
        было where t1.re_line_contract_id = par_recont_ver_id_in;
      */
       WHERE t1.re_line_contract_id = par_recont_ver_id_in;
  
    RETURN v_re_contract_version.re_contract_version_id;
  END;

END Pkg_Re_Bordero;
/

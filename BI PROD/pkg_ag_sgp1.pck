CREATE OR REPLACE PACKAGE pkg_ag_sgp1 IS

  -- Author  : DKOLGANOV
  -- Created : 21.05.2008 15:32:08
  -- Purpose : пакет для подсчета и обработки СГП менеджеров и 
  --           директоров по новой мотивации от 14.04.2008

  --тип сгп
  vTYPE_SGP CONSTANT NUMBER := 1;

  /**
  *  расчет суммы собственных продаж и суммы продаж подчиненных 
  *  агентов у менеджеров и директоров по новой мотивации от 14.04.2008
  *  
  * @author Колганов Дмитрий
  * @param p_date_begin дата начала отчетного периода
  * @param p_ag_contract_header_id ИД агентского договора
  */
  PROCEDURE sgp_own_calc
  (
    p_date_begin            IN DATE
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  );

  /**
  *  расчет всей суммы по новой мотивации от 14.04.2008
  *  
  * @author Колганов Дмитрий
  * @param p_date_begin дата начала отчетного периода
  * @param p_ag_contract_header_id ИД агентского договора
  */
  PROCEDURE sgp_all_calc
  (
    p_date_begin            IN DATE
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  );

END pkg_ag_sgp1;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_sgp1 IS

  PROCEDURE sgp_own_calc
  (
    p_date_begin            IN DATE
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  ) IS
    v_ag_sgp1_id NUMBER;
    v_status     NUMBER;
    v_ag_sgp     ven_ag_sgp%ROWTYPE;
    p_ret        NUMBER;
    v_counter    NUMBER := 0;
    --Каткевич А.Г. 18/11/2008 Изменил курсор. Нельзя зашиваться на ID
    CURSOR sgp
    (
      h_id NUMBER
     ,dt   DATE
    ) IS(
      SELECT nvl(ag_stat_agent_id, NULL) v_status
            ,nvl(ag_stat_hist_id, NULL) v_status_hist_id
        FROM (SELECT *
                FROM ag_stat_hist asa1
               WHERE asa1.ag_contract_header_id = h_id
                 AND ASa1.stat_date < last_day(dt)
               ORDER BY asa1.stat_date DESC
                       ,asa1.num       DESC)
       WHERE ROWNUM = 1);
  
    k_sgp sgp%ROWTYPE;
  
  BEGIN
    FOR cur_sgp IN (SELECT ch.ag_contract_header_id
                          ,c.ag_contract_id
                          ,c.category_id
                          ,pkg_agent_sub.Get_Leader_Id_By_Date(last_day(p_date_begin)
                                                              ,ch.ag_contract_header_id
                                                              ,last_day(p_date_begin)) leader_id
                      FROM ven_ag_contract        c
                          ,ven_ag_contract_header ch
                     WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id
                                                         ,last_day(p_date_begin)) = c.ag_contract_id
                       AND (ch.ag_contract_header_id = p_ag_contract_header_id OR
                            p_ag_contract_header_id IS NULL) --28/10/2008 Каткевич А.Г. Поправил условие
                       AND c.category_id = (SELECT ah.ag_category_agent_id
                                              FROM ag_roll_header ah
                                                  ,ag_roll        ar
                                             WHERE ar.ag_roll_header_id = ah.ag_roll_header_id
                                               AND ar.ag_roll_id = p_ag_roll_id) --26/11/2008 Каткевич А.Г. Добавил определение категории
                       AND Doc.get_doc_status_brief(ch.ag_contract_header_id, SYSDATE) IN
                           ('PRINTED', 'CURRENT', 'RESUME')
                       AND ch.ag_contract_templ_k = 0)
    LOOP
    
      OPEN sgp(cur_sgp.ag_contract_header_id, p_date_begin);
      FETCH sgp
        INTO k_sgp.v_status
            ,k_sgp.v_status_hist_id;
    
      EXIT WHEN sgp%NOTFOUND;
      CLOSE sgp;
    
      v_ag_sgp.ag_sgp_id             := NULL;
      v_ag_sgp.ag_contract_header_id := cur_sgp.ag_contract_header_id;
      v_ag_sgp.sgp_sum               := 0;
      v_ag_sgp.sgp_type_id           := vTYPE_SGP;
      v_ag_sgp.date_calc             := p_date_begin;
      v_ag_sgp.date_of_calc          := SYSDATE;
      v_ag_sgp.category_id           := cur_sgp.category_id;
      v_ag_sgp.leader_id             := cur_sgp.leader_id;
      v_ag_sgp.status_id             := k_sgp.v_status;
      v_ag_sgp.ag_stat_hist_id       := k_sgp.v_status_hist_id;
      v_ag_sgp.ag_roll_id            := p_ag_roll_id;
    
      p_ret := pkg_ag_sgp.InsertIntoSgp(v_ag_sgp);
    
      IF (p_ret != Utils.c_true)
      THEN
        RETURN;
      END IF;
    
      v_ag_sgp1_id := v_ag_sgp.ag_sgp_id;
    
      INSERT INTO ven_ag_sgp_det
        (ag_sgp_det_id, ag_contract_header_ch_id, ag_sgp_id, policy_id, SUM, part_Agent)
        SELECT sq_ag_sgp_det.nextval
              ,ag_contract_header_id
              ,v_ag_sgp1_id
              ,policy_id
              ,agent_rate * koef * koef_GR * koef_ccy * sum_prem
              ,part_agent
          FROM (SELECT nbp.agent_rate
                      ,nbp.koef
                      ,nbp.koef_GR
                      ,nbp.koef_ccy
                      ,
                       -- nbp.sum_izd,
                       nbp.ag_contract_header_id
                      ,nbp.policy_id
                      ,nbp.part_agent
                      ,nbp.sum_prem
                  FROM /*Каткевич А.Г. 25/09/2008 
                                               Этот код работает без использования денормализации p_pol_header
                                               мжоно совсем отказаться от денормализованой таблицы,
                                               НО это существенно повлияет на производительност*/
                       T_AG_SGP_PRODUCT t
                      ,
                       -- Принадлежность полиса агенту а агента менеджеру    
                       (SELECT nbp.*
                          FROM (
                                --Каткевич А.Г. 30/09/2008 Еще более правильное дерево
                                SELECT DISTINCT ac.contract_id
                                                ,LEVEL
                                  FROM ag_contract ac
                                 WHERE (doc.get_doc_status_brief(ac.contract_id, last_day(p_date_begin)) <>
                                       'BREAK' OR
                                       doc.get_doc_status_brief(ac.contract_id, last_day(p_date_begin)) IS NULL)
                                   AND pkg_agent.get_status_by_date(ac.contract_id, last_day(p_date_begin)) =
                                       ac.ag_contract_id
                                 START WITH ac.contract_id = cur_sgp.ag_contract_header_id
                                CONNECT BY NOCYCLE
                                 PRIOR ac.contract_id =
                                            (SELECT MAX(contract_id)
                                                    FROM ag_contract ac1
                                                   WHERE ac1.ag_contract_id = ac.contract_leader_id)
                                       AND pkg_agent_1.get_status_by_date(ac.contract_id
                                                                         ,LAST_DAY(p_date_begin)) =
                                           ac.ag_contract_id) manager_net
                              ,New_Buisnes_Pol nbp
                         WHERE manager_net.contract_id = nbp.ag_contract_header_id) nbp
                 WHERE t.product_id = nbp.product_id
                   AND T.T_SGP_TYPE_ID = vTYPE_SGP);
    
      p_ret := pkg_ag_sgp.UpdateSummSgp(v_ag_sgp1_id);
    
      IF (p_ret != Utils.c_true)
      THEN
        RETURN;
      END IF;
      IF v_counter > 10
      THEN
        EXIT;
      END IF;
    
    END LOOP;
  END;

  PROCEDURE sgp_all_calc
  (
    p_date_begin            IN DATE
   ,p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  ) IS
    p_ret          NUMBER;
    v_rate_type_id NUMBER;
  BEGIN
    p_ret := pkg_ag_sgp.DeleteSgpByAgHeaderAgRoll(p_ag_roll_id, p_ag_contract_header_id);
  
    IF (p_ret != Utils.c_true)
    THEN
      RETURN;
    END IF;
  
    -- определение типа курса валют
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM RATE_TYPE rt WHERE rt.brief = 'ЦБ';
  
    --Используем табличку New buisnes (полисы проданные в отчетном периоде)
    EXECUTE IMMEDIATE 'TRUNCATE TABLE new_buisnes_pol';
  
    INSERT INTO new_buisnes_pol
      (SELECT /*+ ORDERED */
        CASE
          WHEN ar.brief = 'PERCENT' THEN
           ag_sales_p.part_agent / 100
          WHEN ar.brief = 'ABSOL' THEN
           ag_sales_p.part_agent
          ELSE
           ag_sales_p.part_agent
        END agent_rate
      ,
        
        --19/03/2009 Каткевич А.Г.
        CASE
          WHEN pt.brief = 'Единовременно' THEN
           CASE
             WHEN tp.description = 'Семейный депозит' THEN
              0.2
             ELSE
              CASE
                WHEN CEIL(MONTHS_BETWEEN(last_day(pp.end_date), last_day(pp.start_date))) > 12 THEN
                 0.1
                ELSE
                 1
              END
           END
          ELSE
           1
        END koef
      ,
        
        /*              CASE WHEN tp.description = 'Семейный депозит' 
             THEN 0.2 
        ELSE
            CASE WHEN pt.brief = 'Единовременно' 
                 AND ceil(months_between(last_day(pp.end_date), last_day(pp.start_date))) > 12
                 THEN 0.1
                 WHEN (pt.brief = 'Единовременно' 
                 AND ceil(months_between(last_day(pp.end_date), last_day(pp.start_date))) <= 12) 
                 OR pt.brief <> 'Единовременно'
                 THEN 1
            ELSE 1
            END 
        END koef,   */
        --Для групповых 100%
        CASE
          WHEN pp.is_group_flag = 1 THEN
           1
          ELSE
           1
        END koef_GR
      ,ag_sales_p.part_agent
      ,ach.ag_contract_header_id
      ,nvl(pp.is_group_flag, 0) is_group_flag
      ,
        --Сумма премии за вычетом издержек * количество платежей
        /* pt.number_of_payments*
        ((select sum(pc.fee)
           from ven_p_cover pc, 
                ven_as_asset aa,
                status_hist sh
          where aa.p_policy_id = pp.policy_id
            and aa.as_asset_id = pc.as_asset_id
            AND pc.status_hist_id = sh.STATUS_HIST_ID
            AND sh.brief <> 'DELETED')
         - pkg_agent_1.find_sum_adm_izd(ph.policy_header_id))*/
        --pkg_agent_1.find_sum_adm_izd(ph.policy_header_id) sum_izd,
        
        --Каткевич А.Г. 30/12/2008 Исправлене ошибки с сумированием "удаленных покрытий" 
        -- + чуть побыстрее т.к. не подсчитываются 2 раза издержки
        pt.number_of_payments * (SELECT SUM(pc.fee)
                                   FROM P_COVER            pc
                                       ,AS_ASSET           aa
                                       ,status_hist        sh
                                       ,t_prod_line_option plo
                                  WHERE aa.p_policy_id = ph.policy_id
                                    AND aa.as_asset_id = pc.as_asset_id
                                    AND pc.t_prod_line_option_id = plo.ID
                                    AND plo.DESCRIPTION <> 'Административные издержки'
                                    AND sh.status_hist_id = pc.status_hist_id
                                    AND sh.brief <> 'DELETED') sum_prem
      ,NULL sum_izd
      ,acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                              ,ph.fund_id
                              ,pkg_agent_1.get_agent_start_contr(ag_sales_p.policy_header_id)) koef_ccy
      ,ph.product_id
      ,ph.policy_header_id
      ,pp.policy_id
         FROM (SELECT row_number() over(PARTITION BY ppa.policy_header_id ORDER BY ppa.date_start, ppa.p_policy_agent_id) rn
                     ,ppa.policy_header_id
                     ,ppa.ag_contract_header_id
                     ,ppa.date_start
                     ,ppa.date_end
                     ,ppa.part_agent
                     ,ppa.ag_type_rate_value_id
                 FROM p_policy_agent ppa
                WHERE ppa.status_id <> 4) ag_sales_p
             ,p_pol_header ph
             ,p_policy pp
             ,ag_contract_header ach
             ,ag_type_rate_value ar
             ,t_payment_terms pt
             ,t_product tp
        WHERE rn = 1
             -- Дата окончания действия агента по договору NB должна быть не меньше даты начала отчетного периода
          AND ag_sales_p.date_end > p_date_begin
             -- Дата начала действия агента по договору NB должна быть больше даты начала отчетного периода
             --  AND ag_sales_p.date_start >= p_date_begin
             -- Теперь точно отберем из оставшегося
          AND pkg_agent_1.get_agent_start_contr(ag_sales_p.policy_header_id) BETWEEN p_date_begin AND
              last_day(p_date_begin)
             -- Заключенный договор не расторгнут или отменен НА ДАТУ РАСЧЕТА
          AND doc.get_doc_status_brief(pp.policy_id, last_day(SYSDATE)) NOT IN ('CANCEL', 'BREAK')
          AND ph.policy_header_id = ag_sales_p.policy_header_id
          AND pp.policy_id = ph.policy_id
          AND ach.ag_contract_header_id = ag_sales_p.ag_contract_header_id
             --Каткевич А.Г. 26092008 Менджерам такие договора поподают
             --AND ach.agent_id <> pkg_policy.get_policy_contact(ph.policy_id, 'Страхователь')
          AND ag_sales_p.ag_type_rate_value_id = ar.ag_type_rate_value_id
          AND pp.payment_term_id = pt.ID
          AND tp.product_id = ph.product_id
             --Существует хоть одна оплаченая версия
          AND EXISTS (SELECT 1
                 FROM doc_doc    d
                     ,ac_payment ap
                     ,p_policy   p
                WHERE p.pol_header_id = ph.policy_header_id
                  AND d.parent_id = p.policy_id
                  AND ap.payment_id = d.child_id
                  AND doc.get_doc_status_brief(ap.payment_id) = 'PAID'));
  
    sgp_own_calc(p_date_begin, p_ag_roll_id, p_ag_contract_header_id);
  
    --Может и не надо!!!!!!!
    COMMIT;
  END;

END pkg_ag_sgp1;
/

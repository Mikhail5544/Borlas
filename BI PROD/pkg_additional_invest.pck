CREATE OR REPLACE PACKAGE pkg_Additional_Invest IS
  /**
  * Алгоритмы для расчета дополнительного инвестиционного дохода
  * @author Marchuk A.
  * @version 1.0
  */

  /*  Функция возвращает сохраненное ранее значение инвестиционного дохода по фильтру
    *@param p_pol_header_id  ИД договора страхования
    *@param p_t_lob_line_id  ИД страховой программы
    *@param p_contact_id  ИД застрахованного 
    *@param p_begin_date  Граничная дата поиска рассчитанного значения инвестиционного дохода
    *@return number
    *@author Marchuk A.
    *@version 1.0
    *@since 1.0
  */
  FUNCTION Calc_kB_prev
  (
    p_pol_header_id     IN NUMBER
   ,p_p_policy_id       IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_begin_date        IN DATE
  ) RETURN NUMBER;
  /*  Процедура расчета инвестиционных сумм в объявленном периоде
    *@author Marchuk A.
    *@param p_Additional_Invest_id ИД номера расчета
    *@version 1.0
    *@since 1.0
  */
  PROCEDURE Calc_Additional_Invest(p_Additional_Invest_id IN NUMBER);
  --
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_Additional_Invest IS
  /**
  * Алгоритмы для расчета дополнительного инвестиционного дохода
  * @author Marchuk A.
  * @version 1.0
  */

  /*  Функция возвращает сохраненное ранее значение инвестиционного дохода по фильтру
    *@param p_pol_header_id  ИД договора страхования
    *@param p_t_lob_line_id  ИД страховой программы
    *@param p_contact_id  ИД застрахованного 
    *@param p_begin_date  Граничная дата поиска рассчитанного значения инвестиционного дохода
    *@return number
    *@author Marchuk A.
    *@version 1.0
    *@since 1.0
  */

  FUNCTION Calc_kB_prev
  (
    p_pol_header_id     IN NUMBER
   ,p_p_policy_id       IN NUMBER
   ,p_t_lob_line_id     IN NUMBER
   ,p_p_asset_header_id IN NUMBER
   ,p_begin_date        IN DATE
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT VALUE
      INTO RESULT
      FROM (SELECT ad.VALUE
              FROM ADDITIONAL_INVEST_D ad
                  ,ADDITIONAL_INVEST   ai
             WHERE 1 = 1
               AND ad.pol_header_id = p_pol_header_id
               AND ad.p_asset_header_id = p_p_asset_header_id
               AND ad.t_lob_line_id = p_t_lob_line_id
               AND ai.additional_invest_id = ad.additional_invest_id
               AND ai.begin_date < p_begin_date
             ORDER BY ai.begin_date DESC)
     WHERE ROWNUM = 1;
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RAISE;
  END;

  /*  Процедура расчета инвестиционных сумм в объявленном периоде
    *@author Marchuk A.
    *@param p_Additional_Invest_id ИД номера расчета
    *@version 1.0
    *@since 1.0
  */

  PROCEDURE Calc_Additional_Invest(p_Additional_Invest_id IN NUMBER) IS
  BEGIN
    DELETE FROM VEN_ADDITIONAL_INVEST_D WHERE ADDITIONAL_INVEST_ID = p_Additional_Invest_id;
  
    INSERT INTO VEN_ADDITIONAL_INVEST_D
      (ADDITIONAL_INVEST_ID, POL_HEADER_ID, T_LOB_LINE_ID, P_ASSET_HEADER_ID, BASE_FUND_ID, VALUE)
    
      SELECT ADDITIONAL_INVEST_ID
            ,POL_HEADER_ID
            ,T_LOB_LINE_ID
            ,P_ASSET_HEADER_ID
            ,BASE_FUND_ID
            ,ROUND(KV * (J - I) + NVL(KB, 0) * (1 + J), 2) VALUE
        FROM (SELECT ds.ID
                    ,ds.additional_invest_id
                    ,ds.pol_header_id
                    ,ds.t_lob_line_id
                    ,ds.p_asset_header_id
                    ,ds.first_value
                    ,ds.next_value
                    ,ds.base_fund_id
                    ,ds.insurance_year_date
                    ,ds.begin_date
                    ,ds.next_insurance_year_date
                    ,ds.normrate_value i
                    ,ds.normrate_add_value j
                    ,ds.first_value +
                     (next_value - first_value) * (ds.begin_date - ds.insurance_year_date + 1) /
                     (ds.next_insurance_year_date - ds.insurance_year_date + 1) kV
                    ,pkg_Additional_Invest.Calc_kB_prev(ds.pol_header_id
                                                       ,ds.policy_id
                                                       ,ds.t_lob_line_id
                                                       ,ds.p_asset_header_id
                                                       ,ds.begin_date) kB
                FROM (SELECT rv.ID
                            ,ai.additional_invest_id
                            ,ph.policy_header_id pol_header_id
                            ,pp.policy_id
                            ,rr.insurance_variant_id t_lob_line_id
                            ,rr.p_asset_header_id
                            ,nr.VALUE normrate_add_value
                            ,rv.s * rv.PLAN first_value
                            ,lead(rv.PLAN * rv.s) OVER(PARTITION BY rv.reserve_id ORDER BY rv.insurance_year_date) next_value
                            ,ph.fund_id base_fund_id
                            ,ai.begin_date
                            ,ai.end_date
                            ,nr.d_end
                            ,rv.insurance_year_date
                            ,rv.c normrate_value
                            ,lead(rv.insurance_year_date) OVER(PARTITION BY rv.reserve_id ORDER BY rv.insurance_year_date) next_insurance_year_date
                        FROM T_PAYMENT_TERMS         pt
                            ,NORMRATE_ADD            nr
                            ,P_POLICY                pp
                            ,P_POL_HEADER            ph
                            ,reserve.r_reserve_value rv
                            ,reserve.r_reserve       rr
                            ,ADDITIONAL_INVEST       ai
                       WHERE 1 = 1
                         AND ai.additional_invest_id = p_Additional_Invest_id
                         AND pp.end_date > ai.begin_date
                         AND ph.policy_header_id = pp.pol_header_id
                         AND rr.policy_id = pp.policy_id
                         AND rv.reserve_id = rr.ID
                         AND nr.t_lob_line_id = rr.insurance_variant_id
                         AND nr.base_fund_id = ph.fund_id
                         AND TRUNC(nr.d_begin) = TRUNC(ai.begin_date)
                         AND TRUNC(nr.d_end) = TRUNC(ai.end_date)
                         AND pt.ID = pp.payment_term_id
                         AND pt.is_periodical = 1) ds
               WHERE 1 = 1
                 AND ds.begin_date BETWEEN ds.insurance_year_date AND ds.next_insurance_year_date);
  
    --
    COMMIT;
  END;
  --
END;
/

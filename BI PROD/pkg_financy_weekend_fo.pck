CREATE OR REPLACE PACKAGE pkg_financy_weekend_fo IS

  v_charge_acc_id NUMBER;
  v_pay_acc_id    NUMBER;

  --Договор страхования без программы "ИНВЕСТ" и риски НС не исключились при автопролонгации
  type1_fw_policy CONSTANT NUMBER := 1;

  --(Договор страхования без программы "ИНВЕСТ" и риски НС исключились при автопролонгации)
  type2_fw_policy CONSTANT NUMBER := 2;

  --(Договор страхования с программой "ИНВЕСТ" и риски НС не исключились при автопролонгации)
  type3_fw_policy CONSTANT NUMBER := 3;

  --(Договор страхования с программой "ИНВЕСТ" и риски НС исключились при автопролонгации)
  type4_fw_policy CONSTANT NUMBER := 4;

  v_type_p_policy NUMBER;

  -- создание проводок по фин каникулам при начале фин каникул
  FUNCTION create_trans_fw_start(p_policy_id NUMBER) RETURN NUMBER;

  PROCEDURE correctdates
  (
    v_oper_id     NUMBER
   ,p_p_policy_id NUMBER
  );

  FUNCTION isfoweekpolicy(pp_policy_id NUMBER) RETURN NUMBER;

  PROCEDURE create_trans_fw_start_msfo(p_policy_id NUMBER);
  PROCEDURE create_trans_fw_start_rsbu(p_policy_id NUMBER);

  FUNCTION is_type1(p_policy_id NUMBER) RETURN NUMBER; -- 0 нет -- 1 да
  FUNCTION is_type2(p_policy_id NUMBER) RETURN NUMBER; -- 0 нет -- 1 да
  FUNCTION is_type3(p_policy_id NUMBER) RETURN NUMBER; -- 0 нет -- 1 да
  FUNCTION is_type4(p_policy_id NUMBER) RETURN NUMBER; -- 0 нет -- 1 да

  FUNCTION getcountinvestprogramm(p_policy_id NUMBER) RETURN NUMBER;
  FUNCTION getcountdeletens(p_policy_id NUMBER) RETURN NUMBER;

  FUNCTION get_charge_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER;
  FUNCTION get_pay_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER;

  FUNCTION get_pay_cover_amount2
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER;
  FUNCTION get_charge_cover_amount2
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER;

  FUNCTION get_77_01_01 RETURN NUMBER;
  FUNCTION get_92_01 RETURN NUMBER;

  FUNCTION getduedate(doc_id NUMBER) RETURN DATE;

  FUNCTION getprevcover(pp_cover_id NUMBER) RETURN NUMBER;

--function get_charge_cover_am_YEARS(pp_policy_rec P_POLICY%rowtype, pp_cover_id number) return number;

END pkg_financy_weekend_fo;
/
CREATE OR REPLACE PACKAGE BODY pkg_financy_weekend_fo IS

  -- создание проводок по фин каникулам при начале фин каникул
  FUNCTION create_trans_fw_start(p_policy_id NUMBER) RETURN NUMBER AS
  BEGIN
  
    IF (is_type1(p_policy_id) = 1)
    THEN
      v_type_p_policy := type1_fw_policy;
    END IF;
  
    IF (is_type2(p_policy_id) = 1)
    THEN
      v_type_p_policy := type2_fw_policy;
    END IF;
  
    IF (is_type3(p_policy_id) = 1)
    THEN
      v_type_p_policy := type3_fw_policy;
    END IF;
  
    IF (is_type4(p_policy_id) = 1)
    THEN
      v_type_p_policy := type4_fw_policy;
    END IF;
  
    create_trans_fw_start_rsbu(p_policy_id);
    create_trans_fw_start_msfo(p_policy_id);
  
    RETURN 1;
  
  END create_trans_fw_start;

  FUNCTION is_type1(p_policy_id NUMBER) RETURN NUMBER -- 0 нет -- 1 да
   AS
    res NUMBER := 0;
  BEGIN
  
    IF (getcountinvestprogramm(p_policy_id) > 0)
    THEN
      RETURN 0;
    END IF;
  
    IF (getcountdeletens(p_policy_id) > 0)
    THEN
      res := 1;
    END IF;
  
    RETURN res;
  END is_type1;

  FUNCTION is_type2(p_policy_id NUMBER) RETURN NUMBER -- 0 нет -- 1 да
   AS
    res NUMBER := 0;
  BEGIN
  
    RETURN res;
  END is_type2;

  FUNCTION is_type3(p_policy_id NUMBER) RETURN NUMBER -- 0 нет -- 1 да
   AS
    res NUMBER := 0;
  BEGIN
  
    RETURN res;
  END is_type3;

  FUNCTION is_type4(p_policy_id NUMBER) RETURN NUMBER -- 0 нет -- 1 да
   AS
    res NUMBER := 0;
  BEGIN
  
    RETURN res;
  END is_type4;

  PROCEDURE create_trans_fw_start_msfo(p_policy_id NUMBER) AS
  BEGIN
    NULL;
  END create_trans_fw_start_msfo;

  PROCEDURE create_trans_fw_start_rsbu(p_policy_id NUMBER) AS
  BEGIN
    NULL;
  END create_trans_fw_start_rsbu;

  FUNCTION getcountinvestprogramm(p_policy_id NUMBER) RETURN NUMBER AS
    i_res NUMBER;
  BEGIN
  
    SELECT COUNT(v.lob_brief)
      INTO i_res
      FROM v_asset_cover_life v
     WHERE v.p_policy_id = p_policy_id
       AND v.lob_brief IN ('INVEST2', 'I2', 'INVEST');
  
    RETURN i_res;
  
  END getcountinvestprogramm;

  FUNCTION getcountdeletens(p_policy_id NUMBER) RETURN NUMBER AS
    i_res NUMBER;
  BEGIN
  
    SELECT COUNT(v.lob_brief)
      INTO i_res
      FROM v_asset_cover_life v
     WHERE v.p_policy_id = p_policy_id
       AND v.lob_brief IN (SELECT tll.brief
                             FROM t_lob_line tll
                                 ,t_lob      tl
                            WHERE tll.t_lob_id = tl.t_lob_id
                              AND tl.brief = 'Acc')
       AND v.sh_brief != 'DELETE';
  
    RETURN i_res;
  
  END getcountdeletens;

  FUNCTION isfoweekpolicy(pp_policy_id NUMBER) RETURN NUMBER AS
    res NUMBER := 0;
  BEGIN
  
    FOR irec IN (SELECT 1
                   FROM p_pol_addendum_type pa
                       ,t_addendum_type     tat
                  WHERE pa.p_policy_id = pp_policy_id
                    AND pa.t_addendum_type_id = tat.t_addendum_type_id
                    AND tat.brief = 'FIN_WEEK')
    LOOP
      RETURN 1;
    END LOOP;
  
    RETURN res;
  END isfoweekpolicy;

  PROCEDURE correctdates
  (
    v_oper_id     NUMBER
   ,p_p_policy_id NUMBER
  ) AS
  BEGIN
  
    UPDATE oper o
       SET o.oper_date =
           (SELECT pp.start_date FROM p_policy pp WHERE pp.policy_id = p_p_policy_id)
     WHERE o.oper_id = v_oper_id;
  
    UPDATE trans t
       SET t.trans_date =
           (SELECT o.oper_date FROM oper o WHERE o.oper_id = v_oper_id)
     WHERE t.oper_id = v_oper_id;
  
  END correctdates;

  FUNCTION get_charge_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER AS
    v_fund_id         NUMBER;
    v_policy_id       NUMBER;
    v_pol_header_id   NUMBER;
    v_ret_val         NUMBER;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
    v_policy_id_2     NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,a.p_policy_id
          ,ph.policy_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    --      select 
    --        a.POLICY_ID
    --      into v_policy_id_2 
    --      from (   
    --       select PP.POLICY_ID 
    --       from P_POLICY pp 
    --       where PP.POL_HEADER_ID = v_pol_header_id
    --       and PP.POLICY_ID <> v_policy_id
    --       order by PP.POLICY_ID desc ) A
    --       where rownum < 2;
  
    SELECT SUM(nvl(t.trans_amount, 0))
      INTO v_ret_val
      FROM trans t
     WHERE
    -- t.a2_ct_uro_id in (v_policy_id_2) and 
     t.ct_account_id = get_92_01
     AND t.a3_ct_uro_id = v_asset_header_id
     AND t.a4_ct_uro_id = v_plo_id
     AND t.acc_fund_id = v_fund_id
     AND to_char(t.trans_date, 'YYYY') = p_year;
  
    RETURN nvl(v_ret_val, 0);
  END;

  FUNCTION get_pay_cover_amount
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER AS
    v_fund_id         NUMBER;
    v_policy_id       NUMBER;
    v_pol_header_id   NUMBER;
    v_ret_val         NUMBER;
    v_asset_header_id NUMBER;
    v_plo_id          NUMBER;
  BEGIN
    SELECT a.p_asset_header_id
          ,pc.t_prod_line_option_id
          ,ph.fund_id
          ,a.p_policy_id
          ,ph.policy_header_id
      INTO v_asset_header_id
          ,v_plo_id
          ,v_fund_id
          ,v_policy_id
          ,v_pol_header_id
      FROM p_cover      pc
          ,as_asset     a
          ,p_policy     p
          ,p_pol_header ph
     WHERE pc.p_cover_id = p_p_cover_id
       AND pc.as_asset_id = a.as_asset_id
       AND a.p_policy_id = p.policy_id
       AND p.pol_header_id = ph.policy_header_id;
  
    SELECT SUM(nvl(t.trans_amount, 0))
      INTO v_ret_val
      FROM trans t
     WHERE
    --t.a2_ct_uro_id = pp.policy_id                 and 
     t.ct_account_id = get_92_01
     AND t.dt_account_id = get_77_01_01
     AND t.a3_ct_uro_id = v_asset_header_id
     AND t.a4_ct_uro_id = v_plo_id
     AND to_char(t.trans_date, 'YYYY') = p_year
     AND nvl(t.trans_amount, 0) > 0;
    --AND pp.pol_header_id = v_pol_header_id;
    --AND is_version_cover(v_policy_id, t.a5_ct_uro_id, v_asset_header_id,v_plo_id, v_pol_header_id)=1;
  
    RETURN nvl(v_ret_val, 0);
  
  END get_pay_cover_amount;

  FUNCTION get_charge_cover_amount2
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER AS
    res NUMBER := 0;
  BEGIN
    FOR irec IN (SELECT SUM(t.trans_amount) AS s
                   FROM trans t
                  WHERE --T.TRANS_ID= 10481594 and 
                 -- T.TRANS_TEMPL_ID = 21 and
                  t.trans_amount > 0
                 --and T.OBJ_URO_ID = 1131713
                 --
              AND t.a2_dt_ure_id = 283
              AND t.a2_dt_uro_id != (SELECT a.p_policy_id
                                       FROM p_cover  pc
                                           ,as_asset a
                                      WHERE pc.as_asset_id = a.as_asset_id
                                        AND p_p_cover_id = pc.p_cover_id)
              AND t.a3_dt_ure_id = 302
              AND t.a3_dt_uro_id = (SELECT a.p_asset_header_id
                                      FROM p_cover  pc
                                          ,as_asset a
                                     WHERE pc.as_asset_id = a.as_asset_id
                                       AND p_p_cover_id = pc.p_cover_id)
                 --
              AND t.a4_dt_ure_id = 310
              AND t.a4_dt_uro_id =
                  (SELECT pc.t_prod_line_option_id FROM p_cover pc WHERE p_p_cover_id = pc.p_cover_id)
              AND to_char(t.trans_date, 'YYYY') = p_year
              AND t.dt_account_id = 53)
    LOOP
      res := irec.s;
    END LOOP;
  
    RETURN res;
  END;

  FUNCTION get_pay_cover_amount2
  (
    p_p_cover_id NUMBER
   ,p_year       NUMBER
  ) RETURN NUMBER AS
    res NUMBER := 0;
  BEGIN
  
    FOR irec IN (
                 --     select T.TRANS_AMOUNT,t.*  from  trans t 
                 --        where --T.TRANS_ID= 10481594 and 
                 --        T.TRANS_TEMPL_ID = 21
                 --        and T.TRANS_AMOUNT > 0
                 --        --and T.OBJ_URO_ID = 1131713
                 --        --
                 --        --and t.a2_dt_ure_id = 283
                 --        --and t.a2_dt_uro_id = (
                 --        -- select A.P_POLICY_ID from P_COVER PC , AS_ASSET a  where PC.AS_ASSET_ID = A.AS_ASSET_ID and 1131713 = PC.P_COVER_ID)
                 --        --
                 --        and t.a3_dt_ure_id = 302
                 --        and t.a3_dt_uro_id = (
                 --         select A.P_ASSET_HEADER_ID from P_COVER PC , AS_ASSET a  where PC.AS_ASSET_ID = A.AS_ASSET_ID and 1131713 = PC.P_COVER_ID )
                 --         --
                 --        and t.a4_dt_ure_id = 310
                 --        and t.a4_dt_uro_id = (
                 --         select PC.T_PROD_LINE_OPTION_ID from P_COVER PC where 1131713 = PC.P_COVER_ID )
                 
                 SELECT SUM(t.trans_amount) AS s
                   FROM trans t
                  WHERE -- T.TRANS_ID= 9306645 and
                  t.trans_amount > 0
              AND t.a3_ct_ure_id = 302
              AND t.a3_ct_uro_id = (SELECT a.p_asset_header_id
                                      FROM p_cover  pc
                                          ,as_asset a
                                     WHERE pc.as_asset_id = a.as_asset_id
                                       AND /*1131713*/
                                           p_p_cover_id = pc.p_cover_id)
                 --
              AND t.a4_ct_ure_id = 310
              AND t.a4_ct_uro_id = (SELECT pc.t_prod_line_option_id
                                      FROM p_cover pc
                                     WHERE /*1131713 */
                                     p_p_cover_id = pc.p_cover_id)
              AND t.trans_templ_id IN (741, 44)
              AND t.dt_account_id IN (441, 122)
              AND t.ct_account_id = 481
              AND to_char(t.trans_date, 'YYYY') = p_year)
    LOOP
      res := irec.s;
    END LOOP;
  
    RETURN res;
  END get_pay_cover_amount2;

  --  function get_charge_cover_am_YEARS(pp_policy_rec P_POLICY%rowtype,pp_cover_id number) return number
  --  as
  --   res
  --  begin
  --         for y in to_date(to_char(pp_policy_rec.start_date,'YYYY')) - 1 
  --            ..
  --            to_date(to_char(pp_policy_rec.start_date,'YYYY'))
  --           loop
  --            get_charge_cover_amount(p_p_cover_id number,p_year number )
  --           end loop;

  --  end get_charge_cover_am_YEARS;

  FUNCTION getduedate(doc_id NUMBER) RETURN DATE AS
    ret DATE;
  BEGIN
    SELECT due_date INTO ret FROM ac_payment WHERE payment_id = doc_id;
  
    RETURN ret;
  END getduedate;

  FUNCTION getaccountbynumber(p_num VARCHAR2) RETURN NUMBER AS
    res NUMBER;
  BEGIN
    SELECT a.account_id INTO res FROM account a WHERE a.num = p_num;
    RETURN res;
  END getaccountbynumber;

  FUNCTION get_77_01_01 RETURN NUMBER AS
  BEGIN
    RETURN getaccountbynumber('77.01.01');
  END get_77_01_01;

  FUNCTION get_92_01 RETURN NUMBER AS
  BEGIN
    RETURN getaccountbynumber('92.01');
  END get_92_01;

  FUNCTION getprevcover(pp_cover_id NUMBER) RETURN NUMBER AS
  
    v_asset_header_id     NUMBER;
    v_prod_line_option_id NUMBER;
    v_pol_header_id       NUMBER;
    v_version_num         NUMBER;
    --v_policy_id number;
    --v_policy_prev_id number;
    res NUMBER;
  BEGIN
  
    --      for irec in (
    --              select A.P_ASSET_HEADER_ID, 
    --                    PC.T_PROD_LINE_OPTION_ID,
    --                    PP.POLICY_ID,
    --                    PP.POL_HEADER_ID
    --              from AS_ASSET a, 
    --                   P_COVER pc,
    --                   P_POLICY pp
    --            where PC.P_COVER_ID = pp_cover_id
    --            and PP.POLICY_ID = A.P_POLICY_ID )
    --      loop
    --        v_prod_line_option_id := irec.T_PROD_LINE_OPTION_ID;
    --        v_asset_header_id := irec.P_ASSET_HEADER_ID;
    --        v_policy_id := irec.POLICY_ID;
    --        v_policy_header_id := irec.POL_HEADER_ID;    
    --        
    --      end loop;
    --      
    --      for irec in ( 
    --      select * from (
    --      select PP.POLICY_ID 
    --       from 
    --        P_POLICY pp 
    --       where PP.POL_HEADER_ID = v_policy_header_id
    --       and DOC.GET_LAST_DOC_STATUS_BRIEF(PP.POLICY_ID) in ('ACTIVE','PRINTED','CURRENT')
    --       and PP.POLICY_ID != v_policy_id
    --       order by PP.START_DATE desc, PP.POLICY_ID desc
    --       ) A where rownum = 1  )
    --      loop
    --           v_policy_prev_id := irec.POLICY_ID;  
    --               
    --      end loop;
    --      
    --      for irec in 
    --      (
    --        select PC.P_COVER_ID
    --        from 
    --        AS_ASSET a, 
    --        P_COVER pc where
    --        A.P_POLICY_ID = v_policy_prev_id
    --        and PC.AS_ASSET_ID = A.AS_ASSET_ID
    --        and PC.T_PROD_LINE_OPTION_ID = v_prod_line_option_id
    --      )
    --      loop
    --       res := irec.P_COVER_ID;
    --          raise_application_error(-20000,'1:'||res);    
    --      end loop;
  
    -- Байтин А.
    -- В рамках заявки 188491
    -- Заменил запрос из вью на два простых запроса
    /*       for irec in (
         select * from V_P_COVER_LIFE_ADD where p_cover_id_curr = pp_cover_id)
    loop
      res := irec.P_COVER_ID_PREV;
    end loop;*/
  
    SELECT pc.t_prod_line_option_id
          ,se.p_asset_header_id
          ,pp.pol_header_id
          ,pp.version_num
      INTO v_prod_line_option_id
          ,v_asset_header_id
          ,v_pol_header_id
          ,v_version_num
      FROM p_cover  pc
          ,as_asset se
          ,p_policy pp
     WHERE pc.p_cover_id = pp_cover_id
       AND pc.as_asset_id = se.as_asset_id
       AND se.p_policy_id = pp.policy_id;
  
    BEGIN
      SELECT pc.p_cover_id
        INTO res
        FROM p_policy pp
            ,as_asset aa
            ,p_cover  pc
       WHERE pp.version_num = v_version_num - 1
         AND pp.pol_header_id = v_pol_header_id
         AND aa.p_policy_id = pp.policy_id
         AND pc.as_asset_id = aa.as_asset_id
         AND aa.p_asset_header_id = v_asset_header_id
         AND pc.status_hist_id != 3
         AND pc.t_prod_line_option_id = v_prod_line_option_id;
    EXCEPTION
      WHEN no_data_found THEN
        res := pp_cover_id;
    END;
    RETURN res;
  END getprevcover;

BEGIN
  SELECT a.account_id INTO v_charge_acc_id FROM account a WHERE a.num = '92.01';
EXCEPTION
  WHEN no_data_found THEN
    NULL;
  
    BEGIN
      SELECT a.account_id INTO v_pay_acc_id FROM account a WHERE a.num = '77.01.03';
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
END;
/

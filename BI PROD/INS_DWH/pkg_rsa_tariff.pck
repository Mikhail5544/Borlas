CREATE OR REPLACE PACKAGE PKG_RSA_TARIFF IS

  -- Author  : ABALASHOV
  -- Created : 16.04.2007 12:37:31
  -- Purpose : 

  v_rth rsa_tariff_header%ROWTYPE;
  v_rts rsa_tariff_contents%ROWTYPE;

  PROCEDURE insert_empty_string(P_TAR_HEAD IN NUMBER);
  PROCEDURE create_table_region
  (
    P_TAR_HEAD IN NUMBER
   ,P_REG      IN VARCHAR
  );
  PROCEDURE create_all_tables(p_tar_header_id IN NUMBER);
  PROCEDURE create_tariff_hdr
  (
    P_DATE_TO              IN DATE
   ,P_NOTE                 IN VARCHAR2
   ,P_RSA_TARIFF_HEADER_ID OUT NUMBER
  );

END PKG_RSA_TARIFF;
/
CREATE OR REPLACE PACKAGE BODY PKG_RSA_TARIFF IS

  PROCEDURE create_table_region
  (
    P_TAR_HEAD IN NUMBER
   ,P_REG      IN VARCHAR
  ) IS
  BEGIN
  
    INSERT INTO rsa_tariff_contents
      (RSA_TARIFF_CONTENTS_ID
      ,RSA_TARIFF_HEADER_ID
      ,NUM_TABLE
      ,NUM_STR
      ,PREMIUM
      ,RNP
      ,DECL_LOSS_PR_LIFE
      ,DECL_LOSS_PR
      ,DECL_LOSS_LIFE
      ,PAYMENT_LIFE
      ,PAYMENT_PROP
      ,RZNU_LIFE
      ,RZNU_PR)
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,temp.tbl
            ,temp.st
            ,temp.pr
            ,temp.rnp
            ,temp.col_pr_lf
            ,temp.col_pr
            ,temp.col_lf
            ,temp.pay_lf
            ,temp.pay_pr
            ,temp.rzu_lf
            ,temp.rzu_pr
        FROM (SELECT tbl
                    ,st
                    ,SUM(pr) pr
                    ,SUM(rnp) rnp
                    ,SUM(col_pr_lf) col_pr_lf
                    ,SUM(col_pr) col_pr
                    ,SUM(col_lf) col_lf
                    ,SUM(pay_lf) pay_lf
                    ,SUM(pay_pr) pay_pr
                    ,SUM(rzu_lf) rzu_lf
                    ,SUM(rzu_pr) rzu_pr
                FROM (SELECT CASE P_REG
                               WHEN '77' THEN
                                1
                               WHEN '78' THEN
                                2
                               WHEN '50' THEN
                                3
                               WHEN '47' THEN
                                4
                             END tbl
                            ,CASE
                               WHEN vu.BRIEF = 'TAXI' THEN
                                5
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 0 THEN
                                2
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 1 THEN
                                3
                               WHEN vt.BRIEF = 'CAR_TRAILER' THEN
                                4
                               WHEN vt.BRIEF = 'TRUCK'
                                    AND p.max_weight > 16000 THEN
                                8
                               WHEN vt.BRIEF = 'TRUCK' THEN
                                7
                               WHEN vt.BRIEF = 'TRUCK_TRAILER' THEN
                                9
                               WHEN vt.BRIEF = 'BUS'
                                    AND p.passangers > 20 THEN
                                12
                               WHEN vt.BRIEF = 'BUS' THEN
                                11
                               WHEN vt.BRIEF = 'TROLLEYBUS' THEN
                                13
                               WHEN vt.BRIEF = 'TRAM' THEN
                                14
                               WHEN vt.BRIEF = 'TRACTOR' THEN
                                15
                               WHEN vt.BRIEF = 'TRACTOR_TRAILER' THEN
                                16
                               WHEN vt.BRIEF = 'MOTORCYCLE' THEN
                                17
                             END st
                            ,SUM(nach.nch) pr
                            , -- начисленная премия
                             0 rnp
                            , -- рнп
                             nvl(ev_pr_lf.col_pr_lf, 0) col_pr_lf
                            ,nvl(ev_pr.col_pr, 0) col_pr
                            ,nvl(ev_lf.col_lf, 0) col_lf
                            ,nvl(pay_l.pay, 0) pay_lf
                            ,nvl(pay_p.pay, 0) pay_pr
                            ,0 rzu_lf
                            ,0 rzu_pr
                        FROM oa_policy p
                        JOIN t_vehicle_type vt
                          ON vt.T_VEHICLE_TYPE_ID = p.t_vehicle_type_id
                        JOIN t_rsa_vehicle_type rvt
                          ON rvt.brief = vt.BRIEF
                        JOIN t_vehicle_usage vu
                          ON vu.T_VEHICLE_USAGE_ID = p.t_vehicle_usage_id
                        JOIN oa_contact c
                          ON c.CONTACT_ID = p.sob_contact_id
                      -- начисленные премии
                        LEFT JOIN (SELECT t.a2_ct_uro_id
                                        ,SUM(t.TRANS_AMOUNT) nch
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                   WHERE tt.BRIEF = 'НачПремия'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.a2_ct_uro_id) nach
                          ON nach.a2_ct_uro_id = p.policy_id
                      -- убытки с претензиями и по имуществу и по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_pr.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr_lf
                          ON ev_pr_lf.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по имуществу
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    LEFT JOIN (SELECT cl_lf.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_lf.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_lf
                                                JOIN oa_damage d_lf
                                                  ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                                JOIN t_damage_code tdc_lf
                                                  ON tdc_lf.ID = d_lf.t_damage_code_id
                                                JOIN t_peril tp_lf
                                                  ON tp_lf.ID = tdc_lf.PERIL
                                               WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                                 AND cl_lf.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_lf.C_EVENT_ID) ev_lf
                                      ON ev_lf.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND ev_lf.col = 0
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr
                          ON ev_pr.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_lf.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                    LEFT JOIN (SELECT cl_pr.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_pr.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_pr
                                                JOIN oa_damage d_pr
                                                  ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                                JOIN t_damage_code tdc_pr
                                                  ON tdc_pr.ID = d_pr.t_damage_code_id
                                                JOIN t_peril tp_pr
                                                  ON tp_pr.ID = tdc_pr.PERIL
                                               WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                                 AND cl_pr.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_pr.C_EVENT_ID) ev_pr
                                      ON ev_pr.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND ev_pr.col = 0
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_lf
                          ON ev_lf.AS_ASSET_ID = p.as_asset_id
                      -- выплаты по жизни/здоровью
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_l
                          ON pay_l.A3_DT_URO_ID = p.as_asset_id
                      -- выплаты по имуществу
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_p
                          ON pay_p.A3_DT_URO_ID = p.as_asset_id
                       WHERE substr(p.sob_kladr, 1, 2) = P_REG
                       GROUP BY vu.BRIEF
                               ,vt.BRIEF
                               ,c.IS_INDIVIDUAL
                               ,p.max_weight
                               ,p.passangers
                               ,ev_pr_lf.col_pr_lf
                               ,ev_pr.col_pr
                               ,ev_lf.col_lf
                               ,pay_l.pay
                               ,pay_p.pay) tmp
               GROUP BY tmp.tbl
                       ,tmp.st) temp;
  
  END;

  PROCEDURE create_table_coef
  (
    P_TAR_HEAD IN NUMBER
   ,P_COEF     IN NUMBER
  ) IS
  
  BEGIN
  
    INSERT INTO rsa_tariff_contents
      (RSA_TARIFF_CONTENTS_ID
      ,RSA_TARIFF_HEADER_ID
      ,NUM_TABLE
      ,NUM_STR
      ,PREMIUM
      ,RNP
      ,DECL_LOSS_PR_LIFE
      ,DECL_LOSS_PR
      ,DECL_LOSS_LIFE
      ,PAYMENT_LIFE
      ,PAYMENT_PROP
      ,RZNU_LIFE
      ,RZNU_PR)
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,temp.tbl
            ,temp.st
            ,temp.pr
            ,temp.rnp
            ,temp.col_pr_lf
            ,temp.col_pr
            ,temp.col_lf
            ,temp.pay_lf
            ,temp.pay_pr
            ,temp.rzu_lf
            ,temp.rzu_pr
        FROM (SELECT tbl
                    ,st
                    ,SUM(pr) pr
                    ,SUM(rnp) rnp
                    ,SUM(col_pr_lf) col_pr_lf
                    ,SUM(col_pr) col_pr
                    ,SUM(col_lf) col_lf
                    ,SUM(pay_lf) pay_lf
                    ,SUM(pay_pr) pay_pr
                    ,SUM(rzu_lf) rzu_lf
                    ,SUM(rzu_pr) rzu_pr
                FROM (SELECT CASE P_COEF
                               WHEN 1.3 THEN
                                5
                               WHEN 1 THEN
                                6
                               WHEN 0.5 THEN
                                7
                             END tbl
                            ,CASE
                               WHEN vu.BRIEF = 'TAXI' THEN
                                5
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 0 THEN
                                2
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 1 THEN
                                3
                               WHEN vt.BRIEF = 'CAR_TRAILER' THEN
                                4
                               WHEN vt.BRIEF = 'TRUCK'
                                    AND p.max_weight > 16000 THEN
                                8
                               WHEN vt.BRIEF = 'TRUCK' THEN
                                7
                               WHEN vt.BRIEF = 'TRUCK_TRAILER' THEN
                                9
                               WHEN vt.BRIEF = 'BUS'
                                    AND p.passangers > 20 THEN
                                12
                               WHEN vt.BRIEF = 'BUS' THEN
                                11
                               WHEN vt.BRIEF = 'TROLLEYBUS' THEN
                                13
                               WHEN vt.BRIEF = 'TRAM' THEN
                                14
                               WHEN vt.BRIEF = 'TRACTOR' THEN
                                15
                               WHEN vt.BRIEF = 'TRACTOR_TRAILER' THEN
                                16
                               WHEN vt.BRIEF = 'MOTORCYCLE' THEN
                                17
                             END st
                            ,SUM(nach.nch) pr
                            , -- начисленная премия
                             0 rnp
                            , -- рнп
                             nvl(ev_pr_lf.col_pr_lf, 0) col_pr_lf
                            ,nvl(ev_pr.col_pr, 0) col_pr
                            ,nvl(ev_lf.col_lf, 0) col_lf
                            ,nvl(pay_l.pay, 0) pay_lf
                            ,nvl(pay_p.pay, 0) pay_pr
                            ,0 rzu_lf
                            ,0 rzu_pr
                        FROM oa_policy p
                        JOIN t_vehicle_type vt
                          ON vt.T_VEHICLE_TYPE_ID = p.t_vehicle_type_id
                        JOIN t_rsa_vehicle_type rvt
                          ON rvt.brief = vt.BRIEF
                        JOIN t_vehicle_usage vu
                          ON vu.T_VEHICLE_USAGE_ID = p.t_vehicle_usage_id
                        JOIN oa_contact c
                          ON c.CONTACT_ID = p.sob_contact_id
                      -- начисленные премии
                        LEFT JOIN (SELECT t.a2_ct_uro_id
                                        ,SUM(t.TRANS_AMOUNT) nch
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                   WHERE tt.BRIEF = 'НачПремия'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.a2_ct_uro_id) nach
                          ON nach.a2_ct_uro_id = p.policy_id
                      -- убытки с претензиями и по имуществу и по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_pr.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr_lf
                          ON ev_pr_lf.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по имуществу
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    LEFT JOIN (SELECT cl_lf.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_lf.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_lf
                                                JOIN oa_damage d_lf
                                                  ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                                JOIN t_damage_code tdc_lf
                                                  ON tdc_lf.ID = d_lf.t_damage_code_id
                                                JOIN t_peril tp_lf
                                                  ON tp_lf.ID = tdc_lf.PERIL
                                               WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                                 AND cl_lf.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_lf.C_EVENT_ID) ev_lf
                                      ON ev_lf.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND ev_lf.col = 0
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr
                          ON ev_pr.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_lf.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                    LEFT JOIN (SELECT cl_pr.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_pr.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_pr
                                                JOIN oa_damage d_pr
                                                  ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                                JOIN t_damage_code tdc_pr
                                                  ON tdc_pr.ID = d_pr.t_damage_code_id
                                                JOIN t_peril tp_pr
                                                  ON tp_pr.ID = tdc_pr.PERIL
                                               WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                                 AND cl_pr.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_pr.C_EVENT_ID) ev_pr
                                      ON ev_pr.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND ev_pr.col = 0
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_lf
                          ON ev_lf.AS_ASSET_ID = p.as_asset_id
                      -- выплаты по жизни/здоровью
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_l
                          ON pay_l.A3_DT_URO_ID = p.as_asset_id
                      -- выплаты по имуществу
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_p
                          ON pay_p.A3_DT_URO_ID = p.as_asset_id
                       WHERE p.coef_area = P_COEF
                       GROUP BY vu.BRIEF
                               ,vt.BRIEF
                               ,c.IS_INDIVIDUAL
                               ,p.max_weight
                               ,p.passangers
                               ,ev_pr_lf.col_pr_lf
                               ,ev_pr.col_pr
                               ,ev_lf.col_lf
                               ,pay_l.pay
                               ,pay_p.pay) tmp
               GROUP BY tmp.tbl
                       ,tmp.st) temp;
  
  END;

  PROCEDURE create_table_city
  (
    P_TAR_HEAD IN NUMBER
   ,P_CITY     IN VARCHAR
  ) IS
  BEGIN
  
    INSERT INTO rsa_tariff_contents
      (RSA_TARIFF_CONTENTS_ID
      ,RSA_TARIFF_HEADER_ID
      ,NUM_TABLE
      ,NUM_STR
      ,PREMIUM
      ,RNP
      ,DECL_LOSS_PR_LIFE
      ,DECL_LOSS_PR
      ,DECL_LOSS_LIFE
      ,PAYMENT_LIFE
      ,PAYMENT_PROP
      ,RZNU_LIFE
      ,RZNU_PR)
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,temp.tbl
            ,temp.st
            ,temp.pr
            ,temp.rnp
            ,temp.col_pr_lf
            ,temp.col_pr
            ,temp.col_lf
            ,temp.pay_lf
            ,temp.pay_pr
            ,temp.rzu_lf
            ,temp.rzu_pr
        FROM (SELECT tbl
                    ,st
                    ,SUM(pr) pr
                    ,SUM(rnp) rnp
                    ,SUM(col_pr_lf) col_pr_lf
                    ,SUM(col_pr) col_pr
                    ,SUM(col_lf) col_lf
                    ,SUM(pay_lf) pay_lf
                    ,SUM(pay_pr) pay_pr
                    ,SUM(rzu_lf) rzu_lf
                    ,SUM(rzu_pr) rzu_pr
                FROM (SELECT CASE P_CITY
                               WHEN '54000001000' THEN
                                9
                               WHEN '61000001000' THEN
                                8
                               WHEN '52000001000' THEN
                                10
                               WHEN '66000001000' THEN
                                11
                               WHEN '27000001000' THEN
                                12
                             END tbl
                            ,CASE
                               WHEN vu.BRIEF = 'TAXI' THEN
                                5
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 0 THEN
                                2
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 1 THEN
                                3
                               WHEN vt.BRIEF = 'CAR_TRAILER' THEN
                                4
                               WHEN vt.BRIEF = 'TRUCK'
                                    AND p.max_weight > 16000 THEN
                                8
                               WHEN vt.BRIEF = 'TRUCK' THEN
                                7
                               WHEN vt.BRIEF = 'TRUCK_TRAILER' THEN
                                9
                               WHEN vt.BRIEF = 'BUS'
                                    AND p.passangers > 20 THEN
                                12
                               WHEN vt.BRIEF = 'BUS' THEN
                                11
                               WHEN vt.BRIEF = 'TROLLEYBUS' THEN
                                13
                               WHEN vt.BRIEF = 'TRAM' THEN
                                14
                               WHEN vt.BRIEF = 'TRACTOR' THEN
                                15
                               WHEN vt.BRIEF = 'TRACTOR_TRAILER' THEN
                                16
                               WHEN vt.BRIEF = 'MOTORCYCLE' THEN
                                17
                             END st
                            ,SUM(nach.nch) pr
                            , -- начисленная премия
                             0 rnp
                            , -- рнп
                             nvl(ev_pr_lf.col_pr_lf, 0) col_pr_lf
                            ,nvl(ev_pr.col_pr, 0) col_pr
                            ,nvl(ev_lf.col_lf, 0) col_lf
                            ,nvl(pay_l.pay, 0) pay_lf
                            ,nvl(pay_p.pay, 0) pay_pr
                            ,0 rzu_lf
                            ,0 rzu_pr
                        FROM oa_policy p
                        JOIN t_vehicle_type vt
                          ON vt.T_VEHICLE_TYPE_ID = p.t_vehicle_type_id
                        JOIN t_rsa_vehicle_type rvt
                          ON rvt.brief = vt.BRIEF
                        JOIN t_vehicle_usage vu
                          ON vu.T_VEHICLE_USAGE_ID = p.t_vehicle_usage_id
                        JOIN oa_contact c
                          ON c.CONTACT_ID = p.sob_contact_id
                      -- начисленные премии
                        LEFT JOIN (SELECT t.a2_ct_uro_id
                                        ,SUM(t.TRANS_AMOUNT) nch
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                   WHERE tt.BRIEF = 'НачПремия'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.a2_ct_uro_id) nach
                          ON nach.a2_ct_uro_id = p.policy_id
                      -- убытки с претензиями и по имуществу и по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_pr.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr_lf
                          ON ev_pr_lf.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по имуществу
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    LEFT JOIN (SELECT cl_lf.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_lf.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_lf
                                                JOIN oa_damage d_lf
                                                  ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                                JOIN t_damage_code tdc_lf
                                                  ON tdc_lf.ID = d_lf.t_damage_code_id
                                                JOIN t_peril tp_lf
                                                  ON tp_lf.ID = tdc_lf.PERIL
                                               WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                                 AND cl_lf.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_lf.C_EVENT_ID) ev_lf
                                      ON ev_lf.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND ev_lf.col = 0
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr
                          ON ev_pr.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_lf.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                    LEFT JOIN (SELECT cl_pr.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_pr.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_pr
                                                JOIN oa_damage d_pr
                                                  ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                                JOIN t_damage_code tdc_pr
                                                  ON tdc_pr.ID = d_pr.t_damage_code_id
                                                JOIN t_peril tp_pr
                                                  ON tp_pr.ID = tdc_pr.PERIL
                                               WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                                 AND cl_pr.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_pr.C_EVENT_ID) ev_pr
                                      ON ev_pr.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND ev_pr.col = 0
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_lf
                          ON ev_lf.AS_ASSET_ID = p.as_asset_id
                      -- выплаты по жизни/здоровью
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_l
                          ON pay_l.A3_DT_URO_ID = p.as_asset_id
                      -- выплаты по имуществу
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_p
                          ON pay_p.A3_DT_URO_ID = p.as_asset_id
                       WHERE p.sob_kladr = P_CITY
                       GROUP BY vu.BRIEF
                               ,vt.BRIEF
                               ,c.IS_INDIVIDUAL
                               ,p.max_weight
                               ,p.passangers
                               ,ev_pr_lf.col_pr_lf
                               ,ev_pr.col_pr
                               ,ev_lf.col_lf
                               ,pay_l.pay
                               ,pay_p.pay) tmp
               GROUP BY tmp.tbl
                       ,tmp.st) temp;
  
  END;

  PROCEDURE create_table_for
  (
    P_TAR_HEAD IN NUMBER
   ,P_FOR      IN VARCHAR
  ) IS
  BEGIN
  
    INSERT INTO rsa_tariff_contents
      (RSA_TARIFF_CONTENTS_ID
      ,RSA_TARIFF_HEADER_ID
      ,NUM_TABLE
      ,NUM_STR
      ,PREMIUM
      ,RNP
      ,DECL_LOSS_PR_LIFE
      ,DECL_LOSS_PR
      ,DECL_LOSS_LIFE
      ,PAYMENT_LIFE
      ,PAYMENT_PROP
      ,RZNU_LIFE
      ,RZNU_PR)
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,temp.tbl
            ,temp.st
            ,temp.pr
            ,temp.rnp
            ,temp.col_pr_lf
            ,temp.col_pr
            ,temp.col_lf
            ,temp.pay_lf
            ,temp.pay_pr
            ,temp.rzu_lf
            ,temp.rzu_pr
        FROM (SELECT tbl
                    ,st
                    ,SUM(pr) pr
                    ,SUM(rnp) rnp
                    ,SUM(col_pr_lf) col_pr_lf
                    ,SUM(col_pr) col_pr
                    ,SUM(col_lf) col_lf
                    ,SUM(pay_lf) pay_lf
                    ,SUM(pay_pr) pay_pr
                    ,SUM(rzu_lf) rzu_lf
                    ,SUM(rzu_pr) rzu_pr
                FROM (SELECT 13 tbl
                            ,CASE
                               WHEN vu.BRIEF = 'TAXI' THEN
                                5
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 0 THEN
                                2
                               WHEN vt.BRIEF = 'CAR'
                                    AND c.IS_INDIVIDUAL = 1 THEN
                                3
                               WHEN vt.BRIEF = 'CAR_TRAILER' THEN
                                4
                               WHEN vt.BRIEF = 'TRUCK'
                                    AND p.max_weight > 16000 THEN
                                8
                               WHEN vt.BRIEF = 'TRUCK' THEN
                                7
                               WHEN vt.BRIEF = 'TRUCK_TRAILER' THEN
                                9
                               WHEN vt.BRIEF = 'BUS'
                                    AND p.passangers > 20 THEN
                                12
                               WHEN vt.BRIEF = 'BUS' THEN
                                11
                               WHEN vt.BRIEF = 'TROLLEYBUS' THEN
                                13
                               WHEN vt.BRIEF = 'TRAM' THEN
                                14
                               WHEN vt.BRIEF = 'TRACTOR' THEN
                                15
                               WHEN vt.BRIEF = 'TRACTOR_TRAILER' THEN
                                16
                               WHEN vt.BRIEF = 'MOTORCYCLE' THEN
                                17
                             END st
                            ,SUM(nach.nch) pr
                            , -- начисленная премия
                             0 rnp
                            , -- рнп
                             nvl(ev_pr_lf.col_pr_lf, 0) col_pr_lf
                            ,nvl(ev_pr.col_pr, 0) col_pr
                            ,nvl(ev_lf.col_lf, 0) col_lf
                            ,nvl(pay_l.pay, 0) pay_lf
                            ,nvl(pay_p.pay, 0) pay_pr
                            ,0 rzu_lf
                            ,0 rzu_pr
                        FROM oa_policy p
                        JOIN t_vehicle_type vt
                          ON vt.T_VEHICLE_TYPE_ID = p.t_vehicle_type_id
                        JOIN t_rsa_vehicle_type rvt
                          ON rvt.brief = vt.BRIEF
                        JOIN t_vehicle_usage vu
                          ON vu.T_VEHICLE_USAGE_ID = p.t_vehicle_usage_id
                        JOIN oa_contact c
                          ON c.CONTACT_ID = p.sob_contact_id
                      -- начисленные премии
                        LEFT JOIN (SELECT t.a2_ct_uro_id
                                        ,SUM(t.TRANS_AMOUNT) nch
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                   WHERE tt.BRIEF = 'НачПремия'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.a2_ct_uro_id) nach
                          ON nach.a2_ct_uro_id = p.policy_id
                      -- убытки с претензиями и по имуществу и по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_pr.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr_lf
                          ON ev_pr_lf.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по имуществу
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_pr
                                    FROM oa_events ev
                                    JOIN oa_claim cl_pr
                                      ON cl_pr.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_pr
                                      ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = d_pr.t_damage_code_id
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                    LEFT JOIN (SELECT cl_lf.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_lf.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_lf
                                                JOIN oa_damage d_lf
                                                  ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                                JOIN t_damage_code tdc_lf
                                                  ON tdc_lf.ID = d_lf.t_damage_code_id
                                                JOIN t_peril tp_lf
                                                  ON tp_lf.ID = tdc_lf.PERIL
                                               WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                                 AND cl_lf.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_lf.C_EVENT_ID) ev_lf
                                      ON ev_lf.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND ev_lf.col = 0
                                     AND cl_pr.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_pr
                          ON ev_pr.AS_ASSET_ID = p.as_asset_id
                      -- убытки с претензиями только по жизни/здоровью
                        LEFT JOIN (SELECT ev.AS_ASSET_ID
                                        ,COUNT(DISTINCT ev.C_EVENT_ID) col_lf
                                    FROM oa_events ev
                                    JOIN oa_claim cl_lf
                                      ON cl_lf.C_EVENT_ID = ev.C_EVENT_ID
                                    JOIN oa_damage d_lf
                                      ON d_lf.c_claim_id = cl_lf.C_CLAIM_ID
                                    JOIN t_damage_code tdc_lf
                                      ON tdc_lf.ID = d_lf.t_damage_code_id
                                    JOIN t_peril tp_lf
                                      ON tp_lf.ID = tdc_lf.PERIL
                                    LEFT JOIN (SELECT cl_pr.C_EVENT_ID
                                                    ,COUNT(DISTINCT cl_pr.C_CLAIM_HEADER_ID) col
                                                FROM oa_claim cl_pr
                                                JOIN oa_damage d_pr
                                                  ON d_pr.c_claim_id = cl_pr.C_CLAIM_ID
                                                JOIN t_damage_code tdc_pr
                                                  ON tdc_pr.ID = d_pr.t_damage_code_id
                                                JOIN t_peril tp_pr
                                                  ON tp_pr.ID = tdc_pr.PERIL
                                               WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                                 AND cl_pr.claim_status_date <= v_rth.date_to
                                               GROUP BY cl_pr.C_EVENT_ID) ev_pr
                                      ON ev_pr.C_EVENT_ID = ev.C_EVENT_ID
                                   WHERE tp_lf.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND ev_pr.col = 0
                                     AND cl_lf.claim_status_date <= v_rth.date_to
                                   GROUP BY ev.AS_ASSET_ID) ev_lf
                          ON ev_lf.AS_ASSET_ID = p.as_asset_id
                      -- выплаты по жизни/здоровью
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ЗДОРОВЬЕ'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_l
                          ON pay_l.A3_DT_URO_ID = p.as_asset_id
                      -- выплаты по имуществу
                        LEFT JOIN (SELECT t.A3_DT_URO_ID
                                        ,SUM(t.TRANS_AMOUNT) pay
                                    FROM oa_trans t
                                    JOIN trans_templ tt
                                      ON tt.TRANS_TEMPL_ID = t.TRANS_TEMPL_ID
                                    JOIN t_damage_code tdc_pr
                                      ON tdc_pr.ID = t.A5_DT_URO_ID
                                    JOIN t_peril tp_pr
                                      ON tp_pr.ID = tdc_pr.PERIL
                                   WHERE tp_pr.BRIEF = 'ОСАГО_ИМУЩЕСТВО'
                                     AND tt.BRIEF = 'ВыплВозмещ'
                                     AND t.TRANS_DATE <= v_rth.date_to
                                   GROUP BY t.A3_DT_URO_ID) pay_p
                          ON pay_p.A3_DT_URO_ID = p.as_asset_id
                       WHERE p.is_foreing_reg = P_FOR
                       GROUP BY vu.BRIEF
                               ,vt.BRIEF
                               ,c.IS_INDIVIDUAL
                               ,p.max_weight
                               ,p.passangers
                               ,ev_pr_lf.col_pr_lf
                               ,ev_pr.col_pr
                               ,ev_lf.col_lf
                               ,pay_l.pay
                               ,pay_p.pay) tmp
               GROUP BY tmp.tbl
                       ,tmp.st) temp;
  
  END;

  PROCEDURE insert_empty_string(P_TAR_HEAD IN NUMBER) IS
    i NUMBER;
  BEGIN
    NULL;
    FOR i IN 2 .. 17
    LOOP
      -- по строкам, кроме строк 1,10,18
      FOR j IN 1 .. 13
      LOOP
        -- по таблицам
        IF (i <> 10)
        THEN
          BEGIN
            SELECT rtc.*
              INTO v_rts
              FROM rsa_tariff_contents rtc
             WHERE rtc.rsa_tariff_header_id = P_TAR_HEAD
               AND rtc.num_str = i
               AND rtc.num_table = j;
          EXCEPTION
            WHEN no_data_found THEN
              INSERT INTO rsa_tariff_contents
                SELECT sq_rsa_tariff_contents.nextval
                      ,P_TAR_HEAD
                      ,j
                      ,i
                      ,0
                      ,0
                      ,0
                      ,0
                      ,0
                      ,0
                      ,0
                      ,0
                      ,0
                  FROM dual;
          END;
        END IF;
      END LOOP;
    END LOOP;
  END;

  PROCEDURE calc_itogi(P_TAR_HEAD IN NUMBER) IS
  BEGIN
  
    -- строка 1
    INSERT INTO rsa_tariff_contents rtc
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,tmp.NUM_TABLE
            ,1
            ,tmp.premium
            ,tmp.rnp
            ,tmp.decl_loss_pr_life
            ,tmp.decl_loss_pr
            ,tmp.decl_loss_life
            ,tmp.payment_life
            ,tmp.payment_prop
            ,tmp.rznu_life
            ,tmp.rznu_pr
        FROM (SELECT rtc.NUM_TABLE
                    ,SUM(rtc.premium) premium
                    ,SUM(rtc.rnp) rnp
                    ,SUM(rtc.decl_loss_pr_life) decl_loss_pr_life
                    ,SUM(rtc.decl_loss_pr) decl_loss_pr
                    ,SUM(rtc.decl_loss_life) decl_loss_life
                    ,SUM(rtc.payment_life) payment_life
                    ,SUM(rtc.payment_prop) payment_prop
                    ,SUM(rtc.rznu_life) rznu_life
                    ,SUM(rtc.rznu_pr) rznu_pr
                FROM rsa_tariff_contents rtc
               WHERE rtc.rsa_tariff_header_id = P_TAR_HEAD
                 AND rtc.num_str IN (2, 3)
               GROUP BY rtc.num_table) tmp;
  
    -- строка 10
    INSERT INTO rsa_tariff_contents rtc
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,tmp.NUM_TABLE
            ,10
            ,tmp.premium
            ,tmp.rnp
            ,tmp.decl_loss_pr_life
            ,tmp.decl_loss_pr
            ,tmp.decl_loss_life
            ,tmp.payment_life
            ,tmp.payment_prop
            ,tmp.rznu_life
            ,tmp.rznu_pr
        FROM (SELECT rtc.NUM_TABLE
                    ,SUM(rtc.premium) premium
                    ,SUM(rtc.rnp) rnp
                    ,SUM(rtc.decl_loss_pr_life) decl_loss_pr_life
                    ,SUM(rtc.decl_loss_pr) decl_loss_pr
                    ,SUM(rtc.decl_loss_life) decl_loss_life
                    ,SUM(rtc.payment_life) payment_life
                    ,SUM(rtc.payment_prop) payment_prop
                    ,SUM(rtc.rznu_life) rznu_life
                    ,SUM(rtc.rznu_pr) rznu_pr
                FROM rsa_tariff_contents rtc
               WHERE rtc.rsa_tariff_header_id = P_TAR_HEAD
                 AND rtc.num_str IN (11, 12)
               GROUP BY rtc.num_table) tmp;
  
    -- строка 18
    INSERT INTO rsa_tariff_contents rtc
      SELECT sq_rsa_tariff_contents.nextval
            ,P_TAR_HEAD
            ,tmp.NUM_TABLE
            ,18
            ,tmp.premium
            ,tmp.rnp
            ,tmp.decl_loss_pr_life
            ,tmp.decl_loss_pr
            ,tmp.decl_loss_life
            ,tmp.payment_life
            ,tmp.payment_prop
            ,tmp.rznu_life
            ,tmp.rznu_pr
        FROM (SELECT rtc.NUM_TABLE
                    ,SUM(rtc.premium) premium
                    ,SUM(rtc.rnp) rnp
                    ,SUM(rtc.decl_loss_pr_life) decl_loss_pr_life
                    ,SUM(rtc.decl_loss_pr) decl_loss_pr
                    ,SUM(rtc.decl_loss_life) decl_loss_life
                    ,SUM(rtc.payment_life) payment_life
                    ,SUM(rtc.payment_prop) payment_prop
                    ,SUM(rtc.rznu_life) rznu_life
                    ,SUM(rtc.rznu_pr) rznu_pr
                FROM rsa_tariff_contents rtc
               WHERE rtc.rsa_tariff_header_id = P_TAR_HEAD
                 AND rtc.num_str NOT IN (1, 10)
               GROUP BY rtc.num_table) tmp;
  
  END;

  PROCEDURE create_all_tables(p_tar_header_id IN NUMBER) IS
  BEGIN
  
    SELECT rth.*
      INTO v_rth
      FROM rsa_tariff_header rth
     WHERE rth.rsa_tariff_header_id = p_tar_header_id;
  
    create_table_region(p_tar_header_id, '77'); -- Москва - Таблица 1
    create_table_region(p_tar_header_id, '78'); -- Питер  - Таблица 2
    create_table_region(p_tar_header_id, '50'); -- МО     - Таблица 3
    create_table_region(p_tar_header_id, '47'); -- ЛО     - Таблица 4
  
    create_table_coef(p_tar_header_id, 1.3); -- КТ=1.3 - Таблица 5
    create_table_coef(p_tar_header_id, 1); -- КТ=1   - Таблица 6
    create_table_coef(p_tar_header_id, 0.5); -- КТ=0.5 - Таблица 7
  
    create_table_city(p_tar_header_id, '54000001000'); -- Новосибирск      - Таблица 9
    create_table_city(p_tar_header_id, '61000001000'); -- Ростов-На-Дону   - Таблица 8
    create_table_city(p_tar_header_id, '52000001000'); -- Нижний Новгород  - Таблица 10
    create_table_city(p_tar_header_id, '66000001000'); -- Екатеринбург     - Таблица 11
    create_table_city(p_tar_header_id, '27000001000'); -- Хабаровск        - Таблица 12
  
    create_table_for(p_tar_header_id, 1); -- Иностр государства            - Таблица 13
  
    insert_empty_string(p_tar_header_id);
    calc_itogi(p_tar_header_id);
  END;

  PROCEDURE create_tariff_hdr
  (
    P_DATE_TO              IN DATE
   ,P_NOTE                 IN VARCHAR2
   ,P_RSA_TARIFF_HEADER_ID OUT NUMBER
  ) IS
    tmp_id NUMBER;
  BEGIN
    IF P_DATE_TO IS NOT NULL
    THEN
      SELECT SQ_RSA_TARIFF_HEADER.nextval INTO tmp_id FROM dual;
      INSERT INTO RSA_TARIFF_HEADER VALUES (tmp_id, P_DATE_TO, P_NOTE);
      P_RSA_TARIFF_HEADER_ID := tmp_id;
    END IF;
  END;

END PKG_RSA_TARIFF;
/

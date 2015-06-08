CREATE OR REPLACE PACKAGE Pkg_Policy_11 IS

  /**
  * Работа с полисами - создание, редактирование, удаление, изменения статусов
  * @author Patsan O.
  * @version 1
  */

  /**
  * Процедура для выполнения Job`а на создание автопролонгации
  * создание новой версии договора в статусе проект
  * @author Сыровецкий Д.
  * @param p_pol_id ИД заголовка договора
  */
  PROCEDURE job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  );

  /*                             
  **
  * Процедура для выполнения Job`а на создание автопролонгации
  * создание новой версии договора в статусе проект
  * @author Сыровецкий Д.
  * @param p_pol_id ИД заголовка договора
  */

  FUNCTION job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  ) RETURN NUMBER;

  FUNCTION job_prolongation_indexation
  (
    p_pol_id      NUMBER DEFAULT NULL
   ,flg_run_p3    NUMBER DEFAULT 1
   ,p_is_auto_pro NUMBER DEFAULT 1
   ,p_year        NUMBER DEFAULT TO_CHAR(SYSDATE, 'YYYY')
  ) RETURN NUMBER;

END Pkg_Policy_11;
/
CREATE OR REPLACE PACKAGE BODY PKG_POLICY_11 IS

  P_DEBUG BOOLEAN := FALSE;

  PROCEDURE COVER_LOG
  (
    p_p_cover_id IN NUMBER
   ,p_message    IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF P_DEBUG
    THEN
      INSERT INTO P_COVER_DEBUG
        (P_COVER_ID, execution_date, operation_type, debug_message)
      VALUES
        (p_p_cover_id, SYSDATE, 'INS.PKG_POLICY', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  ) RETURN NUMBER IS
  
    v_skip_flg     NUMBER;
    v_count        NUMBER;
    v_pr_policy_id NUMBER;
  
    v_new_policy_id NUMBER;
    v_temp_id       NUMBER;
  
    v_pol_type VARCHAR2(50);
  
  BEGIN
  
    v_pr_policy_id := 0;
    dbms_output.put_line('JOB_PROLONGATION_P2 P_POL_ID' || p_pol_id);
  
    FOR cur IN (SELECT ll.brief
                      ,pc.p_cover_id
                      ,pp.POLICY_ID
                      ,pph.POLICY_HEADER_ID
                      ,TO_DATE(TO_CHAR(pph.start_date, 'DD.MM.') || TO_CHAR(pp.start_date, 'YYYY')
                              ,'DD.MM.YYYY') START_DATE
                       /*, CASE WHEN (SELECT COUNT(*)
                                 FROM ins.p_pol_addendum_type ppat,
                                      ins.t_addendum_type tat
                                 WHERE ppat.p_policy_id = pp.policy_id
                                       AND ppat.t_addendum_type_id = tat.t_addendum_type_id
                                       AND tat.brief = 'COL_METHOD_CHANGE') > 0
                            THEN TO_DATE(TO_CHAR(pph.start_date,'DD.MM.')||TO_CHAR(pp.start_date,'YYYY'),'DD.MM.YYYY')
                           ELSE pp.START_DATE
                       END START_DATE*/
                       /*, pp.START_DATE*/
                      ,pp.END_DATE
                      ,pp.PAYMENT_TERM_ID
                      ,pp.PAYMENTOFF_TERM_ID
                  FROM p_pol_header       pph
                      ,p_policy           pp
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob_line         ll
                 WHERE pp.POL_HEADER_ID = pph.POLICY_HEADER_ID
                   AND pph.POLICY_HEADER_ID = NVL(p_pol_id, pph.POLICY_HEADER_ID)
                   AND pp.policy_id = pph.last_ver_id
                      --AND pp.VERSION_NUM = (SELECT MAX(a.version_num) FROM p_policy a WHERE a.POL_HEADER_ID = pph.POLICY_HEADER_ID)
                   AND pp.END_DATE > ADD_MONTHS(pp.START_DATE, 12)
                   AND aa.P_POLICY_ID = pp.POLICY_ID
                   AND pc.AS_ASSET_ID = aa.AS_ASSET_ID
                   AND plo.ID = pc.T_PROD_LINE_OPTION_ID
                   AND pl.ID = plo.PRODUCT_LINE_ID
                   AND ll.T_LOB_LINE_ID = pl.T_LOB_LINE_ID
                      --AND pl.IS_AVTOPROLONGATION = 1
                   AND doc.get_last_doc_status_brief(pp.POLICY_ID) IN
                       ('CURRENT', 'ACTIVE', 'STOP', 'PRINTED')
                 ORDER BY pp.policy_id)
    LOOP
    
      BEGIN
        dbms_output.put_line('JOB_PROLONGATION_P2 PC.P_COVER_ID' || cur.p_cover_id);
        SAVEPOINT start_loop;
      
        v_skip_flg := 0;
        v_count    := 0;
      
        --проверка, чтобы не брали один и тот же полис
        --по разным п_коверам
      
        IF v_pr_policy_id = cur.policy_id
        THEN
          v_skip_flg := 1;
        ELSE
          v_pr_policy_id := cur.policy_id;
        END IF;
      
        IF UPPER(cur.brief) = 'WOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
           WHERE cch.P_COVER_ID = cur.p_cover_id
             AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
             AND cd.C_CLAIM_ID = cc.c_claim_id
             AND cc.SEQNO =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID)
             AND doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND dc.ID = cd.T_DAMAGE_CODE_ID
             AND dc.DESCRIPTION = 'Установление застрахованному 1 или 2 группы инвалидности';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        v_count := 0;
      
        IF UPPER(cur.brief) = 'PWOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
           WHERE cch.P_COVER_ID = cur.p_cover_id
             AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
             AND cd.C_CLAIM_ID = cc.c_claim_id
             AND cc.SEQNO =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID)
             AND doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND dc.ID = cd.T_DAMAGE_CODE_ID
             AND dc.DESCRIPTION = 'Установление застрахованному 1 или 2 группы инвалидности';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        dbms_output.put_line('job_prolongation_p2 v_skip_flg ' || v_skip_flg);
      
        IF v_skip_flg = 0
        THEN
        
          BEGIN
          
            SELECT t_policy_change_type_id
              INTO v_temp_id
              FROM t_policy_change_type
             WHERE brief = 'Технические';
          
            dbms_output.put_line('job_prolongation_p2 PKG_POLICY.NEW_POLICY_VERSION ' ||
                                 cur.policy_id || ' ' || v_temp_id);
            v_new_policy_id := pkg_policy.NEW_POLICY_VERSION(par_policy_id             => cur.policy_id
                                                            ,par_change_id             => v_temp_id
                                                            ,par_policy_change_type_id => v_temp_id);
          
            BEGIN
            
              SELECT t_addendum_type_id
                INTO v_temp_id
                FROM t_addendum_type
               WHERE brief = 'Автопролонгация';
            
              INSERT INTO ven_p_pol_addendum_type
                (p_policy_id, t_addendum_type_id)
              VALUES
                (v_new_policy_id, v_temp_id);
            
              /*exception
              when others then
                raise;*/
            END;
          
            UPDATE p_policy pp
               SET pp.start_date            = ADD_MONTHS(cur.start_date, 12)
                  ,pp.confirm_date          = ADD_MONTHS(cur.start_date, 12)
                  ,pp.end_date              = cur.end_date
                  ,pp.NOTICE_DATE_ADDENDUM  = ADD_MONTHS(cur.start_date, 12)
                  ,pp.CONFIRM_DATE_ADDENDUM = ADD_MONTHS(cur.start_date, 12)
             WHERE policy_id = v_new_policy_id;
          
            pkg_policy.UPDATE_POLICY_DATES(v_new_policy_id);
          
            pkg_payment.delete_unpayed_pol(v_new_policy_id);
          
            SELECT pft.brief
              INTO v_pol_type
              FROM ven_p_policy           pol
                  ,ven_t_product          p
                  ,ven_p_pol_header       ph
                  ,ven_t_policy_form_type pft
             WHERE pol.policy_id = v_new_policy_id
               AND ph.policy_header_id = pol.pol_header_id
               AND ph.product_id = p.product_id
               AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
          
            IF NVL(v_pol_type, '?') = 'Жизнь'
            THEN
              pkg_payment.POLICY_MAKE_PLANNING(pkg_policy.get_last_version(cur.POLICY_HEADER_ID)
                                              ,cur.PAYMENT_TERM_ID
                                              ,'PAYMENT');
            ELSE
              pkg_payment.POLICY_MAKE_PLANNING(v_new_policy_id, cur.PAYMENT_TERM_ID, 'PAYMENT');
            END IF;
          
            /*  exception
            when others then
              raise;*/
          END;
        ELSE
          dbms_output.put_line('JOB_PROLONGATION_P2 V_SKIP != 0');
        
        END IF;
      
        RETURN v_new_policy_id;
      
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('ERR ' || SQLERRM);
          ROLLBACK TO SAVEPOINT start_loop;
      END;
    
    END LOOP;
  
  END;

  PROCEDURE job_prolongation_p2
  (
    p_pol_id   NUMBER DEFAULT NULL
   ,flg_run_p3 NUMBER DEFAULT 1
  ) IS
    RESULT NUMBER;
  BEGIN
    dbms_output.put_line('PROCEDURE JOB_PROLONGATION_P2');
    RESULT := job_prolongation_p2(p_pol_id, flg_run_p3);
  END;

  FUNCTION job_prolongation_indexation
  (
    p_pol_id      NUMBER DEFAULT NULL
   ,flg_run_p3    NUMBER DEFAULT 1
   ,p_is_auto_pro NUMBER DEFAULT 1
   ,p_year        NUMBER DEFAULT TO_CHAR(SYSDATE, 'YYYY')
  ) RETURN NUMBER IS
  
    v_skip_flg     NUMBER;
    v_count        NUMBER;
    v_pr_policy_id NUMBER;
  
    v_new_policy_id NUMBER := NULL;
    v_temp_id       NUMBER;
  
    v_pol_type VARCHAR2(50);
  
  BEGIN
  
    v_pr_policy_id := 0;
    dbms_output.put_line('JOB_PROLONGATION_P2 P_POL_ID' || p_pol_id);
  
    FOR cur IN (SELECT ll.brief
                      ,pc.p_cover_id
                      ,pp.POLICY_ID
                      ,pph.POLICY_HEADER_ID
                      ,TO_DATE(TO_CHAR(pph.start_date, 'DD.MM.') || TO_CHAR(pp.start_date, 'YYYY')
                              ,'DD.MM.YYYY') START_DATE
                       /*, CASE WHEN (SELECT COUNT(*)
                                 FROM ins.p_pol_addendum_type ppat,
                                      ins.t_addendum_type tat
                                 WHERE ppat.p_policy_id = pp.policy_id
                                       AND ppat.t_addendum_type_id = tat.t_addendum_type_id
                                       AND tat.brief = 'COL_METHOD_CHANGE') > 0
                            THEN TO_DATE(TO_CHAR(pph.start_date,'DD.MM.')||TO_CHAR(pp.start_date,'YYYY'),'DD.MM.YYYY')
                           ELSE pp.START_DATE
                       END START_DATE*/
                       /*, pp.START_DATE*/
                      ,pp.END_DATE
                      ,pp.PAYMENT_TERM_ID
                      ,pp.PAYMENTOFF_TERM_ID
                  FROM p_pol_header       pph
                      ,p_policy           pp
                      ,as_asset           aa
                      ,p_cover            pc
                      ,t_prod_line_option plo
                      ,t_product_line     pl
                      ,t_lob_line         ll
                 WHERE pp.POL_HEADER_ID = pph.POLICY_HEADER_ID
                   AND pph.POLICY_HEADER_ID = NVL(p_pol_id, pph.POLICY_HEADER_ID)
                   AND pp.VERSION_NUM = (SELECT MAX(a.version_num)
                                           FROM ins.p_policy       a
                                               ,ins.document       d
                                               ,ins.doc_status_ref rf
                                          WHERE a.POL_HEADER_ID = pph.POLICY_HEADER_ID
                                            AND a.policy_id = d.document_id
                                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                                            AND rf.brief != 'CANCEL')
                   AND pp.END_DATE > ADD_MONTHS(pp.START_DATE, 12)
                   AND aa.P_POLICY_ID = pp.POLICY_ID
                   AND pc.AS_ASSET_ID = aa.AS_ASSET_ID
                   AND plo.ID = pc.T_PROD_LINE_OPTION_ID
                   AND pl.ID = plo.PRODUCT_LINE_ID
                   AND ll.T_LOB_LINE_ID = pl.T_LOB_LINE_ID
                   AND pl.IS_AVTOPROLONGATION IN (1, p_is_auto_pro)
                   AND doc.get_last_doc_status_brief(pp.POLICY_ID) IN
                       ('CURRENT', 'ACTIVE', 'STOP', 'PRINTED')
                 ORDER BY pp.policy_id)
    LOOP
    
      BEGIN
        dbms_output.put_line('JOB_PROLONGATION_P2 PC.P_COVER_ID' || cur.p_cover_id);
        SAVEPOINT start_loop;
      
        v_skip_flg := 0;
        v_count    := 0;
      
        --проверка, чтобы не брали один и тот же полис
        --по разным п_коверам
      
        IF v_pr_policy_id = cur.policy_id
        THEN
          v_skip_flg := 1;
        ELSE
          v_pr_policy_id := cur.policy_id;
        END IF;
      
        IF UPPER(cur.brief) = 'WOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
           WHERE cch.P_COVER_ID = cur.p_cover_id
             AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
             AND cd.C_CLAIM_ID = cc.c_claim_id
             AND cc.SEQNO =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID)
             AND doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND dc.ID = cd.T_DAMAGE_CODE_ID
             AND dc.DESCRIPTION = 'Установление застрахованному 1 или 2 группы инвалидности';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        v_count := 0;
      
        IF UPPER(cur.brief) = 'PWOP'
           AND v_skip_flg = 0
        THEN
          SELECT COUNT(1)
            INTO v_count
            FROM c_claim_header cch
                ,c_claim        cc
                ,c_damage       cd
                ,t_damage_code  dc
           WHERE cch.P_COVER_ID = cur.p_cover_id
             AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
             AND cd.C_CLAIM_ID = cc.c_claim_id
             AND cc.SEQNO =
                 (SELECT MAX(a.seqno) FROM c_claim a WHERE a.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID)
             AND doc.get_last_doc_status_brief(cc.C_CLAIM_ID) = 'CLOSE'
             AND dc.ID = cd.T_DAMAGE_CODE_ID
             AND dc.DESCRIPTION = 'Установление застрахованному 1 или 2 группы инвалидности';
          IF v_count > 0
          THEN
            v_skip_flg := 1;
          END IF;
        END IF;
      
        dbms_output.put_line('job_prolongation_p2 v_skip_flg ' || v_skip_flg);
      
        IF v_skip_flg = 0
        THEN
        
          BEGIN
          
            SELECT t_policy_change_type_id
              INTO v_temp_id
              FROM t_policy_change_type
             WHERE brief = 'Технические';
          
            dbms_output.put_line('job_prolongation_p2 PKG_POLICY.NEW_POLICY_VERSION ' ||
                                 cur.policy_id || ' ' || v_temp_id);
            v_new_policy_id := pkg_policy.NEW_POLICY_VERSION(par_policy_id             => cur.policy_id
                                                            ,par_change_id             => v_temp_id
                                                            ,par_policy_change_type_id => v_temp_id);
          
            BEGIN
            
              SELECT t_addendum_type_id
                INTO v_temp_id
                FROM t_addendum_type
               WHERE brief = 'Автопролонгация';
            
              INSERT INTO ven_p_pol_addendum_type
                (p_policy_id, t_addendum_type_id)
              VALUES
                (v_new_policy_id, v_temp_id);
            
              /*exception
              when others then
                raise;*/
            END;
          
            UPDATE p_policy pp
               SET pp.start_date            = to_date(to_char(ADD_MONTHS(cur.start_date, 12), 'dd.mm.') ||
                                                      p_year
                                                     ,'dd.mm.yyyy')
                  ,pp.confirm_date          = to_date(to_char(ADD_MONTHS(cur.start_date, 12), 'dd.mm.') ||
                                                      p_year
                                                     ,'dd.mm.yyyy')
                  ,pp.end_date              = cur.end_date
                  ,pp.NOTICE_DATE_ADDENDUM  = to_date(to_char(ADD_MONTHS(cur.start_date, 12), 'dd.mm.') ||
                                                      p_year
                                                     ,'dd.mm.yyyy')
                  ,pp.CONFIRM_DATE_ADDENDUM = to_date(to_char(ADD_MONTHS(cur.start_date, 12), 'dd.mm.') ||
                                                      p_year
                                                     ,'dd.mm.yyyy')
             WHERE policy_id = v_new_policy_id;
          
            pkg_policy.UPDATE_POLICY_DATES(v_new_policy_id);
          
            -- формирвоание плана графика, только в том случае, если запуск от авто пролонгации
            IF (p_is_auto_pro = 1)
            THEN
              pkg_payment.delete_unpayed_pol(v_new_policy_id);
            
              SELECT pft.brief
                INTO v_pol_type
                FROM ven_p_policy           pol
                    ,ven_t_product          p
                    ,ven_p_pol_header       ph
                    ,ven_t_policy_form_type pft
               WHERE pol.policy_id = v_new_policy_id
                 AND ph.policy_header_id = pol.pol_header_id
                 AND ph.product_id = p.product_id
                 AND p.t_policy_form_type_id = pft.t_policy_form_type_id(+);
            
              IF NVL(v_pol_type, '?') = 'Жизнь'
              THEN
                pkg_payment.POLICY_MAKE_PLANNING(pkg_policy.get_last_version(cur.POLICY_HEADER_ID)
                                                ,cur.PAYMENT_TERM_ID
                                                ,'PAYMENT');
              ELSE
                pkg_payment.POLICY_MAKE_PLANNING(v_new_policy_id, cur.PAYMENT_TERM_ID, 'PAYMENT');
              END IF;
            
            END IF;
          
            /*  exception
            when others then
              raise;*/
          END;
        ELSE
          dbms_output.put_line('JOB_PROLONGATION_P2 V_SKIP != 0');
        
        END IF;
      
        RETURN nvl(v_new_policy_id, -1);
      
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('ERR ' || SQLERRM);
          -- Байтин А.
          -- Не обнулялась и возвращалась со значением, если на самом деле такого документа не было
          v_new_policy_id := NULL;
          ROLLBACK TO SAVEPOINT start_loop;
      END;
    
    END LOOP;
    -- Байтин А.
    -- Раньше функция завершалась без возвращаемого значения, если не заходила в цикл
    raise_application_error(-20001
                           ,'Невозможно создать версию автопролонгация');
  END job_prolongation_indexation;

END Pkg_Policy_11;
/

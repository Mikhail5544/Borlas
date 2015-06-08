CREATE OR REPLACE PACKAGE ins.pkg_indexation IS
  /**
  * Работа с индексацией - создание, редактирование, удаление, изменения статусов
  * @author akatkev
  * @version J
  */

  candeletefromindexation INT := 0; --0 НЕТ, 1 - ДА

  /**
  *  Осуществляет отбор договоров для индексации по месяцу
  *
  * @author Renlife Support
  * @param p_date дата отбора
  */

  PROCEDURE select_ind_policy(p_doc_index ven_policy_index_header%ROWTYPE);

  /**
  *  Создает дополнительные соглашения для индексируемых договоров
  *
  * @author akatkev
  * @param p_doc_id документ - журнал индексации
  */

  PROCEDURE new_index(p_doc_id NUMBER);
  PROCEDURE new_indexjob(p_doc_id NUMBER);
  PROCEDURE createpolicyindex(p_doc_id NUMBER);
  PROCEDURE deletepolicyindex(p_doc_id NUMBER);
  PROCEDURE deletepolicyindexbypolicy(p_doc_id NUMBER);
  PROCEDURE savepolicyindexbypolicy(p_doc_id NUMBER);
  PROCEDURE changestatuspolicy(p_doc_id NUMBER);
  PROCEDURE deleteindexitems(p_doc_id NUMBER);
  PROCEDURE iscandeletefromindexation(p_doc_id NUMBER);

END pkg_indexation;
/
CREATE OR REPLACE PACKAGE BODY ins.pkg_indexation IS

  ------------------------------------------------------------------------
  --Отбирает договора для индексации
  PROCEDURE select_ind_policy(p_doc_index ven_policy_index_header%ROWTYPE) IS
  
    CURSOR c_pol
    (
      vc_date        DATE
     ,vc_polh_id     NUMBER
     ,vc_mailing_on  NUMBER
     ,vc_mailing_off NUMBER
    ) IS(
      SELECT pp.policy_id         policy_id
            ,pp.pol_header_id     p_pol_header_id
            ,aa.as_asset_id       asset_id
            ,aa.contact_id        asset_contact_id
            ,a.as_assured_id      assured_id
            ,a.assured_contact_id assured_contact_id
            ,phh.start_date
            ,phh.fund_id
            ,pp.end_date
            ,pp.payment_term_id
        FROM p_policy     pp
            ,p_pol_header phh
            ,as_asset     aa
            ,as_assured   a
            ,cn_person    cp
       WHERE pp.mailing IN (vc_mailing_on, vc_mailing_off)
         AND phh.policy_id = pp.policy_id
         AND aa.p_policy_id = phh.policy_id
         AND a.as_assured_id = aa.as_asset_id
         AND aa.contact_id = cp.contact_id
         AND cp.date_of_death IS NULL --312748  Доработка журнала индексации
            /*FROM p_policy pp
            JOIN p_pol_header phh
              ON phh.policy_id = pp.policy_id
            JOIN as_asset aa
              ON aa.p_policy_id = phh.policy_id
            JOIN as_assured a
              ON a.as_assured_id = aa.as_asset_id
                WHERE pp.mailing IN (vc_mailing_on, vc_mailing_off)*/ -- переписал без JOIN'ов
            --         and PHH.PRODUCT_ID not in 
            --                (select T.PRODUCT_ID 
            --                        from t_product t 
            --                        where T.BRIEF in ('Life_GF','Family_Dep','GN') )
            /*         and phh.PRODUCT_ID in (
            select T.PRODUCT_ID from T_PRODUCT t where T.BRIEF in (
                      'END', 
                       'CHI', 
                       'PEPR', 
                       'Platinum_LA', 
                       'Baby_LA', 
                       'Family La', 
                       'PRIN_DP',
                       'PRIN',
                       'PEPR_Old',
                       'END_Old',
                       'CHI_Old'
                       ) )*/
            --Каткевич А.Г. Заявка 50019
         AND EXISTS (SELECT NULL
                FROM p_cover            pc
                    ,t_prod_coef        tpc
                    ,t_prod_coef_type   tpt
                    ,t_prod_line_option tplo
               WHERE pc.as_asset_id = aa.as_asset_id
                 AND pc.status_hist_id <> 3
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.product_line_id = tpc.criteria_1
                 AND tpc.t_prod_coef_type_id = tpt.t_prod_coef_type_id
                 AND tpt.brief = 'Indexing_prog')
         AND NOT EXISTS
       (SELECT 1
                FROM p_cover_underwr pcu
                    ,p_cover         pcu
                    ,as_asset        assu
                    ,p_policy        ppund
               WHERE pcu.p_cover_id = pcu.p_cover_underwr_id
                 AND pcu.as_asset_id = assu.as_asset_id
                 AND assu.p_policy_id = ppund.policy_id
                 AND (nvl(s_coef_nm_re, 0) <> 0 OR nvl(k_coef_nm_re, 0) <> 0 OR
                     nvl(s_coef_m_re, 0) <> 0 OR nvl(k_coef_m_re, 0) <> 0)
                 AND ppund.pol_header_id = pp.pol_header_id)
         AND doc.get_doc_status_brief(pkg_policy.get_last_version(phh.policy_header_id), '31.12.2999') NOT IN
             ('PROJECT', 'READY_TO_CANEL')
         AND phh.policy_header_id = vc_polh_id
      --Каткевич А.Г. 31.03.2010 Whats the Heck???????????????? - поменял на активную вресию
      /*         and pp.policy_id in
      (select y.policy_id
         from (select pp.policy_id, pp.start_date, pp.pol_header_id
                 from p_policy pp
                where pp.pol_header_id = vc_polh_id
                  and pp.start_date <=   
                 to_Date(to_char(vc_date,'dd.mm') || '.'|| (extract(year from vc_date) -1 ),'dd.mm.yyyy') 
                order by pp.VERSION_NUM desc, policy_id       desc) y
        where rownum = 1)*/
       );
    v_pol          c_pol%ROWTYPE;
    c_sys_year_ren NUMBER;
    c_ren          NUMBER;
    fl_und         NUMBER;
    fl_cov         NUMBER;
    p_fund         NUMBER;
    p_pt_id        NUMBER;
    p_stat         NUMBER;
    pendd          DATE;
    p_p_t          NUMBER;
    p_date         DATE := p_doc_index.date_index;
    mailing_on     NUMBER;
    mailing_off    NUMBER;
    end_date       DATE;
    start_date     DATE;
    is_date_ok     NUMBER;
  BEGIN
  
    DELETE FROM tmp_index_policy tip;
    --vvv:=0;
  
    IF (p_doc_index.is_take_without_post = 1)
    THEN
      mailing_on  := 1;
      mailing_off := 0;
    ELSE
      mailing_on  := 1;
      mailing_off := 1;
    END IF;
  
    IF (to_char(p_doc_index.date_index, 'mm') = '02' AND to_char(p_doc_index.date_index, 'dd') = '28')
    THEN
      p_date := p_date + 1;
    END IF;
  
    FOR yy IN (SELECT pu.policy_header_id
                 FROM p_pol_header pu
               /*where not exists    
               (select 1  
                   from POLICY_INDEX_ITEM i, 
                       POLICY_INDEX_HEADER h 
                   where I.POLICY_INDEX_HEADER_ID = H.POLICY_INDEX_HEADER_ID
                   and extract(year from H.DATE_INDEX) =  extract(year from p_date)
                   and PU.POLICY_HEADER_ID = I.POLICY_HEADER_ID
               )*/
               )
    LOOP
    
      OPEN c_pol(p_date, yy.policy_header_id, mailing_on, mailing_off);
      LOOP
      
        FETCH c_pol
          INTO v_pol;
        EXIT WHEN c_pol%NOTFOUND;
        is_date_ok := 0;
      
        FOR i IN 2006 .. to_number(to_char(p_date, 'yyyy'))
        LOOP
        
          /**/
        
          start_date := to_date('01.01.' || i, 'dd.mm.yyyy');
          end_date   := to_date(to_char(p_date, 'dd.mm.') || i, 'dd.mm.yyyy');
        
          IF (v_pol.start_date >= start_date AND v_pol.start_date <= end_date)
          THEN
            is_date_ok := 1;
          END IF;
        
          IF (to_char(p_date, 'yyyy') = 2009 AND
             to_char(v_pol.start_date, 'mm') IN ('01', '02', '03', '04', '05'))
          THEN
            is_date_ok := 0;
          END IF;
        
        END LOOP;
      
        dbms_output.put_line('policy_id ' || v_pol.policy_id || ' is_date_ok ' || is_date_ok);
      
        IF (is_date_ok = 0)
        THEN
          GOTO main_fetch;
        END IF;
      
        SELECT COUNT(ds.doc_status_id)
          INTO c_sys_year_ren
          FROM doc_status ds
          JOIN policy_index_item pi
            ON ds.document_id = pi.policy_index_item_id
          JOIN policy_index_header ph
            ON ph.policy_index_header_id = pi.policy_index_header_id
         WHERE extract(YEAR FROM ds.start_date) = extract(YEAR FROM p_date)
           AND pi.policy_id = v_pol.policy_id
           AND ds.doc_status_ref_id IN
               (SELECT dsr.doc_status_ref_id
                  FROM doc_status_ref dsr
                 WHERE (dsr.brief = 'INDEXATING_RENUNCIATION' OR dsr.brief = 'INDEXATING_AGREE' OR
                       dsr.brief = 'INDEXATING'));
        --проверка на отказ от индексации в текущем году , либо уже уже полис прошел индекскацию
        IF c_sys_year_ren = 0
        THEN
        
          SELECT COUNT(1)
            INTO c_ren
            FROM doc_status ds
            JOIN policy_index_item pi
              ON ds.document_id = pi.policy_index_item_id
            JOIN policy_index_header ph
              ON ph.policy_index_header_id = pi.policy_index_header_id
           WHERE v_pol.policy_id = pi.policy_id
             AND ds.doc_status_ref_id =
                 (SELECT dsr.doc_status_ref_id
                    FROM doc_status_ref dsr
                   WHERE dsr.brief = 'INDEXATING_RENUNCIATION');
        
          --проверка на наличие двух отказов от индексации
          IF c_ren <= 2
          THEN
            --проверка на статус полиса
          
            SELECT r.policy_id
                  ,r.end_date
                  ,r.payment_term_id
              INTO p_stat
                  ,pendd
                  ,p_p_t
              FROM (SELECT pti.policy_id
                          ,pti.end_date
                          ,pti.payment_term_id
                      FROM p_policy pti
                     WHERE pti.pol_header_id = v_pol.p_pol_header_id
                     ORDER BY pti.version_num DESC
                             ,pti.start_date  DESC
                             ,pti.policy_id   DESC) r
             WHERE rownum = 1;
          
            IF doc.get_doc_status_brief(p_stat) IN
               ('ACTIVE', 'PRINTED', 'PASSED_TO_AGENT', 'CONCLUDED', 'CURRENT')
            THEN
            
              SELECT f.fund_id INTO p_fund FROM fund f WHERE f.brief = 'RUR';
              --проверка на валюту      
              IF v_pol.fund_id = p_fund
              THEN
                p_pt_id := 0;
                FOR rec IN (SELECT t.id
                              FROM t_payment_terms t
                             WHERE t.description IN ('Ежеквартально'
                                                    ,'Ежегодно'
                                                    ,'Ежемесячно'
                                                    ,'Раз в полгода'))
                LOOP
                  IF rec.id = p_p_t
                  THEN
                    p_pt_id := 1;
                  END IF;
                END LOOP;
                --проверка на условия выплат
                IF p_pt_id = 1
                THEN
                  --проверка на количество лет договора
                  IF CEIL(MONTHS_BETWEEN(last_day(pendd), last_day(v_pol.start_date))) > 72
                  THEN
                    --проверка на количество лет действия
                    IF CEIL(MONTHS_BETWEEN(last_day(pendd), p_date)) > 60
                    THEN
                    
                      SELECT COUNT(t.c)
                        INTO fl_cov
                        FROM (SELECT 1 AS c
                                FROM dual
                               WHERE EXISTS (SELECT '1'
                                        FROM p_policy pp1
                                        JOIN p_pol_header phh
                                          ON phh.policy_header_id = pp1.pol_header_id
                                        JOIN as_asset aa
                                          ON aa.p_policy_id = pp1.policy_id
                                        JOIN p_cover pc
                                          ON pc.as_asset_id = aa.as_asset_id
                                        JOIN t_prod_line_option plo
                                          ON plo.id = pc.t_prod_line_option_id
                                       WHERE pp1.policy_id = v_pol.policy_id
                                         AND plo.description IN
                                             ('Смешанное страхование жизни'
                                             ,'Дожитие с возвратом взносов'
                                             ,'Дожитие с возвратом взносов в случае смерти'
                                             ,'Дожитие с возвратом взносов в случае смерти (Дети)')
                                         AND nvl(pc.s_coef_m, 0) > 75
                                         AND nvl(pc.k_coef_m, 0) > 75)) t;
                    
                      --проверка на андеррайтерские коэффециенты и программы
                      IF fl_cov = 0
                      THEN
                      
                        SELECT nvl((SELECT 1
                                     FROM dual
                                    WHERE EXISTS (SELECT *
                                             FROM p_policy p12
                                             JOIN as_asset aa
                                               ON p12.policy_id = aa.p_policy_id
                                             JOIN p_cover pc2
                                               ON pc2.as_asset_id = aa.as_asset_id
                                             JOIN t_prod_line_option plo2
                                               ON plo2.id = pc2.t_prod_line_option_id
                                             JOIN c_claim_header ch
                                               ON (pc2.p_cover_id = ch.p_cover_id AND
                                                  p12.policy_id = ch.p_policy_id)
                                            WHERE v_pol.policy_id = p12.policy_id
                                              AND plo2.description IN
                                                  ('Освобождение от уплаты страховых взносов'
                                                  ,'Защита страхового взноса')))
                                  ,0)
                          INTO fl_und
                          FROM dual;
                        --проверка на наличие определенных убытков
                        IF fl_und = 0
                        THEN
                          INSERT INTO tmp_index_policy
                            (p_policy_id
                            ,p_policy_header_id
                            ,asset_id
                            ,asset_contact_id
                            ,assured_id
                            ,assured_contact_id
                            ,make_dop
                            ,t_date)
                          VALUES
                            (v_pol.policy_id
                            ,v_pol.p_pol_header_id
                            ,v_pol.asset_id
                            ,v_pol.asset_contact_id
                            ,v_pol.assured_id
                            ,v_pol.assured_contact_id
                            ,1
                            ,p_date);
                          --     vvv:=vvv+1;  
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      
        <<main_fetch>>
        NULL;
      
      END LOOP;
      CLOSE c_pol;
    
    END LOOP;
  
    dbms_output.put_line(' Поиск завершен ');
  
  END;

  PROCEDURE ERROR_INDEX
  (
    str_msg             VARCHAR2
   ,p_policy_header_id  NUMBER
   ,p_policy_index_item NUMBER
  ) IS
  BEGIN
  
    UPDATE ven_policy_index_item v
       SET v.policy_id              = NULL
          ,v.policy_index_header_id = p_policy_header_id
          ,v.log_error_msg          = str_msg
     WHERE v.policy_index_item_id = p_policy_index_item;
  
    doc.set_doc_status(p_policy_index_item
                      ,'ERROR_CALCULATE'
                      ,SYSDATE
                      ,'AUTO'
                      ,'Ошибка в расчете');
  
  END;

  PROCEDURE new_index(p_doc_id NUMBER) IS
    --res    number;
    doc_index                 ven_policy_index_header%ROWTYPE;
    doc_templ_index_header_id NUMBER := doc.templ_id_by_brief('POLICY_INDEX_ITEM');
  
    r              NUMBER := 0;
    v_index_date   DATE;
    v_mailling     PLS_INTEGER;
    vc_mailing_on  PLS_INTEGER;
    vc_mailing_off PLS_INTEGER;
    --l_exists number := 0;
    v_policy_index_id NUMBER := 0;
    --v_date date := sysdate;
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_header v WHERE v.policy_index_header_id = p_doc_id)
    LOOP
      doc_index := r;
    END LOOP;
  
    SELECT v.date_index
          ,v.is_take_without_post
      INTO v_index_date
          ,v_mailling
      FROM policy_index_header v
     WHERE v.policy_index_header_id = p_doc_id;
  
    IF v_mailling = 1
    THEN
      vc_mailing_on  := 1;
      vc_mailing_off := 0;
    ELSE
      vc_mailing_on  := 1;
      vc_mailing_off := 1;
    END IF;
  
    --select_ind_policy(doc_index );
  
    INSERT INTO ven_policy_index_item
      (doc_templ_id, num, reg_date, policy_header_id, policy_id, policy_index_header_id)
      SELECT doc_templ_index_header_id
            ,0
            ,SYSDATE
            ,pp.pol_header_id
            ,NULL
            ,p_doc_id
        FROM ins.p_policy        pp
            ,ins.document        d
            ,ins.doc_status_ref  rf
            ,ins.p_pol_header    ph
            ,ins.fund            f
            ,ins.t_payment_terms pt
       WHERE 1 = 1
         AND ph.policy_id = pp.policy_id
            --AND ph.policy_header_id in (21620772, 35672491, 746692, 20152896)
            --         AND aa.p_policy_id = pp.policy_id
         AND pp.payment_term_id = pt.id
         AND ph.fund_id = f.fund_id
         AND f.brief = 'RUR'
         AND pp.policy_id = d.document_id
         AND d.doc_status_ref_id = rf.doc_status_ref_id
         AND rf.brief IN ('CURRENT', 'ACTIVE', 'PRINTED', 'PASSED_TO_AGENT', 'CONCLUDED')
            /* sergey.ilyushkin 30/07/2012 RT 181006 */
            -- добавил в список исключений статус Отменен
         AND doc.get_doc_status_brief(pkg_policy.get_last_version(ph.policy_header_id)
                                     ,to_date('31.12.2999', 'DD.MM.YYYY')) NOT IN
             ('PROJECT', 'READY_TO_CANCEL' /*, 'CANCEL'*/)
         AND pt.description IN ('Ежеквартально'
                               ,'Ежегодно'
                               ,'Ежемесячно'
                               ,'Раз в полгода')
            /*************************************/
            --Не формируется Индексация, если есть доп соглашения:
            --Уменьшение взноса: в случае, если в годовщину индексации есть версия с уменьшением взноса,
            --индексация в эту годовщину не предлагается. В дальнейшем предлагается.
            --Финансовые каникулы: если после версии "Финансовые каникулы" нет версии "Выход из Фин каникул",
            --договор не индексируется. Если есть версия "Выход из фин каникул", то индексируется.
            --Перевод полиса в оплаченный: в случае, если по договору есть версия с видом изменения "Перевод
            --полиса в оплаченный" - индексация не предлагается. Если после версии "Перевод полиса в оплаченный"
            --есть версия "Восстановление полиса из оплаченного" - договор индексируется.
            /***********************************/
         AND NOT EXISTS
       (SELECT NULL
                FROM ins.p_pol_addendum_type ppat
                    ,ins.t_addendum_type     tat
                    ,ins.p_policy            pol
               WHERE ppat.t_addendum_type_id = tat.t_addendum_type_id
                 AND tat.brief = 'PREMIUM_CHANGE'
                 AND ppat.p_policy_id = pol.policy_id
                 AND pol.pol_header_id = ph.policy_header_id
                 AND pol.start_date =
                     ADD_MONTHS(ph.start_date
                               ,(extract(YEAR FROM v_index_date) - extract(YEAR FROM ph.start_date)) * 12)
              --                              AND pol.start_date = TO_DATE(TO_CHAR(ph.start_date,'DD.MM.')||TO_CHAR(v_index_date,'YYYY'),'DD.MM.YYYY')
              )
         AND (SELECT nvl(SUM((SELECT COUNT(*)
                               FROM ins.p_pol_addendum_type pat
                                   ,ins.t_addendum_type     ta
                                   ,ins.p_policy            pl
                              WHERE pat.t_addendum_type_id = ta.t_addendum_type_id
                                AND ta.brief = 'CLOSE_FIN_WEEKEND'
                                AND pat.p_policy_id = pl.policy_id
                                AND pl.pol_header_id = pol.pol_header_id
                                AND pl.start_date >= pol.start_date))
                        ,1)
                FROM ins.p_pol_addendum_type ppat
                    ,ins.t_addendum_type     tat
                    ,ins.p_policy            pol
               WHERE ppat.t_addendum_type_id = tat.t_addendum_type_id
                 AND tat.brief = 'FIN_WEEK'
                 AND ppat.p_policy_id = pol.policy_id
                 AND pol.pol_header_id = ph.policy_header_id) > 0
         AND (SELECT nvl(SUM((SELECT COUNT(*)
                               FROM ins.p_pol_addendum_type pat
                                   ,ins.t_addendum_type     ta
                                   ,ins.p_policy            pl
                              WHERE pat.t_addendum_type_id = ta.t_addendum_type_id
                                AND ta.brief = 'POLICY_FROM_PAYED'
                                AND pat.p_policy_id = pl.policy_id
                                AND pl.pol_header_id = pol.pol_header_id
                                AND pl.start_date >= pol.start_date))
                        ,1)
                FROM ins.p_pol_addendum_type ppat
                    ,ins.t_addendum_type     tat
                    ,ins.p_policy            pol
               WHERE ppat.t_addendum_type_id = tat.t_addendum_type_id
                 AND tat.brief = 'POLICY_TO_PAYED'
                 AND ppat.p_policy_id = pol.policy_id
                 AND pol.pol_header_id = ph.policy_header_id) > 0
            /*****************************************************************/
         AND NOT EXISTS
       (SELECT NULL
                FROM policy_index_item   pi
                    ,policy_index_header pih
               WHERE 1 = 1
                 AND pi.policy_index_header_id = pih.policy_index_header_id
                 AND pih.date_index BETWEEN trunc(v_index_date, 'YYYY') AND v_index_date
                 AND pi.policy_header_id = ph.policy_header_id
                 AND doc.get_doc_status_brief(pi.policy_index_item_id
                                             ,to_date('31.12.2999', 'DD.MM.YYYY')) IN
                     ('INDEXATING_RENUNCIATION', 'INDEXATING_AGREE', 'INDEXATING'))
            /*********доработка по индексации по письму от Екатерины Ганиной от 21.03.2012**********************/
            /*     AND (SELECT count(1)
             FROM policy_index_item pi,
                  policy_index_header pih 
            WHERE 1=1
              AND pi.policy_index_header_id = pih.policy_index_header_id
              AND pi.policy_header_id = ph.policy_header_id
              AND doc.get_doc_status_brief(pi.policy_index_item_id,'31.12.2999') = 'INDEXATING_RENUNCIATION') < 2*/
            /********доработка по индексации по письму от Екатерины Ганиной от 15.03.2012********************************/
         AND EXISTS (SELECT NULL
                FROM ins.t_contact_pol_role polr
                    ,ins.p_policy_contact   pcnt
                    ,ins.cn_contact_address cac
               WHERE polr.brief = 'Страхователь'
                 AND pcnt.policy_id = pp.policy_id
                 AND pcnt.contact_policy_role_id = polr.id
                 AND pcnt.contact_id = cac.contact_id
                 AND cac.status = 1)
            /******************************/
         AND pp.mailing IN (vc_mailing_on, vc_mailing_off)
         AND EXISTS
       (SELECT NULL
                FROM as_asset           aa
                    ,p_cover            pc
                    ,t_prod_coef        tpc
                    ,t_prod_coef_type   tpt
                    ,t_prod_line_option tplo
               WHERE aa.p_policy_id = pp.policy_id
                 AND pc.as_asset_id = aa.as_asset_id
                 AND pc.status_hist_id <> 3
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.product_line_id = tpc.criteria_1
                 AND tpc.t_prod_coef_type_id = tpt.t_prod_coef_type_id
                 AND tpt.brief = 'Indexing_prog')
         AND ADD_MONTHS(ph.start_date
                       ,(extract(YEAR FROM v_index_date) - extract(YEAR FROM ph.start_date)) * 12) BETWEEN
             SYSDATE AND v_index_date
         AND MONTHS_BETWEEN(ADD_MONTHS(ph.start_date
                                      ,(extract(YEAR FROM v_index_date) -
                                       extract(YEAR FROM ph.start_date)) * 12)
                           ,ph.start_date) >= 12
         AND MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12 >= 6
         AND MONTHS_BETWEEN(pp.end_date
                           ,ADD_MONTHS(ph.start_date
                                      ,(extract(YEAR FROM v_index_date) -
                                       extract(YEAR FROM ph.start_date)) * 12)) / 12 >= 5
         AND EXISTS (SELECT NULL
                FROM as_asset           aa
                    ,p_cover            pc
                    ,t_prod_line_option tplo
               WHERE aa.p_policy_id = pp.policy_id
                 AND pc.as_asset_id = aa.as_asset_id
                 AND pc.status_hist_id <> 3
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.description IN
                     ('Смешанное страхование жизни'
                     ,'Дожитие с возвратом взносов'
                     ,'Дожитие с возвратом взносов в случае смерти'
                     ,'Дожитие с возвратом взносов в случае смерти (Дети)'))
         AND NOT EXISTS
       (SELECT NULL
                FROM as_asset           aa
                    ,p_cover            pc
                    ,t_prod_line_option tplo
                    ,c_claim_header     ch
               WHERE aa.p_policy_id = pp.policy_id
                 AND pc.as_asset_id = aa.as_asset_id
                 AND pc.status_hist_id <> 3
                 AND pc.t_prod_line_option_id = tplo.id
                 AND ch.p_cover_id = pc.p_cover_id
                 AND tplo.description IN ('Освобождение от уплаты страховых взносов'
                                         ,'Защита страхового взноса'))
         AND NOT EXISTS (SELECT 1
                FROM p_cover_underwr pcu
                    ,p_cover         pc
                    ,as_asset        assu
                    ,p_policy        ppu
               WHERE pc.p_cover_id = pcu.p_cover_underwr_id
                 AND pc.as_asset_id = assu.as_asset_id
                 AND assu.p_policy_id = ppu.policy_id
                 AND (nvl(s_coef_nm_re, 0) <> 0 OR nvl(k_coef_nm_re, 0) <> 0 OR
                     nvl(s_coef_m_re, 0) <> 0 OR nvl(k_coef_m_re, 0) <> 0)
                 AND ppu.pol_header_id = pp.pol_header_id)
            --386321 Григорьев Ю. Проверяем, живы ли застрахованный и страхователь
         AND EXISTS
       (SELECT 1
                FROM as_asset   ass
                    ,as_assured aaa
                    ,cn_person  cn
               WHERE ass.p_policy_id = pp.policy_id
                 AND aaa.as_assured_id = ass.as_asset_id
                 AND cn.contact_id = aaa.assured_contact_id
                 AND cn.date_of_death IS NULL)
         AND (SELECT c.date_of_death
                FROM cn_person c
               WHERE c.contact_id(+) = pkg_policy.get_policy_holder_id(pp.policy_id)) IS NULL
            /*1.  Если в плане графике платежей есть ЭПГ в статусе «К оплате» и «Сроком платежа», 
            удаленным от даты формирования Журнала Индексации более чем на 5 календарных дней, договор к Индексации не отбирать.
            364768 Черных М.
            */
         AND NOT EXISTS (SELECT NULL
                FROM p_policy         ac_p
                    ,doc_doc          dd
                    ,ac_payment       ac
                    ,ac_payment_templ act
               WHERE ac_p.pol_header_id = pp.pol_header_id
                 AND ac_p.policy_id = dd.parent_id
                 AND dd.child_id = ac.payment_id
                 AND ac.payment_templ_id = act.payment_templ_id
                 AND act.brief = 'PAYMENT' /*ЭПГ*/
                 AND doc.get_last_doc_status_brief(ac.payment_id) = 'TO_PAY'
                 AND v_index_date - ac.grace_date > 5);
    /**/
  
    FOR i IN (SELECT t.policy_index_item_id
                FROM ven_policy_index_item t
               WHERE t.policy_index_header_id = p_doc_id)
    LOOP
      doc.set_doc_status(i.policy_index_item_id, 'NEW', SYSDATE, 'AUTO', '');
      BEGIN
        doc.set_doc_status(i.policy_index_item_id, 'INDEXATING', SYSDATE + 0.00001, 'AUTO');
      EXCEPTION
        WHEN OTHERS THEN
          doc.set_doc_status(i.policy_index_item_id
                            ,'ERROR_CALCULATE'
                            ,SYSDATE + 0.00001
                            ,'AUTO'
                            ,SQLERRM);
      END;
    END LOOP;
  
    doc.set_doc_status(p_doc_id
                      ,'INDEXATING'
                      ,doc.get_last_doc_status_date(p_doc_id) + 10 / 24 / 3600
                      ,'AUTO'
                      ,'');
  
  EXCEPTION
    WHEN OTHERS THEN
      doc.set_doc_status(p_doc_id
                        ,'ERROR_CALCULATE'
                        ,SYSDATE + 1 / 24 / 3600
                        ,'AUTO'
                        ,'Ошибка:' || v_policy_index_id || '  ' || SQLERRM);
  END new_index;

  PROCEDURE new_indexjob(p_doc_id NUMBER) IS
  
    --job_x number;
    sql_exec VARCHAR2(400);
  
  BEGIN
  
    sql_exec := 'begin UPDATE ven_POLICY_INDEX_HEADER ip 
                          SET ip.note = null
                        WHERE ip.policy_index_header_id = ' || p_doc_id || ';' ||
                'PKG_INDEXATION.new_index (' || p_doc_id || '); commit; end;';
  
    UPDATE ven_policy_index_header ip
       SET ip.note = 'В очереди на расчет ' || to_char(SYSDATE, 'DD.MM.YYYY HH24:Mi:SS')
     WHERE ip.policy_index_header_id = p_doc_id;
  
    pkg_scheduler.run_scheduled('INDEX_CALC', sql_exec, 0);
    /*SYS.DBMS_JOB.SUBMIT(job       => job_x,
    what      => sql_exec,
    next_date => sysdate,
    no_parse  => FALSE);*/
  END;

  --Удаление версии полиса по элементу в журнале    
  PROCEDURE deletepolicyindex(p_doc_id NUMBER) IS
  
    policy_r       ven_policy_index_item%ROWTYPE;
    policy_prev_id NUMBER;
  
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_item v WHERE v.policy_index_item_id = p_doc_id)
    LOOP
      policy_r := r;
    END LOOP;
  
    IF (policy_r.policy_id IS NOT NULL)
    THEN
    
      /* */
      FOR n IN (SELECT policy_id
                  FROM (SELECT pp.policy_id
                          FROM ven_p_policy pp
                         WHERE policy_r.policy_header_id = pp.pol_header_id
                         ORDER BY pp.policy_id DESC) a
                 WHERE rownum <= 2)
      LOOP
        policy_prev_id := n.policy_id;
      END LOOP;
    
      /**/
    
      UPDATE doc_doc dd
         SET dd.parent_id = policy_prev_id
       WHERE dd.child_id IN (SELECT a.payment_id
                               FROM ac_payment       a
                                   ,ac_payment_templ apt
                                   ,doc_doc          dd2
                              WHERE apt.brief = 'PAYMENT'
                                AND apt.payment_templ_id = a.payment_templ_id
                                AND dd2.parent_id = policy_r.policy_id
                                AND dd2.child_id = a.payment_id);
    
      /**/
    
      /*был вызов удаления через журнал*/
      UPDATE ven_policy_index_item v SET v.policy_id = NULL WHERE v.policy_index_item_id = p_doc_id;
    
      candeletefromindexation := 1;
      doc.set_doc_status(policy_r.policy_id, 'CANCEL');
    
      /* план графиг*/
      --pkg_payment.Set_Policy_New_Renlife(policy_prev_id);
      /**/
    
      candeletefromindexation := 0;
    
    ELSE
      /*был вызов удаления через полис*/
    
      NULL;
    END IF;
  
  END;

  --Удаление информации из журнала индексации
  PROCEDURE deletepolicyindexbypolicy(p_doc_id NUMBER) IS
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_item p WHERE p.policy_id = p_doc_id)
    LOOP
    
      UPDATE policy_index_item p
         SET p.policy_id = NULL
       WHERE p.policy_index_item_id = r.policy_index_item_id;
      candeletefromindexation := 1;
      doc.set_doc_status(r.policy_index_item_id, 'CANCEL');
      candeletefromindexation := 0;
    
    END LOOP;
  
  END deletepolicyindexbypolicy;

  --Сохранение информации в журнал индексации
  PROCEDURE savepolicyindexbypolicy(p_doc_id NUMBER) IS
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_item p WHERE p.policy_id = p_doc_id)
    LOOP
      -- Байтин А.
      -- Добавлен if, иначе начиналась бесконечная рекурсия
      IF doc.get_doc_status_brief(r.policy_index_item_id) != 'INDEXATING_AGREE'
      THEN
        doc.set_doc_status(r.policy_index_item_id, 'INDEXATING_AGREE');
      END IF;
    END LOOP;
  
  END savepolicyindexbypolicy;

  --Индексация элемента журнала
  PROCEDURE createpolicyindex(p_doc_id NUMBER) IS
    res                   NUMBER;
    policy_item           ven_policy_index_item%ROWTYPE;
    v_policy_index_header ven_policy_index_header%ROWTYPE;
    is_err                NUMBER := 0;
    str_msg               VARCHAR2(500);
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_item v WHERE v.policy_index_item_id = p_doc_id)
    LOOP
      policy_item := r;
    END LOOP;
  
    FOR r IN (SELECT *
                FROM ven_policy_index_header v
               WHERE v.policy_index_header_id = policy_item.policy_index_header_id)
    LOOP
      v_policy_index_header := r;
    END LOOP;
  
    BEGIN
      SAVEPOINT create_index;
      res := pkg_policy_program_index_11.create_policy_index(policy_item.policy_header_id
                                                            ,to_char(v_policy_index_header.date_index
                                                                    ,'YYYY'));
    EXCEPTION
      WHEN OTHERS THEN
        str_msg := SQLERRM;
        is_err  := 1;
        ROLLBACK TO create_index;
    END;
  
    IF (is_err = 1)
    THEN
    
      UPDATE ven_policy_index_item v
         SET v.policy_id     = NULL
            ,v.log_error_msg = str_msg
       WHERE v.policy_index_item_id = policy_item.policy_index_item_id;
    
      doc.set_doc_status(policy_item.policy_index_item_id
                        ,'ERROR_CALCULATE'
                        ,SYSDATE + 10 / 24 / 3600
                        ,'AUTO'
                        ,'Ошибка в расчете');
    
    ELSE
      UPDATE ven_policy_index_item v
         SET v.policy_id     = res
            ,v.log_error_msg = NULL
       WHERE v.policy_index_item_id = p_doc_id;
    
      -- DOC.SET_DOC_STATUS(policy_item.POLICY_INDEX_ITEM_ID,'INDEXATING',SYSDATE,'MANUAL','');
    
    END IF;
  
  END createpolicyindex;

  --Изменение статуса полиса на действующий
  PROCEDURE changestatuspolicy(p_doc_id NUMBER) IS
    policy_index_row  ven_policy_index_item%ROWTYPE;
    rec_p_policy      p_policy%ROWTYPE;
    rec_prev_p_policy p_policy%ROWTYPE;
    l_doc_prev_status VARCHAR2(50);
    v_date            DATE := SYSDATE;
    l_status_date     DATE;
  BEGIN
  
    FOR r IN (SELECT * FROM ven_policy_index_item v WHERE v.policy_index_item_id = p_doc_id)
    LOOP
      policy_index_row := r;
    END LOOP;
  
    FOR r IN (SELECT * FROM p_policy v WHERE v.policy_id = policy_index_row.policy_id)
    LOOP
      rec_p_policy := r;
    END LOOP;
  
    FOR rec IN (SELECT *
                  FROM ((SELECT pp.*
                           FROM ins.p_policy       pp
                               ,ins.document       d
                               ,ins.doc_status_ref rf
                          WHERE pp.pol_header_id = rec_p_policy.pol_header_id
                            AND pp.policy_id <> rec_p_policy.policy_id
                            AND pp.policy_id = d.document_id
                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                            AND rf.brief != 'CANCEL'
                          ORDER BY pp.policy_id DESC))
                 WHERE rownum = 1)
    LOOP
      rec_prev_p_policy := rec;
    END LOOP;
  
    l_doc_prev_status := doc.get_doc_status_brief(rec_prev_p_policy.policy_id);
    dbms_output.put_line('ChangeStatusPolicy l_doc_prev_status ' || l_doc_prev_status || ' v_date ' ||
                         to_char(v_date, 'dd.mm.yyyy hh24:mi:ss'));
  
    doc.set_doc_status(policy_index_row.policy_id, 'NEW', v_date);
  
    IF (l_doc_prev_status = 'ACTIVE')
    THEN
      l_status_date := v_date + ((10 * 2) / 24 / 3600);
      dbms_output.put_line('ChangeStatusPolicy l_status_date ' ||
                           to_char(l_status_date, 'dd.mm.yyyy hh24:mi:ss'));
      doc.set_doc_status(rec_p_policy.policy_id, l_doc_prev_status, l_status_date);
    END IF;
  
    IF (l_doc_prev_status = 'CURRENT')
    THEN
      l_status_date := v_date + ((10 * 2) / 24 / 3600);
      dbms_output.put_line('ChangeStatusPolicy l_status_date ' ||
                           to_char(l_status_date, 'dd.mm.yyyy hh24:mi:ss'));
      doc.set_doc_status(rec_p_policy.policy_id, l_doc_prev_status, l_status_date);
    END IF;
  
    IF (l_doc_prev_status = 'PRINTED')
    THEN
      l_status_date := v_date + ((10 * 2) / 24 / 3600);
      dbms_output.put_line('ChangeStatusPolicy l_status_date ' ||
                           to_char(l_status_date, 'dd.mm.yyyy hh24:mi:ss'));
      doc.set_doc_status(rec_p_policy.policy_id, 'CURRENT', l_status_date);
      l_status_date := v_date + ((10 * 3) / 24 / 3600);
      dbms_output.put_line('ChangeStatusPolicy l_status_date ' ||
                           to_char(l_status_date, 'dd.mm.yyyy hh24:mi:ss'));
      doc.set_doc_status(rec_p_policy.policy_id, l_doc_prev_status, l_status_date);
    END IF;
  
    UPDATE ins.ven_p_policy pp SET pp.mailing = 1 WHERE pp.policy_id = rec_p_policy.policy_id;
  
  END;

  --Удаление версии полиса по элементу в журнале
  -- Отмена журнала индексации - процедура
  PROCEDURE deleteindexitems(p_doc_id NUMBER) IS
    v_err VARCHAR2(1000);
  BEGIN
  
    FOR r IN (SELECT *
                FROM ven_policy_index_item v
               WHERE v.policy_index_header_id = p_doc_id
                 AND doc.get_doc_status_brief(v.policy_index_item_id) <> 'ERROR_CALCULATE'
                 AND doc.get_doc_status_brief(v.policy_index_item_id) <> 'INDEXATING_AGREE'
                 AND doc.get_doc_status_brief(v.policy_index_item_id) <> 'INDEXATING_RENUNCIATION'
                 AND doc.get_doc_status_brief(v.policy_index_item_id) <> 'CANCEL')
    LOOP
    
      BEGIN
      
        doc.set_doc_status(r.policy_index_item_id, 'CANCEL');
      
      EXCEPTION
        WHEN OTHERS THEN
          v_err := SQLERRM;
          UPDATE ven_policy_index_item v
             SET v.note = 'Ошибка при отмене индексации. ' || v_err
           WHERE v.policy_index_item_id = r.policy_index_item_id;
        
      END;
    
    END LOOP;
  
  END;

  PROCEDURE iscandeletefromindexation(p_doc_id NUMBER) IS
  BEGIN
  
    IF (candeletefromindexation = 0)
    THEN
      raise_application_error(-20000
                             ,'Вы не можете удалить договор из версии индексации из этого места.');
      RETURN;
    END IF;
  
  END;

END pkg_indexation;
/

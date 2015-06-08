CREATE OR REPLACE PACKAGE PKG_DISCOVERER IS

  -- Author  : SKUSHENKO
  -- Created : 10.04.2008 15:57:15
  -- Purpose : Заполнение временных таблиц для отчетов Discoverer

  /**
  *  Реализация запроса к сводной таблице из функции
  *  Для отчета bso_traffic_hist (РенесанЖ)
  *  @autor Kushenko S.
  *  @modified Sizon S.
  *  @param p_start_date - дата начала отчетного периода,
  *          p_end_date - дата окончания отчетного периода
  *  @return - возврат сводной таблицы tbl_bso_in_out
  */
  PROCEDURE get_pivot_bso_table
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_session_id NUMBER
  );

END PKG_DISCOVERER;
/
CREATE OR REPLACE PACKAGE BODY PKG_DISCOVERER IS

  FUNCTION get_bso_rest_on_date
  (
    p_date        DATE
   ,p_bso_type_id NUMBER
  ) RETURN NUMBER IS
    buf NUMBER;
  BEGIN
  
    SELECT COUNT(*)
      INTO buf
      FROM bso_hist      his
          ,bso           b
          ,bso_hist_type ht
          ,bso_series    bs
     WHERE his.bso_id = b.bso_id
       AND bs.bso_series_id = b.bso_series_id
       AND bs.bso_type_id = p_bso_type_id
       AND ht.bso_hist_type_id = his.hist_type_id
       AND his.num =
           (SELECT MAX(his2.num)
              FROM bso_hist      his2
                  ,bso_hist_type ht2
             WHERE his2.hist_date < p_date
               AND his2.bso_id = his.bso_id
               AND his2.hist_type_id = ht2.bso_hist_type_id
               AND ht2.brief IN ('НеВыдан', 'Выдан', 'Зарезервирован'));
    RETURN buf;
  END;

  PROCEDURE get_pivot_bso_table
  (
    p_start_date DATE
   ,p_end_date   DATE
   ,p_session_id NUMBER
  )
  
   IS
  
    TYPE t_bso_in_out IS RECORD(
       N              NUMBER(10)
      ,NN             NUMBER(6)
      ,BSO_TYPE       VARCHAR2(150)
      ,IN_QUANTITY    NUMBER(6)
      ,IN_NUM_START   VARCHAR2(150)
      ,IN_NUM_END     VARCHAR2(150)
      ,IN_REG_DATE    DATE
      ,OUT_QUANTITY   NUMBER(6)
      ,OUT_NUM_START  VARCHAR2(150)
      ,OUT_NUM_END    VARCHAR2(150)
      ,OUT_REG_DATE   DATE
      ,OUT_BSO_STATUS VARCHAR2(150)
      ,REST_BEGIN     NUMBER(8)
      ,REST_END       NUMBER(8)
      ,REST_CHANGE    NUMBER(8)
      ,SESSION_ID     NUMBER
      ,GEN_DATE       DATE);
    l_rec         t_bso_in_out;
    l_rec_tot_tmp t_bso_in_out;
    CURSOR l_cur
    (
      v_start_date DATE
     ,v_end_date   DATE
    ) IS
      SELECT DISTINCT t.QUANTITY_IN
                     ,t.NUM_START_IN
                     ,t.NUM_END_IN
                     ,t.REG_DATE_IN
                     ,t.QUANTITY_OUT
                     ,t.NUM_START_OUT
                     ,t.NUM_END_OUT
                     ,t.REG_DATE_OUT
                     ,t.BSO_STATUS
                     ,t.tot_cnt_IN
                     ,t.tot_cnt_OUT
                     ,t.bso_type_id
                     ,v.NAME
                     ,MAX(NVL(tot_cnt_out, 0) - NVL(tot_cnt_in, 0)) OVER(PARTITION BY t.bso_type_id) AS sgn
        FROM (SELECT ROWNUM
                    ,t1.QUANTITY QUANTITY_IN
                    ,t1.NUM_START NUM_START_IN
                    ,t1.NUM_END NUM_END_IN
                    ,t1.REG_DATE REG_DATE_IN
                    ,t2.QUANTITY QUANTITY_OUT
                    ,t2.NUM_START NUM_START_OUT
                    ,t2.NUM_END NUM_END_OUT
                    ,t2.REG_DATE REG_DATE_OUT
                    ,t2.BSO_STATUS
                    ,t1.tot_cnt tot_cnt_IN
                    ,t2.tot_cnt tot_cnt_OUT
                    ,NVL(t1.bso_type_id, t2.bso_type_id) bso_type_id
                FROM (SELECT ROWNUM AS nn
                            ,bd.reg_date AS REG_DATE
                            ,bdc.num_start AS NUM_START
                            ,NVL(bdc.num_end, bdc.num_start) AS NUM_END
                            ,DECODE(bdc.num_end
                                   ,NULL
                                   ,1
                                   ,TO_NUMBER(bdc.num_end) - TO_NUMBER(bdc.num_start) + 1) AS QUANTITY
                            ,COUNT(*) OVER(PARTITION BY bt.bso_type_id) AS tot_cnt
                            ,bt.bso_type_id AS bso_type_id
                        FROM ven_bso_document  bd
                            ,ven_doc_templ     dt
                            ,ven_bso_doc_cont  bdc
                            ,ven_bso_type      bt
                            ,ven_bso_series    bs
                            ,ven_bso_hist_type bht
                       WHERE bs.bso_type_id = bt.bso_type_id
                         AND bdc.bso_series_id = bs.bso_series_id
                         AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                         AND bdc.bso_document_id = bd.bso_document_id
                         AND dt.doc_templ_id = bd.doc_templ_id
                         AND dt.brief = 'НакладнаяБСО'
                         AND bd.reg_date BETWEEN v_start_date AND v_end_date) t1
                    ,(SELECT ROWNUM AS nn
                            ,QUANTITY
                            ,NUM_START
                            ,NUM_END
                            ,REG_DATE
                            ,BSO_STATUS
                            ,COUNT(*) OVER(PARTITION BY bso_type_id) AS tot_cnt
                            ,bso_type_id
                        FROM (SELECT COUNT(*) AS QUANTITY
                                    ,MIN(a) AS NUM_START
                                    ,MAX(a) AS NUM_END
                                    ,MIN(hist_date) AS REG_DATE
                                    ,MIN(status) AS BSO_STATUS
                                    ,MIN(bso_type_id) AS bso_type_id
                                FROM (SELECT b.num AS a
                                            ,TRUNC(his.hist_date) AS hist_date
                                            ,ht.NAME AS status
                                            ,bs.bso_type_id AS bso_type_id
                                        FROM bso_hist      his
                                            ,bso           b
                                            ,bso_hist_type ht
                                            ,bso_series    bs
                                       WHERE his.bso_id = b.bso_id
                                         AND bs.bso_series_id = b.bso_series_id
                                         AND ht.bso_hist_type_id = his.hist_type_id
                                         AND his.num =
                                             (SELECT MAX(his2.num)
                                                FROM bso_hist      his2
                                                    ,bso_hist_type ht2
                                               WHERE his2.hist_date BETWEEN v_start_date AND v_end_date
                                                 AND his2.bso_id = his.bso_id
                                                 AND his2.hist_type_id = ht2.bso_hist_type_id
                                                 AND ht2.brief IN ('Использован'
                                                                  ,'Испорчен'
                                                                  ,'Утерян'
                                                                  ,'Устарел'
                                                                  ,'Списан'))
                                       ORDER BY TRUNC(his.hist_date)
                                               ,ht.brief
                                               ,TO_NUMBER(b.num))
                               GROUP BY (TO_NUMBER(a) - ROWNUM)
                               ORDER BY REG_DATE
                                       ,BSO_STATUS
                                       ,NUM_START)) t2
               WHERE t1.nn(+) = t2.nn
                 AND t1.bso_type_id(+) = t2.bso_type_id
              UNION ALL
              SELECT ROWNUM
                    ,t1.QUANTITY QUANTITY_IN
                    ,t1.NUM_START NUM_START_IN
                    ,t1.NUM_END NUM_END_IN
                    ,t1.REG_DATE REG_DATE_IN
                    ,t2.QUANTITY QUANTITY_OUT
                    ,t2.NUM_START NUM_START_OUT
                    ,t2.NUM_END NUM_END_OUT
                    ,t2.REG_DATE REG_DATE_OUT
                    ,t2.BSO_STATUS
                    ,t1.tot_cnt tot_cnt_IN
                    ,t2.tot_cnt tot_cnt_OUT
                    ,NVL(t1.bso_type_id, t2.bso_type_id) bso_type_id
                FROM (SELECT ROWNUM AS nn
                            ,bd.reg_date AS REG_DATE
                            ,bdc.num_start AS NUM_START
                            ,NVL(bdc.num_end, bdc.num_start) AS NUM_END
                            ,DECODE(bdc.num_end
                                   ,NULL
                                   ,1
                                   ,TO_NUMBER(bdc.num_end) - TO_NUMBER(bdc.num_start) + 1) AS QUANTITY
                            ,COUNT(*) OVER(PARTITION BY bt.bso_type_id) AS tot_cnt
                            ,bt.bso_type_id AS bso_type_id
                        FROM ven_bso_document  bd
                            ,ven_doc_templ     dt
                            ,ven_bso_doc_cont  bdc
                            ,ven_bso_type      bt
                            ,ven_bso_series    bs
                            ,ven_bso_hist_type bht
                       WHERE bs.bso_type_id = bt.bso_type_id
                         AND bdc.bso_series_id = bs.bso_series_id
                         AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                         AND bdc.bso_document_id = bd.bso_document_id
                         AND dt.doc_templ_id = bd.doc_templ_id
                         AND dt.brief = 'НакладнаяБСО'
                         AND bd.reg_date BETWEEN v_start_date AND v_end_date) t1
                    ,(SELECT ROWNUM AS nn
                            ,QUANTITY
                            ,NUM_START
                            ,NUM_END
                            ,REG_DATE
                            ,BSO_STATUS
                            ,COUNT(*) OVER(PARTITION BY bso_type_id) AS tot_cnt
                            ,bso_type_id
                        FROM (SELECT COUNT(*) AS QUANTITY
                                    ,MIN(a) AS NUM_START
                                    ,MAX(a) AS NUM_END
                                    ,MIN(hist_date) AS REG_DATE
                                    ,MIN(status) AS BSO_STATUS
                                    ,MIN(bso_type_id) AS bso_type_id
                                FROM (SELECT b.num AS a
                                            ,TRUNC(his.hist_date) AS hist_date
                                            ,ht.NAME AS status
                                            ,bs.bso_type_id AS bso_type_id
                                        FROM bso_hist      his
                                            ,bso           b
                                            ,bso_hist_type ht
                                            ,bso_series    bs
                                       WHERE his.bso_id = b.bso_id
                                         AND bs.bso_series_id = b.bso_series_id
                                         AND ht.bso_hist_type_id = his.hist_type_id
                                         AND his.num =
                                             (SELECT MAX(his2.num)
                                                FROM bso_hist      his2
                                                    ,bso_hist_type ht2
                                               WHERE his2.hist_date BETWEEN v_start_date AND v_end_date
                                                 AND his2.bso_id = his.bso_id
                                                 AND his2.hist_type_id = ht2.bso_hist_type_id
                                                 AND ht2.brief IN ('Использован'
                                                                  ,'Испорчен'
                                                                  ,'Утерян'
                                                                  ,'Устарел'
                                                                  ,'Списан'))
                                       ORDER BY TRUNC(his.hist_date)
                                               ,ht.brief
                                               ,TO_NUMBER(b.num))
                               GROUP BY (TO_NUMBER(a) - ROWNUM)
                               ORDER BY REG_DATE
                                       ,BSO_STATUS
                                       ,NUM_START)) t2
               WHERE t1.nn = t2.nn(+)
                 AND t1.bso_type_id = t2.bso_type_id(+)) t
            ,ven_bso_type v
       WHERE t.bso_type_id = v.bso_type_id
       ORDER BY v.NAME
               ,nvl2(t.REG_DATE_IN, 2, DECODE(SIGN(sgn), -1, 1, 0)) +
                nvl2(t.REG_DATE_OUT, 2, DECODE(SIGN(sgn), 1, 1, 0)) DESC
               ,t.REG_DATE_OUT
               ,t.REG_DATE_IN
               ,t.NUM_START_OUT
               ,t.NUM_START_IN;
  
    l_quantity_in  NUMBER(8);
    l_quantity_out NUMBER(8);
    l_tmp_N        NUMBER(8);
    l_tmp_NN       NUMBER(8);
    l_tmp_num      NUMBER(8);
    l_tmp_in       NUMBER(8);
    l_tmp_out      NUMBER(8);
    l_tmp_id       NUMBER(8);
    l_pred_id      NUMBER(8);
    l_tmp_name     VARCHAR2(150);
    l_pred_name    VARCHAR2(150);
    l_tmp_sgn      NUMBER(8);
  
    /* счетчики финального ИТОГО */
    l_fin_RB NUMBER(8);
    l_fin_IQ NUMBER(8);
    l_fin_OQ NUMBER(8);
    l_fin_RE NUMBER(8);
    l_fin_RC NUMBER(8);
  
  BEGIN
    /* Чистим "временную" таблицу, удаляя данные текущей сессии и
    данные суточной давности*/
    DELETE FROM ins_dwh.bso_pivot_table_tmp b
     WHERE (SYSDATE - b.gen_date) > 1
        OR b.SESSION_ID = p_session_id;
    /* Инициализация счетчиков */
    l_tmp_N                  := 0;
    l_tmp_NN                 := 1; -- первый стартовый номер в группе 
    l_fin_RB                 := 0;
    l_fin_IQ                 := 0;
    l_fin_OQ                 := 0;
    l_fin_RE                 := 0;
    l_fin_RC                 := 0;
    l_rec.SESSION_ID         := p_session_id;
    l_rec.GEN_DATE           := SYSDATE;
    l_rec_tot_tmp.SESSION_ID := p_session_id;
    l_rec_tot_tmp.GEN_DATE   := SYSDATE;
    l_pred_id                := 0; -- несуществующий тип бланка на входе в цикл 
  
    OPEN l_cur(p_start_date, p_end_date);
    LOOP
    
      /* Остатки */
      l_rec.REST_BEGIN  := NULL;
      l_rec.REST_END    := NULL;
      l_rec.REST_CHANGE := NULL;
      l_tmp_N           := l_tmp_N + 1;
    
      FETCH l_cur
        INTO --l_rec.NN,
             l_rec.IN_QUANTITY
            ,l_rec.IN_NUM_START
            ,l_rec.IN_NUM_END
            ,l_rec.IN_REG_DATE
            ,l_rec.OUT_QUANTITY
            ,l_rec.OUT_NUM_START
            ,l_rec.OUT_NUM_END
            ,l_rec.OUT_REG_DATE
            ,l_rec.OUT_BSO_STATUS
            ,l_tmp_in
            ,l_tmp_out
            ,l_tmp_id
            ,l_tmp_name
            ,l_tmp_sgn;
    
      EXIT WHEN l_cur%NOTFOUND;
    
      l_rec.BSO_TYPE := NULL; /* Чтобы вид бланка выводился только на первой строке */
      IF l_tmp_id <> l_pred_id
      THEN
        IF l_pred_id > 0
        THEN
          /* меняется вид бланка - выводим промежуточный итог */
          -- Подсчет промежуточных итогов 
          l_rec_tot_tmp.N              := l_tmp_N;
          l_tmp_N                      := l_tmp_N + 1;
          l_tmp_NN                     := l_tmp_NN + 1;
          l_rec_tot_tmp.NN             := l_tmp_NN;
          l_rec_tot_tmp.BSO_TYPE       := 'ИТОГО по ' || l_pred_name;
          l_rec_tot_tmp.REST_BEGIN     := get_bso_rest_on_date(p_start_date, l_pred_id);
          l_rec_tot_tmp.IN_QUANTITY    := l_quantity_in;
          l_rec_tot_tmp.IN_NUM_START   := NULL;
          l_rec_tot_tmp.IN_NUM_END     := NULL;
          l_rec_tot_tmp.IN_REG_DATE    := NULL;
          l_rec_tot_tmp.OUT_QUANTITY   := l_quantity_out;
          l_rec_tot_tmp.OUT_NUM_START  := NULL;
          l_rec_tot_tmp.OUT_NUM_END    := NULL;
          l_rec_tot_tmp.OUT_REG_DATE   := NULL;
          l_rec_tot_tmp.REST_END       := NVL(l_rec_tot_tmp.REST_BEGIN, 0) + l_quantity_in -
                                          l_quantity_out;
          l_rec_tot_tmp.OUT_BSO_STATUS := NULL;
          l_rec_tot_tmp.REST_CHANGE    := NVL(l_rec_tot_tmp.REST_END, 0) -
                                          NVL(l_rec_tot_tmp.REST_BEGIN, 0);
        
          INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec_tot_tmp;
        
          IF (l_quantity_in + l_quantity_out) > 0
          THEN
            l_fin_RB := l_fin_RB + NVL(l_rec_tot_tmp.REST_BEGIN, 0);
            l_fin_IQ := l_fin_IQ + NVL(l_rec_tot_tmp.IN_QUANTITY, 0);
            l_fin_OQ := l_fin_OQ + NVL(l_rec_tot_tmp.OUT_QUANTITY, 0);
            l_fin_RE := l_fin_RE + NVL(l_rec_tot_tmp.REST_END, 0);
            l_fin_RC := l_fin_RC + NVL(l_rec_tot_tmp.REST_CHANGE, 0);
          END IF;
        END IF;
        l_rec.BSO_TYPE := l_tmp_name;
        l_quantity_in  := NVL(l_tmp_in, 0);
        l_quantity_out := NVL(l_tmp_out, 0);
        l_tmp_NN       := 1;
        l_pred_name    := l_tmp_name;
      ELSE
        l_tmp_NN := l_tmp_NN + 1;
      END IF;
      l_pred_id := l_tmp_id;
      l_rec.NN  := l_tmp_NN;
    
      l_rec.N := l_tmp_N; /*Глобальный счетчик по всем записям отчета*/
    
      INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
    
      l_quantity_in  := l_quantity_in + NVL(l_rec.IN_QUANTITY, 0); /* Итого кол-во по видам бланка*/
      l_quantity_out := l_quantity_out + NVL(l_rec.OUT_QUANTITY, 0);
    
    END LOOP; -- Конец цикла по BSO_TYPE  (видам бланков) 
    CLOSE l_cur;
    --последний промежуточный итог 
    IF l_pred_id > 0
    THEN
      l_rec_tot_tmp.N              := l_tmp_N;
      l_tmp_N                      := l_tmp_N + 1;
      l_rec_tot_tmp.NN             := l_tmp_NN + 1;
      l_rec_tot_tmp.BSO_TYPE       := 'ИТОГО по ' || l_pred_name;
      l_rec_tot_tmp.REST_BEGIN     := get_bso_rest_on_date(p_start_date, l_pred_id);
      l_rec_tot_tmp.IN_QUANTITY    := l_quantity_in;
      l_rec_tot_tmp.IN_NUM_START   := NULL;
      l_rec_tot_tmp.IN_NUM_END     := NULL;
      l_rec_tot_tmp.IN_REG_DATE    := NULL;
      l_rec_tot_tmp.OUT_QUANTITY   := l_quantity_out;
      l_rec_tot_tmp.OUT_NUM_START  := NULL;
      l_rec_tot_tmp.OUT_NUM_END    := NULL;
      l_rec_tot_tmp.OUT_REG_DATE   := NULL;
      l_rec_tot_tmp.REST_END       := NVL(l_rec_tot_tmp.REST_BEGIN, 0) + l_quantity_in -
                                      l_quantity_out;
      l_rec_tot_tmp.OUT_BSO_STATUS := NULL;
      l_rec_tot_tmp.REST_CHANGE    := NVL(l_rec_tot_tmp.REST_END, 0) -
                                      NVL(l_rec_tot_tmp.REST_BEGIN, 0);
    
      INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec_tot_tmp;
    
      IF (l_quantity_in + l_quantity_out) > 0
      THEN
        l_fin_RB := l_fin_RB + NVL(l_rec_tot_tmp.REST_BEGIN, 0);
        l_fin_IQ := l_fin_IQ + NVL(l_rec_tot_tmp.IN_QUANTITY, 0);
        l_fin_OQ := l_fin_OQ + NVL(l_rec_tot_tmp.OUT_QUANTITY, 0);
        l_fin_RE := l_fin_RE + NVL(l_rec_tot_tmp.REST_END, 0);
        l_fin_RC := l_fin_RC + NVL(l_rec_tot_tmp.REST_CHANGE, 0);
      END IF;
    END IF;
  
    -- Подсчет финального итога
    l_rec.N            := l_tmp_N;
    l_rec.NN           := NULL;
    l_rec.BSO_TYPE     := 'ИТОГО все бланки';
    l_rec.REST_BEGIN   := l_fin_RB;
    l_rec.IN_QUANTITY  := l_fin_IQ;
    l_rec.OUT_QUANTITY := l_fin_OQ;
    l_rec.REST_END     := l_fin_RE;
    l_rec.REST_CHANGE  := l_fin_RC;
  
    l_rec.IN_NUM_START   := NULL;
    l_rec.IN_NUM_END     := NULL;
    l_rec.IN_REG_DATE    := NULL;
    l_rec.OUT_NUM_START  := NULL;
    l_rec.OUT_NUM_END    := NULL;
    l_rec.OUT_REG_DATE   := NULL;
    l_rec.OUT_BSO_STATUS := NULL;
  
    INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
  
  END;

END PKG_DISCOVERER;
/

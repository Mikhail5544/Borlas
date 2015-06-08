CREATE OR REPLACE PACKAGE PKG_DISCOVERER IS

  -- Author  : SKUSHENKO
  -- Created : 10.04.2008 15:57:15
  -- Purpose : Заполнение временных таблиц для отчетов Discoverer

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
      FROM ins.bso_hist      his
          ,ins.bso           b
          ,ins.bso_hist_type ht
          ,ins.bso_series    bs
    
     WHERE his.bso_id = b.bso_id
       AND bs.bso_series_id = b.bso_series_id
       AND bs.bso_type_id = p_bso_type_id
       AND ht.bso_hist_type_id = his.hist_type_id
       AND his.num =
           (SELECT MAX(his2.num)
              FROM ins.bso_hist      his2
                  ,ins.bso_hist_type ht2
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
    TYPE t_rc IS REF CURSOR;
    l_cur             t_rc;
    l_rec             t_bso_in_out;
    l_finished_select VARCHAR2(4000);
    l_select          VARCHAR2(4000) := 'select
  rownum,
  t1.QUANTITY,
  t1.NUM_START,
  t1.NUM_END,
  t1.REG_DATE,
  t2.QUANTITY,
  t2.NUM_START,
  t2.NUM_END,
  t2.REG_DATE,
  t2.BSO_STATUS
from
   (select
       rownum as nn,
       bd.reg_date as REG_DATE,
       bdc.num_start as  NUM_START,
       nvl(bdc.num_end,bdc.num_start) as  NUM_END,
       decode(bdc.num_end,null,1,to_number(bdc.num_end)-to_number(bdc.num_start)+1) as QUANTITY
    from ins.ven_bso_document bd,
         ins.ven_doc_templ dt,
         ins.ven_bso_doc_cont bdc,
         ins.ven_bso_type bt,
         ins.ven_bso_series bs,
         ins.ven_bso_hist_type bht
    where bs.bso_type_id = bt.bso_type_id
      and bdc.bso_series_id = bs.bso_series_id
      and bht.bso_hist_type_id = bdc.bso_hist_type_id
      and bdc.bso_document_id = bd.bso_document_id
      and dt.doc_templ_id = bd.doc_templ_id
      and dt.brief = ''НакладнаяБСО''
      and bd.reg_date between :v_start_date and :v_end_date
      and bt.bso_type_id = :v_bso_type_id ) t1,
    (select rownum as nn,
            QUANTITY,
            NUM_START,
            NUM_END,
            REG_DATE,
            BSO_STATUS
       from  (select
                 count(*) as QUANTITY,
                 min(a) as NUM_START,
                 max(a) as NUM_END,
                 min(hist_date) as REG_DATE,
                 min(status) as BSO_STATUS
                from (select b.num as a, trunc(his.hist_date)  as hist_date, ht.name as status
                        from ins.bso_hist his, ins.bso b, ins.bso_hist_type ht, ins.bso_series bs
                       where his.bso_id = b.bso_id
                         and bs.bso_series_id = b.bso_series_id
                         and bs.bso_type_id = :v_bso_type_id
                         and ht.bso_hist_type_id = his.hist_type_id
                         and his.num = (select max(his2.num)
                                          from ins.bso_hist his2, ins.bso_hist_type ht2
                                         where his2.hist_date between :v_start_date and :v_end_date
                                           and his2.bso_id = his.bso_id
                                           and his2.hist_type_id = ht2.bso_hist_type_id
                                           and ht2.brief in (''Использован'', ''Испорчен'',
                                                ''Утерян'', ''Устарел'', ''Списан''))
                       order by trunc(his.hist_date), ht.brief, to_number(b.num))
               group by (to_number(a) - rownum)
               order by REG_DATE,BSO_STATUS, NUM_START )) t2 ';
    l_where_in_more   VARCHAR2(50) := ' where t1.nn = t2.nn(+)';
    l_where_out_more  VARCHAR2(50) := ' where t1.nn(+) = t2.nn';
    l_quantity_in     NUMBER(8);
    l_quantity_out    NUMBER(8);
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
    l_rec.N          := 0;
    l_fin_RB         := 0;
    l_fin_IQ         := 0;
    l_fin_OQ         := 0;
    l_fin_RE         := 0;
    l_fin_RC         := 0;
    l_rec.SESSION_ID := p_session_id;
    l_rec.GEN_DATE   := SYSDATE;
    FOR i IN (SELECT * FROM ins.ven_bso_type v ORDER BY NAME)
    LOOP
      /* Остатки */
      l_rec.REST_BEGIN  := NULL;
      l_rec.REST_END    := NULL;
      l_rec.REST_CHANGE := NULL;
      l_quantity_in     := 0;
      l_quantity_out    := 0;
      -- Идем циклом по видам бланков БСО
      --  Считаем записей в какой части таблицы больше Прихода или Расхода
      --  сцелью определения в какую сторону поставить внешнее объединение
      SELECT COUNT(*)
        INTO l_quantity_in
        FROM ins.ven_bso_document  bd
            ,ins.ven_doc_templ     dt
            ,ins.ven_bso_doc_cont  bdc
            ,ins.ven_bso_type      bt
            ,ins.ven_bso_series    bs
            ,ins.ven_bso_hist_type bht
       WHERE bs.bso_type_id = bt.bso_type_id
         AND bdc.bso_series_id = bs.bso_series_id
         AND bht.bso_hist_type_id = bdc.bso_hist_type_id
         AND bdc.bso_document_id = bd.bso_document_id
         AND dt.doc_templ_id = bd.doc_templ_id
         AND dt.brief = 'НакладнаяБСО'
         AND bd.reg_date BETWEEN p_start_date AND p_end_date
         AND bt.bso_type_id = i.bso_type_id;
    
      SELECT COUNT(*)
        INTO l_quantity_out
        FROM (SELECT 1
                FROM (SELECT b.num AS a
                            ,trunc(his.hist_date) AS hist_date
                            ,ht.name AS status
                        FROM ins.bso_hist      his
                            ,ins.bso           b
                            ,ins.bso_hist_type ht
                            ,ins.bso_series    bs
                       WHERE his.bso_id = b.bso_id
                         AND bs.bso_series_id = b.bso_series_id
                         AND bs.bso_type_id = i.bso_type_id
                         AND ht.bso_hist_type_id = his.hist_type_id
                         AND his.num = (SELECT MAX(his2.num)
                                          FROM ins.bso_hist      his2
                                              ,ins.bso_hist_type ht2
                                         WHERE his2.hist_date BETWEEN p_start_date AND p_end_date
                                           AND his2.bso_id = his.bso_id
                                           AND his2.hist_type_id = ht2.bso_hist_type_id
                                           AND ht2.brief IN ('Использован'
                                                            ,'Испорчен'
                                                            ,'Утерян'
                                                            ,'Устарел'
                                                            ,'Списан'))
                       ORDER BY trunc(his.hist_date)
                               ,ht.brief
                               ,to_number(b.num))
               GROUP BY (to_number(a) - rownum));
    
      IF l_quantity_out > l_quantity_in
      THEN
        --  Приход (+) = Расход
        l_finished_select := l_select || l_where_out_more;
      ELSE
        -- Приход = Расход (+)
        l_finished_select := l_select || l_where_in_more;
      END IF;
      -- Получили окончательный select для Прихода Расхода для текущего вида бланка
      -- В принципе в эту процедуру можно встатить и подсчет промежуточных и финального итогов
      -- и остатков
      OPEN l_cur FOR l_finished_select
        USING p_start_date, p_end_date, i.bso_type_id, i.bso_type_id, p_start_date, p_end_date;
    
      LOOP
        FETCH l_cur
          INTO l_rec.NN
              ,l_rec.IN_QUANTITY
              ,l_rec.IN_NUM_START
              ,l_rec.IN_NUM_END
              ,l_rec.IN_REG_DATE
              ,l_rec.OUT_QUANTITY
              ,l_rec.OUT_NUM_START
              ,l_rec.OUT_NUM_END
              ,l_rec.OUT_REG_DATE
              ,l_rec.OUT_BSO_STATUS;
      
        EXIT WHEN l_cur%NOTFOUND;
      
        l_rec.BSO_TYPE := NULL; /* Чтобы вид бланка выводился только на первой строке */
        IF l_cur%ROWCOUNT = 1
        THEN
          l_rec.BSO_TYPE := i.name;
        END IF;
      
        l_rec.N := l_rec.N + 1; /*Глобальный счетчик по всем записям отчета*/
      
        INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
      
        l_quantity_in  := l_quantity_in + nvl(l_rec.IN_QUANTITY, 0); /* Итого кол-во по видам бланка*/
        l_quantity_out := l_quantity_out + nvl(l_rec.OUT_QUANTITY, 0);
      
      END LOOP; -- Конец выворки записей Приход Расход для очередного вида Бланка
      CLOSE l_cur;
      -- Подсчет промежуточных итогов
      l_rec.N              := NULL;
      l_rec.BSO_TYPE       := 'ИТОГО по ' || i.name;
      l_rec.REST_BEGIN     := get_bso_rest_on_date(p_start_date, i.bso_type_id);
      l_rec.IN_QUANTITY    := l_quantity_in;
      l_rec.IN_NUM_START   := NULL;
      l_rec.IN_NUM_END     := NULL;
      l_rec.IN_REG_DATE    := NULL;
      l_rec.OUT_QUANTITY   := l_quantity_out;
      l_rec.OUT_NUM_START  := NULL;
      l_rec.OUT_NUM_END    := NULL;
      l_rec.OUT_REG_DATE   := NULL;
      l_rec.REST_END       := nvl(l_rec.REST_BEGIN, 0) + l_quantity_in - l_quantity_out;
      l_rec.OUT_BSO_STATUS := NULL;
      l_rec.REST_CHANGE    := nvl(l_rec.REST_END, 0) - nvl(l_rec.REST_BEGIN, 0);
    
      INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
    
      IF (l_quantity_in + l_quantity_out) > 0
      THEN
        l_fin_RB := l_fin_RB + l_rec.REST_BEGIN;
        l_fin_IQ := l_fin_IQ + l_rec.IN_QUANTITY;
        l_fin_OQ := l_fin_OQ + l_rec.OUT_QUANTITY;
        l_fin_RE := l_fin_RE + l_rec.REST_END;
        l_fin_RC := l_fin_RC + l_rec.REST_CHANGE;
      END IF;
    END LOOP; -- Конец цикла по BSO_TYPE  (видам бланков)
    -- Подсчет финального итога
    l_rec.BSO_TYPE     := 'ИТОГО все бланки';
    l_rec.REST_BEGIN   := l_fin_RB;
    l_rec.IN_QUANTITY  := l_fin_IQ;
    l_rec.OUT_QUANTITY := l_fin_OQ;
    l_rec.REST_END     := l_fin_RE;
    l_rec.REST_CHANGE  := l_fin_RC;
  
    INSERT INTO ins_dwh.bso_pivot_table_tmp VALUES l_rec;
  
  END;

END PKG_DISCOVERER;
/

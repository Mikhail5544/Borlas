CREATE MATERIALIZED VIEW INS_DWH.DM_DATE
REFRESH FORCE ON DEMAND
AS
SELECT
       date_id,
       year,
       half,
       quater,
       month,
       month_name,
       -- тут - тонко. 1 Неделя начинается с 1 понедельника, до этого - идет последняя неделя прошлого года
       MAX(CASE WHEN www LIKE '%.00' THEN NULL ELSE www END) over (ORDER BY date_id ROWS BETWEEN 8 preceding AND CURRENT ROW) week,
       day,
       day_type,
       month_end,
       sql_date,
       txt_date,
       day_o_week,
       day_o_week#
  FROM
(
  SELECT to_number(TO_CHAR(da, 'yyyymmdd')) date_id            ,
         to_number(TO_CHAR(da, 'YYYY'))     year                 ,
         decode(TO_CHAR(da, 'Q'), 1, 1, 2, 1, 2) half                 ,
         to_number(TO_CHAR(da, 'Q'))        quater               ,
         to_number(TO_CHAR(da, 'MM'))       month                ,
         trim(TO_CHAR(da, 'month', 'NLS_DATE_LANGUAGE=RUSSIAN')) month_name           ,
         -- считаем правильный номер недели
         TO_CHAR(da, 'YYYY')||'.'||to_char(COUNT(DECODE(TO_CHAR(da, 'D'), 2, 2, NULL)) over (PARTITION BY TO_CHAR(da, 'YYYY') ORDER BY da ROWS UNBOUNDED PRECEDING), 'fm00') www,
  --       to_number(TO_CHAR(da, 'WW'))        week,
         to_number(TO_CHAR(da, 'DD'))       day,
         decode(dt.dd_type, 0, 'Раб', 1, 'Вых') day_type,
         DECODE(da, last_day(da), 'Д', 'Н') month_end ,
         da sql_date,
         trim(TO_CHAR(da, 'dd.mm.yyyy', 'NLS_DATE_LANGUAGE=RUSSIAN')) txt_date,
         TO_CHAR(da, 'fmDay', 'NLS_DATE_LANGUAGE=RUSSIAN') day_o_week,
         DECODE(TO_CHAR(da, 'D'), 1, 7, TO_CHAR(da, 'D')-1) day_o_week#
    FROM (SELECT DATE'2003-01-01'+ROWNUM-1 da FROM dual
          CONNECT BY ROWNUM <= (LAST_DAY(SYSDATE + 366) - DATE'2003-01-01') -- на следующий год
         ) d,
         (SELECT t.calendar_date dd, t.is_holiday dd_type
            FROM ins.t_calendar t
         ) dt
   WHERE dt.dd (+) = d.da
) d
UNION ALL
SELECT
  -1 date_id   ,
  null year      ,
  null half      ,
  null quater    ,
  null month     ,
  null month_name,
  null week,
  null day       ,
  null day_type  ,
  'Н' month_end  ,
  null sql_date  ,
  'Не определена' txt_date,
  NULL day_o_week,
  NULL day_o_week#
FROM dual;


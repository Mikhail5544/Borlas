CREATE OR REPLACE FORCE VIEW V_GEN_BSO_IDS AS
SELECT series_num,
          to_char(ids - TRUNC(ids, -7),'0000000') num,
          ids
     FROM (SELECT series_num,
                  num,
                  PKG_XX_POL_IDS.cre_new_ids(series_num, num) ids
             FROM (SELECT     LEVEL num
                         FROM DUAL
                   CONNECT BY LEVEL <= (SELECT param_value
                                          FROM ins_dwh.rep_param
                                         WHERE rep_name = 'p_GEN_IDS' AND param_name = 'p_max_num')),
                  (SELECT bs.series_num
                     FROM bso_series bs
                    WHERE bs.series_name =
                                     (SELECT param_value
                                        FROM ins_dwh.rep_param
                                       WHERE rep_name = 'p_GEN_IDS' AND param_name = 'p_series_name')
                      AND ROWNUM = 1)
            WHERE num >= (SELECT param_value
                            FROM ins_dwh.rep_param
                           WHERE rep_name = 'p_GEN_IDS' AND param_name = 'p_min_num'));


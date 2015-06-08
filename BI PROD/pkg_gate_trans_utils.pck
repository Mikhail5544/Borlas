CREATE OR REPLACE PACKAGE PKG_GATE_TRANS_UTILS IS

  -- Author  : RKUDRYAVCEV
  -- Created : 09.08.2007 10:37:00
  -- Purpose : Вспомогательная процедура для выгрузки фин. проводок в Navision

  ----------------------------------------------------------
  --
  -- Функция выгружает Аналитику в navision
  --
  ----------------------------------------------------------
  FUNCTION EXPORT_ANALYTICS_TO_NAV(p_package_number NUMBER) RETURN VARCHAR2;

END PKG_GATE_TRANS_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_TRANS_UTILS IS

  ----------------------------------------------------------
  --
  -- Функция выгружает Аналитику в navision
  --
  ----------------------------------------------------------
  FUNCTION EXPORT_ANALYTICS_TO_NAV(p_package_number NUMBER) RETURN VARCHAR2 IS
    var_sql VARCHAR2(32000);
    --var_res varchar2(2000);
    -- var_count number;
  
  BEGIN
  
    -- будем идти только по тем типам аналитик которые хоть раз выгружались.
    -- Но перед выгрузкой данных аналитик необходимо сначала залогировать gate_trans_analityc
    FOR r IN (SELECT AT.*
                    ,GAT.ANALYTIC_TYPE_NAV
                    ,GAT.CALC_CODE
                FROM ins.analytic_type        AT
                    ,INSI.GATE_ANALYTICS_TYPE GAT
               WHERE AT.BRIEF = GAT.ANALYTIC_TYPE_BI
                 AND GAT.IS_EXPORT = 'Д'
                 AND EXISTS (SELECT *
                        FROM insi.gate_trans_analityc_log tal
                       WHERE tal.analytic_type_nav = gat.analytic_type_nav))
    LOOP
    
      var_sql := 'begin insert into INSI.GATE_ANALYTIC_VALUE (code, row_status, gate_package_id, ANALYTIC_TYPE_NAV, ANALYTIC_VALUE_ID, ANALYTIC_VALUE_NAME)
                            select 777 as CODE, INSI.PKG_GATE.row_update as row_status, ' ||
                 p_package_number || ' as gate_package_id, ''' || r.ANALYTIC_TYPE_NAV ||
                 ''' as ANALYTIC_TYPE_NAV, insi.pkg_trans.get_calc_analytic(''' || r.brief ||
                 ''', rec_t.obj_id, rec_t.obj_name, ''CALC_CODE'') as ANALYTIC_VALUE_ID, insi.pkg_trans.get_calc_analytic(''' ||
                 r.brief ||
                 ''', rec_t.obj_id, rec_t.obj_name, ''CALC_NAME'') as ANALYTIC_VALUE_NAME from (' ||
                 r.obj_list_sql_view || ') rec_t; end; ';
    
      EXECUTE IMMEDIATE var_sql
        USING IN SYSDATE;
    
    END LOOP;
  
    RETURN NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('PKG_GATE_TRANS_UTILS.EXPORT_ANALYTICS_TO_NAV:' ||
                                                         substr(var_sql, 0, 3900)
                                                        ,INSI.pkg_gate.event_error);
    
      INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('PKG_GATE_TRANS_UTILS.EXPORT_ANALYTICS_TO_NAV:' ||
                                                         SQLERRM
                                                        ,INSI.pkg_gate.event_error);
      RETURN 'Ошибка определения списка передаваемых значений аналитик. см. ошибку Oracle:' || SQLERRM(SQLCODE);
  END EXPORT_ANALYTICS_TO_NAV;

END PKG_GATE_TRANS_UTILS;
/

CREATE OR REPLACE PACKAGE PKG_REPOSITORY_FUNCTIONS IS

  -- Author  : MMIROVICH
  -- Created : 28.06.2007 18:07:12
  -- Purpose : 

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations

  FUNCTION F_GET_PERIOD
  (
    p_Report_Type VARCHAR2
   ,p_StartDate   VARCHAR2
   ,p_EndDate     VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE SP_WRITE_PERIOD
  (
    p_StartDate DATE
   ,p_EndDate   DATE
  );

END PKG_REPOSITORY_FUNCTIONS;
/
CREATE OR REPLACE PACKAGE BODY PKG_REPOSITORY_FUNCTIONS IS

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Вызывает процедуру, необходимую для построения отчета
  -- Возвращает период
  FUNCTION F_GET_PERIOD
  (
    p_Report_Type VARCHAR2
   ,p_StartDate   VARCHAR2
   ,p_EndDate     VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    RESULT     VARCHAR2(100);
    session_id NUMBER;
  BEGIN
  
    /*    Result := '';
    
       SP_WRITE_PERIOD(to_date(substr(p_StartDate,7,4)||substr(p_StartDate,4,2)||substr(p_StartDate,1,2), 'yyyymmdd'), to_date(substr(p_EndDate,7,4)||substr(p_EndDate,4,2)||substr(p_EndDate,1,2), 'yyyymmdd'));
    
        select 
               to_char(rp.start_date, 'dd.mm.yyyy') || '-' ||  
               to_char(rp.end_date, 'dd.mm.yyyy')
        into Result 
        from rep_period rp
        where
        rp.start_date = to_date(substr(p_StartDate,7,4)||substr(p_StartDate,4,2)||substr(p_StartDate,1,2), 'yyyymmdd')
        and
        rp.end_date = to_date(substr(p_EndDate,7,4)||substr(p_EndDate,4,2)||substr(p_EndDate,1,2), 'yyyymmdd');
    */
    -- Номер сессии
    session_id := sys_context('USERENV', 'SESSIONID');
    CASE
      WHEN p_Report_Type = 'rep_sr_product' THEN
        pkg_rep_utils_ins11.create_period_sales_report(to_date(p_StartDate, 'dd.mm.yyyy')
                                                      ,to_date(p_EndDate, 'dd.mm.yyyy'));
        RESULT := p_StartDate || ' - ' || p_EndDate;
      WHEN p_Report_Type = 'bso_pivot_table' THEN
        ins.pkg_discoverer.get_pivot_bso_table(to_date(p_StartDate, 'dd.mm.yyyy')
                                              ,to_date(p_EndDate, 'dd.mm.yyyy')
                                              ,session_id);
        RESULT := to_char(session_id);
      ELSE
        RESULT := '';
    END CASE;
    COMMIT;
    RETURN(RESULT);
  END;

  -- Записывает период
  PROCEDURE SP_WRITE_PERIOD
  (
    p_StartDate DATE
   ,p_EndDate   DATE
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DELETE REP_PERIOD;
    INSERT INTO rep_period VALUES (p_StartDate, p_EndDate, 0); -- added 0 to compile
    COMMIT;
  END;

END PKG_REPOSITORY_FUNCTIONS;
/

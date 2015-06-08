CREATE OR REPLACE PACKAGE pkg_dispatcher IS

  -- Author  : Алексей Землянский
  -- Created : 05-07-2006 14:08:43
  -- Purpose : Пакет для формы "Диспетчерский пульт" (DISPATCHER.fmb)

  FUNCTION what_is_this(p_as_dispatcher_id as_dispatcher.as_dispatcher_id%TYPE) RETURN VARCHAR2;

END pkg_dispatcher;
/
CREATE OR REPLACE PACKAGE BODY pkg_dispatcher IS

  FUNCTION what_is_this(p_as_dispatcher_id as_dispatcher.as_dispatcher_id%TYPE) RETURN VARCHAR2 IS
    retval VARCHAR2(255);
  BEGIN
    BEGIN
      SELECT CASE
               WHEN EXISTS
                (SELECT 1 FROM ven_as_demand_hosp WHERE as_dispatcher_id = p_as_dispatcher_id) THEN
                'на госпитализацию'
               WHEN EXISTS
                (SELECT 1 FROM ven_as_demand_service WHERE as_dispatcher_id = p_as_dispatcher_id) THEN
                'на услугу'
               WHEN EXISTS
                (SELECT 1 FROM ven_as_demand_smp WHERE as_dispatcher_id = p_as_dispatcher_id) THEN
                'на СМП'
               WHEN EXISTS (SELECT 1 FROM ven_as_complaint WHERE as_dispatcher_id = p_as_dispatcher_id) THEN
                'жалоба'
               ELSE
                NULL
             END
        INTO retval
        FROM dual;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    RETURN(retval);
  END;

BEGIN
  -- Initialization
  NULL;
END pkg_dispatcher;
/

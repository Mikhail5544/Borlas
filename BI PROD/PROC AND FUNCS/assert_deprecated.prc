CREATE OR REPLACE PROCEDURE assert_deprecated
(
  par_condition  BOOLEAN
 ,par_msg        VARCHAR2
 ,par_error_code NUMBER DEFAULT -20001
) IS
BEGIN
	-- @author Капля П.
	
  IF par_error_code IS NOT NULL
     AND - abs(par_error_code) NOT BETWEEN - 20999 AND - 20000
  THEN
    raise_application_error(-20001
                           ,'Переданный код ошибки должен быть в диапазоне от -20999 до -20000');
  END IF;

  IF nvl(par_condition, FALSE)
  THEN
    raise_application_error(-abs(nvl(par_error_code, -20001)), par_msg);
  END IF;
	
END assert_deprecated;
 
/

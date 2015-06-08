CREATE OR REPLACE PACKAGE PKG_FORMS_MESSAGE IS

  -- Author  : 
  -- Created : 11.06.2009
  -- Purpose : Утилиты для получения сообщений в приложении, полученных после выполнения кода в БД
  TYPE T_MESSAGE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  PROCEDURE put_message(p_message IN VARCHAR2);

  FUNCTION get_message RETURN T_MESSAGE;

END PKG_FORMS_MESSAGE;
/
CREATE OR REPLACE PACKAGE BODY PKG_FORMS_MESSAGE IS

  -- Author  : 
  -- Created : 11.06.2009
  -- Purpose : Утилиты для получения сообщений в приложении, полученных после выполнения кода в БД

  FORMS_MESSAGE       T_MESSAGE;
  FORMS_MESSAGE_OUT   T_MESSAGE;
  FORMS_MESSAGE_CLEAR T_MESSAGE;

  PROCEDURE put_message(p_message IN VARCHAR2) IS
    l_index NUMBER;
  BEGIN
    l_index := FORMS_MESSAGE.count;
  
    dbms_output.put_line('count (in package ' || l_index);
  
    FORMS_MESSAGE(l_index + 1) := p_message;
  
  END;

  FUNCTION get_message RETURN T_MESSAGE IS
  BEGIN
    FORMS_MESSAGE_OUT := FORMS_MESSAGE;
    FORMS_MESSAGE     := FORMS_MESSAGE_CLEAR;
    RETURN FORMS_MESSAGE_OUT;
  END;

END PKG_FORMS_MESSAGE;
/

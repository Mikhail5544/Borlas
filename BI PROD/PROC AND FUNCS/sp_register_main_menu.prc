CREATE OR REPLACE PROCEDURE sp_register_main_menu(pName VARCHAR2, pCode VARCHAR2, pNum VARCHAR2, pParentCode VARCHAR2) IS
 exist_code NUMBER(1);
 pParent_id   NUMBER; 
BEGIN

 exist_code := 0; 

 BEGIN
  SELECT MIN(main_menu_id) INTO pParent_id FROM main_menu WHERE UPPER(code) = UPPER(pParentCode);
 EXCEPTION
 WHEN OTHERS THEN RETURN;
 END;

 
 FOR rec IN (SELECT code FROM main_menu WHERE UPPER(code) = UPPER(pCode) AND UPPER(NAME) = UPPER(pName) AND parent_id = pParent_id) LOOP
    exist_code := 1;
    EXIT; 
 END LOOP;

 IF ( exist_code = 0) THEN
    INSERT INTO main_menu (main_menu_id, parent_id, code, NAME, num) 
    SELECT sq_main_menu.NEXTVAL, pParent_id, pCode, pName, pNum FROM dual;
 END IF;         

END;
/


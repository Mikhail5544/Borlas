CREATE OR REPLACE PROCEDURE sp_register_right(pName VARCHAR2, pBrief VARCHAR2, pRigthType VARCHAR2) IS
n NUMBER;
BEGIN

  SELECT r.safety_right_id INTO n FROM ven_safety_right r WHERE r.brief = pBrief ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN 
       INSERT INTO VEN_SAFETY_RIGHT  (BRIEF, NAME, SAFETY_RIGHT_TYPE_ID)
         VALUES (pBrief, pName, 
                 (SELECT rt.safety_right_type_id FROM VEN_SAFETY_RIGHT_TYPE rt 
                  WHERE rt.brief = pRigthType AND ROWNUM = 1));
    
END;
/


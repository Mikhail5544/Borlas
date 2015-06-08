CREATE OR REPLACE PROCEDURE sp_register_role_right(pNameRole VARCHAR2, pBrief VARCHAR2) IS
n NUMBER;
BEGIN
   SELECT s.safety_right_role_id INTO n 
    FROM ven_safety_right_role s, ven_sys_role ro, ven_safety_right ri
      WHERE ro.sys_role_id = s.role_id  AND ri.safety_right_id = s.safety_right_id
        AND ro.NAME = pNameRole AND ri.brief = pBrief;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN 
         INSERT INTO  ven_safety_right_role  (role_id,safety_right_id)
           VALUES  ( (SELECT ro.sys_role_id FROM ven_sys_role ro 
                      WHERE ro.NAME = pNameRole AND ROWNUM = 1),
                      (SELECT ri.safety_right_id FROM ven_safety_right ri
                       WHERE ri.brief = pBrief AND ROWNUM = 1)
                    );
END;
/


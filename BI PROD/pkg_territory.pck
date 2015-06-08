CREATE OR REPLACE PACKAGE pkg_territory IS
  FUNCTION get_territory_path(p_t_territory_id IN NUMBER) RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_territory IS
  FUNCTION get_territory_path(p_t_territory_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR c1 IS
    
      SELECT LEVEL
            ,parent_id
            ,DESCRIPTION
            ,T_TERRITORY_ID ID
        FROM T_TERRITORY tt
       START WITH tt.T_TERRITORY_ID = p_t_territory_id
      CONNECT BY PRIOR tt.parent_id = tt.t_territory_id
      
      ;
    RESULT  VARCHAR2(2000);
    v_index NUMBER;
    TYPE t_result IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    t_desc t_result;
  
  BEGIN
    v_index := 0;
    FOR cur IN c1
    LOOP
      v_index := v_index + 1;
      t_desc(v_index) := cur.DESCRIPTION;
    END LOOP;
  
    FOR i IN REVERSE 1 .. v_index
    LOOP
      RESULT := RESULT || t_desc(i) || '/';
    END LOOP;
  
    RESULT := RTRIM(RESULT, '/');
  
    RETURN RESULT;
  END;

END;
/

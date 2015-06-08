CREATE OR REPLACE PACKAGE PKG_GATE_UTILS IS
  -- пакет для доступа из MSSQL
  FUNCTION GetExportLine
  (
    p_obj_type NUMBER
   ,p_num      NUMBER
  ) RETURN VARCHAR2;
  FUNCTION GetObjTypeByPack(p_pack_id NUMBER) RETURN NUMBER;
END PKG_GATE_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_UTILS IS
  FUNCTION GetExportLine
  (
    p_obj_type NUMBER
   ,p_num      NUMBER
  ) RETURN VARCHAR2 IS
  
    CURSOR gate_ex
    (
      p_type    IN NUMBER
     ,C_NUM_EXE IN NUMBER
    ) IS
      SELECT *
        FROM GATE_OBJ_EXPORT_LINE
       WHERE GATE_OBJ_TYPE_ID = p_type
         AND NUM_EXE = C_NUM_EXE;
  
    rec gate_ex%ROWTYPE;
  
    l_val NVARCHAR2(255);
  BEGIN
  
    OPEN gate_ex(p_obj_type, P_NUM);
    FETCH gate_ex
      INTO rec;
  
    IF (gate_ex%NOTFOUND)
    THEN
      CLOSE gate_ex;
      RETURN 'none';
    END IF;
  
    l_val := rec.EXPORT_LINE;
    CLOSE gate_ex;
  
    RETURN l_val;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'none';
  END GetExportLine;

  FUNCTION GetObjTypeByPack(p_pack_id NUMBER) RETURN NUMBER IS
    l_ret NUMBER;
  BEGIN
    SELECT G.GATE_OBJ_TYPE_ID INTO l_ret FROM GATE_PACKAGE G WHERE G.GATE_PACKAGE_ID = p_pack_id;
    RETURN l_ret;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_gate.EventRet := pkg_gate.InserEvent('Ошибка:PKG_GATE_UTILS.GetObjTypeByPack'
                                              ,pkg_gate.event_error);
      RETURN 0;
  END GetObjTypeByPack;
END PKG_GATE_UTILS;
/

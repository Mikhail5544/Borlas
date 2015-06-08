CREATE OR REPLACE PACKAGE xp AS
  /*API ��� ������ � XQuery*/
  FUNCTION xPathProp(p_name VARCHAR2) RETURN VARCHAR2;

  FUNCTION xPathStr(p_name VARCHAR2 := NULL) RETURN VARCHAR2;

  FUNCTION xPathVal(p_name VARCHAR2 := '��������') RETURN VARCHAR2;

  FUNCTION xPathObj
  (
    n VARCHAR2 := NULL
   ,t VARCHAR2 := NULL
  ) RETURN VARCHAR2;

  FUNCTION xPathObjKey(n VARCHAR2) RETURN VARCHAR2;

  FUNCTION xPathObjRef(n VARCHAR2 := NULL) RETURN VARCHAR2;

END;
/
CREATE OR REPLACE PACKAGE BODY xp AS
  FUNCTION xPathProp(p_name VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN xPathStr(p_name) || xPathVal;
  END;

  FUNCTION xPathStr(p_name VARCHAR2 := NULL) RETURN VARCHAR2 IS
  BEGIN
    IF (p_name IS NULL)
    THEN
      RETURN '/��������';
    END IF;
    RETURN '/��������[@���="' || p_name || '"]';
  END;

  FUNCTION xPathVal(p_name VARCHAR2 := '��������') RETURN VARCHAR2 IS
  BEGIN
    RETURN '/' || p_name || '/text()';
  END;

  FUNCTION xPathObj
  (
    n VARCHAR2 := NULL
   ,t VARCHAR2 := NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    IF (n IS NULL AND t IS NULL)
    THEN
      RETURN '/����������/������';
    END IF;
    IF (n IS NULL AND t IS NOT NULL)
    THEN
      RETURN '/����������/������[@���="' || t || '"]';
    END IF;
  
    RETURN '/����������/������[@��� = "' || n || '"]';
  END;

  FUNCTION xPathObjKey(n VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN xPathObjRef(n) || xPathProp('���');
  END;

  FUNCTION xPathObjRef(n VARCHAR2 := NULL) RETURN VARCHAR2 IS
  BEGIN
    IF (n IS NULL)
    THEN
      RETURN '/������';
    END IF;
    RETURN '/������[@��� = "' || n || '"]';
  END;

END;
/

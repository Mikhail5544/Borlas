CREATE OR REPLACE PACKAGE xp AS
  /*API дл€ работы с XQuery*/
  FUNCTION xPathProp(p_name VARCHAR2) RETURN VARCHAR2;

  FUNCTION xPathStr(p_name VARCHAR2 := NULL) RETURN VARCHAR2;

  FUNCTION xPathVal(p_name VARCHAR2 := '«начение') RETURN VARCHAR2;

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
      RETURN '/—войство';
    END IF;
    RETURN '/—войство[@»м€="' || p_name || '"]';
  END;

  FUNCTION xPathVal(p_name VARCHAR2 := '«начение') RETURN VARCHAR2 IS
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
      RETURN '/‘айлќбмена/ќбъект';
    END IF;
    IF (n IS NULL AND t IS NOT NULL)
    THEN
      RETURN '/‘айлќбмена/ќбъект[@“ип="' || t || '"]';
    END IF;
  
    RETURN '/‘айлќбмена/ќбъект[@Ќпп = "' || n || '"]';
  END;

  FUNCTION xPathObjKey(n VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN xPathObjRef(n) || xPathProp(' од');
  END;

  FUNCTION xPathObjRef(n VARCHAR2 := NULL) RETURN VARCHAR2 IS
  BEGIN
    IF (n IS NULL)
    THEN
      RETURN '/—сылка';
    END IF;
    RETURN '/—сылка[@Ќпп = "' || n || '"]';
  END;

END;
/

CREATE OR REPLACE FUNCTION GetDocIdByPriority(p_contact INT) RETURN NUMBER IS
  ret NUMBER;
  res BOOLEAN;
BEGIN
  res := FALSE;
  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT MIN(TIT.ID) keep(DENSE_RANK FIRST ORDER BY TO_NUMBER(TIT.IMNS_CODE) ASC) AS ID
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.is_default = 1
               AND TIT.IMNS_CODE IS NOT NULL) TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT tit.id
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.IMNS_CODE IS NOT NULL
               AND tit.BRIEF = 'PASS_RF') TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT tit.id
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.IMNS_CODE IS NOT NULL
               AND upper(tit.DESCRIPTION) = upper('Паспорт моряка')) TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT tit.id
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.IMNS_CODE IS NOT NULL
               AND tit.BRIEF = 'VOEN_SOLD') TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT tit.id
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.IMNS_CODE IS NOT NULL
               AND tit.BRIEF = 'VOEN_UDOS') TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  BEGIN
    SELECT CCI.table_id
      INTO ret
      FROM (SELECT tit.id
              FROM ins.T_ID_TYPE TIT
             WHERE TIT.IMNS_CODE IS NOT NULL
               AND tit.BRIEF = 'BIRTH_CERT') TT
          ,ins.CN_CONTACT_IDENT CCI
     WHERE CCI.ID_TYPE = TT.ID
       AND CCI.contact_id = p_contact;
    res := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      res := FALSE;
  END;

  IF (res)
  THEN
    RETURN ret;
  END IF;

  RETURN NULL;
END GetDocIdByPriority;
/

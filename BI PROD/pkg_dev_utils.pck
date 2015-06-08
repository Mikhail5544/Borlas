CREATE OR REPLACE PACKAGE PKG_DEV_UTILS AS

  TextErr VARCHAR2(255);
  Err EXCEPTION;

  /*удаление последней версии у агенского договора*/
  /*подаетс€ ID хедера агенсткого договора */
  PROCEDURE delete_ag_last_version(p_ag_header_id NUMBER);

  /* изменение руководител€ */
  PROCEDURE currect_lead
  (
    p_ag_contract_id NUMBER
   ,p_ag_lead_id     NUMBER
  );

  /*изменение вырастивший руководитель*/
  PROCEDURE currect_f_lead
  (
    p_ag_contract_id NUMBER
   ,p_ag_f_lead_id   NUMBER
  );

  /*изменение рекрутера*/
  PROCEDURE currect_recrut
  (
    p_ag_contract_id NUMBER
   ,p_ag_recrut_id   NUMBER
  );

END PKG_DEV_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_DEV_UTILS AS

  /*удаление последней версии у агенского договора*/
  PROCEDURE delete_ag_last_version(p_ag_header_id NUMBER) IS
    CURSOR cur_del(p_ag_header NUMBER) IS
      SELECT b.MAX_AG
        FROM (SELECT MAX(a.AG_CONTRACT_ID) over(PARTITION BY a.CONTRACT_ID) AS MAX_AG
                    ,A.AG_CONTRACT_ID
                    ,a.CONTRACT_ID
                FROM VEN_AG_CONTRACT a
               WHERE a.CONTRACT_ID = p_ag_header) B
       WHERE b.MAX_AG = B.AG_CONTRACT_ID;
  
    CURSOR cur_prev_ver
    (
      p_ag_header  NUMBER
     ,p_ag_version NUMBER
    ) IS
      SELECT b.MAX_AG
        FROM (SELECT MAX(a.AG_CONTRACT_ID) over(PARTITION BY a.CONTRACT_ID) AS MAX_AG
                    ,A.AG_CONTRACT_ID
                    ,a.CONTRACT_ID
                FROM VEN_AG_CONTRACT a
               WHERE a.CONTRACT_ID = p_ag_header
                 AND A.AG_CONTRACT_ID <> p_ag_version) B
       WHERE b.MAX_AG = B.AG_CONTRACT_ID;
  
    p_ag_del  NUMBER;
    p_ag_prev NUMBER;
  BEGIN
  
    OPEN cur_del(p_ag_header_id);
    FETCH cur_del
      INTO p_ag_del;
  
    IF (cur_del%NOTFOUND)
    THEN
      CLOSE cur_del;
      TextErr := 'Ќе найдена верси€ агенского договора дл€ удалени€';
      RAISE Err;
    END IF;
  
    CLOSE cur_del;
  
    OPEN cur_prev_ver(p_ag_header_id, p_ag_del);
    FETCH cur_prev_ver
      INTO p_ag_prev;
  
    IF (cur_prev_ver%NOTFOUND)
    THEN
      CLOSE cur_prev_ver;
      TextErr := 'Ќе найдена предыдуща€ верси€ агенского договора';
      RAISE Err;
    END IF;
  
    CLOSE cur_prev_ver;
  
    UPDATE VEN_AG_CONTRACT_HEADER a
       SET a.LAST_VER_ID = p_ag_prev
     WHERE a.AG_CONTRACT_HEADER_ID = p_ag_header_id;
  
    DELETE FROM ven_ag_prod_line_contr plc WHERE plc.ag_contract_id = p_ag_del;
  
    DELETE FROM ven_ag_dav d WHERE d.CONTRACT_ID = p_ag_del;
  
    DELETE FROM ven_ag_plan_dop_rate d WHERE d.AG_CONTRACT_ID = p_ag_del;
  
    DELETE FROM ven_doc_status d WHERE d.DOCUMENT_ID = p_ag_del;
  
    DELETE ven_ag_contract a WHERE a.AG_CONTRACT_ID = p_ag_del;
  
  EXCEPTION
    WHEN Err THEN
      Raise_application_error(-20001, TextErr);
    WHEN OTHERS THEN
      Raise_application_error(-20001, SQLERRM);
    
  END delete_ag_last_version;

  /* изменение руководител€ */
  PROCEDURE currect_lead
  (
    p_ag_contract_id NUMBER
   ,p_ag_lead_id     NUMBER
  ) IS
    res      NUMBER;
    old_mean VARCHAR2(30);
    new_mean VARCHAR2(30);
  BEGIN
  
    SELECT v.CONTRACT_LEADER_ID
      INTO res
      FROM ven_AG_CONTRACT v
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
    IF (res = p_ag_lead_id)
    THEN
      TextErr := '—овпадают руководители.';
      RAISE Err;
    END IF;
  
    SELECT nvl(to_char(res), 'null') INTO old_mean FROM dual;
    SELECT nvl(to_char(p_ag_lead_id), 'null') INTO new_mean FROM dual;
    sp_insert_object_history('ag_contract'
                            ,'contract_leader_id'
                            ,p_ag_contract_id
                            ,TRIM(old_mean)
                            ,TRIM(new_mean)
                            ,'veselek'
                            ,'изменение »ƒ руководител€');
  
    UPDATE ven_AG_CONTRACT v
       SET v.CONTRACT_LEADER_ID = p_ag_lead_id
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
  EXCEPTION
    WHEN Err THEN
      raise_application_error(-20001, TextErr);
  END currect_lead;

  /*изменение вырастивший руководитель*/
  PROCEDURE currect_f_lead
  (
    p_ag_contract_id NUMBER
   ,p_ag_f_lead_id   NUMBER
  ) IS
    res      NUMBER;
    old_mean VARCHAR2(30);
    new_mean VARCHAR2(30);
  BEGIN
  
    SELECT v.CONTRACT_F_LEAD_ID
      INTO res
      FROM ven_AG_CONTRACT v
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
    IF (res = p_ag_f_lead_id)
    THEN
      TextErr := '—овпадают вырастивший руководители.';
      RAISE Err;
    END IF;
  
    SELECT nvl(to_char(res), 'null') INTO old_mean FROM dual;
    SELECT nvl(to_char(p_ag_f_lead_id), 'null') INTO new_mean FROM dual;
    sp_insert_object_history('ag_contract'
                            ,'contract_f_lead_id'
                            ,p_ag_contract_id
                            ,TRIM(old_mean)
                            ,TRIM(new_mean)
                            ,'veselek'
                            ,'изменение »ƒ вырастившего руководител€');
  
    UPDATE ven_AG_CONTRACT v
       SET v.CONTRACT_F_LEAD_ID = p_ag_f_lead_id
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
  EXCEPTION
    WHEN Err THEN
      raise_application_error(-20001, TextErr);
  END currect_f_lead;

  /*изменение рекрутера*/
  PROCEDURE currect_recrut
  (
    p_ag_contract_id NUMBER
   ,p_ag_recrut_id   NUMBER
  ) IS
    res      NUMBER;
    rec_id   NUMBER;
    new_mean VARCHAR2(30);
    old_mean VARCHAR2(30);
  BEGIN
  
    SELECT v.CONTRACT_RECRUT_ID
          ,v.ag_contract_id
      INTO res
          ,rec_id
      FROM ven_AG_CONTRACT v
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
    IF (res = p_ag_recrut_id)
    THEN
      TextErr := '—овпадают рекрутеры.';
      RAISE Err;
    END IF;
    SELECT nvl(to_char(res), 'null') INTO old_mean FROM dual;
    SELECT nvl(to_char(p_ag_recrut_id), 'null') INTO new_mean FROM dual;
    sp_insert_object_history('ag_contract'
                            ,'contract_recrut_id'
                            ,rec_id
                            ,TRIM(old_mean)
                            ,TRIM(new_mean)
                            ,'veselek'
                            ,'изменение »ƒ рекрутера');
  
    UPDATE ven_AG_CONTRACT v
       SET v.CONTRACT_recrut_ID = p_ag_recrut_id
     WHERE v.AG_CONTRACT_ID = p_ag_contract_id;
  
  EXCEPTION
    WHEN Err THEN
      raise_application_error(-20001, TextErr);
  END currect_recrut;

END PKG_DEV_UTILS;
/

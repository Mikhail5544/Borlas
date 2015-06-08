CREATE OR REPLACE PACKAGE pkg_agent_attest IS
  FUNCTION GetFirstStatusByAgentCategory(p_category VARCHAR2) RETURN VEN_AG_ATTEST_PATH%ROWTYPE;
  FUNCTION GetNextStatusByAgentCategory
  (
    p_category   VARCHAR2
   ,p_cur_status VARCHAR2
  ) RETURN VEN_AG_ATTEST_PATH%ROWTYPE;

  PROCEDURE CreateHisAttByDoc(p_doc_id IN NUMBER); /*false/true*/
  PROCEDURE DeleteHisAttByDoc(p_doc_id IN NUMBER); /*false/true*/

  FUNCTION DeleteHisAttByDocCont
  (
    p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER; /*false/true*/

  FUNCTION CreateHisAttByDocCont
  (
    p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER; /*false/true*/
  FUNCTION CreateAddAgreement
  (
    p_item VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER; /*false/true*/

  FUNCTION InsertAgStatHistory(p_stat IN OUT VEN_AG_STAT_HIST%ROWTYPE) RETURN NUMBER; /*false/true*/
  FUNCTION DeleteAgStatHistory(p_id NUMBER) RETURN NUMBER; /*false/true*/

  FUNCTION GetLastStatHistByHead(p_ag_header NUMBER) RETURN VEN_AG_STAT_HIST%ROWTYPE;

  FUNCTION GetAgAttestPath(p_Ag_Attest_Path_Id NUMBER) RETURN VEN_AG_ATTEST_PATH%ROWTYPE;

  FUNCTION GetAgStatAgent(p_Id NUMBER) RETURN VEN_AG_STAT_AGENT%ROWTYPE;

  FUNCTION CreateAddAgreementByTempl
  (
    p_item               VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc                VEN_AG_ATTEST_DOCUMENT%ROWTYPE
   ,p_AG_TEMPL_HEADER_ID NUMBER
  ) RETURN NUMBER; /*false/true*/

  FUNCTION GetAgAttestDocument(p_id NUMBER) RETURN VEN_AG_ATTEST_DOCUMENT%ROWTYPE;
  FUNCTION UpdateAgAttestDocCont(p_rec VEN_AG_ATTEST_DOC_CONT%ROWTYPE) RETURN NUMBER;

  FUNCTION InsertAgAttestDocument(p_item IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE) RETURN NUMBER;
  FUNCTION InsertAgAttestDocCont(p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE) RETURN NUMBER;

  FUNCTION GetSqAgStatHistory RETURN NUMBER;

  PROCEDURE CreateDocumentAttestBySgpRoll(p_id NUMBER);

END pkg_agent_attest;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent_attest IS

  FUNCTION GetFirstStatusByAgentCategory(p_category VARCHAR2) RETURN VEN_AG_ATTEST_PATH%ROWTYPE IS
    CURSOR cur_AG_ATTEST_PATH(cv_BRIEF VARCHAR2) IS
      SELECT v.*
        FROM VEN_AG_ATTEST_PATH    v
            ,VEN_AG_CATEGORY_AGENT vag
            ,VEN_AG_STAT_AGENT     VAS
       WHERE vag.BRIEF = cv_BRIEF
         AND vag.AG_CATEGORY_AGENT_ID = VAS.AG_CATEGORY_AGENT_ID
         AND v.FROM_STAT_ID IS NULL
         AND v.TO_STAT_ID = VAS.AG_STAT_AGENT_ID;
  
    rec_AG_ATTEST_PATH cur_AG_ATTEST_PATH%ROWTYPE;
  BEGIN
  
    OPEN cur_AG_ATTEST_PATH(p_category);
    FETCH cur_AG_ATTEST_PATH
      INTO rec_AG_ATTEST_PATH;
  
    IF (cur_AG_ATTEST_PATH%NOTFOUND)
    THEN
      CLOSE cur_AG_ATTEST_PATH;
      RETURN NULL;
    END IF;
  
    CLOSE cur_AG_ATTEST_PATH;
    RETURN rec_AG_ATTEST_PATH;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GetFirstStatusByAgentCategory;

  FUNCTION GetNextStatusByAgentCategory
  (
    p_category   VARCHAR2
   ,p_cur_status VARCHAR2
  ) RETURN VEN_AG_ATTEST_PATH%ROWTYPE IS
    CURSOR cur_AG_ATTEST_PATH
    (
      cv_BRIEF       VARCHAR2
     ,cv_curr_status VARCHAR2
    ) IS
      SELECT v.*
        FROM VEN_AG_ATTEST_PATH    v
            ,VEN_AG_CATEGORY_AGENT vag
            ,VEN_AG_STAT_AGENT     VAS
            ,VEN_AG_STAT_AGENT     VAS_FROM
       WHERE vag.BRIEF = cv_BRIEF
         AND vag.AG_CATEGORY_AGENT_ID = VAS.AG_CATEGORY_AGENT_ID
         AND v.FROM_STAT_ID = VAS_FROM.AG_STAT_AGENT_ID
         AND VAS_FROM.BRIEF = cv_curr_status
         AND v.TO_STAT_ID = VAS.AG_STAT_AGENT_ID;
  
    rec_AG_ATTEST_PATH cur_AG_ATTEST_PATH%ROWTYPE;
  
  BEGIN
    OPEN cur_AG_ATTEST_PATH(p_category, p_cur_status);
    FETCH cur_AG_ATTEST_PATH
      INTO rec_AG_ATTEST_PATH;
  
    IF (cur_AG_ATTEST_PATH%NOTFOUND)
    THEN
      CLOSE cur_AG_ATTEST_PATH;
      RETURN NULL;
    END IF;
  
    CLOSE cur_AG_ATTEST_PATH;
    RETURN rec_AG_ATTEST_PATH;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GetNextStatusByAgentCategory;

  FUNCTION DeleteAgStatHistory(p_id NUMBER) RETURN NUMBER /*false/true*/
   IS
  BEGIN
    DELETE FROM ven_ag_stat_hist v WHERE V.AG_STAT_HIST_ID = p_id;
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END DeleteAgStatHistory;

  FUNCTION DeleteHisAttByDocCont
  (
    p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER /*false/true*/
   IS
    ret NUMBER;
  BEGIN
  
    ret := DeleteAgStatHistory(p_item.AG_STAT_HIST_ID);
  
    IF (ret != Utils.c_true)
    THEN
      RETURN ret;
    END IF;
  
    p_item.AG_STAT_HIST_ID := NULL;
  
    ret := UpdateAgAttestDocCont(p_item);
  
    IF (ret != Utils.c_true)
    THEN
      RETURN ret;
    END IF;
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END DeleteHisAttByDocCont;

  PROCEDURE DeleteHisAttByDoc(p_doc_id IN NUMBER) IS
    CURSOR cur_AG_ATTEST_DOC_CONT(cv_document NUMBER) IS
      SELECT *
        FROM VEN_AG_ATTEST_DOC_CONT V
       WHERE v.AG_ATTEST_DOCUMENT_ID = cv_document
         AND v.AG_STAT_HIST_ID IS NOT NULL;
  
    rec_AG_ATTEST_DOCUMENT VEN_AG_ATTEST_DOCUMENT%ROWTYPE := GetAgAttestDocument(p_doc_id);
  BEGIN
  
    FOR rec IN cur_AG_ATTEST_DOC_CONT(p_doc_id)
    LOOP
      IF (DeleteHisAttByDocCont(rec, rec_AG_ATTEST_DOCUMENT) != Utils.c_true)
      THEN
        RETURN;
      END IF;
    END LOOP;
  
  END DeleteHisAttByDoc;

  PROCEDURE CreateHisAttByDoc(p_doc_id IN NUMBER) IS
  
    CURSOR cur_AG_ATTEST_DOC_CONT(cv_document NUMBER) IS
      SELECT *
        FROM VEN_AG_ATTEST_DOC_CONT V
       WHERE v.AG_ATTEST_DOCUMENT_ID = cv_document
         AND v.AG_STAT_HIST_ID IS NULL;
  
    rec_AG_ATTEST_DOCUMENT VEN_AG_ATTEST_DOCUMENT%ROWTYPE := GetAgAttestDocument(p_doc_id);
    rec_AG_ATTEST_DOC_CONT cur_AG_ATTEST_DOC_CONT%ROWTYPE;
  BEGIN
  
    FOR rec IN cur_AG_ATTEST_DOC_CONT(p_doc_id)
    LOOP
      IF (CreateHisAttByDocCont(rec, rec_AG_ATTEST_DOCUMENT) != Utils.c_true)
      THEN
        RETURN;
      END IF;
    END LOOP;
  
  END CreateHisAttByDoc;

  FUNCTION CreateHisAttByDocCont
  (
    p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER IS
    v_stat           VEN_AG_STAT_HIST%ROWTYPE;
    v_stat_prev      VEN_AG_STAT_HIST%ROWTYPE := GetLastStatHistByHead(p_item.AG_CONTRACT_HEADER_ID);
    v_ag_attest_path VEN_AG_ATTEST_PATH%ROWTYPE := GetAgAttestPath(p_item.AG_ATTEST_PATH_ID);
    vrec_ag_contract VEN_AG_CONTRACT%ROWTYPE;
    v2_ag_contract   NUMBER;
  
    p NUMBER;
  BEGIN
  
    v_stat.AG_CATEGORY_AGENT_ID := GetAgStatAgent(p_item.AG_STAT_AGENT_ID).AG_CATEGORY_AGENT_ID;
  
    v_stat.num := v_stat_prev.num + 1;
  
    /*СОздаем доп соглашение согласно теплейту*/
    IF (v_ag_attest_path.AG_TEMPL_HEADER_ID IS NOT NULL)
    THEN
      p                := pkg_agent.CreateContractByTemplateId(p_item.AG_CONTRACT_HEADER_ID
                                                              ,v_ag_attest_path.AG_TEMPL_HEADER_ID
                                                              ,v2_ag_contract);
      vrec_ag_contract := pkg_agent.GetAgContract(v2_ag_contract);
    END IF;
  
    /*Если не нужно создовать темплейт, вычитываем последний допник*/
    IF (v_ag_attest_path.AG_TEMPL_HEADER_ID IS NULL)
    THEN
      vrec_ag_contract := pkg_agent.GetLastAgContractByHeader(p_item.AG_CONTRACT_HEADER_ID);
    END IF;
  
    v_stat.AG_CONTRACT_HEADER_ID := p_item.AG_CONTRACT_HEADER_ID;
    v_stat.AG_STAT_AGENT_ID      := p_item.AG_STAT_AGENT_ID;
    v_stat.K_KD                  := p_item.K_KD;
    v_stat.K_KSP                 := p_item.K_KSP;
    v_stat.K_SGP                 := p_item.K_SGP;
  
    v_stat.STAT_DATE      := p_doc.STAT_DATE;
    v_stat.AG_CONTRACT_ID := vrec_ag_contract.AG_CONTRACT_ID;
  
    --vrec_ag_contract.AG_CONTRACT_ID
  
    IF (InsertAgStatHistory(v_stat) != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    p_item.AG_STAT_HIST_ID := v_stat.AG_STAT_HIST_ID;
  
    IF (UpdateAgAttestDocCont(p_item) != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END CreateHisAttByDocCont;

  FUNCTION GetSqAgStatHistory RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT SQ_AG_STAT_HIST.nextval INTO ret FROM dual;
  
    RETURN ret;
  END GetSqAgStatHistory;

  FUNCTION InsertAgStatHistory(p_stat IN OUT VEN_AG_STAT_HIST%ROWTYPE) RETURN NUMBER /*false/true*/
   IS
  BEGIN
  
    p_stat.AG_STAT_HIST_ID := GetSqAgStatHistory;
  
    INSERT INTO VEN_AG_STAT_HIST
      (AG_STAT_HIST_ID
      ,AG_CATEGORY_AGENT_ID
      ,AG_CONTRACT_HEADER_ID
      ,AG_STAT_AGENT_ID
      ,K_KD
      ,K_KSP
      ,K_SGP
      ,NUM
      ,STAT_DATE
      ,AG_CONTRACT_ID)
    VALUES
      (p_stat.AG_STAT_HIST_ID
      ,p_stat.AG_CATEGORY_AGENT_ID
      ,p_stat.AG_CONTRACT_HEADER_ID
      ,p_stat.AG_STAT_AGENT_ID
      ,p_stat.K_KD
      ,p_stat.K_KSP
      ,p_stat.K_SGP
      ,p_stat.NUM
      ,p_stat.STAT_DATE
      ,p_stat.AG_CONTRACT_ID);
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END InsertAgStatHistory;

  FUNCTION GetLastStatHistByHead(p_ag_header NUMBER) RETURN VEN_AG_STAT_HIST%ROWTYPE IS
  
    CURSOR cur_VEN_AG_STAT_HIST(cv_ag_header NUMBER) IS
      SELECT v2.*
        FROM VEN_AG_STAT_HIST v2
       WHERE v2.AG_STAT_HIST_ID = (SELECT MAX(v.AG_STAT_HIST_ID) M
                                     FROM VEN_AG_STAT_HIST v
                                    WHERE v.AG_CONTRACT_HEADER_ID = cv_ag_header);
  
    rec_VEN_AG_STAT_HIST cur_VEN_AG_STAT_HIST%ROWTYPE;
  
  BEGIN
  
    OPEN cur_VEN_AG_STAT_HIST(p_ag_header);
    FETCH cur_VEN_AG_STAT_HIST
      INTO rec_VEN_AG_STAT_HIST;
  
    IF (cur_VEN_AG_STAT_HIST%NOTFOUND)
    THEN
      CLOSE cur_VEN_AG_STAT_HIST;
      RETURN NULL;
    END IF;
  
    CLOSE cur_VEN_AG_STAT_HIST;
  
    RETURN rec_VEN_AG_STAT_HIST;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END GetLastStatHistByHead;

  /*Создание дополнительного соглашения, если требуется*/
  FUNCTION CreateAddAgreement
  (
    p_item VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc  VEN_AG_ATTEST_DOCUMENT%ROWTYPE
  ) RETURN NUMBER /*false/true*/
   IS
  
    rec_VEN_AG_ATTEST_PATH VEN_AG_ATTEST_PATH%ROWTYPE := GetAgAttestPath(p_item.AG_ATTEST_PATH_ID);
  BEGIN
  
    IF (rec_VEN_AG_ATTEST_PATH.AG_ATTEST_PATH_ID IS NULL)
    THEN
      RETURN Utils.c_true; -- добавлять доп соглашение не требуется
    END IF;
  
    IF (rec_VEN_AG_ATTEST_PATH.AG_TEMPL_HEADER_ID IS NOT NULL)
    THEN
    
      NULL;
    
    END IF;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN utils.c_false;
  END CreateAddAgreement;

  FUNCTION GetAgAttestPath(p_Ag_Attest_Path_Id NUMBER) RETURN VEN_AG_ATTEST_PATH%ROWTYPE IS
  
    CURSOR cur_VEN_AG_ATTEST_PATH(cv_Ag_Attest_Path_Id NUMBER) IS
      SELECT * FROM VEN_AG_ATTEST_PATH v WHERE v.AG_ATTEST_PATH_ID = cv_Ag_Attest_Path_Id;
  
    rec_VEN_AG_ATTEST_PATH cur_VEN_AG_ATTEST_PATH%ROWTYPE;
  
  BEGIN
  
    OPEN cur_VEN_AG_ATTEST_PATH(p_Ag_Attest_Path_Id);
    FETCH cur_VEN_AG_ATTEST_PATH
      INTO rec_VEN_AG_ATTEST_PATH;
  
    IF (cur_VEN_AG_ATTEST_PATH%NOTFOUND)
    THEN
      CLOSE cur_VEN_AG_ATTEST_PATH;
      RETURN NULL;
    END IF;
  
    CLOSE cur_VEN_AG_ATTEST_PATH;
  
    RETURN rec_VEN_AG_ATTEST_PATH;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION CreateAddAgreementByTempl
  (
    p_item               VEN_AG_ATTEST_DOC_CONT%ROWTYPE
   ,p_doc                VEN_AG_ATTEST_DOCUMENT%ROWTYPE
   ,p_AG_TEMPL_HEADER_ID NUMBER
  ) RETURN NUMBER /*false/true*/
   IS
  BEGIN
    NULL;
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END CreateAddAgreementByTempl;

  FUNCTION GetAgStatAgent(p_Id NUMBER) RETURN VEN_AG_STAT_AGENT%ROWTYPE IS
  
    CURSOR cur_VEN_AG_STAT_AGENT(cv_VEN_AG_STAT_AGENT NUMBER) IS
      SELECT * FROM VEN_AG_STAT_AGENT v WHERE V.AG_STAT_AGENT_ID = cv_VEN_AG_STAT_AGENT;
  
    rec_VEN_AG_STAT_AGENT cur_VEN_AG_STAT_AGENT%ROWTYPE;
  
  BEGIN
  
    OPEN cur_VEN_AG_STAT_AGENT(p_Id);
    FETCH cur_VEN_AG_STAT_AGENT
      INTO rec_VEN_AG_STAT_AGENT;
  
    IF (cur_VEN_AG_STAT_AGENT%NOTFOUND)
    THEN
      CLOSE cur_VEN_AG_STAT_AGENT;
      RETURN NULL;
    END IF;
  
    CLOSE cur_VEN_AG_STAT_AGENT;
  
    RETURN rec_VEN_AG_STAT_AGENT;
  
  END;

  FUNCTION GetAgAttestDocument(p_id NUMBER) RETURN VEN_AG_ATTEST_DOCUMENT%ROWTYPE IS
    CURSOR cur_AG_ATTEST_DOCUMENT(cv_document NUMBER) IS
      SELECT * FROM VEN_AG_ATTEST_DOCUMENT V WHERE v.AG_ATTEST_DOCUMENT_ID = cv_document;
  
    ret cur_AG_ATTEST_DOCUMENT%ROWTYPE;
  BEGIN
  
    OPEN cur_AG_ATTEST_DOCUMENT(p_id);
    FETCH cur_AG_ATTEST_DOCUMENT
      INTO ret;
  
    IF (cur_AG_ATTEST_DOCUMENT%NOTFOUND)
    THEN
      CLOSE cur_AG_ATTEST_DOCUMENT;
      RETURN NULL;
    END IF;
  
    CLOSE cur_AG_ATTEST_DOCUMENT;
    RETURN ret;
  
  END GetAgAttestDocument;

  FUNCTION UpdateAgAttestDocCont(p_rec VEN_AG_ATTEST_DOC_CONT%ROWTYPE) RETURN NUMBER IS
  BEGIN
    UPDATE VEN_AG_ATTEST_DOC_CONT V
       SET ag_attest_document_id = p_rec.ag_attest_document_id
          ,ag_attest_path_id     = p_rec.ag_attest_path_id
          ,ag_contract_header_id = p_rec.ag_contract_header_id
          ,ag_stat_agent_id      = p_rec.ag_stat_agent_id
          ,ag_stat_hist_id       = p_rec.ag_stat_hist_id
          ,is_up                 = p_rec.is_up
          ,k_kd                  = p_rec.k_kd
          ,k_ksp                 = p_rec.k_ksp
          ,k_sgp                 = p_rec.k_sgp
          ,notice                = p_rec.notice
     WHERE p_rec.ag_attest_doc_cont_id = V.ag_attest_doc_cont_id;
  
    RETURN UTILS.C_TRUE;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN UTILS.C_FALSE;
  END UpdateAgAttestDocCont;

  FUNCTION InsertAgAttestDocument(p_item IN OUT VEN_AG_ATTEST_DOCUMENT%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_item.ag_attest_document_id IS NULL)
    THEN
      p_item.ag_attest_document_id := PKG_AGENT_UTILS.GetNewSqAgAttestDocument;
    END IF;
  
    IF (p_item.doc_templ_id IS NULL)
    THEN
      p_item.doc_templ_id := PKG_AGENT_UTILS.GetDocTemplAgAttestDocument;
    END IF;
  
    INSERT INTO ven_ag_attest_document
      (ag_attest_document_id, doc_templ_id, note, num, reg_date, stat_date, ext_id)
    VALUES
      (p_item.ag_attest_document_id
      ,p_item.doc_templ_id
      ,p_item.note
      ,p_item.num
      ,p_item.reg_date
      ,p_item.stat_date
      ,p_item.ext_id);
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END InsertAgAttestDocument;

  FUNCTION InsertAgAttestDocCont(p_item IN OUT VEN_AG_ATTEST_DOC_CONT%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_item.ag_attest_doc_cont_id IS NULL)
    THEN
      p_item.ag_attest_doc_cont_id := PKG_AGENT_UTILS.GetNewSqAgAttestDocCon;
    END IF;
  
    INSERT INTO VEN_AG_ATTEST_DOC_CONT
      (ag_attest_doc_cont_id
      ,ext_id
      ,ag_attest_document_id
      ,ag_attest_path_id
      ,ag_contract_header_id
      ,ag_stat_agent_id
      ,ag_stat_hist_id
      ,is_up
      ,k_kd
      ,k_ksp
      ,k_sgp
      ,notice)
    VALUES
      (p_item.ag_attest_doc_cont_id
      ,p_item.ext_id
      ,p_item.ag_attest_document_id
      ,p_item.ag_attest_path_id
      ,p_item.ag_contract_header_id
      ,p_item.ag_stat_agent_id
      ,p_item.ag_stat_hist_id
      ,p_item.is_up
      ,p_item.k_kd
      ,p_item.k_ksp
      ,p_item.k_sgp
      ,p_item.notice);
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END InsertAgAttestDocCont;

  FUNCTION IsValidAttest
  (
    p_package_name          VARCHAR2
   ,P_AG_ATTEST_PATH_ID     NUMBER
   ,p_ag_contract_header_id NUMBER
   ,p_ag_sgp_id             NUMBER
   ,p_ag_roll_id            NUMBER
  ) RETURN NUMBER IS
    res NUMBER := UTILS.C_FALSE;
  BEGIN
  
    FOR rec_fn IN (SELECT *
                     FROM AG_ATTEST_CONDITION aac
                    WHERE AAC.AG_ATTEST_PATH_ID = P_AG_ATTEST_PATH_ID)
    LOOP
    
      EXECUTE IMMEDIATE 'BEGIN :res:=' || p_package_name || '.' || rec_fn.sql_exec ||
                        '(:p_ag_contract_header_id, :p_ag_roll_id, :p_ag_sgp_id );  END;'
        USING OUT res, IN p_ag_contract_header_id, IN p_ag_roll_id, IN p_ag_sgp_id;
    
    END LOOP;
  
    RETURN res;
  END IsValidAttest;

  PROCEDURE CreateDocumentAttestBySgpRoll(p_id NUMBER) IS
  
    CURSOR cur(cv_AG_ROLL_ID NUMBER) IS
      SELECT art.BRIEF
            ,ACA.PACKAGE_NAME
        FROM ven_AG_ROLL           ar
            ,ven_AG_ROLL_HEADER    arh
            ,ven_AG_ROLL_TYPE      art
            ,ven_AG_CATEGORY_AGENT aca
       WHERE AR.AG_ROLL_ID = cv_AG_ROLL_ID
         AND ARH.AG_ROLL_HEADER_ID = AR.AG_ROLL_HEADER_ID
         AND ART.AG_ROLL_TYPE_ID = ARH.AG_ROLL_TYPE_ID
         AND ACA.AG_CATEGORY_AGENT_ID = ARH.AG_CATEGORY_AGENT_ID;
  
    rec cur%ROWTYPE;
  
    var_ven_ag_roll        ven_ag_roll%ROWTYPE;
    var_ven_ag_roll_header ven_ag_roll_header%ROWTYPE;
    var_ven_AG_ROLL_TYPE   ven_AG_ROLL_TYPE%ROWTYPE;
  
    ret                    NUMBER;
    var_AG_ATTEST_DOCUMENT ven_AG_ATTEST_DOCUMENT%ROWTYPE;
    var_AG_ATTEST_DOC_CONT ven_AG_ATTEST_DOC_CONT%ROWTYPE;
  
  BEGIN
  
    OPEN cur(p_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN;
    END IF;
  
    CLOSE cur;
  
    IF (rec.BRIEF NOT IN ('ASG', 'DSG'))
    THEN
      RETURN;
    END IF;
  
    var_ven_ag_roll.ag_roll_id := p_id;
    var_ven_ag_roll            := PKG_AG_ROLL.GetAgRoll(var_ven_ag_roll.ag_roll_id);
    var_ven_ag_roll_header     := PKG_AG_ROLL.GetAgRollHeader(var_ven_ag_roll.ag_roll_header_id);
    var_ven_AG_ROLL_TYPE       := PKG_AG_ROLL.GEtAgRollType(var_ven_ag_roll_header.AG_ROLL_TYPE_ID);
  
    var_AG_ATTEST_DOCUMENT.NUM          := PKG_AUTOSQ.NEXTVAL('ATTEST_DOCUMENT', '');
    var_AG_ATTEST_DOCUMENT.STAT_DATE    := ADD_MONTHS(var_ven_ag_roll_header.DATE_BEGIN, 1);
    var_AG_ATTEST_DOCUMENT.DOC_TEMPL_ID := PKG_AGENT_UTILS.GetDocTemplAgAttestDocument;
  
    ret := PKG_AGENT_ATTEST.InsertAgAttestDocument(var_AG_ATTEST_DOCUMENT);
    DOC.SET_DOC_STATUS(var_AG_ATTEST_DOCUMENT.AG_ATTEST_DOCUMENT_ID
                      ,'NEW'
                      ,SYSDATE
                      ,'AUTO'
                      ,'Автоматическое создание документа по ' || var_ven_AG_ROLL_TYPE.NAME);
  
    FOR rec_ag IN (SELECT SGP.AG_SGP_ID
                         ,SGP.SGP_SUM
                         ,SGP.AG_CONTRACT_HEADER_ID
                         ,AP.IS_UP
                         ,AP.FROM_STAT_ID
                         ,AP.TO_STAT_ID
                         ,AP.AG_ATTEST_PATH_ID
                     FROM AG_SGP         SGP
                         ,ag_attest_path ap
                         ,AG_STAT_AGENT  asa_to
                         ,AG_STAT_AGENT  asa_from
                    WHERE SGP.status_id = ap.from_stat_id
                      AND asa_to.AG_STAT_AGENT_ID = AP.TO_STAT_ID
                      AND ASA_FROM.AG_STAT_AGENT_ID = AP.FROM_STAT_ID
                      AND SGP.AG_ROLL_ID = p_id --5622488
                    ORDER BY SGP.AG_CONTRACT_HEADER_ID ASC
                            ,to_number(ASA_TO.AG_CATEGORY_AGENT_ID || ASA_TO.STATUS_PRIOR) DESC)
    LOOP
    
      ret := IsValidAttest(rec.PACKAGE_NAME
                          ,rec_ag.AG_ATTEST_PATH_ID
                          ,rec_ag.AG_CONTRACT_HEADER_ID
                          ,rec_ag.AG_SGP_ID
                          ,p_id);
    
      IF (ret = Utils.c_true)
      THEN
      
        var_AG_ATTEST_DOC_CONT.AG_ATTEST_DOCUMENT_ID := var_AG_ATTEST_DOCUMENT.AG_ATTEST_DOCUMENT_ID;
        var_AG_ATTEST_DOC_CONT.AG_ATTEST_PATH_ID     := rec_ag.AG_ATTEST_PATH_ID;
        var_AG_ATTEST_DOC_CONT.AG_CONTRACT_HEADER_ID := rec_ag.AG_CONTRACT_HEADER_ID;
        var_AG_ATTEST_DOC_CONT.AG_STAT_AGENT_ID      := rec_ag.AG_ATTEST_PATH_ID;
        var_AG_ATTEST_DOC_CONT.IS_UP                 := rec_ag.IS_UP;
        var_AG_ATTEST_DOC_CONT.K_KD                  := 0;
        var_AG_ATTEST_DOC_CONT.K_KSP                 := 0;
        var_AG_ATTEST_DOC_CONT.K_SGP                 := 0;
        var_AG_ATTEST_DOC_CONT.NOTICE                := 'Автоматическое создание';
      
        ret := PKG_AGENT_ATTEST.InsertAgAttestDocCont(var_AG_ATTEST_DOC_CONT);
      
      END IF;
    
    END LOOP;
  
    /*
    EXECUTE IMMEDIATE
          'begin '|| rec.PACKAGE_NAME ||'.attest(:p_ag_roll_id); end;'
          USING in p_id;*/
  
  END CreateDocumentAttestBySgpRoll;

END pkg_agent_attest;
/

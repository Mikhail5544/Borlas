CREATE OR REPLACE PACKAGE pkg_agent_document AS

  PROCEDURE set_agent_report_status(doc_id IN NUMBER);

  FUNCTION CreateAgContractByAttestPath
  (
    p_ag_attest_path  NUMBER
   ,p_sales_chanel_id NUMBER
   ,p_agent_id        NUMBER
   ,p_date_start      DATE
   ,p_is_pbul         NUMBER
   ,p_is_call_center  NUMBER
   ,p_depatment       NUMBER
   ,p_new_ag_header   OUT NUMBER
   ,p_new_ag_contract OUT NUMBER
  ) RETURN NUMBER;

  FUNCTION CreateAgRollHeader
  (
    p_begin_date        DATE
   ,p_end_date          DATE
   ,p_ag_roll_type      NUMBER
   ,p_ag_roll_header_id OUT NUMBER
   ,p_ag_roll_id        OUT NUMBER
  ) RETURN NUMBER;

  FUNCTION CreateAgRoll
  (
    p_ag_roll_header_id IN NUMBER
   ,p_ag_roll_id        OUT NUMBER
  ) RETURN NUMBER;

  PROCEDURE IsAvailableCreateAgRoll(p_doc_id IN NUMBER);

  PROCEDURE SetAgRollHeaderStatusByAgRoll(p_doc_id IN NUMBER);

  /*
  Капля П.
  На переходе статусов Некомплект -> Проверено в ЦО
  Обнуление признака «Оригинал отсутствует» 
  */
  PROCEDURE NullDocOriginalMissing(par_document_id NUMBER);

  /*
  Капля П.
  На переходе статусов Некомплект -> В Архиве ЦО
  Обнуление признака «Оригинал отсутствует» 
  */
  PROCEDURE CheckDocumentPackage(par_document_id NUMBER);

  /*
  Капля П.
  На переходе статусов Проверено в ЦО -> Некомплект
  Создание комплекта необходимых документов для типа документа 
  */
  PROCEDURE CreateDocumentPackage(par_document_id NUMBER);

END pkg_agent_document;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent_document AS
  PROCEDURE set_agent_report_status(doc_id IN NUMBER) IS
    id              NUMBER;
    v_cover_obj_id  NUMBER;
    v_cover_ent_id  NUMBER;
    v_Oper_Templ_ID NUMBER;
    v_Is_Accepted   NUMBER;
    v_Amount        NUMBER;
    v_doc_status_id NUMBER;
    v_doc_status    DOC_STATUS%ROWTYPE;
  
    CURSOR c_Oper_Agent
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id oper_templ_id
            ,dsr.is_accepted
            ,arc.ent_id
            ,arc.agent_report_cont_id
            ,arc.comission_sum
        FROM AGENT_REPORT       ar
            ,AGENT_REPORT_CONT  arc
            ,DOC_ACTION_TYPE    dat
            ,DOCUMENT           d
            ,DOC_TEMPL          dt
            ,DOC_STATUS_ACTION  dsa
            ,DOC_STATUS_ALLOWED dsal
            ,DOC_TEMPL_STATUS   sdts
            ,DOC_TEMPL_STATUS   ddts
            ,DOC_STATUS_REF     dsr
            ,OPER_TEMPL         ot
            ,T_AG_AV            taa
       WHERE arc.agent_report_id = ar.agent_report_id
         AND ar.agent_report_id = doc_id
         AND d.document_id = ar.agent_report_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND ot.oper_templ_id = dsa.obj_uro_id
         AND ot.brief = 'МСФОВознаграждениеНачисленоАк'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND taa.T_AG_AV_ID = ar.T_AG_AV_ID
         AND taa.BRIEF NOT IN ('ОАВ');
  
  BEGIN
  
    v_doc_status_id := Doc.get_last_doc_status_id(doc_id);
    IF v_doc_status_id IS NOT NULL
    THEN
      SELECT * INTO v_doc_status FROM DOC_STATUS ds WHERE ds.doc_status_id = v_doc_status_id;
      -- создаем операции по шаблону
      OPEN c_Oper_Agent(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
      LOOP
        FETCH c_Oper_Agent
          INTO v_Oper_Templ_ID
              ,v_Is_Accepted
              ,v_Cover_Ent_ID
              ,v_Cover_Obj_ID
              ,v_Amount;
        EXIT WHEN c_Oper_Agent%NOTFOUND;
      
        IF (nvl(v_Amount, 0) != 0)
        THEN
          id := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID
                                            ,doc_id
                                            ,v_Cover_Ent_ID
                                            ,v_Cover_Obj_ID
                                            ,v_doc_status.doc_status_ref_id
                                            ,v_Is_Accepted
                                            ,v_Amount);
        END IF;
      END LOOP;
      CLOSE c_Oper_Agent;
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
  END set_agent_report_status;

  FUNCTION CreateAgContractByAttestPath
  (
    p_ag_attest_path  NUMBER
   ,p_sales_chanel_id NUMBER
   ,p_agent_id        NUMBER
   ,p_date_start      DATE
   ,p_is_pbul         NUMBER
   ,p_is_call_center  NUMBER
   ,p_depatment       NUMBER
   ,p_new_ag_header   OUT NUMBER
   ,p_new_ag_contract OUT NUMBER
  ) RETURN NUMBER IS
    VP_AG_ATTEST_PATH VEN_AG_ATTEST_PATH%ROWTYPE;
    v_ret             NUMBER;
    vc_ag_contract    ven_ag_contract%ROWTYPE;
    p_stat_hist       VEN_AG_STAT_HIST%ROWTYPE;
    p_stat            VEN_AG_STAT_AGENT%ROWTYPE;
    i                 INT;
  BEGIN
  
    VP_AG_ATTEST_PATH := pkg_agent_attest.GetAgAttestPath(p_ag_attest_path);
  
    v_ret := pkg_agent.CreateContractHeadByTemplId(VP_AG_ATTEST_PATH.ag_templ_header_id
                                                  ,p_sales_chanel_id
                                                  ,p_date_start
                                                  ,p_agent_id
                                                  ,p_new_ag_header
                                                  ,p_new_ag_contract);
  
    vc_ag_contract := pkg_agent.GetAgContract(p_new_ag_contract);
    p_stat         := pkg_agent_attest.GetAgStatAgent(VP_AG_ATTEST_PATH.TO_STAT_ID);
  
    p_stat_hist.ag_category_agent_id  := p_stat.AG_CATEGORY_AGENT_ID;
    p_stat_hist.ag_contract_header_id := p_new_ag_header;
    p_stat_hist.ag_contract_id        := p_new_ag_contract;
    p_stat_hist.ag_stat_agent_id      := p_stat.AG_STAT_AGENT_ID;
    p_stat_hist.k_kd                  := 0;
    p_stat_hist.k_ksp                 := 0;
    p_stat_hist.k_sgp                 := 0;
    p_stat_hist.num                   := 0;
    p_stat_hist.stat_date             := p_date_start;
  
    v_ret := pkg_agent_attest.InsertAgStatHistory(p_stat_hist);
  
    IF (v_ret != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    --        VP_AG_ATTEST_PATH.TO_STAT_ID
  
    /*
    if (vc_ag_contract.ag_contract_id is null) then
       return 0;
    end if;
    */
  
    vc_ag_contract.LEG_POS        := p_is_pbul;
    vc_ag_contract.IS_CALL_CENTER := p_is_call_center;
    vc_ag_contract.AGENCY_ID      := p_depatment;
    vc_ag_contract.DATE_BEGIN     := p_date_start;
    vc_ag_contract.num            := 0;
    vc_ag_contract.METHOD_PAYMENT := 0;
  
    v_ret := pkg_agent.UpdateContract(vc_ag_contract);
  
    IF (v_ret != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    --    commit;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END CreateAgContractByAttestPath;

  FUNCTION CreateAgRollHeader
  (
    p_begin_date        DATE
   ,p_end_date          DATE
   ,p_ag_roll_type      NUMBER
   ,p_ag_roll_header_id OUT NUMBER
   ,p_ag_roll_id        OUT NUMBER
  ) RETURN NUMBER IS
    ret         NUMBER;
    roll_header ven_ag_roll_header%ROWTYPE;
    roll        ven_ag_roll%ROWTYPE;
  BEGIN
  
    roll_header.NUM                  := PKG_AUTOSQ.NEXTVAL('AG_ROLL_HEADER', '');
    roll_header.REG_DATE             := SYSDATE;
    roll_header.AG_ROLL_TYPE_ID      := p_ag_roll_type;
    roll_header.DATE_BEGIN           := p_begin_date;
    roll_header.DATE_END             := p_end_date;
    roll_header.DOC_TEMPL_ID         := PKG_AGENT_UTILS.GetDocTemplAgRollHeader;
    roll_header.AG_CATEGORY_AGENT_ID := pkg_ag_roll.GetAgRollType(p_ag_roll_type).AGENT_CATEGORY_ID;
  
    ret := pkg_ag_roll.InsertAgRollHeader(roll_header);
  
    IF (ret != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    DOC.SET_DOC_STATUS(roll_header.AG_ROLL_HEADER_ID, 'NEW', SYSDATE, 'AUTO', '');
  
    roll.AG_ROLL_HEADER_ID := roll_header.AG_ROLL_HEADER_ID;
    roll.USER_NAME         := USER;
    roll.REG_DATE          := SYSDATE;
    roll.NUM               := PKG_AUTOSQ.NEXTVAL('AG_ROLL'
                                                ,'%N_AG_ROLL_HEADER:' || roll.AG_ROLL_HEADER_ID);
    roll.DOC_TEMPL_ID      := PKG_AGENT_UTILS.GetDocTemplAgRoll;
  
    ret := pkg_ag_roll.InsertAgRoll(roll);
  
    IF (ret != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    DOC.SET_DOC_STATUS(roll.AG_ROLL_ID, 'NEW', SYSDATE, 'AUTO', '');
  
    p_ag_roll_header_id := roll_header.ag_roll_header_id;
    p_ag_roll_id        := roll.ag_roll_id;
  
    RETURN Utils.c_true;
  
  END CreateAgRollHeader;

  FUNCTION CreateAgRoll
  (
    p_ag_roll_header_id IN NUMBER
   ,p_ag_roll_id        OUT NUMBER
  ) RETURN NUMBER IS
    roll ven_ag_roll%ROWTYPE;
    ret  NUMBER;
  BEGIN
  
    roll.AG_ROLL_HEADER_ID := p_ag_roll_header_id;
    roll.USER_NAME         := USER;
    roll.REG_DATE          := SYSDATE;
    roll.NUM               := PKG_AUTOSQ.NEXTVAL('AG_ROLL'
                                                ,'%N_AG_ROLL_HEADER:' || roll.AG_ROLL_HEADER_ID);
    roll.DOC_TEMPL_ID      := PKG_AGENT_UTILS.GetDocTemplAgRoll;
  
    ret := pkg_ag_roll.InsertAgRoll(roll);
  
    IF (ret != Utils.c_true)
    THEN
      RETURN Utils.c_false;
    END IF;
  
    DOC.SET_DOC_STATUS(roll.AG_ROLL_ID, 'NEW', SYSDATE, 'AUTO', '');
    p_ag_roll_id := roll.AG_ROLL_ID;
    RETURN Utils.c_true;
  
  END CreateAgRoll;

  PROCEDURE IsAvailableCreateAgRoll(p_doc_id IN NUMBER) IS
  
    CURSOR cur(cv_ag_roll_id NUMBER) IS
      SELECT *
        FROM (SELECT SUM(1) over(PARTITION BY AR.AG_ROLL_HEADER_ID ORDER BY AR.AG_ROLL_ID ASC) AS CNUM
                    ,SUM(1) over(PARTITION BY AR.AG_ROLL_HEADER_ID) AS CCOUNT
                    ,DOC.GET_LAST_DOC_STATUS_BRIEF(AR.AG_ROLL_ID) AS STATUS_NAME
                FROM ven_AG_ROLL ar
                    ,ven_AG_ROLL ar2
               WHERE AR.AG_ROLL_HEADER_ID = AR2.AG_ROLL_HEADER_ID
                 AND AR2.AG_ROLL_ID = cv_ag_roll_id) a
       WHERE a.CNUM = a.CCOUNT - 1;
  
    rec cur%ROWTYPE;
  
  BEGIN
  
    OPEN cur(p_doc_id);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN;
    END IF;
  
    CLOSE cur;
  
    IF (rec.STATUS_NAME != 'PRINTED')
    THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Нельзя создавать версию ведомости расчета вознаграждений агентам, т.к. предыдущая версия не в статусе "Напечатан"');
    END IF;
  
  END IsAvailableCreateAgRoll;

  PROCEDURE SetAgRollHeaderStatusByAgRoll(p_doc_id IN NUMBER) IS
    ag_roll_status_id NUMBER;
    v_ven_ag_roll     ven_ag_roll%ROWTYPE := pkg_ag_roll.GetAgRoll(p_doc_id);
  BEGIN
  
    ag_roll_status_id := DOC.GET_DOC_STATUS_BRIEF(p_doc_id);
  
    DOC.SET_DOC_STATUS(p_doc_id                => v_ven_ag_roll.AG_ROLL_HEADER_ID
                      ,p_status_id             => ag_roll_status_id
                      ,p_status_date           => SYSDATE
                      ,p_status_change_type_id => 2
                      ,p_note                  => 'Автоматическое выставление статуса по версии документа.');
  
  END;

  /*
  Капля П.
  На переходе статусов Некомплект -> Проверено в ЦО
  Обнуление признака «Оригинал отсутствует» 
  */
  PROCEDURE NullDocOriginalMissing(par_document_id NUMBER) IS
  BEGIN
/*    UPDATE ag_document_elements de
       SET de.missing_original = 0
     WHERE de.ag_documents_id = par_document_id;*/
    DELETE FROM ag_document_elements de WHERE de.ag_documents_id = par_document_id;
  END;

  /*
  Капля П.
  На переходе статусов Некомплект -> В Архиве ЦО
  Обнуление признака «Оригинал отсутствует» 
  */
  PROCEDURE CheckDocumentPackage(par_document_id NUMBER) IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM ag_document_elements de
     WHERE de.ag_documents_id = par_document_id
       AND de.missing_original != 0;
  
    IF v_count != 0
    THEN
      raise_application_error(-20001
                             ,'Внимание! Для данного документа обнаружено отсутствие одного из оригиналов комплекта, переход статусов запрещен.');
    END IF;
  
  END;

  /*
  Капля П.
  На переходе статусов Проверено в ЦО -> Некомплект
  Создание комплекта необходимых документов для типа документа 
  */
  PROCEDURE CreateDocumentPackage(par_document_id NUMBER) IS
    v_count NUMBER;
  BEGIN
  
    INSERT INTO ven_ag_document_elements
      (ag_doc_type_element_id, ag_documents_id)
      SELECT el.ag_doc_type_element_id
            ,ad.ag_documents_id
        FROM ag_documents        ad
            ,ag_doc_type_element el
       WHERE el.ag_doc_type_id = ad.ag_doc_type_id
         AND ad.ag_documents_id = par_document_id
         AND NOT EXISTS (SELECT NULL
                FROM ag_document_elements de
               WHERE de.ag_documents_id = ad.ag_documents_id
                 AND de.ag_doc_type_element_id = el.ag_doc_type_element_id);
  
  END;

END pkg_agent_document;
/

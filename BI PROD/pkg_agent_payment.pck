CREATE OR REPLACE PACKAGE pkg_agent_payment IS

  PROCEDURE FillTransByAgRoll(doc_id NUMBER);

END pkg_agent_payment;
/
CREATE OR REPLACE PACKAGE BODY pkg_agent_payment IS

  PROCEDURE FillTransByAgRoll(doc_id NUMBER) AS
    ID              NUMBER;
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
            ,APW_COVER.ent_id
            ,APW_COVER.AG_PERF_WORK_DCOVER_ID
            ,APW_COVER.SUMM
        FROM AG_ROLL
            ,AG_PERFOMED_WORK_ACT apw_act
            ,AG_PERFOM_WORK_DET   apw_det
            ,AG_PERFOM_WORK_DPOL  apw_pol
            ,AG_PERF_WORK_DCOVER  apw_cover
            ,DOC_ACTION_TYPE      dat
            ,DOCUMENT             d
            ,DOC_TEMPL            dt
            ,DOC_STATUS_ACTION    dsa
            ,DOC_STATUS_ALLOWED   dsal
            ,DOC_TEMPL_STATUS     sdts
            ,DOC_TEMPL_STATUS     ddts
            ,DOC_STATUS_REF       dsr
            ,OPER_TEMPL           ot
       WHERE d.document_id = AG_ROLL.AG_ROLL_ID
         AND APW_ACT.AG_ROLL_ID = AG_ROLL.AG_ROLL_ID
         AND APW_DET.AG_PERFOMED_WORK_ACT_ID = APW_ACT.AG_PERFOMED_WORK_ACT_ID
         AND APW_POL.AG_PERFOM_WORK_DET_ID = APW_DET.AG_PERFOM_WORK_DET_ID
         AND APW_COVER.AG_PERF_WORK_DPOL_ID = APW_POL.AG_PERFOM_WORK_DPOL_ID
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.doc_templ_id = sdts.doc_templ_id
         AND dt.doc_templ_id = ddts.doc_templ_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND ot.oper_templ_id = dsa.obj_uro_id
         AND ot.brief = 'НачКВАгент'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id
         AND AG_ROLL.AG_ROLL_ID = doc_id;
  
  BEGIN
  
    -- создание операций(проводок) для этого статуса документа
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
          ID := Acc_New.Run_Oper_By_Template(v_Oper_Templ_ID
                                            ,doc_id
                                            ,v_Cover_Ent_ID
                                            ,v_Cover_Obj_ID
                                            ,v_doc_status.doc_status_ref_id
                                            ,v_Is_Accepted
                                            ,v_Amount);
        END LOOP;
        CLOSE c_Oper_Agent;
      END IF;
    END;
  
  END FillTransByAgRoll;

END pkg_agent_payment;
/

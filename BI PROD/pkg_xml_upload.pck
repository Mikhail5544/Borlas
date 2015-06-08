CREATE OR REPLACE PACKAGE pkg_xml_upload AS
  /******************************************************************************
     Пакет для написания процедур выгрузки/загрузки объектов БД
  ******************************************************************************/

  /**
  * Выгрузка шаблонов банковских счетов df
  * @author Сыровецкий Д.
  * @param P_OBJ_ID ID объекта
  * @param P_XML_ID ID выгрузки
  * @param FLG_INNER Флаг внутренней загрузки
  */
  PROCEDURE account_save
  (
    p_obj_id  IN NUMBER
   ,p_xml_id  OUT NUMBER
   ,flg_inner IN NUMBER DEFAULT 0
  );

  /**
  * Выгрузка шаблонов шаблона проводки
  * @author Сыровецкий Д.
  * @param P_OBJ_ID ID объекта
  * @param P_XML_ID ID выгрузки
  * @param FLG_UPLOAD_ACCOUNT Флаг признаки выгрузки счетов
  * @param FLG_INNER Флаг внутренней загрузки
  */
  PROCEDURE trans_templ_save
  (
    p_obj_id           IN NUMBER
   ,p_xml_id           OUT NUMBER
   ,flg_upload_account IN NUMBER DEFAULT 0
   ,flg_inner          IN NUMBER DEFAULT 0
  );

  /**
  * Выгрузка шаблонов операций
  * @author Сыровецкий Д.
  * @param P_OBJ_ID ID объекта
  * @param P_XML_ID ID выгрузки
  * @param FLG_UPLOAD_TRANS_TEMPL Флаг признака выгрузки шаблона проводок
  * @param FLG_UPLOAD_ACCOUNT Флаг признаки выгрузки счетов
  * @param FLG_INNER Флаг внутренней загрузки
  */
  PROCEDURE oper_templ_save
  (
    p_obj_id               IN NUMBER
   ,p_xml_id               OUT NUMBER
   ,flg_upload_trans_templ IN NUMBER DEFAULT 0
   ,flg_upload_account     IN NUMBER DEFAULT 0
   ,flg_inner              IN NUMBER DEFAULT 0
  );

  /**
  * Выгрузка шаблона документа
  * @author Сыровецкий Д.
  * @param P_OBJ_ID ID объекта
  * @param P_XML_ID ID выгрузки
  * @param FLG_UPLOAD_OPER_TEMPL Флаг признака выгрузки шаблона операции
  * @param FLG_UPLOAD_TRANS_TEMPL Флаг признака выгрузки шаблона проводок
  * @param FLG_UPLOAD_ACCOUNT Флаг признаки выгрузки счетов
  */
  PROCEDURE doc_templ_save
  (
    p_obj_id               IN NUMBER
   ,p_xml_id               OUT NUMBER
   ,flg_upload_oper_templ  IN NUMBER DEFAULT 0
   ,flg_upload_trans_templ IN NUMBER DEFAULT 0
   ,flg_upload_account     IN NUMBER DEFAULT 0
  );

  /**
  * Ппроверка привязки операции к зачету
  * @author Сыровецкий Д.
  * @param P_OT_ID ID операции
  */
  PROCEDURE set_off_oper_save(p_ot_id IN NUMBER);

END pkg_xml_upload;
/
CREATE OR REPLACE PACKAGE BODY pkg_xml_upload AS
  /******************************************************************************
     Пакет для написания процедур выгрузки/загрузки объектов БД
  ******************************************************************************/

  x               NUMBER;
  st              NUMBER;
  flg_run_set_off NUMBER := 0;

  PROCEDURE account_save
  (
    p_obj_id  IN NUMBER
   ,p_xml_id  OUT NUMBER
   ,flg_inner IN NUMBER DEFAULT 0
  ) IS
    v_a account%ROWTYPE;
  BEGIN
    IF flg_inner = 0
    THEN
      ENT_IO.open_xml(x);
      p_xml_id := x;
    END IF;
  
    SELECT * INTO v_a FROM account WHERE account_id = p_obj_id;
  
    --выгрузка аналитик
    IF v_a.a1_analytic_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ANALYTIC_TYPE'), v_a.a1_analytic_type_id, x, NULL, st);
    END IF;
    IF v_a.a2_analytic_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ANALYTIC_TYPE'), v_a.a2_analytic_type_id, x, NULL, st);
    END IF;
    IF v_a.a3_analytic_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ANALYTIC_TYPE'), v_a.a3_analytic_type_id, x, NULL, st);
    END IF;
    IF v_a.a4_analytic_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ANALYTIC_TYPE'), v_a.a4_analytic_type_id, x, NULL, st);
    END IF;
    IF v_a.a5_analytic_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ANALYTIC_TYPE'), v_a.a5_analytic_type_id, x, NULL, st);
    END IF;
  
    ENT_IO.append_to_XML(ent.id_by_brief('ACCOUNT'), p_obj_id, x, NULL, st);
  
    IF flg_inner = 0
    THEN
      ENT_IO.close_xml(x);
    END IF;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE trans_templ_save
  (
    p_obj_id           IN NUMBER
   ,p_xml_id           OUT NUMBER
   ,flg_upload_account IN NUMBER DEFAULT 0
   ,flg_inner          IN NUMBER DEFAULT 0
  ) IS
  
    v_tr  trans_templ%ROWTYPE;
    tmp_x NUMBER;
  
  BEGIN
  
    IF flg_inner = 0
    THEN
      ENT_IO.open_xml(x);
      p_xml_id := x;
    END IF;
  
    SELECT * INTO v_tr FROM trans_templ WHERE trans_templ_id = p_obj_id;
  
    --выгрузка счетов
    IF flg_upload_account = 1
    THEN
      IF v_tr.dt_account_id IS NOT NULL
      THEN
        account_save(v_tr.dt_account_id, tmp_x, 1);
      END IF;
      IF v_tr.ct_account_id IS NOT NULL
      THEN
        account_save(v_tr.ct_account_id, tmp_x, 1);
      END IF;
    END IF;
  
    --выгрузка правил формирования счетов
    IF v_tr.DT_ACC_DEF_RULE_ID IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ACC_DEF_RULE'), v_tr.DT_ACC_DEF_RULE_ID, x, NULL, st);
    END IF;
  
    IF v_tr.ct_ACC_DEF_RULE_ID IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('ACC_DEF_RULE'), v_tr.ct_ACC_DEF_RULE_ID, x, NULL, st);
    END IF;
  
    --выгрузка различных типов сумм, валют, дат
    IF v_tr.date_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('DATE_TYPE'), v_tr.date_type_id, x, NULL, st);
    END IF;
  
    IF v_tr.fund_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('FUND_TYPE'), v_tr.fund_type_id, x, NULL, st);
    END IF;
  
    IF v_tr.summ_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('SUMM_TYPE'), v_tr.summ_type_id, x, NULL, st);
    END IF;
  
    IF v_tr.summ_fund_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('FUND_TYPE'), v_tr.summ_fund_type_id, x, NULL, st);
    END IF;
  
    IF v_tr.qty_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('SUMM_TYPE'), v_tr.qty_type_id, x, NULL, st);
    END IF;
  
    ENT_IO.append_to_XML(ent.ID_BY_BRIEF('TRANS_TEMPL'), p_obj_id, x, NULL, st);
  
    IF flg_inner = 0
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE oper_templ_save
  (
    p_obj_id               IN NUMBER
   ,p_xml_id               OUT NUMBER
   ,flg_upload_trans_templ IN NUMBER DEFAULT 0
   ,flg_upload_account     IN NUMBER DEFAULT 0
   ,flg_inner              IN NUMBER DEFAULT 0
  ) IS
    v_ot  oper_templ%ROWTYPE;
    tmp_x NUMBER;
  
  BEGIN
  
    IF flg_inner = 0
    THEN
      ENT_IO.open_xml(x);
      p_xml_id := x;
    END IF;
  
    SELECT * INTO v_ot FROM oper_templ WHERE oper_templ_id = p_obj_id;
  
    IF v_ot.date_type_id IS NOT NULL
    THEN
      ENT_IO.append_to_XML(ent.id_by_brief('DATE_TYPE'), v_ot.date_type_id, x, NULL, st);
    END IF;
  
    ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), p_obj_id, x, NULL, st);
  
    IF flg_upload_trans_templ = 1
    THEN
      FOR cur IN (SELECT rott.trans_templ_id
                        ,tt.name
                        ,rott.rel_oper_trans_templ_id
                    FROM rel_oper_trans_templ rott
                        ,trans_templ          tt
                   WHERE rott.oper_templ_id = v_ot.oper_templ_id
                     AND tt.trans_templ_id = rott.trans_templ_id)
      LOOP
      
        trans_templ_save(cur.trans_templ_id, tmp_x, flg_upload_account, 1);
      
        ENT_IO.append_to_XML(ent.ID_BY_BRIEF('REL_OPER_TRANS_TEMPL')
                            ,cur.rel_oper_trans_templ_id
                            ,x
                            ,NULL
                            ,st);
      END LOOP;
    
    END IF;
  
    IF flg_inner = 0
    THEN
      ENT_IO.close_xml(x);
    END IF;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE doc_templ_save
  (
    p_obj_id               IN NUMBER
   ,p_xml_id               OUT NUMBER
   ,flg_upload_oper_templ  IN NUMBER DEFAULT 0
   ,flg_upload_trans_templ IN NUMBER DEFAULT 0
   ,flg_upload_account     IN NUMBER DEFAULT 0
  ) IS
    v_dt  doc_templ%ROWTYPE;
    tmp_x NUMBER;
  BEGIN
  
    ENT_IO.open_xml(x);
    p_xml_id := x;
  
    SELECT * INTO v_dt FROM doc_templ WHERE doc_templ_id = p_obj_id;
  
    --проверка наличия статуса  
    FOR cur IN (SELECT dts.doc_templ_status_id dts_id
                      ,dsr.DOC_STATUS_REF_ID   dsr_id
                  FROM doc_templ_status dts
                      ,doc_status_ref   dsr
                 WHERE dts.doc_templ_id = v_dt.doc_templ_id
                   AND dsr.DOC_STATUS_REF_ID = dts.DOC_STATUS_REF_ID
                 ORDER BY dts.ORDER_NUM)
    LOOP
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_STATUS_REF'), cur.dsr_id, x, NULL, st);
    
    END LOOP;
  
    --создание шаблона документа
    ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_TEMPL'), v_dt.doc_templ_id, x, NULL, st);
  
    --проверка связи статуса с шаблоном
    FOR cur IN (SELECT dts.doc_templ_status_id dts_id
                  FROM doc_templ_status dts
                 WHERE dts.doc_templ_id = v_dt.doc_templ_id
                 ORDER BY dts.ORDER_NUM)
    LOOP
    
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_TEMPL_STATUS'), cur.dts_id, x, NULL, st);
    END LOOP;
  
    FOR cur IN (SELECT dsa.doc_status_allowed_id dsa_id
                  FROM doc_templ_status   dts
                      ,doc_status_allowed dsa
                 WHERE dts.doc_templ_id = p_obj_id
                   AND dsa.DEST_DOC_TEMPL_STATUS_ID = dts.DOC_TEMPL_STATUS_ID)
    LOOP
    
      --выгрузка разрешенных статусов
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_STATUS_ALLOWED'), cur.dsa_id, x, NULL, st);
      FOR cur1 IN (SELECT dsa.doc_status_action_id
                         ,dp.doc_procedure_id
                     FROM DOC_STATUS_ACTION dsa
                         ,doc_action_type   dat
                         ,DOC_PROCEDURE     DP
                    WHERE dsa.doc_status_allowed_id = cur.dsa_id
                      AND dat.doc_action_type_id = dsa.doc_action_type_id
                      AND dat.brief = 'PROCEDURE'
                      AND dp.doc_procedure_id = dsa.obj_uro_id)
      LOOP
      
        --выгрузка связанных процедур
        ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_PROCEDURE'), cur1.doc_procedure_id, x, NULL, st);
      
        --привязка связанных процедур                    
        ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_STATUS_ACTION')
                            ,cur1.doc_status_action_id
                            ,x
                            ,NULL
                            ,st);
      
      END LOOP;
    
      FOR cur2 IN (SELECT dsa.doc_status_action_id
                         ,ot.oper_templ_id
                     FROM DOC_STATUS_ACTION dsa
                         ,doc_action_type   dat
                         ,oper_templ        ot
                    WHERE dsa.doc_status_allowed_id = cur.dsa_id
                      AND dat.doc_action_type_id = dsa.doc_action_type_id
                      AND dat.brief = 'OPER'
                      AND ot.oper_templ_id = dsa.obj_uro_id)
      LOOP
      
        IF flg_upload_oper_templ = 0
        THEN
          ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), cur2.oper_templ_id, x, NULL, st);
        ELSE
          oper_templ_save(cur2.oper_templ_id, tmp_x, flg_upload_trans_templ, flg_upload_account, 1);
        END IF;
      
        --привязка связанных процедур                    
        ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_STATUS_ACTION')
                            ,cur2.doc_status_action_id
                            ,x
                            ,NULL
                            ,st);
      
      END LOOP;
    
    END LOOP;
  
    --выгрузка платежной состовляющей
    FOR v_apt IN (SELECT * FROM ac_payment_templ apt WHERE apt.DOC_TEMPL_ID = p_obj_id)
    LOOP
    
      --выгрузка собственной операции
      IF v_apt.SELF_OPER_TEMPL_ID IS NOT NULL
      THEN
        IF flg_upload_oper_templ = 0
        THEN
          ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), v_apt.SELF_OPER_TEMPL_ID, x, NULL, st);
        ELSE
          oper_templ_save(v_apt.SELF_OPER_TEMPL_ID
                         ,tmp_x
                         ,flg_upload_trans_templ
                         ,flg_upload_account
                         ,1);
        END IF;
      END IF;
    
      --выгрузка операции по зачету
      IF v_apt.DSO_OPER_TEMPL_ID IS NOT NULL
      THEN
        IF flg_upload_oper_templ = 0
        THEN
          ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), v_apt.DSO_OPER_TEMPL_ID, x, NULL, st);
        ELSE
          oper_templ_save(v_apt.DSO_OPER_TEMPL_ID
                         ,tmp_x
                         ,flg_upload_trans_templ
                         ,flg_upload_account
                         ,1);
        END IF;
      
        set_off_oper_save(v_apt.DSO_OPER_TEMPL_ID);
      
      END IF;
    
      --выгрузка операции по зачету агента
      IF v_apt.DSO_AG_OPER_TEMPL_ID IS NOT NULL
      THEN
        IF flg_upload_oper_templ = 0
        THEN
          ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), v_apt.DSO_AG_OPER_TEMPL_ID, x, NULL, st);
        ELSE
          oper_templ_save(v_apt.DSO_AG_OPER_TEMPL_ID
                         ,tmp_x
                         ,flg_upload_trans_templ
                         ,flg_upload_account
                         ,1);
        END IF;
      
        set_off_oper_save(v_apt.DSO_AG_OPER_TEMPL_ID);
      
      END IF;
    
      --выгузка самого шаблона
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('AC_PAYMENT_TEMPL'), v_apt.payment_templ_id, x, NULL, st);
    
      --выгрузка операций по зачету (список)
    
      FOR cur IN (SELECT * FROM REL_OPER_TEMPL_DSO WHERE doc_templ_id = p_obj_id)
      LOOP
      
        IF flg_upload_oper_templ = 0
        THEN
          ENT_IO.append_to_XML(ent.ID_BY_BRIEF('OPER_TEMPL'), cur.oper_templ_id, x, NULL, st);
        ELSE
          oper_templ_save(cur.oper_templ_id, tmp_x, flg_upload_trans_templ, flg_upload_account, 1);
        END IF;
      
        set_off_oper_save(cur.oper_templ_id);
      
        ENT_IO.append_to_XML(ent.ID_BY_BRIEF('REL_OPER_TEMPL_DSO')
                            ,cur.rel_oper_templ_dso_id
                            ,x
                            ,NULL
                            ,st);
      
      END LOOP;
    
    END LOOP;
  
    flg_run_set_off := 0;
  
    ENT_IO.close_xml(x);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE set_off_oper_save(p_ot_id IN NUMBER) IS
  
    v_dt_id NUMBER;
  
  BEGIN
  
    SELECT doc_templ_id INTO v_dt_id FROM doc_templ WHERE brief = 'ЗАЧПЛ';
  
    --создание шаблона документа ЗАЧПЛ
    IF flg_run_set_off = 0
    THEN
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_TEMPL'), v_dt_id, x, NULL, st);
      flg_run_set_off := 1;
    END IF;
  
    FOR cur IN (SELECT dts.DOC_STATUS_REF_ID        dsr_id1
                      ,dts1.DOC_STATUS_REF_ID       dsr_id2
                      ,dsa.DEST_DOC_TEMPL_STATUS_ID dsa_id1
                      ,dsa.SRC_DOC_TEMPL_STATUS_ID  dsa_id2
                      ,dsa.DOC_STATUS_ALLOWED_ID    dsa_id
                      ,dsac.DOC_STATUS_ACTION_ID    dsac_id
                  FROM doc_templ          dt
                      ,doc_templ_status   dts
                      ,doc_status_allowed dsa
                      ,doc_templ_status   dts1
                      ,doc_status_action  dsac
                      ,entity             e
                 WHERE dt.BRIEF = 'ЗАЧПЛ'
                   AND dts.doc_templ_id = dt.doc_templ_id
                   AND dsa.DEST_DOC_TEMPL_STATUS_ID = dts.DOC_TEMPL_STATUS_ID
                   AND dsac.DOC_STATUS_ALLOWED_ID = dsa.DOC_STATUS_ALLOWED_ID
                   AND dts1.DOC_TEMPL_STATUS_ID = dsa.SRC_DOC_TEMPL_STATUS_ID
                   AND e.brief = 'OPER_TEMPL'
                   AND dsac.OBJ_URE_ID = e.ent_id
                   AND dsac.OBJ_URO_ID = p_ot_id)
    LOOP
    
      --создание операции по зачету
      ENT_IO.append_to_XML(ent.ID_BY_BRIEF('DOC_STATUS_ACTION'), cur.dsac_id, x, NULL, st);
    
    END LOOP;
  END;

END pkg_xml_upload;
/

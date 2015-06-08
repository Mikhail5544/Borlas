CREATE OR REPLACE PACKAGE pkg_pd4 IS

  PROCEDURE create_pd4_copy(p_pd4_id IN NUMBER);
  PROCEDURE pd4_delete(p_pd4_id IN NUMBER);
  PROCEDURE pd4_update(p_pd4_id IN NUMBER);
  PROCEDURE set_pd4_copy_status(p_doc_id IN NUMBER);
  FUNCTION get_pd4_parent(p_copy_id IN NUMBER) RETURN NUMBER;
  PROCEDURE set_pd4_doc_status(p_doc_id IN NUMBER);
  /**
  * Удаляет зачет счета квитанцией ПД4(удаляется сам зачет, проводки, 
  * , удаляется сама ПД4)
  * Вызывается из формы оплаты договора
  * Если копия ПД4 зачтена то ПД4 не удаляется
  * @author Ф.Ганичев
  * @param p_pd4_id - ИД квитанции пд4
  */
  PROCEDURE delete_pd4_setoff
  (
    p_pd4_id     NUMBER
   ,p_set_off_id NUMBER
  );
  FUNCTION get_pd4_dso(p_pd4_id NUMBER) RETURN NUMBER;
END pkg_pd4;
/
CREATE OR REPLACE PACKAGE BODY pkg_pd4 IS

  FUNCTION get_pd4_parent(p_copy_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT d.document_id
                 FROM document  d
                     ,doc_doc   dd
                     ,doc_templ dt
                WHERE dt.brief = 'PD4'
                  AND dt.doc_templ_id = d.doc_templ_id
                  AND dd.parent_id = d.document_id
                  AND dd.child_id = p_copy_id)
    LOOP
      RETURN rc.document_id;
    END LOOP;
    RETURN p_copy_id;
  END;

  PROCEDURE create_pd4_copy(p_pd4_id IN NUMBER) IS
    v_pd4 ven_ac_payment%ROWTYPE;
    v_id  NUMBER;
  BEGIN
    -- данные квитанции а7
    SELECT * INTO v_pd4 FROM ven_ac_payment p WHERE p.payment_id = p_pd4_id;
  
    -- Ф. Ганичев
    v_pd4.rev_amount  := v_pd4.amount;
    v_pd4.rev_rate    := 1;
    v_pd4.rev_fund_id := v_pd4.fund_id;
  
    -- шаблон "копия а7"
    SELECT dt.doc_templ_id INTO v_pd4.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'PD4COPY';
  
    -- запоминаем ид а7
    v_id := v_pd4.payment_id;
  
    -- новый ид для копии
    SELECT sq_ac_payment.nextval INTO v_pd4.payment_id FROM dual;
    v_pd4.payment_direct_id := 1 - v_pd4.payment_direct_id;
    v_pd4.payment_type_id   := 1 - v_pd4.payment_type_id;
  
    -- добавляем копию
    INSERT INTO ven_ac_payment VALUES v_pd4;
  
    -- связь между квитанцией и копией
    INSERT INTO ven_doc_doc (parent_id, child_id) VALUES (v_id, v_pd4.payment_id);
  
  END;

  PROCEDURE pd4_delete(p_pd4_id IN NUMBER) IS
    v_paym_id NUMBER;
  BEGIN
  
    BEGIN
      SELECT d.document_id
        INTO v_paym_id
        FROM doc_doc   dd
            ,document  d
            ,doc_templ dt
       WHERE dd.parent_id = p_pd4_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PD4COPY';
      -- удалить копию
      /* удаление изменено по заявке 288235: ошибка при удалении ПД4
      DELETE FROM ac_payment p
       WHERE p.payment_id = v_paym_id;
      DELETE FROM document d
       WHERE d.document_id = v_paym_id;*/
    
      DELETE FROM ven_ac_payment p WHERE p.payment_id = v_paym_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  END;

  PROCEDURE pd4_update(p_pd4_id IN NUMBER) IS
    v_pd4 ven_ac_payment%ROWTYPE;
  BEGIN
    -- данные квитанции а7
    SELECT * INTO v_pd4 FROM ven_ac_payment p WHERE p.payment_id = p_pd4_id;
  
    -- ид копии
    SELECT d.document_id
      INTO v_pd4.payment_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_pd4_id
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'PD4COPY';
  
    -- изменении копии
    UPDATE ven_ac_payment p
       SET (filial_id
          ,note
          ,num
          ,reg_date
          ,amount
          ,a7_contact_id
          ,collection_metod_id
          ,comm_amount
          ,company_bank_acc_id
          ,contact_bank_acc_id
          ,contact_id
          ,date_ext
          ,due_date
          ,fund_id
          ,grace_date
          ,is_agent
          ,num_ext
          ,payment_direct_id
          ,payment_number
          ,payment_templ_id
          ,payment_terms_id
          ,payment_type_id
          ,real_pay_date
          ,rev_amount
          ,rev_fund_id
          ,rev_rate
          ,rev_rate_type_id) =
           (SELECT v_pd4.filial_id
                  ,v_pd4.note
                  ,num
                  ,v_pd4.reg_date
                  ,v_pd4.amount
                  ,v_pd4.a7_contact_id
                  ,v_pd4.collection_metod_id
                  ,v_pd4.comm_amount
                  ,v_pd4.company_bank_acc_id
                  ,v_pd4.contact_bank_acc_id
                  ,v_pd4.contact_id
                  ,v_pd4.date_ext
                  ,v_pd4.due_date
                  ,v_pd4.fund_id
                  ,v_pd4.grace_date
                  ,v_pd4.is_agent
                  ,v_pd4.num_ext
                  ,1 - v_pd4.payment_direct_id
                  ,v_pd4.payment_number
                  ,v_pd4.payment_templ_id
                  ,v_pd4.payment_terms_id
                  ,1 - v_pd4.payment_type_id
                  ,v_pd4.real_pay_date
                  ,v_pd4.amount
                  ,v_pd4.fund_id
                  ,1
                  ,v_pd4.rev_rate_type_id
              FROM dual)
     WHERE p.payment_id = v_pd4.payment_id;
  
  END;

  PROCEDURE set_pd4_copy_status(p_doc_id IN NUMBER) IS
    v_status                NUMBER;
    v_id                    NUMBER;
    v_status_change_type_id NUMBER;
  BEGIN
    v_status := doc.get_last_doc_status_id(p_doc_id);
  
    SELECT d.document_id
      INTO v_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_doc_id
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'PD4COPY';
  
    SELECT t.status_change_type_id
      INTO v_status_change_type_id
      FROM status_change_type t
     WHERE t.brief = 'AUTO';
  
    FOR rc IN (SELECT * FROM doc_status ds WHERE ds.doc_status_id = v_status)
    LOOP
    
      doc.set_doc_status(p_doc_id                   => v_id
                        ,p_status_brief             => 'TO_PAY'
                        ,p_status_date              => rc.start_date
                        ,p_status_change_type_brief => 'AUTO'
                        ,p_note                     => rc.note);
    END LOOP;
  END;

  PROCEDURE set_pd4_doc_status(p_doc_id IN NUMBER) IS
    id                NUMBER;
    v_cover_obj_id    NUMBER;
    v_cover_ent_id    NUMBER;
    v_oper_templ_id   NUMBER;
    v_is_accepted     NUMBER;
    v_count           NUMBER;
    v_oper_count      NUMBER;
    v_amount          NUMBER;
    v_total_amount    NUMBER;
    v_oper_amount     NUMBER;
    v_doc_status_id   NUMBER;
    v_doc_status      doc_status%ROWTYPE;
    v_doc_status_ref  doc_status_ref%ROWTYPE;
    v_doc_templ_brief VARCHAR2(30);
    v_doc_amount      NUMBER;
    v_real_amount     NUMBER;
    v_plan_amount     NUMBER;
    v_doc_id          NUMBER := pkg_pd4.get_pd4_parent(p_doc_id);
  
    CURSOR c_oper
    (
      cp_src_dsr_id NUMBER
     ,cp_dst_dsr_id NUMBER
    ) IS
      SELECT dsa.obj_uro_id  oper_templ_id
            ,dsr.is_accepted
            ,c.ent_id
            ,c.p_cover_id
            ,c.premium       amount
            ,0               plan_amount
        FROM ven_ac_payment d
            ,doc_set_off    dso
            ,
             --ac_payment ap,
             doc_doc dd
            ,
             --ven_bso            b,
             p_policy           p
            ,as_asset           ass
            ,status_hist        sh
            ,p_cover            c
            ,doc_status_action  dsa
            ,doc_action_type    dat
            ,doc_status_allowed dsal
            ,doc_templ_status   sdts
            ,doc_templ_status   ddts
            ,doc_status_ref     dsr
       WHERE d.payment_id = p_doc_id
         AND dso.child_doc_id = v_doc_id
         AND dd.child_id = dso.parent_doc_id
         AND dd.parent_id = p.policy_id
            --AND b.document_id = v_doc_id
            --AND b.policy_id = p.policy_id
         AND ass.p_policy_id = p.policy_id
         AND ass.status_hist_id = sh.status_hist_id(+)
         AND sh.brief IN ('NEW', 'CURRENT')
         AND c.as_asset_id = ass.as_asset_id
         AND d.doc_templ_id = sdts.doc_templ_id
         AND d.doc_templ_id = ddts.doc_templ_id
         AND dsa.doc_action_type_id = dat.doc_action_type_id
         AND dat.brief = 'OPER'
         AND dsa.is_execute = 0
         AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
         AND sdts.doc_status_ref_id = cp_src_dsr_id
         AND ddts.doc_status_ref_id = cp_dst_dsr_id
         AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
         AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
         AND ddts.doc_status_ref_id = dsr.doc_status_ref_id;
  BEGIN
    v_doc_status_id := doc.get_last_doc_status_id(p_doc_id);
  
    IF v_doc_status_id IS NOT NULL
    THEN
      SELECT * INTO v_doc_status FROM doc_status ds WHERE ds.doc_status_id = v_doc_status_id;
    
      SELECT *
        INTO v_doc_status_ref
        FROM doc_status_ref dsr
       WHERE dsr.doc_status_ref_id = v_doc_status.doc_status_ref_id;
    
      BEGIN
        SELECT dt.brief
          INTO v_doc_templ_brief
          FROM document  d
              ,doc_templ dt
         WHERE d.document_id = p_doc_id
           AND d.doc_templ_id = dt.doc_templ_id
           AND dt.brief IN ('PD4COPY');
      EXCEPTION
        WHEN OTHERS THEN
          v_doc_templ_brief := NULL;
      END;
    
      -- создание операций(проводок) для этого статуса документа
      BEGIN
        IF v_doc_templ_brief IS NOT NULL
        THEN
          ---------------------------------- Pavel A. Mikushin в рамках заявки №39585
          SELECT ap.amount INTO v_doc_amount FROM ac_payment ap WHERE ap.payment_id = p_doc_id;
        
          BEGIN
            SAVEPOINT cre_trans;
          
            --Берём за основу проводки ЭПГ
            FOR x IN (SELECT o.oper_id
                            ,o.name
                            ,t.trans_id
                            ,(SELECT dsa.obj_uro_id
                                FROM document           d
                                    ,doc_status_action  dsa
                                    ,doc_action_type    dat
                                    ,doc_status_allowed dsal
                                    ,doc_templ_status   sdts
                                    ,doc_templ_status   ddts
                               WHERE dsa.doc_action_type_id = dat.doc_action_type_id
                                 AND dat.brief = 'OPER'
                                 AND dsa.is_execute = 0
                                 AND d.doc_templ_id = sdts.doc_templ_id
                                 AND d.doc_templ_id = ddts.doc_templ_id
                                 AND dsa.doc_status_allowed_id = dsal.doc_status_allowed_id
                                 AND sdts.doc_status_ref_id = v_doc_status.src_doc_status_ref_id
                                 AND ddts.doc_status_ref_id = v_doc_status.doc_status_ref_id
                                 AND dsal.src_doc_templ_status_id = sdts.doc_templ_status_id
                                 AND dsal.dest_doc_templ_status_id = ddts.doc_templ_status_id
                                 AND d.document_id = p_doc_id) oper_templ_id
                            ,t.obj_ure_id
                            ,t.obj_uro_id
                            ,ROUND(CASE plo.description
                                     WHEN 'Административные издержки' THEN
                                      t.trans_amount - nvl(old_t.trans_amount, 0)
                                     ELSE
                                      t.trans_amount *
                                      (v_doc_amount - SUM(CASE plo.description
                                                            WHEN 'Административные издержки' THEN
                                                             t.trans_amount - nvl(old_t.trans_amount, 0)
                                                            ELSE
                                                             0
                                                          END) over()) /
                                      SUM(CASE plo.description
                                            WHEN 'Административные издержки' THEN
                                             0
                                            ELSE
                                             t.trans_amount
                                          END) over()
                                   END
                                  ,2) trans_amount
                        FROM oper o
                            ,trans t
                            ,doc_set_off dso
                            ,trans_templ tt
                            ,doc_doc dd
                            ,t_prod_line_option plo
                            ,p_cover c
                            ,(SELECT tt.trans_amount
                                    ,tt.obj_uro_id
                                FROM oper  oo
                                    ,trans tt
                               WHERE tt.oper_id = oo.oper_id
                                 AND oo.document_id = p_doc_id) old_t
                       WHERE o.oper_id = t.oper_id
                         AND o.document_id = dso.parent_doc_id
                         AND t.trans_templ_id = tt.trans_templ_id
                         AND dso.child_doc_id = dd.parent_id
                         AND plo.id = c.t_prod_line_option_id
                         AND c.p_cover_id = t.obj_uro_id
                         AND old_t.obj_uro_id(+) = t.obj_uro_id
                         AND dd.child_id = p_doc_id
                         AND tt.brief = 'ПремияНачисленаКОплате')
            LOOP
              IF x.oper_templ_id IS NOT NULL
              THEN
                id := acc_new.run_oper_by_template(x.oper_templ_id
                                                  ,p_doc_id
                                                  ,x.obj_ure_id
                                                  ,x.obj_uro_id
                                                  ,v_doc_status.doc_status_ref_id
                                                  ,1
                                                  ,x.trans_amount);
              END IF;
            END LOOP;
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK TO cre_trans;
              id := NULL;
          END;
        
          --Если ID не пустой - значит больше ничего делать не надо
          IF id IS NULL
          THEN
            --а если пустой - делаем как делалось раньше
            ----------------------------------
            v_count  := 0;
            v_amount := 0;
          
            OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
          
            LOOP
              FETCH c_oper
                INTO v_oper_templ_id
                    ,v_is_accepted
                    ,v_cover_ent_id
                    ,v_cover_obj_id
                    ,v_real_amount
                    ,v_plan_amount;
            
              EXIT WHEN c_oper%NOTFOUND;
            
              IF (v_real_amount > v_plan_amount)
              THEN
                v_count  := v_count + 1;
                v_amount := v_amount + v_real_amount - v_plan_amount;
              END IF;
            END LOOP;
          
            CLOSE c_oper;
          
            -- создаем операции по шаблону
            v_oper_count   := 0;
            v_total_amount := 0;
          
            OPEN c_oper(v_doc_status.src_doc_status_ref_id, v_doc_status.doc_status_ref_id);
          
            LOOP
              FETCH c_oper
                INTO v_oper_templ_id
                    ,v_is_accepted
                    ,v_cover_ent_id
                    ,v_cover_obj_id
                    ,v_real_amount
                    ,v_plan_amount;
            
              EXIT WHEN c_oper%NOTFOUND;
            
              IF (v_real_amount > v_plan_amount)
              THEN
                v_oper_count := v_oper_count + 1;
              
                IF v_oper_count <> v_count
                THEN
                  v_oper_amount  := (v_real_amount - v_plan_amount) * v_doc_amount / v_amount;
                  v_oper_amount  := ROUND(v_oper_amount * 100) / 100;
                  v_total_amount := v_total_amount + v_oper_amount;
                ELSE
                  v_oper_amount := v_doc_amount - v_total_amount;
                END IF;
              
                id := acc_new.run_oper_by_template(v_oper_templ_id
                                                  ,p_doc_id
                                                  ,v_cover_ent_id
                                                  ,v_cover_obj_id
                                                  ,v_doc_status.doc_status_ref_id
                                                  ,1
                                                  ,v_oper_amount);
              END IF;
            END LOOP;
          
            CLOSE c_oper;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    END IF;
  END set_pd4_doc_status;

  PROCEDURE delete_pd4_setoff
  (
    p_pd4_id     NUMBER
   ,p_set_off_id NUMBER
  ) IS
    v_bso_id   NUMBER;
    v_dso_id   NUMBER;
    v_d_num    VARCHAR2(100);
    v_dt_name  VARCHAR2(1000);
    v_d_date   VARCHAR2(100);
    v_d_amount NUMBER;
    v_d_fund   VARCHAR2(100);
  BEGIN
    -- Проверка. Есть ли зачет копии pd4
    v_dso_id := pkg_pd4.get_pd4_dso(p_pd4_id);
    IF v_dso_id IS NOT NULL
    THEN
      SELECT d.num
            ,dt.name
            ,to_char(d.reg_date, 'DD.MM.YYYY')
            ,d.amount
            ,f.brief
        INTO v_d_num
            ,v_dt_name
            ,v_d_date
            ,v_d_amount
            ,v_d_fund
        FROM ven_ac_payment d
            ,ven_doc_templ  dt
            ,fund           f
       WHERE d.payment_id = v_dso_id
         AND dt.doc_templ_id = d.doc_templ_id
         AND d.fund_id = f.fund_id;
      raise_application_error(-20100
                             ,'Ошибка удаления: есть зачитывающий документ ' || v_dt_name || ' №' ||
                              v_d_num || ' от ' || v_d_date || ' на сумму ' || v_d_amount || ' ' ||
                              v_d_fund);
    END IF;
  
    -- Удаляется зачет счета квитанцией pd4
    BEGIN
      pkg_payment.dso_before_delete(p_set_off_id);
      DELETE oper o WHERE o.document_id = p_set_off_id;
      DELETE ven_doc_set_off WHERE doc_set_off_id = p_set_off_id;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20100
                               ,'Ошибка удаления зачета ПД4: ' || SQLERRM);
    END;
    -- Удаляется pd4
    BEGIN
      -- Удаляются проводки по pd4
      DELETE oper o WHERE o.document_id = p_pd4_id;
      -- Удаляется Копия ПД4
      pd4_delete(p_pd4_id);
      -- Удаляется сама pd4
      DELETE ven_ac_payment WHERE payment_id = p_pd4_id;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20100
                               ,'Ошибка удаления квитанции ПД4: ' || SQLERRM);
    END;
  END;

  FUNCTION get_pd4_dso(p_pd4_id NUMBER) RETURN NUMBER IS
    v_pd4_copy_id NUMBER;
    v_dso_id      NUMBER;
  BEGIN
    BEGIN
      SELECT d.document_id
        INTO v_pd4_copy_id
        FROM doc_doc   dd
            ,document  d
            ,doc_templ dt
       WHERE dd.parent_id = p_pd4_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.brief = 'PD4COPY';
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
    BEGIN
      SELECT dso.child_doc_id
        INTO v_dso_id
        FROM doc_set_off dso
       WHERE dso.parent_doc_id = v_pd4_copy_id
         AND rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN NULL;
    END;
    RETURN v_dso_id;
  END;
END pkg_pd4;
/

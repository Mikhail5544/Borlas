CREATE OR REPLACE PACKAGE Pkg_A7 IS

  PROCEDURE create_a7_copy(p_a7_id IN NUMBER);
  PROCEDURE a7_delete(p_a7_id IN NUMBER);
  PROCEDURE a7_update(p_a7_id IN NUMBER);
  PROCEDURE set_a7_copy_status(p_doc_id IN NUMBER);
  FUNCTION get_a7_parent(p_copy_id IN NUMBER) RETURN NUMBER;
  /**
  * Возвращает ИД документа, зачитывающий копию передаваемой квитанции A7
  * @author Ф.Ганичев
  * @param p_a7_id - ИД квитанции A7
  */
  FUNCTION get_a7_dso(p_a7_id NUMBER) RETURN NUMBER;
  /*function get_doc_copy(p_doc_id number) return number;*/

  /**
  * Удаляет зачет счета квитанцией a7(удаляется сам зачет, проводки,
  * бланк a7 отвязывается от договора, удаляется сама a7)
  * Вызывается из формы оплаты договора
  * Если копия a7 зачтена то a7 не удаляется
  * @author Ф.Ганичев
  * @param p_a7_id - ИД квитанции A7
  */
  PROCEDURE delete_a7_setoff
  (
    p_a7_id      NUMBER
   ,p_set_off_id NUMBER
  );
  PROCEDURE cancel_a7
  (
    p_doc_id      NUMBER
   ,p_cancel_date DATE
  );
  PROCEDURE del_cancel_a7(p_doc_id NUMBER);
  /*
    Байтин А.
    Создание А7
  */
  PROCEDURE create_a7
  (
    par_a7_num           VARCHAR2
   ,par_doc_date         DATE
   ,par_receiver_id      NUMBER
   ,par_issuer_id        NUMBER
   ,par_payment_terms_id NUMBER
   ,par_fund_id          NUMBER
   ,par_rev_fund_id      NUMBER
   ,par_rate             NUMBER
   ,par_rev_rate_type_id NUMBER
   ,par_doc_amount       NUMBER
   ,par_rev_amount       NUMBER
   ,par_payment_direct   NUMBER
   ,par_a7_id            OUT NUMBER
  );

  /*
    Байтин А.
    Процедура загрузки А7 из файла
  */
  PROCEDURE load_a7(par_load_file_rows_id NUMBER);

  /*
    Байтин А.
    Процедура проверки перед загрузкой А7 из файла
  */
  PROCEDURE check_before_load_a7
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

  /*
    Процедура аннулирования платежей по ЭПГ по всем видам документов (ПД4/А7/ППвх и пр.)
    По умолчанию (par_from_date IS NULL) аннулируются все документы для заданной версии ДС.
    Если дата par_from_date указана явно, то аннулирование происходит не только по версии ДС par_policy_id,
    но и по всем версиям, в пределах которых существуют ЭПГ, начиная с даты par_from_date

    @param par_policy_id - ИД версии ДС
    @param par_from_date - дата, с которой должны аннулироваться платежи по версии ДС
  */
  PROCEDURE ANNULATED_PAYMENT
  (
    par_policy_id NUMBER
   ,par_from_date DATE DEFAULT NULL -- Пиядин А.: 218940 Отвязка платежей после даты расторжения
  );

END Pkg_A7; 
/
CREATE OR REPLACE PACKAGE BODY Pkg_A7 IS

  FUNCTION get_a7_parent(p_copy_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rc IN (SELECT d.document_id
                 FROM document  d
                     ,doc_doc   dd
                     ,doc_templ dt
                WHERE dt.brief = 'A7'
                  AND dt.doc_templ_id = d.doc_templ_id
                  AND dd.parent_id = d.document_id
                  AND dd.child_id = p_copy_id)
    LOOP
      RETURN rc.document_id;
    END LOOP;
    RETURN p_copy_id;
  END;

  FUNCTION get_a7_dso(p_a7_id NUMBER) RETURN NUMBER IS
    v_a7_copy_id NUMBER;
    v_dso_id     NUMBER;
  BEGIN
    BEGIN
      SELECT d.document_id
        INTO v_a7_copy_id
        FROM doc_doc   dd
            ,document  d
            ,doc_templ dt
            ,doc_templ dt1
            ,document  d1
       WHERE dd.parent_id = p_a7_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND (dt.brief = 'A7COPY' AND dt1.BRIEF = 'A7' OR dt.brief = 'PD4COPY' AND dt1.BRIEF = 'PD4' OR
             dt.brief = 'ЗачетУ_КВ_COPY' AND dt1.BRIEF = 'ЗачетУ_КВ') --Чирков 22.11.2011 Зачет уд. КВ
         AND d1.DOCUMENT_ID = dd.parent_id
         AND dt1.DOC_TEMPL_ID = d1.DOC_TEMPL_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
  
    BEGIN
      SELECT dso.child_doc_id
        INTO v_dso_id
        FROM doc_set_off dso
       WHERE dso.parent_DOC_ID = v_a7_copy_id
         AND doc.get_last_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
         AND ROWNUM < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    RETURN v_dso_id;
  END;

  FUNCTION get_doc_copy(p_doc_id NUMBER) RETURN NUMBER IS
    v_a7_copy_id NUMBER;
  BEGIN
    BEGIN
      SELECT d.document_id
        INTO v_a7_copy_id
        FROM doc_doc   dd
            ,document  d
            ,doc_templ dt
       WHERE dd.parent_id = p_doc_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id = dt.doc_templ_id
         AND dt.brief IN ('A7COPY', 'PD4COPY', 'ЗачетУ_КВ_COPY');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
      WHEN too_many_rows THEN
        raise_application_error(-20100
                               ,'Найдено более одной копии документа ' ||
                                doc.GET_DOC_TEMPL_BRIEF(p_doc_id));
    END;
    RETURN v_a7_copy_id;
  END;

  FUNCTION get_dso(p_a7_id NUMBER) RETURN NUMBER IS
    v_a7_copy_id NUMBER;
    v_dso_id     NUMBER;
  BEGIN
    v_a7_copy_id := get_doc_copy(p_a7_id);
    BEGIN
      SELECT dso.DOC_SET_OFF_ID
        INTO v_dso_id
        FROM doc_set_off dso
       WHERE dso.parent_DOC_ID = v_a7_copy_id
         AND ROWNUM < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    RETURN v_dso_id;
  END;

  PROCEDURE create_a7_copy(p_a7_id IN NUMBER) IS
    v_a7 ven_ac_payment%ROWTYPE;
    v_id NUMBER;
  BEGIN
    -- данные квитанции а7
    SELECT * INTO v_a7 FROM ven_ac_payment p WHERE p.payment_id = p_a7_id;
  
    -- Ф. Ганичев
    v_a7.rev_amount  := v_a7.amount;
    v_a7.rev_rate    := 1;
    v_a7.rev_fund_id := v_a7.fund_id;
  
    -- шаблон "копия а7"
    SELECT dt.doc_templ_id INTO v_a7.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'A7COPY';
  
    SELECT dt.payment_templ_id
      INTO v_a7.payment_templ_id
      FROM ac_payment_templ dt
     WHERE dt.brief = 'A7COPY';
  
    -- запоминаем ид а7
    v_id := v_a7.payment_id;
  
    -- новый ид для копии
    SELECT sq_ac_payment.NEXTVAL INTO v_a7.payment_id FROM dual;
    v_a7.payment_direct_id := 1 - v_a7.payment_direct_id;
    v_a7.payment_type_id   := 1 - v_a7.payment_type_id;
  
    -- добавляем копию
    INSERT INTO ven_ac_payment VALUES v_a7;
  
    -- связь между квитанцией и копией
    INSERT INTO ven_doc_doc (parent_id, child_id) VALUES (v_id, v_a7.payment_id);
  
  END;

  PROCEDURE a7_delete(p_a7_id IN NUMBER) IS
    v_a7_copy_id NUMBER;
  BEGIN
    SELECT d.document_id
      INTO v_a7_copy_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_a7_id
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'A7COPY';
    -- удалить копию
    DELETE FROM ven_ac_payment p WHERE p.payment_id = v_a7_copy_id;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  PROCEDURE a7_update(p_a7_id IN NUMBER) IS
    v_a7 ven_ac_payment%ROWTYPE;
  BEGIN
    -- данные квитанции а7
    SELECT * INTO v_a7 FROM ven_ac_payment p WHERE p.payment_id = p_a7_id;
  
    -- ид копии
    SELECT d.document_id
      INTO v_a7.payment_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_a7_id
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'A7COPY';
  
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
           (SELECT v_a7.filial_id
                  ,v_a7.note
                  ,num
                  ,v_a7.reg_date
                  ,v_a7.amount
                  ,v_a7.a7_contact_id
                  ,v_a7.collection_metod_id
                  ,v_a7.comm_amount
                  ,v_a7.company_bank_acc_id
                  ,v_a7.contact_bank_acc_id
                  ,v_a7.contact_id
                  ,v_a7.date_ext
                  ,v_a7.due_date
                  ,v_a7.fund_id
                  ,v_a7.grace_date
                  ,v_a7.is_agent
                  ,v_a7.num_ext
                  ,1 - v_a7.payment_direct_id
                  ,v_a7.payment_number
                  ,v_a7.payment_templ_id
                  ,v_a7.payment_terms_id
                  ,1 - v_a7.payment_type_id
                  ,v_a7.real_pay_date
                  ,v_a7.amount
                  ,v_a7.fund_id
                  ,1
                  ,v_a7.rev_rate_type_id
              FROM dual)
     WHERE p.payment_id = v_a7.payment_id;
  
  END;

  PROCEDURE set_a7_copy_status(p_doc_id IN NUMBER) IS
    v_status                NUMBER;
    v_id                    NUMBER;
    v_status_change_type_id NUMBER;
  BEGIN
    v_status := Doc.get_last_doc_status_id(p_doc_id);
  
    SELECT d.document_id
      INTO v_id
      FROM doc_doc   dd
          ,document  d
          ,doc_templ dt
     WHERE dd.parent_id = p_doc_id
       AND dd.child_id = d.document_id
       AND d.doc_templ_id = dt.doc_templ_id
       AND dt.brief = 'A7COPY';
  
    SELECT t.status_change_type_id
      INTO v_status_change_type_id
      FROM status_change_type t
     WHERE t.brief = 'AUTO';
  
    FOR rc IN (SELECT * FROM doc_status ds WHERE ds.doc_status_id = v_status)
    LOOP
    
      Doc.set_doc_status(p_doc_id                   => v_id
                        ,p_status_brief             => 'TO_PAY'
                        ,p_status_date              => rc.start_date
                        ,p_status_change_type_brief => 'AUTO'
                        ,p_note                     => rc.note);
    END LOOP;
  END;

  PROCEDURE delete_a7_setoff
  (
    p_a7_id      NUMBER
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
    -- Проверка. Есть ли зачет копии a7
    v_dso_id := Pkg_A7.get_a7_dso(p_a7_id);
    IF v_dso_id IS NOT NULL
    THEN
      SELECT d.num
            ,dt.name
            ,TO_CHAR(d.reg_date, 'DD.MM.YYYY')
            ,d.AMOUNT
            ,f.BRIEF
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
         AND d.FUND_ID = f.FUND_ID;
      RAISE_APPLICATION_ERROR(-20100
                             ,'Ошибка удаления: есть зачитывающий документ ' || v_dt_name || ' №' ||
                              v_d_num || ' от ' || v_d_date || ' на сумму ' || v_d_amount || ' ' ||
                              v_d_fund);
    END IF;
  
    -- отвязывается бланк от договора
    BEGIN
      BEGIN
        SELECT b.bso_id INTO v_bso_id FROM bso b WHERE b.document_id = p_a7_id;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      IF v_bso_id IS NOT NULL
      THEN
        Pkg_Bso.unlink_bso_payment(v_bso_id);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Ошибка при освобождении бланка a7: ' || SQLERRM);
    END;
  
    -- Удаляется зачет счета квитанцией a7
    BEGIN
      Pkg_Payment.dso_before_delete(p_set_off_id);
      DELETE oper o WHERE o.document_id = p_set_off_id;
      DELETE ven_doc_set_off WHERE doc_set_off_id = p_set_off_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100, 'Ошибка удаления зачета a7: ' || SQLERRM);
    END;
  
    -- Удаляется a7
    BEGIN
      -- Удаляются проводки по a7
      DELETE oper o WHERE o.document_id = p_a7_id;
      -- Удаляется копия a7
      a7_delete(p_a7_id);
      -- Удаляется сама а7
      DELETE ven_ac_payment WHERE payment_id = p_a7_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'Ошибка удаления квитанции a7: ' || SQLERRM);
    END;
  END;

  PROCEDURE del_cancel_a7(p_doc_id NUMBER) IS
    v_paym    ven_ac_payment%ROWTYPE;
    v_pol_id  NUMBER;
    v_copy_id NUMBER;
    v_err     NUMBER := 1;
  BEGIN
  
    IF doc.GET_DOC_TEMPL_BRIEF(p_doc_id) NOT IN ('A7', 'PD4', 'ЗачетУ_КВ')
    THEN
      RETURN;
    END IF;
  
    IF doc.GET_LAST_DOC_STATUS_BRIEF(p_doc_id) <> 'ANNULATED'
    THEN
      RETURN;
    END IF;
  
    -- Выборка всех данных по А7
    SELECT * INTO v_paym FROM ven_ac_payment WHERE payment_id = p_doc_id;
  
    IF (pkg_period_closed.check_closed_date(v_paym.cancel_date) <> v_paym.cancel_date)
    THEN
      raise_application_error(-20100
                             ,'Нельзя отменить аннулирование А7(ПД4) в закрытом периоде');
    END IF;
  
    -- Находим полис, связанный с а7
    BEGIN
      SELECT DISTINCT dd.PARENT_ID
        INTO v_pol_id
        FROM doc_doc     dd
            ,doc_set_off dsf
       WHERE dd.CHILD_ID = dsf.PARENT_DOC_ID
         AND dsf.CHILD_DOC_ID = p_doc_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20100
                               ,'Не найден полис, связанный с А7(ПД4)');
      WHEN too_many_rows THEN
        raise_application_error(-20100
                               ,'А7(ПД4) связана с несколькими полисами');
    END;
  
    FOR b IN (SELECT bso_id
                FROM bso        b
                    ,bso_type   bt
                    ,bso_series bs
               WHERE (bs.series_name || '-' || b.num) = v_paym.num
                 AND b.document_id IS NULL
                 AND bt.BRIEF = 'A7'
                 AND bs.BSO_SERIES_ID = b.BSO_SERIES_ID
                 AND bt.BSO_TYPE_ID = bs.BSO_TYPE_ID
                 AND rownum = 1)
    LOOP
    
      v_err := 0;
      -- Привязываем бсо, к a7
      -- TODO: проверка статуса(Испорчен)
      pkg_bso.LINK_BSO_PAYMENT(b.bso_id, p_doc_id, v_pol_id);
    END LOOP;
    IF v_err = 1
       AND doc.GET_DOC_TEMPL_BRIEF(p_doc_id) = 'A7'
    THEN
      raise_application_error(-20100
                             ,'Отмена аннулирования невозможна, т.к. бланк a7 использован');
    END IF;
  
    -- Отменяется аннулирование зачетов
    FOR setoffs IN (SELECT doc_set_off_id FROM doc_set_off WHERE child_doc_id = p_doc_id)
    LOOP
    
      UPDATE doc_set_off SET cancel_date = NULL WHERE doc_set_off_id = setoffs.doc_set_off_id;
    
      doc.SET_DOC_STATUS(setoffs.doc_set_off_id, 'NEW');
    
    END LOOP;
  
    -- Отменяется аннулирование а7
    UPDATE ac_payment SET cancel_date = NULL WHERE payment_id = p_doc_id;
  
    doc.SET_DOC_STATUS(p_doc_id, 'TRANS');
  
    -- Отменяется аннулирование копии a7
    v_copy_id := get_doc_copy(p_doc_id);
    IF v_copy_id IS NOT NULL
    THEN
    
      -- Дату аннулирования проставить
      UPDATE ac_payment SET cancel_date = NULL WHERE payment_id = v_copy_id;
    
      -- Проводки сторнируются по крыжику на переход статусоа
      doc.SET_DOC_STATUS(v_copy_id, 'TO_PAY');
    END IF;
  
  END;

  PROCEDURE cancel_a7
  (
    p_doc_id      NUMBER
   ,p_cancel_date DATE
  ) IS
    v_copy_id NUMBER;
    v_dso_id  NUMBER;
  BEGIN
  
    IF doc.GET_DOC_TEMPL_BRIEF(p_doc_id) NOT IN ('A7', 'PD4', 'ЗачетУ_КВ')
    THEN
      RETURN;
    END IF;
  
    IF doc.GET_LAST_DOC_STATUS_BRIEF(p_doc_id) <> 'TRANS'
    THEN
      RETURN;
    END IF;
  
    IF p_cancel_date IS NULL
    THEN
      raise_application_error(-20100, 'Не задана нада аннулирования');
    ELSIF pkg_period_closed.CHECK_CLOSED_DATE(p_cancel_date) <> p_cancel_date
    THEN
      raise_application_error(-20100
                             ,'Дата аннулирования в закрытом периоде. Аннулирование невозможно');
    END IF;
  
    v_dso_id := Pkg_A7.get_dso(p_doc_id);
    IF (v_dso_id IS NOT NULL)
       AND (doc.GET_last_DOC_STATUS_BRIEF(v_dso_id) <> 'ANNULATED')
    THEN
      raise_application_error(-20100
                             ,'Есть зачет копии документа ' || doc.get_doc_templ_brief(p_doc_id) ||
                              '. Аннулирование невозможно.');
    END IF;
    -- Если есть копия A7, она аннулируется
    v_copy_id := get_doc_copy(p_doc_id);
    IF v_copy_id IS NOT NULL
    THEN
    
      -- Дату аннулирования проставить
      UPDATE ac_payment SET cancel_date = p_cancel_date WHERE payment_id = v_copy_id;
    
      -- Проводки сторнируются по крыжику на переход статусоа
      doc.SET_DOC_STATUS(v_copy_id
                        ,'ANNULATED'
                        ,greatest(doc.GET_LAST_DOC_STATUS_DATE(v_copy_id) + 1 / 24 / 3600
                                 ,p_cancel_date));
    END IF;
  
    -- Дату аннулирования проставить
    UPDATE ac_payment SET cancel_date = p_cancel_date WHERE payment_id = p_doc_id;
  
    -- Проводки сторнируются по крыжику на переход статусоа
    doc.SET_DOC_STATUS(p_doc_id
                      ,'ANNULATED'
                      ,greatest(doc.GET_LAST_DOC_STATUS_DATE(p_doc_id) + 1 / 24 / 3600, p_cancel_date));
  
    -- Отвязываем бсо
    FOR bso_docs IN (SELECT bso_id FROM bso WHERE document_id = p_doc_id)
    LOOP
      pkg_bso.UNLINK_BSO_PAYMENT(bso_docs.bso_id);
    END LOOP;
  
    -- Аннулируются зачеты а7
  
    FOR setoffs IN (SELECT doc_set_off_id FROM doc_set_off WHERE child_doc_id = p_doc_id)
    LOOP
    
      UPDATE doc_set_off
         SET cancel_date = p_cancel_date
       WHERE doc_set_off_id = setoffs.doc_set_off_id;
    
      doc.SET_DOC_STATUS(setoffs.doc_set_off_id
                        ,'ANNULATED'
                        ,greatest(doc.GET_LAST_DOC_STATUS_DATE(setoffs.doc_set_off_id) +
                                  1 / 24 / 3600
                                 ,p_cancel_date));
    
    END LOOP;
  
  END;

  /*
    Байтин А.
    Создание А7
  */
  PROCEDURE create_a7
  (
    par_a7_num           VARCHAR2
   ,par_doc_date         DATE
   ,par_receiver_id      NUMBER
   ,par_issuer_id        NUMBER
   ,par_payment_terms_id NUMBER
   ,par_fund_id          NUMBER
   ,par_rev_fund_id      NUMBER
   ,par_rate             NUMBER
   ,par_rev_rate_type_id NUMBER
   ,par_doc_amount       NUMBER
   ,par_rev_amount       NUMBER
   ,par_payment_direct   NUMBER
   ,par_a7_id            OUT NUMBER
  ) IS
    v_a7_templ_id         doc_templ.doc_templ_id%TYPE;
    v_a7_payment_templ_id ac_payment_templ.payment_templ_id%TYPE;
  BEGIN
    SELECT dt.doc_templ_id INTO v_a7_templ_id FROM doc_templ dt WHERE dt.brief = 'A7';
  
    SELECT dt.payment_templ_id
      INTO v_a7_payment_templ_id
      FROM ac_payment_templ dt
     WHERE dt.brief = 'A7';
  
    SELECT sq_ac_payment.nextval INTO par_a7_id FROM dual;
  
    INSERT INTO ven_ac_payment
      (payment_id
      ,doc_templ_id
      ,num
      ,reg_date
      ,amount
      ,a7_contact_id
      ,collection_metod_id
      ,contact_id
      ,due_date
      ,fund_id
      ,grace_date
      ,is_agent
      ,payment_direct_id
      ,payment_number
      ,payment_templ_id
      ,payment_terms_id
      ,payment_type_id
      ,real_pay_date
      ,comm_amount
      ,rev_amount
      ,rev_fund_id
      ,rev_rate
      ,rev_rate_type_id)
    VALUES
      (par_a7_id
      ,v_a7_templ_id
      ,par_a7_num
      ,par_doc_date
      ,par_doc_amount
      ,par_receiver_id
      ,1
      ,par_issuer_id
      ,par_doc_date
      ,par_fund_id
      ,par_doc_date
      ,0
      ,par_payment_direct
      ,1
      ,v_a7_payment_templ_id
      ,par_payment_terms_id
      ,1
      ,par_doc_date
      ,0
      ,par_rev_amount
      ,par_rev_fund_id
      ,par_rate
      ,par_rev_rate_type_id);
  
    create_a7_copy(par_a7_id);
  END create_a7;

  /*
    Байтин А.
    Перепривязка А7 на ПД4
  */
  PROCEDURE change_pd4_to_a7
  (
    par_pd4_id      NUMBER
   ,par_a7_num      VARCHAR2
   ,par_policy_id   NUMBER
   ,par_receiver_id NUMBER
  ) IS
    v_pd4_copy_id             ac_payment.payment_id%TYPE;
    v_a7_templ_id             doc_templ.doc_templ_id%TYPE;
    v_a7copy_templ_id         ac_payment_templ.payment_templ_id%TYPE;
    v_a7_payment_templ_id     doc_templ.doc_templ_id%TYPE;
    v_a7copy_payment_templ_id ac_payment_templ.payment_templ_id%TYPE;
    v_bso_id                  bso.bso_id%TYPE;
    v_series_num              VARCHAR2(3);
  BEGIN
    BEGIN
      SELECT pd4_copy.payment_id
        INTO v_pd4_copy_id
        FROM doc_doc        dd
            ,ven_ac_payment pd4_copy
       WHERE dd.parent_id = par_pd4_id
         AND dd.child_id = pd4_copy.payment_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найдена связанная с ПД4 копия ПД4');
    END;
    SELECT dt.doc_templ_id INTO v_a7_templ_id FROM doc_templ dt WHERE dt.brief = 'A7';
  
    SELECT dt.payment_templ_id
      INTO v_a7_payment_templ_id
      FROM ac_payment_templ dt
     WHERE dt.brief = 'A7';
  
    SELECT dt.doc_templ_id INTO v_a7copy_templ_id FROM doc_templ dt WHERE dt.brief = 'A7COPY';
  
    SELECT dt.payment_templ_id
      INTO v_a7copy_payment_templ_id
      FROM ac_payment_templ dt
     WHERE dt.brief = 'A7COPY';
  
    -- Ищем БСО с типом А7 у получателя
    BEGIN
      SELECT b.bso_id
            ,to_char(bs.series_num)
        INTO v_bso_id
            ,v_series_num
        FROM bso_type      tp
            ,bso_series    bs
            ,bso           b
            ,bso_hist      bh
            ,bso_hist_type ht
       WHERE tp.brief = 'A7'
         AND tp.bso_type_id = bs.bso_type_id
         AND bs.bso_series_id = b.bso_series_id
         AND b.num = par_a7_num
         AND b.document_id IS NULL
         AND b.bso_hist_id = bh.bso_hist_id
         AND bh.contact_id = par_receiver_id
         AND bh.hist_type_id = ht.bso_hist_type_id
         AND ht.name = 'Передан';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найден БСО с номером "' || par_a7_num ||
                                '" у действующего агента по договору');
    END;
  
    -- Меняем шаблон документа с ПД4 (копии) на А7 (копию), заполняем получателя и дату реальной оплаты
    UPDATE ven_ac_payment ac
       SET ac.doc_templ_id     = v_a7_templ_id
          ,ac.payment_templ_id = v_a7_payment_templ_id
          ,ac.num              = v_series_num || '-' || par_a7_num
          ,ac.a7_contact_id    = par_receiver_id
          ,ac.real_pay_date    = ac.reg_date
     WHERE ac.payment_id = par_pd4_id;
  
    UPDATE ven_ac_payment ac
       SET ac.doc_templ_id     = v_a7copy_templ_id
          ,ac.payment_templ_id = v_a7copy_payment_templ_id
          ,ac.num              = v_series_num || '-' || par_a7_num
          ,ac.a7_contact_id    = par_receiver_id
          ,ac.real_pay_date    = ac.reg_date
     WHERE ac.payment_id = v_pd4_copy_id;
  
    -- Привязываем найденный БСО к А7
    pkg_bso.link_bso_payment(p_bso_id     => v_bso_id
                            ,p_payment_id => par_pd4_id
                            ,p_policy_id  => par_policy_id);
  END change_pd4_to_a7;

  /*
    Байтин А.
    Перепривязка ПП на А7
  */
  PROCEDURE change_pp_to_a7
  (
    par_dso_id          NUMBER
   ,par_pp_id           NUMBER
   ,par_policy_id       NUMBER
   ,par_a7_num          VARCHAR2
   ,par_receiver_id     NUMBER
   ,par_issuer_id       NUMBER
   ,par_payment_term_id NUMBER
   ,par_fund_id         NUMBER
   ,par_doc_amount      NUMBER
   ,par_doc_date        DATE
  ) IS
    v_doc_set_off_id       doc_set_off.doc_set_off_id%TYPE;
    v_parent_doc_id        doc_set_off.parent_doc_id%TYPE;
    v_pp_due_date          ac_payment.due_date%TYPE;
    v_a7_id                ac_payment.payment_id%TYPE;
    v_a7copy_id            ac_payment.payment_id%TYPE;
    v_bso_id               bso.bso_id%TYPE;
    v_series_num           VARCHAR2(3);
    v_pay_registry_item_id payment_register_item.payment_register_item_id%TYPE;
  BEGIN
    -- Сохранить значения doc_set_off перед удалением
    SELECT dso.doc_set_off_id
          ,dso.parent_doc_id
          ,dso.pay_registry_item
      INTO v_doc_set_off_id
          ,v_parent_doc_id
          ,v_pay_registry_item_id
      FROM doc_set_off dso
     WHERE dso.doc_set_off_id = par_dso_id;
  
    SELECT ac.due_date INTO v_pp_due_date FROM ac_payment ac WHERE ac.payment_id = par_pp_id;
  
    -- Ищем БСО с типом А7 у получателя
    BEGIN
      SELECT b.bso_id
            ,to_char(bs.series_num)
        INTO v_bso_id
            ,v_series_num
        FROM bso_type      tp
            ,bso_series    bs
            ,bso           b
            ,bso_hist      bh
            ,bso_hist_type ht
       WHERE tp.brief = 'A7'
         AND tp.bso_type_id = bs.bso_type_id
         AND bs.bso_series_id = b.bso_series_id
         AND b.num = par_a7_num
         AND b.document_id IS NULL
         AND b.bso_hist_id = bh.bso_hist_id
         AND bh.contact_id = par_receiver_id
         AND bh.hist_type_id = ht.bso_hist_type_id
         AND ht.name = 'Передан';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Не найден неиспользуемый БСО у действующего агента по договору');
    END;
  
    -- Убрать зачет
    pkg_payment.del_annul_doc_set_off(par_dso_id);
  
    -- Вставляем А7
    create_a7(par_a7_num           => v_series_num || '-' || par_a7_num
             ,par_doc_date         => par_doc_date
             ,par_receiver_id      => par_receiver_id
             ,par_issuer_id        => par_issuer_id
             ,par_payment_terms_id => par_payment_term_id
             ,par_fund_id          => par_fund_id
             ,par_rev_fund_id      => 122
             ,par_rate             => acc_new.get_rate_by_id(1, par_fund_id, par_doc_date)
             ,par_rev_rate_type_id => 1
             ,par_doc_amount       => par_doc_amount
             ,par_rev_amount       => par_doc_amount *
                                      acc_new.get_rate_by_id(1, par_fund_id, par_doc_date)
             ,par_payment_direct   => 1
             ,par_a7_id            => v_a7_id);
  
    -- Создание нового документа зачета
    pkg_doc_set_off.create_doc_set_off(par_parent_id            => v_parent_doc_id
                                      ,par_child_id             => v_a7_id
                                      ,par_set_off_amount       => par_doc_amount *
                                                                   acc_new.get_rate_by_id(1
                                                                                         ,par_fund_id
                                                                                         ,par_doc_date)
                                      ,par_set_off_child_amount => par_doc_amount *
                                                                   acc_new.get_rate_by_id(1
                                                                                         ,par_fund_id
                                                                                         ,par_doc_date)
                                      ,par_doc_set_off_id       => v_doc_set_off_id);
  
    doc.set_doc_status(v_doc_set_off_id, 'NEW');
  
    -- Находим копию А7
    SELECT dd.child_id INTO v_a7copy_id FROM doc_doc dd WHERE dd.parent_id = v_a7_id;
  
    pkg_doc_set_off.create_doc_set_off(par_parent_id            => v_a7copy_id
                                      ,par_child_id             => par_pp_id
                                      ,par_set_off_amount       => par_doc_amount *
                                                                   acc_new.get_rate_by_id(1
                                                                                         ,par_fund_id
                                                                                         ,par_doc_date)
                                      ,par_set_off_child_amount => par_doc_amount *
                                                                   acc_new.get_rate_by_id(1
                                                                                         ,par_fund_id
                                                                                         ,par_doc_date)
                                      ,par_doc_set_off_id       => v_doc_set_off_id
                                      ,par_pay_registry_item_id => v_pay_registry_item_id);
  
    -- Привязываем найденный БСО к А7
    pkg_bso.link_bso_payment(p_bso_id     => v_bso_id
                            ,p_payment_id => v_a7_id
                            ,p_policy_id  => par_policy_id);
    doc.set_doc_status(v_a7_id, 'NEW');
    doc.set_doc_status(v_a7_id, 'TRANS');
    doc.set_doc_status(v_doc_set_off_id, 'NEW');
  END change_pp_to_a7;

  /*
    Байтин А.
    Процедура загрузки А7 из файла
  */
  PROCEDURE load_a7(par_load_file_rows_id NUMBER) IS
    v_ids             p_pol_header.ids%TYPE;
    v_pol_header_id   p_pol_header.policy_header_id%TYPE;
    v_policy_id       p_policy.policy_id%TYPE;
    v_a7_num          document.num%TYPE;
    v_offset_doc_id   document.document_id%TYPE;
    v_epg_id          ac_payment.payment_id%TYPE;
    v_dso_id          ac_payment.payment_id%TYPE;
    v_offset_brief    doc_templ.brief%TYPE;
    v_comment         load_file_rows.row_comment%TYPE;
    v_notice_date     p_policy.notice_date%TYPE;
    v_issuer_id       contact.contact_id%TYPE;
    v_receiver_id     contact.contact_id%TYPE;
    v_payment_term_id t_payment_terms.id%TYPE;
    v_fund_id         fund.fund_id%TYPE;
    v_premium         p_policy.premium%TYPE;
    v_bso_id          bso.bso_id%TYPE;
    v_series_num      VARCHAR2(3);
  BEGIN
    SAVEPOINT before_load;
    SELECT to_number(lf.val_1)
          ,lf.val_2
          ,lf.uro_id
      INTO v_ids
          ,v_a7_num
          ,v_pol_header_id
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    -- Ищем договор + один ЭПГ
    BEGIN
      SELECT dc.document_id
            ,pp.policy_id
            ,pp.notice_date - 1
            ,pi.contact_id
            ,pp.payment_term_id
            ,ph.fund_id
            ,pp.premium
        INTO v_epg_id
            ,v_policy_id
            ,v_notice_date
            ,v_issuer_id
            ,v_payment_term_id
            ,v_fund_id
            ,v_premium
        FROM p_pol_header   ph
            ,p_policy       pp
            ,v_pol_issuer   pi
            ,doc_doc        dd
            ,document       dc
            ,doc_templ      dt
            ,doc_status_ref dsr
       WHERE ph.policy_header_id = v_pol_header_id
         AND ph.policy_header_id = pp.pol_header_id
         AND pp.policy_id = dd.parent_id
         AND dd.child_id = dc.document_id
         AND dc.doc_templ_id = dt.doc_templ_id
         AND pp.policy_id = pi.policy_id
         AND dt.brief = 'PAYMENT'
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief != 'ANNULATED';
    EXCEPTION
      -- Если не нашли, пишем ошибку. Если нашли больше, тоже пишем ошибку
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'В договоре не найдено ни одного ЭПГ');
      WHEN TOO_MANY_ROWS THEN
        raise_application_error(-20001
                               ,'В договоре найдено несколько ЭПГ');
    END;
    -- Если все нашли, смотрим, какой зачитывающий документ привязан
    BEGIN
      SELECT dc.document_id
            ,dso.doc_set_off_id
            ,dt.brief
        INTO v_offset_doc_id
            ,v_dso_id
            ,v_offset_brief
        FROM doc_set_off dso
            ,document    dc
            ,doc_templ   dt
       WHERE dso.parent_doc_id = v_epg_id
         AND dso.child_doc_id = dc.document_id
         AND dc.doc_templ_id = dt.doc_templ_id
         AND dso.cancel_date IS NULL;
    EXCEPTION
      -- Если нет зачитывающего документа добавим дальше
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN TOO_MANY_ROWS THEN
        raise_application_error(-20001
                               ,'Найдено несколько зачитывающих документов');
    END;
  
    -- Находим получателя А7 - действующего агента по договору
    BEGIN
      SELECT agh.agent_id
        INTO v_receiver_id
        FROM p_policy_agent_doc pad
            ,document           dc
            ,doc_status_ref     dsr
            ,ag_contract_header agh
       WHERE pad.policy_header_id = v_pol_header_id
         AND pad.p_policy_agent_doc_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief = 'CURRENT'
         AND pad.ag_contract_header_id = agh.ag_contract_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001, 'Не найден получатель квитанции');
      WHEN TOO_MANY_ROWS THEN
        raise_application_error(-20001
                               ,'Найдено несколько агентов по договору в статусе "Действующий"');
    END;
  
    IF v_offset_brief IS NULL
    THEN
      -- Ищем БСО с типом А7 у получателя
      BEGIN
        SELECT b.bso_id
              ,to_char(bs.series_num)
          INTO v_bso_id
              ,v_series_num
          FROM bso_type      tp
              ,bso_series    bs
              ,bso           b
              ,bso_hist      bh
              ,bso_hist_type ht
         WHERE tp.brief = 'A7'
           AND tp.bso_type_id = bs.bso_type_id
           AND bs.bso_series_id = b.bso_series_id
           AND b.num = v_a7_num
           AND b.document_id IS NULL
           AND b.bso_hist_id = bh.bso_hist_id
           AND bh.contact_id = v_receiver_id
           AND bh.hist_type_id = ht.bso_hist_type_id
           AND ht.name = 'Передан';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          raise_application_error(-20001
                                 ,'Не найден БСО с номером "' || v_a7_num ||
                                  '" у действующего агента по договору');
      END;
    
      -- Если нет зачитывающего документа, добавляем А7
      create_a7(par_a7_num           => v_series_num || '-' || v_a7_num
               ,par_doc_date         => v_notice_date
               ,par_receiver_id      => v_receiver_id
               ,par_issuer_id        => v_issuer_id
               ,par_payment_terms_id => v_payment_term_id
               ,par_fund_id          => v_fund_id
               ,par_rev_fund_id      => 122
               ,par_rate             => acc_new.Get_Rate_By_ID(1, v_fund_id, v_notice_date)
               ,par_rev_rate_type_id => 1
               ,par_doc_amount       => v_premium
               ,par_rev_amount       => v_premium *
                                        acc_new.Get_Rate_By_ID(1, v_fund_id, v_notice_date)
               ,par_payment_direct   => 1
               ,par_a7_id            => v_offset_doc_id);
      pkg_doc_set_off.create_doc_set_off(par_parent_id            => v_epg_id
                                        ,par_child_id             => v_offset_doc_id
                                        ,par_set_off_amount       => v_premium *
                                                                     acc_new.Get_Rate_By_ID(1
                                                                                           ,v_fund_id
                                                                                           ,v_notice_date)
                                        ,par_set_off_child_amount => v_premium *
                                                                     acc_new.Get_Rate_By_ID(1
                                                                                           ,v_fund_id
                                                                                           ,v_notice_date)
                                        ,par_doc_set_off_id       => v_dso_id);
    
      doc.set_doc_status(v_dso_id, 'NEW');
    
      -- Привязываем найденный БСО к А7
      pkg_bso.link_bso_payment(p_bso_id     => v_bso_id
                              ,p_payment_id => v_offset_doc_id
                              ,p_policy_id  => v_policy_id);
    
    ELSIF v_offset_brief = 'ПП'
    THEN
      -- Если есть ПП, перепривязываем на А7
      change_pp_to_a7(par_dso_id          => v_dso_id
                     ,par_pp_id           => v_offset_doc_id
                     ,par_policy_id       => v_policy_id
                     ,par_a7_num          => v_a7_num
                     ,par_receiver_id     => v_receiver_id
                     ,par_issuer_id       => v_issuer_id
                     ,par_payment_term_id => v_payment_term_id
                     ,par_fund_id         => v_fund_id
                     ,par_doc_amount      => v_premium
                     ,par_doc_date        => v_notice_date);
    
    ELSIF v_offset_brief = 'PD4'
    THEN
      -- Если есть ПД4, перепривязываем на А7
      change_pd4_to_a7(par_pd4_id      => v_offset_doc_id
                      ,par_a7_num      => v_a7_num
                      ,par_policy_id   => v_policy_id
                      ,par_receiver_id => v_receiver_id);
    ELSE
      raise_application_error(-20001
                             ,'Зачитывающий документ отличается от ПП и ПД4. Сокращенное наименование: "' ||
                              v_offset_brief || '"');
    END IF;
    pkg_load_file_to_table.set_row_checked(par_load_file_rows_id);
    pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                         ,par_row_status        => pkg_load_file_to_table.get_loaded
                                         ,par_row_comment       => NULL);
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_load;
      v_comment := REPLACE(SQLERRM, 'ORA-20001: ');
      pkg_load_file_to_table.set_row_not_checked(par_load_file_rows_id);
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => v_comment);
  END load_a7;

  /*
    Байтин А.
    Процедура проверки перед загрузкой А7 из файла
  */
  PROCEDURE check_before_load_a7
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    v_ids           p_pol_header.ids%TYPE;
    v_policy_status doc_status_ref.brief%TYPE;
    v_pol_header_id p_pol_header.policy_header_id%TYPE;
  BEGIN
    SELECT to_number(lf.val_1)
      INTO v_ids
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    -- Ищем договор
    BEGIN
      SELECT ph.policy_header_id
            ,dsr.brief
        INTO v_pol_header_id
            ,v_policy_status
        FROM p_pol_header   ph
            ,p_policy       pp
            ,document       dc
            ,doc_status_ref dsr
       WHERE ph.ids = v_ids
         AND ph.last_ver_id = pp.policy_id
         AND pp.policy_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id;
    
      -- Если нашли, проверяем статус
      IF v_policy_status IN ('CURRENT', 'PASSED_TO_AGENT', 'QUIT', 'STOPED')
      THEN
        UPDATE load_file_rows
           SET ure_id     = 282
              ,uro_id     = v_pol_header_id
              ,is_checked = 1
         WHERE load_file_rows_id = par_load_file_rows_id;
      
        par_status  := pkg_load_file_to_table.get_checked;
        par_comment := NULL;
      ELSE
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := 'Договор не находится в одном из статусов: Действующий, Передано агенту, Завершен, Прекращен';
      END IF;
    EXCEPTION
      -- Если не нашли, пишем ошибку.
      WHEN NO_DATA_FOUND THEN
        par_status  := pkg_load_file_to_table.get_error;
        par_comment := 'Не найден договор с ИДС: "' || to_char(v_ids) || '"';
    END;
  END check_before_load_a7;
  
  /*
    Процедура аннулирования платежей по ЭПГ по всем видам документов (ПД4/А7/ППвх и пр.)
    По умолчанию (par_from_date IS NULL) аннулируются все документы для заданной версии ДС.
    Если дата par_from_date указана явно, то аннулирование происходит не только по версии ДС par_policy_id,
    но и по всем версиям, в пределах которых существуют ЭПГ, начиная с даты par_from_date

    @param par_policy_id - ИД версии ДС
    @param par_from_date - дата, с которой должны аннулироваться платежи по версии ДС
  */
  PROCEDURE ANNULATED_PAYMENT
  (
    par_policy_id NUMBER
   ,par_from_date DATE DEFAULT NULL -- Пиядин А.: 218940 Отвязка платежей после даты расторжения
  ) IS
    buf_ids         VARCHAR2(2000) := '';
    num_set_off_acc VARCHAR2(35) := '';
    IS_EXIST_SETOFF NUMBER := 0;
    EXIST_SETOFF EXCEPTION;
    k NUMBER := 0;
  BEGIN
  
    FOR paym_to_del IN (SELECT ac.payment_id epg_id
                              ,dt.brief brief_epg
                              ,dso.doc_set_off_id
                              ,dso.child_doc_id
                              ,dt_c.brief brief_dso
                              ,pkg_period_closed.check_closed_date(dso.set_off_date) closed_date
                              ,
                               /**/NVL(dt_copy.brief, 'NONE') brief_copy
                              ,ac_copy.payment_id copy_id
                              ,d_copy.reg_date reg_date_copy
                              ,NVL(dso_copy.doc_set_off_id, dso.doc_set_off_id) doc_id
                              ,pol.pol_header_id
                              ,NVL(dso.pay_registry_item, dso_copy.pay_registry_item) pay_registry_item
                          FROM ins.ac_payment     ac
                              ,ins.doc_doc        dd
                              ,ins.document       d
                              ,ins.doc_status_ref rf
                              ,ins.doc_templ      dt
                              ,ins.doc_set_off    dso
                              ,ins.document       d_dso
                              ,ins.doc_status_ref rf_dso
                              ,
                               /**/ins.ac_payment ac_c
                              ,ins.document   d_c
                              ,ins.doc_templ  dt_c
                              ,
                               /**/ins.doc_doc     dd_copy
                              ,ins.document    d_copy
                              ,ins.doc_templ   dt_copy
                              ,ins.ac_payment  ac_copy
                              ,ins.doc_set_off dso_copy
                              ,
                               /**/ins.p_policy pol
                         WHERE ac.payment_id = dd.child_id
                           AND pol.policy_id = dd.parent_id
                           AND ac.payment_id = d.document_id
                           AND d.doc_status_ref_id = rf.doc_status_ref_id
                           AND d.doc_templ_id = dt.doc_templ_id
                           AND dt.brief IN ('PAYMENT', 'PAYMENT_SETOFF_ACC')
                           AND rf.brief != 'ANNULATED'
                           AND ac.payment_id = dso.parent_doc_id
                           AND dso.doc_set_off_id = d_dso.document_id
                           AND d_dso.doc_status_ref_id = rf_dso.doc_status_ref_id
                           AND rf_dso.brief != 'ANNULATED'
                              /**/
                           AND dso.child_doc_id = ac_c.payment_id
                           AND ac_c.payment_id = d_c.document_id
                           AND d_c.doc_templ_id = dt_c.doc_templ_id
                              /**/
                           AND ac_c.payment_id = dd_copy.parent_id(+)
                           AND d_copy.document_id(+) = dd_copy.child_id
                           AND d_copy.doc_templ_id = dt_copy.doc_templ_id(+)
                           AND dd_copy.child_id = ac_copy.payment_id(+)
                           AND ac_copy.payment_id = dso_copy.parent_doc_id(+)
                             /* Пиядин А.: 218940 Отвязка платежей после даты расторжения */
                           AND pol.policy_id IN (SELECT p2.policy_id
                                                 FROM p_policy p1
                                                     ,p_policy p2
                                                 WHERE 1 = 1
                                                   AND p1.pol_header_id = p2.pol_header_id
                                                   AND p1.policy_id     = par_policy_id
                                                   AND p2.policy_id = DECODE(par_from_date, NULL, par_policy_id, p2.policy_id))
                           AND d_c.reg_date >= nvl(par_from_date, d_c.reg_date)                       
                       )
    LOOP
      -- Пиядин А. 218940 Отвязка платежей после даты расторжения
      IF par_from_date IS NOT NULL THEN
        UPDATE payment_register_item pri
          SET pri.status        = 10 -- Статус – Условно распознан
             ,pri.set_off_state = 11 -- Статус ручной обработки – Расторжение
        WHERE pri.payment_register_item_id = paym_to_del.pay_registry_item;
      END IF;
    
      UPDATE ins.ven_doc_set_off SET cancel_date = SYSDATE WHERE doc_set_off_id = paym_to_del.doc_id;
      ins.doc.set_doc_status(paym_to_del.doc_id, 'ANNULATED', SYSDATE);
    
      IF paym_to_del.brief_copy = 'ЗачетУ_КВ'
      THEN
        IF ins.pkg_period_closed.CHECK_CLOSED_DATE(paym_to_del.reg_date_copy) >=
           paym_to_del.reg_date_copy
        THEN
          ins.pkg_payment.dso_before_delete(paym_to_del.doc_set_off_id);
          DELETE FROM ins.document d WHERE d.document_id = paym_to_del.doc_set_off_id;
          DELETE FROM ins.document d WHERE d.document_id = paym_to_del.copy_id;
          DELETE FROM ins.document d WHERE d.document_id = paym_to_del.child_doc_id;
          DELETE FROM ins.doc_doc dd
           WHERE dd.child_id = paym_to_del.copy_id
             AND dd.parent_id = paym_to_del.child_doc_id;
        ELSE
          pkg_a7.cancel_a7(paym_to_del.child_doc_id, SYSDATE);
        END IF;
      ELSIF paym_to_del.brief_copy IN ('A7COPY', 'PD4COPY')
      THEN
        pkg_a7.cancel_a7(paym_to_del.child_doc_id, SYSDATE);
      ELSIF paym_to_del.brief_dso IN ('PAYMENT_SETOFF_ACC', 'PAYMENT_SETOFF')
      THEN
        k := 0;
        /*Если взаимозачет зачитывает ЭПГ, которая не относится к версии par_policy_id
        и относится к другому ИДС*/
        IS_EXIST_SETOFF := 0;
        FOR paym_another IN (SELECT ph.ids
                                   ,d.num num_setoff
                               FROM ins.ac_payment     ac
                                   ,ins.doc_doc        dd
                                   ,ins.ven_document   d
                                   ,ins.doc_status_ref rf
                                   ,ins.doc_templ      dt
                                   ,
                                    /**/ins.doc_set_off    dso
                                   ,ins.document       d_dso
                                   ,ins.doc_templ      dt_dso
                                   ,ins.doc_status_ref rf_dso
                                   ,
                                    /**/ins.ac_payment   ac_an
                                   ,ins.doc_doc      dd_an
                                   ,ins.p_policy     pol
                                   ,ins.p_pol_header ph
                              WHERE ac.payment_id = dd.child_id
                                AND dso.doc_set_off_id = paym_to_del.doc_id
                                AND ac.payment_id = d.document_id
                                AND d.doc_status_ref_id = rf.doc_status_ref_id
                                AND d.doc_templ_id = dt.doc_templ_id
                                AND dt.brief IN ('PAYORDBACK'
                                                ,'PAYMENT_SETOFF'
                                                ,'PAYMENT_SETOFF_ACC'
                                                ,'PAYORDER_SETOFF')
                                AND rf.brief != 'ANNULATED'
                                   /**/
                                AND dso.child_doc_id = ac.payment_id
                                AND dso.doc_set_off_id = d_dso.document_id
                                AND d_dso.doc_templ_id = dt_dso.doc_templ_id
                                AND rf_dso.doc_status_ref_id = d_dso.doc_status_ref_id
                                   /*AND rf_dso.brief != 'ANNULATED'*/
                                   /**/
                                AND dso.parent_doc_id = ac_an.payment_id
                                AND ac_an.payment_id = dd_an.child_id
                                AND dd_an.parent_id = pol.policy_id
                                AND pol.pol_header_id = ph.policy_header_id
                                AND pol.pol_header_id != paym_to_del.pol_header_id
                                /* Пиядин А.: 218940 Отвязка платежей после даты расторжения */
                                AND dd.parent_id IN (SELECT p2.policy_id
                                                     FROM p_policy p1
                                                         ,p_policy p2
                                                     WHERE 1 = 1
                                                       AND p1.pol_header_id = p2.pol_header_id
                                                       AND p1.policy_id     = par_policy_id
                                                       AND p2.policy_id = DECODE(par_from_date, NULL, par_policy_id, p2.policy_id))
                                AND d.reg_date >= nvl(par_from_date, d.reg_date)   
                            )
        LOOP
          num_set_off_acc := paym_another.num_setoff;
          buf_ids         := buf_ids || TO_CHAR(paym_another.ids) || ';';
          IS_EXIST_SETOFF := 1;
        END LOOP;
        IF IS_EXIST_SETOFF = 1
        THEN
          RAISE EXIST_SETOFF;
        END IF;
        /*Если взаимозачет зачитывает ЭПГ, которая не относится к версии par_policy_id
        и относится к нашему ИДС*/
        FOR paym_our IN (SELECT ph.ids
                               ,d.num num_setoff
                               ,ac_an.payment_id
                               ,dso.child_doc_id
                           FROM ins.ac_payment     ac
                               ,ins.doc_doc        dd
                               ,ins.ven_document   d
                               ,ins.doc_status_ref rf
                               ,ins.doc_templ      dt
                               ,
                                /**/ins.doc_set_off    dso
                               ,ins.document       d_dso
                               ,ins.doc_templ      dt_dso
                               ,ins.doc_status_ref rf_dso
                               ,
                                /**/ins.ac_payment   ac_an
                               ,ins.doc_doc      dd_an
                               ,ins.p_policy     pol
                               ,ins.p_pol_header ph
                          WHERE ac.payment_id = dd.child_id
                            AND dso.doc_set_off_id = paym_to_del.doc_id
                            AND ac.payment_id = d.document_id
                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                            AND d.doc_templ_id = dt.doc_templ_id
                            AND dt.brief IN ('PAYORDBACK'
                                            ,'PAYMENT_SETOFF'
                                            ,'PAYMENT_SETOFF_ACC'
                                            ,'PAYORDER_SETOFF')
                            AND rf.brief != 'ANNULATED'
                               /**/
                            AND dso.child_doc_id = ac.payment_id
                            AND dso.doc_set_off_id = d_dso.document_id
                            AND d_dso.doc_templ_id = dt_dso.doc_templ_id
                            AND rf_dso.doc_status_ref_id = d_dso.doc_status_ref_id
                               /*AND rf_dso.brief != 'ANNULATED'*/
                               /**/
                            AND dso.parent_doc_id = ac_an.payment_id
                            AND ac_an.payment_id = dd_an.child_id
                            AND dd_an.parent_id = pol.policy_id
                            AND pol.pol_header_id = ph.policy_header_id
                            AND pol.pol_header_id = paym_to_del.pol_header_id
                            /* Пиядин А.: 218940 Отвязка платежей после даты расторжения */
--                            AND dd.parent_id = par_policy_id
                            AND pol.policy_id NOT IN (SELECT p2.policy_id
                                                      FROM p_policy p1
                                                          ,p_policy p2
                                                      WHERE 1 = 1
                                                        AND p1.pol_header_id = p2.pol_header_id
                                                        AND p1.policy_id     = par_policy_id
                                                        AND p2.policy_id = DECODE(par_from_date, NULL, par_policy_id, p2.policy_id))
                            AND d.reg_date >= nvl(par_from_date, d.reg_date)
                        )
        LOOP
          /*IF ins.doc.get_doc_status_brief(paym_our.payment_id) = 'PAID' THEN
            ins.doc.set_doc_status(paym_our.payment_id,'TO_PAY',SYSDATE);
          END IF;*/
          IF ins.doc.get_doc_status_brief(paym_our.payment_id) = 'PAID'
          THEN
            ins.doc.set_doc_status(paym_our.payment_id, 'TO_PAY', SYSDATE);
            IF par_from_date IS NULL THEN
              ins.doc.set_doc_status(paym_our.payment_id, 'ANNULATED', SYSDATE);
            END IF;
          END IF;
          IF ins.doc.get_doc_status_brief(paym_our.payment_id) = 'TO_PAY' AND par_from_date IS NULL
          THEN
            ins.doc.set_doc_status(paym_our.payment_id, 'ANNULATED', SYSDATE);
          END IF;
          IF ins.doc.get_doc_status_brief(paym_our.child_doc_id) = 'PAID'
          THEN
            ins.doc.set_doc_status(paym_our.child_doc_id, 'TO_PAY', SYSDATE);
          END IF;
          k := k + 1;
        END LOOP;
        /*Зачеты не существуют, или существуют но только на 
        ЭПГ относящиеся к отменяемой версии – аннулируем зачеты и взаимозачет*/
        FOR paym_ver IN (SELECT ph.ids
                               ,d.num num_setoff
                               ,ac_an.payment_id
                               ,dso.child_doc_id
                           FROM ins.ac_payment     ac
                               ,ins.doc_doc        dd
                               ,ins.ven_document   d
                               ,ins.doc_status_ref rf
                               ,ins.doc_templ      dt
                               ,
                                /**/ins.doc_set_off    dso
                               ,ins.document       d_dso
                               ,ins.doc_templ      dt_dso
                               ,ins.doc_status_ref rf_dso
                               ,
                                /**/ins.ac_payment   ac_an
                               ,ins.doc_doc      dd_an
                               ,ins.p_policy     pol
                               ,ins.p_pol_header ph
                          WHERE ac.payment_id = dd.child_id
                            AND dso.doc_set_off_id = paym_to_del.doc_id
                            AND ac.payment_id = d.document_id
                            AND d.doc_status_ref_id = rf.doc_status_ref_id
                            AND d.doc_templ_id = dt.doc_templ_id
                            AND dt.brief IN ('PAYORDBACK'
                                            ,'PAYMENT_SETOFF'
                                            ,'PAYMENT_SETOFF_ACC'
                                            ,'PAYORDER_SETOFF')
                            AND rf.brief != 'ANNULATED'
                               /**/
                            AND dso.child_doc_id = ac.payment_id
                            AND dso.doc_set_off_id = d_dso.document_id
                            AND d_dso.doc_templ_id = dt_dso.doc_templ_id
                            AND rf_dso.doc_status_ref_id = d_dso.doc_status_ref_id
                               /*AND rf_dso.brief != 'ANNULATED'*/
                               /**/
                            AND dso.parent_doc_id = ac_an.payment_id
                            AND ac_an.payment_id = dd_an.child_id
                            AND dd_an.parent_id = pol.policy_id
                            AND pol.pol_header_id = ph.policy_header_id
                            AND pol.pol_header_id = paym_to_del.pol_header_id
                            /* Пиядин А.: 218940 Отвязка платежей после даты расторжения */
--                            AND dd.parent_id = par_policy_id
                            AND pol.policy_id IN (SELECT p2.policy_id
                                                  FROM p_policy p1
                                                      ,p_policy p2
                                                  WHERE 1 = 1
                                                    AND p1.pol_header_id = p2.pol_header_id
                                                    AND p1.policy_id     = par_policy_id
                                                    AND p2.policy_id = DECODE(par_from_date, NULL, par_policy_id, p2.policy_id))
                            AND d.reg_date >= nvl(par_from_date, d.reg_date)
                        )
        LOOP
          IF ins.doc.get_doc_status_brief(paym_ver.payment_id) = 'PAID'
          THEN
            ins.doc.set_doc_status(paym_ver.payment_id, 'TO_PAY', SYSDATE);
            IF par_from_date IS NULL THEN
              ins.doc.set_doc_status(paym_ver.payment_id, 'ANNULATED', SYSDATE);
            END IF;
          END IF;
          IF ins.doc.get_doc_status_brief(paym_ver.payment_id) = 'TO_PAY' AND par_from_date IS NULL
          THEN
            ins.doc.set_doc_status(paym_ver.payment_id, 'ANNULATED', SYSDATE);
          END IF;
          IF ins.doc.get_doc_status_brief(paym_ver.child_doc_id) = 'PAID'
          THEN
            ins.doc.set_doc_status(paym_ver.child_doc_id, 'TO_PAY', SYSDATE);
            ins.doc.set_doc_status(paym_ver.child_doc_id, 'ANNULATED', SYSDATE);
          END IF;
          k := k + 1;
        END LOOP;
        IF k = 0
        THEN
          IF ins.doc.get_doc_status_brief(paym_to_del.child_doc_id) = 'PAID'
          THEN
            ins.doc.set_doc_status(paym_to_del.child_doc_id, 'TO_PAY', SYSDATE);
          END IF;
        END IF;
      ELSIF paym_to_del.brief_dso = 'PAYORDER_SETOFF'
      THEN
        IF ins.doc.get_doc_status_brief(paym_to_del.child_doc_id) = 'PAID'
        THEN
          ins.doc.set_doc_status(paym_to_del.child_doc_id, 'TO_PAY', SYSDATE);
        END IF;
      END IF;
    
    END LOOP;
  EXCEPTION
    WHEN EXIST_SETOFF THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Внимание! По отменяемому взаимозачету ' || num_set_off_acc ||
                              ' существуют зачеты на договор(ы) ' || buf_ids ||
                              '. Для выполнения операции необходимо аннулировать все зачеты по документу ' ||
                              num_set_off_acc || '.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении ANNULATED_PAYMENT');
  END ANNULATED_PAYMENT;
  
END Pkg_A7; 
/

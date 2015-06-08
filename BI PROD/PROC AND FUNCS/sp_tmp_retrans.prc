CREATE OR REPLACE PROCEDURE sp_tmp_retrans(p_doc_id IN NUMBER) IS
  v_id     NUMBER;
  v_ref_id NUMBER;

  v_id2     NUMBER;
  v_ref_id2 NUMBER;

  one_sec NUMBER := 1 / 24 / 3600;
BEGIN
  -- узнаем статус
  CASE doc.get_last_doc_status_brief(p_doc_id)

    --если к оплате
    WHEN 'TO_PAY' THEN
      dbms_output.put_line('to pay');

      -- ид статуса
      v_id := doc.get_last_doc_status_id(p_doc_id);

      -- ид статуса
      SELECT doc_status_ref_id
        INTO v_ref_id
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id;

      -- чистим проводки
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id
         AND o.document_id = p_doc_id;
      -- чистим статус
      DELETE FROM doc_status WHERE doc_status_id = v_id;

      -- перепроводим
      doc.set_doc_status(p_doc_id, v_ref_id);

    -- если оплачен
    WHEN 'PAID' THEN
      dbms_output.put_line('payed');

      -- статус оплачен
      v_id := doc.get_last_doc_status_id(p_doc_id);
      SELECT doc_status_ref_id
        INTO v_ref_id
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id;

      -- чистим оплачен
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id
         AND o.document_id = p_doc_id;
      DELETE FROM doc_status WHERE doc_status_id = v_id;

      -- статус к оплате
      v_id2 := doc.get_last_doc_status_id(p_doc_id);
      SELECT doc_status_ref_id
        INTO v_ref_id2
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id2;

      -- чистим к оплате
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id2
         AND o.document_id = p_doc_id;
      DELETE FROM doc_status WHERE doc_status_id = v_id2;

      -- перепроводим к оплате
      doc.set_doc_status(p_doc_id, v_ref_id2);
      --doc.set_doc_status(rc.payment_id, v_ref_id, sysdate + one_sec);


      -- цикл по зачетам
      FOR rc2 IN (SELECT *
                    FROM doc_set_off dso
                   WHERE dso.parent_doc_id = p_doc_id) LOOP

        -- статус зачета
        v_id := doc.get_last_doc_status_id(rc2.doc_set_off_id);
        SELECT doc_status_ref_id
          INTO v_ref_id
          FROM doc_status ds
         WHERE ds.doc_status_id = v_id;

        -- чистим
        DELETE FROM oper o
         WHERE o.doc_status_ref_id = v_ref_id
           AND o.document_id = rc2.doc_set_off_id;
        DELETE FROM doc_status WHERE doc_status_id = v_id;

        -- перепроводим
        doc.set_doc_status(rc2.doc_set_off_id, v_ref_id, SYSDATE + one_sec);


        -- курсор по копии а7 для счета
        FOR rc3 IN (SELECT a7c.payment_id
                      FROM doc_doc dd, ven_ac_payment a7c, doc_templ dta7c--, ven_ac_payment a7
                     WHERE
                     dd.parent_id = rc2.child_doc_id
                       AND dd.child_id = a7c.payment_id
                       AND dta7c.doc_templ_id = a7c.doc_templ_id
                       AND dta7c.brief = 'A7COPY'
                    ) LOOP
          sp_tmp_retrans(rc3.payment_id);
        END LOOP;

      END LOOP;

    ELSE
      dbms_output.put_line('no');
  END CASE;

END sp_tmp_retrans;
/


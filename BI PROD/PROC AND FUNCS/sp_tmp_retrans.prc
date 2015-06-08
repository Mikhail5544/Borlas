CREATE OR REPLACE PROCEDURE sp_tmp_retrans(p_doc_id IN NUMBER) IS
  v_id     NUMBER;
  v_ref_id NUMBER;

  v_id2     NUMBER;
  v_ref_id2 NUMBER;

  one_sec NUMBER := 1 / 24 / 3600;
BEGIN
  -- ������ ������
  CASE doc.get_last_doc_status_brief(p_doc_id)

    --���� � ������
    WHEN 'TO_PAY' THEN
      dbms_output.put_line('to pay');

      -- �� �������
      v_id := doc.get_last_doc_status_id(p_doc_id);

      -- �� �������
      SELECT doc_status_ref_id
        INTO v_ref_id
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id;

      -- ������ ��������
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id
         AND o.document_id = p_doc_id;
      -- ������ ������
      DELETE FROM doc_status WHERE doc_status_id = v_id;

      -- ������������
      doc.set_doc_status(p_doc_id, v_ref_id);

    -- ���� �������
    WHEN 'PAID' THEN
      dbms_output.put_line('payed');

      -- ������ �������
      v_id := doc.get_last_doc_status_id(p_doc_id);
      SELECT doc_status_ref_id
        INTO v_ref_id
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id;

      -- ������ �������
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id
         AND o.document_id = p_doc_id;
      DELETE FROM doc_status WHERE doc_status_id = v_id;

      -- ������ � ������
      v_id2 := doc.get_last_doc_status_id(p_doc_id);
      SELECT doc_status_ref_id
        INTO v_ref_id2
        FROM doc_status ds
       WHERE ds.doc_status_id = v_id2;

      -- ������ � ������
      DELETE FROM oper o
       WHERE o.doc_status_ref_id = v_ref_id2
         AND o.document_id = p_doc_id;
      DELETE FROM doc_status WHERE doc_status_id = v_id2;

      -- ������������ � ������
      doc.set_doc_status(p_doc_id, v_ref_id2);
      --doc.set_doc_status(rc.payment_id, v_ref_id, sysdate + one_sec);


      -- ���� �� �������
      FOR rc2 IN (SELECT *
                    FROM doc_set_off dso
                   WHERE dso.parent_doc_id = p_doc_id) LOOP

        -- ������ ������
        v_id := doc.get_last_doc_status_id(rc2.doc_set_off_id);
        SELECT doc_status_ref_id
          INTO v_ref_id
          FROM doc_status ds
         WHERE ds.doc_status_id = v_id;

        -- ������
        DELETE FROM oper o
         WHERE o.doc_status_ref_id = v_ref_id
           AND o.document_id = rc2.doc_set_off_id;
        DELETE FROM doc_status WHERE doc_status_id = v_id;

        -- ������������
        doc.set_doc_status(rc2.doc_set_off_id, v_ref_id, SYSDATE + one_sec);


        -- ������ �� ����� �7 ��� �����
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


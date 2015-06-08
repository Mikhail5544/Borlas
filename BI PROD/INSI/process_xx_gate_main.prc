CREATE OR REPLACE PROCEDURE process_xx_gate_main AS
  v_doc_id       NUMBER;
  v_cnt_xx_gate  NUMBER;
  v_cnt_rows     NUMBER;
  v_xx_gate      insi.xx_gate_ac_payment%ROWTYPE;
  v_fund_id      NUMBER;
  v_bank_acc_id  NUMBER;
  v_payer_acc_id NUMBER;
BEGIN
  LOOP
    --выбираем количество строк. находящихся в текущий момент в таблице xx_gate - столько раз быдет выполняться внутренний цикл
    SELECT COUNT(*) INTO v_cnt_xx_gate FROM insi.xx_gate_ac_payment;
    --если число строк в шлюзовой таблице = 0, то выходим из цикла
    EXIT WHEN v_cnt_xx_gate = 0;
    --выбираем первую строчку из шлюзовой таблицы
    SELECT * INTO v_xx_gate FROM insi.xx_gate_ac_payment WHERE ROWNUM = 1;
    dbms_output.put_line(v_xx_gate.num || ' ' || v_xx_gate.code);
    --проверяем наличие платежа, ранее импортированного в Борлас из Навижн
    SELECT COUNT(*) INTO v_cnt_rows FROM ins.ac_payment ap WHERE ap.doc_txt = v_xx_gate.code;
    IF v_cnt_rows = 0
    THEN
      SELECT MAX(f.fund_id) INTO v_fund_id FROM ins.fund f WHERE f.brief = v_xx_gate.crn_code;
      SELECT MAX(ccba.id)
        INTO v_bank_acc_id
        FROM ins.cn_contact_bank_acc ccba
       WHERE ccba.account_nr = v_xx_gate.account_receiver;
      SELECT MAX(ccba.id)
        INTO v_payer_acc_id
        FROM ins.cn_contact_bank_acc ccba
       WHERE ccba.account_nr = v_xx_gate.account_payer;
      SELECT ins.sq_document.NEXTVAL INTO v_doc_id FROM DUAL;
      dbms_output.put_line(v_doc_id);
      BEGIN
        INSERT INTO ins.ven_ac_payment
          (rev_rate
          ,collection_metod_id
          ,payment_terms_id
          ,contact_id
          ,fund_id
          ,grace_date
          ,payment_number
          ,num
          ,doc_templ_id
          ,note
          ,reg_date
          ,payment_id
          ,payment_type_id
          ,payment_direct_id
          ,due_date
          ,amount
          ,rev_fund_id
          ,payment_templ_id
          ,company_bank_acc_id
          ,contact_bank_acc_id
          ,rev_amount
          ,doc_txt)
        VALUES
          (1
          ,2 --Безналичный расчет
          ,78 --Безналичная оплата
          ,444409 --ИД контакта "Платеж"
          ,v_fund_id
          ,v_xx_gate.doc_date
          ,-1
          ,v_xx_gate.num
          ,86
          ,v_xx_gate.note
          ,v_xx_gate.doc_date
          ,v_doc_id
          ,1
          ,0
          ,v_xx_gate.bnr_date
          ,v_xx_gate.doc_sum
          ,v_fund_id
          ,2
          ,v_bank_acc_id
          ,v_payer_acc_id
          ,v_xx_gate.rev_amount
          ,v_xx_gate.code);
        INSERT INTO ins.ven_doc_status
          (document_id, doc_status_ref_id, start_date)
        VALUES
          (v_doc_id
          ,1 --статус документа "Новый"
          ,SYSDATE);
        insi.process_xx_gate(v_doc_id, 'insi.xx_gate_ac_payment_good');
      EXCEPTION
        WHEN OTHERS THEN
          process_xx_gate(-2, 'insi.xx_gate_ac_payment_bad');
      END;
    ELSE
      process_xx_gate(-1, 'insi.xx_gate_ac_payment_bad');
    END IF;
  END LOOP;
END process_xx_gate_main;
/

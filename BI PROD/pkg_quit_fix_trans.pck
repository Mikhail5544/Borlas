CREATE OR REPLACE PACKAGE pkg_quit_fix_trans IS
  ----========================================================================----
  -- Подготовка данных для корректирующих проводок по прекращению ДС. 
  -- Формирование корректирующих проводок
  ----========================================================================----
  -- Дата расторжения ДС по его ИДС
  FUNCTION Get_Decline_Date_By_IDS(par_ids VARCHAR2) RETURN DATE;
  ----========================================================================----
  -- Заполнение временной таблицы с данными для формирования 
  -- корректирующих проводок
  PROCEDURE Fill_Quit_Fix_Trans_Table(par_ids NUMBER);
  ----========================================================================----  
END PKG_QUIT_FIX_TRANS;
/
CREATE OR REPLACE PACKAGE BODY pkg_quit_fix_trans IS
  ----========================================================================----
  -- Подготовка данных для корректирующих проводок по прекращению ДС. 
  -- Формирование корректирующих проводок
  ----========================================================================----
  -- Дата расторжения ДС по его ИДС
  FUNCTION Get_Decline_Date_By_IDS(par_ids VARCHAR2) RETURN DATE IS
    v_decline_date DATE;
    CURSOR decline_curs(pcurs_ids VARCHAR2) IS
      SELECT p.decline_date
        FROM p_policy     p
            ,p_pol_header ph
       WHERE p.pol_header_id = ph.policy_header_id
         AND ph.ids = pcurs_ids
         AND EXISTS (SELECT '1' FROM p_pol_decline pd WHERE pd.p_policy_id = p.policy_id);
  BEGIN
    OPEN decline_curs(par_ids);
    FETCH decline_curs
      INTO v_decline_date;
    IF decline_curs%NOTFOUND
    THEN
      CLOSE decline_curs;
      Raise_Application_Error(-20001
                             ,'Не найдена дата прекращения договора. ИДС ' || par_ids);
    END IF;
    CLOSE decline_curs;
    RETURN(v_decline_date);
  END Get_Decline_Date_By_IDS;
  ----========================================================================----
  -- Сумма по проводкам
  FUNCTION Get_Trans_Sum
  (
    par_document_id NUMBER
   ,par_cover_id    NUMBER
  ) RETURN NUMBER IS
    v_return NUMBER;
  BEGIN
    SELECT SUM(t.trans_amount)
      INTO v_return
      FROM oper  o
          ,trans t
     WHERE o.document_id = par_document_id
       AND o.oper_id = t.oper_id
       AND t.obj_uro_id = par_cover_id
       AND t.obj_ure_id = (SELECT ent_id FROM entity WHERE brief = 'P_COVER')
       AND t.trans_templ_id = (SELECT trans_templ_id
                                 FROM trans_templ
                                WHERE NAME = '!Премия начислена к оплате');
    -- Управленческий 77.01.02 77.01.01    
    RETURN(v_return);
  END Get_Trans_Sum;
  ----========================================================================----
  -- Операционная сумма
  FUNCTION Get_Oper_Sum(par_cover_id NUMBER) RETURN NUMBER IS
    v_return NUMBER;
  BEGIN
    -- определить сумму брутто-взноса по данному покрытию
    SELECT fee INTO v_return FROM p_cover WHERE p_cover_id = par_cover_id;
    RETURN(v_return);
  END Get_Oper_Sum;
  ----========================================================================----       
  -- Заполнение временной таблицы с данными для формирования 
  -- корректирующих проводок
  PROCEDURE Fill_Quit_Fix_Trans_Table(par_ids NUMBER) IS
    CURSOR cover_curs(pcurs_pol_header_id NUMBER) IS
      SELECT p.version_num
            ,p.policy_id
            ,Fn_Obj_Name(a.ent_id, a.as_asset_id) asset_name
            ,a.as_asset_id
            ,pl.description product_line_descr
            ,pl.id product_line_id
            ,c.p_cover_id
        FROM p_policy           p
            ,ven_as_asset       a
            ,p_cover            c
            ,t_prod_line_option plo
            ,t_product_line     pl
            ,ven_status_hist    sh
       WHERE p.pol_header_id = pcurs_pol_header_id
         AND p.policy_id = a.p_policy_id
         AND a.as_asset_id = c.as_asset_id
         AND c.t_prod_line_option_id = plo.id
         AND plo.product_line_id = pl.id
         AND c.status_hist_id = sh.status_hist_id
       ORDER BY p.version_num    DESC
               ,a.as_asset_id    ASC
               ,c.status_hist_id ASC
               ,pl.sort_order    ASC;
    -- Оплаты      
    CURSOR pay_curs(pcurs_policy_id NUMBER) IS
      SELECT ap.plan_date
            ,dd.parent_amount part_amount
            ,ap.payment_id
        FROM doc_doc    dd
            ,document   d
            ,ac_payment ap
       WHERE dd.parent_id = pcurs_policy_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id = (SELECT doc_templ_id FROM doc_templ WHERE brief = 'PAYMENT')
         AND d.document_id = ap.payment_id;
    -- Выплаты
    CURSOR setoff_curs(pcurs_policy_id NUMBER) IS
      SELECT ap.due_date
            ,ap.amount
        FROM doc_doc    dd
            ,document   d
            ,ac_payment ap
       WHERE dd.parent_id = pcurs_policy_id
         AND dd.child_id = d.document_id
         AND d.doc_templ_id IN
             (SELECT doc_templ_id
                FROM doc_templ
               WHERE brief IN ('PAYORDBACK', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF'))
         AND d.document_id = ap.payment_id;
    v_pol_header_id  NUMBER;
    v_quit_fix_trans temp_quit_fix_trans%ROWTYPE;
  BEGIN
    IF par_ids IS NULL
    THEN
      RETURN;
    END IF;
    BEGIN
      SELECT policy_header_id INTO v_pol_header_id FROM p_pol_header WHERE ids = par_ids;
    EXCEPTION
      WHEN no_data_found THEN
        Raise_Application_Error(-20001, 'Не найден договор с ИДС ' || par_ids);
      WHEN too_many_rows THEN
        Raise_Application_Error(-20001
                               ,'Найдено несколько договоров с ИДС ' || par_ids);
      WHEN OTHERS THEN
        Raise_Application_Error(-20001
                               ,'Ошибка поиска договора. ИДС ' || par_ids || '. ' || SQLERRM);
    END;
    DELETE FROM temp_quit_fix_trans WHERE ids = par_ids;
    v_quit_fix_trans.ids           := par_ids;
    v_quit_fix_trans.default_order := 1;
    FOR cover_rec IN cover_curs(v_pol_header_id)
    LOOP
      v_quit_fix_trans.version_num        := cover_rec.version_num;
      v_quit_fix_trans.asset_name         := cover_rec.asset_name;
      v_quit_fix_trans.as_asset_id        := cover_rec.as_asset_id;
      v_quit_fix_trans.product_line_descr := cover_rec.product_line_descr;
      v_quit_fix_trans.product_line_id    := cover_rec.product_line_id;
      v_quit_fix_trans.p_cover_id         := cover_rec.p_cover_id;
      v_quit_fix_trans.version_num        := cover_rec.version_num;
      v_quit_fix_trans.policy_id          := cover_rec.policy_id;
      -- Оплаты
      v_quit_fix_trans.payment_or_setoff := 'О';
      FOR pay_rec IN pay_curs(cover_rec.policy_id)
      LOOP
        v_quit_fix_trans.plan_date    := pay_rec.plan_date;
        v_quit_fix_trans.document_sum := pay_rec.part_amount;
        v_quit_fix_trans.trans_sum    := Get_Trans_Sum(pay_rec.payment_id, cover_rec.p_cover_id);
        v_quit_fix_trans.oper_sum     := Get_Oper_Sum(cover_rec.p_cover_id);
        v_quit_fix_trans.fix_sum      := NVL(v_quit_fix_trans.oper_sum, 0) -
                                         NVL(v_quit_fix_trans.trans_sum, 0);
        INSERT INTO temp_quit_fix_trans
          (ids
          ,payment_or_setoff
          ,version_num
          ,policy_id
          ,asset_name
          ,as_asset_id
          ,product_line_descr
          ,product_line_id
          ,p_cover_id
          ,document_id
          ,document_sum
          ,plan_date
          ,oper_sum
          ,trans_sum
          ,fix_sum
          ,default_order)
        VALUES
          (v_quit_fix_trans.ids
          ,v_quit_fix_trans.payment_or_setoff
          ,v_quit_fix_trans.version_num
          ,v_quit_fix_trans.policy_id
          ,v_quit_fix_trans.asset_name
          ,v_quit_fix_trans.as_asset_id
          ,v_quit_fix_trans.product_line_descr
          ,v_quit_fix_trans.product_line_id
          ,v_quit_fix_trans.p_cover_id
          ,v_quit_fix_trans.document_id
          ,v_quit_fix_trans.document_sum
          ,v_quit_fix_trans.plan_date
          ,v_quit_fix_trans.oper_sum
          ,v_quit_fix_trans.trans_sum
          ,v_quit_fix_trans.fix_sum
          ,v_quit_fix_trans.default_order);
        v_quit_fix_trans.default_order := v_quit_fix_trans.default_order + 1;
      END LOOP;
      -- Выплаты
    /*    v_quit_fix_trans.payment_or_setoff := 'В';
        FOR setoff_rec IN setoff_curs( cover_rec.policy_id ) LOOP
          v_quit_fix_trans.plan_date := setoff_rec.due_date;
          v_quit_fix_trans.document_sum := setoff_rec.amount;
          --
          v_quit_fix_trans.trans_sum := NULL;
          --
          INSERT INTO temp_quit_fix_trans( ids, payment_or_setoff,
              version_num, policy_id,
              asset_name, as_asset_id,
              product_line_descr, product_line_id,
              p_cover_id, document_id,
              document_sum, plan_date,
              oper_sum, trans_sum,
              fix_sum, default_order )
            VALUES( v_quit_fix_trans.ids, v_quit_fix_trans.payment_or_setoff,
              v_quit_fix_trans.version_num, v_quit_fix_trans.policy_id,
              v_quit_fix_trans.asset_name, v_quit_fix_trans.as_asset_id,
              v_quit_fix_trans.product_line_descr, v_quit_fix_trans.product_line_id,
              v_quit_fix_trans.p_cover_id, v_quit_fix_trans.document_id,
              v_quit_fix_trans.document_sum, v_quit_fix_trans.plan_date,
              v_quit_fix_trans.oper_sum, v_quit_fix_trans.trans_sum,
              v_quit_fix_trans.fix_sum, v_quit_fix_trans.default_order );
          v_quit_fix_trans.default_order := v_quit_fix_trans.default_order + 1;  
        END LOOP; */
    END LOOP;
  END Fill_Quit_Fix_Trans_Table;
  ----========================================================================----
END PKG_QUIT_FIX_TRANS;
/

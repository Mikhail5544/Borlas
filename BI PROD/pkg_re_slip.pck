CREATE OR REPLACE PACKAGE pkg_re_slip IS

  /**
  * Возвращает максимальное значение лимита
  * @author Patsan O.
  * @return максимальное значение лимита
  */
  FUNCTION get_max_limit RETURN NUMBER;
  FUNCTION get_no_reins(par_cover_id IN NUMBER) RETURN NUMBER;

  /**
  * Пересчет покрытия в слипе
  * Добавления покрытия в слип, если такого нет
  * @author Patsan O.
  * @param par_slip_id ИД слипа
  * @param par_cover_id ИД покрытия из договора перестрахования
  */
  PROCEDURE slip_cover_recalc
  (
    par_slip_id  IN NUMBER
   ,par_cover_id IN NUMBER
  );
  PROCEDURE slip_cover_recalc_in
  (
    par_slip_id   IN NUMBER
   ,par_start     IN DATE
   ,par_end       IN DATE
   ,par_amount    IN NUMBER
   ,par_prem      IN NUMBER
   ,par_tariff    IN NUMBER
   ,par_ins_group IN NUMBER
   ,par_policy    VARCHAR
   ,par_asset     VARCHAR
   ,par_customer  IN NUMBER
  );

  PROCEDURE line_slip_calc
  (
    par_slip_id     IN NUMBER
   ,par_re_cover_id IN NUMBER
  );

  /**
  * Пересчет слипа
  * @author Patsan O.
  * @param par_slip_id ИД слипа
  */
  PROCEDURE slip_recalc(par_slip_id IN NUMBER);

  PROCEDURE set_last_version(par_slip_header IN NUMBER);

  PROCEDURE line_damage_calc
  (
    par_slip_id      IN NUMBER
   ,par_re_cover_id  IN NUMBER
   ,par_claim_header IN NUMBER
   ,par_claim_id     IN NUMBER
   ,par_damage_id    IN NUMBER
  );
  PROCEDURE line_damage_calc_in
  (
    par_slip_id   IN NUMBER
   ,par_re_damage IN NUMBER
   ,par_decsum    IN NUMBER
   ,par_paysum    IN NUMBER
  );
  FUNCTION get_re_damade_count
  (
    par_recover_id IN NUMBER
   ,par_cdamage_id IN NUMBER
  ) RETURN NUMBER;
  PROCEDURE slip_accept(par_slip_id IN NUMBER);
  PROCEDURE slip_oplata(par_slip_id IN NUMBER);
  PROCEDURE slip_payment(par_re_claim_header_id IN NUMBER);
  PROCEDURE slip_payment_nach(par_re_claim_header_id IN NUMBER);
  FUNCTION copy_ver_slip(par_slip_id IN NUMBER) RETURN NUMBER;

END pkg_re_slip;
/
CREATE OR REPLACE PACKAGE BODY pkg_re_slip IS

  FUNCTION get_max_limit RETURN NUMBER IS
  BEGIN
    RETURN 10000000000;
  END;

  -- функция определения оставшейся неперестрахованной части по покрытию
  FUNCTION get_no_reins(par_cover_id IN NUMBER) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    SELECT nvl(SUM(rc.part_sum), 0) INTO RESULT FROM re_cover rc WHERE rc.p_cover_id = par_cover_id;
    RETURN(RESULT);
  END get_no_reins;

  -- добавляем покрытие в слип
  PROCEDURE slip_cover_recalc
  (
    par_slip_id  IN NUMBER
   ,par_cover_id IN NUMBER
  ) IS
    v_re_cover      ven_re_cover%ROWTYPE;
    v_p_cover       ven_p_cover%ROWTYPE;
    v_re_line_cover ven_re_line_cover%ROWTYPE;
    v_re_slip       ven_re_slip%ROWTYPE;
  
    all_amount    NUMBER;
    other_partsum NUMBER;
  BEGIN
  
    SELECT ss.* INTO v_re_slip FROM ven_re_slip ss WHERE ss.re_slip_id = par_slip_id;
  
    SELECT pc.* INTO v_p_cover FROM ven_p_cover pc WHERE pc.p_cover_id = par_cover_id;
  
    SELECT nvl(SUM(rc.part_sum), 0)
      INTO other_partsum
      FROM re_cover rc
     WHERE rc.p_cover_id = par_cover_id;
  
    IF (v_p_cover.ins_amount > other_partsum)
    THEN
      -- добавляем запись в  re_cover, усли такой нет
      BEGIN
        INSERT INTO re_cover
          (re_cover_id, p_cover_id, start_date, end_date, re_slip_id)
          SELECT sq_re_cover.nextval
                ,par_cover_id
                ,v_p_cover.start_date
                ,v_p_cover.end_date
                ,par_slip_id
            FROM dual;
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
      END;
      -- выбираем запись re_cover
      SELECT *
        INTO v_re_cover
        FROM ven_re_cover r
       WHERE r.p_cover_id = par_cover_id
         AND r.re_slip_id = par_slip_id;
      -----------------------
      --тут считаем че надо--
    
      all_amount := 0;
      DELETE FROM ven_re_line_cover r WHERE r.re_cover_id = v_re_cover.re_cover_id;
    
      FOR cur IN (SELECT rls.line_number
                        ,rls.limit
                        ,rls.retention_perc
                        ,rls.retention_val
                        ,rls.part_perc
                        ,rls.part_sum
                        ,rls.tariff_ins
                        ,rls.re_tariff
                        ,rls.commission_perc
                    FROM re_line_slip rls
                   WHERE rls.re_slip_id = par_slip_id
                   ORDER BY rls.line_number)
      LOOP
      
        v_re_line_cover.re_cover_id    := v_re_cover.re_cover_id;
        v_re_line_cover.line_number    := cur.line_number;
        v_re_line_cover.retention_perc := cur.retention_perc;
        v_re_line_cover.part_perc      := cur.part_perc;
        IF (cur.tariff_ins = 1)
        THEN
          v_re_line_cover.re_tariff := nvl(ROUND((v_p_cover.premium * 100 / v_p_cover.ins_amount), 4)
                                          ,0);
        ELSE
          v_re_line_cover.re_tariff := nvl(cur.re_tariff, 0);
        END IF;
        v_re_line_cover.commission_perc := cur.commission_perc;
      
        IF cur.line_number = 1
        THEN
          v_re_line_cover.limit := least(v_p_cover.ins_amount - other_partsum, cur.limit);
        ELSE
          IF (v_p_cover.ins_amount - other_partsum >= all_amount + cur.limit)
          THEN
            v_re_line_cover.limit := cur.limit;
          ELSE
            v_re_line_cover.limit := v_p_cover.ins_amount - all_amount - other_partsum;
          END IF;
        END IF;
      
        v_re_line_cover.retention_val := ROUND(v_re_line_cover.limit * v_re_line_cover.retention_perc / 100
                                              ,2);
        v_re_line_cover.part_sum      := ROUND(v_re_line_cover.limit * v_re_line_cover.part_perc / 100
                                              ,2);
      
        v_re_line_cover.brutto_premium := nvl(ROUND(v_re_line_cover.part_sum *
                                                    v_re_line_cover.re_tariff / 100
                                                   ,2)
                                             ,0);
        v_re_line_cover.commission     := nvl(ROUND(v_re_line_cover.brutto_premium *
                                                    v_re_line_cover.commission_perc / 100
                                                   ,2)
                                             ,0);
        v_re_line_cover.netto_premium  := v_re_line_cover.brutto_premium - v_re_line_cover.commission;
      
        INSERT INTO ven_re_line_cover VALUES v_re_line_cover;
      
        all_amount := all_amount + cur.limit;
        IF (v_p_cover.ins_amount - other_partsum <= all_amount)
        THEN
          EXIT;
        END IF;
      
      END LOOP;
    
      SELECT SUM(rlc.part_sum)
            ,SUM(rlc.brutto_premium)
            ,SUM(rlc.commission)
            ,SUM(rlc.netto_premium)
        INTO v_re_cover.part_sum
            ,v_re_cover.brutto_premium
            ,v_re_cover.commission
            ,v_re_cover.netto_premium
        FROM ven_re_line_cover rlc
       WHERE rlc.re_cover_id = v_re_cover.re_cover_id;
    
      -----------------------
      UPDATE re_cover r
         SET (r.brutto_premium, r.commission, r.netto_premium, r.part_sum) =
             (SELECT v_re_cover.brutto_premium
                    ,v_re_cover.commission
                    ,v_re_cover.netto_premium
                    ,v_re_cover.part_sum
                FROM dual)
       WHERE r.p_cover_id = par_cover_id
         AND r.re_slip_id = par_slip_id;
    END IF;
  
    UPDATE re_slip r
       SET (r.brutto_premium, r.commission, r.netto_premium, r.re_amount) =
           (SELECT SUM(rr.brutto_premium)
                  ,SUM(rr.commission)
                  ,SUM(rr.netto_premium)
                  ,SUM(rr.part_sum)
              FROM re_cover rr
             WHERE rr.re_slip_id = par_slip_id)
     WHERE r.re_slip_id = par_slip_id;
  
  END;

  -- расчет показателей на ДСП во входящем факультативе
  PROCEDURE line_slip_calc
  (
    par_slip_id     IN NUMBER
   ,par_re_cover_id IN NUMBER
  ) IS
    v_re_line_cover ven_re_line_cover%ROWTYPE;
    v_re_cover      ven_re_cover%ROWTYPE;
    pc_amount       NUMBER;
    pc_prem         NUMBER;
    pc_tariff       NUMBER;
    all_amount      NUMBER;
  BEGIN
  
    SELECT rc.ins_amount
          ,rc.ins_tariff
          ,rc.ins_premium
      INTO pc_amount
          ,pc_tariff
          ,pc_prem
      FROM re_cover rc
     WHERE rc.re_cover_id = par_re_cover_id;
  
    --тут считаем че надо--
  
    all_amount := 0;
    DELETE FROM ven_re_line_cover r WHERE r.re_cover_id = par_re_cover_id;
  
    FOR cur IN (SELECT rls.line_number
                      ,rls.limit
                      ,rls.retention_perc
                      ,rls.retention_val
                      ,rls.part_perc
                      ,rls.part_sum
                      ,rls.tariff_ins
                      ,rls.re_tariff
                      ,rls.commission_perc
                  FROM re_line_slip rls
                 WHERE rls.re_slip_id = par_slip_id
                 ORDER BY rls.line_number)
    LOOP
      all_amount                     := all_amount + cur.limit;
      v_re_line_cover.re_cover_id    := par_re_cover_id;
      v_re_line_cover.line_number    := cur.line_number;
      v_re_line_cover.limit          := cur.limit;
      v_re_line_cover.retention_perc := cur.retention_perc;
      v_re_line_cover.part_perc      := cur.part_perc;
      IF (cur.tariff_ins = 1)
      THEN
        v_re_line_cover.re_tariff := nvl(ROUND((pc_prem * 100 / pc_amount), 4), 0);
      ELSE
        v_re_line_cover.re_tariff := nvl(cur.re_tariff, 0);
      END IF;
      v_re_line_cover.commission_perc := cur.commission_perc;
    
      IF (pc_amount >= all_amount)
      THEN
        v_re_line_cover.retention_val := cur.retention_val;
        v_re_line_cover.part_sum      := cur.part_sum;
      ELSE
        v_re_line_cover.retention_val := nvl(ROUND((all_amount - pc_amount) *
                                                   v_re_line_cover.retention_perc / 100
                                                  ,2)
                                            ,0);
        v_re_line_cover.part_sum      := nvl(ROUND((all_amount - pc_amount -
                                                   v_re_line_cover.retention_val) *
                                                   v_re_line_cover.part_perc / 100
                                                  ,2)
                                            ,0);
      END IF;
      v_re_line_cover.brutto_premium := nvl(ROUND(v_re_line_cover.part_sum * v_re_line_cover.re_tariff / 100
                                                 ,2)
                                           ,0);
      v_re_line_cover.commission     := nvl(ROUND(v_re_line_cover.brutto_premium *
                                                  v_re_line_cover.commission_perc / 100
                                                 ,2)
                                           ,0);
      v_re_line_cover.netto_premium  := v_re_line_cover.brutto_premium - v_re_line_cover.commission;
    
      INSERT INTO ven_re_line_cover VALUES v_re_line_cover;
    
      IF (pc_amount <= all_amount)
      THEN
        EXIT;
      END IF;
    
    END LOOP;
  
    SELECT SUM(rlc.part_sum)
          ,SUM(rlc.brutto_premium)
          ,SUM(rlc.commission)
          ,SUM(rlc.netto_premium)
      INTO v_re_cover.part_sum
          ,v_re_cover.brutto_premium
          ,v_re_cover.commission
          ,v_re_cover.netto_premium
      FROM ven_re_line_cover rlc
     WHERE rlc.re_cover_id = par_re_cover_id;
  
    -----------------------
    UPDATE re_cover r
       SET (r.brutto_premium, r.commission, r.netto_premium, r.part_sum) =
           (SELECT v_re_cover.brutto_premium
                  ,v_re_cover.commission
                  ,v_re_cover.netto_premium
                  ,v_re_cover.part_sum
              FROM dual)
     WHERE r.re_cover_id = par_re_cover_id;
  END;

  -- процедура пересчета показателей 
  PROCEDURE slip_recalc(par_slip_id IN NUMBER) IS
  BEGIN
    FOR rec IN (SELECT rc.p_cover_id
                      ,rc.re_cover_id
                      ,rsh.is_in
                  FROM re_cover       rc
                      ,re_slip        rs
                      ,re_slip_header rsh
                 WHERE rc.re_slip_id = par_slip_id
                   AND rs.re_slip_id = par_slip_id
                   AND rsh.re_slip_header_id = rs.re_slip_header_id)
    LOOP
      IF rec.is_in = 0
      THEN
        slip_cover_recalc(par_slip_id, rec.p_cover_id);
      ELSE
        line_slip_calc(par_slip_id, rec.re_cover_id);
      END IF;
    END LOOP;
  END;

  -- устанавливаем последнее состояние на заголовке слипа
  PROCEDURE set_last_version(par_slip_header IN NUMBER) IS
  BEGIN
    UPDATE re_slip_header rsh
       SET rsh.last_slip_id =
           (SELECT rs.re_slip_id
              FROM re_slip rs
             WHERE rs.re_slip_header_id = par_slip_header
               AND rs.ver_num =
                   (SELECT MAX(ver_num) FROM re_slip WHERE re_slip_header_id = par_slip_header))
     WHERE rsh.re_slip_header_id = par_slip_header;
  
  END;

  -- расчет доли ущерба по ДСП 
  PROCEDURE line_damage_calc
  (
    par_slip_id      IN NUMBER
   ,par_re_cover_id  IN NUMBER
   ,par_claim_header IN NUMBER
   ,par_claim_id     IN NUMBER
   ,par_damage_id    IN NUMBER
  ) IS
    v_re_claim_header ven_re_claim_header%ROWTYPE;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_c_claim         ven_c_claim%ROWTYPE;
    v_re_damage       ven_re_damage%ROWTYPE;
    v_c_damage        ven_c_damage%ROWTYPE;
    v_re_line_damage  ven_re_line_damage%ROWTYPE;
  
    d_decsum       NUMBER;
    d_paysum       NUMBER;
    all_amount_pay NUMBER;
    all_amount_dec NUMBER;
  
  BEGIN
  
    SELECT cd.* INTO v_c_damage FROM ven_c_damage cd WHERE cd.c_damage_id = par_damage_id;
  
    SELECT cc.* INTO v_c_claim FROM ven_c_claim cc WHERE cc.c_claim_id = par_claim_id;
  
    -- добавляем запись в  re_claim_header,усли такой нет
    BEGIN
      INSERT INTO ven_re_claim_header
        (re_claim_header_id
        ,re_slip_id
        ,c_claim_header_id
        ,num
        ,doc_templ_id
        ,t_prod_line_option_id
        ,re_cover_id
        ,event_date)
        SELECT sq_re_claim_header.nextval
              ,par_slip_id
              ,par_claim_header
              ,(SELECT num FROM ven_c_claim_header ch WHERE ch.c_claim_header_id = par_claim_header)
              ,(SELECT dc.doc_templ_id
                 FROM doc_templ dc
                WHERE dc.doc_ent_id = ent.id_by_brief('RE_CLAIM_HEADER'))
              ,(SELECT DISTINCT pc.t_prod_line_option_id
                 FROM ven_re_cover rc
                     ,ven_p_cover  pc
                WHERE pc.p_cover_id = rc.p_cover_id
                  AND rc.re_cover_id = par_re_cover_id)
              ,par_re_cover_id
              ,(SELECT ce.event_date
                 FROM c_event ce
                WHERE ce.c_event_id =
                      (SELECT ch.c_event_id
                         FROM ven_c_claim_header ch
                        WHERE ch.c_claim_header_id = par_claim_header))
          FROM dual;
    
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;
  
    -- выбираем запись re_claim_header
    SELECT *
      INTO v_re_claim_header
      FROM ven_re_claim_header r
     WHERE r.c_claim_header_id = par_claim_header
       AND r.re_slip_id = par_slip_id;
  
    -- добавляем запись в  re_claim,усли такой нет
    BEGIN
      INSERT INTO ven_re_claim
        (re_claim_id, re_claim_header_id, seqno, re_claim_status_date, num, doc_templ_id, status_id)
        SELECT sq_re_claim.nextval
              ,v_re_claim_header.re_claim_header_id
              ,v_c_claim.seqno
              ,v_c_claim.claim_status_date
              ,v_c_claim.num
              ,(SELECT dc.doc_templ_id
                 FROM doc_templ dc
                WHERE dc.doc_ent_id = ent.id_by_brief('RE_CLAIM'))
              ,v_c_claim.claim_status_id
          FROM dual;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;
  
    doc.set_doc_status(v_re_claim_header.re_claim_header_id, doc.get_doc_status_id(par_claim_header));
  
    -- выбираем запись re_claim
    SELECT *
      INTO v_re_claim
      FROM ven_re_claim r
     WHERE r.re_claim_header_id = v_re_claim_header.re_claim_header_id
       AND r.seqno = (SELECT cc.seqno FROM c_claim cc WHERE cc.c_claim_id = par_claim_id);
  
    doc.set_doc_status(v_re_claim.re_claim_id, doc.get_doc_status_id(par_claim_id));
  
    -- добавляем запись в  re_damage,усли такой нет
    BEGIN
      INSERT INTO re_damage
        (re_damage_id
        ,re_cover_id
        ,damage_id
        ,re_claim_id
        ,t_damage_code_id
        ,c_damage_type_id
        ,ins_declared_sum
        ,ins_payment_sum)
        SELECT sq_re_damage.nextval
              ,par_re_cover_id
              ,par_damage_id
              ,v_re_claim.re_claim_id
              ,v_c_damage.t_damage_code_id
              ,v_c_damage.c_damage_type_id
              ,v_c_damage.declare_sum
              ,v_c_damage.payment_sum
          FROM dual;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;
  
    -- выбираем запись re_damage
    SELECT *
      INTO v_re_damage
      FROM re_damage r
     WHERE r.damage_id = par_damage_id
       AND r.re_claim_id = v_re_claim.re_claim_id
       AND r.re_cover_id = par_re_cover_id;
  
    --удаляем линии по ущербу
    DELETE FROM re_line_damage r WHERE r.re_damage_id = v_re_damage.re_damage_id;
  
    -- заявленная и сумма к выплате по оригинальному ущербу
    SELECT cd.declare_sum
          ,cd.payment_sum
      INTO d_decsum
          ,d_paysum
      FROM c_damage cd
     WHERE cd.c_damage_id = par_damage_id;
  
    --тут считаем че надо--
    all_amount_pay := 0;
    all_amount_dec := 0;
  
    FOR cur IN (SELECT rls.line_number
                      ,rls.limit
                      ,rls.part_perc
                      ,rls.part_sum
                  FROM re_line_slip rls
                 WHERE rls.re_slip_id = par_slip_id
                 ORDER BY rls.line_number)
    LOOP
    
      v_re_line_damage.re_damage_id := v_re_damage.re_damage_id;
      v_re_line_damage.line_number  := cur.line_number;
      v_re_line_damage.part_perc    := cur.part_perc;
    
      IF (cur.line_number = 1)
      THEN
        v_re_line_damage.limit    := least(cur.limit, d_paysum);
        v_re_line_damage.part_sum := least(cur.part_sum
                                          ,ROUND(least(cur.limit, d_decsum) *
                                                 v_re_line_damage.part_perc / 100
                                                ,2));
      ELSE
        IF (d_paysum >= all_amount_pay + cur.limit)
        THEN
          v_re_line_damage.limit    := cur.limit;
          v_re_line_damage.part_sum := least(cur.part_sum
                                            ,ROUND(least(cur.limit, d_decsum) *
                                                   v_re_line_damage.part_perc / 100
                                                  ,2));
        ELSE
          v_re_line_damage.limit    := d_paysum - all_amount_pay;
          v_re_line_damage.part_sum := least(cur.part_sum
                                            ,ROUND(least(cur.limit, d_decsum - all_amount_dec) *
                                                   v_re_line_damage.part_perc / 100
                                                  ,2));
        END IF;
      END IF;
    
      v_re_line_damage.part_pay := least(cur.part_sum
                                        ,ROUND(v_re_line_damage.limit * v_re_line_damage.part_perc / 100
                                              ,2));
    
      all_amount_pay := all_amount_pay + cur.limit;
      all_amount_dec := all_amount_dec + cur.limit;
      INSERT INTO ven_re_line_damage VALUES v_re_line_damage;
    
      IF (d_paysum <= all_amount_pay)
      THEN
        EXIT;
      END IF;
    END LOOP;
  
    SELECT SUM(rld.part_sum)
          ,SUM(rld.part_pay)
      INTO v_re_damage.re_declared_sum
          ,v_re_damage.re_payment_sum
      FROM ven_re_line_damage rld
     WHERE rld.re_damage_id = v_re_damage.re_damage_id;
  
    -----------------------
    UPDATE ven_re_damage rd
       SET (re_declared_sum, re_payment_sum) =
           (SELECT v_re_damage.re_declared_sum
                  ,v_re_damage.re_payment_sum
              FROM dual)
     WHERE rd.re_damage_id = v_re_damage.re_damage_id;
  
    ------------------------
    UPDATE ven_re_claim rc
       SET (rc.re_declare_sum, rc.re_payment_sum) =
           (SELECT SUM(rd.re_declared_sum)
                  ,SUM(rd.re_payment_sum)
              FROM ven_re_damage rd
             WHERE rd.re_claim_id = v_re_claim.re_claim_id)
     WHERE rc.re_claim_id = v_re_claim.re_claim_id;
  
  END;

  --  расчет доли ущерба во вход факультативе
  PROCEDURE line_damage_calc_in
  (
    par_slip_id   IN NUMBER
   ,par_re_damage IN NUMBER
   ,par_decsum    IN NUMBER
   ,par_paysum    IN NUMBER
  ) IS
    v_re_damage      ven_re_damage%ROWTYPE;
    v_re_line_damage ven_re_line_damage%ROWTYPE;
  
    -- d_decsum            number;
    d_paysum       NUMBER;
    all_amount_pay NUMBER;
    all_amount_dec NUMBER;
  
  BEGIN
  
    --удаляем линии по ущербу
    DELETE FROM re_line_damage r WHERE r.re_damage_id = par_re_damage;
  
    --тут считаем че надо--
    all_amount_pay := 0;
    all_amount_dec := 0;
  
    FOR cur IN (SELECT rls.line_number
                      ,rls.limit
                      ,rls.part_perc
                      ,rls.part_sum
                  FROM re_line_slip rls
                 WHERE rls.re_slip_id = par_slip_id
                 ORDER BY rls.line_number)
    LOOP
    
      v_re_line_damage.re_damage_id := par_re_damage;
      v_re_line_damage.line_number  := cur.line_number;
      v_re_line_damage.part_perc    := cur.part_perc;
    
      IF (cur.line_number = 1)
      THEN
        v_re_line_damage.limit    := least(cur.limit, par_paysum);
        v_re_line_damage.part_sum := least(cur.part_sum
                                          ,ROUND(least(cur.limit, par_decsum) *
                                                 v_re_line_damage.part_perc / 100
                                                ,2));
      ELSE
        IF (d_paysum >= all_amount_pay + cur.limit)
        THEN
          v_re_line_damage.limit    := cur.limit;
          v_re_line_damage.part_sum := least(cur.part_sum
                                            ,ROUND(least(cur.limit, par_decsum) *
                                                   v_re_line_damage.part_perc / 100
                                                  ,2));
        ELSE
          v_re_line_damage.limit    := par_paysum - all_amount_pay;
          v_re_line_damage.part_sum := least(cur.part_sum
                                            ,ROUND(least(cur.limit, par_decsum - all_amount_dec) *
                                                   v_re_line_damage.part_perc / 100
                                                  ,2));
        END IF;
      END IF;
    
      v_re_line_damage.part_pay := least(cur.part_sum
                                        ,ROUND(v_re_line_damage.limit * v_re_line_damage.part_perc / 100
                                              ,2));
    
      all_amount_pay := all_amount_pay + cur.limit;
      all_amount_dec := all_amount_dec + cur.limit;
      INSERT INTO ven_re_line_damage VALUES v_re_line_damage;
    
      IF (par_paysum <= all_amount_pay)
      THEN
        EXIT;
      END IF;
    END LOOP;
  
    SELECT SUM(rld.part_sum)
          ,SUM(rld.part_pay)
      INTO v_re_damage.re_declared_sum
          ,v_re_damage.re_payment_sum
      FROM ven_re_line_damage rld
     WHERE rld.re_damage_id = par_re_damage;
  
    -----------------------
    UPDATE ven_re_damage rd
       SET (re_declared_sum, re_payment_sum) =
           (SELECT v_re_damage.re_declared_sum
                  ,v_re_damage.re_payment_sum
              FROM dual)
     WHERE rd.re_damage_id = par_re_damage;
  
    SELECT rd.re_claim_id
      INTO v_re_damage.re_claim_id
      FROM ven_re_damage rd
     WHERE rd.re_damage_id = par_re_damage;
  
    UPDATE ven_re_claim rc
       SET rc.re_declare_sum = nvl(rc.re_declare_sum, 0) + v_re_damage.re_declared_sum
          ,rc.re_payment_sum = nvl(rc.re_declare_sum, 0) + v_re_damage.re_payment_sum
     WHERE rc.re_claim_id = v_re_damage.re_claim_id;
  
  END;

  -- количество ущербов по ДСП
  FUNCTION get_re_damade_count
  (
    par_recover_id IN NUMBER
   ,par_cdamage_id IN NUMBER
  ) RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO ret
      FROM ven_re_damage
     WHERE ven_re_damage.damage_id = par_cdamage_id
       AND ven_re_damage.re_cover_id = par_recover_id;
    RETURN ret;
  END;

  PROCEDURE slip_cover_recalc_in
  (
    par_slip_id   IN NUMBER
   ,par_start     IN DATE
   ,par_end       IN DATE
   ,par_amount    IN NUMBER
   ,par_prem      IN NUMBER
   ,par_tariff    IN NUMBER
   ,par_ins_group IN NUMBER
   ,par_policy    VARCHAR
   ,par_asset     VARCHAR
   ,par_customer  IN NUMBER
  ) IS
    v_re_cover      re_cover%ROWTYPE;
    v_re_line_cover ven_re_line_cover%ROWTYPE;
    all_amount      NUMBER;
    fund            NUMBER;
    fund_pay        NUMBER;
  BEGIN
  
    SELECT sh.fund_id
          ,sh.fund_pay_id
      INTO fund
          ,fund_pay
      FROM ven_re_slip        rs
          ,ven_re_slip_header sh
     WHERE rs.re_slip_header_id = sh.re_slip_header_id
       AND rs.re_slip_id = par_slip_id
       AND rs.ver_num = 1;
  
    -- добавляем запись в  re_cover, усли такой нет
    BEGIN
      INSERT INTO re_cover
        (RE_COVER_ID
        ,START_DATE
        ,END_DATE
        ,RE_SLIP_ID
        ,FUND_ID
        ,FUND_PAY_ID
        ,T_INSURANCE_GROUP_ID
        ,INS_POLICY
        ,INS_ASSET
        ,CUSTOMER_ID
        ,INS_AMOUNT
        ,INS_PREMIUM
        ,INS_TARIFF)
        SELECT sq_re_cover.nextval
              ,par_start
              ,par_end
              ,par_slip_id
              ,fund
              ,fund_pay
              ,par_ins_group
              ,par_policy
              ,par_asset
              ,par_customer
              ,par_amount
              ,par_prem
              ,par_tariff
          FROM dual;
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;
  
    -- выбираем запись re_cover
    SELECT *
      INTO v_re_cover
      FROM re_cover r
     WHERE r.ins_policy = par_policy
       AND r.ins_asset = par_asset
       AND r.re_slip_id = par_slip_id;
    -----------------------
  
    --тут считаем че надо--
    all_amount := 0;
    DELETE FROM ven_re_line_cover r WHERE r.re_cover_id = v_re_cover.re_cover_id;
  
    FOR cur IN (SELECT rls.line_number
                      ,rls.limit
                      ,rls.retention_perc
                      ,rls.retention_val
                      ,rls.part_perc
                      ,rls.part_sum
                      ,rls.tariff_ins
                      ,rls.re_tariff
                      ,rls.commission_perc
                  FROM re_line_slip rls
                 WHERE rls.re_slip_id = par_slip_id
                 ORDER BY rls.line_number)
    LOOP
    
      v_re_line_cover.re_cover_id    := v_re_cover.re_cover_id;
      v_re_line_cover.line_number    := cur.line_number;
      v_re_line_cover.retention_perc := cur.retention_perc;
      v_re_line_cover.part_perc      := cur.part_perc;
      IF (cur.tariff_ins = 1)
      THEN
        v_re_line_cover.re_tariff := par_tariff;
      ELSE
        v_re_line_cover.re_tariff := nvl(cur.re_tariff, 0);
      END IF;
      v_re_line_cover.commission_perc := cur.commission_perc;
    
      IF cur.line_number = 1
      THEN
        v_re_line_cover.limit := least(par_amount, cur.limit);
      ELSE
        IF (par_amount >= all_amount + cur.limit)
        THEN
          v_re_line_cover.limit := cur.limit;
        ELSE
          v_re_line_cover.limit := par_amount - all_amount;
        END IF;
      END IF;
    
      v_re_line_cover.retention_val := ROUND(v_re_line_cover.limit * v_re_line_cover.retention_perc / 100
                                            ,2);
      v_re_line_cover.part_sum      := ROUND(v_re_line_cover.limit * v_re_line_cover.part_perc / 100
                                            ,2);
    
      v_re_line_cover.brutto_premium := nvl(ROUND(v_re_line_cover.part_sum * v_re_line_cover.re_tariff / 100
                                                 ,2)
                                           ,0);
      v_re_line_cover.commission     := nvl(ROUND(v_re_line_cover.brutto_premium *
                                                  v_re_line_cover.commission_perc / 100
                                                 ,2)
                                           ,0);
      v_re_line_cover.netto_premium  := v_re_line_cover.brutto_premium - v_re_line_cover.commission;
    
      INSERT INTO ven_re_line_cover VALUES v_re_line_cover;
    
      all_amount := all_amount + cur.limit;
      IF (par_amount <= all_amount)
      THEN
        EXIT;
      END IF;
    
    END LOOP;
  
    SELECT SUM(rlc.part_sum)
          ,SUM(rlc.brutto_premium)
          ,SUM(rlc.commission)
          ,SUM(rlc.netto_premium)
      INTO v_re_cover.part_sum
          ,v_re_cover.brutto_premium
          ,v_re_cover.commission
          ,v_re_cover.netto_premium
      FROM ven_re_line_cover rlc
     WHERE rlc.re_cover_id = v_re_cover.re_cover_id;
  
    -----------------------
    UPDATE re_cover r
       SET (r.start_date
          ,r.end_date
          ,r.cancel_date
          ,r.brutto_premium
          ,r.commission
          ,r.netto_premium
          ,r.return_premium
          ,r.part_sum) =
           (SELECT v_re_cover.start_date
                  ,v_re_cover.end_date
                  ,v_re_cover.cancel_date
                  ,v_re_cover.brutto_premium
                  ,v_re_cover.commission
                  ,v_re_cover.netto_premium
                  ,v_re_cover.return_premium
                  ,v_re_cover.part_sum
            
              FROM dual)
     WHERE r.ins_policy = par_policy
       AND r.ins_asset = par_asset
       AND r.re_slip_id = par_slip_id;
  END;

  PROCEDURE slip_accept(par_slip_id IN NUMBER) IS
    v_status     NUMBER;
    v_re_cover   re_cover%ROWTYPE;
    v_templ_prem NUMBER;
    v_templ_com  NUMBER;
    v_res_id     NUMBER;
  BEGIN
  
    SELECT st.doc_status_ref_id INTO v_status FROM doc_status_ref st WHERE st.brief = 'ACCEPTED';
  
    SELECT o.oper_templ_id
      INTO v_templ_prem
      FROM oper_templ o
     WHERE o.brief = 'НачПремИсхПрстрх';
  
    SELECT o.oper_templ_id
      INTO v_templ_com
      FROM oper_templ o
     WHERE o.brief = 'НачКомИсхПрстрх';
  
    FOR rel IN (SELECT rc.re_cover_id FROM re_cover rc WHERE rc.re_slip_id = par_slip_id)
    LOOP
      SELECT rc.* INTO v_re_cover FROM re_cover rc WHERE rc.re_cover_id = rel.re_cover_id;
    
      v_res_id := acc_new.Run_Oper_By_Template(v_templ_prem
                                              ,par_slip_id
                                              ,v_re_cover.ent_id
                                              ,v_re_cover.re_cover_id
                                              ,doc.get_doc_status_id(par_slip_id)
                                              ,1
                                              ,v_re_cover.brutto_premium
                                              ,'INS');
    
      v_res_id := acc_new.Run_Oper_By_Template(v_templ_com
                                              ,par_slip_id
                                              ,v_re_cover.ent_id
                                              ,v_re_cover.re_cover_id
                                              ,doc.get_doc_status_id(par_slip_id)
                                              ,1
                                              ,v_re_cover.commission
                                              ,'INS');
    
    END LOOP;
    doc.set_doc_status(par_slip_id, v_status);
  END;

  PROCEDURE slip_oplata(par_slip_id IN NUMBER) IS
    v_re_slip        ven_re_slip%ROWTYPE;
    v_re_slip_header ven_re_slip_header%ROWTYPE;
  
    v_Payment_Templ_ID    NUMBER;
    v_Rate_Type_ID        NUMBER;
    v_Company_Bank_Acc_ID NUMBER;
    sum_all               NUMBER;
  BEGIN
  
    -- проверяем наличие счетов 
    SELECT nvl(SUM(p.amount), 0)
      INTO sum_all
      FROM ac_payment p
      JOIN document d
        ON d.document_id = p.payment_id
     WHERE d.doc_templ_id =
           (SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'OrderPaymentOutReins')
       AND d.document_id IN (SELECT dd.child_id FROM doc_doc dd WHERE dd.parent_id = par_slip_id);
  
    SELECT rs.* INTO v_re_slip FROM ven_re_slip rs WHERE rs.re_slip_id = par_slip_id;
  
    SELECT rsh.*
      INTO v_re_slip_header
      FROM ven_re_slip_header rsh
     WHERE rsh.re_slip_header_id = v_re_slip.re_slip_header_id;
  
    IF (v_re_slip.netto_premium > sum_all)
    THEN
    
      SELECT pt.payment_templ_id
        INTO v_Payment_Templ_ID
        FROM ac_payment_templ pt
       WHERE pt.brief = 'OrderPaymentOutReins';
    
      SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
    
      SELECT cba.id
        INTO v_Company_Bank_Acc_ID
        FROM cn_contact_bank_acc cba
       WHERE cba.contact_id IN (SELECT bc.contact_id FROM t_brand_company bc)
         AND cba.id =
             (SELECT MAX(cbas.id)
                FROM cn_contact_bank_acc cbas
               WHERE cbas.contact_id IN (SELECT bcs.contact_id FROM t_brand_company bcs));
    
      pkg_payment.create_paymnt_sheduler(v_Payment_Templ_ID
                                        ,v_re_slip.payment_term_id
                                        ,v_re_slip.netto_premium - sum_all
                                        ,v_re_slip_header.fund_id
                                        ,v_re_slip_header.fund_pay_id
                                        ,v_Rate_Type_ID
                                        ,CASE WHEN
                                         v_re_slip_header.fund_id = v_re_slip_header.fund_pay_id THEN 1.0 ELSE
                                         acc_new.Get_Rate_By_ID(v_Rate_Type_ID
                                                               ,v_re_slip_header.fund_id
                                                               ,v_re_slip.accept_date) END
                                        ,v_re_slip_header.reinsurer_id
                                        ,NULL
                                        ,v_Company_Bank_Acc_ID
                                        ,v_re_slip.first_pay_date
                                        ,v_re_slip.re_slip_id);
    END IF;
  
  END;

  PROCEDURE slip_payment(par_re_claim_header_id IN NUMBER) IS
    v_re_slip         ven_re_slip%ROWTYPE;
    v_re_slip_header  ven_re_slip_header%ROWTYPE;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_re_claim_header ven_re_claim_header%ROWTYPE;
  
    v_Payment_Templ_ID     NUMBER;
    v_Payment_Term_ID      NUMBER;
    v_collection_method_id NUMBER;
    v_Rate_Type_ID         NUMBER;
    v_Company_Bank_Acc_ID  NUMBER;
  
    sum_all NUMBER;
  
  BEGIN
  
    SELECT rch.*
      INTO v_re_claim_header
      FROM ven_re_claim_header rch
     WHERE rch.re_claim_header_id = par_re_claim_header_id;
  
    SELECT rc.*
      INTO v_re_claim
      FROM ven_re_claim rc
     WHERE rc.re_claim_header_id = par_re_claim_header_id
       AND rc.seqno = (SELECT MAX(rc1.seqno)
                         FROM ven_re_claim rc1
                        WHERE rc1.re_claim_header_id = par_re_claim_header_id);
  
    SELECT rs.* INTO v_re_slip FROM ven_re_slip rs WHERE rs.re_slip_id = v_re_claim_header.re_slip_id;
  
    SELECT rsh.*
      INTO v_re_slip_header
      FROM ven_re_slip_header rsh
     WHERE rsh.re_slip_header_id = v_re_slip.re_slip_header_id;
  
    SELECT pt.payment_templ_id
      INTO v_Payment_Templ_ID
      FROM ac_payment_templ pt
     WHERE pt.brief = 'AccPayOutReins';
  
    SELECT nvl(SUM(ap.amount), 0)
      INTO sum_all
      FROM ac_payment ap
      JOIN document d1
        ON d1.document_id = ap.payment_id
      JOIN doc_templ dt
        ON dt.doc_templ_id = d1.doc_templ_id
      JOIN doc_doc dd
        ON dd.child_id = ap.payment_id
     WHERE dt.brief = 'AccPayOutReins'
       AND dd.parent_id = par_re_claim_header_id;
  
    SELECT rt.rate_type_id INTO v_Rate_Type_ID FROM Rate_Type rt WHERE rt.brief = 'ЦБ';
  
    SELECT cba.id
      INTO v_Company_Bank_Acc_ID
      FROM cn_contact_bank_acc cba
     WHERE cba.contact_id IN (SELECT bc.contact_id FROM t_brand_company bc)
       AND cba.id =
           (SELECT MAX(cbas.id)
              FROM cn_contact_bank_acc cbas
             WHERE cbas.contact_id IN (SELECT bcs.contact_id FROM t_brand_company bcs));
  
    SELECT c.id
      INTO v_collection_method_id
      FROM t_collection_method c
     WHERE c.description = 'Безналичный расчет';
  
    SELECT pt.id
      INTO v_Payment_Term_ID
      FROM t_payment_terms pt
     WHERE pt.description = 'Единовременно'
       AND pt.collection_method_id = v_collection_method_id;
  
    IF (v_re_claim.re_payment_sum - sum_all) > 0
    THEN
    
      pkg_payment.create_paymnt_sheduler(v_Payment_Templ_ID
                                        ,v_Payment_Term_ID
                                        ,(v_re_claim.re_payment_sum - sum_all)
                                        ,v_re_slip_header.fund_id
                                        ,v_re_slip_header.fund_pay_id
                                        ,v_Rate_Type_ID
                                        ,acc_new.Get_Cross_Rate_By_Id(v_Rate_Type_ID
                                                                     ,v_re_slip_header.fund_id
                                                                     ,v_re_slip_header.fund_pay_id)
                                        ,v_re_slip_header.reinsurer_id
                                        ,NULL
                                        ,v_Company_Bank_Acc_ID
                                        ,v_re_claim.re_claim_status_date
                                        ,v_re_claim.re_claim_header_id);
    END IF;
    COMMIT;
  
  END;

  PROCEDURE slip_payment_nach(par_re_claim_header_id IN NUMBER) IS
    v_templ_prem      NUMBER;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_re_claim_header ven_re_claim_header%ROWTYPE;
    v_res_id          NUMBER;
  BEGIN
  
    SELECT rch.*
      INTO v_re_claim_header
      FROM ven_re_claim_header rch
     WHERE rch.re_claim_header_id = par_re_claim_header_id;
  
    SELECT rc.*
      INTO v_re_claim
      FROM ven_re_claim rc
     WHERE rc.re_claim_header_id = par_re_claim_header_id
       AND rc.seqno = (SELECT MAX(rc1.seqno)
                         FROM ven_re_claim       rc1
                             ,ven_c_claim_status cc
                        WHERE rc1.re_claim_header_id = par_re_claim_header_id
                          AND rc1.status_id = cc.c_claim_status_id
                          AND cc.brief != 'ЗАКРЫТО');
  
    SELECT o.oper_templ_id
      INTO v_templ_prem
      FROM oper_templ o
     WHERE o.brief = 'НачДоляВыплИсхПрстрх';
  
    FOR cur IN (SELECT rd.ent_id
                      ,rd.re_damage_id
                      ,rd.re_payment_sum
                  FROM ven_re_damage rd
                 WHERE rd.re_claim_id = v_re_claim.re_claim_id)
    LOOP
      v_res_id := acc_new.Run_Oper_By_Template(v_templ_prem
                                              ,v_re_claim.re_claim_id
                                              ,cur.ent_id
                                              ,cur.re_damage_id
                                              ,doc.get_doc_status_id(v_re_claim.re_claim_id)
                                              ,1
                                              ,cur.re_payment_sum
                                              ,'INS');
    END LOOP;
  END;

  FUNCTION copy_ver_slip(par_slip_id IN NUMBER) RETURN NUMBER IS
    v_re_slip ven_re_slip%ROWTYPE;
  BEGIN
  
    SELECT t.* INTO v_re_slip FROM ven_re_slip t WHERE t.re_slip_id = par_slip_id;
  
    -- новый ид версии
    SELECT sq_re_slip.nextval INTO v_re_slip.re_slip_id FROM dual;
  
    v_re_slip.start_date     := trunc(SYSDATE, 'dd');
    v_re_slip.ver_num        := v_re_slip.ver_num + 1;
    v_re_slip.re_amount      := 0;
    v_re_slip.brutto_premium := 0;
    v_re_slip.commission     := 0;
    v_re_slip.netto_premium  := 0;
  
    INSERT INTO ven_re_slip VALUES v_re_slip;
  
    -- статус
    doc.set_doc_status(v_re_slip.re_slip_id, 'PROPOSAL');
  
    INSERT INTO ven_re_line_slip
      (RE_LINE_SLIP_ID
      ,RE_SLIP_ID
      ,LINE_NUMBER
      ,LIMIT
      ,RETENTION_PERC
      ,RETENTION_VAL
      ,PART_PERC
      ,PART_SUM
      ,TARIFF_INS
      ,RE_TARIFF
      ,COMMISSION_PERC)
      SELECT sq_re_line_slip.nextval
            ,v_re_slip.re_slip_id
            ,t.line_number
            ,t.limit
            ,t.retention_perc
            ,t.retention_val
            ,t.part_perc
            ,t.part_sum
            ,t.tariff_ins
            ,t.re_tariff
            ,t.commission_perc
        FROM ven_re_line_slip t
       WHERE t.re_slip_id = par_slip_id;
  
    UPDATE ven_re_slip_header s SET s.last_slip_id = v_re_slip.re_slip_id;
  
    RETURN v_re_slip.re_slip_id;
  END;

END pkg_re_slip;
/

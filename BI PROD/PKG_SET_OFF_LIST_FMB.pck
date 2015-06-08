CREATE OR REPLACE PACKAGE pkg_set_off_list_fmb IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 02.10.2013 16:56:18
  -- Purpose : Логика формы SET_OFF_LIST.FMB

  PROCEDURE annulate_set_off_kv
  (
    par_tmp_doc_id          tmp_set_off.document_id%TYPE
   ,par_parent_doc_id       document.document_id%TYPE
   ,par_parent_doc_reg_date document.reg_date%TYPE
  );

  PROCEDURE update_docs(par_payment_type_id ac_payment.payment_type_id%TYPE);

  PROCEDURE insert_docs
  (
    par_payment_reg_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_payment_id          ac_payment.payment_id%TYPE
   ,par_payment_type_id     ac_payment.payment_type_id%TYPE
   ,par_doc_templ_brief     doc_templ.brief%TYPE
   ,par_due_date            ac_payment.due_date%TYPE
   ,par_grace_date          ac_payment.grace_date%TYPE
   ,par_payment_data        payment_register_item.payment_data%TYPE
  );

  PROCEDURE update_ids(par_payment_reg_item_id payment_register_item.payment_register_item_id%TYPE);

END pkg_set_off_list_fmb; 
/
CREATE OR REPLACE PACKAGE BODY pkg_set_off_list_fmb IS

  PROCEDURE annulate_set_off_kv
  (
    par_tmp_doc_id          tmp_set_off.document_id%TYPE
   ,par_parent_doc_id       document.document_id%TYPE
   ,par_parent_doc_reg_date document.reg_date%TYPE
  ) IS
    v_doc_copy_id   document.document_id%TYPE;
    v_dso_id        doc_set_off.doc_set_off_id%TYPE;
    v_dt_copy_brief doc_templ.brief%TYPE;
    v_dso_pp        document.document_id%TYPE;
  BEGIN
    SELECT d_c.document_id
          ,dso.doc_set_off_id
          ,dt_c.brief
      INTO v_doc_copy_id
          ,v_dso_id
          ,v_dt_copy_brief
      FROM doc_doc dd
          ,document d_c
          ,doc_templ dt_c
          ,doc_set_off dso
          ,document d_dso
          ,doc_status_ref dsr_dso
          ,document d_epg
          ,(SELECT * FROM doc_templ WHERE brief = 'PAYMENT') dt_epg
     WHERE dd.child_id = par_tmp_doc_id
       AND dd.child_id = d_c.document_id
       AND dt_c.doc_templ_id = d_c.doc_templ_id
       AND dd.parent_id = dso.child_doc_id
       AND dso.doc_set_off_id = d_dso.document_id
       AND dsr_dso.doc_status_ref_id = d_dso.doc_status_ref_id
       AND dsr_dso.brief != 'ANNULATED'
       AND dso.parent_doc_id = d_epg.document_id
       AND d_epg.doc_templ_id = dt_epg.doc_templ_id;
    --если дата документа в открытом периоде, то удаляем документ
    IF pkg_period_closed.check_closed_date(par_parent_doc_reg_date) = par_parent_doc_reg_date
    THEN
      pkg_payment.dso_before_delete(v_dso_id);
      DELETE FROM document d WHERE d.document_id = v_dso_id;
    
      --301648 удаляем ЗАЧП, связанный с ПП
      SELECT dso.doc_set_off_id
        INTO v_dso_pp
        FROM ins.doc_set_off dso
       WHERE dso.parent_doc_id = par_tmp_doc_id;
    
      IF v_dso_pp IS NOT NULL
      THEN
        DELETE FROM document d WHERE d.document_id = v_dso_pp;
      END IF;
    
      --обновляем информацию по распознаванию
      UPDATE ins.payment_register_item pri
         SET pri.recognized_payment_id = NULL
       WHERE pri.recognized_payment_id = v_doc_copy_id;
      -- 
    
      DELETE FROM document d WHERE d.document_id = v_doc_copy_id;
      DELETE FROM document d WHERE d.document_id = par_parent_doc_id;
    
      DELETE FROM doc_doc dd
       WHERE dd.child_id = v_doc_copy_id
         AND dd.parent_id = par_parent_doc_id;
    ELSE
      --если дата документа в закрытом периоде, то аннулируем документ            
      pkg_a7.cancel_a7(par_parent_doc_id, SYSDATE);
    END IF;
  END annulate_set_off_kv;

  PROCEDURE update_docs(par_payment_type_id ac_payment.payment_type_id%TYPE) IS
    v_set_off_amount       doc_set_off.set_off_amount%TYPE;
    v_set_off_child_amount doc_set_off.set_off_child_amount%TYPE;
  BEGIN
    FOR vr_upd IN (SELECT tso.doc_set_off_id
                         ,tso.main_set_off_amount
                         ,tso.list_set_off_amount
                         ,tso.set_off_rate
                         ,dsr.brief AS doc_status_brief
                     FROM tmp_set_off    tso
                         ,doc_set_off    dso
                         ,document       dc
                         ,doc_status_ref dsr
                    WHERE tso.doc_set_off_id = dso.doc_set_off_id
                      AND dso.doc_set_off_id = dc.document_id
                      AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                      AND tso.cancel_set_off_date IS NULL
                      AND (((par_payment_type_id = 0) AND
                          ((tso.main_set_off_amount <> dso.set_off_amount) OR
                          (tso.list_set_off_amount <> dso.set_off_child_amount))) OR
                          ((par_payment_type_id = 1) AND
                          ((tso.main_set_off_amount <> dso.set_off_child_amount) OR
                          (tso.list_set_off_amount <> dso.set_off_amount)))))
    LOOP
      IF par_payment_type_id = 0
      THEN
        v_set_off_amount       := vr_upd.main_set_off_amount;
        v_set_off_child_amount := vr_upd.list_set_off_amount;
      ELSIF par_payment_type_id = 1
      THEN
        v_set_off_amount       := vr_upd.list_set_off_amount;
        v_set_off_child_amount := vr_upd.main_set_off_amount;
      ELSE
        raise_application_error(-20001
                               ,'Значение вида платежа "' || to_char(par_payment_type_id) ||
                                '" не поддерживается');
      END IF;
    
      UPDATE doc_set_off dso
         SET dso.set_off_amount       = v_set_off_amount
            ,dso.set_off_child_amount = v_set_off_child_amount
            ,dso.set_off_rate         = vr_upd.set_off_rate
       WHERE dso.doc_set_off_id = vr_upd.doc_set_off_id;
      -- Перепроводим зачет
      IF vr_upd.doc_status_brief = 'NEW'
      THEN
        doc.set_doc_status(vr_upd.doc_set_off_id, 'CANCEL');
        doc.set_doc_status(vr_upd.doc_set_off_id, 'NEW');
      END IF;
    END LOOP;
  END update_docs;

  PROCEDURE insert_docs
  (
    par_payment_reg_item_id payment_register_item.payment_register_item_id%TYPE
   ,par_payment_id          ac_payment.payment_id%TYPE
   ,par_payment_type_id     ac_payment.payment_type_id%TYPE
   ,par_doc_templ_brief     doc_templ.brief%TYPE
   ,par_due_date            ac_payment.due_date%TYPE
   ,par_grace_date          ac_payment.grace_date%TYPE
   ,par_payment_data        payment_register_item.payment_data%TYPE
  ) IS
    v_agent_id       ag_contract_header.agent_id%TYPE;
    v_sposob_opl     t_collection_method.description%TYPE;
    v_pp_templ       doc_templ.brief%TYPE;
    v_cre_pd4_err    VARCHAR2(250);
    v_cre_zachet_err VARCHAR2(250);
  
    v_child_doc_id          doc_set_off.child_doc_id%TYPE;
    v_parent_doc_id         doc_set_off.parent_doc_id%TYPE;
    v_set_off_amount        doc_set_off.set_off_amount%TYPE;
    v_set_off_child_amount  doc_set_off.set_off_child_amount%TYPE;
    v_set_off_child_fund_id doc_set_off.set_off_child_fund_id%TYPE;
    v_set_off_fund_id       doc_set_off.set_off_fund_id%TYPE;
    v_reg_date              document.reg_date%TYPE;
    v_set_off_date          doc_set_off.set_off_date%TYPE;
    v_doc_set_off_id        doc_set_off.doc_set_off_id%TYPE;
  BEGIN
  
    --добавить документы по зачету, которых не было, но по которым установили сумму > 0
    FOR vr_ins IN (SELECT tso.main_set_off_amount
                         ,tso.list_set_off_amount
                         ,tso.document_id
                         ,tso.due_date
                         ,tso.set_off_rate
                         ,mf.fund_id              AS main_fund_id
                         ,lf.fund_id              AS list_fund_id
                         ,dt.brief                AS paydoc_brief
                     FROM tmp_set_off tso
                         ,document    dc
                         ,doc_templ   dt
                         ,fund        mf
                         ,fund        lf
                    WHERE tso.doc_set_off_id IS NULL
                      AND tso.document_id = dc.document_id
                      AND dc.doc_templ_id = dt.doc_templ_id
                      AND tso.main_set_off_amount > 0
                      AND tso.list_set_off_amount > 0
                      AND tso.main_fund_brief = mf.brief
                      AND tso.list_fund_brief = lf.brief
                    ORDER BY tso.due_date)
    LOOP
      --Проверка. ЕПГ нельзя привязывать к валютному договору
      pkg_payment_register.check_payment_currency(vr_ins.document_id, par_payment_id);
    
      --Чирков 301648: РОЛЬФ УДЕРЖАНИЕ НОЯБРЬ 2013
      --опредеяем ид договора, связанный с эпг из ЭР
      --определяем агента на удержании (если нет агента на удержании то NULL)           
      BEGIN
        SELECT pkg_payment_register.get_agent_with_ret(ph.policy_header_id)
          INTO v_agent_id
          FROM ven_ac_payment ac
              ,doc_doc dd
              ,p_policy p
              ,p_pol_header ph
              ,(SELECT dt.doc_templ_id FROM doc_templ dt WHERE dt.brief = 'PAYMENT') dt
         WHERE ac.payment_id = vr_ins.document_id --ЭПГ
           AND dd.child_id = ac.payment_id
           AND p.policy_id = dd.parent_id
           AND ph.policy_header_id = p.pol_header_id
           AND dt.doc_templ_id = ac.doc_templ_id
           AND doc.get_doc_status_brief(ac.payment_id) = 'TO_PAY'
           AND rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          v_agent_id := NULL;
      END;
    
      --опреределяем способ оплаты и шаблон ПП
      SELECT cm.description
            ,dt.brief
        INTO v_sposob_opl
            ,v_pp_templ
        FROM ven_ac_payment      ppvh
            ,t_collection_method cm
            ,doc_templ           dt
       WHERE cm.id = ppvh.collection_metod_id
         AND dt.doc_templ_id = ppvh.doc_templ_id
            --param
         AND ppvh.payment_id = par_payment_id;
      --301648: РОЛЬФ УДЕРЖАНИЕ НОЯБРЬ 2013
      -------------------------------------
    
      --Чирков 10.08.2011 Автоматическое формирование ПД4 если дата ПП или дата платежа из реестра
      --меньше даты выписки ПП
      --*******************************************************************************************
      -- По согласованию изменено на нахождение этой даты путем нахождения минимального значения трех дат:
      -- Даты ПП, Даты выписки и Даты платежа (из реестра)
    
      v_reg_date := least(par_due_date, par_grace_date, nvl(par_payment_data, par_due_date));
    
      --Если есть дата меньше чем срок платежа ППвх, то создаем ПД4
      --Проверяем, нет ли на ЭПГ зачитывающих документов? Если не Payment,
      --то значит PD4COPY или A7COPY
      IF vr_ins.paydoc_brief = 'PAYMENT'
         AND v_reg_date != par_grace_date
         AND NOT (par_doc_templ_brief IN ('PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF', 'PAYMENT_SETOFF'))
      THEN
      
        v_cre_pd4_err := pkg_payment_register.cre_pd4(p_pri                 => par_payment_reg_item_id
                                                     ,ap_epg_id             => vr_ins.document_id
                                                     ,p_list_set_off_amount => vr_ins.list_set_off_amount);
      
        IF v_cre_pd4_err IS NOT NULL
        THEN
          raise_application_error(-20001, v_cre_pd4_err);
        END IF;
      
      ELSIF v_agent_id IS NOT NULL
      THEN
        --если есть агент может удерживать комиссию то
        IF v_pp_templ = 'ППУКВ'
           AND v_sposob_opl = 'Удержание'
        THEN
          --:если это удержание КВ, то создаем документ Зачет удержания
          -- Всегда возвращается NULL
          v_cre_zachet_err := pkg_payment_register.cre_zachet_ucv(p_pri                   => par_payment_reg_item_id
                                                                 ,ap_epg_id               => vr_ins.document_id
                                                                 ,par_list_set_off_amount => vr_ins.list_set_off_amount);
        ELSE
          --:если это платеж, то создаем ПД4
        
          v_cre_pd4_err := pkg_payment_register.cre_pd4(p_pri                 => par_payment_reg_item_id
                                                       ,ap_epg_id             => vr_ins.document_id
                                                       ,p_list_set_off_amount => vr_ins.list_set_off_amount);
        
          IF v_cre_pd4_err IS NOT NULL
          THEN
            raise_application_error(-20001, v_cre_pd4_err);
          END IF;
        END IF;
      
      ELSE
        --*************************************************************************  
        IF par_payment_type_id = 0
        THEN
          v_child_doc_id          := vr_ins.document_id;
          v_parent_doc_id         := par_payment_id;
          v_set_off_amount        := vr_ins.main_set_off_amount;
          v_set_off_child_amount  := vr_ins.list_set_off_amount;
          v_set_off_child_fund_id := vr_ins.list_fund_id;
          v_set_off_fund_id       := vr_ins.main_fund_id;
        ELSIF par_payment_type_id = 1
        THEN
          v_child_doc_id          := par_payment_id;
          v_parent_doc_id         := vr_ins.document_id;
          v_set_off_amount        := vr_ins.list_set_off_amount;
          v_set_off_child_amount  := vr_ins.main_set_off_amount;
          v_set_off_child_fund_id := vr_ins.main_fund_id;
          v_set_off_fund_id       := vr_ins.list_fund_id;
        ELSE
          raise_application_error(-20001
                                 ,'Значение вида платежа "' || to_char(par_payment_type_id) ||
                                  '" не поддерживается');
        END IF;
      
        IF par_due_date > vr_ins.due_date
        THEN
          v_reg_date     := par_due_date;
          v_set_off_date := par_due_date;
        ELSE
          v_reg_date     := vr_ins.due_date;
          v_set_off_date := vr_ins.due_date;
        END IF;
      
        pkg_doc_set_off.insert_doc_set_off(par_reg_date              => v_reg_date
                                          ,par_child_doc_id          => v_child_doc_id
                                          ,par_parent_doc_id         => v_parent_doc_id
                                          ,par_pay_registry_item     => par_payment_reg_item_id
                                          ,par_set_off_amount        => v_set_off_amount
                                          ,par_set_off_child_amount  => v_set_off_child_amount
                                          ,par_set_off_child_fund_id => v_set_off_child_fund_id
                                          ,par_set_off_date          => v_set_off_date
                                          ,par_set_off_fund_id       => v_set_off_fund_id
                                          ,par_set_off_rate          => vr_ins.set_off_rate
                                          ,par_doc_set_off_id        => v_doc_set_off_id);
      
        doc.set_doc_status(v_doc_set_off_id, 'NEW');
      END IF;
    END LOOP;
  END insert_docs;

  PROCEDURE update_ids(par_payment_reg_item_id payment_register_item.payment_register_item_id%TYPE) IS
    v_ids payment_register_item.ids%TYPE;
  BEGIN
    --Чирков 12.12.2011 Просьба Ивачевой М., чтобы при отвязывании платежа сохранялся идс
    BEGIN
      SELECT nvl(ph1.ids, ph2.ids)
        INTO v_ids
        FROM doc_set_off  dso
            ,doc_doc      dd1
            ,p_policy     pp1
            ,p_pol_header ph1
            ,doc_doc      dd2_1
            ,doc_set_off  dso2
            ,doc_doc      dd2
            ,p_policy     pp2
            ,p_pol_header ph2
       WHERE dso.pay_registry_item = par_payment_reg_item_id
            --Ветка когда реестр разнесен с ПП на ЭПГ
         AND dso.parent_doc_id = dd1.child_id(+)
         AND dd1.parent_id = pp1.policy_id(+)
         AND pp1.pol_header_id = ph1.policy_header_id(+)
            --Ветка когда реестр разнесен с ПП на копию А7/ПД4
         AND dso.parent_doc_id = dd2_1.child_id(+)
         AND dd2_1.parent_id = dso2.child_doc_id(+)
         AND dso2.parent_doc_id = dd2.child_id(+)
         AND dd2.parent_id = pp2.policy_id(+)
         AND pp2.pol_header_id = ph2.policy_header_id(+)
         AND doc.get_doc_status_brief(dso.doc_set_off_id) != 'ANNULATED'
       GROUP BY nvl(ph1.ids, ph2.ids);
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        v_ids := NULL;
    END;
  
    UPDATE payment_register_item pri
       SET pri.pol_num = CASE
                           WHEN v_ids IS NOT NULL THEN
                            nvl(to_char(pri.ids), pri.pol_num)
                           ELSE
                            pri.pol_num
                         END
          ,pri.ids     = v_ids
     WHERE pri.payment_register_item_id = par_payment_reg_item_id
       AND pri.status = 40;
  END;

END pkg_set_off_list_fmb;
/

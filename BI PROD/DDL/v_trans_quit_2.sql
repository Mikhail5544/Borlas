CREATE OR REPLACE FORCE VIEW V_TRANS_QUIT_2 AS
SELECT  q1.ids                      "Идентификатор ДС", 
        q1.pol_ser_num              "Номер полиса",
        q1.issuer_name              "Страхователь",
        CASE
          WHEN q2.document_id IN ( SELECT  d.document_id
                                     FROM  doc_doc dd,
                                           document d
                                     WHERE dd.parent_id = q1.policy_id
                                       AND dd.child_id = d.document_id
                                       AND d.doc_templ_id = 
                                             ( SELECT  dt.doc_templ_id 
                                                 FROM  doc_templ dt 
                                                 WHERE dt.brief = 
                                                            'PAYMENT_SETOFF' ) ) 
            THEN '3 Возврат'                          
          WHEN q2.document_id IN ( SELECT  td.p_trans_decline_id 
                                     FROM  p_pol_decline   pd,
                                           p_trans_decline td
                                     WHERE pd.p_policy_id = q1.policy_id
                                       AND pd.p_pol_decline_id = 
                                             td.p_pol_decline_id ) 
            THEN '2 Корректировка'
          WHEN DOC.Get_Doc_Status_Brief( q1.policy_id, SYSDATE ) IN
                 ( 'TO_QUIT', 'TO_QUIT_CHECK_READY', 'TO_QUIT_CHECKED',
                   'QUIT_REQ_QUERY', 'QUIT_REQ_GET', 'QUIT_TO_PAY', 'QUIT' ) 
            THEN '1 Прекращение'
          ELSE '4 Остальные'
        END                         "Вид проводки",
        q1.version_num              "Номер версии",
        q1.start_date               "Дата версии",
        q2.oper_name                "Наименование операции",
        q2.trans_name               "Наименование проводки",
        q2.trans_date               "Дата проводки",
        q2.dt_account_num           "Счет Дт",
        q2.ct_account_num           "Счет Кт",
        q2.acc_fund_brief           "Валюта счета",
        q2.acc_amount               "Сумма в валюте счета",
        q2.trans_fund_brief         "Валюта приведения",
        q2.trans_amount             "Сумма в валюте приведения",
        q2.acc_rate                 "Курс приведения",
        q2.a1_dt_analytic_type_name "Дт аналитика 1",
        q2.a1_dt_uro_name           "Дт значение аналитики 1",
        q2.a2_dt_analytic_type_name "Дт аналитика 2",
        q2.a2_dt_uro_name           "Дт значение аналитики 2",
        q2.a3_dt_analytic_type_name "Дт аналитика 3",
        q2.a3_dt_uro_name           "Дт значение аналитики 3",
        q2.a4_dt_analytic_type_name "Дт аналитика 4",
        q2.a4_dt_uro_name           "Дт значение аналитики 4",
        q2.a5_dt_analytic_type_name "Дт аналитика 5",
        q2.a5_dt_uro_name           "Дт значение аналитики 5",
        q2.a1_ct_analytic_type_name "Кт аналитика 1",
        q2.a1_ct_uro_name           "Кт значение аналитики 1",
        q2.a2_ct_analytic_type_name "Кт аналитика 2",
        q2.a2_ct_uro_name           "Кт значение аналитики 2",
        q2.a3_ct_analytic_type_name "Кт аналитика 3",
        q2.a3_ct_uro_name           "Кт значение аналитики 3",
        q2.a4_ct_analytic_type_name "Кт аналитика 4",
        q2.a4_ct_uro_name           "Кт значение аналитики 4",
        q2.a5_ct_analytic_type_name "Кт аналитика 5",
        q2.a5_ct_uro_name           "Кт значение аналитики 5",
        q1.trans_id                 "ИД проводки",
        q2.document_id              "ИД документа",
        q2.note                     "Примечание"
  FROM  ( -- Проводки, привязанные к ДС по cover_id (id покрытия)
          SELECT  ph.ids, t.trans_id,
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                    p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date,
                  p.policy_id  
            FROM  p_policy     p,
                  as_asset     a,
                  ven_p_cover  pc,
                  trans        t,
                  p_pol_header ph,
                  v_pol_issuer vi
            WHERE p.policy_id         = a.p_policy_id
              AND a.as_asset_id       = pc.as_asset_id    
              AND t.obj_uro_id        = pc.p_cover_id
              AND t.obj_ure_id        = pc.ent_id
              AND ph.policy_header_id = p.pol_header_id
              AND p.policy_id         = vi.policy_id
              -- Кроме проводок, привязанных к последней версии ДС через операцию
              AND NOT EXISTS 
                  ( SELECT  '1'
                      FROM  oper     o,
                            p_policy p2
                      WHERE o.oper_id = t.oper_id 
                        AND o.document_id = p2.policy_id
                        AND p2.policy_id = PKG_POLICY.Get_Last_Version( 
                                                         ph.policy_header_id ) )
              -- Кроме корректирующих проводок по ДС
              AND NOT EXISTS 
                  ( SELECT  '1'
                      FROM  oper            o,
                            p_trans_decline td,
                            p_pol_decline   pd,
                            p_policy        p2
                      WHERE o.oper_id = t.oper_id 
                        AND o.document_id = td.p_trans_decline_id
                        AND td.p_pol_decline_id = pd.p_pol_decline_id
                        AND pd.p_policy_id = p2.policy_id
                        AND p2.pol_header_id = ph.policy_header_id )
          UNION 
          -- Проводки, привязанные к ДС по damage_id (id ущерба)   
          SELECT  ph.ids, t.trans_id,
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                    p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date,
                  p.policy_id   
            FROM  p_policy     p,
                  as_asset     a,
                  ven_p_cover  pc,
                  c_damage     cd,
                  trans        t,
                  p_pol_header ph,
                  v_pol_issuer vi
            WHERE p.policy_id         = a.p_policy_id
              AND a.as_asset_id       = pc.as_asset_id    
              AND pc.p_cover_id       = cd.p_cover_id
              AND t.obj_uro_id        = cd.c_damage_id
              AND t.obj_ure_id        = cd.ent_id
              AND ph.policy_header_id = p.pol_header_id 
              AND p.policy_id         = vi.policy_id
              -- Кроме проводок, привязанных к последней версии ДС через операцию
              AND NOT EXISTS 
                  ( SELECT  '1'
                      FROM  oper     o,
                            p_policy p2
                      WHERE o.oper_id = t.oper_id 
                        AND o.document_id = p2.policy_id
                        AND p2.policy_id = PKG_POLICY.Get_Last_Version( 
                                                         ph.policy_header_id ) )
          UNION
          -- Проводки, привязанных к последней версии ДС через операцию    
          SELECT  ph.ids, t.trans_id,
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                    p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date,
                  p.policy_id  
            FROM  p_policy     p,
                  trans        t,
                  oper         o,
                  p_pol_header ph,
                  v_pol_issuer vi
            WHERE p.policy_id         = o.document_id
              AND t.oper_id           = o.oper_id
              AND ph.policy_header_id = p.pol_header_id 
              AND p.policy_id         = vi.policy_id
          UNION
          -- Корректирующие проводки    
          SELECT  ph.ids, t.trans_id,
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                    p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date,
                  p.policy_id   
            FROM  p_policy        p,
                  p_pol_decline   pd,
                  p_trans_decline td,
                  trans           t,
                  oper            o,
                  p_pol_header    ph,
                  v_pol_issuer    vi
            WHERE p.policy_id         = pd.p_policy_id
              AND pd.p_pol_decline_id = td.p_pol_decline_id
              AND t.oper_id           = o.oper_id
              AND o.document_id       = td.p_trans_decline_id
              AND ph.policy_header_id = p.pol_header_id 
              AND p.policy_id         = vi.policy_id 
          UNION
          -- Проводки по возврату
          SELECT  ph.ids, t.trans_id,
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                    p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date,
                  p.policy_id
            FROM  p_pol_header ph,
                  trans        t,
                  oper         o,
                  p_policy     p,
                  doc_doc      dd,
                  document     d,
                  v_pol_issuer vi
            WHERE ph.policy_header_id = p.pol_header_id    
              AND p.policy_id = dd.parent_id
              AND dd.child_id = d.document_id
              AND d.doc_templ_id = ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                       WHERE dt.brief = 'PAYMENT_SETOFF' ) 
              AND p.policy_id = vi.policy_id 
              AND d.document_id = o.document_id
              AND o.oper_id = t.oper_id ) q1,
        ( SELECT  t.trans_id,
                  o.document_id, o.name oper_name, t.trans_date,
                  ad.num dt_account_num, ac.num ct_account_num,
                  t.acc_amount,
                  t.trans_amount,
                  atd1.name a1_dt_analytic_type_name,
                  atd2.name a2_dt_analytic_type_name,
                  atd3.name a3_dt_analytic_type_name,
                  atd4.name a4_dt_analytic_type_name,
                  atd5.name a5_dt_analytic_type_name,
                  atc1.name a1_ct_analytic_type_name,
                  atc2.name a2_ct_analytic_type_name,
                  atc3.name a3_ct_analytic_type_name,
                  atc4.name a4_ct_analytic_type_name,
                  atc5.name a5_ct_analytic_type_name,
                  ENT.Obj_Name(t.a1_dt_ure_id, t.a1_dt_uro_id) a1_dt_uro_name,
                  ENT.Obj_Name(t.a2_dt_ure_id, t.a2_dt_uro_id) a2_dt_uro_name,
                  ENT.Obj_Name(t.a3_dt_ure_id, t.a3_dt_uro_id) a3_dt_uro_name,
                  ENT.Obj_Name(t.a4_dt_ure_id, t.a4_dt_uro_id) a4_dt_uro_name,
                  ENT.Obj_Name(t.a5_dt_ure_id, t.a5_dt_uro_id) a5_dt_uro_name,
                  ENT.Obj_Name(t.a1_ct_ure_id, t.a1_ct_uro_id) a1_ct_uro_name,
                  ENT.Obj_Name(t.a2_ct_ure_id, t.a2_ct_uro_id) a2_ct_uro_name,
                  ENT.Obj_Name(t.a3_ct_ure_id, t.a3_ct_uro_id) a3_ct_uro_name,
                  ENT.Obj_Name(t.a4_ct_ure_id, t.a4_ct_uro_id) a4_ct_uro_name,
                  ENT.Obj_Name(t.a5_ct_ure_id, t.a5_ct_uro_id) a5_ct_uro_name,
                  t.note,
                  tt.name    trans_name,
                  f.brief    trans_fund_brief,
                  facc.brief acc_fund_brief,
                  t.acc_rate
            FROM  oper          o,
                  trans         t,
                  account       ad,
                  account       ac,
                  analytic_type atd1,
                  analytic_type atd2,
                  analytic_type atd3,
                  analytic_type atd4,
                  analytic_type atd5,
                  analytic_type atc1,
                  analytic_type atc2,
                  analytic_type atc3,
                  analytic_type atc4,
                  analytic_type atc5,
                  trans_templ   tt,
                  fund          f,
                  fund          facc
            WHERE o.oper_id = t.oper_id 
              AND t.dt_account_id = ad.account_id
              AND t.ct_account_id = ac.account_id 
              AND ad.a1_analytic_type_id = atd1.analytic_type_id(+)
              AND ad.a2_analytic_type_id = atd2.analytic_type_id(+)
              AND ad.a3_analytic_type_id = atd3.analytic_type_id(+)
              AND ad.a4_analytic_type_id = atd4.analytic_type_id(+)
              AND ad.a5_analytic_type_id = atd5.analytic_type_id(+)
              AND ac.a1_analytic_type_id = atc1.analytic_type_id(+)
              AND ac.a2_analytic_type_id = atc2.analytic_type_id(+)
              AND ac.a3_analytic_type_id = atc3.analytic_type_id(+)
              AND ac.a4_analytic_type_id = atc4.analytic_type_id(+)
              AND ac.a5_analytic_type_id = atc5.analytic_type_id(+) 
              AND t.trans_templ_id = tt.trans_templ_id 
              AND t.trans_fund_id = f.fund_id
              AND t.acc_fund_id = facc.fund_id ) q2                    
  WHERE q1.trans_id = q2.trans_id
  ORDER BY q1.ids, "Вид проводки", "Номер версии", q2.oper_name
/*SELECT  ph.ids                      "Идентификатор ДС", 
        DECODE( p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num )              
                                    "Номер полиса",
        q2.oper_name                "Наименование операции",
        q2.trans_name               "Наименование проводки",
        q2.trans_date               "Дата проводки",
        q2.dt_account_num           "Счет Дт",
        q2.ct_account_num           "Счет Кт",
        q2.acc_fund_brief           "Валюта счета",
        q2.acc_amount               "Сумма в валюте счета",
        q2.trans_fund_brief         "Валюта приведения",
        q2.trans_amount             "Сумма в валюте приведения",
        q2.acc_rate                 "Курс приведения",
        q2.a1_dt_analytic_type_name "Дт аналитика 1",
        q2.a1_dt_uro_name           "Дт значение аналитики 1",
        q2.a2_dt_analytic_type_name "Дт аналитика 2",
        q2.a2_dt_uro_name           "Дт значение аналитики 2",
        q2.a3_dt_analytic_type_name "Дт аналитика 3",
        q2.a3_dt_uro_name           "Дт значение аналитики 3",
        q2.a4_dt_analytic_type_name "Дт аналитика 4",
        q2.a4_dt_uro_name           "Дт значение аналитики 4",
        q2.a5_dt_analytic_type_name "Дт аналитика 5",
        q2.a5_dt_uro_name           "Дт значение аналитики 5",
        q2.a1_ct_analytic_type_name "Кт аналитика 1",
        q2.a1_ct_uro_name           "Кт значение аналитики 1",
        q2.a2_ct_analytic_type_name "Кт аналитика 2",
        q2.a2_ct_uro_name           "Кт значение аналитики 2",
        q2.a3_ct_analytic_type_name "Кт аналитика 3",
        q2.a3_ct_uro_name           "Кт значение аналитики 3",
        q2.a4_ct_analytic_type_name "Кт аналитика 4",
        q2.a4_ct_uro_name           "Кт значение аналитики 4",
        q2.a5_ct_analytic_type_name "Кт аналитика 5",
        q2.a5_ct_uro_name           "Кт значение аналитики 5",
      --  q1.document_name            "Документ",
        q2.note                     "Примечание",
        q1.trans_id                 "ИД проводки"
  FROM  p_policy     p,
        p_pol_header ph,
        ( SELECT  p.policy_id, t.trans_id
            FROM  p_policy    p,
                  as_asset    a,
                  ven_p_cover pc,
                  trans       t
            WHERE p.policy_id   = a.p_policy_id
              AND a.as_asset_id = pc.as_asset_id    
              AND t.obj_uro_id  = pc.p_cover_id
              AND t.obj_ure_id  = pc.ent_id
          UNION    
          SELECT  p.policy_id, t.trans_id
            FROM  p_policy    p,
                  as_asset    a,
                  ven_p_cover pc,
                  c_damage    cd,
                  trans       t
            WHERE p.policy_id   = a.p_policy_id
              AND a.as_asset_id = pc.as_asset_id    
              AND pc.p_cover_id = cd.p_cover_id
              AND t.obj_uro_id  = cd.c_damage_id
              AND t.obj_ure_id  = cd.ent_id
          UNION    
          SELECT  p.policy_id, t.trans_id
            FROM  p_policy p,
                  trans    t,
                  oper     o
            WHERE p.policy_id = o.document_id
              AND t.oper_id   = o.oper_id
          UNION    
          SELECT  p.policy_id, t.trans_id
            FROM  p_policy        p,
                  p_pol_decline   pd,
                  p_trans_decline td,
                  trans           t,
                  oper            o
            WHERE p.policy_id         = pd.p_policy_id
              AND pd.p_pol_decline_id = td.p_pol_decline_id
              AND t.oper_id           = o.oper_id
              AND o.document_id       = td.p_trans_decline_id ) q1,
        ( SELECT  t.trans_id,
                  o.document_id, o.name oper_name, t.trans_date,
                  ad.num dt_account_num, ac.num ct_account_num,
                  t.acc_amount,
                  t.trans_amount,
                  atd1.name a1_dt_analytic_type_name,
                  atd2.name a2_dt_analytic_type_name,
                  atd3.name a3_dt_analytic_type_name,
                  atd4.name a4_dt_analytic_type_name,
                  atd5.name a5_dt_analytic_type_name,
                  atc1.name a1_ct_analytic_type_name,
                  atc2.name a2_ct_analytic_type_name,
                  atc3.name a3_ct_analytic_type_name,
                  atc4.name a4_ct_analytic_type_name,
                  atc5.name a5_ct_analytic_type_name,
                  ENT.Obj_Name(t.a1_dt_ure_id, t.a1_dt_uro_id) a1_dt_uro_name,
                  ENT.Obj_Name(t.a2_dt_ure_id, t.a2_dt_uro_id) a2_dt_uro_name,
                  ENT.Obj_Name(t.a3_dt_ure_id, t.a3_dt_uro_id) a3_dt_uro_name,
                  ENT.Obj_Name(t.a4_dt_ure_id, t.a4_dt_uro_id) a4_dt_uro_name,
                  ENT.Obj_Name(t.a5_dt_ure_id, t.a5_dt_uro_id) a5_dt_uro_name,
                  ENT.Obj_Name(t.a1_ct_ure_id, t.a1_ct_uro_id) a1_ct_uro_name,
                  ENT.Obj_Name(t.a2_ct_ure_id, t.a2_ct_uro_id) a2_ct_uro_name,
                  ENT.Obj_Name(t.a3_ct_ure_id, t.a3_ct_uro_id) a3_ct_uro_name,
                  ENT.Obj_Name(t.a4_ct_ure_id, t.a4_ct_uro_id) a4_ct_uro_name,
                  ENT.Obj_Name(t.a5_ct_ure_id, t.a5_ct_uro_id) a5_ct_uro_name,
                  t.note,
                  tt.name    trans_name,
                  f.brief    trans_fund_brief,
                  facc.brief acc_fund_brief,
                  t.acc_rate
            FROM  oper          o,
                  trans         t,
                  account       ad,
                  account       ac,
                  analytic_type atd1,
                  analytic_type atd2,
                  analytic_type atd3,
                  analytic_type atd4,
                  analytic_type atd5,
                  analytic_type atc1,
                  analytic_type atc2,
                  analytic_type atc3,
                  analytic_type atc4,
                  analytic_type atc5,
                  trans_templ   tt,
                  fund          f,
                  fund          facc
            WHERE o.oper_id = t.oper_id 
              AND t.dt_account_id = ad.account_id
              AND t.ct_account_id = ac.account_id 
              AND ad.a1_analytic_type_id = atd1.analytic_type_id(+)
              AND ad.a2_analytic_type_id = atd2.analytic_type_id(+)
              AND ad.a3_analytic_type_id = atd3.analytic_type_id(+)
              AND ad.a4_analytic_type_id = atd4.analytic_type_id(+)
              AND ad.a5_analytic_type_id = atd5.analytic_type_id(+)
              AND ac.a1_analytic_type_id = atc1.analytic_type_id(+)
              AND ac.a2_analytic_type_id = atc2.analytic_type_id(+)
              AND ac.a3_analytic_type_id = atc3.analytic_type_id(+)
              AND ac.a4_analytic_type_id = atc4.analytic_type_id(+)
              AND ac.a5_analytic_type_id = atc5.analytic_type_id(+) 
              AND t.trans_templ_id = tt.trans_templ_id 
              AND t.trans_fund_id = f.fund_id
              AND t.acc_fund_id = facc.fund_id ) q2                    
  WHERE q1.trans_id = q2.trans_id
    AND ph.policy_header_id = p.pol_header_id
    AND p.policy_id = q1.policy_id
    AND ph.ids = 1250007307
*/

/*
SELECT  q.ids, q.trans_id
  FROM  ( SELECT  ph.ids, t.trans_id
            FROM  p_policy     p,
                  as_asset     a,
                  ven_p_cover  pc,
                  trans        t,
                  p_pol_header ph
            WHERE p.policy_id         = a.p_policy_id
              AND a.as_asset_id       = pc.as_asset_id    
              AND t.obj_uro_id        = pc.p_cover_id
              AND t.obj_ure_id        = pc.ent_id
              AND ph.policy_header_id = p.pol_header_id
         UNION    
         SELECT  ph.ids, t.trans_id
            FROM  p_policy     p,
                  as_asset     a,
                  ven_p_cover  pc,
                  c_damage     cd,
                  trans        t,
                  p_pol_header ph
            WHERE p.policy_id         = a.p_policy_id
              AND a.as_asset_id       = pc.as_asset_id    
              AND pc.p_cover_id       = cd.p_cover_id
              AND t.obj_uro_id        = cd.c_damage_id
              AND t.obj_ure_id        = cd.ent_id
              AND ph.policy_header_id = p.pol_header_id 
          UNION    
         SELECT  ph.ids, t.trans_id
            FROM  p_policy     p,
                  trans        t,
                  oper         o,
                  p_pol_header ph
            WHERE p.policy_id         = o.document_id
              AND t.oper_id           = o.oper_id
              AND ph.policy_header_id = p.pol_header_id 
          UNION    
         SELECT  ph.ids, t.trans_id
            FROM  p_policy        p,
                  p_pol_decline   pd,
                  p_trans_decline td,
                  trans           t,
                  oper            o,
                  p_pol_header    ph
            WHERE p.policy_id         = pd.p_policy_id
              AND pd.p_pol_decline_id = td.p_pol_decline_id
              AND t.oper_id           = o.oper_id
              AND o.document_id       = td.p_trans_decline_id
              AND ph.policy_header_id = p.pol_header_id ) q        
    WHERE q.ids = 1250007307
*/
/*
SELECT  t.trans_id
  FROM  p_policy        p,
        as_asset        a,
        ven_p_cover     pc,
        c_damage        cd,
        p_pol_decline   pd,
        p_trans_decline td,
        trans           t,
        oper            o,
        p_pol_header    ph
  WHERE p.policy_id         = a.p_policy_id
    AND a.as_asset_id       = pc.as_asset_id    
    AND pc.p_cover_id       = cd.p_cover_id(+)
    AND p.policy_id         = pd.p_policy_id
    AND pd.p_pol_decline_id = td.p_pol_decline_id(+)
    AND t.oper_id           = o.oper_id
    AND (    (     t.obj_uro_id = pc.p_cover_id
               AND t.obj_ure_id = pc.ent_id )   
          OR (     t.obj_uro_id = cd.c_damage_id(+)
               AND t.obj_ure_id = cd.ent_id(+) ) 
          OR ( o.document_id = p.policy_id )
          OR ( o.document_id = td.p_trans_decline_id(+) ) )
    AND ph.policy_header_id = p.pol_header_id
    AND ph.ids = 1250007307 */
            
/*SELECT  ph.ids
  FROM  p_pol_header ph,
        ( SELECT  q1.pol_header_id, t1.trans_id
            FROM  trans t1,
                  ( SELECT  p.pol_header_id, pc.p_cover_id obj_uro_id, 
                            pc.ent_id obj_ure_id
                      FROM  ven_p_cover pc,
                            as_asset    a,
                            p_policy    p
                      WHERE pc.as_asset_id = a.as_asset_id
                        AND a.p_policy_id = p.policy_id
                    UNION ALL
                    SELECT  p.pol_header_id, cd.c_damage_id obj_uro_id, 
                            cd.ent_id obj_ure_id
                      FROM  p_cover  pc,
                            as_asset a,
                            c_damage cd,     
                            p_policy p
                      WHERE pc.as_asset_id = a.as_asset_id
                        AND a.p_policy_id = p.policy_id
                        AND pc.p_cover_id = cd.p_cover_id ) q1
            WHERE t1.obj_uro_id = q1.obj_uro_id
              AND t1.obj_ure_id = q1.obj_ure_id
          UNION
          SELECT  q2.pol_header_id, t2.trans_id
            FROM  trans t2,
                  oper  o2,
                    -- по договору
                  ( SELECT  p.pol_header_id, p.policy_id document_id
                      FROM  p_policy p
                    UNION ALL
                    -- корректирующие
                    SELECT  p.pol_header_id, td.p_trans_decline_id document_id
                      FROM  p_policy            p,
                            p_pol_decline       pd,
                            p_trans_decline td
                      WHERE p.policy_id = pd.p_policy_id
                        AND pd.p_pol_decline_id = td.p_pol_decline_id ) q2
            WHERE t2.oper_id = o2.oper_id            
              AND o2.document_id = o2.document_id ) qq3
  WHERE ph.policy_header_id = qq3.pol_header_id
    AND ph.ids = 1250007307  
*/    
    
              
/*          SELECT  ph.ids, COUNT( DISTINCT cd.c_damage_id )
            FROM  p_cover      pc,
                  as_asset     a,
                  c_damage     cd,     
                  p_policy     p,
                  p_pol_header ph
            WHERE pc.as_asset_id= a.as_asset_id
              AND a.p_policy_id = p.policy_id
              AND pc.p_cover_id = cd.p_cover_id
              AND p.pol_header_id = ph.policy_header_id 
              AND ph.start_date > TO_DATE( '01.01.2010', 'DD.MM.RRRR' )
            GROUP BY ph.ids
            HAVING COUNT( DISTINCT cd.c_damage_id ) > 0  
*/
/*        SELECT  ph.ids, COUNT( DISTINCT t.trans_id )
            FROM  p_cover      pc,
                  as_asset     a,
                  c_damage     cd,     
                  p_policy     p,
                  p_pol_header ph,
                  trans        t
            WHERE pc.as_asset_id= a.as_asset_id
              AND a.p_policy_id = p.policy_id
              AND pc.p_cover_id = cd.p_cover_id
              AND p.pol_header_id = ph.policy_header_id 
              AND ph.start_date > TO_DATE( '01.01.2010', 'DD.MM.RRRR' )
              AND t.obj_uro_id = cd.c_damage_id
               AND t.obj_ure_id = cd.ent_id
            GROUP BY ph.ids
            HAVING COUNT( DISTINCT t.trans_id ) > 0  
*/
;


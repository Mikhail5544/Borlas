CREATE OR REPLACE FORCE VIEW V_TRANS_QUIT AS
SELECT  TO_CHAR( q1.ids )           "Идентификатор ДС", 
        q1.pol_ser_num              "Номер полиса",
        q1.issuer_name              "Страхователь",
        q1.trans_type               "Вид проводки",
        q1.version_num              "Номер версии",
        q1.start_date               "Дата версии",
        q2.oper_name                "Наименование операции",
        q2.trans_name               "Наименование проводки",
        q2.trans_date               "Дата проводки",
        q2.dt_account_num           "Счет Дт",
        --q2.dt_char                  "Дт А/П",
        q2.ct_account_num           "Счет Кт",
        --q2.ct_char                  "Кт А/П",
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
        q1.document_name            "Документ",
        q2.note                     "Примечание"
  FROM  ( SELECT  ph.ids ids, 
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                                     p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  DECODE( DOC.Get_Doc_Status_Brief( p.policy_id, SYSDATE ),
                    -- 'QUIT_DECL',           'По договору',
                    'TO_QUIT',             'Прекращение',
                    'TO_QUIT_CHECK_READY', 'Прекращение',
                    'TO_QUIT_CHECKED',     'Прекращение',
                    'QUIT_REQ_QUERY',      'Прекращение',
                    'QUIT_REQ_GET',        'Прекращение',
                    'QUIT_TO_PAY',         'Прекращение',
                    'QUIT',                'Прекращение',
                                           'По договору' ) trans_type,
                  DECODE( DOC.Get_Doc_Status_Brief( p.policy_id, SYSDATE ),
                    -- 'QUIT_DECL',           4,
                    'TO_QUIT',             1,
                    'TO_QUIT_CHECK_READY', 1,
                    'TO_QUIT_CHECKED',     1,
                    'QUIT_REQ_QUERY',      1,
                    'QUIT_REQ_GET',        1,
                    'QUIT_TO_PAY',         1,
                    'QUIT',                1,
                                           1000 - p.version_num ) trans_order,
                  ENT.Obj_Name( p.ent_id, p.policy_id ) document_name,
                  p.policy_id document_id,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date
            FROM  p_pol_header ph,
                  ven_p_policy p,
                  v_pol_issuer vi
            WHERE ph.policy_header_id = p.pol_header_id
              AND p.policy_id = vi.policy_id
          UNION
          SELECT  ph.ids ids, 
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                                     p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  'Корректирующие' trans_type,
                  3 trans_order,
                  ENT.Obj_Name( td.ent_id, td.p_trans_decline_id ) document_name,
                  td.p_trans_decline_id document_id,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date
            FROM  p_pol_header        ph,
                  p_policy            p,
                  p_pol_decline       pd,
                  ven_p_trans_decline td,
                  v_pol_issuer        vi
            WHERE ph.policy_header_id = p.pol_header_id    
              AND p.policy_id = pd.p_policy_id
              AND pd.p_pol_decline_id = td.p_pol_decline_id
              AND p.policy_id = vi.policy_id
          UNION    
          SELECT  ph.ids ids, 
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                                     p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  'Возврат' trans_type,
                  2 trans_order,
                  ENT.Obj_Name( d.ent_id, d.document_id ) document_name,
                  d.document_id document_id,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date
            FROM  p_pol_header ph,
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
          UNION    
          SELECT  ph.ids ids, 
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                                     p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  'Платежи' trans_type,
                  ( 2000 - p.version_num ) trans_order,
                  ENT.Obj_Name( d.ent_id, d.document_id ) document_name,
                  d.document_id document_id,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date
            FROM  p_pol_header ph,
                  p_policy     p,
                  doc_doc      dd,
                  document     d,
                  v_pol_issuer vi
            WHERE ph.policy_header_id = p.pol_header_id    
              AND p.policy_id = dd.parent_id
              AND dd.child_id = d.document_id
              AND d.doc_templ_id = ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                       WHERE dt.brief = 'PAYMENT' ) 
              AND p.policy_id = vi.policy_id
          UNION
          SELECT  ph.ids ids, 
                  DECODE( p.pol_ser, NULL, p.pol_num, 
                                     p.pol_ser || '-' || p.pol_num ) pol_ser_num,
                  'Зачет платежей' trans_type,
                  ( 3000 - p.version_num ) trans_order,
                  ENT.Obj_Name( q.ent_id, q.doc_set_off_id ) document_name,
                  q.doc_set_off_id document_id,
                  vi.contact_name issuer_name,
                  p.version_num, 
                  p.start_date
            FROM  p_pol_header    ph,
                  p_policy        p,
                  v_pol_issuer    vi,
                  doc_doc         dd1,
                  document        d1, -- 'PAYMENT'
                  ( SELECT  dso1.ent_id, dso1.doc_set_off_id, 
                            dso1.parent_doc_id
                      FROM  ven_doc_set_off dso1
                    UNION
                    SELECT  dso2.ent_id, dso2.doc_set_off_id, 
                            dso1.parent_doc_id
                      FROM  ven_doc_set_off dso1,  
                            document        d2, -- 'A7'
                            doc_doc         dd2,
                            document        d3, -- 'A7COPY'
                            ven_doc_set_off dso2
                      WHERE dso1.child_doc_id = d2.document_id
                        AND d2.doc_templ_id = 
                              ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                  WHERE dt.brief = 'A7' )
                        AND d2.document_id = dd2.parent_id
                        AND dd2.child_id = d3.document_id
                        AND d3.doc_templ_id = 
                              ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                  WHERE dt.brief = 'A7COPY' )
                        AND d3.document_id = dso2.parent_doc_id
                    UNION
                    SELECT  dso2.ent_id, dso2.doc_set_off_id, 
                            dso1.parent_doc_id
                      FROM  ven_doc_set_off dso1,  
                            document        d2, -- 'PD4'
                            doc_doc         dd2,
                            document        d3, -- 'PD4COPY'
                            ven_doc_set_off dso2
                      WHERE dso1.child_doc_id = d2.document_id
                        AND d2.doc_templ_id = 
                              ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                  WHERE dt.brief = 'PD4' )
                        AND d2.document_id = dd2.parent_id
                        AND dd2.child_id = d3.document_id
                        AND d3.doc_templ_id = 
                              ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                  WHERE dt.brief = 'PD4COPY' )
                        AND d3.document_id = dso2.parent_doc_id ) q
            WHERE ph.policy_header_id = p.pol_header_id
              AND p.policy_id = vi.policy_id  
              AND p.policy_id = dd1.parent_id
              AND dd1.child_id = d1.document_id
              AND d1.doc_templ_id = ( SELECT  dt.doc_templ_id FROM doc_templ dt 
                                        WHERE dt.brief = 'PAYMENT' ) 
              AND d1.document_id = q.parent_doc_id 
                   ) q1,
        ( SELECT  o.document_id, o.name oper_name, t.trans_date,
                  ad.num dt_account_num, ac.num ct_account_num,
                  t.acc_amount,
                  t.trans_amount,
                  ad.characteristics dt_char,
                  ac.characteristics ct_char,
                  t.trans_id,
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
  WHERE q1.document_id = q2.document_id
    -- AND q1.ids = 1920025424
  ORDER BY q1.ids, q1.trans_order, q2.oper_name
;


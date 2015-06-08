CREATE OR REPLACE FORCE VIEW INS_DWH.V_POLICY_AGENT_BSO_SUM_STATUS AS
SELECT  p.pol_num,                                                 -- 1  - Номер договора страхования
        p.pol_ser,                                                 -- 2  - Серия договора страхования
        pr.description product_name,                               -- 3  - Продукт по договору 
        p.notice_num,                                              -- 4  - Номер заявления по договору страхования
        vi.contact_name,                                           -- 5  - ФИО Страхователя по договору страхования
        ins.Fn_Obj_Name( a.ent_id, a.as_asset_id ) asset_name,     -- 6  - ФИО Застрахованного лица по договору страхования
        ph.start_date pol_start_date,                              -- 7  - Дата начала договора страхования (дата "с")
        p.end_date pol_end_date,                                   -- 8  - Дата окончания договора страхования
        d.num ad_num,                                              -- 9  - Номер агентского договора агента по договору страхования
        ins.ENT.Obj_Name( c.ent_id, c.contact_id ) agent_name,     -- 10 - Наименование агента по договору страхования
        ins.DOC.Get_Doc_Status_Name( pad.p_policy_agent_doc_id, 
          SYSDATE ) agent_status,                                  -- 11 - Статус Агента по договору страхования
        pad.date_begin ad_start_date,                              -- 12 - Дата начала действия агента по договору страхования
        sc.description sales_ch_name,                              -- 13 - Канал продаж по договору страхования
        bt.name bso_type_name,                                     -- 14 - Тип БСО по договору страхования
        bs.series_name,                                            -- 15 - Серия БСО
        b.num bso_num,                                             -- 16 - Номер БСО
        bht.name bso_status_name,                                  -- 17 - Статус БСО
        DECODE( b.is_pol_num, 1, 
          'Использован как номер договора', '' ) is_pol_num,       -- 18 - Отметка об использовании
        dsr.name doc_status_name,                                  -- 19 - Статус договора страхования
        ds.change_date status_change_date,                         -- 20 - Дата присвоения статуса по договору страхования
        a.fee,                                                     -- 21 - Брутто-взнос по договору страхования (по последней версии)
        a.ins_amount,                                              -- 22 - Страховая сумма по договру страхования (по последней версии)
        a.ins_premium,                                             -- 23 - Страховая премия по договору страхования (по последней версии)
        ds.user_name                                               -- 24 - Учетная запись пользователя присвоившего соответствующий статус договору страхования
  FROM  ins.p_policy           p,
        ins.t_product          pr,
        ins.p_pol_header       ph, 
        ins.v_pol_issuer       vi,
        ins.v_as_asset_order   a,
        ins.p_policy_agent_doc pad,
        ins.ag_contract_header h,
        ins.contact            c,
        ins.document           d,
        ins.t_sales_channel    sc,
        ins.bso                b,
        ins.bso_series         bs,
        ins.bso_type           bt,
        ins.bso_hist_type      bht,
        ins.bso_hist           bh,
        ins.doc_status         ds,
        ins.doc_status_ref     dsr
  WHERE ph.product_id = pr.product_id
    AND p.pol_header_id = ph.policy_header_id
    AND ins.PKG_POLICY.Get_Last_Version( ph.policy_header_id ) = p.policy_id -- только последняя версия договора
    AND p.policy_id = vi.policy_id(+)
    AND p.policy_id = a.p_policy_id(+)
    AND p.pol_header_id = pad.policy_header_id(+)
    -- AND ins.DOC.Get_Doc_Status_Brief( pad.p_policy_agent_doc_id(+), SYSDATE ) = 'CURRENT' -- убрано по просьбе Т.Ким
    AND pad.ag_contract_header_id = h.ag_contract_header_id(+)
    AND h.ag_contract_header_id = d.document_id(+)
    AND h.agent_id = c.contact_id(+)
    AND ph.sales_channel_id = sc.id
    AND p.policy_id = b.policy_id(+)
    AND b.bso_series_id = bs.bso_series_id(+)
    AND bs.bso_type_id = bt.bso_type_id(+)
    AND b.bso_hist_id = bh.bso_hist_id(+)
    AND bh.hist_type_id = bht.bso_hist_type_id(+)
    AND p.policy_id = ds.document_id(+) 
    AND ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
    -- ПАРАМЕТРЫ ОТЧЕТА:
    -- Дата начала ДС с:
    AND ph.start_date >= ( SELECT  TO_DATE( param_value, 'DD.MM.YYYY' )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_DATE_FROM' )
    -- Дата начала ДС по:
    AND ph.start_date <= ( SELECT  TO_DATE( param_value, 'DD.MM.YYYY' )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_DATE_TO' )
    -- Канал продаж
    AND sc.description = ( SELECT  DECODE( param_value, '<Не задано>', sc.description, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_SALES_CHANNEL' )
    -- Статус ДС
    AND dsr.name =       ( SELECT  DECODE( param_value, '<Не задано>', dsr.name, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_POLICY_STATUS' )
    -- Продукт
    AND pr.description = ( SELECT  DECODE( param_value, '<Не задано>', pr.description, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_PRODUCT_NAME' )
    -- Агент по ДС
    AND ins.ENT.Obj_Name( c.ent_id, c.contact_id ) LIKE
                         ( SELECT  param_value || '%'
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_AGENT_NAME' )
    -- Пользователь, установивший статус
    AND ds.user_name =   ( SELECT  DECODE( param_value, '<Не задано>', ds.user_name, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_USER_NAME' )
;


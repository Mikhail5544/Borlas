CREATE OR REPLACE FORCE VIEW INS_DWH.V_POLICY_AGENT_BSO_SUM_STATUS AS
SELECT  p.pol_num,                                                 -- 1  - ����� �������� �����������
        p.pol_ser,                                                 -- 2  - ����� �������� �����������
        pr.description product_name,                               -- 3  - ������� �� �������� 
        p.notice_num,                                              -- 4  - ����� ��������� �� �������� �����������
        vi.contact_name,                                           -- 5  - ��� ������������ �� �������� �����������
        ins.Fn_Obj_Name( a.ent_id, a.as_asset_id ) asset_name,     -- 6  - ��� ��������������� ���� �� �������� �����������
        ph.start_date pol_start_date,                              -- 7  - ���� ������ �������� ����������� (���� "�")
        p.end_date pol_end_date,                                   -- 8  - ���� ��������� �������� �����������
        d.num ad_num,                                              -- 9  - ����� ���������� �������� ������ �� �������� �����������
        ins.ENT.Obj_Name( c.ent_id, c.contact_id ) agent_name,     -- 10 - ������������ ������ �� �������� �����������
        ins.DOC.Get_Doc_Status_Name( pad.p_policy_agent_doc_id, 
          SYSDATE ) agent_status,                                  -- 11 - ������ ������ �� �������� �����������
        pad.date_begin ad_start_date,                              -- 12 - ���� ������ �������� ������ �� �������� �����������
        sc.description sales_ch_name,                              -- 13 - ����� ������ �� �������� �����������
        bt.name bso_type_name,                                     -- 14 - ��� ��� �� �������� �����������
        bs.series_name,                                            -- 15 - ����� ���
        b.num bso_num,                                             -- 16 - ����� ���
        bht.name bso_status_name,                                  -- 17 - ������ ���
        DECODE( b.is_pol_num, 1, 
          '����������� ��� ����� ��������', '' ) is_pol_num,       -- 18 - ������� �� �������������
        dsr.name doc_status_name,                                  -- 19 - ������ �������� �����������
        ds.change_date status_change_date,                         -- 20 - ���� ���������� ������� �� �������� �����������
        a.fee,                                                     -- 21 - ������-����� �� �������� ����������� (�� ��������� ������)
        a.ins_amount,                                              -- 22 - ��������� ����� �� ������� ����������� (�� ��������� ������)
        a.ins_premium,                                             -- 23 - ��������� ������ �� �������� ����������� (�� ��������� ������)
        ds.user_name                                               -- 24 - ������� ������ ������������ ������������ ��������������� ������ �������� �����������
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
    AND ins.PKG_POLICY.Get_Last_Version( ph.policy_header_id ) = p.policy_id -- ������ ��������� ������ ��������
    AND p.policy_id = vi.policy_id(+)
    AND p.policy_id = a.p_policy_id(+)
    AND p.pol_header_id = pad.policy_header_id(+)
    -- AND ins.DOC.Get_Doc_Status_Brief( pad.p_policy_agent_doc_id(+), SYSDATE ) = 'CURRENT' -- ������ �� ������� �.���
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
    -- ��������� ������:
    -- ���� ������ �� �:
    AND ph.start_date >= ( SELECT  TO_DATE( param_value, 'DD.MM.YYYY' )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_DATE_FROM' )
    -- ���� ������ �� ��:
    AND ph.start_date <= ( SELECT  TO_DATE( param_value, 'DD.MM.YYYY' )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_DATE_TO' )
    -- ����� ������
    AND sc.description = ( SELECT  DECODE( param_value, '<�� ������>', sc.description, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_SALES_CHANNEL' )
    -- ������ ��
    AND dsr.name =       ( SELECT  DECODE( param_value, '<�� ������>', dsr.name, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_POLICY_STATUS' )
    -- �������
    AND pr.description = ( SELECT  DECODE( param_value, '<�� ������>', pr.description, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_PRODUCT_NAME' )
    -- ����� �� ��
    AND ins.ENT.Obj_Name( c.ent_id, c.contact_id ) LIKE
                         ( SELECT  param_value || '%'
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_AGENT_NAME' )
    -- ������������, ������������ ������
    AND ds.user_name =   ( SELECT  DECODE( param_value, '<�� ������>', ds.user_name, param_value )
                             FROM  ins_dwh.rep_param
                             WHERE rep_name = 'POLICY_GROUP_STATUS'
                               AND param_name = 'PAR_USER_NAME' )
;


CREATE MATERIALIZED VIEW INS_DWH.MV_CR_GENERAL_INFO
BUILD DEFERRED
REFRESH FORCE ON DEMAND
AS
SELECT  pp.policy_id, -- �� ������
       pp.pol_num AS policy_num,-- ����� ��������
       pp.notice_num,-- ����� ���������
       pr.description AS product,-- �������
       tLob.brief AS product_kode,-- ��� ���������
       tPrLn.description AS main_programm, -- �������� ��������� � ��������
       ph.start_date, -- ���� ������ �������� ��������
       pp.end_date, -- ���� ��������� ��������
       -- ���� �������� �������� � �����
       CEIL(MONTHS_BETWEEN(pp.end_date,ph.start_date)/12) AS act_period,
       pp.notice_date, -- ���� ����������� ��������� � �������
       pp.ins_amount, -- ����� ��������������� �� ��������
       pp.fee_payment_term,-- ������ ������ (� �����)
       ins.Pkg_Rep_Utils.get_admin_expenses (pp.policy_id) AS admin_expenses, -- ���������������� ��������
       (pp.premium - ins.Pkg_Rep_Utils.get_admin_expenses (pp.policy_id)) AS pol_premium, -- ������ ������ �� ��������
       pCov.premium,-- ������ �� �������� ���������
       pp.premium AS premium_year,-- ������� ������
       tpt.description AS period,-- �������������
       ins.Pkg_Rep_Utils.get_period_code (tpt.description) AS period_code,-- ��� �������������
       -- TODO: ������ ������ / ����� (���� �� ����� �������)
       -- TODO: ������������� ������� ������ / ����� (���� �� ����� �������)
       -- TODO: ���� ������ ������� ������ / ����� (���� �� ����� �������)
       -- ���������� ������ �� ��������
       ins.Pkg_Payment.get_pay_pol_header_amount_pfa(ph.start_date,SYSDATE,ph.policy_header_id) AS pay_premium,
       ap.due_date, -- �������� ���� �������
       ddsch.parent_amount part_amount,
       ap.payment_number,-- id ��������� �������
       ap1.due_date AS doc_pay_date,-- ���� ��������� ������
       ap1.doc_templ_id AS doc_pay_tipe, -- id ���� ��������� ������
       ap1.num AS doc_pay_num, -- ����� ��������� ������
       dof.set_off_amount, -- ����� ������
       ins.Ent.obj_name('CONTACT',agch.agent_id) AS agent,-- ��� ������
       dagch.num AS ag_num, -- ����� ���������� ��������
       ins.Ent.obj_name('CONTACT',agchLead.agent_id) AS agent_lead ,-- ��� ������������ ������
       ins.Ent.obj_name('CONTACT',agchRecr.agent_id) AS agent_recruter, -- ��������
       d.name AS agency, -- ��������
       ins.Doc.get_doc_status_name(pp.policy_id) AS doc_status,-- ������ �������� �� ������ ��������
        -- ���� ���������� �������
       ins.doc.get_last_doc_status_date(pp.policy_id) AS date_status,
      ins.Doc.get_status_date(pp.policy_id,'PRINTED') AS date_printed,
      -- ������� ��������
        ins.Ent.obj_name('CONTACT',qq2.contact_id) AS curator ,
      -- ������������ ��������
        ins.Ent.obj_name('CONTACT',qq1.contact_id) AS reg_meneger ,
       --  ���� ��������� �������������� �������
       ins.Pkg_Policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,ph.start_date) AS wait_period,
       f1.brief AS fund,-- ������ ���������������
       f2.brief AS fund_pay-- ������ ��������
   FROM ins.p_policy pp
    join ins.p_pol_header ph ON pp.policy_id = ph.policy_id
   left join ins.t_period tPer ON tPer.id = pp.waiting_period_id
   --������
   left join ins.p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   left join ins.document dagch on dagch.document_id = ppag.ag_contract_header_id
   left join ins.ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ins.ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
   left join ins.department d ON d.department_id = agch.agency_id
   left join ins.ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   left join ins.ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   left join ins.ag_contract agRecr ON agRecr.ag_contract_id = agc.contract_recrut_id
   left join ins.ag_contract_header agchRecr ON agchRecr.ag_contract_header_id = agRecr.contract_id
   left join ins.ag_category_agent agCatAg ON agCatAg.ag_category_agent_id = agc.category_id
   left join ins.policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id
   join ins.t_product pr ON pr.product_id = ph.product_id
   join ins.fund f1 ON f1.fund_id = ph.fund_id
   join ins.fund f2 ON f2.fund_id = ph.fund_pay_id
   -- �������� ����� �������� (���������)
   left join ins.as_asset ass ON ass.p_policy_id = pp.policy_id
   left join ins.p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   left join ins.t_prod_line_option tPrLnOp ON tPrLnOp.id = pCov.t_prod_line_option_id
   left join ins.t_product_line tPrLn ON tPrLn.id = tPrLnOp.product_line_id
   left join ins.t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
    --�������� ��� ���������
   left join ins.t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   left join ins.t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
    --�������� ��������� ���������
   left join ins.t_payment_terms tpt ON tpt.id = pp.payment_term_id
  left join ins.doc_doc ddsch on ddsch.parent_id = pp.policy_id
   left join ins.ac_payment ap ON ap.payment_id = ddsch.child_id --sch.document_id
   left join ins.doc_set_off dof ON dof.parent_doc_id = ap.payment_id
   left join ins.ven_ac_payment ap1 ON ap1.payment_id = dof.child_doc_id
   left join (SELECT ppc.contact_id, ppc.policy_id, row_number() over (partition by ppc.policy_id order by ppc.contact_id) rn
        FROM ins.p_policy_contact ppc, ins.t_contact_pol_role pr
        WHERE pr.id = ppc.contact_policy_role_id
        AND pr.brief = '�����������') qq1 on qq1.policy_id = pp.policy_id and qq1.rn = 1
   left join (SELECT ppc.contact_id, ppc.policy_id, row_number() over (partition by ppc.policy_id order by ppc.contact_id) rn
        FROM ins.p_policy_contact ppc, ins.t_contact_pol_role pr
        WHERE pr.id = ppc.contact_policy_role_id
        AND pr.brief = '�������') qq2 on qq1.policy_id = pp.policy_id and qq2.rn = 1
WHERE NVL(tPrLnT.brief,'RECOMMENDED') = 'RECOMMENDED'
   AND NVL(pAgSt.brief,'CURRENT') = 'CURRENT';


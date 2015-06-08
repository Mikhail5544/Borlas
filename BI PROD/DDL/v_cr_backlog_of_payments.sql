CREATE OR REPLACE FORCE VIEW V_CR_BACKLOG_OF_PAYMENTS AS
SELECT "PRODUCT_NAME","POL_SER","POL_NUM","CONTRACT_NUM","POLICE_ID","NOTICE_NUM","FIO_ASSUR_OBJ","START_DATE","END_DATE",/*"AGENT_ID","AGENT_LIADER",*/"AGENSY","PERIOD","PAYNMENT_NUMBER","DUE_DATE","PLAN_DATE","SET_OF_DATE","PROGRAMM_KODE","PROGRAMM_NAME","GRACE_DATE","PREMIUM","AMOUNT","FUND","FUND_PAY","STATUS_NAME"
FROM
(
SELECT
pr.description AS product_name, -- �������
       pp.pol_ser AS pol_ser, -- �����
       pp.pol_num AS pol_num, -- �����
       pp.num AS contract_num, -- ����� ��������
       pp.policy_id AS police_id, -- id ��������
       pp.notice_num AS notice_num,-- ����� ���������
       ass.NAME AS fio_assur_obj,
       --ent.obj_name('CONTACT',assur.assured_contact_id) AS fio_assur_obj,-- ��������������
       ph.start_date AS start_date, -- ���� ������ �������� ��������
       pp.end_date AS end_date, -- ���� ��������� �������� ��������
       --ent.obj_name('CONTACT',agch.agent_id) AS agent_id,-- ��� ������
       --ent.obj_name('CONTACT',agchLead.agent_id) AS agent_liader,-- ��� ������������ ������
       d.NAME AS agensy,-- ��������
       tpt.description AS period,-- �������������
       ap.payment_number AS paynment_number,-- id ��������� �������
       sch.due_date, -- ���� �����������
       sch.plan_date, --���� �� �������
       SYSDATE AS set_of_date, -- ������ �� ������������
       tLob.brief AS programm_kode,-- ��� ���������
       tPrLn.description AS programm_name, -- �������� ��������� � ��������
       sch.grace_date AS grace_date, -- ���� ��������� ��������� �������
       sch.part_amount AS premium,-- ������ ������ doc_doc.parent_amount (����� ������� �� ��������)  
       (SELECT NVL(SUM(DECODE(dd2.doc_doc_id,NULL,dof.set_off_amount,
                        pkg_rep_utils.a7pd4_copy_set_off_sum(dd2.child_id))),0)
          FROM
          doc_set_off dof
          LEFT JOIN doc_doc dd2 ON dd2.parent_id = dof.child_doc_id
          WHERE dof.parent_doc_id = ap.payment_id
            AND dof.cancel_date IS NULL
        ) AS amount, -- ����� �������
       (SELECT NVL(MIN(DECODE(dd2.doc_doc_id,NULL,DECODE(doc.get_last_doc_status_brief(ap.payment_id),'NEW',0,'TO_PAY',0,1),
                       DECODE(doc.get_last_doc_status_brief(dd2.child_id),'NEW',0,'TO_PAY',0,1)  )),0)
          FROM
          doc_set_off dof
          LEFT JOIN doc_doc dd2 ON dd2.parent_id = dof.child_doc_id
         WHERE dof.parent_doc_id = ap.payment_id
            AND dof.cancel_date IS NULL
       ) AS is_payed, -- ���� ������ ���������
       f1.brief AS fund, -- ������ ���������������
       f2.brief AS fund_pay, -- ������ ��������
       Doc.get_doc_status_name(ph.policy_id) status_name  --������ ��������
 FROM p_pol_header ph
   JOIN ven_p_policy pp ON pp.policy_id = ph.policy_id
   JOIN t_product pr ON pr.product_id = ph.product_id
   JOIN t_payment_terms tpt ON tpt.ID = pp.payment_term_id
  -- ������
   /*LEFT JOIN ven_p_policy_agent ppag ON ppag.policy_header_id = ph.policy_header_id
   LEFT JOIN ven_ag_contract_header agch ON agch.ag_contract_header_id = ppag.ag_contract_header_id*/
   LEFT JOIN department d ON d.department_id = ph.agency_id
   /*LEFT JOIN ven_ag_contract agc ON agch.last_ver_id = agc.ag_contract_id
   LEFT JOIN ven_ag_contract agLead ON agLead.ag_contract_id = agc.contract_leader_id
   LEFT JOIN ven_ag_contract_header agchLead ON agchLead.ag_contract_header_id = agLead.contract_id
   LEFT JOIN ven_policy_agent_status pAgSt ON pAgSt.policy_agent_status_id = ppag.status_id*/
   JOIN fund f1 ON f1.fund_id = ph.fund_id
   JOIN fund f2 ON f2.fund_id = ph.fund_pay_id
  -- �������� ����� �������� (���������)
   LEFT JOIN as_asset ass ON ass.p_policy_id = pp.policy_id
   LEFT JOIN as_assured assur ON assur.as_assured_id = ass.as_asset_id
   LEFT JOIN p_cover pCov ON pCov.as_asset_id = ass.as_asset_id
   LEFT JOIN t_prod_line_option tPrLnOp ON tPrLnOp.ID = pCov.t_prod_line_option_id
   LEFT JOIN t_product_line tPrLn ON tPrLn.ID = tPrLnOp.product_line_id
   LEFT JOIN t_product_line_type tPrLnT ON tPrLnT.product_line_type_id = tPrLn.product_line_type_id
  --�������� ��� ���������
   LEFT JOIN t_lob_line tLobLn ON tLobLn.t_lob_line_id = tPrLn.t_lob_line_id
   LEFT JOIN t_lob tLob ON tLob.t_lob_id = tLobLn.t_lob_id
  -- �������
   LEFT JOIN v_policy_payment_schedule sch ON sch.policy_id = pp.policy_id
   LEFT JOIN ac_payment ap ON ap.payment_id = sch.document_id  -- ������������ ����
   WHERE NVL(tPrLnT.brief,'RECOMMENDED') = 'RECOMMENDED'
   --AND NVL(pAgSt.brief,'CURRENT') = 'CURRENT'
   AND doc.get_doc_status_brief(pp.policy_id) NOT IN
       ('ANNULATED', 'STOP','CLOSE','BREAK','CANCEL', 'READY_TO_CANCEL')
   AND doc.get_last_doc_status_brief(ap.payment_id) IN ('NEW', 'TO_PAY')
   AND sch.grace_date < SYSDATE
   )t
   WHERE t.is_payed = 0
;


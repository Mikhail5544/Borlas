CREATE OR REPLACE VIEW  v_rep_ag_register_bank_br AS
SELECT DISTINCT ag.agent_name "������������ ������"
                ,ag.NUM "����� ���"
                ,ag.admin_num "����� ���������� ��������"
                ,last_value(ag.leg_pos) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "����������� ������"
                ,last_value(ag.NAME) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "���������"
                ,ag.DATE_BEGIN "���� ������ �������� ��"
                ,last_value(ag.DESCRIPTION) OVER(PARTITION BY ag.NUM ORDER BY ag.ac_date_end ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "����� ������"
                ,ins.doc.get_last_doc_status_name(ag.ag_contract_header_id) "������ ���������� ��������"
                ,agd.doc_status "������ �-� <���������� ��>"
  FROM ins.v_agn_contract  ag
      ,ins.V_AGN_DOCUMENTS agd
 WHERE agd.ag_contract_header_id = ag.ag_contract_header_id
   AND agd.doc_desc = '���������� ��'
   AND ag.DESCRIPTION IN ('����������'
                         ,'����������'
                         ,'�������������'
                         ,'������'
                         ,'���������� ��� ������'
                         ,'����������� ������ ������'
                         ,'��� ��������'
                         ,'����� ������ ������')
--and num='45048'

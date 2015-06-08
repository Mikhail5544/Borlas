CREATE OR REPLACE VIEW V_REP_AG_CONTRACT_SAV AS
SELECT s.ag_contract_header_id
      ,sch.brief
      ,agh.num "����� ������"
       ,c.obj_name_orig "��� ������"
       ,agh.date_begin "���� ������ ��"
       ,rf.name "������ ������"
       ,prod.product_id "�� ��������"
       ,prod.description "�������"
       ,s.t_ag_contract_sav_id "�� ������"
       ,pl.id "�� �����"
       ,pl.description "����"
       ,s.product_line_order "��������� �� �������"
       ,s.name_product_line_order "�������� ��������� �� �������"
       ,s.value_sav_order "���"
       ,s.note "�����������"
       ,s.start_date "���� ������ ��������"
       ,s.end_date "���� ��������� ��������"
       ,s.amount_from "����� �"
       ,s.amount_to "����� ��"
       ,s.term_ins_from "���� ����������� ��"
       ,s.term_ins_to "���� ����������� ��"
       ,decode(s.paym_term, 0, '���', 1, '����', 2, '������', '����������') "��� ������"
       ,decode(agh.with_retention
             ,0
             ,'��� ���������'
             ,1
             ,'� ����������'
             ,'����������') "���������"
       ,decode(s.with_nds, 1, '��� ���', 2, '��� �� ���', '����������') "��� � ��"
       ,decode(s.is_action, 1, '���������', '') is_action
       ,s.pay_ins_from "��� ������ ��"
       ,s.pay_ins_to "��� ������ ��"
       ,agh.rko "���"
       ,agh.storage_ds "�������� ���."
       ,(SELECT admin_num FROM ag_contract a WHERE a.ag_contract_id = agh.last_ver_id) "���������������� �����"
       ,s.assured_age_from
       ,s.assured_age_to
       ,decode(agh.select_commission_by,0,'�� ���� ������ �/�',1,'�� ���� ������ �/�',agh.select_commission_by) commission_by
  FROM ins.ven_ag_contract_header agh
      ,ins.t_ag_contract_sav      s
      ,ins.t_product              prod
      ,ins.t_product_line         pl
      ,ins.contact                c
      ,ins.document               d
      ,ins.doc_status_ref         rf
      ,ins.t_sales_channel        sch
 WHERE agh.ag_contract_header_id = s.ag_contract_header_id(+)
   AND s.product_id = prod.product_id(+)
   AND s.product_line_id = pl.id(+)
   AND agh.agent_id = c.contact_id
   AND agh.ag_contract_header_id = d.document_id
   AND d.doc_status_ref_id = rf.doc_status_ref_id
   AND agh.t_sales_channel_id = sch.id
   AND ((sch.brief IN ('BANK', 'BR') AND s.ag_contract_header_id IS NULL) OR
       s.ag_contract_header_id IS NOT NULL);

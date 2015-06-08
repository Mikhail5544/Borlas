CREATE OR REPLACE VIEW V_REP_DWO_NOTICE_JOURNAL AS
SELECT dn.dwo_notice_id AS "��"
       ,tdt.description AS "���"
       ,dn.ids AS "���"
       ,dn.payer_fio AS "������������"
       ,dn.central_office_date AS "���� ���. � ��"
       ,dsr.name AS "������"
       ,trunc(ds.start_date) AS "���� �������"
       ,tmr.name AS "������� ������"
       ,d.note AS "�����������"
       ,dn.payer_fio AS "��� �����������"
       ,regexp_replace(dn.card_num, '^(\d{4})(\d{8})(\d{4})$', '\1********\3') AS "����� �����"
       ,dn.card_fio AS "��� �� �����"
       ,dn.notice_fee AS "������ ���������� ������"
       ,ent.obj_name('T_PAYMENT_TERMS', dn.payment_term_id) AS "������������� �����. ������"
       ,dn.notice_writeoff_date AS "���� �������� �� ���������"
       ,dn.notice_date AS "���� ���������"
       ,dn.rt_date AS "���� ������ �� RT"
       ,ent.obj_name('SYS_USER', dn.author_id) AS "�����"
       ,CASE
         WHEN dn.prolongation_flag = 1 THEN
          '��'
         ELSE
          '���'
       END "�����������"
       ,trt.relationship_dsc AS "������� �� �������������"
       ,dn.card_month || '/' || dn.card_year AS "���� �����"
       ,tps.name AS "��� �����"
       ,dn.admin_costs AS "������ ���. ��������"
       ,f.name AS "������"
       ,dn.next_writeoff_date AS "����. ����. � ���� ���. ������"
       ,dn.roo_date AS "���� ����������� � ���"
       ,dn.rt_num AS "� ������ � RT"
       ,dn.dwo_notice_parent_id AS "�� ���������� ���������"
       ,dn.first_writeoff_date AS "����. ����. � ���� ���. ������"
       ,doc.get_doc_status_name(pph.policy_id) AS "������ �������� �����������"
       ,ent.obj_name('T_PERIOD', pp.pol_privilege_period_id) AS "�������� ������"
       ,pp.first_pay_date AS "���� ������� ������� �� ��"
       ,ent.obj_name('T_PRODUCT', pph.product_id) AS "�������"
       ,pp.end_date "���� ��������� ��"
       ,dn.acquiring_id AS "�� ���������"
       ,dn.mpos_id AS "�� mPos"
/*
      ,dn.DWO_NOTICE_ID
      ,dn.insured_fio
      ,dn.NOTICE_TYPE_ID
      ,pph.policy_id
      ,dn.INSURED_ID
      ,d.DOC_STATUS_ID
      ,d.DOC_STATUS_REF_ID
      ,dn.POLICY_HEADER_ID
      ,dn.PAYER_ID
      ,dn.insured_relation_id
      ,dn.CARD_TYPE_ID
      ,dn.PAY_FUND_ID
      ,dn.payment_term_id
      ,dn.plan_end_date
      ,dn.POL_PRIVILEGE_PERIOD_ID
      ,cp_payer.gender
      ,dn.rejection_reason_id
      ,cp_insured.gender
      ,tdt.brief
*/
  FROM dwo_notice         dn
      ,document           d
      ,p_pol_header       pph
      ,p_policy           pp
      ,t_dwo_notice_type  tdt
      ,doc_status_ref     dsr
      ,doc_status         ds
      ,t_payment_system   tps
      ,fund               f
      ,cn_person          cp_payer
      ,cn_person          cp_insured
      ,t_contact_rel_type trt
      ,t_mpos_rejection   tmr
 WHERE dn.dwo_notice_id = d.document_id
   AND dn.policy_header_id = pph.policy_header_id
   AND pph.policy_id = pp.policy_id
   AND dn.notice_type_id = tdt.t_dwo_notice_type_id
   AND d.doc_status_ref_id = dsr.doc_status_ref_id
   AND d.doc_status_id = ds.doc_status_id
   AND dn.card_type_id = tps.t_payment_system_id(+)
   AND dn.pay_fund_id = f.fund_id(+)
   AND dn.payer_id = cp_payer.contact_id(+)
   AND dn.insured_id = cp_insured.contact_id
   AND dn.insured_relation_id = trt.id(+)
   AND dn.rejection_reason_id = tmr.t_mpos_rejection_id(+) --and dn.notice_date between to_date('19.12.2009','dd.mm.yyyy') and to_date('19.12.2014','dd.mm.yyyy')
/*and dn.ids='4130307142'
and dn.PROLONGATION_FLAG=1*/;
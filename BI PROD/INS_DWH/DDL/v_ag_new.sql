CREATE OR REPLACE FORCE VIEW INS_DWH.V_AG_NEW AS
SELECT ach.num "� ��",
       ins.ent.obj_name('CONTACT',ach.agent_id) "��� ������",
       aca.category_name "���������",
       ins.ent.obj_name('DEPARTMENT',ac.agency_id) "���������",
       sc.DESCRIPTION "����� ������",
       ach.date_begin "���� ���������� ��",
       ins.doc.get_doc_status_name(ach.ag_contract_header_id) "������ ��",
       adt.DESCRIPTION "��� ���������",
       agd.doc_date "���� ���������",
       (SELECT MAX(ds.start_date)
          FROM ins.doc_status ds
         WHERE ds.document_id = agd.ag_documents_id
       ) "���� ���� ������� �-��",
       ins.doc.get_doc_status_name(agd.ag_documents_id) "������ �-��"

  FROM ins.ag_contract  ac,
       ins.ven_ag_contract_header ach,
       ins.ag_documents agd,
       ins.ag_doc_type  adt,
       ins.ag_category_agent aca,
       ins.t_sales_channel   sc
 WHERE ach.is_new = 1
   AND ach.ag_contract_header_id = agd.ag_contract_header_id
   AND adt.ag_doc_type_id = agd.ag_doc_type_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND ac.date_end = to_date('31.12.2999','dd.mm.yyyy') --������� ������
   AND ac.category_id = aca.ag_category_agent_id
   AND sc.ID = ach.t_sales_channel_id
   AND sc.brief IN ('MLM','SAS','GRSMoscow','GRSRegion','SAS 2')
   AND aca.brief IN ('AG','MN','DR','DR2')
   AND ach.date_begin >= TO_DATE('26.04.2010','dd.mm.yyyy')
ORDER BY ach.num,10
;


CREATE OR REPLACE FORCE VIEW INS_DWH.V_AG_NEW AS
SELECT ach.num "№ АД",
       ins.ent.obj_name('CONTACT',ach.agent_id) "ФИО агента",
       aca.category_name "Категория",
       ins.ent.obj_name('DEPARTMENT',ac.agency_id) "Агентство",
       sc.DESCRIPTION "Канал продаж",
       ach.date_begin "Дата заключения АД",
       ins.doc.get_doc_status_name(ach.ag_contract_header_id) "Статус АД",
       adt.DESCRIPTION "Тип документа",
       agd.doc_date "Дата документа",
       (SELECT MAX(ds.start_date)
          FROM ins.doc_status ds
         WHERE ds.document_id = agd.ag_documents_id
       ) "Дата посл статуса д-та",
       ins.doc.get_doc_status_name(agd.ag_documents_id) "Статус д-та"

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
   AND ac.date_end = to_date('31.12.2999','dd.mm.yyyy') --текущая версия
   AND ac.category_id = aca.ag_category_agent_id
   AND sc.ID = ach.t_sales_channel_id
   AND sc.brief IN ('MLM','SAS','GRSMoscow','GRSRegion','SAS 2')
   AND aca.brief IN ('AG','MN','DR','DR2')
   AND ach.date_begin >= TO_DATE('26.04.2010','dd.mm.yyyy')
ORDER BY ach.num,10
;


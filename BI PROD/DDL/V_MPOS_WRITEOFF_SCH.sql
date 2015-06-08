CREATE OR REPLACE VIEW V_MPOS_WRITEOFF_SCH AS
SELECT
/*
График списания mPos
Черных М. 29.09.2014
*/
 sch.mpos_writeoff_sch_id
,sch.mpos_writeoff_form_id
,sch.start_date
,sch.end_date
,dc.document_id
,dc.ent_id
,dc.num
,dc.doc_templ_id
,dc.note
,dc.reg_date
,dc.doc_status_id
,dc.doc_status_ref_id
,dsr.name                  doc_status_name
,dsr.brief                 doc_status_brief
  FROM mpos_writeoff_sch sch
      ,document          dc
      ,doc_status_ref    dsr
 WHERE sch.mpos_writeoff_sch_id = dc.document_id
   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
--380005 Григорьев Ю.А. Установка сортировки, чтобы отмененные платежи отображались в конце 
 ORDER BY CASE
            WHEN dsr.brief='CANCEL' THEN
             2
            ELSE
             1
          END
         ,sch.start_date;

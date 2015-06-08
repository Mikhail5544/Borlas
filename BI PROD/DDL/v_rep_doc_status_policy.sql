create or replace view v_rep_doc_status_policy as
SELECT vdt.brief, dsr.name, dsr.brief
  FROM ven_doc_templ_status dts
      ,doc_status_ref       dsr
      ,ven_doc_templ        vdt
 WHERE dts.doc_status_ref_id = dsr.doc_status_ref_id
   AND vdt.doc_templ_id = dts.doc_templ_id
   AND vdt.brief = 'POLICY';
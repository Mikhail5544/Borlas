CREATE OR REPLACE FORCE VIEW VGO_GATE_AGENT_REPORT AS
SELECT  c.AGENT_REPORT_ID     as AGENT_REPORT_ID,
		c.agent_report_id         as CODE,
    dsf.brief                 as DOC_STATUS,
		d.num                     as AGENT_REPORT_NUM,
		ach.ag_contract_header_id as AG_CONTRACT_HEADER_ID,
		--c.ag_contract_h_id as POLICY_HEADER_ID,
		c.REPORT_DATE             as REPORT_DATE,
		to_char(round(C.Av_Sum,2))         as KB_AMOUNT,
    ds.start_date             as CHANGE_STATUS_DATE,
    taa.brief                 as TYPE_AG_AV,
    aca.brief                 as category_agent,
    ach.agent_id              as CONTACT_ID,
    ava.Date_Begin            as DATE_BEGIN,
    ava.Date_End              as DATE_END
 FROM ins.agent_report c,
      ins.ag_vedom_av ava,
      ins.t_ag_av taa,
      ins.ag_category_agent aca,
      ins.ag_contract_header ach,
      insi.vgo_document_status_current ds,
      ins.document d,
      ins.doc_status_ref dsf
 WHERE ach.ag_contract_header_id = c.ag_contract_h_id
 and d.document_id = c.agent_report_id
 and ds.DOCUMENT_ID = c.agent_report_id
 and dsf.doc_status_ref_id = ds.DOC_STATUS_REF_ID
 and ava.ag_vedom_av_id = c.ag_vedom_av_id
 and taa.t_ag_av_id = ava.t_ag_av_id
 and ava.ag_category_agent_id = aca.ag_category_agent_id
;


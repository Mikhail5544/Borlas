create or replace view ins.v_rep_activity_meetings as
select a.ag_contract_header_id
,d.num
,a.report_date
,a.activity_meetings_count
FROM ins.ag_activity_meet_journal a
,ins.document d
WHERE a.ag_contract_header_id = d.document_id;
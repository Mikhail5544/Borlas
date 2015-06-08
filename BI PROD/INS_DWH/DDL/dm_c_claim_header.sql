create materialized view INS_DWH.DM_C_CLAIM_HEADER
refresh force on demand
as
select ch.c_claim_header_id,
       ch.num claim_num,
       ce.num event_num,
       ce.event_date,
       ce.reg_date event_reg_date,
       ins.doc.get_doc_status_name(cc.c_claim_id) claim_status
  from ins.ven_c_claim_header ch, ins.ven_c_event ce, ins.c_claim cc
 where ch.c_event_id = ce.c_event_id
   and ch.active_claim_id = cc.c_claim_id
union all
select -1 c_claim_header_id,
       'неопределено' claim_num,
       'неопределено'event_num,
       null event_date,
       null event_reg_date,
       'неопределено' claim_status
        from dual;


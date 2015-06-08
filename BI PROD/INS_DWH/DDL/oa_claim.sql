create or replace force view ins_dwh.oa_claim as
select ch.C_CLAIM_HEADER_ID,
       c.C_CLAIM_ID,
       c.CLAIM_STATUS_ID,
       c.seqno,
       ch.C_EVENT_ID,
       c.claim_status_date,
       c.payment_sum
from ins.ven_c_claim_header ch
join ins.ven_c_claim c on c.c_claim_header_id=ch.C_CLAIM_HEADER_ID;


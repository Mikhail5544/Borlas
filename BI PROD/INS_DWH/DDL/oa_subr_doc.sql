create or replace force view ins_dwh.oa_subr_doc as
select sd.C_SUBR_DOC_ID,
       sd.c_claim_header_id,
       sd.SUBR_AMOUNT,
       sd.t_reason_subr_id,
       least(sd.CLAIM_SEND_DATE,sd.WRIT_SEND_DATE,sd.AGREEMENT_DATE) reason_date
from ins.ven_C_SUBR_DOC sd;


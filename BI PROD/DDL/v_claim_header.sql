CREATE OR REPLACE FORCE VIEW V_CLAIM_HEADER AS
SELECT distinct
       Ch.c_claim_header_id,
       TCT.DESCRIPTION,
       CE.EVENT_DATE,
       CD.P_COVER_ID 
FROM VEN_C_DAMAGE CD,
     VEN_C_CLAIM CC,
     VEN_C_CLAIM_HEADER CH,
     VEN_C_EVENT CE,
     VEN_T_CATASTROPHE_TYPE TCT
 WHERE CD.C_CLAIM_ID = CC.C_CLAIM_ID
   AND CC.c_claim_header_id = CH.c_claim_header_id
   AND CE.c_event_id = CH.c_event_id
   and TCT.id = CE.catastrophe_type_id;


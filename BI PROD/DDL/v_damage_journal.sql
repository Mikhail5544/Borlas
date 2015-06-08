CREATE OR REPLACE FORCE VIEW V_DAMAGE_JOURNAL AS
SELECT   ent.obj_name(RC.ent_id,RC.re_cover_id) re_cover_name,
         RD.re_damage_id,
         RC.re_cover_id,
         RC.re_slip_id, 
         CE.event_date, TDC.description, CD.payment_sum, RD.re_payment_sum
  FROM VEN_RE_COVER RC,
       VEN_T_DAMAGE_CODE TDC,  
       VEN_RE_DAMAGE RD,
       VEN_C_DAMAGE CD,
       VEN_C_CLAIM CC,
       VEN_C_CLAIM_HEADER CH,
       VEN_C_EVENT CE
  WHERE RC.RE_cover_id=RD.re_cover_id 
    AND RD.damage_id=CD.c_damage_id
    AND TDC.id=CD.t_damage_code_id
    AND CD.c_claim_id=CC.c_claim_id
    AND CC.c_claim_header_id=CH.c_claim_header_id
    AND CH.c_event_id=CE.c_event_id;


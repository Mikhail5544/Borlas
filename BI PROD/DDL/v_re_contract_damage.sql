create or replace force view v_re_contract_damage as
select rc.re_slip_id
     , rc.re_bordero_id
     , rc.re_cover_id
     , rc.p_cover_id
     , cch.c_claim_header_id
     , cc.c_claim_id
     , cd.c_damage_id
from re_cover rc
   , c_claim_header cch
   , c_claim cc
   , c_damage cd
where cch.p_cover_id = rc.p_cover_id
  and cc.c_claim_header_id = cch.c_claim_header_id
  and cd.c_claim_id = cc.c_claim_id;


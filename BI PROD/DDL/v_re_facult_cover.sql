create or replace force view v_re_facult_cover as
select pc.p_cover_id,
       rmc.num,
       c.obj_name_orig reins,
       rc.part_sum,
       rc.brutto_premium,
       rc.commission,
       rc.netto_premium
from ven_p_cover pc
 join ven_re_cover rc on rc.p_cover_id = pc.p_cover_id
 join ven_re_main_contract rmc on rmc.re_main_contract_id = rc.re_m_contract_id
 join ven_contact c on c.contact_id = rmc.reinsurer_id;


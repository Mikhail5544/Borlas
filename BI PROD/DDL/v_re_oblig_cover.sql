create or replace force view v_re_oblig_cover as
select pc.p_cover_id,
       rs.num,
       c.obj_name_orig reins,
       rc.part_sum,
       rc.brutto_premium,
       rc.commission,
       rc.netto_premium
from ven_p_cover pc
 join ven_re_cover rc on rc.p_cover_id = pc.p_cover_id
 join ven_re_slip rs on rs.re_slip_id = rc.re_slip_id
 join ven_re_slip_header sh on sh.re_slip_header_id = rs.re_slip_header_id
 join ven_contact c on c.contact_id = sh.reinsurer_id;


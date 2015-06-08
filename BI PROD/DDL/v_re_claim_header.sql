create or replace force view v_re_claim_header as
select rch.re_claim_header_id,
       rcl.re_claim_id,
       rc.re_cover_id,
       ent.obj_name(rc.ent_id,rc.re_cover_id) rc_name,
       rc.part_sum,
       rc.brutto_premium,
       rc.commission,
       rc.netto_premium,
       rcl.num,
       rcl.seqno,
       rcl.re_declare_sum,
       rcl.re_payment_sum,
       rcl.re_claim_status_date,
       rcl.status_id,
       ccs.description,
       rsh.num slip_name,
       rsh.sign_date,
       rs_first.start_date,
       rs_last.end_date,
       c1.obj_name_orig as_name,
       c2.obj_name_orig rei_name,
       rch.event_date,
       tc.description cat_name
from ven_re_claim_header rch
 join ven_c_claim_header ch on ch.c_claim_header_id = rch.c_claim_header_id
 join ven_c_event ce on ce.c_event_id = ch.c_event_id
 join ven_t_catastrophe_type tc on tc.id = ce.catastrophe_type_id
 join ven_re_cover rc on rc.re_cover_id = rch.re_cover_id
 join ven_re_claim rcl on rcl.re_claim_header_id = rch.re_claim_header_id
 join ven_c_claim_status ccs on ccs.c_claim_status_id = rcl.status_id
 join ven_re_slip rs on rch.re_slip_id = rs.re_slip_id
 join ven_re_slip_header rsh on rsh.re_slip_header_id = rs.re_slip_header_id
 join ven_re_slip rs_last on rs_last.re_slip_id = rsh.last_slip_id
 join ven_re_slip rs_first on rs_first.re_slip_header_id = rsh.re_slip_header_id and rs_first.ver_num = 1
 join ven_contact c1 on c1.contact_id = rsh.assignor_id
 join ven_contact c2 on c2.contact_id = rsh.reinsurer_id;


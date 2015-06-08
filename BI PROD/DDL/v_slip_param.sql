create or replace force view v_slip_param as
select   sh.re_slip_header_id,
         sh.sign_date,
         sh.num,
         s.re_slip_id,
         s1.start_date,
         s.end_date,
         ent.obj_name('CONTACT',sh.assignor_id) assignor_name,
         ent.obj_name('CONTACT',sh.reinsurer_id) reinsurer_name
from ven_re_slip_header sh
   , ven_re_slip s
   , ven_re_slip s1
where sh.re_slip_header_id = s.re_slip_header_id
  and sh.last_slip_id = s.re_slip_id
  and s1.re_slip_header_id = sh.re_slip_header_id
  and s1.ver_num = 0;


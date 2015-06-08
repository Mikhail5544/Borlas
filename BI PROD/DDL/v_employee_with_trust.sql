create or replace force view v_employee_with_trust as
select distinct c.contact_id, c.obj_name_orig contact_name
  from employee e, contact c, cn_contact_ident ci, t_id_type tit
 where e.contact_id = c.contact_id
   and c.contact_id = ci.contact_id
   and ci.id_type = tit.id
   and tit.brief = 'TRUST';


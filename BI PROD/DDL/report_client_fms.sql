CREATE OR REPLACE VIEW REPORT_CLIENT_FMS AS
select ter.row_id,
       ter.nameu,
       ter.fon_name,
       ter.gr,
       ter.vd,
       ter.adress,
       cont.contact_id,
       cont.obj_name_orig,
       NULL paym_reg
from ins.fms_terror ter,
     (select c.obj_name_orig,
            tr.row_id num_c,
            c.contact_id
      from contact c,
           t_contact_to_terror tr
      where c.risk_level = (SELECT r.t_risk_level_id FROM ins.t_risk_level r WHERE r.description = 'Террорист\экстремист')
        and c.contact_id = tr.contact_id) cont
where ter.row_id = cont.num_c
union
select ter.row_id,
       ter.nameu,
       ter.fon_name,
       ter.gr,
       ter.vd,
       ter.adress,
       NULL,
       '',
       paym.payment_register_item_id
from ins.fms_terror ter,
     (select ii.payment_register_item_id,
             ii.field_number num_ii
      from payment_register_item ii
      where ii.set_off_state = (SELECT l.id
                                FROM xx_lov_list l
                                WHERE l.name = 'PAYMENT_SET_OFF_STATE'
                                  AND l.description = 'Террорист\экстремист')
      ) paym
where ter.field_number = paym.num_ii;

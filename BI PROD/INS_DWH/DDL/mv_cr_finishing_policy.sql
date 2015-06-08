create materialized view INS_DWH.MV_CR_FINISHING_POLICY
build deferred
refresh force on demand
as
select pr.description product_name, -- продукт
       pp.pol_ser, -- серия
       pp.pol_num, -- номер
       ins.ent.obj_name(c.ent_id,c.contact_id) issuer, -- страхователь
       ph.start_date, -- дата начала
	   pp.end_date -- дата окончания
          from ins.ven_p_pol_header ph
 join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
 join ins.ven_t_product pr on pr.product_id = ph.product_id
 join ins.ven_p_policy_contact ppc on ppc.policy_id = pp.policy_id
 join ins.ven_t_contact_pol_role cpr on cpr.id = ppc.contact_policy_role_id and cpr.brief = 'Страхователь'
 join ins.ven_contact c on c.contact_id = ppc.contact_id;


create or replace force view v_rep_claim as
select distinct ch.c_claim_header_id claim_header_id,
                c.c_claim_id c_claim_id,
                c.seqno claim_ver_num,
                doc.num act_num,
                ent.obj_name(ent.id_by_brief('CONTACT'),
                             pkg_policy.get_policy_holder_id(ch.p_policy_id)) policy_holder_name,
                ph.policy_header_id pol_header_id,             
                p.pol_ser || '-' || p.pol_num pol_name,
                p.start_date pol_start_date,
                p.end_date pol_end_date,
                ent.obj_name(a.ent_id, ch.as_asset_id) asset_name,
                e.event_date event_date,
                ch.declare_date declare_date,
                ct.description catastrophe_type,
                plo.description risk_name,
                pc.ins_amount ins_amount,
                pc.premium premium,
                f.brief fund,
                pc.p_cover_id p_cover_id,
                c.payment_sum payment_sum,
                pkg_contact.get_essential(bc.contact_id) company_assential,
                ent.obj_name(ent.id_by_brief('CONTACT'), bc.contact_id) company_name
  from c_claim_header ch,
       c_claim c,
       p_policy p,
       p_pol_header ph,
       c_event e,
       t_catastrophe_type ct,
       as_asset a,
       (select d.*
          from c_damage d, c_damage_type dt, c_damage_status ds
         where d.c_damage_type_id = dt.c_damage_type_id
           and dt.brief = '—“–¿’Œ¬Œ…'
           and d.c_damage_status_id = ds.c_damage_status_id
           and ds.brief in ('Œ“ –€“')) t,
       p_cover pc,
       t_prod_line_option plo,
       document doc,
       t_brand_company bc,
       fund f
 where c.c_claim_header_id = ch.c_claim_header_id
   and ch.p_policy_id = p.policy_id
   and ch.c_event_id = e.c_event_id
   and e.catastrophe_type_id = ct.id
   and a.as_asset_id = ch.as_asset_id
   and t.c_claim_id = c.c_claim_id
   and t.p_cover_id = pc.p_cover_id
   and pc.t_prod_line_option_id = plo.id
   and doc.document_id = c.c_claim_id
   and ph.policy_header_id = p.pol_header_id
   and ph.fund_id = f.fund_id;


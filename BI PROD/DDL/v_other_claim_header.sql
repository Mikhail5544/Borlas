create or replace force view v_other_claim_header as
select chm.c_claim_header_id,
       ch.c_claim_header_id other_claim_header_id,
       --ent.obj_name(p.ent_id, p.policy_id) policy_num,
       p.policy_id,
       p.pol_ser||'-'||p.pol_num policy_num,
       ch.num claim_num,
       ch.declare_date,
       a.as_asset_id,
       ent.obj_name(a.ent_id, a.as_asset_id) asset_name,
       c.payment_sum,
       --cs.description status_name
       doc.get_doc_status_name(c.c_claim_id) status_name
  from c_claim_header     chm,
       p_policy           pm,
       ven_c_claim_header ch,
       ven_p_policy       p,
       as_asset           a,
       c_claim            c--,
       --c_claim_status cs
 where chm.p_policy_id = pm.policy_id
   and ch.p_policy_id = p.policy_id
   and pm.pol_header_id = p.pol_header_id
   and chm.c_claim_header_id <> ch.c_claim_header_id
   and ch.as_asset_id = a.as_asset_id
   and c.c_claim_header_id = ch.c_claim_header_id
   and c.seqno =
       (select max(cm.seqno)
          from c_claim cm
         where cm.c_claim_header_id = ch.c_claim_header_id)
;


create materialized view INS_DWH.MV_CR_PLAST_CARDS
build deferred
refresh force on demand
as
select pp.policy_id,--ИД версии договора
       ins.ent.obj_name('DOCUMENT',pp.policy_id) dog_num, --номер договора
       aa.card_num,
       ins.ent.obj_name('CONTACT', cp.contact_id) fio,
       cp.date_of_birth,
       to_char(aa.start_date,'DD.MM.YYYY')||' - '||to_char(aa.end_date,'DD.MM.YYYY') period,
       pl.description
  from ins.ven_as_assured aa,
       ins.ven_p_cover pc,
       ins.ven_t_prod_line_option plo,
      ins.ven_t_product_line pl,
       ins.ven_p_policy pp,
      ins.ven_cn_person cp
 where
    cp.contact_id = aa.assured_contact_id
   and pl.id = plo.product_line_id
   and plo.id = pc.t_prod_line_option_id
   and pc.as_asset_id = aa.as_assured_id
   and aa.p_policy_id = pp.policy_id;


create materialized view INS_DWH.MV_CR_ASSURED_PROP
refresh force on demand
as
select c_lpu.contact_id, --ИД ЛПУ
       ins.ent.obj_name('P_POLICY', pp.policy_id) policy_num, -- № версии договора
       pp.policy_id, -- ИД версии договора
       pp.start_date dog_start, --дата начала договора
       pp.end_date dog_end, --дата окончания договора
       aa.card_num card_num, -- № полиса
       aa.card_date assured_start_date, -- дата начала полиса
       aa.end_date assured_end_date, -- дата окончания полиса
       cast(null as date) assured_stop_date, -- дата аннулирования
       tpld.code code, -- код программы
       cast(null as varchar2(2000)) note, -- примечание
       aa.start_date, --дата начала страхования
       aa.assured_contact_id, --ИД застрахованного по контактам
       aa.as_assured_id, --ИД застрахованного по версии договора
       ins.ent.obj_name('P_POL_HEADER', pph.policy_header_id) dog_num, --№ договора
       pph.policy_header_id, --ИД договора
       decode(upper(tplt.brief),
              'RISC',
              'Риск',
              'DEPOS',
              'Депозит',
              'Комб.') prod_type --тип программы
  from ins.ven_as_assured          aa,
       ins.ven_contact             c_policy,
       ins.ven_p_policy            pp,
       ins.ven_p_cover             pc,
       ins.ven_t_prod_line_option  tplo,
       ins.ven_t_prod_line_dms     tpld,
       ins.ven_parent_prod_line    ppl,
       ins.ven_par_prod_line_cont  pplc,
       ins.ven_cn_company          c_lpu,
       ins.ven_p_pol_header        pph,
       ins.ven_t_product_line_type tplt
 where c_lpu.contact_id = pplc.contact_id
   and pplc.parent_prod_line_id = ppl.parent_prod_line_id
   and ppl.t_parent_prod_line_id = tpld.t_prod_line_dms_id
   and tpld.t_prod_line_dms_id = tplo.product_line_id
   and tplo.id = pc.t_prod_line_option_id
   and pc.as_asset_id = aa.as_assured_id
   and c_policy.contact_id = aa.contact_id
   and pp.policy_id = aa.p_policy_id
   and pph.policy_id = pp.policy_id
   and tplt.product_line_type_id = tpld.product_line_type_id;


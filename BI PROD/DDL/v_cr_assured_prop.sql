create or replace force view v_cr_assured_prop as
select c_lpu.contact_id, --ИД ЛПУ
ent.obj_name('P_POLICY', pp.policy_id) policy_num, -- № версии договора
pp.policy_id, -- ИД версии договора
pp.start_date dog_start, --дата начала договора
pp.end_date dog_end, --дата окончания договора
aa.card_num card_num, -- № полиса
aa.card_date assured_start_date, -- дата начала полиса
aa.end_date assured_end_date, -- дата окончания полиса
cast(null as date) assured_stop_date, -- дата аннулирования
tpld.code code, -- код программы
cast(null as varchar(2000)) note, -- примечание
aa.start_date, --дата начала страхования
aa.assured_contact_id, --ИД застрахованного по контактам
aa.as_assured_id, --ИД застрахованного по версии договора
ent.obj_name('P_POL_HEADER',pph.policy_header_id) dog_num,--№ договора
pph.policy_header_id,                              --ИД договора
decode(upper(tplt.brief),'RISC','Риск','DEPOS','Депозит','Комб.') prod_type--тип программы
from ven_as_assured aa,
ven_contact c_policy,
ven_p_policy pp,
ven_p_cover pc,
ven_t_prod_line_option tplo,
ven_t_prod_line_dms tpld,
ven_parent_prod_line ppl,
ven_par_prod_line_cont pplc,
ven_cn_company c_lpu,
ven_p_pol_header pph,
ven_t_product_line_type tplt
where
c_lpu.contact_id = pplc.contact_id
and pplc.parent_prod_line_id = ppl.parent_prod_line_id
and ppl.t_parent_prod_line_id = tpld.t_prod_line_dms_id
and tpld.t_prod_line_dms_id = tplo.product_line_id
and tplo.id = pc.t_prod_line_option_id
and pc.as_asset_id = aa.as_assured_id
and c_policy.contact_id = aa.contact_id
and pp.policy_id = aa.p_policy_id
and pph.policy_id=pp.policy_id
and tplt.product_line_type_id=tpld.product_line_type_id
;


create or replace force view vgo_dwh_navision_policy as
select

ph.policy_header_id POL_HEADER_ID,
pp.pol_ser pol_ser,
case when nvl(pp.pol_ser,'&') = '&' then nvl(pp.pol_num,'') else pp.pol_ser || '-' || pp.pol_num end policy_no,
pp.notice_ser ap_ser,
case when nvl(pp.notice_ser,'&') = '&' then nvl(pp.notice_num,'') else pp.notice_ser || '-' || pp.notice_num end application_no,
case when (pp.start_date < to_date('01.01.2004','DD.MM.YYYY') or pp.start_date > to_date('01.01.2100','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else pp.start_date end start_date,
case when (pp.end_date < to_date('01.01.2004','DD.MM.YYYY') or pp.end_date > to_date('01.01.2200','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else pp.end_date end end_date,
ppc.contact_id HOLDER_CONTACT_ID,
--C.CONTACT_ID HOLDER_CONTACT_ID,
c.obj_name_orig HOLDER_NAME,
ct.is_individual HOLDER_TYPE,
ph.agency_id  AGENCY_ID,
ph.product_id,
pr.description AS PRODUCT_NAME,
ph.sales_channel_id,
ph.fund_id CUR_POLICY,
ph.fund_pay_id CUR_PAYMENT,
active_policy_on_date.m MAX_VERSION,
pp.is_group_flag, --групповой договор
pp.region_id INS_REGION,
pp.policy_id,
--ins.Doc.get_doc_status_ID(pp.policy_id) status_id,
ins.doc.get_doc_status_brief(pp.policy_id) status_brief,
ins.Doc.get_doc_status_name(pp.policy_id) status_name,
case
when (nvl(vds.start_date,to_date('01.01.1753','DD.MM.YYYY')) > to_date('01.01.2050','DD.MM.YYYY'))
     or (nvl(vds.start_date,to_date('01.01.1753','DD.MM.YYYY')) < to_date('01.01.2004','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY')
else nvl(vds.start_date,to_date('01.01.1753','DD.MM.YYYY')) end STATUS_DATE,
ins.Ent.obj_name('T_PAYMENT_TERMS',pp.PAYMENT_TERM_ID) pay_term_name,
nvl(pol_asset.asset_count,0) asset_count,
case when (nvl(prev_not_break_version.start_date,to_date('01.01.1753','DD.MM.YYYY')) < to_date('01.01.2004','DD.MM.YYYY') or nvl(prev_not_break_version.start_date,to_date('01.01.1753','DD.MM.YYYY')) > to_date('01.01.2200','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else nvl(prev_not_break_version.start_date,to_date('01.01.1753','DD.MM.YYYY')) end PREV_START_DATE,
case when (nvl(prev_not_break_version.end_date,to_date('01.01.1753','DD.MM.YYYY')) < to_date('01.01.2004','DD.MM.YYYY') or nvl(prev_not_break_version.end_date,to_date('01.01.1753','DD.MM.YYYY')) > to_date('01.01.2200','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else nvl(prev_not_break_version.end_date,to_date('01.01.1753','DD.MM.YYYY')) end PREV_END_DATE,
c.resident_flag,
ph.ids POL_IDS


from
ins.p_policy              pp,
--ins.ven_p_pol_header    ph,
ins.p_pol_header          ph,
ins.p_policy_contact      ppc,
ins.contact               c,
ins.t_contact_type        ct,
ins.t_product             pr,
--ins.status_hist           status_hist,

--ins.department            dp,
ins.ven_doc_status vds,

( select policy_id, m
  from ( select
             max(pp_temp.version_num) over(partition by pp_temp.pol_header_id) m,
             pp_temp.policy_id,
             pp_temp.version_num
         from ins.p_policy pp_temp )
  where m = version_num) active_policy_on_date,  --определяем ИД последней версии договора

 ( select  aa.p_policy_id, count(aa.as_asset_id) asset_count
   from ins.as_asset aa
   group by aa.p_policy_id
 ) pol_asset,  -- подсчитываем количество застрахованных для последней версии
/*
 ( select policy_id, m,start_date,end_date,pol_header_id
  from ( select
             max(pp_temp1.version_num) over(partition by pp_temp1.pol_header_id) m,
             pp_temp1.policy_id,
             pp_temp1.version_num,
             min(pp_temp1.start_date) over(partition by pp_temp1.pol_header_id) start_date,
             max(pp_temp1.end_date) over(partition by pp_temp1.pol_header_id) end_date,
             pp_temp1.pol_header_id
         from ins.p_policy pp_temp1
 --        where ins.doc.get_doc_status_brief(pp_temp1.policy_id) <> 'BREAK'
         )
  where m = version_num) prev_not_break_version  --определяем дату начала и дату окончания для мах верстии не в статусе "BREAK"
*/
 (
  select pp_temp1.pol_header_id,min(pp_temp1.start_date) start_date, max(pp_temp1.end_date)end_date
 -- select pp_temp1.pol_header_id,pp_temp1.start_date , pp_temp1.end_date
  from ins.p_policy pp_temp1
--  where pp_temp1.pol_header_id = 5061408
  group by pp_temp1.pol_header_id

 )prev_not_break_version  -- Мин Дата начала и Мах дата окончания

where
     pp.pol_header_id = ph.policy_header_id
     and ppc.contact_policy_role_id = 6
     and ppc.policy_id = pp.policy_id
     and ppc.contact_id = c.contact_id
     and pp.policy_id = active_policy_on_date.policy_id ---Последняя версия
     and ct.id = c.contact_type_id
     and pr.product_id = ph.product_id
     and ins.Doc.get_doc_status_rec_id(pp.policy_id) = vds.doc_status_id (+)
     and pp.policy_id = pol_asset.p_policy_id (+)
     and ph.policy_header_id = prev_not_break_version.pol_header_id (+)

 --    and ins.doc.get_doc_status_brief(pp.policy_id) = 'READY_TO_CANCEL'
;


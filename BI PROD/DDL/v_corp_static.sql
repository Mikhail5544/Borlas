CREATE OR REPLACE FORCE VIEW V_CORP_STATIC AS
select ids||' '||ins_name||' '||date_of_birth||' '||gender||' '||start_date||' '||end_date||' '||sum_fee ins_info,
       risk,
       fee,
       ins_amount,
       null fee_S,
       null fee_A,
       null fee_R

from (
SELECT                 ph.policy_header_id,
                       aa.p_policy_id,
                       pc.p_cover_id,
                       aa.contact_id,
                       aas.assured_contact_id,
                       ph.ids,
                       ent.obj_name(ca.ent_id,aas.assured_contact_id) ins_name,
                       to_char(per.date_of_birth,'dd.mm.yyyy') date_of_birth ,
                       decode(nvl(per.gender,0),0,'Жен','Муж') gender,
                       to_char(pc.start_date,'dd.mm.yyyy') start_date,
                       to_char(pc.end_date,'dd.mm.yyyy') end_date,
                       'Итого страховой взнос = ' ||to_char((select sum(pc2.fee)
                          FROM t_lob_line ll2
                             , t_product_line pl2
                             , t_prod_line_option plo2
                             , p_cover pc2
                             , ven_status_hist sh2
                             , as_asset aa2
                       WHERE 1=1
                         AND aa2.p_policy_id = pp.policy_id
                         AND pc2.as_asset_id = aa2.as_asset_id
                         and pc2.as_asset_id = aas.as_assured_id
                         AND sh2.status_hist_id = pc2.status_hist_id
                         AND sh2.brief != 'DELETED'
                         AND plo2.ID = pc2.t_prod_line_option_id
                         AND pl2.ID = plo2.product_line_id
                         AND ll2.t_lob_line_id = pl2.t_lob_line_id
                         and ll2.description <> 'Административные издержки'
                       )) sum_fee,
                       aa.p_asset_header_id,
                       ll.t_lob_line_id,
                       ll.brief,
                       ll.description risk,
                       pc.fee,
                       pc.ins_amount,
                       tp.brief product,
                       case sh.brief when 'NEW' then 'A'
                                     when 'DELETED' then 'R'
                                     else 'N'
                                     end chn,
                       (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief = 'DELETED') fee_R,
                       (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief = 'NEW') fee_A,
                        (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief != 'DELETED') fee_S

                       FROM
                         t_lob_line ll
                       , t_product_line pl
                       , t_prod_line_option plo
                       , p_cover pc
                       , ven_status_hist sh
                       , as_assured aas
                       , contact ca
                       , cn_person per
                       , p_pol_header ph
                       , p_policy pp
                       , as_asset aa
                       , t_product tp
                       WHERE 1=1
                         AND aa.p_policy_id = pp.policy_id
                         AND pp.policy_id in (2978297/*,3216029,2726318*/)
                         AND tp.product_id = ph.product_id
                         AND ph.policy_header_id = pp.pol_header_id
                         AND aas.as_assured_id = aa.as_asset_id
                         AND pc.as_asset_id = aa.as_asset_id
                         and ca.contact_id = aas.assured_contact_id
                         and per.contact_id = ca.contact_id
                         AND sh.status_hist_id = pc.status_hist_id
                         and nvl(pp.is_group_flag,0) = 1
                         AND sh.brief != 'DELETED'
                         AND plo.ID = pc.t_prod_line_option_id
                         AND pl.ID = plo.product_line_id
                         AND ll.t_lob_line_id = pl.t_lob_line_id
order by ph.policy_header_id, aa.p_policy_id, aas.assured_contact_id, pc.start_date)
union
select 'Итого по договору',
       null,
       null,
       null,
       fee_S,
       fee_A,
       fee_R

from (
SELECT                 ph.policy_header_id,
                       aa.p_policy_id,
                       pc.p_cover_id,
                       aa.contact_id,
                       aas.assured_contact_id,
                       ph.ids,
                       ent.obj_name(ca.ent_id,aas.assured_contact_id) ins_name,
                       to_char(per.date_of_birth,'dd.mm.yyyy') date_of_birth ,
                       decode(nvl(per.gender,0),0,'Жен','Муж') gender,
                       to_char(pc.start_date,'dd.mm.yyyy') start_date,
                       to_char(pc.end_date,'dd.mm.yyyy') end_date,
                       'Итого страховой взнос = ' ||to_char((select sum(pc2.fee)
                          FROM t_lob_line ll2
                             , t_product_line pl2
                             , t_prod_line_option plo2
                             , p_cover pc2
                             , ven_status_hist sh2
                             , as_asset aa2
                       WHERE 1=1
                         AND aa2.p_policy_id = pp.policy_id
                         AND pc2.as_asset_id = aa2.as_asset_id
                         and pc2.as_asset_id = aas.as_assured_id
                         AND sh2.status_hist_id = pc2.status_hist_id
                         AND sh2.brief != 'DELETED'
                         AND plo2.ID = pc2.t_prod_line_option_id
                         AND pl2.ID = plo2.product_line_id
                         AND ll2.t_lob_line_id = pl2.t_lob_line_id
                         and ll2.description <> 'Административные издержки'
                       )) sum_fee,
                       aa.p_asset_header_id,
                       ll.t_lob_line_id,
                       ll.brief,
                       ll.description risk,
                       pc.fee,
                       pc.ins_amount,
                       tp.brief product,
                       case sh.brief when 'NEW' then 'A'
                                     when 'DELETED' then 'R'
                                     else 'N'
                                     end chn,
                       (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief = 'DELETED') fee_R,
                       (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief = 'NEW') fee_A,
                        (select sum(pcs.fee)
                        from p_cover pcs,
                             as_asset ass,
                             p_policy pps,
                             status_hist shs
                        where pcs.as_asset_id = ass.as_asset_id
                              and pps.policy_id = pp.policy_id
                              and ass.p_policy_id = pps.policy_id
                              and pcs.status_hist_id = shs.status_hist_id
                              and shs.brief != 'DELETED') fee_S

                       FROM
                         t_lob_line ll
                       , t_product_line pl
                       , t_prod_line_option plo
                       , p_cover pc
                       , ven_status_hist sh
                       , as_assured aas
                       , contact ca
                       , cn_person per
                       , p_pol_header ph
                       , p_policy pp
                       , as_asset aa
                       , t_product tp
                       WHERE 1=1
                         AND aa.p_policy_id = pp.policy_id
                         AND pp.policy_id in (2978297/*,3216029,2726318*/)
                         AND tp.product_id = ph.product_id
                         AND ph.policy_header_id = pp.pol_header_id
                         AND aas.as_assured_id = aa.as_asset_id
                         AND pc.as_asset_id = aa.as_asset_id
                         and ca.contact_id = aas.assured_contact_id
                         and per.contact_id = ca.contact_id
                         AND sh.status_hist_id = pc.status_hist_id
                         and nvl(pp.is_group_flag,0) = 1
                         AND sh.brief != 'DELETED'
                         AND plo.ID = pc.t_prod_line_option_id
                         AND pl.ID = plo.product_line_id
                         AND ll.t_lob_line_id = pl.t_lob_line_id
order by ph.policy_header_id, aa.p_policy_id, aas.assured_contact_id, pc.start_date);


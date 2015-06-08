create or replace force view ins_dwh.v_rep_work_lost as
select ph.ids,
       p.pol_num,
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(p.policy_id,'Страхователь')) "Страхователь",
       ins.doc.get_doc_status_name(p.policy_id) "Статус акт версии",
       pc.premium,
       f.brief "Валюта",
       pt.description "Периодичность оплаты",
       ph.start_date  "Дата начала ДС",
       pr.description "Продукт"
  from ins.p_pol_header ph,
       ins.fund         f,
       ins.p_policy     p,
       ins.as_asset     aa,
       ins.status_hist  ash,
       ins.p_cover      pc,
       ins.status_hist  psh,
       ins.t_prod_line_option plo,
       ins.t_payment_terms    pt,
       ins.t_product          pr
 where p.policy_id = ph.policy_id
   and pr.product_id = ph.product_id
   and f.fund_id = ph.fund_id
   and aa.p_policy_id = p.policy_id
   and ash.status_hist_id = aa.status_hist_id
   and ash.brief <> 'DELETED'
   and pc.as_asset_id = aa.as_asset_id
   and psh.status_hist_id = pc.status_hist_id
   and psh.brief <> 'DELETED'
   and plo.id = pc.t_prod_line_option_id
   and plo.description = 'Дожитие Страхователя до потери постоянной работы по независящим от него причинам'
   and pt.id = p.payment_term_id;


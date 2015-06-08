create or replace view ins.v_rep_for_broker as
select ph.policy_header_id,
       pp.pol_num ids,
       cpol.obj_name_orig holder,
       --prod.description product,
       trm.description period,
       ph.start_date,
       pp.end_date,
       pp.fee_payment_term,
       TRUNC(MONTHS_BETWEEN(SYSDATE,ph.start_date)/12) srok,
       opt.description risk_name,
       CASE WHEN f.brief = 'RUR' THEN trim(to_char(pc.fee,'999G999G999G999G990D00')) ELSE '' END sum_fee_rur,
       CASE WHEN f.brief <> 'RUR' THEN trim(to_char(pc.fee,'999G999G999G999G990D00')) ELSE '' END sum_fee_usd,
       pc.ins_amount sum_ins_amount,
       DECODE(f.fund_id,122,'RUR',5,'EUR',121,'USD',f.brief) fund_id,
       --ins.pkg_renlife_utils.paid_unpaid(ph.policy_header_id,1) unpaid,
       --ins.pkg_renlife_utils.paid_unpaid(ph.policy_header_id,2) paid,
       --pkg_policy.get_last_version_status(ph.policy_header_id) last_status,
       --doc.get_doc_status_name(ph.policy_id) active_status,
       
       (select max(acdso.due_date)
        from p_policy pol,
             ven_ac_payment ac,
             doc_doc dac,
             doc_templ dt,
             doc_set_off dsf,
             ven_ac_payment acdso,
             doc_templ dtdso
        where pol.pol_header_id = ph.policy_header_id
              and pol.policy_id = dac.parent_id
              and ac.payment_id = dsf.parent_doc_id
              and ac.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
              and dsf.child_doc_id = acdso.payment_id(+)
              and acdso.doc_templ_id = dtdso.doc_templ_id(+)
              and dac.child_id = ac.payment_id
              ) due_date,
      CASE WHEN f.brief <> 'RUR' THEN 
        (select acc_new.get_rate_by_brief('ЦБ',f.brief,max(acdso.due_date))
          from p_policy pol,
               ven_ac_payment ac,
               doc_doc dac,
               doc_templ dt,
               doc_set_off dsf,
               ven_ac_payment acdso,
               doc_templ dtdso
          where pol.pol_header_id = ph.policy_header_id
                and pol.policy_id = dac.parent_id
                and ac.payment_id = dsf.parent_doc_id
                and ac.doc_templ_id = dt.doc_templ_id
                and dt.brief = 'PAYMENT'
                and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
                and dsf.child_doc_id = acdso.payment_id(+)
                and acdso.doc_templ_id = dtdso.doc_templ_id(+)
                and dac.child_id = ac.payment_id
                )
      ELSE NULL END due_rate,
      (select max(acdso.num)
        from p_policy pol,
             ven_ac_payment ac,
             doc_doc dac,
             doc_templ dt,
             doc_set_off dsf,
             ven_ac_payment acdso,
             doc_templ dtdso
        where pol.pol_header_id = ph.policy_header_id
              and pol.policy_id = dac.parent_id
              and ac.payment_id = dsf.parent_doc_id
              and ac.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
              and dsf.child_doc_id = acdso.payment_id(+)
              and acdso.doc_templ_id = dtdso.doc_templ_id(+)
              and dac.child_id = ac.payment_id
              ) due_num,
     (select agh.num||'-'||c.obj_name_orig
     from ins.p_policy_agent_doc pad,
          ins.ven_ag_contract_header agh,
          ins.contact c
     where pad.policy_header_id = ph.policy_header_id
           and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           and agh.ag_contract_header_id = pad.ag_contract_header_id
           and agh.agent_id = c.contact_id
           and rownum = 1) agent_name
       
from p_policy pp,
     p_pol_header ph,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     t_product prod,
     t_payment_terms trm,
     fund f,
     as_asset a,
     p_cover pc,
     t_prod_line_option opt,
     ven_status_hist h
where pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.product_id = prod.product_id
      and trm.id = pp.payment_term_id
      and ph.fund_id = f.fund_id
      and pp.policy_id = a.p_policy_id
      and a.as_asset_id = pc.as_asset_id
      and h.status_hist_id = pc.status_hist_id
      and opt.id = pc.t_prod_line_option_id
      and h.brief <> 'DELETED'
      and prod.description in (
      'Гармония жизни',
      'Дети','Семья','Будущее','Семейный депозит','Защита APG'
      )
      and opt.description NOT IN ('Административные издержки')
--and ph.ids = 1910054320
union all
select ph.policy_header_id,
       pp.pol_num ids,
       cpol.obj_name_orig holder,
       --prod.description product,
       trm.description period,
       ph.start_date,
       pp.end_date,
       pp.fee_payment_term,
       TRUNC(MONTHS_BETWEEN(SYSDATE,ph.start_date)/12) srok,
       prod.description risk_name,
       CASE WHEN f.brief = 'RUR' THEN trim(to_char(
       (select sum(pc.fee)
        from as_asset a,
             p_cover pc,
             ven_status_hist h
        where a.p_policy_id = pp.policy_id
              and a.as_asset_id = pc.as_asset_id
              and h.status_hist_id = pc.status_hist_id
              and h.brief <> 'DELETED')
       ,'999G999G999G999G990D00')) ELSE '' END sum_fee_rur,
       CASE WHEN f.brief <> 'RUR' THEN trim(to_char(
       (select sum(pc.fee)
        from as_asset a,
             p_cover pc,
             ven_status_hist h
        where a.p_policy_id = pp.policy_id
              and a.as_asset_id = pc.as_asset_id
              and h.status_hist_id = pc.status_hist_id
              and h.brief <> 'DELETED')
       ,'999G999G999G999G990D00')) ELSE '' END sum_fee_usd,
       (select sum(pc.ins_amount)
        from as_asset a,
             p_cover pc,
             ven_status_hist h
        where a.p_policy_id = pp.policy_id
              and a.as_asset_id = pc.as_asset_id
              and h.status_hist_id = pc.status_hist_id
              and h.brief <> 'DELETED') sum_ins_amount,
        DECODE(f.fund_id,122,'RUR',5,'EUR',121,'USD',f.brief) fund_id,
        --ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id,1) unpaid,
        --ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id,2) paid,
        --pkg_policy.get_last_version_status(ph.policy_header_id) last_status,
        --doc.get_doc_status_name(ph.policy_id) active_status,
        (select max(acdso.due_date)
        from p_policy pol,
             ven_ac_payment ac,
             doc_doc dac,
             doc_templ dt,
             doc_set_off dsf,
             ven_ac_payment acdso,
             doc_templ dtdso
        where pol.pol_header_id = ph.policy_header_id
              and pol.policy_id = dac.parent_id
              and ac.payment_id = dsf.parent_doc_id
              and ac.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
              and dsf.child_doc_id = acdso.payment_id(+)
              and acdso.doc_templ_id = dtdso.doc_templ_id(+)
              and dac.child_id = ac.payment_id
              --and dt.brief IN ('ПП','ПП_ОБ','ПП_ПС')
              
              ) due_date,
        CASE WHEN f.brief <> 'RUR' THEN 
        (select acc_new.get_rate_by_brief('ЦБ',f.brief,max(acdso.due_date))
          from p_policy pol,
               ven_ac_payment ac,
               doc_doc dac,
               doc_templ dt,
               doc_set_off dsf,
               ven_ac_payment acdso,
               doc_templ dtdso
          where pol.pol_header_id = ph.policy_header_id
                and pol.policy_id = dac.parent_id
                and ac.payment_id = dsf.parent_doc_id
                and ac.doc_templ_id = dt.doc_templ_id
                and dt.brief = 'PAYMENT'
                and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
                and dsf.child_doc_id = acdso.payment_id(+)
                and acdso.doc_templ_id = dtdso.doc_templ_id(+)
                and dac.child_id = ac.payment_id
                )
      ELSE NULL END due_rate,
      (select max(acdso.num)
        from p_policy pol,
             ven_ac_payment ac,
             doc_doc dac,
             doc_templ dt,
             doc_set_off dsf,
             ven_ac_payment acdso,
             doc_templ dtdso
        where pol.pol_header_id = ph.policy_header_id
              and pol.policy_id = dac.parent_id
              and ac.payment_id = dsf.parent_doc_id
              and ac.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and Doc.get_doc_status_brief(ac.payment_id) = 'PAID'
              and dsf.child_doc_id = acdso.payment_id(+)
              and acdso.doc_templ_id = dtdso.doc_templ_id(+)
              and dac.child_id = ac.payment_id
              ) due_num,
     (select agh.num||'-'||c.obj_name_orig
     from ins.p_policy_agent_doc pad,
          ins.ven_ag_contract_header agh,
          ins.contact c
     where pad.policy_header_id = ph.policy_header_id
           and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
           and agh.ag_contract_header_id = pad.ag_contract_header_id
           and agh.agent_id = c.contact_id
           and rownum = 1) agent_name
from p_policy pp,
     p_pol_header ph,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     t_product prod,
     t_payment_terms trm,
     fund f  
where pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.product_id = prod.product_id
      and trm.id = pp.payment_term_id
      and ph.fund_id = f.fund_id
      and prod.description in (      
      'Baby_Life_Active_2','Baby Life Active',
      'Platinum Life Active','Family Life Active_2','Экспресс-Актив','Экспресс 5000','ОПС + 2',
      'Благополучие','Экспресс-Семья','Экспресс 1000000','Софинансирование +',
      'Защита и накопление','КАСКА для людей','Авто-Экспресс','Экспресс-Защита (новый)','Экспресс-Защита','Уверенность плюс','Забота'
      ) 
--and ph.ids = 1140016612 

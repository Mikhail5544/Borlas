create or replace view v_re_claim_report as
select rownum as row_num
      ,--bp.re_bordero_package_id
       bbl.re_bordero_package_id
      ,mc.re_main_contract_id
      ,--bp.start_date
       bu.start_date
      ,--bp.end_date
       bu.end_date
      ,case
         when ar.re_bordero_type_id = 0 then 'Облигатор (стандарт)'
         when ar.re_bordero_type_id = 1 then 'Облигатор (не стандарт)'
         when ar.re_bordero_type_id = 2 then 'Факультатив'
       end as reinsurance_sign
      ,bbt.short_name as bordero_part
      ,to_char(bu.start_date,'q')||' кв '||to_char(bu.start_date,'yyyy') as Quarter
      ,'Убыток' as premium_type_name
      ,decode(lg.lob_line_group,1,'C','L') as product_type
      ,ccd.num as file_num
      ,ph.policy_header_id
      ,ph.ids
      ,d.num
      ,decode(p.is_group_flag, 0, 'Индивидуальный', 'Корпоративный') as pol_type
      ,tp.description as product_name
      ,pl.description cover_name
      ,tp.brief as product_brief
      ,c.obj_name_orig as asset_name
      ,c1.obj_name_orig as assured_name
      ,decode(cp.gender,1,'m','w') as sex
      ,cp.date_of_birth
      ,ph.start_date as policy_start_date
      ,e.date_company
      ,(select nvl(max(ds.start_date),to_date('01.01.1900','dd.mm.yyyy'))
          from c_claim clm2,
               doc_status ds
         where clm2.c_claim_header_id = cch.c_claim_header_id
           and ds.document_id         = clm2.c_claim_id
           and ds.doc_status_ref_id   = 122) as date_all_doc
      ,e.event_date
      ,nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, cch.c_claim_header_id,'В'),0) +
       nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, cch.c_claim_header_id, 'З'),0) as account_date
      ,nvl(replace(e.diagnose,chr(10),''),'-')            as diagnose 
      -- Гаргонов Д.А. 
      -- Добавил replace, заявка 266386.
      ,rrb.payment_sum*rrb.rate       as claim_amount_rur
      ,rrb.payment_sum                as claim_amount
      ,f.brief                        as fund_brief
      ,nvl(rrb.rate,pkg_re_insurance.get_rate_on_package_end(bbl.re_bordero_package_id, ph.fund_id)) as rate
      ,cc.payment_sum                 as claim_pay_sum
      ,null                           as total_payment_sum
      ,rc.re_payment_share
      ,nvl(rrb.re_payment_sum, rc.re_payment_share*rc.re_declare_sum) as re_payment_sum
      ,rrb.pay_date
      ,(select sum(case
  when case when (nvl(dmg.payment_sum,0)) = 0 then
        (select max(ds.start_date)
         from ven_c_claim clm2,
              doc_status ds
         where clm2.c_claim_header_id = cch.c_claim_header_id
               and ds.document_id = clm2.c_claim_id
               and ds.doc_status_ref_id in (128)) end /* p31 */ is null
  then
     round(nvl(case
                     when nvl(cch.is_handset_ins_sum,0) = 1 then
                       cch.ins_sum
                     when nvl(pc.ins_amount,0) = 0 then
                       pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
                     else nvl(pc.ins_amount,0)
                   end /* amount */, 0) * (case
                                when case
                                       when nvl(cch.is_handset_ins_sum,0) = 1 then
                                         cch.ins_sum
                                       when nvl(pc.ins_amount,0) = 0 then
                                         pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
                                       else nvl(pc.ins_amount,0)
                                     end /* amount */ > 0
                                then ((nvl(dmg.declare_sum /*paym*/,0) - nvl(dmg.decline_sum /*decl*/,0)) * nvl(acc.get_cross_rate_by_brief(1,dmgf.brief,f.brief,cch.declare_date),1)/*rate*/ /
                                                                           case
                                                                             when nvl(cch.is_handset_ins_sum,0) = 1 then
                                                                               cch.ins_sum
                                                                             when nvl(pc.ins_amount,0) = 0 then
                                                                               pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
                                                                             else nvl(pc.ins_amount,0)
                                                                           end /* amount */)
                                else 0
                              end),2)
   
  else 0
end
       )
    from c_damage dmg
        ,fund     dmgf
   where dmg.c_claim_id = cc.c_claim_id
     and dmg.damage_fund_id = dmgf.fund_id
)
      
      
      /*round(nvl(pc.ins_amount,0)
                  *(case
                      when pc.ins_amount > 0 then
                        (select nvl(sum(dmg.declare_sum),0)-nvl(sum(dmg.decline_sum),0)
                                -- ** sum(pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id))
                           from c_damage dmg
                          where dmg.c_claim_id = cc.c_claim_id)
                        * pkg_re_insurance.get_rate_on_package_end(bbl.re_bordero_package_id, ph.fund_id)
                        / pc.ins_amount
                      else 0
                    end)
                  -- ** *(rc.re_payment_share \*\100 *\)
                  ,2
                )*/ as amount_of_claims
      ,rc.declare_sum*pkg_re_insurance.get_rate_on_package_end(bbl.re_bordero_package_id, ph.fund_id) as res_amount_claims
      ,nvl(rrb.re_payment_sum*rrb.rate
      	  ,rc.declare_sum*pkg_re_insurance.get_rate_on_package_end(bbl.re_bordero_package_id, ph.fund_id)*rc.re_payment_share
          ) as reinsurer_share
  from re_main_contract        mc
      ,re_contract_version     cv
      ,re_bordero_package      bp
      ,re_bordero_package      bu
      ,re_bordero              b
      ,re_bordero              bbl
--*
      ,re_bordero_type         bbt
--*
      ,re_bordero_line         bl
      ,t_product_line          pl
      ,t_lob_line              ll
      ,t_lob_line_group        lg
      ,c_claim_header          cch
      ,c_claim                 cc
      ,document                ccd
      ,c_event                 e
      --,c_damage                cd
      ,p_pol_header            ph
      ,document                d
      ,p_policy                p
      ,t_product               tp
      ,as_asset                a
      ,contact                 c
      ,as_assured              s
      ,contact                 c1
      ,cn_person               cp
      ,p_cover                 pc
      ,fund                    f
      --,re_damage               rd
      --,rel_redamage_bordero    rrb
      ,re_claim                rc
      ,rel_reclaim_bordero     rrb
      ,as_assured_re           ar
      ,re_bordero_type         bt
      ,p_policy_contact        ppc
where mc.re_main_contract_id    = cv.re_main_contract_id
  and cv.re_contract_version_id = bp.re_contract_id
  and bp.re_bordero_package_id  = b.re_bordero_package_id
  and b.re_bordero_id           = bl.re_bordero_id
  and pl.id                     = bl.product_line_id
  and ll.t_lob_line_id          = pl.t_lob_line_id
  and lg.t_lob_line_id          = pl.t_lob_line_id
  and lg.lob_line_type          = 1
  and lg.period                 = 1
  and cc.c_claim_header_id      = cch.c_claim_header_id
  and ph.policy_header_id       = bl.pol_header_id
  and d.document_id             = ph.policy_header_id
  and p.policy_id               = bl.policy_id
  and tp.product_id             = bl.product_id
  and a.p_policy_id             = p.policy_id
  --and c.contact_id              = a.contact_id
  and p.policy_id               = ppc.policy_id
  and ppc.contact_policy_role_id = 6
  and ppc.contact_id            = c.contact_id
  and s.as_assured_id           = a.as_asset_id
  and c1.contact_id             = s.assured_contact_id
  and cp.contact_id             = c1.contact_id
  and pc.as_asset_id            = a.as_asset_id
  and pc.p_cover_id             = bl.cover_id
  and e.c_event_id              = cch.c_event_id
  --and cd.c_claim_id             = cc.c_claim_id
  and rc.c_claim_id             = cc.c_claim_id
  --and rd.damage_id              = cd.c_damage_id
  and ph.fund_id                = f.fund_id
  --and rd.re_bordero_line_id     = bl.re_bordero_line_id
  and rc.re_bordero_line_id     = bl.re_bordero_line_id
  --and rrb.re_damage_id          = rd.re_damage_id
  and ar.p_policy_id            = p.policy_id

--* дополнительный отбор по версии договора перестрахования
  and ar.re_contract_version_id = bp.re_contract_id
  and bt.re_bordero_type_id     = b.re_bordero_type_id
  --and rrb.re_bordero_id         = bbl.re_bordero_id
  and bbl.re_bordero_type_id = bbt.re_bordero_type_id
  and bbt.short_name in ('БОУ', 'БЗУ')
  and bbl.fund_id            = bl.fund_id


  and rc.re_bordero_id = bbl.re_bordero_id
  and rc.re_claim_id   = rrb.re_claim_id (+)

  and bbl.re_bordero_package_id = bu.re_bordero_package_id
  and cc.c_claim_header_id      = ccd.document_id
;

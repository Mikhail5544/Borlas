create or replace view ins_dwh.v_cbnt_contact as
select to_char(c.contact_id) insured_id,
       nvl(c.obj_name,'null') insured_name,
       cntel.email,
       nvl(to_char(cnid.vip_card),'null') vip_card,
       nvl(decode(p.gender, 1, 'М', 0, 'Ж', 'Н'),'null') gender
      ,nvl(cntel.email,'null') as login_name
      ,nvl(to_char(cnid.vip_card),'null') as pwd
  from ins.contact c,
       ins.cn_person p,
       ins.t_contact_status cs,
       (select cnt1.*
          from (select ce.contact_id,
                       row_number() over(partition by ce.contact_id order by decode(et.id, 363, 0, 1, 1, 2, 2, 100)) rn,
                       ce.email
                  from ins.cn_contact_email ce, ins.t_email_type et
                 where ce.email_type = et.id) cnt1
         where cnt1.rn = 1) cntel,
       (select cnid1.*
          from (select i.contact_id,
                       row_number() over(partition by i.contact_id order by i.id_value) rn,
                       i.id_value vip_card
                  from ins.cn_contact_ident i, ins.t_id_type it
                 where i.id_type = it.id
                   and it.brief = 'VIPCard') cnid1
         where cnid1.rn = 1) cnid
 where c.contact_id          = p.contact_id
   and c.contact_id          = cntel.contact_id
   and c.t_contact_status_id = cs.t_contact_status_id
   and cs.name               = 'VIP'
   and cnid.contact_id       = c.contact_id
-- Должны быть связаны с договорами, у которых есть номер
   and exists (select null
                 from ins.p_policy_contact pc
                     ,ins.p_policy         pp
                where c.contact_id             = pc.contact_id
                  and pc.policy_id             = pp.policy_id
                  and pc.contact_policy_role_id = 6
                  and ins.pkg_policy.get_last_version(pp.pol_header_id) = pp.policy_id
                  and pp.pol_num is not null
              )
-- Если страхователь не VIP, но есть договор Инвестор
union all
-- Первый по дате заключения договор Инвестор
select insured_id
      ,insured_name
      ,email
      ,vip_card
      ,gender
      ,login_name
      ,pwd
  from (select to_char(c.contact_id)                             as insured_id
              ,nvl(c.obj_name,'null')                            as insured_name
              ,cntel.email
              ,nvl(pp.pol_num,'null')                            as vip_card
              ,nvl(decode(p.gender, 1, 'М', 0, 'Ж', 'Н'),'null') as gender
              ,nvl(cntel.email,'null')                           as login_name
              ,nvl(to_char(ph.ids),'null')                       as pwd
              ,row_number() over (partition by c.contact_id order by ph.start_date) as rn
          from ins.contact          c
              ,ins.t_contact_status cs
              ,ins.p_pol_header     ph
              ,ins.p_policy_contact pc
              ,ins.p_policy         pp
              ,ins.t_product        pr
              ,ins.cn_person        p
              ,(select cnt1.*
                  from (select ce.contact_id,
                               row_number() over(partition by ce.contact_id order by decode(et.id, 363, 0, 1, 1, 2, 2, 100)) rn,
                               ce.email
                          from ins.cn_contact_email ce, ins.t_email_type et
                         where ce.email_type = et.id) cnt1
                 where cnt1.rn = 1) cntel
         where c.t_contact_status_id     = cs.t_contact_status_id
           and cs.name                  != 'VIP'
           and pc.contact_id             = c.contact_id
           and ins.pkg_policy.get_last_version(ph.policy_header_id) = pp.policy_id
           and pp.policy_id              = pc.policy_id
           and pc.contact_policy_role_id = 6
           and ph.product_id             = pr.product_id
           and pr.brief                  in ('Investor','INVESTOR_LUMP_OLD','INVESTOR_LUMP','InvestorALFA','Invest_in_future')
           and c.contact_id              = cntel.contact_id
           and c.contact_id              = p.contact_id
           -- Отбираются договоры, имеющие номера
           and pp.pol_num is not null
           and ph.ids is not null
       )
  where rn = 1
union all
select insured_id
      ,insured_name
      ,email
      ,vip_card
      ,gender
      ,login_name
      ,pwd
  from (select to_char(c.contact_id)  as insured_id
              ,nvl(c.obj_name,'null') as insured_name
              ,nvl(cntel.email,'null') as email
              ,pp.pol_num             as vip_card
              ,nvl(decode(p.gender, 1, 'М', 0, 'Ж', 'Н'),'null') as gender
              ,nvl(pd.pas_number,'null') as login_name
              ,nvl(pd.issue_date,'null') as pwd
              ,row_number() over (partition by c.contact_id order by ph.start_date) as rn
          from ins.contact c
              ,ins.t_contact_status cs
              ,ins.p_pol_header     ph
              ,ins.p_policy_contact pc
              ,ins.p_policy         pp
              ,ins.cn_person        p
              ,(select cnt1.*
                  from (select ce.contact_id,
                               row_number() over(partition by ce.contact_id order by decode(et.id, 363, 0, 1, 1, 2, 2, 100)) rn,
                               ce.email
                          from ins.cn_contact_email ce, ins.t_email_type et
                         where ce.email_type = et.id) cnt1
                 where cnt1.rn = 1) cntel
              ,ins.p_policy_agent_doc ad
              ,ins.document           dc
              ,ins.doc_status_ref     dsr
              ,ins.ag_contract_header ch
              ,ins.ag_contract        cn
              ,(select ci.id_value   as pas_number
                      ,to_char(ci.issue_date,'dd.mm.yyyy') as issue_date
                      ,ci.contact_id
                  from ins.cn_contact_ident ci
                      ,ins.t_id_type        it
                 where ci.id_type = it.id
                   and it.brief in ('PASS_SSSR','PASS_RF')
                   and ci.is_used = 1
               ) pd
              ,t_product prd
         where c.contact_id              = pc.contact_id
           and ins.pkg_policy.get_last_version(ph.policy_header_id) = pp.policy_id
           and pp.policy_id              = pc.policy_id
           and pc.contact_policy_role_id = 6
           and c.contact_id              = cntel.contact_id (+)
           and c.contact_id              = p.contact_id
           and c.t_contact_status_id     = cs.t_contact_status_id
           and ph.policy_header_id       = ad.policy_header_id
           and trunc(sysdate,'dd') between ad.date_begin and ad.date_end
           and ad.ag_contract_header_id  = ch.ag_contract_header_id
           and ch.last_ver_id            = cn.ag_contract_id
           and cn.agency_id in (5619,5652,9906) --('Москва 4', 'Екатеринбург', 'Ярославль')
           and c.contact_id              = pd.contact_id
           and ad.p_policy_agent_doc_id  = dc.document_id
           and dc.doc_status_ref_id      = dsr.doc_status_ref_id
           and dsr.brief                 = 'CURRENT'
           -- Отбираются договоры, имеющие номера
           and pp.pol_num is not null
           -- Не должны быть ВИП и Инвесторами
           and cs.name                  != 'VIP'
           and c.contact_id not in (select pc_.contact_id
                  from ins.p_policy_contact pc_
                      ,ins.p_pol_header     ph_
                      ,ins.t_product        pr_
                 where pc_.policy_id              = ins.pkg_policy.get_last_version(ph_.policy_header_id)
                   and pc_.contact_policy_role_id = 6
                   and ph_.product_id             = pr_.product_id
                   and pr_.brief in ('Investor','INVESTOR_LUMP_OLD','INVESTOR_LUMP','InvestorALFA','Invest_in_future'))
/*           and pp.is_group_flag = 0
           and ph.product_id = prd.product_id
           and prd.brief not like 'CR92%'*/
        ) c
 where c.rn = 1;

create or replace view v_rep_issurer_adr_tel as
select
  rownum rn
  , contact_id
  , contact_name
  , type_requisit_absenced
  , ids
  , dep_name
  , department_id
  , agent_name
  , leader_name
  , requisites_type_name
  , requisites_name
  , requisites_status_name
  , contact_number
  , is_check_adr_tel
  , prod_description
  , prod_brief
  , leader_id
  , agent_id
from
    (select --rownum rn
           row_number()over(partition by vi.contact_id, requisites.type_name, requisites.name, requisites.status_name
                            order by ph.start_date desc) rn_sd
           , vi.contact_id
           , ent.obj_name('CONTACT', vi.contact_id) contact_name
           , requisites.type_requisit_absenced
           , ph.ids
           , dep.name                  as dep_name
           , dep.department_id         as department_id
           , ent.obj_name('CONTACT'
                       , ach.agent_id) as agent_name
           , ent.obj_name('CONTACT'
                       , ach_leader.agent_id) as leader_name
           , ach_leader.agent_id       as leader_id
           , ach.agent_id              as agent_id
           , requisites.type_name      as requisites_type_name
           , requisites.name           as requisites_name
           , requisites.status_name    as requisites_status_name
           , (select cct.telephone_number 
              from cn_contact_telephone cct
              where cct.contact_id = vi.contact_id
                    and cct.status = 1
                    and rownum < 2)     as contact_number
           , c.is_check_adr_tel
           , pr.description                as prod_description
           , pr.brief                      as prod_brief

    from ven_p_policy                     pp
         , p_pol_header                   ph
         , v_pol_issuer                   vi
         , doc_status_ref                 pol_status
         , contact                        c
         , t_contact_type                 ct
         , t_product                      pr
         , p_policy_agent_doc ad
         , document ad_d
         , doc_status_ref ad_dsr
         , ag_contract_header ach
         , ag_contract agc
         , department dep
         , ag_contract agc_leader
         , ag_contract_header ach_leader
         ,  (select cct.contact_id, 'Телефон' as type_requisit_absenced
                    , case when ttt.description  = 'Мобильный'
                      then 'Мобильный телефон'
                      else ttt.description
                      end as type_name
                    , cct.telephone_number name
                    , case when cct.status = 1
                                and trim(cct.telephone_number) is not null
                           then 'Действует'
                           else 'Не действует' end status_name
             from cn_contact_telephone cct
                  ,t_telephone_type ttt
             where ttt.id = cct.telephone_type
             and not exists (select 1 from cn_contact_telephone cct1
                             where cct1.contact_id = cct.contact_id
                                   and cct1.status = 1
                                   and trim(cct.telephone_number) is not null)
             union all
             select ca.contact_id
                    , 'Адрес' as type_requisit_absenced
                    , ca.address_type_name type_name
                    , ca.address_name name
                    , case when ca.status = 1
                                and trim(ca.address_name) is not null
                           then 'Действует'
                           else 'Не действует' end as status_name
             from v_cn_contact_address ca
             where
             not exists (select 1 from v_cn_contact_address ca1
                         where ca1.contact_id = ca.contact_id
                               and ca1.status = 1 
                               and trim(ca1.address_name) is not null)
          )  requisites

    where pp.pol_header_id                   = ph.policy_header_id
          and pp.policy_id                   = ph.last_ver_id
          and ph.ids is not null
          and pp.policy_id                   = vi.policy_id
          and vi.contact_id                  = c.contact_id
          and ct.id                          = c.contact_type_id
          and pol_status.doc_status_ref_id   = pp.doc_status_ref_id
          and pol_status.brief not in ('STOPED', 'TO_QUIT', 'TO_QUIT_CHECK_READY', 'TO_QUIT_CHECKED',
                                       'QUIT_REQ_QUERY', 'QUIT_REQ_GET', 'QUIT_TO_PAY', 'QUIT', 'RECOVER',
                                       'RECOVER_DENY', 'READY_TO_CANCEL', 'BREAK', 'CANCEL', 'QUIT_DECL'
                                      )
          and (ct.brief != 'ФЛ'
               or exists(
                          select 1
                          from cn_person cp_
                          where cp_.contact_id = c.contact_id
                             and cp_.date_of_death is null
                        )
               )--страхователь физ лицо и он жив или страхователь не физ лицо
          and exists(
                      select 1
                      from  as_asset    aa_
                            ,as_assured aas_
                            ,contact    c_aas_
                            ,cn_person  cp_
                      where aa_.p_policy_id             = pp.policy_id
                            and aa_.as_asset_id         = aas_.as_assured_id
                            and aas_.assured_contact_id = c_aas_.contact_id
                            and cp_.contact_id          = c_aas_.contact_id
                            and cp_.date_of_death       is  null
                    )--хотябы один застрахованны жив
          and ph.product_id                   = pr.product_id
          and ph.policy_header_id             = ad.policy_header_id
          and ad.p_policy_agent_doc_id = ad_d.document_id
          and sysdate between ad.date_begin and ad.date_end
          and ad_d.doc_status_ref_id = ad_dsr.doc_status_ref_id
          and ad_dsr.brief = 'CURRENT'
          and ad.ag_contract_header_id = ach.ag_contract_header_id
          and ach.ag_contract_header_id = agc.contract_id
          and ach.last_ver_id =  agc.ag_contract_id
          and agc.agency_id = dep.department_id


          and agc.contract_leader_id = agc_leader.ag_contract_id(+)
          and agc_leader.contract_id = ach_leader.ag_contract_header_id(+)

          and vi.contact_id                   = requisites.contact_id --(+)

          and pr.brief in (
          'InvestorALFA','OPS_Plus_New','OPS_Plus_2','Fof_Prot','END','CHI','TERM','PEPR','END_2','CHI_2',
          'TERM_2','PEPR_2','Family_Dep','Family_Dep_2011','Investor','INVESTOR_LUMP','Family La','Platinum_LA',
          'Baby_LA','Family_La2','Platinum_LA2','Baby_LA2','ACC','APG','PRIN_DP_NEW','PRIN_DP','LOD','OPS_Plus','SF_Plus',
          'SF_AVCR','GN'
          )
    )
where rn_sd = 1;
/*
select distinct cct.telephone_number from cn_contact_telephone cct where cct.status = 1 and (
cct.telephone_number like '%XX%'
or cct.telephone_number like '%xx%'
or cct.telephone_number like '%ХХ%'
or cct.telephone_number like '%хх%')

select * from cn_contact_telephone t where t.id = 2859435*/

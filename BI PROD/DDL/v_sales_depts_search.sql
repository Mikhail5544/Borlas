create or replace view v_sales_depts_search as
select sh.sales_dept_header_id    as dept_header_id
      ,to_char(sh.universal_code,'FM0009') as dept_number
      ,'Продающее подразделение'  as dept_type_name
      ,'SALES_DEPT'               as dept_type_brief
      ,sd.dept_name
      ,case sd.send_status
         when -1 then 'Не экспортировано'
         when 0  then 'Не экспортировалось'
         when 1  then 'Экспортировано'
       end as send_status
      ,nullif(sd.close_date,pkg_sales_depts.get_default_end_date) as close_date
      ,sd.marketing_name
      ,sd.legal_name
      ,co.obj_name_orig as initiator_name
      ,(select ot.name
          from ven_organisation_tree ot
         where ot.organisation_tree_id = sd.branch_id
       ) as branch_name
      ,tp.tap_number
      ,rh.roo_number
      ,ro.roo_name
      ,cc.cc_code
      ,cc.cc_name
      ,tt.tac_number
      ,tt.tac_name
      ,sc.description    as sales_channel
      ,mco.obj_name_orig as manager_name
      ,nvl(ad.name, pkg_contact.get_address_name(ad.id)) as address
      ,sd.sales_dept_id as fake_pk
  from ven_sales_dept_header  sh
      ,ven_sales_dept         sd
      ,ven_ag_contract_header ch
      ,contact                co
      ,ven_t_tap_header       th
      ,ven_t_tap              tp
      ,ven_t_roo_header       rh
      ,ven_t_roo              ro
      ,(select tt.t_tap_header_id
              ,tc.tac_number
              ,tc.tac_name
          from ven_t_tac_to_tap       tt
              ,ven_t_tac              tc
              ,ven_t_tac_header       tch
         where tt.t_tac_id = tc.t_tac_id
           and tc.t_tac_id = tch.last_tac_id
           and tt.end_date = pkg_tac.get_default_end_date
      ) tt
      ,ven_t_navision_cc      cc
      ,ag_contract_header     mah
      ,contact                mco
      ,ag_contract            mac
      ,t_sales_channel        sc
      ,ven_cn_entity_address  ea
      ,cn_address             ad
 where sh.last_sales_dept_id = sd.sales_dept_id
   and sd.initiator_id       = ch.ag_contract_header_id
   and ch.agent_id           = co.contact_id
   and sd.manager_id         = mah.ag_contract_header_id
   and mah.agent_id          = mco.contact_id
   and mah.last_ver_id       = mac.ag_contract_id
   and mac.ag_sales_chn_id   = sc.id
   and sd.t_tap_header_id    = th.t_tap_header_id
   and th.last_tap_id        = tp.t_tap_id
   and sd.t_roo_header_id    = rh.t_roo_header_id
   and rh.last_roo_id        = ro.t_roo_id
   and th.t_tap_header_id    = tt.t_tap_header_id (+)
   and sd.t_navision_cc_id   = cc.t_navision_cc_id
   and sd.ent_id             = ea.ure_id
   and sd.sales_dept_id      = ea.uro_id
   and ea.address_id         = ad.id
   and safety.check_right_custom('CSR_SDEPTS_SEARCH') = 1
union all
-- РОО
select rh.t_roo_header_id      as dept_header_id
      ,to_char(rh.roo_number)  as dept_number
      ,'РОО'                   as dept_type_name
      ,'ROO'                   as dept_type_brief
      ,ro.roo_name
      ,null as send_status
      ,nullif(ro.close_date,pkg_roo.get_default_end_date) as close_date
      ,sd.marketing_name
      ,sd.legal_name
      ,co.obj_name_orig as initiator_name
      /*Чирков 164396 Доработка - карточка подразделений_приоритет
      * добавил комментарий и заменил на sd.dept_name
      ,(select ot.name
          from ven_organisation_tree ot
         where ot.organisation_tree_id = sd.branch_id
       ) as branch_name*/
      ,sd.dept_name as branch_name
      --
      ,tp.tap_number
      ,rh.roo_number
      ,ro.roo_name
      ,null as cc_code
      ,null as cc_name
      ,null as tac_number
      ,null as tac_name
      ,null as sales_channel
      ,null as manager_name
      ,null as address
      ,ro.t_roo_id as fake_pk
  from ven_t_roo_header       rh
      ,ven_t_roo              ro
      ,ven_sales_dept_header  sh
      ,ven_sales_dept         sd
      ,ven_ag_contract_header ch
      ,contact                co
      ,ven_t_tap_header       th
      ,ven_t_tap              tp
 where rh.last_roo_id     = ro.t_roo_id
   and ro.organisation_tree_id = sh.organisation_tree_id  (+)
   and sh.last_sales_dept_id   = sd.sales_dept_id         (+)
   and sd.initiator_id         = ch.ag_contract_header_id (+)
   and ch.agent_id             = co.contact_id            (+)
   and ro.t_tap_header_id      = th.t_tap_header_id       (+)
   and th.last_tap_id          = tp.t_tap_id              (+)
   and safety.check_right_custom('CSR_ROO_SEARCH') = 1
union all
-- ТАЦ
select th.t_tac_header_id      as dept_header_id
      ,to_char(tc.tac_number)  as dept_number
      ,'ТАЦ'                   as dept_type_name
      ,'TAC'                   as dept_type_brief
      ,tc.tac_name
      ,case tc.send_status
         when -1 then 'Не экспортировано'
         when 0  then 'Не экспортировалось'
         when 1  then 'Экспортировано'
       end as send_status
      ,nullif(tc.close_date,pkg_tac.get_default_end_date) as close_date
      ,null as marketing_name
      ,null as legal_name
      ,null as initiator_name
      ,null as branch_name
      ,null as tap_number
      ,null as roo_number
      ,null as roo_name
      ,null as cc_code
      ,null as cc_name
      ,tc.tac_number
      ,tc.tac_name
      ,null as sales_channel
      ,null as manager_name
      ,null as address
      ,tc.t_tac_id as fake_pk
  from ven_t_tac_header       th
      ,ven_t_tac              tc
 where th.last_tac_id   = tc.t_tac_id
   and safety.check_right_custom('CSR_TAC_SEARCH') = 1
union all
-- ТАП
select th.t_tap_header_id      as dept_header_id
      ,to_char(tp.tap_number)  as dept_number
      ,'ТАП'                   as dept_type_name
      ,'TAP'                   as dept_type_brief
      ,null as tap_name
      ,case tp.send_status
         when -1 then 'Не экспортировано'
         when 0  then 'Не экспортировалось'
         when 1  then 'Экспортировано'
       end as send_status
      ,nullif(tp.close_date,pkg_tap.get_default_end_date) as close_date
      ,sd.marketing_name
      --Чирков164396 Доработка - карточка подразделений_приоритет
      ,null legal_name --sd.legal_name
      ,null initiator_name --co.obj_name_orig as initiator_name
      ,
      /*(select ot.name
          from ven_organisation_tree ot
         where ot.organisation_tree_id = sd.branch_id
       ) as branch_name*/
       (select to_char(rh.roo_number)
              from ven_t_roo_header rh
                  ,ven_t_roo        ro
             where ro.t_roo_id = rh.last_roo_id
                   and ro.t_tap_header_id = tp.t_tap_header_id
        ) as branch_name
      --
      ,tp.tap_number
      ,null as roo_number
      ,null as roo_name
      ,null as cc_code
      ,null as cc_name
      ,null as tac_number
      ,null as tac_name
      ,null as sales_channel
      ,null as manager_name
      ,null as address
      ,tp.t_tap_id as fake_pk
  from ven_t_tap_header       th
      ,ven_t_tap              tp
      ,ven_sales_dept_header  sh
      ,ven_sales_dept         sd
      --,ven_ag_contract_header ch
      --,contact                co

 where th.last_tap_id          = tp.t_tap_id
   and tp.organisation_tree_id = sh.organisation_tree_id  (+)
   and sh.last_sales_dept_id   = sd.sales_dept_id         (+)
   --Чирков164396 Доработка - карточка подразделений_приоритет /*комменарии*/
   --and sd.initiator_id         = ch.ag_contract_header_id (+)
   --and ch.agent_id             = co.contact_id            (+)
   --
   and safety.check_right_custom('CSR_TAP_SEARCH') = 1

union all
-- ЦЗ Navision
select cc.t_navision_cc_id      as dept_header_id
      ,cc.cc_code               as dept_number
      ,'ЦЗ'                     as doc_type_name
      ,'NAV_CC'                 as doc_type_brief
      ,cc.cc_name
      ,case cc.send_status
         when -1 then 'Не экспортировано'
         when 0  then 'Не экспортировалось'
         when 1  then 'Экспортировано'
       end as send_status
      ,nullif(cc.close_date,to_date('31.12.3000','dd.mm.yyyy')) as close_date
      ,null as marketing_name
      ,null as legal_name
      ,null as initiator_name
      ,null as branch_name
      ,null as tap_number
      ,null as roo_number
      ,null as roo_name
      ,cc.cc_code
      ,cc.cc_name
      ,null as tac_number
      ,null as tac_name
      ,null as sales_channel
      ,null as manager_name
      ,null as address
      ,cc.t_navision_cc_id as fake_pk
  from ven_t_navision_cc cc;

CREATE OR REPLACE VIEW V_REP_DISTIBUTION_RISKS_SUR AS
with tmp_tab as
(SELECT /*+ NO_MERGE*/
               nvl(t.pol_header_id,0)                       as ph
               
               ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID)) as ph_num
               --,nvl(to_char(decode(t.POL_HEADER_ID,0,null,t.POL_HEADER_ID)), t.pol_num)    
               ,t.agent_number                              as agent_number
               ,t.bonus_type                                as bonus_type
               ,t.agent_name                                as agent_name
               ,sum(distinct t.prem_percent)                as prem_percent
               ,sum(t.prem)                                 as prem
          from 
          distibution_risks t       
        group by nvl(t.pol_header_id,0)
                ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))
                ,t.agent_number
                ,t.bonus_type
                ,t.agent_name
                ,t.prem_percent
       )
,
tmp_tab_date as (SELECT /*+ NO_MERGE*/
                     nvl(t.pol_header_id,0)                      as ph
                     ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))  as ph_num
                     ,t.agent_number                             as agent_number
                     ,t.bonus_type                               as bonus_type
                     ,Upper(t.Agent_name)                        as agent_name
                     ,t.date_register                            as date_register
                     ,t.otch_period                              as otch_period
                     ,sum(distinct t.prem_percent)               as prem_percent
                     ,sum(t.prem)                                as prem
                from 
                     distibution_risks t 
                group by nvl(t.pol_header_id,0)
                      ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))
                      ,t.agent_number
                      ,t.bonus_type
                      ,Upper(t.Agent_name)
                      ,t.date_register
                      ,t.otch_period
                      ,t.prem_percent
                      )       
SELECT /*+ LEADING (t b)*/
       null                                                      as "Номер ведомости",
       null                                                      as "Версия ведомости",
       b.policy_header_id                                        as policy_header_id,
       b.pol_ser                                                 as pol_ser,
       nvl(b.pol_num,t.ph_num  )                                  as pol_num,
       b.prod_id                                                 as prod_id,
       case when b.policy_header_id is null 
         then 'OPS'
         else b.prod_name                                               
       end                                                       as "Продукт",
       b.t_prod_line_option_id                                   as "id Риска",
       b.tplo_name                                               as "Риск",
       b.tplo_type                                               as "Признак Ж/НС",
       b.active_pol                                              as active_p_policy_id,
       ach.ag_contract_header_id                                 as ag_contract_header_id,
       ach.agent_id                                              as agent_id,
       ach.num                                                   as "Номер АД",
       t.Agent_name                                              as Agent_name,
       agc.category_name                                         as "Категория агента на дату вед",
       NULL                                                      as "Статус агента на дату вед",
       t.bonus_type                                              as "Тип АВ",
       t.prem_percent                                            as "Ставка",
       t.prem*nvl(b.premium/sum(b.premium) 
       over (partition by t.ph
                        , t.bonus_type
                        , t.agent_number
                        , t.date_register
                        , t.otch_period
                        , prem_percent),1)                       as "comiss by risk",
              
       t.date_register                                           as "Дата расчёта BORLAS",
       t.otch_period                                             as "Отчётный период"
  FROM ven_ag_contract_header ach,
       department             dep,
       ag_contract            ac,
       ins.ag_category_agent  agc,
       tmp_tab_date           t,
       (select /*+ LEADING(tm ph) NO_MERGE*/
               ph.policy_header_id,
               pp.pol_ser,
               pp.pol_num,
               ph.policy_id active_pol,
               tp.product_id prod_id,
               tp.DESCRIPTION prod_name,
               pc.t_prod_line_option_id,
               tplo.description tplo_name,
               decode(ig.life_property,1,'Ж',0,'НС')  tplo_type,
               sum(pc.fee) premium --сумма если несколько застрахованных
          from as_asset aas,
               p_policy pp,
               status_hist sha,
               p_pol_header ph,
               p_cover  pc,
               status_hist shp,
               t_product tp,
               t_prod_line_option tplo,
               t_product_line     pl,
               t_lob_line         ll,
               t_insurance_group  ig,
               tmp_tab            tm
         where ph.policy_id = aas.p_policy_id
           AND ph.product_id = tp.product_id
           AND pp.policy_id = ph.policy_id
           and pc.as_asset_id = aas.as_asset_id
           and sha.status_hist_id = aas.status_hist_id
           and sha.brief <> 'DELETED'
           and tplo.ID = pc.t_prod_line_option_id
           and shp.status_hist_id = pc.status_hist_id
           and shp.brief <> 'DELETED'
           and tplo.description <> 'Административные издержки'
           and tplo.description <> 'Не страховые убытки'
           and pl.id = tplo.product_line_id
           and ll.t_lob_line_id = pl.t_lob_line_id
           and ig.t_insurance_group_id = ll.insurance_group_id
           and ph.policy_header_id = tm.ph
         group by ph.policy_header_id,
                  pp.pol_ser,
                  pp.pol_num,
                  ph.policy_id ,
                  tp.product_id ,
                  tp.DESCRIPTION ,
                  pc.t_prod_line_option_id,
                  tplo.description,
                  decode(ig.life_property,1,'Ж',0,'НС')
     )b
 WHERE 1=1
   AND ach.num = t.agent_number
   AND ac.category_id = agc.ag_category_agent_id
   and ac.ag_contract_id = PKG_AGENT_1.GET_STATUS_BY_DATE(ach.ag_contract_header_id,trunc(last_day(t.date_register))) --из-за внешников получаем версию по старому
   and dep.department_id = ach.agency_id
   --206526: Ошибка при размазке/на один номер агентского договора приходится 2 агента. Не должен попадать RLA/
   and (dep.short_name    != 'RLA' or dep.short_name is null)                                                  
   --                    
   and t.ph = b.policy_header_id (+);

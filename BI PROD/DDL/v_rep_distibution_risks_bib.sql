CREATE OR REPLACE VIEW V_REP_DISTIBUTION_RISKS_BIB AS
with tmp_tab as
(         SELECT /*+ NO_MERGE*/
                 nvl(t.pol_header_id,0)                       as ph               
                 ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))    as ph_num
                 ,t.bonus_type                                as bonus_type
                 ,Upper(t.Agent_name)                         as Agent_name
                 ,sum(distinct t.prem_percent)                as prem_percent
                 ,sum(t.prem)                                 as prem
          from 
               distibution_risks t 
          group by nvl(t.pol_header_id,0)
                ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID))
                ,t.agent_number
                ,t.bonus_type                
                ,Upper(t.Agent_name)
                ,t.prem_percent
)
,
tmp_tab_date as (SELECT /*+ NO_MERGE*/
                     nvl(t.pol_header_id,0)                    as ph
                     ,decode(nvl(t.pol_header_id,0), 0 , t.pol_num, to_char(t.POL_HEADER_ID)) as ph_num
                     ,t.bonus_type                             as bonus_type
                     ,Upper(t.Agent_name)                      as Agent_name
                     ,t.date_register                          as date_register
                     ,t.otch_period                            as otch_period
                     ,sum(distinct t.prem_percent)             as prem_percent
                     ,sum(t.prem)                              as prem
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
       null                               as "Номер ведомости",
       null                               as "Версия ведомости",
       b.policy_header_id                 as policy_header_id,
       b.pol_ser                          as pol_ser,
       nvl(b.pol_num,t.ph_num)            as pol_num,
       b.prod_id                          as prod_id,
       case when b.policy_header_id is null 
         then 'OPS'
         else b.prod_name                                               
       end                                as "Продукт",
       b.t_prod_line_option_id            as "id Риска",
       b.tplo_name                        as "Риск",
       b.tplo_type                        as "Признак Ж/НС",
       b.active_pol                       as active_p_policy_id,
       null                               as AG_CONTRACT_HEADER_ID,
       null                               as AGENT_ID,
       null                               as "Номер АД",
       
       t.Agent_name                       as Agent_name,
       null                               as "Категория агента на дату вед",
       null                               as "Статус агента на дату вед",
       t.bonus_type                       as "Тип АВ",
       t.prem_percent                     as "Ставка",
       t.prem*nvl(b.premium/sum(b.premium) 
       over (partition by t.ph
                        , upper(t.Agent_name)
                        , t.bonus_type
                        , t.date_register
                        , prem_percent),1)  as "comiss by risk",
       
       t.date_register                         as "Дата расчёта BORLAS",
       t.otch_period                           as "Отчётный период"
  FROM 
       tmp_tab_date t,
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
         where 
           ph.policy_header_id = tm.ph
           and ph.policy_id = aas.p_policy_id
           AND ph.product_id = tp.product_id
           AND pp.policy_id = ph.policy_id
           and pc.as_asset_id = aas.as_asset_id
           and sha.status_hist_id = aas.status_hist_id
           and sha.brief <> 'DELETED'
           and tplo.ID = pc.t_prod_line_option_id
           and shp.status_hist_id = pc.status_hist_id
           and shp.brief <> 'DELETED'
           and tplo.description <> 'Административные издержки'
           and tplo.description != 'Не страховые убытки'
           and pl.id = tplo.product_line_id
           and ll.t_lob_line_id = pl.t_lob_line_id
           and ig.t_insurance_group_id = ll.insurance_group_id
           
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
       and t.ph = b.policy_header_id (+);

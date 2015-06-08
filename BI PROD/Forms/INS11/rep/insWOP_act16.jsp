<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report">


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="dopsg_ids" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="insur_act" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="EVENT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>

	<userParameter name="t_asset" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>

	 
     <dataSource name="Q_TABLE">
      <select canParse="no">
      <![CDATA[
--inswop_act16
select 
    peril_name
    ,peril_id  
    ,diagnose
    --страховая сумма  
    ,LTRIM(TO_CHAR(ins_amount, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount 
    --сумма ранее произведенных выплат
    ,LTRIM(TO_CHAR(payment_amount, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) payment_amount 
    --страховая сумма с учетом выплат    
    ,LTRIM(TO_CHAR(ins_paym, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', '''))ins_paym
     --%по таблице выплат    
    ,case when nvl(rate_tbl,0) = 0 then '-'
          else LTRIM(TO_CHAR(rate_tbl, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) || '%'
     end rate_tbl
    --% от страховой суммы за каждый день  
    ,case when nvl(rate_day,0) = 0 then '-'
          else LTRIM(TO_CHAR(rate_day, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) || '%'
     end rate_day
    --количесво дней     
    , kolvo
    --сумма к выплате
    ,  LTRIM(TO_CHAR(viplata, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) viplata  
    --дата очередного платежа
    ,to_char(due_date,'dd.mm.yyyy') due_date   
    --сумма задолженности 
    ,case when s_z != 0 then LTRIM(TO_CHAR(s_z, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) else '-' end s_z
    --сумма к выплате с учетом задолженности
    ,case when has_PAYORDER = 1 and has_PAYORDER_SETOFF = 0 --есть только В, то прочерк
         then '-'
         when  has_PAYORDER = 0 and has_PAYORDER_SETOFF = 1 --есть только З, то '0.00'
         then '0.00'
         --если и В и З, то только В
         else LTRIM(TO_CHAR(nvl(PAYORDER_sum,0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) 
    end s_v
   --Название страхового случая и Сумма
   ,case when has_PAYORDER = 1 and has_PAYORDER_SETOFF = 0 --есть только В, то сумма В
         then LTRIM(TO_CHAR(nvl(PAYORDER_sum,0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) 
         when  has_PAYORDER = 0 and has_PAYORDER_SETOFF = 1 --есть только З, то сумма З
         then LTRIM(TO_CHAR(nvl(PAYORDER_SETOFF_sum,0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) 
         --если и В и З, то только В    
         else LTRIM(TO_CHAR(nvl(PAYORDER_sum,0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', '''))
    end s_r_s

    --итоговая сумма к выплате с учетом задолженности
    ,LTRIM(TO_CHAR(
    sum(
         case when has_PAYORDER = 1 and has_PAYORDER_SETOFF = 0 --есть только В, то сумма В
             then nvl(PAYORDER_sum,0)
             when  has_PAYORDER = 0 and has_PAYORDER_SETOFF = 1 --есть только З, то сумма З
             then nvl(PAYORDER_SETOFF_sum,0)
             --если и В и З, то только В    
             else nvl(PAYORDER_sum,0)
         end
        )over() 
    , '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) sum_s_v
    ,has_PAYORDER
    ,has_PAYORDER_SETOFF
    ,PAYORDER_sum
    ,PAYORDER_SETOFF_sum
  ,LTRIM(TO_CHAR(fee_osn, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) fee_osn
    ,LTRIM(TO_CHAR(fee_dop, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) fee_dop 
FROM(    

    SELECT
            peril_name 
            ,peril_id
            ,diagnose
            --страховая сумма
            ,ins_amount 
            --сумма ранее произведенных выплат
            ,ot_claim payment_amount
            --страховая сумма с учетом выплат
            ,case when one_is_aggregate = 1 
                  then ins_amount - ot_claim
                  else ins_amount
             end ins_paym
            --количесво дней     
            , nvl(to_char(rec_days),'-') kolvo
            --сумма к выплате
            , viplata  
            --дата очередного платежа
            , due_date     
            --сумма задолженности 
            ,case when nvl(real_z, 0) > 0 and has_PAYORDER_SETOFF = 1 then real_z else 0 end  s_z
            --сумма к выплате с учетом задолженности
            ,case when nvl(viplata,0) - nvl(real_z,0) < 0 then 0 else nvl(viplata,0) - nvl(real_z,0) end s_v
            ,real_z
            --%по таблице выплат   
            ,sum(
                case when nvl(ins_amount,0) = 0 then 0
                     else 
                         case when  d_status_brief in ('NEW', 'CURRENT') then
                           round(a.payment_sum * a.rate / (a.ins_amount - pkg_claim.get_payed_cover_sum(a.c_claim_id, a.p_cover_id)) * 100, 1)
                         else 
                           0
                         end
                end)  rate_tbl
             --% от страховой суммы за каждый день    
            , sum(case when peril_name like '%оспитализация%'
                           or peril_name like '%Временная нетрудоспособность застрахованного в результате%'
                           or peril_name like 'Временная утрата трудоспособности застрахованным%'
                     then      
                            (case when pc_ins_amount > 0 then 
                                       round(nvl(declare_sum,0) * a.rate/ (pc_ins_amount - nvl(ot_claim,0)) * 100, 1)
                             else 0 end)       
                      else 0               
                 end) rate_day 

            ,has_PAYORDER_SETOFF
            ,has_PAYORDER           
            ,PAYORDER_sum         
            ,PAYORDER_SETOFF_sum    
      ,fee_osn
            ,fee_dop 
        FROM
            (SELECT 
                  cch.c_claim_header_id,   
                  case when plo.description like 'Защита страховых%'
                    then plo.description
                  when plo.description like 'Освобождение%'
                    then plo.description
                  when plo.description like '%Дожитие%по независящим%'
                    then plo.description
                  when plo.description like '%"Расширенная Госпитализация"%'
                    then plo.description    
            when plo.description like 'Первичное диагностирование смертельно опасного заболевания'
                    then plo.description   
                  else nvl(tp.description,'-')
                  end peril_name
                  ,tp.id peril_id
                  
                  ,cch.ins_sum ins_amount--pc.ins_amount 
                  
                  ,(select sum(nvl(x.payment_sum,0))
                    from v_other_claim_header x,
                         c_claim_header hl,
                         p_cover pc
                    where x.c_claim_header_id = hl.c_claim_header_id                           
                          and x.policy_id = hl.p_policy_id
                          and pc.p_cover_id = hl.p_cover_id
                          and nvl(pc.is_aggregate,0) = 1
                          and x.c_claim_header_id = cch.c_claim_header_id              
                          and hl.c_event_id = cch.c_event_id
                          and hl.p_policy_id = cch.p_policy_id
                          and hl.p_cover_id = cch.p_cover_id
                          and x.as_asset_id = cch.as_asset_id
                          ) ot_claim                   --сумма ранее произведенных выпла

                        
                          
                 ,acc.Get_Cross_Rate_By_Id(1,d.damage_fund_id ,cch.fund_id,cch.declare_date) rate                                  
                 ,pc.is_aggregate                          --для расчета % по таблице выплат
                 ,d.payment_sum              
                 ,d.c_claim_id
                 ,d.p_cover_id
                 ,d.declare_sum                            --Заявленная сумма
                 ,trunc(d.rec_end_date) - trunc(d.rec_start_date) + 1 rec_days
                 ,pc.ins_amount  pc_ins_amount             --Страховая сумма по риску
                 ,vsh.brief d_status_brief
                 ,nvl(e.diagnose,'-') diagnose
                 ,sum(d.payment_sum) over(partition by c_claim_header_id) viplata      
                 , (select min(ac.due_date)
                   from ins.p_policy p
                        , ins.p_policy p_2
                        , ins.p_pol_header ph 
                        , ins.doc_doc dd 
                        , ins.ven_ac_payment ac  
                        , ins.doc_templ dt 
                        , ins.doc_status_ref dsr 
                   where p.policy_id = cch.p_policy_id
                         and ph.policy_header_id = p.pol_header_id
                         and ph.policy_header_id = p_2.pol_header_id
                         and dd.parent_id = p_2.policy_id
                         and dd.child_id = ac.payment_id
                         and dt.doc_templ_id = ac.doc_templ_id
                         and dt.brief = 'PAYMENT'
                         and dsr.doc_status_ref_id = ac.doc_status_ref_id
                         and dsr.brief = 'NEW') due_date

                 ,(select sum(ac.amount -                                    --сколько надо зачесть
                      nvl(Pkg_Payment.get_set_off_amount(ac.payment_id, NULL, NULL),0) --сумма зачета ЭПГ
                             )
                   from ins.p_policy p
                        , ins.p_policy p_2
                        , ins.p_pol_header ph 
                        , ins.doc_doc dd 
                        , ins.ven_ac_payment ac  
                        , ins.doc_templ dt 
                        , ins.doc_status_ref dsr 
                   where p.policy_id = cch.p_policy_id
                         and ph.policy_header_id = p.pol_header_id
                         and ph.policy_header_id = p_2.pol_header_id
                         and dd.parent_id = p_2.policy_id
                         and dd.child_id = ac.payment_id
                         and dt.doc_templ_id = ac.doc_templ_id
                         and dt.brief = 'PAYMENT'
                         and dsr.doc_status_ref_id = ac.doc_status_ref_id
                         and dsr.brief = 'TO_PAY') real_z 
                , case when exists(select 1 from p_cover pc 
                                   where pc.p_cover_id = cch.p_cover_id 
                                         and pc.is_aggregate = 1) 
                       then 1 else 0 
                  end  one_is_aggregate     
                  
                  
                  
                , case when exists( 
                                    select 1
                                    from c_claim cc
                                        , doc_doc dd 
                                        , ac_payment vipl
                                        , document d_vipl
                                        , doc_status_ref dsr 
                                        , doc_templ dt  
                                    where /*cc.c_claim_id = cch.active_claim_id
                                          and*/ 
						                  cc.c_claim_header_id = cch.c_claim_header_id										  
										  and dd.parent_id = cc.c_claim_id
                                          and vipl.payment_id = dd.child_id
                                          and vipl.payment_id = d_vipl.document_id      
                                          and d_vipl.doc_status_ref_id =  dsr.doc_status_ref_id 
                                          and dsr.brief not in ('ANNULATED', 'CANCEL')   
                                          and dt.doc_templ_id = d_vipl.doc_templ_id
                                          and dt.brief in ('PAYORDER')                                      
                                    )  
                        then 1
                        else 0
                   end has_PAYORDER
                , case when exists( 
                                    select 1
                                    from c_claim cc
                                        , doc_doc dd 
                                        , ac_payment vipl
                                        , document d_vipl
                                        , doc_status_ref dsr 
                                        , doc_templ dt  
                                    where /*cc.c_claim_id = cch.active_claim_id
                                          and*/
										  cc.c_claim_header_id = cch.c_claim_header_id										  
										  and dd.parent_id = cc.c_claim_id
                                          and vipl.payment_id = dd.child_id
                                          and vipl.payment_id = d_vipl.document_id      
                                          and d_vipl.doc_status_ref_id =  dsr.doc_status_ref_id 
                                          and dsr.brief not in ('ANNULATED', 'CANCEL')                                      
                                          and dt.doc_templ_id = d_vipl.doc_templ_id
                                          and dt.brief in ('PAYORDER_SETOFF')   
                                    )  
                        then 1
                        else 0
                   end has_PAYORDER_SETOFF   
                   
                   ,(select sum(vipl.amount)
                  from c_claim cc
                      , doc_doc dd 
                      , ac_payment vipl
                      , document d_vipl
                      , doc_status_ref dsr 
                      , doc_templ dt  
                  where /*cc.c_claim_id = cch.active_claim_id
                        and*/
						cc.c_claim_header_id = cch.c_claim_header_id						
						and dd.parent_id = cc.c_claim_id
                        and vipl.payment_id = dd.child_id
                        and vipl.payment_id = d_vipl.document_id      
                        and d_vipl.doc_status_ref_id =  dsr.doc_status_ref_id 
                        and dsr.brief not in ('ANNULATED', 'CANCEL')                                      
                        and dt.doc_templ_id = d_vipl.doc_templ_id
                        and dt.brief in ('PAYORDER')) PAYORDER_sum   
                  ,(select sum(vipl.amount)
                  from c_claim cc
                      , doc_doc dd 
                      , ac_payment vipl
                      , document d_vipl
                      , doc_status_ref dsr 
                      , doc_templ dt  
                  where /*cc.c_claim_id = cch.active_claim_id
                        and*/ 						
						cc.c_claim_header_id = cch.c_claim_header_id
						and dd.parent_id = cc.c_claim_id
                        and vipl.payment_id = dd.child_id
                        and vipl.payment_id = d_vipl.document_id      
                        and d_vipl.doc_status_ref_id =  dsr.doc_status_ref_id 
                        and dsr.brief not in ('ANNULATED', 'CANCEL')                                      
                        and dt.doc_templ_id = d_vipl.doc_templ_id
                        and dt.brief in ('PAYORDER_SETOFF')) PAYORDER_SETOFF_sum    
        
        ,(select sum(pc.fee)
                    from ven_p_policy pp, 
                          ven_as_asset ass, 
                          ven_p_cover pc,
                          ven_t_prod_line_option plo,
                          ven_t_product_line pl,
                          ven_t_product_line_type plt
                     where pp.policy_id = cch.p_policy_id
                           and ass.p_policy_id = pp.policy_id
                           and pc.as_asset_id = ass.as_asset_id
                         and pp.decline_date is null
                           and plo.id = pc.t_prod_line_option_id
                           and plo.product_line_id = pl.id
                           and pl.product_line_type_id = plt.product_line_type_id
                           and plt.brief = 'RECOMMENDED'
                           and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ') fee_osn
               
                   , (select nvl(sum(pc.fee),0)
                     from ven_p_policy pp, 
                          ven_as_asset ass, 
                          ven_p_cover pc,
                          ven_t_prod_line_option plo,
                          ven_t_product_line pl,
                          ven_t_product_line_type plt
                     where pp.policy_id = cch.p_policy_id
                           and ass.p_policy_id = pp.policy_id
                           and pc.as_asset_id = ass.as_asset_id
                         and pp.decline_date is null
                           and plo.id = pc.t_prod_line_option_id
                           and plo.product_line_id = pl.id
                           and pl.product_line_type_id = plt.product_line_type_id
                           and plt.brief in ('OPTIONAL','MANDATORY')
                           and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
                         and plo.description not in ('Защита страховых взносов','Защита страховых взносов рассчитанная по основной программе',
                         'Защита страховых взносов расчитанная по основной программе',
                         'Освобождение от уплаты дальнейших взносов',
                         'Освобождение от уплаты взносов рассчитанное по основной программе',
                         'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе',
                         'Освобождение от уплаты страховых взносов'))
                    fee_dop               
                                   
            FROM c_claim_header cch 
                , c_event e
                , p_cover pc
                ,ins.t_prod_line_option plo 
                ,t_peril tp
                
                ,c_damage d
                ,ven_status_hist vsh      
        ,document d_c 
                ,doc_status_ref dsr_c        
            where  e.c_event_id = cch.c_event_id
            and pc.p_cover_id = cch.p_cover_id
            and pc.t_prod_line_option_id = plo.id
            and cch.peril_id = tp.id
            and cch.active_claim_id = d.c_claim_id
            and d.p_cover_id = pc.p_cover_id(+)
            and d.status_hist_id = vsh.status_hist_id               
            and cch.c_event_id =  :EVENT_ID
            and vsh.brief in ('NEW', 'CURRENT')
            and cch.active_claim_id = d_c.document_id            
            and dsr_c.doc_status_ref_id = d_c.doc_status_ref_id
            and dsr_c.brief = 'DECISION' 
      )a
    group by 
            peril_name 
            ,peril_id
            ,diagnose
            --страховая сумма
            ,ins_amount 
            --сумма ранее произведенных выплат
            ,ot_claim 
            --страховая сумма с учетом выплат
            ,case when one_is_aggregate = 1 
                  then ins_amount - ot_claim
                  else ins_amount
             end 
            --количесво дней     
            , nvl(to_char(rec_days),'-') 
            --сумма к выплате
            , viplata  
            --дата очередного платежа
            , due_date     
            --сумма задолженности 
            ,case when nvl(real_z, 0) > 0 and has_PAYORDER_SETOFF = 1 then real_z else 0 end 
            ,real_z 
            --сумма к выплате с учетом задолженности
            ,case when nvl(viplata,0) - nvl(real_z,0) < 0 then 0 else nvl(viplata,0) - nvl(real_z,0) end            
            ,has_PAYORDER_SETOFF
            ,has_PAYORDER   
            ,PAYORDER_sum
            ,PAYORDER_SETOFF_sum
      ,fee_osn
            ,fee_dop       
)             

             ]]>
      </select>

        <group name="G_TABLE">
			<dataItem name="peril_id"/>
		<formula name="CF_end_date" source="cf_end_dateformula"
			 datatype="character" width="500" precision="10" defaultWidth="100000"
			 defaultHeight="10000" columnFlags="16" defaultLabel="Cf End Date"
			 breakOrder="none">
			 <displayInfo x="0.00000" y="0.00000" width="0.00000" height="0.00000"/>
        </formula>

		</group>
    </dataSource>

	 
	 <dataSource name="Q_CLAIM">
      <select>
      <![CDATA[ 
select
      --№ дела
      num
      --полиса
      ,pol
      --вид страхования / программа
      ,prod
      --валюта договора
      ,brief
      --дата вступления договора в силу
      ,start_date
      --дата окончания действия программы
      ,end_date
      --застрахованный
      ,beneficiary
      --страхователь
      ,holder
      --выгодоприобретатель
      ,vigod
      --агент
      ,agent
      --дата наступления страхового случая
      ,event_date
      --дата составления
      ,status_claim
      --заголовок сумма задолженности
      ,date_s_z
	  ,1 rn
    from
      (
      select
        e.num
        ,decode(p.pol_ser, null, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
        ,prod.description prod
        ,f.brief
        ,to_char(ph.start_date,'DD.MM.YYYY') start_date
        ,  (select to_char(max(pc_1.end_date),'DD.MM.YYYY') 
            from ven_c_claim_header cch_1
               ,p_cover pc_1 
            where cch_1.c_event_id = e.c_event_id 
            and pc_1.p_cover_id(+) = cch_1.p_cover_id )
         end_date 
         ,    ent.obj_name(aa.ent_id, aa.as_asset_id) 
         beneficiary
         , (select c.obj_name_orig
            from p_policy_contact pco,
                 contact c
            where pco.contact_id = c.contact_id
                  and pco.contact_policy_role_id  = 6
                  and pco.policy_id = p.policy_id) holder                                  
         
         , case when UPPER(tp.description) like UPPER('Смерть застрахованного%')
                     or UPPER(tp.description) like UPPER('Смерть Страхователя%')
           then 
               pkg_utils.get_aggregated_string(cast(multiset(
                                                 select ent.obj_name(c.ent_id, b.contact_id)
                                                 from as_beneficiary b
                                                       ,contact c
                                                 where c.contact_id = b.contact_id 
                                                       and b.as_asset_id = aa.as_asset_id                                             
                                           ) as ins.tt_one_col), ', ')
		   else '-' 
           end  vigod    
        , case when max (trunc(ds_cc.start_date))over() = min(trunc(ds_cc.start_date))over() 
               then to_char(ds_cc.start_date,'DD.MM.YYYY') end  status_claim
                             
        , (select c.obj_name_orig
          from ins.p_policy_agent_doc pad,
             ag_contract_header ag,
             contact c
          where pad.ag_contract_header_id = ag.ag_contract_header_id
            and ag.agent_id = c.contact_id
            and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
            and pad.policy_header_id = p.pol_header_id
            and rownum = 1) 
        agent
        ,to_char(e.event_date,'DD.MM.YYYY') event_date
        , pkg_utils.get_aggregated_string(cast(multiset(
                   select to_char(ac.due_date, 'dd.mm.yyyy')
                   from ins.p_policy p
                        , ins.p_policy p_2
                        , ins.doc_doc dd 
                        , ins.ven_ac_payment ac  
                        , ins.doc_templ dt 
                        , ins.doc_status_ref dsr 
                   where p.policy_id = cch.p_policy_id
                         and ph.policy_header_id = p.pol_header_id
                         and ph.policy_header_id = p_2.pol_header_id
                         and dd.parent_id = p_2.policy_id
                         and dd.child_id = ac.payment_id
                         and dt.doc_templ_id = ac.doc_templ_id
                         and dt.brief = 'PAYMENT'
                         and dsr.doc_status_ref_id = ac.doc_status_ref_id
                         and dsr.brief = 'TO_PAY'
           ) as ins.tt_one_col), ', ') date_s_z 
        
         
      from ven_c_event e
         ,c_claim_header cch
         ,c_claim cc 
         ,document d_cc
         ,doc_status ds_cc 
         ,doc_status_ref dsr_cc 
         ,p_policy p 
         ,p_pol_header  ph      
         ,t_product prod 
         ,fund f        
         ,as_asset aa 
         ,t_peril tp
      where cch.c_event_id = e.c_event_id
      and cc.c_claim_header_id = cch.c_claim_header_id
      and cc.c_claim_id = cch.active_claim_id
      and d_cc.document_id = cc.c_claim_id
      and ds_cc.doc_status_id = d_cc.doc_status_id
      and dsr_cc.doc_status_ref_id = d_cc.doc_status_ref_id
      and dsr_cc.brief = 'DECISION' --Принято решение по делу
      and p.policy_id = cch.p_policy_id 
      and ph.policy_header_id = p.pol_header_id
      and prod.product_id = ph.product_id
      and aa.as_asset_id = cch.as_asset_id
      and cch.peril_id = tp.id
      
      and ph.fund_id = f.fund_id(+)
      and e.c_event_id = :EVENT_ID
      )
    group by 
      num
      ,pol
      ,prod
      ,brief
      ,start_date
      ,end_date
      ,beneficiary
      ,holder
      ,vigod
      ,agent
      ,event_date
      ,status_claim
       ,date_s_z;
	  ]]>
      </select>
      <group name="GR_ROW">
        <dataItem name="rn"/>
      </group>
    </dataSource>
	 
	 
	<dataSource name="Q_POL_VIPL">
		  <select>
		  <![CDATA[ 	 
					select distinct ent.obj_name(c.ent_id, c.contact_id)pol_vipl, 
					LTRIM(TO_CHAR(cd.share_payment, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) || '%' share_payment,
					1 rn_2
					from ven_c_claim_header cch         
						 ,c_declarants cd
						 ,ven_c_event_contact cec   
						 ,ven_contact c
						 ,document d_c 
                         ,doc_status_ref dsr_c  
					where cch.c_event_id = :EVENT_ID
					and cd.c_claim_header_id = cch.c_claim_header_id
					and cec.c_event_contact_id = cd.declarant_id
					and c.contact_id = cec.cn_person_id
					and cch.active_claim_id = d_c.document_id            
					and dsr_c.doc_status_ref_id = d_c.doc_status_ref_id
					and dsr_c.brief = 'DECISION';    
		  ]]>
		  </select>
		  <group name="GR_POL_VIPL">
			<dataItem name="rn_2"/>
		  </group>
     </dataSource>	 
	 
  </data>
  <programUnits>
   
	
<function name="cf_end_dateformula" returnType="character">
 <textSource>
      <![CDATA[function CF_end_dateFormula return Char is
 n number;
 buf varchar2(1000);
begin

 for rec in (select case when tp.description like 'Телесные%' then 'п. '||c.code||' '||'-'||' '||to_char(c.limit_val)||'%'
            when tp.description like 'Хирург%' then 'п. '||c.code||' '||'-'||' '||to_char(c.limit_val)||'%'
            else to_char(d.declare_sum / (pc.ins_amount - pkg_claim.get_payed_cover_sum(d.c_claim_id,pc.p_cover_id)) * 100)||'%' end val
from ven_c_claim_header ch,
     ven_c_claim clm,
     ven_p_policy p,
     p_cover pc,
     t_peril tp,
     c_damage d,
     t_damage_code c
where ch.p_policy_id = p.policy_id
       and ch.active_claim_id = clm.c_claim_id
       and ch.p_cover_id = pc.p_cover_id
       and d.p_cover_id = pc.p_cover_id
       and ch.active_claim_id = d.c_claim_id
       and d.status_hist_id <> 3
       and c.id = d.t_damage_code_id
       and ch.peril_id = tp.id
	   and doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт'
       and ch.c_event_id = :EVENT_ID
	   and ch.peril_id = :peril_id) 
    LOOP
        buf:= buf ||' '|| '(' || rec.val || ')';
    END LOOP;
    buf := rtrim(buf,', ');

return (buf);
end;]]>
 </textSource>
</function>
	
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="Страховой%20акт.files/filelist.xml">
<title>Страховой акт</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>57</o:TotalTime>
  <o:Created>2009-06-08T12:09:00Z</o:Created>
  <o:LastSaved>2009-06-08T12:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>325</o:Words>
  <o:Characters>1857</o:Characters>
  <o:Lines>15</o:Lines>
  <o:Paragraphs>4</o:Paragraphs>
  <o:CharactersWithSpaces>2178</o:CharactersWithSpaces>
  <o:Version>11.8107</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:PunctuationKerning/>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
   <w:DontGrowAutofit/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:1.5cm 42.5pt 1.5cm 1.5cm;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Обычная таблица";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-parent:"";
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
table.MsoTableGrid
	{mso-style-name:"Сетка таблицы";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<%
String fl = new String();
String p_itogo = "";
%>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
 <rw:foreach id="fi2" src="GR_ROW">

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'>Страховой акт</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=236 colspan=6 valign=top style='width:176.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>г. Москва<o:p></o:p></span></p>
  </td>
  <td width=202 colspan=6 valign=top style='width:151.15pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>Дата составления:<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><rw:field id="" src="status_claim"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>№ Дела<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="num"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Застрахованный<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="beneficiary"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>№ Полиса<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="pol"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Страхователь<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="holder"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Вид страхования / программа <o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="prod"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:7.0pt'>Выгодоприобретатель</span></span><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b>

<rw:field id="" src="vigod"/>

  </b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Валюта договора<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:8.0pt;mso-ansi-language:
  EN-US'><b><rw:field id="" src="brief"/></b></span><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Агент<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="agent"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата вступления договора
  страхования в силу<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="start_date"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 rowspan=2 style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата наступления страхового
  случая<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 rowspan=2 style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="event_date"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата окончания действия
  договора страхования (действия программы страхования)<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="end_date"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>1. Произошел ли страховой
  случай в период действия страховой защиты (срока страхования)?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>2. Произошел ли страховой
  случай в период действия временного страхового покрытия (выжидательного
  периода)?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Нет<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>3. Был ли оплачен очередной
  взнос, если страховая премия оплачивается в рассрочку?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>4. Произошел ли страховой
  случай в период действия льготного периода?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Нет<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>5. Уведомление о страховом
  случае направлено в установленные договором сроки?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>6. Были ли полностью
  предоставлены документы, подтверждающие факт наступления страхового случая?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:5.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Описание страхового случая<o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="tbl3" src="G_TABLE">
 <tr style='mso-yfti-irow:18'>
  <td width=638 colspan=16 valign=top style='width:700.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="peril_name"/></b>
  <rw:field id="" src="DIAGNOSE"/> <o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:19'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Расчет страховой выплаты<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21'>
  <td width=56 colspan=4 valign=top style='width:42.05pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Название страхового риска<o:p></o:p></span></p>
  </td>
  <td width=54 colspan=3 valign=top style='width:40.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Страховой взнос по основной программе страхования<o:p></o:p></span></p>
  </td>
  <td width=73 colspan=3 valign=top style='width:54.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Страховой взнос по дополнительным программам страхования<o:p></o:p></span></p>
  </td>
  <td width=45 colspan=3 valign=top style='width:34.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Сумма к выплате<o:p></o:p></span></p>
  </td>
  <td width=57 colspan=3 valign=top style='width:43.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Дата оплаты страховых взносов, подлежащих уплате страхователя<o:p></o:p></span></p>
  </td>
 </tr>
 
  <rw:foreach id="tbl1" src="G_TABLE">
 
 <tr style='mso-yfti-irow:22'>
  <td width=56 colspan=4 valign=top style='width:42.05pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt'><b><rw:field id="" src="peril_name"/></b><o:p></o:p></span></p>
  </td>
  <td width=54 colspan=3 valign=top style='width:40.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span 
  style='font-size:6.0pt'><b><rw:field id="" src="fee_osn"/></b><o:p></o:p></span></p>
  </td>
  <td width=73 colspan=3 valign=top style='width:54.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="fee_dop"/></b><o:p></o:p></span></p>
  </td>
  <td width=45 colspan=3 valign=top style='width:34.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="viplata"/></b><o:p></o:p></span></p>
  </td>
  <td width=65 colspan=3 valign=top style='width:50.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt'><b><rw:field id="" src="date_s_z"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 
  </rw:foreach>
 
 <tr style='mso-yfti-irow:23'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
  <rw:foreach id="fi3" src="GR_POL_VIPL">
 <tr style='mso-yfti-irow:24'>
  <td width=150 colspan=4 valign=top style='width:125.9pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>Получатель выплаты:<o:p></o:p></span></p>
  </td>
  <td width=150 colspan=4 valign=top style='width:125.65pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="pol_vipl"/></b><o:p></o:p></span></p>
  </td>
  
 <td width=150 colspan=4 valign=top style='width:125.9pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>Процент доли выплаты:<o:p></o:p></span></p>
  </td>
  <td width=150 colspan=4 valign=top style='width:125.65pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="share_payment"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 <tr style='mso-yfti-irow:25'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Сумма к выплате<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:27'>
  <td width=392 colspan=10 valign=top style='width:293.95pt;border-top:none;
  border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;
  border-right:none;mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Название страхового случая<o:p></o:p></span></p>
  </td>
  <td width=246 colspan=6 valign=top style='width:184.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Сумма<o:p></o:p></span></p>
  </td>
 </tr>

 <rw:foreach id="tbl2" src="G_TABLE">
 <rw:getValue id="ITOGO" src="sum_s_v"/>
 <% p_itogo = ITOGO; %>

 
 <tr style='mso-yfti-irow:28'>
  <td width=392 colspan=10 valign=top style='width:293.95pt;border-top:none;
  border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;
  border-right:none;mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'><b><rw:field id="" src="peril_name"/></b><o:p></o:p></span></p>
  </td>
  <td width=246 colspan=6 valign=top style='width:184.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt'><b><rw:field id="" src="s_r_s"/></b><o:p></o:p></span></p>
  </td>
 </tr>
  </rw:foreach>



 
 <tr style='mso-yfti-irow:30'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись: _______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. эксперта по урегулированию убытков<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника Управления страховых выплат и экспертизы<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись: _______________________________________________________________________________</p>


<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника юридического управления<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_________________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника <span class=GramE>СБ</span><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_________________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Главного бухгалтера</span><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Управляющего директора<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Президента<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

 </rw:foreach>
</div>

</body>

</html>


</rw:report>

create or replace force view v_cr_dwh_main as
select NULL "Empty0", 
       pp.policy_id "Current Policy ID",
       pc.p_cover_id "Cover ID",       
       decode(pp.pol_ser, null, pp.pol_num, pp.pol_ser || '-' || pp.pol_num)"Policy number",
       /*  decode(pp.notice_ser,null,pp.notice_num,pp.notice_ser || '-' || pp.notice_num), */
       'ю(Текущая версия)' "Policy_version",
     --  prod.brief || '-' || pl.description "Risk name",

       ll.description "Risk name",
       -- это нужно проверить!!!
       decode(ig.life_property, 0, 'C', 1, 'L', NULL) "Policy Type ID",
       NULL "Empty1",
       decode(cn_pol_insurer.gender, 0, 'F', 1, 'M') "Sex(Insurer)",       
       NULL "Empty2",
       decode(cn_pol_holder_person.gender, 0, 'F', 1, 'M') "Sex(Policyholder)",
       pc.start_date "Date from",
       pc.end_date "Date to",
       NULL "Empty3",       
       pc.ins_amount   "Cover value",
       pc.fee          "Cover premium",
       NULL "Empty4",
       tpt.description "Pay period name",
       pc.k_coef_m "Med ep coef",       
       pc.s_coef_nm "Med em coef",
       pc.k_coef_nm "Ep non med",
       pc.s_coef_nm "Em non med",
       pca.sport_coef "I sport coef",
       pca.prof_coef "I prof coef",
       pca.k_coef_m_re "Re med ep coef",
       pca.s_coef_m_re "Re med em coef",
       pca.k_coef_nm_re "Re ep non med",
       pca.s_coef_nm_re "Re em non med",
       NULL "Re sport coef",
       NULL "Re prof coef",       
       decode(pc.is_avtoprolongation,1,'Да',0,'Нет','Нет') "Policy note",
       cn_pol_insurer.date_of_birth "Date of birth(Insurer)",
       cn_pol_holder_person.date_of_birth "Date of birth(Policyholder)",
       cn_pol_insurer.date_of_death "Date of death(Insurer)",                   
       aa.p_asset_header_id "Insurer id",
       NULL "Empty5",
       f.brief "Currency",
       NULL "Empty6",   
       NULL "Empty7",   
       NULL "Empty8",
       /*case
         when months_between(pc.end_date + 1, pc.start_date) > 12 then
          trunc(months_between(pc.end_date + 1, pc.start_date), 0) / 12
         else
          (pc.end_date - pc.start_date)
       end */
       trunc(months_between(pp.end_date + 1, ph.start_date), 0) / 12 "Insurance period",             
       NULL "Empty9",       
       pca.mort_discount "Mort discount", -- этого у нас нет
       pc.NORMRATE_VALUE  "Ii rate",       
       pc.decline_date "Date Cancel",
       NULL "Empty10", 
       NULL "Empty11",
       NULL "Empty12",
       NULL "Empty13",
       cn_pol_holder.obj_name "Policy holder",
       NULL "Empty14",
       NULL "Empty15",
       NULL "Empty16",
       NULL "Empty17",
       NULL "Empty18",
       decode(pp.is_group_flag,0,'I',1,'C','I') "Corporate policy type",
       NULL "Empty19",
       nvl(pca.reinsurer,reinsurer_contact.obj_name) "Reinsured",
       NULL "Empty20",
       NULL "Empty21",
       ph.start_date "Date orig",
       NULL "Empty22",
       NULL "Empty23",
       NULL "Empty24", 
       NULL "Empty25", 
       NULL "Empty26",
       NULL "Empty27",  
       NULL "Empty28", 
       NULL "Empty29", 
       NULL "Empty30", 
       NULL "Empty31",
       NULL "Empty32",  
       NULL "Empty33", 
       NULL "Empty34", 
       NULL "Empty35", 
       NULL "Empty36",
       NULL "Empty37",
       --!!!!!!!! заполнить
       NULL "Year com",
       NULL "Empty38",  
       NULL "Empty39", 
       NULL "Empty40", 
       NULL "Empty41", 
       NULL "Empty42",
       NULL "Empty43",  
       NULL "Empty44", 
       NULL "Empty45", 
       --!!!!!!!! заполнить
       --pkg_payment.get_charge_pcover_amount_pfa(pc.start_date, pc.end_date,pc.p_cover_id)
 
       charging.s "Charge Premium",
       NULL "Empty47",
       NULL "Empty48", 
       NULL "Empty49", 
       NULL "Empty50", 
       NULL "Empty51",
       NULL "Empty52",  
       NULL "Empty53", 
       --!!!!!!!! заполнить
       case
         when months_between(pp.end_date + 1, ph.start_date) > 12 then
          case 
             when gt.life_property = 1 then 
                'long_life'
              else 'long_ns'
           end   
         else
           case 
             when gt.life_property = 1 then
             'short_life'
             else 'short_ns'
           end
        end    "Risk type gaap", 
         
       NULL "Empty54",  
       NULL "Empty55", 
       NULL "Empty56", 
       NULL "Empty57",
       pc.rvb_value "Loading",
       NULL "Ii rate benefit",
       NULL "Benefit period name",
       NULL "Date start benefit",
       NULL "Date benefit end", 
       NULL "Benefit period",  
       NULL "Date guaranteed end",     
       NULL "Guaranteed period",       
       NULL "Date end premium",        
       NULL "Premium period",  
       NULL "Empty58",  
       NULL "Empty59", 
       NULL "Empty60", 
       NULL "Empty61",
       NULL "Empty62",  
       NULL "Empty63", 
       NULL "Empty64", 
       NULL "Empty65",
       NULL "Acquisition total",
       /*
       case tpt.is_periodical
       when 1 then
add_months(pc.start_date,decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12)*trunc(months_between(to_date('30.09.2007',
                                                        'DD.MM.YYYY'),
pc.start_date)/decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0))
       when 0 then pc.start_date
       end      "Inst start",             
       */
       case tpt.is_periodical
       when 1 then
            get_start_date_pmnt_period(pc.start_date,
                                       decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),
                                       0,
                                       trunc(months_between(to_date('30.09.2007','DD.MM.YYYY'),pc.start_date)/
                                       decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0))
       when 0 then pc.start_date
       end      "Inst start",

       /*       
       case tpt.is_periodical
       when 1 then
add_months(pc.start_date,decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12)*(trunc(months_between(to_date('30.09.2007',
                                                        'DD.MM.YYYY'),
pc.start_date)/decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0)+1))-1
       when 0 then pc.end_date
       end           "Inst end",       
       */

       case tpt.is_periodical
       when 1 then
       get_start_date_pmnt_period(pc.start_date,
                                  decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),
                                  0,
                                  (trunc(months_between(to_date('30.09.2007','DD.MM.YYYY'),pc.start_date)/
                                  decode(tpt.number_of_payments,1,12,2,6,4,3,12,1,12),0)+1)) - 1
       when 0 then pc.end_date
       end           "Inst end",
                
       nvl(av_trans.s,0) "Commission",
       pc.insured_age "actuar_age",
       pc.p_cover_id "p_cover_id",    
       pp.policy_id "p_policy_id",
       ph.policy_header_id "p_pol_header_id",   
       pc.ext_id  "risk_ext_id",
       ph.ext_id  "policy_ext_ID",
       cn_pol_insurer.obj_name "Policy insurer",
       pay_coef.pcc_val "Pay period coef",
       cr_prod.description "bank product",
       prod.description "product name"

  from p_cover pc,
       ven_as_assured aa,
       ven_p_policy pp,
       status_hist sh,
       t_prod_line_option plo,
       t_product_line pl,
       t_lob_line ll,
       t_insurance_group ig,
       t_product prod,
       ven_p_pol_header ph,
       contact cn_pol_holder,
       cn_person cn_pol_holder_person,
       ven_cn_person cn_pol_insurer,
       t_payment_terms tpt,
       fund f,
       gaap_pl_types gt,
       p_cover_add_param pca,
       contact reinsurer_contact,
       (select polc.policy_id, polc.contact_id
          from p_policy_contact polc, t_contact_pol_role pr
         where polc.contact_policy_role_id = pr.id
           and pr.brief = 'Страхователь') insurers, --страхователи по договорам страхования

       (select policy_id
          from (select max(pp.version_num) over(partition by pp.pol_header_id) m,
                       pp.policy_id,
                       pp.version_num
                  from p_policy pp
                 where doc.get_doc_status_brief(pp.policy_id, to_date('30.09.2007','DD.MM.YYYY')) not in
                                                                ('PROJECT', 'STOPED', 'BREAK', 'CANCEL'))
         where m = version_num) active_policy_on_date, --действующие на дату версии
        (select pcc.p_cover_id pcc_p_cover_id, pcc.val pcc_val
          from p_cover_coef pcc, t_prod_coef_type pct
         where pcc.t_prod_coef_type_id = pct.t_prod_coef_type_id
         --  and pcc.p_cover_id = pc.p_cover_id
           and pct.brief in('Коэффициент рассрочки платежа','Coeff_payment_loss')) pay_coef,
       ( select sum(t1.trans_amount) s, a1.p_asset_header_id,pc1.t_prod_line_option_id--, t1.trans_date
          from -- ins.ven_p_policy     pp,
               -- ins.ven_p_pol_header ph,
                p_cover pc1,
                as_asset a1,
                ven_trans t1
          where 
          --ph.start_date between :first_day and :dright
          -- and ph.policy_header_id = pp.pol_header_id(+)
           --  t.trans_date between :first_day and :dright
            a1.as_asset_id = pc1.as_asset_id
            and t1.ct_account_id = 186
            and t1.A4_ct_URO_ID = pc1.t_prod_line_option_id
            and t1.a3_ct_uro_id = a1.p_asset_header_id
            group by a1.p_asset_header_id, pc1.t_prod_line_option_id
         --   and t.trans_date between pc.start_date and pc.end_date
        ) charging, -- проводки по начислению премии
         (select prod1.description, prod1.product_id from t_product prod1 where
           prod1.brief like '%CR%') cr_prod,
         (select sum(av1.trans_amount) s, av1.p_cover_id from trans_av_dwh av1
group by av1.p_cover_id) av_trans,
(select distinct mc.reinsurer_id, rc.p_cover_id
from re_cover rc
   , re_main_contract mc
where mc.re_main_contract_id = rc.re_m_contract_id) bordero_reinsurer

 where pc.as_asset_id = aa.as_assured_id
   and aa.p_policy_id = pp.policy_id
   and pc.status_hist_id = sh.status_hist_id
      -- действующие на дату версии
   and pp.policy_id = active_policy_on_date.policy_id
      -- действующие на дату покрытия по действущим версиям
   and pc.start_date <= to_date('30.09.2007', 'DD.MM.YYYY')
   and pc.end_date > to_date('30.09.2007', 'DD.MM.YYYY')
   and sh.brief <> 'DELETED'
   and pc.t_prod_line_option_id = plo.id
   and plo.product_line_id = pl.id
   and pl.t_lob_line_id = ll.t_lob_line_id
   and ll.insurance_group_id = ig.t_insurance_group_id
   and ph.policy_header_id = pp.pol_header_id
   and prod.product_id = ph.product_id
      --and polc.contact_policy_role_id = 6
   and insurers.policy_id = pp.policy_id
   and cn_pol_holder.contact_id = insurers.contact_id
--   and pp.policy_id = 830007
   and cn_pol_insurer.contact_id = aa.assured_contact_id
   and cn_pol_holder.contact_id = cn_pol_holder_person.contact_id(+)
   and pp.payment_term_id = tpt.id
   and pay_coef.pcc_p_cover_id (+)= pc.p_cover_id
   and f.fund_id = ph.fund_id
   and charging.p_asset_header_id = aa.p_asset_header_id 
   and charging.t_prod_line_option_id  = pc.t_prod_line_option_id
   and prod.product_id = cr_prod.product_id (+)
   and gt.id (+) = pl.id    
   and pca.p_cover_id (+) = pc.p_cover_id
   and pp.is_group_flag <> 1
   and av_trans.p_cover_id (+) = pc.p_cover_id
   and bordero_reinsurer.p_cover_id (+) = pc.p_cover_id
   and bordero_reinsurer.reinsurer_id = reinsurer_contact.contact_id
;


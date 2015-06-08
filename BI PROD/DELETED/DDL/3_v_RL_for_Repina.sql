create or replace view v_RL_for_Repina as

WITH all_agent AS 
    (SELECT ach.ag_contract_header_id agent_ag_id,
            ach.agent_id agent_id,
            ach.num ad_num,
            cna.obj_name_orig agent_name,
            aca.category_name agent_category,
            dep.NAME agent_agency,
            acs.DESCRIPTION agent_sales_chanel,
            aat.ag_parent_header_id,
            CASE WHEN aca.ag_category_agent_id = 3
                 THEN CASE WHEN to_date(decode(ach.date_break, TO_DATE('31.12.2999') , NULL , ach.date_break)) IS NOT NULL
                           THEN to_date(decode(ach.date_break, TO_DATE('31.12.2999') , NULL , ach.date_break))
                      ELSE (SELECT min(ac_f.date_begin)
                              FROM ins.ag_contract ac_f
                             WHERE ac_f.contract_id = ach.ag_contract_header_id
                               AND ac_f.category_id = 2
                               AND ac_f.date_begin > to_date((SELECT r.param_value
                                                              FROM ins_dwh.rep_param r
                                                              WHERE r.rep_name = 'RL_REPINA'
                                                                AND r.param_name = 'ag_date'),'dd.mm.yyyy'))
                      END
            END mng_break
       FROM ins.ven_ag_contract_header ach,
            ins.ag_contract ac,
            ins.contact cna,
            ins.ag_category_agent aca,
            ins.department dep,
            ins.t_sales_channel acs,
            ins.ag_agent_tree aat
      WHERE ach.ag_contract_header_id = ac.contract_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'RL_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN ac.date_begin AND ac.date_end
        AND ac.category_id = aca.ag_category_agent_id
        AND ac.agency_id = dep.department_id
        AND acs.ID = ach.t_sales_channel_id
        AND cna.contact_id = ach.agent_id
        AND aat.ag_contract_header_id = ach.ag_contract_header_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'RL_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN aat.date_begin AND aat.date_end)

select num,
       epg_id,
       set_of_amt_rur, 
       case when payment_templ_title = 'Платежное поручение входящее (Прямое списание)' and pay_term = 'Ежемесячно' and first_epg = 1 then set_of_amt_rur * 2
            when payment_templ_title = 'Платежное поручение входящее (Перечислено плательщиком)' and pay_term = 'Ежемесячно' and first_epg = 1 then set_of_amt_rur * 2
            else set_of_amt_rur
            end set_of_amt_rur_everyquat,
       set_of_amt,
       set_off_date,
       set_off_rate,
       payment_templ_title,
       pay_date,
       pp_reg_date,
       pp_fund,
       doc_set_off_id,
       pd4_date,
       coll_metod,
       pol_header_id,
       first_epg,
       start_date,
       is_group_flag,
       plan_date,
       num2,
       agent_ag_id,
       ad_num agent_id,
       agent_name,
       agent_category,
       agent_agency,
       agent_sales_chanel,
       ag_mng_break,
       policy_sales_channel,
       leader_ag_ad_id,
       leader_ad_num,
       leader_name,
       leader_cat,
       leader_agency,
       leader_mng_break,
       case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
            (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
       end sign,
       case when (case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
                      (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
                 end) = 'Оплаченное заявление (первый платеж)' then 'NBV'
            when (case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
                      (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
                 end) = 'Очередные платежи 1 года' then 'NBV'
            else 'noNBV'
            end NBV,
       case when (case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
                      (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
                 end) = 'Оплаченное заявление (первый платеж)' and agent_category = 'Агент' then 'Агент' else '' end agent_new_sales,
       case when (case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
                      (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
                 end) = 'Оплаченное заявление (первый платеж)' then agent_name else '' end agmandir_new_sales,
       case when (case when first_epg = 1 then 'Оплаченное заявление (первый платеж)' else
                      (case when plan_date - start_date < 365 then 'Очередные платежи 1 года' else 'Очередные платежи 2 и последующий годы' end)
                 end) = 'Оплаченное заявление (первый платеж)' then 'Жизнь' else 'Очередные' end OPS_Life,
       case when agent_category = 'Менеджер' then agent_name else
            case when agent_category = 'Агент' and leader_cat = 'Менеджер' then leader_name else '' END
            end group_manag
FROM 
     (
 SELECT p.num,
        p.epg_id,
        p.set_of_amt_rur,
        p.set_of_amt,
        p.set_off_date,
        p.set_off_rate,
        p.payment_templ_title,
        p.pay_date,
        p.pp_reg_date,
        p.pp_fund,
        p.doc_set_off_id,
        p.pd4_date,
        p.coll_metod,
        e.pol_header_id,
        e.first_epg,
        ph.start_date,
        ph.is_group_flag,
        ph.pay_term,
        e.plan_date,
        e.num num2,
        aa.agent_ag_id,
        aa.ad_num,
        aa.agent_name,
        aa.agent_category,
        aa.agent_agency,
        aa.agent_sales_chanel,
        aa.mng_break ag_mng_break,
        sc.description policy_sales_channel,
        la.agent_ag_id leader_ag_ad_id,
        la.ad_num leader_ad_num,
        la.agent_name leader_name,
        la.agent_category leader_cat,
        la.agent_agency leader_agency,
        la.mng_break leader_mng_break
   FROM ins_dwh.fc_pay_doc         p,
        ins_dwh.t_fc_epg           e,
        ins_dwh.dm_p_pol_header    ph,
        ins_dwh.dm_t_sales_channel sc,        
        (SELECT DISTINCT pad.policy_header_id,
                         nvl(apd.ag_contract_header_id, achn.ag_contract_header_id) ag_contract_header_id
           FROM ins.p_policy_agent_doc pad,
                ins.ag_prev_dog apd,
                (SELECT * FROM ins.ven_ag_contract_header WHERE IS_new = 1) achn
          WHERE 1 = 1
            AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) !=
                'ERROR'
            AND  to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'RL_REPINA'
                            AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN pad.date_begin AND pad.date_end
            AND pad.ag_contract_header_id = apd.ag_prev_header_id(+)
            AND pad.ag_contract_header_id = achn.ag_contract_header_id(+)
            AND (achn.is_new = 1 OR achn.ag_contract_header_id IS NULL)) pad,
        all_agent aa,
        all_agent la
  WHERE nvl(p.pd4_date, p.pay_date) BETWEEN 
                                    to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'RL_REPINA'
                                      AND r.param_name = 'date_from'),'dd.mm.yyyy') and
                                      to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'RL_REPINA'
                                      AND r.param_name = 'date_to'),'dd.mm.yyyy') 
  --to_date('26.01.2011','dd.mm.yyyy')/*&p_date_begin*/ AND to_date('25.02.2011','dd.mm.yyyy')/*&P_end_date*/
    AND e.payment_id(+) = p.epg_id
    AND ph.policy_header_id = e.pol_header_id
    AND pad.policy_header_id (+) = ph.policy_header_id
    AND pad.ag_contract_header_id = aa.agent_ag_id(+)
    AND aa.ag_parent_header_id = la.agent_ag_id(+)
    AND ph.sales_channel_id = sc.ID
 ---   AND ph.ids = 2620020272
   );
   
/

GRANT SELECT ON v_RL_for_Repina TO INS_EUL;


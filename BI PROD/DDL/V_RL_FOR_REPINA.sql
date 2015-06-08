CREATE OR REPLACE VIEW V_RL_FOR_REPINA AS
WITH all_agent AS
    (SELECT ach.ag_contract_header_id agent_ag_id,
            ach.agent_id agent_id,
            ach.num ad_num,
            cna.obj_name_orig agent_name,
            aca.category_name agent_category,
            dep.NAME agent_agency,
            acs.DESCRIPTION agent_sales_chanel,
            DECODE(nvl(mat_leave.contact_id,0),0,'','Декрет') mat_lv,
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
                                                              WHERE r.rep_name = 'RL_FOR_REPINA'
                                                                AND r.param_name = 'ag_date'),'dd.mm.yyyy'))
                      END
            END mng_break
       FROM ins.ven_ag_contract_header ach,
            ins.ag_contract ac,
            ins.contact cna,
            ins.ag_category_agent aca,
            ins.department dep,
            ins.t_sales_channel acs,
            ins.ag_agent_tree aat,
            (select * from
              (select ci.contact_id, ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
                from ins.cn_contact_ident ci, ins.t_id_type it
               where ci.id_type = it.id
                 and it.brief = 'MATERNITY_LEAVE'
                 and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'RL_FOR_REPINA' and param_name = 'ag_date') between ci.issue_date and nvl(ci.termination_date,to_date('31.12.3000','dd.mm.yyyy'))
               ) lv
             where lv.rn = 1) mat_leave
      WHERE ach.ag_contract_header_id = ac.contract_id
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'RL_FOR_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN ac.date_begin AND ac.date_end
        AND ac.category_id = aca.ag_category_agent_id
        AND ac.agency_id = dep.department_id
        AND acs.ID = ach.t_sales_channel_id
        AND cna.contact_id = ach.agent_id
        AND aat.ag_contract_header_id = ach.ag_contract_header_id
        AND mat_leave.contact_id(+) = cna.contact_id
        AND acs.id NOT IN (8,10,81,16)
        AND to_date((SELECT r.param_value
                     FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'RL_FOR_REPINA'
                       AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN aat.date_begin AND aat.date_end)
-- Байтин А.
-- Заявка #151040
,nearest_agent as
 (select /*+ INDEX(cnp IX_AG_CONTRACT_01) */
         pad.policy_header_id
        ,pad.ag_contract_header_id as agent_ag_id
        ,ch.agent_id
        ,dch.num                   as ad_num
        ,co.obj_name_orig          as agent_name
        ,cat.category_name         as agent_category
        ,dep.name                  as agent_agency
        ,sc.description            as agent_sales_chanel
        ,case
           when cat.ag_category_agent_id = 3 then
             case
               when ch.date_break != to_date('31.12.2999','dd.mm.yyyy') then
                 nullif(ch.date_break, to_date('31.12.2999','dd.mm.yyyy'))
               else
                 (select min(ac_f.date_begin)
                    from ins.ag_contract ac_f
                   where ac_f.contract_id = ch.ag_contract_header_id
                     and ac_f.category_id = 2
                     and ac_f.date_begin  > pad.date_begin
                 )
             end
          end as mng_break

        ,chp.ag_contract_header_id as leader_ag_ad_id
        ,dcp.num                   as leader_ad_num
        ,cop.obj_name_orig         as leader_name
        ,cap.category_name         as leader_cat
        ,depp.name                 as leader_agency
    from ins.p_policy_agent_doc pad
        ,ins.document           dc
        ,ins.doc_status_ref     dsr

        ,ins.ag_contract_header ch
        ,ins.document           dch

        ,ins.ag_contract        cn
        ,ins.contact            co
        ,ins.ag_category_agent  cat
        ,ins.department         dep
        ,ins.t_sales_channel    sc

        -- parent
        ,ins.ag_contract_header chp
        ,ins.document           dcp
        ,ins.ag_contract        cnp
        ,ins.contact            cop
        ,ins.ag_category_agent  cap
        ,ins.department         depp
   where pad.ag_contract_header_id = ch.ag_contract_header_id
     and pad.p_policy_agent_doc_id = dc.document_id
     and dc.doc_status_ref_id      = dsr.doc_status_ref_id
     and dsr.brief                != 'ERROR'
     and ch.agent_id               = co.contact_id
     and sc.id NOT IN (8,10,81,16)
     and ch.ag_contract_header_id  = cn.contract_id
     and ch.ag_contract_header_id  = dch.document_id
     and /*pad.date_begin*/(select to_date(r.param_value,'dd.mm.yyyy')
                              from ins_dwh.rep_param r
                             where r.rep_name = 'RL_FOR_REPINA'
                               and r.param_name = 'ag_date') between cn.date_begin and cn.date_end
     and cn.category_id            = cat.ag_category_agent_id
     and cn.agency_id              = dep.department_id
     and ch.t_sales_channel_id     = sc.id
     and cn.contract_leader_id     = cnp.ag_contract_id        (+)

     and cnp.contract_id           = chp.ag_contract_header_id (+)
     and chp.ag_contract_header_id = dcp.document_id           (+)
     and chp.agent_id              = cop.contact_id            (+)
     and cnp.category_id           = cap.ag_category_agent_id  (+)
     and cnp.agency_id             = depp.department_id        (+)
     and ch.is_new                 = 1
     and pad.date_begin            = (select min(pam.date_begin)
                                        from ins.p_policy_agent_doc pam
                                            ,ins.document           dm
                                            ,ins.doc_status_ref     dsm
                                       where pam.policy_header_id      = pad.policy_header_id
                                         and pam.p_policy_agent_doc_id = dm.document_id
                                         and dm.doc_status_ref_id      = dsm.doc_status_ref_id
                                         and dsm.brief                != 'ERROR'
                                         and (select to_date(r.param_value,'dd.mm.yyyy')
                                                from ins_dwh.rep_param r
                                               where r.rep_name = 'RL_FOR_REPINA'
                                                 and r.param_name = 'ag_date') <= pam.date_end
                                     )
 )
-- V_RL_FOR_REPINA
select num,
       prod_desc,
       epg_id,
       set_of_amt_rur,
       case when payment_templ_title = 'Платежное поручение входящее (Прямое списание)' and pay_term = 'Ежемесячно' and first_epg = 1 then set_of_amt_rur * 2
            when payment_templ_title = 'Платежное поручение входящее (Перечислено плательщиком)' and pay_term = 'Ежемесячно' and first_epg = 1 then set_of_amt_rur * 2
            else (
            CASE WHEN pay_term = 'Единовременно' AND srok > 1
                 THEN set_of_amt_rur * 0.1
                 ELSE set_of_amt_rur
            END
            )
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
       nvl(agent_sales_chanel,policy_sales_channel) as policy_sales_channel,
       leader_ag_ad_id,
       leader_ad_num,
       leader_name,
       leader_cat,
       leader_agency,
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
            end group_manag,
       case when agent_category = 'Менеджер' then aa_leave else
            case when agent_category = 'Агент' and leader_cat = 'Менеджер' then la_leave else '' END
            end Group_Manag_Decret,
       NULL AG_CONTRACT_NUM,
       NULL STATUS_NAME,
       NULL OPS_IS_KV,
       leader_mng_break
      ,null as vedom_num
      ,null as version_num
      ,Nbv_koef_for_commiss
      ,null as version_status
FROM
     (
 SELECT p.num,
        ph.prod_desc,
        p.epg_id,
        p.set_of_amt_rur,
        p.set_of_amt,
        p.set_off_date,
        p.set_off_rate,
        (months_between(ph.end_date, ph.start_date + 1 )) / 12 srok,
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
        -- Байтин А.
        -- Добавил nvlы. Заявка #151040
        nvl(aa.agent_ag_id, na.agent_ag_id)               as agent_ag_id,
        nvl(aa.ad_num, na.ad_num)                         as ad_num,
        nvl(aa.agent_name, na.agent_name)                 as agent_name,
        nvl(aa.agent_category, na.agent_category)         as agent_category,
        nvl(aa.agent_agency, na.agent_agency)             as agent_agency,
        nvl(aa.agent_sales_chanel, na.agent_sales_chanel) as agent_sales_chanel,
        nvl(aa.mng_break, na.mng_break)                   as ag_mng_break,
        aa.mat_lv aa_leave,
        sc.description policy_sales_channel,
        nvl(la.agent_ag_id, na.leader_ag_ad_id)           as leader_ag_ad_id,
        nvl(la.ad_num, na.leader_ad_num)                  as leader_ad_num,
        nvl(la.agent_name, na.leader_name)                as leader_name,
        nvl(la.agent_category, na.leader_cat)             as leader_cat,
        nvl(la.agent_agency, na.leader_agency)            as leader_agency,
        la.mng_break leader_mng_break,
        la.mat_lv la_leave,
        (select SUM(tpc.val)
         from ins.t_prod_coef_type tpct,
              ins.t_prod_coef tpc
         WHERE tpct.t_prod_coef_type_id = tpc.t_prod_coef_type_id
               and tpct.brief = 'nbv_koef_for_commiss'
               and tpc.criteria_1 = e.pol_header_id) Nbv_koef_for_commiss
   FROM ins_dwh.fc_pay_doc         p,
        ins_dwh.t_fc_epg           e,
        ins_dwh.dm_p_pol_header    ph,
        ins_dwh.dm_t_sales_channel sc,
        (SELECT DISTINCT pad.policy_header_id,
                         nvl(apd.ag_contract_header_id, achn.ag_contract_header_id) ag_contract_header_id
           FROM ins.p_policy_agent_doc pad,
                ins.document           dc,
                ins.doc_status_ref     dsr,
                ins.ag_prev_dog apd,
                (SELECT * FROM ins.ven_ag_contract_header WHERE IS_new = 1) achn
          WHERE 1 = 1
            AND /*ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) !=
                'ERROR'*/
                pad.p_policy_agent_doc_id = dc.document_id
            and dc.doc_status_ref_id      = dsr.doc_status_ref_id
            and dsr.brief                != 'ERROR'
            AND  to_date((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                          WHERE r.rep_name = 'RL_FOR_REPINA'
                            AND r.param_name = 'ag_date'),'dd.mm.yyyy') BETWEEN pad.date_begin AND pad.date_end
            AND pad.ag_contract_header_id = apd.ag_prev_header_id(+)
            AND pad.ag_contract_header_id = achn.ag_contract_header_id(+)
            AND (achn.is_new = 1 OR achn.ag_contract_header_id IS NULL)) pad,
        all_agent aa,
        all_agent la
        -- Байтин А.
        -- Заявка №151040
       ,nearest_agent na
  WHERE nvl(p.pd4_date, p.pay_date) BETWEEN
                                    to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'RL_FOR_REPINA'
                                      AND r.param_name = 'date_from_rl'),'dd.mm.yyyy') and
                                      to_date((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'RL_FOR_REPINA'
                                      AND r.param_name = 'date_to_rl'),'dd.mm.yyyy')
    AND e.payment_id(+) = p.epg_id
    AND ph.policy_header_id = e.pol_header_id
    AND pad.policy_header_id (+) = ph.policy_header_id
    AND pad.ag_contract_header_id = aa.agent_ag_id(+)
    AND aa.ag_parent_header_id = la.agent_ag_id(+)
    AND ph.sales_channel_id = sc.ID
    AND sc.ID NOT IN (8,10,81,16)
    and ph.policy_header_id = na.policy_header_id (+)
   );

create or replace view v_exp_pol_header as
select  pph.policy_header_id pol_header_id,
                null ext_id,
                0 is_uploaded,
                null uploading_date,
                'update' action_type,
                c_iss.contact_id issuer_id,
                c_iss.ext_id issuer_ext_id,
                tig.ext_id insurance_type,
                trunc(pp.start_date - pp.end_date) agreement_time,
                pp.end_date,
                f.ext_id fund,
                pp.start_date begin_date,
                pp.ins_amount summ,
                sum(pc.premium) premium,-- over(partition by pp.policy_id, tig.t_insurance_group_id) premium,
                0 comission,
                c_ag.contact_id agent_id,
                c_ag.ext_id agent_ext_id,
                null notes,
                0 payed_summ,
                d.num,
                null broker_id,
                null broker_ext_id,
                0 broker_comission,
                c_b.contact_id beneficiary_id,
                c_b.ext_id beneficiary_ext_id,
                pp.sign_date agreement_date,
                decode(pp.ins_amount,
                       0,
                       0,
                       round(sum(pc.premium)/ pp.ins_amount * 100,4)) tarif,
                null deduct_value,
                null deduct_type,
                pp.decline_date stop_date,
                null blank_num,
                null blank_series,
                null region
  from document d,
       p_pol_header pph,
       p_policy pp,
       p_policy_contact ppc_iss,
       contact c_iss,
       t_contact_pol_role tcr_iss,
       as_asset aa,
       p_cover pc,
       t_prod_line_option tplo,
       t_product_line tpl,
       t_insurance_group tig,
       fund f,
       (select ppc_ag.policy_id, ppc_ag.contact_id
          from p_policy_contact ppc_ag, t_contact_pol_role tcr_ag
         where ppc_ag.contact_policy_role_id = tcr_ag.id
           and tcr_ag.description = 'Агент') ppc_ag,
       contact c_ag,
       (select ppc_b.policy_id, ppc_b.contact_id
          from p_policy_contact ppc_b, t_contact_pol_role tcr_b
         where ppc_b.contact_policy_role_id = tcr_b.id
           and tcr_b.description = 'Выгодоприобретатель') ppc_b,
       contact c_b
 where pph.policy_id = pp.policy_id
   and ppc_iss.policy_id = pp.policy_id
   and c_iss.contact_id = ppc_iss.contact_id
   and ppc_iss.contact_policy_role_id = tcr_iss.id
   and aa.p_policy_id = pp.policy_id
   and pc.as_asset_id = aa.as_asset_id
   and pc.t_prod_line_option_id = tplo.id
   and tplo.product_line_id = tpl.id
   and tpl.insurance_group_id = tig.t_insurance_group_id
   and tcr_iss.description = 'Страхователь'
   and f.fund_id = pph.fund_id
   and ppc_ag.policy_id(+) = pp.policy_id
   and c_ag.contact_id(+) = ppc_ag.contact_id
   and pp.policy_id = d.document_id
   and ppc_b.policy_id(+) = pp.policy_id
   and c_b.contact_id(+) = ppc_b.contact_id
GROUP BY pph.policy_header_id ,
                c_iss.contact_id ,
                c_iss.ext_id ,
                tig.ext_id ,
                trunc(pp.start_date - pp.end_date) ,
                pp.end_date,
                f.ext_id ,
                pp.start_date ,
                pp.ins_amount ,
                c_ag.contact_id ,
                c_ag.ext_id ,
                d.num,
                c_b.contact_id ,
                c_b.ext_id ,
                pp.sign_date ,
                pp.decline_date    

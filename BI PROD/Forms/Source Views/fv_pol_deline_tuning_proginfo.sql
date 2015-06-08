create or replace view fv_pol_deline_tuning_proginfo as
SELECT pr.product_id
      ,pfp.t_policyform_product_id
      ,pr.brief AS product_brief
      ,pr.description
      ,pf.t_policy_form_name
  FROM t_policyform_product pfp
      ,t_policy_form        pf
      ,t_product            pr
 WHERE pfp.t_policy_form_id = pf.t_policy_form_id
   AND pfp.t_product_id = pr.product_id;
	 
grant select on fv_pol_deline_tuning_proginfo to ins_read;

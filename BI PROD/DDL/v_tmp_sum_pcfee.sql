create or replace force view v_tmp_sum_pcfee as
select sum(pc.fee)as sum_pcfee, aa.P_POLICY_ID 
                             from p_cover pc, 
							 	  as_asset aa 
                            where aa.as_asset_id = pc.as_asset_id 
							  group by aa.P_POLICY_ID;


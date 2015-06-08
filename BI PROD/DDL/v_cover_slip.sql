CREATE OR REPLACE FORCE VIEW V_COVER_SLIP AS
SELECT pc.p_cover_id,
       pc.ins_amount,
       ((pc.ins_amount - Pkg_reins.get_pcover_reins_sum(pc.p_cover_id)) + abs(pc.ins_amount - Pkg_reins.get_pcover_reins_sum(pc.p_cover_id)))/2 noreins,
       pp.pol_ser,
       pp.pol_num,
       Ent.obj_name(aa.ent_id, aa.as_asset_id) asset_name,
       (SELECT COUNT(*) FROM TMP_NUM WHERE pc.p_cover_id = num) c,
       plo.description cover_name
  FROM ven_as_asset aa
     , ven_p_cover pc
     , ven_p_policy pp
     , ven_t_prod_line_option plo
     , tmp_num n
 WHERE pc.p_cover_id = n.num
   AND plo.id = pc.t_prod_line_option_id
   AND aa.as_asset_id = pc.as_asset_id 
   AND pp.policy_id = aa.p_policy_id;


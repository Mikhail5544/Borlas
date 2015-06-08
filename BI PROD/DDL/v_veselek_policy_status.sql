CREATE OR REPLACE FORCE VIEW V_VESELEK_POLICY_STATUS AS
SELECT vv.notice_num,
       vv.insurer_name,
       vv.pol_num,
       vv.status_name,
       vv.status_date,
       vv.change_date,
       vv.user_name,
       vv.sale_desc,
       vv.agency_name,
       vv.start_date,
       vv.notice_date,
       pr.description as prod,
       sum(cov.fee) as fee_sum,
       pkg_policy.get_last_version_status(vv.policy_header_id) stat
FROM v_policy_version_journal vv
     left join t_product pr on (vv.product_id = pr.product_id)
     left join as_asset ass on (ass.p_policy_id = vv.policy_id)
     left join p_cover cov on (cov.as_asset_id = ass.as_asset_id)
WHERE policy_id = active_policy_id
      and vv.status_name like '%'
      --and vv.policy_id = 782785
group by vv.notice_num,
         vv.insurer_name,
         vv.pol_num,
         vv.status_name,
         vv.status_date,
         vv.change_date,
         vv.user_name,
         vv.sale_desc,
         vv.agency_name,
         vv.start_date,
         vv.notice_date,
         pr.description,
         pkg_policy.get_last_version_status(vv.policy_header_id)
;


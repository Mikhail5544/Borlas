create or replace force view v_indexating_fee as
select p2.pol_header_id,
       sum(pc.fee) indexating_fee --суммируем если несколько засрахованных
  from p_policy    p2,
       as_asset    aa,
       status_hist sha,
       p_cover     pc,
       status_hist shp
 where 1 = 1
   and p2.version_num =
       (select max(p3.version_num)
          from p_policy p3
         where p3.pol_header_id = p2.pol_header_id
           and doc.get_doc_status_brief(p3.policy_id) = 'INDEXATING')
   and aa.p_policy_id = p2.policy_id
   and sha.status_hist_id = aa.status_hist_id
   and sha.brief <> 'DELETED'
   and pc.as_asset_id = aa.as_asset_id
   and shp.status_hist_id = pc.status_hist_id
   and shp.brief <> 'DELETED'
group by p2.pol_header_id
;


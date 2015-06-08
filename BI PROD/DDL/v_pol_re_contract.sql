CREATE OR REPLACE FORCE VIEW V_POL_RE_CONTRACT AS
SELECT tp.description,
       pi.contact_name,
       pa.contact_name agent_name,
       pp.policy_id,
       pp.pol_ser,
       pp.pol_num,
       pp.start_date,
       pp.end_date,
       pph.fund_id,
       (SELECT COUNT(1)
          FROM AS_ASSET aa, P_COVER pc, TMP_NUM tn
         WHERE aa.p_policy_id = pp.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND tn.num = pc.p_cover_id) c
  FROM p_policy pp,
       p_pol_header pph,
       v_pol_issuer pi,
       v_pol_agent pa,
       t_product tp
 WHERE pp.pol_header_id = pph.policy_header_id
   AND Doc.get_doc_status_brief(pp.policy_id) NOT IN ('PROJECT','STOPED', 'CLOSE', 'CANCEL')
   AND pi.policy_id = pp.policy_id
   AND tp.product_id = pph.product_id
   AND pa.policy_id(+) = pp.policy_id;


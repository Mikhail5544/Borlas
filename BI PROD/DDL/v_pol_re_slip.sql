CREATE OR REPLACE FORCE VIEW V_POL_RE_SLIP AS
SELECT tp.description,
       pp.pol_ser,
       pp.pol_num,
       pi.contact_name,
       pa.contact_name agent_name,
       pp.start_date,
       pp.end_date,
       (SELECT COUNT(*)
          FROM AS_ASSET aa, P_COVER pc, TMP_NUM tn
         WHERE aa.p_policy_id = pp.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND tn.num = pc.p_cover_id) c,
       mp.re_slip_id, pp.policy_id
  FROM p_policy pp,
       p_pol_header ph,
       v_pol_issuer pi,
       v_pol_agent pa,
       ven_t_product tp,
       re_slip_header rsh,
       (SELECT pp.pol_header_id,
               MAX(pp.version_num) version_num,
               rs.re_slip_id, rs.re_slip_header_id
          FROM ven_re_slip rs, ven_p_policy pp
         WHERE pp.start_date <= rs.start_date
           AND pp.end_date >= rs.end_date
           AND Doc.get_doc_status_brief(pp.policy_id) = 'CURRENT'
         GROUP BY pp.pol_header_id, rs.re_slip_id, rs.re_slip_header_id) mp
 WHERE pp.pol_header_id = mp.pol_header_id
   AND pp.version_num = mp.version_num
   AND ph.policy_header_id = pp.pol_header_id
   AND pi.policy_id = pp.policy_id
   AND tp.product_id = ph.product_id
   AND pa.policy_id(+) = pp.policy_id
   AND mp.re_slip_header_id = rsh.re_slip_header_id
   AND rsh.fund_id = ph.fund_id;


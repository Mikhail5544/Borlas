CREATE MATERIALIZED VIEW INS_DWH.MV_PAY_CAH_RISK
REFRESH FORCE ON DEMAND
AS
SELECT b.ph_id,
       b.plo_id,
       a.*
  FROM (SELECT distinct
               pp.pol_header_id          ph_id,
               pc.t_prod_line_option_id  plo_id
          FROM ins.p_policy pp,
               ins.P_COVER  PC,
               ins.AS_ASSET ASS
         WHERE ASS.P_POLICY_ID = pp.POLICY_ID
           AND PC.AS_ASSET_ID = ASS.AS_ASSET_ID
           and pp.pol_header_id in (SELECT nvl(cah.pol_header_id, pay.ph) phid
                                      FROM ins_dwh.mv_charges cah
                                           FULL OUTER JOIN
                                           ins_dwh.mv_payments pay ON (pay.ph = cah.pol_header_id AND pay.plo = cah.tplo)
                                   )
       ) b,
       (SELECT nvl(cah.pol_header_id, pay.ph) phid,
               nvl(cah.tplo, pay.plo)         ploid,
               cah.*,
               pay.*
          FROM ins_dwh.mv_charges cah
               FULL OUTER JOIN
               ins_dwh.mv_payments pay ON (pay.ph = cah.pol_header_id AND pay.plo = cah.tplo)
       )a
WHERE b.ph_id  = a.phid  (+)
  AND b.plo_id = a.ploid (+)
  --and b.ph_id  in (621177,6008119, 664942,8711500,8742760)
  --ѕо 8742760 должно быть 4 риска, а по 621177 не должно задваиватьс€!!

UNION ALL

SELECT b.ph_id,
       b.plo_id,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,     null,null,null,null,null,null,null,null,null,null
  FROM (SELECT distinct
               pp.pol_header_id          ph_id,
               pc.t_prod_line_option_id  plo_id
          FROM ins.p_policy pp,
               ins.P_COVER  PC,
               ins.AS_ASSET ASS
         WHERE ASS.P_POLICY_ID = pp.POLICY_ID
           AND PC.AS_ASSET_ID = ASS.AS_ASSET_ID
       ) b,
      (SELECT distinct ph_id  phid,
              null            ploid
         FROM (SELECT ph.policy_header_id ph_id
                 FROM ins.p_policy p,
                      ins.p_pol_header ph,
                      ins.doc_status ds
                WHERE p.pol_header_id = ph.policy_header_id
                  and ds.document_id = p.policy_id
                  AND ds.change_date BETWEEN '01.01.2010' and '31.12.2010'
                  AND nvl(p.is_group_flag,0) = 0
               MINUS
                SELECT cah.pol_header_id ph_id FROM ins_dwh.mv_charges cah
               MINUS
                SELECT pay.ph            ph_id FROM ins_dwh.mv_payments pay
              )
       )a
WHERE b.ph_id  = a.phid;


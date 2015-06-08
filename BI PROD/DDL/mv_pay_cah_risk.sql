create materialized view MV_PAY_CAH_RISK
refresh force on demand
as
select b.ph_id,
       b.plo_id,
       a.*
  FROM (select distinct
               pp.pol_header_id          ph_id,
               pc.t_prod_line_option_id  plo_id
          from p_policy pp,
               P_COVER  PC,
               AS_ASSET ASS
        where  ASS.P_POLICY_ID = pp.POLICY_ID
           AND PC.AS_ASSET_ID = ASS.AS_ASSET_ID
           and pp.pol_header_id in (select nvl(cah.pol_header_id, pay.ph) phid
                                      from mv_charges cah
                                           FULL OUTER JOIN
                                           mv_payments pay ON (pay.ph = cah.pol_header_id AND pay.plo = cah.tplo)
                                   )
       ) b,
       (select nvl(cah.pol_header_id, pay.ph) phid,
               nvl(cah.tplo, pay.plo)         ploid,
               cah.*,
               pay.*
          from mv_charges cah
               FULL OUTER JOIN
               mv_payments pay ON (pay.ph = cah.pol_header_id AND pay.plo = cah.tplo)
       )a
where b.ph_id  = a.phid  (+)
  and b.plo_id = a.ploid (+)
  --and b.ph_id  in (621177,6008119, 664942,8711500,8742760)
  --ѕо 8742760 должно быть 4 риска, а по 621177 не должно задваиватьс€!!

UNION ALL

select b.ph_id,
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
  FROM (select distinct
               pp.pol_header_id          ph_id,
               pc.t_prod_line_option_id  plo_id
          from p_policy pp,
               P_COVER  PC,
               AS_ASSET ASS
        where  ASS.P_POLICY_ID = pp.POLICY_ID
           AND PC.AS_ASSET_ID = ASS.AS_ASSET_ID
       ) b,
      (select distinct ph_id  phid,
              null            ploid
         from (select ph.policy_header_id        ph_id
                 from p_policy p,
                      p_pol_header ph,
                      doc_status ds
                where p.pol_header_id = ph.policy_header_id
                  and ds.document_id = p.policy_id
                  and ds.change_date between '01.01.2010' and '31.05.2010'
                  AND nvl(p.is_group_flag,0) = 0
                minus
                select cah.pol_header_id ph_id from mv_charges cah
                minus
                select pay.ph            ph_id from mv_payments pay
              )
       )a
where b.ph_id  = a.phid;


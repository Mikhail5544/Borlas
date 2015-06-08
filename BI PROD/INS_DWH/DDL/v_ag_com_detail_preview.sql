CREATE OR REPLACE FORCE VIEW INS_DWH.V_AG_COM_DETAIL_PREVIEW AS
WITH
   agents_vol AS --В расчет какой ведомости, кому вошли какие объемы
   (SELECT apv.ag_volume_id,
           arh.date_begin,
--           arh.ag_roll_header_id,
           SUM(DECODE(ac.category_id, 2, apv.VOL_AMOUNT*apv.VOL_RATE, NULL)) ag_prem,
           SUM(DECODE(ac.category_id, 3, apv.VOL_AMOUNT*apv.VOL_RATE, NULL)) mng_prem,
           SUM(DECODE(ac.category_id, 4, apv.VOL_AMOUNT*apv.VOL_RATE, 20, apv.VOL_AMOUNT*apv.VOL_RATE, NULL)) dir_prem,
           SUM(DECODE(ac.category_id, 50, apv.VOL_AMOUNT*apv.VOL_RATE, 55, apv.VOL_AMOUNT*apv.VOL_RATE, NULL)) tdir_prem,
           MAX(DECODE(ac.category_id, 2, apw.ag_contract_header_id, NULL)) ag,
           MAX(DECODE(ac.category_id, 3, apw.ag_contract_header_id, NULL)) mng,
           MAX(DECODE(ac.category_id, 4, apw.ag_contract_header_id, 20, apw.ag_contract_header_id, NULL)) dir,
           MAX(DECODE(ac.category_id, 50, apw.ag_contract_header_id, 55, apw.ag_contract_header_id, NULL)) tdir
      FROM ins.ven_ag_roll_header   arh,
           ins.ag_roll              ar,
           ins.ag_perfomed_work_act apw,
           ins.ag_contract          ac,
           ins.ag_perfom_work_det   apd,
           ins.ag_perf_work_vol     apv
     WHERE 1 = 1
       --AND arh.num IN ('000233','000234')
       AND ar.ag_roll_header_id = arh.ag_roll_header_id
       AND ar.ag_roll_id = apw.ag_roll_id
       AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
       AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
       AND ac.contract_id = apw.ag_contract_header_id
       AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
     GROUP BY apv.ag_volume_id,
              arh.date_begin),

    agents_prem AS --Информация по вознаграждениям и агентам
      (SELECT arh.date_begin,
              --arh.ag_roll_header_id,
              apw.ag_contract_header_id,
              SUM(apd.summ) prem_amt,
              dep.NAME agency_name,
              cn.obj_name_orig ag_name,
              aca.category_name,
              ac.category_id
         FROM ins.ven_ag_roll_header arh,
              ins.ag_roll_type art,
              ins.ag_roll ar,
              ins.ag_perfomed_work_act apw,
              ins.ag_perfom_work_det apd,
              ins.ag_contract_header ach,
              ins.contact cn,
              ins.department dep,
              ins.ag_contract ac,
              ins.ag_category_agent aca
        WHERE arh.ag_roll_header_id =ar.ag_roll_header_id
          AND ar.ag_roll_id = apw.ag_roll_id
         -- AND arh.num IN ('000233','000234')
          AND arh.ag_roll_type_id = art.ag_roll_type_id
          AND art.BRIEF IN ('OAV_0510','MnD_PREM')
          AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
          AND apw.ag_contract_header_id = ach.ag_contract_header_id
          AND ach.ag_contract_header_id = ac.contract_id
          AND ach.agent_id = cn.contact_id
          AND ac.category_id = aca.ag_category_agent_id
          AND dep.department_id = ac.agency_id
          AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
        GROUP BY arh.date_begin,apw.ag_contract_header_id,dep.NAME,cn.obj_name_orig,aca.category_name,ac.category_id)

SELECT agv.date_begin calc_per,
       arh.date_begin vol_per,
       av.ag_volume_id,
       avt.DESCRIPTION vol_type,
       coalesce(to_char(ph.Ids), anv.snils) pol_num,
       /*Пока так*/
       decode(NVL(av.Index_Delta_Sum,0),0, av.trans_sum,av.Index_Delta_Sum)*nvl(av.nbv_coef,0) nbv,
       decode(NVL(av.Index_Delta_Sum,0),0, av.trans_sum,av.Index_Delta_Sum) prem,

 /*Агент*/
       apa.ag_name "AGENT",


       (apa.agency_name) agency,
       (apa.category_name) "CATEGORY",
       (agv.ag_prem) prem_by_vol,
       (apa.prem_amt) prem_amt,
       /*Менеджер*/
       (apm.ag_name) manager,
       (apm.agency_name) mng_agency,
       (apm.category_name) mng_category,
       (agv.mng_prem) mng_prem_by_vol,
       (apm.prem_amt) mng_prem_amt,
       /*Директор*/
       (apd.ag_name) Director,
       (apd.agency_name) dir_agency,
       (apd.category_name) dir_category,
       (agv.dir_prem) dir_prem_by_vol,
       (apd.prem_amt) dir_prem_amt,
       /*Тер/регион директор*/
       (aptd.ag_name) Regional_dir,
       (aptd.agency_name) td_agency,
       (aptd.category_name) td_category,
       (agv.tdir_prem) td_prem_by_vol,
       (aptd.prem_amt) td_prem_amt,

       av.trans_sum Total_Volume,
       decode(nvl(av.nbv_coef,0), 0, 0, 1)  IS_NBV,
        --Чирков 154367 Доработка факта агентская коммиссия детали
       (select
          ins.ent.obj_name(cn_a.ent_id, cn_a.contact_id)
       from
          ins.ag_contract_header ach_s,
          ins.contact cn_a
       where
          ach_s.ag_contract_header_id = AV.AG_CONTRACT_HEADER_ID
          AND cn_a.contact_id = ach_s.agent_id
          and rownum = 1
        ) "AGENT_MANAGERA", --end_Чирков 154367 Доработка факта агентская коммиссия детали
        av.pay_period,
        /*197655*/
       decode(NVL(av.Index_Delta_Sum,0),0, av.trans_sum,av.Index_Delta_Sum) *
       (CASE WHEN (SELECT COUNT(*)
                    FROM ins.t_product prod
                    WHERE ph.product_id = prod.product_id
                      AND prod.brief IN ('INVESTOR_LUMP','INVESTOR_LUMP_OLD')
                    ) > 0 AND av.ins_period = 3 AND (SELECT COUNT(*)
                                                     FROM ins.ag_contract ag
                                                     WHERE ag.contract_id = apm.ag_contract_header_id
                                                       AND ag.category_id = 50
                                                       AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                                                     ) = 0
               THEN 0.3
               WHEN (SELECT COUNT(*)
                    FROM ins.t_product prod
                    WHERE ph.product_id = prod.product_id
                      AND prod.brief IN ('INVESTOR_LUMP','INVESTOR_LUMP_OLD')
                    ) > 0 AND av.ins_period = 5 AND (SELECT COUNT(*)
                                                     FROM ins.ag_contract ag
                                                     WHERE ag.contract_id = apm.ag_contract_header_id
                                                       AND ag.category_id = 50
                                                       AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                                                     ) = 0
               THEN 0.2
               ELSE NVL(av.nbv_coef,0)
           END
        ) mng_nbv,
        decode(NVL(av.Index_Delta_Sum,0),0, av.trans_sum,av.Index_Delta_Sum) *
       (CASE WHEN (SELECT COUNT(*)
                    FROM ins.t_product prod
                    WHERE ph.product_id = prod.product_id
                      AND prod.brief IN ('INVESTOR_LUMP','INVESTOR_LUMP_OLD')
                    ) > 0 AND av.ins_period = 3 AND (SELECT COUNT(*)
                                                     FROM ins.ag_contract ag
                                                     WHERE ag.contract_id = apm.ag_contract_header_id
                                                       AND ag.category_id = 50
                                                       AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                                                     ) = 0
               THEN 0.3
               WHEN (SELECT COUNT(*)
                    FROM ins.t_product prod
                    WHERE ph.product_id = prod.product_id
                      AND prod.brief IN ('INVESTOR_LUMP','INVESTOR_LUMP_OLD')
                    ) > 0 AND av.ins_period = 5 AND (SELECT COUNT(*)
                                                     FROM ins.ag_contract ag
                                                     WHERE ag.contract_id = apm.ag_contract_header_id
                                                       AND ag.category_id = 50
                                                       AND arh.date_end BETWEEN ag.date_begin AND ag.date_end
                                                     ) = 0
               THEN 0.2
               ELSE NVL(av.nbv_coef,0)
           END
        ) dir_nbv
  FROM ins.ven_ag_roll_header arh,
       ins.ag_roll ar,
       ins.ag_volume av,
       ins.ag_volume_type avt,
       ins.ag_npf_volume_det anv,
       ins.p_pol_header ph,
       agents_vol agv,
       (SELECT * FROM agents_prem a WHERE a.category_id = 2) apa,
       (SELECT * FROM agents_prem a WHERE a.category_id = 3) apm,
       (SELECT * FROM agents_prem a WHERE a.category_id IN (20,4)) apd,
       (SELECT * FROM agents_prem a WHERE a.category_id IN (55,50)) aptd
 WHERE arh.ag_roll_header_id = ar.ag_roll_header_id
   AND ar.ag_roll_id  = av.ag_roll_id
   AND av.ag_volume_type_id = avt.ag_volume_type_id
   AND av.ag_volume_id = anv.ag_volume_id (+)
   AND av.policy_header_id = ph.policy_header_id (+)
   AND av.ag_volume_id  = agv.ag_volume_id
   AND apa.ag_contract_header_id (+) = agv.ag
   AND apa.date_begin (+) = agv.date_begin
   AND apm.ag_contract_header_id (+) = agv.mng
   AND apm.date_begin (+) = agv.date_begin
   AND apd.ag_contract_header_id (+) = agv.dir
   AND apd.date_begin (+) = agv.date_begin
   AND aptd.ag_contract_header_id (+) = agv.tdir
   AND aptd.date_begin (+) = agv.date_begin
;


CREATE OR REPLACE VIEW INS.V_ROLL_PAY_DETAIL AS
SELECT aph.num arh_num,
       aph.company company_name,
       art.name art_name,
       agh.num||'/'||(SELECT c.obj_name_orig FROM contact c WHERE arpd.contact_id = c.contact_id) name_agent,
       agh.ag_contract_header_id,
       arpd.ag_perfomed_work_act_id,
       aph.date_begin,
       aph.date_end,
       SUM(arpd.prem_sum) prem_sum,
       NVL(arpd.other_prem_sum,0) other_prem_sum,
       arpd.to_pay_bank,
       arpd.to_pay_amount,
       arpd.to_pay_props,
       arh.ag_roll_header_id,
       arpd.state_detail,
       arpd.ag_roll_pay_header_id/*,
       arpd.vol_type_id*/
FROM ins.ag_roll_pay_detail arpd,
     ins.ven_ag_roll_pay_header aph,
     ins.ag_roll_header arh,
     ins.ag_roll ar,
     ins.ag_roll_type art,
     ins.ven_ag_contract_header agh
WHERE arpd.ag_roll_pay_header_id = aph.ag_roll_pay_header_id
  AND arpd.ag_roll_id = ar.ag_roll_id
  AND ar.ag_roll_header_id = arh.ag_roll_header_id
  AND arh.ag_roll_type_id = art.ag_roll_type_id
  AND arpd.ag_contract_header_id = agh.ag_contract_header_id
  /*AND agh.num = '10047'*/
GROUP BY aph.num,
       aph.company,
       agh.num,
       agh.ag_contract_header_id,
       arpd.contact_id,
       arpd.ag_perfomed_work_act_id,
       arpd.to_pay_bank,
       arpd.to_pay_amount,
       arpd.to_pay_props,
       arh.ag_roll_header_id,
       arpd.state_detail,
       arpd.ag_roll_pay_header_id,
       /*arpd.vol_type_id,*/
       aph.date_begin,
       aph.date_end,
       art.name,
       arpd.other_prem_sum;
grant select on INS.V_ROLL_PAY_DETAIL to INS_READ;
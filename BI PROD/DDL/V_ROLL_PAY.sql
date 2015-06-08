CREATE OR REPLACE VIEW INS.V_ROLL_PAY AS
SELECT agh.ag_contract_header_id,
       agh.num||'/'||(SELECT c.obj_name_orig FROM contact c WHERE arpd.contact_id = c.contact_id) name_agent,
       arpd.contact_id,
       tct.description leg_pos,
       (SELECT NVL(SUM(ad.prem_sum),0)
        FROM ins.ag_roll_pay_detail ad
        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
          AND ad.vol_type_brief IN ('RL','FDep','INV')
        ) + arpd.other_prem_sum amount_rl,
        (SELECT NVL(SUM(ad.prem_sum),0)
        FROM ins.ag_roll_pay_detail ad
        WHERE ad.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
          AND ad.ag_contract_header_id = arpd.ag_contract_header_id
          AND ad.vol_type_brief IN ('NPF','NPF02','NPF(MARK9)')
        ) amount_npf,
       (SELECT NVL(SUM(d.prem_sum + d.other_prem_sum),0)
        FROM ins.V_ROLL_PAY_DETAIL d
        WHERE d.ag_contract_header_id = agh.ag_contract_header_id
          AND d.state_detail IN (1,2)
          AND d.ag_roll_pay_header_id = arpd.ag_roll_pay_header_id
       ) amount_to_pay,
       SUM(NVL(arpd.amount_payed,0)) amount_payed,
       SUM(NVL(arpd.amount_ndfl,0)) amount_ndfl,
       SUM(NVL(arpd.amount_esn,0)) amount_esn,
       arpd.ag_roll_pay_header_id,
       arph.ag_roll_header_id,
       cat.category_name
FROM ins.ag_roll_pay_detail arpd,
     ins.ven_ag_contract_header agh,
     ins.t_contact_type tct,
     ins.ag_roll_pay_header arph,
     ins.ag_category_agent cat
WHERE arpd.ag_contract_header_id = agh.ag_contract_header_id
  AND arpd.contact_type_id = tct.id
  AND arpd.ag_roll_pay_header_id = arph.ag_roll_pay_header_id
  AND cat.ag_category_agent_id = arpd.ag_category_agent_id
GROUP BY agh.ag_contract_header_id,
         agh.num,
         arpd.contact_id,
         tct.description,
         arpd.ag_roll_pay_header_id,
         arpd.ag_contract_header_id,
         arph.ag_roll_header_id,
         arpd.other_prem_sum,
         cat.category_name;
grant select on INS.V_ROLL_PAY to INS_READ;
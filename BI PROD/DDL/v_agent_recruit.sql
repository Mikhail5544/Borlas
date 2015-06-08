CREATE OR REPLACE VIEW v_agent_recruit AS
SELECT agh.num num_agent,
       c.obj_name_orig name_agent,
       ch.description sales_ch,
       NVL(aghl.num,'-') num_recruit,
       NVL(cl.obj_name_orig,'-') name_recruit,
       agh.agent_id agent_id,
       aghl.agent_id recruit_id
FROM ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.t_sales_channel ch,
     ins.ag_contract ag,
     ins.ag_contract agl,
     ins.ven_ag_contract_header aghl,
     ins.contact cl
WHERE agh.last_ver_id = ag.ag_contract_id
  AND agh.agent_id = c.contact_id
  AND agh.t_sales_channel_id = ch.id
  AND ag.contract_recrut_id = agl.ag_contract_id(+)
  AND agl.contract_id = aghl.ag_contract_header_id(+)
  AND aghl.agent_id = cl.contact_id(+);
  
GRANT SELECT ON v_agent_recruit TO INS_EUL;
GRANT SELECT ON v_agent_recruit TO INS_READ;

create or replace view v_bso_under_agent_broker as
select bh.bso_id,
       bb.num as bso,
       tt.name as type_bso,
       t.name as stat,
       c.contact_id,
       c.obj_name_orig as fio,
       nvl(agh.num,'-') num,
       nvl(dep.name,'-') name,
       NVL(ch.description,'-') sales_ch,
       NVL(aghl.num,'-') num_recruit,
       NVL(cl.obj_name_orig,'-') name_recruit
from ins.contact c,
     ins.bso_hist bh,
     ins.bso bb,
     ins.bso_hist_type t,
     ins.bso_series s,
     ins.bso_type tt,
     ins.ven_ag_contract_header agh,
     ins.department dep,
     ins.t_sales_channel ch,
     ins.ag_contract ag,
     ins.ag_contract agl,
     ins.ven_ag_contract_header aghl,
     ins.contact cl
WHERE bh.contact_id = c.contact_id
  AND bb.bso_hist_id = bh.bso_hist_id
  AND bh.hist_type_id = t.bso_hist_type_id
  AND s.bso_series_id = bb.bso_series_id
  AND tt.bso_type_id = s.bso_type_id
  AND agh.agent_id(+) = c.contact_id
  AND dep.department_id(+) = bh.department_id
  AND agh.t_sales_channel_id = ch.id(+)
  AND agh.last_ver_id = ag.ag_contract_id(+)
  AND ag.contract_recrut_id = agl.ag_contract_id(+)
  AND agl.contract_id = aghl.ag_contract_header_id(+)
  AND aghl.agent_id = cl.contact_id(+);
     
GRANT SELECT ON v_bso_under_agent_broker TO INS_EUL;
GRANT SELECT ON v_bso_under_agent_broker TO INS_READ;

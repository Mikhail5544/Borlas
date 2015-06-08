create or replace view v_bso_under_agent as
select bh.bso_id,
       bb.num as bso,
       s.series_num as series_num,
       tt.name as type_bso,
       t.name as stat,
       c.contact_id,
--       c.name||' '||c.first_name||' '||c.middle_name as fio,
       c.obj_name_orig as fio,
       dd.num,
       nvl(dep.name,'-') name
from contact c
     inner join bso_hist bh on (bh.contact_id = c.contact_id)
     inner join bso bb on (bb.bso_hist_id = bh.bso_hist_id)
     inner join bso_hist_type t on (bh.hist_type_id = t.bso_hist_type_id)
     inner join bso_series s on (s.bso_series_id = bb.bso_series_id)
     inner join bso_type tt on (tt.bso_type_id = s.bso_type_id)
     left join ag_contract_header ag on (ag.agent_id = c.contact_id)
     left join department dep on (dep.department_id = bh.department_id)
     left join document dd on (dd.document_id = ag.ag_contract_header_id)
--where dd.num = '000005'
     --where bb.num like '074224';
;

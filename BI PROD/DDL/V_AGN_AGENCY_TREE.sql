CREATE OR REPLACE VIEW V_AGN_AGENCY_TREE AS
SELECT (ca.category_name || ': ' || cn.obj_name_orig) NAME,
       ach.ag_contract_header_id id,
       (CASE
         WHEN aat.ag_parent_header_id IS NULL
              OR ac_lead.agency_id <> ac.agency_id
         THEN
          TO_NUMBER('-'||ts.id||ach.agency_id)
         ELSE
          aat.ag_parent_header_id
       END) parent_id,
       aat.Is_Leaf,
       ac.date_begin ac_date_begin,
       ac.date_end ac_date_end,
       aat.date_begin atree_date_begin,
       aat.date_end atree_date_end
  FROM ag_contract_header ach,
       ag_contract ac,
       ag_contract ac_lead,
       ag_agent_tree aat,
       t_sales_channel ts,
       ag_category_agent  ca,
       contact                cn
 WHERE 1=1
   AND ac.contract_leader_id = ac_lead.ag_contract_id (+)
   AND ach.ag_contract_header_id = aat.ag_contract_header_id
   AND ca.ag_category_agent_id = ac.category_id
   AND ach.ag_contract_header_id = ac.contract_id
   AND cn.contact_id = ach.agent_id
   AND ts.ID = ach.t_sales_channel_id
UNION ALL
SELECT ts.description name,
       ts.id*-1 id,
       -1 parent_id,
       0,
       TO_DATE('01.01.1999'),
       TO_DATE('31.12.2999'),
       TO_DATE('01.01.1999'),
       TO_DATE('31.12.2999')
  FROM t_sales_channel ts
 where ts.brief in ('SAS','SAS 2','MLM','GRSMoscow','GRSRegion','CC','CORPORATE','GRS-TSOK','RLA','BR','BR_WDISC','BANK')
UNION ALL
SELECT dep.NAME NAME,
       TO_NUMBER('-' || ts.id || dep.department_id) id,
       ts.ID * -1 parent_id,
       0,
       TO_DATE('01.01.1999'),
       TO_DATE('31.12.2999'),
       TO_DATE('01.01.1999'),
       TO_DATE('31.12.2999')
  FROM Organisation_Tree ot,
       department        dep,
       t_sales_channel   ts
 WHERE dep.Org_Tree_Id = ot.organisation_tree_id
   AND ot.parent_id IS NOT NULL
   AND EXISTS (SELECT NULL
                  FROM ag_contract ac,
                       ag_contract_header ach
                 WHERE ac.contract_id = ach.ag_contract_header_id
                   AND ach.Is_New = 1
                   AND ach.t_sales_channel_id = ts.ID
                   AND ac.agency_id = dep.department_id)
with read only;

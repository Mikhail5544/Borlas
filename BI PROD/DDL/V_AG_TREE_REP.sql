CREATE OR REPLACE VIEW V_AG_TREE_REP AS
SELECT ach.num                                                       ag_num
      ,cn.obj_name_orig                                              agent_name
      ,(SELECT ach0.num
          FROM  ven_ag_contract_header ach0
         WHERE ach0.ag_contract_header_id = aat.ag_parent_header_id) ag_man_num
      ,(SELECT ent.obj_name('CONTACT',ach3.agent_id)
          FROM ag_contract_header ach3
         WHERE ach3.ag_contract_header_id = aat.ag_parent_header_id) manager_name
      ,dep.name                                                      department
      ,aat.date_begin
      ,aat.date_end                                                      
 --     ,aat.date_begin
  FROM ins.ag_contract            ac
      ,ins.department             dep
      ,ins.organisation_tree      ot     --Организационная структура
      ,ins.sales_dept_header      sdh    --Продающее подразделение (заголовок)
      ,ins.ven_ag_contract_header ach    --Заголовок агентского договора
      ,ins.contact                cn     --на ФИО агента
      ,ins.ag_agent_tree          aat    --Структура подчинения агентов
 WHERE dep.department_id          = ac.agency_id
   AND ot.organisation_tree_id    = dep.org_tree_id
   AND sdh.organisation_tree_id   = ot.organisation_tree_id
   AND ach.last_ver_id            = ac.ag_contract_id
   AND cn.contact_id              = ach.agent_id
   AND aat.date_end >             sysdate
   AND aat.ag_contract_header_id  = ach.ag_contract_header_id
/*   AND (SELECT to_date((r.param_value),'dd.mm.yyyy')
                         FROM ins_dwh.rep_param r
                        WHERE r.rep_name   = 'V_AG_TREE_REP'
                          AND r.param_name = 'date_begin')
       between aat.date_begin AND aat.date_end;*/
--c
     AND aat.date_end >= (SELECT to_date((r.param_value),'dd.mm.yyyy')
                            FROM ins_dwh.rep_param r
                           WHERE r.rep_name   = 'V_AG_TREE_REP'
                             AND r.param_name = 'date_start')

--по       
     AND aat.date_begin <= (SELECT to_date((r.param_value),'dd.mm.yyyy')
                              FROM ins_dwh.rep_param r
                             WHERE r.rep_name   = 'V_AG_TREE_REP'
                               AND r.param_name = 'date_end');


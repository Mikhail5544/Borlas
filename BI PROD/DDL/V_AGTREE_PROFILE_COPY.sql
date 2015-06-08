CREATE OR REPLACE VIEW V_AGTREE_PROFILE_COPY AS
SELECT
       doc.get_doc_status_name(ac.contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) AD_stat,
       doc.get_doc_status_name(ac.ag_contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) ADds_stat,
       (select doc.get_doc_status_name(agd.ag_documents_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
        from ins.ag_documents agd,
             ins.ag_doc_type dt
        where agd.ag_contract_header_id = ach.ag_contract_header_id
              and agd.ag_doc_type_id = dt.ag_doc_type_id
              and dt.brief = 'NEW_AD'
              and rownum = 1) ag_doc_stat,
        sc.description sales_channel,
        ach.date_begin date_begin_ad,
        (select max(agd.doc_date)
        from ins.ag_documents agd,
             ins.ag_doc_type dt
        where agd.ag_contract_header_id = ach.ag_contract_header_id
              and agd.ag_doc_type_id = dt.ag_doc_type_id
              and dt.brief = 'BREAK_AD'
              and doc.get_doc_status_name(agd.ag_documents_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) = 'Подтвержден'
              ) date_term_ad,
        pkg_renlife_utils.get_ag_stat_brief(ac.contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) agent_stat,
       (SELECT num FROM ven_ag_contract_header v WHERE v.ag_contract_header_id = ac.contract_id) num_agent_ad,
       ac.contract_id   id_ad,
       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.ag_contract_id) agent_fio,
       DECODE(nvl(mat_leave.contact_id,0),0,'','Декрет') agent_decret,
       (select cat.category_name from ag_category_agent cat where cat.ag_category_agent_id = ac.category_id) agent_cat,
       (select tct.description
        from t_contact_type tct
        where tct.id = (select decode(nvl(aghl.is_new,0),0,decode(acl.leg_pos,0,1,1,1030),1,acl.leg_pos)
                       from ins.ag_contract_header aghl,
                            ins.ag_contract acl
                       where aghl.ag_contract_header_id = ac.contract_id
                             and acl.ag_contract_id = ac.ag_contract_id)
                             ) leg_pos,

       --decode(ac.category_id, 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') agent_cat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),ac.agency_id) ad_agency,
       (SELECT num
          FROM ven_ag_contract_header v
         WHERE v.ag_contract_header_id = (SELECT MAX(contract_id)
                                            FROM ag_contract
                                           WHERE ag_contract_id =  ac.contract_leader_id)) leader_ad,
       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.contract_leader_id) leader_fio,

       (select cat.category_name
        from ag_category_agent cat
        where cat.ag_category_agent_id = (SELECT ac_lead.category_id
                                          FROM ven_ag_contract ac_lead
                                          WHERE ac_lead.ag_contract_id IN
                                                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                                                         FROM ag_contract
                                                                        WHERE ag_contract_id =  ac.contract_leader_id)
                                       )) lead_cat,

/*       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, to_date('27-07-2010','dd-mm-yyyy')\*(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')*\)
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_leader_id)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') lead_cat,*/

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_leader_id)
       ) lead_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_leader_id)
       )) lead_agency,

       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.contract_recrut_id) recr_fio,

       (SELECT num
          FROM ven_ag_contract_header v
         WHERE v.ag_contract_header_id = (SELECT MAX(contract_id)
                                            FROM ag_contract
                                           WHERE ag_contract_id =  ac.contract_recrut_id)
       ) recr_ad,

       (select cat.category_name
        from ag_category_agent cat
        where cat.ag_category_agent_id = (SELECT ac_lead.category_id
                                          FROM ven_ag_contract ac_lead
                                          WHERE ac_lead.ag_contract_id IN
                                                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                                                         FROM ag_contract
                                                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       )) recr_cat,

/*       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, to_date('27-07-2010','dd-mm-yyyy')\*(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')*\)
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') recr_cat,*/

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       ) recr_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id,/* to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       )) recr_agency,

       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.CONTRACT_F_LEAD_ID) f_lead_fio,
       (SELECT num
          FROM ven_ag_contract_header v
         WHERE v.ag_contract_header_id = (SELECT MAX(contract_id)
                                            FROM ag_contract
                                           WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       ) f_lead_ad,

       (select cat.category_name
        from ag_category_agent cat
        where cat.ag_category_agent_id = (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       )) f_lead_cat,

/*       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, to_date('27-07-2010','dd-mm-yyyy')\*(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')*\)
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') f_lead_cat,*/

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       ) f_lead_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id,/*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       )) f_lead_agency,
       ach.agent_id,
      (SELECT CASE WHEN ac0.category_id IN (50)
              THEN ach0.num||' '||cn0.obj_name_orig
              WHEN ac1.category_id IN (50)
              THEN ach1.num||' '||cn1.obj_name_orig
              WHEN ac2.category_id IN (50)
              THEN ach2.num||' '||cn2.obj_name_orig
              END-- "Директор"
    FROM ins.ag_contract ac_s0
        ,ins.ven_ag_contract_header ach0
        ,ins.ag_contract ac0
        ,ins.contact     cn0
        ,ins.ag_contract ac_s1
        ,ins.ag_contract ac1
        ,ins.ven_ag_contract_header ach1
        ,ins.contact     cn1
        ,ins.ag_contract ac_s2
        ,ins.ag_contract ac2
        ,ins.ven_ag_contract_header ach2
        ,ins.contact     cn2
   WHERE ac_s0.ag_contract_id=ac.contract_leader_id--contract_leader
     AND ach0.ag_contract_header_id=ac_s0.contract_id
     AND ac0.ag_contract_id=ach0.last_ver_id
     AND cn0.contact_id=ach0.agent_id
     AND ac_s1.ag_contract_id=ac0.contract_leader_id
     AND ach1.ag_contract_header_id=ac_s1.contract_id
     AND ac1.ag_contract_id=ach1.last_ver_id
     AND cn1.contact_id=ach1.agent_id
     AND ac_s2.ag_contract_id=ac1.contract_leader_id
     AND ach2.ag_contract_header_id=ac_s2.contract_id
     AND ac2.ag_contract_id=ach2.last_ver_id
     AND cn2.contact_id=ach2.agent_id) ter_dir

  FROM ag_contract ac,
       ag_contract_header ach,
       t_sales_channel    sc,
       (select * from
        (select ci.contact_id, ci.id_value id_value, row_number() over(partition by ci.contact_id order by nvl(ci.is_default,0)) rn
          from ins.cn_contact_ident ci, ins.t_id_type it
         where ci.id_type = it.id
           and it.brief = 'MATERNITY_LEAVE'
           and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date') between ci.issue_date and nvl(ci.termination_date,to_date('31.12.3000','dd.mm.yyyy'))
         ) lv
        where lv.rn = 1) mat_leave

 WHERE pkg_agent_1.get_status_by_date(ac.contract_id, /*to_date('27-07-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) = ac.ag_contract_id
   --AND doc.get_doc_status_brief(ac.contract_id,to_date('27-07-2010','dd-mm-yyyy')/*(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')*/) IN ('CURRENT','PRINTED','RESUME', 'NEW')
   AND ac.agency_id <> 8127
   and ach.ag_contract_header_id = ac.contract_id
   and sc.id = ach.t_sales_channel_id
   and ach.agent_id = mat_leave.contact_id(+)
   /*and sc.description = 'DSF'*/;

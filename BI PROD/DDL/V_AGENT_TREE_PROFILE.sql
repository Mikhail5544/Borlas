CREATE OR REPLACE VIEW INS.V_AGENT_TREE_PROFILE AS
SELECT
       doc.get_doc_status_name(ac.contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) AD_stat,
       doc.get_doc_status_name(ac.ag_contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) ADds_stat,
       (select doc.get_doc_status_name(agd.ag_documents_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
        from ins.ag_documents agd,
             ins.ag_doc_type dt
        where agd.ag_contract_header_id = ach.ag_contract_header_id
              and agd.ag_doc_type_id = dt.ag_doc_type_id
              and dt.brief = 'NEW_AD') ag_doc_stat,
        sc.description sales_channel,
        ach.date_begin date_begin_ad,
        pkg_renlife_utils.get_ag_stat_brief(ac.contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) agent_stat,
       (SELECT num FROM ven_ag_contract_header v WHERE v.ag_contract_header_id = ac.contract_id) num_agent_ad,
       ac.contract_id   id_ad,
       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.ag_contract_id) agent_fio,
       decode(ac.category_id, 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') agent_cat,
       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),ac.agency_id) ad_agency,
       (SELECT num
          FROM ven_ag_contract_header v
         WHERE v.ag_contract_header_id = (SELECT MAX(contract_id)
                                            FROM ag_contract
                                           WHERE ag_contract_id =  ac.contract_leader_id)) leader_ad,
       pkg_renlife_utils.get_fio_by_ag_contract_id(ac.contract_leader_id) leader_fio,

       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_leader_id)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') lead_cat,

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_leader_id)
       ) lead_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
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

       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') recr_cat,

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.contract_recrut_id)
       ) recr_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
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

       DECODE(
       (SELECT ac_lead.category_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id,/* to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       ), 2,'Агент', 3, 'Менеджер', 4 , 'Директор', 1, 'Без кат', '') f_lead_cat,

       (SELECT pkg_renlife_utils.get_ag_stat_brief(ac_lead.contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
          FROM ven_ag_contract ac_lead

         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       ) f_lead_stat,

       ENT.OBJ_NAME(INS.ENT.ID_BY_BRIEF('DEPARTMENT'),
       (SELECT ac_lead.agency_id
          FROM ven_ag_contract ac_lead
         WHERE ac_lead.ag_contract_id IN
                                      (SELECT pkg_agent_1.get_status_by_date(contract_id,/*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date'))
                                         FROM ag_contract
                                        WHERE ag_contract_id =  ac.CONTRACT_F_LEAD_ID)
       )) f_lead_agency

  FROM ag_contract ac,
       ag_contract_header ach,
       t_sales_channel    sc

 WHERE pkg_agent_1.get_status_by_date(ac.contract_id, /*to_date('25-06-2010','dd-mm-yyyy')*/(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')) = ac.ag_contract_id
   --AND doc.get_doc_status_brief(ac.contract_id,to_date('25-06-2010','dd-mm-yyyy')/*(SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'ag_tree' and param_name = 'rep_date')*/) IN ('CURRENT','PRINTED','RESUME', 'NEW')
   AND ac.agency_id <> 8127
   and ach.ag_contract_header_id = ac.contract_id
   and sc.id = ach.t_sales_channel_id
   /*and sc.description = 'DSF'*/


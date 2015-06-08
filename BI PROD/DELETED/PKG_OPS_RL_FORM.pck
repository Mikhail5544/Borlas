CREATE OR REPLACE PACKAGE PKG_OPS_RL_FORM IS

  -- Author  : VESELEK
  -- Created : 27.04.2012 10:01:56
  -- Purpose : Подготовка данных для OPS_RL

  PROCEDURE PREP_RL_OPS_NEAREST_AGENT;
  PROCEDURE PREP_RL_OPS_AGENT_TREE;
  PROCEDURE PREP_RL_FOR_DWH;
  PROCEDURE PREP_OPS_FOR_DWH;
  FUNCTION PREP_DATA RETURN NUMBER;

END PKG_OPS_RL_FORM;
/
CREATE OR REPLACE PACKAGE BODY PKG_OPS_RL_FORM IS

  PROCEDURE PREP_RL_OPS_NEAREST_AGENT IS
    proc_name VARCHAR2(26) := 'PREP_RL_OPS_NEAREST_AGENT';
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.RL_OPS_NEAREST_AGENT';
  
    INSERT INTO RL_OPS_NEAREST_AGENT
      SELECT /*+INDEX(cnp IX_AG_CONTRACT_01) */
       pad.policy_header_id
      ,pad.ag_contract_header_id AS agent_ag_id
      ,ch.agent_id
      ,dch.num AS ad_num
      ,co.obj_name_orig AS agent_name
      ,cat.category_name AS agent_category
      ,dep.name AS agent_agency
      ,sc.description AS agent_sales_chanel
      ,CASE
         WHEN cat.ag_category_agent_id = 3 THEN
          CASE
            WHEN ch.date_break != to_date('31.12.2999', 'dd.mm.yyyy') THEN
             nullif(ch.date_break, to_date('31.12.2999', 'dd.mm.yyyy'))
            ELSE
             (SELECT MIN(ac_f.date_begin)
                FROM ins.ag_contract ac_f
               WHERE ac_f.contract_id = ch.ag_contract_header_id
                 AND ac_f.category_id = 2
                 AND ac_f.date_begin > pad.date_begin)
          END
       END AS mng_break
       
      ,chp.ag_contract_header_id AS leader_ag_ad_id
      ,dcp.num AS leader_ad_num
      ,cop.obj_name_orig AS leader_name
      ,cap.category_name AS leader_cat
      ,depp.name AS leader_agency
      ,NVL(NVL((SELECT agh.num || '-' || c.obj_name_orig || '/' || cat.category_name
                 FROM ins.sales_dept_header      sdh
                     ,ins.sales_dept             sd
                     ,ins.ven_ag_contract_header agh
                     ,ins.contact                c
                     ,ins.document               d
                     ,ins.doc_status_ref         rf
                     ,ins.ag_contract            aga
                     ,ins.ag_category_agent      cat
                WHERE sdh.last_sales_dept_id = sd.sales_dept_id
                  AND sd.manager_id = agh.ag_contract_header_id
                  AND agh.agent_id = c.contact_id
                  AND dep.org_tree_id = sdh.organisation_tree_id
                  AND agh.ag_contract_header_id = d.document_id
                  AND d.doc_status_ref_id = rf.doc_status_ref_id
                  AND rf.brief = 'CURRENT'
                  AND agh.ag_contract_header_id = aga.contract_id
                  AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                      aga.date_begin AND aga.date_end
                  AND aga.category_id = cat.ag_category_agent_id
                  AND cat.brief IN ('RM', 'TD')
                  AND ROWNUM = 1)
              ,(SELECT aghl.num || '-' || c.obj_name_orig || '/' || cat.category_name
                 FROM ins.sales_dept_header      sdh
                     ,ins.sales_dept             sd
                     ,ins.ven_ag_contract_header agh
                     ,ins.document               d
                     ,ins.doc_status_ref         rf
                     ,ins.ag_contract            aga
                     ,ins.ag_contract            agl
                     ,ins.ven_ag_contract_header aghl
                     ,ins.ag_contract            agll
                     ,ins.contact                c
                     ,ins.document               dl
                     ,ins.doc_status_ref         rfl
                     ,ins.ag_category_agent      cat
                WHERE sdh.last_sales_dept_id = sd.sales_dept_id
                  AND sd.manager_id = agh.ag_contract_header_id
                  AND dep.org_tree_id = sdh.organisation_tree_id
                  AND agh.ag_contract_header_id = d.document_id
                  AND d.doc_status_ref_id = rf.doc_status_ref_id
                  AND rf.brief = 'CURRENT'
                  AND agh.ag_contract_header_id = aga.contract_id
                  AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                      aga.date_begin AND aga.date_end
                  AND aga.contract_leader_id = agl.ag_contract_id
                  AND agl.contract_id = aghl.ag_contract_header_id
                  AND aghl.ag_contract_header_id = agll.contract_id
                  AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                      agll.date_begin AND agll.date_end
                  AND agll.category_id = cat.ag_category_agent_id
                  AND aghl.agent_id = c.contact_id
                  AND aghl.ag_contract_header_id = dl.document_id
                  AND dl.doc_status_ref_id = rfl.doc_status_ref_id
                  AND rfl.brief = 'CURRENT'
                  AND cat.brief IN ('RM', 'TD')
                  AND ROWNUM = 1))
          ,(SELECT aghl.num || '-' || c.obj_name_orig || '/' || cat.category_name
             FROM ins.ven_ag_contract_header agh
                 ,ins.document               d
                 ,ins.doc_status_ref         rf
                 ,ins.ag_contract            aga
                 ,ins.ag_category_agent      cat
                 ,ins.ag_contract            agl
                 ,ins.ven_ag_contract_header aghl
                 ,ins.document               dl
                 ,ins.doc_status_ref         rfl
                 ,ins.contact                c
            WHERE agh.agency_id = dep.department_id
              AND agh.ag_contract_header_id = aga.contract_id
              AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                  aga.date_begin AND aga.date_end
              AND cat.ag_category_agent_id = aga.category_id
              AND cat.brief IN ('DR2', 'DR')
              AND agh.ag_contract_header_id = d.document_id
              AND d.doc_status_ref_id = rf.doc_status_ref_id
              AND rf.brief = 'CURRENT'
              AND NVL(agh.is_new, 0) = 1
              AND aga.contract_leader_id = agl.ag_contract_id
              AND agl.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
              AND aghl.ag_contract_header_id = dl.document_id
              AND dl.doc_status_ref_id = rfl.doc_status_ref_id
              AND rfl.brief = 'CURRENT'
              AND NVL(aghl.is_new, 0) = 1
              AND ROWNUM = 1)) TD_RU_DEP
        FROM ins.p_policy_agent_doc pad
            ,ins.document           dc
            ,ins.doc_status_ref     dsr
             
            ,ins.ag_contract_header ch
            ,ins.document           dch
             
            ,ins.ag_contract       cn
            ,ins.contact           co
            ,ins.ag_category_agent cat
            ,ins.department        dep
            ,ins.t_sales_channel   sc
             
             -- parent
            ,ins.ag_contract_header chp
            ,ins.document           dcp
            ,ins.ag_contract        cnp
            ,ins.contact            cop
            ,ins.ag_category_agent  cap
            ,ins.department         depp
       WHERE pad.ag_contract_header_id = ch.ag_contract_header_id
         AND pad.p_policy_agent_doc_id = dc.document_id
         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
         AND dsr.brief != 'ERROR'
         AND ch.agent_id = co.contact_id
         AND sc.id NOT IN (8, 10, 81, 16)
         AND ch.ag_contract_header_id = cn.contract_id
         AND ch.ag_contract_header_id = dch.document_id
         AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
             cn.date_begin AND cn.date_end
         AND cn.category_id = cat.ag_category_agent_id
         AND cn.agency_id = dep.department_id
         AND ch.t_sales_channel_id = sc.id
         AND cn.contract_leader_id = cnp.ag_contract_id(+)
            
         AND cnp.contract_id = chp.ag_contract_header_id(+)
         AND chp.ag_contract_header_id = dcp.document_id(+)
         AND chp.agent_id = cop.contact_id(+)
         AND cnp.category_id = cap.ag_category_agent_id(+)
         AND cnp.agency_id = depp.department_id(+)
         AND ch.is_new = 1
         AND pad.date_begin <= pad.date_end
         AND pad.date_begin =
             (SELECT MIN(pam.date_begin)
                FROM ins.p_policy_agent_doc pam
                    ,ins.document           dm
                    ,ins.doc_status_ref     dsm
               WHERE pam.policy_header_id = pad.policy_header_id
                 AND pam.p_policy_agent_doc_id = dm.document_id
                 AND dm.doc_status_ref_id = dsm.doc_status_ref_id
                 AND pad.date_begin <= pad.date_end
                 AND dsm.brief != 'ERROR'
                 AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) <=
                     pam.date_end);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении ' || proc_name);
  END PREP_RL_OPS_NEAREST_AGENT;
  /**/
  PROCEDURE PREP_RL_OPS_AGENT_TREE IS
  
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.RL_OPS_AGENT_TREE';
  
    INSERT INTO RL_OPS_AGENT_TREE
      SELECT ach.ag_contract_header_id agent_ag_id
            ,ach.agent_id agent_id
            ,ach.num ad_num
            ,cna.obj_name_orig agent_name
            ,aca.category_name agent_category
            ,dep.NAME agent_agency
            ,acs.DESCRIPTION agent_sales_chanel
            ,DECODE(nvl(mat_leave.contact_id, 0), 0, '', 'Декрет') mat_lv
            ,aat.ag_parent_header_id
            ,CASE
               WHEN aca.ag_category_agent_id = 3 THEN
                CASE
                  WHEN to_date(decode(ach.date_break, TO_DATE('31.12.2999'), NULL, ach.date_break)) IS NOT NULL THEN
                   to_date(decode(ach.date_break, TO_DATE('31.12.2999'), NULL, ach.date_break))
                  ELSE
                   (SELECT MIN(ac_f.date_begin)
                      FROM ins.ag_contract ac_f
                     WHERE ac_f.contract_id = ach.ag_contract_header_id
                       AND ac_f.category_id = 2
                       AND ac_f.date_begin >
                           (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1))
                END
             END mng_break
            ,NVL(NVL((SELECT agh.num || '-' || c.obj_name_orig || '/' || cat.category_name
                       FROM ins.sales_dept_header      sdh
                           ,ins.sales_dept             sd
                           ,ins.ven_ag_contract_header agh
                           ,ins.contact                c
                           ,ins.document               d
                           ,ins.doc_status_ref         rf
                           ,ins.ag_contract            aga
                           ,ins.ag_category_agent      cat
                      WHERE sdh.last_sales_dept_id = sd.sales_dept_id
                        AND sd.manager_id = agh.ag_contract_header_id
                        AND agh.agent_id = c.contact_id
                        AND dep.org_tree_id = sdh.organisation_tree_id
                        AND agh.ag_contract_header_id = d.document_id
                        AND d.doc_status_ref_id = rf.doc_status_ref_id
                        AND rf.brief = 'CURRENT'
                        AND agh.ag_contract_header_id = aga.contract_id
                        AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                            aga.date_begin AND aga.date_end
                        AND aga.category_id = cat.ag_category_agent_id
                        AND cat.brief IN ('RM', 'TD')
                        AND ROWNUM = 1)
                    ,(SELECT aghl.num || '-' || c.obj_name_orig || '/' || cat.category_name
                       FROM ins.sales_dept_header      sdh
                           ,ins.sales_dept             sd
                           ,ins.ven_ag_contract_header agh
                           ,ins.document               d
                           ,ins.doc_status_ref         rf
                           ,ins.ag_contract            aga
                           ,ins.ag_contract            agl
                           ,ins.ven_ag_contract_header aghl
                           ,ins.ag_contract            agll
                           ,ins.contact                c
                           ,ins.document               dl
                           ,ins.doc_status_ref         rfl
                           ,ins.ag_category_agent      cat
                      WHERE sdh.last_sales_dept_id = sd.sales_dept_id
                        AND sd.manager_id = agh.ag_contract_header_id
                        AND dep.org_tree_id = sdh.organisation_tree_id
                        AND agh.ag_contract_header_id = d.document_id
                        AND d.doc_status_ref_id = rf.doc_status_ref_id
                        AND rf.brief = 'CURRENT'
                        AND agh.ag_contract_header_id = aga.contract_id
                        AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                            aga.date_begin AND aga.date_end
                        AND aga.contract_leader_id = agl.ag_contract_id
                        AND agl.contract_id = aghl.ag_contract_header_id
                        AND aghl.ag_contract_header_id = agll.contract_id
                        AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                            agll.date_begin AND agll.date_end
                        AND agll.category_id = cat.ag_category_agent_id
                        AND aghl.agent_id = c.contact_id
                        AND aghl.ag_contract_header_id = dl.document_id
                        AND dl.doc_status_ref_id = rfl.doc_status_ref_id
                        AND rfl.brief = 'CURRENT'
                        AND cat.brief IN ('RM', 'TD')
                        AND ROWNUM = 1))
                ,(SELECT aghl.num || '-' || c.obj_name_orig || '/' || cat.category_name
                   FROM ins.ven_ag_contract_header agh
                       ,ins.document               d
                       ,ins.doc_status_ref         rf
                       ,ins.ag_contract            aga
                       ,ins.ag_category_agent      cat
                       ,ins.ag_contract            agl
                       ,ins.ven_ag_contract_header aghl
                       ,ins.document               dl
                       ,ins.doc_status_ref         rfl
                       ,ins.contact                c
                  WHERE agh.agency_id = dep.department_id
                    AND agh.ag_contract_header_id = aga.contract_id
                    AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                        aga.date_begin AND aga.date_end
                    AND cat.ag_category_agent_id = aga.category_id
                    AND cat.brief IN ('DR2', 'DR')
                    AND agh.ag_contract_header_id = d.document_id
                    AND d.doc_status_ref_id = rf.doc_status_ref_id
                    AND rf.brief = 'CURRENT'
                    AND NVL(agh.is_new, 0) = 1
                    AND aga.contract_leader_id = agl.ag_contract_id
                    AND agl.contract_id = aghl.ag_contract_header_id
                    AND aghl.agent_id = c.contact_id
                    AND aghl.ag_contract_header_id = dl.document_id
                    AND dl.doc_status_ref_id = rfl.doc_status_ref_id
                    AND rfl.brief = 'CURRENT'
                    AND NVL(aghl.is_new, 0) = 1
                    AND ROWNUM = 1)) TD_RU_DEP
        FROM ins.ven_ag_contract_header ach
            ,ins.ag_contract ac
            ,ins.contact cna
            ,ins.ag_category_agent aca
            ,ins.department dep
            ,ins.t_sales_channel acs
            ,ins.ag_agent_tree aat
            ,(SELECT *
                FROM (SELECT ci.contact_id
                            ,ci.id_value id_value
                            ,row_number() over(PARTITION BY ci.contact_id ORDER BY nvl(ci.is_default, 0)) rn
                        FROM ins.cn_contact_ident ci
                            ,ins.t_id_type        it
                       WHERE ci.id_type = it.id
                         AND it.brief = 'MATERNITY_LEAVE'
                         AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                             ci.issue_date AND
                             nvl(ci.termination_date, to_date('31.12.3000', 'dd.mm.yyyy'))) lv
               WHERE lv.rn = 1) mat_leave
       WHERE ach.ag_contract_header_id = ac.contract_id
         AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
             ac.date_begin AND ac.date_end
         AND ac.category_id = aca.ag_category_agent_id
         AND ac.agency_id = dep.department_id
         AND acs.ID = ach.t_sales_channel_id
         AND cna.contact_id = ach.agent_id
         AND aat.ag_contract_header_id = ach.ag_contract_header_id
         AND mat_leave.contact_id(+) = cna.contact_id
         AND acs.id NOT IN (8, 10, 81, 16)
         AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
             aat.date_begin AND aat.date_end;
  
  END PREP_RL_OPS_AGENT_TREE;
  /**/
  PROCEDURE PREP_RL_FOR_DWH IS
  
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.RL_FOR_DWH';
  
    INSERT INTO RL_FOR_DWH
    -- V_RL_FOR_REPINA
      SELECT num
            ,prod_desc
            ,epg_id
            ,set_of_amt_rur
            ,CASE
               WHEN (CASE
                      WHEN pd4_date IS NOT NULL THEN
                       pd4_date
                      ELSE
                       pay_date
                    END) >= TO_DATE('26.03.2012', 'DD.MM.YYYY')
                    AND
                    prod_desc IN ('Инвестор с единовременной формой оплаты'
                                 ,'Инвестор с единовременной формой оплаты_старый')
                    AND ROUND(srok, 0) = 3 THEN
                set_of_amt_rur * 0.3
               WHEN (CASE
                      WHEN pd4_date IS NOT NULL THEN
                       pd4_date
                      ELSE
                       pay_date
                    END) >= TO_DATE('26.03.2012', 'DD.MM.YYYY')
                    AND
                    prod_desc IN ('Инвестор с единовременной формой оплаты'
                                 ,'Инвестор с единовременной формой оплаты_старый')
                    AND ROUND(srok, 0) = 5 THEN
                set_of_amt_rur * 0.2
               ELSE
                (CASE
                  WHEN payment_templ_title = 'Платежное поручение входящее (Прямое списание)'
                       AND pay_term = 'Ежемесячно'
                       AND first_epg = 1 THEN
                   set_of_amt_rur * 2
                  WHEN payment_templ_title = 'Платежное поручение входящее (Перечислено плательщиком)'
                       AND pay_term = 'Ежемесячно'
                       AND first_epg = 1 THEN
                   set_of_amt_rur * 2
                  ELSE
                   (CASE
                     WHEN pay_term = 'Единовременно'
                          AND srok > 1 THEN
                      set_of_amt_rur * 0.1
                     ELSE
                      set_of_amt_rur
                   END)
                END)
             END set_of_amt_rur_everyquat
            ,set_of_amt
            ,set_off_date
            ,set_off_rate
            ,payment_templ_title
            ,pay_date
            ,pp_reg_date
            ,pp_fund
            ,doc_set_off_id
            ,pd4_date
            ,coll_metod
            ,pol_header_id
            ,first_epg
            ,start_date
            ,is_group_flag
            ,plan_date
            ,num2
            ,agent_ag_id
            ,ad_num agent_id
            ,agent_name
            ,agent_category
            ,agent_agency
            ,agent_sales_chanel
            ,ag_mng_break
            ,nvl(agent_sales_chanel, policy_sales_channel) AS policy_sales_channel
            ,leader_ag_ad_id
            ,leader_ad_num
            ,leader_name
            ,leader_cat
            ,leader_agency
            ,CASE
               WHEN first_epg = 1 THEN
                'Оплаченное заявление (первый платеж)'
               ELSE
                (CASE
                  WHEN plan_date - start_date < 365 THEN
                   'Очередные платежи 1 года'
                  ELSE
                   'Очередные платежи 2 и последующий годы'
                END)
             END sign
            ,CASE
               WHEN (CASE
                      WHEN first_epg = 1 THEN
                       'Оплаченное заявление (первый платеж)'
                      ELSE
                       (CASE
                         WHEN plan_date - start_date < 365 THEN
                          'Очередные платежи 1 года'
                         ELSE
                          'Очередные платежи 2 и последующий годы'
                       END)
                    END) = 'Оплаченное заявление (первый платеж)' THEN
                'NBV'
               WHEN (CASE
                      WHEN first_epg = 1 THEN
                       'Оплаченное заявление (первый платеж)'
                      ELSE
                       (CASE
                         WHEN plan_date - start_date < 365 THEN
                          'Очередные платежи 1 года'
                         ELSE
                          'Очередные платежи 2 и последующий годы'
                       END)
                    END) = 'Очередные платежи 1 года' THEN
                'NBV'
               ELSE
                'noNBV'
             END NBV
            ,CASE
               WHEN (CASE
                      WHEN first_epg = 1 THEN
                       'Оплаченное заявление (первый платеж)'
                      ELSE
                       (CASE
                         WHEN plan_date - start_date < 365 THEN
                          'Очередные платежи 1 года'
                         ELSE
                          'Очередные платежи 2 и последующий годы'
                       END)
                    END) = 'Оплаченное заявление (первый платеж)'
                    AND agent_category = 'Агент' THEN
                'Агент'
               ELSE
                ''
             END agent_new_sales
            ,CASE
               WHEN (CASE
                      WHEN first_epg = 1 THEN
                       'Оплаченное заявление (первый платеж)'
                      ELSE
                       (CASE
                         WHEN plan_date - start_date < 365 THEN
                          'Очередные платежи 1 года'
                         ELSE
                          'Очередные платежи 2 и последующий годы'
                       END)
                    END) = 'Оплаченное заявление (первый платеж)' THEN
                agent_name
               ELSE
                ''
             END agmandir_new_sales
            ,CASE
               WHEN (CASE
                      WHEN first_epg = 1 THEN
                       'Оплаченное заявление (первый платеж)'
                      ELSE
                       (CASE
                         WHEN plan_date - start_date < 365 THEN
                          'Очередные платежи 1 года'
                         ELSE
                          'Очередные платежи 2 и последующий годы'
                       END)
                    END) = 'Оплаченное заявление (первый платеж)' THEN
                'Жизнь'
               ELSE
                'Очередные'
             END OPS_Life
            ,CASE
               WHEN agent_category = 'Менеджер' THEN
                agent_name
               ELSE
                CASE
                  WHEN agent_category = 'Агент'
                       AND leader_cat = 'Менеджер' THEN
                   leader_name
                  ELSE
                   ''
                END
             END group_manag
            ,CASE
               WHEN agent_category = 'Менеджер' THEN
                aa_leave
               ELSE
                CASE
                  WHEN agent_category = 'Агент'
                       AND leader_cat = 'Менеджер' THEN
                   la_leave
                  ELSE
                   ''
                END
             END Group_Manag_Decret
            ,NULL AG_CONTRACT_NUM
            ,NULL STATUS_NAME
            ,NULL OPS_IS_KV
            ,leader_mng_break
            ,NULL AS vedom_num
            ,NULL AS version_num
            ,Nbv_koef_for_commiss
            ,NULL AS version_status
            ,SET_OFF_AMT_RUR_PD4_A7
            ,TD_RU_DEP
        FROM (SELECT p.num
                    ,ph.prod_desc
                    ,p.epg_id
                    ,p.set_of_amt_rur
                    ,p.set_of_amt
                    ,p.set_off_date
                    ,p.set_off_rate
                    ,(MONTHS_BETWEEN(ph.end_date, ph.start_date + 1)) / 12 srok
                    ,p.payment_templ_title
                    ,p.pay_date
                    ,p.pp_reg_date
                    ,p.pp_fund
                    ,p.doc_set_off_id
                    ,p.pd4_date
                    ,p.coll_metod
                    ,ph.policy_header_id pol_header_id
                    ,
                     /*e.pol_header_id,*/(CASE
                       WHEN abs(acp.plan_date - ph.start_date) < 5 THEN
                        1
                       ELSE
                        0
                     END) first_epg
                    ,
                     /*e.first_epg,*/ph.start_date
                    ,ph.is_group_flag
                    ,ph.pay_term
                    ,acp.plan_date    plan_date
                    ,
                     /*e.plan_date,*/acp.num num2
                    ,
                     /*e.num num2,*/
                     -- Байтин А.
                     -- Добавил nvlы. Заявка #151040
                     nvl(aa.agent_ag_id, na.agent_ag_id) AS agent_ag_id
                    ,nvl(aa.ad_num, na.ad_num) AS ad_num
                    ,nvl(aa.agent_name, na.agent_name) AS agent_name
                    ,nvl(aa.agent_category, na.agent_category) AS agent_category
                    ,nvl(aa.agent_agency, na.agent_agency) AS agent_agency
                    ,nvl(aa.agent_sales_chanel, na.agent_sales_chanel) AS agent_sales_chanel
                    ,nvl(aa.mng_break, na.mng_break) AS ag_mng_break
                    ,aa.mat_lv aa_leave
                    ,sc.description policy_sales_channel
                    ,nvl(la.agent_ag_id, na.leader_ag_ad_id) AS leader_ag_ad_id
                    ,nvl(la.ad_num, na.leader_ad_num) AS leader_ad_num
                    ,nvl(la.agent_name, na.leader_name) AS leader_name
                    ,nvl(la.agent_category, na.leader_cat) AS leader_cat
                    ,nvl(la.agent_agency, na.leader_agency) AS leader_agency
                    ,la.mng_break leader_mng_break
                    ,la.mat_lv la_leave
                    ,(SELECT SUM(tpc.val)
                        FROM ins.t_prod_coef_type tpct
                            ,ins.t_prod_coef      tpc
                       WHERE tpct.t_prod_coef_type_id = tpc.t_prod_coef_type_id
                         AND tpct.brief = 'nbv_koef_for_commiss'
                         AND tpc.criteria_1 = ph.policy_header_id) Nbv_koef_for_commiss
                     --,p."Сумма зачета в руб. по А7/ПД4" as SET_OFF_AMT_RUR_PD4_A7 -- 195397
                    ,p."Сумма зачета (реальная)" AS SET_OFF_AMT_RUR_PD4_A7 -- 195397
                     ,NVL(aa.td_ru_dep, na.td_ru_dep) AS td_ru_dep
                FROM ins_dwh.fc_pay_doc p
                    ,
                     /*ins_dwh.t_fc_epg           e,*/(SELECT aca.num
                            ,aca.plan_date
                            ,pola.pol_header_id
                            ,aca.payment_id
                        FROM ins.ven_ac_payment aca
                            ,ins.doc_doc        dd
                            ,ins.p_policy       pola
                       WHERE aca.payment_id = dd.child_id
                         AND dd.parent_id = pola.policy_id) acp
                    ,ins_dwh.dm_p_pol_header ph
                    ,ins.t_sales_channel sc
                    ,(SELECT DISTINCT pad.policy_header_id
                                     ,nvl(apd.ag_contract_header_id, achn.ag_contract_header_id) ag_contract_header_id
                        FROM ins.p_policy_agent_doc pad
                            ,ins.document dc
                            ,ins.doc_status_ref dsr
                            ,ins.ag_prev_dog apd
                            ,(SELECT * FROM ins.ven_ag_contract_header WHERE IS_new = 1) achn
                       WHERE 1 = 1
                         AND /*ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) !=
                                              'ERROR'*/
                             pad.p_policy_agent_doc_id = dc.document_id
                         AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                         AND dsr.brief != 'ERROR'
                         AND (SELECT trl.ag_tree_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) BETWEEN
                             pad.date_begin AND pad.date_end
                         AND pad.ag_contract_header_id = apd.ag_prev_header_id(+)
                         AND pad.ag_contract_header_id = achn.ag_contract_header_id(+)
                         AND (achn.is_new = 1 OR achn.ag_contract_header_id IS NULL)) pad
                    ,ins.RL_OPS_AGENT_TREE aa
                    ,ins.RL_OPS_AGENT_TREE la
                     -- Байтин А.
                     -- Заявка №151040
                    ,ins.RL_OPS_NEAREST_AGENT na
               WHERE (CASE
                       WHEN p.pd4_date IS NOT NULL THEN
                        p.pd4_date
                       ELSE
                        p.pay_date
                     END) BETWEEN
                     (SELECT trl.rl_from_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) AND
                     (SELECT trl.rl_to_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1)
                    /*AND e.payment_id(+) = p.epg_id
                    AND ph.policy_header_id = e.pol_header_id*/
                 AND acp.payment_id(+) = p.epg_id
                 AND ph.policy_header_id = acp.pol_header_id
                    /**/
                 AND pad.policy_header_id(+) = ph.policy_header_id
                 AND pad.ag_contract_header_id = aa.agent_ag_id(+)
                 AND aa.ag_parent_header_id = la.agent_ag_id(+)
                 AND ph.sales_channel_id = sc.ID
                 AND sc.ID NOT IN (8, 10, 81, 16)
                 AND ph.policy_header_id = na.policy_header_id(+)
              /*and ph.ids = 1470029786*/
              );
  
  END PREP_RL_FOR_DWH;
  /**/
  PROCEDURE PREP_OPS_FOR_DWH IS
  
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.OPS_FOR_DWH';
  
    INSERT INTO OPS_FOR_DWH
    -- V_OPS_FOR_REPINA
      SELECT num
            ,prod_desc
            ,epg_id
            ,set_off_amt_rur
            ,set_off_amt_rur set_off_amt_rur_everyquat
            ,set_off_amt
            ,set_off_date
            ,set_off_rate
            ,payment_templ_title
            ,pay_date
            ,pp_reg_date
            ,pp_fund
            ,doc_set_off_id
            ,pd4_date
            ,coll_metod
            ,pol_header_id
            ,first_epg
            ,start_date
            ,is_group_flag
            ,plan_date
            ,num2
            ,agent_ag_id
            ,ad_num agent_id
            ,agent_name
            ,agent_category
            ,agent_agency
            ,agent_sales_chanel
            ,ag_mng_break
            ,policy_sales_channel
            ,leader_ag_ad_id
            ,leader_ad_num
            ,leader_name
            ,leader_cat
            ,leader_agency
            ,'ОПС' sign
            ,'NBV' NBV
            ,CASE
               WHEN agent_category = 'Агент' THEN
                'Агент'
               ELSE
                ''
             END agent_new_sales
            ,agent_name agmandir_new_sales
            ,'ОПС' OPS_Life
            ,CASE
               WHEN agent_category = 'Менеджер' THEN
                agent_name
               ELSE
                (CASE
                  WHEN agent_category = 'Агент'
                       AND leader_cat = 'Менеджер' THEN
                   leader_name
                  ELSE
                   ''
                END)
             END group_manag
            ,CASE
               WHEN agent_category = 'Менеджер' THEN
                aa_leave
               ELSE
                (CASE
                  WHEN agent_category = 'Агент'
                       AND leader_cat = 'Менеджер' THEN
                   la_leave
                  ELSE
                   ''
                END)
             END group_manag_decret
            ,ag_contract_num
            ,status_name
            ,ops_is_kv
            ,NULL AS leader_mng_break
            ,vedom_num
            ,version_num
            ,NULL Nbv_koef_for_commiss
            ,version_status
            ,td_ru_dep
        FROM (SELECT NOp.Policy_Num num
                    ,0 epg_id
                    ,CASE
                       WHEN np.Birth_Date >= '01.01.1967' THEN
                        CASE
                          WHEN FLOOR(MONTHS_BETWEEN(NOp.sign_date, np.birth_date) / 12) >= 24 THEN
                           500
                          ELSE
                           0
                        END
                       ELSE
                        0
                     END set_off_amt_rur
                    ,NULL set_off_amt
                    ,NULL set_off_date
                    ,NULL set_off_rate
                    ,NULL payment_templ_title
                    ,NULL pay_date
                    ,NULL pp_reg_date
                    ,NULL pp_fund
                    ,NULL doc_set_off_id
                    ,NULL pd4_date
                    ,NULL coll_metod
                    ,NULL pol_header_id
                    ,NULL first_epg
                    ,nop.notice_date start_date
                    ,NULL is_group_flag
                    ,NULL plan_date
                    ,NULL num2
                    ,aa.agent_ag_id
                    ,aa.ad_num
                    ,aa.agent_name
                    ,aa.agent_category
                    ,aa.agent_agency
                    ,aa.agent_sales_chanel
                    ,aa.mat_lv aa_leave
                    ,la.agent_ag_id leader_ag_ad_id
                    ,la.ad_num leader_ad_num
                    ,la.agent_name leader_name
                    ,la.agent_category leader_cat
                    ,la.agent_agency leader_agency
                    ,nvl(aa.mng_break, la.mng_break) ag_mng_break
                    ,la.mat_lv la_leave
                    ,nvl(aa.agent_sales_chanel, la.agent_sales_chanel) policy_sales_channel
                    ,nop.ag_contract_num
                    ,nsr.status_name status_name
                    ,nop.kv_flag ops_is_kv
                    ,npr.product_name AS prod_desc
                    ,rh.num AS vedom_num
                    ,ar.num AS version_num
                    ,dsr.name AS version_status
                    ,aa.td_ru_dep
                FROM etl.npf_person     np
                    ,etl.npf_ops_policy nop
                    ,etl.npf_product    npr
                    ,etl.npf_status_ref nsr
                    ,
                     --               etl.npf_policy_assured_m npa,
                     (SELECT prev.a2 num
                            ,ach.ag_contract_header_id
                            ,ach.agency_id
                            ,ach.agent_id
                        FROM ins.ven_ag_contract_header ach
                            ,(SELECT *
                                FROM (SELECT ach.ag_contract_header_id a1
                                            ,ach.num                   a2
                                        FROM ins.ven_ag_contract_header ach
                                       WHERE ach.is_new = 1
                                      UNION
                                      SELECT apd.ag_contract_header_id
                                            ,'S' || apd.num
                                        FROM ins.ag_prev_dog apd)) prev
                       WHERE ach.ag_contract_header_id = prev.a1
                         AND ach.is_new = 1
                         AND ach.t_sales_channel_id NOT IN (8, 10, 81, 16)) ach
                    ,ins.RL_OPS_AGENT_TREE aa
                    ,ins.RL_OPS_AGENT_TREE la
                    ,ins.ag_npf_volume_det vd
                    ,ins.ag_volume av
                    ,ins.ven_ag_roll ar
                    ,ins.ven_ag_roll_header rh
                    ,ins.document dc
                    ,ins.doc_status_ref dsr
               WHERE 1 = 1
                 AND np.snils = vd.snils
                 AND vd.ag_volume_id = av.ag_volume_id
                 AND av.ag_roll_id = ar.ag_roll_id
                 AND ar.ag_roll_header_id = rh.ag_roll_header_id
                 AND ar.ag_roll_id = dc.document_id
                 AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                 AND rh.ops_sign_date BETWEEN
                     (SELECT trl.ops_from_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) AND
                     (SELECT trl.ops_to_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1)
                 AND nop.sign_date BETWEEN
                     (SELECT trl.ops_from_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) AND
                     (SELECT trl.ops_to_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1)
                 AND npr.product_id IN (1, 5)
                 AND npr.product_id = nop.product_id
                 AND nop.person_id = np.person_id
                 AND nop.status_ref_id = nsr.status_ref_id
                 AND nop.ag_contract_num = ach.num(+)
                 AND ach.ag_contract_header_id = aa.agent_ag_id(+)
                 AND aa.ag_parent_header_id = la.agent_ag_id(+)
                 AND vd.npf_det_type = 'OPS'
                 AND nop.policy_num NOT IN (SELECT a.ops_num FROM etl.tmp_ops_nums_for_delete a)
              UNION
              SELECT NOp.Policy_Num num
                    ,
                     
                     0 epg_id
                    ,CASE
                       WHEN np.Birth_Date >= '01.01.1967' THEN
                        CASE
                          WHEN FLOOR(MONTHS_BETWEEN(NOp.sign_date, np.birth_date) / 12) >= 24 THEN
                           500
                          ELSE
                           0
                        END
                       ELSE
                        0
                     END set_off_amt_rur
                    ,NULL set_off_amt
                    ,NULL set_off_date
                    ,NULL set_off_rate
                    ,NULL payment_templ_title
                    ,NULL pay_date
                    ,NULL pp_reg_date
                    ,NULL pp_fund
                    ,NULL doc_set_off_id
                    ,NULL pd4_date
                    ,NULL coll_metod
                    ,NULL pol_header_id
                    ,NULL first_epg
                    ,nop.notice_date start_date
                    ,NULL is_group_flag
                    ,NULL plan_date
                    ,NULL num2
                    ,aa.agent_ag_id
                    ,aa.ad_num
                    ,aa.agent_name
                    ,aa.agent_category
                    ,aa.agent_agency
                    ,aa.agent_sales_chanel
                    ,aa.mat_lv aa_leave
                    ,la.agent_ag_id leader_ag_ad_id
                    ,la.ad_num leader_ad_num
                    ,la.agent_name leader_name
                    ,la.agent_category leader_cat
                    ,la.agent_agency leader_agency
                    ,nvl(aa.mng_break, la.mng_break) ag_mng_break
                    ,la.mat_lv la_leave
                    ,nvl(aa.agent_sales_chanel, la.agent_sales_chanel) policy_sales_channel
                    ,nop.ag_contract_num
                    ,nsr.status_name status_name
                    ,nop.kv_flag ops_is_kv
                    ,npr.product_name AS prod_desc
                    ,NULL AS vedom_num
                    ,NULL AS version_num
                    ,NULL AS version_status
                    ,aa.td_ru_dep
                FROM etl.npf_person     np
                    ,etl.npf_ops_policy nop
                    ,etl.npf_product    npr
                    ,etl.npf_status_ref nsr
                    ,
                     --               etl.npf_policy_assured_m npa,
                     (SELECT prev.a2 num
                            ,ach.ag_contract_header_id
                            ,ach.agency_id
                            ,ach.agent_id
                        FROM ins.ven_ag_contract_header ach
                            ,(SELECT *
                                FROM (SELECT ach.ag_contract_header_id a1
                                            ,ach.num                   a2
                                        FROM ins.ven_ag_contract_header ach
                                       WHERE ach.is_new = 1
                                      UNION
                                      SELECT apd.ag_contract_header_id
                                            ,'S' || apd.num
                                        FROM ins.ag_prev_dog apd)) prev
                       WHERE ach.ag_contract_header_id = prev.a1
                         AND ach.is_new = 1
                         AND ach.t_sales_channel_id NOT IN (8, 10, 81, 16)) ach
                    ,ins.RL_OPS_AGENT_TREE aa
                    ,ins.RL_OPS_AGENT_TREE la
               WHERE 1 = 1
                 AND nop.sign_date BETWEEN
                     (SELECT trl.ops_from_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1) AND
                     (SELECT trl.ops_to_date FROM ins.t_rl_ops_date trl WHERE trl.enabled = 1)
                 AND npr.product_id IN (1, 5)
                 AND npr.product_id = nop.product_id
                 AND nop.person_id = np.person_id
                 AND nop.status_ref_id = nsr.status_ref_id
                 AND nop.ag_contract_num = ach.num(+)
                 AND ach.ag_contract_header_id = aa.agent_ag_id(+)
                 AND aa.ag_parent_header_id = la.agent_ag_id(+)
                 AND nop.policy_num NOT IN (SELECT a.ops_num FROM etl.tmp_ops_nums_for_delete a)
                 AND NOT EXISTS
               (SELECT NULL FROM ins.ag_npf_volume_det vd WHERE vd.snils = np.snils));
  
  END PREP_OPS_FOR_DWH;
  /**/
  FUNCTION PREP_DATA RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'PREP_DATA';
  BEGIN
  
    INS.PKG_OPS_RL_FORM.PREP_RL_OPS_NEAREST_AGENT;
    INS.PKG_OPS_RL_FORM.PREP_RL_OPS_AGENT_TREE;
    INS.PKG_OPS_RL_FORM.PREP_RL_FOR_DWH;
    INS.PKG_OPS_RL_FORM.PREP_OPS_FOR_DWH;
  
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.T_RL_OPS';
  
    INSERT /*+ APPEND*/
    INTO INS.T_RL_OPS
      SELECT * FROM INS.V_REPORT_RL_OPS_DWH;
  
    RETURN 1;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ошибка при выполнении ' || proc_name);
  END PREP_DATA;

END PKG_OPS_RL_FORM;
/

CREATE OR REPLACE VIEW V_SMS_CHANGE_AGENT AS 
SELECT policy_header_id
      ,ids
      ,pol_ser
      ,pol_num
      ,holder
      ,product
      ,date_end
      ,agent_num_cancel
      ,agent_name_cancel
      ,tel_num
      ,agent_num_current
      ,agent_name_current
      ,'Уважаемый Клиент, сообщаем Вам о смене агента по Вашему договору ' || pol_num || (CASE
         WHEN (SELECT COUNT(*)
                 FROM ins.ag_documents   agd
                     ,ins.ag_doc_type    adt
                     ,ins.document       d
                     ,ins.doc_status_Ref rf
                WHERE agd.ag_contract_header_id = header_cancel
                  AND agd.ag_doc_type_id = adt.ag_doc_type_id
                  AND adt.brief = 'BREAK_AD'
                  AND agd.ag_documents_id = d.document_id
                  AND d.doc_status_ref_id = rf.doc_status_ref_id
                  AND rf.brief != 'CANCEL') > 0 THEN
          ' в связи с прекращением отношений между компанией и ' || agent_name_cancel_instr || '.'
         ELSE
          '.'
       END) || (CASE
         WHEN agent_num_current = '14013' THEN
          ' Ваш договор передан на прямое сопровождение Компании.'
         ELSE
          ' Ваш новый агент - ' || agent_name_current || '.'
       END) || ' По сопровождению Вашего договора просим связаться' || (CASE
         WHEN agent_num_current != '14013' THEN
          ' с нашим региональным офисом или'
         ELSE
          ''
       END) || ' с нами (495) 981-2-981.' text
      ,contact_id
      ,obj_name_orig contact_name
  FROM (SELECT ph.policy_header_id
              ,ph.ids
              ,pol.pol_ser
              ,pol.pol_num
              ,cpol.obj_name_orig holder
              ,prod.description product
              ,ag_cancel.date_end
              ,NVL(ag_cancel.agent_num_cancel, 'не определен') agent_num_cancel
              ,NVL(ag_cancel.agent_name_cancel, 'не определен') agent_name_cancel
              ,(SELECT tel.telephone_number
                  FROM ins.cn_contact_telephone tel
                      ,ins.t_telephone_type     t
                 WHERE tel.contact_id = cpol.contact_id
                   AND tel.telephone_type = t.id
                   AND t.brief = 'MOBIL'
                   AND tel.status = 1
                   AND tel.control = 0
                   AND tel.telephone_number IS NOT NULL
                   AND ROWNUM = 1) tel_num
              ,NVL(ag_current.agent_num_current, 'не определен') agent_num_current
              ,NVL(ag_current.agent_name_current, 'не определен') agent_name_current
              ,ag_cancel.header_cancel
              ,NVL(ag_cancel.agent_name_cancel_instr, 'не определен') agent_name_cancel_instr
              ,ag_cancel.contact_id contact_id_cancel
              ,ag_current.contact_id contact_id_current
              ,cpol.contact_id
              ,cpol.obj_name_orig
          FROM ins.p_pol_header ph
              ,ins.t_sales_channel chl
              ,ins.t_product prod
              ,ins.p_policy pol
              ,ins.t_payment_terms pt
              ,ins.document da
              ,ins.doc_status_ref rfd
              ,ins.t_contact_pol_role polr
              ,ins.p_policy_contact pcnt
              ,ins.contact cpol
              ,(SELECT MAX(pad.date_end) date_end
                      ,pad.policy_header_id
                      ,agh.num agent_num_cancel
                      ,c.obj_name_orig agent_name_cancel
                      ,c.contact_id
                      ,agh.ag_contract_header_id header_cancel
                      ,c.instrumental agent_name_cancel_instr
                  FROM ins.p_policy_agent_doc     pad
                      ,ins.document               d
                      ,ins.doc_status_ref         rf
                      ,ins.ven_ag_contract_header agh
                      ,ins.contact                c
                 WHERE pad.p_policy_agent_doc_id = d.document_id
                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                   AND rf.brief = 'CANCEL'
                   AND pad.ag_contract_header_id = agh.ag_contract_header_id
                   AND agh.agent_id = c.contact_id
                   AND trunc(pad.date_end) BETWEEN to_date((SELECT r.param_value
                                                      FROM ins_dwh.rep_param r
                                                     WHERE r.rep_name = 'sms_agent'
                                                       AND r.param_name = 'date_from')
                                                   ,'dd.mm.yyyy')
                   AND to_date((SELECT r.param_value
                                 FROM ins_dwh.rep_param r
                                WHERE r.rep_name = 'sms_agent'
                                  AND r.param_name = 'date_to')
                              ,'dd.mm.yyyy')
                 GROUP BY pad.policy_header_id
                         ,agh.num
                         ,c.obj_name_orig
                         ,c.contact_id
                         ,agh.ag_contract_header_id
                         ,c.instrumental) ag_cancel
              ,(SELECT pad.policy_header_id
                      ,agh.num                   agent_num_current
                      ,c.obj_name_orig           agent_name_current
                      ,c.contact_id
                      ,agh.ag_contract_header_id header_current
                  FROM ins.p_policy_agent_doc     pad
                      ,ins.document               d
                      ,ins.doc_status_ref         rf
                      ,ins.ven_ag_contract_header agh
                      ,ins.contact                c
                 WHERE pad.p_policy_agent_doc_id = d.document_id
                   AND d.doc_status_ref_id = rf.doc_status_ref_id
                   AND rf.brief = 'CURRENT'
                   AND pad.ag_contract_header_id = agh.ag_contract_header_id
                   AND agh.agent_id = c.contact_id) ag_current
         WHERE pol.policy_id = ph.last_ver_id
           AND ph.product_id = prod.product_id
           AND polr.brief = 'Страхователь'
           AND da.document_id = pol.policy_id
           AND da.doc_status_ref_id = rfd.doc_status_ref_id
           AND rfd.brief NOT IN ('RECOVER_DENY'
                                ,'RECOVER'
                                ,'READY_TO_CANCEL'
                                ,'STOPED'
                                ,'CANCEL'
                                ,'STOP'
                                ,'BREAK'
                                ,'QUIT_DECL'
                                ,'TO_QUIT'
                                ,'TO_QUIT_CHECK_READY'
                                ,'TO_QUIT_CHECKED'
                                ,'QUIT_REQ_QUERY'
                                ,'QUIT_REQ_GET'
                                ,'QUIT_TO_PAY'
                                ,'QUIT')
           AND pol.payment_term_id = pt.id
           AND pt.DESCRIPTION NOT IN ('Единовременно')
           AND ph.sales_channel_id = chl.id
           AND chl.description IN ('SAS'
                                  ,'SAS 2'
                                  ,'DSF'
                                  ,'Брокерский'
                                  ,'Брокерский без скидки')
           AND pcnt.policy_id = pol.policy_id
           AND pcnt.contact_policy_role_id = polr.id
           AND cpol.contact_id = pcnt.contact_id
              /*AND ph.policy_header_id = 818200*/
           AND ph.policy_header_id = ag_cancel.policy_header_id
           AND ph.policy_header_id = ag_current.policy_header_id(+)
           AND NOT EXISTS (SELECT ch.p_policy_id
                  FROM ins.ven_c_claim_header ch
                 WHERE ch.p_policy_id = pol.policy_id)
           AND EXISTS (SELECT NULL
                  FROM ins.cn_contact_telephone tel
                      ,ins.t_telephone_type     t
                 WHERE tel.contact_id = cpol.contact_id
                   AND tel.telephone_type = t.id
                   AND t.brief = 'MOBIL'
                   AND tel.status = 1
                   AND tel.control = 0
                   AND tel.telephone_number IS NOT NULL)
           AND NOT EXISTS (SELECT 1
                  FROM ins.ven_journal_tech_work jtw
                      ,ins.doc_status_ref        dsr
                 WHERE jtw.doc_status_ref_id = dsr.doc_status_ref_id
                   AND jtw.policy_header_id = ph.policy_header_id
                   AND dsr.brief = 'CURRENT'
                   AND jtw.work_type = 0))
 WHERE contact_id_cancel != contact_id_current;

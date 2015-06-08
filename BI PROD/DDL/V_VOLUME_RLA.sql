CREATE OR REPLACE VIEW V_VOLUME_RLA AS
SELECT sales_ch "Канал продаж",
       ad "Номер АД",
       agent_fio "ФИО АД",
       manager_name "Руководитель",
       recruter_name "Раздатчик",
       IDS "ИДС",
       policy_num "Номер полиса",
       product "Продукт",
       Insuer "Страхователь",
       policy_begin "Дата начала договора",
       insurance_term "Тип оплаты",
       last_status "Последний статус",
       active_status "Активный статус",
       payment_term "Периодичность",
       SUM(trans_sum) "Сумма транзакции",
       epg_date "Дата ЭПГ",
       payment_date "Дата платежа"
FROM
(
select ts.DESCRIPTION sales_ch,
       ach_new.num ad,
       cn.obj_name_orig agent_fio,
       NVL(
       (SELECT aghl.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghl,
             ins.contact c
        WHERE ag.ag_contract_id = ach_new.contract_leader_id
              AND ag.contract_id = aghl.ag_contract_header_id
              AND aghl.agent_id = c.contact_id
       ),
       '1_Корень сети') manager_name,
       NVL(
       (SELECT aghr.num||'_'||c.obj_name_orig
        FROM ins.ag_contract ag,
             ins.ven_ag_contract_header aghr,
             ins.contact c
        WHERE ag.ag_contract_id = ach_new.contract_recrut_id
              AND ag.contract_id = aghr.ag_contract_header_id
              AND aghr.agent_id = c.contact_id
       ),
       '1_Корень сети') recruter_name,
       ph.Ids IDS,
       pp.pol_num policy_num,
       DECODE(tp.DESCRIPTION,'Защита и накопление для банка Ситисервис','Защита и накопление'
                            ,'Platinum Life Active_2 СитиСервис','Platinum Life Active'
                            ,tp.DESCRIPTION) product,
       cn_ins.obj_name_orig Insuer,
       agv.date_begin policy_begin,
       agv.ins_period insurance_term,
       ins.ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       ins.ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       pt.DESCRIPTION payment_term,
       agv.trans_sum,
       agv.epg_date,
       agv.payment_date,
       avt.description
  from ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
      (SELECT ach.ag_contract_header_id,
              NVL(ag.agency_id,ach.agency_id) agency_id,
              ach.agent_id,
              ach.num,
              NVL(chac.id,ach.t_sales_channel_id) t_sales_channel_id,
              ag.contract_leader_id,
              ag.contract_recrut_id
         FROM ins.ven_ag_contract_header ach,
              ins.ag_contract ag,
              ins.t_sales_channel chac
        WHERE (ach.is_new = 1
              OR ach.ag_contract_header_id = 10146042
              )
          AND ach.last_ver_id = ag.ag_contract_id
          AND ag.ag_sales_chn_id = chac.id(+)
       ) ach_new,
       ins.department dep,
       ins.contact cn,
       ins.t_sales_channel ts,
       ins.p_pol_header ph,
       ins.p_policy pp,
       ins.contact cn_ins,
       ins.t_payment_terms pt,
       ins.document epg,
       ins.fund f,
       ins.document pd,
       ins.ac_payment_templ acpt,
       ins.t_collection_method cm,
       ins.t_prod_line_option tplo,
       ins.t_product tp
 WHERE 1=1
   AND arh.num = LPAD((SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'vol_rla'
                        AND r.param_name = 'num_ved'),6,'0')
   AND ar.num = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'vol_rla'
                 AND r.param_name = 'ver_ved')
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id (+)
   AND agv.ag_roll_id = ar.ag_roll_id
   AND avt.ag_volume_type_id = agv.ag_volume_type_id
   AND avt.ag_volume_type_id IN (1,4,6)
   AND ach_new.agent_id = cn.contact_id (+)
   AND ach_new.agency_id = dep.department_id (+)
   AND ach_new.t_sales_channel_id = ts.ID (+)
   AND agv.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pp.policy_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_ins.contact_id
   AND agv.payment_term_id = pt.ID
   AND epg.document_id = agv.epg_payment
   AND f.fund_id = agv.fund
   AND agv.pd_payment = pd.document_id
   AND acpt.payment_templ_id = agv.epg_pd_type
   AND cm.id = agv.pd_collection_method
   AND tplo.ID = agv.t_prod_line_option_id
   AND tp.product_id = ph.product_id
   /*AND ph.ids = 1910078473*/
)
GROUP BY sales_ch,
       ad,
       agent_fio,
       manager_name,
       recruter_name,
       IDS,
       policy_num,
       product,
       Insuer,
       policy_begin,
       insurance_term,
       last_status,
       active_status,
       payment_term,
       epg_date,
       payment_date;

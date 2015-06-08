CREATE OR REPLACE VIEW ins.v_products_riders AS
select ph.policy_header_id                   pol_header_id,
       pol.policy_id                       policy_id,
       ph.dep_name                           "Агентство",
       ph.prod_name                   "Продукт",
       pol.holder_name                 "ФИО Страхователя",
       pc.pl_desc                     "Наименование риска",
       pol.pol_num                         "Номер договора",
       ph.state_name                            "Статус активной версии",
       (CASE
         WHEN abs(ac.plan_date - ph.ph_start_date) < 5 THEN
          1
         ELSE
          0
       END) "Признак 1го ЭПГ",
       ROUND(MONTHS_BETWEEN(pol.po_end_date, ph.ph_start_date) / 12) "Срок",
       (SELECT trm.description
        FROM ins.t_payment_terms trm
        WHERE trm.id = pol.payment_term_id
       )           "Периодичность оплаты",
       (SELECT m.description
        FROM ins.t_collection_method m
        WHERE m.id = pol.collection_method_id
        ) "Тип расчетов",
       ph.ph_start_date                      "Дата начала ДС",
       pol.po_end_date                        "Дата окончания ДС",
       ac.ds_start_date "Дата платежа",
       ac.plan_date "Дата графика",
       pc.fee                             "Брутто взнос",
       pc.ins_amount                      "Страховая сумма",       
       ph.cur_brief                          "Валюта",
       tr.trans_amount "Сумма проводки",
       tr.trans_date "Дата проводки"
from ins.tbl_pr_pol_header ph,
     ins.tbl_pr_p_policy pol,
     ins.tbl_pr_p_cover pc,
     ins.tbl_pr_ac_payment ac,
     ins.tbl_pr_oper_trans tr
where ph.policy_header_id = pol.policy_header_id
  and pol.policy_id = pc.policy_id
  and pc.policy_id = ac.parent_id
  and ac.doc_set_off_id = tr.document_id
  and (tr.a4_dt_uro_id = pc.opt_id
       OR tr.a4_ct_uro_id = pc.opt_id);
       
GRANT SELECT ON ins.v_products_riders TO INS_EUL;
GRANT SELECT ON ins.v_products_riders TO INS_READ;

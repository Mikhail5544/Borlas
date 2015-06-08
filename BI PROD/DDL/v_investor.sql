CREATE OR REPLACE VIEW V_INVESTOR AS
select pp.pol_header_id                   pol_header_id,
       pp.policy_id                       policy_id,
       ph.ids                             ids,
       pp.pol_ser                         "Серия",
       pp.pol_num                         "Номер",
       cpol.obj_name_orig                 "Страхователь",
       prod.description                   "Продукт",
       ph.start_date                      "Дата начала ДС",
       pp.start_date                      "Дата начала версии ДС",
       pp.end_date                        "Дата окончания версии ДС",
       f.brief                            "Валюта ответственности",
       trm.description                    "Период",
       opt.description                    "Группа рисков по программе",
       pc.ins_amount                      "Страховая сумма",
       pc.fee                             "Брутто взнос",
       pc.premium                         "Премия",
       dep.name                           "Подразделение",
       rfph.name                          "Статус последней версии",
       /*pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии",*/
       ac.plan_date "Дата графика",
       ac.grace_date "Срок платежа",
       (SELECT trunc(ds.start_date)
        FROM ins.doc_status ds
        WHERE ds.doc_status_id = dac.doc_status_id) "Дата платежа",
       o.name "Имя операции",
       tr.trans_amount "Сумма проводки",
       tr.trans_date "Дата проводки",
       ag_p_name.ag_name "Агент по договору"
from ins.p_policy                     pp,
     ins.p_pol_header                 ph,
     ins.document                     dph,
     ins.doc_status_ref               rfph,
     ins.fund                         f,
     ins.t_contact_pol_role           polr,
     ins.p_policy_contact             pcnt,
     ins.contact                      cpol,
     ins.t_payment_terms              trm,
     ins.t_product                    prod,
     ins.t_product_group              pg,  -- Чирков 235198: Отчет ОС.Инвестор и справочник "Группа страховых 
     ins.as_asset                     a,
     ins.p_cover                      pc,
     ins.t_prod_line_option           opt,
     ins.department                   dep,
     
     ins.doc_doc                      dd,
     ins.ac_payment                   ac,
     ins.document                     dac,
     ins.doc_set_off                  dsf,
     ins.oper                         o,
     ins.trans                        tr,
     (SELECT ach.num||' '||cn.obj_name_orig as ag_name, ppad.policy_header_id
  FROM ins.p_policy_agent_doc     ppad
      ,ins.document               dc  --2
     -- ,ins.document               dc_ag
      ,ins.contact                cn
      ,ins.ven_ag_contract_header ach      
 WHERE dc.document_id             = ppad.p_policy_agent_doc_id
   AND dc.doc_status_ref_id       = 2 --действующий
   AND ach.ag_contract_header_id  = ppad.ag_contract_header_id
   AND cn.contact_id              = ach.agent_id) ag_p_name
where pp.pol_header_id                = ph.policy_header_id
      and polr.brief                  = 'Страхователь'
      and pcnt.policy_id(+)           = pp.policy_id
      AND ph.last_ver_id              = dph.document_id
      AND dph.doc_status_ref_id       = rfph.doc_status_ref_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id             = pcnt.contact_id
      and ph.fund_id                  = f.fund_id
      and pp.payment_term_id          = trm.id
      AND ph.product_id               = prod.product_id            
      /*комментарий Чирков 235198: Отчет ОС.Инвестор и справочник "Группа страховых 
        AND prod.product_id IN (45581, --Вклад в будущее (Инвестор) для ОАО Банк "Открытие"
                              41175, --Инвестор
                              44056, --Инвестор Альфа Банк
                              44655, --Инвестор с единовременной формой оплаты
                              42795, --Инвестор с единовременной формой оплаты_старый
                              --заявка 197612. Изместьев. 01.11.2012
                              46557,46556, --Инвестор Плюс
                              46298, --Приоритет Инвест (единовременный Инвестор) Сбербанк
                              46296 --Приоритет Инвест (регулярный Инвестор) Сбербанк
                              )*/
      --добавил Чирков  235198: Отчет ОС.Инвестор и справочник "Группа страховых                               
      and pg.t_product_group_id       = prod.t_product_group_id      
      and pg.brief                    = 'Инвестор'
      and prod.product_id             not in (28487 --Семейный депозит
                                            , 42000)--Семейный депозит 2011
      --
      and pp.policy_id                = a.p_policy_id
      and a.as_asset_id               = pc.as_asset_id
      and pc.t_prod_line_option_id    = opt.id
      and ph.agency_id                = dep.department_id(+)
      and dd.parent_id                = pp.policy_id
      and dd.child_id                 = ac.payment_id
      AND ac.payment_id               = dac.document_id
      and dac.doc_status_ref_id       = 6/*'PAID'*/
      and dac.doc_templ_id            = 4/*'PAYMENT'*/
   --   AND ph.ids                      = 6180003217
      AND dsf.parent_doc_id           = ac.payment_id
      AND dsf.cancel_date             IS NULL
      AND dsf.doc_set_off_id          = o.document_id
      AND o.oper_id                   = tr.oper_id
      AND o.oper_templ_id             = 3201/*1825*/
      /*'Страховая премия аванс оплачен'*/
      /*'Страховая премия оплачена'*/
      AND (tr.a4_dt_uro_id = opt.id
           OR tr.a4_ct_uro_id = opt.id)
      AND ag_p_name.policy_header_id(+)  = ph.policy_header_id;

CREATE OR REPLACE VIEW INS_DWH.V_PAYMENT_REGISTER_REP AS
select distinct
       pr.PAYMENT_REGISTER_ITEM_ID "ИД",
       pr.DUE_DATE "Дата ПП",
       pr.NUM      "Номер ПП",
       pr.TITLE    "Вид ПП",
       pr.collection_metod_desc "Способ оплаты",
       pr.paym_term "Вид расчетов",
       pr.PAYMENT_CURRENCY "Валюта платежа",
       pr.AMOUNT           "Сумма прихода",
       pr.SET_OFF_AMOUNT   "Сумма зачтено",
       case when nvl(pr.PAYMENT_SUM,0) = 0 then 1 else pr.PAYMENT_SUM end "Сумма платежа",
       pr.sum2setoff       "Сумма осталось зачесть",
       pr.CONTACT_NAME     "Контрагент",
       pr.POL_SER          "Серия ДС",
       pr.POL_NUM          "Номер ДС",
       pr.PAYER_FIO        "Плательщик",
       pr.TERRITORY        "Регион",
       pr.PAYMENT_PURPOSE  "Назначение",
       pr.ADD_INFO         "Дополнительное поле",
       pr.set_off_state_descr "Статус ручной обработки",
       decode(pr.STATUS,0,'Новый',
                        10,'Условно распознан',
                        20,'Автоматически не распознан',
                        30,'Распознаваться не будет',
                        40,'Разнесён',
                        50,'Распознан автоматически',
                        60,'Ошибочное перечисление',
                        70,'Возвращено',
                        -1,'<none>'
       )"Статус элемента реестра",
       pr.RECOGNIZE_DATA "Дата распознавания",
       pr.NOTE           "Комментарий",
       pr.num_ids "ИДС",
       pr.b_pol_num "Номер полиса",
       pr.num_ser "Номер серии",
       pr.start_date_dog "Дата начала страхования",
       decode(nvl(pr.is_group_flag,0),1,'Групповой','Индивидуальный') "Признак группового договора",
       (SELECT pp_l.start_date
         FROM ins.p_policy pp_l
        WHERE pp_l.policy_id = ins.pkg_policy.get_last_version(nvl(pr.ph_id,ph.policy_header_id))) lv_start_date,
       (SELECT pp_l.decline_date
         FROM ins.p_policy pp_l
        WHERE pp_l.policy_id = ins.pkg_policy.get_last_version(nvl(pr.ph_id,ph.policy_header_id))) lv_decline_date,
       (SELECT ins.doc.get_doc_status_name(pp_l.policy_id)
         FROM ins.p_policy pp_l
        WHERE pp_l.policy_id = ins.pkg_policy.get_last_version(nvl(pr.ph_id,ph.policy_header_id))) lv_status,
       ph.Ids,
       pr.ph_id,
       pr.PAYMENT_REGISTER_ITEM_ID,
       pr.AC_PAYMENT_ID,
       CASE WHEN NVL(
                     (SELECT bac.account_nr || ' в ' || bac.bank_name company_bank_acc_name
                      FROM ins.ven_ac_payment ac,
                           ins.cn_contact_bank_acc bac
                      where ac.payment_id = pr.AC_PAYMENT_ID
                            and ac.company_bank_acc_id = bac.id
                     )
                     ,'X') = 'X' THEN
              (CASE WHEN NVL(pr.xx_receiver_account,'X') = 'X' THEN ''
                    ELSE pr.xx_receiver_account||' в '||pr.xx_receiver_bank_name
               END)
             ELSE
             (SELECT bac.account_nr || ' в ' || bac.bank_name company_bank_acc_name
                      FROM ins.ven_ac_payment ac,
                           ins.cn_contact_bank_acc bac
                      where ac.payment_id = pr.AC_PAYMENT_ID
                            and ac.company_bank_acc_id = bac.id
                     )
       END "Счет компании",
       CASE WHEN NVL(pr.xx_receiver_account,'X') = 'X' THEN

            (CASE WHEN NVL(
                          (SELECT bac.account_nr || ' в ' || bac.bank_name company_bank_acc_name
                           FROM ins.ven_ac_payment ac,
                                ins.cn_contact_bank_acc bac
                           where ac.payment_id = pr.AC_PAYMENT_ID
                             and ac.company_bank_acc_id = bac.id
                           )
                           ,'X') = 'X' THEN ''
                 ELSE
                          (SELECT bac.account_nr || ' в ' || bac.bank_name company_bank_acc_name
                           FROM ins.ven_ac_payment ac,
                                ins.cn_contact_bank_acc bac
                           where ac.payment_id = pr.AC_PAYMENT_ID
                             and ac.company_bank_acc_id = bac.id
                           )
                 END)

       ELSE pr.xx_receiver_account||' в '||pr.xx_receiver_bank_name
       END "Счет компании XX",
       pr.PAYMENT_ID,
       pr.IDS "ИДС, загруженное руками",
       pr.dep_name "Агентство",
       pr.ag_name "Агент",
       pr.leader_name "Руководитель",
       pr.a7_due_date "Дата А7/ПД4",
       pr.a7_num "Номер А7/ПД4",
       nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0') "Конкретное ИДС",

     ins.pkg_policy.get_last_version_status( (select pph.policy_header_id from ins.p_pol_header pph where pph.ids = to_number(
     decode( TRANSLATE(UPPER(nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0')),
'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ| ',
' '),nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0'),
to_number(nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0')),0)
     ) ) ) "Статус Последней версии",
ins.doc.get_doc_status_name( (select pph.policy_id from ins.p_pol_header pph where pph.ids = to_number(
     decode( TRANSLATE(UPPER(nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0')),
'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЪЭЮЯ| ',
' '),nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0'),
to_number(nvl(nvl(to_char(pr.IDS),nvl(to_char(pr.num_ids),nvl(to_char(ph.Ids),nvl(substr(pr.NOTE,48,10),'0')))),'0')),0)
     ) ), to_date('31-12-2999','dd-mm-yyyy') ) "Статус Активной версии",
     pr.epg_amount "Сумма к зачету",
     pr.epg_due_date "Дата ЭПГ",
     pr.pay_amount "Сумма по дог.",
     pr.part_pay_amount "Зачт. по дог.",
     pr.COMMISSION "Сумма комиссии"
    ,pr.reg_date
    ,pr.DOC_NUM "№Док-та"
    ,pr.PAYMENT_DATA "Дата платежа"
 FROM ins_dwh.V_PAYMENT_REGISTER pr
  LEFT OUTER JOIN ins.p_pol_header ph ON to_char(ph.Ids) = substr(pr.NOTE,48,10)
 where pr.DUE_DATE between
       (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'pay_reg' and param_name = 'start_date')
                       and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'pay_reg' and param_name = 'end_date')
   and (pr.contact_name != 'ООО "ХКФ БАНК"'
         and exists (SELECT null FROM ins_dwh.rep_param WHERE rep_name = 'pay_reg' and param_name = 'without_hcb' and upper(param_value) = 'ДА')
        or exists (SELECT null FROM ins_dwh.rep_param WHERE rep_name = 'pay_reg' and param_name = 'without_hcb' and upper(param_value) != 'ДА')
       );

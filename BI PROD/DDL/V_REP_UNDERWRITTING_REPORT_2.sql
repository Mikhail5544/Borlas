CREATE OR REPLACE VIEW INS.V_REP_UNDERWRITTING_REPORT_2 AS
SELECT "Агентство"
       ,"ФИО Рук"
       ,"Агент по ДС"
       ,
       /*"Агент по ДС пред",
       "Канал продаж пред Агента",
       "Агентство пред",*/"Серия ДС"
       ,"Номер ДС"
       ,"Продукт"
       ,"Дата начала ДС"
       ,"Страхователь"
       ,"Дата акцепта ДС"
       ,"Дата акцепта Год"
       ,"Дата акцепта Месяц"
       ,"Текщий статус"
       ,"Статус последней версии"
       ,"Шаг процесса"
       ,nvl("Ответственный", 'нет ответственного') "Ответственный"
       ,"Дата присвоения статуса"
       ,"Длительность"
       ,"Плановая длит."
       ,"Отклонение"
       ,"ИДС"
       ,policy_header_id
       ,"Статус 1 ЭПГ"
       ,"Вид расчета"
       ,user_name
       ,"дней от пред. до тек. статуса"
       ,"мин дата статуса ДП или Д"
       ,trunc("мин дата статуса ДП или Д", 'dd') - "Дата акцепта ДС" "Дней от акцепта до ДП или Д"
       ,CASE
         WHEN "мин дата статуса ДП или Д" IS NULL THEN
          'not issued'
         WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 8 THEN
          'до 7'
         WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 15 THEN
          'до 14'
         WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 22 THEN
          'до 21'
         WHEN "мин дата статуса ДП или Д" - "Дата акцепта ДС" < 29 THEN
          'до 28'
         ELSE
          'дольше'
       END "Группа"
       ,"Групповой ДС"
       ,"Действующий агент"
       ,"Уровень риска Страхователя"
       ,"Уровень риска Агента по ДС"
       ,"Уровень риска Действ агента"
  FROM (SELECT ins.ent.obj_name('DEPARTMENT', a.agency_id) "Агентство"
               ,nvl(ins.ent.obj_name('CONTACT'
                                   ,(SELECT ach_lead.agent_id
                                      FROM ins.ag_contract_header ach_lead
                                     WHERE ach_lead.ag_contract_header_id = a.ac_lead_contract_id))
                  ,'Нет руководителя') "ФИО Рук"
               ,ins.ent.obj_name('CONTACT', a.agent_id) "Агент по ДС"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id = a.agent_id
                   AND c.risk_level = ll.t_risk_level_id) "Уровень риска Агента по ДС"
               ,pp.pol_ser "Серия ДС"
               ,pp.pol_num "Номер ДС"
               ,tp.description "Продукт"
               ,ph.start_date "Дата начала ДС"
               ,ins.ent.obj_name('CONTACT'
                               ,ins.pkg_policy.get_policy_contact(pp.policy_id
                                                                 ,'Страхователь')) "Страхователь"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id =
                       ins.pkg_policy.get_policy_contact(pp.policy_id, 'Страхователь')
                   AND c.risk_level = ll.t_risk_level_id) "Уровень риска Страхователя"
               ,trunc(pp.sign_date, 'dd') "Дата акцепта ДС"
               ,to_char(pp.sign_date, 'YYYY') "Дата акцепта Год"
               ,to_char(pp.sign_date, 'mm') "Дата акцепта Месяц"
               ,
               
               dsr.name "Текщий статус"
               ,ins.pkg_policy.get_last_version_status(ph.policy_header_id) "Статус последней версии"
               ,
               --(select rf.name from ins.doc_status_ref rf where rf.doc_status_ref_id = doc.doc_status_ref_id) "Статус последней версии",
               (SELECT da.note
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Шаг процесса"
               ,(SELECT da.respons_pers
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Ответственный"
               ,ds.change_date "Дата присвоения статуса"
               ,ROUND(ds.change_date - pp.sign_date) "Длительность"
               ,(SELECT da.plan_duration
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Плановая длит."
               ,(SELECT da.plan_duration - ROUND(lead(ds.change_date, 1, SYSDATE)
                                                over(ORDER BY ds.change_date) - ds.change_date
                                               ,2)
                  FROM ins.doc_templ_status   dts_src
                      ,ins.doc_templ_status   dts_dst
                      ,ins.doc_status_allowed da
                 WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
                   AND dts_dst.doc_templ_id = pp.doc_templ_id
                   AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
                   AND dts_src.doc_templ_id = pp.doc_templ_id
                   AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
                   AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "Отклонение"
               ,ph.ids "ИДС"
               ,ph.policy_header_id
               ,(SELECT MIN(ins.doc.get_doc_status_name(ap.payment_id)) keep(dense_rank FIRST ORDER BY plan_date DESC)
                  FROM ins.p_policy       p2
                      ,ins.ven_ac_payment ap
                      ,ins.document       d
                      ,ins.doc_templ      dt
                      ,ins.doc_doc        dd
                 WHERE dd.parent_id = p2.policy_id
                   AND d.document_id = dd.child_id
                   AND dt.doc_templ_id = d.doc_templ_id
                   AND dt.brief = 'PAYMENT'
                   AND ap.payment_id = dd.child_id
                   AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                   AND p2.pol_header_id = ph.policy_header_id) "Статус 1 ЭПГ"
               
               ,(SELECT cm.description
                  FROM ins.t_collection_method cm
                 WHERE cm.id = pp.collection_method_id) "Вид расчета"
               ,ds.user_name
               ,(SELECT trunc(ds.change_date - ds2.change_date)
                  FROM (SELECT ds.change_date
                              ,ds.doc_status_id
                              ,ds.document_id
                              ,row_number() over(PARTITION BY ds.document_id ORDER BY ds.change_date DESC) c
                          FROM ins.doc_status ds) a
                      ,ins.doc_status ds2
                 WHERE a.document_id = ds2.document_id
                   AND ds2.doc_status_id = a.doc_status_id
                   AND ds2.document_id = pp.policy_id
                   AND a.c = 2) "дней от пред. до тек. статуса"
               ,(SELECT MIN(ds2.change_date)
                  FROM ins.p_policy       p2
                      ,ins.doc_status     ds2
                      ,ins.doc_status_ref dsr2
                 WHERE p2.pol_header_id = ph.policy_header_id
                   AND ds2.document_id = p2.policy_id
                   AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
                   AND dsr2.brief IN ('CONCLUDED', 'CURRENT')) "мин дата статуса ДП или Д"
               ,nvl(pp.is_group_flag, 0) "Групповой ДС"
               ,ag_cur.agent_current "Действующий агент"
               ,(SELECT ll.description
                  FROM ins.contact      c
                      ,ins.t_risk_level ll
                 WHERE c.contact_id = ag_cur.agent_id
                   AND c.risk_level = ll.t_risk_level_id) "Уровень риска Действ агента"
          FROM ins.p_pol_header ph
              ,ins.ven_p_policy pp
              ,ins.document doc
              ,ins.t_product tp
              ,ins.doc_status ds
              ,ins.doc_status_ref dsr
              ,(SELECT ph.policy_header_id
                      ,ach.agent_id
                      ,ach.agency_id
                      ,ac_lead.contract_id       ac_lead_contract_id
                      ,dep.name                  dep_name
                      ,ach.is_new
                      ,ach.ag_contract_header_id
                  FROM ins.p_pol_header       ph
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                      ,ins.ag_contract        ac_lead
                      ,ins.department         dep
                 WHERE ach.ag_contract_header_id =
                       ins.pkg_renlife_utils.get_p_agent_sale_new(ph.policy_header_id)
                   AND ach.agency_id = dep.department_id
                   AND ach.last_ver_id = ac.ag_contract_id
                   AND ac.contract_leader_id = ac_lead.ag_contract_id(+)) a
              ,
               
               (SELECT ph.policy_header_id
                      ,ach.agent_id
                      ,ach.agency_id
                      ,ach.t_sales_channel_id
                      ,cagc.obj_name_orig agent_current
                  FROM ins.p_pol_header           ph
                      ,ins.ven_ag_contract_header ach
                      ,ins.contact                cagc
                 WHERE ach.ag_contract_header_id =
                       ins.pkg_renlife_utils.get_p_agent_current_new(ph.policy_header_id)
                   AND cagc.contact_id = ach.agent_id) ag_cur
         WHERE ph.policy_id = pp.policy_id
           AND pp.policy_id = doc.document_id
           AND tp.product_id = ph.product_id
              --and a.policy_header_id (+) = ph.policy_header_id
           AND a.policy_header_id = ph.policy_header_id
           AND ins.doc.get_doc_status_rec_id(pp.policy_id, '01.01.3000') = ds.doc_status_id
           AND ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND ph.policy_header_id = ag_cur.policy_header_id(+)
           AND tp.brief NOT IN ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')
              --and pp.policy_id = 62496530
              -------------------------------------------------------------------------------------------------------
              -- and pp.sign_date BETWEEN to_date('01.01.2015', 'dd.mm.yyyy') and to_date('01.02.2015', 'dd.mm.yyyy')
           AND pp.sign_date BETWEEN to_date((SELECT r.param_value
                                              FROM ins_dwh.rep_param r
                                             WHERE r.rep_name = 'under_rep_2'
                                               AND r.param_name = 'DATE_FROM')
                                           ,'dd.mm.yyyy')
           AND to_date((SELECT r.param_value
                         FROM ins_dwh.rep_param r
                        WHERE r.rep_name = 'under_rep_2'
                          AND r.param_name = 'DATE_TO')
                      ,'dd.mm.yyyy')
              -------------------------------------------------------------------------------------------------------
           AND (a.dep_name NOT IN (' Отдел бизнес-туризма'
                                  ,'Call center'
                                  ,'Тверь'
                                  ,'Административное управление'
                                  ,'Административно-хозяйственный  отдел'
                                  ,'Барнаул GRS'
                                  ,'Барнаул GRS-1'
                                  ,'Бухгалтерия'
                                  ,'Владимир GRS'
                                  ,'Внешние агенты и агентства'
                                  ,'Волгоград GRS'
                                  ,'Вологда GRS'
                                  ,'ГРС в г. Санкт-Петербург'
                                  ,'ГРС Центр обслуживания клиентов г. Санкт-Петербург'
                                  ,'Департамент корпоративных продаж'
                                  ,'Департамент маркетинга, PR и рекламы'
                                  ,'Департамент по корпоративным продажам'
                                  ,'Департамент по продажам через банки и брокеров'
                                  ,'Екатеринбург GRS'
                                  ,'Екатеринбург ЦОК ГРС'
                                  ,'Иркутск GRS'
                                  ,'Истра GRS'
                                  ,'Казань GRS'
                                  ,'Казань GRS-2'
                                  ,'Каневская GRS'
                                  ,'Кемерово GRS'
                                  ,'Колл-центр'
                                  ,'Коммерческое управление'
                                  ,'Контакт центр 1'
                                  ,'Королев GRS'
                                  ,'Красноярск GRS'
                                  ,'Красноярск GRS Группа-1'
                                  ,'Красноярск GRS-1'
                                  ,'Липецк GRS'
                                  ,'Москва ЦО'
                                  ,'Москва-1 GRS'
                                  ,'Москва-1 GRS-1'
                                  ,'Москва-1 GRS-3'
                                  ,'Москва-1 GRS-6'
                                  ,'Неопознанный Склад-1'
                                  ,'Неопознанный Склад-2'
                                  ,'Нижний Новгород GRS'
                                  ,'Нижний Новгород GRS отдел продаж'
                                  ,'Новосибирск GRS'
                                  ,'Омск GRS'
                                  ,'Оренбург GRS'
                                  ,'Операционное управление'
                                  ,'Отдел выплат'
                                  ,'Отдел корпоративных продаж'
                                  ,'Отдел методологии и андеррайтинга'
                                  ,'Отдел отчетности'
                                  ,'Отдел по работе с банками'
                                  ,'Отдел по работе с брокерами и независимыми агентами'
                                  ,'Отдел по развитию менеджеров'
                                  ,'Отдел по расчетам с персоналом'
                                  ,'Отдел по связям с общественностью и рекламе'
                                  ,'Отдел привязки платежей'
                                  ,'Отдел разработки программного обеспечения'
                                  ,'Отдел рекрутинга'
                                  ,'Отдел технической поддержки и регионального развития'
                                  ,'Отдел управленческой отчетности и планирования'
                                  ,'Отдел урегулирования убытков'
                                  ,'Отдел учета'
                                  ,'Отдел финансового анализа и инвестиций'
                                  ,'Пермь GRS'
                                  ,'Подразделение ГРС Агентства ООО "СК "Ренессанс Жизнь"  в городе Краснодаре'
                                  ,'Подразделение ГРС Агентство в г. Магнитогорск Филиала ООО "СК" Ренессанс Жизнь" в городе Челябинске'
                                  ,'Подразделение ГРС Агентство в г. Челябинск ООО "СК" Ренессанс Жизнь" в городе Челябинске'
                                  ,'Подразделение ГРС в городе Набережные Челны Филиала ООО "СК "Ренессанс Жизнь" в городе Казань'
                                  ,'Подразделение ГРС Группа №1 в г.Волгоград Агентства ООО "СК "Ренессанс Жизнь" в городе Волгограде'
                                  ,'Подразделение ГРС Отдел розничных продаж в г.Волгоград Агентства ООО "СК "Ренессанс Жизнь" в городе Волгограде'
                                  ,'Подразделение ГРС №2 в г.Екатеринбург Филиала ООО "СК "Ренессанс Жизнь" в городе Екатеринбурге'
                                  ,'Подразделение ГРС №2 в г.Нижний Новгород Филиала ООО "СК "Ренессанс Жизнь" в городе Нижний Новгород'
                                  ,'Подразделение ГРС №3 в г.Уфе Филиала ООО "СК "Ренессанс Жизнь" в городе Уфе'
                                  ,'Проект Подмосковье'
                                  ,'Региональное Операционное управление'
                                  ,'Ренлайф Партнерс'
                                  ,'РОО 1'
                                  ,'РОО 2'
                                  ,'Ростов на Дону GRS'
                                  ,'Самара GRS-2'
                                  ,'Самара GRS-4'
                                  ,'Санкт-Пеетрбург GRS ВЗР'
                                  ,'Санкт-Петербург GRS Архангельск'
                                  ,'Санкт-Петербург GRS Выборгское'
                                  ,'Санкт-Петербург GRS Выборгское представительство'
                                  ,'Санкт-Петербург GRS Гатчинское'
                                  ,'Санкт-Петербург GRS группа развития'
                                  ,'Санкт-Петербург GRS Киришское'
                                  ,'Санкт-петербург GRS Колпинское'
                                  ,'Санкт-Петербург GRS Комендантское'
                                  ,'Санкт-Петербург GRS Отдел развития-2'
                                  ,'Санкт-Петербург GRS Пушкинское'
                                  ,'Санкт-Петербург GRS Тосненское'
                                  ,'Санкт-Петербург GRS Турфирмы'
                                  ,'Санкт-Петербург GRS-1'
                                  ,'Санкт-Петербург GRS-12'
                                  ,'Санкт-Петербург GRS-2'
                                  ,'Санкт-Петербург GRS-3'
                                  ,'Санкт-Петербург GRS-4'
                                  ,'Санкт-Петербург GRS-5'
                                  ,'Саранск GRS'
                                  ,'Саратов GRS'
                                  ,'Сотрудники ООО "СК "Ренессанс Жизнь"'
                                  ,'Стерлитамак GRS-3'
                                  ,'Тольятти_Самара GRS'
                                  ,'Транспортный отдел'
                                  ,'Тюмень GRS'
                                  ,'УПРАВЛЕНИЕ  ИНФОРМАЦИОННЫХ ТЕХНОЛОГИЙ'
                                  ,'Управление актуарных расчетов'
                                  ,'Управление андеррайтинга, методологии, перестрахования и урегулирования убытков'
                                  ,'Управление делами'
                                  ,'Управление по работе с персоналом'
                                  ,'Управление по развитию информационных систем'
                                  ,'Управление по региональному развитию (ГРС)'
                                  ,'Управление развития продаж'
                                  ,'Управление регионального развития (Киев)'
                                  ,'Управление регионального развития (Москва)'
                                  ,'Уфа GRS'
                                  ,'Учебный центр'
                                  ,'Ф'
                                  ,'Финансовое управление'
                                  ,'Челябинск GRS-1'
                                  ,'Юридическое управление'
                                  ,'Ярославль GRS') OR
               --390998 Григорьев Ю. Хардкодом добавляем выгрузку данных по продукту Наследие у "Внешние агенты и агентства"
               (a.dep_name = 'Внешние агенты и агентства' AND tp.brief IN ('Nasledie', 'Nasledie_HKF')))
           AND a.dep_name IS NOT NULL)
 ORDER BY 1
         ,2
         ,5
         ,8;

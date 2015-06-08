create or replace view ins.report_sales_dep as
select sd.universal_code "Универсальный код",
       sd.dept_name "Название подразделения",
       sd.legal_name "Юридическое название",
       sd.marketing_name "Маркетинговое название",
       sd.short_name "Краткое обозначение",
       sd.company_name "Компания",
       sd.sales_channel "Канал продаж",
       sd.initiator_name "Инициатор открытия",
       sd.local_director_name "Территориальный директор",
       sd.manager_name "Руководитель",
       sd.roo_name "Название РОО",
       sd.tap_number "ТАП",
       sd.roo_number "Номер РОО",
       sd.branch_name "Офис",
       sd.address "Адрес",
       sd.cc_code "Код центра затрат",    
       sd.kpp "КПП подразделения",
       tt.tac_number "ТАЦ",
       sd.open_date "Дата открытия",
       sd.close_date "Дата закрытия",
       sd.ver_num "Версия номер",
       sd.start_date "Дата начала"

from ins.sales_dept_header sdh,
     ins.v_sales_depts sd,
     (select tt.t_tap_header_id
              ,tc.tac_number
              ,tc.tac_name
          from ven_t_tac_to_tap       tt
              ,ven_t_tac              tc
              ,ven_t_tac_header       tch
         where tt.t_tac_id = tc.t_tac_id
           and tc.t_tac_id = tch.last_tac_id
           and tt.end_date = pkg_tac.get_default_end_date
      ) tt
where sdh.last_sales_dept_id = sd.sales_dept_id
      and sd.t_tap_header_id = tt.t_tap_header_id (+);

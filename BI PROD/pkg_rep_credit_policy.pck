CREATE OR REPLACE PACKAGE pkg_rep_credit_policy IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 26.06.2014 18:17:08
  -- Purpose : Печать кредитных договоров

  gv_datas    plpdf_type.t_row_datas; -- Array of datas
  gv_borders  plpdf_type.t_row_borders; -- Array of borders
  gv_widths   plpdf_type.t_row_widths; -- Array of widths
  gv_aligns   plpdf_type.t_row_aligns; -- Array of aligns
  gv_styles   plpdf_type.t_row_styles; -- Array of styles
  gv_maxlines plpdf_type.t_row_maxlines; -- Array of max lines

  -- Полис для продуктов Евросиба
  -- 365957: Анкета на настройку продукта для ЕВросиб
  -- Доброхотова И., ноябрь, 2014  
  PROCEDURE rep_evrosib
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Полис "ЕКБ CR50_3"
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_503_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Полис Полис по продуктам CR50_5/CR50_6
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_5056_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Полис "ЕКБ CR50_7/CR50_8/CR50_9"
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_50789_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Полис продукта ТКБ
  -- 339295 - Анкета на настройку продукта ТКБ
  -- Доброхотова, декабрь, 2014
  PROCEDURE rep_tkb
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /** 
  * Форма счета для ТКБ
  * @task 404551
  * @author Капля П.
  */
  PROCEDURE rep_tkb_payment_doc
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --РБР CR122
  PROCEDURE rep_rbr
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --Рольф СК103%
  PROCEDURE rep_rolf_2015
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Ирбис CR123%
  -- 397365: Ирбис настройка продуктов
  -- Доброхотова И., март, 2014
  PROCEDURE rep_irbis
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Автодом БМВ
  -- CR107_8  - CR107_8 БМВ Базовая 
  -- CR107_9  - CR107_9 БМВ Спешл
  -- CR107_10 - CR107_10 БМВ Премиум
  PROCEDURE rep_avtodom_bmw
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- Полис Автодом Автокредит
  -- CR107_11  - Автокредит 2 риска
  -- CR107_12 - Автокредит 3 риска
  -- CR107_13 - Автокредит 4 риска
  PROCEDURE rep_avtodom_avtocredit
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

END pkg_rep_credit_policy;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_credit_policy IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := $$PLSQL_UNIT;

  gv_chapter_num PLS_INTEGER := 0;

  gv_default_height NUMBER := 4;

  TYPE t_states IS TABLE OF VARCHAR2(32676) INDEX BY PLS_INTEGER;

  -- Город подписания Договора
  FUNCTION get_city_name RETURN VARCHAR2 IS
    v_city_name VARCHAR2(255);
  BEGIN
    SELECT a.province_type || '. ' || a.province_name
      INTO v_city_name
      FROM contact            c
          ,cn_contact_address ca
          ,cn_address         a
          ,t_address_type     tat
     WHERE 1 = 1
       AND ca.contact_id = c.contact_id
       AND a.id = ca.adress_id
       AND tat.id = ca.address_type
       AND c.contact_id = pkg_app_param.get_app_param_u('WHOAMI')
       AND tat.brief = 'LEGAL'
       AND rownum = 1
     ORDER BY nvl(ca.is_default, 0) DESC;
  
    RETURN v_city_name;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN '';
  END get_city_name;

  PROCEDURE set_font
  (
    par_size        NUMBER DEFAULT NULL
   ,par_style       VARCHAR2 DEFAULT NULL
   ,par_color       plpdf_type.t_color DEFAULT pkg_rep_plpdf.gc_color_black
   ,par_font_family VARCHAR2 DEFAULT pkg_rep_plpdf.gc_times_font_family
  ) IS
  BEGIN
    pkg_rep_plpdf.set_font(par_size        => par_size
                          ,par_style       => par_style
                          ,par_color       => par_color
                          ,par_font_family => par_font_family);
  END set_font;

  PROCEDURE print_header
  (
    par_policy_id       p_policy.policy_id%TYPE
   ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
   ,par_title           VARCHAR2 DEFAULT 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ КРЕДИТА     № '
   ,par_policyform_note VARCHAR2 DEFAULT 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита'
  ) IS
    l_text    VARCHAR2(500);
    v_barcode VARCHAR2(25);
  BEGIN
    v_barcode := pkg_rep_plpdf.get_barcode_for_policy(par_policy_id => par_policy_id);
  
    IF v_barcode IS NOT NULL
    THEN
      set_font(par_size        => 28
              ,par_style       => pkg_rep_plpdf.gc_style_regular
              ,par_font_family => pkg_rep_plpdf.gc_barcode_font_family_code39);
      plpdf.printcell(p_h => -1, p_txt => v_barcode, p_align => 'R', p_ln => 1);
    END IF;
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_txt      => par_title || par_policy_summary.pol_num
                            ,p_border   => 'LRT'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 1);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_txt      => par_policyform_note
                            ,p_border   => 'LRB'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 1);
  
    l_text := get_city_name;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => plpdf.gettextwidth(l_text) + 10
                   ,p_txt      => l_text
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => pkg_rep_utils.date_to_genitive_case(par_policy_summary.start_date) ||
                                  ' г.'
                   ,p_align    => 'R'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
  END print_header;

  PROCEDURE print_insurer IS
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => gv_chapter_num || '. СТРАХОВЩИК:'
                   ,p_border   => 'LRT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_txt      => pkg_contact_rep_utils.get_insurer_info(par_mask => pkg_contact_rep_utils.gc_company_nameaddr)
                            ,p_border   => 'LRT'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 1);
  
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_txt      => pkg_contact_rep_utils.get_insurer_info(par_mask => pkg_contact_rep_utils.gc_company_default_billing || ',' ||
                                                                                              pkg_contact_rep_utils.gc_company_def_phones || ',' ||
                                                                                              pkg_contact_rep_utils.gc_company_website)
                            ,p_border   => 'LRB'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 1);
  
  END print_insurer;

  PROCEDURE print_insuree(par_insuree_info pkg_rep_plpdf.t_contact_summary) IS
    l_type_doc  VARCHAR2(4000);
    l_doc_num   VARCHAR2(4000);
    l_doc_place VARCHAR2(4000);
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                   ,p_border   => 'LRT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => 'Фамилия'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.name
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 60
                            ,p_txt      => '          Дата рождения'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => 'Имя'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.first_name
                   ,p_align    => 'C'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_border   => '1'
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 60
                   ,p_txt      => '          Документ, удостоверяющий личность'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    /*Заполняем паспортные данные только при наличии паспорта (модифицировано 28.04.2014 Черных М.Г. исправлено no_data_found)*/
    IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
    THEN
      l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#TYPE_DESC>');
      l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#DOC_SERNUM>');
      l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
    
    END IF; /*конец модификации 28.04.2014*/
  
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 50
                            ,p_txt      => l_type_doc
                            ,p_align    => 'C'
                            ,p_border   => '1'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => 'Отчество'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.middle_name
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_h        => -1
                   ,p_w        => 60
                   ,p_txt      => NULL
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 50
                            ,p_txt      => l_doc_num
                            ,p_align    => 'C'
                            ,p_border   => '1'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_w        => plpdf.getpagespace - 5
                   ,p_txt      => l_doc_place
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'Кем и когда выдан'
                   ,p_align    => 'C'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => 'Адрес'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 85
                   ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                            ,par_brief      => 'CONST')
                                                                           ,'<#ADDRESS_FULL>')
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                         ,'<#EMAIL_LOWER>')
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
  END print_insuree;

  PROCEDURE print_period(par_policy_summary pkg_rep_plpdf.t_policy_summary) IS
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => gv_chapter_num || '. СРОК ДЕЙСТВИЯ ДОГОВОРА СТРАХОВАНИЯ:'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => ROUND(MONTHS_BETWEEN(par_policy_summary.end_date
                                                      ,par_policy_summary.start_date)) || ' месяцев'
                   ,p_w        => 50
                   ,p_border   => 'LBT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 25
                   ,p_txt      => 'с ' || to_char(par_policy_summary.start_date, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => 'BT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 25
                   ,p_txt      => 'по ' || to_char(par_policy_summary.end_date, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => 'BT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'TBR', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
  END print_period;

  /*
  вторые два параметра нужны при изменении размера шрифта
  */
  PROCEDURE print_currency
  (
    par_policy_summary pkg_rep_plpdf.t_policy_summary
   ,par_box_size       NUMBER DEFAULT 2
   ,par_box_delta_y    NUMBER DEFAULT 1
  ) IS
    v_text VARCHAR2(500);
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    v_text := gv_chapter_num || '. ВАЛЮТА ДОГОВОРА:';
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => v_text
                   ,p_w        => plpdf.gettextwidth(v_text) + 5
                   ,p_border   => 'LTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    FOR rec IN (SELECT f.name
                      ,nvl2(lead(1) over(ORDER BY f.fund_id DESC), 0, 1) is_last
                      ,decode(f.brief
                             ,par_policy_summary.fund_brief
                             ,pkg_rep_plpdf.gc_rect_marked
                             ,pkg_rep_plpdf.gc_rect_unmarked) marked
                  FROM t_product       p
                      ,t_prod_currency pc
                      ,fund            f
                 WHERE p.product_id = pc.product_id
                   AND pc.currency_id = f.fund_id
                   AND p.product_id = par_policy_summary.product_id
                 ORDER BY /*pc.is_default DESC NULLS LAST,*/ f.fund_id DESC)
    LOOP
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + par_box_delta_y --1
                    ,p_w     => par_box_size --2
                    ,p_h     => par_box_size --2
                    ,p_style => rec.marked);
    
      plpdf.printcell(p_border   => 'TB'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => plpdf.gettextwidth(rec.name) + 5
                     ,p_txt      => rec.name
                     ,p_border   => 'TB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    END LOOP;
  
    plpdf.printcell(p_ln => 1, p_border => 'BTR', p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
  END print_currency;

  PROCEDURE print_territory IS
    v_text VARCHAR2(500);
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    v_text := gv_chapter_num || '. ТЕРРИТОРИЯ И ВРЕМЯ ДЕЙСТВИЯ СТРАХОВОЙ ЗАЩИТЫ:';
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => v_text
                   ,p_w        => plpdf.gettextwidth(v_text) + 5
                   ,p_border   => 'LTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'ВЕСЬ МИР, 24 ЧАСА В СУТКИ'
                   ,p_border   => 'RTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
  END print_territory;

  PROCEDURE print_declaration
  (
    par_declaration_states  t_states
   ,par_declaration_states2 t_states
   ,par_print_subindex      BOOLEAN DEFAULT TRUE
  ) IS
    v_str VARCHAR2(32767);
  BEGIN
  
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => gv_chapter_num || '. ДЕКЛАРАЦИЯ СТРАХОВАТЕЛЯ/ЗАСТРАХОВАННОГО:'
                   ,p_border   => 'LRT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'Настоящим Страхователь/Застрахованный заявляет, что он:'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
  
    FOR i IN 1 .. par_declaration_states.count
    LOOP
      IF par_print_subindex
      THEN
        v_str := gv_chapter_num || '.' || i || ' ' || par_declaration_states(i);
      ELSE
        v_str := par_declaration_states(i);
      
      END IF;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => v_str
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_ln       => 1
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    END LOOP;
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'Да, я могу подписать настоящую Декларацию и заявляю:'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
  
    FOR i IN 1 .. par_declaration_states2.count
    LOOP
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => par_declaration_states2(i)
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END LOOP;
  END print_declaration;

  PROCEDURE print_additional_conditions(par_add_cond_states t_states) IS
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h      => -1
                   ,p_txt    => gv_chapter_num || '. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ:'
                   ,p_border => 'LTR'
                   ,p_ln     => 1);
  
    set_font;
    FOR i IN 1 .. par_add_cond_states.count
    LOOP
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => gv_chapter_num || '.' || i || ' ' ||
                                             par_add_cond_states(i)
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END LOOP;
  END print_additional_conditions;

  PROCEDURE print_sign
  (
    par_report_exe_name rep_report.exe_name%TYPE
   ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
  ) IS
    v_signer pkg_report_signer.typ_signer;
  BEGIN
  
    v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
  
    IF par_policy_summary.policy_status_desc NOT IN
       ('Ожидает подтверждения из B2B', 'Проект')
    THEN
      plpdf.putimage(p_name => 'image_sign_jpg'
                    ,p_data => v_signer.image_sign_jpg
                    ,p_x    => plpdf.getpagespace - 5 - 45
                    ,p_y    => plpdf.getcurrenty
                    ,p_w    => 45
                    ,p_h    => 50);
    END IF;
  
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 3;
    pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    pkg_rep_plpdf.gv_widths(3) := pkg_rep_plpdf.gv_widths(1);
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_bold;
  
    pkg_rep_plpdf.gv_borders(1) := 'LTR';
    pkg_rep_plpdf.gv_borders(2) := 'LTR';
    pkg_rep_plpdf.gv_borders(3) := 'LTR';
  
    pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
    pkg_rep_plpdf.gv_datas(2) := 'Застрахованный';
    pkg_rep_plpdf.gv_datas(3) := 'Страховщик';
  
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_datas(1) := NULL;
    pkg_rep_plpdf.gv_datas(2) := NULL;
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_borders(1) := 'LR';
    pkg_rep_plpdf.gv_borders(2) := 'LR';
    pkg_rep_plpdf.gv_borders(3) := 'LR';
  
    FOR i IN 1 .. 3
    LOOP
      pkg_rep_plpdf.row_print2;
    END LOOP;
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
  
    pkg_rep_plpdf.gv_datas(1) := 'Полисные условия по программе страхования жизни и здоровья Заёмщиков кредита  получил(а), ознакомлен(а) в полном объёме и согласен(на).';
    pkg_rep_plpdf.gv_datas(2) := 'С назначением Выгодоприобретателей согласен(на)';
    pkg_rep_plpdf.gv_datas(3) := 'Представитель по доверенности ' || v_signer.short_name || chr(13) ||
                                 '(дов №' || v_signer.procuratory_num || ')';
  
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_datas(1) := NULL;
    pkg_rep_plpdf.gv_datas(2) := NULL;
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_styles(1) := NULL;
    pkg_rep_plpdf.gv_styles(2) := NULL;
    pkg_rep_plpdf.gv_styles(3) := NULL;
  
    pkg_rep_plpdf.row_print2;
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
  
    pkg_rep_plpdf.gv_datas(1) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
    pkg_rep_plpdf.gv_datas(2) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_borders(1) := 'LBR';
    pkg_rep_plpdf.gv_borders(2) := 'LBR';
    pkg_rep_plpdf.gv_borders(3) := 'LBR';
  
    pkg_rep_plpdf.row_print2;
  
  END print_sign;

  PROCEDURE print_footer IS
    v_current_page INTEGER;
    v_text         VARCHAR2(255);
  BEGIN
    set_font;
    v_current_page := plpdf.currentpagenumber;
  
    v_text := 'стр.  ' || to_char(v_current_page) || ' из {nb}';
  
    plpdf.printcell(p_txt        => v_text
                   ,p_border     => 0
                   ,p_align      => 'C'
                   ,p_ln         => 0
                   ,p_h          => 5
                   ,p_vert_align => 'B');
  
  END print_footer;

  -- Полис для продуктов Евросиба
  -- 365957: Анкета на настройку продукта для ЕВросиб
  -- Доброхотова И., ноябрь, 2014  
  PROCEDURE rep_evrosib
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_evrosib';
  
    PROCEDURE print_insuree_custom(par_insuree_info pkg_rep_plpdf.t_contact_summary) IS
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => plpdf.getpagespace - 5
                     ,p_txt      => l_doc_place
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Кем и когда выдан'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Адреc'
                     ,p_w        => plpdf.getpagespace
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      --Отступ
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 110
                     ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                              ,par_brief      => 'CONST')
                                                                             ,'<#ADDRESS_FULL>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                           ,'<#EMAIL_LOWER>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      --Подпись к строке адреса                 
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 20
                     ,p_txt      => 'Индекс'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    END print_insuree_custom;
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски программа страхования';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия (взнос)';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height - 1);
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(5) := 'J';
    
      FOR rec_product_lines IN (SELECT (CASE
                                         WHEN plo.brief = 'TERM_2' THEN
                                          pl.description || ' (далее "Смерть ЛП"**)'
                                         WHEN plo.brief = 'ANY_1_GR' THEN
                                          pl.description || ' (далее "Инвалидность")'
                                         WHEN plo.brief = 'ATD_Any' THEN
                                          pl.description || ' (далее "ВНТ ЛП")'
                                       END) public_description
                                      ,pkg_rep_utils.to_money_sep(pc.ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(pc.fee) fee
                                      , (CASE
                                          WHEN plo.brief IN ('TERM_2', 'ANY_1_GR') THEN
                                           '100% от страховой суммы'
                                          WHEN plo.brief = 'ATD_Any' THEN
                                           '1/30  (одна  тридцатая)  от  размера  ежемесячного  платежа 
Застрахованного  по  кредиту,  в  соответствии  с  графиком 
платежей  по  Кредитному  договору  за  каждый  день 
нетрудоспособности  календарного  месяца,  начиная  с  31-го 
(тридцать  первого)  дня  временно  нетрудоспособности,  но  не 
более, чем за 180 (сто восемьдесят) дней нетрудоспособности 
по  одному  страховому  случаю  и  не  более  чем  за  360  (триста 
шестьдесят) дней  за весь срок страхования по всем страховым 
случаям и не более 50 000(пятьдесят тысяч) рублей в месяц.'
                                        END) note
                                      ,row_number() over(ORDER BY plt.sort_order, pl.sort_order) rn
                                  FROM p_cover             pc
                                      ,as_asset            aa
                                      ,t_prod_line_option  plo
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                 WHERE aa.p_policy_id = v_policy_id
                                   AND aa.as_asset_id = pc.as_asset_id
                                   AND pc.t_prod_line_option_id = plo.id
                                   AND plo.product_line_id = pl.id
                                   AND pl.product_line_type_id = plt.product_line_type_id
                                 ORDER BY plt.sort_order
                                         ,pl.sort_order)
      LOOP
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := gv_chapter_num || '.' || rec_product_lines.rn || ' ' ||
                                     rec_product_lines.public_description;
        pkg_rep_plpdf.gv_datas(3) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(6) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height - 1);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height - 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ: '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => '*  Страховая сумма по  рискам «Смерть ЛП» и «Инвалидность» равна размеру первоначальной суммы кредита по кредитному договору на 
момент  его  заключения.  В  течение  действия  договора  страхования  страховая  сумма  уменьшается  в  соответствии  с  первоначальным 
графиком платежей и равна ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком 
платежей.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => 'Страховая сумма по рискам «ВНТ ЛП» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент 
его заключения.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => '** Любая причина - событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при 
условии, что к моменту самоубийства договор страхования действовал не менее двух лет.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END print_programs_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              , p_txt      => gv_chapter_num ||
                                              '.1. Первым Выгодоприобретателем по страховым рискам «Смерть  ЛП» и «Инвалидность» настоящего Договора,   в доле, равной размеру 
фактической  задолженности  Застрахованного  по  кредиту,  но  не  более  суммы  страховой  выплаты  является: 
____________________________________________________________________________________________________________________________'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              , p_txt      => gv_chapter_num ||
                                              '.2.  Выгодоприобретателями   по  страховому  риску   «Смерть  ЛП»  в  доле,  оставшейся  после  исполнения  обязательств  по   страховой 
выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего Договора, являются следующие лица: наследники по Закону; '
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              , p_txt      => gv_chapter_num ||
                                              '.3.  Выгодоприобретателем  по  страховому  риску  «Инвалидность»  в  доле,  оставшейся  после  исполнения  обязательств  по  страховой 
выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего Договора, является  Застрахованный;'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             '.4. Выгодоприобретателем по риску «ВНТ ЛП» является Застрахованный.'
                              ,p_border   => 'LRB'
                              ,p_ln       => 1);
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие 
движение;  НЕ  страдает  мышечной  дистрофией,  нервными  расстройствами,  психическими  заболеваниями;  НЕ  употребляет  наркотики, 
токсические вещества, НЕ страдает алкоголизмом, и/или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями,
ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия 
и  т.д.;';
      v_declaration_states(2) := 'НЕ  находится  в  изоляторе  временного  содержания  или  других  учреждениях,  предназначенных  для  содержания  лиц, 
подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 
7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный 
диабет,  гемофилия,  сердечнососудистая  патология  (включая  ишемическую  болезнь  сердца,  аритмии  (включая  мерцательную  аритмию), 
гипертонию (II-IV  степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), 
цирроз  печени,  хронический  гепатит,  злокачественные  или  доброкачественные  опухоли,  туберкулез,  а  также  иными  хроническими 
заболеваниями,  требующими  постоянных  консультаций,  лечения,  обследований  или  наблюдения;';
      v_declaration_states(4) := 'За  последние  2  (два)  года  НЕ находился(-ась)  на  больничном  листе  сроком  3  (три)  недели  подряд  и  более  (счет  по  каждому  году,  не  учитывая  острую  респираторную 
инфекцию, грипп, травмы, не требующие долгосрочной госпитализации и не связанные с жизнью) и/или НЕ был направлен на стационарное 
лечение  (в  том  числе,  если   лечение   связано  с  заболеваниями,  влекущими  получение  инвалидности),  или  за  последние  12  месяцев  НЕ 
обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий  момент  НЕ  находится  под  наблюдением  врача,  на  лечении,  НЕ  принимает  лекарства  в  связи  с  каким-либо  заболеванием 
(нарушением  здоровья)  или  в  отношении  него/нее  НЕ  запланировано  лечение/операция  и  он/она  НЕ  планирует  обратиться  к  врачу  по 
причине  какого-либо  заболевания  в  ближайшее  время   за  исключением  обращений  к  стоматологу  и/или  прохождения  периодических 
осмотров,  в  течение  ближайшего  месяца  с  момента  подписания  настоящей  Декларации;';
      v_declaration_states(6) := 'НЕ  связан(-а)  с  особым  риском  в  связи  с 
трудовой  деятельностью  (например:  облучение,  работа  с  химическими  и  взрывчатыми  веществами,  источниками  повышенной  опасности, 
работа  на  высоте,  под  землей,  под  водой,  на  нефтяных  и  газовых  платформах,  с  оружием,  в  правоохранительных  органах,  инкассаци я, 
испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами 
увлечений  (хобби);';
      v_declaration_states(7) := 'НЕ  подавал(-а)  заявления  на  страхование  жизни,  страхование  от  несчастных  случаев  и  болезней,  утраты 
трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых 
условиях  (с  применением  повышающих  коэффициентов,  исключений  или  особых  условий),  а  также  заключенных  договоров  страхования, 
которые  были  расторгнуты  по  причине  невозможности  заключения  или  существенные  условия  которых  были  изменены  по   результатам 
оценки степени риска;';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного 
не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, декларацию можно подписать; рост 160 см, вес 85 кг, 
разница - 75 - –декларацию подписать нельзя).';
      v_declaration_states(9) := 'Не является иностранным/российским публичным должностным лицом.';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих 
утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может 
повлечь отказ в страховой выплате; что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоро в 
страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого рис ка в
сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 4 000 000 (четыре миллиона) рублей; что я 
уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультаци и, 
лечение и т.д.), предоставлять по требованию страховой компании ООО «СК «Ренессанс Жизнь» копии медицинских документов 
(результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оц енкой 
степени страхового риска, так и в связи со страховыми случаями по данному договору страхования; что я обязуюсь незамедлительно 
письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение 
степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, 
что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию 
и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты 
по нему будут невозможны; что я прочел(-ла), понял(-а) и согласен(-на) с «Полисными условиями страхования жизни и здоровья заемщиков 
кредита».';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    
    END print_declaration_custom;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все  письменные  заявления  Страхователя,  относящиеся  к  настоящему  Договору,  а  также  все 
Приложения  и  дополнения  к  настоящему  Договору,  являются  его  составной  и  неотъемлемой  частью.';
      v_add_cond_states(2) := 'Стороны  признают  равную 
юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с 
использованием  клише)  в  настоящем  Договоре,  а  также  во  всех  Приложениях  и  дополнительных  соглашениях  к  нему.';
      v_add_cond_states(3) := 'Подписывая 
настоящий  Договор,  Страхователь  в  соответствии  c  Федеральным  законом  от  27  июля  2006  г.  №  152-ФЗ  «О  персональных  данных» 
предоставлять  страховой  компании  ООО  «СК  «Ренессанс  Жизнь»  согласие  на  обработку,  в  том  числе  передачу  Агенту  по  Агентскому 
договору,  перестраховочным  организациям  (в  том  числе  находящимся  за  рубежом)  своих  персональных  данных,  в  том  числе  данных  о 
состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём 
осуществления  прямых  контактов  с  помощью  средств  связи,  в  том  числе  в  целях  заключения  между  Страхователем  и  Страховщиком 
договора страхования. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в 
течение  15  лет  после  окончания  срока  действия  настоящего  Договора  и  может  быть  отозвано  Страхователем  (Застрахованным)  в  любой 
момент  времени  путем  передачи  Страховщику  подписанного  Страхователем  (Застрахованным)  письменного  уведомления.';
      v_add_cond_states(4) := 'В  случае отказа Страхователя от договора страховая, премия не возвращается Страхователю.';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
  BEGIN
    gv_default_height := 4;
    v_policy_id       := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализаци
    pkg_rep_plpdf.init(par_default_font_size => 8);
    -- Надпись Черновик    
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    plpdf.newpage;
    gv_default_height := 3;
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    gv_default_height := 4;
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
              ,par_policy_summary  => v_pol_sum);
  
    -- Надпись Черновик          
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_evrosib;

  PROCEDURE print_header_ekb
  (
    par_policy_id      p_policy.policy_id%TYPE
   ,par_policy_summary pkg_rep_plpdf.t_policy_summary
  ) IS
    l_text    VARCHAR2(500);
    v_barcode VARCHAR2(25);
  BEGIN
    BEGIN
      v_barcode := pkg_rep_plpdf.get_barcode_for_policy(par_policy_id => par_policy_id);
    
      IF v_barcode IS NOT NULL
      THEN
        set_font(par_size        => 28
                ,par_style       => pkg_rep_plpdf.gc_style_regular
                ,par_font_family => pkg_rep_plpdf.gc_barcode_font_family_code39);
        plpdf.printcell(p_h => -1, p_txt => v_barcode, p_align => 'R', p_ln => 1);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold, par_size => 8);
    plpdf.printcell(p_h => gv_default_height
                    --                     ,p_w   => 200
                   ,p_txt => 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ КРЕДИТА     № ' ||
                             par_policy_summary.pol_num
                    --                     ,p_border   => 'LRT'
                    --                     ,p_align    => 'R'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    plpdf.printcell(p_h   => gv_default_height
                   ,p_txt => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита, утвержденных 20.02.2012'
                    --                     ,p_border   => 'LRB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    l_text := get_city_name;
    plpdf.printcell(p_h   => gv_default_height
                   ,p_w   => plpdf.gettextwidth(l_text) + 10
                   ,p_txt => l_text
                    --                     ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    plpdf.printcell(p_h     => gv_default_height
                   ,p_txt   => pkg_rep_utils.date_to_genitive_case(par_policy_summary.start_date) ||
                               ' г.'
                   ,p_align => 'R'
                    --                     ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
  END print_header_ekb;

  PROCEDURE print_insuree_ekb
  (
    par_insuree_info pkg_rep_plpdf.t_contact_summary
   ,par_pol_sum      pkg_rep_plpdf.t_policy_summary
  ) IS
    l_type_doc  VARCHAR2(4000);
    l_doc_num   VARCHAR2(4000);
    l_doc_place VARCHAR2(4000);
    v_yes       VARCHAR2(2);
    v_no        VARCHAR2(2);
  BEGIN
    gv_chapter_num := gv_chapter_num + 1;
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                   ,p_border   => 'LT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_txt      => 'Тип кредита: потребительский '
                   ,p_w        => 50
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_txt      => 'Кредитный договор № '
                   ,p_w        => 30
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_txt      => par_pol_sum.credit_account_number
                   ,p_w        => 20
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    set_font;
    plpdf.printcell(p_txt      => ' от '
                   ,p_w        => 6
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_txt => to_char(par_pol_sum.start_date, 'dd.mm.yyyy')
                    -- ,p_w        => 20
                   ,p_ln       => 1
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_border   => 'R');
  
    set_font;
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => 'Фамилия'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                    /*,p_vert_align => 'T'*/);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.name
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 60
                            ,p_txt      => '          Дата рождения'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => 'Имя'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                    /*,p_vert_align => 'T'*/);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.first_name
                   ,p_align    => 'C'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_border   => '1'
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 60
                   ,p_txt      => '          Документ, удостоверяющий личность'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    /*Заполняем паспортные данные только при наличии паспорта (модифицировано 28.04.2014 Черных М.Г. исправлено no_data_found)*/
    IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
    THEN
      l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#TYPE_DESC>');
      l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#DOC_SERNUM>');
      l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
    
    END IF; /*конец модификации 28.04.2014*/
  
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 50
                            ,p_txt      => l_type_doc
                            ,p_align    => 'C'
                            ,p_border   => '1'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => 'Отчество'
                   ,p_w        => 25
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                    /*,p_vert_align => 'T'*/);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 50
                   ,p_txt      => par_insuree_info.middle_name
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_h        => -1
                   ,p_w        => 60
                   ,p_txt      => NULL
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printmultilinecell(p_h        => gv_default_height
                            ,p_w        => 50
                            ,p_txt      => l_doc_num
                            ,p_align    => 'C'
                            ,p_border   => '1'
                            ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                            ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font;
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell( /*p_h        => -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           ,*/p_w        => plpdf.getpagespace - 5
                   ,p_txt      => l_doc_place
                   ,p_align    => 'C'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'Кем и когда выдан'
                   ,p_align    => 'C'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => 'Адрес'
                   ,p_w        => 15
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 95
                   ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                            ,par_brief      => 'CONST')
                                                                           ,'<#ADDRESS_FULL>')
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                         ,'<#EMAIL_LOWER>')
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    --Подпись к строке адреса            
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => ''
                   ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_h   => gv_default_height
                   ,p_w   => 25
                   ,p_txt => 'Индекс'
                    --                     ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'L');
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 40
                   ,p_txt      => 'город, улица, дом'
                   ,p_border   => '0'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 40
                   ,p_txt      => 'телефон'
                   ,p_border   => '0'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => 'e-mail'
                   ,p_border   => '0'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    --    plpdf.setcolor4filling(p_color => pkg_rep_plpdf.gc_color_black);
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => 'Является ли Страхователь Иностранным публичным должностным лицом?'
                   ,p_w        => 100
                   ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    IF par_insuree_info.is_public_contact = 1 /*Публичное лицо*/
    THEN
      v_yes := 'DF'; --залит черным цветом
      v_no  := 'D'; --без заливки
    ELSE
      v_yes := 'D';
      v_no  := 'DF';
    END IF;
    plpdf.drawrect(p_x     => plpdf.getcurrentx
                  ,p_y     => plpdf.getcurrenty + 0.5
                  ,p_w     => 1.5
                  ,p_h     => 1.5
                  ,p_style => v_yes);
    plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'ДА'
                   ,p_w        => 15
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.drawrect(p_x     => plpdf.getcurrentx
                  ,p_y     => plpdf.getcurrenty + 0.5
                  ,p_w     => 1.5
                  ,p_h     => 1.5
                  ,p_style => v_no);
    plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'НЕТ'
                   ,p_w        => 15
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_border => 'R', p_ln => 1);
  
  END print_insuree_ekb;

  PROCEDURE print_sign_ekb
  (
    par_report_exe_name rep_report.exe_name%TYPE
   ,par_insuree_info    pkg_rep_plpdf.t_contact_summary
   ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
  ) IS
    v_signer pkg_report_signer.typ_signer;
    --    v_assured_info pkg_rep_plpdf.t_contact_summary;
  BEGIN
  
    v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
    --    v_assured_info := pkg_rep_plpdf.get_contact_summary(par_policy_summary.assured_array(1));
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
  
    IF par_policy_summary.policy_status_desc NOT IN
       ('Ожидает подтверждения из B2B', 'Проект')
    THEN
      plpdf.putimage(p_name => 'image_sign_jpg'
                    ,p_data => v_signer.image_sign_jpg
                    ,p_x    => plpdf.getpagespace - 5 - 30 -- - 45
                    ,p_y    => plpdf.getcurrenty - 5
                    ,p_w    => 40 --45
                    ,p_h    => 45 --50
                     );
    END IF;
  
    pkg_rep_plpdf.delete_row_print_cache;
  
    pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 3;
    pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    pkg_rep_plpdf.gv_widths(3) := pkg_rep_plpdf.gv_widths(1);
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_bold;
  
    pkg_rep_plpdf.gv_borders(1) := 'LTR';
    pkg_rep_plpdf.gv_borders(2) := 'LTR';
    pkg_rep_plpdf.gv_borders(3) := 'LTR';
  
    pkg_rep_plpdf.gv_datas(1) := 'СТРАХОВАТЕЛЬ';
    pkg_rep_plpdf.gv_datas(2) := 'ЗАСТРАХОВАННЫЙ';
    pkg_rep_plpdf.gv_datas(3) := 'СТРАХОВЩИК';
    pkg_rep_plpdf.row_print2(par_h => gv_default_height);
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
  
    pkg_rep_plpdf.gv_borders(1) := 'LR';
    pkg_rep_plpdf.gv_borders(2) := 'LR';
    pkg_rep_plpdf.gv_borders(3) := 'LR';
  
    pkg_rep_plpdf.gv_datas(1) := '"Полисные условия" по программе страхования жизни и здоровья Заёмщиков кредита  получил(а), ознакомлен(а) в полном объёме и согласен(на).';
    pkg_rep_plpdf.gv_datas(2) := 'С назначением Выгодоприобретателей согласен(на)';
    pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || 'по дов. ' ||
                                 v_signer.procuratory || chr(13) || v_signer.name;
  
    pkg_rep_plpdf.row_print2(par_h => gv_default_height);
  
    pkg_rep_plpdf.gv_datas(1) := NULL;
    pkg_rep_plpdf.gv_datas(2) := NULL;
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_styles(1) := NULL;
    pkg_rep_plpdf.gv_styles(2) := NULL;
    pkg_rep_plpdf.gv_styles(3) := NULL;
  
    FOR i IN 1 .. 5
    LOOP
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    END LOOP;
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
  
    pkg_rep_plpdf.gv_datas(1) := '                         ' || par_insuree_info.fio_initials;
    pkg_rep_plpdf.gv_datas(2) := '                         ' || par_insuree_info.fio_initials;
    pkg_rep_plpdf.gv_datas(3) := NULL;
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_datas(1) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
    pkg_rep_plpdf.gv_datas(2) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_borders(1) := 'LBR';
    pkg_rep_plpdf.gv_borders(2) := 'LBR';
    pkg_rep_plpdf.gv_borders(3) := 'LBR';
    pkg_rep_plpdf.row_print2;
  
  END print_sign_ekb;

  -- Полис "ЕКБ CR50_3"
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_503_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    --    v_assured_array t_number_type;
  
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_ekb_503_policy';
  
    PROCEDURE print_insuree_custom IS
      v_yes     VARCHAR2(2);
      v_no      VARCHAR2(2);
      v_x_start NUMBER;
      v_y_start NUMBER;
      v_x_end   NUMBER;
      v_y_end   NUMBER;
    BEGIN
      v_x_start := plpdf.getcurrentx;
      v_y_start := plpdf.getcurrenty;
    
      print_insuree(par_insuree_info => v_insuree_info);
      --      print_insuree_ekb(par_insuree_info => v_insuree_info);
    
      v_x_end := plpdf.getcurrentx;
      v_y_end := plpdf.getcurrenty;
    
      -- в существующий блок вставляем доп.данные
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => 'Тип кредита: потребительский '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => 'Кредитный договор № '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' от '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => 'Индекс'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcolor4filling(p_color => pkg_rep_plpdf.gc_color_black);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => 'Является ли Страхователь Иностранным публичным должностным лицом?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 /*Публичное лицо*/
      THEN
        v_yes := 'DF'; --залит черным цветом
        v_no  := 'D'; --без заливки
      ELSE
        v_yes := 'D';
        v_no  := 'DF';
      END IF;
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_yes);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ДА'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_no);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'НЕТ'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Срок действи Договора равен сроку действия Кредитного договора, указанного в Разделе 2.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
      --      v_no        VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски "Жизнь бэджетника + Потеря работы"';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия (взнос)';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 5;
      pkg_rep_plpdf.gv_widths(3) := 55;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 30;
      pkg_rep_plpdf.gv_widths(6) := 78;
      pkg_rep_plpdf.gv_widths(7) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := '1';
      pkg_rep_plpdf.gv_borders(7) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'L';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'J';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
      pkg_rep_plpdf.gv_maxlines(7) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,row_number() over(ORDER BY plt_sort_order, product_line_sort_order) || '. ' || t_product_line_desc || '*' product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                  FROM (SELECT ppl.t_product_line_desc
                                              ,plo.id                  prod_line_option_id
                                              ,plt.sort_order          plt_sort_order
                                              ,pl.sort_order           product_line_sort_order
                                              ,pl.note
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY plt_sort_order
                                         ,product_line_sort_order
                                /*SELECT pl.public_description
                                      ,pkg_rep_utils.to_money_sep(pc.ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(pc.fee) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY plt.sort_order, pl.sort_order) rn
                                 FROM p_cover             pc
                                      ,as_asset            aa
                                      ,t_prod_line_option  plo
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                WHERE aa.p_policy_id = v_policy_id
                                  AND aa.as_asset_id = pc.as_asset_id
                                  AND pc.t_prod_line_option_id = plo.id
                                  AND plo.product_line_id = pl.id
                                  AND pl.product_line_type_id = plt.product_line_type_id
                                ORDER BY plt.sort_order
                                         ,pl.sort_order*/
                                
                                )
      LOOP
        IF rec_product_lines.t_prod_line_option_id IS NOT NULL
        THEN
          v_yes := 'DF'; --залит черным цветом
        ELSE
          v_yes := 'D';
        END IF;
        plpdf.drawrect(p_x     => plpdf.getcurrentx + 2.5
                      ,p_y     => plpdf.getcurrenty + 0.6
                      ,p_w     => 1.5
                      ,p_h     => 1.5
                      ,p_style => v_yes);
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := NULL;
        pkg_rep_plpdf.gv_datas(3) := gv_chapter_num || '.' || rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(6) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(7) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
        /*        plpdf.row_print2(p_data       => pkg_rep_plpdf.gv_datas
        ,p_border     => pkg_rep_plpdf.gv_borders
        ,p_width      => pkg_rep_plpdf.gv_widths
        ,p_align      => pkg_rep_plpdf.gv_aligns
        ,p_style      => pkg_rep_plpdf.gv_styles
        ,p_maxline    => pkg_rep_plpdf.gv_maxlines
        ,p_clipping   => 0
        ,p_h          => 2.5
        ,p_min_height => 0);*/
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ: '
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => v_pol_sum.payment_terms
                              ,p_align    => 'J'
                              ,p_border   => 'R'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма устанавливается в соответствии с п. 7.2. Полисных условий и определяется как размер текущей ссудной задолженности Застрахованного на дату наступления страхового случая,  по Кредитному Договору, указанному в Разделе 2, и не может превышать сумму, указанную в п. 6.1. и 6.2. настоящего Договора.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END print_programs_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             'Выгодоприобретателем по страховым рискам "Смерть Застрахованного по любой причине", "Инвалидность Застрахованного I или II группы (с ограничением способности к трудовой деятельности третьей степени) по любой причине", "Дожитие Застрахованного до потери постоянной работы по независящим от него причинам"  настоящего Договора является ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ')
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ  является  инвалидом, лицом, требующим постоянного ухода;';
      v_declaration_states(2) := 'НЕ употребляет наркотики,  токсические  вещества, НЕ страдает алкоголизмом, или НЕ состоит по перечисленным причинам на диспансерном   учёте;  ';
      v_declaration_states(3) := 'НЕ   является ВИЧ-инфицированным  или  НЕ  страдает  СПИДом; ';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на  больничном  листе сроком  3 (три) недели подряд и более; В настоящий момент НЕ находится под наблюдением врача или в отношении его НЕ запланировано  лечение/операция;  ';
      v_declaration_states(5) := 'НЕ связан  с особым  риском  в связи с трудовой деятельностью (например: облучение, работа  с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под  землей, под водой, на  нефтяных и газовых платформах, с оружием, в правоохранительных органах (оперативная работа, участие в спецоперациях), инкассация, испытания и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби); ';
      v_declaration_states(6) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных  случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых мне было отказано, которые  были  отложены  или  приняты  на  особых  условиях (с применением  повышающих  коэффициентов, исключений  или особых условий), а также  заключенных Договоров страхования, которые были  расторгнуты по причине невозможности заключения или  существенные условия которых были изменены по результатам оценки степени риска.';
      v_declaration_states(7) := 'Имеет постоянную работу (постоянный источник дохода) в течение последних 12 (двенадцати) месяцев, в том числе не менее 6 (шести) месяцев на последнем месте работы,';
      v_declaration_states(8) := 'Состоит в трудовых отношениях с работодателем на основании трудового договора (за исключением трудового договора с индивидуальным частным предпринимателем), заключенного на неопределенный срок и предусматривающего занятость на полный рабочий день,';
      v_declaration_states(9) := 'Получает вознаграждения за свой труд в форме ежемесячной заработной платы; ';
      v_declaration_states(10) := 'НЕ является акционером (участником) организации работодателя;';
      v_declaration_states(11) := 'НЕ является индивидуальным частным предпринимателем; ';
      v_declaration_states(12) := 'НЕ является близким родственником руководителя работодателя (супруг(а), родитель, ребенок, усыновитель, усыновленный, родной брат, родная сестра, дедушка, бабушка, внук); ';
      v_declaration_states(13) := 'НЕ является временным, сезонным рабочим; ';
      v_declaration_states(14) := 'НЕ является временно нетрудоспособным по беременности и родам, ';
      v_declaration_states(15) := 'НЕ находится в отпуске по уходу за ребенком; ';
      v_declaration_states(16) := 'НЕ уведомлен о намерении работодателя сократить штат сотрудников или о ликвидации организации работодателя ';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате';
      v_declaration_states2(2) := 'что в отношении Застрахованного не заключены и не поданы заявления на заключение других Договоров страхования жизни и/или от несчастных случаев в ООО "СК "Ренессанс Жизнь", по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 1 500 000 (один миллион пятьсот тысяч) рублей;';
      v_declaration_states2(3) := 'что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий Договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, Договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны;';
      v_declaration_states2(4) := 'что я прочел(-ла), понял(-а) и согласен(-на) с "Полисными условиями по программе страхования жизни Заёмщиков кредита".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
      v_add_cond_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ "О персональных данных" выражает Страховщику согласие на обработку своих персональных данных, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путем осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору,  об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 5 лет после окончания срока действия настоящего Договора.';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    /*    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer       pkg_report_signer.typ_signer;
      v_assured_info pkg_rep_plpdf.t_contact_summary;
    BEGIN
    
      v_signer       := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      v_assured_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.assured_array(1));
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 3;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
      pkg_rep_plpdf.gv_widths(3) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
      pkg_rep_plpdf.gv_borders(3) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'СТРАХОВАТЕЛЬ';
      pkg_rep_plpdf.gv_datas(2) := 'ЗАСТРАХОВАННЫЙ';
      pkg_rep_plpdf.gv_datas(3) := 'СТРАХОВЩИК';
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"Полисные условия" по программе страхования жизни и здоровья Заёмщиков кредита  получил(а), ознакомлен(а) в полном объёме и согласен(на).';
      pkg_rep_plpdf.gv_datas(2) := 'С назначением Выгодоприобретателей согласен(на)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || 'по дов. ' ||
                                   v_signer.procuratory || chr(13) || v_signer.name;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      FOR i IN 1 .. 5
      LOOP
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      END LOOP;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '                         ' || v_insuree_info.fio_initials;
      pkg_rep_plpdf.gv_datas(2) := '                         ' || v_assured_info.fio_initials;
      pkg_rep_plpdf.gv_datas(3) := NULL;
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
      pkg_rep_plpdf.gv_borders(3) := 'LBR';
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;*/
  
  BEGIN
    gv_default_height := 2.5;
  
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*--Колонтитулы с номерми страниц
    plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
    plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);
    */
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_503_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                         c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- Полис Полис по продуктам CR50_5/CR50_6
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_5056_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    ---    v_assured_array t_number_type;
  
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_ekb_5056_policy';
  
    /*    PROCEDURE print_header_custom IS
      l_text    VARCHAR2(500);
      v_barcode VARCHAR2(25);
    BEGIN
      v_barcode := pkg_rep_plpdf.get_barcode_for_policy(par_policy_id => v_policy_id);
    
      IF v_barcode IS NOT NULL
      THEN
        set_font(par_size        => 28
                ,par_style       => pkg_rep_plpdf.gc_style_regular
                ,par_font_family => pkg_rep_plpdf.gc_barcode_font_family_code39);
        plpdf.printcell(p_h => -1, p_txt => v_barcode, p_align => 'R', p_ln => 1);
      END IF;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold, par_size => 8);
      plpdf.printcell(p_h => gv_default_height
                      --                     ,p_w   => 200
                     ,p_txt => 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ КРЕДИТА     № ' ||
                               v_pol_sum.pol_num
                      --                     ,p_border   => 'LRT'
                      --                     ,p_align    => 'R'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
      plpdf.printcell(p_h   => gv_default_height
                     ,p_txt => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита, утвержденных 20.02.2012'
                      --                     ,p_border   => 'LRB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      l_text := get_city_name;
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => plpdf.gettextwidth(l_text) + 10
                     ,p_txt => l_text
                      --                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_h     => gv_default_height
                     ,p_txt   => pkg_rep_utils.date_to_genitive_case(v_pol_sum.start_date) || ' г.'
                     ,p_align => 'R'
                      --                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
    END print_header_custom;*/
  
    /*    PROCEDURE print_insuree_custom IS
      v_yes     VARCHAR2(2);
      v_no      VARCHAR2(2);
      v_x_start NUMBER;
      v_y_start NUMBER;
      v_x_end   NUMBER;
      v_y_end   NUMBER;
    BEGIN
      v_x_start := plpdf.getcurrentx;
      v_y_start := plpdf.getcurrenty;
    
      print_insuree(par_insuree_info => v_insuree_info);
    
      v_x_end := plpdf.getcurrentx;
      v_y_end := plpdf.getcurrenty;
    
      -- в существующий блок вставляем доп.данные
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => 'Тип кредита: потребительский '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => 'Кредитный договор № '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' от '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => 'Индекс'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcolor4filling(p_color => pkg_rep_plpdf.gc_color_black);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => 'Является ли Страхователь Иностранным публичным должностным лицом?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 --Публичное лицо
      THEN
        v_yes := 'DF'; --залит черным цветом
        v_no  := 'D'; --без заливки
      ELSE
        v_yes := 'D';
        v_no  := 'DF';
      END IF;
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_yes);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ДА'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_no);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'НЕТ'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;*/
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Срок действи Договора равен сроку действия Кредитного договора, указанного в Разделе 2.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
      --      v_no        VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 50;
      pkg_rep_plpdf.gv_widths(3) := 40;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 20;
      pkg_rep_plpdf.gv_widths(6) := 58;
      pkg_rep_plpdf.gv_widths(7) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'C';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := 'B';
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LT';
      pkg_rep_plpdf.gv_borders(3) := 'LT';
      pkg_rep_plpdf.gv_borders(4) := 'LT';
      pkg_rep_plpdf.gv_borders(5) := 'LT';
      pkg_rep_plpdf.gv_borders(6) := 'LT';
      pkg_rep_plpdf.gv_borders(7) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски';
      pkg_rep_plpdf.gv_datas(3) := 'Срок действия';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая сумма';
      pkg_rep_plpdf.gv_datas(5) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(6) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(7) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 50;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 20;
      pkg_rep_plpdf.gv_widths(6) := 20;
      pkg_rep_plpdf.gv_widths(7) := 58;
      pkg_rep_plpdf.gv_widths(8) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'C';
      pkg_rep_plpdf.gv_aligns(7) := 'C';
      pkg_rep_plpdf.gv_aligns(8) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := 'B';
      pkg_rep_plpdf.gv_styles(7) := 'B';
      pkg_rep_plpdf.gv_styles(8) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'L';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := 'L';
      pkg_rep_plpdf.gv_borders(6) := 'L';
      pkg_rep_plpdf.gv_borders(7) := 'L';
      pkg_rep_plpdf.gv_borders(8) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := 'с';
      pkg_rep_plpdf.gv_datas(4) := 'до';
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
      pkg_rep_plpdf.gv_datas(7) := NULL;
      pkg_rep_plpdf.gv_datas(8) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 5;
      pkg_rep_plpdf.gv_widths(3) := 45;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 20;
      pkg_rep_plpdf.gv_widths(6) := 20;
      pkg_rep_plpdf.gv_widths(7) := 20;
      pkg_rep_plpdf.gv_widths(8) := 58;
      pkg_rep_plpdf.gv_widths(9) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := '1';
      pkg_rep_plpdf.gv_borders(7) := '1';
      pkg_rep_plpdf.gv_borders(8) := '1';
      pkg_rep_plpdf.gv_borders(9) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
      pkg_rep_plpdf.gv_styles(8) := NULL;
      pkg_rep_plpdf.gv_styles(9) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'L';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'C';
      pkg_rep_plpdf.gv_aligns(7) := 'C';
      pkg_rep_plpdf.gv_aligns(8) := 'J';
      pkg_rep_plpdf.gv_aligns(9) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,row_number() over(ORDER BY plt_sort_order, product_line_sort_order) || '. ' || t_product_line_desc || '*' product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                      ,pc.cover_start_date
                                      ,pc.cover_end_date
                                  FROM (SELECT CASE ppl.t_product_line_desc
                                                 WHEN 'Смерть ЛП (61-80)' THEN
                                                  'Смерть Застрахованного по любой причине'
                                                 ELSE
                                                  ppl.t_product_line_desc
                                               END t_product_line_desc
                                              ,plo.id prod_line_option_id
                                              ,plt.sort_order plt_sort_order
                                              ,pl.sort_order product_line_sort_order
                                              ,pl.note
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,to_char(pc.start_date, 'dd.mm.yyyy') cover_start_date
                                              ,to_char(trunc(pc.end_date), 'dd.mm.yyyy') cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY plt_sort_order
                                         ,product_line_sort_order
                                /*SELECT pl.public_description
                                      ,pkg_rep_utils.to_money_sep(pc.ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(pc.fee) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY plt.sort_order, pl.sort_order) rn
                                 FROM p_cover             pc
                                      ,as_asset            aa
                                      ,t_prod_line_option  plo
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                WHERE aa.p_policy_id = v_policy_id
                                  AND aa.as_asset_id = pc.as_asset_id
                                  AND pc.t_prod_line_option_id = plo.id
                                  AND plo.product_line_id = pl.id
                                  AND pl.product_line_type_id = plt.product_line_type_id
                                ORDER BY plt.sort_order
                                         ,pl.sort_order*/
                                
                                )
      LOOP
        IF rec_product_lines.t_prod_line_option_id IS NOT NULL
        THEN
          v_yes := 'DF'; --залит черным цветом
        ELSE
          v_yes := 'D';
        END IF;
        plpdf.drawrect(p_x     => plpdf.getcurrentx + 2.5
                      ,p_y     => plpdf.getcurrenty + 0.6
                      ,p_w     => 1.5
                      ,p_h     => 1.5
                      ,p_style => v_yes);
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := NULL;
        pkg_rep_plpdf.gv_datas(3) := gv_chapter_num || '.' || rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.cover_start_date;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.cover_end_date;
        pkg_rep_plpdf.gv_datas(6) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(7) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(8) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(9) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 111;
      pkg_rep_plpdf.gv_widths(2) := 20;
      pkg_rep_plpdf.gv_widths(3) := 58;
      pkg_rep_plpdf.gv_widths(4) := 1;
      --      pkg_rep_plpdf.gv_widths(5) := NULL;
      --      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      --      pkg_rep_plpdf.gv_aligns(5) := NULL;
      --      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      --      pkg_rep_plpdf.gv_styles(5) := NULL;
      --      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := 'R';
      --      pkg_rep_plpdf.gv_borders(5) := NULL;
      --      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      --      pkg_rep_plpdf.gv_datas(5) := NULL;
      --      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ: '
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => v_pol_sum.payment_terms
                              ,p_align    => 'J'
                              ,p_border   => 'R'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма устанавливается в соответствии с п. 7.2. Полисных условий и определяется как размер ссудной задолженности Застрахованного по Кредитному Договору, указанному в Разделе 2, на дату начала действия Договора страхования.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END print_programs_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             'Выгодоприобретателем по настоящему Договору страхования является  ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ')
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      /*      DECLARE
        v_product_brief t_product.brief%TYPE;
      BEGIN*/
      IF v_pol_sum.product_brief = 'CR50_5'
      THEN
        v_declaration_states(1) := 'НЕ является инвалидом I или II группы, лицом, требующим постоянного ухода;';
        v_declaration_states(2) := 'НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; ';
        v_declaration_states(3) := 'НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; ';
        v_declaration_states(4) := 'НЕ употребляет  наркотики, токсические вещества, НЕ страдает алкоголизмом, или НЕ состоит по перечисленным причинам на диспансерном учете; ';
        v_declaration_states(5) := 'НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
        v_declaration_states(6) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения;';
        v_declaration_states(7) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие госпитализации) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
        v_declaration_states(8) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время;';
        v_declaration_states(9) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби););Никакие заявления по страхованию моей жизни и(или) нетрудоспособности никогда не были отклонены, отсрочены или удовлетворены с повышением премии или другими изменениями условий';
        v_declaration_states(10) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120';
      ELSE
        v_declaration_states(1) := 'НЕ  является  инвалидом I группы, лицом, требующим постоянного ухода; ';
        v_declaration_states(2) := 'в настоящий  момент оценивает состояние своего здоровья как хорошее, не страдает/страдал(а) следующими заболеваниями: гипертония (II-IV степени), перенесённые инфаркты, инсульты, сердечная недостаточность 3-ей или более высокой степени,  цирроз печени, тяжелая степень почечной недостаточности, злокачественные заболевания крови, онкологические заболевания, гепатит С, сахарный диабет; ';
        v_declaration_states(3) := 'НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита); ';
        v_declaration_states(4) := 'НЕ был не в состоянии выполнять свои обычные обязанности в течение более 10 дней подряд в течение последних 2 лет; ';
        v_declaration_states(5) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей,  под  водой,  на  нефтяных  и газовых платформах, с оружием, в правоохранительных  органах  (оперативная работа, участие в спецоперациях), инкассация, испытания и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
        v_declaration_states(6) := 'Никакие заявления по страхованию моей жизни и(или) нетрудоспособности никогда не были отклонены, отсрочены или удовлетворены с повышением премии или другими изменениями условий.';
      END IF;
      --      END;
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате';
      v_declaration_states2(2) := 'что в отношении Застрахованного не заключены и не поданы заявления на заключение других Договоров страхования жизни и/или от несчастных случаев в ООО "СК "Ренессанс Жизнь", по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 1 500 000 (один миллион пятьсот тысяч) рублей;';
      v_declaration_states2(3) := 'что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий Договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, Договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны;';
      v_declaration_states2(4) := 'что я прочел(-ла), понял(-а) и согласен(-на) с "Полисными условиями по программе страхования жизни Заёмщиков кредита".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
      v_add_cond_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ "О персональных данных" №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку своих персональных данных, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путем осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору,  об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 5 лет после окончания срока действия настоящего Договора.';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    /*    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer       pkg_report_signer.typ_signer;
      v_assured_info pkg_rep_plpdf.t_contact_summary;
    BEGIN
    
      v_signer       := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      v_assured_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.assured_array(1));
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 3;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
      pkg_rep_plpdf.gv_widths(3) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
      pkg_rep_plpdf.gv_borders(3) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'СТРАХОВАТЕЛЬ';
      pkg_rep_plpdf.gv_datas(2) := 'ЗАСТРАХОВАННЫЙ';
      pkg_rep_plpdf.gv_datas(3) := 'СТРАХОВЩИК';
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"Полисные условия" по программе страхования жизни и здоровья Заёмщиков кредита  получил(а), ознакомлен(а) в полном объёме и согласен(на).';
      pkg_rep_plpdf.gv_datas(2) := 'С назначением Выгодоприобретателей согласен(на)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || 'по дов. ' ||
                                   v_signer.procuratory || chr(13) || v_signer.name;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      FOR i IN 1 .. 5
      LOOP
        pkg_rep_plpdf.row_print2;
      END LOOP;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '                         ' || v_insuree_info.fio_initials;
      pkg_rep_plpdf.gv_datas(2) := '                         ' || v_assured_info.fio_initials;
      pkg_rep_plpdf.gv_datas(3) := NULL;
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
      pkg_rep_plpdf.gv_borders(3) := 'LBR';
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;*/
  
  BEGIN
    gv_default_height := 2.5;
    v_policy_id       := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*    --Колонтитулы с номерми страниц
        plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
        plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);
    */
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    -- print_header_custom;
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_5056_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                          c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- Полис "ЕКБ CR50_7/CR50_8/CR50_9"
  -- Доброхотова И., июль, 2014
  PROCEDURE rep_ekb_50789_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    --    v_assured_array t_number_type;
  
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_ekb_50789_policy';
  
    /*    PROCEDURE print_insuree_custom IS
      v_yes     VARCHAR2(2);
      v_no      VARCHAR2(2);
      v_x_start NUMBER;
      v_y_start NUMBER;
      v_x_end   NUMBER;
      v_y_end   NUMBER;
    BEGIN
      v_x_start := plpdf.getcurrentx;
      v_y_start := plpdf.getcurrenty;
    
      print_insuree(par_insuree_info => v_insuree_info);
    
      v_x_end := plpdf.getcurrentx;
      v_y_end := plpdf.getcurrenty;
    
      -- в существующий блок вставляем доп.данные
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => 'Тип кредита: потребительский '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => 'Кредитный договор № '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' от '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => 'Индекс'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcolor4filling(p_color => pkg_rep_plpdf.gc_color_black);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => 'Является ли Страхователь Иностранным публичным должностным лицом?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 --Публичное лицо
      THEN
        v_yes := 'DF'; --залит черным цветом
        v_no  := 'D'; --без заливки
      ELSE
        v_yes := 'D';
        v_no  := 'DF';
      END IF;
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_yes);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ДА'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_no);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'НЕТ'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;*/
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Срок действи Договора равен сроку действия Кредитного договора, указанного в Разделе 2.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
      --      v_no        VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски "Жизнь бэджетника + Потеря работы"';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия (взнос)';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 5;
      pkg_rep_plpdf.gv_widths(3) := 55;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 30;
      pkg_rep_plpdf.gv_widths(6) := 78;
      pkg_rep_plpdf.gv_widths(7) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := '1';
      pkg_rep_plpdf.gv_borders(7) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'L';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'J';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,row_number() over(ORDER BY plt_sort_order, product_line_sort_order) || '. ' || t_product_line_desc || '*' product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                  FROM (SELECT ppl.t_product_line_desc
                                              ,plo.id                  prod_line_option_id
                                              ,plt.sort_order          plt_sort_order
                                              ,pl.sort_order           product_line_sort_order
                                              ,pl.note
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY plt_sort_order
                                         ,product_line_sort_order
                                /*SELECT pl.public_description
                                      ,pkg_rep_utils.to_money_sep(pc.ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(pc.fee) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY plt.sort_order, pl.sort_order) rn
                                 FROM p_cover             pc
                                      ,as_asset            aa
                                      ,t_prod_line_option  plo
                                      ,t_product_line      pl
                                      ,t_product_line_type plt
                                WHERE aa.p_policy_id = v_policy_id
                                  AND aa.as_asset_id = pc.as_asset_id
                                  AND pc.t_prod_line_option_id = plo.id
                                  AND plo.product_line_id = pl.id
                                  AND pl.product_line_type_id = plt.product_line_type_id
                                ORDER BY plt.sort_order
                                         ,pl.sort_order*/
                                
                                )
      LOOP
        IF rec_product_lines.t_prod_line_option_id IS NOT NULL
        THEN
          v_yes := 'DF'; --залит черным цветом
        ELSE
          v_yes := 'D';
        END IF;
        plpdf.drawrect(p_x     => plpdf.getcurrentx + 2.5
                      ,p_y     => plpdf.getcurrenty + 0.6
                      ,p_w     => 1.5
                      ,p_h     => 1.5
                      ,p_style => v_yes);
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := NULL;
        pkg_rep_plpdf.gv_datas(3) := gv_chapter_num || '.' || rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(6) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(7) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      --      pkg_rep_plpdf.gv_widths(5) := NULL;
      --      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      --      pkg_rep_plpdf.gv_aligns(5) := NULL;
      --      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      --      pkg_rep_plpdf.gv_styles(5) := NULL;
      --      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := 'R';
      --      pkg_rep_plpdf.gv_borders(5) := NULL;
      --      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      --      pkg_rep_plpdf.gv_datas(5) := NULL;
      --      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ: '
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => v_pol_sum.payment_terms
                              ,p_align    => 'J'
                              ,p_border   => 'R'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма устанавливается в соответствии с п. 7.2. Полисных условий и определяется как размер текущей ссудной задолженности Застрахованного на дату наступления страхового случая,  по Кредитному Договору, указанному в Разделе 2, и не может превышать сумму, указанную в п. 6.1. и 6.2. настоящего Договора.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    END print_programs_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             'Выгодоприобретателем по страховым рискам "Смерть Застрахованного по любой причине", "Инвалидность Застрахованного I или II группы (с ограничением способности к трудовой деятельности третьей степени) по любой причине", "Дожитие Застрахованного до потери постоянной работы по независящим от него причинам"  настоящего Договора является ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ')
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ является инвалидом I или II группы, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет  наркотики, токсические вещества, НЕ страдает алкоголизмом, или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.;';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения;';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие госпитализации) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время; Является сотрудником правоохранительных органов, но не является сотрудником подразделений специального назначения ФСБ, ФСО, МВД (ОМОН, ОПОН, СОБР, ОМСН, ОПСН и т.д. ), ФСКН. и иных служб и министерств, не является военнослужащим, проходящим военную службу по призыву или контракту; ';
      v_declaration_states(6) := 'НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате';
      v_declaration_states2(2) := 'что в отношении Застрахованного не заключены и не поданы заявления на заключение других Договоров страхования жизни и/или от несчастных случаев в ООО "СК "Ренессанс Жизнь", по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 1 500 000 (один миллион пятьсот тысяч) рублей;';
      v_declaration_states2(3) := 'что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий Договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, Договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны;';
      v_declaration_states2(4) := 'что я прочел(-ла), понял(-а) и согласен(-на) с "Полисными условиями по программе страхования жизни Заёмщиков кредита".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
      v_add_cond_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ «О персональных данных» №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку своих персональных данных, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору, об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора.';
      v_add_cond_states(4) := 'Изложить п. 4.1 и 4.1.1 Полисных условий в новой редакции:' || chr(13) ||
                              '«4.1. На страхование не принимаются:' || chr(13) || '4.1.1. лица:' ||
                              chr(13) ||
                              '-  по риску «Смерть ЛП» и «Инвалидность Застрахованного 1 группы по любой причине» - младше 18 (восемнадцати) лет на момент начала действия Договора страхования и старше 55 (пятьдесят пять) лет для женщин и 60 (шестьдесят) лет для мужчин на момент окончания действия Договора страхования»';
      v_add_cond_states(5) := 'Внести изменения в пункт 4.4.Полисных условий и изложить п.п. 4.4.8. и 4.4.9 в новой редакции:' ||
                              chr(13) ||
                              '4.4.8.во время непосредственного участия Застрахованного в гражданских волнениях, беспорядках, войне или военных действиях; за исключением выполнения им служебных обязанностей или несения службы' ||
                              chr(13) ||
                              '4.4.9. во время любых воздушных перелетов, совершаемых Застрахованным, исключая полеты в качестве пассажира регулярного авиарейса (включая регулярные чартерные авиарейсы), выполняемого организацией, обладающей соответствующей лицензией, а так же исключая полеты в качестве члена экипажа военного воздушного судна.';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    /*    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer       pkg_report_signer.typ_signer;
      v_assured_info pkg_rep_plpdf.t_contact_summary;
    BEGIN
    
      v_signer       := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      v_assured_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.assured_array(1));
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 3;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
      pkg_rep_plpdf.gv_widths(3) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
      pkg_rep_plpdf.gv_borders(3) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'СТРАХОВАТЕЛЬ';
      pkg_rep_plpdf.gv_datas(2) := 'ЗАСТРАХОВАННЫЙ';
      pkg_rep_plpdf.gv_datas(3) := 'СТРАХОВЩИК';
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"Полисные условия" по программе страхования жизни и здоровья Заёмщиков кредита  получил(а), ознакомлен(а) в полном объёме и согласен(на).';
      pkg_rep_plpdf.gv_datas(2) := 'С назначением Выгодоприобретателей согласен(на)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || 'по дов. ' ||
                                   v_signer.procuratory || chr(13) || v_signer.name;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      FOR i IN 1 .. 5
      LOOP
        pkg_rep_plpdf.row_print2;
      END LOOP;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '                         ' || v_insuree_info.fio_initials;
      pkg_rep_plpdf.gv_datas(2) := '                         ' || v_assured_info.fio_initials;
      pkg_rep_plpdf.gv_datas(3) := NULL;
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := 'Подпись         Расшифровка подписи' || chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
      pkg_rep_plpdf.gv_borders(3) := 'LBR';
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;*/
  
  BEGIN
    gv_default_height := 2.5;
  
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*    --Колонтитулы с номерми страниц
    plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
    plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);*/
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    --    print_header(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_50789_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                           c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- Полис продукта ТКБ
  -- 339295 - Анкета на настройку продукта ТКБ
  -- Доброхотова, декабрь, 2014
  PROCEDURE rep_tkb
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_tkb';
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 5;
      pkg_rep_plpdf.gv_widths(3) := 55;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 30;
      pkg_rep_plpdf.gv_widths(6) := 78;
      pkg_rep_plpdf.gv_widths(7) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := '1';
      pkg_rep_plpdf.gv_borders(7) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'L';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'J';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
      pkg_rep_plpdf.gv_maxlines(7) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,row_number() over(ORDER BY plt_sort_order, product_line_sort_order) || '. ' || t_product_line_desc || '*' product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                  FROM (SELECT ppl.t_product_line_desc
                                              ,plo.id                  prod_line_option_id
                                              ,plt.sort_order          plt_sort_order
                                              ,pl.sort_order           product_line_sort_order
                                              ,pl.note
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY plt_sort_order
                                         ,product_line_sort_order)
      LOOP
        IF rec_product_lines.t_prod_line_option_id IS NOT NULL
        THEN
          v_yes := 'DF'; --залит черным цветом
        ELSE
          v_yes := 'D';
        END IF;
        plpdf.drawrect(p_x     => plpdf.getcurrentx + 2.5
                      ,p_y     => plpdf.getcurrenty + 0.6
                      ,p_w     => 1.5
                      ,p_h     => 1.5
                      ,p_style => v_yes);
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := NULL;
        pkg_rep_plpdf.gv_datas(3) := gv_chapter_num || '.' || rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(6) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(7) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '*Любая причина - событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при условии, что к моменту самоубийства договор страхования действовал не менее двух лет.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ: '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Раз в год: оплата страховых взносов производится раз в год не позднее даты заключения Договора, далее - не позднее даты, отстоящей от нее на срок, кратный году.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма устанавливается в соответствии с п. 7.2. Полисных условий'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_insuree_custom(par_insuree_info pkg_rep_plpdf.t_contact_summary) IS
      v_yes VARCHAR2(2);
      v_no  VARCHAR2(2);
    
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 150
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_txt      => ''
                     ,p_align    => 'R'
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      /* 405988 Григорьев Ю. Сделал корректное отображение строки */
      pkg_rep_plpdf.gv_widths(1) := 35;
      pkg_rep_plpdf.gv_widths(2) := 40;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 95;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := 'Кредитный договор № ';
      pkg_rep_plpdf.gv_datas(2) := v_pol_sum.credit_account_number;
      pkg_rep_plpdf.gv_datas(3) := ' от ' || to_char(v_pol_sum.start_date, 'dd.mm.yyyy');
      pkg_rep_plpdf.gv_datas(4) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      /* */
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_w        => plpdf.getpagespace - 5
                     ,p_txt      => l_doc_place
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Кем и когда выдан паспорт'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Адрес'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 85
                     ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                              ,par_brief      => 'CONST')
                                                                             ,'<#ADDRESS_FULL>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                           ,'<#EMAIL_LOWER>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      --------------------------
    
      set_font;
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 25
                     ,p_txt      => 'Индекс'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h      => -1
                     ,p_txt    => 'Является ли Страхователь иностранным публичным должностным лицом?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 /*Публичное лицо*/
      THEN
        v_yes := 'DF'; --залит черным цветом
        v_no  := 'D'; --без заливки
      ELSE
        v_yes := 'D';
        v_no  := 'DF';
      END IF;
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_yes);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ДА'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_no);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'НЕТ'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => 'Является ли Страхователь российским публичным должностным лицом?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_rpdl = 1 /*Публичное лицо*/
      THEN
        v_yes := 'DF'; --залит черным цветом
        v_no  := 'D'; --без заливки
      ELSE
        v_yes := 'D';
        v_no  := 'DF';
      END IF;
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_yes);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ДА'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.drawrect(p_x     => plpdf.getcurrentx
                    ,p_y     => plpdf.getcurrenty + 1
                    ,p_w     => 2
                    ,p_h     => 2
                    ,p_style => v_no);
      plpdf.printcell(p_h => gv_default_height, p_w => 5, p_ln => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'НЕТ'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет  наркотики, токсические вещества, НЕ страдает алкоголизмом, или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.;';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения;';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие госпитализации) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время;';
      v_declaration_states(6) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;8.8. НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, можно ответить ДА; рост 160 см, вес 85 кг, разница - 75 - ответ - НЕТ).';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате';
      v_declaration_states2(2) := 'что в отношении Застрахованного не заключены и не поданы заявления на заключение других Договоров страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 3 000 000 (Три миллиона) рублей;';
      v_declaration_states2(3) := 'что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий Договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, Договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны; ';
      v_declaration_states2(4) := 'что я прочел(-ла), понял(-а) и согласен(-на) с Полисными условиями по программе страхования жизни и здоровья Заёмщиков кредита.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    
    END print_declaration_custom;
  
    PROCEDURE print_additional_conditions IS
      TYPE t_states IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
      v_additional_condition_states t_states;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => gv_chapter_num || '. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ:'
                     ,p_border => 'LTR'
                     ,p_ln     => 1);
    
      set_font;
    
      v_additional_condition_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_additional_condition_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
      v_additional_condition_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ «О персональных данных» №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору №001140 от 29 мая 2006 г. (ИНН 7743040060, ОГРН 1027739036445, передачу перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору, об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора. Настоящее согласие на обработку персональных данных может быть отозвано посредством направления письменного уведомления в адрес Страховщика.';
    
      FOR i IN 1 .. v_additional_condition_states.count
      LOOP
        plpdf.printmultilinecell(p_h        => gv_default_height
                                ,p_txt      => v_additional_condition_states(i)
                                ,p_align    => 'J'
                                ,p_border   => 'LR'
                                ,p_ln       => 1
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      END LOOP;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold_italic);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Я  уполномочиваю  любое лечебное учреждение, любое иное учреждение любой организационно-правовой формы, предоставлять по запросу ООО «СК «Ренессанс Жизнь», любую информацию о моем здоровье,  проводимом мне лечении, операциях и т.д., результатах анализов и т.д., включая органы медико-социальной экспертизы, бюро судебно-медицинской экспертизы и т.д.'
                              ,p_align    => 'J'
                              ,p_border   => 'LRB'
                              ,p_ln       => 1
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
    END print_additional_conditions;
  
    PROCEDURE print_beneficiaries_custom IS
    BEGIN
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             '.1. Первым Выгодоприобретателем по страховым рискам "Смерть Застрахованного по любой причине" и "Инвалидность Застрахованного I или  2  группы  "  настоящего  Договора,   в  доле,  равной  сумме  задолженности  Застрахованного  по  Кредитному  договору  на  момент наступления  страхового  случая,  указанному  в  Разделе  2  настоящего  договора,  является АКБ «Транскапиталбанк» (ЗАО).'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => gv_chapter_num ||
                                             '.2.Выгодоприобретателями   по  страховому  риску   "Смерть  Застрахованного  по  любой  причине"  в  доле,  оставшейся  после  страховой выплаты Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, являются следующие лица:'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      set_font;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 6 * 2;
      pkg_rep_plpdf.gv_widths(2) := plpdf.getpagespace / 6;
      pkg_rep_plpdf.gv_widths(3) := plpdf.getpagespace / 6 * 2;
      pkg_rep_plpdf.gv_widths(4) := plpdf.getpagespace / 6;
    
      pkg_rep_plpdf.gv_borders(1) := '1';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
    
      pkg_rep_plpdf.gv_datas(1) := 'Ф.И.О.';
      pkg_rep_plpdf.gv_datas(2) := 'Дата рождения';
      pkg_rep_plpdf.gv_datas(3) := 'Родственные отношения';
      pkg_rep_plpdf.gv_datas(4) := 'Доля(%)';
    
      pkg_rep_plpdf.gv_aligns(1) := 'C';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
    
      pkg_rep_plpdf.row_print2(par_h => 3);
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'L';
    
      FOR rec IN (SELECT *
                    FROM (SELECT c.obj_name_orig
                                ,to_char(cp.date_of_birth, 'dd.mm.yyyy') date_of_birth
                                ,crt.relationship_dsc
                                ,to_char(ab.value) AS VALUE
                                ,rownum AS rn
                            FROM as_asset           aa
                                ,as_beneficiary     ab
                                ,contact            c
                                ,cn_contact_rel     cr
                                ,t_contact_rel_type crt
                                ,cn_person          cp
                           WHERE aa.p_policy_id = v_policy_id
                             AND aa.as_asset_id = ab.as_asset_id
                             AND ab.contact_id = c.contact_id
                             AND ab.cn_contact_rel_id = cr.id
                             AND cr.relationship_type = crt.id
                             AND c.contact_id = cp.contact_id(+)) t
                        ,(SELECT LEVEL AS rn2 FROM dual CONNECT BY LEVEL <= 3)
                   WHERE rn2 = rn(+))
      LOOP
        pkg_rep_plpdf.gv_datas(1) := rec.obj_name_orig;
        pkg_rep_plpdf.gv_datas(2) := rec.date_of_birth;
        pkg_rep_plpdf.gv_datas(3) := rec.relationship_dsc;
        pkg_rep_plpdf.gv_datas(4) := rec.value;
      
        pkg_rep_plpdf.row_print2(par_h => 3);
      END LOOP;
    
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '** Доли в настоящей таблице указаны в процентном отношении к общей доле, причитающейся указанным Выгодоприобретателям после страховой выплаты Первому Выгодоприобретателю, указанному в п. 7.1. настоящего договора.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => gv_chapter_num ||
                                             '.3 Выгодоприобретателем по страховому риску "Инвалидность Застрахованного I и 2 группы " в доле, оставшейся после страховой выплаты Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LBR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
  BEGIN
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header(v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------
    print_additional_conditions;
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
              ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_tkb;

  /** 
  * Форма счета для ТКБ
  * @task 404551
  * @author Капля П.
  */
  PROCEDURE rep_tkb_payment_doc
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    NUMBER;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name      CONSTANT pkg_trace.t_object_name := 'rep_tkb_payment_doc';
    c_rigvis_contact CONSTANT INTEGER := 251658;
    v_rigvis_info dml_contact.tt_contact;
    v_address_str VARCHAR2(32767);
  BEGIN
  
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    v_rigvis_info := dml_contact.get_record(251658);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 10);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    pkg_rep_plpdf.set_font(par_style => 'B', par_font_family => 'Times');
    plpdf.printcell(p_txt => v_rigvis_info.short_name, p_ln => 1);
  
    v_address_str := 'Адрес: 125239, г. Москва, Ленинградское шоссе, 46/1, тел.: 797-32-75';
  
    plpdf.printcell(p_txt => v_address_str, p_ln => 1);
  
    pkg_rep_plpdf.set_font;
  
    pkg_rep_plpdf.delete_row_print_cache;
    FOR i IN 1 .. 3
    LOOP
      pkg_rep_plpdf.gv_widths(i) := plpdf.getPageSpace / 5;
    END LOOP;
    pkg_rep_plpdf.gv_widths(4) := plpdf.getPageSpace / 5 * 2;
  
    pkg_rep_plpdf.gv_borders(1) := '1';
    pkg_rep_plpdf.gv_borders(2) := '1';
    pkg_rep_plpdf.gv_borders(3) := 'LTR';
    pkg_rep_plpdf.gv_borders(4) := 'LTR';
  
/*    pkg_rep_plpdf.gv_datas(1) := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(c_rigvis_contact
                                                                                                                            ,'INN')
                                                                               ,'<#TYPE_DESC> <DOC_NUM>');
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(c_rigvis_contact
                                                                                                                            ,'KPP')
                                                                               ,'<#TYPE_DESC> <DOC_NUM>');*/
    pkg_rep_plpdf.gv_datas(1) := 'ИНН 7743040060';
    pkg_rep_plpdf.gv_datas(2) := 'КПП 774301001';
    pkg_rep_plpdf.gv_datas(3) := NULL;
    pkg_rep_plpdf.gv_datas(4) := NULL;
  
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.delete_row_print_cache;
    pkg_rep_plpdf.gv_widths(1) := plpdf.getPageSpace / 5 * 2;
    pkg_rep_plpdf.gv_widths(2) := plpdf.getPageSpace / 5;
    pkg_rep_plpdf.gv_widths(3) := plpdf.getPageSpace / 5 * 2;
  
    pkg_rep_plpdf.gv_borders(1) := '1';
    pkg_rep_plpdf.gv_borders(2) := 'LR';
    pkg_rep_plpdf.gv_borders(3) := 'LR';
		
    pkg_rep_plpdf.gv_aligns(1) := 'L';
    pkg_rep_plpdf.gv_aligns(2) := 'C';
    pkg_rep_plpdf.gv_aligns(3) := 'L';
  
    pkg_rep_plpdf.gv_datas(1) := 'Получатель';
    pkg_rep_plpdf.gv_datas(2) := NULL;
    pkg_rep_plpdf.gv_datas(3) := NULL;
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_datas(1) := v_rigvis_info.short_name;
    pkg_rep_plpdf.gv_datas(2) := 'Сч №';
    pkg_rep_plpdf.gv_datas(3) := '40702810700000002581';
  
    pkg_rep_plpdf.gv_borders(1) := '1';
    pkg_rep_plpdf.gv_borders(2) := 'LBR';
    pkg_rep_plpdf.gv_borders(3) := 'LBR';
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_borders(1) := 'LTR';
    pkg_rep_plpdf.gv_borders(2) := '1';
    pkg_rep_plpdf.gv_borders(3) := '1';
  
    pkg_rep_plpdf.gv_datas(1) := 'Банк получателя';
    pkg_rep_plpdf.gv_datas(2) := 'БИК';
    pkg_rep_plpdf.gv_datas(3) := '044525388';
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_borders(1) := 'LBR';
    pkg_rep_plpdf.gv_borders(2) := '1';
    pkg_rep_plpdf.gv_borders(3) := '1';
  
    pkg_rep_plpdf.gv_datas(1) := '«ТКБ» (ЗАО) г. Москва';
    pkg_rep_plpdf.gv_datas(2) := 'Сч №';
    pkg_rep_plpdf.gv_datas(3) := '30101810800000000388';
    pkg_rep_plpdf.row_print2;
  
    plpdf.printcell(p_ln => 1);
    
    pkg_rep_plpdf.set_font(par_size => 14, par_style => 'B');
		plpdf.printcell(p_ln => 1);
		plpdf.printcell(p_ln => 1);
  
    plpdf.printcell(p_align => 'C'
                   ,p_w     => plpdf.getPageSpace
                   ,p_ln    => 1
									 ,p_h => 6
                   ,p_txt   => 'СЧЕТ № ___ от ' || to_char(trunc(SYSDATE), 'dd.mm.yyyy')
									 ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    pkg_rep_plpdf.set_font;
    plpdf.printcell(p_ln => 1);
		
    pkg_rep_plpdf.delete_row_print_cache;
		
    pkg_rep_plpdf.gv_widths(1) := 35;
    pkg_rep_plpdf.gv_widths(2) := plpdf.getPageSpace - 35;
		
    pkg_rep_plpdf.gv_datas(1) := 'Плательщик:';
    pkg_rep_plpdf.gv_datas(2) := v_insuree_info.fio;	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := 'Адрес:';
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.get_address(pkg_contact_rep_utils.get_last_active_address_id(v_insuree_info.contact_id
                                                                                                                       ,'CONST'));	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := 'Паспорт:';
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(v_insuree_info.contact_id
                                                                                                                       ,'PASS_RF'),'<#DOC_SER> № <DOC_NUM>');	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := 'Выдан:';
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(v_insuree_info.contact_id
                                                                                                                       ,'PASS_RF'),'<#DOC_PLACE> <#DOC_DATE>');	
		pkg_rep_plpdf.row_print2;
		
		plpdf.printcell(p_ln => 1);
									 
		pkg_rep_plpdf.delete_row_print_cache;							 
									 
    pkg_rep_plpdf.gv_widths(1) := 10;					
		pkg_rep_plpdf.gv_widths(2) := 50;
		pkg_rep_plpdf.gv_widths(3) := 25;
		pkg_rep_plpdf.gv_widths(4) := 25;
		pkg_rep_plpdf.gv_widths(5) := 40;
		pkg_rep_plpdf.gv_widths(6) := 40;
		
		for i in 1..6 loop
		pkg_rep_plpdf.gv_aligns(i) := 'C';
		pkg_rep_plpdf.gv_borders(i) := '1';
		end loop;
		
		pkg_rep_plpdf.gv_datas(1) := '№';
		pkg_rep_plpdf.gv_datas(2) := 'Наименование товара';
		pkg_rep_plpdf.gv_datas(3) := 'Единица измерения';
		pkg_rep_plpdf.gv_datas(4) := 'Количество';
		pkg_rep_plpdf.gv_datas(5) := 'Цена';
		pkg_rep_plpdf.gv_datas(6) := 'Сумма';
    pkg_rep_plpdf.row_print2;
		
		pkg_rep_plpdf.gv_aligns(2) := 'L';
    pkg_rep_plpdf.gv_datas(1) := '1';
    pkg_rep_plpdf.gv_datas(2) := 'Страховая премия по договору страхования  ООО «СК «Ренессанс Жизнь» № '||v_pol_sum.pol_num||' подписания договора от '||to_char(v_pol_sum.start_date,'dd.mm.yyyy');
    pkg_rep_plpdf.gv_datas(3) := 'Шт.';
    pkg_rep_plpdf.gv_datas(4) := '1';
    pkg_rep_plpdf.gv_datas(5) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
    pkg_rep_plpdf.gv_datas(6) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
    pkg_rep_plpdf.row_print2;
		
		pkg_rep_plpdf.delete_row_print_cache;
		
		-- сумма предыдущих ширин столбцов кроме последнего
    pkg_rep_plpdf.gv_widths(1) := 10+50+25+25+40;					
		pkg_rep_plpdf.gv_widths(2) := 40;
		
		pkg_rep_plpdf.gv_borders(1) := null;
		pkg_rep_plpdf.gv_borders(2) := '1';
		
		pkg_rep_plpdf.gv_aligns(1) := 'R';
		pkg_rep_plpdf.gv_aligns(2) := 'C';
		
		pkg_rep_plpdf.gv_styles(1) := 'B';
		pkg_rep_plpdf.gv_styles(2) := null;
		
    pkg_rep_plpdf.gv_datas(1) := 'Итого:';
    pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := 'Без налога (НДС).';
    pkg_rep_plpdf.gv_datas(2) := '----';
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := 'Всего к оплате:';
    pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
		pkg_rep_plpdf.row_print2;		
		
		plpdf.PrintCell(p_txt => 'Всего наименований 1 (один) на сумму:',p_ln => 1);
		plpdf.PrintCell(p_txt => pkg_utils.money2speech(quant => v_pol_sum.premium,p_fund_id => v_pol_sum.fund_id),p_ln => 1);
		
		plpdf.PrintCell(p_ln => 1);
		plpdf.PrintMultiLineCell(p_txt => 'Оплата производится в российских рублях по курсу соответствующей валюты, установленному ЦБ РФ на дату проведения расчетов.',p_ln => 1);
		
		plpdf.PrintCell(p_ln => 1);		
		plpdf.PrintCell(p_ln => 1,p_txt => 'Руководитель предприятия_____________________ (Васянина Е.С.)');	
		plpdf.PrintCell(p_ln => 1,p_txt => 'Главный бухгалтер ____________________________ (Иванова Т.Н.)');	
		
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'payment_pol_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END;

  --РБР CR122
  PROCEDURE rep_rbr
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_rbr';
  
    PROCEDURE print_header_custom
    (
      par_policy_id      p_policy.policy_id%TYPE
     ,par_policy_summary pkg_rep_plpdf.t_policy_summary
    ) IS
      l_text    VARCHAR2(500);
      v_barcode VARCHAR2(25);
    BEGIN
      v_barcode := pkg_rep_plpdf.get_barcode_for_policy(par_policy_id => par_policy_id);
    
      IF v_barcode IS NOT NULL
      THEN
        set_font(par_size        => 28
                ,par_style       => pkg_rep_plpdf.gc_style_regular
                ,par_font_family => pkg_rep_plpdf.gc_barcode_font_family_code39);
        plpdf.printcell(p_h => -1, p_txt => v_barcode, p_align => 'R', p_ln => 1);
      END IF;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Договор страхования жизни и здоровья заёмщиков кредита № ' ||
                                    par_policy_summary.pol_num
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'заключён на основании Полисных условий по программе страхования жизни и здоровья заёмщиков кредита'
                     ,p_border   => 'LRB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      l_text := get_city_name;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => plpdf.gettextwidth(l_text) + 10
                     ,p_txt      => l_text
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => pkg_rep_utils.date_to_genitive_case(par_policy_summary.start_date) ||
                                    ' г.'
                     ,p_align    => 'R'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
    END print_header_custom;
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
      --      v_no        VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ (ВЗНОСЫ):'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 5;
      pkg_rep_plpdf.gv_widths(3) := 55;
      pkg_rep_plpdf.gv_widths(4) := 20;
      pkg_rep_plpdf.gv_widths(5) := 30;
      pkg_rep_plpdf.gv_widths(6) := 78;
      pkg_rep_plpdf.gv_widths(7) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := '1';
      pkg_rep_plpdf.gv_borders(7) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'L';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'J';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
      pkg_rep_plpdf.gv_maxlines(7) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,pl.public_description product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                  FROM (SELECT ppl.t_product_line_desc t_product_line_desc
                                              ,plo.id                  prod_line_option_id
                                              ,plt.sort_order          plt_sort_order
                                              ,pl.sort_order           product_line_sort_order
                                              ,pl.note
                                              ,pl.public_description
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY plt_sort_order
                                         ,product_line_sort_order)
      LOOP
        IF rec_product_lines.t_prod_line_option_id IS NOT NULL
        THEN
          v_yes := 'DF'; --залит черным цветом
        ELSE
          v_yes := 'D';
        END IF;
        plpdf.drawrect(p_x     => plpdf.getcurrentx + 2.5
                      ,p_y     => plpdf.getcurrenty + 0.6
                      ,p_w     => 1.5
                      ,p_h     => 1.5
                      ,p_style => v_yes);
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := NULL;
        pkg_rep_plpdf.gv_datas(3) := gv_chapter_num || '.' || rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(6) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(7) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL /*'1'*/
       ;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ (ВЗНОС):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Cтраховая сумма по рискам «Смерть ЛП» и «Инвалидность», указываемая в Договоре страхования, равна размеру первоначальной суммы кредита по кредитному договору на момент его заключения, увеличенной на 10%. В течение действия договора страхования страховая сумма уменьшается по мере погашения задолженности Застрахованного по кредитному договору  и равна размеру текущей ссудной (фактической) задолженности Застрахованного по кредитному договору, увеличенной на 10%,  на дату наступления страхового случая.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма  по рискам «Смерть ЛП» и «Инвалидность» в случае полного досрочного погашения кредита равна размеру ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком платежей, увеличенной на 10 (десять) процентов.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма по риску «Временная утрата трудоспособности Застрахованного, наступившая в результате любой причины » равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения, увеличенной на 10%.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ:  Единовременно '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      ------------------------
    
    END print_programs_custom;
  
    PROCEDURE print_insuree_custom(par_insuree_info pkg_rep_plpdf.t_contact_summary) IS
      v_yes VARCHAR2(2);
      v_no  VARCHAR2(2);
    
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 150
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_txt   => 'Тип кредита: потребительский '
                     ,p_align => 'R'
                      -- ,p_w        => 50
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_txt    => 'Кредитный договор № '
                     ,p_border => 'RL'
                      --                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' от '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 182;
      pkg_rep_plpdf.gv_widths(3) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := l_doc_place;
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 182;
      pkg_rep_plpdf.gv_widths(3) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Кем и когда выдан паспорт';
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 26;
      pkg_rep_plpdf.gv_widths(3) := 86;
      pkg_rep_plpdf.gv_widths(4) := 35;
      pkg_rep_plpdf.gv_widths(5) := 35;
      pkg_rep_plpdf.gv_widths(6) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := 'R';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Адрес';
      pkg_rep_plpdf.gv_datas(3) := pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                             ,par_brief      => 'CONST')
                                                                            ,'<#ADDRESS_FULL>');
      pkg_rep_plpdf.gv_datas(4) := pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id));
      pkg_rep_plpdf.gv_datas(5) := pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                          ,'<#EMAIL_LOWER>');
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 26;
      pkg_rep_plpdf.gv_widths(3) := 23;
      pkg_rep_plpdf.gv_widths(4) := 63;
      pkg_rep_plpdf.gv_widths(5) := 35;
      pkg_rep_plpdf.gv_widths(6) := 35;
      pkg_rep_plpdf.gv_widths(7) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'C';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := NULL;
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
      pkg_rep_plpdf.gv_borders(7) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := 'индекс';
      pkg_rep_plpdf.gv_datas(4) := 'город, улица, дом, квартира';
      pkg_rep_plpdf.gv_datas(5) := 'телефон';
      pkg_rep_plpdf.gv_datas(6) := 'е-mail';
      pkg_rep_plpdf.gv_datas(7) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет  наркотики, токсические вещества, НЕ страдает алкоголизмом, или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.;';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения;';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился(-ась) на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие госпитализации) и/или НЕ был(-а) направлен на стационарное лечение (в том числе если лечение связано с заболеваниями, влекущими получение инвалидности), или за последние 12 месяцев НЕ обращался(-ась) за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания (не учитывая больничные листы выданные в связи с острой респираторной инфекцией, гриппом любой формы и вида, травм, не требующих долгосрочной госпитализации) более одного раза, не учитывая разновидности обследований и консультаций (т.е. не получал акт (заключение) обследования более одного раза);';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него/нее НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания за исключением обращений к стоматологу и/или прохождения периодических осмотров, в течение ближайшего месяца с момента подписания настоящей Декларации;';
      v_declaration_states(6) := 'НЕ связан(-а) с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал(-а) заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;8.8. НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, можно ответить ДА; рост 160 см, вес 85 кг, разница - 75 - ответ - НЕТ).';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, (декларацию можно подписать!); рост 160 см, вес 85 кг, разница - 75, (декларацию подписать нельзя!).';
      v_declaration_states(9) := 'НЕ являюсь российским/иностранным публичным должностным лицом.';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате;';
      v_declaration_states2(2) := 'что я уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультации, лечение и т.д.), предоставлять по требованию страховой компании ООО «СК «Ренессанс Жизнь» копии медицинских документов (результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оценкой степени страхового риска, так и в связи со страховыми случаями по данному договору страхования;';
      v_declaration_states2(3) := 'что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоров страхования  в ООО «СК «Ренессанс Жизнь» и общая страховая сумма по любым договорам страхования, заключенным в отношении Застрахованных по рискам «смерть ЛП», «Инвалидность», «ВНТ ЛП» не превышает 10 000 000 (десять миллионов) рублей;';
      v_declaration_states2(4) := 'что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны;';
      v_declaration_states2(5) := 'что я прочел(-ла), понял(-а) и согласен(-на) с Полисными условиями по программе страхования жизни и здоровья заёмщиков кредита.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    
    END print_declaration_custom;
  
    PROCEDURE print_additional_conditions IS
      TYPE t_states IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
      v_additional_condition_states t_states;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => gv_chapter_num || '. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ:'
                     ,p_border => 'LTR'
                     ,p_ln     => 1);
    
      set_font;
    
      v_additional_condition_states(1) := '9.1 Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_additional_condition_states(2) := '9.2 Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
      v_additional_condition_states(3) := '9.3 Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ «О персональных данных» №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору Общество с ограниченной ответственностью 
«Главстрахиндустрия» перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору, об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора. Настоящее согласие на обработку персональных данных может быть отозвано посредством направления письменного уведомления в адрес Страховщика.';
      v_additional_condition_states(4) := '9.4 Подписывая настоящий Договор подтверждаю, что ни  я, ни мои  родственники не занимают должности членов Совета директоров Банка России, должности в законодательном, исполнительном, административном, судебном органе РФ или других стран; должности в Банке России, государственных и иных организациях, созданных РФ на основании федеральных законов; должности в публичных международных организациях.';
    
      FOR i IN 1 .. v_additional_condition_states.count
      LOOP
        plpdf.printmultilinecell(p_h        => gv_default_height
                                ,p_txt      => v_additional_condition_states(i)
                                ,p_align    => 'J'
                                ,p_border   => 'LR'
                                ,p_ln       => 1
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      END LOOP;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold_italic);
    
    END print_additional_conditions;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => 'Выгодоприобретателем по страховым рискам «Смерть ЛП», «Инвалидность» настоящего  Договора является ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => 'Выгодоприобретателем по риску «Временная утрата трудоспособности Застрахованного, наступившая в результате любой причины» является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LBR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer pkg_report_signer.typ_signer;
    BEGIN
    
      v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 2;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
      pkg_rep_plpdf.gv_datas(2) := 'Страховщик';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подписывая настоящий договор страхования, подтверждаю достоверность утверждений в вышеуказанной декларации.
 Полисные условия по программе страхования жизни и здоровья заёмщиков кредита получил(а), ознакомлен(а) в полном объеме и согласен(на).';
      pkg_rep_plpdf.gv_datas(2) := 'Вице-Президент  по операционным вопросам и информационным технологиям ' ||
                                   v_signer.short_name || ' действующего на основании доверенности №' ||
                                   v_signer.procuratory_num;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись                                                                    Расшифровка подписи' ||
                                   chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header_custom(v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_conditions;
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_rbr;

  PROCEDURE rep_rolf_2015
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id     p_policy.policy_id%TYPE;
    v_pol_sum       pkg_rep_plpdf.t_policy_summary;
    v_insuree_info  pkg_rep_plpdf.t_contact_summary;
    v_cnt_benef     NUMBER := 0;
    v_product_brief t_product.brief%TYPE;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_rolf_2015';
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски/программы страхования';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'J';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY product_line_sort_order) rn
                                  FROM (SELECT ppl.t_product_line_desc t_product_line_desc
                                              ,plo.id prod_line_option_id
                                              ,plt.sort_order plt_sort_order
                                              ,pl.sort_order product_line_sort_order
                                              ,pl.note
                                              ,nvl(pl.public_description, pl.description) product_line_desc
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY product_line_sort_order)
      LOOP
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := gv_chapter_num || '.' || rec_product_lines.rn || ' ' ||
                                     rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(3) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(6) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ:  Единовременно '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма по рискам «Смерть ЛП» и «Инвалидность» равна размеру первоначальной суммы кредита по кредитному договору на момент его заключения, увеличенной на 10% (десять процентов). В течение действия договора страхования страховая сумма уменьшается в соответствии с первоначальным графиком платежей и равна ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком платежей, увеличенной на 10% (десять процентов). Страховая сумма по риску «ВНТ НС» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения, увеличенной на 10% (десять процентов). Страховая сумма по программе страхования «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам» определяется в соответствии с Приложением № 1 к Полисным условиям.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** Любая причина - событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при условии, что к моменту самоубийства договор страхования действовал не менее двух лет. '
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      ------------------------
    
    END print_programs_custom;
  
    PROCEDURE print_insuree_custom(par_insuree_info pkg_rep_plpdf.t_contact_summary) IS
      v_yes VARCHAR2(2);
      v_no  VARCHAR2(2);
    
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 182;
      pkg_rep_plpdf.gv_widths(3) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := l_doc_place;
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 182;
      pkg_rep_plpdf.gv_widths(3) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Кем и когда выдан паспорт';
      pkg_rep_plpdf.gv_datas(3) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 26;
      pkg_rep_plpdf.gv_widths(3) := 86;
      pkg_rep_plpdf.gv_widths(4) := 35;
      pkg_rep_plpdf.gv_widths(5) := 35;
      pkg_rep_plpdf.gv_widths(6) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := 'R';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Адрес';
      pkg_rep_plpdf.gv_datas(3) := pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                             ,par_brief      => 'CONST')
                                                                            ,'<#ADDRESS_FULL>');
      pkg_rep_plpdf.gv_datas(4) := pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id));
      pkg_rep_plpdf.gv_datas(5) := pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                          ,'<#EMAIL_LOWER>');
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 4;
      pkg_rep_plpdf.gv_widths(2) := 26;
      pkg_rep_plpdf.gv_widths(3) := 23;
      pkg_rep_plpdf.gv_widths(4) := 63;
      pkg_rep_plpdf.gv_widths(5) := 35;
      pkg_rep_plpdf.gv_widths(6) := 35;
      pkg_rep_plpdf.gv_widths(7) := 4;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := 'C';
      pkg_rep_plpdf.gv_aligns(7) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
      pkg_rep_plpdf.gv_styles(7) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := NULL;
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
      pkg_rep_plpdf.gv_borders(7) := 'R';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
      pkg_rep_plpdf.gv_datas(3) := 'индекс';
      pkg_rep_plpdf.gv_datas(4) := 'город, улица, дом, квартира';
      pkg_rep_plpdf.gv_datas(5) := 'телефон';
      pkg_rep_plpdf.gv_datas(6) := 'е-mail';
      pkg_rep_plpdf.gv_datas(7) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_currency_custom
    (
      par_policy_summary pkg_rep_plpdf.t_policy_summary
     ,par_box_size       NUMBER DEFAULT 2
     ,par_box_delta_y    NUMBER DEFAULT 1
    ) IS
      v_text VARCHAR2(500);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      v_text := gv_chapter_num || '. ВАЛЮТА ДОГОВОРА:';
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => v_text
                     ,p_w        => plpdf.gettextwidth(v_text) + 5
                     ,p_border   => 'LTB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      FOR rec IN (SELECT f.name
                        ,nvl2(lead(1) over(ORDER BY f.fund_id DESC), 0, 1) is_last
                        ,decode(f.brief
                               ,par_policy_summary.fund_brief
                               ,pkg_rep_plpdf.gc_rect_marked
                               ,pkg_rep_plpdf.gc_rect_unmarked) marked
                    FROM t_product       p
                        ,t_prod_currency pc
                        ,fund            f
                   WHERE p.product_id = pc.product_id
                     AND pc.currency_id = f.fund_id
                     AND p.product_id = par_policy_summary.product_id
                   ORDER BY f.fund_id DESC)
      LOOP
        plpdf.drawrect(p_x     => plpdf.getcurrentx
                      ,p_y     => plpdf.getcurrenty + par_box_delta_y
                      ,p_w     => par_box_size
                      ,p_h     => par_box_size
                      ,p_style => rec.marked);
      
        plpdf.printcell(p_border   => 'TB'
                       ,p_w        => 5
                       ,p_ln       => 0
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      
        plpdf.printcell(p_h        => gv_default_height
                       ,p_w        => plpdf.gettextwidth(rec.name) + 5
                       ,p_txt      => rec.name
                       ,p_border   => 'TB'
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                       ,p_ln       => 0);
      END LOOP;
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => 'Марка автомобиля: '
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'R'
                     ,p_border   => 'TB'
                     ,p_ln       => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 30
                     ,p_txt      => pkg_doc_properties.get_string(v_policy_id, 'CAR_MAKE')
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'C'
                     ,p_border   => 1
                     ,p_ln       => 0);
    
      plpdf.printcell(p_ln       => 1
                     ,p_border   => 'BTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
    END print_currency_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      v_declaration_states(1) := '8.1. НЕ является инвалидом, лицом, требующим постоянного ухода (помощи) других лиц; НЕ имеет нарушений опорно-двигательной системы, ограничивающих движение; НЕ страдает мышечной дистрофией; НЕ страдает нервными расстройствами, психическими заболеваниями; НЕ употребляет  наркотики, токсические вещества, НЕ страдает алкоголизмом, и/или НЕ состит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.;';
      v_declaration_states(2) := '8.2. НЕ страдает/страдал(а) следующими заболеваниями: близорукость более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, диабет, гемофилия, сердечно-сосудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, заболевания щитовидной железы, дыхательная недостаточность, повреждение головного мозга, заболевания костно-мышечной системы, иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения, а также любые другие опасные для жизни заболевания или признаки заболеваний, не перечисленные выше;';
      v_declaration_states(3) := '8.3. НЕ находится  в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(4) := '8.4. За последние 2 (два) года НЕ находился(-ась) на больничном листе сроком 3 (три) недели подряд и более (исчисляется по каждому году, не учитывая больничные листы выданные в связи с острой респираторной инфекцией, гриппом любой формы и вида, травм, не требующих долгосрочной госпитализации и/или НЕ был(-а) направлен на стационарное лечение (в том числе если лечение связано с заболеваниями, влекущими получение инвалидности), или за последние 12 месяцев НЕ обращался(-ась) за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания (не учитывая больничные листы выданные в связи с острой респираторной инфекцией, гриппом любой формы и вида, травм, не требующих долгосрочной госпитализации более одного раза, не учитывая разновидности обследований и консультаций (т.е. не получал акт (заключение) обследования более одного раза);';
      v_declaration_states(5) := '8.5. В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием/нарушением здоровья или в отношении меня НЕ запланировано лечение/операция и я не планирует обратиться к врачу в ближайшее время за исключением обращений к стоматологу и/или прохождения периодических осмотров (за исключением регулярных профилактических осмотров, диспансеризаций или прохождения профессиональных медицинских комиссий) с момента подписания настоящей Декларации;';
      v_declaration_states(6) := '8.6. НЕ связан(а) с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается ь опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := '8.7. НЕ подавал(а) заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых мне  было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска; ';
      v_declaration_states(8) := '8.8. НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет  95(Декларацию можно подписать!) Рост 160 см, вес 85 кг, разница  75 (Декларацию нельзя подписать!)';
      v_declaration_states(9) := '8.9. НЕ является российским/иностранным публичным должностным лицом;';
      v_declaration_states(10) := '8.10. Имеет постоянную работу (постоянный источник дохода) в течение последних 12 (двенадцати) месяцев, в том числе не менее 6 (шести) месяцев на последнем месте работы; Состоит в трудовых отношениях с работодателем на основании трудового договора (за исключением трудового договора с индивидуальным частным предпринимателем), заключенного на неопределенный срок и предусматривающего занятость на полный рабочий день. Получает вознаграждения за свой труд в форме ежемесячной заработной платы;  НЕ является акционером (участником) организации работодателя; НЕ является индивидуальным частным предпринимателем; НЕ является близким родственником руководителя работодателя (супруг(а), родитель, ребенок, усыновитель, усыновленный, родной брат, родная сестра, дедушка, бабушка, внуки); НЕ является временным, сезонным рабочим, служащим в отрасли, которая подразумевает сезонный характер в работе; НЕ является временно нетрудоспособным по беременности и родам, НЕ находится в отпуске по уходу за ребенком; НЕ уведомлен о намерении работодателя сократить штат сотрудников или о ликвидации организации работодателя;';
      v_declaration_states(11) := '9. Дополнительные условия:';
      v_declaration_states(12) := '9.1. Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_declaration_states(13) := '9.2. Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных Соглашениях к нему.';
    
      v_declaration_states2(1) := 'Да, я могу подписать настоящую Декларацию и заявляю: что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате; что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоров страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 5 000 000 (пять миллионов) рублей для Застрахованных в возрасте от 18 (восемнадцати) лет на дату начала срока страхования и до 60 (шестидесяти) лет на дату окончания срока страхования или превышает 2 500 000 (два миллиона пятьсот тысяч) рублей для Застрахованных в возрасте от 61 (шестидесяти одного) года на дату начала срока страхования и до 65 (шестидесяти пяти) лет на дату окончания срока страхования или превышает 1 500 000 (один миллион пятьсот тысяч) рублей для Застрахованных в возрасте от 66 (шестидесяти шести) лет на дату начала срока страхования и до 70 (семидесяти) лет на дату окончания срока страхования; что я уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультации, лечение и т.д.), предоставлять по требованию страховой  компании ООО «СК «Ренессанс Жизнь» копии медицинских документов (результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оценкой степени страхового риска, так и в связи со страховыми случаями по данному договору страхования; что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны; что я прочел(-ла), понял(-а) и согласен(-на) с «Полисными условиями  страхования жизни и здоровья заемщиков кредита».';
      v_declaration_states2(2) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ «О персональных данных» №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору с ООО «Рольф», перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору, об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Подтверждаю, что ни  я, ни мои  родственники не занимают должности членов Совета директоров Банка России, должности в законодательном, исполнительном, административном, судебном органе РФ или других стран; должности в Банке России, государственных и иных организациях, созданных РФ на основании федеральных законов; должности в публичных международных организациях. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора. Настоящее согласие на обработку персональных данных может быть отозвано посредством направления письменного уведомления в адрес Страховщика.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2
                       ,par_print_subindex      => FALSE);
    
    END print_declaration_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      IF v_product_brief IN ('CR103_15_Toyota', 'CR103_16_Toyota')
      THEN
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.1. Выгодоприобретателями по страховому риску «Смерть ЛП» настоящего Договора,являются  Наследники Застрахованного.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.2. Выгодоприобретателем  по страховому риску  «Инвалидность» является Застрахованный;'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.4. Выгодоприобретателем по риску «Временная  утрата трудоспособности Застрахованного в результате несчастного случая»  и по риску «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам»  является Застрахованный.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
      ELSE
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.1. Первым Выгодоприобретателем по страховым рискам «Смерть ЛП» и «Инвалидность» настоящего Договора,  в доле, равной размеру фактической задолженности Застрахованного по кредиту, но не более суммы страховой выплаты является: ' ||
                                               nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                  ,par_separator => ', ')
                                                  ,'____________________________') || '.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.2. Выгодоприобретателями  по страховому риску  «Смерть ЛП» в доле, оставшейся после исполнения обязательств по  страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, являются: Наследники Застрахованного; 7.3. Выгодоприобретателем по страховому риску «Инвалидность» в доле, оставшейся после исполнения обязательств по страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего Договора, является  Застрахованное лицо; 7.4. Выгодоприобретателем по риску «Временная  утрата трудоспособности Застрахованного в результате несчастного случая»  и по риску «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам»  является Застрахованный. '
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
      END IF;
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer pkg_report_signer.typ_signer;
    BEGIN
    
      v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 2;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
      pkg_rep_plpdf.gv_datas(2) := 'Страховщик';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подписывая настоящий договор страхования, подтверждаю достоверность утверждений в вышеуказанной декларации.
 Полисные условия по программе страхования жизни и здоровья заёмщиков кредита получил(а), ознакомлен(а) в полном объеме и согласен(на).
 С назначением выгодоприобретателей согласен (на)';
      pkg_rep_plpdf.gv_datas(2) := 'Вице-Президент  по операционным вопросам и информационным технологиям ' ||
                                   v_signer.short_name || ' действующего на основании доверенности №' ||
                                   v_signer.procuratory_num;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись                                                                    Расшифровка подписи' ||
                                   chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
    PROCEDURE print_programma_description IS
    BEGIN
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПРОГРАММА СТРАХОВАНИЯ: ' || v_pol_sum.product_name
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
    END;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    IF v_pol_sum.product_brief IN ('CR103_11_Renault', 'CR103_10_Renault', 'CR103_13', 'CR103_14')
    THEN
      SELECT COUNT(*)
        INTO v_cnt_benef
        FROM dual
       WHERE EXISTS (SELECT *
                FROM as_asset       aa
                    ,as_beneficiary ab
                    ,contact        c
               WHERE aa.p_policy_id = v_policy_id
                 AND aa.as_asset_id = ab.as_asset_id
                 AND ab.contact_id = c.contact_id
                 AND upper(c.obj_name_orig) LIKE '%ЮНИКРЕДИТ%');
    END IF;
  
    IF v_cnt_benef > 0
    THEN
      v_product_brief := 'CR103_15_Toyota';
    ELSE
      v_product_brief := v_pol_sum.product_brief;
    END IF;
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => 'ДОГОВОР СТРАХОВАНИЯ ПО ПРОГРАММЕ СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ  КРЕДИТА №            '
                ,par_policyform_note => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита (Приложение №1 к настоящему Договору страхования)');
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency_custom(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММА СТРАХОВАНИЯ
    -------------------------------------------------------------------------------------------------
    print_programma_description;
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    --    plpdf.newpage;
    print_declaration_custom;
    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_rolf_2015;

  -- Ирбис CR123%
  -- 397365: Ирбис настройка продуктов
  -- Доброхотова И., март, 2014
  PROCEDURE rep_irbis
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_irbis';
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски/программы страхования';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'J';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY product_line_sort_order) rn
                                  FROM (SELECT ppl.t_product_line_desc t_product_line_desc
                                              ,plo.id prod_line_option_id
                                              ,plt.sort_order plt_sort_order
                                              ,pl.sort_order product_line_sort_order
                                              ,pl.note
                                              ,nvl(pl.public_description, pl.description) product_line_desc
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY product_line_sort_order)
      LOOP
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := gv_chapter_num || '.' || rec_product_lines.rn || ' ' ||
                                     rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(3) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(6) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ:  Единовременно '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма по рискам «Смерть ЛП» и «Инвалидность» равна размеру первоначальной суммы кредита по кредитному договору на момент его заключения. В течение действия договора страхования страховая сумма уменьшается в соответствии с первоначальным графиком платежей и равна ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком платежей.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** Любая причина - событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при условии, что к моменту самоубийства договор страхования действовал не менее двух лет.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет наркотики, токсические вещества, НЕ страдает алкоголизмом, и/или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.; ';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений;';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения;';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие долгосрочной госпитализации и не связанные с жизнью) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время  за исключением обращений к стоматологу и/или прохождения периодических осмотров, в течение ближайшего месяца с момента подписания настоящей Декларации;';
      v_declaration_states(6) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, декларацию можно подписать; рост 160 см, вес 85 кг, разница - 75 - –декларацию подписать нельзя).';
      v_declaration_states(9) := 'Имеет постоянную работу (постоянный источник дохода) в течение последних 12 (двенадцати) месяцев, в том числе не менее 4 (четырех) месяцев на последнем месте работы; Состоит в трудовых отношениях с работодателем на основании трудового договора (за исключением трудового договора с индивидуальным частным предпринимателем), заключенного на неопределенный срок и предусматривающего занятость на полный рабочий день. Получает вознаграждения за свой труд в форме ежемесячной заработной платы;  НЕ является акционером (участником) организации работодателя; НЕ является индивидуальным частным предпринимателем; НЕ является близким родственником руководителя работодателя (супруг(а), родитель, ребенок, усыновитель, усыновленный, родной брат, родная сестра, дедушка, бабушка, внуки); НЕ является временным, сезонным рабочим, служащим в отрасли, которая подразумевает сезонный характер в работе; НЕ является временно нетрудоспособным по беременности и родам, НЕ находится в отпуске по уходу за ребенком; НЕ уведомлен о намерении работодателя сократить штат сотрудников или о ликвидации организации работодателя; НЕ является иностранным публичным должностным лицом, НЕ является российским публичным должностным лицом или его родственником.';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате; что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоров страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 3 500 000 (три миллиона пятьсот тысяч)  рублей;что я уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультации, лечение и т.д.), предоставлять по требованию страховой  компании ООО «СК «Ренессанс Жизнь» копии медицинских документов (результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оценкой степени страхового риска, так и в связи со страховыми случаями по данному договору страхования; что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны; что я прочел(-ла), понял(-а) и согласен(-на) с «Полисными условиями  страхования жизни и здоровья заемщиков кредита».';
      v_declaration_states2(2) := 'Подписывая настоящий Договор, Страхователь в соответствии c ФЗ РФ «О персональных данных» №152-ФЗ от 27.07.2006 выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору с ООО «СТОА» перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услугна рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях обеспечения исполнения настоящего Договора, а также выражает Страховщику согласие на предоставление Выгодоприобретателю информации по настоящему Договору, об исполнении Страховщиком и/или Страхователем обязательств по настоящему Договору, в том числе информацию об оплате и размере страховой премии, размере страховой суммы, о возникновении и урегулировании претензий, наступлении/вероятности наступления страховых случаев, страховой выплате и другую имеющую отношение к настоящему Договору информацию. Подтверждаю, что ни  я, ни мои  родственники не занимают должности членов Совета директоров Банка России, должности в законодательном, исполнительном, административном, судебном органе РФ или других стран; должности в Банке России, государственных и иных организациях, созданных РФ на основании федеральных законов; должности в публичных международных организациях. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора. Настоящее согласие на обработку персональных данных может быть отозвано посредством направления письменного уведомления в адрес Страховщика.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных соглашениях к нему.';
      v_add_cond_states(3) := 'В случае отказа Страхователя от договора страхования возврат части страховой премии осуществляется в соответствии с порядком, предусмотренным п. 11.3 Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита.  ';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. Выгодоприобретателем по страховым рискам «Смерть ЛП» и «Инвалидность» настоящего Договора,  в доле, равной размеру фактической задолженности Застрахованного по кредиту, но не более суммы страховой выплаты является: ' ||
                                             nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                ,par_separator => ', ')
                                                ,'____________________________') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. Выгодоприобретателями  по страховому риску  «Смерть ЛП» в доле, оставшейся после исполнения обязательств по  страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, являются следующие лица: наследники Застрахованного;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. Выгодоприобретателем по страховому риску «Инвалидность» в доле, оставшейся после исполнения обязательств по страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, является  Застрахованное лицо;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.4. Выгодоприобретателем по риску «Временная утрата трудоспособности Застрахованного, наступившая по любой причине» и по программе «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам»  является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    END print_beneficiaries_custom;
  
    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer pkg_report_signer.typ_signer;
    BEGIN
    
      v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 2;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
      pkg_rep_plpdf.gv_datas(2) := 'Страховщик';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подписывая настоящий договор страхования, подтверждаю достоверность утверждений в вышеуказанной Декларации. Полисные условия по программе страхования жизни и здоровья Заёмщиков кредита получил (а), ознакомлен (а) в полном объеме и согласен(на). С назначением Выгодоприобретателей согласен (на)';
      pkg_rep_plpdf.gv_datas(2) := 'Представитель по доверенности ' || v_signer.short_name || chr(13) ||
                                   '(дов №' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись                                                                    Расшифровка подписи' ||
                                   chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
    PROCEDURE print_insuree_custom
    (
      par_insuree_info pkg_rep_plpdf.t_contact_summary
     ,par_pol_sum      pkg_rep_plpdf.t_policy_summary
    ) IS
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
      v_yes       VARCHAR2(2);
      v_no        VARCHAR2(2);
      v_rowheight NUMBER;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*Заполняем паспортные данные только при наличии паспорта (модифицировано 28.04.2014 Черных М.Г. исправлено no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF; /*конец модификации 28.04.2014*/
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_w        => plpdf.getpagespace - 5
                     ,p_txt      => l_doc_place
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Кем и когда выдан'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      gv_datas(1) := pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                               ,par_brief      => 'CONST')
                                                              ,'<#ADDRESS_FULL>');
      gv_widths(1) := 95;
      gv_maxlines(1) := 2;
      v_rowheight := plpdf.getrowheight(p_data => gv_datas
                                        
                                       ,p_width   => gv_widths
                                       ,p_maxline => gv_maxlines
                                       ,p_h       => gv_default_height);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_h        => v_rowheight
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => v_rowheight
                     ,p_txt      => 'Адрес'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 95
                              ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                                       ,par_brief      => 'CONST')
                                                                                      ,'<#ADDRESS_FULL>')
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_h => v_rowheight
                     ,p_w => 35
                      
                     ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => v_rowheight
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                           ,'<#EMAIL_LOWER>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 25
                     ,p_txt      => 'Индекс'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    END print_insuree_custom;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ  КРЕДИТА '
                ,par_policyform_note => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита');
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------
    print_additional_cond_custom;
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_irbis;

  -- Автодом БМВ
  -- CR107_8  - CR107_8 БМВ Базовая 
  -- CR107_9  - CR107_9 БМВ Спешл
  -- CR107_10 - CR107_10 БМВ Премиум
  PROCEDURE rep_avtodom_bmw
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_irbis';
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски/программы страхования';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'J';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY product_line_sort_order) rn
                                  FROM (SELECT ppl.t_product_line_desc t_product_line_desc
                                              ,plo.id prod_line_option_id
                                              ,plt.sort_order plt_sort_order
                                              ,pl.sort_order product_line_sort_order
                                              ,pl.note
                                              ,nvl(pl.public_description, pl.description) product_line_desc
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY product_line_sort_order)
      LOOP
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := gv_chapter_num || '.' || rec_product_lines.rn || ' ' ||
                                     rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(3) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(6) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL /*'1'*/
       ;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ:  Единовременно '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма по рискам «Смерть ЛП» и «Инвалидность» устанавливается в соответствии с п. 7.2. Полисных условий и равна размеру первоначальной суммы кредита по кредитному договору на момент его заключения и уменьшается в соответствии с первоначальным графиком платежей и равна ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком платежей.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма по рискам «ВНТ НС», «ВНТ ЛП» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма по программе «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** Любая причина – событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при условии, что к моменту самоубийства договор страхования действовал не менее двух лет.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_currency_custom
    (
      par_policy_summary pkg_rep_plpdf.t_policy_summary
     ,par_box_size       NUMBER DEFAULT 2
     ,par_box_delta_y    NUMBER DEFAULT 1
    ) IS
      v_text VARCHAR2(500);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      v_text := gv_chapter_num || '. ВАЛЮТА ДОГОВОРА:';
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => v_text
                     ,p_w        => plpdf.gettextwidth(v_text) + 5
                     ,p_border   => 'LTB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      FOR rec IN (SELECT f.name
                        ,nvl2(lead(1) over(ORDER BY f.fund_id DESC), 0, 1) is_last
                        ,decode(f.brief
                               ,par_policy_summary.fund_brief
                               ,pkg_rep_plpdf.gc_rect_marked
                               ,pkg_rep_plpdf.gc_rect_unmarked) marked
                    FROM t_product       p
                        ,t_prod_currency pc
                        ,fund            f
                   WHERE p.product_id = pc.product_id
                     AND pc.currency_id = f.fund_id
                     AND p.product_id = par_policy_summary.product_id
                   ORDER BY /*pc.is_default DESC NULLS LAST,*/ f.fund_id DESC)
      LOOP
        plpdf.drawrect(p_x     => plpdf.getcurrentx
                      ,p_y     => plpdf.getcurrenty + par_box_delta_y --1
                      ,p_w     => par_box_size --2
                      ,p_h     => par_box_size --2
                      ,p_style => rec.marked);
      
        plpdf.printcell(p_border   => 'TB'
                       ,p_w        => 5
                       ,p_ln       => 0
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      
        plpdf.printcell(p_h        => gv_default_height
                       ,p_w        => plpdf.gettextwidth(rec.name) + 5
                       ,p_txt      => rec.name
                       ,p_border   => 'TB'
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                       ,p_ln       => 0);
      END LOOP;
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => 'Марка автомобиля: '
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'R'
                     ,p_border   => 'TB'
                     ,p_ln       => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 30
                     ,p_txt      => pkg_doc_properties.get_string(v_policy_id, 'CAR_MAKE')
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'C'
                     ,p_border   => 1
                     ,p_ln       => 0);
    
      plpdf.printcell(p_ln       => 1
                     ,p_border   => 'BTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
    END print_currency_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет наркотики, токсические вещества, НЕ страдает алкоголизмом, и/или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.; ';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений; ';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения; ';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие долгосрочной госпитализации и не связанные с жизнью) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время  за исключением обращений к стоматологу и/или прохождения периодических осмотров, в течение ближайшего месяца с момента подписания настоящей Декларации; ';
      v_declaration_states(6) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, декларацию можно подписать; рост 160 см, вес 85 кг, разница - 75 - –декларацию подписать нельзя).';
      v_declaration_states(9) := 'Имеет постоянную работу (постоянный источник дохода) в течение последних 12 (двенадцати) месяцев, в том числе не менее 4 (четырех) месяцев на последнем месте работы; Состоит в трудовых отношениях с работодателем на основании трудового договора (за исключением трудового договора с индивидуальным частным предпринимателем), заключенного на неопределенный срок и предусматривающего занятость на полный рабочий день. Получает вознаграждения за свой труд в форме ежемесячной заработной платы;  НЕ является акционером (участником) организации работодателя; НЕ является индивидуальным частным предпринимателем; НЕ является близким родственником руководителя работодателя (супруг(а), родитель, ребенок, усыновитель, усыновленный, родной брат, родная сестра, дедушка, бабушка, внуки); НЕ является временным, сезонным рабочим, служащим в отрасли, которая подразумевает сезонный характер в работе; НЕ является временно нетрудоспособным по беременности и родам, НЕ находится в отпуске по уходу за ребенком; НЕ уведомлен о намерении работодателя сократить штат сотрудников или о ликвидации организации работодателя; НЕ является иностранным публичным должностным лицом, НЕ является российским публичным должностным лицом.';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате; что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоров страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 5 250 000 (пять миллионов двести пятьдесят тысяч)  рублей; что я уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультации, лечение и т.д.), предоставлять по требованию страховой  компании ООО «СК «Ренессанс Жизнь» копии медицинских документов (результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оценкой степени страхового риска, так и в связи со страховыми случаями по данному договору страхования; что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Подтверждаю, что ни я, ни мои родственники не занимают должности членов Совета директоров Банка России, должности в законодательном, исполнительном, административном, судебном органе РФ или других стран; должности в Банке России, государственных и иных организациях, созданных РФ на основании федеральных законов; должности в публичных международных организациях. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны; что я прочел(-ла), понял(-а) и согласен(-на) с «Полисными условиями  страхования жизни и здоровья заемщиков кредита».';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных соглашениях к нему.';
      v_add_cond_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c Федеральным законом от 27 июля 2006 г. № 152-ФЗ «О персональных данных» выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору с ОАО «Автодом», перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях заключения между Страхователем и Страховщиком договора страхования. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора и может быть отозвано Страхователем (Застрахованным) в любой момент времени путем передачи Страховщику подписанного Страхователем (Застрахованным) письменного уведомления.';
      v_add_cond_states(4) := 'В случае отказа Страхователя от договора страхования возврат части страховой премии осуществляется в соответствии с порядком, предусмотренным п. 11.3 Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита.';
    
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. Выгодоприобретателями по страховому риску «Смерть ЛП» настоящего Договора являются  Наследники Застрахованного.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. Выгодоприобретателем  по страховому риску  «Инвалидность» является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. Выгодоприобретателем по рискам «Временная  утрата трудоспособности Застрахованного в результате несчастного случая», «Временная утрата трудоспособности, наступившая по любой причине»  и по риску «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам»  является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    END print_beneficiaries_custom;
  
    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer pkg_report_signer.typ_signer;
    BEGIN
    
      v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 2;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
      pkg_rep_plpdf.gv_datas(2) := 'Страховщик';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подписывая настоящий договор страхования, подтверждаю достоверность утверждений в вышеуказанной Декларации. Полисные условия по программе страхования жизни и здоровья Заёмщиков кредита получил (а), ознакомлен (а) в полном объеме и согласен(на). С назначением Выгодоприобретателей согласен (на)';
      pkg_rep_plpdf.gv_datas(2) := 'Представитель по доверенности ' || v_signer.short_name || chr(13) ||
                                   '(дов №' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись                                                                    Расшифровка подписи' ||
                                   chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
    PROCEDURE print_insuree_custom
    (
      par_insuree_info pkg_rep_plpdf.t_contact_summary
     ,par_pol_sum      pkg_rep_plpdf.t_policy_summary
    ) IS
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
      v_yes       VARCHAR2(2);
      v_no        VARCHAR2(2);
      v_rowheight NUMBER;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h => gv_default_height
                      --                     ,p_w        => 50
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*Заполняем паспортные данные только при наличии паспорта (модифицировано 28.04.2014 Черных М.Г. исправлено no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF; /*конец модификации 28.04.2014*/
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell( /*p_h        => -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,*/p_w        => plpdf.getpagespace - 5
                     ,p_txt      => l_doc_place
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Кем и когда выдан'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      gv_datas(1) := pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                               ,par_brief      => 'CONST')
                                                              ,'<#ADDRESS_FULL>');
      gv_widths(1) := 95;
      gv_maxlines(1) := 2;
      v_rowheight := plpdf.getrowheight(p_data => gv_datas
                                        
                                       ,p_width   => gv_widths
                                       ,p_maxline => gv_maxlines
                                       ,p_h       => gv_default_height);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_h        => v_rowheight
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => v_rowheight
                     ,p_txt      => 'Адрес'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 95
                              ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                                       ,par_brief      => 'CONST')
                                                                                      ,'<#ADDRESS_FULL>')
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_h => v_rowheight
                     ,p_w => 35
                      
                     ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => v_rowheight
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                           ,'<#EMAIL_LOWER>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => 'Индекс'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    END print_insuree_custom;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    --print_header_custom(par_policyid => v_policy_id, par_policy_summary => v_pol_sum, par_title => );
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ  КРЕДИТА '
                ,par_policyform_note => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита');
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    --    print_insuree(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    --    print_currency_custom(par_policy_summary => v_pol_sum);
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- Продукт
    -------------------------------------------------------------------------------------------------
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'ПРОГРАММА СТРАХОВАНИЯ: '
                   ,p_w        => 45
                   ,p_border   => 'LTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => v_pol_sum.product_public_name
                   ,p_border   => 'RTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_cond_custom;
    --    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_avtodom_bmw;

  -- Полис Автодом Автокредит
  -- CR107_11  - Автокредит 2 риска
  -- CR107_12 - Автокредит 3 риска
  -- CR107_13 - Автокредит 4 риска
  PROCEDURE rep_avtodom_avtocredit
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id    p_policy.policy_id%TYPE;
    v_pol_sum      pkg_rep_plpdf.t_policy_summary;
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    c_proc_name CONSTANT pkg_trace.t_object_name := 'rep_irbis';
  
    PROCEDURE print_programs_custom IS
      v_total_fee p_cover.fee%TYPE;
      v_yes       VARCHAR2(2);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num ||
                                    '. СТРАХОВЫЕ РИСКИ, СТРАХОВЫЕ СУММЫ, СТРАХОВЫЕ ПРЕМИИ:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'C';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := 'B';
      pkg_rep_plpdf.gv_styles(5) := 'B';
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := 'Страховые риски/программы страхования';
      pkg_rep_plpdf.gv_datas(3) := 'Страховая сумма*';
      pkg_rep_plpdf.gv_datas(4) := 'Страховая премия';
      pkg_rep_plpdf.gv_datas(5) := 'Размер выплаты';
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 1;
      pkg_rep_plpdf.gv_widths(2) := 60;
      pkg_rep_plpdf.gv_widths(3) := 20;
      pkg_rep_plpdf.gv_widths(4) := 30;
      pkg_rep_plpdf.gv_widths(5) := 78;
      pkg_rep_plpdf.gv_widths(6) := 1;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := '1';
      pkg_rep_plpdf.gv_borders(3) := '1';
      pkg_rep_plpdf.gv_borders(4) := '1';
      pkg_rep_plpdf.gv_borders(5) := '1';
      pkg_rep_plpdf.gv_borders(6) := 'LR';
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
      pkg_rep_plpdf.gv_styles(3) := NULL;
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := NULL;
      pkg_rep_plpdf.gv_aligns(2) := 'L';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := 'C';
      pkg_rep_plpdf.gv_aligns(5) := 'J';
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_maxlines(1) := NULL;
      pkg_rep_plpdf.gv_maxlines(2) := NULL;
      pkg_rep_plpdf.gv_maxlines(3) := NULL;
      pkg_rep_plpdf.gv_maxlines(4) := NULL;
      pkg_rep_plpdf.gv_maxlines(5) := NULL;
      pkg_rep_plpdf.gv_maxlines(6) := NULL;
    
      FOR rec_product_lines IN (SELECT pc.t_prod_line_option_id
                                      ,product_line_desc
                                      ,pkg_rep_utils.to_money_sep(cover_ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(cover_premium) fee
                                      ,pl.note
                                      ,row_number() over(ORDER BY product_line_sort_order) rn
                                  FROM (SELECT ppl.t_product_line_desc t_product_line_desc
                                              ,plo.id prod_line_option_id
                                              ,plt.sort_order plt_sort_order
                                              ,pl.sort_order product_line_sort_order
                                              ,pl.note
                                              ,nvl(pl.public_description, pl.description) product_line_desc
                                          FROM v_prod_product_line ppl
                                              ,p_pol_header        ph
                                              ,p_policy            pp
                                              ,t_product_line      pl
                                              ,t_product_line_type plt
                                              ,t_prod_line_option  plo
                                         WHERE pp.policy_id = v_policy_id
                                           AND pp.pol_header_id = ph.policy_header_id
                                           AND ph.product_id = ppl.product_id
                                           AND ppl.t_product_line_id = pl.id
                                           AND pl.product_line_type_id = plt.product_line_type_id
                                           AND pl.id = plo.product_line_id
                                           AND ppl.t_product_line_desc !=
                                               'Административные издержки на восстановление') pl
                                       
                                      ,(SELECT pc.t_prod_line_option_id
                                              ,pc.start_date cover_start_date
                                              ,trunc(pc.end_date) cover_end_date
                                              ,pc.ins_amount cover_ins_amount
                                              ,pc.premium cover_premium
                                          FROM as_asset aa
                                              ,p_cover  pc
                                         WHERE aa.p_policy_id = v_policy_id
                                           AND aa.as_asset_id = pc.as_asset_id) pc
                                 WHERE pl.prod_line_option_id = pc.t_prod_line_option_id(+)
                                 ORDER BY product_line_sort_order)
      LOOP
      
        pkg_rep_plpdf.gv_datas(1) := NULL;
        pkg_rep_plpdf.gv_datas(2) := gv_chapter_num || '.' || rec_product_lines.rn || ' ' ||
                                     rec_product_lines.product_line_desc;
        pkg_rep_plpdf.gv_datas(3) := rec_product_lines.ins_amount;
        pkg_rep_plpdf.gv_datas(4) := rec_product_lines.fee;
        pkg_rep_plpdf.gv_datas(5) := rec_product_lines.note;
        pkg_rep_plpdf.gv_datas(6) := NULL;
      
        pkg_rep_plpdf.row_print2(par_h => gv_default_height);
      
      END LOOP;
    
      SELECT nvl(SUM(pc.fee), 0)
        INTO v_total_fee
        FROM p_cover  pc
            ,as_asset aa
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = pc.as_asset_id;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := 81;
      pkg_rep_plpdf.gv_widths(2) := 30;
      pkg_rep_plpdf.gv_widths(3) := 78;
      pkg_rep_plpdf.gv_widths(4) := 1;
      pkg_rep_plpdf.gv_widths(5) := NULL;
      pkg_rep_plpdf.gv_widths(6) := NULL;
    
      pkg_rep_plpdf.gv_aligns(1) := 'R';
      pkg_rep_plpdf.gv_aligns(2) := 'C';
      pkg_rep_plpdf.gv_aligns(3) := 'C';
      pkg_rep_plpdf.gv_aligns(4) := NULL;
      pkg_rep_plpdf.gv_aligns(5) := NULL;
      pkg_rep_plpdf.gv_aligns(6) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := 'B';
      pkg_rep_plpdf.gv_styles(2) := 'B';
      pkg_rep_plpdf.gv_styles(3) := 'B';
      pkg_rep_plpdf.gv_styles(4) := NULL;
      pkg_rep_plpdf.gv_styles(5) := NULL;
      pkg_rep_plpdf.gv_styles(6) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'L';
      pkg_rep_plpdf.gv_borders(2) := NULL /*'1'*/
       ;
      pkg_rep_plpdf.gv_borders(3) := NULL;
      pkg_rep_plpdf.gv_borders(4) := 'R';
      pkg_rep_plpdf.gv_borders(5) := NULL;
      pkg_rep_plpdf.gv_borders(6) := NULL;
    
      pkg_rep_plpdf.gv_datas(1) := 'ИТОГО СТРАХОВАЯ ПРЕМИЯ:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'ПЕРИОДИЧНОСТЬ ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ:  Единовременно '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* Страховая сумма по рискам «Смерть ЛП» и «Инвалидность» устанавливается в соответствии с п. 7.2. Полисных условий и равна размеру первоначальной суммы кредита по кредитному договору на момент его заключения и уменьшается в соответствии с первоначальным графиком платежей и равна ссудной задолженности на дату наступления страхового случая в соответствии с первоначальным графиком платежей.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма по рискам «ВНТ НС», «ВНТ ЛП» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Страховая сумма по программе «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам» равна размеру первоначальной суммы кредита Застрахованного по кредитному договору на момент его заключения.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** Любая причина – событие (болезнь или несчастный случай), возникшее в течение действия договора, а также  самоубийство, при условии, что к моменту самоубийства договор страхования действовал не менее двух лет.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'Договор страхования вступает в силу с 00:00 часов дня, следующего за датой оплаты Страхователем в полном объеме первого страхового взноса Страховщику / представителю Страховщика, если иная (более поздняя) дата начала срока действия Договора страхования не указана в Договоре страхования.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_currency_custom
    (
      par_policy_summary pkg_rep_plpdf.t_policy_summary
     ,par_box_size       NUMBER DEFAULT 2
     ,par_box_delta_y    NUMBER DEFAULT 1
    ) IS
      v_text VARCHAR2(500);
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      v_text := gv_chapter_num || '. ВАЛЮТА ДОГОВОРА:';
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => v_text
                     ,p_w        => plpdf.gettextwidth(v_text) + 5
                     ,p_border   => 'LTB'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      FOR rec IN (SELECT f.name
                        ,nvl2(lead(1) over(ORDER BY f.fund_id DESC), 0, 1) is_last
                        ,decode(f.brief
                               ,par_policy_summary.fund_brief
                               ,pkg_rep_plpdf.gc_rect_marked
                               ,pkg_rep_plpdf.gc_rect_unmarked) marked
                    FROM t_product       p
                        ,t_prod_currency pc
                        ,fund            f
                   WHERE p.product_id = pc.product_id
                     AND pc.currency_id = f.fund_id
                     AND p.product_id = par_policy_summary.product_id
                   ORDER BY /*pc.is_default DESC NULLS LAST,*/ f.fund_id DESC)
      LOOP
        plpdf.drawrect(p_x     => plpdf.getcurrentx
                      ,p_y     => plpdf.getcurrenty + par_box_delta_y --1
                      ,p_w     => par_box_size --2
                      ,p_h     => par_box_size --2
                      ,p_style => rec.marked);
      
        plpdf.printcell(p_border   => 'TB'
                       ,p_w        => 5
                       ,p_ln       => 0
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      
        plpdf.printcell(p_h        => gv_default_height
                       ,p_w        => plpdf.gettextwidth(rec.name) + 5
                       ,p_txt      => rec.name
                       ,p_border   => 'TB'
                       ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                       ,p_ln       => 0);
      END LOOP;
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => 'Марка автомобиля: '
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'R'
                     ,p_border   => 'TB'
                     ,p_ln       => 0);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 30
                     ,p_txt      => pkg_doc_properties.get_string(v_policy_id, 'CAR_MAKE')
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_align    => 'C'
                     ,p_border   => 1
                     ,p_ln       => 0);
    
      plpdf.printcell(p_ln       => 1
                     ,p_border   => 'BTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
    END print_currency_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := 'НЕ является инвалидом, лицом, требующим постоянного ухода; НЕ имеет нарушения опорно-двигательной системы, ограничивающие движение; НЕ страдает мышечной дистрофией, нервными расстройствами, психическими заболеваниями; НЕ употребляет наркотики, токсические вещества, НЕ страдает алкоголизмом, и/или НЕ состоит по перечисленным причинам на диспансерном учете; НЕ является ВИЧ-инфицированным или НЕ страдает СПИДом (синдромом приобретенного иммунного дефицита), а также НЕ страдает иными заболеваниями, ограничивающими физическую активность или повышающими риск травмы, включая нарушения зрения, слуха, функции органов равновесия и т.д.; ';
      v_declaration_states(2) := 'НЕ находится в изоляторе временного содержания или других учреждениях, предназначенных для содержания лиц, подозреваемых или обвиняемых в совершении преступлений; ';
      v_declaration_states(3) := 'НЕ страдает/страдал(а) следующими заболеваниями: близорукостью более 7 (семи) диоптрий, хроническая почечная недостаточность, поликистоз почек, неспецифический язвенный колит, болезнь Крона, сахарный диабет, гемофилия, сердечнососудистая патология (включая ишемическую болезнь сердца, аритмии (включая мерцательную аритмию), гипертонию (II-IV степени), тромбоэмболии, аневризмы сосудов, перенесенные инфаркты, инсульты, операции на сердце и сосудах и т.п.), цирроз печени, хронический гепатит, злокачественные или доброкачественные опухоли, туберкулез, а также иными хроническими заболеваниями, требующими постоянных консультаций, лечения, обследований или наблюдения; ';
      v_declaration_states(4) := 'За последние 2 (два) года НЕ находился на больничном листе сроком 3 (три) недели подряд и более (счет по каждому году, не учитывая острую респираторную инфекцию, грипп, травмы, не требующие долгосрочной госпитализации и не связанные с жизнью) и/или НЕ был направлен на стационарное лечение, или за последние 12 месяцев НЕ обращался за медицинской помощью, обследованием или консультацией по причине одного и того же заболевания более одного раза;';
      v_declaration_states(5) := 'В настоящий момент НЕ находится под наблюдением врача, на лечении, НЕ принимает лекарства в связи с каким-либо заболеванием (нарушением здоровья) или в отношении него НЕ запланировано лечение/операция и он/она НЕ планирует обратиться к врачу по причине какого-либо заболевания в ближайшее время  за исключением обращений к стоматологу и/или прохождения периодических осмотров, в течение ближайшего месяца с момента подписания настоящей Декларации; ';
      v_declaration_states(6) := 'НЕ связан с особым риском в связи с трудовой деятельностью (например: облучение, работа с химическими и взрывчатыми веществами, источниками повышенной опасности, работа на высоте, под землей, под водой, на нефтяных и газовых платформах, с оружием, в правоохранительных органах, инкассация, испытания, частые (более одного раза в месяц) командировки и т.п.), а также НЕ занимается опасными видами спорта или опасными видами увлечений (хобби);';
      v_declaration_states(7) := 'НЕ подавал заявления на страхование жизни, страхование от несчастных случаев и болезней, утраты трудоспособности (инвалидности), от несчастных случаев, в которых ему/ей было отказано, которые были отложены или приняты на особых условиях (с применением повышающих коэффициентов, исключений или особых условий), а также заключенных договоров страхования, которые были расторгнуты по причине невозможности заключения или существенные условия которых были изменены по  результатам оценки степени риска;';
      v_declaration_states(8) := 'НЕ выкуривает более 30 (тридцати) сигарет в день. Разница между ростом (в см.) и весом (в кг.) Застрахованного не менее 80 и не более 120 (например, рост - 180 см, вес - 85 кг, разница составляет - 95, декларацию можно подписать; рост 160 см, вес 85 кг, разница - 75 - –декларацию подписать нельзя).';
      v_declaration_states(9) := 'Имеет постоянную работу (постоянный источник дохода) в течение последних 12 (двенадцати) месяцев, в том числе не менее 4 (четырех) месяцев на последнем месте работы; Состоит в трудовых отношениях с работодателем на основании трудового договора (за исключением трудового договора с индивидуальным частным предпринимателем), заключенного на неопределенный срок и предусматривающего занятость на полный рабочий день. Получает вознаграждения за свой труд в форме ежемесячной заработной платы;  НЕ является акционером (участником) организации работодателя; НЕ является индивидуальным частным предпринимателем; НЕ является близким родственником руководителя работодателя (супруг(а), родитель, ребенок, усыновитель, усыновленный, родной брат, родная сестра, дедушка, бабушка, внуки); НЕ является временным, сезонным рабочим, служащим в отрасли, которая подразумевает сезонный характер в работе; НЕ является временно нетрудоспособным по беременности и родам, НЕ находится в отпуске по уходу за ребенком; НЕ уведомлен о намерении работодателя сократить штат сотрудников или о ликвидации организации работодателя; НЕ является иностранным публичным должностным лицом, НЕ является российским публичным должностным лицом.';
    
      v_declaration_states2(1) := 'что я согласен(-на) с утверждениями настоящей Декларации, т.е. я подтверждаю достоверность сведений, содержащихся в этих утверждениях. Я понимаю, что предоставление ложных и/или неполных сведений, равно как и отказ в предоставлении информации, может повлечь отказ в страховой выплате; что в отношении Застрахованного не заключены и не поданы заявления на заключение других договоров страхования жизни и/или от несчастных случаев в ООО «СК «Ренессанс Жизнь», по которым страховые суммы в отношении каждого риска в сумме со страховыми суммами по аналогичным рискам по данному Договору превышают 5 250 000 (пять миллионов двести пятьдесят тысяч)  рублей; что я уполномочиваю любого врача и/или любое лечебное учреждение, предоставлявших мне медицинские услуги (обследования, консультации, лечение и т.д.), предоставлять по требованию страховой  компании ООО «СК «Ренессанс Жизнь» копии медицинских документов (результаты лабораторных и инструментальных исследований, результаты лечения, прогноз по заболеванию и т.д.) как в связи с оценкой степени страхового риска, так и в связи со страховыми случаями по данному договору страхования; что я обязуюсь незамедлительно письменно уведомить Страховщика в случае изменения степени риска при первой представившейся возможности. Подтверждаю, что ни я, ни мои родственники не занимают должности членов Совета директоров Банка России, должности в законодательном, исполнительном, административном, судебном органе РФ или других стран; должности в Банке России, государственных и иных организациях, созданных РФ на основании федеральных законов; должности в публичных международных организациях. Я понимаю, что изменение степени риска может повлечь оплату дополнительной страховой премии и/или изменение условий договора страхования. Я также понимаю, что в случае моего отказа проинформировать Страховщика об изменении степени риска и уплатить дополнительную страховую премию и/или изменить условия страхования, договор страхования будет расторгнут Страховщиком в одностороннем порядке и страховые выплаты по нему будут невозможны; что я прочел(-ла), понял(-а) и согласен(-на) с «Полисными условиями  страхования жизни и здоровья заемщиков кредита».';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := 'Все письменные заявления Страхователя, относящиеся к настоящему Договору, а также все Приложения и дополнения к настоящему Договору, являются его составной и неотъемлемой частью.';
      v_add_cond_states(2) := 'Стороны признают равную юридическую силу собственноручной подписи и факсимиле подписи Страховщика (воспроизведенное механическим или иным способом с использованием клише) в настоящем Договоре, а также во всех Приложениях и дополнительных соглашениях к нему.';
      v_add_cond_states(3) := 'Подписывая настоящий Договор, Страхователь в соответствии c Федеральным законом от 27 июля 2006 г. № 152-ФЗ «О персональных данных» выражает Страховщику согласие на обработку, в том числе передачу Агенту по Агентскому договору с ОАО «Автодом», перестраховочным организациям (в том числе находящимся за рубежом) своих персональных данных, в том числе данных о состоянии здоровья, содержащихся в документах, передаваемых Страховщику в целях продвижения товаров, работ, услуг на рынке путём осуществления прямых контактов с помощью средств связи, в том числе в целях заключения между Страхователем и Страховщиком договора страхования. Настоящее согласие Страхователя/Застрахованного действительно в течение срока действия настоящего Договора и в течение 15 лет после окончания срока действия настоящего Договора и может быть отозвано Страхователем (Застрахованным) в любой момент времени путем передачи Страховщику подписанного Страхователем (Застрахованным) письменного уведомления.';
      v_add_cond_states(4) := 'В случае отказа Страхователя от договора страхования возврат части страховой премии осуществляется в соответствии с порядком, предусмотренным п. 11.3 Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита.';
    
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
    PROCEDURE print_beneficiaries_custom IS
      v_benif_array tt_one_col;
    BEGIN
    
      SELECT DISTINCT c.obj_name_orig
        BULK COLLECT
        INTO v_benif_array
        FROM as_asset       aa
            ,as_beneficiary ab
            ,contact        c
       WHERE aa.p_policy_id = v_policy_id
         AND aa.as_asset_id = ab.as_asset_id
         AND ab.contact_id = c.contact_id;
    
      gv_chapter_num := gv_chapter_num + 1;
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => gv_chapter_num || '. ВЫГОДОПРИОБРЕТАТЕЛЬ:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. Первым Выгодоприобретателем по страховым рискам «Смерть ЛП» и «Инвалидность» настоящего Договора,  в доле, равной размеру фактической задолженности Застрахованного по кредиту, но не более суммы страховой выплаты является: ' ||
                                             nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                ,par_separator => ', ')
                                                ,'____________________________') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. Выгодоприобретателями  по страховому риску  «Смерть ЛП» в доле, оставшейся после исполнения обязательств по  страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, являются Наследники Застрахованного;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. Выгодоприобретателем по страховому риску «Инвалидность» в доле, оставшейся после исполнения обязательств по страховой выплате Первому Выгодоприобретателю, указанному п. 7.1. настоящего договора, является  Застрахованное лицо;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.4. Выгодоприобретателем по риску «ВНТ НС», по риску «ВНТ ЛП» и по программе «Дожитие Застрахованного до потери постоянной работы по независящим от него причинам»  является Застрахованный.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    END print_beneficiaries_custom;
  
    PROCEDURE print_sign_custom
    (
      par_report_exe_name rep_report.exe_name%TYPE
     ,par_policy_summary  pkg_rep_plpdf.t_policy_summary
    ) IS
      v_signer pkg_report_signer.typ_signer;
    BEGIN
    
      v_signer := pkg_report_signer.get_signer_id_by_exe_name(par_report_exe_name);
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    
      IF par_policy_summary.policy_status_desc NOT IN
         ('Ожидает подтверждения из B2B', 'Проект')
      THEN
        plpdf.putimage(p_name => 'image_sign_jpg'
                      ,p_data => v_signer.image_sign_jpg
                      ,p_x    => plpdf.getpagespace - 5 - 45
                      ,p_y    => plpdf.getcurrenty
                      ,p_w    => 45
                      ,p_h    => 50);
      END IF;
    
      pkg_rep_plpdf.delete_row_print_cache;
    
      pkg_rep_plpdf.gv_widths(1) := plpdf.getpagespace / 2;
      pkg_rep_plpdf.gv_widths(2) := pkg_rep_plpdf.gv_widths(1);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_bold;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_bold;
    
      pkg_rep_plpdf.gv_borders(1) := 'LTR';
      pkg_rep_plpdf.gv_borders(2) := 'LTR';
    
      pkg_rep_plpdf.gv_datas(1) := 'Страхователь';
      pkg_rep_plpdf.gv_datas(2) := 'Страховщик';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подписывая настоящий договор страхования, подтверждаю достоверность утверждений в вышеуказанной Декларации. Полисные условия по программе страхования жизни и здоровья Заёмщиков кредита получил (а), ознакомлен (а) в полном объеме и согласен(на). С назначением Выгодоприобретателей согласен (на)';
      pkg_rep_plpdf.gv_datas(2) := 'Представитель по доверенности ' || v_signer.short_name || chr(13) ||
                                   '(дов №' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := 'Подпись                                                                    Расшифровка подписи' ||
                                   chr(13) || 'дата';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
    PROCEDURE print_insuree_custom
    (
      par_insuree_info pkg_rep_plpdf.t_contact_summary
     ,par_pol_sum      pkg_rep_plpdf.t_policy_summary
    ) IS
      l_type_doc  VARCHAR2(4000);
      l_doc_num   VARCHAR2(4000);
      l_doc_place VARCHAR2(4000);
      v_yes       VARCHAR2(2);
      v_no        VARCHAR2(2);
      v_rowheight NUMBER;
    BEGIN
      gv_chapter_num := gv_chapter_num + 1;
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h => gv_default_height
                      --                     ,p_w        => 50
                     ,p_txt      => gv_chapter_num || '. СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Фамилия'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 60
                              ,p_txt      => '          Дата рождения'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => to_char(par_insuree_info.date_of_birth, 'dd.mm.yyyy')
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Имя'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.first_name
                     ,p_align    => 'C'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_border   => '1'
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 60
                     ,p_txt      => '          Документ, удостоверяющий личность'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*Заполняем паспортные данные только при наличии паспорта (модифицировано 28.04.2014 Черных М.Г. исправлено no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>');
      
      END IF; /*конец модификации 28.04.2014*/
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_type_doc
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => 'Отчество'
                     ,p_w        => 25
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                      /*,p_vert_align => 'T'*/);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 50
                     ,p_txt      => par_insuree_info.middle_name
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font;
      plpdf.printcell(p_h        => -1
                     ,p_w        => 60
                     ,p_txt      => NULL
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 50
                              ,p_txt      => l_doc_num
                              ,p_align    => 'C'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font;
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell( /*p_h        => -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,*/p_w        => plpdf.getpagespace - 5
                     ,p_txt      => l_doc_place
                     ,p_align    => 'C'
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => 'Кем и когда выдан'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      gv_datas(1) := pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                               ,par_brief      => 'CONST')
                                                              ,'<#ADDRESS_FULL>');
      gv_widths(1) := 95;
      gv_maxlines(1) := 2;
      v_rowheight := plpdf.getrowheight(p_data => gv_datas
                                        
                                       ,p_width   => gv_widths
                                       ,p_maxline => gv_maxlines
                                       ,p_h       => gv_default_height);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_h        => v_rowheight
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => v_rowheight
                     ,p_txt      => 'Адрес'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_w        => 95
                              ,p_txt      => pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_insuree_info.contact_id
                                                                                                                                       ,par_brief      => 'CONST')
                                                                                      ,'<#ADDRESS_FULL>')
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 0);
    
      plpdf.printcell(p_h => v_rowheight
                     ,p_w => 35
                      
                     ,p_txt      => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_primary_phone_id(par_insuree_info.contact_id))
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_h        => v_rowheight
                     ,p_w        => 35
                     ,p_txt      => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_email(par_insuree_info.contact_id)
                                                                           ,'<#EMAIL_LOWER>')
                     ,p_border   => '1'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      --Подпись к строке адреса            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => 'Индекс'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'город, улица, дом'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => 'телефон'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => 'e-mail'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_border => 'R', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    END print_insuree_custom;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- Инициализация
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ДОГОВОР №
    -------------------------------------------------------------------------------------------------
    --print_header_custom(par_policyid => v_policy_id, par_policy_summary => v_pol_sum, par_title => );
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => 'ДОГОВОР СТРАХОВАНИЯ ЖИЗНИ И ЗДОРОВЬЯ ЗАЁМЩИКОВ  КРЕДИТА '
                ,par_policyform_note => 'заключён на основании Полисных условий по программе страхования жизни и здоровья Заёмщиков кредита');
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВЩИК
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- СТРАХОВАТЕЛЬ / ЗАСТРАХОВАННЫЙ
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    --    print_insuree(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- СРОК ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ВАЛЮТА ДОГОВОРА
    -------------------------------------------------------------------------------------------------
    --    print_currency_custom(par_policy_summary => v_pol_sum);
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ТЕРРИТОРИЯ
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- Продукт
    -------------------------------------------------------------------------------------------------
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => 'ПРОГРАММА СТРАХОВАНИЯ: '
                   ,p_w        => 45
                   ,p_border   => 'LTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => v_pol_sum.product_public_name
                   ,p_border   => 'RTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    -------------------------------------------------------------------------------------------------
    -- ПРОГРАММЫ
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ВЫГОДОПРИОБРЕТАТЕЛИ
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДЕКЛАРАЦИЯ
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_cond_custom;
    --    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ПОДПИСИ
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ФОРМИРОВАНИЕ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_avtodom_avtocredit;

END pkg_rep_credit_policy;
/

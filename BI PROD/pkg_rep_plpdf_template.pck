CREATE OR REPLACE PACKAGE pkg_rep_plpdf_template IS

  -- Author  : Доброхотова И.
  -- Created : 26.12.2014 20:57:08
  -- Purpose : создание отчетов на основе plpdf_template

  /*
    Процедура формирования Заявление по продукту Наследия
    385734 Настройка продукта Наследие
    Доброхотова И., декабрь, 2014
  */
  PROCEDURE rep_nasledie_notice_p
  (
    par_content_type OUT NOCOPY VARCHAR2
   ,par_file_name    OUT NOCOPY VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  PROCEDURE rep_dostoyanie_notice_p
  (
    par_content_type OUT NOCOPY VARCHAR2
   ,par_file_name    OUT NOCOPY VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );
END pkg_rep_plpdf_template;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_plpdf_template IS
  gc_font_size CONSTANT NUMBER := 10;
  gc_mark_sign CONSTANT VARCHAR2(1) := 'V'; --Галочка

  gv_height_rect NUMBER := 3.5; --Высота прямоугольника для закраски
  gv_height_row  NUMBER := 4.8; -- высота строки

  -- определяем, заведены ли в договоре программы определенного типа
  FUNCTION get_product_line_type_exists
  (
    par_policy_id               NUMBER
   ,par_product_line_type_brief VARCHAR2
  ) RETURN BOOLEAN IS
    v_exists NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM as_asset            aa
                  ,p_cover             pc
                  ,t_prod_line_option  plo
                  ,t_product_line      pl
                  ,t_product_line_type plt
             WHERE aa.p_policy_id = par_policy_id
               AND aa.as_asset_id = pc.as_asset_id
               AND aa.status_hist_id != pkg_asset.status_hist_id_del
               AND pc.status_hist_id != pkg_cover.status_hist_id_del
               AND pc.t_prod_line_option_id = plo.id
               AND pl.id = plo.product_line_id
               AND plt.product_line_type_id = pl.product_line_type_id
               AND plt.brief = par_product_line_type_brief
               AND pc.premium <> 0);
    RETURN v_exists > 0;
  END get_product_line_type_exists;

  /*Печать текста в заданных координатах*/
  PROCEDURE print_text_xy
  (
    par_x          NUMBER
   ,par_y          NUMBER
   ,par_text       VARCHAR2
   ,par_w          NUMBER := 0
   ,par_align      VARCHAR2 := NULL
   ,par_h          NUMBER DEFAULT gv_height_rect - 0.5
   ,par_textline_h NUMBER DEFAULT 5
  ) IS
  BEGIN
    plpdf.drawrect(p_x => par_x, p_y => par_y, p_w => par_w, p_h => par_h, p_style => 'F');
    plpdf.setcurrentxy(p_x => par_x, p_y => par_y);
    plpdf.printmultilinecell(p_w        => par_w
                            ,p_txt      => par_text
                            ,p_align    => par_align
                            ,p_h        => par_textline_h
                            ,p_clipping => 0);
  END print_text_xy;

  PROCEDURE print_text_xy2
  (
    par_x     NUMBER
   ,par_y     NUMBER
   ,par_text  VARCHAR2
   ,par_w     NUMBER := 0
   ,par_align VARCHAR2 := NULL
  ) IS
  BEGIN
    plpdf.setcurrentxy(p_x => par_x, p_y => par_y);
    plpdf.printcell(p_w => par_w, p_txt => par_text, p_align => par_align, p_h => 5, p_clipping => 0);
  END print_text_xy2;

  PROCEDURE print_sign_xy
  (
    par_x     NUMBER
   ,par_y     NUMBER
   ,par_align VARCHAR2 := NULL
  ) IS
  
  BEGIN
    plpdf.setcurrentxy(p_x => par_x, p_y => par_y);
    plpdf.printcell(p_txt => gc_mark_sign, p_align => par_align, p_clipping => 0, p_w => 5);
  END print_sign_xy;

  PROCEDURE print_contact
  (
    par_contact_info  pkg_rep_plpdf.t_contact_summary
   ,par_delta_y       NUMBER DEFAULT 0
   ,par_type_contact  VARCHAR2 DEFAULT 'INS'
   ,par_product_brief VARCHAR2 DEFAULT NULL
  ) IS
    v_delta_y NUMBER := 0;
  
    PROCEDURE print_sign_rn
    (
      par_x     NUMBER
     ,par_row_n NUMBER
    ) IS
      v_y NUMBER;
    BEGIN
      v_y := par_delta_y + gv_height_row * (par_row_n - 1) + v_delta_y;
      plpdf.setcurrentxy(p_x => par_x, p_y => v_y);
      plpdf.printcell(p_txt => gc_mark_sign, p_w => 5);
    END print_sign_rn;
  
    PROCEDURE print_text_rn
    (
      par_x     NUMBER
     ,par_row_n NUMBER
     ,par_text  VARCHAR2
     ,par_h     NUMBER := 0
     ,par_w     NUMBER := 0
     ,par_align VARCHAR2 := NULL
    ) IS
      v_h NUMBER;
      v_y NUMBER;
    BEGIN
      IF par_h = 0
      THEN
        v_h := gv_height_rect;
      ELSE
        v_h := par_h;
      END IF;
      v_y := par_delta_y + gv_height_row * (par_row_n - 1) + v_delta_y;
      plpdf.drawrect(p_x => par_x, p_y => v_y, p_w => par_w, p_h => v_h, p_style => 'F');
      plpdf.setcurrentxy(p_x => par_x, p_y => v_y);
      plpdf.printcell(p_w        => par_w
                     ,p_txt      => par_text
                     ,p_align    => par_align
                     ,p_h        => v_h
                     ,p_clipping => 0);
    END print_text_rn;
  
    /*ФИО страхователя*/
    PROCEDURE print_fio IS
    BEGIN
      print_text_rn(par_x => 57, par_row_n => 1, par_text => par_contact_info.fio, par_w => 130);
    END print_fio;
  
    /*Пол страхователя*/
    PROCEDURE print_gender IS
      v_delta_x NUMBER := 0;
    BEGIN
      IF par_product_brief LIKE 'Nasledie_2%'
      THEN
        v_delta_x := -4.5;
      END IF;
      IF par_contact_info.gender = 'FEMALE' --Женский
      THEN
        print_sign_rn(par_x => 25.5 + v_delta_x, par_row_n => 2);
      ELSE
        print_sign_rn(par_x => 19 + v_delta_x, par_row_n => 2);
      END IF;
    
    END print_gender;
  
    /*Дата рождения*/
    PROCEDURE print_date_of_birth IS
    BEGIN
      print_text_rn(par_x     => 57
                   ,par_row_n => 2
                   ,par_text  => to_char(par_contact_info.date_of_birth, 'dd.mm.yyyy')
                   ,par_w     => 35
                   ,par_align => 'C');
    END print_date_of_birth;
  
    /*Гражданство*/
    PROCEDURE print_nationality IS
    BEGIN
      print_text_rn(par_x     => 131
                   ,par_row_n => 2
                   ,par_text  => pkg_contact.get_citizenry(par_contact_info.contact_id) || '/' ||
                                 pkg_contact.get_contact_ident_doc_by_type(par_contact_info.contact_id
                                                                          ,'INN')
                   ,par_w     => 60
                   ,par_align => 'C');
    END print_nationality;
  
    /*Паспорт*/
    PROCEDURE print_passport IS
      v_name_doc VARCHAR2(250);
    BEGIN
      v_name_doc := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                  ,'<#TYPE_DESC>');
      IF v_name_doc LIKE 'Паспорт гражданина РФ'
      THEN
        v_name_doc := 'Паспорт РФ';
      END IF;
      /*Наименование документа*/
      print_text_rn(par_x     => 78.5
                   ,par_row_n => 3
                   ,par_text  => v_name_doc
                   ,par_w     => 26
                   ,par_align => 'C');
      /*Серия*/
      print_text_rn(par_x     => 119
                   ,par_row_n => 3
                   ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                               ,pkg_contact_rep_utils.gc_mask_doc_series)
                   ,par_w     => 20
                   ,par_align => 'C');
      /*Номер*/
      print_text_rn(par_x     => 156
                   ,par_row_n => 3
                   ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                               ,pkg_contact_rep_utils.gc_mask_doc_number)
                   ,par_w     => 37
                   ,par_align => 'C');
    
      /*кем и когда выдан паспорт*/
      plpdf.setprintfontsize(p_size => 8);
      print_text_rn(par_x     => 45
                   ,par_row_n => 4
                   ,par_text  => substr(pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                                      ,'Выдан: <#DOC_PLACE>')
                                       ,1
                                       ,100)
                   ,par_w     => 150
                   ,par_align => 'L');
      plpdf.setprintfontsize(p_size => gc_font_size);
      print_text_rn(par_x     => 7
                   ,par_row_n => 5
                   ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                               ,'Дата выдачи: <#DOC_DATE>')
                   ,par_w     => 65
                   ,par_align => 'R');
    
      /*Код подразделения*/
      print_text_rn(par_x     => 143
                   ,par_row_n => 5
                   ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_contact_info.contact_id)
                                                                               ,pkg_contact_rep_utils.gc_mask_doc_subdivision_code)
                   ,par_w     => 43
                   ,par_align => 'C');
    END print_passport;
  
    PROCEDURE print_migration_card IS
    BEGIN
      -- сведения о миграционной карте
      print_text_rn(par_x     => 7
                   ,par_row_n => 8
                   ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_doc_by_type(par_contact_info.contact_id
                                                                                                                          ,'MIGRATION_CARD')
                                                                               ,'<#DOC_SERNUM> Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>'));
      v_delta_y := v_delta_y - 0.5;
    END print_migration_card;
  
    /*Адрес регистрации*/
    PROCEDURE print_registration_address IS
      v_contact_address_id cn_contact_address.id%TYPE;
    BEGIN
      /*Адрес постоянной регистрации*/
      v_contact_address_id := pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => par_contact_info.contact_id
                                                                              ,par_brief      => 'CONST');
      /*Индекс*/
      print_text_rn(par_x     => 45
                   ,par_row_n => 12
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_zip)
                   ,par_w     => 22
                   ,par_align => 'C');
      /*Регион/область*/
      print_text_rn(par_x     => 70
                   ,par_row_n => 12
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_province)
                    
                   ,par_w     => 59
                   ,par_align => 'C');
      /*Город/населенный пункт*/
      print_text_rn(par_x     => 132
                   ,par_row_n => 12
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_city)
                    
                   ,par_w     => 69
                   ,par_align => 'C');
      /*Улица, дом и т.д.*/
      print_text_rn(par_x     => 7
                   ,par_row_n => 13
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_street_with_house)
                    
                   ,par_w     => 195
                   ,par_align => 'C');
    END print_registration_address;
  
    /*Адрес фактический/почтовый*/
    PROCEDURE print_postal_address IS
      v_contact_address_id cn_contact_address.id%TYPE;
      /*Найти ИД адреса контакта, если он отличается от адреса регистрации*/
      FUNCTION get_different_address RETURN cn_contact_address.id%TYPE IS
        v_contact_address_id cn_contact_address.id%TYPE;
      BEGIN
        SELECT MIN(cca.id) keep(dense_rank FIRST ORDER BY tat.brief)
          INTO v_contact_address_id
          FROM cn_contact_address cca
              ,t_address_type     tat
              ,cn_contact_address cca_const
              ,t_address_type     tat_const
         WHERE cca.contact_id = par_contact_info.contact_id
           AND tat.brief IN ('POSTAL', 'FACT')
           AND cca.address_type = tat.id
           AND cca.contact_id = cca_const.contact_id
           AND cca_const.address_type = tat_const.id
           AND tat_const.brief = 'CONST'
           AND cca.adress_id != cca_const.adress_id /*Если отличаются адрес регигистрации и фактический/почтовый*/
        ;
        RETURN v_contact_address_id;
      END get_different_address;
    BEGIN
      v_contact_address_id := get_different_address;
      /*Индекс*/
      print_text_rn(par_x     => 69
                   ,par_row_n => 14
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_zip)
                   ,par_w     => 15
                   ,par_align => 'C'
                   ,par_h     => 6);
      /*Регион/область*/
      print_text_rn(par_x     => 87
                   ,par_row_n => 14
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_province)
                    
                   ,par_w     => 42
                   ,par_align => 'C'
                   ,par_h     => 6);
      /*Город/населенный пункт*/
      print_text_rn(par_x     => 132
                   ,par_row_n => 14
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_city)
                    
                   ,par_w     => 70
                   ,par_align => 'C'
                   ,par_h     => 6);
    
      v_delta_y := v_delta_y + 2.5;
      /*Улица, дом и т.д.*/
      print_text_rn(par_x     => 7
                   ,par_row_n => 15
                   ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                          ,pkg_contact_rep_utils.gc_address_street_with_house)
                    
                   ,par_w     => 195
                   ,par_align => 'C');
    END print_postal_address;
  
    /*Телефоны*/
    PROCEDURE print_phones IS
    BEGIN
      /*Телефон по месту жительства*/
      print_text_rn(par_x     => 47
                   ,par_row_n => 16
                   ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(par_contact_info.contact_id
                                                                                                                            ,'HOME'))
                   ,par_w     => 25
                   ,par_align => 'C');
    
      /*Телефон мобильный*/
      print_text_rn(par_x     => 106
                   ,par_row_n => 16
                   ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(par_contact_info.contact_id
                                                                                                                            ,'MOBIL'))
                   ,par_w     => 35
                   ,par_align => 'C');
      /*E-mail*/
      print_text_rn(par_x     => 143
                   ,par_row_n => 16
                   ,par_text  => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_last_active_email_id(par_contact_info.contact_id)
                                                                        ,pkg_contact_rep_utils.gc_mask_email)
                   ,par_w     => 60
                   ,par_align => 'C');
    END print_phones;
  
    /*Галочки*/
    PROCEDURE print_marks IS
    BEGIN
      IF par_type_contact = 'INS'
      THEN
        v_delta_y := v_delta_y + 3.8;
      ELSE
        v_delta_y := v_delta_y + 4;
      END IF;
      --Иностранное публичное лицо
      IF par_contact_info.is_public_contact = 1
      THEN
        print_sign_rn(par_x => 84, par_row_n => 19);
      ELSE
        print_sign_rn(par_x => 93.3, par_row_n => 19);
      END IF;
      --Российское публичное лицо
      IF par_contact_info.is_rpdl = 1
      THEN
        print_sign_rn(par_x => 188, par_row_n => 19);
      ELSE
        print_sign_rn(par_x => 197.5, par_row_n => 19);
      END IF;
      v_delta_y := v_delta_y + 2;
    END print_marks;
  
    PROCEDURE print_add_citizenship IS
      v_delta_x NUMBER := 0;
    BEGIN
    
      --Гражданство иного государства
      IF par_contact_info.has_additional_citizenship = 1
      THEN
        IF par_product_brief LIKE 'Nasledie_2%'
        THEN
          v_delta_x := 0.5;
        END IF;
        print_sign_rn(par_x => 90 + v_delta_x, par_row_n => 10);
        plpdf.setprintfontsize(p_size => 7);
        print_text_rn(par_x     => 155
                     ,par_row_n => 10
                     ,par_text  => substr(pkg_rep_plpdf.get_additional_citizenships(par_contact_info.contact_id)
                                         ,1
                                         ,36));
        plpdf.setprintfontsize(p_size => gc_font_size);
      ELSE
        IF par_product_brief LIKE 'Nasledie_2%'
        THEN
          v_delta_x := -0.5;
        END IF;
        print_sign_rn(par_x => 100.3 + v_delta_x, par_row_n => 10);
      END IF;
    
      v_delta_x := 0;
    
      -- Вид на жительство в иностранном государстве    
      IF par_contact_info.has_foreign_residency = 1
      THEN
      
        IF par_type_contact = 'INS'
        THEN
          print_sign_rn(par_x => 104 + v_delta_x, par_row_n => 11);
          plpdf.setprintfontsize(p_size => 7);
          print_text_rn(par_x     => 167
                       ,par_row_n => 11
                       ,par_text  => substr(pkg_rep_plpdf.get_foreign_residencies(par_contact_info.contact_id)
                                           ,1
                                           ,27));
          plpdf.setprintfontsize(p_size => gc_font_size);
        ELSE
          print_sign_rn(par_x => 110.5 + v_delta_x, par_row_n => 11);
          plpdf.setprintfontsize(p_size => 7);
          print_text_rn(par_x     => 173
                       ,par_row_n => 11
                       ,par_text  => substr(pkg_rep_plpdf.get_foreign_residencies(par_contact_info.contact_id)
                                           ,1
                                           ,24));
          plpdf.setprintfontsize(p_size => gc_font_size);
        
        END IF;
      ELSE
        IF par_type_contact = 'INS'
        THEN
          print_sign_rn(par_x => 113 + v_delta_x, par_row_n => 11);
        ELSE
          print_sign_rn(par_x => 119.5 + v_delta_x, par_row_n => 11);
        END IF;
      END IF;
    END print_add_citizenship;
  
  BEGIN
    plpdf.setprintfont(p_style => NULL);
    /*ФИО страхователя*/
    print_fio;
    /*Галочка "Пол"*/
    print_gender;
    /*Дата рождения*/
    print_date_of_birth;
    /*Гражданство*/
    print_nationality;
    /*Паспорт*/
    print_passport;
    -- Сведения о миграционной карте
    print_migration_card;
    --  Имеет ли Страхователь гражданство иного государства?
    -- Имеет ли Страхователь вид на жительство в иностранном
    print_add_citizenship;
    /*Адрес регистрации*/
    print_registration_address;
    /*Адрес фактический/почтовый*/
    print_postal_address;
    /*Телефоны*/
    print_phones;
    /*Остальные Галочки*/
    print_marks;
  
  END print_contact;

  PROCEDURE rep_nasledie_notice_p
  (
    par_content_type OUT NOCOPY VARCHAR2
   ,par_file_name    OUT NOCOPY VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id p_policy.policy_id%TYPE;
    /*Информация по полису*/
    v_pol_sum pkg_rep_plpdf.t_policy_summary;
    /*Информация по застрахованному*/
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    v_assured_info pkg_rep_plpdf.t_contact_summary;
  
    v_total_fee NUMBER := 0; --Итоговый взнос общий
  
    /*Структура для шаблона */
    v_tmpl_page1 plpdf_type.tr_tpl_data;
    v_tmpl_page2 plpdf_type.tr_tpl_data;
    v_tmpl_page3 plpdf_type.tr_tpl_data;
    v_tmpl_page4 plpdf_type.tr_tpl_data;
    v_tmpl_page5 plpdf_type.tr_tpl_data;
  
    /*ИД страниц шаблона*/
    v_tmpl_page1_id NUMBER;
    v_tmpl_page2_id NUMBER;
    v_tmpl_page3_id NUMBER;
    v_tmpl_page4_id NUMBER;
    v_tmpl_page5_id NUMBER;
  
    v_is_opt_pl BOOLEAN;
    FUNCTION is_ins_ass RETURN BOOLEAN IS
      v_cnt NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy_contact ppc
                    ,as_asset         aa
                    ,as_assured       aad
               WHERE ppc.contact_id = v_insuree_info.contact_id
                 AND ppc.policy_id = v_policy_id
                 AND ppc.policy_id = aa.p_policy_id
                 AND aa.as_asset_id = aad.as_assured_id
                 AND ppc.contact_id = aad.assured_contact_id);
      RETURN v_cnt = 1;
    END;
  
    /*Инициализация настроек для печати отчета*/
    PROCEDURE init_print_settings IS
    BEGIN
      -- Инициализация PDF
      plpdf.init;
    
      pkg_rep_plpdf.font_init;
      plpdf.setencoding(p_enc => plpdf_const.cp1251);
    
      plpdf.setprintfont(p_family => pkg_rep_plpdf.gc_arial_font_family
                        ,p_style  => 'B'
                        ,p_size   => gc_font_size);
      /*Цвет текста для заявления*/
      plpdf.setcolor4text(p_r => 136, p_g => 89, p_b => 144);
      /*green white yellow*/
      plpdf.setcolor4filling(p_color => plpdf_const.white);
    
    END;
  
    /*Загрузка шаблонов страниц заявления*/
    PROCEDURE load_templates IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(6);
      v_tmpl_page2 := plpdf_parser.loadtemplate(7);
      v_tmpl_page3 := plpdf_parser.loadtemplate(8);
      v_tmpl_page4 := plpdf_parser.loadtemplate(9);
    END load_templates;
  
    PROCEDURE load_templates_2 IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(16);
      v_tmpl_page2 := plpdf_parser.loadtemplate(17);
      v_tmpl_page3 := plpdf_parser.loadtemplate(18);
      v_tmpl_page4 := plpdf_parser.loadtemplate(19);
      v_tmpl_page5 := plpdf_parser.loadtemplate(20);
    END load_templates_2;
  
    PROCEDURE load_templates_2_opt IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(21);
      v_tmpl_page2 := plpdf_parser.loadtemplate(22);
      v_tmpl_page3 := plpdf_parser.loadtemplate(23);
      v_tmpl_page4 := plpdf_parser.loadtemplate(24);
      v_tmpl_page5 := plpdf_parser.loadtemplate(25);
    END load_templates_2_opt;
  
    PROCEDURE load_templates_2_retail IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(26);
      v_tmpl_page2 := plpdf_parser.loadtemplate(27);
      v_tmpl_page3 := plpdf_parser.loadtemplate(28);
      v_tmpl_page4 := plpdf_parser.loadtemplate(29);
      v_tmpl_page5 := plpdf_parser.loadtemplate(30);
    END load_templates_2_retail;
  
    PROCEDURE load_templates_2_retail_opt IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(31);
      v_tmpl_page2 := plpdf_parser.loadtemplate(32);
      v_tmpl_page3 := plpdf_parser.loadtemplate(33);
      v_tmpl_page4 := plpdf_parser.loadtemplate(34);
      v_tmpl_page5 := plpdf_parser.loadtemplate(35);
    END load_templates_2_retail_opt;
  
    /*Печать страницы №1 заявления*/
    PROCEDURE print_page1 IS
      v_asset_adult_id contact.contact_id%TYPE; --ИД контакта застрахованный взрослый
    
      PROCEDURE print_header IS
      BEGIN
      
        plpdf.setcurrentxy(p_x => 107, p_y => 26);
        plpdf.printcell(p_w        => 30
                       ,p_txt      => v_pol_sum.pol_num
                       ,p_align    => 'L'
                       ,p_h        => 5
                       ,p_clipping => 0);
      
      END print_header;
    
      PROCEDURE print_programms IS
      BEGIN
        FOR rec IN (SELECT nvl(pl.public_description, pl.description) AS description
                          ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                          ,nvl(pc.fee, 0) AS fee
                      FROM t_prod_line_option plo
                          ,t_product_line pl
                          ,v_prod_product_line ppl
                          ,t_product_line_type plt
                          ,(SELECT pc.t_prod_line_option_id
                                  ,pc.ins_amount
                                  ,pc.fee
                              FROM p_cover  pc
                                  ,as_asset aa
                             WHERE aa.p_policy_id = v_policy_id
                               AND aa.as_asset_id = pc.as_asset_id) pc
                     WHERE ppl.product_brief = v_pol_sum.product_brief
                       AND ppl.t_product_line_id = plo.product_line_id
                       AND ppl.t_product_line_id = pl.id
                       AND plo.id = pc.t_prod_line_option_id(+)
                       AND plt.product_line_type_id = pl.product_line_type_id
                       AND plt.brief = 'RECOMMENDED'
                     ORDER BY pl.sort_order)
        LOOP
          print_text_xy(par_x     => 135
                       ,par_y     => 280
                       ,par_text  => rec.ins_amount
                       ,par_w     => 28
                       ,par_align => 'C');
          print_text_xy(par_x     => 170
                       ,par_y     => 280
                       ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                       ,par_w     => 33
                       ,par_align => 'C');
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      END print_programms;
    
      /*Является ли страхователь застрахованным*/
      PROCEDURE print_is_insuree_assured IS
        v_cnt NUMBER;
      BEGIN
        SELECT COUNT(*)
          INTO v_cnt
          FROM dual
         WHERE EXISTS (SELECT NULL
                  FROM p_policy_contact ppc
                      ,as_asset         aa
                      ,as_assured       aad
                 WHERE ppc.contact_id = v_insuree_info.contact_id
                   AND ppc.policy_id = v_policy_id
                   AND ppc.policy_id = aa.p_policy_id
                   AND aa.as_asset_id = aad.as_assured_id
                   AND ppc.contact_id = aad.assured_contact_id);
        IF v_cnt = 1
        THEN
          --Является ли страхователь застрахованным
          print_sign_xy(par_x => 74, par_y => 139);
        ELSE
          print_sign_xy(par_x => 83.5, par_y => 139);
        END IF;
      END print_is_insuree_assured;
    
      PROCEDURE print_period IS
        v_period_value t_period.period_value%TYPE;
      BEGIN
        SELECT period_value
          INTO v_period_value
          FROM t_period t
         WHERE t.description = v_pol_sum.policy_period_desc;
        print_text_xy2(par_x => 7, par_y => 259.5, par_text => v_period_value);
        print_text_xy2(par_x    => 22
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.start_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 35
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.start_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 50
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.start_date, 'yy')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 66
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.end_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 78
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.end_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 95
                      ,par_y    => 259.5
                      ,par_text => to_char(v_pol_sum.end_date, 'yy')
                      ,par_w    => 10);
      END print_period;
    
      PROCEDURE print_insurer_info_hkf IS
      BEGIN
        plpdf.setprintfontsize(p_size => 5);
        print_text_xy(par_x          => 56
                     ,par_y          => 9
                     ,par_w          => 148
                     ,par_h          => 13
                     ,par_text       => '1. ООО «СК «Ренессанс Жизнь», 115114,Россия, г. Москва, наб. Дербеневская,д.7,стр. 22 Тел. 8 (495) 981 2 981, Факс 8 (495) 589 18 65/67info@renlife.comwww.renlife.com Лицензия С № 3972 77 от 17.01.2006 года. ИНН  7725520440, КПП 775001001, Р/С  40701 810 8 0001 0000034 в ООО "Хоум Кредит энд Финанс Банк", ИНН 7735057951,  Юридический адрес:125040, г. Москва, улица Правды, д. 8, кор.1, К/С 30101810400000000216 в Отделении 2 Главного управления Центрального банка Российской Федерации по Центральному федеральному округу г. Москва, БИК:044585216 КПП 997950001 ОКТМО 45334000 ОКПО 9807804 ОГРН 1027700280937,  Генеральная лицензия ЦБ РФ № 316 от 15 марта 2012 г.'
                     ,par_textline_h => 2.5);
        plpdf.setprintfontsize(p_size => 9);
      END print_insurer_info_hkf;
    
      PROCEDURE print_insurer_info_default IS
      BEGIN
        plpdf.setprintfontsize(p_size => 7);
        print_text_xy(par_x          => 56
                     ,par_y          => 9
                     ,par_w          => 148
                     ,par_h          => 13
                     ,par_text       => '1. ' ||
                                        pkg_contact_rep_utils.get_insurer_info(par_mask => pkg_contact_rep_utils.gc_company_def_info)
                     ,par_textline_h => 3.5);
        plpdf.setprintfontsize(p_size => 9);
      END print_insurer_info_default;
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page1_id := plpdf.instemplate(v_tmpl_page1);
      plpdf.newpage;
    
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page1_id);
    
      IF v_pol_sum.product_brief = 'Nasledie_HKF'
      THEN
        print_insurer_info_hkf;
      ELSE
        print_insurer_info_default;
      END IF;
    
      --Заголовок - номер заявления
      print_header;
    
      --Страхователь
      /*      IF v_pol_sum.product_brief IN ('Nasledie_2', 'Nasledie_2_retail')
      THEN
        print_contact(v_insuree_info, 38, 'INS');
      ELSE*/
      print_contact(v_insuree_info, 36.8, 'INS');
      --    END IF;
      print_is_insuree_assured;
      --Застрахованные
      /*      IF v_pol_sum.product_brief IN ('Nasledie_2', 'Nasledie_2_retail')
      THEN
        print_contact(v_assured_info, 162, 'ASS');
      ELSE*/
      print_contact(v_assured_info, 148.5, 'ASS');
      --      END IF;
    
      -- Валюта
      print_sign_xy(par_x => 57.8, par_y => 251.5);
    
      print_period;
      print_programms;
    END print_page1;
  
    PROCEDURE print_page1_n2 IS
      v_asset_adult_id contact.contact_id%TYPE; --ИД контакта застрахованный взрослый
    
      PROCEDURE print_header IS
      BEGIN
      
        plpdf.setcurrentxy(p_x => 107, p_y => 26);
        plpdf.printcell(p_w        => 30
                       ,p_txt      => v_pol_sum.pol_num
                       ,p_align    => 'L'
                       ,p_h        => 5
                       ,p_clipping => 0);
      
      END print_header;
    
      /*Является ли страхователь застрахованным*/
      PROCEDURE print_is_insuree_assured IS
        v_cnt NUMBER;
      BEGIN
        IF is_ins_ass
        THEN
          --Является ли страхователь застрахованным
          print_sign_xy(par_x => 74.5, par_y => 151.25);
        ELSE
          print_sign_xy(par_x => 84.5, par_y => 151.25);
        END IF;
      END print_is_insuree_assured;
    
      PROCEDURE print_period IS
        v_period_value t_period.period_value%TYPE;
      BEGIN
        SELECT period_value
          INTO v_period_value
          FROM t_period t
         WHERE t.description = v_pol_sum.policy_period_desc;
      
        print_text_xy2(par_x => 7, par_y => 285, par_text => v_period_value);
      
        print_text_xy2(par_x    => 22
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.start_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 35
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.start_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 50
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.start_date, 'yy')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 66
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.end_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 78
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.end_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 95
                      ,par_y    => 285
                      ,par_text => to_char(v_pol_sum.end_date, 'yy')
                      ,par_w    => 10);
      
      END print_period;
    
      PROCEDURE print_insurer_info_hkf IS
      BEGIN
        plpdf.setprintfontsize(p_size => 5);
        print_text_xy(par_x          => 56
                     ,par_y          => 9
                     ,par_w          => 148
                     ,par_h          => 13
                     ,par_text       => '1. ООО «СК «Ренессанс Жизнь», 115114,Россия, г. Москва, наб. Дербеневская,д.7,стр. 22 Тел. 8 (495) 981 2 981, Факс 8 (495) 589 18 65/67info@renlife.comwww.renlife.com Лицензия С № 3972 77 от 17.01.2006 года. ИНН  7725520440, КПП 775001001, Р/С  40701 810 8 0001 0000034 в ООО "Хоум Кредит энд Финанс Банк", ИНН 7735057951,  Юридический адрес:125040, г. Москва, улица Правды, д. 8, кор.1, К/С 30101810400000000216 в Отделении 2 Главного управления Центрального банка Российской Федерации по Центральному федеральному округу г. Москва, БИК:044585216 КПП 997950001 ОКТМО 45334000 ОКПО 9807804 ОГРН 1027700280937,  Генеральная лицензия ЦБ РФ № 316 от 15 марта 2012 г.'
                     ,par_textline_h => 2.5);
        plpdf.setprintfontsize(p_size => 9);
      END print_insurer_info_hkf;
    
      PROCEDURE print_insurer_info_default IS
      BEGIN
        plpdf.setprintfontsize(p_size => 7);
        print_text_xy(par_x          => 56
                     ,par_y          => 9
                     ,par_w          => 148
                     ,par_h          => 13
                     ,par_text       => '1. ' ||
                                        pkg_contact_rep_utils.get_insurer_info(par_mask => pkg_contact_rep_utils.gc_company_def_info)
                     ,par_textline_h => 3.5);
        plpdf.setprintfontsize(p_size => 9);
      END print_insurer_info_default;
    BEGIN
    
      --Вставка шаблона как фона для страницы
      v_tmpl_page1_id := plpdf.instemplate(v_tmpl_page1);
      plpdf.newpage;
    
      -- чтобы автоматически не добавлялся разрыв страницы (не создавалась новая страница)
      --(если текст выходит за нижние границы листа)
      plpdf.setautonewpage(FALSE);
    
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page1_id);
    
      IF v_pol_sum.product_brief = 'Nasledie_2_HKF'
      THEN
        print_insurer_info_hkf;
      ELSE
        print_insurer_info_default;
      END IF;
    
      --Заголовок - номер заявления
      print_header;
      --Страхователь  
      print_contact(v_insuree_info, 38, 'INS', v_pol_sum.product_brief);
      -- Является страхователь застрахованным
      print_is_insuree_assured;
      --Застрахованные
      print_contact(v_assured_info, 162, 'ASS', v_pol_sum.product_brief);
      -- Валюта
      print_sign_xy(par_x => 56.8, par_y => 276.3);
    
      print_period;
    END print_page1_n2;
  
    /*Печать страницы №2 заявления*/
    PROCEDURE print_page2_n2 IS
      PROCEDURE print_programms IS
      BEGIN
      
        FOR rec IN (SELECT nvl(pl.public_description, pl.description) AS description
                          ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                          ,nvl(pc.fee, 0) AS fee
                      FROM t_prod_line_option plo
                          ,t_product_line pl
                          ,v_prod_product_line ppl
                          ,t_product_line_type plt
                          ,(SELECT pc.t_prod_line_option_id
                                  ,pc.ins_amount
                                  ,pc.fee
                              FROM p_cover  pc
                                  ,as_asset aa
                             WHERE aa.p_policy_id = v_policy_id
                               AND aa.as_asset_id = pc.as_asset_id) pc
                     WHERE ppl.product_brief = v_pol_sum.product_brief
                       AND ppl.t_product_line_id = plo.product_line_id
                       AND ppl.t_product_line_id = pl.id
                       AND plo.id = pc.t_prod_line_option_id(+)
                       AND plt.product_line_type_id = pl.product_line_type_id
                       AND plt.brief = 'RECOMMENDED'
                     ORDER BY pl.sort_order)
        LOOP
        
          print_text_xy(par_x     => 135
                       ,par_y     => 28
                       ,par_text  => rec.ins_amount
                       ,par_w     => 28
                       ,par_align => 'C');
          print_text_xy(par_x => 170
                       ,par_y => 28 --30
                        
                       ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                       ,par_w     => 33
                       ,par_align => 'C');
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      
        FOR rec IN (SELECT rownum rn
                          ,a.*
                      FROM (SELECT nvl(pl.public_description, pl.description) AS description
                                  ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                                  ,nvl(pc.fee, 0) AS fee
                              FROM t_prod_line_option plo
                                  ,t_product_line pl
                                  ,v_prod_product_line ppl
                                  ,t_product_line_type plt
                                  ,(SELECT pc.t_prod_line_option_id
                                          ,pc.ins_amount
                                          ,pc.fee
                                      FROM p_cover  pc
                                          ,as_asset aa
                                     WHERE aa.p_policy_id = v_policy_id
                                       AND aa.as_asset_id = pc.as_asset_id) pc
                             WHERE ppl.product_brief = v_pol_sum.product_brief
                               AND ppl.t_product_line_id = plo.product_line_id
                               AND ppl.t_product_line_id = pl.id
                               AND plo.id = pc.t_prod_line_option_id(+)
                               AND plt.product_line_type_id = pl.product_line_type_id
                               AND plt.brief = 'MANDATORY'
                             ORDER BY pl.sort_order) a)
        LOOP
        
          IF rec.rn = 1
          THEN
            print_text_xy(par_x     => 133
                         ,par_y     => (CASE
                                         WHEN v_is_opt_pl THEN
                                          52
                                         ELSE
                                          48
                                       END)
                         ,par_text  => rec.ins_amount
                         ,par_w     => 33
                         ,par_align => 'C');
          END IF;
          print_text_xy(par_x     => 168
                       ,par_y     => (CASE
                                       WHEN v_is_opt_pl THEN
                                        47 + 5 * (rec.rn - 1)
                                       ELSE
                                        43 + 5 * (rec.rn - 1)
                                     END)
                       ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                       ,par_w     => 33
                       ,par_align => 'C');
        
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      
        IF v_is_opt_pl
        THEN
          FOR rec IN (SELECT rownum rn
                            ,a.*
                        FROM (SELECT nvl(pl.public_description, pl.description) AS description
                                    ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                                    ,nvl(pc.fee, 0) AS fee
                                    ,plo.brief
                                FROM t_prod_line_option plo
                                    ,t_product_line pl
                                    ,v_prod_product_line ppl
                                    ,t_product_line_type plt
                                    ,(SELECT pc.t_prod_line_option_id
                                            ,pc.ins_amount
                                            ,pc.fee
                                        FROM p_cover  pc
                                            ,as_asset aa
                                       WHERE aa.p_policy_id = v_policy_id
                                         AND aa.as_asset_id = pc.as_asset_id) pc
                               WHERE ppl.product_brief = v_pol_sum.product_brief
                                 AND ppl.t_product_line_id = plo.product_line_id
                                 AND ppl.t_product_line_id = pl.id
                                 AND plo.id = pc.t_prod_line_option_id(+)
                                 AND plt.product_line_type_id = pl.product_line_type_id
                                 AND plt.brief = 'OPTIONAL'
                               ORDER BY pl.sort_order) a)
          LOOP
            IF rec.fee <> 0
            THEN
              IF rec.brief = 'WOP'
              THEN
                IF v_pol_sum.product_brief = 'Nasledie_2_retail'
                THEN
                  print_sign_xy(par_x => 8.5, par_y => 69.5 + 8.5 * (rec.rn - 1));
                  plpdf.setprintfontsize(p_size => 8);
                  print_text_xy(par_x          => 133
                               ,par_y          => 68
                               ,par_text       => 'Величина страховой премии по рискам, указанным в п. 6.1'
                               ,par_w          => 33
                               ,par_align      => 'C'
                               ,par_textline_h => 2.75);
                  plpdf.setprintfontsize(p_size => gc_font_size);
                
                  print_text_xy(par_x     => 168
                               ,par_y     => 70 + 8 * (rec.rn - 1)
                               ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                               ,par_w     => 33
                               ,par_align => 'C');
                ELSE
                  print_sign_xy(par_x => 8.5, par_y => 71.5 + 7 * (rec.rn - 1));
                  plpdf.setprintfontsize(p_size => 8);
                  print_text_xy(par_x          => 133
                               ,par_y          => 70 + 1 * (rec.rn - 1)
                               ,par_text       => 'Величина страховой премии по рискам, указанным в п. 6.1'
                               ,par_w          => 33
                               ,par_align      => 'C'
                               ,par_textline_h => 2.75);
                  plpdf.setprintfontsize(p_size => gc_font_size);
                  print_text_xy(par_x     => 168
                               ,par_y     => 73 + 6 * (rec.rn - 1)
                               ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                               ,par_w     => 33
                               ,par_align => 'C');
                END IF;
              
              ELSE
                IF v_pol_sum.product_brief = 'Nasledie_2_retail'
                THEN
                  print_sign_xy(par_x => 8.5, par_y => 69.5 + 8.5 * (rec.rn - 1));
                  print_text_xy(par_x     => 133
                               ,par_y     => 70 + 8 * (rec.rn - 1)
                               ,par_text  => rec.ins_amount
                               ,par_w     => 33
                               ,par_align => 'C');
                  print_text_xy(par_x     => 168
                               ,par_y     => 70 + 8 * (rec.rn - 1)
                               ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                               ,par_w     => 33
                               ,par_align => 'C');
                ELSE
                  print_sign_xy(par_x => 8.5, par_y => 71.5 + 7 * (rec.rn - 1));
                  print_text_xy(par_x     => 133
                               ,par_y     => 73 + 6 * (rec.rn - 1)
                               ,par_text  => rec.ins_amount
                               ,par_w     => 33
                               ,par_align => 'C');
                  print_text_xy(par_x     => 168
                               ,par_y     => 73 + 6 * (rec.rn - 1)
                               ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                               ,par_w     => 33
                               ,par_align => 'C');
                END IF;
              END IF;
              v_total_fee := v_total_fee + rec.fee;
            END IF;
          END LOOP;
        END IF;
      
        -- итого
        print_text_xy(par_x     => 168
                     ,par_y     => --85
                       (CASE
                         WHEN v_is_opt_pl THEN
                          85
                         ELSE
                          61
                       END)
                     ,par_text  => pkg_rep_utils.to_money_sep(v_total_fee)
                     ,par_w     => 33
                     ,par_align => 'C');
        plpdf.setprintfontsize(p_size => 8);
        print_text_xy(par_x    => 80
                     ,par_y    => (CASE
                                    WHEN v_is_opt_pl THEN
                                     90
                                    ELSE
                                     66
                                  END)
                     ,par_text => pkg_utils.money2speech(v_total_fee, 122));
        plpdf.setprintfontsize(p_size => gc_font_size);
      END print_programms;
    
      PROCEDURE print_payment_terms IS
        v_y NUMBER;
      BEGIN
        IF v_is_opt_pl
        THEN
          v_y := 95.5;
        ELSE
          v_y := 71;
        END IF;
        IF v_pol_sum.payment_terms = 'Раз в полгода'
        THEN
          print_sign_xy(par_x => 109, par_y => v_y);
        ELSIF v_pol_sum.payment_terms = 'Ежеквартально'
        THEN
          print_sign_xy(par_x => 129.5, par_y => v_y);
        
        ELSIF v_pol_sum.payment_terms = 'Ежегодно'
        THEN
          print_sign_xy(par_x => 88, par_y => v_y);
        END IF;
      END;
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page2_id := plpdf.instemplate(v_tmpl_page2);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page2_id);
      /*Обязательно выставить, иначе переводит на новую страницу*/
      plpdf.setautonewpage(p_auto => FALSE);
      /*Заполнение страховых программ*/
      print_programms;
      -- периодичность уплаты
      print_payment_terms;
    END print_page2_n2;
  
    PROCEDURE print_page2 IS
      PROCEDURE print_programms IS
      BEGIN
        FOR rec IN (SELECT rownum rn
                          ,a.*
                      FROM (SELECT nvl(pl.public_description, pl.description) AS description
                                  ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                                  ,nvl(pc.fee, 0) AS fee
                                  ,pl.description descr
                              FROM t_prod_line_option plo
                                  ,t_product_line pl
                                  ,v_prod_product_line ppl
                                  ,t_product_line_type plt
                                  ,(SELECT pc.t_prod_line_option_id
                                          ,pc.ins_amount
                                          ,pc.fee
                                      FROM p_cover  pc
                                          ,as_asset aa
                                     WHERE aa.p_policy_id = v_policy_id
                                       AND aa.as_asset_id = pc.as_asset_id) pc
                             WHERE ppl.product_brief = v_pol_sum.product_brief
                               AND ppl.t_product_line_id = plo.product_line_id
                               AND ppl.t_product_line_id = pl.id
                               AND plo.id = pc.t_prod_line_option_id(+)
                               AND plt.product_line_type_id = pl.product_line_type_id
                               AND plt.brief = 'MANDATORY'
                             ORDER BY pl.sort_order) a)
        LOOP
        
          IF rec.rn = 1
          THEN
          
            IF rec.descr IN
               ('Освобождение от уплаты страховых взносов в случае наступления события «Инвалидность Страхователя 1-й группы по любой причине»'
               ,'Освобождение от уплаты страховых взносов в случае наступления события «Инвалидность Страхователя 1-й или 2-й группы, наступившая в результате несчастного случая»')
            THEN
              print_text_xy(par_x     => 133
                           ,par_y     => 20
                           ,par_text  => 'Величина страховой премии по рискам, указанным в п. 6.1'
                           ,par_w     => 33
                           ,par_align => 'C');
            ELSE
              print_text_xy(par_x     => 133
                           ,par_y     => 20
                           ,par_text  => rec.ins_amount
                           ,par_w     => 33
                           ,par_align => 'C');
            END IF;
          END IF;
          print_text_xy(par_x     => 168
                       ,par_y     => 15 + 4 * (rec.rn - 1)
                       ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                       ,par_w     => 33
                       ,par_align => 'C');
        
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      
        -- итого
        print_text_xy(par_x     => 168
                     ,par_y     => 30
                     ,par_text  => pkg_rep_utils.to_money_sep(v_total_fee)
                     ,par_w     => 33
                     ,par_align => 'C');
        plpdf.setprintfontsize(p_size => 8);
        print_text_xy(par_x    => 80
                     ,par_y    => 34.5
                     ,par_text => pkg_utils.money2speech(v_total_fee, 122));
        plpdf.setprintfontsize(p_size => gc_font_size);
      END print_programms;
    
      PROCEDURE print_payment_terms IS
      BEGIN
        IF v_pol_sum.payment_terms = 'Раз в полгода'
        THEN
          print_sign_xy(par_x => 133, par_y => 39);
        ELSIF v_pol_sum.payment_terms = 'Ежеквартально'
        THEN
          print_sign_xy(par_x => 167, par_y => 39);
        
        ELSIF v_pol_sum.payment_terms = 'Ежегодно'
        THEN
          print_sign_xy(par_x => 97, par_y => 39);
        END IF;
      END;
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page2_id := plpdf.instemplate(v_tmpl_page2);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page2_id);
      /*Обязательно выставить, иначе переводит на новую страницу*/
      plpdf.setautonewpage(p_auto => FALSE);
      /*Заполнение страховых программ*/
      print_programms;
      -- периодичность уплаты
      print_payment_terms;
    END print_page2;
  
    /*Печать страницы №3 заявления*/
    PROCEDURE print_page3 IS
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page3_id := plpdf.instemplate(v_tmpl_page3);
      plpdf.newpage;
      plpdf.usetemplate(v_tmpl_page3_id);
    END print_page3;
  
    /*Печать страницы №4 заявления*/
    PROCEDURE print_page4 IS
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page4_id := plpdf.instemplate(v_tmpl_page4);
      plpdf.newpage;
      plpdf.usetemplate(v_tmpl_page4_id);
    END print_page4;
  
    /*Печать страницы №4 заявления*/
    PROCEDURE print_page5 IS
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page5_id := plpdf.instemplate(v_tmpl_page5);
      plpdf.newpage;
      plpdf.usetemplate(v_tmpl_page5_id);
    END print_page5;
  
  BEGIN
  
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
    v_assured_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.assured_array(1));
  
    IF v_pol_sum.product_brief IN
       ('Nasledie_2', 'Nasledie_2_retail', 'Nasledie_2_HKF', 'Nasledie_2_BIN')
    THEN
      gv_height_row := 5.6;
    ELSE
      gv_height_row := 5;
    END IF;
    /*Загрузка шаблонов страниц для заялвения*/
    IF v_pol_sum.product_brief IN ('Nasledie', 'Nasledie_HKF')
    THEN
      load_templates;
    ELSIF v_pol_sum.product_brief IN ('Nasledie_2', 'Nasledie_2_HKF', 'Nasledie_2_BIN')
    THEN
      v_is_opt_pl := get_product_line_type_exists(v_policy_id, 'OPTIONAL');
      IF v_is_opt_pl
      THEN
        load_templates_2_opt;
      ELSE
        load_templates_2;
      END IF;
    ELSIF v_pol_sum.product_brief = 'Nasledie_2_retail'
    THEN
      v_is_opt_pl := get_product_line_type_exists(v_policy_id, 'OPTIONAL');
      IF v_is_opt_pl
      THEN
        load_templates_2_retail_opt;
      ELSE
        load_templates_2_retail;
      END IF;
    END IF;
  
    --Установка настоек для печати документа (цвет текста)
    init_print_settings;
    plpdf.setallmargin(0, 0);
    IF v_pol_sum.product_brief IN
       ('Nasledie_2', 'Nasledie_2_retail', 'Nasledie_2_HKF', 'Nasledie_2_BIN')
    THEN
      --Печать страницы №1
      print_page1_n2;
      --Печать страницы №2
      print_page2_n2;
    ELSE
      --Печать страницы №1
      print_page1;
      --Печать страницы №2
      print_page2;
    END IF;
    --Печать страницы №3
    print_page3;
    --Печать страницы №4
    print_page4;
  
    IF v_pol_sum.product_brief IN
       ('Nasledie_2', 'Nasledie_2_retail', 'Nasledie_2_HKF', 'Nasledie_2_BIN')
    THEN
      --Печать страницы №5
      print_page5;
    END IF;
  
    plpdf.senddoc(p_blob => par_data);
  
    par_file_name    := 'notice_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_nasledie_notice_p;

  PROCEDURE rep_dostoyanie_notice_p
  (
    par_content_type OUT NOCOPY VARCHAR2
   ,par_file_name    OUT NOCOPY VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
    v_policy_id p_policy.policy_id%TYPE;
    /*Информация по полису*/
    v_pol_sum pkg_rep_plpdf.t_policy_summary;
    /*Информация по застрахованному*/
    v_insuree_info pkg_rep_plpdf.t_contact_summary;
    v_assured_info pkg_rep_plpdf.t_contact_summary;
  
    v_total_fee NUMBER := 0; --Итоговый взнос общий
  
    /*Структура для шаблона */
    v_tmpl_page1 plpdf_type.tr_tpl_data;
    v_tmpl_page2 plpdf_type.tr_tpl_data;
    v_tmpl_page3 plpdf_type.tr_tpl_data;
    v_tmpl_page4 plpdf_type.tr_tpl_data;
    v_tmpl_page5 plpdf_type.tr_tpl_data;
    --    v_tmpl_page6 plpdf_type.tr_tpl_data;
  
    /*ИД страниц шаблона*/
    v_tmpl_page1_id NUMBER;
    v_tmpl_page2_id NUMBER;
    v_tmpl_page3_id NUMBER;
    v_tmpl_page4_id NUMBER;
    v_tmpl_page5_id NUMBER;
    --    v_tmpl_page6_id NUMBER;
  
    gc_height    CONSTANT NUMBER := 3.3; --Высота прямоугольника для закраски
    gc_font_size CONSTANT NUMBER := 10;
    gc_mark_sign CONSTANT VARCHAR2(1) := 'V'; --Галочка
  
    v_is_small_notice BOOLEAN;
  
    /*Инициализация настроек для печати отчета*/
    PROCEDURE init_print_settings IS
    BEGIN
      -- Инициализация PDF
      plpdf.init;
    
      pkg_rep_plpdf.font_init;
      plpdf.setencoding(p_enc => plpdf_const.cp1251);
    
      plpdf.setprintfont(p_family => pkg_rep_plpdf.gc_arial_font_family
                        ,p_style  => 'B'
                        ,p_size   => gc_font_size);
      /*Цвет текста для заявления*/
      plpdf.setcolor4text(p_r => 136, p_g => 89, p_b => 144);
      /*green white yellow*/
      plpdf.setcolor4filling(p_color => plpdf_const.white);
    
    END;
  
    /*Печать текста в заданных координатах*/
    PROCEDURE print_text_xy
    (
      par_x      NUMBER
     ,par_y      NUMBER
     ,par_text   VARCHAR2
     ,par_w      NUMBER := 0
     ,par_h      NUMBER := 5
     ,par_align  VARCHAR2 := NULL
     ,par_coef_h NUMBER := 1
    ) IS
    
    BEGIN
      plpdf.drawrect(p_x     => par_x
                    ,p_y     => par_y
                    ,p_w     => par_w
                    ,p_h     => gc_height * par_coef_h - 0.5
                    ,p_style => 'F');
      plpdf.setcurrentxy(p_x => par_x, p_y => par_y);
      plpdf.printmultilinecell(p_w        => par_w
                              ,p_txt      => par_text
                              ,p_align    => par_align
                              ,p_h        => par_h
                              ,p_clipping => 0);
    END;
  
    PROCEDURE print_sign_xy
    (
      par_x     NUMBER
     ,par_y     NUMBER
     ,par_w     NUMBER := 0
     ,par_align VARCHAR2 := NULL
    ) IS
    
    BEGIN
      plpdf.setcurrentxy(p_x => par_x, p_y => par_y);
      plpdf.printcell(p_txt => gc_mark_sign, p_align => par_align, p_w => 5);
    END;
  
    /*Загрузка шаблонов страниц заявления (5 страниц)*/
    PROCEDURE load_templates_small IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(1);
      v_tmpl_page2 := plpdf_parser.loadtemplate(2);
      v_tmpl_page3 := plpdf_parser.loadtemplate(3);
      v_tmpl_page4 := plpdf_parser.loadtemplate(4);
      v_tmpl_page5 := plpdf_parser.loadtemplate(5);
    END load_templates_small;
  
    PROCEDURE load_templates_big IS
    BEGIN
      /*ИД шаблона сгенерированы вручную без последовательности для таблицы PLPDF.PLPDF_TEMPLATE*/
      v_tmpl_page1 := plpdf_parser.loadtemplate(10);
      v_tmpl_page2 := plpdf_parser.loadtemplate(11);
      v_tmpl_page3 := plpdf_parser.loadtemplate(12);
      v_tmpl_page4 := plpdf_parser.loadtemplate(13);
      v_tmpl_page5 := plpdf_parser.loadtemplate(14);
    END load_templates_big;
  
    /*Печать страницы №1 заявления*/
    PROCEDURE print_page1 IS
      PROCEDURE print_header IS
        v_x NUMBER := 163; --Положение № заявления
        v_y NUMBER := 25;
      BEGIN
        print_text_xy2(par_x => v_x, par_y => v_y, par_text => v_pol_sum.pol_num);
      END print_header;
    
      /*Страхователь*/
      PROCEDURE print_insuree IS
        /*ФИО страхователя*/
        PROCEDURE print_fio IS
        BEGIN
          print_text_xy(par_x => 57, par_y => 36, par_text => v_insuree_info.fio, par_w => 130);
        END print_fio;
      
        /*Пол страхователя*/
        PROCEDURE print_gender IS
        BEGIN
          IF v_insuree_info.gender = 'FEMALE' --Женский
          THEN
            print_sign_xy(par_x => 25.5, par_y => 39.5);
          ELSE
            print_sign_xy(par_x => 19, par_y => 39.5);
          END IF;
        
        END print_gender;
      
        /*Дата рождения*/
        PROCEDURE print_date_of_birth IS
        BEGIN
        
          print_text_xy(par_x     => 57
                       ,par_y     => 40.5
                       ,par_text  => to_char(v_insuree_info.date_of_birth, 'dd.mm.yyyy')
                       ,par_w     => 35
                       ,par_align => 'C');
        END print_date_of_birth;
      
        /*Гражданство*/
        PROCEDURE print_nationality IS
        BEGIN
          print_text_xy(par_x     => 131
                       ,par_y     => 40.5
                       ,par_text  => pkg_contact.get_citizenry(v_insuree_info.contact_id) || '/' ||
                                     pkg_contact.get_contact_ident_doc_by_type(v_insuree_info.contact_id
                                                                              ,'INN')
                       ,par_w     => 60
                       ,par_align => 'C');
        END print_nationality;
      
        /*Паспорт*/
        PROCEDURE print_passport IS
          v_name_doc VARCHAR2(250);
        BEGIN
          v_name_doc := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                      ,'<#TYPE_DESC>');
          IF v_name_doc IN
             ('Паспорт гражданина РФ', 'Иностранный паспорт')
          THEN
            v_name_doc := 'Паспорт';
          END IF;
          /*Наименование документа*/
          print_text_xy(par_x     => 78.5
                       ,par_y     => 45
                       ,par_text  => v_name_doc
                       ,par_w     => 26
                       ,par_align => 'C');
          /*Серия*/
          print_text_xy(par_x     => 119
                       ,par_y     => 45
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_series)
                       ,par_w     => 20
                       ,par_align => 'C');
          /*Номер*/
          print_text_xy(par_x     => 156
                       ,par_y     => 45
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_number)
                       ,par_w     => 37
                       ,par_align => 'C');
          /*кем и когда выдан паспорт*/
          print_text_xy(par_x     => 45
                       ,par_y     => 49
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                                   ,'Выдан: <#DOC_PLACE>')
                       ,par_w     => 150
                       ,par_align => 'C');
          print_text_xy(par_x     => 7
                       ,par_y     => 53.5
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                                   ,'Дата выдачи: <#DOC_DATE>')
                       ,par_w     => 65
                       ,par_align => 'R');
        
          /*Код подразделения*/
          print_text_xy(par_x     => 143
                       ,par_y     => 53.5
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_insuree_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_subdivision_code)
                       ,par_w     => 43
                       ,par_align => 'C');
        END print_passport;
      
        /*Адрес регистрации*/
        PROCEDURE print_registration_address IS
          v_contact_address_id cn_contact_address.id%TYPE;
        BEGIN
          /*Адрес постоянной регистрации*/
          v_contact_address_id := pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => v_insuree_info.contact_id
                                                                                  ,par_brief      => 'CONST');
          /*Индекс*/
          print_text_xy(par_x     => 45
                       ,par_y     => 84.7
                       ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                              ,pkg_contact_rep_utils.gc_address_zip)
                       ,par_w     => 22
                       ,par_align => 'C');
          /*Регион/область*/
          print_text_xy(par_x    => 70
                       ,par_y    => 84.7
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_province)
                        
                       ,par_w     => 59
                       ,par_align => 'C');
          /*Город/населенный пункт*/
          print_text_xy(par_x    => 132
                       ,par_y    => 84.7
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_city)
                        
                       ,par_w     => 69
                       ,par_align => 'C');
          /*Улица, дом и т.д.*/
          print_text_xy(par_x    => 7
                       ,par_y    => 89
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_street_with_house)
                        
                       ,par_w     => 195
                       ,par_align => 'C');
        END print_registration_address;
      
        /*Адрес фактический/почтовый*/
        PROCEDURE print_postal_address IS
          v_contact_address_id cn_contact_address.id%TYPE;
          /*Найти ИД адреса контакта, если он отличается от адреса регистрации*/
          FUNCTION get_different_address RETURN cn_contact_address.id%TYPE IS
            v_contact_address_id cn_contact_address.id%TYPE;
          BEGIN
            SELECT MIN(cca.id) keep(dense_rank FIRST ORDER BY tat.brief)
              INTO v_contact_address_id
              FROM cn_contact_address cca
                  ,t_address_type     tat
                  ,cn_contact_address cca_const
                  ,t_address_type     tat_const
             WHERE cca.contact_id = v_insuree_info.contact_id
               AND tat.brief IN ('POSTAL', 'FACT')
               AND cca.address_type = tat.id
               AND cca.contact_id = cca_const.contact_id
               AND cca_const.address_type = tat_const.id
               AND tat_const.brief = 'CONST'
               AND cca.adress_id != cca_const.adress_id /*Если отличаются адрес регигистрации и фактический/почтовый*/
            ;
            RETURN v_contact_address_id;
          END get_different_address;
        BEGIN
          v_contact_address_id := get_different_address;
          /*Индекс*/
          print_text_xy(par_x      => 69
                       ,par_y      => 94
                       ,par_text   => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                               ,pkg_contact_rep_utils.gc_address_zip)
                       ,par_w      => 15
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Регион/область*/
          print_text_xy(par_x    => 87
                       ,par_y    => 94
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_province)
                        
                       ,par_w      => 42
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Город/населенный пункт*/
          print_text_xy(par_x    => 132
                       ,par_y    => 94
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_city)
                        
                       ,par_w      => 70
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Улица, дом и т.д.*/
          print_text_xy(par_x    => 7
                       ,par_y    => 100.8
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_street_with_house)
                        
                       ,par_w     => 195
                       ,par_align => 'C');
        END print_postal_address;
      
        /*Телефоны*/
        PROCEDURE print_phones IS
        BEGIN
          /*Телефон по месту жительства*/
          print_text_xy(par_x     => 47
                       ,par_y     => 105.1
                       ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(v_insuree_info.contact_id
                                                                                                                                ,'HOME'))
                       ,par_w     => 25
                       ,par_align => 'C');
        
          /*Телефон мобильный*/
          print_text_xy(par_x     => 106
                       ,par_y     => 105.1
                       ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(v_insuree_info.contact_id
                                                                                                                                ,'MOBIL'))
                       ,par_w     => 35
                       ,par_align => 'C');
          /*E-mail*/
          print_text_xy(par_x     => 143
                       ,par_y     => 105.1
                       ,par_text  => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_last_active_email_id(v_insuree_info.contact_id)
                                                                            ,pkg_contact_rep_utils.gc_mask_email)
                       ,par_w     => 60
                       ,par_align => 'C');
        END print_phones;
      
        /*Галочки*/
        PROCEDURE print_marks IS
          /*Является ли страхователь застрахованным*/
          FUNCTION is_insuree_assured RETURN BOOLEAN IS
            v_res NUMBER;
          BEGIN
            SELECT COUNT(*)
              INTO v_res
              FROM dual
             WHERE EXISTS (SELECT NULL
                      FROM p_policy_contact ppc
                          ,as_asset         aa
                          ,as_assured       aad
                     WHERE ppc.contact_id = v_insuree_info.contact_id
                       AND ppc.policy_id = aa.p_policy_id
                       AND aa.as_asset_id = aad.as_assured_id
                       AND ppc.contact_id = aad.assured_contact_id);
            RETURN v_res = 1;
          END is_insuree_assured;
        BEGIN
          --Иностранное публичное лицо
          IF v_insuree_info.is_public_contact = 1
          THEN
            print_sign_xy(par_x => 84, par_y => 122);
          ELSE
            print_sign_xy(par_x => 93.3, par_y => 122);
          END IF;
          --Российское публичное лицо
          IF v_insuree_info.is_rpdl = 1
          THEN
            print_sign_xy(par_x => 188, par_y => 122);
          ELSE
            print_sign_xy(par_x => 197, par_y => 122);
          END IF;
          --Является ли страхователь застрахованным
          IF is_insuree_assured
          THEN
            print_sign_xy(par_x => 74, par_y => 128);
          ELSE
            print_sign_xy(par_x => 84, par_y => 128);
          END IF;
          --Гражданство иного государства
          IF v_insuree_info.has_additional_citizenship = 1
          THEN
            print_sign_xy(par_x => 90.5, par_y => 75.5);
            plpdf.setprintfontsize(p_size => 7);
            print_text_xy(par_x    => 155
                         ,par_y    => 75.6
                         ,par_text => substr(pkg_rep_plpdf.get_additional_citizenships(v_insuree_info.contact_id)
                                            ,1
                                            ,36));
            plpdf.setprintfontsize(p_size => 9);
          ELSE
            print_sign_xy(par_x => 100.3, par_y => 75.4);
          END IF;
        
          -- Вид на жительство в иностранном государстве
          IF v_insuree_info.has_foreign_residency = 1
          THEN
            print_sign_xy(par_x => 104, par_y => 80);
            plpdf.setprintfontsize(p_size => 7);
            print_text_xy(par_x    => 167
                         ,par_y    => 80
                         ,par_text => substr(pkg_rep_plpdf.get_foreign_residencies(v_insuree_info.contact_id)
                                            ,1
                                            ,27));
            plpdf.setprintfontsize(p_size => 9);
          
          ELSE
            print_sign_xy(par_x => 113, par_y => 80);
          END IF;
        
          -- сведения о миграционной карте
          print_text_xy(par_x    => 7
                       ,par_y    => 67
                       ,par_text => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_doc_by_type(v_insuree_info.contact_id
                                                                                                                             ,'MIGRATION_CARD')
                                                                                  ,'<#DOC_SERNUM> Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>'));
        
        END print_marks;
      
      BEGIN
        plpdf.setprintfont(p_style => NULL);
        /*ФИО страхователя*/
        print_fio;
        /*Галочка "Пол"*/
        print_gender;
        /*Дата рождения*/
        print_date_of_birth;
        /*Гражданство*/
        print_nationality;
        /*Паспорт*/
        print_passport;
        /*Адрес регистрации*/
        print_registration_address;
        /*Адрес фактический/почтовый*/
        print_postal_address;
        /*Телефоны*/
        print_phones;
        /*Галочки*/
        print_marks;
      
      END print_insuree;
    
      PROCEDURE print_asset IS
        /*ФИО страхователя*/
        PROCEDURE print_fio IS
        BEGIN
          print_text_xy(par_x => 57, par_y => 137, par_text => v_assured_info.fio, par_w => 130);
        END print_fio;
      
        /*Пол страхователя*/
        PROCEDURE print_gender IS
        BEGIN
          IF v_assured_info.gender = 'FEMALE' --Женский
          THEN
            print_sign_xy(par_x => 25.5, par_y => 141);
          ELSE
            print_sign_xy(par_x => 19, par_y => 141);
          END IF;
        
        END print_gender;
      
        /*Дата рождения*/
        PROCEDURE print_date_of_birth IS
        BEGIN
        
          print_text_xy(par_x     => 57
                       ,par_y     => 141.5
                       ,par_text  => to_char(v_assured_info.date_of_birth, 'dd.mm.yyyy')
                       ,par_w     => 35
                       ,par_align => 'C');
        END print_date_of_birth;
      
        /*Гражданство*/
        PROCEDURE print_nationality IS
        BEGIN
          print_text_xy(par_x     => 131
                       ,par_y     => 141.5
                       ,par_text  => pkg_contact.get_citizenry(v_assured_info.contact_id) || '/' ||
                                     pkg_contact.get_contact_ident_doc_by_type(v_assured_info.contact_id
                                                                              ,'INN')
                       ,par_w     => 60
                       ,par_align => 'C');
        END print_nationality;
      
        /*Паспорт*/
        PROCEDURE print_passport IS
          v_name_doc VARCHAR2(250);
        BEGIN
          v_name_doc := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                      ,'<#TYPE_DESC>');
          IF v_name_doc IN
             ('Паспорт гражданина РФ', 'Иностранный паспорт')
          THEN
            v_name_doc := 'Паспорт';
          END IF;
          /*Наименование документа*/
          print_text_xy(par_x     => 78.5
                       ,par_y     => 146
                       ,par_text  => v_name_doc
                       ,par_w     => 26
                       ,par_align => 'C');
          /*Серия*/
          print_text_xy(par_x     => 119
                       ,par_y     => 146
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_series)
                       ,par_w     => 20
                       ,par_align => 'C');
          /*Номер*/
          print_text_xy(par_x     => 156
                       ,par_y     => 146
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_number)
                       ,par_w     => 37
                       ,par_align => 'C');
          /*кем и когда выдан паспорт*/
          print_text_xy(par_x     => 45
                       ,par_y     => 150.3
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                                   ,'Выдан: <#DOC_PLACE>')
                       ,par_w     => 150
                       ,par_align => 'C');
          print_text_xy(par_x     => 7
                       ,par_y     => 154.5
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                                   ,'Дата выдачи: <#DOC_DATE>')
                       ,par_w     => 65
                       ,par_align => 'R');
          /*Код подразделения*/
          print_text_xy(par_x     => 143
                       ,par_y     => 154.5
                       ,par_text  => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(v_assured_info.contact_id)
                                                                                   ,pkg_contact_rep_utils.gc_mask_doc_subdivision_code)
                       ,par_w     => 43
                       ,par_align => 'C');
        END print_passport;
      
        /*Адрес регистрации*/
        PROCEDURE print_registration_address IS
          v_contact_address_id cn_contact_address.id%TYPE;
        BEGIN
          /*Адрес постоянной регистрации*/
          v_contact_address_id := pkg_contact_rep_utils.get_last_active_address_id(par_contact_id => v_assured_info.contact_id
                                                                                  ,par_brief      => 'CONST');
          /*Индекс*/
          print_text_xy(par_x     => 45
                       ,par_y     => 185
                       ,par_text  => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                              ,pkg_contact_rep_utils.gc_address_zip)
                       ,par_w     => 22
                       ,par_align => 'C');
          /*Регион/область*/
          print_text_xy(par_x    => 70
                       ,par_y    => 185
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_province)
                        
                       ,par_w     => 59
                       ,par_align => 'C');
          /*Город/населенный пункт*/
          print_text_xy(par_x    => 132
                       ,par_y    => 185
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_city)
                        
                       ,par_w     => 69
                       ,par_align => 'C');
          /*Улица, дом и т.д.*/
          print_text_xy(par_x    => 7
                       ,par_y    => 189.3
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_street_with_house)
                        
                       ,par_w     => 195
                       ,par_align => 'C');
        END print_registration_address;
      
        /*Адрес фактический/почтовый*/
        PROCEDURE print_postal_address IS
          v_contact_address_id cn_contact_address.id%TYPE;
          /*Найти ИД адреса контакта, если он отличается от адреса регистрации*/
          FUNCTION get_different_address RETURN cn_contact_address.id%TYPE IS
            v_contact_address_id cn_contact_address.id%TYPE;
          BEGIN
            SELECT MIN(cca.id) keep(dense_rank FIRST ORDER BY tat.brief)
              INTO v_contact_address_id
              FROM cn_contact_address cca
                  ,t_address_type     tat
                  ,cn_contact_address cca_const
                  ,t_address_type     tat_const
             WHERE cca.contact_id = v_assured_info.contact_id
               AND tat.brief IN ('POSTAL', 'FACT')
               AND cca.address_type = tat.id
               AND cca.contact_id = cca_const.contact_id
               AND cca_const.address_type = tat_const.id
               AND tat_const.brief = 'CONST'
               AND cca.adress_id != cca_const.adress_id /*Если отличаются адрес регигистрации и фактический/почтовый*/
            ;
            RETURN v_contact_address_id;
          END get_different_address;
        BEGIN
          v_contact_address_id := get_different_address;
          /*Индекс*/
          print_text_xy(par_x      => 69
                       ,par_y      => 194
                       ,par_text   => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                               ,pkg_contact_rep_utils.gc_address_zip)
                       ,par_w      => 15
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Регион/область*/
          print_text_xy(par_x    => 87
                       ,par_y    => 194
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_province)
                        
                       ,par_w      => 42
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Город/населенный пункт*/
          print_text_xy(par_x    => 132
                       ,par_y    => 194
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_city)
                        
                       ,par_w      => 70
                       ,par_align  => 'C'
                       ,par_coef_h => 2);
          /*Улица, дом и т.д.*/
          print_text_xy(par_x    => 7
                       ,par_y    => 200.65
                       ,par_text => pkg_contact_rep_utils.get_address_by_mask(v_contact_address_id
                                                                             ,pkg_contact_rep_utils.gc_address_street_with_house)
                        
                       ,par_w     => 195
                       ,par_align => 'C');
        END print_postal_address;
      
        /*Телефоны*/
        PROCEDURE print_phones IS
        BEGIN
          /*Телефон по месту жительства*/
          print_text_xy(par_x     => 47
                       ,par_y     => 204.8
                       ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(v_assured_info.contact_id
                                                                                                                                ,'HOME'))
                       ,par_w     => 25
                       ,par_align => 'C');
        
          /*Телефон мобильный*/
          print_text_xy(par_x     => 106
                       ,par_y     => 204.8
                       ,par_text  => pkg_contact_rep_utils.get_phone_number_by_id(pkg_contact_rep_utils.get_last_active_phone_id(v_assured_info.contact_id
                                                                                                                                ,'MOBIL'))
                       ,par_w     => 35
                       ,par_align => 'C');
          /*E-mail*/
          print_text_xy(par_x     => 143
                       ,par_y     => 204.8
                       ,par_text  => pkg_contact_rep_utils.get_email_by_mask(pkg_contact_rep_utils.get_last_active_email_id(v_assured_info.contact_id)
                                                                            ,pkg_contact_rep_utils.gc_mask_email)
                       ,par_w     => 60
                       ,par_align => 'C');
        END print_phones;
      
        /*Галочки*/
        PROCEDURE print_marks IS
          /*Является ли страхователь застрахованным*/
          FUNCTION is_insuree_assured RETURN BOOLEAN IS
            v_res NUMBER;
          BEGIN
            SELECT COUNT(*)
              INTO v_res
              FROM dual
             WHERE EXISTS (SELECT NULL
                      FROM p_policy_contact ppc
                          ,as_asset         aa
                          ,as_assured       aad
                     WHERE ppc.contact_id = v_assured_info.contact_id
                       AND ppc.policy_id = aa.p_policy_id
                       AND aa.as_asset_id = aad.as_assured_id
                       AND ppc.contact_id = aad.assured_contact_id);
            RETURN v_res = 1;
          END is_insuree_assured;
        BEGIN
          --Иностранное публичное лицо
          IF v_assured_info.is_public_contact = 1
          THEN
            print_sign_xy(par_x => 84, par_y => 222);
          ELSE
            print_sign_xy(par_x => 93.3, par_y => 222);
          END IF;
          --Российское публичное лицо
          IF v_assured_info.is_rpdl = 1
          THEN
            print_sign_xy(par_x => 188, par_y => 222);
          ELSE
            print_sign_xy(par_x => 197.5, par_y => 222);
          END IF;
          --Гражданство иного государства
          IF v_assured_info.has_additional_citizenship = 1
          THEN
            print_sign_xy(par_x => 90.5, par_y => 175.5);
            plpdf.setprintfontsize(p_size => 7);
            print_text_xy(par_x    => 155
                         ,par_y    => 175.6
                         ,par_text => substr(pkg_rep_plpdf.get_additional_citizenships(v_assured_info.contact_id)
                                            ,1
                                            ,36));
            plpdf.setprintfontsize(p_size => 9);
          ELSE
            print_sign_xy(par_x => 100.3, par_y => 175.4);
          END IF;
        
          -- Вид на жительство в иностранном государстве
          IF v_assured_info.has_foreign_residency = 1
          THEN
            print_sign_xy(par_x => 110, par_y => 180);
            plpdf.setprintfontsize(p_size => 7);
            print_text_xy(par_x    => 173
                         ,par_y    => 180
                         ,par_text => substr(pkg_rep_plpdf.get_foreign_residencies(v_assured_info.contact_id)
                                            ,1
                                            ,24));
            plpdf.setprintfontsize(p_size => 9);
          
          ELSE
            print_sign_xy(par_x => 119, par_y => 180);
          END IF;
        
          -- сведения о миграционной карте
          print_text_xy(par_x    => 7
                       ,par_y    => 167
                       ,par_text => pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_doc_by_type(v_assured_info.contact_id
                                                                                                                             ,'MIGRATION_CARD')
                                                                                  ,'<#DOC_SERNUM> Выдан: <#DOC_PLACE> Дата выдачи: <#DOC_DATE>'));
        
        END print_marks;
      
      BEGIN
        plpdf.setprintfont(p_style => NULL);
        /*ФИО страхователя*/
        print_fio;
        /*Галочка "Пол"*/
        print_gender;
        /*Дата рождения*/
        print_date_of_birth;
        /*Гражданство*/
        print_nationality;
        /*Паспорт*/
        print_passport;
        /*Адрес регистрации*/
        print_registration_address;
        /*Адрес фактический/почтовый*/
        print_postal_address;
        /*Телефоны*/
        print_phones;
        /*Галочки*/
        print_marks;
      END print_asset;
    
      PROCEDURE print_period IS
        v_period_value t_period.period_value%TYPE;
      BEGIN
        SELECT period_value
          INTO v_period_value
          FROM t_period t
         WHERE t.description = v_pol_sum.policy_period_desc;
      
        print_text_xy2(par_x    => 20
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.start_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 33
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.start_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 48
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.start_date, 'yy')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 64
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.end_date, 'dd')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 76
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.end_date, 'mm')
                      ,par_w    => 10);
        print_text_xy2(par_x    => 93
                      ,par_y    => 236
                      ,par_text => to_char(v_pol_sum.end_date, 'yy')
                      ,par_w    => 10);
      END print_period;
    
      PROCEDURE print_currency IS
      BEGIN
        IF v_pol_sum.fund_brief = 'USD'
        THEN
          print_sign_xy(par_x => 58, par_y => 228.5);
        ELSIF v_pol_sum.fund_brief = 'EUR'
        THEN
          print_sign_xy(par_x => 100, par_y => 228.5);
        END IF;
      END print_currency;
    
      PROCEDURE print_programms IS
        v_is_program BOOLEAN := FALSE;
      BEGIN
      
        FOR rec IN (SELECT pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                          ,nvl(pc.fee, 0) AS fee
                      FROM t_prod_line_option plo
                          ,t_product_line pl
                          ,v_prod_product_line ppl
                          ,(SELECT pc.t_prod_line_option_id
                                  ,pc.ins_amount
                                  ,pc.fee
                              FROM p_cover  pc
                                  ,as_asset aa
                             WHERE aa.p_policy_id = v_policy_id
                               AND aa.as_asset_id = pc.as_asset_id
                               AND pc.status_hist_id != pkg_cover.status_hist_id_del
                               AND aa.status_hist_id != pkg_asset.status_hist_id_del) pc
                     WHERE ppl.product_brief = v_pol_sum.product_brief
                       AND ppl.t_product_line_id = plo.product_line_id
                       AND ppl.t_product_line_id = pl.id
                       AND plo.id = pc.t_prod_line_option_id
                       AND plo.brief = 'Ins_life_to_date')
        LOOP
          v_is_program := TRUE;
          print_text_xy2(par_x     => 143
                        ,par_y     => 260
                        ,par_text  => rec.ins_amount
                        ,par_w     => 28
                        ,par_align => 'C');
          print_text_xy2(par_x     => 175
                        ,par_y     => 260
                        ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                        ,par_w     => 28
                        ,par_align => 'C');
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
        IF v_is_program
        THEN
          FOR rec IN (SELECT nvl(pl.public_description, pl.description) AS description
                            ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                            ,SUM(nvl(pc.fee, 0)) over() AS fee
                            ,plo.brief
                            ,row_number() over(ORDER BY pl.sort_order) AS rn
                        FROM t_prod_line_option plo
                            ,t_product_line pl
                            ,v_prod_product_line ppl
                            ,t_product_line_type plt
                            ,(SELECT pc.t_prod_line_option_id
                                    ,pc.ins_amount
                                    ,pc.fee
                                FROM p_cover  pc
                                    ,as_asset aa
                               WHERE aa.p_policy_id = v_policy_id
                                 AND aa.as_asset_id = pc.as_asset_id
                                 AND pc.status_hist_id != pkg_cover.status_hist_id_del
                                 AND aa.status_hist_id != pkg_asset.status_hist_id_del) pc
                       WHERE ppl.product_brief = v_pol_sum.product_brief
                         AND ppl.t_product_line_id = plo.product_line_id
                         AND ppl.t_product_line_id = pl.id
                         AND plo.id = pc.t_prod_line_option_id
                         AND plt.product_line_type_id = pl.product_line_type_id
                         AND plt.brief = 'MANDATORY'
                       ORDER BY pl.sort_order)
          LOOP
            IF rec.rn = 2
            THEN
              print_text_xy2(par_x     => 143
                            ,par_y     => 276 + (rec.rn - 1) * 2.9
                            ,par_text  => rec.ins_amount
                            ,par_w     => 28
                            ,par_align => 'C');
              print_text_xy2(par_x     => 175
                            ,par_y     => 276 + (rec.rn - 1) * 2.9
                            ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                            ,par_w     => 28
                            ,par_align => 'C');
            
              v_total_fee := v_total_fee + rec.fee;
            END IF;
          END LOOP;
        END IF;
      END print_programms;
    
      PROCEDURE print_insurer_info_default IS
      BEGIN
        plpdf.setprintfontsize(p_size => 7);
        print_text_xy(par_x      => 57
                     ,par_y      => 6
                     ,par_w      => 147
                     ,par_text   => pkg_contact_rep_utils.get_insurer_info(par_mask => pkg_contact_rep_utils.gc_company_def_info)
                     ,par_h      => 3.5
                     ,par_coef_h => 4.3);
        plpdf.setprintfontsize(p_size => 9);
      END print_insurer_info_default;
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page1_id := plpdf.instemplate(v_tmpl_page1);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page1_id);
      -- реквизиты страхователя
      print_insurer_info_default;
      --Заголовок - номер заявления
      print_header;
      --Страхователь
      print_insuree;
      --Застрахованные
      print_asset;
    
      print_period;
      print_currency;
      print_programms;
    END print_page1;
  
    /*Печать страницы №2 заявления*/
    PROCEDURE print_page2 IS
      PROCEDURE print_programms IS
        v_is_program BOOLEAN := FALSE;
      BEGIN
        FOR rec IN (SELECT pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                          ,nvl(pc.fee, 0) AS fee
                      FROM t_prod_line_option plo
                          ,t_product_line pl
                          ,v_prod_product_line ppl
                          ,(SELECT pc.t_prod_line_option_id
                                  ,pc.ins_amount
                                  ,pc.fee
                              FROM p_cover  pc
                                  ,as_asset aa
                             WHERE aa.p_policy_id = v_policy_id
                               AND aa.as_asset_id = pc.as_asset_id
                               AND pc.status_hist_id != pkg_cover.status_hist_id_del
                               AND aa.status_hist_id != pkg_asset.status_hist_id_del) pc
                     WHERE ppl.product_brief = v_pol_sum.product_brief
                       AND ppl.t_product_line_id = plo.product_line_id
                       AND ppl.t_product_line_id = pl.id
                       AND plo.id = pc.t_prod_line_option_id
                       AND plo.brief = 'END')
        LOOP
          v_is_program := TRUE;
          print_text_xy2(par_x     => 143
                        ,par_y     => 18
                        ,par_text  => rec.ins_amount
                        ,par_w     => 28
                        ,par_align => 'C');
          print_text_xy2(par_x     => 175
                        ,par_y     => 18
                        ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                        ,par_w     => 28
                        ,par_align => 'C');
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      
        IF v_is_program
        THEN
          FOR rec IN (SELECT nvl(pl.public_description, pl.description) AS description
                            ,pkg_rep_utils.to_money_sep(nvl(pc.ins_amount, 0)) ins_amount
                            ,SUM(nvl(pc.fee, 0)) over() AS fee
                            ,plo.brief
                            ,row_number() over(ORDER BY pl.sort_order) AS rn
                        FROM t_prod_line_option plo
                            ,t_product_line pl
                            ,v_prod_product_line ppl
                            ,t_product_line_type plt
                            ,(SELECT pc.t_prod_line_option_id
                                    ,pc.ins_amount
                                    ,pc.fee
                                FROM p_cover  pc
                                    ,as_asset aa
                               WHERE aa.p_policy_id = v_policy_id
                                 AND aa.as_asset_id = pc.as_asset_id) pc
                       WHERE ppl.product_brief = v_pol_sum.product_brief
                         AND ppl.t_product_line_id = plo.product_line_id
                         AND ppl.t_product_line_id = pl.id
                         AND plo.id = pc.t_prod_line_option_id
                         AND plt.product_line_type_id = pl.product_line_type_id
                         AND plt.brief = 'MANDATORY'
                         AND plo.brief IN ('AD', 'AD_AVTO')
                       ORDER BY pl.sort_order)
          LOOP
            IF rec.rn = 1
            THEN
              print_text_xy2(par_x     => 143
                            ,par_y     => 30 + (rec.rn - 1) * 2.9
                            ,par_text  => rec.ins_amount
                            ,par_w     => 28
                            ,par_align => 'C');
              print_text_xy2(par_x     => 175
                            ,par_y     => 30 + (rec.rn - 1) * 2.9
                            ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                            ,par_w     => 28
                            ,par_align => 'C');
            
              v_total_fee := v_total_fee + rec.fee;
            END IF;
          END LOOP;
        END IF;
        FOR rec IN (SELECT SUM(nvl(pc.fee, 0)) over() AS fee
                      FROM t_prod_line_option plo
                          ,t_product_line pl
                          ,v_prod_product_line ppl
                          ,t_product_line_type plt
                          ,(SELECT pc.t_prod_line_option_id
                                  ,pc.ins_amount
                                  ,pc.fee
                              FROM p_cover  pc
                                  ,as_asset aa
                             WHERE aa.p_policy_id = v_policy_id
                               AND aa.as_asset_id = pc.as_asset_id) pc
                     WHERE ppl.product_brief = v_pol_sum.product_brief
                       AND ppl.t_product_line_id = plo.product_line_id
                       AND ppl.t_product_line_id = pl.id
                       AND plo.id = pc.t_prod_line_option_id
                       AND plt.product_line_type_id = pl.product_line_type_id
                       AND plt.brief = 'OPTIONAL'
                     ORDER BY pl.sort_order)
        LOOP
          IF v_is_small_notice
          THEN
            print_sign_xy(par_x => 7, par_y => 46);
          ELSE
            print_sign_xy(par_x => 7, par_y => 44);
          END IF;
          print_text_xy2(par_x     => 175
                        ,par_y     => 85
                        ,par_text  => pkg_rep_utils.to_money_sep(rec.fee)
                        ,par_w     => 28
                        ,par_align => 'C');
        
          v_total_fee := v_total_fee + rec.fee;
        END LOOP;
      
        -- итого
        IF v_is_small_notice
        THEN
          print_text_xy(par_x     => 175
                       ,par_y     => 125.5
                       ,par_text  => pkg_rep_utils.to_money_sep(v_total_fee)
                       ,par_w     => 28
                       ,par_align => 'C');
          print_text_xy(par_x    => 80
                       ,par_y    => 130.3
                       ,par_text => pkg_utils.money2speech(v_total_fee, 122));
        ELSE
          print_text_xy(par_x     => 175
                       ,par_y     => 122.5
                       ,par_text  => pkg_rep_utils.to_money_sep(v_total_fee)
                       ,par_w     => 28
                       ,par_align => 'C');
          print_text_xy(par_x    => 80
                       ,par_y    => 127.5
                       ,par_text => pkg_utils.money2speech(v_total_fee, 122));
        
        END IF;
      END print_programms;
    
      PROCEDURE print_payment_terms IS
      BEGIN
        IF v_is_small_notice
        THEN
          IF v_pol_sum.payment_terms = 'Раз в полгода'
          THEN
            print_sign_xy(par_x => 135, par_y => 135);
          ELSIF v_pol_sum.payment_terms = 'Ежеквартально'
          THEN
            print_sign_xy(par_x => 170, par_y => 135);
          
          ELSIF v_pol_sum.payment_terms = 'Ежегодно'
          THEN
            print_sign_xy(par_x => 100, par_y => 135);
          END IF;
        ELSE
          IF v_pol_sum.payment_terms = 'Раз в полгода'
          THEN
            print_sign_xy(par_x => 135, par_y => 132);
          ELSIF v_pol_sum.payment_terms = 'Ежеквартально'
          THEN
            print_sign_xy(par_x => 170, par_y => 132);
          
          ELSIF v_pol_sum.payment_terms = 'Ежегодно'
          THEN
            print_sign_xy(par_x => 100, par_y => 132);
          END IF;
        END IF;
      END;
    
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page2_id := plpdf.instemplate(v_tmpl_page2);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page2_id);
      /*Обязательно выставить, иначе переводит на новую страницу*/
      plpdf.setautonewpage(p_auto => FALSE);
      /*Застрахованные дети*/
      --print_assureds;
      /*Заполнение страховых программ*/
      print_programms;
      -- Периодичность
      print_payment_terms;
    END print_page2;
  
    /*Печать страницы №3 заявления*/
    PROCEDURE print_page3 IS
      /*Итоговая сумма взноса*/
      PROCEDURE print_total_fee(par_fee NUMBER) IS
        v_y NUMBER := 6.4;
      BEGIN
      
        /*прописью*/
        plpdf.setprintfont(p_size => 7);
        plpdf.setcurrentxy(p_x => 60, p_y => v_y);
        plpdf.printmultilinecell(p_txt      => pkg_utils.money2speech(par_fee, 122)
                                ,p_h        => 4
                                ,p_clipping => 0);
      
      END print_total_fee;
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page3_id := plpdf.instemplate(v_tmpl_page3);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page3_id);
    
      print_total_fee(par_fee => v_total_fee);
    END print_page3;
  
    /*Печать страницы №4 заявления*/
    PROCEDURE print_page4 IS
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page4_id := plpdf.instemplate(v_tmpl_page4);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page4_id);
    END print_page4;
  
    /*Печать страницы №5 заявления*/
    PROCEDURE print_page5 IS
    BEGIN
      --Вставка шаблона как фона для страницы
      v_tmpl_page5_id := plpdf.instemplate(v_tmpl_page5);
      plpdf.newpage;
      --Использовать шаблон первой страницы
      plpdf.usetemplate(v_tmpl_page5_id);
    END print_page5;
  BEGIN
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
    v_assured_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.assured_array(1));
  
    /*Загрузка шаблонов страниц для заялвения*/
    v_is_small_notice := ((v_pol_sum.ins_amount <= 750000) AND (v_pol_sum.fund_brief = 'USD')) OR
                         ((v_pol_sum.ins_amount <= 600000) AND (v_pol_sum.fund_brief = 'EUR'));
    IF v_is_small_notice
    THEN
      load_templates_small;
    ELSE
      load_templates_big;
    END IF;
  
    --Установка настоек для печати документа (цвет текста)
    init_print_settings;
  
    --Печать страницы №1
    print_page1;
    --Печать страницы №2
    print_page2;
    --Печать страницы №3
    print_page3;
    --Печать страницы №4
    print_page4;
    --Печать страницы №5
    print_page5;
  
    plpdf.senddoc(p_blob => par_data);
  
    par_file_name    := 'notice_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END rep_dostoyanie_notice_p;

END pkg_rep_plpdf_template;
/

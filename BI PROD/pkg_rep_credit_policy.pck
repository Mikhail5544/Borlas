CREATE OR REPLACE PACKAGE pkg_rep_credit_policy IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 26.06.2014 18:17:08
  -- Purpose : ������ ��������� ���������

  gv_datas    plpdf_type.t_row_datas; -- Array of datas
  gv_borders  plpdf_type.t_row_borders; -- Array of borders
  gv_widths   plpdf_type.t_row_widths; -- Array of widths
  gv_aligns   plpdf_type.t_row_aligns; -- Array of aligns
  gv_styles   plpdf_type.t_row_styles; -- Array of styles
  gv_maxlines plpdf_type.t_row_maxlines; -- Array of max lines

  -- ����� ��� ��������� ��������
  -- 365957: ������ �� ��������� �������� ��� �������
  -- ����������� �., ������, 2014  
  PROCEDURE rep_evrosib
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� "��� CR50_3"
  -- ����������� �., ����, 2014
  PROCEDURE rep_ekb_503_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� ����� �� ��������� CR50_5/CR50_6
  -- ����������� �., ����, 2014
  PROCEDURE rep_ekb_5056_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� "��� CR50_7/CR50_8/CR50_9"
  -- ����������� �., ����, 2014
  PROCEDURE rep_ekb_50789_policy
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� �������� ���
  -- 339295 - ������ �� ��������� �������� ���
  -- �����������, �������, 2014
  PROCEDURE rep_tkb
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /** 
  * ����� ����� ��� ���
  * @task 404551
  * @author ����� �.
  */
  PROCEDURE rep_tkb_payment_doc
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --��� CR122
  PROCEDURE rep_rbr
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  --����� ��103%
  PROCEDURE rep_rolf_2015
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� CR123%
  -- 397365: ����� ��������� ���������
  -- ����������� �., ����, 2014
  PROCEDURE rep_irbis
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ������� ���
  -- CR107_8  - CR107_8 ��� ������� 
  -- CR107_9  - CR107_9 ��� �����
  -- CR107_10 - CR107_10 ��� �������
  PROCEDURE rep_avtodom_bmw
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  -- ����� ������� ����������
  -- CR107_11  - ���������� 2 �����
  -- CR107_12 - ���������� 3 �����
  -- CR107_13 - ���������� 4 �����
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

  -- ����� ���������� ��������
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
   ,par_title           VARCHAR2 DEFAULT '������� ����������� ����� � �������� ��������� �������     � '
   ,par_policyform_note VARCHAR2 DEFAULT '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������'
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
                                  ' �.'
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
                   ,p_txt      => gv_chapter_num || '. ����������:'
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
                   ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                   ,p_border   => 'LRT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => '�������'
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
                            ,p_txt      => '          ���� ��������'
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
                   ,p_txt      => '���'
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
                   ,p_txt      => '          ��������, �������������� ��������'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    /*��������� ���������� ������ ������ ��� ������� �������� (�������������� 28.04.2014 ������ �.�. ���������� no_data_found)*/
    IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
    THEN
      l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#TYPE_DESC>');
      l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#DOC_SERNUM>');
      l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
    
    END IF; /*����� ����������� 28.04.2014*/
  
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
                   ,p_txt      => '��������'
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
                   ,p_txt      => '��� � ����� �����'
                   ,p_align    => 'C'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => gv_default_height -- -1
                   ,p_txt      => '�����'
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
                   ,p_txt      => gv_chapter_num || '. ���� �������� �������� �����������:'
                   ,p_border   => '1'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => ROUND(MONTHS_BETWEEN(par_policy_summary.end_date
                                                      ,par_policy_summary.start_date)) || ' �������'
                   ,p_w        => 50
                   ,p_border   => 'LBT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 25
                   ,p_txt      => '� ' || to_char(par_policy_summary.start_date, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => 'BT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 25
                   ,p_txt      => '�� ' || to_char(par_policy_summary.end_date, 'dd.mm.yyyy')
                   ,p_align    => 'C'
                   ,p_border   => 'BT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    plpdf.printcell(p_border => 'TBR', p_ln => 1, p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
  END print_period;

  /*
  ������ ��� ��������� ����� ��� ��������� ������� ������
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
    v_text := gv_chapter_num || '. ������ ��������:';
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
    v_text := gv_chapter_num || '. ���������� � ����� �������� ��������� ������:';
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => v_text
                   ,p_w        => plpdf.gettextwidth(v_text) + 5
                   ,p_border   => 'LTB'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
    set_font;
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => '���� ���, 24 ���� � �����'
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
                   ,p_txt      => gv_chapter_num || '. ���������� ������������/���������������:'
                   ,p_border   => 'LRT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => '��������� ������������/�������������� ��������, ��� ��:'
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
                   ,p_txt      => '��, � ���� ��������� ��������� ���������� � �������:'
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
                   ,p_txt    => gv_chapter_num || '. �������������� �������:'
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
       ('������� ������������� �� B2B', '������')
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
  
    pkg_rep_plpdf.gv_datas(1) := '������������';
    pkg_rep_plpdf.gv_datas(2) := '��������������';
    pkg_rep_plpdf.gv_datas(3) := '����������';
  
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
  
    pkg_rep_plpdf.gv_datas(1) := '�������� ������� �� ��������� ����������� ����� � �������� �������� �������  �������(�), ����������(�) � ������ ������ � ��������(��).';
    pkg_rep_plpdf.gv_datas(2) := '� ����������� �������������������� ��������(��)';
    pkg_rep_plpdf.gv_datas(3) := '������������� �� ������������ ' || v_signer.short_name || chr(13) ||
                                 '(��� �' || v_signer.procuratory_num || ')';
  
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
  
    pkg_rep_plpdf.gv_datas(1) := '�������         ����������� �������' || chr(13) || '����';
    pkg_rep_plpdf.gv_datas(2) := '�������         ����������� �������' || chr(13) || '����';
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
  
    v_text := '���.  ' || to_char(v_current_page) || ' �� {nb}';
  
    plpdf.printcell(p_txt        => v_text
                   ,p_border     => 0
                   ,p_align      => 'C'
                   ,p_ln         => 0
                   ,p_h          => 5
                   ,p_vert_align => 'B');
  
  END print_footer;

  -- ����� ��� ��������� ��������
  -- 365957: ������ �� ��������� �������� ��� �������
  -- ����������� �., ������, 2014  
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
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
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
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
                     ,p_txt      => '��������'
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
                     ,p_txt      => '��� � ����� �����'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '����c'
                     ,p_w        => plpdf.getpagespace
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      --������
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
    
      --������� � ������ ������                 
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 20
                     ,p_txt      => '������'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� ����� ��������� �����������';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������ (�����)';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                          pl.description || ' (����� "������ ��"**)'
                                         WHEN plo.brief = 'ANY_1_GR' THEN
                                          pl.description || ' (����� "������������")'
                                         WHEN plo.brief = 'ATD_Any' THEN
                                          pl.description || ' (����� "��� ��")'
                                       END) public_description
                                      ,pkg_rep_utils.to_money_sep(pc.ins_amount) ins_amount
                                      ,pkg_rep_utils.to_money_sep(pc.fee) fee
                                      , (CASE
                                          WHEN plo.brief IN ('TERM_2', 'ANY_1_GR') THEN
                                           '100% �� ��������� �����'
                                          WHEN plo.brief = 'ATD_Any' THEN
                                           '1/30  (����  ���������)  ��  �������  ������������  ������� 
���������������  ��  �������,  �  ������������  �  �������� 
��������  ��  ����������  ��������  ��  ������  ���� 
������������������  ������������  ������,  �������  �  31-�� 
(��������  �������)  ���  ��������  ������������������,  ��  �� 
�����, ��� �� 180 (��� �����������) ���� ������������������ 
��  ������  ����������  ������  �  ��  �����  ���  ��  360  (������ 
����������) ����  �� ���� ���� ����������� �� ���� ��������� 
������� � �� ����� 50 000(��������� �����) ������ � �����.'
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height - 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������: '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => '*  ��������� ����� ��  ������ ������� �ϻ � �������������� ����� ������� �������������� ����� ������� �� ���������� �������� �� 
������  ���  ����������.  �  �������  ��������  ��������  �����������  ���������  �����  �����������  �  ������������  �  �������������� 
�������� �������� � ����� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� 
��������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => '��������� ����� �� ������ ���� �ϻ ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ 
��� ����������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              , p_txt      => '** ����� ������� - ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� 
�������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���.'
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
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
                                              '.1. ������ �������������������� �� ��������� ������ �������  �ϻ � �������������� ���������� ��������,   � ����, ������ ������� 
�����������  �������������  ���������������  ��  �������,  ��  ��  �����  �����  ���������  �������  ��������: 
____________________________________________________________________________________________________________________________'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              , p_txt      => gv_chapter_num ||
                                              '.2.  ���������������������   ��  ����������  �����   �������  �ϻ  �  ����,  ����������  �����  ����������  ������������  ��   ��������� 
������� ������� �������������������, ���������� �. 7.1. ���������� ��������, �������� ��������� ����: ���������� �� ������; '
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              , p_txt      => gv_chapter_num ||
                                              '.3.  ��������������������  ��  ����������  �����  ��������������  �  ����,  ����������  �����  ����������  ������������  ��  ��������� 
������� ������� �������������������, ���������� �. 7.1. ���������� ��������, ��������  ��������������;'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             '.4. �������������������� �� ����� ���� �ϻ �������� ��������������.'
                              ,p_border   => 'LRB'
                              ,p_ln       => 1);
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� 
��������;  ��  ��������  ��������  ����������,  ��������  ��������������,  ������������  �������������;  ��  �����������  ���������, 
����������� ��������, �� �������� ������������, �/��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������,
��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� 
�  �.�.;';
      v_declaration_states(2) := '��  ���������  �  ���������  ����������  ����������  ���  ������  �����������,  ���������������  ���  ����������  ���, 
������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 
7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� 
������,  ���������,  ������������������  ���������  (�������  �����������  �������  ������,  �������  (�������  ������������  �������), 
���������� (II-IV  �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), 
������  ������,  �����������  �������,  ���������������  ���  �����������������  �������,  ����������,  �  �����  �����  ������������ 
�������������,  ����������  ����������  ������������,  �������,  ������������  ���  ����������;';
      v_declaration_states(4) := '��  ���������  2  (���)  ����  �� ���������(-���)  ��  ����������  �����  ������  3  (���)  ������  ������  �  �����  (����  ��  �������  ����,  ��  ��������  ������  ������������� 
��������, �����, ������, �� ��������� ������������ �������������� � �� ��������� � ������) �/��� �� ��� ��������� �� ������������ 
�������  (�  ���  �����,  ����   �������   �������  �  �������������,  ���������  ���������  ������������),  ���  ��  ���������  12  �������  �� 
��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ���������  ������  ��  ���������  ���  �����������  �����,  ��  �������,  ��  ���������  ���������  �  �����  �  �����-����  ������������ 
(����������  ��������)  ���  �  ���������  ����/���  ��  �������������  �������/��������  �  ��/���  ��  ���������  ����������  �  �����  �� 
�������  ������-����  �����������  �  ���������  �����   ��  �����������  ���������  �  �����������  �/���  �����������  ������������� 
��������,  �  �������  ����������  ������  �  �������  ����������  ���������  ����������;';
      v_declaration_states(6) := '��  ������(-�)  �  ������  ������  �  �����  � 
��������  �������������  (��������:  ���������,  ������  �  �����������  �  �����������  ����������,  �����������  ����������  ���������, 
������  ��  ������,  ���  ������,  ���  �����,  ��  ��������  �  �������  ����������,  �  �������,  �  ������������������  �������,  ��������� �, 
���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ 
���������  (�����);';
      v_declaration_states(7) := '��  �������(-�)  ���������  ��  �����������  �����,  �����������  ��  ����������  �������  �  ��������,  ������ 
���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ 
��������  (�  �����������  ����������  �������������,  ����������  ���  ������  �������),  �  �����  �����������  ���������  �����������, 
�������  ����  �����������  ��  �������  �������������  ����������  ���  ������������  �������  �������  ����  ��������  ��   ����������� 
������ ������� �����;';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� 
�� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ���������� ����� ���������; ���� 160 ��, ��� 85 ��, 
������� - 75 - ����������� ��������� ������).';
      v_declaration_states(9) := '�� �������� �����������/���������� ��������� ����������� �����.';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� 
������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� 
������� ����� � ��������� �������; ��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ �������� � 
����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ��� �� �
����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 4 000 000 (������ ��������) ������; ��� � 
������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ����������� �, 
������� � �.�.), ������������� �� ���������� ��������� �������� ��� ��� ���������� ������ ����� ����������� ���������� 
(���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � �� ����� 
������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������; ��� � �������� ��������������� 
��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� 
������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, 
��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ 
�/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� 
�� ���� ����� ����������; ��� � ������(-��), �����(-�) � ��������(-��) � ���������� ��������� ����������� ����� � �������� ��������� 
�������.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    
    END print_declaration_custom;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '���  ����������  ���������  ������������,  �����������  �  ����������  ��������,  �  �����  ��� 
����������  �  ����������  �  ����������  ��������,  ��������  ���  ���������  �  ������������  ������.';
      v_add_cond_states(2) := '�������  ��������  ������ 
����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � 
��������������  �����)  �  ���������  ��������,  �  �����  ��  ����  �����������  �  ��������������  �����������  �  ����.';
      v_add_cond_states(3) := '���������� 
���������  �������,  ������������  �  ������������  c  �����������  �������  ��  27  ����  2006  �.  �  152-��  ��  ������������  ������� 
�������������  ���������  ��������  ���  ���  ����������  ������  ��������  ��  ���������,  �  ���  �����  ��������  ������  ��  ���������� 
��������,  ����������������  ������������  (�  ���  �����  �����������  ��  �������)  �����  ������������  ������,  �  ���  �����  ������  � 
��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� 
�������������  ������  ���������  �  �������  �������  �����,  �  ���  �����  �  �����  ����������  �����  �������������  �  ������������ 
�������� �����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � 
�������  15  ���  �����  ���������  �����  ��������  ����������  ��������  �  �����  ����  ��������  �������������  (��������������)  �  ����� 
������  �������  �����  ��������  �����������  ������������  �������������  (��������������)  �����������  �����������.';
      v_add_cond_states(4) := '�  ������ ������ ������������ �� �������� ���������, ������ �� ������������ ������������.';
      print_additional_conditions(v_add_cond_states);
    END print_additional_cond_custom;
  
  BEGIN
    gv_default_height := 4;
    v_policy_id       := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- ������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    -- ������� ��������    
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    plpdf.newpage;
    gv_default_height := 3;
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    gv_default_height := 4;
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
              ,par_policy_summary  => v_pol_sum);
  
    -- ������� ��������          
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
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
                   ,p_txt => '������� ����������� ����� � �������� ��������� �������     � ' ||
                             par_policy_summary.pol_num
                    --                     ,p_border   => 'LRT'
                    --                     ,p_align    => 'R'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    plpdf.printcell(p_h   => gv_default_height
                   ,p_txt => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������, ������������ 20.02.2012'
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
                               ' �.'
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
                   ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                   ,p_border   => 'LT'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font;
    plpdf.printcell(p_txt      => '��� �������: ��������������� '
                   ,p_w        => 50
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_txt      => '��������� ������� � '
                   ,p_w        => 30
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_txt      => par_pol_sum.credit_account_number
                   ,p_w        => 20
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    set_font;
    plpdf.printcell(p_txt      => ' �� '
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
                   ,p_txt      => '�������'
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
                            ,p_txt      => '          ���� ��������'
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
                   ,p_txt      => '���'
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
                   ,p_txt      => '          ��������, �������������� ��������'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0);
  
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    /*��������� ���������� ������ ������ ��� ������� �������� (�������������� 28.04.2014 ������ �.�. ���������� no_data_found)*/
    IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
    THEN
      l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#TYPE_DESC>');
      l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'<#DOC_SERNUM>');
      l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                   ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
    
    END IF; /*����� ����������� 28.04.2014*/
  
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
                   ,p_txt      => '��������'
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
                   ,p_txt      => '��� � ����� �����'
                   ,p_align    => 'C'
                   ,p_border   => 'LR'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 1);
  
    plpdf.printcell(p_border   => 'L'
                   ,p_w        => 5
                   ,p_ln       => 0
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    plpdf.printcell(p_h        => -1
                   ,p_txt      => '�����'
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
  
    --������� � ������ ������            
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 35
                   ,p_txt      => ''
                   ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_h   => gv_default_height
                   ,p_w   => 25
                   ,p_txt => '������'
                    --                     ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'L');
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 40
                   ,p_txt      => '�����, �����, ���'
                   ,p_border   => '0'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                   ,p_ln       => 0
                   ,p_align    => 'R');
    plpdf.printcell(p_h        => gv_default_height
                   ,p_w        => 40
                   ,p_txt      => '�������'
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
                   ,p_txt      => '�������� �� ������������ ����������� ��������� ����������� �����?'
                   ,p_w        => 100
                   ,p_border   => 'L'
                   ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    IF par_insuree_info.is_public_contact = 1 /*��������� ����*/
    THEN
      v_yes := 'DF'; --����� ������ ������
      v_no  := 'D'; --��� �������
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
                   ,p_txt      => '��'
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
                   ,p_txt      => '���'
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
       ('������� ������������� �� B2B', '������')
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
  
    pkg_rep_plpdf.gv_datas(1) := '������������';
    pkg_rep_plpdf.gv_datas(2) := '��������������';
    pkg_rep_plpdf.gv_datas(3) := '����������';
    pkg_rep_plpdf.row_print2(par_h => gv_default_height);
  
    pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
  
    pkg_rep_plpdf.gv_borders(1) := 'LR';
    pkg_rep_plpdf.gv_borders(2) := 'LR';
    pkg_rep_plpdf.gv_borders(3) := 'LR';
  
    pkg_rep_plpdf.gv_datas(1) := '"�������� �������" �� ��������� ����������� ����� � �������� �������� �������  �������(�), ����������(�) � ������ ������ � ��������(��).';
    pkg_rep_plpdf.gv_datas(2) := '� ����������� �������������������� ��������(��)';
    pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || '�� ���. ' ||
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
  
    pkg_rep_plpdf.gv_datas(1) := '�������         ����������� �������' || chr(13) || '����';
    pkg_rep_plpdf.gv_datas(2) := '�������         ����������� �������' || chr(13) || '����';
    pkg_rep_plpdf.gv_datas(3) := NULL;
  
    pkg_rep_plpdf.gv_borders(1) := 'LBR';
    pkg_rep_plpdf.gv_borders(2) := 'LBR';
    pkg_rep_plpdf.gv_borders(3) := 'LBR';
    pkg_rep_plpdf.row_print2;
  
  END print_sign_ekb;

  -- ����� "��� CR50_3"
  -- ����������� �., ����, 2014
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
    
      -- � ������������ ���� ��������� ���.������
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. ������������ / ��������������:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => '��� �������: ��������������� '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => '��������� ������� � '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' �� '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => '������'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
                     ,p_txt    => '�������� �� ������������ ����������� ��������� ����������� �����?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 /*��������� ����*/
      THEN
        v_yes := 'DF'; --����� ������ ������
        v_no  := 'D'; --��� �������
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
                     ,p_txt      => '��'
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
                     ,p_txt      => '���'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '���� ������� �������� ����� ����� �������� ���������� ��������, ���������� � ������� 2.'
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� ����� "����� ���������� + ������ ������"';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������ (�����)';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
          v_yes := 'DF'; --����� ������ ������
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => '������������� ������ ��������� ������: '
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
                              ,p_txt      => '* ��������� ����� ��������������� � ������������ � �. 7.2. �������� ������� � ������������ ��� ������ ������� ������� ������������� ��������������� �� ���� ����������� ���������� ������,  �� ���������� ��������, ���������� � ������� 2, � �� ����� ��������� �����, ��������� � �. 6.1. � 6.2. ���������� ��������.'
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
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
                                             '�������������������� �� ��������� ������ "������ ��������������� �� ����� �������", "������������ ��������������� I ��� II ������ (� ������������ ����������� � �������� ������������ ������� �������) �� ����� �������", "������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������"  ���������� �������� �������� ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ')
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := '��  ��������  ���������, �����, ��������� ����������� �����;';
      v_declaration_states(2) := '�� ����������� ���������,  �����������  ��������, �� �������� ������������, ��� �� ������� �� ������������� �������� �� ������������   �����;  ';
      v_declaration_states(3) := '��   �������� ���-��������������  ���  ��  ��������  ������; ';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� ��  ����������  ����� ������  3 (���) ������ ������ � �����; � ��������� ������ �� ��������� ��� ����������� ����� ��� � ��������� ��� �� �������������  �������/��������;  ';
      v_declaration_states(5) := '�� ������  � ������  ������  � ����� � �������� ������������� (��������: ���������, ������  � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ���  ������, ��� �����, ��  �������� � ������� ����������, � �������, � ������������������ ������� (����������� ������, ������� � �������������), ����������, ��������� � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����); ';
      v_declaration_states(6) := '�� ������� ��������� �� ����������� �����, ����������� �� ����������  ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ��� ���� ��������, �������  ����  ��������  ���  �������  ��  ������  �������� (� �����������  ����������  �������������, ����������  ��� ������ �������), � �����  ����������� ��������� �����������, ������� ����  ����������� �� ������� ������������� ���������� ���  ������������ ������� ������� ���� �������� �� ����������� ������ ������� �����.';
      v_declaration_states(7) := '����� ���������� ������ (���������� �������� ������) � ������� ��������� 12 (����������) �������, � ��� ����� �� ����� 6 (�����) ������� �� ��������� ����� ������,';
      v_declaration_states(8) := '������� � �������� ���������� � ������������� �� ��������� ��������� �������� (�� ����������� ��������� �������� � �������������� ������� ����������������), ������������ �� �������������� ���� � ������������������ ��������� �� ������ ������� ����,';
      v_declaration_states(9) := '�������� �������������� �� ���� ���� � ����� ����������� ���������� �����; ';
      v_declaration_states(10) := '�� �������� ���������� (����������) ����������� ������������;';
      v_declaration_states(11) := '�� �������� �������������� ������� ����������������; ';
      v_declaration_states(12) := '�� �������� ������� ������������� ������������ ������������ (������(�), ��������, �������, �����������, ������������, ������ ����, ������ ������, �������, �������, ����); ';
      v_declaration_states(13) := '�� �������� ���������, �������� �������; ';
      v_declaration_states(14) := '�� �������� �������� ���������������� �� ������������ � �����, ';
      v_declaration_states(15) := '�� ��������� � ������� �� ����� �� ��������; ';
      v_declaration_states(16) := '�� ��������� � ��������� ������������ ��������� ���� ����������� ��� � ���������� ����������� ������������ ';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������';
      v_declaration_states2(2) := '��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� "�� "��������� �����", �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 1 500 000 (���� ������� ������� �����) ������;';
      v_declaration_states2(3) := '��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������;';
      v_declaration_states2(4) := '��� � ������(-��), �����(-�) � ��������(-��) � "��������� ��������� �� ��������� ����������� ����� �������� �������".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '���������� ��������� �������, ������������ � ������������ c �� �� "� ������������ ������" �������� ����������� �������� �� ��������� ����� ������������ ������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ����� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������,  �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 5 ��� ����� ��������� ����� �������� ���������� ��������.';
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '��������������';
      pkg_rep_plpdf.gv_datas(3) := '����������';
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"�������� �������" �� ��������� ����������� ����� � �������� �������� �������  �������(�), ����������(�) � ������ ������ � ��������(��).';
      pkg_rep_plpdf.gv_datas(2) := '� ����������� �������������������� ��������(��)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || '�� ���. ' ||
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
    
      pkg_rep_plpdf.gv_datas(1) := '�������         ����������� �������' || chr(13) || '����';
      pkg_rep_plpdf.gv_datas(2) := '�������         ����������� �������' || chr(13) || '����';
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*--����������� � ������� �������
    plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
    plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);
    */
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_503_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                         c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- ����� ����� �� ��������� CR50_5/CR50_6
  -- ����������� �., ����, 2014
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
                     ,p_txt => '������� ����������� ����� � �������� ��������� �������     � ' ||
                               v_pol_sum.pol_num
                      --                     ,p_border   => 'LRT'
                      --                     ,p_align    => 'R'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
      plpdf.printcell(p_h   => gv_default_height
                     ,p_txt => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������, ������������ 20.02.2012'
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
                     ,p_txt   => pkg_rep_utils.date_to_genitive_case(v_pol_sum.start_date) || ' �.'
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
    
      -- � ������������ ���� ��������� ���.������
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. ������������ / ��������������:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => '��� �������: ��������������� '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => '��������� ������� � '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' �� '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => '������'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
                     ,p_txt    => '�������� �� ������������ ����������� ��������� ����������� �����?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 --��������� ����
      THEN
        v_yes := 'DF'; --����� ������ ������
        v_no  := 'D'; --��� �������
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
                     ,p_txt      => '��'
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
                     ,p_txt      => '���'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;*/
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '���� ������� �������� ����� ����� �������� ���������� ��������, ���������� � ������� 2.'
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����';
      pkg_rep_plpdf.gv_datas(3) := '���� ��������';
      pkg_rep_plpdf.gv_datas(4) := '��������� �����';
      pkg_rep_plpdf.gv_datas(5) := '��������� ������';
      pkg_rep_plpdf.gv_datas(6) := '������ �������';
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
      pkg_rep_plpdf.gv_datas(3) := '�';
      pkg_rep_plpdf.gv_datas(4) := '��';
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
                                                 WHEN '������ �� (61-80)' THEN
                                                  '������ ��������������� �� ����� �������'
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
                                               '���������������� �������� �� ��������������') pl
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
          v_yes := 'DF'; --����� ������ ������
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      --      pkg_rep_plpdf.gv_datas(5) := NULL;
      --      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => '������������� ������ ��������� ������: '
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
                              ,p_txt      => '* ��������� ����� ��������������� � ������������ � �. 7.2. �������� ������� � ������������ ��� ������ ������� ������������� ��������������� �� ���������� ��������, ���������� � ������� 2, �� ���� ������ �������� �������� �����������.'
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
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
                                             '�������������������� �� ���������� �������� ����������� ��������  ' ||
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
        v_declaration_states(1) := '�� �������� ��������� I ��� II ������, �����, ��������� ����������� �����;';
        v_declaration_states(2) := '�� ����� ��������� ������-������������ �������, �������������� ��������; ';
        v_declaration_states(3) := '�� �������� �������� ����������, �������� ��������������, ������������ �������������; ';
        v_declaration_states(4) := '�� �����������  ���������, ����������� ��������, �� �������� ������������, ��� �� ������� �� ������������� �������� �� ������������ �����; ';
        v_declaration_states(5) := '�� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
        v_declaration_states(6) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������;';
        v_declaration_states(7) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ��������������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
        v_declaration_states(8) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����;';
        v_declaration_states(9) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����););������� ��������� �� ����������� ���� ����� �(���) ������������������ ������� �� ���� ���������, ��������� ��� ������������� � ���������� ������ ��� ������� ����������� �������';
        v_declaration_states(10) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120';
      ELSE
        v_declaration_states(1) := '��  ��������  ��������� I ������, �����, ��������� ����������� �����; ';
        v_declaration_states(2) := '� ���������  ������ ��������� ��������� ������ �������� ��� �������, �� ��������/�������(�) ���������� �������������: ���������� (II-IV �������), ����������� ��������, ��������, ��������� ��������������� 3-�� ��� ����� ������� �������,  ������ ������, ������� ������� �������� ���������������, ��������������� ����������� �����, �������������� �����������, ������� �, �������� ������; ';
        v_declaration_states(3) := '�� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������); ';
        v_declaration_states(4) := '�� ��� �� � ��������� ��������� ���� ������� ����������� � ������� ����� 10 ���� ������ � ������� ��������� 2 ���; ';
        v_declaration_states(5) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������,  ���  �����,  ��  ��������  � ������� ����������, � �������, � ������������������  �������  (����������� ������, ������� � �������������), ����������, ��������� � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
        v_declaration_states(6) := '������� ��������� �� ����������� ���� ����� �(���) ������������������ ������� �� ���� ���������, ��������� ��� ������������� � ���������� ������ ��� ������� ����������� �������.';
      END IF;
      --      END;
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������';
      v_declaration_states2(2) := '��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� "�� "��������� �����", �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 1 500 000 (���� ������� ������� �����) ������;';
      v_declaration_states2(3) := '��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������;';
      v_declaration_states2(4) := '��� � ������(-��), �����(-�) � ��������(-��) � "��������� ��������� �� ��������� ����������� ����� �������� �������".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '���������� ��������� �������, ������������ � ������������ c �� �� "� ������������ ������" �152-�� �� 27.07.2006 �������� ����������� �������� �� ��������� ����� ������������ ������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ����� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������,  �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 5 ��� ����� ��������� ����� �������� ���������� ��������.';
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '��������������';
      pkg_rep_plpdf.gv_datas(3) := '����������';
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"�������� �������" �� ��������� ����������� ����� � �������� �������� �������  �������(�), ����������(�) � ������ ������ � ��������(��).';
      pkg_rep_plpdf.gv_datas(2) := '� ����������� �������������������� ��������(��)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || '�� ���. ' ||
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
    
      pkg_rep_plpdf.gv_datas(1) := '�������         ����������� �������' || chr(13) || '����';
      pkg_rep_plpdf.gv_datas(2) := '�������         ����������� �������' || chr(13) || '����';
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*    --����������� � ������� �������
        plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
        plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);
    */
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    -- print_header_custom;
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_5056_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                          c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- ����� "��� CR50_7/CR50_8/CR50_9"
  -- ����������� �., ����, 2014
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
    
      -- � ������������ ���� ��������� ���.������
      plpdf.setcurrentxy(v_x_start + plpdf.gettextwidth(p_s => '2. ������������ / ��������������:') + 1
                        ,v_y_start);
      set_font;
      plpdf.printcell(p_txt      => '��� �������: ��������������� '
                     ,p_w        => 50
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_txt      => '��������� ������� � '
                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' �� '
                     ,p_w        => 6
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => to_char(v_pol_sum.start_date, 'dd.mm.yyyy')
                     ,p_w        => 20
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.setcurrentxy(v_x_end, v_y_end);
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => '������'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
                     ,p_txt    => '�������� �� ������������ ����������� ��������� ����������� �����?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 --��������� ����
      THEN
        v_yes := 'DF'; --����� ������ ������
        v_no  := 'D'; --��� �������
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
                     ,p_txt      => '��'
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
                     ,p_txt      => '���'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END;*/
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '���� ������� �������� ����� ����� �������� ���������� ��������, ���������� � ������� 2.'
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� ����� "����� ���������� + ������ ������"';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������ (�����)';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
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
          v_yes := 'DF'; --����� ������ ������
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      --      pkg_rep_plpdf.gv_datas(5) := NULL;
      --      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 80
                     ,p_txt      => '������������� ������ ��������� ������: '
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
                              ,p_txt      => '* ��������� ����� ��������������� � ������������ � �. 7.2. �������� ������� � ������������ ��� ������ ������� ������� ������������� ��������������� �� ���� ����������� ���������� ������,  �� ���������� ��������, ���������� � ������� 2, � �� ����� ��������� �����, ��������� � �. 6.1. � 6.2. ���������� ��������.'
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
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
                                             '�������������������� �� ��������� ������ "������ ��������������� �� ����� �������", "������������ ��������������� I ��� II ������ (� ������������ ����������� � �������� ������������ ������� �������) �� ����� �������", "������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������"  ���������� �������� �������� ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ')
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := '�� �������� ��������� I ��� II ������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� �����������  ���������, ����������� ��������, �� �������� ������������, ��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.;';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������;';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ��������������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����; �������� ����������� ������������������ �������, �� �� �������� ����������� ������������� ������������ ���������� ���, ���, ��� (����, ����, ����, ����, ���� � �.�. ), ����. � ���� ����� � �����������, �� �������� ��������������, ���������� ������� ������ �� ������� ��� ���������; ';
      v_declaration_states(6) := '�� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� ������� ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������';
      v_declaration_states2(2) := '��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� "�� "��������� �����", �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 1 500 000 (���� ������� ������� �����) ������;';
      v_declaration_states2(3) := '��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������;';
      v_declaration_states2(4) := '��� � ������(-��), �����(-�) � ��������(-��) � "��������� ��������� �� ��������� ����������� ����� �������� �������".';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '���������� ��������� �������, ������������ � ������������ c �� �� �� ������������ ������� �152-�� �� 27.07.2006 �������� ����������� �������� �� ��������� ����� ������������ ������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������, �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� ��������.';
      v_add_cond_states(4) := '�������� �. 4.1 � 4.1.1 �������� ������� � ����� ��������:' || chr(13) ||
                              '�4.1. �� ����������� �� �����������:' || chr(13) || '4.1.1. ����:' ||
                              chr(13) ||
                              '-  �� ����� ������� �ϻ � ������������� ��������������� 1 ������ �� ����� ������� - ������ 18 (������������) ��� �� ������ ������ �������� �������� ����������� � ������ 55 (��������� ����) ��� ��� ������ � 60 (����������) ��� ��� ������ �� ������ ��������� �������� �������� ������������';
      v_add_cond_states(5) := '������ ��������� � ����� 4.4.�������� ������� � �������� �.�. 4.4.8. � 4.4.9 � ����� ��������:' ||
                              chr(13) ||
                              '4.4.8.�� ����� ����������������� ������� ��������������� � ����������� ���������, �����������, ����� ��� ������� ���������; �� ����������� ���������� �� ��������� ������������ ��� ������� ������' ||
                              chr(13) ||
                              '4.4.9. �� ����� ����� ��������� ���������, ����������� ��������������, �������� ������ � �������� ��������� ����������� ��������� (������� ���������� ��������� ���������), ������������ ������������, ���������� ��������������� ���������, � ��� �� �������� ������ � �������� ����� ������� �������� ���������� �����.';
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '��������������';
      pkg_rep_plpdf.gv_datas(3) := '����������';
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(3) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
      pkg_rep_plpdf.gv_borders(3) := 'LR';
    
      pkg_rep_plpdf.gv_datas(1) := '"�������� �������" �� ��������� ����������� ����� � �������� �������� �������  �������(�), ����������(�) � ������ ������ � ��������(��).';
      pkg_rep_plpdf.gv_datas(2) := '� ����������� �������������������� ��������(��)';
      pkg_rep_plpdf.gv_datas(3) := v_signer.job_position || chr(13) || '�� ���. ' ||
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
    
      pkg_rep_plpdf.gv_datas(1) := '�������         ����������� �������' || chr(13) || '����';
      pkg_rep_plpdf.gv_datas(2) := '�������         ����������� �������' || chr(13) || '����';
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 6);
    /*    --����������� � ������� �������
    plpdf.nopalias(p_alias => '{nb}', p_cp_alias => '{cp}', p_format => '{cp}/{nb}');
    plpdf.setfooterprocname(p_proc_name => 'ins.pkg_rep_credit_policy.print_footer', p_height => 5);*/
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    --    print_header(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
    print_header_ekb(par_policy_id => v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    --    print_insuree_custom;
    print_insuree_ekb(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum, par_box_size => 1.5, par_box_delta_y => 0.5);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------    
    print_additional_cond_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    /*    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' ||c_proc_name)
    ,par_policy_summary  => v_pol_sum);*/
    print_sign_ekb(par_report_exe_name => /*'EKB_50789_POLICY.rdf'*/ lower(gc_pkg_name || '.' ||
                                                                           c_proc_name)
                  ,par_policy_summary  => v_pol_sum
                  ,par_insuree_info    => v_insuree_info);
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
    gv_default_height := 4;
  END;

  -- ����� �������� ���
  -- 339295 - ������ �� ��������� �������� ���
  -- �����������, �������, 2014
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
          v_yes := 'DF'; --����� ������ ������
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '*����� ������� - ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� �������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������: '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��� � ���: ������ ��������� ������� ������������ ��� � ��� �� ������� ���� ���������� ��������, ����� - �� ������� ����, ��������� �� ��� �� ����, ������� ����.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* ��������� ����� ��������������� � ������������ � �. 7.2. �������� �������'
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_txt      => ''
                     ,p_align    => 'R'
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      /* 405988 ��������� �. ������ ���������� ����������� ������ */
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
    
      pkg_rep_plpdf.gv_datas(1) := '��������� ������� � ';
      pkg_rep_plpdf.gv_datas(2) := v_pol_sum.credit_account_number;
      pkg_rep_plpdf.gv_datas(3) := ' �� ' || to_char(v_pol_sum.start_date, 'dd.mm.yyyy');
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
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
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
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
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
                     ,p_txt      => '��������'
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
                     ,p_txt      => '��� � ����� ����� �������'
                     ,p_align    => 'C'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '�����'
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
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 25
                     ,p_txt      => '������'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
                     ,p_txt    => '�������� �� ������������ ����������� ��������� ����������� �����?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_public_contact = 1 /*��������� ����*/
      THEN
        v_yes := 'DF'; --����� ������ ������
        v_no  := 'D'; --��� �������
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
                     ,p_txt      => '��'
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
                     ,p_txt      => '���'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_border => 'R', p_ln => 1);
      plpdf.printcell(p_h      => -1
                     ,p_txt    => '�������� �� ������������ ���������� ��������� ����������� �����?'
                     ,p_w      => 100
                     ,p_border => 'L');
    
      IF v_insuree_info.is_rpdl = 1 /*��������� ����*/
      THEN
        v_yes := 'DF'; --����� ������ ������
        v_no  := 'D'; --��� �������
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
                     ,p_txt      => '��'
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
                     ,p_txt      => '���'
                     ,p_w        => 15
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_border => 'R', p_ln => 1);
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� �����������  ���������, ����������� ��������, �� �������� ������������, ��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.;';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������;';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ��������������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����;';
      v_declaration_states(6) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� ������� ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;8.8. �� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ����� �������� ��; ���� 160 ��, ��� 85 ��, ������� - 75 - ����� - ���).';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������';
      v_declaration_states2(2) := '��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 3 000 000 (��� ��������) ������;';
      v_declaration_states2(3) := '��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������; ';
      v_declaration_states2(4) := '��� � ������(-��), �����(-�) � ��������(-��) � ��������� ��������� �� ��������� ����������� ����� � �������� �������� �������.';
    
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
                     ,p_txt    => gv_chapter_num || '. �������������� �������:'
                     ,p_border => 'LTR'
                     ,p_ln     => 1);
    
      set_font;
    
      v_additional_condition_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_additional_condition_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_additional_condition_states(3) := '���������� ��������� �������, ������������ � ������������ c �� �� �� ������������ ������� �152-�� �� 27.07.2006 �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� �001140 �� 29 ��� 2006 �. (��� 7743040060, ���� 1027739036445, �������� ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������, �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� ��������. ��������� �������� �� ��������� ������������ ������ ����� ���� �������� ����������� ����������� ����������� ����������� � ����� �����������.';
    
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
                              ,p_txt      => '�  �������������  ����� �������� ����������, ����� ���� ���������� ����� ��������������-�������� �����, ������������� �� ������� ��� ��� ���������� ������, ����� ���������� � ���� ��������,  ���������� ��� �������, ��������� � �.�., ����������� �������� � �.�., ������� ������ ������-���������� ����������, ���� �������-����������� ���������� � �.�.'
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_txt      => gv_chapter_num ||
                                             '.1. ������ �������������������� �� ��������� ������ "������ ��������������� �� ����� �������" � "������������ ��������������� I ���  2  ������  "  ����������  ��������,   �  ����,  ������  �����  �������������  ���������������  ��  ����������  ��������  ��  ������ �����������  ����������  ������,  ����������  �  �������  2  ����������  ��������,  �������� ��� ����������������� (���).'
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => gv_chapter_num ||
                                             '.2.���������������������   ��  ����������  �����   "������  ���������������  ��  �����  �������"  �  ����,  ����������  �����  ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, �������� ��������� ����:'
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
    
      pkg_rep_plpdf.gv_datas(1) := '�.�.�.';
      pkg_rep_plpdf.gv_datas(2) := '���� ��������';
      pkg_rep_plpdf.gv_datas(3) := '����������� ���������';
      pkg_rep_plpdf.gv_datas(4) := '����(%)';
    
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
                              ,p_txt      => '** ���� � ��������� ������� ������� � ���������� ��������� � ����� ����, ������������� ��������� �������������������� ����� ��������� ������� ������� �������������������, ���������� � �. 7.1. ���������� ��������.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => gv_chapter_num ||
                                             '.3 �������������������� �� ���������� ����� "������������ ��������������� I � 2 ������ " � ����, ���������� ����� ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, �������� ��������������.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LBR'
                              ,p_ln       => 1);
    
    END print_beneficiaries_custom;
  
  BEGIN
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header(v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------
    print_additional_conditions;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
              ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_tkb;

  /** 
  * ����� ����� ��� ���
  * @task 404551
  * @author ����� �.
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 10);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    pkg_rep_plpdf.set_font(par_style => 'B', par_font_family => 'Times');
    plpdf.printcell(p_txt => v_rigvis_info.short_name, p_ln => 1);
  
    v_address_str := '�����: 125239, �. ������, ������������� �����, 46/1, ���.: 797-32-75';
  
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
    pkg_rep_plpdf.gv_datas(1) := '��� 7743040060';
    pkg_rep_plpdf.gv_datas(2) := '��� 774301001';
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
  
    pkg_rep_plpdf.gv_datas(1) := '����������';
    pkg_rep_plpdf.gv_datas(2) := NULL;
    pkg_rep_plpdf.gv_datas(3) := NULL;
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_datas(1) := v_rigvis_info.short_name;
    pkg_rep_plpdf.gv_datas(2) := '�� �';
    pkg_rep_plpdf.gv_datas(3) := '40702810700000002581';
  
    pkg_rep_plpdf.gv_borders(1) := '1';
    pkg_rep_plpdf.gv_borders(2) := 'LBR';
    pkg_rep_plpdf.gv_borders(3) := 'LBR';
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_borders(1) := 'LTR';
    pkg_rep_plpdf.gv_borders(2) := '1';
    pkg_rep_plpdf.gv_borders(3) := '1';
  
    pkg_rep_plpdf.gv_datas(1) := '���� ����������';
    pkg_rep_plpdf.gv_datas(2) := '���';
    pkg_rep_plpdf.gv_datas(3) := '044525388';
    pkg_rep_plpdf.row_print2;
  
    pkg_rep_plpdf.gv_borders(1) := 'LBR';
    pkg_rep_plpdf.gv_borders(2) := '1';
    pkg_rep_plpdf.gv_borders(3) := '1';
  
    pkg_rep_plpdf.gv_datas(1) := '����� (���) �. ������';
    pkg_rep_plpdf.gv_datas(2) := '�� �';
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
                   ,p_txt   => '���� � ___ �� ' || to_char(trunc(SYSDATE), 'dd.mm.yyyy')
									 ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
  
    pkg_rep_plpdf.set_font;
    plpdf.printcell(p_ln => 1);
		
    pkg_rep_plpdf.delete_row_print_cache;
		
    pkg_rep_plpdf.gv_widths(1) := 35;
    pkg_rep_plpdf.gv_widths(2) := plpdf.getPageSpace - 35;
		
    pkg_rep_plpdf.gv_datas(1) := '����������:';
    pkg_rep_plpdf.gv_datas(2) := v_insuree_info.fio;	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := '�����:';
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.get_address(pkg_contact_rep_utils.get_last_active_address_id(v_insuree_info.contact_id
                                                                                                                       ,'CONST'));	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := '�������:';
    pkg_rep_plpdf.gv_datas(2) := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_last_active_doc_id(v_insuree_info.contact_id
                                                                                                                       ,'PASS_RF'),'<#DOC_SER> � <DOC_NUM>');	
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := '�����:';
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
		
		pkg_rep_plpdf.gv_datas(1) := '�';
		pkg_rep_plpdf.gv_datas(2) := '������������ ������';
		pkg_rep_plpdf.gv_datas(3) := '������� ���������';
		pkg_rep_plpdf.gv_datas(4) := '����������';
		pkg_rep_plpdf.gv_datas(5) := '����';
		pkg_rep_plpdf.gv_datas(6) := '�����';
    pkg_rep_plpdf.row_print2;
		
		pkg_rep_plpdf.gv_aligns(2) := 'L';
    pkg_rep_plpdf.gv_datas(1) := '1';
    pkg_rep_plpdf.gv_datas(2) := '��������� ������ �� �������� �����������  ��� ��� ���������� ������ � '||v_pol_sum.pol_num||' ���������� �������� �� '||to_char(v_pol_sum.start_date,'dd.mm.yyyy');
    pkg_rep_plpdf.gv_datas(3) := '��.';
    pkg_rep_plpdf.gv_datas(4) := '1';
    pkg_rep_plpdf.gv_datas(5) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
    pkg_rep_plpdf.gv_datas(6) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
    pkg_rep_plpdf.row_print2;
		
		pkg_rep_plpdf.delete_row_print_cache;
		
		-- ����� ���������� ����� �������� ����� ����������
    pkg_rep_plpdf.gv_widths(1) := 10+50+25+25+40;					
		pkg_rep_plpdf.gv_widths(2) := 40;
		
		pkg_rep_plpdf.gv_borders(1) := null;
		pkg_rep_plpdf.gv_borders(2) := '1';
		
		pkg_rep_plpdf.gv_aligns(1) := 'R';
		pkg_rep_plpdf.gv_aligns(2) := 'C';
		
		pkg_rep_plpdf.gv_styles(1) := 'B';
		pkg_rep_plpdf.gv_styles(2) := null;
		
    pkg_rep_plpdf.gv_datas(1) := '�����:';
    pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := '��� ������ (���).';
    pkg_rep_plpdf.gv_datas(2) := '----';
		pkg_rep_plpdf.row_print2;
		
    pkg_rep_plpdf.gv_datas(1) := '����� � ������:';
    pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_pol_sum.premium);
		pkg_rep_plpdf.row_print2;		
		
		plpdf.PrintCell(p_txt => '����� ������������ 1 (����) �� �����:',p_ln => 1);
		plpdf.PrintCell(p_txt => pkg_utils.money2speech(quant => v_pol_sum.premium,p_fund_id => v_pol_sum.fund_id),p_ln => 1);
		
		plpdf.PrintCell(p_ln => 1);
		plpdf.PrintMultiLineCell(p_txt => '������ ������������ � ���������� ������ �� ����� ��������������� ������, �������������� �� �� �� ���� ���������� ��������.',p_ln => 1);
		
		plpdf.PrintCell(p_ln => 1);		
		plpdf.PrintCell(p_ln => 1,p_txt => '������������ �����������_____________________ (�������� �.�.)');	
		plpdf.PrintCell(p_ln => 1,p_txt => '������� ��������� ____________________________ (������� �.�.)');	
		
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'payment_pol_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END;

  --��� CR122
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
                     ,p_txt      => '������� ����������� ����� � �������� �������� ������� � ' ||
                                    par_policy_summary.pol_num
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������'
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
                                    ' �.'
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
                                    '. ��������� �����, ��������� �����, ��������� ������ (������):'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
          v_yes := 'DF'; --����� ������ ������
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������ (�����):';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => 'C�������� ����� �� ������ ������� �ϻ � ��������������, ����������� � �������� �����������, ����� ������� �������������� ����� ������� �� ���������� �������� �� ������ ��� ����������, ����������� �� 10%. � ������� �������� �������� ����������� ��������� ����� ����������� �� ���� ��������� ������������� ��������������� �� ���������� ��������  � ����� ������� ������� ������� (�����������) ������������� ��������������� �� ���������� ��������, ����������� �� 10%,  �� ���� ����������� ���������� ������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� �����  �� ������ ������� �ϻ � �������������� � ������ ������� ���������� ��������� ������� ����� ������� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� ��������, ����������� �� 10 (������) ���������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� ����� �� ����� ���������� ������ ���������������� ���������������, ����������� � ���������� ����� ������� � ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������, ����������� �� 10%.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������:  ������������� '
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
      plpdf.printcell(p_txt   => '��� �������: ��������������� '
                     ,p_align => 'R'
                      -- ,p_w        => 50
                     ,p_border   => 'R'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
    
      plpdf.printcell(p_txt    => '��������� ������� � '
                     ,p_border => 'RL'
                      --                     ,p_w        => 30
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_txt      => v_pol_sum.credit_account_number
                     ,p_w        => 20
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printcell(p_txt      => ' �� '
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
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
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
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
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
                     ,p_txt      => '��������'
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
      pkg_rep_plpdf.gv_datas(2) := '��� � ����� ����� �������';
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
      pkg_rep_plpdf.gv_datas(2) := '�����';
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
      pkg_rep_plpdf.gv_datas(3) := '������';
      pkg_rep_plpdf.gv_datas(4) := '�����, �����, ���, ��������';
      pkg_rep_plpdf.gv_datas(5) := '�������';
      pkg_rep_plpdf.gv_datas(6) := '�-mail';
      pkg_rep_plpdf.gv_datas(7) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
    
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� �����������  ���������, ����������� ��������, �� �������� ������������, ��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.;';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������;';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ���������(-���) �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ��������������) �/��� �� ���(-�) ��������� �� ������������ ������� (� ��� ����� ���� ������� ������� � �������������, ��������� ��������� ������������), ��� �� ��������� 12 ������� �� ���������(-���) �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� (�� �������� ���������� ����� �������� � ����� � ������ ������������� ���������, ������� ����� ����� � ����, �����, �� ��������� ������������ ��������������) ����� ������ ����, �� �������� ������������� ������������ � ������������ (�.�. �� ������� ��� (����������) ������������ ����� ������ ����);';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ����/��� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� �� ����������� ��������� � ����������� �/��� ����������� ������������� ��������, � ������� ���������� ������ � ������� ���������� ��������� ����������;';
      v_declaration_states(6) := '�� ������(-�) � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� �������(-�) ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;8.8. �� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ����� �������� ��; ���� 160 ��, ��� 85 ��, ������� - 75 - ����� - ���).';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, (���������� ����� ���������!); ���� 160 ��, ��� 85 ��, ������� - 75, (���������� ��������� ������!).';
      v_declaration_states(9) := '�� ������� ����������/����������� ��������� ����������� �����.';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������;';
      v_declaration_states2(2) := '��� � ������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ������������, ������� � �.�.), ������������� �� ���������� ��������� �������� ��� ��� ���������� ������ ����� ����������� ���������� (���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � ������� ������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������;';
      v_declaration_states2(3) := '��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� �����������  � ��� ��� ���������� ������ � ����� ��������� ����� �� ����� ��������� �����������, ����������� � ��������� �������������� �� ������ ������� �ϻ, ��������������, ���� �ϻ �� ��������� 10 000 000 (������ ���������) ������;';
      v_declaration_states2(4) := '��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������;';
      v_declaration_states2(5) := '��� � ������(-��), �����(-�) � ��������(-��) � ��������� ��������� �� ��������� ����������� ����� � �������� �������� �������.';
    
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
                     ,p_txt    => gv_chapter_num || '. �������������� �������:'
                     ,p_border => 'LTR'
                     ,p_ln     => 1);
    
      set_font;
    
      v_additional_condition_states(1) := '9.1 ��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_additional_condition_states(2) := '9.2 ������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_additional_condition_states(3) := '9.3 ���������� ��������� �������, ������������ � ������������ c �� �� �� ������������ ������� �152-�� �� 27.07.2006 �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� �������� � ������������ ���������������� 
�������������������� ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������, �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� ��������. ��������� �������� �� ��������� ������������ ������ ����� ���� �������� ����������� ����������� ����������� ����������� � ����� �����������.';
      v_additional_condition_states(4) := '9.4 ���������� ��������� ������� �����������, ��� ��  �, �� ���  ������������ �� �������� ��������� ������ ������ ���������� ����� ������, ��������� � ���������������, ��������������, ����������������, �������� ������ �� ��� ������ �����; ��������� � ����� ������, ��������������� � ���� ������������, ��������� �� �� ��������� ����������� �������; ��������� � ��������� ������������� ������������.';
    
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '�������������������� �� ��������� ������ ������� �ϻ, �������������� ����������  �������� �������� ' ||
                                             pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                            ,par_separator => ', ') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
    
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '�������������������� �� ����� ���������� ������ ���������������� ���������������, ����������� � ���������� ����� �������� �������� ��������������.'
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '����������';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '���������� ��������� ������� �����������, ����������� ������������� ����������� � ������������� ����������.
 �������� ������� �� ��������� ����������� ����� � �������� �������� ������� �������(�), ����������(�) � ������ ������ � ��������(��).';
      pkg_rep_plpdf.gv_datas(2) := '����-���������  �� ������������ �������� � �������������� ����������� ' ||
                                   v_signer.short_name || ' ������������ �� ��������� ������������ �' ||
                                   v_signer.procuratory_num;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '�������                                                                    ����������� �������' ||
                                   chr(13) || '����';
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header_custom(v_policy_id, par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_conditions;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
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
                                    '. ��������� �����, ��������� �����, ��������� ������:'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����/��������� �����������';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������:  ������������� '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* ��������� ����� �� ������ ������� �ϻ � �������������� ����� ������� �������������� ����� ������� �� ���������� �������� �� ������ ��� ����������, ����������� �� 10% (������ ���������). � ������� �������� �������� ����������� ��������� ����� ����������� � ������������ � �������������� �������� �������� � ����� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� ��������, ����������� �� 10% (������ ���������). ��������� ����� �� ����� ���� �ѻ ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������, ����������� �� 10% (������ ���������). ��������� ����� �� ��������� ����������� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� �������� ������������ � ������������ � ����������� � 1 � �������� ��������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** ����� ������� - ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� �������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���. '
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => -1
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
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
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
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
                     ,p_txt      => '��������'
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
      pkg_rep_plpdf.gv_datas(2) := '��� � ����� ����� �������';
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
      pkg_rep_plpdf.gv_datas(2) := '�����';
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
      pkg_rep_plpdf.gv_datas(3) := '������';
      pkg_rep_plpdf.gv_datas(4) := '�����, �����, ���, ��������';
      pkg_rep_plpdf.gv_datas(5) := '�������';
      pkg_rep_plpdf.gv_datas(6) := '�-mail';
      pkg_rep_plpdf.gv_datas(7) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      pkg_rep_plpdf.delete_row_print_cache;
    
    END print_insuree_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
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
      v_text := gv_chapter_num || '. ������ ��������:';
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
                     ,p_txt      => '����� ����������: '
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
    
      v_declaration_states(1) := '8.1. �� �������� ���������, �����, ��������� ����������� ����� (������) ������ ���; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������; �� �������� �������� ��������������, ������������ �������������; �� �����������  ���������, ����������� ��������, �� �������� ������������, �/��� �� ������ �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.;';
      v_declaration_states(2) := '8.2. �� ��������/�������(�) ���������� �������������: ������������ ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, ������, ���������, ��������-���������� ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, ����������� ���������� ������, ����������� ���������������, ����������� ��������� �����, ����������� ������-�������� �������, ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������, � ����� ����� ������ ������� ��� ����� ����������� ��� �������� �����������, �� ������������� ����;';
      v_declaration_states(3) := '8.3. �� ���������  � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(4) := '8.4. �� ��������� 2 (���) ���� �� ���������(-���) �� ���������� ����� ������ 3 (���) ������ ������ � ����� (����������� �� ������� ����, �� �������� ���������� ����� �������� � ����� � ������ ������������� ���������, ������� ����� ����� � ����, �����, �� ��������� ������������ �������������� �/��� �� ���(-�) ��������� �� ������������ ������� (� ��� ����� ���� ������� ������� � �������������, ��������� ��������� ������������), ��� �� ��������� 12 ������� �� ���������(-���) �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� (�� �������� ���������� ����� �������� � ����� � ������ ������������� ���������, ������� ����� ����� � ����, �����, �� ��������� ������������ �������������� ����� ������ ����, �� �������� ������������� ������������ � ������������ (�.�. �� ������� ��� (����������) ������������ ����� ������ ����);';
      v_declaration_states(5) := '8.5. � ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������/���������� �������� ��� � ��������� ���� �� ������������� �������/�������� � � �� ��������� ���������� � ����� � ��������� ����� �� ����������� ��������� � ����������� �/��� ����������� ������������� �������� (�� ����������� ���������� ���������������� ��������, ��������������� ��� ����������� ���������������� ����������� ��������) � ������� ���������� ��������� ����������;';
      v_declaration_states(6) := '8.6. �� ������(�) � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� � �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '8.7. �� �������(�) ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���  ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����; ';
      v_declaration_states(8) := '8.8. �� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ����������  95(���������� ����� ���������!) ���� 160 ��, ��� 85 ��, �������  75 (���������� ������ ���������!)';
      v_declaration_states(9) := '8.9. �� �������� ����������/����������� ��������� ����������� �����;';
      v_declaration_states(10) := '8.10. ����� ���������� ������ (���������� �������� ������) � ������� ��������� 12 (����������) �������, � ��� ����� �� ����� 6 (�����) ������� �� ��������� ����� ������; ������� � �������� ���������� � ������������� �� ��������� ��������� �������� (�� ����������� ��������� �������� � �������������� ������� ����������������), ������������ �� �������������� ���� � ������������������ ��������� �� ������ ������� ����. �������� �������������� �� ���� ���� � ����� ����������� ���������� �����;  �� �������� ���������� (����������) ����������� ������������; �� �������� �������������� ������� ����������������; �� �������� ������� ������������� ������������ ������������ (������(�), ��������, �������, �����������, ������������, ������ ����, ������ ������, �������, �������, �����); �� �������� ���������, �������� �������, �������� � �������, ������� ������������� �������� �������� � ������; �� �������� �������� ���������������� �� ������������ � �����, �� ��������� � ������� �� ����� �� ��������; �� ��������� � ��������� ������������ ��������� ���� ����������� ��� � ���������� ����������� ������������;';
      v_declaration_states(11) := '9. �������������� �������:';
      v_declaration_states(12) := '9.1. ��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_declaration_states(13) := '9.2. ������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
    
      v_declaration_states2(1) := '��, � ���� ��������� ��������� ���������� � �������: ��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������; ��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 5 000 000 (���� ���������) ������ ��� �������������� � �������� �� 18 (������������) ��� �� ���� ������ ����� ����������� � �� 60 (�����������) ��� �� ���� ��������� ����� ����������� ��� ��������� 2 500 000 (��� �������� ������� �����) ������ ��� �������������� � �������� �� 61 (����������� ������) ���� �� ���� ������ ����� ����������� � �� 65 (����������� ����) ��� �� ���� ��������� ����� ����������� ��� ��������� 1 500 000 (���� ������� ������� �����) ������ ��� �������������� � �������� �� 66 (����������� �����) ��� �� ���� ������ ����� ����������� � �� 70 (����������) ��� �� ���� ��������� ����� �����������; ��� � ������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ������������, ������� � �.�.), ������������� �� ���������� ���������  �������� ��� ��� ���������� ������ ����� ����������� ���������� (���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � ������� ������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������; ��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������; ��� � ������(-��), �����(-�) � ��������(-��) � ���������� ���������  ����������� ����� � �������� ��������� �������.';
      v_declaration_states2(2) := '���������� ��������� �������, ������������ � ������������ c �� �� �� ������������ ������� �152-�� �� 27.07.2006 �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� � ��� �������, ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������, �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. �����������, ��� ��  �, �� ���  ������������ �� �������� ��������� ������ ������ ���������� ����� ������, ��������� � ���������������, ��������������, ����������������, �������� ������ �� ��� ������ �����; ��������� � ����� ������, ��������������� � ���� ������������, ��������� �� �� ��������� ����������� �������; ��������� � ��������� ������������� ������������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� ��������. ��������� �������� �� ��������� ������������ ������ ����� ���� �������� ����������� ����������� ����������� ����������� � ����� �����������.';
    
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      IF v_product_brief IN ('CR103_15_Toyota', 'CR103_16_Toyota')
      THEN
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.1. ��������������������� �� ���������� ����� ������� �ϻ ���������� ��������,��������  ���������� ���������������.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.2. ��������������������  �� ���������� �����  �������������� �������� ��������������;'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.4. �������������������� �� ����� ����������  ������ ���������������� ��������������� � ���������� ����������� �������  � �� ����� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������  �������� ��������������.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
      ELSE
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.1. ������ �������������������� �� ��������� ������ ������� �ϻ � �������������� ���������� ��������,  � ����, ������ ������� ����������� ������������� ��������������� �� �������, �� �� ����� ����� ��������� ������� ��������: ' ||
                                               nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                  ,par_separator => ', ')
                                                  ,'____________________________') || '.'
                                ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                                ,p_border   => 'LR'
                                ,p_ln       => 1);
        plpdf.printmultilinecell(p_h        => 4
                                ,p_txt      => '7.2. ���������������������  �� ���������� �����  ������� �ϻ � ����, ���������� ����� ���������� ������������ ��  ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, ��������: ���������� ���������������; 7.3. �������������������� �� ���������� ����� �������������� � ����, ���������� ����� ���������� ������������ �� ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, ��������  �������������� ����; 7.4. �������������������� �� ����� ����������  ������ ���������������� ��������������� � ���������� ����������� �������  � �� ����� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������  �������� ��������������. '
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '����������';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '���������� ��������� ������� �����������, ����������� ������������� ����������� � ������������� ����������.
 �������� ������� �� ��������� ����������� ����� � �������� �������� ������� �������(�), ����������(�) � ������ ������ � ��������(��).
 � ����������� �������������������� �������� (��)';
      pkg_rep_plpdf.gv_datas(2) := '����-���������  �� ������������ �������� � �������������� ����������� ' ||
                                   v_signer.short_name || ' ������������ �� ��������� ������������ �' ||
                                   v_signer.procuratory_num;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '�������                                                                    ����������� �������' ||
                                   chr(13) || '����';
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LBR';
      pkg_rep_plpdf.gv_borders(2) := 'LBR';
    
      pkg_rep_plpdf.row_print2;
    
    END print_sign_custom;
  
    PROCEDURE print_programma_description IS
    BEGIN
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '��������� �����������: ' || v_pol_sum.product_name
                     ,p_border   => 'LRT'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
    END;
  
  BEGIN
    gv_chapter_num := 0;
    v_policy_id    := to_number(repcore.get_context('POL_ID'));
  
    v_pol_sum      := pkg_rep_plpdf.get_policy_summary(v_policy_id);
    v_insuree_info := pkg_rep_plpdf.get_contact_summary(v_pol_sum.insuree_contact_id);
  
    -- �������������
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
                 AND upper(c.obj_name_orig) LIKE '%���������%');
    END IF;
  
    IF v_cnt_benef > 0
    THEN
      v_product_brief := 'CR103_15_Toyota';
    ELSE
      v_product_brief := v_pol_sum.product_brief;
    END IF;
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => '������� ����������� �� ��������� ����������� ����� � �������� ���������  ������� �            '
                ,par_policyform_note => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� ������� (���������� �1 � ���������� �������� �����������)');
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency_custom(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ��������� �����������
    -------------------------------------------------------------------------------------------------
    print_programma_description;
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    --    plpdf.newpage;
    print_declaration_custom;
    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_rolf_2015;

  -- ����� CR123%
  -- 397365: ����� ��������� ���������
  -- ����������� �., ����, 2014
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
                                    '. ��������� �����, ��������� �����, ��������� ������:'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����/��������� �����������';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������:  ������������� '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* ��������� ����� �� ������ ������� �ϻ � �������������� ����� ������� �������������� ����� ������� �� ���������� �������� �� ������ ��� ����������. � ������� �������� �������� ����������� ��������� ����� ����������� � ������������ � �������������� �������� �������� � ����� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� ��������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** ����� ������� - ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� �������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
                              ,p_border   => '1'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_period_custom;
  
    PROCEDURE print_declaration_custom IS
      v_declaration_states  t_states;
      v_declaration_states2 t_states;
    BEGIN
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� ����������� ���������, ����������� ��������, �� �������� ������������, �/��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.; ';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������;';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������;';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ������������ �������������� � �� ��������� � ������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����  �� ����������� ��������� � ����������� �/��� ����������� ������������� ��������, � ������� ���������� ������ � ������� ���������� ��������� ����������;';
      v_declaration_states(6) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� ������� ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ���������� ����� ���������; ���� 160 ��, ��� 85 ��, ������� - 75 - ����������� ��������� ������).';
      v_declaration_states(9) := '����� ���������� ������ (���������� �������� ������) � ������� ��������� 12 (����������) �������, � ��� ����� �� ����� 4 (�������) ������� �� ��������� ����� ������; ������� � �������� ���������� � ������������� �� ��������� ��������� �������� (�� ����������� ��������� �������� � �������������� ������� ����������������), ������������ �� �������������� ���� � ������������������ ��������� �� ������ ������� ����. �������� �������������� �� ���� ���� � ����� ����������� ���������� �����;  �� �������� ���������� (����������) ����������� ������������; �� �������� �������������� ������� ����������������; �� �������� ������� ������������� ������������ ������������ (������(�), ��������, �������, �����������, ������������, ������ ����, ������ ������, �������, �������, �����); �� �������� ���������, �������� �������, �������� � �������, ������� ������������� �������� �������� � ������; �� �������� �������� ���������������� �� ������������ � �����, �� ��������� � ������� �� ����� �� ��������; �� ��������� � ��������� ������������ ��������� ���� ����������� ��� � ���������� ����������� ������������; �� �������� ����������� ��������� ����������� �����, �� �������� ���������� ��������� ����������� ����� ��� ��� �������������.';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������; ��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 3 500 000 (��� �������� ������� �����)  ������;��� � ������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ������������, ������� � �.�.), ������������� �� ���������� ���������  �������� ��� ��� ���������� ������ ����� ����������� ���������� (���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � ������� ������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������; ��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������; ��� � ������(-��), �����(-�) � ��������(-��) � ���������� ���������  ����������� ����� � �������� ��������� �������.';
      v_declaration_states2(2) := '���������� ��������� �������, ������������ � ������������ c �� �� �� ������������ ������� �152-�� �� 27.07.2006 �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� � ��� ������ ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ������� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ����������� ���������� ���������� ��������, � ����� �������� ����������� �������� �� �������������� ������������������� ���������� �� ���������� ��������, �� ���������� ������������ �/��� ������������� ������������ �� ���������� ��������, � ��� ����� ���������� �� ������ � ������� ��������� ������, ������� ��������� �����, � ������������� � �������������� ���������, �����������/����������� ����������� ��������� �������, ��������� ������� � ������ ������� ��������� � ���������� �������� ����������. �����������, ��� ��  �, �� ���  ������������ �� �������� ��������� ������ ������ ���������� ����� ������, ��������� � ���������������, ��������������, ����������������, �������� ������ �� ��� ������ �����; ��������� � ����� ������, ��������������� � ���� ������������, ��������� �� �� ��������� ����������� �������; ��������� � ��������� ������������� ������������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� ��������. ��������� �������� �� ��������� ������������ ������ ����� ���� �������� ����������� ����������� ����������� ����������� � ����� �����������.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '� ������ ������ ������������ �� �������� ����������� ������� ����� ��������� ������ �������������� � ������������ � ��������, ��������������� �. 11.3 �������� ������� �� ��������� ����������� ����� � �������� �������� �������.  ';
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. �������������������� �� ��������� ������ ������� �ϻ � �������������� ���������� ��������,  � ����, ������ ������� ����������� ������������� ��������������� �� �������, �� �� ����� ����� ��������� ������� ��������: ' ||
                                             nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                ,par_separator => ', ')
                                                ,'____________________________') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. ���������������������  �� ���������� �����  ������� �ϻ � ����, ���������� ����� ���������� ������������ ��  ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, �������� ��������� ����: ���������� ���������������;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. �������������������� �� ���������� ����� �������������� � ����, ���������� ����� ���������� ������������ �� ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, ��������  �������������� ����;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.4. �������������������� �� ����� ���������� ������ ���������������� ���������������, ����������� �� ����� ������� � �� ��������� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������  �������� ��������������.'
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '����������';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '���������� ��������� ������� �����������, ����������� ������������� ����������� � ������������� ����������. �������� ������� �� ��������� ����������� ����� � �������� �������� ������� ������� (�), ���������� (�) � ������ ������ � ��������(��). � ����������� �������������������� �������� (��)';
      pkg_rep_plpdf.gv_datas(2) := '������������� �� ������������ ' || v_signer.short_name || chr(13) ||
                                   '(��� �' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '�������                                                                    ����������� �������' ||
                                   chr(13) || '����';
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*��������� ���������� ������ ������ ��� ������� �������� (�������������� 28.04.2014 ������ �.�. ���������� no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
      END IF; /*����� ����������� 28.04.2014*/
    
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
                     ,p_txt      => '��������'
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
                     ,p_txt      => '��� � ����� �����'
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
                     ,p_txt      => '�����'
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
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 25
                     ,p_txt      => '������'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => '������� ����������� ����� � �������� ���������  ������� '
                ,par_policyform_note => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������');
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------
    print_additional_cond_custom;
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_irbis;

  -- ������� ���
  -- CR107_8  - CR107_8 ��� ������� 
  -- CR107_9  - CR107_9 ��� �����
  -- CR107_10 - CR107_10 ��� �������
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
                                    '. ��������� �����, ��������� �����, ��������� ������:'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����/��������� �����������';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������:  ������������� '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* ��������� ����� �� ������ ������� �ϻ � �������������� ��������������� � ������������ � �. 7.2. �������� ������� � ����� ������� �������������� ����� ������� �� ���������� �������� �� ������ ��� ���������� � ����������� � ������������ � �������������� �������� �������� � ����� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� ��������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� ����� �� ������ ���� �ѻ, ���� �ϻ ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� ����� �� ��������� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� �������� ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** ����� ������� � ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� �������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
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
      v_text := gv_chapter_num || '. ������ ��������:';
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
                     ,p_txt      => '����� ����������: '
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
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� ����������� ���������, ����������� ��������, �� �������� ������������, �/��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.; ';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������; ';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������; ';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ������������ �������������� � �� ��������� � ������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����  �� ����������� ��������� � ����������� �/��� ����������� ������������� ��������, � ������� ���������� ������ � ������� ���������� ��������� ����������; ';
      v_declaration_states(6) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� ������� ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ���������� ����� ���������; ���� 160 ��, ��� 85 ��, ������� - 75 - ����������� ��������� ������).';
      v_declaration_states(9) := '����� ���������� ������ (���������� �������� ������) � ������� ��������� 12 (����������) �������, � ��� ����� �� ����� 4 (�������) ������� �� ��������� ����� ������; ������� � �������� ���������� � ������������� �� ��������� ��������� �������� (�� ����������� ��������� �������� � �������������� ������� ����������������), ������������ �� �������������� ���� � ������������������ ��������� �� ������ ������� ����. �������� �������������� �� ���� ���� � ����� ����������� ���������� �����;  �� �������� ���������� (����������) ����������� ������������; �� �������� �������������� ������� ����������������; �� �������� ������� ������������� ������������ ������������ (������(�), ��������, �������, �����������, ������������, ������ ����, ������ ������, �������, �������, �����); �� �������� ���������, �������� �������, �������� � �������, ������� ������������� �������� �������� � ������; �� �������� �������� ���������������� �� ������������ � �����, �� ��������� � ������� �� ����� �� ��������; �� ��������� � ��������� ������������ ��������� ���� ����������� ��� � ���������� ����������� ������������; �� �������� ����������� ��������� ����������� �����, �� �������� ���������� ��������� ����������� �����.';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������; ��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 5 250 000 (���� ��������� ������ ��������� �����)  ������; ��� � ������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ������������, ������� � �.�.), ������������� �� ���������� ���������  �������� ��� ��� ���������� ������ ����� ����������� ���������� (���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � ������� ������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������; ��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. �����������, ��� �� �, �� ��� ������������ �� �������� ��������� ������ ������ ���������� ����� ������, ��������� � ���������������, ��������������, ����������������, �������� ������ �� ��� ������ �����; ��������� � ����� ������, ��������������� � ���� ������������, ��������� �� �� ��������� ����������� �������; ��������� � ��������� ������������� ������������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������; ��� � ������(-��), �����(-�) � ��������(-��) � ���������� ���������  ����������� ����� � �������� ��������� �������.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '���������� ��������� �������, ������������ � ������������ c ����������� ������� �� 27 ���� 2006 �. � 152-�� �� ������������ ������� �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� � ��� ��������, ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ���������� ����� ������������� � ������������ �������� �����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� �������� � ����� ���� �������� ������������� (��������������) � ����� ������ ������� ����� �������� ����������� ������������ ������������� (��������������) ����������� �����������.';
      v_add_cond_states(4) := '� ������ ������ ������������ �� �������� ����������� ������� ����� ��������� ������ �������������� � ������������ � ��������, ��������������� �. 11.3 �������� ������� �� ��������� ����������� ����� � �������� �������� �������.';
    
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. ��������������������� �� ���������� ����� ������� �ϻ ���������� �������� ��������  ���������� ���������������.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. ��������������������  �� ���������� �����  �������������� �������� ��������������.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. �������������������� �� ������ ����������  ������ ���������������� ��������������� � ���������� ����������� �������, ���������� ������ ����������������, ����������� �� ����� �������  � �� ����� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������  �������� ��������������.'
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '����������';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '���������� ��������� ������� �����������, ����������� ������������� ����������� � ������������� ����������. �������� ������� �� ��������� ����������� ����� � �������� �������� ������� ������� (�), ���������� (�) � ������ ������ � ��������(��). � ����������� �������������������� �������� (��)';
      pkg_rep_plpdf.gv_datas(2) := '������������� �� ������������ ' || v_signer.short_name || chr(13) ||
                                   '(��� �' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '�������                                                                    ����������� �������' ||
                                   chr(13) || '����';
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*��������� ���������� ������ ������ ��� ������� �������� (�������������� 28.04.2014 ������ �.�. ���������� no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
      END IF; /*����� ����������� 28.04.2014*/
    
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
                     ,p_txt      => '��������'
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
                     ,p_txt      => '��� � ����� �����'
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
                     ,p_txt      => '�����'
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
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => '������'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    --print_header_custom(par_policyid => v_policy_id, par_policy_summary => v_pol_sum, par_title => );
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => '������� ����������� ����� � �������� ���������  ������� '
                ,par_policyform_note => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������');
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    --    print_insuree(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    --    print_currency_custom(par_policy_summary => v_pol_sum);
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => '��������� �����������: '
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
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_cond_custom;
    --    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_avtodom_bmw;

  -- ����� ������� ����������
  -- CR107_11  - ���������� 2 �����
  -- CR107_12 - ���������� 3 �����
  -- CR107_13 - ���������� 4 �����
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
                                    '. ��������� �����, ��������� �����, ��������� ������:'
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
      pkg_rep_plpdf.gv_datas(2) := '��������� �����/��������� �����������';
      pkg_rep_plpdf.gv_datas(3) := '��������� �����*';
      pkg_rep_plpdf.gv_datas(4) := '��������� ������';
      pkg_rep_plpdf.gv_datas(5) := '������ �������';
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
                                               '���������������� �������� �� ��������������') pl
                                       
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
    
      pkg_rep_plpdf.gv_datas(1) := '����� ��������� ������:';
      pkg_rep_plpdf.gv_datas(2) := pkg_rep_utils.to_money_sep(v_total_fee);
      pkg_rep_plpdf.gv_datas(3) := pkg_utils.money2speech(v_total_fee, v_pol_sum.fund_id);
      pkg_rep_plpdf.gv_datas(4) := NULL;
      pkg_rep_plpdf.gv_datas(5) := NULL;
      pkg_rep_plpdf.gv_datas(6) := NULL;
    
      pkg_rep_plpdf.row_print2(par_h => gv_default_height);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      plpdf.printcell(p_h        => gv_default_height
                     ,p_txt      => '������������� ������ ��������� ������:  ������������� '
                     ,p_border   => 'LR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
      set_font(par_style => pkg_rep_plpdf.gc_style_regular);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '* ��������� ����� �� ������ ������� �ϻ � �������������� ��������������� � ������������ � �. 7.2. �������� ������� � ����� ������� �������������� ����� ������� �� ���������� �������� �� ������ ��� ���������� � ����������� � ������������ � �������������� �������� �������� � ����� ������� ������������� �� ���� ����������� ���������� ������ � ������������ � �������������� �������� ��������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� ����� �� ������ ���� �ѻ, ���� �ϻ ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '��������� ����� �� ��������� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� �������� ����� ������� �������������� ����� ������� ��������������� �� ���������� �������� �� ������ ��� ����������.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '** ����� ������� � ������� (������� ��� ���������� ������), ��������� � ������� �������� ��������, � �����  ������������, ��� �������, ��� � ������� ������������ ������� ����������� ���������� �� ����� ���� ���.'
                              ,p_align    => 'J'
                              ,p_border   => 'LR'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_ln       => 1);
    
    END print_programs_custom;
  
    PROCEDURE print_period_custom IS
    BEGIN
      print_period(par_policy_summary => v_pol_sum);
    
      plpdf.printmultilinecell(p_h        => gv_default_height
                              ,p_txt      => '������� ����������� �������� � ���� � 00:00 ����� ���, ���������� �� ����� ������ ������������� � ������ ������ ������� ���������� ������ ����������� / ������������� �����������, ���� ���� (����� �������) ���� ������ ����� �������� �������� ����������� �� ������� � �������� �����������.'
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
      v_text := gv_chapter_num || '. ������ ��������:';
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
                     ,p_txt      => '����� ����������: '
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
      v_declaration_states(1) := '�� �������� ���������, �����, ��������� ����������� �����; �� ����� ��������� ������-������������ �������, �������������� ��������; �� �������� �������� ����������, �������� ��������������, ������������ �������������; �� ����������� ���������, ����������� ��������, �� �������� ������������, �/��� �� ������� �� ������������� �������� �� ������������ �����; �� �������� ���-�������������� ��� �� �������� ������ (��������� �������������� ��������� ��������), � ����� �� �������� ����� �������������, ��������������� ���������� ���������� ��� ����������� ���� ������, ������� ��������� ������, �����, ������� ������� ���������� � �.�.; ';
      v_declaration_states(2) := '�� ��������� � ��������� ���������� ���������� ��� ������ �����������, ��������������� ��� ���������� ���, ������������� ��� ���������� � ���������� ������������; ';
      v_declaration_states(3) := '�� ��������/�������(�) ���������� �������������: ������������� ����� 7 (����) ��������, ����������� �������� ���������������, ���������� �����, ��������������� �������� �����, ������� �����, �������� ������, ���������, ������������������ ��������� (������� ����������� ������� ������, ������� (������� ������������ �������), ���������� (II-IV �������), �������������, ��������� �������, ������������ ��������, ��������, �������� �� ������ � ������� � �.�.), ������ ������, ����������� �������, ��������������� ��� ����������������� �������, ����������, � ����� ����� ������������ �������������, ���������� ���������� ������������, �������, ������������ ��� ����������; ';
      v_declaration_states(4) := '�� ��������� 2 (���) ���� �� ��������� �� ���������� ����� ������ 3 (���) ������ ������ � ����� (���� �� ������� ����, �� �������� ������ ������������� ��������, �����, ������, �� ��������� ������������ �������������� � �� ��������� � ������) �/��� �� ��� ��������� �� ������������ �������, ��� �� ��������� 12 ������� �� ��������� �� ����������� �������, ������������� ��� ������������� �� ������� ������ � ���� �� ����������� ����� ������ ����;';
      v_declaration_states(5) := '� ��������� ������ �� ��������� ��� ����������� �����, �� �������, �� ��������� ��������� � ����� � �����-���� ������������ (���������� ��������) ��� � ��������� ���� �� ������������� �������/�������� � ��/��� �� ��������� ���������� � ����� �� ������� ������-���� ����������� � ��������� �����  �� ����������� ��������� � ����������� �/��� ����������� ������������� ��������, � ������� ���������� ������ � ������� ���������� ��������� ����������; ';
      v_declaration_states(6) := '�� ������ � ������ ������ � ����� � �������� ������������� (��������: ���������, ������ � ����������� � ����������� ����������, ����������� ���������� ���������, ������ �� ������, ��� ������, ��� �����, �� �������� � ������� ����������, � �������, � ������������������ �������, ����������, ���������, ������ (����� ������ ���� � �����) ������������ � �.�.), � ����� �� ���������� �������� ������ ������ ��� �������� ������ ��������� (�����);';
      v_declaration_states(7) := '�� ������� ��������� �� ����������� �����, ����������� �� ���������� ������� � ��������, ������ ���������������� (������������), �� ���������� �������, � ������� ���/�� ���� ��������, ������� ���� �������� ��� ������� �� ������ �������� (� ����������� ���������� �������������, ���������� ��� ������ �������), � ����� ����������� ��������� �����������, ������� ���� ����������� �� ������� ������������� ���������� ��� ������������ ������� ������� ���� �������� ��  ����������� ������ ������� �����;';
      v_declaration_states(8) := '�� ���������� ����� 30 (��������) ������� � ����. ������� ����� ������ (� ��.) � ����� (� ��.) ��������������� �� ����� 80 � �� ����� 120 (��������, ���� - 180 ��, ��� - 85 ��, ������� ���������� - 95, ���������� ����� ���������; ���� 160 ��, ��� 85 ��, ������� - 75 - ����������� ��������� ������).';
      v_declaration_states(9) := '����� ���������� ������ (���������� �������� ������) � ������� ��������� 12 (����������) �������, � ��� ����� �� ����� 4 (�������) ������� �� ��������� ����� ������; ������� � �������� ���������� � ������������� �� ��������� ��������� �������� (�� ����������� ��������� �������� � �������������� ������� ����������������), ������������ �� �������������� ���� � ������������������ ��������� �� ������ ������� ����. �������� �������������� �� ���� ���� � ����� ����������� ���������� �����;  �� �������� ���������� (����������) ����������� ������������; �� �������� �������������� ������� ����������������; �� �������� ������� ������������� ������������ ������������ (������(�), ��������, �������, �����������, ������������, ������ ����, ������ ������, �������, �������, �����); �� �������� ���������, �������� �������, �������� � �������, ������� ������������� �������� �������� � ������; �� �������� �������� ���������������� �� ������������ � �����, �� ��������� � ������� �� ����� �� ��������; �� ��������� � ��������� ������������ ��������� ���� ����������� ��� � ���������� ����������� ������������; �� �������� ����������� ��������� ����������� �����, �� �������� ���������� ��������� ����������� �����.';
    
      v_declaration_states2(1) := '��� � ��������(-��) � ������������� ��������� ����������, �.�. � ����������� ������������� ��������, ������������ � ���� ������������. � �������, ��� �������������� ������ �/��� �������� ��������, ����� ��� � ����� � �������������� ����������, ����� ������� ����� � ��������� �������; ��� � ��������� ��������������� �� ��������� � �� ������ ��������� �� ���������� ������ ��������� ����������� ����� �/��� �� ���������� ������� � ��� ��� ���������� ������, �� ������� ��������� ����� � ��������� ������� ����� � ����� �� ���������� ������� �� ����������� ������ �� ������� �������� ��������� 5 250 000 (���� ��������� ������ ��������� �����)  ������; ��� � ������������� ������ ����� �/��� ����� �������� ����������, ��������������� ��� ����������� ������ (������������, ������������, ������� � �.�.), ������������� �� ���������� ���������  �������� ��� ��� ���������� ������ ����� ����������� ���������� (���������� ������������ � ���������������� ������������, ���������� �������, ������� �� ����������� � �.�.) ��� � ����� � ������� ������� ���������� �����, ��� � � ����� �� ���������� �������� �� ������� �������� �����������; ��� � �������� ��������������� ��������� ��������� ����������� � ������ ��������� ������� ����� ��� ������ ��������������� �����������. �����������, ��� �� �, �� ��� ������������ �� �������� ��������� ������ ������ ���������� ����� ������, ��������� � ���������������, ��������������, ����������������, �������� ������ �� ��� ������ �����; ��������� � ����� ������, ��������������� � ���� ������������, ��������� �� �� ��������� ����������� �������; ��������� � ��������� ������������� ������������. � �������, ��� ��������� ������� ����� ����� ������� ������ �������������� ��������� ������ �/��� ��������� ������� �������� �����������. � ����� �������, ��� � ������ ����� ������ ���������������� ����������� �� ��������� ������� ����� � �������� �������������� ��������� ������ �/��� �������� ������� �����������, ������� ����������� ����� ���������� ������������ � ������������� ������� � ��������� ������� �� ���� ����� ����������; ��� � ������(-��), �����(-�) � ��������(-��) � ���������� ���������  ����������� ����� � �������� ��������� �������.';
    
      print_declaration(par_declaration_states  => v_declaration_states
                       ,par_declaration_states2 => v_declaration_states2);
    END;
  
    PROCEDURE print_additional_cond_custom IS
      v_add_cond_states t_states;
    BEGIN
      v_add_cond_states(1) := '��� ���������� ��������� ������������, ����������� � ���������� ��������, � ����� ��� ���������� � ���������� � ���������� ��������, �������� ��� ��������� � ������������ ������.';
      v_add_cond_states(2) := '������� �������� ������ ����������� ���� ���������������� ������� � ��������� ������� ����������� (���������������� ������������ ��� ���� �������� � �������������� �����) � ��������� ��������, � ����� �� ���� ����������� � �������������� ����������� � ����.';
      v_add_cond_states(3) := '���������� ��������� �������, ������������ � ������������ c ����������� ������� �� 27 ���� 2006 �. � 152-�� �� ������������ ������� �������� ����������� �������� �� ���������, � ��� ����� �������� ������ �� ���������� �������� � ��� ��������, ���������������� ������������ (� ��� ����� ����������� �� �������) ����� ������������ ������, � ��� ����� ������ � ��������� ��������, ������������ � ����������, ������������ ����������� � ����� ����������� �������, �����, ����� �� ����� ���� ������������� ������ ��������� � ������� ������� �����, � ��� ����� � ����� ���������� ����� ������������� � ������������ �������� �����������. ��������� �������� ������������/��������������� ������������� � ������� ����� �������� ���������� �������� � � ������� 15 ��� ����� ��������� ����� �������� ���������� �������� � ����� ���� �������� ������������� (��������������) � ����� ������ ������� ����� �������� ����������� ������������ ������������� (��������������) ����������� �����������.';
      v_add_cond_states(4) := '� ������ ������ ������������ �� �������� ����������� ������� ����� ��������� ������ �������������� � ������������ � ��������, ��������������� �. 11.3 �������� ������� �� ��������� ����������� ����� � �������� �������� �������.';
    
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
                     ,p_txt      => gv_chapter_num || '. �������������������:'
                     ,p_border   => 'LR'
                     ,p_ln       => 1
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      set_font;
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.1. ������ �������������������� �� ��������� ������ ������� �ϻ � �������������� ���������� ��������,  � ����, ������ ������� ����������� ������������� ��������������� �� �������, �� �� ����� ����� ��������� ������� ��������: ' ||
                                             nvl(pkg_utils.get_aggregated_string(par_table     => v_benif_array
                                                                                ,par_separator => ', ')
                                                ,'____________________________') || '.'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.2. ���������������������  �� ���������� �����  ������� �ϻ � ����, ���������� ����� ���������� ������������ ��  ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, �������� ���������� ���������������;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.3. �������������������� �� ���������� ����� �������������� � ����, ���������� ����� ���������� ������������ �� ��������� ������� ������� �������������������, ���������� �. 7.1. ���������� ��������, ��������  �������������� ����;'
                              ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                              ,p_border   => 'LR'
                              ,p_ln       => 1);
      plpdf.printmultilinecell(p_h        => 4
                              ,p_txt      => '7.4. �������������������� �� ����� ���� �ѻ, �� ����� ���� �ϻ � �� ��������� �������� ��������������� �� ������ ���������� ������ �� ����������� �� ���� ��������  �������� ��������������.'
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
         ('������� ������������� �� B2B', '������')
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
    
      pkg_rep_plpdf.gv_datas(1) := '������������';
      pkg_rep_plpdf.gv_datas(2) := '����������';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_borders(1) := 'LR';
      pkg_rep_plpdf.gv_borders(2) := 'LR';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '���������� ��������� ������� �����������, ����������� ������������� ����������� � ������������� ����������. �������� ������� �� ��������� ����������� ����� � �������� �������� ������� ������� (�), ���������� (�) � ������ ������ � ��������(��). � ����������� �������������������� �������� (��)';
      pkg_rep_plpdf.gv_datas(2) := '������������� �� ������������ ' || v_signer.short_name || chr(13) ||
                                   '(��� �' || v_signer.procuratory_num || ')';
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_datas(1) := NULL;
      pkg_rep_plpdf.gv_datas(2) := NULL;
    
      pkg_rep_plpdf.gv_styles(1) := NULL;
      pkg_rep_plpdf.gv_styles(2) := NULL;
    
      pkg_rep_plpdf.row_print2;
    
      pkg_rep_plpdf.gv_styles(1) := pkg_rep_plpdf.gc_style_italic;
      pkg_rep_plpdf.gv_styles(2) := pkg_rep_plpdf.gc_style_italic;
    
      pkg_rep_plpdf.gv_datas(1) := '�������                                                                    ����������� �������' ||
                                   chr(13) || '����';
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
                     ,p_txt      => gv_chapter_num || '. ������������ / ��������������:'
                     ,p_border   => 'LTR'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 1);
    
      set_font;
    
      plpdf.printcell(p_border   => 'L'
                     ,p_w        => 5
                     ,p_ln       => 0
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping);
      plpdf.printcell(p_h        => gv_default_height -- -1
                     ,p_txt      => '�������'
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
                              ,p_txt      => '          ���� ��������'
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
                     ,p_txt      => '���'
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
                     ,p_txt      => '          ��������, �������������� ��������'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0);
    
      set_font(par_style => pkg_rep_plpdf.gc_style_bold);
      /*��������� ���������� ������ ������ ��� ������� �������� (�������������� 28.04.2014 ������ �.�. ���������� no_data_found)*/
      IF pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id) IS NOT NULL
      THEN
        l_type_doc  := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#TYPE_DESC>');
        l_doc_num   := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'<#DOC_SERNUM>');
        l_doc_place := pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(par_insuree_info.contact_id)
                                                                     ,'�����: <#DOC_PLACE> ���� ������: <#DOC_DATE>');
      
      END IF; /*����� ����������� 28.04.2014*/
    
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
                     ,p_txt      => '��������'
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
                     ,p_txt      => '��� � ����� �����'
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
                     ,p_txt      => '�����'
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
    
      --������� � ������ ������            
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 35
                     ,p_txt      => ''
                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h   => gv_default_height
                     ,p_w   => 25
                     ,p_txt => '������'
                      --                     ,p_border   => 'L'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'L');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�����, �����, ���'
                     ,p_border   => '0'
                     ,p_clipping => pkg_rep_plpdf.gc_default_no_clipping
                     ,p_ln       => 0
                     ,p_align    => 'R');
      plpdf.printcell(p_h        => gv_default_height
                     ,p_w        => 40
                     ,p_txt      => '�������'
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
  
    -- �������������
    pkg_rep_plpdf.init(par_default_font_size => 8);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- ������� �
    -------------------------------------------------------------------------------------------------
    --print_header_custom(par_policyid => v_policy_id, par_policy_summary => v_pol_sum, par_title => );
    print_header(par_policy_id       => v_policy_id
                ,par_policy_summary  => v_pol_sum
                ,par_title           => '������� ����������� ����� � �������� ���������  ������� '
                ,par_policyform_note => '�������� �� ��������� �������� ������� �� ��������� ����������� ����� � �������� �������� �������');
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_insurer;
  
    -------------------------------------------------------------------------------------------------
    -- ������������ / ��������������
    -------------------------------------------------------------------------------------------------
    print_insuree_custom(par_insuree_info => v_insuree_info, par_pol_sum => v_pol_sum);
    --    print_insuree(par_insuree_info => v_insuree_info);
  
    -------------------------------------------------------------------------------------------------
    -- ���� ��������
    -------------------------------------------------------------------------------------------------
    print_period(v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������ ��������
    -------------------------------------------------------------------------------------------------
    --    print_currency_custom(par_policy_summary => v_pol_sum);
    print_currency(par_policy_summary => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_territory;
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    set_font(par_style => pkg_rep_plpdf.gc_style_bold);
    plpdf.printcell(p_h        => gv_default_height
                   ,p_txt      => '��������� �����������: '
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
    -- ���������
    -------------------------------------------------------------------------------------------------
    print_programs_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������������
    -------------------------------------------------------------------------------------------------
    print_beneficiaries_custom;
  
    -------------------------------------------------------------------------------------------------
    -- ����������
    -------------------------------------------------------------------------------------------------
    print_declaration_custom;
  
    -------------------------------------------------------------------------------------------------
    -- �������������� �������
    -------------------------------------------------------------------------------------------------
    plpdf.newpage;
    print_additional_cond_custom;
    --    plpdf.printcell(p_w => plpdf.getpagespace, p_border => 'LRB', p_h => 0, p_ln => 1);
    pkg_rep_plpdf.print_draft(v_pol_sum.policy_status_desc);
  
    -------------------------------------------------------------------------------------------------
    -- �������
    -------------------------------------------------------------------------------------------------
    print_sign_custom(par_report_exe_name => lower(gc_pkg_name || '.' || c_proc_name)
                     ,par_policy_summary  => v_pol_sum);
  
    -------------------------------------------------------------------------------------------------
    -- ������������ PDF
    -------------------------------------------------------------------------------------------------
    plpdf.senddoc(p_blob => par_data);
    par_file_name    := 'policy_' || v_pol_sum.pol_num || '.pdf';
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  
  END rep_avtodom_avtocredit;

END pkg_rep_credit_policy;
/

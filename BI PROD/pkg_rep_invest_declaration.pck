CREATE OR REPLACE PACKAGE pkg_rep_invest_declaration IS

  -- Author  : Черных М.
  -- Created : 29.04.2015 
  -- Purpose : Печать инвестиционных деклараций

  /**
  * Продукт: Инвестор с единовременной формой оплаты; Серия: 148, 681
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_1
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед.ф.оплаты (АкБарс)+ для Глобэкса; Серия: 149
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_2
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – альфа); Серия: 517
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_3
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: 
      Инвестор Партнер (агент - ОАО "Азиатско-Тихоокеанский Банк"); Серия: 626
      Инвестор Партнер (агент – альфа); Серия: 505
      Инвестор Партнер (агент – кредит европа банк); Серия: 607    
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_4
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Вклад в будущее; Серия: 508, 519, 521, дата договра < 01.10.2013
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_5_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Вклад в будущее; Серия: 508, 519, 521, дата договра >= 01.10.2013
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_5_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл. (агент – ВТБ24); Серия: 682, дата договра < 01.12.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_6_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл. (агент – ВТБ24); Серия: 682, дата договра >= 01.12.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_6_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – ХКБ); Серия: 675, дата договра < 01.04.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_7_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – ХКБ); Серия: 675, дата договра >= 01.04.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_7_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор плюс; Серия:618, 686
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_8
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Инвестор_new (5 лет, Инвестор для ВТБ); Серия 679: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_9
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Приоритет Инвест (единовременный Инвестор) Сбербанк; Серия 615: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_10
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

  /**
  * Продукт: Приоритет Инвест (регулярный Инвестор) Сбербанк; Серия 614: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_11
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  );

END pkg_rep_invest_declaration;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_invest_declaration IS

  gc_filename VARCHAR2(100) := 'invest_declaration.pdf';

  /**
  * Получить BLOB шаблона
  * @author Черных М. 30.04.2015
  */
  FUNCTION get_template_blob RETURN BLOB IS
    v_template_blob BLOB;
    v_rep_report_id rep_report.rep_report_id%TYPE;
  BEGIN
    v_rep_report_id := to_number(repcore.get_context('REP_REPORT_ID'));
  
    SELECT t.templ
      INTO v_template_blob
      FROM rep_report r
          ,rep_templ  t
     WHERE r.rep_report_id = v_rep_report_id
       AND r.rep_templ_id = t.rep_templ_id;
    RETURN v_template_blob;
  EXCEPTION
    WHEN no_data_found
         OR too_many_rows THEN
      RETURN NULL;
  END get_template_blob;

  /**
  * Продукт: Инвестор с единовременной формой оплаты; Серия: 148, 681
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_1
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_1;

  /**
  * Продукт: Инвестор Партнер с ед.ф.оплаты (АкБарс)+ для Глобэкса; Серия: 149
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_2
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_2;

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – альфа); Серия: 517
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_3
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_3;

  /**
  * Продукт: 
      Инвестор Партнер (агент - ОАО "Азиатско-Тихоокеанский Банк"); Серия: 626
      Инвестор Партнер (агент – альфа); Серия: 505
      Инвестор Партнер (агент – кредит европа банк); Серия: 607    
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_4
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_4;

  /**
  * Продукт: Вклад в будущее; Серия: 508, 519, 521, дата договра < 01.10.2013
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_5_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_5_before;

  /**
  * Продукт: Вклад в будущее; Серия: 508, 519, 521, дата договра >= 01.10.2013
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_5_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_5_after;

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл. (агент – ВТБ24); Серия: 682, дата договра < 01.12.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_6_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_6_before;

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл. (агент – ВТБ24); Серия: 682, дата договра >= 01.12.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_6_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_6_after;

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – ХКБ); Серия: 675, дата договра < 01.04.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_7_before
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_7_before;

  /**
  * Продукт: Инвестор Партнер с ед. ф. опл.(агент – ХКБ); Серия: 675, дата договра >= 01.04.2014
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_7_after
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_7_after;

  /**
  * Продукт: Инвестор плюс; Серия:618, 686
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_8
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_8;

  /**
  * Продукт: Инвестор_new (5 лет, Инвестор для ВТБ); Серия 679: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_9
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_9;

  /**
  * Продукт: Приоритет Инвест (единовременный Инвестор) Сбербанк; Серия 615: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_10
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_10;

  /**
  * Продукт: Приоритет Инвест (регулярный Инвестор) Сбербанк; Серия 614: 
  * @author Черных М. 30.04.2015
  */
  PROCEDURE invest_declaration_11
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT NOCOPY BLOB
  ) IS
  BEGIN
    par_data         := get_template_blob;
    par_file_name    := gc_filename;
    par_content_type := pkg_rep_plpdf.gc_pdf_content_type;
  END invest_declaration_11;

END pkg_rep_invest_declaration;
/

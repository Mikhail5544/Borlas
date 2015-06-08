CREATE OR REPLACE PACKAGE PKG_RSA_AUTOCHANGE AS
  /**
  * Функции для формы большого Автообмена RSA_BA_PACK_DATA
  * @author Kushenko S.
  * @version 1.0
  * @since 1.0
  * @headcom
  */

  /**
  * Процедура инициализации пакетной переменной  xml_file типа CLOB  
  * @autor Кущенко С.
  */
  PROCEDURE init_clob;

  /**
  * Процедура заполнения пакетной пееменной xml_file типа CLOB
  * @param str  Строка добавляемая к переменной xml_file
  * @autor Кущенко С.
  */
  PROCEDURE add_clob(str VARCHAR2);

  /**
  * Процедура парсинга  пакетной переменной xml_file с разнесеннием данных по ДОГОВОРАМ
  * в таблицу ins_dwh.RSA_ERR_PACK_DATA
  * @p_pack_header_id  ИД Реестра договоров страхования
  * @p_code_osn_id  
  * @p_code_isp_id
  * @autor Кущенко С.
  */
  PROCEDURE pack_err_data
  (
    p_pack_header_id NUMBER
   ,p_code_osn_id    NUMBER
   ,p_code_isp_id    NUMBER
  );

  /**
  * Процедура парсинга  пакетной переменной xml_file с разнесеннием данных по СОБЫТИЯМ
  * в таблицу ins_dwh.RSA_ERR_PACK_DATA
  * @autor Кущенко С.
  * @param p_pack_header_id  ИД Реестра договоров страхования
  * @param p_code_osn_id  
  * @param p_code_isp_id
  * 
  */
  PROCEDURE pack_err_event
  (
    p_pack_header_id NUMBER
   ,p_code_osn_id    NUMBER
   ,p_code_isp_id    NUMBER
  );

  /**
  * Процедура экспорта информации об изменениях в состоянии БСО за период 
    во временную таблицу
    @autor Кущенко С.
    @param start_date Дата начала периода
    @param end_date   Дата окончания периода
    @return BSO_STATUS_RSA_TMP.ID (ИД выгружаемого XML файла) 
  */

  FUNCTION bso_status_export_xml
  (
    start_date IN DATE
   ,end_date   IN DATE
  ) RETURN NUMBER;

  /**
  * Процедура экспорта файла описания страховой организации во временную таблицу
    перед экспортом в файл s0.XML
    @autor Кущенко С.
    @param p_rep_ref_id - ИД расчета
    @return BSO_STATUS_RSA_TMP.ID (ИД выгружаемого XML файла) 
  */
  FUNCTION export_2C_0_xml(p_rep_ref_id NUMBER) RETURN NUMBER;

  /**
  * Процедура экспорта таблицы формы 2С (Раздел 6) во временную таблицу
    перед экспортом в файл XML.
    Формат файла описан в документе: 
    "Приложение 1 к письму Министерства финансов Российской Федерации от 08 апреля 2004 г. № 24-07/04-02"
    @autor Кущенко С.
    @param p_rep_ref_id - ИД расчета
    @param p_ct         - Код таблицы (6.1, 6.5.15, ....)
    @return BSO_STATUS_RSA_TMP.ID (ИД выгружаемого XML файла) 
  */
  FUNCTION export_2C_6_xml
  (
    p_rep_ref_id NUMBER
   ,p_ct         VARCHAR2
  ) RETURN NUMBER;

  /**
  * Процедура экспорта таблиц формы 2С (Подраздел 6.5) во временную таблицу
    перед экспортом в файл TXT (разделитель TAB). Для последующего импорта в 
    программу ГСО, которая не умеет импортировать XML-файлы для соответствующего
    раздела
    @autor Кущенко С.
    @param p_rep_ref_id - ИД расчета
    @param p_ct         - Код таблицы (6.1, 6.5.15, ....)
    @return BSO_STATUS_RSA_TMP.ID (ИД выгружаемого XML файла) 
  */

  FUNCTION export_2C_65_txt
  (
    p_rep_ref_id NUMBER
   ,p_ct         VARCHAR2
  ) RETURN NUMBER;

END PKG_RSA_AUTOCHANGE;
/
CREATE OR REPLACE PACKAGE BODY PKG_RSA_AUTOCHANGE AS
  xml_file CLOB; -- Здесь храним здоровенный xml-файл

  PROCEDURE init_clob AS
  BEGIN
    xml_file := NULL;
  END;

  PROCEDURE add_clob(str VARCHAR2) AS
  BEGIN
    xml_file := xml_file || str;
  END;

  PROCEDURE pack_err_data
  (
    p_pack_header_id NUMBER
   ,p_code_osn_id    NUMBER
   ,p_code_isp_id    NUMBER
  ) AS
  BEGIN
    FOR rc IN (SELECT ins_dwh.SQ_RSA_ERR_PACK_DATA.NEXTVAL RSA_ERR_PACK_DATA_ID
                     ,(SELECT t.RSA_BA_PACK_DATA_ID
                         FROM ins_dwh.RSA_BA_PACK_DATA t
                        WHERE t.rsa_pack_header_id = p_pack_header_id
                          AND t.RECID = extractValue(VALUE(i), '/RECORD@RECID')
                          AND t.t_rsa_pack_code_id IN (p_code_osn_id, p_code_isp_id)
                          AND ROWNUM = 1) RSA_PACK_DATA_ID
                     ,extractValue(VALUE(i), '/RECORD@RECID') recid
                     ,extractValue(VALUE(i), '/RECORD@C_ERR') c_err
                     ,SYSDATE imp_date
                     ,0 STATUS
                 FROM TABLE(xmlsequence(EXTRACT(XMLTYPE.createxml(xml_file), '/DATA/RECORD'))) i
                WHERE UPPER(extractValue(VALUE(i), '/RECORD@C_ERR')) LIKE 'R__')
    LOOP
      BEGIN
        INSERT INTO ins_dwh.RSA_ERR_PACK_DATA VALUES rc;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101, SQLERRM);
  END;

  PROCEDURE pack_err_event
  (
    p_pack_header_id NUMBER
   ,p_code_osn_id    NUMBER
   ,p_code_isp_id    NUMBER
  ) AS
  BEGIN
    FOR rc IN (SELECT ins_dwh.SQ_RSA_ERR_PACK_DATA.NEXTVAL RSA_ERR_PACK_DATA_ID
                     ,(SELECT t.RSA_BA_PACK_EVENT_ID
                         FROM ins_dwh.RSA_BA_PACK_EVENT t
                        WHERE t.rsa_pack_header_id = p_pack_header_id
                          AND t.RECID = extractValue(VALUE(i), '/RECORD@RECID')
                          AND t.t_rsa_pack_code_id IN (p_code_osn_id, p_code_isp_id)
                          AND ROWNUM = 1) RSA_PACK_DATA_ID
                     ,extractValue(VALUE(i), '/RECORD@RECID') recid
                     ,extractValue(VALUE(i), '/RECORD@C_ERR') c_err
                     ,SYSDATE imp_date
                     ,0 STATUS
                 FROM TABLE(xmlsequence(EXTRACT(XMLTYPE.createxml(xml_file), '/DATA/RECORD'))) i
                WHERE UPPER(extractValue(VALUE(i), '/RECORD@C_ERR')) LIKE 'S__')
    LOOP
      BEGIN
        INSERT INTO ins_dwh.RSA_ERR_PACK_DATA VALUES rc;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20102, SQLERRM);
  END pack_err_event;

  FUNCTION bso_status_export_xml
  (
    start_date IN DATE
   ,end_date   IN DATE
  ) RETURN NUMBER AS
    new_tmp_xml_id NUMBER;
    current_row_id NUMBER;
    l_state        VARCHAR2(1000);
    date1          DATE;
    date2          DATE;
  BEGIN
    date1 := start_date;
    date2 := end_date;
    SELECT SQ_TMP_TXT.NEXTVAL INTO new_tmp_xml_id FROM dual;
    current_row_id := 1;
  
    /*<?xml version="1.0" encoding="UTF-8"?>
    
    <autoins>
        <header>
            <sender id="18800000"/>
            <recipient id="00000000"/>
        </header>
        <body>
    */
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<?xml version="1.0" encoding="UTF-8"?>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<autoins>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<header>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<sender id="18800000"/>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<recipient id="00000000"/>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</header>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<body>');
    current_row_id := current_row_id + 1;
  
    -- Статус №1  "Находится у страховщика"
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,bdc.num_start || DECODE(bdc.num_end, NULL, NULL, '-' || bdc.num_end) AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'002' AS bstate
                      ,TO_CHAR(d.reg_date, 'YYYYMMDDHH24miss') AS bdate
                  FROM ven_bso_document d
                      ,DOC_TEMPL        dt
                      ,ven_bso_doc_cont bdc
                      ,ven_bso_series   bs
                      ,ven_bso_type     bt
                 WHERE d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'НакладнаяБСО' --Заменил Балашов 17.01.2008   and dt.brief = 'ВыдачаБСО'
                   AND bdc.bso_document_id = d.bso_document_id
                   AND bs.bso_series_id = bdc.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND d.reg_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №2 В системе Borlas Insurance отсутствует
  
    -- Статус №3-4 "Находится у страхователя"  
    -- 3) Выдача бланка страхователю при заключении или изменении условий договора договора,
    -- требующих выдачи нового БСО
    -- 4) Выдача бланка страхователю вследствие утраты или порчи выданного БСО
  
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,b.num AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'003' AS bstate
                      ,TO_CHAR(bh.hist_date, 'YYYYMMDDHH24miss') AS bdate
                      ,p.pol_num AS bcontractnr
                  FROM ven_bso_hist      bh
                      ,ven_bso_hist_type bht
                      ,ven_bso           b
                      ,ven_bso_series    bs
                      ,ven_bso_type      bt
                      ,ven_p_policy      p
                 WHERE bh.hist_type_id = bht.bso_hist_type_id
                   AND bht.brief = 'Использован'
                   AND bh.bso_id = b.bso_id
                   AND bs.bso_series_id = b.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND p.policy_id = b.policy_id
                   AND bh.hist_date BETWEEN date1 AND date2
                 ORDER BY bh.hist_date)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '" contractnr="' || rec.bcontractnr || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №5 "Утрачен" Версия 2
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,bdc.num_start || DECODE(bdc.num_end, NULL, NULL, '-' || bdc.num_end) AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'004' AS bstate
                      ,TO_CHAR(bd.reg_date, 'YYYYMMDDHH24miss') AS bdate
                
                  FROM ven_bso_document  bd
                      ,DOC_TEMPL         dt
                      ,ven_bso_doc_cont  bdc
                      ,ven_bso_hist_type bht
                      ,ven_bso           b
                      ,ven_bso_series    bs
                      ,ven_bso_type      bt
                 WHERE bd.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'СписаниеБСО'
                   AND bdc.bso_document_id = bd.bso_document_id
                   AND bs.bso_series_id = bdc.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                   AND bht.brief = 'Утерян'
                   AND bd.reg_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №6 "Испорчен"
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,b.num AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'005' AS bstate
                      ,TO_CHAR(bh.hist_date, 'YYYYMMDDHH24miss') AS bdate
                
                  FROM ven_bso_hist      bh
                      ,ven_bso_hist_type bht
                      ,ven_bso           b
                      ,ven_bso_series    bs
                      ,ven_bso_type      bt
                 WHERE bh.hist_type_id = bht.bso_hist_type_id
                   AND bht.brief = 'Испорчен'
                   AND bh.bso_id = b.bso_id
                   AND bs.bso_series_id = b.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND bh.hist_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №7 Украден  (версия 2)
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,bdc.num_start || DECODE(bdc.num_end, NULL, NULL, '-' || bdc.num_end) AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'006' AS bstate
                      ,TO_CHAR(bd.reg_date, 'YYYYMMDDHH24miss') AS bdate
                
                  FROM ven_bso_document  bd
                      ,DOC_TEMPL         dt
                      ,ven_bso_doc_cont  bdc
                      ,ven_bso_hist_type bht
                      ,ven_bso           b
                      ,ven_bso_series    bs
                      ,ven_bso_type      bt
                 WHERE bd.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'СписаниеБСО'
                   AND bdc.bso_document_id = bd.bso_document_id
                   AND bs.bso_series_id = bdc.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                   AND bht.brief = 'Похищен'
                   AND bd.reg_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №8 "Утратил силу": переписать с учетом нового статуса
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,b.num AS bnumber
                      ,DECODE(bt2.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'009' AS bstate
                      ,TO_CHAR(bh2.hist_date, 'YYYYMMDDHH24miss') AS bdate
                  FROM ven_bso_hist      bh2
                      ,ven_bso_hist_type bht2
                      ,ven_bso           b2
                      ,ven_bso_series    bs2
                      ,ven_bso_type      bt2
                      ,ven_p_policy      p2
                      ,ven_p_policy      p
                      ,ven_bso           b
                      ,ven_bso_series    bs
                 WHERE bh2.hist_type_id = bht2.bso_hist_type_id
                   AND bht2.brief = 'Использован'
                   AND bh2.bso_id = b2.bso_id
                   AND bs2.bso_series_id = b2.bso_series_id
                   AND bt2.bso_type_id = bs2.bso_type_id
                   AND (bt2.brief = 'ОСАГО' OR bt2.brief LIKE 'СЗОСАГО%')
                   AND b2.policy_id = p2.policy_id
                   AND doc.get_doc_status_brief(p2.policy_id) <> 'PROJECT'
                   AND p.pol_header_id = p2.pol_header_id
                   AND p.version_num = p2.version_num - 1
                   AND b.policy_id = p.policy_id
                   AND bs.bso_series_id = b.bso_series_id
                   AND bs.bso_type_id = bs2.bso_type_id
                   AND pkg_bso.get_bso_last_status_brief(b.bso_id) = 'Использован'
                   AND bh2.hist_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    -- Статус №9 "Уничтожен"  (версия 2)
    FOR rec IN (SELECT bs.series_name AS bseries
                      ,bdc.num_start || DECODE(bdc.num_end, NULL, NULL, '-' || bdc.num_end) AS bnumber
                      ,DECODE(bt.brief, 'ОСАГО', 'P', 'S') AS btype
                      ,'007' AS bstate
                      ,TO_CHAR(bd.reg_date, 'YYYYMMDDHH24miss') AS bdate
                      ,'18800000' AS binsurer
                  FROM ven_bso_document  bd
                      ,DOC_TEMPL         dt
                      ,ven_bso_doc_cont  bdc
                      ,ven_bso_hist_type bht
                      ,ven_bso           b
                      ,ven_bso_series    bs
                      ,ven_bso_type      bt
                 WHERE bd.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'УничтожениеБСО'
                   AND bdc.bso_document_id = bd.bso_document_id
                   AND bs.bso_series_id = bdc.bso_series_id
                   AND bt.bso_type_id = bs.bso_type_id
                   AND (bt.brief = 'ОСАГО' OR bt.brief LIKE 'СЗОСАГО%')
                   AND bht.bso_hist_type_id = bdc.bso_hist_type_id
                   AND bht.brief = 'Уничтожен'
                   AND bd.reg_date BETWEEN date1 AND date2)
    LOOP
      l_state := '<form-state mid="' || TO_CHAR(current_row_id - 7) || '" series="' || rec.bseries ||
                 '" number="' || rec.bnumber || '" type="' || rec.btype || '" state="' || rec.bstate ||
                 '" date="' || rec.bdate || '" insurer="' || rec.binsurer || '"/>';
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, l_state);
      current_row_id := current_row_id + 1;
    END LOOP;
  
    /*    </body>
        <signature/>
    </autoins> */
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</body>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<signature/>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</autoins>');
    IF current_row_id = 10
    THEN
      ROLLBACK;
      RETURN NULL;
    END IF;
    COMMIT;
    RETURN(new_tmp_xml_id);
  END;

  FUNCTION export_2C_0_xml(p_rep_ref_id NUMBER) RETURN NUMBER AS
    new_tmp_xml_id NUMBER;
    current_row_id NUMBER;
    l_begin_date   VARCHAR2(10);
    l_end_date     VARCHAR2(10);
  BEGIN
    current_row_id := 1;
    BEGIN
      SELECT SQ_TMP_TXT.NEXTVAL INTO new_tmp_xml_id FROM dual;
      SELECT TO_CHAR(r.date_begin, 'dd.mm.yyyy')
            ,TO_CHAR(r.date_end, 'dd.mm.yyyy')
        INTO l_begin_date
            ,l_end_date
        FROM ins_dwh.rep_ref r
       WHERE r.id_rep_ref = p_rep_ref_id;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<?xml version="1.0" encoding="windows-1251" ?>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<company id="3398" kind="stat" period="' || l_end_date || '">');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<attributes date="' || l_begin_date || '">');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<name>Общество с ограниченной ответственностью Страховая компания "ВТБ Страхование"</name>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<shortname>OOO СК "ВТБ Страхование"</shortname>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<shortname>OOO СК "ВТБ Страхование"</shortname>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<okpo>14255577</okpo>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<okved>66</okved>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<okonh>96200</okonh>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<okato>45286565000</okato>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<okopf>90</okopf>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<okfs>16</okfs>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<code>02</code>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<address>101000,Россия, г. Москва, пл. Тургеневская,д.2/4,1</address>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<phone>580-73-33</phone>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<kinds>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<free_personal>1</free_personal>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<free_estate>1</free_estate>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<free_responsibility>1</free_responsibility>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<strict_not_medical>0</strict_not_medical>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<strict_medical>0</strict_medical>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<reinsurance>1</reinsurance>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<avto>1</avto>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</kinds>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</attributes>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<general>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<head>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<name></name> ');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<position></position> ');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</head>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<assistant>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<name></name>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<position></position>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</assistant>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<account>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<sign_date />');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</account>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</general>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</company>');
    current_row_id := current_row_id + 1;
  
    RETURN new_tmp_xml_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END export_2C_0_xml;

  FUNCTION export_2C_6_xml
  (
    p_rep_ref_id NUMBER
   ,p_ct         VARCHAR2
  ) RETURN NUMBER
  /*
    TODO: owner="SKushenko" category="Fix" priority="3 - Low" created="08.05.2008"
    text="1. Занести параметр ""company id"" в систему  (базу данных)
          2. Брать этот параметр из базы"
    */
   AS
    new_tmp_xml_id NUMBER;
    current_row_id NUMBER;
    l_end_date     VARCHAR2(10);
  BEGIN
    current_row_id := 1;
  
    BEGIN
      SELECT SQ_TMP_TXT.NEXTVAL INTO new_tmp_xml_id FROM dual;
      SELECT TO_CHAR(r.date_end, 'dd.mm.yyyy')
        INTO l_end_date
        FROM ins_dwh.rep_ref r
       WHERE r.id_rep_ref = p_rep_ref_id;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    /*<?xml version="1.0" encoding="windows-1251" ?>
      <company id="6666" kind="stat" period="11.11.2111"›
          <part id="6">
    */
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id, current_row_id, '<?xml version="1.0" encoding="windows-1251" ?>');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT
      (ID, ROW_ID, TEXT)
    VALUES
      (new_tmp_xml_id
      ,current_row_id
      ,'<company id="3398" kind="stat" period="' || l_end_date || '">');
    current_row_id := current_row_id + 1;
  
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<part id="6">');
    current_row_id := current_row_id + 1;
  
    -- 6.5 (кроме 6.5.13)
    IF p_ct LIKE '6.5.%'
       AND p_ct <> '6.5.13'
    THEN
    
      INSERT INTO TMP_TXT
        (ID, ROW_ID, TEXT)
      VALUES
        (new_tmp_xml_id, current_row_id, '<list id="' || TRIM(SUBSTR(p_ct, 3, 20)) || '">');
      current_row_id := current_row_id + 1;
    
      FOR rec IN (SELECT *
                    FROM ins_dwh.rep_grid g
                   WHERE g.rep_ref_id = p_rep_ref_id
                     AND g.ct = p_ct
                     AND UPPER(g.c1) <> 'ИТОГО'
                   ORDER BY g.C1)
      LOOP
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<item>');
        current_row_id := current_row_id + 1;
      
        IF rec.c1 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="1">' || TRIM(rec.c1) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c2 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="2">' || TRIM(rec.c2) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c3 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="3">' || TRIM(rec.c3) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c4 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="4">' || TRIM(rec.c4) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c5 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="5">' || TRIM(rec.c5) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c6 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="6">' || TRIM(rec.c6) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c7 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="7">' || TRIM(rec.c7) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c8 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="8">' || TRIM(rec.c8) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</item>');
        current_row_id := current_row_id + 1;
      END LOOP;
    
      -- Summery
      FOR rec IN (SELECT *
                    FROM ins_dwh.rep_grid g
                   WHERE g.rep_ref_id = p_rep_ref_id
                     AND g.ct = p_ct
                     AND UPPER(g.c1) = 'ИТОГО'
                   ORDER BY g.C1)
      LOOP
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<summary>');
        current_row_id := current_row_id + 1;
      
        IF rec.c2 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="2">' || TRIM(rec.c2) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c3 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="3">' || TRIM(rec.c3) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c4 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="4">' || TRIM(rec.c4) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c5 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="5">' || TRIM(rec.c5) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c6 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="6">' || TRIM(rec.c6) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c7 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="7">' || TRIM(rec.c7) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c8 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="8">' || TRIM(rec.c8) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</summary>');
        current_row_id := current_row_id + 1;
      
      END LOOP;
    
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</list>');
      current_row_id := current_row_id + 1;
    END IF;
  
    -- Все кроме 6.5
    IF p_ct LIKE '6.%'
       AND p_ct NOT LIKE '6.5%'
       AND p_ct <> '6.4'
    THEN
      INSERT INTO TMP_TXT
        (ID, ROW_ID, TEXT)
      VALUES
        (new_tmp_xml_id, current_row_id, '<table id="' || TRIM(SUBSTR(p_ct, 3, 20)) || '">');
      current_row_id := current_row_id + 1;
      FOR rec IN (SELECT *
                    FROM ins_dwh.rep_grid g
                   WHERE g.rep_ref_id = p_rep_ref_id
                     AND g.ct = p_ct
                   ORDER BY g.C2)
      LOOP
        INSERT INTO TMP_TXT
          (ID, ROW_ID, TEXT)
        VALUES
          (new_tmp_xml_id, current_row_id, '<line id="' || rec.c2 || '">');
        current_row_id := current_row_id + 1;
      
        IF rec.c3 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="3">' || TRIM(rec.c3) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c4 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="4">' || TRIM(rec.c4) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c5 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="5">' || TRIM(rec.c5) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c6 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="6">' || TRIM(rec.c6) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c7 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="7">' || TRIM(rec.c7) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c8 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="8">' || TRIM(rec.c8) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c9 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="9">' || TRIM(rec.c9) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c10 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="10">' || TRIM(rec.c10) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c11 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="11">' || TRIM(rec.c11) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c12 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="12">' || TRIM(rec.c12) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c13 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="13">' || TRIM(rec.c13) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c14 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="14">' || TRIM(rec.c14) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c15 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="15">' || TRIM(rec.c15) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c16 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="16">' || TRIM(rec.c16) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c17 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="17">' || TRIM(rec.c17) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c18 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="18">' || TRIM(rec.c18) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c19 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="19">' || TRIM(rec.c19) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c20 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="20">' || TRIM(rec.c20) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c21 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="21">' || TRIM(rec.c21) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c22 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="22">' || TRIM(rec.c22) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c23 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="23">' || TRIM(rec.c23) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c24 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="24">' || TRIM(rec.c24) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c25 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="25">' || TRIM(rec.c25) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c26 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="26">' || TRIM(rec.c26) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c27 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="27">' || TRIM(rec.c27) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c28 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="28">' || TRIM(rec.c28) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</line>');
        current_row_id := current_row_id + 1;
      END LOOP;
    
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</table>');
      current_row_id := current_row_id + 1;
    
    END IF;
  
    --  6.5.13 (Смешанная таблица)
    IF p_ct = '6.5.13'
    THEN
    
      --- list --- list --- list --- list --- list ------------------------------------------  
      INSERT INTO TMP_TXT
        (ID, ROW_ID, TEXT)
      VALUES
        (new_tmp_xml_id, current_row_id, '<list id="5.13">');
      current_row_id := current_row_id + 1;
    
      FOR rec IN (SELECT *
                    FROM ins_dwh.rep_grid g
                   WHERE g.rep_ref_id = p_rep_ref_id
                     AND g.ct = p_ct
                     AND SUBSTR(g.c1, 1, 1) IN ('1', '2')
                   ORDER BY g.C1)
      LOOP
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '<item>');
        current_row_id := current_row_id + 1;
      
        IF rec.c1 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="1">' || TRIM(rec.c1) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c2 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="2">' || TRIM(rec.c2) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c3 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="3">' || TRIM(rec.c3) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c4 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="4">' || TRIM(rec.c4) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c5 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="5">' || TRIM(rec.c5) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c6 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="6">' || TRIM(rec.c6) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c7 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="7">' || TRIM(rec.c7) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c8 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="8">' || TRIM(rec.c8) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c9 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="9">' || TRIM(rec.c9) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c10 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="10">' || TRIM(rec.c10) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c11 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="11">' || TRIM(rec.c11) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c12 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="12">' || TRIM(rec.c12) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c13 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="13">' || TRIM(rec.c13) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c14 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="14">' || TRIM(rec.c14) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c15 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="15">' || TRIM(rec.c15) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c16 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="16">' || TRIM(rec.c16) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c17 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="17">' || TRIM(rec.c17) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c18 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="18">' || TRIM(rec.c18) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c19 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="19">' || TRIM(rec.c19) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c20 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="20">' || TRIM(rec.c20) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c21 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="21">' || TRIM(rec.c21) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c22 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="22">' || TRIM(rec.c22) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c23 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="23">' || TRIM(rec.c23) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c24 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="24">' || TRIM(rec.c24) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c25 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="25">' || TRIM(rec.c25) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c26 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="26">' || TRIM(rec.c26) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c27 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="27">' || TRIM(rec.c27) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c28 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="28">' || TRIM(rec.c28) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c29 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="29">' || TRIM(rec.c29) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</item>');
        current_row_id := current_row_id + 1;
      
      END LOOP;
    
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</list>');
      current_row_id := current_row_id + 1;
      --- list --- list --- list --- list --- list -------------------------------------------   
    
      ---- table ---- table ---- table ---- table -------------------------------------     
      /* Исправил 5.13r -> 6.5.13r (для корректной работы программы ОСТ) */
      INSERT INTO TMP_TXT
        (ID, ROW_ID, TEXT)
      VALUES
        (new_tmp_xml_id, current_row_id, '<table id="6.5.13r">');
      current_row_id := current_row_id + 1;
    
      FOR rec IN (SELECT *
                    FROM ins_dwh.rep_grid g
                   WHERE g.rep_ref_id = p_rep_ref_id
                     AND g.ct = p_ct
                     AND SUBSTR(g.c1, 1, 1) NOT IN ('1', '2')
                   ORDER BY TO_NUMBER(g.C2))
      LOOP
        INSERT INTO TMP_TXT
          (ID, ROW_ID, TEXT)
        VALUES
          (new_tmp_xml_id, current_row_id, '<line id="' || rec.c2 || '">');
        current_row_id := current_row_id + 1;
      
        IF rec.c3 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="3">' || TRIM(rec.c3) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c4 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="4">' || TRIM(rec.c4) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c5 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="5">' || TRIM(rec.c5) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c6 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="6">' || TRIM(rec.c6) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c7 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="7">' || TRIM(rec.c7) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c8 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="8">' || TRIM(rec.c8) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c9 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="9">' || TRIM(rec.c9) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c10 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="10">' || TRIM(rec.c10) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c11 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="11">' || TRIM(rec.c11) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c12 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="12">' || TRIM(rec.c12) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c13 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="13">' || TRIM(rec.c13) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c14 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="14">' || TRIM(rec.c14) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c15 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="15">' || TRIM(rec.c15) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c16 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="16">' || TRIM(rec.c16) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c17 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="17">' || TRIM(rec.c17) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c18 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="18">' || TRIM(rec.c18) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c19 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="19">' || TRIM(rec.c19) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c20 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="20">' || TRIM(rec.c20) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c21 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="21">' || TRIM(rec.c21) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c22 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="22">' || TRIM(rec.c22) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c23 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="23">' || TRIM(rec.c23) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c24 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="24">' || TRIM(rec.c24) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c25 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="25">' || TRIM(rec.c25) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c26 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="26">' || TRIM(rec.c26) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c27 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="27">' || TRIM(rec.c27) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c28 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="28">' || TRIM(rec.c28) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        IF rec.c29 IS NOT NULL
        THEN
          INSERT INTO TMP_TXT
            (ID, ROW_ID, TEXT)
          VALUES
            (new_tmp_xml_id, current_row_id, '<col id="29">' || TRIM(rec.c29) || '</col>');
          current_row_id := current_row_id + 1;
        END IF;
      
        INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</line>');
        current_row_id := current_row_id + 1;
      END LOOP;
    
      INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</table>');
      current_row_id := current_row_id + 1;
    
      ---- table ---- table ---- table ---- table -----------------------------------------------
    END IF; -- 6.5.13
  
    /* </part>
     </company>
    */
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</part>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '</company>');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, '   ');
    current_row_id := current_row_id + 1;
    INSERT INTO TMP_TXT (ID, ROW_ID, TEXT) VALUES (new_tmp_xml_id, current_row_id, CHR(13));
  
    --current_row_id := current_row_id + 1;
  
    RETURN new_tmp_xml_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END export_2C_6_xml;

  FUNCTION export_2C_65_txt
  (
    p_rep_ref_id NUMBER
   ,p_ct         VARCHAR2
  ) RETURN NUMBER AS
  BEGIN
    /*
    TODO: owner="SKushenko" created="15.05.2008"
    text="Реализовать выгрузку в упращенном (промежуточном) формате с разделителем через TAB для последующей загрузки в программу ГСО "
    */
    RETURN NULL;
  END;

END;
/

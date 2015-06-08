CREATE OR REPLACE PACKAGE process_vip_data AS
  /******************************************************************************
     NAME:       Process_VIP_Date
     PURPOSE: Prepare xml files for BI2BI
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        25.05.2010             1. Created this package.
  ******************************************************************************/
  FUNCTION preparedata RETURN NUMBER;

  PROCEDURE writeblobtofile
  (
    i_xml_file_id IN NUMBER
   ,i_filename    IN VARCHAR2
  );

  FUNCTION extract_all_data RETURN NUMBER;
END process_vip_data;
/
CREATE OR REPLACE PACKAGE BODY process_vip_data AS
  /******************************************************************************
     NAME:       Process_VIP_Data
     PURPOSE:
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        25.05.2010             1. Created this package body.
  ******************************************************************************/
  FUNCTION preparedata RETURN NUMBER AS
  BEGIN
    DELETE FROM ins_dwh.t_xml_doc;
  
    /*
      Байтин А.
      Добавил временные таблицы, чтобы быстрее отбирались данные,
      заменил на них представления
    */
  
    DELETE FROM ins_dwh.cbnt_contact_tmp;
    DELETE FROM ins_dwh.cbnt_policy_tmp;
    DELETE FROM ins_dwh.cbnt_payment_tmp;
  
    dbms_application_info.set_client_info('INSERT INTO INS_DWH.CBNT_CONTACT_TMP');
    INSERT INTO ins_dwh.cbnt_contact_tmp
      (insured_id, insured_name, email, vip_card, gender, login_name, pwd)
      SELECT insured_id
            ,insured_name
            ,email
            ,vip_card
            ,gender
            ,login_name
            ,pwd
        FROM ins_dwh.v_cbnt_contact;
  
    dbms_application_info.set_client_info('INSERT INTO INS_DWH.CBNT_POLICY_TMP');
    INSERT INTO ins_dwh.cbnt_policy_tmp
      (policy_id
      ,insured_id
      ,product_name
      ,product_brief
      ,pol_num
      ,date_begin
      ,date_end
      ,policy_header_id
      ,payment_term
      ,fund
      ,status
      ,agent_id
      ,agency_id
      ,fee
      ,fee_index
      ,debt_sum
      ,agent_name
      ,agency_name
      ,agency_address
      ,agency_phone
      ,indexing_persent
      ,invest_income
      ,decline_date
      ,decline_reason
      ,due_date
      ,last_ver_policy_id
      ,last_ver_status)
      SELECT policy_id
            ,insured_id
            ,product_name
            ,product_brief
            ,pol_num
            ,date_begin
            ,date_end
            ,policy_header_id
            ,payment_term
            ,fund
            ,status
            ,agent_id
            ,agency_id
            ,fee
            ,fee_index
            ,debt_sum
            ,agent_name
            ,agency_name
            ,agency_address
            ,agency_phone
            ,indexing_persent
            ,invest_income
            ,decline_date
            ,decline_reason
            ,due_date
            ,last_ver_policy_id
            ,last_ver_status
        FROM ins_dwh.v_cbnt_policy;
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'CBNT_POLICY_TMP');
  
    dbms_application_info.set_client_info('INSERT INTO INS_DWH.CBNT_PAYMENT_TMP');
    INSERT INTO INS_DWH.CBNT_PAYMENT_TMP
      (payment_id
      ,policy_id
      ,due_date
      ,grace_date
      ,epg_amount
      ,pay_date
      ,epg_amount_rur
      ,epg_status
      ,index_fee
      ,debt_sum
      ,epg_status_brief
      ,pol_header_id)
      SELECT payment_id
            ,policy_id
            ,due_date
            ,grace_date
            ,epg_amount
            ,pay_date
            ,epg_amount_rur
            ,epg_status
            ,index_fee
            ,debt_sum
            ,epg_status_brief
            ,pol_header_id
        FROM ins_dwh.v_cbnt_payment;
  
    dbms_stats.gather_table_stats(ownname => 'INS_DWH', tabname => 'CBNT_PAYMENT_TMP');
  
    MERGE INTO ins_dwh.cbnt_payment_tmp trg
    USING (SELECT /*+ USE_NL(pt pp) */
            row_number() over(PARTITION BY pt.pol_header_id ORDER BY to_date(pt.grace_date, 'dd.mm.yyyy')) AS payment_num
           ,pt.rowid AS rid
             FROM ins_dwh.cbnt_payment_tmp pt) src
    ON (trg.rowid = src.rid)
    WHEN MATCHED THEN
      UPDATE SET trg.payment_num = src.payment_num;
  
    dbms_application_info.set_client_info('INSERT INTO INS_DWH.T_XML_DOC');
    INSERT INTO ins_dwh.t_xml_doc
      (t_xml_doc_id, doc_name, doc_data, doc_num, doc_date)
      SELECT 1
            ,'insured'
            ,XMLTYPE(CURSOR (SELECT insured_id
                                  ,insured_name
                                  ,email
                                  ,vip_card
                                  ,gender
                                  ,login_name
                                  ,pwd
                              FROM ins_dwh.cbnt_contact_tmp)).getclobval()
            ,1
            ,SYSDATE
        FROM DUAL
      UNION ALL
      SELECT 2
            ,'policy'
            ,XMLTYPE(CURSOR (SELECT policy_id
                                  ,insured_id
                                  ,product_name
                                  ,product_brief
                                  ,pol_num
                                  ,date_begin
                                  ,date_end
                                  ,policy_header_id
                                  ,payment_term
                                  ,fund
                                  ,status
                                  ,agent_id
                                  ,agency_id
                                  ,fee
                                  ,fee_index
                                  ,debt_sum
                                  ,agent_name
                                  ,agency_name
                                  ,agency_address
                                  ,agency_phone
                                  ,indexing_persent
                                  ,invest_income
                                  ,due_date
                                  ,decline_date
                                  ,decline_reason
                              FROM ins_dwh.cbnt_policy_tmp pp)).getclobval()
            ,2
            ,SYSDATE
        FROM DUAL
      UNION ALL
      SELECT 3
            ,'payment'
            ,XMLTYPE(CURSOR (SELECT payment_id
                                  ,policy_id
                                  ,due_date
                                  ,grace_date
                                  ,epg_amount
                                  ,pay_date
                                  ,epg_amount_rur
                                  ,epg_status
                                  ,epg_status_brief
                                  ,index_fee
                                  ,debt_sum
                              FROM INS_DWH.CBNT_PAYMENT_TMP)).getclobval()
            ,3
            ,SYSDATE
        FROM DUAL
      UNION ALL
      SELECT 4
            ,'cover'
            ,XMLTYPE(CURSOR (SELECT p_cover_id
                                  ,policy_id
                                  ,date_begin
                                  ,date_end
                                  ,insurance_sum
                                  ,fee
                                  ,cover_type_name
                                  ,annual
                                  ,loan
                                  ,loan AS invest_part
                                  ,net_premium_act
                                  ,delta_deposit1
                                  ,penalty
                                  ,payment_sign
                              FROM ins_dwh.v_cbnt_cover)).getclobval()
            ,4
            ,SYSDATE
        FROM DUAL;
  
    COMMIT;
    RETURN 0;
    /*EXCEPTION
    when others then
    ROLLBACK;
    RETURN 1;*/
  END preparedata;

  FUNCTION convertclobtoblob(p_clob IN CLOB) RETURN BLOB IS
    --      v_len      NUMBER;
    v_offset NUMBER := 1;
    --      v_str      VARCHAR2 (32767);
    v_blob BLOB;
    --      v_buffer   PLS_INTEGER      := 32767;
    v_lang_context INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
  BEGIN
    DBMS_LOB.createtemporary(v_blob, TRUE);
  
    /*      FOR i IN 1 .. CEIL (DBMS_LOB.getlength (p_clob) / v_buffer)
          LOOP
             v_str := DBMS_LOB.SUBSTR (p_clob, 32767, v_offset);
             v_len := UTL_RAW.LENGTH (UTL_RAW.cast_to_raw (v_str));
             DBMS_LOB.append (v_blob, UTL_RAW.cast_to_raw (v_str));
             v_offset := v_offset + v_len;
          END LOOP;
    */
  
    DBMS_LOB.CONVERTTOBLOB(dest_lob     => v_blob
                          ,src_clob     => p_clob
                          ,amount       => DBMS_LOB.LOBMAXSIZE
                          ,dest_offset  => v_offset
                          ,src_offset   => v_offset
                          ,blob_csid    => NLS_CHARSET_ID('UTF8')
                          ,lang_context => v_lang_context
                          ,warning      => v_warning);
  
    RETURN(v_blob);
  END convertclobtoblob;

  PROCEDURE writeblobtofile
  (
    i_xml_file_id IN NUMBER
   ,i_filename    IN VARCHAR2
  ) AS
    v_blob        BLOB;
    v_clob        CLOB;
    blob_length   INTEGER;
    out_file      UTL_FILE.file_type;
    v_buffer      RAW(32767);
    chunk_size    BINARY_INTEGER := 32767;
    blob_position INTEGER := 1;
  BEGIN
    -- Retrieve the BLOB for reading
    SELECT doc_data INTO v_clob FROM t_xml_doc WHERE t_xml_doc_id = i_xml_file_id;
  
    v_blob := convertclobtoblob(v_clob);
    -- Retrieve the SIZE of the BLOB
    blob_length := DBMS_LOB.getlength(v_blob);
    -- Open a handle to the location where you are going to write the BLOB to file
    -- NOTE: The 'wb' parameter means "write in byte mode" and is only availabe
    --       in the UTL_FILE package with Oracle 10g or later
    out_file := UTL_FILE.fopen('EXPDP_EDU', i_filename, 'wb', chunk_size);
  
    -- Write the BLOB to file in chunks
    WHILE blob_position <= blob_length
    LOOP
      IF blob_position + chunk_size - 1 > blob_length
      THEN
        chunk_size := blob_length - blob_position + 1;
      END IF;
    
      DBMS_LOB.READ(v_blob, chunk_size, blob_position, v_buffer);
      UTL_FILE.put_raw(out_file, v_buffer, TRUE);
      blob_position := blob_position + chunk_size;
    END LOOP;
  
    -- Close the file handle
    UTL_FILE.fclose(out_file);
  END writeblobtofile;

  FUNCTION extract_all_data RETURN NUMBER AS
  BEGIN
    FOR l_cur_row IN (SELECT t_xml_doc_id
                            ,doc_name
                        FROM ins_dwh.t_xml_doc)
    LOOP
      writeblobtofile(l_cur_row.t_xml_doc_id, l_cur_row.doc_name || '.xml');
    END LOOP;
  
    RETURN 0;
  END extract_all_data;
END process_vip_data;
/

CREATE OR REPLACE TRIGGER trg_stored_files_aiu
  AFTER INSERT OR UPDATE ON stored_files
  FOR EACH ROW
DECLARE
  v_httpdocpath_brief VARCHAR2(3200);
  v_sitename          VARCHAR(3200);
  v_url               VARCHAR(3200);
  v_file_found_on_as  BOOLEAN;
  v_blob              BLOB;
BEGIN
  BEGIN
    SELECT TRIM(def_value_c) INTO v_sitename FROM app_param WHERE brief = 'SITENAME';
    SELECT TRIM(def_value_c)
      INTO v_httpdocpath_brief
      FROM app_param
     WHERE brief = 'HTTPDOCPATH_BRIEF';
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Загрузка  невозможна - не  определены  параметры хранения  документов');
  END;
  v_url := v_sitename || v_httpdocpath_brief || TRIM(:new.file_stored_name);
  IF updating
  THEN
    DELETE FROM stored_files_body WHERE stored_files_body_id = :new.stored_files_id;
  END IF;
  BEGIN
    v_blob             := httpuritype(v_url).getblob();
    v_file_found_on_as := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      v_file_found_on_as := FALSE;
  END;

  IF v_file_found_on_as
  THEN
    INSERT INTO stored_files_body
      (stored_files_body_id, stored_fb, store_date)
      SELECT :new.stored_files_id stored_files_id
            ,v_blob               stored_fb
            ,SYSDATE
        FROM dual;
  END IF;
END;
/

CREATE OR REPLACE FUNCTION getClobDocument
(
  filename IN VARCHAR2
 ,charset  IN VARCHAR2 DEFAULT NULL
) RETURN CLOB DETERMINISTIC IS
  file        BFILE := bfilename('XMLDIR', filename);
  charContent CLOB := ' ';
  targetFile  BFILE;
  lang_ctx    NUMBER := DBMS_LOB.default_lang_ctx;
  charset_id  NUMBER := 0;
  src_offset  NUMBER := 1;
  dst_offset  NUMBER := 1;
  warning     NUMBER;
BEGIN
  IF charset IS NOT NULL
  THEN
    charset_id := NLS_CHARSET_ID(charset);
  END IF;
  targetFile := file;
  DBMS_LOB.fileopen(targetFile, DBMS_LOB.file_readonly);
  DBMS_LOB.LOADCLOBFROMFILE(charContent
                           ,targetFile
                           ,DBMS_LOB.getLength(targetFile)
                           ,src_offset
                           ,dst_offset
                           ,charset_id
                           ,lang_ctx
                           ,warning);
  DBMS_LOB.fileclose(targetFile);
  RETURN charContent;
END;
/

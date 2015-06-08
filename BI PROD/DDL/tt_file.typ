CREATE OR REPLACE TYPE tt_file AS OBJECT
(
-- Author  : PAVEL.KAPLYA
-- Created : 12.05.2014 13:13:44
-- Purpose : Тип хранения файла

-- Attributes
  filename  VARCHAR2(1000),
  content   BLOB,
  mime_type VARCHAR2(1000),

-- Member functions and procedures
  CONSTRUCTOR FUNCTION tt_file
  (
    par_filename  VARCHAR2
   ,par_content   BLOB
   ,par_mime_type VARCHAR2 DEFAULT NULL
  ) RETURN SELF AS RESULT,

  MEMBER PROCEDURE update_mime_type,

  STATIC FUNCTION get_mime_type(par_file_name_or_ext VARCHAR2) RETURN VARCHAR2
)
NOT FINAL;
/
CREATE OR REPLACE TYPE BODY tt_file IS
  -- Member functions and procedures
  CONSTRUCTOR FUNCTION tt_file
  (
    par_filename  VARCHAR2
   ,par_content   BLOB
   ,par_mime_type VARCHAR2 DEFAULT NULL
  ) RETURN SELF AS RESULT IS
  BEGIN
  
    self.filename := par_filename;
    self.content  := par_content;
  
    IF par_mime_type IS NOT NULL
    THEN
      self.mime_type := par_mime_type;
    ELSE
      update_mime_type;
    
    END IF;
  
    RETURN;
  END tt_file;

  MEMBER PROCEDURE update_mime_type IS
  BEGIN
    self.mime_type := tt_file.get_mime_type(self.filename);
  END update_mime_type;

  STATIC FUNCTION get_mime_type(par_file_name_or_ext VARCHAR2) RETURN VARCHAR2 IS
    v_extension VARCHAR2(50);
    v_mime_type VARCHAR2(100);
  BEGIN
    IF (par_file_name_or_ext IS NULL)
    THEN
      v_mime_type := NULL;
    ELSE
      -- Get extension (passing -1 to INSTR searches backwards from end of str)
      IF instr(par_file_name_or_ext, '.') != 0
      THEN
        v_extension := lower(substr(par_file_name_or_ext, instr(par_file_name_or_ext, '.', -1) + 1));
      ELSE
        v_extension := lower(par_file_name_or_ext);
      END IF;
    
      IF (v_extension IN ('txt', 'log', 'ora', 'lst', 'sql', 'out', 'bat', 'ini'))
      THEN
        v_mime_type := 'text/plain';
      ELSIF v_extension = 'csv'
      THEN
        v_mime_type := 'text/csv';
      ELSIF v_extension = 'tsv'
      THEN
        v_mime_type := 'text/tab-separated-values';
      ELSIF (v_extension IN ('xls', 'prn', 'dif'))
      THEN
        v_mime_type := 'application/vnd.ms-excel';
      ELSIF (v_extension IN ('docx'))
      THEN
        v_mime_type := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      ELSIF (v_extension IN ('ppsx'))
      THEN
        v_mime_type := 'application/vnd.openxmlformats-officedocument.presentationml.slideshow';
      ELSIF (v_extension IN ('pptx'))
      THEN
        v_mime_type := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      ELSIF (v_extension IN ('xlsx'))
      THEN
        v_mime_type := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      ELSIF (v_extension IN ('htm', 'html'))
      THEN
        v_mime_type := 'text/html';
      ELSIF (v_extension = 'xml')
      THEN
        v_mime_type := 'text/xml';
      ELSIF (v_extension IN ('doc', 'asc', 'ans'))
      THEN
        v_mime_type := 'application/msword';
      ELSIF (v_extension = ('rtf'))
      THEN
        v_mime_type := 'text/rtf';
      ELSIF (v_extension = ('zip'))
      THEN
        v_mime_type := 'application/zip';
      ELSIF (v_extension = ('gif'))
      THEN
        v_mime_type := 'image/gif';
      ELSIF (v_extension IN ('jpeg', 'jpg'))
      THEN
        v_mime_type := 'image/jpeg';
      ELSIF (v_extension = 'pdf')
      THEN
        v_mime_type := 'application/pdf';
        -- below are less frequently used as attachments
      ELSIF (v_extension = 'css')
      THEN
        v_mime_type := 'text/css';
      ELSIF (v_extension = 'gtar')
      THEN
        v_mime_type := 'application/x-gtar';
      ELSIF (v_extension = 'gz')
      THEN
        v_mime_type := 'application/x-gzip';
      ELSIF (v_extension = 'js')
      THEN
        v_mime_type := 'application/x-javascript';
      ELSIF (v_extension = 'png')
      THEN
        v_mime_type := 'image/png';
      ELSIF (v_extension = 'tar')
      THEN
        v_mime_type := 'application/x-tar';
      ELSIF (v_extension IN ('tif', 'tiff'))
      THEN
        v_mime_type := 'image/tiff';
      ELSIF (v_extension = 'svg')
      THEN
        v_mime_type := 'image/svg+xml';
      ELSIF (v_extension = 'dat')
      THEN
        v_mime_type := 'application/octet-stream';
      ELSIF (v_extension = 'mdb')
      THEN
        v_mime_type := 'application/x-msaccess';
      ELSIF (v_extension = 'sxw')
      THEN
        v_mime_type := 'application/vnd.sun.xml.writer';
      ELSIF (v_extension = 'sxc')
      THEN
        v_mime_type := 'application/vnd.sun.xml.calc';
      ELSIF (v_extension = 'sxi')
      THEN
        v_mime_type := 'application/vnd.sun.xml.impress';
      ELSIF (v_extension = 'sxd')
      THEN
        v_mime_type := 'application/vnd.sun.xml.draw';
      ELSIF (v_extension = 'sxm')
      THEN
        v_mime_type := 'application/vnd.sun.xml.math';
      ELSIF (v_extension = 'odt')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.text';
      ELSIF (v_extension = 'oth')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.text-web';
      ELSIF (v_extension = 'odg')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.graphics';
      ELSIF (v_extension = 'odp')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.presentation';
      ELSIF (v_extension = 'ods')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.spreadsheet';
      ELSIF (v_extension = 'odb')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.database';
      ELSIF (v_extension = 'odi')
      THEN
        v_mime_type := 'application/vnd.oasis.opendocument.image';
      ELSE
        v_mime_type := 'application/octet-stream';
      END IF;
    END IF;
  
    RETURN v_mime_type;
  
  END get_mime_type;
END;
/

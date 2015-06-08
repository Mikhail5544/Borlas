CREATE OR REPLACE PACKAGE pkg_zip IS
  /**********************************************
  **
  ** Author: Anton Scheffer
  ** Date: 25-01-2012
  ** Website: http://technology.amis.nl/blog
  **
  ** Changelog:
  **   Date: 29-04-2012
  **    fixed bug for large uncompressed files, thanks Morten Braten
  **   Date: 21-03-2012
  **     Take CRC32, compressed length and uncompressed length from
  **     Central file header instead of Local file header
  **   Date: 17-02-2012
  **     Added more support for non-ascii filenames
  **   Date: 25-01-2012
  **     Added MIT-license
  **     Some minor improvements
  **   Date: 31-01-2014
  **     file limit increased to 4GB
  ******************************************************************************
  ******************************************************************************
  Copyright (C) 2010,2011 by Anton Scheffer
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  
  ******************************************************************************
  ******************************************** */
  TYPE file_list IS TABLE OF CLOB;
  --
  FUNCTION file2blob
  (
    p_dir       VARCHAR2
   ,p_file_name VARCHAR2
  ) RETURN BLOB;
  --
  FUNCTION get_file_list
  (
    p_dir      VARCHAR2
   ,p_zip_file VARCHAR2
   ,p_encoding VARCHAR2 := NULL
  ) RETURN file_list;
  --
  FUNCTION get_file_list
  (
    p_zipped_blob BLOB
   ,p_encoding    VARCHAR2 := NULL
  ) RETURN file_list;
  --
  FUNCTION get_file
  (
    p_dir       VARCHAR2
   ,p_zip_file  VARCHAR2
   ,p_file_name VARCHAR2
   ,p_encoding  VARCHAR2 := NULL
  ) RETURN BLOB;
  --
  FUNCTION get_file
  (
    p_zipped_blob BLOB
   ,p_file_name   VARCHAR2
   ,p_encoding    VARCHAR2 := NULL
  ) RETURN BLOB;
  --
  PROCEDURE add1file
  (
    p_zipped_blob IN OUT BLOB
   ,p_name        VARCHAR2
   ,p_content     BLOB
  );
  --
  PROCEDURE finish_zip(p_zipped_blob IN OUT BLOB);
  --
  PROCEDURE save_zip
  (
    p_zipped_blob BLOB
   ,p_dir         VARCHAR2 := 'MY_DIR'
   ,p_filename    VARCHAR2 := 'my.zip'
  );
  --
/*
declare
  g_zipped_blob blob;
begin
  as_zip.add1file( g_zipped_blob, 'test4.txt', null ); -- a empty file
  as_zip.add1file( g_zipped_blob, 'dir1/test1.txt', utl_raw.cast_to_raw( q'<A file with some more text, stored in a subfolder which isn't added>' ) );
  as_zip.add1file( g_zipped_blob, 'test1234.txt', utl_raw.cast_to_raw( 'A small file' ) );
  as_zip.add1file( g_zipped_blob, 'dir2/', null ); -- a folder
  as_zip.add1file( g_zipped_blob, 'dir3/', null ); -- a folder
  as_zip.add1file( g_zipped_blob, 'dir3/test2.txt', utl_raw.cast_to_raw( 'A small filein a previous created folder' ) );
  as_zip.finish_zip( g_zipped_blob );
  as_zip.save_zip( g_zipped_blob, 'MY_DIR', 'my.zip' );
  dbms_lob.freetemporary( g_zipped_blob );
end;
--
declare
  zip_files as_zip.file_list;
begin
  zip_files  := as_zip.get_file_list( 'MY_DIR', 'my.zip' );
  for i in zip_files.first() .. zip_files.last
  loop
    dbms_output.put_line( zip_files( i ) );
    dbms_output.put_line( utl_raw.cast_to_varchar2( as_zip.get_file( 'MY_DIR', 'my.zip', zip_files( i ) ) ) );
  end loop;
end;
*/
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_zip IS
  --
  c_local_file_header        CONSTANT RAW(4) := hextoraw('504B0304'); -- Local file header signature
  c_end_of_central_directory CONSTANT RAW(4) := hextoraw('504B0506'); -- End of central directory signature
  --
  FUNCTION blob2num
  (
    p_blob BLOB
   ,p_len  INTEGER
   ,p_pos  INTEGER
  ) RETURN NUMBER IS
    rv NUMBER;
  BEGIN
    rv := utl_raw.cast_to_binary_integer(dbms_lob.substr(p_blob, p_len, p_pos), utl_raw.little_endian);
    IF rv < 0
    THEN
      rv := rv + 4294967296;
    END IF;
    RETURN rv;
  END;
  --
  FUNCTION raw2varchar2
  (
    p_raw      RAW
   ,p_encoding VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN coalesce(utl_i18n.raw_to_char(p_raw, p_encoding)
                   ,utl_i18n.raw_to_char(p_raw
                                        ,utl_i18n.map_charset(p_encoding
                                                             ,utl_i18n.generic_context
                                                             ,utl_i18n.iana_to_oracle)));
  END;
  --
  FUNCTION little_endian
  (
    p_big   NUMBER
   ,p_bytes PLS_INTEGER := 4
  ) RETURN RAW IS
    t_big NUMBER := p_big;
  BEGIN
    IF t_big > 2147483647
    THEN
      t_big := t_big - 4294967296;
    END IF;
    RETURN utl_raw.substr(utl_raw.cast_from_binary_integer(t_big, utl_raw.little_endian), 1, p_bytes);
  END;
  --
  FUNCTION file2blob
  (
    p_dir       VARCHAR2
   ,p_file_name VARCHAR2
  ) RETURN BLOB IS
    file_lob  BFILE;
    file_blob BLOB;
  BEGIN
    file_lob := bfilename(p_dir, p_file_name);
    dbms_lob.open(file_lob, dbms_lob.file_readonly);
    dbms_lob.createtemporary(file_blob, TRUE);
    dbms_lob.loadfromfile(file_blob, file_lob, dbms_lob.lobmaxsize);
    dbms_lob.close(file_lob);
    RETURN file_blob;
  EXCEPTION
    WHEN OTHERS THEN
      IF dbms_lob.isopen(file_lob) = 1
      THEN
        dbms_lob.close(file_lob);
      END IF;
      IF dbms_lob.istemporary(file_blob) = 1
      THEN
        dbms_lob.freetemporary(file_blob);
      END IF;
      RAISE;
  END;
  --
  FUNCTION get_file_list
  (
    p_zipped_blob BLOB
   ,p_encoding    VARCHAR2 := NULL
  ) RETURN file_list IS
    t_ind      INTEGER;
    t_hd_ind   INTEGER;
    t_rv       file_list;
    t_encoding VARCHAR2(32767);
  BEGIN
    t_ind := dbms_lob.getlength(p_zipped_blob) - 21;
    LOOP
      EXIT WHEN t_ind < 1 OR dbms_lob.substr(p_zipped_blob, 4, t_ind) = c_end_of_central_directory;
      t_ind := t_ind - 1;
    END LOOP;
    --
    IF t_ind <= 0
    THEN
      RETURN NULL;
    END IF;
    --
    t_hd_ind := blob2num(p_zipped_blob, 4, t_ind + 16) + 1;
    t_rv     := file_list();
    t_rv.extend(blob2num(p_zipped_blob, 2, t_ind + 10));
    FOR i IN 1 .. blob2num(p_zipped_blob, 2, t_ind + 8)
    LOOP
      IF p_encoding IS NULL
      THEN
        IF utl_raw.bit_and(dbms_lob.substr(p_zipped_blob, 1, t_hd_ind + 9), hextoraw('08')) =
           hextoraw('08')
        THEN
          t_encoding := 'AL32UTF8'; -- utf8
        ELSE
          t_encoding := 'US8PC437'; -- IBM codepage 437
        END IF;
      ELSE
        t_encoding := p_encoding;
      END IF;
      t_rv(i) := raw2varchar2(dbms_lob.substr(p_zipped_blob
                                             ,blob2num(p_zipped_blob, 2, t_hd_ind + 28)
                                             ,t_hd_ind + 46)
                             ,t_encoding);
      t_hd_ind := t_hd_ind + 46 + blob2num(p_zipped_blob, 2, t_hd_ind + 28) -- File name length
                  + blob2num(p_zipped_blob, 2, t_hd_ind + 30) -- Extra field length
                  + blob2num(p_zipped_blob, 2, t_hd_ind + 32); -- File comment length
    END LOOP;
    --
    RETURN t_rv;
  END;
  --
  FUNCTION get_file_list
  (
    p_dir      VARCHAR2
   ,p_zip_file VARCHAR2
   ,p_encoding VARCHAR2 := NULL
  ) RETURN file_list IS
  BEGIN
    RETURN get_file_list(file2blob(p_dir, p_zip_file), p_encoding);
  END;
  --
  FUNCTION get_file
  (
    p_zipped_blob BLOB
   ,p_file_name   VARCHAR2
   ,p_encoding    VARCHAR2 := NULL
  ) RETURN BLOB IS
    t_tmp      BLOB;
    t_ind      INTEGER;
    t_hd_ind   INTEGER;
    t_fl_ind   INTEGER;
    t_encoding VARCHAR2(32767);
    t_len      INTEGER;
  BEGIN
    t_ind := dbms_lob.getlength(p_zipped_blob) - 21;
    LOOP
      EXIT WHEN t_ind < 1 OR dbms_lob.substr(p_zipped_blob, 4, t_ind) = c_end_of_central_directory;
      t_ind := t_ind - 1;
    END LOOP;
    --
    IF t_ind <= 0
    THEN
      RETURN NULL;
    END IF;
    --
    t_hd_ind := blob2num(p_zipped_blob, 4, t_ind + 16) + 1;
    FOR i IN 1 .. blob2num(p_zipped_blob, 2, t_ind + 8)
    LOOP
      IF p_encoding IS NULL
      THEN
        IF utl_raw.bit_and(dbms_lob.substr(p_zipped_blob, 1, t_hd_ind + 9), hextoraw('08')) =
           hextoraw('08')
        THEN
          t_encoding := 'AL32UTF8'; -- utf8
        ELSE
          t_encoding := 'US8PC437'; -- IBM codepage 437
        END IF;
      ELSE
        t_encoding := p_encoding;
      END IF;
      IF p_file_name = raw2varchar2(dbms_lob.substr(p_zipped_blob
                                                   ,blob2num(p_zipped_blob, 2, t_hd_ind + 28)
                                                   ,t_hd_ind + 46)
                                   ,t_encoding)
      THEN
        t_len := blob2num(p_zipped_blob, 4, t_hd_ind + 24); -- uncompressed length
        IF t_len = 0
        THEN
          IF substr(p_file_name, -1) IN ('/', '\')
          THEN
            -- directory/folder
            RETURN NULL;
          ELSE
            -- empty file
            RETURN empty_blob();
          END IF;
        END IF;
        --
        IF dbms_lob.substr(p_zipped_blob, 2, t_hd_ind + 10) = hextoraw('0800') -- deflate
        THEN
          t_fl_ind := blob2num(p_zipped_blob, 4, t_hd_ind + 42);
          t_tmp    := hextoraw('1F8B0800000000000003'); -- gzip header
          dbms_lob.copy(t_tmp
                       ,p_zipped_blob
                       ,blob2num(p_zipped_blob, 4, t_hd_ind + 20)
                       ,11
                       ,t_fl_ind + 31 + blob2num(p_zipped_blob, 2, t_fl_ind + 27) -- File name length
                        + blob2num(p_zipped_blob, 2, t_fl_ind + 29) -- Extra field length
                        );
          dbms_lob.append(t_tmp
                         ,utl_raw.concat(dbms_lob.substr(p_zipped_blob, 4, t_hd_ind + 16) -- CRC32
                                        ,little_endian(t_len) -- uncompressed length
                                         ));
          RETURN utl_compress.lz_uncompress(t_tmp);
        END IF;
        --
        IF dbms_lob.substr(p_zipped_blob, 2, t_hd_ind + 10) = hextoraw('0000') -- The file is stored (no compression)
        THEN
          t_fl_ind := blob2num(p_zipped_blob, 4, t_hd_ind + 42);
          dbms_lob.createtemporary(t_tmp, TRUE);
          dbms_lob.copy(t_tmp
                       ,p_zipped_blob
                       ,t_len
                       ,1
                       ,t_fl_ind + 31 + blob2num(p_zipped_blob, 2, t_fl_ind + 27) -- File name length
                        + blob2num(p_zipped_blob, 2, t_fl_ind + 29) -- Extra field length
                        );
          RETURN t_tmp;
        END IF;
      END IF;
      t_hd_ind := t_hd_ind + 46 + blob2num(p_zipped_blob, 2, t_hd_ind + 28) -- File name length
                  + blob2num(p_zipped_blob, 2, t_hd_ind + 30) -- Extra field length
                  + blob2num(p_zipped_blob, 2, t_hd_ind + 32); -- File comment length
    END LOOP;
    --
    RETURN NULL;
  END;
  --
  FUNCTION get_file
  (
    p_dir       VARCHAR2
   ,p_zip_file  VARCHAR2
   ,p_file_name VARCHAR2
   ,p_encoding  VARCHAR2 := NULL
  ) RETURN BLOB IS
  BEGIN
    RETURN get_file(file2blob(p_dir, p_zip_file), p_file_name, p_encoding);
  END;
  --
  PROCEDURE add1file
  (
    p_zipped_blob IN OUT BLOB
   ,p_name        VARCHAR2
   ,p_content     BLOB
  ) IS
    t_now        DATE;
    t_blob       BLOB;
    t_len        INTEGER;
    t_clen       INTEGER;
    t_crc32      RAW(4) := hextoraw('00000000');
    t_compressed BOOLEAN := FALSE;
    t_name       RAW(32767);
  BEGIN
    t_now := SYSDATE;
    t_len := nvl(dbms_lob.getlength(p_content), 0);
    IF t_len > 0
    THEN
      t_blob       := utl_compress.lz_compress(p_content);
      t_clen       := dbms_lob.getlength(t_blob) - 18;
      t_compressed := t_clen < t_len;
      t_crc32      := dbms_lob.substr(t_blob, 4, t_clen + 11);
    END IF;
    IF NOT t_compressed
    THEN
      t_clen := t_len;
      t_blob := p_content;
    END IF;
    IF p_zipped_blob IS NULL
    THEN
      dbms_lob.createtemporary(p_zipped_blob, TRUE);
    END IF;
    t_name := utl_i18n.string_to_raw(p_name, 'AL32UTF8');
    dbms_lob.append(p_zipped_blob
                   ,utl_raw.concat(c_local_file_header -- Local file header signature
                                  ,hextoraw('1400') -- version 2.0
                                  ,CASE WHEN t_name = utl_i18n.string_to_raw(p_name, 'US8PC437') THEN
                                   hextoraw('0000') -- no General purpose bits
                                   ELSE hextoraw('0008') -- set Language encoding flag (EFS)
                                   END
                                  ,CASE WHEN t_compressed THEN hextoraw('0800') -- deflate
                                   ELSE hextoraw('0000') -- stored
                                   END
                                  ,little_endian(to_number(to_char(t_now, 'ss')) / 2 +
                                                 to_number(to_char(t_now, 'mi')) * 32 +
                                                 to_number(to_char(t_now, 'hh24')) * 2048
                                                ,2) -- File last modification time
                                  ,little_endian(to_number(to_char(t_now, 'dd')) +
                                                 to_number(to_char(t_now, 'mm')) * 32 +
                                                 (to_number(to_char(t_now, 'yyyy')) - 1980) * 512
                                                ,2) -- File last modification date
                                  ,t_crc32 -- CRC-32
                                  ,little_endian(t_clen) -- compressed size
                                  ,little_endian(t_len) -- uncompressed size
                                  ,little_endian(utl_raw.length(t_name), 2) -- File name length
                                  ,hextoraw('0000') -- Extra field length
                                  ,t_name -- File name
                                   ));
    IF t_compressed
    THEN
      dbms_lob.copy(p_zipped_blob, t_blob, t_clen, dbms_lob.getlength(p_zipped_blob) + 1, 11); -- compressed content
    ELSIF t_clen > 0
    THEN
      dbms_lob.copy(p_zipped_blob, t_blob, t_clen, dbms_lob.getlength(p_zipped_blob) + 1, 1); --  content
    END IF;
    IF dbms_lob.istemporary(t_blob) = 1
    THEN
      dbms_lob.freetemporary(t_blob);
    END IF;
  END;
  --
  PROCEDURE finish_zip(p_zipped_blob IN OUT BLOB) IS
    t_cnt             PLS_INTEGER := 0;
    t_offs            INTEGER;
    t_offs_dir_header INTEGER;
    t_offs_end_header INTEGER;
    t_comment         RAW(32767) := utl_raw.cast_to_raw('Implementation by Anton Scheffer');
  BEGIN
    t_offs_dir_header := dbms_lob.getlength(p_zipped_blob);
    t_offs            := 1;
    WHILE dbms_lob.substr(p_zipped_blob, utl_raw.length(c_local_file_header), t_offs) =
          c_local_file_header
    LOOP
      t_cnt := t_cnt + 1;
      dbms_lob.append(p_zipped_blob
                     ,utl_raw.concat(hextoraw('504B0102') -- Central directory file header signature
                                    ,hextoraw('1400') -- version 2.0
                                    ,dbms_lob.substr(p_zipped_blob, 26, t_offs + 4)
                                    ,hextoraw('0000') -- File comment length
                                    ,hextoraw('0000') -- Disk number where file starts
                                    ,hextoraw('0000') -- Internal file attributes =>
                                     --     0000 binary file
                                     --     0100 (ascii)text file
                                    ,CASE WHEN dbms_lob.substr(p_zipped_blob
                                                    ,1
                                                    ,t_offs + 30 +
                                                     blob2num(p_zipped_blob, 2, t_offs + 26) - 1) IN
                                     (hextoraw('2F') -- /
                                    ,hextoraw('5C') -- \
                                      ) THEN hextoraw('10000000') -- a directory/folder
                                     ELSE hextoraw('2000B681') -- a file
                                     END -- External file attributes
                                    ,little_endian(t_offs - 1) -- Relative offset of local file header
                                    ,dbms_lob.substr(p_zipped_blob
                                                    ,blob2num(p_zipped_blob, 2, t_offs + 26)
                                                    ,t_offs + 30) -- File name
                                     ));
      t_offs := t_offs + 30 + blob2num(p_zipped_blob, 4, t_offs + 18) -- compressed size
                + blob2num(p_zipped_blob, 2, t_offs + 26) -- File name length
                + blob2num(p_zipped_blob, 2, t_offs + 28); -- Extra field length
    END LOOP;
    t_offs_end_header := dbms_lob.getlength(p_zipped_blob);
    dbms_lob.append(p_zipped_blob
                   ,utl_raw.concat(c_end_of_central_directory -- End of central directory signature
                                  ,hextoraw('0000') -- Number of this disk
                                  ,hextoraw('0000') -- Disk where central directory starts
                                  ,little_endian(t_cnt, 2) -- Number of central directory records on this disk
                                  ,little_endian(t_cnt, 2) -- Total number of central directory records
                                  ,little_endian(t_offs_end_header - t_offs_dir_header) -- Size of central directory
                                  ,little_endian(t_offs_dir_header) -- Offset of start of central directory, relative to start of archive
                                  ,little_endian(nvl(utl_raw.length(t_comment), 0), 2) -- ZIP file comment length
                                  ,t_comment));
  END;
  --
  PROCEDURE save_zip
  (
    p_zipped_blob BLOB
   ,p_dir         VARCHAR2 := 'MY_DIR'
   ,p_filename    VARCHAR2 := 'my.zip'
  ) IS
    t_fh  utl_file.file_type;
    t_len PLS_INTEGER := 32767;
  BEGIN
    t_fh := utl_file.fopen(p_dir, p_filename, 'wb');
    FOR i IN 0 .. trunc((dbms_lob.getlength(p_zipped_blob) - 1) / t_len)
    LOOP
      utl_file.put_raw(t_fh, dbms_lob.substr(p_zipped_blob, t_len, i * t_len + 1));
    END LOOP;
    utl_file.fclose(t_fh);
  END;
  --
END;
/

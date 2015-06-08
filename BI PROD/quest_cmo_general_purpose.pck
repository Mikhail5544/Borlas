CREATE OR REPLACE PACKAGE quest_cmo_general_purpose AS
  FUNCTION extract_file_name(file_with_directory IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION convert_size
  (
    value_in  NUMBER
   ,from_unit VARCHAR2
   ,to_unit   VARCHAR2
  ) RETURN NUMBER;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- types used for after (DML) triggers to avoid "mutating table" error
  TYPE rowid_array IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  modified_rows_rowid rowid_array;

  TYPE pk_id_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  modified_rows_pk pk_id_array;
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
END quest_cmo_general_purpose;
/
CREATE OR REPLACE PACKAGE BODY quest_cmo_general_purpose AS
  FUNCTION extract_file_name(file_with_directory IN VARCHAR2) RETURN VARCHAR2 IS
    file_name_start PLS_INTEGER;
  BEGIN
    -- assumptions: file will be either
    -- a) UNIX file name /directory1/directory2/filename.dat
    -- b) Windows file name C:\directory1\directory2\filename.dat
    -- c) VMS file name NODE::DISK:[DIRECTORY1.DIRECTORY2]filename.dat
    --               or LOGICAL:filename.dat
    --  I will look for these delimiters: /, \, ], :
    file_name_start := instr(file_with_directory, '/', -1, 1);
    IF file_name_start = 0
    THEN
      file_name_start := instr(file_with_directory, '\', -1, 1);
    END IF;
    IF file_name_start = 0
    THEN
      file_name_start := instr(file_with_directory, ']', -1, 1);
    END IF;
    IF file_name_start = 0
    THEN
      file_name_start := instr(file_with_directory, ':', -1, 1);
    END IF;
    RETURN substr(file_with_directory, file_name_start + 1);
  END extract_file_name;

  FUNCTION convert_size
  (
    value_in  NUMBER
   ,from_unit VARCHAR2
   ,to_unit   VARCHAR2
  ) RETURN NUMBER IS
    kb NUMBER;
  BEGIN
    IF from_unit = to_unit
    THEN
      RETURN value_in;
    ELSE
      kb := CASE from_unit
              WHEN 'B' THEN
               value_in / 1024
              WHEN 'KB' THEN
               value_in
              WHEN 'MB' THEN
               value_in * 1024
              WHEN 'GB' THEN
               value_in * 1048576
              ELSE
               value_in
            END;
      RETURN CASE to_unit WHEN 'B' THEN kb * 1024 WHEN 'KB' THEN kb WHEN 'MB' THEN kb / 1024 WHEN 'GB' THEN kb / 1048576 ELSE kb END;
    END IF;
  END convert_size;
END quest_cmo_general_purpose;
/

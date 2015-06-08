CREATE OR REPLACE PACKAGE pkg_oracle_exceptions IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 02.10.2013 15:40:10
  -- Purpose : Перечисление ошибок Oracle

  -- Невозможно вставить NULL
  cant_insert_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_insert_null, -01400);

  -- Невозможно заменить на NULL
  cant_update_to_null EXCEPTION;
  PRAGMA EXCEPTION_INIT(cant_update_to_null, -01407);

  -- Нарушено ограничение CHECK
  check_violated EXCEPTION;
  PRAGMA EXCEPTION_INIT(check_violated, -02290);

  -- Нарушено ограничение FOREIGN KEY (parent key not found)
  parent_key_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(parent_key_not_found, -02291);

  -- Год в дате должен быть между -4713 и +9999
  year_in_date_out_of_range EXCEPTION;
  PRAGMA EXCEPTION_INIT(year_in_date_out_of_range, -01841);

  -- Значение превышает предусмотренную полем точность
  value_larger_than_precision EXCEPTION;
  PRAGMA EXCEPTION_INIT(value_larger_than_precision, -01438);

  -- Попытка залочить уже залоченную запись с NOWAIT
  resource_busy_nowait EXCEPTION;
  PRAGMA EXCEPTION_INIT(resource_busy_nowait, -00054);

  -- Ошибка при парсинге XML конструктором XMLTYPE
  xmltype_parse_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(xmltype_parse_error, -31011);

  --ORA-01722: invalid number
  --CAUSE: You executed a SQL statement that tried to convert a string to a number, but it was unsuccessful.
  invalid_number EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_number, -1722);

  --ORA-01847: day of month must be between 1 and last day of month
  --CAUSE: You tried to enter a date value, but you specified a day of the month that is not valid for the specified month.
  day_of_month_our_of_range EXCEPTION;
  PRAGMA EXCEPTION_INIT(day_of_month_our_of_range, -1847);

  --ORA-01861: literal does not match format string
  --CAUSE: You tried to enter a literal with a format string, but the length of the format string was not the same length as the literal.
  literal_does_not_match_format EXCEPTION;
  PRAGMA EXCEPTION_INIT(literal_does_not_match_format, -1861);

  --ORA-01858: a non-numeric character found where a digit was expected
  --CAUSE: You tried to enter a date value using a specified date format, but you entered a non-numeric character where a numeric character was expected.
  not_a_numeric_char EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_a_numeric_char, -1858);

  --ORA-06550: line num, column num: str
  --CAUSE: You tried to execute an invalid block of PLSQL code (like a stored procedure or function), but a compilation error occurred.
  proc_func_doesnt_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(proc_func_doesnt_exists, -06550);

  --ORA-01830: date format picture ends before converting entire input string
  --CAUSE: You tried to enter a date value, but the date entered did not match the date format
  date_format_pic_ends EXCEPTION;
  PRAGMA EXCEPTION_INIT(date_format_pic_ends, -01830);

  --ORA-24381: error(s) in array DML
  --Cause: One or more rows failed in the DML.
  --Action: Refer to the error stack in the error handle.
  bulk_dml EXCEPTION;
  PRAGMA EXCEPTION_INIT(bulk_dml, -24381);

  child_record_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(child_record_found, -02292);

  /*
  ORA-12899: value too large for column string (actual: string, maximum: string)
  Cause: An attempt was made to insert or update a column with a value
  which is too wide for the width of the destination column.
  The name of the column is given, along with the actual width of the value,
  and the maximum allowed width of the column.
  Note that widths are reported in characters
  if character length semantics are in effect for the column,
  otherwise widths are reported in bytes.
  */
  value_too_large_for_column EXCEPTION;
  PRAGMA EXCEPTION_INIT(value_too_large_for_column, -12899);

  c_no_data_found               CONSTANT PLS_INTEGER := 100;
  c_no_data_found2              CONSTANT PLS_INTEGER := -1403;
  c_too_many_rows               CONSTANT PLS_INTEGER := -1422;
  c_dup_val_on_index            CONSTANT PLS_INTEGER := -1;
  c_value_error                 CONSTANT PLS_INTEGER := -6502;
  c_zero_divide                 CONSTANT PLS_INTEGER := -1476;
  c_subscript_beyond_count      CONSTANT PLS_INTEGER := -6533;
  c_subscript_outside_limit     CONSTANT PLS_INTEGER := -6532;
  c_collection_is_null          CONSTANT PLS_INTEGER := -6531;
  c_cursor_already_open         CONSTANT PLS_INTEGER := -6511;
  c_invalid_cursor              CONSTANT PLS_INTEGER := -1001;
  c_access_into_null            CONSTANT PLS_INTEGER := -6530;
  c_case_not_found              CONSTANT PLS_INTEGER := -6592;
  c_self_is_null                CONSTANT PLS_INTEGER := -30625;
  c_rowtype_mismatch            CONSTANT PLS_INTEGER := -6504;
  c_timeout_on_resource         CONSTANT PLS_INTEGER := -51;
  c_login_denied                CONSTANT PLS_INTEGER := -1017;
  c_not_logged_on               CONSTANT PLS_INTEGER := -1012;
  c_program_error               CONSTANT PLS_INTEGER := -6501;
  c_storage_error               CONSTANT PLS_INTEGER := -6500;
  c_sys_invalid_rowid           CONSTANT PLS_INTEGER := -1410;
  c_cant_insert_null            CONSTANT PLS_INTEGER := -01400;
  c_cant_update_to_null         CONSTANT PLS_INTEGER := -01407;
  c_check_violated              CONSTANT PLS_INTEGER := -02290;
  c_parent_key_not_found        CONSTANT PLS_INTEGER := -02291;
  c_year_in_date_out_of_range   CONSTANT PLS_INTEGER := -01841;
  c_value_larger_than_precision CONSTANT PLS_INTEGER := -01438;
  c_resource_busy_nowait        CONSTANT PLS_INTEGER := -00054;
  c_xmltype_parse_error         CONSTANT PLS_INTEGER := -31011;
  c_invalid_number              CONSTANT PLS_INTEGER := -1722;
  c_day_of_month_our_of_range   CONSTANT PLS_INTEGER := -1847;
  c_literal_does_not_match_form CONSTANT PLS_INTEGER := -1861;
  c_not_a_numeric_char          CONSTANT PLS_INTEGER := -1858;
  c_proc_func_doesnt_exists     CONSTANT PLS_INTEGER := -06550;
  c_date_format_pic_ends        CONSTANT PLS_INTEGER := -01830;
  c_bulk_dml                    CONSTANT PLS_INTEGER := -24381;
  c_child_record_found          CONSTANT PLS_INTEGER := -02292;
  c_value_too_large_for_column  CONSTANT PLS_INTEGER := -12899;

END pkg_oracle_exceptions;
/

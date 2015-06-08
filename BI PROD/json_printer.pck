CREATE OR REPLACE PACKAGE json_printer AS
  /*
  Copyright (c) 2010 Jonas Krogsboell
  
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
  */
  indent_string VARCHAR2(10 CHAR) := '  '; --chr(9); for tab
  newline_char  VARCHAR2(2 CHAR) := chr(13) || chr(10); -- Windows style
  --newline_char varchar2(2) := chr(10); -- Mac style
  --newline_char varchar2(2) := chr(13); -- Linux style
  ascii_output   BOOLEAN NOT NULL := FALSE;
  escape_solidus BOOLEAN NOT NULL := FALSE;

  FUNCTION pretty_print
  (
    obj         JSON
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  FUNCTION pretty_print_list
  (
    obj         JSON_LIST
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  FUNCTION pretty_print_any
  (
    json_part   json_value
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2;
  PROCEDURE pretty_print
  (
    obj         JSON
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  );
  PROCEDURE pretty_print_list
  (
    obj         JSON_LIST
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  );
  PROCEDURE pretty_print_any
  (
    json_part   json_value
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  );

  PROCEDURE dbms_output_clob
  (
    my_clob CLOB
   ,delim   VARCHAR2
   ,jsonp   VARCHAR2 DEFAULT NULL
  );
  PROCEDURE htp_output_clob
  (
    my_clob CLOB
   ,jsonp   VARCHAR2 DEFAULT NULL
  );
END json_printer;
/
CREATE OR REPLACE PACKAGE BODY "JSON_PRINTER" AS
  max_line_len NUMBER := 0;
  cur_line_len NUMBER := 0;

  FUNCTION llcheck(str IN VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    --dbms_output.put_line(cur_line_len || ' : '|| str);
    IF (max_line_len > 0 AND length(str) + cur_line_len > max_line_len)
    THEN
      cur_line_len := length(str);
      RETURN newline_char || str;
    ELSE
      cur_line_len := cur_line_len + length(str);
      RETURN str;
    END IF;
  END llcheck;

  FUNCTION escapeString(str VARCHAR2) RETURN VARCHAR2 AS
    sb  VARCHAR2(32767) := '';
    buf VARCHAR2(40);
    num NUMBER;
  BEGIN
    IF (str IS NULL)
    THEN
      RETURN '';
    END IF;
    FOR i IN 1 .. length(str)
    LOOP
      buf := substr(str, i, 1);
      --backspace b = U+0008
      --formfeed  f = U+000C
      --newline   n = U+000A
      --carret    r = U+000D
      --tabulator t = U+0009
      CASE buf
        WHEN chr(8) THEN
          buf := '\b';
        WHEN chr(9) THEN
          buf := '\t';
        WHEN chr(10) THEN
          buf := '\n';
        WHEN chr(13) THEN
          buf := '\f';
        WHEN chr(14) THEN
          buf := '\r';
        WHEN chr(34) THEN
          buf := '\"';
        WHEN chr(47) THEN
          IF (escape_solidus)
          THEN
            buf := '\/';
          END IF;
        WHEN chr(92) THEN
          buf := '\\';
        ELSE
          IF (ascii(buf) < 32)
          THEN
            buf := '\u' || REPLACE(substr(to_char(ascii(buf), 'XXXX'), 2, 4), ' ', '0');
          ELSIF (ascii_output)
          THEN
            buf := REPLACE(asciistr(buf), '\', '\u');
          END IF;
      END CASE;
    
      sb := sb || buf;
    END LOOP;
  
    RETURN sb;
  END escapeString;

  FUNCTION newline(spaces BOOLEAN) RETURN VARCHAR2 AS
  BEGIN
    cur_line_len := 0;
    IF (spaces)
    THEN
      RETURN newline_char;
    ELSE
      RETURN '';
    END IF;
  END;

  /*  function get_schema return varchar2 as
    begin
      return sys_context('userenv', 'current_schema');
    end;  
  */
  FUNCTION tab
  (
    indent NUMBER
   ,spaces BOOLEAN
  ) RETURN VARCHAR2 AS
    i VARCHAR(200) := '';
  BEGIN
    IF (NOT spaces)
    THEN
      RETURN '';
    END IF;
    FOR x IN 1 .. indent
    LOOP
      i := i || indent_string;
    END LOOP;
    RETURN i;
  END;

  FUNCTION getCommaSep(spaces BOOLEAN) RETURN VARCHAR2 AS
  BEGIN
    IF (spaces)
    THEN
      RETURN ', ';
    ELSE
      RETURN ',';
    END IF;
  END;

  FUNCTION getMemName
  (
    mem    json_value
   ,spaces BOOLEAN
  ) RETURN VARCHAR2 AS
  BEGIN
    IF (spaces)
    THEN
      RETURN llcheck('"' || escapeString(mem.mapname) || '"') || llcheck(' : ');
    ELSE
      RETURN llcheck('"' || escapeString(mem.mapname) || '"') || llcheck(':');
    END IF;
  END;

  /* Clob method start here */
  PROCEDURE add_to_clob
  (
    buf_lob IN OUT NOCOPY CLOB
   ,buf_str IN OUT NOCOPY VARCHAR2
   ,str     VARCHAR2
  ) AS
  BEGIN
    IF (lengthb(str) > 32767 - lengthb(buf_str))
    THEN
      --      dbms_lob.append(buf_lob, buf_str);
      dbms_lob.writeappend(buf_lob, length(buf_str), buf_str);
      buf_str := str;
    ELSE
      buf_str := buf_str || str;
    END IF;
  END add_to_clob;

  PROCEDURE flush_clob
  (
    buf_lob IN OUT NOCOPY CLOB
   ,buf_str IN OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    --    dbms_lob.append(buf_lob, buf_str);
    dbms_lob.writeappend(buf_lob, length(buf_str), buf_str);
  END flush_clob;

  PROCEDURE ppObj
  (
    obj     JSON
   ,indent  NUMBER
   ,buf     IN OUT NOCOPY CLOB
   ,spaces  BOOLEAN
   ,buf_str IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE ppEA
  (
    input   JSON_LIST
   ,indent  NUMBER
   ,buf     IN OUT NOCOPY CLOB
   ,spaces  BOOLEAN
   ,buf_str IN OUT NOCOPY VARCHAR2
  ) AS
    elem   json_value;
    arr    json_value_array := input.list_data;
    numbuf VARCHAR2(4000);
  BEGIN
    FOR y IN 1 .. arr.count
    LOOP
      elem := arr(y);
      IF (elem IS NOT NULL)
      THEN
        CASE elem.get_type
          WHEN 'number' THEN
            numbuf := '';
            IF (elem.get_number < 1 AND elem.get_number > 0)
            THEN
              numbuf := '0';
            END IF;
            IF (elem.get_number < 0 AND elem.get_number > -1)
            THEN
              numbuf := '-0';
              numbuf := numbuf ||
                        substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
            ELSE
              numbuf := numbuf || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
            END IF;
            add_to_clob(buf, buf_str, llcheck(numbuf));
          WHEN 'string' THEN
            IF (elem.extended_str IS NOT NULL)
            THEN
              --clob implementation
              add_to_clob(buf
                         ,buf_str
                         ,CASE
                            WHEN elem.num = 1 THEN
                             '"'
                            ELSE
                             '/**/'
                          END);
              DECLARE
                offset NUMBER := 1;
                v_str  VARCHAR(32767);
                amount NUMBER := 32767;
              BEGIN
                WHILE (offset <= dbms_lob.getlength(elem.extended_str))
                LOOP
                  dbms_lob.read(elem.extended_str, amount, offset, v_str);
                  IF (elem.num = 1)
                  THEN
                    add_to_clob(buf, buf_str, escapeString(v_str));
                  ELSE
                    add_to_clob(buf, buf_str, v_str);
                  END IF;
                  offset := offset + amount;
                END LOOP;
              END;
              add_to_clob(buf
                         ,buf_str
                         ,CASE WHEN elem.num = 1 THEN '"' ELSE '/**/' END || newline_char);
            ELSE
              IF (elem.num = 1)
              THEN
                add_to_clob(buf, buf_str, llcheck('"' || escapeString(elem.get_string) || '"'));
              ELSE
                add_to_clob(buf, buf_str, llcheck('/**/' || elem.get_string || '/**/'));
              END IF;
            END IF;
          WHEN 'bool' THEN
            IF (elem.get_bool)
            THEN
              add_to_clob(buf, buf_str, llcheck('true'));
            ELSE
              add_to_clob(buf, buf_str, llcheck('false'));
            END IF;
          WHEN 'null' THEN
            add_to_clob(buf, buf_str, llcheck('null'));
          WHEN 'array' THEN
            add_to_clob(buf, buf_str, llcheck('['));
            ppEA(JSON_LIST(elem), indent, buf, spaces, buf_str);
            add_to_clob(buf, buf_str, llcheck(']'));
          WHEN 'object' THEN
            ppObj(JSON(elem), indent, buf, spaces, buf_str);
          ELSE
            add_to_clob(buf, buf_str, llcheck(elem.get_type));
        END CASE;
      END IF;
      IF (y != arr.count)
      THEN
        add_to_clob(buf, buf_str, llcheck(getCommaSep(spaces)));
      END IF;
    END LOOP;
  END ppEA;

  PROCEDURE ppMem
  (
    mem     json_value
   ,indent  NUMBER
   ,buf     IN OUT NOCOPY CLOB
   ,spaces  BOOLEAN
   ,buf_str IN OUT NOCOPY VARCHAR2
  ) AS
    numbuf VARCHAR2(4000);
  BEGIN
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck(getMemName(mem, spaces)));
    CASE mem.get_type
      WHEN 'number' THEN
        IF (mem.get_number < 1 AND mem.get_number > 0)
        THEN
          numbuf := '0';
        END IF;
        IF (mem.get_number < 0 AND mem.get_number > -1)
        THEN
          numbuf := '-0';
          numbuf := numbuf ||
                    substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
        ELSE
          numbuf := numbuf || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        END IF;
        add_to_clob(buf, buf_str, llcheck(numbuf));
      WHEN 'string' THEN
        IF (mem.extended_str IS NOT NULL)
        THEN
          --clob implementation
          add_to_clob(buf
                     ,buf_str
                     ,CASE
                        WHEN mem.num = 1 THEN
                         '"'
                        ELSE
                         '/**/'
                      END);
          DECLARE
            offset NUMBER := 1;
            v_str  VARCHAR(32767);
            amount NUMBER := 32767;
          BEGIN
            --            dbms_output.put_line('SIZE:'||dbms_lob.getlength(mem.extended_str));
            WHILE (offset <= dbms_lob.getlength(mem.extended_str))
            LOOP
              --            dbms_output.put_line('OFFSET:'||offset);
              --             v_str := dbms_lob.substr(mem.extended_str, 8192, offset);
              dbms_lob.read(mem.extended_str, amount, offset, v_str);
              --            dbms_output.put_line('VSTR_SIZE:'||length(v_str));
              IF (mem.num = 1)
              THEN
                add_to_clob(buf, buf_str, escapeString(v_str));
              ELSE
                add_to_clob(buf, buf_str, v_str);
              END IF;
              offset := offset + amount;
            END LOOP;
          END;
          add_to_clob(buf, buf_str, CASE WHEN mem.num = 1 THEN '"' ELSE '/**/' END || newline_char);
        ELSE
          IF (mem.num = 1)
          THEN
            add_to_clob(buf, buf_str, llcheck('"' || escapeString(mem.get_string) || '"'));
          ELSE
            add_to_clob(buf, buf_str, llcheck('/**/' || mem.get_string || '/**/'));
          END IF;
        END IF;
      WHEN 'bool' THEN
        IF (mem.get_bool)
        THEN
          add_to_clob(buf, buf_str, llcheck('true'));
        ELSE
          add_to_clob(buf, buf_str, llcheck('false'));
        END IF;
      WHEN 'null' THEN
        add_to_clob(buf, buf_str, llcheck('null'));
      WHEN 'array' THEN
        add_to_clob(buf, buf_str, llcheck('['));
        ppEA(JSON_LIST(mem), indent, buf, spaces, buf_str);
        add_to_clob(buf, buf_str, llcheck(']'));
      WHEN 'object' THEN
        ppObj(JSON(mem), indent, buf, spaces, buf_str);
      ELSE
        add_to_clob(buf, buf_str, llcheck(mem.get_type));
    END CASE;
  END ppMem;

  PROCEDURE ppObj
  (
    obj     JSON
   ,indent  NUMBER
   ,buf     IN OUT NOCOPY CLOB
   ,spaces  BOOLEAN
   ,buf_str IN OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    add_to_clob(buf, buf_str, llcheck('{') || newline(spaces));
    FOR m IN 1 .. obj.json_data.count
    LOOP
      ppMem(obj.json_data(m), indent + 1, buf, spaces, buf_str);
      IF (m != obj.json_data.count)
      THEN
        add_to_clob(buf, buf_str, llcheck(',') || newline(spaces));
      ELSE
        add_to_clob(buf, buf_str, newline(spaces));
      END IF;
    END LOOP;
    add_to_clob(buf, buf_str, llcheck(tab(indent, spaces)) || llcheck('}')); -- || chr(13);
  END ppObj;

  PROCEDURE pretty_print
  (
    obj         JSON
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  ) AS
    buf_str VARCHAR2(32767);
    amount  NUMBER := dbms_lob.getlength(buf);
  BEGIN
    IF (erase_clob AND amount > 0)
    THEN
      dbms_lob.trim(buf, 0);
      dbms_lob.erase(buf, amount);
    END IF;
  
    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces, buf_str);
    flush_clob(buf, buf_str);
  END;

  PROCEDURE pretty_print_list
  (
    obj         JSON_LIST
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  ) AS
    buf_str VARCHAR2(32767);
    amount  NUMBER := dbms_lob.getlength(buf);
  BEGIN
    IF (erase_clob AND amount > 0)
    THEN
      dbms_lob.trim(buf, 0);
      dbms_lob.erase(buf, amount);
    END IF;
  
    max_line_len := line_length;
    cur_line_len := 0;
    add_to_clob(buf, buf_str, llcheck('['));
    ppEA(obj, 0, buf, spaces, buf_str);
    add_to_clob(buf, buf_str, llcheck(']'));
    flush_clob(buf, buf_str);
  END;

  PROCEDURE pretty_print_any
  (
    json_part   json_value
   ,spaces      BOOLEAN DEFAULT TRUE
   ,buf         IN OUT NOCOPY CLOB
   ,line_length NUMBER DEFAULT 0
   ,erase_clob  BOOLEAN DEFAULT TRUE
  ) AS
    buf_str VARCHAR2(32767) := '';
    numbuf  VARCHAR2(4000);
    amount  NUMBER := dbms_lob.getlength(buf);
  BEGIN
    IF (erase_clob AND amount > 0)
    THEN
      dbms_lob.trim(buf, 0);
      dbms_lob.erase(buf, amount);
    END IF;
  
    CASE json_part.get_type
      WHEN 'number' THEN
        IF (json_part.get_number < 1 AND json_part.get_number > 0)
        THEN
          numbuf := '0';
        END IF;
        IF (json_part.get_number < 0 AND json_part.get_number > -1)
        THEN
          numbuf := '-0';
          numbuf := numbuf ||
                    substr(to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
        ELSE
          numbuf := numbuf || to_char(json_part.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        END IF;
        add_to_clob(buf, buf_str, numbuf);
      WHEN 'string' THEN
        IF (json_part.extended_str IS NOT NULL)
        THEN
          --clob implementation
          add_to_clob(buf
                     ,buf_str
                     ,CASE
                        WHEN json_part.num = 1 THEN
                         '"'
                        ELSE
                         '/**/'
                      END);
          DECLARE
            offset NUMBER := 1;
            v_str  VARCHAR(32767);
            amount NUMBER := 32767;
          BEGIN
            WHILE (offset <= dbms_lob.getlength(json_part.extended_str))
            LOOP
              dbms_lob.read(json_part.extended_str, amount, offset, v_str);
              IF (json_part.num = 1)
              THEN
                add_to_clob(buf, buf_str, escapeString(v_str));
              ELSE
                add_to_clob(buf, buf_str, v_str);
              END IF;
              offset := offset + amount;
            END LOOP;
          END;
          add_to_clob(buf, buf_str, CASE WHEN json_part.num = 1 THEN '"' ELSE '/**/' END);
        ELSE
          IF (json_part.num = 1)
          THEN
            add_to_clob(buf, buf_str, llcheck('"' || escapeString(json_part.get_string) || '"'));
          ELSE
            add_to_clob(buf, buf_str, llcheck('/**/' || json_part.get_string || '/**/'));
          END IF;
        END IF;
      WHEN 'bool' THEN
        IF (json_part.get_bool)
        THEN
          add_to_clob(buf, buf_str, 'true');
        ELSE
          add_to_clob(buf, buf_str, 'false');
        END IF;
      WHEN 'null' THEN
        add_to_clob(buf, buf_str, 'null');
      WHEN 'array' THEN
        pretty_print_list(JSON_LIST(json_part), spaces, buf, line_length);
        RETURN;
      WHEN 'object' THEN
        pretty_print(JSON(json_part), spaces, buf, line_length);
        RETURN;
      ELSE
        add_to_clob(buf, buf_str, 'unknown type:' || json_part.get_type);
    END CASE;
    flush_clob(buf, buf_str);
  END;

  /* Clob method end here */

  /* Varchar2 method start here */

  PROCEDURE ppObj
  (
    obj    JSON
   ,indent NUMBER
   ,buf    IN OUT NOCOPY VARCHAR2
   ,spaces BOOLEAN
  );

  PROCEDURE ppEA
  (
    input  JSON_LIST
   ,indent NUMBER
   ,buf    IN OUT VARCHAR2
   ,spaces BOOLEAN
  ) AS
    elem json_value;
    arr  json_value_array := input.list_data;
    str  VARCHAR2(400);
  BEGIN
    FOR y IN 1 .. arr.count
    LOOP
      elem := arr(y);
      IF (elem IS NOT NULL)
      THEN
        CASE elem.get_type
          WHEN 'number' THEN
            str := '';
            IF (elem.get_number < 1 AND elem.get_number > 0)
            THEN
              str := '0';
            END IF;
            IF (elem.get_number < 0 AND elem.get_number > -1)
            THEN
              str := '-0' ||
                     substr(to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
            ELSE
              str := str || to_char(elem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
            END IF;
            buf := buf || llcheck(str);
          WHEN 'string' THEN
            IF (elem.num = 1)
            THEN
              buf := buf || llcheck('"' || escapeString(elem.get_string) || '"');
            ELSE
              buf := buf || llcheck('/**/' || elem.get_string || '/**/');
            END IF;
          WHEN 'bool' THEN
            IF (elem.get_bool)
            THEN
              buf := buf || llcheck('true');
            ELSE
              buf := buf || llcheck('false');
            END IF;
          WHEN 'null' THEN
            buf := buf || llcheck('null');
          WHEN 'array' THEN
            buf := buf || llcheck('[');
            ppEA(JSON_LIST(elem), indent, buf, spaces);
            buf := buf || llcheck(']');
          WHEN 'object' THEN
            ppObj(JSON(elem), indent, buf, spaces);
          ELSE
            buf := buf || llcheck(elem.get_type); /* should never happen */
        END CASE;
      END IF;
      IF (y != arr.count)
      THEN
        buf := buf || llcheck(getCommaSep(spaces));
      END IF;
    END LOOP;
  END ppEA;

  PROCEDURE ppMem
  (
    mem    json_value
   ,indent NUMBER
   ,buf    IN OUT NOCOPY VARCHAR2
   ,spaces BOOLEAN
  ) AS
    str VARCHAR2(400) := '';
  BEGIN
    buf := buf || llcheck(tab(indent, spaces)) || getMemName(mem, spaces);
    CASE mem.get_type
      WHEN 'number' THEN
        IF (mem.get_number < 1 AND mem.get_number > 0)
        THEN
          str := '0';
        END IF;
        IF (mem.get_number < 0 AND mem.get_number > -1)
        THEN
          str := '-0' || substr(to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
        ELSE
          str := str || to_char(mem.get_number, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        END IF;
        buf := buf || llcheck(str);
      WHEN 'string' THEN
        IF (mem.num = 1)
        THEN
          buf := buf || llcheck('"' || escapeString(mem.get_string) || '"');
        ELSE
          buf := buf || llcheck('/**/' || mem.get_string || '/**/');
        END IF;
      WHEN 'bool' THEN
        IF (mem.get_bool)
        THEN
          buf := buf || llcheck('true');
        ELSE
          buf := buf || llcheck('false');
        END IF;
      WHEN 'null' THEN
        buf := buf || llcheck('null');
      WHEN 'array' THEN
        buf := buf || llcheck('[');
        ppEA(JSON_LIST(mem), indent, buf, spaces);
        buf := buf || llcheck(']');
      WHEN 'object' THEN
        ppObj(JSON(mem), indent, buf, spaces);
      ELSE
        buf := buf || llcheck(mem.get_type); /* should never happen */
    END CASE;
  END ppMem;

  PROCEDURE ppObj
  (
    obj    JSON
   ,indent NUMBER
   ,buf    IN OUT NOCOPY VARCHAR2
   ,spaces BOOLEAN
  ) AS
  BEGIN
    buf := buf || llcheck('{') || newline(spaces);
    FOR m IN 1 .. obj.json_data.count
    LOOP
      ppMem(obj.json_data(m), indent + 1, buf, spaces);
      IF (m != obj.json_data.count)
      THEN
        buf := buf || llcheck(',') || newline(spaces);
      ELSE
        buf := buf || newline(spaces);
      END IF;
    END LOOP;
    buf := buf || llcheck(tab(indent, spaces)) || llcheck('}'); -- || chr(13);
  END ppObj;

  FUNCTION pretty_print
  (
    obj         JSON
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2 AS
    buf VARCHAR2(32767) := '';
  BEGIN
    max_line_len := line_length;
    cur_line_len := 0;
    ppObj(obj, 0, buf, spaces);
    RETURN buf;
  END pretty_print;

  FUNCTION pretty_print_list
  (
    obj         JSON_LIST
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2 AS
    buf VARCHAR2(32767);
  BEGIN
    max_line_len := line_length;
    cur_line_len := 0;
    buf          := llcheck('[');
    ppEA(obj, 0, buf, spaces);
    buf := buf || llcheck(']');
    RETURN buf;
  END;

  FUNCTION pretty_print_any
  (
    json_part   json_value
   ,spaces      BOOLEAN DEFAULT TRUE
   ,line_length NUMBER DEFAULT 0
  ) RETURN VARCHAR2 AS
    buf VARCHAR2(32767) := '';
  BEGIN
    CASE json_part.get_type
      WHEN 'number' THEN
        IF (json_part.get_number() < 1 AND json_part.get_number() > 0)
        THEN
          buf := buf || '0';
        END IF;
        IF (json_part.get_number() < 0 AND json_part.get_number() > -1)
        THEN
          buf := buf || '-0';
          buf := buf ||
                 substr(to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,'''), 2);
        ELSE
          buf := buf || to_char(json_part.get_number(), 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''');
        END IF;
      WHEN 'string' THEN
        IF (json_part.num = 1)
        THEN
          buf := buf || '"' || escapeString(json_part.get_string) || '"';
        ELSE
          buf := buf || '/**/' || json_part.get_string || '/**/';
        END IF;
      WHEN 'bool' THEN
        IF (json_part.get_bool)
        THEN
          buf := 'true';
        ELSE
          buf := 'false';
        END IF;
      WHEN 'null' THEN
        buf := 'null';
      WHEN 'array' THEN
        buf := pretty_print_list(JSON_LIST(json_part), spaces, line_length);
      WHEN 'object' THEN
        buf := pretty_print(JSON(json_part), spaces, line_length);
      ELSE
        buf := 'weird error: ' || json_part.get_type;
    END CASE;
    RETURN buf;
  END;

  PROCEDURE dbms_output_clob
  (
    my_clob CLOB
   ,delim   VARCHAR2
   ,jsonp   VARCHAR2 DEFAULT NULL
  ) AS
    prev       NUMBER := 1;
    indx       NUMBER := 1;
    size_of_nl NUMBER := lengthb(delim);
    v_str      VARCHAR2(32767);
    amount     NUMBER := 32767;
  BEGIN
    IF (jsonp IS NOT NULL)
    THEN
      dbms_output.put_line(jsonp || '(');
    END IF;
    WHILE (indx != 0)
    LOOP
      --read every line
      indx := dbms_lob.instr(my_clob, delim, prev + 1);
      --     dbms_output.put_line(prev || ' to ' || indx);
    
      IF (indx = 0)
      THEN
        --emit from prev to end;
        amount := 32767;
        --       dbms_output.put_line(' mycloblen ' || dbms_lob.getlength(my_clob));
        LOOP
          dbms_lob.read(my_clob, amount, prev, v_str);
          dbms_output.put_line(v_str);
          prev := prev + amount - 1;
          EXIT WHEN prev >= dbms_lob.getlength(my_clob);
        END LOOP;
      ELSE
        amount := indx - prev;
        IF (amount > 32767)
        THEN
          amount := 32767;
          --          dbms_output.put_line(' mycloblen ' || dbms_lob.getlength(my_clob));
          LOOP
            dbms_lob.read(my_clob, amount, prev, v_str);
            dbms_output.put_line(v_str);
            prev   := prev + amount - 1;
            amount := indx - prev;
            EXIT WHEN prev >= indx - 1;
            IF (amount > 32767)
            THEN
              amount := 32767;
            END IF;
          END LOOP;
          prev := indx + size_of_nl;
        ELSE
          dbms_lob.read(my_clob, amount, prev, v_str);
          dbms_output.put_line(v_str);
          prev := indx + size_of_nl;
        END IF;
      END IF;
    
    END LOOP;
    IF (jsonp IS NOT NULL)
    THEN
      dbms_output.put_line(')');
    END IF;
  
    /*    while (amount != 0) loop
          indx := dbms_lob.instr(my_clob, delim, prev+1);
          
    --      dbms_output.put_line(prev || ' to ' || indx);
          if(indx = 0) then 
            indx := dbms_lob.getlength(my_clob)+1;
          end if;
    
          if(indx-prev > 32767) then
            indx := prev+32767;
          end if;
    --      dbms_output.put_line(prev || ' to ' || indx);
          --substr doesnt work properly on all platforms! (come on oracle - error on Oracle VM for virtualbox)
    --        dbms_output.put_line(dbms_lob.substr(my_clob, indx-prev, prev));
          amount := indx-prev;
    --        dbms_output.put_line('amount'||amount);
          dbms_lob.read(my_clob, amount, prev, v_str);
          dbms_output.put_line(v_str);
          prev := indx+size_of_nl;
          if(amount = 32767) then prev := prev-size_of_nl-1; end if;
        end loop;
        if(jsonp is not null) then dbms_output.put_line(')'); end if;*/
  END;

  /*  procedure dbms_output_clob(my_clob clob, delim varchar2, jsonp varchar2 default null) as 
      prev number := 1;
      indx number := 1;
      size_of_nl number := lengthb(delim);
      v_str varchar2(32767);
      amount number;
    begin
      if(jsonp is not null) then dbms_output.put_line(jsonp||'('); end if;
      while (indx != 0) loop
        indx := dbms_lob.instr(my_clob, delim, prev+1);
        
  --      dbms_output.put_line(prev || ' to ' || indx);
        if(indx-prev > 32767) then
          indx := prev+32767;
        end if;
  --      dbms_output.put_line(prev || ' to ' || indx);
        --substr doesnt work properly on all platforms! (come on oracle - error on Oracle VM for virtualbox)
        if(indx = 0) then 
  --        dbms_output.put_line(dbms_lob.substr(my_clob, dbms_lob.getlength(my_clob)-prev+size_of_nl, prev));
          amount := dbms_lob.getlength(my_clob)-prev+size_of_nl;
          dbms_lob.read(my_clob, amount, prev, v_str);
        else 
  --        dbms_output.put_line(dbms_lob.substr(my_clob, indx-prev, prev));
          amount := indx-prev;
  --        dbms_output.put_line('amount'||amount);
          dbms_lob.read(my_clob, amount, prev, v_str);
        end if;
        dbms_output.put_line(v_str);
        prev := indx+size_of_nl;
        if(amount = 32767) then prev := prev-size_of_nl-1; end if;
      end loop;
      if(jsonp is not null) then dbms_output.put_line(')'); end if;
    end;
  */
  PROCEDURE htp_output_clob
  (
    my_clob CLOB
   ,jsonp   VARCHAR2 DEFAULT NULL
  ) AS
    amount NUMBER := 8192;
    pos    NUMBER := 1;
    len    NUMBER;
  BEGIN
    IF (jsonp IS NOT NULL)
    THEN
      htp.prn(jsonp || '(');
    END IF;
    len := dbms_lob.getlength(my_clob);
    WHILE (pos < len)
    LOOP
      htp.prn(dbms_lob.substr(my_clob, amount, pos)); -- should I replace substr with dbms_lob.read?
      --dbms_output.put_line(dbms_lob.substr(my_clob, amount, pos)); 
      pos := pos + amount;
    END LOOP;
    IF (jsonp IS NOT NULL)
    THEN
      htp.prn(')');
    END IF;
  END;

END json_printer;
/

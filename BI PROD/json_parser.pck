CREATE OR REPLACE PACKAGE json_parser AS
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
  /* scanner tokens:
    '{', '}', ',', ':', '[', ']', STRING, NUMBER, TRUE, FALSE, NULL
  */
  TYPE rToken IS RECORD(
     type_name     VARCHAR2(7)
    ,line          PLS_INTEGER
    ,col           PLS_INTEGER
    ,data          VARCHAR2(32767)
    ,data_overflow CLOB); -- max_string_size

  TYPE lTokens IS TABLE OF rToken INDEX BY PLS_INTEGER;
  TYPE json_src IS RECORD(
     len    NUMBER
    ,offset NUMBER
    ,src    VARCHAR2(32767)
    ,s_clob CLOB);

  json_strict BOOLEAN NOT NULL := FALSE;

  FUNCTION next_char
  (
    indx NUMBER
   ,s    IN OUT NOCOPY json_src
  ) RETURN VARCHAR2;
  FUNCTION next_char2
  (
    indx   NUMBER
   ,s      IN OUT NOCOPY json_src
   ,amount NUMBER DEFAULT 1
  ) RETURN VARCHAR2;

  FUNCTION prepareClob(buf IN CLOB) RETURN json_parser.json_src;
  FUNCTION prepareVarchar2(buf IN VARCHAR2) RETURN json_parser.json_src;
  FUNCTION lexer(jsrc IN OUT NOCOPY json_src) RETURN lTokens;
  PROCEDURE print_token(t rToken);

  FUNCTION parser(str VARCHAR2) RETURN JSON;
  FUNCTION parse_list(str VARCHAR2) RETURN JSON_LIST;
  FUNCTION parse_any(str VARCHAR2) RETURN json_value;
  FUNCTION parser(str CLOB) RETURN JSON;
  FUNCTION parse_list(str CLOB) RETURN JSON_LIST;
  FUNCTION parse_any(str CLOB) RETURN json_value;
  PROCEDURE remove_duplicates(obj IN OUT NOCOPY JSON);
  FUNCTION get_version RETURN VARCHAR2;

END json_parser;
/
CREATE OR REPLACE PACKAGE BODY "JSON_PARSER" AS
  /*
  Copyright (c) 2009 Jonas Krogsboell
  
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

  /*type json_src is record (len number, offset number, src varchar2(10), s_clob clob); */
  FUNCTION next_char
  (
    indx NUMBER
   ,s    IN OUT NOCOPY json_src
  ) RETURN VARCHAR2 AS
  BEGIN
    IF (indx > s.len)
    THEN
      RETURN NULL;
    END IF;
    --right offset?
    IF (indx > 4000 + s.offset OR indx < s.offset)
    THEN
      --load right offset
      s.offset := indx - (indx MOD 4000);
      s.src    := dbms_lob.substr(s.s_clob, 4000, s.offset + 1);
    END IF;
    --read from s.src
    RETURN substr(s.src, indx - s.offset, 1);
  END;

  FUNCTION next_char2
  (
    indx   NUMBER
   ,s      IN OUT NOCOPY json_src
   ,amount NUMBER DEFAULT 1
  ) RETURN VARCHAR2 AS
    buf VARCHAR2(32767) := '';
  BEGIN
    FOR i IN 1 .. amount
    LOOP
      buf := buf || next_char(indx - 1 + i, s);
    END LOOP;
    RETURN buf;
  END;

  FUNCTION prepareClob(buf CLOB) RETURN json_parser.json_src AS
    temp json_parser.json_src;
  BEGIN
    temp.s_clob := buf;
    temp.offset := 0;
    temp.src    := dbms_lob.substr(buf, 4000, temp.offset + 1);
    temp.len    := dbms_lob.getlength(buf);
    RETURN temp;
  END;

  FUNCTION prepareVarchar2(buf VARCHAR2) RETURN json_parser.json_src AS
    temp json_parser.json_src;
  BEGIN
    temp.s_clob := buf;
    temp.offset := 0;
    temp.src    := substr(buf, 1, 4000);
    temp.len    := length(buf);
    RETURN temp;
  END;

  PROCEDURE debug(text VARCHAR2) AS
  BEGIN
    dbms_output.put_line(text);
  END;

  PROCEDURE print_token(t rToken) AS
  BEGIN
    dbms_output.put_line('Line: ' || t.line || ' - Column: ' || t.col || ' - Type: ' || t.type_name ||
                         ' - Content: ' || t.data);
  END print_token;

  /* SCANNER FUNCTIONS START */
  PROCEDURE s_error
  (
    text VARCHAR2
   ,line NUMBER
   ,col  NUMBER
  ) AS
  BEGIN
    raise_application_error(-20100
                           ,'JSON Scanner exception @ line: ' || line || ' column: ' || col || ' - ' || text);
  END;

  PROCEDURE s_error
  (
    text VARCHAR2
   ,tok  rToken
  ) AS
  BEGIN
    raise_application_error(-20100
                           ,'JSON Scanner exception @ line: ' || tok.line || ' column: ' || tok.col ||
                            ' - ' || text);
  END;

  FUNCTION mt
  (
    t VARCHAR2
   ,l PLS_INTEGER
   ,c PLS_INTEGER
   ,d VARCHAR2
  ) RETURN rToken AS
    token rToken;
  BEGIN
    token.type_name := t;
    token.line      := l;
    token.col       := c;
    token.data      := d;
    RETURN token;
  END;

  FUNCTION lexNumber
  (
    jsrc IN OUT NOCOPY json_src
   ,tok  IN OUT NOCOPY rToken
   ,indx IN OUT NOCOPY PLS_INTEGER
  ) RETURN PLS_INTEGER AS
    numbuf    VARCHAR2(4000) := '';
    buf       VARCHAR2(4);
    checkLoop BOOLEAN;
  BEGIN
    buf := next_char(indx, jsrc);
    IF (buf = '-')
    THEN
      numbuf := '-';
      indx   := indx + 1;
    END IF;
    buf := next_char(indx, jsrc);
    --0 or [1-9]([0-9])*
    IF (buf = '0')
    THEN
      numbuf := numbuf || '0';
      indx   := indx + 1;
      buf    := next_char(indx, jsrc);
    ELSIF (buf >= '1' AND buf <= '9')
    THEN
      numbuf := numbuf || buf;
      indx   := indx + 1;
      --read digits
      buf := next_char(indx, jsrc);
      WHILE (buf >= '0' AND buf <= '9')
      LOOP
        numbuf := numbuf || buf;
        indx   := indx + 1;
        buf    := next_char(indx, jsrc);
      END LOOP;
    END IF;
    --fraction
    IF (buf = '.')
    THEN
      numbuf    := numbuf || buf;
      indx      := indx + 1;
      buf       := next_char(indx, jsrc);
      checkLoop := FALSE;
      WHILE (buf >= '0' AND buf <= '9')
      LOOP
        checkLoop := TRUE;
        numbuf    := numbuf || buf;
        indx      := indx + 1;
        buf       := next_char(indx, jsrc);
      END LOOP;
      IF (NOT checkLoop)
      THEN
        s_error('Expected: digits in fraction', tok);
      END IF;
    END IF;
    --exp part
    IF (buf IN ('e', 'E'))
    THEN
      numbuf := numbuf || buf;
      indx   := indx + 1;
      buf    := next_char(indx, jsrc);
      IF (buf = '+' OR buf = '-')
      THEN
        numbuf := numbuf || buf;
        indx   := indx + 1;
        buf    := next_char(indx, jsrc);
      END IF;
      checkLoop := FALSE;
      WHILE (buf >= '0' AND buf <= '9')
      LOOP
        checkLoop := TRUE;
        numbuf    := numbuf || buf;
        indx      := indx + 1;
        buf       := next_char(indx, jsrc);
      END LOOP;
      IF (NOT checkLoop)
      THEN
        s_error('Expected: digits in exp', tok);
      END IF;
    END IF;
  
    tok.data := numbuf;
    RETURN indx;
  END lexNumber;

  -- [a-zA-Z]([a-zA-Z0-9])*
  FUNCTION lexName
  (
    jsrc IN OUT NOCOPY json_src
   ,tok  IN OUT NOCOPY rToken
   ,indx IN OUT NOCOPY PLS_INTEGER
  ) RETURN PLS_INTEGER AS
    varbuf VARCHAR2(32767) := '';
    buf    VARCHAR(4);
    num    NUMBER;
  BEGIN
    buf := next_char(indx, jsrc);
    WHILE (REGEXP_LIKE(buf, '^[[:alnum:]\_]$', 'i'))
    LOOP
      varbuf := varbuf || buf;
      indx   := indx + 1;
      buf    := next_char(indx, jsrc);
      IF (buf IS NULL)
      THEN
        GOTO retname;
        --debug('Premature string ending');
      END IF;
    END LOOP;
    <<retname>>
  
    --could check for reserved keywords here
  
    --debug(varbuf);
    tok.data := varbuf;
    RETURN indx - 1;
  END lexName;

  PROCEDURE updateClob
  (
    v_extended IN OUT NOCOPY CLOB
   ,v_str      VARCHAR2
  ) AS
  BEGIN
    dbms_lob.writeappend(v_extended, length(v_str), v_str);
  END updateClob;

  FUNCTION lexString
  (
    jsrc    IN OUT NOCOPY json_src
   ,tok     IN OUT NOCOPY rToken
   ,indx    IN OUT NOCOPY PLS_INTEGER
   ,endChar CHAR
  ) RETURN PLS_INTEGER AS
    v_extended CLOB := NULL;
    v_count    NUMBER := 0;
    varbuf     VARCHAR2(32767) := '';
    buf        VARCHAR(4);
    wrong      BOOLEAN;
  BEGIN
    indx := indx + 1;
    buf  := next_char(indx, jsrc);
    WHILE (buf != endChar)
    LOOP
      --clob control
      IF (v_count > 8191)
      THEN
        --crazy oracle error (16383 is the highest working length with unistr - 8192 choosen to be safe)
        IF (v_extended IS NULL)
        THEN
          v_extended := empty_clob();
          dbms_lob.createtemporary(v_extended, TRUE);
        END IF;
        updateClob(v_extended, unistr(varbuf));
        varbuf  := '';
        v_count := 0;
      END IF;
      IF (buf = Chr(13) OR buf = CHR(9) OR buf = CHR(10))
      THEN
        s_error('Control characters not allowed (CHR(9),CHR(10)CHR(13))', tok);
      END IF;
      IF (buf = '\')
      THEN
        --varbuf := varbuf || buf;
        indx := indx + 1;
        buf  := next_char(indx, jsrc);
        CASE
          WHEN buf IN ('\') THEN
            varbuf  := varbuf || buf || buf;
            v_count := v_count + 2;
            indx    := indx + 1;
            buf     := next_char(indx, jsrc);
          WHEN buf IN ('"', '/') THEN
            varbuf  := varbuf || buf;
            v_count := v_count + 1;
            indx    := indx + 1;
            buf     := next_char(indx, jsrc);
          WHEN buf = '''' THEN
            IF (json_strict = FALSE)
            THEN
              varbuf  := varbuf || buf;
              v_count := v_count + 1;
              indx    := indx + 1;
              buf     := next_char(indx, jsrc);
            ELSE
              s_error('strictmode - expected: " \ / b f n r t u ', tok);
            END IF;
          WHEN buf IN ('b', 'f', 'n', 'r', 't') THEN
            --backspace b = U+0008
            --formfeed  f = U+000C
            --newline   n = U+000A
            --carret    r = U+000D
            --tabulator t = U+0009
            CASE buf
              WHEN 'b' THEN
                varbuf := varbuf || chr(8);
              WHEN 'f' THEN
                varbuf := varbuf || chr(13);
              WHEN 'n' THEN
                varbuf := varbuf || chr(10);
              WHEN 'r' THEN
                varbuf := varbuf || chr(14);
              WHEN 't' THEN
                varbuf := varbuf || chr(9);
            END CASE;
            --varbuf := varbuf || buf;
            v_count := v_count + 1;
            indx    := indx + 1;
            buf     := next_char(indx, jsrc);
          WHEN buf = 'u' THEN
            --four hexidecimal chars
            DECLARE
              four VARCHAR2(4);
            BEGIN
              four  := next_char2(indx + 1, jsrc, 4);
              wrong := FALSE;
              IF (upper(substr(four, 1, 1)) NOT IN ('0'
                                                   ,'1'
                                                   ,'2'
                                                   ,'3'
                                                   ,'4'
                                                   ,'5'
                                                   ,'6'
                                                   ,'7'
                                                   ,'8'
                                                   ,'9'
                                                   ,'A'
                                                   ,'B'
                                                   ,'C'
                                                   ,'D'
                                                   ,'E'
                                                   ,'F'
                                                   ,'a'
                                                   ,'b'
                                                   ,'c'
                                                   ,'d'
                                                   ,'e'
                                                   ,'f'))
              THEN
                wrong := TRUE;
              END IF;
              IF (upper(substr(four, 2, 1)) NOT IN ('0'
                                                   ,'1'
                                                   ,'2'
                                                   ,'3'
                                                   ,'4'
                                                   ,'5'
                                                   ,'6'
                                                   ,'7'
                                                   ,'8'
                                                   ,'9'
                                                   ,'A'
                                                   ,'B'
                                                   ,'C'
                                                   ,'D'
                                                   ,'E'
                                                   ,'F'
                                                   ,'a'
                                                   ,'b'
                                                   ,'c'
                                                   ,'d'
                                                   ,'e'
                                                   ,'f'))
              THEN
                wrong := TRUE;
              END IF;
              IF (upper(substr(four, 3, 1)) NOT IN ('0'
                                                   ,'1'
                                                   ,'2'
                                                   ,'3'
                                                   ,'4'
                                                   ,'5'
                                                   ,'6'
                                                   ,'7'
                                                   ,'8'
                                                   ,'9'
                                                   ,'A'
                                                   ,'B'
                                                   ,'C'
                                                   ,'D'
                                                   ,'E'
                                                   ,'F'
                                                   ,'a'
                                                   ,'b'
                                                   ,'c'
                                                   ,'d'
                                                   ,'e'
                                                   ,'f'))
              THEN
                wrong := TRUE;
              END IF;
              IF (upper(substr(four, 4, 1)) NOT IN ('0'
                                                   ,'1'
                                                   ,'2'
                                                   ,'3'
                                                   ,'4'
                                                   ,'5'
                                                   ,'6'
                                                   ,'7'
                                                   ,'8'
                                                   ,'9'
                                                   ,'A'
                                                   ,'B'
                                                   ,'C'
                                                   ,'D'
                                                   ,'E'
                                                   ,'F'
                                                   ,'a'
                                                   ,'b'
                                                   ,'c'
                                                   ,'d'
                                                   ,'e'
                                                   ,'f'))
              THEN
                wrong := TRUE;
              END IF;
              IF (wrong)
              THEN
                s_error('expected: " \u([0-9][A-F]){4}', tok);
              END IF;
              --              varbuf := varbuf || buf || four;
              varbuf  := varbuf || '\' || four; --chr(to_number(four,'XXXX'));
              v_count := v_count + 5;
              indx    := indx + 5;
              buf     := next_char(indx, jsrc);
            END;
          ELSE
            s_error('expected: " \ / b f n r t u ', tok);
        END CASE;
      ELSE
        varbuf  := varbuf || buf;
        v_count := v_count + 1;
        indx    := indx + 1;
        buf     := next_char(indx, jsrc);
      END IF;
    END LOOP;
  
    IF (buf IS NULL)
    THEN
      s_error('string ending not found', tok);
      --debug('Premature string ending');
    END IF;
  
    --debug(varbuf);
    --dbms_output.put_line(varbuf);
    IF (v_extended IS NOT NULL)
    THEN
      updateClob(v_extended, unistr(varbuf));
      tok.data_overflow := v_extended;
      tok.data          := dbms_lob.substr(v_extended, 1, 32767);
    ELSE
      tok.data := unistr(varbuf);
    END IF;
    RETURN indx;
  END lexString;

  /* scanner tokens:
    '{', '}', ',', ':', '[', ']', STRING, NUMBER, TRUE, FALSE, NULL
  */
  FUNCTION lexer(jsrc IN OUT NOCOPY json_src) RETURN lTokens AS
    tokens   lTokens;
    indx     PLS_INTEGER := 1;
    tok_indx PLS_INTEGER := 1;
    buf      VARCHAR2(4);
    lin_no   NUMBER := 1;
    col_no   NUMBER := 0;
  BEGIN
    WHILE (indx <= jsrc.len)
    LOOP
      --read into buf
      buf    := next_char(indx, jsrc);
      col_no := col_no + 1;
      --convert to switch case
      CASE
        WHEN buf = '{' THEN
          tokens(tok_indx) := mt('{', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = '}' THEN
          tokens(tok_indx) := mt('}', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = ',' THEN
          tokens(tok_indx) := mt(',', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = ':' THEN
          tokens(tok_indx) := mt(':', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = '[' THEN
          tokens(tok_indx) := mt('[', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = ']' THEN
          tokens(tok_indx) := mt(']', lin_no, col_no, NULL);
          tok_indx := tok_indx + 1;
        WHEN buf = 't' THEN
          IF (next_char2(indx, jsrc, 4) != 'true')
          THEN
            IF (json_strict = FALSE AND REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i'))
            THEN
              tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            ELSE
              s_error('Expected: ''true''', lin_no, col_no);
            END IF;
          ELSE
            tokens(tok_indx) := mt('TRUE', lin_no, col_no, NULL);
            tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          END IF;
        WHEN buf = 'n' THEN
          IF (next_char2(indx, jsrc, 4) != 'null')
          THEN
            IF (json_strict = FALSE AND REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i'))
            THEN
              tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            ELSE
              s_error('Expected: ''null''', lin_no, col_no);
            END IF;
          ELSE
            tokens(tok_indx) := mt('NULL', lin_no, col_no, NULL);
            tok_indx := tok_indx + 1;
            indx := indx + 3;
            col_no := col_no + 3;
          END IF;
        WHEN buf = 'f' THEN
          IF (next_char2(indx, jsrc, 5) != 'false')
          THEN
            IF (json_strict = FALSE AND REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i'))
            THEN
              tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
              indx := lexName(jsrc, tokens(tok_indx), indx);
              col_no := col_no + length(tokens(tok_indx).data) + 1;
              tok_indx := tok_indx + 1;
            ELSE
              s_error('Expected: ''false''', lin_no, col_no);
            END IF;
          ELSE
            tokens(tok_indx) := mt('FALSE', lin_no, col_no, NULL);
            tok_indx := tok_indx + 1;
            indx := indx + 4;
            col_no := col_no + 4;
          END IF;
          /*   -- 9 = TAB, 10 = \n, 13 = \r (Linux = \n, Windows = \r\n, Mac = \r */
        WHEN (buf = Chr(10)) THEN
          --linux newlines
          lin_no := lin_no + 1;
          col_no := 0;
        
        WHEN (buf = Chr(13)) THEN
          --Windows or Mac way
          lin_no := lin_no + 1;
          col_no := 0;
          IF (jsrc.len >= indx + 1)
          THEN
            -- better safe than sorry
            buf := next_char(indx + 1, jsrc);
            IF (buf = Chr(10))
            THEN
              --\r\n
              indx := indx + 1;
            END IF;
          END IF;
        
        WHEN (buf = CHR(9)) THEN
          NULL; --tabbing
        WHEN (buf IN ('-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) THEN
          --number
          tokens(tok_indx) := mt('NUMBER', lin_no, col_no, NULL);
          indx := lexNumber(jsrc, tokens(tok_indx), indx) - 1;
          col_no := col_no + length(tokens(tok_indx).data);
          tok_indx := tok_indx + 1;
        WHEN buf = '"' THEN
          --number
          tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
          indx := lexString(jsrc, tokens(tok_indx), indx, '"');
          col_no := col_no + length(tokens(tok_indx).data) + 1;
          tok_indx := tok_indx + 1;
        WHEN buf = ''''
             AND json_strict = FALSE THEN
          --number
          tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
          indx := lexString(jsrc, tokens(tok_indx), indx, '''');
          col_no := col_no + length(tokens(tok_indx).data) + 1; --hovsa her
          tok_indx := tok_indx + 1;
        WHEN json_strict = FALSE
             AND REGEXP_LIKE(buf, '^[[:alpha:]]$', 'i') THEN
          tokens(tok_indx) := mt('STRING', lin_no, col_no, NULL);
          indx := lexName(jsrc, tokens(tok_indx), indx);
          IF (tokens(tok_indx).data_overflow IS NOT NULL)
          THEN
            col_no := col_no + dbms_lob.getlength(tokens(tok_indx).data_overflow) + 1;
          ELSE
            col_no := col_no + length(tokens(tok_indx).data) + 1;
          END IF;
          tok_indx := tok_indx + 1;
        WHEN json_strict = FALSE
             AND buf || next_char(indx + 1, jsrc) = '/*' THEN
          --strip comments
          DECLARE
            saveindx NUMBER := indx;
            un_esc   CLOB;
          BEGIN
            indx := indx + 1;
            LOOP
              indx := indx + 1;
              buf  := next_char(indx, jsrc) || next_char(indx + 1, jsrc);
              EXIT WHEN buf = '*/';
              EXIT WHEN buf IS NULL;
            END LOOP;
          
            IF (indx = saveindx + 2)
            THEN
              --enter unescaped mode
              --dbms_output.put_line('Entering unescaped mode');
              un_esc := empty_clob();
              dbms_lob.createtemporary(un_esc, TRUE);
              indx := indx + 1;
              LOOP
                indx := indx + 1;
                buf  := next_char(indx, jsrc) || next_char(indx + 1, jsrc) ||
                        next_char(indx + 2, jsrc) || next_char(indx + 3, jsrc);
                EXIT WHEN buf = '/**/';
                IF buf IS NULL
                THEN
                  s_error('Unexpected sequence /**/ to end unescaped data: ' || buf, lin_no, col_no);
                END IF;
                buf := next_char(indx, jsrc);
                dbms_lob.writeappend(un_esc, length(buf), buf);
              END LOOP;
              tokens(tok_indx) := mt('ESTRING', lin_no, col_no, NULL);
              tokens(tok_indx).data_overflow := un_esc;
              col_no := col_no + dbms_lob.getlength(un_esc) + 1; --note: line count won't work properly
              tok_indx := tok_indx + 1;
              indx := indx + 2;
            END IF;
          
            indx := indx + 1;
          END;
        WHEN buf = ' ' THEN
          NULL; --space
        ELSE
          s_error('Unexpected char: ' || buf, lin_no, col_no);
      END CASE;
    
      indx := indx + 1;
    END LOOP;
  
    RETURN tokens;
  END lexer;

  /* SCANNER END */

  /* PARSER FUNCTIONS START*/
  PROCEDURE p_error
  (
    text VARCHAR2
   ,tok  rToken
  ) AS
  BEGIN
    raise_application_error(-20101
                           ,'JSON Parser exception @ line: ' || tok.line || ' column: ' || tok.col ||
                            ' - ' || text);
  END;

  FUNCTION parseObj
  (
    tokens lTokens
   ,indx   IN OUT NOCOPY PLS_INTEGER
  ) RETURN JSON;

  FUNCTION parseArr
  (
    tokens lTokens
   ,indx   IN OUT NOCOPY PLS_INTEGER
  ) RETURN JSON_LIST AS
    e_arr    json_value_array := json_value_array();
    ret_list JSON_LIST := JSON_LIST();
    v_count  NUMBER := 0;
    tok      rToken;
  BEGIN
    --value, value, value ]
    IF (indx > tokens.count)
    THEN
      p_error('more elements in array was excepted', tok);
    END IF;
    tok := tokens(indx);
    WHILE (tok.type_name != ']')
    LOOP
      e_arr.extend;
      v_count := v_count + 1;
      CASE tok.type_name
        WHEN 'TRUE' THEN
          e_arr(v_count) := json_value(TRUE);
        WHEN 'FALSE' THEN
          e_arr(v_count) := json_value(FALSE);
        WHEN 'NULL' THEN
          e_arr(v_count) := json_value;
        WHEN 'STRING' THEN
          e_arr(v_count) := CASE
                              WHEN tok.data_overflow IS NOT NULL THEN
                               json_value(tok.data_overflow)
                              ELSE
                               json_value(tok.data)
                            END;
        WHEN 'ESTRING' THEN
          e_arr(v_count) := json_value(tok.data_overflow, FALSE);
        WHEN 'NUMBER' THEN
          DECLARE
            rev VARCHAR2(10);
          BEGIN
            --stupid countries with , as decimal point
            SELECT VALUE
              INTO rev
              FROM NLS_SESSION_PARAMETERS
             WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
            IF (rev = ',.')
            THEN
              e_arr(v_count) := json_value(to_number(REPLACE(tok.data, '.', ',')));
            ELSE
              e_arr(v_count) := json_value(to_number(tok.data));
            END IF;
          END;
        WHEN '[' THEN
          DECLARE
            e_list JSON_LIST;
          BEGIN
            indx := indx + 1;
            e_list := parseArr(tokens, indx);
            e_arr(v_count) := e_list.to_json_value;
          END;
        WHEN '{' THEN
          indx := indx + 1;
          e_arr(v_count) := parseObj(tokens, indx).to_json_value;
        ELSE
          p_error('Expected a value', tok);
      END CASE;
      indx := indx + 1;
      IF (indx > tokens.count)
      THEN
        p_error('] not found', tok);
      END IF;
      tok := tokens(indx);
      IF (tok.type_name = ',')
      THEN
        --advance
        indx := indx + 1;
        IF (indx > tokens.count)
        THEN
          p_error('more elements in array was excepted', tok);
        END IF;
        tok := tokens(indx);
        IF (tok.type_name = ']')
        THEN
          --premature exit
          p_error('Premature exit in array', tok);
        END IF;
      ELSIF (tok.type_name != ']')
      THEN
        --error
        p_error('Expected , or ]', tok);
      END IF;
    
    END LOOP;
    ret_list.list_data := e_arr;
    RETURN ret_list;
  END parseArr;

  FUNCTION parseMem
  (
    tokens   lTokens
   ,indx     IN OUT PLS_INTEGER
   ,mem_name VARCHAR2
   ,mem_indx NUMBER
  ) RETURN json_value AS
    mem json_value;
    tok rToken;
  BEGIN
    tok := tokens(indx);
    CASE tok.type_name
      WHEN 'TRUE' THEN
        mem := json_value(TRUE);
      WHEN 'FALSE' THEN
        mem := json_value(FALSE);
      WHEN 'NULL' THEN
        mem := json_value;
      WHEN 'STRING' THEN
        mem := CASE
                 WHEN tok.data_overflow IS NOT NULL THEN
                  json_value(tok.data_overflow)
                 ELSE
                  json_value(tok.data)
               END;
      WHEN 'ESTRING' THEN
        mem := json_value(tok.data_overflow, FALSE);
      WHEN 'NUMBER' THEN
        DECLARE
          rev VARCHAR2(10);
        BEGIN
          --stupid countries with , as decimal point - like my own
          SELECT VALUE
            INTO rev
            FROM NLS_SESSION_PARAMETERS
           WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';
          -- Байтин А.
          IF (rev = ',.' OR rev = ', ')
          THEN
            mem := json_value(to_number(REPLACE(tok.data, '.', ',')));
          ELSE
            mem := json_value(to_number(tok.data));
          END IF;
        END;
      WHEN '[' THEN
        DECLARE
          e_list JSON_LIST;
        BEGIN
          indx   := indx + 1;
          e_list := parseArr(tokens, indx);
          mem    := e_list.to_json_value;
        END;
      WHEN '{' THEN
        indx := indx + 1;
        mem  := parseObj(tokens, indx).to_json_value;
      ELSE
        p_error('Found ' || tok.type_name, tok);
    END CASE;
    mem.mapname := mem_name;
    mem.mapindx := mem_indx;
  
    indx := indx + 1;
    RETURN mem;
  END parseMem;

  /*procedure test_duplicate_members(arr in json_member_array, mem_name in varchar2, wheretok rToken) as
  begin
    for i in 1 .. arr.count loop
      if(arr(i).member_name = mem_name) then
        p_error('Duplicate member name', wheretok);
      end if;
    end loop;
  end test_duplicate_members;*/

  FUNCTION parseObj
  (
    tokens lTokens
   ,indx   IN OUT NOCOPY PLS_INTEGER
  ) RETURN JSON AS
    TYPE memmap IS TABLE OF NUMBER INDEX BY VARCHAR2(4000); -- i've read somewhere that this is not possible - but it is!
    mymap         memmap;
    nullelemfound BOOLEAN := FALSE;
  
    obj      JSON;
    tok      rToken;
    mem_name VARCHAR(4000);
    arr      json_value_array := json_value_array();
  BEGIN
    --what to expect?
    WHILE (indx <= tokens.count)
    LOOP
      tok := tokens(indx);
      --debug('E: '||tok.type_name);
      CASE tok.type_name
        WHEN 'STRING' THEN
          --member
          mem_name := substr(tok.data, 1, 4000);
          BEGIN
            IF (mem_name IS NULL)
            THEN
              IF (nullelemfound)
              THEN
                p_error('Duplicate empty member: ', tok);
              ELSE
                nullelemfound := TRUE;
              END IF;
            ELSIF (mymap(mem_name) IS NOT NULL)
            THEN
              p_error('Duplicate member name: ' || mem_name, tok);
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              mymap(mem_name) := 1;
          END;
        
          indx := indx + 1;
          IF (indx > tokens.count)
          THEN
            p_error('Unexpected end of input', tok);
          END IF;
          tok  := tokens(indx);
          indx := indx + 1;
          IF (indx > tokens.count)
          THEN
            p_error('Unexpected end of input', tok);
          END IF;
          IF (tok.type_name = ':')
          THEN
            --parse
            DECLARE
              jmb json_value;
              x   NUMBER;
            BEGIN
              x   := arr.count + 1;
              jmb := parseMem(tokens, indx, mem_name, x);
              arr.extend;
              arr(x) := jmb;
            END;
          ELSE
            p_error('Expected '':''', tok);
          END IF;
          --move indx forward if ',' is found
          IF (indx > tokens.count)
          THEN
            p_error('Unexpected end of input', tok);
          END IF;
        
          tok := tokens(indx);
          IF (tok.type_name = ',')
          THEN
            --debug('found ,');
            indx := indx + 1;
            tok  := tokens(indx);
            IF (tok.type_name = '}')
            THEN
              --premature exit
              p_error('Premature exit in json object', tok);
            END IF;
          ELSIF (tok.type_name != '}')
          THEN
            p_error('A comma seperator is probably missing', tok);
          END IF;
        WHEN '}' THEN
          obj           := JSON();
          obj.json_data := arr;
          RETURN obj;
        ELSE
          p_error('Expected string or }', tok);
      END CASE;
    END LOOP;
  
    p_error('} not found', tokens(indx - 1));
  
    RETURN obj;
  
  END;

  FUNCTION parser(str VARCHAR2) RETURN JSON AS
    tokens lTokens;
    obj    JSON;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    jsrc   := prepareVarchar2(str);
    tokens := lexer(jsrc);
    IF (tokens(indx).type_name = '{')
    THEN
      indx := indx + 1;
      obj  := parseObj(tokens, indx);
    ELSE
      raise_application_error(-20101, 'JSON Parser exception - no { start found');
    END IF;
    IF (tokens.count != indx)
    THEN
      p_error('} should end the JSON object', tokens(indx));
    END IF;
  
    RETURN obj;
  END parser;

  FUNCTION parse_list(str VARCHAR2) RETURN JSON_LIST AS
    tokens lTokens;
    obj    JSON_LIST;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    jsrc   := prepareVarchar2(str);
    tokens := lexer(jsrc);
    IF (tokens(indx).type_name = '[')
    THEN
      indx := indx + 1;
      obj  := parseArr(tokens, indx);
    ELSE
      raise_application_error(-20101, 'JSON List Parser exception - no [ start found');
    END IF;
    IF (tokens.count != indx)
    THEN
      p_error('] should end the JSON List object', tokens(indx));
    END IF;
  
    RETURN obj;
  END parse_list;

  FUNCTION parse_list(str CLOB) RETURN JSON_LIST AS
    tokens lTokens;
    obj    JSON_LIST;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    jsrc   := prepareClob(str);
    tokens := lexer(jsrc);
    IF (tokens(indx).type_name = '[')
    THEN
      indx := indx + 1;
      obj  := parseArr(tokens, indx);
    ELSE
      raise_application_error(-20101, 'JSON List Parser exception - no [ start found');
    END IF;
    IF (tokens.count != indx)
    THEN
      p_error('] should end the JSON List object', tokens(indx));
    END IF;
  
    RETURN obj;
  END parse_list;

  FUNCTION parser(str CLOB) RETURN JSON AS
    tokens lTokens;
    obj    JSON;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    --dbms_output.put_line('Using clob');
    jsrc   := prepareClob(str);
    tokens := lexer(jsrc);
    IF (tokens(indx).type_name = '{')
    THEN
      indx := indx + 1;
      obj  := parseObj(tokens, indx);
    ELSE
      raise_application_error(-20101, 'JSON Parser exception - no { start found');
    END IF;
    IF (tokens.count != indx)
    THEN
      p_error('} should end the JSON object', tokens(indx));
    END IF;
  
    RETURN obj;
  END parser;

  FUNCTION parse_any(str VARCHAR2) RETURN json_value AS
    tokens lTokens;
    obj    JSON_LIST;
    ret    json_value;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    jsrc := prepareVarchar2(str);
    tokens := lexer(jsrc);
    tokens(tokens.count + 1).type_name := ']';
    obj := parseArr(tokens, indx);
    IF (tokens.count != indx)
    THEN
      p_error('] should end the JSON List object', tokens(indx));
    END IF;
  
    RETURN obj.head();
  END parse_any;

  FUNCTION parse_any(str CLOB) RETURN json_value AS
    tokens lTokens;
    obj    JSON_LIST;
    indx   PLS_INTEGER := 1;
    jsrc   json_src;
  BEGIN
    jsrc := prepareClob(str);
    tokens := lexer(jsrc);
    tokens(tokens.count + 1).type_name := ']';
    obj := parseArr(tokens, indx);
    IF (tokens.count != indx)
    THEN
      p_error('] should end the JSON List object', tokens(indx));
    END IF;
  
    RETURN obj.head();
  END parse_any;

  /* last entry is the one to keep */
  PROCEDURE remove_duplicates(obj IN OUT NOCOPY JSON) AS
    TYPE memberlist IS TABLE OF json_value INDEX BY VARCHAR2(4000);
    members       memberlist;
    nulljsonvalue json_value := NULL;
    validated     JSON := JSON();
    indx          VARCHAR2(4000);
  BEGIN
    FOR i IN 1 .. obj.count
    LOOP
      IF (obj.get(i).mapname IS NULL)
      THEN
        nulljsonvalue := obj.get(i);
      ELSE
        members(obj.get(i).mapname) := obj.get(i);
      END IF;
    END LOOP;
  
    validated.check_duplicate(FALSE);
    indx := members.first;
    LOOP
      EXIT WHEN indx IS NULL;
      validated.put(indx, members(indx));
      indx := members.next(indx);
    END LOOP;
    IF (nulljsonvalue IS NOT NULL)
    THEN
      validated.put('', nulljsonvalue);
    END IF;
  
    validated.check_for_duplicate := obj.check_for_duplicate;
  
    obj := validated;
  END;

  FUNCTION get_version RETURN VARCHAR2 AS
  BEGIN
    RETURN 'PL/JSON v1.0.0';
  END get_version;

END json_parser;
/

CREATE OR REPLACE PACKAGE json_ext AS
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

  /* This package contains extra methods to lookup types and
  an easy way of adding date values in json - without changing the structure */
  FUNCTION parsePath
  (
    json_path VARCHAR2
   ,base      NUMBER DEFAULT 1
  ) RETURN JSON_LIST;

  --JSON Path getters
  FUNCTION get_json_value
  (
    obj    JSON
   ,v_path VARCHAR2
   ,base   NUMBER DEFAULT 1
  ) RETURN json_value;
  FUNCTION get_string
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN VARCHAR2;
  FUNCTION get_number
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN NUMBER;
  FUNCTION get_json
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN JSON;
  FUNCTION get_json_list
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN JSON_LIST;
  FUNCTION get_bool
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN BOOLEAN;

  --JSON Path putters
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem VARCHAR2
   ,base NUMBER DEFAULT 1
  );
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem NUMBER
   ,base NUMBER DEFAULT 1
  );
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem JSON
   ,base NUMBER DEFAULT 1
  );
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem JSON_LIST
   ,base NUMBER DEFAULT 1
  );
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem BOOLEAN
   ,base NUMBER DEFAULT 1
  );
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem json_value
   ,base NUMBER DEFAULT 1
  );

  PROCEDURE remove
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  );

  --Pretty print with JSON Path - obsolete in 0.9.4 - obj.path(v_path).(to_char,print,htp)
  FUNCTION pp
  (
    obj    JSON
   ,v_path VARCHAR2
  ) RETURN VARCHAR2;
  PROCEDURE pp
  (
    obj    JSON
   ,v_path VARCHAR2
  ); --using dbms_output.put_line
  PROCEDURE pp_htp
  (
    obj    JSON
   ,v_path VARCHAR2
  ); --using htp.print

  --extra function checks if number has no fraction
  FUNCTION is_integer(v json_value) RETURN BOOLEAN;

  format_string VARCHAR2(30 CHAR) := 'yyyy-mm-dd hh24:mi:ss';
  --extension enables json to store dates without comprimising the implementation
  FUNCTION to_json_value(d DATE) RETURN json_value;
  --notice that a date type in json is also a varchar2
  FUNCTION is_date(v json_value) RETURN BOOLEAN;
  --convertion is needed to extract dates 
  --(json_ext.to_date will not work along with the normal to_date function - any fix will be appreciated)
  FUNCTION to_date2(v json_value) RETURN DATE;
  --JSON Path with date
  FUNCTION get_date
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN DATE;
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem DATE
   ,base NUMBER DEFAULT 1
  );

  --experimental support of binary data with base64
  FUNCTION base64(binarydata BLOB) RETURN JSON_LIST;
  FUNCTION base64(l JSON_LIST) RETURN BLOB;

  FUNCTION encode(binarydata BLOB) RETURN json_value;
  FUNCTION decode(v json_value) RETURN BLOB;

END json_ext;
/
CREATE OR REPLACE PACKAGE BODY json_ext AS
  scanner_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(scanner_exception, -20100);
  parser_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(parser_exception, -20101);
  jext_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(jext_exception, -20110);

  --extra function checks if number has no fraction
  FUNCTION is_integer(v json_value) RETURN BOOLEAN AS
    myint NUMBER(38); --the oracle way to specify an integer
  BEGIN
    IF (v.is_number)
    THEN
      myint := v.get_number;
      RETURN(myint = v.get_number); --no rounding errors?
    ELSE
      RETURN FALSE;
    END IF;
  END;

  --extension enables json to store dates without comprimising the implementation
  FUNCTION to_json_value(d DATE) RETURN json_value AS
  BEGIN
    RETURN json_value(to_char(d, format_string));
  END;

  --notice that a date type in json is also a varchar2
  FUNCTION is_date(v json_value) RETURN BOOLEAN AS
    temp DATE;
  BEGIN
    temp := json_ext.to_date2(v);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  --convertion is needed to extract dates
  FUNCTION to_date2(v json_value) RETURN DATE AS
  BEGIN
    IF (v.is_string)
    THEN
      RETURN to_date(v.get_string, format_string);
    ELSE
      raise_application_error(-20110, 'Anydata did not contain a date-value');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20110
                             ,'Anydata did not contain a date on the format: ' || format_string);
  END;

  --Json Path parser
  FUNCTION parsePath
  (
    json_path VARCHAR2
   ,base      NUMBER DEFAULT 1
  ) RETURN JSON_LIST AS
    build_path VARCHAR2(32767) := '[';
    buf        VARCHAR2(4);
    endstring  VARCHAR2(1);
    indx       NUMBER := 1;
    ret        JSON_LIST;
  
    PROCEDURE next_char AS
    BEGIN
      IF (indx <= length(json_path))
      THEN
        buf  := substr(json_path, indx, 1);
        indx := indx + 1;
      ELSE
        buf := NULL;
      END IF;
    END;
    --skip ws
    PROCEDURE skipws AS
    BEGIN
      WHILE (buf IN (chr(9), chr(10), chr(13), ' '))
      LOOP
        next_char;
      END LOOP;
    END;
  
  BEGIN
    next_char();
    WHILE (buf IS NOT NULL)
    LOOP
      IF (buf = '.')
      THEN
        next_char();
        IF (buf IS NULL)
        THEN
          raise_application_error(-20110, 'JSON Path parse error: . is not a valid json_path end');
        END IF;
        IF (NOT regexp_like(buf, '^[[:alnum:]\_ ]+', 'c'))
        THEN
          raise_application_error(-20110
                                 ,'JSON Path parse error: alpha-numeric character or space expected at position ' || indx);
        END IF;
      
        IF (build_path != '[')
        THEN
          build_path := build_path || ',';
        END IF;
        build_path := build_path || '"';
        WHILE (regexp_like(buf, '^[[:alnum:]\_ ]+', 'c'))
        LOOP
          build_path := build_path || buf;
          next_char();
        END LOOP;
        build_path := build_path || '"';
      ELSIF (buf = '[')
      THEN
        next_char();
        skipws();
        IF (buf IS NULL)
        THEN
          raise_application_error(-20110, 'JSON Path parse error: [ is not a valid json_path end');
        END IF;
        IF (buf IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') OR (buf = '0' AND base = 0))
        THEN
          IF (build_path != '[')
          THEN
            build_path := build_path || ',';
          END IF;
          WHILE (buf IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9'))
          LOOP
            build_path := build_path || buf;
            next_char();
          END LOOP;
        ELSIF (regexp_like(buf, '^(\"|\'')', 'c'))
        THEN
          endstring := buf;
          IF (build_path != '[')
          THEN
            build_path := build_path || ',';
          END IF;
          build_path := build_path || '"';
          next_char();
          IF (buf IS NULL)
          THEN
            raise_application_error(-20110, 'JSON Path parse error: premature json_path end');
          END IF;
          WHILE (buf != endstring)
          LOOP
            build_path := build_path || buf;
            next_char();
            IF (buf IS NULL)
            THEN
              raise_application_error(-20110, 'JSON Path parse error: premature json_path end');
            END IF;
            IF (buf = '\')
            THEN
              next_char();
              build_path := build_path || '\' || buf;
              next_char();
            END IF;
          END LOOP;
          build_path := build_path || '"';
          next_char();
        ELSE
          raise_application_error(-20110
                                 ,'JSON Path parse error: expected a string or an positive integer at ' || indx);
        END IF;
        skipws();
        IF (buf IS NULL)
        THEN
          raise_application_error(-20110, 'JSON Path parse error: premature json_path end');
        END IF;
        IF (buf != ']')
        THEN
          raise_application_error(-20110
                                 ,'JSON Path parse error: no array ending found. found: ' || buf);
        END IF;
        next_char();
        skipws();
      ELSIF (build_path = '[')
      THEN
        IF (NOT regexp_like(buf, '^[[:alnum:]\_ ]+', 'c'))
        THEN
          raise_application_error(-20110
                                 ,'JSON Path parse error: alpha-numeric character or space expected at position ' || indx);
        END IF;
        build_path := build_path || '"';
        WHILE (regexp_like(buf, '^[[:alnum:]\_ ]+', 'c'))
        LOOP
          build_path := build_path || buf;
          next_char();
        END LOOP;
        build_path := build_path || '"';
      ELSE
        raise_application_error(-20110
                               ,'JSON Path parse error: expected . or [ found ' || buf ||
                                ' at position ' || indx);
      END IF;
    
    END LOOP;
  
    build_path := build_path || ']';
    build_path := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(build_path, chr(9), '\t'), chr(10), '\n')
                                         ,chr(13)
                                         ,'\f')
                                 ,chr(8)
                                 ,'\b')
                         ,chr(14)
                         ,'\r');
  
    ret := JSON_LIST(build_path);
    IF (base != 1)
    THEN
      --fix base 0 to base 1
      DECLARE
        elem json_value;
      BEGIN
        FOR i IN 1 .. ret.count
        LOOP
          elem := ret.get(i);
          IF (elem.is_number)
          THEN
            ret.replace(i, elem.get_number() + 1);
          END IF;
        END LOOP;
      END;
    END IF;
  
    RETURN ret;
  END parsePath;

  --JSON Path getters
  FUNCTION get_json_value
  (
    obj    JSON
   ,v_path VARCHAR2
   ,base   NUMBER DEFAULT 1
  ) RETURN json_value AS
    path JSON_LIST;
    ret  json_value;
    o    JSON;
    l    JSON_LIST;
  BEGIN
    path := parsePath(v_path, base);
    ret  := obj.to_json_value;
    IF (path.count = 0)
    THEN
      RETURN ret;
    END IF;
  
    FOR i IN 1 .. path.count
    LOOP
      IF (path.get(i).is_string())
      THEN
        --string fetch only on json
        o   := JSON(ret);
        ret := o.get(path.get(i).get_string());
      ELSE
        --number fetch on json and json_list
        IF (ret.is_array())
        THEN
          l   := JSON_LIST(ret);
          ret := l.get(path.get(i).get_number());
        ELSE
          o   := JSON(ret);
          l   := o.get_values();
          ret := l.get(path.get(i).get_number());
        END IF;
      END IF;
    END LOOP;
  
    RETURN ret;
  EXCEPTION
    WHEN scanner_exception THEN
      RAISE;
    WHEN parser_exception THEN
      RAISE;
    WHEN jext_exception THEN
      RAISE;
    WHEN OTHERS THEN
      RETURN NULL;
  END get_json_value;

  --JSON Path getters
  FUNCTION get_string
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN VARCHAR2 AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT temp.is_string)
    THEN
      RETURN NULL;
    ELSE
      RETURN temp.get_string;
    END IF;
  END;

  FUNCTION get_number
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN NUMBER AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT temp.is_number)
    THEN
      RETURN NULL;
    ELSE
      RETURN temp.get_number;
    END IF;
  END;

  FUNCTION get_json
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN JSON AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT temp.is_object)
    THEN
      RETURN NULL;
    ELSE
      RETURN JSON(temp);
    END IF;
  END;

  FUNCTION get_json_list
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN JSON_LIST AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT temp.is_array)
    THEN
      RETURN NULL;
    ELSE
      RETURN JSON_LIST(temp);
    END IF;
  END;

  FUNCTION get_bool
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN BOOLEAN AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT temp.is_bool)
    THEN
      RETURN NULL;
    ELSE
      RETURN temp.get_bool;
    END IF;
  END;

  FUNCTION get_date
  (
    obj  JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) RETURN DATE AS
    temp json_value;
  BEGIN
    temp := get_json_value(obj, path, base);
    IF (temp IS NULL OR NOT is_date(temp))
    THEN
      RETURN NULL;
    ELSE
      RETURN json_ext.to_date2(temp);
    END IF;
  END;

  /* JSON Path putter internal function */
  PROCEDURE put_internal
  (
    obj    IN OUT NOCOPY JSON
   ,v_path VARCHAR2
   ,elem   json_value
   ,base   NUMBER
  ) AS
    val           json_value := elem;
    path          JSON_LIST;
    backreference JSON_LIST := JSON_LIST();
  
    keyval    json_value;
    keynum    NUMBER;
    keystring VARCHAR2(4000);
    temp      json_value := obj.to_json_value;
    obj_temp  JSON;
    list_temp JSON_LIST;
    inserter  json_value;
  BEGIN
    path := json_ext.parsePath(v_path, base);
    IF (path.count = 0)
    THEN
      raise_application_error(-20110, 'JSON_EXT put error: cannot put with empty string.');
    END IF;
  
    --build backreference
    FOR i IN 1 .. path.count
    LOOP
      --backreference.print(false);
      keyval := path.get(i);
      IF (keyval.is_number())
      THEN
        --nummer index
        keynum := keyval.get_number();
        IF ((NOT temp.is_object()) AND (NOT temp.is_array()))
        THEN
          IF (val IS NULL)
          THEN
            RETURN;
          END IF;
          backreference.remove_last;
          temp := JSON_LIST().to_json_value();
          backreference.append(temp);
        END IF;
      
        IF (temp.is_object())
        THEN
          obj_temp := JSON(temp);
          IF (obj_temp.count < keynum)
          THEN
            IF (val IS NULL)
            THEN
              RETURN;
            END IF;
            raise_application_error(-20110, 'JSON_EXT put error: access object with to few members.');
          END IF;
          temp := obj_temp.get(keynum);
        ELSE
          list_temp := JSON_LIST(temp);
          IF (list_temp.count < keynum)
          THEN
            IF (val IS NULL)
            THEN
              RETURN;
            END IF;
            --raise error or quit if val is null
            FOR i IN list_temp.count + 1 .. keynum
            LOOP
              list_temp.append(json_value.makenull);
            END LOOP;
            backreference.remove_last;
            backreference.append(list_temp);
          END IF;
        
          temp := list_temp.get(keynum);
        END IF;
      ELSE
        --streng index
        keystring := keyval.get_string();
        IF (NOT temp.is_object())
        THEN
          --backreference.print;
          IF (val IS NULL)
          THEN
            RETURN;
          END IF;
          backreference.remove_last;
          temp := JSON().to_json_value();
          backreference.append(temp);
          --raise_application_error(-20110, 'JSON_ext put error: trying to access a non object with a string.'); 
        END IF;
        obj_temp := JSON(temp);
        temp     := obj_temp.get(keystring);
      END IF;
    
      IF (temp IS NULL)
      THEN
        IF (val IS NULL)
        THEN
          RETURN;
        END IF;
        --what to expect?
        keyval := path.get(i + 1);
        IF (keyval IS NOT NULL AND keyval.is_number())
        THEN
          temp := JSON_LIST().to_json_value;
        ELSE
          temp := JSON().to_json_value;
        END IF;
      END IF;
      backreference.append(temp);
    END LOOP;
  
    --  backreference.print(false);
    --  path.print(false);
  
    --use backreference and path together
    inserter := val;
    FOR i IN REVERSE 1 .. backreference.count
    LOOP
      --    inserter.print(false);
      IF (i = 1)
      THEN
        keyval := path.get(1);
        IF (keyval.is_string())
        THEN
          keystring := keyval.get_string();
        ELSE
          keynum := keyval.get_number();
          DECLARE
            t1 json_value := obj.get(keynum);
          BEGIN
            keystring := t1.mapname;
          END;
        END IF;
        IF (inserter IS NULL)
        THEN
          obj.remove(keystring);
        ELSE
          obj.put(keystring, inserter);
        END IF;
      ELSE
        temp := backreference.get(i - 1);
        IF (temp.is_object())
        THEN
          keyval   := path.get(i);
          obj_temp := JSON(temp);
          IF (keyval.is_string())
          THEN
            keystring := keyval.get_string();
          ELSE
            keynum := keyval.get_number();
            DECLARE
              t1 json_value := obj_temp.get(keynum);
            BEGIN
              keystring := t1.mapname;
            END;
          END IF;
          IF (inserter IS NULL)
          THEN
            obj_temp.remove(keystring);
            IF (obj_temp.count > 0)
            THEN
              inserter := obj_temp.to_json_value;
            END IF;
          ELSE
            obj_temp.put(keystring, inserter);
            inserter := obj_temp.to_json_value;
          END IF;
        ELSE
          --array only number
          keynum    := path.get(i).get_number();
          list_temp := JSON_LIST(temp);
          list_temp.remove(keynum);
          IF (NOT inserter IS NULL)
          THEN
            list_temp.append(inserter, keynum);
            inserter := list_temp.to_json_value;
          ELSE
            IF (list_temp.count > 0)
            THEN
              inserter := list_temp.to_json_value;
            END IF;
          END IF;
        END IF;
      END IF;
    
    END LOOP;
  
  END put_internal;

  /* JSON Path putters */
  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem VARCHAR2
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    put_internal(obj, path, json_value(elem), base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem NUMBER
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, json_value(elem), base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem JSON
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, elem.to_json_value, base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem JSON_LIST
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, elem.to_json_value, base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem BOOLEAN
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, json_value(elem), base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem json_value
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, elem, base);
  END;

  PROCEDURE put
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,elem DATE
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    IF (elem IS NULL)
    THEN
      raise_application_error(-20110, 'Cannot put null-value');
    END IF;
    put_internal(obj, path, json_ext.to_json_value(elem), base);
  END;

  PROCEDURE remove
  (
    obj  IN OUT NOCOPY JSON
   ,path VARCHAR2
   ,base NUMBER DEFAULT 1
  ) AS
  BEGIN
    json_ext.put_internal(obj, path, NULL, base);
    --    if(json_ext.get_json_value(obj,path) is not null) then
    --    end if;
  END remove;

  --Pretty print with JSON Path
  FUNCTION pp
  (
    obj    JSON
   ,v_path VARCHAR2
  ) RETURN VARCHAR2 AS
    json_part json_value;
  BEGIN
    json_part := json_ext.get_json_value(obj, v_path);
    IF (json_part IS NULL)
    THEN
      RETURN '';
    ELSE
      RETURN json_printer.pretty_print_any(json_part); --escapes a possible internal string
    END IF;
  END pp;

  PROCEDURE pp
  (
    obj    JSON
   ,v_path VARCHAR2
  ) AS --using dbms_output.put_line
  BEGIN
    dbms_output.put_line(pp(obj, v_path));
  END pp;

  -- spaces = false!
  PROCEDURE pp_htp
  (
    obj    JSON
   ,v_path VARCHAR2
  ) AS
    --using htp.print
    json_part json_value;
  BEGIN
    json_part := json_ext.get_json_value(obj, v_path);
    IF (json_part IS NULL)
    THEN
      htp.print;
    ELSE
      htp.print(json_printer.pretty_print_any(json_part, FALSE));
    END IF;
  END pp_htp;

  FUNCTION base64(binarydata BLOB) RETURN JSON_LIST AS
    obj  JSON_LIST := JSON_LIST();
    c    CLOB := empty_clob();
    benc BLOB;
  
    v_blob_offset  NUMBER := 1;
    v_clob_offset  NUMBER := 1;
    v_lang_context NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      NUMBER;
    v_amount       PLS_INTEGER;
    --    temp varchar2(32767);
  
    FUNCTION encodeBlob2Base64(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount     NUMBER := 45;
      vBlobEnc    BLOB := empty_blob();
      vBlobEncLen NUMBER := 0;
      vBlobInLen  NUMBER := 0;
      vBuffer     RAW(45);
      vOffset     NUMBER := 1;
    BEGIN
      --      dbms_output.put_line('Start base64 encoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
      --      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobEnc, TRUE);
      LOOP
        IF vOffset >= vBlobInLen
        THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobEnc, utl_encode.base64_encode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' ||
                                 vBuffer);
            dbms_output.put_line('ERROR IN append: ' || SQLERRM);
            RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobEncLen := dbms_lob.getlength(vBlobEnc);
      --      dbms_output.put_line('<BlobEncLength>' || vBlobEncLen);
      --      dbms_output.put_line('Finshed base64 encoding.');
      RETURN vBlobEnc;
    END encodeBlob2Base64;
  BEGIN
    benc := encodeBlob2Base64(binarydata);
    dbms_lob.createtemporary(c, TRUE);
    v_amount := DBMS_LOB.GETLENGTH(benc);
    DBMS_LOB.CONVERTTOCLOB(c
                          ,benc
                          ,v_amount
                          ,v_clob_offset
                          ,v_blob_offset
                          ,1
                          ,v_lang_context
                          ,v_warning);
  
    v_amount      := DBMS_LOB.GETLENGTH(c);
    v_clob_offset := 1;
    --dbms_output.put_line('V amount: '||v_amount);
    WHILE (v_clob_offset < v_amount)
    LOOP
      --dbms_output.put_line(v_offset);
      --temp := ;
      --dbms_output.put_line('size: '||length(temp));
      obj.append(dbms_lob.SUBSTR(c, 4000, v_clob_offset));
      v_clob_offset := v_clob_offset + 4000;
    END LOOP;
    dbms_lob.freetemporary(benc);
    dbms_lob.freetemporary(c);
    --dbms_output.put_line(obj.count);
    --dbms_output.put_line(obj.get_last().to_char);
    RETURN obj;
  
  END base64;

  FUNCTION base64(l JSON_LIST) RETURN BLOB AS
    c    CLOB := empty_clob();
    b    BLOB := empty_blob();
    bret BLOB;
  
    v_blob_offset  NUMBER := 1;
    v_clob_offset  NUMBER := 1;
    v_lang_context NUMBER := 0; --DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      NUMBER;
    v_amount       PLS_INTEGER;
  
    FUNCTION decodeBase642Blob(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount     NUMBER := 256; --32;
      vBlobDec    BLOB := empty_blob();
      vBlobDecLen NUMBER := 0;
      vBlobInLen  NUMBER := 0;
      vBuffer     RAW(256); --32);
      vOffset     NUMBER := 1;
    BEGIN
      --      dbms_output.put_line('Start base64 decoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
      --      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobDec, TRUE);
      LOOP
        IF vOffset >= vBlobInLen
        THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobDec, utl_encode.base64_decode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' ||
                                 vBuffer);
            dbms_output.put_line('ERROR IN append: ' || SQLERRM);
            RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobDecLen := dbms_lob.getlength(vBlobDec);
      --      dbms_output.put_line('<BlobDecLength>' || vBlobDecLen);
      --      dbms_output.put_line('Finshed base64 decoding.');
      RETURN vBlobDec;
    END decodeBase642Blob;
  BEGIN
    dbms_lob.createtemporary(c, TRUE);
    FOR i IN 1 .. l.count
    LOOP
      dbms_lob.append(c, l.get(i).get_string());
    END LOOP;
    v_amount := DBMS_LOB.GETLENGTH(c);
    --    dbms_output.put_line('L C'||v_amount);
  
    dbms_lob.createtemporary(b, TRUE);
    DBMS_LOB.CONVERTTOBLOB(b
                          ,c
                          ,dbms_lob.lobmaxsize
                          ,v_clob_offset
                          ,v_blob_offset
                          ,1
                          ,v_lang_context
                          ,v_warning);
    dbms_lob.freetemporary(c);
    v_amount := DBMS_LOB.GETLENGTH(b);
    --    dbms_output.put_line('L B'||v_amount);
  
    bret := decodeBase642Blob(b);
    dbms_lob.freetemporary(b);
    RETURN bret;
  
  END base64;

  FUNCTION encode(binarydata BLOB) RETURN json_value AS
    obj  json_value;
    c    CLOB := empty_clob();
    benc BLOB;
  
    v_blob_offset  NUMBER := 1;
    v_clob_offset  NUMBER := 1;
    v_lang_context NUMBER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      NUMBER;
    v_amount       PLS_INTEGER;
    --    temp varchar2(32767);
  
    FUNCTION encodeBlob2Base64(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount     NUMBER := 45;
      vBlobEnc    BLOB := empty_blob();
      vBlobEncLen NUMBER := 0;
      vBlobInLen  NUMBER := 0;
      vBuffer     RAW(45);
      vOffset     NUMBER := 1;
    BEGIN
      --      dbms_output.put_line('Start base64 encoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
      --      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobEnc, TRUE);
      LOOP
        IF vOffset >= vBlobInLen
        THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobEnc, utl_encode.base64_encode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' ||
                                 vBuffer);
            dbms_output.put_line('ERROR IN append: ' || SQLERRM);
            RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobEncLen := dbms_lob.getlength(vBlobEnc);
      --      dbms_output.put_line('<BlobEncLength>' || vBlobEncLen);
      --      dbms_output.put_line('Finshed base64 encoding.');
      RETURN vBlobEnc;
    END encodeBlob2Base64;
  BEGIN
    benc := encodeBlob2Base64(binarydata);
    dbms_lob.createtemporary(c, TRUE);
    v_amount := DBMS_LOB.GETLENGTH(benc);
    DBMS_LOB.CONVERTTOCLOB(c
                          ,benc
                          ,v_amount
                          ,v_clob_offset
                          ,v_blob_offset
                          ,1
                          ,v_lang_context
                          ,v_warning);
  
    obj := json_value(c);
  
    dbms_lob.freetemporary(benc);
    dbms_lob.freetemporary(c);
    --dbms_output.put_line(obj.count);
    --dbms_output.put_line(obj.get_last().to_char);
    RETURN obj;
  
  END encode;

  FUNCTION decode(v json_value) RETURN BLOB AS
    c    CLOB := empty_clob();
    b    BLOB := empty_blob();
    bret BLOB;
  
    v_blob_offset  NUMBER := 1;
    v_clob_offset  NUMBER := 1;
    v_lang_context NUMBER := 0; --DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning      NUMBER;
    v_amount       PLS_INTEGER;
  
    FUNCTION decodeBase642Blob(pBlobIn IN BLOB) RETURN BLOB IS
      vAmount     NUMBER := 256; --32;
      vBlobDec    BLOB := empty_blob();
      vBlobDecLen NUMBER := 0;
      vBlobInLen  NUMBER := 0;
      vBuffer     RAW(256); --32);
      vOffset     NUMBER := 1;
    BEGIN
      --      dbms_output.put_line('Start base64 decoding.');
      vBlobInLen := dbms_lob.getlength(pBlobIn);
      --      dbms_output.put_line('<BlobInLength>' || vBlobInLen);
      dbms_lob.createtemporary(vBlobDec, TRUE);
      LOOP
        IF vOffset >= vBlobInLen
        THEN
          EXIT;
        END IF;
        dbms_lob.read(pBlobIn, vAmount, vOffset, vBuffer);
        BEGIN
          dbms_lob.append(vBlobDec, utl_encode.base64_decode(vBuffer));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('<vAmount>' || vAmount || '<vOffset>' || vOffset || '<vBuffer>' ||
                                 vBuffer);
            dbms_output.put_line('ERROR IN append: ' || SQLERRM);
            RAISE;
        END;
        vOffset := vOffset + vAmount;
      END LOOP;
      vBlobDecLen := dbms_lob.getlength(vBlobDec);
      --      dbms_output.put_line('<BlobDecLength>' || vBlobDecLen);
      --      dbms_output.put_line('Finshed base64 decoding.');
      RETURN vBlobDec;
    END decodeBase642Blob;
  BEGIN
    dbms_lob.createtemporary(c, TRUE);
    v.get_string(c);
    v_amount := DBMS_LOB.GETLENGTH(c);
    --    dbms_output.put_line('L C'||v_amount);
  
    dbms_lob.createtemporary(b, TRUE);
    DBMS_LOB.CONVERTTOBLOB(b
                          ,c
                          ,dbms_lob.lobmaxsize
                          ,v_clob_offset
                          ,v_blob_offset
                          ,1
                          ,v_lang_context
                          ,v_warning);
    dbms_lob.freetemporary(c);
    v_amount := DBMS_LOB.GETLENGTH(b);
    --    dbms_output.put_line('L B'||v_amount);
  
    bret := decodeBase642Blob(b);
    dbms_lob.freetemporary(b);
    RETURN bret;
  
  END decode;

END json_ext;
/

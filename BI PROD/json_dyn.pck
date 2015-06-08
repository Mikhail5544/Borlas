CREATE OR REPLACE PACKAGE json_dyn AUTHID CURRENT_USER AS
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

  null_as_empty_string BOOLEAN NOT NULL := TRUE; --varchar2
  include_dates        BOOLEAN NOT NULL := TRUE; --date
  include_clobs        BOOLEAN NOT NULL := TRUE;
  include_blobs        BOOLEAN NOT NULL := FALSE;

  /* list with objects */
  FUNCTION executeList
  (
    stmt    VARCHAR2
   ,bindvar JSON DEFAULT NULL
  ) RETURN JSON_LIST;

  /* object with lists */
  FUNCTION executeObject
  (
    stmt    VARCHAR2
   ,bindvar JSON DEFAULT NULL
  ) RETURN JSON;

/* usage example:
   * declare
   *   res json_list;
   * begin
   *   res := json_dyn.executeList(
   *            'select :bindme as one, :lala as two from dual where dummy in :arraybind',
   *            json('{bindme:"4", lala:123, arraybind:[1,2,3,"X"]}')
   *          );
   *   res.print;
   * end;
   */

END json_dyn;
/
CREATE OR REPLACE PACKAGE BODY json_dyn AS

  PROCEDURE bind_json
  (
    l_cur   NUMBER
   ,bindvar JSON
  ) AS
    keylist JSON_LIST := bindvar.get_keys();
  BEGIN
    FOR i IN 1 .. keylist.count
    LOOP
      IF (bindvar.get(i).get_type = 'number')
      THEN
        dbms_sql.bind_variable(l_cur, ':' || keylist.get(i).get_string, bindvar.get(i).get_number);
      ELSIF (bindvar.get(i).get_type = 'array')
      THEN
        DECLARE
          v_bind dbms_sql.varchar2_table;
          v_arr  JSON_LIST := JSON_LIST(bindvar.get(i));
        BEGIN
          FOR j IN 1 .. v_arr.count
          LOOP
            v_bind(j) := v_arr.get(j).value_of;
          END LOOP;
          dbms_sql.bind_array(l_cur, ':' || keylist.get(i).get_string, v_bind);
        END;
      ELSE
        dbms_sql.bind_variable(l_cur, ':' || keylist.get(i).get_string, bindvar.get(i).value_of());
      END IF;
    END LOOP;
  END bind_json;

  /* list with objects */
  FUNCTION executeList
  (
    stmt    VARCHAR2
   ,bindvar JSON
  ) RETURN JSON_LIST AS
    l_cur      NUMBER;
    l_dtbl     dbms_sql.desc_tab;
    l_cnt      NUMBER;
    l_status   NUMBER;
    l_val      VARCHAR2(4000);
    outer_list JSON_LIST := JSON_LIST();
    inner_obj  JSON;
    conv       NUMBER;
    read_date  DATE;
    read_clob  CLOB;
    read_blob  BLOB;
    col_type   NUMBER;
  BEGIN
    l_cur := dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, stmt, dbms_sql.native);
    IF (bindvar IS NOT NULL)
    THEN
      bind_json(l_cur, bindvar);
    END IF;
    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);
    FOR i IN 1 .. l_cnt
    LOOP
      col_type := l_dtbl(i).col_type;
      --      dbms_output.put_line(col_type);
      IF (col_type = 12)
      THEN
        dbms_sql.define_column(l_cur, i, read_date);
      ELSIF (col_type = 112)
      THEN
        dbms_sql.define_column(l_cur, i, read_clob);
      ELSIF (col_type = 113)
      THEN
        dbms_sql.define_column(l_cur, i, read_blob);
      ELSIF (col_type IN (1, 2, 96))
      THEN
        dbms_sql.define_column(l_cur, i, l_val, 4000);
      END IF;
    END LOOP;
    l_status := dbms_sql.execute(l_cur);
  
    --loop through rows 
    WHILE (dbms_sql.fetch_rows(l_cur) > 0)
    LOOP
      inner_obj := JSON(); --init for each row
      --loop through columns
      FOR i IN 1 .. l_cnt
      LOOP
        CASE TRUE
        --handling string types
          WHEN l_dtbl(i).col_type IN (1, 96) THEN
            -- varchar2
            dbms_sql.column_value(l_cur, i, l_val);
            IF (l_val IS NULL)
            THEN
              IF (null_as_empty_string)
              THEN
                inner_obj.put(l_dtbl(i).col_name, ''); --treatet as emptystring?
              ELSE
                inner_obj.put(l_dtbl(i).col_name, json_value.makenull); --null
              END IF;
            ELSE
              DECLARE
                v json_value;
              BEGIN
                v := json_parser.parse_any('"' || l_val || '"');
                inner_obj.put(l_dtbl(i).col_name, v); --null
              EXCEPTION
                WHEN OTHERS THEN
                  inner_obj.put(l_dtbl(i).col_name, json_value.makenull); --null
              END;
            END IF;
            --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'varchar2' ||l_dtbl(i).col_type);
        --handling number types
          WHEN l_dtbl(i).col_type = 2 THEN
            -- number
            dbms_sql.column_value(l_cur, i, l_val);
            conv := l_val;
            inner_obj.put(l_dtbl(i).col_name, conv);
            -- dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'number ' ||l_dtbl(i).col_type);
          WHEN l_dtbl(i).col_type = 12 THEN
            -- date
            IF (include_dates)
            THEN
              dbms_sql.column_value(l_cur, i, read_date);
              inner_obj.put(l_dtbl(i).col_name, json_ext.to_json_value(read_date));
            END IF;
            --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'date ' ||l_dtbl(i).col_type);
          WHEN l_dtbl(i).col_type = 112 THEN
            --clob
            IF (include_clobs)
            THEN
              dbms_sql.column_value(l_cur, i, read_clob);
              inner_obj.put(l_dtbl(i).col_name, json_value(read_clob));
            END IF;
          WHEN l_dtbl(i).col_type = 113 THEN
            --blob
            IF (include_blobs)
            THEN
              dbms_sql.column_value(l_cur, i, read_blob);
              inner_obj.put(l_dtbl(i).col_name, json_ext.encode(read_blob));
            END IF;
          
          ELSE
            NULL; --discard other types
        END CASE;
      END LOOP;
      outer_list.append(inner_obj.to_json_value);
    END LOOP;
    dbms_sql.close_cursor(l_cur);
    RETURN outer_list;
  END executeList;

  /* object with lists */
  FUNCTION executeObject
  (
    stmt    VARCHAR2
   ,bindvar JSON
  ) RETURN JSON AS
    l_cur            NUMBER;
    l_dtbl           dbms_sql.desc_tab;
    l_cnt            NUMBER;
    l_status         NUMBER;
    l_val            VARCHAR2(4000);
    inner_list_names JSON_LIST := JSON_LIST();
    inner_list_data  JSON_LIST := JSON_LIST();
    data_list        JSON_LIST;
    outer_obj        JSON := JSON();
    conv             NUMBER;
    read_date        DATE;
    read_clob        CLOB;
    read_blob        BLOB;
    col_type         NUMBER;
  BEGIN
    l_cur := dbms_sql.open_cursor;
    dbms_sql.parse(l_cur, stmt, dbms_sql.native);
    IF (bindvar IS NOT NULL)
    THEN
      bind_json(l_cur, bindvar);
    END IF;
    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);
    FOR i IN 1 .. l_cnt
    LOOP
      col_type := l_dtbl(i).col_type;
      IF (col_type = 12)
      THEN
        dbms_sql.define_column(l_cur, i, read_date);
      ELSIF (col_type = 112)
      THEN
        dbms_sql.define_column(l_cur, i, read_clob);
      ELSIF (col_type = 113)
      THEN
        dbms_sql.define_column(l_cur, i, read_blob);
      ELSIF (col_type IN (1, 2, 96))
      THEN
        dbms_sql.define_column(l_cur, i, l_val, 4000);
      END IF;
    END LOOP;
    l_status := dbms_sql.execute(l_cur);
  
    --build up name_list
    FOR i IN 1 .. l_cnt
    LOOP
      CASE l_dtbl(i).col_type
        WHEN 1 THEN
          inner_list_names.append(l_dtbl(i).col_name);
        WHEN 96 THEN
          inner_list_names.append(l_dtbl(i).col_name);
        WHEN 2 THEN
          inner_list_names.append(l_dtbl(i).col_name);
        WHEN 12 THEN
          IF (include_dates)
          THEN
            inner_list_names.append(l_dtbl(i).col_name);
          END IF;
        WHEN 112 THEN
          IF (include_clobs)
          THEN
            inner_list_names.append(l_dtbl(i).col_name);
          END IF;
        WHEN 113 THEN
          IF (include_blobs)
          THEN
            inner_list_names.append(l_dtbl(i).col_name);
          END IF;
        ELSE
          NULL;
      END CASE;
    END LOOP;
  
    --loop through rows 
    WHILE (dbms_sql.fetch_rows(l_cur) > 0)
    LOOP
      data_list := JSON_LIST();
      --loop through columns
      FOR i IN 1 .. l_cnt
      LOOP
        CASE TRUE
        --handling string types
          WHEN l_dtbl(i).col_type IN (1, 96) THEN
            -- varchar2
            dbms_sql.column_value(l_cur, i, l_val);
            IF (l_val IS NULL)
            THEN
              IF (null_as_empty_string)
              THEN
                data_list.append(''); --treatet as emptystring?
              ELSE
                data_list.append(json_value.makenull); --null
              END IF;
            ELSE
              DECLARE
                v json_value;
              BEGIN
                v := json_parser.parse_any('"' || l_val || '"');
                data_list.append(v); --null
              EXCEPTION
                WHEN OTHERS THEN
                  data_list.append(json_value.makenull); --null
              END;
            END IF;
            --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'varchar2' ||l_dtbl(i).col_type);
        --handling number types
          WHEN l_dtbl(i).col_type = 2 THEN
            -- number
            dbms_sql.column_value(l_cur, i, l_val);
            conv := l_val;
            data_list.append(conv);
            -- dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'number ' ||l_dtbl(i).col_type);
          WHEN l_dtbl(i).col_type = 12 THEN
            -- date
            IF (include_dates)
            THEN
              dbms_sql.column_value(l_cur, i, read_date);
              data_list.append(json_ext.to_json_value(read_date));
            END IF;
            --dbms_output.put_line(l_dtbl(i).col_name||' --> '||l_val||'date ' ||l_dtbl(i).col_type);
          WHEN l_dtbl(i).col_type = 112 THEN
            --clob
            IF (include_clobs)
            THEN
              dbms_sql.column_value(l_cur, i, read_clob);
              data_list.append(json_value(read_clob));
            END IF;
          WHEN l_dtbl(i).col_type = 113 THEN
            --blob
            IF (include_blobs)
            THEN
              dbms_sql.column_value(l_cur, i, read_blob);
              data_list.append(json_ext.encode(read_blob));
            END IF;
          ELSE
            NULL; --discard other types
        END CASE;
      END LOOP;
      inner_list_data.append(data_list);
    END LOOP;
  
    outer_obj.put('names', inner_list_names.to_json_value);
    outer_obj.put('data', inner_list_data.to_json_value);
    dbms_sql.close_cursor(l_cur);
    RETURN outer_obj;
  END executeObject;

END json_dyn;
/

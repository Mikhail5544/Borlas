CREATE OR REPLACE PROCEDURE xGenericHelp(p_name_file VARCHAR2) IS

  CURSOR cur_table(p_table VARCHAR2) IS
    SELECT COMMENTS FROM user_tab_comments WHERE TABLE_NAME = UPPER(p_table);

  CURSOR cur_comments(p_table VARCHAR2) IS
    SELECT COLUMN_NAME
          ,COMMENTS
      FROM user_col_comments
     WHERE TABLE_NAME = p_table;

  CURSOR cur_obj_type IS
    SELECT * FROM GATE_OBJ_TYPE G ORDER BY G.GATE_OBJ_TYPE_ID ASC;

  CURSOR cur_obj_exlist(p_obj_type INT) IS
    SELECT * FROM GATE_OBJ_EXPORT_LINE G WHERE G.GATE_OBJ_TYPE_ID = p_obj_type ORDER BY g.NUM_EXE ASC;

  PROCEDURE getCommentCol(p_table VARCHAR2) IS
  BEGIN
    FOR rec IN cur_comments(p_table)
    LOOP
      dbms_output.put_line('<tr><td class = "css_tab_cell">' || rec.COLUMN_NAME || '</td>');
      dbms_output.put_line('<td class = "css_tab_cell">' || rec.COMMENTS || '</td> </tr>');
    END LOOP;
  END getCommentCol;

  FUNCTION getCommentTable(p_table VARCHAR2) RETURN VARCHAR2 IS
    rec cur_table%ROWTYPE;
    ret VARCHAR2(255);
  BEGIN
    OPEN cur_table(p_table);
    FETCH cur_table
      INTO rec;
    IF (cur_table%NOTFOUND)
    THEN
      ret := 'нет';
    ELSE
      ret := rec.COMMENTS;
    END IF;
    CLOSE cur_table;
    RETURN ret;
  END getCommentTable;

BEGIN
  dbms_output.enable(1000000);
  dbms_output.put_line('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head><title>
	Интеграция - описание шлюзовых таблиц
</title><link href="Style.css" rel="stylesheet" type="text/css" /></head>
<body>
    <form name="form1" method="post" action="Default.aspx" id="form1">
<div>
</div>
    <table style ="height:100%; width:100%">
      <tr>
        <td style ="height:100px; text-align:right">  
            <h1>Интеграция - описание шлюзовых таблиц</h1> <br />
            автоматическая генерация <br />
            автор <a href ="mailto:a.surovtsev@belsoft-borlas.by">Суровцев Алексей</a>
            <hr/>
        </td>
      </tr>
      <tr>
       <td>
        <h1>Интегрируемые объекты:</h1>
       </td>
      </tr>
      <tr>
        <td style ="height:100%; vertical-align:top; padding-left:21px"> 
        <ol start="1" class = "css_list_table">');

  FOR rec_obj_type IN cur_obj_type
  LOOP
    dbms_output.put_line('<li>');
    dbms_output.put_line('<a href ="' || p_name_file || '#obj' || rec_obj_type.GATE_OBJ_TYPE_ID || '">' ||
                         rec_obj_type.DESCR || '</a>');
    dbms_output.put_line('</li>');
  
    dbms_output.put_line('<ol  class = "css_list_table2">');
    FOR rec_obj_exlist IN cur_obj_exlist(rec_obj_type.GATE_OBJ_TYPE_ID)
    LOOP
      dbms_output.put_line('<li>');
      dbms_output.put_line('<a href ="' || p_name_file || '#obj' || rec_obj_type.GATE_OBJ_TYPE_ID ||
                           'tab' || rec_obj_exlist.NUM_EXE || '">' || rec_obj_exlist.EXPORT_LINE || '-' ||
                           getCommentTable(rec_obj_exlist.EXPORT_LINE) || '</a>');
      dbms_output.put_line('</li>');
    END LOOP;
  
    dbms_output.put_line('</ol>');
  END LOOP;
  dbms_output.put_line('</ol>');

  FOR rec_obj_type IN cur_obj_type
  LOOP
  
    dbms_output.put_line('<p id ="obj"' || rec_obj_type.GATE_OBJ_TYPE_ID || '>');
    dbms_output.put_line('<h1>' || rec_obj_type.DESCR || '</h1>');
  
    FOR rec_obj_exlist IN cur_obj_exlist(rec_obj_type.GATE_OBJ_TYPE_ID)
    LOOP
      dbms_output.put_line('<p id ="obj' || rec_obj_type.GATE_OBJ_TYPE_ID || 'tab' ||
                           rec_obj_exlist.NUM_EXE || '">');
      dbms_output.put_line('<table style="width: 400px; height: 1px" cellpadding = "0" cellspacing = "0">
                    <tr>
                        <td colspan="2" class = "css_tab_header">');
      dbms_output.put_line(rec_obj_exlist.EXPORT_LINE || '-' ||
                           getCommentTable(rec_obj_exlist.EXPORT_LINE));
    
      dbms_output.put_line('</td>
                    </tr>
                    <tr>
                        <td colspan="2" class = "css_tab_reheader">
                        </td>
                    </tr>');
    
      getCommentCol(rec_obj_exlist.EXPORT_LINE);
      dbms_output.put_line('</table>');
      dbms_output.put_line('</p>');
    END LOOP;
    dbms_output.put_line('</p>');
  END LOOP;

  dbms_output.put_line('</td>
      </tr>
    </table>
    </form>
</body>
</html>');
END xGenericHelp;
/

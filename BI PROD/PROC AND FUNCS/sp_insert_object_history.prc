CREATE OR REPLACE PROCEDURE Sp_Insert_Object_History(object_name VARCHAR2,
                                                     field_name VARCHAR2,
                                                     ext_id NUMBER,
                                                     old_mean VARCHAR2,
                                                     new_mean VARCHAR2,
                                                     login_name VARCHAR2,
                                                     note VARCHAR2) IS
BEGIN
  insert into object_history
    (ext_id,
     object_name_table,
     object_name_field,
     object_id,
     old_mean,
     new_mean,
     change_date,
     change_login,
     change_note)
  values
    (sq_object_history.nextval,
     object_name,
     field_name,
     ext_id,
     old_mean,
     new_mean,
     sysdate(),
     login_name,
     note);

END Sp_Insert_Object_History;
/


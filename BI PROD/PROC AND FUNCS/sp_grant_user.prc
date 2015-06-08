create or replace procedure sp_grant_user(p_user varchar2) is
    v_from varchar2(30);
    v_to   varchar2(30);
  begin
    v_from := upper(ents.v_sch);
    v_to   := upper(p_user);

    for rc in (select e.source from entity e) loop
      begin
        execute immediate 'create or replace synonym ' || v_to || '.ven_' || rc.source ||
                          ' for ' || v_from || '.ven_' || rc.source;                          
      exception
        when others then
          null;
      end;      
      begin
        execute immediate 'create or replace synonym ' || v_to || '.' || rc.source ||
                          ' for ' || v_from || '.' || rc.source;                          
      exception
        when others then
          null;
      end;      
      begin
        execute immediate 'create or replace synonym ' || v_to || '.sq_' || rc.source ||
                          ' for ' || v_from || '.sq_' || rc.source;
      exception
        when others then
          null;
      end;      
    end loop;
    
    execute immediate 'create or replace synonym ' || v_to || '.ent for ' || v_from || '.ent';
    execute immediate 'create or replace synonym ' || v_to || '.acc for ' || v_from || '.acc';
    execute immediate 'create or replace synonym ' || v_to || '.doc for ' || v_from || '.doc';
    execute immediate 'create or replace synonym ' || v_to || '.utils for ' || v_from || '.utils';            
    execute immediate 'create or replace synonym ' || v_to || '.repcore for ' || v_from || '.repcore';                
    for v_r in ( select object_name
                 from user_objects uo
                 where uo.object_type = 'PACKAGE' and substr(uo.object_name, 1, 4) = 'PKG_'
               ) loop    
      begin
        execute immediate 'create or replace synonym ' || v_to || '.' || v_r.object_name ||
                          ' for ' || v_from || '.' || v_r.object_name;
      exception
        when others then
          null;
      end;                 
    end loop;
  end;
/


create or replace force view v_tree_dms_mkb as
select 
    -1 st,
    level x_level, 
    tt.dsp_name,
    '' icon, 
    tt.id
  from  
    (
      select
        'Международный классификатор болезней' dsp_name,
        0 id,
        null parent_id
      from
        dual
      union all  
      select 
        t.code || ' ' || t.name dsp_name, 
        t.dms_mkb_id id,
        nvl(t.parent_id, 0) parent_id
      from 
        dms_mkb t
    ) tt
  start with tt.parent_id is NULL
  connect by prior tt.id = tt.parent_id order siblings by tt.dsp_name;


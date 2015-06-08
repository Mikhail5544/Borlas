create or replace force view v_rel_oper_trans_templ as
select
    rott.rel_oper_trans_templ_id,
    rott.ent_id,
    rott.filial_id,
    rott.oper_templ_id,
    ot.name oper_templ_name,
    rott.trans_templ_id,
    tt.name trans_templ_name,
    tt.brief trans_templ_brief,
    rott.parent_id,
    ptt.name parent_name
  from 
    Oper_Templ ot,
    Rel_Oper_Trans_Templ rott,
    Trans_Templ tt,
    Trans_Templ ptt
  where
    ot.oper_templ_id = rott.oper_templ_id
    and
    tt.trans_templ_id = rott.trans_templ_id
    and
    rott.parent_id = ptt.trans_templ_id(+);


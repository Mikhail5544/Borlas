create or replace force view v_oper_trans_templ as
select rott.oper_templ_id, rott.trans_templ_id, tt.name, rott.rel_oper_trans_templ_id
    from rel_oper_trans_templ rott, trans_templ tt
    where rott.trans_templ_id = tt.trans_templ_id;


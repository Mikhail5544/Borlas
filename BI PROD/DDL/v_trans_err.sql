create or replace force view v_trans_err as
select
    te.trans_err_id,
    te.ent_id,
    te.filial_id,
    te.oper_id,
    ot.name oper_templ_name,
    te.trans,
    te.trans_templ,
    te.trans_date,
    te.acc_fund,
    te.recalc_fund,
    te.acc_amount,
    te.base_fund,
    te.rate_type,
    te.dt_account,
    te.ct_account,
    o.document_id,
    te.Source
  from 
    Trans_Err te,
    Oper o,
    Oper_Templ ot
  where
    te.oper_id = o.oper_id
    and
    o.oper_templ_id = ot.oper_templ_id;


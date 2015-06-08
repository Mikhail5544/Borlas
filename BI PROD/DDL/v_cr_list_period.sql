create or replace force view v_cr_list_period as
select pt.id, pt.description from ven_t_payment_terms pt;


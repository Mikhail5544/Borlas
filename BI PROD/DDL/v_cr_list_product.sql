create or replace force view v_cr_list_product as
select pr.product_id, pr.description from ven_t_product pr;


create materialized view INS_DWH.MV_CR_LIST_PRODUCT
build deferred
refresh force on demand
as
select pr.product_id, pr.description from ins.ven_t_product pr;


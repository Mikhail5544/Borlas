create view v_rep_doc_from_b2b
as
select 
   pgt.RECEIVE_DATE                                  as "Дата импорта"
   ,ph.ids                                           as "Номер импортируемого договора"
   ,ph.policy_header_id                              as "policy_header_id из b2b"
   ,pr.description                                   as "Наименование продукта"
   ,count(pgt.RECEIVE_DATE) 
          over(partition by pgt.RECEIVE_DATE)        as "Кол-во имп договоров"
   ,min(RECEIVE_DATE)over()                          as "Время начала импорта"  
   ,count(pgt.P_POL_HEADER_ID) 
          over()                                     as "ДС появилось в Броласе"    
   ,max(RECEIVE_DATE)over()                          as "Время окончания импорта" 
from ins.p_policy_gate_table      pgt
   , ins.p_pol_header             ph 
   , ins.t_product                pr
where pgt.p_pol_header_id = ph.policy_header_id(+)    
  and pr.product_id       = ph.product_id;

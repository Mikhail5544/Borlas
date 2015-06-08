create view v_rep_doc_from_b2b
as
select 
   pgt.RECEIVE_DATE                                  as "���� �������"
   ,ph.ids                                           as "����� �������������� ��������"
   ,ph.policy_header_id                              as "policy_header_id �� b2b"
   ,pr.description                                   as "������������ ��������"
   ,count(pgt.RECEIVE_DATE) 
          over(partition by pgt.RECEIVE_DATE)        as "���-�� ��� ���������"
   ,min(RECEIVE_DATE)over()                          as "����� ������ �������"  
   ,count(pgt.P_POL_HEADER_ID) 
          over()                                     as "�� ��������� � �������"    
   ,max(RECEIVE_DATE)over()                          as "����� ��������� �������" 
from ins.p_policy_gate_table      pgt
   , ins.p_pol_header             ph 
   , ins.t_product                pr
where pgt.p_pol_header_id = ph.policy_header_id(+)    
  and pr.product_id       = ph.product_id;

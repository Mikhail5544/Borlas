CREATE OR REPLACE FORCE VIEW V_CALL_CLIENT AS
select rownum rec_number,
       dep.name depart,
       ent.obj_name('DOCUMENT', vlp.pol_header_id) dog_num,
       vlp.contact_name,
       prod.description product,
       f.name fund,
       t1.telephone_prefix||'-'||t1.telephone_number tel1,
       t2.telephone_prefix||'-'||t2.telephone_number tel2,
       t3.telephone_prefix||'-'||t3.telephone_number tel3,
       t4.telephone_prefix||'-'||t4.telephone_number tel4,
       t5.telephone_prefix||'-'||t5.telephone_number tel5,
       vlp.address_name,
       c.obj_name_orig agent,
       ch.description sale_ch,
       vlp.due_date,
       vlp.plan_date,
       vlp.grace_date,
       vlp.amount,
       vlp.pay_amount_dog,
       vlp.oplata,
       ph.ids

from v_letters_payment vlp
     left join p_policy_agent pa on (vlp.pol_header_id = pa.policy_header_id and pa.status_id not in (2,4))
     left join ag_contract_header ag on (ag.ag_contract_header_id = pa.ag_contract_header_id)
     left join t_sales_channel ch on (ch.id = ag.t_sales_channel_id)
     left join department dep on (dep.department_id = ag.agency_id)
     left join contact c on (c.contact_id = ag.agent_id)
     left join p_pol_header ph on (ph.policy_header_id = vlp.pol_header_id)
     left join t_product prod on (prod.product_id = ph.product_id)
     left join fund f on (f.fund_id = ph.fund_id)
     left join cn_contact_telephone t1 on (t1.contact_id = vlp.contact_id and t1.telephone_type = 1)
     left join cn_contact_telephone t2 on (t2.contact_id = vlp.contact_id and t2.telephone_type = 2)
     left join cn_contact_telephone t3 on (t3.contact_id = vlp.contact_id and t3.telephone_type = 3)
     left join cn_contact_telephone t4 on (t4.contact_id = vlp.contact_id and t4.telephone_type = 4)
     left join cn_contact_telephone t5 on (t5.contact_id = vlp.contact_id and t5.telephone_type = 181)
where vlp.plan_date between (SELECT to_date(param_value,'dd.mm.yyyy') FROM ins_dwh.rep_param WHERE rep_name = 'call_client' and param_name = 'start_date')
                                  and (SELECT to_date(param_value,'dd.mm.yyyy') FROM ins_dwh.rep_param WHERE rep_name = 'call_client' and param_name = 'end_date')
order by vlp.contact_name, ent.obj_name('DOCUMENT', vlp.pol_header_id);


create or replace force view v_sved_events_vl as
select count(AS_contact) over (Partition by AS_contact order by EV) as NUM_STR,
AS_contact, EV, V_1, V_2, V_3, V_4, V_5, V_6, V_7
from(
select rr.contact_id AS_contact,
       rr.ev EV,
       max(data) V_1,
       sum(decode(rr.status,'ЗАКРЫТО',decode(rr.descr,'Причинения вреда имуществу (ОСАГО)',1,0),0) ) V_2,
       sum(decode(rr.status,'ЗАКРЫТО',decode(rr.descr,'Причинения вреда имуществу (ОСАГО)',0,1),0) ) V_3,
       sum(decode(rr.status,'УРЕГУЛИРОВАНИЕ',1,'ИНФОРМИРОВАНИЕ',1,0) ) V_4,
       sum(nvl(rr.amount,0)) V_5,
       sum(rr.rez_sum) V_6,
       max(koef) V_7
from 
(
select cec.cn_person_id contact_id, ce.c_event_id ev, ch.c_claim_header_id, ccs.brief status, cc0.description descr, 0 amount , 0 rez_sum, '' data, '' koef
from ven_c_event ce 
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
join ven_c_event_contact cec on (ce.c_event_id=cec.c_event_id and cec.c_claim_header_id=ch.c_claim_header_id)
join ven_c_event_contact_role cr on (cec.c_event_contact_role_id=cr.c_event_contact_role_id and cr.brief='Водитель')
join (select  cc.c_claim_header_id,  tp.description, max (cc.c_claim_id) claim_id
     from ven_c_claim cc 
     join ven_c_damage cd on (cd.c_claim_id=cc.c_claim_id)
     join ven_t_damage_code tdc on (tdc.id=cd.t_damage_code_id)
     join ven_t_peril tp on (tp.id=tdc.peril)
     group by cc.c_claim_header_id, tp.description
     ) cc0 on (cc0.c_claim_header_id=ch.c_claim_header_id )
join (select cl.c_claim_id, cs.brief from ven_c_claim_status cs,  ven_c_claim cl  
      where cs.c_claim_status_id=cl.claim_status_id) ccs  on (ccs.c_claim_id= cc0.claim_id)

union all

select cec.cn_person_id contact_id, ce.c_event_id, ch.c_claim_header_id,  '' status, '' descr,  tr.acc_amount amount, 0 rez_sum, '' data, '' koef
from ven_c_event ce 
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
join ven_c_event_contact cec on (ce.c_event_id=cec.c_event_id and cec.c_claim_header_id=ch.c_claim_header_id)
join ven_c_event_contact_role cr on (cec.c_event_contact_role_id=cr.c_event_contact_role_id and cr.brief='Водитель')
join (select  cc.c_claim_header_id, max (cc.c_claim_id) claim_id
     from ven_c_claim cc 
     group by cc.c_claim_header_id
     ) cc0 on (cc0.c_claim_header_id=ch.c_claim_header_id )
join ven_c_damage cd on (cd.c_claim_id=cc0.claim_id)
join ven_trans tr on (cd.c_damage_id=tr.a5_dt_uro_id)
join ven_trans_templ tt on (tt.trans_templ_id = tr.trans_templ_id and tt.brief in ('ЗачВыплКонтр','ЗачВыплВыгод'))

union all

select cec.cn_person_id contact_id, ce.c_event_id, ch.c_claim_header_id,  '' status, '' descr,  0 amount, (nvl(cc1.declare_sum,0) - nvl(cc2.acc_amount,0)) rez_sum, '' data, '' koef
from ven_c_event ce 
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
join ven_c_event_contact cec on (ce.c_event_id=cec.c_event_id and cec.c_claim_header_id=ch.c_claim_header_id)
join ven_c_event_contact_role cr on (cec.c_event_contact_role_id=cr.c_event_contact_role_id and cr.brief='Водитель')
join ( select t.c_claim_header_id, max(t.c_claim_id) c_claim_id,  t.declare_sum 
       from ven_c_claim t
       join ven_c_damage cd on (cd.c_claim_id=t.c_claim_id)
       group by t.c_claim_header_id, t.declare_sum 
      ) cc1 on (cc1.c_claim_header_id=ch.c_claim_header_id )
left join ( select c.c_claim_header_id,  sum(tr.acc_amount) acc_amount
       from ven_c_claim c
       join ven_c_damage cd on (cd.c_claim_id=c.c_claim_id)
       join ven_trans tr on (cd.c_damage_id=tr.a5_dt_uro_id)
       join ven_trans_templ tt on (tt.trans_templ_id = tr.trans_templ_id and tt.brief in ('ЗачВыплКонтр','ЗачВыплВыгод'))
       group by c.c_claim_header_id
     ) cc2 on (cc2.c_claim_header_id=ch.c_claim_header_id ) 
) rr
group by rr.contact_id, rr.ev);


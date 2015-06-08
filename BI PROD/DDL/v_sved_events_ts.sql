create or replace force view v_sved_events_ts as
select count(qq.PH_ID) over (Partition by qq.PH_ID order by qq.EV) NUM_STR,
qq.PH_ID,qq.AS_ASSET,qq.ev, qq.TS_1,qq.TS_2,qq.TS_3,qq.TS_4,qq.TS_5, qq.TS_6, qq.TS_7
from
(select rr.policy_header_id PH_ID,
       rr.as_asset_id AS_ASSET,
       rr.ev,
       max(data) TS_1,
       sum(decode(rr.status,'ÇÀÊĞÛÒÎ',decode(rr.descr,'Ïğè÷èíåíèÿ âğåäà èìóùåñòâó (ÎÑÀÃÎ)',1,0),0) )TS_2,
       sum(decode(rr.status,'ÇÀÊĞÛÒÎ',decode(rr.descr,'Ïğè÷èíåíèÿ âğåäà èìóùåñòâó (ÎÑÀÃÎ)',0,1),0) )TS_3,
       sum(decode(rr.status,'ÓĞÅÃÓËÈĞÎÂÀÍÈÅ',1,'ÈÍÔÎĞÌÈĞÎÂÀÍÈÅ',1,0) )TS_4,
       sum(nvl(rr.amount,0)) TS_5,
       sum(rez_sum) TS_6,
       max(koef) TS_7
from 
(
select ph.policy_header_id, ass.as_asset_id, ce.c_event_id ev, ch.c_claim_header_id, ccs.brief status, cc0.description descr, 0 amount , 0 rez_sum,  to_char(pp.start_date,'DD.MM.YYYY')||' - '||to_char(pp.end_date,'DD.MM.YYYY') data, '' koef
from ven_p_pol_header ph
join ven_p_policy pp on (pp.pol_header_id = ph.policy_header_id)
join ven_as_vehicle av on av.p_policy_id = pp.policy_id
join ven_as_asset ass on  (ass.p_policy_id = pp.policy_id and ass.as_asset_id = av.as_vehicle_id)
join ven_c_event ce on (ass.as_asset_id=ce.as_asset_id)
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
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

select ph.policy_header_id, ass.as_asset_id, ce.c_event_id ev, ch.c_claim_header_id, '' status, '' descr, tr.acc_amount amount , 0 rez_sum,  '' data, '' koef
from ven_p_pol_header ph
join ven_p_policy pp on (pp.pol_header_id = ph.policy_header_id )
join ven_as_vehicle av on av.p_policy_id = pp.policy_id
join ven_as_asset ass on  (ass.p_policy_id = pp.policy_id and ass.as_asset_id = av.as_vehicle_id)
join ven_c_event ce on (ass.as_asset_id=ce.as_asset_id)
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
join (select  cc.c_claim_header_id, max (cc.c_claim_id) claim_id
     from ven_c_claim cc 
     group by cc.c_claim_header_id
     ) cc0 on (cc0.c_claim_header_id=ch.c_claim_header_id )
join ven_c_damage cd on (cd.c_claim_id=cc0.claim_id)
join ven_trans tr on (cd.c_damage_id=tr.a5_dt_uro_id)
join ven_trans_templ tt on (tt.trans_templ_id = tr.trans_templ_id and tt.brief in ('Çà÷ÂûïëÊîíòğ','Çà÷ÂûïëÂûãîä'))

union all

select ph.policy_header_id, ass.as_asset_id, ce.c_event_id, ch.c_claim_header_id,  '' status, '' descr,  0 amount, (nvl(cc1.declare_sum,0) - nvl(cc2.acc_amount,0)) rez_sum,  '' data, '' koef
from ven_p_pol_header ph
join ven_p_policy pp on (pp.pol_header_id = ph.policy_header_id )
join ven_as_vehicle av on av.p_policy_id = pp.policy_id
join ven_as_asset ass on  (ass.p_policy_id = pp.policy_id and ass.as_asset_id = av.as_vehicle_id)
join ven_c_event ce on (ass.as_asset_id=ce.as_asset_id)
join ven_c_claim_header ch on (ch.c_event_id=ce.c_event_id)
join ( select t.c_claim_header_id, max(t.c_claim_id) c_claim_id,  t.declare_sum 
       from ven_c_claim t
       join ven_c_damage cd on (cd.c_claim_id=t.c_claim_id)
       group by t.c_claim_header_id, t.declare_sum 
      ) cc1 on (cc1.c_claim_header_id=ch.c_claim_header_id )
left join ( select c.c_claim_header_id,  sum(tr.acc_amount) acc_amount
       from ven_c_claim c
       join ven_c_damage cd on (cd.c_claim_id=c.c_claim_id)
       join ven_trans tr on (cd.c_damage_id=tr.a5_dt_uro_id)
       join ven_trans_templ tt on (tt.trans_templ_id = tr.trans_templ_id and tt.brief in ('Çà÷ÂûïëÊîíòğ','Çà÷ÂûïëÂûãîä'))
       group by c.c_claim_header_id
     ) cc2 on (cc2.c_claim_header_id=ch.c_claim_header_id ) 

) rr
group by rr.policy_header_id,rr.as_asset_id, rr.ev
) qq
/*where PH_ID=:P_policy_header_id --62049 
  and AS_ASSET in (select ass1.as_asset_id
                   from ven_p_pol_header ph1
                   join ven_p_policy pp1 on (pp1.pol_header_id = ph1.policy_header_id)
                   join ven_as_vehicle av1 on av1.p_policy_id = pp1.policy_id
                   join ven_as_asset ass1 on  (ass1.p_policy_id = pp1.policy_id and ass1.as_asset_id = av1.as_vehicle_id)
                   where ph1.policy_header_id=:P_policy_header_id --62049
                     and rownum=1)
                    */
;


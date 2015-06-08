create materialized view INS_DWH.MV_CR_ERR_SERVICE
refresh force on demand
as
select num.act,
     aa.assured_contact_id,                                          --ИД ФИО застрахованного
      sm.c_service_med_id,                                             --ИД услуги
       rsa.serv_count,
       rsa.serv_amount
from (select'№ '||da1.num||' от '||to_char(da1.act_date,'dd.mm.yyyy')||' на сумму '||decode(sum(rsa1.serv_amount),'0','0',to_char(sum(rsa1.serv_amount),'999999999D99'))||' '||f.brief act,
     da1.dms_act_id act_id
       from ins.ven_dms_rel_serv_act rsa1,
     ins.ven_dms_act da1, ins.ven_doc_doc dd,
     ins.ven_dms_serv_act dsa,
     ins.ven_fund f,
     ins.ven_doc_templ dt
     where
          rsa1.dms_act_id=da1.dms_act_id
           and dd.child_id=da1.dms_act_id
      and dsa.dms_serv_act_id=dd.parent_id
      and f.fund_id=dsa.fund_id
      and upper(dt.brief) in ('DMS_ACT_FIRST_MED', 'DMS_ACT_SELECT_MED', 'DMS_ACT_DIRECT_MED', 'DMS_ACT_TECH')
      and da1.doc_templ_id=dt.doc_templ_id
      group by da1.num, da1.act_date, f.brief, da1.dms_act_id) num,
      ins.ven_c_service_med sm,
    ins.ven_as_assured aa,
     ins.ven_dms_rel_serv_act rsa
where rsa.dms_act_id=num.act_id
      and sm.c_service_med_id=rsa.c_service_med_id
      and aa.as_assured_id(+)=sm.as_asset_id;


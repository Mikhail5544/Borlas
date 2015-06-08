create materialized view INS_DWH.MV_CR_LPU_PRICE
build deferred
refresh force on demand
as
select cl.NUM, f.BRIEF, vdp.CODE, vdp.NAME, vdp.AMOUNT
  from ins.ven_contract_lpu cl, ins.ven_dms_price vdp, ins.ven_fund f
 where vdp.fund_id = f.fund_id
   AND vdp.status_hist_id IN (1, 2)
   and cl.curr_version_id = vdp.contract_lpu_ver_id;


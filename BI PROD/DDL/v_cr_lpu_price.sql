create or replace force view v_cr_lpu_price as
select cl.NUM, f.BRIEF, vdp.CODE, vdp.NAME, vdp.AMOUNT
  from ven_contract_lpu cl, ven_dms_price vdp, ven_fund f
 where vdp.fund_id = f.fund_id
   AND vdp.status_hist_id IN (1, 2)
   and cl.curr_version_id = vdp.contract_lpu_ver_id;


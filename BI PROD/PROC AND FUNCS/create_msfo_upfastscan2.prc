create or replace procedure CREATE_MSFO_UPFASTSCAN2 (f number, l number)
 as
 begin
  PKG_INS_LOG.EventTrace := Utils.c_true;
  PKG_INS_LOG.SP_EventInfo('старт','нет','CREATE_MSFO_UPFASTSCAN(f:'||f||',l:'||l);
    update 
  TMP_CREATE_MSFO_2 t
 set 
 t.P_ST = av_oav_pol_ag_com(t.p_policy_agent_com_id/*,t.trans_date*/) 
   where RN >= f and RN < l ;
   commit;
  PKG_INS_LOG.SP_EventInfo('конец','нет','CREATE_MSFO_UPFASTSCAN(f:'||f||',l:'||l);
 end;
/


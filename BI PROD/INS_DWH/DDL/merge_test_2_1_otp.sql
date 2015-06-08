create or replace force view ins_dwh.merge_test_2_1_otp as
select v.POLICY_HEADER_ID 
from 
ins.VEN_P_POL_HEADER v, ins.P_POLICY PP 
where v.START_DATE < to_date('01.09.2007','dd.mm.yyyy') 
and  v.POLICY_ID = PP.POLICY_ID 
and PP.END_DATE  > to_date('01.12.2007','dd.mm.yyyy');


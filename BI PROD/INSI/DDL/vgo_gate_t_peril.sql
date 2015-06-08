create or replace force view vgo_gate_t_peril as
select T.ID as CODE,T.DESCRIPTION,T.INSURANCE_GROUP_ID from ins.T_PERIL T;


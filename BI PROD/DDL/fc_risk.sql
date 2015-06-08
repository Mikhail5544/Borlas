
create view ins.fc_risk
as
select plop.product_line_option_id as risk_type_id
,p.id as risk_id
,p.description "Наименование Риска"
,p.brief "Сокр Наим. Риска"
from 
ins.VEN_T_PROD_LINE_OPT_PERIL PLOP
, ins.VEN_T_PERIL P
where PLOP.PERIL_ID = P.ID;


grant select on ins.fc_risk to ins_read;
grant select on ins.fc_risk to ins_eul;

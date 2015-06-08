create materialized view INS_DWH.MV_CR_NEB_POLICY_NUM
build deferred
refresh force on demand
as
select ph.policy_header_id, -- id заголовка полиса
       pkg_rep_utils_ins11.get_pol_agency_name(ph.agency_id) as dep, -- агентство
       ph.num as pol_num, -- номер договора
       ins.doc.get_doc_status_name (pp.policy_id) as status, -- статус договора
       ph.start_date, -- дата начала договора
       pp.end_date, -- дата окончания договора
       ins.pkg_rep_utils.get_notice_date (ph.policy_header_id) as not_date, -- дата 1 заявления
       pp.premium -- годовая премия по договору
from ins.ven_p_pol_header ph
join ins.ven_p_policy pp on pp.policy_id = ph.policy_id;


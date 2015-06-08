create materialized view INS_DWH.MV_CR_POLICY_EDITION
build deferred
refresh force on demand
as
select pr.description as product, -- продукт
       pp.pol_ser, -- серия
       pp.pol_num, -- номер
       pp.num, -- номер договора
       pp.policy_id, -- id полиса
       pp.notice_num,-- номер заявления
       pr.brief as programm_code, -- код программы
       ins.doc.get_status_date (pp.policy_id,'ACTIVE') as st_active_date, -- дата статуса активный
       ins.doc.get_status_date (pp.policy_id,'UNDERWRITING') as st_under_date -- дата статуса андеррайтинг
from ins.ven_p_pol_header ph
   join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
   join ins.ven_t_product pr on pr.product_id = ph.product_id
   where ins.doc.get_doc_status_brief (pp.policy_id) = 'ACTIVE';


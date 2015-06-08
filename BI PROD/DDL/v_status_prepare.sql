create or replace force view v_status_prepare as
select pp.pol_ser,
       pp.pol_num,
       pp.notice_num,
       pp.notice_date,
       pp.start_date as begin_date,
       pp.end_date,
       pp.premium,
       pp.ins_amount,
       pp.version_num,
       ss.start_date,
       ss.user_name,
       ss.change_date

from (select max(pol.policy_id) pol_id, pol.pol_header_id
      from (select pp.policy_id, pp.pol_header_id
           from p_policy pp
                left join doc_status ss on (ss.document_id = pp.policy_id)
           where ss.doc_status_ref_id = 21) pol
      group by pol.pol_header_id) pol
      left join p_policy pp on (pol.pol_id = pp.policy_id)
      left join doc_status ss on (ss.document_id = pp.policy_id and ss.doc_status_ref_id = 21);


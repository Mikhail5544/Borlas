create materialized view INS_DWH.MV_CR_POLICY_EDITION
build deferred
refresh force on demand
as
select pr.description as product, -- �������
       pp.pol_ser, -- �����
       pp.pol_num, -- �����
       pp.num, -- ����� ��������
       pp.policy_id, -- id ������
       pp.notice_num,-- ����� ���������
       pr.brief as programm_code, -- ��� ���������
       ins.doc.get_status_date (pp.policy_id,'ACTIVE') as st_active_date, -- ���� ������� ��������
       ins.doc.get_status_date (pp.policy_id,'UNDERWRITING') as st_under_date -- ���� ������� ������������
from ins.ven_p_pol_header ph
   join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
   join ins.ven_t_product pr on pr.product_id = ph.product_id
   where ins.doc.get_doc_status_brief (pp.policy_id) = 'ACTIVE';


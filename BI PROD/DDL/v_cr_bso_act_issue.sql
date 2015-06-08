create or replace force view v_cr_bso_act_issue as
select bs.bso_type_id,      -- ��� (���) ���
       bd.reg_date,         -- ���� ���� ������
	   bd.num,              -- ����� ���� ������
	   bs.bso_series_id,    -- �� ����� ���
	   bdc.num_start,       -- ����� ������� ������
	   bdc.num_end,         -- ����� ���������� ������
	   bd.contact_from_id,  -- �� ����������� ������������� (��)
	   bd.contact_to_id,    -- �� ������������ (������)
	   bd.department_from_id,  -- �� ������������ ��
	   bd.department_to_id     -- �� ������������ ������
from
	ven_bso_document bd,
	ven_bso_doc_cont bdc,
    ven_doc_templ dt,
	ven_bso_series bs
where
	bd.doc_templ_id = dt.doc_templ_id
and	bd.bso_document_id = bdc.bso_document_id
and bs.bso_series_id = bdc.bso_series_id
and	dt.brief = '���������'
;


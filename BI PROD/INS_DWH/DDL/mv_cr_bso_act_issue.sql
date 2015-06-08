create materialized view INS_DWH.MV_CR_BSO_ACT_ISSUE
refresh force on demand
as
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
	ins.ven_bso_document bd,
	ins.ven_bso_doc_cont bdc,
    ins.ven_doc_templ dt,
	ins.ven_bso_series bs
where
	bd.doc_templ_id = dt.doc_templ_id
and	bd.bso_document_id = bdc.bso_document_id
and bs.bso_series_id = bdc.bso_series_id
and	dt.brief = '���������';


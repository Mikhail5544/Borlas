create or replace force view v_cr_assured_prop as
select c_lpu.contact_id, --�� ���
ent.obj_name('P_POLICY', pp.policy_id) policy_num, -- � ������ ��������
pp.policy_id, -- �� ������ ��������
pp.start_date dog_start, --���� ������ ��������
pp.end_date dog_end, --���� ��������� ��������
aa.card_num card_num, -- � ������
aa.card_date assured_start_date, -- ���� ������ ������
aa.end_date assured_end_date, -- ���� ��������� ������
cast(null as date) assured_stop_date, -- ���� �������������
tpld.code code, -- ��� ���������
cast(null as varchar(2000)) note, -- ����������
aa.start_date, --���� ������ �����������
aa.assured_contact_id, --�� ��������������� �� ���������
aa.as_assured_id, --�� ��������������� �� ������ ��������
ent.obj_name('P_POL_HEADER',pph.policy_header_id) dog_num,--� ��������
pph.policy_header_id,                              --�� ��������
decode(upper(tplt.brief),'RISC','����','DEPOS','�������','����.') prod_type--��� ���������
from ven_as_assured aa,
ven_contact c_policy,
ven_p_policy pp,
ven_p_cover pc,
ven_t_prod_line_option tplo,
ven_t_prod_line_dms tpld,
ven_parent_prod_line ppl,
ven_par_prod_line_cont pplc,
ven_cn_company c_lpu,
ven_p_pol_header pph,
ven_t_product_line_type tplt
where
c_lpu.contact_id = pplc.contact_id
and pplc.parent_prod_line_id = ppl.parent_prod_line_id
and ppl.t_parent_prod_line_id = tpld.t_prod_line_dms_id
and tpld.t_prod_line_dms_id = tplo.product_line_id
and tplo.id = pc.t_prod_line_option_id
and pc.as_asset_id = aa.as_assured_id
and c_policy.contact_id = aa.contact_id
and pp.policy_id = aa.p_policy_id
and pph.policy_id=pp.policy_id
and tplt.product_line_type_id=tpld.product_line_type_id
;


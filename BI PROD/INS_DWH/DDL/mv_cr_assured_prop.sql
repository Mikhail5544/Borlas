create materialized view INS_DWH.MV_CR_ASSURED_PROP
refresh force on demand
as
select c_lpu.contact_id, --�� ���
       ins.ent.obj_name('P_POLICY', pp.policy_id) policy_num, -- � ������ ��������
       pp.policy_id, -- �� ������ ��������
       pp.start_date dog_start, --���� ������ ��������
       pp.end_date dog_end, --���� ��������� ��������
       aa.card_num card_num, -- � ������
       aa.card_date assured_start_date, -- ���� ������ ������
       aa.end_date assured_end_date, -- ���� ��������� ������
       cast(null as date) assured_stop_date, -- ���� �������������
       tpld.code code, -- ��� ���������
       cast(null as varchar2(2000)) note, -- ����������
       aa.start_date, --���� ������ �����������
       aa.assured_contact_id, --�� ��������������� �� ���������
       aa.as_assured_id, --�� ��������������� �� ������ ��������
       ins.ent.obj_name('P_POL_HEADER', pph.policy_header_id) dog_num, --� ��������
       pph.policy_header_id, --�� ��������
       decode(upper(tplt.brief),
              'RISC',
              '����',
              'DEPOS',
              '�������',
              '����.') prod_type --��� ���������
  from ins.ven_as_assured          aa,
       ins.ven_contact             c_policy,
       ins.ven_p_policy            pp,
       ins.ven_p_cover             pc,
       ins.ven_t_prod_line_option  tplo,
       ins.ven_t_prod_line_dms     tpld,
       ins.ven_parent_prod_line    ppl,
       ins.ven_par_prod_line_cont  pplc,
       ins.ven_cn_company          c_lpu,
       ins.ven_p_pol_header        pph,
       ins.ven_t_product_line_type tplt
 where c_lpu.contact_id = pplc.contact_id
   and pplc.parent_prod_line_id = ppl.parent_prod_line_id
   and ppl.t_parent_prod_line_id = tpld.t_prod_line_dms_id
   and tpld.t_prod_line_dms_id = tplo.product_line_id
   and tplo.id = pc.t_prod_line_option_id
   and pc.as_asset_id = aa.as_assured_id
   and c_policy.contact_id = aa.contact_id
   and pp.policy_id = aa.p_policy_id
   and pph.policy_id = pp.policy_id
   and tplt.product_line_type_id = tpld.product_line_type_id;


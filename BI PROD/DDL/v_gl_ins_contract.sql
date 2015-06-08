create or replace force view v_gl_ins_contract as
select 1 CONTRACT_TYPE_ID, -- ��� ��������: 1 - ������, 2 - ��������, 3  - ����������
       999 FINANCE_PERIOD_ID, -- ���������� ������
       ph.fund_id CURRENCY_ID, -- ������ ��������
       pl.insurance_group_id INS_LICENCE_TYPE_ID, -- ��� �����������
       pc.start_date BEGIN_DATE, -- ���� ������
       pc.end_date END_DATE,   -- ���� ���������
       nach_first.trans_date ACC_DATE, -- ���� ������� ����������
       pp.sign_date REG_DATE, -- ���� �����������
       0 PROPORTIONAL, --���� ��� �������� = "��������", �� ����������� ���������������� �� ��� ���
       case doc.get_doc_status_name(pp.policy_id) -- ���� �����������
        when '����������' then pp.start_date 
        else null
       end CANCEL_DATE,
       nach_prem.prem PREMIUM_AMOUNT, -- ����������� ������,
       pp.num CONTR_NUMBER, -- ����� �������� 
       pc.ent_id ORIGIN_ID, -- �� ������������ ��������
       com.prem COMPENS_AMOUNT, -- �������������� �� ��������
       0 DEDUCT_AMOUNT,--����� ���������� �� ��������
       0 DECLARED_CLAIM_AMOUNT,--����� �����������  �� �������� ������
       0 PAYS_CLAIM_AMOUNT,--����� ������ �� ������
       0 CANCEL_PAYMENTS--������� � ����� � ������������
from ven_p_cover pc
 join t_prod_line_option plo on plo.id = pc.t_prod_line_option_id
 join t_product_line pl on pl.id = plo.product_line_id
 join as_asset ass on ass.as_asset_id  = pc.as_asset_id
 join ven_p_policy pp on pp.policy_id = ass.p_policy_id
 join p_pol_header ph on ph.policy_header_id = pp.pol_header_id
 join ( select  distinct tr.A5_DT_URO_ID cover,tr.trans_date 
        from trans tr
         join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
        where tt.brief = '���������' 
          and tr.trans_date = (select min (tr1.trans_date)
                               from trans tr1
                               where tr1.a5_dt_uro_id = tr.a5_dt_uro_id
                                 and tr1.trans_templ_id = tr.trans_templ_id
                              )
      ) nach_first on nach_first.cover = pc.p_cover_id
 join ( select  tr.a5_dt_uro_id cover,sum(tr.trans_amount) prem
        from trans tr
         join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
        where tt.brief = '���������' 
        group by tr.a5_dt_uro_id
      ) nach_prem on nach_prem.cover = pc.p_cover_id  
 left join ( select tr.A5_CT_URO_ID cover,nvl(sum(tr.acc_amount),0) prem
             from trans tr
              join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
             where tt.brief in ('�����')
             group by tr.A5_CT_URO_ID
            ) com on com.cover = pc.p_cover_id
;


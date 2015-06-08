create or replace force view ins_dwh.v_rep_work_lost as
select ph.ids,
       p.pol_num,
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(p.policy_id,'������������')) "������������",
       ins.doc.get_doc_status_name(p.policy_id) "������ ��� ������",
       pc.premium,
       f.brief "������",
       pt.description "������������� ������",
       ph.start_date  "���� ������ ��",
       pr.description "�������"
  from ins.p_pol_header ph,
       ins.fund         f,
       ins.p_policy     p,
       ins.as_asset     aa,
       ins.status_hist  ash,
       ins.p_cover      pc,
       ins.status_hist  psh,
       ins.t_prod_line_option plo,
       ins.t_payment_terms    pt,
       ins.t_product          pr
 where p.policy_id = ph.policy_id
   and pr.product_id = ph.product_id
   and f.fund_id = ph.fund_id
   and aa.p_policy_id = p.policy_id
   and ash.status_hist_id = aa.status_hist_id
   and ash.brief <> 'DELETED'
   and pc.as_asset_id = aa.as_asset_id
   and psh.status_hist_id = pc.status_hist_id
   and psh.brief <> 'DELETED'
   and plo.id = pc.t_prod_line_option_id
   and plo.description = '������� ������������ �� ������ ���������� ������ �� ����������� �� ���� ��������'
   and pt.id = p.payment_term_id;


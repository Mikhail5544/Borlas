create materialized view INS_DWH.MV_CR_FIN_OPERATION
build deferred
refresh force on demand
as
select t.trans_id as "�� ��������",
       tt.name as "��� ��������",
       dt.num as "�����",
       ct.num as "������",
       t.trans_date as "���� ��������",
       t.acc_amount as "����� � ������ ���-��",
       fa.brief as "������ ���-��",
       t.trans_amount as "����� � ������ �������",
       ft.brief as "������ �������",
       atdt1.name as "��� ��������� �1",
       ins.ent.obj_name(t.a1_dt_ure_id, t.a1_dt_uro_id) as "���� ��������� �1",
       atdt2.name as "��� ��������� �2",
       ins.ent.obj_name(t.a2_dt_ure_id, t.a2_dt_uro_id) as "���� ��������� �2",
       atdt3.name as "��� ��������� �3",
       ins.ent.obj_name(t.a3_dt_ure_id, t.a3_dt_uro_id) as "���� ��������� �3",
       atdt4.name as "��� ��������� �4",
       ins.ent.obj_name(t.a4_dt_ure_id, t.a4_dt_uro_id) as "���� ��������� �4",
       atdt5.name as "��� ��������� �5",
       ins.ent.obj_name(t.a5_dt_ure_id, t.a5_dt_uro_id) as "���� ��������� �5",
       atct1.name as "��� ��������� �1",
       ins.ent.obj_name(t.a1_dt_ure_id, t.a1_dt_uro_id) as "���� ��������� �1",
       atct2.name as "��� ��������� �2",
       ins.ent.obj_name(t.a2_dt_ure_id, t.a2_dt_uro_id) as "���� ��������� �2",
       atct3.name as "��� ��������� �3",
       ins.ent.obj_name(t.a3_dt_ure_id, t.a3_dt_uro_id) as "���� ��������� �3",
       atct4.name as "��� ��������� �4",
       ins.ent.obj_name(t.a4_dt_ure_id, t.a4_dt_uro_id) as "���� ��������� �4",
       atct5.name as "��� ��������� �5",
       ins.ent.obj_name(t.a5_dt_ure_id, t.a5_dt_uro_id) as "���� ��������� �5",
       cover_info."����� ��������",cover_info."����� ���������",cover_info."�� �������� BI",cover_info."�� �������� LIS",cover_info."�� �������� BI",cover_info."�� �������� LIS",cover_info."���� ������ ��������",cover_info."���� ��������� ��������",cover_info."���-�� �������� � ���",cover_info."����� �� ��������",cover_info."������� ������ �� ��������",cover_info."���-� ���������",cover_info."�����",cover_info."���������",cover_info."�������",cover_info."�� ��������"
  from ins.trans t,
       ins.trans_templ tt,
       ins.account dt,
       ins.account ct,
       ins.fund ft,
       ins.fund fa,
       ins.analytic_type atdt1,
       ins.analytic_type atdt2,
       ins.analytic_type atdt3,
       ins.analytic_type atdt4,
       ins.analytic_type atdt5,
       ins.analytic_type atct1,
       ins.analytic_type atct2,
       ins.analytic_type atct3,
       ins.analytic_type atct4,
       ins.analytic_type atct5,
       (select p.pol_ser || '-' || p.pol_num as "����� ��������",
               p.notice_ser || '-' || p.notice_num as "����� ���������",
               p.pol_header_id as "�� �������� BI",
               p.ext_id as "�� �������� LIS",
               pc.p_cover_id as "�� �������� BI",
               pc.ext_id as "�� �������� LIS",
               pc.start_date as "���� ������ ��������",
               pc.end_date as "���� ��������� ��������",
               pt.number_of_payments as "���-�� �������� � ���",
               pc.fee as "����� �� ��������",
               pc.premium as "������� ������ �� ��������",
               pt.description as "���-� ���������",
               ig.life_property as "�����",
               ll.description as "���������",
               pr.description as "�������",
               pc.ent_id as "�� ��������"
          from ins.ven_p_cover        pc,
               ins.as_asset           a,
               ins.ven_p_policy       p,
               ins.t_prod_line_option plo,
               ins.t_product_line     pl,
               ins.t_product_ver_lob  pvl,
               ins.t_product_version  pv,
               ins.t_product          pr,
               ins.t_lob_line         ll,
               ins.t_insurance_group  ig,
               ins.t_payment_terms    pt
         where pc.as_asset_id = a.as_asset_id
           and a.p_policy_id = p.policy_id
           and pc.t_prod_line_option_id = plo.id
           and plo.product_line_id = pl.id
           and pl.t_lob_line_id = ll.t_lob_line_id
           and ll.insurance_group_id = ig.t_insurance_group_id
           and pvl.t_product_ver_lob_id = pl.product_ver_lob_id
           and pv.t_product_version_id = pvl.product_version_id
           and pv.product_id = pr.product_id
           and p.payment_term_id = pt.id) cover_info
 where tt.trans_templ_id = t.trans_templ_id
   and dt.account_id = t.dt_account_id
   and ct.account_id = t.ct_account_id
   and ft.fund_id = t.trans_fund_id
   and fa.fund_id = t.acc_fund_id
   and dt.a1_analytic_type_id = atdt1.analytic_type_id (+)
   and dt.a2_analytic_type_id = atdt2.analytic_type_id (+)
   and dt.a3_analytic_type_id = atdt3.analytic_type_id (+)
   and dt.a4_analytic_type_id = atdt4.analytic_type_id (+)
   and dt.a5_analytic_type_id = atdt5.analytic_type_id (+)
   and ct.a1_analytic_type_id = atct1.analytic_type_id (+)
   and ct.a2_analytic_type_id = atct2.analytic_type_id (+)
   and ct.a3_analytic_type_id = atct3.analytic_type_id (+)
   and ct.a4_analytic_type_id = atct4.analytic_type_id (+)
   and ct.a5_analytic_type_id = atct5.analytic_type_id (+)
   and t.obj_uro_id = cover_info."�� �������� BI"(+)
   and t.obj_ure_id = cover_info."�� ��������"(+);


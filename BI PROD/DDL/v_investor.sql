CREATE OR REPLACE VIEW V_INVESTOR AS
select pp.pol_header_id                   pol_header_id,
       pp.policy_id                       policy_id,
       ph.ids                             ids,
       pp.pol_ser                         "�����",
       pp.pol_num                         "�����",
       cpol.obj_name_orig                 "������������",
       prod.description                   "�������",
       ph.start_date                      "���� ������ ��",
       pp.start_date                      "���� ������ ������ ��",
       pp.end_date                        "���� ��������� ������ ��",
       f.brief                            "������ ���������������",
       trm.description                    "������",
       opt.description                    "������ ������ �� ���������",
       pc.ins_amount                      "��������� �����",
       pc.fee                             "������ �����",
       pc.premium                         "������",
       dep.name                           "�������������",
       rfph.name                          "������ ��������� ������",
       /*pkg_policy.get_last_version_status(ph.policy_header_id) "������ ��������� ������",*/
       ac.plan_date "���� �������",
       ac.grace_date "���� �������",
       (SELECT trunc(ds.start_date)
        FROM ins.doc_status ds
        WHERE ds.doc_status_id = dac.doc_status_id) "���� �������",
       o.name "��� ��������",
       tr.trans_amount "����� ��������",
       tr.trans_date "���� ��������",
       ag_p_name.ag_name "����� �� ��������"
from ins.p_policy                     pp,
     ins.p_pol_header                 ph,
     ins.document                     dph,
     ins.doc_status_ref               rfph,
     ins.fund                         f,
     ins.t_contact_pol_role           polr,
     ins.p_policy_contact             pcnt,
     ins.contact                      cpol,
     ins.t_payment_terms              trm,
     ins.t_product                    prod,
     ins.t_product_group              pg,  -- ������ 235198: ����� ��.�������� � ���������� "������ ��������� 
     ins.as_asset                     a,
     ins.p_cover                      pc,
     ins.t_prod_line_option           opt,
     ins.department                   dep,
     
     ins.doc_doc                      dd,
     ins.ac_payment                   ac,
     ins.document                     dac,
     ins.doc_set_off                  dsf,
     ins.oper                         o,
     ins.trans                        tr,
     (SELECT ach.num||' '||cn.obj_name_orig as ag_name, ppad.policy_header_id
  FROM ins.p_policy_agent_doc     ppad
      ,ins.document               dc  --2
     -- ,ins.document               dc_ag
      ,ins.contact                cn
      ,ins.ven_ag_contract_header ach      
 WHERE dc.document_id             = ppad.p_policy_agent_doc_id
   AND dc.doc_status_ref_id       = 2 --�����������
   AND ach.ag_contract_header_id  = ppad.ag_contract_header_id
   AND cn.contact_id              = ach.agent_id) ag_p_name
where pp.pol_header_id                = ph.policy_header_id
      and polr.brief                  = '������������'
      and pcnt.policy_id(+)           = pp.policy_id
      AND ph.last_ver_id              = dph.document_id
      AND dph.doc_status_ref_id       = rfph.doc_status_ref_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id             = pcnt.contact_id
      and ph.fund_id                  = f.fund_id
      and pp.payment_term_id          = trm.id
      AND ph.product_id               = prod.product_id            
      /*����������� ������ 235198: ����� ��.�������� � ���������� "������ ��������� 
        AND prod.product_id IN (45581, --����� � ������� (��������) ��� ��� ���� "��������"
                              41175, --��������
                              44056, --�������� ����� ����
                              44655, --�������� � �������������� ������ ������
                              42795, --�������� � �������������� ������ ������_������
                              --������ 197612. ���������. 01.11.2012
                              46557,46556, --�������� ����
                              46298, --��������� ������ (�������������� ��������) ��������
                              46296 --��������� ������ (���������� ��������) ��������
                              )*/
      --������� ������  235198: ����� ��.�������� � ���������� "������ ���������                               
      and pg.t_product_group_id       = prod.t_product_group_id      
      and pg.brief                    = '��������'
      and prod.product_id             not in (28487 --�������� �������
                                            , 42000)--�������� ������� 2011
      --
      and pp.policy_id                = a.p_policy_id
      and a.as_asset_id               = pc.as_asset_id
      and pc.t_prod_line_option_id    = opt.id
      and ph.agency_id                = dep.department_id(+)
      and dd.parent_id                = pp.policy_id
      and dd.child_id                 = ac.payment_id
      AND ac.payment_id               = dac.document_id
      and dac.doc_status_ref_id       = 6/*'PAID'*/
      and dac.doc_templ_id            = 4/*'PAYMENT'*/
   --   AND ph.ids                      = 6180003217
      AND dsf.parent_doc_id           = ac.payment_id
      AND dsf.cancel_date             IS NULL
      AND dsf.doc_set_off_id          = o.document_id
      AND o.oper_id                   = tr.oper_id
      AND o.oper_templ_id             = 3201/*1825*/
      /*'��������� ������ ����� �������'*/
      /*'��������� ������ ��������'*/
      AND (tr.a4_dt_uro_id = opt.id
           OR tr.a4_ct_uro_id = opt.id)
      AND ag_p_name.policy_header_id(+)  = ph.policy_header_id;

create materialized view INS_DWH.MV_CR_BACKLOG_OF_PAYMENTS
build deferred
refresh force on demand
as
select "PRODUCT_NAME",
       "POL_SER",
       "POL_NUM",
       "CONTRACT_NUM",
       "POLICE_ID",
       "NOTICE_NUM",
       "FIO_ASSUR_OBJ",
       "START_DATE",
       "END_DATE",
       "AGENT_ID",
       "AGENT_LIADER",
       "AGENSY",
       "PERIOD",
       "PAYNMENT_NUMBER",
       "DUE_DATE",
       "SET_OF_DATE",
       "PROGRAMM_KODE",
       "PROGRAMM_NAME",
       "GRACE_DATE",
       "PREMIUM",
       "AMOUNT",
       "FUND",
       "FUND_PAY"
  from (select pr.description as product_name, -- �������
               pp.pol_ser as pol_ser, -- �����
               pp.pol_num as pol_num, -- �����
               pp.num as contract_num, -- ����� ��������
               pp.policy_id as police_id, -- id ��������
               pp.notice_num as notice_num, -- ����� ���������
               ins.ent.obj_name('CONTACT', assur.assured_contact_id) as fio_assur_obj, -- ��������������
               ph.start_date as start_date, -- ���� ������ �������� ��������
               pp.end_date as end_date, -- ���� ��������� �������� ��������
               ins.ent.obj_name('CONTACT', agch.agent_id) as agent_id, -- ��� ������
               ins.ent.obj_name('CONTACT', agchLead.agent_id) as agent_liader, -- ��� ������������ ������
               d.name as agensy, -- ��������
               tpt.description as period, -- �������������
               ap.payment_number as paynment_number, -- id ��������� �������
               sch.due_date, -- ���� �����������
               --sch.plan_date, -- ���� �� �������
               ap1.due_date      as set_of_date, -- ���� �������
               tLob.brief        as programm_kode, -- ��� ���������
               tPrLn.description as programm_name, -- �������� ��������� � ��������
               sch.grace_date    as grace_date, -- ���� ��������� ��������� �������
               sch.part_amount   as premium, -- ������ ������
               --dof.set_off_amount as amount, -- ����� �������
               --/*
               a.amount, -- ����� �������
               -- */
               f1.brief as fund, -- ������ ���������������
               f2.brief as fund_pay -- ������ ��������
        --,dof.doc_set_off_id
        --*/
          from ins.ven_p_pol_header ph
          join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
          join ins.ven_t_product pr on pr.product_id = ph.product_id
          join ins.ven_t_payment_terms tpt on tpt.id = pp.payment_term_id
        -- /*
        -- ������
          left join ins.ven_p_policy_agent ppag on ppag.policy_header_id =
                                                   ph.policy_header_id
          left join ins.ven_ag_contract_header agch on agch.ag_contract_header_id =
                                                       ppag.ag_contract_header_id
          left join ins.ven_department d on d.department_id = agch.agency_id
          left join ins.ven_ag_contract agc on agch.last_ver_id =
                                               agc.ag_contract_id
          left join ins.ven_ag_contract agLead on agLead.ag_contract_id =
                                                  agc.contract_leader_id
          left join ins.ven_ag_contract_header agchLead on agchLead.ag_contract_header_id =
                                                           agLead.contract_id
          left join ins.ven_policy_agent_status pAgSt on pAgSt.policy_agent_status_id =
                                                         ppag.status_id
        --*/
          join ins.ven_fund f1 on f1.fund_id = ph.fund_id
          join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
        --/*
        -- �������� ����� �������� (���������)
          left join ins.ven_as_asset ass on ass.p_policy_id = pp.policy_id
          left join ins.ven_as_assured assur on assur.as_assured_id =
                                                ass.as_asset_id
          left join ins.ven_p_cover pCov on pCov.as_asset_id =
                                            ass.as_asset_id
          left join ins.ven_t_prod_line_option tPrLnOp on tPrLnOp.id =
                                                          pCov.t_prod_line_option_id
          left join ins.ven_t_product_line tPrLn on tPrLn.id =
                                                    tPrLnOp.product_line_id
          left join ins.ven_t_product_line_type tPrLnT on tPrLnT.product_line_type_id =
                                                          tPrLn.product_line_type_id
        -- */
        --/*
        --�������� ��� ���������
          left join ins.ven_t_lob_line tLobLn on tLobLn.t_lob_line_id =
                                                 tPrLn.t_lob_line_id
          left join ins.ven_t_lob tLob on tLob.t_lob_id = tLobLn.t_lob_id
        --*/
        --/*
        -- �������
          left join ins.v_policy_payment_schedule sch on sch.policy_id =
                                                         pp.policy_id
          left join ins.ven_ac_payment ap on ap.payment_id = sch.document_id
          left join ins.ven_doc_set_off dof on dof.parent_doc_id =
                                               ap.payment_id
          left join ins.ven_ac_payment ap1 on ap1.payment_id =
                                              dof.child_doc_id
          left join(select sum(d.set_off_amount) over(partition by a.payment_id) amount, a.payment_id
          from ins.ven_ac_payment a
          left join ins.ven_doc_set_off d on d.parent_doc_id = a.payment_id
          left join ins.ven_ac_payment a1 on a1.payment_id = d.child_doc_id
                                     and a1.due_date <= a.due_date) a on a.payment_id = ap.payment_id
         where nvl(tPrLnT.brief, 'RECOMMENDED') = 'RECOMMENDED'
           and nvl(pAgSt.brief, 'CURRENT') = 'CURRENT'
              -- and tpt.description = '�������������'
              -- and pp.policy_id = 1879343
           and ins.doc.get_doc_status_brief(pp.policy_id) not in
               ('ANNULATED',
                'STOP',
                'CLOSE',
                'BREAK',
                'CANCEL',
                'READY_TO_CANCEL')) t
 where (nvl(t.amount, 0) < t.premium
    or t.set_of_date > t.due_date);


CREATE OR REPLACE VIEW v_RLA_units_agents
AS
SELECT agh.num "����� ������",
       ca.obj_name_orig "��� ������",
       agh.personal_units "������ �������  RLA �������",
       agh.structural_units "����������� ��. RLA �������",
       agh.common_units "����� ������� ��� RLA �������",
       (SELECT max(pl.t_tariff)
        FROM ins.t_career_plan pl
        WHERE agh.personal_units BETWEEN pl.t_le_from AND pl.t_le_to
              AND agh.common_units BETWEEN pl.t_ce_from AND pl.t_ce_to
       ) "�����",
       rf.name "��������� ������"
FROM ins.ven_ag_contract_header agh,
     ins.contact ca,
     ins.t_sales_channel ch,
     ins.document d,
     ins.doc_status_ref rf
WHERE agh.agent_id = ca.contact_id
      AND agh.t_sales_channel_id = ch.id
      AND ch.brief = 'RLA'
      AND agh.ag_contract_header_id = d.document_id
      AND d.doc_status_ref_id = rf.doc_status_ref_id
     -- AND ins.pkg_readonly.get_doc_status_name(agh.ag_contract_header_id)='�����������'
/*    AND rf.brief = 'CURRENT'*/
      ;
      grant select on  v_RLA_units_agents to ins_eul;                         
      grant select on  v_RLA_units_agents to ins_read;
/

create or replace view rep_grop_policy as
SELECT h.ids AS "���"
       ,p.version_num AS "� ������"
       ,r.name AS "������ ������"
       ,c.obj_name_orig AS "���"
       ,cp.date_of_birth AS "��"
       ,decode(cp.gender, 0, '�', '1', '�', cp.gender) AS "���"
       ,a.start_date AS "���� ������"
       ,a.end_date AS "���� ���������"
       ,plo.description AS "��������� ���������"
       ,pc.ins_amount AS "�-� �����"
       ,pc.fee AS "������ �����"

  FROM p_pol_header       h
      ,p_policy           p
      ,as_asset           a
      ,as_assured         au
      ,contact            c
      ,cn_person          cp
      ,p_cover            pc
      ,document           d
      ,doc_status_ref     r
      ,t_prod_line_option plo

 WHERE a.p_policy_id = p.policy_id
   AND p.pol_header_id = h.policy_header_id
   AND au.as_assured_id = a.as_asset_id
   AND c.contact_id = au.assured_contact_id
   AND cp.contact_id = c.contact_id
   AND pc.as_asset_id = a.as_asset_id
   AND d.document_id = p.policy_id
   AND d.doc_status_ref_id = r.doc_status_ref_id
   AND plo.id = pc.t_prod_line_option_id
      
   --AND h.ids = 1251113298

 ORDER BY p.version_num
         ,c.obj_name_orig
;

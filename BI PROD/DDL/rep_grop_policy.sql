create or replace view rep_grop_policy as
SELECT h.ids AS "ИДС"
       ,p.version_num AS "№ Версии"
       ,r.name AS "Стутус версии"
       ,c.obj_name_orig AS "ФИО"
       ,cp.date_of_birth AS "ДР"
       ,decode(cp.gender, 0, 'Ж', '1', 'М', cp.gender) AS "ПОЛ"
       ,a.start_date AS "Дата начала"
       ,a.end_date AS "Дата окончания"
       ,plo.description AS "Страховая программа"
       ,pc.ins_amount AS "С-я сумма"
       ,pc.fee AS "Брутто взнос"

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

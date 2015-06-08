CREATE OR REPLACE VIEW INS.V_AG_ROLL_HEADER AS 
SELECT vhead.ag_roll_header_id    AS ag_roll_header_id
			,vhead.reg_date             AS reg_date
			,vhead.num                  AS num
			,vhead.ent_id               AS ent_id
			,NULL                       AS period
			,vhead.date_begin           AS date_begin
			,vhead.date_end             AS date_end
			,vhead.ag_roll_type_id      AS ag_roll_type_id
			,vtype.name                 AS ag_roll_type_name
			,vtype.brief                AS ag_roll_type_brief
			,vhead.ag_category_agent_id AS ag_category_agent_id
			,vcat.category_name         AS ag_category_agent_name
			,vcat.brief                 AS ag_category_agent_brief
			,vhead.doc_templ_id         AS doc_templ_id
			,vhead.note                 AS note
			,dsr.name                   AS ag_roll_status_name
			,ds.user_name               AS status_user_name
			,ds.start_date              AS status_start_date
			,vtype.date_begin           begin_roll
			,vtype.date_end             end_roll
			,vhead.payment_date
			,vhead.trans_reg_date
			,vhead.ksp_roll_header_id
			,ksp_head.num               ksp_num
			,vhead.conclude_date
			,vhead.ops_sign_date
			,vhead.sofi_begin_date
			,vhead.sofi_end_date
			,vtype.type_av
	FROM ins.ven_ag_roll_header vhead
	LEFT JOIN ven_ag_roll_type vtype
		ON (vtype.ag_roll_type_id = vhead.ag_roll_type_id AND
			 vtype.ag_roll_type_id IN
			 (SELECT tp.ag_roll_type_id
					 FROM ins.ag_roll_type tp
					WHERE (safety.check_right_custom('VIEW_RLA') = 1 AND tp.brief LIKE 'RLA%')
						 OR (safety.check_right_custom('VIEW_RENLIFE') = 1 AND tp.brief NOT LIKE 'RLA%')))
	LEFT JOIN ven_ag_category_agent vcat
		ON vcat.ag_category_agent_id = vhead.ag_category_agent_id
	LEFT OUTER JOIN ven_ag_roll var
		ON var.ag_roll_id = pkg_ag_roll.get_last_ag_roll_id(vhead.ag_roll_header_id)
	LEFT JOIN ven_doc_status ds
		ON ds.doc_status_id = var.doc_status_id /*doc.get_last_doc_status_id(vhead.ag_roll_header_id)*/
	LEFT JOIN ven_doc_status_ref dsr
		ON dsr.doc_status_ref_id = ds.doc_status_ref_id
	LEFT OUTER JOIN ven_ag_roll_header ksp_head
		ON ksp_head.ag_roll_header_id = vhead.ksp_roll_header_id
 ORDER BY num               DESC
				 ,date_end          DESC
				 ,ag_roll_type_name;
					 
grant select on INS.V_AG_ROLL_HEADER to ins_read;

LOAD DATA
INTO TABLE AS_PERSON_MED_TMP
APPEND
FIELDS TERMINATED BY ';'
TRAILING NULLCOLS
(
  dms_health_group_brief                  CHAR,
  bso_num              				CHAR,
  name                                  	CHAR,
  first_name             			CHAR,
  middle_name					CHAR,
  birth_date  					CHAR "to_date(:birth_date,'dd.mm.yyyy')",
  dms_ins_var_num					CHAR,
  coeff						CHAR,
  dms_age_range_name				CHAR,
  address						CHAR,
  home_phone_number				CHAR,
  work_phone_number				CHAR,
  office						CHAR,
  department					CHAR,
  start_date					CHAR "to_date(:start_date,'dd.mm.yyyy')",
  end_date						CHAR "to_date(:end_date,'dd.mm.yyyy')",
  dms_ins_rel_type_name				CHAR "nvl(:dms_ins_rel_type_name, 'Сотрудники')",
  worker 						CHAR,
  note 						CHAR,
  t_id_type_name					CHAR "nvl((select description from ven_t_id_type where description = :t_id_type_name),(select description from ven_t_id_type where brief = 'PASS_RF'))",
  doc_ser						CHAR,
  doc_num						CHAR,  
  doc_issue_date					CHAR "to_date(:doc_issue_date,'dd.mm.yyyy')",
  doc_issue_who					CHAR,
  is_asset_add          			CHAR "0",
  is_asset_change          			CHAR "0",
  is_contact_add          			CHAR "0",
  is_contact_change          			CHAR "0",
  is_address_add          			CHAR "0",
  is_address_change          			CHAR "0",
  is_home_phone_add          			CHAR "0",
  is_home_phone_change          		CHAR "0",
  is_work_phone_add          			CHAR "0",
  is_work_phone_change          		CHAR "0",
  is_error          				CHAR "0",
  is_doc_add          				CHAR "0",
  is_doc_change          			CHAR "0",
  row_id						SEQUENCE,
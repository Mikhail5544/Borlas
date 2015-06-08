CREATE OR REPLACE FORCE VIEW V_REINSUR_JOURNAL
(re_main_contract_id, assignor_id, reinsurer_id, re_metod_reins_id, last_version_id, num, met_brief, assignor, reinsurer, metod_reins, sign_date, re_contract_version_id, start_date, end_date, status_name, is_in, is_retroceciya, doc_templ_brief)
AS
SELECT m.re_main_contract_id,
        m.assignor_id,
        m.reinsurer_id,
        m.re_metod_reins_id,
        m.last_version_id,
        m.num num,
        met.brief met_brief,
        Ent.obj_name('CONTACT', m.assignor_id) assignor,
        Ent.obj_name('CONTACT', m.reinsurer_id) reinsurer,
        met.NAME metod_reins,
        NVL(CV.sign_date,m.sign_date),
        CV.re_contract_version_id,
        m.start_date,
        NVL(CV.end_date,m.end_date),
        Doc.get_doc_status_name(NVL(CV.re_contract_version_id,m.RE_MAIN_CONTRACT_id)) status_name,
        m.is_in,
        m.is_retroceciya,
        dt.BRIEF doc_templ_brief       
  FROM ven_re_main_contract m
  ,ven_re_metod_reins met
  ,ven_re_contract_version CV
  ,ven_doc_templ dt
  WHERE m.re_metod_reins_id = met.re_metod_reins_id
  AND CV.RE_CONTRACT_VERSION_ID = m.LAST_VERSION_ID
  AND dt.DOC_TEMPL_ID = CV.DOC_TEMPL_ID
UNION
SELECT m.re_main_contract_id,
        m.assignor_id,
        m.reinsurer_id,
        m.re_metod_reins_id,
        m.last_version_id,
        m.num num,
        met.brief met_brief,
        Ent.obj_name('CONTACT', m.assignor_id) assignor,
        Ent.obj_name('CONTACT', m.reinsurer_id) reinsurer,
        met.NAME metod_reins,
        m.sign_date,
        m.re_main_contract_id re_contract_version_id,
        m.start_date,
        m.end_date,
        Doc.get_doc_status_name(m.RE_MAIN_CONTRACT_id) status_name,
        m.is_in,
        m.is_retroceciya,
        NULL       
  FROM ven_re_main_contract m
  ,ven_re_metod_reins met
  WHERE m.re_metod_reins_id = met.re_metod_reins_id;


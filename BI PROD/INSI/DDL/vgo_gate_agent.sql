CREATE OR REPLACE FORCE VIEW VGO_GATE_AGENT AS
WITH
sel_address AS
     (SELECT row_number() over(PARTITION BY cca.contact_id, cca.address_type, cca.is_default order by cca.is_default DESC) rn, cca.contact_id AS contact_id, ca.name, ca.id, cca.is_default,cca.address_type, tat.brief, TD.description as DISTRICT_TYPE_NAME, C.DESCRIPTION as COUNTRY_NAME
        FROM ins.cn_address ca, ins.cn_contact_address cca, ins.t_address_type tat, ins.T_DISTRICT_TYPE TD, ins.T_COUNTRY C
       WHERE tat.ID = cca.address_type AND ca.ID = cca.adress_id and TD.DISTRICT_TYPE_ID (+) = ca.district_type_id and C.ID = ca.COUNTRY_ID),
sel_doc AS (SELECT row_number() over(PARTITION BY cci.contact_id, CCI.ID_TYPE order by cci.table_id) rn, TIT.BRIEF,CCI.* from ins.CN_CONTACT_IDENT CCI, ins.T_ID_TYPE TIT where TIT.ID = CCI.ID_TYPE )
SELECT  ach.ag_contract_header_id as AG_CONTRACT_HEADER_ID,
        ach.ag_contract_header_id as CODE,
        AGENT.NAME,
        AGENT.FIRST_NAME,
        AGENT.MIDDLE_NAME,
        ACH.NUM,
        dep.NAME  as AGENCY_NAME,
        dep.DEPARTMENT_ID as AGENCY_ID,
        CP.GENDER,
        NVL(ac.leg_pos, decode(tct.is_individual,0,2,decode(tct.brief,'ѕЅќёЋ',1,0))) AS CONTACT_TYPE_ID,

        sd_inn.ID_VALUE as INN_VAL,
        sd_kpp.ID_VALUE as KPP_VAL,
        sd_pens.ID_VALUE as PENS_VAL,
        sd_pass.ID_VALUE as PASS_VAL,
        sd_pass.serial_nr as PASS_SERIAL,
        sd_pass.place_of_issue as PASS_place,
        sd_pass.issue_date as pass_issue_date,
        CP.DATE_OF_BIRTH,
        CP.COUNTRY_BIRTH,
        (select ins.pkg_contact.get_ident_number(CCBA.BANK_ID, 'KORR') from INS.CN_CONTACT_BANK_ACC CCBA where CCBA.CONTACT_ID = AGENT.CONTACT_ID and rownum <=1) as korr_val,
        null as LIC_ACCOUNT, -- в BI нет Ћицевых счетов
        (select A.ACCOUNT_NR from ins.CN_CONTACT_BANK_ACC A where A.CONTACT_ID =  ach.AGENT_ID and rownum <=1 ) as RASS_ACCOUNT,
        (select ins.pkg_contact.get_ident_number(CCBA.BANK_ID, 'BIK') from INS.CN_CONTACT_BANK_ACC CCBA where CCBA.CONTACT_ID = AGENT.CONTACT_ID and rownum <=1) as RASS_BIK,
        --
        (select ins.fn_obj_name(c.ent_id, c.contact_id, sysdate) from ins.CN_CONTACT_BANK_ACC A, INS.Contact c where A.CONTACT_ID =  ach.AGENT_ID and c.contact_id = a.bank_id and rownum <=1 ) as BANK_NAME,
        (select ins.fn_obj_name(c.ent_id, c.contact_id, sysdate) from ins.CN_CONTACT_BANK_ACC A, INS.Contact c where A.CONTACT_ID =  ach.AGENT_ID and c.contact_id = a.branch_id and rownum <=1 ) as BRANCH_NAME,
        --
        (select ins.pkg_contact.get_ident_number(CCBA.BANK_ID, 'INN') from INS.CN_CONTACT_BANK_ACC CCBA where CCBA.CONTACT_ID = AGENT.CONTACT_ID and rownum <=1) as BANK_INN,
        (select ins.pkg_contact.get_ident_number(CCBA.BANK_ID, 'KPP') from INS.CN_CONTACT_BANK_ACC CCBA where CCBA.CONTACT_ID = AGENT.CONTACT_ID and rownum <=1) as BANK_KPP,
        ac.CATEGORY_ID,
       -- add_dom.zip as zip_dom,
        (select NVL(insi.pkg_utils.Get_addr_2NDFL(add_dom.ID), add_dom.name) from sel_address add_dom where add_dom.brief = 'DOMADD' and add_dom.contact_id = AGENT.CONTACT_ID and  rownum <= 1) as ADDRESS_NAME_DOM, -- адрес по проживанию
        (select NVL(insi.pkg_utils.Get_addr_2NDFL(add_const.ID), add_const.name) from sel_address add_const where add_const.brief = 'CONST' and add_const.contact_id = AGENT.CONTACT_ID and rownum <= 1) as ADDRESS_NAME_CONST, -- адрес по регистрации
        AGENT.CONTACT_ID as CONTACT_ID,
        decode(ac.leg_pos,1,'ѕЅќёЋ',null) as PBOUL,
        ins.doc.get_doc_status_brief(ach.ag_contract_header_id) status_brief,
        ins.Doc.get_doc_status_name(ach.ag_contract_header_id) status_name


  FROM ins.VEN_ag_contract_header ach,
         ins.VEN_ag_contract ac,
      -- (select row_number() over(PARTITION BY a.contact_id, a.address_type, a.is_default order by a.is_default DESC, a.id) rn, a.* from sel_address A where a.brief = 'DOMADD') add_dom,
      -- (select row_number() over(PARTITION BY a.contact_id, a.address_type, a.is_default order by a.is_default DESC, a.id) rn, a.* from sel_address A where a.brief = 'CONST') add_const,
--       ins.DOCUMENT D,
--       ins.CONTACT AGENCY,
       ins.DEPARTMENT dep,
       ins.CONTACT AGENT,
       ins.T_CONTACT_TYPE tct,
       ins.CN_PERSON CP,
       sel_doc sd_inn,
       sel_doc sd_kpp,
       sel_doc sd_pens,
       sel_doc sd_pass
    -- ,sel_doc sd_korr
 WHERE
  -- add_dom.contact_id(+) = ach.Agent_ID
   --and  add_dom.rn(+) = 1
  -- AND add_const.contact_id(+) = ach.Agent_ID
  -- and add_const.rn(+) = 1
  -- and
   sd_inn.CONTACT_ID(+) = AGENT.CONTACT_ID
   and sd_inn.BRIEF(+) = 'INN'
   and sd_inn.rn(+) = 1
   and sd_kpp.CONTACT_ID(+) = AGENT.CONTACT_ID
   and sd_kpp.BRIEF(+) = 'KPP'
   and sd_kpp.rn(+) = 1
   and sd_pens.CONTACT_ID(+) = AGENT.CONTACT_ID
   and sd_pens.BRIEF(+) = 'PENS'
   and sd_pens.rn(+) = 1
   and sd_pass.CONTACT_ID(+) = AGENT.CONTACT_ID
   and sd_pass.BRIEF(+) = 'PASS_RF'
   and sd_pass.rn(+) = 1
  /* and sd_korr.CONTACT_ID(+) = AGENT.CONTACT_ID
   and sd_korr.BRIEF(+) = 'KORR'
   and sd_korr.rn(+) = 1*/
   and ac.CONTRACT_ID = ach.AG_contract_header_id
   and ac.ag_contract_id = ach.last_ver_id
   and ac.agency_id = dep.DEPARTMENT_ID(+)
   and CP.CONTACT_ID(+) = AGENT.CONTACT_ID
   and AGENT.CONTACT_ID  = ach.AGENT_ID
   and tct.ID = AGENT.CONTACT_TYPE_ID
   --!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ”Ѕ–ј“№
/*
  and AGENT.CONTACT_ID in
(
539100
)
*/
;


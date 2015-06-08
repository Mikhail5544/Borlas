CREATE OR REPLACE FORCE VIEW VGO_DWH_AGENT AS
SELECT
        to_char(nvl(ach.ag_contract_header_id,0))                                as AG_HEADER_ID,
        to_char(nvl(AGENT.NAME,''))                                              as Name,
        to_char(nvl(AGENT.FIRST_NAME,''))                                        as FIRST_NAME,
        to_char(nvl(AGENT.MIDDLE_NAME,''))                                       as MIDDLE_NAME,
        to_char(nvl(ACH.NUM,''))                                                 as AG_DOGOVOR_NUM,
        to_char(nvl(dep.DEPARTMENT_ID,''))                                       as AGENCY_ID,
        to_char(nvl(AGENT.CONTACT_ID,''))                                        as CONTACT_ID,
        to_char(nvl(ins.doc.get_doc_status_brief(ach.ag_contract_header_id),'')) as status_ID,
        to_char(nvl(decode(ac.leg_pos,1,'оанчк',null),''))                       as PBOUL

FROM
        ins.VEN_ag_contract_header ach,
        ins.VEN_ag_contract ac,
        ins.DEPARTMENT dep,
        ins.CONTACT AGENT
 WHERE
        ac.CONTRACT_ID = ach.AG_contract_header_id
        and ac.ag_contract_id = ach.last_ver_id
        and ac.agency_id = dep.DEPARTMENT_ID(+)
        and AGENT.CONTACT_ID  = ach.AGENT_ID;


create or replace force view vgo_gate_contact as
with t_doc_inn as (select CCI.* from ins.T_ID_TYPE TIT, ins.CN_CONTACT_IDENT CCI where TIT.BRIEF = 'INN' and CCI.ID_TYPE = TIT.ID),
     t_doc_KPP as (select CCI.* from ins.T_ID_TYPE TIT, ins.CN_CONTACT_IDENT CCI where TIT.BRIEF = 'KPP' and CCI.ID_TYPE = TIT.ID)
select
c.CONTACT_ID as CODE,
TCT.IS_INDIVIDUAL as IS_INDIVIDUAL,
t_inn.ID_VALUE as INN,
t_kpp.ID_VALUE as KPP,
c.RESIDENT_FLAG as IS_RESIDENT,
c.NAME || ' '|| c.FIRST_NAME  || ' ' || c.MIDDLE_NAME as FULL_NAME,
c.SHORT_NAME,
null as COUNTRY_OKSM
 from
ins.contact c,
ins.CN_CONTACT_IDENT CCI,
ins.CN_PERSON CP,
ins.T_CONTACT_TYPE TCT,
t_doc_inn t_inn,
t_doc_kpp t_kpp,
ins.T_ID_TYPE TIT
where CCI.TABLE_ID = GetDocIdByPriority (c.CONTACT_ID)
and CP.CONTACT_ID = c.CONTACT_ID
and TCT.ID = c.CONTACT_TYPE_ID
and TIT.id(+) = CCI.ID_TYPE
and t_inn.CONTACT_ID(+) = c.CONTACT_ID
and t_KPP.CONTACT_ID(+) = c.CONTACT_ID;


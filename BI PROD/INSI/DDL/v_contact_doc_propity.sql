create or replace force view v_contact_doc_propity as
with tit_def as ( select 
       min(TIT.ID) keep (DENSE_RANK FIRST order by TO_NUMBER(TIT.IMNS_CODE) asc) as ID 
       from ins.T_ID_TYPE TIT where TIT.is_default = 1 and TIT.IMNS_CODE is not null), 
	 tit_PASS_RF as ( select tit.id from ins.T_ID_TYPE TIT where TIT.IMNS_CODE is not null and tit.BRIEF  = 'PASS_RF'), 
	 tit_20017 as ( select tit.id from ins.T_ID_TYPE TIT where TIT.IMNS_CODE is not null and upper(tit.DESCRIPTION)  = upper('Паспорт моряка')), 
	 tit_VOEN_SOLD as ( select tit.id from ins.T_ID_TYPE TIT where TIT.IMNS_CODE is not null and tit.BRIEF  = 'VOEN_SOLD'), 
	 tit_VOEN_UDOS as ( select tit.id from ins.T_ID_TYPE TIT where TIT.IMNS_CODE is not null and tit.BRIEF  = 'VOEN_UDOS'), 
	 tit_BIRTH_CERT as ( select tit.id from ins.T_ID_TYPE TIT where TIT.IMNS_CODE is not null and tit.BRIEF  = 'BIRTH_CERT') 
select 
  COALESCE ( (select t.id from tit_def t where t.id = cci.ID_TYPE), 
             (select t.id from tit_PASS_RF t where t.id = cci.ID_TYPE), 
  		     (select t.id from tit_20017 t where t.id = cci.ID_TYPE), 
			 (select t.id from tit_VOEN_SOLD t where t.id = cci.ID_TYPE), 
			 (select t.id from tit_VOEN_UDOS t where t.id = cci.ID_TYPE), 
			 (select t.id from tit_BIRTH_CERT t where t.id = cci.ID_TYPE) 
			  ) as DOC_ID, 
  CCI.CONTACT_ID, 
  CCI.TABLE_ID 
from 
ins.CN_CONTACT_IDENT CCI, 
(select min(cc.TABLE_ID) keep (DENSE_RANK FIRST order by cc.CONTACT_ID asc) as TABLE_ID 
       from ins.CN_CONTACT_IDENT cc ) cci2 
where cci2.TABLE_ID = CCI.TABLE_ID;


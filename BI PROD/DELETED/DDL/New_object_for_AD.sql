drop index IX_P_POLICY_AGENT_DOC_04;

drop index IX_P_POLICY_AGENT_DOC_03;

drop index IX_P_POLICY_AGENT_DOC_02;

drop index IX_P_POLICY_AGENT_DOC_01;

drop table P_POLICY_AGENT_DOC cascade constraints;

/*==============================================================*/
/* Table: P_POLICY_AGENT_DOC                                    */
/*==============================================================*/

DECLARE
v_sql VARCHAR2(2000);
BEGIN

FOR r IN (
SELECT s.sid     sid,
       s.serial# serial
  FROM v$lock       l,
       v$session    s,
       user_objects uo
 WHERE s.sid = l.sid
   AND (uo.object_id(+) = l.ID1)
   AND l.TYPE <> 'MR'
   AND s.TYPE <> 'BACKGROUND'
   AND object_name in ('DOCUMENT','AG_CONTRACT_HEADER','P_POL_HEADER')
  -- AND username <> 'INS'
) LOOP
  EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||r.sid||','||r.serial||'''';
END LOOP;
END;
/
create table P_POLICY_AGENT_DOC  (
   P_POLICY_AGENT_DOC_ID INTEGER                         not null,
   AG_CONTRACT_HEADER_ID INTEGER                         not null,
   POLICY_HEADER_ID     INTEGER                         not null,
   DATE_BEGIN           DATE,
   DATE_END             DATE,
   SUBAGENT             VARCHAR(50),
   constraint PK_P_POLICY_AGENT_DOC primary key (P_POLICY_AGENT_DOC_ID),
   constraint FK_P_POLICY_AGENT_DOC_02 foreign key (AG_CONTRACT_HEADER_ID)
         references AG_CONTRACT_HEADER (AG_CONTRACT_HEADER_ID),
   constraint FK_P_POLICY_AGENT_REF_01 foreign key (POLICY_HEADER_ID)
         references P_POL_HEADER (POLICY_HEADER_ID)
);

comment on table P_POLICY_AGENT_DOC is
'Документ - агент по договору ';

comment on column P_POLICY_AGENT_DOC.P_POLICY_AGENT_DOC_ID is
'Ид записи документ - агент по договору';

comment on column P_POLICY_AGENT_DOC.AG_CONTRACT_HEADER_ID is
'Ид записи заголовка АД';

comment on column P_POLICY_AGENT_DOC.POLICY_HEADER_ID is
'Ид записи шапка договора страхования';

comment on column P_POLICY_AGENT_DOC.DATE_BEGIN is
'Дата начала действия';

comment on column P_POLICY_AGENT_DOC.DATE_END is
'Дата окончания действия';

comment on column P_POLICY_AGENT_DOC.SUBAGENT is
'Субагент';

DELETE FROM entity e WHERE e.SOURCE = 'P_POLICY_AGENT_DOC';

execute execute immediate 'DROP VIEW VEN_P_POLICY_AGENT_DOC';

BEGIN
ents.create_ent('P_POLICY_AGENT_DOC',
                'Документ - агент по договору ',
                'P_POLICY_AGENT_DOC',
                'DOCUMENT');
END;
/


DECLARE
v_sql VARCHAR2(2000);
BEGIN

FOR r IN (
SELECT s.sid     sid,
       s.serial# serial
  FROM v$lock       l,
       v$session    s,
       user_objects uo
 WHERE s.sid = l.sid
   AND (uo.object_id(+) = l.ID1)
   AND l.TYPE <> 'MR'
   AND s.TYPE <> 'BACKGROUND'
   AND object_name in ('DOCUMENT','AG_CONTRACT_HEADER','P_POL_HEADER')
  -- AND username <> 'INS'
) LOOP
  EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||r.sid||','||r.serial||'''';
END LOOP;

EXECUTE IMMEDIATE 'ALTER TABLE document DROP CONSTRAINT CHE_DOCUMENT';

SELECT 'ALTER TABLE document add CONSTRAINT CHE_DOCUMENT CHECK (ENT_ID in ('|| wmsys.wm_concat(e.ent_id)||'))'
  INTO v_sql
  FROM entity e 
 WHERE e.parent_id = (SELECT ent_id FROM entity e1 WHERE e1.SOURCE = 'DOCUMENT');

EXECUTE IMMEDIATE v_sql;
END;
/

INSERT INTO ven_doc_templ (brief,doc_ent_id,name) 
SELECT e.brief, e.ent_id, e.name FROM entity e WHERE e.SOURCE = 'P_POLICY_AGENT_DOC';

INSERT INTO ven_doc_status_ref (brief,NAME) VALUES ('ERROR','Ошибка');

ALTER TABLE P_POLICY_AGENT ADD (P_POLICY_AGENT_DOC_ID INTEGER);

comment on column P_POLICY_AGENT.P_POLICY_AGENT_DOC_ID
  is 'Ид записи документ - агент по договору';

alter table P_POLICY_AGENT
  add constraint FK_P_POLICY_AGENT_05 foreign key (P_POLICY_AGENT_DOC_ID)
  references P_POLICY_AGENT_DOC (P_POLICY_AGENT_DOC_ID);

-- Create/Recreate indexes 
drop index IX_P_POLICY_AGENT_05;
create index IX_P_POLICY_AGENT_05 on P_POLICY_AGENT (p_policy_agent_doc_id) tablespace "INDEX";

BEGIN
ents.gen_ent_all('P_POLICY_AGENT');
END;  
/

/*==============================================================*/
/* Index: IX_P_POLICY_AGENT_DOC_01                              */
/*==============================================================*/
create index IX_P_POLICY_AGENT_DOC_01 on P_POLICY_AGENT_DOC (
   POLICY_HEADER_ID ASC
)
tablespace "INDEX";

/*==============================================================*/
/* Index: IX_P_POLICY_AGENT_DOC_02                              */
/*==============================================================*/
create index IX_P_POLICY_AGENT_DOC_02 on P_POLICY_AGENT_DOC (
   AG_CONTRACT_HEADER_ID ASC
)
tablespace "INDEX";

/*==============================================================*/
/* Index: IX_P_POLICY_AGENT_DOC_03                              */
/*==============================================================*/
create index IX_P_POLICY_AGENT_DOC_03 on P_POLICY_AGENT_DOC (
   DATE_BEGIN ASC
)
tablespace "INDEX";

/*==============================================================*/
/* Index: IX_P_POLICY_AGENT_DOC_04                              */
/*==============================================================*/
create index IX_P_POLICY_AGENT_DOC_04 on P_POLICY_AGENT_DOC (
   DATE_END ASC
)
tablespace "INDEX";

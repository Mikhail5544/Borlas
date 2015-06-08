drop table AGN_TAC cascade constraints;

/*==============================================================*/
/* Table: AGN_TAC                                               */
/*==============================================================*/
create table AGN_TAC  (
   AGN_TAC_ID           INTEGER                         not null,
   TAC_NUM              VARCHAR(5),
   TAC_NAME             VARCHAR(255),
   TAC_ENT              VARCHAR(255),
   constraint PK_AGN_TAC primary key (AGN_TAC_ID)
);

comment on table AGN_TAC is
'���������� �������� ��������� �������';

comment on column AGN_TAC.AGN_TAC_ID is
'�� ������ ���';

comment on column AGN_TAC.TAC_NUM is
'����� ���';

comment on column AGN_TAC.TAC_NAME is
'�������� ���';

comment on column AGN_TAC.TAC_ENT is
'��� ���';

DELETE FROM entity e WHERE e.SOURCE = 'AGN_TAC';

execute execute immediate 'DROP VIEW VEN_AGN_TAC';

BEGIN
ents.create_ent('AGN_TAC',
                '���������� �������� ��������� �������',
                'AGN_TAC');
END;
/

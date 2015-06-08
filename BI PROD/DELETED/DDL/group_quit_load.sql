-- DROP TABLE group_quit_file
CREATE TABLE load_file(
  load_file_id NUMBER,
  file_code    VARCHAR2( 30 ),
  file_name    VARCHAR2( 1000 ),
  load_date    DATE             DEFAULT SYSDATE,
  user_name    VARCHAR2( 30 )   DEFAULT USER
  )
/
COMMENT ON TABLE load_file IS '����������� �����';
COMMENT ON COLUMN load_file.load_file_id IS 
  '������������� �����';
COMMENT ON COLUMN load_file.file_code IS 
  '��� (���) �����';  
COMMENT ON COLUMN load_file.file_name IS 
  '��� �����';
COMMENT ON COLUMN load_file.load_date IS 
  '���� �������� �����';
COMMENT ON COLUMN load_file.user_name IS 
  '������������, ����������� ����'
/
ALTER TABLE load_file ADD CONSTRAINT pk_load_file 
  PRIMARY KEY ( load_file_id )
/
CREATE INDEX idx_load_file_01 
  ON load_file( load_date )
/
CREATE SEQUENCE sq_load_file
/  
-- DROP TABLE group_quit_file_row
CREATE TABLE group_quit_file_row(
  group_quit_file_row_id  NUMBER,
  load_file_id            NUMBER,  
  pol_num                 VARCHAR2( 1024 ),
  ids                     NUMBER( 10, 0 ),
  issuer_name             VARCHAR2( 255 ), 
  start_date              DATE, 
  pay_term_name           VARCHAR2( 30 ),
  fund_brief              VARCHAR2( 30 ),
  rate_act_date           NUMBER,
  rate_return_date        NUMBER,
  region_name             VARCHAR2( 255 ), 
  product_conds_desc      VARCHAR2( 2000 ),
  decline_date            DATE,
  decline_reason_name     VARCHAR2( 2000 ),
  debt_fee_sum            NUMBER,
  debt_fee_fact           NUMBER,
  medo_cost               NUMBER,
  overpayment             NUMBER,
  status                  NUMBER( 1 ) DEFAULT 0,
  load_date               DATE,
  user_name               VARCHAR2( 30 ),
  info                    VARCHAR2( 4000 )
  )
/
COMMENT ON TABLE group_quit_file_row IS 
  '������ ����� - ������ ��������� � �����������';
COMMENT ON COLUMN group_quit_file_row.group_quit_file_row_id IS 
  '������������� ������ ����� - ������ ��������� � �����������';
COMMENT ON COLUMN group_quit_file_row.load_file_id IS 
  '������������� �����';  
COMMENT ON COLUMN group_quit_file_row.pol_num IS 
  '����� ��������';
COMMENT ON COLUMN group_quit_file_row.ids IS 
  '���';
COMMENT ON COLUMN group_quit_file_row.issuer_name IS 
  '������������';
COMMENT ON COLUMN group_quit_file_row.start_date IS 
  '���� ���������� ��';
COMMENT ON COLUMN group_quit_file_row.pay_term_name IS 
  '������������� ������ �������';
COMMENT ON COLUMN group_quit_file_row.fund_brief IS 
  '������ ��';
COMMENT ON COLUMN group_quit_file_row.rate_act_date IS 
  '���� �� ���� ����';
COMMENT ON COLUMN group_quit_file_row.rate_return_date IS 
  '���� �� ���� �������';
COMMENT ON COLUMN group_quit_file_row.region_name IS 
  '������������ �������';
COMMENT ON COLUMN group_quit_file_row.product_conds_desc IS 
  '�������� �������';
COMMENT ON COLUMN group_quit_file_row.decline_date IS 
  '���� �����������';
COMMENT ON COLUMN group_quit_file_row.decline_reason_name IS 
  '������� ����������� ��';
COMMENT ON COLUMN group_quit_file_row.debt_fee_sum IS 
  '��������� ������������';
COMMENT ON COLUMN group_quit_file_row.debt_fee_fact IS 
  '��������� �����������';
COMMENT ON COLUMN group_quit_file_row.medo_cost IS 
  '������� �� ����';
COMMENT ON COLUMN group_quit_file_row.overpayment  IS 
  '��������� �� ������';
COMMENT ON COLUMN group_quit_file_row.status IS 
  '������ ������ �����: 0 - �� ����������� � ��������, 1 - ���������, 2 - ��������� �������� (�������� ���������), 3 - �������� �� �������������, (-1) - ������';
COMMENT ON COLUMN group_quit_file_row.load_date IS 
  '���� ����������� (������� �����������) �������� �� ������ ������ ��������� � �����������';
COMMENT ON COLUMN group_quit_file_row.user_name IS 
  '������������, ������������ (������������ ����������) ������� �� ������ ������ ��������� � �����������';
COMMENT ON COLUMN group_quit_file_row.info IS 
  '���������� � ������ ������ ��������� � ����������� ��� ����� ������'
/
ALTER TABLE group_quit_file_row ADD CONSTRAINT pk_group_quit_file_row 
  PRIMARY KEY ( group_quit_file_row_id )
/
ALTER TABLE group_quit_file_row ADD CONSTRAINT fk_group_quit_file_row_01
  FOREIGN KEY ( load_file_id ) 
  REFERENCES load_file( load_file_id )
  ON DELETE CASCADE
/
CREATE INDEX fk_group_quit_file_row_01 
  ON group_quit_file_row( load_file_id )
/
CREATE SEQUENCE sq_group_quit_file_row
/
CREATE SEQUENCE sq_temp_load_blob
/ 


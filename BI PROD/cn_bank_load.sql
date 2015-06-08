-- DROP TABLE cn_bank_req_file_row
CREATE TABLE cn_bank_req_file_row(
  cn_bank_req_file_row_id NUMBER,
  load_file_id            NUMBER,
  city_name               VARCHAR2( 255 ),
  bank_name               VARCHAR2( 1000 ),
  bic                     VARCHAR2( 50 ),
  corracc                 VARCHAR2( 50 ),
  status                  NUMBER( 1 )    DEFAULT 0,
  load_date               DATE           DEFAULT SYSDATE,
  user_name               VARCHAR2( 30 ) DEFAULT USER,
  info                    VARCHAR2( 4000 )
  )
/
COMMENT ON TABLE cn_bank_req_file_row IS 
  '������ ����� ���������� ����������';
COMMENT ON COLUMN cn_bank_req_file_row.cn_bank_req_file_row_id IS 
  '������������� ������ ����� ���������� ����������';
COMMENT ON COLUMN cn_bank_req_file_row.load_file_id IS 
  '������������� �����';  
COMMENT ON COLUMN cn_bank_req_file_row.city_name IS 
  '�����';
COMMENT ON COLUMN cn_bank_req_file_row.bank_name IS '������������ �����';
COMMENT ON COLUMN cn_bank_req_file_row.bic IS '���';
COMMENT ON COLUMN cn_bank_req_file_row.corracc IS '����. ����';
COMMENT ON COLUMN cn_bank_req_file_row.status IS 
  '������ ������ �����: 0 - �� ����������� � ��������, 1 - ���������, 2 - ��������� �������� (�������� ���������), 3 - �������� �� �������������, (-1) - ������';
COMMENT ON COLUMN cn_bank_req_file_row.load_date IS 
  '���� �������� (������� ��������) ������ ���������� ���������� � �������� � �������������� ���������';
COMMENT ON COLUMN cn_bank_req_file_row.user_name IS 
  '������������, ����������� (������������ ���������) ������ ���������� ���������� � �������� � �������������� ���������';
COMMENT ON COLUMN cn_bank_req_file_row.info IS 
  '���������� � ������ ���������� ���������� ��� ����� ������'
/
ALTER TABLE cn_bank_req_file_row ADD CONSTRAINT pk_cn_bank_req_file_row 
  PRIMARY KEY ( cn_bank_req_file_row_id )
/
ALTER TABLE cn_bank_req_file_row ADD CONSTRAINT fk_cn_bank_req_file_row_01
  FOREIGN KEY ( load_file_id ) 
  REFERENCES load_file( load_file_id )
  ON DELETE CASCADE
/
CREATE INDEX fk_cn_bank_req_file_row_01 
  ON cn_bank_req_file_row( load_file_id )
/
CREATE SEQUENCE sq_cn_bank_req_file_row
/



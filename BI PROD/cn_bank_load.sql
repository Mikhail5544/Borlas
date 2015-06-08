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
  'Строка файла банковских реквизитов';
COMMENT ON COLUMN cn_bank_req_file_row.cn_bank_req_file_row_id IS 
  'Идентификатор строки файла банковских реквизитов';
COMMENT ON COLUMN cn_bank_req_file_row.load_file_id IS 
  'Идентификатор файла';  
COMMENT ON COLUMN cn_bank_req_file_row.city_name IS 
  'Город';
COMMENT ON COLUMN cn_bank_req_file_row.bank_name IS 'Наименование банка';
COMMENT ON COLUMN cn_bank_req_file_row.bic IS 'БИК';
COMMENT ON COLUMN cn_bank_req_file_row.corracc IS 'Корр. счет';
COMMENT ON COLUMN cn_bank_req_file_row.status IS 
  'Статус строки файла: 0 - не загружалась в контакты, 1 - загружена, 2 - загружена частично (контакты обновлены), 3 - загрузка не потребовалась, (-1) - ошибка';
COMMENT ON COLUMN cn_bank_req_file_row.load_date IS 
  'Дата загрузки (попытки загрузки) строки банковских реквизитов в контакты и идентификаторы контактов';
COMMENT ON COLUMN cn_bank_req_file_row.user_name IS 
  'Пользователь, загрузивший (попытавшийся загрузить) строку банковских реквизитов в контакты и идентификаторы контактов';
COMMENT ON COLUMN cn_bank_req_file_row.info IS 
  'Информация о строке банковских реквизитов или текст ошибки'
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



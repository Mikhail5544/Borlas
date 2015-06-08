-- DROP TABLE group_quit_file
CREATE TABLE load_file(
  load_file_id NUMBER,
  file_code    VARCHAR2( 30 ),
  file_name    VARCHAR2( 1000 ),
  load_date    DATE             DEFAULT SYSDATE,
  user_name    VARCHAR2( 30 )   DEFAULT USER
  )
/
COMMENT ON TABLE load_file IS 'Загружаемые файлы';
COMMENT ON COLUMN load_file.load_file_id IS 
  'Идентификатор файла';
COMMENT ON COLUMN load_file.file_code IS 
  'Код (тип) файла';  
COMMENT ON COLUMN load_file.file_name IS 
  'Имя файла';
COMMENT ON COLUMN load_file.load_date IS 
  'Дата загрузки файла';
COMMENT ON COLUMN load_file.user_name IS 
  'Пользователь, загрузивший файл'
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
  'Строка файла - списка договоров к прекращению';
COMMENT ON COLUMN group_quit_file_row.group_quit_file_row_id IS 
  'Идентификатор строки файла - списка договоров к прекращению';
COMMENT ON COLUMN group_quit_file_row.load_file_id IS 
  'Идентификатор файла';  
COMMENT ON COLUMN group_quit_file_row.pol_num IS 
  'Номер договора';
COMMENT ON COLUMN group_quit_file_row.ids IS 
  'ИДС';
COMMENT ON COLUMN group_quit_file_row.issuer_name IS 
  'Страхователь';
COMMENT ON COLUMN group_quit_file_row.start_date IS 
  'Дата заключения ДС';
COMMENT ON COLUMN group_quit_file_row.pay_term_name IS 
  'Периодичность уплаты взносов';
COMMENT ON COLUMN group_quit_file_row.fund_brief IS 
  'Валюта ДС';
COMMENT ON COLUMN group_quit_file_row.rate_act_date IS 
  'Курс на дату акта';
COMMENT ON COLUMN group_quit_file_row.rate_return_date IS 
  'Курс на дату выплаты';
COMMENT ON COLUMN group_quit_file_row.region_name IS 
  'Наименование региона';
COMMENT ON COLUMN group_quit_file_row.product_conds_desc IS 
  'Полисные условия';
COMMENT ON COLUMN group_quit_file_row.decline_date IS 
  'Дата расторжения';
COMMENT ON COLUMN group_quit_file_row.decline_reason_name IS 
  'Причина расторжения ДС';
COMMENT ON COLUMN group_quit_file_row.debt_fee_sum IS 
  'Недоплата удерживаемая';
COMMENT ON COLUMN group_quit_file_row.debt_fee_fact IS 
  'Недоплата фактическая';
COMMENT ON COLUMN group_quit_file_row.medo_cost IS 
  'Расходы на МедО';
COMMENT ON COLUMN group_quit_file_row.overpayment  IS 
  'Переплата по полису';
COMMENT ON COLUMN group_quit_file_row.status IS 
  'Статус строки файла: 0 - не загружалась в контакты, 1 - загружена, 2 - загружена частично (контакты обновлены), 3 - загрузка не потребовалась, (-1) - ошибка';
COMMENT ON COLUMN group_quit_file_row.load_date IS 
  'Дата прекращения (попытки прекращения) договора по строке списка договоров к прекращению';
COMMENT ON COLUMN group_quit_file_row.user_name IS 
  'Пользователь, прекративший (попытавшийся прекратить) договор по строке списка договоров к прекращению';
COMMENT ON COLUMN group_quit_file_row.info IS 
  'Информация о строке списка договоров к прекращению или текст ошибки'
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


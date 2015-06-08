-- DROP TABLE p_cover_decline
CREATE TABLE p_cover_decline(
  p_cover_decline_id NUMBER,
  p_pol_decline_id   NUMBER NOT NULL,
  as_asset_id        NUMBER NOT NULL,
  t_product_line_id  NUMBER NOT NULL,
  cover_period       NUMBER,
  redemption_sum     NUMBER,
  add_invest_income  NUMBER,
  return_bonus_part  NUMBER,
  bonus_off_prev     NUMBER,
  bonus_off_current  NUMBER
  )
/
ALTER TABLE p_cover_decline
  ADD CONSTRAINT fk_p_cover_decline_01 FOREIGN KEY ( p_pol_decline_id )
  REFERENCES p_pol_decline ( p_pol_decline_id ) ON DELETE CASCADE
/
ALTER TABLE p_cover_decline
  ADD CONSTRAINT fk_p_cover_decline_02 FOREIGN KEY ( as_asset_id )
  REFERENCES as_asset ( as_asset_id )
/
ALTER TABLE p_cover_decline
  ADD CONSTRAINT fk_p_cover_decline_03 FOREIGN KEY ( t_product_line_id )
  REFERENCES t_product_line ( id )
/
CREATE INDEX ix_p_cover_decline_01 ON p_cover_decline ( p_pol_decline_id ) 
  TABLESPACE "INDEX"
/
CREATE INDEX ix_p_cover_decline_02 ON p_cover_decline ( as_asset_id ) 
  TABLESPACE "INDEX"
/
CREATE INDEX ix_p_cover_decline_03 ON p_cover_decline ( t_product_line_id ) 
  TABLESPACE "INDEX"
/
COMMENT ON TABLE p_cover_decline IS 'Прекращение договора. Данные по программам';
COMMENT ON COLUMN p_cover_decline.p_cover_decline_id IS 'ИД объекта сущности "Прекращение договора. Данные по программам"';
COMMENT ON COLUMN p_cover_decline.p_pol_decline_id IS 'ИД объекта сущности "Данные по расторжению версии ДС"';
COMMENT ON COLUMN p_cover_decline.as_asset_id IS 'ИД объекта сущности "Объект страхования"';
COMMENT ON COLUMN p_cover_decline.t_product_line_id IS 'ИД объекта сущности "Линия страхового продукта"';
COMMENT ON COLUMN p_cover_decline.cover_period IS 'Срок страхования';
COMMENT ON COLUMN p_cover_decline.redemption_sum IS 'Выкупная сумма';
COMMENT ON COLUMN p_cover_decline.add_invest_income IS 'Доп. инвест доход';
COMMENT ON COLUMN p_cover_decline.return_bonus_part IS 'Возврат части премии';
COMMENT ON COLUMN p_cover_decline.bonus_off_prev IS 'Начисленная премия к списанию прошлых лет';
COMMENT ON COLUMN p_cover_decline.bonus_off_current IS 'Начисленная премия к списанию этого года';

BEGIN
  ENTS.Create_Ent( 'P_COVER_DECLINE', 'Прекращение договора. Данные по программам', 
    'P_COVER_DECLINE' );
END;
/

--BEGIN 
--  ENTS.Gen_Ent_All( 'P_COVER_DECLINE' ); 
--END;

-- SELECT * FROM ven_p_cover_decline

   

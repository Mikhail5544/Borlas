-- DELETE FROM p_cover_decline
--DROP TABLE p_pol_decline
CREATE TABLE p_pol_decline(
  p_pol_decline_id   NUMBER,
  p_policy_id        NUMBER NOT NULL,
  reg_code           NUMBER,
  t_product_conds_id NUMBER,
  medo_cost          NUMBER,
  other_pol_sum      NUMBER,
  other_pol_num      VARCHAR2( 1024 ),
  income_tax_sum     NUMBER,
  income_tax_date    DATE,
  act_date           DATE,
  issuer_return_sum  NUMBER,
  issuer_return_date DATE,
  admin_expenses     NUMBER,
  overpayment        NUMBER
  )
/
-- ALTER TABLE p_pol_decline ADD( admin_expenses NUMBER, overpayment NUMBER );
-- ALTER TABLE p_pol_decline DROP CONSTRAINT fk_p_pol_decline_01
ALTER TABLE p_pol_decline
  ADD CONSTRAINT fk_p_pol_decline_01 FOREIGN KEY ( p_policy_id )
  REFERENCES p_policy ( policy_id ) ON DELETE CASCADE
/
-- ALTER TABLE p_pol_decline DROP CONSTRAINT fk_p_pol_decline_02
ALTER TABLE p_pol_decline
  ADD CONSTRAINT fk_p_pol_decline_02 FOREIGN KEY ( t_product_conds_id )
  REFERENCES t_product_conds ( t_product_conds_id )
/
CREATE INDEX ix_p_pol_decline_01 ON p_pol_decline ( p_policy_id ) 
  TABLESPACE "INDEX"
/
CREATE INDEX ix_p_pol_decline_02 ON p_pol_decline ( t_product_conds_id ) 
  TABLESPACE "INDEX"
/
COMMENT ON TABLE p_pol_decline IS 'Данные по расторжению версии ДС';
COMMENT ON COLUMN p_pol_decline.p_pol_decline_id IS 'ИД объекта сущности Данные по расторжению версии ДС';
COMMENT ON COLUMN p_pol_decline.p_policy_id IS 'ИД объекта сущности Версия договора страхования';
COMMENT ON COLUMN p_pol_decline.reg_code IS 'Код региона';
COMMENT ON COLUMN p_pol_decline.t_product_conds_id IS 'ИД объекта сущности Полисные условия страхового продукта';
COMMENT ON COLUMN p_pol_decline.medo_cost IS 'Расходы на МедО';
COMMENT ON COLUMN p_pol_decline.other_pol_sum IS 'Сумма зачета на другой договор';
COMMENT ON COLUMN p_pol_decline.other_pol_num IS 'Договор № - другой договор, на который делается зачет';
COMMENT ON COLUMN p_pol_decline.income_tax_sum IS 'Сумма НДФЛ';
COMMENT ON COLUMN p_pol_decline.income_tax_date IS 'Дата начисления НДФЛ';
COMMENT ON COLUMN p_pol_decline.act_date IS 'Дата акта';
COMMENT ON COLUMN p_pol_decline.issuer_return_sum IS 'Сумма к возврату Страхователю';
COMMENT ON COLUMN p_pol_decline.issuer_return_date IS 'Дата выплаты страхователю';
COMMENT ON COLUMN p_pol_decline.admin_expenses IS 'Административные издержки';
COMMENT ON COLUMN p_pol_decline.overpayment IS 'Переплата';
  
BEGIN
  ENTS.Create_Ent( 'P_POL_DECLINE', 'Данные по расторжению версии ДС', 
    'P_POL_DECLINE' );
END;
/
-- BEGIN ENTS.Gen_Ent_All( 'P_POL_DECLINE' ); END;
-- SELECT * FROM ven_p_pol_decline

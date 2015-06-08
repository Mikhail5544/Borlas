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
COMMENT ON TABLE p_pol_decline IS '������ �� ����������� ������ ��';
COMMENT ON COLUMN p_pol_decline.p_pol_decline_id IS '�� ������� �������� ������ �� ����������� ������ ��';
COMMENT ON COLUMN p_pol_decline.p_policy_id IS '�� ������� �������� ������ �������� �����������';
COMMENT ON COLUMN p_pol_decline.reg_code IS '��� �������';
COMMENT ON COLUMN p_pol_decline.t_product_conds_id IS '�� ������� �������� �������� ������� ���������� ��������';
COMMENT ON COLUMN p_pol_decline.medo_cost IS '������� �� ����';
COMMENT ON COLUMN p_pol_decline.other_pol_sum IS '����� ������ �� ������ �������';
COMMENT ON COLUMN p_pol_decline.other_pol_num IS '������� � - ������ �������, �� ������� �������� �����';
COMMENT ON COLUMN p_pol_decline.income_tax_sum IS '����� ����';
COMMENT ON COLUMN p_pol_decline.income_tax_date IS '���� ���������� ����';
COMMENT ON COLUMN p_pol_decline.act_date IS '���� ����';
COMMENT ON COLUMN p_pol_decline.issuer_return_sum IS '����� � �������� ������������';
COMMENT ON COLUMN p_pol_decline.issuer_return_date IS '���� ������� ������������';
COMMENT ON COLUMN p_pol_decline.admin_expenses IS '���������������� ��������';
COMMENT ON COLUMN p_pol_decline.overpayment IS '���������';
  
BEGIN
  ENTS.Create_Ent( 'P_POL_DECLINE', '������ �� ����������� ������ ��', 
    'P_POL_DECLINE' );
END;
/
-- BEGIN ENTS.Gen_Ent_All( 'P_POL_DECLINE' ); END;
-- SELECT * FROM ven_p_pol_decline

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
COMMENT ON TABLE p_cover_decline IS '����������� ��������. ������ �� ����������';
COMMENT ON COLUMN p_cover_decline.p_cover_decline_id IS '�� ������� �������� "����������� ��������. ������ �� ����������"';
COMMENT ON COLUMN p_cover_decline.p_pol_decline_id IS '�� ������� �������� "������ �� ����������� ������ ��"';
COMMENT ON COLUMN p_cover_decline.as_asset_id IS '�� ������� �������� "������ �����������"';
COMMENT ON COLUMN p_cover_decline.t_product_line_id IS '�� ������� �������� "����� ���������� ��������"';
COMMENT ON COLUMN p_cover_decline.cover_period IS '���� �����������';
COMMENT ON COLUMN p_cover_decline.redemption_sum IS '�������� �����';
COMMENT ON COLUMN p_cover_decline.add_invest_income IS '���. ������ �����';
COMMENT ON COLUMN p_cover_decline.return_bonus_part IS '������� ����� ������';
COMMENT ON COLUMN p_cover_decline.bonus_off_prev IS '����������� ������ � �������� ������� ���';
COMMENT ON COLUMN p_cover_decline.bonus_off_current IS '����������� ������ � �������� ����� ����';

BEGIN
  ENTS.Create_Ent( 'P_COVER_DECLINE', '����������� ��������. ������ �� ����������', 
    'P_COVER_DECLINE' );
END;
/

--BEGIN 
--  ENTS.Gen_Ent_All( 'P_COVER_DECLINE' ); 
--END;

-- SELECT * FROM ven_p_cover_decline

   

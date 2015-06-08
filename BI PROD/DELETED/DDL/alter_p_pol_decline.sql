ALTER TABLE p_pol_decline ADD ( total_fee_payment_sum NUMBER )
/
COMMENT ON COLUMN p_pol_decline.total_fee_payment_sum IS 
  'Общая сумма уплаченных взносов'
/
BEGIN
  ENTS.Gen_Ent_All( 'P_POL_DECLINE' );
END;
/

  

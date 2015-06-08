create materialized view IV_LETTERS_PAYMENT
refresh force on demand
as
(SELECT * FROM v_letters_payment_iv);


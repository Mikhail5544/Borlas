drop materialized view V_LETTERS_PAYMENT;
create materialized view V_LETTERS_PAYMENT
refresh force on demand
as
(SELECT * FROM v_letters_payment_v);

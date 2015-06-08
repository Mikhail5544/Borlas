CREATE MATERIALIZED VIEW INS_DWH.MV_PAYMENTS
REFRESH FORCE ON DEMAND
AS
SELECT PP.POL_HEADER_ID PH,
       t.risk_type_id   PLO,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3)
                  OR (PP.PAYMENT_TERM_ID IN (433, 163) AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)<=12)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 1))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P1,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 1 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 2))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P2,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 2 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P3,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 4))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P4,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 4 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 5))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P5,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 5 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P6,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 7))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P7,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
               OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44 )
               OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 7 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 8))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P8,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 8 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P9,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 10))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P10,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 10 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 11))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P11,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 11 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P12,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 13))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P13,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 13 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 14))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P14,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 14 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P15,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 16))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P16,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 16 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 17))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P17,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 17 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P18,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 19))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P19,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 19 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 20))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P20,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 20 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P21,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 22))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P22,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 22 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 23))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P23,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 23 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P24,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 25))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P25,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 25 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 26))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P26,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 26 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P27,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 28))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P28,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 28 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 29))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P29,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 29 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P30,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 31))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P31,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 31 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 32))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P32,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 32 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P33,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 34))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P34,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 34 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 35))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P35,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 35 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P36,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 37))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P37,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 37 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 38))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P38,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 38 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P39,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 40))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P40,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 40 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 41))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P41,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 41 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 42))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P42,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 42 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 43))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P43,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 43 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P44,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44))
                  and T.rur_amount > 0
             THEN T.rur_amount ELSE 0 END) P_END,
--------отрицательные значения:
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3)
                  OR (PP.PAYMENT_TERM_ID IN (433, 163) AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)<=12)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 1))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN1,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 1 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 2))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN2,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 2 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN3,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 4))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN4,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 4 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 5))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN5,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 5 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN6,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 7))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN7,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
               OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44 )
               OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 7 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 8))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN8,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 8 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN9,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 10))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN10,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 10 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 11))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN11,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 11 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN12,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 13))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN13,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 13 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 14))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN14,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 14 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN15,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 16))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN16,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 16 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 17))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN17,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 17 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN18,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 19))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN19,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 19 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 20))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN20,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 20 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN21,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 22))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN22,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 22 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 23))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN23,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 23 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN24,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 25))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN25,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 25 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 26))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN26,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 26 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN27,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 28))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN28,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 28 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 29))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN29,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 29 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN30,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 31))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN31,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 31 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 32))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN32,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 32 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN33,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 34))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN34,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 34 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 35))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN35,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 35 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN36,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 37))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN37,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 37 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 38))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN38,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 38 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN39,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 40))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN40,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 40 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 41))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN41,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 41 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 42))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN42,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 42 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 43))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN43,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 43 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN44,
       SUM(CASE WHEN ((PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44))
                  and T.rur_amount < 0
             THEN T.rur_amount ELSE 0 END) PN_END,
-------в валюте:
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3)
                  OR (PP.PAYMENT_TERM_ID IN (433, 163) AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)<=12)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 1)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F1,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 1 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 2)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F2,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 2 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 3)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F3,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
                  OR (PP.PAYMENT_TERM_ID = 433 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE)>36)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 3 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 4)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F4,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 4 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 5)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F5,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 5 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 6)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F6,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21)
                  OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 6 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 7)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F7,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
               OR (PP.PAYMENT_TERM_ID = 162 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44 )
               OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 7 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 8)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F8,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 8 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 9)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F9,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 9 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 10)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F10,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 10 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 11)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F11,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 11 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 12)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F12,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 12 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 13)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F13,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 13 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 14)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F14,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 165 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44)
                  OR (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 14 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 15)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F15,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 15 AND  MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 16)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F16,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 16 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 17)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F17,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 17 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 18)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F18,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 18 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 19)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F19,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 19 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 20)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F20,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 20 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 21)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F21,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 21 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 22)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F22,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 22 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 23)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F23,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 23 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 24)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F24,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 24 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 25)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F25,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 25 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 26)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F26,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 26 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 27)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F27,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 27 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 28)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F28,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 28 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 29)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F29,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 29 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 30)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F30,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 30 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 31)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F31,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 31 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 32)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F32,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 32 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 33)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F33,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 33 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 34)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F34,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 34 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 35)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F35,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 35 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 36)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F36,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 36 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 37)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F37,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 37 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 38)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F38,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 38 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 39)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F39,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 39 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 40)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F40,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 40 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 41)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F41,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 41 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 42)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F42,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 42 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 43)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F43,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 43 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) <= 44)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F44,
       SUM(CASE WHEN (PP.PAYMENT_TERM_ID = 166 AND MONTHS_BETWEEN(D.REG_DATE, PH.START_DATE) > 44)
             THEN case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                       then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
             ELSE 0 END) F_END,
       sum(case when tt.brief = 'СтраховаяПремияАвансОпл' and dt.brief = 'PAYORDER_SETOFF'
            then t.rur_amount else 0 end) damage

  FROM INS_DWH.FC_TRANS T,
       ins.P_POLICY     PP,
       ins.p_pol_header ph,
       ins.DOC_SET_OFF  DSO,
       ins.DOCUMENT     D,
       ins.doc_templ    dt,
       ins.trans_templ  tt
 WHERE tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND PP.POL_HEADER_ID  = t.pol_header_id
   and pp.policy_id      = ph.policy_id
   AND nvl(pp.is_group_flag,0) = 0
   AND T.DOCUMENT_ID    = DSO.DOC_SET_OFF_ID
   AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND ((tt.brief in ('СтраховаяПремияОплачена',
                      'ЗачВзнСтрАг',
                      'ПремияОплаченаПоср',
                      'СтраховаяПремияАвансОпл')
        and dt.brief in ('ПП','ПП_ОБ','ПП_ПС')
        )
        or (tt.brief in ('СтраховаяПремияАвансОпл','УдержКВ') --Убыток и выплата КВ
            and dt.brief in ('PAYORDER_SETOFF','ЗачетУ_КВ')
           )
       )
   and t.trans_date between '01.01.2010' and '31.12.2010'
GROUP BY PP.POL_HEADER_ID,
          t.risk_type_id;


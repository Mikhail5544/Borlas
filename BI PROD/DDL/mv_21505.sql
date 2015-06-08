CREATE OR REPLACE FORCE VIEW MV_21505 AS
SELECT DISTINCT --ap.payment_id
                 fnfc.code "ID Navision",
                ap.due_date "Дата ПД",
                dc.num "Номер ПД",
                NVL(to_number(fnfc.pp_rev_amount), 0) "Сумма платежа (Navision)",
                NVL(ap.amount, 0) "Сумма платежа (Borlas)",
                NVL((1 - fnfc.pp_rev_amount / ap.amount) * 100, 0) "Комиссия",
                NVL(ap.amount - fnfc.pp_rev_amount, 0) "Сумма комиссии, руб.",
                NVL(fnfc.payer_bank_name, ' ') "Банк плательщика Navision",
                NVL(fnfc.receiver_bank_name, ' ') "Банк получателя Navision"
                --,(SELECT cn.obj_name_orig FROM contact cn WHERE cn.contact_id = ap.contact_id)  "Плательщик/получатель Borlas"
                ,
                NVL(dc.Note, ' ') "Назначение платежа"
  FROM ac_payment              ap,
       insi.from_nav_for_check fnfc,
       document                dc
 WHERE ap.payment_templ_id in (select payment_templ_id from ac_payment_templ pt where pt.brief in ('ПП','ПП_ПС'))
   AND ap.payment_id = dc.document_id
   AND to_number(ap.doc_txt) = fnfc.code (+)
--AND ROWNUM < 2000
--AND ap.due_date BETWEEN '01.05.2009' AND '16.06.2009'
--AND     fnfc.pp_rev_amount IS NOT NULL
--AND     fnfc.code = 25606
--AND     ap.doc_txt IS NOT NULL
;


CREATE OR REPLACE VIEW MV_21505_FOJ AS
--Чирков /Комментарий/ по заявке 244129: Ошибка при формировании Отчета 1С-Borlas
/*select nvl(nc.code, a.code) as code,
       nvl(a."Дата ПД", nc.pp_bnr_date) AS "Дата ПД",
       a."Номер ПД",
       NVL(to_number(nc.pp_rev_amount), 0) "Сумма платежа (Navision)",
       NVL(a.amount, 0)                    "Сумма платежа (Borlas)",
       NVL((1 - nc.pp_rev_amount / a.amount) * 100, 0) "Комиссия",
       NVL(a.amount - nc.pp_rev_amount, 0) "Сумма комиссии, руб.",
       NVL(nc.payer_bank_name, ' ')        "Банк плательщика Navision",
       NVL(nc.receiver_bank_name, ' ')     "Банк получателя Navision",
       nvl(a.Note, nc.pp_note) "Назначение платежа",
       a.brief
      ,substr(nvl(a.md5, nc.md5),1,32) as md5
from (SELECT \*+ NO_MERGE *\
             ap.due_date "Дата ПД",
             dc.num "Номер ПД",
             ap.amount,
             dc.Note,
             case dc.doc_templ_id
               when 86 then 'ПП'
               when 16176 then 'ПП_ОБ'
               when 16174 then 'ПП_ПС'
             end as brief,
             ap.code,
             ap.md5
        FROM ac_payment ap,
             document   dc
       WHERE dc.doc_templ_id in (86, 16176, 16174) --ПП, ПП_ПС, ПП_ОБ
         and ap.payment_id = dc.document_id
      )a
full outer join insi.from_nav_for_check nc
on (a.code = nc.code)
union*/
select nvl(nc.code, a.code) as code,
       nvl(a."Дата ПД", nc.pp_bnr_date) AS "Дата ПД",
       a."Номер ПД",
       NVL(to_number(nc.pp_rev_amount), 0) "Сумма платежа (Navision)",
       NVL(a.amount, 0)                    "Сумма платежа (Borlas)",
       NVL((1 - nc.pp_rev_amount / a.amount) * 100, 0) "Комиссия",
       NVL(a.amount - nc.pp_rev_amount, 0) "Сумма комиссии, руб.",
       NVL(nc.payer_bank_name, ' ')        "Банк плательщика Navision",
       NVL(nc.receiver_bank_name, ' ')     "Банк получателя Navision",
       nvl(a.Note, nc.pp_note) "Назначение платежа",
       a.brief
      ,substr(nvl(a.md5, nc.md5),1,32) as md5
from (SELECT /*+ NO_MERGE */
             ap.due_date "Дата ПД",
             dc.num "Номер ПД",
             ap.amount,
             dc.Note,
             case dc.doc_templ_id
               when 86 then 'ПП'
               when 16176 then 'ПП_ОБ'
               when 16174 then 'ПП_ПС'
             end as brief,
             ap.code,
             ap.md5
        FROM ac_payment ap,
             document   dc
       WHERE dc.doc_templ_id in (86, 16176, 16174) --ПП, ПП_ПС, ПП_ОБ
         and ap.payment_id = dc.document_id
      )a
full outer join insi.from_nav_for_check nc
on (nc.md5 = a.md5);

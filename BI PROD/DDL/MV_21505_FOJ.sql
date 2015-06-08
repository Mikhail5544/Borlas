CREATE OR REPLACE VIEW MV_21505_FOJ AS
--������ /�����������/ �� ������ 244129: ������ ��� ������������ ������ 1�-Borlas
/*select nvl(nc.code, a.code) as code,
       nvl(a."���� ��", nc.pp_bnr_date) AS "���� ��",
       a."����� ��",
       NVL(to_number(nc.pp_rev_amount), 0) "����� ������� (Navision)",
       NVL(a.amount, 0)                    "����� ������� (Borlas)",
       NVL((1 - nc.pp_rev_amount / a.amount) * 100, 0) "��������",
       NVL(a.amount - nc.pp_rev_amount, 0) "����� ��������, ���.",
       NVL(nc.payer_bank_name, ' ')        "���� ����������� Navision",
       NVL(nc.receiver_bank_name, ' ')     "���� ���������� Navision",
       nvl(a.Note, nc.pp_note) "���������� �������",
       a.brief
      ,substr(nvl(a.md5, nc.md5),1,32) as md5
from (SELECT \*+ NO_MERGE *\
             ap.due_date "���� ��",
             dc.num "����� ��",
             ap.amount,
             dc.Note,
             case dc.doc_templ_id
               when 86 then '��'
               when 16176 then '��_��'
               when 16174 then '��_��'
             end as brief,
             ap.code,
             ap.md5
        FROM ac_payment ap,
             document   dc
       WHERE dc.doc_templ_id in (86, 16176, 16174) --��, ��_��, ��_��
         and ap.payment_id = dc.document_id
      )a
full outer join insi.from_nav_for_check nc
on (a.code = nc.code)
union*/
select nvl(nc.code, a.code) as code,
       nvl(a."���� ��", nc.pp_bnr_date) AS "���� ��",
       a."����� ��",
       NVL(to_number(nc.pp_rev_amount), 0) "����� ������� (Navision)",
       NVL(a.amount, 0)                    "����� ������� (Borlas)",
       NVL((1 - nc.pp_rev_amount / a.amount) * 100, 0) "��������",
       NVL(a.amount - nc.pp_rev_amount, 0) "����� ��������, ���.",
       NVL(nc.payer_bank_name, ' ')        "���� ����������� Navision",
       NVL(nc.receiver_bank_name, ' ')     "���� ���������� Navision",
       nvl(a.Note, nc.pp_note) "���������� �������",
       a.brief
      ,substr(nvl(a.md5, nc.md5),1,32) as md5
from (SELECT /*+ NO_MERGE */
             ap.due_date "���� ��",
             dc.num "����� ��",
             ap.amount,
             dc.Note,
             case dc.doc_templ_id
               when 86 then '��'
               when 16176 then '��_��'
               when 16174 then '��_��'
             end as brief,
             ap.code,
             ap.md5
        FROM ac_payment ap,
             document   dc
       WHERE dc.doc_templ_id in (86, 16176, 16174) --��, ��_��, ��_��
         and ap.payment_id = dc.document_id
      )a
full outer join insi.from_nav_for_check nc
on (nc.md5 = a.md5);

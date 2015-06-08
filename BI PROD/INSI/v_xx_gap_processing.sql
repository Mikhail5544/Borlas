CREATE OR REPLACE FORCE VIEW V_XX_GAP_PROCESSING AS
SELECT
        xg.code                                         "ID �������"
        ,xxgpl.status_date                              "���� ������� �������"
        ,xg.pp_date                                     "���� ���������� ���������"
        ,xg.pp_num                                      "����� ���������� ���������"
        ,TO_CHAR(xg.pp_rev_amount,'fm999999999999.00')  "����� �������"
        ,cn.obj_name_orig                               "����������"
        ,xxgsr.NAME                                     "��������� ��������"
        ,xg.pp_note                                     "���������� �������"
        ,(select t.description from ins.xx_lov_list t where t.val = vap.set_off_state) "�����������"
FROM
        ins.ven_ac_payment                  vap
        ,insi.xx_gap_process_log            xxgpl
        ,insi.xx_gap_status_ref             xxgsr
        ,insi.xx_gap_good                   xg
        ,ins.contact                        cn
WHERE   vap.payment_templ_id         =   2
AND     vap.payment_id               =   xg.row_status
--AND     TRUNC(vap.due_date, 'dd')    BETWEEN TO_DATE(&p_start_date) AND TO_DATE(&p_end_date)
--AND     TRUNC(xxgpl.status_date, 'dd')    BETWEEN TO_DATE(&p_start_date) AND TO_DATE(&p_end_date)
AND     xg.code                     =   xxgpl.code
AND     xxgpl.status_id             =   xxgsr.status_id
AND     vap.contact_id              =   cn.contact_id
AND     xxgsr.status_type           =   1
--AND     xg.code = 631
--AND     trunc(xxgpl.status_date, 'dd') = '01.06.2009'

UNION
SELECT  NULL                                            "ID �������"
        ,NULL                                           "���� ������� �������"
        ,trunc(vap.due_date, 'dd')                      "���� ���������� ���������"
        ,vap.num                                        "����� ���������� ���������"
        ,TO_CHAR(vap.amount,'fm999999999999.00')        "����� �������"
        ,cn.obj_name_orig                               "����������"
        ,'������� � ������� �������'                    "��������� ��������"
        ,vap.note                                       "���������� �������"
        ,(select t.description from ins.xx_lov_list t where t.val = vap.set_off_state) "�����������"
FROM    ins.ven_ac_payment                      vap
        ,ins.contact                            cn
WHERE   vap.contact_id              =   cn.contact_id
--AND     TRUNC(vap.due_date, 'dd')    BETWEEN TO_DATE(&p_start_date) AND TO_DATE(&p_end_date)
AND     vap.doc_txt                 IS NULL
AND     vap.payment_templ_id         =   2
--and vap.payment_id = 6517103
ORDER BY 1
;


CREATE OR REPLACE FORCE VIEW V_XX_GAP_COPYING AS
SELECT
        xxbg.code                       "ID платежа"
        ,xxgpl.status_date              "Дата импорта платежа"
        ,xxbg.pp_date                   "Дата платежного документа"
        ,xxbg.pp_num                    "Номер платежного документа"
        ,TO_CHAR(xxbg.pp_rev_amount,'fm999999999999.00')    "Сумма платежа"
        ,cn.obj_name_orig               "Контрагент"
        ,xxgsr.NAME                     "Результат импорта"
        ,xxbg.pp_note                   "Назначение платежа"
FROM
        insi.xx_gap_process_log             xxgpl
        ,(  SELECT DISTINCT
                            xxgg.code
                            ,xxgg.pp_date
                            ,xxgg.pp_num
                            ,xxgg.pp_rev_amount
                            ,xxgg.payer_name
                            ,xxgg.pp_note
                            ,xxgg.row_status
            FROM insi.xx_gap_good xxgg
            UNION
            SELECT          xxgb.code
                            ,xxgb.pp_date
                            ,xxgb.pp_num
                            ,xxgb.pp_rev_amount
                            ,xxgb.payer_name
                            ,xxgb.pp_note
                            ,xxgb.row_status
            FROM insi.xx_gap_bad  xxgb)     xxbg
        ,insi.xx_gap_status_ref             xxgsr
        ,ins.ac_payment                         ap
        ,inS.contact                            cn
WHERE   xxgpl.code                      =   xxbg.code
--AND     TRUNC(xxgpl.status_date, 'dd')  BETWEEN TO_DATE(&p_start_date) AND TO_DATE(&p_end_date)
AND     xxgpl.status_id                 =   xxgsr.status_id
AND     xxbg.row_status                 =   ap.payment_id
AND     ap.contact_id                   =   cn.contact_id
AND     xxgsr.status_type               =   0
ORDER BY 1
;


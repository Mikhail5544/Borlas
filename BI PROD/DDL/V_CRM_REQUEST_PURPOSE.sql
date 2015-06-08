CREATE OR REPLACE VIEW V_CRM_REQUEST_PURPOSE AS
SELECT DISTINCT t.CONTACT_ID
               ,t.IDS
               ,t.OBJECT_TYPE
               ,t.DOC_NUMBER
               ,t.CONTACT_FIO
               ,t.CONTACT_TYPE
               ,t.POLICY_ID
               ,t.CONTACT_DATE_OF_BIRTH
               ,t.POLICY_FUND
               ,t.POLICY_STATUS
               ,t.POLICY_FEE
               ,t.POLICY_COLLECT_TYPE
               ,t.POLICY_PAYMENT_TERM
               ,(SELECT pol_header_id
                 FROM p_policy
                 WHERE policy_id = t.POLICY_ID) pol_header_id
               ,CASE t.OBJECT_TYPE WHEN 'ДИС'     THEN 1
                                   WHEN 'ДКС'     THEN 2
                                   WHEN 'АД'      THEN 3
                                   WHEN 'УСВЭ'    THEN 4
                                   WHEN 'ЭР'      THEN 5
                ELSE 6
                END obj_type
               ,CASE t.CONTACT_TYPE WHEN 'Страхователь'        THEN 1
                                    WHEN 'Застрахованный'      THEN 2
                                    WHEN 'Выгодоприобретатель' THEN 3
                                    WHEN 'Агент'               THEN 4
                                    WHEN 'Заявитель'           THEN 5
                                    WHEN 'Контакт'             THEN 6
                                    WHEN 'Плательщик'          THEN 7
                ELSE 8
                END cont_type
FROM TMP_CRM_REQUEST_PURPOSE t
ORDER BY obj_type, t.IDS, cont_type;
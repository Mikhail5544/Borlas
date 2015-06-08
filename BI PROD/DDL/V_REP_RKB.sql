CREATE OR REPLACE VIEW V_REP_RKB AS
select 
PAYMENT_REGISTER_ITEM_ID                                   payment_register_item_id,
NOTE                                                       "Примечание",
NUM_REESTR                                                 "Номер реестра",
DATE_REESTR                                                "Дата реестра",
PNUM                                                       "Номер",
DUE_DATE                                                   "Дата оплаты",
AMOUNT                                                     "Сумма прихода",
COMMISSION                                                 "Сумма комиссии",
PAYMENT_DATA                                               "Дата платежа",
DOC_NUM                                                    "№ Док-та",
PP_NUM                                                     "№ПП",
POL_NUM                                                    "Номер ДС",
POLICY_NUM                                                 "№ ДС",
IDS                                                        "ИДС",
POLICY_HEADER_ID                                           "policy header id",
INSURED_FIO                                                "Страхователь",
PRODUCT                                                    "Продукт",
START_DATE                                                 "Дата начала ДС",
END_DATE                                                   "Дата оконания ДС",
INS_AMOUNT                                                 "Страховая сумма",
--VERIFICATION_INS_AMOUNT                                    VERIFICATION_INS_AMOUNT,
SUM_DOG                                                    as "Сумма по договору",
SUM_ZACHT                                                  as "Зачтенная сумма",
PAYMENT_CURRENCY                                           as "Валюта платежа",
STATE_POL                                                  as "Статус последней версии",
TDR_NAME                                                   as "Причина прекращения",
TDP_NAME                                                   as "Тип расторжения",
INI_NAME                                                   as "Инициатор",
AMOUNT_RETURN                                              as "Сумма возврата",
ISSUER_RETURN_DATE                                         as "Дата выплаты"
from 
(
    select DISTINCT ii.payment_register_item_id,
           vd.note,
            regexp_replace(regexp_substr(vd.note,'Реестром \d+ от \d{2}\.\d{2}\.\d{4}')
                  ,'Реестром (\d+) от (\d{2})\.(\d{2})\.(\d{2})(\d{2})','\5\3\2\1') num_reestr,

            regexp_replace(regexp_substr(vd.note,'Реестром \d+ от \d{2}\.\d{2}\.\d{4}')
                          ,'Реестром (\d+) от (\d{2})\.(\d{2})\.(\d{2})(\d{2})','\2/\3') date_reestr,
            ltrim(regexp_substr(vd.note,'Реестром \d+'),'Реестром ') pnum,
            ii.due_date,
            ii.amount,
            ii.COMMISSION,
            ii.payment_data,
            ii.doc_num doc_num,
            ii.num pp_num,
            ii.POL_NUM,
            ii.b_pol_num policy_num,
    --        ii.IDS, --Капля П.С. Заменил на ph, т.к. ii через outer join и инфы может не быть
            ph.IDS,
            ph.policy_header_id, -- Капля П.С. 200367
            NVL(NVL(ii.INSURED_FIO,ii.insurer_name),
                    (SELECT cpol.obj_name_orig
                     FROM ins.p_policy pol,
                          ins.t_contact_pol_role polr,
                          ins.p_policy_contact pcnt,
                          ins.contact cpol
                     WHERE pol.policy_id = ph.last_ver_id
                           AND pol.policy_id = pcnt.policy_id
                           AND pcnt.contact_id = cpol.contact_id
                           AND pcnt.contact_policy_role_id = polr.id
                           AND polr.brief = 'Страхователь'
                     )
            ) INSURED_FIO,
            (SELECT prod.description
             FROM ins.t_product prod
             WHERE prod.product_id = ph.product_id
            ) product,
            nvl(ph.start_date,'01.01.1900') start_date,
            (SELECT pol.end_date
             FROM ins.p_policy pol
             WHERE pol.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)
            ) end_date,
            (SELECT MAX(pc.ins_amount)
             FROM ins.p_policy pol,
                  ins.as_asset a,
                  ins.p_cover pc,
                  ins.status_hist st
             WHERE pol.policy_id = ins.pkg_policy.get_last_version(ii.ph_id)
                   AND pol.policy_id = a.p_policy_id
                   AND a.as_asset_id = pc.as_asset_id
                   AND pc.status_hist_id = st.status_hist_id
                   AND st.brief != 'DELETED'
            ) ins_amount,
            /*CASE WHEN
              (SELECT pc.ins_amount
               FROM ins.p_policy pol,
                    ins.as_asset a,
                    ins.p_cover pc,
                    ins.status_hist st,
                    ins.t_prod_line_option opt,
                    ins.t_product_line pl,
                    ins.t_product_line_type plt
               WHERE pol.policy_id = ins.pkg_policy.get_last_version(ii.ph_id)
                     AND pol.policy_id = a.p_policy_id
                     AND a.as_asset_id = pc.as_asset_id
                     AND pc.status_hist_id = st.status_hist_id
                     AND st.brief != 'DELETED'
                     AND pc.t_prod_line_option_id = opt.id
                     AND opt.product_line_id = pl.id
                     AND pl.product_line_type_id = plt.product_line_type_id
                     AND plt.brief = 'RECOMMENDED') !=
              (SELECT SUM(pc.ins_amount) / COUNT(*)
               FROM ins.p_policy pol,
                    ins.as_asset a,
                    ins.p_cover pc,
                    ins.status_hist st
               WHERE pol.policy_id = ins.pkg_policy.get_last_version(ii.ph_id)
                     AND pol.policy_id = a.p_policy_id
                     AND a.as_asset_id = pc.as_asset_id
                     AND pc.status_hist_id = st.status_hist_id
                     AND st.brief != 'DELETED')
               THEN 1
               ELSE 0
            END verification_ins_amount,*/
            ii.epg_amount sum_dog,
            ins.Pkg_Payment.get_set_off_amount(ii.epg_payment_id, NULL, NULL) sum_zacht,
            ii.PAYMENT_CURRENCY,
            (SELECT rf.name
             FROM ins.document d,
                  ins.doc_status_ref rf
             WHERE d.document_id = ins.pkg_policy.get_last_version(ii.ph_id)
                   AND rf.doc_status_ref_id = d.doc_status_ref_id
            ) state_pol,
            pol_decl.tdr_name,
            pol_decl.tdp_name,
            ap_decl.ini_name,
            ap_decl.amount amount_return,
            nvl(pol_decl.issuer_return_date,'01.01.1900') issuer_return_date
    from ins.p_pol_header ph,
         ins.t_product    pr,
         ins.V_PAYMENT_REGISTER ii,
         ins.ven_ac_payment acp_pp,
         ins.doc_templ dt,
         (SELECT vda.document_id,
                 vda.note
          FROM ins.ven_document vda
          WHERE vda.doc_templ_id = 86) vd,
         (SELECT dacpa.document_id
          FROM ins.document dacpa
          WHERE dacpa.doc_status_ref_id != 41) dacp,
         (SELECT pol.pol_header_id,
                 tdr.name tdr_name,
                 CASE WHEN tdr.name = 'Отказ Страховщика' THEN 'Аннулирование'
                      WHEN tdr.name = 'Отказ Страхователя от договора' THEN 'Аннулирование'
                      WHEN tdr.name = 'Неоплата первого взноса' THEN 'Аннулирование'
                      WHEN tdr.name = 'Решение суда (аннулирование)' THEN 'Аннулирование'
                      WHEN tdr.name = 'Отказ страхователя от НУ' THEN 'Аннулирование'
                 ELSE 'Расторжение'
                 END tdp_name,
                 pol.policy_id,
                 ppd.issuer_return_date
          FROM ins.p_policy pol,
               ins.t_decline_reason tdr,
               ins.p_pol_decline ppd
          WHERE EXISTS (SELECT NULL
                        FROM ins.doc_status ds
                        WHERE ds.document_id = pol.policy_id
                          AND ds.doc_status_ref_id = 182)
                AND pol.decline_reason_id = tdr.t_decline_reason_id
                AND pol.policy_id = ppd.p_policy_id
          ) pol_decl,
          (SELECT ac.payment_id,
                  dd.parent_id,
                  /*CASE WHEN tct.description = 'Физическое лицо'
                        THEN 'КЛИЕНТ'
                       ELSE 'БАНК'
                  END ini_name,*/
                  ac.amount,
                  (SELECT CASE WHEN ca.obj_name = 'ООО «ХОУМ КРЕДИТ ЭНД ФИНАНС БАНК»'
                                THEN 'БАНК'
                               ELSE 'КЛИЕНТ'
                          END
                    FROM  ins.ven_cn_contact_bank_acc ccba
                        ,ins.cn_document_bank_acc dacc
                        ,ins.contact ca
                        ,ins.document d
                        ,ins.doc_status_ref dsr
                        ,ins.doc_status ds
                    WHERE ca.contact_id=ccba.owner_contact_id
                      and dacc.cn_contact_bank_acc_id=ccba.id
                      and d.document_id=dacc.cn_document_bank_acc_id
                      and d.doc_status_id=ds.doc_status_id
                      and ccba.contact_id = c.contact_id
                      and dsr.doc_status_ref_id=ds.doc_status_ref_id
                      and ccba.used_flag=1
                      and dsr.brief='ACTIVE'
                      AND ROWNUM = 1
                 ) ini_name
           FROM ins.ven_ac_payment ac,
                ins.doc_doc dd,
                ins.contact c,
                ins.t_contact_type tct
           WHERE ac.payment_id = dd.child_id
                 AND ac.doc_templ_id = 20175/*'PAYREQ'*/
                 AND ac.contact_id = c.contact_id
                 AND tct.id = c.contact_type_id) ap_decl
    where --ph.product_id IN (47975, 47976, 47977, 47978, 47979) --Чирков закомментировал 247043 перенести РенКап 
          pr.brief like 'RenCap%'  --Чирков добавил 247043 перенести РенКап 
          and pr.product_id = ph.product_id
          AND ph.policy_header_id = ii.ph_id (+)
          /*AND ii.payment_register_item_id IN (1139509)*/
          AND ii.ac_payment_id = vd.document_id(+)
          AND ii.ac_payment_id = acp_pp.payment_id(+)
          AND dt.doc_templ_id(+) = acp_pp.doc_templ_id
          /*AND vd.doc_templ_id = 86*/
                                /*(SELECT dt.doc_templ_id
                                 FROM ins.doc_templ dt
                                 WHERE dt.brief = 'ПП')*/
          AND dacp.document_id(+) = ii.epg_payment_id
          /*AND dacp.doc_status_ref_id != 41*/
                                        /*(SELECT rf.doc_status_ref_id
                                         FROM ins.doc_status_ref rf
                                         WHERE rf.brief = 'ANNULATED')*/
          /*AND ii.IDS = 4570002818*/
          AND ph.policy_header_id = pol_decl.pol_header_id (+)
          AND pol_decl.policy_id = ap_decl.parent_id (+)
          AND ii.ddso_status(+) NOT IN ('ANNULATED')
          /*AND ii.b_pol_num = '2150487987'*/
          /*AND EXISTS (SELECT NULL
                      FROM ins.t_product prod
                      WHERE prod.product_id = ph.product_id
                            AND prod.description LIKE 'КС CR92%')*/
)main;

create or replace view V_POLICY_USVE as
/*Договоры страхования, с признаком «Групповой договор» равным «0 – нет»,  в статусе «К прекращению. Ожидание решения УСВЭ», 
для которых дело по страховому событию по рискам, указанным ниже, находится либо в статусе «Отказано в выплате»,
 либо в статусе «Передано на оплату», либо в статусе «Закрыт». 
Список рисков:
•  «Смерть Застрахованного в результате  болезни»;
•  «Смерть Застрахованного в результате авиа- или железнодорожной катастрофы»;
•  «Смерть Застрахованного в результате болезни или несчастного случая»;
•  «Смерть Застрахованного в результате дорожно-транспортного происшествия»;
•  «Смерть Застрахованного в результате несчастного случая»;
•  «Смерть Застрахованного по любой причине»;
•  «Смерть и инвалидность в результате несчастного случая».
26.1.2015 Черных М.
*/
WITH policy_usve AS
 (SELECT pp.policy_id
        ,pp.pol_header_id
    FROM p_policy       pp
        ,document       d
        ,doc_status_ref dsr
        ,p_pol_header   pph
   WHERE pp.is_group_flag = 0 /*Не групповой*/
     AND pp.policy_id = pph.policy_id /*Активная версия*/
     AND pp.policy_id = d.document_id
     AND d.doc_status_ref_id = dsr.doc_status_ref_id
     AND dsr.brief IN ('TO_QUIT_AWAITING_USVE'))
SELECT pu.policy_id
      ,to_number(NULL) p_pol_change_notice_id
  FROM policy_usve    pu
      ,p_policy       pp
      ,c_claim_header ch
      ,c_claim        c
      ,document       cd
      ,doc_status_ref cdsr
      ,t_peril        tp
 WHERE pu.pol_header_id = pp.pol_header_id
   AND ch.p_policy_id = pp.policy_id
   AND ch.c_claim_header_id = c.c_claim_header_id
   AND c.c_claim_id = cd.document_id
   AND cd.doc_status_ref_id = cdsr.doc_status_ref_id
   AND cdsr.brief IN ('REFUSE_PAY', 'FOR_PAY', 'CLOSE')
   AND ch.peril_id = tp.id
   AND tp.description IN ('Смерть застрахованного в результате болезни'
                         ,'Смерть застрахованного в результате авиа- или железнодорожной катастрофы'
                         ,'Смерть застрахованного в результате болезни или несчастного случая'
                         ,'Смерть Застрахованного в результате дорожно-транспортного происшествия'
                         ,'Смерть застрахованного в результате несчастного случая'
                         ,'Смерть Застрахованного по любой причине')

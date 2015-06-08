<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="paym_req" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="paym_req" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
      
    <userParameter name="EVENT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 

    <dataSource name="Q_CLAIM">
      <select>
      <![CDATA[ 
WITH main_ch AS
 (SELECT cch.c_claim_header_id    AS c_claim_header_id
        ,ds_cc.start_date         AS claim_start_date
        ,cch.peril_id             AS peril_id
        ,tp.description           AS peril_name
        ,pc.t_prod_line_option_id AS t_prod_line_option_id
        ,pc.p_cover_id            AS p_cover_id
        ,cch.fund_id              AS fund_id
        ,cch.declare_date         AS declare_date
        ,cc.c_claim_id            AS c_claim_id
        ,to_number(substr(cch.num,  instr(cch.num,'/')+1,1)) order_num        
    FROM ven_c_claim_header cch
        ,c_claim        cc
        ,document       d_cc
        ,doc_status     ds_cc
        ,doc_status_ref dsr_cc
        ,t_peril        tp
        ,p_cover        pc
   WHERE cc.c_claim_header_id = cch.c_claim_header_id
     AND cc.c_claim_id = cch.active_claim_id
     AND d_cc.document_id = cc.c_claim_id
     AND ds_cc.doc_status_id = d_cc.doc_status_id
     AND dsr_cc.doc_status_ref_id = d_cc.doc_status_ref_id
     AND cch.peril_id = tp.id
     AND cch.p_cover_id = pc.p_cover_id
     AND dsr_cc.brief = 'DECISION' --Принято решение по делу                  
     AND cch.c_event_id = :EVENT_ID),
main_vipl AS
 (SELECT mch.c_claim_header_id
        ,d_vipl.note
        ,vipl.amount
        ,dt.brief
        ,vipl.contact_id
        ,mch.order_num
    FROM main_ch        mch
        ,c_claim        cc
        ,doc_doc        dd
        ,ac_payment     vipl
        ,document       d_vipl
        ,doc_status_ref dsr
        ,doc_templ      dt
   WHERE cc.c_claim_header_id = mch.c_claim_header_id
     AND dd.parent_id = cc.c_claim_id
     AND vipl.payment_id = dd.child_id
     AND vipl.payment_id = d_vipl.document_id
     AND d_vipl.doc_status_ref_id = dsr.doc_status_ref_id
     AND dsr.brief NOT IN ('ANNULATED', 'CANCEL')
     AND dt.doc_templ_id = d_vipl.doc_templ_id
     AND dt.brief IN ('PAYORDER', 'PAYORDER_SETOFF'))
--END_WITH
SELECT
--дата платежного тебования
 status_claim
 --номер уведомления
,num
 --номер договора
,pol
 --валюта
,brief
 --сумма платежа
,ltrim(to_char(SUM(CASE
                     WHEN has_payorder = 1
                          AND has_payorder_setoff = 0 --есть только В, то сумма В
                      THEN
                      nvl(payorder_sum, 0)
                     WHEN has_payorder = 0
                          AND has_payorder_setoff = 1 --есть только З, то сумма З
                      THEN
                      nvl(payorder_setoff_sum, 0)
                   --если и В и З, то только В    
                     ELSE
                      nvl(payorder_sum, 0)
                   END) * (share_payment / 100) --Чирков/204161: Ошибка в выгрузке ПТ 000005584/1/
              ,'999G999G999G999G999G999G990D99'
              ,'NLS_NUMERIC_CHARACTERS = '', ''')) s_amount
 --сумма прописью
,pkg_utils.money2speech(SUM(CASE
                              WHEN has_payorder = 1
                                   AND has_payorder_setoff = 0 --есть только В, то сумма В
                               THEN
                               nvl(payorder_sum, 0)
                              WHEN has_payorder = 0
                                   AND has_payorder_setoff = 1 --есть только З, то сумма З
                               THEN
                               nvl(payorder_setoff_sum, 0)
                            --если и В и З, то только В    
                              ELSE
                               nvl(payorder_sum, 0)
                            END) * (share_payment / 100) --Чирков/204161: Ошибка в выгрузке ПТ 000005584/1/
                       ,fund_id) amount_in_words
 
 --банк получателя
,bank
 --получатель
,beneficiary
 --расчетный счет получателя
,account_nr
 --бик
,bic
 --кор счет
,account_corr
 --инн
,inn
 --кпп
,cpp
 --адрес банка
,NULL bank_adr
 --адрес получателя
,beneficiary_adr
 --код продукта
,prod
 --подготовлено      
,prep
 --назначение платежа        
,flag
 --код региона
,code
 --комментарии
,note
 --поле вид платежа
,paym_type
,rn
  FROM ( --SELECT SEL_1************************************************************************************************************ 
        SELECT
        --дата платежного тебования
         status_claim
          --номер уведомления
        ,num
          --номер договора
        ,pol
          --валюта
        ,brief
          --банк получателя
        ,bank
          --получатель
        ,beneficiary
          --расчетный счет получателя
        ,account_nr
          --бик
        ,bic
          --кор счет
        ,account_corr
          --инн
        ,inn
          --кпп
        ,cpp
          --адрес банка
        ,NULL bank_adr
          --адрес получателя
        ,beneficiary_adr
          --код продукта
        ,prod
          --подготовлено      
        ,prep
          --назначение платежа            
        ,CASE
            WHEN flag_num = 1 THEN
             (SELECT peril_name
                FROM main_ch mch_
               WHERE mch_.peril_name LIKE 'Дожитие%'
                 AND rownum = 1) || flag_2
            WHEN flag_num IN (2, 3) THEN
             CASE
               WHEN flag_num = 2 THEN
                'Выплата страхового обеспечения'
               WHEN flag_num = 3 THEN
                ''
             END ||
             pkg_utils.get_aggregated_string(CAST(MULTISET (SELECT peril_name
                                                     FROM main_ch            mch_
                                                         ,t_prod_line_option plo
                                                    WHERE plo.id = mch_.t_prod_line_option_id
                                                      AND plo.brief = 'NonInsuranceClaims') AS
                                                  ins.tt_one_col)
                                            ,', ') || flag_2
            WHEN flag_num = 4 THEN
             'Выплата страхового обеспечения' || flag_2
            WHEN flag_num = 5 THEN
             'Учет страховой выплаты в счет очередного страхового взноса' || flag_2
          END flag
          --поле вид платежа
        ,CASE
            WHEN flag_num = 5 THEN
             'Учет страховой выплаты в счет очередного страхового взноса'
            ELSE
             'Выплата страхового обеспечения возмещения / Claims maturity'
          END paym_type
          --код региона
        ,region_code code
          --комментарии
        ,(   
                             SELECT max(mvpl.note) keep (dense_rank first ORDER BY mvpl.order_num)
                               FROM main_vipl mvpl
                              WHERE mvpl.brief = 'PAYORDER'
                                    and mvpl.contact_id = sel_.cn_person_id
         )  note  
        ,1 rn
          --поля для рассчета сумм
        ,has_payorder
        ,has_payorder_setoff
        ,payorder_sum
        ,payorder_setoff_sum
        ,fund_id
        ,share_payment --Чирков/204161: Ошибка в выгрузке ПТ 000005584/1/
        --FROM SEL_1************************************************************************************************************   
          FROM ( --SELECT SEL_*********************************************************************************************************
                 SELECT CASE
                           WHEN MAX(trunc(mch.claim_start_date)) over() = MIN(trunc(mch.claim_start_date))
                            over() THEN
                            to_char(mch.claim_start_date, 'DD.MM.YYYY')
                         END status_claim
                        ,e.num
                        ,decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num) pol
                        ,f.fund_id
                        ,f.brief
                        ,nvl((SELECT SUM(mvpl.amount)
                               FROM main_vipl mvpl
                              WHERE mvpl.c_claim_header_id = mch.c_claim_header_id
                                AND mvpl.brief = 'PAYORDER')
                            ,0) payorder_sum
                         
                        ,nvl((SELECT SUM(mvpl.amount)
                               FROM main_vipl mvpl
                              WHERE mvpl.c_claim_header_id = mch.c_claim_header_id
                                AND mvpl.brief = 'PAYORDER_SETOFF')
                            ,0) payorder_setoff_sum
                         
                        ,CASE --если есть в уведомлении дела с риском Дожитие%, то вывесть любой из этих рисков 
                           WHEN EXISTS (SELECT peril_name
                                   FROM main_ch mch_
                                  WHERE mch_.peril_name LIKE 'Дожитие%') THEN
                            1
                         --если по уведомлению есть дела с программой Нестраховые убытки 
                         --и есть дела с программой не Нестраховые убытки
                           WHEN EXISTS (SELECT peril_name
                                   FROM main_ch            mch_
                                       ,t_prod_line_option plo
                                  WHERE plo.id = mch_.t_prod_line_option_id
                                    AND plo.brief = 'NonInsuranceClaims')
                                AND EXISTS (SELECT peril_name
                                   FROM main_ch            mch_
                                       ,t_prod_line_option plo
                                  WHERE plo.id = mch_.t_prod_line_option_id
                                    AND plo.brief != 'NonInsuranceClaims') THEN
                            2
                         --если по уведомлению есть дела только с программой Нестраховые убытки 
                           WHEN EXISTS (SELECT peril_name
                                   FROM main_ch            mch_
                                       ,t_prod_line_option plo
                                  WHERE plo.id = mch_.t_prod_line_option_id
                                    AND plo.brief = 'NonInsuranceClaims')
                                AND NOT EXISTS (SELECT peril_name
                                   FROM main_ch            mch_
                                       ,t_prod_line_option plo
                                  WHERE plo.id = mch_.t_prod_line_option_id
                                    AND plo.brief != 'NonInsuranceClaims') THEN
                            3
                           WHEN --если есть выплаты по ПС                     
                            (SELECT COUNT(1)
                               FROM main_vipl mvpl
                              WHERE mvpl.c_claim_header_id = mch.c_claim_header_id
                                AND mvpl.brief = 'PAYORDER') > 0 THEN
                            4
                           ELSE
                            5
                         END flag_num        
                         
                        ,CASE
                           WHEN EXISTS (SELECT 1
                                   FROM main_ch       mch_
                                       ,c_damage      dam_
                                       ,t_damage_code dc_
                                  WHERE mch_.c_claim_id = dam_.c_claim_id
                                    AND dc_.id = dam_.t_damage_code_id
                                    AND dc_.brief = 'DOP_INVEST_DOHOD') THEN
                            ' включая Дополнительный инвестиционный доход ' ||
                            (SELECT SUM(ROUND(dam_.payment_sum *
                                              acc.get_cross_rate_by_brief(1
                                                                         ,fu_dam.brief
                                                                         ,fu_ch.brief
                                                                         ,declare_date)
                                             ,2))
                               FROM main_ch       mch_
                                   ,c_damage      dam_
                                   ,t_damage_code dc_
                                   ,fund          fu_dam
                                   ,fund          fu_ch
                              WHERE mch_.c_claim_id = dam_.c_claim_id
                                AND dc_.id = dam_.t_damage_code_id
                                AND fu_dam.fund_id = dam_.damage_fund_id
                                AND fu_ch.fund_id = mch_.fund_id
                                AND dam_.status_hist_id IN (1, 2)
                                AND dc_.brief = 'DOP_INVEST_DOHOD')
                           ELSE
                            ''
                         END AS flag_2                                                                 
                        ,cec.cn_person_id
                        ,ccb.bank_name || ' ' || ccb.branch_name bank
                        ,ent.obj_name(bank_owner.ent_id, bank_owner.contact_id) beneficiary
                        ,ccb.account_nr
                        ,bic.id_value bic
                        ,krc.id_value account_corr
                        ,inn.id_value inn
                        ,cpp.id_value cpp
                        ,(select adr.address_name
                            from v_cn_contact_address adr
                           where pkg_contact.get_primary_address(ccb.bank_id) = adr.adress_id(+)
                             and rownum = 1
                           ) beneficiary_adr
                        ,prod.brief prod

                         
                        ,decode(us.name
                               ,'Панферова Валерия Олеговна'
                               ,'Панферова В.О.'
                               ,'Асланова Елена Федоровна'
                               ,'Асланова Е.Ф.'
                               ,'Асланова Елена Фёдоровна'
                               ,'Асланова Е.Ф.'
                               ,'Кутенкова Марина Юрьевна'
                               ,'Кутенкова М.Ю.'
                               ,'Вера Вадимовна Лопотовская'
                               ,'Лопотовская В.В.'
                               ,us.name) prep
                        ,(SELECT substr(tp.ocatd, 1, 2) region_code
                            FROM organisation_tree ot
                                ,department        d
                                ,t_province        tp
                           WHERE ph.agency_id = d.department_id(+)
                             AND d.org_tree_id = ot.organisation_tree_id(+)
                             AND ot.province_id = tp.province_id(+)) region_code
                         
                        ,CASE
                           WHEN EXISTS ( --
                                 SELECT 1
                                   FROM main_vipl mvpl
                                  WHERE mvpl.c_claim_header_id = mch.c_claim_header_id
                                    AND mvpl.brief = 'PAYORDER') THEN
                            1
                           ELSE
                            0
                         END has_payorder
                        ,CASE
                           WHEN EXISTS (SELECT 1
                                   FROM main_vipl mvpl
                                  WHERE mvpl.c_claim_header_id = mch.c_claim_header_id
                                    AND mvpl.brief = 'PAYORDER_SETOFF') THEN
                            1
                           ELSE
                            0
                         END has_payorder_setoff
                         
                        ,cd.share_payment --Чирков/204161: Ошибка в выгрузке ПТ 000005584/1/
                 --FROM SEL_**********************************************************************************************************
                   FROM main_ch        mch
                        ,ven_c_event    e
                        ,c_claim_header cch
                        ,p_policy       p
                        ,p_pol_header   ph
                        ,t_product      prod
                        ,fund           f
                         
                        ,c_declarants cd
                        ,c_event_contact cec
                        ,cn_contact_bank_acc ccb
                        ,(SELECT ii.id_value
                                ,ii.contact_id
                            FROM cn_contact_ident ii
                           WHERE ii.id_type = 10) bic
                        ,(SELECT ii.id_value
                                ,ii.contact_id
                            FROM cn_contact_ident ii
                           WHERE ii.id_type = 1) inn
                        ,(SELECT ii.id_value
                                ,ii.contact_id
                            FROM cn_contact_ident ii
                           WHERE ii.id_type = 20022) cpp
                        ,(SELECT ii.id_value
                                ,ii.contact_id
                            FROM cn_contact_ident ii
                           WHERE ii.id_type = 11) krc
                        ,contact bank_owner
                        ,ven_sys_user us
                 
                  WHERE mch.c_claim_header_id = cch.c_claim_header_id
                    AND cd.c_claim_header_id = cch.c_claim_header_id
                    AND cd.cn_contact_bank_acc_id = ccb.id
                    AND cch.c_event_id = e.c_event_id
                    AND p.policy_id = cch.p_policy_id
                    AND ph.policy_header_id = p.pol_header_id
                    AND prod.product_id = ph.product_id
                    AND cec.c_event_contact_id = cd.declarant_id
                    AND ph.fund_id = f.fund_id
                    AND us.sys_user_name = USER
                       
                    AND cec.cn_person_id = ccb.contact_id(+)
                    AND ccb.bank_id = bic.contact_id(+)
                    AND ccb.bank_id = inn.contact_id(+)
                    AND ccb.bank_id = cpp.contact_id(+)
                    AND ccb.bank_id = krc.contact_id(+)
                    AND ccb.owner_contact_id = bank_owner.contact_id(+)) sel_) sel_1
 GROUP BY --дата платежного тебования
           status_claim
          --номер уведомления
         ,num
          --номер договора
         ,pol
          --валюта
         ,brief
          --банк получателя
         ,bank
          --получатель
         ,beneficiary
          --расчетный счет получателя
         ,account_nr
          --бик
         ,bic
          --кор счет
         ,account_corr
          --инн
         ,inn
          --кпп
         ,cpp
          --адрес банка
         ,bank_adr
          --адрес получателя
         ,beneficiary_adr
          --код продукта
         ,prod
          --подготовлено      
         ,prep
          --назначение платежа        
         ,flag
          --код региона
         ,code
          --комментарии
         ,note
          --поле вид платежа
         ,paym_type
         ,fund_id
         ,rn
         ,share_payment
	  ]]>
      </select>
      <group name="GR_ROW">
        <dataItem name="rn"/>		        
      </group>
    </dataSource>
  </data>
  
   <programUnits>
	
  </programUnits>
  
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"f
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="?????????%20?????????1.files/filelist.xml">
<title>????????? ?????????? / Payment Request</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>33</o:TotalTime>
  <o:Created>2009-06-04T06:09:00Z</o:Created>
  <o:LastSaved>2009-06-04T06:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>247</o:Words>
  <o:Characters>1412</o:Characters>
  <o:Lines>11</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>1656</o:CharactersWithSpaces>
  <o:Version>11.8107</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:PunctuationKerning/>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
   <w:DontGrowAutofit/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:51.05pt 39.7pt 51.05pt 51.05pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"??????? ???????";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-parent:"";
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
table.MsoTableGrid
	{mso-style-name:"????? ???????";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
 <rw:foreach id="fi2" src="GR_ROW">

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=638 colspan=6 valign=top style='width:478.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'>Платежное требование / </b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='mso-ansi-language:
  EN-US'>Payment Request</span><o:p></o:p></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.45pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.45pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Дата</span></b><span style='font-size:9.0pt'> / </span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>Date:</span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="status_claim"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Номер</span></b><span style='font-size:9.0pt'> / </span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>Number:</span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="num"/><o:p></o:p></span></p>
  </td>
 </tr>
 
 
 <tr style='mso-yfti-irow:3;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Номер договора </span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE><span class=GramE>C</span>ontract</span>
  <span class=SpellE>number</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="pol"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Сумма платежа</span></b><span
  style='font-size:9.0pt'>/<span class=SpellE>Amount</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="s_amount"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Валюта</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Currency</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="brief"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Сумма прописью </span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Amount</span> <span
  class=SpellE>in</span> <span class=SpellE>words</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="amount_in_words"/></span><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Банк получателя / </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>Bank</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bank"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span class=GramE><b><span
  style='font-size:9.0pt'>C</span></b></span><b><span style='font-size:9.0pt'>Страна</span></b></span><b><span
  style='font-size:9.0pt'>, адрес банка получателя </span></b><span
  style='font-size:9.0pt'>/</span><span style='font-size:9.0pt;mso-ansi-language:
  EN-US'> </span><span class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>Bank</span> <span class=SpellE>adress</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bank_adr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:6.7pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.7pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>БИК/ </span></b><span
  style='font-size:9.0pt'>BIC<o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="bic"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>корр. счет банка</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> <span lang=EN-US>/</span></span></b><span
  class=SpellE><span style='font-size:9.0pt'>correspondence</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>bank</span> <span class=SpellE>account</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.7pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="account_corr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Получатель</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Beneficiary</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:9.0pt'><rw:field id="" src="beneficiary"/></span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:6.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Адрес получателя /</span></b><span
  style='font-size:9.0pt'> <span class=SpellE>Beneficiary</span> <span
  class=SpellE>address</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="beneficiary_adr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;height:4.35pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.35pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:7.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:7.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>ИНН банка получателя</span></b><b><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'> /</span></b><span
  class=SpellE><span style='font-size:9.0pt'>Beneficiary</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>tax</span> <span class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="inn"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span class=SpellE><b><span style='font-size:9.0pt'>расч</span></b></span><b><span
  style='font-size:9.0pt'>. счет получателя</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> </span></b><b><span
  style='font-size:9.0pt'>/</span></b><span class=SpellE><span
  style='font-size:9.0pt'>Beneficiary</span></span><span style='font-size:9.0pt'>
  <span class=SpellE>account</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:7.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="account_nr"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:22;height:2.55pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>КПП</span></b><span
  style='font-size:9.0pt'>/CPP<o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="cpp"/><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:2.55pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;height:5.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24;height:6.4pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Назначение платежа</span></b><b><span
  style='font-size:9.0pt;mso-ansi-language:EN-US'> </span></b><b><span
  style='font-size:9.0pt'>/</span></b><span class=SpellE><span
  style='font-size:9.0pt'>Payment</span></span><span style='font-size:9.0pt'> <span
  class=SpellE>purpose</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 <!-- <rw:getValue id="fl" src="flag"/>-->
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'>
  <b><rw:field id="" src="flag"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25;height:6.8pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.8pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Примечания</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Comments</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="note"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:27;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:28'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Наименование <span
  class=SpellE>кост-центра</span>/ </span></b><span class=SpellE><span
  style='font-size:9.0pt'>Name</span></span><span style='font-size:9.0pt'> of <span
  class=SpellE>cost</span> <span class=SpellE>center</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:9.0pt'> </span><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:29;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:30'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Код продукта / </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Product</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:
  EN-US'><rw:field id="" src="prod"/></span><span style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Код региона</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Region</span> <span
  class=SpellE>code</span><o:p></o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><rw:field id="" src="code"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:31;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:32'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Вид платежа</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Type</span> of <span
  class=SpellE>payment</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Перестрахование/ </span></b><span
  class=SpellE><span style='font-size:9.0pt'>Reinsurance</span></span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:33;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:black;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal style='tab-stops:68.95pt'><b><span style='font-size:9.0pt'>
  <b><rw:field id="" src="paym_type"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34;height:3.9pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.9pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Агентское вознаграждение/
  </span></b><span class=SpellE><span style='font-size:9.0pt'>Brokerage</span></span><span
  style='font-size:9.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:35;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal style='tab-stops:102.95pt'><b><span style='font-size:9.0pt'>Возврат 
  премии/</span></b><span class=SpellE><span style='font-size:9.0pt'>Premium</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>return</span>, <span
  class=SpellE>surrender</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:36;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Экпертиза</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Examination</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:37;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:38'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Налогообложение платежа /
  </span></b><span class=SpellE><span style='font-size:9.0pt'>Tax</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>deductible</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>НДС включен/</span></b><span
  style='font-size:9.0pt'> VAT <span class=SpellE>Included</span><o:p></o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'>Сумма НДС/VAT <span
  class=SpellE>amount</span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:39;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:black;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=bottom style='width:180.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>НДС не взимается</span></b><span
  style='font-size:9.0pt'>/ VAT <span class=SpellE>Not</span> <span
  style='mso-spacerun:yes'> </span></span><span lang=EN-US style='font-size:
  9.0pt;mso-ansi-language:EN-US'>A</span><span class=SpellE><span
  style='font-size:9.0pt'>pplicable</span></span><b><span style='font-size:
  9.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'> <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:40'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=240 colspan=2 valign=top style='width:180.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=54 valign=top style='width:40.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:41'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Подготовлено</span></b><span
  style='font-size:9.0pt'>/ <span class=SpellE>Prepared</span> <span
  class=SpellE>by</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt'><rw:field id="" src="prep"/></span><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:42;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:43'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt'>Одобрено /</span></b><span
  style='font-size:9.0pt'> <span class=SpellE>Accepted</span> <span
  class=SpellE>by</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><span
  style='font-size:9.0pt'>Лопотовская</span></span><span style='font-size:9.0pt'>
  В.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:44;height:3.05pt'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.05pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:45'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:69.45pt'><b><span style='font-size:9.0pt'>Главный 
  бухгалтер /</span></b><span class=SpellE><span style='font-size:9.0pt'>Chief</span></span><span
  style='font-size:9.0pt'> <span class=SpellE>accountant</span><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=415 colspan=4 valign=top style='width:311.15pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt'>Белоусова Е.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:46'>
  <td width=207 valign=top style='width:155.6pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=174 colspan=2 valign=top style='width:130.25pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=121 valign=top style='width:90.9pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=207 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=120 style='border:none'></td>
  <td width=120 style='border:none'></td>
  <td width=54 style='border:none'></td>
  <td width=121 style='border:none'></td>
 </tr>
 <![endif]>
</table>
 
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <span style='font-size:12.0pt;font-family:"Times New Roman","serif";mso-fareast-font-family:
	"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
	AR-SA'><br clear=all style='page-break-before:always'>
  </span>
 </tr>
 </rw:foreach>
<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report>

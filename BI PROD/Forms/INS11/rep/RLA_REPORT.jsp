<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
   <userParameter name="P_ROLL_ID"/>
   <userParameter name="P_HEADER_ID"/>
   <userParameter name="P_ACT_PERF_ID"/>
<userParameter name="p_arh_date_begin" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_arh_date_end" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_to_rep" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_print_date" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_report_number" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>

<userParameter name="p_rla_num" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_name_rla" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_rla_begin" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_rla_address" datatype="character" width="2000"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_rla_inn" datatype="character" width="2000"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_rla_rs" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_rla_ks" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_name_broker_agent" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_name_broker_insurer" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_company" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_company_address" datatype="character" width="2000"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_company_inn" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_company_rs" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_company_ks" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_chief_od" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_depart_name" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>

	<dataSource name="Q_1">
      <select>
      <![CDATA[
		SELECT 1 rec_num, vcp.contact_id, nvl(ctr.brief,'@') doc_desc, NVL (ctr.serial_nr, '@') p_ser,
		         NVL (ctr.id_value, '@') p_num, NVL (ctr.place_of_issue, '@') pvidan,
		         DECODE (TO_CHAR (NVL (ctr.issue_date,
		                               TO_DATE ('01.01.1900', 'DD.MM.YYYY')
		                              ),
		                          'DD.MM.YYYY'
		                         ),
		                 '01.01.1900', '@',
		                 TO_CHAR (ctr.issue_date, 'DD.MM.YYYY')
		                ) data_v
		    FROM contact vcp,
		         (select cci.id_value,
		                 cci.place_of_issue,
		                 cci.serial_nr,
		                 cci.issue_date,
		                 tit.brief,
		                 cci.contact_id
		          from cn_contact_ident cci, 
		               t_id_type tit
		          WHERE cci.id_type = tit.ID
		          AND (UPPER (tit.brief) IN ('PASS_RF','PASS_IN') or tit.id = 20003)
		          AND cci.is_used = 1
		          ) ctr
		   WHERE vcp.contact_id = ctr.contact_id(+)
		     and vcp.contact_id = (SELECT agh.agent_id FROM ins.ag_contract_header agh WHERE agh.ag_contract_header_id = :P_HEADER_ID)
		ORDER BY NVL (ctr.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC 
	   ]]>
      </select>
      <group name="G_1">
        <dataItem name="rec_num"/>
      </group>
    </dataSource>
<dataSource name="Q_2">
      <select>
      <![CDATA[
  	  SELECT 0 rec_num1,
	  		 DENSE_RANK() OVER (ORDER BY a.ids) p_numpp,
			 NUM_POL,
 			 HOLDER,
 			 PRODUCT,
 		     RISK_NAME,
 			 PAY_PERIOD,
 			 INS_PERIOD,
 			 PAYMENT_DATE,
 			 PREM_PAY_NUMBER,
 			 VOL_RATE,
 			 COM_PAY_NUMBER,
 			 EPG_DATE,
 			 PERIOD_NAME,
 			 FUND_BRIEF,
 			 IDS
	  FROM (
	  select NUM_POL,
 HOLDER,
 PRODUCT,
 RISK_NAME,
 PAY_PERIOD,
 INS_PERIOD,
 PAYMENT_DATE,
 TO_CHAR(ROUND(PREM_PAY_NUMBER,2),'99999990D99') PREM_PAY_NUMBER,
 PREM_BACK,
 VOL_RATE,
 TO_CHAR(ROUND(COM_PAY_NUMBER,2),'99999990D99') COM_PAY_NUMBER,
 COM_BACK,
 EPG_DATE,
 PERIOD_NAME,
 FUND_BRIEF,
 IDS
from ins.RLA_CALC_POL
WHERE NVL(PAY_PERIOD,0) = 1
ORDER BY 16,13
) a
	   ]]>
      </select>
      <group name="G_2">
        <dataItem name="rec_num1"/>
      </group>
    </dataSource>
<dataSource name="Q_3">
      <select>
      <![CDATA[
SELECT SUM(0) rec_num2,
	   TO_CHAR(ROUND(SUM(PREM_PAY_NUMBER),2),'99999990D99') sum_prem_pay_number,
	   TO_CHAR(ROUND(SUM(COM_PAY_NUMBER),2),'99999990D99') sum_com_pay_number,
	   ins.pkg_utils.money2speech(ROUND(SUM(COM_PAY_NUMBER),2),122) all_sum_speech
FROM ins.RLA_CALC_POL
WHERE NVL(PAY_PERIOD,0) = 1
	   ]]>
      </select>
      <group name="G_3">
        <dataItem name="rec_num2"/>
      </group>
    </dataSource>
<dataSource name="Q_4">
      <select>
      <![CDATA[
SELECT SUM(0) rec_num3,
	   TO_CHAR(ROUND(SUM(COM_PAY_NUMBER),2),'99999990D99') common_pay_number
FROM ins.RLA_CALC_POL
	   ]]>
      </select>
      <group name="G_4">
        <dataItem name="rec_num3"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
p_min_payment_date VARCHAR2(30);
p_max_payment_date VARCHAR2(30);
begin

BEGIN
SELECT agh.num rla_num,
	   ins.pkg_utils.date2genitive_case(agh.date_begin) rla_begin,
	   'ООО "Ренессанс Лайф Актив"' name_rla,
	   'Адрес: Россия, 115114, г. Москва, Дербеневская наб., д.7, стр.22' rla_address,
	   'ИНН 7703672658      КПП 770301001      БИК 044525700' rla_inn,
	   'Р/С 40701810800001410093 в в АО "Райффайзенбанк", г. Москва' rla_rs,
	   'К/С 30101810200000000700' rla_ks,
	   'А.В. Чернявский' name_broker_agent,
	   'Ю.В. Махонина' name_broker_insurer,
	   'ООО "СК "Ренессанс Жизнь"' company,
	   'Адрес: Россия, 115114, г. Москва, Дербеневская наб., д.7, стр.22' company_address,
	   'ИНН 7725520440      КПП 775001001      БИК  044525700' company_inn,
	   'Р/С 40701810800001410925  в АО "Райффайзенбанк", г. Москва' company_rs,
	   'К/С 30101810200000000700' company_ks,
	   'В.В. Гусев' chief_od,
	    dep.name depart_name
INTO :p_rla_num,
	 :p_rla_begin,
	 :p_name_rla,
	 :p_rla_address,
	 :p_rla_inn,
	 :p_rla_rs,
	 :p_rla_ks,
	 :p_name_broker_agent,
	 :p_name_broker_insurer,
	 :p_company,
	 :p_company_address,
	 :p_company_inn,
	 :p_company_rs,
	 :p_company_ks,
	 :p_chief_od,
     :p_depart_name
FROM ins.ven_ag_contract_header agh,
	 ins.department dep
WHERE agh.num = '467696'
  AND agh.is_new = 0
  AND dep.department_id = agh.agency_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
	 :p_rla_num := '';
	 :p_rla_begin := '';
	 :p_name_rla := '';
	 :p_rla_address := '';
	 :p_rla_inn := '';
	 :p_rla_rs := '';
	 :p_rla_ks := '';
	 :p_name_broker_agent := '';
	 :p_name_broker_insurer := '';
	 :p_company := '';
	 :p_company_address := '';
	 :p_company_inn := '';
	 :p_company_rs := '';
	 :p_company_ks := '';
	 :p_chief_od := '';
     :p_depart_name := '';
END;

BEGIN
SELECT ins.pkg_utils.date2genitive_case(NVL(rl.date_end,arh.date_end)) arh_date_end,
	       TRIM(TO_CHAR(NVL(rl.date_end,arh.date_end),'MM')||'/'||TO_CHAR(NVL(rl.date_end,arh.date_end),'YYYY')) to_rep,
	       ins.pkg_utils.date2genitive_case(NVL(rl.date_begin,arh.date_begin)) arh_date_begin,
	       TRIM(TO_CHAR(SYSDATE,'DD.MM.YYYY')) print_date,
	       TRIM(TO_CHAR(NVL(rl.date_begin,arh.date_begin),'MM')) report_number
INTO :p_arh_date_end,
		 :p_to_rep,
	     :p_arh_date_begin,
		 :p_print_date,
		 :p_report_number
FROM ins.ven_ag_roll_header arh,
	     ins.ven_ag_roll rl
WHERE arh.ag_roll_header_id = rl.ag_roll_header_id
  AND rl.ag_roll_id = :P_ROLL_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	:p_arh_date_end := '';
	:p_to_rep := '';
	:p_arh_date_begin := '';
	:p_print_date := '';
	:p_report_number := '';
END;
  
return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:???????;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	mso-rotate:0;}
.xl65
	{mso-style-parent:style0;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	border:.5pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-weight:700;}
.xl68
	{mso-style-parent:style0;
	vertical-align:middle;}
.xl69
	{mso-style-parent:style0;
	text-align:center;
	border:.5pt solid windowtext;}
.xl70
	{mso-style-parent:style0;
	font-weight:700;
	font-style:italic;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>????1</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>17</x:ActiveRow>
       <x:ActiveCol>6</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????2</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????3</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11955</x:WindowHeight>
  <x:WindowWidth>18975</x:WindowWidth>
  <x:WindowTopX>-615</x:WindowTopX>
  <x:WindowTopY>270</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
</xml><![endif]-->
</head>

<body link=blue vlink=purple>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=14><p style='text-align:center;font-size:12.0pt'><b>ОТЧЕТ АГЕНТА № АВ-<rw:field id="" src="p_to_rep"/> от <rw:field id="" src="p_arh_date_end"/></b></p></td>
</tr>
<tr><td colspan=14><p style='text-align:center;font-size:12.0pt'><b>к Агентскому договору № <rw:field id="" src="p_rla_num"></rw:field> ОТ <rw:field id="" src="p_rla_begin"></rw:field>.</b></p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'>г. Москва</p></td>
<td colspan=7 style='mso-number-format:"dd\/mm\/yyyy"'><p style='text-align:right;font-size:12.0pt'><rw:field id="" src="p_print_date"/></p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=14><p style='text-align:left;font-size:12.0pt'>За период с <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/>.</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=14><p style='text-align:left;font-size:12.0pt'>За период с <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/> при посредничестве АГЕНТА были заключены следующие договоры страхования, по которым страховая премия была оплачена в полном объеме и поступила на расчетный счет СТРАХОВЩИКА:</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750
 style='width:750.0pt;font-size:8.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'> 
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=50 rowspan=2 style='width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ п/п</b></p></td>
<td width=50 rowspan=2 style='width:200.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ договора</b></p></td>
<td width=200 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Страхователь</b></p></td>
<td width=80 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Программа страхования</b></p></td>
<td width=50 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Год страхования</b></p></td>
<td width=50 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Срок уплаты взносов</b></p></td>
<td width=80 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Периодичность</b></p></td>
<td width=80 colspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Размер страхового взноса (премии)</b></p></td>
<td width=80 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Дата оплаты</b></p></td>
<td width=80 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Курс на дату уплаты взноса (премии)</b></p></td>
<td width=80 rowspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ квитанции А7 или № плат.поручения</b></p></td>
<td width=80 colspan=2 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Размер агентского вознаграждения</b></p></td>
</tr>
<tr>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>в дол.США, Евро</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>в рублях</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>в % от взноса</b></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>в рублях</b></p></td>
</tr>
<rw:foreach id="F2" src="G_2">
<tr>
<td width=50 style='width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_numpp"/></p></td>
<td width=50 style='mso-number-format:"@";width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="NUM_POL"/></p></td>
<td width=200 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="HOLDER"/></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="RISK_NAME"/></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="PAY_PERIOD"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="INS_PERIOD"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="PERIOD_NAME"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p> </p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="PREM_PAY_NUMBER"/></p></td>
<td width=80 style='mso-number-format:"dd\/mm\/yyyy";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="PAYMENT_DATE"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p> </p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p> </p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="VOL_RATE"/></p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="COM_PAY_NUMBER"/></p></td>
</tr>
</rw:foreach>	
<rw:foreach id="F3" src="G_3">
<tr>
<td width=50 style='width:50.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=50 style='width:200.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=200 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=50 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p>ИТОГО:</p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="SUM_PREM_PAY_NUMBER"/></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=80 style='width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p>ИТОГО:</p></td>
<td width=80 style='mso-number-format:"@";width:80.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="SUM_COM_PAY_NUMBER"/></p></td>
</tr>
</table>

</rw:foreach>


<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=6><p style='text-align:left;font-size:12.0pt'>Вознаграждение за отчетный период составляет: <rw:foreach id="F4" src="G_4"> <rw:field id="" src="common_pay_number"/> </rw:foreach> </p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Агентом удержано вознаграждение: 0 руб.</p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>К выплате причитается: <rw:foreach id="F5" src="G_3"> <rw:field id="" src="SUM_COM_PAY_NUMBER"/> </rw:foreach></p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr><td colspan=14><p style='text-align:left;font-size:12.0pt'>Расчет вознаграждения прилагается к настоящеему отчету.</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr>
<td colspan=6><p style='text-align:left;font-size:12.0pt'><b>Агент <rw:field id="" src="p_name_rla"/></b></p></td>
<td colspan=4><p style='text-align:center;font-size:12.0pt'>________________________________</p></td>
<td colspan=4><p style='text-align:center;font-size:12.0pt'>/ <rw:field id="" src="p_name_broker_agent"/> / </p></td>
</tr>
<tr>
<td colspan=6><p style='text-align:left;font-size:8.0pt'></p></td>
<td colspan=4><p style='text-align:center;font-size:8.0pt'>Подпись</p></td>
<td colspan=4><p style='text-align:center;font-size:8.0pt'>ФИО</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr>
<td colspan=4><p style='text-align:left;font-size:12.0pt'><b>Заполняется представителем СТРАХОВЩИКА:</b></p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'></p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'></p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'></p></td>
</tr>
<tr>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Исчислено стр.взносов всего: </p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'><rw:foreach id="F6" src="G_3"><rw:field id="" src="SUM_PREM_PAY_NUMBER"/></p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Исчислено аг.вознаграждения всего:</p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="SUM_COM_PAY_NUMBER"/></rw:foreach></p></td>
</tr>
<tr>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Сумма к перечислению СТРАХОВЩИКУ:</p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'><rw:foreach id="F7" src="G_3"><rw:field id="" src="SUM_PREM_PAY_NUMBER"/></rw:foreach></p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Сумма к перечислению АГЕНТУ:</p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'><rw:foreach id="F8" src="G_4"><rw:field id="" src="common_pay_number"/></rw:foreach></p></td>
</tr>
<tr>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Недоперечислено СТРАХОВЩИКУ:</p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'>0</p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>Подлежит возврату АГЕНТУ:</p></td>
<td colspan=3><p style='text-align:left;font-size:12.0pt'>0</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr>
<td colspan=5><p style='text-align:left;font-size:8.0pt'>Отчет получен СТРАХОВЩИКОМ <rw:field id="" src="p_arh_date_end"/></p></td>
<td colspan=4><p style='text-align:left;font-size:8.0pt'></p></td>
<td colspan=5><p style='text-align:right;font-size:8.0pt'>Отчет отправлен СТРАХОВЩИКОМ на доработку "__"__________20__ г.</p></td>
</tr>
<tr>
<td colspan=5><p style='text-align:left;font-size:8.0pt'>Отчет принят СТРАХОВЩИКОМ <rw:field id="" src="p_arh_date_end"/></p></td>
<td colspan=4><p style='text-align:center;font-size:8.0pt'>____________________________ /</p></td>
<td colspan=5><p style='text-align:center;font-size:8.0pt'><b><rw:field id="" src="p_name_broker_insurer"/></b></p></td>
</tr>
<tr>
<td colspan=5><p style='text-align:left;font-size:6.0pt'></p></td>
<td colspan=4><p style='text-align:center;font-size:6.0pt'>Подпись</p></td>
<td colspan=5><p style='text-align:center;font-size:6.0pt'>ФИО Представителя СТРАХОВЩИКА</p></td>
</tr>
</table>

<table border=0 cellspacing=0 cellpadding=0 width=750 style='width:750.0pt;border:none'>
<tr>
<td colspan=7><p style='text-align:center;font-size:12.0pt'><b>СТРАХОВЩИК</b></p></td>
<td colspan=7><p style='text-align:center;font-size:12.0pt'><b>АГЕНТ</b></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><b><rw:field id="" src="p_company"/></b></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><b><rw:field id="" src="p_name_rla"/></b></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_company_address"/></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_rla_address"/></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'>Реквизиты:</p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'>Реквизиты:</p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_company_inn"/></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_rla_inn"/></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_company_rs"/></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_rla_rs"/></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_company_ks"/></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'><rw:field id="" src="p_rla_ks"/></p></td>
</tr>
<tr>
<td colspan=7><p style='text-align:left;font-size:12.0pt'>______________________<rw:field id="" src="p_chief_od"/></p></td>
<td colspan=7><p style='text-align:left;font-size:12.0pt'>_____________________<rw:field id="" src="p_name_broker_agent"/></p></td>
</tr>
</table>

</body>

</html>


</rw:report>

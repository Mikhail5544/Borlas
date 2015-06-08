<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="paym_req" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="paym_req" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="PAY_HEADER_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="PAY_DATE" datatype="character" width="20"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_date_begin" datatype="character" width="20"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_date_end" datatype="character" width="20"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_sysdate_year" datatype="character" width="20"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_MANAG">
      <select>
      <![CDATA[ 
SELECT c.obj_name_orig name_agent_mn,
       agh.num num_agent_mn,
       agh.ag_contract_header_id header_mn,
       aca.category_name cat_mn,
       ch.description sales_chn_mn,
       dep.name depart_mn,
       SUM(det.prem_sum) + det.other_prem_sum prem_sum_mn
FROM ins.ag_roll_pay_detail det,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_roll ar,
     ins.ag_category_agent aca,
     ins.t_sales_channel ch,
     ins.department dep
WHERE det.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND det.ag_contract_header_id = agh.ag_contract_header_id
  AND det.ag_roll_id = ar.ag_roll_id
  AND det.department_id = dep.department_id
  AND det.ag_category_agent_id = aca.ag_category_agent_id
  AND det.ag_sales_channel_id = ch.id
  AND agh.agent_id = c.contact_id
  AND det.state_detail = 1
  AND aca.brief IN ('MN')
GROUP BY c.obj_name_orig,
         agh.num,
         agh.ag_contract_header_id,
         aca.category_name,
         ch.description,
         dep.name,
		 det.other_prem_sum
		]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_MANAG">
	  	  <displayInfo x="1.00273" y="2.35986" width="3.78675" height="5.00063"/>
        <dataItem name="name_agent_mn" datatype="vchar2" columnOrder="1" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="name_agent_mn">
          <dataDescriptor expression="name_agent_mn" descriptiveExpression="name_agent_mn"
           order="1" width="30"/>
        </dataItem>
		<dataItem name="num_agent_mn" datatype="vchar2" columnOrder="2" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="num_agent_mn">
          <dataDescriptor expression="num_agent_mn" descriptiveExpression="num_agent_mn"
           order="2" width="30"/>
        </dataItem>
		<dataItem name="header_mn" oracleDatatype="number" columnOrder="3"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="header_mn">
          <dataDescriptor expression="header_mn" descriptiveExpression="header_mn"
           order="3" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="cat_mn" datatype="vchar2" columnOrder="4" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="cat_mn">
          <dataDescriptor expression="cat_mn" descriptiveExpression="cat_mn"
           order="4" width="30"/>
        </dataItem>
		<dataItem name="sales_chn_mn" datatype="vchar2" columnOrder="5" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="sales_chn_mn">
          <dataDescriptor expression="sales_chn_mn" descriptiveExpression="sales_chn_mn"
           order="5" width="30"/>
        </dataItem>
		<dataItem name="depart_mn" datatype="vchar2" columnOrder="6" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="depart_mn">
          <dataDescriptor expression="depart_mn" descriptiveExpression="depart_mn"
           order="6" width="30"/>
        </dataItem>
		<dataItem name="prem_sum_mn" oracleDatatype="number" columnOrder="7"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="prem_sum_mn">
          <dataDescriptor expression="prem_sum_mn" descriptiveExpression="prem_sum_mn"
           order="7" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
	  </group>
    </dataSource>
    <dataSource name="Q_DIR">
      <select>
      <![CDATA[ 
SELECT c.obj_name_orig name_agent,
       agh.num num_agent,
       agh.ag_contract_header_id,
       aca.category_name,
       ch.description sales_chn,
       dep.name depart,
       SUM(det.prem_sum) + det.other_prem_sum prem_sum
FROM ins.ag_roll_pay_detail det,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_roll ar,
     ins.ag_category_agent aca,
     ins.t_sales_channel ch,
     ins.department dep
WHERE det.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND det.ag_contract_header_id = agh.ag_contract_header_id
  AND det.ag_roll_id = ar.ag_roll_id
  AND det.department_id = dep.department_id
  AND det.ag_category_agent_id = aca.ag_category_agent_id
  AND det.ag_sales_channel_id = ch.id
  AND agh.agent_id = c.contact_id
  AND det.state_detail = 1
  AND aca.brief IN ('DR','DR2','TD')
GROUP BY c.obj_name_orig,
         agh.num,
         agh.ag_contract_header_id,
         aca.category_name,
         ch.description,
         dep.name,
		 det.other_prem_sum
		]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_DIR">
	  <displayInfo x="1.00273" y="2.35986" width="3.78675" height="5.00063"/>
        <dataItem name="name_agent" datatype="vchar2" columnOrder="1" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="name_agent">
          <dataDescriptor expression="name_agent" descriptiveExpression="name_agent"
           order="1" width="30"/>
        </dataItem>
		<dataItem name="num_agent" datatype="vchar2" columnOrder="2" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="num_agent">
          <dataDescriptor expression="num_agent" descriptiveExpression="num_agent"
           order="2" width="30"/>
        </dataItem>
		<dataItem name="ag_contract_header_id" oracleDatatype="number" columnOrder="3"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="ag_contract_header_id">
          <dataDescriptor expression="ag_contract_header_id" descriptiveExpression="ag_contract_header_id"
           order="3" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="category_name" datatype="vchar2" columnOrder="4" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="category_name">
          <dataDescriptor expression="category_name" descriptiveExpression="category_name"
           order="4" width="30"/>
        </dataItem>
		<dataItem name="sales_chn" datatype="vchar2" columnOrder="5" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="sales_chn">
          <dataDescriptor expression="sales_chn" descriptiveExpression="sales_chn"
           order="5" width="30"/>
        </dataItem>
		<dataItem name="depart" datatype="vchar2" columnOrder="6" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="depart">
          <dataDescriptor expression="depart" descriptiveExpression="depart"
           order="6" width="30"/>
        </dataItem>
		<dataItem name="prem_sum" oracleDatatype="number" columnOrder="7"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="prem_sum">
          <dataDescriptor expression="prem_sum" descriptiveExpression="prem_sum"
           order="7" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
	  </group>
    </dataSource>
  </data>
  
   <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

begin
select to_char(pay.date_begin,'dd.mm.yyyy') date_begin,
       to_char(pay.date_end,'dd.mm.yyyy') date_end,
	   TO_CHAR(SYSDATE,'YYYY')
into :p_date_begin, :p_date_end, :p_sysdate_year
from ins.ag_roll_pay_header pay
where pay.ag_roll_pay_header_id = :PAY_HEADER_ID;
exception when no_data_found then
 :p_date_begin := ''; :p_date_end := ''; :p_sysdate_year := '2013';
end;

  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  
  <reportPrivate templateName="rwbeige"/>
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
	font-size:10.0pt;
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
	font-size:9.0pt;
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
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:nowrap;}
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
	text-align:center;
	border:.5pt solid windowtext;
	white-space:nowrap;}
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
	border-bottom:none;
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
.xl75
	{mso-style-parent:style0;
	text-align:right;
	border:none;}
.xl76
	{mso-style-parent:style0;
	text-align:center;
	border:none;
	font-size:6.0pt;}
.xl77
	{mso-style-parent:style0;
	text-align:center;
	border:none;}
.xl79
	{border:.5pt solid windowtext;}
.xl80
	{border-left:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-top:none;
	border-bottom:1.5pt solit windowstext;}
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

<table border=0 width=70 style='width:70.0pt;border:none'>
<col width=60 pre-wrap style='mso-width-source:userset;mso-width-alt:9000;width:190pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4827;width:99pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3657;width:75pt'>
</tr>
 
 <tr>
  <td colspan=2><p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p></td>
  <td colspan=2><p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p></td>
  <td colspan=3><p class=MsoNormal align=right style='text-align:right'><span style='font-size:9.0pt'>ООО "СК "Ренессанс Жизнь"</span></p>
  </td>
 </tr>
 
 <tr>
  <td colspan=2><p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p></td>
  <td colspan=2><p class=MsoNormal align=center style='text-align:center'><span style='font-size:10.0pt'>Приказ</span></p></td>
  <td colspan=3><p class=MsoNormal><span style='font-size:9.0pt'>&nbsp;</span></p></td>
 </tr>
 
 <tr>
  <td colspan=2 style='mso-number-format:"dd\/mm\/yyyy"'>
  <p class=MsoNormal align=left><span style='font-size:9.0pt'><rw:field id="" src="pay_date"/></span></p>
  </td>
  <td colspan=2><p class=MsoNormal align=center style='text-align:center'><span style='font-size:10.0pt'>О выплате премий</span></p></td>
  <td colspan=3><p class=MsoNormal align=right style='text-align:right'><span style='font-size:9.0pt'>№ ______ ОД / </span></p></td>
 </tr>
 
 <tr>
  <td colspan=2><p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p></td>
  <td colspan=2><p class=MsoNormal align=center style='text-align:center'><span style='font-size:10.0pt'>ПРИКАЗЫВАЮ:</span></p></td>
  <td colspan=3><p class=MsoNormal><span style='font-size:9.0pt'>&nbsp;</span></p></td>
 </tr>
 
 <tr>
  <td colspan=7>
  <p class=MsoNormal><span style='font-size:9.0pt'>1. Выплатить комиссионую премию за ОП и ОП3 (1-ого года), комиссионную
  премию за договоры страхования, начиная со 2-го по 5-ый (включительно) годы действия, премию за выполнение плана по ОП, 
  комиссионную премию за собственные продажи, комиссионную премию за ОП личной группы, премию за достижение уровня,
  комиссионную премию по договорам ОПС, дополнительную премию по договорам ОПС, комиссионную премию за достижение КСП,
  премию за развитие Директора за период с <rw:field id="" src="p_date_begin"/> по <rw:field id="" src="p_date_end"/> следующим директорам агентств / филиалов в размере:
  </span></p>
  </td>
 </tr>
<tr><td colspan=7><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr> 

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ФИО</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ АД</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ИД</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Должность</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Сумма, руб.</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Канал продаж</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Агентство / филиал</b></p></td>
</tr>
<rw:foreach id="g_dir" src="G_DIR">
<tr>
<td width=7 pre-wrap style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="name_agent"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="num_agent"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="ag_contract_header_id"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="category_name"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="prem_sum"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="sales_chn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="depart"/></p></td>
</tr>
 </rw:foreach>
 
<tr><td colspan=7><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
 
 <tr>
 <td colspan=7>
  <p class=MsoNormal><span style='font-size:9.0pt'>2. Выплатить комиссионую премию за ОП и ОП3 (1-ого года), комиссионную
  премию за договоры страхования, начиная со 2-го по 5-ый (включительно) годы действия, 
  комиссионную премию за собственные продажи, премию за достижение уровня,
  комиссионную премию по качественным договорам ОПС, дополнительную премию по качественным договорам ОПС,
  комиссионную премию за достижение КСП, премию за развитие Менеджера за период с <rw:field id="" src="p_date_begin"/> по <rw:field id="" src="p_date_end"/>
  следующим менеджерам, в размере:</span></p>
  </td>
 </tr>
 <tr><td colspan=7><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
 
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ФИО</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ АД</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ИД</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Должность</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Сумма, руб.</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Канал продаж</b></p></td>
<td width=3 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Агентство / филиал</b></p></td>
</tr>
<rw:foreach id="g_manag" src="G_MANAG">
<tr>
<td width=7 pre-wrap style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="name_agent_mn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="num_agent_mn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="header_mn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="cat_mn"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="prem_sum_mn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="sales_chn_mn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="depart_mn"/></p></td>
</tr>
</rw:foreach>
 
<tr><td colspan=7><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
 
 <tr>
  <td colspan=7>
  <p class=MsoNormal><span style='font-size:9.0pt'>3. Контроль за исполнением настоящего Приказа возложить на Главного бухгалтера
  Белоусову Е.В.</span></p>
  </td>
 </tr>
 
<tr><td colspan=7><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
 
<tr>
 <td colspan=5><p class=MsoNormal><span style='font-size:9.0pt'>Генеральный директор</span></p></td>
 <td colspan=2><p class=MsoNormal><span style='font-size:9.0pt'>Ю.О. Смышляев</span></p></td>
</tr>

</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report>

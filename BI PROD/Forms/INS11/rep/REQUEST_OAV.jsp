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
	 <userParameter name="p_art_name" datatype="character" width="1000"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_prem_sum" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="p_sysdate_year" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_total_life" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_total_acc" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_total_npf" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_total_sofi" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_total" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_OAV">
      <select>
      <![CDATA[ 
SELECT c.obj_name_orig name_agent,
       agh.num num_agent,
       agh.ag_contract_header_id header_id,
       tct.description leg_pos,
       ch.description sales_chn,
       dep.name depart,
	   
	   SUM(CASE WHEN det.vol_type_brief in ('RL','FDep','INV') THEN
           CASE WHEN det.ig_property = 1 THEN det.prem_sum ELSE 0 END ELSE 0 END) + det.other_prem_sum RL_LIFE_sum,

       SUM(CASE WHEN det.vol_type_brief in ('RL','FDep','INV') THEN
           CASE WHEN det.ig_property = 0 THEN det.prem_sum ELSE 0 END ELSE 0 END) RL_ACCIDENT_sum,

       SUM(CASE WHEN det.vol_type_brief IN ('NPF','NPF02','NPF(MARK9)') THEN det.prem_sum
                ELSE 0 END) NPF_sum,

       SUM(CASE WHEN det.vol_type_brief = 'SOFI' THEN det.prem_sum ELSE 0 END) SOFI_sum,

       SUM(CASE WHEN det.vol_type_brief IN ('RL','FDep','INV','SOFI','NPF','NPF02','NPF(MARK9)') THEN det.prem_sum ELSE 0 END) + det.other_prem_sum total,
	   aca.category_name
FROM ins.ag_roll_pay_detail det,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_roll ar,
     ins.ag_category_agent aca,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.t_contact_type tct,
     ins.ag_volume_type avt
WHERE det.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND det.ag_contract_header_id = agh.ag_contract_header_id
  AND det.ag_roll_id = ar.ag_roll_id
  AND tct.id = det.contact_type_id
  AND det.department_id = dep.department_id
  AND det.ag_category_agent_id = aca.ag_category_agent_id
  AND det.ag_sales_channel_id = ch.id
  AND avt.ag_volume_type_id = det.vol_type_id
  AND agh.agent_id = c.contact_id
  AND det.state_detail = 1
GROUP BY c.obj_name_orig,
         agh.num,
         agh.ag_contract_header_id,
         ch.description,
         dep.name,
         tct.description,
		 aca.category_name,
		 det.other_prem_sum
		]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_OAV">
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
		<dataItem name="header_id" oracleDatatype="number" columnOrder="3"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="header_id">
          <dataDescriptor expression="header_id" descriptiveExpression="header_id"
           order="3" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="leg_pos" datatype="vchar2" columnOrder="4" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="leg_pos">
          <dataDescriptor expression="leg_pos" descriptiveExpression="leg_pos"
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
		<dataItem name="RL_LIFE_sum" oracleDatatype="number" columnOrder="7"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="RL_LIFE_sum">
          <dataDescriptor expression="RL_LIFE_sum" descriptiveExpression="RL_LIFE_sum"
           order="7" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="RL_ACCIDENT_sum" oracleDatatype="number" columnOrder="8"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="RL_ACCIDENT_sum">
          <dataDescriptor expression="RL_ACCIDENT_sum" descriptiveExpression="RL_ACCIDENT_sum"
           order="8" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="NPF_sum" oracleDatatype="number" columnOrder="9"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="NPF_sum">
          <dataDescriptor expression="NPF_sum" descriptiveExpression="NPF_sum"
           order="9" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="SOFI_sum" oracleDatatype="number" columnOrder="10"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="SOFI_sum">
          <dataDescriptor expression="SOFI_sum" descriptiveExpression="SOFI_sum"
           order="10" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="total" oracleDatatype="number" columnOrder="11"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="total">
          <dataDescriptor expression="total" descriptiveExpression="total"
           order="11" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="category_name" datatype="vchar2" columnOrder="12" width="2000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="category_name">
          <dataDescriptor expression="category_name" descriptiveExpression="category_name"
           order="12" width="30"/>
        </dataItem>
	  </group>
    </dataSource>
  </data>
  
   <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
p_other_sum NUMBER;
p_prem_sum NUMBER;
begin

begin
select to_char(pay.date_begin,'dd.mm.yyyy') date_begin,
       to_char(pay.date_end,'dd.mm.yyyy') date_end,
     'Партнерс' art_name,
     s.prem_sum,
     TO_CHAR(SYSDATE,'YYYY')
into :p_date_begin, :p_date_end, :p_art_name, p_prem_sum, :p_sysdate_year
from ins.ag_roll_pay_header pay,
     (select NVL(SUM(det.prem_sum),0) prem_sum
        from ins.ag_roll_pay_detail det
        where det.ag_roll_pay_header_id = :PAY_HEADER_ID
              and det.state_detail = 1) s
where pay.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND pay.company = 'Партнерс';
exception when no_data_found then
 :p_date_begin := ''; :p_date_end := ''; :p_art_name := ''; :p_prem_sum := ''; :p_sysdate_year := '2013';
end;

BEGIN
SELECT SUM(CASE WHEN det.vol_type_brief in ('RL','FDep','INV') THEN
           CASE WHEN det.ig_property = 1 THEN det.prem_sum ELSE 0 END ELSE 0 END) RL_LIFE_sum,

       SUM(CASE WHEN det.vol_type_brief in ('RL','FDep','INV') THEN
           CASE WHEN det.ig_property = 0 THEN det.prem_sum ELSE 0 END ELSE 0 END) RL_ACCIDENT_sum,

       SUM(CASE WHEN det.vol_type_brief IN ('NPF','NPF02','NPF(MARK9)') THEN det.prem_sum
                ELSE 0 END) NPF_sum,

       SUM(CASE WHEN det.vol_type_brief = 'SOFI' THEN det.prem_sum ELSE 0 END) SOFI_sum,

       SUM(CASE WHEN det.vol_type_brief IN ('RL','FDep','INV','SOFI','NPF','NPF02','NPF(MARK9)') THEN det.prem_sum ELSE 0 END) total
INTO :p_total_life, :p_total_acc, :p_total_npf, :p_total_sofi, :p_total
FROM ins.ag_roll_pay_detail det,
     ins.ven_ag_contract_header agh,
     ins.contact c,
     ins.ag_roll ar,
     ins.ag_category_agent aca,
     ins.t_sales_channel ch,
     ins.department dep,
     ins.t_contact_type tct,
     ins.ag_volume_type avt
WHERE det.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND det.ag_contract_header_id = agh.ag_contract_header_id
  AND det.ag_roll_id = ar.ag_roll_id
  AND tct.id = det.contact_type_id
  AND det.department_id = dep.department_id
  AND det.ag_category_agent_id = aca.ag_category_agent_id
  AND det.ag_sales_channel_id = ch.id
  AND avt.ag_volume_type_id = det.vol_type_id
  AND agh.agent_id = c.contact_id
  AND det.state_detail = 1;
EXCEPTION WHEN NO_DATA_FOUND THEN
  :p_total_life := 0; :p_total_acc := 0; :p_total_npf := 0; :p_total_sofi := 0; :p_total := 0;
END;

SELECT NVL(SUM(other_prem_sum),0)
INTO p_other_sum
FROM
( 
SELECT DISTINCT det.other_prem_sum,
       det.ag_contract_header_id
FROM ins.ag_roll_pay_detail det
WHERE det.ag_roll_pay_header_id = :PAY_HEADER_ID
  AND det.state_detail = 1
);

:p_total_life := :p_total_life + p_other_sum;
:p_total := :p_total + p_other_sum;

SELECT trim(to_char(p_prem_sum + p_other_sum,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', '''))
INTO :p_prem_sum
FROM DUAL;
	  
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
<% 
  int rec_count_current = 0;
%>
<body link=blue vlink=purple>

<table border=0 width=70 style='width:70.0pt;border:none'>
<col width=10 pre-wrap style='mso-width-source:userset;mso-width-alt:1500;width:30pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4827;width:99pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3657;width:75pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3254;width:67pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3401;width:70pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3657;width:75pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3254;width:67pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3401;width:70pt'>
<tr><td colspan=13><p style='text-align:right;font-size:12.0pt'>Дата <rw:field id="" src="pay_date"/></p></td></tr>
</tr>

<tr><td colspan=13><p style='text-align:center;font-size:13.0pt'><b>РЕЕСТР</b></p></td></tr>
<tr><td colspan=13><p style='text-align:center;font-size:13.0pt'>на выплату субагентского вознаграждения</p></td>
</tr>
<tr><td colspan=13><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
<tr>
<td colspan=5><p style='text-align:left;font-size:12.0pt'>к оплате ________Субагентское вознаграждение________</p></td>
<td colspan=8><p style='text-align:left;font-size:12.0pt'></p></td>
</tr>
<tr><td colspan=5><p style='text-align:center;font-size:7.0pt'>(наименование агентского вознаграждения)</p></td>
<td colspan=8><p style='text-align:center;font-size:7.0pt'></p></td>
</tr>
<tr>
<td colspan=5><p style='text-align:left;font-size:12.0pt'>за период ________ <rw:field id="" src="p_date_begin"/> по <rw:field id="" src="p_date_end"/>________</p></td>
<td colspan=8><p style='text-align:left;font-size:12.0pt'></p></td>
</tr>
<tr>
<td colspan=5><p style='text-align:center;font-size:7.0pt'>(период, за который выплачивается агентское вознаграждение)</p></td>
<td colspan=8><p style='text-align:center;font-size:7.0pt'></p></td>
</tr>
<tr>
<td colspan=5><p style='text-align:left;font-size:12.0pt'>в сумме ________ <rw:field id="" src="p_prem_sum"/> ____ рублей ____</p></td>
<td colspan=8><p style='text-align:left;font-size:12.0pt'></p></td>
</tr>
<tr><td colspan=13><p style='text-align:left;font-size:7.0pt'></p></td>
</tr>

<tr><td colspan=13><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=3 rowspan=2 style='width:3.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№п/п</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ФИО субагента</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ Субагентского договора</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Категория агента</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ID субагента</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Правовой статус субагента</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Канал продаж</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Агентство</b></p></td>
<td width=7 pre-wrap colspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Сумма субагентского вознаграждения по видам страховых рисков</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Сумма субагентского вознаграждения по договорам ОПС</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Сумма субагентского вознаграждения по Софинансированию</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Итого сумма субагентского вознаграждения</b></p></td>
</tr>
<tr>
<td width=7 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Жизнь</b></p></td>
<td width=7 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>НС</b></p></td>
</tr>
 
<rw:foreach id="g_oav" src="G_OAV">

<tr>
<td width=7 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><%=++rec_count_current%></p></td>
<td width=7 pre-wrap style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="name_agent"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="num_agent"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="category_name"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="header_id"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="leg_pos"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="sales_chn"/></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="depart"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="RL_LIFE_sum"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="RL_ACCIDENT_sum"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="NPF_sum"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="SOFI_sum"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="total"/></p></td>
</tr>
</rw:foreach>	

<tr>
<td width=7 style='width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p>ИТОГО:</p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_total_life"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_total_acc"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_total_npf"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_total_sofi"/></p></td>
<td width=7 pre-wrap style='mso-number-format:"0\.00";width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><rw:field id="" src="p_total"/></p></td>
</tr>
<tr><td colspan=13><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr><td colspan=5><p style='text-align:center;font-size:12.0pt'><b>Генеральный директор</b></p></td>
<td colspan=5><p style='text-align:center;font-size:12.0pt'><b>Ю.О. Смышляев</b></p></td>
<td colspan=3><p style='text-align:center;font-size:12.0pt'><b>______ / ________ / ______</b></p></td>
</tr>
</table>

</div>

</body>

</html>

</rw:report>

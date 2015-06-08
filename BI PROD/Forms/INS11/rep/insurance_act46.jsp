<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report">


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="dopsg_ids" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="insur_act" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="EVENT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="CLAIM_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="num" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="pol" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="prod" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="brief" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="start_date" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="end_date" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="beneficiary" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="pol_vipl" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="holder" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="vigod" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="event_date" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="status_claim" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="agent" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
     <dataSource name="Q_TABLE">
      <select canParse="no">
      <![CDATA[select peril_name,
	  				  case when upper(peril_name) like '%СМЕРТЬ%' then 1 else 0 end vgd,
	  				  LTRIM(TO_CHAR(ins_amount, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount,
					  LTRIM(TO_CHAR(payment_amount, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) payment_amount,
					  LTRIM(TO_CHAR(ins_paym, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', '''))ins_paym,
					  flag,
					  rate_tbl,
					  rate_day,
					  kolvo,
					  LTRIM(TO_CHAR(viplata, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) viplata,
					  case when real_z > 0 then LTRIM(TO_CHAR(real_z, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) else '-' end s_z,
					  case when real_z > 0 then LTRIM(TO_CHAR(case when viplata - real_z < 0 then 0 else viplata - real_z end, '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) else '-' end s_v,
					  to_char(due_date,'dd.mm.yyyy') due_date,
					  diagnose
			   from temp_tmptable_vipl]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_TABLE">
        <displayInfo x="0.04041" y="0.60620" width="1.68176" height="1.62695"/>
		<dataItem name="peril_name" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="peril name">
          <dataDescriptor expression="peril_name"
           descriptiveExpression="peril_name" order="1" width="4000"/>
        </dataItem>
		<dataItem name="vgd" oracleDatatype="number" columnOrder="28"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="vgd">
          <dataDescriptor expression="vgd" descriptiveExpression="flag"
           order="2" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="ins_amount" datatype="vchar2" columnOrder="29"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="ins amount">
          <dataDescriptor expression="ins_amount"
           descriptiveExpression="ins_amount" order="3" width="4000"/>
        </dataItem>
		<dataItem name="payment_amount" datatype="vchar2" columnOrder="30"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="payment amount">
          <dataDescriptor expression="payment_amount"
           descriptiveExpression="payment_amount" order="4" width="4000"/>
        </dataItem>
		<dataItem name="ins_paym" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="ins paym">
          <dataDescriptor expression="ins_paym"
           descriptiveExpression="ins_paym" order="5" width="4000"/>
        </dataItem>	
		<dataItem name="flag" oracleDatatype="number" columnOrder="32"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="flag">
          <dataDescriptor expression="flag" descriptiveExpression="flag"
           order="6" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="rate_tbl" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="rate tbl">
          <dataDescriptor expression="rate_tbl" descriptiveExpression="rate_tbl"
           order="7" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="rate_day" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="rate day">
          <dataDescriptor expression="rate_day" descriptiveExpression="rate_day"
           order="8" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
		<dataItem name="kolvo" datatype="vchar2" columnOrder="35"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="kolvo">
          <dataDescriptor expression="kolvo"
           descriptiveExpression="kolvo" order="9" width="4000"/>
        </dataItem>
		<dataItem name="viplata" datatype="vchar2" columnOrder="36"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="viplata">
          <dataDescriptor expression="viplata"
           descriptiveExpression="viplata" order="10" width="4000"/>
        </dataItem>
		<dataItem name="s_z" datatype="vchar2" columnOrder="37"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="s z">
          <dataDescriptor expression="s_z"
           descriptiveExpression="s_z" order="11" width="4000"/>
        </dataItem>
		<dataItem name="s_v" datatype="vchar2" columnOrder="38"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="s_v">
          <dataDescriptor expression="s_v"
           descriptiveExpression="s_v" order="12" width="4000"/>
        </dataItem>
		<dataItem name="due_date" datatype="vchar2" columnOrder="39"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="due date">
          <dataDescriptor
           expression="to_char(due_date, &apos;dd.mm.yyyy&apos;)"
         descriptiveExpression="due_date" order="13" width="10"/>
		</dataItem>
		<dataItem name="diagnose" datatype="vchar2" columnOrder="40"
         width="4000" defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="diagnose">
          <dataDescriptor expression="diagnose"
         descriptiveExpression="diagnose" order="14" width="4000"/>
		</dataItem>
	   </group>
    </dataSource>
    <dataSource name="Q_TBL">
      <select canParse="no">
      <![CDATA[select description risk_name, LTRIM(TO_CHAR(nvl(sall,0), '999G999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = '', ''')) sall
	           from temp_tmptable_comvipl]]>
      </select>
      <displayInfo x="0.43750" y="4.51038" width="0.69995" height="0.19995"/>
      <group name="G_TBL">
	  <displayInfo x="0.04041" y="0.60620" width="1.68176" height="1.62695"/>
		<dataItem name="risk_name" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="risk name">
          <dataDescriptor expression="risk_name"
           descriptiveExpression="risk_name" order="1" width="4000"/>
      </dataItem>
	  <dataItem name="sall" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sall">
          <dataDescriptor expression="sall"
           descriptiveExpression="sall" order="2" width="4000"/>
      </dataItem>
	  </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

declare
  n varchar2(10);
  k varchar2(10);
  s varchar2(10);
  t varchar2(10);
  t_asset number;
  begin
  
    select v.as_asset_id 
	into t_asset
	from ven_c_claim_header v 
	where v.c_event_id = :EVENT_ID
		  and rownum = 1;
	
	n := pkg_renlife_utils.f_param('pkg_renlife_utils.set_tmptable_ben',t_asset);
  
  	k := pkg_renlife_utils.f_param('pkg_renlife_utils.set_tmptable_vipl',:EVENT_ID);
	s := pkg_renlife_utils.f_param('pkg_renlife_utils.set_tmptable_comvipl',:EVENT_ID);
	t := pkg_renlife_utils.f_param('pkg_renlife_utils.set_tmptable_event',:EVENT_ID);
  end;

  begin
	select num,pol,prod,case brief when 'RUR' then 'рубль РФ' else brief end brief,
		   start_date,end_date,beneficiary,holder,vigod,agent,event_date,status_claim, pol_vipl
	into :num, :pol,:prod,:brief,:start_date,:end_date,:beneficiary,:holder,:vigod,:agent,:event_date,:status_claim,:pol_vipl
	from temp_tmptable_event;
	exception
      when no_data_found then :num:=''; :pol:='';:prod:='';:brief:='';
	  						  :start_date:='';:end_date:='';:beneficiary:='';:holder:='';
							  :vigod:='';:agent:='';:event_date:='';:status_claim:='';:pol_vipl:='';
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
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="Страховой%20акт.files/filelist.xml">
<title>Страховой акт</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>57</o:TotalTime>
  <o:Created>2009-06-08T12:09:00Z</o:Created>
  <o:LastSaved>2009-06-08T12:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>325</o:Words>
  <o:Characters>1857</o:Characters>
  <o:Lines>15</o:Lines>
  <o:Paragraphs>4</o:Paragraphs>
  <o:CharactersWithSpaces>2178</o:CharactersWithSpaces>
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
	font-size:10.0pt;
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
	margin:1.5cm 42.5pt 1.5cm 1.5cm;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Обычная таблица";
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
	{mso-style-name:"Сетка таблицы";
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

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'>Страховой акт</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=236 colspan=6 valign=top style='width:176.9pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>г. Москва<o:p></o:p></span></p>
  </td>
  <td width=202 colspan=6 valign=top style='width:151.15pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>Дата составления:<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><rw:field id="" src="status_claim"/><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>№ Дела<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="num"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Застрахованный<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="beneficiary"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>№ Полиса<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="pol"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Страхователь<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="holder"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Вид страхования / программа<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="prod"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span style='font-size:7.0pt'>Выгодоприобретатель</span></span><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <rw:foreach id="tbl4" src="G_TABLE">
  <rw:getValue id="vgd" src="vgd"/>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><% if (vgd.equals("1")) {%> <rw:field id="" src="vigod"/> <%} else {%> <%} %>
  </b><o:p></o:p></span></p>
  </td>
  </rw:foreach>
 </tr>
 <tr style='mso-yfti-irow:7'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Валюта договора<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:8.0pt;mso-ansi-language:
  EN-US'><b><rw:field id="" src="brief"/></b></span><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 valign=top style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Агент<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="agent"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата вступления договора
  страхования в силу<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="start_date"/></b><o:p></o:p></span></p>
  </td>
  <td width=157 colspan=4 rowspan=2 style='width:117.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата наступления страхового
  случая<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=4 rowspan=2 style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="event_date"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=182 colspan=4 valign=top style='width:136.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'>Дата окончания действия
  договора страхования (действия программы страхования)<o:p></o:p></span></p>
  </td>
  <td width=98 colspan=4 valign=top style='width:73.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="end_date"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>1. Произошел ли страховой
  случай в период действия страховой защиты (срока страхования)?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>2. Произошел ли страховой
  случай в период действия временного страхового покрытия (выжидательного
  периода)?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Нет<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>3. Был ли оплачен очередной
  взнос, если страховая премия оплачивается в рассрочку?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>4. Произошел ли страховой
  случай в период действия льготного периода?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Нет<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>5. Уведомление о страховом
  случае направлено в установленные договором сроки?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15'>
  <td width=437 colspan=11 valign=top style='width:328.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:6.0pt'>6. Были ли полностью
  предоставлены документы, подтверждающие факт наступления страхового случая?<o:p></o:p></span></p>
  </td>
  <td width=201 colspan=5 valign=top style='width:150.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:6.0pt'>Да<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:5.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Описание страхового случая<o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="tbl3" src="G_TABLE">
 <tr style='mso-yfti-irow:18'>
  <td width=638 colspan=16 valign=top style='width:700.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="DIAGNOSE"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:19'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Расчет страховой выплаты<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21'>
  <td width=56 valign=top style='width:42.05pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Название страхового риска<o:p></o:p></span></p>
  </td>
  <td width=54 colspan=2 valign=top style='width:40.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Страховая сумма<o:p></o:p></span></p>
  </td>
  <td width=73 valign=top style='width:54.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Сумма ранее произведенных
  выплат<o:p></o:p></span></p>
  </td>
  <td width=54 colspan=2 valign=top style='width:40.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Страховая сумма с учетом
  выплат<o:p></o:p></span></p>
  </td>
  <td width=45 valign=top style='width:33.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>% по таблице выплат<o:p></o:p></span></p>
  </td>
  <td width=53 valign=top style='width:39.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>% от страховой суммы за
  каждый день<o:p></o:p></span></p>
  </td>
  <td width=59 valign=top style='width:44.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Количество дней<o:p></o:p></span></p>
  </td>
  <td width=45 colspan=2 valign=top style='width:34.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Сумма к выплате<o:p></o:p></span></p>
  </td>
  <td width=57 valign=top style='width:43.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Дата очередного платежа<o:p></o:p></span></p>
  </td>
  <td width=72 colspan=2 valign=top style='width:53.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Сумма задолженности<o:p></o:p></span></p>
  </td>
  <td width=72 colspan=2 valign=top style='width:53.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:5.0pt'>Сумма к выплате с учетом
  задолженности<o:p></o:p></span></p>
  </td>
 </tr>
 
  <rw:foreach id="tbl1" src="G_TABLE">
 
 <tr style='mso-yfti-irow:22'>
  <td width=56 valign=top style='width:42.05pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt'><b><rw:field id="" src="peril_name"/></b><o:p></o:p></span></p>
  </td>
  <td width=54 colspan=2 valign=top style='width:40.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span  
  style='font-size:6.0pt'><b><rw:field id="" src="ins_amount"/></b><o:p></o:p></span></p>
  </td>
  <td width=73 valign=top style='width:54.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="payment_amount"/></b><o:p></o:p></span></p>
  </td>
  <td width=54 colspan=2 valign=top style='width:40.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="ins_paym"/></b><o:p></o:p></span></p>
  </td>
  <rw:getValue id="flg" src="flag"/>
  <td width=45 valign=top style='width:33.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><% if (flg.equals("0")) {%> <rw:field id="" src="rate_tbl" formatMask="999G999G999G999G999G999G990D99"/>% <%} else {%> - <%} %></b><o:p></o:p></span></p>
  </td>
  <td width=53 valign=top style='width:39.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><% if (flg.equals("1")) {%> <rw:field id="" src="rate_day" formatMask="999G999G999G999G999G999G990D99"/>% <%} else {%> - <%} %></b><o:p></o:p></span></p>
  </td>
  <td width=59 valign=top style='width:44.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="kolvo"/></b><o:p></o:p></span></p>
  </td>
  <td width=45 colspan=2 valign=top style='width:34.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="viplata"/></b><o:p></o:p></span></p>
  </td>
  <td width=65 valign=top style='width:50.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt'><b><rw:field id="" src="due_date"/></b><o:p></o:p></span></p>
  </td>
  <td width=72 colspan=2 valign=top style='width:53.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="s_z"/></b><o:p></o:p></span></p>
  </td>
  <td width=72 colspan=2 valign=top style='width:53.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt'><b><rw:field id="" src="s_v"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 
  </rw:foreach>
 
 <tr style='mso-yfti-irow:23'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24'>
  <td width=333 colspan=9 valign=top style='width:249.9pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'>Получатель выплаты:<o:p></o:p></span></p>
  </td>
  <td width=305 colspan=7 valign=top style='width:228.65pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><b><rw:field id="" src="pol_vipl"/></b><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=638 colspan=16 valign=top style='width:478.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Сумма к выплате<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:27'>
  <td width=392 colspan=10 valign=top style='width:293.95pt;border-top:none;
  border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;
  border-right:none;mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Название страхового случая<o:p></o:p></span></p>
  </td>
  <td width=246 colspan=6 valign=top style='width:184.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'>Сумма<o:p></o:p></span></p>
  </td>
 </tr>
 
 <rw:foreach id="tbl2" src="G_TBL">
 
 <tr style='mso-yfti-irow:28'>
  <td width=392 colspan=10 valign=top style='width:293.95pt;border-top:none;
  border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;
  border-right:none;mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;background:#99CC00;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:7.0pt'><b><rw:field id="" src="risk_name"/></b><o:p></o:p></span></p>
  </td>
  <td width=246 colspan=6 valign=top style='width:184.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt'><b><rw:field id="" src="sall"/></b><o:p></o:p></span></p>
  </td>
 </tr>
  
 </rw:foreach>
 
 <tr style='mso-yfti-irow:30'>
  <td width=56 colspan=16 valign=top style='width:42.05pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись: _______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. эксперта по урегулированию убытков<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника Управления урегулирования убытков<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись: _______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника юридического управления<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Начальника <span class=GramE>СБ</span><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Управляющего директора<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'>Подпись:
_______________________________________________________________________________</p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:6.0pt'>Ф.И.О. Президента<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>


</rw:report>

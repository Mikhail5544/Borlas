<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dop_rost" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOP_ROST" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select canParse="no">
      <![CDATA[SELECT ach.agent_id, ach.ag_contract_header_id,
       ach.date_begin date_start_dov,
sysdate+30 dat_r,
NVL (c.DATIVE, c.NAME || ' ' || c.first_name || ' ' || c.middle_name) agent_name_dat,
       c.first_name || ' ' || c.middle_name ag_n,
       c.NAME || ' ' || c.first_name || ' ' || c.middle_name agent_name,
       NVL (c.instrumental, c.NAME || ' ' || c.first_name || ' ' || c.middle_name) agent_name_instrumental,
       pkg_contact.get_address_name(pkg_contact.get_primary_address (ach.agent_id) ) addr,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || ach.num num,
       ach.date_break,
       dept_exe.contact_id dir_contact_id,
       decode(nvl(lower(vtt.description),'г-н'),'г-н','г-на','г-жа','г-жи',lower(vtt.description)) g_n,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name,
	   dep.name dept
  FROM ven_ag_contract_header ach JOIN ven_ag_contract ac
       ON (ac.ag_contract_id = ach.last_ver_id)
       JOIN ven_contact c ON c.contact_id = ach.agent_id
       LEFT OUTER JOIN ven_department dep ON (ach.agency_id = dep.department_id)
       LEFT OUTER JOIN ven_dept_executive dept_exe ON (ach.agency_id = dept_exe.department_id)
       LEFT OUTER JOIN ven_cn_person vcp ON (dept_exe.contact_id = vcp.contact_id)
       LEFT OUTER JOIN VEN_T_TITLE vtt ON (vcp.title = vtt.ID)
       left outer join ven_ag_contract_dover dov on (dov.AG_CONTRACT_HEADER_ID = ach.AG_CONTRACT_HEADER_ID)
       join t_dover_type dt on (dt.T_DOVER_TYPE_ID = dov.T_DOVER_TYPE_ID and dt.BRIEF = 'ДПАО')      
 WHERE ach.ag_contract_header_id = :p_ch_id]]>
      </select>
      <displayInfo x="1.15625" y="0.54163" width="0.69995" height="0.19995"/>
      <group name="G_TITLE">
        <displayInfo x="0.38416" y="1.25208" width="2.24426" height="2.48145"
        />
        <dataItem name="AGENT_NAME_DAT" datatype="vchar2" columnOrder="25"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name Dat">
          <dataDescriptor expression="AGENT_NAME_DAT"
           descriptiveExpression="AGENT_NAME_DAT" order="5" width="602"/>
        </dataItem>
        <dataItem name="DAT_R" datatype="date" oracleDatatype="date"
         columnOrder="24" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dat R">
          <dataDescriptor expression="DAT_R" descriptiveExpression="DAT_R"
           order="4" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="12"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="AGENT_ID"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="AG_CONTRACT_HEADER_ID" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DATE_START_DOV" datatype="date" oracleDatatype="date"
         columnOrder="14" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Start Dov">
          <dataDescriptor expression="DATE_START_DOV"
           descriptiveExpression="DATE_START_DOV" order="3"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="AG_N" datatype="vchar2" columnOrder="15" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag N">
          <dataDescriptor expression="AG_N" descriptiveExpression="AG_N"
           order="6" width="101"/>
        </dataItem>
        <dataItem name="AGENT_NAME" datatype="vchar2" columnOrder="16"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name">
          <dataDescriptor expression="AGENT_NAME"
           descriptiveExpression="AGENT_NAME" order="7" width="602"/>
        </dataItem>
        <dataItem name="AGENT_NAME_INSTRUMENTAL" datatype="vchar2"
         columnOrder="17" width="602" defaultWidth="100000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Agent Name Instrumental">
          <dataDescriptor expression="AGENT_NAME_INSTRUMENTAL"
           descriptiveExpression="AGENT_NAME_INSTRUMENTAL" order="8"
           width="602"/>
        </dataItem>
        <dataItem name="ADDR" datatype="vchar2" columnOrder="18" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor expression="ADDR" descriptiveExpression="ADDR"
           order="9" width="4000"/>
        </dataItem>
        <dataItem name="NUM" datatype="vchar2" columnOrder="19" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="NUM" descriptiveExpression="NUM"
           order="10" width="201"/>
        </dataItem>
        <dataItem name="DATE_BREAK" datatype="date" oracleDatatype="date"
         columnOrder="20" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Break">
          <dataDescriptor expression="DATE_BREAK"
           descriptiveExpression="DATE_BREAK" order="11" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="21" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="12"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="G_N" datatype="vchar2" columnOrder="22" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="G N">
          <dataDescriptor expression="G_N" descriptiveExpression="G_N"
           order="13" width="255"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="14" width="4000"/>
        </dataItem>
		<dataItem name="DEPT" datatype="vchar2" columnOrder="24"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="DEPT">
          <dataDescriptor expression="DEPT"
           descriptiveExpression="DEPT" order="15" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
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
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title></title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>jbutenko</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>61</o:TotalTime>
  <o:LastPrinted>2006-07-06T14:05:00Z</o:LastPrinted>
  <o:Created>2007-12-17T09:14:00Z</o:Created>
  <o:LastSaved>2007-12-17T09:14:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>151</o:Words>
  <o:Characters>865</o:Characters>
  <o:Company>Borlas</o:Company>
  <o:Lines>7</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1014</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
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
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
h1
	{mso-style-next:Normal;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-font-kerning:0pt;
	mso-bidi-font-weight:normal;}
h2
	{mso-style-next:Normal;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:14.0pt;
	font-family:Arial;
	font-style:italic;}
h3
	{mso-style-next:Normal;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:13.0pt;
	font-family:Arial;}
p.MsoToc1, li.MsoToc1, div.MsoToc1
	{mso-style-update:auto;
	mso-style-noshow:yes;
	mso-style-next:Normal;
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-weight:bold;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoCaption, li.MsoCaption, div.MsoCaption
	{mso-style-noshow:yes;
	mso-style-next:Normal;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:18.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBlockText, li.MsoBlockText, div.MsoBlockText
	{margin-top:0cm;
	margin-right:16.55pt;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.a, li.a, div.a
	{mso-style-name:Рисунок;
	mso-style-parent:"Body Text";
	mso-style-next:Caption;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
 /* Page Definitions */
 @page
@page Section1
	{size:595.3pt 841.9pt;
	margin:2.0cm 2.0cm 2.0cm 2.0cm;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:577596171;
	mso-list-type:hybrid;
	mso-list-template-ids:-296684240 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l0:level1
	{mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:1541242586;
	mso-list-type:hybrid;
	mso-list-template-ids:1983578046 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l1:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l1:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Courier New";}
@list l2
	{mso-list-id:1707103527;
	mso-list-type:hybrid;
	mso-list-template-ids:-264745774 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l2:level1
	{mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
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
	{mso-style-name:"Table Grid";
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

<rw:foreach id="G_TITLE" src="G_TITLE">

<div class=Section1>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=638
 style='width:478.55pt;margin-left:3.9pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:14.4pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><b><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:8.0pt;font-family:Arial;color:black'>Страховая Компания "Ренессанс Жизнь" <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:14.4pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><b><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:8.0pt;font-family:Arial;color:black'>115114, Москва, <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:13.7pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:8.0pt;font-family:Arial;color:black'>Дербеневская наб., д.7,
  стр.22<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:13.7pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:8.0pt;font-family:Arial;color:black'>тел.:+7(495)981-2-981<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:14.4pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:42.15pt'>
  <td width=500 valign=top style='width:500.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:42.15pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  style='font-size:10.0pt;font-family:Arial;color:black'><img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/logo_new.jpg" alt="logo">
 </span></b><span
  style='font-size:10.0pt;font-family:Arial;color:black'><o:p></o:p></span></p>
  </td>
  <td width=100 colspan=3 valign=top style='width:100.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:42.15pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;font-family:Arial;color:black'>Адрес по прописке</span><span
  lang=EN-US style='font-size:11.0pt;font-family:Arial;color:black;mso-ansi-language:
  EN-US'>: <rw:field id="" src="ADDR"></rw:field> </span><a name="addr_person"></a><span lang=EN-US
  style='font-size:11.0pt;font-family:Arial;color:black;mso-ansi-language:EN-US;
  mso-bidi-font-weight:bold'><span style='mso-spacerun:yes'> </span></span><span
  lang=EN-US style='font-size:10.0pt;font-family:Arial;color:black;mso-ansi-language:
  EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:14.4pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  style='font-size:11.0pt;color:black'><o:p></o:p></span></b></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><a
  name="agent_name"><span style='font-size:11.0pt;font-family:Arial;color:black;
  mso-bidi-font-weight:bold'><rw:field id="" src="AGENT_NAME"></rw:field></span></a><span style='font-size:11.0pt;
  font-family:Arial;color:black;mso-bidi-font-weight:bold'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:14.4pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><b><span style='font-size:11.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:12.25pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:10.0pt;font-family:Arial;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;height:12.25pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:10.0pt;font-family:Arial;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:12.25pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:10.0pt;font-family:Arial;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:43.0pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:43.0pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:43.0pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:12.25pt'>
  <td width=302 valign=top style='width:226.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:10.0pt;font-family:Arial;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 colspan=3 valign=top style='width:252.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12;height:12.25pt'>
  <td width=638 colspan=4 valign=top style='width:478.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'>ПИСЬМО - УВЕДОМЛЕНИЕ О РАСТОРЖЕНИИ АГЕНТСКОГО ДОГОВОРА<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:24.5pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.5pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.5pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.5pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:12.25pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'><a name=today></a>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
  Arial;color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:12.25pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><a name="per_sex"><span style='font-size:11.0pt;
  color:black'>Уважаемый (ая)</span></a><span style='font-size:11.0pt;
  color:black'><span style='mso-spacerun:yes'>  </span><a name="person_name"><b
  style='mso-bidi-font-weight:normal'><rw:field id="" src="AG_N"></rw:field></b></a>!<o:p></o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:104.3pt'>
  <td width=638 colspan=4 valign=top style='width:478.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:104.3pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span style='font-size:11.0pt;color:black'>Общество с
  ограниченной ответственностью &quot;Страховая Компания &quot;Ренессанс Жизнь&quot;, именуемое
  в дальнейшем СТРАХОВЩИК, в лице Директора департамента продаж через агентскую сеть Глушковой 
  Натальи Николаевны, действующей на основании Доверенности № 2009/06, выданной 01 января 2009 года,
  уведомляет Вас об одностороннем расторжении Агентского Договора,
  заключенного путем присоединения к Агентскому договору (Присоединения), утвержденного приказом № 27/ОД/09
   от 01.04.2009 года, со всеми изменениями и дополнениями, на основании подписания Заявления/Соглашения № <rw:field id="" src="NUM"></rw:field> от <rw:field id="" src="date_start_dov" formatMask="DD.MM.YYYY"/>.
   Датой расторжения Агентского Договора (Присоединения) является <rw:field id="" src="DAT_R" formatMask="DD.MM.YYYY"></rw:field>.
   До даты расторжения Вы обязаны передать по Акту приема-передачи бланки строгой отчетности
   в агентство/филиал ООО "СК "Ренессанс Жизнь" в городе <rw:field id="" src="DEPT"/>.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:12.25pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.25pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:22;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'>С уважением,<o:p></o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'>Глушкова Н.Н.<o:p></o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25;height:14.4pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.4pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26;mso-yfti-lastrow:yes;height:13.7pt'>
  <td width=342 colspan=2 valign=top style='width:256.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  style='font-size:11.0pt;color:black'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=68 valign=top style='width:50.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:13.7pt'>
  <p class=MsoNormal align=right style='text-align:right;mso-layout-grid-align:
  none;text-autospace:none'><span style='font-size:10.0pt;font-family:Arial;
  color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=302 style='border:none'></td>
  <td width=40 style='border:none'></td>
  <td width=68 style='border:none'></td>
  <td width=228 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-left:18.0pt'><o:p>&nbsp;</o:p></p>

</div>

</rw:foreach>

</body>

</html>


</rw:report>
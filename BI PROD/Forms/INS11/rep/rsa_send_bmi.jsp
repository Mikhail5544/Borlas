<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
   String vid_send = new String("");
%>


<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="RSA_PACK_BMI" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="RSA_PACK_BMI" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="HEADER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT org.company_name company_name FROM v_company_info org;]]>
      </select>
      <displayInfo x="0.20850" y="0.09375" width="1.42700" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.14453" y="0.75195" width="1.49084" height="0.60156"
        />
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="12"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor expression="org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_rsa_pack_ds">
      <select canParse="no">
      <![CDATA[select 
pd.exp_file_name,
case pcod.code  when 'O' then 'Основная'  when 'D' then 'Дополнительная' else 'Исправленная' end vid_pos, 
       count(pd.recid) kol_doc
from ins_dwh.rsa_pack_header ph
 left join ins_dwh.rsa_ba_pack_data pd on pd.rsa_pack_header_id = ph.rsa_pack_header_id
 left join ins_dwh.t_rsa_pack_code pcod on pcod.t_rsa_pack_code_id = pd.t_rsa_pack_code_id 
where ph.rsa_pack_header_id = :header_id --209
group by pd.exp_file_name,pcod.code
]]>
      </select>
      <displayInfo x="1.84375" y="0.11462" width="1.83337" height="0.25000"/>
      <group name="G_RSA_PACK_DS">
        <displayInfo x="1.89355" y="0.71887" width="1.87964" height="0.77246"
        />
        <dataItem name="EXP_FILE_NAME" datatype="vchar2" columnOrder="13"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Exp File Name">
          <dataDescriptor expression="EXP_FILE_NAME"
           descriptiveExpression="EXP_FILE_NAME" order="1" width="100"/>
        </dataItem>
        <dataItem name="VID_POS" datatype="vchar2" columnOrder="14" width="14"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Vid Pos">
          <dataDescriptor expression="VID_POS" descriptiveExpression="VID_POS"
           order="2" width="14"/>
        </dataItem>
        <dataItem name="KOL_DOC" oracleDatatype="number" columnOrder="15"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kol Doc">
          <dataDescriptor expression="KOL_DOC" descriptiveExpression="KOL_DOC"
           order="3" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="BMI_Send_files/filelist.xml">
<title>ПАСПОРТ ИНФОРМАЦИОННОЙ ПОСЫЛКИ</title>
<!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
margin-top:0cm;
margin-right:0cm;
margin-bottom:12.0pt;
margin-left:53.85pt;
text-align:justify;
line-height:12.0pt;
mso-pagination:widow-orphan;
font-size:10.0pt;
font-family:Arial;
mso-fareast-font-family:"Times New Roman";
mso-bidi-font-family:"Times New Roman";
letter-spacing:-.25pt;
mso-fareast-language:EN-US;
table.MSONORMALTABLE
	{mso-style-name:"Table ;
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;}

 /* Font Definitions */
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
h4
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:43.2pt;
	text-indent:-43.2pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:4;
	mso-list:l0 level4 lfo2;
	mso-hyphenate:none;
	tab-stops:list 43.2pt;
	border:none;
	mso-border-top-alt:solid windowtext .75pt;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	mso-bidi-font-weight:normal;}
h5
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:50.4pt;
	text-indent:-50.4pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:5;
	mso-list:l0 level5 lfo2;
	mso-hyphenate:none;
	tab-stops:list 50.4pt;
	border:none;
	mso-border-top-alt:solid windowtext .75pt;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:10.0pt;
	font-family:Arial;
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
h6
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:57.6pt;
	text-indent:-57.6pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:6;
	mso-list:l0 level6 lfo2;
	tab-stops:list 57.6pt;
	border:none;
	mso-border-top-alt:solid windowtext .75pt;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoHeading7, li.MsoHeading7, div.MsoHeading7
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:64.8pt;
	text-indent:-64.8pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:7;
	mso-list:l0 level7 lfo2;
	tab-stops:list 64.8pt;
	border:none;
	mso-border-top-alt:solid windowtext .75pt;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.MsoHeading8, li.MsoHeading8, div.MsoHeading8
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:72.0pt;
	text-indent:-72.0pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:8;
	mso-list:l0 level8 lfo2;
	tab-stops:list 72.0pt;
	border:none;
	mso-border-top-alt:solid windowtext .75pt;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoHeading9, li.MsoHeading9, div.MsoHeading9
	{mso-style-parent:Title;
	mso-style-next:Normal;
	margin-top:11.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:79.2pt;
	text-indent:-79.2pt;
	line-height:16.0pt;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	mso-outline-level:9;
	mso-list:l0 level9 lfo2;
	tab-stops:list 79.2pt;
	border:none;
	padding:0cm;
	mso-padding-alt:16.0pt 0cm 0cm 0cm;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-1.0pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:53.85pt;
	text-align:center;
	mso-line-height-alt:12.0pt;
	mso-pagination:widow-orphan;
	mso-outline-level:1;
	font-size:16.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	letter-spacing:-.25pt;
	mso-font-kerning:14.0pt;
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:53.85pt;
	text-align:justify;
	line-height:12.0pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-.25pt;
	mso-fareast-language:EN-US;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.11pt, li.11pt, div.11pt
	{mso-style-name:"Стиль Основной текст + 11 pt влево";
	mso-style-parent:"Body Text";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	mso-hyphenate:none;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	letter-spacing:-.25pt;
	mso-fareast-language:EN-US;}
@page Section1
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:3.0cm 2.0cm 42.55pt 2.0cm;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:-5;
	mso-list-template-ids:1220567800;}
@list l0:level1
	{mso-level-start-at:5;
	mso-level-text:%1;
	mso-level-tab-stop:21.6pt;
	mso-level-number-position:left;
	margin-left:21.6pt;
	text-indent:-21.6pt;}
@list l0:level2
	{mso-level-text:"%1\.%2";
	mso-level-tab-stop:28.8pt;
	mso-level-number-position:left;
	margin-left:28.8pt;
	text-indent:-28.8pt;}
@list l0:level3
	{mso-level-text:"%1\.%2\.%3";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l0:level4
	{mso-level-style-link:"Heading 4";
	mso-level-text:"%1\.%2\.%3\.%4";
	mso-level-tab-stop:43.2pt;
	mso-level-number-position:left;
	margin-left:43.2pt;
	text-indent:-43.2pt;}
@list l0:level5
	{mso-level-style-link:"Heading 5";
	mso-level-text:"%1\.%2\.%3\.%4\.%5";
	mso-level-tab-stop:50.4pt;
	mso-level-number-position:left;
	margin-left:50.4pt;
	text-indent:-50.4pt;}
@list l0:level6
	{mso-level-style-link:"Heading 6";
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6";
	mso-level-tab-stop:57.6pt;
	mso-level-number-position:left;
	margin-left:57.6pt;
	text-indent:-57.6pt;}
@list l0:level7
	{mso-level-style-link:"Heading 7";
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7";
	mso-level-tab-stop:64.8pt;
	mso-level-number-position:left;
	margin-left:64.8pt;
	text-indent:-64.8pt;}
@list l0:level8
	{mso-level-style-link:"Heading 8";
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l0:level9
	{mso-level-style-link:"Heading 9";
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9";
	mso-level-tab-stop:79.2pt;
	mso-level-number-position:left;
	margin-left:79.2pt;
	text-indent:-79.2pt;}
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
</style>
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="G_RSA_PACK_DS_t" src="G_RSA_PACK_DS">
<rw:getValue id="VID_POS" src="VID_POS"/>
<%
  if (VID_POS != null)  vid_send = VID_POS.toString();
%>
</rw:foreach>


<div class=Section1>

<p class=MsoHeading9 align=center style='margin-left:0cm;text-align:center;
text-indent:0cm;mso-list:none;tab-stops:35.4pt;border:none;padding:0cm;mso-padding-alt:31.0pt 0cm 0cm 0cm'><span
style='mso-bidi-font-size:9.0pt;letter-spacing:2.0pt'>ПАСПОРТ ИНФОРМАЦИОННОЙ
ПОСЫЛКИ<o:p></o:p></span></p>


<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'><o:p>&nbsp;</o:p></p>

<rw:foreach id="G_ORG_CONT" src="G_ORG_CONT">
<rw:getValue id="COMPANY_NAME" src="COMPANY_NAME"/>


<p class=11pt>Страховая компания, представившая информацию: <u><%=COMPANY_NAME%></u></p>

</rw:foreach>

<p class=11pt>Вид информационной посылки: <%=vid_send%></p>

<p class=11pt>Представлено:<span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>

<p class=11pt><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .75pt;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.75pt solid windowtext;
 mso-border-insidev:.75pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:45.75pt'>
  <td width=313 style='width:235.05pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .75pt;padding:0cm 5.4pt 0cm 5.4pt;height:45.75pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=130 style='width:97.7pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .75pt;mso-border-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:45.75pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'>Имя файла</p>
  </td>
  <td width=206 style='width:154.6pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .75pt;mso-border-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:45.75pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'>Общее количество записей в файле</p>
  </td>
  <td width=295 style='width:221.45pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .75pt;mso-border-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:45.75pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'>Контрольная сумма файла </p>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'>(<span lang=EN-US style='mso-ansi-language:
  EN-US'>CRC</span> – 32)</p>
  </td>
 </tr>
<rw:foreach id="G_RSA_PACK_DS" src="G_RSA_PACK_DS">
<rw:getValue id="EXP_FILE_NAME" src="EXP_FILE_NAME"/>
<rw:getValue id="KOL_DOC" src="KOL_DOC" formatMask="999999990"/>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:33.8pt'>
  <td width=313 style='width:235.05pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .75pt;mso-border-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:33.8pt'>
  <p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;
  mso-list:skip'>Реестр данных по договорам страхования и страхователям</p>
  </td>
  <td width=130 style='width:97.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .75pt;padding:0cm 5.4pt 0cm 5.4pt;height:
  33.8pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'><%=EXP_FILE_NAME%></p>
  </td>
  <td width=206 style='width:154.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .75pt;padding:0cm 5.4pt 0cm 5.4pt;height:
  33.8pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'><%=KOL_DOC%></p>
  </td>
  <td width=295 style='width:221.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .75pt;padding:0cm 5.4pt 0cm 5.4pt;height:
  33.8pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center;mso-list:skip'> </p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=11pt>Представитель СК <u><span style='mso-ansi-language:EN-US'><span
style='mso-spacerun:yes'> </span><span lang=EN-US><span
style='mso-spacerun:yes'>                                                              </span></span></span></u><span
style='mso-spacerun:yes'> </span>(должность, ФИО) </p>

<p class=11pt><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'>“<u><span
style='mso-ansi-language:EN-US'> <span lang=EN-US><span
style='mso-spacerun:yes'>      </span></span></span></u>” <u><span
style='mso-ansi-language:EN-US'><span style='mso-spacerun:yes'> </span><span
lang=EN-US><span style='mso-spacerun:yes'>                    </span><span
style='mso-spacerun:yes'>          </span><span
style='mso-spacerun:yes'> </span></span></span></u><span lang=EN-US
style='mso-ansi-language:EN-US'><span style='mso-spacerun:yes'> </span><u>200<span
style='mso-spacerun:yes'>    </span></u></span>г.</p>

</div>

</body>

</html>


</rw:report>

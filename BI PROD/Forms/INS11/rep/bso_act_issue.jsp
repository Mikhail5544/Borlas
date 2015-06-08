<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bso_act_issue" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="BSO_ACT_ISSUE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_BSO_DOCUMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_MAIN">
      <select>
      <![CDATA[select  
    rownum,
    ac.num as AGENT_DOC_NUM,     -- Номер агентского договора
    replace(pkg_utils.date2genitive_case(ac.date_begin),'года','г.') as DATE_BEGIN,  
    ent.obj_name('DEPARTMENT',da.department_id) as AGENCY,      -- Название агентства/департамента
	ent.obj_name ('CONTACT', bd.contact_to_id)  as AGENT_NAME,
    pkg_contact.get_fio_fmt(ent.obj_name ('CONTACT', bd.contact_from_id),4) as SIGN_FROM,
	pkg_contact.get_fio_fmt(ent.obj_name ('CONTACT', bd.contact_to_id),4) as SIGN_TO
  from    
  	ven_bso_document bd,  -- Документ БСО (CONTACT TO|FROM, DEPARTMENT TO|FROM)
  	ven_doc_templ dt,      -- Шаблон документа (BRIEF = 'ПередачаБСО','ВыдачаБСО')
	VEN_DEPT_AGENT DA,
	ven_ag_contract_header ac      -- Агентский договор
  where bd.bso_document_id =  :P_BSO_DOCUMENT_ID
    and bd.doc_templ_id = dt.doc_templ_id
    and da.agent_id = bd.contact_to_id
	and bd.contact_to_id = ac.agent_id (+)
	and rownum = 1  
]]>
      </select>
      <group name="G_MAIN"><dataItem name="rownum"/></group>
    </dataSource>
    <dataSource name="Q_CHILD">
      <select>
      <![CDATA[
      select
       rownum as nn,
       NUM_START,
       NUM_END,
	   QUANTITY,
	   SERIA,
	   BSO_TYPE
from (select 
	   rownum as nn,
	   bdc.num_start NUM_START, 
       nvl(bdc.num_end,bdc.num_start) NUM_END, 
       decode(bdc.num_end,null,1,to_number(bdc.num_end)-to_number(bdc.num_start)+1) as QUANTITY, 
       bs.series_name as SERIA, 
       bt.name BSO_TYPE
	from ven_bso_doc_cont bdc, -- Содержимое док. БСО (BSO_ID, N_START,N_END, BSO_SERIES_ID)
         ven_bso_type bt,      -- Вид БСО (NAME = 'Квитанция №13','Полис Осаго')
	     ven_bso_series bs    -- Серия БСО (SERIES_NAME, BSO_TYPE_ID)
    where bs.bso_type_id = bt.bso_type_id
      and bdc.bso_series_id = bs.bso_series_id
      and bdc.bso_document_id = :P_BSO_DOCUMENT_ID
	order by bdc.num_start)]]>
      </select>
      <group name="G_nn"><dataItem name="nn"/></group>
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
<link rel=File-List href="bso_act_issue.files/filelist.xml">
<title>АКТ ПРИЕМА-ПЕРЕДАЧИ  БЛАНКОВ СТРОГОЙ ОТЧЕТНОСТИ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>7</o:TotalTime>
  <o:Created>2007-03-01T08:31:00Z</o:Created>
  <o:LastSaved>2007-03-01T08:31:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>70</o:Words>
  <o:Characters>399</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>3</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>468</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
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
 /* Font Definitions */
 @font-face
	{font-family:"Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:128;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1 -369098753 63 0 4129279 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"\@Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:128;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1 -369098753 63 0 4129279 0;}
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
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:16.0pt;
	font-family:Arial;
	mso-font-kerning:16.0pt;}
p.MsoHeading7, li.MsoHeading7, div.MsoHeading7
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	mso-outline-level:7;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:16.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
p.MsoSubtitle, li.MsoSubtitle, div.MsoSubtitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.2, li.2, div.2
	{mso-style-name:" Знак2";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:12.0pt;
	mso-line-height-rule:exactly;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:Verdana;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:3.0cm 22.9pt 42.55pt 54.0pt;
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
<rw:foreach id="rp_main" src="G_MAIN">
<p class=MsoTitle><o:p>&nbsp;</o:p></p>

<p class=MsoSubtitle><span style='mso-ansi-language:RU'>АКТ
ПРИЕМА-ПЕРЕДАЧИ<span style='mso-spacerun:yes'>  </span>БЛАНКОВ СТРОГОЙ
ОТЧЕТНОСТИ <o:p></o:p></span></p>

<p class=MsoSubtitle><span style='mso-ansi-language:RU'>к агентскому / брокерскому
Договору № <rw:field id="f_AGENT_DOC_NUM" src="AGENT_DOC_NUM" /> от <u><rw:field id="f_DATE_BEGIN" src="DATE_BEGIN" /><o:p></o:p></u></span></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=856
 style='width:642.0pt;margin-left:14.4pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=268 valign=top style='width:201.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1><i><span style='font-size:12.0pt;font-family:"Times New Roman";
  mso-bidi-font-family:Arial;mso-font-kerning:0pt;font-weight:normal;
  mso-bidi-font-weight:bold'>Агентство/ Департамент:</span></i><i><span
  style='font-size:12.0pt;mso-bidi-font-size:16.0pt;font-family:"Times New Roman";
  mso-bidi-font-family:Arial;font-weight:normal'><o:p></o:p></span></i></h1>
  </td>
  <td width=588 valign=top style='width:441.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:337.35pt'><u><rw:field id="f_AGENCY" src="AGENCY" /><span style='mso-tab-count:
  1'>                                                                                                           </span><o:p></o:p></u></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=268 valign=top style='width:201.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1><i><span style='font-size:12.0pt;font-family:"Times New Roman";
  mso-bidi-font-family:Arial;mso-font-kerning:0pt;font-weight:normal;
  mso-bidi-font-weight:bold'>Агент / Брокер:<o:p></o:p></span></i></h1>
  </td>
  <td width=588 valign=top style='width:441.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:336.6pt'><u><rw:field id="f_AGENT_NAME" src="AGENT_NAME" /><span
  style='mso-tab-count:1'>                                                                                                           </span><o:p></o:p></u></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-left:9.0pt;text-align:justify;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><span style='color:black;
mso-bidi-font-style:italic'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:4.2pt;text-align:justify;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><span style='color:black;
mso-bidi-font-style:italic'>Страховщик передает, а Агент / Брокер принимает
следующие бланки строгой отчетности:</span><span style='mso-bidi-font-size:
10.0pt'><o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=828
 style='width:621.0pt;margin-left:9.45pt;border-collapse:collapse;mso-padding-alt:
 0cm 0cm 0cm 0cm'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:32.25pt'>
  <td width=48 rowspan=2 valign=top style='width:35.7pt;border:solid windowtext 1.0pt;
  border-bottom:solid black 1.0pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>№</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=420 rowspan=2 valign=top style='width:315.3pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Вид бланка</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=208 colspan=2 valign=top style='width:156.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Нумерация </b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=152 rowspan=2 valign=top style='width:114.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'>Кол-во, <span
  class=SpellE><span class=GramE>шт</span></span><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:32.25pt'>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>с<o:p></o:p></b></p>
  </td>
  <td width=112 valign=top style='width:84.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>по<o:p></o:p></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_nn" src="G_NN">
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:18.4pt'>
  <td width=48 valign=top style='width:35.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_nn" src="nn" /><o:p></o:p></span></p>
  </td>
  <td width=420 valign=top style='width:315.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_BSO_TYPE" src="BSO_TYPE" /><o:p></o:p></span></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_START" src="NUM_START" /><o:p></o:p></span></p>
  </td>
  <td width=112 valign=top style='width:84.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_END" src="NUM_END" /><o:p></o:p></span></p>
  </td>
  <td width=152 valign=top style='width:114.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_QUANTITY" src="QUANTITY" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=977
 style='width:733.0pt;margin-left:8.2pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=977 valign=top style='width:733.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=963
   style='width:722.2pt;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=486 nowrap valign=top style='width:364.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><u><span style='color:black'>От
    имени Страховщика<o:p></o:p></span></u></b></p>
    </td>
    <td width=477 nowrap valign=top style='width:357.55pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><u><span style='color:black'>От
    имени Агента / Брокера</span></u></b><u><span style='color:black'><o:p></o:p></span></u></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
    <td width=486 nowrap valign=top style='width:364.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:0cm;text-align:justify;tab-stops:129.6pt 237.6pt;
    mso-layout-grid-align:none;punctuation-wrap:simple;text-autospace:none'><span
    style='color:black'><rw:field id="f_sf" src="SIGN_FROM" /><span style='mso-tab-count:1'>                                    </span>/<span
    style='mso-tab-count:1'>                                   </span>/
    Дата:__________<o:p></o:p></span></p>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:0cm;text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt;color:black'>Ответственное лицо в <span
    style='mso-spacerun:yes'> </span>агентстве / департаменте<o:p></o:p></span></p>
    </td>
    <td width=477 nowrap valign=top style='width:357.55pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><b><span
    style='color:black'><o:p>&nbsp;</o:p></span></b></p>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify;tab-stops:
    224.75pt;mso-layout-grid-align:none;punctuation-wrap:simple;text-autospace:
    none'><b><span style='color:black'>________________/ <rw:field id="f_st" src="SIGN_TO" /><span
    style='mso-tab-count:1'>                                  </span>/ Дата:
    _____________<o:p></o:p></span></b></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><o:p></o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>
</rw:foreach>
</div>

</body>

</html>

</rw:report>

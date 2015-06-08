<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bso_act_discard" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="BSO_ACT_DISCARD" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_BSO_DOCUMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select
       rownum as nn,
       NUM_START,
       NUM_END,
	   QUANTITY,
	   SERIA,
	   BSO_TYPE,
	   BSO_STATUS
from (select 
	   rownum as nn,
	   bdc.num_start NUM_START, 
       nvl(bdc.num_end,bdc.num_start) NUM_END, 
       decode(bdc.num_end,null,1,to_number(bdc.num_end)-to_number(bdc.num_start)+1) as QUANTITY, 
       bs.series_name as SERIA, 
       bt.name BSO_TYPE,
	   bht.name BSO_STATUS
	from ven_bso_doc_cont bdc, -- Содержимое док. БСО (BSO_ID, N_START,N_END, BSO_SERIES_ID)
         ven_bso_type bt,      -- Вид БСО (NAME = 'Квитанция №13','Полис Осаго')
	     ven_bso_series bs,     -- Серия БСО (SERIES_NAME, BSO_TYPE_ID)
    	 ven_bso_hist_type bht -- Вид состояния БСО
	where bs.bso_type_id = bt.bso_type_id
      and bdc.bso_series_id = bs.bso_series_id
	  and bht.bso_hist_type_id = bdc.bso_hist_type_id
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
<link rel=File-List href="bso_act_discard.files/filelist.xml">
<title>АКТ ПРИЕМА-ПЕРЕДАЧИ  БЛАНКОВ СТРОГОЙ ОТЧЕТНОСТИ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>8</o:TotalTime>
  <o:Created>2007-03-01T14:55:00Z</o:Created>
  <o:LastSaved>2007-03-01T14:55:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>91</o:Words>
  <o:Characters>522</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>4</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>612</o:CharactersWithSpaces>
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
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
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
	{size:595.3pt 841.9pt;
	margin:22.95pt 42.55pt 53.85pt 2.0cm;
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

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><span style='mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoBodyText style='margin-left:279.0pt'><b>УТВЕРЖДЕНО<o:p></o:p></b></p>

<p class=MsoBodyText style='margin-left:279.0pt'>Управляющий директор </p>

<p class=MsoBodyText style='margin-left:279.0pt'>ООО «СК «Ренессанс Жизнь»</p>

<p class=MsoBodyText style='margin-left:279.0pt'>________________________</p>

<p class=MsoBodyText style='margin-left:279.0pt'>Киселев О.М.</p>

<p class=MsoBodyText style='margin-left:279.0pt'>«_____»________________2007г.</p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'>Акт<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><span
style='mso-spacerun:yes'> </span>списания бланков строгой отчетности<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'>&nbsp;</span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;mso-bidi-font-size:
10.0pt'><o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'>Производится списание<span
style='mso-spacerun:yes'>  </span>следующих<span style='mso-spacerun:yes'> 
</span>бланков<span style='mso-spacerun:yes'>  </span>строгой отчетности:<span
style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'>&nbsp;<span style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'>&nbsp;<span style='mso-bidi-font-size:
10.0pt'><o:p></o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=664
 style='width:498.0pt;margin-left:-5.25pt;border-collapse:collapse;mso-padding-alt:
 0cm 0cm 0cm 0cm'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:32.25pt'>
  <td width=39 rowspan=2 valign=top style='width:29.55pt;border:solid windowtext 1.0pt;
  border-bottom:solid black 1.0pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>№</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=241 rowspan=2 valign=top style='width:180.45pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Вид бланка<o:p></o:p></b></p>
  </td>
  <td width=80 rowspan=2 valign=top style='width:60.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'>Кол-во, <span
  class=SpellE><span class=GramE>шт</span></span><o:p></o:p></span></b></p>
  </td>
  <td width=136 colspan=2 valign=top style='width:102.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Нумерация </b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=168 rowspan=2 valign=top style='width:126.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Причина списания</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:32.25pt'>
  <td width=64 valign=top style='width:48.0pt;border-top:none;border-left:none;
  border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>с<o:p></o:p></b></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>по<o:p></o:p></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_nn" src="G_nn">
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:18.4pt'>
  <td width=39 valign=top style='width:29.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><rw:field id="f_nn" src="nn" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=241 valign=top style='width:180.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_BSO_TYPE" src="BSO_TYPE" /><o:p></o:p></span></p>
  </td>
  <td width=80 valign=top style='width:60.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_QUANTITY" src="QUANTITY" /><o:p></o:p></span></p>
  </td>
  <td width=64 valign=top style='width:48.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_start" src="NUM_START" />&nbsp;</span><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_end" src="NUM_END" /><o:p></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_BSO_STATUS" src="BSO_STATUS" />&nbsp;</span><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='mso-bidi-font-size:
10.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'>&nbsp;<span style='mso-bidi-font-size:
10.0pt'><o:p></o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=643
 style='width:482.4pt;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
  text-autospace:none'><b><span style='color:black'>Подпись сотрудника
  бухгалтерии:</span></b></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:207.0pt;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'>________________ /<span
  style='mso-tab-count:1'>                                   </span>/<span
  style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата:<span
  style='mso-spacerun:yes'>     </span><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Начальник
  Административного управления:<o:p></o:p></span></b></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:207.0pt;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'>________________ /<span
  style='mso-tab-count:1'>                                   </span>/<span
  style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата:<span
  style='mso-spacerun:yes'>     </span><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Начальник
  Операционного Управления:<o:p></o:p></span></b></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:207.0pt;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'>________________ /<span
  style='mso-tab-count:1'>                                   </span>/<span
  style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата:<span
  style='mso-spacerun:yes'>     </span><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Операционный
  Директор:<o:p></o:p></span></b></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes'>
  <td width=487 valign=top style='width:365.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:207.0pt;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'>________________ /<span
  style='mso-tab-count:1'>                                   </span>/<span
  style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата:<span
  style='mso-spacerun:yes'>     </span><o:p></o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>

</div>

</body>

</html>

</rw:report>

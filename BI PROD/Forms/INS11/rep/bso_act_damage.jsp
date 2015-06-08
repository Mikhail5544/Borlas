<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bso_act_damage" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="BSO_ACT_DAMAGE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_BSO_DOCUMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select  
    rownum,
    ent.obj_name('DEPARTMENT',da.department_id) as AGENCY,      -- Название агентства/департамента
	ent.obj_name ('CONTACT', bd.contact_from_id)  as AGENT_NAME,
    pkg_contact.get_fio_fmt(ent.obj_name ('CONTACT', bd.contact_to_id),4) as SIGN_TO,
	pkg_contact.get_fio_fmt(ent.obj_name ('CONTACT', bd.contact_from_id),4) as SIGN_FROM,
	(select ci.id_value 
	 from ven_cn_contact_ident ci, -- Идентификаторы контакта
	      ven_t_id_type t          -- Cловарь идентификаторов
	 where ci.contact_id  = bd.contact_from_id
	   and t.id  = ci.id_type and t.brief  = 'KOD') as AGENT_ID
 from    
  	ven_bso_document bd,  -- Документ БСО (CONTACT TO|to, DEPARTMENT TO|to)
  	ven_doc_templ dt,      -- Шаблон документа (BRIEF = 'ПередачаБСО','ВыдачаБСО')
	VEN_DEPT_AGENT DA
 where bd.bso_document_id = :P_BSO_DOCUMENT_ID --12853691249 --
    and bd.doc_templ_id = dt.doc_templ_id
	and da.agent_id = bd.contact_from_id
    and rownum = 1 ]]>
      </select>
      <group name="G_MAIN"><dataItem name="rownum"/></group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[ select
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
	     ven_bso_series bs,     -- Серия БСО (SERIES_NAME, BSO_TYPE_ID)
    	 ven_bso_hist_type bht -- Вид состояния БСО
	where bs.bso_type_id = bt.bso_type_id
      and bdc.bso_series_id = bs.bso_series_id
	  and bht.bso_hist_type_id = bdc.bso_hist_type_id
	  and bht.brief = 'Испорчен'
	  and bdc.bso_document_id = :P_BSO_DOCUMENT_ID
	order by bdc.num_start)l]]>
      </select>
      <group name="G_nn"><dataItem name="nn"/></group>
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
<title>Заявление</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>7</o:TotalTime>
  <o:Created>2007-03-15T09:13:00Z</o:Created>
  <o:LastSaved>2007-03-15T09:13:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>49</o:Words>
  <o:Characters>281</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>2</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>329</o:CharactersWithSpaces>
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
	{font-family:"Times New Roman CYR";
	panose-1:2 2 6 3 5 4 5 2 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:536902279 -2147483648 8 0 511 0;}
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
p.MsoToc1, li.MsoToc1, div.MsoToc1
	{mso-style-update:auto;
	mso-style-noshow:yes;
	mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
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
	margin:2.0cm 42.5pt 2.0cm 3.0cm;
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
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
<rw:foreach id="rg_main" src="G_MAIN">
<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt;font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'>Заявление</span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;mso-bidi-font-size:
10.0pt;font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt;font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><span
style='mso-spacerun:yes'> </span>о порче бланков строгой отчетности</span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;mso-bidi-font-size:
10.0pt;font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=454
 style='width:12.0cm;margin-left:-.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1 style='margin-top:6.0pt'><i><span style='font-size:12.0pt;font-family:
  "Times New Roman CYR";mso-bidi-font-family:Arial;mso-font-kerning:0pt;
  font-weight:normal;mso-bidi-font-weight:bold'>Агентство:</span></i><i><span
  style='font-size:12.0pt;mso-bidi-font-size:16.0pt;font-weight:normal'><o:p></o:p></span></i></h1>
  </td>
  <td width=296 style='width:222.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoToc1><span style='mso-ansi-language:RU'><rw:field id="f_AGENCY" src="AGENCY" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1 style='margin-top:6.0pt'><i><span style='font-size:12.0pt;font-family:
  "Times New Roman CYR";mso-bidi-font-family:Arial;mso-font-kerning:0pt;
  font-weight:normal;mso-bidi-font-weight:bold'>Заявитель:<o:p></o:p></span></i></h1>
  </td>
  <td width=296 style='width:222.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><rw:field id="f_AGENT_NAME" src="AGENT_NAME" /></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>
  <td width=144 valign=top style='width:108.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1 style='margin-top:6.0pt'><i><span style='font-size:12.0pt;font-family:
  "Times New Roman CYR";mso-bidi-font-family:Arial;mso-font-kerning:0pt;
  font-weight:normal;mso-bidi-font-weight:bold'>ID:<o:p></o:p></span></i></h1>
  </td>
  <td width=296 style='width:222.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><rw:field id="f_ag_id" src="AGENT_ID" /></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman"'>Мною были испорчены следующие бланки
строгой отчетности:</span><span style='mso-bidi-font-size:10.0pt;font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=664
 style='width:498.0pt;margin-left:-5.25pt;border-collapse:collapse;mso-padding-alt:
 0cm 0cm 0cm 0cm'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:19.9pt'>
  <td width=39 rowspan=2 valign=top style='width:29.55pt;border:solid windowtext 1.0pt;
  border-bottom:solid black 1.0pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:19.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>№</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=345 rowspan=2 valign=top style='width:258.45pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:19.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Вид бланка</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=104 rowspan=2 valign=top style='width:78.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:19.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Кол-во, <span
  class=SpellE><span class=GramE>шт</span></span></b><b><span style='mso-fareast-font-family:
  "Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=176 colspan=2 valign=top style='width:132.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 0cm 0cm 0cm;height:19.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Нумерация</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:12.6pt'>
  <td width=88 valign=top style='width:66.0pt;border-top:none;border-left:none;
  border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:0cm 0cm 0cm 0cm;height:12.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>с<o:p></o:p></b></p>
  </td>
  <td width=88 valign=top style='width:66.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>по</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_nn" src="G_nn">
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:11.95pt'>
  <td width=39 valign=top style='width:29.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:11.95pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><rw:field id="f_nn" src="nn" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=345 valign=top style='width:258.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:11.95pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_BSO_TYPE" src="BSO_TYPE" /><o:p></o:p></span></p>
  </td>
  <td width=104 valign=top style='width:78.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:11.95pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_QUANTITY" src="QUANTITY" /><o:p></o:p></span></p>
  </td>
  <td width=88 valign=top style='width:66.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:11.95pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_NUM_START" src="NUM_START" /><o:p></o:p></span></p>
  </td>
  <td width=88 valign=top style='width:66.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:11.95pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_NUM_END" src="NUM_END" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=648
 style='width:486.0pt;margin-left:-3.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=648 valign=top style='width:486.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=643
   style='width:17.0cm;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=476 valign=top style='width:357.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Заявитель:<o:p></o:p></span></b></p>
    </td>
    <td width=163 valign=top style='width:122.15pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1'>
    <td width=476 valign=top style='width:357.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='tab-stops:223.2pt;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'>___<span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'>_____________
    / <rw:field id="f_s_f" src="SIGN_FROM" /><span style='mso-tab-count:1'>                                 </span>/</span><span
    style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=163 valign=top style='width:122.15pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Дата<span
    class=GramE> :</span></span></b><b><span lang=EN-US style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black;
    mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2'>
    <td width=476 valign=top style='width:357.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Ответственное
    лицо в агентстве:<o:p></o:p></span></b></p>
    </td>
    <td width=163 valign=top style='width:122.15pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
    <td width=476 valign=top style='width:357.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='tab-stops:223.2pt;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'>___<span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'>_____________
    / <rw:field id="f_s_t" src="SIGN_TO" /></span><span lang=EN-US style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";mso-ansi-language:EN-US'><span
    style='mso-tab-count:1'>                                 </span></span><span
    style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'>/</span><span
    style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=163 valign=top style='width:122.15pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Дата<span
    class=GramE> :</span></span></b><b><span lang=EN-US style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black;
    mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal><o:p></o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>
</rw:foreach>
</div>

</body>

</html>

</rw:report>

<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report" > 

<rw:objects id="objects">

<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="underwriting_resolution" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="UNDERWRITING_RESOLUTION" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_TYPE_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select canParse="no">
      <![CDATA[-- Полис \ Застрахованный   
SELECT 
    rownum as n1,
    ent.obj_name('P_POLICY',p.policy_id) as pol_num,
    p.notice_num as notice_num,
    to_char(p.notice_date,'dd.mm.yyyy') as notice_date,
    ent.obj_name ('T_PAYMENT_TERMS',p.payment_term_id) as credit,
    ent.obj_name ('T_PROVINCE', p.region_id) as region,
    ent.obj_name ('T_PERIOD',p.period_id) as period,
	ent.obj_name ('CONTACT', a.assured_contact_id ) as assured, 
	to_char(pkg_contact.get_birth_date(a.assured_contact_id),'dd.mm.yyyy') as birth_date,
	TRUNC(MONTHS_BETWEEN(SYSDATE,pkg_contact.get_birth_date(a.assured_contact_id))/12) as age, 
    ent.obj_name('T_GENDER', pkg_contact.get_sex_id(a.assured_contact_id)) as sex,
    nvl(ent.obj_name('T_SMOKE',a.smoke_id),'Не курящий') as smoke,
	a.WEIGHT, 
	a.HEIGHT,
	round(a.WEIGHT*10000/(a.HEIGHT*a.HEIGHT)) as BMI, 
	ent.obj_name('T_PROFESSION',a.t_profession_id) as profession,
    nvl((select met.name
      from ven_ASSURED_MEDICAL_EXAM ame,
    	   ven_medical_exam_status  mes,
    	   MEDICAL_EXAM_TYPE        met
     where  mes.medical_exam_status_id = ame.medical_exam_status_id
       and met.medical_exam_type_id = ame.medical_exam_type_id
       and ame.as_assured_id = aa.as_asset_id
	   and rownum = 1),' ') as med,
    nvl((select ame.UNDERWRITING_NOTE  from ven_ASSURED_MEDICAL_EXAM ame where ame.as_assured_id = aa.as_asset_id and rownum = 1),' ') as UNDERWRITING_NOTE
FROM ven_p_policy p,
     ven_as_asset aa,
	 ven_as_assured a
WHERE p.POLICY_ID = :P_POLICY_ID  --pkg_policy.get_curr_policy(:P_POL_HEADER_ID)
  and aa.p_policy_id = p.policy_id
  and a.as_assured_id = aa.as_asset_id]]>
      </select>
      <group name="G_MAIN"><dataItem name="N1"/></group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[-- Программы (риски)
   
   
    SELECT   rownum as n2,
             decode(plt.brief,'RECOMMENDED',pl.description,'') as  prog_name_main,
		   decode(plt.brief,'OPTIONAL',pl.description,'') as prog_name_dop,
		   pl.description as prog_name,
           ROUND (MONTHS_BETWEEN (pc.end_date, pc.start_date) / 12) as years,
           pkg_rep_utils.to_money(pc.ins_amount) as ins_amount, 
	       pkg_rep_utils.to_money(pc.s_coef_m) as ms, 
		   pkg_rep_utils.to_money(pc.k_coef_m) as mk,
		pkg_rep_utils.to_money(pc.s_coef_nm) as nms, 
		   pkg_rep_utils.to_money(pc.k_coef_nm) as nmk

    FROM ven_as_asset a,
	     ven_p_cover pc,
         ven_t_prod_line_option plo,
         ven_t_product_line pl,
         ven_t_product_line_type plt
   WHERE a.p_policy_id = :P_POLICY_ID --pkg_policy.get_curr_policy(:P_POL_HEADER_ID)
     AND pc.as_asset_id = a.as_asset_id
     AND pc.t_prod_line_option_id = plo.ID
     AND plo.product_line_id = pl.ID
     AND pl.product_line_type_id = plt.product_line_type_id
 ORDER BY plt.brief DESC]]>
      </select>
      <group name="G_N"><dataItem name="n2"/></group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>ЗАКЛЮЧЕНИЕ ПО АНДЕРРАЙТИНГУ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>archy</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>72</o:TotalTime>
  <o:LastPrinted>2007-06-14T10:00:00Z</o:LastPrinted>
  <o:Created>2007-06-14T12:27:00Z</o:Created>
  <o:LastSaved>2007-06-14T12:27:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>193</o:Words>
  <o:Characters>1106</o:Characters>
  <o:Lines>9</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1297</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
   <w:UseWord2002TableStyleRules/>
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
	margin:14.2pt 42.55pt 26.95pt 72.0pt;
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
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
<rw:foreach id="rg_main" src="G_main">
<rw:getValue id="flag_type" src="P_TYPE_ID"/>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><% if (flag_type.equals("1")) { %>ЗАКЛЮЧЕНИЕ ПО АНДЕРРАЙТИНГУ<% } else { %>ЗАПРОС ДЛЯ ПЕРЕСТРАХОВЩИКОВ<% } %><o:p></o:p></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=720
 style='width:540.0pt;margin-left:-30.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:15.25pt'>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.25pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Застрахованный</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=276 valign=top style='width:207.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.25pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_assured" src="assured" /><o:p></o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.25pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Заявление</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.25pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_notice_num" src="notice_num" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:17.15pt'>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Дата рождения</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=276 valign=top style='width:207.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_birth_date" src="birth_date" /><o:p></o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Дата заявления</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_notice_date" src="notice_date" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:17.7pt'>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.7pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Возраст (полн. лет):<o:p></o:p></span></b></p>
  </td>
  <td width=276 valign=top style='width:207.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.7pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_age" src="age" /><o:p></o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.7pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Город (Регион)</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.7pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_region" src="region" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:17.45pt'>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.45pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Пол</span></b><b style='mso-bidi-font-weight:normal'><span
  lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=276 valign=top style='width:207.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.45pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_sex" src="sex" /><o:p></o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.45pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Мед. </span></b><span class=GramE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>o</span></b></span><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>бследование</span></b></span><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.45pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_med" src="med" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes;height:16.15pt'>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>Профессия:<o:p></o:p></span></b></p>
  </td>
  <td width=276 valign=top style='width:207.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_profession" src="profession" /><o:p></o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:99.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>№ договора / полиса</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:9.0pt;mso-ansi-language:EN-US'>:<o:p></o:p></span></b></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_pol_num" src="pol_num" /><o:p></o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=709
 style='width:531.9pt;margin-left:-30.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:21.45pt'>
  <td width=240 style='width:180.0pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.45pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Основная
  программа<o:p></o:p></span></b></p>
  </td>
  <td width=252 style='width:189.0pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.45pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Дополнительные
  программы<o:p></o:p></span></b></p>
  </td>
  <td width=98 style='width:73.85pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.45pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Срок
  страхования<o:p></o:p></span></b></p>
  </td>
  <td width=119 style='width:89.05pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.45pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Периодичность
  уплаты<o:p></o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_n" src="G_N">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:48.25pt'>
  <td width=240 valign=top style='width:180.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:48.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><rw:field id="f_prog_name_main" src="prog_name_main" /><o:p></o:p></span></p>
  </td>
  <td width=252 valign=top style='width:189.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:48.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><rw:field id="f_prog_name_dop" src="prog_name_dop" /><o:p></o:p></span></p>
  </td>
  <td width=98 valign=top style='width:73.85pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:48.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><rw:field id="f_years" src="years" /><o:p></o:p></span></p>
  </td>
  <td width=119 valign=top style='width:89.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:48.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><rw:field id="f_credit" src="credit" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt'>Дополнительная информация:<o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=709
 style='width:531.8pt;margin-left:-30.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:44.8pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:44.8pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Мед<span
  class=GramE>.</span> <span class=GramE>а</span>нкета:<o:p></o:p></span></b></p>
  </td>
  <td width=581 colspan=4 valign=top style='width:435.95pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:44.8pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:21.7pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Семейный
  анамнез:<o:p></o:p></span></b></p>
  </td>
  <td width=581 colspan=4 style='width:435.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=EN-US
  style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:22.35pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>История
  семьи:<o:p></o:p></span></b></p>
  </td>
  <td width=581 colspan=4 style='width:435.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:22.1pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Ве<span
  class=GramE>с(</span>кг):<o:p></o:p></span></b></p>
  </td>
  <td width=76 style='width:57.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Рос<span
  class=GramE>т(</span>см):<o:p></o:p></span></b></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>BMI<o:p></o:p></span></b></p>
  </td>
  <td width=283 style='width:212.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Употребление
  алкоголя.<o:p></o:p></span></b></p>
  </td>
  <td width=150 style='width:112.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:22.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Курение.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:21.7pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><rw:field id="f_WEIGHT" src="WEIGHT" /><o:p></o:p></span></b></p>
  </td>
  <td width=76 style='width:57.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><rw:field id="f_HEIGHT" src="HEIGHT" /><o:p></o:p></span></b></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><rw:field id="f_BMI" src="BMI" formatMask="999999990"/><o:p></o:p></span></b></p>
  </td>
  <td width=283 style='width:212.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=150 style='width:112.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.7pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_smoke" src="smoke" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:21.6pt'>
  <td width=128 style='width:95.85pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Особые
  риски:<o:p></o:p></span></b></p>
  </td>
  <td width=581 colspan=4 style='width:435.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.6pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<rw:getValue id="flag_med" src="med"/>
<% if (!flag_med.equals(" ")) { %> 

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt'>Медицинское обследование:</span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;margin-left:-30.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:32.25pt'>
  <td width=118 style='width:88.8pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Результаты
  обследования<o:p></o:p></span></b></p>
  </td>
  <td width=590 colspan=7 style='width:442.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:6.4pt'>
  <td width=118 style='width:88.8pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=590 colspan=7 style='width:442.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:12.0pt'>
  <td width=118 rowspan=2 style='width:88.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Ве<span
  class=GramE>с(</span>кг):<o:p></o:p></span></b></p>
  </td>
  <td width=64 rowspan=2 style='width:48.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Рос<span
  class=GramE>т(</span>см):<o:p></o:p></span></b></p>
  </td>
  <td width=70 rowspan=2 style='width:52.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>BMI</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=325 colspan=3 style='width:243.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>АД (</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'>мм <span class=SpellE>рт.ст</span>.</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'>)</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=71 rowspan=2 style='width:53.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Пульс (уд<span
  class=GramE>.</span> <span class=GramE>м</span>ин)<o:p></o:p></span></b></p>
  </td>
  <td width=59 rowspan=2 style='width:44.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Тест ВИЧ<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:15.75pt'>
  <td width=95 style='width:71.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>1-е <span
  class=SpellE>изм</span>.<o:p></o:p></span></b></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>2-е <span
  class=SpellE>изм</span>.<o:p></o:p></span></b></p>
  </td>
  <td width=116 style='width:86.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>3-е <span
  class=SpellE>изм</span>.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:18.0pt'>
  <td width=118 style='width:88.8pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=64 style='width:48.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=70 style='width:52.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=95 style='width:71.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=116 style='width:86.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=71 style='width:53.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
  <td width=59 style='width:44.3pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:9.0pt;
  mso-ansi-language:EN-US'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:17.25pt'>
  <td width=118 style='width:88.8pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:17.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>ЭКГ<o:p></o:p></span></b></p>
  </td>
  <td width=590 colspan=7 valign=top style='width:442.2pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:17.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:17.25pt'>
  <td width=118 valign=top style='width:88.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:17.25pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=590 colspan=7 valign=top style='width:442.2pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:17.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:8.25pt'>
  <td width=118 rowspan=2 style='width:88.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Лабораторные
  исследования<o:p></o:p></span></b></p>
  </td>
  <td width=64 style='width:48.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Моча<o:p></o:p></span></b></p>
  </td>
  <td width=525 colspan=6 valign=top style='width:393.85pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;mso-yfti-lastrow:yes;height:34.5pt'>
  <td width=64 style='width:48.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:34.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Кровь<o:p></o:p></span></b></p>
  </td>
  <td width=525 colspan=6 valign=top style='width:393.85pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:34.5pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;margin-left:-30.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:18.0pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Дополнительно:<o:p></o:p></span></b></p>
  </td>
  <td width=588 valign=top style='width:441.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.0pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='text-align:justify;tab-stops:486.0pt'><b
style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Заключение: </span></b><b
style='mso-bidi-font-weight:normal'><u><span lang=EN-US style='font-size:9.0pt;
mso-ansi-language:EN-US'><rw:field id="f_sUNDERWRITING_NOTE" src="UNDERWRITING_NOTE"/></span></u></b><b style='mso-bidi-font-weight:normal'><u><span
style='font-size:9.0pt'><span style='mso-tab-count:1'>                                                                                                                                                                                         </span><o:p></o:p></span></u></b></p>
<% } %>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;margin-left:-30.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:21.75pt'>
  <td width=228 rowspan=2 style='width:171.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Риски<o:p></o:p></span></b></p>
  </td>
  <td width=96 rowspan=2 style='width:72.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Страховая
  сумма<o:p></o:p></span></b></p>
  </td>
  <td width=192 colspan=2 style='width:144.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Медицинский<o:p></o:p></span></b></p>
  </td>
  <td width=192 colspan=2 style='width:144.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>Не
  медицинский<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:18.05pt'>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>(К<span
  class=GramE>,%)</span><o:p></o:p></span></b></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>(S,‰)<o:p></o:p></span></b></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>(К<span
  class=GramE>,%)</span><o:p></o:p></span></b></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt'>(S,‰)<o:p></o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_n1" src="G_N">
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:3.5pt'>
  <td width=228 valign=top style='width:171.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:10.0pt;mso-ansi-language:EN-US'><rw:field id="f_prog_name" src="prog_name" /><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_ins_amount" src="ins_amount" /><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_mk" src="mk" /><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_ms" src="ms" /><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'><rw:field id="f_nmk" src="nmk" /><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:9.0pt;mso-ansi-language:EN-US'></span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  mso-ansi-language:EN-US'><rw:field id="f_nms" src="nms" /><o:p></o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>
</table>
<% if (flag_type.equals("1")) { %>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=718
 style='width:19.0cm;margin-left:-30.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:22.25pt'>
  <td width=168 valign=top style='width:126.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:22.25pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'>Подпись:</span></b><span lang=EN-US
  style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:22.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=264 valign=top style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:22.25pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:25.4pt'>
  <td width=168 style='width:126.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'>Р.Гущин</span></b><span lang=EN-US style='mso-ansi-language:
  EN-US'><o:p></o:p></span></p>
  </td>
  <td width=228 style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.4pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'>_____________________<o:p></o:p></span></p>
  </td>
  <td width=264 style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'>________/______/_________</span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:27.2pt'>
  <td width=168 style='width:126.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'>О. Киселев</span></b><span lang=EN-US
  style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=228 style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'>_____________________<o:p></o:p></span></p>
  </td>
  <td width=264 style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'>________/______/_________</span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:27.2pt'>
  <td width=168 style='width:126.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:11.0pt;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:11.0pt;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:11.0pt;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=228 style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=264 style='width:198.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:27.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:27.2pt'>
  <td width=660 colspan=3 style='width:495.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.2pt'>
  <p class=MsoNormal><span style='font-size:11.0pt'>В случае<span class=GramE>,</span>
  если клиент не согласен с предложенным по результатам андеррайтинга вариантом
  (перерасчет с уменьшением страховых сумм и сохранением страхового взноса),
  расчет<span style='mso-spacerun:yes'>  </span>варианта с сохранением
  страховых сумм и увеличением взноса производится сотрудником ОУ. <b
  style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
 </tr>

</table>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<% } %>
</rw:foreach>
</div>

</body>

</html>

</rw:report>

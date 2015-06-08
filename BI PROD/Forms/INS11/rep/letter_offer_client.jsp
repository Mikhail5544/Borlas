<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251"  %>
<%@ page import="java.text.*" %>

<%
  double i = 0;
%>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="Letter_Offer_Client" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="LETTER_OFFER_CLIENT" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_NOTICE_NUM" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_NOTICE_SER" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_NOTICE_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_HOLDER" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_UNDR_1" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_UNDR_2" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_SUM_FEE_1" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_SUM_FEE_2" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_SIGNER_NAME" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_POSITION_NAME" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_REC_1">
      <select canParse="no">
      <![CDATA[
select 1 dop_field_1,
	  'Основная программа: '||plo.description recom_risk_1,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_1,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_1
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'RECOMMENDED'
 and pp.policy_id = (select p.policy_id
                     from p_policy pol, p_pol_header ph, p_policy p
                     where pol.policy_id = :P_POLICY_ID
                           and pol.pol_header_id = ph.policy_header_id
                           and p.pol_header_id = ph.policy_header_id
                           and p.version_num = 1)
]]>
      </select>
      <displayInfo x="0.75012" y="0.23938" width="0.69995" height="0.19995"/>
      <group name="G_REC_1">
        <dataItem name="dop_field_1"/>
      </group>
    </dataSource>
    <dataSource name="Q_OPT_1">
      <select>
      <![CDATA[
select 1 dop_field_2,
	   plo.description opt_risk_1,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_opt_1,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_opt_1
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief <> 'RECOMMENDED'
 and pp.policy_id = (select p.policy_id
                     from p_policy pol, p_pol_header ph, p_policy p
                     where pol.policy_id = :P_POLICY_ID
                           and pol.pol_header_id = ph.policy_header_id
                           and p.pol_header_id = ph.policy_header_id
                           and p.version_num = 1)
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
]]>
      </select>
      <displayInfo x="4.19812" y="0.19788" width="0.69995" height="0.19995"/>
      <group name="G_OPT_1">
        <dataItem name="dop_field_2"/>
      </group>
    </dataSource>
    <dataSource name="Q_REC_2">
      <select canParse="no">
      <![CDATA[
select 1 dop_field_3,
	   'Основная программа: '||plo.description recom_risk_2,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_2,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_2
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'RECOMMENDED'
 and pp.policy_id = :P_POLICY_ID
]]>
      </select>
      <displayInfo x="1.92712" y="4.01038" width="0.69995" height="0.19995"/>
      <group name="G_REC_2">
        <dataItem name="dop_field_3"/>
      </group>
    </dataSource>
<dataSource name="Q_ADM_1">
      <select canParse="no">
      <![CDATA[
select 1 dop_field_5,
	   plo.description adm_risk_1,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_adm_1,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_adm_1
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief <> 'RECOMMENDED'
 and pp.policy_id = (select p.policy_id
                     from p_policy pol, p_pol_header ph, p_policy p
                     where pol.policy_id = :P_POLICY_ID
                           and pol.pol_header_id = ph.policy_header_id
                           and p.pol_header_id = ph.policy_header_id
                           and p.version_num = 1)
 and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
]]>
      </select>
      <displayInfo x="2.29163" y="0.19788" width="0.97070" height="0.19995"/>
      <group name="G_ADM_1">
        <dataItem name="dop_field_5"/>
      </group>
   </dataSource>	
<dataSource name="Q_OPT_2">
      <select canParse="no">
      <![CDATA[
select 1 dop_field_4,
	   plo.description opt_risk_2,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_opt_2,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_opt_2
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief <> 'RECOMMENDED'
 and pp.policy_id = :P_POLICY_ID
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
]]>
      </select>
      <displayInfo x="2.29163" y="0.19788" width="0.97070" height="0.19995"/>
      <group name="G_OPT_2">
        <dataItem name="dop_field_4"/>
      </group>
   </dataSource>
<dataSource name="Q_ADM_2">
      <select canParse="no">
      <![CDATA[
select 1 dop_field_6,
	   plo.description adm_risk_2,
       trim(to_char(pc.ins_amount,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_amount_adm_2,
	   trim(to_char(pc.fee,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')) ins_premium_adm_2
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief <> 'RECOMMENDED'
 and pp.policy_id = :P_POLICY_ID
 and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
]]>
      </select>
      <displayInfo x="2.29163" y="0.19788" width="0.97070" height="0.19995"/>
      <group name="G_ADM_2">
        <dataItem name="dop_field_6"/>
      </group>
   </dataSource>	
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

begin
select pp.notice_num,
	   pp.notice_ser,
       to_char(pp.notice_date,'dd.mm.yyyy') notice_date,
       cpol.obj_name_orig
into :P_NOTICE_NUM, :P_NOTICE_SER, :P_NOTICE_DATE, :P_HOLDER
from p_policy pp,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol
where 1=1
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      
      and pp.policy_id = :P_POLICY_ID;
exception
      when no_data_found then :P_NOTICE_NUM := ''; :P_NOTICE_SER := ''; :P_NOTICE_DATE := to_char(sysdate,'dd.mm.yyyy'); :P_HOLDER := '';
  end;

begin
SELECT pkg_contact.get_fio_fmt(s.contact_name,4) signer_name_o,
       jp.position_name position_name_o
INTO :P_SIGNER_NAME, :P_POSITION_NAME
  FROM ins.t_report_signer sg,
       ins.t_job_position jp,
         ins.t_signer s
  WHERE s.job_position_id = jp.t_job_position_id
    AND jp.dep_brief = 'ОПЕРУ'
    AND jp.is_enabled = 1
      AND s.t_signer_id = sg.t_signer_id
    AND sg.report_id = (SELECT r.rep_report_id
                        FROM ins.rep_report r
                        WHERE r.exe_name = 'ins11/letter_offer_client.jsp');
exception
      when no_data_found then :P_SIGNER_NAME := ''; :P_POSITION_NAME := '';
  end;
  
begin
select undr.addendum_note
into :P_UNDR_1
from ven_p_policy pp, 
     ven_as_asset ass,
     ven_as_assured assu,
     ins.ven_as_assured_underwr undr
where 1=1
 and ass.p_policy_id = pp.policy_id
 and ass.as_asset_id = assu.as_assured_id
 and undr.as_assured_id = assu.as_assured_id
 and pp.policy_id = (select p.policy_id
                     from p_policy pol, p_pol_header ph, p_policy p
                     where pol.policy_id = :P_POLICY_ID
                           and pol.pol_header_id = ph.policy_header_id
                           and p.pol_header_id = ph.policy_header_id
                           and p.version_num = 1);
exception
      when no_data_found then :P_UNDR_1 := '';
  end;						   
 
begin
select undr.addendum_note
into :P_UNDR_2
from ven_p_policy pp, 
     ven_as_asset ass,
     ven_as_assured assu,
     ins.ven_as_assured_underwr undr
where 1=1
 and ass.p_policy_id = pp.policy_id
 and ass.as_asset_id = assu.as_assured_id
 and undr.as_assured_id = assu.as_assured_id
 and pp.policy_id = :P_POLICY_ID;
exception
      when no_data_found then :P_UNDR_2 := '';
  end;

begin
select trim(to_char(sum(pc.fee),'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', '''))
into :P_SUM_FEE_2
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and pp.policy_id = :P_POLICY_ID;
 exception
      when no_data_found then :P_SUM_FEE_2 := '0,00';
  end;
  
begin
select trim(to_char(sum(pc.fee),'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', '''))
into :P_SUM_FEE_1
from ven_p_policy pp, 
     ven_as_asset ass, 
     ven_p_cover pc,

     ven_t_prod_line_option plo,
     ven_t_product_line pl,
     ven_t_product_line_type plt
where 1=1
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and pp.policy_id = (select p.policy_id
                     from p_policy pol, p_pol_header ph, p_policy p
                     where pol.policy_id = :P_POLICY_ID
                           and pol.pol_header_id = ph.policy_header_id
                           and p.pol_header_id = ph.policy_header_id
                           and p.version_num = 1);
 exception
      when no_data_found then :P_SUM_FEE_1 := '0,00';
  end;

  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="Med_confinement_files/filelist.xml">
<title>ПИСЬМО_ПРЕДЛОЖЕНИЕ</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="country-region"/>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="place"/>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="City"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>NGrek</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>148</o:TotalTime>
  <o:Created>2007-12-12T08:47:00Z</o:Created>
  <o:LastSaved>2007-12-12T11:33:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>201</o:Words>
  <o:Characters>1146</o:Characters>
  <o:Company>BelsoftBorlasGrup</o:Company>
  <o:Lines>9</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1345</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
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
</xml><![endif]--><!--[if !mso]><object
 classid="clsid:38481807-CA0E-42D2-BF39-B33AF135CC4D" id=ieooui></object>
<style>
st1\:*{behavior:url(#ieooui) }
</style>
<![endif]-->
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
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
h2
	{mso-style-next:Normal;
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-indent:36.0pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	mso-fareast-language:EN-US;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;
	font-weight:bold;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:31.2pt 31.2pt 31.2pt 62.35pt;
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
table.TableNormal1
	{mso-style-name:"Table Normal1";
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
table.TableGrid1
	{mso-style-name:"Table Grid1";
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

<p class=MsoBodyText style='text-align:right;margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image009.jpg" alt="Logo"></p>

<p class=MsoTitle><span lang=EN-US style='font-size:9.0pt;font-family:Times New Roman'><i>Уважаемый (ая) <rw:field id="" src="P_HOLDER"/>!</i></span></p>
<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US style='font-size:9.0pt;font-family:Times New Roman'>Благодарим Вас за выбор ООО "СК "Ренессанс Жизнь" в качестве Вашего Страховщика.</span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'>По итогам проведенной оценки страхового риска по Вашему 
Заявлению № <rw:field id="" src="P_NOTICE_SER"/> - <rw:field id="" src="P_NOTICE_NUM"/> от <rw:field id="" src="P_NOTICE_DATE"/> г., Страховщиком были получены дополнительные существенные сведения, 
влияющие на степень вероятности наступления страховых случаев по страховым рискам.</span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US style='font-size:8.0pt;font-family:Times New Roman'>В связи с 
изложенным и в соответствии с Полисными условиями ООО "СК "Ренессанс Жизнь" предлагает Вам новые 
условия страхования по  следующим вариантам:</span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US style='font-size:8.0pt;font-family:Times New Roman'><o:p></o:p></span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US style='font-size:8.0pt;font-family:Times New Roman'><b>I Вариант</b></span></p>

<table class=TableGrid1 border=0 cellspacing=0 cellpadding=0 width=691
 style='width:518.4pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховые риски / программы страхования</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховая сумма, руб.</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховая премия (страховой взнос), руб.</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Подпись Страхователя</span></p>
  </td>
 </tr>
 <rw:foreach id="G_REC_1" src="G_REC_1">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="RECOM_RISK_1"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_AMOUNT_1"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_1"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 <rw:foreach id="G_OPT_1" src="G_OPT_1">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="OPT_RISK_1"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_AMOUNT_OPT_1"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_OPT_1"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <rw:foreach id="G_ADM_1" src="G_ADM_1">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="ADM_RISK_1"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_ADM_1"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Итого:</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><b><rw:field id="" src="P_SUM_FEE_1"/></b></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'><rw:field id="" src="P_UNDR_2"/></span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US style='font-size:8.0pt;font-family:Times New Roman'><b>II Вариант</b></span></p>

<table class=TableGrid1 border=0 cellspacing=0 cellpadding=0 width=691
 style='width:518.4pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховые риски / программы страхования</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховая сумма, руб.</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Страховая премия (страховой взнос), руб.</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Подпись Страхователя</span></p>
  </td>
 </tr>
 <rw:foreach id="G_REC_2" src="G_REC_2">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="RECOM_RISK_2"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_AMOUNT_2"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_2"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 <rw:foreach id="G_OPT_2" src="G_OPT_2">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="OPT_RISK_2"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_AMOUNT_OPT_2"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_OPT_2"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 
  <rw:foreach id="G_ADM_2" src="G_ADM_2">
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><rw:field id="" src="ADM_RISK_2"></rw:field></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'></span></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Times New Roman;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><rw:field id="" src="INS_PREMIUM_ADM_2"></rw:field></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'>Итого:</span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'><b><rw:field id="" src="P_SUM_FEE_2"/></b></span></p>
  </td>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Times New Roman'></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'><rw:field id="" src="P_UNDR_2"/></span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'>В случае согласования Вами одного из 
предоставленных вариантов условий страхования, своё согласие подтвердите  подписью.</span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
font-family:Times New Roman;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='tab-stops:18.0pt'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'>Искренне надеемся на то, что Вы останетесь, довольны 
качеством страховых продуктов и нашим обслуживанием.</span></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
style='font-size:8.0pt;font-family:Times New Roman'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='font-size:8.0pt;
font-family:Times New Roman'>С уважением,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/podpis0003.jpg" alt="Голованов Андрей"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='font-size:8.0pt;
font-family:Times New Roman'><rw:field id="" src="P_POSITION_NAME"/></span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='font-size:8.0pt;
font-family:Times New Roman'><rw:field id="" src="P_SIGNER_NAME"/></span></i></b></p>

</div>

</body>

</html>

</rw:report>
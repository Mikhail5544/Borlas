<%@ include file="/inc/header_msword.jsp" %> 
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>
<rw:report id="report" > 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="Indexating_PrilV" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="Indexating_PrilV" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="POL_HEAD_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_1" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_2" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_3" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_4" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_5" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_6" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_7" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_8" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_9" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_10" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_11" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_12" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_13" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_13_1" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_13_2" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_13_3" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_14" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_15" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_16" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_17" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_18" datatype="character" width="500" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select max(pl.description) t1_1,
       to_char(sum(pc.INS_AMOUNT), 'FM999G999G990D09','NLS_NUMERIC_CHARACTERS = '', ''') t1_2,
       to_char(sum(pc.PREMIUM), 'FM999G999G990D09','NLS_NUMERIC_CHARACTERS = '', ''') t1_3
     from ven_p_pol_header ph,
          ven_p_policy pp,
          as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pp.pol_header_id = ph.policy_header_id
       and a.p_policy_id = pp.policy_id
       and pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
       and plt.presentation_desc = 'ДОП'
       and ph.policy_header_id = :POL_HEAD_ID
     group by pl.id
     order by decode(max(pl.description), 'Административные издержки',1, 0), max(pl.description);]]>
      </select>
      <displayInfo x="1.46875" y="0.95837" width="0.69995" height="0.19995"/>
      <group name="G_1">
        <displayInfo x="1.26880" y="1.65833" width="1.09998" height="0.77246"
        />
        <dataItem name="t1_1" datatype="vchar2" columnOrder="33" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 1">
          <dataDescriptor expression="max ( pl.description )"
           descriptiveExpression="T1_1" order="1" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t1_2" datatype="vchar2" columnOrder="34" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 2">
          <dataDescriptor
           expression="to_char ( sum ( pc.INS_AMOUNT ) , &apos;FM999G999G990D09&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T1_2" order="2" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t1_3" datatype="vchar2" columnOrder="35" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 3">
          <dataDescriptor
           expression="to_char ( sum ( pc.PREMIUM ) , &apos;FM999G999G990D09&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T1_3" order="3" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
	
select pp.num p2,
       to_char(ph.start_date,'dd.mm.yyyy') p3,
       '"'||to_char(sysdate,'dd')||'"'||substr(pkg_utils.date2genitive_case(sysdate),3) p4,
       PKG_CONTACT.GET_FIO_CASE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id), 'И') p5,
       PKG_CONTACT.GET_FIO_FMT(PKG_CONTACT.GET_FIO_CASE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id), 'И'),4) p6,
       nvl(PKG_CONTACT.GET_IDENT_NUMBER(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'),lpad('_',15,'_')) p7,
       nvl(PKG_CONTACT.GET_IDENT_PLACE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'),lpad('_',35,'_')) p8,
       nvl(to_char(PKG_CONTACT.GET_IDENT_DATE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'), 'dd.mm.yyyy'),lpad('_',10,'_')) p9,
       to_char(PKG_CONTACT.GET_BIRTH_DATE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id)), 'dd.mm.yyyy') p10,
       PKG_CONTACT.GET_FIO_CASE(C.CONTACT_ID, 'И') p11,
       to_char(PKG_CONTACT.GET_BIRTH_DATE(C.CONTACT_ID), 'dd.mm.yyyy') p12,
       nvl(PKG_CONTACT.GET_IDENT_NUMBER(C.CONTACT_ID,'PASS_RF'),lpad('_',15,'_')) p13_1,
       nvl(PKG_CONTACT.GET_IDENT_PLACE(C.CONTACT_ID,'PASS_RF'),lpad('_',35,'_')) p13_2,
       nvl(to_char(PKG_CONTACT.GET_IDENT_DATE(C.CONTACT_ID,'PASS_RF'), 'dd.mm.yyyy'),lpad('_',10,'_')) p13_3,
       'уплачивается ' || lower(PT.DESCRIPTION) p17
into :P_2, :P_3, :P_4, :P_5, :P_6, :P_7, :P_8, :P_9, :P_10, :P_11, :P_12, :P_13_1, :P_13_2, :P_13_3, :P_17
from ven_p_pol_header ph,
     ven_p_policy pp,
     VEN_T_PAYMENT_TERMS PT,
     (select max(nvl(assured_contact_id, contact_id)) contact_id, p_policy_id from ven_as_assured group by p_policy_id) t,
     ven_contact c
where pp.policy_id = ph.policy_id
  and PT.ID = pp.PAYMENT_TERM_ID
  and T.P_POLICY_ID(+) = pp.policy_id
  and C.CONTACT_ID(+) = T.CONTACT_ID
  and ph.policy_header_id = :POL_HEAD_ID;
  
select max(pl.description) pl_desc,
       to_char(sum(pc.INS_AMOUNT), 'FM999G999G990D09','NLS_NUMERIC_CHARACTERS = '', '''),
       to_char(sum(pc.PREMIUM), 'FM999G999G990D09','NLS_NUMERIC_CHARACTERS = '', ''')
     into :P_14, :P_15, :P_16
     from ven_p_pol_header ph,
          ven_p_policy pp,
          as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pp.pol_header_id = ph.policy_header_id
       and a.p_policy_id = pp.policy_id
       and pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
       and plt.presentation_desc = 'ОСН'
       and ph.policy_header_id = :POL_HEAD_ID;

select to_char(sum(pc.PREMIUM), 'FM999G999G990D09','NLS_NUMERIC_CHARACTERS = '', ''')
     into :P_18
     from ven_p_pol_header ph,
          ven_p_policy pp,
          as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl
     where pp.pol_header_id = ph.policy_header_id
       and a.p_policy_id = pp.policy_id
       and pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
       and ph.policy_header_id = :POL_HEAD_ID;

  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate versionFlags2="0" templateName="rwbeige"/>
  <reportWebSettings>
  <![CDATA[]]>
  </reportWebSettings>
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
<link rel=File-List href="<%=g_ImagesRoot%>/Pril_V.files/filelist.xml">
<link rel=Edit-Time-Data href="<%=g_ImagesRoot%>/Pril_V.files/editdata.mso">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title>Дополнительное соглашение по условиям индексации премии № </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>pavel.ikonopiscev</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>Novik</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>53</o:TotalTime>
  <o:LastPrinted>2008-12-30T09:56:00Z</o:LastPrinted>
  <o:Created>2009-01-26T22:39:00Z</o:Created>
  <o:LastSaved>2009-01-26T22:39:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>589</o:Words>
  <o:Characters>3363</o:Characters>
  <o:Lines>28</o:Lines>
  <o:Paragraphs>7</o:Paragraphs>
  <o:CharactersWithSpaces>3945</o:CharactersWithSpaces>
  <o:Version>11.5606</o:Version>
 </o:DocumentProperties>
 <o:OfficeDocumentSettings>
  <o:RelyOnVML/>
  <o:AllowPNG/>
 </o:OfficeDocumentSettings>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>108</w:Zoom>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:PunctuationKerning/>
  <w:DrawingGridHorizontalSpacing>6 пт</w:DrawingGridHorizontalSpacing>
  <w:DisplayHorizontalDrawingGridEvery>2</w:DisplayHorizontalDrawingGridEvery>
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
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:Calibri;
	mso-font-alt:"Century Gothic";
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073750139 0 0 159 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"Book Antiqua";
	panose-1:2 4 6 2 5 3 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"MS Sans Serif";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Cambria;
	mso-font-alt:"Palatino Linotype";
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073741899 0 0 159 0;}
@font-face
	{font-family:Garamond;
	panose-1:2 2 4 4 3 3 1 1 8 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:PragmaticaCTT;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:"Times New Roman";
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:auto;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Physics;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:"Times New Roman";
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:auto;
	mso-font-signature:0 0 0 0 0 0;}
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
	{mso-style-update:auto;
	mso-style-link:"Знак Знак13";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:18.0pt;
	text-indent:-18.0pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	mso-list:l1 level1 lfo2;
	tab-stops:list 36.0pt;
	font-size:16.0pt;
	font-family:Arial;
	mso-font-kerning:16.0pt;}
h2
	{mso-style-link:"Знак Знак12";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:55.8pt;
	text-indent:-21.6pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	mso-list:l1 level2 lfo2;
	tab-stops:list 72.9pt;
	font-size:14.0pt;
	font-family:Arial;
	font-style:italic;}
h3
	{mso-style-link:"Знак Знак11";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:13.0pt;
	font-family:Arial;}
h4
	{mso-style-link:"Знак Знак10";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:4;
	font-size:14.0pt;
	font-family:"Times New Roman";}
p.MsoToc1, li.MsoToc1, div.MsoToc1
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoToc2, li.MsoToc2, div.MsoToc2
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:12.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoToc3, li.MsoToc3, div.MsoToc3
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:24.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoNormalIndent, li.MsoNormalIndent, div.MsoNormalIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	tab-stops:list 60.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;}
p.MsoFootnoteText, li.MsoFootnoteText, div.MsoFootnoteText
	{mso-style-noshow:yes;
	mso-style-link:"Знак Знак3";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;}
p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
	{mso-style-noshow:yes;
	mso-style-link:"Знак Знак2";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{mso-style-noshow:yes;
	mso-style-link:"Знак Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{mso-style-link:"Знак Знак4";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoCaption, li.MsoCaption, div.MsoCaption
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoListNumber, li.MsoListNumber, div.MsoListNumber
	{margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:-18.0pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 36.0pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	text-transform:uppercase;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-link:"Знак Знак6";
	margin-top:70.85pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{mso-style-link:"Знак Знак5";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{mso-style-link:"Знак Знак8";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 78.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;}
a:link, span.MsoHyperlink
	{color:#993300;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;
	text-underline:single;}
p.MsoDocumentMap, li.MsoDocumentMap, div.MsoDocumentMap
	{mso-style-noshow:yes;
	mso-style-link:"Знак Знак9";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	background:navy;
	font-size:10.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.MsoCommentSubject, li.MsoCommentSubject, div.MsoCommentSubject
	{mso-style-noshow:yes;
	mso-style-parent:"Текст примечания";
	mso-style-link:"Знак Знак1";
	mso-style-next:"Текст примечания";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	mso-style-link:"Знак Знак7";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
span.13
	{mso-style-name:"Знак Знак13";
	mso-ansi-font-size:16.0pt;
	mso-bidi-font-size:16.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-font-kerning:16.0pt;
	font-weight:bold;}
span.12
	{mso-style-name:"Знак Знак12";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 2";
	mso-ansi-font-size:14.0pt;
	mso-bidi-font-size:14.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-fareast-language:RU;
	font-weight:bold;
	font-style:italic;}
span.11
	{mso-style-name:"Знак Знак11";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 3";
	mso-ansi-font-size:13.0pt;
	mso-bidi-font-size:13.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-fareast-language:RU;
	font-weight:bold;}
span.10
	{mso-style-name:"Знак Знак10";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 4";
	mso-ansi-font-size:14.0pt;
	mso-bidi-font-size:14.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;
	font-weight:bold;}
span.3
	{mso-style-name:"Знак Знак3";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст сноски";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	mso-fareast-language:RU;}
span.2
	{mso-style-name:"Знак Знак2";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст примечания";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.a
	{mso-style-name:"Знак Знак";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Верхний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.4
	{mso-style-name:"Знак Знак4";
	mso-style-locked:yes;
	mso-style-link:"Нижний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.6
	{mso-style-name:"Знак Знак6";
	mso-style-locked:yes;
	mso-style-link:Название;
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-ascii-font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"MS Sans Serif";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.5
	{mso-style-name:"Знак Знак5";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.8
	{mso-style-name:"Знак Знак8";
	mso-style-locked:yes;
	mso-style-link:"Основной текст с отступом";
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;
	mso-fareast-language:RU;}
span.9
	{mso-style-name:"Знак Знак9";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Схема документа";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;
	background:navy;
	mso-fareast-language:RU;}
span.1
	{mso-style-name:"Знак Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-parent:"Знак Знак2";
	mso-style-link:"Тема примечания";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;
	font-weight:bold;}
span.7
	{mso-style-name:"Знак Знак7";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст выноски";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;
	mso-fareast-language:RU;}
p.20, li.20, div.20
	{mso-style-name:"Стиль Заголовок 2 + Междустр\.интервал\:  полуторный";
	mso-style-update:auto;
	mso-style-parent:"Заголовок 2";
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:55.8pt;
	text-indent:-21.6pt;
	line-height:150%;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	mso-list:l1 level2 lfo2;
	tab-stops:list 72.9pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;
	font-style:italic;}
p.a0, li.a0, div.a0
	{mso-style-name:"Стиль Междустр\.интервал\:  полуторный";
	mso-style-update:auto;
	margin:0cm;
	margin-bottom:.0001pt;
	line-height:150%;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a1, li.a1, div.a1
	{mso-style-name:"Знак Знак Знак Знак Знак Знак Знак";
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
p.TableText, li.TableText, div.TableText
	{mso-style-name:"Table Text";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan lines-together;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;}
p.TableHeading, li.TableHeading, div.TableHeading
	{mso-style-name:"Table Heading";
	mso-style-parent:"Table Text";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan lines-together;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.200, li.200, div.200
	{mso-style-name:"Стиль Заголовок 2 + Слева\:  0 см Первая строка\:  0 см";
	mso-style-parent:"Заголовок 2";
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;
	font-style:italic;}
p.14, li.14, div.14
	{mso-style-name:Обычный1;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 78.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;}
p.4CharChar, li.4CharChar, div.4CharChar
	{mso-style-name:"Знак4 Знак Знак Char Char Знак Знак Знак";
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
p.a2, li.a2, div.a2
	{mso-style-name:"Текст таблицы";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:1.7pt;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a3, li.a3, div.a3
	{mso-style-name:"Шапка таблицы";
	mso-style-next:"Текст таблицы";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	text-align:justify;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.a4, li.a4, div.a4
	{mso-style-name:"Абзац списка";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a4CxSpFirst, li.a4CxSpFirst, div.a4CxSpFirst
	{mso-style-name:"Абзац спискаCxSpFirst";
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a4CxSpMiddle, li.a4CxSpMiddle, div.a4CxSpMiddle
	{mso-style-name:"Абзац спискаCxSpMiddle";
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a4CxSpLast, li.a4CxSpLast, div.a4CxSpLast
	{mso-style-name:"Абзац спискаCxSpLast";
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a5, li.a5, div.a5
	{mso-style-name:"Заголовок оглавления";
	mso-style-noshow:yes;
	mso-style-parent:"Заголовок 1";
	mso-style-next:Обычный;
	margin-top:24.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	line-height:115%;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	font-size:14.0pt;
	font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:#365F91;
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.oaenocaeeaiey, li.oaenocaeeaiey, div.oaenocaeeaiey
	{mso-style-name:oaenocaeeaiey;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msonormalcxspmiddle, li.msonormalcxspmiddle, div.msonormalcxspmiddle
	{mso-style-name:msonormalcxspmiddle;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msonormalcxsplast, li.msonormalcxsplast, div.msonormalcxsplast
	{mso-style-name:msonormalcxsplast;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
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
	margin:2.0cm 62.95pt 2.0cm 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:-120;
	mso-list-type:simple;
	mso-list-template-ids:-665833582;}
@list l0:level1
	{mso-level-style-link:"Нумерованный список";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:1155756171;
	mso-list-template-ids:-384640348;}
@list l1:level1
	{mso-level-style-link:"Заголовок 1";
	mso-level-text:%1;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1:level2
	{mso-level-style-link:"Заголовок 2";
	mso-level-text:"%1\.%2";
	mso-level-tab-stop:72.9pt;
	mso-level-number-position:left;
	margin-left:55.8pt;
	text-indent:-21.6pt;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:126.0pt;
	mso-level-number-position:left;
	margin-left:61.2pt;
	text-indent:-25.2pt;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	margin-left:86.4pt;
	text-indent:-32.4pt;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	margin-left:111.6pt;
	text-indent:-39.6pt;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:270.0pt;
	mso-level-number-position:left;
	margin-left:136.8pt;
	text-indent:-46.8pt;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:306.0pt;
	mso-level-number-position:left;
	margin-left:162.0pt;
	text-indent:-54.0pt;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:360.0pt;
	mso-level-number-position:left;
	margin-left:187.2pt;
	text-indent:-61.2pt;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:396.0pt;
	mso-level-number-position:left;
	margin-left:216.0pt;
	text-indent:-72.0pt;}
@list l2
	{mso-list-id:1288076459;
	mso-list-type:hybrid;
	mso-list-template-ids:-1146192126 1301434110 68747265 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l2:level1
	{mso-level-text:"%1\)";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l2:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l2:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level9
	{mso-level-tab-stop:324.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3
	{mso-list-id:1351225284;
	mso-list-type:hybrid;
	mso-list-template-ids:753709194 68747279 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l3:level1
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l3:level2
	{mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level9
	{mso-level-tab-stop:324.0pt;
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
table.TableNormal
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
table.15
	{mso-style-name:"Сетка таблицы1";
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
 <o:shapedefaults v:ext="edit" spidmax="5122"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU link="#993300" vlink=purple style='tab-interval:35.4pt'>

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><em><span
style='font-size:14.0pt;font-style:normal;mso-bidi-font-style:italic'>Дополнительное
соглашение<o:p></o:p></span></em></p>

<p class=MsoNormal align=center style='text-align:center;text-indent:18.0pt'><em><span
style='font-size:14.0pt;font-style:normal;mso-bidi-font-style:italic'>к
Договору страхования №
<rw:field id="" src="P_2">P_2</rw:field>
<span class=GramE>
от</span>
<rw:field id="" src="P_3">P_3</rw:field>
<o:p></o:p></span></em></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='margin-left:-3.6pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=312 valign=top style='width:234.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>г. Москва</p>
  </td>
  <td width=348 valign=top style='width:261.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:11.0pt'>
  <rw:field id="" src="P_4">P_4</rw:field>
  <o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице Управляющего Директора Киселева О.М., действующего на
основании Доверенности № 2006/07/23 от 23.11.2006 г., с одной стороны, и
<rw:field id="" src="P_5">P_5</rw:field>, Паспорт гражданина РФ Номер:
<rw:field id="" src="P_7">P_7</rw:field>
Выдан:
<rw:field id="" src="P_8">P_8</rw:field>
Дата выдачи:
<rw:field id="" src="P_9">P_9</rw:field>, именуемый (<span class=SpellE>ая</span>)<span
style='mso-spacerun:yes'>  </span>в дальнейшем «Страхователь», с другой
стороны, заключили настоящее Дополнительное Соглашение к Договору страхования №
<rw:field id="" src="P_2">P_2</rw:field>
<span class=GramE>от</span>
<rw:field id="" src="P_3">P_3</rw:field>
(далее – Договор) о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><em><span
style='font-style:normal;mso-bidi-font-style:italic'>1. Стороны договорились п.
2 Договора изложить в следующей редакции:<o:p></o:p></span></em></p>

<p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:
normal'><o:p>&nbsp;</o:p></i></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=175 colspan=3 valign=top style='width:131.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span lang=EN-US
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;color:#FF6600;mso-ansi-language:
  EN-US'>2</span></b><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'>. СТРАХОВАТЕЛЬ</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=480 colspan=3 valign=top style='width:360.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>Ф.И.О.</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_5">P_5</rw:field>
  </o:p>
  </span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_10">P_10</rw:field>
  </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОКУМЕНТ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>
  Номер:
  <rw:field id="" src="P_7">P_7</rw:field>
  Выдан:
  <rw:field id="" src="P_8">P_8</rw:field>
  Дата выдычи:
  <rw:field id="" src="P_9">P_9</rw:field>
  </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 colspan=3 valign=top style='width:116.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 valign=top style='width:252.1pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=139 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=11 style='border:none'></td>
  <td width=5 style='border:none'></td>
  <td width=139 style='border:none'></td>
  <td width=336 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='text-align:justify'><span lang=EN-US
style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'>2. Стороны <em><span
style='font-style:normal;mso-bidi-font-style:italic'>договорились</span></em> п.
3 Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=271 colspan=4 valign=top style='width:203.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600'>3. ЗАСТРАХОВАННОЕ ЛИЦО</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=384 colspan=2 valign=top style='width:288.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>Ф.И.О.</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_11">P_11</rw:field>
  </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_12">P_12</rw:field>
  </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОКУМЕНТ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p>
  Номер:
  <rw:field id="" src="P_13_1">P_13_1</rw:field>
  Выдан:
  <rw:field id="" src="P_13_2">P_13_2</rw:field>
  Дата выдычи:
  <rw:field id="" src="P_13_3">P_13_3</rw:field>
  </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 colspan=3 valign=top style='width:116.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 valign=top style='width:252.1pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=139 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=91 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=336 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'>3. Стороны договорились п. 4
Договора изложить в следующей редакции: </p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600'>4. ПРОГРАММЫ СТРАХОВАНИЯ</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая
  сумма, руб.<o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Премия, руб.<o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:3.5pt'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ОСНОВНАЯ ПРОГРАММА: </span></b><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_14">P_14</rw:field>
  </o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_15">P_15</rw:field>
  </o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_16">P_16</rw:field>
  </o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="G_1" src="G_1">
 <tr style='mso-yfti-irow:7'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="T1_1">T1_1</rw:field>
  </o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="T1_2">T1_2</rw:field>
  </o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="T1_3">T1_3</rw:field>
  </o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 <tr style='mso-yfti-irow:9'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ИТОГО ПРЕМИЯ: <span class=GramE>ОСНОВНАЯ</span>
  И ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ (<i style='mso-bidi-font-style:normal'><rw:field id="" src="P_17">P_17</rw:field></i>):<o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>
  <rw:field id="" src="P_18">P_18</rw:field>
  </o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 valign=top style='width:116.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=216 colspan=2 valign=top style='width:162.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;mso-yfti-lastrow:yes'>
  <td width=657 colspan=5 valign=top style='width:492.75pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:
  normal'><span style='font-size:8.0pt'>Все банковские расходы, связанные с
  оплатой страховой премии, оплачиваются Страхователем.<span class=GramE> .</span><o:p></o:p></span></i></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=164 style='border:none'></td>
  <td width=155 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=168 style='border:none'></td>
  <td width=122 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=657
 style='width:492.75pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=377 colspan=8 valign=top style='width:282.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>СТРАХОВАТЕЛЬ</p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
  style='mso-spacerun:yes'>                  </span><span
  style='mso-spacerun:yes'>                                                                                                  </span></p>
  </td>
  <td width=280 valign=top style='width:210.35pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:6.95pt'>
  <td width=10 valign=top style='width:7.2pt;padding:0cm 1.4pt 0cm 1.4pt;
  height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=158 colspan=4 valign=top style='width:118.75pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>
  <rw:field id="" src="P_6">P_6</rw:field>
  </o:p></p>
  </td>
  <td width=10 valign=top style='width:7.2pt;padding:0cm 1.4pt 0cm 1.4pt;
  height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'>/</p>
  </td>
  <td width=105 valign=top style='width:78.9pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=94 valign=top style='width:70.4pt;padding:0cm 1.4pt 0cm 1.4pt;
  height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'>/</p>
  </td>
  <td width=280 rowspan=4 valign=top style='width:210.35pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.95pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:4.65pt'>
  <td width=377 colspan=8 valign=top style='width:282.4pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.65pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:4.6pt'>
  <td width=16 colspan=2 valign=top style='width:11.65pt;padding:0cm 0cm 0cm 1.4pt;
  height:4.6pt'>
  <p class=MsoNormal style='margin-right:-.25pt'><span style='mso-ansi-language:
  EN-US'><span style='mso-spacerun:yes'> </span></span>«<span lang=EN-US
  style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=23 valign=top style='width:17.6pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.6pt'>
  <p class=MsoNormal style='margin-right:-.25pt'><span lang=EN-US
  style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=11 valign=top style='width:8.5pt;padding:0cm 0cm 0cm 0cm;
  height:4.6pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>»</p>
  </td>
  <td width=118 valign=top style='width:88.15pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.6pt'>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=209 colspan=3 valign=top style='width:156.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.6pt'>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes;height:11.15pt'>
  <td width=377 colspan=8 valign=top style='width:282.4pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.15pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=10 style='border:none'></td>
  <td width=6 style='border:none'></td>
  <td width=23 style='border:none'></td>
  <td width=11 style='border:none'></td>
  <td width=118 style='border:none'></td>
  <td width=10 style='border:none'></td>
  <td width=105 style='border:none'></td>
  <td width=94 style='border:none'></td>
  <td width=280 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt'>Квитанция для оплаты через банк ВТБ-24<o:p></o:p></span></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=677
 style='width:507.6pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:17.0pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-bottom:none;padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>ИЗВЕЩЕНИЕ<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:double windowtext 1.5pt;
  border-left:none;border-bottom:none;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
  6.0pt;margin-left:-1.0cm;text-indent:1.0cm'>ИНН 772552040 <span
  style='mso-no-proof:yes'><v:shapetype id="_x0000_t75" coordsize="21600,21600"
   o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe" filled="f"
   stroked="f">
   <v:stroke joinstyle="miter"/>
   <v:formulas>
    <v:f eqn="if lineDrawn pixelLineWidth 0"/>
    <v:f eqn="sum @0 1 0"/>
    <v:f eqn="sum 0 0 @1"/>
    <v:f eqn="prod @2 1 2"/>
    <v:f eqn="prod @3 21600 pixelWidth"/>
    <v:f eqn="prod @3 21600 pixelHeight"/>
    <v:f eqn="sum @0 0 1"/>
    <v:f eqn="prod @6 1 2"/>
    <v:f eqn="prod @7 21600 pixelWidth"/>
    <v:f eqn="sum @8 21600 0"/>
    <v:f eqn="prod @7 21600 pixelHeight"/>
    <v:f eqn="sum @10 21600 0"/>
   </v:formulas>
   <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>
   <o:lock v:ext="edit" aspectratio="t"/>
  </v:shapetype><v:shape id="Рисунок_x0020_61" o:spid="_x0000_i1025" type="#_x0000_t75"
   style='width:112.5pt;height:48.75pt;visibility:visible'>
   <v:imagedata src="<%=g_ImagesRoot%>/Pril_V.files/image001.emz" o:title=""/>
  </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal style='tab-stops:316.5pt'><span class=GramE>Р</span>/с
  40701810019000007118 в ВТБ24 (ЗАО)<span style='mso-tab-count:1'>                                 </span><span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-bottom-alt:solid windowtext .75pt;mso-border-right-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика <span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-top-alt:solid .75pt;mso-border-left-alt:double 1.5pt;mso-border-bottom-alt:
  solid .75pt;mso-border-right-alt:double 1.5pt;mso-border-color-alt:windowtext;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Код региона <span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border-top:none;
  border-left:double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:22.95pt'>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховая премия по полису <span lang=EN-US
  style='font-family:Garamond;mso-ansi-language:EN-US;mso-fareast-language:
  EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-family:Garamond;mso-ansi-language:EN-US;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:17.0pt'>
  <td width=156 style='width:117.0pt;border-top:none;border-left:double windowtext 1.5pt;
  border-bottom:none;border-right:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>КВИТАНЦИЯ<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
  6.0pt;margin-left:-1.0cm;text-indent:1.0cm'>ИНН 772552040 <span
  style='mso-no-proof:yes'><v:shape id="Рисунок_x0020_60" o:spid="_x0000_i1026"
   type="#_x0000_t75" style='width:112.5pt;height:48.75pt;visibility:visible'>
   <v:imagedata src="<%=g_ImagesRoot%>/Pril_V.files/image001.emz" o:title=""/>
  </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span class=GramE>Р</span>/с 40701810019000007118 в ВТБ24
  (ЗАО)<span style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-bottom-alt:solid windowtext .75pt;mso-border-right-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-top-alt:solid .75pt;mso-border-left-alt:double 1.5pt;mso-border-bottom-alt:
  solid .75pt;mso-border-right-alt:double 1.5pt;mso-border-color-alt:windowtext;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Код региона <span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border-top:none;
  border-left:double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:22.95pt'>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховая премия по полису <span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21;mso-yfti-lastrow:yes;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='text-align:center;page-break-before:
always'><b style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;
font-family:Calibri'>Квитанция для оплаты через прочие банки<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;font-family:Calibri'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-right:-28.4pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt;font-family:PragmaticaCTT'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='margin-left:-12.6pt;border-collapse:collapse;mso-table-layout-alt:fixed;
 border:none;mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;
 mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:231.45pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><v:shapetype id="_x0000_t202"
   coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe">
   <v:stroke joinstyle="miter"/>
   <v:path gradientshapeok="t" o:connecttype="rect"/>
  </v:shapetype><v:shape id="_x0000_s1026" type="#_x0000_t202" style='position:absolute;
   left:0;text-align:left;margin-left:-68.15pt;margin-top:-9.35pt;width:36pt;
   height:45pt;z-index:1' stroked="f">
   <v:textbox style='mso-next-textbox:#_x0000_s1026'>
    <![if !mso]>
    <table cellpadding=0 cellspacing=0 width="100%">
     <tr>
      <td><![endif]>
      <div>
      <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
      style='font-size:42.0pt;mso-bidi-font-size:12.0pt;font-family:Physics'><o:p>&nbsp;</o:p></span></b></p>
      </div>
      <![if !mso]></td>
     </tr>
    </table>
    <![endif]></v:textbox>
  </v:shape><span style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:
  Garamond;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <br style='mso-ignore:vglayout' clear=ALL>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:20.65pt;margin-bottom:
  0cm;margin-left:6.6pt;margin-bottom:.0001pt;line-height:12.0pt;mso-line-height-rule:
  exactly;background:white'><span style='font-size:6.0pt;mso-bidi-font-size:
  12.0pt'><span style='mso-spacerun:yes'>         </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>             </span><span
  style='font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>Отправить в <span class=SpellE><span class=GramE>д</span></span>/о
  _______</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span
  style='mso-spacerun:yes'>                                          </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>ИЗВЕЩЕНИЕ</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='font-size:6.0pt;mso-bidi-font-size:12.0pt'>Кассир</span><span
  style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <p class=a4 align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='mso-fareast-font-family:Calibri'>Форма ПД-4</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:13.5pt;mso-fareast-font-family:
  Calibri'><o:p></o:p></span></b></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='margin-left:.25pt;border-collapse:collapse;mso-table-layout-alt:fixed;
   border:none;mso-border-alt:dash-small-gap windowtext .5pt;mso-yfti-tbllook:
   1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:64.9pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:64.9pt'>
    <p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
    auto'><span style='font-size:10.0pt;mso-fareast-font-family:Calibri'>ООО</span><span
    class=GramE><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
    mso-fareast-font-family:Calibri'>«С</span></span><span style='font-size:
    10.0pt;mso-fareast-font-family:Calibri'>К «Ренессанс Жизнь»<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП 775001001<span
    style='mso-spacerun:yes'>                </span><o:p></o:p></span></p>
    <p class=MsoNormal><span class=GramE><b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'>Р</span></b></span><b><span style='font-size:
    7.0pt;mso-bidi-font-size:8.0pt'>/С</span></b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'><span style='mso-spacerun:yes'>    </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «<span class=SpellE>Райффайзенбанк</span>» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=317 rowspan=2 valign=top style='width:237.7pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:64.9pt'>
    <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:-1.0cm;text-indent:1.0cm'><span style='mso-no-proof:yes'><v:shape
     id="Рисунок_x0020_58" o:spid="_x0000_i1027" type="#_x0000_t75" style='width:112.5pt;
     height:48.75pt;visibility:visible'>
     <v:imagedata src="<%=g_ImagesRoot%>/Pril_V.files/image001.emz" o:title=""/>
    </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:8.7pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:8.7pt'>
    <h1 style='text-indent:0cm;mso-list:none;tab-stops:35.4pt'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-font-family:
    Calibri;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev:
   .5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:21.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:21.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>________________________________________________________</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:27.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:27.05pt'>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                                                                 
    </span>(Фамилия, Имя, Отчество плательщика)</span><span style='font-size:
    7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:
    EN-US'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>___________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)</span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.75pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.75pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>________________________________________________________________</span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:9.95pt;mso-row-margin-right:81.0pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;text-autospace:ideograph-other'><o:p>&nbsp;</o:p></p>
    </td>
    <td width=282 valign=top style='width:211.45pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                        </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    страхователя)</span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=108><p class='MsoNormal'></td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:12.1pt'>
    <p class=MsoNormal style='margin-bottom:3.0pt'><b><span style='font-size:
    9.0pt;mso-bidi-font-size:12.0pt'>Назначение платежа:</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховая премия</span><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:12.1pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:16.05pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    3.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по</span><span style='mso-no-proof:yes'> </span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>полису<span
    style='mso-spacerun:yes'>   </span>№ </span></b><b><span style='font-size:
    8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:
    EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 style='width:72.8pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:6.2pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:6.2pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><b><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'> </span></span></b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:5.4pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:5.4pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>         </span><span
    style='mso-spacerun:yes'>                                              </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span></span><span style='font-size:7.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=a4><span style='mso-fareast-font-family:Calibri'>«_____»
  ___________200 __ г.<span style='mso-spacerun:yes'>               
  </span>Подпись плательщика _______________________ <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:224.0pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>                             </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>КВИТАНЦИЯ</p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'>Кассир</span><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev:
   .5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:52.5pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=a4><span style='mso-fareast-font-family:Calibri'>ООО «СК
    «Ренессанс Жизнь»<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП775001001<o:p></o:p></span></p>
    <p class=MsoNormal><span class=GramE><b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'>Р</span></b></span><b><span style='font-size:
    7.0pt;mso-bidi-font-size:8.0pt'>/С</span></b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'><span style='mso-spacerun:yes'>    </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «<span class=SpellE>Райффайзенбанк</span>» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=317 colspan=2 rowspan=2 valign=top style='width:237.4pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:-1.0cm;text-indent:1.0cm'><span style='mso-no-proof:yes'><v:shape
     id="Рисунок_x0020_59" o:spid="_x0000_i1028" type="#_x0000_t75" style='width:112.5pt;
     height:48.75pt;visibility:visible'>
     <v:imagedata src="<%=g_ImagesRoot%>/Pril_V.files/image001.emz" o:title=""/>
    </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=257 colspan=2 rowspan=2 valign=top style='width:192.8pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=MsoNormal align=right style='margin-right:-1.7pt;text-align:right'><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:8.6pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:8.6pt'>
    <h1 style='text-indent:0cm;mso-list:none;tab-stops:35.4pt'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-font-family:
    Calibri;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>_______________________________________________________</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:4.0pt;mso-row-margin-right:
    191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    плательщика)</span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)</span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:20.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:20.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>______________________________________________________________</span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:4.0pt;mso-row-margin-right:272.7pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:4.0pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;text-autospace:ideograph-other'><o:p>&nbsp;</o:p></p>
    </td>
    <td width=282 colspan=2 valign=top style='width:211.45pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                            </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    страхователя)</span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=364 colspan=3><p class='MsoNormal'></td>
   </tr>
   <![if !supportMisalignedColumns]>
   <tr height=0>
    <td width=125 style='border:none'></td>
    <td width=72 style='border:none'></td>
    <td width=210 style='border:none'></td>
    <td width=107 style='border:none'></td>
    <td width=1 style='border:none'></td>
    <td width=256 style='border:none'></td>
   </tr>
   <![endif]>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:10.3pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:10.3pt'>
    <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Назначение
    платежа:</span></b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховая премия </span><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:10.3pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по полису<span style='mso-spacerun:yes'>  </span>№ </span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 valign=top style='width:72.8pt;border-top:none;
    border-left:none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:5.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:5.1pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><o:p>&nbsp;</o:p></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                    </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='margin-top:6.0pt'><span style='font-size:8.0pt;
  mso-bidi-font-size:12.0pt'>«_____» ___________200 __ г.<span
  style='mso-spacerun:yes'>                </span>Подпись плательщика _______________________</span><sub><span
  style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></sub></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report> 


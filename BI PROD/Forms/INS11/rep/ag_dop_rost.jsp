<%response.setContentType("application/msword");
  Long msec = new Long((new java.util.Date()).getTime());
  response.setHeader ("Content-Disposition", "attachment;filename=\""+ msec.toString() +".doc\""); %>
<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*, java.text.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  String SYSD = sdf.format(new java.util.Date());
%>

<rw:report id="report" >

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dop_kz" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOP_KZ" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CONTRACT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select>
      <![CDATA[SELECT acj.AGENT_ID, acj.ag_contract_header_id, acj.agent_name, acj.num,
       pkg_contact.get_address_name
                          (pkg_contact.get_primary_address (acj.agent_id)
                          ) addr, CH.DATE_BREAK, CH.DATE_BEGIN
  FROM v_ag_contract_journal acj, VEN_AG_CONTRACT_HEADER CH 
 WHERE acj.ag_contract_header_id = :p_ch_id
AND CH.AG_CONTRACT_HEADER_ID = acj.ag_contract_header_id 
]]>
      </select>
      <displayInfo x="2.07300" y="1.48950" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="1.79785"
        />
        <dataItem name="DATE_BEGIN" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="CH.DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="7" width="9"/>
        </dataItem>
        <dataItem name="DATE_BREAK" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Break">
          <dataDescriptor expression="CH.DATE_BREAK"
           descriptiveExpression="DATE_BREAK" order="6" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="16" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="acj.num" descriptiveExpression="NUM"
           order="4" width="100"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="15"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="acj.AGENT_ID"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="ag_contract_header_id" oracleDatatype="number"
         columnOrder="12" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="acj.ag_contract_header_id"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="agent_name" datatype="vchar2" columnOrder="13"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name">
          <dataDescriptor expression="acj.agent_name"
           descriptiveExpression="AGENT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="14" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="pkg_contact.get_address_name ( pkg_contact.get_primary_address ( acj.agent_id ) )"
           descriptiveExpression="ADDR" order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[select org.COMPANY_NAME, org.chief_name, org.INN, org.KPP, org.ACCOUNT_NUMBER, 
org.BANK_COMPANY_TYPE||' "'||org.BANK_NAME||'"' bank, org.B_BIC, org.B_KOR_ACCOUNT, org.LEGAL_ADDRESS
   from v_company_info org
]]>
      </select>
      <displayInfo x="0.40637" y="0.09375" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.13416" y="0.63745" width="1.24426" height="1.79785"
        />
        <dataItem name="chief_name" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor expression="org.COMPANY_NAME"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="20" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.INN" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="21" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.KPP" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="22"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.ACCOUNT_NUMBER"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="23" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.BANK_COMPANY_TYPE || &apos; &quot;&apos; || org.BANK_NAME || &apos;&quot;&apos;"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="24" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.B_BIC" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="25"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.B_KOR_ACCOUNT"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Legal Address">
          <dataDescriptor expression="org.LEGAL_ADDRESS"
           descriptiveExpression="LEGAL_ADDRESS" order="9" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AGENT_ADDR">
      <select>
      <![CDATA[SELECT DECODE (brief, 'CONST', 'прописки', 'проживания') pref, ca.contact_id,
       pkg_contact.get_address_name (a.ID) addr
  FROM cn_contact_address ca, cn_address a, t_address_type AT
 WHERE ca.adress_id = a.ID
   AND ca.address_type = AT.ID
   AND (AT.brief = 'CONST' OR AT.brief = 'FACT');
]]>
      </select>
      <displayInfo x="3.75000" y="0.04163" width="0.69995" height="0.32983"/>
      <group name="G_AGENT_ADDR">
        <displayInfo x="3.55005" y="0.74158" width="1.09998" height="0.77246"
        />
        <dataItem name="pref" datatype="vchar2" columnOrder="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="28" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr1">
          <dataDescriptor expression="pkg_contact.get_address_name ( a.ID )"
           descriptiveExpression="ADDR" order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AG_DOCS">
      <select>
      <![CDATA[SELECT   vcp.CONTACT_ID, tit.brief doc_desc, NVL (cci.serial_nr, '@') p_ser,
         NVL (cci.id_value, '@') p_num,
         NVL (cci.place_of_issue, '@') pvidan,
         DECODE (TO_CHAR (NVL (cci.issue_date,
                               TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                              ),
                          'DD.MM.YYYY'
                         ),
                 '01.01.1900', '@',
                 TO_CHAR (cci.issue_date, 'DD.MM.YYYY')
                ) data_v
    FROM ven_cn_person vcp, ven_cn_contact_ident cci, ven_t_id_type tit
   WHERE vcp.contact_id = cci.contact_id
     AND cci.id_type = tit.ID
     AND UPPER (tit.brief) IN ('PASS_RF','INN','PENS' ) 
ORDER BY NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC]]>
      </select>
      <displayInfo x="3.99988" y="1.77087" width="0.69995" height="0.32996"/>
      <group name="G_AG_DOCS">
        <displayInfo x="3.66003" y="2.47095" width="1.37964" height="1.28516"
        />
        <dataItem name="data_v" datatype="vchar2" columnOrder="36"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <xmlSettings xmlTag="DATA_V1"/>
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="32"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <xmlSettings xmlTag="DOC_DESC1"/>
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="33" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="34" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="35" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOPS">
      <select>
      <![CDATA[SELECT   c.contract_id, TO_NUMBER (c.num) vn
    FROM ven_ag_contract c
   WHERE c.AG_CONTRACT_ID = :P_CONTRACT_ID
]]>
      </select>
      <displayInfo x="4.12500" y="3.88538" width="0.69995" height="0.32983"/>
      <group name="G_DOPS">
        <displayInfo x="3.87378" y="4.58533" width="1.20251" height="0.77246"
        />
        <dataItem name="contract_id" oracleDatatype="number" columnOrder="38"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contract Id">
          <dataDescriptor expression="c.contract_id"
           descriptiveExpression="CONTRACT_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="vn" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Vn">
          <dataDescriptor expression="TO_NUMBER ( c.num )"
           descriptiveExpression="VN" order="2" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT" parentColumn="AGENT_ID"
     childQuery="Q_AGENT_ADDR" childColumn="contact_id" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_AGENT" parentColumn="AGENT_ID"
     childQuery="Q_AG_DOCS" childColumn="CONTACT_ID2" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_AGENT"
     parentColumn="ag_contract_header_id" childQuery="Q_DOPS"
     childColumn="contract_id" condition="eq" sqlClause="where"/>
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
<link rel=File-List href="ag_dop_rost.files/filelist.xml">
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:getValue id="DATE_BREAK" src="DATE_BREAK"/>
<title>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ №  <%=AGDOGNUM%> </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>Khomich</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>Khomich</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>1</o:TotalTime>
  <o:Created>2007-03-30T14:56:00Z</o:Created>
  <o:LastSaved>2007-03-30T14:57:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>177</o:Words>
  <o:Characters>1009</o:Characters>
  <o:Company>belsoft-borlas</o:Company>
  <o:Lines>8</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1184</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
 <o:OfficeDocumentSettings>
  <o:RelyOnVML/>
  <o:AllowPNG/>
 </o:OfficeDocumentSettings>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"MS Sans Serif";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:515 0 0 0 5 0;}
@font-face
	{font-family:PartnerCondensed;
	mso-font-alt:"Courier New";
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:515 0 0 0 5 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
h1
	{margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	mso-outline-level:1;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:12.0pt;
	font-family:PartnerCondensed;
	font-variant:small-caps;
	font-weight:bold;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:70.85pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	tab-stops:334.45pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.25in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p
	{mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.fr1, li.fr1, div.fr1
	{mso-style-name:fr1;
	margin-top:0in;
	margin-right:140.0pt;
	margin-bottom:0in;
	margin-left:146.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:16.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:8.5in 11.0in;
	margin:56.7pt 42.5pt 56.7pt 85.05pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:170068102;
	mso-list-template-ids:1454823246;}
@list l0:level1
	{mso-level-start-at:3;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1
	{mso-list-id:612516387;
	mso-list-template-ids:-73886900;}
@list l1:level1
	{mso-level-start-at:4;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2
	{mso-list-id:785735684;
	mso-list-template-ids:-1844442574;}
@list l2:level1
	{mso-level-start-at:5;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3
	{mso-list-id:1117598131;
	mso-list-template-ids:-1006572814;}
@list l4
	{mso-list-id:1301494429;
	mso-list-template-ids:-1440197206;}
@list l4:level1
	{mso-level-start-at:6;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5
	{mso-list-id:1858889809;
	mso-list-template-ids:1434252754;}
@list l5:level1
	{mso-level-start-at:2;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
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
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-para-margin:0in;
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

<body bgcolor=white lang=EN-US style='tab-interval:.5in'>
<%

/*AGENT INFO*/
String PS = new String("");
String PNUM = new String("");
String PVIDAN= new String("");
String DATAV = new String("");
String AGINN= new String();
String PENS = new String();
String addrProp = new String();
String addrProz = new String();

/*ORG INFO*/
String ORGNAME = new String();
String CHIEF_NAME = new String();
String ORGINN = new String();
String ORGKPP = new String();
String ORGRS = new String();
String ORGBANK = new String();
String ORGBBIC = new String();
String ORGKORAC = new String();
String ORGADDR = new String();
String AGDOPSNUM = new String();


%>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY" />
<rw:foreach id="agdop" src="G_DOPS">
<rw:getValue id="VER_NT" src="VN"/>

<% AGDOPSNUM = AGDOGNUM + "/" +VER_NT;%>
</rw:foreach>
<rw:foreach id="agdoc" src="G_AG_DOCS">
<rw:getValue id="docBrief" src="DOC_DESC"/>
<% if (docBrief.equals("PASS_RF")) { %>
<rw:getValue id="P_SER" src="P_SER"/>
<rw:getValue id="P_NUM" src="P_NUM"/>
<rw:getValue id="P_VIDAN" src="PVIDAN"/>
<rw:getValue id="DATA_V" src="DATA_V"/>
<%


    PS = P_SER;
    PNUM = P_NUM;
    PVIDAN = P_VIDAN;
    DATAV = DATA_V;
  
}
if (docBrief.equals("INN")) { %>
<rw:getValue id="P_NUM1" src="P_NUM"/>
<%AGINN = P_NUM1;}%>
<% if (docBrief.equals("PENS")) { %>
<rw:getValue id="P_NUM2" src="P_NUM"/>
<%PENS = P_NUM2;}%>
</rw:foreach>
<%  
if (PNUM.equals("")) {
     PNUM = "____________";
     PS = "____";
     PVIDAN = "_____________________________";
     DATAV = "__________";
  
} else {
  if (PNUM.equals("@")) 
      PNUM = "____________";
    if (PS.equals("@")) 
      PS = "____";
    if (PVIDAN.equals("@")) 
     PVIDAN = "_____________________________";
    if (DATAV.equals("@")) 
      DATAV = "__________";
    }
  
%>
<rw:foreach id="gorg" src="G_ORG_CONT">
  <rw:getValue id="COMPANY_NAME" src="COMPANY_NAME"/>
  <rw:getValue id="DIRRECTOR" src="CHIEF_NAME"/>
  <rw:getValue id="INN" src="INN"/>
  <rw:getValue id="KPP" src="KPP"/>
  <rw:getValue id="ACCOUNT_NUMBER" src="ACCOUNT_NUMBER"/>
  <rw:getValue id="BANK" src="BANK"/>
  <rw:getValue id="B_BIC" src="B_BIC"/>
  <rw:getValue id="B_KOR_ACCOUNT" src="B_KOR_ACCOUNT"/>
  <rw:getValue id="LEGAL_ADDRESS" src="LEGAL_ADDRESS"/>
  
<% 
ORGNAME  = COMPANY_NAME;
CHIEF_NAME = DIRRECTOR;
ORGINN 	 = INN;
ORGKPP   = KPP; 	
ORGRS    = ACCOUNT_NUMBER;	
ORGBANK	 = BANK;
ORGBBIC  = B_BIC; 
ORGKORAC = B_KOR_ACCOUNT;
ORGADDR  = LEGAL_ADDRESS;
%>
</rw:foreach>

    <rw:foreach id="gaddr" src="G_AGENT_ADDR">
     <rw:getValue id="pref" src="PREF"/> 
     <% if (pref.equals("прописки") ) {
     %>
          <rw:getValue id="addrProp_temp" src="ADDR1"/>      
     <%
     addrProp = addrProp_temp;
     } else {
     %>
          <rw:getValue id="addrProz_temp" src="ADDR1"/> 
     <%
        addrProz_temp.trim();
        if ( !addrProz_temp.equals(addrProp) && !addrProz_temp.equals("")) {
     addrProz = addrProz_temp;
     %>
     <%}}%>
    </rw:foreach>
<div class=Section1>

<div>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:496.5pt;mso-cellspacing:0in;mso-padding-alt:0in 0in 0in 0in'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:496.5pt;padding:0in 0in 0in 0in'>
  <p align=center style='text-align:center;tab-stops:421.65pt'><b><span
  style='font-size:9.0pt'>&nbsp;</span></b><b><span lang=RU style='font-size:
  11.0pt;mso-ansi-language:RU'>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ <span style='color:
  #333333'>№ <%=AGDOPSNUM%></span></span></b><span
  lang=RU style='font-size:9.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  <p align=center style='text-align:center;tab-stops:172.65pt 255.65pt 338.65pt 421.65pt'><b><span
  lang=RU style='mso-ansi-language:RU'>&nbsp;</span></b><span lang=RU
  style='mso-ansi-language:RU'><o:p></o:p></span></p>
  <h1><span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";
  text-transform:uppercase;mso-ansi-language:RU'>К АГЕНТСКОМУ ДОГОВОРУ <span
  style='color:#333333'>№ <%=AGDOGNUM%></span></span><span lang=RU
  style='mso-ansi-language:RU'><o:p></o:p></span></h1>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=659
   style='width:494.25pt;mso-cellspacing:0in;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
    <td width=344 valign=top style='width:258.0pt;padding:0in 0in 0in 0in'>
    <p class=fr1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";
    mso-ansi-language:RU;font-weight:normal'>г. Москва</span><span lang=RU
    style='mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=316 valign=top style='width:237.0pt;padding:0in 0in 0in 0in'>
    <p class=fr1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;tab-stops:467.8pt'><span style='font-size:11.0pt;
    font-family:"Times New Roman";color:#333333;font-weight:normal'><%=SYSD%></span><span
    lang=RU style='mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p style='text-align:justify;tab-stops:421.65pt'><span lang=RU
  style='mso-ansi-language:RU'>&nbsp;</span><span lang=RU style='font-size:
  11.0pt;mso-ansi-language:RU'>Общество с ограниченной ответственностью <%=ORGNAME%>,
  именуемое в дальнейшем СТРАХОВЩИК, в лице г-на </span><span lang=RU
  style='mso-ansi-language:RU'><%=CHIEF_NAME%></span><span lang=RU style='font-size:
  11.0pt;mso-ansi-language:RU'>, действующего на основании Доверенности №
  2005/02/17, выданной 15 ноября 2005 года, с одной стороны, и <%=AGNAME%> ,
  именуемы</span><span class=GramE>й(</span><span class=SpellE>ая</span><span
  lang=RU style='font-size:11.0pt;mso-ansi-language:RU'>) в дальнейшем АГЕНТ, с
  другой стороны, составили и утвердили настоящее Дополнительное Соглашение к
  Агентскому договору (далее – Соглашение) о нижеследующем:<o:p></o:p></span></p>
  <ol start=1 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l3 level1 lfo1;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>С <%=DATE_BREAK%> Агентский договор № <%=AGDOGNUM%>
       , заключенный между <%=ORGNAME%> &nbsp;и <%=AGNAME%> &nbsp;(далее – </span>Договор<span
       lang=RU style='mso-ansi-language:RU'>) прекращает свое действие по
       соглашению сторон.<o:p></o:p></span></li>
  </ol>
  <ol start=2 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l5 level1 lfo2;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>Настоящее Соглашение вступает в
       силу с момента его подписания обеими сторонами.<o:p></o:p></span></li>
  </ol>
  <ol start=3 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l0 level1 lfo3;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>Обязательства Сторон по Договору прекращаются
       с момента вступления в силу настоящего соглашения. <o:p></o:p></span></li>
  </ol>
  <ol start=4 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l1 level1 lfo4;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>Стороны не имеют взаимных претензий
       по Договору.<o:p></o:p></span></li>
  </ol>
  <ol start=5 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l2 level1 lfo5;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>С момента вступления настоящего
       Соглашения в силу Страховщик отзывает выданную Агенту Доверенность от </span>&nbsp;<%=DATE_BEGIN%><o:p></o:p></li>
  </ol>
  <ol start=6 type=1>
   <li class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
       auto;mso-list:l4 level1 lfo6;tab-stops:list .5in left 421.65pt'><span
       lang=RU style='mso-ansi-language:RU'>Настоящее Соглашение составлено в
       двух экземплярах, имеющих одинаковую юридическую силу, по одному для
       каждой из Сторон.<o:p></o:p></span></li>
  </ol>
  <p style='tab-stops:421.65pt'><span lang=RU style='mso-ansi-language:RU'>&nbsp;&nbsp;<o:p></o:p></span></p>
     <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=328 valign=top style='width:246.35pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width=328 valign=top style='width:246.35pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt'>
    <td width=328 valign=top style='width:246.35pt;padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>
    <%=ORGNAME%>
    </span><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU style='color:#333333'>Реквизиты</span></b><span
    style='color:#333333;mso-ansi-language:EN-US'>: <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU style='color:#333333'>ИНН </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGINN%>
    </span><span lang=RU
    style='color:#333333'>, <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:0in;line-height:11.0pt;mso-line-height-rule:
    exactly'><span lang=RU style='color:#333333'>КПП </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGKPP%>
    </span><span lang=RU
    style='color:#333333'>,<o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:0in;line-height:11.0pt;mso-line-height-rule:
    exactly'><span lang=RU style='color:#333333'><span class=GramE>Р</span>/С: </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGRS%>
    </span><span lang=RU
    style='color:#333333'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:0in;line-height:11.0pt;mso-line-height-rule:
    exactly'><span lang=RU style='color:#333333'>В </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGBANK%>
    </span><span lang=RU
    style='color:#333333'>,<o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:0in;line-height:11.0pt;mso-line-height-rule:
    exactly'><span lang=RU style='color:#333333'><span
    style='mso-spacerun:yes'> </span>г. Москва, БИК </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGBBIC%>
    </span><span lang=RU
    style='color:#333333'>, <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:0in;line-height:11.0pt;mso-line-height-rule:
    exactly'><span lang=RU style='color:#333333'>К/С </span><span
    style='color:#333333;mso-ansi-language:EN-US'>
    <%=ORGKORAC%>
    </span><span lang=RU
    style='color:#333333'><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU style='color:#333333'>Адрес:
    </span></b><span
    style='color:#333333;mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=ORGADDR%>
    </span><span
    lang=RU style='color:#333333'><o:p></o:p></span></p>
    </td>
    <td width=328 valign=top style='width:246.35pt;padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>ФИО</span></b><span
    style='color:#333333;mso-ansi-language:EN-US'><%=AGNAME%></span><span lang=RU
    style='color:#333333'><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>Паспорт: </span></b>
    <span style='color:#333333;mso-ansi-language:EN-US'>
    <% if (!PNUM.equals("____________")) {%>
    <% if (!PS.equals("____")) {%>
    Серия: <%=PS%>, <%}%>
    номер: <%=PNUM%>, 
    <% if (!PVIDAN.equals("_____________________________")) {%>
    выдан: <%=PVIDAN%>, <%}%>
    <% if (!DATAV.equals("__________")) {%>
    дата выдачи: <%=DATAV%> <%}%>     
    <%}%>
    </span>
    <span
    lang=RU style='color:#333333'><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>Адрес по месту прописки: </span></b><span
    style='color:#333333;mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProp%>
</span><b><span
    lang=RU style='color:#333333'><o:p></o:p></span></b></p>
    <%if (!addrProz.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>Адрес по месту проживания<span
    style='mso-spacerun:yes'>  </span></span></b><span
    style='color:#333333;mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProz%>
    </span><b><span
    lang=RU style='color:#333333'><o:p></o:p></span></b></p>
    <%}%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>ИНН: </span></b><b><span style='color:#333333;
    mso-ansi-language:EN-US'><%=AGINN%></span><span lang=RU style='color:#333333'><o:p></o:p></span></b></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    style='color:#333333'>№ пенсионного свидетельства</span></b><b><span
    style='color:#333333;mso-ansi-language:EN-US'>: </span></b><span
    style='color:#333333;mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=PENS%></span><span
    style='color:#333333;mso-ansi-language:EN-US'><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU style='color:#333333'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  </td>
 </tr>
</table>
</div>

</div>

</body>
</rw:foreach>
</html>
</rw:report>
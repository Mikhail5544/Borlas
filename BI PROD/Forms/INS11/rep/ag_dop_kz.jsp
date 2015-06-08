<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>
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
                          ) addr
  FROM v_ag_contract_journal acj
 WHERE acj.ag_contract_header_id = :p_ch_id;
]]>
      </select>
      <displayInfo x="2.07300" y="1.48950" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="1.79785"
        />
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
        <dataItem name="chief_name" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="17"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor expression="org.COMPANY_NAME"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="18" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.INN" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="19" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.KPP" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="20"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.ACCOUNT_NUMBER"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="21" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.BANK_COMPANY_TYPE || &apos; &apos; || org.BANK_NAME"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="22" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.B_BIC" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="23"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.B_KOR_ACCOUNT"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="24"
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
        <dataItem name="pref" datatype="vchar2" columnOrder="28"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="27"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="26" width="4000"
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
        <dataItem name="data_v" datatype="vchar2" columnOrder="34"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <xmlSettings xmlTag="DATA_V1"/>
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="30"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <xmlSettings xmlTag="DOC_DESC1"/>
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="31" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="32" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="33" width="255"
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
      <![CDATA[ SELECT   c.contract_id, c.num vn, c.date_begin
    FROM ven_ag_contract c
   WHERE c.AG_CONTRACT_ID = :P_CONTRACT_ID
]]>
      </select>
      <displayInfo x="4.12500" y="3.88538" width="0.69995" height="0.32983"/>
      <group name="G_DOPS">
        <displayInfo x="3.87378" y="4.58533" width="1.20251" height="0.77246"
        />
        <dataItem name="contract_id" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contract Id">
          <dataDescriptor expression="c.contract_id"
           descriptiveExpression="CONTRACT_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="vn" datatype="vchar2" columnOrder="35" width="100"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Vn">
          <dataDescriptor expression="c.num" descriptiveExpression="VN"
           order="2" width="100"/>
        </dataItem>
        <dataItem name="date_begin" datatype="date" oracleDatatype="date"
         columnOrder="36" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="c.date_begin"
           descriptiveExpression="DATE_BEGIN" order="3" oracleDatatype="date"
           width="9"/>
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


<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="<%=g_ImagesRoot%>/ag_dop_kz.files/filelist.xml">
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<title>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ № 1 К АГЕНТСКОМУ ДОГОВОРУ № <%=AGDOGNUM%></title>
<!--[if gte mso 9]><xml>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:DocumentProtectionNotEnforced>ReadOnly</w:DocumentProtectionNotEnforced>
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
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:"Times New Roman CYR";
	panose-1:2 2 6 3 5 4 5 2 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:536902279 -2147483648 8 0 511 0;}
@font-face
	{font-family:"MS Sans Serif";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:515 0 0 0 5 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
h2
	{mso-style-next:Обычный;
	margin:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:RU;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 207.65pt right 415.3pt;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 207.65pt right 415.3pt;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:70.85pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
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
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
p.MsoDocumentMap, li.MsoDocumentMap, div.MsoDocumentMap
	{mso-style-noshow:yes;
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	background:navy;
	font-size:10.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:19.5pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:-19.5pt;
	mso-pagination:widow-orphan;
	mso-list:l1 level1 lfo2;
	tab-stops:14.2pt list 19.5pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
@page Section3
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section3
	{page:Section3;}
@page Section4
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section4
	{page:Section4;}
@page Section5
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section5
	{page:Section5;}
@page Section6
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section6
	{page:Section6;}
@page Section7
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;	
	mso-paper-source:0;}
div.Section7
	{page:Section7;}
@page Section8
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;		
	mso-paper-source:0;}
div.Section8
	{page:Section8;}
@page Section9
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;		
	mso-paper-source:0;}
div.Section9
	{page:Section9;}
@page Section10
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;		
	mso-paper-source:0;}
div.Section10
	{page:Section10;}
@page Section11
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dop_kz.files/header.htm") f1;		
	mso-paper-source:0;}
div.Section11
	{page:Section11;}
 /* List Definitions */
 @list l0
	{mso-list-id:212280710;
	mso-list-type:hybrid;
	mso-list-template-ids:1106007218 68747279 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l0:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1
	{mso-list-id:1354503029;
	mso-list-template-ids:-767529522;}
@list l1:level1
	{mso-level-start-at:2;
	mso-level-style-link:Обычный1;
	mso-level-legal-format:yes;
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l1:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
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
<![endif]-->
</head>

<body lang=EN-US style='tab-interval:35.4pt'>


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
String DATE_BEGIN = new String();

%>
<rw:foreach id="agdop" src="G_DOPS">
<rw:getValue id="VER_NT" src="VN"/>
<rw:getValue id="DATE_BEGINT" src="DATE_BEGIN" formatMask="DD.MM.YYYY" />
<% AGDOPSNUM = AGDOGNUM + "/" +VER_NT; 
   DATE_BEGIN = DATE_BEGINT;
%>
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

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
  center'><b style='mso-bidi-font-weight:normal'><span lang=RU>ДОПОЛНИТЕЛЬНОЕ
  СОГЛАШЕНИЕ № <span style='color:#333333;mso-bidi-font-weight:bold'><%=AGDOPSNUM%></span><o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
  center'><b style='mso-bidi-font-weight:normal'><span lang=RU>К АГЕНТСКОМУ
  ДОГОВОРУ <span style='color:#333333'>№<span style='mso-spacerun:yes'> 
  </span></span></span></b><span lang=RU style='color:#333333'><%=AGDOGNUM%><b
  style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in'><span lang=RU
  style='color:#333333'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Общество
  с </span><span lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>ограниченной
  ответственностью </span><span style='font-size:11.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=ORGNAME%></span><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>, именуемое в дальнейшем Страховщик, в лице
  г-на </span><span style='font-size:11.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=CHIEF_NAME%></span><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>, действующего на основании Доверенности №
  2005/02/17, выданной 15 ноября 2005 года, с одной стороны, и<span
  style='mso-spacerun:yes'>  </span></span><span style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman";color:#333333;
  mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=AGNAME%></span><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>, паспорт <span
  style='color:#333333'>серии </span></span><span style='font-size:11.0pt;
  font-family:"Times New Roman";color:#333333;mso-ansi-language:EN-US'><%=PS%></span><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman";color:#333333'>
  № </span><span style='font-size:11.0pt;font-family:"Times New Roman";
  color:#333333;mso-ansi-language:EN-US'><%=PNUM%></span><span lang=RU
  style='font-size:11.0pt;font-family:"Times New Roman";color:#333333'>, </span><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>именуемый(ая)
  в дальнейшем АГЕНТ, с другой стороны, составили настоящее Дополнительное
  соглашение к Агентскому договору <span style='color:#333333'>№</span></span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  color:#333333;mso-fareast-language:EN-US'> </span><span style='font-size:
  11.0pt;font-family:"Times New Roman";color:#333333;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman";color:#333333'>
  от<span style='mso-spacerun:yes'>  </span></span><span style='font-size:11.0pt;
  font-family:"Times New Roman";color:#333333;mso-ansi-language:EN-US'><%=DATE_BEGIN%></span><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'><span
  style='mso-spacerun:yes'>  </span>о нижеследующем.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:l0 level1 lfo4;
  tab-stops:list 0in left 14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Настоящее Дополнительное
  соглашение является неотъемлемой частью Агентского Договора <span
  style='color:#333333'>№<a name="agent_id_11"> </a></span></span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;color:#333333;mso-ansi-language:
  EN-US;layout-grid-mode:line'><%=AGDOGNUM%></span><span style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;color:#333333;layout-grid-mode:line'> </span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>(далее – Агентский Договор) и определяет размер агентского
  вознаграждения Агента по договорам страхования, заключенным Страховщиком в
  результате выполнения Агентом своих обязанностей по Агентскому договору, но
  по которым поиск потенциальных клиентов был осуществлен не самим Агентом, а
  сотрудниками структурного подразделения Страховщика или представителями
  Страховщика</span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt'> в ходе телефонных переговоров.<span style='layout-grid-mode:line'><o:p></o:p></span></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt'>2</span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:line'>.
  Выплата агентского вознаграждения производится на основании Отчета к
  Агентскому Договору (Приложение № 1,2 к настоящему дополнительному
  соглашению), который подписывается Агентом и представителем Страховщика.</span><span
  lang=RU style='font-size:11.0pt'><o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt'>3. Б</span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>азовые размеры ставок
  агентского вознаграждения АГЕНТА за 1-й год действия договора страхования
  определяются в соответствии с пунктами 3.1.-3.6. настоящего Дополнительного
  соглашения.<span style='mso-spacerun:yes'>  </span>Размер агентского
  вознаграждения за 2-й и последующие годы действия договора страхования
  определяются в соответствии с Приложением 1 к Агентскому Договору.<o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section2>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>3.1. САВ1. СТАВКИ ОСНОВНОГО АГЕНТСКОГО
  ВОЗНАГРАЖДЕНИЯ АГЕНТОВ, ИМЕЮЩИХ СТАТУС &quot;КОНСУЛЬТАНТ&quot;<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>(физические лица) <o:p></o:p></span></p>
  <p class=MsoNormal style='tab-stops:54.4pt 96.95pt 139.5pt 182.05pt 224.6pt 267.15pt 309.7pt 352.25pt 394.75pt 437.25pt 479.75pt 522.25pt 564.75pt 607.25pt 649.75pt'><span
  style='font-size:10.0pt;font-family:Arial'><span style='mso-tab-count:11'>                                                                                                                                                                </span><o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>2,63%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,68%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal><span style='font-size:10.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,73%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>6,13%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,15%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>6,74%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,78%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,36%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>7,35%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,57%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,84%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>7,97%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,78%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,91%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>8,58%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>7,35%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>3,99%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>0,98%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>9,19%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>7,88%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,05%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>9,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,41%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,12%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>10,42%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>8,93%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,62%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,19%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>11,03%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>9,45%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,83%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,26%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>11,64%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>9,98%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,04%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,33%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>12,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,33%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section3>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>САВ1. СТАВКИ ОСНОВНОГО АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ
  АГЕНТОВ, ИМЕЮЩИХ СТАТУС &quot;КОНСУЛЬТАНТ&quot;<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>(индивидуальные предприниматели)<o:p></o:p></span></p>
  <p class=MsoNormal style='tab-stops:54.4pt 96.95pt 139.5pt 182.05pt 224.6pt 267.15pt 309.7pt 352.25pt 394.75pt 437.25pt 479.75pt 522.25pt 564.75pt 607.25pt 649.75pt'><span
  style='font-size:10.0pt;font-family:Arial'><span style='mso-tab-count:11'>                                                                                                                                                                </span><o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее будущее»,
    «Жизнь под моим контролем», «Успешный старт».</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>1 – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,87%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,44%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,01%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,58%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,15%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,69%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,73%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,36%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,65%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,02%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,87%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,87%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,44%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,36%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,01%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,33%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,08%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,03%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,56%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,16%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,16%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,79%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,23%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,37%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,73%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,02%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,31%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,04%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,39%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,71%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,48%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,47%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>больше или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,37%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,45%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,71%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,33%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA;layout-grid-mode:line'><br
clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section4>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'>3.2. </span><span lang=RU style='mso-ansi-language:
  RU;mso-fareast-language:RU'>САВ2. СТАВКИ ОСНОВНОГО АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ
  АГЕНТОВ, ИМЕЮЩИХ СТАТУС &quot;ФИНАНСОВЫЙ КОНСУЛЬТАНТ&quot;<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>(физические лица)<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,63%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,38%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,13%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,63%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,90%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section5>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>САВ2. СТАВКИ ОСНОВНОГО
  АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ АГЕНТОВ, ИМЕЮЩИХ СТАТУС &quot;ФИНАНСОВЫЙ
  КОНСУЛЬТАНТ&quot;<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'><span
  style='mso-spacerun:yes'> </span>(индивидуальные предприниматели)<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,09%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,91%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,73%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,36%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,18%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,51%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,99%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,21%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,21%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,46%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,81%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,53%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,42%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,63%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,86%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,43%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,37%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,45%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,19%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,33%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,26%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,52%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,65%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,28%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,08%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,84%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,76%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,24%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,87%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,19%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,72%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,98%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,15%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,53%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,09%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,35%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,15%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,20%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,90%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap style='width:183.95pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section6>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>3.3. САВ3. СТАВКИ
  ОСНОВНОГО АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ АГЕНТОВ, ИМЕЮЩИХ СТАТУС «ВЕДУЩИЙ
  КОНСУЛЬТАНТ»<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>(физические лица)<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,76%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,12%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,44%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,65%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,48%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,56%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,84%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,68%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,56%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,92%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,92%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,04%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,28%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,16%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,95%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,64%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,28%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>21,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,40%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,20%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,28%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section7>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>САВ3. СТАВКИ ОСНОВНОГО
  АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ АГЕНТОВ В СТАТУСЕ &quot;ВЕДУЩИЙ КОНСУЛЬТАНТ&quot;<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>(индивидуальные предприниматели)<o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>4,91%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,89%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,87%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,83%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,46%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,81%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,32%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,61%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,79%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,45%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,77%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,64%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,59%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,90%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,76%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,03%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,72%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,05%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,74%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,42%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,19%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,72%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,82%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,98%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,34%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,70%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,21%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,11%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,48%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,68%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,61%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>20,63%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,66%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,38%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>21,78%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,64%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,39%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>22,92%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,62%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,30%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,78%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,86%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,51%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,64%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,64%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,74%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,80%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA;layout-grid-mode:line'><br
clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section8>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'>3.4. </span><span lang=RU style='mso-ansi-language:
  RU;mso-fareast-language:RU'>САВ4. СТАВКИ ОСНОВНОГО АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ
  АГЕНТОВ В СТАТУСЕ &quot; ФИНАНСОВЫЙ СОВЕТНИК&quot; <o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>(физические лица)<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее
    будущее», «Жизнь под моим контролем», «Успешный старт».</span><span
    lang=RU style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,35%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,45%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,25%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,48%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,55%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,72%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,14%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,68%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,65%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,56%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,82%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,15%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,98%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,38%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,82%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,24%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>20,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,24%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,38%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>22,05%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,90%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,66%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,52%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>23,28%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,95%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,08%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,66%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>24,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>21,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,80%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,40%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,66%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 align=left style='margin-left:0in;text-align:left;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section9>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>САВ4. СТАВКИ ОСНОВНОГО
  АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ АГЕНТОВ В СТАТУСЕ &quot; ФИНАНСОВЫЙ СОВЕТНИК&quot; <o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU;mso-fareast-language:RU'>(индивидуальные предприниматели)<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=640
   style='width:479.65pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 0in 0in 0in;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Период страхо</span><span
    style='font-size:9.0pt'>вания, лет<o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Гармония жизни»</span><span style='font-size:10.0pt;
    font-family:Arial'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>«Лучшее будущее», «Жизнь под
    моим контролем», «Успешный старт»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;Страхование от
    несчастных случаев&quot; к программам &quot;Гармония жизни&quot;, «Лучшее будущее»,
    «Жизнь под моим контролем», «Успешный старт».</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>«Моя защита»</span><span lang=RU style='font-size:
    10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам &quot;Гармония жизни&quot;, «Лучшее будущее», «Жизнь под моим
    контролем», «Успешный старт».</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>периодическая уплата взносов,
    1 год действия договора</span><span lang=RU style='font-size:10.0pt;
    font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>единовременная уплата премии</span><span lang=RU
    style='font-size:10.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>1
    – 4<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>5,73%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,87%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,02%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,16%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,31%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,37%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,45%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>6,83%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,54%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,71%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,59%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,29%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,70%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,05%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>13,74%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>7,74%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>1,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,38%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>14,88%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,21%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,72%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>16,03%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>8,66%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,16%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>20,06%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>17,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,12%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,31%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>21,39%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>18,31%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,58%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,47%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>22,73%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>19,46%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,04%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,62%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>24,07%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>20,60%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,77%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>25,41%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>21,75%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,96%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,93%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'>больше
    или равно 20<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>26,74%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>22,89%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,85%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,41%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>9,17%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,10%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,08%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=628
   style='width:470.9pt;border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=383 nowrap style='width:286.95pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=245 style='width:183.95pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и от несчастных случаев<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,08%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к
    программам группового страхования жизни и от НС<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,19%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:11.45pt'>
    <td width=383 style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>Опция &quot;ИНВЕСТ&quot; к программам
    группового страхования жизни и от НС (пакетное страхование)<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:3.0pt'>
    <td width=383 nowrap style='width:286.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
    </td>
    <td width=245 nowrap valign=bottom style='width:183.95pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 align=left style='margin-left:0in;text-align:left;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 align=left style='margin-left:0in;text-align:left;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>3.5.
  По дополнительным программам (опциям к основным программам) «Гармония жизни»,
  «Лучшее будущее», «Жизнь под моим контролем», «Успешный старт»), за
  исключением дополнительных программ (опций) «Инвест» и «Страхование от
  несчастных случаев», базовый размер ставки агентского вознаграждения равен
  базовому размеру ставки агентского вознаграждения по основной программе
  страхования. <o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>3.6.
  По дополнительным программам (опциям к основным программам) к договорам
  группового страхования, заключенным в соответствии с «Общими условиями
  группового страхования жизни и от несчастных случаев (пакетные программы
  страхования)» и с «Общими условиями группового страхования жизни и
  страхования от несчастных случаев», за исключением дополнительной программы
  (опции) «Инвест», базовый размер ставки агентского вознаграждения равен
  базовому размеру ставки агентского вознаграждения по основной программе
  страхования.<o:p></o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>4.
  Настоящее Дополнительное соглашение вступает в силу с момента его подписания
  Сторонами. Во всем остальном, что не предусмотрено настоящим Дополнительным
  соглашением, Стороны руководствуются положениями Агентского Договора.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  EN-US'><span style='mso-tab-count:2'>            </span><o:p></o:p></span></p>
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

<span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA;layout-grid-mode:line'><br clear=all style='page-break-before:always;
mso-break-type:section-break'>
</span>

<div class=Section10>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyTextIndent style='margin-left:0in'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <h2><span lang=RU>Приложение № 1 к Дополнительному соглашению <span
  style='color:#333333'>№ </span></span><span style='color:#333333;mso-ansi-language:
  EN-US'><%=AGDOPSNUM%></span><span lang=RU style='color:#333333'><span
  style='mso-spacerun:yes'>  </span>к Агентскому Договору<span
  style='mso-spacerun:yes'>  </span>№ </span><span style='mso-bidi-font-size:
  11.0pt;color:#333333;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span lang=RU
  style='color:#333333'><o:p></o:p></span></h2>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1.Настоящее Приложение является
  неотъемлемой частью Дополнительного соглашения к Агентскому договору № </span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'> (далее -
  Договор).<o:p></o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2.Настоящее Приложение
  устанавливает форму Отчета Агента к </span><span lang=RU style='font-size:
  11.0pt'>Агентскому договору, на основании которого выплачивается основное
  агентское вознаграждение, за осуществление Агентом агентской деятельности,
  направленной на заключение Страховщиком при посредничестве Агента договоров
  страхования, в соответствии с условиями Договора, за исключением
  обязанностей, предусмотренных п.п. 2.1. и 2.3..<o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА
  № ОАВ-__<o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'>к Агентскому договору № <a name="agent_id_222">0000</a><o:p></o:p></span></b></p>
  <p class=MsoTitle align=left style='margin-top:6.0pt;text-align:left'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>г.
  Москва<span style='mso-tab-count:4'>                                                                                                                              </span></span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'> <span style='mso-spacerun:yes'> </span><span
  style='mso-spacerun:yes'> </span><span style='mso-spacerun:yes'> </span></span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=SYSD%></span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-tab-count:1'>            </span>Общество с ограниченной
  ответственностью </span><span style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;font-family:"Times New Roman";mso-ansi-language:EN-US'><%=ORGNAME%></span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>,
  именуемое в дальнейшем Страховщик, в лице Генерального директора г-на </span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=CHIEF_NAME%></span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>, действующего на
  основании Устава, с одной стороны, и </span><span style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman";mso-ansi-language:
  EN-US'><%=AGNAME%></span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;font-family:"Times New Roman"'>, паспорт серии </span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=PS%></span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'> № </span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=PNUM%></span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>, именуемый(ая) в
  дальнейшем АГЕНТ, с другой стороны, составили и утвердили настоящий отчет к
  Агентскому договору о нижеследующем.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>За период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; при посредничестве Агента были заключены
  следующие договоры страхования.<b style='mso-bidi-font-weight:normal'>.</b>
  По указанным договорам страхования на расчетный счет страховщика поступила
  страховая премия в полном объеме:<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:11.25pt'>
    <td width=119 rowspan=2 style='width:89.25pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
    </td>
    <td width=177 rowspan=2 style='width:132.9pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
    </td>
    <td width=141 rowspan=2 style='width:105.55pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
    </td>
    <td width=88 rowspan=2 style='width:66.35pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора<o:p></o:p></span></b></p>
    </td>
    <td width=76 rowspan=2 style='width:57.2pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
    </td>
    <td width=82 rowspan=2 style='width:61.75pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплаченная страховая
    премия, руб.<o:p></o:p></span></b></p>
    </td>
    <![if !supportMisalignedRows]>
    <td style='height:11.25pt;border:none' width=0 height=15></td>
    <![endif]>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <![if !supportMisalignedRows]>
    <td style='height:31.85pt;border:none' width=0 height=42></td>
    <![endif]>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=119 valign=bottom style='width:89.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=177 valign=bottom style='width:132.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=141 valign=bottom style='width:105.55pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=88 valign=bottom style='width:66.35pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=76 valign=bottom style='width:57.2pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=82 valign=bottom style='width:61.75pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <![if !supportMisalignedRows]>
    <td style='height:12.75pt;border:none' width=0 height=17></td>
    <![endif]>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'>Основное агентское вознаграждение за отчетный период
  составляет: ________. Расчет агентского вознаграждения прилагается к
  настоящему отчету.<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><b><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'>.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
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

<span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA;layout-grid-mode:line'><br clear=all style='page-break-before:always;
mso-break-type:section-break'>
</span>

<div class=Section11>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyTextIndent style='margin-left:0in'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <h2><span lang=RU>Приложение № 2<span style='mso-spacerun:yes'>  </span>к
  Дополнительному соглашению <span style='color:#333333'>№<a name="alt_number_2">
  </a></span></span><span style='color:#333333;mso-ansi-language:EN-US'><%=AGDOPSNUM%></span><span
  lang=RU style='color:#333333'><span style='mso-spacerun:yes'>  </span></span><span
  lang=RU>к Агентскому Договору<span style='mso-spacerun:yes'>  </span><span
  style='color:#333333'>№ </span></span><span style='mso-bidi-font-size:11.0pt;
  color:#333333;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span lang=RU
  style='color:#333333'><o:p></o:p></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='tab-stops:14.2pt list 19.5pt left 27.0pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1. Настоящее
  Приложение является неотъемлемой частью Дополнительного соглашения к
  Агентскому договору № </span><span style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'> (</span><span lang=RU
  style='font-size:11.0pt'>далее - Договор).<o:p></o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt'>2. Настоящее Приложение устанавливает форму Расчета
  агентского вознаграждения Агента, выплачиваемое за осуществление Агентом
  агентской деятельности, направленной на заключение Страховщиком при
  посредничестве Агента договоров страхования, в соответствии с условиями
  Договора, за исключением обязанностей, предусмотренных п.п. 2.1. и 2.3..<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.25in;tab-stops:
  27.0pt;mso-layout-grid-align:none;text-autospace:none'><span lang=RU
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center;text-indent:.25in;
  tab-stops:27.0pt;mso-layout-grid-align:none;text-autospace:none'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Расчет
  агентского вознаграждения к отчету Агента от &lt;ДАТА&gt; к Дополнительному
  Соглашению № 1 к Агентскому договору </span></b><b style='mso-bidi-font-weight:
  normal'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
  "Times New Roman"'><%=AGDOGNUM%></span></b><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center;text-indent:.25in;
  tab-stops:27.0pt;mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;tab-stops:27.0pt;mso-layout-grid-align:
  none;text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>3. Агентское
  вознаграждение выплачивается в соответствии с условиями Дополнительного
  соглашения № 1 к Агентскому договору №<a name="agent_id_3333"> </a></span><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><%=AGDOGNUM%></span><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'>, а также условиями Агентского договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;tab-stops:27.0pt;mso-layout-grid-align:
  none;text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>4. За период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; АГЕНТ получает агентское вознаграждение за
  следующие договоры страхования, заключенные при его посредничестве:<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify;mso-layout-grid-align:
  none;text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=96 rowspan=2 style='width:71.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
    </td>
    <td width=143 rowspan=2 style='width:107.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
    </td>
    <td width=113 rowspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
    </td>
    <td width=71 rowspan=2 style='width:53.45pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора<o:p></o:p></span></b></p>
    </td>
    <td width=61 rowspan=2 style='width:46.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
    </td>
    <td width=66 rowspan=2 style='width:49.75pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.<o:p></o:p></span></b></p>
    </td>
    <td width=133 colspan=2 style='width:99.6pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=66 valign=bottom style='width:49.8pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от премии<o:p></o:p></span></b></p>
    </td>
    <td width=66 valign=bottom style='width:49.8pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=96 valign=bottom style='width:71.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=143 valign=bottom style='width:107.1pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=113 valign=bottom style='width:85.05pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=71 valign=bottom style='width:53.45pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=61 valign=bottom style='width:46.1pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=66 valign=bottom style='width:49.75pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=66 valign=bottom style='width:49.8pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=66 valign=bottom style='width:49.8pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt'><span
  style='mso-list:Ignore'>3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>За
  период с &lt;ДАТА&gt; по &lt;ДАТА&gt; были расторгнуты следующие договоры
  страхования, заключенные Страховщиком при посредничестве Агента. В
  соответствии с п. 2.24., 6.6., 6.7. Агентского договора, часть агентского
  вознаграждения по этим договорам удержана из агентского вознаграждения Агента
  в соответствии с таблицей, приведенной ниже.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=96 rowspan=2 style='width:71.95pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
    </td>
    <td width=143 rowspan=2 style='width:107.1pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <h2><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
    layout-grid-mode:line'>Страхователь<o:p></o:p></span></h2>
    </td>
    <td width=113 rowspan=2 style='width:85.05pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
    </td>
    <td width=80 rowspan=2 style='width:60.2pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год действия договора на
    момент расторжения<o:p></o:p></span></b></p>
    </td>
    <td width=80 rowspan=2 style='width:60.25pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Сумма выплаченного по
    договору агентского вознаграждения<o:p></o:p></span></b></p>
    </td>
    <td width=161 colspan=2 style='width:120.5pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение к
    возврату<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=80 valign=bottom style='width:60.25pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от суммы выплаченного
    АВ<o:p></o:p></span></b></p>
    </td>
    <td width=80 valign=bottom style='width:60.25pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:14.8pt'>
    <td width=96 valign=bottom style='width:71.95pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=143 valign=bottom style='width:107.1pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=113 valign=bottom style='width:85.05pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=80 valign=bottom style='width:60.2pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=80 valign=bottom style='width:60.25pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=80 valign=bottom style='width:60.25pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=80 valign=bottom style='width:60.25pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:14.8pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt'><span
  style='mso-list:Ignore'>4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>Итого
  размер агентского вознаграждения за период с &lt;ДАТА&gt; по &lt;ДАТА&gt;
  составляет: &lt;Сумма из п. 1&gt; - &lt;Сумма из п. 2&gt; = &lt;СУММА&gt;.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Сумма агентского
  вознаграждения, указанная в п. 4, определена правильно.<o:p></o:p></span></p>
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
  <p class=MsoBodyTextIndent style='margin-left:0in'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='layout-grid-mode:both'><span style='font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>

</div>
</rw:foreach>
</body>

</html>
</rw:report>
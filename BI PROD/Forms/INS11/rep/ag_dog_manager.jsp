<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report" > 


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_meneger_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_MENEGER_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[SELECT acj.agent_id, acj.ag_contract_header_id, 
       acj.agent_name,
       nvl((select instrumental from contact where contact_id = acj.agent_id),acj.agent_name) agent_name_ins,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || acj.num num,
       d.reg_date,
       acj.date_begin,
       nvl(pkg_contact.get_address_name
                          (pkg_contact.get_primary_address (acj.agent_id)
                          ),'@') addr,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            '��������� ���� ���������'
           ) dir_name,
       dept_exe.contact_id dir_contact_id          
  FROM v_ag_contract_journal acj,
       ven_department dep,
       ven_document d,
       ven_dept_executive dept_exe
 WHERE acj.agency_id = dep.department_id(+)
   AND d.document_id = acj.ag_contract_header_id
   AND acj.agency_id = dept_exe.department_id(+)
   AND acj.ag_contract_header_id = :p_ch_id;]]>
      </select>
      <displayInfo x="2.07300" y="1.48950" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="2.13965"
        />
        <dataItem name="AGENT_NAME_INS" datatype="vchar2" columnOrder="37"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name Ins">
          <dataDescriptor expression="AGENT_NAME_INS"
           descriptiveExpression="AGENT_NAME_INS" order="4" width="4000"/>
        </dataItem>
        <dataItem name="DATE_BEGIN" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="7" width="9"/>
        </dataItem>
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="39" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="10" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="dir_name" datatype="vchar2" columnOrder="18"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="9" width="4000"/>
        </dataItem>
        <dataItem name="reg_date" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Reg Date">
          <dataDescriptor expression="REG_DATE"
           descriptiveExpression="REG_DATE" order="6" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="16" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="NUM" descriptiveExpression="NUM"
           order="5" width="201"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="15"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="AGENT_ID"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="ag_contract_header_id" oracleDatatype="number"
         columnOrder="12" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="agent_name" datatype="vchar2" columnOrder="13"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name">
          <dataDescriptor expression="AGENT_NAME"
           descriptiveExpression="AGENT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="14" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor expression="ADDR" descriptiveExpression="ADDR"
           order="8" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT org.company_type||' '||org.company_name company_name, org.chief_name, org.inn, org.kpp, org.account_number,
       org.bank_company_type || ' ' || org.bank_name bank, org.b_bic,
       org.b_kor_account, org.legal_address
  FROM v_company_info org;]]>
      </select>
      <displayInfo x="0.40637" y="0.09375" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.13416" y="0.63745" width="1.49084" height="1.79785"
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
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="20" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="21" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="22"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="23" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="24" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="25"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Legal Address">
          <dataDescriptor expression="org.legal_address"
           descriptiveExpression="LEGAL_ADDRESS" order="9" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AGENT_ADDR">
      <select>
      <![CDATA[SELECT DECODE (brief, 'CONST', '��������', '����������') pref, ca.contact_id,
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
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;��������&apos; , &apos;����������&apos; )"
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
          <dataDescriptor
           expression="NVL ( cci.serial_nr , &apos;_____&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="34" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor
           expression="NVL ( cci.id_value , &apos;___________&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="35" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;______________________________&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="36" width="11"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;___________&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="11"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DIR_DOCS">
      <select>
      <![CDATA[SELECT   vcp.CONTACT_ID, tit.brief doc_desc, NVL (cci.serial_nr, '@') p_ser,
         NVL (cci.id_value, '@') p_num,
         NVL (cci.place_of_issue, '@') pvidan,
         DECODE (TO_CHAR (NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY') ),'DD.MM.YYYY' ),
                 '01.01.1900', '@', TO_CHAR (cci.issue_date, 'DD.MM.YYYY') ) data_v
    FROM ven_cn_person vcp, ven_cn_contact_ident cci, ven_t_id_type tit
   WHERE vcp.contact_id = cci.contact_id
     AND cci.id_type = tit.ID
     AND UPPER (tit.brief) IN ('TRUST')   ]]>
      </select>
      <displayInfo x="3.86462" y="4.19788" width="0.69995" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="3.52478" y="4.89783" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID1" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="41"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser1" datatype="vchar2" columnOrder="42" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser1">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num1" datatype="vchar2" columnOrder="43" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num1">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan1" datatype="vchar2" columnOrder="44"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pvidan1">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v1" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT" parentColumn="AGENT_ID"
     childQuery="Q_AGENT_ADDR" childColumn="contact_id" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_AGENT" parentColumn="AGENT_ID"
     childQuery="Q_AG_DOCS" childColumn="CONTACT_ID2" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_AGENT" parentColumn="DIR_CONTACT_ID"
     childQuery="Q_DIR_DOCS" childColumn="CONTACT_ID1" condition="eq"
     sqlClause="where"/>
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
<title>���������� �5 </title>
<!--[if gte mso 9]><xml>
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
 table.mainTable{
 border=0;
 cellspacing=0;
 cellpadding=0;
 width:6.9in;
 border-collapse:collapse;
 mso-yfti-tbllook:480;
 mso-padding-alt:0in 5.4pt 0in 5.4pt;
 }
 tr.mainTr{
 }
 td.mainTd{
 valign=top;
 width:6.9in;
 padding:0in 5.4pt 0in 5.4pt;
 }
 @font-face
	{font-family:"Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
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
	{mso-style-next:�������;
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
p.MsoBodyTextIndent2, li.MsoBodyTextIndent2, div.MsoBodyTextIndent2
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:2.25pt;
	margin-bottom:.0001pt;
	text-align:justify;
	line-height:125%;
	mso-pagination:none;
	layout-grid-mode:char;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;
	text-underline:single;}
p.FR1, li.FR1, div.FR1
	{mso-style-name:FR1;
	mso-style-parent:"";
	margin-top:0in;
	margin-right:140.0pt;
	margin-bottom:0in;
	margin-left:146.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	layout-grid-mode:char;
	font-size:16.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.1, li.1, div.1
	{mso-style-name:�������1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:28.5pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:-19.5pt;
	mso-pagination:widow-orphan;
	mso-list:l7 level1 lfo1;
	tab-stops:14.2pt list 28.5pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
 /* Page Definitions */
 @page
@page Section1
	{size:595.3pt 841.9pt;
	margin:56.9pt 56.9pt 56.9pt 56.9pt;
	mso-header-margin:0in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:22.7pt;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
@page Section3
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:42.5pt 42.5pt .5in 42.5pt;
	mso-header-margin:35.3pt;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section3
	{page:Section3;}
@page Section4
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section4
	{page:Section4;}
@page Section5
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section5
	{page:Section5;}
@page Section6
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section6
	{page:Section6;}
 /* List Definitions */
 @list l0
	{mso-list-id:61561152;
	mso-list-type:hybrid;
	mso-list-template-ids:1850607882 68747265 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
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
	{mso-list-id:131220508;
	mso-list-type:hybrid;
	mso-list-template-ids:1908572790 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l1:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2
	{mso-list-id:179778994;
	mso-list-type:hybrid;
	mso-list-template-ids:2106090686 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l2:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l2:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3
	{mso-list-id:342901498;
	mso-list-type:hybrid;
	mso-list-template-ids:1593837392 67698689 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}
@list l3:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l3:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4
	{mso-list-id:803890164;
	mso-list-type:hybrid;
	mso-list-template-ids:-324102726 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l4:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l4:level2
	{mso-level-start-at:2;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
@list l4:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5
	{mso-list-id:969628906;
	mso-list-type:hybrid;
	mso-list-template-ids:-801358350 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l5:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l5:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6
	{mso-list-id:1082602987;
	mso-list-type:hybrid;
	mso-list-template-ids:-696759816 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l6:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l6:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7
	{mso-list-id:1354503029;
	mso-list-template-ids:-267218132;}
@list l7:level1
	{mso-level-start-at:2;
	mso-level-style-link:�������1;
	mso-level-legal-format:yes;
	mso-level-tab-stop:28.5pt;
	mso-level-number-position:left;
	margin-left:28.5pt;
	text-indent:-19.5pt;}
@list l7:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:29.5pt;
	mso-level-number-position:left;
	margin-left:29.5pt;
	text-indent:-29.5pt;}
@list l7:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l7:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l7:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l7:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l7:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l7:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l7:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l8
	{mso-list-id:1728840352;
	mso-list-template-ids:72643792;}
@list l8:level1
	{mso-level-legal-format:yes;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:8.5pt;
	text-indent:-8.5pt;}
@list l8:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:17.0pt;
	text-indent:-17.0pt;}
@list l8:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l8:level4
	{mso-level-reset-level:level1;
	mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l8:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l8:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l8:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l8:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l8:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l9
	{mso-list-id:2005477334;
	mso-list-template-ids:-447601770;}
@list l9:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:27.0pt;
	mso-level-number-position:left;
	margin-left:27.0pt;
	text-indent:-.25in;
	font-family:Symbol;}
@list l9:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l9:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l9:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l9:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l9:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l9:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l9:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l9:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l7:level1 lfo5
	{mso-level-start-at:1;}
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
	{mso-style-name:"������� �������";
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

<body lang=EN-US link=blue vlink=purple style='tab-interval:35.4pt'>
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="REG_DATE" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="DIR_NAME" src="DIR_NAME"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:getValue id="AGENT_NAME_INS" src="AGENT_NAME_INS"/>
<%

/*AGENT INFO*/
String PS = new String("____");
String PNUM = new String("____________");
String PVIDAN= new String("_____________________________");
String DATAV = new String("__________");
String AGINN= new String();
String PENS = new String();
String addrProp = new String();
String addrProz = new String();

String PNUM_DOC_DIR = new String("____________");
String DATAV_DOC_DIR = new String("__________");


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

CHIEF_NAME = DIR_NAME;

if (AGADDR.equals("@")) AGADDR = "_______________________________________________";
%>

<rw:foreach id="G_DIR_DOCS" src="G_DIR_DOCS">
<rw:getValue id="docBrief_dir" src="DOC_DESC1"/>
<% if (docBrief_dir.equals("TRUST")) { %>
<rw:getValue id="P_NUM_DIR_DOV" src="P_NUM1"/>
<rw:getValue id="DATA_V_DIR_DOV" src="DATA_V1"/>
<%
    if (!P_NUM_DIR_DOV.equals("@")) PNUM_DOC_DIR = P_NUM_DIR_DOV;
    if (!DATA_V_DIR_DOV.equals("@")) DATAV_DOC_DIR = DATA_V_DIR_DOV;    
}
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
    if (!P_SER.equals("@")) PS = P_SER;
    if (!P_NUM.equals("@")) PNUM = P_NUM;
    if (!P_VIDAN.equals("@")) PVIDAN = P_VIDAN;
    if (!DATA_V.equals("@")) DATAV = DATA_V;    
}
if (docBrief.equals("INN")) { %>
<rw:getValue id="P_NUM1" src="P_NUM"/>
<%AGINN = P_NUM1;}%>
<% if (docBrief.equals("PENS")) { %>
<rw:getValue id="P_NUM2" src="P_NUM"/>
<%PENS = P_NUM2;}%>
</rw:foreach>
<%  
  
%>
<rw:foreach id="gorg" src="G_ORG_CONT">
  <rw:getValue id="COMPANY_NAME" src="COMPANY_NAME"/>
  <rw:getValue id="INN" src="INN"/>
  <rw:getValue id="KPP" src="KPP"/>
  <rw:getValue id="ACCOUNT_NUMBER" src="ACCOUNT_NUMBER"/>
  <rw:getValue id="BANK" src="BANK"/>
  <rw:getValue id="B_BIC" src="B_BIC"/>
  <rw:getValue id="B_KOR_ACCOUNT" src="B_KOR_ACCOUNT"/>
  <rw:getValue id="LEGAL_ADDRESS" src="LEGAL_ADDRESS"/>
  
<% 
ORGNAME  = COMPANY_NAME;
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
     <% if (pref.equals("��������") ) {
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

<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
  <p class=MsoBodyTextIndent align=right style='margin-left:0in;text-align:
  right'><span lang=RU style='font-size:12.0pt'>���������� �5 <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent align=right style='margin-left:0in;text-align:
  right'><span lang=RU style='font-size:12.0pt'>� ������� �� 25.01.2007<span
  style='mso-spacerun:yes'>�� </span>�05/��/07 <o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="100%" colspan=2 valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 style='margin-top:0in;margin-right:1.35pt;margin-bottom:0in;
    margin-left:0in;margin-bottom:.0001pt;line-height:11.0pt;mso-line-height-rule:
    exactly;tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������� ������� <span
    >� </span></span><span style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span lang=RU style='font-size:
    11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>�. ������</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span><span lang=RU style='font-size:
    11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";color:#333333'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='text-indent:27.0pt;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-indent:27.0pt;line-height:11.0pt;mso-line-height-rule:
  exactly;text-align:justify'><span lang=RU style='mso-ansi-language:RU'>��������� �������
  �������� ����� <%=ORGNAME%>, ��������� � ���������� ����������ʻ, � ����
  <%=CHIEF_NAME%>, ������������ �� ��������� ������������ � <%=PNUM_DOC_DIR%> ������� <%=DATAV_DOC_DIR%>,
  � ����� �������, � <%=AGENT_NAME_INS%></span><b style='mso-bidi-font-weight:
  normal'><span style='mso-ansi-language:RU'> </span></b><span
  lang=RU style='mso-ansi-language:RU'>,</span></span><span
  lang=RU style='mso-ansi-language:RU'> ������� ����� <b
  style='mso-bidi-font-weight:normal'><span style='mso-spacerun:yes'>�</span></b></span>
  <span ><%=PS%></span><span lang=RU
  style='mso-ansi-language:RU'> � </span><span
  ><%=PNUM%></span><span lang=RU style='
  mso-ansi-language:RU'> �����: </span><span ><%=PVIDAN%>, ���� ������ <%=DATAV%></span><span
  lang=RU style='mso-ansi-language:RU'>, �����: </span>
  <span ><%=AGADDR%></span><span lang=RU
  style='mso-ansi-language:RU'>, ��������� � ���������� �����һ,
  � ������ �������.<o:p></o:p></span></p>
  <p class=MsoNormal style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent2 align=left style='margin-left:0in;text-align:
  left;text-indent:9.0pt;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l8 level1 lfo2;tab-stops:list .25in left 42.55pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������� ��������.</span></b><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=1 style='margin-left:17.0pt;text-indent:-17.0pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>1.1.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>�� ����������
  �������� ����� ��������� �� �������������� ������������ �� ����� � ��
  ��������� ����������� �������������� ������������ � ������� ����������� �
  ����� ���������� ������������ � </span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;mso-fareast-language:EN-US'>����������� �
  ������������ ������ (����� �� ������ - ��������������) </span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>��������� ����������� </span><span
  lang=RU style='font-size:11.0pt'>�� ��������� ����� �����������:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������� �����;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������� �����
  (����������);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������� ������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������� ��
  ���������� ������� � ��������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������������
  ����������� �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:8.5pt;text-indent:-8.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;
  tab-stops:list .25in'><![if !supportLists]><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������� ������:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>������������
  ����� �������� ��� ���������� �� ������������ ��������� �����������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������
  ������ ������������� � ���������<span class=GramE>�</span> ���������
  �����������, � ��� ����� �������������, ����� ������� ����������� ����
  ������� - ������..<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������������
  ������������� ��������, � ��� ����� �������������, ����� ������� �����������
  ���� ������� � ������, �� ��������, ��������� � ����������� ���������
  ����������� � ������ ��������������� ����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>��������� ����
  ��������, ����������� ��� ���������� ��������� ����������� � ��������
  ����������, ��������������� ��������� ��������� � �������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 25.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������
  ������ ������������� � ����������� ���������� ��������� � ����������� � �����
  �����������, � ��� ����� �������������, ����� ������� ����������� ����
  ������� - ������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.6.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������
  ������ � ���������� ����������, ����������� ��� ��������� ��������� ������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.7.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>������������
  ������ ��������� ������ �� ��������� ����������� (�������) � ������������ �
  �������� ���������, ����������� � ����������� �� ������ ���������� ��������
  ����������� (������) �� �������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.8.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������
  �������, ������������� ��������� ���������, � ������� ������������ �
  ����������������� ��, ��������� ���������� ��������, ��������� ����������� �
  ������������, �������������� ������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.9.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>���������
  ���������, ����������� ��� ���������� ��������� �����������, � �������
  ������������ � �����������, ������������� ������������, � ��� ����� ���������
  ����������� <span class=GramE>��</span> <span class=GramE>�������������</span>,
  ����� ������� ����������� ���� ������� - ������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 29.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.10.</span></span><![endif]>
  <span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>��������� ������������ � ������������ ���
  ���������� ������� ���������� ������� ���������� (��������� � �.�.), ��������
  ������� �������, ���������<span style='mso-spacerun:yes'>� </span>� ������
  ��������������� ���������� �����������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.11.</span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>������������� ����������� ����������� ������
  ����������, ����������� ��� ���������� ��������� �����������<span
  class=GramE> .</span><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.12.
  </span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>���������� �������� �������� ���������� �
  ������������ ���������, �������� �� ����������� � ������������. � ������
  ������ ������� ���������� ������� ����������, �������� ������� ���������,
  �������, ���������� ������������, �������� ����, ���������� � ��������
  ��������� ������ (�������) �� ����������� ������� ��������� �����������,
  ����� ������ � ������� 1 (������) �������� ��� ��������� �� ���� �����������.
  ��� ������ ���������� ������� ����������, �������� ������� ���������, �������
  � �������� ������� �� ���� ������, ���������� ����� ����� ����������� ��
  ������ ���������� ����������� ��������� ���������� ����� ������ �������.
  ����� ������������� �� ���������������, ���� �������, ��� ������ ���������� �
  �������� ������� ������� ���������� �������� ������������� ������������� ����
  ���� �������������� �������� ������� ���. � ������ ����� ���������� �������
  ����������, �������� ������� ��������� � ������� ����������� ����������
  ������ ������������ ����������� � ������� 3 (����) ������� ����.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.13.
  </span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>���������� ������������ ����������
  ��������������, � ��� ����� ��������������, ����� ������� ����������� ���� �������
  � ������, ��������� �� ����������� � �������� �� ����������� �� ������� 3
  (����) ������� ���� � ������� �� ���������� � ���������� �������������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.14.
  </span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>������������ �������� �������������, � ���
  ����� �������������, ����� ������� ����������� ���� ������� � ������,
  ����������� ������������ ��������� ����������� (�������) � �������
  ����������� ����������� ����������� �� ������� 3 (����) ������� ���� �
  ������� �� ����������. ��� ������ ���������� ��������
  ������������/����������� ������������� �������� ������� ������� �� ����
  ������, ���������� ����� ����� ����������� �� ������ ���������� �����������
  ��������� ���������� ����� ������ �������. ����� ������������� ��
  ���������������, ���� �������, ��� ������ ���������� � �������� �������
  ������� ���������� �������� ������������� ������������� ���� ����
  �������������� �������� ������� ���.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.15.
  </span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>����������� �� ��������� ���� �����������
  ����� ��������� ������/������� �� ��������� �����������, �����������
  ������������ � ���������� ���������� ������� ������������ �� ����������
  ��������, � ������� 3 (����) ������� ���� �� ��� �� ��������� ��
  ������������� � ���������� ��� � �������������� ����������������. ������
  ��������� ������ �������������� - ������������ ������ ������������ �
  ����������� ������� ����� ������������ �������� ������� �� ��������� ����
  �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.16.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>� ����������� ���� �������� ����������� �
  �������� ������������� � ��������� ��������� � ���������� � �����������
  ��������� ����������� � ��������������� ������������� �� ����������
  ��������������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.17.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�������� ����������� � ����� ��������� �������
  ���������� ����� ��� ��� ���� ���������������, ������� � ������ ���������, �
  ������� ����� �������� ������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.18.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>������������� ������������ � �������������
  ������ ���������� ������ � �������, ������������� ��������� �����������, ��
  ������� 30 ���� �� ���� ���������� �������, ��������� � ��������� ������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.19.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>��������������� �������� ����������� � �����
  ������������ ��� ������������ ������������� �������� ������, ������,
  ���������� ����������� ��� ������ ����������� ������������ ����, �������
  ���������� ��� ����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.20.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>����������� � ��������� ����������� � ������
  ���������, ������������ ��������� ���������, ��������� �������� �
  ������������ �����������. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.21.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>������� ���� � ����� ��� ������������
  ���������� �������������� � �������������� ����� �������, ��������� �
  ������������� �����<span class=GramE>..</span><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.22.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='font-size:11.0pt;font-family:"Times New Roman"'>�� ������� 1-��
  �������� ��� ������, ���������� �� ���������� ��������� �������,
  ������������� � ���������� �� �������� ��������� �������������� ������» (<span style='font-size:10.0pt;mso-bidi-font-size:
  11.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";color:windowtext;
  text-decoration:none;text-underline:none'>���������� � 1</span> �
  ���������� ��������) � ���������� � �������������� ��������� ��������������
  ������» (<span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";
  color:windowtext;text-decoration:none;text-underline:none'>���������� � 2</span>
  � ���������� ��������), ������������� ����������� ���������� ������ �
  ���������� ����� ������������ �� ���������� �������� �� �������������
  ������������ � <span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";
  color:windowtext;text-decoration:none;text-underline:none'>�����������</span>
  �� 3, 4, 5 � ���������� �������� �����.</span></span><span lang=RU
  style='font-size:11.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.23.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>������ ������������ �� ���������� ������� �
  ���������� ��������, ��������� <span class=GramE>�</span> �. 2.21., �����,
  ������������ ������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.24.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�������������� �� ���� ������� ������������,
  ���������� ������������. ������������� �������� ������ ������������
  ������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.25.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�� ���������� ���� ����� � ����������� ��
  ���������� �������� ��� ��� ����� ������� �����, � ��� ����� �� ��������� <span
  class=SpellE>������������</span> ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.26.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�� ��������� ����������� �����-���� ���������
  ����������� ���������������, ��������������� ������������ ����������������
  ��, �������� ���������� ��������, �������� ����������� �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.27.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�� ��������� �� ���� ��������������� � �� ������
  ������������� �� ����� �����������, �� ��������������� ��������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.28.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�� ��������� �������� � ��������������
  ������������ � ����� ���������� ��������� ����������� �� ����� �����������,
  ������������� <span class=GramE>�</span> �.1.1. <span class=GramE>����������</span>
  ��������, � ������� ���������� ����������, ���������, ���������� �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.29.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>�� ���������� � �� ������������
  ���������������� � ���������������� ����������, ���������� �� �����������, �
  ����� ������ ���������� � ������������ �����������, ��� ������� ��������� ���
  ������� �� �������������, �� ������������ ������������ ��� �����������, �
  ������� ����� �������� ������� �������� ��� ����� ����, ��� ���� ��� ��������
  �������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l7 level2 lfo1;
  tab-stops:list 19.5pt'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.30.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>� ������� ������ �������� ��� ��������
  ����������� � ����������� � ���������� �� ��������� ���� � �������� ���������������
  ��������������� ��� � ������ � ����� � �������� ��������. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  font-family:"Times New Roman"'>� ������ ��������� ������� ����� �� ���������
  � ��������� ������� ������������ ���������� ����� ����� � �������������
  ������� ����������� ��������� ������� � ����������� ���������� ������� �
  �������, ��������������� ����������� ����������������� ��.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>� ������ ���������� �������� ����� ����� �����:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������
  �� ����������� ���������� � ������������, ����������� ��� ������������� ��
  ��������� <span class=GramE>�</span> �. 1., 2. <span class=GramE>����������</span>
  �������� �������, ������� ������� �����������, ������ ���������-�����, ������
  ������� ���������� � �.�. ����� � �������� ������ ���������� � ������������
  ���������� ����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>���������
  �� ����� � �� ��������� ����������� ���������� �� �������������� ��
  ������������ ������� ����������� �� �����, ��������� <span class=GramE>�</span>
  �. 2. <span class=GramE>����������</span> ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������
  �� ����������� ������������ �� ��������, ��������� � ����������� �������
  ���������� ��������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������
  �� ��������� �� ������ �� ����������� ��������� �������������� � �������,
  ��������� � ���������� �1 � ����������
  ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;tab-stops:42.55pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>� ������ ���������� ��������
  ���������� ����� �����:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������������
  ������������ ������ �� ���������� ������������ �� ���������� ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>��������������
  � �������� ������ ��������, ���������� ������ � ����� ������ ���� ���������,
  � ������ ������������� ������������� ����������� ������� ����������
  ����������, �� �������� ������ ������ ��� ��������� ����������, ������������
  � ��������� �� �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>���
  ������-���� ���������������� ����������� ������:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>���������� ���
  ������������� ������ ������� ���� ����� �� ������������� ����� ��������������
  ������������ �� ����������� �� ����� �����������;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>�������� ���������
  ������ � ������� �����������, �� ��������, ����������� <span class=GramE>�</span>
  �.5.5. <span class=GramE>����������</span> ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>�<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����������
  ������������� ������ ��������� �������������� ��� ��� ����� � ���� ���������
  ������, ����������� ����������� �� ���� ������, � ������� ���������������
  ��������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>�
  ������������� ������� �������� ������ ���������� �������������� �� �����
  ����������� ��������� ����������� (�������) ����� ����������� �����������
  ������. � ������ ���������� ������ � ������ �������� ����������
  �������������� ����� ����� ����� ����������� ��������� �������,
  �������������� �� 10 (������) ������� ���� �������� �� ���� �����������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:14.2pt;text-align:justify;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>� ������ ���������� ��������
  ���������� ������:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������������
  ������ ������������ ��� ������������� ������� �� ����� ����������� �������,
  ��������� � <span class=SpellE>��</span>. 1., 2. ���������� ��������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������������
  ������������ ������ ����� ������������ ����������� � �����������,<span
  style='mso-spacerun:yes'>� </span>������������� ������������ � ������������
  ��� ������������� ������������, ��������������� ��������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>�����������
  ������ ������������� � ������������ � �������� 6 ���������� �������� �
  ����������� �� 1 ��������� ��������������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������������,
  ��� ���������� ����� � ������������ � ����������� ����������������� �����
  ������������ ��������� ������������ �� ���������� �� �� ��������� <span
  class=GramE>�</span> �. 2. <span class=GramE>����������</span> �������� �����
  �����������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.5.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>������������
  ���������� ������ � �������� ���������� � ����������� ������� �����������,
  ��������� ������, ������� ���������� ��������� ����������� � ������
  ���������� ��������� �����������. <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>6.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>������� �� ����������
  ��������.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>��
  ���������� ������������ �� ���������� ��������, ���������� ����������� ������
  ��������������. ������ � ������� ������� �������������� ������� � ����������
  �� �������� ��������� �������������� ������» (���������� � 1 � ����������
  ��������).<span style='background:yellow'> </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�������,
  ���������� ������� � ����� � ����������� ���������� ��������, ��������������
  �� ���� ���������� �������������� � ������������� �� ������������, ����
  ����������� ������ �� ����� ������������� ����.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.3.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='mso-ansi-language:RU'>� ������ ����������� �������� �����������,
  ������������ ��� �������������� ������, �� ����� �������� ��������������
  �������, � ���������� �������� ������������ ������������� ����� � �������
  ���������� ������� ��� ��������������� ������ � ������ ������ ��� �� �������
  �������� <span style='text-transform:uppercase'>�����������</span> ��
  ������������ ������������, <span style='text-transform:uppercase'>����������</span>
  ����� ����� ����������� �� ������ �������� ����������� �� ������� ��������
  ��������� ���������� �������������� � ������ ������.</span></span><span
  lang=RU style='mso-ansi-language:RU'><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.4.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�
  ������ ����������� �������� �����������, ������������ ��� ��������������
  ������, � ���������� ���� ���������� ���������� ������������ ����� ����������
  ��������� ������ � ������ ������, ���������� ����� ����� ����������� ��
  ������ �������� ����������� �� ������� �������� ��������� ����������
  �������������� � ������ ������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:8.5pt;text-align:justify;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-ansi-language:
  RU'>���� ���������� ����� ��������������� ������ ������������ �� ������
  ��������� � ��������� ������ ����, ���������� ������ ����������� �� ���������
  �� ����� ����, ���������� ������� ������ ������������, �� ��� ���, ���� �����
  �������� ���������� �������������� �� ����� ���������� ����������� � ������
  ������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>7.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>����-�����<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�������
  ������������� �� ��������������� �� ������������ ���<span
  style='mso-spacerun:yes'>� </span>������������ ���������� ����� ������������
  �� ���������� ��������, ���� ��� ������� ���������� �������� �������������
  �������������� � ������������� ��������� (����-�����), � ������� ���������
  ��������� ��������, ������, �������������, ���������������� ����, �������
  ��������, �������� ���������� � �. �.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�
  ������������� � ����������� ����� ����������<span class=GramE>��� ��</span>�����
  ������ ���������� ���� ����� ����� ���������<span style='mso-spacerun:yes'>�
  </span>�� �������� � ������� 5 (����) ���� � ������� �� �������������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.3.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>��
  ���������� �������, �� ���������� ����-�������, ������� �������������
  ������������� ���� ������ �������������� ��������� ��������������� �������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>8.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>������������������<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>8.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='mso-ansi-language:RU'>�������</span></span><span lang=RU
  style='mso-ansi-language:RU'> ��� �� �����, ��� � ����� ����������� ��������
  ���������� �������� ��������� �� ���������� ������� ����� ��� �������
  ����������� � ������ ���������� ������ �� ������ ������� �����������
  ��������, ����� ��� ��������, ������� ���������� � ��������, ���������� �
  ����������� �����, ���������, �������� ������������ ���������, ����������
  ����������, �������� ������ � ������� � ���������� ����������, ����������
  �������������, �������� ������������ �����, ��������� �����, ����������, <span
  class=GramE>���������� � ���� �������������� � ��������������� ���-���,
  ���-��� � ������� ����������� ������������, ������� � ������� ��� �������
  ����������� � ������ ���-���, ������� ����� ���� �������� ��������, ��� �
  ������, ��� � ��� ������ ������ ������� ���������� ��������.</span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>8.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�
  ������<span class=GramE>,</span> ���� ����� �� ������ ����� ������� ����� �
  ���������� �������� ������ �������, ������� ������������������ �������
  ������� ��������� � �. 8.1. ����������, ����������� ������� ����� �����
  ����������� �� ������ ������� ���������� �����, ����������� ����������
  ��������� ������� ������������������ � ������� � �������, ���������������
  �����������������. <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><span style='mso-list:Ignore'>9.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>���� �������� ��������. </span></b><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><o:p></o:p></span></p>
  <p class=1 style='margin-left:17.0pt;text-indent:-17.0pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><span style='mso-list:Ignore'>9.1.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'>��������� ������� �������� �� ��������������
  ������ � �������� � ���� � ������� ��� ���������� ���������.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:EN-US;
  layout-grid-mode:line'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>10.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-spacerun:yes'>�</span><b style='mso-bidi-font-weight:
  normal'>�������</b></span><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'> �����������
  ��������</span></b><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt'>.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'><span
  style='mso-spacerun:yes'>�</span>������ �� ������ ������ ���������� �� ����������
  �������� � ������������� ������� � ������������ ���������� ������������
  ������ ������� �� 20 (��������) ����������� ���� �� ���� ���������������
  ����������� ��������. ����������� (������) � ����������� ���������� ��������
  ����� ���� �������� ������ �� ������ (�� ��������� ��� ���������������
  �������������) ����� ��� �������� ��� ������������ �� ����� �������� �������.
  <o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>����
  �� ��������� ������ 60 (�����������) ����������� ���� �������� ����������
  �������� ��� �������������� ������ �� ���� ��������� �� ������ ��������
  �����������, ���������� ������ � ������������� ������� ����������� ���������
  ������� ����� ����������� ����������� ������ �� 7 (����) ����������� ���� ��
  ���� ��������������� ����������� ��������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='mso-ansi-language:RU'>�� ���� ����������� ���������� �������� �������
  ������� ���������� ����� ����� ��� �������������, � ��� ����� ����� ������
  ������� ����������� ��� ���������� �� ���������� ��� ���������� ������������
  �� ���������� �������� ��������� � ��������� � ������������, � �����
  ������������ ����� � ���������� �� �������������� ������ ������� ����������,
  � ����� ��������� ��� �������������, ��������������� ��������� ��������� �
  ����������������� ��.</span></span><span lang=RU style='mso-ansi-language:
  RU'><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�����������
  ���������� �������� ������ �� ����� ����������� ���������<span class=GramE>���
  ��</span>���� �� ���������� ��������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>11.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>���������� ������<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�������
  ����� �������� ������������� ���������� � ���������� �������� �� ����
  ��������� � ������������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>���
  ����� � �����������, ������� ����� ���������� �� ���������� ��������, �����
  �� ����������� �������� ����� ������������ �����������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�
  ������ ������������� �������������� ������ � ����������� ����� �����������,
  ���������� ������ � ����������� ������������ � ������������ � �����������
  ����������������� ���������� ���������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�������
  ��������������, ��� ��� �����, ���������� �� ���������� ��������,
  ����������������� �� ������ �����������, �������� ������������ � �����������
  ���� ������ ������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>12.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>��������������� ������.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in left 42.55pt'><![if !supportLists]><span lang=RU
  style='mso-ansi-language:RU'><span style='mso-list:Ignore'>12.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>��
  ������������ ��������� ���������� �������� ������� ����� ��������������� � ������������
  � ����������� ����������������� ���������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;tab-stops:42.55pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>13.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>�������������� ���������.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='mso-ansi-language:RU'>������� ��������, ��� ��� �� ��������� �
  ����������� ������������ ������ ���������� ��������, ��� ������� ����������
  �������� �� �������� ���������� � ������ ������������ ���������������� ��,
  ��� ������ ������� �� �������� ������ ��� ���������� �������, ��� ������
  ������ �� ������������ ����-���� ���������, ��� ������������� ������
  ��������� � ������� ��� ��� ��������� ��������, ��� ������� �� ���������
  ������ ������� ��� ������ ��� ���������</span></span><span lang=RU
  style='mso-ansi-language:RU'> ������� ������ ������� ���� ������� ���, ���
  ������ ������ �� ��������� ��� �������� ������, ��� ������� ��������
  ��������� ����������� ������������ ����� ������������, ���������� ��
  ���������� ��������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>���
  ���������� � ������� �������� ���������� ��� ��������� � ������������ �����.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>���
  ����������, ���������� � ��������� � ���������� �������� �����
  ��������������� � ����� ����������� ����, ���� ��� ����� ��������� �
  ���������� ����� � ��������� ������ ���������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>��
  ����, ��� �� ������������� ������ ���������, ������� ����� �����������������
  ����������� ����������� ����������������� ���������� ���������.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>���������
  ������� ��������� � 2-� �����������: ���� - ��� �����������, ������ - ���
  ������. ��� ���������� ����� ���������� ����������� ����.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l8 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.6.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>�������
  �������� <span class=SpellE>�����������</span> ���������������� �������
  ����������� ���������.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU>����������� ������ � ��������� ������:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU><o:p>&nbsp;</o:p></span></b></p>
    <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>����������</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>�����</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>
    <%=ORGNAME%>
    </span><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >���������</span></b><span
    style='mso-ansi-language:EN-US'>: <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>
	<span style='mso-ansi-language:EN-US'>
	���: <%=ORGINN%>, ���: <%=ORGKPP%>, �/�: <%=ORGRS%>, � <%=ORGBANK%>, �. ������, ���  <%=ORGBBIC%>,�/�: <%=ORGKORAC%>
    </span>
	</p>   
    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >�����:
    </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=ORGADDR%>
    </span><span
    lang=RU ><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span
    style='mso-ansi-language:EN-US'><%=AGNAME%></span><span lang=RU
    ><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>�������:</b> </span>
    <span style='mso-ansi-language:EN-US'>
    <% if (!PNUM.equals("____________")) {%>
    <% if (!PS.equals("____")) {%>
    �����: <%=PS%> <%}%>
    �����: <%=PNUM%> 
    <% if (!PVIDAN.equals("_____________________________")) {%>
    �����: <%=PVIDAN%> <%}%>
    <% if (!DATAV.equals("__________")) {%>
    ���� ������: <%=DATAV%> <%}%>     
    <%}%>
    </span>
    <span
    lang=RU ><o:p></o:p></span></p>
<p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>	
<% if (!addrProp.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>����� �� ����� ��������: </b></span><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProp%></span>

<b><span
    lang=RU ><o:p></o:p></span></b></p>
<%}%>    	
    <%if (!addrProz.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU
    >����� �� ����� ����������: <span
    style='mso-spacerun:yes'>� </span></span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProz%>
    </span><b><span
    lang=RU ><o:p></o:p></span></b></p>
    <%}%> 
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>
    <%if (!AGINN.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span style='
    mso-ansi-language:EN-US'><%=AGINN%></span><span lang=RU ><o:p></o:p></span></p>
    <%} %> 
    <p></p>
    <%if (!PENS.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >� ����������� �������������: </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=PENS%></span><span
    style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
<%}%>    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='layout-grid-mode:both'><span lang=RU
  style='font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA;layout-grid-mode:line'><br clear=all style='page-break-before:always;
mso-break-type:section-break'>
</span>

<div class=Section2>

<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
  <h2 align=right style='text-align:right;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU><o:p>&nbsp;</o:p></span></h2>
  <h2 align=right style='text-align:right;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU>���������� � 1 � ���������� �������� � <%=AGDOGNUM%></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
    height:4.0pt'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>�. ������</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><%=REG_DATE%><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <h2 style='line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU
  style='mso-bidi-font-size:11.0pt'>��������� �� �������� ��������� ��������������
  �������<o:p></o:p></span></h2>
  <p class=MsoNormal align=center style='text-align:center;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo5;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>����� ���������<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;'><span lang=RU style='mso-ansi-language:RU'>1.1.  ���������
  ��������� �������� ������������ ������ ���������� �������� � <%=AGDOGNUM%><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;'><span lang=RU style='mso-ansi-language:RU'>1.2. ���������
  ��������� �������������� ������� ������� ��������� ���������� ��������������
  (���) ��������� ������� (����� � �����). <o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo5;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>������� ������� ����������
  ��������������</span></b><span lang=RU style='font-size:11.0pt'>. <o:p></o:p></span></p>
  <p class=1 style='margin-left:9.0pt;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt'>2.1. ������ ��������� ���������� ��������������
  ��������������� � ����������� �� ��������� ����������:<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l1 level1 lfo7;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>������� ����������� � ��������� ����������
  ��������� ������ (������) � ������ ���������� ��������������;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l1 level1 lfo7;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>��������� �����������;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo8;tab-stops:14.2pt list .25in 27.0pt .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>������� ������ ��������� ������
  (������������� ��� � ���������);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo8;tab-stops:14.2pt list .25in 27.0pt .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>3.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>������� ������ ��������� ������ (������
  ����������� ���);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo8;tab-stops:14.2pt list .25in 27.0pt .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-fareast-language:EN-US;layout-grid-mode:
  line'><span style='mso-list:Ignore'>4.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-fareast-language:EN-US;layout-grid-mode:line'>����������� ������ ����
  �������� �������� �����������, �� ������� �������� ��������� ������;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-fareast-language:EN-US;layout-grid-mode:line'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt'>2.2. ������ ��������� ���������� ��������������
  ������������ ��� ������������ ������� ������ ��������� ����������
  �������������� (���) �� ����� ��������� ���������� ������������� ������ ��
  �������� �����������, �� �������� ���������� �������� ��������� �����, ��
  ������� ����� ���������������� ��������. <o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt'>2.3. �������� ��������� �������������� ������
  ����������� �� ����������� � ���������� ������������ ������ �� ��������� ����
  ����������� � ������ ������ ��������� ��������� ������ (�������):<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l4 level1 lfo9;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='mso-fareast-language:RU'><span style='mso-list:Ignore'>1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-fareast-language:RU'>������ ��������� ������ (�� �������
  ����� ���������������� ��������);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l4 level1 lfo9;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='mso-fareast-language:RU'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-fareast-language:RU'>��������� �������, ���������� ������
  � �������� ������� (�� ������� ����� ���������������� ��������);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l4 level1 lfo9;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='mso-fareast-language:RU'><span style='mso-list:Ignore'>3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-fareast-language:RU'>���������� � �������� �������
  ������������ ��������� ������� (�� ������� ����� ���������������� ��������). <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.4.
  �� ��������� �����������, ��������� ������ � ������� ������� � ��������
  �����������, ��������� ������ ��������� ���������� ��������� � ������, ����
  �������� �� ����� 99,99% �� ����� ������. ��� ����������� � ��������
  ������������ ��������� ������ ������������ � ������ �� ����� ������������
  ����� ��, �������������� ��� ����������� ������ �� ���� ������
  (������������).&nbsp; ����� ������ ��������� ������ (������) ���������:</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  � ������ ������������ ��������� ������ � ���������� ����� ������������ (������)
  �� ��������� ���� <span style='text-transform:uppercase'>�����������</span> �
  ����, ��������� � ��������� ��������� � �����������;</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  � ������ ������ <span style='text-transform:uppercase'>�������</span> �
  ������������ ��������� ������ � �������������� ������ ������� ����������
  ��������� ����� �7 � ����, ��������� � ��������� ����� �7.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  � ������ ������ ��������� ������ ������������� ����� ���� � ����, ��������� �
  ��������� ��������&nbsp; ������ ����� (����� ��4)</span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-fareast-language:EN-US'>2.5. �������� ��������
  ��������� ������ � 1-�� �� 30 (31-�) ����� ������� ������. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.6.
  ������� ��������� ���������� �������������� ������������ �� ��������� ������
  � ���������� �������� (���������� � 2, 3 � ���������� ��������), �������
  ������������� <span style='text-transform:uppercase'>�������</span> �
  �������������� �����������.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.7.
  ���������� ����������� �������� ��������� �������������� <span
  style='text-transform:uppercase'>������</span> � ������� 5 (����) �������
  ���� � ������� ���������� ������ � ���������� �������� ������ ���������.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.8.
  ������� ����� ����������� � ������ � ���������� �������� ����� ����������� �
  ������� ��������� ���������� ��������������, ������������� �� ���������
  ������� ������ ��������� ���������� ��������������, ��������� �� ���������� �
  ��������� ���������.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:-.25in'><span
  lang=RU>2.9. � ������ ���� ����� ����������� � ������� �� �������� �����
  ���������� �������������� ���������� ����� 300 ������, �� ���������
  �������������� � ������ ��������� �� �������� �� �������������.</span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'>2.10. ��������� ��������������, ������������ ����� ����� ��������� �
  ������ 2.9., ����� ������������� �� ����� 3-� ������� � �� ���������
  ���������� ����� ���������� ������ ��������� ����������� ����� ����������
  ��������������<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  text-indent:42.55pt;line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo5;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt'><span
  style='mso-list:Ignore'>3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt'>������ ���������� �������������� <o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.3. ���
  ������� ��������� ���������� �������������� �� �������� ����������� � �������
  ����� ����� �������� �������� ����������� ����������� ���, ������������� ��
  ������ ���������� �������� ����������� (���� ������ ������������ �� ������
  ��������� �7 ��� ���������� ���������), �� ����������� ������� ��������
  ������������ ���������� �������� �� ������ ������ �������, � ����� ��
  ����������� ������� ��������� ������� ������ �� �� ������� ��������.</span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.4. �������
  ������ ���������� �������������� ������������ ������������. �� ���������
  ������� ������ ���������� �������������� ���������� ���������� <span
  style='text-transform:uppercase'>������</span> �� 10 ���� �� ���������� �
  ������ ���������� ����� ������. ��� �� ��������� �����������, ����������� <span
  style='text-transform:uppercase'>�������</span> �� ���� ���������� �����
  ������ � ����, �������������� �� ������ �������.</span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.5. ������
  ��� ��������������� �������� �� ������ �������� ���������, ��������� �
  �������� �����������. �� �������������� ����������, ��������� � ��������
  �����������, ��������� ����� �� ������, ��� � �� ��������� ��������
  ���������, ����� �������������� ��������� � 1 ������������ �� ����������
  ������� � �������������� ��������� � 7 �������.</span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'>3.6. ����� ����� ����� �� ��������� ��� �� ����������� ��� �� ����������
  ������������ �������� �����������, ������������ ��� �������������� �������
  ������, � ������� ������������ ��� ���������� ��������� �������. � ����
  ������ ����� �������� ��� �� ����������� �� ����� ��������� ���������
  ��������� ������� �� ������ ��� �������� ������ �������� ����������� ��
  ������ ���������� �������������� �� ������ ��� �������� �������� �����������
  ��� ������� ��������� ���������� �������� ����������� � ����� ������.. <o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-fareast-language:EN-US;layout-grid-mode:line'>3.7.
  ��� ������� ��� �� ��������� ��������� ����������� ���������� ����� ����� ���
  ������� ������������ � ������� ��������� ��� � ������� ����, ��� ���������� �
  ��������� ����������, � ��������� ��������� ��� ������� ���� ��������
  �������� ����������� � ������� ������� ���� �������� ������ ��������
  �����������. </span><span lang=RU style='font-size:11.0pt'><o:p></o:p></span></p>
  <p class=1 style='margin-left:9.0pt;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo5;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU><span style='mso-list:Ignore'>4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt'>������� ������� ������ ����������
  ��������������</span></b><span lang=RU style='font-size:11.0pt'>:</span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:RU;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:left;mso-break-type:section-break'>
</span>

<div class=Section3>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=960 valign=top style='width:10.0in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  9.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><a
  name="_����������_�_1.2._���2._������_����"></a><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>4.1. ������ ��������� ���������� ��������������
  �������<o:p></o:p></span></i></b></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.75pt'>
    <td width=73 rowspan=3 style='width:54.4pt;border:solid windowtext 1.0pt;
    border-bottom:solid black 1.0pt;padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>�����������</span>, <span
    class=SpellE>���</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.65pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>��������� </span><span
    class=SpellE><span style='font-size:8.0pt'>����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>�����������</span> <span
    class=SpellE>�����</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.65pt;border:solid windowtext 1.0pt;
    border-right:solid black 1.0pt;padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>��������� ������� � ���������
    �������, ����������� ����� �� ����, ������� � ��������� �������
    (����������� �����)</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.55pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>�������������� ��������� �
    1<span style='mso-spacerun:yes'>� </span>&quot;����������� �� ����������
    �������&quot; � ���������� ���������� ����������� �����, ������� �
    ��������� �������, ����������� ����� �� ����, ������� � ��������� �������
    (����������� �����).</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.5pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>��������� ����������� ��
    ���������� �������</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.5pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>�������������� ��������� � 7 �<span
    class=SpellE>������</span>� � ���������� ���������� ����������� �����,
    ������� � ��������� �������, ����������� ����� �� ����, ������� � ���������
    ������� (����������� �����).<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:12.0pt'>
    <td width=113 colspan=2 style='width:85.1pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>�������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.55pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>��������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>�������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>��������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>�������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>��������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>�������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>��������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>�������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>��������������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>������</span> <span
    class=SpellE>������</span></span><span style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:36.75pt'>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-� <span class=SpellE>���</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>����</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-� <span class=SpellE>���</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>����</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-� <span class=SpellE>���</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>����</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-� <span class=SpellE>���</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>����</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-� <span class=SpellE>���</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>�����������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>����</span></span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1 - 4<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>5<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>6<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>7<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>8<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>9<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>13,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>17,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>3,96%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>19,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>16,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>9,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>4,24%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>21,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>18,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>4,53%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>22,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>19,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>10,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>4,85%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>24,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>21,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>11,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>11,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>11,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>5,19%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>26,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>22,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>5,55%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>28,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>24,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>12,60%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>5,94%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>29,75%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>25,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,20%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>6,36%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>31,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>27,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>13,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>6,80%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:18;height:12.0pt'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    mso-border-right-alt:solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>33,25%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>28,50%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border:none;border-right:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>14,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>14,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>14,40%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>7,28%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:19;mso-yfti-lastrow:yes'>
    <td width=73 style='width:54.4pt;border:solid windowtext 1.0pt;border-top:
    none;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:8.0pt'>������</span></span><span
    style='font-size:8.0pt'> <span class=SpellE>���</span> <span class=SpellE>�����</span>
    20<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>35,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>30,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border:none;border-bottom:
    solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt;font-family:Arial'>5,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.55pt;border:solid windowtext 1.0pt;
    mso-border-top-alt:.5pt;mso-border-left-alt:1.0pt;mso-border-bottom-alt:
    1.0pt;mso-border-right-alt:.5pt;mso-border-color-alt:windowtext;mso-border-style-alt:
    solid;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:none;border-bottom:
    solid windowtext 1.0pt;padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>7,79%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>0,00%<o:p></o:p></span></p>
    </td>
    <td width=57 valign=bottom style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:.75pt .75pt 0in .75pt'>
    <p class=MsoNormal align=right style='text-align:right'><span
    style='font-size:8.0pt;font-family:Arial'>1,96%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:6.75pt'>
    <td width=559 nowrap style='width:419.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:9.0pt'>���������</span></span><span
    style='font-size:9.0pt'> <span class=SpellE>�����������</span><o:p></o:p></span></p>
    </td>
    <td width=364 style='width:272.7pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% �������������� �� ������
    �����, ���������� �������������<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;<span class=SpellE>����</span>&quot;<o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>12,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;height:3.0pt'>
    <td width=559 nowrap valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;<span class=SpellE>��������-������</span>&quot;<o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>15,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:3.0pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>�������� ����������
    ����������� ����� � ��<o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>10,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:3.0pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:9.0pt'>��������</span></span><span
    style='font-size:9.0pt'> <span class=SpellE>��������</span> <span
    class=SpellE>�����������</span> <span class=SpellE>�����</span><o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>11,67%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:3.0pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    class=SpellE><span style='font-size:9.0pt'>��������</span></span><span
    style='font-size:9.0pt'> <span class=SpellE>�����������</span> <span
    class=SpellE>������/���������</span><o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:3.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;mso-yfti-lastrow:yes;height:11.45pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext 1.0pt;mso-border-alt:
    solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>�������� �������� �����������
    ������/���������<o:p></o:p></span></p>
    </td>
    <td width=364 nowrap valign=bottom style='width:272.7pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;
    height:11.45pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:10.0pt;font-family:Arial'>3,33%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  both'><span style='font-size:12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

<b><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span></b>

<div class=Section4>

<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:9.75in'>
  <td class="mainTd">
  <p style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>5. <b style='mso-bidi-font-weight:normal'>��������������
  �� ���������� ��������� �������������� ����������� ����� ����.</b><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>5.1. ���������� ����������� ������
  �������������� �� ������ ������� �������������� ����������� (��������� ����������
  ����������� �����), ����������� ��� ���������� ������� ������ � �����.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>5.2. �������� �������� ��������� ������ � 1-��
  �� 30 (31-�) ����� ������� ������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'>5.3. �������������� ����������� �� �����������
  �� ��������� ���� ����������� � ������ ������ ��������� ��������� ������
  (�������):<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>������ ��������� ������ (�� ������� �����
  ���������������� ��������);<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly;tab-stops:.5in'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>��������� �������, ���������� ������ � ��������
  ������� (�� ������� ����� ���������������� <o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly;tab-stops:.5in'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'> ��������);<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>���������� � �������� ������� ������������ ���������
  ������� (�� ������� �����  <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>���������������� ��������). <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'>5.4. ������ �������������� �� ������ ���
  �������� �������� �������������� ����������� ����� ������������ �� ���������
  �������:<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=373
   style='width:279.7pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 1.5pt 0in 1.5pt;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=94 rowspan=3 style='width:70.4pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>���� �������� �������� ����������� (���)<o:p></o:p></span></p>
    </td>
    <td width=279 style='width:209.3pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>�� ��������� �����������, �����������������
    ������ ��������� ������ � ���������:<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:12.35pt'>
    <td width=279 style='width:209.3pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>% ������ �� ���������� ������ ��<span
    style='mso-spacerun:yes'>� </span>��������� �������������� �����������,
    ����������� ������������� �� ��������������� ��� �������� ��������<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:20.65pt'>
    <td width=279 style='width:209.3pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:20.65pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>1 ��� �������� ��������<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>5-10<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>15,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>11<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>16,51%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>12<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>18,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>13<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>19,51%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>14<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>21,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;height:15.25pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:15.25pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>15<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:15.25pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>22,51%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>16<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>24,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>17<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>25,51%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>18<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>27,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>19<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>28,51%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;mso-yfti-lastrow:yes;height:12.35pt'>
    <td width=94 style='width:70.4pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>������ ��� ����� 20<o:p></o:p></span></p>
    </td>
    <td width=279 valign=bottom style='width:209.3pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>30,00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'>5.5. �� ������ � ����������� ���� �������� ��������
  �����������, ������������������ ������ ��������� ������ � ���������.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='margin-left:28.5pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .5pt;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:
   .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=285 valign=top style='width:213.4pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>��� �������� �������� �����������<o:p></o:p></span></p>
    </td>
    <td width=279 valign=top style='width:209.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>% ������ �� ���������� ������ �� ���������
    �������������� �����������, ����������� ������������� �� ���������������
    ��� �������� ��������<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1'>
    <td width=285 style='width:213.4pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>2<o:p></o:p></span></p>
    </td>
    <td width=279 style='width:209.0pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>10.00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2'>
    <td width=285 style='width:213.4pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>3<o:p></o:p></span></p>
    </td>
    <td width=279 style='width:209.0pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>6.00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
    <td width=285 style='width:213.4pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>4 � ��� �����������<o:p></o:p></span></p>
    </td>
    <td width=279 style='width:209.0pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
    11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
    11.0pt;mso-ansi-language:RU'>3.00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;text-indent:.5in;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>5.6. �� ��������� �����������, �����������������
  ������ ��������� ������ �������������, ������ �������������� ���������� 6.00%<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  text-indent:.5in;line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:
  0in'><span lang=RU>5.7. ������� ���������� �������������� ��<b
  style='mso-bidi-font-weight:normal'> </b>���������� ��������� ��������������
  ����������� ����� ���� ������������ �� ��������� ������ � ���������� ��������
  (���������� � 2, 3 � ���������� ��������), ������� ������������� <span
  style='text-transform:uppercase'>�������</span> � �������������� �����������.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  text-indent:.5in;line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:
  0in'><span lang=RU>5.8. ���������� ����������� �������� ���������
  �������������� <span style='text-transform:uppercase'>������</span> � �������
  5 (����) ������� ���� � ������� ���������� ������ � ���������� ��������
  ������ ���������.</span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";mso-fareast-font-family:"Times New Roman";mso-ansi-language:
RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section5>

<table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:485.25pt'>
  <td class="mainTd">
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <h2 align=right style='text-align:right'><a name="_����������_�_4"></a><span
  lang=RU>���������� � 2 � ���������� �������� � <%=AGDOGNUM%></span></h2>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l1 level1 lfo9;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>��������� ���������� �������� ������������ ������ ����������
  �������� � <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l1 level1 lfo9;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>��������� ���������� ������������� ����� ������
  ������ � ���������� ��������, �� ��������� �������� ������������� ��������
  ��������� ��������������. <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>����� ������
  � ���-__<o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'>� ���������� �������� � <%=AGDOGNUM%><o:p></o:p></span></b></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
    height:4.0pt'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>�. ������</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><%=REG_DATE%><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>�� ������ �
  &lt;����&gt; �� &lt;����&gt; <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-tab-count:1'>����������� </span> <%=ORGNAME%>, ��������� �
  ���������� ����������, � ���� <%=CHIEF_NAME%>,
  ������������ �� ��������� ������������ � <%=PNUM_DOC_DIR%> ������� <%=DATAV_DOC_DIR%>, � ����� �������,
  � <%=AGENT_NAME_INS%>, �������
  �����<span style='mso-spacerun:yes'>� </span><%=PS%> � </span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=PNUM%> ,�����: <%=PVIDAN%>, 
  ���� ������ <%=DATAV%>
  ���������(<span class=SpellE>��</span>) � ���������� �����, � ������ �������,
  ��������� � ��������� ��������� ����� � ���������� ���������� �
  �������������:<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'>1. �� ������ � &lt;����&gt; �� &lt;����&gt; ���
  �������������� ������ ���� ��������� ��������� �������� �����������, ��
  ������� �� ��������� ���� ����������� ��������� ��������� ������ � ������
  ������:<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>����� ��������
      <o:p></o:p></span></b></p>    </td>
    <td width=20% style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>������������<o:p></o:p></span></b></p>    </td>
    <td width=20% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��������� �����������
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>������������ ��� ��������
    ��������
          <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>���� ������
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>���������� ���������
    ������, ���.
          <o:p></o:p></span></b></p>    </td>
    </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border:none;border-bottom:
    solid windowtext 1.0pt;border-left:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;bomso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    </tr>
  </table>
  </div>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'>2. �������� ��������� �������������� �� �������� ������
  ����������: ________. ������ ���������� �������������� ����������� �
  ���������� ������.<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>����������</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>�����</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>
    <%=ORGNAME%>
    </span><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >���������</span></b><span
    style='mso-ansi-language:EN-US'>: <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>
	<span style='mso-ansi-language:EN-US'>
	���: <%=ORGINN%>, ���: <%=ORGKPP%>, �/�: <%=ORGRS%>, � <%=ORGBANK%>, �. ������, ���  <%=ORGBBIC%>,�/�: <%=ORGKORAC%>
    </span>
	</p>   
    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >�����:
    </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=ORGADDR%>
    </span><span
    lang=RU ><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span
    style='mso-ansi-language:EN-US'><%=AGNAME%></span><span lang=RU
    ><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>�������:</b> </span>
    <span style='mso-ansi-language:EN-US'>
    <% if (!PNUM.equals("____________")) {%>
    <% if (!PS.equals("____")) {%>
    �����: <%=PS%> <%}%>
    �����: <%=PNUM%> 
    <% if (!PVIDAN.equals("_____________________________")) {%>
    �����: <%=PVIDAN%> <%}%>
    <% if (!DATAV.equals("__________")) {%>
    ���� ������: <%=DATAV%> <%}%>     
    <%}%>
    </span>
    <span
    lang=RU ><o:p></o:p></span></p>
<p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>	
<% if (!addrProp.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>����� �� ����� ��������: </b></span><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProp%></span>

<b><span
    lang=RU ><o:p></o:p></span></b></p>
<%}%>    	
    <%if (!addrProz.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU
    >����� �� ����� ����������: <span
    style='mso-spacerun:yes'>� </span></span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProz%>
    </span><b><span
    lang=RU ><o:p></o:p></span></b></p>
    <%}%> 
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>
    <%if (!AGINN.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span style='
    mso-ansi-language:EN-US'><%=AGINN%></span><span lang=RU ><o:p></o:p></span></p>
    <%} %> 
    <p></p>
    <%if (!PENS.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >� ����������� �������������: </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=PENS%></span><span
    style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
<%}%>    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  <span lang=RU style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:
  "Times New Roman CYR";mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
  AR-SA'><br clear=all style='mso-special-character:line-break;page-break-before:
  always'>
  </span>
  <h2 align=right style='text-align:right'><span lang=RU style='mso-bidi-font-size:
  11.0pt'><o:p>&nbsp;</o:p></span></h2>
  </td>
 </tr>
</table>

</div>

<b><span style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:"Times New Roman CYR";
mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br
clear=all style='page-break-before:always;mso-break-type:section-break'>
</span></b>

<div class=Section6>

<table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:703.5pt'>
  <td class="mainTd">
  <h2 align=right style='text-align:right'><span style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></h2>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  <h2 align=right style='text-align:right'><span lang=RU>���������� � 3<span
  style='mso-spacerun:yes'>� </span>� ���������� �������� � <%=AGDOGNUM%></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l6 level1 lfo10;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>��������� ���������� �������� ������������ ������
  ���������� �������� � <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <ol style='margin-top:0in' start=2 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l6 level1 lfo10;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='mso-ansi-language:RU'>��������� ���������� �������������
       ����� ������� ��������� ���������� ��������������.</span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'><o:p></o:p></span></li>
  </ol>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>������ ���������
  ���������� �������������� � ������ <span style='text-transform:uppercase'>������</span>
  �� &lt;����&gt; � ���������� �������� <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>��������
  ��������� �������������� ������������� � ������������ � ��������� ����������
  �������� � <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:
  .25in;mso-list:l5 level1 lfo11;tab-stops:list 0in .5in;mso-layout-grid-align:
  none;text-autospace:none'><![if !supportLists]><span lang=RU
  style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
  mso-ansi-language:RU'><span style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>�� ������ �
  &lt;����&gt; �� &lt;����&gt; �����, ������� �� ��������� ������ ������
  __________________________________, �������� �������� ���������
  �������������� �� ��������� �������� �����������, ����������� � ����������
  ���������� ������� ������������ �� ���������� ��������:<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>����� ��������
      <o:p></o:p></span></b></p>
    </td>
    <td width=20% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>������������<o:p></o:p></span></b></p>
    </td>
    <td width=20% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��������� �����������
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>������������ ��� ��������
    ��������
          <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>���� ������
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>���������� ���������
    ������, ���.
          <o:p></o:p></span></b></p>
    </td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��������� ��������������<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>� % �� ������
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>� ������<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p>
    </span></p>
    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=10% valign=bottom style='border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
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
  <p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:
  .25in;mso-list:l5 level1 lfo11;tab-stops:list 0in .5in;mso-layout-grid-align:
  none;text-autospace:none'><![if !supportLists]><span lang=RU
  style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
  mso-ansi-language:RU'><span style='mso-list:Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>�� ������ �
  &lt;����&gt; �� &lt;����&gt; ���� ����������� ��������� �������� �����������,
  ����������� <span style='text-transform:uppercase'>������������</span> ���
  �������������� <span style='text-transform:uppercase'>������</span>. �
  ������������ � �. 2.24., 6.3., 6.4. ���������� ��������, ����� ����������
  �������������� �� ���� ��������� �������� �� ���������� �������������� ������
  � ������������ � ��������, ����������� ����.<o:p></o:p></span></p>
  
 
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>����� ��������
      <o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>������������<o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��������� �����������
      <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��� �������� �������� �� ������ �����������
          <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'> ����� ������������ �� �������� ���������� ��������������
      <o:p></o:p></span></b></p></td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>��������� ��������������<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>� % �� ����� ������������ ��
      <o:p></o:p></span></b></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>� ������<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span><span lang=RU style='mso-ansi-language:RU'>
      <o:p>&nbsp;</o:p>
    </span></p>    
    </td>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>    </td>
   </tr>
  </table>
  
  
  </div>
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <ol style='margin-top:0in' start=3 type=1>
   <li class=MsoNormal style='mso-list:l5 level1 lfo11;tab-stops:list .5in;
       mso-layout-grid-align:none;text-autospace:none'><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>����� ������ ���������� �������������� �� ������ �
       &lt;����&gt; �� &lt;����&gt; ����������: </span><span lang=RU
       style='mso-ansi-language:RU'>&lt;����� �� </span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>�. 1</span><span lang=RU style='mso-ansi-language:
       RU'>&gt;</span><span lang=RU style='font-family:"Times New Roman CYR";
       mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'> - </span><span
       lang=RU style='mso-ansi-language:RU'>&lt;����� �� </span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>�. 2</span><span lang=RU style='mso-ansi-language:
       RU'>&gt;</span><span lang=RU style='font-family:"Times New Roman CYR";
       mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'> = </span><span
       lang=RU style='mso-ansi-language:RU'>&lt;�����&gt;.</span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'><o:p></o:p></span></li>
   <li class=MsoNormal style='mso-list:l5 level1 lfo11;tab-stops:list .5in;
       mso-layout-grid-align:none;text-autospace:none'><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>����� ���������� ��������������, ��������� � �. 3.,
       ���������� ���������.<o:p></o:p></span></li>
  </ol>
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>����������</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>�����</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>
    <%=ORGNAME%>
    </span><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >���������</span></b><span
    style='mso-ansi-language:EN-US'>: <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>
	<span style='mso-ansi-language:EN-US'>
	���: <%=ORGINN%>, ���: <%=ORGKPP%>, �/�: <%=ORGRS%>, � <%=ORGBANK%>, �. ������, ���  <%=ORGBBIC%>,�/�: <%=ORGKORAC%>
    </span>
	</p>   
    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >�����:
    </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=ORGADDR%>
    </span><span
    lang=RU ><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:71.6pt'>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span
    style='mso-ansi-language:EN-US'><%=AGNAME%></span><span lang=RU
    ><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>�������:</b> </span>
    <span style='mso-ansi-language:EN-US'>
    <% if (!PNUM.equals("____________")) {%>
    <% if (!PS.equals("____")) {%>
    �����: <%=PS%> <%}%>
    �����: <%=PNUM%> 
    <% if (!PVIDAN.equals("_____________________________")) {%>
    �����: <%=PVIDAN%> <%}%>
    <% if (!DATAV.equals("__________")) {%>
    ���� ������: <%=DATAV%> <%}%>     
    <%}%>
    </span>
    <span
    lang=RU ><o:p></o:p></span></p>
<p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>	
<% if (!addrProp.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>����� �� ����� ��������: </b></span><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProp%></span>

<b><span
    lang=RU ><o:p></o:p></span></b></p>
<%}%>    	
    <%if (!addrProz.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU
    >����� �� ����� ����������: <span
    style='mso-spacerun:yes'>� </span></span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProz%>
    </span><b><span
    lang=RU ><o:p></o:p></span></b></p>
    <%}%> 
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>
    <%if (!AGINN.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >���: </span></b><span style='
    mso-ansi-language:EN-US'><%=AGINN%></span><span lang=RU ><o:p></o:p></span></p>
    <%} %> 
    <p></p>
    <%if (!PENS.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >� ����������� �������������: </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=PENS%></span><span
    style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
<%}%>    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
 
  </td>
 </tr>
</table>
</div>
</rw:foreach>
</body>

</html>

</rw:report>

<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report">



<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dops_pobul_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOPS_POBUL_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CONTRACT_ID" datatype="character" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[SELECT ach.agent_id, ach.ag_contract_header_id,
       c.NAME || ' ' || c.first_name || ' ' || c.middle_name agent_name,
       NVL (c.instrumental, c.NAME || ' ' || c.first_name || ' ' || c.middle_name ) agent_name_instrumental,
       dept_exe.contact_id dir_contact_id,
       NVL(pkg_contact.get_address_name(pkg_contact.get_primary_address (ach.agent_id)),'@') addr,
       decode(nvl(lower(vtt.description),'г-н'),'г-н','г-на','г-жа','г-жи',lower(vtt.description)) g_n,   
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || ach.num num,
       ach.date_begin dog_date
  FROM ven_ag_contract_header ach JOIN ven_ag_contract ac
       ON (ac.ag_contract_id = ach.last_ver_id)
       JOIN ven_contact c ON c.contact_id = ach.agent_id
       LEFT OUTER JOIN ven_department dep ON (ach.agency_id = dep.department_id)
       LEFT OUTER JOIN ven_dept_executive dept_exe ON (ach.agency_id = dept_exe.department_id)
       LEFT OUTER JOIN ven_cn_person vcp ON (dept_exe.contact_id = vcp.contact_id)
       LEFT OUTER JOIN VEN_T_TITLE vtt ON (vcp.title = vtt.ID)       
 WHERE ach.ag_contract_header_id = :p_ch_id;]]>
      </select>
      <displayInfo x="1.94800" y="1.38538" width="1.18738" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.59741" y="2.01038" width="1.81714" height="2.82324"
        />
        <dataItem name="G_N" datatype="vchar2" columnOrder="49" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="G N">
          <dataDescriptor expression="G_N" descriptiveExpression="G_N"
           order="7" width="255"/>
        </dataItem>
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="21" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="5"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="8" width="4000"/>
        </dataItem>
        <dataItem name="AGENT_NAME_INSTRUMENTAL" datatype="vchar2"
         columnOrder="19" width="602" defaultWidth="100000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Agent Name Instrumental">
          <dataDescriptor expression="AGENT_NAME_INSTRUMENTAL"
           descriptiveExpression="AGENT_NAME_INSTRUMENTAL" order="4"
           width="602"/>
        </dataItem>
        <dataItem name="dog_date" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dog Date">
          <dataDescriptor expression="DOG_DATE"
           descriptiveExpression="DOG_DATE" order="10" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="17" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="NUM" descriptiveExpression="NUM"
           order="9" width="201"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="16"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="AGENT_ID"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="ag_contract_header_id" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="agent_name" datatype="vchar2" columnOrder="14"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name">
          <dataDescriptor expression="AGENT_NAME"
           descriptiveExpression="AGENT_NAME" order="3" width="602"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="15" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor expression="ADDR" descriptiveExpression="ADDR"
           order="6" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[select org.COMPANY_TYPE||' '|| org.COMPANY_NAME COMPANY_NAME, org.CHIEF_NAME, org.INN, org.KPP, org.ACCOUNT_NUMBER, 
org.BANK_COMPANY_TYPE||' "'||org.BANK_NAME||'"' bank, org.B_BIC, org.B_KOR_ACCOUNT, org.LEGAL_ADDRESS
   from v_company_info org
]]>
      </select>
      <displayInfo x="0.40637" y="0.09375" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.12366" y="0.65625" width="1.28259" height="1.79785"
        />
        <dataItem name="CHIEF_NAME" datatype="vchar2" columnOrder="30"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.CHIEF_NAME"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="22"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.COMPANY_TYPE || &apos; &apos; || org.COMPANY_NAME"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="23" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.INN" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="24" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.KPP" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="25"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.ACCOUNT_NUMBER"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="26" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.BANK_COMPANY_TYPE || &apos; &quot;&apos; || org.BANK_NAME || &apos;&quot;&apos;"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="27" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.B_BIC" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="28"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.B_KOR_ACCOUNT"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="29"
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
        <dataItem name="pref" datatype="vchar2" columnOrder="33"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="32"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="31" width="4000"
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
     AND UPPER (tit.brief) IN ('PASS_RF','OGRN' ,'REG_SVID','INN','PENS')]]>
      </select>
      <displayInfo x="5.18738" y="0.20837" width="0.69995" height="0.32996"/>
      <group name="G_AG_DOCS">
        <displayInfo x="5.05591" y="0.90845" width="1.37964" height="1.28516"
        />
        <dataItem name="data_v" datatype="vchar2" columnOrder="39"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <xmlSettings xmlTag="DATA_V1"/>
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="35"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <xmlSettings xmlTag="DOC_DESC1"/>
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="36" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="37" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="38" width="255"
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
      <![CDATA[SELECT   c.contract_id, c.num vn, c.date_begin
    FROM ven_ag_contract c
   WHERE c.AG_CONTRACT_ID = :P_CONTRACT_ID]]>
      </select>
      <displayInfo x="4.16675" y="4.11462" width="0.69995" height="0.32983"/>
      <group name="G_DOPS">
        <displayInfo x="3.91028" y="4.81458" width="1.21301" height="0.77246"
        />
        <dataItem name="contract_id" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contract Id">
          <dataDescriptor expression="c.contract_id"
           descriptiveExpression="CONTRACT_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="vn" datatype="vchar2" columnOrder="41" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Vn">
          <dataDescriptor expression="c.num" descriptiveExpression="VN"
           order="2" width="100"/>
        </dataItem>
        <dataItem name="date_begin" datatype="date" oracleDatatype="date"
         columnOrder="42" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="c.date_begin"
           descriptiveExpression="DATE_BEGIN" order="3" width="9"/>
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
     AND UPPER (tit.brief) IN ('TRUST')   
]]>
      </select>
      <displayInfo x="5.20825" y="2.56250" width="1.18762" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="5.18103" y="3.17908" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID1" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="44"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser1" datatype="vchar2" columnOrder="45" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser1">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num1" datatype="vchar2" columnOrder="46" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num1">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan1" datatype="vchar2" columnOrder="47"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pvidan1">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v1" datatype="vchar2" columnOrder="48"
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
    <link name="L_3" parentGroup="G_AGENT"
     parentColumn="ag_contract_header_id" childQuery="Q_DOPS"
     childColumn="contract_id" condition="eq" sqlClause="where"/>
    <link name="L_4" parentGroup="G_AGENT" parentColumn="DIR_CONTACT_ID"
     childQuery="Q_DIR_DOCS" childColumn="CONTACT_ID1" condition="eq"
     sqlClause="where"/>
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
<title>Дополнительное соглашение на ПБОЮЛ </title>
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:PartnerCondensed;
	mso-font-alt:"Courier New";
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:515 0 0 0 5 0;}
@font-face
	{font-family:"MS Sans Serif";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
h1
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	mso-outline-level:1;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:PartnerCondensed;
	font-variant:small-caps;
	mso-font-kerning:14.0pt;
	mso-ansi-language:RU;
	mso-bidi-font-weight:normal;}
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
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:70.85pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	layout-grid-mode:line;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.25in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	layout-grid-mode:line;}
p.MsoBodyText2, li.MsoBodyText2, div.MsoBodyText2
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:0in;
	line-height:200%;
	mso-pagination:widow-orphan;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
p.MsoBodyTextIndent2, li.MsoBodyTextIndent2, div.MsoBodyTextIndent2
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.25in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;
	text-underline:single;}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:26.6pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:-19.5pt;
	mso-pagination:widow-orphan;
	mso-list:l25 level1 lfo1;
	tab-stops:14.2pt list 26.6pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;}
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
	font-size:16.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	layout-grid-mode:line;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
 /* Page Definitions */
 @page
	{}
@page Section1
	{size:595.35pt 842.0pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:0in;
	mso-footer-margin:0in;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:2635175;
	mso-list-template-ids:-3651454;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l0:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l0:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l0:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l0:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l0:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l0:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l0:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l0:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l1
	{mso-list-id:165364206;
	mso-list-type:simple;
	mso-list-template-ids:68747283;}
@list l1:level1
	{mso-level-number-format:roman-upper;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.5in;}
@list l2
	{mso-list-id:218714086;
	mso-list-type:hybrid;
	mso-list-template-ids:-159220304 68747279 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l2:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l3
	{mso-list-id:408037197;
	mso-list-template-ids:-407360284;}
@list l3:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l3:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l3:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l3:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l3:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l3:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l3:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l3:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l3:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l4
	{mso-list-id:531579270;
	mso-list-template-ids:-407360284;}
@list l4:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l4:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l4:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l4:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l4:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l4:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l4:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l4:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l4:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l5
	{mso-list-id:573394896;
	mso-list-template-ids:-1480055962;}
@list l5:level1
	{mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l5:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.55in;
	mso-level-number-position:left;
	margin-left:.55in;
	text-indent:-.3in;}
@list l5:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:.85in;
	text-indent:-.35in;}
@list l5:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l5:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l5:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l5:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l5:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l5:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l6
	{mso-list-id:617567664;
	mso-list-template-ids:486596930;}
@list l6:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l6:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l6:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l6:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l6:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l6:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l6:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l6:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l6:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l7
	{mso-list-id:620645390;
	mso-list-type:hybrid;
	mso-list-template-ids:154588306 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l7:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l7:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l7:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8
	{mso-list-id:664166696;
	mso-list-template-ids:866266076;}
@list l8:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l8:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l8:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9
	{mso-list-id:742677824;
	mso-list-type:hybrid;
	mso-list-template-ids:836128414 -674082962 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l9:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10
	{mso-list-id:757676774;
	mso-list-type:hybrid;
	mso-list-template-ids:1966786994 68747265 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l10:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l11
	{mso-list-id:847060416;
	mso-list-template-ids:384696802;}
@list l11:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l11:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l11:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l11:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l11:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l11:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l11:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l11:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l11:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l12
	{mso-list-id:850604624;
	mso-list-template-ids:866266076;}
@list l12:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l12:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l12:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13
	{mso-list-id:853615671;
	mso-list-template-ids:71625110;}
@list l13:level1
	{mso-level-start-at:2;
	mso-level-legal-format:yes;
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l13:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l13:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l13:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l13:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l13:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l13:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l13:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l13:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l14
	{mso-list-id:899904612;
	mso-list-template-ids:-510507766;}
@list l14:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	font-family:Symbol;}
@list l14:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.55in;
	mso-level-number-position:left;
	margin-left:.55in;
	text-indent:-.3in;}
@list l14:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:.85in;
	text-indent:-.35in;}
@list l14:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l14:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l14:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l14:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l14:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l14:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l15
	{mso-list-id:985664687;
	mso-list-type:hybrid;
	mso-list-template-ids:1267658024 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l15:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l16
	{mso-list-id:997735389;
	mso-list-type:hybrid;
	mso-list-template-ids:2113950864 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l16:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.25in;
	font-family:Symbol;}
@list l17
	{mso-list-id:1009600428;
	mso-list-type:hybrid;
	mso-list-template-ids:-1704540548 68747265 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l17:level1
	{mso-level-number-format:roman-upper;
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.5in;}
@list l17:level2
	{mso-level-start-at:2;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:79.5pt;
	mso-level-number-position:left;
	margin-left:79.5pt;
	text-indent:-25.5pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
@list l17:level3
	{mso-level-tab-stop:117.0pt;
	mso-level-number-position:left;
	margin-left:117.0pt;
	text-indent:-.25in;}
@list l18
	{mso-list-id:1109161031;
	mso-list-type:hybrid;
	mso-list-template-ids:694969928 1042023610 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l18:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l19
	{mso-list-id:1136070635;
	mso-list-type:hybrid;
	mso-list-template-ids:-719189454 67698703 67698713 67698715 67698703 67698713 67698715 67698703 67698713 67698715;}
@list l19:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l20
	{mso-list-id:1176455120;
	mso-list-template-ids:1350309968;}
@list l20:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l20:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l20:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l20:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l20:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l20:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l20:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l20:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l20:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l21
	{mso-list-id:1178689992;
	mso-list-type:hybrid;
	mso-list-template-ids:-65253034 67698703 67698713 67698715 67698703 67698713 67698715 67698703 67698713 67698715;}
@list l21:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l22
	{mso-list-id:1193764264;
	mso-list-template-ids:-407360284;}
@list l22:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l22:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l22:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l22:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l22:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l22:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l22:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l22:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l22:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l23
	{mso-list-id:1197504084;
	mso-list-template-ids:-407360284;}
@list l23:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l23:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l23:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l23:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l23:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l23:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l23:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l23:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l23:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l24
	{mso-list-id:1255742528;
	mso-list-type:hybrid;
	mso-list-template-ids:866266076 -1 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l24:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l24:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l24:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l25
	{mso-list-id:1354503029;
	mso-list-template-ids:-1487609610;}
@list l25:level1
	{mso-level-start-at:2;
	mso-level-style-link:Обычный1;
	mso-level-legal-format:yes;
	mso-level-tab-stop:26.6pt;
	mso-level-number-position:left;
	margin-left:26.6pt;
	text-indent:-19.5pt;}
@list l25:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l25:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l25:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l25:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l25:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l25:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l25:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l25:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l26
	{mso-list-id:1481726740;
	mso-list-type:hybrid;
	mso-list-template-ids:-773847814 -1 -1 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l26:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l26:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l26:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l26:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l27
	{mso-list-id:1485388239;
	mso-list-type:hybrid;
	mso-list-template-ids:-375456936 68747265 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l27:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l28
	{mso-list-id:1520662145;
	mso-list-type:hybrid;
	mso-list-template-ids:576482732 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l28:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l28:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l28:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l29
	{mso-list-id:1736127240;
	mso-list-template-ids:1441428514;}
@list l29:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	font-family:Symbol;}
@list l29:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l29:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l29:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l29:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l29:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l29:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l29:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l29:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l30
	{mso-list-id:1738093076;
	mso-list-type:hybrid;
	mso-list-template-ids:-1257729588 -1 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l30:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l30:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l30:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l31
	{mso-list-id:1791243288;
	mso-list-template-ids:1377980568;}
@list l31:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:25.1pt;
	mso-level-number-position:left;
	margin-left:25.1pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l31:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l31:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l31:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l31:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l31:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l31:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l31:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l31:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l32
	{mso-list-id:1943760649;
	mso-list-template-ids:1441428514;}
@list l32:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	font-family:Symbol;}
@list l32:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l32:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l32:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l32:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l32:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l32:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l32:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l32:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l33
	{mso-list-id:2069717456;
	mso-list-template-ids:-585831966;}
@list l33:level1
	{mso-level-start-at:6;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l33:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.55in;
	mso-level-number-position:left;
	margin-left:.55in;
	text-indent:-.3in;}
@list l33:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:.85in;
	text-indent:-.35in;}
@list l33:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l33:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l33:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l33:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l33:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l33:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l34
	{mso-list-id:2088073523;
	mso-list-template-ids:866266076;}
@list l34:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l34:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l34:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35
	{mso-list-id:2108187082;
	mso-list-type:hybrid;
	mso-list-template-ids:-1164004568 -1 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l35:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l35:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l35:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l25:level1 lfo10
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

/*POBUL INFO*/
String POBUL_SER = new String();
String POBUL_NUM = new String();
String POBUL_VIDAN = new String();
String OGRN_NUM = new String();
String OGRN_DATE = new String();
String OGRN_VIDAN = new String();
String SVID_STR = new String();

String PNUM_DOC_DIR = new String("____________");
String DATAV_DOC_DIR = new String("__________");
String G_N_OBR = new String("");

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

<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'>
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
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="DOGDATE" src="DOG_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="DIR_NAME" src="DIR_NAME"/>
<rw:getValue id="G_N" src="G_N"/>
<rw:getValue id="AGENT_NAME_INSTRUMENTAL" src="AGENT_NAME_INSTRUMENTAL"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:foreach id="agdop" src="G_DOPS">
<rw:getValue id="VER_NT" src="VN"/>
<rw:getValue id="DATE_BEGINT" src="DATE_BEGIN" formatMask="DD.MM.YYYY" />
<% AGDOPSNUM = VER_NT; 
   G_N_OBR = G_N;
   CHIEF_NAME = DIR_NAME;
   DATE_BEGIN = DATE_BEGINT;
   if (AGADDR.equals("@")) AGADDR = "_______________________________________________";
%>
</rw:foreach>

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


    PS = P_SER;
    PNUM = P_NUM;
    PVIDAN = P_VIDAN;
    DATAV = DATA_V;
  
}
if (docBrief.equals("REG_SVID")) { %>
<rw:getValue id="POBUL_S" src="P_SER"/>
<rw:getValue id="POBUL_N" src="P_NUM"/>
<rw:getValue id="POBUL_V" src="PVIDAN"/>
<%
POBUL_SER = POBUL_S;
POBUL_NUM = POBUL_N;
POBUL_VIDAN = POBUL_V;

}%>
<% if (docBrief.equals("OGRN")) { %>
<rw:getValue id="OGRN_N" src="P_NUM"/>
<rw:getValue id="OGRN_D" src="DATA_V"/>
<rw:getValue id="OGRN_V" src="PVIDAN"/>
<%
OGRN_NUM = OGRN_N;
OGRN_DATE = OGRN_D;
OGRN_VIDAN = OGRN_V;

}
if (docBrief.equals("INN")) { %>
<rw:getValue id="INN_NUM" src="P_NUM"/>
<%AGINN = INN_NUM;}%>
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

if (OGRN_NUM.equals("")) {
     OGRN_NUM  = "______________";
     OGRN_VIDAN = "_____________________________";
  
} else {
  if (OGRN_NUM.equals("@")) 
      OGRN_NUM = "______________";
    if (OGRN_VIDAN.equals("@")) 
     OGRN_VIDAN = "_____________________________";
    }
  
if (POBUL_NUM.equals("")) {
     POBUL_SER = "_______";
     POBUL_NUM  = "______________";
     POBUL_VIDAN = "_____________________________";
  
} else {
  if (POBUL_SER.equals("@")) 
    POBUL_SER  =  "_______";
  else
    SVID_STR = "Серия ".concat(POBUL_SER);
  
  if (POBUL_NUM.equals("@")) 
        POBUL_NUM = "______________";
  else
       SVID_STR = SVID_STR.concat(" Номер ".concat(POBUL_NUM));
      
  if (POBUL_VIDAN.equals("@")) 
    POBUL_VIDAN = "_____________________________";
  else
    SVID_STR = SVID_STR.concat(" Выдано ".concat(POBUL_VIDAN));
    }

%>

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
<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=697 valign=top style='width:500.4pt;padding:0in 5.4pt 0in 5.4pt'>
<p class=MsoNormal align=center style='text-align:center;tab-stops:421.65pt'><b
style='mso-bidi-font-weight:normal'><span lang=RU>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ № </span></b><b
style='mso-bidi-font-weight:normal'><span style='mso-ansi-language:EN-US'><%=AGDOPSNUM%></span></b><b
style='mso-bidi-font-weight:normal'><span lang=RU style='mso-fareast-font-family:
"Arial Unicode MS"'><o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;tab-stops:172.65pt 255.65pt 338.65pt 421.65pt'><b
style='mso-bidi-font-weight:normal'><span lang=RU style='mso-fareast-font-family:
"Arial Unicode MS"'><o:p>&nbsp;</o:p></span></b></p>

<h1><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:
"Times New Roman";font-variant:normal !important;text-transform:uppercase'>К
АГЕНТСКОМУ ДОГОВОРУ № <span style='mso-spacerun:yes'> </span></span><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
font-variant:normal !important;text-transform:uppercase;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
mso-fareast-font-family:"Arial Unicode MS";font-variant:normal !important;
text-transform:uppercase'><o:p></o:p></span></h1>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=344 valign=top style='width:257.7pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;margin-bottom:
  0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;tab-stops:467.8pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width=316 valign=top style='width:236.75pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;text-align:
  right;tab-stops:467.8pt'><span style='font-size:11.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US;font-weight:normal'><%=DATE_BEGIN%></span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in'><span
lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>Общество с
ограниченной ответственностью </span><span style='font-size:11.0pt;font-family:
"Times New Roman";mso-ansi-language:EN-US'><%=ORGNAME%></span><span lang=RU
style='font-size:11.0pt;font-family:"Times New Roman"'>, именуемое в дальнейшем
СТРАХОВЩИК, в лице <%=G_N_OBR%> </span><span style='font-size:11.0pt;font-family:"Times New Roman";
mso-ansi-language:EN-US'><%=CHIEF_NAME%></span><span
lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>, действующего
на основании Доверенности № <%=PNUM_DOC_DIR%>, выданной <%=DATAV_DOC_DIR%>, с одной
стороны, и <span style='mso-spacerun:yes'> </span></span><span
style='font-size:11.0pt;font-family:"Times New Roman";mso-ansi-language:EN-US'><%=AGNAME%></span><span
lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>, паспорт
серии<span style='mso-spacerun:yes'>  </span><%=PS%> №<span
style='mso-spacerun:yes'>  </span></span><span style='font-size:11.0pt;
font-family:"Times New Roman";mso-ansi-language:EN-US'><%=PNUM%></span><span
lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>, выдан<span
style='mso-spacerun:yes'>  </span></span><span style='font-size:11.0pt;
font-family:"Times New Roman";mso-ansi-language:EN-US'><%=PVIDAN%></span><span
lang=RU style='font-size:11.0pt;font-family:"Times New Roman"'>,<span
style='mso-spacerun:yes'>  </span>именуемый(ая) в дальнейшем «АГЕНТ», с другой
стороны, составили и утвердили настоящее Дополнительное Соглашение к Агентскому
договору о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:.5in;text-indent:-.5in;mso-list:l1 level1 lfo2;
tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:11.0pt'><span
style='mso-list:Ignore'>I.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>С<span
style='mso-spacerun:yes'>  </span></span><span style='font-size:11.0pt;
mso-ansi-language:EN-US'><%=DATE_BEGIN%></span><span style='font-size:11.0pt'> <span
lang=RU>в Агентский Договор № </span></span><span style='font-size:11.0pt;
mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span lang=RU style='font-size:11.0pt'>
вносятся следующие изменения.<o:p></o:p></span></p>

<p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:14.2pt'><span
lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoBodyText><span style='mso-bidi-font-size:11.0pt;mso-ansi-language:
EN-US'>I</span><span lang=RU style='mso-bidi-font-size:11.0pt'>.</span><span
style='mso-bidi-font-size:11.0pt;mso-ansi-language:EN-US'>I</span><span
lang=RU style='mso-bidi-font-size:11.0pt'>.<span style='mso-tab-count:1'>        </span>Преамбула
к Агентскому Договору Действует в следующей редакции:<o:p></o:p></span></p>

<p class=MsoBodyText><span lang=RU style='mso-bidi-font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:14.2pt'><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>Настоящий договор
заключен между Обществом с ограниченной ответственностью Страховая Компания </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=ORGNAME%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, именуемое в дальнейшем
«СТРАХОВЩИК», в лице г-на </span><span style='font-size:11.0pt;mso-ansi-language:
EN-US'><%=CHIEF_NAME%></span><span lang=RU
style='font-size:11.0pt;layout-grid-mode:line'>, действующего на основании </span><span
lang=RU style='font-size:11.0pt'>Доверенности № <%=PNUM_DOC_DIR%>, выданной <%=DATAV_DOC_DIR%>,
<span style='layout-grid-mode:line'>с одной стороны, и<span
style='mso-spacerun:yes'> </span></span></span><span style='font-size:
11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=AGENT_NAME_INSTRUMENTAL%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, паспорт серии </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=PS%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'> № </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=PNUM%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, выдан </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=PVIDAN%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, адрес: </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=AGADDR%></span><span
style='font-size:11.0pt;layout-grid-mode:line'> <span lang=RU>, именуемый в
дальнейшем «АГЕНТ», действующим на основании Свидетельства о внесении в Единый
государственный реестр индивидуальных предпринимателей записи об индивидуальном
предпринимателе серия <%=POBUL_SER%> № </span></span><span lang=RU><%=POBUL_NUM%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, выданного</span><span
lang=RU style='font-size:14.0pt;mso-bidi-font-size:10.0pt;color:#333333'> </span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'><%=POBUL_VIDAN%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>,<span
style='mso-spacerun:yes'>  </span>основной государственный регистрационный
номер записи о государственной регистрации индивидуального предпринимателя - </span><span
style='font-size:11.0pt;mso-ansi-language:EN-US;layout-grid-mode:line'><%=OGRN_NUM%></span><span
lang=RU style='font-size:11.0pt;layout-grid-mode:line'>, дата внесения записи - <%=OGRN_DATE%>
</span><span lang=RU style='font-size:11.0pt;layout-grid-mode:
line'>,<span style='mso-spacerun:yes'>  </span>с другой стороны.<o:p></o:p></span></p>

<p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:14.2pt'><span
lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:.5in;text-indent:-.5in;mso-list:l1 level1 lfo2;
tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:11.0pt'><span
style='mso-list:Ignore'>II.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>Настоящее
Дополнительное Соглашение вступает в силу с момента его подписания обеими
сторонами и является<span style='mso-spacerun:yes'>  </span>неотъемлемой частью
Агентского договора №<span style='mso-spacerun:yes'>  </span></span><span
style='font-size:11.0pt;mso-ansi-language:EN-US'><%=AGDOGNUM%></span><span
lang=RU style='font-size:11.0pt'> от<span style='mso-spacerun:yes'>  </span><span
style='mso-spacerun:yes'> </span></span><span style='font-size:11.0pt;
mso-ansi-language:EN-US'><%=DOGDATE%></span><span lang=RU style='font-size:11.0pt'>,
заключенного между </span><span style='font-size:11.0pt;mso-ansi-language:
EN-US;layout-grid-mode:line'><%=ORGNAME%></span><span lang=RU style='font-size:11.0pt'>
и <span style='mso-spacerun:yes'> </span></span><span style='font-size:11.0pt;
mso-ansi-language:EN-US'><%=AGENT_NAME_INSTRUMENTAL%></span><span lang=RU style='font-size:11.0pt'>.<o:p></o:p></span></p>

<p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:14.2pt'><span
lang=RU><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
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
    mso-line-height-rule:exactly'><b><span lang=RU >Реквизиты</span></b><span
    style='mso-ansi-language:EN-US'>: <o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>
	<span style='mso-ansi-language:EN-US'>
	ИНН: <%=ORGINN%>, КПП: <%=ORGKPP%>, Р/С: <%=ORGRS%>, в <%=ORGBANK%>, г. Москва, БИК  <%=ORGBBIC%>,К/С: <%=ORGKORAC%>
    </span>
	</p>   
    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU >Адрес:
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
    >ФИО: </span></b><span
    style='mso-ansi-language:EN-US'><%=AGNAME%></span><span lang=RU
    ><o:p></o:p></span></p>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>Паспорт:</b> </span>
    <span style='mso-ansi-language:EN-US'>
    <% if (!PNUM.equals("____________")) {%>
    <% if (!PS.equals("____")) {%>
    Серия: <%=PS%> <%}%>
    Номер: <%=PNUM%> 
    <% if (!PVIDAN.equals("_____________________________")) {%>
    Выдан: <%=PVIDAN%> <%}%>
    <% if (!DATAV.equals("__________")) {%>
    Дата выдачи: <%=DATAV%> <%}%>     
    <%}%>
    </span>
    <span
    lang=RU ><o:p></o:p></span></p>
<p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'>&nbsp;</p>	
<% if (!addrProp.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU
    ><b>Адрес по месту прописки: </b></span><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'>
    <%=addrProp%></span>

<b><span
    lang=RU ><o:p></o:p></span></b></p>
<%}%>    	
    <%if (!addrProz.equals("")){%>
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><b><span lang=RU
    >Адрес по месту проживания: <span
    style='mso-spacerun:yes'>  </span></span></b><span
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
    >ИНН: </span></b><span style='
    mso-ansi-language:EN-US'><%=AGINN%></span><span lang=RU ><o:p></o:p></span></p>
    <%} %> 
    <p></p>
    <%if (!PENS.equals("")) {%>
    <p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >№ пенсионного свидетельства: </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=PENS%></span><span
    style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
<%}%>
	<p class=MsoBodyTextIndent style='margin-top:0in;margin-right:0in;
    margin-bottom:6.0pt;margin-left:36.8pt;text-align:justify;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><b><span lang=RU
    >Свидетельство: </span></b><span
    style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold'><%=SVID_STR%></span><span
    style='mso-ansi-language:EN-US'><o:p></o:p></span></p>    
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>

<p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:14.2pt'><span
lang=RU><o:p>&nbsp;</o:p></span></p>
</td>
</tr>
</table>
</div>
</rw:foreach>
</body>


</html>

</rw:report>

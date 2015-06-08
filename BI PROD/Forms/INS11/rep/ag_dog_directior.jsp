<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_director_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_DIRECTOR_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[SELECT acj.agent_id, acj.ag_contract_header_id, acj.agent_name,
       nvl((select instrumental from contact where contact_id = acj.agent_id),acj.agent_name) agent_name_ins,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || acj.num num,
       d.reg_date,
       acj.date_begin,
       nvl(pkg_contact.get_address_name
                          (pkg_contact.get_primary_address (acj.agent_id)
                          ),'@') addr,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
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
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="2.31055"
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
      <![CDATA[SELECT DECODE (brief, 'CONST', 'прописки', 'проживания') pref, ca.contact_id,
       nvl(pkg_contact.get_address_name (a.ID),' ') addr
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
     AND UPPER (tit.brief) IN ('TRUST')   
]]>
      </select>
      <displayInfo x="6.06250" y="3.25000" width="0.69995" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="5.72266" y="3.94995" width="1.37964" height="1.28516"
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

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Приложение №6 </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>abudkova</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>Khomich</o:LastAuthor>
  <o:Revision>15</o:Revision>
  <o:TotalTime>14</o:TotalTime>
  <o:Created>2007-03-24T17:41:00Z</o:Created>
  <o:LastSaved>2007-03-24T18:01:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>4511</o:Words>
  <o:Characters>25714</o:Characters>
  <o:Lines>214</o:Lines>
  <o:Paragraphs>60</o:Paragraphs>
  <o:CharactersWithSpaces>30165</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
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
 table.mainTable{
 border=0;
 cellspacing=0;
 cellpadding=0;
 width:6.9in;
 border-collapse:collapse;
 mso-yfti-tbllook:480;
 mso-padding-alt:0in 5.4pt 0in 5.4pt;
 }
 td.mainTd{
 valign=top;
 width:6.9in;
 padding:0in 5.4pt 0in 5.4pt;
 }

 /* Font Definitions */
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
	{mso-style-name:Обычный1;
	margin:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
 /* Page Definitions */
 @page
	{}
@page Section1
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:22.7pt;
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
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:22.7pt;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section4
	{page:Section4;}
@page Section5
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:22.7pt;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.Section5
	{page:Section5;}

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
	{mso-list-id:1337420986;
	mso-list-template-ids:-267218132;}
@list l7:level1
	{mso-level-start-at:2;
	mso-level-legal-format:yes;
	mso-level-tab-stop:28.5pt;
	mso-level-number-position:left;
	margin-left:28.5pt;
	text-indent:-19.5pt;}
@list l7:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
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
	{mso-list-id:1354503029;
	mso-list-template-ids:-1947057530;}
@list l8:level1
	{mso-level-start-at:2;
	mso-level-number-format:none;
	mso-level-text:"1\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l8:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.55in;
	mso-level-number-position:left;
	margin-left:.55in;
	text-indent:-.3in;}
@list l8:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:.85in;
	text-indent:-.35in;}
@list l8:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
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
	{mso-list-id:1728840352;
	mso-list-template-ids:72643792;}
@list l9:level1
	{mso-level-legal-format:yes;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:8.5pt;
	text-indent:-8.5pt;}
@list l9:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:17.0pt;
	text-indent:-17.0pt;}
@list l9:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l9:level4
	{mso-level-reset-level:level1;
	mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l9:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l9:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l9:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l9:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l9:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l10
	{mso-list-id:2005477334;
	mso-list-template-ids:-447601770;}
@list l10:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:27.0pt;
	mso-level-number-position:left;
	margin-left:27.0pt;
	text-indent:-.25in;
	font-family:Symbol;}
@list l10:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l10:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l10:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l10:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l10:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l10:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l10:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l10:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l8:level2 lfo9
	{mso-level-start-at:5;}
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

<table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class="mainTd">
  <p class=MsoBodyTextIndent align=right style='margin-left:0in;text-align:
  right'><span lang=RU style='font-size:12.0pt'>Приложение №6 <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent align=right style='margin-left:0in;text-align:
  right'><span lang=RU style='font-size:12.0pt'>к Приказу от 25.01.2007<span
  style='mso-spacerun:yes'>   </span>№05/ОД/07 <o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="100%" colspan=2 valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 style='margin-top:0in;margin-right:1.35pt;margin-bottom:0in;
    margin-left:0in;margin-bottom:.0001pt;line-height:11.0pt;mso-line-height-rule:
    exactly;tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Агентский Договор
    № </span><span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
    font-family:"Times New Roman";mso-ansi-language:EN-US'><%=AGDOGNUM%><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    color:#333333'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='text-indent:27.0pt;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-indent:27.0pt;line-height:11.0pt;mso-line-height-rule:
  exactly;text-align:justify'><span lang=RU style='mso-ansi-language:RU'>Настоящий договор
  заключен между <%=ORGNAME%>, именуемое в дальнейшем «СТРАХОВЩИК», в лице <%=CHIEF_NAME%>,
  действующего на основании доверенности № <%=PNUM_DOC_DIR%> выданой <%=DATAV_DOC_DIR%>,
  с одной стороны, и <%=AGENT_NAME_INS%></span><b
  style='mso-bidi-font-weight:normal'><span style='mso-ansi-language:
  RU'> </span></b><span lang=RU style='mso-ansi-language:RU'>,
  паспорт серии <b style='mso-bidi-font-weight:normal'><span
  style='mso-spacerun:yes'> </span></b></span>
  <span ><%=PS%></span><span lang=RU
  style='mso-ansi-language:RU'> № </span><span ><%=PNUM%></span>
  <span lang=RU style='mso-ansi-language:
  RU'>выдан </span><span
  ><%=PVIDAN%></span><span lang=RU style='
  mso-ansi-language:RU'>, дата выдача </span>
  <span ><%=DATAV%></span><span lang=RU
  style='mso-ansi-language:RU'> адрес: </span>
  <span ><%=AGADDR%></span><span
  lang=RU style='mso-ansi-language:RU'>, именуемый в дальнейшем
  «АГЕНТ», с другой стороны.<o:p></o:p></span></p>
  <p class=MsoNormal style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent2 align=left style='margin-left:0in;text-align:
  left;text-indent:9.0pt;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l9 level1 lfo2;tab-stops:list .25in left 42.55pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Предмет договора.</span></b><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=1 style='margin-left:17.0pt;text-indent:-17.0pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt'><span style='mso-list:Ignore'>1.1.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По настоящему
  Договору АГЕНТ обязуется за вознаграждение осуществлять от имени и по
  поручению СТРАХОВЩИКА посредническую деятельность в области страхования с
  целью заключения СТРАХОВЩИКОМ с </span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;mso-fareast-language:EN-US'>физическими и
  юридическими лицами (далее по тексту - Страхователями) </span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>договоров страхования </span><span
  lang=RU style='font-size:11.0pt'>по следующим видам страхования:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование жизни;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование ренты
  (аннуитетов);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование пенсий;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование от
  несчастных случаев и болезней;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l2 level1 lfo3;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Добровольное
  медицинское страхование.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:8.5pt;text-indent:-8.5pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;
  tab-stops:list .25in'><![if !supportLists]><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Обязанности АГЕНТА:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Осуществлять поиск
  клиентов для заключения со СТРАХОВЩИКОМ договоров страхования;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Оказывать помощь
  страхователям в заключении договоров страхования.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Консультировать потенциальных
  клиентов, по вопросам, связанным с заключением договоров страхования в рамках
  предоставленных полномочий.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Совершать иные
  действия, необходимые для заключения договоров страхования в пределах
  полномочий, предоставленных настоящим Договором и Доверенностью, а также
  содействовать заключению Страховщиком договоров страхования с физическими и
  юридическими лицами в результате посреднической деятельности других<span
  style='mso-spacerun:yes'>  </span>агентов.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Оказывать помощь
  страхователям в составлении письменных заявлений и уведомлений в адрес
  СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.6.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Оказывать помощь в
  оформлении документов, необходимых для получения страховых выплат.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.7.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Осуществлять расчет
  страховых премий по договорам страхования (полисам) в соответствии с тарифным
  сборником, действующим у СТРАХОВЩИКА на момент заключения договора
  страхования (полиса) со Страхователем.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.8.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Выполнять функции,
  обусловленные настоящим Договором, в строгом соответствии с законодательством
  РФ, условиями настоящего Договора, условиями страхования и требованиями,
  установленными СТРАХОВЩИКОМ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.9.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Оформлять документы,
  необходимые для заключения договоров страхования, в строгом соответствии с
  документами, утвержденными СТРАХОВЩИКОМ. Соблюдать правильность и
  аккуратность при заполнении бланков документов строгой отчетности (квитанций
  и т.п.), номерных бланков полисов, заявлений<span style='mso-spacerun:yes'> 
  </span>и прочих формализованных документов СТРАХОВЩИКА;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.10.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Предоставлять
  СТРАХОВЩИКУ максимально полную информацию, необходимую для заключения
  договоров страхования .<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.11.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Обеспечить надежное
  хранение документов и материальных ценностей, принятых от СТРАХОВЩИКА и
  СТРАХОВАТЕЛЯ. В случае утраты АГЕНТОМ документов строгой отчетности, номерных
  бланков заявлений, полисов, переданных СТРАХОВЩИКОМ, денежных сумм,
  полученных в качестве страховой премии (взносов) по заключенным АГЕНТОМ
  договорам страхования, АГЕНТ обязан в течение 1 (одного) рабочего дня
  известить об этом СТРАХОВЩИКА. При утрате документов строгой отчетности,
  номерных бланков заявлений, полисов и денежных средств по вине АГЕНТА,
  СТРАХОВЩИК имеет право потребовать от АГЕНТА возмещения СТРАХОВЩИКУ возникших
  вследствие такой утраты убытков. АГЕНТ освобождается от ответственности, если
  докажет, что утрата документов и денежных средств явилась следствием действия
  обстоятельств непреодолимой силы либо противоправных действий третьих лиц. В
  случае порчи документов строгой отчетности, номерных бланков заявлений и
  полисов испорченные экземпляры должны передаваться СТРАХОВЩИКУ в течение 3
  (трех) рабочих дней.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.12.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Обеспечить
  правильность заполнения страхователями заявлений на страхование и передачу их
  СТРАХОВЩИКУ не позднее 3 (трех) рабочих дней с момента их заполнения и
  подписания страхователем;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.13.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Осуществлять
  передачу страхователям оформленных СТРАХОВЩИКОМ договоров страхования
  (полисов) и возврат подписанных экземпляров СТРАХОВЩИКУ не позднее 3 (трех)
  рабочих дней с момента их подписания. При утрате подлежащих передаче
  Страхователю/подписанных Страхователем номерных бланков полисов по вине
  АГЕНТА, СТРАХОВЩИК имеет право потребовать от АГЕНТА возмещения СТРАХОВЩИКУ
  возникших вследствие такой утраты убытков. АГЕНТ освобождается от
  ответственности, если докажет, что утрата документов и денежных средств
  явилась следствием действия обстоятельств непреодолимой силы либо
  противоправных действий третьих лиц.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.14.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Перечислять на
  расчетный счет СТРАХОВЩИКА суммы страховых премий/взносов по договорам
  страхования, заключенным СТРАХОВЩИКОМ в результате исполнения АГЕНТОМ
  обязанностей по настоящему договору, в течение 3 (трех) рабочих дней со дня
  их получения от страхователей – физических лиц и индивидуальных
  предпринимателей. Оплата страховых премий Страхователями - юридическими
  лицами производится в безналичном порядке путем перечисления денежных средств
  на расчетный счет СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.15.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В трехдневный срок
  сообщать СТРАХОВЩИКУ о решениях страхователей в отношении изменений и дополнений
  к заключенным договорам страхования и консультировать страхователей по
  заполнению соответствующих заявлений.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.16.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Сообщать СТРАХОВЩИКУ
  о любом изменении степени страхового риска или обо всех обстоятельствах,
  ведущих к такому изменению, о которых стало известно АГЕНТУ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.17.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Информировать
  страхователя о необходимости уплаты страхового взноса в порядке,
  установленном договором страхования, не позднее 30 дней до даты очередного
  платежа, указанной в страховом полисе.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.18.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Незамедлительно
  извещать СТРАХОВЩИКА о любом ненадлежащем или неправильном использовании
  товарных знаков, эмблем, разработок СТРАХОВЩИКА или других аналогичных
  коммерческих прав, которые становятся ему известными.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.19.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Действовать в
  интересах СТРАХОВЩИКА в рамках отношений, определенных настоящим Договором,
  соблюдать указания и распоряжения СТРАХОВЩИКА. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.20.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Открыть счет в банке
  для перечисления агентского вознаграждения и самостоятельно нести расходы,
  связанные с обслуживанием счета..<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.21.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не позднее 1-го
  рабочего дня месяца, следующего за окончанием отчетного периода,
  определенного в «Положении об основном агентском вознаграждении АГЕНТОВ» (<span style='font-size:10.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman";color:windowtext;text-decoration:none;
  text-underline:none'>Приложение № 1</span> к настоящему Договору) и
  «Положении о дополнительном агентском вознаграждении АГЕНТОВ» (<span style='font-size:10.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman";color:windowtext;text-decoration:none;
  text-underline:none'>Приложение № 2</span> к настоящему Договору),
  предоставлять СТРАХОВЩИКУ письменные Отчеты о выполнении своих обязанностей
  по настоящему Договору по установленной СТРАХОВЩИКОМ в <<span style='font-size:10.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman";color:windowtext;text-decoration:none;
  text-underline:none'>Приложениях</span> №№ 3, 4, 5 к настоящему Договору
  форме.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.22.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Выдать Доверенность
  на подписание Отчетов к настоящему Договору, указанных в п. 2.21., лицам,
  определенным СТРАХОВЩИКОМ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.23.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Присутствовать на
  всех учебных мероприятиях, проводимых СТРАХОВЩИКОМ. Необходимость обучения
  АГЕНТА определяется СТРАХОВЩИКОМ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.24.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не передавать свои
  права и обязанности по настоящему Договору или его части третьим лицам, в том
  числе не заключать субагентские договоры.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.25.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не связывать
  посредством каких-либо заявлений СТРАХОВЩИКА обязательствами, противоречащими
  действующему законодательству РФ, условиям настоящего Договора, правилам
  страхования СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.26.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не принимать на себя
  ответственность и не давать обязательства от имени СТРАХОВЩИКА, не
  предусмотренные настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.27.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не заключать
  договоры о посреднической деятельности с целью заключения договоров
  страхования по видам страхования, перечисленным в п.1.1. настоящего Договора,
  с другими страховыми компаниями, брокерами, страховыми агентствами.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.28.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не разглашать и не
  использовать неопубликованную и конфиденциальную информацию, получаемую от
  СТРАХОВЩИКА, и любую другую информацию о деятельности СТРАХОВЩИКА, его
  деловых операциях или методах их осуществления, не определенную СТРАХОВЩИКОМ
  для разглашения, в течение срока действия данного Договора или после того,
  как срок его действия истечет.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.55in;text-indent:-.3in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo1;
  tab-stops:list .55in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>.29.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В течение одного
  рабочего дня сообщать Страховщику о регистрации и постановке на налоговый
  учет в качестве индивидуального предпринимателя или о снятии с учета в
  качестве такового. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В случае нарушения
  АГЕНТОМ одной из указанных в настоящем разделе обязанностей СТРАХОВЩИК имеет
  право в одностороннем порядке расторгнуть настоящий Договор и потребовать
  возмещения убытков в порядке, предусмотренном действующим законодательством
  РФ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>В рамках настоящего Договора АГЕНТ имеет право:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получить
  от СТРАХОВЩИКА информацию и документацию, необходимую для осуществления им
  указанных в п. 1., 2. настоящего Договора функций, включая правила
  страхования, бланки заявлений-анкет, бланки строгой отчетности и т.д. Объем и
  характер данной информации и документации определяет СТРАХОВЩИК.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Проводить
  от имени и по поручению СТРАХОВЩИКА переговоры со страхователями по
  согласованию условий страхования по видам, указанным в п. 2. настоящего
  Договора.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получать
  от СТРАХОВЩИКА консультации по вопросам, связанным с выполнением условий настоящего
  Договора;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получать
  за оказанные им услуги от СТРАХОВЩИКА агентское вознаграждение в размере,
  указанном в Приложении №1 к настоящему Договору.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;tab-stops:42.55pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>В рамках настоящего Договора
  СТРАХОВЩИК имеет право:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Контролировать
  деятельность АГЕНТА по выполнению обязательств по настоящему Договору.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Контактировать
  с клиентом АГЕНТА напрямую, информируя АГЕНТА о любых такого рода контактах,
  в случае возникновения необходимости согласовать условия страхового
  возмещения, по вопросам оплаты премии или уточнения информации, содержащейся
  в заявлении на страхование.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Без
  какого-либо предварительного уведомления АГЕНТА:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>предлагать или
  предоставлять любому другому лицу право на осуществление любой посреднической
  деятельности по страхованию от имени СТРАХОВЩИКА;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>изменять страховые
  тарифы и условия страхования, на условиях, оговоренных в п.5.5. настоящего
  Договора.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l4 level1 lfo4;
  tab-stops:list .5in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>удерживать
  причитающееся АГЕНТУ агентское вознаграждение или его часть в счет погашения
  ущерба, нанесенного СТРАХОВЩИКУ по вине АГЕНТА, в случаях предусмотренных
  настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>4.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В
  одностороннем порядке изменять размер агентского вознаграждения по вновь
  заключаемым договорам страхования (полисам) путем письменного уведомления
  АГЕНТА. В случае несогласия АГЕНТА с новыми ставками агентского
  вознаграждения АГЕНТ имеет право расторгнуть настоящий Договор,
  предварительно за 10 (десять) рабочих дней уведомив об этом СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:14.2pt;text-align:justify;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>В рамках настоящего Договора
  СТРАХОВЩИК обязан:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.1.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Предоставить
  АГЕНТУ доверенность для осуществления АГЕНТОМ от имени СТРАХОВЩИКА функций,
  указанных в пп. 1., 2. настоящего Договора.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.2.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Своевременно
  обеспечивать АГЕНТА всеми необходимыми документами и материалами,<span
  style='mso-spacerun:yes'>  </span>определяемыми СТРАХОВЩИКОМ и необходимыми
  для осуществления деятельности, предусмотренной настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.3.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Выплачивать
  АГЕНТУ установленное в соответствии с разделом 6 настоящего Договора и
  Приложением №№ 1 агентское вознаграждение.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.4.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Подтверждать,
  что СТРАХОВЩИК имеет в соответствии с действующим законодательством право
  осуществлять страховую деятельность на территории РФ по указанным в п. 2.
  настоящего Договора видам страхования.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:17.0pt;text-indent:-17.0pt;
  line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>5.5.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Своевременно
  уведомлять АГЕНТА о вносимых изменениях в действующие условия страхования,
  страховые тарифы, порядок заключения договоров страхования и другие
  внутренние документы СТРАХОВЩИКА. <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>6.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Расчеты по настоящему
  Договору.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>За
  выполнение обязанностей по настоящему Договору, СТРАХОВЩИК выплачивает АГЕНТУ
  вознаграждение. Размер и порядок выплаты вознаграждения указаны в «Положении
  об основном агентском вознаграждении АГЕНТОВ» (Приложении № 1 к настоящему
  Договору).<span style='background:yellow'> </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Расходы,
  понесенные АГЕНТОМ в связи с исполнением настоящего Договора, компенсируются
  за счет агентского вознаграждения и дополнительно не оплачиваются, если
  соглашением Сторон не будет предусмотрено иное.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.3.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>В
  случае расторжения договора страхования, заключенного при посредничестве
  АГЕНТА, на этапе действия выжидательного периода, в результате которого
  Страхователю выплачивается сумма в размере внесенного первого или
  единовременного взноса в полном объеме или за вычетом расходов <span
  style='text-transform:uppercase'>Страховщика</span> по медицинскому
  обследованию, <span style='text-transform:uppercase'>Страховщик</span> имеет
  право потребовать от Агента возврата полученного по данному договору
  основного агентского вознаграждения в полном объеме.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>6.4.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>В
  случае расторжения договора страхования, заключенного при посредничестве
  АГЕНТА, в результате чего Страховщик возвращает Страхователю сумму оплаченной
  страховой премии в полном объеме, Страховщик имеет право потребовать от
  Агента возврата полученного по данному договору основного агентского вознаграждения
  в полном объеме.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:8.5pt;text-align:justify;line-height:
  11.0pt;mso-line-height-rule:exactly'><span lang=RU style='mso-ansi-language:
  RU'>Если Страховщик решит воспользоваться правом истребования от Агента
  указанных в настоящем пункте сумм, Страховщик вправе производить их удержание
  из любых сумм, подлежащих выплате АГЕНТУ СТРАХОВЩИКОМ, до тех пор, пока сумма
  возврата агентского вознаграждения не будет возвращена СТРАХОВЩИКУ в полном
  объеме.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>7.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Форс-мажор<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  освобождаются от ответственности за неисполнение или<span
  style='mso-spacerun:yes'>  </span>ненадлежащее исполнение своих обязанностей
  по настоящему Договору, если это явилось следствием действий обстоятельств
  непреодолимого и чрезвычайного характера (форс-мажор), к которым относятся
  стихийные бедствия, пожары, землетрясения, террористические акты, военные
  действия, массовые беспорядки и т. д.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>О
  возникновении и прекращении таких обстоятельств стороны должны уведомлять
  друг друга любым доступным<span style='mso-spacerun:yes'>  </span>им способом
  в течение 5 (пяти) дней с момента их возникновения.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>7.3.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>По
  требованию стороны, не затронутой форс-мажором, наличие обстоятельств
  непреодолимой силы должно подтверждаться справками государственных органов.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>8.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Конфиденциальность<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>8.1.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  как во время, так и после прекращения действия настоящего Договора обязуются
  не передавать третьим лицам без заранее полученного в каждом конкретном
  случае от другой стороны письменного согласия, прямо или косвенно, никакой
  информации о клиентах, физических и юридических лицах, контактах, способах
  установления контактов, источниках информации, способах выхода и доступа к
  источникам информации, источниках происхождения, способах приобретения услуг,
  свойствах услуг, информацию, содержащую в себе информационные и
  организационные ноу-хау, ноу-хау в области юридических формулировок, позиций
  и приемов при ведении переговоров и другие ноу-хау, которые могут быть
  известны сторонам, как с ведома, так и без ведома другой стороны настоящего
  Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>8.2.<span style='font:7.0pt "Times New Roman"'>
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>В
  случае, если одной из Сторон будет нанесен ущерб в результате действий другой
  Стороны, которая несанкционированно придаст огласке указанную в п. 8.1.
  информацию, потерпевшая Сторона имеет право потребовать от другой Стороны
  возмещения вреда, нанесенного вследствие нарушения условий конфиденциальности
  в порядке и размере, предусмотренных законодательством. <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><span style='mso-list:Ignore'>9.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Срок действия договора. </span></b><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><o:p></o:p></span></p>
  <p class=1 style='margin-left:17.0pt;text-indent:-17.0pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><span style='mso-list:Ignore'>9.1.<span
  style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'>Настоящий Договор заключен на неопределенный
  период и вступает в силу с момента его подписания Сторонами.<o:p></o:p></span></p>
  <p class=1 style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-language:
  EN-US;layout-grid-mode:line'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>10.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-spacerun:yes'> </span><b style='mso-bidi-font-weight:
  normal'>Порядок</b></span><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'> расторжения
  договора</span></b><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt'>.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'><span
  style='mso-spacerun:yes'> </span>Каждая из Сторон вправе отказаться от
  настоящего Договора в одностороннем порядке с обязательным письменным уведомлением
  другой стороны за 20 (двадцать) календарных дней до даты предполагаемого
  расторжения Договора. Уведомление (письмо) о расторжении Агентского Договора
  может быть передано каждой из Сторон (ее законному или уполномоченному
  представителю) лично под расписку или направляется по почте заказным письмом.
  <o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Если
  по истечении первых 60 (шестидесяти) календарных дней действия настоящего
  Договора при посредничестве АГЕНТА не было заключено ни одного договора
  страхования, СТРАХОВЩИК вправе в одностороннем порядке расторгнуть настоящий
  Договор путем письменного уведомления АГЕНТА за 7 (семь) календарных дней до
  даты предполагаемого расторжения Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>До
  даты прекращении настоящего Договора Стороны обязаны произвести между собой
  все взаиморасчеты, в том числе АГЕНТ обязан вернуть СТРАХОВЩИКУ все
  полученные от последнего для исполнения обязательств по настоящему договору
  документы и материалы и доверенность, а также предоставить отчет и отчитаться
  за использованные бланки строгой отчетности, а также выполнить все
  обязательства, предусмотренные настоящим Договором и законодательством РФ.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>10.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Расторжение
  настоящего договора влечет за собой прекращение обязательств Сторон по
  настоящему договору.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>11.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Разрешение споров<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  будут всячески содействовать сохранению и выполнению принятых на себя
  намерений и обязательств.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Все
  споры и разногласия, которые могут возникнуть из настоящего Договора, будут
  по возможности решаться путем двусторонних переговоров.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>В
  случае невозможности урегулирования споров и разногласий путем переговоров,
  разрешение споров и разногласий производится в соответствии с действующим
  законодательством Российской Федерации.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>11.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  договариваются, что все споры, вытекающие из настоящего договора,
  неурегулированные на стадии переговоров, подлежат рассмотрению в Арбитражном
  суде города Москвы.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>12.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Ответственность сторон.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in left 42.55pt'><![if !supportLists]><span lang=RU
  style='mso-ansi-language:RU'><span style='mso-list:Ignore'>12.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>За
  невыполнение положений настоящего Договора стороны несут ответственность в
  соответствии с действующим законодательством Российской Федерации.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;tab-stops:42.55pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:8.5pt;text-indent:-8.5pt;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l9 level1 lfo2;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'><span style='mso-list:Ignore'>13.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span></b><![endif]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;layout-grid-mode:line'>Заключительные положения.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  заявляют, что они не находятся в заблуждении относительно смысла настоящего
  Договора, что условия настоящего Договора не являются кабальными в смысле
  Гражданского законодательства РФ, что данный Договор не является мнимой или
  притворной сделкой, что данная сделка не противоречит чьим-либо интересам,
  что представители Сторон находятся в обычном для них состоянии здоровья, что
  Стороны не подписали данный Договор под прямой или косвенной угрозой другой
  стороны либо третьих лиц, что данная сделка не совершена под влиянием обмана,
  что Стороны осознают возможные последствия несоблюдения своих обязательств,
  вытекающих из настоящего Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Все
  приложения к данному Договору составляют его составную и неотъемлемую часть.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Все
  дополнения, приложения и изменения к настоящему Договору будут
  действительными и иметь юридическую силу, если они будут выполнены в
  письменной форме и подписаны обеими Сторонами.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Во
  всем, что не урегулировано данным Договором, Стороны будут руководствоваться
  действующим Гражданским законодательством Российской Федерации.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Настоящий
  Договор составлен в 2-х экземплярах: один - для СТРАХОВЩИКА, другой - для
  АГЕНТА. Оба экземпляра имеют одинаковую юридическую силу.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:17.0pt;text-align:justify;text-indent:
  -17.0pt;line-height:11.0pt;mso-line-height-rule:exactly;mso-list:l9 level2 lfo2;
  tab-stops:list .25in'><![if !supportLists]><span lang=RU style='mso-ansi-language:
  RU'><span style='mso-list:Ignore'>13.6.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  признают факсимильно воспроизведенную подпись СТРАХОВЩИКА подлинной.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU>ЮРИДИЧЕСКИЕ АДРЕСА И РЕКВИЗИТЫ СТОРОН:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><b style='mso-bidi-font-weight:normal'><span
  lang=RU><o:p>&nbsp;</o:p></span></b></p>
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
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='layout-grid-mode:both'><span style='font-size:12.0pt'><o:p></o:p></span></p>
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

<table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class="mainTd">
  <h2 align=right style='text-align:right;line-height:11.0pt;mso-line-height-rule:
  exactly'><a name="_Приложение_№_1"></a><span lang=RU><o:p>&nbsp;</o:p></span></h2>
  <h2 align=right style='text-align:right;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU>Приложение № 1 к Агентскому Договору <span
  >№ <%=AGDOGNUM%><o:p></o:p></span></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    color:#333333'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <h2 style='line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU
  style='mso-bidi-font-size:11.0pt'>Положение об основном агентском
  вознаграждении АГЕНТОВ<o:p></o:p></span></h2>
  <p class=MsoNormal align=center style='text-align:center;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l8 level1 lfo5;tab-stops:14.2pt list .25in'><![if !supportLists]><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt'>Общие положения<o:p></o:p></span></b></p>
  <p class=1 style='margin-left:.3in;line-height:11.0pt;mso-line-height-rule:
  exactly;tab-stops:list .3in'><span lang=RU style='font-size:11.0pt'>1.1. Настоящее
  положение является неотъемлемой частью Агентского <span >договора
  № <%=AGDOGNUM%> <o:p></o:p></span></span></p>
  <p class=1 style='margin-left:19.5pt;line-height:11.0pt;mso-line-height-rule:
  exactly;tab-stops:14.2pt list 19.5pt'><span lang=RU style='font-size:11.0pt'>1.2.
  Настоящее положение регламентирует условия выплаты основного агентского
  вознаграждения (ОАВ) страховым АГЕНТАМ (далее – АГЕНТ).<o:p></o:p></span></p>
  <p class=1 style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1><b style='mso-bidi-font-weight:normal'><span style='font-size:
  11.0pt;mso-ansi-language:EN-US'>2 </span></b><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt'>Порядок выплаты агентского
  вознаграждения</span></b><span lang=RU style='font-size:11.0pt'>.<o:p></o:p></span></p>
  <p class=1 style='margin-left:9.0pt;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='font-size:11.0pt'>2.1. Размер основного
  агентского вознаграждения устанавливается в зависимости от следующих
  параметров:<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l0 level1 lfo6;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>размера
  подписанной и полностью оплаченной страховой премии (взноса) и ставки
  агентского вознаграждения;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l0 level1 lfo6;tab-stops:14.2pt list .25in .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt'>программы
  страхования;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo7;tab-stops:14.2pt list .25in 27.0pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>порядка уплаты страховой премии
  (единовременно или в рассрочку);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo7;tab-stops:14.2pt list .25in 27.0pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt'>периода уплаты страховой премии (полных
  календарных лет);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:0in;line-height:11.0pt;
  mso-line-height-rule:exactly;mso-list:l10 level1 lfo7;tab-stops:14.2pt list .25in 27.0pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;font-family:Symbol;mso-fareast-font-family:
  Symbol;mso-bidi-font-family:Symbol;mso-fareast-language:EN-US;layout-grid-mode:
  line'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-fareast-language:EN-US;layout-grid-mode:line'>порядкового номера года
  действия договора страхования, за который уплачена страховая премия;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='font-size:11.0pt;mso-fareast-language:EN-US;
  layout-grid-mode:line'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='font-size:11.0pt'>2.2. Размер основного агентского
  вознаграждения определяется как произведение базовой ставки основного
  агентского вознаграждения (САВ) на сумму полностью оплаченной Страхователем
  премии по договору страхования, по которому СТРАХОВЩИК выпустил страховой полис,
  за вычетом суммы административных издержек. <o:p></o:p></span></p>
  <p class=1 style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='font-size:11.0pt'>2.3. Основное агентское вознаграждение
  АГЕНТА исчисляется от поступивших в результате деятельности АГЕНТА на
  расчетный счет СТРАХОВЩИКА в полном объеме следующих страховых премий
  (взносов):<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l3 level1 lfo8;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
  Symbol;mso-fareast-language:RU'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-fareast-language:
  RU'>первых страховых премий (за вычетом суммы административных издержек);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l3 level1 lfo8;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
  Symbol;mso-fareast-language:RU'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-fareast-language:
  RU'>очередных взносов, подлежащих оплате в отчетном периоде (за вычетом суммы
  административных издержек);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:.5in;margin-bottom:.0001pt;text-align:justify;
  text-indent:-.25in;line-height:11.0pt;mso-line-height-rule:exactly;
  mso-list:l3 level1 lfo8;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
  Symbol;mso-fareast-language:RU'><span style='mso-list:Ignore'>·<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-fareast-language:
  RU'>оплаченных в отчетном периоде просроченных страховых взносов (за вычетом
  суммы административных издержек). <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.4.
  По договорам страхования, страховая премия в которых указана в валютном
  эквиваленте, страховая премия считается оплаченной полностью в случае, если
  оплачено не менее 99,99% от суммы премии. При страховании с валютным
  эквивалентом страховая премия уплачивается в рублях по курсу Центрального
  банка РФ, установленному для иностранной валюты на дату уплаты
  (перечисления).&nbsp; Датой уплаты страховой премии (взноса) считается:</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  В случае перечисления страховой премии с расчетного счета Страхователя (Агента)
  на расчетный счет <span style='text-transform:uppercase'>Страховщика</span> –
  дата, указанная в платежном поручении с исполнением;</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  В случае приема <span style='text-transform:uppercase'>Агентом</span> у
  Страхователя страховой премии с использованием бланка строгой отчетности
  квитанции формы А7 – дата, указанная в квитанции формы А7.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>-
  В случае оплаты страховой премии Страхователем через банк – дата, указанная в
  приходном кассовом&nbsp; ордере банка (форме ПД4)</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'>
  <span lang=RU style='font-size:11.0pt;
  mso-fareast-language:EN-US;layout-grid-mode:line'>2.5. Отчетным периодом считается
  период с 1-го по 30 (31-е) число каждого месяца. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.6.
  Выплата основного агентского вознаграждения производится на основании Отчета
  к Агентскому Договору (Приложение № 2, 3 к Агентскому договору), который
  подписывается <span style='text-transform:uppercase'>Агентом</span> и
  представителем СТРАХОВЩИКА.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.7.
  СТРАХОВЩИК выплачивает основное агентское вознаграждение <span
  style='text-transform:uppercase'>агенту</span> в течение 5 (пяти) рабочих
  дней с момента подписания Отчета к Агентскому Договору обеими сторонами.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:0in'><span lang=RU>2.8.
  Стороны могут согласовать в Отчете к Агентскому договору сумму подлежащего к
  выплате основного агентского вознаграждения, рассчитанного на основании
  размера ставки основного агентского вознаграждения, отличного от указанного в
  настоящем Положении.</span></p>
  <p class=MsoBodyTextIndent style='margin-top:6.0pt;margin-right:0in;
  margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:-.25in'><span
  lang=RU>2.9. В случае если сумма подлежащего к выплате за отчетный месяц
  агентского вознаграждения составляет менее 300 рублей, то агентское
  вознаграждение в месяце следующим за отчетным не выплачивается.</span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1;tab-stops:
  -.25in'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'>2.10. Агентское вознаграждение, составляющее сумму менее указанной в
  пункте 2.9., может накапливаться не более 3-х месяцев и по истечении
  указанного срока СТРАХОВЩИК обязан выплатить накопленную сумму агентского
  вознаграждения<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-outline-level:1'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  text-indent:42.55pt;line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
  mso-line-height-rule:exactly'><span lang=RU><o:p>&nbsp;</o:p></span></p>
  <p class=1><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:11.0pt'>3. Ставки агентского вознаграждения<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.3. При
  расчете основного агентского вознаграждения по договору страхования в течение
  всего срока действия договора страхования применяется САВ, действовавшая на
  момент заключения договора страхования (этот момент определяется по первой
  квитанции А7 или банковской квитанции), за исключением случаев передачи
  обслуживания агентского договора от одного агента другому, а также за
  исключением случаев изменения базовых ставок ПМ по решению Компании.</span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.4. Базовые
  ставки агентского вознаграждения утверждаются СТРАХОВЩИКОМ. Об изменении
  базовых ставок агентского вознаграждения СТРАХОВЩИК уведомляет <span
  style='text-transform:uppercase'>Агента</span> за 10 дней до вступления и
  начала применения новых ставок. ОАВ по договорам страхования, заключенным <span
  style='text-transform:uppercase'>Агентом</span> до даты вступления новых
  ставок в силу, рассчитывается по старым ставкам.</span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in;text-align:justify;
  line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>3.5. Ставки
  ОАВ устанавливаются отдельно по каждой основной Программе, указанной в
  договоре страхования. По дополнительным программам, указанным в договоре
  страхования, действуют такие же ставки, что и по выбранной основной программе,
  кроме дополнительной программы № 1 «Страхование от несчастных случаев» и
  дополнительной программы № 7 «Инвест».</span></p>
  <p class=MsoNormal style='text-align:justify;line-height:11.0pt;mso-line-height-rule:
  exactly'><span lang=RU style='mso-bidi-font-size:11.0pt;mso-ansi-language:
  RU'>3.6. АГЕНТ имеет право на получение ОАВ по переданному ему на дальнейшее
  обслуживание договору страхования, заключенному при посредничестве другого
  агента, с которым СТРАХОВЩИКОМ был расторгнут агентский договор. В этом
  случае АГЕНТ получает ОАВ от поступивших по таким договорам очередных
  страховых взносов за первый год действия такого договора страхования по
  ставке агентского вознаграждения за второй год действия договора страхования
  при условии включения указанного договора страхования в отчет АГЕНТА.. <o:p></o:p></span></p>
  <p class=1 style='line-height:11.0pt;mso-line-height-rule:exactly'><span
  lang=RU style='font-size:11.0pt;mso-fareast-language:EN-US;layout-grid-mode:
  line'>3.7. При расчете ОАВ по отдельным договорам страхования СТРАХОВЩИК
  имеет право при условии согласования с АГЕНТОМ применить САВ в порядке ином,
  чем определено в настоящем Приложении, в частности применять САВ второго года
  действия договора страхования в течение первого года действия такого договора
  страхования. </span><span lang=RU style='font-size:11.0pt'><o:p></o:p></span></p>
  <p class=1 style='margin-left:9.0pt'><span lang=RU style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:9.0pt'><span lang=RU style='font-size:11.0pt'>4.
  <b style='mso-bidi-font-weight:normal'>Базовые размеры ставок агентского
  вознаграждения</b>:</span></p>
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
  name="_ПРИЛОЖЕНИЕ_№_1.2._САВ2._СТАВКИ_ОСНО"></a><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='mso-bidi-font-size:
  11.0pt;mso-ansi-language:RU'>4.1. СТАВКИ ОСНОВНОГО АГЕНТСКОГО ВОЗНАГРАЖДЕНИЯ
  АГЕНТОВ<o:p></o:p></span></i></b></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.75pt'>
    <td width=73 rowspan=3 style='width:54.4pt;border:solid windowtext 1.0pt;
    border-bottom:solid black 1.0pt;padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>Период страхования, лет</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.65pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>Программа </span><span
    style='font-size:8.0pt'>смешанного страхования жизни</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.65pt;border:solid windowtext 1.0pt;
    border-right:solid black 1.0pt;padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>Программы дожития с возвратом
    взносов, страхования жизни на срок, дожития с возвратом взносов
    (страхование детей)</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.55pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>Дополнительная программа №
    1<span style='mso-spacerun:yes'>  </span>&quot;Страхование от несчастных
    случаев&quot; к программам смешанного страхования жизни, дожития с
    возвратом взносов, страхования жизни на срок, дожития с возвратом взносов
    (страхование детей).</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.5pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>Программа страхования от
    несчастных случаев</span><span lang=RU style='font-size:8.0pt;mso-fareast-font-family:
    "Arial Unicode MS";mso-ansi-language:RU'><o:p></o:p></span></p>
    </td>
    <td width=170 colspan=3 style='width:127.5pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    padding:.75pt .75pt 0in .75pt;height:12.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:8.0pt;mso-ansi-language:RU'>Дополнительная программа № 7
    «Инвест» к программам смешанного страхования жизни, дожития с возвратом
    взносов, страхования жизни на срок, дожития с возвратом взносов
    (страхование детей).<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:12.0pt'>
    <td width=113 colspan=2 style='width:85.1pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>периодическая уплата взносов</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.55pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>единовременная уплата премии</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.1pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>периодическая уплата взносов</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.55pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>единовременная уплата премии</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.05pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>периодическая уплата взносов</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>единовременная уплата премии</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>периодическая уплата взносов</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border:none;border-bottom:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>единовременная уплата премии</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=113 colspan=2 style='width:85.0pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-top-alt:solid windowtext 1.0pt;mso-border-top-alt:
    windowtext 1.0pt;mso-border-left-alt:windowtext 1.0pt;mso-border-bottom-alt:
    windowtext .5pt;mso-border-right-alt:black .5pt;mso-border-style-alt:solid;
    padding:.75pt .75pt 0in .75pt;height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>периодическая уплата взносов</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 rowspan=2 style='width:42.5pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:12.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>единовременная уплата премии</span><span
    style='font-size:8.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:36.75pt'>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-й год</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>последующие годы</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-й год</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>последующие годы</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.55pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-й год</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>последующие годы</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-й год</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>последующие годы</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border:solid windowtext 1.0pt;border-top:
    none;mso-border-left-alt:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;
    mso-border-right-alt:solid windowtext .5pt;padding:.75pt .75pt 0in .75pt;
    height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>1-й год</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=57 style='width:42.5pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:.75pt .75pt 0in .75pt;height:36.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:8.0pt'>последующие годы</span><span style='font-size:8.0pt;
    mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
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
    style='font-size:8.0pt'>больше или равно 20<o:p></o:p></span></p>
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
    style='font-size:9.0pt'>Программа страхования<o:p></o:p></span></p>
    </td>
    <td width=364 style='width:272.7pt;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    padding:0in 5.4pt 0in 5.4pt;height:6.75pt'>
    <p class=MsoNormal align=center style='text-align:center'><span lang=RU
    style='font-size:9.0pt;mso-ansi-language:RU'>% вознаграждения за каждый
    взнос, оплаченный Страхователем<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;height:3.05pt'>
    <td width=559 valign=bottom style='width:419.55pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 5.4pt 0in 5.4pt;height:3.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt'>&quot;ЖиНС&quot;<o:p></o:p></span></p>
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
    style='font-size:9.0pt'>&quot;Экспресс-защита&quot;<o:p></o:p></span></p>
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
    style='font-size:9.0pt;mso-ansi-language:RU'>Договоры группового
    страхования жизни и НС<o:p></o:p></span></p>
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
    style='font-size:9.0pt'>Пакетные продукты страхования жизни<o:p></o:p></span></p>
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
    style='font-size:9.0pt'>Договоры страхования пенсии/аннуитета<o:p></o:p></span></p>
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
    style='font-size:9.0pt;mso-ansi-language:RU'>Пакетные продукты страхования
    пенсии/аннуитета<o:p></o:p></span></p>
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

<table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class="mainTd">
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <h2 align=right style='text-align:right'><a name="_Приложение_№_4"></a><span
  lang=RU>Приложение № 2 к Агентскому Договору <span >№ <%=AGDOGNUM%><o:p></o:p></span></span></h2>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l1 level1 lfo10;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение является неотъемлемой частью
  Агентского договора № <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l1 level1 lfo10;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение устанавливает форму Отчета
  Агента к Агентскому договору, на основании которого выплачивается основное
  агентское вознаграждение. <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА
  № ОАВ-__<o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'>к Агентскому договору № <%=AGDOGNUM%><o:p></o:p></span></b></p>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    color:#333333'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-tab-count:1'>            </span> <%=ORGNAME%>, именуемое в дальнейшем Страховщик, в
  лице <%=CHIEF_NAME%>, действующего на основании доверенности № <%=PNUM_DOC_DIR%> выданой <%=DATAV_DOC_DIR%>,
  с одной стороны, и <%=AGENT_NAME_INS%>, паспорт серии <%=PS%> № <%=PNUM%>, именуемый(ая) в
  дальнейшем АГЕНТ, с другой стороны, составили и утвердили настоящий отчет к
  Агентскому соглашению о нижеследующем:<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none;text-align:justify'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
  1. За период с &lt;ДАТА&gt; по &lt;ДАТА&gt; при
  посредничестве Агента были заключены следующие договоры страхования, по
  которым на расчетный счет страховщика поступила страховая премия в полном
  объеме:<o:p></o:p></span></p>
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
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=20% style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=20% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
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
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none;text-align:justify'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
  2. Основное агентское вознаграждение за отчетный период
  составляет: ________. Расчет агентского вознаграждения прилагается к
  настоящему отчету.<o:p></o:p></span></p>
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
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
     </td>
   </tr>
  </table>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <span lang=RU style='font-size:11.0pt;mso-bidi-font-size:12.0pt;font-family:
  "Times New Roman CYR";mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
  AR-SA'><br clear=all style='page-break-before:always'>
  </span>
  </div>
  <div class=Section5>
  <table class="mainTable">
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class="mainTd">

  <h2 align=right style='text-align:right'><span lang=RU>Приложение № 3<span
  style='mso-spacerun:yes'>  </span>к Агентскому Договору <span
  >№ <%=AGDOGNUM%><o:p></o:p></span></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l6 level1 lfo11;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение является неотъемлемой частью
  Агентского договора № <%=AGDOGNUM%><o:p></o:p></span></p>
  <ol style='margin-top:0in' start=2 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l6 level1 lfo11;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='mso-ansi-language:RU'>Настоящее Приложение устанавливает
       форму Расчета основного агентского вознаграждения.</span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'><o:p></o:p></span></li>
  </ol>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Расчет основного
  агентского вознаграждения к отчету <span style='text-transform:uppercase'>Агента</span>
  от &lt;ДАТА&gt; к Агентскому договору №<%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Основное
  агентское вознаграждение выплачивается в соответствии с условиями агентского
  договора № <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-top:6.0pt;text-align:justify;
  mso-list:l5 level1 lfo12;tab-stops:list 0in .5in;mso-layout-grid-align:
  none;text-autospace:none'><![if !supportLists]><span lang=RU
  style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
  mso-ansi-language:RU'><span style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
  За период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; АГЕНТ, имеющий на указанный период статус
  __________________________________, получает основное агентское
  вознаграждение за следующие договоры страхования, заключенные в результате
  выполнения АГЕНТОМ обязанностей по агентскому договору:<o:p></o:p></span></p>
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
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>
    </td>
    <td width=20% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
    </td>
    <td width=20% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
          <o:p></o:p></span></b></p>
    </td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от премии
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
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
  .25in;mso-list:l5 level1 lfo12;tab-stops:list 0in .5in;mso-layout-grid-align:
  none;text-autospace:none'><![if !supportLists]><span lang=RU
  style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
  mso-ansi-language:RU'><span style='mso-list:Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>За период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; были расторгнуты следующие договоры страхования,
  заключенные <span style='text-transform:uppercase'>Страховщиком</span> при
  посредничестве <span style='text-transform:uppercase'>Агента</span>. В
  соответствии с п. 2.24., 6.3., 6.4. Агентского договора, часть агентского
  вознаграждения по этим договорам удержана из агентского вознаграждения Агента
  в соответствии с таблицей, приведенной ниже.<o:p></o:p></span></p>
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
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год действия договора на момент расторжения
          <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'> Сумма выплаченного по договору агентского вознаграждения
      <o:p></o:p></span></b></p></td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение к возврату<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от суммы выплаченного АВ
      <o:p></o:p></span></b></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>    </td>
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
   <li class=MsoNormal style='mso-list:l5 level1 lfo12;tab-stops:list .5in;
       mso-layout-grid-align:none;text-autospace:none'><span lang=RU
       style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
	   Итого размер агентского вознаграждения за период с
       &lt;ДАТА&gt; по &lt;ДАТА&gt; составляет: </span><span lang=RU
       style='mso-ansi-language:RU'>&lt;Сумма из </span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>п. 1</span><span lang=RU style='mso-ansi-language:
       RU'>&gt;</span><span lang=RU style='font-family:"Times New Roman CYR";
       mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'> - </span><span
       lang=RU style='mso-ansi-language:RU'>&lt;Сумма из </span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'>п. 2</span><span lang=RU style='mso-ansi-language:
       RU'>&gt;</span><span lang=RU style='font-family:"Times New Roman CYR";
       mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'> = </span><span
       lang=RU style='mso-ansi-language:RU'>&lt;СУММА&gt;.</span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'><o:p></o:p></span></li>
   <li class=MsoNormal style='mso-list:l5 level1 lfo12;tab-stops:list .5in;
       mso-layout-grid-align:none;text-autospace:none'><span lang=RU
       style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
	   Сумма агентского вознаграждения, указанная в п.
       3., определена правильно.<o:p></o:p></span></li>
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
    <p class=MsoBodyTextIndent style='margin-left:0in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span lang=RU ><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>     
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

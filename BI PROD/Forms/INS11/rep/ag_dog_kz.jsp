<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report" >

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_kz_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_KZ_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[SELECT acj.agent_id, acj.ag_contract_header_id, acj.agent_name,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || acj.num num,
       d.reg_date,
       dept_exe.contact_id dir_contact_id,
       decode(nvl(lower(vtt.description),'г-н'),'г-н','г-на','г-жа','г-жи',lower(vtt.description)) g_n,
       NVL(pkg_contact.get_address_name(pkg_contact.get_primary_address (acj.agent_id)),'@') addr,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name
  FROM v_ag_contract_journal acj,
       ven_department dep,
       ven_document d,
       ven_dept_executive dept_exe,
       ven_cn_person vcp,
       VEN_T_TITLE vtt
 WHERE acj.agency_id = dep.department_id(+)
   AND d.document_id = acj.ag_contract_header_id
   AND acj.agency_id = dept_exe.department_id(+)
   AND dept_exe.contact_id = vcp.contact_id(+)
   AND vcp.title = vtt.ID(+)
   AND acj.ag_contract_header_id = :p_ch_id;
]]>
      </select>
      <displayInfo x="2.07300" y="1.48950" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="1.79785"
        />
        <dataItem name="G_N" datatype="vchar2" columnOrder="44" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="G N">
          <dataDescriptor expression="G_N" descriptiveExpression="G_N"
           order="7" width="255"/>
        </dataItem>
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="19" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
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
           descriptiveExpression="REG_DATE" order="5" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="16" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="NUM" descriptiveExpression="NUM"
           order="4" width="201"/>
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
        <dataItem name="chief_name" datatype="vchar2" columnOrder="28"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="21" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="22" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="23"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="24" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="25" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="26"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="27"
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
        <dataItem name="pref" datatype="vchar2" columnOrder="31"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="29" width="4000"
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
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="32"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="33"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <xmlSettings xmlTag="DOC_DESC1"/>
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="34" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor
           expression="NVL ( cci.serial_nr , &apos;_____&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="35" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor
           expression="NVL ( cci.id_value , &apos;___________&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="36" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;______________________________&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="37" width="11"
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
      <displayInfo x="3.91663" y="4.39587" width="0.69995" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="3.57678" y="5.09583" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID1" oracleDatatype="number" columnOrder="38"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="39"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser1" datatype="vchar2" columnOrder="40" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser1">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num1" datatype="vchar2" columnOrder="41" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num1">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan1" datatype="vchar2" columnOrder="42"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pvidan1">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v1" datatype="vchar2" columnOrder="43"
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
xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="<%=g_ImagesRoot%>/ag_dog_kz.files/filelist.xml">
<title>Агентский Договор № ____________</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="date"/>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="metricconverter"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>soldain</o:Author>
  <o:Template>agent_treaty_telemarket</o:Template>
  <o:LastAuthor>Khomich</o:LastAuthor>
  <o:Revision>3</o:Revision>
  <o:TotalTime>2</o:TotalTime>
  <o:LastPrinted>2006-02-17T07:09:00Z</o:LastPrinted>
  <o:Created>2007-03-26T14:25:00Z</o:Created>
  <o:LastSaved>2007-03-26T14:47:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>4161</o:Words>
  <o:Characters>23718</o:Characters>
  <o:Company>Renaissance Insurance</o:Company>
  <o:Lines>197</o:Lines>
  <o:Paragraphs>55</o:Paragraphs>
  <o:CharactersWithSpaces>27824</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:GrammarState>Clean</w:GrammarState>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:FootnoteLayoutLikeWW8/>
   <w:ShapeLayoutLikeWW8/>
   <w:AlignTablesRowByRow/>
   <w:ForgetLastTabAlignment/>
   <w:LayoutRawTableWidth/>
   <w:LayoutTableRowsApart/>
   <w:UseWord97LineBreakingRules/>
   <w:SelectEntireFieldWithStartOrEnd/>
   <w:UseWord2002TableStyleRules/>
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
@font-face
	{font-family:PartnerCondensed;
	mso-font-alt:"Courier New";
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:515 0 0 0 5 0;}
@font-face
	{font-family:"Trebuchet MS";
	panose-1:2 11 6 3 2 2 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
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
	font-family:PartnerCondensed;
	font-variant:small-caps;
	mso-font-kerning:14.0pt;
	mso-ansi-language:RU;}
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
h3
	{mso-style-next:Обычный;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:0in;
	text-align:justify;
	mso-pagination:widow-orphan;
	mso-outline-level:3;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:12.0pt;
	font-family:PartnerCondensed;
	mso-ansi-language:RU;
	font-weight:normal;}
h4
	{mso-style-next:Обычный;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:6.0pt;
	margin-left:0in;
	text-align:justify;
	mso-pagination:widow-orphan;
	mso-outline-level:4;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:12.0pt;
	font-family:PartnerCondensed;
	font-weight:normal;}
h5
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	mso-outline-level:5;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:11.0pt;
	font-family:Arial;
	font-weight:normal;}
h6
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	mso-outline-level:6;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:11.0pt;
	font-family:"Times New Roman";
	font-weight:normal;
	font-style:italic;}
p.MsoHeading7, li.MsoHeading7, div.MsoHeading7
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	mso-outline-level:7;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";}
p.MsoHeading8, li.MsoHeading8, div.MsoHeading8
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	mso-outline-level:8;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	font-style:italic;}
p.MsoHeading9, li.MsoHeading9, div.MsoHeading9
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	mso-outline-level:9;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:9.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;
	font-style:italic;}
p.MsoNormalIndent, li.MsoNormalIndent, div.MsoNormalIndent
	{margin:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Trebuchet MS";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;
	mso-fareast-language:RU;}
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
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-line-height-alt:1.1pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Courier New";
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
p.MsoBodyText2, li.MsoBodyText2, div.MsoBodyText2
	{margin:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:red;
	mso-ansi-language:RU;}
p.MsoBodyText3, li.MsoBodyText3, div.MsoBodyText3
	{margin-top:2.05pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:none;
	tab-stops:320.3pt;
	layout-grid-mode:char;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	mso-bidi-font-weight:bold;}
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
p.MsoBodyTextIndent3, li.MsoBodyTextIndent3, div.MsoBodyTextIndent3
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:19.5pt;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
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
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
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
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:19.5pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:-19.5pt;
	mso-pagination:widow-orphan;
	mso-list:l5 level1 lfo1;
	tab-stops:14.2pt list 19.5pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
ins
	{mso-style-type:export-only;
	text-decoration:none;}
span.msoIns
	{mso-style-type:export-only;
	mso-style-name:"";
	text-decoration:underline;
	text-underline:single;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
/* Page Definitions */
 @page
	{mso-footnote-separator:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") fs;
	mso-footnote-continuation-separator:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") fcs;
	mso-endnote-separator:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") es;
	mso-endnote-continuation-separator:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ecs;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") f1;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") f1;
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
@page Section3
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") f1;
	mso-paper-source:0;}
div.Section3
	{page:Section3;}
@page Section4
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") f1;
	mso-paper-source:0;}
div.Section4
	{page:Section4;}
@page Section5
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_kz.files/header.htm") f1;
	mso-paper-source:0;}
div.Section5
	{page:Section5;}
 /* List Definitions */
 @list l0
	{mso-list-id:131220508;
	mso-list-type:hybrid;
	mso-list-template-ids:1908572790 -1017068402 -28014920 -1189973318 -384157814 581962188 1238150786 976653320 -1809448648 643089896;}
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
	{mso-list-id:179778994;
	mso-list-type:hybrid;
	mso-list-template-ids:2106090686 -1915983560 -118978828 -1313169586 1340862 1613941338 1507630926 -579730204 -228298378 1015202754;}
@list l1:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
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
	{mso-list-id:803890164;
	mso-list-type:hybrid;
	mso-list-template-ids:-324102726 -945759716 -11214134 494705548 -371442866 -1541735200 -1508977390 -1018911742 1854857346 -1638091216;}
@list l2:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l2:level2
	{mso-level-start-at:2;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
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
	{mso-list-id:969628906;
	mso-list-type:hybrid;
	mso-list-template-ids:-801358350 -2069329948 -521776072 1056053346 -1103317330 -1260118834 1736220584 1834800980 1908437178 570084516;}
@list l3:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
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
	{mso-list-id:1082602987;
	mso-list-type:hybrid;
	mso-list-template-ids:-696759816 -538424900 983605082 -1044739050 -1554219884 -664624712 -1232837584 -346001754 1397257692 -566871134;}
@list l4:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
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
	{mso-list-id:1354503029;
	mso-list-template-ids:-767529522;}
@list l5:level1
	{mso-level-start-at:2;
	mso-level-style-link:Обычный1;
	mso-level-legal-format:yes;
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l5:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l5:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l5:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l5:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l5:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l5:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l5:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l5:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l6
	{mso-list-id:1728840352;
	mso-list-template-ids:72643792;}
@list l6:level1
	{mso-level-legal-format:yes;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:8.5pt;
	text-indent:-8.5pt;}
@list l6:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:17.0pt;
	text-indent:-17.0pt;}
@list l6:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l6:level4
	{mso-level-reset-level:level1;
	mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l6:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l6:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l6:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l6:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l6:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l7
	{mso-list-id:1736127240;
	mso-list-template-ids:1441428514;}
@list l7:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	font-family:Symbol;}
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
	{mso-list-id:1943760649;
	mso-list-template-ids:1441428514;}
@list l8:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;
	font-family:Symbol;}
@list l8:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l8:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l8:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l8:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l8:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l8:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l8:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l8:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l9
	{mso-list-id:2123961353;
	mso-list-template-ids:1441428514;}
@list l9:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
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
@list l5:level1 lfo5
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="3074"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'>

<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="REG_DATE" src="REG_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="DIR_NAME" src="DIR_NAME"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:getValue id="G_N" src="G_N"/>
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

CHIEF_NAME = DIR_NAME;
G_N_OBR = G_N;

if (AGADDR.equals("@")) AGADDR = "_______________________________________________";
%>

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

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=659 colspan=2 valign=top style='width:494.45pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 style='margin-top:0in;margin-right:1.35pt;margin-bottom:0in;
    margin-left:0in;margin-bottom:.0001pt;tab-stops:467.8pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Агентский
    Договор № <span style='mso-spacerun:yes'> </span><%=AGDOGNUM%><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width=344 valign=top style='width:257.7pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'>г. Москва</span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width=316 valign=top style='width:236.75pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;tab-stops:467.8pt'><a name="treaty_date"><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span></a><span
    style='mso-bookmark:treaty_date'><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman";font-weight:normal'>.</span></span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
  RU'>Настоящий договор заключен между <%=ORGNAME%>, именуемым в
  дальнейшем «СТРАХОВЩИК», в лице <%=G_N_OBR%> <%=CHIEF_NAME%>, действующего
  на основании Доверенности № <%=PNUM_DOC_DIR%> выданой <%=DATAV_DOC_DIR%>, с
  одной стороны, и<span style='mso-spacerun:yes'>   </span></span><%=AGNAME%><span lang=RU
  style='mso-ansi-language:RU'>, паспорт серии </span><%=PS%><span lang=RU style='mso-ansi-language:RU'> № </span>
  <%=PNUM%><span lang=RU
  style='mso-ansi-language:RU'>, выдан </span>
  <%=PVIDAN%><span lang=RU style='mso-ansi-language:RU'> дата
  выдачи </span><%=DATAV%><span
  lang=RU style='mso-ansi-language:RU'>, адрес: </span>
  <%=AGADDR%><span lang=RU style='mso-ansi-language:RU'>, <span
  class=GramE>именуемым(</span>ой) в дальнейшем «АГЕНТ», с другой стороны.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:8.5pt;text-indent:-8.5pt;
  line-height:normal;mso-list:l6 level1 lfo2;tab-stops:list .25in left 42.55pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Предмет
  договора. </span></b><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:8.5pt;text-indent:-8.5pt;
  line-height:normal;mso-list:l6 level1 lfo2;tab-stops:list .25in left 42.55pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>По настоящему
  Договору АГЕНТ обязуется за вознаграждение осуществлять от имени и по
  поручению СТРАХОВЩИКА посредническую деятельность в области страхования с
  целью заключения СТРАХОВЩИКОМ договоров страхования личных и имущественных
  интересов с </span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;font-family:"Times New Roman";mso-fareast-language:EN-US'>физическими
  и юридическими лицами (далее по тексту - Страхователями).</span><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>В рамках
  настоящего Договора АГЕНТ обязан:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Осуществлять
  посредническую деятельность по заключению договоров страхования по следующим
  видам страхования:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l1 level1 lfo3;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование жизни;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l1 level1 lfo3;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование ренты
  (аннуитетов);<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l1 level1 lfo3;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование пенсий;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l1 level1 lfo3;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Страхование от
  несчастных случаев и болезней;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l1 level1 lfo3;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Добровольное
  медицинское страхование.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:0in;line-height:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В
  целях выполнения этой обязанности, АГЕНТ обязан:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Осуществлять поиск
  клиентов для заключения со СТРАХОВЩИКОМ договоров страхования;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Консультировать
  потенциальных клиентов, по вопросам, связанным с заключением договоров
  страхования в рамках предоставленных полномочий.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Информировать
  потенциальных клиентов о программах страхования СТРАХОВЩИКА, способствуя
  формированию у клиентов положительного восприятия страхования жизни и
  выражению ими намерения заключить договор страхования по указанным в
  настоящем договоре видам страхования с учетом индивидуальных потребностей
  конкретного клиента.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Способствовать
  установлению делового контакта с потенциальными Клиентами, при этом под
  установлением «делового контакта» в смысле настоящего Договора понимается
  достижение АГЕНТОМ в ходе телефонных переговоров или иным образом достигнутых
  договоренностей с потенциальными клиентами о проведении встреч с
  установлением времени и места таких встреч с целью заключения потенциальными
  клиентами Договоров страхования со СТРАХОВЩИКОМ по программам страхования,
  указанным в п. 2 настоящего Договора</span></span><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>.
  Встречи с потенциальными клиентами могут назначаться АГЕНТАМИ на дни,
  следующими за днем, когда была достигнута соответствующая договоренность.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Совершать иные
  действия, необходимые для заключения договоров страхования в пределах
  полномочий, предоставленных настоящим Договором. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.6.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Выполнять функции,
  обусловленные настоящим Договором, в строгом соответствии с законодательством
  РФ, условиями настоящего Договора, условиями страхования и требованиями,
  установленными СТРАХОВЩИКОМ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.7.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Предоставлять
  СТРАХОВЩИКУ максимально полную информацию, влияющую на заключение договоров
  страхования.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.8.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Обеспечить надежное
  хранение документов и материальных ценностей, принятых от СТРАХОВЩИКА и
  СТРАХОВАТЕЛЯ. В случае утраты АГЕНТОМ документов, переданных
  СТРАХОВЩИКОМ,<span style='mso-spacerun:yes'>  </span>АГЕНТ обязан немедленно
  известить СТРАХОВЩИКА. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.9.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Сообщать СТРАХОВЩИКУ
  о любом повышении степени риска или обо всех обстоятельствах, ведущих к
  такому повышению, о которых стало известно АГЕНТУ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.10.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Незамедлительно
  извещать СТРАХОВЩИКА о любом ненадлежащем или неправильном использовании
  товарных знаков, эмблем, разработок СТРАХОВЩИКА или других аналогичных
  коммерческих прав, которые становятся ему известными.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.11.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Действовать в
  интересах СТРАХОВЩИКА в рамках отношений, определенных настоящим Договором,
  соблюдать указания и распоряжения СТРАХОВЩИКА. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.12.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Открыть счет в банке
  для перечисления агентского вознаграждения и самостоятельно уплачивать
  комиссию за ведение банковской карточки.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.13.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не
  позднее 1-го рабочего дня, следующего за окончанием отчетных периодов,
  оговоренных в «Положении об агентском вознаграждении АГЕНТОВ – физических
  лиц» (<a href="#_Приложение_№_1"><span style='font-size:10.0pt;font-family:
  Arial;mso-bidi-font-family:"Times New Roman";color:windowtext;text-decoration:
  none;text-underline:none'>Приложение № 1</span></a> к настоящему Договору),
  предоставлять СТРАХОВЩИКУ письменные Отчеты о выполнении своих обязанностей
  по настоящему Договору, в установленной СТРАХОВЩИКОМ в Приложениях № 2 , 3,
  настоящему Договору форме.</span></span><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.14.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Присутствовать на
  учебных мероприятиях, проводимых СТРАХОВЩИКОМ. Необходимость обучения АГЕНТА
  определяется СТРАХОВЩИКОМ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.15.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Возвратить за свой
  счет в случае прекращения настоящего Договора по любой причине все оставшиеся
  у АГЕНТА документы и материалы, переданные ему СТРАХОВЩИКОМ для исполнения
  обязательств по настоящему Договору, не позднее последнего дня действия
  Договора.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.16.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-spacerun:yes'> </span><span class=GramE>Возвратить в случае
  расторжения договора страхования, заключенного при посредничестве АГЕНТА, на
  этапе действия выжидательного периода, в результате которого Страхователю
  выплачивается сумма в размере внесенного первого или единовременного взноса в
  полном объеме или за вычетом расходов Страховщика по медицинскому
  обследованию, агентское вознаграждение в течение 5 (пяти) банковских дней с
  момента получения Агентом Уведомления (письма) с требованием возврата агентского
  вознаграждения, в случае</span>, если Страховщик решит воспользоваться,
  указанным <span class=GramE>в</span> п. 6.4. <span class=GramE>настоящего</span>
  договора правом на возврат агентского вознаграждения.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.17.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не передавать свои
  права и обязанности по настоящему Договору или его части третьим лицам, в том
  числе не заключать субагентские договоры.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.18.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не связывать
  посредством каких-либо заявлений СТРАХОВЩИКА обязательствами, противоречащими
  действующему законодательству РФ, условиям настоящего Договора, правилам
  страхования СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.19.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не принимать на себя
  ответственность и не давать обязательства от имени СТРАХОВЩИКА, не
  предусмотренные настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.20.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не заключать без
  согласия СТРАХОВЩИКА договоры о посреднической деятельности с целью
  заключения договоров страхования по видам страхования, перечисленным <span
  class=GramE>в</span> п.2., с другими страховыми компаниями, брокерами,
  страховыми агентствами.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.21.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Не разглашать и не
  использовать неопубликованную и конфиденциальную информацию, получаемую от
  СТРАХОВЩИКА, и любую другую информацию о деятельности СТРАХОВЩИКА, его
  деловых операциях или методах их осуществления, не определенную СТРАХОВЩИКОМ
  для разглашения, в течение срока действия данного Договора или после того,
  как срок его действия истечет.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.22.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В случае нарушения
  АГЕНТОМ одной из указанных в настоящем разделе обязанностей СТРАХОВЩИК имеет
  право в одностороннем порядке расторгнуть настоящий Договор и потребовать
  возмещения убытков в порядке, предусмотренном действующим законодательством
  РФ.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.23.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В рамках настоящего
  Договора АГЕНТ имеет право:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.24.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получить от
  СТРАХОВЩИКА информацию и документацию, необходимую для осуществления им
  указанных <span class=GramE>в</span> п. 1., 2. <span class=GramE>настоящего</span>
  Договора функций, включая правила страхования, бланки заявлений-анкет, и т.д.
  Объем и характер данной информации и документации определяет СТРАХОВЩИК.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.25.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получать от
  СТРАХОВЩИКА консультации по вопросам, связанным с выполнением условий
  настоящего Договора;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.26.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Получать за
  оказанные им услуги от СТРАХОВЩИКА агентское вознаграждение в размере,
  указанном в <a href="#_Приложение_№_1"><span style='font-size:10.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman";color:windowtext;
  text-decoration:none;text-underline:none'>Приложении <span style='mso-bookmark:
  _Hlt126917995'>№</span>1</span></a><![if !supportNestedAnchors]><a
  name="_Hlt126917995"></a><![endif]> к настоящему Договору.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.27.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В рамках настоящего
  Договора СТРАХОВЩИК имеет право:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.28.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Контролировать
  деятельность АГЕНТА по выполнению обязательств по настоящему Договору.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.29.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В любое время
  требовать от АГЕНТА письменного отчета о ходе исполнения АГЕНТОМ условий
  настоящего Договора. <o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.30.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Контактировать с
  клиентом АГЕНТА напрямую, информируя АГЕНТА о любых такого рода контактах, в
  случае возникновения необходимости уточнения информации, содержащейся в
  заявлении на страхование.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.31.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Без какого-либо
  предварительного уведомления АГЕНТА:<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l2 level1 lfo4;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>предлагать или предоставлять
  любому другому лицу право на осуществление любой посреднической деятельности
  по страхованию от имени СТРАХОВЩИКА;<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l2 level1 lfo4;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>изменять страховые
  тарифы и условия страхования, на условиях, оговоренных <span class=GramE>в</span>
  п.5.5. <span class=GramE>настоящего</span> Договора.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:.5in;text-indent:-.25in;
  line-height:normal;mso-list:l2 level1 lfo4;tab-stops:list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>удерживать
  причитающееся АГЕНТУ агентское вознаграждение или его часть в счет погашения
  ущерба, нанесенного СТРАХОВЩИКУ по вине АГЕНТА, в случаях предусмотренных
  настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>2.32.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>В одностороннем
  порядке изменять размер агентского вознаграждения по вновь заключаемым
  договорам страхования (полисам) путем письменного уведомления АГЕНТА. В
  случае несогласия АГЕНТА с новыми ставками агентского вознаграждения АГЕНТ
  имеет право расторгнуть настоящий Договор, предварительно за 10 (десять)
  рабочих дней уведомив об этом СТРАХОВЩИКА.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:14.2pt;text-align:justify'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>В рамках настоящего Договора СТРАХОВЩИК обязан:<o:p></o:p></span></b></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Своевременно
  обеспечивать АГЕНТА всеми необходимыми документами и материалами,<span
  style='mso-spacerun:yes'>  </span>определяемыми СТРАХОВЩИКОМ и необходимыми
  для осуществления деятельности, предусмотренной настоящим Договором.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Выплачивать АГЕНТУ установленное
  в соответствии с разделом 6 настоящего Договора и Приложением № 1 агентское
  вознаграждение.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Подтверждать, что
  СТРАХОВЩИК имеет в соответствии с действующим законодательством право
  осуществлять страховую деятельность на территории РФ по указанным <span
  class=GramE>в</span> п. 2. <span class=GramE>настоящего</span> Договора видам
  страхования.<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent2 style='margin-left:19.5pt;text-indent:-19.5pt;
  line-height:normal;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-list:Ignore'>3.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-spacerun:yes'> </span>Своевременно уведомлять АГЕНТА о вносимых
  изменениях в действующие условия страхования, страховые тарифы, порядок
  заключения договоров страхования. <o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Расчеты по настоящему Договору.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>4.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>За выполнение обязанностей по настоящему
  Договору, Компания выплачивает АГЕНТУ вознаграждение. Размер и порядок
  выплаты вознаграждения указаны в «Положении об агентском вознаграждении
  АГЕНТОВ – физических лиц» (<b style='mso-bidi-font-weight:normal'>Приложении
  № 1</b> к настоящему Договору).<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>4.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Расходы, понесенные АГЕНТОМ в связи с
  исполнением настоящего Договора, компенсируются за счет агентского
  вознаграждения и дополнительно не оплачиваются, если соглашением Сторон не
  будет предусмотрено иное.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>4.3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>СТРАХОВЩИК обязуется выплачивать
  агентское вознаграждение АГЕНТУ за каждый договор страхования, который был
  заключен при осуществлении АГЕНТОМ своих обязанностей по настоящему Договору,
  предусмотренных <span class=GramE>в</span> п.п. 1., 2. <span class=GramE>настоящего</span>
  Договора, в соответствии с условиями «Положения об агентском вознаграждении
  АГЕНТОВ – физических лиц» (<a href="#_Приложение_№_1">Приложение № 1</a> к
  настоящему Договору), являющемуся неотъемлемой частью настоящего Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>4.4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  class=GramE><span lang=RU style='mso-ansi-language:RU'>В случае расторжения
  договора страхования, заключенного при посредничестве АГЕНТА, на этапе
  действия выжидательного периода, в результате которого Страхователю
  выплачивается сумма в размере внесенного первого или единовременного взноса в
  полном объеме или за вычетом расходов Страховщика по медицинскому
  обследованию, Страховщик имеет право потребовать от Агента возврата
  полученного по данному договору агентского вознаграждения в полном объеме.</span></span><span
  lang=RU style='mso-ansi-language:RU'><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>4.5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Если Страховщик решит воспользоваться
  правом истребования от Агента указанных в пункте 6.4. сумм, Страховщик
  направляет Агенту Уведомление (письмо) с требованием возврата агентского
  вознаграждения. Уведомление может быть передано Агенту (его законному или
  уполномоченному представителю) лично под расписку или иным способом,
  подтверждающим факт и дату его получения. В случае, когда указанные лица
  уклоняются от получения Уведомления, данное Уведомление направляется Агенту
  по почте заказным письмом. В таком случае Уведомление с требованием возврата
  агентского вознаграждения считается полученным по истечении шести дней <span
  class=GramE>с даты направления</span> заказного письма. Агент обязан вернуть
  агентское вознаграждение Страховщику в течение 5 (пяти) банковских дней путем
  безналичного перечисления указанной в Уведомлении суммы на расчетный счет
  Страховщика, указанный в Агентском Договоре.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='mso-ansi-language:RU'>В случае невозврата АГЕНТОМ данных сумм
  в указанные в сроки, Страховщик вправе производить их удержание из любых
  сумм, подлежащих выплате АГЕНТУ СТРАХОВЩИКОМ до тех пор, пока сумма возврата
  агентского вознаграждения не будет возвращена СТРАХОВЩИКУ в полном объеме.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Форс-мажор<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>5.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Стороны освобождаются от ответственности
  за неисполнение или<span style='mso-spacerun:yes'>  </span>ненадлежащее
  исполнение своих обязанностей по настоящему Договору, если это явилось
  следствием действий обстоятельств непреодолимого и чрезвычайного характера
  (форс-мажор), к которым относятся стихийные бедствия, пожары, землетрясения,
  террористические акты, военные действия, массовые беспорядки и т. д.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>5.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>О возникновении и прекращении таких
  обстоятель<span class=GramE>ств ст</span>ороны должны уведомлять друг друга
  любым доступным<span style='mso-spacerun:yes'>  </span>им способом в течение
  5 (пяти) дней с момента их возникновения.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>5.3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>По требованию стороны, не затронутой
  форс-мажором, наличие обстоятельств непреодолимой силы должно подтверждаться
  справками государственных органов.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>6.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Конфиденциальность<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>6.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  class=GramE><span lang=RU style='mso-ansi-language:RU'>Стороны</span></span><span
  lang=RU style='mso-ansi-language:RU'> как во время, так и после прекращения
  действия настоящего Договора обязуются не передавать третьим лицам без
  заранее полученного в каждом конкретном случае от другой стороны письменного
  согласия, прямо или косвенно, никакой информации о клиентах, физических и
  юридических лицах, контактах, способах установления контактов, источниках
  информации, способах выхода и доступа к источникам информации, источниках
  происхождения, способах приобретения услуг, свойствах услуг, информацию, <span
  class=GramE>содержащую в себе информационные и организационные ноу-хау,
  ноу-хау в области юридических формулировок, позиций и приемов при ведении переговоров
  и другие ноу-хау, которые могут быть известны сторонам, как с ведома, так и
  без ведома другой стороны настоящего Договора.</span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>6.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>В случае<span class=GramE>,</span> если
  одной из Сторон будет нанесен ущерб в результате действий другой Стороны,
  которая несанкционированно придаст огласке указанную в п. 8.1. информацию,
  потерпевшая Сторона имеет право потребовать от другой Стороны возмещения
  вреда, нанесенного вследствие нарушения условий конфиденциальности в порядке
  и размере, предусмотренных законодательством. <o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;mso-fareast-language:EN-US;layout-grid-mode:line'><span
  style='mso-list:Ignore'>7.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Срок действия договора. </span></b><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;mso-fareast-language:EN-US;layout-grid-mode:line'>Настоящий
  Договор заключен на неопределенный период и вступает в силу с момента его
  подписания Сторонами.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>8.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-spacerun:yes'> </span></span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Условия
  расторжения настоящего договора</span></b><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt'>.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>8.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'><span
  style='mso-spacerun:yes'> </span>Каждая из Сторон вправе отказаться от
  настоящего Договора в одностороннем порядке с обязательным письменным
  уведомлением другой стороны за 30 (тридцать) календарных дней до даты
  предполагаемого расторжения Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
  RU'>Уведомление (письмо) о расторжении Агентского Договора может быть
  передано каждой из Сторон (ее законному или уполномоченному представителю) лично
  под расписку или иным способом, подтверждающим факт и дату его получения. В
  случае, когда указанные лица уклоняются от получения Уведомления, данное
  Уведомление направляется по почте заказным письмом. В таком случае
  Уведомление о расторжении Агентского Договора считается полученным по
  истечении шести дней <span class=GramE>с даты направления</span> заказного
  письма.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>8.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>При окончании или досрочном прекращении
  настоящего Договора Стороны обязаны выполнить все обязательства,
  предусмотренные настоящим Договором и законодательством РФ.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>9.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Разрешение споров<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>9.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Стороны будут всячески содействовать
  сохранению и выполнению принятых на себя намерений и обязательств.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>9.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Все споры и разногласия, которые могут
  возникнуть из настоящего Договора, будут по возможности решаться путем
  двусторонних переговоров.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>9.3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>В случае невозможности урегулирования
  споров и разногласий путем переговоров, разрешение споров и разногласий
  производится в соответствии с действующим законодательством Российской
  Федерации.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>9.4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp; </span></span></span><![endif]><span
  lang=RU style='mso-ansi-language:RU'>Стороны договариваются, что все споры,
  вытекающие из настоящего договора, неурегулированные на стадии переговоров,
  подлежат рассмотрению в суде по месту государственной регистрации
  Страховщика.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>10.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Ответственность сторон.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt left 42.55pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>10.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>За
  невыполнение положений настоящего Договора стороны несут ответственность в
  соответствии с действующим законодательством Российской Федерации.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'><span style='mso-list:Ignore'>11.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;
  </span></span></span></b><![endif]><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;layout-grid-mode:
  line'>Заключительные положения.<o:p></o:p></span></b></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.1.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span class=GramE><span lang=RU
  style='mso-ansi-language:RU'>Стороны заявляют, что они не находятся в
  заблуждении относительно смысла настоящего Договора, что условия настоящего
  Договора не являются кабальными в смысле Гражданского законодательства РФ,
  что данный Договор не является мнимой или притворной сделкой, что данная
  сделка не противоречит чьим-либо интересам, что представители Сторон
  находятся в обычном для них состоянии здоровья, что Стороны не подписали
  данный Договор под прямой или косвенной</span></span><span lang=RU
  style='mso-ansi-language:RU'> угрозой другой стороны либо третьих лиц, что
  данная сделка не совершена под влиянием обмана, что Стороны осознают
  возможные последствия несоблюдения своих обязательств, вытекающих из
  настоящего Договора.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Все
  приложения к данному Договору составляют его составную и неотъемлемую часть.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Все
  дополнения, приложения и изменения к настоящему Договору будут
  действительными и иметь юридическую силу, если они будут выполнены в
  письменной форме и подписаны обеими Сторонами.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Во
  всем, что не урегулировано данным Договором, Стороны будут руководствоваться
  действующим Гражданским законодательством Российской Федерации.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Настоящий
  Договор составлен в 2-х экземплярах: один - для СТРАХОВЩИКА, другой - для
  АГЕНТА. Оба экземпляра имеют одинаковую юридическую силу.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:19.5pt;text-align:justify;text-indent:
  -19.5pt;mso-list:l5 level2 lfo1;tab-stops:list 19.5pt'><![if !supportLists]><span
  lang=RU style='mso-ansi-language:RU'><span style='mso-list:Ignore'>11.6.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='mso-ansi-language:RU'>Стороны
  признают факсимильно воспроизведенную подпись подлинной (Ч. 2 ст. 160 ГК РФ).<o:p></o:p></span></p>
  <p class=MsoBodyTextIndent style='margin-left:0in'><b style='mso-bidi-font-weight:
  normal'><span lang=RU><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoBodyTextIndent style='margin-left:0in'><b style='mso-bidi-font-weight:
  normal'><span lang=RU>ЮРИДИЧЕСКИЕ АДРЕСА И РЕКВИЗИТЫ СТОРОН:<o:p></o:p></span></b></p>
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

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <h2 align=right style='text-align:right'><a name="_Приложение_№_1"></a><span
  lang=RU>Приложение № 1 к Агентскому Договору № <span
  style='mso-spacerun:yes'> </span><%=AGDOGNUM%></span></h2>
  <h2 align=right style='text-align:right'><i style='mso-bidi-font-style:normal'><span
  lang=RU><o:p>&nbsp;</o:p></span></i></h2>
  <h2><span lang=RU>Положение об агентском вознаграждении АГЕНТОВ – физических
  лиц</span></h2>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level1 lfo5'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Общие положения<o:p></o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>1.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее положение является неотъемлемой частью
  Агентского договора № <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>1.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее положение регламентирует условия выплаты
  агентского вознаграждения страховым АГЕНТАМ (далее – АГЕНТ).<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>2.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>За установление
  делового контакта со Страхователями, </span><span lang=RU>результатом
  которого стало заключение последними договоров страхования жизни со
  Страховщиком</span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt'> СТРАХОВЩИК обязуется выплатить АГЕНТУ вознаграждение за каждый такой
  договор страхования в следующие сроки и в следующем порядке. <o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>3.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Агентское
  вознаграждение выплачивается АГЕНТУ за каждый договор страхования,
  заключенный при осуществлении АГЕНТОМ своих обязанностей по Агентскому
  Договору, по которому Страховщик выпустил полис. <o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>4.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>В том случае, если
  договор страхования предусматривает оплату премии по договору страхования в
  рассрочку, агентское вознаграждение выплачивается агенту только за первый год
  действия договора страхования.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>5.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Агентское
  вознаграждение исчисляется от поступивших на расчетный счет СТРАХОВЩИКА
  следующих полностью оплаченных страховых премий (взносов):<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l7 level1 lfo7;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>первых страховых премий (за вычетом суммы
  административных издержек);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l7 level1 lfo7;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>очередных взносов, подлежащих оплате в отчетном
  периоде (за вычетом суммы административных издержек);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l7 level1 lfo7;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>оплаченных в отчетном периоде просроченных
  страховых взносов (за вычетом суммы административных издержек).<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Отчетным
  периодом считается:<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l8 level1 lfo8;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>период с 1-го по 14-е число каждого месяца – 1-й
  ежемесячный отчетный период;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l8 level1 lfo8;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>период с 15-го числа по последнюю дату каждого
  месяца – 2-й ежемесячный отчетный период.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>6.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Выплата агентского
  вознаграждения производится на основании Отчета к Агентскому Договору, за
  подписью АГЕНТА и представителя СТРАХОВЩИКА (<b style='mso-bidi-font-weight:
  normal'><a href="#_Приложение_№_4"><span style='color:windowtext;text-decoration:
  none;text-underline:none'>Приложения №№ <span style='mso-bookmark:_Hlt126919936'>2,3</span></span></a><![if !supportNestedAnchors]><a
  name="_Hlt126919936"></a><![endif]></b> к Агентскому Договору).<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>7.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>СТРАХОВЩИК
  выплачивает агентское вознаграждение АГЕНТУ в течение 3 (трех) рабочих дней с
  момента подписания Отчета к Агентскому Договору обеими сторонами.<o:p></o:p></span></p>
  <p class=1><![if !supportLists]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><span style='mso-list:Ignore'>8.<span
  style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Размер агентского
  вознаграждения.<o:p></o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.5in;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>9.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Размер агентского вознаграждения устанавливается в
  зависимости от следующих параметров:<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l9 level1 lfo9;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>размера подписанной и полностью оплаченной
  страховой премии (взноса) и ставки агентского вознаграждения;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l9 level1 lfo9;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>вида страхования;<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l9 level1 lfo9;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>порядка уплаты страховой премии (единовременно или
  в рассрочку);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l9 level1 lfo9;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>периода уплаты страховой премии (полных
  календарных лет);<o:p></o:p></span></p>
  <p class=1 style='margin-left:.25in;text-indent:-.25in;mso-list:l9 level1 lfo9;
  tab-stops:14.2pt list .25in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Symbol;
  mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol'><span
  style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>порядкового номера года действия договора
  страхования, за который уплачена страховая премия<o:p></o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.5in;tab-stops:14.2pt list .5in'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>10.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Размер агентского
  вознаграждения определяется по следующей формуле: <o:p></o:p></span></p>
  <p class=1 align=center style='margin-left:0in;text-align:center;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>АВ = САВ (%)*СП,<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>где:<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>АВ
  –агентское вознаграждение АГЕНТА;<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>САВ
  - ставка агентского вознаграждения АГЕНТА согласно Базовым размерам ставок
  агентского вознаграждения (см. п. 3. настоящего Приложения). <o:p></o:p></span></p>
  <p class=1 align=left style='margin-left:0in;text-align:left;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>СП – подписанная страховая премия, полностью
  оплаченная Страхователем.<o:p></o:p></span></p>
  <p class=1 align=left style='margin-left:0in;text-align:left;text-indent:
  0in;mso-list:none;tab-stops:14.2pt'><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 align=left style='text-align:left'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.<span style='font:7.0pt "Times New Roman"'> </span></span></span><![endif]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Базовые размеры
  ставок агентского вознаграждения АГЕНТА:<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
</div>



<div class=Section3>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По программе «Гармония жизни» размер агентского
  вознаграждения составляет:<u><o:p></o:p></u></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><u><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p><span
   style='text-decoration:none'>&nbsp;</span></o:p></span></u></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
   mso-padding-alt:0in 1.5pt 0in 1.5pt;mso-border-insideh:.5pt solid windowtext;
   mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=151 rowspan=2 style='width:113.0pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Срок
    действия договора страхования (лет)<o:p></o:p></span></b></p>
    </td>
    <td width=266 style='width:199.45pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии в
    рассрочку:<o:p></o:p></span></b></p>
    </td>
    <td width=133 rowspan=2 style='width:99.75pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии
    единовременно<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:60.0pt'>
    <td width=266 style='width:199.45pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:60.0pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>%
    агентского вознаграждения от страхового взноса за 1-й год действия договора
    по данной программе, оплаченного Страхователем.<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><a name=END><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>10</span></a><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>8,75%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>11</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>9,63%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>10,50%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>13</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>11,38%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>14</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>12,25%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>15</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>13,13%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>16</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>14,00%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>17</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>14,88%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>18</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>15,75%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>19</span><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>16,63%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=151 style='width:113.0pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>больше или равно 20</span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-fareast-font-family:
    "Arial Unicode MS"'><o:p></o:p></span></p>
    </td>
    <td width=266 valign=bottom style='width:199.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>17,50%</p>
    </td>
    <td width=133 valign=bottom style='width:99.75pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=MsoNormal align=center style='text-align:center'>2,50%</p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='text-align:justify'><u><span lang=RU
  style='mso-ansi-language:RU'><o:p><span style='text-decoration:none'>&nbsp;</span></o:p></span></u></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По программам «Лучшее будущее», «Жизнь под моим
  контролем», «Успешный старт» размер агентского вознаграждения составляет:<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
   mso-padding-alt:0in 1.5pt 0in 1.5pt;mso-border-insideh:.5pt solid windowtext;
   mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=151 rowspan=2 style='width:113.25pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Срок
    действия договора страхования (лет)<o:p></o:p></span></b></p>
    </td>
    <td width=264 style='width:2.75in;border:solid windowtext 1.0pt;border-left:
    none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
    padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии в
    рассрочку:<o:p></o:p></span></b></p>
    </td>
    <td width=135 rowspan=2 style='width:101.4pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии
    единовременно<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:57.25pt'>
    <td width=264 style='width:2.75in;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:57.25pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>%
    агентского вознаграждения от страхового взноса за 1-й год действия договора
    по данной программе, оплаченного Страхователем.<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><a name=PEPR><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5</span></a><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>*<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>3,75%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6*<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>7*<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5,25%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>8*<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>9*<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,75%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>10<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>8,25%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>9,00%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>9,75%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>10,50%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>11,25%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:13;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12,00%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:14;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12,75%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:15;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>13,50%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:16;page-break-inside:avoid;height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>14,25%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:17;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=151 style='width:113.25pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>больше или равно 20<o:p></o:p></span></p>
    </td>
    <td width=264 valign=bottom style='width:2.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>15,00%<o:p></o:p></span></p>
    </td>
    <td width=135 valign=bottom style='width:101.4pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,50%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>*Данные базовые ставки агентского вознаграждения действительны только для
  программы «Успешный старт»<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify;text-indent:
  -.25in;mso-text-indent-alt:0in;mso-list:none;mso-list-ins:SvionVe 20060210T1311'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительным программам (опциям к основным
  программам) «Гармония жизни», «Лучшее будущее», «Жизнь под моим контролем»,
  «Успешный старт»), за исключением дополнительных программ (опций) «Инвест» и
  «Страхование от несчастных случаев», базовый размер ставки агентского
  вознаграждения равен базовому размеру ставки агентского вознаграждения по
  основной программе страхования. <o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительной программе «Инвест» к основным программам
  «Гармония жизни», «Лучшее будущее», «Жизнь под моим контролем», «Успешный
  старт» размер агентского вознаграждения составляет:<o:p></o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
   mso-padding-alt:0in 1.5pt 0in 1.5pt;mso-border-insideh:.5pt solid windowtext;
   mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=150 rowspan=2 style='width:112.15pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Срок
    действия договора страхования (лет)<o:p></o:p></span></b></p>
    </td>
    <td width=265 valign=top style='width:198.9pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии в
    рассрочку:<o:p></o:p></span></b></p>
    </td>
    <td width=133 rowspan=2 style='width:99.45pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии
    единовременно:<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:61.05pt'>
    <td width=265 style='width:198.9pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:61.05pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>%
    агентского вознаграждения от страхового взноса за 1-й год действия договора
    по данной программе, оплаченного Страхователем.<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1 - <a name=I>10</a><o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,00%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,10%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,20%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,30%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,40%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,50%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,60%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,70%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,80%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>1,90%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>больше или равно 20<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>2,00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительной программе «Страхование от
  несчастных случаев» к основным программам «Гармония жизни», «Лучшее будущее»,
  «Жизнь под моим контролем», «Успешный старт» размер агентского вознаграждения
  составляет:<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:.25in;text-align:justify'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
   mso-padding-alt:0in 1.5pt 0in 1.5pt;mso-border-insideh:.5pt solid windowtext;
   mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=150 rowspan=2 style='width:112.15pt;border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>Срок
    действия договора страхования (лет)<o:p></o:p></span></b></p>
    </td>
    <td width=265 style='width:198.9pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии в
    рассрочку:<o:p></o:p></span></b></p>
    </td>
    <td width=133 rowspan=2 style='width:99.45pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
    договорам страхования, предусматривающим уплату страховой премии
    единовременно:<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:66.25pt'>
    <td width=265 style='width:198.9pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:66.25pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><b style='mso-bidi-font-weight:
    normal'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>%
    агентского вознаграждения от страхового взноса за 1-й год действия договора
    по данной программе, оплаченного Страхователем.<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5 - <a name="ACC_r">10</a><o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>4,50%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>11<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>4,80%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>12<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5,10%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>13<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5,40%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>14<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>5,70%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:7;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>15<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:8;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>16<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,30%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:9;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>17<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,60%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>18<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,90%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:11;page-break-inside:avoid;height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>19<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>7,20%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:12.35pt'>
    <td width=150 style='width:112.15pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>больше или равно 20<o:p></o:p></span></p>
    </td>
    <td width=265 valign=bottom style='width:198.9pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>7,50%<o:p></o:p></span></p>
    </td>
    <td width=133 valign=bottom style='width:99.45pt;border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 1.5pt 0in 1.5pt;
    height:12.35pt'>
    <p class=1 align=center style='margin-left:0in;text-align:center;
    text-indent:0in;mso-list:none;tab-stops:14.2pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>6,00%<o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.6.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По программе «Моя защита» размер агентского
  вознаграждения составляет 7,50% от страхового взноса, оплаченного
  Страхователем.<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.7.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По договорам группового страхования, заключенным в
  соответствии с «Общими условиями группового страхования жизни и от несчастных
  случаев (пакетные программы страхования)» и с «Общими условиями группового
  страхования жизни и страхования от несчастных случаев»<span style='color:
  blue'> </span>размер агентского вознаграждения составляет 6,00% от страхового
  взноса, оплаченного Страхователем.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.8.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительным программам (опциям к основным
  программам) к договорам группового страхования, заключенным в соответствии с «Общими
  условиями группового страхования жизни и от несчастных случаев (пакетные
  программы страхования)» и с «Общими условиями группового страхования жизни и
  страхования от несчастных случаев», за исключением дополнительной программы
  (опции) «Инвест», базовый размер ставки агентского вознаграждения равен
  базовому размеру ставки агентского вознаграждения по основной программе
  страхования.<o:p></o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.9.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительной программе «Инвест» к основной
  программе к договорам группового страхования, заключенным в соответствии с
  «Общими условиями группового страхования жизни и от несчастных случаев
  (пакетные программы страхования)»<span style='color:blue'> </span><span
  style='mso-spacerun:yes'> </span>размер агентского вознаграждения составляет
  1,90 % от страхового взноса, оплаченного Страхователем.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.10.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По дополнительной программе «Инвест» к основной
  программе к договорам группового страхования, заключенным в соответствии с
  «Общими условиями группового страхования жизни и страхования от несчастных
  случаев», основное агентское вознаграждение не выплачивается.<o:p></o:p></span></p>
  <p class=1 style='mso-list:none;tab-stops:14.2pt'><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='mso-list:l5 level2 lfo6'><![if !supportLists]><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-list:Ignore'>11.11.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>По программе «ЖиНС» размер агентского
  вознаграждения составляет 6,00% от страхового взноса, оплаченного
  Страхователем.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'>По
  всем дополнительным программ (опциям) к основной программе «ЖиНС» размер
  агентского вознаграждения равен базовому размеру ставки агентского вознаграждения
  по основной программе страхования.<o:p></o:p></span></p>
  <p class=1 style='margin-left:0in;text-indent:0in;mso-list:none;tab-stops:
  14.2pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
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
</div>

<span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
mso-fareast-font-family:"Times New Roman";mso-ansi-language:EN-US;mso-fareast-language:
EN-US;mso-bidi-language:AR-SA;layout-grid-mode:line'><br clear=all
style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section4>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <h2 align=right style='text-align:right'><a name="_Приложение_№_4"></a><a
  name="_Приложение_№_3"></a><span lang=RU>Приложение № 2 к Агентскому Договору
  № <%=AGDOGNUM%></span></h2>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l0 level1 lfo10;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение является неотъемлемой частью
  Агентского договора № <%=AGDOGNUM%>.<o:p></o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l0 level1 lfo10;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение устанавливает форму Отчета
  Агента к Агентскому договору, на основании которого выплачивается агентское
  вознаграждение. <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА
  № АВ-__<o:p></o:p></span></p>
  
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=659 colspan=2 valign=top style='width:494.45pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 style='margin-top:0in;margin-right:1.35pt;margin-bottom:0in;
    margin-left:0in;margin-bottom:.0001pt;tab-stops:467.8pt'><span lang=RU
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Агентский
    Договор № <span style='mso-spacerun:yes'> </span><%=AGDOGNUM%><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
    <td width=344 valign=top style='width:257.7pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'>г. Москва</span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
    <td width=316 valign=top style='width:236.75pt;padding:0in 5.4pt 0in 5.4pt'>
    <p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;tab-stops:467.8pt'><a name="treaty_date"><span
    style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    mso-ansi-language:EN-US;font-weight:normal'><%=REG_DATE%></span></a><span
    style='mso-bookmark:treaty_date'><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman";font-weight:normal'>.</span></span><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; <o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
  style='mso-tab-count:1'>            </span><%=ORGNAME%>, именуемое в
  дальнейшем Страховщик, в лице Генерального директора г-на
  <%=CHIEF_NAME%>, действующего на основании Устава, с одной стороны,
  и<span style='mso-spacerun:yes'>  </span><%=AGNAME%>,
  паспорт серии </span><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
  mso-ansi-language:EN-US'><%=PS%></span><span lang=RU style='font-size:
  11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'> № </span><span style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;font-family:"Times New Roman";mso-ansi-language:
  EN-US'><%=PNUM%></span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
  10.0pt;font-family:"Times New Roman"'>, именуемый (ая) в дальнейшем АГЕНТ, с
  другой стороны, составили и утвердили настоящий отчет к Агентскому договору о
  нижеследующем.<o:p></o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'>
  <span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
  За период с
  &lt;ДАТА&gt; по &lt;ДАТА&gt; в результате установленных Агентом деловых
  контактов со Страхователями при посредничестве Агента были заключены
  следующие договоры страхования, по которым на расчетный счет страховщика
  поступила страховая премия в полном объеме:<o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <div align=center>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:11.25pt'>
    <td width=127 valign=top style='width:95.35pt;border:solid windowtext 1.0pt;
    border-bottom:none;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
    </td>
    <td width=96 valign=top style='width:1.0in;border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
    </td>
    <td width=96 rowspan=2 style='width:1.0in;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
    </td>
    <td width=86 rowspan=2 style='width:64.4pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
    </td>
    <td width=72 rowspan=2 style='width:.75in;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
    </td>
    <td width=96 rowspan=2 style='width:1.0in;border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора<o:p></o:p></span></b></p>
    </td>
    <td width=81 rowspan=2 style='width:61.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
    </td>
    <td width=87 rowspan=2 style='width:65.0pt;border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:11.25pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=127 valign=top style='width:95.35pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата установления делового
    контакта со Страхователем<o:p></o:p></span></b></p>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>(дата телефонного звонка)<o:p></o:p></span></b></p>
    </td>
    <td width=96 valign=top style='width:1.0in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Время, место состоявшейся
    встречи со Страхователем<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=127 valign=top style='width:95.35pt;border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=96 valign=top style='width:1.0in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=96 valign=bottom style='width:1.0in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=86 valign=bottom style='width:64.4pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=72 valign=bottom style='width:.75in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=96 valign=bottom style='width:1.0in;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=81 valign=bottom style='width:61.0pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=87 valign=bottom style='width:65.0pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  </div>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:.5in 334.45pt'><span
  lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
  Агентское вознаграждение за отчетный период составляет:
  ________. Расчет агентского вознаграждения прилагается к настоящему отчету.</span><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
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
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
  lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

</div>

<span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br
clear=all style='page-break-before:always;mso-break-type:section-break'>
</span>

<div class=Section5>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=662
 style='width:6.9in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=662 valign=top style='width:6.9in;padding:0in 5.4pt 0in 5.4pt'>
  <h2 align=right style='text-align:right'><span lang=RU>Приложение № 3<span
  style='mso-spacerun:yes'>  </span>к Агентскому Договору № <%=AGDOGNUM%></span></h2>
  <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=1 style='margin-left:.5in;text-indent:-.25in;mso-list:l4 level1 lfo11;
  tab-stops:14.2pt list .5in'><![if !supportLists]><span lang=RU
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt'><span style='mso-list:
  Ignore'>1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span></span></span><![endif]><span lang=RU style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt'>Настоящее Приложение является неотъемлемой частью
  Агентского договора № <%=AGDOGNUM%><o:p></o:p></span></p>
  <ol style='margin-top:0in' start=2 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l4 level1 lfo11;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='mso-ansi-language:RU'>Настоящее Приложение устанавливает
       форму Расчета агентского вознаграждения.</span><span lang=RU
       style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
       mso-ansi-language:RU'><o:p></o:p></span></li>
  </ol>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Расчет
  агентского вознаграждения к отчету Агента от &lt;ДАТА&gt; к Агентскому
  договору<span style='mso-spacerun:yes'>  </span><%=AGDOGNUM%><o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Агентское
  вознаграждение выплачивается в соответствии с условиями агентского договора №<%=AGDOGNUM%>.
  <o:p></o:p></span></p>
  <ol style='margin-top:0in' start=1 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l3 level1 lfo12;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:
       "Times New Roman";mso-ansi-language:RU'>За период с &lt;ДАТА&gt; по
       &lt;ДАТА&gt; АГЕНТ получает агентское вознаграждение за следующие
       договоры страхования, заключенные при его посредничестве:<o:p></o:p></span></li>
  </ol>
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
  <ol style='margin-top:0in' start=2 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l3 level1 lfo12;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:
       "Times New Roman";mso-ansi-language:RU'>За период с &lt;ДАТА&gt; по
       &lt;ДАТА&gt; были расторгнуты следующие договоры страхования,
       заключенные Страховщиком при посредничестве Агента. В соответствии с п.
       2.24., 6.6., 6.7. Агентского договора, часть агентского вознаграждения
       по этим договорам удержана из агентского вознаграждения Агента в
       соответствии с таблицей, приведенной ниже.<o:p></o:p></span></li>
  </ol>
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
  <ol style='margin-top:0in' start=3 type=1>
   <li class=MsoNormal style='text-align:justify;mso-list:l3 level1 lfo12;
       tab-stops:list .5in;mso-layout-grid-align:none;text-autospace:none'><span
       lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:
       "Times New Roman";mso-ansi-language:RU'>Итого размер агентского
       вознаграждения за период с &lt;ДАТА&gt; по &lt;ДАТА&gt; составляет: </span><span
       lang=RU style='mso-ansi-language:RU'>&lt;Сумма из </span><span lang=RU
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
  </ol>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
  text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Сумма агентского
  вознаграждения, указанная в п. 3., определена правильно.<o:p></o:p></span></p>
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
  <h2 align=left style='text-align:left;tab-stops:105.75pt'><a
  name="_Приложение_№_5_к_Агентскому_Договор"></a><a
  name="_Приложение_№_6_к_Агентскому_Договор"></a><span lang=RU><span
  style='mso-tab-count:1'>                                   </span></span></h2>
  </td>
 </tr>
</table>

<p class=MsoNormal style='layout-grid-mode:both'><span style='font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>

</div>
</rw:foreach>
</body>

</html>
</rw:report>
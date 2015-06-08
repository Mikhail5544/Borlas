<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report"> 

<rw:objects id="objects">

<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_agent_model" DTDVersion="9.0.2.0.10"
beforeReportTrigger="afterpform" unitOfMeasurement="centimeter">
  <xmlSettings xmlTag="AG_DOG_AGENT_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
<userParameter name="AG" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
<userParameter name="AG_ACC" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
<userParameter name="D" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
<userParameter name="D_DAT" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
 <userParameter name="NUM_VER" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
<userParameter name="DEPT" datatype="character" width="400"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[ SELECT ach.agent_id, ach.ag_contract_header_id,
       ent.obj_name (246, ach.agent_id) agent_name,
       nvl((select instrumental from contact where contact_id = ach.agent_id),
           ent.obj_name (246, ach.agent_id) ) agent_name_ins,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || d.num num,
       d.reg_date,
       ach.date_begin,
       NVL(pkg_contact.get_address_name(pkg_contact.get_primary_address (ach.agent_id) ),'@' ) addr,
       nvl(ac.leg_pos,0) leg_pos,
       dept_exe.contact_id dir_contact_id,
       decode(nvl(lower(vtt.description),'г-н'),'г-н','г-на','г-жа','г-жи',lower(vtt.description)) g_n,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name 
  FROM ven_ag_contract_header ach,
       ven_ag_contract ac,
       ven_department dep,
       ven_document d,
       ven_dept_executive dept_exe,
       ven_cn_person vcp,
       VEN_T_TITLE vtt
 WHERE ac.ag_contract_id = ach.last_ver_id
   AND ach.agency_id = dep.department_id(+)
   AND d.document_id = ach.ag_contract_header_id
   AND ach.agency_id = dept_exe.department_id(+)
   AND dept_exe.contact_id = vcp.contact_id(+)
   AND vcp.title = vtt.ID(+)
   AND ach.ag_contract_header_id = :p_ch_id;]]>
      </select>
      <displayInfo x="2.02087" y="0.19800" width="0.92700" height="0.35608"/>
      <group name="G_AGENT">
        <displayInfo x="1.68066" y="0.76245" width="1.81714" height="2.48145"
        />
        <dataItem name="G_N" datatype="vchar2" columnOrder="47" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="G N">
          <dataDescriptor expression="G_N" descriptiveExpression="G_N"
           order="11" width="255"/>
        </dataItem>
        <dataItem name="AGENT_NAME_INS" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name Ins">
          <dataDescriptor expression="AGENT_NAME_INS"
           descriptiveExpression="AGENT_NAME_INS" order="4" width="4000"/>
        </dataItem>
        <dataItem name="DATE_BEGIN" datatype="date" oracleDatatype="date"
         columnOrder="21" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="22" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="10"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="dir_name" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="12" width="4000"/>
        </dataItem>
        <dataItem name="LEG_POS" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Leg Pos">
          <dataDescriptor expression="LEG_POS" descriptiveExpression="LEG_POS"
           order="9" oracleDatatype="number" width="22" scale="-127"/>
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
        <dataItem name="chief_name" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="24" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="25" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="26"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="27" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="28" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="29"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="30"
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
      <displayInfo x="4.07288" y="0.04163" width="0.69995" height="0.32983"/>
      <group name="G_AGENT_ADDR">
        <displayInfo x="4.13330" y="0.68945" width="1.09998" height="0.77246"
        />
        <dataItem name="pref" datatype="vchar2" columnOrder="34"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="32" width="4000"
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
         DECODE (TO_CHAR (NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY') ),'DD.MM.YYYY' ),
                 '01.01.1900', '@', TO_CHAR (cci.issue_date, 'DD.MM.YYYY') ) data_v
    FROM ven_cn_person vcp, ven_cn_contact_ident cci, ven_t_id_type tit
   WHERE vcp.contact_id = cci.contact_id
     AND cci.id_type = tit.ID
     AND UPPER (tit.brief) IN ('PASS_RF','OGRN' ,'REG_SVID','INN','PENS')   
]]>
      </select>
      <displayInfo x="4.09375" y="1.57288" width="1.11462" height="0.32996"/>
      <group name="G_AG_DOCS">
        <displayInfo x="4.04541" y="2.19995" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="35"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="36"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <xmlSettings xmlTag="DOC_DESC1"/>
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="37" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="38" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="39" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="40"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
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
      <displayInfo x="3.80212" y="3.58337" width="1.13538" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="4.07690" y="4.28333" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID1" oracleDatatype="number" columnOrder="41"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="42"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser1" datatype="vchar2" columnOrder="43" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser1">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num1" datatype="vchar2" columnOrder="44" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num1">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan1" datatype="vchar2" columnOrder="45"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pvidan1">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v1" datatype="vchar2" columnOrder="46"
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


<parameterForm width="27.53350" height="27.53350"/>
  <programUnits>
    <function name="afterpform">
      <textSource>
      <![CDATA[function AfterPForm return boolean is
begin
 
  begin
  SELECT ac.num+1 num_ver,
	dep.name dept,
ag_cont.genitive,
dir_cont.dative
 into :NUM_VER,:DEPT,:AG_ACC, :D_DAT
 FROM ven_ag_contract_header ach,
       ven_ag_contract ac,
       ven_department dep,
       ven_document d,
       ven_dept_executive dept_exe,
       ven_cn_person vcp,
       VEN_T_TITLE vtt,
       contact ag_cont,
       contact dir_cont
 WHERE ac.ag_contract_id = ach.last_ver_id
   AND ach.agency_id = dep.department_id(+)
   and ag_cont.contact_id = ach.agent_id(+)
   and dir_cont.contact_id = dept_exe.contact_id
   AND d.document_id = ach.ag_contract_header_id
   AND ach.agency_id = dept_exe.department_id(+)
   AND dept_exe.contact_id = vcp.contact_id(+)
   AND vcp.title = vtt.ID(+)
   AND ach.ag_contract_header_id = :p_ch_id;
  exception
      when no_data_found then :NUM_VER := ''; :DEPT := ''; :AG_ACC := ''; :D_DAT := '';
  end;

 return (TRUE);

   end;]]>
      </textSource>
    </function>
 </programUnits>


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
<link rel=File-List href="ag_dog_agent.files/filelist.xml">
<link rel=Edit-Time-Data href="ag_dog_agent.files/editdata.mso">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title>Приложение №2 </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>abudkova</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>Khomich</o:LastAuthor>
  <o:Revision>9</o:Revision>
  <o:TotalTime>7</o:TotalTime>
  <o:Created>2007-03-26T07:04:00Z</o:Created>
  <o:LastSaved>2007-03-26T07:35:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>11253</o:Words>
  <o:Characters>64145</o:Characters>
  <o:Lines>534</o:Lines>
  <o:Paragraphs>150</o:Paragraphs>
  <o:CharactersWithSpaces>75248</o:CharactersWithSpaces>
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
	{font-family:Helvetica;
	panose-1:2 11 5 4 2 2 2 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Courier;
	panose-1:2 7 4 9 2 2 5 2 4 4;
	mso-font-charset:0;
	mso-generic-font-family:modern;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Tms Rmn";
	panose-1:2 2 6 3 4 5 5 2 3 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Helv;
	panose-1:2 11 6 4 2 2 2 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"New York";
	panose-1:2 4 5 3 6 5 6 2 3 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:System;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"MS Mincho";
	panose-1:2 2 6 9 4 2 5 8 3 4;
	mso-font-alt:"\FF2D\FF33 \660E\671D";
	mso-font-charset:128;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 134676480 16 0 131072 0;}
@font-face
	{font-family:Batang;
	panose-1:2 3 6 0 0 1 1 1 1 1;
	mso-font-alt:\BC14\D0D5;
	mso-font-charset:129;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 151388160 16 0 524288 0;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;
	mso-font-alt:\5B8B\4F53;
	mso-font-charset:134;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 135135232 16 0 262144 0;}
@font-face
	{font-family:PMingLiU;
	panose-1:2 1 6 1 0 1 1 1 1 1;
	mso-font-alt:\65B0\7D30\660E\9AD4;
	mso-font-charset:136;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 134742016 16 0 1048576 0;}
@font-face
	{font-family:"MS Gothic";
	panose-1:2 11 6 9 7 2 5 8 2 4;
	mso-font-alt:"\FF2D\FF33 \30B4\30B7\30C3\30AF";
	mso-font-charset:128;
	mso-generic-font-family:modern;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 134676480 16 0 131072 0;}
@font-face
	{font-family:Dotum;
	panose-1:2 11 6 0 0 1 1 1 1 1;
	mso-font-alt:\B3CB\C6C0;
	mso-font-charset:129;
	mso-generic-font-family:modern;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 151388160 16 0 524288 0;}
@font-face
	{font-family:SimHei;
	panose-1:2 1 6 0 3 1 1 1 1 1;
	mso-font-alt:\9ED1\4F53;
	mso-font-charset:134;
	mso-generic-font-family:modern;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 135135232 16 0 262144 0;}
@font-face
	{font-family:MingLiU;
	panose-1:2 1 6 9 0 1 1 1 1 1;
	mso-font-alt:\7D30\660E\9AD4;
	mso-font-charset:136;
	mso-generic-font-family:modern;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 134742016 16 0 1048576 0;}
@font-face
	{font-family:Mincho;
	panose-1:2 2 6 9 4 3 5 8 3 5;
	mso-font-alt:\660E\671D;
	mso-font-charset:128;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 134676480 16 0 131072 0;}
@font-face
	{font-family:Gulim;
	panose-1:2 11 6 0 0 1 1 1 1 1;
	mso-font-alt:\AD74\B9BC;
	mso-font-charset:129;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:fixed;
	mso-font-signature:1 151388160 16 0 524288 0;}
@font-face
	{font-family:Century;
	panose-1:2 4 6 3 5 7 5 2 3 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Angsana New";
	panose-1:2 2 6 3 5 4 5 2 3 4;
	mso-font-charset:222;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:16777217 0 0 0 65536 0;}
@font-face
	{font-family:"Cordia New";
	panose-1:2 11 3 4 2 2 2 2 2 4;
	mso-font-charset:222;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:16777217 0 0 0 65536 0;}
@font-face
	{font-family:Mangal;
	panose-1:0 0 4 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:32771 0 0 0 1 0;}
@font-face
	{font-family:Latha;
	panose-1:2 0 4 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:1048579 0 0 0 1 0;}
@font-face
	{font-family:Sylfaen;
	panose-1:1 10 5 2 5 3 6 3 3 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:67110535 0 0 0 159 0;}
@font-face
	{font-family:Vrinda;
	panose-1:0 0 4 0 0 0 0 0 0 0;
	mso-font-charset:1;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Raavi;
	panose-1:2 0 5 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:131075 0 0 0 1 0;}
@font-face
	{font-family:Shruti;
	panose-1:2 0 5 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:262147 0 0 0 1 0;}
@font-face
	{font-family:Sendnya;
	panose-1:0 0 4 0 0 0 0 0 0 0;
	mso-font-charset:1;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Gautami;
	panose-1:2 0 5 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:2097155 0 0 0 1 0;}
@font-face
	{font-family:Tunga;
	panose-1:0 0 4 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:4194307 0 0 0 1 0;}
@font-face
	{font-family:"Estrangelo Edessa";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:-2147459005 0 128 0 1 0;}
@font-face
	{font-family:Kartika;
	panose-1:1 1 1 0 1 1 1 1 1 1;
	mso-font-charset:1;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:0 0 0 0 0 0;}
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
@font-face
	{font-family:Marlett;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Lucida Console";
	panose-1:2 11 6 9 4 5 4 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:-2147482993 6144 0 0 31 0;}
@font-face
	{font-family:"Lucida Sans Unicode";
	panose-1:2 11 6 2 3 5 4 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-2147476737 14699 0 0 63 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"Arial Black";
	panose-1:2 11 10 4 2 1 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Comic Sans MS";
	panose-1:3 15 7 2 3 3 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:Impact;
	panose-1:2 11 8 6 3 9 2 5 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:Georgia;
	panose-1:2 4 5 2 5 4 5 2 3 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Franklin Gothic Medium";
	panose-1:2 11 6 3 2 1 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Palatino Linotype";
	panose-1:2 4 5 2 5 5 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:-536870009 1073741843 0 0 415 0;}
@font-face
	{font-family:Webdings;
	panose-1:5 3 1 2 1 5 9 6 7 3;
	mso-font-charset:2;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"MV Boli";
	mso-font-charset:0;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:3 0 256 0 1 0;}
@font-face
	{font-family:"Microsoft Sans Serif";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421663 -2147483648 8 0 66047 0;}
@font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 5 6 2 2 2 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Book Antiqua";
	panose-1:2 4 6 2 5 3 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Bookman Old Style";
	panose-1:2 5 6 4 5 5 5 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Century Gothic";
	panose-1:2 11 5 2 2 2 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:Garamond;
	panose-1:2 2 4 4 3 3 1 1 8 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"MS Outlook";
	panose-1:5 1 1 0 1 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Monotype Corsiva";
	panose-1:3 1 1 1 1 2 1 1 1 1;
	mso-font-charset:204;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Wingdings 2";
	panose-1:5 2 1 2 1 5 7 7 7 7;
	mso-font-charset:2;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Wingdings 3";
	panose-1:5 4 1 2 1 8 7 7 7 7;
	mso-font-charset:2;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"MS Reference Sans Serif";
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"MS Reference Specialty";
	panose-1:5 0 5 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Bookshelf Symbol 7";
	panose-1:5 1 1 1 1 1 1 1 1 1;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:"Reveal Line Draw";
	panose-1:2 2 5 0 0 0 0 0 0 0;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Quest Font";
	panose-1:2 7 3 9 2 2 5 2 4 4;
	mso-font-charset:204;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:536902279 -2147483648 8 0 511 0;}
@font-face
	{font-family:"Agency FB";
	panose-1:2 11 5 3 2 2 2 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Arial Rounded MT Bold";
	panose-1:2 15 7 4 3 5 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Blackadder ITC";
	panose-1:4 2 5 5 5 16 7 2 13 2;
	mso-font-charset:0;
	mso-generic-font-family:decorative;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Bodoni MT";
	panose-1:2 7 6 3 8 6 6 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Bodoni MT Black";
	panose-1:2 7 10 3 8 6 6 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Bodoni MT Condensed";
	panose-1:2 7 6 6 8 6 6 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Bradley Hand ITC";
	panose-1:3 7 4 2 5 3 2 3 2 3;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Calisto MT";
	panose-1:2 4 6 3 5 5 5 3 3 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Castellar;
	panose-1:2 10 4 2 6 4 6 1 3 1;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Century Schoolbook";
	panose-1:2 4 6 4 5 5 5 2 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Copperplate Gothic Bold";
	panose-1:2 14 7 5 2 2 6 2 4 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Copperplate Gothic Light";
	panose-1:2 14 5 7 2 2 6 2 4 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Curlz MT";
	panose-1:4 4 4 4 5 7 2 2 2 2;
	mso-font-charset:0;
	mso-generic-font-family:decorative;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Edwardian Script ITC";
	panose-1:3 3 3 2 4 7 7 13 8 4;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Elephant;
	panose-1:2 2 9 4 9 5 5 2 3 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Engravers MT";
	panose-1:2 9 7 7 8 5 5 2 3 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Eras Bold ITC";
	panose-1:2 11 9 7 3 5 4 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Eras Demi ITC";
	panose-1:2 11 8 5 3 5 4 2 8 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Eras Light ITC";
	panose-1:2 11 4 2 3 5 4 2 8 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Eras Medium ITC";
	panose-1:2 11 6 2 3 5 4 2 8 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Felix Titling";
	panose-1:4 6 5 5 6 2 2 2 10 4;
	mso-font-charset:0;
	mso-generic-font-family:decorative;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Forte;
	panose-1:3 6 9 2 4 5 2 7 2 3;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Franklin Gothic Book";
	panose-1:2 11 5 3 2 1 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Franklin Gothic Demi";
	panose-1:2 11 7 3 2 1 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Franklin Gothic Demi Cond";
	panose-1:2 11 7 6 3 4 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Franklin Gothic Heavy";
	panose-1:2 11 9 3 2 1 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Franklin Gothic Medium Cond";
	panose-1:2 11 6 6 3 4 2 2 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"French Script MT";
	panose-1:3 2 4 2 4 6 7 4 6 5;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Gigi;
	panose-1:4 4 5 4 6 16 7 2 13 2;
	mso-font-charset:0;
	mso-generic-font-family:decorative;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Gill Sans MT Ext Condensed Bold";
	panose-1:2 11 9 2 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Gill Sans MT";
	panose-1:2 11 5 2 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Gill Sans MT Condensed";
	panose-1:2 11 5 6 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Gill Sans Ultra Bold";
	panose-1:2 11 10 2 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Gill Sans Ultra Bold Condensed";
	panose-1:2 11 10 6 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Gloucester MT Extra Condensed";
	panose-1:2 3 8 8 2 6 1 1 1 1;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Goudy Old Style";
	panose-1:2 2 5 2 5 3 5 2 3 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Goudy Stout";
	panose-1:2 2 9 4 7 3 11 2 4 1;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Haettenschweiler;
	panose-1:2 11 7 6 4 9 2 6 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Imprint MT Shadow";
	panose-1:4 2 6 5 6 3 3 3 2 2;
	mso-font-charset:0;
	mso-generic-font-family:decorative;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Lucida Sans";
	panose-1:2 11 6 2 3 5 4 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Lucida Sans Typewriter";
	panose-1:2 11 5 9 3 5 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Maiandra GD";
	panose-1:2 14 5 2 3 3 8 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"OCR A Extended";
	panose-1:2 1 5 9 2 1 2 1 3 3;
	mso-font-charset:0;
	mso-generic-font-family:modern;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Palace Script MT";
	panose-1:3 3 3 2 2 6 7 12 11 5;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Papyrus;
	panose-1:3 7 5 2 6 5 2 3 2 5;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Perpetua;
	panose-1:2 2 5 2 6 4 1 2 3 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Perpetua Titling MT";
	panose-1:2 2 5 2 6 5 5 2 8 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Pristina;
	panose-1:3 6 4 2 4 4 6 8 2 4;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Rage Italic";
	panose-1:3 7 5 2 4 5 7 7 3 4;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Rockwell;
	panose-1:2 6 6 3 2 2 5 2 4 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Rockwell Condensed";
	panose-1:2 6 6 3 5 4 5 2 1 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Rockwell Extra Bold";
	panose-1:2 6 9 3 4 5 5 2 4 3;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Script MT Bold";
	panose-1:3 4 6 2 4 6 7 8 9 4;
	mso-font-charset:0;
	mso-generic-font-family:script;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:"Tw Cen MT";
	panose-1:2 11 6 2 2 1 4 2 6 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Tw Cen MT Condensed";
	panose-1:2 11 6 6 2 1 4 2 2 3;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"Tw Cen MT Condensed Extra Bold";
	panose-1:2 11 8 3 2 2 2 2 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:7 0 0 0 3 0;}
@font-face
	{font-family:"MT Extra";
	panose-1:5 5 1 2 1 2 5 2 2 2;
	mso-font-charset:2;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
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
p.MsoListNumber, li.MsoListNumber, div.MsoListNumber
	{margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list .25in;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Trebuchet MS";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	text-transform:uppercase;
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
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
	tab-stops:14.2pt list .25in;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
p.xl24, li.xl24, div.xl24
	{mso-style-name:xl24;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl25, li.xl25, div.xl25
	{mso-style-name:xl25;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl26, li.xl26, div.xl26
	{mso-style-name:xl26;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl27, li.xl27, div.xl27
	{mso-style-name:xl27;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl28, li.xl28, div.xl28
	{mso-style-name:xl28;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl29, li.xl29, div.xl29
	{mso-style-name:xl29;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:.5pt;
	mso-border-left-alt:.5pt;
	mso-border-bottom-alt:1.0pt;
	mso-border-right-alt:1.0pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl30, li.xl30, div.xl30
	{mso-style-name:xl30;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl31, li.xl31, div.xl31
	{mso-style-name:xl31;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:.5pt;
	mso-border-left-alt:1.0pt;
	mso-border-bottom-alt:1.0pt;
	mso-border-right-alt:.5pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl32, li.xl32, div.xl32
	{mso-style-name:xl32;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:.5pt;
	mso-border-left-alt:1.0pt;
	mso-border-bottom-alt:.5pt;
	mso-border-right-alt:1.0pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl33, li.xl33, div.xl33
	{mso-style-name:xl33;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext 1.0pt;
	mso-border-top-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl34, li.xl34, div.xl34
	{mso-style-name:xl34;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl35, li.xl35, div.xl35
	{mso-style-name:xl35;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl36, li.xl36, div.xl36
	{mso-style-name:xl36;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl37, li.xl37, div.xl37
	{mso-style-name:xl37;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl38, li.xl38, div.xl38
	{mso-style-name:xl38;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:1.0pt;
	mso-border-left-alt:.5pt;
	mso-border-bottom-alt:.5pt;
	mso-border-right-alt:1.0pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl39, li.xl39, div.xl39
	{mso-style-name:xl39;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext .5pt;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl40, li.xl40, div.xl40
	{mso-style-name:xl40;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl41, li.xl41, div.xl41
	{mso-style-name:xl41;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext .5pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl42, li.xl42, div.xl42
	{mso-style-name:xl42;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:.5pt;
	mso-border-left-alt:1.0pt;
	mso-border-bottom-alt:1.0pt;
	mso-border-right-alt:.5pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl43, li.xl43, div.xl43
	{mso-style-name:xl43;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl44, li.xl44, div.xl44
	{mso-style-name:xl44;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext .5pt;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl45, li.xl45, div.xl45
	{mso-style-name:xl45;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl46, li.xl46, div.xl46
	{mso-style-name:xl46;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl47, li.xl47, div.xl47
	{mso-style-name:xl47;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:1.0pt;
	mso-border-left-alt:1.0pt;
	mso-border-bottom-alt:.5pt;
	mso-border-right-alt:.5pt;
	mso-border-color-alt:windowtext;
	mso-border-style-alt:solid;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl48, li.xl48, div.xl48
	{mso-style-name:xl48;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	mso-border-top-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl49, li.xl49, div.xl49
	{mso-style-name:xl49;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl50, li.xl50, div.xl50
	{mso-style-name:xl50;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl51, li.xl51, div.xl51
	{mso-style-name:xl51;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:"Arial Unicode MS";
	mso-fareast-font-family:"Arial Unicode MS";
	mso-bidi-font-family:"Arial Unicode MS";}
p.xl52, li.xl52, div.xl52
	{mso-style-name:xl52;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:"Arial Unicode MS";
	mso-fareast-font-family:"Arial Unicode MS";
	mso-bidi-font-family:"Arial Unicode MS";}
p.xl53, li.xl53, div.xl53
	{mso-style-name:xl53;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl54, li.xl54, div.xl54
	{mso-style-name:xl54;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext .5pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl55, li.xl55, div.xl55
	{mso-style-name:xl55;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl56, li.xl56, div.xl56
	{mso-style-name:xl56;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl57, li.xl57, div.xl57
	{mso-style-name:xl57;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-left-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl58, li.xl58, div.xl58
	{mso-style-name:xl58;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:"Arial Unicode MS";
	mso-fareast-font-family:"Arial Unicode MS";
	mso-bidi-font-family:"Arial Unicode MS";}
p.xl59, li.xl59, div.xl59
	{mso-style-name:xl59;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl60, li.xl60, div.xl60
	{mso-style-name:xl60;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-left-alt:solid windowtext .5pt;
	mso-border-bottom-alt:solid windowtext 1.0pt;
	mso-border-right-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl61, li.xl61, div.xl61
	{mso-style-name:xl61;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#FFCC99;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	mso-border-left-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";}
p.xl62, li.xl62, div.xl62
	{mso-style-name:xl62;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-top-alt:solid windowtext 1.0pt;
	padding:0in;
	mso-padding-alt:0in 0in 0in 0in;
	font-size:12.0pt;
	font-family:"Arial Unicode MS";
	mso-fareast-font-family:"Arial Unicode MS";
	mso-bidi-font-family:"Arial Unicode MS";}
p.xl63, li.xl63, div.xl63
	{mso-style-name:xl63;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	text-align:center;
	mso-pagination:widow-orphan;
	background:#99CCFF;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Arial Unicode MS";
	font-weight:bold;}
ins
	{mso-style-type:export-only;
	text-decoration:none;}
span.msoIns
	{mso-style-type:export-only;
	mso-style-name:"";
	text-decoration:underline;
	text-underline:single;}
span.msoDel
	{mso-style-type:export-only;
	mso-style-name:"";
	text-decoration:line-through;
	color:red;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:56.9pt 56.9pt 56.9pt 56.9pt;
	mso-header-margin:0in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;			
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 42.55pt;
	mso-header-margin:22.7pt;
	mso-footer-margin:22.7pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
@page Section3
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:14.2pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section3
	{page:Section3;}
@page Section4
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:28.35pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section4
	{page:Section4;}
@page Section5
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:28.35pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section5
	{page:Section5;}
@page Section6
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:28.35pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section6
	{page:Section6;}
@page Section7
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:28.35pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section7
	{page:Section7;}
@page Section8
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:14.2pt 42.55pt 14.2pt 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-gutter-margin:28.35pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section8
	{page:Section8;}
@page Section28
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:42.5pt 42.5pt .5in 42.5pt;
	mso-header-margin:35.3pt;
	mso-footer-margin:35.3pt;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section28
	{page:Section28;}
@page Section9
	{size:595.3pt 841.9pt;
	margin:56.9pt 56.9pt 56.9pt 56.9pt;
	mso-header-margin:0in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;			
	mso-paper-source:0;}
div.Section9
	{page:Section9;}
@page Section10
	{size:595.3pt 841.9pt;
	margin:28.35pt 42.55pt 28.35pt 42.55pt;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section10
	{page:Section10;}
@page Section11
	{size:595.3pt 841.9pt;
	margin:56.9pt 56.9pt 56.9pt 56.9pt;
	mso-header-margin:0in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section11
	{page:Section11;}  
@page Section12
	{size:595.3pt 841.9pt;
	margin:56.9pt 56.9pt 56.9pt 56.9pt;
	mso-header-margin:0in;
	mso-footer-margin:.5in;
	mso-even-header:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") eh1;
	mso-even-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") ef1;
	mso-footer:url("<%=g_ImagesRoot%>/ag_dog_agent.files/header.htm") f1;				
	mso-paper-source:0;}
div.Section12
	{page:Section12;}
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
	{mso-list-id:527717665;
	mso-list-type:hybrid;
	mso-list-template-ids:-599239962 -762677628 19059054 -423327764 -717424566 -320714620 1240921762 755788878 1189656746 -746953372;}
@list l4:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l4:level2
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level3
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level4
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level5
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level6
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level7
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level8
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l4:level9
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l5
	{mso-list-id:620645390;
	mso-list-type:hybrid;
	mso-list-template-ids:154588306 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l5:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
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
	{mso-list-id:803890164;
	mso-list-type:hybrid;
	mso-list-template-ids:-324102726 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l6:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:Symbol;}
@list l6:level2
	{mso-level-start-at:2;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
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
	{mso-list-id:966621293;
	mso-list-type:hybrid;
	mso-list-template-ids:1662520082 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l7:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F02D;
	mso-level-tab-stop:46.35pt;
	mso-level-number-position:left;
	margin-left:28.35pt;
	text-indent:0in;
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
	{mso-list-id:969628906;
	mso-list-type:hybrid;
	mso-list-template-ids:-801358350 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l8:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
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
	{mso-list-id:1009600428;
	mso-list-type:hybrid;
	mso-list-template-ids:-1704540548 68747265 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l9:level1
	{mso-level-number-format:roman-upper;
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.5in;}
@list l9:level2
	{mso-level-start-at:2;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:79.5pt;
	mso-level-number-position:left;
	margin-left:79.5pt;
	text-indent:-25.5pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
@list l9:level3
	{mso-level-tab-stop:117.0pt;
	mso-level-number-position:left;
	margin-left:117.0pt;
	text-indent:-.25in;}
@list l9:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l9:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10
	{mso-list-id:1082602987;
	mso-list-type:hybrid;
	mso-list-template-ids:-696759816 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l10:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l10:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l11
	{mso-list-id:1109161031;
	mso-list-type:hybrid;
	mso-list-template-ids:988073638 1803829810 -381782470 796955792 -727911798 542961858 -504971622 -1720813476 -169947396 953305334;}
@list l11:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l11:level2
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level3
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level4
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level5
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level6
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level7
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level8
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l11:level9
	{mso-level-start-at:0;
	mso-level-number-format:none;
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l12
	{mso-list-id:1354503029;
	mso-list-template-ids:-267218132;}
@list l12:level1
	{mso-level-start-at:2;
	mso-level-legal-format:yes;
	mso-level-tab-stop:28.5pt;
	mso-level-number-position:left;
	margin-left:28.5pt;
	text-indent:-19.5pt;}
@list l12:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l12:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l12:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l12:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l12:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l12:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l12:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l12:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l13
	{mso-list-id:1658260915;
	mso-list-type:hybrid;
	mso-list-template-ids:514499622 -1 -1 -507497550 -1 -1 -1 -1 -1 -1;}
@list l13:level1
	{mso-level-start-at:0;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
@list l13:level2
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level3
	{mso-level-start-at:2;
	mso-level-text:%3;
	mso-level-tab-stop:117.0pt;
	mso-level-number-position:left;
	margin-left:117.0pt;
	text-indent:-.25in;}
@list l13:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l13:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14
	{mso-list-id:1658530902;
	mso-list-type:hybrid;
	mso-list-template-ids:1713545178 -1098623722 68747267 68747269 68747265 68747267 68747269 68747265 68747267 68747269;}
@list l14:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:57.0pt;
	mso-level-number-position:left;
	margin-left:57.0pt;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l14:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0BE;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:8.0pt;
	font-family:Symbol;}
@list l14:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l14:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l15
	{mso-list-id:1728840352;
	mso-list-template-ids:72643792;}
@list l15:level1
	{mso-level-legal-format:yes;
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:8.5pt;
	text-indent:-8.5pt;}
@list l15:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:17.0pt;
	text-indent:-17.0pt;}
@list l15:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l15:level4
	{mso-level-reset-level:level1;
	mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.2in;
	text-indent:-.45in;}
@list l15:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:1.75in;
	mso-level-number-position:left;
	margin-left:1.55in;
	text-indent:-.55in;}
@list l15:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	margin-left:1.9in;
	text-indent:-.65in;}
@list l15:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	margin-left:2.25in;
	text-indent:-.75in;}
@list l15:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:2.75in;
	mso-level-number-position:left;
	margin-left:2.6in;
	text-indent:-.85in;}
@list l15:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:3.25in;
	mso-level-number-position:left;
	margin-left:3.0in;
	text-indent:-1.0in;}
@list l16
	{mso-list-id:1932620929;
	mso-list-template-ids:-1895800696;}
@list l16:level1
	{mso-level-start-at:3;
	mso-level-text:%1;
	mso-level-tab-stop:21.75pt;
	mso-level-number-position:left;
	margin-left:21.75pt;
	text-indent:-21.75pt;}
@list l16:level2
	{mso-level-start-at:2;
	mso-level-text:"%1\.%2";
	mso-level-tab-stop:21.75pt;
	mso-level-number-position:left;
	margin-left:21.75pt;
	text-indent:-21.75pt;}
@list l16:level3
	{mso-level-text:"%1\.%2\.%3";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l16:level4
	{mso-level-text:"%1\.%2\.%3\.%4";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l16:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l16:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l16:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l16:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l16:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l17
	{mso-list-id:2005477334;
	mso-list-template-ids:-447601770;}
@list l17:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:27.0pt;
	mso-level-number-position:left;
	margin-left:27.0pt;
	text-indent:-.25in;
	font-family:Symbol;}
@list l17:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l17:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l17:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l17:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l17:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l17:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l17:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l17:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
@list l12:level1 lfo5
	{mso-level-start-at:1;}
@list l12:level2 lfo9
	{mso-level-start-at:5;}
@list l12:level1 lfo10
	{mso-level-start-at:3;}
@list l12:level1 lfo16
	{mso-level-start-at:3;}
@list l12:level2 lfo16
	{mso-level-start-at:2;}
@list l12:level3 lfo16
	{mso-level-start-at:3;}
@list l12:level1 lfo18
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
table.MsoTableGrid
	{mso-style-name:"Сетка таблицы";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
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
 <o:shapedefaults v:ext="edit" spidmax="4098"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=EN-US link=blue vlink=purple style='tab-interval:35.4pt'>

<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="REG_DATE" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="AGENT_NAME_INS" src="AGENT_NAME_INS"/>
<rw:getValue id="DIR_NAME" src="DIR_NAME"/>
<rw:getValue id="G_N" src="G_N"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:getValue id="LEG_POS" src="LEG_POS"/>

<rw:getValue id="DATE_BEGIN_DOG" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
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
String PBSER = new String("____");
String PBNUM = new String("____________");
String PBVIDAN = new String("_____________________________");
String PBDATAV = new String("__________");

String PNUM_DOC_DIR = new String("____________");
String DATAV_DOC_DIR = new String("__________");
String G_N_OBR = new String("");

/*POBUL INFO*/
String OGRN_NUM = new String("____________");
String OGRN_DATE = new String("__________");
String OGRN_VIDAN = new String("_____________________________");
String SVID_STR = new String();
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
if (docBrief.equals("REG_SVID")) { %>
<rw:getValue id="PB_SER" src="P_SER"/>
<rw:getValue id="PB_NUM" src="P_NUM"/>
<rw:getValue id="PB_VIDAN" src="PVIDAN"/>
<rw:getValue id="PB_DATA_V" src="DATA_V"/>
<%
    if (!PB_SER.equals("@")) {
       PBSER = PB_SER;
       SVID_STR = "Серия ".concat(PB_SER);
      }
    if (!PB_NUM.equals("@")) {
        PBNUM = PB_NUM;
        SVID_STR = SVID_STR.concat(" Номер ".concat(PB_NUM));
        }
    if (!PB_VIDAN.equals("@")) PBVIDAN = PB_VIDAN;
    if (!PB_DATA_V.equals("@")) PBDATAV = PB_DATA_V;    

}
if (docBrief.equals("OGRN")) { %>
<rw:getValue id="OGRN_N" src="P_NUM"/>
<rw:getValue id="OGRN_D" src="DATA_V"/>
<rw:getValue id="OGRN_V" src="PVIDAN"/>
<%
    if (!OGRN_N.equals("@")) OGRN_NUM = OGRN_N;
    if (!OGRN_D.equals("@")) OGRN_DATE = OGRN_D;
    if (!OGRN_V.equals("@")) OGRN_VIDAN = OGRN_V;
}

if (docBrief.equals("INN")) { %>
<rw:getValue id="P_NUM1" src="P_NUM"/>
<%AGINN = P_NUM1;}%>
<% if (docBrief.equals("PENS")) { %>
<rw:getValue id="P_NUM2" src="P_NUM"/>
<%PENS = P_NUM2;}%>
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

<div align=right>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image009.jpg" alt="logo"></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='margin-left:-1.05pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>Директору Филиала/Агентства ООО «СК «Ренессанс Жизнь»</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><rw:field id="" src="D_DAT"/></b></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>От:</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><rw:field id="" src="AG_ACC"/></b></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>Паспорт:</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><%=PS%> <%=PNUM%> <%=PVIDAN%> <%=DATAV%></b></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>Адрес:</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><%=addrProp%></b></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>ИНН:</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><%=AGINN%></b></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=237 valign=top style='width:177.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>№ пенсионного свидетельства:</p>
  </td>
  <td width=166 valign=top style='width:124.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;mso-yfti-lastrow:yes'>
  <td width=403 colspan=2 valign=top style='width:302.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt'><o:p><b><%=PENS%></b></o:p></span></p>
  </td>
 </tr>
</table>

</div>

</div>

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt'>ЗАЯВЛЕНИЕ/СОГЛАШЕНИЕ <o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt'>№ <rw:field id="" src="NUM_VER"/> </span></b><span
style='font-size:10.0pt'><o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt'>о безусловном присоединении к АГЕНТСКОМУ
ДОГОВОРУ (ПРИСОЕДИНЕНИЕ), <o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt'>утвержденному Управляющим директором ООО
«СК «Ренессанс Жизнь» Киселевым О.М. <span
style='mso-spacerun:yes'> </span>«01» апреля <st1:metricconverter
ProductID="2008 г" w:st="on">2009 г.</st1:metricconverter><o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>1.
<span class=GramE>Я, _<%=AGNAME%>_, именуемый (-<span
class=SpellE>ая</span>) в дальнейшем «АГЕНТ», настоящим присоединяюсь к<span
style='mso-spacerun:yes'>  </span>условиям, изложенным в АГЕНТСКОМ ДОГОВОРЕ
(ПРИСОЕДИНЕНИЕ), утвержденным Управляющим директором ООО «СК «Ренессанс Жизнь» (далее
«СТРАХОВЩИК») Киселевым О.М.<span style='mso-spacerun:yes'>  </span>«01» апреля 
 <st1:metricconverter ProductID="2009 г" w:st="on">2009 г</st1:metricconverter>.
(Далее «АГЕНТСКИЙ ДОГОВОР»), и обязуюсь за вознаграждение осуществлять от имени
и по поручению СТРАХОВЩИКА посредническую деятельность в области страхования с
целью заключения СТРАХОВЩИКОМ с <span style='mso-fareast-language:EN-US'>физическими
и юридическими лицами </span>договоров страхования по</span> следующим видам
страхования:<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>Страхование
жизни;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>Страхование
ренты (аннуитетов);<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>Страхование
пенсий;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>Страхование
от несчастных случаев и болезней;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>Добровольное
медицинское страхование.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>2.
В соответствии с<span style='mso-spacerun:yes'>  </span>АГЕНТСКИМ ДОГОВОРОМ
(ПРИСОЕДИНЕНИЕ) СТРАХОВЩИК предоставляет АГЕНТУ следующие полномочия:<o:p></o:p></span></p>



<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>знакомить потенциальных страхователей с
условиями, Правилами страхования и тарифами СТРАХОВЩИКА;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>проводить переговоры с потенциальными
страхователями о заключении ими со Страховщиком договоров страхования по видам,
указанным в АГЕНТСКОМ ДОГОВОРЕ (ПРИСОЕДИНЕНИЕ);<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>оформлять документы, необходимые для
заключения договоров страхования (заявления на страхование, договоры
страхования (полисы), направления на медицинское обследование, квитанции формы
А<span class=GramE>7</span> и т.п.) и передавать их СТРАХОВЩИКУ;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>принимать и передавать в кассу
СТРАХОВЩИКА или перечислять на расчетный счет последнего (далее -
передавать)<span style='mso-spacerun:yes'>  </span>страховую премию (страховые
взносы), уплачиваемые страхователями по договорам страхования;<o:p></o:p></span></p>

<p class=MsoBodyTextIndent2 style='margin-left:0cm;text-indent:0cm;line-height:
normal;mso-list:l0 level1 lfo1;tab-stops:0cm list 36.0pt'><![if !supportLists]><span
style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:
Symbol'><span style='mso-list:Ignore'>·<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style='font-family:"Times New Roman"'>совершать иные действия, необходимые для
заключения договоров страхования в пределах полномочий (обязанностей),
предоставленных АГЕНТСКИМ ДОГОВОРОМ (ПРИСОЕДИНЕНИЕ) (Доверенностью при
необходимости), а также содействовать заключению Страховщиком договоров
страхования с физическими и юридическими лицами путем привлечения к заключению
агентских договоров со СТРАХОВЩИКОМ физических лиц и юридических лиц (Банков,
Брокеров).<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>3.
С текстом АГЕНТСКОГО ДОГОВОРА<b><i> </i></b>(ПРИСОЕДИНЕНИЕ), утвержденного Управляющим
директором ООО «СК «Ренессанс Жизнь» Киселевым О.М.<span
style='mso-spacerun:yes'>  </span>«01» апреля <st1:metricconverter
ProductID="2009 г" w:st="on">2009 г</st1:metricconverter>., ознакомлен<span
class=GramE> (- </span>а).<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>4.
Подписи сторон: <o:p></o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=307 valign=top style='width:230.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>
Директор Филиала/Агентства <o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>ООО «СК «Ренессанс Жизнь» в
  городе <b style='mso-bidi-font-weight:normal'><rw:field id="" src="DEPT"/></b><o:p></o:p></span></p>
  </td>
  <td width=324 valign=top style='width:243.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>ФИО Агента:                                                            
  <b style='mso-bidi-font-weight:normal'><%=AGNAME%></span></b><span
  style='font-size:10.0pt;font-family:Tahoma;color:#666666'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=307 valign=top style='width:230.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>______________________/________________/<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>«______»
  _______________________ <st1:metricconverter ProductID="2008 г" w:st="on">2009
   г</st1:metricconverter>.<o:p></o:p></span></p>
  </td>
  <td width=324 valign=top style='width:243.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>__________________/_________________/<o:p></o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt'>«______»
  ___________________ <st1:metricconverter ProductID="2008 г" w:st="on">2009 г</st1:metricconverter>.<o:p></o:p></span></p>
  </td>
 </tr>
</table>

</div>

</rw:foreach>
</body>

</html>

</rw:report>

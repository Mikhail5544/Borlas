<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dov_dppd" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOV_DPPD" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AG_DOVER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select canParse="no">
      <![CDATA[ SELECT ach.agent_id, ach.ag_contract_header_id,
       c.NAME || ' ' || c.first_name || ' ' || c.middle_name agent_name,
       pkg_contact.get_fio_fmt (NVL (c.GENITIVE, c.NAME || ' ' || c.first_name || ' ' || c.middle_name),4
                               ) agent_name_initial,
       NVL (c.accusative,
            c.NAME || ' ' || c.first_name || ' ' || c.middle_name
           ) agent_name_accusative,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || ach.num num,
       utils.date2genitive_case (ach.date_begin) date_begin,
       pkg_contact.get_fio_fmt (NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),'Смышляев Юрий Олегович'
           ), 4 ) dir_name_initial,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name_genitive, 
       NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),
            'Смышляев Юрий Олегович'
           ) dir_name
  FROM ven_ag_contract_header ach JOIN ven_ag_contract ac
       ON (ac.ag_contract_id = ach.last_ver_id)
       JOIN ven_contact c ON c.contact_id = ach.agent_id
       LEFT OUTER JOIN ven_department dep ON (ach.agency_id =
                                                             dep.department_id
                                             )
       LEFT OUTER JOIN ven_dept_executive dept_exe
       ON (ach.agency_id = dept_exe.department_id)
 WHERE ach.ag_contract_header_id = :p_ch_id;]]>
      </select>
      <displayInfo x="2.07300" y="1.48950" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="1.51404" y="2.27283" width="1.81714" height="1.79785"
        />
        <dataItem name="DIR_NAME_INITIAL" datatype="vchar2" columnOrder="34"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Initial">
          <dataDescriptor expression="DIR_NAME_INITIAL"
           descriptiveExpression="DIR_NAME_INITIAL" order="8" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_GENITIVE" datatype="vchar2" columnOrder="35"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Genitive">
          <dataDescriptor expression="DIR_NAME_GENITIVE"
           descriptiveExpression="DIR_NAME_GENITIVE" order="9" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="10" width="4000"/>
        </dataItem>
        <dataItem name="AGENT_NAME_INITIAL" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name Initial">
          <dataDescriptor expression="AGENT_NAME_INITIAL"
           descriptiveExpression="AGENT_NAME_INITIAL" order="4" width="4000"/>
        </dataItem>
        <dataItem name="AGENT_NAME_ACCUSATIVE" datatype="vchar2"
         columnOrder="18" width="602" defaultWidth="100000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Agent Name Accusative">
          <dataDescriptor expression="AGENT_NAME_ACCUSATIVE"
           descriptiveExpression="AGENT_NAME_ACCUSATIVE" order="5" width="602"
          />
        </dataItem>
        <dataItem name="DATE_BEGIN" datatype="vchar2" columnOrder="17"
         width="4000" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="7" width="4000"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="16" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="NUM" descriptiveExpression="NUM"
           order="6" width="201"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="15"
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
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT org.company_name, org.inn, chief_name,
       pkg_contact.get_fio_fmt (chief_name, 4) chief_name_initial
  FROM v_company_info org]]>
      </select>
      <displayInfo x="0.40637" y="0.09375" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.13416" y="0.63745" width="1.24426" height="1.62695"
        />
        <dataItem name="chief_name_initial" datatype="vchar2" columnOrder="24"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name Initial">
          <dataDescriptor
           expression="pkg_contact.get_fio_fmt ( chief_name , 4 )"
           descriptiveExpression="CHIEF_NAME_INITIAL" order="4" width="4000"/>
        </dataItem>
        <dataItem name="CHIEF_NAME" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="chief_name"
           descriptiveExpression="CHIEF_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="21"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor expression="org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="22" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="2" width="101"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AG_DOCS">
      <select>
      <![CDATA[SELECT   vcp.contact_id, NVL (cci.serial_nr, '____') p_ser,
         NVL (cci.id_value, '_________') p_num,
         NVL (cci.place_of_issue,
              '_________________________________________'
             ) pvidan,
         DECODE (TO_CHAR (NVL (cci.issue_date,
                               TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                              ),
                          'DD.MM.YYYY'
                         ),
                 '01.01.1900', '_________',
                 TO_CHAR (cci.issue_date, 'DD.MM.YYYY')
                ) data_v,
         NVL
            (pkg_contact.get_address_name
                              (pkg_contact.get_primary_address (vcp.contact_id)
                              ),
             '@'
            ) addr
    FROM ven_cn_person vcp,
         (SELECT cci1.contact_id, cci1.serial_nr, cci1.id_value,
                 cci1.place_of_issue, cci1.issue_date
            FROM ven_cn_contact_ident cci1, ven_t_id_type tit
           WHERE cci1.id_type = tit.ID AND UPPER (tit.brief) = 'PASS_RF') cci
   WHERE vcp.contact_id = cci.contact_id(+)
ORDER BY NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC;]]>
      </select>
      <displayInfo x="3.99988" y="1.77087" width="0.69995" height="0.32996"/>
      <group name="G_AG_DOCS">
        <displayInfo x="3.66003" y="2.47095" width="1.37964" height="1.28516"
        />
        <dataItem name="addr" datatype="vchar2" columnOrder="30" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="NVL ( pkg_contact.get_address_name ( pkg_contact.get_primary_address ( vcp.contact_id ) ) , &apos;@&apos; )"
           descriptiveExpression="ADDR" order="6" width="4000"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="29"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <xmlSettings xmlTag="DATA_V1"/>
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;_________&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="5" width="10"/>
        </dataItem>
        <dataItem name="CONTACT_ID2" oracleDatatype="number" columnOrder="25"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="vcp.contact_id"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="26" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor
           expression="NVL ( cci.serial_nr , &apos;____&apos; )"
           descriptiveExpression="P_SER" order="2" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="27" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor
           expression="NVL ( cci.id_value , &apos;_________&apos; )"
           descriptiveExpression="P_NUM" order="3" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="28" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;_________________________________________&apos; )"
           descriptiveExpression="PVIDAN" order="4" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOVER">
      <select>
      <![CDATA[SELECT dov.ag_contract_header_id, decode(nvl(dov.NUM_DOVER,'0'),'0',' ',dov.NUM_DOVER) num, utils.DATE2SPEACH(dov.date_start) date_start
  FROM ven_ag_contract_dover dov
 WHERE dov.ag_contract_dover_id = :p_ag_dover_id]]>
      </select>
      <displayInfo x="4.17712" y="4.09375" width="0.69995" height="0.32983"/>
      <group name="G_DOVER">
        <displayInfo x="3.85291" y="4.79370" width="1.34497" height="0.77246"
        />
        <dataItem name="num1" datatype="vchar2" columnOrder="33" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Nvl Dov Num">
          <xmlSettings xmlTag="NVL_DOV_NUM"/>
          <dataDescriptor expression="nvl ( dov.num , &apos; &apos; )"
           descriptiveExpression="NUM" order="2" width="100"/>
        </dataItem>
        <dataItem name="AG_CONTRACT_HEADER_ID1" oracleDatatype="number"
         columnOrder="32" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id1">
          <dataDescriptor expression="dov.ag_contract_header_id"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DATE_START" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Start">
          <dataDescriptor expression="utils.DATE2SPEACH ( dov.date_start )"
           descriptiveExpression="DATE_START" order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT" parentColumn="AGENT_ID"
     childQuery="Q_AG_DOCS" childColumn="CONTACT_ID2" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_AGENT"
     parentColumn="ag_contract_header_id" childQuery="Q_DOVER"
     childColumn="AG_CONTRACT_HEADER_ID1" condition="eq" sqlClause="where"/>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title> </title>
<!--[if gte mso 9]><xml>
  <o:_AdHocReviewCycleID dt:dt="float">-700844206</o:_AdHocReviewCycleID>
  <o:_EmailSubject dt:dt="string">доверенность АГЕНТУ без права передоверия</o:_EmailSubject>
  <o:_AuthorEmail dt:dt="string">VSviontkovskaya@renlife.ru</o:_AuthorEmail>
  <o:_AuthorEmailDisplayName dt:dt="string">Sviontkovskaya Veronika</o:_AuthorEmailDisplayName>
  <o:_PreviousAdHocReviewCycleID dt:dt="float">1276345109</o:_PreviousAdHocReviewCycleID>
  <o:_ReviewingToolsShownOnce dt:dt="string"></o:_ReviewingToolsShownOnce>
 </o:CustomDocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:AttachedTemplate HRef="АГЕНТЫ_Доверенность"></w:AttachedTemplate>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:SelectEntireFieldWithStartOrEnd/>
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
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
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
	margin:56.7pt 42.55pt 56.7pt 42.55pt;
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

<body lang=EN-US style='tab-interval:35.4pt'>
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="DIR_NAME" src="DIR_NAME"/>
<rw:getValue id="CHIEF_NAME_INITIAL" src="dir_name_initial"/>
<rw:getValue id="CHIEF_NAME_GEN" src="dir_name_genitive"/>
<rw:getValue id="AGNAME_INITIAL" src="agent_name_initial"/>
<rw:getValue id="AGENT_NAME_ACCUSATIVE" src="AGENT_NAME_ACCUSATIVE"/>
<rw:getValue id="AGENT_NAME" src="AGENT_NAME"/>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<%

/*AGENT INFO*/
String PS = new String("____");
String PNUM = new String("____________");
String PVIDAN= new String("_____________________________");
String DATAV = new String("__________");
String AGADDR = new String("_______________________________________________");


/*ORG INFO*/
String ORGNAME = new String();
String CHIEF_NAME = new String();
String ORGINN = new String();

//DOVERENNOST
String DOVNUM = new String();
String DOVDATA = new String();

CHIEF_NAME = DIR_NAME;
%>

<rw:foreach id="agdoc" src="G_AG_DOCS">
<rw:getValue id="AGADDR1" src="ADDR"/>
<rw:getValue id="P_SER" src="P_SER"/>
<rw:getValue id="P_NUM" src="P_NUM"/>
<rw:getValue id="P_VIDAN" src="PVIDAN"/>
<rw:getValue id="DATA_V" src="DATA_V"/>
<%
    PS = P_SER;
    PNUM = P_NUM;
    PVIDAN = P_VIDAN;
    DATAV = DATA_V;
if (!AGADDR1.equals("@")) AGADDR = AGADDR1;    
  
%>

</rw:foreach>

<rw:foreach id="gorg" src="G_ORG_CONT">
  <rw:getValue id="COMPANY_NAME" src="COMPANY_NAME"/>
  <rw:getValue id="INN" src="INN"/>  
<% 
ORGNAME  = COMPANY_NAME;
ORGINN 	 = INN;
%>
</rw:foreach>
<rw:foreach id="gdaver" src="G_DOVER">
  <rw:getValue id="DOV_N" src="NUM1"/> 
  <%DOVNUM = DOV_N;%>
  <rw:getValue id="DOG_DATA" src="DATE_START" formatMask="DD.MM.YYYY"/> 
  <%DOVDATA =  DOG_DATA; %>
</rw:foreach>
<div class=Section1>



<table class="mainTable">
<tr>
<td class="mainTd">
<p class=MsoNormal style='margin-bottom:6.0pt'><span lang=RU style='font-size:
11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt'><span style='font-size:11.0pt;
mso-bidi-font-size:12.0pt'><!--[if gte vml 1]><v:shapetype id="_x0000_t75"
 coordsize="21600,21600" o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe"
 filled="f" stroked="f">
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
</v:shapetype><v:shape id="_x0000_i1025" type="#_x0000_t75" style='width:81pt;
 height:24pt' o:ole="">
 <v:imagedata src="<%=g_ImagesRoot%>/ag_dov_dppd_files/image001.png" o:title=""/>
</v:shape><![endif]--><![if !vml]><img width=108 height=32
src="<%=g_ImagesRoot%>/ag_dov_dppd_files/image002.jpg" v:shapes="_x0000_i1025"><![endif]><!--[if gte mso 9]><xml>
 <o:OLEObject Type="Embed" ProgID="PBrush" ShapeID="_x0000_i1025"
  DrawAspect="Content" ObjectID="_1242294589">
 </o:OLEObject>
</xml><![endif]--></span><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:11.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:11.0pt;mso-ansi-language:RU'>ДОВЕРЕННОСТЬ</span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt'><span
style='mso-spacerun:yes'>  </span></span></b><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:11.0pt;mso-ansi-language:RU'>№ <%=DOVNUM%><o:p></o:p></span></b></p>

<p class=MsoNormal><span lang=RU style='font-size:11.0pt;mso-ansi-language:
RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-size:11.0pt;mso-ansi-language:
RU'>г. Москва<span
style='mso-spacerun:yes'>                                                                   
</span><o:p></o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
12.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:11.0pt;mso-bidi-font-size:12.0pt;
letter-spacing:.7pt'><%=DOVDATA%> года <o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:11.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'>Общество с
ограниченной ответственностью <%=ORGNAME%><span
style='mso-spacerun:yes'>  </span>ИНН <%=ORGINN%>,<span
style='mso-spacerun:yes'>  </span>в лице Генерального директора Никифорова Евгения Андреевича,
 действующего на основании Устава, (далее – «Общество»),
настоящей доверенностью уполномочивает:</span><span lang=RU style='font-size:
11.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>

<p class=MsoNormal style='tab-stops:196.8pt 437.75pt'><span style='font-size:
11.0pt;letter-spacing:.7pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='tab-stops:196.8pt 437.75pt'><span style='font-size:
11.0pt;letter-spacing:.7pt'><b><u><%=AGENT_NAME_ACCUSATIVE%></u></b><o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;tab-stops:255.15pt'><span
class=GramE><span lang=RU style='font-size:11.0pt;letter-spacing:.7pt;
mso-ansi-language:RU'>имеющего</span></span><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'> (<span class=SpellE>щую</span>)
паспорт серии </span><span style='font-size:11.0pt;letter-spacing:.7pt'><b><%=PS%></b></span><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'> № </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><b><%=PNUM%></b></span><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>, выданный </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><b><%=PVIDAN%></b></span><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'> ,
зарегистрированного (<span class=SpellE>ую</span>) по адресу:<span
style='mso-spacerun:yes'>    </span></span><span class=GramE><span
style='font-size:11.0pt;letter-spacing:.7pt'><b><%=AGADDR%></b></span><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'> ,</span></span><b><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>
являющегося Агентом<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;tab-stops:255.15pt'><b><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>по
договору</span><span style='font-size:11.0pt;letter-spacing:.7pt'> № <%=AGDOGNUM%> </span><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>от </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><%=DATE_BEGIN%>,<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;tab-stops:255.15pt'><span
style='font-size:11.0pt;letter-spacing:.7pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;tab-stops:255.15pt'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>совершать
от имени Общества следующие действия:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
RU'>1. Проводить на территории Российской Федерации переговоры с физическими и
юридическими лицами о заключении договоров по следующим видам страхования:
страхование жизни и страхование от несчастных случаев и болезней.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
RU'>2. Консультировать потенциальных клиентов, по вопросам, связанным с
заключением договоров страхования жизни и от несчастных случаев и болезней.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
RU'>3. Оформлять документы, необходимые для заключения Обществом вышеуказанных
договоров страхования, в частности Заявления на страхование, Направления на медицинское
обследование к Заявлениям на страхование, квитанции формы А-7.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
RU'>4. Осуществлять расчет по договорам страхования (полисам) в соответствии с
действующими тарифными сборниками Общества и принимать от страхователей
страховые премии (взносы) по заключенным договорам страхования наличными
деньгами с выдачей страхователю квитанции установленного образца с целью их
последующего перечисления на расчетный счет Общества. <o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='mso-ansi-language:
RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='mso-ansi-language:RU'>Доверенность выдана сроком на один год без
права передоверия другим лицам.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>Образец
подписи<o:p></o:p></span></p>

<p class=MsoNormal style='tab-stops:196.8pt 437.75pt'><span class=GramE><span
style='font-size:11.0pt;letter-spacing:.7pt'><%=AGENT_NAME%> </span><span
style='font-size:11.0pt;color:blue;letter-spacing:.7pt;mso-ansi-language:RU'><span
style='mso-spacerun:yes'> </span></span><span lang=RU style='font-size:11.0pt;
letter-spacing:.7pt;mso-ansi-language:RU'>_</span></span><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>__________________________
удостоверяю.</span><span style='font-size:11.0pt;letter-spacing:.7pt'><o:p></o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'>Генеральный
директор __________________________ Никифоров Е. А.
<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
</td>
</tr>
</table>
</div>
</rw:foreach>
</body>

</html>

</rw:report>
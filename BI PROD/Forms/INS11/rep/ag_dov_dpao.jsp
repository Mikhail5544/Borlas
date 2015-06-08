s<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%
String dovNum = new String();
String dovData = new String();
String DATE_START_PROP = new String();
String AGNAME = new String();
String PS  = new String();
String PNUM = new String();
String PVIDAN = new String();
String DATAV  = new String();
String AGADDR = new String("_______________________________________________");

%>
<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dov_dpao" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOV_DPAO" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AG_DOVER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select>
      <![CDATA[SELECT agch.agent_id, agch.ag_contract_header_id,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || agch.num num,
       agc.date_begin,
            ent.obj_name (ent.id_by_brief ('CONTACT'), agch.agent_id)    ag_name,
       mng.agent_id manager_id
  FROM ven_ag_contract_header agch,
       ven_ag_contract agc,
       ven_contact c,
       (SELECT agcht.agent_id, agct.ag_contract_id
          FROM ven_ag_contract_header agcht, ven_ag_contract agct
         WHERE agcht.ag_contract_header_id = agct.contract_id) mng,
       ven_department dep
 WHERE agch.last_ver_id = agc.ag_contract_id
   AND agch.agency_id = dep.department_id(+)
   AND agch.agent_id = c.contact_id
   AND agc.contract_leader_id = mng.ag_contract_id(+)
   AND agch.ag_contract_header_id = :p_ch_id;]]>
      </select>
      <displayInfo x="0.75000" y="0.96875" width="0.69995" height="0.19995"/>
      <group name="G_AGENT">
        <displayInfo x="0.19141" y="1.66870" width="1.81714" height="1.28516"
        />
        <dataItem name="date_begin" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="agc.date_begin"
           descriptiveExpression="DATE_BEGIN" order="4" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="ag_name" datatype="vchar2" columnOrder="16"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name">
          <dataDescriptor
           expression="ent.obj_name ( ent.id_by_brief ( &apos;CONTACT&apos; ) , agch.agent_id )"
           descriptiveExpression="AG_NAME" order="5" width="4000"/>
        </dataItem>
        <dataItem name="manager_id" oracleDatatype="number" columnOrder="17"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Manager Id">
          <dataDescriptor expression="mng.agent_id"
           descriptiveExpression="MANAGER_ID" order="6"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="agent_id" oracleDatatype="number" columnOrder="13"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="agch.agent_id"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="ag_contract_header_id" oracleDatatype="number"
         columnOrder="14" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="agch.ag_contract_header_id"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="15" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor
           expression="DECODE ( dep.code , NULL , NULL , dep.code || &apos;-&apos; ) || agch.num"
           descriptiveExpression="NUM" order="3" width="201"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AG_DOC">
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
      <displayInfo x="3.13550" y="0.14587" width="0.69995" height="0.32983"/>
      <group name="G_AG_DOC">
        <displayInfo x="2.82690" y="0.84583" width="1.31714" height="1.28516"
        />
        <dataItem name="addr" datatype="vchar2" columnOrder="24" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="NVL ( pkg_contact.get_address_name ( pkg_contact.get_primary_address ( vcp.contact_id ) ) , &apos;@&apos; )"
           descriptiveExpression="ADDR" order="6" width="4000"/>
        </dataItem>
        <dataItem name="CONTACT_ID" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id">
          <dataDescriptor expression="vcp.contact_id"
           descriptiveExpression="CONTACT_ID" order="1"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="20" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor
           expression="NVL ( cci.serial_nr , &apos;____&apos; )"
           descriptiveExpression="P_SER" order="2" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="21" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor
           expression="NVL ( cci.id_value , &apos;_________&apos; )"
           descriptiveExpression="P_NUM" order="3" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="22" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;_________________________________________&apos; )"
           descriptiveExpression="PVIDAN" order="4" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="23"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;_________&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="5" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOVER">
      <select>
      <![CDATA[select DOV.AG_CONTRACT_HEADER_ID,  decode(nvl(dov.NUM_DOVER,'0'),'0',' ',dov.NUM_DOVER) num , dov.date_start,
utils.DATE2SPEACH(dov.date_start) date_start_prop
from VEN_AG_CONTRACT_DOVER dov
where
dov.AG_CONTRACT_DOVER_ID = :P_AG_DOVER_ID
]]>
      </select>
      <displayInfo x="0.68396" y="3.79114" width="0.69995" height="0.32983"/>
      <group name="G_AG_DOVER">
        <displayInfo x="0.20837" y="4.34570" width="1.65625" height="1.28516"
        />
        <dataItem name="date_start" datatype="date" oracleDatatype="date"
         columnOrder="28" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Start">
          <dataDescriptor expression="dov.date_start"
           descriptiveExpression="DATE_START" order="3" width="9"/>
        </dataItem>
        <dataItem name="AG_CONTRACT_HEADER_ID1" oracleDatatype="number"
         columnOrder="25" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id1">
          <dataDescriptor expression="DOV.AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="NUM1" datatype="vchar2" columnOrder="26" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num1">
          <dataDescriptor expression="dov.NUM" descriptiveExpression="NUM"
           order="2" width="100"/>
        </dataItem>
        <dataItem name="date_start_prop" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Start">
          <dataDescriptor expression="utils.DATE2SPEACH ( dov.date_start )"
           descriptiveExpression="DATE_START_PROP" order="4" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT" parentColumn="agent_id"
     childQuery="Q_AG_DOC" childColumn="CONTACT_ID" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_AGENT"
     parentColumn="ag_contract_header_id" childQuery="Q_DOVER"
     childColumn="AG_CONTRACT_HEADER_ID1" condition="eq" sqlClause="where"/>
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
<link rel=File-List href="DOVER_DPAO.files/filelist.xml">
<title>ДОВЕРЕННОСТЬ № </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>soldain</o:Author>
  <o:Template>agent_dov_report_sign</o:Template>
  <o:LastAuthor>Khomich</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>4</o:TotalTime>
  <o:LastPrinted>2006-09-25T07:24:00Z</o:LastPrinted>
  <o:Created>2007-06-02T11:10:00Z</o:Created>
  <o:LastSaved>2007-06-02T11:10:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>108</o:Words>
  <o:Characters>619</o:Characters>
  <o:Company>RenLife</o:Company>
  <o:Lines>5</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>726</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
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
	{font-family:"Times New Roman CYR";
	panose-1:2 2 6 3 5 4 5 2 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:536902279 -2147483648 8 0 511 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a, li.a, div.a
	{mso-style-name:"Таблицы \(моноширинный\)";
	mso-style-next:Обычный;
	margin:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	mso-layout-grid-align:none;
	text-autospace:none;
	font-size:10.0pt;
	font-family:"Courier New";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:56.7pt 42.5pt 56.7pt 85.05pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
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
<![endif]-->
</head>

<body lang=EN-US style='tab-interval:35.4pt'>
<rw:foreach id="gagent" src="G_AGENT">
<rw:foreach id="gdover" src="G_AG_DOVER">
<rw:getValue id="dovn" src="NUM1"/>
<rw:getValue id="datdov" src="DATE_START" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_START_PROP1" src="DATE_START_PROP"/>
<%
dovNum = dovn;
dovData = datdov;
DATE_START_PROP = DATE_START_PROP1;
%>
</rw:foreach>

<rw:foreach id="gagdoc" src="G_AG_DOC" startRow="1" endRow="1">
<rw:getValue id="AN1" src="AG_NAME"/>
<rw:getValue id="PS1" src="P_SER"/>
<rw:getValue id="PN1" src="P_NUM"/>
<rw:getValue id="PV1" src="PVIDAN"/>
<rw:getValue id="DV1" src="DATA_V"/>
<rw:getValue id="AGADDR1" src="ADDR"/>
<%
AGNAME = AN1;
PS  = PS1;
PNUM = PN1;
PVIDAN = PV1;
DATAV  = DV1;
if (!AGADDR1.equals("@")) AGADDR = AGADDR1;    
%>
</rw:foreach>
<div class=Section1>
<table class="mainTable">
<tr>
<td class="mainTd">
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'>ДОВЕРЕННОСТЬ № </span></b><b style='mso-bidi-font-weight:
normal'><span lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;
font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><span
style='mso-spacerun:yes'> </span></span></b><a name="treaty_number"><b
style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;mso-bidi-font-size:
12.0pt;font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><rw:field id="FNUM" src="NUM"> &Field </rw:field> </span></b></a><span
style='mso-bookmark:treaty_number'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:14.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
RU'><o:p></o:p></span></b></span></p>

<span style='mso-bookmark:treaty_number'></span>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>г. Москва<span
style='mso-spacerun:yes'>  </span></span><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:12.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
RU'><o:p></o:p></span></b></p>

<p class=MsoNormal><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><%=DATE_START_PROP%> года<span
style='mso-spacerun:yes'>  </span></span><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:12.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
RU'><o:p></o:p></span></b></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU
style='mso-ansi-language:RU'>Я, 
<b style='mso-bidi-font-weight:normal'>
</span><%=AGNAME%></b><span lang=RU style='mso-ansi-language:
RU'>,<span style='mso-no-proof:yes'> паспорт серии </span></span><span
style='mso-no-proof:yes'><%=PS%></span><span lang=RU style='mso-ansi-language:RU;
mso-no-proof:yes'> № </span><span style='mso-no-proof:yes'><%=PNUM%></span><span
lang=RU style='mso-ansi-language:RU'>, <span style='mso-no-proof:yes'>выданный </span></span><span
style='mso-no-proof:yes'><%=PVIDAN%></span><span lang=RU style='mso-ansi-language:
RU;mso-no-proof:yes'>, дата выдачи: </span><span style='mso-no-proof:yes'><%=DATAV%></span><span
lang=RU style='mso-ansi-language:RU;mso-no-proof:yes'>, <span
style='mso-spacerun:yes'> </span>зарегистрирован(а) <span
style='mso-spacerun:yes'> </span>по адресу: </span><span style='mso-no-proof:
yes'><%=AGADDR%></span><span lang=RU style='mso-ansi-language:RU;mso-no-proof:yes'>,<o:p></o:p></span></p>

<p class=a><span lang=RU style='font-size:12.0pt;font-family:"Times New Roman";
mso-no-proof:yes'>настоящей доверенностью уполномочиваю </span><span lang=RU
style='font-size:12.0pt;font-family:"Times New Roman"'><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><b><span
lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><b
style='mso-bidi-font-weight:normal'><span lang=RU style='mso-ansi-language:
RU;mso-no-proof:yes'>Глушкову Наталью Николаевну, </span></b><span lang=RU
style='mso-ansi-language:RU;mso-no-proof:yes'>паспорт серии 52 05 № 097907, выданный
УВД КАО г.Омска, дата выдачи: <span style='mso-spacerun:yes'> </span>25.01.2005,
зарегистрирована по адресу: г. Омск, ул. Дианова, д.4, кв.45,<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU
style='mso-ansi-language:RU;mso-no-proof:yes'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU
style='mso-ansi-language:RU;mso-no-proof:yes'>подписывать от моего имени отчеты
к Агентскому договору № <span style='mso-spacerun:yes'> </span></span><span
style='mso-no-proof:yes'>
<b style='mso-bidi-font-weight:normal'>
<rw:field id="FNUM" src="NUM"> &Field </rw:field>
</b>
</span><span style='mso-ansi-language:RU;
mso-no-proof:yes'> <span lang=RU><span style='mso-spacerun:yes'>    </span>от 
<b style='mso-bidi-font-weight:normal'>
<rw:field id="FDATEBEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"> &Field </rw:field>
</b>
, а также совершать иные действия,
связанные с выполнением настоящего поручения.<o:p></o:p></span></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:.5in'><span lang=RU
style='mso-ansi-language:RU;mso-no-proof:yes'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><b><span lang=RU
style='mso-ansi-language:RU'><span style='mso-spacerun:yes'>  </span><span
style='mso-tab-count:1'>          </span></span></b><span lang=RU
style='mso-ansi-language:RU;mso-bidi-font-weight:bold'>Настоящая </span><span
lang=RU style='mso-ansi-language:RU'>Доверенность выдана без права передоверия
сроком на один год.<o:p></o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'>_____________________________________</span>________________<span
lang=RU style='mso-ansi-language:RU'>________________________<o:p></o:p></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>
</td>
</tr>
</table>
</div>
</rw:foreach>
</body>

</html>


</rw:report>

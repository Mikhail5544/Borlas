<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>


<%
	SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  String SYSD = sdf.format(new java.util.Date());
%>

<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dover" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOVER" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CH_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_DOV_NUM" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT">
      <select>
      <![CDATA[SELECT acj.AGENT_ID,acj.DATE_BEGIN, acj.ag_contract_header_id, acj.agent_name, acj.num,
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
        <dataItem name="DATE_BEGIN" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="acj.DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="2" width="9"/>
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="17" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="acj.num" descriptiveExpression="NUM"
           order="5" width="100"/>
        </dataItem>
        <dataItem name="AGENT_ID" oracleDatatype="number" columnOrder="16"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Id">
          <dataDescriptor expression="acj.AGENT_ID"
           descriptiveExpression="AGENT_ID" order="1" oracleDatatype="number"
           width="22" precision="9"/>
        </dataItem>
        <dataItem name="ag_contract_header_id" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="acj.ag_contract_header_id"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="agent_name" datatype="vchar2" columnOrder="14"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agent Name">
          <dataDescriptor expression="acj.agent_name"
           descriptiveExpression="AGENT_NAME" order="4" width="4000"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="15" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="pkg_contact.get_address_name ( pkg_contact.get_primary_address ( acj.agent_id ) )"
           descriptiveExpression="ADDR" order="6" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[select org.COMPANY_NAME, org.INN, org.KPP, org.ACCOUNT_NUMBER, 
org.BANK_COMPANY_TYPE||' '||org.BANK_NAME bank, org.B_BIC, org.B_KOR_ACCOUNT, org.LEGAL_ADDRESS
   from v_company_info org
]]>
      </select>
      <displayInfo x="0.40637" y="0.09375" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.13416" y="0.63745" width="1.24426" height="1.62695"
        />
        <dataItem name="COMPANY_NAME" datatype="vchar2" columnOrder="18"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor expression="org.COMPANY_NAME"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="INN" datatype="vchar2" columnOrder="19" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.INN" descriptiveExpression="INN"
           order="2" width="101"/>
        </dataItem>
        <dataItem name="KPP" datatype="vchar2" columnOrder="20" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.KPP" descriptiveExpression="KPP"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="ACCOUNT_NUMBER" datatype="vchar2" columnOrder="21"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.ACCOUNT_NUMBER"
           descriptiveExpression="ACCOUNT_NUMBER" order="4" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="22" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.BANK_COMPANY_TYPE || &apos; &apos; || org.BANK_NAME"
           descriptiveExpression="BANK" order="5" width="4000"/>
        </dataItem>
        <dataItem name="B_BIC" datatype="vchar2" columnOrder="23" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.B_BIC" descriptiveExpression="B_BIC"
           order="6" width="101"/>
        </dataItem>
        <dataItem name="B_KOR_ACCOUNT" datatype="vchar2" columnOrder="24"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.B_KOR_ACCOUNT"
           descriptiveExpression="B_KOR_ACCOUNT" order="7" width="101"/>
        </dataItem>
        <dataItem name="LEGAL_ADDRESS" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Legal Address">
          <dataDescriptor expression="org.LEGAL_ADDRESS"
           descriptiveExpression="LEGAL_ADDRESS" order="8" width="4000"/>
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
    <dataSource name="Q_DOVER">
      <select>
      <![CDATA[select DOV.AG_CONTRACT_HEADER_ID, dov.NUM, dov.DATE_START from VEN_AG_CONTRACT_DOVER dov
where
dov.NUM = :P_DOV_NUM]]>
      </select>
      <displayInfo x="4.17712" y="4.09375" width="0.69995" height="0.32983"/>
      <group name="G_DOVER">
        <displayInfo x="3.85291" y="4.79370" width="1.34839" height="0.77246"
        />
        <dataItem name="AG_CONTRACT_HEADER_ID1" oracleDatatype="number"
         columnOrder="37" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id1">
          <dataDescriptor expression="DOV.AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="NUM1" datatype="vchar2" columnOrder="35" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num1">
          <dataDescriptor expression="dov.NUM" descriptiveExpression="NUM"
           order="2" width="100"/>
        </dataItem>
        <dataItem name="DATE_START" datatype="date" oracleDatatype="date"
         columnOrder="36" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Start">
          <dataDescriptor expression="dov.DATE_START"
           descriptiveExpression="DATE_START" order="3" oracleDatatype="date"
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
     parentColumn="ag_contract_header_id" childQuery="Q_DOVER"
     childColumn="AG_CONTRACT_HEADER_ID1" condition="eq" sqlClause="where"/>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link rel=Edit-Time-Data href="ag_dog_dov.files/editdata.mso">
<link rel=OLE-Object-Data href="ag_dog_dov.files/oledata.mso">
<title></title>
<style>
<!--
span.SpellE
span.GramE
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>
</head>
<body bgcolor="#FFFFFF" lang=EN-US>
<rw:foreach id="agent" src="G_AGENT">
<rw:getValue id="AGDOGNUM" src="NUM"/>
<rw:getValue id="AGNAME" src="AGENT_NAME"/>
<rw:getValue id="AGADDR" src="ADDR"/>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
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
String PBSER = new String("");
String PBNUM = new String("");
String PBVIDAN = new String("");
String PBDATAV = new String("");


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

//DOVERENNOST
String DOVNUM = new String();
String DOVDATA = new String();


%>

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
<rw:getValue id="PB_SER" src="P_SER"/>
<rw:getValue id="PB_NUM" src="P_NUM"/>
<rw:getValue id="PB_VIDAN" src="PVIDAN"/>
<rw:getValue id="PB_DATA_V" src="DATA_V"/>
<%
    PBSER = PB_SER;
    PBNUM = PB_NUM;
    PBVIDAN = PB_VIDAN;
    PBDATAV = PB_DATA_V;

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
<rw:foreach id="gdaver" src="G_DOVER">
  <rw:getValue id="DOV_N" src="NUM1"/> 
  <%DOVNUM = DOV_N;%>
  <rw:getValue id="DOG_DATA" src="DATE_START" formatMask="DD.MM.YYYY"/> 
  <%DOVDATA =  DOG_DATA; %>
</rw:foreach>

<div class=Section1>
  <table border=0 cellspacing=0 cellpadding=0 width=662>
    <tr>
      <td width=662 valign=top><p><span style='font-size:11.0pt;
'><img width=108 height=32
src="<%=g_ImagesRoot%>/ag_dog_dov.files/image002.jpg" v:shapes="_x0000_i1025"></span><b><span lang=RU style='font-size:11.0pt;'>&nbsp;</span></b></p>
        <p align=center style='text-align:center'><b><span lang=RU style='font-size:11.0pt;'>ДОВЕРЕННОСТЬ</span></b><b><span style='font-size:11.0pt'>  </span></b><b><span lang=RU style='font-size:11.0pt;color:#333333;'>№ </span></b><b><span style='font-size:
11.0pt;color:#333333'><%=DOVNUM%></span></b></p>
        <p><span lang=RU style='font-size:11.0pt;'>&nbsp;</span></p>
        <p style='text-align:justify;tab-stops:0in'><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;'>город Москва                                                                                                               </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><%=SYSD%></span></p>
        <p style='text-align:justify'><a name="date_from"><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'><%=DOVDATA%>  (дата выдачи доверенности прописью)</span></a></p>
        <p style='text-align:justify'><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;'>__________________________________________________________________________________</span></p>
        <p style='text-align:justify;tab-stops:196.8pt 437.75pt'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>Общество
          с ограниченной ответственностью <%=ORGNAME%>  ИНН <%=ORGINN%>,  в лице Генерального
          директора <%=CHIEF_NAME%>, действующего на основании Устава, (далее – «Общество»),
          настоящей доверенностью уполномочивает <%=AGNAME%></span></p>
        <p style='text-align:justify;tab-stops:196.8pt 437.75pt'><span
class=GramE><span lang=RU style='font-size:11.0pt;letter-spacing:.7pt;
'>имеющего</span></span><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;'> (<span class=SpellE>щую</span>)
          паспорт серии <%=PS%> № <%=PNUM%>, выданный <%=PVIDAN%>, дата выдачи <%=DATAV%>, зарегистрированного
          (<span class=SpellE>ую</span>) по адресу: <%=AGADDR%>, являющегося Агентом</span></p>
        <p style='text-align:justify;tab-stops:196.8pt 437.75pt'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>по
          договору № <%=AGDOGNUM%>  от  <%=DATE_BEGIN%><b><span
style='color:#333333'>,</span></b></span></p>
        <p style='margin-top:6.0pt;text-align:justify;tab-stops:255.15pt'><span
lang=RU style='font-size:11.0pt;color:#333333;letter-spacing:.7pt;'>&nbsp;</span><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>совершать
          от имени Общества следующие действия:</span></p>
        <p style='margin-left:27.0pt;text-align:justify;text-indent:
-.25in'><span lang=RU>1. Проводить на территории
          Российской Федерации переговоры с физическими и юридическими лицами о
          заключении договоров по следующим видам страхования: страхование жизни и
          страхование от несчастных случаев и болезней.</span></p>
        <p style='margin-left:27.0pt;text-align:justify;text-indent:
-.25in'><span lang=RU>2. Консультировать
          потенциальных клиентов, по вопросам, связанным с заключением договоров
          страхования жизни и от несчастных случаев и болезней.</span></p>
        <p style='margin-left:27.0pt;text-align:justify;text-indent:
-.25in'><span lang=RU>3. Оформлять документы,
          необходимые для заключения Обществом вышеуказанных договоров страхования, в
          частности Заявления на страхование, Направления на медицинское обследование к
          Заявлениям на страхование, квитанции формы А-7.</span></p>
        <p style='margin-left:27.0pt;text-align:justify;text-indent:
-.25in'><span lang=RU>4. Осуществлять расчет по
          договорам страхования (полисам) в соответствии с действующими тарифными
          сборниками Общества и принимать от страхователей страховые премии (взносы) по
          заключенным договорам страхования наличными деньгами с выдачей страхователю
          квитанции установленного образца с целью их последующего перечисления на
          расчетный счет Общества. </span></p>
        <p style='text-align:justify; margin-bottom: 6.0pt;'><span lang=RU>&nbsp;</span></p>
        <p style='text-align:justify; margin-bottom: 6.0pt;'><span
lang=RU>Доверенность выдана сроком на один год без
          права передоверия другим лицам.</span></p>
        <p style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>Образец
          подписи</span></p>
        <p style='margin-bottom:6.0pt;text-align:justify'><a
name="agent_name_R"><span lang=RU style='font-size:11.0pt;color:black;
letter-spacing:.7pt;'>ФИО Агента</span></a><span lang=RU style='font-size:11.0pt;
color:blue;letter-spacing:.7pt;'> </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><%=AGNAME%></span><span
style='font-size:11.0pt;letter-spacing:.7pt;'>  <span lang=RU>удостоверяю.</span></span></p>
        <p style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>&nbsp;</span></p>
        <p style='margin-bottom:6.0pt;text-align:justify'><span
lang=RU style='font-size:11.0pt;letter-spacing:.7pt;'>Генеральный
          директор _______________________________________________ </span><span
style='font-size:11.0pt;letter-spacing:.7pt'><%=CHIEF_NAME%></span><span lang=RU
style='font-size:11.0pt;letter-spacing:.7pt;'>.</span></p>
        <p style='text-align:justify'><span lang=RU style='font-size:
11.0pt;letter-spacing:.7pt;'>&nbsp;</span></p></td>
    </tr>
    <tr>
      <td valign=top>&nbsp;</td>
    </tr>
  </table>
</div>
</rw:foreach>
</body>
</html>
</rw:report>
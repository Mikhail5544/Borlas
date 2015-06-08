<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="lifeVision"> 
<%
String docInfNVL = new String("______________________________________");
String addrNVL = new   String("______________________________________");
String telNVL = new   String("_____________");
String polnumNVL = new String("_______________");
%>
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="live version" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="LIVE VERSION" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_POLICY">
      <select>
      <![CDATA[SELECT p.policy_id,ph.POLICY_HEADER_ID,
        nvl(DECODE (NVL (pol_ser, '@'),
        '@', pol_num,
        pol_ser || '-' || pol_num
        ),'@@') pol_ser_num, utils.date2genitive_case(p.start_date) start_date, utils.date2genitive_case(p.end_date) end_date, p.SIGN_DATE, p.ins_amount,
        p.premium
        FROM ven_p_policy p, ven_p_pol_header ph
        WHERE p.policy_id = ph.policy_id and ph.policy_header_id =
        :P_POLICY_HEADER_ID
        ]]>
      </select>
      <displayInfo x="1.22913" y="1.16663" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.73828" y="1.86658" width="1.68176" height="1.62695"
        />
        <dataItem name="premium" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Premium">
          <dataDescriptor expression="p.premium"
           descriptiveExpression="PREMIUM" order="8" oracleDatatype="number"
           width="22" scale="2" precision="11"/>
        </dataItem>
        <dataItem name="ins_amount" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="p.ins_amount"
           descriptiveExpression="INS_AMOUNT" order="7"
           oracleDatatype="number" width="22" scale="2" precision="11"/>
        </dataItem>
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="12"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="p.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POLICY_HEADER_ID" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="ph.POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="pol_ser_num" datatype="vchar2" columnOrder="14"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num">
          <dataDescriptor
           expression="DECODE ( NVL ( pol_ser , &apos;@&apos; ) , &apos;@&apos; , pol_num , pol_ser || &apos;-&apos; || pol_num )"
           descriptiveExpression="POL_SER_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="start_date" datatype="vchar2" columnOrder="15"
         width="4000" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor
           expression="utils.date2genitive_case ( p.start_date )"
           descriptiveExpression="START_DATE" order="4" width="4000"/>
        </dataItem>
        <dataItem name="end_date" datatype="vchar2" columnOrder="16"
         width="4000" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="utils.date2genitive_case ( p.end_date )"
           descriptiveExpression="END_DATE" order="5" width="4000"/>
        </dataItem>
        <dataItem name="SIGN_DATE" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sign Date">
          <dataDescriptor expression="p.SIGN_DATE"
           descriptiveExpression="SIGN_DATE" order="6" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT pkg_contact.get_essential(pkg_app_param.get_app_param_u('WHOAMI')) ORG_CONT FROM DUAL]]>
      </select>
      <displayInfo x="3.23962" y="0.28113" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="2.96753" y="0.98108" width="1.24426" height="0.43066"
        />
        <dataItem name="ORG_CONT" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Org Cont">
          <dataDescriptor
           expression="pkg_contact.get_essential ( pkg_app_param.get_app_param_u ( &apos;WHOAMI&apos; ) )"
           descriptiveExpression="ORG_CONT" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL">
      <select>
      <![CDATA[SELECT iss.policy_id, iss.contact_id, iss.contact_name, vcp.date_of_birth,
       nvl(trim(pkg_contact.get_primary_doc (iss.contact_id)), '@@') doc_inf,
       nvl(trim(pkg_contact.get_address_name
                        (pkg_contact.get_primary_address (iss.contact_id)
                        )), '@@') addr,
       nvl(trim(pkg_contact.get_primary_tel (iss.contact_id)), '@@') tel, vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id;
       ]]>
      </select>
      <displayInfo x="3.45837" y="1.46875" width="0.69995" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="3.12903" y="1.85413" width="1.35876" height="1.62695"
        />
        <dataItem name="short_name" datatype="vchar2" columnOrder="40"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Short Name">
          <dataDescriptor expression="vc.short_name"
           descriptiveExpression="SHORT_NAME" order="8" width="100"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="26" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_address_name ( pkg_contact.get_primary_address ( iss.contact_id ) ) , &apos;_____________________________________________________________&apos; )"
           descriptiveExpression="ADDR" order="6" width="4000"/>
        </dataItem>
        <dataItem name="tel" datatype="vchar2" columnOrder="27" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_primary_tel ( iss.contact_id ) , &apos;_______________&apos; )"
           descriptiveExpression="TEL" order="7" width="4000"/>
        </dataItem>
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="21"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="iss.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="date_of_birth" datatype="date" oracleDatatype="date"
         columnOrder="24" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( iss.contact_id )"
           descriptiveExpression="DOC_INF" order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ZASTRAHOVANNI">
      <select>
      <![CDATA[SELECT vas.assured_contact_id, a.as_asset_id, a.p_policy_id, vas.contact_id,
       fn_obj_name (a.ent_id, a.as_asset_id) contact_name, vcp.date_of_birth,
       nvl(trim(pkg_contact.get_primary_doc (vas.assured_contact_id)),'@@') doc_inf,
       nvl(trim(pkg_contact.get_address_name
                (pkg_contact.get_primary_address (vas.assured_contact_id)
                )), '@@') addr,
       nvl(trim(pkg_contact.get_primary_tel (vas.assured_contact_id)), '@@') tel
  FROM ven_as_asset a, ven_cn_person vcp, ven_as_assured vas
 WHERE a.as_asset_id = vas.as_assured_id
   AND vas.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="3.47986" y="3.57458" width="0.69995" height="0.32983"/>
      <group name="G_ZASTRAHOVANNI">
        <displayInfo x="3.02478" y="4.18750" width="1.61060" height="1.79785"
        />
        <dataItem name="assured_contact_id" oracleDatatype="number"
         columnOrder="36" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Assured Contact Id">
          <dataDescriptor expression="vas.assured_contact_id"
           descriptiveExpression="ASSURED_CONTACT_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="34" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr1">
          <dataDescriptor
           expression="pkg_contact.get_address_name ( pkg_contact.get_primary_address ( vas.assured_contact_id ) )"
           descriptiveExpression="ADDR" order="8" width="4000"/>
        </dataItem>
        <dataItem name="tel1" datatype="vchar2" columnOrder="35" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel1">
          <dataDescriptor
           expression="pkg_contact.get_primary_tel ( vas.assured_contact_id )"
           descriptiveExpression="TEL" order="9" width="4000"/>
        </dataItem>
        <dataItem name="as_asset_id" oracleDatatype="number" columnOrder="28"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id">
          <dataDescriptor expression="a.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="p_policy_id" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id">
          <dataDescriptor expression="a.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id1">
          <dataDescriptor expression="vas.contact_id"
           descriptiveExpression="CONTACT_ID" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name1" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name1">
          <dataDescriptor
           expression="fn_obj_name ( a.ent_id , a.as_asset_id )"
           descriptiveExpression="CONTACT_NAME" order="5" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth1" datatype="date" oracleDatatype="date"
         columnOrder="32" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth1">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf1" datatype="vchar2" columnOrder="33"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf1">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( vas.assured_contact_id )"
           descriptiveExpression="DOC_INF" order="7" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_RISKS">
      <select>
      <![CDATA[SELECT   COUNT (1) OVER () cnt, pc.as_asset_id, tp.description, t.description terr_cover
    FROM ven_p_cover pc,
         ven_t_prod_line_option plo,
         ven_t_prod_line_opt_peril plop,
         ven_t_peril tp,
         ven_t_prod_line_ter plt,
         t_territory t         
   WHERE pc.t_prod_line_option_id = plo.ID
     AND plo.ID = plop.product_line_option_id
     AND plop.peril_id = tp.ID
     and plo.PRODUCT_LINE_ID = plt.PRODUCT_LINE_ID
     and plt.T_TERRITORY_ID = t.T_TERRITORY_ID
ORDER BY pc.p_cover_id;
]]>
      </select>
      <displayInfo x="6.29163" y="3.93750" width="0.69995" height="0.32983"/>
      <group name="G_RISKS">
        <displayInfo x="5.92053" y="4.63745" width="1.44214" height="1.11426"
        />
        <dataItem name="terr_cover" datatype="vchar2" columnOrder="41"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Terr Cover">
          <dataDescriptor expression="t.description"
           descriptiveExpression="TERR_COVER" order="4" width="255"/>
        </dataItem>
        <dataItem name="CNT" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt">
          <dataDescriptor expression="COUNT ( 1 ) OVER ( )"
           descriptiveExpression="CNT" order="1" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="AS_ASSET_ID1" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id1">
          <dataDescriptor expression="pc.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DESCRIPTION" datatype="vchar2" columnOrder="38"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="tp.description"
           descriptiveExpression="DESCRIPTION" order="3" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STRAHOVATEL" childColumn="policy_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_ZASTRAHOVANNI" childColumn="p_policy_id" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_ZASTRAHOVANNI" parentColumn="as_asset_id"
     childQuery="Q_RISKS" childColumn="AS_ASSET_ID1" condition="eq"
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
    <link rel=File-List href="temp%20live%20version.files/filelist.xml">
    <title>Договор страхования по программе «Life-vision»</title>
    <style>
        <!--
        /* Font Definitions */
        @font-face
        {
            font-family: "Arial Narrow"
        ;
            panose-1: 2 11 5 6 2 2 2 3 2 4
        ;
            mso-font-charset: 204
        ;
            mso-generic-font-family: swiss
        ;
            mso-font-pitch: variable
        ;
            mso-font-signature: 647 0 0 0 159 0
        ;
        }
        /* Style Definitions */
        p.MsoNormal, li.MsoNormal, div.MsoNormal {
            mso-style-parent: "";
            margin: 0in;
            margin-bottom: .0001pt;
            mso-pagination: widow-orphan;
            font-size: 12.0pt;
            font-family: "Times New Roman";
            mso-fareast-font-family: "Times New Roman";
            mso-ansi-language: RU;
            mso-fareast-language: RU;
        }

        span.SpellE {
            mso-style-name: "";
            mso-spl-e: yes;
        }

        span.GramE {
            mso-style-name: "";
            mso-gram-e: yes;
        }

        @page
        Section1
        {
            size: 595.3pt 841.9pt
        ;
            margin: 36.85pt 37.3pt 36.85pt 85.05pt
        ;
            mso-header-margin: 35.45pt
        ;
            mso-footer-margin: 35.45pt
        ;
            mso-paper-source: 0
        ;
        }
        div.Section1 {
            page: Section1;
        }

        -->
    </style>

</head>

<body lang=EN-US style='tab-interval:.5in'>
<%
String SHORT_NAME = new String();
%>
<div class=Section1>
<rw:foreach id="gpolicy" src="G_POLICY">
<%
String strahName = new String();
String TERR_COVER = new String();

%>
<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=655
       style='width:493.75pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=655 colspan=2 valign=top style='width:493.75pt;border:none;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='text-align:center'><span lang=RU
                                                                        style='font-size:10.0pt;font-family:Arial'>Договор страхования по программе «</span><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'>LIFE</span><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>·</span><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'>VISION</span><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>». <o:p></o:p></span></p>
        <p class=MsoNormal align=center style='margin-left:.05in;text-align:center'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'>Договор страхования
  заключается на основании Общих условий (далее ОУ) страхования по программе «</span><span
                style='font-size:9.0pt;font-family:Arial;mso-ansi-language:EN-US'>LIFE</span><span
                lang=RU style='font-size:9.0pt;font-family:Arial'>·</span><span
                style='font-size:9.0pt;font-family:Arial;mso-ansi-language:EN-US'>VISION</span><span
                lang=RU style='font-size:9.0pt;font-family:Arial'>» <o:p></o:p></span></p>
        <p class=MsoNormal align=center style='margin-right:4.95pt;text-align:center'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:1pt;margin-bottom:
  0in;margin-left:225.0pt;margin-bottom:.0001pt;text-indent:63.0pt;text-align:right;'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Номер договора:<span
                style='mso-spacerun:yes'>   </span>
<rw:getValue id="tmpVal0" src="pol_ser_num"/>  
<%if (!tmpVal0.equals("@#@")){%>                              
                <u><rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field</rw:field></u>
<%} else {%>                
<%=polnumNVL%>
<%}%>
      <o:p></o:p></span></p>
        <p class=MsoNormal align=center style='margin-top:0in;margin-right:1pt;
  margin-bottom:0in;margin-left:45.0pt;margin-bottom:.0001pt;text-align:right;
  text-indent:27.0pt'><span lang=RU style='font-size:10.0pt;font-family:Arial'><span
                style='mso-spacerun:yes'>                     </span>Дата подписания (заключения)
  договора страхования:<span style='mso-spacerun:yes'>  </span></span><u><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'>
      <rw:field id="F_SIGN_DATE" src="SIGN_DATE" formatMask="DD.MM.YYYY"> &Field</rw:field>
  </span></u><u><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p></o:p></span></u></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:Arial'><o:p>&nbsp;</o:p></span></b></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:Arial'>Страховщик: </span></b><span style='font-size:9.0pt;
  font-family:Arial;mso-ansi-language:EN-US'>
        <u>
        <rw:foreach id="gorgcont" src="G_ORG_CONT">
            <rw:field id="F_ORG_CONT" src="ORG_CONT"> &Field</rw:field>
        </rw:foreach>
        </u>    
  </span>

            <b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:Arial'><span
                style='mso-spacerun:yes'>                              </span></span></b><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p></o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal align=right style='margin-right:1pt;text-align:left;'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><span
                style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
<rw:foreach id="gstrahovatel" src="G_STRAHOVATEL">
<rw:getValue id="strahName_tmp" src="CONTACT_NAME"/>
<rw:getValue id="SHORT_NAME_TMP" src="SHORT_NAME"/>
<%
SHORT_NAME = SHORT_NAME_TMP;
strahName = new String(strahName_tmp);
%>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify;'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Ф.И.О. Страхователя <i
                style='mso-bidi-font-style:normal'><u>
            <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field </rw:field>
            </u></i></span><i
                style='mso-bidi-font-style:normal'><u><span style='font-size:10.0pt;
  font-family:Arial;background:#B3B3B3;mso-ansi-language:EN-US'><o:p></o:p></span></u></i>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Дата рождения Страхователя
  <i style='mso-bidi-font-style:normal'><u>
      <rw:field id="F_DATE_OF_BIRTH" src="DATE_OF_BIRTH" formatMask="DD.MM.YYYY"> &Field </rw:field>
      </u></i>
  <o:p></o:p></span>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'> Данные документа,
  удостоверяющего личность (серия, номер, кем и когда выдан)<span
                style='mso-spacerun:yes'>  </span><o:p></o:p></span>
        <i
                style='mso-bidi-font-style:normal'>
<rw:getValue id="tmpVal" src="DOC_INF"/>  
<%if (!tmpVal.equals("@@")){%>              
                <u><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>
            <rw:field id="F_DOC_INF" src="DOC_INF"> &Field </rw:field>
            </span></u>
<%} else{%>            
                <span lang=RU style='font-size:10.0pt;
  font-family:Arial'>
<%=docInfNVL%></span>

<%}%>
            </i><i
                style='mso-bidi-font-style:normal'><u><span style='font-size:10.0pt;
  font-family:Arial;mso-ansi-language:EN-US'><o:p></o:p></span></u></i>
        <span lang=RU style='font-size:10.0pt;font-family:Arial'> Адрес <i style='mso-bidi-font-style:
  normal'>
<rw:getValue id="tmpVal1" src="ADDR"/>  
<%if (!tmpVal1.equals("@@")){%>              
  
  <u><rw:field id="F_ADDR" src="ADDR"> &Field </rw:field></u>
<%} else{%><%=addrNVL%> <%}%>  
  </i></span><i
                style='mso-bidi-font-style:normal'><span style='font-size:10.0pt;font-family:
  Arial;mso-ansi-language:EN-US'><o:p></o:p></span></i>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'> Телефон <span
                style='mso-spacerun:yes'></span><i style='mso-bidi-font-style:normal'>
<rw:getValue id="tmpVal2" src="TEL"/>  
<%if (!tmpVal2.equals("@@")){%>              
                
                <u> <rw:field id="F_TEL" src="TEL"> &Field </rw:field></u>
<%} else{%><%=telNVL%><%}%>
             

            <o:p></o:p>
        </i></span></p>
</rw:foreach>
<rw:foreach id="gzastrahovanni" src="G_ZASTRAHOVANNI">
<rw:getValue id="zastrahName" src="CONTACT_NAME1"/>
<%  if (zastrahName.equals(strahName)){
%>
    <p class=MsoNormal style='margin-right:1pt;text-align:left'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><i>
        <p></p>
        <p>Застрахованный является Страхователем</p>
        <p></p>
        
    </i><o:p></o:p></span></p>
<%}
    else {
%>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Данные о <span
                class=GramE>Застрахованном</span> <o:p></o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Ф.И.О. Застрахованного <i
                style='mso-bidi-font-style:normal'><u>
            <rw:field id="F_CONTACT_NAME1" src="CONTACT_NAME1"> &Field </rw:field>
            </u></i></span><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'><o:p></o:p></span>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Дата рождения Застрахованного
  <i style='mso-bidi-font-style:normal'><u>
      <rw:field id="F_DATE_OF_BIRTH1" src="DATE_OF_BIRTH1" formatMask="DD.MM.YYYY"> &Field </rw:field>
      </u></i><u>
            <o:p></o:p>
        </u></span>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'><span
                style='mso-spacerun:yes'> </span>Данные документа, удостоверяющего личность
  (серия, номер, кем и когда выдан)<span style='mso-spacerun:yes'>  </span><o:p></o:p></span>
        <i
                style='mso-bidi-font-style:normal'>
                
<span lang=RU style='font-size:10.0pt; font-family:Arial'>
<rw:getValue id="tmpVal3" src="DOC_INF1"/>  
<%if (!tmpVal3.equals("@@")){%>              
           <u><rw:field id="F_DOC_INF1" src="DOC_INF1"> &Field </rw:field></u>
<%} else {%>            
<%=docInfNVL%>
<%}%>            
</span>
</i><i
                style='mso-bidi-font-style:normal'><u><span style='font-size:10.0pt;
  font-family:Arial;mso-ansi-language:EN-US'><o:p></o:p></span></u></i>
       <span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Адрес <i style='mso-bidi-font-style:
  normal'>  
<rw:getValue id="tmpVa4" src="ADDR1"/>  
<%if (!tmpVa4.equals("@@")){%>              
  <u><rw:field id="F_ADDR1" src="ADDR1"> &Field </rw:field></u>
<%} else {%>            
<%=addrNVL%>
<%}%></i></span><i
                style='mso-bidi-font-style:normal'><span style='font-size:10.0pt;font-family:
  Arial;mso-ansi-language:EN-US'><o:p></o:p></span></i>
        <span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Телефон<span
                style='mso-spacerun:yes'>  </span><i style='mso-bidi-font-style:normal'>
<rw:getValue id="tmpVal5" src="TEL1"/>  
<%if (!tmpVal5.equals("@@")){%>                             
<u><rw:field id="F_TEL1" src="TEL1"> &Field </rw:field></u>
<%} else {%>                
<%=telNVL%>
<%}%>
                </i><u>
            <o:p></o:p>
        </u></span></p>
<%}%>
</rw:foreach>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Период страхования: с<span
                style='mso-spacerun:yes'>  </span><u>
            <rw:field id="F_START_DATE" src="START_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
            </u><span
                style='mso-spacerun:yes'>  </span>по <u>
            <rw:field id="F_END_DATE" src="END_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
            </u>
  , при условии оплаты годовой страховой премии. <o:p></o:p></span></p>
        <p class=MsoNormal align=center style='text-align:center'><span lang=RU
                                                                        style='font-size:10.0pt;font-family:Arial'><o:p>
            &nbsp;</o:p></span></p>
<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width="100%"
       style='border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
<tr style='mso-yfti-irow:2'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
     mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:Arial'>Страховая
  сумма</span><span lang=RU style='font-size:8.0pt;font-family:Arial'>:<span
                style='mso-spacerun:yes'>                              </span><o:p></o:p></span></p>
    </td>
    <td width="60%" valign=top style='border:solid windowtext 1.0pt;
     mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='text-align:center'><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>
                <rw:field id="F_INS_AMOUNT" src="INS_AMOUNT" formatMask="999999990D99"> &Field </rw:field>
                </span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></p>
    </td>
</tr>
<tr style='mso-yfti-irow:3'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-right:-4.3pt'><span lang=RU
                                                             style='font-size:8.0pt;font-family:Arial'>Годовая страховая премия</span><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>
        </span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>:<span
                style='mso-spacerun:yes'>                    </span><o:p></o:p></span></p>
    </td>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='margin-right:-4.3pt;text-align:center'><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>
         <rw:field id="F_PREMIUM" src="PREMIUM" formatMask="999999990D99"> &Field </rw:field>   
        </span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></p>
    </td>
</tr>
<%boolean showCapt = true;%>
<rw:foreach id="grisks" src="G_RISKS">
<rw:getValue id="riskCount" src="CNT"/>
<rw:getValue id="TERR_COVER_TMP" src="TERR_COVER"/>
<%TERR_COVER = TERR_COVER_TMP;%>
<tr style='mso-yfti-irow:4'>
  <%
    if (showCapt) {
  %>

    <td  width="40%" valign=top style='width:184.75pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt' rowspan=<%=riskCount%>>
        <p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:Arial'>Страховые
  риски: <o:p></o:p></span></p>
    </td>
    <%
        showCapt = false;
     }
    %>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='text-align:center'><span lang=RU
                                                                        style='font-size:8.0pt;font-family:Arial'>
            <rw:field id="F_DESCRIPTION" src="DESCRIPTION"> &Field </rw:field>
        </span><span lang=RU style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span>
        </p>
    </td>
</tr>
</rw:foreach>
<tr style='mso-yfti-irow:5'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-right:-5.45pt'><span lang=RU
                                                              style='font-size:8.0pt;font-family:Arial'>Территория действия страхования:<o:p></o:p></span>
        </p>
    </td>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='margin-right:-5.45pt;text-align:center'><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><%=TERR_COVER%><o:p></o:p></span></p>
    </td>
</tr>
</table>
        <p class=MsoNormal style='margin-top:0in;margin-right:1pt;margin-bottom:
  0in;margin-bottom:.0001pt;text-align:justify'><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:1pt;margin-bottom:
  0in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Декларация Страхователя:<o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:1pt;margin-bottom:
  0in;margin-bottom:.0001pt;text-align:justify'><span
                class=GramE><span lang=RU style='font-size:8.0pt;font-family:Arial'>Настоящим
  заявляю, что лицо, указанное в настоящем договоре в качестве Застрахованного
  не является инвалидом </span><span style='font-size:8.0pt;font-family:Arial;
  mso-ansi-language:EN-US'>I</span><span lang=RU style='font-size:8.0pt;
  font-family:Arial'>-<span class=SpellE>й</span> или </span><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>II</span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>-<span class=SpellE>й</span>
  группы, не страдает психическими заболеваниями, не имеет ограничений
  нормальной жизнедеятельности в виде расстройств зрения, слуха, координации
  движений, нарушений опорно-двигательного аппарата и т.п., не имеет
  хронических заболеваний сердечно-сосудистой, нервной, пищеварительной,
  дыхательной, мочеполовой, иммунной, эндокринной, костно-мышечной и иных
  систем, повышающих риск наступления страхового случая</span></span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>, не страдает алкоголизмом,
  не употребляет наркотические, токсические или сильнодействующие вещества. Я
  также подтверждаю, что на момент заключения договора страхования лицо,
  указанное в настоящем договоре в качестве Застрахованного не страдает
  каким-либо острым заболеванием и не нуждается в медицинском обследовании,
  лечении или консультации врача в условиях поликлиники или стационара. Я
  понимаю, что сообщение мною ложных сведений, равно как и отказ в предоставлении
  достоверных сведений повлечет отказ в страховой выплате. <o:p></o:p></span></p>
        <p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-right:8.7pt;text-align:justify'><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>Стороны признают <span
                class=SpellE>факсимильно</span> воспроизведенную подпись Страховщика
  подлинной. Страхователь подтверждает получение Общих условий страхования по
  программе «</span><span style='font-size:8.0pt;font-family:Arial;mso-ansi-language:
  EN-US'>LIFE</span><span lang=RU style='font-size:8.0pt;font-family:Arial'>·</span><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>VISION</span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>».<o:p></o:p></span></p>
        <p class=MsoNormal align=center style='margin-right:-5.45pt;text-align:center'><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
</tr>
</table>
</rw:foreach>
<p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
        lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:1pt'><span lang=RU style='font-size:
8.0pt;font-family:Arial'><span
        style='mso-spacerun:yes'>                         </span><span
        style='mso-spacerun:yes'>                                 </span><o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
        lang=RU style='font-size:10.0pt;font-family:Arial'>Подпись Страхователя<span
        class=GramE>: _________________(<%=SHORT_NAME%>) </span><o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
        lang=RU style='font-size:8.0pt;font-family:Arial'><span
        style='mso-spacerun:yes'>                                                                                          
</span>Расшифровка подписи</span><span lang=RU style='font-size:10.0pt;
font-family:Arial'><o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
        lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:1pt;text-align:justify'><span
        lang=RU style='font-size:10.0pt;font-family:Arial'>Подпись Страховщика
___________________<o:p></o:p></span></p>

<p class=MsoNormal><span lang=RU><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report>

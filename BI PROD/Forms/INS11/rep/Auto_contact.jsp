<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report" >

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="Auto_contact" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AUTO_CONTACT" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_POLICY">
      <select>
      <![CDATA[SELECT p.policy_id, ph.policy_header_id,
       NVL(DECODE (NVL (pol_ser, '@'),
               '@', pol_num,
               pol_ser || '-' || pol_num
              ),'___________') pol_ser_num,
       p.start_date, p.end_date, p.sign_date, NVL (p.ins_amount,
                                                   0) ins_amount,
       NVL (p.premium, 0) premium, '"'||vtp.description||'"' prod_desc
  FROM ven_p_policy p, ven_p_pol_header ph, ven_t_product vtp
 WHERE p.policy_id = ph.policy_id
   AND ph.product_id = vtp.product_id
   AND ph.policy_header_id = :p_policy_header_id]]>
      </select>
      <displayInfo x="1.19788" y="0.85413" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.70703" y="1.28125" width="1.68176" height="1.96875"
        />
        <dataItem name="prod_desc" datatype="vchar2" columnOrder="20"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Prod Dec">
          <dataDescriptor expression="vtp.description"
           descriptiveExpression="PROD_DESC" order="9" width="255"/>
        </dataItem>
        <dataItem name="SIGN_DATE" datatype="date" oracleDatatype="date"
         columnOrder="19" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sign Date">
          <dataDescriptor expression="p.sign_date"
           descriptiveExpression="SIGN_DATE" order="6" oracleDatatype="date"
           width="9"/>
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
          <dataDescriptor expression="ph.policy_header_id"
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
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="15" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="p.start_date"
           descriptiveExpression="START_DATE" order="4" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="end_date" datatype="date" oracleDatatype="date"
         columnOrder="16" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="p.end_date"
           descriptiveExpression="END_DATE" order="5" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="ins_amount" oracleDatatype="number" columnOrder="17"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="NVL ( p.ins_amount , 0 )"
           descriptiveExpression="INS_AMOUNT" order="7"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="premium" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Premium">
          <dataDescriptor expression="NVL ( p.premium , 0 )"
           descriptiveExpression="PREMIUM" order="8" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT pkg_contact.get_essential(pkg_app_param.get_app_param_u('WHOAMI')) ORG_CONT FROM DUAL]]>
      </select>
      <displayInfo x="2.84387" y="0.05200" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="2.57166" y="0.56445" width="1.24426" height="0.43066"
        />
        <dataItem name="ORG_CONT" datatype="vchar2" columnOrder="21"
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
       pkg_contact.get_primary_doc (iss.contact_id) doc_inf,
       NVL
          (pkg_contact.get_address_name
                              (pkg_contact.get_primary_address (iss.contact_id)
                              ),
           '@@'
          ) addr,
       NVL (pkg_contact.get_primary_tel (iss.contact_id), '____________') tel,
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id]]>
      </select>
      <displayInfo x="1.22913" y="3.65613" width="0.69995" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="0.89978" y="4.35608" width="1.35876" height="1.62695"
        />
        <dataItem name="short_name" datatype="vchar2" columnOrder="29"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Short Name">
          <dataDescriptor expression="vc.short_name"
           descriptiveExpression="SHORT_NAME" order="8" width="100"/>
        </dataItem>
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="23"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="iss.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="24"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth" datatype="date" oracleDatatype="date"
         columnOrder="25" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( iss.contact_id )"
           descriptiveExpression="DOC_INF" order="5" width="4000"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="27" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="NVL ( pkg_contact.get_address_name ( pkg_contact.get_primary_address ( iss.contact_id ) ) , &apos;@@&apos; )"
           descriptiveExpression="ADDR" order="6" width="4000"/>
        </dataItem>
        <dataItem name="tel" datatype="vchar2" columnOrder="28" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel">
          <dataDescriptor
           expression="NVL ( pkg_contact.get_primary_tel ( iss.contact_id ) , &apos;____________&apos; )"
           descriptiveExpression="TEL" order="7" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ZASTRAHOVANNI">
      <select>
      <![CDATA[SELECT vas.assured_contact_id, a.as_asset_id, a.p_policy_id, vas.contact_id,
       fn_obj_name (a.ent_id, a.as_asset_id) contact_name, vcp.date_of_birth,
       pkg_contact.get_primary_doc (vas.assured_contact_id) doc_inf,
       nvl(pkg_contact.get_address_name
                (pkg_contact.get_primary_address (vas.assured_contact_id)
                ),'@@') addr,
       nvl(pkg_contact.get_primary_tel (vas.assured_contact_id), '____________' ) tel
  FROM ven_as_asset a, ven_cn_person vcp, ven_as_assured vas
 WHERE a.as_asset_id = vas.as_assured_id
   AND vas.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="3.45837" y="1.44800" width="0.69995" height="0.32983"/>
      <group name="G_ZASTRAHOVANNI">
        <displayInfo x="2.98315" y="2.14795" width="1.65051" height="1.79785"
        />
        <dataItem name="assured_contact_id" oracleDatatype="number"
         columnOrder="30" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Assured Contact Id">
          <dataDescriptor expression="vas.assured_contact_id"
           descriptiveExpression="ASSURED_CONTACT_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="as_asset_id" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id">
          <dataDescriptor expression="a.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="p_policy_id" oracleDatatype="number" columnOrder="32"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id">
          <dataDescriptor expression="a.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id1">
          <dataDescriptor expression="vas.contact_id"
           descriptiveExpression="CONTACT_ID" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name1" datatype="vchar2" columnOrder="34"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name1">
          <dataDescriptor
           expression="fn_obj_name ( a.ent_id , a.as_asset_id )"
           descriptiveExpression="CONTACT_NAME" order="5" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth1" datatype="date" oracleDatatype="date"
         columnOrder="35" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth1">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf1" datatype="vchar2" columnOrder="36"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf1">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( vas.assured_contact_id )"
           descriptiveExpression="DOC_INF" order="7" width="4000"/>
        </dataItem>
        <dataItem name="addr1" datatype="vchar2" columnOrder="37" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr1">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_address_name ( pkg_contact.get_primary_address ( vas.assured_contact_id ) ) , &apos;@@&apos; )"
           descriptiveExpression="ADDR" order="8" width="4000"/>
        </dataItem>
        <dataItem name="tel1" datatype="vchar2" columnOrder="38" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel1">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_primary_tel ( vas.assured_contact_id ) , &apos;____________&apos; )"
           descriptiveExpression="TEL" order="9" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_RISKS">
      <select>
      <![CDATA[SELECT   COUNT (1) OVER () cnt, pc.as_asset_id, tp.description risk_desc,
         pl.description pr_line_desc, t.description terr_cover
    FROM ven_p_cover pc,
         ven_t_prod_line_option plo,
         ven_t_prod_line_opt_peril plop,
         ven_t_peril tp,
         ven_t_product_line pl,
         ven_t_prod_line_ter plt,
         t_territory t
   WHERE pc.t_prod_line_option_id = plo.ID
     AND plo.ID = plop.product_line_option_id
     AND plo.product_line_id = pl.ID
     AND plop.peril_id = tp.ID
     AND pl.ID = plt.product_line_id(+)
     AND plt.t_territory_id = t.t_territory_id(+)
ORDER BY pc.p_cover_id;        
]]>
      </select>
      <displayInfo x="5.47913" y="1.52087" width="0.69995" height="0.32983"/>
      <group name="G_pr_line_desc">
        <displayInfo x="5.12878" y="2.27808" width="1.47510" height="0.60156"
        />
        <dataItem name="terr_cover" datatype="vchar2" columnOrder="43"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Terr Cover">
          <dataDescriptor expression="t.description"
           descriptiveExpression="TERR_COVER" order="5" width="255"/>
        </dataItem>
        <dataItem name="pr_line_desc" datatype="vchar2" columnOrder="42"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pr Line Desc">
          <dataDescriptor expression="pl.description"
           descriptiveExpression="PR_LINE_DESC" order="4" width="255"/>
        </dataItem>
      </group>
      <group name="G_RISKS">
        <displayInfo x="5.12878" y="3.21033" width="1.44214" height="1.11426"
        />
        <dataItem name="CNT" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt">
          <dataDescriptor expression="COUNT ( 1 ) OVER ( )"
           descriptiveExpression="CNT" order="1" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="AS_ASSET_ID1" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id1">
          <dataDescriptor expression="pc.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="risk_desc" datatype="vchar2" columnOrder="41"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <xmlSettings xmlTag="DESCRIPTION"/>
          <dataDescriptor expression="tp.description"
           descriptiveExpression="RISK_DESC" order="3" width="500"/>
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
<rw:foreach id="gpolicy" src="G_POLICY">
    <meta http-equiv=Content-Type content="text/html; charset=windows-1251">
    <meta name=ProgId content=Word.Document>
    <meta name=Generator content="Microsoft Word 11">
    <meta name=Originator content="Microsoft Word 11">
    <link rel=File-List href="Auto_contact.files/filelist.xml">
    <title>Договор страхования по программе 
    <rw:field id="F_PROD_DESC" src="PROD_DESC"> &Field </rw:field>
    </title>
    <style>
        <!--
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
.style1 {font-size: 12px}

        -->
    </style>
</head>

<body lang=EN-US style='tab-interval:.5in'>

<div class=Section1>
<%String strahName = new String();%>
<%String rasshifr = new String();%>
<p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:Arial'><span
        style='mso-spacerun:yes'>                                                                        
</span><o:p></o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=684
       style='width:513.0pt;margin-left:-.05in;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=684 colspan=2 valign=top style='width:513.0pt;border:none;
  mso-border-bottom-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:center'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Договор страхования по
  программе  
  <rw:field id="F_PROD_DESC1" src="PROD_DESC"> &Field </rw:field>
  <o:p></o:p></span></p>
        <p class=MsoNormal align=center style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:center'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'>Договор страхования
  заключается на основании Общих условий (далее ОУ) страхования по программе
  <rw:field id="F_PROD_DESC2" src="PROD_DESC"> &Field </rw:field>
  (приведены на обратной стороне договора).<o:p></o:p></span></p>
        <p class=MsoNormal align=right style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:right'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal align=right style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:right'>
            <span lang=RU style='font-size:10.0pt;font-family:Arial'>Номер договора
  (определяется оператором):<span style='mso-spacerun:yes'>  </span>
                <u>
                    <rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field </rw:field>
                    <i style='mso-bidi-font-style:normal'> <o:p></o:p></i></u>

            </span></p>
        <p class=MsoNormal align=right style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:right'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Код офиса платежной
  системы «КОНТАКТ»:___________</span><i style='mso-bidi-font-style:normal'><u><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p></o:p></span></u></i></p>
        <p class=MsoNormal align=center style='margin-top:0in;margin-right:.05in;
  margin-bottom:0in;margin-left:.05in;margin-bottom:.0001pt;text-align:center'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>Страховщик: </b><u>
            <rw:foreach id="gorgcont" src="G_ORG_CONT">
                <span lang=RU style='font-size:
  10.0pt;font-family:Arial'>
  <rw:field id="F_ORG_CONT" src="ORG_CONT"> &Field</rw:field>
  </span>
            </rw:foreach>           
        </u><i
                style='mso-bidi-font-style:normal'><u><span lang=RU style='font-size:9.0pt;
  font-family:Arial'>
        <o:p></o:p></span></u></i></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
<rw:foreach id="gstrahovatel" src="G_STRAHOVATEL">
<rw:getValue id="strahName_tmp" src="CONTACT_NAME"/>
<rw:getValue id="shName_tmp" src="SHORT_NAME"/>

<%
strahName = new String(strahName_tmp);
rasshifr  = new String(shName_tmp);
%>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Страхователи: <o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Ф.И.О. Страхователя <i style='mso-bidi-font-style:
  normal'><u>
            <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field </rw:field>
        </u></i><u><span style='background:#B3B3B3'><o:p></o:p></span></u></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Дата рождения Страхователя <i style='mso-bidi-font-style:
  normal'><u>
            <rw:field id="F_DATE_OF_BIRTH" src="DATE_OF_BIRTH" formatMask="DD.MM.YYYY"> &Field </rw:field>
        </u></i>Данные документа, удостоверяющего личность (серия,
  номер, кем и когда выдан)<span style='mso-spacerun:yes'>  </span><i
                style='mso-bidi-font-style:normal'><u><span style='mso-tab-count:1'> </span>
            <rw:field id="F_DOC_INF" src="DOC_INF"> &Field </rw:field>
        </u></i><u>
            <o:p></o:p>
        </u></span></p>
<rw:getValue id="tmp_addr" src="ADDR"/>        
<%tmp_addr = "@@";
if (tmp_addr.equals("@@")) {%>
<table align="center" class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=100%>
<tr style='mso-yfti-irow:1;height:11.65pt'>
   <td width="10%" >
		
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'> Адрес </span></p> 
</td>  
<td width="90%" >

 <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>
  ______________________________________________________________________________________
  </span></p>
</td>
</tr>		
</table>		
<%} else {%>
<table align="center" class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=100%>
<tr style='mso-yfti-irow:1;height:11.65pt'>
   <td width="10%">		
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'> Адрес </span></p> 
</td>  
<td width="90%" >

 <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>
       <i><u> <rw:field id="F_ADDR" src="ADDR"> &Field </rw:field> </u></i>
</span></p>
</td>
</tr>		
</table>			
<%}%>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Телефон<span style='mso-spacerun:yes'>  </span><i
                style='mso-bidi-font-style:normal'><u>
            <rw:field id="F_TEL" src="TEL"> &Field </rw:field>
            <o:p></o:p>
        </u></i></span></p>
</rw:foreach>
<rw:foreach id="gzastrahovanni" src="G_ZASTRAHOVANNI">
<rw:getValue id="zastrahName" src="CONTACT_NAME1"/>
<%  if (zastrahName.equals(strahName)){
%>
    <p class=MsoNormal style='margin-right:-9.3pt;text-align:left'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'><i>
        <p></p>
        <p>Застрахованный является Страхователем</p>
        <p></p>

    </i><o:p></o:p></span></p>
<%}
    else {
%>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'>
            <span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Данные о <span class=GramE>Застрахованном</span>:<o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Ф.И.О. Застрахованного <i style='mso-bidi-font-style:
  normal'><u>
            <rw:field id="F_CONTACT_NAME1" src="CONTACT_NAME1"> &Field </rw:field>
            <o:p></o:p>
        </u></i></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Дата рождения Страхователя <i style='mso-bidi-font-style:
  normal'><u>
            <rw:field id="F_DATE_OF_BIRTH1" src="DATE_OF_BIRTH1" formatMask="DD.MM.YYYY"> &Field </rw:field>
        </u></i><span style='mso-spacerun:yes'>  </span>Данные
  документа, удостоверяющего личность (серия, номер, кем и когда выдан)<span
                style='mso-spacerun:yes'>  </span><i style='mso-bidi-font-style:normal'><u><span
                style='mso-tab-count:1'> </span>
            <rw:field id="F_DOC_INF1" src="DOC_INF1"> &Field </rw:field>
            <o:p></o:p>
        </u></i></span></p>
<rw:getValue id="tmp_addr1" src="ADDR1"/>        
<%if (tmp_addr1.equals("@@")) {%>
<table align="center" class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=100%>
<tr style='mso-yfti-irow:1;height:11.65pt'>
   <td width="10%" valign=middle height="25">
		
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'> Адрес </span></p> 
</td>  
<td width="90%" valign=bottom height="25">

 <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>
______________________________________________________________________________________
  </span></p>
</td>
</tr>		
</table>		
<%} else {%>
<table align="center" class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=100%>
<tr style='mso-yfti-irow:1;height:11.65pt'>
   <td width="10%">		
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'> Адрес </span></p> 
</td>  
<td width="90%" >

 <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>
       <i><u> <rw:field id="F_ADDR1" src="ADDR1"> &Field </rw:field> </u></i>
</span></p>
</td>
</tr>		
</table>			
<%}%>		
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Адрес <i style='mso-bidi-font-style:normal'><u><span
                style='mso-tab-count:1'>            </span>
        
            <o:p></o:p>
        </u></i></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Телефон<span style='mso-spacerun:yes'>  </span><i
                style='mso-bidi-font-style:normal'><u>
            <rw:field id="F_TEL1" src="TEL1"> &Field </rw:field>
            <o:p></o:p>
        </u></i></span></p>
<%}%>
</rw:foreach>        
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Период страхования: с <u>
            <rw:field id="F_START_DATE" src="START_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
        </u><span
                style='mso-spacerun:yes'> </span>по <u>
            <rw:field id="F_END_DATE" src="END_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
        </u>, при условии оплаты годовой
  страховой премии. <o:p></o:p></span></p>
        <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
                                                                        style='font-size:10.0pt;font-family:Arial'><o:p>
            &nbsp;</o:p></span></b></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                style='font-size:10.0pt;font-family:Arial;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
<rw:foreach id="gpr_line_desc" src="G_pr_line_desc">
<rw:getValue id="PR_LINE_DESC" src="PR_LINE_DESC"/>
<rw:getValue id="TERR_COVER" src="TERR_COVER"/>
<table align="center" class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=100%
       style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
<tr style='mso-yfti-irow:1;height:11.65pt'>
    <td colspan="2" align="left" valign=top style='border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:11.65pt'>
        <p class=MsoNormal style1><strong><span lang=RU style='font-family:Arial'><%=PR_LINE_DESC%>
        <span style='mso-spacerun:yes'>                              </span><o:p></o:p>
        </span></strong></p>    </td>
    </tr>
<tr style='mso-yfti-irow:1;height:11.65pt'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:11.65pt'>
        <p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:Arial'>Страховая сумма:
        <span style='mso-spacerun:yes'>                              </span><o:p></o:p></span></p>    </td>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:11.65pt'>
        <p class=MsoNormal align=center style='text-align:center'><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>
            <rw:field id="F_INS_AMOUNT" src="INS_AMOUNT"> &Field </rw:field>
        </span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></p>    </td>
</tr>
<tr style='mso-yfti-irow:2'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-right:-4.3pt'><span lang=RU
                                                             style='font-size:8.0pt;font-family:Arial'>Годовая страховая премия:<span
                style='mso-spacerun:yes'>                    </span><o:p></o:p></span></p>    </td>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal align=center style='text-align:center'><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>
            <rw:field id="F_PREMIUM" src="PREMIUM"> &Field </rw:field>
            <o:p></o:p></span></p>    </td>
</tr>
<%boolean showCapt = true;%>
<rw:foreach id="grisks" src="G_RISKS">
<rw:getValue id="riskCount" src="CNT"/>
<tr style='mso-yfti-irow:4'>
  <%
    if (showCapt) {
  %>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:9.85pt' rowspan= <%=riskCount%>>
        <p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:Arial'>Страховые
  риски: <o:p></o:p></span></p>    </td>
    <%showCapt = false;}
    %>
    <td width="60%" valign=top style='border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:9.85pt'>
        <p class=MsoNormal align=left style='text-align:left'>
		<span style='font-size:8.0pt;font-family:
  Arial;mso-ansi-language:EN-US'>
            <rw:field id="F_risk_desc" src="risk_desc"> &Field </rw:field>
            <o:p></o:p></span></p>    </td>
</tr>
</rw:foreach>

<tr style='mso-yfti-irow:4'>
    <td width="40%" valign=top style='border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-right:-5.45pt'><span lang=RU
                                                              style='font-size:8.0pt;font-family:Arial'>Территория страхования:<o:p></o:p></span>        </p>    </td>
    <td width="60%" valign=top style='border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:Arial'><%=TERR_COVER%><o:p></o:p></span></p>    </td>
</tr>
</table>
</rw:foreach>
		<p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Декларация Страхователя:<o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:.05in;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                class=GramE><span lang=RU style='font-size:8.0pt;font-family:Arial'>Настоящим
  заявляю, что лицо, указанное в настоящем полисе в качестве Застрахованного не
  является инвалидом </span><span style='font-size:8.0pt;font-family:Arial;
  mso-ansi-language:EN-US'>I</span><span lang=RU style='font-size:8.0pt;
  font-family:Arial'>-<span class=SpellE>й</span> или </span><span
                style='font-size:8.0pt;font-family:Arial;mso-ansi-language:EN-US'>II</span><span
                lang=RU style='font-size:8.0pt;font-family:Arial'>-<span class=SpellE>й</span>
  группы, не страдает психическими заболеваниями, не имеет ограничений
  нормальной жизнедеятельности в виде расстройств зрения, слуха, координации,
  нарушений опорно-двигательного аппарата и т.п., повышающих риск наступления
  страхового случая, не страдает алкоголизмом, не употребляет наркотические,
  токсические или сильнодействующие вещества.</span></span><span lang=RU
                                                                 style='font-size:8.0pt;font-family:Arial'> Я понимаю, что сообщение мною
  ложных сведений, равно как и отказ в предоставлении достоверных сведений
  повлечет отказ в страховой выплате. Я понимаю, что без соответствующей
  отметки сотрудника системы «КОНТАКТ» о принятии страхового взноса и
  подтверждения об оплате договор будет считаться недействительным. <o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Отметка сотрудника платежной системы КОНТАКТ о
  принятии страхового взноса: <i style='mso-bidi-font-style:normal'>____________________<span
                style='color:#999999'><o:p></o:p></span></i></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Дата подписания (заключения)
  договора страхования: <i style='mso-bidi-font-style:normal'><u>
            <rw:field id="F_SIGN_DATE" src="SIGN_DATE" formatMask="DD.MM.YYYY"> &Field</rw:field>
            <o:p></o:p>
        </u></i></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><span
                style='mso-spacerun:yes'>                                                                                                  
  </span><o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:10.0pt;font-family:Arial'>Подпись Страхователя<span
                class=GramE>: _________________(<%=rasshifr%>) </span><o:p></o:p></span></p>
        <p class=MsoNormal style='margin-top:0in;margin-right:-9.3pt;margin-bottom:
  0in;margin-left:.05in;margin-bottom:.0001pt;text-align:justify'><span
                lang=RU style='font-size:8.0pt;font-family:Arial'><span
                style='mso-spacerun:yes'>                                                            
  </span><span
                style='mso-spacerun:yes'>                             </span>Расшифровка
  подписи</span><span lang=RU style='font-size:10.0pt;font-family:Arial'><o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
    </td>
</tr>
</table>


</rw:foreach>
</div>

</body>

</html>

</rw:report>

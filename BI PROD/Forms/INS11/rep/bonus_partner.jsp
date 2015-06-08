<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*, java.text.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%
    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
	boolean showBeneficiary = false;
%>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bonus_partner_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="BONUS_PARTNER_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_DIRECTOR">
      <select>
      <![CDATA[   select name||' '||first_name||' '||middle_name director from contact
   where
   contact_id = pkg_contact.get_rel_contact_id(pkg_app_param.get_app_param_u('WHOAMI'),'CM')]]>
      </select>
      <displayInfo x="0.24988" y="0.05212" width="0.69995" height="0.19995"/>
      <group name="G_director">
        <displayInfo x="0.06042" y="0.52283" width="1.09998" height="0.43066"
        />
        <dataItem name="director" datatype="vchar2" columnOrder="12"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Director">
          <dataDescriptor
           expression="name || &apos; &apos; || first_name || &apos; &apos; || middle_name"
           descriptiveExpression="DIRECTOR" order="1" width="602"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_NAME">
      <select>
      <![CDATA[SELECT NAME ORG_NAME FROM CONTACT
WHERE
CONTACT_ID = pkg_app_param.get_app_param_u('WHOAMI')
;]]>
      </select>
      <displayInfo x="1.65637" y="0.05200" width="0.69995" height="0.19995"/>
      <group name="G_ORG_NAME">
        <displayInfo x="1.41028" y="0.52283" width="1.25464" height="0.60156"
        />
        <dataItem name="ORG_NAME" datatype="vchar2" columnOrder="13"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Org Name">
          <dataDescriptor expression="NAME" descriptiveExpression="ORG_NAME"
           order="1" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_POLICY">
      <select>
      <![CDATA[SELECT p.policy_id,ph.POLICY_HEADER_ID,
        DECODE (NVL (pol_ser, '@'),
        '@', pol_num,
        pol_ser || '-' || pol_num
        ) pol_ser_num, p.start_date, p.end_date, p.SIGN_DATE, p.ins_amount,
        p.premium
        FROM ven_p_policy p, ven_p_pol_header ph
        WHERE p.policy_id = ph.policy_id and ph.policy_header_id =
        :P_POLICY_HEADER_ID
       ]]>
      </select>
      <displayInfo x="0.66675" y="1.16821" width="0.69995" height="0.21143"/>
      <group name="G_POLICY">
        <displayInfo x="0.14465" y="1.90833" width="1.74426" height="1.79785"
        />
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="p.start_date"
           descriptiveExpression="START_DATE" order="4" width="9"/>
        </dataItem>
        <dataItem name="end_date" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="p.end_date"
           descriptiveExpression="END_DATE" order="5" width="9"/>
        </dataItem>
        <dataItem name="SIGN_DATE" datatype="date" oracleDatatype="date"
         columnOrder="19" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sign Date">
          <dataDescriptor expression="p.SIGN_DATE"
           descriptiveExpression="SIGN_DATE" order="6" width="9"/>
        </dataItem>
        <dataItem name="ins_amount" oracleDatatype="number" columnOrder="20"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="p.ins_amount"
           descriptiveExpression="INS_AMOUNT" order="7" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="premium" oracleDatatype="number" columnOrder="21"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Premium">
          <dataDescriptor expression="p.premium"
           descriptiveExpression="PREMIUM" order="8" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="14"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="p.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="policy_header_id" oracleDatatype="number"
         columnOrder="15" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="ph.POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="pol_ser_num" datatype="vchar2" columnOrder="16"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num">
          <dataDescriptor
           expression="DECODE ( NVL ( pol_ser , &apos;@&apos; ) , &apos;@&apos; , pol_num , pol_ser || &apos;-&apos; || pol_num )"
           descriptiveExpression="POL_SER_NUM" order="3" width="2049"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PAYMENT">
      <select>
      <![CDATA[select policy_id,PAYMENT_TERM_DESC, plan_amount from v_POLICY_PAYMENT]]>
      </select>
      <displayInfo x="3.13538" y="1.39587" width="0.69995" height="0.32983"/>
      <group name="G_PAYMENT">
        <displayInfo x="2.56116" y="2.09583" width="1.84839" height="0.77246"
        />
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="policy_id"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="PAYMENT_TERM_DESC" datatype="vchar2" columnOrder="23"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Payment Term Desc">
          <dataDescriptor expression="PAYMENT_TERM_DESC"
           descriptiveExpression="PAYMENT_TERM_DESC" order="2" width="500"/>
        </dataItem>
        <dataItem name="plan_amount" oracleDatatype="number" columnOrder="24"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Plan Amount">
          <dataDescriptor expression="plan_amount"
           descriptiveExpression="PLAN_AMOUNT" order="3" width="22"
           precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ZASTRAHOVANNI">
      <select>
      <![CDATA[SELECT vas.assured_contact_id, a.as_asset_id, a.p_policy_id, vas.contact_id,
       fn_obj_name (a.ent_id, a.as_asset_id) contact_name, vcp.date_of_birth,
       pkg_contact.get_primary_doc (vas.assured_contact_id) doc_inf,
       pkg_contact.get_address_name
                (pkg_contact.get_primary_address (vas.assured_contact_id)
                ) addr,
       pkg_contact.get_primary_tel (vas.assured_contact_id) tel
  FROM ven_as_asset a, ven_cn_person vcp, ven_as_assured vas
 WHERE a.as_asset_id = vas.as_assured_id
   AND vas.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="3.14587" y="3.03125" width="0.69995" height="0.32983"/>
      <group name="G_ZASTRAHOVANNI">
        <displayInfo x="2.81653" y="3.73120" width="1.35876" height="1.96875"
        />
        <dataItem name="assured_contact_id" oracleDatatype="number"
         columnOrder="30" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Assured Contact Id">
          <dataDescriptor expression="vas.assured_contact_id"
           descriptiveExpression="ASSURED_CONTACT_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="vas.contact_id"
           descriptiveExpression="CONTACT_ID" order="4" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="32" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor
           expression="pkg_contact.get_address_name ( pkg_contact.get_primary_address ( vas.assured_contact_id ) )"
           descriptiveExpression="ADDR" order="8" width="4000"/>
        </dataItem>
        <dataItem name="tel" datatype="vchar2" columnOrder="33" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel">
          <dataDescriptor
           expression="pkg_contact.get_primary_tel ( vas.assured_contact_id )"
           descriptiveExpression="TEL" order="9" width="4000"/>
        </dataItem>
        <dataItem name="p_policy_id" oracleDatatype="number" columnOrder="26"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id">
          <dataDescriptor expression="a.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="as_asset_id" oracleDatatype="number" columnOrder="25"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id">
          <dataDescriptor expression="a.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor
           expression="fn_obj_name ( a.ent_id , a.as_asset_id )"
           descriptiveExpression="CONTACT_NAME" order="5" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth" datatype="date" oracleDatatype="date"
         columnOrder="28" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf" datatype="vchar2" columnOrder="29"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc">
          <xmlSettings xmlTag="DOC_DESC"/>
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( vas.assured_contact_id )"
           descriptiveExpression="DOC_INF" order="7" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_VIGPREOB">
      <select>
      <![CDATA[SELECT rownum, asset.as_asset_id, vas.assured_contact_id contact_id_a,
       ben.contact_id contact_id_b,
       ent.obj_name (vcp.ent_id, vcp.contact_id) NAME, vcp.date_of_birth,
       ben.VALUE dolya
  FROM ven_cn_person vcp,
       ven_as_beneficiary ben,
       ven_as_asset asset,
       ven_as_assured vas
 WHERE asset.as_asset_id = vas.as_assured_id
   AND asset.as_asset_id = ben.as_asset_id
   AND ben.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="5.34375" y="4.31250" width="0.69995" height="0.32983"/>
      <group name="G_VIGPREOB">
        <displayInfo x="4.98315" y="4.92712" width="1.37964" height="1.45605"
        />
        <dataItem name="rownum" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Rownum">
          <dataDescriptor expression="rownum" descriptiveExpression="ROWNUM"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="as_asset_id1" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id1">
          <dataDescriptor expression="asset.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id_a" oracleDatatype="number" columnOrder="35"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id A">
          <dataDescriptor expression="vas.assured_contact_id"
           descriptiveExpression="CONTACT_ID_A" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id_b" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id B">
          <dataDescriptor expression="ben.contact_id"
           descriptiveExpression="CONTACT_ID_B" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="NAME" datatype="vchar2" columnOrder="37" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Name">
          <dataDescriptor
           expression="ent.obj_name ( vcp.ent_id , vcp.contact_id )"
           descriptiveExpression="NAME" order="5" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth1" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth1">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="dolya" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dolya">
          <dataDescriptor expression="ben.VALUE" descriptiveExpression="DOLYA"
           order="7" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_REL">
      <select>
      <![CDATA[ SELECT cnr1.CONTACT_ID_A, cnr1.CONTACT_ID_B, relt.relationship_dsc
                  FROM ven_cn_contact_rel cnr1,
                       ven_t_contact_rel_type relt
                 WHERE cnr1.relationship_type = relt.ID]]>
      </select>
      <displayInfo x="7.23962" y="4.50000" width="1.41663" height="0.47974"/>
      <group name="G_REL">
        <displayInfo x="7.13953" y="5.30432" width="1.52551" height="0.77246"
        />
        <dataItem name="CONTACT_ID_A1" oracleDatatype="number"
         columnOrder="41" width="22" defaultWidth="110000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Contact Id A1">
          <dataDescriptor expression="cnr1.CONTACT_ID_A"
           descriptiveExpression="CONTACT_ID_A" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="CONTACT_ID_B1" oracleDatatype="number"
         columnOrder="42" width="22" defaultWidth="110000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Contact Id B1">
          <dataDescriptor expression="cnr1.CONTACT_ID_B"
           descriptiveExpression="CONTACT_ID_B" order="2" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="relationship_dsc" datatype="vchar2" columnOrder="43"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Relationship Dsc">
          <dataDescriptor expression="relt.relationship_dsc"
           descriptiveExpression="RELATIONSHIP_DSC" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_RULE_DATE">
      <select>
      <![CDATA[SELECT ph.policy_header_id, prv.start_date
  FROM p_pol_header ph, t_product pr, t_product_version prv
 WHERE ph.product_id = pr.product_id
   AND pr.product_id = prv.product_id
   AND prv.version_nr = (SELECT MAX (prv1.version_nr)
                           FROM t_product_version prv1
                          WHERE prv1.product_id = prv.product_id)]]>
      </select>
      <displayInfo x="0.68359" y="4.07288" width="0.69995" height="0.32983"/>
      <group name="G_RULE_DATE">
        <displayInfo x="0.25000" y="4.80957" width="1.56714" height="0.60156"
        />
        <dataItem name="policy_header_id1" oracleDatatype="number"
         columnOrder="44" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id1">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="start_date1" datatype="date" oracleDatatype="date"
         columnOrder="45" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date1">
          <dataDescriptor expression="prv.start_date"
           descriptiveExpression="START_DATE" order="2" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_PAYMENT" childColumn="policy_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_ZASTRAHOVANNI" childColumn="p_policy_id" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_VIGPREOB" parentColumn="contact_id_a"
     childQuery="Q_REL" childColumn="CONTACT_ID_A1" condition="eq"
     sqlClause="where"/>
    <link name="L_4" parentGroup="G_VIGPREOB" parentColumn="contact_id_b"
     childQuery="Q_REL" childColumn="CONTACT_ID_B1" condition="eq"
     sqlClause="where"/>
    <link name="L_5" parentGroup="G_ZASTRAHOVANNI" parentColumn="as_asset_id"
     childQuery="Q_VIGPREOB" childColumn="as_asset_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_6" parentGroup="G_POLICY" parentColumn="policy_header_id"
     childQuery="Q_RULE_DATE" childColumn="policy_header_id1" condition="eq"
     sqlClause="where"/>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">
<rw:foreach id="gpolicy" src="G_POLICY">
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="Бонус-партнёр1.files/filelist.xml">
<title>ДОГОВОР НАКОПИТЕЛЬНОГО СТРАХОВАНИЯ ЖИЗНИ №  <rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field </rw:field> </title>
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 5 6 2 2 2 3 2 4;
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
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
h1
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:225.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:0in;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	mso-list:l1 level2 lfo2;
	tab-stops:list 243.0pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	text-transform:uppercase;
	mso-font-kerning:0pt;
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
h3
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:3.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:13.0pt;
	font-family:Arial;
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
p.MsoNormalIndent, li.MsoNormalIndent, div.MsoNormalIndent
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:28.35pt;
	mso-pagination:widow-orphan;
	mso-list:l1 level5 lfo2;
	tab-stops:list 60.55pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-GB;
	mso-fareast-language:RU;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoListNumber, li.MsoListNumber, div.MsoListNumber
	{margin-top:12.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:0in;
	mso-pagination:widow-orphan;
	mso-list:l1 level1 lfo2;
	tab-stops:14.2pt list .25in;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	text-transform:uppercase;
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:6.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:6.0pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:-15.55pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	mso-list:l1 level3 lfo2;
	tab-stops:14.2pt list 63.0pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-GB;
	mso-fareast-language:RU;}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:25.65pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:28.35pt;
	mso-pagination:widow-orphan;
	mso-list:l1 level4 lfo2;
	tab-stops:14.2pt list 1.25in;
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
@page Section1
	{size:8.5in 11.0in;
	margin:56.7pt 42.5pt 56.7pt 85.05pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:-120;
	mso-list-type:simple;
	mso-list-template-ids:786705492;}
@list l0:level1
	{mso-level-style-link:"Нумерованный список";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l1
	{mso-list-id:1351108930;
	mso-list-template-ids:865734612;}
@list l1:level1
	{mso-level-number-format:none;
	mso-level-style-link:"Нумерованный список";
	mso-level-text:"";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:0in;
	text-indent:0in;}
@list l1:level2
	{mso-level-style-link:"Заголовок 1";
	mso-level-text:"%1%2\.";
	mso-level-tab-stop:243.0pt;
	mso-level-number-position:left;
	margin-left:225.0pt;
	text-indent:0in;}
@list l1:level3
	{mso-level-style-link:"Основной текст с отступом";
	mso-level-text:"%1%2\.%3\.";
	mso-level-tab-stop:63.0pt;
	mso-level-number-position:left;
	margin-left:-15.55pt;
	text-indent:42.55pt;}
@list l1:level4
	{mso-level-style-link:Обычный1;
	mso-level-text:"%1%2\.%3\.%4\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:25.65pt;
	text-indent:28.35pt;
	mso-ansi-font-size:9.0pt;
	mso-bidi-font-size:9.0pt;
	font-family:Arial;}
@list l1:level5
	{mso-level-number-format:none;
	mso-level-style-link:"Обычный отступ";
	mso-level-text:%1;
	mso-level-tab-stop:60.55pt;
	mso-level-number-position:left;
	margin-left:14.2pt;
	text-indent:28.35pt;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6";
	mso-level-tab-stop:.8in;
	mso-level-number-position:left;
	margin-left:.8in;
	text-indent:-.8in;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7";
	mso-level-tab-stop:.9in;
	mso-level-number-position:left;
	margin-left:.9in;
	text-indent:-.9in;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9";
	mso-level-tab-stop:1.1in;
	mso-level-number-position:left;
	margin-left:1.1in;
	text-indent:-1.1in;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>

</head>

<body lang=EN-US style='tab-interval:.5in'>

<div class=Section1>
<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=684
 style='width:513.35pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=684 valign=top style='width:513.35pt;padding:0in 5.4pt 0in 5.4pt'>
  <h1 style='margin-top:6.0pt;margin-right:0in;margin-bottom:0in;margin-left:
  0in;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><a
  name="_Toc99349889"><span lang=RU style='font-size:9.0pt;font-family:Arial;
  font-style:normal'>договор накопительного страхования жизни № </span></a><span
  style='mso-bookmark:_Toc99349889'><u><span lang=RU style='font-size:9.0pt;
  font-family:Arial'>
      <rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field </rw:field>
      <o:p></o:p></span></u></span></h1>
  <h1 style='margin-top:6.0pt;margin-right:0in;margin-bottom:0in;margin-left:
  0in;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><span
  style='mso-bookmark:_Toc99349889'><span lang=RU style='font-size:9.0pt;
  font-family:Arial;font-style:normal'>от </span></span><span style='mso-bookmark:
  _Toc99349889'><u><span lang=RU style='font-size:9.0pt;font-family:Arial'>
      <rw:field id="F_SIGN_DATE" src="SIGN_DATE" formatMask="dd.MM.yyyy"> &Field</rw:field>
  </span></u></span><span
  style='mso-bookmark:_Toc99349889'><span lang=RU style='font-size:9.0pt;
  font-family:Arial;font-style:normal'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></span></h1>
  <h1 style='margin-top:6.0pt;margin-right:0in;margin-bottom:0in;margin-left:
  0in;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><span
  style='mso-bookmark:_Toc99349889'><span lang=RU style='font-size:9.0pt;
  font-family:Arial;font-style:normal'>Программа страхования жизни «БОНУС –
  ПАРТНЕР»<o:p></o:p></span></span></h1>
  <span style='mso-bookmark:_Toc99349889'></span>
  <p class=MsoNormal style='text-align:justify'><span style='mso-bookmark:_Toc99349889'><span
  lang=RU style='font-size:8.0pt;font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></span></p>
  </td>
  <span style='mso-bookmark:_Toc99349889'></span>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=684 valign=top style='width:513.35pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:Arial;letter-spacing:-.1pt'><span
  style='mso-spacerun:yes'>   </span>г. Москва<span
  style='mso-spacerun:yes'>                                                                                                                                      
  </span><span style='mso-spacerun:yes'>                             </span><i
  style='mso-bidi-font-style:normal'><u>
    <%=sdf.format(new java.util.Date())%>
      <o:p></o:p></u></i></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  5.0pt;font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  5.0pt;font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:10.0pt;font-family:Arial'>1.</span></b><span
  lang=RU style='font-size:10.0pt;font-family:Arial;letter-spacing:-.1pt'> <i
  style='mso-bidi-font-style:normal'><u>
      <rw:foreach id="gorgname" src="G_ORG_NAME">
          <rw:field id="F_ORG_NAME" src="ORG_NAME"> &Field</rw:field>
      </rw:foreach>
  </u></i>, именуемое в дальнейшем
  «Страховщик», в лице Управляющего директора <i style='mso-bidi-font-style:
  normal'><u>
      <rw:foreach id="gdirr" src="G_DIRECTOR">
          <rw:field id="F_DIRECTOR" src="DIRECTOR"> &Field</rw:field>
      </rw:foreach>
  </u></i>., действующего на основании Доверенности № ________________
  от __________, с одной стороны, и<span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <rw:foreach id="gz" src="G_ZASTRAHOVANNI">
  <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:
  normal'><u><span lang=RU style='font-size:10.0pt;font-family:Arial;
  letter-spacing:-.1pt'>
      <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field</rw:field>
      <o:p></o:p></span></u></i></p>

      <p class=MsoNormal style='margin-right:.05in'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Данные документа, удостоверяющего личность (серия,
  номер, кем и когда выдан)<span style='mso-spacerun:yes'>  </span><i
        style='mso-bidi-font-style:normal'><u><span style='mso-tab-count:1'>     </span>
    <rw:field id="F_DOC_INF" src="DOC_INF"> &Field</rw:field>
    <o:p></o:p>
</u></i></span></p>
  <p class=MsoNormal style='margin-right:.05in'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Дата рождения <i style='mso-bidi-font-style:normal'><u>
    <rw:field id="F_DATE_OF_BIRTH" src="DATE_OF_BIRTH"> &Field</rw:field>
</u></i><span
        style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:.05in'><span lang=RU style='font-size:
  10.0pt;font-family:Arial'>Адрес <i style='mso-bidi-font-style:normal'><u><span
        style='mso-tab-count:1'>  </span>
    <rw:field id="F_ADDR" src="ADDR"> &Field</rw:field>
    <o:p></o:p>
</u></i></span></p>
  </rw:foreach>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  7.0pt;font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:Arial;letter-spacing:-.1pt'>именуемы<span class=GramE>й(</span>-<span
  class=SpellE>ая</span>) в дальнейшем Страхователь, с другой стороны,
  заключили настоящий Договор (далее Договор страхования).<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>2.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Застрахованным по настоящему договору является
  Страхователь.<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>3.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Страховыми случаями признаются следующие события, при
  условии, что они произошли в период действия договора страхования, кроме
  случаев, предусмотренных п. 4.2.-4.4.Общих условий страхования от <i
  style='mso-bidi-font-style:normal'><u>
      <rw:foreach id="grd" src="G_RULE_DATE">
          <rw:field id="F_START_DATE1" src="START_DATE1"> &Field</rw:field>
      </rw:foreach>
  </u></i>(далее «Общие условия»):<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;margin-right:0in;margin-bottom:
  0in;margin-left:.25in;margin-bottom:.0001pt;text-indent:0in;tab-stops:27.0pt'><a
  name="z_3_1_2"><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:10.0pt;font-family:Arial'>3.1</span></b></a><span
  style='mso-bookmark:z_3_1_2'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> смерть </span></span><span class=GramE><span lang=RU
  style='font-size:10.0pt;font-family:Arial'>Застрахованного</span></span><span
  lang=RU style='font-size:10.0pt;font-family:Arial'> по любой причине;<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;margin-right:0in;margin-bottom:
  0in;margin-left:.25in;margin-bottom:.0001pt;text-indent:0in;tab-stops:27.0pt'><a
  name="_Ref60118614"></a><a name="z_3_1_1"><span style='mso-bookmark:_Ref60118614'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>3.2</span></b></span></a><span style='mso-bookmark:z_3_1_1'><span
  style='mso-bookmark:_Ref60118614'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> дожитие Застрахованного</span></span></span><span
  style='mso-bookmark:_Ref60118614'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> до даты окончания Договора страхования</span></span><span
  lang=RU style='font-size:10.0pt;font-family:Arial'>.<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;margin-right:0in;margin-bottom:
  0in;margin-left:.25in;margin-bottom:.0001pt;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>3.3</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Период оплаты страховых взносов равен сроку страхования.<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial;mso-bidi-font-style:italic'>4.</span></b><span lang=RU
  style='font-size:10.0pt;font-family:Arial;mso-bidi-font-style:italic'>
  Страховые взносы<span style='mso-spacerun:yes'>  </span>
      <rw:foreach id="gpayment" src="G_PAYMENT">
          <rw:field id="F_PLAN_AMOUNT" src="PLAN_AMOUNT"> &Field</rw:field>
          рублей (
          <rw:field id="F_PAYMENT_TERM_DESC" src="PAYMENT_TERM_DESC"> &Field</rw:field>
          )
      </rw:foreach>
      <o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:-9.0pt 14.2pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>5.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Общая страховая сумма по рискам, указанным <span
  class=GramE>в</span> п.3.1. и 3.2. <span class=GramE>настоящего</span>
  Договора:
      <rw:field id="F_INS_AMOUNT" src="INS_AMOUNT" nullValue="0"> &Field</rw:field>
      <o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:-9.0pt 14.2pt'><i
  style='mso-bidi-font-style:normal'><u><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>
      <o:p></o:p></span></u></i></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>6.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Период страхования:<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>6.1</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>. Договор страхования заключается сроком на 5 (пять) лет с
  <i style='mso-bidi-font-style:normal'><u>
      <rw:field id="F_START_DATE" src="START_DATE" formatMask="dd.MM.yyyy"> &Field</rw:field>
  </u></i> по <i style='mso-bidi-font-style:
  normal'><u>
      <rw:field id="F_END_DATE" src="END_DATE" formatMask="dd.MM.yyyy"> &Field</rw:field>
  </u></i>. Договор вступает в силу после оплаты
  Страхователем<span style='mso-spacerun:yes'>  </span>первого страхового
  взноса в соответствие с п. 4 настоящего Договора.<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>7.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> Страховые выплаты.<span style='mso-spacerun:yes'> 
  </span><o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>7.1</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>. При наступлении страховых случаев, предусмотренных
  п.3.1. или п. 3.2. настоящего Договора, выплачивается страховая сумма,
  указанная <span class=GramE>в</span> п.5. <span class=GramE>настоящего</span>
  Договора. <o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>8.</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'> При досрочном расторжении Договора страхования
  Страхователю выплачивается выкупная сумма <span class=GramE>в размере
  сформированного на момент расторжения резерва за вычетом задолженности
  Страхователя перед Страховщиком по уплате</span> страховых взносов.<o:p></o:p></span></p>
  <p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>9</span></b><span lang=RU style='font-size:10.0pt;
  font-family:Arial'>. <span class=SpellE>Выгодоприобретатели</span> на случай
  смерти <span class=GramE>Застрахованного</span>:<o:p></o:p></span></p>
  <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='margin-right:-225.0pt;text-align:center'><span
lang=RU style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:
Arial'><o:p>&nbsp;</o:p></span></p>
<rw:foreach id="gvigodopreob_rowcount" src="G_VIGPREOB" endRow="1">
    <%showBeneficiary = true;%>
</rw:foreach>
<%if (showBeneficiary) {%>
<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=684
 style='width:513.35pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=32 style='width:23.75pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>№ <span class=SpellE><span class=GramE>п</span></span>/<span
  class=SpellE>п</span><o:p></o:p></span></p>
  </td>
  <td width=239 style='width:179.25pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>Фамилия, Имя, Отчество<o:p></o:p></span></p>
  </td>
  <td width=137 style='width:102.6pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyText align=left style='margin-left:.3in;text-align:left;
  text-indent:0in;tab-stops:14.2pt 27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>Дата рождения<o:p></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>Степень родства<o:p></o:p></span></p>
  </td>
  <td width=144 style='width:1.5in;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>Процент от страховой суммы<o:p></o:p></span></p>
  </td>
 </tr>
    <rw:foreach id="gvigodopreob" src="G_VIGPREOB">
        <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
            <td width=32 style='width:23.75pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
                <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>
                    <rw:field id="F_ROWNUM" src="ROWNUM"> &Field</rw:field>
                </o:p></span></p>
            </td>
            <td width=239 style='width:179.25pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
                <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>
                    <rw:field id="F_NAME" src="NAME"> &Field</rw:field>
                </o:p></span></p>
            </td>
            <td width=137 style='width:102.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
                <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>
                    <rw:field id="F_DATE_OF_BIRTH1" src="DATE_OF_BIRTH1" formatMask="dd.MM.yyyy"> &Field</rw:field>
                </o:p></span></p>
            </td>
            <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
                <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>
                    <rw:foreach id="grel" src="G_REL">
                        <rw:field id="F_RELATIONSHIP_DSC" src="RELATIONSHIP_DSC" nullValue="-"> &Field</rw:field>
                    </rw:foreach>
                </o:p></span></p>
            </td>
            <td width=144 style='width:1.5in;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
                <p class=MsoBodyText align=left style='margin-top:0in;text-align:left;
  text-indent:0in;tab-stops:27.0pt'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'><o:p>
                    <rw:field id="F_DOLYA" src="DOLYA" nullValue="0"> &Field</rw:field> %
                </o:p></span></p>
            </td>
        </tr>
    </rw:foreach>
</table>
<%} else{%>
<p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'>
  <span class=SpellE>По законодательству РФ</span></p>
<%}%>
</rw:foreach>
<p class=MsoNormal align=center style='margin-right:-225.0pt;text-align:center'><span
style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='margin-right:-225.0pt;text-align:center'><span
style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'>10.</span></b><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'> Во всем остальном, что не урегулировано настоящим
Договором, Стороны руководствуются Общими условиями. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'>11.</span></b><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'> Общие условия являются неотъемлемой частью
настоящего Договора страхования. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0in;text-indent:0in;tab-stops:27.0pt'><b
style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'>12.</span></b><span lang=RU style='font-size:10.0pt;
font-family:"Arial Narrow"'> Подписи сторон. Стороны признают <span
class=SpellE>факсимильно</span> воспроизведенную подпись Страховщика подлинной.<o:p></o:p></span></p>

<p class=MsoNormal align=center style='margin-right:-225.0pt;text-align:center'><span
lang=RU style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:
Arial'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=684
 style='width:513.35pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:52.2pt'>
  <td width=288 valign=top style='width:3.0in;border:none;padding:0in 5.4pt 0in 5.4pt;
  height:52.2pt'>
  <div style='mso-element:para-border-div;border:none;border-bottom:solid windowtext 1.0pt;
  padding:0in 0in 1.0pt 0in;margin-left:-.3pt;margin-right:0in'>
  <p class=MsoNormal align=center style='text-align:center;border:none;
  mso-border-bottom-alt:solid windowtext 1.0pt;padding:0in;mso-padding-alt:
  0in 0in 1.0pt 0in'><i><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal align=center style='text-align:center;border:none;
  mso-border-bottom-alt:solid windowtext 1.0pt;padding:0in;mso-padding-alt:
  0in 0in 1.0pt 0in'><i><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal align=center style='text-align:center;border:none;
  mso-border-bottom-alt:solid windowtext 1.0pt;padding:0in;mso-padding-alt:
  0in 0in 1.0pt 0in'><i><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  </div>
  <h3 style='margin:0in;margin-bottom:.0001pt'><span lang=RU style='font-size:
  8.0pt;font-weight:normal;mso-bidi-font-weight:bold'>Страховщик<o:p></o:p></span></h3>
  <p class=MsoNormal><span lang=RU><span
  style='mso-spacerun:yes'>                      </span></span><span lang=RU
  style='font-size:10.0pt;font-family:Arial'>М.П.<span style='color:silver'><o:p></o:p></span></span></p>
  </td>
  <td width=108 valign=top style='width:81.35pt;border:none;padding:0in 5.4pt 0in 5.4pt;
  height:52.2pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span lang=RU style='font-size:8.0pt;
  font-family:Arial'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=288 valign=top style='width:3.0in;border:none;padding:0in 5.4pt 0in 5.4pt;
  height:52.2pt'>
  <div style='mso-element:para-border-div;border:none;border-bottom:solid windowtext 1.0pt;
  padding:0in 0in 1.0pt 0in'>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.0pt;padding:0in;mso-padding-alt:0in 0in 1.0pt 0in'><i><span
  lang=RU style='font-size:7.0pt;font-family:Arial'>Общие условия страхования <span
  class=GramE>от</span> «….<span style='mso-spacerun:yes'>  </span>получил.<o:p></o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.0pt;padding:0in;mso-padding-alt:0in 0in 1.0pt 0in'><i><span
  lang=RU style='font-size:7.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.0pt;padding:0in;mso-padding-alt:0in 0in 1.0pt 0in'><i><span
  lang=RU style='font-size:7.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.0pt;padding:0in;mso-padding-alt:0in 0in 1.0pt 0in'><i><span
  lang=RU style='font-size:7.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  </div>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span lang=RU style='font-size:8.0pt;
  font-family:Arial'>Страхователь</span></i></b><b style='mso-bidi-font-weight:
  normal'><i><span lang=RU style='font-size:6.0pt;mso-bidi-font-size:8.0pt;
  font-family:Arial'><o:p></o:p></span></i></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span lang=RU style='font-size:6.0pt;
  mso-bidi-font-size:8.0pt;font-family:Arial'>(</span></i></b><i><span lang=RU
  style='font-size:6.0pt;mso-bidi-font-size:8.0pt;font-family:Arial;mso-bidi-font-weight:
  bold'>подпись, фамилия, инициалы<b>)</b></span></i><i><span lang=RU
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial'><o:p></o:p></span></i></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-right:-225.0pt'><span style='font-size:8.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:-225.0pt;margin-bottom:
0in;margin-left:351.0pt;margin-bottom:.0001pt;text-align:justify'><i
style='mso-bidi-font-style:normal'><u><span style='font-size:8.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-ansi-language:EN-US'>
    <%=sdf.format(new java.util.Date())%>
    <o:p></o:p></span></u></i></p>

<p class=MsoNormal style='margin-right:-225.0pt'><span lang=RU><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

</rw:report>

<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp"  session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="azbuka_dogovor_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AZBUKA_DOGOVOR_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="XML_HTTPS" datatype="character"
     pluginClass="oracle.reports.plugin.datasource.xmlpds.XMLDataSourceFactory"
     width="255" defaultWidth="0" defaultHeight="0" display="no"/>
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
      <displayInfo x="2.72925" y="1.54211" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="2.24890" y="1.99170" width="1.68176" height="1.62695"
        />
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="13"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="p.policy_id"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="POLICY_HEADER_ID" oracleDatatype="number"
         columnOrder="14" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="ph.POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="pol_ser_num" datatype="vchar2" columnOrder="15"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num">
          <dataDescriptor
           expression="DECODE ( NVL ( pol_ser , &apos;@&apos; ) , &apos;@&apos; , pol_num , pol_ser || &apos;-&apos; || pol_num )"
           descriptiveExpression="POL_SER_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="16" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="p.start_date"
           descriptiveExpression="START_DATE" order="4" width="9"/>
        </dataItem>
        <dataItem name="end_date" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="p.end_date"
           descriptiveExpression="END_DATE" order="5" width="9"/>
        </dataItem>
        <dataItem name="SIGN_DATE" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sign Date">
          <dataDescriptor expression="p.SIGN_DATE"
           descriptiveExpression="SIGN_DATE" order="6" width="9"/>
        </dataItem>
        <dataItem name="ins_amount" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="p.ins_amount"
           descriptiveExpression="INS_AMOUNT" order="7" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="premium" oracleDatatype="number" columnOrder="20"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Premium">
          <dataDescriptor expression="p.premium"
           descriptiveExpression="PREMIUM" order="8" width="22" scale="2"
           precision="11"/>
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
      <displayInfo x="0.46875" y="2.35437" width="0.69995" height="0.32983"/>
      <group name="G_RULE_DATE">
        <displayInfo x="0.12366" y="2.87720" width="1.41089" height="0.60156"
        />
        <dataItem name="policy_header_id1" oracleDatatype="number"
         columnOrder="22" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id1">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="START_DATE1" datatype="date" oracleDatatype="date"
         columnOrder="21" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date1">
          <dataDescriptor expression="prv.start_date"
           descriptiveExpression="START_DATE" order="2" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DIRECTOR">
      <select>
      <![CDATA[   select name||' '||first_name||' '||middle_name director from contact
   where
   contact_id = pkg_contact.get_rel_contact_id(pkg_app_param.get_app_param_u('WHOAMI'),'CM')]]>
      </select>
      <displayInfo x="0.41663" y="0.14587" width="0.69995" height="0.19995"/>
      <group name="G_director">
        <displayInfo x="0.21667" y="0.66870" width="1.09998" height="0.43066"
        />
        <dataItem name="director" datatype="vchar2" columnOrder="23"
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
      <![CDATA[SELECT NAME ORG_NAME, pkg_contact.get_essential(CONTACT_ID)   ORG_DESC FROM CONTACT
WHERE
CONTACT_ID = pkg_app_param.get_app_param_u('WHOAMI')
;

]]>
      </select>
      <displayInfo x="1.84375" y="0.14587" width="0.69995" height="0.19995"/>
      <group name="G_ORG_NAME">
        <displayInfo x="1.56628" y="0.68958" width="1.25464" height="0.60156"
        />
        <dataItem name="ORG_DESC" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Org Desc">
          <dataDescriptor
           expression="pkg_contact.get_essential ( CONTACT_ID )"
           descriptiveExpression="ORG_DESC" order="2" width="4000"/>
        </dataItem>
        <dataItem name="ORG_NAME" datatype="vchar2" columnOrder="24"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Org Name">
          <dataDescriptor expression="NAME" descriptiveExpression="ORG_NAME"
           order="1" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AZ">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt,
         SUM (NVL (asset.ins_amount, 0)) sum_am,
         SUM (asset.ins_premium) sum_prem
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND progr.description LIKE '%"��"%'
GROUP BY asset.p_policy_id;]]>
      </select>
      <displayInfo x="5.19788" y="0.11450" width="0.69995" height="0.32983"/>
      <group name="G_AZ">
        <displayInfo x="4.96240" y="0.78320" width="1.17126" height="0.94336"
        />
        <dataItem name="p_policy_id" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt" oracleDatatype="number" columnOrder="26"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_am" oracleDatatype="number" columnOrder="27"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Am">
          <dataDescriptor expression="SUM ( NVL ( asset.ins_amount , 0 ) )"
           descriptiveExpression="SUM_AM" order="3" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_prem" oracleDatatype="number" columnOrder="28"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Prem">
          <dataDescriptor expression="SUM ( asset.ins_premium )"
           descriptiveExpression="SUM_PREM" order="4" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_BUKI">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt,
         SUM (NVL (asset.ins_amount, 0)) sum_am,
         SUM (asset.ins_premium) sum_prem
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND progr.description LIKE '%"����"%'
GROUP BY asset.p_policy_id;]]>
      </select>
      <displayInfo x="5.23950" y="1.78125" width="0.69995" height="0.32983"/>
      <group name="G_BUKI">
        <displayInfo x="4.95178" y="2.48120" width="1.27551" height="0.94336"
        />
        <dataItem name="p_policy_id1" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id1">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt1" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt1">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_am1" oracleDatatype="number" columnOrder="32"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Am1">
          <dataDescriptor expression="SUM ( NVL ( asset.ins_amount , 0 ) )"
           descriptiveExpression="SUM_AM" order="3" width="22" precision="38"
          />
        </dataItem>
        <dataItem name="sum_prem1" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Prem1">
          <dataDescriptor expression="SUM ( asset.ins_premium )"
           descriptiveExpression="SUM_PREM" order="4" width="22"
           precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_VEDI">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt,
         SUM (NVL (asset.ins_amount, 0)) sum_am,
         SUM (asset.ins_premium) sum_prem
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND progr.description LIKE '%"����"%'
GROUP BY asset.p_policy_id;]]>
      </select>
      <displayInfo x="5.28125" y="3.54163" width="0.69995" height="0.32983"/>
      <group name="G_VEDI">
        <displayInfo x="4.99353" y="4.24158" width="1.27551" height="0.94336"
        />
        <dataItem name="p_policy_id2" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id2">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt2" oracleDatatype="number" columnOrder="35"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt2">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_am2" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Am2">
          <dataDescriptor expression="SUM ( NVL ( asset.ins_amount , 0 ) )"
           descriptiveExpression="SUM_AM" order="3" width="22" precision="38"
          />
        </dataItem>
        <dataItem name="sum_prem2" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Prem2">
          <dataDescriptor expression="SUM ( asset.ins_premium )"
           descriptiveExpression="SUM_PREM" order="4" width="22"
           precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_GLAGOL">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt,
         SUM (NVL (asset.ins_amount, 0)) sum_am,
         SUM (asset.ins_premium) sum_prem
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND progr.description LIKE '%"�������"%'
GROUP BY asset.p_policy_id;]]>
      </select>
      <displayInfo x="5.36462" y="5.38525" width="0.69995" height="0.32983"/>
      <group name="G_GLAGOL">
        <displayInfo x="5.07690" y="6.08521" width="1.27551" height="0.94336"
        />
        <dataItem name="p_policy_id3" oracleDatatype="number" columnOrder="38"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id3">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt3" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt3">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_am3" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Am3">
          <dataDescriptor expression="SUM ( NVL ( asset.ins_amount , 0 ) )"
           descriptiveExpression="SUM_AM" order="3" width="22" precision="38"
          />
        </dataItem>
        <dataItem name="sum_prem3" oracleDatatype="number" columnOrder="41"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Prem3">
          <dataDescriptor expression="SUM ( asset.ins_premium )"
           descriptiveExpression="SUM_PREM" order="4" width="22"
           precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOBRO">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt,
         SUM (NVL (asset.ins_amount, 0)) sum_am,
         SUM (asset.ins_premium) sum_prem
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND progr.description LIKE '%"�����"%'
GROUP BY asset.p_policy_id;]]>
      </select>
      <displayInfo x="5.32288" y="7.12500" width="0.69995" height="0.32983"/>
      <group name="G_DOBRO">
        <displayInfo x="5.03516" y="7.82495" width="1.27551" height="0.94336"
        />
        <dataItem name="p_policy_id4" oracleDatatype="number" columnOrder="42"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id4">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt4" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt4">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sum_am4" oracleDatatype="number" columnOrder="44"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Am4">
          <dataDescriptor expression="SUM ( NVL ( asset.ins_amount , 0 ) )"
           descriptiveExpression="SUM_AM" order="3" width="22" precision="38"
          />
        </dataItem>
        <dataItem name="sum_prem4" oracleDatatype="number" columnOrder="45"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Prem4">
          <dataDescriptor expression="SUM ( asset.ins_premium )"
           descriptiveExpression="SUM_PREM" order="4" width="22"
           precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STR">
      <select>
      <![CDATA[SELECT iss.policy_id, contact_name, pkg_contact.get_essential(iss.contact_id) STR_INF
        FROM v_pol_issuer iss]]>
      </select>
      <displayInfo x="2.73962" y="4.47913" width="0.69995" height="0.32983"/>
      <group name="G_STR">
        <displayInfo x="2.51440" y="5.17908" width="1.15051" height="0.77246"
        />
        <dataItem name="contact_name" datatype="vchar2" columnOrder="48"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="contact_name"
           descriptiveExpression="CONTACT_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="46"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="STR_INF" datatype="vchar2" columnOrder="47"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Str Inf">
          <dataDescriptor
           expression="pkg_contact.get_essential ( iss.contact_id )"
           descriptiveExpression="STR_INF" order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_KOLVO_TOT">
      <select>
      <![CDATA[SELECT   asset.p_policy_id, COUNT (1) cnt
    FROM ven_as_asset asset,
         ven_p_cover cover,
         ven_t_prod_line_option grisk,
         ven_t_product_line prodl,
         ven_t_lob_line progr
   WHERE asset.as_asset_id = cover.as_asset_id
     AND cover.t_prod_line_option_id = grisk.ID
     AND grisk.product_line_id = prodl.ID
     AND prodl.t_lob_line_id = progr.t_lob_line_id
     AND
            (progr.description LIKE '%"��"%' or
             progr.description LIKE '%"����"%' or
             progr.description LIKE '%"����"%' or
             progr.description LIKE '%"�������"%' or
             progr.description LIKE '%"�����"%' )
GROUP BY asset.p_policy_id;
]]>
      </select>
      <displayInfo x="0.48962" y="4.73962" width="0.69995" height="0.32983"/>
      <group name="G_KOLVO_TOT">
        <displayInfo x="0.20190" y="5.43958" width="1.27551" height="0.60156"
        />
        <dataItem name="p_policy_id5" oracleDatatype="number" columnOrder="49"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id5">
          <dataDescriptor expression="asset.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="cnt5" oracleDatatype="number" columnOrder="50"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt5">
          <dataDescriptor expression="COUNT ( 1 )" descriptiveExpression="CNT"
           order="2" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="POLICY_HEADER_ID"
     childQuery="Q_RULE_DATE" childColumn="policy_header_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_AZ" childColumn="p_policy_id" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_BUKI" childColumn="p_policy_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_4" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_VEDI" childColumn="p_policy_id2" condition="eq"
     sqlClause="where"/>
    <link name="L_5" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_GLAGOL" childColumn="p_policy_id3" condition="eq"
     sqlClause="where"/>
    <link name="L_6" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_DOBRO" childColumn="p_policy_id4" condition="eq"
     sqlClause="where"/>
    <link name="L_7" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STR" childColumn="policy_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_8" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_KOLVO_TOT" childColumn="p_policy_id5" condition="eq"
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
<link rel=File-List href="azbuka_dogovor.files/filelist.xml">
<title>

    ���������� �2</title>
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
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:9.0pt 42.55pt 0in 48.2pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:1317489869;
	mso-list-type:hybrid;
	mso-list-template-ids:1856775182 68747279 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l0:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level2
	{mso-level-start-at:2;
	mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.25in;}
@list l0:level3
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.5in;}
@list l0:level4
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.5in;}
@list l0:level5
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.5in;}
@list l0:level6
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-.75in;}
@list l0:level7
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-.75in;}
@list l0:level8
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.0in;}
@list l0:level9
	{mso-level-legal-format:yes;
	mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.0in;}
@list l1
	{mso-list-id:1796094649;
	mso-list-template-ids:469421942;}
@list l1:level1
	{mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l1:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:.25in;
	mso-level-number-position:left;
	margin-left:.25in;
	text-indent:-.25in;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>

</head>

<body lang=EN-US style='tab-interval:.5in'>

<div class=Section1>
<rw:foreach id="gpolicy" src="G_POLICY">
<p class=MsoNormal style='text-align:justify'><span lang=RU><span
        style='mso-spacerun:yes'>������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
</span></span><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=672
       style='width:7.0in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal align=right style='text-align:right'><span lang=RU>����������
  �2</span></p>

            <p class=MsoNormal align=right style='text-align:right'><span lang=RU>�
  ������� �� ____________<span style='mso-spacerun:yes'>� </span>� _______________</span></p>

            <p class=MsoNormal align=center style='text-align:center'><b
                    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:11.0pt;
  font-family:"Arial Narrow"'>������� ���������� ����������� ����� �
  ����������� �� ���������� ������� � ��������.<o:p></o:p></span></b></p>
            <p class=MsoNormal><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>�����
  �������� �����������:
                <rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field </rw:field>
                ��
                <rw:field id="F_SIGN_DATE" src="SIGN_DATE" formatMask="dd.MM.yyyy"> &Field </rw:field>
                <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>��������� ������� ����������� �������� ��
  ��������� ������ ������� ���������� ����������� ����� � ����������� ��
  ���������� ������� � �������� ������� ������� ��
                <rw:foreach id="grd" src="G_RULE_DATE">
                    <rw:field id="F_START_DATE1" src="START_DATE1" formatMask="dd.MM.yyyy"> &Field </rw:field>
                </rw:foreach>
                , <span class=GramE>�����</span>:<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:
  normal'><u><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>
                <rw:foreach id="gon" src="G_ORG_NAME">
                    <rw:field id="F_ORG_NAME" src="ORG_NAME"> &Field </rw:field>
                </rw:foreach>
            </span></u></i><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'> (����� ��
  �������� �����������) � ���� ������������ ��������� <i style='mso-bidi-font-style:
  normal'><u>
                <rw:foreach id="gd" src="G_DIRECTOR">
                    <rw:field id="F_DIRECTOR" src="DIRECTOR"> &Field </rw:field>
                </rw:foreach>
            </u></i> ������������ �� ��������� ������������ <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:left'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>�<i style='mso-bidi-font-style:normal'><u><span
                    style='mso-tab-count:2'>��������������������������� </span></u></i> �� <i
                    style='mso-bidi-font-style:normal'><u><span
                    style='mso-tab-count:2'>������������������������� </span></u></i>,<span
                    style='mso-spacerun:yes'>� </span>� <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'><span style='mso-spacerun:yes'>�</span><i
                    style='mso-bidi-font-style:normal'><u>
                <rw:foreach id="gstr" src="G_STR">
                    <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field </rw:field>
                </rw:foreach>
            </u></i> <span
                    style='mso-spacerun:yes'>�</span>(����� �� �������� ������������),<span
                    style='mso-spacerun:yes'>����� </span><o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:left;'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>��� ������������ <u><span
  style='mso-tab-count:11'>������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� </span>
  <o:p></o:p></u></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'><span
                    style='mso-spacerun:yes'>�������������������������������������������� </span><span
                    style='mso-spacerun:yes'>����������������������������������������������</span>(�������
  �������������� ������������ �����������))<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>���������� ����������� � �����������<span
                    class=GramE> <u><span style='mso-tab-count:2'>��������������������������� </span></u><span
                    style='mso-spacerun:yes'>�</span>(<u><span style='mso-tab-count:5'>����������������������������������������������������������������������������� </span></u>)<span
                    style='mso-spacerun:yes'>�� </span></span>�������.<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>1</span></b><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>. ���������������
  �������� ���������� ������������, � ���������� �� ����� 90% �� �����
  ����������� ���������� �<span style='mso-spacerun:yes'>� </span>�����������. <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>����� ����� �������������� � ������������
  � ����������� �1 � ���������� �������� �� ������ ���������� ����������
  �������� ����������
                <rw:foreach id="gktt" src="G_KOLVO_TOT">
                    <rw:field id="F_CNT5" src="CNT5"> &Field </rw:field>
                </rw:foreach>
                �������. <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>2. ��������� �����������.</span></i></b><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'> ��������� �
  ���������� �1 � ���������� �������� ��������� ����������� �������� ���������
  ��������� �����:<o:p></o:p></span></p>            
        </td>
    </tr>
</table>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=672
       style='width:7.0in;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:
  -.25in;mso-list:l1 level2 lfo2;tab-stops:9.0pt'><![if !supportLists]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
  "Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:
  Ignore'>1.1.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>��������� ��ǻ
  ��������:<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>-<span style='mso-spacerun:yes'>�
  </span>������� <span class=GramE>���������������</span> �� ����� ������� <b
                style='mso-bidi-font-weight:normal'>
            <o:p></o:p>
        </b></span></p>
    </td>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:
  -.25in;mso-list:l0 level2 lfo1;tab-stops:17.0pt list .5in'><![if !supportLists]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
  "Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:
  Ignore'>1.2.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>��������� ����Ȼ
  ��������:<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- ������� <span
                class=GramE>���������������</span> �� ����� ������� <o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>- ������������� <span class=GramE>���������������</span>
  �� ����� ������� </span><span lang=RU style='font-size:10.0pt;font-family:
  "Arial Narrow"'><o:p></o:p></span></p>
    </td>
</tr>
<tr style='mso-yfti-irow:1'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <rw:foreach id="gaz" src="G_AZ">

        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ���, �������������� �� ��������� ��ǻ:
            <rw:field id="F_CNT" src="CNT"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:4.5pt 9.0pt center 93.7pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ��������� �����:<span
                style='mso-spacerun:yes'>� </span>
            <rw:field id="F_SUM_AM" src="SUM_AM"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:4.5pt 9.0pt center 93.7pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ������:<span
                style='mso-spacerun:yes'>��������������</span><span
                style='mso-spacerun:yes'>�</span><span style='mso-spacerun:yes'>�</span>
            <rw:field id="F_SUM_PREM" src="SUM_PREM"> &Field </rw:field>
        </span></b><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
         </rw:foreach>
    </td>
    <td width=336 valign=top style='width:3.5in;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <rw:foreach id="gbuki" src="G_BUKI">
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ���, �������������� �� ��������� ����Ȼ:
            <rw:field id="F_CNT1" src="CNT1"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ��������� �����:<span
                style='mso-spacerun:yes'>� </span>
            <rw:field id="F_SUM_AM1" src="SUM_AM1"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ������:<span
                style='mso-spacerun:yes'>���������������� </span>
            <rw:field id="F_SUM_PREM1" src="SUM_PREM1"> &Field </rw:field>
        </span></b><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
        </rw:foreach>
    </td>
</tr>
<tr style='mso-yfti-irow:2'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:
  -.25in;mso-list:l0 level2 lfo1;tab-stops:9.0pt list .5in'><![if !supportLists]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
  "Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:
  Ignore'>1.3.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>��������� ����Ȼ
  ��������:<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>-<span
                style='mso-spacerun:yes'>� </span>������� <span class=GramE>���������������</span>
  �� ����� ������� <o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- ������������� <span
                class=GramE>���������������</span> �� ����� �������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �<span
                class=GramE>���������</span> ���������������� ���������� ��������
  ������������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>- ��������������� � ����� � ��������
  ����������� �����; �������������� � ����� � �������� ����������� �������������;
  �������������� � ����� � �������� ���������������; �������������� � ����� �
  �������� ���������� ������������, ����� � ������������� �������.</span><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
    </td>
    <td width=336 valign=top style='width:3.5in;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:
  -.25in;mso-list:l0 level2 lfo1;tab-stops:9.0pt list .5in'><![if !supportLists]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
  "Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:
  Ignore'>1.4.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>���������
  �������ܻ ��������:<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �������
  ��������������� � ���������� ����������� �������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �������������
  ��������������� � ���������� ����������� ������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- ���������
  ����������� ��������������� � ���������� ����������� �������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �<b
                style='mso-bidi-font-weight:normal'>�������������</b> �������������, �������
  ������������ � ����� � ���������� �������</span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>;</span></b><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>-<span style='mso-spacerun:yes'>�
  </span>��������������� ��������������� � ���������� ����������� �������.</span><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
    </td>
</tr>
<tr style='mso-yfti-irow:3'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <rw:foreach id="gvedi" src="G_VEDI">
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ���, �������������� �� ��������� ����Ȼ:
            <rw:field id="F_CNT2" src="CNT2"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:4.5pt 9.0pt center 93.7pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ��������� �����:<span
                style='mso-spacerun:yes'>� </span>
            <rw:field id="F_SUM_AM2" src="SUM_AM2"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='tab-stops:9.0pt'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>�����
  ������:<span style='mso-spacerun:yes'>���������������� </span>
            <rw:field id="F_SUM_PREM2" src="SUM_PREM2"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        </rw:foreach>
    </td>
    <td width=336 valign=top style='width:3.5in;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <rw:foreach id="gglagol" src="G_GLAGOL">
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ���, �������������� �� ��������� �������ܻ:
            <rw:field id="F_CNT3" src="CNT3"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:4.5pt 9.0pt center 93.7pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ��������� �����:<span
                style='mso-spacerun:yes'>� </span>
            <rw:field id="F_SUM_AM3" src="SUM_AM3"> &Field </rw:field>
        </span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ������:<span
                style='mso-spacerun:yes'>�������������� </span><span
                style='mso-spacerun:yes'>��</span>
            <rw:field id="F_SUM_PREM3" src="SUM_PREM3"> &Field </rw:field>
        </span></b></p>
        </rw:foreach>
    </td>
</tr>
<tr style='mso-yfti-irow:4'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.5in;text-align:justify;text-indent:
  -.25in;mso-list:l0 level2 lfo1;tab-stops:9.0pt list .5in'><![if !supportLists]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
  "Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:
  Ignore'>1.5.<span style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
                lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>��������� �����λ
  ��������:<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>-<span
                style='mso-spacerun:yes'>� </span>������� ��������������� � ����������
  ����������� �������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �������������
  ��������������� � ���������� ����������� ������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- ���������
  ����������� ��������������� � ���������� ����������� �������;<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify;tab-stops:list 0in left 9.0pt'><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>- �<b
                style='mso-bidi-font-weight:normal'>�������������</b> �������������, �������
  ������������ � ����� � ���������� �������</span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>;</span></b><span
                lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>-<span style='mso-spacerun:yes'>�
  </span>��������������� ��������������� � ���������� ����������� ������ ���
  �������<o:p></o:p></span></p>
        <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
    </td>
    <td width=336 valign=top style='width:3.5in;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
    </td>
</tr>
<tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes'>
    <td width=336 valign=top style='width:3.5in;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
        <rw:foreach id="gdobro" src="G_DOBRO">
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ���, �������������� �� ��������� �����λ: <o:p></o:p></span>
            <span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>
                <rw:field id="F_CNT4" src="CNT4"> &Field </rw:field>
                <o:p></o:p></span>
  </b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:4.5pt 9.0pt center 93.7pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ��������� �����:<span
                style='mso-spacerun:yes'>� </span>
            <rw:field id="F_SUM_PREM4" src="SUM_PREM4"> &Field </rw:field>
            <o:p></o:p></span></b></p>
        <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><b
                style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>����� ������:<span
                style='mso-spacerun:yes'>�������������</span><span
                style='mso-spacerun:yes'>���</span>
            <rw:field id="F_SUM_PREM4" src="SUM_PREM4"> &Field </rw:field>
        </span></b><span lang=RU
                                                                        style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span>
        </p>
        </rw:foreach>
    </td>
    <td width=336 valign=top style='width:3.5in;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
        <p class=MsoNormal style='margin-left:.25in;text-align:justify;tab-stops:
  9.0pt'><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
    </td>
</tr>
</table>

<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></i></b></p>

<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></i></b></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=672
       style='width:7.0in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>3. ������ �����������. 1 (����)</span></i></b><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'> ����������� ���,
  �
                <i><u><rw:field id="F_START_DATE" src="START_DATE" formatMask="dd.MM.yyyy"> &Field </rw:field></u></i>
                ��
                <i><u><rw:field id="F_END_DATE" src="END_DATE" formatMask="dd.MM.yyyy"> &Field </rw:field></u></i> 
                , �� �� ����� 00 ����� 00 ����� ���, ���������� �� �����
  ����������� ������� ��������� ������ �� ��������� ���� �����������. <b
                    style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
                    style='mso-spacerun:yes'>�</span>
                <o:p></o:p>
            </i></b></span></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>4. ����� ������� ��������� ������ </span></i></b><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>�� ����������
  �������� ���������� <i style='mso-bidi-font-style:normal'><u>
                <rw:field id="F_PREMIUM" src="PREMIUM"> &Field </rw:field>
            </u></i>  ������
  � ������ ���� �������� �������������.<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>5. ��������� �����.</span></i></b><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'> ��������� �����
  �� ������� ��������������� ������� � ���������� �1 � ���������� ��������.<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>��������� ����� �� ������� ���������������
  �� ����� ���� ����� 100&nbsp;000 (��� �����)<span style='mso-spacerun:yes'>�
  </span>������ ��� ����� 1&nbsp;500&nbsp;000 (���� ������� ������� �����)
  ������ �� ��������.<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>6. �������������� �������: �������
  �������� ����������� ���������������� ������� ����������� ���������. <o:p></o:p></span></i></b></p>
            <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>7. ���������� � ���������� ��������
  �����������:<o:p></o:p></span></i></b></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>7.1. ���������� � 1: ������ ��������������
  ���, � ��������� �������, �����, ��������, ���������, ���� ��������,
  ��������, ������ �������� �����������, ��������� ����� � ���������� ������;<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>7.2. ���������� � 2: ����� �������<span
                    style='mso-spacerun:yes'>� </span>���������� ����������� ����� � �����������
  �� ���������� ������� � �������� ������� ������� ��
                <rw:foreach id="grd" src="G_RULE_DATE">
                    <rw:field id="F_START_DATE1" src="START_DATE1" formatMask="dd.MM.yyyy"> &Field </rw:field>
                </rw:foreach>
                (����� ������
  ��������).<o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>7.3.<span style='mso-spacerun:yes'>�
  </span></span><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow";
  mso-ansi-language:EN-US'><span style='mso-spacerun:yes'>�</span></span><u><span
                    style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:EN-US'><span
  style='mso-tab-count:14'>��������������������		�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������� </span>
                    <span
                    style='mso-tab-count:12'>        </span>
                    </span></u></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  10.0pt;font-family:"Arial Narrow"'>8. ������� ������. ����������
  ������������. ��������� ������. <o:p></o:p></span></p>
            <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  7.0pt;font-family:"Arial Narrow"'>������������ ��������� ������������, ��� �
  ���������� �1 � ���������� �������� ����������� �� ������� ����, ����������
  ���������� </span><span style='font-size:7.0pt;font-family:"Arial Narrow";
  mso-ansi-language:EN-US'>I</span><span lang=RU style='font-size:7.0pt;
  font-family:"Arial Narrow"'> ��� </span><span style='font-size:7.0pt;
  font-family:"Arial Narrow";mso-ansi-language:EN-US'>II</span><span lang=RU
                                                                     style='font-size:7.0pt;font-family:"Arial Narrow"'> ������; <span
                    class=GramE>����, ���������� �������� ��� ������������ ��������������
  ������������, ����������� � ��������� �� ����� ������ �� ������������
  ����,<span style='mso-spacerun:yes'>� </span>���������� ���������������
  �������������, ����������� �� ������ ���������� �������� ����������� ��
  ������������ �������, � ����� ����, ��� �������� ������������ ������� �
  ���������� ������ (� ���������:<span style='mso-spacerun:yes'>� </span>������
  � �������, �� ������, ��� �����, ��� ������, ������ � ������������, ��������,
  �������������� ��� �������������� ���������� � �.�</span>.) ������������
  �������� � ���, ��� ����� ������������, ����������� ��� �������� ���������
  ��� ���������� ���������� �������� �����������, � �� ���<span
                    style='mso-spacerun:yes'>� </span>������������� ����� ����������� ��������.
  ������������ ������ ������� ���� ����������� ����� �������� ��������� �������
  ����������� �� �����������, � ������� ���������� ��������� ������</span><b
                    style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
                    lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></i></b></p>
        </td>
    </tr>
</table>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=672
       style='width:7.0in;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>����������:<o:p></o:p></span>
            </p>
        </td>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>������������: �� ������
  ��������� <span class=GramE>��������</span>, ����� ������� �������<o:p></o:p></span></p>
        </td>
    </tr>
    <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>
                <rw:foreach id="gon1" src="G_ORG_NAME">
                    <rw:field id="F_ORG_DESC" src="ORG_DESC"> &Field </rw:field>
                </rw:foreach>
                <o:p></o:p></span>
            </p>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>
                &nbsp;</o:p></span></p>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>
                &nbsp;</o:p></span></p>

        </td>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>
                <rw:foreach id="gstr1" src="G_STR">
                    <rw:field id="F_STR_INF" src="STR_INF"> &Field </rw:field>
                </rw:foreach>
                <o:p></o:p></span>
            </p>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>
                &nbsp;</o:p></span></p>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>
                &nbsp;</o:p></span></p>
        </td>
    </tr>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>�������<span
                    style='mso-spacerun:yes'>�������������������������������������������
  </span>(��)<o:p></o:p></span></p>
        </td>
        <td width=672 valign=top style='width:7.0in;padding:0in 5.4pt 0in 5.4pt'>
            <p class=MsoNormal style='margin-right:-5.4pt;tab-stops:9.0pt'><span lang=RU
                                                                                 style='font-size:10.0pt;font-family:"Arial Narrow"'>�������<span
                    style='mso-spacerun:yes'>�������������������������������������������
  </span>(��)<o:p></o:p></span></p>
        </td>
    </tr>
    
</table>

<p class=MsoNormal><span style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>
</rw:foreach>
</div>

</body>

</html>

</rw:report>

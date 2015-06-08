<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*, java.text.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>

<%
	SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  DecimalFormat format = new DecimalFormat("0.00");
  boolean nsShow = false;
  boolean showBeneficiary = false;
%>

<rw:report id="policy_garm_life"> 
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="policy_garm_life" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="POLICY_GARM_LIFE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>ащк
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_POLICY">
      <select>
      <![CDATA[SELECT p.policy_id, ph.policy_header_id,
       DECODE (NVL (pol_ser, '@'),
               '@', pol_num,
               pol_ser || '-' || pol_num
              ) pol_ser_num,
       p.first_pay_date, fp.brief curr, pt.number_of_payments,
       vtp.description prod_desc, per.description per_desc
  FROM ven_p_policy p,
       ven_p_pol_header ph,
       ven_fund fp,
       ven_t_payment_terms pt,
       ven_t_product vtp,
       ven_t_period per
 WHERE p.policy_id = ph.policy_id
   AND ph.fund_pay_id = fp.fund_id
   AND p.payment_term_id = pt.ID
   AND ph.product_id = vtp.product_id
   AND p.period_id = per.ID
   AND ph.policy_header_id = :p_policy_header_id]]>
      </select>
      <displayInfo x="1.01038" y="1.41663" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.38916" y="2.05408" width="1.94214" height="1.28516"
        />
        <dataItem name="per_desc" datatype="vchar2" columnOrder="58"
         width="765" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Per Desc">
          <dataDescriptor expression="per.description"
           descriptiveExpression="PER_DESC" order="8" width="765"/>
        </dataItem>
        <dataItem name="prod_desc" datatype="vchar2" columnOrder="18"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Prod Desc">
          <dataDescriptor expression="vtp.description"
           descriptiveExpression="PROD_DESC" order="7" width="255"/>
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
        <dataItem name="first_pay_date" datatype="date" oracleDatatype="date"
         columnOrder="15" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date">
          <dataDescriptor expression="p.first_pay_date"
           descriptiveExpression="FIRST_PAY_DATE" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="CURR" datatype="vchar2" columnOrder="16" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Curr">
          <dataDescriptor expression="fp.brief" descriptiveExpression="CURR"
           order="5" width="30"/>
        </dataItem>
        <dataItem name="NUMBER_OF_PAYMENTS" oracleDatatype="number"
         columnOrder="17" width="22" defaultWidth="110000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Number Of Payments">
          <dataDescriptor expression="pt.number_of_payments"
           descriptiveExpression="NUMBER_OF_PAYMENTS" order="6"
           oracleDatatype="number" width="22" precision="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL">
      <select>
      <![CDATA[SELECT iss.policy_id, iss.contact_name, vcp.date_of_birth,
        pkg_contact.get_primary_doc (iss.contact_id) doc_desc
        FROM v_pol_issuer iss, ven_cn_person vcp
        WHERE iss.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="3.12500" y="0.05212" width="1.03125" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="2.87830" y="0.61719" width="1.52551" height="1.79785"
        />
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="22"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( iss.contact_id )"
           descriptiveExpression="DOC_DESC" order="4" width="4000"/>
        </dataItem>
        <dataItem name="POLICY_ID1" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="CONTACT_NAME" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="DATE_OF_BIRTH" datatype="date" oracleDatatype="date"
         columnOrder="21" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="3"
           oracleDatatype="date" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ZASTRAHOVANNI">
      <select>
      <![CDATA[SELECT a.as_asset_id, a.p_policy_id,
       fn_obj_name (a.ent_id, a.as_asset_id) contact_name, vcp.date_of_birth,
       pkg_contact.get_primary_doc (vas.assured_contact_id) doc_desc
  FROM ven_as_asset a, ven_cn_person vcp, ven_as_assured vas
 WHERE a.as_asset_id = vas.as_assured_id AND vas.contact_id = vcp.contact_id]]>
      </select>
      <displayInfo x="3.17700" y="3.83325" width="0.69995" height="0.32983"/>
      <group name="G_ZASTRAHOVANNI">
        <displayInfo x="2.79517" y="4.38550" width="1.48376" height="1.79785"
        />
        <dataItem name="as_asset_id" oracleDatatype="number" columnOrder="23"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id">
          <dataDescriptor expression="a.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="p_policy_id" oracleDatatype="number" columnOrder="24"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id">
          <dataDescriptor expression="a.p_policy_id"
           descriptiveExpression="P_POLICY_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name1" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name1">
          <dataDescriptor
           expression="fn_obj_name ( a.ent_id , a.as_asset_id )"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="date_of_birth1" datatype="date" oracleDatatype="date"
         columnOrder="26" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth1">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor
           expression="pkg_contact.get_primary_doc ( vas.assured_contact_id )"
           descriptiveExpression="DOC_DESC" order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PROG">
      <select>
      <![CDATA[SELECT   a.AS_ASSET_ID,pl.DESCRIPTION,pc.START_DATE, pc.END_DATE, nvl(pc.ins_amount,0) ins_amount, nvl(pc.premium,0) premium, pc.start_date,plt.presentation_desc, count(1) over(PARTITION BY  plt.presentation_desc) osn_row_cnt
    FROM ven_as_asset a,
         ven_p_cover pc,
         ven_t_prod_line_option plo,
         ven_t_product_line pl,
         ven_t_product_line_type plt
   WHERE a.as_asset_id = pc.as_asset_id
     AND pc.t_prod_line_option_id = plo.ID
     AND plo.product_line_id = pl.ID
     AND pl.product_line_type_id = plt.product_line_type_id
     AND (plt.presentation_desc = 'ОСН' or plt.presentation_desc = 'ДОП' )
     order by plt.presentation_desc desc]]>
      </select>
      <displayInfo x="5.67712" y="1.54163" width="1.23950" height="0.32983"/>
      <group name="G_PROG">
        <displayInfo x="5.57678" y="2.25208" width="1.44214" height="1.79785"
        />
        <dataItem name="START_DATE1" datatype="date" oracleDatatype="date"
         columnOrder="35" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date1">
          <dataDescriptor expression="pc.START_DATE"
           descriptiveExpression="START_DATE" order="3" width="9"/>
        </dataItem>
        <dataItem name="END_DATE" datatype="date" oracleDatatype="date"
         columnOrder="36" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="pc.END_DATE"
           descriptiveExpression="END_DATE" order="4" width="9"/>
        </dataItem>
        <dataItem name="ins_amount" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Nvl Pc Ins Amount 0">
          <xmlSettings xmlTag="NVL_PC_INS_AMOUNT_0"/>
          <dataDescriptor expression="nvl ( pc.ins_amount , 0 )"
           descriptiveExpression="INS_AMOUNT" order="5"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="premium" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Nvl Pc Premium 0">
          <xmlSettings xmlTag="NVL_PC_PREMIUM_0"/>
          <dataDescriptor expression="nvl ( pc.premium , 0 )"
           descriptiveExpression="PREMIUM" order="6" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="presentation_desc" datatype="vchar2" columnOrder="32"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Presentation Desc">
          <dataDescriptor expression="plt.presentation_desc"
           descriptiveExpression="PRESENTATION_DESC" order="8" width="30"/>
        </dataItem>
        <dataItem name="osn_row_cnt" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Osn Row Cnt">
          <dataDescriptor
           expression="count ( 1 ) over ( PARTITION BY plt.presentation_desc )"
           descriptiveExpression="OSN_ROW_CNT" order="9"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="AS_ASSET_ID1" oracleDatatype="number" columnOrder="28"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id1">
          <dataDescriptor expression="a.AS_ASSET_ID"
           descriptiveExpression="AS_ASSET_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DESCRIPTION" datatype="vchar2" columnOrder="29"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="pl.DESCRIPTION"
           descriptiveExpression="DESCRIPTION" order="2" width="255"/>
        </dataItem>
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="30" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PAYMENT">
      <select>
      <![CDATA[SELECT count(1) over() cnt_pay, pps.POL_HEADER_ID, pps.DUE_DATE
  FROM v_policy_payment_schedule pps]]>
      </select>
      <displayInfo x="0.83337" y="4.27075" width="0.69995" height="0.32983"/>
      <group name="G_PAYMENT">
        <displayInfo x="0.43103" y="4.97070" width="1.50464" height="0.77246"
        />
        <dataItem name="cnt_pay" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt Pay">
          <dataDescriptor expression="count ( 1 ) over ( )"
           descriptiveExpression="CNT_PAY" order="1" width="22" precision="38"
          />
        </dataItem>
        <dataItem name="POL_HEADER_ID" oracleDatatype="number"
         columnOrder="37" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Pol Header Id">
          <dataDescriptor expression="pps.POL_HEADER_ID"
           descriptiveExpression="POL_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DUE_DATE" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Due Date">
          <dataDescriptor expression="pps.DUE_DATE"
           descriptiveExpression="DUE_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_VIGODOPRIOBRETATEL">
      <select>
      <![CDATA[SELECT asset.as_asset_id, vas.assured_contact_id contact_id_a,
       ben.contact_id contact_id_b,
       ent.obj_name (vcp.ent_id, vcp.contact_id) NAME, vcp.date_of_birth,
       ben.VALUE dolya
  FROM ven_cn_person vcp,
       ven_as_beneficiary ben,
       ven_as_asset asset,
       ven_as_assured vas
 WHERE asset.as_asset_id = vas.as_assured_id
   AND asset.as_asset_id = ben.as_asset_id
   AND ben.contact_id = vcp.contact_id
]]>
      </select>
      <displayInfo x="4.98962" y="6.53125" width="0.69995" height="0.32983"/>
      <group name="G_VIGODOPRIOBRETATEL">
        <displayInfo x="4.59253" y="7.23120" width="1.49426" height="1.45605"
        />
        <dataItem name="contact_id_a" oracleDatatype="number" columnOrder="44"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id A">
          <dataDescriptor expression="vas.assured_contact_id"
           descriptiveExpression="CONTACT_ID_A" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id_b" oracleDatatype="number" columnOrder="45"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id B">
          <dataDescriptor expression="ben.contact_id"
           descriptiveExpression="CONTACT_ID_B" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="as_asset_id3" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id3">
          <dataDescriptor expression="asset.as_asset_id"
           descriptiveExpression="AS_ASSET_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="NAME" datatype="vchar2" columnOrder="41" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Name">
          <dataDescriptor
           expression="ent.obj_name ( vcp.ent_id , vcp.contact_id )"
           descriptiveExpression="NAME" order="4" width="4000"/>
        </dataItem>
        <dataItem name="dolya" oracleDatatype="number" columnOrder="42"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dolya">
          <dataDescriptor expression="ben.VALUE" descriptiveExpression="DOLYA"
           order="6" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="date_of_birth2" datatype="date" oracleDatatype="date"
         columnOrder="43" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth2">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_CURATOR">
      <select>
      <![CDATA[select pc.policy_id, pc.contact_id, ent.obj_name(c.ent_id, c.contact_id) contact_name, emp.TAB_NUM TAB_NUM
  from  VEN_p_policy_contact pc, VEN_t_contact_pol_role cpr, ven_contact c, ven_EMPLOYEE emp
 where
       lower(cpr.brief) = 'куратор'
   and cpr.id = pc.contact_policy_role_id
   and c.contact_id = pc.contact_id
   and c.CONTACT_ID = emp.CONTACT_ID(+)
;  ]]>
      </select>
      <displayInfo x="1.37500" y="0.20837" width="0.69995" height="0.32983"/>
      <group name="G_CURATOR">
        <displayInfo x="1.04565" y="0.64795" width="1.42126" height="0.94336"
        />
        <dataItem name="policy_id2" oracleDatatype="number" columnOrder="46"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id2">
          <dataDescriptor expression="pc.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_id2" oracleDatatype="number" columnOrder="47"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id2">
          <dataDescriptor expression="pc.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name2" datatype="vchar2" columnOrder="48"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name2">
          <dataDescriptor
           expression="ent.obj_name ( c.ent_id , c.contact_id )"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="TAB_NUM" datatype="vchar2" columnOrder="49"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tab Num">
          <dataDescriptor expression="emp.TAB_NUM"
           descriptiveExpression="TAB_NUM" order="4" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_CONTACT_REL">
      <select>
      <![CDATA[ SELECT cnr1.CONTACT_ID_A, cnr1.CONTACT_ID_B, relt.relationship_dsc
                  FROM ven_cn_contact_rel cnr1,
                       ven_t_contact_rel_type relt
                 WHERE cnr1.relationship_type = relt.ID]]>
      </select>
      <displayInfo x="7.19788" y="7.35413" width="1.26050" height="0.47974"/>
      <group name="G_CONTACT_REL">
        <displayInfo x="6.78516" y="8.05408" width="1.52551" height="0.77246"
        />
        <dataItem name="CONTACT_ID_A1" oracleDatatype="number"
         columnOrder="50" width="22" defaultWidth="110000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Contact Id A1">
          <dataDescriptor expression="cnr1.CONTACT_ID_A"
           descriptiveExpression="CONTACT_ID_A" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="CONTACT_ID_B1" oracleDatatype="number"
         columnOrder="51" width="22" defaultWidth="110000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Contact Id B1">
          <dataDescriptor expression="cnr1.CONTACT_ID_B"
           descriptiveExpression="CONTACT_ID_B" order="2" width="22"
           precision="9"/>
        </dataItem>
        <dataItem  name="relationship_dsc" datatype="vchar2" columnOrder="52"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Relationship Dsc">
          <dataDescriptor expression="relt.relationship_dsc"
           descriptiveExpression="RELATIONSHIP_DSC" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ORG_CONT">
      <select>
      <![CDATA[SELECT pkg_contact.get_essential(pkg_app_param.get_app_param_u('WHOAMI')) ORG_CONT FROM DUAL]]>
      </select>
      <displayInfo x="7.83337" y="0.28088" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="7.56128" y="0.82495" width="1.24426" height="0.43066"
        />
        <dataItem name="ORG_CONT" datatype="vchar2" columnOrder="53"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Org Cont">
          <dataDescriptor
           expression="pkg_contact.get_essential ( pkg_app_param.get_app_param_u ( &apos;WHOAMI&apos; ) )"
           descriptiveExpression="ORG_CONT" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOV">
      <select>
      <![CDATA[SELECT iss.policy_id, pkg_contact.get_essential(iss.contact_id) STR_INF
        FROM v_pol_issuer iss]]>
      </select>
      <displayInfo x="0.88696" y="6.60999" width="0.69995" height="0.32983"/>
      <group name="G_STRAHOV">
        <displayInfo x="0.52087" y="7.21875" width="1.42700" height="0.60156"
        />
        <dataItem name="policy_id3" oracleDatatype="number" columnOrder="54"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id3">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="STR_INF" datatype="vchar2" columnOrder="55"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pkg Contact Get Essential Iss">
          <xmlSettings xmlTag="PKG_CONTACT_GET_ESSENTIAL_ISS_"/>
          <dataDescriptor
           expression="pkg_contact.get_essential ( iss.contact_id )"
           descriptiveExpression="STR_INF" order="2" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select policy_id,PAYMENT_TERM_DESC 
from v_POLICY_PAYMENT]]>
      </select>
      <displayInfo x="3.61462" y="2.60425" width="0.69995" height="0.32983"/>
      <group name="G_PAY_TERM">
        <displayInfo x="3.04041" y="3.30420" width="1.84839" height="0.60156"
        />
        <dataItem name="policy_id4" oracleDatatype="number" columnOrder="56"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id4">
          <dataDescriptor expression="policy_id"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="PAYMENT_TERM_DESC" datatype="vchar2" columnOrder="57"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Payment Term Desc">
          <dataDescriptor expression="PAYMENT_TERM_DESC"
           descriptiveExpression="PAYMENT_TERM_DESC" order="2" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STRAHOVATEL" childColumn="POLICY_ID1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_ZASTRAHOVANNI" childColumn="p_policy_id" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_POLICY" parentColumn="POLICY_HEADER_ID"
     childQuery="Q_PAYMENT" childColumn="POL_HEADER_ID" condition="eq"
     sqlClause="where"/>
    <link name="L_4" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_CURATOR" childColumn="policy_id2" condition="eq"
     sqlClause="where"/>
    <link name="L_5" parentGroup="G_ZASTRAHOVANNI" parentColumn="as_asset_id"
     childQuery="Q_VIGODOPRIOBRETATEL" childColumn="as_asset_id3"
     condition="eq" sqlClause="where"/>
    <link name="L_6" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STRAHOV" childColumn="policy_id3" condition="eq"
     sqlClause="where"/>
    <link name="L_7" parentGroup="G_ZASTRAHOVANNI" parentColumn="as_asset_id"
     childQuery="Q_PROG" childColumn="AS_ASSET_ID1" condition="eq"
     sqlClause="where"/>
    <link name="L_8" parentGroup="G_VIGODOPRIOBRETATEL"
     parentColumn="contact_id_a" childQuery="Q_CONTACT_REL"
     childColumn="CONTACT_ID_A1" condition="eq" sqlClause="where"/>
    <link name="L_9" parentGroup="G_VIGODOPRIOBRETATEL"
     parentColumn="contact_id_b" childQuery="Q_CONTACT_REL"
     childColumn="CONTACT_ID_B1" condition="eq" sqlClause="where"/>
    <link name="L_10" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_1" childColumn="policy_id4" condition="eq"
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
<rw:foreach id="gpolicy" src="G_POLICY">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="Полис%20Гармония%20Жизниrrr.files/filelist.xml">
<title>
  <rw:field id="F_PROD_DESC" src="PROD_DESC"> &Field </rw:field>
</title>
<!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--h2
	{mso-style-next: О б ы ч н ы й
;}

 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
h2
	{margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	mso-outline-level:2;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p
	{font-size:12.0pt;
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
</style>
<![endif]-->
</head>

<body lang=EN-US style='tab-interval:.5in'>

<div class=Section1>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=795
 style='width:480.55pt;margin-left:0pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev:
 .5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-top:12.0pt;margin-right:0in;
  margin-bottom:12.0pt;margin-left:0in;text-align:center'><b><span lang=RU
  style='font-size:20.0pt;mso-bidi-font-size:12.0pt;color:#FF6600;mso-ansi-language:
  RU'>
    <rw:field id="F_PROD_DESC1" src="PROD_DESC"> &Field </rw:field>
  </span></b><b><span lang=RU style='font-size:18.0pt;
  color:#FF6600;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-top:12.0pt;margin-right:0in;
  margin-bottom:12.0pt;margin-left:0in;text-align:center'><b><span lang=RU
  style='font-size:18.0pt;color:#FF6600;mso-ansi-language:RU'>Полис </span></b><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:18.0pt;
  color:#FF6600;mso-ansi-language:RU'>№<span style='mso-spacerun:yes'>  </span></span></b><b><span
  style='font-size:18.0pt;color:#FF6600'>
      <rw:field id="F_POL_SER_NUM" src="POL_SER_NUM"> &Field </rw:field>
  </span></b></p>
  <p class=MsoNormal align=center style='margin-top:12.0pt;margin-right:0in;
  margin-bottom:12.0pt;margin-left:0in;text-align:center'><span lang=RU
  style='font-size:4.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>1. СТРАХОВЩИК</span></b><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:21.05pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:21.05pt'>
  <p class=MsoNormal style='margin-top:6.0pt'><span lang=RU style='font-size:
  10.0pt;mso-ansi-language:RU'>
  <rw:foreach id="gorgcont" src="G_ORG_CONT">
    <rw:field id="F_ORG_CONT" src="ORG_CONT"> &Field</rw:field>
  </rw:foreach>
  </span><span lang=RU style='font-size:
  8.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:19.7pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:19.7pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>2. СТРАХОВАТЕЛЬ</span></b><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="gstrahovatel" src="G_STRAHOVATEL">
 <tr style='mso-yfti-irow:9;height:11.2pt'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:11.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>Ф.И.О.</span></b><span lang=RU
  style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:11.2pt'>
  <h2><span class=MsoNormal><span style='mso-ansi-language:EN-US;font-weight:normal'>
    <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field </rw:field>           
  </span></span>
  </span><span lang=RU style='font-weight:
  normal'><o:p></o:p></span></h2>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:13.0pt'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:13.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА РОЖДЕНИЯ</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.0pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
      <rw:field id="F_DATE_OF_BIRTH" src="DATE_OF_BIRTH" formatMask="DD.MM.YYYY"> &Field</rw:field>
  <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДОКУМЕНТ</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
  <rw:field id="F_DOC_DESC" src="DOC_DESC">&Field</rw:field>
  </span><span lang=RU style='mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:12.9pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:12.9pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>
 <tr style='mso-yfti-irow:8;height:19.6pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:19.6pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>3. ЗАСТРАХОВАННОЕ ЛИЦО</span></b><span
  lang=RU style='font-size:9.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="gzastrahovanni" src="G_ZASTRAHOVANNI">
 <tr style='mso-yfti-irow:9;height:11.2pt'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:11.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>Ф.И.О.</span></b><span lang=RU
  style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:11.2pt'>
  <h2><span class=MsoNormal><span style='mso-ansi-language:EN-US;font-weight:normal'>
    <rw:field id="F_CONTACT_NAME1" src="CONTACT_NAME1"> &Field </rw:field>           
  </span></span>
  </span><span lang=RU style='font-weight:
  normal'><o:p></o:p></span></h2>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:13.0pt'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:13.0pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА РОЖДЕНИЯ</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.0pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
  <rw:field id="F_DATE_OF_BIRTH1" src="DATE_OF_BIRTH1" formatMask="DD.MM.YYYY"> &Field </rw:field>
  <b style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=115 valign=top style='width:71.1pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДОКУМЕНТ</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=8 valign=top style='width:459.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
    <rw:field id="F_DOC_DESC1" src="DOC_DESC1"> &Field </rw:field>           
  </span></p>
  </td>
 </tr>
  <rw:getValue id="asset1111" src="AS_ASSET_ID"/>
 </rw:foreach>
 <tr style='mso-yfti-irow:12;height:12.65pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:12.65pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:14.9pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:14.9pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>4. ПРОГРАММЫ СТРАХОВАНИЯ</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:18.35pt'>
  <td colspan=7 valign=top style='width:426.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:18.35pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:3.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:3.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 valign=top style='width:57.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.35pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>Страховая сумма, </span></i><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>
  <rw:field id="F_CURR" src="CURR"> &Field </rw:field>
  </span></i><i
  style='mso-bidi-font-style:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>.<o:p></o:p></span></i></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>Премия, </span></i><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt'>
  <rw:field id="F_CURR1" src="CURR"> &Field </rw:field>
  <o:p></o:p></span></i></p>
  </td>
 </tr>
<%boolean ShowOsnProg = true;%>
<%boolean ShowDopProg = true;%>
<%double SumPremiumOsn = 0; %>
<%double SumPremiumDop = 0; %>
<rw:foreach id="gprog" src="G_PROG">
<rw:getValue id="progIdent" src="PRESENTATION_DESC"/>
<rw:getValue id="rowCnt" src="osn_row_cnt"/>
<% if (progIdent.equals("ОСН")) {%>
 <tr style='mso-yfti-irow:15;height:13.15pt'>
  <%if (ShowOsnProg) {%>
  <td colspan=3 rowspan=<%=rowCnt%> valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ОСНОВНАЯ ПРОГРАММА: </span></b></p>
  </td>
 <%ShowOsnProg = false;}%>
  <td colspan=4 valign=top style='width:205.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
      <rw:field id="F_DESCRIPTION" src="DESCRIPTION"> &Field </rw:field>
  <b style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>
  </td>
  <td width=143 valign=top style='width:57.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>
      <rw:field id="F_INS_AMOUNT" src="INS_AMOUNT" formatMask="999999990D99"> &Field </rw:field>
  <o:p></o:p></span></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>
      <rw:field id="F_PREMIUM" src="PREMIUM" formatMask="999999990D99"> &Field </rw:field>            
        <rw:getValue id="PremiumOsn" src="PREMIUM" formatMask="999999999.99"/>
        <%SumPremiumOsn = SumPremiumOsn + Double.valueOf(PremiumOsn).doubleValue();%>
  <o:p></o:p></span></p>
  </td>
 </tr>
 <%}%>
<% if (progIdent.equals("ДОП")) {%>
  <rw:getValue id="progDesc" src="DESCRIPTION"/>
  <% if (progDesc.indexOf("НС") != -1) nsShow = true;%>
 <tr style='mso-yfti-irow:16;height:13.15pt'>
     <%if (ShowDopProg) {%>
  <td colspan=3 rowspan=<%=rowCnt%> valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДОПОЛНИТЕЛЬНАЯ <span
  style='mso-spacerun:yes'> </span>ПРОГРАММА:<o:p></o:p></span></b></p>
  </td>
   <%ShowDopProg = false;} %>
  <td colspan=4 valign=top style='width:205.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
  <rw:field id="F_DESCRIPTION1" src="DESCRIPTION"> &Field </rw:field>
  <o:p></o:p></span></p>
  </td>
  <td width=143 valign=top style='width:57.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>
  <rw:field id="F_INS_AMOUNT1" src="INS_AMOUNT" formatMask="999999990D99"> &Field </rw:field>            
  <o:p></o:p></span></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:13.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>
  <rw:field id="F_PREMIUM1" src="PREMIUM" formatMask="999999990D99"> &Field </rw:field>
        <rw:getValue id="PremiumDop" src="PREMIUM" formatMask="999999999.99"/>
        <%SumPremiumDop = SumPremiumDop + Double.valueOf(PremiumDop).doubleValue();%>

  <o:p></o:p></span></p>
  </td>
 </tr>
 <%}%>
 </rw:foreach>
 <tr style='mso-yfti-irow:17;height:22.5pt'>
  <td colspan=8 valign=top style='width:483.35pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:22.5pt'>
  <p class=MsoNormal align=left style='text-align:left'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>ИТОГО:<span style='mso-spacerun:yes'> 
  </span>ПРЕМИЯ<span style='mso-spacerun:yes'>  </span>ПО ОСНОВНОЙ<span
  style='mso-spacerun:yes'>  </span>И ДОПОЛНИТЕЛЬНЫМ ПРОГРАММАМ<span
  style='mso-spacerun:yes'>  </span>(
  <rw:foreach id="gpt" src="G_PAY_TERM">
  <rw:field id="F_PAYMENT_TERM_DESC" src="PAYMENT_TERM_DESC"> &Field </rw:field>
  </rw:foreach>

  ):<o:p></o:p></span></b></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:22.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><b>
  <%=format.format(SumPremiumOsn + SumPremiumDop)%>
  </b> <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18'>
  <td colspan=8 valign=top style='width:483.35pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'>       </span><span
  style='mso-spacerun:yes'>                                                                                            </span>АДМИНИСТРАТИВНЫЕ
  ИЗДЕРЖКИ (уплачиваются один раз в год):<o:p></o:p></span></b></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>300,00</span></b><b style='mso-bidi-font-weight:normal'><span
  lang=RU style='font-size:3.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;page-break-inside:avoid;height:28.0pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:28.0pt'>
  <p class=MsoNormal style='margin-top:6.0pt'><i><span lang=RU
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU;
  mso-no-proof:yes'>Все банковские расходы, связанные с оплатой страховой
  премии, оплачиваются Страхователем. </span></i><b style='mso-bidi-font-weight:
  normal'><i><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:23.5pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:23.5pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>5. ПЕРИОД СТРАХОВАНИЯ</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
<rw:foreach id="gprog1" src="G_PROG">
 <tr style='mso-yfti-irow:20'>
  <td colspan=3 valign=top style='width:130.5pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
  <rw:field id="F_DESCRIPTION2" src="DESCRIPTION"> &Field </rw:field>
  </span><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  <p class=MsoNormal style='tab-stops:center 17.1pt'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-tab-count:1'>        </span><o:p></o:p></span></p>
  </td>
  <td width=67 valign=top style='width:49.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>
  <rw:field id="F_PER_DESC" src="PER_DESC"> &Field </rw:field>
  </o:p></span></p>
  </td>
  <td  colspan=3 valign=top style='width:123.8pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>НАЧАЛО: <o:p></o:p></span></b></p>
  <span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>00:00 часов </span>
  <span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>
  <rw:field id="F_STD" src="START_DATE1" formatMask="dd.MM.yyyy"> &Field </rw:field>
  </span>
  
  </td>
  <td colspan=2 valign=top style='width:203.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>ОКОНЧАНИЕ:<o:p></o:p></span></b></p>
    <span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>00:00 часов </span>
  <span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>
   <rw:field id="F_END" src="END_DATE" formatMask="dd.MM.yyyy"> &Field </rw:field>
  </span>
  </td>
 </tr>
 
 </rw:foreach>
 <tr style='mso-yfti-irow:23;page-break-inside:avoid'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:5.0pt;
  mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
  <%if (nsShow) {%>  
 <tr style='mso-yfti-irow:24;page-break-inside:avoid;height:66.0pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:66.0pt'>
  <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><span class=GramE><i><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>Если Страхователь за 30
  (тридцать) календарных дней до дня окончания срока страхования по
  дополнительным программам <span style='mso-bidi-font-weight:bold'>«инвалидность
  по любой причине»,<span style='mso-spacerun:yes'>  </span>«освобождение от
  уплаты взносов»</span> и </span></i><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU;mso-bidi-font-weight:bold'>«страхование от несчастных
  случаев»,</span><i><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'><span style='mso-spacerun:yes'>  </span>не выразит желания исключить
  какую-либо из указанных<span style='mso-spacerun:yes'>  </span>программ<span
  style='mso-spacerun:yes'>  </span>из настоящего Договора или не предложит
  иные условия, при условии своевременной оплаты Страхователем очередной премии,
  указанной в <span class=SpellE>п.№</span> 4 настоящего полиса, срок
  страхования по</span></i></span><i><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'> указанно<span class=GramE>й(</span><span class=SpellE>ым</span>)
  дополнительной(<span class=SpellE>ым</span>) программе(<span class=SpellE>ам</span>)
  будет считаться пролонгированным на 1 год на прежних условиях соответствующей
  дополнительной программы.</span></i><span lang=RU style='mso-ansi-language:
  RU'> </span><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:6.0pt;mso-bidi-font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
  <%} %>
 <tr style='mso-yfti-irow:25;height:13.65pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:13.65pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>6. УСЛОВИЯ И СРОКИ УПЛАТЫ
  СТРАХОВОЙ<span style='mso-spacerun:yes'>  </span>ПРЕМИИ</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ДАТА УПЛАТЫ ПЕРВОГО<span
  style='mso-spacerun:yes'>  </span>ВЗНОСА:<o:p></o:p></span></b></p>
  </td>
  <td colspan=6 valign=top style='width:310.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
    <rw:field id="F_FPD" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
  <o:p></o:p></span></p>
  </td>
 </tr>
 <%boolean ShowCaptionDataUpl = true;%>
 <rw:foreach id="gpayment" src="G_PAYMENT">
<rw:getValue id="cntPay" src="CNT_PAY"/>
 <tr style='mso-yfti-irow:27'>
<%if (ShowCaptionDataUpl){%>
  <td colspan=3 rowspan=<%=cntPay%> valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><a name="payment_rule_row"><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'></span>ДАТЫ УПЛАТЫ ПОСЛЕДУЮЩИХ ВЗНОСОВ:
  </span></b></a><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
<%ShowCaptionDataUpl = false;}%>  
  <td colspan=6 valign=top style='width:310.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>
  <rw:field id="F_DUE_DATE" src="DUE_DATE" formatMask="DD.MM.YYYY"> &Field </rw:field>
  <o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 </rw:foreach>
 <tr style='mso-yfti-irow:28;height:17.5pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>7. ВЫГОДОПРИОБРЕТАТЕЛИ НА
  СЛУЧАЙ<span style='mso-spacerun:yes'>  </span>СМЕРТИ <span class=GramE>ЗАСТРАХОВАННОГО</span></span></b><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:3.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
  <rw:foreach id="gvigodopriobretatel_rowcount" src="G_VIGODOPRIOBRETATEL" endRow="1">
    <%showBeneficiary = true;%>
  </rw:foreach>
  <%if (showBeneficiary) {%>
 <tr style='mso-yfti-irow:29;height:18.05pt'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><a name="no_benefit"><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>Ф.И.О.<o:p></o:p></span></b></a></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td colspan=3 valign=top style='width:97.0pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td colspan=2 valign=top style='width:166.1pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>РОДСТВЕННЫЕ ОТНОШЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'>ДОЛЯ<o:p></o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="gvigodopriobretatel_da" src="G_VIGODOPRIOBRETATEL">
 <tr style='mso-yfti-irow:30;height:18.05pt'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:18.05pt'><span style='mso-bookmark:no_benefit'></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:no_benefit'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <rw:field id="F_N" src="NAME"> &Field </rw:field>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:no_benefit'></span>
  <td colspan=3 valign=top style='width:97.0pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p>
  <rw:field id="F_DOB2" src="DATE_OF_BIRTH2" formatMask="DD.MM.YYYY"> &Field </rw:field>
  </o:p></span></p>
  </td>
  <td colspan=2 valign=top style='width:166.1pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p>
  <rw:foreach id="greldesc" src="G_CONTACT_REL" >
       <rw:field id="F_RELATIONSHIP_DSC" src="RELATIONSHIP_DSC"> &Field </rw:field>
  </rw:foreach>
  </o:p></span></p>
  </td>
  <td width=124 valign=top style='width:47.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:18.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p>
  <rw:field id="F_DOLYA" src="DOLYA"> &Field </rw:field>
  </o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 <%} else {%>
 <tr style='mso-yfti-irow:30;height:18.05pt'>
  <td colspan=9 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:18.05pt'><span style='mso-bookmark:no_benefit'></span>
  <p class=MsoNormal align=center style='text-align:left'><span
  style='mso-bookmark:no_benefit'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p> По законодательству РФ
  </o:p></span></span></p>
  </td>
 </tr>
 <%}%>
 <tr style='mso-yfti-irow:31;height:29.0pt'>
  <td colspan=9 style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:29.0pt'>
  <p class=MsoNormal><b><span lang=RU style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:RU'>8. ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ</span></b><b><span
  lang=RU style='font-size:8.0pt;color:#FF6600;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:32;page-break-inside:avoid;height:138.5pt'>
  <td colspan=9 valign=top style='width:480.55pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:138.5pt'>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>1. <span
  style='text-transform:uppercase'>договор страхования заключен на основании
  «Общих условий по индивидуальному страхованию жизни и страхованию от
  несчастных случаев», утвержденных Генеральным директором ООО «СК «ренессанс
  жизнь» 23.06.2006<span style='mso-spacerun:yes'>  </span><o:p></o:p></span></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;text-transform:uppercase;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>2. СТОРОНЫ ПРИЗНАЮТ
  ФАКСИМИЛЬНО ВОСПРОИЗВЕДЕННУЮ ПОДПИСЬ СТРАХОВЩИКА ПОДЛИННОЙ.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>3. ПРИ ДОСРОЧНОМ<span
  style='mso-spacerun:yes'>  </span>РАСТОРЖЕНИИ ДОГОВОРА ВЫПЛАТА
  ПРЕДУСМОТРЕННОЙ СООТВЕТСТВУЮЩЕЙ ПРОГРАММОЙ СТРАХОВАНИЯ ВЫКУПНОЙ СУММЫ
  ПРОИЗВОДИТСЯ СОГЛАСНО ТАБЛИЦЕ ВЫКУПНЫХ СУММ<span style='mso-spacerun:yes'> 
  </span>(ПРИЛОЖЕНИЕ № 1). <o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>4.ТЕРРИТОРИЯ СТРАХОВАНИЯ: ВЕСЬ МИР.<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>5.ВРЕМЯ ДЕЙСТВИЯ СТРАХОВОЙ ЗАЩИТЫ: 24 ЧАСА.<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:9.0pt;text-indent:-9.0pt'><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'>6. ДАТА ДОСРОЧНОГО
  ПРЕКРАЩЕНИЯ ВЫЖИДАТЕЛЬНОГО ПЕРИОДА: <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:33'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
  <td colspan=6 valign=top style='width:310.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34;height:64.0pt'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt;height:64.0pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>К полису прилагаются:</span></i><span
  lang=RU style='mso-ansi-language:RU'> </span><i style='mso-bidi-font-style:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></p>
  </td>
  <td colspan=6 valign=top style='width:310.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt;height:64.0pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>1. Таблица выкупных сумм по
  основной программе (Приложение № 1)<o:p></o:p></span></i></p>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>2. Заявление на страхование №
  _______<o:p></o:p></span></i></p>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>3. Соглашение о временном страховом
  покрытии № _______<o:p></o:p></span></i></p>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>2. Общие условия по
  индивидуальному страхованию жизни и страхованию от несчастных случаев<span
  style='mso-spacerun:yes'>  </span>от 23.06.2006<o:p></o:p></span></i></p>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>3. Таблица выплат по страховому
  риску &quot;телесные повреждения в результате несчастного случая&quot;<o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:35;mso-yfti-lastrow:yes'>
  <td colspan=3 valign=top style='width:220.25pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>СТРАХОВАТЕЛЬ</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td colspan=6 valign=top style='width:310.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>СТРАХОВЩИК</span></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'></b><span
  lang=RU style='mso-ansi-language:RU'> </span><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=115 style='border:none'></td>
  <td width=27 style='border:none'></td>
  <td width=148 style='border:none'></td>
  <td width=67 style='border:none'></td>
  <td width=56 style='border:none'></td>
  <td width=0 style='border:none'></td>
  <td width=145 style='border:none'></td>
  <td width=143 style='border:none'></td>
  <td width=124 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='tab-stops:100.5pt'><span lang=RU style='mso-ansi-language:
RU;mso-no-proof:yes'><o:p>&nbsp;</o:p></span></p>
<rw:foreach id="gcurator" src="G_CURATOR">
<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=710
 style='width:532.3pt;margin-left:44.9pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=264 valign=top style='width:2.75in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>ФИО Консультанта</span></i><span
  lang=RU style='mso-ansi-language:RU'> </span><i style='mso-bidi-font-style:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><span class=SpellE><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt'>
   <rw:field id="F_CONTACT_NAME2" src="CONTACT_NAME2"> &Field </rw:field>
  </span></i></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=264 valign=top style='width:2.75in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span lang=RU
  style='font-size:8.0pt;mso-ansi-language:RU'>Номер Консультанта</span></i><span
  lang=RU style='mso-ansi-language:RU'> </span><i style='mso-bidi-font-style:
  normal'><span lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></p>
  </td>
  <td width=446 valign=top style='width:334.3pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i style='mso-bidi-font-style:normal'><span
  style='font-size:8.0pt'>
  <rw:field id="F_TAB_NUM" src="TAB_NUM"> &Field </rw:field> 
  <o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=710 colspan=2 valign=top style='width:532.3pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
  <td width=710 colspan=2 valign=top style='width:532.3pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><i><span lang=RU style='font-size:8.0pt;mso-ansi-language:
  RU'>Москва, </span></i><i><span style='font-size:8.0pt'>
   <%=sdf.format(new java.util.Date())%>
  </span></i><i><span
  lang=RU style='font-size:8.0pt;mso-ansi-language:RU'><o:p></o:p></span></i></p>
  </td>
 </tr>
</table>
</rw:foreach>
<p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
lang=RU style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:4.55pt'><o:p>&nbsp;</o:p></p>

</div>

</body>

</html>

</rw:report>

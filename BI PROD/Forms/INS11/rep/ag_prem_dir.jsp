<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  DecimalFormat format = new DecimalFormat("0.00");
  double D_COMISSION_SUM_ALL = 0;  
  double D_COMISSION_SUM = 0;
  double D_S_BREAK = 0;  
  double D_BONUS_ALL = 0;  
  double D_BONUS_NEW = 0;
%>

<rw:report id="report" >

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_prem_dir" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="AG_PREM_DIR" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_VEDOM_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AG_REP_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT_REPORT">
      <select canParse="no">
      <![CDATA[SELECT count(1) over() row_cnt,
agr.agent_report_id, agch.ag_contract_header_id, agr.num act_num,
       agr.report_date, ved.date_begin, ved.date_end, con.contact_id,
       dep.name name_dep,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || agch.num dognum,
       ent.obj_name (con.ent_id, con.contact_id) agname,
       agr.av_sum,
       pkg_contact.get_fio_fmt (ent.obj_name (con.ent_id, con.contact_id), 4 ) ag_name_initial,
       NVL (nvl((select genitive from contact where contact_id = con.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), con.contact_id)),
            '________________' ) ag_name_genitive 
  FROM ven_agent_report agr JOIN ven_ag_vedom_av ved
       ON (agr.ag_vedom_av_id = ved.ag_vedom_av_id)
       JOIN ven_ag_contract_header agch
       ON (agch.ag_contract_header_id = agr.ag_contract_h_id)
       JOIN ven_contact con ON (agch.agent_id = con.contact_id)
       LEFT OUTER JOIN ven_department dep 
       ON (agch.agency_id = dep.department_id )
       LEFT OUTER JOIN ven_dept_executive dept_exe 
       ON (agch.agency_id = dept_exe.department_id)
  WHERE agr.AG_VEDOM_AV_ID = :p_vedom_id and agr.agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="0.55200" y="0.09375" width="1.54175" height="0.32983"/>
      <group name="G_AGENT_REPORT">
        <displayInfo x="0.30200" y="0.75000" width="2.03125" height="2.99414"
        />
        <dataItem name="NAME_DEP" datatype="vchar2" columnOrder="25"
         width="150" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Name Dep">
          <dataDescriptor expression="NAME_DEP"
           descriptiveExpression="NAME_DEP" order="9" width="150"/>
        </dataItem>
        <dataItem name="AG_NAME_GENITIVE" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name Genitive">
          <dataDescriptor expression="AG_NAME_GENITIVE"
           descriptiveExpression="AG_NAME_GENITIVE" order="14" width="4000"/>
        </dataItem>
        <dataItem name="ROW_CNT" oracleDatatype="number" columnOrder="24"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="ROW_CNT" descriptiveExpression="ROW_CNT"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="AG_NAME_INITIAL" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name Initial">
          <dataDescriptor expression="AG_NAME_INITIAL"
           descriptiveExpression="AG_NAME_INITIAL" order="13" width="4000"/>
        </dataItem>
        <dataItem name="AG_CONTRACT_HEADER_ID" oracleDatatype="number"
         columnOrder="21" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DOGNUM" datatype="vchar2" columnOrder="22" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dognum">
          <dataDescriptor expression="DOGNUM" descriptiveExpression="DOGNUM"
           order="10" width="201"/>
        </dataItem>
        <dataItem name="REPORT_DATE" datatype="date" oracleDatatype="date"
         columnOrder="20" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Report Date">
          <dataDescriptor expression="REPORT_DATE"
           descriptiveExpression="REPORT_DATE" order="5" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="CONTACT_ID" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="8"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id">
          <dataDescriptor expression="AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="ACT_NUM" datatype="vchar2" columnOrder="14"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Act Num">
          <dataDescriptor expression="ACT_NUM" descriptiveExpression="ACT_NUM"
           order="4" width="100"/>
        </dataItem>
        <dataItem name="DATE_BEGIN" datatype="date" oracleDatatype="date"
         columnOrder="15" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="6" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="DATE_END" datatype="date" oracleDatatype="date"
         columnOrder="16" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date End">
          <dataDescriptor expression="DATE_END"
           descriptiveExpression="DATE_END" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="AGNAME" datatype="vchar2" columnOrder="17"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Agname">
          <dataDescriptor expression="AGNAME" descriptiveExpression="AGNAME"
           order="11" width="4000"/>
        </dataItem>
        <dataItem name="AV_SUM" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Av Sum">
          <dataDescriptor expression="AV_SUM" descriptiveExpression="AV_SUM"
           order="12" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_PREM">
      <select>
      <![CDATA[SELECT * from V_REPORT_PREDIR_DOG_PREM
]]>
      </select>
      <displayInfo x="2.63367" y="0.07288" width="1.34375" height="0.32983"/>
      <group name="G_DOG_PREM">
        <displayInfo x="2.44983" y="0.76038" width="1.71301" height="4.01953"
        />
        <dataItem name="DATE_BREAK1" datatype="date" oracleDatatype="date"
         columnOrder="46" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Break1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.DATE_BREAK"
           descriptiveExpression="DATE_BREAK" order="14" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME_MNG1" datatype="vchar2" columnOrder="47"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name Mng1">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_PREM.STRAHOV_NAME_MNG"
           descriptiveExpression="STRAHOV_NAME_MNG" order="18" width="602"/>
        </dataItem>
        <dataItem name="STATUS_MNG" datatype="vchar2" columnOrder="45"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Mng">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.STATUS_MNG"
           descriptiveExpression="STATUS_MNG" order="5" width="4000"/>
        </dataItem>
        <dataItem name="ROW_CNT1" oracleDatatype="number" columnOrder="43"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.ROW_CNT"
           descriptiveExpression="ROW_CNT" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD_DEST" oracleDatatype="number" columnOrder="44"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God Dest">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.GOD_DEST"
           descriptiveExpression="GOD_DEST" order="21" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="SUM_PREMIUM" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM" oracleDatatype="number"
         columnOrder="38" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="7"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PROGR" datatype="vchar2" columnOrder="39" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.PROGR"
           descriptiveExpression="PROGR" order="16" width="255"/>
        </dataItem>
        <dataItem name="STATUS_NAME" datatype="vchar2" columnOrder="40"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="17" width="1024"/>
        </dataItem>
        <dataItem name="PERCENT_ST_PRM" oracleDatatype="number"
         columnOrder="41" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Percent St Prm">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.PERCENT_ST_PRM"
           descriptiveExpression="PERCENT_ST_PRM" order="19"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD" oracleDatatype="number" columnOrder="42"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.GOD"
           descriptiveExpression="GOD" order="20" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="IS_BREAK" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.IS_BREAK"
           descriptiveExpression="IS_BREAK" order="15" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FIRST_PAY_DATE" datatype="date" oracleDatatype="date"
         columnOrder="30" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.FIRST_PAY_DATE"
           descriptiveExpression="FIRST_PAY_DATE" order="8"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="PAY_TERM" datatype="vchar2" columnOrder="31"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pay Term">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.PAY_TERM"
           descriptiveExpression="PAY_TERM" order="9" width="500"/>
        </dataItem>
        <dataItem name="NOTICE_DATE" datatype="date" oracleDatatype="date"
         columnOrder="32" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="10"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="SGP" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.SGP"
           descriptiveExpression="SGP" order="11" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PRODUCT" datatype="vchar2" columnOrder="34"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.PRODUCT"
           descriptiveExpression="PRODUCT" order="12" width="255"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="35" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.BRIEF"
           descriptiveExpression="BRIEF" order="13" width="30"/>
        </dataItem>
        <dataItem name="POL_NUM" datatype="vchar2" columnOrder="28"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME" datatype="vchar2" columnOrder="29"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PREM.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID1" oracleDatatype="number"
         columnOrder="27" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id1">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_PREM.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_RAZV">
      <select>
      <![CDATA[select * from V_REPORT_PREDIR_DOG_RAZV]]>
      </select>
      <displayInfo x="4.55212" y="0.08337" width="1.20825" height="0.32288"/>
      <group name="G_DOG_RAZV">
        <displayInfo x="4.29565" y="0.74170" width="1.71301" height="4.01953"
        />
        <dataItem name="STRAHOV_NAME1" datatype="vchar2" columnOrder="68"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="DATE_BREAK" datatype="date" oracleDatatype="date"
         columnOrder="66" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Break">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.DATE_BREAK"
           descriptiveExpression="DATE_BREAK" order="14" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME_MNG" datatype="vchar2" columnOrder="67"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name Mng">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_RAZV.STRAHOV_NAME_MNG"
           descriptiveExpression="STRAHOV_NAME_MNG" order="18" width="602"/>
        </dataItem>
        <dataItem name="ROW_CNT2" oracleDatatype="number" columnOrder="48"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.ROW_CNT"
           descriptiveExpression="ROW_CNT" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID2" oracleDatatype="number"
         columnOrder="49" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id2">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_RAZV.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM1" datatype="vchar2" columnOrder="50"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STATUS_MNG1" datatype="vchar2" columnOrder="51"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Mng1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.STATUS_MNG"
           descriptiveExpression="STATUS_MNG" order="5" width="4000"/>
        </dataItem>
        <dataItem name="SUM_PREMIUM1" oracleDatatype="number" columnOrder="52"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM1" oracleDatatype="number"
         columnOrder="53" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="7"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FIRST_PAY_DATE1" datatype="date" oracleDatatype="date"
         columnOrder="54" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.FIRST_PAY_DATE"
           descriptiveExpression="FIRST_PAY_DATE" order="8"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="PAY_TERM1" datatype="vchar2" columnOrder="55"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pay Term1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.PAY_TERM"
           descriptiveExpression="PAY_TERM" order="9" width="500"/>
        </dataItem>
        <dataItem name="NOTICE_DATE1" datatype="date" oracleDatatype="date"
         columnOrder="56" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="10"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="SGP1" oracleDatatype="number" columnOrder="57"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.SGP"
           descriptiveExpression="SGP" order="11" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PRODUCT1" datatype="vchar2" columnOrder="58"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.PRODUCT"
           descriptiveExpression="PRODUCT" order="12" width="255"/>
        </dataItem>
        <dataItem name="BRIEF1" datatype="vchar2" columnOrder="59" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.BRIEF"
           descriptiveExpression="BRIEF" order="13" width="30"/>
        </dataItem>
        <dataItem name="IS_BREAK1" oracleDatatype="number" columnOrder="60"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.IS_BREAK"
           descriptiveExpression="IS_BREAK" order="15" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PROGR1" datatype="vchar2" columnOrder="61" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.PROGR"
           descriptiveExpression="PROGR" order="16" width="255"/>
        </dataItem>
        <dataItem name="STATUS_NAME1" datatype="vchar2" columnOrder="62"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="17" width="1024"/>
        </dataItem>
        <dataItem name="PERCENT_ST_PRM1" oracleDatatype="number"
         columnOrder="63" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Percent St Prm1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.PERCENT_ST_PRM"
           descriptiveExpression="PERCENT_ST_PRM" order="19"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD1" oracleDatatype="number" columnOrder="64"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.GOD"
           descriptiveExpression="GOD" order="20" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD_DEST1" oracleDatatype="number" columnOrder="65"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God Dest1">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_RAZV.GOD_DEST"
           descriptiveExpression="GOD_DEST" order="21" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_PROD">
      <select>
      <![CDATA[select * from V_REPORT_PREDIR_DOG_PROD]]>
      </select>
      <displayInfo x="6.41675" y="0.11462" width="1.33325" height="0.27295"/>
      <group name="G_DOG_PROD">
        <displayInfo x="6.12354" y="0.75208" width="1.91089" height="4.01953"
        />
        <dataItem name="STRAHOV_NAME2" datatype="vchar2" columnOrder="89"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="ROW_CNT3" oracleDatatype="number" columnOrder="69"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt3">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.ROW_CNT"
           descriptiveExpression="ROW_CNT" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID3" oracleDatatype="number"
         columnOrder="70" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id3">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_PROD.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM2" datatype="vchar2" columnOrder="71"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STATUS_MNG2" datatype="vchar2" columnOrder="72"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Mng2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.STATUS_MNG"
           descriptiveExpression="STATUS_MNG" order="5" width="4000"/>
        </dataItem>
        <dataItem name="SUM_PREMIUM2" oracleDatatype="number" columnOrder="73"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM2" oracleDatatype="number"
         columnOrder="74" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="7"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FIRST_PAY_DATE2" datatype="date" oracleDatatype="date"
         columnOrder="75" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.FIRST_PAY_DATE"
           descriptiveExpression="FIRST_PAY_DATE" order="8"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="PAY_TERM2" datatype="vchar2" columnOrder="76"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pay Term2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.PAY_TERM"
           descriptiveExpression="PAY_TERM" order="9" width="500"/>
        </dataItem>
        <dataItem name="NOTICE_DATE2" datatype="date" oracleDatatype="date"
         columnOrder="77" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="10"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="SGP2" oracleDatatype="number" columnOrder="78"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.SGP"
           descriptiveExpression="SGP" order="11" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PRODUCT2" datatype="vchar2" columnOrder="79"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.PRODUCT"
           descriptiveExpression="PRODUCT" order="12" width="255"/>
        </dataItem>
        <dataItem name="BRIEF2" datatype="vchar2" columnOrder="80" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.BRIEF"
           descriptiveExpression="BRIEF" order="13" width="30"/>
        </dataItem>
        <dataItem name="DATE_BREAK2" datatype="date" oracleDatatype="date"
         columnOrder="81" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Break2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.DATE_BREAK"
           descriptiveExpression="DATE_BREAK" order="14" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="IS_BREAK2" oracleDatatype="number" columnOrder="82"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.IS_BREAK"
           descriptiveExpression="IS_BREAK" order="15" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PROGR2" datatype="vchar2" columnOrder="83" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.PROGR"
           descriptiveExpression="PROGR" order="16" width="255"/>
        </dataItem>
        <dataItem name="STATUS_NAME2" datatype="vchar2" columnOrder="84"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="17" width="1024"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME_MNG2" datatype="vchar2" columnOrder="85"
         width="602" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name Mng2">
          <dataDescriptor
           expression="V_REPORT_PREDIR_DOG_PROD.STRAHOV_NAME_MNG"
           descriptiveExpression="STRAHOV_NAME_MNG" order="18" width="602"/>
        </dataItem>
        <dataItem name="PERCENT_ST_PRM2" oracleDatatype="number"
         columnOrder="86" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Percent St Prm2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.PERCENT_ST_PRM"
           descriptiveExpression="PERCENT_ST_PRM" order="19"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD2" oracleDatatype="number" columnOrder="87"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.GOD"
           descriptiveExpression="GOD" order="20" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD_DEST2" oracleDatatype="number" columnOrder="88"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God Dest2">
          <dataDescriptor expression="V_REPORT_PREDIR_DOG_PROD.GOD_DEST"
           descriptiveExpression="GOD_DEST" order="21" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_BONUS">
      <select canParse="no">
      <![CDATA[  select distinct nvl(davct.bonus_all,0) bonus_all, nvl(davct.bonus_new,0) bonus_new
  from ven_agent_report_dav agdav        
       JOIN V_T_PROD_COEF_TYPE vtct ON (vtct.T_PROD_COEF_TYPE_ID = agdav.PROD_COEF_TYPE_ID and vtct.BRIEF = 'PREM_DIR')
       JOIN ven_agent_report_dav_ct davct  ON (davct.agent_report_dav_id = agdav.agent_report_dav_id)
  where agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="0.47913" y="4.10413" width="0.69995" height="0.19995"/>
      <group name="G_BONUS">
        <displayInfo x="0.13416" y="4.80408" width="1.39001" height="0.60156"
        />
        <dataItem name="BONUS_ALL1" oracleDatatype="number" columnOrder="90"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bonus All1">
          <dataDescriptor expression="BONUS_ALL"
           descriptiveExpression="BONUS_ALL" order="1" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="BONUS_NEW1" oracleDatatype="number" columnOrder="91"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bonus New1">
          <dataDescriptor expression="BONUS_NEW"
           descriptiveExpression="BONUS_NEW" order="2" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  PKG_REP_UTILS2.iSetVal('P_AG_REP_ID',:P_AG_REP_ID);  
  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Расчет премии Директора Агентства</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="place"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>NGrek</o:Author>
  <o:Template>primary_director_report (2)</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>0</o:TotalTime>
  <o:Created>2007-07-06T06:57:00Z</o:Created>
  <o:LastSaved>2007-07-06T06:57:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>563</o:Words>
  <o:Characters>3212</o:Characters>
  <o:Lines>26</o:Lines>
  <o:Paragraphs>7</o:Paragraphs>
  <o:CharactersWithSpaces>3768</o:CharactersWithSpaces>
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
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;
	layout-grid-mode:line;}
h2
	{mso-style-next:Normal;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:70.85pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	layout-grid-mode:line;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:18.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;
	layout-grid-mode:line;}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:28.5pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:-19.5pt;
	mso-pagination:widow-orphan;
	mso-list:l3 level1 lfo4;
	tab-stops:14.2pt list 28.5pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
@page Section1
	{size:595.3pt 841.9pt;
	margin:26.95pt 42.5pt 27.0pt 36.0pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:131220508;
	mso-list-type:hybrid;
	mso-list-template-ids:1908572790 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l0:level1
	{mso-level-tab-stop:27.0pt;
	mso-level-number-position:left;
	margin-left:27.0pt;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:969628906;
	mso-list-type:hybrid;
	mso-list-template-ids:-801358350 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l1:level1
	{mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2
	{mso-list-id:1082602987;
	mso-list-type:hybrid;
	mso-list-template-ids:-696759816 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l2:level1
	{mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3
	{mso-list-id:1354503029;
	mso-list-template-ids:-267218132;}
@list l3:level1
	{mso-level-start-at:2;
	mso-level-style-link:Обычный1;
	mso-level-legal-format:yes;
	mso-level-tab-stop:28.5pt;
	mso-level-number-position:left;
	margin-left:28.5pt;
	text-indent:-19.5pt;}
@list l3:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l3:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l3:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l3:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l3:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l3:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l3:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l3:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:90.0pt;
	mso-level-number-position:left;
	margin-left:90.0pt;
	text-indent:-90.0pt;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-parent:"";
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
table.MsoTableGrid
	{mso-style-name:"Table Grid";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
	mso-para-margin:0cm;
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

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="G_BONUS" src="G_BONUS">

<rw:getValue id="BONUS_ALL1" src="BONUS_ALL1" formatMask="999999990.99"/>
<rw:getValue id="BONUS_NEW1" src="BONUS_NEW1" formatMask="999999990.99"/>

  <% D_BONUS_ALL = Double.valueOf(BONUS_ALL1).doubleValue();
     D_BONUS_NEW =  Double.valueOf(BONUS_NEW1).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_AGENT_REPORT" src="G_AGENT_REPORT">

<rw:getValue id="REPORT_DATE" src="REPORT_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_END" src="DATE_END" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AGNAME" src="AGNAME"/>
<rw:getValue id="AG_NAME_INITIAL" src="AG_NAME_INITIAL"/>
<rw:getValue id="AG_NAME_GENITIVE" src="AG_NAME_GENITIVE"/>
<rw:getValue id="NAME_DEP" src="NAME_DEP"/>

<div class=Section1>

<p class=MsoTitle style='margin-top:6.0pt'><span style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Расчет премии Директора
Агентства (филиала) <span style='mso-spacerun:yes'> </span><a name=agency><%=NAME_DEP%></a><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><a name="agent_name_R"><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=AG_NAME_GENITIVE%></span></a><b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></b></p>

<p class=MsoTitle align=left style='margin-top:6.0pt;text-align:left'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>г.
Москва<span style='mso-tab-count:5'>                                                                                                                                         </span><a
name="report_date"><%=REPORT_DATE%></a><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><span style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период с <span
style='mso-spacerun:yes'> </span><a name="date_from_1"><%=DATE_BEGIN%></a> <span
style='mso-spacerun:yes'> </span>по <span style='mso-spacerun:yes'> </span><a
name="date_to_1"><%=DATE_END%></a> <o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><st1:place w:st="on"><span lang=EN-US style='font-family:
 "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";layout-grid-mode:
 both'>I</span><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
 "Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>.</span></st1:place><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> Премия Директора Агентства за
продажи агентов и менеджеров, прикрепленных к агентству:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span><a
name="date_from_2"><span style='mso-ansi-language:RU'><%=DATE_BEGIN%></span></a><span
style='mso-ansi-language:RU'> по <a name="date_to_2"><%=DATE_END%></a></span><span
style='mso-bookmark:date_to_2'></span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'> Директор Агентства получает премию за продажи агентов и менеджеров,
прикрепленных к агентству, <span style='mso-spacerun:yes'> </span>за следующие
договоры страхования, заключенные в результате выполнения агентами и
менеджерами, прикрепленными к агентству, обязанностей по агентскому договору:<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>Бонус-ставка за
количество продающих агентов в Агентстве составляет <span
style='mso-spacerun:yes'> </span><%=format.format(D_BONUS_ALL)%>%</span></p>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>Бонус-ставка за
количество новых агентов в Агентстве составляет <span
style='mso-spacerun:yes'> </span><%=format.format(D_BONUS_NEW)%>%</span></p>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=668
 style='width:500.85pt;border-collapse:collapse;mso-padding-alt:0cm 0cm 0cm 0cm'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=80 rowspan=2 style='width:59.8pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=125 rowspan=2 style='width:93.95pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=131 rowspan=2 style='width:98.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=62 rowspan=2 style='width:46.35pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия договора<o:p></o:p></span></b></p>
   </td>
   <td width=60 rowspan=2 style='width:45.0pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
   </td>
   <td width=77 rowspan=2 style='width:57.95pt;border-top:solid windowtext 1.0pt;
   border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
   mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
   padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Уплаченная страховая премия, руб.<o:p></o:p></span></b></p>
   </td>
   <td width=133 colspan=2 style='width:99.6pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Премия за продажи агентов и менеджеров,
   прикрепленных к агентству<o:p></o:p></span></b></p>
   </td>
  </tr>
  <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
   <td width=55 valign=bottom style='width:41.05pt;border:solid windowtext 1.0pt;
   border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В % от<span style='mso-spacerun:yes'> 
   </span>страховой премии<o:p></o:p></span></b></p>
   </td>
   <td width=78 valign=bottom style='width:58.55pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG_PREM" src="G_DOG_PREM"> 

<rw:getValue id="pol_num_prem" src="pol_num"/>
<rw:getValue id="strahov_name_prem" src="strahov_name"/>
<rw:getValue id="progr_prem" src="progr"/>
<rw:getValue id="STATUS_MNG_prem" src="STATUS_MNG"/>
<rw:getValue id="god_prem" src="god"/>
<rw:getValue id="SUM_PREMIUM_prem" src="SUM_PREMIUM" formatMask="999999990.99"/>
<rw:getValue id="COMISSION_SUM_prem" src="COMISSION_SUM" formatMask="999999990.99"/>
<rw:getValue id="percent_st_prm_prem" src="percent_st_prm" formatMask="999999990.99%"/>
<rw:getValue id="IS_BREAK_prem" src="IS_BREAK"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_prem).doubleValue();%>
<%
if ( D_S_BREAK == 0) {

D_COMISSION_SUM = D_COMISSION_SUM + Double.valueOf(COMISSION_SUM_prem).doubleValue();
%>
 
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:12.75pt'>
  <td width=80 valign=top style='width:59.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-right-alt:solid windowtext .75pt;padding:0cm 0cm 0cm 0cm;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><a name="table_1"><span
  style='font-size:9.0pt'><span style='mso-spacerun:yes'> </span></span></a><span
  lang=EN-US style='font-size:9.0pt'><o:p>
  <%=pol_num_prem%>  
  </o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_prem%>
  </o:p></span></p>
  </td>
  <td width=131 valign=top style='width:98.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_prem%>
  </o:p></span></p>
  </td>
  <td width=62 valign=top style='width:46.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=god_prem%>
  </o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  &nbsp;
  </o:p></span></p>
  </td>
  <td width=77 valign=top style='width:57.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=SUM_PREMIUM_prem%>
  </o:p></span></p>
  </td>
  <td width=55 valign=top style='width:41.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=percent_st_prm_prem%>
  </o:p></span></p>
  </td>
  <td width=78 valign=top style='width:58.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=COMISSION_SUM_prem%>
  </o:p></span></p>
  </td>
 </tr>
 <%}%>
</rw:foreach> 
</table>

</div>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><a
name="canceled_1"><span style='mso-ansi-language:RU;layout-grid-mode:both'>2. </span></a><span
style='mso-bookmark:canceled_1'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>За период с </span></span><span style='mso-bookmark:canceled_1'><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span></span><span
style='mso-bookmark:canceled_1'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'> были расторгнуты следующие договоры страхования, заключенные <span
style='text-transform:uppercase'>Страховщиком</span> при посредничестве агентов
и менеджеров, прикрепленных к Агентству, премия за продажи агентов и
менеджеров, прикрепленных к агентству по которым была выплачена Директору
Агентства в предыдущих периодах. Данная сумма вычитается из премии Директора
Агентства за продажи агентов и менеджеров, прикрепленных к агентству, за период
с </span></span><span style='mso-bookmark:canceled_1'><span style='mso-ansi-language:
RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'>  </span>по<span
style='mso-spacerun:yes'>  </span><%=DATE_END%></span></span><span
style='mso-bookmark:canceled_1'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>. <o:p></o:p></span></span></p>

<div align=center>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=536
 style='width:401.9pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 0cm 0cm 0cm;mso-border-insideh:.5pt solid windowtext;
 mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:10.35pt'>
  <td width=96 rowspan=2 style='width:71.95pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_1'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер
  договора<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=143 rowspan=2 style='width:107.1pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <h2><span style='mso-bookmark:canceled_1'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;layout-grid-mode:line'>Страхователь<o:p></o:p></span></span></h2>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=113 rowspan=2 style='width:3.0cm;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_1'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа
  страхования<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=80 rowspan=2 style='width:60.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_1'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год
  действия договора на момент расторжения<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=103 rowspan=2 style='width:77.6pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_1'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Сумма
  премии за продажи агентов и менеджеров, прикрепленных к агентству<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'><![if !supportMisalignedRows]>
  <td style='height:10.35pt;border:none' width=0 height=14></td>
  <![endif]></span>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
  <span style='mso-bookmark:canceled_1'><![if !supportMisalignedRows]>
  <td style='height:31.85pt;border:none' width=0 height=42></td>
  <![endif]></span>
 </tr>
 
<rw:foreach id="G_DOG_PREM_V" src="G_DOG_PREM"> 

<rw:getValue id="pol_num_prem_v" src="pol_num"/>
<rw:getValue id="strahov_name_prem_v" src="strahov_name"/>
<rw:getValue id="progr_prem_v" src="progr"/>
<rw:getValue id="god_dest_prem_v" src="god_dest"/>
<rw:getValue id="COMISSION_SUM_prem_v" src="COMISSION_SUM" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_prem_v" src="IS_BREAK"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_prem_v).doubleValue();%>
<%
if ( D_S_BREAK == 1) {

D_COMISSION_SUM = D_COMISSION_SUM - Double.valueOf(COMISSION_SUM_prem_v).doubleValue();
%>
 
 
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
  <td width=96 valign=bottom style='width:71.95pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'><span style='mso-bookmark:canceled_1'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_1'><span
  style='mso-ansi-language:RU'><o:p>
  <%=pol_num_prem_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=143 valign=bottom style='width:107.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_1'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_1'><span
  style='mso-ansi-language:RU'><o:p>
  <%=strahov_name_prem_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=113 valign=bottom style='width:3.0cm;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_1'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_1'><span
  style='mso-ansi-language:RU'><o:p>
  <%=progr_prem_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=80 valign=bottom style='width:60.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_1'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_1'><span
  style='mso-ansi-language:RU'><o:p>
  <%=god_dest_prem_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'></span>
  <td width=103 valign=bottom style='width:77.6pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_1'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_1'><span
  style='mso-ansi-language:RU'><o:p>
  <%=COMISSION_SUM_prem_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_1'><![if !supportMisalignedRows]>
  <td style='height:12.75pt;border:none' width=0 height=17></td>
  <![endif]></span>
 </tr>
  <%}%>
</rw:foreach> 
 
</table>

</div>

<span style='mso-bookmark:canceled_1'></span>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>3. Итого премия Директора Агентства
за продажи агентов и менеджеров, прикрепленных к агентству за период с <span
style='mso-spacerun:yes'> </span></span><a name="date_from_3"><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%></span></a><span style='mso-ansi-language:
RU'><span style='mso-spacerun:yes'>  </span>по<span style='mso-spacerun:yes'> 
</span><a name="date_to_3"><%=DATE_END%></a> <span
style='mso-spacerun:yes'> </span>составляет <span
style='mso-spacerun:yes'> </span><a name="main_commission"><%=format.format(D_COMISSION_SUM)%>.</a></span><span
style='mso-bookmark:main_commission'></span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'>II</span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>. Премия Директора Агентства за развитие директоров.<o:p></o:p></span></p>
<%
D_COMISSION_SUM_ALL = D_COMISSION_SUM;
D_COMISSION_SUM = 0;
%>
<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с <span
style='mso-spacerun:yes'> </span></span><span style='mso-ansi-language:RU'><%=DATE_BEGIN%><span
style='mso-spacerun:yes'>  </span>по<span style='mso-spacerun:yes'> 
</span><%=DATE_END%></span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'> Директор Агентства получает премию за продажи агентов группы,
прикрепленной к Директору Агентства,<span style='mso-spacerun:yes'>  </span>за
следующие договоры страхования, заключенные в результате выполнения агентами
группы обязанностей по агентскому договору:<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=668
 style='width:500.85pt;border-collapse:collapse;mso-padding-alt:0cm 0cm 0cm 0cm'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=80 rowspan=2 style='width:59.8pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=125 rowspan=2 style='width:93.95pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=131 rowspan=2 style='width:98.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=62 rowspan=2 style='width:46.35pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия договора<o:p></o:p></span></b></p>
   </td>
   <td width=60 rowspan=2 style='width:45.0pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
   </td>
   <td width=77 rowspan=2 style='width:57.95pt;border-top:solid windowtext 1.0pt;
   border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
   mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
   padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Уплаченная страховая премия, руб.<o:p></o:p></span></b></p>
   </td>
   <td width=133 colspan=2 style='width:99.6pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Премия за продажи агентов группы<o:p></o:p></span></b></p>
   </td>
  </tr>
  <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
   <td width=55 valign=bottom style='width:41.05pt;border:solid windowtext 1.0pt;
   border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В % от<span style='mso-spacerun:yes'> 
   </span>страховой премии<o:p></o:p></span></b></p>
   </td>
   <td width=78 valign=bottom style='width:58.55pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG_RAZV" src="G_DOG_RAZV"> 

<rw:getValue id="pol_num_razv" src="pol_num1"/>
<rw:getValue id="strahov_name_razv" src="strahov_name1"/>
<rw:getValue id="progr_razv" src="progr1"/>
<rw:getValue id="STATUS_MNG_razv" src="STATUS_MNG1"/>
<rw:getValue id="STRAHOV_NAME_MNG_razv" src="STRAHOV_NAME_MNG"/>
<rw:getValue id="god_razv" src="god1"/>
<rw:getValue id="SUM_PREMIUM_razv" src="SUM_PREMIUM1" formatMask="999999990.99"/>
<rw:getValue id="COMISSION_SUM_razv" src="COMISSION_SUM1" formatMask="999999990.99"/>
<rw:getValue id="percent_st_prm_razv" src="percent_st_prm1" formatMask="999999990.99%"/>
<rw:getValue id="IS_BREAK_razv" src="IS_BREAK1"/>

<%
D_COMISSION_SUM = D_COMISSION_SUM + Double.valueOf(COMISSION_SUM_razv).doubleValue();
%>

 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:12.75pt'>
  <td width=80 valign=top style='width:59.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-right-alt:solid windowtext .75pt;padding:0cm 0cm 0cm 0cm;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><a name="table_3"><span
  style='font-size:9.0pt'><span style='mso-spacerun:yes'> </span></span></a><span
  lang=EN-US style='font-size:9.0pt'><o:p>
  <%=pol_num_razv%>
  </o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_razv%>
  </o:p></span></p>
  </td>
  <td width=131 valign=top style='width:98.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_razv%>
  </o:p></span></p>
  </td>
  <td width=62 valign=top style='width:46.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=god_razv%>
  </o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  &nbsp;
  </o:p></span></p>
  </td>
  <td width=77 valign=top style='width:57.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=SUM_PREMIUM_razv%>
  </o:p></span></p>
  </td>
  <td width=55 valign=top style='width:41.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=percent_st_prm_razv%>
  </o:p></span></p>
  </td>
  <td width=78 valign=top style='width:58.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=COMISSION_SUM_razv%>
  </o:p></span></p>
  </td>
 </tr>
</rw:foreach> 

</table>
   
</div>

<%
D_COMISSION_SUM_ALL = D_COMISSION_SUM_ALL + D_COMISSION_SUM;
D_COMISSION_SUM = 0;
%>


<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'>II</span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>. Премия Директора Агентства за продажи группы агентов, прикрепленной к
Директору Агентства.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с <span
style='mso-spacerun:yes'> </span></span><a name="date_from_4"><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%></span></a><span style='mso-ansi-language:
RU'><span style='mso-spacerun:yes'>  </span>по<span style='mso-spacerun:yes'> 
</span><a name="date_to_4"><%=DATE_END%></a></span><span style='mso-bookmark:
date_to_4'></span><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'> Директор
Агентства получает премию за продажи агентов группы, прикрепленной к Директору
Агентства,<span style='mso-spacerun:yes'>  </span>за следующие договоры
страхования, заключенные в результате выполнения агентами группы обязанностей
по агентскому договору:<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=668
 style='width:500.85pt;border-collapse:collapse;mso-padding-alt:0cm 0cm 0cm 0cm'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=80 rowspan=2 style='width:59.8pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=125 rowspan=2 style='width:93.95pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=131 rowspan=2 style='width:98.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=62 rowspan=2 style='width:46.35pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия договора<o:p></o:p></span></b></p>
   </td>
   <td width=60 rowspan=2 style='width:45.0pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
   solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
   0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Дата оплаты<o:p></o:p></span></b></p>
   </td>
   <td width=77 rowspan=2 style='width:57.95pt;border-top:solid windowtext 1.0pt;
   border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
   mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
   padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Уплаченная страховая премия, руб.<o:p></o:p></span></b></p>
   </td>
   <td width=133 colspan=2 style='width:99.6pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Премия за продажи агентов группы<o:p></o:p></span></b></p>
   </td>
  </tr>
  <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
   <td width=55 valign=bottom style='width:41.05pt;border:solid windowtext 1.0pt;
   border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В % от<span style='mso-spacerun:yes'> 
   </span>страховой премии<o:p></o:p></span></b></p>
   </td>
   <td width=78 valign=bottom style='width:58.55pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:31.85pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG_PROD" src="G_DOG_PROD"> 

<rw:getValue id="pol_num_prod" src="pol_num2"/>
<rw:getValue id="strahov_name_prod" src="strahov_name2"/>
<rw:getValue id="progr_prod" src="progr2"/>
<rw:getValue id="STATUS_MNG_prod" src="STATUS_MNG2"/>
<rw:getValue id="god_prod" src="god2"/>
<rw:getValue id="SUM_PREMIUM_prod" src="SUM_PREMIUM2" formatMask="999999990.99"/>
<rw:getValue id="COMISSION_SUM_prod" src="COMISSION_SUM2" formatMask="999999990.99"/>
<rw:getValue id="percent_st_prm_prod" src="percent_st_prm2" formatMask="999999990.99%"/>
<rw:getValue id="IS_BREAK_prod" src="IS_BREAK2"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_prod).doubleValue();%>
<%
if ( D_S_BREAK == 0) {

D_COMISSION_SUM = D_COMISSION_SUM + Double.valueOf(COMISSION_SUM_prod).doubleValue();
%>
 
 
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:12.75pt'>
  <td width=80 valign=top style='width:59.8pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-right-alt:solid windowtext .75pt;padding:0cm 0cm 0cm 0cm;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><a name="table_2"><span
  style='font-size:9.0pt'><span style='mso-spacerun:yes'> </span></span></a><span
  lang=EN-US style='font-size:9.0pt'><o:p>
  <%=pol_num_prod%>
  </o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_prod%>
  </o:p></span></p>
  </td>
  <td width=131 valign=top style='width:98.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_prod%>
  </o:p></span></p>
  </td>
  <td width=62 valign=top style='width:46.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=god_prod%>
  </o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  &nbsp;
  </o:p></span></p>
  </td>
  <td width=77 valign=top style='width:57.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=SUM_PREMIUM_prod%>
  </o:p></span></p>
  </td>
  <td width=55 valign=top style='width:41.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:windowtext;mso-border-style-alt:
  solid;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=percent_st_prm_prod%>
  </o:p></span></p>
  </td>
  <td width=78 valign=top style='width:58.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  mso-border-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .75pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-ansi-language:RU'><o:p>
  <%=COMISSION_SUM_prod%>
  </o:p></span></p>
  </td>
 </tr>
   <%}%>
</rw:foreach> 

</table>

</div>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><a
name="canceled_2"><span style='mso-ansi-language:RU;layout-grid-mode:both'>2. </span></a><span
style='mso-bookmark:canceled_2'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>За период с </span></span><span style='mso-bookmark:canceled_2'><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span></span><span
style='mso-bookmark:canceled_2'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'> были расторгнуты следующие договоры страхования, заключенные <span
style='text-transform:uppercase'>Страховщиком</span> при посредничестве агентов
группы, прикрепленной к Директору Агентства, премия за продажи группы агентов,
прикрепленной к Директору Агентства по которым была выплачена Директору
Агентства в предыдущих периодах. Данная сумма вычитается из премии Директора
Агентства за продажи группы агентов, прикрепленной к Директору Агентства, за
период с </span></span><span style='mso-bookmark:canceled_2'><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span></span><span
style='mso-bookmark:canceled_2'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>. <o:p></o:p></span></span></p>

<div align=center>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=536
 style='width:401.9pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-padding-alt:0cm 0cm 0cm 0cm;mso-border-insideh:.5pt solid windowtext;
 mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:10.35pt'>
  <td width=96 rowspan=2 style='width:71.95pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_2'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер
  договора<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=143 rowspan=2 style='width:107.1pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <h2><span style='mso-bookmark:canceled_2'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;layout-grid-mode:line'>Страхователь<o:p></o:p></span></span></h2>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=113 rowspan=2 style='width:3.0cm;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_2'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа
  страхования<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=80 rowspan=2 style='width:60.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_2'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год
  действия договора на момент расторжения<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=103 rowspan=2 style='width:77.6pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:10.35pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:canceled_2'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Сумма
  премии менеджера за продажи агентов группы, выплаченной по договору
  страхования<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'><![if !supportMisalignedRows]>
  <td style='height:10.35pt;border:none' width=0 height=14></td>
  <![endif]></span>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
  <span style='mso-bookmark:canceled_2'><![if !supportMisalignedRows]>
  <td style='height:31.85pt;border:none' width=0 height=42></td>
  <![endif]></span>
 </tr>
 
 <rw:foreach id="G_DOG_PROD_V" src="G_DOG_PROD"> 

<rw:getValue id="pol_num_prod_v" src="pol_num2"/>
<rw:getValue id="strahov_name_prod_v" src="strahov_name2"/>
<rw:getValue id="progr_prod_v" src="progr2"/>
<rw:getValue id="god_dest_prod_v" src="god_dest2"/>
<rw:getValue id="COMISSION_SUM_prod_v" src="COMISSION_SUM2" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_prod_v" src="IS_BREAK2"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_prod_v).doubleValue();%>
<%
if ( D_S_BREAK == 1) {

D_COMISSION_SUM = D_COMISSION_SUM - Double.valueOf(COMISSION_SUM_prod_v).doubleValue();
%>

 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
  <td width=96 valign=bottom style='width:71.95pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'><span style='mso-bookmark:canceled_2'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_2'><span
  style='mso-ansi-language:RU'><o:p>
  <%=pol_num_prod_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=143 valign=bottom style='width:107.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_2'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_2'><span
  style='mso-ansi-language:RU'><o:p>
  <%=strahov_name_prod_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=113 valign=bottom style='width:3.0cm;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_2'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_2'><span
  style='mso-ansi-language:RU'><o:p>
  <%=progr_prod_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=80 valign=bottom style='width:60.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_2'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_2'><span
  style='mso-ansi-language:RU'><o:p>
  <%=god_dest_prod_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'></span>
  <td width=103 valign=bottom style='width:77.6pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'><span
  style='mso-bookmark:canceled_2'></span>
  <p class=MsoNormal><span style='mso-bookmark:canceled_2'><span
  style='mso-ansi-language:RU'><o:p>
  <%=COMISSION_SUM_prod_v%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:canceled_2'><![if !supportMisalignedRows]>
  <td style='height:12.75pt;border:none' width=0 height=17></td>
  <![endif]></span>
 </tr>
    <%}%>
</rw:foreach> 
 
</table>

</div>

<span style='mso-bookmark:canceled_2'></span>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>3. Итого премия Директора Агентства
за продажи группы агентов, прикрепленной к Директору Агентства за период с <span
style='mso-spacerun:yes'> </span></span><a name="date_from_5"><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%></span></a><span style='mso-ansi-language:
RU'><span style='mso-spacerun:yes'>  </span>по<span style='mso-spacerun:yes'> 
</span><a name="date_to_5"><%=DATE_END%></a> <span
style='mso-spacerun:yes'> </span>составляет <span
style='mso-spacerun:yes'> </span><a name="group_commission"><%=format.format(D_COMISSION_SUM)%>.</a></span><span
style='mso-bookmark:group_commission'></span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>
<%D_COMISSION_SUM_ALL = D_COMISSION_SUM_ALL + D_COMISSION_SUM;%>
<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'>III</span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>. <span style='mso-spacerun:yes'> </span>ИТОГО сумма премии,
выплачиваемой Директору Агентства, составляет <span
style='mso-spacerun:yes'> </span><a name="total_commission"><%=format.format(D_COMISSION_SUM_ALL)%></a><o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>С расчетом ознакомлен и согласен:<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='margin-left:5.4pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid;height:17.55pt'>
  <td width=276 valign=bottom style='width:207.0pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
  none;text-autospace:none'><a name=shortname><span lang=EN-US
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  layout-grid-mode:both'>&lt;</span></a><span style='mso-bookmark:shortname'><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU;layout-grid-mode:both'><%=AG_NAME_INITIAL%></span></span><span
  style='mso-bookmark:shortname'><span lang=EN-US style='font-family:"Times New Roman CYR";
  mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>&gt;</span></span><span
  style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
  mso-ansi-language:RU;layout-grid-mode:both'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>

</rw:report>
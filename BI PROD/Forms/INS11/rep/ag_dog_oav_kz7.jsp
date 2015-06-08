<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251"  %>
<%@ page import="java.text.*" %>

<%
  java.text.DecimalFormat format = new java.text.DecimalFormat("0.00");  
   
  double Double_COMISSION_SUM = 0;
  double Double_SUM_PREMIUM = 0;
  double Double_SUM_RETURN = 0;

  String NUM_CALL_CENTR= new String();  
  
  String strTMP = new String(""); 
  String strTMPZ = new String(""); 
        
  double row_cnt_ag = 0;  
  double row_cnt_zakl = 0;  
  double row_cnt_rost = 0;    
  double row_cnt_tot = 0;      

  double row_cnt_zakl_100 = 0;  
  double row_cnt_rost_100 = 0;    
  double row_cnt_tot_100 = 0;      

  double partAgent = 0;        
  double AV_SUM_1 = 0;          
  double AV_SUM_2 = 0;            
%>

<rw:report id="report" >  


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_oav_kz_model" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="AG_DOG_OAV" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_VEDOM_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AG_REP_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="long_name" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="short_name" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="dover" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT_REPORT">
      <select canParse="no">
      <![CDATA[SELECT count(1) over() row_cnt,
agr.agent_report_id, agch.ag_contract_header_id, agr.num act_num,
       agr.report_date, ved.date_begin, ved.date_end, con.contact_id,
       DECODE (dep.code, NULL, NULL, dep.code || '-') || agch.num dognum,
       ent.obj_name (con.ent_id, con.contact_id) agname,
       agr.av_sum, 
       dept_exe.contact_id dir_contact_id,       decode(vca.category_name,'Агент',agent_status.status_name,'Финансовый консультант') status_name,
       salchan.BRIEF salesChanel,
       pkg_contact.get_fio_fmt (ent.obj_name (con.ent_id, con.contact_id), 4 ) ag_name_initial,
       pkg_contact.get_fio_fmt (NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),'Смышляев Юрий Олегович'
           ), 4 ) dir_name_initial,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name_genitive, 
       NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),
            'Смышляев Юрий Олегович'
           ) dir_name
  FROM ven_agent_report agr JOIN ven_ag_vedom_av ved
       ON (agr.ag_vedom_av_id = ved.ag_vedom_av_id)
       JOIN ven_ag_contract_header agch
       ON (agch.ag_contract_header_id = agr.ag_contract_h_id)
       JOIN ven_t_sales_channel salchan
       ON (agch.T_SALES_CHANNEL_ID = salchan.id)        
       JOIN ven_contact con ON (agch.agent_id = con.contact_id)
       LEFT JOIN
       (SELECT CASE ac.brief
                  WHEN 'MN'
                     THEN 'Статус Менеджера'
                  ELSE sa.NAME
               END status_name,
               sh.ag_stat_hist_id
          FROM ven_ag_stat_hist sh,
               ven_ag_category_agent ac,
               ven_ag_stat_agent sa
         WHERE sh.ag_category_agent_id = ac.ag_category_agent_id
           AND sh.ag_category_agent_id = sa.ag_category_agent_id(+)
           AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status
       ON (agent_status.ag_stat_hist_id =
              pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id,ved.date_end)
          )
       LEFT OUTER JOIN ven_department dep 
       ON (agch.agency_id = dep.department_id )
       LEFT OUTER JOIN ven_dept_executive dept_exe 
       ON (agch.agency_id = dept_exe.department_id)
       LEFT OUTER JOIN ven_ag_category_agent vca 
        ON (vca.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, ved.date_end) )
  WHERE agr.AG_VEDOM_AV_ID = :p_vedom_id and agr.agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="2.56250" y="0.08337" width="1.19788" height="0.32983"/>
      <group name="G_AGENT_REPORT">
        <displayInfo x="2.06250" y="0.60413" width="2.03125" height="3.16504"
        />
        <dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="30" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="12" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="ROW_CNT" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="ROW_CNT" descriptiveExpression="ROW_CNT"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="AG_NAME_INITIAL" datatype="vchar2" columnOrder="28"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name Initial">
          <dataDescriptor expression="AG_NAME_INITIAL"
           descriptiveExpression="AG_NAME_INITIAL" order="15" width="4000"/>
        </dataItem>
        <dataItem name="SALESCHANEL" datatype="vchar2" columnOrder="24"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Saleschanel">
          <dataDescriptor expression="SALESCHANEL"
           descriptiveExpression="SALESCHANEL" order="14" width="100"/>
        </dataItem>
        <dataItem name="DIR_NAME_INITIAL" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Initial">
          <dataDescriptor expression="DIR_NAME_INITIAL"
           descriptiveExpression="DIR_NAME_INITIAL" order="16" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_GENITIVE" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Genitive">
          <dataDescriptor expression="DIR_NAME_GENITIVE"
           descriptiveExpression="DIR_NAME_GENITIVE" order="17" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="18" width="4000"/>
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
           order="9" width="201"/>
        </dataItem>
        <dataItem name="STATUS_NAME" datatype="vchar2" columnOrder="23"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name">
          <dataDescriptor expression="STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="13" width="250"/>
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
           order="10" width="4000"/>
        </dataItem>
        <dataItem name="AV_SUM" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Av Sum">
          <dataDescriptor expression="AV_SUM" descriptiveExpression="AV_SUM"
           order="11" oracleDatatype="number" width="22" scale="-127"/>
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
      <displayInfo x="0.54163" y="0.11462" width="0.69995" height="0.19995"/>
      <group name="G_ORG_CONT">
        <displayInfo x="0.14453" y="0.73962" width="1.49426" height="1.96875"
        />
        <dataItem name="company_name" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="chief_name" datatype="vchar2" columnOrder="32"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="inn" datatype="vchar2" columnOrder="33" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="kpp" datatype="vchar2" columnOrder="34" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="account_number" datatype="vchar2" columnOrder="35"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="36" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="b_bic" datatype="vchar2" columnOrder="37" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="b_kor_account" datatype="vchar2" columnOrder="38"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="legal_address" datatype="vchar2" columnOrder="39"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Legal Address">
          <dataDescriptor expression="org.legal_address"
           descriptiveExpression="LEGAL_ADDRESS" order="9" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AG_DOCS">
      <select>
      <![CDATA[SELECT   vcp.contact_id, tit.brief doc_desc, NVL (cci.serial_nr, '@') p_ser,
         NVL (cci.id_value, '@') p_num, NVL (cci.place_of_issue, '@') pvidan,
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
     AND UPPER (tit.brief) IN ('PASS_RF', 'INN', 'PENS')
ORDER BY NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC]]>
      </select>
      <displayInfo x="4.38562" y="0.17712" width="1.05212" height="0.32983"/>
      <group name="G_AG_DOCS">
        <displayInfo x="4.29517" y="0.78333" width="1.23376" height="1.28516"
        />
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="40"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.contact_id"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="41"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="42" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="43" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="44" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="45"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_ZAKL">
      <select>
      <![CDATA[ SELECT * from V_REPORT_OAV_DOG_ZAKL]]>
      </select>
      <displayInfo x="4.84277" y="2.98962" width="1.34375" height="0.32983"/>
      <group name="G_DOG_ZAKL">
        <displayInfo x="4.80383" y="3.38733" width="1.71301" height="1.79785"
        />
        <dataItem name="STATUS_NAME1" datatype="vchar2" columnOrder="57"
         width="4" defaultWidth="40000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Status Name1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="12" width="4"/>
        </dataItem>
        <dataItem name="ZAKL_ROW_CNT" oracleDatatype="number" columnOrder="56"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Zakl Row Cnt">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.ZAKL_ROW_CNT"
           descriptiveExpression="ZAKL_ROW_CNT" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PART_AGENT" oracleDatatype="number" columnOrder="55"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Part Agent">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.PART_AGENT"
           descriptiveExpression="PART_AGENT" order="7"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM" datatype="vchar2" columnOrder="47"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME" datatype="vchar2" columnOrder="48"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="PROGR" datatype="vchar2" columnOrder="49" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.PROGR"
           descriptiveExpression="PROGR" order="5" width="255"/>
        </dataItem>
        <dataItem name="STAVKA" oracleDatatype="number" columnOrder="50"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Stavka">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.STAVKA"
           descriptiveExpression="STAVKA" order="6" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD" oracleDatatype="number" columnOrder="51"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.GOD"
           descriptiveExpression="GOD" order="8" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DATE_PAY" datatype="date" oracleDatatype="date"
         columnOrder="52" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Pay">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.DATE_PAY"
           descriptiveExpression="DATE_PAY" order="9" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="SUM_PREMIUM" oracleDatatype="number" columnOrder="53"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="10"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM" oracleDatatype="number"
         columnOrder="54" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="11"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID1" oracleDatatype="number"
         columnOrder="46" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ZAKL.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_ROST">
      <select>
      <![CDATA[SELECT * from V_REPORT_OAV_DOG_ROST]]>
      </select>
      <displayInfo x="4.84387" y="5.28113" width="1.22913" height="0.32983"/>
      <group name="G_DOG_ROST">
        <displayInfo x="4.65942" y="5.85620" width="1.58032" height="1.45605"
        />
        <dataItem name="STATUS_NAME3" datatype="vchar2" columnOrder="67"
         width="4" defaultWidth="40000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Status Name3">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="10" width="4"/>
        </dataItem>
        <dataItem name="ROST_ROW_CNT" oracleDatatype="number" columnOrder="66"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Rost Row Cnt">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.ROST_ROW_CNT"
           descriptiveExpression="ROST_ROW_CNT" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PART_AGENT2" oracleDatatype="number" columnOrder="65"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Part Agent2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.PART_AGENT"
           descriptiveExpression="PART_AGENT" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID2" oracleDatatype="number"
         columnOrder="58" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM1" datatype="vchar2" columnOrder="59"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME1" datatype="vchar2" columnOrder="60"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="PROGR1" datatype="vchar2" columnOrder="61" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.PROGR"
           descriptiveExpression="PROGR" order="5" width="255"/>
        </dataItem>
        <dataItem name="GOD1" oracleDatatype="number" columnOrder="62"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.GOD"
           descriptiveExpression="GOD" order="7" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM1" oracleDatatype="number"
         columnOrder="63" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="8"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="SUM_RETURN" oracleDatatype="number" columnOrder="64"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Return">
          <dataDescriptor expression="V_REPORT_OAV_DOG_ROST.SUM_RETURN"
           descriptiveExpression="SUM_RETURN" order="9"
           oracleDatatype="number" width="22" scale="-127"/>
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
      <displayInfo x="6.14587" y="1.54175" width="1.03113" height="0.32983"/>
      <group name="G_AGENT_ADDR">
        <displayInfo x="6.03552" y="2.08545" width="1.23376" height="0.77246"
        />
        <dataItem name="pref" datatype="vchar2" columnOrder="68"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pref">
          <dataDescriptor
           expression="DECODE ( brief , &apos;CONST&apos; , &apos;прописки&apos; , &apos;проживания&apos; )"
           descriptiveExpression="PREF" order="1" width="10"/>
        </dataItem>
        <dataItem name="contact_id2" oracleDatatype="number" columnOrder="69"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id2">
          <dataDescriptor expression="ca.contact_id"
           descriptiveExpression="CONTACT_ID" order="2" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="addr" datatype="vchar2" columnOrder="70" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor expression="pkg_contact.get_address_name ( a.ID )"
           descriptiveExpression="ADDR" order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG_ZAKL_TOT">
      <select>
      <![CDATA[SELECT * from V_REPORT_OAV_DOG_TOT]]>
      </select>
      <displayInfo x="2.91675" y="4.79102" width="1.44788" height="0.34583"/>
      <group name="G_DOG_ZAKL_TOT">
        <displayInfo x="2.76392" y="5.41663" width="1.71301" height="1.79785"
        />
        <dataItem name="STATUS_NAME2" datatype="vchar2" columnOrder="82"
         width="4" defaultWidth="40000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Status Name2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="12" width="4"/>
        </dataItem>
        <dataItem name="ROW_CNT_TOT" oracleDatatype="number" columnOrder="81"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt Tot">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.ROW_CNT_TOT"
           descriptiveExpression="ROW_CNT_TOT" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PART_AGENT1" oracleDatatype="number" columnOrder="80"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Part Agent1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.PART_AGENT"
           descriptiveExpression="PART_AGENT" order="11"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID3" oracleDatatype="number"
         columnOrder="71" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id3">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM2" datatype="vchar2" columnOrder="72"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.POL_NUM"
           descriptiveExpression="POL_NUM" order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME2" datatype="vchar2" columnOrder="73"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
        </dataItem>
        <dataItem name="PROGR2" datatype="vchar2" columnOrder="74" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.PROGR"
           descriptiveExpression="PROGR" order="5" width="255"/>
        </dataItem>
        <dataItem name="STAVKA1" oracleDatatype="number" columnOrder="75"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Stavka1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.STAVKA"
           descriptiveExpression="STAVKA" order="6" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="GOD2" oracleDatatype="number" columnOrder="76"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="God2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.GOD"
           descriptiveExpression="GOD" order="7" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DATE_PAY1" datatype="date" oracleDatatype="date"
         columnOrder="77" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Pay1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.DATE_PAY"
           descriptiveExpression="DATE_PAY" order="8" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="SUM_PREMIUM1" oracleDatatype="number" columnOrder="78"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium1">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="9"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="COMISSION_SUM2" oracleDatatype="number"
         columnOrder="79" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum2">
          <dataDescriptor expression="V_REPORT_OAV_DOG_TOT.COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="10"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_NUM_CALL_CENTR">
      <select canParse="no">
      <![CDATA[ select ah.ag_contract_header_id, ah.num||'/'||ac.num num_call_centr
 from ven_ag_contract_header ah
 join ven_ag_contract ac on (ac.contract_id=ah.ag_contract_header_id) -- все версии по договору
 where exists  (select '1' from ven_ag_contract_header h, ven_ag_contract c
                where c.ag_contract_id=h.last_ver_id -- по последней (действующей) версии
                and h.ag_contract_templ_k=2 -- шаблон версии
                and h.templ_brief = 'Call-Center' --соглашения с кол-центром
                and h.ag_contract_header_id=ac.ag_contract_templ_id -- шаблон использован в искомых договорах
                )]]>
      </select>
      <displayInfo x="0.38538" y="4.63550" width="1.65625" height="0.32983"/>
      <group name="G_NUM_CALL_CENTR">
        <displayInfo x="0.16028" y="5.47083" width="2.17126" height="0.60156"
        />
        <dataItem name="AG_CONTRACT_HEADER_ID1" oracleDatatype="number"
         columnOrder="83" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id1">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="NUM_CALL_CENTR" datatype="vchar2" columnOrder="84"
         width="201" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Num Call Centr">
          <dataDescriptor expression="NUM_CALL_CENTR"
           descriptiveExpression="NUM_CALL_CENTR" order="2" width="201"/>
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
      <displayInfo x="0.62500" y="3.48962" width="0.69995" height="0.32983"/>
      <group name="G_DIR_DOCS">
        <displayInfo x="0.28516" y="4.18958" width="1.37964" height="1.28516"
        />
        <dataItem name="CONTACT_ID3" oracleDatatype="number" columnOrder="85"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id3">
          <dataDescriptor expression="vcp.CONTACT_ID"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc1" datatype="vchar2" columnOrder="86"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc1">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser1" datatype="vchar2" columnOrder="87" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser1">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num1" datatype="vchar2" columnOrder="88" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num1">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan1" datatype="vchar2" columnOrder="89"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pvidan1">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v1" datatype="vchar2" columnOrder="90"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V1">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT_REPORT" parentColumn="CONTACT_ID"
     childQuery="Q_AG_DOCS" childColumn="contact_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_AGENT_REPORT"
     parentColumn="AGENT_REPORT_ID" childQuery="Q_DOG_ZAKL"
     childColumn="AGENT_REPORT_ID1" condition="eq" sqlClause="where"/>
    <link name="L_3" parentGroup="G_AGENT_REPORT"
     parentColumn="AGENT_REPORT_ID" childQuery="Q_DOG_ROST"
     childColumn="AGENT_REPORT_ID2" condition="eq" sqlClause="where"/>
    <link name="L_4" parentGroup="G_AGENT_REPORT" parentColumn="CONTACT_ID"
     childQuery="Q_AGENT_ADDR" childColumn="contact_id2" condition="eq"
     sqlClause="where"/>
    <link name="L_5" parentGroup="G_AGENT_REPORT"
     parentColumn="AGENT_REPORT_ID" childQuery="Q_DOG_ZAKL_TOT"
     childColumn="AGENT_REPORT_ID3" condition="eq" sqlClause="where"/>
    <link name="L_6" parentGroup="G_AGENT_REPORT"
     parentColumn="AGENT_REPORT_ID" childQuery="Q_NUM_CALL_CENTR"
     childColumn="AG_CONTRACT_HEADER_ID1" condition="eq" sqlClause="where"/>
    <link name="L_7" parentGroup="G_AGENT_REPORT"
     parentColumn="DIR_CONTACT_ID" childQuery="Q_DIR_DOCS"
     childColumn="CONTACT_ID3" condition="eq" sqlClause="where"/>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  PKG_REP_UTILS2.iSetVal('P_AG_REP_ID',:P_AG_REP_ID);
  
  begin
  select decode(upper(uu.sys_user_name),'YPLATOVA','Платовой Юлии Игоревны',
  									    'RVAGAPOV','Вагапова Раиля Рафиковича',
										'VESELEK','Веселухи Екатерины Владимировны',
										'TKIM','Ким Татьяны Ивановны',
										''),
		 decode(upper(uu.sys_user_name),'YPLATOVA','Платова Ю.И.',
  									    'RVAGAPOV','Вагапов Р.Р.',
										'VESELEK','Веселуха Е.В.',
										'TKIM','Ким Т.И.',
										''),
	     decode(upper(uu.sys_user_name),'YPLATOVA','Доверенности № 2009/245, выданной 01 февраля 2009 года',
  									    'RVAGAPOV','Доверенности № 2009/244, выданной 01 февраля 2009 года',
										'VESELEK','Доверенности № 2009/245, выданной 01 февраля 2009 года',
										'TKIM','Доверенности № 2009/252, выданной 11 января 2009 года',
										'')
  into :long_name,:short_name,:dover
  from sys_user uu 
  where upper(uu.sys_user_name) = upper(USER);
  exception
    when no_data_found then :long_name := ''; :short_name := ''; :dover := '';    
  end;
    
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
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="ag_dog_oav.files/filelist.xml">
<title>ОТЧЕТ АГЕНТА № ОАВ-__</title>
<!--[if gte mso 9]><xml>
</xml><![endif]--><!--[if gte mso 9]><xml>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
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
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	layout-grid-mode:line;}
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
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:70.85pt;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:0in;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	layout-grid-mode:line;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.25in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	layout-grid-mode:line;}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
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
	{size:595.3pt 841.9pt;
	margin:26.95pt 42.5pt 27.0pt .5in;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:26.95pt 42.5pt 27.0pt .5in;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section2
	{page:Section2;}

 /* List Definitions */
 @list l0
	{mso-list-id:131220508;
	mso-list-type:hybrid;
	mso-list-template-ids:1908572790 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l0:level1
	{mso-level-tab-stop:27.0pt;
	mso-level-number-position:left;
	margin-left:27.0pt;
	text-indent:-.25in;}
@list l1
	{mso-list-id:969628906;
	mso-list-type:hybrid;
	mso-list-template-ids:-801358350 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l1:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l2
	{mso-list-id:1082602987;
	mso-list-type:hybrid;
	mso-list-template-ids:-696759816 -1 -1 -1 -1 -1 -1 -1 -1 -1;}
@list l2:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
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
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l3:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	margin-left:.5in;
	text-indent:-.5in;}
@list l3:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l3:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:.75in;
	mso-level-number-position:left;
	margin-left:.75in;
	text-indent:-.75in;}
@list l3:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l3:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	margin-left:1.0in;
	text-indent:-1.0in;}
@list l3:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:1.25in;
	mso-level-number-position:left;
	margin-left:1.25in;
	text-indent:-1.25in;}
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
</style>
<![endif]-->
</head>

<body lang=EN-US style='tab-interval:35.4pt'>
<rw:foreach id="G_AGENT_REPORT" src="G_AGENT_REPORT">
<rw:getValue id="AGNAME" src="AGNAME"/>
<rw:getValue id="ACT_NUM" src="ACT_NUM"/>
<rw:getValue id="STATUS_NAME" src="STATUS_NAME"/>
<rw:getValue id="AGDOGNUM" src="DOGNUM"/>
  
<rw:getValue id="CHIEF_NAME_GEN" src="dir_name_genitive"/>
<rw:getValue id="DIR_NAME" src="dir_name"/>
<rw:getValue id="DIR_NAME_INITIAL" src="dir_name_initial"/>
<rw:getValue id="AG_NAME_INITIAL" src="ag_name_initial"/>

<rw:getValue id="salesChanel" src="salesChanel"/>

<rw:getValue id="REPORT_DATE" src="REPORT_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_END" src="DATE_END" formatMask="DD.MM.YYYY"/>
<rw:getValue id="AV_SUM" src="AV_SUM" formatMask="999999990.99"/>

<rw:getValue id="F_row_cnt_ag" src="row_cnt"/>

<%row_cnt_ag = Double.valueOf(F_row_cnt_ag).doubleValue();%>

<rw:foreach id="G_DOG_ZAKL_C" src="G_DOG_ZAKL">
 <rw:getValue id="F_zakl_row_cnt" src="zakl_row_cnt"/>
 <rw:getValue id="F_zakl_PART_AGENT" src="PART_AGENT"/> 
   <%row_cnt_zakl = Double.valueOf(F_zakl_row_cnt).doubleValue();
     if ( Double.valueOf(F_zakl_PART_AGENT).doubleValue() < 100 )
        row_cnt_zakl_100 = row_cnt_zakl_100 + 1;%>
</rw:foreach>

<rw:foreach id="G_DOG_ROST_C" src="G_DOG_ROST">
 <rw:getValue id="F_rost_row_cnt" src="rost_row_cnt"/>
   <%row_cnt_rost = Double.valueOf(F_rost_row_cnt).doubleValue();%> 
 <rw:getValue id="F_rost_PART_AGENT" src="PART_AGENT2"/> 
     <%if ( Double.valueOf(F_rost_PART_AGENT).doubleValue() < 100 )
        row_cnt_rost_100 = row_cnt_rost_100 + 1;%>
   
</rw:foreach>

<rw:foreach id="G_DOG_ZAKL_TOT_C" src="G_DOG_ZAKL_TOT">
 <rw:getValue id="F_row_cnt_tot" src="row_cnt_tot"/>
   <%row_cnt_tot = Double.valueOf(F_row_cnt_tot).doubleValue();%> 
 <rw:getValue id="F_tot_PART_AGENT" src="PART_AGENT1"/> 
     <%if ( Double.valueOf(F_tot_PART_AGENT).doubleValue() < 100 )
        row_cnt_tot_100 = row_cnt_tot_100 + 1;%>
   
</rw:foreach>

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

String PNUM_DOC_DIR = new String("____________");
String DATAV_DOC_DIR = new String("__________");

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

if (STATUS_NAME != null) 
   if (STATUS_NAME.equals("")) STATUS_NAME = "____________________________";

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


<rw:foreach id="G_NUM_CALL_CENTR" src="G_NUM_CALL_CENTR">
 <rw:getValue id="NUM_CALL_CENTR_D" src="NUM_CALL_CENTR"/>
   <%NUM_CALL_CENTR = NUM_CALL_CENTR_D;%> 
</rw:foreach>

 <% if (NUM_CALL_CENTR.equals("")) NUM_CALL_CENTR = "_____";%>
 

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
if (docBrief.equals("INN")) { %>
<rw:getValue id="P_NUM1" src="P_NUM"/>
<%AGINN = P_NUM1;}%>
<% if (docBrief.equals("PENS")) { %>
<rw:getValue id="P_NUM2" src="P_NUM"/>
<%PENS = P_NUM2;}%>
</rw:foreach>

    <rw:foreach id="gaddr" src="G_AGENT_ADDR">
     <rw:getValue id="pref" src="PREF"/> 
     <% if (pref.equals("прописки") ) {
     %>
          <rw:getValue id="addrProp_temp" src="ADDR"/>      
     <%
     addrProp = addrProp_temp;
     } else {
     %>
          <rw:getValue id="addrProz_temp" src="ADDR"/> 
     <%
        if (addrProz_temp != null) {
          addrProz_temp.trim();
        
          if ( !addrProz_temp.equals(addrProp) && !addrProz_temp.equals("")) 
             addrProz = addrProz_temp;
        }             
     %>
     <%}%>
    </rw:foreach>

<rw:foreach id="gorg" src="G_ORG_CONT">
  <rw:getValue id="COMPANY_NAME" src="COMPANY_NAME"/>
  <rw:getValue id="CHIEF_NAME1" src="CHIEF_NAME"/>
  <rw:getValue id="INN" src="INN"/>
  <rw:getValue id="KPP" src="KPP"/>
  <rw:getValue id="ACCOUNT_NUMBER" src="ACCOUNT_NUMBER"/>
  <rw:getValue id="BANK" src="BANK"/>
  <rw:getValue id="B_BIC" src="B_BIC"/>
  <rw:getValue id="B_KOR_ACCOUNT" src="B_KOR_ACCOUNT"/>
  <rw:getValue id="LEGAL_ADDRESS" src="LEGAL_ADDRESS"/>
  
<% 
ORGNAME  = COMPANY_NAME;
CHIEF_NAME = CHIEF_NAME1;
ORGINN 	 = INN;
ORGKPP   = KPP; 	
ORGRS    = ACCOUNT_NUMBER;	
ORGBANK	 = BANK;
ORGBBIC  = B_BIC; 
ORGKORAC = B_KOR_ACCOUNT;
ORGADDR  = LEGAL_ADDRESS;
%>
</rw:foreach>

<div class=Section1>

<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
<p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА № ОАВ-<%=ACT_NUM%> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>к
Агентскому договору № <%=AGDOGNUM%><o:p></o:p></span></b></p>

<table width="100%" height="30" border=0 cellpadding=0 cellspacing=0 class=MsoNormalTable
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
    height:4.0pt'>
    <td width="50%" height="30" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
      <o:p></o:p></span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'><p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><o:p></o:p></span>
	<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><%=DATE_END%></span></p>
    </td>
   </tr>
  </table>

<p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период <span
class=GramE>с</span> <%=DATE_BEGIN%> <span
style='mso-spacerun:yes'> </span>по <span style='mso-spacerun:yes'> </span><%=DATE_END%> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:0in'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=ORGNAME%>,
именуемое в дальнейшем Страховщик, в лице <rw:field id="" src="long_name"/>, действующего на основании <rw:field id="" src="dover"/>,
с одной стороны, и <%=AGNAME%>, паспорт серии <%=PS%> № <%=PNUM%>, именуемы<span
class=GramE>й(</span><span class=SpellE>ая</span>) в дальнейшем АГЕНТ, с другой
стороны, составили и утвердили настоящий отчет к Агентскому соглашению о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>1. За период <span class=GramE>с</span>
<span class=GramE><span style='mso-bookmark:date_from_1'><%=DATE_BEGIN%></span></span>
 по <%=DATE_END%>
при посредничестве Агента были заключены следующие договоры страхования, по
которым на расчетный счет страховщика поступила страховая премия в полном
объеме:<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=20% style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=20% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
          <o:p></o:p></span></b></p>    </td>
    </tr>
   <rw:foreach id="G_DOG_ZAKL_TOT_5" src="G_DOG_ZAKL_TOT">
    <rw:getValue id="F_PART_AGENT1_TOT1" src="PART_AGENT1"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_TOT1).doubleValue(); 
    if ( ( (! salesChanel.equals("CC")) && (partAgent == 100) ) || (salesChanel.equals("CC")))   {%>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom align="center" style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_POL_NUM2" src="POL_NUM2" > &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=20% valign=bottom align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME2" src="STRAHOV_NAME2"> &Field </rw:field>
	</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR2" src="PROGR2"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD2" src="GOD2"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_DATE_PAY2" src="DATE_PAY1" formatMask="DD.MM.YYYY"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom align="center" style='border:none;border-bottom:
    solid windowtext 1.0pt;border-left:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;bomso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_PREMIUM2" src="SUM_PREMIUM1" formatMask="999999990.99"> &Field </rw:field>
        <rw:getValue id="F_COMISSION_SUM2_1" src="COMISSION_SUM2" formatMask="999999990.99"/>
     
      <%
      strTMP = F_COMISSION_SUM2_1.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      AV_SUM_1 = AV_SUM_1 + Double.parseDouble(strTMP);
      %>                  

	</o:p></span></p>    </td>
    </tr>
    <%}%>
	</rw:foreach>
  </table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=left style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. Основное агентское
вознаграждение за отчетный период составляет: <%=format.format(AV_SUM_1)%> рублей.
Расчет агентского вознаграждения прилагается к настоящему отчету.</span></p>


<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt; height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>  <rw:field id="" src="short_name"/>
    </span><o:p></o:p></span></p>  </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;  height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:36.8pt;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><span
    style='mso-ansi-language:EN-US'><%=AG_NAME_INITIAL%></span><span lang=RU
    ><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
</td>
</tr>
</table>

</div>

<div class="Section2">

<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br
clear=all style='mso-special-character:line-break;page-break-before:always'>
</span>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>


<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Расчет основного агентского вознаграждения к отчету  <span
style='text-transform:uppercase'>Агента</span> <span class=GramE>от</span> 
<%=REPORT_DATE%> к Агентскому договору № <%=AGDOGNUM%>.<o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>Основное агентское вознаграждение выплачивается в соответствии с
условиями агентского договора № <%=AGDOGNUM%>.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:.25in;
mso-list:l1 level1 lfo2;tab-stops:list 0in;mso-layout-grid-align:none;
text-autospace:none'><![if !supportLists]><span lang=RU style='font-family:
"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";mso-ansi-language:
RU;layout-grid-mode:both'><span style='mso-list:Ignore'>1.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>За период <span class=GramE>с</span>
<span class=GramE><span style='mso-bookmark:date_from_2'><%=DATE_BEGIN%></span></span> по <%=DATE_END%>
АГЕНТ, имеющий на указанный период статус <span
style='mso-spacerun:yes'> </span><%=STATUS_NAME%><span
style='mso-bookmark:agent_status'></span>, получает основное агентское
вознаграждение за следующие договоры страхования, заключенные в результате
выполнения АГЕНТОМ обязанностей по агентскому договору:<o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>
    </td>
    <td width=15% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь
      <o:p></o:p></span></b></p>
    </td>
    <td width=15% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>
    </td>
	<td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Ставка агента на момент заключения
    договора страхования (САВ1, САВ2, САВ3, САВ4)
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% rowspan=2 style='border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
          <o:p></o:p></span></b></p>
    </td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от премии
      <o:p></o:p></span></b></p>
    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>
    </td>
   </tr>
   <rw:foreach id="G_DOG_ZAKL" src="G_DOG_ZAKL">
    <rw:getValue id="F_PART_AGENT1_ZAKL1" src="PART_AGENT"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_ZAKL1).doubleValue(); 
    if ( ( (! salesChanel.equals("CC")) && (partAgent == 100) ) || (salesChanel.equals("CC")))   {%>
   <rw:getValue id="SUM_PREMIUM" src="SUM_PREMIUM" formatMask="999999990.99"/>
   <rw:getValue id="COMISSION_SUM" src="COMISSION_SUM" formatMask="999999990.99"/>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign="middle" align="center" style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'>
	<o:p><rw:field id="F_POL_NUM" src="POL_NUM"> &Field </rw:field></o:p></span></p>
    </td>
    <td width=15% valign="middle" align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME" src="STRAHOV_NAME"> &Field </rw:field>
	</o:p>
    </span></p>
    </td>
    <td width=15% valign="middle" align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR" src="PROGR"> &Field </rw:field>
	</o:p></span> </p>
    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_status_name1" src="status_name1"> &Field </rw:field>
	</o:p></span> </p>
    </td>

    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD" src="GOD"> &Field </rw:field>
	</o:p></span></p>
    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_DATE_PAY" src="DATE_PAY" formatMask="DD.MM.YYYY"> &Field </rw:field>
	</o:p></span></p>
    </td>
    <td width=10% valign="middle" align="center" style='border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_PREMIUM" src="SUM_PREMIUM" formatMask="999999990.99"> &Field </rw:field>
      
	</o:p></span></p>
    </td>
    <td width=10% valign="middle" align="center" style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
    <% 

      strTMP = SUM_PREMIUM.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      Double_SUM_PREMIUM = Double.valueOf(strTMP).doubleValue();

      strTMP = COMISSION_SUM.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      Double_COMISSION_SUM = Double.valueOf(strTMP).doubleValue();      

    %>
    <% if ( Double_SUM_PREMIUM != 0 ) {%>
    <%=format.format(Double_COMISSION_SUM * 100 / Double_SUM_PREMIUM)%><%}%>
    </o:p></span></p>
    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_COMISSION_SUM" src="COMISSION_SUM" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>
    </td>
   </tr>
   <%}%>
   </rw:foreach>
  </table>

</div>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:.25in;
mso-list:l1 level1 lfo2;tab-stops:list 0in;mso-layout-grid-align:none;
text-autospace:none'><a name=canceled><![if !supportLists]><span lang=RU
style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
mso-ansi-language:RU;layout-grid-mode:both'><span style='mso-list:Ignore'>2.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>За период </span></a><span
class=GramE><span style='mso-bookmark:canceled'><span lang=RU style='font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";mso-ansi-language:
RU;layout-grid-mode:both'>с</span></span></span><span style='mso-bookmark:canceled'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> <span
class=GramE><span style='mso-bookmark:date_from_3'><%=DATE_BEGIN%></span></span> по <%=DATE_END%>
были расторгнуты следующие договоры страхования, заключенные <span
style='text-transform:uppercase'>Страховщиком</span> при посредничестве <span
style='text-transform:uppercase'>Агента</span>. В соответствии <span
class=GramE>с</span> п. 2.24., 6.6., 6.7. Агентского договора, часть агентского
вознаграждения по этим договорам удержана из агентского вознаграждения Агента в
соответствии с таблицей, приведенной ниже.<o:p></o:p></span></span></p>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:canceled'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год действия договора на момент расторжения
          <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'> Сумма выплаченного по договору агентского вознаграждения
      <o:p></o:p></span></b></p></td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от суммы выплаченного АВ
      <o:p></o:p></span></b></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>    </td>
   </tr>
   <rw:foreach id="G_DOG_ROST" src="G_DOG_ROST">
      <rw:getValue id="F_PART_AGENT1_rost1" src="PART_AGENT2"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_rost1).doubleValue(); 
    if ( ( (! salesChanel.equals("CC")) && (partAgent == 100) ) || (salesChanel.equals("CC")))   {%>
    
   <rw:getValue id="COMISSION_SUM1" src="COMISSION_SUM1" formatMask="999999990.99"/>
   <rw:getValue id="SUM_RETURN" src="SUM_RETURN" formatMask="999999990.99"/>   
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_POL_NUM1" src="POL_NUM1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME1" src="STRAHOV_NAME1"> &Field </rw:field>
	</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR1" src="PROGR1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD1" src="GOD1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_COMISSION_SUM1" src="COMISSION_SUM1" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>    
    </td>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
    <% 
      Double_SUM_RETURN = Double.valueOf(SUM_RETURN).doubleValue();
      Double_COMISSION_SUM = Double.valueOf(COMISSION_SUM1).doubleValue();
    %>
        <% if ( Double_COMISSION_SUM != 0 ) {%>
    <%=format.format( Double_SUM_RETURN * 100 / Double_COMISSION_SUM)%><%}%>
    </o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_RETURN" src="SUM_RETURN" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>    </td>
   </tr>
   <%}%>
   </rw:foreach>
  </table>

</div>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:canceled'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<span style='mso-bookmark:canceled'></span>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<ol style='margin-top:0in' start=3 type=1>
 <li class=MsoNormal style='mso-list:l1 level1 lfo2;tab-stops:list .5in;
     mso-layout-grid-align:none;text-autospace:none'><span lang=RU
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU;layout-grid-mode:both'>Итого размер агентского
     вознаграждения за период <span class=GramE>с</span> <%=DATE_BEGIN%>
     по <%=DATE_END%> составляет: <%=format.format(AV_SUM_1)%> рублей</span>  <span class=GramE></span>
	 <span style='mso-bookmark:amount_1'></span><span
     lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:
     "Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'> <span
     style='mso-spacerun:yes'> </span><o:p></o:p></span></li>
 <li class=MsoNormal style='mso-list:l1 level1 lfo2;tab-stops:list .5in;
     mso-layout-grid-align:none;text-autospace:none'><span lang=RU
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU;layout-grid-mode:both'>Сумма агентского
     вознаграждения, указанная <span class=GramE>в</span> п. <a
     name="total_chapter">3</a>., определена правильно.<o:p></o:p></span></li>
</ol>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt; height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>  <rw:field id="" src="short_name"/>
    </span><o:p></o:p></span></p>  </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;  height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:36.8pt;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><span
    style='mso-ansi-language:EN-US'><%=AG_NAME_INITIAL%></span><span lang=RU
    ><o:p></o:p></span></p>
    </td>
   </tr>
  </table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:-23.2pt'><o:p>&nbsp;</o:p></p>
</td>
</tr>
</table>
 
 



















<% if ( salesChanel.equals("CC")){%>

<%} else {
 if ( (row_cnt_zakl_100 > 0) || (row_cnt_rost_100 > 0) || (row_cnt_tot_100 > 0))  {
%>
<span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA;layout-grid-mode:line'><br clear=all style='page-break-before:always;
mso-break-type:section-break'>
</span>

<div class=Section1>
<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
<p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА № ОАВ-<%=ACT_NUM%> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
к Дополнительному Соглашению №  <%=NUM_CALL_CENTR%> <o:p></o:p></span></b></p>
<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>к
Агентскому договору № <%=AGDOGNUM%><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
    height:4.0pt'>
    <td width="50%" height="42" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'><span
    lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman";
    font-weight:normal'>г. Москва</span><span lang=RU style='font-size:11.0pt;
    mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
      <o:p></o:p></span></p>
    <p class=FR1 align=left style='margin-top:0in;margin-right:70.5pt;
    margin-bottom:0in;margin-left:0in;margin-bottom:.0001pt;text-align:left;
    line-height:11.0pt;mso-line-height-rule:exactly;tab-stops:467.8pt'>&nbsp;</p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;
    height:4.0pt'><p class=FR1 align=right style='margin:0in;margin-bottom:.0001pt;
    text-align:right;line-height:11.0pt;mso-line-height-rule:exactly;
    tab-stops:467.8pt'><span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><o:p></o:p></span>
	<span lang=RU style='font-size:11.0pt;mso-bidi-font-size:
    10.0pt;font-family:"Times New Roman";font-weight:normal'><%=REPORT_DATE%></span></p>
    </td>
   </tr>
  </table>

<p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период <span
class=GramE>с</span> <%=DATE_BEGIN%> <span
style='mso-spacerun:yes'> </span>по <span style='mso-spacerun:yes'> </span><%=DATE_END%> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:0in'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=ORGNAME%>,
именуемое в дальнейшем Страховщик, в лице <rw:field id="" src="long_name"/>, действующего на основании <rw:field id="" src="dover"/>, с одной стороны, и <%=AGNAME%>, паспорт серии <%=PS%> № <%=PNUM%>, именуемы<span
class=GramE>й(</span><span class=SpellE>ая</span>) в дальнейшем АГЕНТ, с другой
стороны, составили и утвердили настоящий отчет к Агентскому соглашению о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>1. За период <span class=GramE>с</span>
<span class=GramE><span style='mso-bookmark:date_from_1'><%=DATE_BEGIN%></span></span>
 по <%=DATE_END%>
при посредничестве Агента были заключены следующие договоры страхования. 
По указанным договорам страхования на расчетный счет страховщика поступила страховая премия в полном объеме: <o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=20% style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=20% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>    </td>
    <td width=10% style='border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
          <o:p></o:p></span></b></p>    </td>
    </tr>
   <rw:foreach id="G_DOG_ZAKL_TOT2" src="G_DOG_ZAKL_TOT">
      <rw:getValue id="F_PART_AGENT1_2" src="PART_AGENT1"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_2).doubleValue(); 
     if (partAgent != 100) {%>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_POL_NUM2_2" src="POL_NUM2"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME2_2" src="STRAHOV_NAME2"> &Field </rw:field>
	</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR2_2" src="PROGR2"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD2_2" src="GOD2"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_DATE_PAY2_2" src="DATE_PAY1" formatMask="DD.MM.YYYY"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border:none;border-bottom:
    solid windowtext 1.0pt;border-left:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;bomso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal align=center><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_PREMIUM2_2" src="SUM_PREMIUM1" formatMask="999999990.99"> &Field </rw:field>
        <rw:getValue id="F_COMISSION_SUM2_2_1" src="COMISSION_SUM2" formatMask="999999990.99"/>      
      <%AV_SUM_2 = AV_SUM_2 + Double.valueOf(F_COMISSION_SUM2_2_1).doubleValue();%>                    
	</o:p></span></p>    </td>
    </tr>
<%}%>
	</rw:foreach>
  </table>

</div>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. Основное агентское
вознаграждение за отчетный период составляет: <%=format.format(AV_SUM_2)%> рублей.
Расчет агентского вознаграждения прилагается к настоящему отчету.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt; height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>  <rw:field id="" src="short_name"/>
    </span><o:p></o:p></span></p>  </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;  height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:36.8pt;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><span
    style='mso-ansi-language:EN-US'><%=AG_NAME_INITIAL%></span><span lang=RU
    ><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
</td>
</tr>
</table>

</div>

<span lang=RU style='font-size:11.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA;layout-grid-mode:line'><br clear=all style='page-break-before:always;
mso-break-type:section-break'>
</span>

<div class="Section2">
<table class=mainTable>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td class=mainTd>
<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'><br
clear=all style='mso-special-character:line-break;page-break-before:always'>
</span>

<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
Расчет основного агентского вознаграждения к отчету Агента от <%=REPORT_DATE%> 
к Дополнительному Соглашению № <%=NUM_CALL_CENTR%>  
к Агентскому договору № <%=AGDOGNUM%>
<o:p></o:p></span></b></p>
<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>Агентское вознаграждение выплачивается в соответствии с условиями Дополнительного соглашения № 
<№ ДС о работе с call-center> к Агентскому договору № 
<%=AGDOGNUM%>, а также условиями Агентского договора.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:.25in;
tab-stops:list 0in;mso-layout-grid-align:none;
text-autospace:none'><![if !supportLists]><span lang=RU style='font-family:
"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";mso-ansi-language:
RU;layout-grid-mode:both'><span style='mso-list:Ignore'>1.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>1. За период <span class=GramE>с</span>
<span class=GramE><span style='mso-bookmark:date_from_2'><%=DATE_BEGIN%></span></span> по <%=DATE_END%>
АГЕНТ, получает основное агентское
вознаграждение за следующие договоры страхования, заключенные при его посредничестве:<o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=15% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь
      <o:p></o:p></span></b></p>    </td>
    <td width=15% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
	<td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплачиваемый год действия
    договора
          <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты
      <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border-top:solid windowtext 1.0pt;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
    mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Уплаченная страховая
    премия, руб.
          <o:p></o:p></span></b></p>    </td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от премии
      <o:p></o:p></span></b></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>    </td>
   </tr>
   <rw:foreach id="G_DOG_ZAKL_2" src="G_DOG_ZAKL">
      <rw:getValue id="F_PART_AGENT1_ZAKL2" src="PART_AGENT"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_ZAKL2).doubleValue(); 
     if (partAgent != 100) {%>
   <rw:getValue id="SUM_PREMIUM_2" src="SUM_PREMIUM" formatMask="999999990.99"/>
   <rw:getValue id="COMISSION_SUM_2" src="COMISSION_SUM" formatMask="999999990.99"/>
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign="middle" align="center" style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'>
	<o:p><rw:field id="F_POL_NUM_2" src="POL_NUM"> &Field </rw:field></o:p></span></p>    </td>
    <td width=15% valign="middle" align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME_2" src="STRAHOV_NAME"> &Field </rw:field>
	</o:p>
    </span></p>    </td>
    <td width=15% valign="middle" align="center" style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR_2" src="PROGR"> &Field </rw:field>
	</o:p></span> </p>    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD_2" src="GOD"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_DATE_PAY_2" src="DATE_PAY"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign="middle" align="center" style='border:none;border-bottom:
    solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_PREMIUM_2" src="SUM_PREMIUM" formatMask="999999990.99"> &Field </rw:field>

	</o:p></span></p>    </td>
    <td width=10% valign="middle" align="center" style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
    <% 
      Double_SUM_PREMIUM = Double.valueOf(SUM_PREMIUM_2).doubleValue();
      Double_COMISSION_SUM = Double.valueOf(COMISSION_SUM_2).doubleValue();
    %>
        <% if ( Double_SUM_PREMIUM != 0 ) {%>
    <%=format.format(Double_COMISSION_SUM * 100 / Double_SUM_PREMIUM)%><%}%>
    </o:p></span></p>    </td>
    <td width=10% valign="middle" align="center" style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_COMISSION_SUM_2" src="COMISSION_SUM" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>    </td>
   </tr>
<%}%>
   </rw:foreach>
  </table>

</div>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:0in;text-align:justify;text-indent:.25in;
tab-stops:list 0in;mso-layout-grid-align:none;
text-autospace:none'><a name=canceled><![if !supportLists]><span lang=RU
style='font-family:"Times New Roman CYR";mso-fareast-font-family:"Times New Roman CYR";
mso-ansi-language:RU;layout-grid-mode:both'><span style='mso-list:Ignore'>2.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span></span><![endif]><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. За период </span></a><span
class=GramE><span style='mso-bookmark:canceled'><span lang=RU style='font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";mso-ansi-language:
RU;layout-grid-mode:both'>с</span></span></span><span style='mso-bookmark:canceled'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> <span
class=GramE><span style='mso-bookmark:date_from_3'><%=DATE_BEGIN%></span></span> по <%=DATE_END%>
были расторгнуты следующие договоры страхования, заключенные <span
style='text-transform:uppercase'>Страховщиком</span> при посредничестве <span
style='text-transform:uppercase'>Агента</span>. В соответствии с п. 6.4. Агентского договора, часть агентского вознаграждения по этим договорам удержана из агентского вознаграждения Агента в соответствии с таблицей, приведенной ниже</span></p>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:canceled'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<div align=center>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=100%
   style='border-collapse:collapse;mso-padding-alt:0in 0in 0in 0in'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора
      <o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='order:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>    </td>
    <td width=25% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования
      <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Год действия договора на момент расторжения
          <o:p></o:p></span></b></p>    </td>
    <td width=10% rowspan=2 style='border:solid windowtext 1.0pt;
    border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'> Сумма выплаченного по договору агентского вознаграждения
      <o:p></o:p></span></b></p></td>
    <td colspan=2 style='border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Агентское вознаграждение<o:p></o:p></span></b></p>    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:31.85pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:
    solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В % от суммы выплаченного АВ
      <o:p></o:p></span></b></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-alt:solid windowtext .5pt;padding:0in 0in 0in 0in;height:31.85pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
    mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>В рублях<o:p></o:p></span></b></p>    </td>
   </tr>
   <rw:foreach id="G_DOG_ROST_2" src="G_DOG_ROST">
      <rw:getValue id="F_PART_AGENT1_ROST2" src="PART_AGENT2"/>
         <% partAgent = Double.valueOf(F_PART_AGENT1_ROST2).doubleValue(); 
     if (partAgent != 100) {%>
   <rw:getValue id="COMISSION_SUM1_2" src="COMISSION_SUM1" formatMask="999999990.99"/>
   <rw:getValue id="SUM_RETURN_2" src="SUM_RETURN" formatMask="999999990.99"/>   
   <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;height:12.75pt'>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_POL_NUM1_2" src="POL_NUM1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_STRAHOV_NAME1_2" src="STRAHOV_NAME1"> &Field </rw:field>
	</o:p>
    </span></p>    </td>
    <td width=20% valign=bottom style='border-top:none;
    border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_PROGR1_2" src="PROGR1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_GOD1_2" src="GOD1"> &Field </rw:field>
	</o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_COMISSION_SUM1_2" src="COMISSION_SUM1" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>    
    </td>
    <td width=10% valign=bottom style='border:solid windowtext 1.0pt;
    border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
    <% 
      Double_SUM_RETURN = Double.valueOf(SUM_RETURN_2).doubleValue();
      Double_COMISSION_SUM = Double.valueOf(COMISSION_SUM1_2).doubleValue();
    %>
        <% if ( Double_COMISSION_SUM != 0 ) {%>
    <%=format.format( Double_SUM_RETURN * 100 / Double_COMISSION_SUM)%><%}%>
    </o:p></span></p>    </td>
    <td width=10% valign=bottom style='border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
    padding:0in 0in 0in 0in;height:12.75pt'>
    <p class=MsoNormal><span lang=RU style='mso-ansi-language:RU'><o:p>
	<rw:field id="F_SUM_RETURN_2" src="SUM_RETURN" formatMask="999999990.99"> &Field </rw:field>
	</o:p></span></p>    </td>
   </tr>
   <%}%>
   </rw:foreach>
  </table>

</div>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:canceled'><span lang=RU
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<span style='mso-bookmark:canceled'></span>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<ol style='margin-top:0in' start=3 type=1>
 <li class=MsoNormal style='tab-stops:list .5in;
     mso-layout-grid-align:none;text-autospace:none'><span lang=RU
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU;layout-grid-mode:both'>Итого размер агентского
     вознаграждения за период <span class=GramE>с</span> <%=DATE_BEGIN%>
     по <%=DATE_END%> составляет: <%=format.format(AV_SUM_2)%> рублей</span>  <span class=GramE></span>
	 <span style='mso-bookmark:amount_1'></span><span
     lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:
     "Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'> <span
     style='mso-spacerun:yes'> </span><o:p></o:p></span></li>
 <li class=MsoNormal style='tab-stops:list .5in;
     mso-layout-grid-align:none;text-autospace:none'><span lang=RU
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU;layout-grid-mode:both'>Сумма агентского
     вознаграждения, указанная <span class=GramE>в</span> п. <a
     name="total_chapter">3</a>., определена правильно.<o:p></o:p></span></li>
</ol>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:.25in;mso-layout-grid-align:none;
text-autospace:none'><span lang=RU style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
   style='border-collapse:collapse;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;page-break-inside:avoid'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>СТРАХОВЩИК</span></p>
    </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoBodyTextIndent align=center style='margin-left:0in;text-align:
    center;line-height:11.0pt;mso-line-height-rule:exactly'><span lang=RU>АГЕНТ</span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:71.6pt;page-break-inside:avoid'>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt; height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:.5in;text-indent:-.5in;line-height:11.0pt;
    mso-line-height-rule:exactly'><span class=SpellE>  <rw:field id="" src="short_name"/>
    </span><o:p></o:p></p>  </td>
    <td width="50%" valign=top style='padding:0in 5.4pt 0in 5.4pt;  height:71.6pt'>
    <p class=MsoBodyTextIndent align=center style='margin-top:0in;margin-right:0in; 
    margin-bottom:6.0pt;margin-left:36.8pt;text-indent:-36.8pt;
    line-height:11.0pt;mso-line-height-rule:exactly'><span
    style='mso-ansi-language:EN-US'><%=AG_NAME_INITIAL%></span><span lang=RU
    ><o:p></o:p></span></p>
    </td>
   </tr>
  </table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:-23.2pt'><o:p>&nbsp;</o:p></p>
</td>
</tr>
</table>
</div>
<%} }%>
</rw:foreach>
</body>

</html>


</rw:report>

<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  DecimalFormat format = new DecimalFormat("0.00");
  double SUM_SGP_1 = 0;
  double SUM_SGP_2 = 0;
  double SUM_SGP_3 = 0;
  double SUM_COM_1 = 0;
  double SUM_COM_2 = 0;
  double SUM_COM_3 = 0;
  double SUM_COM_4 = 0;
  double SUM_COM_5 = 0;
  double SUM_COM_ALL = 0;
  String SumStr = new String();  
  
  double D_S_BREAK = 0;  
  
  String strTMP = new String(""); 
  String strTMPZ = new String(""); 
  
%>

<rw:report id="report">  

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_dav_mng" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_DAV_MNG" xmlPrologType="text">
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
       ved.date_end + 15 report_date, ved.date_begin, ved.date_end, con.contact_id,
       agch.num dognum, ent.obj_name (con.ent_id, con.contact_id) agname,
       agr.av_sum, 
       dep.name name_dep,
       vca.category_name status_name,
       vca_n.category_name status_name_next,
       NVL (nvl((select genitive from contact where contact_id = con.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), con.contact_id)),
            '________________' ) ag_name_genitive ,
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
       JOIN ven_contact con ON (agch.agent_id = con.contact_id)
       LEFT OUTER JOIN ven_ag_category_agent vca 
        ON (vca.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, ved.date_end) )
       LEFT OUTER JOIN ven_ag_category_agent vca_n 
        ON (vca_n.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, ved.date_end+1) )
       LEFT OUTER JOIN ven_department dep 
       ON (agch.agency_id = dep.department_id )
       LEFT OUTER JOIN ven_dept_executive dept_exe 
       ON (agch.agency_id = dept_exe.department_id)
  WHERE agr.AG_VEDOM_AV_ID = :p_vedom_id and agr.agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="2.12500" y="0.08337" width="1.19788" height="0.32983"/>
      <group name="G_AGENT_REPORT">
        <displayInfo x="1.70825" y="0.65625" width="2.03125" height="3.50684"
        />
        <dataItem name="AG_NAME_GENITIVE" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name Genitive">
          <dataDescriptor expression="AG_NAME_GENITIVE"
           descriptiveExpression="AG_NAME_GENITIVE" order="15" width="4000"/>
        </dataItem>
        <dataItem name="NAME_DEP" datatype="vchar2" columnOrder="30"
         width="150" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Name Dep">
          <dataDescriptor expression="NAME_DEP"
           descriptiveExpression="NAME_DEP" order="12" width="150"/>
        </dataItem>
        <dataItem name="STATUS_NAME_NEXT" datatype="vchar2" columnOrder="29"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name Next">
          <dataDescriptor expression="STATUS_NAME_NEXT"
           descriptiveExpression="STATUS_NAME_NEXT" order="14" width="1024"/>
        </dataItem>
        <dataItem name="ROW_CNT" oracleDatatype="number" columnOrder="28"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="ROW_CNT" descriptiveExpression="ROW_CNT"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="AG_NAME_INITIAL" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Name Initial">
          <dataDescriptor expression="AG_NAME_INITIAL"
           descriptiveExpression="AG_NAME_INITIAL" order="16" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_INITIAL" datatype="vchar2" columnOrder="24"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Initial">
          <dataDescriptor expression="DIR_NAME_INITIAL"
           descriptiveExpression="DIR_NAME_INITIAL" order="17" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_GENITIVE" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Genitive">
          <dataDescriptor expression="DIR_NAME_GENITIVE"
           descriptiveExpression="DIR_NAME_GENITIVE" order="18" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="19" width="4000"/>
        </dataItem>
        <dataItem name="AG_CONTRACT_HEADER_ID" oracleDatatype="number"
         columnOrder="21" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="DOGNUM" datatype="vchar2" columnOrder="22" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dognum">
          <dataDescriptor expression="DOGNUM" descriptiveExpression="DOGNUM"
           order="9" width="100"/>
        </dataItem>
        <dataItem name="STATUS_NAME" datatype="vchar2" columnOrder="23"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name">
          <dataDescriptor expression="STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="13" width="1024"/>
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
        <dataItem name="company_name" datatype="vchar2" columnOrder="32"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="chief_name" datatype="vchar2" columnOrder="33"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="inn" datatype="vchar2" columnOrder="34" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="kpp" datatype="vchar2" columnOrder="35" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="account_number" datatype="vchar2" columnOrder="36"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="37" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="b_bic" datatype="vchar2" columnOrder="38" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="b_kor_account" datatype="vchar2" columnOrder="39"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="legal_address" datatype="vchar2" columnOrder="40"
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
      <displayInfo x="4.14600" y="0.14587" width="1.05212" height="0.32983"/>
      <group name="G_AG_DOCS">
        <displayInfo x="4.05554" y="0.72083" width="1.23376" height="1.28516"
        />
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="41"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.contact_id"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="42"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="43" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="44" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="45" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="46"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Data V">
          <dataDescriptor
           expression="DECODE ( TO_CHAR ( NVL ( cci.issue_date , TO_DATE ( &apos;01.01.1900&apos; , &apos;DD.MM.YYYY&apos; ) ) , &apos;DD.MM.YYYY&apos; ) , &apos;01.01.1900&apos; , &apos;@&apos; , TO_CHAR ( cci.issue_date , &apos;DD.MM.YYYY&apos; ) )"
           descriptiveExpression="DATA_V" order="6" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOG">
      <select canParse="no">
      <![CDATA[SELECT count(1) over() zakl_row_cnt,
agd.AGENT_REPORT_ID, pp.pol_ser || '-' || pp.pol_num pol_num, pi.contact_name strahov_name,
      get_first_pay_date(pi.policy_id) first_pay_date,       
       pt.DESCRIPTION pay_term,
       pp.NOTICE_DATE,
       nvl(ac.SGP,0) SGP,
       nvl(ac.SUM_PREMIUM,0) SUM_PREMIUM,
       nvl(agd.COMISSION_SUM,0) COMISSION_SUM,
       tp.DESCRIPTION product,
       vtct.BRIEF,
       plo.DESCRIPTION progr,       
       doc.GET_LAST_DOC_STATUS_BRIEF(agr.AG_CONTRACT_H_ID) status_BRIF,
       nvl(ac.IS_BREAK,0) IS_BREAK,
       ac.IS_INCLUDED
FROM ven_p_policy pp 
     JOIN ven_t_payment_terms pt ON  (pt.ID = pp.payment_term_id)     
     JOIN ven_p_pol_header ph ON (ph.policy_header_id = pp.pol_header_id)
     JOIN ven_t_product tp ON (tp.product_id = ph.product_id)
     JOIN ven_agent_report_dav_ct ac ON (ac.policy_id = pp.policy_id)
     JOIN ven_agent_report_dav agd ON (agd.agent_report_dav_id = ac.agent_report_dav_id)
     JOIN ven_agent_report agr ON (agr.agent_report_id = agd.agent_report_id)     
     JOIN V_T_PROD_COEF_TYPE vtct ON (vtct.T_PROD_COEF_TYPE_ID = agd.PROD_COEF_TYPE_ID)     
     JOIN v_pol_issuer pi ON (pi.policy_id = ac.policy_id)
     LEFT OUTER JOIN P_POLICY_AGENT_COM pac ON (ac.p_policy_agent_com_id =pac.p_policy_agent_com_id)
     LEFT OUTER JOIN ven_t_prod_line_option plo ON (pac.t_product_line_id=plo.product_line_id)
  WHERE agd.agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="6.72766" y="0.11450" width="1.34375" height="0.32983"/>
      <group name="G_DOG">
        <displayInfo x="6.54370" y="0.73999" width="1.71301" height="3.33594"
        />
        <dataItem name="SUM_PREMIUM" oracleDatatype="number" columnOrder="61"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sum Premium">
          <dataDescriptor expression="SUM_PREMIUM"
           descriptiveExpression="SUM_PREMIUM" order="9"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM" oracleDatatype="number"
         columnOrder="62" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Comission Sum">
          <dataDescriptor expression="COMISSION_SUM"
           descriptiveExpression="COMISSION_SUM" order="10"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="PROGR" datatype="vchar2" columnOrder="60" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr">
          <dataDescriptor expression="PROGR" descriptiveExpression="PROGR"
           order="13" width="255"/>
        </dataItem>
        <dataItem name="IS_BREAK" oracleDatatype="number" columnOrder="58"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break">
          <dataDescriptor expression="IS_BREAK"
           descriptiveExpression="IS_BREAK" order="15" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="IS_INCLUDED" oracleDatatype="number" columnOrder="59"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Included">
          <dataDescriptor expression="IS_INCLUDED"
           descriptiveExpression="IS_INCLUDED" order="16"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FIRST_PAY_DATE" datatype="date" oracleDatatype="date"
         columnOrder="51" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date">
          <dataDescriptor expression="FIRST_PAY_DATE"
           descriptiveExpression="FIRST_PAY_DATE" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="PAY_TERM" datatype="vchar2" columnOrder="52"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pay Term">
          <dataDescriptor expression="PAY_TERM"
           descriptiveExpression="PAY_TERM" order="6" width="500"/>
        </dataItem>
        <dataItem name="NOTICE_DATE" datatype="date" oracleDatatype="date"
         columnOrder="53" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date">
          <dataDescriptor expression="NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="SGP" oracleDatatype="number" columnOrder="54"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp">
          <dataDescriptor expression="SGP" descriptiveExpression="SGP"
           order="8" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="PRODUCT" datatype="vchar2" columnOrder="55"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product">
          <dataDescriptor expression="PRODUCT" descriptiveExpression="PRODUCT"
           order="11" width="255"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="56" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="12" width="30"/>
        </dataItem>
        <dataItem name="STATUS_BRIF" datatype="vchar2" columnOrder="57"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Brif">
          <dataDescriptor expression="STATUS_BRIF"
           descriptiveExpression="STATUS_BRIF" order="14" width="4000"/>
        </dataItem>
        <dataItem name="ZAKL_ROW_CNT" oracleDatatype="number" columnOrder="50"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Zakl Row Cnt">
          <dataDescriptor expression="ZAKL_ROW_CNT"
           descriptiveExpression="ZAKL_ROW_CNT" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="POL_NUM" datatype="vchar2" columnOrder="48"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="POL_NUM" descriptiveExpression="POL_NUM"
           order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME" datatype="vchar2" columnOrder="49"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name">
          <dataDescriptor expression="STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="4000"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID1" oracleDatatype="number"
         columnOrder="47" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Agent Report Id1">
          <dataDescriptor expression="AGENT_REPORT_ID"
           descriptiveExpression="AGENT_REPORT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_SUM">
      <select canParse="no">
      <![CDATA[select report.sgp_DPPM_line,
       report.sgp_DP_KV_MN_line,
       report.sgp_PREM_PLAN_MENG_line,
       report.sgp_opm_line,
       report.sgp_dppbb_line,
       report.COM_SUM_DPPM_line,
       report.COM_SUM_DP_KV_MN_line,
       report.COM_SUM_PREM_PLAN_MENG_line,
       report.COM_SUM_opm_line,
       report.COM_SUM_dppbb_line,
       
       pkg_utils.money2speech(report.COM_SUM_DPPM_line +
                              report.COM_SUM_DP_KV_MN_line +
                              report.COM_SUM_PREM_PLAN_MENG_line +
                              report.COM_SUM_opm_line +
                              report.COM_SUM_dppbb_line,
                              (select f.fund_id
                                 from fund f
                                where f.brief = 'RUR')) SUM_DOG_PR
-- выплата всегда в рублях!!!
  from (SELECT (case
                 when vtct.BRIEF = 'DPPM' then
                  spg.spg
                 else
                  0
               end) sgp_DPPM_line,
               (case
                 when vtct.BRIEF = 'DP_KV_MN' then
                  spg.spg
                 else
                  0
               end) sgp_DP_KV_MN_line,
               (case
                 when vtct.BRIEF = 'PREM_PLAN_MENG' then
                  spg.spg
                 else
                  0
               end) sgp_PREM_PLAN_MENG_line,
               (case
                 when vtct.BRIEF = 'ОПМ' then
                  spg.spg
                 else
                  0
               end) sgp_opm_line,
               (case
                 when vtct.BRIEF = 'ДППББ' then
                  spg.spg
                 else
                  0
               end) sgp_dppbb_line,
               
               (case
                 when vtct.BRIEF = 'DPPM' then
                  agd.COMISSION_SUM
                 else
                  0
               end) COM_SUM_DPPM_line,
               (case
                 when vtct.BRIEF = 'DP_KV_MN' then
                  agd.COMISSION_SUM
                 else
                  0
               end) COM_SUM_DP_KV_MN_line,
               (case
                 when vtct.BRIEF = 'PREM_PLAN_MENG' then
                  agd.COMISSION_SUM
                 else
                  0
               end) COM_SUM_PREM_PLAN_MENG_line,
               (case
                 when vtct.BRIEF = 'ОПМ' then
                  agd.COMISSION_SUM
                 else
                  0
               end) COM_SUM_opm_line,
               (case
                 when vtct.BRIEF = 'ДППББ' then
                  agd.COMISSION_SUM
                 else
                  0
               end) COM_SUM_dppbb_line
          FROM (select NVL(sum(ac.sgp),0) spg,
                       dav.agent_report_dav_id
                  from ven_agent_report_dav_ct ac,
                       ven_agent_report_dav    dav
                 where ac.agent_report_dav_id = dav.agent_report_dav_id
                   and dav.agent_report_id =  :P_AG_REP_ID
                 group by dav.agent_report_dav_id) spg,
               ven_agent_report_dav agd,
               V_T_PROD_COEF_TYPE vtct
         where agd.agent_report_id =  :P_AG_REP_ID
           and spg.agent_report_dav_id = agd.agent_report_dav_id
           and vtct.T_PROD_COEF_TYPE_ID = agd.PROD_COEF_TYPE_ID) report
]]>
      </select>
      <displayInfo x="4.81250" y="2.06250" width="0.69995" height="0.19995"/>
      <group name="G_SUM">
        <displayInfo x="4.05078" y="2.47925" width="2.22339" height="1.96875"
        />
        <dataItem name="SUM_DOG_PR" datatype="vchar2" columnOrder="73"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sum Dog Pr">
          <dataDescriptor expression="SUM_DOG_PR"
           descriptiveExpression="SUM_DOG_PR" order="11" width="4000"/>
        </dataItem>
        <dataItem name="sgp_DPPM_line" oracleDatatype="number"
         columnOrder="63" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Dppm Line">
          <dataDescriptor expression="SGP_DPPM_LINE"
           descriptiveExpression="SGP_DPPM_LINE" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_DP_KV_MN_line" oracleDatatype="number"
         columnOrder="64" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dp Kv Mn Line">
          <dataDescriptor expression="SGP_DP_KV_MN_LINE"
           descriptiveExpression="SGP_DP_KV_MN_LINE" order="2"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_PREM_PLAN_MENG_line" oracleDatatype="number"
         columnOrder="65" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Prem Plan Meng Line">
          <dataDescriptor expression="SGP_PREM_PLAN_MENG_LINE"
           descriptiveExpression="SGP_PREM_PLAN_MENG_LINE" order="3"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_opm_line" oracleDatatype="number" columnOrder="66"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Opm Line">
          <dataDescriptor expression="SGP_OPM_LINE"
           descriptiveExpression="SGP_OPM_LINE" order="4"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_dppbb_line" oracleDatatype="number"
         columnOrder="67" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Dppbb Line">
          <dataDescriptor expression="SGP_DPPBB_LINE"
           descriptiveExpression="SGP_DPPBB_LINE" order="5"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_DPPM_line" oracleDatatype="number"
         columnOrder="68" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Com Sum Dav Line"
          >
          <xmlSettings xmlTag="COM_SUM_DAV_LINE"/>
          <dataDescriptor expression="COM_SUM_DPPM_LINE"
           descriptiveExpression="COM_SUM_DPPM_LINE" order="6"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_DP_KV_MN_line" oracleDatatype="number"
         columnOrder="69" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Com Sum Dp Kv Mn Line">
          <dataDescriptor expression="COM_SUM_DP_KV_MN_LINE"
           descriptiveExpression="COM_SUM_DP_KV_MN_LINE" order="7"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_PREM_PLAN_MENG_line" oracleDatatype="number"
         columnOrder="70" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Com Sum Prem Plan Meng Line">
          <dataDescriptor expression="COM_SUM_PREM_PLAN_MENG_LINE"
           descriptiveExpression="COM_SUM_PREM_PLAN_MENG_LINE" order="8"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_opm_line" oracleDatatype="number"
         columnOrder="71" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Com Sum Opm Line">
          <dataDescriptor expression="COM_SUM_OPM_LINE"
           descriptiveExpression="COM_SUM_OPM_LINE" order="9"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_dppbb_line" oracleDatatype="number"
         columnOrder="72" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Com Sum Dppbb Line">
          <dataDescriptor expression="COM_SUM_DPPBB_LINE"
           descriptiveExpression="COM_SUM_DPPBB_LINE" order="10"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT_REPORT" parentColumn="CONTACT_ID"
     childQuery="Q_AG_DOCS" childColumn="contact_id1" condition="eq"
     sqlClause="where"/>
  </data>
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
<title> Расчет дополнительной премии менеджера Агентства</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="place"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>deisde</o:Author>
  <o:Template>bonus_manager_report</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>52</o:TotalTime>
  <o:Created>2007-07-10T10:28:00Z</o:Created>
  <o:LastSaved>2007-07-10T10:28:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>533</o:Words>
  <o:Characters>3044</o:Characters>
  <o:Lines>25</o:Lines>
  <o:Paragraphs>7</o:Paragraphs>
  <o:CharactersWithSpaces>3570</o:CharactersWithSpaces>
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
	mso-font-signature:3 0 0 0 1 0;}
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
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
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
</style>
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="G_SUM" src="G_SUM">
<rw:getValue id="sgp_DPPM_line" src="sgp_DPPM_line"/>
<rw:getValue id="COM_SUM_DPPM_line" src="COM_SUM_DPPM_line"/>
<rw:getValue id="sgp_DP_KV_MN_line" src="sgp_DP_KV_MN_line"/>
<rw:getValue id="COM_SUM_DP_KV_MN_line" src="COM_SUM_DP_KV_MN_line"/>
<rw:getValue id="sgp_PREM_PLAN_MENG_line" src="sgp_PREM_PLAN_MENG_line"/>
<rw:getValue id="COM_SUM_PREM_PLAN_MENG_line" src="COM_SUM_PREM_PLAN_MENG_line"/>
<rw:getValue id="COM_SUM_opm_line" src="COM_SUM_opm_line"/>
<rw:getValue id="COM_SUM_dppbb_line" src="COM_SUM_dppbb_line"/>
<rw:getValue id="SUM_DOG_PR" src="SUM_DOG_PR"/>

<%
  
      strTMP = sgp_DPPM_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_SGP_1 = Double.parseDouble(strTMP);
  
      strTMP = sgp_DP_KV_MN_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_SGP_2 = Double.parseDouble(strTMP);

      strTMP = sgp_PREM_PLAN_MENG_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_SGP_3 = Double.parseDouble(strTMP);

      strTMP = COM_SUM_DPPM_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_COM_1 = Double.parseDouble(strTMP);

      strTMP = COM_SUM_DP_KV_MN_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_COM_2 = Double.parseDouble(strTMP);

      strTMP = COM_SUM_PREM_PLAN_MENG_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_COM_3 = Double.parseDouble(strTMP);

      strTMP = COM_SUM_opm_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_COM_4 = Double.parseDouble(strTMP);

      strTMP = COM_SUM_dppbb_line.toString();
      strTMPZ = strTMP.substring(0,1); 
      strTMP = strTMP.substring(1);
      strTMP = strTMP.trim();
      strTMP = strTMPZ + strTMP;
      SUM_COM_5 = Double.parseDouble(strTMP);

  SUM_COM_ALL = SUM_COM_1 + SUM_COM_2 + SUM_COM_3 + SUM_COM_4 + SUM_COM_5;
  
  SumStr = SUM_DOG_PR;
%>

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
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Расчет дополнительной премии
менеджера Агентства (филиала) <span style='mso-spacerun:yes'> </span><%=NAME_DEP%>
<o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><span style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=AG_NAME_GENITIVE%>
<b style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=425 valign=top style='width:318.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoTitle align=left style='margin-top:6.0pt;text-align:left;
  tab-stops:35.4pt'><span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'>г. Москва<o:p></o:p></span></p>
  </td>
  <td width=266 valign=top style='width:199.75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoTitle align=right style='margin-top:6.0pt;text-align:right;
  tab-stops:35.4pt'><span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
  font-family:"Times New Roman"'><%=REPORT_DATE%><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoTitle style='margin-top:6.0pt'><span style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>за период с <%=DATE_BEGIN%>
<span style='mso-spacerun:yes'> </span>по <span
style='mso-spacerun:yes'> </span><%=DATE_END%> <o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><st1:place w:st="on"><span lang=EN-US style='font-family:
 "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";layout-grid-mode:
 both'>I</span><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
 "Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>.</span></st1:place><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> Дополнительная премия первого года
в рамках начальной поддержки менеджера группы (ДППМ<span class=GramE>) :</span><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> при посредничестве агентов,
координируемых менеджером, и самого менеджера, были заключены следующие
договоры страхования, первый взнос по которым был оплачен в полном объеме в
отчетном периоде:<o:p></o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=100 valign=top style='width:74.8pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=103 valign=top style='width:77.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Периодичность уплаты взносов<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата поступления Заявления на страхование в Компанию<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата оплаты первого взноса<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Годовая премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG1" src="G_DOG"> 

<rw:getValue id="pol_num" src="pol_num"/>
<rw:getValue id="strahov_name" src="strahov_name"/>
<rw:getValue id="progr" src="progr"/>
<rw:getValue id="PAY_TERM" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="BRIEF" src="BRIEF"/>

<%
 if (BRIEF.equals("DPPM")) {
%>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=EN-US
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><o:p>
  <%=pol_num%>
  </o:p></span></p>
  </td>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;
  mso-ansi-language:RU'><o:p>
  <%=strahov_name%>
  </o:p></span></p>
  </td>
  <td width=100 valign=top style='width:74.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=progr%>
  </o:p></span></p>
  </td>
  <td width=103 valign=top style='width:77.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP%>
  </o:p></span></p>
  </td>
 </tr>
   <%}%>
</rw:foreach> 

</table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>2. СГП по договорам
страхования, заключенных в отчетном периоде при посредничестве агентов,
координируемых менеджером, и самого менеджера, составляет <span
style='mso-spacerun:yes'> </span><%=format.format(SUM_SGP_1)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>3. Менеджеру в соответствии с
Положением о премировании менеджеров и директоров агентств и филиалов ООО «СК
«Ренессанс Жизнь» выплачивается дополнительная премия в рамках начальной
поддержки менеджера группы в размере <span style='mso-spacerun:yes'> </span><%=format.format(SUM_COM_1)%>
руб..</span><span style='mso-ansi-language:RU;layout-grid-mode:both'><o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>II</span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>. Дополнительная премия второго
года за выполнение квартального плана продаж (ДКПМ):<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> при посредничестве агентов группы
были заключены следующие договоры страхования, первый взнос по которым был
оплачен в полном объеме в отчетном периоде:<o:p></o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=112 valign=top style='width:83.8pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=91 valign=top style='width:68.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Периодичность уплаты взносов<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата поступления Заявления на страхование в Компанию<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата оплаты первого взноса<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Годовая премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG2" src="G_DOG"> 

<rw:getValue id="pol_num2" src="pol_num"/>
<rw:getValue id="strahov_name2" src="strahov_name"/>
<rw:getValue id="progr2" src="progr"/>
<rw:getValue id="PAY_TERM2" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE2" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE2" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP2" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="BRIEF2" src="BRIEF"/>


<%
if (BRIEF2.equals("DP_KV_MN")) {
%>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><a name="table_3"><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-spacerun:yes'> </span></span></a><span lang=EN-US
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><o:p>
  <%=pol_num2%>
  </o:p></span></p>
  </td>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;
  mso-ansi-language:RU'><o:p>
  <%=strahov_name2%>
  </o:p></span></p>
  </td>
  <td width=112 valign=top style='width:83.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;
  mso-ansi-language:RU'><o:p>
  <%=progr2%>
  </o:p></span></p>
  </td>
  <td width=91 valign=top style='width:68.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM2%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE2%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE2%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP2%>
  </o:p></span></p>
  </td>
 </tr>
    <%}%>
</rw:foreach> 
 
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>2. СГП по договорам
страхования, заключенных в отчетном периоде при посредничестве агентов, и
менеджеров, прикрепленных к агентству (филиалу), составляет <span
style='mso-spacerun:yes'> </span><%=format.format(SUM_SGP_2)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>3. </span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>Менеджеру в соответствии с
Положением о премировании менеджеров и директоров агентств и филиалов ООО «СК
«Ренессанс Жизнь» выплачивается дополнительная квартальная премия второго года
в размере <span style='mso-spacerun:yes'> </span> <%=format.format(SUM_COM_2)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>III</span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>. Дополнительная премия за
выполнение годового плана <span class=GramE>продаж :</span><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span><span
style='mso-ansi-language:RU'><%=DATE_BEGIN%><span style='mso-spacerun:yes'> 
</span>по<span style='mso-spacerun:yes'>  </span><%=DATE_END%></span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> при посредничестве агентов группы
были заключены следующие договоры страхования, первый взнос по которым был
оплачен в полном объеме в отчетном периоде:<o:p></o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=112 valign=top style='width:83.8pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=91 valign=top style='width:68.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Периодичность уплаты взносов<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата поступления Заявления на страхование в Компанию<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Дата оплаты первого взноса<o:p></o:p></span></b></p>
   </td>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
   RU'>Годовая премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG3" src="G_DOG"> 

<rw:getValue id="pol_num3" src="pol_num"/>
<rw:getValue id="strahov_name3" src="strahov_name"/>
<rw:getValue id="progr3" src="progr"/>
<rw:getValue id="PAY_TERM3" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE3" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE3" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP3" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="BRIEF3" src="BRIEF"/>

<%
if (BRIEF3.equals("PREM_PLAN_MENG")) {
%>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'> </span><o:p>
  <%=pol_num3%>
  </o:p></span></p>
  </td>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;
  mso-ansi-language:RU'><o:p>
  <%=strahov_name3%>
  </o:p></span></p>
  </td>
  <td width=112 valign=top style='width:83.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;
  mso-ansi-language:RU'><o:p>
  <%=progr3%>
  </o:p></span></p>
  </td>
  <td width=91 valign=top style='width:68.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM3%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE3%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE3%>
  </o:p></span></p>
  </td>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP3%>
  </o:p></span></p>
  </td>
 </tr>
    <%}%>
</rw:foreach> 
 
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>2. СГП по договорам
страхования, заключенных в отчетном периоде при посредничестве агентов, и
менеджеров, прикрепленных к агентству (филиалу), составляет <span
style='mso-spacerun:yes'> </span><%=format.format(SUM_SGP_3)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>3. </span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>Менеджеру в соответствии с
Положением о премировании менеджеров и директоров агентств и филиалов ООО «СК
«Ренессанс Жизнь» выплачивается дополнительная премия за выполнение годового
плана продаж в размере <span style='mso-spacerun:yes'> </span><%=format.format(SUM_COM_3)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>IV</span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>. Отсроченная премия менеджера
(ОПМ):<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>1. </span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>Менеджеру в соответствии с
Положением о премировании менеджеров и директоров агентств и филиалов ООО «СК
«Ренессанс Жизнь» выплачивается отсроченнам премия менеджера размере <span
style='mso-spacerun:yes'> </span><%=format.format(SUM_COM_4)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>V</span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>. Дополнительная премия за
привлечение Банков, Брокеров (ДППББ):<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-ansi-language:RU;layout-grid-mode:both'>1. </span><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>Менеджеру в соответствии с
Положением о премировании менеджеров и директоров агентств и филиалов ООО «СК
«Ренессанс Жизнь» выплачивается дополнительная премия за привлечение Банков,
Брокеров размере <span style='mso-spacerun:yes'> </span><%=format.format(SUM_COM_5)%> руб.<o:p></o:p></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'>Итого к выплате: <%=format.format(SUM_COM_ALL)%>
руб. (<%=SumStr%>)<o:p></o:p></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>С расчетом ознакомлен и согласен:<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>___________________________<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><a
name=shortname><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'><%=AG_NAME_INITIAL%><o:p></o:p></span></a></p>

<span style='mso-bookmark:shortname'></span>

<p class=MsoNormal style='margin-right:-23.2pt'><span style='mso-ansi-language:
RU'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>

</rw:report>
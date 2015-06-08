SUM_COM_1<%@ include file="/inc/header_msword.jsp" %>  
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
  double SUM_SGP = 0; 
  double D_S_BREAK = 0;  
  double PER_PLAN = 0; 
%>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_dav_dir" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_DAV_DIR" xmlPrologType="text">
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
       ac.SGP,
       tp.DESCRIPTION product,
       vtct.BRIEF,
       plo.DESCRIPTION progr,       
       doc.GET_LAST_DOC_STATUS_BRIEF(agr.AG_CONTRACT_H_ID) status_BRIF,
       nvl(ac.IS_BREAK,0) IS_BREAK,
       ac.IS_INCLUDED,
      nvl(agd.PER_PLAN,0) PER_PLAN
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
  WHERE agd.agent_report_id = :P_AG_REP_ID ;]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
      <group name="G_DOG">
        <displayInfo x="5.71021" y="0.76074" width="1.71301" height="2.99414"
        />
        <dataItem name="PER_PLAN" oracleDatatype="number" columnOrder="67"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Per Plan">
          <dataDescriptor expression="PER_PLAN"
           descriptiveExpression="PER_PLAN" order="15" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="PROGR" datatype="vchar2" columnOrder="60" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Progr">
          <dataDescriptor expression="PROGR" descriptiveExpression="PROGR"
           order="11" width="255"/>
        </dataItem>
        <dataItem name="IS_BREAK" oracleDatatype="number" columnOrder="58"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break">
          <dataDescriptor expression="IS_BREAK"
           descriptiveExpression="IS_BREAK" order="13" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="IS_INCLUDED" oracleDatatype="number" columnOrder="59"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Included">
          <dataDescriptor expression="IS_INCLUDED"
           descriptiveExpression="IS_INCLUDED" order="14"
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
           order="8" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="PRODUCT" datatype="vchar2" columnOrder="55"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product">
          <dataDescriptor expression="PRODUCT" descriptiveExpression="PRODUCT"
           order="9" width="255"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="56" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="10" width="30"/>
        </dataItem>
        <dataItem name="STATUS_BRIF" datatype="vchar2" columnOrder="57"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Brif">
          <dataDescriptor expression="STATUS_BRIF"
           descriptiveExpression="STATUS_BRIF" order="12" width="4000"/>
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
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name">
          <dataDescriptor expression="STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="2000"/>
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
      <select>
      <![CDATA[  SELECT 
       nvl(sum(decode(vtct.BRIEF,'ДКП',ac.SGP,0)),0) sgp_dkp_line,
       nvl(sum(decode(vtct.BRIEF,'ДПР',ac.SGP,0)),0) sgp_dpr_line,
       nvl(sum(decode(vtct.BRIEF,'ОПД',ac.SGP,0)),0) sgp_opd_line,
       nvl(max(agd.COMISSION_SUM),0) COM_SUM_dkp_line,
       nvl(sum(decode(vtct.BRIEF,'ДПР',ac.COMISSION_SUM,0)),0) COM_SUM_dpr_line,
       nvl(sum(decode(vtct.BRIEF,'ОПД',ac.COMISSION_SUM,0)),0) COM_SUM_opd_line
FROM  ven_agent_report_dav_ct ac,
      ven_agent_report_dav agd,
      V_T_PROD_COEF_TYPE vtct
where agd.agent_report_id = :P_AG_REP_ID
  and agd.agent_report_dav_id = ac.agent_report_dav_id
  and vtct.T_PROD_COEF_TYPE_ID = agd.PROD_COEF_TYPE_ID]]>
      </select>
      <displayInfo x="4.33325" y="2.34375" width="0.69995" height="0.19995"/>
      <group name="G_SUM">
        <displayInfo x="3.84253" y="3.04346" width="2.22339" height="1.62695"
        />
        <dataItem name="sgp_dkp_line" oracleDatatype="number" columnOrder="61"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dkp Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДКП&apos; , ac.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DKP_LINE" order="1" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="sgp_dpr_line" oracleDatatype="number" columnOrder="62"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dpr Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДПР&apos; , ac.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DPR_LINE" order="2" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="sgp_opd_line" oracleDatatype="number" columnOrder="63"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Opd Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ОПД&apos; , ac.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_OPD_LINE" order="3" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_dkp_line" oracleDatatype="number"
         columnOrder="64" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Com Sum Dkp Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДКП&apos; , ac.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COM_SUM_DKP_LINE" order="4" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_dpr_line" oracleDatatype="number"
         columnOrder="65" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Com Sum Dpr Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДПР&apos; , ac.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COM_SUM_DPR_LINE" order="5" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="COM_SUM_opd_line" oracleDatatype="number"
         columnOrder="66" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Com Sum Opd Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ОПД&apos; , ac.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COM_SUM_OPD_LINE" order="6" width="22"
           precision="38"/>
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
<title>Расчет дополнительной премии Директора Агентства</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="place"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>soldain</o:Author>
  <o:Template>bonus_director_report</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>1</o:TotalTime>
  <o:Created>2007-07-10T13:29:00Z</o:Created>
  <o:LastSaved>2007-07-10T13:29:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>561</o:Words>
  <o:Characters>3200</o:Characters>
  <o:Lines>26</o:Lines>
  <o:Paragraphs>7</o:Paragraphs>
  <o:CharactersWithSpaces>3754</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
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
<rw:getValue id="sgp_dkp_line" src="sgp_dkp_line"/>
<rw:getValue id="sgp_dpr_line" src="sgp_dpr_line"/>
<rw:getValue id="sgp_opd_line" src="sgp_opd_line"/>
<rw:getValue id="COM_SUM_dkp_line" src="COM_SUM_dkp_line"/>
<rw:getValue id="COM_SUM_dpr_line" src="COM_SUM_dpr_line"/>
<rw:getValue id="COM_SUM_opd_line" src="COM_SUM_opd_line"/>

<%
  SUM_SGP_1 = Double.valueOf(sgp_dkp_line).doubleValue();;
  SUM_SGP_2 = Double.valueOf(sgp_dpr_line).doubleValue();;
  SUM_SGP_3 = Double.valueOf(sgp_opd_line).doubleValue();;
  SUM_COM_1 = Double.valueOf(COM_SUM_dkp_line).doubleValue();;
  SUM_COM_2 = Double.valueOf(COM_SUM_dpr_line).doubleValue();;
  SUM_COM_3 = Double.valueOf(COM_SUM_opd_line).doubleValue();;
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
Директора Агентства (филиала) <span style='mso-spacerun:yes'> </span><a
name=agency><%=NAME_DEP%></a><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><a name="agent_name_R"><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=AG_NAME_GENITIVE%>
<b style='mso-bidi-font-weight:normal'><o:p></o:p></b></span></a></p>

<span style='mso-bookmark:agent_name_R'></span>

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
text-autospace:none'><a name="dkp_block"></a><st1:place w:st="on"><span
 style='mso-bookmark:dkp_block'><span lang=EN-US style='font-family:"Times New Roman CYR";
 mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>I</span></span><span
 style='mso-bookmark:dkp_block'><span style='font-family:"Times New Roman CYR";
 mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
 both'>.</span></span></st1:place><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> Дополнительная премия за
выполнение квартального плана продаж (ДКП):<o:p></o:p></span></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span></span><a
name="date_from_2"><span style='mso-bookmark:dkp_block'><span style='mso-ansi-language:
RU'><%=DATE_BEGIN%></span></span></a><span style='mso-bookmark:dkp_block'><span
style='mso-ansi-language:RU'><span style='mso-spacerun:yes'>  </span>по<span
style='mso-spacerun:yes'>  </span><a name="date_to_2"><%=DATE_END%></a></span></span><span
style='mso-bookmark:date_to_2'></span><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> при посредничестве агентов и
менеджеров, прикрепленных к агентству (филиалу), были заключены следующие
договоры страхования, первый взнос по которым был оплачен в полном объеме в
отчетном периоде:<o:p></o:p></span></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер
   договора<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=112 valign=top style='width:83.8pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа
   страхования<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=91 valign=top style='width:68.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Периодичность
   уплаты взносов<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата
   поступления Заявления на страхование в Компанию<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата
   оплаты первого взноса<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dkp_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Годовая
   премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dkp_block'></span>
  </tr>
 </thead>
 
<rw:foreach id="G_DOG" src="G_DOG"> 

<rw:getValue id="pol_num" src="pol_num"/>
<rw:getValue id="strahov_name" src="strahov_name"/>
<rw:getValue id="progr" src="progr"/>
<rw:getValue id="PAY_TERM" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK" src="IS_BREAK"/>
<rw:getValue id="BRIEF" src="BRIEF"/>
<rw:getValue id="PER_PLAN_D" src="PER_PLAN" formatMask="999999990.99"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK).doubleValue();
  PER_PLAN =  Double.valueOf(PER_PLAN_D).doubleValue();%>
<%
if ( ( D_S_BREAK == 0) && (BRIEF.equals("ДКП") ) ) {
SUM_SGP = SUM_SGP + Double.valueOf(SGP).doubleValue();
%>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-bookmark:dkp_block'><a name="table_1"><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-spacerun:yes'> </span></span></a></span><span style='mso-bookmark:
  dkp_block'><span lang=EN-US style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><o:p>
  <%=pol_num%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dkp_block'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=112 valign=top style='width:83.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dkp_block'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=progr%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=91 valign=top style='width:68.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dkp_block'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'></span>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='mso-bookmark:dkp_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'></span>
 </tr>
  <%}%>
</rw:foreach> 

</table>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bookmark:dkp_block'><span style='mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bookmark:dkp_block'><span style='mso-ansi-language:RU;layout-grid-mode:
both'>СГП по договорам страхования, заключенных в отчетном периоде при
посредничестве агентов, и менеджеров, прикрепленных к агентству (филиалу), составляет
<span style='mso-spacerun:yes'> </span><a name="dkp_premium"><%=format.format(SUM_SGP)%>.</a><o:p></o:p></span></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bookmark:dkp_block'><span style='mso-ansi-language:RU;layout-grid-mode:
both'><o:p>&nbsp;</o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><a name="canceled_1"><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. За период с <%=DATE_BEGIN%> по
<%=DATE_END%> были расторгнуты следующие договоры страхования первого года
действия, заключенные <span style='text-transform:uppercase'>Страховщиком </span>при
посредничестве агентов и менеджеров, прикрепленных к агентству (филиалу), сумма
годовой премии по которым была учтена при расчете ДКП Директора агентства <span
style='mso-spacerun:yes'> </span>(филиала) в предшествующих отчетных периодах:</span></a></span><span
style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><span
style='mso-ansi-language:RU'><span style='mso-tab-count:5'>                                                   </span><o:p></o:p></span></span></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=116 valign=top style='width:86.85pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.1pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Периодичность уплаты взносов<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Дата поступления Заявления на страхование в
  Компанию<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Дата оплаты первого взноса<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'>Годовая премия по договору за вычетом суммы
  административных издержек<o:p></o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
 </tr>
 
<rw:foreach id="G_DOG_V" src="G_DOG"> 

<rw:getValue id="pol_num_v" src="pol_num"/>
<rw:getValue id="strahov_name_v" src="strahov_name"/>
<rw:getValue id="progr_v" src="progr"/>
<rw:getValue id="PAY_TERM_V" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE_V" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE_V" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP_V" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_V" src="IS_BREAK"/>
<rw:getValue id="BRIEF_V" src="BRIEF"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_V).doubleValue();%>
<%
if ( ( D_S_BREAK == 1) && (BRIEF_V.equals("ДКП") ) ) {
SUM_SGP = SUM_SGP - Double.valueOf(SGP_V).doubleValue();
%>
 
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:dkp_block'><span
  style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=pol_num_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=116 valign=top style='width:86.85pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dkp_block'><span style='mso-bookmark:canceled_1'></span></span>
 </tr>
    <%}%>
</rw:foreach> 
 
</table>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><span
style='mso-bookmark:canceled_1'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>СГП по данным договорам страхования вычитается из СГП Директора агентства
(филиала) за период с <%=DATE_BEGIN%> по <%=DATE_END%>.<o:p></o:p></span></span></span></p>

<span style='mso-bookmark:canceled_1'></span>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. Итого СГП за период с <a
name="date_from_3"><%=DATE_BEGIN%></a> по <a name="date_to_3"><%=DATE_END%></a>
составляет <span style='mso-spacerun:yes'> </span><a name="dkp_premium_1"><%=format.format(SUM_SGP)%></a>,
что составляет <span style='mso-spacerun:yes'> </span><a name="dkp_percent"><%=format.format(PER_PLAN)%> %</a>
от Индивидуального квартального плана Директора Агентства.<o:p></o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>3. За период с <a name="date_from_4"><%=DATE_BEGIN%></a>
по <a name="date_to_4"><%=DATE_END%></a> Директору агентства (филиала) в
соответствии с Положением о премировании менеджеров и директоров агентств и
филиалов ООО «СК «Ренессанс Жизнь» выплачивается дополнительная премия за
выполнение квартального плана продаж в размере <span
style='mso-spacerun:yes'> </span><a name="dkp_commission"><%=format.format(SUM_COM_1)%> руб.</a><o:p></o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dkp_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<span style='mso-bookmark:dkp_block'></span>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><a name="dpr_block"></a><a name=nmbr><span
style='mso-bookmark:dpr_block'><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'>II</span></span></a><span
style='mso-bookmark:nmbr'></span><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>. Дополнительная единовременная премия
за выполнение агентством (филиалом) плана развития.<o:p></o:p></span></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>1. За период с </span></span><a
name="date_from_5"><span style='mso-bookmark:dpr_block'><span style='mso-ansi-language:
RU'><%=DATE_BEGIN%></span></span></a><span style='mso-bookmark:dpr_block'><span
style='mso-ansi-language:RU'><span style='mso-spacerun:yes'>  </span>по<span
style='mso-spacerun:yes'>  </span><a name="date_to_5"><%=DATE_END%></a></span></span><span
style='mso-bookmark:date_to_5'></span><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'> при посредничестве агентов и
менеджеров, прикрепленных к агентству (филиалу), были заключены следующие
договоры страхования, первый взнос по которым был оплачен в полном объеме в
отчетном периоде:<o:p></o:p></span></span></p>
<%SUM_SGP = 0;%>
<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер
   договора<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=116 valign=top style='width:86.85pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа
   страхования<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=87 valign=top style='width:65.1pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Периодичность
   уплаты взносов<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата
   поступления Заявления на страхование в Компанию<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата
   оплаты первого взноса<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><b style='mso-bidi-font-weight:normal'><span
   style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Годовая
   премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'></span>
  </tr>
 </thead>
 
 <rw:foreach id="G_DOG_DOP" src="G_DOG"> 

<rw:getValue id="pol_num_dop" src="pol_num"/>
<rw:getValue id="strahov_name_dop" src="strahov_name"/>
<rw:getValue id="progr_dop" src="progr"/>
<rw:getValue id="PAY_TERM_dop" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE_dop" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE_dop" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP_dop" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_dop" src="IS_BREAK"/>
<rw:getValue id="BRIEF_DOP" src="BRIEF"/>
<rw:getValue id="PER_PLAN_DOP" src="PER_PLAN"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_dop).doubleValue(); %>
<%
if (( D_S_BREAK == 0) && (BRIEF_DOP.equals("ДПР") ) ){

SUM_SGP = SUM_SGP + Double.valueOf(SGP_dop).doubleValue();
%>
 
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-bookmark:dpr_block'><a name="table_2"><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-spacerun:yes'> </span></span></a></span><span style='mso-bookmark:
  dpr_block'><span lang=EN-US style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><o:p>
  <%=pol_num_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dpr_block'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=116 valign=top style='width:86.85pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dpr_block'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=87 valign=top style='width:65.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal><span style='mso-bookmark:dpr_block'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'></span>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='mso-bookmark:dpr_block'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP_dop%>
  </o:p></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'></span>
 </tr>
 <%}%>
</rw:foreach>  
</table>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><a name="canceled_2"><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>2. За период с <%=DATE_BEGIN%> по
<%=DATE_END%> были расторгнуты следующие договоры страхования первого года
действия, заключенные <span style='text-transform:uppercase'>Страховщиком </span>при
посредничестве агентов и менеджеров, прикрепленных к агентству (филиалу), сумма
годовой премии по которым была учтена при расчете ДКП Директора агентства<span
style='mso-spacerun:yes'>  </span>(филиала) в предшествующих отчетных периодах:</span></a></span><span
style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><span
style='mso-ansi-language:RU'><span style='mso-tab-count:5'>                                                   </span><o:p></o:p></span></span></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=695
 style='width:521.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
   mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=164 valign=top style='width:123.2pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=116 valign=top style='width:86.85pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=87 valign=top style='width:65.1pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Периодичность уплаты взносов<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Дата поступления Заявления на страхование в
   Компанию<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Дата оплаты первого взноса<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
   <td width=87 valign=top style='width:65.15pt;border:solid windowtext 1.0pt;
   border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
   solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center'><span
   style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
   10.0pt;mso-ansi-language:RU'>Годовая премия по договору за вычетом суммы
   административных издержек<o:p></o:p></span></b></span></span></p>
   </td>
   <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  </tr>
 </thead>
 
 <rw:foreach id="G_DOG_DOP_V" src="G_DOG"> 

<rw:getValue id="pol_num_dop_v" src="pol_num"/>
<rw:getValue id="strahov_name_dop_v" src="strahov_name"/>
<rw:getValue id="progr_dop_v" src="progr"/>
<rw:getValue id="PAY_TERM_dop_V" src="PAY_TERM"/>
<rw:getValue id="NOTICE_DATE_dop_V" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FIRST_PAY_DATE_dop_V" src="FIRST_PAY_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP_dop_V" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_dop_V" src="IS_BREAK"/>
<rw:getValue id="BRIEF_DOP_V" src="BRIEF"/>

<%D_S_BREAK = Double.valueOf(IS_BREAK_dop_V).doubleValue();%>
<%
if (( D_S_BREAK == 1) && (BRIEF_DOP_V.equals("ДПР") ) ){

SUM_SGP = SUM_SGP - Double.valueOf(SGP_dop_V).doubleValue();
%>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=67 valign=top style='width:50.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:dpr_block'><span
  style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=pol_num_dop_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=strahov_name_dop_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=116 valign=top style='width:86.85pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=progr_dop_v%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=87 valign=top style='width:65.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=PAY_TERM_dop_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=NOTICE_DATE_dop_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=FIRST_PAY_DATE_dop_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  10.0pt;mso-ansi-language:RU'><o:p>
  <%=SGP_dop_V%>
  </o:p></span></b></span></span></p>
  </td>
  <span style='mso-bookmark:dpr_block'><span style='mso-bookmark:canceled_2'></span></span>
 </tr>
<%}%>
</rw:foreach>   
</table>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='mso-bookmark:canceled_2'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'>СГП по данным договорам страхования вычитается из СГП Директора агентства
(филиала) за период с <%=DATE_BEGIN%> по <%=DATE_END%>.<o:p></o:p></span></span></span></p>

<span style='mso-bookmark:canceled_2'></span>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>3. Итого СГП за период с <a
name="date_from_6"><%=DATE_BEGIN%></a> по <a name="date_to_6"><%=DATE_END%></a>
составляет <span style='mso-spacerun:yes'> </span><a name="dpr_premium"><%=format.format(SUM_SGP)%></a></span></span><span
style='mso-bookmark:dpr_premium'></span><span style='mso-bookmark:dpr_block'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'><o:p></o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>4. Отсроченная премия Директора
Агентства за выполнение квартальных планов продаж составляет <%=format.format(SUM_COM_3)%>.<o:p></o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>5. За период с <a name="date_from_7"><%=DATE_BEGIN%></a>
по <a name="date_to_7"><%=DATE_END%></a> Директору агентства (филиала) в
соответствии с Положением о премировании менеджеров и директоров агентств и
филиалов ООО «СК «Ренессанс Жизнь» выплачивается дополнительная единовременная
премия за выполнение агентством (филиалом) плана развития в размере <span
style='mso-spacerun:yes'> </span><a name="dpr_commission"><%=format.format(SUM_COM_2)%> руб.</a><o:p></o:p></span></span></p>

<p class=MsoNormal style='text-indent:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='mso-bookmark:dpr_block'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></span></p>

<span style='mso-bookmark:dpr_block'></span>

<p class=MsoNormal style='margin-left:18.0pt;mso-layout-grid-align:none;
text-autospace:none'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

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
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'>___________________________<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><a
name=shortname><span lang=EN-US style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";layout-grid-mode:both'></span></a><span
style='mso-bookmark:shortname'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU;layout-grid-mode:
both'><%=AG_NAME_INITIAL%></span></span><span style='mso-bookmark:shortname'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
layout-grid-mode:both'></span></span><span style='mso-bookmark:shortname'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;layout-grid-mode:both'><o:p></o:p></span></span></p>

<span style='mso-bookmark:shortname'></span>

<p class=MsoNormal style='margin-right:-23.2pt'><span style='mso-ansi-language:
RU'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>

</rw:report>
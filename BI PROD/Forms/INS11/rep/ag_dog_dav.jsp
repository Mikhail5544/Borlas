<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251"  %>
<%@ page import="java.text.*" %>

<%
  DecimalFormatSymbols unusualSymbols =  new DecimalFormatSymbols();
  unusualSymbols.setDecimalSeparator('.');
  String strange = "0.00";
  DecimalFormat format = new DecimalFormat(strange, unusualSymbols);  
  
  double Double_isbreak = 0;
  double SUM_SGP = 0;
%>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ag_dog_dav_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="AG_DOG_OAV" xmlPrologType="text">
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
       decode(vca.category_name,'Агент',agent_status.status_name,'Финансовый консультант') status_name, 
       decode(vca_n.category_name,'Агент',agent_status_next.status_name,'Финансовый консультант') status_name_next,       
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
           AND sh.ag_stat_agent_id = sa.ag_stat_agent_id(+)) agent_status_next
       ON (agent_status_next.ag_stat_hist_id =
              pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id,ved.date_end+1)
          )       
  WHERE agr.AG_VEDOM_AV_ID = :p_vedom_id and agr.agent_report_id = :P_AG_REP_ID;]]>
      </select>
      <displayInfo x="2.12500" y="0.08337" width="1.19788" height="0.32983"/>
      <group name="G_AGENT_REPORT">
        <displayInfo x="1.70825" y="0.72913" width="2.03125" height="3.16504"
        />
        <dataItem name="STATUS_NAME_NEXT" datatype="vchar2" columnOrder="29"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name Next">
          <dataDescriptor expression="STATUS_NAME_NEXT"
           descriptiveExpression="STATUS_NAME_NEXT" order="13" width="250"/>
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
           descriptiveExpression="AG_NAME_INITIAL" order="14" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_INITIAL" datatype="vchar2" columnOrder="24"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Initial">
          <dataDescriptor expression="DIR_NAME_INITIAL"
           descriptiveExpression="DIR_NAME_INITIAL" order="15" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_GENITIVE" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Genitive">
          <dataDescriptor expression="DIR_NAME_GENITIVE"
           descriptiveExpression="DIR_NAME_GENITIVE" order="16" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="26"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="17" width="4000"/>
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
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Name">
          <dataDescriptor expression="STATUS_NAME"
           descriptiveExpression="STATUS_NAME" order="12" width="250"/>
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
        <dataItem name="company_name" datatype="vchar2" columnOrder="30"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Company Name">
          <dataDescriptor
           expression="org.company_type || &apos; &apos; || org.company_name"
           descriptiveExpression="COMPANY_NAME" order="1" width="4000"/>
        </dataItem>
        <dataItem name="chief_name" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Chief Name">
          <dataDescriptor expression="org.chief_name"
           descriptiveExpression="CHIEF_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="inn" datatype="vchar2" columnOrder="32" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Inn">
          <dataDescriptor expression="org.inn" descriptiveExpression="INN"
           order="3" width="101"/>
        </dataItem>
        <dataItem name="kpp" datatype="vchar2" columnOrder="33" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Kpp">
          <dataDescriptor expression="org.kpp" descriptiveExpression="KPP"
           order="4" width="101"/>
        </dataItem>
        <dataItem name="account_number" datatype="vchar2" columnOrder="34"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Account Number">
          <dataDescriptor expression="org.account_number"
           descriptiveExpression="ACCOUNT_NUMBER" order="5" width="30"/>
        </dataItem>
        <dataItem name="bank" datatype="vchar2" columnOrder="35" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bank">
          <dataDescriptor
           expression="org.bank_company_type || &apos; &apos; || org.bank_name"
           descriptiveExpression="BANK" order="6" width="4000"/>
        </dataItem>
        <dataItem name="b_bic" datatype="vchar2" columnOrder="36" width="101"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="B Bic">
          <dataDescriptor expression="org.b_bic" descriptiveExpression="B_BIC"
           order="7" width="101"/>
        </dataItem>
        <dataItem name="b_kor_account" datatype="vchar2" columnOrder="37"
         width="101" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="B Kor Account">
          <dataDescriptor expression="org.b_kor_account"
           descriptiveExpression="B_KOR_ACCOUNT" order="8" width="101"/>
        </dataItem>
        <dataItem name="legal_address" datatype="vchar2" columnOrder="38"
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
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Id1">
          <dataDescriptor expression="vcp.contact_id"
           descriptiveExpression="CONTACT_ID" order="1" width="22"
           precision="9"/>
        </dataItem>
        <dataItem name="doc_desc" datatype="vchar2" columnOrder="40"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Desc">
          <dataDescriptor expression="tit.brief"
           descriptiveExpression="DOC_DESC" order="2" width="30"/>
        </dataItem>
        <dataItem name="p_ser" datatype="vchar2" columnOrder="41" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Ser">
          <dataDescriptor expression="NVL ( cci.serial_nr , &apos;@&apos; )"
           descriptiveExpression="P_SER" order="3" width="50"/>
        </dataItem>
        <dataItem name="p_num" datatype="vchar2" columnOrder="42" width="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Num">
          <dataDescriptor expression="NVL ( cci.id_value , &apos;@&apos; )"
           descriptiveExpression="P_NUM" order="4" width="50"/>
        </dataItem>
        <dataItem name="pvidan" datatype="vchar2" columnOrder="43" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pvidan">
          <dataDescriptor
           expression="NVL ( cci.place_of_issue , &apos;@&apos; )"
           descriptiveExpression="PVIDAN" order="5" width="255"/>
        </dataItem>
        <dataItem name="data_v" datatype="vchar2" columnOrder="44"
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
       tp.DESCRIPTION product,
       vtct.BRIEF,
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
  WHERE agd.agent_report_id = :P_AG_REP_ID ; ]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
      <group name="G_DOG">
        <displayInfo x="5.71021" y="0.76074" width="1.71301" height="2.48145"
        />
        <dataItem name="IS_BREAK" oracleDatatype="number" columnOrder="56"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Break">
          <dataDescriptor expression="IS_BREAK"
           descriptiveExpression="IS_BREAK" order="12" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="IS_INCLUDED" oracleDatatype="number" columnOrder="57"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Included">
          <dataDescriptor expression="IS_INCLUDED"
           descriptiveExpression="IS_INCLUDED" order="13"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FIRST_PAY_DATE" datatype="date" oracleDatatype="date"
         columnOrder="49" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="First Pay Date">
          <dataDescriptor expression="FIRST_PAY_DATE"
           descriptiveExpression="FIRST_PAY_DATE" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="PAY_TERM" datatype="vchar2" columnOrder="50"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pay Term">
          <dataDescriptor expression="PAY_TERM"
           descriptiveExpression="PAY_TERM" order="6" width="500"/>
        </dataItem>
        <dataItem name="NOTICE_DATE" datatype="date" oracleDatatype="date"
         columnOrder="51" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date">
          <dataDescriptor expression="NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="SGP" oracleDatatype="number" columnOrder="52"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp">
          <dataDescriptor expression="SGP" descriptiveExpression="SGP"
           order="8" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="PRODUCT" datatype="vchar2" columnOrder="53"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product">
          <dataDescriptor expression="PRODUCT" descriptiveExpression="PRODUCT"
           order="9" width="255"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="54" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="10" width="30"/>
        </dataItem>
        <dataItem name="STATUS_BRIF" datatype="vchar2" columnOrder="55"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Brif">
          <dataDescriptor expression="STATUS_BRIF"
           descriptiveExpression="STATUS_BRIF" order="11" width="4000"/>
        </dataItem>
        <dataItem name="ZAKL_ROW_CNT" oracleDatatype="number" columnOrder="48"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Zakl Row Cnt">
          <dataDescriptor expression="ZAKL_ROW_CNT"
           descriptiveExpression="ZAKL_ROW_CNT" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="POL_NUM" datatype="vchar2" columnOrder="46"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="POL_NUM" descriptiveExpression="POL_NUM"
           order="3" width="2049"/>
        </dataItem>
        <dataItem name="STRAHOV_NAME" datatype="vchar2" columnOrder="47"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Strahov Name">
          <dataDescriptor expression="STRAHOV_NAME"
           descriptiveExpression="STRAHOV_NAME" order="4" width="4000"/>
        </dataItem>
        <dataItem name="AGENT_REPORT_ID1" oracleDatatype="number"
         columnOrder="45" width="22" defaultWidth="20000"
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
       nvl(sum(decode(vtct.BRIEF,'ДАВ',agd.SGP,0)),0) sgp_dav_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВР',agd.SGP,0)),0) sgp_davr_line,
       nvl(sum(decode(vtct.BRIEF,'PREM_RECR_AG_FIRST',agd.SGP,0)),0) sgp_first_ag_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВББ',agd.SGP,0)),0) sgp_davbb_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВ',agd.COMISSION_SUM,0)),0) COMISSION_SUM_dav_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВР',agd.COMISSION_SUM,0)),0) COMISSION_SUM_davr_line,
       nvl(sum(decode(vtct.BRIEF,'PREM_RECR_AG_FIRST',agd.COMISSION_SUM,0)),0) COMISSION_SUM_first_ag_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВББ',agd.COMISSION_SUM,0)),0) COMISSION_SUM_davbb_line,
       nvl(sum(decode(vtct.BRIEF,'ДАВ',agd.SGP,0)),0) sgp_dav_doc,
       nvl(sum(decode(vtct.BRIEF,'ДАВР',agd.SGP,0)),0) sgp_davr_doc,
       nvl(sum(decode(vtct.BRIEF,'PREM_RECR_AG_FIRST',agd.SGP,0)),0) sgp_first_ag_doc,
       nvl(sum(decode(vtct.BRIEF,'ДАВББ',agd.SGP,0)),0) sgp_davbb_doc,
       nvl(sum(decode(vtct.BRIEF,'ДАВ',agd.COMISSION_SUM,0)),0) COMISSION_SUM_dav_doc,
       nvl(sum(decode(vtct.BRIEF,'ДАВР',agd.COMISSION_SUM,0)),0) COMISSION_SUM_davr_doc,
       nvl(sum(decode(vtct.BRIEF,'PREM_RECR_AG_FIRST',agd.COMISSION_SUM,0)),0) COMISSION_SUM_first_ag_doc,
       nvl(sum(decode(vtct.BRIEF,'ДАВББ',agd.COMISSION_SUM,0)),0) COMISSION_SUM_davbb_doc
FROM  ven_agent_report_dav agd,
      V_T_PROD_COEF_TYPE vtct
where agd.agent_report_id = :P_AG_REP_ID
  and vtct.T_PROD_COEF_TYPE_ID = agd.PROD_COEF_TYPE_ID;]]>
      </select>
      <displayInfo x="0.81250" y="3.13538" width="0.69995" height="0.19995"/>
      <group name="G_SUM">
        <displayInfo x="0.19666" y="4.18945" width="2.22339" height="1.62695"
        />
        <dataItem name="sgp_dav_line" oracleDatatype="number" columnOrder="58"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dav Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВ&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAV_LINE" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davr_line" oracleDatatype="number"
         columnOrder="59" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davr Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВР&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAVR_LINE" order="2"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_first_ag_line" oracleDatatype="number"
         columnOrder="60" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp First Ag Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;PREM_RECR_AG_FIRST&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_FIRST_AG_LINE" order="3"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davbb_line" oracleDatatype="number"
         columnOrder="61" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davbb Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВББ&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAVBB_LINE" order="4"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_dav_line" oracleDatatype="number"
         columnOrder="62" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Dav Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВ&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAV_LINE" order="5"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davr_line" oracleDatatype="number"
         columnOrder="63" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davr Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВР&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAVR_LINE" order="6"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_first_ag_line" oracleDatatype="number"
         columnOrder="64" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum First Ag Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;PREM_RECR_AG_FIRST&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_FIRST_AG_LINE" order="7"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davbb_line" oracleDatatype="number"
         columnOrder="65" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davbb Line">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВББ&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAVBB_LINE" order="8"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_dav_doc" oracleDatatype="number" columnOrder="66"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dav Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВ&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAV_DOC" order="9"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davr_doc" oracleDatatype="number" columnOrder="67"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Davr Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВР&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAVR_DOC" order="10"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_first_ag_doc" oracleDatatype="number"
         columnOrder="68" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp First Ag Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;PREM_RECR_AG_FIRST&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_FIRST_AG_DOC" order="11"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davbb_doc" oracleDatatype="number"
         columnOrder="69" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davbb Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВББ&apos; , agd.SGP , 0 ) ) , 0 )"
           descriptiveExpression="SGP_DAVBB_DOC" order="12"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_dav_doc" oracleDatatype="number"
         columnOrder="70" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Dav Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВ&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAV_DOC" order="13"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davr_doc" oracleDatatype="number"
         columnOrder="71" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davr Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВР&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAVR_DOC" order="14"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_first_ag_doc" oracleDatatype="number"
         columnOrder="72" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum First Ag Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;PREM_RECR_AG_FIRST&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_FIRST_AG_DOC" order="15"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davbb_doc" oracleDatatype="number"
         columnOrder="73" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davbb Doc">
          <dataDescriptor
           expression="nvl ( sum ( decode ( vtct.BRIEF , &apos;ДАВББ&apos; , agd.COMISSION_SUM , 0 ) ) , 0 )"
           descriptiveExpression="COMISSION_SUM_DAVBB_DOC" order="16"
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
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>ОТЧЕТ АГЕНТА (ДАВ)</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>soldain</o:Author>
  <o:Template>bonus_agent_report</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>1</o:TotalTime>
  <o:Created>2007-06-26T07:52:00Z</o:Created>
  <o:LastSaved>2007-06-26T07:52:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>385</o:Words>
  <o:Characters>2201</o:Characters>
  <o:Lines>18</o:Lines>
  <o:Paragraphs>5</o:Paragraphs>
  <o:CharactersWithSpaces>2581</o:CharactersWithSpaces>
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
</xml><![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
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
	mso-hyphenate:none;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:AR-SA;}
h2
	{mso-style-next:Normal;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	mso-hyphenate:none;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-language:AR-SA;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-next:Subtitle;
	margin-top:70.85pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	mso-hyphenate:none;
	tab-stops:334.45pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:AR-SA;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:18.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	mso-hyphenate:none;
	font-size:11.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:AR-SA;}
p.MsoSubtitle, li.MsoSubtitle, div.MsoSubtitle
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	text-align:center;
	mso-pagination:widow-orphan;
	mso-outline-level:2;
	mso-hyphenate:none;
	font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:AR-SA;}
p.MsoDocumentMap, li.MsoDocumentMap, div.MsoDocumentMap
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	mso-hyphenate:none;
	background:navy;
	font-size:10.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:AR-SA;}
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
	mso-list:l1 level1 lfo2;
	mso-hyphenate:none;
	tab-stops:14.2pt list 28.5pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:AR-SA;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:27.0pt 37.3pt 26.95pt 45.0pt;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:12;
	mso-list-type:simple;
	mso-list-template-ids:12;
	mso-list-name:WW8Num13;}
@list l0:level1
	{mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:13;
	mso-list-template-ids:13;}
@list l1:level1
	{mso-level-start-at:2;
	mso-level-style-link:Обычный1;
	mso-level-tab-stop:28.5pt;
	mso-level-number-position:left;
	margin-left:28.5pt;
	text-indent:-19.5pt;}
@list l1:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:19.5pt;
	mso-level-number-position:left;
	margin-left:19.5pt;
	text-indent:-19.5pt;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:90.0pt;
	mso-level-number-position:left;
	margin-left:90.0pt;
	text-indent:-90.0pt;}
@list l2
	{mso-list-id:14;
	mso-list-template-ids:14;
	mso-list-name:WW8Num15;}
@list l2:level1
	{mso-level-start-at:0;
	mso-level-number-format:bullet;
	mso-level-text:-;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	mso-ascii-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
@list l2:level2
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level3
	{mso-level-start-at:2;
	mso-level-text:%3;
	mso-level-tab-stop:117.0pt;
	mso-level-number-position:left;
	margin-left:117.0pt;
	text-indent:-18.0pt;}
@list l2:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level5
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level6
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:216.0pt;
	mso-level-number-position:right;
	text-indent:-9.0pt;}
@list l2:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level8
	{mso-level-number-format:alpha-lower;
	mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level9
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:324.0pt;
	mso-level-number-position:right;
	text-indent:-9.0pt;}
@list l3
	{mso-list-id:264269997;
	mso-list-type:hybrid;
	mso-list-template-ids:675313880 -866501572 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l3:level1
	{mso-level-start-at:3;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Times New Roman CYR";
	mso-bidi-font-family:"Times New Roman";}
@list l4
	{mso-list-id:1357536036;
	mso-list-type:hybrid;
	mso-list-template-ids:-1726429256 -1932481432 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l4:level1
	{mso-level-start-at:4;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:"Times New Roman CYR";
	mso-bidi-font-family:"Times New Roman";}
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


<body lang=EN-US style='tab-interval:35.4pt'>
<%
/*AGENT INFO*/
String PS = new String("");
String PNUM = new String("");
String PVIDAN= new String("");
String DATAV = new String("");
String AGINN= new String();
String PENS = new String();

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
  if (PNUM.equals("@"))   PNUM = "____________";
  if (PS.equals("@"))   PS = "____";
  if (PVIDAN.equals("@")) PVIDAN = "_____________________________";
  if (DATAV.equals("@"))  DATAV = "__________";
}
 
%>

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

<rw:foreach id="G_AGENT_REPORT" src="G_AGENT_REPORT">
<rw:foreach id="G_SUM" src="G_SUM">

<rw:getValue id="REPORT_DATE" src="REPORT_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_BEGIN" src="DATE_BEGIN" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DATE_END" src="DATE_END" formatMask="DD.MM.YYYY"/>
<rw:getValue id="STATUS_NAME" src="STATUS_NAME"/>
<rw:getValue id="CHIEF_NAME_GEN" src="dir_name_genitive"/>
<rw:getValue id="DIR_NAME" src="dir_name"/>
<rw:getValue id="DIR_NAME_INITIAL" src="dir_name_initial"/>
<rw:getValue id="AG_NAME_INITIAL" src="ag_name_initial"/>
<rw:getValue id="AGNAME" src="AGNAME"/>
<rw:getValue id="STATUS_NAME_NEXT" src="STATUS_NAME_NEXT"/>
<rw:getValue id="AV_SUM" src="AV_SUM" formatMask="999999990.99"/>


<p class=MsoTitle style='margin-top:6.0pt;mso-outline-level:1'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ
АГЕНТА №  </span><span style='font-size:11.0pt;mso-bidi-font-size:10.0pt;
font-family:"Times New Roman";mso-ansi-language:EN-US'> </span><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><span
style='mso-spacerun:yes'> </span><a name="report_number">
ДАВ-<rw:field id="F_act_num" src="act_num"> &Field </rw:field></a><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>к
Агентскому договору № <a name="treaty_number">
<rw:field id="F_dognum" src="dognum"> &Field </rw:field></a><o:p></o:p></span></b></p>

<p class=MsoTitle align=left style='margin-top:6.0pt;text-align:left'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>г.
Москва<span style='mso-tab-count:5'>                                                                                                                                         </span><a
name="report_date"><%=REPORT_DATE%></a><o:p></o:p></span></p>

<p align="center" class=MsoNormal style='text-autospace:ideograph-numeric'><span
style='mso-ansi-language:RU'>за период с <a name="date_from"><%=DATE_BEGIN%></a>
по <a name="date_to"><%=DATE_END%></a><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:36.0pt'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'><%=ORGNAME%>,
именуемое в дальнейшем Страховщик, в лице Смышляева Юрия Олеговича, действующего
на основании Доверенности № 2005/02/17, выданной 15 ноября 2005 года, с одной
стороны, и <a name="agent_name"><b style='mso-bidi-font-weight:normal'><%=AGNAME%></b>
</a>, паспорт серии <a name="doc_ser"><%=PS%></a> № <a name="doc_no"><%=PNUM%></a>,
именуемый(ая) в дальнейшем АГЕНТ, с другой стороны, составили и утвердили
настоящий отчет к Агентскому соглашению о нижеследующем.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt;text-autospace:
ideograph-numeric'><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>1. За период с <a name="date_from_1"><%=DATE_BEGIN%></a>
по <a name="date_to_1"><%=DATE_END%></a> при посредничестве <span
style='text-transform:uppercase'>Агента, </span>имеющему на указанный период
статус <a name="agent_status"><b style='mso-bidi-font-weight:normal'><%=STATUS_NAME%></b></a>,
были заключены следующие договоры страхования, первый взнос по которым был
оплачен в полном объеме:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt;text-autospace:
ideograph-numeric'><span style='mso-ansi-language:RU'><span style='mso-tab-count:
5'>                                                     </span><o:p></o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='margin-left:-.25pt;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
   <td width=68 valign=top style='width:50.65pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Номер договора<o:p></o:p></span></b></p>
   </td>
   <td width=156 valign=top style='width:117.0pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Страхователь<o:p></o:p></span></b></p>
   </td>
   <td width=96 valign=top style='width:72.0pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Программа страхования<o:p></o:p></span></b></p>
   </td>
   <td width=108 valign=top style='width:81.0pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Периодичность уплаты взносов<o:p></o:p></span></b></p>
   </td>
   <td width=93 valign=top style='width:70.05pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата поступления Заявления
   на страхование в Компанию<o:p></o:p></span></b></p>
   </td>
   <td width=75 valign=top style='width:55.95pt;border:solid black 1.0pt;
   border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Дата оплаты первого взноса<o:p></o:p></span></b></p>
   </td>
   <td width=100 valign=top style='width:74.85pt;border:solid black 1.0pt;
   mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
   char'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
   mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Годовая премия по договору
   за вычетом суммы административных издержек<o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
<rw:foreach id="G_DOG_DAF_IN" src="G_DOG">
<rw:getValue id="pol_num_BRIF_DAF_IN" src="pol_num"/>
<rw:getValue id="strahov_name_BRIF_DAF_IN" src="strahov_name"/>
<rw:getValue id="product_BRIF_DAF_IN" src="product"/>
<rw:getValue id="pay_term_BRIF_DAF_IN" src="pay_term"/>
<rw:getValue id="NOTICE_DATE_BRIF_DAF_IN" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="first_pay_date_BRIF_DAF_IN" src="first_pay_date" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP_BRIF_DAF_IN" src="SGP" formatMask="999999990.99"/>
<rw:getValue id="IS_BREAK_DAF_IN" src="IS_BREAK"/>
<rw:getValue id="BRIEF_IN" src="BRIEF"/>
<%Double_isbreak = Double.valueOf(IS_BREAK_DAF_IN).doubleValue();%>
<%
if ( ( Double_isbreak == 0) && (BRIEF_IN.equals("ДАВ") ) ) {
SUM_SGP = SUM_SGP + Double.valueOf(SGP_BRIF_DAF_IN).doubleValue();
%>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid'>
  <td width=68 valign=top style='width:50.65pt;border:solid black 1.0pt;
  border-top:none;mso-border-top-alt:solid black .5pt;mso-border-alt:solid black .5pt;
  mso-border-right-alt:solid black .75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><a name="table_1"><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><span
  style='mso-spacerun:yes'> </span></span></a><span lang=EN-US
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt'><o:p><%=pol_num_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
  mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:black;mso-border-style-alt:
  solid;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='layout-grid-mode:char'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p><%=strahov_name_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;mso-border-top-alt:
  solid black .5pt;mso-border-left-alt:solid black .75pt;mso-border-top-alt:
  .5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;mso-border-right-alt:
  .75pt;mso-border-color-alt:black;mso-border-style-alt:solid;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='layout-grid-mode:char'><span style='font-size:8.0pt;
  mso-ansi-language:RU'><o:p><%=product_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
  mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:black;mso-border-style-alt:
  solid;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='font-size:8.0pt;mso-ansi-language:RU'><o:p><%=pay_term_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=93 valign=top style='width:70.05pt;border-top:none;border-left:
  none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
  mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:black;mso-border-style-alt:
  solid;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=NOTICE_DATE_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=75 valign=top style='width:55.95pt;border-top:none;border-left:
  none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
  mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  mso-border-top-alt:.5pt;mso-border-left-alt:.75pt;mso-border-bottom-alt:.5pt;
  mso-border-right-alt:.75pt;mso-border-color-alt:black;mso-border-style-alt:
  solid;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=first_pay_date_BRIF_DAF_IN%></o:p></span></p>
  </td>
  <td width=100 valign=top style='width:74.85pt;border-top:none;border-left:
  none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
  mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  mso-border-alt:solid black .5pt;mso-border-left-alt:solid black .75pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right;layout-grid-mode:char'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p><%=SGP_BRIF_DAF_IN%></o:p></span></p>
  </td>
 </tr>
 <%}%>
</rw:foreach> 
</table>

<p class=MsoBodyTextIndent style='margin-left:0cm'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><o:p>&nbsp;</o:p></i></b></p>

<p class=MsoNormal style='text-indent:18.0pt;text-autospace:ideograph-numeric'><a
name=canceled><span style='font-family:"Times New Roman CYR";mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>были расторгнуты следующие договоры страхования первого года действия,
заключенные <span style='text-transform:uppercase'>Страховщиком </span>при
посредничестве <span style='text-transform:uppercase'>Агента</span>:</span></a><span
style='mso-bookmark:canceled'><span style='mso-ansi-language:RU'><span
style='mso-tab-count:5'>                                                 </span>
<o:p></o:p></span></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='margin-left:-.25pt;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=67 valign=top style='width:50.4pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Номер договора<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=164 valign=top style='width:123.2pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Страхователь<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=116 valign=top style='width:86.85pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Программа страхования<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.1pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Периодичность уплаты взносов<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.15pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Дата поступления Заявления на страхование в Компанию<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.15pt;border:solid black 1.0pt;
  border-right:none;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Дата оплаты первого взноса<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=88 valign=top style='width:65.65pt;border:solid black 1.0pt;
  mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'>Годовая премия по договору за вычетом суммы административных издержек<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
 </tr>
 <rw:foreach id="G_DOG_DAF_OUT" src="G_DOG">
<rw:getValue id="pol_num_BRIF_DAF_OUT" src="pol_num"/>
<rw:getValue id="strahov_name_BRIF_DAF_OUT" src="strahov_name"/>
<rw:getValue id="product_BRIF_DAF_OUT" src="product"/>
<rw:getValue id="pay_term_BRIF_DAF_OUT" src="pay_term"/>
<rw:getValue id="NOTICE_DATE_BRIF_DAF_OUT" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="first_pay_date_BRIF_DAF_OUT" src="first_pay_date" formatMask="DD.MM.YYYY"/>
<rw:getValue id="SGP_BRIF_DAF_OUT" src="SGP"/>
<rw:getValue id="IS_BREAK_DAF_OUT" src="IS_BREAK"/>
<rw:getValue id="BRIEF_OUT" src="BRIEF"/>
<%Double_isbreak = Double.valueOf(IS_BREAK_DAF_OUT).doubleValue();%>
<%
if ( ( Double_isbreak == 1) && (BRIEF_OUT.equals("ДАВ")) ) {
SUM_SGP = SUM_SGP + Double.valueOf(SGP_BRIF_DAF_OUT).doubleValue();
%>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=67 valign=top style='width:50.4pt;border-top:none;border-left:solid black 1.0pt;
  border-bottom:solid black 1.0pt;border-right:none;mso-border-left-alt:solid black .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><i style='mso-bidi-font-style:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><o:p><%=pol_num_BRIF_DAF_OUT%></o:p></span></i></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=164 valign=top style='width:123.2pt;border-top:none;border-left:
  solid black 1.0pt;border-bottom:solid black 1.0pt;border-right:none;
  mso-border-left-alt:solid black .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=strahov_name_BRIF_DAF_OUT%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=116 valign=top style='width:86.85pt;border-top:none;border-left:
  solid black 1.0pt;border-bottom:solid black 1.0pt;border-right:none;
  mso-border-left-alt:solid black .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=product_BRIF_DAF_OUT%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.1pt;border-top:none;border-left:solid black 1.0pt;
  border-bottom:solid black 1.0pt;border-right:none;mso-border-left-alt:solid black .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=pay_term_BRIF_DAF_OUT%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  solid black 1.0pt;border-bottom:solid black 1.0pt;border-right:none;
  mso-border-left-alt:solid black .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=NOTICE_DATE_BRIF_DAF_OUT%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=87 valign=top style='width:65.15pt;border-top:none;border-left:
  solid black 1.0pt;border-bottom:solid black 1.0pt;border-right:none;
  mso-border-left-alt:solid black .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=first_pay_date_BRIF_DAF_OUT%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
  <td width=88 valign=top style='width:65.65pt;border:solid black 1.0pt;
  border-top:none;mso-border-left-alt:solid black .5pt;mso-border-bottom-alt:
  solid black .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='mso-bookmark:canceled'></span>
  <p class=MsoNormal align=center style='text-align:center;layout-grid-mode:
  char'><span style='mso-bookmark:canceled'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:
  RU'><o:p><%=format.format(Double.valueOf(SGP_BRIF_DAF_OUT).doubleValue())%></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:canceled'></span>
 </tr>
 <%}%>
</rw:foreach> 

</table>

<span style='mso-bookmark:canceled'></span>

<p class=MsoNormal style='margin-left:18.0pt;text-autospace:ideograph-numeric'><span
lang=EN-US style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;text-autospace:ideograph-numeric'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'>За период с <span style='mso-spacerun:yes'> </span><a
name="date_from_2"><%=DATE_BEGIN%></a> <span style='mso-spacerun:yes'> </span>по <span
style='mso-spacerun:yes'> </span><a name="date_to_2"><%=DATE_END%></a> <span
style='mso-spacerun:yes'> </span><span style='text-transform:uppercase'>агенту</span>
в соответствии с условиями агентского договора № <a name="treaty_number_1"><rw:field id="F_dognum" src="dognum"> &Field </rw:field></a>
выплачивается дополнительное агентское вознаграждение по итогам работы за месяц
в размере <span style='mso-spacerun:yes'> </span><a name="comm_amount">
<rw:field id="f_p_COMISSION_SUM_dav_doc" src="COMISSION_SUM_dav_doc" formatMask="999999990.99"/></a>
<span style='mso-spacerun:yes'> </span>руб.<o:p></o:p></span></p>

<p class=MsoNormal style='text-indent:18.0pt;tab-stops:0cm;text-autospace:ideograph-numeric'><span
style='mso-ansi-language:RU'>План по СГП по новым договорам страхования
составляет <span style='mso-spacerun:yes'> </span><a name="plan_amount">
<rw:field id="f_p_sgp_dav_doc" src="sgp_dav_doc" formatMask="999999990.99"/>.</a><o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;tab-stops:18.0pt;text-autospace:
ideograph-numeric'><span lang=X-NONE style='mso-ansi-language:X-NONE;
mso-fareast-language:RU'>Сумма годовой премии по договорам страхования,
заключенным при посредничестве Агента </span><span style='mso-ansi-language:
RU'><span style='mso-spacerun:yes'> </span>за период<span
style='mso-spacerun:yes'>  </span>с <span style='mso-spacerun:yes'> </span><a
name="date_from_3"><%=DATE_BEGIN%></a> <span style='mso-spacerun:yes'> </span>по <span
style='mso-spacerun:yes'> </span><a name="date_to_3"><%=DATE_END%></a> <span
style='mso-spacerun:yes'> </span>составляет <span
style='mso-spacerun:yes'> </span><a name="fact_amount"><%=format.format(SUM_SGP)%>.</a><o:p></o:p></span></p>

<p class=MsoNormal style='text-indent:18.0pt;tab-stops:0cm;text-autospace:ideograph-numeric'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<rw:getValue id="p_COMISSION_SUM_davr_doc1" src="COMISSION_SUM_davr_doc" formatMask="999999990.99"/>
<rw:getValue id="p_COMISSION_SUM_first_ag_doc1" src="COMISSION_SUM_first_ag_doc" formatMask="999999990.99"/>
<%
Double_isbreak = Double.valueOf(p_COMISSION_SUM_davr_doc1).doubleValue();
Double_isbreak = Double_isbreak + Double.valueOf(p_COMISSION_SUM_first_ag_doc1).doubleValue();
%>

<p class=MsoNormal style='margin-left:18.0pt;text-align:justify;tab-stops:36.0pt;
text-autospace:ideograph-numeric'><span style='mso-ansi-language:RU'>2. Результат
ДАВР за заключение договоров страхования рекомендованными АГЕНТОМ агентами<span
style='mso-spacerun:yes'>  </span><a name="recr_amount">
<rw:field id="f_p_COMISSION_SUM_davr_doc" src="COMISSION_SUM_davr_doc" formatMask="999999990.99"/></a>,
таким образом дополнительное агентское вознаграждение за привлечение новых агентов
составляет <a name="recr_total"><%=format.format(Double_isbreak)%></a>, в том числе
единовременная<span style='mso-spacerun:yes'>  </span>премия за привлечение
первого агента <span style='mso-spacerun:yes'> </span><a name="first_bonus">
<rw:field id="f_p_COMISSION_SUM_first_ag_doc" src="COMISSION_SUM_first_ag_doc" formatMask="999999990.99"/>.</a><o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;text-align:justify;tab-stops:36.0pt;
text-autospace:ideograph-numeric'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;text-align:justify;tab-stops:36.0pt;
text-autospace:ideograph-numeric'><span style='mso-ansi-language:RU'>3.<span
style='mso-spacerun:yes'>  </span>Результат ДАВББ за заключение договоров
страхования Банками и Брокерами, привлеченными при содействии агента,
составляет <rw:field id="f_p_COMISSION_SUM_davbb_doc" src="COMISSION_SUM_davbb_doc" formatMask="999999990.99"/>.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt;tab-stops:0cm;
text-autospace:ideograph-numeric'><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<ol style='margin-top:0cm' start=4 type=1>
 <li class=MsoNormal style='text-align:justify;mso-list:l4 level1 lfo5;
     tab-stops:list 36.0pt;text-autospace:ideograph-numeric'><span
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span>Итого размер
     агентского вознаграждения за период с <a name="date_from_4"><%=DATE_BEGIN%></a>
     по <a name="date_to_4"><%=DATE_END%></a> составляет: <span
     style='mso-spacerun:yes'> </span></span><a name="total_amount"><span
     style='mso-ansi-language:RU'><%=AV_SUM%> </span></a>.<o:p></o:p></span></li>
 <li class=MsoNormal style='text-align:justify;mso-list:l4 level1 lfo5;
     tab-stops:list 36.0pt;text-autospace:ideograph-numeric'><span
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU'>Сумма дополнительного агентского вознаграждения,
     указанная в п. 4., определена правильно.<o:p></o:p></span></li>
 <li class=MsoNormal style='text-align:justify;mso-list:l4 level1 lfo5;
     tab-stops:list 36.0pt;text-autospace:ideograph-numeric'><span
     style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
     mso-ansi-language:RU'>Статус АГЕНТА на следующий отчетный период: <a
     name="next_status"><b style='mso-bidi-font-weight:normal'><%=STATUS_NAME_NEXT%></b></a>.<o:p></o:p></span></li>
</ol>

<p class=MsoNormal style='text-align:justify;text-autospace:ideograph-numeric'><span
style='font-family:"Times New Roman CYR";mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=328 valign=top style='width:246.35pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyTextIndent align=center style='margin-left:0cm;text-align:
  center;layout-grid-mode:char'>СТРАХОВЩИК<span lang=EN-US style='mso-ansi-language:
  EN-US'><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent align=center style='margin-left:0cm;text-align:
  center;layout-grid-mode:char'>Смышляев Ю. О.</p>
  </td>
  <td width=328 valign=top style='width:246.35pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyTextIndent align=center style='margin-left:0cm;text-align:
  center;layout-grid-mode:char'>АГЕНТ<span lang=EN-US style='mso-ansi-language:
  EN-US'><o:p></o:p></span></p>
  <p class=MsoBodyTextIndent align=center style='margin-left:0cm;text-align:
  center;layout-grid-mode:char'><a name=shortname><span lang=EN-US
  style='mso-ansi-language:EN-US'><span style='mso-spacerun:yes'> <%=AG_NAME_INITIAL%></span></span></a><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

</rw:foreach>
</rw:foreach>

</div>

</body>

</html>

</rw:report>
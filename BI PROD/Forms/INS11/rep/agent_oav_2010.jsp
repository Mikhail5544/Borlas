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
<report name="ag_dog_dav_model" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="AG_DOG_OAV" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="p_ag_perfomed_work_act_id" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="p_ag_roll_id" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="long_name" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="short_name" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="dover" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="plan_sgp" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="mn" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="sg" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="ag_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
     <userParameter name="dt" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="dt_b" datatype="date" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="dt_e" datatype="date" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="mindt" datatype="date" width="100"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_AGENT_REPORT">
      <select canParse="no">
      <![CDATA[SELECT count(1) over() row_cnt,
agr.ag_perfomed_work_act_id agent_report_id, agch.ag_contract_header_id, hed.num act_num,
       to_char(hed.date_end,'dd.mm.yyyy') report_date, to_char(hed.date_begin,'dd.mm.yyyy') date_begin, to_char(hed.date_end,'dd.mm.yyyy') date_end, con.contact_id,
       agch.num dognum, ent.obj_name (con.ent_id, con.contact_id) agname,
	   agr.sum av_sum,
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
           ) dir_name,
	   to_char(agch.date_begin,'dd.mm.yyyy') ag_date,
       dep.name filial,
       to_char(hed.date_begin,'dd.mm.yyyy')||'-'||to_char(hed.date_end,'dd.mm.yyyy') month,
       to_char(hed.date_begin,'yyyy') year,
       (select case nvl(cag.leg_pos,0) when 0 then 'ФЛ' else 'ПБОЮЛ' end
       from ag_contract cag where cag.ag_contract_id = pkg_agent_1.get_status_by_date(agch.ag_contract_header_id,hed.date_end)) leg_pos

  FROM ag_perfomed_work_act agr
       join ven_ag_roll ved on (ved.ag_roll_id = agr.ag_roll_id)
       join ven_ag_roll_header hed on (hed.ag_roll_header_id = ved.ag_roll_header_id)
       JOIN ven_ag_contract_header agch ON (agch.ag_contract_header_id = agr.ag_contract_header_id)
       JOIN ven_contact con ON (agch.agent_id = con.contact_id)
       LEFT OUTER JOIN ven_ag_category_agent vca ON (vca.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, hed.date_end) )
LEFT OUTER JOIN ven_ag_category_agent vca_n 
        ON (vca_n.ag_category_agent_id = PKG_AGENT_1.get_agent_cat_by_date(agch.AG_CONTRACT_HEADER_ID, hed.date_end+1) )
       LEFT OUTER JOIN ven_department dep ON (agch.agency_id = dep.department_id )
       LEFT OUTER JOIN ven_dept_executive dept_exe ON (agch.agency_id = dept_exe.department_id)
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
              pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id,hed.date_end)
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
              pkg_agent_1.get_agent_status_by_date(agch.ag_contract_header_id,hed.date_end+1)
          )       
  WHERE agr.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id and ved.ag_roll_id = :p_ag_roll_id;]]>
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
		<dataItem name="REPORT_DATE" datatype="vchar2" columnOrder="20"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Report Date">
          <dataDescriptor expression="REPORT_DATE"
           descriptiveExpression="REPORT_DATE" order="5" width="250"/>
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
		<dataItem name="DATE_BEGIN" datatype="vchar2" columnOrder="15"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Begin">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="6" width="250"/>
        </dataItem>
		<dataItem name="DATE_END" datatype="vchar2" columnOrder="16"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date End">
          <dataDescriptor expression="DATE_END"
           descriptiveExpression="DATE_END" order="7" width="250"/>
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
		<dataItem name="AG_DATE" datatype="vchar2" columnOrder="30"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ag Date">
          <dataDescriptor expression="AG_DATE"
           descriptiveExpression="AG_DATE" order="18" width="250"/>
        </dataItem>
	    <dataItem name="FILIAL" datatype="vchar2" columnOrder="31"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Filial">
          <dataDescriptor expression="FILIAL"
           descriptiveExpression="FILIAL" order="19" width="250"/>
        </dataItem>
		<dataItem name="MONTH" datatype="vchar2" columnOrder="32"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Month">
          <dataDescriptor expression="MONTH"
           descriptiveExpression="MONTH" order="20" width="250"/>
        </dataItem>
		<dataItem name="YEAR" datatype="vchar2" columnOrder="33"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Year">
          <dataDescriptor expression="YEAR"
           descriptiveExpression="YEAR" order="21" width="250"/>
        </dataItem>
		<dataItem name="LEG_POS" datatype="vchar2" columnOrder="34"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Leg Pos">
          <dataDescriptor expression="LEG_POS"
           descriptiveExpression="LEG_POS" order="22" width="250"/>
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
     AND UPPER (tit.brief) IN ('PASS_RF','PASS_IN')
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
      <![CDATA[ SELECT decode(pp.pol_ser, null, pp.pol_num, pp.pol_ser || '-' || pp.pol_num) pol_num,
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) strahov_name,
       tp.DESCRIPTION product,
       tplo.DESCRIPTION progr,
	   appad.year_of_insurance year_ins,
       apdp.insurance_period years,
       asa2.name stat_agent,
       to_char(pay.reg_date,'dd.mm.yyyy') first_pay_date,
       to_char(case when apt.sum_premium > 0 then apt.sum_premium else 0 end,'99999990D99') sum_opl,
       to_char(case when apt.sum_premium < 0 then apt.sum_premium else 0 end,'99999990D99') sum_vozv,
       apt.sav,
       to_char(case when apt.sum_commission > 0 then apt.sum_commission else 0 end,'99999990D99') comm_nach,
       to_char(case when apt.sum_commission < 0 then apt.sum_commission else 0 end,'99999990D99') comm_uder,
       to_char(case when nvl(apt.is_indexing,0) = 1 then apt.sum_premium else 0 end,'99999990D99') idx
FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       ag_perf_work_trans apt,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       ven_ac_payment epg,
       ven_ac_payment pay,
       ven_ac_payment bank_d,
       t_prod_line_option tplo,
       t_product tp,
       ag_stat_agent asa,
       ag_stat_agent asa2,
       ag_stat_hist ash,
       T_CONTACT_TYPE tct,
       t_payment_terms pt
 WHERE 1=1--arh.num = '000109'
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   and apt.sum_commission <> 0
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND apt.ag_perf_work_pay_doc_id= appad.ag_perf_work_pay_doc_id (+)
   AND pp.policy_id = appad.policy_id
   AND pp.pol_header_id = ph.policy_header_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND appad.epg_payment_id = epg.payment_id
   AND appad.pay_payment_id = pay.payment_id
   AND appad.pay_bank_doc_id= bank_d.payment_id
   AND tplo.ID = apt.t_prod_line_option_id
   AND asa.ag_stat_agent_id = apw.status_id
   AND ash.ag_stat_hist_id = apw.ag_stat_hist_id
   AND tct.ID = apdp.ag_leg_pos
   AND ph.product_id = tp.product_id
   AND pt.ID = apdp.pay_term
   AND asa2.ag_stat_agent_id = pkg_renlife_utils.get_ag_stat_id(ach.ag_contract_header_id, epg.plan_date,2)
   AND apw.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id
   ORDER BY 2, 5, 6, 7;]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
      <group name="G_DOG">
        <displayInfo x="5.71021" y="0.76074" width="1.71301" height="2.48145"
        />
	   <dataItem name="pol_num" datatype="vchar2" columnOrder="5"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="pol num">
          <dataDescriptor expression="pol_num"
           descriptiveExpression="pol_num" order="1" width="4000"/>
        </dataItem>
		<dataItem name="strahov_name" datatype="vchar2" columnOrder="6"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="strahov name">
          <dataDescriptor expression="strahov_name"
           descriptiveExpression="strahov_name" order="2" width="4000"/>
        </dataItem>
		<dataItem name="product" datatype="vchar2" columnOrder="7"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="product">
          <dataDescriptor expression="product"
           descriptiveExpression="product" order="3" width="4000"/>
        </dataItem>
		<dataItem name="progr" datatype="vchar2" columnOrder="8"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="progr">
          <dataDescriptor expression="progr"
           descriptiveExpression="progr" order="4" width="4000"/>
        </dataItem>
		<dataItem name="year_ins" oracleDatatype="number" columnOrder="9"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="year ins">
          <dataDescriptor expression="year_ins"
           descriptiveExpression="year_ins" order="5" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="years" oracleDatatype="number" columnOrder="10"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="years">
          <dataDescriptor expression="years"
           descriptiveExpression="years" order="6" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="stat_agent" datatype="vchar2" columnOrder="11"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="stat agent">
          <dataDescriptor expression="stat_agent"
           descriptiveExpression="stat_agent" order="7" width="4000"/>
        </dataItem>
		<dataItem name="first_pay_date" datatype="vchar2" columnOrder="12"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="first pay date">
          <dataDescriptor expression="first_pay_date"
           descriptiveExpression="first_pay_date" order="8" width="4000"/>
        </dataItem>
		<dataItem name="sum_opl" oracleDatatype="number" columnOrder="13"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sum opl">
          <dataDescriptor expression="sum_opl"
           descriptiveExpression="sum_opl" order="9" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="sum_vozv" oracleDatatype="number" columnOrder="14"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sum vozv">
          <dataDescriptor expression="sum_vozv"
           descriptiveExpression="sum_vozv" order="10" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="sav" oracleDatatype="number" columnOrder="15"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sav">
          <dataDescriptor expression="sav"
           descriptiveExpression="sav" order="11" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="comm_nach" oracleDatatype="number" columnOrder="16"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="comm nach">
          <dataDescriptor expression="comm_nach"
           descriptiveExpression="comm_nach" order="12" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="comm_uder" oracleDatatype="number" columnOrder="17"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="comm uder">
          <dataDescriptor expression="comm_uder"
           descriptiveExpression="comm_uder" order="13" width="22"
           precision="9"/>
        </dataItem>
		<dataItem name="idx" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="110000" defaultHeight="10000"
         columnFlags="1" defaultLabel="idx">
          <dataDescriptor expression="idx"
           descriptiveExpression="idx" order="14" width="22"
           precision="9"/>
        </dataItem>
	  </group>
    </dataSource>
    <dataSource name="Q_SUM">
      <select>
      <![CDATA[      SELECT 
       to_char(nvl(sum(agd.sgp1+agd.sgp2),0),'99999990D99') sgp_dav_line,
       0 sgp_davr_line,
       0 sgp_first_ag_line,
       0 sgp_davbb_line,
       to_char(nvl(sum(agd.sum),0),'99999990D99') COMISSION_SUM_dav_line,
       0 COMISSION_SUM_davr_line,
       0 COMISSION_SUM_first_ag_line,
       0 COMISSION_SUM_davbb_line,
       nvl(sum(agd.sgp2),0) sgp_dav_doc,
       0 sgp_davr_doc,
       0 sgp_first_ag_doc,
       0 sgp_davbb_doc,
       nvl(sum(agd.sum),0) COMISSION_SUM_dav_doc,       
       0 COMISSION_SUM_dav_doc,
       0 COMISSION_SUM_first_ag_doc,
       0 COMISSION_SUM_davbb_doc
FROM  ag_perfomed_work_act agd
where agd.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id;]]>
      </select>
      <displayInfo x="0.81250" y="3.13538" width="0.69995" height="0.19995"/>
      <group name="G_SUM">
        <displayInfo x="0.19666" y="4.18945" width="2.22339" height="1.62695"
        />
        <dataItem name="sgp_dav_line" datatype="vchar2" columnOrder="58"
         width="250" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sgp dav line">
          <dataDescriptor expression="sgp_dav_line"
           descriptiveExpression="sgp_dav_line" order="1" width="250"/>
        </dataItem>
        <dataItem name="sgp_davr_line" oracleDatatype="number"
         columnOrder="59" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davr Line">
          <dataDescriptor
           expression="sgp_davr_line"
           descriptiveExpression="SGP_DAVR_LINE" order="2"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_first_ag_line" oracleDatatype="number"
         columnOrder="60" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp First Ag Line">
          <dataDescriptor
           expression="sgp_first_ag_line"
           descriptiveExpression="SGP_FIRST_AG_LINE" order="3"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davbb_line" oracleDatatype="number"
         columnOrder="61" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davbb Line">
          <dataDescriptor
           expression="sgp_davbb_line"
           descriptiveExpression="SGP_DAVBB_LINE" order="4"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_dav_line" oracleDatatype="number"
         columnOrder="62" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Dav Line">
          <dataDescriptor
           expression="nvl(sum(agd.sum),0)"
           descriptiveExpression="COMISSION_SUM_DAV_LINE" order="5"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davr_line" oracleDatatype="number"
         columnOrder="63" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davr Line">
          <dataDescriptor
           expression="COMISSION_SUM_davr_line"
           descriptiveExpression="COMISSION_SUM_DAVR_LINE" order="6"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_first_ag_line" oracleDatatype="number"
         columnOrder="64" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum First Ag Line">
          <dataDescriptor
           expression="COMISSION_SUM_first_ag_line"
           descriptiveExpression="COMISSION_SUM_FIRST_AG_LINE" order="7"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davbb_line" oracleDatatype="number"
         columnOrder="65" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davbb Line">
          <dataDescriptor
           expression="COMISSION_SUM_davbb_line"
           descriptiveExpression="COMISSION_SUM_DAVBB_LINE" order="8"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_dav_doc" oracleDatatype="number" columnOrder="66"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Dav Doc">
          <dataDescriptor
           expression="nvl(sum(agd.sgp1),0)"
           descriptiveExpression="SGP_DAV_DOC" order="9"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davr_doc" oracleDatatype="number" columnOrder="67"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sgp Davr Doc">
          <dataDescriptor
           expression="sgp_davr_doc"
           descriptiveExpression="SGP_DAVR_DOC" order="10"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_first_ag_doc" oracleDatatype="number"
         columnOrder="68" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp First Ag Doc">
          <dataDescriptor
           expression="sgp_first_ag_doc"
           descriptiveExpression="SGP_FIRST_AG_DOC" order="11"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="sgp_davbb_doc" oracleDatatype="number"
         columnOrder="69" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Sgp Davbb Doc">
          <dataDescriptor
           expression="sgp_davbb_doc"
           descriptiveExpression="SGP_DAVBB_DOC" order="12"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_dav_doc" oracleDatatype="number"
         columnOrder="70" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Dav Doc">
          <dataDescriptor
           expression="nvl(sum(agd.sum),0)"
           descriptiveExpression="COMISSION_SUM_DAV_DOC" order="13"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davr_doc" oracleDatatype="number"
         columnOrder="71" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davr Doc">
          <dataDescriptor
           expression="COMISSION_SUM_dav_doc"
           descriptiveExpression="COMISSION_SUM_DAVR_DOC" order="14"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_first_ag_doc" oracleDatatype="number"
         columnOrder="72" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum First Ag Doc">
          <dataDescriptor
           expression="COMISSION_SUM_first_ag_doc"
           descriptiveExpression="COMISSION_SUM_FIRST_AG_DOC" order="15"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="COMISSION_SUM_davbb_doc" oracleDatatype="number"
         columnOrder="73" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Comission Sum Davbb Doc">
          <dataDescriptor
           expression="COMISSION_SUM_davbb_doc"
           descriptiveExpression="COMISSION_SUM_DAVBB_DOC" order="16"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_AGENT_REPORT" parentColumn="CONTACT_ID"
     childQuery="Q_AG_DOCS" childColumn="contact_id1" condition="eq"
     sqlClause="where"/>
  </data>
  
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  
 begin
 
  SELECT  to_char(h.date_end,'yyyymmdd'),
 		 nvl(apd.mounth_num,0),
  		 nvl(apw.sgp1,0) + nvl(apw.sgp2,0),
		 h.date_begin,
		 h.date_end,
		 hed.agent_id
  into :dt,:mn,:sg, :dt_b,:dt_e,:ag_id
  FROM ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_roll r,
       ag_roll_header h,
       ag_contract_header hed
  WHERE apw.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id
        and apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
        and r.ag_roll_header_id = h.ag_roll_header_id
        and hed.ag_contract_header_id = apw.ag_contract_header_id
        and r.ag_roll_id = apw.ag_roll_id;
 end;
 
 begin
 
 SELECT MIN(ach1.date_begin)
 into :mindt
 FROM ag_contract_header ach1
 WHERE ach1.agent_id = :ag_id;
 
 end;

 declare
 z number;
 n number;
 k number;
 begin
 z := (:dt_e+1-:mindt)/(:dt_e+1- :dt_b);
 n := nvl(pkg_renlife_utils.get_plan_sgp('SGP_plan_for_DAV',:dt,:mn,:sg),0);
 k := round(n * z);
 if :mn = 1 then
 	:plan_sgp := to_char(k,'99999990D99');
 else
 	:plan_sgp := to_char(n,'99999990D99');
 end if;
 end;
 
 
  begin
select decode(upper(uu.sys_user_name),'YPLATOVA','Платовой Юлии Игоревны',
  									    'RVAGAPOV','Вагапова Раиля Рафиковича',
										'VESELEK','Веселухи Екатерины Владимировны',
										'TKIM','Ким Татьяны Ивановны',
										'JKOVRIGINA','Ковригиной Юлии Владимировны',
										'EGORNOVA','Горновой Евгении Федоровны',
										''),
		 decode(upper(uu.sys_user_name),'YPLATOVA','Платова Ю.И.',
  									    'RVAGAPOV','Вагапов Р.Р.',
										'VESELEK','Веселуха Е.В.',
										'TKIM','Ким Т.И.',
										'JKOVRIGINA','Ковригина Ю.В.',
										'EGORNOVA','Горнова Е.Ф.',
										''),
	     decode(upper(uu.sys_user_name),'YPLATOVA','Доверенности № 2010/176, выданной 01 января 2010 года',
  									    'RVAGAPOV','Доверенности № 2010/244, выданной 01 января 2010 года',
										'VESELEK','Доверенности № 2010/245, выданной 01 января 2010 года',
										'TKIM','Доверенности № 2010/175, выданной 01 января 2010 года',
										'JKOVRIGINA','Доверенности № 2010/173, выданной 01 января 2010 года',
										'EGORNOVA','Доверенности № 2010/174, выданной 01 января 2010 года',
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
<link rel=File-List href="???%20?????.files/filelist.xml">
<title>Отчет агента ОАВ-1</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>V</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>12</o:TotalTime>
  <o:Created>2009-06-24T09:45:00Z</o:Created>
  <o:LastSaved>2009-06-24T09:45:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>234</o:Words>
  <o:Characters>1340</o:Characters>
  <o:Lines>11</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>1571</o:CharactersWithSpaces>
  <o:Version>11.8107</o:Version>
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
</xml><![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073750139 0 0 159 0;}
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
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:Calibri;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-link:"Title Char";
	margin-top:70.85pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:Calibri;
	mso-bidi-font-family:"Times New Roman";}
span.TitleChar
	{mso-style-name:"Title Char";
	mso-style-locked:yes;
	mso-style-link:????????;
	mso-ansi-font-size:12.0pt;
	font-family:"MS Sans Serif";
	mso-ascii-font-family:"MS Sans Serif";
	mso-fareast-font-family:Calibri;
	mso-hansi-font-family:"MS Sans Serif";
	mso-ansi-language:RU;
	mso-fareast-language:RU;
	mso-bidi-language:AR-SA;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:3.0cm 2.0cm 42.55pt 2.0cm;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"??????? ???????";
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
<div class=Section1>

<rw:foreach id="G_AGENT_REPORT" src="G_AGENT_REPORT">
<rw:foreach id="G_SUM" src="G_SUM">
<rw:foreach id="G_AG_DOCS" src="G_AG_DOCS">

<p class=MsoTitle style='margin-top:0cm'><span style='font-size:10.0pt;
font-family:"Times New Roman"'>ОТЧЕТ АГЕНТА № ОАВ-<b style='mso-bidi-font-weight:
normal'><rw:field id="" src="act_num"/></b><o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:0cm'><b style='mso-bidi-font-weight:normal'><span
style='font-size:10.0pt;font-family:"Times New Roman"'>к АГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ)</span></b><span
style='font-size:10.0pt'> </span><b style='mso-bidi-font-weight:normal'><span
style='font-size:10.0pt;font-family:"Times New Roman"'><o:p></o:p></span></b></p>

<p class=MsoTitle align=left style='margin-top:0cm;text-align:left'><span
style='font-size:10.0pt;font-family:"Times New Roman"'>г. Москва<span
style='mso-tab-count:5'>                                                                                                                                                                                          </span><o:p></o:p></span></p>

<p class=MsoTitle align=left style='margin-top:0cm;text-align:left'><span
style='font-size:10.0pt;font-family:"Times New Roman"'>Общество с ограниченной
ответственностью "Страховая Компания "Ренессанс Жизнь", именуемое в дальнейшем
Страховащик, в лице <b style='mso-bidi-font-weight:normal'><rw:field id="" src="long_name"/></b>,
действующего на основании <b style='mso-bidi-font-weight:normal'><rw:field id="" src="dover"/></b>,
с одной стороны, и <b style='mso-bidi-font-weight:normal'><rw:field id="" src="agname"/></b>, паспорт серии <b
style='mso-bidi-font-weight:normal'><rw:field id="" src="p_ser"/></b> № <b style='mso-bidi-font-weight:
normal'><rw:field id="" src="p_num"/></b>, именуемый(ая)
в дальнейшем АГЕНТ, с другой стороны, составили и утвердили настоящий отчет
к Агентскому соглашению.<o:p></o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
 style='width:100.0%;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:27.85pt'>
  <td width="12%" colspan=3 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Номер агентского договора<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="dognum"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Агентство<o:p></o:p></span></b></p>
  </td>
  <td width="10%" colspan=3 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="filial"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Дата отчета<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=3 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="report_date"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  
 </tr>
 <tr style='mso-yfti-irow:1;height:15.75pt'>
  <td width="12%" colspan=3 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" colspan=2 style='width:8.1%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=3 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="10%" colspan=2 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=3 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:17.55pt'>
  <td width="12%" colspan=3 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>ФИО агента<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="agname"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Месяц расчета вознаграждения<o:p></o:p></span></b></p>
  </td>
  <td width="10%" colspan=3 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="month"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Юридический статус агента<o:p></o:p></span></b></p>
  </td>
  <td width="11%" nowrap colspan=3 valign=bottom style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'></span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="leg_pos"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:15.0pt'>
  <td width="12%" colspan=3 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=3 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" colspan=2 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=3 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:21.2pt'>
  <td width="12%" colspan=3 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Дата АД<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="ag_date"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Год расчета вознаграждения<o:p></o:p></span></b></p>
  </td>
  <td width="10%" colspan=3 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>&nbsp;</span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="year"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" colspan=3 style='width:10.28%;padding:0cm 5.4pt 0cm 5.4pt;height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:12.75pt'>
  <td width="12%" nowrap colspan=3 valign=bottom style='width:12.04%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=4 valign=bottom style='width:11.58%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" nowrap colspan=3 valign=bottom style='width:8.1%;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=3 valign=bottom style='width:12.74%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=2 valign=bottom style='width:10.42%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=3 valign=bottom style='width:11.58%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:6;height:29.05pt'>
  <td width="12%" colspan=2 rowspan=2 style='width:12.04%;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Номер договора страхования<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=3 rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ФИО Страхователя<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Продукт<o:p></o:p></span></b></p>
  </td>
  <td width="8%" colspan=2 rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Программа<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Наличие Индексации<o:p></o:p></span></b></p>
  </td>
  <td width="12%" rowspan=2 style='width:12.74%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Год действия договора страхования<o:p></o:p></span></b></p>
  </td>
  <td width="10%" rowspan=2 style='width:10.42%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Период страхования, лет<o:p></o:p></span></b></p>
  </td>
  <td width="10%" colspan=2 rowspan=2 style='width:10.42%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Статус агента на дату оплаты взноса<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Дата оплаты / Возврата премии<o:p></o:p></span></b></p>
  </td>
  <td width="21%" colspan=3 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Фактически оплаченная страховая премия, руб.<o:p></o:p></span></b></p>
  </td>
 <td width="11%" rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Ставка комиссии, %<o:p></o:p></span></b></p>
  </td>
  <td width="21%" colspan=3 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Комиссионное вознаграждение, руб.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:16.15pt'>
  <td width="11%" colspan=2 style='width:11.44%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Оплачено<o:p></o:p></span></b></p>
  </td>
  <td width="10%" style='width:10.28%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Возвращено<o:p></o:p></span></b></p>
  </td>
 <td width="11%" colspan=2 style='width:11.44%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Начислено<o:p></o:p></span></b></p>
  </td>
  <td width="10%" style='width:10.28%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Удержано<o:p></o:p></span></b></p>
  </td>
</tr>
 
 <tr style='mso-yfti-irow:8;height:12.75pt'>
  <td width="12%" nowrap colspan=2  valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>1<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=3 valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>2<o:p></o:p></span></p>
  </td>
  <td width="8%" nowrap valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>3<o:p></o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.74%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>4<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>5<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>6<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.84%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>7<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>8<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=2 valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>9<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=2 valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>10<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>11<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>12<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=2 valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>13<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>14<o:p></o:p></span></p>
  </td>
 </tr>
 
<rw:foreach id="G_DOG_DAF_IN" src="G_DOG">
 
 <tr style='mso-yfti-irow:9;height:12.75pt'>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'>
  <rw:field id="" src="pol_num"/></span>
  <span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=3 valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="strahov_name"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" nowrap valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="product"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" nowrap colspan=2 valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:8.0pt'><rw:field id="" src="progr"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" nowrap valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="idx"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 <td width="10%" nowrap valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="year_ins"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="years"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=2 valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="stat_agent"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="first_pay_date"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="sum_opl"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="sum_vozv"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="sav"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="comm_nach"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="comm_uder"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
</rw:foreach> 
 
 
 <tr style='mso-yfti-irow:11;height:12.75pt'>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.04%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=3 valign=bottom style='width:11.58%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" nowrap colspan=2 valign=bottom style='width:8.1%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.74%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.42%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.84%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 
  <tr style='mso-yfti-irow:16;height:20.45pt'>
  <td width="100%" colspan=18 style='width:100.0%;padding:0cm 5.4pt 0cm 5.4pt;
  height:20.45pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Итого размер агентского вознаграждения за период<span style='mso-spacerun:yes'>  </span></span><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt'><rw:field id="" src="date_begin"/> - <rw:field id="" src="date_end"/></span></b><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>
   составляет </span><b style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt'>
 <rw:field id="" src="COMISSION_SUM_dav_line"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'> руб.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:12.75pt'>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.04%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" nowrap colspan=2 valign=bottom style='width:8.1%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.74%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap colspan=3 valign=bottom style='width:10.42%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="59%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Сумма агентского вознаграждения определена правильно.<o:p></o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:19;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="7%" nowrap valign=bottom style='width:7.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="4%" nowrap valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="7%" nowrap colspan=2 valign=bottom style='width:7.5%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.14%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.82%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.96%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.06%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:20;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="59%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:21;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="7%" nowrap valign=bottom style='width:7.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=3 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>СТРАХОВЩИК<o:p></o:p></span></p>
  </td>
  <td width="4%" nowrap valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="7%" nowrap colspan=2 valign=bottom style='width:7.5%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.14%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.82%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=3 valign=bottom style='width:6.96%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>АГЕНТ<o:p></o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.06%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:22;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="7%" nowrap valign=bottom style='width:7.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="4%" nowrap valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="7%" nowrap colspan=2 valign=bottom style='width:7.5%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.14%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.82%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.96%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.06%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:23;mso-yfti-lastrow:yes;height:12.75pt;mso-row-margin-right:
  40.44%'>
  <td width="7%" nowrap valign=bottom style='width:7.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=3 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:10.0pt;
  mso-ansi-language:EN-US'><rw:field id="" src="short_name"/><o:p></o:p></span></b></p>
  </td>
  <td width="4%" nowrap valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="7%" nowrap colspan=2 valign=bottom style='width:7.5%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.14%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.82%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=3 valign=bottom style='width:6.96%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:10.0pt;
  mso-ansi-language:EN-US'><rw:field id="" src="ag_name_initial"/><o:p></o:p></span></b></p>
  </td>
  <td width="6%" nowrap valign=bottom style='width:6.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="6%" nowrap colspan=2 valign=bottom style='width:6.06%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="40%" colspan=4><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=42 style='border:none'></td>
  <td width=43 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=29 style='border:none'></td>
  <td width=26 style='border:none'></td>
  <td width=19 style='border:none'></td>
  <td width=29 style='border:none'></td>
  <td width=8 style='border:none'></td>
  <td width=44 style='border:none'></td>
  <td width=30 style='border:none'></td>
  <td width=15 style='border:none'></td>
  <td width=44 style='border:none'></td>
  <td width=9 style='border:none'></td>
  <td width=18 style='border:none'></td>
  <td width=27 style='border:none'></td>
  <td width=78 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=61 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>
</rw:foreach>
</rw:foreach>
</rw:foreach>
</div>

</body>

</html>

</rw:report>
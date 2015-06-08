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
	 <userParameter name="p_p_contact_id" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="long_name" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="short_name" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="dover" datatype="character" width="200"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="p_p_ser" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="p_p_num" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="p_p_pvidan" datatype="character" width="2000"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="p_p_datav" datatype="character" width="2000"
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
      <![CDATA[SELECT count(1) over() row_cnt, h.ag_contract_header_id,
       d.num num_agent,
       c.contact_id,
       c.obj_name_orig fio_agent,
	   to_char(h.date_begin,'DD.MM.YYYY') date_begin,
       dep.name depart,
       initcap(to_char(rh.date_end,'MONTH','NLS_DATE_LANGUAGE = RUSSIAN')) month_calc,
       to_char(rh.date_end,'YYYY') year_calc,
       to_char(sysdate,'DD.MM.YYYY') report_date,
       decode(ag.leg_pos,1,'ПБОЮЛ',0,'Физическое лицо',2,'',3,'Физическое лицо',1030,'ПБОЮЛ','Физическое лицо') leg_pos,
       act.ag_level lvl_agent,
       to_char(nvl(act.ag_ksp,0),'99999990D99') ksp,
       ch.description sales_ch,
       dept_exe.contact_id dir_contact_id,
       pkg_contact.get_fio_fmt (NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),'Смышляев Юрий Олегович'
           ), 4 ) dir_name_initial,
       NVL (nvl((select genitive from contact where contact_id = dept_exe.contact_id),
           ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id)),
            'Смышляева Юрия Олеговича'
           ) dir_name_genitive, 
       NVL (ent.obj_name (ent.id_by_brief ('CONTACT'), dept_exe.contact_id),
            'Смышляев Юрий Олегович'
           ) dir_name,
	 to_char(rh.date_end,'DD.MM.YYYY') date_rep,
	 case ch.description when 'DSF' then 'Приказ №15' when 'SAS' then 'Приказ №13' when 'SAS 2' then 'Приказ №14' else '' end prikaz
from ag_roll_header rh,
     ag_roll rl,
     ag_roll_type tr,
     ag_perfomed_work_act act,
     ins.ag_perfom_work_det det,
     ag_contract_header h,
     document d,
     t_sales_channel ch,
     contact c,
     ag_contract ag,
     department dep,
	 ins.ag_rate_type rt,
     ven_dept_executive dept_exe
where rh.ag_roll_type_id = tr.ag_roll_type_id
      and rh.ag_roll_header_id = rl.ag_roll_header_id
      and act.ag_roll_id = rl.ag_roll_id
      and det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
      and act.ag_contract_header_id = h.ag_contract_header_id
      and h.last_ver_id = ag.ag_contract_id
      and h.ag_contract_header_id = d.document_id
      and h.agent_id = c.contact_id
      and h.t_sales_channel_id = ch.id(+)
      and dep.department_id(+) = ag.agency_id
      and h.agency_id = dept_exe.department_id(+)
	  and det.ag_rate_type_id = rt.ag_rate_type_id
      and rt.brief = 'OAV_0510'
      and act.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id and rl.ag_roll_id = :p_ag_roll_id;]]>
  </select>
      <displayInfo x="2.12500" y="0.08337" width="1.19788" height="0.32983"/>
      <group name="G_AGENT_REPORT">
	 <dataItem name="ROW_CNT" oracleDatatype="number" columnOrder="1"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="ROW_CNT" descriptiveExpression="ROW_CNT"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
	  <dataItem name="AG_CONTRACT_HEADER_ID" oracleDatatype="number"
         columnOrder="2" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ag Contract Header Id">
          <dataDescriptor expression="AG_CONTRACT_HEADER_ID"
           descriptiveExpression="AG_CONTRACT_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="num_agent" datatype="vchar2" columnOrder="3" width="201"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="num agent">
          <dataDescriptor expression="num_agent" descriptiveExpression="num_agent"
           order="3" width="201"/>
        </dataItem>
	<dataItem name="CONTACT_ID" oracleDatatype="number" columnOrder="4"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="c.contact_id"
           descriptiveExpression="CONTACT_ID" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
		<dataItem name="fio_agent" datatype="vchar2" columnOrder="5"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="fio agent">
          <dataDescriptor expression="fio_agent" descriptiveExpression="fio_agent"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="DATE_BEGIN" datatype="vchar2" columnOrder="6"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="DATE BEGIN">
          <dataDescriptor expression="DATE_BEGIN"
           descriptiveExpression="DATE_BEGIN" order="6" width="4000"/>
        </dataItem>
	 <dataItem name="depart" datatype="vchar2" columnOrder="7"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="depart">
          <dataDescriptor expression="depart"
           descriptiveExpression="depart" order="7" width="4000"/>
        </dataItem>
		<dataItem name="month_calc" datatype="vchar2" columnOrder="8"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="month calc">
          <dataDescriptor expression="month_calc"
           descriptiveExpression="month_calc" order="8" width="4000"/>
        </dataItem>
		<dataItem name="year_calc" datatype="vchar2" columnOrder="9"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="year calc">
          <dataDescriptor expression="year_calc"
           descriptiveExpression="year_calc" order="9" width="4000"/>
        </dataItem>
		<dataItem name="REPORT_DATE" datatype="vchar2" columnOrder="10"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="REPORT DATE">
          <dataDescriptor expression="REPORT_DATE"
           descriptiveExpression="REPORT_DATE" order="10" width="4000"/>
        </dataItem>
		<dataItem name="leg_pos" datatype="vchar2" columnOrder="11"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="leg pos">
          <dataDescriptor expression="leg_pos"
           descriptiveExpression="leg_pos" order="11" width="4000"/>
        </dataItem>
		<dataItem name="lvl_agent" oracleDatatype="number"
         columnOrder="12" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="lvl agent">
          <dataDescriptor expression="lvl_agent"
           descriptiveExpression="lvl_agent" order="12"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
		<dataItem name="ksp" datatype="vchar2" columnOrder="13"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="ksp">
          <dataDescriptor expression="ksp"
           descriptiveExpression="ksp" order="13" width="4000"/>
        </dataItem>
		<dataItem name="sales_ch" datatype="vchar2" columnOrder="14"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="sales ch">
          <dataDescriptor expression="sales_ch"
           descriptiveExpression="sales_ch" order="14" width="100"/>
        </dataItem>
		<dataItem name="DIR_CONTACT_ID" oracleDatatype="number"
         columnOrder="15" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Dir Contact Id">
          <dataDescriptor expression="DIR_CONTACT_ID"
           descriptiveExpression="DIR_CONTACT_ID" order="15" width="22"
           scale="-127"/>
        </dataItem>
		<dataItem name="DIR_NAME_INITIAL" datatype="vchar2" columnOrder="16"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Initial">
          <dataDescriptor expression="DIR_NAME_INITIAL"
           descriptiveExpression="DIR_NAME_INITIAL" order="16" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME_GENITIVE" datatype="vchar2" columnOrder="17"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name Genitive">
          <dataDescriptor expression="DIR_NAME_GENITIVE"
           descriptiveExpression="DIR_NAME_GENITIVE" order="17" width="4000"/>
        </dataItem>
        <dataItem name="DIR_NAME" datatype="vchar2" columnOrder="18"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dir Name">
          <dataDescriptor expression="DIR_NAME"
           descriptiveExpression="DIR_NAME" order="18" width="4000"/>
        </dataItem>
		<dataItem name="date_rep" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="date rep">
          <dataDescriptor expression="date_rep" descriptiveExpression="date_rep"
           order="19" width="4000"/>
        </dataItem>
		<dataItem name="prikaz" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="prikaz">
          <dataDescriptor expression="prikaz" descriptiveExpression="prikaz"
           order="20" width="4000"/>
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
      <![CDATA[ 
  select 1 cnt, d.num num_pol,
       cont.obj_name_orig holder,
       prod.description product,
       opt.description risk_name,
       case when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(av.index_delta_sum,0) = nvl(vol.vol_amount,0)) then 'В наличии' else 'Нет' end idx_exist,
       av.pay_period,
       av.ins_period,
       to_char(av.payment_date,'DD.MM.YYYY') payment_date, 
       case when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(av.index_delta_sum,0) = nvl(vol.vol_amount,0)) then to_char(nvl(vol.vol_amount,0),'99999990D99')
            when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(av.index_delta_sum,0) <> nvl(vol.vol_amount,0)) then '0.00'
            when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) <= 0) then '0.00'
            else to_char((nvl(av.trans_sum,0) * nvl(av.nbv_coef,0)),'99999990D99') end op1,
			 case when nvl(vol.vol_amount,0) > 0 then to_char(nvl(vol.vol_amount,0),'99999990D99') else '0.00' end prem_pay,
       case when nvl(vol.vol_amount,0) < 0 then to_char(nvl(abs(vol.vol_amount),0),'99999990D99') else '0.00' end prem_back,
       to_char(nvl(vol.vol_rate,0) * 100,'99999990D99')||'%' vol_rate,
       case when nvl(vol.vol_amount,0) > 0 then to_char((nvl(vol.vol_amount,0) * nvl(vol.vol_rate,0)),'99999990D99')else '0.00' end com_pay,
       case when nvl(vol.vol_amount,0) < 0 then to_char((nvl(abs(vol.vol_amount),0) * nvl(vol.vol_rate,0)),'99999990D99') else '0.00' end com_back       ,
       av.epg_date
from ins.ag_roll_header rh, 
     ins.ag_roll rl, 
     ins.ag_roll_type tr,
     ins.ag_perfomed_work_act act,
     ins.ag_perfom_work_det det, 
	   ins.ag_rate_type rt,
     ins.ag_perf_work_vol vol,
     ins.ag_volume av,
     --left join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     p_pol_header ph,
     document d,
     T_CONTACT_POL_ROLE cpr,
     P_POLICY_CONTACT pc,
     contact cont,
     t_product prod,
     t_prod_line_option opt
where rh.ag_roll_header_id = rl.ag_roll_header_id
			and rh.ag_roll_type_id = tr.ag_roll_type_id
			and act.ag_roll_id(+) = rl.ag_roll_id
			and det.ag_perfomed_work_act_id(+) = act.ag_perfomed_work_act_id
			and det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510'
			and vol.ag_perfom_work_det_id(+) = det.ag_perfom_work_det_id
			and av.ag_volume_id(+) = vol.ag_volume_id
			and av.policy_header_id = ph.policy_header_id(+)
			and ph.policy_header_id = d.document_id(+)
			and cpr.brief = 'Страхователь'
			and pc.policy_id = ph.policy_id AND pc.contact_policy_role_id = cpr.id
			and cont.contact_id(+) = pc.contact_id
			and prod.product_id(+) = ph.product_id
			and av.t_prod_line_option_id = opt.id(+)

			and rl.ag_roll_id = :p_ag_roll_id
      --and act.ag_contract_header_id = 23131603
      and prod.description <> 'Универсальный продукт'
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id
 
union

  select 1 cnt, d.num num_pol,
       cont.obj_name_orig holder,
       prod.description product,
       opt.description risk_name,
       case when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(av.index_delta_sum,0) = nvl(vol.vol_amount,0)) then 'В наличии' else 'Нет' end idx_exist,
       av.pay_period,
       av.ins_period,
       to_char(av.payment_date,'DD.MM.YYYY') payment_date, 
       case when (nvl(sum(av.index_delta_sum),0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(sum(av.index_delta_sum),0) = nvl(sum(vol.vol_amount),0)) then to_char(nvl(sum(vol.vol_amount),0),'99999990D99')
            when (nvl(sum(av.index_delta_sum),0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(sum(av.index_delta_sum),0) <> nvl(sum(vol.vol_amount),0)) then '0.00'
            when (nvl(sum(av.index_delta_sum),0) > 0 and nvl(vol.vol_rate,0) <= 0) then '0.00'
            else to_char(sum(nvl(av.trans_sum,0) * nvl(av.nbv_coef,0)),'99999990D99') end op1,
			 case when nvl(sum(vol.vol_amount),0) > 0 then to_char(nvl(sum(vol.vol_amount),0),'99999990D99') else '0.00' end prem_pay,
       case when nvl(sum(vol.vol_amount),0) < 0 then to_char(nvl(abs(sum(vol.vol_amount)),0),'99999990D99') else '0.00' end prem_back,
       to_char(nvl(vol.vol_rate,0) * 100,'99999990D99')||'%' vol_rate,
       case when nvl(sum(vol.vol_amount),0) > 0 then to_char((nvl(sum(vol.vol_amount),0) * nvl(vol.vol_rate,0)),'99999990D99')else '0.00' end com_pay,
       case when nvl(sum(vol.vol_amount),0) < 0 then to_char((nvl(abs(sum(vol.vol_amount)),0) * nvl(vol.vol_rate,0)),'99999990D99') else '0.00' end com_back       ,
       av.epg_date
from ins.ag_roll_header rh, 
     ins.ag_roll rl, 
     ins.ag_roll_type tr,
     ins.ag_perfomed_work_act act,
     ins.ag_perfom_work_det det, 
	   ins.ag_rate_type rt,
     ins.ag_perf_work_vol vol,
     ins.ag_volume av,
     --left join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     p_pol_header ph,
     document d,
     T_CONTACT_POL_ROLE cpr,
     P_POLICY_CONTACT pc,
     contact cont,
     t_product prod,
     t_prod_line_option opt
where rh.ag_roll_header_id = rl.ag_roll_header_id
			and rh.ag_roll_type_id = tr.ag_roll_type_id
			and act.ag_roll_id(+) = rl.ag_roll_id
			and det.ag_perfomed_work_act_id(+) = act.ag_perfomed_work_act_id
			and det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510'
			and vol.ag_perfom_work_det_id(+) = det.ag_perfom_work_det_id
			and av.ag_volume_id(+) = vol.ag_volume_id
			and av.policy_header_id = ph.policy_header_id(+)
			and ph.policy_header_id = d.document_id(+)
			and cpr.brief = 'Страхователь'
			and pc.policy_id = ph.policy_id AND pc.contact_policy_role_id = cpr.id
			and cont.contact_id(+) = pc.contact_id
			and prod.product_id(+) = ph.product_id
			and av.t_prod_line_option_id = opt.id(+)

			and rl.ag_roll_id = :p_ag_roll_id
      --and act.ag_contract_header_id = 23131603
      and prod.description = 'Универсальный продукт'
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id
 group by d.num,
       cont.obj_name_orig,
       prod.description,
       opt.description,
       case when (nvl(av.index_delta_sum,0) > 0 and nvl(vol.vol_rate,0) > 0 and nvl(av.index_delta_sum,0) = nvl(vol.vol_amount,0)) then 'В наличии' else 'Нет' end,
       av.pay_period,
       av.ins_period,
       to_char(av.payment_date,'DD.MM.YYYY'),
       vol.vol_rate,
       av.epg_date
 order by num_pol]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
	  <group name="G_DOG">
        <dataItem name="cnt"/>
      </group>
    </dataSource>
	
	<dataSource name="Q_DOG_SUM">
    <select canParse="no">
    <![CDATA[select 1 tr, to_char(nvl(sum(nvl(vol.vol_amount,0) * nvl(vol.vol_rate,0)),0),'99999990D99') sum_com_pay    
from ins.ag_roll_header rh, 
     ins.ag_roll rl, 
     ins.ag_roll_type tr,
     ins.ag_perfomed_work_act act,
     ins.ag_perfom_work_det det, 
	   ins.ag_rate_type rt,
     ins.ag_perf_work_vol vol,
     ins.ag_volume av,
     --left join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     p_pol_header ph,
     document d,
     T_CONTACT_POL_ROLE cpr,
     P_POLICY_CONTACT pc,
     contact cont,
     t_product prod,
     t_prod_line_option opt
where rh.ag_roll_header_id = rl.ag_roll_header_id
			and rh.ag_roll_type_id = tr.ag_roll_type_id
			and act.ag_roll_id(+) = rl.ag_roll_id
			and det.ag_perfomed_work_act_id(+) = act.ag_perfomed_work_act_id
			and det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510'
			and vol.ag_perfom_work_det_id(+) = det.ag_perfom_work_det_id
			and av.ag_volume_id(+) = vol.ag_volume_id
			and av.policy_header_id = ph.policy_header_id(+)
			and ph.policy_header_id = d.document_id(+)
			and cpr.brief = 'Страхователь'
			and pc.policy_id = ph.policy_id AND pc.contact_policy_role_id = cpr.id
			and cont.contact_id(+) = pc.contact_id
			and prod.product_id(+) = ph.product_id
			and av.t_prod_line_option_id = opt.id(+)

			and rl.ag_roll_id = :p_ag_roll_id
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
	  <group name="G_DOG_SUM">
        <dataItem name="tr"/>
      </group>
    </dataSource>
	
	
	<dataSource name="Q_DOG_ZAKL">
      <select>
      <![CDATA[
SELECT 1 cntc,
       ar.ag_roll_id,
       apw.ag_perfomed_work_act_id,
       anv.snils num_pol_npf,
       anv.fio holder_npf,
       to_char(anv.sign_date,'DD.MM.YYYY') sign_date,
       case when ts.description = 'SAS 2' then
         case when apv.vol_amount = 500 then 'Качественный' 
              when apv.vol_amount = 100 then 'Некачественный'
              when apv.vol_amount = 250 then 'Качественный' 
              else '' end
       else
         case when apv.vol_amount = 500 then 'Качественный' 
              when apv.vol_amount = 100 then 'Некачественный'
              when apv.vol_amount = 250 then 'Некачественный' 
              else '' end
       end type_dog,
       case when ts.description = 'SAS 2' then
         case when nvl(apv.vol_amount,0) = 500 then to_char((nvl(agv.trans_sum,0) * nvl(agv.nbv_coef,0)),'99999990D99')
              when nvl(apv.vol_amount,0) = 250 then to_char((nvl(agv.trans_sum,0) * nvl(agv.nbv_coef,0)),'99999990D99')
              else '0,00' end
       else
         case when nvl(apv.vol_amount,0) = 500 then to_char((nvl(agv.trans_sum,0) * nvl(agv.nbv_coef,0)),'99999990D99') else '0,00' end
       end op2,
	   0 cnt_dog,
       0 sum_com_pay_npf,
       to_char(nvl(apv.vol_rate,0) * 100,'99999990D99') ||'%' vol_rate_npf,
       case when nvl(apv.vol_rate * apv.vol_amount,0) > 0 then to_char(nvl(apv.vol_rate * apv.vol_amount,0),'99999990D99') else '0,00' end com_pay_npf,
       case when nvl(apv.vol_rate * apv.vol_amount,0) < 0 then to_char(nvl(apv.vol_rate * apv.vol_amount,0),'99999990D99') else '0,00' end com_back_npf
FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_rate_type art,
       ag_perf_work_vol apv,
       ag_volume agv,
       ag_volume_type avt,
       ag_npf_volume_det anv,
       ven_ag_contract_header ach,
       t_sales_channel ts,       
       ag_contract ac,
       ag_category_agent aca,
       department dep,
       contact cn,
       t_contact_type tct
 WHERE 1=1
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id   
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_id = agv.ag_volume_id
   AND agv.ag_volume_id (+)  = anv.ag_volume_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('NPF','AVCP','SOFI','NPF02')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end   
   AND ac.category_id = aca.ag_category_agent_id
   AND dep.department_id = ach.agency_id
   AND ach.agent_id = cn.contact_id
   AND tct.ID = ac.leg_pos   
   AND ach.t_sales_channel_id = ts.ID (+)
   and art.NAME = 'ОАВ 25052010'
   and avt.DESCRIPTION in ('Объемы НПФ Ренессанс','Объемы ОПС02 - SAS 2')
   and apw.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id
	 and ar.ag_roll_id = :p_ag_roll_id
]]>
      </select>
      <displayInfo x="2.91675" y="4.79102" width="1.44788" height="0.34583"/>
      <group name="G_DOG_ZAKL">
        <dataItem name="cntc"/>
      </group>
    </dataSource>
	
	<dataSource name="Q_DOG_ZAKL_SUM">
      <select>
      <![CDATA[  select 1 re, trim(to_char(nvl(sum(nvl(apv.vol_rate * apv.vol_amount,0)),0),'99999990D99')) sum_com_npf
			FROM ven_ag_roll_header arh,
			       ven_ag_roll ar,
			       ag_perfomed_work_act apw,
			       ag_perfom_work_det apd,
			       ag_rate_type art,
			       ag_perf_work_vol apv,
			       ag_volume agv,
			       ag_volume_type avt,
			       ag_npf_volume_det anv,
			       ven_ag_contract_header ach,
			       t_sales_channel ts,       
			       ag_contract ac,
			       ag_category_agent aca,
			       department dep,
			       contact cn,
			       t_contact_type tct
			 WHERE 1=1
			   AND ar.ag_roll_id = apw.ag_roll_id
			   AND arh.ag_roll_header_id = ar.ag_roll_header_id   
			   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
			   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
			   AND art.ag_rate_type_id = apd.ag_rate_type_id
			   AND apv.ag_volume_id = agv.ag_volume_id
			   AND agv.ag_volume_id (+)  = anv.ag_volume_id
			   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
			   AND avt.brief IN ('NPF','AVCP','SOFI','NPF02')
			   AND apw.ag_contract_header_id = ach.ag_contract_header_id
			   AND ac.contract_id = ach.ag_contract_header_id
			   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end   
			   AND ac.category_id = aca.ag_category_agent_id
			   AND dep.department_id = ach.agency_id
			   AND ach.agent_id = cn.contact_id
			   AND tct.ID = ac.leg_pos   
			   AND ach.t_sales_channel_id = ts.ID (+)
			   and art.NAME = 'ОАВ 25052010'
			   and avt.DESCRIPTION in ('Объемы НПФ Ренессанс','Объемы ОПС02 - SAS 2')
			   and apw.ag_perfomed_work_act_id = :p_ag_perfomed_work_act_id
			   and ar.ag_roll_id = :p_ag_roll_id]]>
      </select>
      <displayInfo x="2.91675" y="4.79102" width="1.44788" height="0.34583"/>
      <group name="G_DOG_ZAKL_SUM">
        <dataItem name="re"/>
      </group>
    </dataSource> 
	
    <dataSource name="Q_ALL_SUM">
    <select canParse="no">
    <![CDATA[select 1 ret, to_char(nvl((select sum(nvl(pf.vol_amount,0) * nvl(pf.vol_rate,0) + (nvl(vol.vol_amount,0) * nvl(vol.vol_rate,0)))
							from ins.ag_roll_header rh 
     join ins.ag_roll rl on rh.ag_roll_header_id = rl.ag_roll_header_id
     left join ins.ag_perfomed_work_act act on act.ag_roll_id = rl.ag_roll_id
     left join ins.ag_perfom_work_det det on det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
     join ins.ag_rate_type rt on det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510'
     left join ins.ag_perf_work_vol vol on vol.ag_perfom_work_det_id = det.ag_perfom_work_det_id
     left join ins.ag_volume av on av.ag_volume_id = vol.ag_volume_id
     join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     left join 
     (select vol2.vol_amount, det2.ag_perfomed_work_act_id, vol2.ag_volume_id, av2.trans_sum, vol2.vol_rate
      from ins.ag_perfom_work_det det2
     join ins.ag_rate_type rt2 on det2.ag_rate_type_id = rt2.ag_rate_type_id and rt2.brief = 'QMOPS_0510'
     join ins.ag_perf_work_vol vol2 on vol2.ag_perfom_work_det_id = det2.ag_perfom_work_det_id
     join ins.ag_volume av2 on av2.ag_volume_id = vol2.ag_volume_id
     join ins.ag_npf_volume_det npf on npf.ag_volume_id = av2.ag_volume_id) pf on pf.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id 
                                                                                  and pf.ag_volume_id = av.ag_volume_id
 where rl.ag_roll_id = :p_ag_roll_id
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id),0) +
    nvl((select sum(nvl(vol.vol_amount,0) * nvl(vol.vol_rate,0))    
from ins.ag_roll_header rh 
     join ins.ag_roll rl on rh.ag_roll_header_id = rl.ag_roll_header_id
     join ins.ag_roll_type tr on rh.ag_roll_type_id = tr.ag_roll_type_id
     left join ins.ag_perfomed_work_act act on act.ag_roll_id = rl.ag_roll_id
     left join ins.ag_perfom_work_det det on det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
	 left join ins.ag_rate_type rt on (det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510')
     left join ins.ag_perf_work_vol vol on vol.ag_perfom_work_det_id = det.ag_perfom_work_det_id
     left join ins.ag_volume av on av.ag_volume_id = vol.ag_volume_id
     left join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     left join p_pol_header ph on av.policy_header_id = ph.policy_header_id
     left join document d on ph.policy_header_id = d.document_id
     join T_CONTACT_POL_ROLE cpr ON cpr.brief = 'Страхователь'
     join P_POLICY_CONTACT pc ON pc.policy_id = ph.policy_id AND pc.contact_policy_role_id = cpr.id  --Ent.get_obj_id('t_contact_pol_role','Страхователь')
     left join contact cont ON cont.contact_id = pc.contact_id
     left join t_product prod on (prod.product_id = ph.product_id)
     left join t_prod_line_option opt on (av.t_prod_line_option_id = opt.id)
where rl.ag_roll_id = :p_ag_roll_id
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id),0),'99999990D99') all_sum
from dual]]>
      </select>
      <displayInfo x="5.89441" y="0.10413" width="1.34375" height="0.32983"/>
	  <group name="G_ALL_SUM">
        <dataItem name="ret"/>
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
   
begin
SELECT c.contact_id
into :p_p_contact_id
from ag_roll_header rh,
     ag_roll rl,
     ag_roll_type tr,
     ag_perfomed_work_act act,
     ins.ag_perfom_work_det det,
     ag_contract_header h,
     contact c,
	 ins.ag_rate_type rt
where rh.ag_roll_type_id = tr.ag_roll_type_id
      and rh.ag_roll_header_id = rl.ag_roll_header_id
      and act.ag_roll_id = rl.ag_roll_id
      and det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
      and act.ag_contract_header_id = h.ag_contract_header_id
      and h.agent_id = c.contact_id
  	  and det.ag_rate_type_id = rt.ag_rate_type_id
      and rt.brief = 'OAV_0510'
      and rl.ag_roll_id = :p_ag_roll_id
      and act.ag_perfomed_work_act_id=:p_ag_perfomed_work_act_id;
exception
    when no_data_found then :p_p_contact_id := 0;    
  end;
  
begin
select p_ser, p_num, pvidan, data_v
into :p_p_ser, :p_p_num, :p_p_pvidan, :p_p_datav
from
(
SELECT   NVL (cci.serial_nr, '@') p_ser,
         NVL (cci.id_value, '@') p_num, 
		 NVL (cci.place_of_issue, '@') pvidan,
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
	 and vcp.contact_id = :p_p_contact_id
ORDER BY NVL (cci.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC)
where rownum = 1;
exception
    when no_data_found then :p_p_ser := ''; :p_p_num := ''; :p_p_pvidan := ''; :p_p_datav  := ''; 
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
	margin:1.0cm 2.0cm 42.55pt 1.0cm;
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

<p class=MsoTitle style='margin-top:6.0pt;text-align:right'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>Приложение №2 к СУБАГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ) категории <rw:field id="" src="sales_ch"/> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:0in'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
1. Настоящее Приложение № 2 является неотъемлемой частью Субагентского договора (ПРИСОЕДИНЕНИЯ) категории <rw:field id="" src="sales_ch"/> 
в редакции от 26 июня 2011 г. утвержденного Генеральным директором ЗАО "Ренлайф Партнерс" Киселевым О.М.
от 24 июня 2011 г. <rw:field id="" src="prikaz"/> (Далее - СДП).<o:p></o:p></span></p>
<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:0in'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
2. Настоящее Приложение № 2 устанавливает форму Отчета АГЕНТА к Субагентскому договору (ПРИСОЕДИНЕНИЯ),
 на основании которого выплачивается СУБАГЕНТУ субагентское вознаграждение.<o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><span lang=RU style='font-size:11.0pt;
mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>ОТЧЕТ СУБАГЕНТА № <rw:field id="" src="sales_ch"/>-<rw:field id="" src="num_agent"/> <o:p></o:p></span></p>

<p class=MsoTitle style='margin-top:6.0pt'><b style='mso-bidi-font-weight:normal'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>к
СУБАГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ) категории <rw:field id="" src="sales_ch"/>.<o:p></o:p></span></b></p>

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
    10.0pt;font-family:"Times New Roman";font-weight:normal'><rw:field id="" src="date_rep"/></span></p>
    </td>
   </tr>
  </table>
  
<p class=MsoTitle style='margin-top:6.0pt;text-align:justify;tab-stops:0in'><span
lang=RU style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:"Times New Roman"'>
Закрытое акционерное общество "РенЛайф Партнерс", именуемое в дальнейшем АГЕНТ, в лице
Стельмах Юлии Геннадьевны, действующего на основании Доверенности № 5, выданной 18 февраля 2008 года,
с одной стороны, и <rw:field id="" src="fio_agent"/>, паспорт серии <rw:field id="" src="p_p_ser"/>
 № <rw:field id="" src="p_p_num"/>, выдан: <rw:field id="" src="p_p_pvidan"/> <rw:field id="" src="p_p_datav"/>, именуемы<span
class=GramE>й(</span><span class=SpellE>ая</span>) в дальнейшем СУБАГЕНТ, с другой
стороны, составили и утвердили настоящий отчет к Субагентскому договору (ПРИСОЕДИНЕНИЯ) категории <rw:field id="" src="sales_ch"/>.<o:p></o:p></span></p>

<p class=MsoNormal style='mso-layout-grid-align:none;text-autospace:none'><span
lang=RU style='mso-ansi-language:RU;layout-grid-mode:both'><o:p>&nbsp;</o:p></span></p>


<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%"
 style='width:100.0%;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:27.85pt'>
  <td width="12%" style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Номер СДП<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="NUM_AGENT"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Агентство АГЕНТА<o:p></o:p></span></b></p>
  </td>
  <td width="11%" style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="depart"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Дата отчета СУБАГЕНТА<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="report_date"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>КСП СУБАГЕНТА<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:27.85pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="ksp"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  
 </tr>
 <tr style='mso-yfti-irow:1;height:15.75pt'>
  <td width="12%" style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:8.1%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="12%" colspan=2 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:17.55pt'>
  <td width="12%" style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>ФИО СУБАГЕНТА<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="fio_agent"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Месяц расчета субагентского вознаграждения<o:p></o:p></span></b></p>
  </td>
  <td width="11%" style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="month_calc"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Индивидуальный предприниматель / Физическое лицо<o:p></o:p></span></b></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'></span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="leg_pos"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:17.55pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></b></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.55pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'></span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:15.0pt'>
  <td width="12%" style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:11.84%;padding:0cm 5.4pt 0cm 5.4pt;height:15.0pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:21.2pt'>
  <td width="12%" style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Дата СДП<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=2 style='width:11.58%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="date_begin"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 <td width="12%" colspan=2 style='width:12.74%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>Год расчета субагентского вознаграждения<o:p></o:p></span></b></p>
  </td>
  <td width="11%" style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>&nbsp;</span><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="year_calc"/></span></b><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="12%" colspan=2 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><b>Уровень СУБАГЕНТА</b><o:p>&nbsp;</o:p></span></p>
  </td>
   <td width="11%" colspan=2 style='width:10.42%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt'><rw:field id="" src="lvl_agent"/></span></b><o:p></o:p></p>
  </td>
  <td width="12%" colspan=2 style='width:11.44%;padding:0cm 5.4pt 0cm 5.4pt;height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=2 style='width:10.28%;padding:0cm 5.4pt 0cm 5.4pt;height:21.2pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:12.75pt'>
  <td width="12%" nowrap valign=bottom style='width:12.04%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:8.1%;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:12.74%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:10.42%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:10.42%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=2 valign=bottom style='width:11.58%;
  border:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 
 <tr style='mso-yfti-irow:4;height:21.2pt'>
  <td width="100%" colspan=14 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>1. Расчет субагентского вознаграждения по договорам страхования, заключенным между ООО
  "СК "Ренессанс Жизнь" и Страхователем при посредничестве СУБАГЕНТА:<o:p></o:p></span></b></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:6;height:29.05pt'>
  <td width="8%" rowspan=2 style='width:12.04%;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Номер договора страхования<o:p></o:p></span></b></p>
  </td>
  <td width="12%" rowspan=2 style='width:11.58%;border-top:none;
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
  <td width="11%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Программа страхования<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Наличие Индексации<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:12.74%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Год действия договора страхования<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:10.42%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Период страхования, лет<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:10.42%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Дата оплаты / возврата премии<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ОП 1<o:p></o:p></span></b></p>
  </td>
  <td width="12%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Фактически оплаченная страховая премия (взнос), руб.<o:p></o:p></span></b></p>
  </td>
 <td width="8%" rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Ставка субагентского вознаграждения (САВ), %<o:p></o:p></span></b></p>
  </td>
  <td width="12%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Рамер вознаграждение СУБАГЕНТА, руб.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:16.15pt'>
  <td width="8%" style='width:11.44%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Оплачено<o:p></o:p></span></b></p>
  </td>
  <td width="8%" style='width:10.28%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Возвращено<o:p></o:p></span></b></p>
  </td>
 <td width="8%" style='width:11.44%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Начислено<o:p></o:p></span></b></p>
  </td>
  <td width="8%" style='width:10.28%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Удержано<o:p></o:p></span></b></p>
  </td>
</tr>
    
 <tr style='mso-yfti-irow:8;height:12.75pt'>
  <td width="12%" nowrap valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>1<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
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
  <td width="12%" nowrap valign=bottom style='width:12.74%;
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
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>8<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>9<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
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
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
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
 
<rw:foreach id="G_DOG" src="G_DOG">
  
 <tr style='mso-yfti-irow:9;height:12.75pt'>
  <td width="12%" valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'>
  <rw:field id="" src="num_pol"/></span>
  <span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="holder"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="product"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:8.0pt'><rw:field id="" src="risk_name"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="8%" valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="idx_exist"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 <td width="10%" valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="pay_period"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" valign=bottom style='width:10.42%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="ins_period"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="payment_date"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="op1"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="prem_pay"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="prem_back"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="vol_rate"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="com_pay"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="com_back"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
</rw:foreach> 


 <tr style='mso-yfti-irow:11;height:12.75pt'>
  <td width="12%"  valign=bottom style='width:12.04%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%"  valign=bottom style='width:11.58%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" valign=bottom style='width:8.1%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" valign=bottom style='width:12.74%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" valign=bottom style='width:10.42%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.58%;
  border:none;mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.84%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.44%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" valign=bottom style='width:10.28%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
   <td width="11%" valign=bottom style='width:11.44%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" valign=bottom style='width:10.28%;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 	
 <rw:foreach id="G_DOG_SUM" src="G_DOG_SUM">
  <tr style='mso-yfti-irow:16;height:20.45pt'>
  <td width="100%" colspan=14 style='width:100.0%;padding:0cm 5.4pt 0cm 5.4pt;
  height:20.45pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Итого размер субагентского вознаграждения по договорам страхования,
  за период </span><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt'><rw:field id="" src="month_calc"/> - <rw:field id="" src="year_calc"/></span></b><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>
   составляет <rw:field id="" src="sum_com_pay"/><span style='font-size:8.0pt;
  font-family:Arial;mso-bidi-font-family:"Times New Roman"'> руб.<o:p></o:p></span></p>
  </td>
 </tr>
</rw:foreach> 

 
 <tr style='mso-yfti-irow:4;height:21.2pt'>
  <td width="12%" colspan=14 style='width:12.04%;padding:0cm 5.4pt 0cm 5.4pt;
  height:21.2pt'>
  <p class=MsoNormal><b><span style='font-size:8.0pt;font-family:Arial;
  mso-bidi-font-family:"Times New Roman"'>2. Расчет субагентского вознаграждения по Договорам ОПС, заключенным между НПФ
  "Ренессанс Жизнь и Пенсии" и Застрахованными лицами при посредничестве СУБАГЕНТА:<o:p></o:p></span></b></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:6;height:29.05pt'>
  <td width="12%" colspan=2 rowspan=2 style='width:12.04%;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Номер договора ОПС<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=4 rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ФИО Застрахованного лица<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Дата заключения Договора ОПС<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Вид Договора ОПС (качественный / некачественный)<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ОП 2<o:p></o:p></span></b></p>
  </td>
  
  <td width="21%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Дополнительное вознаграждение за Качественные Договора ОПС (Застрахованные лица мужского пола), руб.<o:p></o:p></span></b></p>
  </td>
 <td width="11%" rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Ставка субагентского вознаграждения (САВ), %<o:p></o:p></span></b></p>
  </td>
  <td width="21%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Рамер вознаграждение СУБАГЕНТА, руб.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:16.15pt'>
  <td width="11%" style='width:11.44%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Количество Договоров ОПС<o:p></o:p></span></b></p>
  </td>
  <td width="10%" style='width:10.28%;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.15pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Размер вознаграждения, руб.<o:p></o:p></span></b></p>
  </td>
 <td width="11%" style='width:11.44%;border-top:none;border-left:none;
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
  <td width="12%" colspan=2 nowrap valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>1<o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap colspan=4 valign=bottom style='width:11.58%;
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
  <td width="12%" nowrap valign=bottom style='width:12.74%;
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
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>8<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>9<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>10<o:p></o:p></span></p>
  </td>
 </tr>
 
<rw:foreach id="G_DOG_ZAKL" src="G_DOG_ZAKL">
  
 <tr style='mso-yfti-irow:9;height:12.75pt'>
  <td width="12%" nowrap colspan=2 valign=bottom style='width:12.04%;
  border:solid windowtext 1.0pt;border-top:none;mso-border-top-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'>
  <rw:field id="" src="num_pol_npf"/></span>
  <span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" colspan=4 valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:8.0pt'><rw:field id="" src="holder_npf"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="sign_date"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" valign=bottom style='width:11.58%;
  border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;
  border-right:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="type_dog"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="op2"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="cnt_dog"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="sum_com_pay_npf"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="vol_rate_npf"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="com_pay_npf"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span style='font-size:7.0pt'><rw:field id="" src="com_back_npf"/></span><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
</rw:foreach> 
 
 <tr style='mso-yfti-irow:17;height:12.75pt'>
  <td width="12%" colspan=2 nowrap valign=bottom style='width:12.04%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=4 nowrap valign=bottom style='width:11.58%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" nowrap valign=bottom style='width:8.1%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap valign=bottom style='width:12.74%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.42%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
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
  <td width="11%" nowrap valign=bottom style='width:11.58%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
  <rw:foreach id="G_DOG_ZAKL_SUM" src="G_DOG_ZAKL_SUM">
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Итого размер субагентского вознаграждения по договорам ОПС за период
  <rw:field id="" src="month_calc"/> - <rw:field id="" src="year_calc"/> составляет: <rw:field id="" src="sum_com_npf"/> руб.<o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach> 
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>3. Расчет субагентского вознаграждения за ДСВ по "Программе Софинансирование", уплаченные Застрахованными 
  лицами в пользу НПФ "Ренессанс Жизнь и Пенсии":<o:p></o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:6;height:29.05pt'>
  <td width="12%" colspan=3 rowspan=2 style='width:12.04%;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ФИО Застрахованного лица<o:p></o:p></span></b></p>
  </td>
  <td width="11%" colspan=3 rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>СНИЛС Застрахованного лица<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 colspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Дата уплаты ДСВ<o:p></o:p></span></b></p>
  </td>
  <td width="8%" rowspan=2 style='width:8.1%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>ОП 3<o:p></o:p></span></b></p>
  </td>
  <td width="21%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Фактически оплаченная сумма ДСВ, руб.<o:p></o:p></span></b></p>
  </td>
 <td width="11%" rowspan=2 style='width:11.58%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Ставка субагентского вознаграждения (САВ), %<o:p></o:p></span></b></p>
  </td>
  <td width="21%" colspan=2 style='width:21.74%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:29.05pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:7.0pt'>Рамер вознаграждение СУБАГЕНТА, руб.<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:16.15pt'>
  <td width="11%" style='width:11.44%;border-top:none;border-left:none;
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
 <td width="11%" style='width:11.44%;border-top:none;border-left:none;
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
  <td width="12%" colspan=3 nowrap valign=bottom style='width:12.04%;
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
  <td width="8%" nowrap colspan=2 valign=bottom style='width:8.1%;border-top:
  none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>3<o:p></o:p></span></p>
  </td>
  <td width="12%" nowrap valign=bottom style='width:12.74%;
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
  <td width="11%" nowrap valign=bottom style='width:11.44%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>8<o:p></o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.28%;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>9<o:p></o:p></span></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:17;height:12.75pt'>
  <td width="12%" colspan=3 nowrap valign=bottom style='width:12.04%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" colspan=3 nowrap valign=bottom style='width:11.58%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="8%" nowrap colspan=2 valign=bottom style='width:8.1%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="12%" nowrap valign=bottom style='width:12.74%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="10%" nowrap valign=bottom style='width:10.42%;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width="11%" nowrap valign=bottom style='width:11.58%;
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
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Итого размер субагентского вознаграждения за ДСВ по "Программе Софинансирование, уплаченные
  Застрахованными лицами в пользу НПФ "Ренессанс Жизнь и Пенсии" за период
  <rw:field id="" src="month_calc"/> - <rw:field id="" src="year_calc"/> составляет: 0.00 руб.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'><o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="G_ALL_SUM" src="G_ALL_SUM">
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=14 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>4. Итого размер субагентского вознаграждения за период
  <rw:field id="" src="month_calc"/> - <rw:field id="" src="year_calc"/> составляет: <rw:field id="" src="all_sum"/> руб.<o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <tr style='mso-yfti-irow:18;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="50%" colspan=7 style='width:59.56%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal><span style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:
  "Times New Roman"'>Сумма субагентского вознаграждения определена правильно.<o:p></o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width="50%" colspan=7><p class='MsoNormal'>&nbsp;</td>
 </tr>

 <tr style='mso-yfti-irow:21;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="6%" nowrap colspan=7 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>АГЕНТ<o:p></o:p></span></p>
  </td>
  <td width="4%" nowrap colspan=7 valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>СУБАГЕНТ<o:p></o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:21;height:12.75pt;mso-row-margin-right:40.44%'>
  <td width="6%" nowrap colspan=7 valign=bottom style='width:6.82%;padding:
  0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'>Стельмах Ю.Г.<o:p></o:p></span></p>
  </td>
  <td width="4%" nowrap colspan=7 valign=bottom style='width:4.78%;padding:0cm 5.4pt 0cm 5.4pt;
  height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman"'><rw:field id="" src="fio_agent"/><o:p></o:p></span></p>
  </td>
 </tr>
 		<![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
  <td width=34 style='border:none'></td>
 </tr>
 <![endif]>
</table>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>

</rw:foreach>
</div>

</body>

</html>

</rw:report>
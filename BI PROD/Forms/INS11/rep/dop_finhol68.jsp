<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  DecimalFormatSymbols unusualSymbols =  new DecimalFormatSymbols();
  unusualSymbols.setDecimalSeparator('.');
  String strange = "0";
  DecimalFormat format = new DecimalFormat(strange, unusualSymbols);  

  String strange2 = "0.00";
  DecimalFormat format2 = new DecimalFormat(strange2, unusualSymbols);  


  SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");

  String strax_fio_old = new String("");
  String strax_doc_old = new String("");
  String strax_dr_old = new String("");  

  String SUR_C = new String("");  
  String SUR_C_old = new String("");  

  String progr = new String("");  
  String progr_old = new String("");  

  String vygod = new String("");  
  String vygod_old = new String("");  

  String prog_per = new String("");  
  String prog_per_old = new String("");  


  String strax_fio = new String("");
  String strax_doc = new String("");
  String strax_dr = new String("");  
  String strax_fio_sokr = new String("");
  String D_ADMIN_PAY = new String("X");
  String D_RESERVE_PAY = new String("X");
  String D_ITOGO_PREM = new String("X"); 
  String D_ITOGO_PREM_OLD = new String("X");   
  
  String S_DAT_VYZH = new String("X"); 
  double NUM_PP = 1; 
  double ROW_PRIL = 0;
  
  double ITOGO_PREM_D = 0;      
  double ITOGO_PREM_D_OLD = 0;        
%>

<rw:report id="report">


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="dopsg_ids" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="DOPSG_IDS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="POL_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="REP_REPORT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>	 	 
    <userParameter name="POL_ID_OLD" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_KOD_VAL" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_KOD_VAL_UP" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="CHECK_SER" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/> 
	 <userParameter name="amount_z" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="s_surr" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="s_surr_reserve" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="pol_header" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="ex_invest" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="p_cover_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="ex_invest_reserve" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	  <userParameter name="amount_let" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="plan_date_let" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="ver_start_date" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="gdv_let" datatype="character"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 
    <userParameter name="POL_SER" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
<userParameter name="NOTICE_NUM" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_KOD_VAL_OLD" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="UNDER_NOTE" datatype="character" width="4000"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_DOP" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_EXIST_DOP_MAND" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="NEXT_PAYS" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FIRST_PAY" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FIRST_PAY_OLD" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="NEXT_PAYS_OLD" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	 	 
	<userParameter name="P_GENITIVE_POSITION_NAME" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_CASE_GENITIVE_SIGNER_NAME" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>	
	<userParameter name="P_PROCURORY_NUM" datatype="character" width="30"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_POLICY">
      <select canParse="no">
      <![CDATA[SELECT p.policy_id, ph.policy_header_id,
              ame.ADDENDUM_NOTE,
       p.VERSION_ORDER_NUM VERSION_NUM,
       ph.start_date CONFIRM_DATE,
       sysdate confDate_opl,
       p.CONFIRM_DATE + 15 confDate_oplEnd,
p.start_date CONFIRM_DATE_ADDENDUM,
       NVL (DECODE (NVL (pol_ser, '@'),
                    '@', pol_num,
                    pol_ser || '-' || pol_num
                   ),
            '@@'
           ) pol_ser_num,
nvl(ame.UNDERWRITING_NOTE,'@') as UNDERWRITING_NOTE,
(select lower(DESCRIPTION) from VEN_T_PAYMENT_TERMS where ID = p.PAYMENT_TERM_ID) as PA_PERIODICH,
    ent.obj_name('CONTACT',sur.assured_contact_id) sur_c,
    to_char(pkg_contact.get_birth_date(sur.assured_contact_id),'dd.mm.yyyy') sur_d,
    replace(replace(pkg_contact.get_primary_doc (sur.assured_contact_id),
            '������� ���������� ��  �����','�������'),'-',' ') sur_p
  FROM ven_p_policy p, ven_p_pol_header ph, ven_as_asset ass, ven_ASSURED_MEDICAL_EXAM ame, ven_as_assured sur
WHERE p.POL_HEADER_ID = ph.POLICY_HEADER_ID
  and p.POLICY_ID = ass.P_POLICY_ID(+)
  AND ass.AS_ASSET_ID = ame.AS_ASSURED_ID(+)
  and p.POLICY_ID = sur.P_POLICY_ID(+)
 AND p.policy_id = :POL_ID
]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.04041" y="0.60620" width="1.68176" height="1.62695"
        />
        <dataItem name="CONFDATE_OPL" datatype="date" oracleDatatype="date"
         columnOrder="107" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Confdate Opl">
          <dataDescriptor expression="CONFDATE_OPL"
           descriptiveExpression="CONFDATE_OPL" order="6" width="9"/>
        </dataItem>
        <dataItem name="CONFDATE_OPLEND" datatype="date" oracleDatatype="date"
         columnOrder="108" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Confdate Oplend">
          <dataDescriptor expression="CONFDATE_OPLEND"
           descriptiveExpression="CONFDATE_OPLEND" order="7" width="9"/>
        </dataItem>
        <dataItem name="SUR_C" datatype="vchar2" columnOrder="27" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sur C">
          <dataDescriptor expression="SUR_C" descriptiveExpression="SUR_C"
           order="12" width="4000"/>
        </dataItem>
        <dataItem name="SUR_D" datatype="vchar2" columnOrder="28"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sur D">
          <dataDescriptor expression="SUR_D" descriptiveExpression="SUR_D"
           order="13" width="10"/>
        </dataItem>
        <dataItem name="SUR_P" datatype="vchar2" columnOrder="29" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sur P">
          <dataDescriptor expression="SUR_P" descriptiveExpression="SUR_P"
           order="14" width="4000"/>
        </dataItem>
        <dataItem name="PA_PERIODICH" datatype="vchar2" columnOrder="26"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pa Periodich">
          <dataDescriptor expression="PA_PERIODICH"
           descriptiveExpression="PA_PERIODICH" order="11" width="500"/>
        </dataItem>
        <dataItem name="UNDERWRITING_NOTE" datatype="vchar2" columnOrder="25"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Underwriting Note">
          <dataDescriptor expression="UNDERWRITING_NOTE"
           descriptiveExpression="UNDERWRITING_NOTE" order="10" width="2000"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE_ADDENDUM" datatype="date"
         oracleDatatype="date" columnOrder="24" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Confirm Date Addendum">
          <dataDescriptor expression="CONFIRM_DATE_ADDENDUM"
           descriptiveExpression="CONFIRM_DATE_ADDENDUM" order="8"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="ADDENDUM_NOTE" datatype="vchar2" columnOrder="23"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Addendum Note">
          <dataDescriptor expression="ADDENDUM_NOTE"
           descriptiveExpression="ADDENDUM_NOTE" order="3" width="2000"/>
        </dataItem>
        <dataItem name="VERSION_NUM" oracleDatatype="number" columnOrder="21"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Version Num">
          <dataDescriptor expression="VERSION_NUM"
           descriptiveExpression="VERSION_NUM" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE" datatype="date" oracleDatatype="date"
         columnOrder="22" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Confirm Date">
          <dataDescriptor expression="CONFIRM_DATE"
           descriptiveExpression="CONFIRM_DATE" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="POLICY_ID"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POLICY_HEADER_ID" oracleDatatype="number"
         columnOrder="19" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="pol_ser_num" datatype="vchar2" columnOrder="20"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num">
          <dataDescriptor expression="POL_SER_NUM"
           descriptiveExpression="POL_SER_NUM" order="9" width="2049"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL">
      <select>
      <![CDATA[SELECT iss.policy_id, iss.contact_id, iss.contact_name, vcp.date_of_birth,
       replace(NVL (TRIM (pkg_contact.get_primary_doc (iss.contact_id)),'@@'),'-',' ') doc_inf, 
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id;       ]]>
      </select>
      <displayInfo x="2.12427" y="0.09387" width="1.32312" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="2.10815" y="0.64563" width="1.35876" height="1.45605"
        />
        <dataItem name="short_name" datatype="vchar2" columnOrder="35"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Short Name">
          <dataDescriptor expression="vc.short_name"
           descriptiveExpression="SHORT_NAME" order="6" width="100"/>
        </dataItem>
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="32"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="iss.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="date_of_birth" datatype="date" oracleDatatype="date"
         columnOrder="33" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf" datatype="vchar2" columnOrder="34"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf">
          <dataDescriptor
           expression="replace ( NVL ( TRIM ( pkg_contact.get_primary_doc ( iss.contact_id ) ) , &apos;@@&apos; ) , &apos;-&apos; , &apos; &apos; )"
           descriptiveExpression="DOC_INF" order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_MAIN_COVER">
      <select>
      <![CDATA[    select pkg_rep_utils.to_money(pc.ins_amount) MAIN_COVER_SUM,
pkg_rep_utils.to_money(pc.fee) as MAIN_COVER_PREM,
         upper(plo.description) MAIN_COVER
    from 
        ins.p_policy pp, 
        ins.as_asset ass, 
        ins.p_cover pc, 
        ins.t_prod_line_option plo,
        ins.t_product_line pl,
        ins.t_product_line_type plt
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
	 and pc.decline_date is null
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) NOT IN ('���������������� ��������')
	 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                                 FROM ins.t_lob_line lb
                                 WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                                 )
     and rownum = 1;
]]>
      </select>
      <displayInfo x="0.29175" y="2.78125" width="1.50000" height="0.19995"/>
      <group name="G_MAIN_COVER">
        <displayInfo x="0.23840" y="3.24158" width="1.60535" height="0.77246"
        />
        <dataItem name="MAIN_COVER_SUM" datatype="vchar2" columnOrder="36"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pkg Rep Utils To Money Pc Ins">
          <xmlSettings xmlTag="PKG_REP_UTILS_TO_MONEY_PC_INS_"/>
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( pc.ins_amount )"
           descriptiveExpression="MAIN_COVER_SUM" order="1" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER_PREM" datatype="vchar2" columnOrder="37"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pkg Rep Utils To Money Pc Prem">
          <xmlSettings xmlTag="PKG_REP_UTILS_TO_MONEY_PC_PREM"/>
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.fee )"
           descriptiveExpression="MAIN_COVER_PREM" order="2" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER" datatype="vchar2" columnOrder="38"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <xmlSettings xmlTag="DESCRIPTION"/>
          <dataDescriptor expression="upper ( plo.description )"
           descriptiveExpression="MAIN_COVER" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ITOG_PREM">
      <select>
      <![CDATA[  select pkg_rep_utils.to_money(sum(pc.fee)) ITOGO_PREM,
sum(pc.fee) itogo_prem_d
  from 
        ins.p_policy pp, 
        ins.as_asset ass, 
        ins.p_cover pc, 
        ins.t_prod_line_option plo,
		ins.t_product_line pl
  where pp.policy_id = :POL_ID
   and ass.p_policy_id = pp.policy_id
   and pc.decline_date is null
   and pc.as_asset_id = ass.as_asset_id
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) NOT IN ('���������������� ��������')
   AND plo.product_line_id = pl.id
   AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                               FROM ins.t_lob_line lb
                               WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                               );
]]>
      </select>
      <displayInfo x="2.29163" y="2.80212" width="1.13538" height="0.19995"/>
      <group name="G_ITOGO_PREM">
        <displayInfo x="2.19666" y="3.27283" width="1.32751" height="0.60156"
        />
        <dataItem name="itogo_prem_d" oracleDatatype="number"
         columnOrder="105" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Itogo Prem D">
          <dataDescriptor expression="sum ( pc.premium )"
           descriptiveExpression="ITOGO_PREM_D" order="2" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="ITOGO_PREM" datatype="vchar2" columnOrder="39"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Itogo Prem">
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( sum ( pc.premium ) )"
           descriptiveExpression="ITOGO_PREM" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ADMIN_PAY">
      <select>
      <![CDATA[select pkg_rep_utils.to_money(pc.premium) ADMIN_PAY
    from 
            ins.p_policy pp, 
            ins.as_asset ass, 
            ins.p_cover pc, 
            ins.t_prod_line_option plo
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = '���������������� ��������'
     and rownum = 1;]]>
      </select>
      <displayInfo x="3.71912" y="2.75000" width="1.11450" height="0.19995"/>
      <group name="G_ADMIN_PAY">
        <displayInfo x="3.63940" y="3.26257" width="1.27551" height="0.43066"
        />
        <dataItem name="ADMIN_PAY" datatype="vchar2" columnOrder="40"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Admin Pay">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.premium )"
           descriptiveExpression="ADMIN_PAY" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
	<dataSource name="Q_RESERVE_PAY">
      <select>
      <![CDATA[select pkg_rep_utils.to_money(SUM(pc.premium)) RESERVE_PAY
    from 
            ins.p_policy pp, 
            ins.as_asset ass, 
            ins.p_cover pc, 
            ins.t_prod_line_option plo,
            ins.t_product_line pl
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     AND plo.product_line_id = pl.id
     AND pl.t_lob_line_id IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              );]]>
      </select>
      <displayInfo x="3.71912" y="2.75000" width="1.11450" height="0.19995"/>
      <group name="G_RESERVE_PAY">
        <displayInfo x="3.63940" y="3.26257" width="1.27551" height="0.43066"
        />
        <dataItem name="RESERVE_PAY" datatype="vchar2" columnOrder="40"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Reserve Pay">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.premium )"
           descriptiveExpression="RESERVE_PAY" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOP_SUMM">
      <select>
      <![CDATA[-- ������������� ���������
select pkg_rep_utils.to_money(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money(pc.fee) as dop_prem,
decode(plo.description,'�������������� �������������� �����','������',
              upper(plo.description)) as dop_progr,	   

--upper(plo.description) as dop_progr,
        decode(upper(plo.description), 
              '������������ �� ������ ���������� �������', 1, 
              '������ ��������� �������', 1,
	'������������ �� ������ ��������� �������', 1,
	'������������ �� ������ ���������� ������� ������������ �� �������� ���������',1,
	'������������ �� ������ ������� ������������ �� �������� ���������',1,
	'������ ��������� ������� ������������ �� �������� ���������',1,
              0) as need_x

from 
		ins.p_policy pp, 
		ins.as_asset ass, 
		ins.p_cover pc, 
		ins.t_prod_line_option plo,
		ins.t_product_line pl,
		ins.t_product_line_type plt
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
--and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and upper(trim(plo.description)) NOT IN ('���������������� ��������')
 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                             );]]>
      </select>
      <displayInfo x="3.87488" y="0.22913" width="1.18958" height="0.19995"/>
      <group name="G_dop_summ">
        <displayInfo x="3.87915" y="0.76257" width="1.19214" height="1.28516"
        />
        <dataItem name="need_x" oracleDatatype="number" columnOrder="44"
         width="2" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Need X">
          <dataDescriptor
           expression="decode ( upper ( plo.description ) , &apos;������������ �� ������ ��������� �������&apos; , 1 , 0 )"
           descriptiveExpression="NEED_X" order="4" width="2" precision="38"/>
        </dataItem>
        <dataItem name="dop_summ" datatype="vchar2" columnOrder="41"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Summ">
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( pc.ins_amount )"
           descriptiveExpression="DOP_SUMM" order="1" width="4000"/>
        </dataItem>
        <dataItem name="dop_prem" datatype="vchar2" columnOrder="42"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Prem">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.fee )"
           descriptiveExpression="DOP_PREM" order="2" width="4000"/>
        </dataItem>
        <dataItem name="dop_progr" datatype="vchar2" columnOrder="43"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Progr">
          <dataDescriptor expression="upper ( plo.description )"
           descriptiveExpression="DOP_PROGR" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_VYK_SUMM">
      <select canParse="no">
      <![CDATA[select 
rownum as n,
v.insurance_year_number as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.* from ven_policy_cash_surr p, ven_policy_cash_surr_d d
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief = 'RECOMMENDED')
    order by d.start_cash_surr_date  ) v]]>
      </select>
      <displayInfo x="5.60425" y="0.21875" width="1.06250" height="0.19995"/>
      <group name="G_VYK_SUMM">
        <displayInfo x="5.40540" y="0.71033" width="1.45251" height="1.11426"
        />
        <dataItem name="N" oracleDatatype="number" columnOrder="45" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N">
          <dataDescriptor expression="N" descriptiveExpression="N" order="1"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER" oracleDatatype="number" columnOrder="46"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number">
          <dataDescriptor expression="YEAR_NUMBER"
           descriptiveExpression="YEAR_NUMBER" order="2" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="PERIOD_START" datatype="vchar2" columnOrder="47"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start">
          <dataDescriptor expression="PERIOD_START"
           descriptiveExpression="PERIOD_START" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END" datatype="vchar2" columnOrder="48"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End">
          <dataDescriptor expression="PERIOD_END"
           descriptiveExpression="PERIOD_END" order="4" width="10"/>
        </dataItem>
        <dataItem name="RANSOM" datatype="vchar2" columnOrder="49"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom">
          <dataDescriptor expression="RANSOM" descriptiveExpression="RANSOM"
           order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
<dataSource name="Q_VYK_SUMM_I">
      <select canParse="no">
      <![CDATA[select 
rownum as n,
v.insurance_year_number as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.* from ven_policy_cash_surr p, ven_policy_cash_surr_d d
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  and p.T_LOB_LINE_ID = (select distinct T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  AND prl.T_LOB_LINE_ID NOT IN (SELECT lb.t_lob_line_id
                               FROM ins.t_lob_line lb
                               WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                               )
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY'))
    order by d.start_cash_surr_date  ) v]]>
      </select>
      <displayInfo x="5.60425" y="0.21875" width="1.06250" height="0.19995"/>
      <group name="G_VYK_SUMM_I">
        <displayInfo x="5.40540" y="0.71033" width="1.45251" height="1.11426"
        />
        <dataItem name="N_I" oracleDatatype="number" columnOrder="45" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N I">
          <dataDescriptor expression="N_I" descriptiveExpression="N_I" order="1"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER_i" oracleDatatype="number" columnOrder="46"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number  I">
          <dataDescriptor expression="YEAR_NUMBER_I"
           descriptiveExpression="YEAR_NUMBER_I" order="2" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="PERIOD_START_I" datatype="vchar2" columnOrder="47"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start I">
          <dataDescriptor expression="PERIOD_START_I"
           descriptiveExpression="PERIOD_START_I" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END_I" datatype="vchar2" columnOrder="48"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End I">
          <dataDescriptor expression="PERIOD_END_I"
           descriptiveExpression="PERIOD_END_I" order="4" width="10"/>
        </dataItem>
        <dataItem name="RANSOM_I" datatype="vchar2" columnOrder="49"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom I">
          <dataDescriptor expression="RANSOM_I" descriptiveExpression="RANSOM_I"
           order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>

    <dataSource name="Q_DAT_VYZH">
      <select>
      <![CDATA[select to_char(ds.start_date,'dd.mm.yyyy') dat_vyzh
from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id =:POL_ID]]>
      </select>
      <displayInfo x="5.29175" y="2.14575" width="0.96863" height="0.19995"/>
      <group name="G_dat_vyzh">
        <displayInfo x="5.21753" y="2.67920" width="1.16089" height="0.43066"
        />
        <dataItem name="dat_vyzh" datatype="vchar2" columnOrder="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dat Vyzh">
          <dataDescriptor
           expression="to_char ( ds.start_date , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="DAT_VYZH" order="1" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PA_ROW_PRIL">
      <select>
      <![CDATA[select count(1) PA_ROW_PRIL
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
]]>
      </select>
      <displayInfo x="5.10413" y="3.37500" width="1.39587" height="0.19995"/>
      <group name="G_PA_ROW_PRIL">
        <displayInfo x="5.15417" y="3.85608" width="1.09998" height="0.43066"
        />
        <dataItem name="PA_ROW_PRIL" oracleDatatype="number" columnOrder="51"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="count ( 1 )"
           descriptiveExpression="PA_ROW_PRIL" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_POLICY_OLD">
      <select canParse="no">
      <![CDATA[SELECT p.policy_id, ph.policy_header_id,ame.ADDENDUM_NOTE,
       p.VERSION_ORDER_NUM VERSION_NUM,
       p.CONFIRM_DATE,
p.CONFIRM_DATE_ADDENDUM,
       NVL (DECODE (NVL (pol_ser, '@'),
                    '@', pol_num,
                    pol_ser || '-' || pol_num
                   ),
            '@@'
           ) pol_ser_num,
nvl(ame.UNDERWRITING_NOTE,'@') as UNDERWRITING_NOTE,
(select lower(DESCRIPTION) from VEN_T_PAYMENT_TERMS where ID = p.PAYMENT_TERM_ID) as PA_PERIODICH,
    ent.obj_name('CONTACT',sur.assured_contact_id) sur_c,
    to_char(pkg_contact.get_birth_date(sur.assured_contact_id),'dd.mm.yyyy') sur_d,
    replace(replace(pkg_contact.get_primary_doc (sur.assured_contact_id),
            '������� ���������� ��  �����','�������'),'-',' ') sur_p
  FROM ven_p_policy p, ven_p_pol_header ph, ven_as_asset ass, ven_ASSURED_MEDICAL_EXAM ame, ven_as_assured sur
WHERE p.POL_HEADER_ID = ph.POLICY_HEADER_ID
  and p.POLICY_ID = ass.P_POLICY_ID(+)
  AND ass.AS_ASSET_ID = ame.AS_ASSURED_ID(+)
  and p.POLICY_ID = sur.P_POLICY_ID(+)
 AND p.policy_id = :POL_ID_OLD]]>
      </select>
      <displayInfo x="0.43750" y="4.51038" width="0.69995" height="0.19995"/>
      <group name="G_POLICY_OLD">
        <displayInfo x="0.04041" y="4.89783" width="2.18176" height="1.62695"
        />
        <dataItem name="SUR_C1" datatype="vchar2" columnOrder="61"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sur C1">
          <dataDescriptor expression="SUR_C" descriptiveExpression="SUR_C"
           order="10" width="4000"/>
        </dataItem>
        <dataItem name="SUR_D1" datatype="vchar2" columnOrder="62"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sur D1">
          <dataDescriptor expression="SUR_D" descriptiveExpression="SUR_D"
           order="11" width="10"/>
        </dataItem>
        <dataItem name="SUR_P1" datatype="vchar2" columnOrder="63"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Sur P1">
          <dataDescriptor expression="SUR_P" descriptiveExpression="SUR_P"
           order="12" width="4000"/>
        </dataItem>
        <dataItem name="POLICY_ID2" oracleDatatype="number" columnOrder="52"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id2">
          <dataDescriptor expression="POLICY_ID"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POLICY_HEADER_ID1" oracleDatatype="number"
         columnOrder="53" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id1">
          <dataDescriptor expression="POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="ADDENDUM_NOTE1" datatype="vchar2" columnOrder="54"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Addendum Note1">
          <dataDescriptor expression="ADDENDUM_NOTE"
           descriptiveExpression="ADDENDUM_NOTE" order="3" width="2000"/>
        </dataItem>
        <dataItem name="VERSION_NUM1" oracleDatatype="number" columnOrder="55"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Version Num1">
          <dataDescriptor expression="VERSION_NUM"
           descriptiveExpression="VERSION_NUM" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE1" datatype="date" oracleDatatype="date"
         columnOrder="56" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Confirm Date1">
          <dataDescriptor expression="CONFIRM_DATE"
           descriptiveExpression="CONFIRM_DATE" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE_ADDENDUM1" datatype="date"
         oracleDatatype="date" columnOrder="57" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Confirm Date Addendum1">
          <dataDescriptor expression="CONFIRM_DATE_ADDENDUM"
           descriptiveExpression="CONFIRM_DATE_ADDENDUM" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="POL_SER_NUM1" datatype="vchar2" columnOrder="58"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num1">
          <dataDescriptor expression="POL_SER_NUM"
           descriptiveExpression="POL_SER_NUM" order="7" width="2049"/>
        </dataItem>
        <dataItem name="UNDERWRITING_NOTE1" datatype="vchar2" columnOrder="59"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Underwriting Note1">
          <dataDescriptor expression="UNDERWRITING_NOTE"
           descriptiveExpression="UNDERWRITING_NOTE" order="8" width="2000"/>
        </dataItem>
        <dataItem name="PA_PERIODICH1" datatype="vchar2" columnOrder="60"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pa Periodich1">
          <dataDescriptor expression="PA_PERIODICH"
           descriptiveExpression="PA_PERIODICH" order="9" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL_OLD">
      <select>
      <![CDATA[SELECT iss.policy_id, iss.contact_id, iss.contact_name, vcp.date_of_birth,
       replace(NVL (TRIM (pkg_contact.get_primary_doc (iss.contact_id)),'@@'),'-',' ') doc_inf, 
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id;   ]]>
      </select>
      <displayInfo x="2.70837" y="4.40625" width="0.69995" height="0.32983"/>
      <group name="G_STRAHOVATEL_OLD">
        <displayInfo x="2.54565" y="5.10620" width="1.42126" height="1.28516"
        />
        <dataItem name="policy_id3" oracleDatatype="number" columnOrder="64"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id3">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="contact_id1" oracleDatatype="number" columnOrder="65"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id1">
          <dataDescriptor expression="iss.contact_id"
           descriptiveExpression="CONTACT_ID" order="2" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="contact_name1" datatype="vchar2" columnOrder="66"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name1">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="3" width="2000"/>
        </dataItem>
        <dataItem name="date_of_birth1" datatype="date" oracleDatatype="date"
         columnOrder="67" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth1">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4" width="9"/>
        </dataItem>
        <dataItem name="doc_inf1" datatype="vchar2" columnOrder="68"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf1">
          <dataDescriptor
           expression="replace ( NVL ( TRIM ( pkg_contact.get_primary_doc ( iss.contact_id ) ) , &apos;@@&apos; ) , &apos;-&apos; , &apos; &apos; )"
           descriptiveExpression="DOC_INF" order="5" width="4000"/>
        </dataItem>
        <dataItem name="short_name1" datatype="vchar2" columnOrder="69"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Short Name1">
          <dataDescriptor expression="vc.short_name"
           descriptiveExpression="SHORT_NAME" order="6" width="100"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOP_SUMM_OLD">
      <select>
      <![CDATA[-- ������������� ���������
select pkg_rep_utils.to_money(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money(pc.fee) as dop_prem,
decode(plo.description,'�������������� �������������� �����','������',
              upper(plo.description)) as dop_progr,  

--upper(plo.description) as dop_progr,
        decode(upper(plo.description), 
              '������������ �� ������ ���������� �������', 1, 
              '������ ��������� �������', 1,
	'������������ �� ������ ��������� �������', 1,
	'������������ �� ������ ���������� ������� ������������ �� �������� ���������',1,
	'������������ �� ������ ������� ������������ �� �������� ���������',1,
	'������ ��������� ������� ������������ �� �������� ���������',1,
              0) as need_x
from 
		ins.p_policy pp, 
		ins.as_asset ass, 
		ins.p_cover pc, 
		ins.t_prod_line_option plo,
		ins.t_product_line pl,
		ins.t_product_line_type plt
where pp.policy_id = :POL_ID_OLD
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and upper(trim(plo.description)) NOT IN ('���������������� ��������')
 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              );
 ]]>
      </select>
      <displayInfo x="4.13538" y="5.02087" width="1.40625" height="0.19995"/>
      <group name="G_DOP_SUMM_OLD">
        <displayInfo x="4.07678" y="5.54370" width="1.25464" height="0.77246"
        />
        <dataItem name="need_x1" oracleDatatype="number" columnOrder="73"
         width="2" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Need X1">
          <dataDescriptor
           expression="decode ( upper ( plo.description ) , &apos;������������ �� ������ ��������� �������&apos; , 1 , 0 )"
           descriptiveExpression="NEED_X" order="4" width="2" precision="38"/>
        </dataItem>
        <dataItem name="dop_summ1" datatype="vchar2" columnOrder="70"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Summ1">
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( pc.ins_amount )"
           descriptiveExpression="DOP_SUMM" order="1" width="4000"/>
        </dataItem>
        <dataItem name="dop_prem1" datatype="vchar2" columnOrder="71"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Prem1">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.fee )"
           descriptiveExpression="DOP_PREM" order="2" width="4000"/>
        </dataItem>
        <dataItem name="dop_progr1" datatype="vchar2" columnOrder="72"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Dop Progr1">
          <dataDescriptor expression="upper ( plo.description )"
           descriptiveExpression="DOP_PROGR" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_MAIN_COVER_OLD">
      <select>
      <![CDATA[    select pkg_rep_utils.to_money(pc.ins_amount) MAIN_COVER_SUM,
       pkg_rep_utils.to_money(pc.premium) MAIN_COVER_PREM,
         upper(plo.description) MAIN_COVER
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
    where pp.policy_id = :POL_ID_OLD
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
	 and pc.decline_date is null
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) NOT IN ('���������������� ��������')
     and rownum = 1;
]]>
      </select>
      <displayInfo x="5.17712" y="4.66663" width="1.38745" height="0.19995"/>
      <group name="G_MAIN_COVER_OLD">
        <displayInfo x="5.62891" y="5.32495" width="1.75464" height="0.77246"
        />
        <dataItem name="MAIN_COVER_SUM1" datatype="vchar2" columnOrder="74"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Main Cover Sum1">
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( pc.ins_amount )"
           descriptiveExpression="MAIN_COVER_SUM" order="1" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER_PREM1" datatype="vchar2" columnOrder="75"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Main Cover Prem1">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.premium )"
           descriptiveExpression="MAIN_COVER_PREM" order="2" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER1" datatype="vchar2" columnOrder="76"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Main Cover1">
          <dataDescriptor expression="upper ( plo.description )"
           descriptiveExpression="MAIN_COVER" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ITOG_PREM_OLD">
      <select>
      <![CDATA[  select pkg_rep_utils.to_money(sum(pc.premium)) ITOGO_PREM,
sum(pc.premium) itogo_prem_d
  from 
        ins.p_policy pp, 
        ins.as_asset ass, 
        ins.p_cover pc, 
        ins.t_prod_line_option plo,
		ins.t_product_line pl
  where pp.policy_id = :POL_ID_OLD
   and ass.p_policy_id = pp.policy_id
   and pc.as_asset_id = ass.as_asset_id
   and pc.decline_date is null
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) NOT IN ('���������������� ��������')
   AND plo.product_line_id = pl.id
   AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                               FROM ins.t_lob_line lb
                               WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                               );
]]>
      </select>
      <displayInfo x="3.08325" y="6.63538" width="0.69995" height="0.19995"/>
      <group name="G_ITOGO_PREM_OLD">
        <displayInfo x="2.90491" y="7.26257" width="1.39001" height="0.60156"
        />
        <dataItem name="itogo_prem_d1" oracleDatatype="number"
         columnOrder="106" width="22" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Itogo Prem D1">
          <dataDescriptor expression="sum ( pc.premium )"
           descriptiveExpression="ITOGO_PREM_D" order="2" width="22"
           precision="38"/>
        </dataItem>
        <dataItem name="ITOGO_PREM1" datatype="vchar2" columnOrder="77"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Itogo Prem1">
          <dataDescriptor
           expression="pkg_rep_utils.to_money ( sum ( pc.premium ) )"
           descriptiveExpression="ITOGO_PREM" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ADMIN_PAY_OLD">
      <select>
      <![CDATA[select pkg_rep_utils.to_money(pc.premium) ADMIN_PAY
    from 
            ins.p_policy pp, 
            ins.as_asset ass, 
            ins.p_cover pc, 
            ins.t_prod_line_option plo
    where pp.policy_id = :POL_ID_OLD
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = '���������������� ��������'
     and rownum = 1;]]>
      </select>
      <displayInfo x="4.87500" y="6.58325" width="0.69995" height="0.19995"/>
      <group name="G_ADMIN_PAY_OLD">
        <displayInfo x="4.62891" y="7.14783" width="1.33801" height="0.43066"
        />
        <dataItem name="ADMIN_PAY1" datatype="vchar2" columnOrder="78"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Admin Pay1">
          <dataDescriptor expression="pkg_rep_utils.to_money ( pc.premium )"
           descriptiveExpression="ADMIN_PAY" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PERIOD">
      <select>
      <![CDATA[select '(�������� ���������)' as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pp.start_date,
	    pp.end_date
from        
        		ins.p_policy pp, 
        		ins.as_asset ass, 
        		ins.p_cover pc, 
        		ins.t_prod_line_option plo,
        		ins.t_product_line pl,
        		ins.t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
			 and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('RECOMMENDED')
             and upper(trim(plo.description)) NOT IN ('���������������� ��������')
]]>
      </select>
      <displayInfo x="6.91663" y="2.35413" width="0.69995" height="0.19995"/>
      <group name="G_PERIOD_OSN">
        <displayInfo x="6.66541" y="3.05408" width="1.20251" height="0.94336"
        />
        <dataItem name="description" datatype="character"
         oracleDatatype="aFixedChar" columnOrder="79" width="20"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Description">
          <dataDescriptor expression="&apos;(�������� ���������)&apos;"
           descriptiveExpression="DESCRIPTION" order="1"
           oracleDatatype="aFixedChar" width="20"/>
        </dataItem>
        <dataItem name="years" oracleDatatype="number" columnOrder="80"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years">
          <dataDescriptor
           expression="round ( months_between ( pc.end_date , pc.start_date ) / 12 )"
           descriptiveExpression="YEARS" order="2" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="start_date" datatype="date" oracleDatatype="date"
         columnOrder="81" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="end_date" datatype="date" oracleDatatype="date"
         columnOrder="82" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date">
          <dataDescriptor expression="pc.end_date"
           descriptiveExpression="END_DATE" order="4" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select --decode(rownum,1,'�������������� ���������:' ||plo.description,'' || plo.description) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pp.start_date,
	    to_date(to_char(pp.start_date - 1,'dd.mm')||'.'||to_char(extract(year from pp.start_date) + 1),'dd.mm.yyyy') end_date
from        
        		ins.p_policy pp, 
        		ins.as_asset ass, 
        		ins.p_cover pc, 
        		ins.t_prod_line_option plo,
        		ins.t_product_line pl,
        		ins.t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
             and plo.id = pc.t_prod_line_option_id
			 and pc.decline_date is null
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('���������������� ��������')
			 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              			  FROM ins.t_lob_line lb
                              			  WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              			  );
]]>
      </select>
      <displayInfo x="8.00000" y="3.90625" width="0.69995" height="0.19995"/>
      <group name="G_PERIOD_DOP_GL">
        <displayInfo x="7.69653" y="4.51245" width="1.22339" height="0.77246"
        />
        <dataItem name="years1" oracleDatatype="number" columnOrder="83"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years1">
          <dataDescriptor
           expression="round ( months_between ( pc.end_date , pc.start_date ) / 12 )"
           descriptiveExpression="YEARS" order="1" width="22" precision="38"/>
        </dataItem>
        <dataItem name="start_date1" datatype="date" oracleDatatype="date"
         columnOrder="84" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date1">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="2" width="9"/>
        </dataItem>
        <dataItem name="end_date1" datatype="date" oracleDatatype="date"
         columnOrder="85" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date1">
          <dataDescriptor expression="pc.end_date"
           descriptiveExpression="END_DATE" order="3" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[select decode(rownum,1,'�������������� ���������:' ||decode(plo.description,'�������������� �������������� �����','������',
              (plo.description)),'' || decode(plo.description,'�������������� �������������� �����','������',
              (plo.description))) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pp.start_date,
	    to_date(to_char(pp.start_date - 1,'dd.mm')||'.'||to_char(extract(year from pp.start_date) + 1),'dd.mm.yyyy') end_date
from        
        		ins.p_policy pp, 
        		ins.as_asset ass, 
        		ins.p_cover pc, 
        		ins.t_prod_line_option plo,
        		ins.t_product_line pl,
        		ins.t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
    and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('���������������� ��������')
			 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              			  FROM ins.t_lob_line lb
                              			  WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              		  	  );
]]>
      </select>
      <displayInfo x="9.57288" y="3.91663" width="0.69995" height="0.47974"/>
      <group name="G_PERIOD_DOP_L">
        <displayInfo x="9.39453" y="4.77295" width="1.26501" height="0.94336"
        />
        <dataItem name="description1" datatype="vchar2" columnOrder="86"
         width="280" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description1">
          <dataDescriptor
           expression="decode ( rownum , 1 , &apos;�������������� ���������:&apos; || plo.description , &apos;&apos; || plo.description )"
           descriptiveExpression="DESCRIPTION" order="1" width="280"/>
        </dataItem>
        <dataItem name="years2" oracleDatatype="number" columnOrder="87"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years2">
          <dataDescriptor
           expression="round ( months_between ( pc.end_date , pc.start_date ) / 12 )"
           descriptiveExpression="YEARS" order="2" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="start_date2" datatype="date" oracleDatatype="date"
         columnOrder="88" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date2">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="end_date2" datatype="date" oracleDatatype="date"
         columnOrder="89" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="End Date2">
          <dataDescriptor expression="pc.end_date"
           descriptiveExpression="END_DATE" order="4" oracleDatatype="date"
           width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select 
nvl(ent.obj_name('CONTACT',b.contact_id),'X') as beneficiary,
nvl(to_char(pkg_contact.get_birth_date(b.contact_id),'dd.mm.yyyy'),'X') as ben_birth,
nvl(pkg_contact.get_rel_description(su.assured_contact_id,b.contact_id),'X') as ben_rel,
decode(b.value,null,'X',pkg_rep_utils.to_money(b.value) || ' ' || decode(pth.brief,'percent','%','absol',f.brief)) as ben_part
from 
ven_as_asset a,
ven_as_assured su , 
ven_as_beneficiary b,
t_path_type   pth,
fund f,
(select :POL_ID id from dual) dd
where a.p_policy_id(+) = dd.id
 and b.as_asset_id(+) = a.as_asset_id
 and su.as_assured_id(+) = a.as_asset_id
 and pth.t_path_type_id (+) = b.value_type_id
 and f.fund_id (+) = b.t_currency_id]]>
      </select>
      <displayInfo x="8.71875" y="0.88538" width="0.69995" height="0.19995"/>
      <group name="G_VYGOD">
        <displayInfo x="8.46228" y="1.58533" width="1.21301" height="0.94336"
        />
        <dataItem name="beneficiary" datatype="vchar2" columnOrder="90"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Beneficiary">
          <dataDescriptor
           expression="nvl ( ent.obj_name ( &apos;CONTACT&apos; , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BENEFICIARY" order="1" width="4000"/>
        </dataItem>
        <dataItem name="ben_birth" datatype="vchar2" columnOrder="91"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ben Birth">
          <dataDescriptor
           expression="nvl ( to_char ( pkg_contact.get_birth_date ( b.contact_id ) , &apos;dd.mm.yyyy&apos; ) , &apos;X&apos; )"
           descriptiveExpression="BEN_BIRTH" order="2" width="10"/>
        </dataItem>
        <dataItem name="ben_rel" datatype="vchar2" columnOrder="92"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Rel">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_rel_description ( su.assured_contact_id , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BEN_REL" order="3" width="4000"/>
        </dataItem>
        <dataItem name="ben_part" datatype="vchar2" columnOrder="93"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Part">
          <dataDescriptor
           expression="decode ( b.value , null , &apos;X&apos; , pkg_rep_utils.to_money ( b.value ) || &apos; &apos; || decode ( pth.brief , &apos;percent&apos; , &apos;%&apos; , &apos;absol&apos; , f.brief ) )"
           descriptiveExpression="BEN_PART" order="4" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_4">
      <select>
      <![CDATA[select 
nvl(ent.obj_name('CONTACT',b.contact_id),'X') as beneficiary,
nvl(to_char(pkg_contact.get_birth_date(b.contact_id),'dd.mm.yyyy'),'X') as ben_birth,
nvl(pkg_contact.get_rel_description(su.assured_contact_id,b.contact_id),'X') as ben_rel,
decode(b.value,null,'X',pkg_rep_utils.to_money(b.value) || ' ' || decode(pth.brief,'percent','%','absol',f.brief)) as ben_part
from 
ven_as_asset a,
ven_as_assured su , 
ven_as_beneficiary b,
t_path_type   pth,
fund f,
(select :POL_ID_OLD id from dual) dd
where a.p_policy_id(+) = dd.id
 and b.as_asset_id(+) = a.as_asset_id
 and su.as_assured_id(+) = a.as_asset_id
 and pth.t_path_type_id (+) = b.value_type_id
 and f.fund_id (+) = b.t_currency_id]]>
      </select>
      <displayInfo x="8.19788" y="6.32288" width="0.69995" height="0.19995"/>
      <group name="G_VYGOD_OLD">
        <displayInfo x="7.91016" y="7.02283" width="1.27551" height="0.94336"
        />
        <dataItem name="beneficiary1" datatype="vchar2" columnOrder="94"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Beneficiary1">
          <dataDescriptor
           expression="nvl ( ent.obj_name ( &apos;CONTACT&apos; , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BENEFICIARY" order="1" width="4000"/>
        </dataItem>
        <dataItem name="ben_birth1" datatype="vchar2" columnOrder="95"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ben Birth1">
          <dataDescriptor
           expression="nvl ( to_char ( pkg_contact.get_birth_date ( b.contact_id ) , &apos;dd.mm.yyyy&apos; ) , &apos;X&apos; )"
           descriptiveExpression="BEN_BIRTH" order="2" width="10"/>
        </dataItem>
        <dataItem name="ben_rel1" datatype="vchar2" columnOrder="96"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Rel1">
          <dataDescriptor
           expression="nvl ( pkg_contact.get_rel_description ( su.assured_contact_id , b.contact_id ) , &apos;X&apos; )"
           descriptiveExpression="BEN_REL" order="3" width="4000"/>
        </dataItem>
        <dataItem name="ben_part1" datatype="vchar2" columnOrder="97"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ben Part1">
          <dataDescriptor
           expression="decode ( b.value , null , &apos;X&apos; , pkg_rep_utils.to_money ( b.value ) || &apos; &apos; || decode ( pth.brief , &apos;percent&apos; , &apos;%&apos; , &apos;absol&apos; , f.brief ) )"
           descriptiveExpression="BEN_PART" order="4" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_5">
      <select>
      <![CDATA[select '(�������� ���������)' as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
        pc.end_date
from        
        		ins.p_policy pp, 
        		ins.as_asset ass, 
        		ins.p_cover pc, 
        		ins.t_prod_line_option plo,
        		ins.t_product_line pl,
        		ins.t_product_line_type plt
            where pp.policy_id = :POL_ID_OLD
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
			 and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('RECOMMENDED')
             and upper(trim(plo.description)) NOT IN ('���������������� ��������')
]]>
      </select>
      <displayInfo x="6.50000" y="6.57288" width="0.69995" height="0.19995"/>
      <group name="G_PERIOD_OSN_OLD">
        <displayInfo x="6.21753" y="7.27283" width="1.26501" height="0.94336"
        />
        <dataItem name="description2" datatype="character"
         oracleDatatype="aFixedChar" columnOrder="98" width="20"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Description2">
          <dataDescriptor expression="&apos;(�������� ���������)&apos;"
           descriptiveExpression="DESCRIPTION" order="1" width="20"/>
        </dataItem>
        <dataItem name="years3" oracleDatatype="number" columnOrder="99"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years3">
          <dataDescriptor
           expression="round ( months_between ( pc.end_date , pc.start_date ) / 12 )"
           descriptiveExpression="YEARS" order="2" width="22" precision="38"/>
        </dataItem>
        <dataItem name="start_date3" datatype="date" oracleDatatype="date"
         columnOrder="100" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Start Date3">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="3" width="9"/>
        </dataItem>
        <dataItem name="end_date3" datatype="date" oracleDatatype="date"
         columnOrder="101" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="End Date3">
          <dataDescriptor expression="pc.end_date"
           descriptiveExpression="END_DATE" order="4" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_6">
      <select>
      <![CDATA[select --decode(rownum,1,'�������������� ���������:' ||plo.description,'' || plo.description) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
	    pc.end_date
from        
        		ins.p_policy pp, 
        		ins.as_asset ass, 
        		ins.p_cover pc, 
        		ins.t_prod_line_option plo,
        		ins.t_product_line pl,
        		ins.t_product_line_type plt
            where pp.policy_id = :POL_ID_OLD
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
			 and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('���������������� ��������')
			 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              			  FROM ins.t_lob_line lb
                              			  WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              			  )
group by pc.start_date,  pc.end_date]]>
      </select>
      <displayInfo x="6.46875" y="8.64587" width="0.69995" height="0.19995"/>
      <group name="G_PERIOD_DOP_GL_OLD">
        <displayInfo x="6.20703" y="9.34583" width="1.22339" height="0.77246"
        />
        <dataItem name="years4" oracleDatatype="number" columnOrder="102"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years4">
          <dataDescriptor
           expression="round ( months_between ( pc.end_date , pc.start_date ) / 12 )"
           descriptiveExpression="YEARS" order="1" width="22" precision="38"/>
        </dataItem>
        <dataItem name="start_date4" datatype="date" oracleDatatype="date"
         columnOrder="103" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Start Date4">
          <dataDescriptor expression="pc.start_date"
           descriptiveExpression="START_DATE" order="2" width="9"/>
        </dataItem>
        <dataItem name="end_date4" datatype="date" oracleDatatype="date"
         columnOrder="104" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1" defaultLabel="End Date4">
          <dataDescriptor expression="pc.end_date"
           descriptiveExpression="END_DATE" order="3" width="9"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STRAHOVATEL" childColumn="policy_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY_OLD" parentColumn="POLICY_ID2"
     childQuery="Q_STRAHOVATEL_OLD" childColumn="policy_id3" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_PERIOD_DOP_GL" parentColumn="start_date1"
     childQuery="Q_2" childColumn="start_date2" condition="eq"
     sqlClause="where"/>
    <link name="L_4" parentGroup="G_PERIOD_DOP_GL" parentColumn="end_date1"
     childQuery="Q_2" childColumn="end_date2" condition="eq" sqlClause="where"
    />
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
	  v_signer pkg_report_signer.typ_signer;
begin
	--������ 325770: FW: ��������� �������� ����� ��� ����������	  	  
	v_signer := pkg_report_signer.get_signer_id_by_rep_id(:REP_REPORT_ID);
	:P_GENITIVE_POSITION_NAME := v_signer.job_position_genitive;
	:P_CASE_GENITIVE_SIGNER_NAME := pkg_contact.get_fio_fmt(pkg_contact.get_fio_case(v_signer.name,'�'),4);
	:P_PROCURORY_NUM := v_signer.procuratory_num;
	--325770-- 
begin
select count(*) into :P_EXIST_DOP
from 
        ins.p_policy pp, 
        ins.as_asset ass, 
        ins.p_cover pc, 
        ins.status_hist sh,
        ins.t_prod_line_option plo,
        ins.t_product_line pl,
        ins.t_product_line_type plt
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and upper(trim(plo.description)) NOT IN ('���������������� ��������')
 and pc.status_hist_id = sh.status_hist_id
 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              )
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0;
 
  exception
      when no_data_found then :P_EXIST_DOP := 0; 
  end;

begin
select count(*) into :P_EXIST_DOP_MAND
from 
        ins.p_policy pp, 
        ins.as_asset ass, 
        ins.p_cover pc, 
        ins.status_hist sh,
        ins.t_prod_line_option plo,
        ins.t_product_line pl,
        ins.t_product_line_type plt
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('MANDATORY')
 and upper(trim(plo.description)) NOT IN ('���������������� ��������')
 AND pl.t_lob_line_id NOT IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              )
 and pc.status_hist_id = sh.status_hist_id
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0;
 
  exception
      when no_data_found then :P_EXIST_DOP_MAND := 0; 
  end;
  
begin
select pl.policy_id
into :POL_ID_OLD
from p_policy pp,
     p_pol_header ph,
     p_policy pl
where pp.policy_id = :POL_ID
      and pp.pol_header_id = ph.policy_header_id
      and pl.pol_header_id = ph.policy_header_id
      and pl.version_num = pp.version_num - 1;
exception
      when no_data_found then :POL_ID_OLD := 0; 
  end;
    
begin
select p.pol_header_id,
	   case when (case when length(p.pol_num) > 6
                 then substr(p.pol_num,1,3)
                else '200'
           end) = '191' then 1
     when (case when length(p.pol_num) > 6
                 then substr(p.pol_num,1,3)
                else '200'
           end) = '192' then 1
     when (case when length(p.pol_num) > 6
                 then substr(p.pol_num,1,3)
                else '200'
           end) = '195' then 1
     else 0
end check_ser
into :pol_header, :CHECK_SER
from p_policy p
where p.policy_id = :POL_ID;
exception
      when no_data_found then :pol_header := 0; :CHECK_SER := 0;
  end;
  
begin
SELECT
  nvl(sum(a.amount),1)
into :amount_z
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  P_POLICY p,
  CONTACT c,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr
WHERE d.document_id = a.payment_id
  AND d.doc_templ_id = dt.doc_templ_id
  AND dt.brief = 'PAYMENT'
  AND dd.child_id = d.document_id
  AND dd.parent_id = p.policy_id
  AND a.contact_id = c.contact_id
  AND ds.document_id = d.document_id
  AND ds.start_date = (SELECT MAX(dss.start_date)
                       FROM DOC_STATUS dss
                       WHERE  dss.document_id = d.document_id)
  AND dsr.doc_status_ref_id = ds.doc_status_ref_id
  and p.pol_header_id = :pol_header
  and dsr.name = '� ������';
exception
      when no_data_found then :amount_z := 1;
end;

begin 
select amount, start_date, plan_date, gdv
into :amount_let, :ver_start_date, :plan_date_let, :gdv_let
from
(select ac.amount,
       to_char(pp.start_date,'dd.mm.yyyy') start_date,
       to_char(ac.plan_date + 45,'dd.mm.yyyy') plan_date,
       to_char(ac.plan_date,'dd.mm.')||to_char(extract(year from ac.plan_date) + 4) gdv
from p_policy pp,
     doc_doc dd,
     ac_payment ac
where pp.policy_id = dd.parent_id
      and dd.child_id = ac.payment_id
      and pp.policy_id = :POL_ID
      and ac.plan_date >= pp.start_date
order by ac.plan_date asc)
where rownum = 1;
exception
      when no_data_found then :amount_let := 0; :ver_start_date := ''; :plan_date_let := ''; :gdv_let := '';
end;  
 
begin
select count(*),
	   pc.p_cover_id
into :ex_invest, :p_cover_id
from p_policy p,
     as_asset ass, 
		 p_cover pc, 
		 t_prod_line_option plo
where ass.p_policy_id = p.policy_id
      and p.policy_id = ass.p_policy_id
      and p.policy_id = :POL_ID_OLD
      and pc.as_asset_id = ass.as_asset_id
      and plo.id = pc.t_prod_line_option_id
      and (plo.description = '�������������� �������������� �����'
	  		or plo.description = '������'
			or plo.description = '������2'
			or plo.description = '������2_1')
group by pc.p_cover_id;
 exception
      when no_data_found then :ex_invest := 0; :p_cover_id := 0; 
  end;  
 
declare
sum_surr number;
begin
sum_surr := nvl(round(Pkg_Policy_Cash_Sur.Get_Value_C_mine(:p_cover_id,to_date(:ver_start_date,'dd-mm-yyyy')),2),0);
:s_surr := sum_surr;
end;

DECLARE
  sum_surr_invest number := 0;
  is_invest_reserve NUMBER := 0;
BEGIN
FOR CUR_RES IN (
select pc.p_cover_id
from p_policy p,
     as_asset ass, 
	 p_cover pc, 
	 t_prod_line_option plo,
	 t_product_line pl
where ass.p_policy_id = p.policy_id
      and p.policy_id = ass.p_policy_id
      and p.policy_id = :POL_ID_OLD
      and pc.as_asset_id = ass.as_asset_id
      and plo.id = pc.t_prod_line_option_id
	  AND plo.product_line_id = pl.id
      AND pl.t_lob_line_id IN (SELECT lb.t_lob_line_id
                              FROM ins.t_lob_line lb
                              WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                              )
)
LOOP
  sum_surr_invest := sum_surr_invest + nvl(round(Pkg_Policy_Cash_Sur.Get_Value_C_mine(cur_res.p_cover_id,to_date(:ver_start_date,'dd-mm-yyyy')),2),0);
  is_invest_reserve := 1;
END LOOP;
:s_surr_reserve := sum_surr_invest;
:ex_invest_reserve := is_invest_reserve;
END;

begin
    select 
    to_char(pps.due_date,'dd.mm.yyyy'),
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm'),
	                  2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm'),
										4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
									    to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')),
decode(ph.fund_id,
	       122,'���.',
                       121,'���.',
                       5,'����.',
                       ''),
decode(ph.fund_id,
	       122,'���.',
                       121,'���.',
                       5,'����',
                       '')
  	into :FIRST_PAY, :NEXT_PAYS, :PA_KOD_VAL,:PA_KOD_VAL_UP
  	from v_policy_payment_schedule pps, ven_ac_payment ap, ven_p_policy pp, ven_t_payment_terms pt, p_pol_header ph
    where pps.pol_header_id = pp.pol_header_id 
    and pps.document_id = ap.payment_id
  	and pp.policy_id = :POL_ID
               and pp.pol_header_id = ph.policy_header_id
  	and pp.payment_term_id = pt.id
	  and rownum = 1;
--ap.payment_number = 1;
  exception
    when no_data_found then :NEXT_PAYS := 'X'; :FIRST_PAY := 'X'; :PA_KOD_VAL := ' '; :PA_KOD_VAL_UP := ' ';   
  end;


begin
    SELECT nvl(wr.addendum_note,'none')
into :UNDER_NOTE
FROM ven_p_policy p, ven_p_pol_header ph, ven_as_asset ass, ven_ASSURED_MEDICAL_EXAM ame, ven_as_assured sur,
       ven_as_assured_underwr wr
WHERE p.POL_HEADER_ID = ph.POLICY_HEADER_ID
  and p.POLICY_ID = ass.P_POLICY_ID(+)
  AND ass.AS_ASSET_ID = ame.AS_ASSURED_ID(+)
  and wr.as_assured_id = ass.AS_ASSET_ID
  and p.POLICY_ID = sur.P_POLICY_ID(+)
 AND p.policy_id = :POL_ID;
exception
    when no_data_found then :UNDER_NOTE := 'none';    
end;

begin
    SELECT decode(p.pol_ser,'APG',1,'FDEP',2,0)
into :pol_ser
FROM ven_p_policy p
WHERE p.policy_id = :POL_ID;
exception
    when no_data_found then :pol_ser := 0;    
end;

begin
    SELECT p.notice_ser||' '||p.notice_num
into :NOTICE_NUM
FROM ven_p_policy p
WHERE p.policy_id = :POL_ID;
exception
    when no_data_found then :NOTICE_NUM := '';    
end;

  begin
    select 
    to_char(pps.due_date,'dd.mm.yyyy'),
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm'),
	                  2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm'),
										4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
									    to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')),
      decode(ph.fund_id,
	       122,'���.',
                       121,'���.',
                       5,'����',
                       '')
  	into :FIRST_PAY_OLD, :NEXT_PAYS_OLD, :PA_KOD_VAL_OLD
  	from v_policy_payment_schedule pps, ven_ac_payment ap, ven_p_policy pp, ven_t_payment_terms pt, p_pol_header ph
    where pps.pol_header_id = pp.pol_header_id
           and pps.document_id = ap.payment_id
  	and pp.policy_id = :POL_ID_OLD
	and pp.pol_header_id = ph.policy_header_id
  	and pp.payment_term_id = pt.id
	  and ap.payment_number = 1;
  exception
    when no_data_found then :NEXT_PAYS_OLD := 'X'; :FIRST_PAY_OLD := 'X'; :PA_KOD_VAL_OLD := ' ';
  end;


  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>�������������� ����������</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>sterlta</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>7</o:Revision>
  <o:TotalTime>352</o:TotalTime>
  <o:LastPrinted>2007-07-11T07:09:00Z</o:LastPrinted>
  <o:Created>2007-11-06T14:26:00Z</o:Created>
  <o:LastSaved>2007-11-16T14:32:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>774</o:Words>
  <o:Characters>4412</o:Characters>
  <o:Lines>36</o:Lines>
  <o:Paragraphs>10</o:Paragraphs>
  <o:CharactersWithSpaces>5176</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>BestFit</w:Zoom>
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
   <w:UseWord2002TableStyleRules/>
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
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;
	mso-font-alt:\5B8B\4F53;
	mso-font-charset:134;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 135135232 16 0 262144 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:"\@SimSun";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-charset:134;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 135135232 16 0 262144 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	tab-stops:center 216.0pt right 432.0pt;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-GB;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
@page Section1
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 70.9pt;
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="9218"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="gstrahovatel" src="G_STRAHOVATEL">
<rw:getValue id="DATE_OF_BIRTH_tmp" src="DATE_OF_BIRTH" formatMask="DD.MM.YYYY"/>
<rw:getValue id="strahName_tmp" src="CONTACT_NAME"/>
<rw:getValue id="SHORT_NAME_TMP" src="SHORT_NAME"/>
<rw:getValue id="tmpVal" src="DOC_INF"/>  
<%
  if (!tmpVal.equals("@@")){ strax_doc = tmpVal; }
  strax_fio = strahName_tmp;
  strax_fio_sokr = SHORT_NAME_TMP;
  strax_dr = DATE_OF_BIRTH_tmp;
%>
</rw:foreach>

<rw:foreach id="G_STRAHOVATEL_OLD" src="G_STRAHOVATEL_OLD">
<rw:getValue id="strahName_tmp_old" src="CONTACT_NAME1"/>
<%
  strax_fio_old = strahName_tmp_old;
%>
</rw:foreach>

<rw:foreach id="G_ADMIN_PAY" src="G_ADMIN_PAY">
<rw:getValue id="ADMIN_PAY" src="ADMIN_PAY"/>
<% D_ADMIN_PAY = ADMIN_PAY;%>
</rw:foreach>

<rw:foreach id="G_RESERVE_PAY" src="G_RESERVE_PAY">
<rw:getValue id="RESERVE_PAY" src="RESERVE_PAY"/>
<% D_RESERVE_PAY = RESERVE_PAY;%>
</rw:foreach>

<rw:foreach id="G_PA_ROW_PRIL" src="G_PA_ROW_PRIL">
<rw:getValue id="PA_ROW_PRIL" src="PA_ROW_PRIL"/>
<% ROW_PRIL = Double.valueOf(PA_ROW_PRIL).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_dat_vyzh" src="G_dat_vyzh">
<rw:getValue id="DAT_VYZH" src="DAT_VYZH"/>
<% S_DAT_VYZH = DAT_VYZH;%>
</rw:foreach>

<rw:foreach id="G_ITOGO_PREM1" src="G_ITOGO_PREM">
<rw:getValue id="ITOGO_PREM_D_1" src="ITOGO_PREM_D"/>
<rw:getValue id="ITOGO_PREM_1" src="ITOGO_PREM"/>
<% D_ITOGO_PREM = ITOGO_PREM_1;%>
<% ITOGO_PREM_D = Double.valueOf(ITOGO_PREM_D_1).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_ITOGO_PREM_OLD" src="G_ITOGO_PREM_OLD">
<rw:getValue id="ITOGO_PREM_D1_2" src="ITOGO_PREM_D1"/>


<% if (ITOGO_PREM_D1_2 != null) ITOGO_PREM_D_OLD = Double.valueOf(ITOGO_PREM_D1_2).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_POLICY" src="G_POLICY">
<rw:getValue id="VERSION_NUM" src="VERSION_NUM"/>
<rw:getValue id="pol_ser_num" src="pol_ser_num"/>
<rw:getValue id="ADDENDUM_NOTE" src="ADDENDUM_NOTE"/>
<rw:getValue id="UNDERWRITING_NOTE" src="UNDERWRITING_NOTE"/>
<rw:getValue id="PA_PERIODICH" src="PA_PERIODICH"/>
<rw:getValue id="CONFIRM_DATE" src="CONFIRM_DATE" formatMask="DD.MM.YYYY"/>  
<rw:getValue id="CONFIRM_DATE_ADDENDUM" src="CONFIRM_DATE_ADDENDUM" formatMask="DD.MM.YYYY"/>  
<rw:getValue id="CONFDATE_OPL" src="CONFDATE_OPL" formatMask="DD.MM.YYYY"/>  
<rw:getValue id="CONFDATE_OPLEND" src="CONFDATE_OPLEND" formatMask="DD.MM.YYYY"/>  

<rw:getValue id="t_check" src="CHECK_SER"/>

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt'>�������������� ���������� � <%=VERSION_NUM%></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:12.0pt'>� �������� ����������� � <%=pol_ser_num%> �� <%=CONFIRM_DATE%></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='margin-left:-3.6pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=312 valign=top style='width:234.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>�. ������</p>
  </td>
  <td width=348 valign=top style='width:261.0pt;padding:0cm 5.4pt 0cm 5.4pt'><a
  name="f_add_start_date"></a>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:11.0pt'><o:p><%=CONFDATE_OPL%></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>��� ��� ���������� ������, ��������� � ����������
�����������, � ���� <rw:field id="" src="P_GENITIVE_POSITION_NAME"/><o:p></o:p> <rw:field id="" src="P_CASE_GENITIVE_SIGNER_NAME"/><o:p></o:p>, ������������ ��
��������� ������������ � <rw:field id="" src="P_PROCURORY_NUM"/><o:p></o:p>, � ����� �������, � <%=strax_fio%>,
<%=strax_doc%>, ��������� (��)<span style='mso-spacerun:yes'>� </span>�
���������� ��������������, � ������ �������, ��������� ��������� ��������������
���������� � �������� ����������� � <%=pol_ser_num%> �� <%=CONFIRM_DATE%> (�����
� �������) � �������������:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. �������� ������ 4 
�������� � ��������� ��������: </p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>
<rw:getValue id="pol_ser2" src="pol_ser"/>
<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600'> 4. ��������� �����������</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>���������
  �����, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>��������� �����, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:3.5pt'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="G_MAIN_COVER" src="G_MAIN_COVER">
 <tr style='mso-yfti-irow:3'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>�������� ���������: </span></b><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>&quot;
  <rw:field id="" src="MAIN_COVER"></rw:field>
  &quot;<!-- (����� 3.1. ����� ������� ����������� �� ���������������
  ����������� � ����������� �� ���������� ������� (����� - ����� �������
  �����������)--></span><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><rw:field id="" src="MAIN_COVER_SUM" formatMask="999999990.00"></rw:field></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><rw:field id="" src="MAIN_COVER_PREM" formatMask="999999990.00"></rw:field></span></b>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
 
 <rw:getValue id="J_EXIST_DOP" src="P_EXIST_DOP"/>
 <rw:getValue id="J_EXIST_DOP_MAND" src="P_EXIST_DOP_MAND"/>
 <% if ( !J_EXIST_DOP.equals("0") ) { %>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>�������������� ���������<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="G_DOP_SUMM" src="G_DOP_SUMM">
 <tr style='mso-yfti-irow:7'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="dop_progr"/></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>
    <rw:getValue id="j_need_x" src="need_x"/><% if (j_need_x.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ"/><% } %>
  <o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>
  <rw:getValue id="j_need_x_2" src="need_x"/><% if (j_need_x.equals("1")) { %><rw:field id="" src="dop_prem"/><% } else { %><rw:field id="" src="dop_prem"/><% } %>
  </span></b>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>

<%}%>

 <tr style='mso-yfti-irow:9'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>����� ��������� �����<% if ( !J_EXIST_DOP.equals("0") ) { %>:
  �������� � �������������� ���������<% } %> (<i style='mso-bidi-font-style:
  normal'>������������ <%=PA_PERIODICH%></i>):<o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=D_ITOGO_PREM%></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 valign=top style='width:116.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=216 colspan=2 valign=top style='width:162.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <% if (!D_ADMIN_PAY.equals("X")) { %>
 <tr style='mso-yfti-irow:11'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>���������������� �������� (<i
  style='mso-bidi-font-style:normal'>������������ ��� � ���</i>):<o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=D_ADMIN_PAY%></o:p></span></b></p>
  </td>
 </tr>
 <% } %>

<rw:getValue id="curr" src="PA_KOD_VAL"/>
<tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes'>
  <td width=657 colspan=5 valign=top style='width:492.75pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:  normal'><span style='font-size:8.0pt'>
<% if (!curr.equals("���.")) { %> �������� ���������� ������ ������������ �� ����� �� ��, ��������������
 ��� ��������������� ������ �� ���� ������. ��� ���������� �������, ��������� � ������� ����������
  ������, ������������ �������������<% } else { %> ��� ���������� �������, ��������� � ������� ����������
  ������, ������������ �������������<% } %>.<o:p></o:p></span></i></p>
  </td>
 </tr>


  <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=164 style='border:none'></td>
  <td width=155 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=168 style='border:none'></td>
  <td width=122 style='border:none'></td>
 </tr>
 <![endif]>



</table>


<rw:foreach id="G_PERIOD_OSN1" src="G_PERIOD_OSN">  
  <rw:getValue id="START_DATE_1" src="START_DATE" formatMask="DD.MM.YYYY"/>
  <rw:getValue id="END_DATE_1" src="END_DATE" formatMask="DD.MM.YYYY"/>
  <%prog_per += START_DATE_1.toString() + END_DATE_1.toString();  %>
</rw:foreach> 

<rw:foreach id="G_PERIOD_DOP_GL1" src="G_PERIOD_DOP_GL">  
  <rw:getValue id="START_DATE_2" src="START_DATE1" formatMask="DD.MM.YYYY"/>
  <rw:getValue id="END_DATE_2" src="END_DATE1" formatMask="DD.MM.YYYY"/>  
  <%prog_per += START_DATE_2.toString() + END_DATE_2.toString();  %>
</rw:foreach> 


<rw:foreach id="G_PERIOD_OSN_OLD1" src="G_PERIOD_OSN_OLD">  
  <rw:getValue id="START_DATE_3" src="START_DATE3" formatMask="DD.MM.YYYY"/>
  <rw:getValue id="END_DATE_3" src="END_DATE3" formatMask="DD.MM.YYYY"/>  
  <%prog_per_old += START_DATE_3.toString() + END_DATE_3.toString();  %>
</rw:foreach> 

<rw:foreach id="G_PERIOD_DOP_GL_OLD1" src="G_PERIOD_DOP_GL_OLD">  
  <rw:getValue id="START_DATE_4" src="START_DATE4" formatMask="DD.MM.YYYY"/>
  <rw:getValue id="END_DATE_4" src="END_DATE4" formatMask="DD.MM.YYYY"/>  
  <%prog_per_old += START_DATE_4.toString() + END_DATE_4.toString();  %>
</rw:foreach> 

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. �������� ������ <% if (t_check.equals("1")) { %>6<% } else { %>5<% } %>
�������� � ��������� ��������:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<rw:foreach id="G_PERIOD_OSN" src="G_PERIOD_OSN"> 

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=655 colspan=6 valign=top style='width:491.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'><% if (t_check.equals("1")) { %>6<% } else { %>5<% } %>. ������ �����������</span></b><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=655 colspan=6 valign=top style='width:491.4pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>���� �����������</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>������:<o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="START_DATE" formatMask="DD.MM.YYYY"></rw:field> 0:00</o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>���������:<o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p><rw:field id="" src="END_DATE" formatMask="DD.MM.YYYY"></rw:field> 23:59</o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'><rw:field id="" src="DESCRIPTION" ></rw:field></span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p></o:p></span></p>
  </td>
 </tr>

<rw:foreach id="G_PERIOD_DOP_GL" src="G_PERIOD_DOP_GL"> 
 
 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>���� �����������</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>������:<o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="START_DATE1" formatMask="DD.MM.YYYY"></rw:field> 0:00</o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>���������:<o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p><rw:field id="" src="END_DATE1" formatMask="DD.MM.YYYY"></rw:field> 23:59</o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'><rw:foreach id="G_PERIOD_DOP_L" src="G_PERIOD_DOP_L">  <rw:field id="" src="DESCRIPTION1" ></rw:field></rw:foreach></span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p></o:p></span></p>
  </td>
 </tr>

</rw:foreach>  
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
  <td width=655 colspan=6 valign=top style='width:491.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>
</rw:foreach> 

<% if (t_check.equals("1")) { %>

<% if ( J_EXIST_DOP_MAND.equals("0") ) { %> 

<% if ( !J_EXIST_DOP.equals("0") ) { %> 

<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>
��� ������� ������������� ������ ������������� ���������� ���������� ������, ����������
� �. 1 ���������� ��������������� ����������, ���� ����������� �� ��������� �������������� 
��������� ����� ��������� ���������������� �� 1 ��� �� ������� �������� ��������������� 
�������������� ��������.<o:p></o:p></span></i></b></p>

<% } %>

<% } %>

<% } %>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. �������� ����� 5 ������� 
8 "�������������� �������" � ��������� ��������: "��� ��������� ����������� (�����������) �������� 
���������� �� ����������� �������� �����".</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<rw:getValue id="ex_inv" src="ex_invest"/>
<rw:getValue id="ex_inv_res" src="ex_invest_reserve"/>
<rw:getValue id="z" src="amount_z"/>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>.<% if (ex_inv.equals("0")) {%> <%} else {%> � ����� �
������������ �������� � ��������� ��������� "������" ��������� ���������� � 2 � ��������. ������������ �����������
������� � ������� �������� �����, <rw:field id="" src="s_surr"/> <rw:field id="" src="PA_KOD_VAL"/> <%} %> 
<% if (ex_inv_res.equals("0")) {%> <%} else {%> � ����� � ������������ �������� � ��������� ��������� "������-������" ��������� 
���������� � 1 � � ��������. ������������ ����������� ������� � ������� �������� �����, <rw:field id="" src="s_surr_reserve"/> <rw:field id="" src="PA_KOD_VAL"/> <%} %> 
<% if (z.equals("1")) {%>��������� ���������� � <% if (t_check.equals("1")) { %>3<% } else { %>1<% } %> � ��������.<%} else {%> ��������� ���������� � <% if (t_check.equals("1")) { %>3<% } else { %>1<% } %> � ��������. ������������ ������ �������� ������������� ����� ������������ � ������� ������������ ��������� �������, 
<rw:field id="" src="amount_z"/> <rw:field id="" src="PA_KOD_VAL"/> <%} %> </p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. ��������� � ���������� � 
��������, ��������� � �. 1-4 ���������� ��������������� ����������, ��������� � 
<%=CONFIRM_DATE_ADDENDUM%>.</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. ��������� �������������� 
���������� �������� � ���� � ������� ���������� ��� ���������.</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. ��������� �������������� 
���������� �������� ��������� � ������������ ������ �������� ����������� � <%=pol_ser_num%> �� <%=CONFIRM_DATE%>.</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><span style='letter-spacing:-.1pt'><%=format.format(NUM_PP++)%>. ��������� �������������� 
���������� ��������� � ���� �����������, ������� ���������� ����, �� ������ ���������� ��� ������ �������.</span></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=657
 style='width:492.75pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=372 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>������������</p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'>____________________/<%=strax_fio_sokr%>/ </p>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
  style='mso-spacerun:yes'>���������������������������������������������������������������������������������������������������
  </span><span style='mso-spacerun:yes'>�����������������</span></p>
  </td>
  <td width=285 valign=top style='width:213.75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
</table>

</div>
</rw:foreach>

</body>

</html>


</rw:report>

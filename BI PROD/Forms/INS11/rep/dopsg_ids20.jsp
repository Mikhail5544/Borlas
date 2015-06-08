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
  double IROW_PRIL = 0;
  double RESERVE_PRIL = 0;
  
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
	<userParameter name="IS_VISIBLE_ADM" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_SER" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PAR_ANNIVERSARY_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PAR_SHOW_ANNIVERSARY" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
<userParameter name="NOTICE_NUM" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="PA_KOD_VAL_OLD" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="UNDER_NOTE" datatype="character" width="4000"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_DOP" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_EXIST_DOP_RESERVE" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="CHECK_SER" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/> 
    <userParameter name="NEXT_PAYS" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FIRST_PAY" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="FIRST_PAY_OLD" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="NEXT_PAYS_OLD" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="TO_PAY_RESERVE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="PAID_RESERVE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
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
       p.CONFIRM_DATE,
       p.CONFIRM_DATE + 14 confDate_opl,
       p.CONFIRM_DATE + 15 confDate_oplEnd,
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
            'Паспорт гражданина РФ  Номер','Паспорт'),'-',' ') sur_p
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
       case when vcp.contact_type_id not in (1,3,1030) then comp.dd else replace(NVL (TRIM (pkg_contact.get_primary_doc (iss.contact_id)),'@@'),'-',' ') end doc_inf, 
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc, v_temp_company comp
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id and comp.contact_id = iss.contact_id
 and iss.policy_id = :POL_ID;        ]]>
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
       --pkg_rep_utils.to_money(pc.premium) MAIN_COVER_PREM,
         upper(plo.description) MAIN_COVER
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
   --and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
   and pc.as_asset_id = ass.as_asset_id
   and plo.id = pc.t_prod_line_option_id
   and plo.product_line_id = pl.id
   and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
   AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
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
            ven_p_policy pp, 
            ven_as_asset ass, 
            ven_p_cover pc, 
            ven_t_prod_line_option plo
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
	 AND :IS_VISIBLE_ADM = 1
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
      <![CDATA[select 1 cnt,
	  				  pkg_rep_utils.to_money(pc.premium) RESERVE_PAY_PREM,
                      pkg_rep_utils.to_money(pc.ins_amount) RESERVE_PAY_AMOUNT,
					  'ИНВЕСТ-РЕЗЕРВ' RESERVE_PROG,
                      TO_CHAR(pc.start_date,'DD.MM.YYYY') RESERVE_START_DATE
    from 
            ins.p_policy pp, 
            ins.as_asset ass, 
            ins.p_cover pc, 
            ins.t_prod_line_option plo,
            ins.t_product_line pl,
            ins.t_lob_line lb
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     AND plo.product_line_id = pl.id
     AND pl.t_lob_line_id = lb.t_lob_line_id
     AND lb.brief = 'PEPR_INVEST_RESERVE';]]>
      </select>
      <displayInfo x="3.71912" y="2.75000" width="1.11450" height="0.19995"/>
      <group name="G_RESERVE_PAY">
        <displayInfo x="3.63940" y="3.26257" width="1.27551" height="0.43066"
        />
        <dataItem name="cnt"/>
      </group>
    </dataSource>
	<dataSource name="Q_DOP_SUMM">
      <select>
      <![CDATA[-- Доплнительные программы
select pkg_rep_utils.to_money(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money(pc.fee) as dop_prem,
decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              upper(plo.description)) as dop_progr,	   

--upper(plo.description) as dop_progr,
        decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАССЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
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
 and pc.decline_date is null
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief in ('OPTIONAL','MANDATORY')
 and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
 AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
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
           expression="decode ( upper ( plo.description ) , &apos;ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ&apos; , 1 , 0 )"
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
	<dataSource name="Q_DOP_SUMM_RESERVE">
      <select>
      <![CDATA[-- Доплнительные программы
select 1 cntr,
       pkg_rep_utils.to_money(pc.ins_amount) as dop_summ_r,
       pkg_rep_utils.to_money(pc.fee) as dop_prem_r,
decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              upper(plo.description)) as dop_progr_r,	   

        decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАССЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
              0) as need_x_r,
     TO_CHAR(pc.start_date,'DD.MM.YYYY') start_date_r

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
 AND pl.t_lob_line_id IN (SELECT ll.t_lob_line_id
                          FROM ins.t_lob_line ll
                          WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                          );]]>
      </select>
      <displayInfo x="3.87488" y="0.22913" width="1.18958" height="0.19995"/>
      <group name="G_dop_summ_Reserve">
        <displayInfo x="3.87915" y="0.76257" width="1.19214" height="1.28516"
        />
        <dataItem name="cntr"/>
      </group>
    </dataSource>
    <dataSource name="Q_VYK_SUMM">
      <select canParse="no">
      <![CDATA[select 
rownum as n,
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, PKG_POL_CASH_SURR_METHOD.get_insurance_year_date(ph.policy_header_id,d.insurance_year_date)  INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  AND p.pol_header_id = ph.policy_header_id
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
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.*, MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct prl.T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt, ins.t_lob_line lb
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY')
  AND lb.t_lob_line_id = prl.t_lob_line_id
  AND lb.brief != 'PEPR_INVEST_RESERVE'
  )
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
	<dataSource name="Q_VYK_SUMM_RESERVE">
      <select>
      <![CDATA[select 
v.row_numb,
v.INS_YEAR_FORMULA as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.svalue) as ransom,
to_char(v.start_date_surr,'dd.mm.yyyy') start_date_surr,
decode(lead(1) over(partition by v.start_date_surr order by v.row_numb),1,0,1) is_last
from
 (select d.start_cash_surr_date,
         d.end_cash_surr_date,
         SUM(d.value) svalue,
         MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1 INS_YEAR_FORMULA,
         row_number() over(PARTITION BY p.policy_cash_surr_id ORDER BY d.START_CASH_SURR_DATE) row_numb,
         p.p_cover_id,
         ir.start_date start_date_surr
  from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.p_pol_header ph,
  (SELECT pc.p_cover_id,
          pc.start_date
  FROM ins.as_asset a,
       ins.p_cover pc,
       ins.t_prod_line_option opt,
       ins.t_product_line pl,
       ins.t_lob_line lb
  WHERE a.p_policy_id = :POL_ID
    AND a.as_asset_id = pc.as_asset_id
    AND pc.t_prod_line_option_id = opt.id
    AND opt.product_line_id = pl.id
    AND pl.t_lob_line_id = lb.t_lob_line_id
    AND lb.brief = 'PEPR_INVEST_RESERVE') ir
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  AND p.pol_header_id = ph.policy_header_id
  and p.T_LOB_LINE_ID = (select distinct prl.T_LOB_LINE_ID from ven_t_product_line prl, ven_t_product_line_type prt, ins.t_lob_line lb
  where  prl.product_line_type_id = prt.product_line_type_id
  and p.T_LOB_LINE_ID = prl.T_LOB_LINE_ID
  and prl.visible_flag = 1
  and prt.brief in ('OPTIONAL','MANDATORY')
  AND lb.t_lob_line_id = prl.t_lob_line_id
  AND lb.brief = 'PEPR_INVEST_RESERVE'
  )
  AND p.p_cover_id = ir.p_cover_id
    GROUP BY d.start_cash_surr_date,
             d.end_cash_surr_date,
             MONTHS_BETWEEN(d.insurance_year_date,ph.start_date) / 12 + 1,
             p.p_cover_id,
             p.policy_cash_surr_id,
             ir.start_date
    order by d.start_cash_surr_date  ) v
order by v.start_date_surr, v.row_numb]]>
      </select>
      <displayInfo x="5.60425" y="0.21875" width="1.06250" height="0.19995"/>
      <group name="G_VYK_SUMM_RESERVE">
        <displayInfo x="5.40540" y="0.71033" width="1.45251" height="1.11426"
        />
        <dataItem name="row_numb" oracleDatatype="number" columnOrder="1"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Numb">
          <dataDescriptor expression="v.row_numb"
           descriptiveExpression="Row_Numb" order="1" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
		<dataItem name="year_number_r" oracleDatatype="number" columnOrder="2"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number R">
          <dataDescriptor expression="v.INS_YEAR_FORMULA"
           descriptiveExpression="year_number_r" order="2" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
		<dataItem name="period_start_r" datatype="vchar2" columnOrder="3"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start R">
          <dataDescriptor expression="to_char(v.start_cash_surr_date,'dd.mm.yyyy')"
           descriptiveExpression="period_start_r" order="3" width="10"/>
        </dataItem>
        <dataItem name="period_end_r" datatype="vchar2" columnOrder="4"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End R">
          <dataDescriptor expression="to_char(v.end_cash_surr_date,'dd.mm.yyyy')"
           descriptiveExpression="period_end_r" order="4" width="10"/>
        </dataItem>
		<dataItem name="ransom_r" datatype="vchar2" columnOrder="5"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ransom R">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep(v.svalue)"
           descriptiveExpression="ransom_r" order="5" width="10"/>
        </dataItem>
		<dataItem name="start_date_surr" datatype="vchar2" columnOrder="6"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Start Date Surr">
          <dataDescriptor expression="to_char(v.start_date_surr,'dd.mm.yyyy')"
           descriptiveExpression="start_date_surr" order="6" width="10"/>
        </dataItem>
		<dataItem name="is_last" oracleDatatype="number" columnOrder="7"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is Last">
          <dataDescriptor expression="decode(lead(1) over(partition by v.start_date_surr order by v.row_numb),1,0,1)"
           descriptiveExpression="is_last" order="7" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
	
    <dataSource name="Q_DAT_VYZH">
      <select>
      <![CDATA[select to_char(sysdate,'dd.mm.yyyy') as dat_vyzh from dual /* (Заявка 152979) select to_char(ds.start_date,'dd.mm.yyyy') dat_vyzh
from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id =:POL_ID*/]]>
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
	
	<dataSource name="IPA_ROW_PRIL">
      <select>
      <![CDATA[select count(1) IPA_ROW_PRIL
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  and p.t_lob_line_id in (30500038,5349)
]]>
      </select>
      <displayInfo x="5.10413" y="3.37500" width="1.39587" height="0.19995"/>
      <group name="G_IPA_ROW_PRIL">
        <displayInfo x="5.15417" y="3.85608" width="1.09998" height="0.43066"
        />
        <dataItem name="IPA_ROW_PRIL" oracleDatatype="number" columnOrder="51"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="count ( 1 )"
           descriptiveExpression="IPA_ROW_PRIL" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
	<dataSource name="RESERVE_ROW_PRIL">
      <select>
      <![CDATA[select count(1) RESERVE_ROW_PRIL
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d, ins.t_lob_line lb
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  AND p.t_lob_line_id = lb.t_lob_line_id
  AND lb.brief = 'PEPR_INVEST_RESERVE'
]]>
      </select>
      <displayInfo x="5.10413" y="3.37500" width="1.39587" height="0.19995"/>
      <group name="G_RESERVE_ROW_PRIL">
        <displayInfo x="5.15417" y="3.85608" width="1.09998" height="0.43066"
        />
        <dataItem name="RESERVE_ROW_PRIL" oracleDatatype="number" columnOrder="51"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="count ( 1 )"
           descriptiveExpression="RESERVE_ROW_PRIL" order="1"
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
            'Паспорт гражданина РФ  Номер','Паспорт'),'-',' ') sur_p
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
       case when vcp.contact_type_id not in (1,3,1030) then comp.dd else replace(NVL (TRIM (pkg_contact.get_primary_doc (iss.contact_id)),'@@'),'-',' ') end doc_inf, 
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc, v_temp_company comp
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id and comp.contact_id = iss.contact_id
 and iss.policy_id = :POL_ID_OLD;   ]]>
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
      <![CDATA[-- Доплнительные программы
select pkg_rep_utils.to_money(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money(pc.fee) as dop_prem,
decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              upper(plo.description)) as dop_progr,  

--upper(plo.description) as dop_progr,
        decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАССЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАССЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
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
 and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
 AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              );]]>
      </select>
      <displayInfo x="4.13538" y="5.02087" width="1.40625" height="0.19995"/>
      <group name="G_DOP_SUMM_OLD">
        <displayInfo x="4.07678" y="5.54370" width="1.25464" height="0.77246"
        />
        <dataItem name="need_x1" oracleDatatype="number" columnOrder="73"
         width="2" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Need X1">
          <dataDescriptor
           expression="decode ( upper ( plo.description ) , &apos;ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ&apos; , 1 , 0 )"
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
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
--and (pc.decline_reason_id is null or pc.decline_date is null)
and pc.decline_date is null
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
   AND plo.product_line_id = pl.id
   AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
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
            ven_p_policy pp, 
            ven_as_asset ass, 
            ven_p_cover pc, 
            ven_t_prod_line_option plo
    where pp.policy_id = :POL_ID_OLD
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
	 AND :IS_VISIBLE_ADM = 1
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
      <![CDATA[select '(основная программа)' as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
	    pc.end_date
from        
        		ven_p_policy pp, 
        		ven_as_asset ass, 
        		ven_p_cover pc, 
        		ven_t_prod_line_option plo,
        		ven_t_product_line pl,
        		ven_t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('RECOMMENDED')
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
          <dataDescriptor expression="&apos;(основная программа)&apos;"
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
      <![CDATA[select --decode(rownum,1,'дополнительные программы:' ||plo.description,'' || plo.description) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
	    pc.end_date
from        
        		ven_p_policy pp, 
        		ven_as_asset ass, 
        		ven_p_cover pc, 
        		ven_t_prod_line_option plo,
        		ven_t_product_line pl,
        		ven_t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
group by pc.start_date,  pc.end_date]]>
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
      <![CDATA[select decode(rownum,1,'дополнительные программы:' ||decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              (plo.description)),'' || decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              (plo.description))) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
	    pc.end_date
from        
        		ven_p_policy pp, 
        		ven_as_asset ass, 
        		ven_p_cover pc, 
        		ven_t_prod_line_option plo,
        		ven_t_product_line pl,
        		ven_t_product_line_type plt
            where pp.policy_id = :POL_ID
             and ass.p_policy_id = pp.policy_id
             and pc.as_asset_id = ass.as_asset_id
    and pc.decline_date is null
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
           expression="decode ( rownum , 1 , &apos;дополнительные программы:&apos; || plo.description , &apos;&apos; || plo.description )"
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
--nvl(pkg_contact.get_rel_description(su.assured_contact_id,b.contact_id),'X') as ben_rel,
nvl(ct.relationship_dsc,'X') ben_rel,
decode(b.value,null,'X',pkg_rep_utils.to_money(b.value) || ' ' || decode(pth.brief,'percent','%','absol',f.brief)) as ben_part
from 
ven_as_asset a,
ven_as_assured su , 
ven_as_beneficiary b,
CN_CONTACT_REL cr,
t_contact_rel_type ct,
t_path_type   pth,
fund f,
(select :POL_ID id from dual) dd
where a.p_policy_id(+) = dd.id
 and b.as_asset_id(+) = a.as_asset_id
 and su.as_assured_id(+) = a.as_asset_id
 and pth.t_path_type_id (+) = b.value_type_id
 and f.fund_id (+) = b.t_currency_id
 and b.cn_contact_rel_id = cr.id(+)
 and cr.relationship_type = ct.id(+)]]>
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
      <![CDATA[select '(основная программа)' as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
        pc.end_date
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
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('RECOMMENDED')
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
          <dataDescriptor expression="&apos;(основная программа)&apos;"
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
      <![CDATA[select --decode(rownum,1,'дополнительные программы:' ||plo.description,'' || plo.description) as description,
round(months_between(pc.end_date,pc.start_date)/12) years,
        pc.start_date,
	    pc.end_date
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
             and plo.product_line_id = pl.id
             and pl.product_line_type_id = plt.product_line_type_id
             and plt.brief in ('OPTIONAL','MANDATORY')
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
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
PAR_PAY_TRM_POL varchar2(30);
v_amount ins.pkg_payment.t_amount;
v_amount_p NUMBER := 0;
v_amount_paid NUMBER := 0;
v_amount_t NUMBER := 0;
v_amount_to_pay NUMBER := 0;
v_signer pkg_report_signer.typ_signer;
begin
	--Чирков 325770: FW: доработка печатной формы доп соглашений	  	  
	v_signer := pkg_report_signer.get_signer_id_by_rep_id(:REP_REPORT_ID);
	:P_GENITIVE_POSITION_NAME := v_signer.job_position_genitive;
	:P_CASE_GENITIVE_SIGNER_NAME := pkg_contact.get_fio_fmt(pkg_contact.get_fio_case(v_signer.name,'Р'),4);
	:P_PROCURORY_NUM := v_signer.procuratory_num;
	--325770-- 

BEGIN
FOR CUR_P IN (
select pc.p_cover_id
    from ins.p_policy pp, 
            ins.as_asset ass, 
            ins.p_cover pc, 
            ins.t_prod_line_option plo,
            ins.t_product_line pl,
            ins.t_lob_line lb,
			ins.status_hist st
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     AND plo.product_line_id = pl.id
     AND pl.t_lob_line_id = lb.t_lob_line_id
     AND lb.brief = 'PEPR_INVEST_RESERVE'
	 AND st.status_hist_id = pc.status_hist_id
     AND st.brief != 'DELETED'
)
LOOP
 v_amount := ins.pkg_payment.get_pay_cover_amount(cur_p.p_cover_id);
 v_amount_p := v_amount.pay_fund_amount;
 v_amount_paid := v_amount_paid + v_amount_p;
END LOOP;
  :PAID_RESERVE := pkg_rep_utils.to_money(v_amount_paid);
EXCEPTION WHEN OTHERS THEN
  :PAID_RESERVE := '0,00';
END;

select NVL(SUM(pc.fee),0)
into v_amount_to_pay
from ins.p_policy pp, 
     ins.as_asset ass, 
     ins.p_cover pc, 
     ins.t_prod_line_option plo,
     ins.t_product_line pl,
     ins.t_lob_line lb,
     ins.status_hist st,
     ins.p_pol_header ph
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 AND plo.product_line_id = pl.id
 AND pl.t_lob_line_id = lb.t_lob_line_id
 AND lb.brief = 'PEPR_INVEST_RESERVE'
 AND st.status_hist_id = pc.status_hist_id
 AND st.brief != 'DELETED'
 AND pp.pol_header_id = ph.policy_header_id;
 
v_amount_to_pay := v_amount_to_pay - v_amount_paid;
:TO_PAY_RESERVE := pkg_rep_utils.to_money(v_amount_to_pay);

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
 and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
 AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                              FROM ins.t_lob_line ll
                              WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                              )
 and pc.status_hist_id = sh.status_hist_id
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0;
 
  exception
      when no_data_found then :P_EXIST_DOP := 0; 
  end;
  
begin
select count(*) into :P_EXIST_DOP_RESERVE
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
 AND pl.t_lob_line_id IN (SELECT ll.t_lob_line_id
                          FROM ins.t_lob_line ll
                          WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                          )
 and pc.status_hist_id = sh.status_hist_id
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0;
 
  exception
      when no_data_found then :P_EXIST_DOP_RESERVE := 0; 
  end;
 
 begin
 select trm.brief
 into PAR_PAY_TRM_POL
 from ins.p_policy pol,
      ins.t_payment_terms trm
 where pol.policy_id = :POL_ID
   and pol.payment_term_id = trm.id;
 exception
      when no_data_found then PAR_PAY_TRM_POL := 'X'; 
 end;

if (PAR_PAY_TRM_POL = 'MONTHLY') THEN
  :IS_VISIBLE_ADM := 0;
else
  :IS_VISIBLE_ADM := 1;
END IF;

begin
select policy_id into :POL_ID_OLD
from(
select rownum rn, vpp.POLICY_ID 
from ven_p_policy vpp, document d, doc_templ dt
where vpp.POL_HEADER_ID = (select pol_header_id from ven_p_policy where policy_id = :POL_ID)
and d.doc_templ_id = dt.doc_templ_id
and vpp.POLICY_ID <> :POL_ID
and d.document_id = decode(vpp.VERSION_NUM, 1, vpp.POL_HEADER_ID, vpp.POLICY_ID)
and dt.name = (select a.name from document b, doc_templ a where b.doc_templ_id = a.doc_templ_id and b.document_id = :POL_ID)
order by vpp.START_DATE desc)
where rn = 1;
  exception
      when no_data_found then :POL_ID_OLD := 0; 
  end;

begin
    select 
    to_char(pps.due_date,'dd.mm.yyyy'),
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                      12,to_char(pps.due_date,'dd')||' числа каждого последующего месяца срока страхования',                                              
                      2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                                        4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
                                        to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования'),
decode(ph.fund_id,
	       122,'руб.',
                       121,'дол.',
                       5,'евро',
                       ''),
decode(ph.fund_id,
	       122,'РУБ.',
                       121,'ДОЛ.',
                       5,'ЕВРО',
                       '')
  	into :FIRST_PAY, :NEXT_PAYS, :PA_KOD_VAL,:PA_KOD_VAL_UP
  	from v_policy_payment_schedule pps, ins.ac_payment ap, ins.document dac, ven_p_policy pp, ven_t_payment_terms pt, p_pol_header ph
    where pps.pol_header_id = pp.pol_header_id 
    and pps.document_id = ap.payment_id
  	and pp.policy_id = :POL_ID
    and pp.pol_header_id = ph.policy_header_id
  	and pp.payment_term_id = pt.id
	and ap.payment_number = (
    select min(ac.payment_number)
    from doc_doc dd,
         ven_ac_payment ac
    where dd.child_id = ac.payment_id
          and dd.parent_id IN (SELECT pol.policy_id FROM ins.p_policy pol WHERE pol.pol_header_id = pp.pol_header_id)
          and ac.doc_templ_id = (select tmpl.doc_templ_id from ins.doc_templ tmpl where tmpl.brief = 'PAYMENT'
          and doc.get_doc_status_brief(ac.payment_id) != 'ANNULATED')
    )
	AND ap.payment_id = dac.document_id
	AND dac.doc_status_ref_id NOT IN (SELECT rf.doc_status_ref_id
									  FROM ins.doc_status_ref rf
									  WHERE rf.brief = 'ANNULATED');
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
        ,case
         when sysdate >= p.start_date
              and exists (select null
                            from p_pol_addendum_type pt
                                ,t_addendum_type     tt
                           where pt.p_policy_id        = p.policy_id
                             and pt.t_addendum_type_id = tt.t_addendum_type_id
                             and tt.brief in ('COVER_ADDING','COVER_DELETING','PERIOD_CHANGE','PAYMENTS_CHANGE'
                                             ,'PREMIUM_CHANGE','CLOSE_FIN_WEEKEND','FEE_INCREASE')
                             and p.t_pol_change_type_id = 1
                         )
         then 1
         else 0
         end
        ,to_char(ph.start_date,'dd.mm.')||to_char(sysdate,'yyyy') as anniversary_date
into :pol_ser, :par_show_anniversary, :par_anniversary_date
FROM ven_p_policy p, ven_p_pol_header ph
WHERE p.policy_id = :POL_ID and p.pol_header_id = ph.policy_header_id;
exception
    when no_data_found then :pol_ser := 0;    
end;

begin
    SELECT p.notice_ser||' '||p.notice_num,
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
into :NOTICE_NUM, :CHECK_SER
FROM ven_p_policy p
WHERE p.policy_id = :POL_ID;
exception
    when no_data_found then :NOTICE_NUM := ''; :CHECK_SER := 0;
end;

  begin
    select 
    to_char(pps.due_date,'dd.mm.yyyy'),
    decode(nvl(pt.number_of_payments,0),0,'X',1,to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                      12,to_char(pps.due_date,'dd')||' числа каждого последующего месяца срока страхования',                                             
                      2,to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования',
                                        4,to_char(add_months(pps.due_date,3),'dd.mm') || ', ' ||to_char(add_months(pps.due_date,6),'dd.mm') || ', ' ||
                                        to_char(add_months(pps.due_date,9),'dd.mm') || ', ' ||to_char(pps.due_date,'dd.mm')||' '||'каждого последующего года срока страхования'),
    decode(ph.fund_id,
	       122,'руб.',
                       121,'дол.',
                       5,'евро',
                       '')
  	into :FIRST_PAY_OLD, :NEXT_PAYS_OLD, :PA_KOD_VAL_OLD
  	from v_policy_payment_schedule pps, ac_payment ap, ins.document dac, ven_p_policy pp, ven_t_payment_terms pt, p_pol_header ph
    where pps.pol_header_id = pp.pol_header_id
           and pps.document_id = ap.payment_id
  	and pp.policy_id = :POL_ID_OLD
	and pp.pol_header_id = ph.policy_header_id
  	and pp.payment_term_id = pt.id
	and ap.payment_number = (
    select min(ac.payment_number)
    from doc_doc dd,
         ven_ac_payment ac
    where dd.child_id = ac.payment_id
          and dd.parent_id IN (SELECT pol.policy_id FROM ins.p_policy pol WHERE pol.pol_header_id = pp.pol_header_id)
          and ac.doc_templ_id = (select tmpl.doc_templ_id from ins.doc_templ tmpl where tmpl.brief = 'PAYMENT'
          and doc.get_doc_status_brief(ac.payment_id) != 'ANNULATED')
    )
	AND ap.payment_id = dac.document_id
	AND dac.doc_status_ref_id NOT IN (SELECT rf.doc_status_ref_id
									  FROM ins.doc_status_ref rf
									  WHERE rf.brief = 'ANNULATED');
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
<title>Дополнительное соглашение</title>
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
<rw:getValue id="RESERVE_PAY_PREM" src="RESERVE_PAY_PREM"/>
<% D_RESERVE_PAY = RESERVE_PAY_PREM;%>
</rw:foreach>

<rw:foreach id="G_PA_ROW_PRIL" src="G_PA_ROW_PRIL">
<rw:getValue id="PA_ROW_PRIL" src="PA_ROW_PRIL"/>
<% ROW_PRIL = Double.valueOf(PA_ROW_PRIL).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_IPA_ROW_PRIL" src="G_IPA_ROW_PRIL">
<rw:getValue id="IPA_ROW_PRIL" src="IPA_ROW_PRIL"/>
<% IROW_PRIL = Double.valueOf(IPA_ROW_PRIL).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_RESERVE_ROW_PRIL" src="G_RESERVE_ROW_PRIL">
<rw:getValue id="RESERVE_ROW_PRIL" src="RESERVE_ROW_PRIL"/>
<% RESERVE_PRIL = Double.valueOf(RESERVE_ROW_PRIL).doubleValue();%>
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
style='font-size:16.0pt'>Дополнительное соглашение № <%=VERSION_NUM%></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt'>к Договору страхования № <%=pol_ser_num%> от <%=CONFIRM_DATE%></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='margin-left:-3.6pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=312 valign=top style='width:234.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>г. Москва</p>
  </td>
  <td width=348 valign=top style='width:261.0pt;padding:0cm 5.4pt 0cm 5.4pt'><a
  name="f_add_start_date"></a>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:11.0pt'><o:p><%=S_DAT_VYZH%></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице <rw:field id="" src="P_GENITIVE_POSITION_NAME"/><o:p></o:p> <rw:field id="" src="P_CASE_GENITIVE_SIGNER_NAME"/><o:p></o:p>, действующего на
основании Доверенности № <rw:field id="" src="P_PROCURORY_NUM"/><o:p></o:p>, с одной стороны, и <%=strax_fio%>,
<%=strax_doc%>, именуемый (ая)<span style='mso-spacerun:yes'>  </span>в
дальнейшем «Страхователь», с другой стороны, заключили настоящее Дополнительное
Соглашение к Договору страхования № <%=pol_ser_num%> от <%=CONFIRM_DATE%>(далее
– Договор) о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>



<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. 2
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=175 colspan=3 valign=top style='width:131.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span lang=EN-US
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;color:#FF6600;mso-ansi-language:
  EN-US'>2</span></b><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'>. СТРАХОВАТЕЛЬ</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=480 colspan=3 valign=top style='width:360.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>Ф.И.О.</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><%=strax_fio%></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><%=strax_dr%></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 colspan=2 valign=top style='width:11.8pt;border:none;padding:
  0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОКУМЕНТ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='font-size:8.0pt;font-family:"Times New Roman";
  mso-fareast-font-family:"Times New Roman";mso-ansi-language:RU;mso-fareast-language:
  RU;mso-bidi-language:AR-SA'><o:p><%=strax_doc%></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 colspan=3 valign=top style='width:116.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 valign=top style='width:252.1pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=139 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=11 style='border:none'></td>
  <td width=5 style='border:none'></td>
  <td width=139 style='border:none'></td>
  <td width=336 style='border:none'></td>
 </tr>
 <![endif]>
</table>


  <rw:getValue id="SUR_C_1" src="SUR_C"/>

  <% SUR_C = SUR_C_1; %>
  

<rw:foreach id="G_POLICY_OLD" src="G_POLICY_OLD"> 
  <rw:getValue id="SUR_C_old_1" src="SUR_C1"/>
  <% SUR_C_old = SUR_C_old_1; %>
</rw:foreach>


<p class=MsoNormal style='text-align:justify'><span lang=EN-US
style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. 3
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>


<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=271 colspan=4 valign=top style='width:203.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600'>3. ЗАСТРАХОВАННОЕ ЛИЦО</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=384 colspan=2 valign=top style='width:288.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>Ф.И.О.</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="SUR_C"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА РОЖДЕНИЯ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="SUR_D" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=3 valign=top style='width:356.55pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=139 valign=top style='width:104.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОКУМЕНТ<o:p></o:p></span></b></p>
  </td>
  <td width=516 colspan=5 valign=top style='width:387.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'><span style='font-size:8.0pt;font-family:"Times New Roman";
  mso-fareast-font-family:"Times New Roman";mso-ansi-language:RU;mso-fareast-language:
  RU;mso-bidi-language:AR-SA'><o:p><rw:field id="" src="SUR_P"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes'>
  <td width=164 colspan=2 valign=top style='width:123.05pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 colspan=3 valign=top style='width:116.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=336 valign=top style='width:252.1pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=139 style='border:none'></td>
  <td width=25 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=91 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=336 style='border:none'></td>
 </tr>
 <![endif]>
</table>



 <rw:foreach id="G_MAIN_COVER1" src="G_MAIN_COVER">
  <rw:getValue id="MAIN_COVER1" src="MAIN_COVER"/>
  <%progr += MAIN_COVER1.toString();  %>
 </rw:foreach>
 
 <rw:foreach id="G_MAIN_COVER_OLD1" src="G_MAIN_COVER_OLD">
  <rw:getValue id="MAIN_COVER_old" src="MAIN_COVER1"/>
  <%progr_old += MAIN_COVER_old.toString();  %>
 </rw:foreach>
 
 
<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<rw:getValue id="pol_ser1" src="pol_ser"/>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. 
<% if (pol_ser1.equals("1")) {%> Стороны договорились п. 5
Договора изложить в следующей редакции: <%} 
else {%> Стороны договорились п. 4 Договора изложить в следующей редакции: <%}
 %></p>

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
  mso-bidi-font-size:8.0pt;color:#FF6600'>
<% if (pol_ser2.equals("1")) {%>5. <%} 
else {%>4. <%} %> ПРОГРАММЫ СТРАХОВАНИЯ</span></b><b
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
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая
  сумма, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Премия, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
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
  normal'><span style='font-size:8.0pt'>ОСНОВНАЯ ПРОГРАММА: </span></b><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>&quot;
  <rw:field id="" src="MAIN_COVER"></rw:field>
  &quot;<!-- (ПУНКТ 3.1. ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ ПО ИНДИВИДУАЛЬНОМУ
  СТРАХОВАНИЮ И СТРАХОВАНИЮ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ (ДАЛЕЕ - ОБЩИХ УСЛОВИЙ
  СТРАХОВАНИЯ)--></span><span
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
 
 <rw:getValue id="J_EXIST_DOP" src="P_EXIST_DOP"/><% if ( !J_EXIST_DOP.equals("0") ) { %>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<o:p></o:p></span></b></p>
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
  normal'><span style='font-size:8.0pt'>ИТОГО ПРЕМИЯ<% if ( !J_EXIST_DOP.equals("0") ) { %>:
  ОСНОВНАЯ И ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<% } %> (<i style='mso-bidi-font-style:
  normal'>уплачивается <%=PA_PERIODICH%></i>):<o:p></o:p></span></b></p>
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
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <% if (!D_ADMIN_PAY.equals("X")) { %>
 <tr style='mso-yfti-irow:11'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ (<i
  style='mso-bidi-font-style:normal'>уплачивается раз в год</i>):<o:p></o:p></span></b></p>
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
 
 <rw:getValue id="J_EXIST_DOP_RES" src="P_EXIST_DOP_RESERVE"/><% if ( !J_EXIST_DOP_RES.equals("0") ) { %>
 <tr style='mso-yfti-irow:6'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая
  сумма, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Премия, <rw:field id="" src="PA_KOD_VAL"/><o:p></o:p></span></i></p>
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
 <rw:foreach id="G_DOP_SUMM_RESERVE" src="G_DOP_SUMM_RESERVE">
 <tr style='mso-yfti-irow:7'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="dop_progr_r"/> от <rw:field id="" src="start_date_r"/></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>
    <rw:getValue id="j_need_x_11" src="need_x_r"/><% if (j_need_x_11.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ_r"/><% } %>
  <o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>
  <rw:getValue id="j_need_x_22" src="need_x_r"/><% if (j_need_x_22.equals("1")) { %><rw:field id="" src="dop_prem_r"/><% } else { %><rw:field id="" src="dop_prem_r"/><% } %>
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
  <td width=168 valign=top style='width:126.0pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 </rw:foreach>

<tr style='mso-yfti-irow:8'>
  <td width=203 colspan=4 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:8.0pt'>ИТОГО СТРАХОВАЯ ПРЕМИЯ ПО ПРОГРАММАМ "Инвест-резерв" (оплачено):<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><rw:field id="" src="PAID_RESERVE"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=203 colspan=4 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:8.0pt'>ИТОГО СТРАХОВАЯ ПРЕМИЯ ПО ПРОГРАММАМ "Инвест-резерв" (к оплате):<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><rw:field id="" src="TO_PAY_RESERVE"/><o:p></o:p></span></b></p>
  </td>
 </tr>
 
 <%}%>

<rw:getValue id="curr" src="PA_KOD_VAL"/>
<tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes'>
  <td width=657 colspan=5 valign=top style='width:492.75pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:  normal'><span style='font-size:8.0pt'>
<% if (!curr.equals("руб.")) { %> Рублевый эквивалент премии уплачивается по курсу ЦБ РФ, установленному
 для соответствующей валюты на дату уплаты. Все банковские расходы, связанные с оплатой страховой
  премии, оплачиваются Страхователем. <% } else { %> Все банковские расходы, связанные с оплатой страховой
  премии, оплачиваются Страхователем. <% } %>.<o:p></o:p></span></i></p>
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

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. <% if (t_check.equals("1")) { %>6<% } else { %>5<% } %>
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<rw:foreach id="G_PERIOD_OSN" src="G_PERIOD_OSN"> 

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=655 colspan=6 valign=top style='width:491.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'><% if (t_check.equals("1")) { %>6<% } else { %>5<% } %>. ПЕРИОД СТРАХОВАНИЯ</span></b><span style='font-size:8.0pt'><o:p></o:p></span></p>
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
  normal'><span style='font-size:8.0pt'>СРОК СТРАХОВАНИЯ</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="YEARS" ></rw:field></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>НАЧАЛО:<o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="START_DATE" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>ОКОНЧАНИЕ:<o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p><rw:field id="" src="END_DATE" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
 </tr>

 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'><rw:field id="" src="DESCRIPTION" ></rw:field></span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p></o:p></span></p>
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
  normal'><span style='font-size:8.0pt'>СРОК СТРАХОВАНИЯ</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="YEARS1" ></rw:field></o:p></span></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>НАЧАЛО:<o:p></o:p></span></b></p>
  </td>
  <td width=90 valign=top style='width:67.6pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="START_DATE1" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
  <td width=90 valign=top style='width:67.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt'>ОКОНЧАНИЕ:<o:p></o:p></span></b></p>
  </td>
  <td width=96 valign=top style='width:72.0pt;padding:0cm 5.4pt 0cm 5.4pt'><span
  style='font-size:8.0pt;font-family:"Times New Roman";mso-fareast-font-family:
  "Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
  AR-SA'></span>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><o:p><rw:field id="" src="END_DATE1" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:2'>
  <td width=247 valign=top style='width:185.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'><rw:foreach id="G_PERIOD_DOP_L" src="G_PERIOD_DOP_L">  <rw:field id="" src="DESCRIPTION1" ></rw:field></rw:foreach></span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'></o:p></span></p>
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

<p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
normal'><i style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Если
Страхователь за 30 (тридцать) календарных дней до дня окончания срока
страхования по дополнительным программам, не выразит желания исключить
какую-либо из указанных<span style='mso-spacerun:yes'>  </span>программ<span
style='mso-spacerun:yes'>  </span>из настоящего Договора или не предложит иные
условия, при условии своевременной оплаты Страхователем очередной премии,
указанного в п.№ 4 настоящего полиса, срок страхования по указанной(ым)
дополнительной(ым) программе(ам)<span style='mso-spacerun:yes'>  </span>будет
считаться пролонгированным на 1 год на прежних условиях соответствующей
дополнительной программ..<o:p></o:p></span></i></b></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>



<rw:getValue id="PA_KOD_VAL" src="PA_KOD_VAL"/>
<rw:getValue id="PA_KOD_VAL_UP" src="PA_KOD_VAL_UP"/>
<rw:getValue id="NEXT_PAYS_1" src="NEXT_PAYS"/>
<rw:getValue id="NEXT_PAYS_OLD" src="NEXT_PAYS_OLD"/>


<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. <% if (t_check.equals("1")) { %>5<% } else { %>6<% } %>
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=655 colspan=4 valign=top style='width:491.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'><% if (t_check.equals("1")) { %>5<% } else { %>6<% } %>. УСЛОВИЯ И СРОКИ УПЛАТЫ СТРАХОВОЙ ПРЕМИИ</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:3.5pt'>
  <td width=164 valign=top style='width:123.05pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=259 colspan=3 valign=top style='width:194.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА УПЛАТЫ ПЕРВОГО ВЗНОСА:</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=396 valign=top style='width:297.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:8.0pt'><o:p><rw:field id="" src="FIRST_PAY"/></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=164 valign=top style='width:123.05pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=259 colspan=3 valign=top style='width:194.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДАТА УПЛАТЫ ПОСЛЕДУЮЩИХ ВЗНОСОВ:<o:p></o:p></span></b></p>
  </td>
  <td width=396 valign=top style='width:297.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="NEXT_PAYS"/> </o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes'>
  <td width=164 valign=top style='width:123.05pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=475 colspan=2 valign=top style='width:356.55pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=164 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=79 style='border:none'></td>
  <td width=396 style='border:none'></td>
 </tr>
 <![endif]>
</table>



<rw:foreach id="G_VYGOD1" src="G_VYGOD">  
  <rw:getValue id="BENEFICIARY_1" src="BENEFICIARY"/>
  <%vygod += BENEFICIARY_1.toString();  %>
</rw:foreach> 

<rw:foreach id="G_VYGOD_OLD1" src="G_VYGOD_OLD">  
  <rw:getValue id="BENEFICIARY1_1" src="BENEFICIARY1"/>
  <%vygod_old += BENEFICIARY1_1.toString();  %>
</rw:foreach> 


<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. 7
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=657 valign=top style='width:492.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'>7. ВЫГОДОПРИОБРЕТАТЕЛИ НА СЛУЧАЙ СМЕРТИ</span></b><span
  style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=657 valign=top style='width:492.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:8.0pt;
  color:#FF6600'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=631
 style='width:473.4pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=235 valign=top style='width:176.4pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>Ф.И.О.</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ДАТА
   РОЖДЕНИЯ</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=192 valign=top style='width:144.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>РОДСТВЕННЫЕ
   ОТНОШЕНИЯ</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=84 valign=top style='width:63.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ДОЛЯ.</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
<rw:foreach id="G_VYGOD" src="G_VYGOD">  
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=235 style='width:176.4pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id="" src="BENEFICIARY"></rw:field></o:p></span></p>
  </td>
  <td width=120 style='width:90.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id="" src="BEN_BIRTH" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
  <td width=192 style='width:144.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id="" src="BEN_REL" ></rw:field></o:p></span></p>
  </td>
  <td width=84 style='width:63.0pt;border-top:none;border-left:none;border-bottom:
  dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;mso-border-top-alt:
  dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id="" src="BEN_PART"></rw:field></o:p></span></p>
  </td>
 </tr>
</rw:foreach> 
</table>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились п. 8
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=657 valign=top style='width:492.65pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span lang=EN-US style='font-size:9.0pt;mso-bidi-font-size:
  8.0pt;color:#FF6600;mso-ansi-language:EN-US'>8</span></b><b><span
  style='font-size:9.0pt;mso-bidi-font-size:8.0pt;color:#FF6600'>.
  ДОПОЛНИТЕЛЬНЫЕ УСЛОВИЯ</span></b><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>1.
ДОГОВОР СТРАХОВАНИЯ ЗАКЛЮЧЕН НА ОСНОВАНИИ &quot;ОБЩИХ УСЛОВИЙ ПО
ИНДИВИДУАЛЬНОМУ СТРАХОВАНИЮ ЖИЗНИ И СТРАХОВАНИЮ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ&quot;,
УТВЕРЖДЕННЫХ ГЕНЕРАЛЬНЫМ ДИРЕКТОРОМ ООО &quot;СК &quot;РЕНЕССАНС
ЖИЗНЬ&quot;<span style='mso-spacerun:yes'>  </span>23.06.2006 ГОДА.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>2.
СТОРОНЫ ПРИЗНАЮТ РАВНУЮ ЮРИДИЧЕСКУЮ СИЛУ СОБСТВЕННОРУЧНОЙ ПОДПИСИ И ФАКСИМИЛЕ
ПОДПИСИ СТРАХОВЩИКА (ВОСПРОИЗВЕДЕНЕННОЕ МЕХАНИЧЕСКИМ ИЛИ ИНЫМ СПОСОБОМ С
ИСПОЛЬЗОВАНИЕМ КЛИШЕ) НА ПОЛИСЕ, А ТАКЖЕ ПРИЛОЖЕНИЯХ И ДОПОЛНИТЕЛЬНЫХ
СОГЛАШЕНИЯХ К НЕМУ.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>3.
ПРИ ДОСРОЧНОМ РАСТОРЖЕНИИ ДОГОВОРА ВЫПЛАТА ПРЕДУСМОТРЕННОЙ СООТВЕТСТВУЮЩЕЙ
ПРОГРАММОЙ СТРАХОВАНИЯ ВЫКУПНОЙ СУММЫ ПРОИЗВОДИТСЯ СОГЛАСНО ТАБЛИЦЕ ВЫКУПНЫХ
СУММ (ПРИЛОЖЕНИЕ №1, ПРИЛОЖЕНИЕ №2).<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>4.
ТЕРРИТОРИЯ СТРАХОВАНИЯ: ВЕСЬ МИР.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>5.
ВРЕМЯ ДЕЙСТВИЯ СТРАХОВОЙ ЗАЩИТЫ: 24 ЧАСА.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>6.
ДАТА ДОСРОЧНОГО ПРЕКРАЩЕНИЯ ВЫЖИДАТЕЛЬНОГО ПЕРИОДА: <o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>7. ЛЬГОТНЫЙ
ПЕРИОД: 45 ДНЕЙ.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'>8. ДЛЯ
РАСТОРЖЕНИЯ ДОГОВОРА СТРАХОВАНИЯ В СЛУЧАЯХ, ПРЕДУСМОТРЕННЫХ П.П. 5.8, 7.9
ПРАВИЛ, СТРАХОВЩИК ДОЛЖЕН НАПРВИТЬ СТРАХОВАТЕЛЮ ПИСЬМЕННОЕ ИЗВЕЩЕНИЕ МЕНЕЕ ЧЕМ
ЗА 21 (ДВАДЦАТЬ ОДИН) ДЕНЬ ДО ПРЕДПОЛАГАЕМОЙ ДАТЫ ПРЕКРАЩЕНИЯ ДОГОВОРА, ПРИ
ЭТОМ ДОГОВОР СЧИТАЕТСЯ РАСТОРГНУТЫМ С ДАТЫ, УКАЗАННОЙ В ИЗВЕЩЕНИИ.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>

<% if (ROW_PRIL > 0) {%>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились
Приложение № <% if (t_check.equals("1")) { %>3<% } else { %>1<% } %><span style='color:blue'> </span>Договора изложить в следующей
редакции:</p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ № 1<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью полиса №<span style='mso-spacerun:yes'>  </span><span
  style='mso-spacerun:yes'> </span><%=pol_ser_num%><o:p></o:p></span></i></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ОСНОВНОЙ ПРОГРАММЕ <o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-top:0cm;margin-right:4.55pt;margin-bottom:
0cm;margin-left:-12.45pt;margin-bottom:.0001pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt'><span style='mso-tab-count:4'>                                                                                                                                                        </span></span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
EN-US'><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <a name="currency_3"><rw:field id="" src="PA_KOD_VAL_UP"/></a></span></b><b style='mso-bidi-font-weight:
   normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 <rw:foreach id="G_VYK_SUMM" src="G_VYK_SUMM">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="N"/></rw:field></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="YEAR_NUMBER"/></rw:field></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_START"/></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_END"/></rw:field></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="RANSOM"/></rw:field></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<%}%>



<% if (IROW_PRIL > 0) {%>
<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились
Приложение № 2<span style='color:blue'> </span>Договора изложить в следующей
редакции:</p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ № 2<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью полиса №<span style='mso-spacerun:yes'>  </span><span
  style='mso-spacerun:yes'> </span><%=pol_ser_num%><o:p></o:p></span></i></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ИНВЕСТ <o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-top:0cm;margin-right:4.55pt;margin-bottom:
0cm;margin-left:-12.45pt;margin-bottom:.0001pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt'><span style='mso-tab-count:4'>                                                                                                                                                        </span></span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
EN-US'><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <a name="currency_3"><rw:field id="" src="PA_KOD_VAL_UP"/></a></span></b><b style='mso-bidi-font-weight:
   normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 <rw:foreach id="G_VYK_SUMM_I" src="G_VYK_SUMM_I">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="N_I"/></rw:field></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="YEAR_NUMBER_I"/></rw:field></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_START_I"/></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_END_I"/></rw:field></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="RANSOM_I"/></rw:field></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<% }  %>

<% if (RESERVE_PRIL > 0) {%>
<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ №1 а<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>к Дополнительному соглашению № <%=VERSION_NUM%><o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью Полиса № <%=pol_ser_num%><o:p></o:p></span></i></p>
  </td>
 </tr>
</table>

<rw:foreach id="G_VYK_SUMM_RESERVE" src="G_VYK_SUMM_RESERVE">
<rw:getValue id="number_period" src="row_numb"/>
<rw:getValue id="is_last" src="is_last"/>

<% if (number_period.equals("1")) {%> 

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ГАРАНТИРОВАННЫХ ВЫКУПНЫХ СУММ ПО ПРОГРАММЕ<span
  style='mso-spacerun:yes'>  </span>"Инвест-Резерв" </b> от <rw:field id=""  src="start_date_surr"/><o:p></o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p><b
  style='mso-bidi-font-weight:normal'>(выкупная сумма засчитывается в счет оплаты очередного взноса)</o:p></b></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </table>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <rw:field id="" src="PA_KOD_VAL_UP"/></span></b><b style='mso-bidi-font-weight:
   normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>

<%}  %>

  <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="row_numb"/></rw:field></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="YEAR_NUMBER_R"/></rw:field></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_START_R"/></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_END_R"/></rw:field></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="RANSOM_R"/></rw:field></o:p></span></p>
  </td>
 </tr>

<% if (is_last.equals("1")) {%>
</table>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<% }  %>
</rw:foreach>
<% }  %>


<% if (RESERVE_PRIL > 0) {%>
<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ №1 б<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>к Дополнительному соглашению № <%=VERSION_NUM%><o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью Полиса № <%=pol_ser_num%><o:p></o:p></span></i></p>
  </td>
 </tr>
</table>

<rw:foreach id="G_VYK_SUMM_RESERVE1" src="G_VYK_SUMM_RESERVE">
<rw:getValue id="number_period1" src="row_numb"/>
<rw:getValue id="is_last1" src="is_last"/>

<% if (number_period1.equals("1")) {%> 

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ГАРАНТИРОВАННЫХ ВЫКУПНЫХ СУММ ПО ПРОГРАММЕ<span
  style='mso-spacerun:yes'>  </span>"Инвест-Резерв" </b> от <rw:field id=""  src="start_date_surr"/><o:p></o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p><b
  style='mso-bidi-font-weight:normal'>(выкупная сумма не засчитывается в счет оплаты очередного взноса)</o:p></b></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </table>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <rw:field id="" src="PA_KOD_VAL_UP"/></span></b><b style='mso-bidi-font-weight:
   normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>

<%}  %>

  <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="row_numb"/></rw:field></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="YEAR_NUMBER_R"/></rw:field></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_START_R"/></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_END_R"/></rw:field></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="RANSOM_R"/></rw:field></o:p></span></p>
  </td>
 </tr>

<% if (is_last1.equals("1")) {%>
</table>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<% }  %>
</rw:foreach>
<% }  %>

<% if (0==1) {%>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:always'>
</span>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились
Приложение № 2<span style='color:blue'> </span>Договора изложить в следующей
редакции:</p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ № 2<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является составной
  и неотъемлемой частью полиса №<span style='mso-spacerun:yes'>  </span><span
  style='mso-spacerun:yes'> </span><%=pol_ser_num%><o:p></o:p></span></i></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО ДОПОЛНИТЕЛЬНОЙ
  ПРОГРАММЕ «ИНВЕСТ»<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-top:0cm;margin-right:4.55pt;margin-bottom:
0cm;margin-left:-12.45pt;margin-bottom:.0001pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt'><span style='mso-tab-count:4'>                                                                                                                                                        </span></span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
EN-US'><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <rw:field id="" src="PA_KOD_VAL"/></span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
<rw:foreach id="G_VYK_SUMM" src="G_VYK_SUMM">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="N"/></rw:field></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="YEAR_NUMBER"/></rw:field></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_START"/></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id=""  src="PERIOD_END"/></rw:field></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:"Times New Roman";mso-fareast-font-family:"Times New Roman";
  mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:AR-SA'></span>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><rw:field id="" src="RANSOM"/></rw:field></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<%}%>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>



<rw:getValue id="under" src="UNDER_NOTE"/><% if ( !under.equals("none") ) { %><p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
style='letter-spacing:-.1pt'><%=format.format(NUM_PP++)%>. Учитывая сведения о заболеваниях застрахованного, содержащиеся 
в заявлении на страхование № <rw:field id="" src="NOTICE_NUM"/>, дополнительно к исключениям, указанным в п. 4.5 «Правила страхования жизни»,
 не являются страховыми случаями по риску "Инвалидность по любой причине" <rw:field id="" src="UNDER_NOTE"/>.
<o:p></o:p></p><% } else { %><% } %>


<% if (ITOGO_PREM_D_OLD < ITOGO_PREM_D) {%>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>


<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><%=format.format(NUM_PP++)%>. </b> <b
style='mso-bidi-font-weight:normal'>Страхователь обязан доплатить страховую
премию в размере <%=format2.format(ITOGO_PREM_D-ITOGO_PREM_D_OLD)%> <rw:field id="" src="PA_KOD_VAL"/> <i style='mso-bidi-font-style:normal'>(валюта
договора)</i>. Доплату необходимо произвести до <%=CONFDATE_OPL%> <i style='mso-bidi-font-style:
normal'></i>
. В случае неоплаты в срок указанной страховой премии, договор считается
расторгнутым с <%=CONFDATE_OPLEND%> .<o:p></o:p></b></p>
<%} else {%>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><%=format.format(NUM_PP++)%>. Страховщик
обязуется возвратить страхователю часть оплаченной страховой премии, в размере
<%=format2.format(ITOGO_PREM_D_OLD-ITOGO_PREM_D)%> <rw:field id="" src="PA_KOD_VAL"/> <i style='mso-bidi-font-style:normal'>(валюта договора)</i>.<o:p></o:p></b></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
style='letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>

<% } %>
<rw:getValue id="is_show" src="PAR_SHOW_ANNIVERSARY"/>
<%
if (is_show.equals("1"))
{
%>
<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
style='letter-spacing:-.1pt'><%=format.format(NUM_PP++)%>. Изменения и дополнения к Договору, указанные в п. 1-4 настоящего Дополнительного
соглашения, действуют с <rw:field id="" src="PAR_ANNIVERSARY_DATE"/>.<o:p></o:p></span></p>
<%}%>

<rw:getValue id="pol_ser" src="pol_ser"/>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
style='letter-spacing:-.1pt'><%=format.format(NUM_PP++)%>. Во всем остальном, что не предусмотрено
настоящим Дополнительным Соглашением Стороны руководствуются положениями
Договора<% if (pol_ser.equals("1")) {%>, Полисными условиями к договору от несчастных случаев и болезней
по программе "Защита" от 17.04.2008 <%} 
else {%> <%if (pol_ser.equals("2")) {%>, Полисными условиями к программе "Семейный депозит". <%}
else {%>.<%} } %> <o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><%=format.format(NUM_PP++)%>. Настоящее Дополнительное соглашение вступает в силу с момента подписания его сторонами.<b style='mso-bidi-font-weight:normal'><span
style='color:blue'> </span><o:p></o:p></b></p>

<p class=MsoNormal><span style='letter-spacing:-.1pt'><%=format.format(NUM_PP++)%>. Настоящее
Дополнительное соглашение является составной и неотъемлемой частью Договора
страхования № <%=pol_ser_num%> от <%=CONFIRM_DATE%>.</span></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><span style='mso-fareast-font-family:SimSun;color:black;mso-fareast-language:
ZH-CN'><%=format.format(NUM_PP++)%>. Настоящее Дополнительное Соглашение</span> подписано в двух
экземплярах, имеющих одинаковую силу, по одному экземпляру для каждой Стороны.</p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=657
 style='width:492.75pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=372 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>СТРАХОВАТЕЛЬ</p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'>____________________/<%=strax_fio_sokr%>/ </p>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
  style='mso-spacerun:yes'>                                                                                                   
  </span><span style='mso-spacerun:yes'>                 </span></p>
  </td>
  <td width=285 valign=top style='width:213.75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=372 valign=top style='width:278.95pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=285 valign=top style='width:213.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>


</rw:report>
